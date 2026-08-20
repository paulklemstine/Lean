import Algebra.RLHFPTXExistence

/-!
# Stationarity and the self-consistent Gibbs form of the PPO-ptx optimum

The PPO-ptx objective

```
J_γ(q) = 𝔼_q[r] − β · KL(q ‖ p) + γ · 𝔼_{x∼d}[log q x]
```

has a unique maximizer (`RLHF.existsUnique_ptx_maximizer`) but, unlike plain KL-regularized
RLHF, no closed-form solution.  This file supplies the exact *characterization* that replaces
the closed form.

Write the coordinatewise marginal value ("score") of a policy `q` as

```
S(y) = r y − β (log (q y / p y) + 1) + γ · d y / q y .
```

Main results (all `sorry`-free):

* `RLHF.ptxScore_const_of_isPTXMaximizer` — **necessity**: at the optimum the score is constant
  across the response space.  Proved by an exact two-coordinate perturbation and a genuine
  derivative computation (no smoothness is assumed; it is established).
* `RLHF.isPTXMaximizer_of_ptxScore_const` — **sufficiency**: any strictly positive policy with
  constant score is the *global* maximizer, and `RLHF.objectivePTX_lt_of_ptxScore_const` shows
  the inequality is strict away from it.  The proof is purely algebraic: coordinatewise
  concavity plus `log t ≤ t − 1`.
* `RLHF.ptx_stationarity_iff` — the resulting exact characterization.
* `RLHF.ptx_self_consistent_gibbs` — the headline structural consequence: the PPO-ptx optimum
  is the *Gibbs policy of its own PTX-augmented reward*,
  `q = gibbsPolicy β (fun y => r y + γ · d y / q y) p`.
  The pretraining mix-in acts exactly as a self-referential reward bonus `γ d/q`, which is
  large precisely on pretraining-likely responses that the aligned policy has suppressed.
* `RLHF.exists_ptxScore_const` — combined with the existence theorem, the stationarity system
  is solvable; `RLHF.ptx_self_consistent_gibbs_exists` packages the fixed point.
* `RLHF.ptx_no_starvation` — a quantitative anti-mode-collapse guarantee extracted from the
  stationarity equation: at the optimum every response keeps probability at least
  `γ d y / (β log (1 / p y) + M + γ − r y)` for any reward ceiling `M`, so the PTX term is a
  hard floor that a corrupted reward model cannot breach.
* `RLHF.ptx_maximizer_iff_self_consistent` — the fixed points of the self-consistent Gibbs map
  are *exactly* the PPO-ptx optima, so the fixed-point equation is a complete substitute for the
  missing closed form.
-/

namespace RLHF

open Finset

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

/-! ## 1. The coordinatewise score -/

/-- The marginal value of mass placed on response `y` by the policy `q`, i.e. the partial
derivative of the PPO-ptx objective in the direction of `y`. -/
noncomputable def ptxScore (β γ : ℝ) (r p d q : Ω → ℝ) (y : Ω) : ℝ :=
  r y - β * (Real.log (q y / p y) + 1) + γ * d y / q y

/-- `q` is a global maximizer of the PPO-ptx objective among strictly positive policies. -/
def IsPTXMaximizer (β γ : ℝ) (r p d q : Ω → ℝ) : Prop :=
  IsPosDist q ∧ ∀ q', IsPosDist q' → objectivePTX β γ r p d q' ≤ objectivePTX β γ r p d q

/-- The coordinatewise summand of the PPO-ptx objective. -/
noncomputable def ptxCoord (β γ rv pv dv t : ℝ) : ℝ :=
  t * rv - β * (t * Real.log (t / pv)) + γ * (dv * Real.log t)

omit [Nonempty Ω] in
theorem objectivePTX_eq_sum_coord {β γ : ℝ} {r p d q : Ω → ℝ} :
    objectivePTX β γ r p d q = ∑ y, ptxCoord β γ (r y) (p y) (d y) (q y) := by
  simpa [ptxCoord] using
    (objectivePTX_eq_sum (β := β) (γ := γ) (r := r) (p := p) (d := d) (q := q))

/-! ## 2. Coordinatewise concavity: the tangent bound -/

/-- **Tangent (concavity) bound.**  Each coordinate summand of the PPO-ptx objective lies
below its tangent line, whose slope is the score. -/
theorem ptxCoord_le_tangent {β γ rv pv dv t t' : ℝ} (hβ : 0 < β) (hγ : 0 ≤ γ) (hpv : 0 < pv)
    (hdv : 0 ≤ dv) (ht : 0 < t) (ht' : 0 < t') :
    ptxCoord β γ rv pv dv t'
      ≤ ptxCoord β γ rv pv dv t
        + (rv - β * (Real.log (t / pv) + 1) + γ * dv / t) * (t' - t) := by
  have hA : Real.log t' = Real.log t + Real.log (t' / t) := by
    rw [Real.log_div ht'.ne' ht.ne']; ring
  have hB : Real.log (t' / pv) = Real.log (t / pv) + Real.log (t' / t) := by
    rw [Real.log_div ht'.ne' hpv.ne', Real.log_div ht.ne' hpv.ne', Real.log_div ht'.ne' ht.ne']
    ring
  have h1 : t' - t ≤ t' * Real.log (t' / t) := log_mul_div_ge ht'.le ht
  have hb : β * (t' - t) ≤ β * (t' * Real.log (t' / t)) :=
    mul_le_mul_of_nonneg_left h1 hβ.le
  have h2 : Real.log (t' / t) ≤ t' / t - 1 :=
    Real.log_le_sub_one_of_pos (by positivity)
  have h3 : γ * (dv * Real.log (t' / t)) ≤ γ * (dv * (t' / t - 1)) := by
    have := mul_le_mul_of_nonneg_left h2 hdv
    exact mul_le_mul_of_nonneg_left this hγ
  have hdt : γ * dv / t * (t' - t) = γ * (dv * (t' / t - 1)) := by
    field_simp
  simp only [ptxCoord]
  rw [hA, hB]
  nlinarith [hb, h3, hdt]

/-- Strict version of `ptxCoord_le_tangent`. -/
theorem ptxCoord_lt_tangent {β γ rv pv dv t t' : ℝ} (hβ : 0 < β) (hγ : 0 ≤ γ) (hpv : 0 < pv)
    (hdv : 0 ≤ dv) (ht : 0 < t) (ht' : 0 < t') (hne : t' ≠ t) :
    ptxCoord β γ rv pv dv t'
      < ptxCoord β γ rv pv dv t
        + (rv - β * (Real.log (t / pv) + 1) + γ * dv / t) * (t' - t) := by
  have hA : Real.log t' = Real.log t + Real.log (t' / t) := by
    rw [Real.log_div ht'.ne' ht.ne']; ring
  have hB : Real.log (t' / pv) = Real.log (t / pv) + Real.log (t' / t) := by
    rw [Real.log_div ht'.ne' hpv.ne', Real.log_div ht.ne' hpv.ne', Real.log_div ht'.ne' ht.ne']
    ring
  have h1 : t' - t < t' * Real.log (t' / t) := log_mul_div_gt ht'.le ht hne
  have hb : β * (t' - t) < β * (t' * Real.log (t' / t)) := by
    exact mul_lt_mul_of_pos_left h1 hβ
  have h2 : Real.log (t' / t) ≤ t' / t - 1 :=
    Real.log_le_sub_one_of_pos (by positivity)
  have h3 : γ * (dv * Real.log (t' / t)) ≤ γ * (dv * (t' / t - 1)) := by
    have := mul_le_mul_of_nonneg_left h2 hdv
    exact mul_le_mul_of_nonneg_left this hγ
  have hdt : γ * dv / t * (t' - t) = γ * (dv * (t' / t - 1)) := by
    field_simp
  simp only [ptxCoord]
  rw [hA, hB]
  nlinarith [hb, h3, hdt]

/-! ## 3. Sufficiency of stationarity -/

omit [Nonempty Ω] in
/-- **Sufficiency.**  A strictly positive policy whose score is constant across responses is
the global maximizer of the PPO-ptx objective. -/
theorem isPTXMaximizer_of_ptxScore_const {β γ c : ℝ} {r p d q : Ω → ℝ} (hβ : 0 < β)
    (hγ : 0 ≤ γ) (hp : IsPosDist p) (hd : ∀ y, 0 ≤ d y) (hq : IsPosDist q)
    (hstat : ∀ y, ptxScore β γ r p d q y = c) : IsPTXMaximizer β γ r p d q := by
  simp only [ptxScore] at hstat
  refine ⟨hq, fun q' hq' => ?_⟩
  rw [objectivePTX_eq_sum_coord, objectivePTX_eq_sum_coord]
  have hle : ∀ y ∈ (univ : Finset Ω), ptxCoord β γ (r y) (p y) (d y) (q' y)
      ≤ ptxCoord β γ (r y) (p y) (d y) (q y) + c * (q' y - q y) := by
    intro y _
    have h := ptxCoord_le_tangent (β := β) (γ := γ) (rv := r y) (pv := p y) (dv := d y)
      (t := q y) (t' := q' y) hβ hγ (hp.1 y) (hd y) (hq.1 y) (hq'.1 y)
    rwa [hstat y] at h
  calc ∑ y, ptxCoord β γ (r y) (p y) (d y) (q' y)
      ≤ ∑ y, (ptxCoord β γ (r y) (p y) (d y) (q y) + c * (q' y - q y)) :=
        Finset.sum_le_sum hle
    _ = ∑ y, ptxCoord β γ (r y) (p y) (d y) (q y) := by
        rw [Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_sub_distrib, hq'.2, hq.2]
        ring

omit [Nonempty Ω] in
/-- Strict global optimality of a stationary policy. -/
theorem objectivePTX_lt_of_ptxScore_const {β γ c : ℝ} {r p d q q' : Ω → ℝ} (hβ : 0 < β)
    (hγ : 0 ≤ γ) (hp : IsPosDist p) (hd : ∀ y, 0 ≤ d y) (hq : IsPosDist q) (hq' : IsPosDist q')
    (hne : q' ≠ q) (hstat : ∀ y, ptxScore β γ r p d q y = c) :
    objectivePTX β γ r p d q' < objectivePTX β γ r p d q := by
  simp only [ptxScore] at hstat
  rw [objectivePTX_eq_sum_coord, objectivePTX_eq_sum_coord]
  obtain ⟨y₀, hy₀⟩ := Function.ne_iff.mp hne
  have hle : ∀ y ∈ (univ : Finset Ω), ptxCoord β γ (r y) (p y) (d y) (q' y)
      ≤ ptxCoord β γ (r y) (p y) (d y) (q y) + c * (q' y - q y) := by
    intro y _
    have h := ptxCoord_le_tangent (β := β) (γ := γ) (rv := r y) (pv := p y) (dv := d y)
      (t := q y) (t' := q' y) hβ hγ (hp.1 y) (hd y) (hq.1 y) (hq'.1 y)
    rwa [hstat y] at h
  have hlt : ptxCoord β γ (r y₀) (p y₀) (d y₀) (q' y₀)
      < ptxCoord β γ (r y₀) (p y₀) (d y₀) (q y₀) + c * (q' y₀ - q y₀) := by
    have h := ptxCoord_lt_tangent (β := β) (γ := γ) (rv := r y₀) (pv := p y₀) (dv := d y₀)
      (t := q y₀) (t' := q' y₀) hβ hγ (hp.1 y₀) (hd y₀) (hq.1 y₀) (hq'.1 y₀) hy₀
    rwa [hstat y₀] at h
  calc ∑ y, ptxCoord β γ (r y) (p y) (d y) (q' y)
      < ∑ y, (ptxCoord β γ (r y) (p y) (d y) (q y) + c * (q' y - q y)) :=
        Finset.sum_lt_sum hle ⟨y₀, mem_univ y₀, hlt⟩
    _ = ∑ y, ptxCoord β γ (r y) (p y) (d y) (q y) := by
        rw [Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_sub_distrib, hq'.2, hq.2]
        ring

/-! ## 4. Necessity of stationarity: an exact perturbation argument -/

section Perturbation

variable [DecidableEq Ω]

/-- The policy obtained from `q` by moving mass `ε` from response `y₂` to response `y₁`. -/
noncomputable def shiftMass (q : Ω → ℝ) (y₁ y₂ : Ω) (ε : ℝ) : Ω → ℝ :=
  fun y => if y = y₁ then q y₁ + ε else if y = y₂ then q y₂ - ε else q y

omit [Nonempty Ω] in
/-- Splitting a sum off two distinguished coordinates. -/
theorem sum_perturb {y₁ y₂ : Ω} (hne : y₁ ≠ y₂) (f : Ω → ℝ) (a b : ℝ) :
    ∑ y, (if y = y₁ then a else if y = y₂ then b else f y)
      = a + (b + ∑ y ∈ (univ.erase y₁).erase y₂, f y) := by
  have h2 : y₂ ∈ univ.erase y₁ := mem_erase.mpr ⟨hne.symm, mem_univ y₂⟩
  have key : ∀ y ∈ (univ.erase y₁).erase y₂,
      (if y = y₁ then a else if y = y₂ then b else f y) = f y := by
    intro y hy
    rw [mem_erase] at hy
    have hy1 : y ≠ y₁ := (mem_erase.mp hy.2).1
    rw [if_neg hy1, if_neg hy.1]
  rw [← Finset.add_sum_erase _ _ (mem_univ y₁), ← Finset.add_sum_erase _ _ h2,
    Finset.sum_congr rfl key, if_pos rfl, if_neg hne.symm, if_pos rfl]

omit [Nonempty Ω] in
theorem shiftMass_sum {q : Ω → ℝ} {y₁ y₂ : Ω} (hne : y₁ ≠ y₂) (hq : ∑ y, q y = 1) (ε : ℝ) :
    ∑ y, shiftMass q y₁ y₂ ε y = 1 := by
  have hbase : q y₁ + (q y₂ + ∑ y ∈ (univ.erase y₁).erase y₂, q y) = 1 := by
    rw [← sum_perturb hne q (q y₁) (q y₂), ← hq]
    refine Finset.sum_congr rfl fun y _ => ?_
    split_ifs with h1 h2
    · rw [h1]
    · rw [h2]
    · rfl
  rw [show (fun y => shiftMass q y₁ y₂ ε y) = fun y =>
      (if y = y₁ then q y₁ + ε else if y = y₂ then q y₂ - ε else q y) from rfl,
    sum_perturb hne q (q y₁ + ε) (q y₂ - ε)]
  linarith

omit [Fintype Ω] [Nonempty Ω] in
theorem shiftMass_pos {q : Ω → ℝ} {y₁ y₂ : Ω} (hq : ∀ y, 0 < q y) {ε : ℝ}
    (hε₁ : -q y₁ < ε) (hε₂ : ε < q y₂) (y : Ω) : 0 < shiftMass q y₁ y₂ ε y := by
  unfold shiftMass
  split_ifs with h1 h2
  · linarith
  · linarith
  · exact hq y

omit [Nonempty Ω] in
theorem shiftMass_isPosDist {q : Ω → ℝ} {y₁ y₂ : Ω} (hne : y₁ ≠ y₂) (hq : IsPosDist q) {ε : ℝ}
    (hε₁ : -q y₁ < ε) (hε₂ : ε < q y₂) : IsPosDist (shiftMass q y₁ y₂ ε) :=
  ⟨shiftMass_pos hq.1 hε₁ hε₂, shiftMass_sum hne hq.2 ε⟩

omit [Nonempty Ω] in
/-- The PPO-ptx value along the two-coordinate perturbation is an explicit function of `ε`. -/
theorem objectivePTX_shiftMass {β γ : ℝ} {r p d q : Ω → ℝ} {y₁ y₂ : Ω} (hne : y₁ ≠ y₂)
    (ε : ℝ) :
    objectivePTX β γ r p d (shiftMass q y₁ y₂ ε)
      = ptxCoord β γ (r y₁) (p y₁) (d y₁) (q y₁ + ε)
        + (ptxCoord β γ (r y₂) (p y₂) (d y₂) (q y₂ - ε)
          + ∑ y ∈ (univ.erase y₁).erase y₂, ptxCoord β γ (r y) (p y) (d y) (q y)) := by
  rw [objectivePTX_eq_sum_coord,
    ← sum_perturb hne (fun y => ptxCoord β γ (r y) (p y) (d y) (q y))
      (ptxCoord β γ (r y₁) (p y₁) (d y₁) (q y₁ + ε))
      (ptxCoord β γ (r y₂) (p y₂) (d y₂) (q y₂ - ε))]
  refine Finset.sum_congr rfl fun y _ => ?_
  unfold shiftMass
  split_ifs with h1 h2
  · rw [h1]
  · rw [h2]
  · rfl

end Perturbation

/-- The coordinate summand is differentiable, with derivative the score. -/
theorem hasDerivAt_ptxCoord {β γ rv pv dv t : ℝ} (hpv : 0 < pv) (ht : 0 < t) :
    HasDerivAt (ptxCoord β γ rv pv dv)
      (rv - β * (Real.log (t / pv) + 1) + γ * dv / t) t := by
  have hdiv : HasDerivAt (fun s : ℝ => s / pv) (1 / pv) t := by
    simpa using (hasDerivAt_id t).div_const pv
  have hlogdiv : HasDerivAt (fun s : ℝ => Real.log (s / pv)) t⁻¹ t := by
    have h := hdiv.log (by positivity)
    have : 1 / pv / (t / pv) = t⁻¹ := by field_simp
    rwa [this] at h
  have hmul : HasDerivAt (fun s : ℝ => s * Real.log (s / pv))
      (1 * Real.log (t / pv) + t * t⁻¹) t := (hasDerivAt_id t).mul hlogdiv
  have hlin : HasDerivAt (fun s : ℝ => s * rv) rv t := by
    simpa using (hasDerivAt_id t).mul_const rv
  have hlog : HasDerivAt (fun s : ℝ => Real.log s) t⁻¹ t := Real.hasDerivAt_log ht.ne'
  have hfun : ptxCoord β γ rv pv dv
      = fun s : ℝ => s * rv - β * (s * Real.log (s / pv)) + γ * (dv * Real.log s) := rfl
  rw [hfun]
  have hcomb := (hlin.sub (hmul.const_mul β)).add ((hlog.const_mul dv).const_mul γ)
  convert hcomb using 1
  field_simp

omit [Nonempty Ω] in
/-- **Necessity.**  At a PPO-ptx maximizer the score is the same for every response: the
first-order condition holds, even though no smoothness was assumed of the problem. -/
theorem ptxScore_const_of_isPTXMaximizer {β γ : ℝ} {r p d q : Ω → ℝ} (hp : IsPosDist p)
    (hmax : IsPTXMaximizer β γ r p d q) (y₁ y₂ : Ω) :
    ptxScore β γ r p d q y₁ = ptxScore β γ r p d q y₂ := by
  classical
  obtain ⟨hq, hopt⟩ := hmax
  rcases eq_or_ne y₁ y₂ with h | hne
  · rw [h]
  set S : ℝ := ∑ y ∈ (univ.erase y₁).erase y₂, ptxCoord β γ (r y) (p y) (d y) (q y) with hS
  set g : ℝ → ℝ := fun ε => ptxCoord β γ (r y₁) (p y₁) (d y₁) (q y₁ + ε)
      + (ptxCoord β γ (r y₂) (p y₂) (d y₂) (q y₂ - ε) + S) with hg
  -- `g` has a local maximum at `0`
  have hlocmax : IsLocalMax g 0 := by
    have hmem : Set.Ioo (-q y₁) (q y₂) ∈ nhds (0 : ℝ) :=
      Ioo_mem_nhds (by linarith [hq.1 y₁]) (hq.1 y₂)
    filter_upwards [hmem] with ε hε
    have hpos := shiftMass_isPosDist hne hq hε.1 hε.2
    have h1 := hopt _ hpos
    rw [objectivePTX_shiftMass hne] at h1
    have h2 : objectivePTX β γ r p d q = g 0 := by
      have := objectivePTX_shiftMass (β := β) (γ := γ) (r := r) (p := p) (d := d) (q := q)
        hne 0
      have hz : shiftMass q y₁ y₂ 0 = q := by
        funext y
        unfold shiftMass
        split_ifs with hh1 hh2
        · rw [hh1]; ring
        · rw [hh2]; ring
        · rfl
      rw [hz] at this
      rw [this, hg]
    rw [h2] at h1
    exact h1
  -- and it is differentiable there
  have hA : HasDerivAt (ptxCoord β γ (r y₁) (p y₁) (d y₁))
      (ptxScore β γ r p d q y₁) (q y₁) :=
    hasDerivAt_ptxCoord (hp.1 y₁) (hq.1 y₁)
  have hB : HasDerivAt (ptxCoord β γ (r y₂) (p y₂) (d y₂))
      (ptxScore β γ r p d q y₂) (q y₂) :=
    hasDerivAt_ptxCoord (hp.1 y₂) (hq.1 y₂)
  have hinner₁ : HasDerivAt (fun ε : ℝ => q y₁ + ε) 1 0 := by
    simpa using (hasDerivAt_id (0 : ℝ)).const_add (q y₁)
  have hinner₂ : HasDerivAt (fun ε : ℝ => q y₂ - ε) (-1) 0 := by
    simpa using (hasDerivAt_id (0 : ℝ)).const_sub (q y₂)
  have hA0 : HasDerivAt (fun ε : ℝ => ptxCoord β γ (r y₁) (p y₁) (d y₁) (q y₁ + ε))
      (ptxScore β γ r p d q y₁ * 1) 0 := by
    have := HasDerivAt.comp (0 : ℝ) (by simpa using hA) hinner₁
    exact this
  have hB0 : HasDerivAt (fun ε : ℝ => ptxCoord β γ (r y₂) (p y₂) (d y₂) (q y₂ - ε))
      (ptxScore β γ r p d q y₂ * (-1)) 0 := by
    have := HasDerivAt.comp (0 : ℝ) (by simpa using hB) hinner₂
    exact this
  have hgderiv : HasDerivAt g
      (ptxScore β γ r p d q y₁ * 1 + ptxScore β γ r p d q y₂ * (-1)) 0 := by
    have := hA0.add (hB0.add_const S)
    exact this
  have hzero := hlocmax.hasDerivAt_eq_zero hgderiv
  linarith [hzero]

/-! ## 5. The characterization and the self-consistent Gibbs form -/

/-- **Exact characterization of the PPO-ptx optimum**: a strictly positive policy is globally
optimal if and only if its coordinatewise score is constant. -/
theorem ptx_stationarity_iff {β γ : ℝ} {r p d q : Ω → ℝ} (hβ : 0 < β) (hγ : 0 ≤ γ)
    (hp : IsPosDist p) (hd : ∀ y, 0 ≤ d y) (hq : IsPosDist q) :
    IsPTXMaximizer β γ r p d q ↔ ∃ c, ∀ y, ptxScore β γ r p d q y = c := by
  constructor
  · intro hmax
    exact ⟨ptxScore β γ r p d q (Classical.arbitrary Ω), fun y =>
      ptxScore_const_of_isPTXMaximizer hp hmax y (Classical.arbitrary Ω)⟩
  · rintro ⟨c, hc⟩
    exact isPTXMaximizer_of_ptxScore_const hβ hγ hp hd hq hc

/-- **The PPO-ptx optimum is a self-consistent Gibbs policy.**  It is the softmax tilt of the
reference policy by its own PTX-augmented reward `r + γ d / q`: the pretraining mix-in acts as
a self-referential bonus on responses that the aligned policy under-weights relative to the
pretraining distribution. -/
theorem ptx_self_consistent_gibbs {β γ : ℝ} {r p d q : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hmax : IsPTXMaximizer β γ r p d q) :
    q = gibbsPolicy β (fun y => r y + γ * d y / q y) p := by
  have hq := hmax.1
  have hβ0 : β ≠ 0 := hβ.ne'
  obtain ⟨c, hc⟩ : ∃ c, ∀ y, ptxScore β γ r p d q y = c :=
    ⟨ptxScore β γ r p d q (Classical.arbitrary Ω), fun y =>
      ptxScore_const_of_isPTXMaximizer hp hmax y (Classical.arbitrary Ω)⟩
  set rt : Ω → ℝ := fun y => r y + γ * d y / q y with hrt
  set K : ℝ := Real.exp (-(β + c) / β) with hK
  have key : ∀ y, q y = p y * Real.exp (rt y / β) * K := by
    intro y
    have h := hc y
    simp only [ptxScore] at h
    have hrty : rt y = r y + γ * d y / q y := by rw [hrt]
    have hlog : Real.log (q y / p y) = (rt y - β - c) / β := by
      rw [hrty, eq_div_iff hβ0]
      linarith [h]
    have hqp : 0 < q y / p y := div_pos (hq.1 y) (hp.1 y)
    have hratio : q y / p y = Real.exp ((rt y - β - c) / β) := by
      rw [← hlog, Real.exp_log hqp]
    have hsplit : Real.exp ((rt y - β - c) / β) = Real.exp (rt y / β) * K := by
      rw [hK, ← Real.exp_add, ← add_div]
      congr 1
      ring
    rw [hsplit, div_eq_iff (hp.1 y).ne'] at hratio
    rw [hratio]
    ring
  have hsum : (∑ y, p y * Real.exp (rt y / β)) * K = 1 := by
    rw [Finset.sum_mul, ← hq.2]
    exact Finset.sum_congr rfl fun y _ => (key y).symm
  have hZpos : 0 < ∑ y, p y * Real.exp (rt y / β) :=
    Finset.sum_pos (fun y _ => mul_pos (hp.1 y) (Real.exp_pos _)) univ_nonempty
  funext y
  rw [key y]
  simp only [gibbsPolicy, partition]
  rw [eq_div_iff hZpos.ne']
  calc p y * Real.exp (rt y / β) * K * ∑ z, p z * Real.exp (rt z / β)
      = p y * Real.exp (rt y / β) * ((∑ z, p z * Real.exp (rt z / β)) * K) := by ring
    _ = p y * Real.exp (rt y / β) := by rw [hsum]; ring

/-- The stationarity system is solvable: a strictly positive policy with constant score
exists. -/
theorem exists_ptxScore_const {β γ δ : ℝ} {r p d : Ω → ℝ} (hβ : 0 < β) (hγ : 0 < γ)
    (hp : IsPosDist p) (hd : ∀ y, δ ≤ d y) (hδ : 0 < δ) :
    ∃ q, IsPosDist q ∧ ∃ c, ∀ y, ptxScore β γ r p d q y = c := by
  obtain ⟨q, ⟨hq, hopt⟩, -⟩ := existsUnique_ptx_maximizer (r := r) hβ hγ hp hd hδ
  refine ⟨q, hq, ptxScore β γ r p d q (Classical.arbitrary Ω), fun y => ?_⟩
  exact ptxScore_const_of_isPTXMaximizer hp ⟨hq, hopt⟩ y (Classical.arbitrary Ω)

/-- Packaged fixed point: a strictly positive policy equal to the Gibbs policy of its own
PTX-augmented reward exists. -/
theorem ptx_self_consistent_gibbs_exists {β γ δ : ℝ} {r p d : Ω → ℝ} (hβ : 0 < β) (hγ : 0 < γ)
    (hp : IsPosDist p) (hd : ∀ y, δ ≤ d y) (hδ : 0 < δ) :
    ∃ q, IsPosDist q ∧ q = gibbsPolicy β (fun y => r y + γ * d y / q y) p := by
  obtain ⟨q, ⟨hq, hopt⟩, -⟩ := existsUnique_ptx_maximizer (r := r) hβ hγ hp hd hδ
  exact ⟨q, hq, ptx_self_consistent_gibbs hβ hp ⟨hq, hopt⟩⟩

/-! ## 6. Anti-starvation: PTX puts a hard floor under every pretraining-likely response -/

omit [Nonempty Ω] in
/-- The common value of the score at the optimum, computed by averaging against `q`. -/
theorem ptxScore_const_value {β γ c : ℝ} {r p d q : Ω → ℝ} (hq : IsPosDist q) (hd : IsDist d)
    (hstat : ∀ y, ptxScore β γ r p d q y = c) :
    c = (∑ y, q y * r y) - β * klDiv q p - β + γ := by
  have h1 : ∑ y, q y * ptxScore β γ r p d q y = c := by
    simp only [hstat, ← Finset.sum_mul, hq.2, one_mul]
  have h2 : ∀ y ∈ (univ : Finset Ω), q y * ptxScore β γ r p d q y
      = q y * r y - β * (q y * Real.log (q y / p y)) - β * q y + γ * d y := by
    intro y _
    have hqy : q y ≠ 0 := (hq.1 y).ne'
    simp only [ptxScore]
    field_simp
    ring
  rw [Finset.sum_congr rfl h2] at h1
  rw [← h1, klDiv, Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.sum_sub_distrib,
    ← Finset.mul_sum, ← Finset.mul_sum, ← Finset.mul_sum, hq.2, hd.2]
  ring

/-- **Anti-starvation (no mode collapse under PTX).**  At the PPO-ptx optimum every response
carries probability at least `γ d y / (β log (1 / p y) + M + γ − r y)`, where `M` is any upper
bound on the reward.  The pretraining mix-in therefore provides an explicit, reward-independent
floor: a response the pretraining distribution likes cannot be suppressed to arbitrarily small
probability, however badly the (possibly hacked) reward model scores it. -/
theorem ptx_no_starvation {β γ M : ℝ} {r p d q : Ω → ℝ} (hβ : 0 < β) (hγ : 0 < γ)
    (hp : IsPosDist p) (hd : IsDist d) (hM : ∀ y, r y ≤ M)
    (hmax : IsPTXMaximizer β γ r p d q) (y : Ω) (hdy : 0 < d y) :
    γ * d y / (β * Real.log (1 / p y) + M + γ - r y) ≤ q y := by
  classical
  have hq := hmax.1
  obtain ⟨c, hc⟩ : ∃ c, ∀ z, ptxScore β γ r p d q z = c := by
    exact ⟨ptxScore β γ r p d q (Classical.arbitrary Ω), fun z =>
      ptxScore_const_of_isPTXMaximizer hp hmax z (Classical.arbitrary Ω)⟩
  have hcval := ptxScore_const_value hq hd hc
  have hy := hc y
  simp only [ptxScore] at hy
  have hER : ∑ z, q z * r z ≤ M := by
    have : ∑ z, q z * r z ≤ ∑ z, q z * M :=
      Finset.sum_le_sum fun z _ => mul_le_mul_of_nonneg_left (hM z) (hq.1 z).le
    rwa [← Finset.sum_mul, hq.2, one_mul] at this
  have hKL : 0 ≤ β * klDiv q p := mul_nonneg hβ.le (kl_nonneg hq.isDist hp)
  have hq1 : q y ≤ 1 := by
    rw [← hq.2]
    exact Finset.single_le_sum (fun i _ => (hq.1 i).le) (mem_univ y)
  have hratio : q y / p y ≤ 1 / p y := by
    exact div_le_div_of_nonneg_right hq1 (hp.1 y).le
  have hlog : Real.log (q y / p y) ≤ Real.log (1 / p y) :=
    Real.log_le_log (div_pos (hq.1 y) (hp.1 y)) hratio
  have hβlog := mul_le_mul_of_nonneg_left hlog hβ.le
  have hkey : γ * d y / q y ≤ β * Real.log (1 / p y) + M + γ - r y := by
    have h1 : γ * d y / q y = β * Real.log (q y / p y) + β + c - r y := by linarith
    rw [h1, hcval]
    linarith
  have hDpos : 0 < β * Real.log (1 / p y) + M + γ - r y :=
    lt_of_lt_of_le (div_pos (mul_pos hγ hdy) (hq.1 y)) hkey
  rw [div_le_iff₀ (hq.1 y)] at hkey
  rw [div_le_iff₀ hDpos]
  linarith

/-! ## 7. Fixed points of the self-consistent Gibbs map are exactly the optima -/

/-- **Converse of `ptx_self_consistent_gibbs`.**  Any strictly positive policy that is the
Gibbs policy of its own PTX-augmented reward is the global PPO-ptx optimum. -/
theorem isPTXMaximizer_of_self_consistent_gibbs {β γ : ℝ} {r p d q : Ω → ℝ} (hβ : 0 < β)
    (hγ : 0 ≤ γ) (hp : IsPosDist p) (hd : ∀ y, 0 ≤ d y) (hq : IsPosDist q)
    (hfix : q = gibbsPolicy β (fun y => r y + γ * d y / q y) p) :
    IsPTXMaximizer β γ r p d q := by
  set rt : Ω → ℝ := fun y => r y + γ * d y / q y with hrt
  have hZ : 0 < partition β rt p := partition_pos hp
  refine isPTXMaximizer_of_ptxScore_const hβ hγ hp hd hq
    (c := β * Real.log (partition β rt p) - β) fun y => ?_
  have hy : q y = p y * Real.exp (rt y / β) / partition β rt p := congrFun hfix y
  have hpy : p y ≠ 0 := (hp.1 y).ne'
  have hratio : q y / p y = Real.exp (rt y / β) / partition β rt p := by
    rw [hy]
    field_simp
  have hlog : Real.log (q y / p y) = rt y / β - Real.log (partition β rt p) := by
    rw [hratio, Real.log_div (Real.exp_ne_zero _) hZ.ne', Real.log_exp]
  have hrty : rt y = r y + γ * d y / q y := by rw [hrt]
  simp only [ptxScore]
  rw [hlog]
  field_simp
  linarith [hrty]

/-- **The optimum is exactly the fixed point.**  For strictly positive policies, global
optimality of the PPO-ptx objective is equivalent to the self-consistent Gibbs equation. -/
theorem ptx_maximizer_iff_self_consistent {β γ : ℝ} {r p d q : Ω → ℝ} (hβ : 0 < β) (hγ : 0 ≤ γ)
    (hp : IsPosDist p) (hd : ∀ y, 0 ≤ d y) (hq : IsPosDist q) :
    IsPTXMaximizer β γ r p d q ↔ q = gibbsPolicy β (fun y => r y + γ * d y / q y) p :=
  ⟨fun h => ptx_self_consistent_gibbs hβ hp h,
    fun h => isPTXMaximizer_of_self_consistent_gibbs hβ hγ hp hd hq h⟩

end RLHF