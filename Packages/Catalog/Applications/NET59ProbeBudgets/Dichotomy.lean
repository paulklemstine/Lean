import Applications.NET59ProbeBudgets.Separation

/-!
# The probe-budget dichotomy

A per-layer budget functional `B` *depends only on the behaviour of a layer at
the probe states `S`* (`ProbeLocal S B`) if `B f p = B f' p'` whenever `f, f'`
and `p, p'` have the same responses at every probe.  It is *calibrated* if an
unpruned layer is charged nothing (`B f f = 0`).  Local + calibrated implies
*probe-blind*: a layer pair whose probe responses agree is charged `0`.

Main results:

* `blind_budget_counterexample` — if the probes do not span `ℚ^α` (and `α` has
  two points), then for **every** probe-blind budget and **every** depth `n+1`
  there is a stack pair whose total budget is `0` and whose joint damage, from
  some input, is `1`;
* `blind_budget_not_relaxed_sound` — no multiplicative or additive slack
  (`joint ≤ C · Σ budgets + δ`, `δ < 1`) repairs such a budget;
* `probe_budget_dichotomy` — **there is a sound, calibrated, `S`-local budget
  iff `α` is a singleton or `S` spans**;
* `window_certifies_iff` — a held-out window of inputs on which two stacks agree
  certifies agreement on *all* inputs iff the window spans;
* `small_window_never_certifies` — a window with fewer inputs than states never
  certifies anything: some stack pair is invisible on the window and maximally
  damaged off it.
-/

namespace Catalog.Probability.NET59.ProbeBudgets

open Finset

variable {α : Type*} [Fintype α]

/-! ## 1. Probe-local budget functionals -/

/-- `B` depends on a layer pair only through the responses at the probe states. -/
def ProbeLocal (S : Set (Dist α)) (B : Kern α α → Kern α α → ℚ) : Prop :=
  ∀ f p f' p' : Kern α α, AgreeOn S f f' → AgreeOn S p p' → B f p = B f' p'

/-- An unpruned layer is charged nothing. -/
def Calibrated (B : Kern α α → Kern α α → ℚ) : Prop := ∀ f : Kern α α, B f f = 0

/-- A layer pair that no probe can tell apart is charged nothing. -/
def ProbeBlind (S : Set (Dist α)) (B : Kern α α → Kern α α → ℚ) : Prop :=
  ∀ f p : Kern α α, AgreeOn S f p → B f p = 0

/-- Probe-local calibrated budgets are probe-blind. -/
theorem ProbeLocal.blind {S : Set (Dist α)} {B : Kern α α → Kern α α → ℚ}
    (hL : ProbeLocal S B) (hC : Calibrated B) : ProbeBlind S B := by
  intro f p hfp
  rw [hL f p f f (fun _ _ => rfl) (fun s hs => (hfp s hs).symm)]
  exact hC f

/-! ## 2. Stacks built from a witness layer -/

theorem chain_replicate_idK' [DecidableEq α] (n : ℕ) (μ : Dist α) :
    chain (List.replicate n (idK : Kern α α)) μ = μ := by
  induction n generalizing μ with
  | zero => simp
  | succ n ih => rw [List.replicate_succ, chain_cons, push_idK, ih]

theorem budgetSum_replicate (B : Kern α α → Kern α α → ℚ) (K : Kern α α) (n : ℕ) :
    budgetSum B (List.replicate n K) (List.replicate n K) = n * B K K := by
  induction n with
  | zero => simp
  | succ n ih => rw [List.replicate_succ, budgetSum_cons, ih]; push_cast; ring

/-- **Necessity of uniform budgets, for every probe-blind functional.**  If the
probe states do not span `ℚ^α`, then at every depth there is a stack pair on
which a probe-blind budget charges nothing in total, while the joint damage from
some input law is maximal. -/
theorem blind_budget_counterexample [DecidableEq α] {S : Set (Dist α)} (hS : ¬ Spans S)
    {x y : α} (hxy : x ≠ y) (B : Kern α α → Kern α α → ℚ) (hB : ProbeBlind S B) (n : ℕ) :
    ∃ F P : List (Kern α α), F.length = n + 1 ∧ P.length = n + 1 ∧
      budgetSum B F P = 0 ∧ ∃ μ : Dist α, tv (chain F μ) (chain P μ) = 1 := by
  obtain ⟨g, q, hgq, a, ha⟩ := exists_blind_pair hS hxy
  refine ⟨g :: List.replicate n idK, q :: List.replicate n idK, by simp, by simp, ?_,
    dirac a, ?_⟩
  · rw [budgetSum_cons, budgetSum_replicate, hB g q hgq, hB idK idK (fun _ _ => rfl)]
    ring
  · rw [chain_cons, chain_cons, chain_replicate_idK', chain_replicate_idK', push_dirac,
      push_dirac, ha]

/-- **No slack repairs a probe-blind budget.**  For a non-spanning probe set, no
inequality `joint ≤ C · Σ budgets + δ` with `δ < 1` holds, whatever the
multiplier `C`. -/
theorem blind_budget_not_relaxed_sound [DecidableEq α] {S : Set (Dist α)} (hS : ¬ Spans S)
    {x y : α} (hxy : x ≠ y) (B : Kern α α → Kern α α → ℚ) (hB : ProbeBlind S B)
    (C δ : ℚ) (hδ : δ < 1) :
    ¬ ∀ F P : List (Kern α α), F.length = P.length →
        ∀ μ : Dist α, tv (chain F μ) (chain P μ) ≤ C * budgetSum B F P + δ := by
  intro h
  obtain ⟨F, P, hF, hP, h0, μ, h1⟩ := blind_budget_counterexample hS hxy B hB 0
  have := h F P (by rw [hF, hP]) μ
  rw [h0, h1, mul_zero, zero_add] at this
  linarith

/-! ## 3. The dichotomy -/

/-- The Dirac-sum budget `Σ_a tv (f a) (p a)`; it dominates the uniform budget and
is defined without choosing a maximiser. -/
def diracSumBudget (f p : Kern α α) : ℚ := ∑ a, tv (f a) (p a)

theorem diracSumBudget_sound : SoundBudget (diracSumBudget (α := α)) :=
  budget_sound_of_dominates _ fun f p a =>
    Finset.single_le_sum (f := fun a => tv (f a) (p a)) (fun _ _ => tv_nonneg _ _)
      (Finset.mem_univ a)

/-- **Probe-budget dichotomy.**  A finite (or arbitrary) set of probe states
supports a sound, calibrated budget depending only on the probe responses if and
only if the state space is a singleton or the probe vectors span `ℚ^α`.

* If they span, the probes determine the layer (`separates_of_spans`) and the
  worst-case budget can be computed from them.
* If they do not, *every* calibrated probe-local budget is defeated, at every
  depth, by a stack with zero total budget and maximal joint damage. -/
theorem probe_budget_dichotomy [DecidableEq α] (S : Set (Dist α)) :
    (∃ B : Kern α α → Kern α α → ℚ, ProbeLocal S B ∧ Calibrated B ∧ SoundBudget B) ↔
      Subsingleton α ∨ Spans S := by
  constructor
  · rintro ⟨B, hL, hC, hsound⟩
    by_contra h
    push_neg at h
    obtain ⟨hnt, hspan⟩ := h
    obtain ⟨x, y, hxy⟩ := exists_pair_ne α
    obtain ⟨F, P, hF, hP, h0, μ, h1⟩ :=
      blind_budget_counterexample hspan hxy B (hL.blind hC) 0
    have := hsound F P (by rw [hF, hP]) μ
    rw [h0, h1] at this
    norm_num at this
  · intro h
    have hsep : Separates S := (separates_iff S).2 h
    refine ⟨diracSumBudget, ?_, ?_, diracSumBudget_sound⟩
    · intro f p f' p' hf hp
      rw [hsep f f' hf, hsep p p' hp]
    · intro f
      simp [diracSumBudget]

/-- **A finite probe set suffices.**  The `|α|` Dirac probes carry a sound,
calibrated, probe-local budget — namely the uniform worst-case budget. -/
theorem diracProbes_suffice [DecidableEq α] :
    ∃ B : Kern α α → Kern α α → ℚ,
      ProbeLocal (Set.range (dirac : α → Dist α)) B ∧ Calibrated B ∧ SoundBudget B :=
  (probe_budget_dichotomy _).2 (Or.inr diracProbes_spans)

/-- **Probe count lower bound.**  If a family of `m` probe states supports a
sound calibrated probe-local budget on a state space with at least two points,
then `m ≥ |α|`. -/
theorem probe_count_lower_bound [DecidableEq α] [Nontrivial α] {m : ℕ}
    (probes : Fin m → Dist α)
    (h : ∃ B : Kern α α → Kern α α → ℚ,
      ProbeLocal (Set.range probes) B ∧ Calibrated B ∧ SoundBudget B) :
    Fintype.card α ≤ m := by
  rcases (probe_budget_dichotomy _).1 h with hs | hs
  · exact absurd hs (not_subsingleton α)
  · exact card_le_of_spans probes hs

/-! ## 4. Held-out windows -/

/-- **Window dichotomy.**  Agreement of two stacks on every input of a held-out
window certifies agreement on all inputs if and only if the window spans (or the
state space is trivial). -/
theorem window_certifies_iff [DecidableEq α] (W : Set (Dist α)) :
    (∀ F P : List (Kern α α), (∀ w ∈ W, chain F w = chain P w) →
        ∀ μ : Dist α, chain F μ = chain P μ) ↔ Subsingleton α ∨ Spans W := by
  rw [← separates_iff]
  constructor
  · intro h g q hgq
    funext a
    have := h [g] [q] (fun w hw => by simpa using hgq w hw) (dirac a)
    simpa using this
  · intro hsep F P hFP μ
    have hK : chainK F = chainK P := hsep _ _ fun w hw => by
      rw [← chain_eq_push_chainK, ← chain_eq_push_chainK]; exact hFP w hw
    rw [chain_eq_push_chainK, chain_eq_push_chainK, hK]

/-- **Small windows never certify.**  If a held-out window has fewer inputs than
there are states, some depth-`n+1` stack pair is exactly invisible on the window
(identical outputs at every window input) yet does maximal damage at some other
input.  (`Nontrivial α` is needed: on a one-point space nothing can be damaged.) -/
theorem small_window_never_certifies [DecidableEq α] [Nontrivial α] {m : ℕ} (window : Fin m → Dist α)
    (hm : m < Fintype.card α) (n : ℕ) :
    ∃ F P : List (Kern α α), F.length = n + 1 ∧ P.length = n + 1 ∧
      (∀ i, chain F (window i) = chain P (window i)) ∧
      ∃ μ : Dist α, tv (chain F μ) (chain P μ) = 1 := by
  have hspan : ¬ Spans (Set.range window) := fun h => absurd (card_le_of_spans window h) (by omega)
  obtain ⟨x, y, hxy⟩ := exists_pair_ne α
  obtain ⟨g, q, hgq, a, ha⟩ := exists_blind_pair hspan hxy
  refine ⟨g :: List.replicate n idK, q :: List.replicate n idK, by simp, by simp, ?_,
    dirac a, ?_⟩
  · intro i
    rw [chain_cons, chain_cons, chain_replicate_idK', chain_replicate_idK']
    exact hgq _ ⟨i, rfl⟩
  · rw [chain_cons, chain_cons, chain_replicate_idK', chain_replicate_idK', push_dirac,
      push_dirac, ha]

end Catalog.Probability.NET59.ProbeBudgets