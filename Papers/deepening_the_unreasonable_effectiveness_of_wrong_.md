# Computational Evidence — Wrong Theories Deepening

The results are theorems of abstract inner-product geometry (valid over *any*
real inner-product space), so the substance is a proof rather than a numerical
pattern. Nonetheless we sanity-check the two nontrivial constructions on small
explicit cases in `ℝ³` with the standard dot product.

## 1. Single-rival quantitative meta-theorem (`wrong_theory_beats_rival_quant`)

Take
```
truth = (0,0,0),  A = (1,0,0),  B = (1,1,0).
```
Then `a = A - truth = (1,0,0)`, `b = B - truth = (1,1,0)`.
- `⟪b,a⟫ = 1`, `⟪a,a⟫ = 1`, so `t = 1`.
- Orthogonal component `q = b - t·a = (0,1,0)`.

Check the phenomenon `u := q = (0,1,0)`:
- A's error there: `⟪a,u⟫ = ⟪(1,0,0),(0,1,0)⟫ = 0`  → `predErr truth A u = 0`. ✓
- B's error there: `⟪b,u⟫ = ⟪(1,1,0),(0,1,0)⟫ = 1 = ‖q‖² = 1`. ✓ and `> 0`. ✓

So the wrong theory `A` predicts phenomenon `u` exactly while the rival `B`
errs by exactly `‖q‖² = 1`, matching the theorem's explicit gap formula.

## 2. Beating several rivals at once (`wrong_theory_beats_finite_rivals`)

Take
```
truth = (0,0,0),  A = (1,0,0),
B₁ = (1,1,0),  B₂ = (1,0,1),  B₃ = (1,1,1).
```
`a = (1,0,0)`; none of `Bᵢ - truth` is a scalar multiple of `a` (each has a
nonzero 2nd or 3rd coordinate), so the hypotheses hold.

Orthogonalized rival errors (project out `a`):
```
q₁ = (0,1,0),  q₂ = (0,0,1),  q₃ = (0,1,1).
```
We seek a single `u ⊥ a` (i.e. `u = (0, y, z)`) with `⟪qᵢ,u⟫ ≠ 0` for all `i`:
`⟪q₁,u⟫ = y`, `⟪q₂,u⟫ = z`, `⟪q₃,u⟫ = y+z`. The construction in the proof
adjusts a running witness by small multiples avoiding the finitely many bad
scalars; e.g. `u = (0, 1, 2)` works: `y=1≠0`, `z=2≠0`, `y+z=3≠0`.

Check on `u = (0,1,2)`:
- `⟪a,u⟫ = 0` → `predErr truth A u = 0`. ✓
- `⟪B₁-truth,u⟫ = ⟪(1,1,0),(0,1,2)⟫ = 1 ≠ 0`. ✓
- `⟪B₂-truth,u⟫ = ⟪(1,0,1),(0,1,2)⟫ = 2 ≠ 0`. ✓
- `⟪B₃-truth,u⟫ = ⟪(1,1,1),(0,1,2)⟫ = 3 ≠ 0`. ✓

A single phenomenon on which the wrong theory `A` is exactly right while all
three rivals err — as the theorem guarantees.

## 3. Counterexample hunt (necessity of the hypotheses)

- If some rival error *is* parallel to `A`'s (`B = truth + r·(A-truth)`), then on
  every phenomenon `u ⊥ (A-truth)` both `A` and `B` are exact, so no such `u`
  can separate them — the non-parallel hypothesis is genuinely needed.
- If `A = truth` (not wrong), then `A` is exact on every phenomenon and the claim
  "`A` beats `B`" is vacuous/uninteresting; the `A ≠ truth` hypothesis pins down
  the intended content.

No counterexample to the stated theorems was found; the small cases agree with
the formal proofs.
