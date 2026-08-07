/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Pythagorean.BrillNoether.Divisors
import Pythagorean.BrillNoether.Reduced
import Pythagorean.BrillNoether.ReducedUnique
import Pythagorean.BrillNoether.ResidualDuality
import Pythagorean.BrillNoether.HalfCanonicalRegular
import Pythagorean.BrillNoether.SetFiringRank
import Pythagorean.BrillNoether.RankUpperBound

/-!
# Exact Baker–Norine ranks on complete graphs, and the sharpness of set firing

This file computes Baker–Norine ranks *exactly* on the complete graphs `K n`,
using the upper-bound machinery of `RankUpperBound.lean` together with the
set-firing lower bound of `SetFiringRank.lean`.

## Main results

* `isReduced_completeGraph_of_count` — a counting criterion for `q`-reducedness on
  `K n`: a divisor nonnegative away from `q` is `q`-reduced as soon as, for every
  `1 ≤ s ≤ n - 1`, fewer than `s` vertices other than `q` carry at least `n - s`
  chips.
* `not_rankAtLeast_const_completeGraph` — **the staircase obstruction**: on `K n`
  the constant divisor `m` does *not* have rank `m (m+3)/2 + 1`.  Hence
  `r(m · 1) ≤ m (m+3) / 2` on every complete graph.
* `rank_const_two_completeGraph` — combining with set firing: for every `n ≥ 4`
  the constant divisor `2` on `K n` has Baker–Norine rank **exactly** `5`.  Since
  `K n` is `(n-1)`-regular and `min (3m-1) (k+m) = 5` here while `k + m = n + 1`,
  this shows that the set-firing bound `rankAtLeast_of_forall_le_three_mul` is
  sharp and that its `3m - 1` term cannot be replaced by `k + m`.
* `rank_halfCanonical_K7`, `rank_halfCanonical_K8`, `rank_halfCanonical_K6` —
  exact ranks of the uniform half-canonical witnesses on `K₆`, `K₇`, `K₈`.  On
  `K₇` (`k = 6`) the rank is `5 = k - 1`, so the half-canonical bound is attained;
  on `K₈` (`k = 7`) and `K₆` (`k = 5`) the ranks are `5 < 6` and `2 < 4`, so the
  uniform witness *fails* to reach `k - 1` in exactly the two residual degrees.
-/

open Finset SimpleGraph

namespace BrillNoetherComplete

open BrillNoetherDivisor BrillNoetherReduced BrillNoetherReducedUnique
open BrillNoetherResidual BrillNoetherHalfCanonical BrillNoetherSetFiring BrillNoetherUpper

/-! ## Basic combinatorics of the complete graph -/

variable {n : ℕ}

/-- The complete graph on `n` labelled vertices. -/
abbrev K (n : ℕ) : SimpleGraph (Fin n) := ⊤

instance : DecidableRel (K n).Adj := fun a b => inferInstanceAs (Decidable (a ≠ b))

@[simp] lemma neighborFinset_K (v : Fin n) : (K n).neighborFinset v = univ.erase v := by
  ext u
  simp [SimpleGraph.mem_neighborFinset, eq_comm]

@[simp] lemma degree_K (v : Fin n) : (K n).degree v = n - 1 := by
  rw [← SimpleGraph.card_neighborFinset_eq_degree, neighborFinset_K,
    Finset.card_erase_of_mem (Finset.mem_univ v)]
  simp

lemma isRegular_K : (K n).IsRegularOfDegree (n - 1) := fun v => degree_K v

lemma connected_K (h : 0 < n) : (K n).Connected := by
  have : Nonempty (Fin n) := ⟨⟨0, h⟩⟩
  exact SimpleGraph.connected_top

/-- The complete graph has `n (n-1) / 2` edges. -/
lemma card_edgeFinset_K : #(K n).edgeFinset * 2 = n * (n - 1) := by
  have h := (K n).sum_degrees_eq_twice_card_edges
  simp only [degree_K, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
    smul_eq_mul] at h
  omega

/-- The genus of `K n` is `(n-1)(n-2)/2`. -/
lemma two_mul_genus_K (h : 1 ≤ n) : 2 * genus (K n) = ((n : ℤ) - 1) * ((n : ℤ) - 2) := by
  have h2 := card_edgeFinset_K (n := n)
  have hn : ((n - 1 : ℕ) : ℤ) = (n : ℤ) - 1 := by
    push_cast [Nat.cast_sub h]; ring
  have h3 : (#(K n).edgeFinset : ℤ) * 2 = (n : ℤ) * ((n : ℤ) - 1) := by
    have := congrArg (fun m : ℕ => (m : ℤ)) h2
    push_cast at this
    rw [hn] at this
    linarith
  unfold genus
  simp only [Fintype.card_fin]
  linarith

/-! ## A reducedness criterion on the complete graph -/

/-- Firing a set `S` of the complete graph costs each of its members `n - #S` chips. -/
lemma outdeg_K {S : Finset (Fin n)} {v : Fin n} (hv : v ∈ S) :
    outdeg (K n) S v = n - #S := by
  have hsub : (K n).neighborFinset v \ S = univ \ S := by
    rw [neighborFinset_K]
    ext u
    simp only [Finset.mem_sdiff, Finset.mem_erase, Finset.mem_univ, true_and, and_true]
    constructor
    · rintro ⟨_, hu⟩; exact hu
    · intro hu
      exact ⟨fun h => hu (h ▸ hv), hu⟩
  rw [outdeg, hsub, Finset.card_univ_diff]
  simp

/-- **Counting criterion for reducedness on `K n`.**  A divisor which is nonnegative
away from `q` is `q`-reduced as soon as, for every `1 ≤ s ≤ n - 1`, strictly fewer
than `s` vertices other than `q` carry at least `n - s` chips. -/
theorem isReduced_completeGraph_of_count {q : Fin n} {D : Divisor (Fin n)}
    (h0 : ∀ v, v ≠ q → 0 ≤ D v)
    (hc : ∀ s : ℕ, 1 ≤ s → s ≤ n - 1 →
      #((univ.erase q).filter (fun v => ((n - s : ℕ) : ℤ) ≤ D v)) < s) :
    IsReduced (K n) q D := by
  refine ⟨h0, fun S hS hne => ?_⟩
  by_contra hcon
  push_neg at hcon
  have hs1 : 1 ≤ #S := Finset.card_pos.mpr hne
  have hs2 : #S ≤ n - 1 := by
    have := Finset.card_le_card hS
    simpa [Finset.card_erase_of_mem (Finset.mem_univ q)] using this
  have hsub : S ⊆ (univ.erase q).filter (fun v => ((n - #S : ℕ) : ℤ) ≤ D v) := by
    intro v hv
    refine Finset.mem_filter.mpr ⟨hS hv, ?_⟩
    have := hcon v hv
    rwa [outdeg_K hv] at this
  have := Finset.card_le_card hsub
  exact absurd this (not_le.mpr (hc (#S) hs1 hs2))

/-! ## The staircase obstruction for constant divisors -/

/-- An auxiliary Gauss sum with truncated subtraction. -/
lemma two_mul_sum_trunc_sub (m : ℕ) :
    ∀ N : ℕ, m + 1 ≤ N → 2 * ∑ i ∈ Finset.range N, (m - i) = m * (m + 1) := by
  intro N hN
  induction N, hN using Nat.le_induction with
  | base =>
      have hrefl := Finset.sum_range_reflect (fun i => i) (m + 1)
      simp only [Nat.add_sub_cancel] at hrefl
      have hgauss := Finset.sum_range_id_mul_two (m + 1)
      simp only [Nat.add_sub_cancel] at hgauss
      rw [hrefl, Nat.mul_comm 2, hgauss]
      ring
  | succ N hN ih =>
      rw [Finset.sum_range_succ]
      have hz : m - N = 0 := by omega
      rw [hz]
      simpa using ih

/-- The *staircase test divisor* on `K n`: it removes `m + 1` chips from vertex `0`
and `m - (i - 1)` chips (truncated subtraction) from vertex `i`. -/
def stairE (n m : ℕ) : Divisor (Fin n) :=
  fun i => if i.val = 0 then (m : ℤ) + 1 else ((m - (i.val - 1) : ℕ) : ℤ)

lemma stairE_effective (n m : ℕ) : Effective (stairE n m) := by
  intro i
  unfold stairE
  split_ifs with h
  · positivity
  · exact Int.natCast_nonneg _

/-- The degree of the staircase test divisor is `m (m + 3) / 2 + 1`. -/
lemma two_mul_deg_stairE {n m : ℕ} (hn : m + 2 ≤ n) :
    2 * deg (stairE n m) = m * (m + 3) + 2 := by
  obtain ⟨N, rfl⟩ : ∃ N, n = N + 1 := ⟨n - 1, by omega⟩
  have hsum : deg (stairE (N + 1) m)
      = ∑ j ∈ Finset.range (N + 1),
        (if j = 0 then (m : ℤ) + 1 else ((m - (j - 1) : ℕ) : ℤ)) :=
    Fin.sum_univ_eq_sum_range
      (fun j => if j = 0 then (m : ℤ) + 1 else ((m - (j - 1) : ℕ) : ℤ)) (N + 1)
  rw [hsum, Finset.sum_range_succ' _ N]
  have hstep : ∀ j ∈ Finset.range N,
      (if j + 1 = 0 then (m : ℤ) + 1 else ((m - (j + 1 - 1) : ℕ) : ℤ)) = ((m - j : ℕ) : ℤ) := by
    intro j _
    simp
  rw [Finset.sum_congr rfl hstep]
  have hcast : ∑ j ∈ Finset.range N, ((m - j : ℕ) : ℤ)
      = ((∑ j ∈ Finset.range N, (m - j) : ℕ) : ℤ) := by push_cast; ring
  rw [hcast]
  have hgauss := two_mul_sum_trunc_sub m N (by omega)
  have hcast2 : ((2 * ∑ i ∈ Finset.range N, (m - i) : ℕ) : ℤ) = ((m * (m + 1) : ℕ) : ℤ) := by
    exact_mod_cast congrArg (fun x : ℕ => (x : ℤ)) hgauss
  push_cast at hcast2 ⊢
  linarith

/-- The divisor left over after removing the staircase from the constant divisor `m`. -/
def stairF (n m : ℕ) : Divisor (Fin n) := fun i => (m : ℤ) - stairE n m i

lemma stairF_apply_zero {n m : ℕ} (q : Fin n) (hq : q.val = 0) : stairF n m q = -1 := by
  simp [stairF, stairE, hq]

lemma stairF_apply_ne {n m : ℕ} (i : Fin n) (hi : i.val ≠ 0) :
    stairF n m i = (m : ℤ) - ((m - (i.val - 1) : ℕ) : ℤ) := by
  simp [stairF, stairE, hi]

/-- The staircase remainder is `q`-reduced at the base vertex `q = 0`. -/
theorem isReduced_stairF {n m : ℕ} (q : Fin n) (hq : q.val = 0) :
    IsReduced (K n) q (stairF n m) := by
  refine isReduced_completeGraph_of_count (fun v hv => ?_) (fun s hs1 hs2 => ?_)
  · have hv0 : v.val ≠ 0 := fun h => hv (Fin.ext (h.trans hq.symm))
    rw [stairF_apply_ne v hv0]
    omega
  · have hcard : #((univ.erase q).filter (fun v => ((n - s : ℕ) : ℤ) ≤ stairF n m v))
        ≤ #(Finset.Ico (n - s + 1) n) := by
      refine Finset.card_le_card_of_injOn (fun v => v.val) (fun v hv => ?_) ?_
      · rw [Finset.mem_coe, Finset.mem_filter] at hv
        obtain ⟨hv1, hv2⟩ := hv
        have hv0 : v.val ≠ 0 := fun h =>
          (Finset.mem_erase.mp hv1).1 (Fin.ext (h.trans hq.symm))
        rw [stairF_apply_ne v hv0] at hv2
        have hlt : v.val < n := v.isLt
        have hgoal : n - s + 1 ≤ v.val := by omega
        rw [Finset.mem_coe, Finset.mem_Ico]
        exact ⟨hgoal, hlt⟩
      · intro a _ b _ h
        exact Fin.ext h
    rw [Nat.card_Ico] at hcard
    omega

/-- **The staircase obstruction.**  On the complete graph `K n` with `n ≥ m + 2`,
the constant divisor with `m` chips at every vertex does *not* have Baker–Norine
rank `r + 1` when `2 r = m (m + 3)`.  Equivalently `r(m · 1) ≤ m (m + 3) / 2`. -/
theorem not_rankAtLeast_const_K {n m r : ℕ} (hn : m + 2 ≤ n) (hr : 2 * r = m * (m + 3)) :
    ¬ RankAtLeast (K n) (fun _ => (m : ℤ)) (r + 1) := by
  have hpos : 0 < n := by omega
  set q : Fin n := ⟨0, hpos⟩ with hqdef
  have hq : q.val = 0 := rfl
  have hdegE : deg (stairE n m) = ((r : ℤ) + 1) := by
    have h := two_mul_deg_stairE (n := n) (m := m) hn
    have hr' : (2 * r : ℤ) = (m : ℤ) * ((m : ℤ) + 3) := by exact_mod_cast hr
    push_cast at h
    linarith
  have hsub : (fun _ => (m : ℤ)) - stairE n m = stairF n m := by
    funext i; rfl
  refine not_rankAtLeast_of_sub_isReduced_neg' (K n) (q := q) (connected_K hpos)
    (stairE_effective n m) (by rw [hdegE]; push_cast; ring) ?_ ?_
  · rw [hsub]; exact isReduced_stairF q hq
  · rw [hsub, stairF_apply_zero q hq]; norm_num

/-! ## Sharpness of the set-firing bound -/

/-- The constant divisor `2` has rank at least `5` on every complete graph `K n`
with `n ≥ 4`: this is the set-firing bound `3m - 1` at `m = 2`. -/
theorem rankAtLeast_const_two_K {n : ℕ} (hn : 4 ≤ n) :
    RankAtLeast (K n) (fun _ => (2 : ℤ)) 5 :=
  rankAtLeast_of_forall_le_three_mul (K n) (k := n - 1) (m := 2) (d := 5)
    (fun v => (degree_K v).ge) (fun _ => le_refl 2) (le_refl 2) (by omega)
    (by omega) (by omega)

/-- **The set-firing bound is sharp.**  For every `n ≥ 4` the constant divisor `2`
on the complete graph `K n` has Baker–Norine rank *exactly* `5 = 3 · 2 - 1`.
Since `K n` is `(n-1)`-regular, the competing expression `k + m = n + 1` of
`rankAtLeast_of_forall_le_three_mul` is arbitrarily large, so the `3m - 1` term is
the essential one and cannot be improved. -/
theorem rank_const_two_K {n : ℕ} (hn : 4 ≤ n) :
    RankAtLeast (K n) (fun _ => (2 : ℤ)) 5 ∧ ¬ RankAtLeast (K n) (fun _ => (2 : ℤ)) 6 := by
  refine ⟨rankAtLeast_const_two_K hn, ?_⟩
  have h := not_rankAtLeast_const_K (n := n) (m := 2) (r := 5) (by omega) (by norm_num)
  simpa using h

/-- The exact value of the integer-valued rank. -/
theorem rankBN_const_two_K {n : ℕ} (hn : 4 ≤ n) [NeZero n] :
    rankBN (K n) (fun _ => (2 : ℤ)) = 5 := by
  obtain ⟨h1, h2⟩ := rank_const_two_K hn
  exact rankBN_eq_of_between (K n) h1 h2

/-- **The `k + m` term of the set-firing estimate is unattainable.**  On `K n` with
`n ≥ 5` the constant divisor `2` satisfies the hypotheses of
`rankAtLeast_of_forall_le_three_mul` with `k = n - 1` and `m = 2`, yet its rank is
strictly below `k + m = n + 1`. -/
theorem set_firing_k_add_m_false {n : ℕ} (hn : 5 ≤ n) :
    ¬ RankAtLeast (K n) (fun _ => (2 : ℤ)) ((n - 1) + 2) := by
  intro h
  have hnl : Nonempty (Fin n) := ⟨⟨0, by omega⟩⟩
  exact (rank_const_two_K (by omega)).2 (rankAtLeast_antitone (K n) (by omega) h)

/-! ## The half-canonical degree on `K₆`, `K₇`, `K₈` -/

lemma genus_K7 : genus (K 7) = 15 := by
  have h := two_mul_genus_K (n := 7) (by norm_num)
  norm_num at h
  linarith

lemma genus_K8 : genus (K 8) = 21 := by
  have h := two_mul_genus_K (n := 8) (by norm_num)
  norm_num at h
  linarith

lemma genus_K6 : genus (K 6) = 10 := by
  have h := two_mul_genus_K (n := 6) (by norm_num)
  norm_num at h
  linarith

/-- The uniform half-canonical witness on `K₇`: two chips at every vertex. -/
def D7 : Divisor (Fin 7) := fun _ => (2 : ℤ)

/-- **`K₇` attains the half-canonical bound.**  On the `6`-regular graph `K₇` the
constant divisor `2` has degree `g - 1` and Baker–Norine rank exactly `5 = k - 1`. -/
theorem rank_halfCanonical_K7 :
    deg D7 = genus (K 7) - 1 ∧
      RankAtLeast (K 7) D7 5 ∧ ¬ RankAtLeast (K 7) D7 6 := by
  refine ⟨?_, (rank_const_two_K (n := 7) (by norm_num)).1,
    (rank_const_two_K (n := 7) (by norm_num)).2⟩
  have hd : deg D7 = (14 : ℤ) := by decide
  rw [hd, genus_K7]
  norm_num

/-- The uniform half-canonical witness on `K₈`: `6` chips at one vertex and `2` at
all the others, of degree `20 = g - 1`. -/
def D8 : Divisor (Fin 8) := ![6, 2, 2, 2, 2, 2, 2, 2]

/-- The test divisor refuting rank `6` for `D8`. -/
def E8 : Divisor (Fin 8) := ![0, 3, 2, 1, 0, 0, 0, 0]

/-- **`K₈` misses the half-canonical bound.**  On the `7`-regular graph `K₈` the
uniform witness `D8` of degree `g - 1 = 20` has Baker–Norine rank exactly `5`,
strictly below `k - 1 = 6`. -/
theorem rank_halfCanonical_K8 :
    deg D8 = genus (K 8) - 1 ∧ RankAtLeast (K 8) D8 5 ∧ ¬ RankAtLeast (K 8) D8 6 := by
  refine ⟨?_, ?_, ?_⟩
  · have hd : deg D8 = (20 : ℤ) := by decide
    rw [hd, genus_K8]
    norm_num
  · refine rankAtLeast_of_forall_le_three_mul (K 8) (k := 7) (m := 2) (d := 5)
      (fun v => (degree_K v).ge) (by decide) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num)
  · refine not_rankAtLeast_of_sub_isReduced_neg' (K 8) (q := 1) (E := E8)
      (connected_K (by norm_num)) (fun v => by fin_cases v <;> decide) (by decide) ?_ (by decide)
    refine isReduced_completeGraph_of_count (by decide) (fun s hs1 hs2 => ?_)
    interval_cases s <;> decide

/-- The uniform half-canonical witness on `K₆`: `4` chips at one vertex and `1` at
all the others, of degree `9 = g - 1`. -/
def D6 : Divisor (Fin 6) := ![4, 1, 1, 1, 1, 1]

/-- The test divisor refuting rank `3` for `D6`. -/
def E6 : Divisor (Fin 6) := ![0, 2, 1, 0, 0, 0]

/-- **`K₆` misses the half-canonical bound badly.**  On the `5`-regular graph `K₆`
the uniform witness `D6` of degree `g - 1 = 9` has Baker–Norine rank exactly `2`,
strictly below `k - 1 = 4`. -/
theorem rank_halfCanonical_K6 :
    deg D6 = genus (K 6) - 1 ∧ RankAtLeast (K 6) D6 2 ∧ ¬ RankAtLeast (K 6) D6 3 := by
  refine ⟨?_, ?_, ?_⟩
  · have hd : deg D6 = (9 : ℤ) := by decide
    rw [hd, genus_K6]
    norm_num
  · have h := rankAtLeast_add_of_forall_le (K 6) (k := 5) (m := 1) (t := 1)
      (fun v => (degree_K v).ge) (D := D6) (by decide) (by norm_num) (by norm_num)
    simpa using h
  · refine not_rankAtLeast_of_sub_isReduced_neg' (K 6) (q := 1) (E := E6)
      (connected_K (by norm_num)) (fun v => by fin_cases v <;> decide) (by decide) ?_ (by decide)
    refine isReduced_completeGraph_of_count (by decide) (fun s hs1 hs2 => ?_)
    interval_cases s <;> decide

end BrillNoetherComplete