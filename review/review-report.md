# Regional Indicators Project: review report

**Author:** Steve Crawshaw
**Date:** August 2026
**Status:** For decision

---

## 1. Executive summary

The Regional Indicators report was delivered to deadline. A public-facing Quarto site now covers all six Growth Strategy priorities, each chapter owned by an analyst, built on reusable foundations: a style guide, a structured quarto template, a data contract, shared functions and an automated publishing pipeline. It is a Minimum Viable Product (MVP) and the foundations exist for repeated work.

This review is a combination of my insights from the process and the outputs of structured interviews with other contributing analysts. It contains some recommendations to improve the process for the next cycle.

Several areas of potential improvement have been identified through this review process.

- **Skills are weakly embedded.** R analysis worked. Git, version control and the
  publishing workflow did not. Four of five analysts cannot independently take a chapter
  from script to published page.
- **Two of four learners lost most of the formal training to IT provisioning failures.**
  They had no working laptop and no R installed. This is the single largest avoidable
  waste in the project. It is now resolved, but it was never budgeted for.
- **Time was fragmented, not absent.** Analysts are not asking for more days. They are
  asking for uninterrupted ones. The repository history corroborates this: four multi-week
  silent stretches, each followed by a crunch week of 15–30 commits.
- **The project depends on one person.** 76% of all commits, and 100% of commits on three
  of six chapters, are mine. One analyst states outright that she could not have done it
  without individual support, and asks for that to be recorded.
- **Audience and purpose are defined only as "residents".** The analysts do not agree on
  what the product is for, and they cannot resolve that disagreement themselves. A clear understanding of the purpose and audience has not been communicated.
- **Several indicators could not be implemented due to data availability and other issues** These indicators should be removed or changed before the next round.
- **Scope is shallow.** Quarto supports far more than the report uses: interactive charts, data downloads, cross-indicator analysis. Early internal feedback already asks for depth the current product does not provide.
- **Continuation is unresolved, and it is blocking people.** Four of five analysts want to know whether this runs again. One says the answer changes how he prioritises everything else. Another's dissatisfaction rests almost entirely on having watched a comparable initiative, the dashboards programme, get built and then abandoned.

Section 2 sets out the decisions needed. Everything after it is the evidence.

---

## 2. Decisions required

These are for the commissioning manager(s), not the analysts.

### D1. Does this continue, and on what cycle?

Four of five analysts raised it unprompted. Tom asks for it outright, because the answer changes how he plans other work. As the architect of the project, I also need to know as soon as possible so that I can plan the support for analysts and technical development.

Analysts expressed concern about effort expended with no long term prospects of continuation. Stuart's "Disagree" on overall satisfaction is not a verdict on the product. He closed the interview with *"well done on this, Steve... I think it is a really good piece of work"*. What he objects to is investing 25 days in something he has watched happen before: *"there  was a big push on dashboards when I first started and that kind of dropped away and it's been replaced by this."*

A stated commitment to continuation or abandonment is necessary to enable effective work planning.

### D2. What is the report for, and who reads it?

The audience is currently understood to be "residents", which is not a usable definition. The analysts disagree on the product, and the disagreement is legitimate. They cannot settle it at their level. The table summarises the opinions of those analysts who spoke about the future direction of the report.

| Position | Held by | Implication |
| --- | --- | --- |
| Narrative layer over auto-updating data | Megan | Editorial effort each cycle; data pipeline investment |
| Discursive cross-indicator commentary linking chapters | Tom | Analytical effort; coordination across chapters |
| Strictly factual indicator content, plus an introduction explaining indicator choice | Heather | Cheapest to maintain; keeps the site current; avoids leading the reader |

The team currently publishes two similar products. The State of the Region powerpoint and this indicators report. There is significant duplication between the products and confusion among the analysts about what purpose each one serves. Audience and purpose also need to be defined for the SotR presentation. End user research would help to understand how these data products are used and by whom and therefore the potential shape of any rationalisation work.

### D3. Protected time. How much, and enforced by whom?

Every analyst who struggled cites fragmentation rather than volume as the constraint. Megan puts it in the strongest terms in any transcript: *"you just need some designated time where you don't answer your team, so you don't look at your emails and you just get it done."* Stuart never got the daily hour that would have helped. He prioritised urgent IBB requests above the indicators because he judged them more important to the region, a rational choice given the signals he was receiving.

Delivering protected time requires that line managers put the project into people's priorities explicitly and support defending allocated time against competing priorities. One potential way of formalising allocated time would be data analyst apprenticeships where the projects and portfolio are aligned to work which supports regional indicator work.

The demand for protected time is currently unquantified. More work is needed to understand how much time is required for a repeated exercise.

### D4. AI tooling. Procure it or prohibit it

Three analysts are personally funding, or about to fund, a consumer AI subscription that the delivery depended on. Megan funds hers through her partner's company, and has already raised the data-privacy limits of a consumer tier when pasting branded organisational code - even though no private data are shared. Stuart is considering paying himself because *"the organisation is a little slow on doing that"*. He switched from Mistral to Claude. Steve has GitHub copilot funded by the MCA but also pays for Claude Pro due to its enhanced capabilities. The MCA does currently have M365 copilot but this is currently not capable enough for code generation or support for this type of project.

This is unmanaged data handling on organisational work, funded off the books aka "shadow" AI. It is a governance risk whatever one's view of AI in analysis, and it needs a management decision and a route into the Digital and Data Strategy. As a starting point GitHub copilot could be trialled for analysts at a relatively low cost of ~£8 per month.

### D5. Do not run the next cycle concurrently with the State of the Region

Stuart says the concurrency degraded the product. Tom describes the deadline collision and the point at which he realised he had conflated the two workstreams and had far more outstanding than he thought.

Megan and Stuart both suggest merging or linking the two products rather than running them in parallel. That is a potential option, but the scheduling point stands either way.

There is a wider point about the need and rationale for two similar analysis products covered in point D2.

### D6. Corporate provision of the development environment

There is no standard corporate provision of R, an IDE, or AI services. Two of four learners lost the training window to this and I spent considerable time supporting the local installation of R, Rstudio, renv and Git. Normalising the corporate provisioning of coding environments will reduce friction and delay for this exercise and allow for a coherent process for new analysts using code across the MCA. This issue, along with the stance on code - first analysis should be considered through a workstream of the digital and data strategy, but this work has established an immediate priority for provisioning of a defined set of analysis tools in the Analysis teams.

### D7. Confirm requirement for high frequency reporting of indicators

A stated requirement was for frequent reporting (i.e. more frequent than annual) for indicators where possible. It is understood that this was a desireable feature to showcase the indicators report as a data lab project. There are only a small number of indicators that use data published at monthly or quarterly cadences and these will be dwarfed by the much higher number of annual indicators. Higher frequency reporting greatly increases the complexity and fragility of the process. It is therefore pertinent to determine if this a real requirement for delivering business insight at a specific cadence, or a cosmetic requirement to show capability.

---

## 3. Background

The requirement for a public-facing report on regional indicators emerged from the work to define an outcomes framework for MCA projects. One component of that framework was a set of regional indicators: metrics not directly influenced by MCA projects, but giving an overview of the region across the six priorities in the Growth Strategy.

Discovery work identified Quarto as the optimal publishing platform. It supports literate programming, interactivity and publishes to a wide range of formats, and works with version control.

I proposed a [project to deliver the training and indicators](https://westofenglandca.sharepoint.com/:w:/s/PolicyStrategy/IQA25MyDGpIUSZzOlZ25r_hGAXF36uOTqMbqyr6-v_vjllg?e=UXf477) report in February 2026. A template of the report was produced in April 2026 and [further requirements](https://westofenglandca.sharepoint.com/:w:/s/PolicyStrategy/IQDT2EnUXrHKSaIQFkMBRO7PAXiOn_y8gQ8TJ2cAFSi6gj4?e=Dsx82A) added in late April.

---

## 4. Indicator definition

Indicators were defined consultatively with the MCA's lead economist, senior analysts and the relevant business area leads. At the time they were defined, the decision to publish them had not been made, so the shape of the published indicator was undefined even though the broad description of each metric was known.

We considered comparison against a "similar" area and rejected it. ONS work on nearest statistical neighbours exists, but "nearness" depends on the topic being compared and so leads to inconsistency in comparators. The requirement to include North Somerset makes prepared analyses from ONS unusable, because they exclude it (North Somerset is not, at the time of writing, a constituent Unitary Authority). New MSAs and MCAs are being planned so it is a shifting landscape of potential comparators.

The indicators were ultimately defined as time series: a unique identifier, period start, period end and value. This supports a standard approach to summary tables and visualisation, and tracks regional progress over time. Indicators can be broken down by UA where appropriate, but this is done in narrative and charts rather than the reported indicator value.

**The FACT contract works.** FACT tables (the time series data derived by analysis) are used to create the summary tables, trends and change statistics. Each analyst writes their indicator to `data/fact/{indicator_id}.csv` and the report collates at render time. Nobody found it conceptually hard. Tom: *"No, not at all."* Simon picked it up quickly. Megan understood it. Heather did not understand it initially and endorses it now.

The one failure was communication, not design. Stuart missed the instruction entirely and discovered FACT tables were required only through Megan, while resolving a duplicate indicator. Once he copied Megan's template it was straightforward.

### Learnings

- Define the general shape of indicators early. It discounts or confirms candidates
  cheaply.
- Including North Somerset removed many pre-computed open datasets from use and forced
  bespoke analysis. This may change now inclusion has been agreed.
- I did not consider polarity, order and unit type at the outset, and had to retrofit both mid-way through.
- This key component could have been better communicated. One analyst never received the instruction.

---

## 5. The code-first skills model

### 5.1 What the workflow demands

Contributing requires an analyst to install and configure non-standard software, write analysis code in R, use Git and GitHub for version control, mix code and prose in Quarto, and use command-line tools to configure R and manage the project.

For three analysts this was an entirely new way of working. Two others had some exposure, but not on a project of this complexity. Learning R, Quarto and the command line is demanding. Confidence in R alone takes years. The analysts have done well to reach the outcomes they have.

To reduce that load, I wrote boilerplate functions for chart formatting, publishing workflow, summary tables and security scanning so analysts could concentrate on business logic and domain knowledge.

### 5.2 Training delivered

I developed training materials for [R and Quarto learning](https://r-quarto-learning.vercel.app/) against an explicit [pedagogy](https://r-quarto-learning.vercel.app/overview/pedagogy.html) for new learners of code-first analysis, and delivered them in weekly sessions from April to July 2026. I also provided on demand support and created specific learning materials for components of the work.

- [Contributing via Git workflow](https://stevecrawshaw.github.io/demos/weca-workflow/)
- [Git playground](https://r-quarto-learning.vercel.app/playgrounds/git-learning-playground.html)
- [Bash playground](https://r-quarto-learning.vercel.app/playgrounds/bash-learning-playground.html)

### 5.3 What the interviews show

Five analysts were interviewed, producing 326 coded points across five transcripts. Two
framing points are relevant.

**The pre-interview forms understate the problems.** In all five cases the interview is more critical than the questionnaire. Heather rated every item "Agree" and then described the first sessions as baffling. Megan rated the resources "Strongly agree" and then described a written Git guide she could not use. The forms were still valuable as a discussion aid. They elicited deeper answers than the questions alone would have.

**Simon is not comparable to the other four.** He arrived fluent in R and Quarto. His five days and uniformly positive ratings describe a different job. He is treated here as design critique, and as an observer of his colleagues, not as evidence about the learning pathway from a low baseline.

#### The machines were not ready

Heather had no R and no working laptop while the group sessions ran: *"I find it quite difficult to learn if I can't put it into practice. So it just became a big delay, really."* The early sessions were *"Baffling"*. She would follow along and then lose the thread entirely.

Megan lost the same sessions the same way. She had no R installed to follow along, and a
laptop change then inhibited her participation in the later ones. Only the first two were usable.

Two of four learners attended the formal training and got no embedded learning from it, because both learn by doing.

#### The training was front-loaded and it evaporated

Four analysts raised timing. Stuart wants it spread out and taught topic by topic, and is specific about Quarto: incomprehensible first time, and it had to be taught again when he came to use it. Heather found small details did not survive the week between sessions, and says embedding takes longer than the project allowed. Megan had taught content evaporate between sessions because competing work filled the gap. Simon, from outside, predicts the same will happen again between cycles unless people get deliberate practice.

The remedy they describe is consistent. Teach a topic at the point it is needed, and block out the rest of the day after each session for hands-on work.

#### R worked. Publishing and Git did not

This is the clearest finding in the set.

Megan is confident in the analysis and stuck at the last mile: *"I'm confident using the code and getting it into a Quarto report-ish... the actual publishing of it, I still, I wouldn't have a clue"*, ending *"I'm not confident at all."* She would not publish again without being talked through it step by step. A written Git guide existed and did not work: *"I think you did do a step by step kind of guide for it. But yeah, I had to keep asking ChatGPT what were these things meant."*

Simon needed no help with R at all, and cites the same gap as his hardest thing and as his single ask: more exposure to *"using repos, maintaining that sort of thing."*

The emphasis on R basics produced output, not autonomy. The people who can now write the analysis still cannot version-control and publish it.

#### Copying a colleague's finished work was the main teaching mechanism

All four learners said this. Megan copied a worked indicator for graph structure and branding, and says it was the thing that made it go smoothly. Tom read a colleague's completed scripts and could immediately see where he was going wrong. Stuart copied Megan's template. Heather read every other analyst's chapter and took both tone and prose from them.

The examples taught more than the documentation did. The next cycle should lead with a complete worked chapter rather than with reference material.

#### Heather only learned what she was aiming at by accident

She saw the rendered website posted in a chat after she missed a meeting, and that was the moment the target became clear. A visible endpoint should be the first artefact shown, not an incidental one.

### 5.4 Learnings

#### General

- Group sessions assumed a working development environment. That assumption failed for two
  analysts and cost them the training.
- Sessions were planned at four hours and ran at ninety minutes maximum. Competing demands
  and attention limits made long sessions impractical.
- Progress was slow, as anticipated. Dedicated, protected time at the start would have
  embedded more than the approach taken.
- Team churn meant the place analyst, Tom, arrived in July and received no training at all.
- Working patterns limited participation for some analysts.

#### Technology-specific

- Git and GitHub are conceptually hard for new users. Cryptic error messages erode confidence, and the experience can be demoralising even with comprehensive material available.
- Teaching focused heavily on R scripting and analysis. That was the right emphasis for getting learners to visible output, but see the autonomy gap above.
- Quarto work was largely templated, so analysts could copy and adapt an existing `index.qmd`. The step from Quarto document to published page was not understood.
- Git was taught through bash rather than a GUI. A GUI exists in RStudio, but it is slow, and without an understanding of the fundamentals it neither improves the workflow nor embeds the underlying concepts. This remains the right call. The sequencing needs work.
- Analysts used AI support to varying degrees. An MVP in this timescale was probably not achievable without it. The risk is that reliance on AI is embedded where learning is not. Verifying AI-written code is impossible unless you understand the code. Stuart used it heavily and shifted from debugging to writing code as time ran out, and says he would have learnt more without it - but at the cost of time.
Rather than using AI tools simply to do the analysis work, a better approach would have been to use AI as a learning tool to embed a deep understanding of the architecture and code. The unplanned and disparate nature of AI provision meant that this opportunity could not be taken in this cycle.

---

## 6. Delivery evidence from the repository

Analysis was undertaken of the commit history in the GitHub repository. 161 commits between 2026-02-16 and 2026-08-07. This corroborates two interview findings, with an important limitation stated at the end.

**Cadence was bursty, not steady.** Four multi-week silent stretches (Feb–Mar, May, late June, late July), each followed by a burst of a dozen or more commits in one week. The two biggest weeks, 19 and 30 commits, sit immediately before deadline points. This is the fragmented-time pattern the analysts describe.

**The "each analyst commits their own chapter" model did not happen.**

| Chapter | Owner | Total commits | Steve | Owner's own |
| --- | --- | --- | --- | --- |
| 01-economy | Stuart | 17 | 14 | 0 |
| 02-transport | Heather | 8 | 8 | 0 |
| 03-place | Tom | 10 | 10 | 0 |
| 04-skills | Megan | 13 | 11 | 2 |
| 05-environment | Steve | 24 | 24 | n/a |
| 06-child-poverty | Steve | 8 | 7 | 1 (Megan) |

Overall: Steve 122 commits (76%), Megan 23 (14%), Simon 11 (7%).

**This measures who ran `git commit` not who did the analysis.** Heather, Tom and Stuart each produced a chapter's worth of work. It reached the repository through me because the Git workflow did not land. Commit counts are evidence about the *workflow*, not about effort or contribution, and should not be read as individual performance data.

Two secondary findings are worth acting on.

- `publish.yml` changed 14 times and `renv.lock` 16 times. The CI pipeline and the R environment both needed repeated correction rather than being right once. Environment management is a recurring cost, not a setup cost.
- Nobody used the GitHub issue tracker. Two issues exist, both for specific alerting purposes. Day-to-day   coordination happened verbally or in Teams and left no durable record. That is why this review had to be reconstructed from interviews.

---

## 7. Time and cost

| | Chapter(s) | Days spent | Next cycle (form) | Next cycle (interview) | Overall rating |
| --- | --- | --- | --- | --- | --- |
| Stuart Newman | Economic Growth | 25, revised up | 15 | 10, or about 1 with automated updates | Disagree |
| Megan Johns | Skills + Child Poverty | 10 | 7 | not given | Neutral |
| Thomas O'Shea | Place | 10 | 7 | not given | Agree |
| Heather Blake | Transport | 6, disowned | 2, undefended | not given | Agree |
| Simon Moss | Economy (digital) | 5, plus others' help | 3 | not given | Strongly agree |

**Three of these five figures are unreliable.** Stuart revised his upwards in interview (*"I said 25 days, I probably under egg that"*) and now has three different next-cycle numbers. Heather was uncertain: *"I have no idea if that is true"*. She reconstructed six days in the moment from a rough weekly rate, and did not defend the two-day estimate when I pointed out that moving her Excel work into R will take longer.

The four analysts learning from baseline spent somewhere between 10 and 25-plus days each. None of this includes my own time, which the commit history suggests dominates the total.

Two specific cost drivers for next cycle:

- **Sixty per cent of Tom's time went on building time series by hand.** This will recur annually unless we address the data collection and pipeline requirements.
- **Automated updates are the only quantified saving in the review.** Stuart estimates they take his next cycle from ten days to about one. It is hedged, but it is the single highest-return investment identified. This will not apply to all datasets as many don't have an API.

---

## 8. Product scope, quality and design

### 8.1 The product under-uses its platform

Quarto is an excellent platform for in-depth reporting, and the analysis sits at the surface. Interactive charts, data downloads and cross-indicator analysis are all available and unused. Initial internal stakeholder feedback from Stewart Grey has already asked for greater depth and other analysts say the same.

Note the disagreement on interactivity. Megan wants more of it. Stuart doubts anyone uses it, arguing that analysts love it and users do not, and would stop at switching between West of England and unitary authority level. This is a D2 question. It follows from audience and purpose definition.

### 8.2 A single common deadline inhibited peer review

The sharpest criticism of the project's design anywhere in the five transcripts, and Tom volunteered it inside an answer about workload:

> "the deadline that was given meant that everybody was working to that deadline. So try
> and then to find time with other people to make, to sense check your own work. It kind of
> takes away a bit from that." ... "And then it takes away from the collaborative element,
> which is so central to this approach."

He follows it with an admission that errors reached the published output and were corrected afterwards, and suggests the deadline was set without an understanding of what producing an error-free script involves.

Collaboration was a stated rationale for the whole approach, and the scheduling inhibited it at exactly the point it mattered. Staggered deadlines, or a review window after the last one, would address it.

### 8.3 Quality assurance is a benefit we are not claiming

Stuart does not know how many errors are sitting in his previously published Excel work, and argues QA should be sold as a headline benefit of the code-first approach. He is right, and it is currently absent from how we describe the project.

### 8.4 Specific data quality issues requiring action

| Issue | Source | Action |
| --- | --- | --- |
| An NHT data correction may never have been sent | Heather | Verify whether the published transport figure uses corrected data |
| A published mental health figure is misleading and cannot be explained. The known driver of a poor North Somerset figure cannot be stated for political reasons | Megan | Verify, then decide: caveat, footnote, or withdraw the indicator |
| Mode share rests on National Travel Survey data the analyst does not trust, *"not good data... but we don't have an alternative"*. Active travel participation may not represent the real picture | Heather | Caveat explicitly. Note that the indicator exists to satisfy DfT reporting rather than WECA's own need |
| The chart template assumes a single series. Digital infrastructure needed gigabit and superfast together | Simon | Fix in shared charting code before next cycle |
| Percentage-point handling in the change column | Stuart | Already documented in `docs/summary-table-units.md`. Confirm resolved |

The mental health item needs a management view, not an analytical one.

### 8.5 Cross-indicator linkage was a missed opportunity

Tom wanted workflows connecting related indicators across chapters, both for analysis and for communications, and flags the Spatial Development Strategy as the obvious overlap. The current architecture works against this: one chapter per analyst, deliberately isolated to prevent merge conflicts. That was the right decision for cycle 1, and should be revisited if D2 lands on a cross-cutting narrative.

---

## 9. Risks

**Key person dependency.** This is the most serious structural risk. 76% of commits, all boilerplate functions, all training material and all publishing infrastructure sit with one person. Megan attributes her entire capability to individual support, and asked for it to be recorded: *"I would have never done this without you... And I think that needs to benoted."* She offered it as thanks but it should be flagged as a risk.

**Unmanaged AI use.** See D4. Organisational code in consumer AI tiers, personally funded.

**Duplication and unclear positioning.** Stuart notes that the Brunel Centre and the Productivity Institute both publish West of England indicators, names the Brunel Centre as the obvious partner, and says the organisation is poor at checking what exists before building its own. He also expects no promotional support: *"I don't think comms are going to be pushing this because it doesn't necessarily tell the narrative that they want to tell."* If he is right, the report's reach will be limited whatever its quality, which is another reason D2 matters.

**Abandonment.** See D1. The precedent of the dashboards programme is live in at least one analyst's assessment of whether to invest next cycle.

---

## 10. What worked and should be kept

- The Quarto platform choice, and the modular one-chapter-per-analyst structure.
- The FACT data contract. Everyone who was told about it understood it, and it does the
  job it was designed for.
- Boilerplate functions for charting, summary tables and publishing. They let analysts
  concentrate on domain work.
- Worked examples as the primary teaching device. This outperformed written documentation
  by a wide margin, and should be the deliberate strategy next time.
- Analyst ownership of a priority. Nobody objected to owning a chapter - and in fact Megan owned two. The concerns are all about time, sequencing and continuation.
- The style guide, report structure and indicator definitions. Reusable assets that do not
  need rebuilding.

---

## 11. Recommendations for cycle 2

These assume D1 is answered affirmatively.

1. **Working machines with R, an IDE and Git installed before any training begins.** Owned by IT, confirmed by a named date.
2. **Teach at the point of need, not up front.** Block out the rest of the day after each session for hands-on work.
3. **Close the Git and publishing gap explicitly.** It is the one skill that did not land, and it is what makes analysts independent of me. Treat it as the primary training objective rather than a follow-on from R.
4. **Lead with a complete worked chapter.** Show the example before the documentation.
5. **Stagger the deadlines and add a peer review window** after the last chapter is drafted.
6. **Invest in automated data updates via API**, starting with the indicators Stuart and Tom identify. It is the only change with a quantified return.
7. **Involve analysts in indicator selection.** Tom asks for this directly. It also distributes ownership of the definitions.
8. **Use the issue tracker** for blockers and decisions, so the next review does not have to be reconstructed from interviews.
9. **Talk to the Brunel Centre and to the unitary authorities** before building anything further, on duplication and on what they would reuse.
10. **Add an introduction explaining why these indicators were chosen.** This is Heather's ask, it is cheap to do, and it addresses the weakest point in the current site.
11. **Store source data in Azure Blob Store** The current approach does not work when multiple analysts work on a single chapter. A single blob store fixes this. In train.
12. **A greater focus on end to end analysis pipelines in code is needed** All the analysts relied to some degree on pre - processing data in Excel. This prevents reproducibility and automation. The implication is that more time will be needed to implement a code first approach in the next cycle, but that investment in time will pay of for subsequent cycles.

---

## 12. Evidence gaps and open questions

These are stated so the report's limits are visible.

**Quantification.** Only one ask in the entire review is quantified by an analyst, and it is hedged twice. Everything else is *"a bit more time"*, *"as and when"*, *"don't teach us too much too quickly"*. Several asks are withdrawn pre-emptively. Megan hedges her blocked-day request against my capacity, and drops the wellbeing survey idea on the grounds that she has not researched it. The demand for protected time and training is real and unmeasured. It needs quantifying well before the next exercise begins, and it needs a time-recording approach rather than retrospective estimates.

**Time recording.** Three of five day-count figures are unreliable (§7). My own time is not recorded at all. The true cost of cycle 1 is unknown.

**What Stuart dropped to find 25 days was never asked.** This is significant, and it is missing. Needs follow-up.

**Megan's "Neutral" overall rating is unexplained.** She is warm throughout, and nothing she volunteers accounts for it. The nearest candidates are that the report *"isn't very unique as in like it's all data sets that anyone could access"*, and that the uniform time-series format does not tell a story for some of her indicators.

**No client or user evidence exists.** This review is entirely producer-side: five analysts and one architect. Nobody has asked a resident, a member, a unitary authority or a policy-maker whether the product is useful - and tested that response by asking for examples of use. Until users' needs are understood, we cannot truthfully answer D2.

**Commit history has limited reach as evidence.** Conventional Commit compliance is 30%, and commit counts measure workflow participation rather than authored work (§6).

**Two data quality items are unverified**, the NHT correction and the mental health figure (§8.4). Both concern published output.

---

## Appendix: method and sources

- **Interviews.** Five semi-structured interviews (Heather Blake, Megan Johns, Simon Moss,
  Stuart Newman, Thomas O'Shea), transcribed, cleaned and coded to 326 points. Coding brief
  at `review/interviews/coded/_coding-brief.md`, cleaned transcripts at
  `review/interviews/clean/`. Every quote in this report is verified against them.
- **Pre-interview forms.** `review/pre-interview-form.md`. Results in §7.
- **Asks register.** `review/interviews/asks.csv`, 34 asks with quotes, line references and
  hedging status.
- **Repository analysis.** `review/git-history-analysis.md`, 161 commits, 2026-02-16 to
  2026-08-07.
- **Architect's assessment.** `review/report-outline.md`, written before the interviews
  were synthesised.
- **Not collected.** Client and user questionnaire (`review/questionnaire-clients.md`,
  drafted, not run). No skills baseline instrument.
