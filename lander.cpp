#include <ncurses.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <thread>
#include <stdio.h>
#include <stdlib.h>
#include <termios.h>
#include <fcntl.h>
#include <time.h>
#include <iostream>
#include <fstream>
#include <locale.h>
#include <math.h>

#include "config.h"

struct rock_t {
	int id;
	int velocity;
	int pos_X;
	int pos_Y;
	bool isActive;
	bool needsRock;
} rocks[1280];

struct boss_shoot{
	int id;
	int pos_X;
	int pos_Y;
	bool isActive;
} bossShoot[256];


int nDigits(int x) {
	x = abs(x);
	if (x > 0) {
		return x < 1000000000 ? (int)log10(x) + 1 : 10;
	} else {
		return 1;
	}
}


void destroyRock(int id) {
	rocks[id].pos_Y = 0;
	rocks[id].pos_X = -1;
	srand((time(0) * id) + time(0));
	int m_rand = rand()%10;
	//20% chance
	if(m_rand == 0 || m_rand == 1) {
		rocks[id].velocity = 2;
	}else{
		rocks[id].velocity = 1;
	}
}

void createRock(int id) {
	rock_t* r = &rocks[id];
	r->id = id;
	r->velocity = 1;
	r->pos_X = -1;
	r->pos_Y = 0;
	r->isActive = false;
	r->needsRock = false;
}

int kbhit(void){
	int ch = getch();

	if (ch != ERR) {
		ungetch(ch);
		return 1;
	} else {
		return 0;
	}
}


void sleep_ms(int milliseconds){
#ifdef WIN32
	Sleep(milliseconds);
#elif _POSIX_C_SOURCE >= 199309L
	struct timespec ts;
	ts.tv_sec = milliseconds / 1000;
	ts.tv_nsec = (milliseconds % 1000) * 1000000;
	nanosleep(&ts, NULL);
#else
	usleep(milliseconds * 1000);
#endif
}


int main() {
	setlocale(LC_ALL,"");
	auto start_time = std::chrono::high_resolution_clock::now();
	initscr();
	curs_set(0);
	int ship_X = 15;
	int loops = 0;
	int chKBHIT;
	srand(time(0));
	struct winsize w;
	ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);   // GET THE TERMINAL SIZE
	clear();
	int wtf = 0;
	int oldwtf = 0;
	bool shoot = 0;
	int shoot_X = -10;
	int shoot_Y = -10;
	int score = 0;
	int cooldownShot = 0;
	int pu_laser_X;
	int pu_laser_Y;
	int laserCD = 0;
	int restartLaser = 0;
	int lsmv_counter = 0;
	int bossStart = -5;
	int bossMov = 0;
	int bossMovX = 0;
	int bossShootID = 0;
	int bossShootCD = 10;
	int bossHP = 30;
	bool laserEnabled = false;
	bool laserOnScreen = false;
	bool fistStepBoss = true;
	bool bossAlive = true;

	for(int i = 0; i < w.ws_col; i++) {
		createRock(i);
		srand((time(0) * i) + time(0));
		rocks[i].pos_X = rand()%(w.ws_col - 7)+4;
		rocks[i].isActive = false;
	}
	rocks[0].isActive = true;
	nodelay(stdscr, TRUE);
	ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
	if (colorsEnabled == true){
		start_color();
	}
	while(true) {
		char key;
		struct winsize w;

		ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);   // GET THE TERMINAL SIZE
		clear();

		while( true ){
			auto current_time = std::chrono::high_resolution_clock::now();
			auto second_time = std::chrono::duration_cast<std::chrono::seconds>(current_time - start_time).count();
			ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
			clear();

			if (second_time > 66 && bossAlive == true && bossHP > 0){			// TOP TO MID BOSS, i know, pretty stupid code, shut up
				for (int i = 0; i < bossHP; ++i){
					mvprintw(1,15+i,"\u2580");
				}
				if (bossStart<3){
					mvprintw(bossStart, w.ws_col/2-4, "_________");
					mvprintw(bossStart+1, w.ws_col/2-4, "\\ o-X-o /");
					mvprintw(bossStart+2, w.ws_col/2-4, " \\|_ _|/");
					mvprintw(bossStart+3, w.ws_col/2-4, "  | V |");
					bossMov++;
					if (bossMov == 5){
						bossStart++;
						bossMov = 0;
					}
				} else if ((w.ws_col/2-4-bossMovX) > 4 && fistStepBoss){		// WHATEVER TO LEFT BOSS
					mvprintw(bossStart, w.ws_col/2-4-bossMovX, "_________");
					mvprintw(bossStart+1, w.ws_col/2-4-bossMovX, "\\ o-X-o /");
					mvprintw(bossStart+2, w.ws_col/2-4-bossMovX, " \\|_ _|/");
					mvprintw(bossStart+3, w.ws_col/2-4-bossMovX, "  | V |");
					bossMov++;

					if (bossMov == 5){

						bossMovX++;
						bossMov = 0;
						bossShootCD--;

						if (bossShootCD <= 3){
							for (int i = 1; i <= 2; ++i){
								for (int n = 0; n <= 256; ++n){
									boss_shoot* r = &bossShoot[n];
									if (!r->isActive){
										r->isActive = true;
										r->pos_Y = 6;
										if (i == 1){
											r->pos_X = w.ws_col/2-4-bossMovX+2;
										} else {
											r->pos_X = w.ws_col/2-4-bossMovX+6;
										}
										break;
									}
								}
								if (bossShootCD <= 0){
									bossShootCD = 10;
								}
							}
						}
						bossShootID = bossShootID+2; // idk why this is here tbh
					}

				} else if ((w.ws_col/2-4-bossMovX) < w.ws_col-12){			// TO RIGHT BOSS
					fistStepBoss = false;
					mvprintw(bossStart, w.ws_col/2-4-bossMovX, "_________");
					mvprintw(bossStart+1, w.ws_col/2-4-bossMovX, "\\ o-X-o /");
					mvprintw(bossStart+2, w.ws_col/2-4-bossMovX, " \\|_ _|/");
					mvprintw(bossStart+3, w.ws_col/2-4-bossMovX, "  | V |");
					bossMov++;

					if (bossMov == 5){

						bossMovX--;
						bossMov = 0;
						bossShootCD--;

						if (bossShootCD <= 3){
							for (int i = 1; i <= 2; ++i){
								for (int n = 0; n <= 256; ++n){
									boss_shoot* r = &bossShoot[n];
									if (!r->isActive){
										r->isActive = true;
										r->pos_Y = 6;
										if (i == 1){
											r->pos_X = w.ws_col/2-4-bossMovX+2;
										} else {
											r->pos_X = w.ws_col/2-4-bossMovX+6;
										}
										break;
									}
								}
								if (bossShootCD <= 0){
									bossShootCD = 10;
								}
							}
						}
					}
				} else {
					fistStepBoss = true;
				}
				
			}


			for (int i = 0; i <= 256; ++i){					// BOSS SHOOTS MOVEMENT + HITBOXES + STDOUT
				boss_shoot* r = &bossShoot[i];
				if (r->isActive){
					r->pos_Y++;
					if (r->pos_Y > w.ws_row){
						r->isActive = false;
						r->pos_Y = -10;
						r->pos_X = -10;
					}
					mvprintw(r->pos_Y,r->pos_X,"!");
				}
				if (r->isActive &&
					(r->pos_Y == shoot_Y || r->pos_Y == shoot_Y + 1 || r->pos_Y == shoot_Y - 1) &&
					(r->pos_X == shoot_X || r->pos_X == shoot_X + 1 || r->pos_X == shoot_X + 2)) {
					r->isActive = false;
					bossHP--;
					if (bossHP == 0){
						score = score + 25000;
						// BOSS DEAD ANIMATION HERE
					}
					shoot = false;
					shoot_X = -10;
					shoot_Y = -10;
				}
				
				if ((ship_X == r->pos_X || ship_X + 1 == r->pos_X || ship_X + 2 == r->pos_X)
					&& (r->pos_Y > (w.ws_row - 3))) {
					goto GOVER;
				}
			}

			if ((bossStart == shoot_Y || bossStart+1 == shoot_Y || bossStart+2 == shoot_Y) &&
				(w.ws_col/2-4-bossMovX == shoot_X || w.ws_col/2-4-bossMovX+1 == shoot_X ||
				w.ws_col/2-4-bossMovX+2 == shoot_X || w.ws_col/2-4-bossMovX+3 == shoot_X ||
				w.ws_col/2-4-bossMovX+4 == shoot_X || w.ws_col/2-4-bossMovX+5 == shoot_X ||
				w.ws_col/2-4-bossMovX+6 == shoot_X || w.ws_col/2-4-bossMovX+7 == shoot_X ||
				w.ws_col/2-4-bossMovX+8 == shoot_X)) {
				bossHP=bossHP-5;
				if (bossHP == 0){
					score = score + 25000;
					// BOSS DEAD ANIMATION HERE
				}
				shoot = false;
				shoot_X = -10;
				shoot_Y = -10;
			}

			if ( second_time > 25 && laserCD <= 0 ){    //LASER (POWERUP) CREATION
				pu_laser_X=4+rand()%((w.ws_col-7)-4);
				pu_laser_Y=0;
				mvprintw(pu_laser_Y,pu_laser_X,"Y");
				laserOnScreen = true;
				laserCD=300;
			}
			if ( laserOnScreen ){               //LASER (POWERUP) MOVEMENT
				lsmv_counter++;
				if (lsmv_counter == 2){
					lsmv_counter = 0;
					++pu_laser_Y;
				}
				mvprintw(pu_laser_Y,pu_laser_X,"Y");
				if (pu_laser_Y==w.ws_row-3 && ( pu_laser_X == ship_X || pu_laser_X == ship_X+1 || pu_laser_X == ship_X+2 )){
					laserOnScreen = false;
					laserEnabled = true;
					restartLaser=200;
				} else if (pu_laser_Y > w.ws_row){
					laserOnScreen = false;
					laserEnabled = false;
				} 
			}
			--laserCD;
			if (restartLaser == 0){
				laserEnabled = false;
			} else {
				--restartLaser;
			}

			for(int i = 0; i < w.ws_col; i++) {
				rock_t* r = &rocks[i];
				if (r->pos_Y > w.ws_row) {
					wtf += r->velocity;
					destroyRock(i);
					r->needsRock = 1;
				}
				if (r->isActive &&
					(r->pos_Y == shoot_Y || r->pos_Y == shoot_Y + 1 || r->pos_Y == shoot_Y - 1) &&
					(r->pos_X == shoot_X || r->pos_X == shoot_X + 1 || r->pos_X == shoot_X + 2)) {
					wtf += 2 * r->velocity;
					destroyRock(i);
					rocks[i].needsRock = 1;
					shoot = false;
					shoot_X = -10;
					shoot_Y = -10;
				}
				if (r->needsRock == 1) {
					r->pos_X = rand() % (w.ws_col - 7) + 4;
					srand((time(0) * i) + time(0));
					r->needsRock = 0;
				}
				if ((ship_X == r->pos_X || ship_X + 1 == r->pos_X || ship_X + 2 == r->pos_X)
					&& (r->pos_Y > (w.ws_row - 3))) {
					goto GOVER;
				}
			}

			if (kbhit()){
				key = getch();
				break;
			}

			if ( cooldownShot > 0 ) {
				--cooldownShot;
			}

			for (int i = 0; i < w.ws_row; ++i){     // BORDERS
				mvprintw(i,3, "\u2503");
				mvprintw(i,w.ws_col - 3, "\u2503");
			}
			if (debugGraph){
				int linesD=w.ws_row;
				int columnsD=w.ws_col;
				mvprintw(2,4,"lines %d\n", linesD);
				mvprintw(3,4,"columns %d\n", columnsD);
				mvprintw(4,4,"Cursor at x:%i", ship_X);
				mvprintw(6,4,"Loops %i", loops);
				if (kbhit()){
					mvprintw(7,4,"kbhit is at 1");
				} else{
					mvprintw(7,4,"kbhit is at 0");
				}
				mvprintw(9,4,"wtf:%i", wtf);
				mvprintw(10,4,"kbhit ch:%i", chKBHIT);
				mvprintw(11,4,"show at %i", shoot_Y);
				mvprintw(12,4,"oldwtf:%i", oldwtf);
				mvprintw(13, 4, "Colours:%i", has_colors());
				mvprintw(14,4,"cooldownShot: %i", cooldownShot);
			}
			mvprintw(0, 4, "Score:%i", score);
			mvprintw(1, 4, "Time:%i", second_time);
			mvprintw(0,w.ws_col - 3,"\u2503");
			mvprintw(1,w.ws_col - 3,"\u2503");
			mvprintw(2,w.ws_col - 3,"\u2503");
			mvprintw(3,w.ws_col - 3,"\u2503");
			if (laserEnabled){                      // THE ACTUAL LASER
				for (int i = 0; i < w.ws_row-4; ++i){
					init_pair(1, COLOR_BLUE, COLOR_BLACK);
					attron(COLOR_PAIR(1));
					mvprintw(i,ship_X+1,"\u2502");
					attroff(COLOR_PAIR(1));
				}
			}
			if (shoot){
				mvprintw(shoot_Y,shoot_X+1,"*");
				--shoot_Y;
				if ( shoot_Y == 0 ){
					shoot = false;
					shoot_Y = -10;
				}
			}
			refresh();
			mvprintw(w.ws_row - 3,ship_X,"/A\\");
			for(int i = 0; i < w.ws_col; i++) {
				rock_t* r = &rocks[i];
				if(r->isActive) {
					if(r->velocity == 2 && second_time >= 30) {
						init_pair(1, COLOR_RED, COLOR_BLACK);
						attron(COLOR_PAIR(1));
						mvprintw(r->pos_Y, r->pos_X,"X");
						attroff(COLOR_PAIR(1));
					}else{
						mvprintw(r->pos_Y, r->pos_X,"X");
						r->velocity = 1;
					}
					r->pos_Y += r->velocity;
				}
			}

			if (kbhit()){
				key = getch();
				break;
			}
			for(int i = 0; i <= second_time / 10; i++) {
				rocks[i].isActive = true;
			}
			score += (wtf - oldwtf) * (second_time * 0.75);
			oldwtf = wtf;
			sleep_ms(50);

			if (kbhit()){
				key = getch();
				break;
			}

			++loops;

			if (kbhit()){
				key = getch();
				break;
			}
			refresh();
		}
		if ( key == KEY_MOVE_LEFT ){
			if ( ship_X == 4 ){
				continue;
			} else{
				ship_X = ship_X - 1;
				mvprintw(w.ws_row - 3,ship_X,"/A\\");
			}
			++loops;
		} else if ( key == KEY_MOVE_RIGHT ){
			if ( ship_X == w.ws_col - 6 ){
				++loops;
				continue;
			} else{
				ship_X = ship_X + 1;
				mvprintw(w.ws_row - 3,ship_X,"/A\\");
				++loops;
			}
		} else if ( key == KEY_SHOOT  && !shoot && cooldownShot == 0) {
			cooldownShot = 20;
			shoot = true;
			shoot_X = ship_X;
			shoot_Y = w.ws_row - 4;
			++loops;
		} else {
			continue;
			++loops;
		}
		refresh();
	}
	GOVER:ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);   // GET THE TERMINAL SIZE

	std::ifstream highscore;
	highscore.open("highscore");
	int hs;
	highscore >> hs;
	highscore.close();
	if (score>hs){
		std::ofstream newHS;
		newHS.open("highscore");
		newHS << score;
		newHS.close();
		hs=score;
		newHS.close();
	}

	refresh();
	clear();
	mvprintw(w.ws_row/2-3,w.ws_col/2-5,"GAME OVER");
	int scoredigits=nDigits(score);
	int hscoredigits=nDigits(hs);
	mvprintw(w.ws_row / 2, w.ws_col / 2 - 3, "Score");
	mvprintw(w.ws_row / 2 + 1, w.ws_col / 2 - scoredigits / 2, "%i", score);
	mvprintw(w.ws_row / 2 + 3, w.ws_col / 2 - 5, "Highscore");
	mvprintw(w.ws_row / 2 + 4, w.ws_col / 2 - hscoredigits / 2, "%i", hs);
	refresh();
	sleep_ms(6000);
	endwin();
	return 0;
}
