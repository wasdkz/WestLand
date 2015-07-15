/*    
	Copyright (C) 2015  Mansur "#WASD" Taukenov
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
#include <a_samp>
#if defined MAX_PLAYERS
	#undef MAX_PLAYERS
	#define MAX_PLAYERS 100
#endif

#if defined MAX_VEHICLES
	#undef MAX_VEHICLES
	#define MAX_VEHICLES 1000
#endif
#include <a_mysql>
#include <sscanf2>
#include <dc_cmd>
#include <foreach>
#include <streamer>
#include <yom_buttons>
#include <playerprogress>

#define CopyRightByWasd 	"(c) 2015 by #WASD (vk.com/teddyt)"

main() print(CopyRightByWasd);

// ^^^^^^^^^^^^^^^^^^^^^^^ [ defines ] ^^^^^^^^^^^^^^^^^^^^^^^
#include "../includes/wl_defines.pwn"
// ^^^^^^^^^^^^^^^^^^^^^^ [ variables ] ^^^^^^^^^^^^^^^^^^^^^^
#include "../includes/wl_variables.pwn"
// ^^^^^^^^^^^^^^^^^^^^^^ [ functions ] ^^^^^^^^^^^^^^^^^^^^^^
#include "../includes/wl_functions.pwn"
// ^^^^^^^^^^^^^^^^^^^^^^^ [ publics ] ^^^^^^^^^^^^^^^^^^^^^^^
#include "../includes/wl_objects.pwn"
#include "../includes/wl_publics.pwn"
// ^^^^^^^^^^^^^^^^^^^^^^^ [ stocks ] ^^^^^^^^^^^^^^^^^^^^^^^^
#include "../includes/wl_stocks.pwn"
// ^^^^^^^^^^^^^^^^^^^^^^ [ commands ] ^^^^^^^^^^^^^^^^^^^^^^^
#include "../includes/wl_commands.pwn"
// ^^^^^^^^^^^^^^^^^^^^^^^^ [ end ] ^^^^^^^^^^^^^^^^^^^^^^^^^^
