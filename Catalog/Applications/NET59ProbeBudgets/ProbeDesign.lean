import Applications.NET59ProbeBudgets.MaskingSuffix

/-!
# Which probes?  Trajectory budgets and design coefficients

The dichotomy (`probe_budget_dichotomy`) says a probe set supports a sound
budget iff it spans.  This file makes the positive side *quantitative and
constructive*, which is what an experimental programme needs, and pins down the
exact boundary of the negative side.

## Trajectory budgets (the sharp edge of the dichotomy)

* `joint_le_trajectoryCost` — for a **fixed input** `μ`, the joint damage is at
  most the sum of the layer-output perturbations measured at the **intact
  upstream states of that same input**.  So a per-layer measurement taken on the
  input's own intact trajectory *is* sound for that input; what fails is reusing
  it for other inputs.
* `trajectory_window_dichotomy` — zero trajectory cost on every input of a
  held-out window certifies zero damage on **all** inputs iff the window spans.

## Design coefficients (the positive side, made quantitative)

* `tv_push_le_combination` — if `v = Σ cᵢ sᵢ` as signed measures, the
  perturbation of a layer at `v` is at most `Σ |cᵢ|` times its perturbations at
  the probes `sᵢ`;
* `designBudget_sound` — given probes `s` and coefficients `c` writing every
  Dirac state as `Σ c a i • s i`, the **design budget**
  `Σ_a Σ_i |c a i| · tv (push f (s i)) (push p (s i))` is probe-local,
  calibrated and sound: an explicit sound budget computed from probe
  measurements only;
* `window_extrapolation` — the same coefficients extrapolate joint damage from a
  held-out window to any input in its span, with amplification `Σ |cᵢ|`.
-/

namespace Catalog.Probability.NET59.ProbeBudgets

open Finset

variable {α : Type*} [Fintype α]

/-! ## 1. Trajectory costs -/

/-- The trajectory cost of a stack pair at input `μ`: layer `j` is charged the
perturbation of its *own output* at the intact upstream state of `μ`. -/
def trajectoryCost : List (Kern α α) → List (Kern α α) → Dist α → ℚ
  | f :: F, p :: P, μ => tv (push f μ) (push p μ) + trajectoryCost F P (push f μ)
  | _, _, _ => 0

@[simp] theorem trajectoryCost_cons (f p : Kern α α) (F P : List (Kern α α)) (μ : Dist α) :
    trajectoryCost (f :: F) (p :: P) μ = tv (push f μ) (push p μ) + trajectoryCost F P (push f μ) :=
  rfl

/-- **Trajectory bound.**  At a fixed input, joint damage is at most the sum of the
per-layer output perturbations measured along the intact trajectory of that
input.  (Compare `chain_hybrid_bound`, which measures along the *pruned*
trajectory, inaccessible to an experimenter who only runs the intact model.) -/
theorem joint_le_trajectoryCost :
    ∀ (F P : List (Kern α α)), F.length = P.length →
      ∀ μ : Dist α, tv (chain F μ) (chain P μ) ≤ trajectoryCost F P μ := by
  intro F
  induction F with
  | nil => intro P hlen μ; cases P with
    | nil => simp [trajectoryCost]
    | cons p P => simp at hlen
  | cons f F ih =>
      intro P hlen μ
      cases P with
      | nil => simp at hlen
      | cons p P =>
          rw [chain_cons, chain_cons, trajectoryCost_cons]
          have h1 := tv_triangle (chain F (push f μ)) (chain P (push f μ)) (chain P (push p μ))
          have h2 := ih P (by simpa using hlen) (push f μ)
          have h3 := tv_chain_le P (push f μ) (push p μ)
          linarith

/-- Zero trajectory cost forces zero damage at that input. -/
theorem chain_eq_of_trajectoryCost_eq_zero (F P : List (Kern α α)) (hlen : F.length = P.length)
    (μ : Dist α) (h : trajectoryCost F P μ = 0) : chain F μ = chain P μ := by
  have := joint_le_trajectoryCost F P hlen μ
  rw [h] at this
  exact (tv_eq_zero_iff _ _).1 (le_antisymm this (tv_nonneg _ _))

/-- **Trajectory-window dichotomy.**  Requiring every pruned layer to reproduce its
intact counterpart along the intact trajectories of a held-out window certifies
the pruned stack on *all* inputs iff the window spans (or `α` is trivial).
Held-out-window measurements are sound *on the window*
(`joint_le_trajectoryCost`); they extrapolate exactly when the window spans. -/
theorem trajectory_window_dichotomy [DecidableEq α] (W : Set (Dist α)) :
    (∀ F P : List (Kern α α), F.length = P.length →
        (∀ w ∈ W, trajectoryCost F P w = 0) → ∀ μ : Dist α, chain F μ = chain P μ) ↔
      Subsingleton α ∨ Spans W := by
  rw [← window_certifies_iff]
  constructor
  · intro h
    rw [window_certifies_iff, ← separates_iff]
    intro g q hgq
    funext a
    have := h [g] [q] rfl (fun w hw => by simp [trajectoryCost, hgq w hw]) (dirac a)
    simpa using this
  · intro h F P hlen hW μ
    exact h F P (fun w hw => chain_eq_of_trajectoryCost_eq_zero F P hlen w (hW w hw)) μ

/-! ## 2. Signed combinations of probes -/

/-- **Combination inequality.**  If `v.p = Σᵢ cᵢ • (s i).p`, then the perturbation
of a layer at `v` is controlled by its perturbations at the probes, weighted by
`|cᵢ|`. -/
theorem tv_push_le_combination {ι : Type*} [Fintype ι] (f p : Kern α α) (s : ι → Dist α)
    (c : ι → ℚ) (v : Dist α) (hv : v.p = ∑ i, c i • (s i).p) :
    tv (push f v) (push p v) ≤ ∑ i, |c i| * tv (push f (s i)) (push p (s i)) := by
  have hdiff : ∀ b, (push f v).p b - (push p v).p b
      = ∑ i, c i * ((push f (s i)).p b - (push p (s i)).p b) := by
    intro b
    have e1 : (push f v).p b = ∑ i, c i * (push f (s i)).p b := by
      rw [← pushL_dist, hv, map_sum]
      simp only [map_smul, Finset.sum_apply, Pi.smul_apply, smul_eq_mul, pushL_dist]
    have e2 : (push p v).p b = ∑ i, c i * (push p (s i)).p b := by
      rw [← pushL_dist, hv, map_sum]
      simp only [map_smul, Finset.sum_apply, Pi.smul_apply, smul_eq_mul, pushL_dist]
    rw [e1, e2, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun i _ => by ring
  have hb : ∀ b, |(push f v).p b - (push p v).p b|
      ≤ ∑ i, |c i| * |(push f (s i)).p b - (push p (s i)).p b| := by
    intro b
    rw [hdiff b]
    refine (Finset.abs_sum_le_sum_abs _ _).trans (le_of_eq ?_)
    exact Finset.sum_congr rfl fun i _ => abs_mul _ _
  unfold tv
  have hsum := Finset.sum_le_sum fun b (_ : b ∈ Finset.univ) => hb b
  rw [Finset.sum_comm] at hsum
  have : ∑ i, |c i| * ((∑ b, |(push f (s i)).p b - (push p (s i)).p b|) / 2)
      = (∑ i, ∑ b, |c i| * |(push f (s i)).p b - (push p (s i)).p b|) / 2 := by
    rw [Finset.sum_div]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [mul_div_assoc', Finset.mul_sum]
  rw [this]
  linarith

/-! ## 3. Design budgets -/

/-- The design budget of a probe family `s` with Dirac-representing coefficients
`c`: computed from the probe responses only. -/
def designBudget {ι : Type*} [Fintype ι] (s : ι → Dist α) (c : α → ι → ℚ)
    (f p : Kern α α) : ℚ :=
  ∑ a, ∑ i, |c a i| * tv (push f (s i)) (push p (s i))

/-- **Constructive sufficiency.**  If the coefficients `c` write every Dirac state
as a signed combination of the probes, the design budget is probe-local,
calibrated and sound. -/
theorem designBudget_sound [DecidableEq α] {ι : Type*} [Fintype ι] (s : ι → Dist α)
    (c : α → ι → ℚ) (hc : ∀ a, (dirac a).p = ∑ i, c a i • (s i).p) :
    ProbeLocal (Set.range s) (designBudget s c) ∧ Calibrated (designBudget s c) ∧
      SoundBudget (designBudget s c) := by
  refine ⟨?_, ?_, ?_⟩
  · intro f p f' p' hf hp
    unfold designBudget
    refine Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun i _ => ?_
    rw [hf (s i) ⟨i, rfl⟩, hp (s i) ⟨i, rfl⟩]
  · intro f; simp [designBudget]
  · refine budget_sound_of_dominates _ fun f p a => ?_
    have h1 := tv_push_le_combination f p s (c a) (dirac a) (hc a)
    rw [push_dirac, push_dirac] at h1
    refine h1.trans ?_
    exact Finset.single_le_sum (f := fun a => ∑ i, |c a i| * tv (push f (s i)) (push p (s i)))
      (fun a _ => Finset.sum_nonneg fun i _ => mul_nonneg (abs_nonneg _) (tv_nonneg _ _))
      (Finset.mem_univ a)

/-- With the Dirac probes and identity coefficients the design budget is the
Dirac-sum budget: the canonical design. -/
theorem designBudget_dirac [DecidableEq α] (f p : Kern α α) :
    designBudget (dirac : α → Dist α) (fun a i => if a = i then 1 else 0) f p
      = diracSumBudget f p := by
  unfold designBudget diracSumBudget
  refine Finset.sum_congr rfl fun a _ => ?_
  rw [Finset.sum_eq_single a] <;> simp +contextual [push_dirac, eq_comm]

/-- **Window extrapolation.**  If an input `μ` is a signed combination
`Σ cᵢ wᵢ` of held-out window inputs, its joint damage is at most `Σ |cᵢ|` times
the trajectory costs measured on the window.  The `ℓ¹` size of the coefficients
is the amplification factor of the probe design. -/
theorem window_extrapolation [DecidableEq α] {ι : Type*} [Fintype ι]
    (F P : List (Kern α α)) (hlen : F.length = P.length) (w : ι → Dist α) (c : ι → ℚ)
    (μ : Dist α) (hμ : μ.p = ∑ i, c i • (w i).p) :
    tv (chain F μ) (chain P μ) ≤ ∑ i, |c i| * trajectoryCost F P (w i) := by
  rw [chain_eq_push_chainK, chain_eq_push_chainK]
  refine (tv_push_le_combination _ _ w c μ hμ).trans ?_
  refine Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ?_ (abs_nonneg _)
  rw [← chain_eq_push_chainK, ← chain_eq_push_chainK]
  exact joint_le_trajectoryCost F P hlen (w i)

/-! ## 4. Lab notes

Exact data on `Fin 2`.

```
probe set                 spans?   blind pair / design coefficients
{bern 1/2}                no       idK vs flipK: equal at the probe, tv at d0 = 1
{bern 1/4, bern 3/4}      yes      d0 = 3/2·bern 1/4 − 1/2·bern 3/4   (ℓ¹ amplification 2)
                                   d1 = −1/2·bern 1/4 + 3/2·bern 3/4  (ℓ¹ amplification 2)
```
-/

section LabNotes

/-- A balanced held-out probe cannot tell the identity from a full flip. -/
example : push idK (bern (1 / 2) (by norm_num) (by norm_num))
      = push flipK (bern (1 / 2) (by norm_num) (by norm_num)) ∧
    tv ((idK : Kern (Fin 2) (Fin 2)) 0) (flipK 0) = 1 := by
  refine ⟨?_, ?_⟩
  · rw [push_idK, push_flipK]; congr 1; norm_num
  · have h1 : (idK : Kern (Fin 2) (Fin 2)) 0 = dirac 0 := rfl
    have h2 : flipK 0 = dirac 1 := by simp [flipK]
    rw [h1, h2, tv_dirac_ne (by decide)]

/-- The probe pair `bern 1/4`, `bern 3/4` spans, with explicit coefficients. -/
theorem lab_d0_combination :
    (d0).p = (3 / 2 : ℚ) • (bern (1 / 4) (by norm_num) (by norm_num)).p
      + (-1 / 2 : ℚ) • (bern (3 / 4) (by norm_num) (by norm_num)).p := by
  funext b; fin_cases b <;> simp [d0, bern] <;> norm_num

/-- Window extrapolation with amplification `2`: the joint damage from `d0` of
any pruned stack is at most `3/2` times its trajectory cost at `bern 1/4` plus
`1/2` times its trajectory cost at `bern 3/4`. -/
example (F P : List (Kern (Fin 2) (Fin 2))) (hlen : F.length = P.length) :
    tv (chain F d0) (chain P d0)
      ≤ 3 / 2 * trajectoryCost F P (bern (1 / 4) (by norm_num) (by norm_num))
        + 1 / 2 * trajectoryCost F P (bern (3 / 4) (by norm_num) (by norm_num)) := by
  have h := window_extrapolation F P hlen
    (![bern (1 / 4) (by norm_num) (by norm_num), bern (3 / 4) (by norm_num) (by norm_num)])
    ![3 / 2, -1 / 2] d0 (by rw [lab_d0_combination]; simp [Fin.sum_univ_two])
  simp only [Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one] at h
  norm_num [abs_of_pos, abs_of_neg] at h
  linarith

end LabNotes

end Catalog.Probability.NET59.ProbeBudgets