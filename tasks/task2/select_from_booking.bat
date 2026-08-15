echo "Select bookings from monolith"
docker exec -it hotelio-db psql -U hotelio -d hotelio -c "SELECT * FROM booking;"

echo "Select bookings from booking-service"
docker exec -it booking-service-db psql -U booking-service -d booking-service -c "SELECT * FROM booking;"