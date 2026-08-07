import Geometry.HyperbolicBerggrenGeodesics

/-!
# Hyperbolic–Pythagorean Geodesics, cycle II

This file is the second research cycle built on
`Geometry.HyperbolicBerggrenGeodesics`.  It closes three of the open sub-conjectures
recorded at the end of that cycle and adds a genuinely new arithmetic pay-off.

## Main results

* `cosh_half_log`, `dist_ge_half_log_hypotenuse`, `dist_le_half_log_two_hypotenuse`,
  `trajectory_window` : **the sharpened logarithmic trajectory law.**  The previous
  cycle proved `|d - ½ log c| ≤ log 2`.  Here the two sides are separated and both are
  improved to the truth: the *lower* bound holds with **no additive constant at all**,
  `d ≥ ½ log c`, and the upper bound is `d ≤ ½ log (2 (c+1)) ≤ ½ log c + ½ log 2 + 1/(2c)`.
  So every Berggren node lies in the half-open annulus
  `½ log c ≤ d < ½ log c + ½ log 2 + o(1)` of width `½ log 2 ≈ 0.3466`, which matches the
  numerically observed residual range `[0.157, 0.30]`.
* `hpoint_injective`, `seed_point_injective` : distinct Euclid seeds give distinct
  points of `ℍ`, so the node count of the previous cycle is an honest point count.
* `vertGeodesic_energy`, `energy_lower_bound_sharp` : **the Cauchy–Schwarz energy bound
  is sharp** (sub-conjecture C3-lite).  For every `k > 0` and every displacement `t ≥ 0`
  there is a `k`-step trajectory with `dist (z 0) (z k) = t` and
  `pathEnergy z k = t²/k` exactly.
* `euler_gcd_product` : **a collision computes a complete splitting, not just one
  divisor.**  If `N` is odd and `N = a²+b² = c²+d²` with both representations primitive,
  then `gcd(N, ac+bd) · gcd(N, ad+bc) = N`.
* `berggren_collision_splits` : consequently two distinct Berggren nodes with the same
  hypotenuse `N` split `N = g · h` with `1 < g, h < N`; both factors are produced at once
  by the geometry.
* `exists_collision_gt`, `collision_hypotenuses_infinite` : **collisions exist at every
  scale.**  An explicit two-parameter family of colliding seed pairs
  `(20j+9, 10j+2)` and `(20j+7, 10j+6)`, both with hypotenuse `500j² + 400j + 85`, shows
  the set of hypotenuses carried by two distinct Berggren nodes is infinite, and the
  divisor extracted from the collision is computed exactly: it equals `5`.
-/

namespace HyperbolicBerggrenGeodesics

open Real UpperHalfPlane

noncomputable section

/-! ## Part A. The sharpened logarithmic trajectory law -/

/-- `cosh (½ log c) = (c+1)/(2√c)` for `c > 0`: the level sets of the hyperbolic distance
from `i` are exactly the level sets of `(c+1)/(2m)`. -/
theorem cosh_half_log {c : ℝ} (hc : 0 < c) :
    Real.cosh ((1 / 2) * Real.log c) = (c + 1) / (2 * Real.sqrt c) := by
  have hsq : Real.sqrt c = Real.exp ((1 / 2) * Real.log c) := by
    rw [Real.sqrt_eq_rpow, Real.rpow_def_of_pos hc]
    ring_nf
  have hspos : 0 < Real.sqrt c := Real.sqrt_pos.2 hc
  have hss : Real.sqrt c * Real.sqrt c = c := Real.mul_self_sqrt hc.le
  rw [Real.cosh_eq, ← hsq, Real.exp_neg, ← hsq]
  field_simp
  linarith [hss]

/-- **Sharp lower bound (no additive constant).**  Every Berggren node with hypotenuse
`c = m² + n²` lies at hyperbolic distance *at least* `½ log c` from the base point `i`.
The bound is attained only in the degenerate limit `n = 0`. -/
theorem dist_ge_half_log_hypotenuse {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    (1 / 2) * Real.log ((m : ℝ) ^ 2 + (n : ℝ) ^ 2) ≤
      dist (hpoint m n (lt_trans hn hnm)) UpperHalfPlane.I := by
  have hm : 0 < m := lt_trans hn hnm
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hN : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  set c : ℝ := (m : ℝ) ^ 2 + (n : ℝ) ^ 2 with hcdef
  have hcpos : 0 < c := by positivity
  set d := dist (hpoint m n hm) UpperHalfPlane.I with hd
  have hd0 : 0 ≤ d := dist_nonneg
  have hcosh : Real.cosh d = (c + 1) / (2 * m) := by rw [hd, cosh_dist_hpoint_I]
  -- `m ≤ √c`
  have hsq : Real.sqrt c ≥ (m : ℝ) := by
    rw [show (m : ℝ) = Real.sqrt ((m : ℝ) ^ 2) from (Real.sqrt_sq hM.le).symm]
    exact Real.sqrt_le_sqrt (by nlinarith)
  have hspos : 0 < Real.sqrt c := Real.sqrt_pos.2 hcpos
  have hkey : Real.cosh ((1 / 2) * Real.log c) ≤ Real.cosh d := by
    rw [cosh_half_log hcpos, hcosh]
    apply div_le_div_of_nonneg_left (by positivity) (by positivity)
    linarith
  have := (Real.cosh_le_cosh).1 hkey
  calc (1 / 2) * Real.log c ≤ |(1 / 2) * Real.log c| := le_abs_self _
    _ ≤ |d| := this
    _ = d := abs_of_nonneg hd0

/-- **Sharp upper bound.**  The distance never exceeds `½ log (2 (c+1))`. -/
theorem dist_le_half_log_two_hypotenuse {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    dist (hpoint m n (lt_trans hn hnm)) UpperHalfPlane.I ≤
      (1 / 2) * Real.log (2 * (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) + 1)) := by
  have hm : 0 < m := lt_trans hn hnm
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hN : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hmn : (n : ℝ) + 1 ≤ (m : ℝ) := by exact_mod_cast hnm
  set c : ℝ := (m : ℝ) ^ 2 + (n : ℝ) ^ 2 with hcdef
  have hcpos : 0 < c := by positivity
  set d := dist (hpoint m n hm) UpperHalfPlane.I with hd
  have hd0 : 0 ≤ d := dist_nonneg
  have hcosh : Real.cosh d = (c + 1) / (2 * m) := by rw [hd, cosh_dist_hpoint_I]
  obtain ⟨-, hhigh⟩ := log_cosh_sandwich hd0
  have h2c : 2 * Real.cosh d = (c + 1) / (m : ℝ) := by rw [hcosh]; field_simp
  -- `2 m² ≥ c + 1`, hence `((c+1)/m)² ≤ 2 (c+1)`
  have hm2 : c + 1 ≤ 2 * (m : ℝ) ^ 2 := by nlinarith
  have hkey : ((c + 1) / (m : ℝ)) ^ 2 ≤ 2 * (c + 1) := by
    rw [div_pow, div_le_iff₀ (by positivity)]
    nlinarith
  have hpos : (0 : ℝ) < (c + 1) / (m : ℝ) := by positivity
  have hlog : Real.log ((c + 1) / (m : ℝ)) ≤ (1 / 2) * Real.log (2 * (c + 1)) := by
    have h1 : Real.log (((c + 1) / (m : ℝ)) ^ 2) ≤ Real.log (2 * (c + 1)) :=
      Real.log_le_log (by positivity) hkey
    rw [Real.log_pow] at h1
    push_cast at h1
    linarith
  rw [h2c] at hhigh
  linarith

/-- **The trajectory window.**  Combining the two sharp bounds: the residual
`d - ½ log c` of every Berggren node lies in `[0, ½ log 2 + 1/(2c)]`, a window of width
`½ log 2 + o(1) ≈ 0.347`, half the width proved in the first cycle. -/
theorem trajectory_window {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    0 ≤ dist (hpoint m n (lt_trans hn hnm)) UpperHalfPlane.I -
        (1 / 2) * Real.log ((m : ℝ) ^ 2 + (n : ℝ) ^ 2) ∧
      dist (hpoint m n (lt_trans hn hnm)) UpperHalfPlane.I -
        (1 / 2) * Real.log ((m : ℝ) ^ 2 + (n : ℝ) ^ 2)
        ≤ (1 / 2) * Real.log 2 + 1 / (2 * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2)) := by
  have hM : (0 : ℝ) < (m : ℝ) := by
    exact_mod_cast lt_trans hn hnm
  set c : ℝ := (m : ℝ) ^ 2 + (n : ℝ) ^ 2 with hcdef
  have hcpos : 0 < c := by positivity
  refine ⟨by linarith [dist_ge_half_log_hypotenuse hn hnm], ?_⟩
  have hup := dist_le_half_log_two_hypotenuse hn hnm
  -- `½ log (2 (c+1)) = ½ log 2 + ½ log c + ½ log ((c+1)/c) ≤ ½ log 2 + ½ log c + 1/(2c)`
  have hsplit : Real.log (2 * (c + 1)) = Real.log 2 + Real.log c + Real.log ((c + 1) / c) := by
    rw [Real.log_mul (by norm_num) (by positivity), Real.log_div (by positivity) (by positivity)]
    ring
  have hlog1 : Real.log ((c + 1) / c) ≤ 1 / c := by
    have := Real.log_le_sub_one_of_pos (show (0 : ℝ) < (c + 1) / c by positivity)
    have hc : (c + 1) / c - 1 = 1 / c := by
      field_simp
      linarith
    linarith [hc ▸ this]
  rw [hsplit] at hup
  have : (1 : ℝ) / (2 * c) = (1 / 2) * (1 / c) := by
    rw [← div_div, div_eq_mul_one_div]
  linarith

/-! ## Part B. Distinct seeds give distinct points -/

/-- The embedding `z(m,n) = (n+i)/m` is injective on pairs with `m > 0`. -/
theorem hpoint_injective {m₁ n₁ m₂ n₂ : ℕ} (h₁ : 0 < m₁) (h₂ : 0 < m₂)
    (h : hpoint m₁ n₁ h₁ = hpoint m₂ n₂ h₂) : m₁ = m₂ ∧ n₁ = n₂ := by
  have hM₁ : (0 : ℝ) < (m₁ : ℝ) := by exact_mod_cast h₁
  have hM₂ : (0 : ℝ) < (m₂ : ℝ) := by exact_mod_cast h₂
  have him : (1 : ℝ) / (m₁ : ℝ) = 1 / (m₂ : ℝ) := by
    have := congrArg UpperHalfPlane.im h
    simpa using this
  have hm : (m₁ : ℝ) = (m₂ : ℝ) := by
    field_simp at him; linarith
  have hmnat : m₁ = m₂ := by exact_mod_cast hm
  refine ⟨hmnat, ?_⟩
  have hre : (n₁ : ℝ) / (m₁ : ℝ) = (n₂ : ℝ) / (m₂ : ℝ) := by
    have := congrArg UpperHalfPlane.re h
    simpa using this
  rw [← hm] at hre
  have : (n₁ : ℝ) = (n₂ : ℝ) := by
    field_simp at hre; linarith
  exact_mod_cast this

/-- Distinct Euclid seeds occupy distinct points of the hyperbolic plane, so the
exponentially many nodes counted in `hyperbolic_ball_volume_growth` really are
exponentially many *points*. -/
theorem seed_point_injective {m₁ n₁ m₂ n₂ : ℕ} (h₁ : 0 < m₁) (h₂ : 0 < m₂)
    (hne : (m₁, n₁) ≠ (m₂, n₂)) : hpoint m₁ n₁ h₁ ≠ hpoint m₂ n₂ h₂ := by
  intro h
  obtain ⟨hm, hn⟩ := hpoint_injective h₁ h₂ h
  exact hne (by rw [hm, hn])

/-! ## Part C. Sharpness of the Cauchy–Schwarz energy bound (sub-conjecture C3-lite) -/

/-- The uniformly parametrised vertical geodesic with `k` steps and total displacement `t`:
`z j = i · e^{t j / k}`. -/
def vertGeodesic (t : ℝ) (k : ℕ) (j : ℕ) : ℍ :=
  UpperHalfPlane.mk ⟨0, Real.exp (t * j / k)⟩ (Real.exp_pos _)

theorem dist_vertGeodesic (t : ℝ) (k : ℕ) (i j : ℕ) :
    dist (vertGeodesic t k i) (vertGeodesic t k j) = |t * i / k - t * j / k| := by
  have := (UpperHalfPlane.isometry_vertical_line 0).dist_eq (t * i / k) (t * j / k)
  simpa [vertGeodesic, Real.dist_eq] using this

/-- Each of the `k` steps of the uniform geodesic has length exactly `t/k`. -/
theorem dist_vertGeodesic_step {t : ℝ} (ht : 0 ≤ t) {k : ℕ} (hk : 0 < k) (j : ℕ) :
    dist (vertGeodesic t k j) (vertGeodesic t k (j + 1)) = t / k := by
  have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  rw [dist_vertGeodesic]
  have : t * (j : ℝ) / k - t * ((j : ℕ) + 1 : ℕ) / k = -(t / k) := by
    push_cast; field_simp; ring
  rw [this, abs_neg, abs_of_nonneg (by positivity)]

/-- The endpoints of the uniform geodesic are at distance exactly `t`. -/
theorem dist_vertGeodesic_endpoints {t : ℝ} (ht : 0 ≤ t) {k : ℕ} (hk : 0 < k) :
    dist (vertGeodesic t k 0) (vertGeodesic t k k) = t := by
  have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  have h0 : t * ((0 : ℕ) : ℝ) / (k : ℝ) = 0 := by simp
  have h1 : t * ((k : ℕ) : ℝ) / (k : ℝ) = t := by field_simp
  rw [dist_vertGeodesic, h0, h1, zero_sub, abs_neg, abs_of_nonneg ht]

/-- **The energy of the uniform geodesic is exactly `t²/k`.** -/
theorem vertGeodesic_energy {t : ℝ} (ht : 0 ≤ t) {k : ℕ} (hk : 0 < k) :
    pathEnergy (vertGeodesic t k) k = t ^ 2 / k := by
  have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  unfold pathEnergy
  rw [Finset.sum_congr rfl (fun j _ => by rw [dist_vertGeodesic_step ht hk j])]
  rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul]
  field_simp

/-- **Sharpness of `geodesic_energy_lower_bound` (C3-lite, closed).**
For every number of steps `k > 0` and every displacement `t ≥ 0` there is a `k`-step
trajectory realising equality `E = d²/k` in the Cauchy–Schwarz energy bound.  Hence the
constant in `berggren_trajectory_energy_bound` cannot be improved. -/
theorem energy_lower_bound_sharp {t : ℝ} (ht : 0 ≤ t) {k : ℕ} (hk : 0 < k) :
    ∃ z : ℕ → ℍ, dist (z 0) (z k) = t ∧
      pathEnergy z k = dist (z 0) (z k) ^ 2 / (k : ℝ) := by
  refine ⟨vertGeodesic t k, dist_vertGeodesic_endpoints ht hk, ?_⟩
  rw [dist_vertGeodesic_endpoints ht hk, vertGeodesic_energy ht hk]

/-! ## Part D. A collision computes a *complete* splitting -/

/-- Euler's product identity `(ac+bd)(ad+bc) = N (ab+cd)` for two representations of `N`
as a sum of two squares. -/
theorem euler_cross_product {a b c d N : ℕ} (h1 : a ^ 2 + b ^ 2 = N) (h2 : c ^ 2 + d ^ 2 = N) :
    (a * c + b * d) * (a * d + b * c) = N * (a * b + c * d) := by
  have hexp : (a * c + b * d) * (a * d + b * c)
      = (a ^ 2 + b ^ 2) * (c * d) + (c ^ 2 + d ^ 2) * (a * b) := by ring
  rw [h1, h2] at hexp
  rw [hexp]; ring

/-- Squares do not change parity. -/
theorem sq_mod_two (x : ℕ) : x ^ 2 % 2 = x % 2 := by
  conv_lhs => rw [Nat.pow_mod]
  rcases Nat.mod_two_eq_zero_or_one x with h | h
  · rw [h]
  · rw [h]

/-- The hypotenuse of a Euclid seed is odd. -/
theorem seed_hypotenuse_odd {m n : ℕ} (h : IsSeed m n) : (m ^ 2 + n ^ 2) % 2 = 1 := by
  have hm := sq_mod_two m
  have hn := sq_mod_two n
  have hp := h.parity
  omega

/-- **The three-fold gcd is trivial.**  If `N` is odd and has two *primitive*
representations `N = a²+b² = c²+d²`, then `N`, `P = ac+bd` and `Q = ad+bc` have no common
factor.  This is the engine behind the complete splitting below: the two Euler pivots
`P` and `Q` cannot both absorb the same prime of `N`. -/
theorem collision_gcd_three_eq_one {a b c d N : ℕ} (hodd : N % 2 = 1)
    (hab : Nat.Coprime a b) (hcd : Nat.Coprime c d)
    (h1 : a ^ 2 + b ^ 2 = N) :
    Nat.gcd (Nat.gcd N (a * c + b * d)) (a * d + b * c) = 1 := by
  by_contra hne
  obtain ⟨p, hp, hpd⟩ := Nat.exists_prime_and_dvd hne
  have hpNP : p ∣ Nat.gcd N (a * c + b * d) := hpd.trans (Nat.gcd_dvd_left _ _)
  have hpN : p ∣ N := hpNP.trans (Nat.gcd_dvd_left _ _)
  have hpP : p ∣ a * c + b * d := hpNP.trans (Nat.gcd_dvd_right _ _)
  have hpQ : p ∣ a * d + b * c := hpd.trans (Nat.gcd_dvd_right _ _)
  -- move to `ℤ`, where the subtraction `a² - b²` makes sense
  have hpZ : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  have hPZ : (p : ℤ) ∣ (a : ℤ) * c + (b : ℤ) * d := by exact_mod_cast Int.natCast_dvd_natCast.2 hpP
  have hQZ : (p : ℤ) ∣ (a : ℤ) * d + (b : ℤ) * c := by exact_mod_cast Int.natCast_dvd_natCast.2 hpQ
  have hNZ : (p : ℤ) ∣ (a : ℤ) ^ 2 + (b : ℤ) ^ 2 := by
    have : ((a ^ 2 + b ^ 2 : ℕ) : ℤ) = (a : ℤ) ^ 2 + (b : ℤ) ^ 2 := by push_cast; ring
    rw [← this, h1]
    exact Int.natCast_dvd_natCast.2 hpN
  have hc1 : (p : ℤ) ∣ (c : ℤ) * ((a : ℤ) ^ 2 - (b : ℤ) ^ 2) := by
    have hid : (c : ℤ) * ((a : ℤ) ^ 2 - (b : ℤ) ^ 2)
        = (a : ℤ) * ((a : ℤ) * c + (b : ℤ) * d) - (b : ℤ) * ((a : ℤ) * d + (b : ℤ) * c) := by ring
    rw [hid]
    exact dvd_sub (hPZ.mul_left _) (hQZ.mul_left _)
  have hd1 : (p : ℤ) ∣ (d : ℤ) * ((a : ℤ) ^ 2 - (b : ℤ) ^ 2) := by
    have hid : (d : ℤ) * ((a : ℤ) ^ 2 - (b : ℤ) ^ 2)
        = (a : ℤ) * ((a : ℤ) * d + (b : ℤ) * c) - (b : ℤ) * ((a : ℤ) * c + (b : ℤ) * d) := by ring
    rw [hid]
    exact dvd_sub (hQZ.mul_left _) (hPZ.mul_left _)
  obtain ⟨u, v, huv⟩ : IsCoprime (c : ℤ) (d : ℤ) := Nat.isCoprime_iff_coprime.2 hcd
  have hdiff : (p : ℤ) ∣ (a : ℤ) ^ 2 - (b : ℤ) ^ 2 := by
    have hid : (a : ℤ) ^ 2 - (b : ℤ) ^ 2
        = u * ((c : ℤ) * ((a : ℤ) ^ 2 - (b : ℤ) ^ 2))
          + v * ((d : ℤ) * ((a : ℤ) ^ 2 - (b : ℤ) ^ 2)) := by
      have : (u * (c : ℤ) + v * (d : ℤ)) * ((a : ℤ) ^ 2 - (b : ℤ) ^ 2)
          = (a : ℤ) ^ 2 - (b : ℤ) ^ 2 := by rw [huv]; ring
      linarith [this]
    rw [hid]
    exact dvd_add (hc1.mul_left _) (hd1.mul_left _)
  have hp2 : p ≠ 2 := by
    rintro rfl
    obtain ⟨t, ht⟩ := hpN
    omega
  have hpnot2 : ¬ (p : ℤ) ∣ 2 := by
    intro hcon
    have hd2 : p ∣ 2 := by exact_mod_cast hcon
    exact hp2 ((Nat.prime_dvd_prime_iff_eq hp Nat.prime_two).1 hd2)
  have hpa : (p : ℤ) ∣ (a : ℤ) := by
    have h2a : (p : ℤ) ∣ 2 * (a : ℤ) ^ 2 := by
      have : 2 * (a : ℤ) ^ 2 = ((a : ℤ) ^ 2 + (b : ℤ) ^ 2) + ((a : ℤ) ^ 2 - (b : ℤ) ^ 2) := by ring
      rw [this]; exact dvd_add hNZ hdiff
    rcases hpZ.dvd_mul.1 h2a with h | h
    · exact absurd h hpnot2
    · exact hpZ.dvd_of_dvd_pow h
  have hpb : (p : ℤ) ∣ (b : ℤ) := by
    have h2b : (p : ℤ) ∣ 2 * (b : ℤ) ^ 2 := by
      have : 2 * (b : ℤ) ^ 2 = ((a : ℤ) ^ 2 + (b : ℤ) ^ 2) - ((a : ℤ) ^ 2 - (b : ℤ) ^ 2) := by ring
      rw [this]; exact dvd_sub hNZ hdiff
    rcases hpZ.dvd_mul.1 h2b with h | h
    · exact absurd h hpnot2
    · exact hpZ.dvd_of_dvd_pow h
  have hpa' : p ∣ a := by exact_mod_cast hpa
  have hpb' : p ∣ b := by exact_mod_cast hpb
  have : p ∣ 1 := hab ▸ Nat.dvd_gcd hpa' hpb'
  exact Nat.Prime.one_lt hp |>.ne' (Nat.dvd_one.1 this)

/-- **A collision computes a complete splitting of `N`.**
If `N` is odd and `N = a² + b² = c² + d²` with both representations primitive, then the two
Euler pivots multiply out exactly:
`gcd (N, ac+bd) · gcd (N, ad+bc) = N`.
So a single collision does not merely expose one divisor — it factors `N` into two
complementary parts. -/
theorem euler_gcd_product {a b c d N : ℕ} (hodd : N % 2 = 1)
    (hab : Nat.Coprime a b) (hcd : Nat.Coprime c d)
    (h1 : a ^ 2 + b ^ 2 = N) (h2 : c ^ 2 + d ^ 2 = N) :
    Nat.gcd N (a * c + b * d) * Nat.gcd N (a * d + b * c) = N := by
  set P := a * c + b * d with hP
  set Q := a * d + b * c with hQ
  set S := a * b + c * d with hS
  have hPQ : P * Q = N * S := euler_cross_product h1 h2
  have hstep : P * Nat.gcd N Q = N * Nat.gcd P S := by
    rw [← Nat.gcd_mul_left P N Q, mul_comm P N, hPQ, Nat.gcd_mul_left N P S]
  have hcop : Nat.gcd (Nat.gcd N Q) (Nat.gcd P S) = 1 := by
    have hdvd : Nat.gcd (Nat.gcd N Q) (Nat.gcd P S) ∣ Nat.gcd (Nat.gcd N P) Q := by
      refine Nat.dvd_gcd (Nat.dvd_gcd ?_ ?_) ?_
      · exact (Nat.gcd_dvd_left _ _).trans (Nat.gcd_dvd_left _ _)
      · exact (Nat.gcd_dvd_right _ _).trans (Nat.gcd_dvd_left _ _)
      · exact (Nat.gcd_dvd_left _ _).trans (Nat.gcd_dvd_right _ _)
    exact Nat.eq_one_of_dvd_one (collision_gcd_three_eq_one hodd hab hcd h1 ▸ hdvd)
  calc Nat.gcd N P * Nat.gcd N Q
      = Nat.gcd (N * Nat.gcd N Q) (P * Nat.gcd N Q) := (Nat.gcd_mul_right N (Nat.gcd N Q) P).symm
    _ = Nat.gcd (N * Nat.gcd N Q) (N * Nat.gcd P S) := by rw [hstep]
    _ = N * Nat.gcd (Nat.gcd N Q) (Nat.gcd P S) := Nat.gcd_mul_left _ _ _
    _ = N := by rw [hcop, mul_one]

/-- **Berggren collisions split the hypotenuse completely.**
Two distinct nodes of the Berggren tree carrying the same hypotenuse `N` produce *two*
non-trivial factors whose product is exactly `N`: the pair of geodesics recovers the full
splitting `N = g · h`, not just a single divisor. -/
theorem berggren_collision_splits {m₁ n₁ m₂ n₂ N : ℕ} (h₁ : IsSeed m₁ n₁) (h₂ : IsSeed m₂ n₂)
    (hN₁ : m₁ ^ 2 + n₁ ^ 2 = N) (hN₂ : m₂ ^ 2 + n₂ ^ 2 = N) (hne : (m₁, n₁) ≠ (m₂, n₂)) :
    Nat.gcd N (m₁ * m₂ + n₁ * n₂) * Nat.gcd N (m₁ * n₂ + n₁ * m₂) = N ∧
      1 < Nat.gcd N (m₁ * m₂ + n₁ * n₂) ∧ Nat.gcd N (m₁ * m₂ + n₁ * n₂) < N ∧
      1 < Nat.gcd N (m₁ * n₂ + n₁ * m₂) ∧ Nat.gcd N (m₁ * n₂ + n₁ * m₂) < N := by
  have hodd : N % 2 = 1 := hN₁ ▸ seed_hypotenuse_odd h₁
  have hprod := euler_gcd_product hodd h₁.cop h₂.cop hN₁ hN₂
  obtain ⟨hlow, hhigh⟩ := berggren_collision_factors h₁ h₂ hN₁ hN₂ hne
  have hNpos : 0 < N := by omega
  refine ⟨hprod, hlow, hhigh, ?_, ?_⟩
  · -- if the second factor were `0` or `1`, the first would be `0` or `N`
    rcases Nat.eq_zero_or_pos (Nat.gcd N (m₁ * n₂ + n₁ * m₂)) with hz | hpos
    · rw [hz, mul_zero] at hprod; omega
    · rcases Nat.lt_or_ge 1 (Nat.gcd N (m₁ * n₂ + n₁ * m₂)) with hlt | hle
      · exact hlt
      · exfalso
        have hone : Nat.gcd N (m₁ * n₂ + n₁ * m₂) = 1 := by omega
        rw [hone, mul_one] at hprod
        omega
  · -- likewise the second factor cannot be all of `N`
    have hle : Nat.gcd N (m₁ * n₂ + n₁ * m₂) ≤ N :=
      Nat.le_of_dvd hNpos (Nat.gcd_dvd_left _ _)
    rcases lt_or_eq_of_le hle with h | h
    · exact h
    · exfalso
      rw [h] at hprod
      have hone : Nat.gcd N (m₁ * m₂ + n₁ * n₂) = 1 :=
        Nat.eq_of_mul_eq_mul_right hNpos (by rw [hprod, one_mul])
      omega

/-! ## Part E. Collisions occur at every scale -/

/-- The first member of the explicit colliding family. -/
theorem collFamilyA_isSeed (j : ℕ) : IsSeed (20 * j + 9) (10 * j + 2) := by
  refine ⟨by omega, by omega, ?_, by omega⟩
  have h1 : Nat.gcd (20 * j + 9) (10 * j + 2) ∣ 20 * j + 9 := Nat.gcd_dvd_left _ _
  have h2 : Nat.gcd (20 * j + 9) (10 * j + 2) ∣ 10 * j + 2 := Nat.gcd_dvd_right _ _
  have h3 : Nat.gcd (20 * j + 9) (10 * j + 2) ∣ 20 * j + 4 := by
    have := h2.mul_left 2
    simpa [show 2 * (10 * j + 2) = 20 * j + 4 by ring] using this
  have h4 : Nat.gcd (20 * j + 9) (10 * j + 2) ∣ 5 := by
    simpa [show 20 * j + 9 - (20 * j + 4) = 5 by omega] using Nat.dvd_sub h1 h3
  rcases (Nat.Prime.eq_one_or_self_of_dvd (by norm_num) _ h4) with h | h
  · exact h
  · exfalso
    rw [h] at h2
    obtain ⟨t, ht⟩ := h2
    omega

/-- The second member of the explicit colliding family. -/
theorem collFamilyB_isSeed (j : ℕ) : IsSeed (20 * j + 7) (10 * j + 6) := by
  refine ⟨by omega, by omega, ?_, by omega⟩
  have h1 : Nat.gcd (20 * j + 7) (10 * j + 6) ∣ 20 * j + 7 := Nat.gcd_dvd_left _ _
  have h2 : Nat.gcd (20 * j + 7) (10 * j + 6) ∣ 10 * j + 6 := Nat.gcd_dvd_right _ _
  have h3 : Nat.gcd (20 * j + 7) (10 * j + 6) ∣ 20 * j + 12 := by
    have := h2.mul_left 2
    simpa [show 2 * (10 * j + 6) = 20 * j + 12 by ring] using this
  have h4 : Nat.gcd (20 * j + 7) (10 * j + 6) ∣ 5 := by
    simpa [show 20 * j + 12 - (20 * j + 7) = 5 by omega] using Nat.dvd_sub h3 h1
  rcases (Nat.Prime.eq_one_or_self_of_dvd (by norm_num) _ h4) with h | h
  · exact h
  · exfalso
    rw [h] at h2
    obtain ⟨t, ht⟩ := h2
    omega

theorem collFamily_hyp_A (j : ℕ) :
    (20 * j + 9) ^ 2 + (10 * j + 2) ^ 2 = 500 * j ^ 2 + 400 * j + 85 := by ring

theorem collFamily_hyp_B (j : ℕ) :
    (20 * j + 7) ^ 2 + (10 * j + 6) ^ 2 = 500 * j ^ 2 + 400 * j + 85 := by ring

/-- **Collisions at every scale.**  For every bound `M` there is a hypotenuse `N > M`
carried by two *distinct* Berggren nodes.  Hence the set of hypotenuses admitting a
geodesic collision — and therefore a geometric factorisation certificate — is infinite. -/
theorem exists_collision_gt (M : ℕ) :
    ∃ N m₁ n₁ m₂ n₂ : ℕ, M < N ∧ IsSeed m₁ n₁ ∧ IsSeed m₂ n₂ ∧
      m₁ ^ 2 + n₁ ^ 2 = N ∧ m₂ ^ 2 + n₂ ^ 2 = N ∧ (m₁, n₁) ≠ (m₂, n₂) := by
  refine ⟨500 * M ^ 2 + 400 * M + 85, 20 * M + 9, 10 * M + 2, 20 * M + 7, 10 * M + 6, ?_,
    collFamilyA_isSeed M, collFamilyB_isSeed M, collFamily_hyp_A M, collFamily_hyp_B M, ?_⟩
  · nlinarith [sq_nonneg M]
  · simp only [ne_eq, Prod.mk.injEq, not_and]
    omega

/-- If `P` is an odd multiple of `5`, then `gcd (P + 10, P) = 5`. -/
theorem gcd_add_ten_eq_five {P : ℕ} (h5P : 5 ∣ P) (hodd : P % 2 = 1) :
    Nat.gcd (P + 10) P = 5 := by
  have h5N : (5 : ℕ) ∣ P + 10 := Dvd.dvd.add h5P (by norm_num)
  have h5g : (5 : ℕ) ∣ Nat.gcd (P + 10) P := Nat.dvd_gcd h5N h5P
  have hgN : Nat.gcd (P + 10) P ∣ P + 10 := Nat.gcd_dvd_left _ _
  have hgP : Nat.gcd (P + 10) P ∣ P := Nat.gcd_dvd_right _ _
  have hg10 : Nat.gcd (P + 10) P ∣ 10 := by
    simpa using Nat.dvd_sub hgN hgP
  have hle : Nat.gcd (P + 10) P ≤ 10 := Nat.le_of_dvd (by norm_num) hg10
  obtain ⟨t, ht⟩ := h5g
  have htle : t ≤ 2 := by omega
  interval_cases t
  · exfalso
    rw [Nat.mul_zero] at ht
    rw [ht] at hgP
    have hP0 : P = 0 := Nat.eq_zero_of_zero_dvd hgP
    omega
  · omega
  · exfalso
    rw [show 5 * 2 = 10 from rfl] at ht
    rw [ht] at hgN
    obtain ⟨s, hs⟩ := hgN
    omega

/-- The divisor extracted from the family collision is computed exactly: it is `5`. -/
theorem collFamily_divisor (j : ℕ) :
    Nat.gcd (500 * j ^ 2 + 400 * j + 85)
      ((20 * j + 9) * (20 * j + 7) + (10 * j + 2) * (10 * j + 6)) = 5 := by
  have hP : (20 * j + 9) * (20 * j + 7) + (10 * j + 2) * (10 * j + 6)
      = 500 * j ^ 2 + 400 * j + 75 := by ring
  have hN : 500 * j ^ 2 + 400 * j + 85 = (500 * j ^ 2 + 400 * j + 75) + 10 := by ring
  rw [hP, hN]
  refine gcd_add_ten_eq_five ⟨100 * j ^ 2 + 80 * j + 15, by ring⟩ ?_
  omega

end

end HyperbolicBerggrenGeodesics