import Mathlib

/-!
# The Mega-Sphere II (Deepening): finite vs infinite, and the dual classes

This file deepens `MegaSphereStiefelWhitney.lean`.  Modelling the mod-`2`
cohomology ring `H*(ℝP^∞; 𝔽₂) ≅ 𝔽₂[w]` by `Polynomial (ZMod 2)` (with
`w = X`), we sharpen the comparison between the finite projective spaces `ℝP^n`
and the "mega" infinite one `ℝP^∞`.

Main results:

* `MegaSphereSWDeep.sw_not_nilpotent` — in `H*(ℝP^∞; 𝔽₂)` the class `w` is **not
  nilpotent**: every power `wⁿ ≠ 0`.  This is exactly what makes the mega-object
  infinite-dimensional.
* `MegaSphereSWDeep.sw_nilpotent_in_truncation` — by **contrast**, in the
  truncated ring modelling `H*(ℝP^n; 𝔽₂) ≅ 𝔽₂[w]/(w^{n+1})`, the class `w`
  **is** nilpotent.  This is the precise finite/infinite dichotomy.
* `MegaSphereSWDeep.sw_poincare` — the Poincaré count: the degree-`< n` part of
  the cohomology ring has `𝔽₂`-dimension exactly `n` (one class in each degree),
  i.e. the Poincaré series of `ℝP^∞` is `1/(1−t)`.
* `MegaSphereSWDeep.sw_frobenius_series` — the Frobenius/Whitney identity
  `(1 + w)^{2^k} = 1 + w^{2^k}` in the completed ring `𝔽₂⟦w⟧`.
* `MegaSphereSWDeep.dual_sw_all_one` — **the dual Stiefel–Whitney classes are all
  `1`**: any inverse of the total class `1 + w` in `𝔽₂⟦w⟧` has every coefficient
  equal to `1`.
-/

namespace MegaSphereSWDeep

open Polynomial PowerSeries

/-! ## Infinite ℝP^∞: `w` is not nilpotent -/

/--
**`w` is not nilpotent in `H*(ℝP^∞; 𝔽₂)`.**  Every Stiefel–Whitney power
`wⁿ` is nonzero, so the mega-object is genuinely infinite-dimensional.
-/
theorem sw_not_nilpotent : ¬ IsNilpotent (Polynomial.X : Polynomial (ZMod 2)) := by
  exact fun ⟨ n, hn ⟩ => absurd ( congr_arg ( Polynomial.eval 1 ) hn ) ( by norm_num )

/-! ## Finite ℝP^n: `w` is nilpotent -/

/--
**`w` is nilpotent in `H*(ℝP^n; 𝔽₂)`.**  In the truncated cohomology ring
`𝔽₂[w]/(w^{n+1})`, the image of `w` satisfies `w^{n+1} = 0`, hence is nilpotent.
This is the precise finite/infinite dichotomy of the mega-sphere story.
-/
theorem sw_nilpotent_in_truncation (n : ℕ) :
    IsNilpotent
      (Ideal.Quotient.mk
        (Ideal.span {(Polynomial.X : Polynomial (ZMod 2)) ^ (n + 1)})
        Polynomial.X) := by
  use n + 1;
  erw [ Ideal.Quotient.eq_zero_iff_mem ];
  exact Ideal.mem_span_singleton_self _

/-! ## The Poincaré count -/

/-
**The Poincaré count of `ℝP^∞`.**  The degree-`< n` part of the cohomology
ring `𝔽₂[w]` is `n`-dimensional over `𝔽₂`: exactly one Stiefel–Whitney class in
each degree, so the Poincaré series is `1 + t + t² + ⋯ = 1/(1−t)`.
-/
theorem sw_poincare (n : ℕ) :
    Module.finrank (ZMod 2) (Polynomial.degreeLT (ZMod 2) n) = n := by
  rw [ Module.finrank_eq_card_basis ( Polynomial.degreeLT.basis ( ZMod 2 ) n ) ];
  convert Fintype.card_fin n

/-! ## Frobenius/Whitney in the completed ring -/

/--
**Whitney–Frobenius identity in the mega ring.**  In `𝔽₂⟦w⟧` the total class
of the `2^k`-fold Whitney sum is `(1 + w)^{2^k} = 1 + w^{2^k}`.
-/
theorem sw_frobenius_series (k : ℕ) :
    ((1 : PowerSeries (ZMod 2)) + PowerSeries.X) ^ (2 ^ k)
      = 1 + PowerSeries.X ^ (2 ^ k) := by
  haveI : CharP (PowerSeries (ZMod 2)) 2 :=
    charP_of_injective_ringHom (PowerSeries.C_injective (R := ZMod 2)) 2
  rw [add_pow_char_pow, one_pow]

/-! ## The dual Stiefel–Whitney classes are all `1` -/

/-
**All dual Stiefel–Whitney classes equal `1`.**  If `y` inverts the total
Stiefel–Whitney class `1 + w` in the mega ring `𝔽₂⟦w⟧`, then every coefficient
of `y` (i.e. every dual class `w̄ₖ`) equals `1`.  Equivalently `(1+w)⁻¹ = ∑ wᵏ`.
-/
theorem dual_sw_all_one (y : PowerSeries (ZMod 2))
    (hy : (1 + PowerSeries.X) * y = 1) (k : ℕ) :
    (PowerSeries.coeff (R := ZMod 2) k) y = 1 := by
  induction' k with k ih <;> simp_all +decide [ add_mul ];
  · simpa using congr_arg ( PowerSeries.constantCoeff ) hy;
  · replace hy := congr_arg ( fun f => PowerSeries.coeff ( k + 1 ) f ) hy ; simp_all +decide;
    grind

end MegaSphereSWDeep