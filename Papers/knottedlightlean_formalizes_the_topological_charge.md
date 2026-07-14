# Computational Evidence — General Winding Number of Knotted Light

This cycle extends `KnottedLight.lean` from the single phase field `exp(iℓθ)` to an
*arbitrary* smooth non-vanishing loop `γ : ℝ → ℂ \ {0}`. The central claim is the
integrality theorem `ℤ = π₁(ℂ*)`: the contour-integral winding number

    w(γ) = (1 / 2πi) ∮₀^{2π} γ'(θ)/γ(θ) dθ

is an integer for every closed loop, is additive under pointwise multiplication,
negates under inversion, and is surjective onto ℤ.

## 1. Small-case sanity checks (the OAM family)

For `γ = oamPhase ℓ = exp(iℓθ)`, `γ'/γ = iℓ` is constant, so
`w = (1/2πi)·(iℓ·2π) = ℓ`. Concrete values:

| ℓ  | ∮ γ'/γ        | w(γ) |
|----|---------------|------|
| -2 | -2·2πi        | -2   |
| -1 | -1·2πi        | -1   |
|  0 | 0             |  0   |
|  1 | 1·2πi         |  1   |
|  3 | 3·2πi         |  3   |

This matches `winding_oamPhase` and shows surjectivity onto ℤ (`winding_surjective`).

## 2. Additivity / multiplicativity

For `γ = exp(iℓθ)`, `δ = exp(imθ)`, the product is `exp(i(ℓ+m)θ)`:
`w(γ·δ) = ℓ+m = w(γ)+w(δ)`. Verified in general (`winding_mul`), not just for OAM,
since `(γδ)'/(γδ) = γ'/γ + δ'/δ` pointwise and the integral is linear.

Inversion: `w(1/γ) = -w(γ)` because `(1/γ)'/(1/γ) = -γ'/γ` (`winding_inv`).

## 3. Counterexample hunt (contrarian claims)

- **"Winding is additive under pointwise addition of fields."** FALSE. Adding a
  beam to itself: `exp(iθ) + exp(iθ) = 2·exp(iθ)`. The scalar `2` cancels in
  `γ'/γ`, so `w = 1`, not `1+1 = 2`. Disproved in `winding_not_additive_under_sum`.
  (More generally winding is a homomorphism `(loops,·) → (ℤ,+)`, not `(loops,+)`.)

- **"Rescaling the amplitude changes the charge."** FALSE. `w(c·γ) = w(γ)` for
  every nonzero constant `c` (`winding_scale_invariant`); the charge is a
  topological, amplitude-independent invariant.

## 4. Why integrality holds (the mechanism, tested symbolically)

Set `G(θ) = ∫₀^θ γ'/γ`. Then `F(θ) = γ(θ)·exp(-G(θ))` has `F' ≡ 0`, hence is
constant. For a closed loop `γ(2π)=γ(0)` this forces `exp(-G(2π)) = 1`, so
`G(2π) ∈ 2πi·ℤ` and `w(γ) = G(2π)/(2πi) ∈ ℤ`. This is exactly the Lean proof of
`winding_integer`. It is the honest reason the topological charge is quantized:
single-valuedness of the field, not an assumption.

## Notes on OEIS / sequences

The realised charges are simply ℤ (surjectivity), so no nontrivial integer
sequence arises; the content is the *integrality + homomorphism* structure rather
than an enumeration. The evidence stage is therefore intentionally brief.
