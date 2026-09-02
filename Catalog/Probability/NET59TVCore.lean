import Mathlib

/-!
# NET-59 core: finite distributions, channels and total variation

This file sets up the small amount of finite probability needed to state and
prove the NET-59 *epistasis* results of
`Probability.NET59HybridEpistasis` and `Probability.NET59NonIdentifiability`.

The experimental setting of NET-59 is: a stack of `24` transformer layers, each
of which can be *pruned* (its attention is restricted to an oracle top-`k` set
of keys).  Measuring the damage caused by pruning **one** layer at a time gives
a remarkably flat profile; the question is what such a profile can possibly say
about the damage caused by pruning **several** layers at once.

We model a layer as a *Markov channel* `Kern α β` on finite state spaces and the
damage as total variation distance between the output law of the intact stack
and the output law of the pruned stack.  Everything is over `ℚ`, so all
examples are exactly computable.

Main results here:

* `tv_triangle`, `tv_le_one` — total variation is a metric bounded by `1`;
* `tv_push_le` — the **data-processing inequality**: post-processing by a common
  channel can only decrease total variation;
* `tv_push_perturb` — the **perturbation inequality**: replacing a channel by
  another one moves the pushforward by at most the `μ`-average of the pointwise
  channel distances;
* `tv_push_context_shift` — the **context-shift inequality**
  `tv (f∗μ) (p∗μ) ≤ tv (f∗ν) (p∗ν) + 2 · tv μ ν`, the quantitative statement
  that a layer's measured damage depends on the upstream state only through the
  drift of that state.  This is the seed of every epistasis bound below.
-/

namespace Catalog.Probability.NET59

open Finset

/-! ## 1. Finite rational distributions -/

/-- A probability distribution on a finite type, with rational weights. -/
structure Dist (α : Type*) [Fintype α] where
  /-- the weight function -/
  p : α → ℚ
  nonneg : ∀ a, 0 ≤ p a
  sum_one : ∑ a, p a = 1

variable {α β γ : Type*} [Fintype α] [Fintype β] [Fintype γ]

theorem Dist.ext' {μ ν : Dist α} (h : ∀ a, μ.p a = ν.p a) : μ = ν := by
  cases μ; cases ν; congr 1; funext a; exact h a

theorem Dist.p_le_one (μ : Dist α) (a : α) : μ.p a ≤ 1 := by
  classical
  have h := Finset.single_le_sum (f := μ.p) (fun i _ => μ.nonneg i) (Finset.mem_univ a)
  rwa [μ.sum_one] at h

/-- A Markov channel from `α` to `β`: a distribution on `β` for each input. -/
def Kern (α β : Type*) [Fintype α] [Fintype β] := α → Dist β

/-- Pushforward of a distribution through a channel. -/
def push (K : Kern α β) (μ : Dist α) : Dist β where
  p b := ∑ a, μ.p a * (K a).p b
  nonneg b := Finset.sum_nonneg fun a _ => mul_nonneg (μ.nonneg a) ((K a).nonneg b)
  sum_one := by
    rw [Finset.sum_comm]
    have : ∀ a : α, ∑ b, μ.p a * (K a).p b = μ.p a := by
      intro a; rw [← Finset.mul_sum, (K a).sum_one, mul_one]
    rw [Finset.sum_congr rfl fun a _ => this a, μ.sum_one]

@[simp] theorem push_apply (K : Kern α β) (μ : Dist α) (b : β) :
    (push K μ).p b = ∑ a, μ.p a * (K a).p b := rfl

/-! ## 2. Total variation distance -/

/-- Total variation distance between two finite rational distributions. -/
def tv (μ ν : Dist α) : ℚ := (∑ a, |μ.p a - ν.p a|) / 2

theorem tv_nonneg (μ ν : Dist α) : 0 ≤ tv μ ν := by
  unfold tv
  have : 0 ≤ ∑ a, |μ.p a - ν.p a| := Finset.sum_nonneg fun a _ => abs_nonneg _
  linarith

@[simp] theorem tv_self (μ : Dist α) : tv μ μ = 0 := by simp [tv]

theorem tv_comm (μ ν : Dist α) : tv μ ν = tv ν μ := by
  unfold tv
  congr 1
  exact Finset.sum_congr rfl fun a _ => abs_sub_comm _ _

theorem tv_triangle (μ ν ρ : Dist α) : tv μ ρ ≤ tv μ ν + tv ν ρ := by
  unfold tv
  have h : ∑ a, |μ.p a - ρ.p a| ≤ ∑ a, (|μ.p a - ν.p a| + |ν.p a - ρ.p a|) :=
    Finset.sum_le_sum fun a _ => abs_sub_le _ _ _
  rw [Finset.sum_add_distrib] at h
  linarith

theorem tv_le_one (μ ν : Dist α) : tv μ ν ≤ 1 := by
  unfold tv
  have h : ∑ a, |μ.p a - ν.p a| ≤ ∑ a, (μ.p a + ν.p a) := by
    refine Finset.sum_le_sum fun a _ => ?_
    rcases abs_cases (μ.p a - ν.p a) with ⟨he, _⟩ | ⟨he, _⟩ <;> rw [he] <;>
      [linarith [ν.nonneg a]; linarith [μ.nonneg a]]
  rw [Finset.sum_add_distrib, μ.sum_one, ν.sum_one] at h
  linarith

/-- If two distributions differ nowhere in total variation they are equal. -/
theorem tv_eq_zero_iff (μ ν : Dist α) : tv μ ν = 0 ↔ μ = ν := by
  constructor
  · intro h
    have hs : ∑ a, |μ.p a - ν.p a| = 0 := by unfold tv at h; linarith
    have := (Finset.sum_eq_zero_iff_of_nonneg (fun a _ => abs_nonneg (μ.p a - ν.p a))).1 hs
    exact Dist.ext' fun a => by
      have := this a (Finset.mem_univ a)
      have := abs_eq_zero.1 this
      linarith
  · rintro rfl; simp

/-! ## 3. Data processing and perturbation -/

/-- **Data-processing inequality.**  Pushing two laws through the *same* channel
cannot increase their total variation distance: a layer can only forget. -/
theorem tv_push_le (K : Kern α β) (μ ν : Dist α) : tv (push K μ) (push K ν) ≤ tv μ ν := by
  have key : ∑ b, |(push K μ).p b - (push K ν).p b| ≤ ∑ a, |μ.p a - ν.p a| := by
    have h1 : ∀ b : β, |(push K μ).p b - (push K ν).p b|
        ≤ ∑ a, |μ.p a - ν.p a| * (K a).p b := by
      intro b
      have hb : (push K μ).p b - (push K ν).p b = ∑ a, (μ.p a - ν.p a) * (K a).p b := by
        simp only [push_apply, ← Finset.sum_sub_distrib, sub_mul]
      rw [hb]
      refine (Finset.abs_sum_le_sum_abs _ _).trans (Finset.sum_le_sum fun a _ => ?_)
      rw [abs_mul, abs_of_nonneg ((K a).nonneg b)]
    calc ∑ b, |(push K μ).p b - (push K ν).p b|
        ≤ ∑ b, ∑ a, |μ.p a - ν.p a| * (K a).p b := Finset.sum_le_sum fun b _ => h1 b
      _ = ∑ a, |μ.p a - ν.p a| * ∑ b, (K a).p b := by
            rw [Finset.sum_comm]
            exact Finset.sum_congr rfl fun a _ => (Finset.mul_sum _ _ _).symm
      _ = ∑ a, |μ.p a - ν.p a| := by
            exact Finset.sum_congr rfl fun a _ => by rw [(K a).sum_one, mul_one]
  unfold tv; linarith

/-- **Perturbation inequality.**  Replacing a channel `f` by a channel `p` moves
the pushforward of `μ` by at most the `μ`-average of the pointwise distances. -/
theorem tv_push_perturb (f p : Kern α β) (μ : Dist α) :
    tv (push f μ) (push p μ) ≤ ∑ a, μ.p a * tv (f a) (p a) := by
  have key : ∑ b, |(push f μ).p b - (push p μ).p b|
      ≤ ∑ a, μ.p a * ∑ b, |(f a).p b - (p a).p b| := by
    have h1 : ∀ b : β, |(push f μ).p b - (push p μ).p b|
        ≤ ∑ a, μ.p a * |(f a).p b - (p a).p b| := by
      intro b
      have hb : (push f μ).p b - (push p μ).p b
          = ∑ a, μ.p a * ((f a).p b - (p a).p b) := by
        simp only [push_apply, ← Finset.sum_sub_distrib, mul_sub]
      rw [hb]
      refine (Finset.abs_sum_le_sum_abs _ _).trans (Finset.sum_le_sum fun a _ => ?_)
      rw [abs_mul, abs_of_nonneg (μ.nonneg a)]
    calc ∑ b, |(push f μ).p b - (push p μ).p b|
        ≤ ∑ b, ∑ a, μ.p a * |(f a).p b - (p a).p b| := Finset.sum_le_sum fun b _ => h1 b
      _ = ∑ a, μ.p a * ∑ b, |(f a).p b - (p a).p b| := by
            rw [Finset.sum_comm]
            exact Finset.sum_congr rfl fun a _ => (Finset.mul_sum _ _ _).symm
  have hrw : ∑ a, μ.p a * tv (f a) (p a)
      = (∑ a, μ.p a * ∑ b, |(f a).p b - (p a).p b|) / 2 := by
    rw [Finset.sum_div]
    exact Finset.sum_congr rfl fun a _ => by unfold tv; ring
  rw [hrw]
  unfold tv
  linarith

/-- Uniform version of the perturbation inequality: if the two channels are
`ε`-close at *every* input, their pushforwards are `ε`-close. -/
theorem tv_push_perturb_unif {ε : ℚ} (f p : Kern α β) (μ : Dist α)
    (h : ∀ a, tv (f a) (p a) ≤ ε) : tv (push f μ) (push p μ) ≤ ε := by
  refine (tv_push_perturb f p μ).trans ?_
  calc ∑ a, μ.p a * tv (f a) (p a) ≤ ∑ a, μ.p a * ε :=
        Finset.sum_le_sum fun a _ => by
          exact mul_le_mul_of_nonneg_left (h a) (μ.nonneg a)
    _ = ε := by rw [← Finset.sum_mul, μ.sum_one, one_mul]

/-- **Context-shift inequality.**  The damage a layer does at upstream state `μ`
differs from the damage it does at upstream state `ν` by at most `2 · tv μ ν`.

This is the exact quantitative form of the NET-59 epistasis puzzle: a *solo*
measurement evaluates each layer at the intact upstream state, and the only
thing that can make the joint damage exceed the solo prediction is upstream
drift. -/
theorem tv_push_context_shift (f p : Kern α β) (μ ν : Dist α) :
    tv (push f μ) (push p μ) ≤ tv (push f ν) (push p ν) + 2 * tv μ ν := by
  have h1 : tv (push f μ) (push p μ)
      ≤ tv (push f μ) (push f ν) + tv (push f ν) (push p μ) :=
    tv_triangle _ _ _
  have h2 : tv (push f ν) (push p μ)
      ≤ tv (push f ν) (push p ν) + tv (push p ν) (push p μ) :=
    tv_triangle _ _ _
  have h3 : tv (push f μ) (push f ν) ≤ tv μ ν := tv_push_le f μ ν
  have h4 : tv (push p ν) (push p μ) ≤ tv ν μ := tv_push_le p ν μ
  rw [tv_comm ν μ] at h4
  linarith

/-! ## 4. Two standard channels -/

/-- The identity channel: `dirac a` on input `a`. -/
def dirac [DecidableEq α] (a : α) : Dist α where
  p x := if x = a then 1 else 0
  nonneg x := by split <;> norm_num
  sum_one := by simp

/-- The identity (lossless) channel. -/
def idK [DecidableEq α] : Kern α α := fun a => dirac a

/-- The constant (totally forgetful) channel with output law `c`. -/
def constK (c : Dist β) : Kern α β := fun _ => c

@[simp] theorem push_idK [DecidableEq α] (μ : Dist α) : push (idK : Kern α α) μ = μ := by
  refine Dist.ext' fun b => ?_
  simp only [push_apply, idK, dirac]
  rw [Finset.sum_eq_single b] <;> simp +contextual [eq_comm]

@[simp] theorem push_constK (c : Dist β) (μ : Dist α) : push (constK c) μ = c := by
  refine Dist.ext' fun b => ?_
  simp only [push_apply, constK]
  rw [← Finset.sum_mul, μ.sum_one, one_mul]

end Catalog.Probability.NET59