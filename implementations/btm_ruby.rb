#!/usr/bin/env ruby
require 'rubygems'
require 'main'
require 'treetop'
require 'facets'
require 'fattr'
require 'highline'

Treetop.load_from_string(DATA.read)

class Game
  DIRECTIONS = %w(north south east west)

  class PlayerError < RuntimeError
  end

  class Room
    fattr :id
    fattr :game
    fattr(:name) { id.to_s }
    fattr :description => "<TBD>"
    alias_method :desc, :description
    fattr(:exits) { Hash.new }

    def initialize(game, id)
      self.id   = id
      self.game = game
      yield(self) if block_given?
    end

    def exit(args)
      direction, room_name = args.words
      exits[direction] = room_name
    end

    def exit_dirs
      # Using a set & puts the keys in the desired order
      Game::DIRECTIONS & exits.keys
    end

    def humanized_exits
      case exit_dirs.length
      when 0 then "No exits. You are trapped!"
      when 1 then "Exit to the #{exit_dirs}"
      else "Exits to the #{exit_dirs[0..-2].join(', ')} and #{exit_dirs.last}"
      end
    end

    def room_to(direction)
      room_name = exits.fetch(direction) do
        raise PlayerError, "There is no exit to the #{direction}"
      end
      game.room_named(room_name)
    end
  end

  class Player
    fattr :game
    fattr(:location) { game.starting_room }

    def initialize(game)
      self.game = game
    end

    def prompt
      hl.ask "> "
    end

    def tell(text)
      hl.say text
    end

    def tell_location
      tell(location.name)
    end

    def do_exit(*args)
      game.exit!
    end

    Game::DIRECTIONS.each do |dir|
      define_method("do_#{dir}") do |*args|
        self.location = location.room_to(dir)
        tell_location
      end
    end

    def do_look(*args)
      tell location.description
      tell location.humanized_exits
    end

    def method_missing(method, *args, &block)
      if method.to_s =~ /^do_(.*)$/
        raise PlayerError, "Unknown command: #{$1}"
      else
        super
      end
    end

    private

    fattr(:hl) { HighLine.new }

  end

  fattr :intro => ""
  fattr :rooms => {}
  fattr(:starting_room) { rooms.values.first }
  fattr(:player) { Player.new(self) }

  def start(args)
    self.starting_room = rooms[args.words.first]
  end

  def room(args, &block)
    name = args.words.first
    returning(Room.new(self,name,&block)) do |room|
      rooms[name] = room
    end
  end

  def room_named(name)
    rooms.fetch(name)
  end

  def play!
    self.player!
    player.tell(intro)
    player.tell_location
    until(exit_requested?) do
      begin
        command = player.prompt
        keyword, *args = command.words
        player.send("do_#{keyword}", *args)
      rescue PlayerError => error
        player.tell error.message
      end
    end
  end

  def exit!
    self.exit_requested = true
  end

  private

  fattr :exit_requested => false

end

Main do
  argument 'data_file'

  def run
    parser    = AdventureParser.new
    data      = IO.read(params[:data_file].value)
    tree      = parser.parse(data)
    game      = tree.new_game
    game.play!
  end
end

__END__
grammar Adventure
  rule statements
    statement_or_blank+ {
      def new_game
        returning(Game.new) do |game|
          elements.each do |element|
            element.apply(game)
          end
        end
      end
    }
  end

  rule statement_or_blank
    statement
    /
    blank_line {
      def apply(game)
        # NO-OP
      end
    }
  end

  rule statement
    block_statement /
    line_statement
  end

  rule block_statement
    declaration block {
      def keyword
        declaration.keyword.text_value
      end

      def args
        declaration.arguments.text_value
      end

      def apply(game)
        game.send(keyword, args) do |context|
          block.contents.elements.each do |element|
            element.apply(context)
          end
        end
      end
    }
  end

  rule blank_line
    (linespace*) newline
  end

  rule declaration
    linespace* keyword linespace* arguments:text
  end

  rule block
    block_open contents:statement* block_close
  end

  rule keyword
    [a-zA-Z_] [a-zA-Z0-9_]*
  end

  rule block_open
    space '{' space
  end

  rule block_close
    linespace* '}' space
  end

  rule line_statement
    declaration newline {
      def apply(game)
        keyword     = declaration.keyword.text_value
        args        = declaration.arguments.text_value
        game.send(keyword, args)
      end
    }
  end

  rule text
    (!delimiter .)*
  end

  rule delimiter
    bracket / newline
  end

  rule bracket
    [{}]
  end

  rule newline
    [\n]
  end

  rule linespace
    [ \t]
  end

  rule space
    [ \r\n\t]*
  end
end
