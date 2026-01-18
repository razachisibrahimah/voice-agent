# Node Voice Agent Starter

Start building interactive voice experiences with Deepgram's Voice Agent API using this Node.js starter application. This project demonstrates how to create a voice agent that can engage in natural conversations using Deepgram's advanced AI capabilities.

## What is Deepgram?

[Deepgram's](https://deepgram.com/) voice AI platform provides APIs for speech-to-text, text-to-speech, and full speech-to-speech voice agents. Over 200,000+ developers use Deepgram to build voice AI products and features.

## Prerequisites

Before you begin, ensure you have:
- A Deepgram API key (see below)
- Audio files in supported formats (WAV, MP3, M4A, or FLAC)

## Quickstart

Follow these steps to get started with this Voice Agent using Docker

### Clone the repository

Go to GitHub and [clone the repository](https://github.com/deepgram-starters/node-voice-agent).

### Create a `.env` config file

Copy the code from `sample.env` and create a new file called `.env`. Paste in the code and enter your API key you generated in the [Deepgram Console](https://console.deepgram.com/).

```
DEEPGRAM_API_KEY=your_deepgram_api_key_here
```

### Run the application with Docker

Make sure Docker is installed and running, then start the app:

```bash
docker compose up
```
This will:

Build the app container and a Traefik reverse proxy
Serve the app at http://voice-agent.localhost:8080 (or whichever domain and port you configure)
To access the app, open your browser and go to:

```
http://voice-agent.localhost:8080
```

- Allow microphone access when prompted.
- Speak into your microphone to interact with the Deepgram Voice Agent.
- You should hear the agent's responses played back in your browser.

### Run the application with Kubernetes

Local Kubernetes Setup (Minikube)

This guide helps developers spin up your Voice Agent app locally using Minikube, including Traefik as an ingress controller, deploying the app, and tailing logs.

## Prerequisites

- Make sure you have these installed:

- Docker (for building images)

- kubectl (Kubernetes CLI)

- Minikube (local Kubernetes cluster)

- Helm (for Traefik; optional if using manifest files)

Start Minikube using Docker as the driver:

```bash
minikube start --driver=docker
```

 Verify it’s running with the following command:

 ```bash
 minikube status
```

 Rename  `voice-agent-secret.example.yaml` to `voice-agent-secret.yaml` and enter your API key you generated in the [Deepgram Console](https://console.deepgram.com/).

`brew install helm`

Add Traefik Helm Repo

```bash
helm repo add traefik https://traefik.github.io/charts
helm repo update
```

Install Traefik via Helm

```bash
helm install traefik traefik/traefik \
  --namespace voice-agent --create-namespace \
  --values ./traefik-helm-values.yaml
```

Start Minikube Tunnel (for LoadBalancer access)
This essential if you're using a LoadBalancer service type (as Traefik does by default when installed via Helm). It creates a network route on your machine so that services exposed via LoadBalancer become accessible at 127.0.0.1.

```bash
sudo minikube tunnel
```

```bash
kubectl apply -f kubernetes/voice-agent-namespace.yaml

kubectl apply -f kubernetes/voice-agent-secret.yaml

kubectl apply -f kubernetes/voice-agent-configmap.yaml

kubectl apply -f kubernetes/voice-agent-blue-deployment.yaml

kubectl apply -f kubernetes/voice-agent-service.yaml

kubectl apply -f kubernetes/voice-agent-ingressroute.yaml
```

Access the App

Add to your /etc/hosts file:

```
127.0.0.1 voice-agent.localhost
```

Then access on your browser

```
http://voice-agent.localhost
```

Useful Scripts

tail-voice-agent-logs.sh – Tail logs from all voice-agent pods

inspect-voice-agent-rollout.sh – Check which pods are active vs being terminated during rollouts

./switch-and-scale.sh blue green
# Or to switch back
./switch-and-scale.sh green blue

## Useful Commands

 It keeps the command running and continuously updates the output in real-time as the state of the pods in the voice-agent namespace changes.
```bash
kubectl get pods -n voice-agent -w
```

```bash
kubectl get pods           # Only shows pods in current namespace
kubectl get pods -A        # Shows pods in ALL namespaces
kubectl rollout restart deployment voice-agent-blue -n voice-agent
kubectl get endpoints voice-agent -n voice-agent -o wide
kubectl delete pod -n voice-agent --field-selector=status.phase=Succeeded
```

```bash
kubectl patch service voice-agent-svc -n voice-agent \
  --type=json -p='[
    {"op": "replace", "path": "/spec/selector/role", "value": "blue"}
  ]'
```
```bash
kubectl rollout restart deployment voice-agent-blue -n voice-agent
```

 You can verify live traffic routed to the blue pods this by checking the service selector:

```bash
kubectl get svc voice-agent-svc -n voice-agent -o jsonpath='{.spec.selector}'
```
## Using Cursor & MDC Rules

This application can be modify as needed by using the [app-requirements.mdc](.cursor/rules/app-requirements.mdc) file. This file allows you to specify various settings and parameters for the application in a structured format that can be use along with [Cursor's](https://www.cursor.com/) AI Powered Code Editor.

## Getting Help

- Join our [Discord community](https://discord.gg/deepgram) for support
- Found a bug? [Create an issue](https://github.com/deepgram-starters/node-voice-agent/issues)
- Have a feature request? [Submit it here](https://github.com/deepgram-starters/node-voice-agent/issues)

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

## Security

For security concerns, please review our [Security Policy](SECURITY.md).

## Code of Conduct

This project adheres to a [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## License

This project is licensed under the terms specified in [LICENSE](LICENSE).