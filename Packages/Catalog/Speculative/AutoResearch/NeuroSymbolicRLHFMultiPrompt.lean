/-
Copyright (c) 2025. All rights reserved.

# Multi-Prompt RLHF and Uniqueness of the PPO-ptx Optimum

Third research cycle, building on
`Catalog.Shared.NeuroSymbolicRLHFObjective`.

Two results:

* **Prompt-wise decomposition.**  The full InstructGPT objective takes an
  expectation over a prompt distribution `D`.  We show that the optimum
  decomposes: the global optimum of the prompt-averaged objective is attained
  exactly when *every* conditional policy is the exponentially tilted policy for
  its own prompt (assuming every prompt has positive probability), and the
  optimal value is the `D`-average of the per-prompt free energies.
  Consequently the **alignment tax of the PTX term is localised**: coupling the
  pre-training mix-in to a single prompt `x₀` leaves the optimal conditional
  policies at all other prompts untouched, and the joint bound is attainable
  iff the pre-training distribution equals the tilted policy at `x₀`.

* **Uniqueness of the PPO-ptx optimum.**  The full objective (reward + KL
  penalty + PTX) has *at most one* maximiser among full-support policies.  This
  is proved from strict convexity of `x ↦ x log x` (strict convexity of the KL
  divergence in its first argument) together with concavity of `log`
  (convexity of the KL divergence in its second argument); no differentiability
  or first-order conditions are used.

No `sorry`, no `native_decide`.
-/
import Mathlib
import Catalog.Shared.NeuroSymbolicRLHFObjective

open Finset Real BigOperators Set

noncomputable section

namespace NeuroSymbolicRLHF

variable {ι : Type*} [Fintype ι]

/-! ## Part 1: prompt-wise decomposition of the RLHF objective -/

section MultiPrompt

variable {χ : Type*} [Fintype χ]

/-- The prompt-averaged RLHF objective `𝔼_{x ∼ D}[Objective(p x)]`. -/
def rlhfMulti (β : ℝ) (D : χ → ℝ) (ref r p : χ → ι → ℝ) : ℝ :=
  ∑ x, D x * rlhfObj β (ref x) (r x) (p x)

/-- The prompt-averaged optimal value. -/
def freeEnergyMulti (β : ℝ) (D : χ → ℝ) (ref r : χ → ι → ℝ) : ℝ :=
  ∑ x, D x * freeEnergy β (ref x) (r x)

theorem rlhfMulti_le {β : ℝ} (hβ : 0 < β) {D : χ → ℝ} {ref r p : χ → ι → ℝ} [Nonempty ι]
    (hD : ∀ x, 0 ≤ D x) (href : ∀ x, IsPosProb (ref x)) (hp : ∀ x, IsProb (p x)) :
    rlhfMulti β D ref r p ≤ freeEnergyMulti β D ref r := by
  refine Finset.sum_le_sum fun x _ => ?_
  exact mul_le_mul_of_nonneg_left (rlhfObj_le_freeEnergy hβ (href x) (hp x)) (hD x)

/-- **Prompt-wise optimality**: the prompt-averaged objective attains its bound
iff every conditional policy is the tilted policy of its own prompt. -/
theorem rlhfMulti_eq_iff {β : ℝ} (hβ : 0 < β) {D : χ → ℝ} {ref r p : χ → ι → ℝ} [Nonempty ι]
    (hD : ∀ x, 0 < D x) (href : ∀ x, IsPosProb (ref x)) (hp : ∀ x, IsProb (p x)) :
    rlhfMulti β D ref r p = freeEnergyMulti β D ref r
      ↔ ∀ x, p x = gibbs β (ref x) (r x) := by
  have hle : ∀ x ∈ (univ : Finset χ),
      D x * rlhfObj β (ref x) (r x) (p x) ≤ D x * freeEnergy β (ref x) (r x) := by
    intro x _
    exact mul_le_mul_of_nonneg_left (rlhfObj_le_freeEnergy hβ (href x) (hp x)) (hD x).le
  rw [rlhfMulti, freeEnergyMulti, Finset.sum_eq_sum_iff_of_le hle]
  constructor
  · intro h x
    have hx := h x (Finset.mem_univ x)
    have : rlhfObj β (ref x) (r x) (p x) = freeEnergy β (ref x) (r x) :=
      mul_left_cancel₀ (hD x).ne' hx
    exact (rlhfObj_eq_freeEnergy_iff hβ (href x) (hp x)).1 this
  · intro h x _
    rw [(rlhfObj_eq_freeEnergy_iff hβ (href x) (hp x)).2 (h x)]

/-- The complete PPO-ptx objective: prompt-averaged reward with KL penalty, plus
the pre-training mix-in coupled to the conditional policy at a distinguished
prompt `x₀`. -/
def fullPtxObj (β γ : ℝ) (D : χ → ℝ) (ref r : χ → ι → ℝ) (pre : ι → ℝ)
    (p : χ → ι → ℝ) (x₀ : χ) : ℝ :=
  rlhfMulti β D ref r p + ptxTerm γ pre (p x₀)

theorem fullPtxObj_le {β γ : ℝ} (hβ : 0 < β) (hγ : 0 ≤ γ) {D : χ → ℝ}
    {ref r : χ → ι → ℝ} {pre : ι → ℝ} {p : χ → ι → ℝ} {x₀ : χ} [Nonempty ι]
    (hD : ∀ x, 0 ≤ D x) (href : ∀ x, IsPosProb (ref x)) (hpre : IsPosProb pre)
    (hp : ∀ x, IsPosProb (p x)) :
    fullPtxObj β γ D ref r pre p x₀
      ≤ freeEnergyMulti β D ref r + ptxTerm γ pre pre := by
  have h1 := rlhfMulti_le hβ hD href (fun x => (hp x).isProb) (p := p) (r := r)
  have h2 := ptxTerm_le hγ hpre (hp x₀)
  unfold fullPtxObj
  linarith

/-- **Localisation of the alignment tax**: the joint bound for the full
objective is attainable iff the pre-training distribution is *exactly* the
tilted policy at the coupled prompt `x₀`; the conditionals at all other prompts
are unaffected by the PTX term. -/
theorem fullPtxObj_eq_iff {β γ : ℝ} (hβ : 0 < β) (hγ : 0 < γ) {D : χ → ℝ}
    {ref r : χ → ι → ℝ} {pre : ι → ℝ} {p : χ → ι → ℝ} {x₀ : χ} [Nonempty ι]
    (hD : ∀ x, 0 < D x) (href : ∀ x, IsPosProb (ref x)) (hpre : IsPosProb pre)
    (hp : ∀ x, IsPosProb (p x)) :
    fullPtxObj β γ D ref r pre p x₀ = freeEnergyMulti β D ref r + ptxTerm γ pre pre
      ↔ (∀ x, p x = gibbs β (ref x) (r x)) ∧ pre = p x₀ := by
  have h1 := rlhfMulti_le hβ (fun x => (hD x).le) href (fun x => (hp x).isProb)
      (p := p) (r := r)
  have h2 := ptxTerm_le hγ.le hpre (hp x₀)
  have hkl : 0 ≤ klDivFin pre (p x₀) := klDivFin_nonneg hpre.isProb (hp x₀)
  have hptx : ptxTerm γ pre pre - ptxTerm γ pre (p x₀) = γ * klDivFin pre (p x₀) := by
    unfold ptxTerm
    rw [klDivFin_of_pos hpre (hp x₀)]
    ring
  constructor
  · intro h
    have hsum : rlhfMulti β D ref r p = freeEnergyMulti β D ref r := by
      unfold fullPtxObj at h
      linarith
    have hptxeq : ptxTerm γ pre (p x₀) = ptxTerm γ pre pre := by
      unfold fullPtxObj at h
      linarith
    refine ⟨(rlhfMulti_eq_iff hβ hD href (fun x => (hp x).isProb)).1 hsum, ?_⟩
    have : γ * klDivFin pre (p x₀) = 0 := by linarith [hptx, hptxeq]
    have hz : klDivFin pre (p x₀) = 0 := by
      rcases mul_eq_zero.1 this with h' | h'
      · exact absurd h' hγ.ne'
      · exact h'
    exact (klDivFin_eq_zero_iff hpre.isProb (hp x₀)).1 hz
  · rintro ⟨hgib, hpx⟩
    unfold fullPtxObj
    rw [(rlhfMulti_eq_iff hβ hD href (fun x => (hp x).isProb)).2 hgib, ← hpx]

end MultiPrompt

/-! ## Part 2: uniqueness of the PPO-ptx optimum via strict concavity -/

/-- Rewriting a KL summand, valid also at `a = 0`. -/
theorem mul_log_div_eq {a c : ℝ} (ha : 0 ≤ a) (hc : 0 < c) :
    a * Real.log (a / c) = a * Real.log a - a * Real.log c := by
  rcases eq_or_lt_of_le ha with h | h
  · simp [← h]
  · rw [Real.log_div h.ne' hc.ne']
    ring

/-- Strict convexity of the KL divergence in its first argument, in midpoint
form: if `p ≠ q` then the KL divergence of the midpoint is strictly below the
average. -/
theorem klDivFin_midpoint_lt {p q c : ι → ℝ} (hp : IsProb p) (hq : IsProb q)
    (hc : IsPosProb c) (hne : p ≠ q) :
    klDivFin (fun i => (p i + q i) / 2) c < (klDivFin p c + klDivFin q c) / 2 := by
  have key : ∀ i : ι,
      ((p i + q i) / 2) * Real.log (((p i + q i) / 2) / c i)
        ≤ (p i * Real.log (p i / c i) + q i * Real.log (q i / c i)) / 2 := by
    intro i
    have hmid : (0:ℝ) ≤ (p i + q i) / 2 := by
      have := hp.nonneg i; have := hq.nonneg i; linarith
    rw [mul_log_div_eq hmid (hc.pos i), mul_log_div_eq (hp.nonneg i) (hc.pos i),
      mul_log_div_eq (hq.nonneg i) (hc.pos i)]
    have hconv := strictConvexOn_mul_log.convexOn.2 (mem_Ici.2 (hp.nonneg i))
      (mem_Ici.2 (hq.nonneg i)) (by norm_num : (0:ℝ) ≤ 1/2) (by norm_num : (0:ℝ) ≤ 1/2)
      (by norm_num)
    simp only [smul_eq_mul] at hconv
    have harg : (1/2 : ℝ) * p i + (1/2 : ℝ) * q i = (p i + q i) / 2 := by ring
    rw [harg] at hconv
    linarith
  obtain ⟨j, hj⟩ : ∃ j, p j ≠ q j := by
    by_contra hall
    exact hne (funext fun i => not_not.1 fun h' => hall ⟨i, h'⟩)
  have keyj : ((p j + q j) / 2) * Real.log (((p j + q j) / 2) / c j)
      < (p j * Real.log (p j / c j) + q j * Real.log (q j / c j)) / 2 := by
    have hmid : (0:ℝ) ≤ (p j + q j) / 2 := by
      have := hp.nonneg j; have := hq.nonneg j; linarith
    rw [mul_log_div_eq hmid (hc.pos j), mul_log_div_eq (hp.nonneg j) (hc.pos j),
      mul_log_div_eq (hq.nonneg j) (hc.pos j)]
    have hconv := strictConvexOn_mul_log.2 (mem_Ici.2 (hp.nonneg j))
      (mem_Ici.2 (hq.nonneg j)) hj (by norm_num : (0:ℝ) < 1/2) (by norm_num : (0:ℝ) < 1/2)
      (by norm_num)
    simp only [smul_eq_mul] at hconv
    have harg : (1/2 : ℝ) * p j + (1/2 : ℝ) * q j = (p j + q j) / 2 := by ring
    rw [harg] at hconv
    linarith
  have hlt : ∑ i, ((p i + q i) / 2) * Real.log (((p i + q i) / 2) / c i)
      < ∑ i, (p i * Real.log (p i / c i) + q i * Real.log (q i / c i)) / 2 :=
    Finset.sum_lt_sum (fun i _ => key i) ⟨j, Finset.mem_univ j, keyj⟩
  have hrhs : ∑ i, (p i * Real.log (p i / c i) + q i * Real.log (q i / c i)) / 2
      = (klDivFin p c + klDivFin q c) / 2 := by
    unfold klDivFin
    rw [← Finset.sum_add_distrib, ← Finset.sum_div]
  rw [klDivFin]
  linarith [hlt, hrhs]

/-- Convexity of the KL divergence in its second argument, midpoint form. -/
theorem klDivFin_midpoint_le_snd {a p q : ι → ℝ} (ha : IsProb a) (hp : IsPosProb p)
    (hq : IsPosProb q) :
    klDivFin a (fun i => (p i + q i) / 2) ≤ (klDivFin a p + klDivFin a q) / 2 := by
  have key : ∀ i : ι,
      a i * Real.log (a i / ((p i + q i) / 2))
        ≤ (a i * Real.log (a i / p i) + a i * Real.log (a i / q i)) / 2 := by
    intro i
    have hmid : (0:ℝ) < (p i + q i) / 2 := by
      have := hp.pos i; have := hq.pos i; linarith
    rw [mul_log_div_eq (ha.nonneg i) hmid, mul_log_div_eq (ha.nonneg i) (hp.pos i),
      mul_log_div_eq (ha.nonneg i) (hq.pos i)]
    have hlog : (Real.log (p i) + Real.log (q i)) / 2 ≤ Real.log ((p i + q i) / 2) := by
      have hconc := strictConcaveOn_log_Ioi.concaveOn.2 (mem_Ioi.2 (hp.pos i))
        (mem_Ioi.2 (hq.pos i)) (by norm_num : (0:ℝ) ≤ 1/2) (by norm_num : (0:ℝ) ≤ 1/2)
        (by norm_num)
      simp only [smul_eq_mul] at hconc
      have harg : (1/2 : ℝ) * p i + (1/2 : ℝ) * q i = (p i + q i) / 2 := by ring
      rw [harg] at hconc
      linarith
    nlinarith [ha.nonneg i, hlog]
  calc klDivFin a (fun i => (p i + q i) / 2)
      ≤ ∑ i, (a i * Real.log (a i / p i) + a i * Real.log (a i / q i)) / 2 :=
        Finset.sum_le_sum fun i _ => key i
    _ = (klDivFin a p + klDivFin a q) / 2 := by
        unfold klDivFin
        rw [← Finset.sum_add_distrib, ← Finset.sum_div]

theorem isPosProb_midpoint {p q : ι → ℝ} (hp : IsPosProb p) (hq : IsPosProb q) :
    IsPosProb (fun i => (p i + q i) / 2) := by
  refine ⟨fun i => by have := hp.pos i; have := hq.pos i; linarith, ?_⟩
  have : ∑ i, (p i + q i) / 2 = (∑ i, p i + ∑ i, q i) / 2 := by
    rw [← Finset.sum_add_distrib, ← Finset.sum_div]
  rw [this, hp.sum_one, hq.sum_one]
  norm_num

/-- **Uniqueness of the PPO-ptx optimum**: the full objective (reward, KL
penalty and pre-training mix-in) has at most one maximiser among full-support
policies.  Strict concavity comes from the KL term alone, so the statement holds
for every `γ ≥ 0`, including the pure RLHF case `γ = 0`. -/
theorem rlhfPtx_maximizer_unique {β γ : ℝ} (hβ : 0 < β) (hγ : 0 ≤ γ)
    {ref r pre p q : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) (hpre : IsPosProb pre) (hp : IsPosProb p) (hq : IsPosProb q)
    (hpmax : ∀ z : ι → ℝ, IsPosProb z →
      rlhfPtxObj β γ ref r pre z ≤ rlhfPtxObj β γ ref r pre p)
    (hqmax : ∀ z : ι → ℝ, IsPosProb z →
      rlhfPtxObj β γ ref r pre z ≤ rlhfPtxObj β γ ref r pre q) :
    p = q := by
  by_contra hne
  set m : ι → ℝ := fun i => (p i + q i) / 2 with hm
  have hmm : IsPosProb m := isPosProb_midpoint hp hq
  have hpq : rlhfPtxObj β γ ref r pre p = rlhfPtxObj β γ ref r pre q :=
    le_antisymm (hqmax p hp) (hpmax q hq)
  have hklfst : klDivFin m (gibbs β ref r)
      < (klDivFin p (gibbs β ref r) + klDivFin q (gibbs β ref r)) / 2 :=
    klDivFin_midpoint_lt hp.isProb hq.isProb (gibbs_isPosProb href) hne
  have hklsnd : klDivFin pre m ≤ (klDivFin pre p + klDivFin pre q) / 2 :=
    klDivFin_midpoint_le_snd hpre.isProb hp hq
  have hep := rlhfPtxObj_eq hβ href hpre hp (r := r) (γ := γ)
  have heq := rlhfPtxObj_eq hβ href hpre hq (r := r) (γ := γ)
  have hem := rlhfPtxObj_eq hβ href hpre hmm (r := r) (γ := γ)
  have hmle : rlhfPtxObj β γ ref r pre m ≤ rlhfPtxObj β γ ref r pre p := hpmax m hmm
  rw [hep, heq] at hpq
  rw [hem, hep] at hmle
  nlinarith [hklfst, hklsnd, hβ, hγ]

end NeuroSymbolicRLHF