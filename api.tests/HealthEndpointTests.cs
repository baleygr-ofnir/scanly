using System.Net;
using Microsoft.AspNetCore.Mvc.Testing;

namespace api.tests;

/// <summary>
/// Smoke tests for the GET /health endpoint.
/// </summary>
public class HealthEndpointTests(WebApplicationFactory<Program> factory)
    : IClassFixture<WebApplicationFactory<Program>>
{
    [Fact]
    public async Task Health_ReturnsOk()
    {
        var client = factory.CreateClient();
        var response = await client.GetAsync("/health");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Health_ResponseContainsStatusAndMode()
    {
        var client = factory.CreateClient();
        var response = await client.GetAsync("/health");

        response.EnsureSuccessStatusCode();
        var json = await response.Content.ReadAsStringAsync();

        Assert.Contains("\"status\"", json);
        Assert.Contains("\"mode\"", json);
    }
}
