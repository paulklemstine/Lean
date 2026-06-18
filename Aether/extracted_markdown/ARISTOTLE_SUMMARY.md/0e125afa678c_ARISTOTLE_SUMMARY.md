# Summary of changes for run c179b899-43f4-4c30-a769-78fe94216315
## Delivered

I created a self-contained, fully verified Lean 4 development plus a research-roadmap file.

### `Logic/Paraconsistent.lean` (compiles cleanly; 0 `sorry`; axioms = `propext`, `Classical.choice`, `Quot.sound` only)

A from-scratch model theory for Priest's three-valued **Logic of Paradox** `LP` (values `ff`, `bb` = glut, `tt`; designated set `{bb, tt}`) and its minimally-inconsistent strengthening `LPm`, with a cross-domain bridge to idempotent (tropical-style) semiring algebra.

**Theorem declarations and status (all `proved` unless noted):**
1. `lem_valid` — excluded middle is LP-valid — case split on the value of `p`.
2. `lnc_valid` — non-contradiction is LP-valid (yet contradictions stay satisfiable).
3. `contradiction_satisfiable` — `p ∧ ¬p` is satisfiable at a glut.
4. `explosion_fails` — `p, ¬p ⊬ q` (LP is paraconsistent), via an explicit valuation.
5. `mp_fails` — material modus ponens fails.
6. `eval_ne_bb` / `classical_no_contradiction` — glut-free valuations reason classically (structural induction).
7. `entailsMin_Γ₁_q` — `LPm` derives `q` from `{p, p→q}` (every minimal model is glut-free).
8. `not_entailsMin_Γ₂_q` — `q` is retracted once `¬p` is added (forced-glut minimal model).
9. `retraction_nonmonotone` (centrepiece) — `Γ₁ ⊆ Γ₂` yet `entailsMin Γ₁ q` holds while `entailsMin Γ₂ q` fails: minimal consequence is genuinely non-monotone.
10. `commSemiring` — `(LP, disj, conj)` is a commutative semiring with units `(ff, tt)`; plus `add_idem`, `mul_idem` (idempotence = tropical/min-plus character), and `desig_mul`/`desig_add` showing `{bb, tt}` is a prime filter for `min`/`max`. This is the explicit bridge to the project's `Tropical/` domain.

The finite truth-table facts are discharged by exhaustive `decide` over the 3-element algebra; the substantive results (`eval_ne_bb`, `entailsMin_Γ₁_q`, the `gluts ⊂ gluts` minimality arguments, `retraction_nonmonotone`) use real structural induction and set-theoretic reasoning. Each theorem carries a brief `-- !-- … -- !--` proof-sketch comment.

### `FUTURE_DIRECTIONS.md`
Five falsifiable conjectures extending the work — sound/complete Hilbert calculus for `entails`, a verified decision procedure for `entailsMin`, a monotonicity boundary theorem, a Belnap four-valued bilattice extension, and tropical eigenvalues of belief-revision operators — each with an explicit "key insight" and "Why now?" justification, and each citing the relevant new lemmas it builds on.

Note: the file lives at `Logic/Paraconsistent.lean`, matching the build system's module layout (verified with a successful `lake build` of `Logic.Paraconsistent`).