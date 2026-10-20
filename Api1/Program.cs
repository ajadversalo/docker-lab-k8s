var builder = WebApplication.CreateBuilder(args);

builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
        policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod());
});

var app = builder.Build();
app.UseCors();

var instance = Environment.GetEnvironmentVariable("INSTANCE") ?? "api1";
var hostname = Environment.MachineName;

var items = new Item[]
{
    new(1, "Containers", "Package an app with its runtime so it runs the same on every machine."),
    new(2, "Images", "A snapshot of a filesystem plus a default command. Built from a Dockerfile."),
    new(3, "Compose", "Declare Web1, Api1, and nginx together and start them with one command."),
    new(4, "Networks", "Containers on the same Compose network reach each other by service name."),
    new(5, "Routing mesh", "Publish a port on the Swarm. Hit any Linux host; Docker picks a replica."),
};

app.MapGet("/health", () => Results.Ok(new { status = "ok", service = instance, hostname }));
app.MapGet("/api/items", () => new { instance, hostname, items });
app.MapGet("/api/items/{id:int}", (int id) =>
{
    var item = items.FirstOrDefault(i => i.Id == id);
    return item is null ? Results.NotFound() : Results.Ok(new { instance, hostname, item });
});

app.Run();

internal record Item(int Id, string Title, string Description);
