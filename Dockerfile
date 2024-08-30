# Stage 1: Build the application
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /build

ENV DOTNET_NUGET_SIGNATURE_VERIFICATION=false
# Copy csproj and restore as distinct layers
COPY ["TumbleBackend/TumbleBackend/*.csproj", "TumbleBackend/TumbleBackend/"]
RUN dotnet restore "TumbleBackend/TumbleBackend/TumbleBackend.csproj"

# Copy everything else and build
COPY . .
WORKDIR "/build/TumbleBackend/TumbleBackend"
RUN dotnet build "TumbleBackend.csproj" -c Release -o /app/build

# Publish the project
RUN dotnet publish "TumbleBackend.csproj" -c Release -o /app/publish

# Stage 2: Prepare the runtime image
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS final
ENV DOTNET_NUGET_SIGNATURE_VERIFICATION=false

WORKDIR /app
COPY --from=build /app/publish .

# Open port 443 for SSL/TLS
EXPOSE 80
EXPOSE 7036

ENTRYPOINT ["dotnet", "TumbleBackend.dll"]
