/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Transition Endomorphisms and Rank Monotonicity

This is a minimal, standalone finite-dimensional linear-algebra file built around
the *transition endomorphism* `transEndo f i j`, the ordered composition

  `transEndo f i j = f (j-1) ∘ f (j-2) ∘ ⋯ ∘ f i`

of a sequence `f : ℕ → V →ₗ[K] V` of endomorphisms over the index window `[i, j)`.
It equals the identity when `j ≤ i`.

Rather than re-deriving a Sylvester rank inequality from scratch, we *reuse*
Mathlib's rank submultiplicativity (`LinearMap.rank_comp_le_left/right`) and
combine it with a combinatorial concatenation ("Chapman–Kolmogorov") law for
`transEndo`. The payoff is a clean structural statement: along any nested window
`i ≤ j ≤ k`, the rank of the transition map is monotone non-increasing, and for a
constant sequence the transition map is exactly an iterate `g ^ (j - i)`.

## Main results

* `transEndo_comp`     : concatenation law `transEndo f i k =
                          transEndo f j k ∘ transEndo f i j` for `i ≤ j ≤ k`.
* `rank_transEndo_le_left` / `rank_transEndo_le_right` : rank submultiplicativity
                          along a nested window.
* `rank_transEndo_succ_le` / `rank_transEndo_antitone` : the rank sequence
                          `j ↦ rank (transEndo f i j)` is non-increasing.
* `transEndo_const`    : the transition map of a constant sequence is an iterate.
* `rank_pow_succ_le`   : consequently `rank (g ^ (n+1)) ≤ rank (g ^ n)`.
-/
import Mathlib

namespace Catalog.Algebra.TransEndo

open LinearMap Module

variable {K V : Type*} [Field K] [AddCommGroup V] [Module K V]

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): The ordered composition of a window of endomorphisms
--   should satisfy a Chapman–Kolmogorov concatenation law, and as a corollary the
--   rank of the transition map should be monotone non-increasing as the window grows.
-- Experiment (Experimenter): define `transEndo` by structural recursion on the
--   upper index and prove the concatenation law by induction on `k`, then derive
--   rank monotonicity from Mathlib's `rank_comp_le_*`.
-- !-- End Lab Notes -- !--

/-- The transition endomorphism `transEndo f i j = f (j-1) ∘ ⋯ ∘ f i`, the ordered
composition of `f i, …, f (j-1)`. It equals the identity when `j ≤ i`. -/
def transEndo (f : ℕ → V →ₗ[K] V) (i : ℕ) : ℕ → V →ₗ[K] V
  | 0 => LinearMap.id
  | (j + 1) => if i ≤ j then (f j).comp (transEndo f i j) else LinearMap.id

@[simp] lemma transEndo_zero (f : ℕ → V →ₗ[K] V) (i : ℕ) :
    transEndo f i 0 = LinearMap.id := rfl

lemma transEndo_succ_of_le (f : ℕ → V →ₗ[K] V) {i j : ℕ} (h : i ≤ j) :
    transEndo f i (j + 1) = (f j).comp (transEndo f i j) := by
  simp [transEndo, h]

lemma transEndo_eq_id_of_le (f : ℕ → V →ₗ[K] V) {i j : ℕ} (h : j ≤ i) :
    transEndo f i j = LinearMap.id := by
  cases j with
  | zero => rfl
  | succ j =>
    have : ¬ i ≤ j := by omega
    simp [transEndo, this]

lemma transEndo_self (f : ℕ → V →ₗ[K] V) (i : ℕ) :
    transEndo f i i = LinearMap.id :=
  transEndo_eq_id_of_le f le_rfl

/-- Chapman–Kolmogorov concatenation law: composing the transition over `[i, j)`
with the transition over `[j, k)` gives the transition over `[i, k)`. -/
theorem transEndo_comp (f : ℕ → V →ₗ[K] V) {i j k : ℕ} (hij : i ≤ j) (hjk : j ≤ k) :
    transEndo f i k = (transEndo f j k).comp (transEndo f i j) := by
  induction' k with k ih generalizing i j;
  · aesop;
  · by_cases hjk' : j ≤ k;
    · rw [ transEndo_succ_of_le f ( by linarith ), transEndo_succ_of_le f ( by linarith ) ];
      rw [ ih hij hjk', LinearMap.comp_assoc ];
    · simp_all +decide [ show j = k + 1 by linarith ];
      simp +decide [ transEndo_self ]

/-- Rank submultiplicativity along a nested window (outer factor). -/
theorem rank_transEndo_le_left (f : ℕ → V →ₗ[K] V) {i j k : ℕ}
    (hij : i ≤ j) (hjk : j ≤ k) :
    (transEndo f i k).rank ≤ (transEndo f j k).rank := by
  rw [transEndo_comp f hij hjk]; exact rank_comp_le_left _ _

/-- Rank submultiplicativity along a nested window (inner factor). -/
theorem rank_transEndo_le_right (f : ℕ → V →ₗ[K] V) {i j k : ℕ}
    (hij : i ≤ j) (hjk : j ≤ k) :
    (transEndo f i k).rank ≤ (transEndo f i j).rank := by
  rw [transEndo_comp f hij hjk]; exact rank_comp_le_right _ _

/-- One-step rank decrease: extending the window by one index cannot increase rank. -/
theorem rank_transEndo_succ_le (f : ℕ → V →ₗ[K] V) {i j : ℕ} (h : i ≤ j) :
    (transEndo f i (j + 1)).rank ≤ (transEndo f i j).rank :=
  rank_transEndo_le_right f h (Nat.le_succ j)

/-- The rank sequence `j ↦ rank (transEndo f i j)` is non-increasing. -/
theorem rank_transEndo_antitone (f : ℕ → V →ₗ[K] V) {i j k : ℕ}
    (hij : i ≤ j) (hjk : j ≤ k) :
    (transEndo f i k).rank ≤ (transEndo f i j).rank :=
  rank_transEndo_le_right f hij hjk

/-- For a constant sequence `fun _ => g`, the transition map is exactly the iterate
`g ^ (j - i)`. -/
theorem transEndo_const (g : V →ₗ[K] V) {i j : ℕ} (h : i ≤ j) :
    transEndo (fun _ => g) i j = g ^ (j - i) := by
  induction' h with j hj ih;
  · simp +decide [ pow_zero, transEndo_self ];
    rfl;
  · rw [ Nat.succ_sub hj, pow_succ', ← ih, transEndo_succ_of_le ];
    · rfl;
    · exact hj

/-- Iterating an endomorphism cannot increase rank: `rank (g ^ (n+1)) ≤ rank (g ^ n)`. -/
theorem rank_pow_succ_le (g : V →ₗ[K] V) (n : ℕ) :
    (g ^ (n + 1)).rank ≤ (g ^ n).rank := by
  convert LinearMap.rank_comp_le_right ( g ^ n ) g using 1;
  rw [ pow_succ' ];
  rfl

-- !-- Lab Notes -- !--
-- Analysis (Analyst): the concatenation law is the load-bearing fact; every rank
--   statement is a one-line corollary of it together with Mathlib's
--   `rank_comp_le_left/right`. The constant-sequence identification ties the new
--   `transEndo` object to the standard monoid power on `End K V`, so the rank
--   decay of iterates becomes a special case of window monotonicity.
-- Critique (Critic): the results are non-vacuous (the concatenation law requires a
--   genuine induction with a case split at `j = k+1` vs `j ≤ k`), avoid `native_decide`,
--   and reuse rather than re-prove Sylvester-type rank facts, as required.
-- Synthesis (PI): `transEndo` provides a reusable "transfer operator" abstraction
--   whose rank is automatically antitone along nested windows.
-- !-- End Lab Notes -- !--

end Catalog.Algebra.TransEndo