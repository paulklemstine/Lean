# Summary of changes for run a0a82a8a-5bbe-40da-8bda-e5a62d8f8b74
## Completed: Social Deduction Game — Parity Paradox Formalization

### Research Summary

This cycle established a rigorous mathematical foundation for analyzing social deduction games (Werewolf/Mafia) through recursive probability theory. The central discovery is the **Parity Paradox**: the win probability P(v, w) for villagers is *not* monotone in the number of villagers. Adding one villager can strictly decrease the win probability — P(3,1) = 1/4 < 1/3 = P(2,1).

### Lean 4 Formalization (`Computation/SocialDeductionGame.lean`)

**Fully proved theorems (no sorry):**
- `winProb` — Computable recursive definition of win probability over ℚ
- `winProb_nonneg` — P(v,w) ≥ 0 for all v, w (by structural induction)
- `winProb_le_one` — P(v,w) ≤ 1 for all v, w (convex combination argument)
- `winProb_w1_recursion` — Clean recursion: P(v,1) = 1/(v+1) + v/(v+1)·P(v-2,1) for v ≥ 4
- `parity_paradox_w1` — P(3,1) < P(2,1): the core paradox for w=1
- `parity_paradox_w2` — P(4,2) < P(3,2): paradox persists for w=2
- `parity_paradox_existence` — ∃ v w, P(v+1,w) < P(v,w)
- `phase_alignment_ratio` — P(2,1)/P(3,1) = 4/3 exactly
- `parity_gap_shrinks` — P(4,1)/P(5,1) < P(2,1)/P(3,1): paradox weakens
- `parityDefect_decreasing_w1` — D(4,1) < D(2,1): defect is decreasing
- 10 concrete value theorems, 5 skip-two instances, 3 diagonal instances
- `GameDominates` preorder with reflexivity and transitivity

**Novel definitions:** `winProb`, `parityDefect`, `SocialDeductionGame`, `GameDominates`, `gameDepth`

**Stated conjectures (3 sorry):** Skip-Two Monotonicity, Diagonal Monotonicity, Parity Defect Convergence — these represent genuine open problems computationally verified for v ≤ 50, w ≤ 10.

### Other Deliverables
- **ARTICLE.md** — Popular-science article on the Parity Paradox (no Lean/verification content)
- **RESEARCH_PAPER.md** — Technical paper with definitions, theorems, proof sketches, algorithms
- **FUTURE_DIRECTIONS.md** — 5 research directions including generating function proofs, closed-form formulas, urn model connections, asymptotic analysis, and strategic play
- **demo.py** — Interactive numerical demonstration showing the paradox
- **algorithms.py** — Type-hinted implementations with verification routines
- **visualize_parity.py**, **visualize_heatmap.py** — Matplotlib visualizations
- **PACKAGE.json** — Bundle with 3 interactive HTML widgets (Game Explorer, Parity Defect Analyzer, Skip-Two Checker)