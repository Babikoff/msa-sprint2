using BookingHistoryService;
using BookingHistoryService.Contracts;
using BookingHistoryService.Repository;
using Microsoft.EntityFrameworkCore;
using Repository;

using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System.Diagnostics.CodeAnalysis;

var builder = Host.CreateApplicationBuilder(args);

builder.Services.AddDbContext<BookingHistoryDbContext>((sp, options) =>
{
    var configuration = sp.GetRequiredService<IConfiguration>();
    var connectionString = Environment.GetEnvironmentVariable("POSTGRES_CONNECTION_STRING")
        ?? builder.Configuration.GetConnectionString("PostgresConnection");
    options.UseNpgsql(connectionString);
});

// repo 
builder.Services.AddScoped<IBookingHistoryRepository, BookingHistoryRepository>();


builder.Services.AddHostedService<Worker>();

var host = builder.Build();

await using (var scope = host.Services.CreateAsyncScope())
{
    var db = scope.ServiceProvider.GetRequiredService<BookingHistoryDbContext>();
    var logger = host.Services.GetRequiredService<ILogger<Program>>();
    logger.LogTrace("Calling Database.EnsureCreated");
    await db.Database.EnsureCreatedAsync();
    logger.LogTrace("Calling Database.Migrate");
    await db.Database.MigrateAsync();
    logger.LogTrace("Finished Database.Migrate");
}

await host.RunAsync();
