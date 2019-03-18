using System.IO;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;

namespace Praxeum.WebApp
{
    public class Program
    {
        public static void Main(string[] args)
        {
            CreateWebHostBuilder(args).Build().Run();
        }

        public static IWebHostBuilder CreateWebHostBuilder(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                .UseApplicationInsights()
                .ConfigureAppConfiguration((hostingContext, config) =>
                {
                    if (hostingContext.HostingEnvironment.EnvironmentName == "Development")
                    {
                        config.SetBasePath(Directory.GetCurrentDirectory());
                        config.AddJsonFile("appsettings.local.json", optional: true, reloadOnChange: true);
                    }
                })
                .UseStartup<Startup>();
    }
}
