/-
  Rigidity at the boundary of the focusing bounds.

  The comparison theorems of `RaychaudhuriFocusing` and `MyersFocusing` are inequalities:
  a congruence obeying the Raychaudhuri equation with non-negative shear and a pointwise
  energy condition focuses *at least* as fast as the model solution.  This file proves the
  corresponding **equality case** (Conjecture 3 of `FUTURE_DIRECTIONS.md`): if the
  comparison is saturated at a *single* interior affine parameter `t₀`, then it is
  saturated on the whole of `[0, t₀]` and the congruence is, there, exactly the model:

  * `riccati_rigidity` / `GeodesicCongruence.rigidity_of_saturated_penrose` —
    equality with `riccatiSol` at one point forces `θ = riccatiSol` on `[0, t₀]` and
    `σ² ≡ 0`, `Ric(k,k) ≡ 0` on `(0, t₀)`: the saturating congruence is shear-free and
    Ricci-flat.
  * `prufer_rigidity` / `GeodesicCongruence.rigidity_of_saturated_myers` —
    equality in the Prüfer phase estimate at one point forces the explicit tangent profile
    `θ t = √(mε) · tan(arctan(θ₀/√(mε)) - √(ε/m) · t)` and `σ² ≡ 0`, `Ric(k,k) ≡ ε`.

  Everything rests on a single analytic principle, isolated in
  `eq_affine_of_saturated_growth`: a function whose derivative is bounded below by `k`
  and which realises the resulting linear growth over `[a, b]` is *affine* with slope `k`
  there, so its derivative equals `k` at every interior point.  Applied to the reciprocal
  expansion `1/θ` (slope `1/m`) it gives Penrose rigidity; applied to the Prüfer angle
  `-arctan(θ/√(mε))` (slope `√(ε/m)`) it gives Myers rigidity.  The two proofs of the
  focusing bounds thus lose information only through the inequalities `σ² ≥ 0` and
  `Ric ≥ 0` (resp. `Ric ≥ ε`), and equality in the conclusion returns them pointwise.
-/

import Physics.Spacetime.MyersFocusing

open Set

namespace Catalog.Physics.Spacetime

section AffineRigidity

variable {a b k : ℝ} {f f' : ℝ → ℝ}

/-- A function with everywhere non-negative derivative on `[a, b]` is monotone there.
(Stated with `HasDerivAt` data rather than `deriv`, which is the form produced by the
Raychaudhuri layer.) -/
theorem monotoneOn_of_hasDerivAt_nonneg
    (hd : ∀ x ∈ Icc a b, HasDerivAt f (f' x) x)
    (hf' : ∀ x ∈ Ioo a b, 0 ≤ f' x) :
    MonotoneOn f (Icc a b) := by
  refine monotoneOn_of_deriv_nonneg (convex_Icc a b) ?_ ?_ ?_
  · exact fun x hx => (hd x hx).continuousAt.continuousWithinAt
  · intro x hx
    rw [interior_Icc] at hx
    exact ((hd x (Ioo_subset_Icc_self hx)).differentiableAt).differentiableWithinAt
  · intro x hx
    rw [interior_Icc] at hx
    rw [(hd x (Ioo_subset_Icc_self hx)).deriv]
    exact hf' x hx

/-- **The rigidity principle.**  If `f' ≥ k` on `(a, b)` and `f` realises the extremal
linear growth `f b = f a + k (b - a)`, then `f` is affine with slope `k` on `[a, b]`, and
consequently `f' = k` at every interior point.  This is the equality case of the mean
value inequality, in the form needed for the focusing theorems. -/
theorem eq_affine_of_saturated_growth
    (hd : ∀ x ∈ Icc a b, HasDerivAt f (f' x) x)
    (hf' : ∀ x ∈ Ioo a b, k ≤ f' x)
    (hsat : f b = f a + k * (b - a)) :
    (∀ t ∈ Icc a b, f t = f a + k * (t - a)) ∧ (∀ t ∈ Ioo a b, f' t = k) := by
  set g : ℝ → ℝ := fun x => f x - k * x with hg
  set g' : ℝ → ℝ := fun x => f' x - k with hg'
  have hdg : ∀ x ∈ Icc a b, HasDerivAt g (g' x) x := by
    intro x hx
    simpa [hg, hg'] using (hd x hx).sub ((hasDerivAt_id x).const_mul k)
  have hg'nonneg : ∀ x ∈ Ioo a b, 0 ≤ g' x := by
    intro x hx
    have := hf' x hx
    simp only [hg']
    linarith
  have hmono : MonotoneOn g (Icc a b) := monotoneOn_of_hasDerivAt_nonneg hdg hg'nonneg
  have hgab : g b = g a := by
    simp only [hg, hsat]
    ring
  have hval : ∀ t ∈ Icc a b, f t = f a + k * (t - a) := by
    intro t ht
    have h1 : g a ≤ g t := hmono (left_mem_Icc.2 (ht.1.trans ht.2)) ht ht.1
    have h2 : g t ≤ g b := hmono ht (right_mem_Icc.2 (ht.1.trans ht.2)) ht.2
    rw [hgab] at h2
    have : g t = g a := le_antisymm h2 h1
    simp only [hg] at this
    linarith
  refine ⟨hval, ?_⟩
  intro t ht
  have hmem : Ioo a b ∈ nhds t := Ioo_mem_nhds ht.1 ht.2
  have heq : f =ᶠ[nhds t] fun x => f a + k * (x - a) := by
    filter_upwards [hmem] with x hx using hval x (Ioo_subset_Icc_self hx)
  have haff : HasDerivAt (fun x : ℝ => f a + k * (x - a)) k t := by
    simpa using (((hasDerivAt_id t).sub_const a).const_mul k).const_add (f a)
  have : HasDerivAt f k t := haff.congr_of_eventuallyEq heq
  exact (hd t (Ioo_subset_Icc_self ht)).unique this

end AffineRigidity

/-! ### Rigidity of the Penrose bound -/

section PenroseRigidity

variable {m L : ℝ} {θ θ' : ℝ → ℝ}

/-- **Penrose rigidity.**  Let `θ` obey the Raychaudhuri inequality `θ' ≤ -θ²/m` with
`θ 0 < 0`.  If at a single interior parameter `t₀` the expansion *equals* the model
Riccati solution (rather than merely being bounded by it, as `expansion_comparison`
guarantees), then `θ` coincides with the model on all of `[0, t₀]` and satisfies the
Raychaudhuri **equation** with vanishing defect on `(0, t₀)`. -/
theorem riccati_rigidity (hm : 0 < m) {t0 : ℝ} (ht0 : 0 < t0) (ht0L : t0 < L)
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hineq : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / m)
    (h0 : θ 0 < 0)
    (hsat : θ t0 = riccatiSol m (θ 0) t0) :
    (∀ t ∈ Icc (0 : ℝ) t0, θ t = riccatiSol m (θ 0) t) ∧
      (∀ t ∈ Ioo (0 : ℝ) t0, θ' t = -(θ t) ^ 2 / m) := by
  have hIcc : Icc (0 : ℝ) t0 ⊆ Ico (0 : ℝ) L := fun x hx => ⟨hx.1, lt_of_le_of_lt hx.2 ht0L⟩
  have hneg : ∀ x ∈ Icc (0 : ℝ) t0, θ x < 0 := fun x hx =>
    lt_of_le_of_lt (expansion_le_init hm hd hineq h0 x (hIcc hx)) h0
  have hne : ∀ x ∈ Icc (0 : ℝ) t0, θ x ≠ 0 := fun x hx => ne_of_lt (hneg x hx)
  -- The reciprocal expansion grows with slope at least `1/m`.
  set f : ℝ → ℝ := fun x => (θ x)⁻¹ with hf
  set f' : ℝ → ℝ := fun x => -θ' x / (θ x) ^ 2 with hf'
  have hdf : ∀ x ∈ Icc (0 : ℝ) t0, HasDerivAt f (f' x) x := fun x hx =>
    (hd x (hIcc hx)).inv (hne x hx)
  have hslope : ∀ x ∈ Ioo (0 : ℝ) t0, 1 / m ≤ f' x := by
    intro x hx
    have hxI : x ∈ Icc (0 : ℝ) t0 := Ioo_subset_Icc_self hx
    have h1 : θ' x ≤ -(θ x) ^ 2 / m := hineq x (hIcc hxI)
    have h2 : (0 : ℝ) < (θ x) ^ 2 := by have := hne x hxI; positivity
    simp only [hf']
    rw [div_le_div_iff₀ hm h2]
    have h : θ' x * m ≤ -(θ x) ^ 2 := (le_div_iff₀ hm).1 h1
    nlinarith
  -- The saturation hypothesis says the growth is exactly linear.
  have hdenpos : 0 < m + θ 0 * t0 := by
    have hlt : t0 < m / (-θ 0) :=
      focusing_time_bound hm hd hineq h0 t0 ⟨ht0.le, ht0L⟩
    rw [lt_div_iff₀ (neg_pos.2 h0)] at hlt
    nlinarith
  have hθ0ne : θ 0 ≠ 0 := ne_of_lt h0
  have hsatf : f t0 = f 0 + (1 / m) * (t0 - 0) := by
    simp only [hf, hsat, riccatiSol]
    rw [show m * θ 0 / (m + θ 0 * t0) = ((m + θ 0 * t0) / (m * θ 0))⁻¹ by rw [inv_div]]
    rw [inv_inv]
    field_simp
    ring
  obtain ⟨hval, hder⟩ := eq_affine_of_saturated_growth hdf hslope hsatf
  constructor
  · intro t ht
    have h1 : (θ t)⁻¹ = (θ 0)⁻¹ + (1 / m) * (t - 0) := hval t ht
    have hdent : 0 < m + θ 0 * t := by
      have h2 : t ≤ t0 := ht.2
      nlinarith [ht.1, h0.le, hdenpos]
    have h3 : θ t = ((θ t)⁻¹)⁻¹ := (inv_inv (θ t)).symm
    rw [h3, h1, riccatiSol]
    rw [show ((θ 0)⁻¹ + 1 / m * (t - 0)) = (m + θ 0 * t) / (m * θ 0) by field_simp; ring]
    rw [inv_div]
  · intro t ht
    have h := hder t ht
    have hxI : t ∈ Icc (0 : ℝ) t0 := Ioo_subset_Icc_self ht
    have h2 : (0 : ℝ) < (θ t) ^ 2 := by have := hne t hxI; positivity
    simp only [hf'] at h
    rw [div_eq_div_iff h2.ne' hm.ne'] at h
    rw [eq_div_iff hm.ne']
    linarith [h]

end PenroseRigidity

namespace GeodesicCongruence

variable {m L : ℝ} (C : GeodesicCongruence m L)

/-- **Rigidity of the Penrose focusing bound for a congruence.**  If the expansion of a
congruence satisfying the energy condition agrees with the model Riccati solution at one
interior affine parameter `t₀`, then on `[0, t₀]` it *is* the model solution, and on
`(0, t₀)` the congruence is shear-free (`σ² = 0`) and Ricci-flat along the generators
(`Ric(k,k) = 0`).  Equality in the singularity bound therefore forces equality in both
hypotheses used to derive it. -/
theorem rigidity_of_saturated_penrose (hm : 0 < m) (htrap : C.expansion 0 < 0)
    {t0 : ℝ} (ht0 : 0 < t0) (ht0L : t0 < L)
    (hsat : C.expansion t0 = riccatiSol m (C.expansion 0) t0) :
    (∀ t ∈ Icc (0 : ℝ) t0, C.expansion t = riccatiSol m (C.expansion 0) t) ∧
      (∀ t ∈ Ioo (0 : ℝ) t0, C.shearSq t = 0 ∧ C.ricci t = 0) := by
  obtain ⟨hval, hder⟩ :=
    riccati_rigidity hm ht0 ht0L C.hasDeriv C.expansionDot_le htrap hsat
  refine ⟨hval, ?_⟩
  intro t ht
  have hmem : t ∈ Ico (0 : ℝ) L := ⟨ht.1.le, lt_trans ht.2 ht0L⟩
  have hray := C.raychaudhuri t hmem
  have h := hder t ht
  have hs := C.shearSq_nonneg t hmem
  have hr := C.energy_condition t hmem
  rw [h] at hray
  constructor <;> linarith

end GeodesicCongruence

/-! ### Rigidity of the Bonnet–Myers / Hawking bound -/

section MyersRigidity

variable {m eps L : ℝ} {θ θ' : ℝ → ℝ}

/-- **Prüfer rigidity.**  Suppose `θ' ≤ -θ²/m - ε` with `ε > 0`, so that the phase angle
`arctan(θ/√(mε))` decreases at rate at least `√(ε/m)` (`arctan_expansion_decay`).  If the
phase estimate is saturated at one interior parameter `t₀`, then the expansion is exactly
the tangent profile of the constant-curvature model on `[0, t₀]`, and the Raychaudhuri
inequality is an equality with `Ric(k,k) ≡ ε` there. -/
theorem prufer_rigidity (hm : 0 < m) (he : 0 < eps) {t0 : ℝ} (ht0L : t0 < L)
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hineq : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / m - eps)
    (hsat : Real.arctan (θ t0 / Real.sqrt (m * eps))
      = Real.arctan (θ 0 / Real.sqrt (m * eps))
        - (Real.sqrt (m * eps) / m) * t0) :
    (∀ t ∈ Icc (0 : ℝ) t0, θ t = Real.sqrt (m * eps) *
        Real.tan (Real.arctan (θ 0 / Real.sqrt (m * eps))
          - (Real.sqrt (m * eps) / m) * t)) ∧
      (∀ t ∈ Ioo (0 : ℝ) t0, θ' t = -(θ t) ^ 2 / m - eps) := by
  set a : ℝ := Real.sqrt (m * eps) with ha
  have hapos : 0 < a := Real.sqrt_pos.2 (by positivity)
  have hasq : a ^ 2 = m * eps := Real.sq_sqrt (by positivity)
  have hIcc : Icc (0 : ℝ) t0 ⊆ Ico (0 : ℝ) L := fun x hx => ⟨hx.1, lt_of_le_of_lt hx.2 ht0L⟩
  -- the *negated* phase angle grows at rate at least `a / m`
  set f : ℝ → ℝ := fun x => -Real.arctan (θ x / a) with hf
  set f' : ℝ → ℝ := fun x => -(a * θ' x / (a ^ 2 + (θ x) ^ 2)) with hf'
  have hdf : ∀ x ∈ Icc (0 : ℝ) t0, HasDerivAt f (f' x) x := by
    intro x hx
    have h1 : HasDerivAt (fun s => θ s / a) (θ' x / a) x := (hd x (hIcc hx)).div_const a
    have h2 := (Real.hasDerivAt_arctan (θ x / a)).comp x h1
    have h3 : HasDerivAt (fun s => Real.arctan (θ s / a))
        (a * θ' x / (a ^ 2 + (θ x) ^ 2)) x := by
      convert h2 using 1
      field_simp
    simpa [hf, hf'] using h3.neg
  have hslope : ∀ x ∈ Ioo (0 : ℝ) t0, a / m ≤ f' x := by
    intro x hx
    have hxI : x ∈ Icc (0 : ℝ) t0 := Ioo_subset_Icc_self hx
    have h1 : θ' x ≤ -(θ x) ^ 2 / m - eps := hineq x (hIcc hxI)
    have hden : 0 < a ^ 2 + (θ x) ^ 2 := by positivity
    have hXm : (-(θ x) ^ 2 / m) * m = -(θ x) ^ 2 := div_mul_cancel₀ _ hm.ne'
    have h2 : θ' x * m ≤ -((θ x) ^ 2 + a ^ 2) := by
      have h3 := mul_le_mul_of_nonneg_right h1 hm.le
      nlinarith [h3, hXm, hasq]
    simp only [hf']
    rw [le_neg, div_le_iff₀ hden]
    have hfac : a * θ' x = (a / m) * (θ' x * m) := by field_simp
    rw [hfac]
    have hpos : 0 < a / m := div_pos hapos hm
    calc (a / m) * (θ' x * m) ≤ (a / m) * (-((θ x) ^ 2 + a ^ 2)) :=
          mul_le_mul_of_nonneg_left h2 hpos.le
      _ = -(a / m) * (a ^ 2 + (θ x) ^ 2) := by ring
  have hsatf : f t0 = f 0 + (a / m) * (t0 - 0) := by
    simp only [hf]
    rw [hsat]
    ring
  obtain ⟨hval, hder⟩ := eq_affine_of_saturated_growth hdf hslope hsatf
  constructor
  · intro t ht
    have h1 : -Real.arctan (θ t / a) = -Real.arctan (θ 0 / a) + (a / m) * (t - 0) :=
      hval t ht
    have h2 : Real.arctan (θ t / a) = Real.arctan (θ 0 / a) - (a / m) * t := by linarith
    have h3 : Real.tan (Real.arctan (θ t / a)) = θ t / a := Real.tan_arctan _
    rw [h2] at h3
    rw [h3]
    field_simp
  · intro t ht
    have h := hder t ht
    have hden : (0 : ℝ) < a ^ 2 + (θ t) ^ 2 := by positivity
    simp only [hf'] at h
    have h4 : a * θ' t / (a ^ 2 + (θ t) ^ 2) = -(a / m) := by linarith
    rw [div_eq_iff hden.ne'] at h4
    have h6 : a * θ' t = a * (-(a ^ 2 + (θ t) ^ 2) / m) := by rw [h4]; ring
    have h5 : θ' t = -(a ^ 2 + (θ t) ^ 2) / m := mul_left_cancel₀ hapos.ne' h6
    rw [h5, hasq]
    field_simp
    ring

end MyersRigidity

namespace GeodesicCongruence

variable {m L : ℝ} (C : GeodesicCongruence m L)

/-- **Rigidity of the Bonnet–Myers / Hawking bound for a congruence.**  If a congruence
whose Ricci focusing term is bounded below by `ε > 0` saturates the Prüfer phase estimate
at one interior parameter, then on `[0, t₀]` its expansion is the exact tangent profile of
the constant-curvature model and, on `(0, t₀)`, it is shear-free with `Ric(k,k) ≡ ε`:
the extremal congruence is the model one, with no room for excess curvature or shear. -/
theorem rigidity_of_saturated_myers (hm : 0 < m) {eps : ℝ} (he : 0 < eps)
    (hstrict : ∀ t ∈ Ico (0 : ℝ) L, eps ≤ C.ricci t)
    {t0 : ℝ} (ht0L : t0 < L)
    (hsat : Real.arctan (C.expansion t0 / Real.sqrt (m * eps))
      = Real.arctan (C.expansion 0 / Real.sqrt (m * eps))
        - (Real.sqrt (m * eps) / m) * t0) :
    (∀ t ∈ Icc (0 : ℝ) t0, C.expansion t = Real.sqrt (m * eps) *
        Real.tan (Real.arctan (C.expansion 0 / Real.sqrt (m * eps))
          - (Real.sqrt (m * eps) / m) * t)) ∧
      (∀ t ∈ Ioo (0 : ℝ) t0, C.shearSq t = 0 ∧ C.ricci t = eps) := by
  have hineq : ∀ t ∈ Ico (0 : ℝ) L,
      C.expansionDot t ≤ -(C.expansion t) ^ 2 / m - eps := by
    intro t ht
    have h := C.raychaudhuri t ht
    have h1 := C.shearSq_nonneg t ht
    have h2 := hstrict t ht
    rw [h]
    linarith
  obtain ⟨hval, hder⟩ := prufer_rigidity hm he ht0L C.hasDeriv hineq hsat
  refine ⟨hval, ?_⟩
  intro t ht
  have hmem : t ∈ Ico (0 : ℝ) L := ⟨ht.1.le, lt_trans ht.2 ht0L⟩
  have hray := C.raychaudhuri t hmem
  have h := hder t ht
  have hs := C.shearSq_nonneg t hmem
  have hr := hstrict t hmem
  rw [h] at hray
  constructor <;> linarith

/-- **Strict focusing in the presence of a defect.**  Contrapositive of Penrose rigidity:
if the shear or the Ricci focusing term is positive anywhere strictly inside `(0, t₀)`,
then the comparison of `expansion_le_riccati` is *strict* at `t₀` — any genuine shear or
energy density makes the congruence focus strictly faster than the model. -/
theorem lt_riccati_of_defect (hm : 0 < m) (htrap : C.expansion 0 < 0)
    {t0 : ℝ} (ht0 : 0 < t0) (ht0L : t0 < L)
    {s : ℝ} (hs : s ∈ Ioo (0 : ℝ) t0) (hdef : 0 < C.shearSq s + C.ricci s) :
    C.expansion t0 < riccatiSol m (C.expansion 0) t0 := by
  have hle := C.expansion_le_riccati hm htrap t0 ⟨ht0.le, ht0L⟩
  rcases lt_or_eq_of_le hle with h | h
  · exact h
  · obtain ⟨-, hzero⟩ := C.rigidity_of_saturated_penrose hm htrap ht0 ht0L h
    obtain ⟨h1, h2⟩ := hzero s hs
    rw [h1, h2] at hdef
    linarith

end GeodesicCongruence

/-! ### Non-vacuity of the rigidity hypotheses -/

section RigidityWitness

/-- The saturation hypothesis of `rigidity_of_saturated_penrose` is satisfiable: the exact
shear-free, Ricci-flat congruence of `exactCongruence` realises equality with the model
Riccati solution at *every* affine parameter.  Rigidity is therefore a statement about a
non-empty class of congruences. -/
theorem exactCongruence_saturates (m t0 t : ℝ) (hm : 0 < m) (h0 : t0 < 0) :
    (exactCongruence m t0 hm h0).expansion t
      = riccatiSol m ((exactCongruence m t0 hm h0).expansion 0) t := by
  rw [exactCongruence_expansion_zero]
  rfl

/-- Applying rigidity to that witness returns exactly the defining data of the model:
the expansion is the Riccati solution and both the shear and the Ricci term vanish. -/
theorem exactCongruence_rigidity (m t0 : ℝ) (hm : 0 < m) (h0 : t0 < 0)
    {u : ℝ} (hu : 0 < u) (huL : u < m / (-t0)) :
    (∀ t ∈ Icc (0 : ℝ) u,
        (exactCongruence m t0 hm h0).expansion t = riccatiSol m t0 t) ∧
      (∀ t ∈ Ioo (0 : ℝ) u, (exactCongruence m t0 hm h0).shearSq t = 0 ∧
        (exactCongruence m t0 hm h0).ricci t = 0) := by
  obtain ⟨hval, hzero⟩ := (exactCongruence m t0 hm h0).rigidity_of_saturated_penrose hm
    (by simpa using h0) hu huL (exactCongruence_saturates m t0 u hm h0)
  refine ⟨fun t ht => ?_, hzero⟩
  have h := hval t ht
  rwa [exactCongruence_expansion_zero] at h

end RigidityWitness

end Catalog.Physics.Spacetime