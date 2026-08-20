import Catalog.Geometry.HyperbolicBerggrenGeodesics
import Catalog.NumberTheory.BerggrenStarSteps

/-!
# How far apart are two colliding Berggren nodes?

A *collision* is a pair of distinct Euclid seeds `(m₁,n₁) ≠ (m₂,n₂)` with the same
hypotenuse `N = m₁² + n₁² = m₂² + n₂²`.  By Euler's two-representation method
(`HyperbolicBerggrenGeodesics.berggren_collision_factors`) the number
`g = gcd (N, m₁m₂ + n₁n₂)` is then a non-trivial divisor of `N`: a collision *factors*
`N`.  The source analysis showed that colliding nodes are hyperbolic *neighbours* in the
weak sense that their distances from the base point `i` differ by at most `2 log 2`
(`collision_dist_close`).  That leaves open the sharper question asked by the picture:

> how far apart are the two colliding nodes **from each other**?

This file answers it exactly, and the answer is governed by the very divisor that the
collision produces.

## Main results

* `collision_cosh_identity` : an exact identity — writing `P = m₁m₂ + n₁n₂` (the *Euler
  pivot*),
  `cosh d(z₁, z₂) = 1 + ((N² − P²) + (m₁ − m₂)²) / (2 m₁ m₂)`.
  The Brahmagupta–Fibonacci identity is what converts the seed cross product appearing in
  `cosh_dist_hpoint_pair` into `N² − P²`.

* `collision_cosh_ge_gcd` : since `g ∣ N` and `g ∣ P` with `P < N`, the deficit `N − P` is
  at least `g`, and therefore
  `cosh d(z₁, z₂) ≥ 1 + g/2`.
  **The two colliding nodes are pushed apart in proportion to the divisor they reveal.**

* `collision_cosh_two_sided` : the two-sided law `(N − P)/2 ≤ cosh d − 1 ≤ 2(N − P) + 2`.
  The pivot deficit `N − P` is the *only* parameter controlling the separation.

* `collision_dist_ge_log_divisor` : consequently `d(z₁, z₂) ≥ log g − log 2`.

* `collision_dist_ge_half_log_of_large_divisor` : if the extracted divisor is the larger
  one (`N ≤ g²`), then `d(z₁, z₂) ≥ ½ log N − log 2` — the colliding pair is essentially
  *antipodal* in its annulus, since each node sits at distance only `½ log N + O(1)` from
  the base point, so a local hyperbolic search around one node cannot find the other.
  (The converse fails: a collision whose extracted divisor is *small* may still be close,
  and indeed `N = 52565 = 5 · 10513` has `d = 2.568` — see `ComputationalEvidence.md`,
  §11.  The parameter that really controls the separation is the pivot deficit `N − P`,
  by `collision_cosh_two_sided`.)
-/

namespace BerggrenCollisionDistance

open Real HyperbolicBerggrenGeodesics BerggrenStarSteps UpperHalfPlane

/-! ## Part 1. The exact collision distance -/

/-- **Exact collision-distance identity.**  For two seeds with the same hypotenuse `N`,
the hyperbolic distance between the corresponding half-plane nodes is determined by the
Euler pivot `P = m₁m₂ + n₁n₂` through
`cosh d = 1 + ((N² − P²) + (m₁ − m₂)²)/(2 m₁ m₂)`. -/
theorem collision_cosh_identity {m₁ n₁ m₂ n₂ N : ℕ} (h₁ : IsSeed m₁ n₁) (h₂ : IsSeed m₂ n₂)
    (hN₁ : m₁ ^ 2 + n₁ ^ 2 = N) (hN₂ : m₂ ^ 2 + n₂ ^ 2 = N) :
    Real.cosh (dist (hpoint m₁ n₁ (lt_trans h₁.pos h₁.lt))
        (hpoint m₂ n₂ (lt_trans h₂.pos h₂.lt)))
      = 1 + (((N : ℝ) ^ 2 - ((m₁ * m₂ + n₁ * n₂ : ℕ) : ℝ) ^ 2)
              + ((m₁ : ℝ) - (m₂ : ℝ)) ^ 2) / (2 * (m₁ : ℝ) * (m₂ : ℝ)) := by
  have hm₁ : (0 : ℝ) < (m₁ : ℝ) := by exact_mod_cast lt_trans h₁.pos h₁.lt
  have hm₂ : (0 : ℝ) < (m₂ : ℝ) := by exact_mod_cast lt_trans h₂.pos h₂.lt
  have e1 : (N : ℝ) = (m₁ : ℝ) ^ 2 + (n₁ : ℝ) ^ 2 := by exact_mod_cast hN₁.symm
  have e2 : (N : ℝ) = (m₂ : ℝ) ^ 2 + (n₂ : ℝ) ^ 2 := by exact_mod_cast hN₂.symm
  have eP : ((m₁ * m₂ + n₁ * n₂ : ℕ) : ℝ) = (m₁ : ℝ) * (m₂ : ℝ) + (n₁ : ℝ) * (n₂ : ℝ) := by
    push_cast; ring
  have eN : (N : ℝ) ^ 2 = ((m₁ : ℝ) ^ 2 + (n₁ : ℝ) ^ 2) * ((m₂ : ℝ) ^ 2 + (n₂ : ℝ) ^ 2) := by
    rw [← e1, ← e2]; ring
  rw [cosh_dist_hpoint_pair, eP, eN]
  field_simp
  ring

/-! ## Part 2. The divisor pushes the nodes apart -/

/-- **The collision distance is bounded below by the divisor it produces.**
With `g = gcd (N, m₁m₂ + n₁n₂)` the non-trivial divisor supplied by Euler's method,
`cosh d(z₁, z₂) ≥ 1 + g/2`. -/
theorem collision_cosh_ge_gcd {m₁ n₁ m₂ n₂ N : ℕ} (h₁ : IsSeed m₁ n₁) (h₂ : IsSeed m₂ n₂)
    (hN₁ : m₁ ^ 2 + n₁ ^ 2 = N) (hN₂ : m₂ ^ 2 + n₂ ^ 2 = N) (hne : (m₁, n₁) ≠ (m₂, n₂)) :
    1 + (Nat.gcd N (m₁ * m₂ + n₁ * n₂) : ℝ) / 2
      ≤ Real.cosh (dist (hpoint m₁ n₁ (lt_trans h₁.pos h₁.lt))
          (hpoint m₂ n₂ (lt_trans h₂.pos h₂.lt))) := by
  rw [collision_cosh_identity h₁ h₂ hN₁ hN₂]
  set P : ℕ := m₁ * m₂ + n₁ * n₂ with hPdef
  set g : ℕ := Nat.gcd N P with hgdef
  have hm₁ : (0 : ℝ) < (m₁ : ℝ) := by exact_mod_cast lt_trans h₁.pos h₁.lt
  have hm₂ : (0 : ℝ) < (m₂ : ℝ) := by exact_mod_cast lt_trans h₂.pos h₂.lt
  -- the Euler pivot is strictly below `N`
  have hPlt : P < N := (collision_dot_bounds h₁ h₂ hN₁ hN₂ hne).2
  -- hence `g ≤ N - P`
  have hgle : g ≤ N - P :=
    Nat.le_of_dvd (by omega) (Nat.dvd_sub (Nat.gcd_dvd_left _ _) (Nat.gcd_dvd_right _ _))
  have hcastsub : ((N - P : ℕ) : ℝ) = (N : ℝ) - (P : ℝ) := by
    push_cast [Nat.cast_sub hPlt.le]; ring
  have hgleR : (g : ℝ) ≤ (N : ℝ) - (P : ℝ) := by
    calc (g : ℝ) ≤ ((N - P : ℕ) : ℝ) := by exact_mod_cast hgle
      _ = (N : ℝ) - (P : ℝ) := hcastsub
  -- `m₁ m₂ ≤ N`, by AM-GM applied to `m₁² ≤ N` and `m₂² ≤ N`
  have hm₁N : (m₁ : ℝ) ^ 2 ≤ (N : ℝ) := by
    have : m₁ ^ 2 ≤ N := by omega
    exact_mod_cast this
  have hm₂N : (m₂ : ℝ) ^ 2 ≤ (N : ℝ) := by
    have : m₂ ^ 2 ≤ N := by omega
    exact_mod_cast this
  have hprod : (m₁ : ℝ) * (m₂ : ℝ) ≤ (N : ℝ) := by
    nlinarith [sq_nonneg ((m₁ : ℝ) - (m₂ : ℝ))]
  have hPnn : (0 : ℝ) ≤ (P : ℝ) := by positivity
  have hgnn : (0 : ℝ) ≤ (g : ℝ) := by positivity
  have hden : (0 : ℝ) < 2 * (m₁ : ℝ) * (m₂ : ℝ) := by positivity
  have hmain : (g : ℝ) / 2
      ≤ (((N : ℝ) ^ 2 - (P : ℝ) ^ 2) + ((m₁ : ℝ) - (m₂ : ℝ)) ^ 2)
          / (2 * (m₁ : ℝ) * (m₂ : ℝ)) := by
    rw [le_div_iff₀ hden]
    -- `g/2 · (2 m₁ m₂) = g m₁ m₂ ≤ g N ≤ (N-P)(N+P) = N² - P²`
    have hA : (g : ℝ) * ((m₁ : ℝ) * (m₂ : ℝ)) ≤ (g : ℝ) * (N : ℝ) := by nlinarith
    have hB : (g : ℝ) * (N : ℝ) ≤ (g : ℝ) * ((N : ℝ) + (P : ℝ)) := by nlinarith
    have hC : (g : ℝ) * ((N : ℝ) + (P : ℝ)) ≤ ((N : ℝ) - (P : ℝ)) * ((N : ℝ) + (P : ℝ)) := by
      have hNP : (0 : ℝ) ≤ (N : ℝ) + (P : ℝ) := by positivity
      nlinarith
    nlinarith [sq_nonneg ((m₁ : ℝ) - (m₂ : ℝ))]
  linarith

/-- **The collision distance is governed by the pivot deficit `N − P`.**
Two-sided and sharp up to a factor `4`:
`(N − P)/2 ≤ cosh d − 1 ≤ 2 (N − P) + 2`.
So the *only* parameter controlling how far apart the two colliding nodes sit is how far
the Euler pivot falls short of `N`; the divisor enters only through `g ∣ N − P`. -/
theorem collision_cosh_two_sided {m₁ n₁ m₂ n₂ N : ℕ} (h₁ : IsSeed m₁ n₁) (h₂ : IsSeed m₂ n₂)
    (hN₁ : m₁ ^ 2 + n₁ ^ 2 = N) (hN₂ : m₂ ^ 2 + n₂ ^ 2 = N) (hne : (m₁, n₁) ≠ (m₂, n₂)) :
    ((N : ℝ) - ((m₁ * m₂ + n₁ * n₂ : ℕ) : ℝ)) / 2
        ≤ Real.cosh (dist (hpoint m₁ n₁ (lt_trans h₁.pos h₁.lt))
            (hpoint m₂ n₂ (lt_trans h₂.pos h₂.lt))) - 1
      ∧ Real.cosh (dist (hpoint m₁ n₁ (lt_trans h₁.pos h₁.lt))
            (hpoint m₂ n₂ (lt_trans h₂.pos h₂.lt))) - 1
          ≤ 2 * ((N : ℝ) - ((m₁ * m₂ + n₁ * n₂ : ℕ) : ℝ)) + 2 := by
  rw [collision_cosh_identity h₁ h₂ hN₁ hN₂]
  set P : ℕ := m₁ * m₂ + n₁ * n₂ with hPdef
  have hm₁ : (0 : ℝ) < (m₁ : ℝ) := by exact_mod_cast lt_trans h₁.pos h₁.lt
  have hm₂ : (0 : ℝ) < (m₂ : ℝ) := by exact_mod_cast lt_trans h₂.pos h₂.lt
  have hPlt : P < N := (collision_dot_bounds h₁ h₂ hN₁ hN₂ hne).2
  have hPltR : (P : ℝ) < (N : ℝ) := by exact_mod_cast hPlt
  have hPnn : (0 : ℝ) ≤ (P : ℝ) := by positivity
  have hm₁N : (m₁ : ℝ) ^ 2 ≤ (N : ℝ) := by
    have : m₁ ^ 2 ≤ N := by omega
    exact_mod_cast this
  have hm₂N : (m₂ : ℝ) ^ 2 ≤ (N : ℝ) := by
    have : m₂ ^ 2 ≤ N := by omega
    exact_mod_cast this
  -- `N < 2 m₁²` and `N < 2 m₂²` because `n < m` in a seed
  have h2m₁ : (N : ℝ) < 2 * (m₁ : ℝ) ^ 2 := by
    have hlt : n₁ ^ 2 < m₁ ^ 2 := Nat.pow_lt_pow_left h₁.lt (by norm_num)
    have : N < 2 * m₁ ^ 2 := by omega
    exact_mod_cast this
  have h2m₂ : (N : ℝ) < 2 * (m₂ : ℝ) ^ 2 := by
    have hlt : n₂ ^ 2 < m₂ ^ 2 := Nat.pow_lt_pow_left h₂.lt (by norm_num)
    have : N < 2 * m₂ ^ 2 := by omega
    exact_mod_cast this
  have hprod : (m₁ : ℝ) * (m₂ : ℝ) ≤ (N : ℝ) := by
    nlinarith [sq_nonneg ((m₁ : ℝ) - (m₂ : ℝ))]
  have hmm : (N : ℝ) < 2 * ((m₁ : ℝ) * (m₂ : ℝ)) := by
    nlinarith [sq_nonneg ((m₁ : ℝ) * (m₂ : ℝ)), mul_pos hm₁ hm₂]
  have hden : (0 : ℝ) < 2 * (m₁ : ℝ) * (m₂ : ℝ) := by positivity
  constructor
  · rw [show (1 : ℝ) + (((N : ℝ) ^ 2 - (P : ℝ) ^ 2) + ((m₁ : ℝ) - (m₂ : ℝ)) ^ 2)
          / (2 * (m₁ : ℝ) * (m₂ : ℝ)) - 1
        = (((N : ℝ) ^ 2 - (P : ℝ) ^ 2) + ((m₁ : ℝ) - (m₂ : ℝ)) ^ 2)
          / (2 * (m₁ : ℝ) * (m₂ : ℝ)) by ring]
    rw [div_le_div_iff₀ (by norm_num : (0:ℝ) < 2) hden]
    have hA : ((N : ℝ) - (P : ℝ)) * ((m₁ : ℝ) * (m₂ : ℝ))
        ≤ ((N : ℝ) - (P : ℝ)) * ((N : ℝ) + (P : ℝ)) := by nlinarith
    nlinarith [sq_nonneg ((m₁ : ℝ) - (m₂ : ℝ))]
  · rw [show (1 : ℝ) + (((N : ℝ) ^ 2 - (P : ℝ) ^ 2) + ((m₁ : ℝ) - (m₂ : ℝ)) ^ 2)
          / (2 * (m₁ : ℝ) * (m₂ : ℝ)) - 1
        = (((N : ℝ) ^ 2 - (P : ℝ) ^ 2) + ((m₁ : ℝ) - (m₂ : ℝ)) ^ 2)
          / (2 * (m₁ : ℝ) * (m₂ : ℝ)) by ring]
    rw [div_le_iff₀ hden]
    have hA : ((N : ℝ) - (P : ℝ)) * ((N : ℝ) + (P : ℝ))
        ≤ ((N : ℝ) - (P : ℝ)) * (4 * ((m₁ : ℝ) * (m₂ : ℝ))) := by nlinarith
    have hB : ((m₁ : ℝ) - (m₂ : ℝ)) ^ 2 ≤ 4 * ((m₁ : ℝ) * (m₂ : ℝ)) := by nlinarith
    nlinarith

/-- Auxiliary: `cosh x ≤ exp x` for `x ≥ 0`. -/
theorem cosh_le_exp_of_nonneg {x : ℝ} (hx : 0 ≤ x) : Real.cosh x ≤ Real.exp x := by
  rw [Real.cosh_eq]
  have : Real.exp (-x) ≤ Real.exp x := Real.exp_le_exp.mpr (by linarith)
  linarith

/-- **The collision distance is at least `log g − log 2`.**  The two nodes that jointly
factor `N` are separated by a distance controlled from below by the divisor they yield. -/
theorem collision_dist_ge_log_divisor {m₁ n₁ m₂ n₂ N : ℕ} (h₁ : IsSeed m₁ n₁)
    (h₂ : IsSeed m₂ n₂) (hN₁ : m₁ ^ 2 + n₁ ^ 2 = N) (hN₂ : m₂ ^ 2 + n₂ ^ 2 = N)
    (hne : (m₁, n₁) ≠ (m₂, n₂)) :
    Real.log (Nat.gcd N (m₁ * m₂ + n₁ * n₂)) - Real.log 2
      ≤ dist (hpoint m₁ n₁ (lt_trans h₁.pos h₁.lt))
          (hpoint m₂ n₂ (lt_trans h₂.pos h₂.lt)) := by
  set g : ℕ := Nat.gcd N (m₁ * m₂ + n₁ * n₂) with hgdef
  set d : ℝ := dist (hpoint m₁ n₁ (lt_trans h₁.pos h₁.lt))
      (hpoint m₂ n₂ (lt_trans h₂.pos h₂.lt)) with hddef
  have hgpos : 1 < g := (berggren_collision_factors h₁ h₂ hN₁ hN₂ hne).1
  have hgR : (1 : ℝ) < (g : ℝ) := by exact_mod_cast hgpos
  have hcosh := collision_cosh_ge_gcd h₁ h₂ hN₁ hN₂ hne
  have hdnn : (0 : ℝ) ≤ d := dist_nonneg
  have hexp : (g : ℝ) / 2 ≤ Real.exp d :=
    le_trans (by linarith) (le_trans hcosh (cosh_le_exp_of_nonneg hdnn))
  have hlog : Real.log ((g : ℝ) / 2) ≤ d := by
    rw [Real.log_le_iff_le_exp (by positivity)]
    exact hexp
  rwa [Real.log_div (by positivity) (by norm_num)] at hlog

/-- **Balanced collisions are far apart.**  If the divisor extracted from the collision is
the larger of the two factors (`N ≤ g²`), then the two colliding nodes lie at hyperbolic
distance at least `½ log N − log 2` from each other.  Since each of them sits at distance
only `½ log N + O(1)` from the base point `i`, the pair is essentially antipodal in its
annulus: no local search around one of the two witnesses can reach the other.  (The
hypothesis is not superfluous: without it the separation can be `O(1)` while `N` is
large.) -/
theorem collision_dist_ge_half_log_of_large_divisor {m₁ n₁ m₂ n₂ N : ℕ} (h₁ : IsSeed m₁ n₁)
    (h₂ : IsSeed m₂ n₂) (hN₁ : m₁ ^ 2 + n₁ ^ 2 = N) (hN₂ : m₂ ^ 2 + n₂ ^ 2 = N)
    (hne : (m₁, n₁) ≠ (m₂, n₂))
    (hlarge : N ≤ Nat.gcd N (m₁ * m₂ + n₁ * n₂) ^ 2) :
    (1 / 2) * Real.log N - Real.log 2
      ≤ dist (hpoint m₁ n₁ (lt_trans h₁.pos h₁.lt))
          (hpoint m₂ n₂ (lt_trans h₂.pos h₂.lt)) := by
  set g : ℕ := Nat.gcd N (m₁ * m₂ + n₁ * n₂) with hgdef
  have hgpos : 1 < g := (berggren_collision_factors h₁ h₂ hN₁ hN₂ hne).1
  have hgR : (1 : ℝ) < (g : ℝ) := by exact_mod_cast hgpos
  have hlargeR : (N : ℝ) ≤ (g : ℝ) ^ 2 := by exact_mod_cast hlarge
  have hkey := collision_dist_ge_log_divisor h₁ h₂ hN₁ hN₂ hne
  have hNpos : (0 : ℝ) < (N : ℝ) := by
    have : 0 < N := by
      have hsq : 0 < n₁ ^ 2 := pow_pos h₁.pos 2
      omega
    exact_mod_cast this
  have hhalf : (1 / 2) * Real.log N ≤ Real.log g := by
    have h1 : Real.log (N : ℝ) ≤ Real.log ((g : ℝ) ^ 2) :=
      Real.log_le_log hNpos hlargeR
    rw [Real.log_pow] at h1
    push_cast at h1
    linarith
  linarith

/-! ## Part 3. Non-vacuity: the collision `65 = 8² + 1² = 7² + 4²` -/

/-- The smallest Berggren collision, `65 = 8² + 1² = 7² + 4²`, extracts the divisor
`gcd (65, 8·7 + 1·4) = gcd (65, 60) = 5`, and the two nodes are indeed at least
`log 5 − log 2` apart.  (The exact value of the distance is `2.5773…`, comfortably above
the bound `0.9163…`.) -/
theorem collision_sixtyfive_dist_ge :
    Real.log 5 - Real.log 2
      ≤ dist (hpoint 8 1 (by norm_num)) (hpoint 7 4 (by norm_num)) := by
  have h := collision_dist_ge_log_divisor (N := 65) isSeed_eight_one isSeed_seven_four
    (by norm_num) (by norm_num) (by decide)
  have hg : Nat.gcd 65 (8 * 7 + 1 * 4) = 5 := by decide
  rw [hg] at h
  push_cast at h
  exact h

end BerggrenCollisionDistance