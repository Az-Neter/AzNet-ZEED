#!/bin/bash
pf(){ for f in *; do if [[ "$f" == *.zeed ]]; then hc=$(xxd -p "$f"|tr -d '\n');bc="ibase=16;obase=2;$hc";hex2bin=$(echo $bc|bc|tr -d '\n');echo "$hex2bin">>"$f";rm "$f";else pf "$f";fi;done;}
pz(){ hc=$(xxd -p "$1"|tr -d '\n');bc="ibase=16;obase=2;$hc";hex2bin=$(echo $bc|bc|tr -d '\n');echo "$hex2bin">>"$f";rm "$1";}
us(){ hc=$(cat "$f"|tr -d '\n');bc="ibase=2;obase=16;$hc";bin2hex=$(echo $bc|bc|tr -d '\n');echo "$bin2hex">"$f";}
ds(){ hc=$(cat "$f"|tr -d '\n');modified_hex="$hc";echo "$modified_hex">"$f";}
if [[ $# -eq 1 && "$1" == *.zeed ]];then pet="$1";else echo "Provide a valid file."&&exit 1;fi;[[ ! -f "$pet" ]]&&touch "$pet";while true;do pf;us;us;hc=$(cat "$f"|tr -d '\n');modified_hex="$hc";echo "$modified_hex">"$f";us;us;sleep 10;done
