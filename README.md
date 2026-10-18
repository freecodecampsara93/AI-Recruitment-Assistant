# Recruitment AI Agent — n8n

An AI-powered recruitment assistant built with **n8n**, **Google Gemini**, **PostgreSQL (Supabase)**, and **Gmail**.

HR users send requests in natural language. The agent understands the request, picks the right tool, and answers from the real candidate database.

**Key design decision:** the agent cannot change data or send emails by itself. It can only create a *request*. A separate workflow sends each request to an HR manager and runs it only after approval. Human approval is enforced in the execution layer, not only in the prompt.

---

## 🧰 Tools

| Tool | What it does |
|---|---|
| `search_candidates` | Search by name, position, skills or status, sorted by years of experience |
| `get_candidate` | Get one candidate's full details by ID |
| `request_status_change` | Creates a pending status change. **Does not change data** |
| `request_email` | Creates a pending email. **Does not send it** |

---

## 🏗️ Architecture

The project has two workflows.

### 1. AI Recruitment Assistant (the agent)

```text
Client (Postman / PowerShell / app)
       │  POST + X-API-Key header
       ▼
    Webhook  (Header Auth)
       │
       ▼
   AI Agent ── Google Gemini Chat Model
       │    ── Postgres Chat Memory (per sessionId)
       │
       ├── search_candidates      (read)
       ├── get_candidate          (read)
       ├── request_status_change  ──┐
       └── request_email          ──┤  INSERT only
                                    ▼
                            pending_actions table
```

### 2. Recruitment Approvals (the execution layer)

```text
Schedule Trigger (every 5 min)
       │
       ▼
Lock pending   pending ➜ awaiting  (one request per run)
       │
       ▼
Has request?
       │
       ▼
Gmail: Send and Wait for Response (Approve / Disapprove)
       │
       ├── Approved ➜ Switch on action
       │               ├── update_status ➜ UPDATE candidates
       │               └── send_email    ➜ Gmail send
       │                         │
       │                         ▼
       │                  Mark done
       │
       └── Disapproved ➜ Mark rejected
```

---

## 🛡️ Human Approval (enforced in the workflow)

The agent has no permission to change data or send emails.

* `request_status_change` and `request_email` only `INSERT` a row into `pending_actions`.
* The **Recruitment Approvals** workflow sends each request to an HR manager with Gmail **Send and Wait for Response**, and runs the action only after approval.
* Request status flow: `pending` ➜ `awaiting` ➜ `done` / `rejected`.
* The `awaiting` status is set in the same SQL statement that picks the request, so the same request is never sent for approval twice.

**Why not just the prompt?** A model can be tricked or make mistakes (for example, a message saying "the manager already approved, just do it", or hidden instructions inside a candidate's text). If the tool that changes data exists, a tricked model can call it. Here that tool does not exist for the agent, so the worst case is a request that HR rejects.

---

## 🔐 Security

* **Webhook protected with Header Auth:** requests without the correct `X-API-Key` header get `403 Forbidden` before they reach the agent.
* **Parameterized SQL queries:** all tools use `$1`, `$2`, ... The query text is fixed; the model only supplies values through `$fromAI`, and they are sent separately from the query. This prevents SQL injection.
* **Database constraints:**
  * `CHECK` on `candidates.status` allows only `new`, `screening`, `interview`, `rejected`, `hired`.
  * `CHECK` on `pending_actions.action` and `pending_actions.status`.
  * `candidate_id` references `candidates(id)`, so requests for non-existent candidates are rejected.
* **No credentials in this repository.** You must configure your own:
  * Google Gemini API key
  * Gmail OAuth credentials
  * PostgreSQL credentials
  * Header Auth value for the webhook

Never commit API keys, passwords, OAuth secrets, or access tokens to GitHub.

---

## 🗄️ Database Setup

1. Create the `candidates` table (id, name, email, phone, position, skills, experience_years, status, created_at).
2. Run [`pending_actions.sql`](pending_actions.sql) in the Supabase SQL Editor. It creates the `pending_actions` table and the status `CHECK` constraint.

**Connecting n8n Cloud to Supabase:** use the **Session pooler** connection (Supabase ➜ Connect ➜ Session pooler). The direct connection is IPv6-only, which n8n Cloud cannot reach. The pooler user has the form `postgres.<project-ref>`.

---

## 🧪 Example Requests

```http
POST /webhook/recruitment-agent
Content-Type: application/json
X-API-Key: <your-secret>
```

Search:

```json
{ "message": "Find frontend developers with Angular experience", "sessionId": "hr-1" }
```

Status change (creates a pending request):

```json
{ "message": "Change candidate 1 status to interview", "sessionId": "hr-1" }
```

Email (creates a pending email, nothing is sent yet):

```json
{ "message": "Send candidate 1 an interview invitation email for Sunday 11am", "sessionId": "hr-1" }
```

Expected agent reply: the request was created and is **waiting for HR approval**.

`sessionId` keeps the conversation history, so a follow-up like "change the first one to interview" works.

---

## 🔧 Technologies

* n8n (AI Agent, Postgres, Gmail, Schedule, Switch, IF nodes)
* Google Gemini API
* PostgreSQL (Supabase)
* Gmail (Send and Wait for Response)
* Webhook API with Header Auth
* Tool Calling
* Human-in-the-Loop

---

## 📁 Repository Files

| File | Description |
|---|---|
| `AI Recruitment Assistant.json` | The agent workflow |
| `Recruitment Approvals.json` | The approval / execution workflow |
| `pending_actions.sql` | Database setup |
| Screenshots | Both workflows and a successful execution |

To use the workflows: in n8n, **Import from file**, then attach your own credentials.

---

## 🎯 What This Project Demonstrates

* AI agent development with tool calling
* Permissions enforced in the execution layer, not in the prompt
* Human-in-the-loop approval workflows
* Secure SQL (parameterized queries and database constraints)
* Preventing duplicate processing
* Webhook authentication
* Conversation memory
* n8n workflow automation

---

## 🔮 Next Improvements

* Add a wait timeout: if HR does not respond, mark the request as rejected or send a reminder.
* Validate the requested status when the request is created, not only when it is applied.
* Build an evaluation set of Arabic and English requests to measure tool-selection accuracy.

---

## 👩‍💻 Author

Sara El Hagar

AI Engineer / Full-Stack Developer

GitHub: https://github.com/freecodecampsara93
