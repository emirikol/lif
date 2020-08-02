class GamesController < ApplicationController


  def index
    @cells = Cell.order(:x).includes(:token, :crystal).to_a.group_by(&:y)
  end

  def show
    case params[:id]
    when "round"
      # g = Grid.new()
      # 0.upto(10).to_a.repeated_permutation(2).map {|(x,y)| Cell.create(x: x,y: y).create_crystal(state: :dead) }
      g = Grid.new(Crystal.includes(:cell).to_a)
      # fail
      d = g.deltas
      g.step(d)
      # sleep 2
      # [[1,1],[2,1],[3,1]].each{|(x,y)| g[x,y].state = :live }
      ActionCable.server.broadcast "delta", {actions: d}
      head :ok
    when "add_col"
      y1,y2,x2 = Cell.minimum(:y), Cell.maximum(:y), Cell.maximum(:x)
      y1.upto(y2).each {|y|  Cell.create(x: x2+1, y: y).tap{|c| c.create_crystal(state: :dead) } }
      redirect_to root_path
    when 'add_row'
      y1,y2,x1, x2 = Cell.minimum(:y), Cell.maximum(:y), Cell.minimum(:x), Cell.maximum(:x)
      x1.upto(x2).each {|x|  Cell.create(x: x, y: y2+1).tap{|c| c.create_crystal(state: :dead) } }
      redirect_to root_path
    end
  end

  
  class Grid
    include Enumerable

    NEIGHBORS = [
      [-1,-1], [-1, 0], [-1, 1],
      [ 0,-1],          [ 0, 1],
      [ 1,-1], [ 1, 0], [ 1, 1],
    ]

    def initialize(crystals)
      @crystals = crystals.each_with_object({}) do |c,h|
        h[[c.cell.x,c.cell.y]] = c
      end
    end

    def [](x,y)
      @crystals[[x,y]] 
    end

    def count_neighbors(x,y)
      NEIGHBORS.count{|(dy, dx)| self[x+dx, y+dy]&.live }
    end

    def deltas
      inject([]) {|changes, crystal|
        cell = crystal.cell
        live_neighbors = count_neighbors(cell.x, cell.y)
        if crystal.live && (live_neighbors < 2 || live_neighbors > 3)
          changes + [{id: cell.id, crystal: :dead}]
        elsif (crystal.dead && live_neighbors == 3) || crystal.state == 'lit'
          changes + [{id: cell.id, crystal: :live}]
        else
          changes
        end
      } 
    end

    def step(deltas)
      deltas.each{|d|  
        Crystal.where(cell_id: d[:id]).update_all(state: d[:crystal])
      }
    end

    def each(&block)
      @crystals.values.each(&block)
    end

  end
end
