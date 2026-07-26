import Mathlib

/-!
# Balanced flat tori are the unique isoperimetric flat tori on odd spheres

This file addresses **Conjecture 2** of the "Composition-Algebra Playground"
research direction.

A flat `m`-torus embedded in `S^{2m-1} ⊆ ℂ^m` is parametrised by a vector of
radii `r : Fin m → ℝ`, `rᵢ ≥ 0`, subject to the sphere constraint
`∑ rᵢ² = 1`.  The induced Riemannian volume of the torus is proportional to the
product of the circle circumferences, i.e. to `∏ rᵢ`.

We prove, **for every dimension `m` simultaneously**, that:

* `sq_prod_le_pow` : the elementary symmetric product of the squared radii
  satisfies `∏ rᵢ² ≤ (1/m)^m`;
* `prod_le_rpow` : consequently `∏ rᵢ ≤ m^(-m/2)`, the announced growth rate;
* `balanced_eq` : the balanced torus `rᵢ² = 1/m` attains the bound;
* `prod_eq_iff` : equality holds **iff** the torus is balanced (uniqueness).

The engine is the `m`-variable arithmetic–geometric mean inequality
(`Real.geom_mean_le_arith_mean_weighted`) together with its equality case
(`Real.geom_mean_eq_arith_mean_weighted_iff`).
-/

open Finset

namespace BalancedTorus

variable {m : ℕ}

/--
**AM–GM for the squared radii.**  If nonnegative numbers `s i` sum to `1`,
their product is at most `(1/m)^m`.  Applied with `s i = rᵢ²` this bounds the
elementary symmetric product of squared radii of any flat torus on `S^{2m-1}`.
-/
theorem prod_le_pow (hm : 0 < m) (s : Fin m → ℝ) (hs : ∀ i, 0 ≤ s i)
    (hsum : ∑ i, s i = 1) : ∏ i, s i ≤ (1 / m) ^ m := by
  -- By the AM-GM inequality, we have $\frac{s_0 + s_1 + \cdots + s_{m-1}}{m} \geq \sqrt[m]{s_0 s_1 \cdots s_{m-1}}$.
  have h_am_gm : (∑ i, s i) / m ≥ (∏ i, s i) ^ (1 / m : ℝ) := by
    have := @Real.geom_mean_le_arith_mean;
    simpa [ hsum, hm.ne' ] using this Finset.univ ( fun _i => 1 ) s ( fun _ _ => zero_le_one ) ( by simpa using hm ) ( fun _ _ => hs _ );
  exact le_trans ( by rw [ ← Real.rpow_natCast, ← Real.rpow_mul ( Finset.prod_nonneg fun _ _ => hs _ ), one_div_mul_cancel ( by positivity ), Real.rpow_one ] ) ( pow_le_pow_left₀ ( Real.rpow_nonneg ( Finset.prod_nonneg fun _ _ => hs _ ) _ ) ( h_am_gm.trans ( by rw [ hsum ] ) ) _ )

/--
**Equality/uniqueness case.**  For nonnegative `s` summing to `1`, the
product equals the maximum `(1/m)^m` iff the configuration is balanced,
`s i = 1/m` for every `i`.
-/
theorem prod_eq_iff (hm : 0 < m) (s : Fin m → ℝ) (hs : ∀ i, 0 ≤ s i)
    (hsum : ∑ i, s i = 1) : (∏ i, s i = (1 / m) ^ m) ↔ ∀ i, s i = 1 / m := by
  have h_geom_mean_eq_arith_mean_weighted_iff : (∏ i, (s i) ^ (1 / m : ℝ)) = (∑ i, (1 / m : ℝ) * s i) ↔ ∀ j, s j = (∑ i, (1 / m : ℝ) * s i) := by
    convert Real.geom_mean_eq_arith_mean_weighted_iff Finset.univ ( fun _ => ( 1 : ℝ ) / m ) s _ _ _ using 1 <;> norm_num [ hm.ne' ];
    assumption;
  rw [ Real.finset_prod_rpow _ _ fun i _ => hs i ] at h_geom_mean_eq_arith_mean_weighted_iff;
  convert h_geom_mean_eq_arith_mean_weighted_iff using 1 <;> norm_num [ ← Finset.mul_sum _ _ _, hsum ];
  constructor <;> intro h <;> have := congr_arg ( · ^ m ) h <;> norm_num at this;
  · rw [ h, Real.inv_rpow ( by positivity ), ← Real.rpow_natCast, ← Real.rpow_mul ( by positivity ), mul_inv_cancel₀ ( by positivity ), Real.rpow_one ];
  · rw [ ← this, ← Real.rpow_natCast, ← Real.rpow_mul ( Finset.prod_nonneg fun _ _ => hs _ ), inv_mul_cancel₀ ( by positivity ), Real.rpow_one ]

/-- **Squared-radius bound for a flat torus.**  Radii `r i ≥ 0` with
`∑ rᵢ² = 1` satisfy `∏ rᵢ² ≤ (1/m)^m`. -/
theorem sq_prod_le_pow (hm : 0 < m) (r : Fin m → ℝ)
    (hsum : ∑ i, r i ^ 2 = 1) : ∏ i, r i ^ 2 ≤ (1 / m) ^ m :=
  prod_le_pow hm (fun i => r i ^ 2) (fun _ => sq_nonneg _) hsum

/--
**Volume bound with the announced `m^{-m/2}` growth.**  The product of the
radii — proportional to the induced volume of the flat torus — is at most
`m^(-(m:ℝ)/2)`.
-/
theorem prod_le_rpow (hm : 0 < m) (r : Fin m → ℝ) (hr : ∀ i, 0 ≤ r i)
    (hsum : ∑ i, r i ^ 2 = 1) : ∏ i, r i ≤ (m : ℝ) ^ (-(m : ℝ) / 2) := by
  convert Real.sqrt_le_sqrt ( sq_prod_le_pow hm r hsum ) using 1;
  · rw [ Finset.prod_pow, Real.sqrt_sq ( Finset.prod_nonneg fun _ _ => hr _ ) ];
  · rw [ Real.sqrt_eq_rpow, ← Real.rpow_natCast, ← Real.rpow_mul ] <;> norm_num [ hm.ne' ];
    rw [ Real.inv_rpow ( by positivity ), ← Real.rpow_neg ( by positivity ) ] ; congr 1 ; ring

/--
**The balanced torus attains the maximum.**  With `rᵢ² = 1/m` we have
`∑ rᵢ² = 1` and `∏ rᵢ² = (1/m)^m`.
-/
theorem balanced_eq (hm : 0 < m) :
    (∑ _i : Fin m, ((1 : ℝ) / m) = 1) ∧ (∏ _i : Fin m, ((1 : ℝ) / m) = (1 / m) ^ m) := by
  norm_num [ hm.ne' ]

end BalancedTorus