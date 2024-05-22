using BrewUpApi.Modules.Sales;
using BrewUpApi.Modules.Sales.Endpoints;

namespace BrewUpApi.Modules;

public class SalesModule : IModule
{
	public bool IsEnabled => true;
	public int Order => 0;
	public IServiceCollection RegisterModule(WebApplicationBuilder builder) => builder.Services.AddSalesModule();

	public IEndpointRouteBuilder MapEndpoints(IEndpointRouteBuilder endpoints) => endpoints.MapSalesEndpoints();
}