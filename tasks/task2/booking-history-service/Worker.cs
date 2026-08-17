using BookingHistoryService.Contracts;
using BookingHistoryService.DTO;
using BookingHistoryService.Model;
using Confluent.Kafka;
using System.Text.Json;

namespace BookingHistoryService
{
    public class Worker : BackgroundService
    {
        private readonly ILogger<Worker> _logger;
        private readonly IConsumer<string, string> _consumer;
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly string _topic;

        public Worker(
            ILogger<Worker> logger,
            IConsumer<string, string> consumer,
            IServiceScopeFactory scopeFactory,
            IConfiguration configuration)
        {
            _logger = logger;
            _consumer = consumer;
            _scopeFactory = scopeFactory;
            _topic = Environment.GetEnvironmentVariable("KAFKA_BOOKING_EVENTS_TOPIC")
                ?? configuration["Kafka:Topic"]
                ?? "booking.created";
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _consumer.Subscribe(_topic);
            _logger.LogInformation("Subscribed to Kafka topic '{Topic}'", _topic);

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    var result = _consumer.Consume(stoppingToken);
                    if (result == null || result.IsPartitionEOF)
                    {
                        continue;
                    }

                    _logger.LogInformation(
                        "Received message: topic={Topic}, partition={Partition}, offset={Offset}, key={Key}",
                        result.Topic, result.Partition.Value, result.Offset.Value, result.Message.Key);

                    await ProcessMessageAsync(result.Message.Value, stoppingToken);

                    _consumer.Commit(result);
                    _logger.LogInformation(
                        "Committed offset {Offset} for topic {Topic}, partition {Partition}",
                        result.Offset.Value, result.Topic, result.Partition.Value);
                }
                catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
                {
                    _logger.LogInformation("Kafka consumer stopping due to cancellation.");
                    break;
                }
                catch (ConsumeException ex)
                {
                    _logger.LogError(ex, "Kafka consume error: {ErrorReason}", ex.Error.Reason);
                    await Task.Delay(1000, stoppingToken);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error processing Kafka message");
                    await Task.Delay(1000, stoppingToken);
                }

                await Task.Delay(500, stoppingToken); // Пауза в бесконечном цикле. Скорость переноса данных не важна
            }

            _consumer.Close();
        }

        private async Task ProcessMessageAsync(string messageValue, CancellationToken stoppingToken)
        {
            BookingEvent? bookingEvent;
            try
            {
                bookingEvent = JsonSerializer.Deserialize<BookingEvent>(messageValue);
            }
            catch (JsonException ex)
            {
                _logger.LogError(ex, "Failed to deserialize BookingEvent from message: {Message}", messageValue);
                return;
            }

            if (bookingEvent == null || bookingEvent.Id == null)
            {
                _logger.LogWarning("Received message with null BookingEvent or null Id, skipping. Message: {Message}", messageValue);
                return;
            }

            var booking = new Booking
            {
                Id = bookingEvent.Id.Value,
                UserId = bookingEvent.UserId,
                HotelId = bookingEvent.HotelId,
                PromoCode = bookingEvent.PromoCode,
                DiscountPercent = bookingEvent.DiscountPercent ?? 0.0,
                Price = bookingEvent.Price,
                CreatedAt = bookingEvent.CreatedAt ?? DateTimeOffset.UtcNow
            };

            using var scope = _scopeFactory.CreateScope();
            var repository = scope.ServiceProvider.GetRequiredService<IBookingHistoryRepository>();
            await repository.AddOrUpdateAsync(booking);
            _logger.LogInformation("Booking {BookingId} saved to history", booking.Id);
        }
    }
}