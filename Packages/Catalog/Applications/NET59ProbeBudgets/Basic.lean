import Probability.NET59NonIdentifiability

/-!
# Per-layer budgets: soundness is exactly uniform domination

`Probability.NET59HybridEpistasis` proves that a per-layer perturbation bound
that is *uniform over upstream states* adds up along depth
(`chain_tv_le_depth_mul`), and `Probability.NET59NonIdentifiability` shows that a
bound certified at a *single* state does not.  This file turns the pair of
observations into an exact characterisation.

A **per-layer budget functional** is any map `B : Kern α α → Kern α α → ℚ`
assigning a number to an (intact, pruned) layer pair.  It is **sound** if for
every pair of stacks of equal depth and every input law, the joint damage is at
most the sum of the per-layer budgets.

Main results:

* `budget_sound_of_dominates` — if `B f p ≥ tv (f a) (p a)` for every state `a`
  then `B` is sound (heterogeneous depth-additivity, generalising
  `chain_tv_le_depth_mul`);
* `dominates_of_budget_sound` — conversely every sound budget dominates the
  pointwise channel distance at every state (single-layer stacks with Dirac
  inputs);
* `budget_sound_iff_dominates` — **soundness ⇔ uniform domination**;
* `uniformBudget` (the worst case over states) is sound and is the *least*
  sound budget: `budget_sound_iff_uniform_le`.

So "certify worst-case per-layer behaviour" is not one policy among others: it
is literally the definition of a sound budget.
-/

namespace Catalog.Probability.NET59.ProbeBudgets

open Finset

variable {α : Type*} [Fintype α]

/-! ## 1. Small facts about channels -/

/-- Pushing a Dirac mass through a channel evaluates the channel. -/
@[simp] theorem push_dirac [DecidableEq α] (K : Kern α α) (a : α) : push K (dirac a) = K a := by
  refine Dist.ext' fun b => ?_
  simp only [push_apply, dirac]
  rw [Finset.sum_eq_single a] <;> simp +contextual

/-- Sequential composition of two channels: first `K`, then `G`. -/
def compK (K G : Kern α α) : Kern α α := fun a => push G (K a)

/-- Pushing twice is pushing through the composite channel. -/
theorem push_push (K G : Kern α α) (μ : Dist α) : push G (push K μ) = push (compK K G) μ := by
  refine Dist.ext' fun b => ?_
  simp only [push_apply, compK, Finset.sum_mul, Finset.mul_sum]
  rw [Finset.sum_comm]
  exact Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun x _ => by ring

/-- The channel computed by a whole stack. -/
def chainK [DecidableEq α] (L : List (Kern α α)) : Kern α α := fun a => chain L (dirac a)

/-- A stack acts on input laws as the single channel `chainK L`: running a stack
is linear in the input law. -/
theorem chain_eq_push_chainK [DecidableEq α] (L : List (Kern α α)) (μ : Dist α) :
    chain L μ = push (chainK L) μ := by
  induction L generalizing μ with
  | nil =>
      have : chainK ([] : List (Kern α α)) = idK := rfl
      rw [this, push_idK, chain_nil]
  | cons K L ih =>
      have hK : chainK (K :: L) = compK K (chainK L) := by
        funext a
        simp only [chainK, compK, chain_cons, push_dirac]
        exact ih (K a)
      rw [chain_cons, ih, push_push, hK]

/-! ## 2. Budget functionals -/

/-- The total budget charged to a pair of stacks: the sum of the per-layer
budgets, layer by layer. -/
def budgetSum (B : Kern α α → Kern α α → ℚ) : List (Kern α α) → List (Kern α α) → ℚ
  | f :: F, p :: P => B f p + budgetSum B F P
  | _, _ => 0

@[simp] theorem budgetSum_cons (B : Kern α α → Kern α α → ℚ) (f p : Kern α α)
    (F P : List (Kern α α)) : budgetSum B (f :: F) (p :: P) = B f p + budgetSum B F P := rfl

@[simp] theorem budgetSum_nil (B : Kern α α → Kern α α → ℚ) (P : List (Kern α α)) :
    budgetSum B [] P = 0 := by cases P <;> rfl

/-- A per-layer budget functional is **sound** if, on every pair of stacks of
equal depth and from every input law, the joint damage never exceeds the sum of
the per-layer budgets. -/
def SoundBudget (B : Kern α α → Kern α α → ℚ) : Prop :=
  ∀ F P : List (Kern α α), F.length = P.length →
    ∀ μ : Dist α, tv (chain F μ) (chain P μ) ≤ budgetSum B F P

/-- The contextual hybrid cost is bounded by any budget dominating the
pointwise channel distance. -/
theorem hybridCost_le_budgetSum (B : Kern α α → Kern α α → ℚ)
    (hB : ∀ f p : Kern α α, ∀ a, tv (f a) (p a) ≤ B f p) :
    ∀ (F P : List (Kern α α)) (μ : Dist α), hybridCost F P μ ≤ budgetSum B F P := by
  intro F
  induction F with
  | nil => intro P μ; simp
  | cons f F ih =>
      intro P μ
      cases P with
      | nil => simp [hybridCost, budgetSum]
      | cons p P =>
          rw [hybridCost_cons, budgetSum_cons]
          have h1 : tv (push f μ) (push p μ) ≤ B f p :=
            tv_push_perturb_unif f p μ (hB f p)
          have h2 := ih P (push p μ)
          linarith

/-- **Sufficiency (heterogeneous depth-additivity).**  Any budget that dominates
the channel distance at *every* state is sound. -/
theorem budget_sound_of_dominates (B : Kern α α → Kern α α → ℚ)
    (hB : ∀ f p : Kern α α, ∀ a, tv (f a) (p a) ≤ B f p) : SoundBudget B := by
  intro F P hlen μ
  exact (chain_hybrid_bound F P hlen μ).trans (hybridCost_le_budgetSum B hB F P μ)

/-- **Necessity.**  A sound budget must dominate the channel distance at every
single state: test it on the depth-one stack fed with a Dirac input. -/
theorem dominates_of_budget_sound [DecidableEq α] (B : Kern α α → Kern α α → ℚ)
    (hB : SoundBudget B) (f p : Kern α α) (a : α) : tv (f a) (p a) ≤ B f p := by
  have h := hB [f] [p] rfl (dirac a)
  simpa [budgetSum] using h

/-- **Soundness is exactly uniform domination.** -/
theorem budget_sound_iff_dominates [DecidableEq α] (B : Kern α α → Kern α α → ℚ) :
    SoundBudget B ↔ ∀ f p : Kern α α, ∀ a, tv (f a) (p a) ≤ B f p :=
  ⟨fun h => dominates_of_budget_sound B h, budget_sound_of_dominates B⟩

/-! ## 3. The uniform budget is the least sound budget -/

/-- The uniform (worst-case over states) per-layer budget. -/
def uniformBudget [Nonempty α] (f p : Kern α α) : ℚ :=
  Finset.univ.sup' Finset.univ_nonempty fun a => tv (f a) (p a)

theorem le_uniformBudget [Nonempty α] (f p : Kern α α) (a : α) :
    tv (f a) (p a) ≤ uniformBudget f p :=
  Finset.le_sup' (fun a => tv (f a) (p a)) (Finset.mem_univ a)

/-- The uniform budget is attained at some state. -/
theorem exists_uniformBudget_eq [Nonempty α] (f p : Kern α α) :
    ∃ a, tv (f a) (p a) = uniformBudget f p := by
  obtain ⟨a, -, ha⟩ := Finset.exists_mem_eq_sup' (Finset.univ_nonempty (α := α))
    (fun a => tv (f a) (p a))
  exact ⟨a, ha.symm⟩

theorem uniformBudget_sound [Nonempty α] : SoundBudget (uniformBudget (α := α)) :=
  budget_sound_of_dominates _ le_uniformBudget

/-- **Uniform budgets are forced.**  A budget functional is sound if and only if
it dominates the worst-case per-layer perturbation, layer pair by layer pair. -/
theorem budget_sound_iff_uniform_le [DecidableEq α] [Nonempty α]
    (B : Kern α α → Kern α α → ℚ) :
    SoundBudget B ↔ ∀ f p : Kern α α, uniformBudget f p ≤ B f p := by
  rw [budget_sound_iff_dominates]
  constructor
  · intro h f p
    obtain ⟨a, ha⟩ := exists_uniformBudget_eq f p
    rw [← ha]; exact h f p a
  · intro h f p a
    exact (le_uniformBudget f p a).trans (h f p)

/-- Depth-additivity of the uniform budget in closed form: a stack of `n` layers,
each `ε`-close in the worst case, does at most `n · ε` damage. -/
theorem budgetSum_le_length_mul [Nonempty α] (ε : ℚ) :
    ∀ F P : List (Kern α α), F.length = P.length →
      (∀ q ∈ F.zip P, uniformBudget q.1 q.2 ≤ ε) →
      budgetSum uniformBudget F P ≤ F.length * ε := by
  intro F
  induction F with
  | nil => intro P _ _; simp
  | cons f F ih =>
      intro P hlen h
      cases P with
      | nil => simp at hlen
      | cons p P =>
          have h1 : uniformBudget f p ≤ ε := h (f, p) (by simp)
          have h2 := ih P (by simpa using hlen) (fun q hq => h q (by simp [hq]))
          rw [budgetSum_cons]
          push_cast [List.length_cons]
          linarith

end Catalog.Probability.NET59.ProbeBudgets