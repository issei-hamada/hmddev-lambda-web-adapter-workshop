# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AWS Lambda Web Adapter Workshop - A FastAPI application deployed to AWS Lambda using Lambda Web Adapter. The app serves as an event API that fetches information from connpass.

## Common Commands

### Local Development
```bash
# Activate virtual environment
source venv/bin/activate

# Install dependencies
pip install -r app/requirements.txt

# Run FastAPI locally
cd app && uvicorn main:app --reload --port 8080
```

### Build and Deploy
```bash
# Build the application (Docker container)
sam build

# Deploy to AWS
sam deploy --guided --role-arn arn:aws:iam::$ACCOUNT_ID:role/workshop-cfn-execution-role

# Deploy with existing configuration
sam deploy
```

### Testing the API
```bash
# Get all events
curl ${API_URL}events

# Get event details
curl ${API_URL}events/{event_id}/detail

# Get events by prefecture
curl ${API_URL}events/pref/tokyo
```

## Architecture

### Key Components
1. **FastAPI Application** (`app/main.py`): REST API with endpoints for event data
2. **Container Deployment**: Uses Docker with AWS Lambda base image
3. **Lambda Web Adapter**: Enables running standard web apps on Lambda
4. **API Gateway**: HTTP API for public access

### Directory Structure
- `app/`: Application source code and Dockerfile
- `docs/`: Workshop documentation and images
- `template.yaml`: AWS SAM/CloudFormation template
- `samconfig.toml`: Deployment configuration

### API Endpoints
- `GET /events` - List events (optional keyword filter)
- `GET /events/{event_id}/detail` - Event details
- `GET /events/pref/{prefecture}` - Events by prefecture
- `GET /events/group/{subdomain}` - Events by group
- `GET /events/count` - Total event count
- `POST /events/filter` - Advanced filtering

### External Dependencies
- Connpass API (via proxy01.yamanashi.dev for workshop)
- API key stored in AWS Systems Manager Parameter Store

## Important Notes

1. **No Test Suite**: Currently no unit or integration tests
2. **CORS Configuration**: Wide open in development - needs restriction for production
3. **Environment Variables**: API_KEY loaded from Parameter Store
4. **Python 3.12**: Required runtime version
5. **Region**: Deploys to ap-northeast-1 (Tokyo)
6. **Profile**: Uses develop_isseihamada AWS profile