# 🎫 IT Support Ticket Analysis & Weekly Automated Reporting

> End-to-end data analytics project — from raw ticket data in **PostgreSQL** to an interactive **Power BI** dashboard, plus an automated weekly email report built with **Power Automate**.

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-336791?logo=postgresql&logoColor=white)
![Power BI](https://img.shields.io/badge/Power_BI-Dashboard-F2C811?logo=powerbi&logoColor=black)
![Power Automate](https://img.shields.io/badge/Power_Automate-Cloud_Flow-0066AD?logo=powerautomate&logoColor=white)
![Status](https://img.shields.io/badge/Status-Completed-success)

---

## 📌 Description

An IT support team receives thousands of tickets every week. This project builds the full reporting stack a support manager needs: raw tickets loaded into PostgreSQL, KPI queries written in SQL, the data cleaned and modeled in Power BI as a star schema, and the resulting dashboard delivered automatically to the manager's inbox every Monday at 09:00 via a Power Automate cloud flow.

The dataset was deliberately designed to contain realistic data-quality issues — 40 duplicate rows, ~6% inconsistent category casing, ~161 missing channel values, and ~22% missing CSAT scores — so the project demonstrates a full data-cleaning discipline in Power Query before modeling. The final dashboard answers three operational questions that a support manager asks every Monday morning (detailed in the Goal section below).

### Dashboard Preview

![Power BI Dashboard](it-support-project/it_support_ticket_dashboard.png)

*Interactive dashboard built on a star schema with DAX measures: 5 KPI cards (Total Tickets, SLA Met %, Avg Resolution, Open Tickets, Avg CSAT), monthly trend, priority breakdown, and category-level resolution times.*

---

## 🎯 Goal

A support manager walks in every Monday morning with three operational questions. This project builds the end-to-end reporting pipeline — from raw tickets in PostgreSQL to a Power Automate-delivered dashboard — that answers them without manual intervention.

### Business Questions Answered

| # | Business Question | Where It's Answered | Short Answer |
|---|-------------------|---------------------|--------------|
| 1 | **Are we meeting our SLA targets?** | KPI card `SLA Met %` + `SLA Met % by Team` chart | **82.1% platform-wide** (17.9% breach). All 4 teams clustered in a tight band (81.4% – 83%), so no team is dramatically underperforming — but the 17.9% breach still represents ~864 closed tickets (out of 4,825) that missed their SLA window |
| 2 | **How long do we take to resolve tickets, per priority?** | KPI card `Avg Resolution (hrs)` + `Avg Resolution by Category` chart + `Priority Mix` donut | Platform average is **16.89 hours**. By category: Security is the slowest at 17.81 hrs, Email & Collaboration the fastest at 16.18 hrs (1.63 hr spread). Per-priority resolution time is not yet surfaced as a dedicated chart — `Priority Mix` shows volume per priority, not resolution time per priority. This is a documented future enhancement |
| 3 | **Which priorities and channels need attention?** | `Priority Mix` donut chart + `SLA Met % by Team` chart | Priorities: P3+P4 = **80% of all volume** — these are the self-service automation opportunity. Teams: Security Operations is the lowest SLA performer at 81.4%, but only 1.6 pp below the top performer (Network Operations at 83%) |

### Scope Note

The current dashboard answers the **platform-wide SLA question** (single overall SLA %). **Priority-level SLA breakdown** (P1 SLA Met %, P2 SLA Met %, P3 SLA Met %, P4 SLA Met %) is a documented future enhancement — the SQL schema supports it (`priority` and `sla_target_hours` columns exist in the `tickets` table), but the dashboard does not yet surface it as a dedicated visual. The `Priority Mix` donut shows ticket volume by priority, not SLA compliance by priority.

---

## 🧰 Technology

| Layer | Tool | Purpose |
|-------|------|---------|
| Database | PostgreSQL (via DBeaver) | Data storage, KPI queries (GROUP BY, CASE WHEN) |
| ETL | Power Query (M) | Connection, cleaning, deduplication, custom columns |
| Modeling & BI | Power BI (DAX) | Star schema, measures, interactive dashboard |
| Automation | Power Automate | Scheduled weekly report email (cloud flow) |

---

## 💡 Skills Demonstrated

- **SQL (PostgreSQL)**: Conditional aggregation with `CASE WHEN` for SLA Met % computation, `GROUP BY` for priority / category / channel breakdowns, `ROUND()` for clean KPI presentation.
- **Power Query (M)**: Duplicate removal (5,040 → 5,000 rows), Trim + Capitalize for inconsistent casing, conditional `sla_met` column with null-handling for open tickets.
- **DAX Modeling**: Star schema (fact `tickets` + dimension `agents`), explicit measures (`DIVIDE` for SLA %, `AVERAGE` for resolution time, `COUNTROWS` for ticket volume, `CALCULATE` for open-tickets count).
- **Data-Quality Discipline**: Documented every intentional data issue in the README so the cleaning exercise is reproducible — duplicates, casing issues, missing channels, missing CSAT, and null resolution hours for open tickets are all handled explicitly in Power Query.
- **Reporting Automation**: Power Automate cloud flow with Recurrence trigger (Monday 09:00 Europe/Warsaw) and Send an Email (V2) action with weekly KPI summary.

---

## 💻 Code

### Repository Structure

```
it-support-ticket-analysis/
├── it-support-project/
│   ├── agents.csv                              # 12 support agents (dimension table)
│   ├── data_dictionary.txt                     # Column definitions
│   ├── it_support_queries.sql                  # Schema + KPI queries
│   ├── it_support_ticket_dashboard.png         # Power BI dashboard screenshot
│   └── tickets.csv                             # 5,040 raw rows (40 intentional duplicates)
└── README.md
```

### SQL File

| File | What It Does |
|------|--------------|
| [`it-support-project/it_support_queries.sql`](it-support-project/it_support_queries.sql) | 4 sections — schema creation, data load checks, cleaning, KPI queries (ticket count by priority, avg resolution by category, overall SLA compliance %) |

> `.pbix` is not committed to GitHub in this version; the SQL + CSV + Power Query steps documented in this README fully reproduce the dashboard.

---

## 📊 Results

### Headline KPIs (Power BI Dashboard — All Departments, No Filter)

| KPI | Value | Source |
|-----|-------|--------|
| Total Tickets | **5,000** (5,040 raw − 40 duplicates) | `COUNTROWS(tickets)` after Power Query dedup |
| Open Tickets | **175** | `CALCULATE(COUNTROWS(tickets), status IN {"Open", "In Progress"})` |
| SLA Met % | **82.1%** | `DIVIDE(SUM(sla_met), COUNT(sla_met), 0)` — DAX measure |
| Avg Resolution Time | **16.89 hours** | `AVERAGE(resolution_hours)` — open tickets excluded (null) |
| Avg CSAT | **3.89 / 5** | `AVERAGE(satisfaction_score)` — based on ~78% non-null responses |

### Priority Mix (Donut Chart — Power BI Dashboard)

Percentages are computed automatically by the Power BI donut chart (count ÷ total × 100) on the deduplicated dataset.

| Priority | Ticket Count | Share | Note |
|----------|--------------|-------|------|
| **P3 — Medium** | 2,471 | **49.42%** | Bulk of workload — operational middle layer |
| **P4 — Low** | 1,530 | **30.60%** | Low-priority noise — automation opportunity |
| **P2 — High** | 737 | **14.74%** | Significant — urgent but manageable volume |
| **P1 — Critical** | 262 | **5.24%** | Critical, low volume — healthy crisis ratio |
| **Total** | **5,000** | **100%** | Deduplicated (raw was 5,040) |

### Avg Resolution Time by Category (Bar Chart — Power BI Dashboard)

| Category | Avg Resolution (hrs) | Note |
|----------|----------------------|------|
| **Security** | **17.81** | Slowest — but only 1.63 hrs above the fastest |
| Software | 17.76 | Close second |
| Hardware | 17.11 | — |
| Access & Accounts | 16.50 | — |
| Network | 16.39 | — |
| Email & Collaboration | 16.18 | Fastest — 1.63 hrs below Security |
| **Spread** | **1.63 hrs** | Tight band — no category is dramatically slower |

### SLA Met % by Team (Bar Chart — Power BI Dashboard)

| Team | SLA Met % | Note |
|------|----------|------|
| **Network Operations** | **83.0%** | Highest performer |
| Field Support | 81.9% | — |
| Service Desk | 81.8% | — |
| **Security Operations** | **81.4%** | Lowest — but only 1.6 pp below Network Ops |
| **Spread** | **1.6 pp** | Tight band — no team is dramatically underperforming |

### Data Quality Issues Found & Resolved

| Issue | Count | Resolution |
|-------|-------|-----------|
| Duplicate rows | 40 (5,040 → 5,000) | Removed in Power Query (Group By + Keep Duplicates filter) |
| Inconsistent category casing | ~308 rows (~6%) | Fixed with Trim + Capitalize transform |
| Missing `channel` values | 161 | Kept as `null`; excluded from channel-level analysis |
| Missing `satisfaction_score` | ~22% | Kept as `null`; `Avg CSAT` computed on non-null subset only |
| `resolution_hours` null for open tickets | 175 | Excluded from SLA and Avg Resolution — `sla_met` left as null (not 0) |

---

## 🎯 Business Recommendations

| # | Recommendation | For Whom | Why |
|---|----------------|----------|-----|
| 1 | **P3 + P4 = 80% of all ticket volume** — these are medium-to-low priority. Stand up a self-service portal + chatbot for the top 5 P4 categories (password resets, access requests, basic troubleshooting). Every 10% shift from P4 to self-service frees ~150 agent-hours per month. | Head of Support Operations | The donut chart shows volume is dominated by low-urgency tickets; tier-1 agents are spending most of their time on tickets that don't need human intervention |
| 2 | **Monitor Security-related tickets as an early warning signal — not yet a problem area.** Two independent dashboard signals point to Security: the `Avg Resolution by Category` chart shows Security at **17.81 hrs** (highest, but only 1.63 hrs above the lowest-performing category Email & Collaboration at 16.18 hrs), and the `SLA Met % by Team` chart shows Security Operations at **81.4%** (lowest, but only 1.6 pp below Network Operations at 83%). Set thresholds: if Security resolution time drifts above 20 hrs or SLA drops below 80%, trigger a root-cause analysis. Until then, the team is performing within an acceptable band. | Support Manager | Aggregate SLA (82.1%) hides where small variations exist. Two narrow-but-consistent gaps suggest Security tickets are marginally harder to resolve, but the spreads are tight (1.63 hrs and 1.6 pp). Treating this as a crisis would misallocate resources; treating it as an early-warning metric preserves the option to act before it becomes one |
| 3 | **Investigate why ~22% of CSAT is missing.** If missingness correlates with high-priority or long-resolution tickets, your CSAT is biased upward — actual satisfaction may be lower than 3.89. Add a follow-up survey trigger for any ticket closed without a CSAT response. | Head of Customer Experience | Missing-data pattern is itself a signal. Missing-at-random is rarely the case in survey data |
| 4 | **Set an SLA improvement target: 82.1% → 85% in 90 days** (a realistic +2.9 pp delta), with a weekly automated burn-down tracking the metric via the existing Power Automate flow. Extend the Monday email to include a 12-week trend line and a delta vs target. A 90% target can be set as a 12-month goal once the 85% milestone is reached. | Support Manager | All four teams are currently clustered between 81.4% and 83% — a 7.9 pp jump in 90 days would require process overhaul, not incremental improvement. A 2.9 pp delta is ambitious but achievable; the infrastructure (Power Automate weekly email) is already in place |
| 5 | **Add a required-field check at ticket intake** so `channel` cannot be blank. Currently 161 tickets (3.2%) have no channel — these cannot be analyzed in the channel view and erode the dashboard's completeness. | Engineering / Tooling | The fix is upstream — it's cheaper to fix at intake than to clean in Power Query every week |
| 6 | **Track team-level SLA gaps over time, not as a one-time audit.** All four teams are clustered between 81.4% (Security Ops) and 83% (Network Ops) — a 1.6 pp spread. This is a tight band, not a meaningful performance gap. Add a team-level SLA trend line to the weekly Power Automate report; only trigger a team-level review if a team drifts below 80% or widens its gap from the platform average by more than 3 pp for two consecutive weeks. | Head of Support Operations | A 1.6 pp gap does not justify coaching budget reallocation. Treat the dashboard's `SLA Met % by Team` chart as a monitoring tool with thresholds, not as a ranking exercise — premature intervention on small gaps creates noise without value |

---

## ⚠️ Known Limitations

1. **Power Automate flow export is not committed to the repo** — only screenshots of the flow + email output are provided as evidence. To fully reproduce the automation, recreate the flow per the documented steps.
2. **`tickets.ticket_id` is not a PRIMARY KEY** in the PostgreSQL schema — this was a deliberate design choice to preserve the 40 intentional duplicates for the cleaning exercise. In production, deduplication should happen at the database level with a UNIQUE constraint.
3. **SLA Met % is computed on closed tickets only** (open tickets have null `resolution_hours`). This means SLA trends early in the week (more open tickets) may look artificially healthy — always pair the SLA % with the Open Tickets count when interpreting the metric.

---

## 🚀 How to Reproduce

1. **Database setup**
   ```bash
   # Create PostgreSQL database
   createdb it_support
   # Import both CSVs via DBeaver
   # Fix empty strings:
   psql -d it_support -c "UPDATE tickets SET channel = NULL WHERE channel = '';"
   ```
2. **Run SQL queries** — execute `it-support-project/it_support_queries.sql` in DBeaver to verify schema and KPIs at the SQL layer
3. **Build the dashboard**
   - Power BI Desktop → Get Data → PostgreSQL → Import mode
   - Apply the cleaning steps listed above in Power Query (dedup, trim, capitalize, custom `sla_met` column)
   - Build the relationship (agents → tickets, many-to-one, single direction)
   - Apply the DAX measures: `Total Tickets`, `SLA Met %`, `Avg Resolution (hrs)`, `Open Tickets`, `Avg CSAT`
4. **Set up the Power Automate flow**
   - Trigger: Recurrence — every Monday at 09:00 (Europe/Warsaw)
   - Action: Send an email (V2) — weekly KPI summary to the support manager

---

## 📄 Data Source

- **Dataset**: Synthetic IT support ticket dataset designed for portfolio practice (5,000 valid tickets + 40 intentional duplicates)
- **Tables**: `tickets` (fact), `agents` (dimension)


---

## 👩‍💻 Author

**Sena Erdem** — Data Analyst · SQL · Power BI · Power Automate

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=flat-square&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/sena-erdem-a64b91345/)
[![GitHub](https://img.shields.io/badge/GitHub-Profile-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/senaerdemm2)

---

> Built as a portfolio project for a Junior Data Analyst application. 2026.
