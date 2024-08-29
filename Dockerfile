# Stage 1: Build the application
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /build

# Copy csproj and restore as distinct layers
COPY ["TumbleBackend/TumbleBackend/*.csproj", "TumbleBackend/TumbleBackend/"]
RUN dotnet restore "TumbleBackend/TumbleBackend/TumbleBackend.csproj"

# Copy everything else and build
COPY . .
WORKDIR "/build/TumbleBackend/TumbleBackend"
RUN dotnet build "TumbleBackend.csproj" -c Debug -o /app/build

# Publish the project
RUN dotnet publish "TumbleBackend.csproj" -c Debug -o /app/publish

# Stage 2: Prepare the runtime image
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS final
WORKDIR /app
COPY --from=build /app/publish .
COPY ["tumblebackend.pfx", "./https/"]

# Open port 443 for SSL/TLS
EXPOSE 80
EXPOSE 7036

ENTRYPOINT ["dotnet", "TumbleBackend.dll"]
