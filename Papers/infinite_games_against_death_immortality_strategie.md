# Why a separate computational-evidence stage was skipped

The claims proved in `Catalog/Novelty/ImmortalityGame.lean` are exact statements about infinite ordinal order types, not extrapolations from a finite numerical sequence. Finite simulation can display only finite prefixes of the clocks `ω` and `ω²`; it cannot test the decisive limit-stage assertions or the sharp impossibility bounds at `ω + 1` and `ω² + 1`.

The appropriate evidence is therefore deductive rather than empirical. The Lean development computes the relevant order types symbolically:

- the natural-number clock has order type `ω`;
- the lexicographic pair clock has order type `ω · ω = ω²`;
- an order embedding exists exactly when the requested play length is at most the clock's order type;
- the successor bounds fail by strict ordinal inequalities.

A small-case table or counterexample search would neither strengthen nor falsify these transfinite conclusions, while the kernel-checked proofs settle them for all stages.