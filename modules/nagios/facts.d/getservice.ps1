#write-output "services=$(get-service | select name,DisplayName,ServiceName,Status,StartType -first 4 | ConvertTo-Json -Depth 4)"

foreach ($Service in (get-service )){

    #write-output ("{0}={1}" -f $Service.ServiceName,($Service | select name,DisplayName,ServiceName,Status,StartType | ConvertTo-Json -Depth 4 -compress))
    write-output ("{0}={0}" -f $Service.ServiceName)

}