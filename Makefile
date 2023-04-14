
build:
	rm out.lua 
	python3 nspire-merger.py --out out.lua
	./luna out.lua nspacegame.tns

clean:
	$(RM) out.lua
	$(RM) nspacegame.tns

.PHONY: clean build

