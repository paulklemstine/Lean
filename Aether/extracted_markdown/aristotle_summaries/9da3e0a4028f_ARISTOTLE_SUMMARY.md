# Summary of changes for run 35c1a379-6b72-48e6-b583-eab8ce083b5d
Delivered a new, fully-proved Lean 4 file plus a research roadmap, extending the catalog's "rank of apparition" / Law-of-Apparition thread.

**New file: `Catalog/Applications/RankLatticeMorphism.lean`** (15 theorems, `sorry`-free, self-contained against Mathlib; verified to elaborate with zero errors/warnings).

It builds directly on the catalog's existing engine (`RankOfApparition.lean`, `UnifiedRankOfApparition.lean`), whose spine `m ∣ u n ↔ rank u m ∣ n` for strong divisibility sequences and the rigidity `rank_self` are restated for self-containment (the catalog's import graph is fragmented, and the default `lake build` is broken independently of this work — its lib globs point at top-level dirs that actually live under `Catalog/`). The catalog had only ever proved that `rank` is *monotone* for divisibility (`b ∣ a → rank b ∣ rank a`); this file proves the sharper structural fact that `rank` is a **join-semilattice homomorphism**:

- `rank_lcm` (generic, new): `rank u (lcm a b) = lcm (rank u a) (rank u b)`.
- `hasRank_lcm` (new): existence of ranks is closed under `lcm` — the join's rank is derived, never assumed.
- `rank_mul_coprime` (new): the multiplicative entry-point law for coprime moduli.
- `fibRank_lcm` (new instance): the classical "Fibonacci entry point of an lcm is the lcm of entry points" (totality via the Pisano pigeonhole `fib_hasRank`).
- `mersenne_rank_lcm` (new cross-domain instance): the same join law for `aᵏ−1`, giving `rank(lcm(aᵐ−1, aⁿ−1)) = lcm m n`.

The unifying point: one lattice identity simultaneously governs Fibonacci and `aⁿ−1`, since both are strong divisibility sequences and `rank` preserves joins. The file includes the required `-- !-- comment -- !--` proof sketches and full `-- !-- Lab Notebook -- !--` blocks (Hypothesis / Result / Insight / Failure analysis) for each result, plus documented sharp boundary conditions (e.g. the dual gcd law genuinely fails; coprimality and `a ≥ 2`, `m,n ≥ 1` are necessary).

**`FUTURE_DIRECTIONS.md`** (project root): a narrative synthesis, results summary, and 5 falsifiable research directions (gcd-side defect, bundling `rank` as a Mathlib `MonoidHom`/`LatticeHom`, prime-power decomposition of the rank, a sequence-agnostic lifting-the-exponent bridge, and primitive divisors as lattice atoms), each with a "The key insight is…" statement and a "Why now?" justification anchored to specific catalog files.

No `sorry`, no `axiom`, and no `@[implemented_by]` were introduced.