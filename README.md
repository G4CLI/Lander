# Lander
CLI Top-Down Space Shooter

![Main gif](http://i.imgur.com/70jvdo3.gif)

Lander is a top-down shooter made in C++

## CONTRIBUTORS
Main Contributors:

* [MrWhiteGoat](https://github.com/MrWhiteGoat)
* [Capuno](https://github.com/Capuno)

Another cool version using a BeagleBone Black as a controller (god bless GPL v3):

[Source](https://github.com/GustavoAC/Lander)

* [GustavoAC](https://github.com/GustavoAC)
* [thiagocesarm](https://github.com/thiagocesarm)


## DEPENDENCIES
> `libncurses5-dev`, `g++`, `libncursesw5-dev`

Distro | Command
------------: | :-------------
Debian & based | `sudo apt install g++ libncurses5-dev libncursesw5-dev`
Arch & based | `sudo pacman -S gcc`


## INSTALLATION

### Plan A: Automatic

The script is still under development, currently working on Debian and Ubuntu, should work on Mint with a little modification on line 21, didn't have time to fix it myself, send PR pls im too lazy.

```bash
$ curl https://raw.githubusercontent.com/Capuno/Lander/master/autoInstall.sh | bash
```

[Maybe its better to download the script somewhere and then execute it:](https://www.seancassidy.me/dont-pipe-to-your-shell.html)

```bash
$ wget https://raw.githubusercontent.com/Capuno/Lander/master/autoInstall.sh
$ md5sum autoInstall.sh
$ chmod +x autoInstall.sh
$ ./autoInstall.sh #Will install Lander in ${pwd}/lander
```

MD5 of the script = 01507fb4e4d3d65ed6c3ab4b2c1ca063 (checked in commit 620ca68c91039d1d4979a6f699b685ec9a1ad075)

### Plan B: Manual

After installing the [Dependencies](https://github.com/Capuno/Lander#dependencies)

```bash
$ git clone https://github.com/Capuno/Lander.git
$ cd Lander
$ make
$ ./lander_game
```

### Plan C: Binary only

```bash
$ wget https://github.com/Capuno/Lander/releases/download/v1.0.0/lander_game
$ chmod +x lander_game
$ ./lander_game
```

## CONTROLS

 * `z` moves left
 * `x` shoots
 * `c` moves right

This can be configured in `config.h` before compiling.



&emsp;

### KNOWN ISSUES
* *Laser changing color to red*
* *Console causes visual glitch*
