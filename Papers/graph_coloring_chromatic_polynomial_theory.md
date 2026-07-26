# Computational evidence

The formal development proves general counting identities, so computation is used only as a concise sanity check.

| Graph | palette size `q` | predicted number of proper colorings |
|---|---:|---:|
| edgeless graph on 3 vertices | 2 | `2^3 = 8` |
| complete graph `K₃` | 3 | `3·2·1 = 6` |
| path on 3 vertices (`K₃` with one edge deleted) | 3 | `3·2² = 12` |
| contraction of the missing-edge endpoints in that path | 3 | `3·2 = 6` |

Thus the smallest nontrivial deletion–contraction instance gives `12 = 6 + 6`.
For disjoint unions, `K₂ ⊔ K₂` with three colors has `(3·2)² = 36` colorings, agreeing with multiplicativity.

No OEIS search is relevant: the main claims are structural identities rather than a newly observed integer sequence.

Counterexample hunt: the delicate cases are empty palettes and empty vertex types. The proved formulas handle both uniformly through finite function counts, falling factorials, and an explicit coloring equivalence. No counterexample was found; the Lean proofs establish the claims for every finite simple graph satisfying the stated edge hypothesis.
