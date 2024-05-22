using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;

namespace BrewUpApi.Modules.Sales.Endpoints;

public static class SalesEndpoints
{
	public static IEndpointRouteBuilder MapSalesEndpoints(this IEndpointRouteBuilder endpoints)
	{
		var group = endpoints.MapGroup("/v1/sales/")
			.WithTags("Sales");

		group.MapPost("/", HandleCreateOrder)
			.Produces(StatusCodes.Status400BadRequest)
			.Produces(StatusCodes.Status201Created)
			.WithName("CreateSalesOrder");

		return endpoints;
	}

	private static async Task<IResult> HandleCreateOrder()
	{
		var salesOrderId = Guid.NewGuid().ToString();

		return string.IsNullOrWhiteSpace(salesOrderId)
			? Results.Ok("No Beers Available")
			: Results.Created(new Uri($"/v1/sales/{salesOrderId}", UriKind.Relative), salesOrderId);
	}
}