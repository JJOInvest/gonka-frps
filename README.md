# Gonka FRP Server Docker Image

This Docker image provides an **FRP (Fast Reverse Proxy) server** that is intended to work with [gonka](https://github.com/gonka-ai) to protect connections from network nodes to MLNodes.

This image is built on top of [FRP](https://github.com/fatedier/frp), a fast reverse proxy that helps expose a local server behind a NAT or firewall to the internet.

## Overview

This FRP server acts as a secure gateway that allows MLNode instances (running on rental GPU services) to establish reverse tunnels, ensuring all traffic is routed through the network node proxy rather than exposing MLNode services directly to the internet.

## Problem Statement

When deploying MLNode instances on rental GPU services (Spheron.ai, Vast.ai, RunPod, Hyperstac, TensorDock, etc.), direct exposure of ports creates security vulnerabilities:

- **Direct Access**: MLNode becomes directly accessible from the internet, bypassing the network node proxy
- **Free Inference**: Users can make inference requests directly without going through the network node, resulting in revenue loss
- **DoS Vulnerability**: The exposed ports are vulnerable to Denial of Service attacks

## Solution

This FRP server works in conjunction with the [gonka-mlnode-protected](https://github.com/OpenDOps/gonka-mlnode-protected) image to establish secure reverse tunnels. The FRP server runs on the network node and accepts connections from MLNode instances (FRP clients), ensuring:

- ✅ All traffic is routed through the network node proxy
- ✅ No direct access to MLNode services from the internet
- ✅ Proper authentication and rate limiting through the network node
- ✅ Protection against direct DoS attacks

For more details on how the MLNode side works, see the [gonka-mlnode-public README](/Users/mac/Documents/development/MidHub/gonka/gonka-mlnode-public/README.md).

## Architecture

```txt
Internet → Network Node (FRP Server) → FRP Tunnel → MLNode Container (FRP Client) → MLNode Services
```

The FRP server accepts reverse tunnel connections from MLNode instances and exposes their services on dynamically assigned ports based on the client ID.

## Installation

To add the FRP server to your standard gonka docker-compose setup, add the following service block:

```yaml
  frps:
    container_name: frps
    image: ghcr.io/jjoinvest/gonka-frps:main
    restart: unless-stopped
    ports:
      - "7200:7200" #exposed externally
      - "127.0.0.1:7500:7500" #exposed internally
    environment:
      - SECRET_FRP_TOKEN=${SECRET_FRP_TOKEN}
      - FRP_DASHBOARD_PASSWORD=${FRP_DASHBOARD_PASSWORD}
    volumes:
      - ./frps/logs:/var/frp
```

## Configuration

### Environment Variables

#### Required Variables

- **`SECRET_FRP_TOKEN`**: Authentication token for FRP server connections. This must match the token used by MLNode clients.
- **`FRP_DASHBOARD_PASSWORD`**: Password for the FRP dashboard (accessible on port 7500)

### Ports

- **`7200`**: Main FRP server port (exposed externally) - accepts connections from MLNode clients
- **`7500`**: FRP dashboard port (exposed internally only) - web UI for monitoring FRP connections

### Volumes

- **`./frps/logs:/var/frp`**: Log directory for FRP server logs

## Usage

1. Set the required environment variables in your `config.env` file:

   ```bash
   export SECRET_FRP_TOKEN=your-secret-token-here
   export FRP_DASHBOARD_PASSWORD=your-dashboard-password-here
   ```

2. Add the FRP server service to your `docker-compose.yml` as shown in the Installation section above.

3. Start the services:

   ```bash
   docker-compose up -d
   ```

4. Access the FRP dashboard (if needed) at `http://localhost:7500` using the admin user and your dashboard password.

## How It Works

1. The FRP server starts and listens on port 7200 for incoming client connections
2. MLNode instances (running the gonka-mlnode-protected image) connect to this server using the shared `SECRET_FRP_TOKEN`
3. The FRP server establishes reverse tunnels, mapping remote ports (based on CLIENT_ID) to local MLNode services
4. All traffic to MLNode services must go through the network node, ensuring proper authentication and rate limiting

## Security Features

- **Token Authentication**: Only clients with the correct `SECRET_FRP_TOKEN` can connect
- **Network Isolation**: MLNode services are never directly exposed to the internet
- **Internal Dashboard**: Dashboard is only accessible on localhost (127.0.0.1:7500)

## Troubleshooting

### Check FRP Server Logs

```bash
docker logs frps
```

Or view log files directly:

```bash
cat ./frps/logs/frps.log
```

### Verify Server Status

Check if the FRP server is listening on the correct ports:

```bash
docker exec frps netstat -tlnp | grep -E '7200|7500'
```

### Access Dashboard

The FRP dashboard provides real-time information about connected clients and active tunnels:

- URL: `http://localhost:7500`
- Username: `admin`
- Password: Value of `FRP_DASHBOARD_PASSWORD` environment variable

## Related Projects

- [gonka](https://github.com/gonka-ai) - Main gonka project
- [FRP](https://github.com/fatedier/frp) - Fast Reverse Proxy project used as the underlying technology
- [gonka-mlnode-protected](https://github.com/OpenDOps/gonka-mlnode-protected) - MLNode image with integrated FRP client
- [gonka-mlnode-public README](/Users/mac/Documents/development/MidHub/gonka/gonka-mlnode-public/README.md) - Detailed documentation on the MLNode side

## License

This project is licensed under the MIT License.

## Support

For support, questions, or issues, please open a GitHub issue in this repository.
