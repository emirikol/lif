class DeltaChannel < ApplicationCable::Channel
  def subscribed
    stream_from "delta"
    # ActionCable.server.broadcast "delta", {actions: [] }
  end

  def build data 
    c = Crystal.where(cell_id: data['id']).first
    File.open('log/actions.log', 'a'){|f| f.write("build,#{data['id']}\n")}
    case c&.state
    when 'live'
      c.destroy
    when 'dead'
      c.update_attributes(state: :live)
    when nil
      c = Crystal.create(cell_id: data['id'], state: :dead)
    end
    ActionCable.server.broadcast "delta", {actions: [{id: c.cell_id, crystal: c.persisted? ? c.state : nil}]}
  end

  def light data #{id: ...}
    # check if cell is has a crystal, and is dead or lit. toggle it and send result
    # {actions: [{id: cell_id, token: token_id, crystal: live/dead/null}, ...]}
    File.open('log/actions.log', 'a'){|f| f.write("light,#{data['id']}\n")}
    if (c = Crystal.where(cell_id: data['id']).first)  && c.state != 'live'
      c.light!
      ActionCable.server.broadcast "delta", {actions: [{id: data['id'], crystal: c.state}]}
    end
  end

  def move data #token_id, cell_id
    # update token cell_id
    File.open('log/actions.log', 'a'){|f| f.write("move,#{data['token_id']},#{data['cell_id']}\n")}
    t = Token.find(data['token_id'])
    t.update_attributes(cell_id: data['cell_id'])
    ActionCable.server.broadcast "delta", {actions: [{id: t.cell_id, token_id: t.id}]}
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
