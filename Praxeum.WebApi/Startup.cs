﻿using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using AutoMapper;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpsPolicy;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Praxeum.WebApi.Features.LeaderBoards;
using Praxeum.WebApi.Features.Learners;
using Praxeum.WebApi.Helpers;
using Swashbuckle.AspNetCore.Swagger;

namespace Praxeum.WebApi
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services
                .AddMvc()
                .SetCompatibilityVersion(CompatibilityVersion.Version_2_1);

            services.AddAuthentication(options =>
            {
                options.DefaultScheme = JwtBearerDefaults.AuthenticationScheme;
                options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
            })
            .AddJwtBearer(options =>
            {
                options.Authority = Configuration["AzureAdB2COptions:Authority"];
                options.Audience = Configuration["AzureAdB2COptions:Audience"];

                options.IncludeErrorDetails = true;

                options.Events = new JwtBearerEvents
                {
                    OnTokenValidated = context =>
                    {
                        // Grab the raw value of the token, and store it as a claim so we can retrieve it again later in the request pipeline
                        // Have a look at the ValuesController.UserInformation() method to see how to retrieve it and use it to retrieve the
                        // user's information from the /userinfo endpoint
                        if (context.SecurityToken is JwtSecurityToken token)
                        {
                            if (context.Principal.Identity is ClaimsIdentity identity)
                            {
                                identity.AddClaim(new Claim("access_token", token.RawData));
                            }
                        }

                        return Task.FromResult(0);
                    },
                    OnAuthenticationFailed = AuthenticationFailed
                };
            });

            services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new Info { Title = "Praxeum API", Version = "v1" });

                c.EnableAnnotations();

                c.SchemaFilter<SwaggerExcludeSchemaFilter>();
                c.DocumentFilter<SwaggerTagDescriptionsDocumentFilter>(); // Enforces sort order and includes descriptions

                c.IgnoreObsoleteActions();

                var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
                var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);

                c.IncludeXmlComments(xmlPath);
            });

            services.Configure<AzureCosmosDbOptions>(
                Configuration.GetSection(nameof(AzureCosmosDbOptions)));

            services.Configure<LearnerOptions>(
                Configuration.GetSection(nameof(LearnerOptions)));

            services.Configure<MicrosoftProfileOptions>(
                Configuration.GetSection(nameof(MicrosoftProfileOptions)));

            services.AddTransient<IMicrosoftProfileRepository, MicrosoftProfileRepository>();

            // Leader Boards
            services.AddTransient<ILeaderBoardHandler<LeaderBoardAdd, LeaderBoardAdded>, LeaderBoardAddHandler>();
            services.AddTransient<ILeaderBoardHandler<LeaderBoardFetchById, LeaderBoardFetchedById>, LeaderBoardFetchByIdHandler>();
            services.AddTransient<ILeaderBoardHandler<LeaderBoardFetchList, IEnumerable<LeaderBoardFetchedList>>, LeaderBoardFetchListHandler>();
            services.AddTransient<ILeaderBoardHandler<LeaderBoardDeleteById, LeaderBoardDeletedById>, LeaderBoardDeleteByIdHandler>();
            services.AddTransient<ILeaderBoardHandler<LeaderBoardUpdateById, LeaderBoardUpdatedById>, LeaderBoardUpdateByIdHandler>();
    
            services.AddTransient<ILeaderBoardRepository, LeaderBoardRepository>();

            // Learners
            services.AddTransient<ILearnerHandler<LearnerAdd, LearnerAdded>, LearnerAddHandler>();
            services.AddTransient<ILearnerHandler<LearnerFetchById, LearnerFetchedById>, LearnerFetchByIdHandler>();
            services.AddTransient<ILearnerHandler<LearnerFetchList, IEnumerable<LearnerFetchedList>>, LearnerFetchListHandler>();
            services.AddTransient<ILearnerHandler<LearnerDeleteById, LearnerDeletedById>, LearnerDeleteByIdHandler>();
            services.AddTransient<ILearnerHandler<LearnerUpdateById, LearnerUpdatedById>, LearnerUpdateByIdHandler>();
    
            services.AddTransient<ILearnerRepository, LearnerRepository>();

            Mapper.Initialize(
                cfg =>
                {
                    cfg.ShouldMapProperty = p => p.GetMethod.IsPublic || p.GetMethod.IsAssembly;


                    cfg.AddProfile<LeaderBoardProfile>();
                    cfg.AddProfile<LearnerProfile>();
              });

            Mapper.AssertConfigurationIsValid();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
                app.UseHsts();
            }

            app.UseStaticFiles();

            app.UseSwagger();

            app.UseSwaggerUI(c =>
            {
                c.DocumentTitle = "Praxeum Api Explorer";

                c.SwaggerEndpoint("/swagger/v1/swagger.json", "Praxeum V1");

                c.InjectStylesheet("/swagger-ui/custom.css");

                c.EnableFilter();
            });

            app.UseHttpsRedirection();
            app.UseAuthentication();
            app.UseMvc();
        }

        private Task AuthenticationFailed(AuthenticationFailedContext arg)
        {
            // For debugging purposes only!
            var s = $"AuthenticationFailed: {arg.Exception.Message}";

            arg.Response.ContentLength = s.Length;
            arg.Response.Body.Write(Encoding.UTF8.GetBytes(s), 0, s.Length);

            return Task.FromResult(0);
        }
    }
}