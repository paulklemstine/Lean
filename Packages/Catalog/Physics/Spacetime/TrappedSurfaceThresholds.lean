/-
  The exact boundary condition for "trapped surface ⇒ geodesic incompleteness".

  The Penrose theorem needs the energy condition `Ric(k,k) ≥ 0`.  Physically the relevant
  question is how much violation it tolerates.  This file answers it exactly, for a
  constant defect `c ≥ 0` (`Ric(k,k) ≥ -c`, e.g. a positive cosmological constant or a
  bounded quantum energy density):

  * if the surface is trapped *strongly enough* — `θ₀² > m c` — the generators are still
    incomplete, with the explicit affine bound `m |θ₀| / (θ₀² - m c)`
    (`DefectCongruence.affine_length_le`);
  * at the threshold `θ₀² = m c` the conclusion fails completely: there is an *eternal*
    exact solution of the Raychaudhuri equation with `Ric(k,k) = -c`, converging
    (`θ₀ = -√(mc) < 0`) and defined for arbitrarily large affine parameter
    (`defect_threshold_eternal`).

  So `θ₀² > m c` is a sharp boundary condition, not an artefact of the proof.
-/

import Physics.Spacetime.AveragedEnergyFocusing

open Set

namespace Catalog.Physics.Spacetime

/-- A geodesic congruence in which the energy condition may be violated by at most the
constant `c`: `Ric(k,k) ≥ -c`. -/
structure DefectCongruence (m L c : ℝ) where
  /-- The expansion scalar `θ`. -/
  expansion : ℝ → ℝ
  /-- Its affine derivative. -/
  expansionDot : ℝ → ℝ
  /-- The squared shear `σ²`. -/
  shearSq : ℝ → ℝ
  /-- The curvature term `Ric(k,k)`, allowed to be negative down to `-c`. -/
  ricci : ℝ → ℝ
  hasDeriv : ∀ t ∈ Ico (0 : ℝ) L, HasDerivAt expansion (expansionDot t) t
  raychaudhuri : ∀ t ∈ Ico (0 : ℝ) L,
    expansionDot t = -(expansion t) ^ 2 / m - shearSq t - ricci t
  shearSq_nonneg : ∀ t ∈ Ico (0 : ℝ) L, 0 ≤ shearSq t
  energy_defect : ∀ t ∈ Ico (0 : ℝ) L, -c ≤ ricci t

namespace DefectCongruence

variable {m L c : ℝ} (C : DefectCongruence m L c)

/-- The Raychaudhuri equation with a bounded energy-condition violation gives the
perturbed focusing inequality `θ' ≤ -θ²/m + c`. -/
theorem expansionDot_le : ∀ t ∈ Ico (0 : ℝ) L,
    C.expansionDot t ≤ -(C.expansion t) ^ 2 / m + c := by
  intro t ht
  have h := C.raychaudhuri t ht
  have h1 := C.shearSq_nonneg t ht
  have h2 := C.energy_defect t ht
  rw [h]
  linarith

/-- **Trapped surfaces still focus under a bounded energy violation.**  If the initial
convergence beats the defect, `θ₀² > m c`, the affine length obeys the explicit bound
`m |θ₀| / (θ₀² - m c)`, which degrades continuously to the Penrose bound `m/|θ₀|` as
`c → 0` and blows up as `θ₀² → (m c)⁺`. -/
theorem affine_length_le (hm : 0 < m) (hc : 0 ≤ c) (htrap : C.expansion 0 < 0)
    (hthr : m * c < (C.expansion 0) ^ 2) :
    L ≤ m * (-C.expansion 0) / ((C.expansion 0) ^ 2 - m * c) :=
  focusing_domain_bound_of_energy_defect hm hc C.hasDeriv C.expansionDot_le htrap hthr

end DefectCongruence

/-- **Sharpness of the threshold.**  For every `m, c > 0` and every affine length `L`
there is a trapped (`θ₀ < 0`) congruence with energy defect exactly `c` that solves the
Raychaudhuri equation *exactly* on `[0, L)` — the constant solution `θ ≡ -√(mc)`, whose
initial expansion saturates `θ₀² = m c`.  Hence no incompleteness conclusion can be drawn
at the threshold, and the strict inequality in `DefectCongruence.affine_length_le` is
necessary. -/
theorem defect_threshold_eternal {m c : ℝ} (hm : 0 < m) (hc : 0 < c) (L : ℝ) :
    ∃ C : DefectCongruence m L c, C.expansion 0 < 0 ∧ (C.expansion 0) ^ 2 = m * c := by
  have hmc : (0 : ℝ) ≤ m * c := by positivity
  have hsq : Real.sqrt (m * c) ^ 2 = m * c := Real.sq_sqrt hmc
  refine ⟨{ expansion := fun _ => -Real.sqrt (m * c)
            expansionDot := fun _ => 0
            shearSq := fun _ => 0
            ricci := fun _ => -c
            hasDeriv := fun t _ => hasDerivAt_const t _
            raychaudhuri := ?_
            shearSq_nonneg := fun t _ => le_rfl
            energy_defect := fun t _ => le_rfl }, ?_, ?_⟩
  · intro t _
    have h : (-Real.sqrt (m * c)) ^ 2 = m * c := by rw [neg_pow]; simpa using hsq
    show (0 : ℝ) = -(-Real.sqrt (m * c)) ^ 2 / m - 0 - -c
    rw [h]
    field_simp
    ring
  · show -Real.sqrt (m * c) < 0
    simpa using Real.sqrt_pos.2 (by positivity)
  · show (-Real.sqrt (m * c)) ^ 2 = m * c
    rw [neg_pow]
    simpa using hsq

/-! ### The sharp (logarithmic) focusing time above the threshold -/

section SharpDefect

variable {m a L : ℝ} {θ θ' : ℝ → ℝ}

/-- The "hyperbolic phase" `(m/2a) log((θ-a)/(θ+a))` of a strongly converging expansion
decreases at unit rate under `θ' ≤ -(θ² - a²)/m`.  (For `θ < -a` the argument of the
logarithm exceeds `1`, so the phase is positive.) -/
theorem hyperbolic_phase_decay (hm : 0 < m) (ha : 0 < a)
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hineq : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -((θ x) ^ 2 - a ^ 2) / m)
    (h0 : θ 0 < -a) (hle : ∀ t ∈ Ico (0 : ℝ) L, θ t ≤ θ 0) :
    ∀ t ∈ Ico (0 : ℝ) L, m / (2 * a) * Real.log ((θ t - a) / (θ t + a))
      ≤ m / (2 * a) * Real.log ((θ 0 - a) / (θ 0 + a)) - t := by
  have hlt : ∀ x ∈ Ico (0 : ℝ) L, θ x < -a := fun x hx => lt_of_le_of_lt (hle x hx) h0
  have hderiv : ∀ x ∈ Ico (0 : ℝ) L,
      HasDerivAt (fun s => m / (2 * a) * Real.log ((θ s - a) / (θ s + a)))
        (m * θ' x / ((θ x) ^ 2 - a ^ 2)) x := by
    intro x hx
    have hx1 : θ x < -a := hlt x hx
    have hne1 : θ x - a ≠ 0 := by nlinarith
    have hne2 : θ x + a ≠ 0 := by nlinarith
    have hne3 : (θ x) ^ 2 - a ^ 2 ≠ 0 := by nlinarith
    have hu : HasDerivAt (fun s => (θ s - a) / (θ s + a))
        ((θ' x * (θ x + a) - (θ x - a) * θ' x) / (θ x + a) ^ 2) x :=
      ((hd x hx).sub_const a).div ((hd x hx).add_const a) hne2
    have hupos : 0 < (θ x - a) / (θ x + a) := by
      apply div_pos_of_neg_of_neg <;> nlinarith
    have hlog := (Real.hasDerivAt_log (ne_of_gt hupos)).comp x hu
    have h2 := hlog.const_mul (m / (2 * a))
    convert h2 using 1
    field_simp
    ring
  intro t ht
  have hsub : Ico (0 : ℝ) t ⊆ Ico (0 : ℝ) L := Ico_subset_Ico le_rfl ht.2.le
  have hsub2 : Icc (0 : ℝ) t ⊆ Ico (0 : ℝ) L := fun x hx => ⟨hx.1, lt_of_le_of_lt hx.2 ht.2⟩
  refine image_le_of_deriv_right_le_deriv_boundary
    (f := fun s => m / (2 * a) * Real.log ((θ s - a) / (θ s + a)))
    (f' := fun x => m * θ' x / ((θ x) ^ 2 - a ^ 2))
    (B := fun s => m / (2 * a) * Real.log ((θ 0 - a) / (θ 0 + a)) - s)
    (B' := fun _ => -1) ?_ ?_ (by simp) ?_ ?_ ?_ (right_mem_Icc.2 ht.1)
  · exact fun x hx => (hderiv x (hsub2 hx)).continuousAt.continuousWithinAt
  · exact fun x hx => (hderiv x (hsub hx)).hasDerivWithinAt
  · fun_prop
  · intro x _
    simpa using ((hasDerivAt_id x).const_sub
      (m / (2 * a) * Real.log ((θ 0 - a) / (θ 0 + a)))).hasDerivWithinAt
  · intro x hx
    have hx1 : θ x < -a := hlt x (hsub hx)
    have hden : 0 < (θ x) ^ 2 - a ^ 2 := by nlinarith
    have h1 : θ' x ≤ -((θ x) ^ 2 - a ^ 2) / m := hineq x (hsub hx)
    show m * θ' x / ((θ x) ^ 2 - a ^ 2) ≤ -1
    rw [div_le_iff₀ hden]
    have h2 : θ' x * m ≤ -((θ x) ^ 2 - a ^ 2) := (le_div_iff₀ hm).1 h1
    nlinarith [h2]

/-- **Sharp focusing time under a constant energy defect.**  With `a = √(m c)`, a
congruence obeying `θ' ≤ -θ²/m + c` and starting strictly below the threshold
(`θ₀ < -a`) has affine length at most `(m / 2a) log((θ₀ - a)/(θ₀ + a))`, which is exactly
the blow-up time of the corresponding exact solution — strictly sharper than the
quadratic estimate `m|θ₀|/(θ₀² - m c)`, and diverging logarithmically as `θ₀ → -a`. -/
theorem sharp_defect_focusing_bound (hm : 0 < m) (ha : 0 < a)
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hineq : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -((θ x) ^ 2 - a ^ 2) / m)
    (h0 : θ 0 < -a) :
    L ≤ m / (2 * a) * Real.log ((θ 0 - a) / (θ 0 + a)) := by
  have hle : ∀ t ∈ Ico (0 : ℝ) L, θ t ≤ θ 0 := by
    refine le_init_of_contact_deriv_neg hd ?_
    intro x hx hxe
    have h1 := hineq x hx
    rw [hxe] at h1
    have h2 : 0 < (θ 0) ^ 2 - a ^ 2 := by nlinarith
    have h3 : -((θ 0) ^ 2 - a ^ 2) / m < 0 := div_neg_of_neg_of_pos (by linarith) hm
    linarith
  have hlt : ∀ x ∈ Ico (0 : ℝ) L, θ x < -a := fun x hx => lt_of_le_of_lt (hle x hx) h0
  have hphase := hyperbolic_phase_decay hm ha hd hineq h0 hle
  set Bd : ℝ := m / (2 * a) * Real.log ((θ 0 - a) / (θ 0 + a)) with hBd
  have hposphase : ∀ t ∈ Ico (0 : ℝ) L,
      0 < m / (2 * a) * Real.log ((θ t - a) / (θ t + a)) := by
    intro t ht
    have hx1 : θ t < -a := hlt t ht
    have hone : 1 < (θ t - a) / (θ t + a) := by
      rw [lt_div_iff_of_neg (by nlinarith : θ t + a < 0)]
      nlinarith
    have := Real.log_pos hone
    have hfac : 0 < m / (2 * a) := div_pos hm (by linarith)
    exact mul_pos hfac this
  have hstep : ∀ t ∈ Ico (0 : ℝ) L, t ≤ Bd := by
    intro t ht
    have h1 := hphase t ht
    have h2 := hposphase t ht
    linarith
  have hBdpos : 0 < Bd := by
    have hone : 1 < (θ 0 - a) / (θ 0 + a) := by
      rw [lt_div_iff_of_neg (by nlinarith : θ 0 + a < 0)]
      nlinarith
    exact mul_pos (div_pos hm (by linarith)) (Real.log_pos hone)
  by_contra hcon
  push_neg at hcon
  have ht : (Bd + L) / 2 ∈ Ico (0 : ℝ) L := ⟨by linarith, by linarith⟩
  have := hstep _ ht
  linarith

/-- The sharp logarithmic focusing time, applied to a congruence with constant energy
defect `c`: strong trapping `θ₀ < -√(mc)` gives affine length at most
`(m / 2√(mc)) log((θ₀ - √(mc))/(θ₀ + √(mc)))`. -/
theorem DefectCongruence.affine_length_le_sharp {c : ℝ} (C : DefectCongruence m L c)
    (hm : 0 < m) (hc : 0 < c) (htrap : C.expansion 0 < -Real.sqrt (m * c)) :
    L ≤ m / (2 * Real.sqrt (m * c)) *
      Real.log ((C.expansion 0 - Real.sqrt (m * c)) / (C.expansion 0 + Real.sqrt (m * c))) := by
  have hapos : 0 < Real.sqrt (m * c) := Real.sqrt_pos.2 (by positivity)
  have hasq : Real.sqrt (m * c) ^ 2 = m * c := Real.sq_sqrt (by positivity)
  refine sharp_defect_focusing_bound hm hapos C.hasDeriv ?_ htrap
  intro x hx
  have h := C.expansionDot_le x hx
  have hrw : -((C.expansion x) ^ 2 - Real.sqrt (m * c) ^ 2) / m
      = -(C.expansion x) ^ 2 / m + c := by
    rw [hasq]
    field_simp
    ring
  rw [hrw]
  exact h

end SharpDefect

/-- **The dichotomy at the boundary.**  For a trapped congruence with energy defect `c`,
`θ₀² > m c` is exactly the condition that forces incompleteness: above the threshold the
affine length is bounded (first component), at the threshold an eternal congruence exists
(second component). -/
theorem trapped_focusing_dichotomy {m c : ℝ} (hm : 0 < m) (hc : 0 < c) :
    (∀ (L : ℝ) (C : DefectCongruence m L c), C.expansion 0 < 0 →
        m * c < (C.expansion 0) ^ 2 →
        L ≤ m * (-C.expansion 0) / ((C.expansion 0) ^ 2 - m * c)) ∧
      (∀ L : ℝ, ∃ C : DefectCongruence m L c,
        C.expansion 0 < 0 ∧ (C.expansion 0) ^ 2 = m * c) :=
  ⟨fun _ C htrap hthr => C.affine_length_le hm hc.le htrap hthr,
   fun L' => defect_threshold_eternal hm hc L'⟩

end Catalog.Physics.Spacetime