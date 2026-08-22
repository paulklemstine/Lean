/-
# Fair schedules for arbitrary positive rate profiles, via prefix sums

A *rate profile* is a function `r : ℕ → ℕ` together with a client count `k`,
all of whose rates `r 0, …, r (k-1)` are positive.  Writing
`pre r i = ∑_{j < i} r j` for the prefix sums and `R = pre r k` for the total
rate, the half-open intervals

  `batch r i = Ico (pre r i) (pre r (i+1))`

form a family of pairwise disjoint *exact-rate batches*: client `i` owns exactly
`r i` of the `R` slots of a period, and the batches tile `range R`.  Repeating
the tiling periodically yields the **block schedule** `owner r k : ℕ → ℕ`, whose
value at time `t` is recovered from the prefix sums by a *counting* formula,
`owner r k t = #{ i < k | pre r (i+1) ≤ t % R }`.

The central result is an exact closed form for the service counter of the block
schedule (`cnt_eq`):

  `cnt r k i t = (t / R) * r i + min (r i) (t % R - pre r i)`.

Every fairness statement in the file is a corollary of this single identity:

* `cnt_period_multiple` : exact rates at every period boundary.
* `cnt_disc_upper` / `cnt_disc_lower` : the *sharp* two–sided discrepancy bounds
  `- r i * pre r i ≤ R * cnt - r i * t ≤ r i * (R - pre r (i+1))`, so the
  discrepancy of a client is governed by the prefix mass before it and the
  suffix mass after it.
* `cnt_exact_iff_period` : for `k ≥ 2` the block schedule is exact **precisely**
  at multiples of the period.
* `exists_service_in_window` : no starvation — every client is served in every
  window of `R` consecutive slots.

We then compare with the classical one-dimensional Bresenham (Beatty) schedule
for two clients, which achieves unit discrepancy (`bres_disc`), strictly better
than the block schedule can do (`block_disc_large`), and we show that the naive
"nested prefix floors" generalisation of Bresenham to `k ≥ 3` clients is *not*
realisable by any schedule (`nested_floor_not_schedulable`): the candidate
counter for the middle client of the profile `(3,1,3)` decreases.  Finally
`no_exact_schedule` shows that with two or more clients *no* schedule whatsoever
can be exact at all times, so the period-boundary exactness of the block
schedule is the best possible form of exactness.
-/
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Order.Interval.Finset.Nat
import Mathlib.Algebra.BigOperators.Intervals
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.NormNum

namespace FairSchedule

open Finset

def pre (r : ℕ → ℕ) (i : ℕ) : ℕ := ∑ j ∈ Finset.range i, r j

def total (r : ℕ → ℕ) (k : ℕ) : ℕ := pre r k

def batch (r : ℕ → ℕ) (i : ℕ) : Finset ℕ := Finset.Ico (pre r i) (pre r (i + 1))

lemma pre_succ (r : ℕ → ℕ) (i : ℕ) : pre r (i + 1) = pre r i + r i := by
  simp [pre, Finset.sum_range_succ]

lemma pre_mono (r : ℕ → ℕ) : Monotone (pre r) := by
  intro a b hab
  exact Finset.sum_le_sum_of_subset
    (fun x hx => Finset.mem_range.mpr (lt_of_lt_of_le (Finset.mem_range.mp hx) hab))

lemma pre_le_total {r : ℕ → ℕ} {k i : ℕ} (h : i ≤ k) : pre r i ≤ total r k :=
  pre_mono r h

lemma batch_card (r : ℕ → ℕ) (i : ℕ) : (batch r i).card = r i := by
  simp [batch, pre_succ]

lemma batch_disjoint_of_lt (r : ℕ → ℕ) {i j : ℕ} (h : i < j) :
    Disjoint (batch r i) (batch r j) := by
  rw [Finset.disjoint_left]
  intro x hx hx'
  simp only [batch, Finset.mem_Ico] at hx hx'
  have : pre r (i + 1) ≤ pre r j := pre_mono r h
  omega

lemma batch_disjoint (r : ℕ → ℕ) {i j : ℕ} (h : i ≠ j) :
    Disjoint (batch r i) (batch r j) := by
  rcases Nat.lt_or_ge i j with hij | hij
  · exact batch_disjoint_of_lt r hij
  · exact (batch_disjoint_of_lt r (lt_of_le_of_ne hij (Ne.symm h))).symm

lemma batch_biUnion (r : ℕ → ℕ) (k : ℕ) :
    ((Finset.range k).biUnion (batch r)) = Finset.range (total r k) := by
  induction k with
  | zero => simp [total, pre]
  | succ k ih =>
      rw [Finset.range_add_one, Finset.biUnion_insert, ih, Finset.range_eq_Ico,
        Finset.union_comm]
      show Finset.Ico 0 (pre r k) ∪ Finset.Ico (pre r k) (pre r (k + 1)) =
        Finset.Ico 0 (pre r (k + 1))
      exact Finset.Ico_union_Ico_eq_Ico (Nat.zero_le _) (pre_mono r (Nat.le_succ k))

lemma sum_batch_card (r : ℕ → ℕ) (k : ℕ) :
    ∑ i ∈ Finset.range k, (batch r i).card = total r k := by
  simp [batch_card, total, pre]

/-! ## block index -/

lemma filter_range_antitone (p : ℕ → Prop) [DecidablePred p]
    (hp : ∀ i j, j ≤ i → p i → p j) (k : ℕ) :
    (Finset.range k).filter p = Finset.range (((Finset.range k).filter p).card) := by
  induction k with
  | zero => simp
  | succ k ih =>
      by_cases h : p k
      · have hall : (Finset.range (k + 1)).filter p = Finset.range (k + 1) :=
          Finset.filter_true_of_mem (fun j hj => hp k j (by simp at hj; omega) h)
        rw [hall]
        simp
      · have hcard : ((Finset.range (k + 1)).filter p).card =
            ((Finset.range k).filter p).card := by
          rw [Finset.range_add_one, Finset.filter_insert, if_neg h]
        rw [hcard, Finset.range_add_one, Finset.filter_insert, if_neg h]
        exact ih

def blockIndex (r : ℕ → ℕ) (k s : ℕ) : ℕ :=
  ((Finset.range k).filter (fun i => pre r (i + 1) ≤ s)).card

lemma filter_eq_range_blockIndex (r : ℕ → ℕ) (k s : ℕ) :
    (Finset.range k).filter (fun i => pre r (i + 1) ≤ s) = Finset.range (blockIndex r k s) :=
  filter_range_antitone _ (fun i j hji hi => le_trans (pre_mono r (by omega)) hi) k

lemma blockIndex_lt {r : ℕ → ℕ} {k s : ℕ} (hs : s < total r k) : blockIndex r k s < k := by
  have hle : blockIndex r k s ≤ k := by
    simpa [blockIndex] using
      Finset.card_le_card (Finset.filter_subset (fun i => pre r (i + 1) ≤ s) (Finset.range k))
        |>.trans_eq (Finset.card_range k)
  rcases Nat.lt_or_ge (blockIndex r k s) k with h | h
  · exact h
  · exfalso
    have hk : blockIndex r k s = k := le_antisymm hle h
    have hk0 : 0 < k := by
      rcases Nat.eq_zero_or_pos k with h0 | h0
      · subst h0; simp [total, pre] at hs
      · exact h0
    have : (k - 1) ∈ Finset.range (blockIndex r k s) := by
      rw [hk]; simp; omega
    rw [← filter_eq_range_blockIndex] at this
    simp only [Finset.mem_filter, Finset.mem_range] at this
    have : pre r k ≤ s := by
      have h1 : k - 1 + 1 = k := by omega
      rw [h1] at this; exact this.2
    simp [total] at hs
    omega

lemma blockIndex_le {r : ℕ → ℕ} {k s : ℕ} : pre r (blockIndex r k s) ≤ s := by
  rcases Nat.eq_zero_or_pos (blockIndex r k s) with h | h
  · rw [h]; simp [pre]
  · have : (blockIndex r k s - 1) ∈ Finset.range (blockIndex r k s) := by simp; omega
    rw [← filter_eq_range_blockIndex] at this
    simp only [Finset.mem_filter, Finset.mem_range] at this
    have h1 : blockIndex r k s - 1 + 1 = blockIndex r k s := by omega
    rw [h1] at this
    exact this.2

lemma blockIndex_gt {r : ℕ → ℕ} {k s : ℕ} (hs : s < total r k) :
    s < pre r (blockIndex r k s + 1) := by
  have hlt := blockIndex_lt hs
  have : (blockIndex r k s) ∉ Finset.range (blockIndex r k s) := by simp
  rw [← filter_eq_range_blockIndex] at this
  simp only [Finset.mem_filter, Finset.mem_range, not_and, not_le] at this
  exact this hlt

lemma blockIndex_unique {r : ℕ → ℕ} {k s i : ℕ} (hs : s < total r k)
    (h1 : pre r i ≤ s) (h2 : s < pre r (i + 1)) : blockIndex r k s = i := by
  have hle := @blockIndex_le r k s
  have hgt := blockIndex_gt hs
  by_contra hne
  rcases Nat.lt_or_ge (blockIndex r k s) i with h | h
  · have : pre r (blockIndex r k s + 1) ≤ pre r i := pre_mono r (by omega)
    omega
  · have h' : i < blockIndex r k s := lt_of_le_of_ne h (Ne.symm hne)
    have : pre r (i + 1) ≤ pre r (blockIndex r k s) := pre_mono r (by omega)
    omega


/-! ## The block schedule and its counter -/

def owner (r : ℕ → ℕ) (k t : ℕ) : ℕ := blockIndex r k (t % total r k)

def schedCnt (s : ℕ → ℕ) (i t : ℕ) : ℕ :=
  ((Finset.range t).filter (fun u => s u = i)).card

def cnt (r : ℕ → ℕ) (k i t : ℕ) : ℕ := schedCnt (owner r k) i t

lemma schedCnt_succ (s : ℕ → ℕ) (i t : ℕ) :
    schedCnt s i (t + 1) = schedCnt s i t + (if s t = i then 1 else 0) := by
  unfold schedCnt
  rw [Finset.range_add_one, Finset.filter_insert]
  by_cases h : s t = i
  · rw [if_pos h, Finset.card_insert_of_notMem (by simp)]
    simp [h]
  · rw [if_neg h, if_neg h]
    simp

lemma schedCnt_mono (s : ℕ → ℕ) (i : ℕ) : Monotone (schedCnt s i) := by
  intro a b hab
  exact Finset.card_le_card (Finset.filter_subset_filter _
    (fun x hx => Finset.mem_range.mpr (lt_of_lt_of_le (Finset.mem_range.mp hx) hab)))

lemma owner_eq_iff {r : ℕ → ℕ} {k i t : ℕ} (hk : 0 < total r k) :
    owner r k t = i ↔ (pre r i ≤ t % total r k ∧ t % total r k < pre r (i + 1)) := by
  have hs : t % total r k < total r k := Nat.mod_lt _ hk
  constructor
  · intro h
    subst h
    exact ⟨blockIndex_le, blockIndex_gt hs⟩
  · intro ⟨h1, h2⟩
    exact blockIndex_unique hs h1 h2

theorem cnt_eq {r : ℕ → ℕ} {k i : ℕ} (hk : 0 < total r k) (hi : i < k) (t : ℕ) :
    cnt r k i t =
      (t / total r k) * r i + min (r i) (t % total r k - pre r i) := by
  induction t with
  | zero => simp [cnt, schedCnt, pre]
  | succ t ih =>
      have hstep : cnt r k i (t + 1) = cnt r k i t + (if owner r k t = i then 1 else 0) :=
        schedCnt_succ _ _ _
      have hown := @owner_eq_iff r k i t hk
      have h1 : pre r (i + 1) = pre r i + r i := pre_succ r i
      have h2 : pre r i + r i ≤ total r k := by
        have := @pre_le_total r k (i + 1) hi
        omega
      have hmod : t % total r k < total r k := Nat.mod_lt _ hk
      have hdm : total r k * (t / total r k) + t % total r k = t := Nat.div_add_mod t _
      rcases Nat.lt_or_ge (t % total r k + 1) (total r k) with hc | hc
      · -- stay inside the current period
        have he : t + 1 = total r k * (t / total r k) + (t % total r k + 1) := by omega
        have hd : (t + 1) / total r k = t / total r k := by
          rw [he, Nat.mul_add_div hk]
          simp [Nat.div_eq_of_lt hc]
        have hm : (t + 1) % total r k = t % total r k + 1 := by
          rw [he, Nat.mul_add_mod]
          exact Nat.mod_eq_of_lt hc
        rw [hstep, ih, hd, hm]
        by_cases hcase : pre r i ≤ t % total r k ∧ t % total r k < pre r (i + 1)
        · rw [if_pos (hown.mpr hcase)]
          omega
        · rw [if_neg (fun h => hcase (hown.mp h))]
          omega
      · -- last slot of the current period
        have hc' : t % total r k + 1 = total r k := by omega
        have he : t + 1 = total r k * (t / total r k + 1) := by
          rw [Nat.mul_add]; omega
        have hd : (t + 1) / total r k = t / total r k + 1 := by
          rw [he, Nat.mul_div_cancel_left _ hk]
        have hm : (t + 1) % total r k = 0 := by
          rw [he]; exact Nat.mul_mod_right _ _
        rw [hstep, ih, hd, hm, Nat.add_mul]
        by_cases hcase : pre r i ≤ t % total r k ∧ t % total r k < pre r (i + 1)
        · rw [if_pos (hown.mpr hcase)]
          simp only [Nat.zero_sub]
          omega
        · rw [if_neg (fun h => hcase (hown.mp h))]
          simp only [Nat.zero_sub]
          omega


/-! ## Fairness corollaries -/

theorem cnt_period_multiple {r : ℕ → ℕ} {k i : ℕ} (hk : 0 < total r k) (hi : i < k) (n : ℕ) :
    cnt r k i (n * total r k) = n * r i := by
  have hd : n * total r k / total r k = n := by
    rw [Nat.mul_div_assoc _ (dvd_refl _), Nat.div_self hk, Nat.mul_one]
  have hm : n * total r k % total r k = 0 := Nat.mul_mod_left n _
  rw [cnt_eq hk hi, hd, hm]
  simp

/-- Arithmetic core of the discrepancy bounds, isolated over `ℤ`. -/
lemma disc_core {R a P s q c : ℤ} (ha : 0 ≤ a) (hP : 0 ≤ P) (hs0 : 0 ≤ s)
    (hsR : s < R) (hPa : P + a ≤ R) (hc : c = 0 ∧ s ≤ P ∨ c = s - P ∧ P ≤ s ∧ s ≤ P + a ∨
      c = a ∧ P + a ≤ s) :
    -(a * P) ≤ R * (q * a + c) - a * (R * q + s) ∧
      R * (q * a + c) - a * (R * q + s) ≤ a * (R - (P + a)) := by
  rcases hc with ⟨hc0, hsP⟩ | ⟨hc0, hsP1, hsP2⟩ | ⟨hc0, hsP⟩ <;> subst hc0 <;>
    constructor <;> nlinarith [ha, hP, hs0, hsR, hPa]

/-- The two-sided **sharp** discrepancy bound for the block schedule: the lag of a client
is at most its rate times the prefix mass before it, and its lead is at most its rate
times the suffix mass after it. -/
theorem cnt_disc {r : ℕ → ℕ} {k i : ℕ} (hk : 0 < total r k) (hi : i < k) (t : ℕ) :
    -((r i : ℤ) * (pre r i : ℤ)) ≤ (total r k : ℤ) * cnt r k i t - (r i : ℤ) * t ∧
      (total r k : ℤ) * cnt r k i t - (r i : ℤ) * t
        ≤ (r i : ℤ) * ((total r k : ℤ) - (pre r (i + 1) : ℤ)) := by
  have h1 : pre r (i + 1) = pre r i + r i := pre_succ r i
  have h2 : pre r i + r i ≤ total r k := by
    have := @pre_le_total r k (i + 1) hi; omega
  have hmod : t % total r k < total r k := Nat.mod_lt _ hk
  have hdm : total r k * (t / total r k) + t % total r k = t := Nat.div_add_mod t _
  have hR : (0:ℤ) < (total r k : ℤ) := by exact_mod_cast hk
  have ha0 : (0:ℤ) ≤ (r i : ℤ) := Int.natCast_nonneg _
  have hP0 : (0:ℤ) ≤ (pre r i : ℤ) := Int.natCast_nonneg _
  have hs0 : (0:ℤ) ≤ ((t % total r k : ℕ) : ℤ) := Int.natCast_nonneg _
  have hsR : ((t % total r k : ℕ) : ℤ) < (total r k : ℤ) := by exact_mod_cast hmod
  have hPa : (pre r i : ℤ) + (r i : ℤ) ≤ (total r k : ℤ) := by exact_mod_cast h2
  have ht : (total r k : ℤ) * ((t / total r k : ℕ) : ℤ) + ((t % total r k : ℕ) : ℤ) = (t : ℤ) := by
    exact_mod_cast hdm
  have hP1 : ((pre r (i + 1) : ℕ) : ℤ) = (pre r i : ℤ) + (r i : ℤ) := by exact_mod_cast h1
  obtain ⟨m, hm⟩ : ∃ m, min (r i) (t % total r k - pre r i) = m := ⟨_, rfl⟩
  have hcase :
      ((min (r i) (t % total r k - pre r i) : ℕ) : ℤ) = 0 ∧
          ((t % total r k : ℕ) : ℤ) ≤ (pre r i : ℤ) ∨
      ((min (r i) (t % total r k - pre r i) : ℕ) : ℤ)
            = ((t % total r k : ℕ) : ℤ) - (pre r i : ℤ) ∧
          (pre r i : ℤ) ≤ ((t % total r k : ℕ) : ℤ) ∧
          ((t % total r k : ℕ) : ℤ) ≤ (pre r i : ℤ) + (r i : ℤ) ∨
      ((min (r i) (t % total r k - pre r i) : ℕ) : ℤ) = (r i : ℤ) ∧
          (pre r i : ℤ) + (r i : ℤ) ≤ ((t % total r k : ℕ) : ℤ) := by
    rcases Nat.lt_or_ge (t % total r k) (pre r i) with hc | hc
    · left
      constructor
      · have : min (r i) (t % total r k - pre r i) = 0 := by omega
        rw [this]; simp
      · exact_mod_cast Nat.le_of_lt hc
    · rcases Nat.lt_or_ge (t % total r k) (pre r i + r i) with hc2 | hc2
      · right; left
        refine ⟨?_, by exact_mod_cast hc, by exact_mod_cast Nat.le_of_lt hc2⟩
        have hmin : min (r i) (t % total r k - pre r i) = t % total r k - pre r i := by omega
        rw [hmin]
        omega
      · right; right
        refine ⟨?_, by exact_mod_cast hc2⟩
        have hmin : min (r i) (t % total r k - pre r i) = r i := by omega
        rw [hmin]
  rw [hm] at hcase
  have key := disc_core (q := ((t / total r k : ℕ) : ℤ)) (c := (m : ℤ)) ha0 hP0 hs0 hsR hPa
    hcase
  rw [ht] at key
  rw [cnt_eq hk hi, hm, hP1, Nat.cast_add, Nat.cast_mul]
  exact key

theorem cnt_disc_lower {r : ℕ → ℕ} {k i : ℕ} (hk : 0 < total r k) (hi : i < k) (t : ℕ) :
    -((r i : ℤ) * (pre r i : ℤ)) ≤ (total r k : ℤ) * cnt r k i t - (r i : ℤ) * t :=
  (cnt_disc hk hi t).1

theorem cnt_disc_upper {r : ℕ → ℕ} {k i : ℕ} (hk : 0 < total r k) (hi : i < k) (t : ℕ) :
    (total r k : ℤ) * cnt r k i t - (r i : ℤ) * t
      ≤ (r i : ℤ) * ((total r k : ℤ) - (pre r (i + 1) : ℤ)) :=
  (cnt_disc hk hi t).2


/-! ## Sharpness, exactness and no starvation -/

lemma r_le_total {r : ℕ → ℕ} {k i : ℕ} (hi : i < k) : r i ≤ total r k := by
  have h := @pre_le_total r k (i + 1) hi
  have := pre_succ r i
  omega

lemma cnt_at_block_start {r : ℕ → ℕ} {k i : ℕ} (hk : 0 < total r k) (hi : i < k) :
    cnt r k i (pre r i) = 0 := by
  have h2 : pre r i + r i ≤ total r k := by
    have := @pre_le_total r k (i + 1) hi
    have := pre_succ r i
    omega
  have hlt : pre r i < total r k ∨ pre r i = total r k := by omega
  rcases hlt with hlt | heq
  · rw [cnt_eq hk hi, Nat.div_eq_of_lt hlt, Nat.mod_eq_of_lt hlt]
    simp
  · rw [cnt_eq hk hi, heq, Nat.div_self hk, Nat.mod_self]
    simp
    omega

lemma cnt_at_block_end {r : ℕ → ℕ} {k i : ℕ} (hk : 0 < total r k) (hi : i < k) :
    cnt r k i (pre r (i + 1)) = r i := by
  have hps := pre_succ r i
  have h2 : pre r i + r i ≤ total r k := by
    have := @pre_le_total r k (i + 1) hi; omega
  rcases Nat.lt_or_ge (pre r (i + 1)) (total r k) with hlt | hge
  · rw [cnt_eq hk hi, Nat.div_eq_of_lt hlt, Nat.mod_eq_of_lt hlt]
    omega
  · have heq : pre r (i + 1) = total r k := by omega
    rw [heq]
    have := cnt_period_multiple hk hi 1
    rwa [one_mul, one_mul] at this

/-- The lower discrepancy bound is attained at the first slot of the block of client `i`. -/
theorem cnt_disc_lower_sharp {r : ℕ → ℕ} {k i : ℕ} (hk : 0 < total r k) (hi : i < k) :
    (total r k : ℤ) * cnt r k i (pre r i) - (r i : ℤ) * (pre r i : ℤ)
      = -((r i : ℤ) * (pre r i : ℤ)) := by
  rw [cnt_at_block_start hk hi]
  simp

/-- The upper discrepancy bound is attained at the last slot of the block of client `i`. -/
theorem cnt_disc_upper_sharp {r : ℕ → ℕ} {k i : ℕ} (hk : 0 < total r k) (hi : i < k) :
    (total r k : ℤ) * cnt r k i (pre r (i + 1)) - (r i : ℤ) * (pre r (i + 1) : ℤ)
      = (r i : ℤ) * ((total r k : ℤ) - (pre r (i + 1) : ℤ)) := by
  rw [cnt_at_block_end hk hi]
  ring

lemma cnt_period_shift {r : ℕ → ℕ} {k i : ℕ} (hk : 0 < total r k) (hi : i < k) (t : ℕ) :
    cnt r k i (t + total r k) = cnt r k i t + r i := by
  rw [cnt_eq hk hi, cnt_eq hk hi, Nat.add_div_right _ hk, Nat.add_mod_right]
  ring

lemma exists_of_schedCnt_lt {f : ℕ → ℕ} {i a b : ℕ} (h : schedCnt f i a < schedCnt f i b) :
    ∃ s, a ≤ s ∧ s < b ∧ f s = i := by
  by_contra hcon
  push_neg at hcon
  have hsub : (Finset.range b).filter (fun u => f u = i) ⊆
      (Finset.range a).filter (fun u => f u = i) := by
    intro x hx
    simp only [Finset.mem_filter, Finset.mem_range] at hx ⊢
    refine ⟨?_, hx.2⟩
    by_contra hxa
    exact absurd hx.2 (hcon x (by omega) hx.1)
  exact absurd (Finset.card_le_card hsub) (by simpa [schedCnt] using Nat.not_le.mpr h)

/-- **No starvation.**  Every client with a positive rate is served at least once in every
window of `total r k` consecutive slots. -/
theorem exists_service_in_window {r : ℕ → ℕ} {k i : ℕ} (hk : 0 < total r k) (hi : i < k)
    (hri : 0 < r i) (t : ℕ) :
    ∃ s, t ≤ s ∧ s < t + total r k ∧ owner r k s = i := by
  apply exists_of_schedCnt_lt (f := owner r k) (i := i) (a := t) (b := t + total r k)
  have := cnt_period_shift hk hi t
  simp only [cnt] at this
  omega

/-- For at least two clients, the block schedule realises the exact rates **precisely** at
the multiples of the period. -/
theorem cnt_exact_iff_period {r : ℕ → ℕ} {k : ℕ} (hpos : ∀ j < k, 0 < r j) (hk2 : 2 ≤ k)
    (t : ℕ) :
    (∀ i < k, total r k * cnt r k i t = r i * t) ↔ total r k ∣ t := by
  have h0 : 0 < r 0 := hpos 0 (by omega)
  have h1 : 0 < r 1 := hpos 1 (by omega)
  have hpair : r 0 + r 1 ≤ total r k := by
    have h := @pre_le_total r k 2 hk2
    have e1 : pre r 1 = r 0 := by simp [pre]
    have e2 : pre r 2 = pre r 1 + r 1 := pre_succ r 1
    omega
  have hk : 0 < total r k := by omega
  constructor
  · intro h
    have h' := h 0 (by omega)
    rw [cnt_eq hk (by omega : 0 < k)] at h'
    have hdm : total r k * (t / total r k) + t % total r k = t := Nat.div_add_mod t _
    have hmod : t % total r k < total r k := Nat.mod_lt _ hk
    have hpre0 : pre r 0 = 0 := by simp [pre]
    rw [hpre0, Nat.sub_zero] at h'
    -- `h'` says `R * (q * r 0 + min (r 0) s) = r 0 * (R * q + s)`, i.e. `R * min (r 0) s = r 0 * s`
    have hkey : total r k * min (r 0) (t % total r k) = r 0 * (t % total r k) := by
      nlinarith [h', hdm]
    rcases Nat.eq_zero_or_pos (t % total r k) with hs | hs
    · exact Nat.dvd_of_mod_eq_zero hs
    · exfalso
      rcases Nat.le_total (t % total r k) (r 0) with hc | hc
      · rw [min_eq_right hc] at hkey
        have : total r k = r 0 := Nat.eq_of_mul_eq_mul_right hs hkey
        omega
      · rw [min_eq_left hc] at hkey
        have : total r k = t % total r k := Nat.eq_of_mul_eq_mul_left h0 (by linarith [hkey])
        omega
  · rintro ⟨n, rfl⟩
    intro i hi
    rw [mul_comm (total r k) n, cnt_period_multiple hk hi]
    ring


/-! ## Fairness as a boundedness property -/

/-- A schedule `f` is `B`-fair for the profile `(r, k)` if the deviation of every client's
service count from its ideal share never exceeds `B / total r k`. -/
def IsFair (f : ℕ → ℕ) (r : ℕ → ℕ) (k B : ℕ) : Prop :=
  ∀ i < k, ∀ t, |(total r k : ℤ) * schedCnt f i t - (r i : ℤ) * t| ≤ (B : ℤ)

theorem cnt_disc_abs {r : ℕ → ℕ} {k i : ℕ} (hk : 0 < total r k) (hi : i < k) (t : ℕ) :
    |(total r k : ℤ) * cnt r k i t - (r i : ℤ) * t| ≤ (r i : ℤ) * ((total r k : ℤ) - r i) := by
  have hlo := cnt_disc_lower hk hi t
  have hup := cnt_disc_upper hk hi t
  have hps : ((pre r (i + 1) : ℕ) : ℤ) = (pre r i : ℤ) + (r i : ℤ) := by
    exact_mod_cast pre_succ r i
  have h2 : (pre r i : ℤ) + (r i : ℤ) ≤ (total r k : ℤ) := by
    have h := @pre_le_total r k (i + 1) hi
    have := pre_succ r i
    exact_mod_cast (by omega : pre r i + r i ≤ total r k)
  have ha0 : (0:ℤ) ≤ (r i : ℤ) := Int.natCast_nonneg _
  have hP0 : (0:ℤ) ≤ (pre r i : ℤ) := Int.natCast_nonneg _
  rw [hps] at hup
  rw [abs_le]
  constructor <;> nlinarith [hlo, hup, ha0, hP0, h2]

/-- The block schedule is fair with the bound `max_i r i * (R - r i)`. -/
theorem block_isFair {r : ℕ → ℕ} {k : ℕ} (hk : 0 < total r k) :
    IsFair (owner r k) r k ((Finset.range k).sup fun i => r i * (total r k - r i)) := by
  intro i hi t
  have h := cnt_disc_abs hk hi t
  have hle : r i * (total r k - r i) ≤ (Finset.range k).sup fun i => r i * (total r k - r i) :=
    Finset.le_sup (f := fun i => r i * (total r k - r i)) (Finset.mem_range.mpr hi)
  have hcast : ((r i * (total r k - r i) : ℕ) : ℤ) = (r i : ℤ) * ((total r k : ℤ) - r i) := by
    have : r i ≤ total r k := r_le_total hi
    push_cast [Nat.cast_sub this]
    ring
  have : ((r i * (total r k - r i) : ℕ) : ℤ) ≤
      (((Finset.range k).sup fun i => r i * (total r k - r i) : ℕ) : ℤ) := by
    exact_mod_cast hle
  simp only [cnt] at h
  rw [hcast] at this
  exact le_trans h this

/-! ## Bresenham (Beatty) schedule for two clients -/

def bres (a R t : ℕ) : ℕ := if t * a / R < (t + 1) * a / R then 0 else 1

def twoProfile (a R : ℕ) : ℕ → ℕ := fun j => if j = 0 then a else R - a

lemma bres_eq_zero_or_one (a R t : ℕ) : bres a R t = 0 ∨ bres a R t = 1 := by
  unfold bres; split <;> simp

lemma schedCnt_two (f : ℕ → ℕ) (hf : ∀ t, f t = 0 ∨ f t = 1) (t : ℕ) :
    schedCnt f 0 t + schedCnt f 1 t = t := by
  induction t with
  | zero => simp [schedCnt]
  | succ t ih =>
      rw [schedCnt_succ, schedCnt_succ]
      rcases hf t with h | h <;> rw [h] <;> simp <;> omega

lemma bres_step {a R : ℕ} (ha : a ≤ R) (hR : 0 < R) (t : ℕ) :
    (t + 1) * a / R ≤ t * a / R + 1 := by
  have h1 : (t + 1) * a ≤ t * a + R := by
    have : (t + 1) * a = t * a + a := by ring
    omega
  calc (t + 1) * a / R ≤ (t * a + R) / R := Nat.div_le_div_right h1
    _ = t * a / R + 1 := Nat.add_div_right _ hR

theorem bres_cnt0 {a R : ℕ} (ha : a ≤ R) (hR : 0 < R) (t : ℕ) :
    schedCnt (bres a R) 0 t = t * a / R := by
  induction t with
  | zero => simp [schedCnt]
  | succ t ih =>
      rw [schedCnt_succ, ih]
      by_cases h : t * a / R < (t + 1) * a / R
      · have : bres a R t = 0 := by unfold bres; rw [if_pos h]
        rw [this]
        have := bres_step ha hR t
        simp
        omega
      · have hb : bres a R t = 1 := by unfold bres; rw [if_neg h]
        rw [hb]
        have hmono : t * a / R ≤ (t + 1) * a / R :=
          Nat.div_le_div_right (Nat.mul_le_mul_right a (by omega))
        simp
        omega

theorem bres_cnt1 {a R : ℕ} (ha : a ≤ R) (hR : 0 < R) (t : ℕ) :
    schedCnt (bres a R) 1 t = t - t * a / R := by
  have h := schedCnt_two (bres a R) (bres_eq_zero_or_one a R) t
  rw [bres_cnt0 ha hR] at h
  omega

lemma total_twoProfile {a R : ℕ} (ha : a ≤ R) : total (twoProfile a R) 2 = R := by
  simp [total, pre, Finset.sum_range_succ, twoProfile]
  omega

lemma pre_twoProfile_one {a R : ℕ} : pre (twoProfile a R) 1 = a := by
  simp [pre, twoProfile]

/-- **Unit discrepancy for two clients.**  The Bresenham schedule is `(R-1)`-fair, i.e. every
client's service count stays within one unit of its ideal share. -/
theorem bres_isFair {a R : ℕ} (ha : a ≤ R) (hR : 0 < R) :
    IsFair (bres a R) (twoProfile a R) 2 (R - 1) := by
  intro i hi t
  have hdm : R * (t * a / R) + (t * a) % R = t * a := Nat.div_add_mod _ _
  have hmod : (t * a) % R < R := Nat.mod_lt _ hR
  have hdle : t * a / R ≤ t := by
    calc t * a / R ≤ t * R / R := Nat.div_le_div_right (Nat.mul_le_mul_left t ha)
      _ = t := by rw [Nat.mul_div_cancel _ hR]
  rw [total_twoProfile ha]
  have hRm : ((R - 1 : ℕ) : ℤ) = (R : ℤ) - 1 := by
    have : (1:ℕ) ≤ R := hR
    push_cast [Nat.cast_sub this]
    ring
  rw [hRm]
  have hi2 : i = 0 ∨ i = 1 := by omega
  rcases hi2 with rfl | rfl
  · rw [bres_cnt0 ha hR]
    have h0 : twoProfile a R 0 = a := by simp [twoProfile]
    rw [h0, abs_le]
    have h1 : (R : ℤ) * ((t * a / R : ℕ) : ℤ) + (((t * a) % R : ℕ) : ℤ) = (t : ℤ) * a := by
      exact_mod_cast hdm
    have h2 : (((t * a) % R : ℕ) : ℤ) < (R : ℤ) := by exact_mod_cast hmod
    have h3 : (0:ℤ) ≤ (((t * a) % R : ℕ) : ℤ) := Int.natCast_nonneg _
    constructor <;> linarith
  · rw [bres_cnt1 ha hR]
    have h1 : twoProfile a R 1 = R - a := by simp [twoProfile]
    rw [h1, abs_le]
    have hc1 : ((t - t * a / R : ℕ) : ℤ) = (t : ℤ) - ((t * a / R : ℕ) : ℤ) := by
      push_cast [Nat.cast_sub hdle]; ring
    have hc2 : ((R - a : ℕ) : ℤ) = (R : ℤ) - a := by push_cast [Nat.cast_sub ha]; ring
    rw [hc1, hc2]
    have h2 : (R : ℤ) * ((t * a / R : ℕ) : ℤ) + (((t * a) % R : ℕ) : ℤ) = (t : ℤ) * a := by
      exact_mod_cast hdm
    have h3 : (((t * a) % R : ℕ) : ℤ) < (R : ℤ) := by exact_mod_cast hmod
    have h4 : (0:ℤ) ≤ (((t * a) % R : ℕ) : ℤ) := Int.natCast_nonneg _
    constructor <;> nlinarith [h2, h3, h4]


/-! ## Separation: the block schedule is not unit-fair -/

lemma total_const {c : ℕ} : total (fun _ => c) 2 = 2 * c := by
  simp [total, pre]

lemma pre_const_one {c : ℕ} : pre (fun _ => c) 1 = c := by simp [pre]

lemma twoProfile_const {c : ℕ} : twoProfile c (2 * c) = fun _ => c := by
  funext j
  simp only [twoProfile]
  split <;> omega

/-- **Separation.**  For the balanced two-client profile `(c, c)` with `c ≥ 2`, the Bresenham
schedule keeps every client within one unit of its ideal share, while the exact-rate block
schedule does not: at the end of the first block, client `1` is `c/2` services behind. -/
theorem bres_fair_block_unfair {c : ℕ} (hc : 2 ≤ c) :
    IsFair (bres c (2 * c)) (fun _ => c) 2 (total (fun _ => c) 2 - 1) ∧
      ¬ IsFair (owner (fun _ => c) 2) (fun _ => c) 2 (total (fun _ => c) 2 - 1) := by
  have hk : 0 < total (fun _ => c) 2 := by rw [total_const]; omega
  constructor
  · have h := bres_isFair (a := c) (R := 2 * c) (by omega) (by omega)
    rw [twoProfile_const] at h
    rw [total_const]
    exact h
  · intro hfair
    have h := hfair 1 (by omega) (pre (fun _ => c) 1)
    rw [show schedCnt (owner (fun _ => c) 2) 1 (pre (fun _ => c) 1)
        = cnt (fun _ => c) 2 1 (pre (fun _ => c) 1) from rfl,
      cnt_at_block_start hk (by omega), pre_const_one, total_const] at h
    rw [abs_le] at h
    have h1 := h.1
    have hcc : ((2 * c - 1 : ℕ) : ℤ) = 2 * (c:ℤ) - 1 := by
      have : (1:ℕ) ≤ 2 * c := by omega
      push_cast [Nat.cast_sub this]
      ring
    rw [hcc] at h1
    have hc' : (2:ℤ) ≤ (c:ℤ) := by exact_mod_cast hc
    push_cast at h1
    nlinarith [h1, hc']

/-! ## Nested prefix floors: valid for two clients, impossible for three -/

/-- The candidate "multi-dimensional Bresenham" counter obtained by differencing the floors
of the scaled prefix sums. -/
def nestCnt (r : ℕ → ℕ) (k i t : ℕ) : ℕ :=
  t * pre r (i + 1) / total r k - t * pre r i / total r k

/-- For two clients the nested-floor counter is realised by the Bresenham schedule. -/
theorem nestCnt_eq_bres {a R : ℕ} (ha : a ≤ R) (hR : 0 < R) (i : ℕ) (hi : i < 2) (t : ℕ) :
    schedCnt (bres a R) i t = nestCnt (twoProfile a R) 2 i t := by
  have hi2 : i = 0 ∨ i = 1 := by omega
  have htot : total (twoProfile a R) 2 = R := total_twoProfile ha
  have hdle : t * a / R ≤ t := by
    calc t * a / R ≤ t * R / R := Nat.div_le_div_right (Nat.mul_le_mul_left t ha)
      _ = t := by rw [Nat.mul_div_cancel _ hR]
  rcases hi2 with rfl | rfl
  · rw [bres_cnt0 ha hR, nestCnt, htot, pre_twoProfile_one]
    simp [pre]
  · rw [bres_cnt1 ha hR]
    have h1 : pre (twoProfile a R) 2 = R := by
      simp only [pre, Finset.sum_range_succ, twoProfile]
      norm_num
      omega
    rw [nestCnt, h1, htot, pre_twoProfile_one, Nat.mul_div_cancel _ hR]

/-- **Obstruction.**  For three clients the nested-floor counter is *not* the counter of any
schedule: for the profile `(3,1,3)` the candidate count of the middle client drops from `1`
at time `2` to `0` at time `3`, whereas service counters are monotone. -/
theorem nested_floor_not_schedulable :
    ∃ (r : ℕ → ℕ) (k : ℕ), (∀ j < k, 0 < r j) ∧
      ¬ ∃ f : ℕ → ℕ, ∀ i < k, ∀ t, schedCnt f i t = nestCnt r k i t := by
  refine ⟨fun j => if j = 1 then 1 else 3, 3, ?_, ?_⟩
  · intro j _
    by_cases hj : j = 1 <;> simp [hj]
  · rintro ⟨f, hf⟩
    have htot : total (fun j => if j = 1 then 1 else 3) 3 = 7 := by
      simp [total, pre, Finset.sum_range_succ]
    have h2 : nestCnt (fun j => if j = 1 then 1 else 3) 3 1 2 = 1 := by
      simp [nestCnt, htot, pre, Finset.sum_range_succ]
    have h3 : nestCnt (fun j => if j = 1 then 1 else 3) 3 1 3 = 0 := by
      simp [nestCnt, htot, pre, Finset.sum_range_succ]
    have hm := schedCnt_mono f 1 (show (2:ℕ) ≤ 3 by omega)
    rw [hf 1 (by omega) 2, hf 1 (by omega) 3, h2, h3] at hm
    omega

/-! ## No schedule is exact -/

lemma pair_le_total {r : ℕ → ℕ} {k i j : ℕ} (hi : i < k) (hj : j < k) (hij : i ≠ j) :
    r i + r j ≤ total r k := by
  have hsub : ({i, j} : Finset ℕ) ⊆ Finset.range k := by
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_singleton] at hx
    rcases hx with rfl | rfl <;> simpa using ‹_›
  have := Finset.sum_le_sum_of_subset (f := r) hsub
  rwa [Finset.sum_pair hij] at this

/-- **No exact schedule.**  With two or more clients of positive rate, no schedule can meet
every client's exact rate at every time; period-boundary exactness (`cnt_period_multiple`) is
therefore optimal. -/
theorem no_exact_schedule {r : ℕ → ℕ} {k : ℕ} (hpos : ∀ j < k, 0 < r j) (hk2 : 2 ≤ k) :
    ¬ ∃ f : ℕ → ℕ, (∀ t, f t < k) ∧
      ∀ i < k, ∀ t, total r k * schedCnt f i t = r i * t := by
  rintro ⟨f, hf, hex⟩
  have hfil : (Finset.range 1).filter (fun u => f u = f 0) = Finset.range 1 := by
    apply Finset.filter_true_of_mem
    intro x hx
    simp only [Finset.mem_range, Nat.lt_one_iff] at hx
    rw [hx]
  have h1 : schedCnt f (f 0) 1 = 1 := by
    unfold schedCnt
    rw [hfil]
    simp
  have hR := hex (f 0) (hf 0) 1
  rw [h1, mul_one, mul_one] at hR
  obtain ⟨j, hjk, hne⟩ : ∃ j, j < k ∧ f 0 ≠ j := by
    by_cases hf0 : f 0 = 0
    · exact ⟨1, by omega, by omega⟩
    · exact ⟨0, by omega, hf0⟩
  have hpair := pair_le_total (r := r) (hf 0) hjk hne
  have := hpos j hjk
  omega

end FairSchedule