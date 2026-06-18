# Summary of changes for run 2b6d48b8-f8e1-4c96-9a15-94ae61ad3a8d
## Completed: Tropical Certified Robustness for Multiclass Plurality-of-Experts Ensembles

### Formally Verified Mathematics (Lean 4)

All theorems are fully proven with no `sorry` statements and use only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

**`MachineLearning/TropicalDefs.lean`** (154 lines) — Core definitions and per-expert analytic lemma:
- `decides`, `StrictDecides`, `predicts` — decision predicates for score vectors
- `scoreGap` — logit-gap margin (score of winner minus runner-up)
- `voteCount`, `winnerVoters` — plurality voting infrastructure
- `InLInfBall`, `CoordLipschitz` — perturbation ball and Lipschitz conditions
- `sum_abs_sub_le_dim_mul_linf` — L∞ sum bound: Σ|zₖ-xₖ| ≤ d·r
- `lip_lower`, `lip_upper` — Lipschitz score bounds
- **`strictDecides_of_gap_gt`** — The key per-expert lemma: if scoreGap > 2·K·d·r and f is K-Lipschitz, then f strictly decides c throughout the L∞ ball
- `decides_of_gap_gt` — Non-strict corollary

**`MachineLearning/PluralityRobust.lean`** (186 lines) — Plurality robustness theorems:
- `card_le_voteCount_of_subset_decides` — Frozen-voter lower bound
- `not_decides_of_strictDecides_ne` — Disjointness: strict decider for c cannot vote for c'≠c
- `rival_voteCount_le_complement` — Rival votes bounded by complement cardinality
- **`plurality_robust_of_frozen_winner_voters`** — Main structural theorem: if S experts are strictly frozen to c★ and S is a strict majority (|Sᶜ| < |S|), then c★ is the unique plurality winner throughout the ball
- `plurality_robust_exists_frozen_subset` — Quantitative wrapper
- `certRadius`, `stableWinnerVoters` — Certificate radius and stable voter set
- **`plurality_robust_of_expert_gap_certificates`** — End-to-end corollary composing per-expert Lipschitz gap certificates with the structural theorem

**Important design note:** The original problem statement used non-strict `decides` in the stability hypothesis, which leads to a false theorem (tied experts can vote for multiple classes, breaking the disjointness argument). The formalization correctly uses `StrictDecides`, which is naturally produced by the positive score gap hypothesis. This subtlety was caught during formal verification.

### Python Demos (`MachineLearning/demo_tropical_robustness.py`)

Four demos bringing the mathematics to life:
1. **Basic certification** — 5 experts, 3 classes, 2D inputs; computes per-expert gaps and ensemble certificate; empirically verified with 10,000 random perturbations (0 violations)
2. **Visualization** — Decision boundary map with certified L∞ ball overlay; per-expert certificate radius bar chart
3. **Scaling** — Shows how certified radius behaves as ensemble size grows (3 to 51 experts)
4. **Application** — Simulated adversarial robustness certification scenario (7 experts, 10 classes, d=10)

Generated figures: `fig_robustness_regions.png`, `fig_scaling.png`, `fig_application.png`

### Research Paper (`MachineLearning/paper_tropical_robustness.md`)

Complete mathematical paper including:
- Formal problem setup and definitions
- Complete proof sketches for all main results
- Discussion of the strict-vs-non-strict decision subtlety
- Scientific American-style discussion section with voting analogy
- Practical applications for certified defense design
- Future directions (top-k aggregators, abstaining experts, tight certificates, probabilistic extensions)