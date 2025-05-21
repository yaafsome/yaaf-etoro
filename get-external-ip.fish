#!/usr/bin/fish

# Get the external IP of the simple-web service
set SERVICE_NAME $argv[1]
if test -z "$SERVICE_NAME"
    set SERVICE_NAME "simple-web"
end

# Wait for external IP to be assigned
echo "Waiting for external IP to be assigned to the $SERVICE_NAME service..."
set counter 0
while true
    set IP (kubectl -n yaaf get service $SERVICE_NAME -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if test -n "$IP"
        break
    end
    
    set counter (math $counter + 1)
    if test $counter -gt 40
        echo "Timeout waiting for external IP. Check service status manually."
        exit 1
    end
    
    printf "."
    sleep 3
end

echo ""
echo "External IP for $SERVICE_NAME service: $IP"
echo "You can access the application at: http://$IP"
