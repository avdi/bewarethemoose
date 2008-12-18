IMPL        ?= ruby
PLAYER      =  player1
GAME        =  mazesofmayhem
SERVER_PORT =  4321
SERVER_HOST =  localhost

tmp/%.pid: tmp
	$(MAKE) start_$(notdir $(basename $@))

tmp:
	mkdir tmp

start_ruby: tmp
	ruby ruby_server.rb $(GAME).dat -p $(SERVER_PORT) &
	echo $! > tmp/ruby.pid

stop_ruby:
	test -f tmp/ruby.pid && kill `cat tmp/ruby.pid`
	rm tmp/ruby.pid
