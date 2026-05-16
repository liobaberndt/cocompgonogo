## Go/No-Go: Anonymized Data Package for Review

Overview
- Anonymized data supporting the Go/No-Go analysis for editorial/peer review.
- Model files (change parameter, sessions, weeks) are included for external reproduction with the emfit toolbox.

Contents (relative to the package root)
- `data/`
  - `Demfit.mat` (participants included in the main analysis)
- `demographics/`
  - `demographics.csv` (aligned to the included participants)
- `models/`
  - `llba2epxbq_rounds_weeks_epsilon.m`
  - `llba2epxbq_rounds_weeks_epsilon_loss.m`
  - `llba2epxbq_rounds_weeks_epsilon_win.m`
- `quest_data/`
  - `batch1_questionnaire_responses.csv`
  - `batch1_questionnaire_responses_aggregated.csv`
  - `batch2_questionnaire_responses.csv`
  - `batch2_questionnaire_responses_aggregated.csv`

Dependencies
- None required to view the data files.
- MATLAB (optional; to load `data/Demfit.mat`).
- emfit toolbox (optional; for external reproduction with `models/*.m`): https://github.com/mpc-ucl/emfit/tree/master

Quick start (reviewer)
1) Data-only verification
- Participants and trials: `data/Demfit.mat`
- Demographics for included participants: `demographics/demographics.csv`

2) Optional reproduction
- Use the public emfit toolbox with the model files in `models/`.

Anonymization
- IDs replaced with anonymous codes (`sub-xxxxxxxx`); no re-identification mapping is included.

Scope
- emfit modelling approach is validated and public; this repository provides:
  - anonymized data (task, demographics, questionnaires),
  - the model definitions used (change parameter, sessions, weeks).

Data availability
- Anonymized data are provided for review; public release will follow journal policy upon acceptance.
- Additional code/materials can be shared with editors on request; the full pipeline will be released upon acceptance.
