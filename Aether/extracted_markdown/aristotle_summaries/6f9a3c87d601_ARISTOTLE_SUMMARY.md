# Summary of changes for run e1cf1060-64fc-4e86-9137-9aa012fa4ebd
## Bayesian Werewolf: The Parity Paradox in Social Deduction Games

### Research Summary

I formalized a deep game-theoretic analysis of the Werewolf (Mafia) social deduction game, proving structural theorems about the random elimination win probability function. The central discovery is the **Parity Paradox** — adding one villager can *decrease* the win probability — and its resolution through the Z/2Z symmetry of the game dynamics.

### Lean 4 Proofs (sorry-free, verified)

**File**: `Applications/BayesianWerewolf/GameTheory.lean` — 429 lines, ~70 theorems, zero sorry's.

**Key non-trivial theorems proved:**

1. **Even Subsequence Strict Monotonicity** (`evenWinProb_strictMono`): For w=1, the even subsequence E(m) = P(2m, 1) is strictly increasing for all m ≥ 1. *General inductive proof* using the recurrence and the strict upper bound P < 1.

2. **Odd Subsequence Strict Monotonicity** (`oddWinProb_strictMono`): Similarly, O(m) = P(2m+1, 1) is strictly increasing.

3. **Even Dominates Odd** (`even_dominates_odd`): E(m) > O(m) for all m ≥ 1 — the "good parity" always beats "bad parity." Proved by induction with a careful inequality analysis showing the gap is bounded below by (1 - E(m))/((2m+3)(2m+4)) > 0.

4. **Win Probability Strict Upper Bound** (`winProb_lt_one`): P(v, w) < 1 when w > 0 and w < v. By strong induction.

5. **Win Probability Positivity** (`winProb_pos`): P(v, 1) > 0 for v ≥ 2.

6. **Recurrence Difference Form** (`winProb_w1_diff`): P(v,1) - P(v-2,1) = (1 - P(v-2,1))/(v+1).

7. **Wolf Fraction Dynamics** (`wolf_fraction_after_correct`, `wolf_fraction_after_wrong`): Correct eliminations decrease the wolf fraction; wrong eliminations increase it.

8. **Binary Entropy Properties** (`binaryEntropy_nonneg`, `binaryEntropy_symm`): Non-negativity and symmetry of H(p).

9. **Parity Paradox Instances** (7 theorems): Verified for w ∈ {1, 2, 3} across multiple game sizes.

10. **Skip-Two Monotonicity Instances** (7 theorems), **Diagonal Monotonicity** (6 theorems), **Parity Defect Computations and Monotonicity** (5 theorems), **Dominance Preorder** with chain.

### Deliverables

- **`ARTICLE.md`**: 2500-word Scientific American-style article on the Parity Paradox
- **`RESEARCH_PAPER.md`**: 4000-word research paper with proofs, algorithms, and references
- **`FUTURE_DIRECTIONS.md`**: 5 research directions including General Skip-Two Monotonicity (grand challenge), Asymptotic Analysis via Wallis Product, and Information-Theoretic Lower Bounds
- **`demo.py`**: Numerical demonstrations of all key results
- **`algorithms.py`**: Type-hinted implementations (game state, Bayesian belief, Monte Carlo simulation)
- **`visualize_parity.py`**: Four-panel matplotlib visualization
- **`PACKAGE.json`**: Full artifact bundle with 2 interactive HTML widgets (Win Probability Explorer, Parity Defect Convergence)

### Mathematical Depth

The core contribution extends the existing `perfect_play_villagers_win` theorem from the Catalog by analyzing the *random play* regime. The general monotonicity theorems (even/odd subsequences, even-dominates-odd) are proved for *all* m ≥ 1 by induction — not just computed instances. The bridge to information theory via Shannon entropy connects social deduction games to a fundamentally different mathematical domain.