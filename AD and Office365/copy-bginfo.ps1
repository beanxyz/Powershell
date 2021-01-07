$servers = get-content C:\Users\xgrose\Documents\serverlist.txt
foreach ($server in $servers) {
write-host "Now copying to server $server"
Copy-Item -Path C:\BGInfo -Destination \\$server\c$ -Force -Recurse
}