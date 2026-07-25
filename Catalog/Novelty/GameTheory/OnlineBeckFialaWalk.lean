/-
# The Self-Balancing Walk: Online Prefix Discrepancy in One Dimension

The **Beck–Fiala** line of research studies *discrepancy*: given vectors arriving
one at a time, choose a sign `±1` for each so that every *prefix* of the resulting
signed sum stays small.  The recent work *"Online Beck–Fiala Down to Logarithmic
Sparsity"* builds its high-dimensional algorithm out of a one-dimensional
primitive — a **compactly supported, online, self-balancing walk**.  This file
formalizes that primitive in full.

Concretely, real increments `a 0, a 1, a 2, …` with `|a t| ≤ 1` arrive online.  At
step `t` we must commit to a sign `ε t ∈ {+1, -1}` *depending only on the history*
and on the current increment, forming the running sum
`S t = ∑_{s < t} ε s · a s`.  The greedy rule "push the running sum back toward
`0`" keeps the walk trapped in the compact interval `[-1, 1]` **forever**,
independently of how many increments arrive.

Main results:

* `walk_abs_le_one` — the greedy walk satisfies `|S t| ≤ 1` for every `t`
  (the compact-support / prefix-discrepancy bound).
* `onlineSign_mem` — the committed values really are signs, `ε t = 1 ∨ ε t = -1`.
* `walk_eq_sum` — the greedy walk equals the online signed prefix sum
  `∑_{s < t} ε s · a s`, certifying that the bound is about a genuine `±1` coloring.
* `prefix_discrepancy_le_one` — combining the two: the online signed prefix sums
  all have absolute value `≤ 1`.
* `exists_signs_prefix_le_one` — hence a sign sequence keeping every prefix within
  `[-1, 1]` *exists* (the offline consequence).
* `online_prefix_lower_bound` — `1` is optimal: on the all-ones stream every online
  strategy already incurs prefix discrepancy `≥ 1` at the very first step.
* `walk_abs_le` — the scaled version: increments bounded by `c ≥ 0` give
  `|S t| ≤ c`.
-/
import Mathlib

namespace OnlineBeckFiala

open Finset

/-- The **greedy self-balancing walk** driven by the increment stream `a`.

`walk a t` is the running sum after processing `a 0, …, a (t-1)`.  At each step we
add `|a t|` if the current sum is `≤ 0`, and subtract `|a t|` otherwise — i.e. we
choose the sign that pushes the running sum back toward `0`.  The step depends only
on the past (`walk a t`) and the current increment `a t`, so the rule is *online*. -/
noncomputable def walk (a : ℕ → ℝ) : ℕ → ℝ
  | 0 => 0
  | (t + 1) => walk a t + (if walk a t ≤ 0 then |a t| else -|a t|)

@[simp] theorem walk_zero (a : ℕ → ℝ) : walk a 0 = 0 := rfl

theorem walk_succ (a : ℕ → ℝ) (t : ℕ) :
    walk a (t + 1) = walk a t + (if walk a t ≤ 0 then |a t| else -|a t|) := rfl

/-- The **online sign** committed to at step `t`: it multiplies the true increment
`a t`, and is `+1` or `-1` depending on the greedy rule and the sign of `a t`. -/
noncomputable def onlineSign (a : ℕ → ℝ) (t : ℕ) : ℝ :=
  (if walk a t ≤ 0 then (1 : ℝ) else -1) * (if 0 ≤ a t then (1 : ℝ) else -1)

/-- The committed values are genuine signs. -/
theorem onlineSign_mem (a : ℕ → ℝ) (t : ℕ) :
    onlineSign a t = 1 ∨ onlineSign a t = -1 := by
  unfold onlineSign
  by_cases h1 : walk a t ≤ 0 <;> by_cases h2 : 0 ≤ a t <;>
    simp [h1, h2]

/-- The signed increment `ε t · a t` equals the greedy step `±|a t|`. -/
theorem onlineSign_mul (a : ℕ → ℝ) (t : ℕ) :
    onlineSign a t * a t = (if walk a t ≤ 0 then |a t| else -|a t|) := by
  unfold onlineSign
  by_cases h1 : walk a t ≤ 0 <;> by_cases h2 : 0 ≤ a t
  · rw [if_pos h1, if_pos h2, if_pos h1, abs_of_nonneg h2]; ring
  · rw [if_pos h1, if_neg h2, if_pos h1, abs_of_neg (not_le.mp h2)]; ring
  · rw [if_neg h1, if_pos h2, if_neg h1, abs_of_nonneg h2]; ring
  · rw [if_neg h1, if_neg h2, if_neg h1, abs_of_neg (not_le.mp h2)]; ring

/-- **Full increment use.**  Each step of the walk moves by exactly `|a t|`, so the
committed decision is genuinely a `±1` sign applied to the whole increment (never a
fractional shrink). -/
theorem walk_step_bound (a : ℕ → ℝ) (t : ℕ) :
    |walk a (t + 1) - walk a t| = |a t| := by
  rw [walk_succ]
  by_cases h : walk a t ≤ 0
  · simp [h, abs_abs]
  · simp [h, abs_neg, abs_abs]

/-- The greedy walk is exactly the online signed prefix sum
`S t = ∑_{s < t} ε s · a s`. -/
theorem walk_eq_sum (a : ℕ → ℝ) (t : ℕ) :
    walk a t = ∑ s ∈ range t, onlineSign a s * a s := by
  induction t with
  | zero => simp
  | succ n ih =>
    rw [sum_range_succ, ← ih, onlineSign_mul, walk_succ]

/-- **Compact support / prefix bound.**  If every increment satisfies `|a t| ≤ 1`,
the greedy self-balancing walk never leaves `[-1, 1]`. -/
theorem walk_abs_le_one (a : ℕ → ℝ) (ha : ∀ s, |a s| ≤ 1) :
    ∀ t, |walk a t| ≤ 1 := by
  intro t
  induction t with
  | zero => simp
  | succ n ih =>
    rw [walk_succ]
    have hb : |a n| ≤ 1 := ha n
    have hpos : (0 : ℝ) ≤ |a n| := abs_nonneg _
    rcases abs_le.mp ih with ⟨hlo, hhi⟩
    by_cases h : walk a n ≤ 0
    · simp only [h, if_true]
      rw [abs_le]
      constructor
      · linarith
      · linarith
    · simp only [h, if_false]
      push_neg at h
      rw [abs_le]
      constructor
      · linarith
      · linarith

/-- **Online prefix discrepancy `≤ 1`.**  The online signed prefix sums all lie in
`[-1, 1]`.  This is the one-dimensional online Beck–Fiala bound. -/
theorem prefix_discrepancy_le_one (a : ℕ → ℝ) (ha : ∀ s, |a s| ≤ 1) (t : ℕ) :
    |∑ s ∈ range t, onlineSign a s * a s| ≤ 1 := by
  rw [← walk_eq_sum]
  exact walk_abs_le_one a ha t

/-- **Offline existence.**  For any stream of increments bounded by `1`, there is a
sign sequence keeping every prefix sum within `[-1, 1]`. -/
theorem exists_signs_prefix_le_one (a : ℕ → ℝ) (ha : ∀ s, |a s| ≤ 1) :
    ∃ ε : ℕ → ℝ, (∀ t, ε t = 1 ∨ ε t = -1) ∧
      ∀ t, |∑ s ∈ range t, ε s * a s| ≤ 1 := by
  refine ⟨onlineSign a, onlineSign_mem a, ?_⟩
  exact prefix_discrepancy_le_one a ha

/-- **Optimality of the constant `1`.**  No online (indeed no) strategy can beat
prefix discrepancy `1`: on the all-ones stream every sign sequence already has a
prefix of absolute value `≥ 1`, namely the first one. -/
theorem online_prefix_lower_bound (σ : ℕ → ℝ) (hσ : ∀ t, σ t = 1 ∨ σ t = -1) :
    ∃ t, (1 : ℝ) ≤ |∑ s ∈ range t, σ s * (1 : ℝ)| := by
  refine ⟨1, ?_⟩
  rw [sum_range_one]
  rcases hσ 0 with h | h <;> simp [h]

/-- **Scaled compact support.**  If every increment satisfies `|a t| ≤ c` with
`0 ≤ c`, the greedy walk stays in `[-c, c]`. -/
theorem walk_abs_le (a : ℕ → ℝ) (c : ℝ) (hc : 0 ≤ c) (ha : ∀ s, |a s| ≤ c) :
    ∀ t, |walk a t| ≤ c := by
  intro t
  induction t with
  | zero => simpa using hc
  | succ n ih =>
    rw [walk_succ]
    have hb : |a n| ≤ c := ha n
    have hpos : (0 : ℝ) ≤ |a n| := abs_nonneg _
    rcases abs_le.mp ih with ⟨hlo, hhi⟩
    by_cases h : walk a n ≤ 0
    · simp only [h, if_true]; rw [abs_le]; constructor <;> linarith
    · simp only [h, if_false]; push_neg at h; rw [abs_le]; constructor <;> linarith

end OnlineBeckFiala