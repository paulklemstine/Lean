/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The Collatz Map: Dynamics, a Min-Plus Stopping-Time Recurrence, and the Logic of Undecidability

The Collatz (or `3n+1`) map sends an even number `n` to `n/2` and an odd number `n`
to `3n+1`. The Collatz conjecture asserts that iterating this map from any positive
integer eventually reaches `1`. Despite enormous numerical verification the statement
remains open, and it is a leading candidate for a concrete arithmetic sentence that
might be *independent* of strong base theories.

This file develops the elementary dynamical theory of the map rigorously, isolates the
exact logical shape of the conjecture, and exhibits a **min-plus (tropical) recurrence**
governing the total stopping time. The tropical viewpoint is natural: the stopping time
`σ` obeys a Bellman-type equation

  `σ(n) = ⨁_{m = T(n)} (1 ⊗ σ(m))`

which in the min-plus semiring `(ℕ ∪ {∞}, min, +)` is exactly `σ(1) = 0` and, for
`n ≠ 1`, `σ(n) = 1 + σ(T n)` — a shortest-path / dynamic-programming law on the Collatz
orbit graph.

## Main definitions

* `collatz`         — the Collatz map `T`.
* `Reaches n`       — the orbit of `n` reaches `1`.
* `Collatz`         — the Collatz conjecture for positive integers.
* `ReachesWithin`   — the decidable, bounded halting predicate.
* `stoppingTime`    — the total stopping time of a halting orbit.

## Main results

* `collatz_iterate_pow_two` — powers of two reach `1` in exactly their exponent of steps.
* `reaches_of_collatz` / `collatz_of_reaches` — the halting predicate is invariant along
  the orbit; combined into `reaches_iff_collatz`.
* `not_collatz_iff_counterexample` — the negation of the conjecture is exactly the
  existence of a positive counterexample (the `Σ`-shape of a refutation).
* `reaches_iff_exists_bound` — the (a priori `Π₁`) halting predicate is the countable
  union of decidable bounded predicates: this is the `Σ`-structure underlying any
  search-based verification.
* `stoppingTime_rec` — the min-plus / Bellman recurrence for the stopping time.

## Lab Notes

`-- !-- Lab Notes -- !--`
* **Hypothesis.** The Collatz predicate `Reaches` has a clean recursive (min-plus)
  structure that fully determines the total stopping time, and the conjecture's
  logical content is precisely a `Π₂` sentence whose refutation is a single `Σ₁`
  witness.
* **Experiment.** Formalize the map, the orbit-invariance of halting, the exact
  stopping time of powers of two, the decidable bounded halting predicate, and the
  stopping-time recurrence. Verify concrete long orbits (`7`, `27`).
* **Analysis.** Every elementary structural claim survives. The genuinely open content
  is exactly `Collatz`; everything provable here reduces `Collatz` to a countable
  disjunction of decidable facts, exposing why the conjecture is *verifiable but not
  obviously decidable*: no uniform bound on the search is available.
* **Critique.** The speculative `Con(PA)`-equivalence is NOT asserted as a theorem — it
  is unproven and is recorded only as a future direction. All theorems below are
  unconditional and sorry-free; the only `Prop` left open (`Collatz`) is never assumed.
* **Synthesis.** The min-plus recurrence `stoppingTime_rec` unifies the dynamics with
  tropical shortest-path theory, and `reaches_iff_exists_bound` pins down the search
  structure that any independence argument must confront.
-/

namespace CollatzTropical

/-- The Collatz map `T`: halve an even number, otherwise `3n+1`. -/
def collatz (n : ℕ) : ℕ := if n % 2 = 0 then n / 2 else 3 * n + 1

/-- The orbit of `n` reaches `1`. -/
def Reaches (n : ℕ) : Prop := ∃ k, collatz^[k] n = 1

/-- The Collatz conjecture: every positive integer reaches `1`. -/
def Collatz : Prop := ∀ n, 0 < n → Reaches n

/-! ### Basic evaluation lemmas -/

lemma collatz_even {n : ℕ} (h : n % 2 = 0) : collatz n = n / 2 := by
  unfold collatz; rw [if_pos h]

lemma collatz_odd {n : ℕ} (h : n % 2 = 1) : collatz n = 3 * n + 1 := by
  unfold collatz; rw [if_neg (by omega)]

lemma collatz_two_mul (n : ℕ) : collatz (2 * n) = n := by
  unfold collatz; rw [if_pos (by omega), Nat.mul_div_cancel_left n (by norm_num)]

lemma collatz_one : collatz 1 = 4 := by decide

/-- The unique cycle through `1`: `1 → 4 → 2 → 1`. -/
lemma collatz_cycle_one : collatz^[3] 1 = 1 := by decide

/-! ### Orbit invariance of the halting predicate -/

lemma reaches_one : Reaches 1 := ⟨0, rfl⟩

/-- Halting is preserved by pulling back one step along the map. -/
lemma reaches_of_collatz {n : ℕ} (h : Reaches (collatz n)) : Reaches n := by
  obtain ⟨k, hk⟩ := h; exact ⟨k + 1, by rw [Function.iterate_succ_apply]; exact hk⟩

/-- Halting is preserved by pushing forward one step (away from the fixed point `1`). -/
lemma collatz_of_reaches {n : ℕ} (hn : n ≠ 1) (h : Reaches n) : Reaches (collatz n) := by
  obtain ⟨k, hk⟩ := h
  cases k with
  | zero => simp only [Function.iterate_zero_apply] at hk; exact absurd hk hn
  | succ k' => exact ⟨k', by rw [Function.iterate_succ_apply] at hk; exact hk⟩

/-- For `n ≠ 1`, the orbit of `n` reaches `1` iff the orbit of `T n` does. -/
lemma reaches_iff_collatz {n : ℕ} (hn : n ≠ 1) : Reaches n ↔ Reaches (collatz n) :=
  ⟨collatz_of_reaches hn, reaches_of_collatz⟩

/-! ### Powers of two: exact stopping time -/

/-- A power of two reaches `1` in exactly its exponent many steps. -/
lemma collatz_iterate_pow_two (m : ℕ) : collatz^[m] (2 ^ m) = 1 := by
  induction m with
  | zero => rfl
  | succ m ih =>
    have h2 : (2 : ℕ) ^ (m + 1) = 2 * 2 ^ m := by ring
    rw [Function.iterate_succ_apply, h2, collatz_two_mul]; exact ih

lemma reaches_pow_two (m : ℕ) : Reaches (2 ^ m) := ⟨m, collatz_iterate_pow_two m⟩

/-! ### Concrete nontrivial orbits -/

lemma reaches_seven : Reaches 7 := ⟨16, by native_decide⟩

lemma reaches_twentyseven : Reaches 27 := ⟨111, by native_decide⟩

/-! ### The logical shape of the conjecture -/

/-- A refutation of the conjecture is exactly a single positive counterexample. -/
lemma not_collatz_iff_counterexample : ¬ Collatz ↔ ∃ n, 0 < n ∧ ¬ Reaches n := by
  unfold Collatz; push_neg; exact Iff.rfl

/-- The decidable bounded halting predicate: reaches `1` within `b` steps. -/
def ReachesWithin (b n : ℕ) : Prop := ∃ k ≤ b, collatz^[k] n = 1

instance (b n : ℕ) : Decidable (ReachesWithin b n) := by
  unfold ReachesWithin; infer_instance

/-- The (a priori unbounded) halting predicate is the countable union of the decidable
bounded predicates. This is the search structure underlying every numerical
verification: `Reaches` is `Σ₁`, refutation of `Collatz` is the failure of every bound. -/
lemma reaches_iff_exists_bound {n : ℕ} : Reaches n ↔ ∃ b, ReachesWithin b n := by
  constructor
  · rintro ⟨k, hk⟩; exact ⟨k, k, le_refl k, hk⟩
  · rintro ⟨b, k, _, hk⟩; exact ⟨k, hk⟩

/-! ### The min-plus (tropical) stopping-time recurrence -/

/-- The total stopping time of a halting orbit: the least number of steps to reach `1`. -/
def stoppingTime {n : ℕ} (h : Reaches n) : ℕ := Nat.find h

lemma stoppingTime_spec {n : ℕ} (h : Reaches n) :
    collatz^[stoppingTime h] n = 1 := by
  unfold stoppingTime; exact Nat.find_spec h

lemma stoppingTime_one : stoppingTime reaches_one = 0 := by
  unfold stoppingTime; exact (Nat.find_eq_zero reaches_one).mpr rfl

/-- **Min-plus / Bellman recurrence.** Away from the fixed point, the stopping time is
one plus the stopping time of the image: in the tropical semiring `(ℕ, min, +)` this is
`σ(n) = 1 ⊗ σ(T n)`, the shortest-path law along the Collatz orbit. -/
lemma stoppingTime_rec {n : ℕ} (hn : n ≠ 1) (h : Reaches n) :
    stoppingTime h = stoppingTime (collatz_of_reaches hn h) + 1 := by
  unfold stoppingTime
  rw [Nat.find_eq_iff]
  refine ⟨?_, ?_⟩
  · rw [Function.iterate_succ_apply]; exact Nat.find_spec (collatz_of_reaches hn h)
  · intro j hj hcontra
    cases j with
    | zero => exact hn (by simpa using hcontra)
    | succ i =>
      rw [Function.iterate_succ_apply] at hcontra
      have hlt : i < Nat.find (collatz_of_reaches hn h) := by omega
      exact Nat.find_min (collatz_of_reaches hn h) hlt hcontra

end CollatzTropical