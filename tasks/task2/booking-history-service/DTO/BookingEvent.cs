using System.ComponentModel.DataAnnotations;

namespace BookingHistoryService.DTO;

public record BookingEvent
{
    [Key]
    public long? Id { get; set; } = null!;
    public string UserId { get; set; } = null!;
    public string HotelId { get; set; } = null!;
    public string PromoCode { get; set; } = null!;
    public double? DiscountPercent { get; set; } = null!;
    public double? Price { get; set; } = null!;
    public DateTimeOffset? CreatedAt { get; set; } = null!;
}
