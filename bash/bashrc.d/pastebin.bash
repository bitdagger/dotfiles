# Pastebin!
pb () { curl -F "c=@${1:--}" "https://ptpb.pw/"; }
export -f pb
