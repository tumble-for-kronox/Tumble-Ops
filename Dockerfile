# Stage 1: Build the application
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /build

# Copy csproj and restore as distinct layers
COPY ["tumble-backend/TumbleBackend/*.csproj", "tumble-backend/TumbleBackend/"]
RUN dotnet restore "tumble-backend/TumbleBackend/TumbleBackend.csproj"

# Copy everything else and build
COPY . .
WORKDIR "/build/tumble-backend/TumbleBackend"
RUN dotnet build "TumbleBackend.csproj" -c Debug -o /app/build

# Publish the project
RUN dotnet publish "TumbleBackend.csproj" -c Debug -o /app/publish

# Stage 2: Prepare the runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS final
WORKDIR /app
COPY --from=build /app/publish .
COPY ["tumblebackend.pfx", "./https/"]

# Set environment variables for Kestrel
ENV ASPNETCORE_URLS="https://+:443;http://+:80"
ENV ASPNETCORE_Kestrel__Certificates__Default__Password="qwY2Betnju11z0U3ThFX"
ENV ASPNETCORE_Kestrel__Certificates__Default__Path="/app/https/tumblebackend.pfx"

# Open port 443 for SSL/TLS
EXPOSE 80
EXPOSE 7036

ENTRYPOINT ["dotnet", "TumbleBackend.dll"]
