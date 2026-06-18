# Summary of changes for run cc002407-d757-414c-a19c-dbc9c0b55b0c
## Bayesian Werewolf: Optimal Strategy for Social Deduction Games

### Lean 4 Formalization (`MachineLearning/BayesianWerewolf/GameTheory.lean`)

I built a rigorous mathematical framework for the Werewolf (Mafia) game, defining the exact villager win probability under random elimination and proving several structural theorems.

**Novel Definition**: `SocialDeductionGame` — a generalized structure for hidden-role elimination games (Werewolf, Mafia, The Resistance, etc.), parameterized by player count, adversary count, night kills, and day eliminations.

**Core Definition**: `randomWinProb v w : ℚ` — the exact rational probability that villagers win with `v` villagers and `w` werewolves under random day voting. Defined as a computable recursive function.

**Proved Theorems** (12 total, all machine-verified, no sorry except the stated conjecture):

1. **`randomWinProb_nonneg`** — Win probability is non-negative (induction via convex combination structure)
2. **`randomWinProb_le_one`** — Win probability is at most 1 (induction using coefficient sum = 1)
3. **`randomWinProb_pos_iff`** — **Game Viability Theorem**: For w ≥ 1, P(v,w) > 0 ↔ v ≥ w + 2. The sharp threshold w+2 arises because one villager is lost each night before the first vote.
4. **`parity_paradox`** — P(3,1) = 1/3 > 1/4 = P(4,1): adding one villager can *decrease* win probability — a counterintuitive dilution effect
5. **`monotonicity_fails`** — Disproof of naive monotonicity: ¬∀ v w, P(v,w) ≤ P(v+1,w)
6. **`day_vote_coefficients_sum`** — Day vote coefficients form a probability distribution (sum to 1)
7. **`randomWinProb_standard_game`** — P(5,2) = 1/12 for the classic 7-player, 2-werewolf game
8. Plus base case and unfolding lemmas

**Conjecture** (with computational evidence for v ≤ 50, w ≤ 20):
- **Skip-Two Monotonicity**: P(v,w) ≤ P(v+2,w) — adding *two* villagers always helps, even though adding one sometimes hurts

### Deliverables

- **`ARTICLE.md`** — Popular-science article (Scientific American style) about the parity paradox and game theory of social deduction
- **`RESEARCH_PAPER.md`** — Full research paper with definitions, proofs, algorithms, and the skip-two conjecture reduction
- **`FUTURE_DIRECTIONS.md`** — 5 research directions including diagonal monotonicity (grand challenge), generalized night-day dynamics, urn model correspondence, information value quantification, and tropical structure
- **`demo.py`** — Numerical demonstrations of all results
- **`algorithms.py`** — Type-hinted implementations of exact computation, Monte Carlo simulation, and Bayesian posterior tracking
- **`visualize_win_probability.py`** — Matplotlib visualizations (heatmap, parity paradox, skip-two monotonicity)
- **`PACKAGE.json`** — Bundle with 3 interactive HTML demos: win probability calculator, game simulator, and parity paradox explorer