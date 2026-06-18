# Summary of changes
I formalized and machine-verified the core mathematical claims of the "Universal Solver" in Lean 4, creating `Stereographic/DualProjection.lean`. All 8 theorems are proved without `sorry` and verified by the Lean compiler with only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

### What was proved

1. **`inverse_stereo_south_on_sphere`** — The inverse stereographic projection from the south pole maps ℝ onto the unit circle: `(2t/(1+t²))² + ((1-t²)/(1+t²))² = 1`.

2. **`inv_stereo_south_y_ne_one`** — When `t ≠ 0`, the image of `σ_S⁻¹(t)` avoids the north pole (so the forward projection is well-defined).

3. **`dual_proj_denom_ne_zero`** — The denominator of the composed map is nonzero when `t ≠ 0`.

4. **`dual_projection_eq_inv`** ⭐ — **The central claim**: the dual projection `D(t) = σ_N(σ_S⁻¹(t)) = 1/t` for all `t ≠ 0`.

5. **`dual_projection_mobius`** — The dual projection equals the Möbius transformation with matrix `[[0,1],[1,0]]`, confirming the "single matrix multiplication" architecture.

6. **`dual_projection_involution`** — `D(D(t)) = t`: the dual projection is a self-inverse involution.

7. **`mobius_inv_involution`** — The Möbius matrix `[[0,1],[1,0]]` squares to the identity.

8. **`projection_idempotent`** — For any idempotent matrix `P` (with `P² = P`), `P(P(v)) = P(v)` — formalizing the "oracle projection" idempotency property.

These results rigorously confirm that the stereographic lift-and-project architecture reduces to Möbius inversion `t ↦ 1/t` in the 1D case.