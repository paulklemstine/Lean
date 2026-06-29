# Computational Evidence — Paradoxes as Theorems (Glut Minimality cycle)

All computations were carried out *inside Lean* on the finite witness model
`paradoxModel : ParaconsistentTheory (Fin 6)` and the four-value algebra
`BelnapVal`, so every number below is machine-checked (`decide`/`rfl`), not
hand-computed.

## 1. The witness model (small case)

`paradoxModel` over `Fin 6`:

| sentence | 0 (Liar) | 1 (Russell) | 2 (Berry) | 3 | 4 | 5 |
|----------|----------|-------------|-----------|---|---|---|
| truth    | B        | B           | B         | T | F | N |
| sentNeg  | 0        | 1           | 2         | 4 | 3 | 5 |

* `neg_coherent` holds for all 6 sentences (checked by `decide`).
* Inconsistency degree (# of `B`-valued sentences) = **3**
  (`paradoxModel_inconsistency_degree`).
* `4 = F` is undesignated ⇒ the theory is non-trivial / non-explosive
  (`paradoxModel_rejects_explosion`).

## 2. Negation fixed points (the source of paradox)

Belnap negation `neg`: `T↦F, F↦T, B↦B, N↦N`. The fixed points are exactly the
non-classical values: `v = v.neg ↔ v ∈ {B, N}` (`BelnapVal.fixed_point_iff`).
Hence every Liar is a glut or a gap, and soundness + provability removes the gap
escape (`provable_liar_is_glut`).

## 3. Counterexample hunt for C5 (functoriality)

Conjecture C5 (strong form): *every* `ParadoxEndomorphism` preserves
inconsistency degree. We tested value-fixing endomorphisms that move only the
classical values:

* `negEndo` (`T↔F`, fix `B,N`): degree preserved — count of gluts unchanged
  (`negEndo_preserves_degree`).
* `boostEndo` (`T↦B`, fix `F,B,N`): applied to `paradoxModel` it converts the
  `T`-sentence `3` into a fourth glut.

| endomorphism | # gluts of `paradoxModel` after applying it |
|--------------|---------------------------------------------|
| identity     | 3                                           |
| `negEndo`    | 3                                           |
| `boostEndo`  | **4**  ← counterexample                      |

The `boostEndo` row (checked by `decide` in `paradox_functoriality_fails`)
**refutes** the strong C5: a legitimate paradox endomorphism can manufacture a
dialetheia. The salvaged invariant is restricted to the negation endomorphism.

## 4. OEIS / external signals

No integer sequence is central to this logical cycle; the only counts are the
fixed number of Belnap values (4) and the model's degree (3), so an OEIS lookup
is not informative here. The four-valued Belnap–Dunn lattice (FDE) and the
relevance-logic literature were the guiding external signals, motivating the
explosion-vs-triviality dichotomy (C3) and the glut-necessity result (C4).
