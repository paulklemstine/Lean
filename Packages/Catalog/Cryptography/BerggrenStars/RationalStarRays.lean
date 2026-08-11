import Mathlib
import Cryptography.BerggrenStars.RationalStars

/-!
# The individual rays of a rational star: straight lines, shrinking steps, ideal tips

`Cryptography.BerggrenStars.RationalStars` determines *which* rays of the pencil over a
boundary rational `p/q` are populated by Berggren nodes. This file studies a single ray.

Fix a boundary rational `p/q` and a star charge `k = q n - p m`. The nodes of charge `k` are
exactly the lattice translates `(m + t q, n + t p)` of one another, and here we prove that they
form the visible radial line of the picture:

## Main results

* `star_ray_line` : the exact Euclidean equation of the ray,
  `Re z = p/q + (k/q) · Im z`. Charge `k` is the Euclidean line parameter.
* `ray_constant_distVLine` : two nodes of equal charge are at equal hyperbolic distance from
  the geodesic over `p/q` — the ray is a hypercycle, not a geodesic.
* `dvd_charge_of_common_divisor`, `isSeed_along_unit_ray` : the arithmetic of a ray. Any common
  divisor of the two coordinates of a node divides its charge; consequently the two **unit
  rays** `k = ±1` of every rational star are *fully* populated — every second lattice point on
  them is a Berggren node. These are the brightest lines of the star.
* `cross_along_ray` : the seed cross product of two nodes on a ray of charge `k` at lattice
  distance `t` is exactly `t k`; the charge is the symplectic area form of the ray.
* `cosh_step_along_star_ray` : hence the exact hyperbolic step length along the ray,
  `cosh(step) = ((tk)² + m² + m'²)/(2 m m')`.
* `step_along_star_ray_tendsto_zero` : the steps along a ray tend to `0`. A ray is an infinite
  path of shrinking steps — the reason it renders as a smooth straight line rather than as a
  sequence of separated dots.
* `ray_tendsto_boundary` : the ray converges to its ideal tip `p/q`. Every rational boundary
  point is the limit of the ray(s) of its own star.
-/

namespace BerggrenRationalStars

open BerggrenHypercycleStars Real UpperHalfPlane

/-! ## Part 1. The ray is a Euclidean straight line through `p/q`, and a hypercycle -/

/-- **The equation of the radial line.** Every node lies on the Euclidean line through the
ideal point `p/q` with parameter `charge / q`. Nodes of equal charge are exactly collinear
along such a line: this is the radial line seen in the picture. -/
theorem star_ray_line (p q m n : ℕ) (hm : 0 < m) (hq : 0 < q) :
    (hpoint m n hm).re
      = (p : ℝ) / q + ((starCharge p q m n : ℝ) / q) * (hpoint m n hm).im := by
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hQ : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  rw [hpoint_re, hpoint_im, starCharge]
  push_cast
  field_simp
  ring

/-- **A ray is a hypercycle.** Nodes with the same charge at `p/q` are at the same hyperbolic
distance from the vertical geodesic over `p/q`. -/
theorem ray_constant_distVLine (p q m n m' n' : ℕ) (hm : 0 < m) (hm' : 0 < m') (hq : 0 < q)
    (h : starCharge p q m n = starCharge p q m' n') :
    distVLine (hpoint m n hm) ((p : ℝ) / q) = distVLine (hpoint m' n' hm') ((p : ℝ) / q) := by
  have h1 := sinh_distVLine_charge p q m n hm hq
  have h2 := sinh_distVLine_charge p q m' n' hm' hq
  have : Real.sinh (distVLine (hpoint m n hm) ((p : ℝ) / q))
      = Real.sinh (distVLine (hpoint m' n' hm') ((p : ℝ) / q)) := by
    rw [h1, h2, h]
  exact Real.sinh_injective this

/-! ## Part 2. The arithmetic of a ray: the unit rays are fully populated -/

/-- Any common divisor of the coordinates of a node divides its star charge. Hence on the rays
of charge `±1` **all** lattice points are primitive. -/
theorem dvd_charge_of_common_divisor (p q m n : ℕ) {d : ℕ} (h1 : d ∣ m) (h2 : d ∣ n) :
    (d : ℤ) ∣ starCharge p q m n := by
  obtain ⟨a, rfl⟩ := h1
  obtain ⟨b, rfl⟩ := h2
  refine ⟨(q : ℤ) * b - (p : ℤ) * a, ?_⟩
  simp only [starCharge]
  push_cast
  ring

/-- **The unit rays are the brightest lines of every rational star.** If a node has charge `±1`
at `p/q` (with `p < q`), then *every* second lattice point along its ray is again a Berggren
node: `(m + 2tq, n + 2tp)` is a Euclid seed for all `t`. No coprimality sieve thins these
rays out — the only constraint is parity, and translating by `2(q,p)` preserves it. -/
theorem isSeed_along_unit_ray (p q m n t : ℕ) (hpq : p < q) (h : IsSeed m n)
    (hk : starCharge p q m n = 1 ∨ starCharge p q m n = -1) :
    IsSeed (m + 2 * t * q) (n + 2 * t * p) := by
  have hpos := h.pos
  have hltmn := h.lt
  have hpar := h.parity
  have hpq2 : 2 * t * p ≤ 2 * t * q := Nat.mul_le_mul_left _ hpq.le
  refine ⟨by omega, by omega, ?_, ?_⟩
  · -- coprimality: a common divisor divides the charge `±1`
    have hd : (Nat.gcd (m + 2 * t * q) (n + 2 * t * p) : ℤ)
        ∣ starCharge p q (m + 2 * t * q) (n + 2 * t * p) :=
      dvd_charge_of_common_divisor p q _ _ (Nat.gcd_dvd_left _ _) (Nat.gcd_dvd_right _ _)
    rw [starCharge_translate p q m n (2 * t)] at hd
    have : (Nat.gcd (m + 2 * t * q) (n + 2 * t * p) : ℤ) ∣ 1 := by
      rcases hk with hk | hk
      · rwa [hk] at hd
      · rw [hk] at hd; exact (dvd_neg.mp hd)
    have hle := Int.le_of_dvd (by norm_num) this
    have hg : Nat.gcd (m + 2 * t * q) (n + 2 * t * p) ≠ 0 := fun hzero => by
      have := (Nat.gcd_eq_zero_iff).mp hzero
      omega
    unfold Nat.Coprime
    omega
  · have hE : m + 2 * t * q + (n + 2 * t * p) = (m + n) + 2 * (t * q + t * p) := by ring
    rw [hE]
    omega

/-! ## Part 3. Steps along a ray, and the ideal tip -/

/-- **The charge is the cross product.** The seed cross product of two nodes at lattice
distance `t` along a ray of charge `k` is exactly `t k`. -/
theorem cross_along_ray (p q m n t : ℕ) :
    (n : ℤ) * ((m : ℤ) + t * q) - ((n : ℤ) + t * p) * m = t * starCharge p q m n := by
  rw [starCharge]; ring

/-- **The exact hyperbolic step along a ray.** -/
theorem cosh_step_along_star_ray (p q m n t : ℕ) (hm : 0 < m) (hm' : 0 < m + t * q) :
    Real.cosh (dist (hpoint m n hm) (hpoint (m + t * q) (n + t * p) hm'))
      = (((t : ℝ) * (starCharge p q m n : ℝ)) ^ 2 + (m : ℝ) ^ 2 + ((m : ℝ) + t * q) ^ 2)
          / (2 * m * ((m : ℝ) + t * q)) := by
  rw [cosh_dist_hpoint_hpoint m n (m + t * q) (n + t * p) hm hm']
  have hcross : (n : ℝ) * ((m : ℝ) + t * q) - ((n : ℝ) + t * p) * m
      = (t : ℝ) * (starCharge p q m n : ℝ) := by
    rw [starCharge]; push_cast; ring
  push_cast
  rw [hcross]

/-- **The steps along a ray tend to zero.** Consecutive Berggren nodes on a fixed ray of a
rational star get hyperbolically closer and closer: the ray renders as a smooth line gliding
into its ideal tip. -/
theorem step_along_star_ray_tendsto_zero (p q m n : ℕ) (hm : 0 < m) (hq : 0 < q) :
    Filter.Tendsto
      (fun j : ℕ => dist (hpoint (m + 2 * j * q) (n + 2 * j * p) (by omega))
        (hpoint (m + 2 * j * q + 2 * q) (n + 2 * j * p + 2 * p) (by omega)))
      Filter.atTop (nhds 0) := by
  have hqR : (1 : ℝ) ≤ (q : ℝ) := by exact_mod_cast hq
  set k : ℝ := (starCharge p q m n : ℝ) with hkdef
  set T : ℕ → ℝ := fun j =>
    (4 * k ^ 2 + 4 * (q : ℝ) ^ 2) /
      (2 * ((m : ℝ) + 2 * j * q) * (((m : ℝ) + 2 * j * q) + 2 * q)) with hT
  -- the exact step formula
  have hstep : ∀ j : ℕ,
      Real.cosh (dist (hpoint (m + 2 * j * q) (n + 2 * j * p) (by omega))
        (hpoint (m + 2 * j * q + 2 * q) (n + 2 * j * p + 2 * p) (by omega))) = 1 + T j := by
    intro j
    have hM : (0 : ℝ) < (m : ℝ) + 2 * j * q := by
      have : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
      positivity
    have hcharge : starCharge p q (m + 2 * j * q) (n + 2 * j * p) = starCharge p q m n :=
      starCharge_translate p q m n (2 * j)
    have hmain := cosh_step_along_star_ray p q (m + 2 * j * q) (n + 2 * j * p) 2
      (by omega) (by omega)
    rw [hcharge] at hmain
    have hcast : (((m + 2 * j * q : ℕ) : ℝ)) = (m : ℝ) + 2 * j * q := by push_cast; ring
    rw [hT]
    simp only
    rw [hmain, hcast, ← hkdef]
    field_simp
    ring
  -- `T j → 0`
  have hbd : ∀ j : ℕ, |T j| ≤ (4 * k ^ 2 + 4 * (q : ℝ) ^ 2) / (2 * j + 1) := by
    intro j
    have hm1 : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
    have hMj : (2 : ℝ) * j + 1 ≤ (m : ℝ) + 2 * j * q := by
      have : (2 : ℝ) * j * 1 ≤ 2 * j * q := by
        have hj : (0 : ℝ) ≤ 2 * j := by positivity
        nlinarith
      linarith
    have hMpos : (0 : ℝ) < (m : ℝ) + 2 * j * q := by linarith [Nat.cast_nonneg (α := ℝ) j]
    have hnum : (0 : ℝ) ≤ 4 * k ^ 2 + 4 * (q : ℝ) ^ 2 := by positivity
    rw [hT]
    simp only
    rw [abs_of_nonneg (by positivity)]
    apply div_le_div_of_nonneg_left hnum (by positivity)
    nlinarith
  have htend0 : Filter.Tendsto T Filter.atTop (nhds 0) := by
    have hlim : Filter.Tendsto
        (fun j : ℕ => (4 * k ^ 2 + 4 * (q : ℝ) ^ 2) / (2 * j + 1)) Filter.atTop (nhds 0) := by
      have h1 : Filter.Tendsto (fun j : ℕ => (2 : ℝ) * j + 1) Filter.atTop Filter.atTop := by
        apply Filter.tendsto_atTop_add_const_right
        apply Filter.Tendsto.const_mul_atTop (by norm_num)
        exact tendsto_natCast_atTop_atTop
      exact Filter.Tendsto.div_atTop tendsto_const_nhds h1
    exact squeeze_zero_norm hbd hlim
  -- transfer to distances by monotonicity of `cosh`
  rw [Metric.tendsto_atTop]
  intro ε hε
  have hcε : (1 : ℝ) < Real.cosh ε := (Real.one_lt_cosh (x := ε)).2 (ne_of_gt hε)
  obtain ⟨K, hK⟩ := (Metric.tendsto_atTop.1 htend0) (Real.cosh ε - 1) (by linarith)
  refine ⟨K, fun j hj => ?_⟩
  have h1 : |T j - 0| < Real.cosh ε - 1 := hK j hj
  have h2 : Real.cosh (dist (hpoint (m + 2 * j * q) (n + 2 * j * p) (by omega))
      (hpoint (m + 2 * j * q + 2 * q) (n + 2 * j * p + 2 * p) (by omega))) < Real.cosh ε := by
    rw [hstep j]
    have := (abs_lt.1 h1).2
    linarith
  have h3 := Real.cosh_lt_cosh.1 h2
  rw [Real.dist_eq, sub_zero, abs_of_nonneg dist_nonneg]
  rwa [abs_of_nonneg dist_nonneg, abs_of_pos hε] at h3

/-- **The ray runs into its ideal tip.** The nodes of a ray of the star at `p/q` converge, in
the closed half-plane, to the boundary point `p/q` itself. So every rational boundary point is
an accumulation point of the Berggren node set *along a straight line*. -/
theorem ray_tendsto_boundary (p q m n : ℕ) (hm : 0 < m) (hq : 0 < q) :
    Filter.Tendsto
      (fun j : ℕ => ((hpoint (m + 2 * j * q) (n + 2 * j * p) (by omega) : ℍ) : ℂ))
      Filter.atTop (nhds ((((p : ℝ) / (q : ℝ) : ℝ)) : ℂ)) := by
  have hqR : (1 : ℝ) ≤ (q : ℝ) := by exact_mod_cast hq
  have hm1 : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  have hQ : (0 : ℝ) < (q : ℝ) := by linarith
  set k : ℝ := |(starCharge p q m n : ℝ)| with hk
  rw [tendsto_iff_norm_sub_tendsto_zero]
  have hbd : ∀ j : ℕ,
      ‖((hpoint (m + 2 * j * q) (n + 2 * j * p) (by omega) : ℍ) : ℂ)
          - ((((p : ℝ) / (q : ℝ) : ℝ)) : ℂ)‖ ≤ (k / q + 1) / (2 * j + 1) := by
    intro j
    have hMj : (2 : ℝ) * j + 1 ≤ ((m + 2 * j * q : ℕ) : ℝ) := by
      push_cast
      have hj : (0 : ℝ) ≤ 2 * j := by positivity
      nlinarith
    have hMpos : (0 : ℝ) < ((m + 2 * j * q : ℕ) : ℝ) := by
      have : (0 : ℝ) ≤ 2 * (j : ℝ) := by positivity
      push_cast
      nlinarith
    -- real and imaginary parts (both `rfl` for the half-plane embedding)
    have hre : (((hpoint (m + 2 * j * q) (n + 2 * j * p) (by omega) : ℍ) : ℂ)
        - ((((p : ℝ) / (q : ℝ) : ℝ)) : ℂ)).re
        = ((n + 2 * j * p : ℕ) : ℝ) / ((m + 2 * j * q : ℕ) : ℝ) - (p : ℝ) / q := rfl
    have him : (((hpoint (m + 2 * j * q) (n + 2 * j * p) (by omega) : ℍ) : ℂ)
        - ((((p : ℝ) / (q : ℝ) : ℝ)) : ℂ)).im = 1 / ((m + 2 * j * q : ℕ) : ℝ) := by
      show 1 / ((m + 2 * j * q : ℕ) : ℝ) - 0 = _
      ring
    have hrev : ((n + 2 * j * p : ℕ) : ℝ) / ((m + 2 * j * q : ℕ) : ℝ) - (p : ℝ) / q
        = (starCharge p q m n : ℝ) / (q * ((m + 2 * j * q : ℕ) : ℝ)) := by
      rw [starCharge]
      push_cast
      field_simp
      ring
    calc ‖((hpoint (m + 2 * j * q) (n + 2 * j * p) (by omega) : ℍ) : ℂ)
            - ((((p : ℝ) / (q : ℝ) : ℝ)) : ℂ)‖
        ≤ |(((hpoint (m + 2 * j * q) (n + 2 * j * p) (by omega) : ℍ) : ℂ)
              - ((((p : ℝ) / (q : ℝ) : ℝ)) : ℂ)).re|
          + |(((hpoint (m + 2 * j * q) (n + 2 * j * p) (by omega) : ℍ) : ℂ)
              - ((((p : ℝ) / (q : ℝ) : ℝ)) : ℂ)).im| :=
          Complex.norm_le_abs_re_add_abs_im _
      _ = (k / q + 1) / ((m + 2 * j * q : ℕ) : ℝ) := by
          rw [hre, him, hrev, abs_div,
            abs_of_pos (by positivity : (0 : ℝ) < (q : ℝ) * ((m + 2 * j * q : ℕ) : ℝ)),
            abs_of_nonneg (by positivity : (0 : ℝ) ≤ 1 / ((m + 2 * j * q : ℕ) : ℝ)), ← hk]
          field_simp
      _ ≤ (k / q + 1) / (2 * j + 1) := by
          apply div_le_div_of_nonneg_left (by positivity) (by positivity) hMj
  have hlim : Filter.Tendsto (fun j : ℕ => (k / q + 1) / (2 * j + 1)) Filter.atTop (nhds 0) := by
    have h1 : Filter.Tendsto (fun j : ℕ => (2 : ℝ) * j + 1) Filter.atTop Filter.atTop := by
      apply Filter.tendsto_atTop_add_const_right
      apply Filter.Tendsto.const_mul_atTop (by norm_num)
      exact tendsto_natCast_atTop_atTop
    exact Filter.Tendsto.div_atTop tendsto_const_nhds h1
  exact squeeze_zero (fun j => norm_nonneg _) hbd hlim

end BerggrenRationalStars