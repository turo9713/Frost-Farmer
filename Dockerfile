FROM mcr.microsoft.com/dotnet/sdk:8.0-bookworm-slim AS build
WORKDIR /src
COPY NuGet.Config FrostFarmer.sln ./
COPY src/FrostFarmer/FrostFarmer.csproj src/FrostFarmer/
RUN dotnet restore src/FrostFarmer/FrostFarmer.csproj --runtime linux-x64
COPY src/FrostFarmer src/FrostFarmer
RUN dotnet publish src/FrostFarmer/FrostFarmer.csproj -c Release -r linux-x64 --self-contained false --no-restore -o /out

FROM mcr.microsoft.com/dotnet/aspnet:8.0-bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build /out .
RUN mkdir -p /app/plugins && chown -R app:app /app
USER app
ENV ASPNETCORE_URLS=http://0.0.0.0:8080 ASPNETCORE_ENVIRONMENT=Production DOTNET_EnableDiagnostics=0
EXPOSE 8080
HEALTHCHECK --interval=15s --timeout=3s --start-period=20s --retries=3 CMD curl --fail --silent http://127.0.0.1:8080/health/ready || exit 1
ENTRYPOINT ["dotnet","FrostFarmer.dll"]
