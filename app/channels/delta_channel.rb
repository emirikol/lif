class DeltaChannel < ApplicationCable::Channel
  def subscribed
    stream_from "delta"
    # ActionCable.server.broadcast "delta", {actions: [] }
  end

  def board data
    File.open('log/state.log', 'a')  {|f| f.write({board_id: data['id']}.to_json+"\n")}
    File.open('log/actions.log', 'a'){|f| f.write("ws,board,#{data.to_json}\n")}
    Board.activate data['id']
    ActionCable.server.broadcast "delta", {actions: [:clear] + Crystal.active.map{|c| {id: c.cell_id, crystal: c.state}}}
  end

  def build data 
    c = Crystal.active.where(cell_id: data['id']).first
    File.open('log/actions.log', 'a'){|f| f.write("ws,build,#{data.to_json}}\n")}
    case c&.state
    when 'live'
      c.destroy
    when 'dead'
      c.update_attributes(state: :live)
    when nil
      c = Crystal.active.create(cell_id: data['id'], state: :dead)
    end
    ActionCable.server.broadcast "delta", {actions: [{id: c.cell_id, crystal: c.persisted? ? c.state : nil}]}
  end

  def light data #{id: ...}
    # check if cell is has a crystal, and is dead or lit. toggle it and send result
    # {actions: [{id: cell_id, token: token_id, crystal: live/dead/null}, ...]}
    File.open('log/actions.log', 'a'){|f| f.write("ws,light,#{data.to_json}}\n")}
    if (c = Crystal.active.where(cell_id: data['id']).first)  && c.state != 'live'
      c.light!
      ActionCable.server.broadcast "delta", {actions: [{id: data['id'], crystal: c.state}]}
    end
  end

  def move data #token_id, cell_id
    # update token cell_id
    File.open('log/actions.log', 'a'){|f| f.write("ws,move,#{data.to_json}\n")}
    t = Token.find(data['token_id'])
    t.update_attributes(cell_id: data['cell_id'])
    ActionCable.server.broadcast "delta", {actions: [{id: t.cell_id, token_id: t.id}]}
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
