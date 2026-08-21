/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Sharp Turán numbers without a divisibility hypothesis

`Catalog/Bridges/TuranExplicitCount.lean` computes the number of edges of the Turán graph
`turanGraph n r` when `r ∣ n`, and, in general, the identity

`2 · #edges(turanGraph n r) + ∑_{i < r} |class i|² = n²`,

where `class i = {v : Fin n | v ≡ i mod r}`.  This file *closes* the loop by evaluating the
residue-class sizes in closed form and deducing the exact extremal number for **every** pair
`(n, r)` with `r ≥ 1`.

Main results (all with `0 < r`, no divisibility hypothesis):

* `card_range_filter_mod_eq` / `classSize_eq` — `|class i| = n / r + 1` if `i < n % r` and
  `n / r` otherwise; a bare induction on `n`.
* `turan_edge_identity` — the clean subtraction-free identity
  `2 · r · #edges(turanGraph n r) + (n % r) · (r − n % r) = (r − 1) · n²`.
* `card_edgeFinset_turanGraph_real_general` — the real-valued form
  `#edges = (1 − 1/r)·n²/2 − (n % r)(r − n % r)/(2r)`, hence the Turán graph is *below* the
  clean value `(1 − 1/r)n²/2`, with equality exactly when `r ∣ n`
  (`card_edgeFinset_eq_clean_iff_dvd`).
* `turan_extremal_number_general` — the exact extremal number
  `ex(n, K_{r+1}) = ((r − 1)·n² − (n % r)·(r − n % r)) / (2r)` as an `IsGreatest` statement,
  for arbitrary `n` and arbitrary `r ≥ 1`.
* `card_edgeFinset_eq_floor_iff` — the Turán number equals the *floor* `⌊(r − 1)n²/(2r)⌋`
  **iff** `(n % r)·(r − n % r) < 2r`.  This *refutes* the guess (recorded as an open direction
  in a previous cycle) that the floor formula is correct exactly when `n % r ∈ {0, 1}`:
* `turan_floor_overshoots_twelve_eight` — for `n = 12`, `r = 8` (so `n % r = 4`) the true
  extremal number is `62` while `⌊(r − 1)n²/(2r)⌋ = 63`, and
* `turan_floor_correct_of_lt_eight` — for every `r < 8` and every `n` the floor formula *is*
  correct, so `r = 8` is the first modulus where it can fail.
-/

import Mathlib
import Bridges.TuranExplicitCount

open Finset SimpleGraph
open scoped BigOperators

namespace TuranSharpNonDivisible

open TuranExplicitCount

variable {n r : ℕ}

/-! ## Residue-class sizes in closed form -/

/-- Division with remainder is unique: if `m = s + r * q` with `s < r`, then `q` and `s` are the
quotient and the remainder. -/
private lemma divmod_unique {r q s m : ℕ} (hr : 0 < r) (hs : s < r) (hm : m = s + r * q) :
    m / r = q ∧ m % r = s := by
  subst hm
  refine ⟨?_, ?_⟩
  · rw [Nat.add_mul_div_left _ _ hr, Nat.div_eq_of_lt hs, Nat.zero_add]
  · rw [Nat.add_mul_mod_self_left, Nat.mod_eq_of_lt hs]

/-- The number of naturals below `n` congruent to `i` mod `r`, in closed form. -/
lemma card_range_filter_mod_eq (r i : ℕ) (hr : 0 < r) (hi : i < r) (n : ℕ) :
    #((range n).filter (fun m => m % r = i)) = n / r + (if i < n % r then 1 else 0) := by
  induction n with
  | zero => simp
  | succ n ih =>
    obtain ⟨q, s, hs, hn⟩ : ∃ q s, s < r ∧ n = s + r * q :=
      ⟨n / r, n % r, Nat.mod_lt _ hr, (Nat.mod_add_div n r).symm⟩
    obtain ⟨hq, hsm⟩ := divmod_unique hr hs hn
    rw [Finset.range_add_one, Finset.filter_insert]
    have hnotmem : n ∉ (range n).filter (fun m => m % r = i) := by simp
    rcases eq_or_lt_of_le (Nat.succ_le_of_lt hs) with h | h
    · obtain ⟨hq1, hsm1⟩ := divmod_unique (m := n + 1) (r := r) (q := q + 1) (s := 0) hr hr
        (by rw [hn, Nat.mul_add, Nat.mul_one]; omega)
      by_cases hcase : n % r = i
      · rw [if_pos hcase, Finset.card_insert_of_notMem hnotmem, ih]
        simp only [hq, hsm, hq1, hsm1] at *
        split_ifs <;> omega
      · rw [if_neg hcase, ih]
        simp only [hq, hsm, hq1, hsm1] at *
        split_ifs <;> omega
    · obtain ⟨hq1, hsm1⟩ := divmod_unique (m := n + 1) (r := r) (q := q) (s := s + 1) hr h
        (by omega)
      by_cases hcase : n % r = i
      · rw [if_pos hcase, Finset.card_insert_of_notMem hnotmem, ih]
        simp only [hq, hsm, hq1, hsm1] at *
        split_ifs <;> omega
      · rw [if_neg hcase, ih]
        simp only [hq, hsm, hq1, hsm1] at *
        split_ifs <;> omega

/-- Counting the vertices of `Fin n` in a residue class is the same as counting the naturals
below `n` in that class. -/
lemma classSize_eq_card_range_filter (n r i : ℕ) :
    classSize n r i = #((range n).filter (fun m => m % r = i)) := by
  classical
  apply Finset.card_bij (fun (w : Fin n) _ => (w : ℕ))
  · intro w hw
    simp only [mem_filter, mem_univ, true_and, mem_range] at *
    exact ⟨w.isLt, hw⟩
  · intro a _ b _ hab
    exact Fin.ext hab
  · intro b hb
    simp only [mem_filter, mem_range] at hb
    exact ⟨⟨b, hb.1⟩, by simp [hb.2], rfl⟩

/-- **Residue-class sizes.**  The `i`-th class of `Fin n` mod `r` has `n / r + 1` elements if
`i < n % r`, and `n / r` elements otherwise. -/
lemma classSize_eq (hr : 0 < r) {i : ℕ} (hi : i < r) :
    classSize n r i = n / r + (if i < n % r then 1 else 0) := by
  rw [classSize_eq_card_range_filter, card_range_filter_mod_eq r i hr hi]

/-- The sum of squares of the residue-class sizes in closed form:
`∑_{i<r} |class i|² = r·(n/r)² + (n % r)·(2·(n/r) + 1)`. -/
lemma sum_classSize_sq_closed (hr : 0 < r) :
    ∑ i ∈ range r, (classSize n r i) ^ 2
      = r * (n / r) ^ 2 + (n % r) * (2 * (n / r) + 1) := by
  have hs : n % r ≤ r := le_of_lt (Nat.mod_lt _ hr)
  have hterm : ∀ i ∈ range r, (classSize n r i) ^ 2
      = (n / r) ^ 2 + (if i < n % r then 2 * (n / r) + 1 else 0) := by
    intro i hi
    rw [classSize_eq hr (mem_range.1 hi)]
    split_ifs <;> ring
  rw [Finset.sum_congr rfl hterm, Finset.sum_add_distrib, Finset.sum_const, Finset.sum_ite,
    Finset.sum_const, Finset.sum_const]
  have hcard : #((range r).filter (fun i => i < n % r)) = n % r := by
    have : (range r).filter (fun i => i < n % r) = range (n % r) := by
      ext i; simp only [mem_filter, mem_range]; omega
    rw [this, card_range]
  simp only [smul_eq_mul, mul_zero, add_zero, card_range, hcard]

/-! ## The exact edge count of the Turán graph -/

/-- The arithmetic core: eliminating the quotient and the remainder from the class-size
identity leaves a subtraction-free cubic identity. -/
private lemma turan_arith {E q s r n : ℕ} (hs : s < r) (hn : n = s + r * q)
    (hE : 2 * E + (r * q ^ 2 + s * (2 * q + 1)) = n ^ 2) :
    2 * r * E + s * (r - s) = (r - 1) * n ^ 2 := by
  obtain ⟨a, rfl⟩ : ∃ a, r = s + (a + 1) := ⟨r - s - 1, by omega⟩
  have h1 : s + (a + 1) - s = a + 1 := by omega
  have h2 : s + (a + 1) - 1 = s + a := by omega
  rw [h1, h2]
  subst hn
  zify at hE ⊢
  linear_combination ((s : ℤ) + (a : ℤ) + 1) * hE

/-- **The Turán graph's edge count, exactly, for all `n` and all `r ≥ 1`.**
`2·r·#edges + (n % r)·(r − n % r) = (r − 1)·n²`.  The correction term
`(n % r)·(r − n % r)` vanishes precisely when `r ∣ n`. -/
theorem turan_edge_identity (hr : 0 < r) :
    2 * r * #(turanGraph n r).edgeFinset + (n % r) * (r - n % r) = (r - 1) * n ^ 2 := by
  have hE : 2 * #(turanGraph n r).edgeFinset + ∑ i ∈ range r, (classSize n r i) ^ 2 = n ^ 2 :=
    two_mul_card_edgeFinset_turanGraph_general hr
  rw [sum_classSize_sq_closed hr] at hE
  exact turan_arith (Nat.mod_lt _ hr) (Nat.mod_add_div n r).symm hE

/-- The real-valued exact edge count: the Turán graph misses the clean value `(1 − 1/r)n²/2`
by exactly `(n % r)·(r − n % r)/(2r)`. -/
theorem card_edgeFinset_turanGraph_real_general (hr : 0 < r) :
    (#(turanGraph n r).edgeFinset : ℝ)
      = (1 - 1 / r) * n ^ 2 / 2 - (n % r : ℕ) * ((r : ℝ) - (n % r : ℕ)) / (2 * r) := by
  have hid := turan_edge_identity (n := n) (r := r) hr
  have hsle : (n % r : ℕ) ≤ r := le_of_lt (Nat.mod_lt _ hr)
  have hcast : (2 : ℝ) * r * #(turanGraph n r).edgeFinset
      + (n % r : ℕ) * ((r : ℝ) - (n % r : ℕ)) = ((r : ℝ) - 1) * (n : ℝ) ^ 2 := by
    have := congrArg (fun m : ℕ => (m : ℝ)) hid
    push_cast [Nat.cast_sub hsle, Nat.cast_sub hr] at this
    linarith [this]
  have hrne : (r : ℝ) ≠ 0 := Nat.cast_ne_zero.2 hr.ne'
  field_simp
  nlinarith [hcast]

/-- The clean value `(1 − 1/r)·n²/2` is attained by the Turán graph **iff** `r ∣ n`. -/
theorem card_edgeFinset_eq_clean_iff_dvd (hr : 0 < r) :
    (#(turanGraph n r).edgeFinset : ℝ) = (1 - 1 / r) * n ^ 2 / 2 ↔ r ∣ n := by
  have hreal := card_edgeFinset_turanGraph_real_general (n := n) (r := r) hr
  have hs : n % r < r := Nat.mod_lt _ hr
  have hrpos : (0 : ℝ) < r := by exact_mod_cast hr
  constructor
  · intro h
    rw [h] at hreal
    have hzero : (n % r : ℕ) * ((r : ℝ) - (n % r : ℕ)) = 0 := by
      have h2r : (0 : ℝ) < 2 * r := by linarith
      have hquot : (n % r : ℕ) * ((r : ℝ) - (n % r : ℕ)) / (2 * r) = 0 := by linarith
      rcases div_eq_zero_iff.1 hquot with h' | h'
      · exact h'
      · exact absurd h' (by positivity)
    have hpos : (0 : ℝ) < (r : ℝ) - (n % r : ℕ) := by
      have : ((n % r : ℕ) : ℝ) < r := by exact_mod_cast hs
      linarith
    have : ((n % r : ℕ) : ℝ) = 0 := by
      rcases mul_eq_zero.1 hzero with h' | h'
      · exact h'
      · linarith
    have : n % r = 0 := by exact_mod_cast this
    exact Nat.dvd_of_mod_eq_zero this
  · intro h
    rw [hreal, Nat.mod_eq_zero_of_dvd h]
    simp

/-! ## The exact extremal number, and the floor formula -/

/-- **Turán's theorem, exactly, with no divisibility hypothesis.**  For every `n` and every
`r ≥ 1`, the maximum number of edges of a `K_{r+1}`-free graph on `n` vertices is
`((r − 1)·n² − (n % r)·(r − n % r)) / (2r)`, attained by the Turán graph. -/
theorem turan_extremal_number_general (hr : 0 < r) :
    IsGreatest {m : ℕ | ∃ (G : SimpleGraph (Fin n)) (_ : DecidableRel G.Adj),
      G.CliqueFree (r + 1) ∧ #G.edgeFinset = m}
      (((r - 1) * n ^ 2 - (n % r) * (r - n % r)) / (2 * r)) := by
  classical
  have hid := turan_edge_identity (n := n) (r := r) hr
  have h2r : 0 < 2 * r := by omega
  have hval : #(turanGraph n r).edgeFinset
      = ((r - 1) * n ^ 2 - (n % r) * (r - n % r)) / (2 * r) := by
    have heq : (r - 1) * n ^ 2 - (n % r) * (r - n % r)
        = 2 * r * #(turanGraph n r).edgeFinset := by omega
    rw [heq, Nat.mul_div_cancel_left _ h2r]
  refine ⟨⟨turanGraph n r, inferInstance, turanGraph_cliqueFree hr, hval⟩, ?_⟩
  rintro m ⟨G, hGdec, hGfree, rfl⟩
  have hmax := (isTuranMaximal_turanGraph (n := n) hr).2 hGfree
  omega

/-- **The floor formula is correct exactly when `(n % r)·(r − n % r) < 2r`.**  In particular the
naive guess that it holds precisely for `n % r ∈ {0, 1}` is false. -/
theorem card_edgeFinset_eq_floor_iff (hr : 0 < r) :
    #(turanGraph n r).edgeFinset = (r - 1) * n ^ 2 / (2 * r)
      ↔ (n % r) * (r - n % r) < 2 * r := by
  have hid := turan_edge_identity (n := n) (r := r) hr
  have h2r : 0 < 2 * r := by omega
  have hdiv : (r - 1) * n ^ 2 / (2 * r)
      = #(turanGraph n r).edgeFinset + (n % r) * (r - n % r) / (2 * r) := by
    rw [← hid, Nat.mul_add_div h2r]
  rw [hdiv]
  constructor
  · intro h
    have hz : (n % r) * (r - n % r) / (2 * r) = 0 := by omega
    exact (Nat.div_eq_zero_iff_lt h2r).1 hz
  · intro h
    have hz : (n % r) * (r - n % r) / (2 * r) = 0 := Nat.div_eq_of_lt h
    omega

/-- **A counterexample to the floor formula.**  For `n = 12`, `r = 8` (so `n % r = 4`) the
extremal number is `62`, while `⌊(r − 1)·n²/(2r)⌋ = 63`. -/
theorem turan_floor_overshoots_twelve_eight :
    #(turanGraph 12 8).edgeFinset = 62 ∧ (8 - 1) * 12 ^ 2 / (2 * 8) = 63 := by
  have hid := turan_edge_identity (n := 12) (r := 8) (by norm_num)
  norm_num at hid
  exact ⟨by omega, by norm_num⟩

/-- For every modulus `r < 8`, and every `n`, the floor formula *is* correct: `r = 8` is the
first modulus at which the extremal number can fall strictly below `⌊(1 − 1/r)·n²/2⌋`. -/
theorem turan_floor_correct_of_lt_eight (hr : 0 < r) (hr8 : r < 8) :
    #(turanGraph n r).edgeFinset = (r - 1) * n ^ 2 / (2 * r) := by
  rw [card_edgeFinset_eq_floor_iff hr]
  have hs : n % r < r := Nat.mod_lt _ hr
  obtain ⟨s, t, hst, hsr⟩ : ∃ s t, s + t = r ∧ n % r = s := ⟨n % r, r - n % r, by omega, rfl⟩
  rw [hsr]
  have ht : r - s = t := by omega
  rw [ht]
  have hs8 : s < 8 := by omega
  have ht8 : t ≤ 8 := by omega
  interval_cases s <;> interval_cases t <;> omega

end TuranSharpNonDivisible