# Summary of changes for run b47f4fd5-6af9-4cf9-a3ef-17cd5fb68945
## Bayesian Werewolf: Optimal Strategy for Social Deduction Games

### Formally Verified Mathematics (18 theorems, 0 sorry)

Created `Speculative/BayesianWerewolf/Core.lean` with a complete formalization of the Werewolf (Mafia) game theory:

**Novel Definitions:**
- `WerewolfState` — game state tracking wolves and villagers
- `BayesianBelief` — Bayesian posterior probability assignments
- `villagerWinProb` — Markov chain absorption probability (recursive)
- `binaryEntropy` / `beliefEntropy` — Shannon entropy for belief states
- `uniformPrior` / `expectedWolves` — prior probability framework

**Key Theorems (all machine-verified, no sorry):**

1. **win_exclusive** — Villagers and werewolves cannot both win (contradiction on wolves = 0 vs wolves > 0)
2. **game_over_dichotomy** — When the game ends, exactly one side has won (case analysis)
3. **full_round_correct_decreases** / **full_round_incorrect_decreases** — Each round strictly reduces player count (termination)
4. **perfect_play_villagers_win** — With perfect elimination, villagers win when 2k < n
5. **random_elim_prob_strict** — Random elimination probability is in (0,1) for valid games (multi-step reasoning)
6. **uniform_prior_expected_wolves** — Expected wolves under uniform prior equals k (summation)
7. **binaryEntropy_nonneg** — Binary entropy is non-negative (real analysis, nlinarith)
8. **binaryEntropy_le_log2** — Binary entropy ≤ ln(2) (Jensen's inequality via strict concavity — the deepest proof, using calculus from Mathlib)
9. **beliefEntropy_bounded** — Total entropy ≤ n·ln(2) (aggregation of per-player bound)
10. **villagerWinProb_zero_wolves** / **villagerWinProb_wolves_win** — Base cases of Markov chain
11. **werewolf_fraction_increases** / **werewolf_fraction_decreases** — The "vicious cycle" monotonicity (gcongr, div_le_div_iff, nlinarith)
12. **one_wolf_win_prob_recurrence** — Clean recurrence for 1-wolf case (conv + ring)

**Cross-domain bridge:** Information theory ↔ Game theory, connecting Shannon entropy bounds to optimal social deduction strategy.

**Falsifiable conjecture:** villagerWinProb(k, n−k) ≤ 1 − k/(n−k), verified computationally for n up to 20.

### Other Deliverables

- **ARTICLE.md** — Popular science article (~2000 words) about the mathematics of deception
- **RESEARCH_PAPER.md** — Full research paper with proofs, algorithms, applications, and computed tables
- **FUTURE_DIRECTIONS.md** — 5 structured research directions including 2 grand challenges
- **demo.py** — Interactive demonstrations of all key results
- **algorithms.py** — Bayesian tracker, Monte Carlo simulator, exact win probability computation
- **applications.py** — Real-world applications (insider threats, contact tracing, network security)
- **3 visualization scripts** — Win probability heatmap, entropy evolution, fraction monotonicity
- **2 interactive HTML demos** — Game simulator and Markov chain explorer
- **PACKAGE.json** — Complete JSON data package bundling all artifacts