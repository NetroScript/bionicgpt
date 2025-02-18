<h1 align="center">BionicGPT</h1>
<div align="center">
 <strong>
   Accelerate LLM adoption in your organisation. Chat with your on premise data safely and securely.
 </strong>
 BionicGTP is a complete platform for enabling LLM integration with confidential data on a team by team basis.
</div>

<br />

<div align="center">
  <!-- License -->
  <a href="https://github.com/purton-tech/cloak#License">
    <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License">
  </a>
  <a href="https://hub.docker.com/repository/docker/purtontech/cloak-server">
    <img src="https://img.shields.io/badge/License-Apache-yellow.svg" alt="License">
  </a>
</div>

<div align="center">
  <h4>
    <a href="https://bionicai.tech">
      Homepage
    </a>
  </h4>
</div>

<br />

![Alt text](website/static/github-readme.png "BionicGPT Screenshot")

<!-- ROADMAP -->
## Roadmap

- [x] Chat Console
    - [x] Connect to Open AI compatible API's i.e. LocalAI
    - [x] Select different prompts
    - [ ] Multi Modal (Show images and text)
    - [ ] Syntax highlighting for code
    - [ ] Mixture of Experts?
- [x] Authentication
    - [x] Email/Password sign in and registration
    - [ ] SSO
- [x] Teams
    - [x] Invite Team Members
    - [x] Manage the teams you belong to
    - [x] Create new teams
    - [x] Switch between teams
    - [ ] RBAC
- [x] Document Management
    - [x] Document Upload
    - [x] Allow user to create datasets
    - [x] UI for datasets table 
    - [x] Turn documents into 1K batches and generate embeddings
    - [ ] OCR for document upload
- [ ] Document Pipelines
    - [ ] Create S3 compatible buckets
    - [ ] Allow user to upload docs to buckets
    - [ ] Process documents and create embeddings
- [x] Retrieval Augmented Generation
    - [x] Parse text out of documents
    - [x] Generate Embeddings and store in pgVector
    - [ ] Add Embeddings to the prompt using similarity search
- [x] Prompt Management 
    - [x] Create and Edit prompts on a per team basis
    - [x] Associate prompts with datasets
    - [ ] Inject datasets into command prompt.
    - [ ] Personas?
- [x] Model Management 
    - [x] Create/update default prompt fo a model
    - [x] Set model location URL.
    - [x] Switchable LLM backends.
    - [ ] Associate models with a command i.e. /image
- [ ] Guardrails
    - [ ] Figure out a strategy
- [ ] API
    - [ ] Create per team API keys
    - [ ] Revoke keys
- [ ] Fine Tuning
    - [ ] QLORA adapters
- [ ] System Admin
    - [ ] Hardware Status
    - [ ] Audit Trail
- [x] Deployment
    - [x] Docker compose so people can test quickly.
    - [ ] Kubernetes bionicgpt.yaml
    - [ ] Kubernetes deployment strategy.
    - [ ] Hardware recommendations.

See the [open issues](https://github.com/purton-tech/bionicgpt/issues) for a full list of proposed features (and known issues).

<!-- Try it out -->
## Try it out

Cut and paste the following into a `docker-compose.yml` file and run `docker-compose up` access the user interface on http://localhost:7800/auth/sign_up

This has been tested on an AMD 2700x with 16GB of ram. The included `ggml-gpt4all-j` model runs on CPU only.

**Warning** - Currently this required around 4GB of download due to the size of the `unstructured` image. 

```yml
services:

  # LocalAI with pre-loaded ggml-gpt4all-j
  llm-api:
    image: ghcr.io/purton-tech/bionicgpt-model-api:latest

  # Handles parsing of multiple documents types.
  unstructured:
    image: quay.io/unstructured-io/unstructured-api:0.0.34
    ports:
      - "8000:8000"

  # Handles routing between the application, barricade and the LLM API
  envoy:
    image: ghcr.io/purton-tech/bionicgpt-envoy:1.0.3
    ports:
      - "7800:7700"

  # Postgres pre-loaded with pgVector
  db:
    image: ankane/pgvector
    environment:
      POSTGRES_PASSWORD: testpassword
      POSTGRES_USER: postgres
      POSTGRES_DB: finetuna
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Sets up our database tables
  migrations:
    image: ghcr.io/purton-tech/bionicgpt-db-migrations:1.0.3
    environment:
      DATABASE_URL: postgresql://postgres:testpassword@db:5432/postgres?sslmode=disable
    depends_on:
      db:
        condition: service_healthy

  # Barricade handles all /auth routes for user sign up and sign in.
  barricade:
    image: purtontech/barricade
    environment:
        # This secret key is used to encrypt cookies.
        SECRET_KEY: 190a5bf4b3cbb6c0991967ab1c48ab30790af876720f1835cbbf3820f4f5d949
        DATABASE_URL: postgresql://postgres:testpassword@db:5432/postgres?sslmode=disable
        FORWARD_URL: app
        FORWARD_PORT: 7703
        REDIRECT_URL: /app/post_registration
    depends_on:
      db:
        condition: service_healthy
      migrations:
        condition: service_completed_successfully
  
  # Our axum server delivering our user interface
  embeddings-job:
    image: ghcr.io/purton-tech/bionicgpt-embeddings-job:1.0.3
    environment:
      APP_DATABASE_URL: postgresql://ft_application:testpassword@db:5432/postgres?sslmode=disable
    depends_on:
      db:
        condition: service_healthy
      migrations:
        condition: service_completed_successfully
  
  # Our axum server delivering our user interface
  app:
    image: ghcr.io/purton-tech/bionicgpt:1.0.3
    environment:
      APP_DATABASE_URL: postgresql://ft_application:testpassword@db:5432/postgres?sslmode=disable
    depends_on:
      db:
        condition: service_healthy
      migrations:
        condition: service_completed_successfully
```

## Kubernetes Ready

BionicGPT is optimized to run on Kubernetes and implements the full pipeline of LLM fine tuning from data acquisition to user interface.


![Alt text](website/content/rust-llm/ide-setup/llm-ops.svg "BionicGPT Architetcure")