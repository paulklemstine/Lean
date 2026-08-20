import Catalog.Geometry.HyperbolicBerggrenGeodesics

/-!
# Boundary dynamics of the Berggren moves: two parabolic cusps and one hyperbolic axis

The three Berggren moves act on the *slope* `t = n/m ∈ (0,1)` of a Euclid seed by the
Möbius maps

  `B₁ : t ↦ 1/(2-t)`,  `B₂ : t ↦ 1/(2+t)`,  `B₃ : t ↦ t/(1+2t)`.

This file determines their boundary dynamics completely, and thereby explains the two
qualitatively different features of the picture of the tree in the half-plane: the
*stars* (families of curves converging to a boundary point at a polynomial rate) and the
*geodesic spine* (converging to a boundary point at an exponential rate).

## Main results

* `slope_seedL`, `slope_seedM`, `slope_seedR` : the three seed moves induce exactly these
  three Möbius maps on slopes.
* `sL_mem_Ioo`, `sM_mem_Ioo`, `sR_mem_Ioo` : the **slope trichotomy** `(1/2,1)`, `(1/3,1/2)`,
  `(0,1/3)`; in particular the three children of a node have pairwise distinct slopes
  (`children_slopes_distinct`).
* `sL_parabolic_normal_form`, `sR_parabolic_normal_form` : the two outer moves are
  **parabolic**: in the coordinate `1/(1-t)` (resp. `1/t`) they are the translations
  `x ↦ x + 1` (resp. `x ↦ x + 2`).
* `sL_iterate`, `sR_iterate` : consequently the orbits have exact closed forms, and
  (`sL_rate_exact`, `sR_rate_exact`) converge to the **rational** ideal points `1` and `0`
  at the exact parabolic rate `Θ(1/k)`.
* `sM_fixed_point`, `sM_contract`, `sM_iterate_dist` : the middle move is **hyperbolic**:
  it contracts by a factor `1/4` towards its fixed point `√2 - 1`, so its orbits converge
  exponentially fast; and `irrational_sM_fixed` shows the limit is **irrational**, hence
  not a cusp of the star.
* `boundary_tip_dichotomy`, `no_polynomial_lower_bound_for_sM` : the resulting dichotomy —
  polynomially slow convergence to rational tips versus exponentially fast convergence to
  an irrational tip.
-/

namespace BerggrenBoundaryDynamics

open Real HyperbolicBerggrenGeodesics Filter Topology

noncomputable section

/-! ## Part 1. The three moves in slope coordinates -/

/-- The slope action of the Berggren move `B₁`. -/
def sL (t : ℝ) : ℝ := 1 / (2 - t)

/-- The slope action of the Berggren move `B₂`. -/
def sM (t : ℝ) : ℝ := 1 / (2 + t)

/-- The slope action of the Berggren move `B₃`. -/
def sR (t : ℝ) : ℝ := t / (1 + 2 * t)

theorem slope_seedL {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    (((seedL (m, n)).2 : ℝ)) / ((seedL (m, n)).1 : ℝ) = sL ((n : ℝ) / m) := by
  have hm : 0 < m := lt_trans hn hnm
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hcast : (((2 * m - n : ℕ)) : ℝ) = 2 * (m : ℝ) - (n : ℝ) := by
    have : n ≤ 2 * m := by omega
    push_cast [Nat.cast_sub this]
    ring
  have hden : (0 : ℝ) < 2 * (m : ℝ) - (n : ℝ) := by
    have : (n : ℝ) < (m : ℝ) := by exact_mod_cast hnm
    linarith
  simp only [seedL, sL, hcast]
  rw [div_eq_div_iff (by linarith) (by
    have : (2 : ℝ) - (n : ℝ) / m > 0 := by
      rw [gt_iff_lt, sub_pos, div_lt_iff₀ hM]
      have : (n : ℝ) < (m : ℝ) := by exact_mod_cast hnm
      linarith
    positivity)]
  field_simp

theorem slope_seedM {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    (((seedM (m, n)).2 : ℝ)) / ((seedM (m, n)).1 : ℝ) = sM ((n : ℝ) / m) := by
  have hm : 0 < m := lt_trans hn hnm
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hN : (0 : ℝ) ≤ (n : ℝ) := by positivity
  simp only [seedM, sM]
  push_cast
  rw [div_eq_div_iff (by linarith) (by positivity)]
  field_simp

theorem slope_seedR {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    (((seedR (m, n)).2 : ℝ)) / ((seedR (m, n)).1 : ℝ) = sR ((n : ℝ) / m) := by
  have hm : 0 < m := lt_trans hn hnm
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hN : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  simp only [seedR, sR]
  push_cast
  rw [div_eq_div_iff (by linarith) (by positivity)]
  field_simp

/-! ## Part 2. The slope trichotomy -/

theorem sL_mem_Ioo {t : ℝ} (h0 : 0 < t) (h1 : t < 1) : 1 / 2 < sL t ∧ sL t < 1 := by
  have hd : (1 : ℝ) < 2 - t := by linarith
  constructor
  · rw [sL, lt_div_iff₀ (by linarith)]; linarith
  · rw [sL, div_lt_one (by linarith)]; linarith

theorem sM_mem_Ioo {t : ℝ} (h0 : 0 < t) (h1 : t < 1) : 1 / 3 < sM t ∧ sM t < 1 / 2 := by
  constructor
  · rw [sM, lt_div_iff₀ (by linarith)]; linarith
  · rw [sM, div_lt_div_iff₀ (by linarith) (by norm_num)]; linarith

theorem sR_mem_Ioo {t : ℝ} (h0 : 0 < t) (h1 : t < 1) : 0 < sR t ∧ sR t < 1 / 3 := by
  have hd : (0 : ℝ) < 1 + 2 * t := by linarith
  constructor
  · rw [sR]; positivity
  · rw [sR, div_lt_div_iff₀ hd (by norm_num)]; linarith

/-- **The three children of a node have pairwise distinct slopes**, since the three
Möbius images of `(0,1)` are disjoint. -/
theorem children_slopes_distinct {t : ℝ} (h0 : 0 < t) (h1 : t < 1) :
    sR t < sM t ∧ sM t < sL t := by
  obtain ⟨hL1, _⟩ := sL_mem_Ioo h0 h1
  obtain ⟨hM1, hM2⟩ := sM_mem_Ioo h0 h1
  obtain ⟨_, hR2⟩ := sR_mem_Ioo h0 h1
  exact ⟨by linarith, by linarith⟩

/-! ## Part 3. `B₁` and `B₃` are parabolic: exact normal forms and orbits -/

/-- **`B₁` is parabolic at the ideal point `1`:** in the coordinate `x = 1/(1-t)` it is
the unit translation `x ↦ x + 1`. -/
theorem sL_parabolic_normal_form {t : ℝ} (ht : t < 1) :
    1 / (1 - sL t) = 1 / (1 - t) + 1 := by
  have h1 : (0 : ℝ) < 1 - t := by linarith
  have h2 : (0 : ℝ) < 2 - t := by linarith
  have hsL : sL t = 1 / (2 - t) := rfl
  have h3 : 1 - sL t = (1 - t) / (2 - t) := by rw [hsL]; field_simp; ring
  rw [h3, one_div_div]
  field_simp
  ring

/-- **`B₃` is parabolic at the ideal point `0`:** in the coordinate `x = 1/t` it is the
translation `x ↦ x + 2`. -/
theorem sR_parabolic_normal_form {t : ℝ} (ht : 0 < t) :
    1 / sR t = 1 / t + 2 := by
  have hd : (0 : ℝ) < 1 + 2 * t := by linarith
  simp only [sR]
  field_simp

/-- **Exact closed form of the `B₁`-orbit of a slope.** -/
theorem sL_iterate (t : ℝ) (ht : t < 1) :
    ∀ k : ℕ, sL^[k] t = 1 - (1 - t) / (1 + k * (1 - t)) := by
  have ha : (0 : ℝ) < 1 - t := by linarith
  intro k
  induction k with
  | zero => simp
  | succ k ih =>
      have hden : (0 : ℝ) < 1 + (k : ℝ) * (1 - t) := by positivity
      have hden' : (0 : ℝ) < 1 + ((k : ℝ) + 1) * (1 - t) := by nlinarith
      rw [Function.iterate_succ_apply', ih]
      simp only [sL]
      push_cast
      have e1 : (2 : ℝ) - (1 - (1 - t) / (1 + (k : ℝ) * (1 - t)))
          = (1 + ((k : ℝ) + 1) * (1 - t)) / (1 + (k : ℝ) * (1 - t)) := by
        field_simp; ring
      rw [e1, one_div_div, eq_sub_iff_add_eq]
      field_simp
      ring

/-- **Exact closed form of the `B₃`-orbit of a slope.** -/
theorem sR_iterate (t : ℝ) (ht : 0 < t) :
    ∀ k : ℕ, sR^[k] t = t / (1 + 2 * k * t) := by
  intro k
  induction k with
  | zero => simp
  | succ k ih =>
      have hden : (0 : ℝ) < 1 + 2 * (k : ℝ) * t := by positivity
      rw [Function.iterate_succ_apply', ih]
      simp only [sR]
      have hden' : (0 : ℝ) < 1 + 2 * ((k : ℝ) + 1) * t := by positivity
      have e1 : 1 + 2 * (t / (1 + 2 * (k : ℝ) * t))
          = (1 + 2 * ((k : ℝ) + 1) * t) / (1 + 2 * (k : ℝ) * t) := by
        field_simp; ring
      have hcancel : ∀ a b c : ℝ, b ≠ 0 → c ≠ 0 → (a / b) / (c / b) = a / c := by
        intro a b c hb hc; field_simp
      rw [e1, hcancel t _ _ (ne_of_gt hden) (ne_of_gt hden')]
      push_cast
      ring

/-- The `B₁`-orbit of a slope converges to the **rational** ideal point `1`, and the exact
parabolic rate is `1/k`: `k·(1 - t_k) → 1`. -/
theorem sL_rate_exact (t : ℝ) (ht : t < 1) :
    Tendsto (fun k : ℕ => (k : ℝ) * (1 - sL^[k] t)) atTop (𝓝 1) := by
  have ha : (0 : ℝ) < 1 - t := by linarith
  have hEq : ∀ k : ℕ, (k : ℝ) * (1 - sL^[k] t)
      = 1 - 1 / (1 + (k : ℝ) * (1 - t)) := by
    intro k
    rw [sL_iterate t ht k]
    have hden : (0 : ℝ) < 1 + (k : ℝ) * (1 - t) := by positivity
    field_simp
    ring
  simp only [hEq]
  have h0 : Tendsto (fun k : ℕ => 1 / (1 + (k : ℝ) * (1 - t))) atTop (𝓝 0) := by
    apply Filter.Tendsto.div_atTop tendsto_const_nhds
    apply Filter.tendsto_atTop_add_const_left
    exact Filter.Tendsto.atTop_mul_const ha tendsto_natCast_atTop_atTop
  simpa using tendsto_const_nhds.sub h0

theorem sL_tendsto_one (t : ℝ) (ht : t < 1) :
    Tendsto (fun k : ℕ => sL^[k] t) atTop (𝓝 1) := by
  have ha : (0 : ℝ) < 1 - t := by linarith
  simp only [sL_iterate t ht]
  have h0 : Tendsto (fun k : ℕ => (1 - t) / (1 + (k : ℝ) * (1 - t))) atTop (𝓝 0) := by
    apply Filter.Tendsto.div_atTop tendsto_const_nhds
    apply Filter.tendsto_atTop_add_const_left
    exact Filter.Tendsto.atTop_mul_const ha tendsto_natCast_atTop_atTop
  simpa using tendsto_const_nhds.sub h0

/-- The `B₃`-orbit of a slope converges to the **rational** ideal point `0` at the exact
parabolic rate `1/(2k)`: `k · t_k → 1/2`. -/
theorem sR_rate_exact (t : ℝ) (ht : 0 < t) :
    Tendsto (fun k : ℕ => (k : ℝ) * sR^[k] t) atTop (𝓝 (1 / 2)) := by
  have hEq : ∀ k : ℕ, (k : ℝ) * sR^[k] t = 1 / 2 - (1 / 2) / (1 + 2 * (k : ℝ) * t) := by
    intro k
    rw [sR_iterate t ht k]
    have hden : (0 : ℝ) < 1 + 2 * (k : ℝ) * t := by positivity
    field_simp
    ring
  simp only [hEq]
  have h0 : Tendsto (fun k : ℕ => (1 / 2 : ℝ) / (1 + 2 * (k : ℝ) * t)) atTop (𝓝 0) := by
    apply Filter.Tendsto.div_atTop tendsto_const_nhds
    apply Filter.tendsto_atTop_add_const_left
    have : Tendsto (fun k : ℕ => 2 * (k : ℝ)) atTop atTop :=
      Filter.Tendsto.const_mul_atTop (by norm_num) tendsto_natCast_atTop_atTop
    exact Filter.Tendsto.atTop_mul_const ht this
  simpa using tendsto_const_nhds.sub h0

theorem sR_tendsto_zero (t : ℝ) (ht : 0 < t) :
    Tendsto (fun k : ℕ => sR^[k] t) atTop (𝓝 0) := by
  simp only [sR_iterate t ht]
  apply Filter.Tendsto.div_atTop tendsto_const_nhds
  apply Filter.tendsto_atTop_add_const_left
  have : Tendsto (fun k : ℕ => 2 * (k : ℝ)) atTop atTop :=
    Filter.Tendsto.const_mul_atTop (by norm_num) tendsto_natCast_atTop_atTop
  exact Filter.Tendsto.atTop_mul_const ht this

/-! ## Part 4. `B₂` is hyperbolic: an irrational fixed point, reached exponentially -/

/-- The fixed point of the middle move is the *silver* slope `√2 - 1`. -/
theorem sM_fixed_point : sM (Real.sqrt 2 - 1) = Real.sqrt 2 - 1 := by
  have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have hpos : (0 : ℝ) < 1 + Real.sqrt 2 := by positivity
  simp only [sM]
  rw [div_eq_iff (by intro h; nlinarith [Real.sqrt_nonneg 2])]
  nlinarith [h2]

/-- The fixed point is **irrational**: the hyperbolic axis of `B₂` does not end at a cusp
of the star. -/
theorem irrational_sM_fixed : Irrational (Real.sqrt 2 - 1) := by
  rw [show (1 : ℝ) = ((1 : ℤ) : ℝ) by norm_num]
  exact irrational_sqrt_two.sub_intCast 1

/-- `sM` maps nonnegative slopes to nonnegative slopes. -/
theorem sM_nonneg {t : ℝ} (ht : 0 ≤ t) : 0 ≤ sM t := by
  have h2 : (0 : ℝ) < 2 + t := by linarith
  simp only [sM]
  exact div_nonneg zero_le_one h2.le

/-- **`B₂` is a `1/4`-contraction on nonnegative slopes.** -/
theorem sM_contract {s t : ℝ} (hs : 0 ≤ s) (ht : 0 ≤ t) :
    |sM s - sM t| ≤ |s - t| / 4 := by
  have hs2 : (0 : ℝ) < 2 + s := by linarith
  have ht2 : (0 : ℝ) < 2 + t := by linarith
  have hkey : sM s - sM t = (t - s) / ((2 + s) * (2 + t)) := by
    simp only [sM]; field_simp; ring
  have hD : (0 : ℝ) < (2 + s) * (2 + t) := by positivity
  have h4 : (4 : ℝ) ≤ (2 + s) * (2 + t) := by nlinarith
  rw [hkey, abs_div, abs_of_pos hD, div_le_div_iff₀ hD (by norm_num : (0 : ℝ) < 4),
    abs_sub_comm t s]
  nlinarith [abs_nonneg (s - t)]

/-- **Exponential convergence of a `B₂`-orbit to the silver slope.** -/
theorem sM_iterate_dist {t : ℝ} (ht : 0 ≤ t) :
    ∀ k : ℕ, |sM^[k] t - (Real.sqrt 2 - 1)| ≤ (1 / 4) ^ k * |t - (Real.sqrt 2 - 1)| := by
  have hx : (0 : ℝ) ≤ Real.sqrt 2 - 1 := by
    nlinarith [Real.sq_sqrt (show (0:ℝ) ≤ 2 by norm_num), Real.sqrt_nonneg 2]
  have hiter_nonneg : ∀ k : ℕ, 0 ≤ sM^[k] t := by
    intro k
    induction k with
    | zero => simpa using ht
    | succ k ih => rw [Function.iterate_succ_apply']; exact sM_nonneg ih
  intro k
  induction k with
  | zero => simp
  | succ k ih =>
      rw [Function.iterate_succ_apply']
      have hstep : |sM (sM^[k] t) - sM (Real.sqrt 2 - 1)|
          ≤ |sM^[k] t - (Real.sqrt 2 - 1)| / 4 := sM_contract (hiter_nonneg k) hx
      rw [sM_fixed_point] at hstep
      have : |sM^[k] t - (Real.sqrt 2 - 1)| / 4 ≤ (1 / 4) ^ (k + 1) * |t - (Real.sqrt 2 - 1)| := by
        have h4 : (0 : ℝ) < 4 := by norm_num
        rw [div_le_iff₀ h4]
        calc |sM^[k] t - (Real.sqrt 2 - 1)|
            ≤ (1 / 4) ^ k * |t - (Real.sqrt 2 - 1)| := ih
          _ = (1 / 4) ^ (k + 1) * |t - (Real.sqrt 2 - 1)| * 4 := by ring
      linarith

theorem sM_tendsto_fixed {t : ℝ} (ht : 0 ≤ t) :
    Tendsto (fun k : ℕ => sM^[k] t) atTop (𝓝 (Real.sqrt 2 - 1)) := by
  rw [tendsto_iff_dist_tendsto_zero]
  apply squeeze_zero (fun k => dist_nonneg) (g := fun k : ℕ =>
      (1 / 4 : ℝ) ^ k * |t - (Real.sqrt 2 - 1)|)
  · intro k
    rw [Real.dist_eq]
    exact sM_iterate_dist ht k
  · have : Tendsto (fun k : ℕ => (1 / 4 : ℝ) ^ k) atTop (𝓝 0) :=
      tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)
    simpa using this.mul_const |t - (Real.sqrt 2 - 1)|

/-! ## Part 5. The dichotomy -/

/-- **Boundary tip dichotomy.**  From any interior slope the two outer moves drive the
slope to the *rational* ideal points `1` and `0` — the tips of the two stars — at the
parabolic rate `Θ(1/k)`, while the middle move drives it to the *irrational* point
`√2 - 1` at an exponential rate.  Rational tips are therefore stars, and the middle limit
is not a star tip at all. -/
theorem boundary_tip_dichotomy {t : ℝ} (h0 : 0 < t) (h1 : t < 1) :
    Tendsto (fun k : ℕ => sL^[k] t) atTop (𝓝 1) ∧
    Tendsto (fun k : ℕ => sR^[k] t) atTop (𝓝 0) ∧
    Tendsto (fun k : ℕ => sM^[k] t) atTop (𝓝 (Real.sqrt 2 - 1)) ∧
    Irrational (Real.sqrt 2 - 1) ∧
    Tendsto (fun k : ℕ => (k : ℝ) * (1 - sL^[k] t)) atTop (𝓝 1) :=
  ⟨sL_tendsto_one t h1, sR_tendsto_zero t h0, sM_tendsto_fixed h0.le, irrational_sM_fixed,
    sL_rate_exact t h1⟩

/-- **The middle move converges faster than any parabolic arm:** the error after `k` steps
is at most `4^{-k}`, whereas along a `B₁`-arm the error times `k` tends to `1`.  In
particular no `B₁`-arm can be reparametrised to a `B₂`-orbit. -/
theorem no_polynomial_lower_bound_for_sM {t : ℝ} (h0 : 0 < t) :
    Tendsto (fun k : ℕ => (k : ℝ) ^ 2 * |sM^[k] t - (Real.sqrt 2 - 1)|) atTop (𝓝 0) := by
  apply squeeze_zero (g := fun k : ℕ => (k : ℝ) ^ 2 * ((1 / 4 : ℝ) ^ k * |t - (Real.sqrt 2 - 1)|))
  · intro k; positivity
  · intro k
    have := sM_iterate_dist h0.le k
    have hk : (0 : ℝ) ≤ (k : ℝ) ^ 2 := by positivity
    exact mul_le_mul_of_nonneg_left this hk
  · have hpoly : Tendsto (fun k : ℕ => (k : ℝ) ^ 2 * (1 / 4 : ℝ) ^ k) atTop (𝓝 0) := by
      exact tendsto_pow_const_mul_const_pow_of_lt_one 2 (by norm_num) (by norm_num)
    have := hpoly.mul_const |t - (Real.sqrt 2 - 1)|
    simpa [mul_assoc] using this

end

end BerggrenBoundaryDynamics