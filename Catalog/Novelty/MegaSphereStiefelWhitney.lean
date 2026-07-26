import Mathlib

/-!
# The Mega-Sphere II: The cohomology ring and Stiefel–Whitney classes

The infinite real projective space `ℝP^∞` is the classifying space `BO(1)` of
real line bundles, and it is the natural "all dimensions at once" home of the
tautological line bundle `L`.  Its mod-`2` cohomology ring is the polynomial
ring on the first Stiefel–Whitney class `w = w₁(L)`:

  `H*(ℝP^∞; 𝔽₂) ≅ 𝔽₂[w]`.

This file takes that polynomial ring as the algebraic model of the cohomology
ring and proves genuine ring-theoretic incarnations of characteristic-class
identities, working over `𝔽₂ = ZMod 2`.  Write `w := X` for the degree-`1`
generator (the universal Stiefel–Whitney class).

Main results:

* `MegaSphereSW.sw_basis` — the powers `wⁿ = w₁ⁿ` are `𝔽₂`-linearly independent,
  i.e. the cohomology ring is a free module with exactly one generator in each
  degree.  This is `Hⁿ(ℝP^∞;𝔽₂) ≅ 𝔽₂` for every `n`.
* `MegaSphereSW.sw_whitney_frobenius` — the Frobenius/Whitney identity
  `(1 + w)^{2^k} = 1 + w^{2^k}`: the total Stiefel–Whitney class of the
  `2^k`-fold Whitney sum `L^{⊕2^k}` is `1 + w^{2^k}`.
* `MegaSphereSW.sw_not_isUnit` — the total class `1 + w` is **not** a unit in the
  polynomial (finite-dimensional truncated) cohomology ring.
* `MegaSphereSW.dual_sw_series` — but after completing to power series (the mega
  ring `𝔽₂⟦w⟧`), `1 + w` **becomes** a unit, with inverse the geometric series
  `∑ wᵏ`; its coefficients are the *dual* Stiefel–Whitney classes `w̄ₖ = wᵏ`,
  all equal to `1`.
* `MegaSphereSW.sw_isUnit_completion` — hence `1 + w` is a unit in `𝔽₂⟦w⟧`.
-/

namespace MegaSphereSW

open Polynomial PowerSeries

/-- The universal (first) Stiefel–Whitney class `w`, modelled as the degree-`1`
generator of the cohomology ring `𝔽₂[w]`. -/
noncomputable abbrev w : Polynomial (ZMod 2) := Polynomial.X

/-! ## The graded structure: one class in each degree -/

/-- The monomial basis vector `basisMonomials n` is literally `wⁿ`. -/
theorem basisMonomials_eq_pow (n : ℕ) :
    (Polynomial.basisMonomials (ZMod 2)) n = Polynomial.X ^ n := by
  rw [Polynomial.basisMonomials, Polynomial.X_pow_eq_monomial]; rfl

/-- **The graded cohomology of `ℝP^∞`.**  The Stiefel–Whitney monomials `wⁿ`
form an `𝔽₂`-basis of the cohomology ring: it is free with exactly one generator
in each degree `n`, i.e. `Hⁿ(ℝP^∞; 𝔽₂) ≅ 𝔽₂`. -/
theorem sw_basis :
    LinearIndependent (ZMod 2) (fun n : ℕ => (Polynomial.X : Polynomial (ZMod 2)) ^ n) := by
  have hb := (Polynomial.basisMonomials (ZMod 2)).linearIndependent
  have hfun : (fun n : ℕ => (Polynomial.X : Polynomial (ZMod 2)) ^ n)
      = fun n => (Polynomial.basisMonomials (ZMod 2)) n := by
    funext n; rw [basisMonomials_eq_pow]
  rw [hfun]; exact hb

/-- Each cohomology group `Hⁿ(ℝP^∞; 𝔽₂)` is nonzero: the class `wⁿ ≠ 0`. -/
theorem sw_pow_ne_zero (n : ℕ) : (Polynomial.X : Polynomial (ZMod 2)) ^ n ≠ 0 :=
  pow_ne_zero n Polynomial.X_ne_zero

/-! ## The Whitney / Frobenius identity -/

/-- **Whitney–Frobenius identity.**  In characteristic `2` the total
Stiefel–Whitney class of the `2^k`-fold Whitney sum `L^{⊕2^k}` is
`(1 + w)^{2^k} = 1 + w^{2^k}`. -/
theorem sw_whitney_frobenius (k : ℕ) :
    ((1 : Polynomial (ZMod 2)) + Polynomial.X) ^ (2 ^ k)
      = 1 + Polynomial.X ^ (2 ^ k) := by
  rw [add_pow_char_pow, one_pow]

/-- The special case `k = 1`: `(1 + w)² = 1 + w²`. -/
theorem sw_square : ((1 : Polynomial (ZMod 2)) + Polynomial.X) ^ 2 = 1 + Polynomial.X ^ 2 := by
  simpa using sw_whitney_frobenius 1

/-! ## The total class is not a unit before completion -/

/-- **The total Stiefel–Whitney class is not invertible in the (truncated,
finite-dimensional) cohomology ring.**  In `𝔽₂[w]` the class `1 + w` has degree
`1`, so it is not a unit. -/
theorem sw_not_isUnit : ¬ IsUnit ((1 : Polynomial (ZMod 2)) + Polynomial.X) := by
  intro hu
  have hdeg : (1 + Polynomial.X : Polynomial (ZMod 2)).natDegree = 0 :=
    Polynomial.natDegree_eq_zero_of_isUnit hu
  have : (1 + Polynomial.X : Polynomial (ZMod 2)).natDegree = 1 := by
    compute_degree!
  omega

/-! ## The mega ring: completing to power series -/

/-- The universal class as an element of the completed cohomology ring
`𝔽₂⟦w⟧`. -/
noncomputable abbrev wSeries : PowerSeries (ZMod 2) := PowerSeries.X

/-- The dual Stiefel–Whitney series `w̄ = ∑ₖ wᵏ`, the formal geometric series. -/
noncomputable def dualSWSeries : PowerSeries (ZMod 2) := PowerSeries.mk (fun _ => 1)

/-- Every dual Stiefel–Whitney class is nonzero: `w̄ₖ = 1` for all `k`. -/
theorem dualSW_coeff (k : ℕ) :
    (PowerSeries.coeff (R := ZMod 2) k) dualSWSeries = 1 := by
  rw [dualSWSeries, PowerSeries.coeff_mk]

/-- **The dual Stiefel–Whitney series inverts the total class.**  In the mega
ring `𝔽₂⟦w⟧`, the total Stiefel–Whitney class `1 + w` times the dual series
`∑ wᵏ` equals `1`.  (Telescoping in characteristic `2`.) -/
theorem dual_sw_series :
    (1 + wSeries) * dualSWSeries = 1 := by
  rw [dualSWSeries, wSeries]
  have h := PowerSeries.mk_one_mul_one_sub_eq_one (ZMod 2)
  have hm1 : (-1 : PowerSeries (ZMod 2)) = 1 := by
    have h2 : ((-1 : ZMod 2)) = (1 : ZMod 2) := by decide
    have hh : (PowerSeries.C (R := ZMod 2)) ((-1 : ZMod 2))
        = (PowerSeries.C (R := ZMod 2)) (1 : ZMod 2) := by rw [h2]
    rw [map_neg, map_one] at hh
    exact hh
  have hnegX : (-(PowerSeries.X : PowerSeries (ZMod 2))) = PowerSeries.X := by
    rw [← neg_one_mul, hm1, one_mul]
  have he : (1 - (PowerSeries.X : PowerSeries (ZMod 2))) = 1 + PowerSeries.X := by
    rw [sub_eq_add_neg, hnegX]
  rw [mul_comm, ← he]
  exact h

/-- **The total class becomes a unit after completion.**  In the mega ring
`𝔽₂⟦w⟧`, unlike in the truncated ring `𝔽₂[w]`, the total Stiefel–Whitney class
`1 + w` is invertible. -/
theorem sw_isUnit_completion : IsUnit ((1 : PowerSeries (ZMod 2)) + wSeries) :=
  IsUnit.of_mul_eq_one _ dual_sw_series

end MegaSphereSW