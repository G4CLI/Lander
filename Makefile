.PHONY: lander_game
lander-game:
	rm -rf lander-game
	g++ lander.cpp -lncursesw -std=c++11 -pthread -o lander-game
