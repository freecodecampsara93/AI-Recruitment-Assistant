# Recruitment AI Agent — n8n

An AI-powered recruitment assistant built with **n8n**, **Google Gemini**, **PostgreSQL**, and **Gmail**.

The agent helps HR users search and manage candidates using natural-language requests and connected tools.

## 🚀 Project Overview

This project demonstrates an AI Agent workflow for recruitment and HR automation.

The user sends a recruitment request through a webhook, and the AI Agent interprets the request and selects the appropriate tool.

### Example request

```text
Find frontend developers with Angular experience
```

The AI Agent analyzes the request and can use recruitment tools to retrieve candidate information or perform approved actions.

---

## 🏗️ Architecture

```text
Client / Postman
       │
       ▼
    Webhook
       │
       ▼
   AI Agent
       │
       ├── Google Gemini Chat Model
       │
       ├── Search Candidates
       │
       ├── Get Candidate
       │
       ├── Update Candidate Status
       │
       └── Gmail
              │
              ▼
       Human Approval
```

---

## 🧠 AI Agent

The AI Agent is powered by **Google Gemini**.

Its system instructions define the agent as an AI Recruitment Assistant responsible for helping HR users manage candidates.

The agent is instructed to:

* Search candidates
* Retrieve candidate details
* Update candidate status
* Send candidate emails
* Avoid inventing candidate information
* Verify candidates before sensitive actions
* Require human confirmation before changing candidate status
* Verify candidate information before sending emails

---

## 🔧 Technologies

* n8n
* Google Gemini API
* PostgreSQL
* Gmail
* REST/Webhook API
* AI Agents
* Tool Calling
* Human-in-the-Loop
* Postman

---

## 🔄 Workflow

### 1. Webhook

Receives recruitment requests through an HTTP POST request.

Example:

```json
{
  "message": "Find frontend developers with Angular experience"
}
```

### 2. AI Agent

The AI Agent receives the user message and determines which tool should be used.

### 3. Candidate Search

The PostgreSQL tools are designed to search and retrieve candidate information.

### 4. Candidate Management

The agent can retrieve candidate details and update candidate status when the required confirmation is provided.

### 5. Gmail

The agent can send candidate-related emails through Gmail.

Sensitive actions are protected using human approval.

---

## 🧪 Example API Request

```http
POST /webhook/recruitment-agent
Content-Type: application/json
```

Request body:

```json
{
  "message": "Find frontend developers with Angular experience"
}
```

---

## 🔐 Security

Credentials are **not included** in this repository.

You must configure your own:

* Google Gemini API credentials
* Gmail credentials
* PostgreSQL credentials

Never commit API keys, passwords, OAuth secrets, or access tokens to GitHub.

---

## 📸 Workflow

The repository includes screenshots demonstrating the n8n workflow and successful AI Agent execution.

---

## 🎯 What This Project Demonstrates

* AI Agent development
* LLM integration
* Tool calling
* Recruitment automation
* PostgreSQL integration
* Gmail integration
* Human-in-the-loop workflows
* Webhook APIs
* Natural-language task execution
* n8n workflow automation

---

## 👩‍💻 Author

Sara El Hagar

AI Engineer / Full-Stack Developer

GitHub: https://github.com/freecodecampsara93
