# Future Directions — Inverse Stereographic Renormalization Group

## Synthesis

This cycle formalized the slogan *"RG flow = iterated inverse stereographic
projection on the energy sphere"* as a precise, machine-checked statement. The
energy line `ℝ` is wrapped onto the unit circle `S¹` by inverse stereographic
projection `invStereo`, and the renormalization-group dilation `t ↦ λ·t` is
transported through this wrapping into the circle flow `rgFlow λ`. The core
discovery is conceptual rather than computational: *the renormalization group is
an abelian one-parameter (semi)group precisely because it is conjugate to scalar
multiplication on a line*, and stereographic projection makes this conjugacy
geometric.

The seven theorems form a tight conceptual unit. `invStereo_on_circle` places
the flow on the energy sphere; `stereoProj_invStereo` and `invStereo_injective`
show a single RG step loses no information; `rgFlow_invStereo` is the conjugacy
identity; `rgFlow_semigroup` and `rgFlow_iterate` give the group/iteration law
(`(rgFlow λ)^[n] = scale by λⁿ`); and `rgFlow_uv_fixed` together with
`invStereo_tendsto_IR` pin down the UV fixed point `(0,1)` as an exact equation
and the IR fixed point `(0,-1)` as a genuine boundary limit. The sharpest insight
is that **RG irreversibility lives only in the iterated asymptotics** `λⁿ → 0/∞`,
not in the maps, each of which is a bijection.

## Results Summary

- `invStereo_on_circle` — image lies on `S¹` (energy sphere).
- `stereoProj_invStereo`, `invStereo_injective` — exact one-step reversibility.
- `rgFlow_invStereo` — conjugacy: the circle flow scales the energy parameter.
- `rgFlow_on_circle` — the flow preserves the energy sphere.
- `rgFlow_semigroup` — the RG flow is an abelian semigroup: `λ₁ ∘ λ₂ = λ₁λ₂`.
- `rgFlow_iterate` — **main result**: `(rgFlow λ)^[n] (invStereo t) = invStereo (λⁿ·t)`.
- `rgFlow_uv_fixed`, `invStereo_tendsto_IR` — UV `(0,1)` and IR `(0,-1)` fixed points.

## Research Directions

1. **Continuous RG flow and the beta function.** Replace the discrete scale `λ`
   by a continuous parameter `λ = e^s` and prove that `s ↦ rgFlow (e^s)` is a
   smooth one-parameter group whose generator (the velocity vector field on `S¹`)
   is exactly the RG **beta function** `β(t) = t` pulled back from the line.
   *The key insight is* that the abelian semigroup law `rgFlow_semigroup` upgrades
   to a flow `ℝ → Diffeo(S¹)` whose infinitesimal generator is the pushforward of
   the Euler vector field `t ∂_t` under `invStereo`. *Why now?* We already have the
   exact conjugacy `rgFlow_invStereo`; differentiating it in `λ` at `λ=1` is a
   finite calculation, and Mathlib's `Filter`/`deriv` API (used in
   `invStereo_tendsto_IR`) suffices to define and compute the generator. This is
   falsifiable: compute `deriv (fun s => (rgFlow (Real.exp s) p).1) 0` and check it
   equals the predicted tangent component.

2. **Möbius enrichment: full conformal group on the circle.** The dilation is one
   element of `PSL(2,ℝ)` acting on `ℝ ∪ {∞}`; conjugating *every* Möbius map by
   `invStereo` should give the full conformal action on `S¹`, with `rgFlow` as the
   diagonal/hyperbolic one-parameter subgroup. *The key insight is* that RG flow,
   translations, and special conformal transformations are the three standard
   one-parameter subgroups of `PSL(2,ℝ)`, and stereographic conjugacy turns the
   group law into matrix multiplication. *Why now?* The catalog already contains
   `mobius_det_condition` and `mobius_compose_det` (SL(2) group law) in
   `InverseStereoResearch`; bridging them to `rgFlow_semigroup` unifies two
   separately stated catalog facts into one homomorphism `PSL(2,ℝ) → Diffeo(S¹)`.
   Falsifiable: exhibit the explicit `2×2` matrix whose Möbius action equals
   `rgFlow λ` and verify `rgFlow_semigroup` is its `det`-preserving product.

3. **Higher-dimensional RG on `Sⁿ` and anisotropic scaling.** Generalize from the
   circle to `Sⁿ` using the catalog's `invStereoN` (in `ConformalPersistence`),
   replacing the scalar dilation by a diagonal matrix `diag(λ₁,…,λₙ)` of mode-wise
   RG rescalings. *The key insight is* that anisotropic (mode-dependent) RG flows
   are conjugate to commuting diagonal dilations, so the `n`-torus of scales acts
   on `Sⁿ` with `2` fixed points (poles) and the flow `rgFlowN` still satisfies an
   iterate law `(rgFlowN Λ)^[k] = invStereoN ∘ (Λ^k ·) ∘ stereoProjN`. *Why now?*
   `invStereoN_on_sphere` is already available, so the `Sⁿ` analogue of
   `invStereo_on_circle` is free; only the conjugacy and iterate lemmas need new
   proofs, mirroring the 1-D ones here. Falsifiable: for `n=2`, `λ₁≠λ₂`, check the
   trajectory does NOT stay on a great circle (anisotropy is detectable).

4. **Quantitative irreversibility / monotone (c-theorem analogue).** Build an
   explicit monotone "RG height" function `c : S¹ → ℝ` that strictly decreases
   along every non-fixed trajectory toward the IR pole, e.g. `c(p) = stereoProj p`
   composed with `log`, and prove `c (rgFlow λ p) < c p` for `0 < λ < 1`, `p` not a
   pole. *The key insight is* that the abelian flow on a line trivially admits the
   Lyapunov function `|t|`, and pushing it to `S¹` gives a Zamolodchikov-style
   monotone certifying irreversibility *without* contradicting step-wise
   bijectivity. *Why now?* `invStereo_tendsto_IR` already proves convergence to the
   IR pole; a monotone strengthens "converges" to "monotonically flows," which is
   the precise content of a c-theorem. Falsifiable: search for any `λ<1` and `p`
   with `c (rgFlow λ p) ≥ c p` — the conjecture predicts none exist off the poles.

5. **Arithmetic RG: rational fixed points and the prime spectrum of scales.** When
   `t` and `λ` are rational, `invStereo` lands on rational points of `S¹`
   (Euclid/Pythagorean parametrization, cf. catalog `euclid_pythagorean_from_stereo`),
   so iterating `rgFlow (p/q)` generates an orbit of Pythagorean triples indexed by
   `(p/q)ⁿ`. *The key insight is* that the multiplicative structure of the rational
   scale `λ = p/q` (its prime factorization) is exactly mirrored in the arithmetic
   of the resulting triples, linking the RG semigroup to the multiplicative monoid
   `ℚ⁺` and hence to the prime spectrum. *Why now?* `rgFlow_iterate` already gives
   the orbit `invStereo(λⁿ t)` in closed form, and the catalog's Pythagorean
   theorems provide the triple machinery; combining them is a cross-domain bridge
   (number theory ↔ geometry ↔ physics). Falsifiable: predict and verify the exact
   denominator `pⁿ·q^? ` growth of the `n`-th triple in a rational RG orbit.
