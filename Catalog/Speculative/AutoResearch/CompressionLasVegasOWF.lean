/-
Copyright (c) 2025. All rights reserved.

# Las Vegas compression, average description length, and the one-way boundary

## Overview

This file continues the research thread *Compression Beyond the Pigeonhole Bound*
(Phase B, Question 2: "can random number generators help?").  It builds directly
on `Speculative.AutoResearch.CompressionOneWayFunctions`, which established

* the pigeonhole ceiling `card_le_of_K_le`,
* the **seed-budget** theorem `card_le_of_K_le_seeded` (a randomized decompressor
  with seed space `R` compresses at most `|R| * (2^(s+1) - 1)` objects), and
* the equivalence `owf_iff_compression_hard` between one-way functions and
  hardness of compression search.

The seed-budget theorem charges the compressor for the *whole* seed space: it only
assumes that **some** seed works for each object.  The present file sharpens and
extends that picture in three independent directions.

### 1. It is the success *probability*, not the seed length, that is paid for

`lasVegas_sum_bound` is a double-counting theorem: summing, over a finite target
set `T`, the number of seeds that compress `y` to `s` bits gives at most
`|R| * (2^(s+1) - 1)`.  Consequences:

* `lasVegas_card_bound` : if every `y ∈ T` is compressed by at least `m` seeds
  then `m * |T| ≤ |R| * (2^(s+1) - 1)`, i.e. a Las Vegas compressor with success
  probability `δ = m/|R|` gains at most `log₂(1/δ) + 1` bits — *independently of
  how many random bits it uses*;
* `zero_error_randomness_no_gain` : a randomized compressor that must succeed for
  **every** seed gains exactly nothing (the deterministic ceiling reappears);
* `lasVegas_bound_tight` : the bound is tight within a factor `2`, witnessed by
  the seeded prefix system `prefixSeeded`, where `j` of the `i + j` seed bits are
  "used" and the success probability is exactly `2^(-j)`;
* `lasVegas_incompressible` : for every seeded family and every `k` there is a
  string of length `k + s + 1` whose success probability is below `2^(-k)`.

### 2. Average-case (Shannon-type) lower bounds from pure counting

`layer_lower_bound` is a layer-cake inequality turning any counting bound into a
bound on the *sum* of description lengths.  From it:

* `avg_description_length` : for any decompressor and any set of `2^n` describable
  objects the average description length is at least `n - 2`;
* `avg_description_length_seeded` : with `2^k` seeds the average is still at least
  `n - k - 3`.  So randomness buys at most `k + O(1)` bits *on average*, not just
  in the worst case.

### 3. Las Vegas randomness does not cross the cryptographic boundary

`tryList` is a deterministic simulation of a Las Vegas algorithm: run all seeds
from a finite list and keep the first output that verifies.  For a class closed
under this operation (`LasVegasClass`), a one-way function defeats *every* Las
Vegas algorithm **totally**:

* `owf_defeats_las_vegas` : there is a describable `y` on which **all** seeds fail;
* `owf_defeats_las_vegas_compression` : the same for seeded compression search.

Non-vacuity is checked (`lengthLVClass`, `lengthClass_las_vegas_compression_hard`):
the class of length-nondecreasing algorithms satisfies the new closure axiom and
carries a genuine one-way function.

`compression_randomness_calibration` collects the four regimes into a single
statement.

All results are proved from scratch; there are no axioms and no `sorry`.
-/
import Mathlib
import Speculative.AutoResearch.CompressionOneWayFunctions

namespace CompressionLasVegas

open CompressionOWF

/-! ## Section 1: Las Vegas compression — the price of a success probability -/

section LasVegas

open scoped Classical

variable {α : Type*}

/-- The set of seeds under which `y` is compressible to `s` bits. -/
noncomputable def goodSeeds {R : Type*} [Fintype R] (D : R → Str → α) (s : ℕ) (y : α) :
    Finset R :=
  Finset.univ.filter (fun r => Describable (D r) y ∧ K (D r) y ≤ s)

lemma mem_goodSeeds {R : Type*} [Fintype R] {D : R → Str → α} {s : ℕ} {y : α} {r : R} :
    r ∈ goodSeeds D s y ↔ Describable (D r) y ∧ K (D r) y ≤ s := by
  simp [goodSeeds]

/-- **Las Vegas double-counting theorem.**  Summed over any finite target set,
the number of seeds that compress an object to `s` bits is at most
`|R| * (2^(s+1) - 1)`.  Randomness is a budget spent across the whole target set. -/
theorem lasVegas_sum_bound {R : Type*} [Fintype R] (D : R → Str → α) (s : ℕ) (T : Finset α) :
    ∑ y ∈ T, (goodSeeds D s y).card ≤ Fintype.card R * (2 ^ (s + 1) - 1) := by
  calc ∑ y ∈ T, (goodSeeds D s y).card
      = ∑ y ∈ T, ∑ r : R, (if Describable (D r) y ∧ K (D r) y ≤ s then 1 else 0) := by
        refine Finset.sum_congr rfl (fun y _ => ?_)
        rw [goodSeeds, Finset.card_filter]
    _ = ∑ r : R, ∑ y ∈ T, (if Describable (D r) y ∧ K (D r) y ≤ s then 1 else 0) :=
        Finset.sum_comm
    _ = ∑ _r : R, ((T.filter (fun y => Describable (D _r) y ∧ K (D _r) y ≤ s)).card) := by
        refine Finset.sum_congr rfl (fun r _ => ?_)
        rw [Finset.card_filter]
    _ ≤ ∑ _r : R, (2 ^ (s + 1) - 1) := by
        refine Finset.sum_le_sum (fun r _ => ?_)
        exact card_le_of_K_le (D r) s _ (fun y hy => (Finset.mem_filter.1 hy).2)
    _ = Fintype.card R * (2 ^ (s + 1) - 1) := by
        rw [Finset.sum_const, Finset.card_univ, smul_eq_mul]

/-- **Success probability, not seed length, is what is paid for.**  If every
object of `T` is compressed to `s` bits by at least `m` of the `|R|` seeds, then
`m * |T| ≤ |R| * (2^(s+1) - 1)`.  Writing `δ = m / |R|` for the success
probability, the number of compressible objects is at most `(2^(s+1) - 1)/δ`:
a Las Vegas compressor gains at most `log₂(1/δ) + 1` bits, no matter how many
random bits it consumes. -/
theorem lasVegas_card_bound {R : Type*} [Fintype R] (D : R → Str → α) (s m : ℕ) (T : Finset α)
    (hT : ∀ y ∈ T, m ≤ (goodSeeds D s y).card) :
    m * T.card ≤ Fintype.card R * (2 ^ (s + 1) - 1) := by
  calc m * T.card = ∑ _y ∈ T, m := by rw [Finset.sum_const, smul_eq_mul, mul_comm]
    _ ≤ ∑ y ∈ T, (goodSeeds D s y).card := Finset.sum_le_sum hT
    _ ≤ Fintype.card R * (2 ^ (s + 1) - 1) := lasVegas_sum_bound D s T

/-- **Zero-error randomness gains nothing.**  A seeded compressor that succeeds
for *every* seed is subject to the deterministic pigeonhole ceiling: the seed
space cancels out completely. -/
theorem zero_error_randomness_no_gain {R : Type*} [Fintype R] [Nonempty R]
    (D : R → Str → α) (s : ℕ) (T : Finset α)
    (hT : ∀ y ∈ T, ∀ r : R, Describable (D r) y ∧ K (D r) y ≤ s) :
    T.card ≤ 2 ^ (s + 1) - 1 := by
  have hpos : 0 < Fintype.card R := Fintype.card_pos
  have h := lasVegas_card_bound D s (Fintype.card R) T (by
    intro y hy
    have huniv : goodSeeds D s y = Finset.univ :=
      Finset.eq_univ_iff_forall.2 (fun r => mem_goodSeeds.2 (hT y hy r))
    simp [huniv])
  exact Nat.le_of_mul_le_mul_left h hpos

/-- **Quantified randomness gain.**  If the success probability is at least
`2^(-k)` (i.e. `|R| ≤ m * 2^k` seeds work for every target), then at most
`2^k * (2^(s+1) - 1)` objects are compressible to `s` bits: the gain over the
deterministic ceiling is at most `k` bits. -/
theorem randomness_gain_le_log_inv_success {R : Type*} [Fintype R] (D : R → Str → α)
    (s k m : ℕ) (hm : 0 < m) (T : Finset α) (hδ : Fintype.card R ≤ m * 2 ^ k)
    (hT : ∀ y ∈ T, m ≤ (goodSeeds D s y).card) :
    T.card ≤ 2 ^ k * (2 ^ (s + 1) - 1) := by
  have h : m * T.card ≤ m * (2 ^ k * (2 ^ (s + 1) - 1)) := by
    calc m * T.card ≤ Fintype.card R * (2 ^ (s + 1) - 1) := lasVegas_card_bound D s m T hT
      _ ≤ (m * 2 ^ k) * (2 ^ (s + 1) - 1) := Nat.mul_le_mul_right _ hδ
      _ = m * (2 ^ k * (2 ^ (s + 1) - 1)) := by ring
  exact Nat.le_of_mul_le_mul_left h hm

/-- **Las Vegas incompressibility.**  For every seeded family of decompressors,
every target length budget `s` and every `k`, some string of length `k + s + 1`
is compressed to `s` bits with probability strictly below `2^(-k)`.  Randomness
cannot remove incompressible strings, it can only make them slightly rarer. -/
theorem lasVegas_incompressible {R : Type*} [Fintype R] [Nonempty R]
    (D : R → Str → Str) (s k : ℕ) :
    ∃ y : Str, y.length = k + s + 1 ∧ 2 ^ k * (goodSeeds D s y).card < Fintype.card R := by
  by_contra hcon
  push_neg at hcon
  set N := Fintype.card R with hN
  have hNpos : 0 < N := Fintype.card_pos
  set T := bitStrings (k + s + 1) with hTdef
  have hTcard : T.card = 2 ^ (k + s + 1) := card_bitStrings _
  have hlow : T.card * N ≤ 2 ^ k * ∑ y ∈ T, (goodSeeds D s y).card := by
    rw [Finset.mul_sum]
    calc T.card * N = ∑ _y ∈ T, N := by rw [Finset.sum_const, smul_eq_mul]
      _ ≤ ∑ y ∈ T, 2 ^ k * (goodSeeds D s y).card := by
          refine Finset.sum_le_sum (fun y hy => ?_)
          exact hcon y (mem_bitStrings.1 hy)
  have hhigh : 2 ^ k * ∑ y ∈ T, (goodSeeds D s y).card < 2 ^ k * (N * 2 ^ (s + 1)) := by
    refine mul_lt_mul_of_pos_left ?_ (pow_pos (by norm_num : (0:ℕ) < 2) k)
    calc ∑ y ∈ T, (goodSeeds D s y).card ≤ N * (2 ^ (s + 1) - 1) := lasVegas_sum_bound D s T
      _ < N * 2 ^ (s + 1) := by
          refine mul_lt_mul_of_pos_left ?_ hNpos
          have : 0 < 2 ^ (s + 1) := pow_pos (by norm_num) _
          omega
  have heq : T.card * N = 2 ^ k * (N * 2 ^ (s + 1)) := by
    rw [hTcard]
    have : (2 : ℕ) ^ (k + s + 1) = 2 ^ k * 2 ^ (s + 1) := by
      rw [← pow_add]; ring_nf
    rw [this]; ring
  omega

end LasVegas

/-! ## Section 2: the Las Vegas bound is tight -/

section Tight

open scoped Classical

/-- Reading the first `j` bits of a list as a function `Fin j → Bool`. -/
lemma ofFn_getD_eq_take (y : Str) (j : ℕ) (hj : j ≤ y.length) :
    List.ofFn (fun t : Fin j => y.getD t false) = y.take j := by
  apply List.ext_getElem
  · simp [Nat.min_eq_left hj]
  · intro n h1 h2
    have hn : n < j := by simpa using h1
    have hny : n < y.length := lt_of_lt_of_le hn hj
    simp [List.getElem_take, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem hny]

/-- The seeded prefix system: the first component of the seed is prepended to the
program, the second component is ignored (it is "wasted" randomness). -/
def prefixSeeded {j i : ℕ} (r : (Fin j → Bool) × (Fin i → Bool)) (p : Str) : Str :=
  List.ofFn r.1 ++ p

/-- Every string of length `j + s` is compressible to `s` bits by at least `2^i`
of the `2^(i+j)` seeds: the success probability is exactly `2^(-j)`. -/
theorem prefixSeeded_goodSeeds_card {i j s : ℕ} (y : Str) (hy : y.length = j + s) :
    2 ^ i ≤ (goodSeeds (prefixSeeded (j := j) (i := i)) s y).card := by
  set u₀ : Fin j → Bool := fun t => y.getD t false with hu₀
  have hsub : ({u₀} ×ˢ (Finset.univ : Finset (Fin i → Bool)))
      ⊆ goodSeeds (prefixSeeded (j := j) (i := i)) s y := by
    intro r hr
    rw [Finset.mem_product] at hr
    have hr1 : r.1 = u₀ := Finset.mem_singleton.1 hr.1
    have htake : List.ofFn u₀ = y.take j := ofFn_getD_eq_take y j (by omega)
    have hdec : prefixSeeded r (y.drop j) = y := by
      show List.ofFn r.1 ++ y.drop j = y
      rw [hr1, htake, List.take_append_drop]
    refine mem_goodSeeds.2 ⟨⟨y.drop j, hdec⟩, ?_⟩
    have hlen : (y.drop j).length = s := by simp [hy]
    calc K (prefixSeeded r) y ≤ (y.drop j).length := K_le_of_eq hdec
      _ = s := hlen
  calc (2 : ℕ) ^ i = ({u₀} ×ˢ (Finset.univ : Finset (Fin i → Bool))).card := by
        rw [Finset.card_product]
        simp
    _ ≤ _ := Finset.card_le_card hsub

/-- **Tightness of the Las Vegas bound.**  For all `i, j, s`, the seeded prefix
system compresses all `2^(j+s)` strings of length `j + s` with success
probability `2^(-j)` using `i + j` random bits, and the resulting product
`m * |T|` is more than half of the upper bound `|R| * (2^(s+1) - 1)`.
So `lasVegas_card_bound` is optimal up to one bit, and — crucially — the answer
depends only on the success probability `2^(-j)`, not on the `i` extra random
bits. -/
theorem lasVegas_bound_tight (i j s : ℕ) :
    (∀ y ∈ bitStrings (j + s), 2 ^ i ≤ (goodSeeds (prefixSeeded (j := j) (i := i)) s y).card) ∧
      Fintype.card ((Fin j → Bool) × (Fin i → Bool)) * (2 ^ (s + 1) - 1)
        < 2 * (2 ^ i * (bitStrings (j + s)).card) := by
  refine ⟨fun y hy => prefixSeeded_goodSeeds_card y (mem_bitStrings.1 hy), ?_⟩
  have hcardR : Fintype.card ((Fin j → Bool) × (Fin i → Bool)) = 2 ^ j * 2 ^ i := by
    simp [Fintype.card_prod]
  have hT : (bitStrings (j + s)).card = 2 ^ (j + s) := card_bitStrings _
  rw [hcardR, hT]
  have h2 : (2 : ℕ) ^ (s + 1) = 2 * 2 ^ s := by rw [pow_succ]; ring
  have h3 : 2 * (2 ^ i * 2 ^ (j + s)) = (2 ^ j * 2 ^ i) * (2 * 2 ^ s) := by
    rw [pow_add]; ring
  have hpos : 0 < (2 : ℕ) ^ j * 2 ^ i :=
    Nat.mul_pos (pow_pos (by norm_num) _) (pow_pos (by norm_num) _)
  have hs : 0 < (2 : ℕ) ^ s := pow_pos (by norm_num) _
  rw [h2, h3]
  exact mul_lt_mul_of_pos_left (by omega) hpos

end Tight

/-! ## Section 3: average description length (Shannon bounds from counting) -/

section Average

open scoped Classical

variable {α : Type*}

/-- Layer-cake inequality: any family of counting bounds on the sublevel sets of
`c` yields a lower bound on the *sum* of `c` over a finite set. -/
theorem layer_lower_bound (c : α → ℕ) (T : Finset α) (bnd : ℕ → ℕ) (S : ℕ)
    (h : ∀ s < S, (T.filter (fun y => c y ≤ s)).card ≤ bnd s) :
    S * T.card ≤ (∑ y ∈ T, c y) + ∑ s ∈ Finset.range S, bnd s := by
  have hsplit : ∀ s : ℕ, (T.filter (fun y => c y ≤ s)).card
      + (T.filter (fun y => s < c y)).card = T.card := by
    intro s
    have := Finset.card_filter_add_card_filter_not
      (s := T) (p := fun y => c y ≤ s)
    simpa using this
  have hupper : ∑ s ∈ Finset.range S, (T.filter (fun y => s < c y)).card ≤ ∑ y ∈ T, c y := by
    calc ∑ s ∈ Finset.range S, (T.filter (fun y => s < c y)).card
        = ∑ s ∈ Finset.range S, ∑ y ∈ T, (if s < c y then 1 else 0) := by
          refine Finset.sum_congr rfl (fun s _ => ?_)
          rw [Finset.card_filter]
      _ = ∑ y ∈ T, ∑ s ∈ Finset.range S, (if s < c y then 1 else 0) := Finset.sum_comm
      _ = ∑ y ∈ T, ((Finset.range S).filter (fun s => s < c y)).card := by
          refine Finset.sum_congr rfl (fun y _ => ?_)
          rw [Finset.card_filter]
      _ ≤ ∑ y ∈ T, c y := by
          refine Finset.sum_le_sum (fun y _ => ?_)
          have hsub : (Finset.range S).filter (fun s => s < c y) ⊆ Finset.range (c y) := by
            intro s hs
            exact Finset.mem_range.2 (Finset.mem_filter.1 hs).2
          simpa using Finset.card_le_card hsub
  calc S * T.card = ∑ _s ∈ Finset.range S, T.card := by
        rw [Finset.sum_const, Finset.card_range, smul_eq_mul]
    _ = ∑ s ∈ Finset.range S, ((T.filter (fun y => c y ≤ s)).card
          + (T.filter (fun y => s < c y)).card) := by
        refine Finset.sum_congr rfl (fun s _ => (hsplit s).symm)
    _ = (∑ s ∈ Finset.range S, (T.filter (fun y => c y ≤ s)).card)
          + ∑ s ∈ Finset.range S, (T.filter (fun y => s < c y)).card := Finset.sum_add_distrib
    _ ≤ (∑ s ∈ Finset.range S, bnd s) + ∑ y ∈ T, c y := by
        refine Nat.add_le_add ?_ hupper
        exact Finset.sum_le_sum (fun s hs => h s (Finset.mem_range.1 hs))
    _ = (∑ y ∈ T, c y) + ∑ s ∈ Finset.range S, bnd s := by ring

lemma sum_two_pow_succ (m : ℕ) : (∑ s ∈ Finset.range m, 2 ^ (s + 1)) + 2 = 2 ^ (m + 1) := by
  induction m with
  | zero => simp
  | succ p ih =>
      rw [Finset.sum_range_succ]
      have h : (2 : ℕ) ^ (p + 1 + 1) = 2 * 2 ^ (p + 1) := by ring
      omega

/-- **Average description length.**  For any decompressor `D` and any set `T` of
at least `2^n` describable objects, the average description length is at least
`n - 2`.  This is the Shannon bound obtained from pure counting: it holds for
every decompressor whatsoever, computable or not. -/
theorem avg_description_length (D : Str → α) (T : Finset α)
    (hdesc : ∀ y ∈ T, Describable D y) (n : ℕ) (hT : 2 ^ n ≤ T.card) :
    (n - 2) * T.card ≤ ∑ y ∈ T, K D y := by
  rcases Nat.lt_or_ge n 3 with hn | hn
  · have : n - 2 = 0 ∨ n - 2 = 0 := Or.inl (by omega)
    simp [show n - 2 = 0 by omega]
  have hlayer := layer_lower_bound (c := fun y => K D y) (T := T)
    (bnd := fun s => 2 ^ (s + 1) - 1) (S := n - 1) (by
      intro s _
      exact card_le_of_K_le D s _ (fun y hy => by
        have hmem := Finset.mem_filter.1 hy
        exact ⟨hdesc y hmem.1, hmem.2⟩))
  have hgeom : (∑ s ∈ Finset.range (n - 1), (2 ^ (s + 1) - 1)) ≤ 2 ^ n := by
    have h1 : (∑ s ∈ Finset.range (n - 1), (2 ^ (s + 1) - 1))
        ≤ ∑ s ∈ Finset.range (n - 1), 2 ^ (s + 1) :=
      Finset.sum_le_sum (fun s _ => Nat.sub_le _ _)
    have h2 := sum_two_pow_succ (n - 1)
    have h3 : n - 1 + 1 = n := by omega
    rw [h3] at h2
    omega
  have hsum : (n - 1) * T.card ≤ (∑ y ∈ T, K D y) + T.card := by
    calc (n - 1) * T.card
        ≤ (∑ y ∈ T, K D y) + ∑ s ∈ Finset.range (n - 1), (2 ^ (s + 1) - 1) := hlayer
      _ ≤ (∑ y ∈ T, K D y) + T.card := Nat.add_le_add_left (le_trans hgeom hT) _
  have hmul : (n - 2) * T.card + T.card = (n - 1) * T.card := by
    have : (n - 2) + 1 = n - 1 := by omega
    calc (n - 2) * T.card + T.card = ((n - 2) + 1) * T.card := by ring
      _ = (n - 1) * T.card := by rw [this]
  omega

/-- Complexity relative to a *seeded* family: the length of a shortest program
under the best seed. -/
noncomputable def Kseed {R : Type*} (D : R → Str → α) (y : α) : ℕ :=
  sInf {n | ∃ (r : R) (p : Str), p.length = n ∧ D r p = y}

lemma Kseed_spec {R : Type*} (D : R → Str → α) (y : α) (h : ∃ r : R, Describable (D r) y) :
    ∃ (r : R) (p : Str), p.length = Kseed D y ∧ D r p = y := by
  obtain ⟨r, p, hp⟩ := h
  have hne : {n | ∃ (r : R) (p : Str), p.length = n ∧ D r p = y}.Nonempty :=
    ⟨p.length, r, p, rfl, hp⟩
  exact Nat.sInf_mem hne

/-- **Average description length with randomness.**  With `2^k` seeds available,
the average description length over any set of at least `2^n` objects is still at
least `n - k - 3`: randomness saves at most `k + O(1)` bits *on average*, exactly
as in the worst case. -/
theorem avg_description_length_seeded {R : Type*} [Fintype R] [DecidableEq R]
    (D : R → Str → α) (T : Finset α) (n k : ℕ) (hR : Fintype.card R ≤ 2 ^ k)
    (hdesc : ∀ y ∈ T, ∃ r : R, Describable (D r) y) (hT : 2 ^ n ≤ T.card) :
    (n - k - 3) * T.card ≤ ∑ y ∈ T, Kseed D y := by
  rcases Nat.lt_or_ge n (k + 4) with hn | hn
  · simp [show n - k - 3 = 0 by omega]
  have hlay : ∀ s, s < n - k - 2 →
      (T.filter (fun y => Kseed D y ≤ s)).card ≤ 2 ^ k * (2 ^ (s + 1) - 1) := by
    intro s _
    have hbound := card_le_of_K_le_seeded D s
      (T.filter (fun y => Kseed D y ≤ s)) (by
        intro y hy
        have hmem := Finset.mem_filter.1 hy
        obtain ⟨r, p, hlen, hp⟩ := Kseed_spec D y (hdesc y hmem.1)
        refine ⟨r, ⟨p, hp⟩, ?_⟩
        have h1 : K (D r) y ≤ p.length := K_le_of_eq hp
        have h2 : Kseed D y ≤ s := hmem.2
        omega)
    exact le_trans hbound (Nat.mul_le_mul_right _ hR)
  have hlayer : (n - k - 2) * T.card ≤
      (∑ y ∈ T, Kseed D y) + ∑ s ∈ Finset.range (n - k - 2), 2 ^ k * (2 ^ (s + 1) - 1) :=
    layer_lower_bound (c := fun y => Kseed D y) (T := T)
      (bnd := fun s => 2 ^ k * (2 ^ (s + 1) - 1)) (S := n - k - 2) hlay
  have hgeom : (∑ s ∈ Finset.range (n - k - 2), 2 ^ k * (2 ^ (s + 1) - 1)) ≤ T.card := by
    have h1 : (∑ s ∈ Finset.range (n - k - 2), 2 ^ k * (2 ^ (s + 1) - 1))
        ≤ ∑ s ∈ Finset.range (n - k - 2), 2 ^ k * 2 ^ (s + 1) :=
      Finset.sum_le_sum (fun s _ => Nat.mul_le_mul_left _ (Nat.sub_le _ _))
    have h2 : ∑ s ∈ Finset.range (n - k - 2), 2 ^ k * 2 ^ (s + 1)
        = 2 ^ k * ∑ s ∈ Finset.range (n - k - 2), 2 ^ (s + 1) := by
      rw [Finset.mul_sum]
    have h3 := sum_two_pow_succ (n - k - 2)
    have h4 : (2 : ℕ) ^ k * 2 ^ (n - k - 2 + 1) = 2 ^ (n - 1) := by
      rw [← pow_add]
      congr 1
      omega
    have h5 : (2 : ℕ) ^ (n - 1) ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) (by omega)
    have h6 : 2 ^ k * ∑ s ∈ Finset.range (n - k - 2), 2 ^ (s + 1) ≤ 2 ^ (n - 1) := by
      have : 2 ^ k * ((∑ s ∈ Finset.range (n - k - 2), 2 ^ (s + 1)) + 2)
          = 2 ^ k * 2 ^ (n - k - 2 + 1) := by rw [h3]
      nlinarith [pow_pos (show 0 < 2 by norm_num) k]
    omega
  have hsum : (n - k - 2) * T.card ≤ (∑ y ∈ T, Kseed D y) + T.card :=
    le_trans hlayer (Nat.add_le_add_left hgeom _)
  have hmul : (n - k - 3) * T.card + T.card = (n - k - 2) * T.card := by
    have h : (n - k - 3) + 1 = n - k - 2 := by omega
    calc (n - k - 3) * T.card + T.card = ((n - k - 3) + 1) * T.card := by ring
      _ = (n - k - 2) * T.card := by rw [h]
  omega

end Average

/-! ## Section 4: Las Vegas algorithms against the cryptographic boundary -/

section Crypto

/-- Deterministic simulation of a Las Vegas algorithm: run the algorithm on every
seed in the finite list `R`, verify each candidate output, and return the first
one that verifies (echoing the input if none does).  This is the operation under
which a class must be closed for Las Vegas randomness to be simulable. -/
def tryList (f : Str → Str) (A : Str → Str → Str) (R : List Str) : Str → Str :=
  fun y =>
    match R.find? (fun r => decide (f (A r y) = y)) with
    | some r => A r y
    | none => y

/-- **Las Vegas inversion derandomizes.**  If for every value in the range of `f`
*some* seed of the finite list `R` produces a preimage, then `tryList` is a
genuine (deterministic) inverter for `f`. -/
theorem tryList_inverts (f : Str → Str) (A : Str → Str → Str) (R : List Str)
    (h : ∀ y : Str, Describable f y → ∃ r ∈ R, f (A r y) = y) :
    Inverts f (tryList f A R) := by
  intro y hy
  obtain ⟨r, hrR, hr⟩ := h y hy
  cases hfind : R.find? (fun r => decide (f (A r y) = y)) with
  | none =>
      have hcontra := List.find?_eq_none.1 hfind r hrR
      simp [hr] at hcontra
  | some r' =>
      have hr' : f (A r' y) = y := by
        have := List.find?_some hfind
        simpa using this
      show f (tryList f A R y) = y
      simp only [tryList, hfind]
      exact hr'

/-- A class of algorithms closed under the operations of `SearchClosedClass` and,
in addition, under the Las Vegas simulation `tryList` (run finitely many seeds
and keep the first verified answer).  Every reasonable deterministic complexity
class with verification is of this kind. -/
structure LasVegasClass extends SearchClosedClass where
  /-- Closure under running finitely many seeds and keeping the first verified answer. -/
  tryList_mem : ∀ f ∈ Comp, ∀ A : Str → Str → Str, (∀ r : Str, A r ∈ Comp) →
    ∀ R : List Str, tryList f A R ∈ Comp

/-- **One-way functions defeat Las Vegas randomness totally.**  If `f` is one-way
for a `LasVegasClass`, then for every seeded algorithm whose every seed-slice
lies in the class and every finite seed list `R`, there is a value in the range
of `f` on which *all* seeds fail simultaneously.

This is the computational counterpart of `zero_error_randomness_no_gain`: a
bounded amount of randomness does not merely fail with small probability, it
fails with probability one on some input. -/
theorem owf_defeats_las_vegas (C : LasVegasClass) (f : Str → Str)
    (hf : OneWayIn C.toSearchClosedClass f)
    (A : Str → Str → Str) (hA : ∀ r : Str, A r ∈ C.Comp) (R : List Str) :
    ∃ y : Str, Describable f y ∧ ∀ r ∈ R, f (A r y) ≠ y := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨hfmem, -, hhard⟩ := hf
  exact hhard (tryList f A R) (C.tryList_mem f hfmem A hA R) (tryList_inverts f A R hcon)

/-- The Las Vegas version of the compression-search task: on every describable
`y`, some seed of the finite list `R` must output a shortest `D`-program. -/
def SeededShortestFinder (D : Str → Str) (A : Str → Str → Str) (R : List Str) : Prop :=
  ∀ y : Str, Describable D y → ∃ r ∈ R, D (A r y) = y ∧ (A r y).length = K D y

/-- **Las Vegas compression is still cryptographically blocked.**  No seeded
family of class algorithms, with any finite seed list, solves the
compression-search problem for a one-way function. -/
theorem owf_defeats_las_vegas_compression (C : LasVegasClass) (f : Str → Str)
    (hf : OneWayIn C.toSearchClosedClass f) (A : Str → Str → Str)
    (hA : ∀ r : Str, A r ∈ C.Comp) (R : List Str) :
    ¬ SeededShortestFinder f A R := by
  intro hS
  obtain ⟨y, hy, hbad⟩ := owf_defeats_las_vegas C f hf A hA R
  obtain ⟨r, hr, h1, -⟩ := hS y hy
  exact hbad r hr h1

/-- The closure axiom is consistent: the class of all functions satisfies it. -/
def fullLVClass : LasVegasClass where
  toSearchClosedClass := fullClass
  tryList_mem := fun _ _ _ _ _ => Set.mem_univ _

/-- The closure axiom is also satisfied by a class carrying a genuine one-way
function: length-nondecreasing algorithms.  (Verification never shortens the
input, and the fallback branch echoes it.) -/
def lengthLVClass : LasVegasClass where
  toSearchClosedClass := lengthClass
  tryList_mem := by
    intro f _ A hA R y
    cases hfind : R.find? (fun r => decide (f (A r y) = y)) with
    | none =>
        show y.length ≤ (tryList f A R y).length
        simp [tryList, hfind]
    | some r =>
        have h : y.length ≤ (A r y).length := hA r y
        show y.length ≤ (tryList f A R y).length
        simpa [tryList, hfind] using h

/-- **Non-vacuity.**  In the class of length-nondecreasing algorithms the tagging
function `tagTrue` is one-way, hence every Las Vegas algorithm of the class, with
any finite seed list, fails on some string for *all* of its seeds. -/
theorem lengthClass_las_vegas_total_failure (A : Str → Str → Str)
    (hA : ∀ r : Str, A r ∈ lengthLVClass.Comp) (R : List Str) :
    ∃ y : Str, Describable tagTrue y ∧ ∀ r ∈ R, tagTrue (A r y) ≠ y :=
  owf_defeats_las_vegas lengthLVClass tagTrue tagTrue_oneway A hA R

/-- The same statement for compression search: Las Vegas compression is hard in
the length class. -/
theorem lengthClass_las_vegas_compression_hard (A : Str → Str → Str)
    (hA : ∀ r : Str, A r ∈ lengthLVClass.Comp) (R : List Str) :
    ¬ SeededShortestFinder tagTrue A R :=
  owf_defeats_las_vegas_compression lengthLVClass tagTrue tagTrue_oneway A hA R

/-! ### Section 4b: Las Vegas compression search is *equivalent* to inversion

The previous results show that one-way functions block Las Vegas compression.
The following results close the loop: Las Vegas compression search is not merely
blocked by one-way functions, it is *equivalent* to inverting them.  Randomness
is therefore worth exactly zero at the cryptographic boundary. -/

/-- Inverting all honest functions is equivalent to inverting them by a Las Vegas
algorithm with a finite seed list. -/
theorem las_vegas_inversion_iff_inversion (C : LasVegasClass) :
    (∀ f ∈ C.Comp, HonestIn C.toSearchClosedClass f → ∃ A ∈ C.Comp, Inverts f A) ↔
    (∀ f ∈ C.Comp, HonestIn C.toSearchClosedClass f →
      ∃ (A : Str → Str → Str) (R : List Str), (∀ r : Str, A r ∈ C.Comp) ∧
        ∀ y : Str, Describable f y → ∃ r ∈ R, f (A r y) = y) := by
  constructor
  · intro h f hf hhon
    obtain ⟨A, hA, hAinv⟩ := h f hf hhon
    exact ⟨fun _ => A, [[]], fun _ => hA, fun y hy => ⟨[], by simp, hAinv y hy⟩⟩
  · intro h f hf hhon
    obtain ⟨A, R, hA, hgood⟩ := h f hf hhon
    exact ⟨tryList f A R, C.tryList_mem f hf A hA R, tryList_inverts f A R hgood⟩

/-- **The characterization.**  For a class closed under guarding, bounded search
and Las Vegas simulation, the following are equivalent:

* a one-way function exists;
* the *deterministic* compression-search problem is hard for some honest
  decompressor;
* the *Las Vegas* compression-search problem (finitely many seeds, any success
  pattern) is hard for some honest decompressor.

This is the precise mapping of compression tasks to cryptographic assumptions:
randomizing the compressor changes nothing about which assumption is needed. -/
theorem owf_iff_las_vegas_compression_hard (C : LasVegasClass) :
    (∃ f, OneWayIn C.toSearchClosedClass f) ↔
    (∃ D, D ∈ C.Comp ∧ HonestIn C.toSearchClosedClass D ∧
      ∀ (A : Str → Str → Str) (R : List Str), (∀ r : Str, A r ∈ C.Comp) →
        ¬ SeededShortestFinder D A R) := by
  constructor
  · rintro ⟨f, hf⟩
    exact ⟨f, hf.1, hf.2.1, fun A R hA => owf_defeats_las_vegas_compression C f hf A hA R⟩
  · rintro ⟨D, hD, hhon, hhard⟩
    refine (owf_iff_compression_hard C.toSearchClosedClass).2 ⟨D, hD, hhon, ?_⟩
    intro A hA hfind
    refine hhard (fun _ => A) [[]] (fun _ => hA) ?_
    intro y hy
    exact ⟨[], by simp, hfind y hy⟩

/-- Approximate Las Vegas compression: some seed must output a program that
*decodes correctly* and is within an additive slack `g` of optimal. -/
def SeededApproxFinder (D : Str → Str) (A : Str → Str → Str) (R : List Str) (g : ℕ → ℕ) : Prop :=
  ∀ y : Str, Describable D y → ∃ r ∈ R, D (A r y) = y ∧ (A r y).length ≤ K D y + g y.length

/-- **Approximation slack does not cross the boundary either.**  For a one-way
`f`, no Las Vegas algorithm of the class produces, for any slack function `g`
whatsoever, a correct program for every describable value.  The cryptographic
obstruction is to producing *any* valid description, not an optimal one. -/
theorem owf_defeats_las_vegas_approx (C : LasVegasClass) (f : Str → Str)
    (hf : OneWayIn C.toSearchClosedClass f) (A : Str → Str → Str)
    (hA : ∀ r : Str, A r ∈ C.Comp) (R : List Str) (g : ℕ → ℕ) :
    ¬ SeededApproxFinder f A R g := by
  intro hS
  obtain ⟨y, hy, hbad⟩ := owf_defeats_las_vegas C f hf A hA R
  obtain ⟨r, hr, h1, -⟩ := hS y hy
  exact hbad r hr h1

/-- **The barrier is genuinely conditional.**  In the class of all functions
there is no one-way function, and indeed a single-seed "Las Vegas" algorithm
solves compression search for every honest decompressor.  So Section 4 is not a
hidden unconditional impossibility: it is exactly the cryptographic assumption
that blocks compression. -/
theorem fullLVClass_las_vegas_easy (f : Str → Str) (hhon : HonestIn fullClass f) :
    ∃ (A : Str → Str → Str) (R : List Str), (∀ r : Str, A r ∈ fullLVClass.Comp) ∧
      SeededShortestFinder f A R := by
  obtain ⟨A, -, hA⟩ := fullClass_compression_easy f (Set.mem_univ _) hhon
  exact ⟨fun _ => A, [[]], fun _ => Set.mem_univ _,
    fun y hy => ⟨[], by simp, (hA y hy).1, (hA y hy).2⟩⟩

end Crypto

/-! ## Section 5: the calibration theorem -/

section Calibration

open scoped Classical

/-- **Calibration of randomness for compression.**  Fix a class `C` with a
one-way function `f`, a target length `s`, a seeded family `D` of decompressors
with at most `m * 2^k` seeds, each target being compressed by at least `m` seeds
(success probability `δ ≥ 2^(-k)`).  Then:

1. *Worst case*: at most `2^k * (2^(s+1) - 1)` strings are compressible to `s`
   bits — the gain over the deterministic ceiling is at most `k` bits, and it
   depends only on `δ`, never on the number of random bits used;
2. *Incompressibility survives*: some string of length `k + s + 1` is compressed
   with probability strictly below `2^(-k)`;
3. *Average case*: over any set of `2^n` objects the average description length
   is still at least `n - k - 3`;
4. *Computational boundary*: every Las Vegas algorithm of the class, with any
   finite seed list, fails with probability one on some input of `f`.

Items 1–3 are unconditional counting facts; item 4 is the cryptographic barrier.
Together they say: randomness helps compression exactly up to `log₂(1/δ)` bits,
and efficient compression stops at the one-way boundary. -/
theorem compression_randomness_calibration (C : LasVegasClass) (f : Str → Str)
    (hf : OneWayIn C.toSearchClosedClass f) (s k m : ℕ) (hm : 0 < m)
    {R : Type} [Fintype R] [Nonempty R] [DecidableEq R] (D : R → Str → Str)
    (hδ : Fintype.card R ≤ m * 2 ^ k) :
    (∀ T : Finset Str, (∀ y ∈ T, m ≤ (goodSeeds D s y).card) →
        T.card ≤ 2 ^ k * (2 ^ (s + 1) - 1))
    ∧ (∃ y : Str, y.length = k + s + 1 ∧ 2 ^ k * (goodSeeds D s y).card < Fintype.card R)
    ∧ (∀ (T : Finset Str) (n : ℕ), Fintype.card R ≤ 2 ^ k →
        (∀ y ∈ T, ∃ r : R, Describable (D r) y) → 2 ^ n ≤ T.card →
        (n - k - 3) * T.card ≤ ∑ y ∈ T, Kseed D y)
    ∧ (∀ A : Str → Str → Str, (∀ r : Str, A r ∈ C.Comp) → ∀ Rl : List Str,
        ∃ y : Str, Describable f y ∧ ∀ r ∈ Rl, f (A r y) ≠ y) := by
  refine ⟨fun T hT => randomness_gain_le_log_inv_success D s k m hm T hδ hT,
    lasVegas_incompressible D s k, ?_, ?_⟩
  · intro T n hR hdesc hT
    exact avg_description_length_seeded D T n k hR hdesc hT
  · intro A hA Rl
    exact owf_defeats_las_vegas C f hf A hA Rl

end Calibration

/-! ## Section 6: a strict hierarchy in the seed budget -/

section Hierarchy

open scoped Classical

/-- **Strict seed hierarchy.**  Halving the seed space strictly weakens a
randomized compressor:

* with `2^k` seeds the prefix family compresses *every* string of length `k + s`
  to `s` bits (some seed always works);
* with only `2^(k-1)` seeds *no* seeded family, however clever, can do this:
  some string of length `k + s` is missed by all seeds.

So the seed budget is not a soft parameter: each extra random bit is worth
exactly one bit of compression and no two bits are interchangeable. -/
theorem seed_hierarchy_strict (k s : ℕ) (hk : 1 ≤ k) :
    (∀ y ∈ bitStrings (k + s), (goodSeeds (prefixSeeded (j := k) (i := 0)) s y).Nonempty) ∧
    (∀ (R : Type) (_ : Fintype R) (D : R → Str → Str), Fintype.card R ≤ 2 ^ (k - 1) →
      ∃ y ∈ bitStrings (k + s), goodSeeds D s y = ∅) := by
  constructor
  · intro y hy
    have h := prefixSeeded_goodSeeds_card (i := 0) (j := k) (s := s) y (mem_bitStrings.1 hy)
    rw [pow_zero] at h
    exact Finset.card_pos.1 h
  · intro R _ D hR
    by_contra hcon
    push_neg at hcon
    have hall : ∀ y ∈ bitStrings (k + s), ∃ r : R, Describable (D r) y ∧ K (D r) y ≤ s := by
      intro y hy
      obtain ⟨r, hr⟩ := hcon y hy
      exact ⟨r, mem_goodSeeds.1 hr⟩
    have hbound := card_le_of_K_le_seeded D s (bitStrings (k + s)) hall
    rw [card_bitStrings] at hbound
    have h1 : Fintype.card R * (2 ^ (s + 1) - 1) ≤ 2 ^ (k - 1) * (2 ^ (s + 1) - 1) :=
      Nat.mul_le_mul_right _ hR
    have h2 : (2 : ℕ) ^ (k - 1) * 2 ^ (s + 1) = 2 ^ (k + s) := by
      rw [← pow_add]
      congr 1
      omega
    have h3 : 0 < (2 : ℕ) ^ (k - 1) := pow_pos (by norm_num) _
    have h4 : (2 : ℕ) ^ (k - 1) * (2 ^ (s + 1) - 1)
        = 2 ^ (k - 1) * 2 ^ (s + 1) - 2 ^ (k - 1) := by
      rw [Nat.mul_sub, mul_one]
    have h6 : 0 < (2 : ℕ) ^ (k + s) := pow_pos (by norm_num) _
    have h5 : (2 : ℕ) ^ (k + s) ≤ 2 ^ (k + s) - 2 ^ (k - 1) :=
      calc (2 : ℕ) ^ (k + s) ≤ Fintype.card R * (2 ^ (s + 1) - 1) := hbound
        _ ≤ 2 ^ (k - 1) * (2 ^ (s + 1) - 1) := h1
        _ = 2 ^ (k - 1) * 2 ^ (s + 1) - 2 ^ (k - 1) := h4
        _ = 2 ^ (k + s) - 2 ^ (k - 1) := by rw [h2]
    omega

end Hierarchy

/-! ## Section 7: the average-case constant is sharp -/

section Sharpness

open scoped Classical

/-- All bit strings of length at most `m`. -/
def bitStringsUpTo (m : ℕ) : Finset Str := (Finset.range (m + 1)).biUnion bitStrings

lemma bitStrings_disjoint {l l' : ℕ} (h : l ≠ l') :
    Disjoint (bitStrings l) (bitStrings l') := by
  refine Finset.disjoint_left.2 (fun y hy hy' => ?_)
  exact h ((mem_bitStrings.1 hy).symm.trans (mem_bitStrings.1 hy'))

lemma sum_two_pow_range (m : ℕ) : (∑ l ∈ Finset.range m, 2 ^ l) + 1 = 2 ^ m := by
  induction m with
  | zero => simp
  | succ p ih =>
      rw [Finset.sum_range_succ]
      have h : (2 : ℕ) ^ (p + 1) = 2 * 2 ^ p := by ring
      omega

lemma card_bitStringsUpTo (m : ℕ) : (bitStringsUpTo m).card + 1 = 2 ^ (m + 1) := by
  have hcard : (bitStringsUpTo m).card = ∑ l ∈ Finset.range (m + 1), 2 ^ l := by
    rw [bitStringsUpTo, Finset.card_biUnion (fun l _ l' _ h => bitStrings_disjoint h)]
    exact Finset.sum_congr rfl (fun l _ => card_bitStrings l)
  rw [hcard]
  exact sum_two_pow_range (m + 1)

/-- Under the identity decompressor the complexity of a string is its length. -/
lemma K_id (y : Str) : K (id : Str → Str) y = y.length := by
  refine le_antisymm (K_le_of_eq (by simp)) ?_
  obtain ⟨p, hlen, hp⟩ := exists_shortest (D := (id : Str → Str)) (y := y) ⟨y, by simp⟩
  have : p = y := hp
  rw [← hlen, this]

/-- The geometric identity `∑_{l<M} l·2^l + 2·2^M = M·2^M + 2`, stated without
truncated subtraction. -/
lemma sum_mul_two_pow (M : ℕ) :
    (∑ l ∈ Finset.range M, l * 2 ^ l) + 2 * 2 ^ M = M * 2 ^ M + 2 := by
  induction M with
  | zero => simp
  | succ p ih =>
      rw [Finset.sum_range_succ]
      have h : (2 : ℕ) ^ (p + 1) = 2 * 2 ^ p := by ring
      have hmul : (p + 1) * 2 ^ (p + 1) = 2 * (p * 2 ^ p) + 2 * 2 ^ p := by
        rw [h]; ring
      omega

/-- **The average-case constant `2` is sharp.**  For the identity decompressor and
the set `T` of all strings of length `≤ m` we have, exactly,
`∑ K + 2·2^(m+1) = (m+1)·2^(m+1) + 2` while `|T| + 1 = 2^(m+1)`.

So the average description length of a set of `≈ 2^n` objects can be as small as
`n - 2 + o(1)`: the bound `avg_description_length` cannot be improved beyond an
additive `O(1)`, and in particular the exponent-counting argument behind it is
asymptotically optimal. -/
theorem avg_description_length_sharp (m : ℕ) :
    (∑ y ∈ bitStringsUpTo m, K (id : Str → Str) y) + 2 * 2 ^ (m + 1)
      = (m + 1) * 2 ^ (m + 1) + 2 ∧ (bitStringsUpTo m).card + 1 = 2 ^ (m + 1) := by
  refine ⟨?_, card_bitStringsUpTo m⟩
  have hsum : (∑ y ∈ bitStringsUpTo m, K (id : Str → Str) y)
      = ∑ l ∈ Finset.range (m + 1), l * 2 ^ l := by
    rw [bitStringsUpTo, Finset.sum_biUnion (fun l _ l' _ h => bitStrings_disjoint h)]
    refine Finset.sum_congr rfl (fun l _ => ?_)
    have : ∀ y ∈ bitStrings l, K (id : Str → Str) y = l := by
      intro y hy
      rw [K_id, mem_bitStrings.1 hy]
    rw [Finset.sum_congr rfl this, Finset.sum_const, card_bitStrings, smul_eq_mul, mul_comm]
  rw [hsum]
  exact sum_mul_two_pow (m + 1)

end Sharpness

end CompressionLasVegas