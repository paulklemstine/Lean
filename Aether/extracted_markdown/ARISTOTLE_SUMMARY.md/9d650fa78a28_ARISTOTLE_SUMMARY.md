# Summary of changes for run c7169af5-acf5-45f6-9828-b81cc8aa7fd5
## Completed: GL3 Tropical Satake Voting Robustness Theorem

### Formally Verified Mathematics (Lean 4)

All theorems are fully proved with no `sorry` statements and only standard axioms (`propext`, `Classical.choice`, `Quot.sound`). The development is in `Bridges/TropicalSatakeVoting/`:

**`Defs.lean`** — Core definitions:
- `PairMargin` — pairwise score difference S(i,x) - S(j,x)
- `PairWins` — proposition that class i beats class j
- `BordaScore` — tournament out-degree (number of pairwise wins)
- `IsStrictBordaWinner` — strict uniqueness of Borda/Copeland winner
- `PairLipschitzBound` — heterogeneous pairwise Lipschitz condition

**`Main.lean`** — 10 formally verified theorems in three layers:

*Analytic layer:*
- `pairMargin_lower_bound_real` — |b - a| ≤ δ implies a - δ ≤ b
- `pairMargin_pos_of_lipschitz_bound` — |b - a| ≤ δ and δ < a implies 0 < b
- `pairMargin_pos_of_bound` — pairwise margin stays positive under Lipschitz perturbation
- `pairMargin_lower_bound` — triangle inequality for pairwise margins

*Combinatorial layer:*
- `filter_beats_all_eq_erase` — the set of beaten opponents is exactly `univ \ {w}`
- `bordaScore_eq_of_beats_all` — if w beats all opponents, BordaScore = n - 1
- `bordaScore_lt_of_loses_to` — if i loses to w, BordaScore(i) < n - 1
- `beats_all_implies_strict_borda_winner` — **pure tournament lemma**: beating everyone implies strict Borda winner

*Robustness theorems:*
- `borda_winner_stable_of_pairwise_win_preservation` — preserved outgoing edges ⟹ preserved winner
- `stable_borda_winner_of_pairwise_margins` — **main theorem**: heterogeneous Lipschitz margin bounds + sufficient margin ⟹ stable Borda winner under perturbation

### Python Demos (`demo.py`)

Three demonstrations with visualizations:
1. **4-class linear classifier** — computes certified radius, empirically verifies zero failures inside the certified ball, generates decision region and tournament graph visualizations
2. **Scaling analysis** — how certified radius decreases with number of classes
3. **Argmax vs Borda comparison** — contrasts pairwise voting robustness with standard argmax certification

Generates three PNG visualizations: `voting_robustness_demo.png`, `radius_scaling.png`, `comparison_demo.png`.

### Research Paper (`paper.md`)

Complete mathematical paper covering:
- Formal definitions and main theorem statements
- Detailed proofs with the three-layer factorization (analytic → combinatorial → bridge)
- Applications to adversarial robustness, ensemble methods, tropical geometry, and voting theory
- Scientific American-style discussion with chess tournament analogy
- Future directions including tighter constants, weighted voting, and randomized smoothing

### Key Mathematical Contribution

The theorem proves that pairwise one-vs-one voting classifiers with Borda/Copeland aggregation inherit certified robustness from heterogeneous pairwise Lipschitz margin bounds. This is genuinely different from argmax stability: the classifier's output is determined by a tournament of pairwise comparisons, and robustness requires preserving all outgoing edges from the winner — a combinatorial condition that the analytic margin bounds guarantee. The modular factorization creates a reusable interface: any score system (including tropical Satake scores) with pairwise Lipschitz control inherits certified voting robustness immediately.