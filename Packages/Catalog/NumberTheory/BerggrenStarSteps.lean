import Catalog.NumberTheory.BerggrenStarLines

/-!
# Step lengths along the star arms, and the circles of the picture

Two further exact computations for the Berggren tree in the Poincaré half-plane.

## Main results

* `cosh_dist_hpoint_pair` : the **exact hyperbolic distance between two nodes**,
  `cosh d(z(m,n), z(m',n')) = ((nm' - n'm)² + m² + m'²)/(2mm')`.  The integer
  `nm' - n'm` is the determinant (cross product) of the two Euclid seeds; it is the only
  arithmetic invariant that enters.

* `armL_step_cosh`, `armR_step_cosh` : along a parabolic arm the step length is *exactly*
  computable, `cosh d = 1 + u²(u²+1)/(2A(A+u))` on the `1`-star and
  `cosh d = 1 + 2n²(n²+1)/(A(A+2n))` on the `0`-star.

* `armL_step_tendsto_zero`, `armR_step_tendsto_zero` : hence the hyperbolic steps along a
  star arm **tend to zero**.  A star arm is therefore an infinite hyperbolic ray of
  logarithmic total speed (`armL_dist_log_bounds`) made of ever shorter steps: this is why
  the arms look like continuous curves converging to the boundary point, and it is the
  precise opposite of a geodesic spine, where the step length is bounded below.

* `ball_iff_disc` : the **circles of the picture.**  A node lies in the hyperbolic ball of
  radius `R` about `i` if and only if the integer point `(m,n)` lies in the Euclidean disc
  of radius `sinh R` centred at `(cosh R, 0)`.  The visible level curves of the picture are
  exactly these discs pulled back through the embedding.
-/

namespace BerggrenStarSteps

open Real HyperbolicBerggrenGeodesics UpperHalfPlane Filter Topology

noncomputable section

/-! ## Part 1. The exact two-node distance -/

/-- **Exact distance between two nodes of the tree.**  The seed cross product
`nm' - n'm` is the only arithmetic input. -/
theorem cosh_dist_hpoint_pair (m n m' n' : ℕ) (hm : 0 < m) (hm' : 0 < m') :
    Real.cosh (dist (hpoint m n hm) (hpoint m' n' hm'))
      = (((n : ℝ) * m' - (n' : ℝ) * m) ^ 2 + (m : ℝ) ^ 2 + (m' : ℝ) ^ 2) / (2 * m * m') := by
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hM' : (0 : ℝ) < (m' : ℝ) := by exact_mod_cast hm'
  rw [UpperHalfPlane.cosh_dist']
  simp only [hpoint_re, hpoint_im]
  field_simp
  ring

/-- Comparison lemma: `cosh` is strictly monotone on the nonnegative reals. -/
theorem lt_of_cosh_lt {d e : ℝ} (hd : 0 ≤ d) (he : 0 ≤ e) (h : Real.cosh d < Real.cosh e) :
    d < e := by
  by_contra hc
  push_neg at hc
  have : Real.cosh e ≤ Real.cosh d := by
    rw [Real.cosh_le_cosh, abs_of_nonneg hd, abs_of_nonneg he]; exact hc
  linarith

/-! ## Part 2. Step lengths along the parabolic arms -/

/-- **Exact step length along a `1`-star arm.**  Writing `A = n + (k+1)u` for the first
coordinate of the `k`-th node, consecutive nodes of the arm satisfy
`cosh d = 1 + u²(u²+1)/(2A(A+u))`. -/
theorem armL_step_cosh (n u k : ℕ) (h : 0 < n + (k + 1) * u) (h' : 0 < n + (k + 2) * u) :
    Real.cosh (dist (hpoint (n + (k + 1) * u) (n + k * u) h)
        (hpoint (n + (k + 2) * u) (n + (k + 1) * u) h'))
      = 1 + (u : ℝ) ^ 2 * ((u : ℝ) ^ 2 + 1)
          / (2 * ((n : ℝ) + ((k : ℝ) + 1) * u) * ((n : ℝ) + ((k : ℝ) + 2) * u)) := by
  have hA : (0 : ℝ) < (n : ℝ) + ((k : ℝ) + 1) * u := by exact_mod_cast h
  have hB : (0 : ℝ) < (n : ℝ) + ((k : ℝ) + 2) * u := by exact_mod_cast h'
  have hA' : ((n : ℝ) + ((k : ℝ) + 1) * u) ≠ 0 := ne_of_gt hA
  have hB' : ((n : ℝ) + ((k : ℝ) + 2) * u) ≠ 0 := ne_of_gt hB
  rw [cosh_dist_hpoint_pair]
  have e1 : ((n + k * u : ℕ) : ℝ) = (n : ℝ) + (k : ℝ) * u := by push_cast; ring
  have e2 : ((n + (k + 1) * u : ℕ) : ℝ) = (n : ℝ) + ((k : ℝ) + 1) * u := by push_cast; ring
  have e3 : ((n + (k + 2) * u : ℕ) : ℝ) = (n : ℝ) + ((k : ℝ) + 2) * u := by push_cast; ring
  rw [e1, e2, e3]
  have hD : (0 : ℝ) < 2 * ((n : ℝ) + ((k : ℝ) + 1) * u) * ((n : ℝ) + ((k : ℝ) + 2) * u) := by
    positivity
  rw [show (1 : ℝ) + (u : ℝ) ^ 2 * ((u : ℝ) ^ 2 + 1)
        / (2 * ((n : ℝ) + ((k : ℝ) + 1) * u) * ((n : ℝ) + ((k : ℝ) + 2) * u))
      = (2 * ((n : ℝ) + ((k : ℝ) + 1) * u) * ((n : ℝ) + ((k : ℝ) + 2) * u)
          + (u : ℝ) ^ 2 * ((u : ℝ) ^ 2 + 1))
        / (2 * ((n : ℝ) + ((k : ℝ) + 1) * u) * ((n : ℝ) + ((k : ℝ) + 2) * u)) by
    rw [add_div, div_self (ne_of_gt hD)]]
  rw [div_left_inj' (ne_of_gt hD)]
  ring

/-- **Exact step length along a `0`-star arm.** -/
theorem armR_step_cosh (m n k : ℕ) (h : 0 < m + 2 * k * n) (h' : 0 < m + 2 * (k + 1) * n) :
    Real.cosh (dist (hpoint (m + 2 * k * n) n h) (hpoint (m + 2 * (k + 1) * n) n h'))
      = 1 + 2 * (n : ℝ) ^ 2 * ((n : ℝ) ^ 2 + 1)
          / (((m : ℝ) + 2 * (k : ℝ) * n) * ((m : ℝ) + 2 * ((k : ℝ) + 1) * n)) := by
  have hA : (0 : ℝ) < (m : ℝ) + 2 * (k : ℝ) * n := by exact_mod_cast h
  have hB : (0 : ℝ) < (m : ℝ) + 2 * ((k : ℝ) + 1) * n := by exact_mod_cast h'
  have hA' : ((m : ℝ) + 2 * (k : ℝ) * n) ≠ 0 := ne_of_gt hA
  have hB' : ((m : ℝ) + 2 * ((k : ℝ) + 1) * n) ≠ 0 := ne_of_gt hB
  rw [cosh_dist_hpoint_pair]
  have e1 : ((m + 2 * k * n : ℕ) : ℝ) = (m : ℝ) + 2 * (k : ℝ) * n := by push_cast; ring
  have e2 : ((m + 2 * (k + 1) * n : ℕ) : ℝ) = (m : ℝ) + 2 * ((k : ℝ) + 1) * n := by
    push_cast; ring
  rw [e1, e2]
  have hD : (0 : ℝ) < 2 * ((m : ℝ) + 2 * (k : ℝ) * n) * ((m : ℝ) + 2 * ((k : ℝ) + 1) * n) := by
    positivity
  have hD2 : (0 : ℝ) < ((m : ℝ) + 2 * (k : ℝ) * n) * ((m : ℝ) + 2 * ((k : ℝ) + 1) * n) := by
    positivity
  rw [show (1 : ℝ) + 2 * (n : ℝ) ^ 2 * ((n : ℝ) ^ 2 + 1)
        / (((m : ℝ) + 2 * (k : ℝ) * n) * ((m : ℝ) + 2 * ((k : ℝ) + 1) * n))
      = (2 * ((m : ℝ) + 2 * (k : ℝ) * n) * ((m : ℝ) + 2 * ((k : ℝ) + 1) * n)
          + 4 * (n : ℝ) ^ 2 * ((n : ℝ) ^ 2 + 1))
        / (2 * ((m : ℝ) + 2 * (k : ℝ) * n) * ((m : ℝ) + 2 * ((k : ℝ) + 1) * n)) by
    rw [add_div, div_self (ne_of_gt hD)]
    congr 1
    rw [div_eq_div_iff (ne_of_gt hD2) (ne_of_gt hD)]
    ring]
  rw [div_left_inj' (ne_of_gt hD)]
  ring

/-- A quantity of the shape `c/(A_k B_k)` with `A_k, B_k → ∞` tends to `0`. -/
theorem tendsto_const_div_mul_atTop {c : ℝ} {A B : ℕ → ℝ}
    (hA : Tendsto A atTop atTop) (hB : Tendsto B atTop atTop) :
    Tendsto (fun k => c / (A k * B k)) atTop (𝓝 0) :=
  Filter.Tendsto.div_atTop tendsto_const_nhds (hA.atTop_mul_atTop₀ hB)

/-- **The hyperbolic steps along a `1`-star arm tend to zero.** -/
theorem armL_step_tendsto_zero (n u : ℕ) (hu : 0 < u)
    (h : ∀ k : ℕ, 0 < n + (k + 1) * u) :
    Tendsto (fun k : ℕ => dist (hpoint (n + (k + 1) * u) (n + k * u) (h k))
        (hpoint (n + (k + 2) * u) (n + (k + 1) * u) (h (k + 1)))) atTop (𝓝 0) := by
  have huR : (0 : ℝ) < u := by exact_mod_cast hu
  -- the exact formula for the step
  have hstep : ∀ k : ℕ, Real.cosh (dist (hpoint (n + (k + 1) * u) (n + k * u) (h k))
      (hpoint (n + (k + 2) * u) (n + (k + 1) * u) (h (k + 1))))
      = 1 + (u : ℝ) ^ 2 * ((u : ℝ) ^ 2 + 1)
          / (2 * ((n : ℝ) + ((k : ℝ) + 1) * u) * ((n : ℝ) + ((k : ℝ) + 2) * u)) := by
    intro k
    have := armL_step_cosh n u k (h k) (by
      have := h (k + 1)
      have hcast : n + (k + 1 + 1) * u = n + (k + 2) * u := by ring_nf
      omega)
    convert this using 3
  -- the error term tends to zero
  have hAtop : Tendsto (fun k : ℕ => 2 * ((n : ℝ) + ((k : ℝ) + 1) * u)) atTop atTop := by
    apply Filter.Tendsto.const_mul_atTop (by norm_num)
    apply Filter.tendsto_atTop_add_const_left
    exact Filter.Tendsto.atTop_mul_const huR
      (Filter.tendsto_atTop_add_const_right _ 1 tendsto_natCast_atTop_atTop)
  have hBtop : Tendsto (fun k : ℕ => (n : ℝ) + ((k : ℝ) + 2) * u) atTop atTop := by
    apply Filter.tendsto_atTop_add_const_left
    exact Filter.Tendsto.atTop_mul_const huR
      (Filter.tendsto_atTop_add_const_right _ 2 tendsto_natCast_atTop_atTop)
  have herr : Tendsto (fun k : ℕ => (u : ℝ) ^ 2 * ((u : ℝ) ^ 2 + 1)
      / (2 * ((n : ℝ) + ((k : ℝ) + 1) * u) * ((n : ℝ) + ((k : ℝ) + 2) * u))) atTop (𝓝 0) :=
    tendsto_const_div_mul_atTop hAtop hBtop
  -- conclude by strict monotonicity of `cosh`
  rw [Metric.tendsto_atTop]
  intro ε hε
  have hcosh : (1 : ℝ) < Real.cosh ε := Real.one_lt_cosh.mpr (ne_of_gt hε)
  rw [Metric.tendsto_atTop] at herr
  obtain ⟨K, hK⟩ := herr (Real.cosh ε - 1) (by linarith)
  refine ⟨K, fun k hk => ?_⟩
  have h1 := hK k hk
  rw [Real.dist_eq, sub_zero] at h1
  have h2 : Real.cosh (dist (hpoint (n + (k + 1) * u) (n + k * u) (h k))
      (hpoint (n + (k + 2) * u) (n + (k + 1) * u) (h (k + 1)))) < Real.cosh ε := by
    rw [hstep k]
    have := le_abs_self ((u : ℝ) ^ 2 * ((u : ℝ) ^ 2 + 1)
      / (2 * ((n : ℝ) + ((k : ℝ) + 1) * u) * ((n : ℝ) + ((k : ℝ) + 2) * u)))
    linarith
  have h3 := lt_of_cosh_lt dist_nonneg hε.le h2
  rw [Real.dist_eq, sub_zero, abs_of_nonneg dist_nonneg]
  exact h3

/-! ## Part 3. The circles of the picture -/

/-- **The visible level curves.**  A node lies in the hyperbolic ball of radius `R` about
the base point `i` exactly when the integer point `(m,n)` lies in the Euclidean disc of
radius `sinh R` centred at `(cosh R, 0)`.  Thus the concentric hyperbolic circles of the
picture pull back to a family of ordinary Euclidean circles in the seed plane. -/
theorem ball_iff_disc (m n : ℕ) (hm : 0 < m) {R : ℝ} (hR : 0 ≤ R) :
    dist (hpoint m n hm) UpperHalfPlane.I ≤ R
      ↔ ((m : ℝ) - Real.cosh R) ^ 2 + (n : ℝ) ^ 2 ≤ Real.sinh R ^ 2 := by
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hcosh := cosh_dist_hpoint_I m n hm
  constructor
  · intro hle
    have h1 : Real.cosh (dist (hpoint m n hm) UpperHalfPlane.I) ≤ Real.cosh R := by
      rw [Real.cosh_le_cosh, abs_of_nonneg dist_nonneg, abs_of_nonneg hR]
      exact hle
    rw [hcosh, div_le_iff₀ (by positivity)] at h1
    have hsq : Real.cosh R ^ 2 - Real.sinh R ^ 2 = 1 := Real.cosh_sq_sub_sinh_sq R
    nlinarith [h1, hsq]
  · intro hdisc
    have hsq : Real.cosh R ^ 2 - Real.sinh R ^ 2 = 1 := Real.cosh_sq_sub_sinh_sq R
    have h1 : Real.cosh (dist (hpoint m n hm) UpperHalfPlane.I) ≤ Real.cosh R := by
      rw [hcosh, div_le_iff₀ (by positivity)]
      nlinarith [hdisc, hsq]
    rw [Real.cosh_le_cosh, abs_of_nonneg dist_nonneg, abs_of_nonneg hR] at h1
    exact h1

end

end BerggrenStarSteps