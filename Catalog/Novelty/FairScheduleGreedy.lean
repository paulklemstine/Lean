/-
# The greedy largest-lag schedule

`Novelty.FairSchedulePrefixBatches` builds the exact-rate block schedule from the prefix sums
of a rate profile and shows that it can be `Θ(R)` services away from the ideal share, and
`Novelty.FairScheduleBalancedTrees` gives an explicit schedule of normalised discrepancy
`⌈log₂ k⌉` for any profile.  This file analyses the *online* alternative: at each slot serve
the client whose lag after the slot would be largest.

The main results are

* `glag_lower` : the greedy schedule **never lets a client run a full period ahead** — the
  lead `R · count_i(t) - r_i · t` is at most `R - 1`, i.e. normalised lead `< 1`, for every
  client count, every positive rate profile and every time;
* `glag_upper` / `greedy_isFair` : since the lags sum to zero, no client is ever more than
  `(k-1)(R-1)` behind, so the greedy schedule is `(k-1)(R-1)`-fair;
* `greedy_block_overshoot_separation` : the block schedule violates the `R - 1` lead bound
  already for the two-client profile `(c, c)` with `c ≥ 2`.

The engine of the lead bound is `one_le_obj_greedy`: the greedy objective values sum to `R`
over the `k` clients, so their maximum is at least `1`, and the served client's lag therefore
never drops below `1 - R`.
-/
import Novelty.FairSchedulePrefixBatches
import Mathlib.Algebra.BigOperators.Ring.Finset

namespace FairSchedule

/-- Index of a maximiser of `f` over `{0, …, n-1}` (returns `0` when `n = 0`). -/
def argmaxRange (f : ℕ → ℤ) : ℕ → ℕ
  | 0 => 0
  | n + 1 => if f (argmaxRange f n) < f n then n else argmaxRange f n

lemma argmaxRange_lt (f : ℕ → ℤ) {n : ℕ} (hn : 0 < n) : argmaxRange f n < n := by
  induction n with
  | zero => omega
  | succ n ih =>
      rw [argmaxRange]
      split
      · omega
      · rcases Nat.eq_zero_or_pos n with h | h
        · subst h; simp [argmaxRange]
        · exact lt_trans (ih h) (by omega)

lemma le_argmaxRange (f : ℕ → ℤ) {i n : ℕ} (h : i < n) : f i ≤ f (argmaxRange f n) := by
  induction n with
  | zero => omega
  | succ n ih =>
      rw [argmaxRange]
      rcases Nat.lt_succ_iff_lt_or_eq.mp h with h' | h'
      · split
        · exact le_trans (ih h') (le_of_lt ‹_›)
        · exact ih h'
      · subst h'
        split
        · exact le_refl _
        · omega

/-- The counter state of the greedy *largest-lag* schedule after `t` slots. -/
def gcnt (r : ℕ → ℕ) (k : ℕ) : ℕ → ℕ → ℕ
  | 0 => fun _ => 0
  | t + 1 =>
      let c := gcnt r k t
      let p := argmaxRange (fun i => (r i : ℤ) * (t + 1) - (total r k : ℤ) * c i) k
      fun i => if i = p then c i + 1 else c i

/-- The greedy *largest-lag* schedule: serve the client whose lag after the slot would be
largest. -/
def greedy (r : ℕ → ℕ) (k t : ℕ) : ℕ :=
  argmaxRange (fun i => (r i : ℤ) * (t + 1) - (total r k : ℤ) * gcnt r k t i) k

lemma gcnt_succ (r : ℕ → ℕ) (k t i : ℕ) :
    gcnt r k (t + 1) i = if i = greedy r k t then gcnt r k t i + 1 else gcnt r k t i := rfl

lemma greedy_lt {r : ℕ → ℕ} {k : ℕ} (hk : 0 < k) (t : ℕ) : greedy r k t < k :=
  argmaxRange_lt _ hk

lemma schedCnt_greedy (r : ℕ → ℕ) (k i t : ℕ) : schedCnt (greedy r k) i t = gcnt r k t i := by
  induction t with
  | zero => simp [schedCnt, gcnt]
  | succ t ih =>
      rw [schedCnt_succ, ih, gcnt_succ]
      by_cases h : i = greedy r k t
      · rw [if_pos h, if_pos h.symm]
      · rw [if_neg h, if_neg (fun hc => h hc.symm), Nat.add_zero]

lemma sum_gcnt (r : ℕ → ℕ) {k : ℕ} (hk : 0 < k) (t : ℕ) :
    ∑ i ∈ Finset.range k, gcnt r k t i = t := by
  induction t with
  | zero => simp [gcnt]
  | succ t ih =>
      have hp : greedy r k t ∈ Finset.range k := Finset.mem_range.mpr (greedy_lt hk t)
      have : ∀ i, gcnt r k (t + 1) i = gcnt r k t i + (if i = greedy r k t then 1 else 0) := by
        intro i
        rw [gcnt_succ]
        by_cases h : i = greedy r k t <;> simp [h]
      simp only [this, Finset.sum_add_distrib, ih]
      simp [hp]

lemma sum_r_eq_total (r : ℕ → ℕ) (k : ℕ) : ∑ i ∈ Finset.range k, r i = total r k := rfl

/-- The signed lag of client `i` at time `t` under the greedy schedule. -/
def glag (r : ℕ → ℕ) (k i t : ℕ) : ℤ := (r i : ℤ) * t - (total r k : ℤ) * gcnt r k t i

lemma sum_glag (r : ℕ → ℕ) {k : ℕ} (hk : 0 < k) (t : ℕ) :
    ∑ i ∈ Finset.range k, glag r k i t = 0 := by
  have h1 : ∑ i ∈ Finset.range k, glag r k i t
      = (∑ i ∈ Finset.range k, (r i : ℤ)) * t
        - (total r k : ℤ) * ∑ i ∈ Finset.range k, (gcnt r k t i : ℤ) := by
    simp only [glag, Finset.sum_sub_distrib, Finset.sum_mul, Finset.mul_sum]
  rw [h1]
  have h2 : ∑ i ∈ Finset.range k, (r i : ℤ) = (total r k : ℤ) := by
    rw [← Nat.cast_sum, sum_r_eq_total]
  have h3 : ∑ i ∈ Finset.range k, (gcnt r k t i : ℤ) = (t : ℤ) := by
    rw [← Nat.cast_sum, sum_gcnt r hk t]
  rw [h2, h3]
  ring

lemma glag_succ (r : ℕ → ℕ) (k i t : ℕ) :
    glag r k i (t + 1) =
      ((r i : ℤ) * ((t : ℤ) + 1) - (total r k : ℤ) * gcnt r k t i)
        - (if i = greedy r k t then (total r k : ℤ) else 0) := by
  unfold glag
  rw [gcnt_succ]
  by_cases h : i = greedy r k t
  · rw [if_pos h, if_pos h]; push_cast; ring
  · rw [if_neg h, if_neg h]; push_cast; ring

lemma obj_eq (r : ℕ → ℕ) (k t j : ℕ) :
    (r j : ℤ) * ((t : ℤ) + 1) - (total r k : ℤ) * gcnt r k t j = glag r k j t + (r j : ℤ) := by
  unfold glag; ring

lemma sum_obj (r : ℕ → ℕ) {k : ℕ} (hk : 0 < k) (t : ℕ) :
    ∑ j ∈ Finset.range k, ((r j : ℤ) * ((t : ℤ) + 1) - (total r k : ℤ) * gcnt r k t j)
      = (total r k : ℤ) := by
  rw [Finset.sum_congr rfl (fun j _ => obj_eq r k t j), Finset.sum_add_distrib,
    sum_glag r hk t, zero_add, ← Nat.cast_sum, sum_r_eq_total]

/-- At every step the greedy rule picks a client whose post-service lag is at least `1`; this
is what stops the schedule from ever overshooting by a full period. -/
lemma one_le_obj_greedy {r : ℕ → ℕ} {k : ℕ} (hk : 0 < k) (hR : 0 < total r k) (t : ℕ) :
    1 ≤ (r (greedy r k t) : ℤ) * ((t : ℤ) + 1)
          - (total r k : ℤ) * gcnt r k t (greedy r k t) := by
  by_contra hc
  push_neg at hc
  have hle : ∀ j ∈ Finset.range k,
      (r j : ℤ) * ((t : ℤ) + 1) - (total r k : ℤ) * gcnt r k t j ≤ 0 := by
    intro j hj
    have hlt : (r j : ℤ) * ((t : ℤ) + 1) - (total r k : ℤ) * gcnt r k t j
        ≤ (r (greedy r k t) : ℤ) * ((t : ℤ) + 1)
            - (total r k : ℤ) * gcnt r k t (greedy r k t) :=
      le_argmaxRange (fun i => (r i : ℤ) * ((t : ℤ) + 1) - (total r k : ℤ) * gcnt r k t i)
        (Finset.mem_range.mp hj)
    omega
  have hsum := sum_obj r hk t
  have hnp := Finset.sum_nonpos hle
  have : (1:ℤ) ≤ (total r k : ℤ) := by exact_mod_cast hR
  omega

/-- **Greedy never overshoots by a full period.**  Under the greedy largest-lag schedule no
client is ever more than `R - 1` service units ahead of its ideal share. -/
theorem glag_lower {r : ℕ → ℕ} {k : ℕ} (hk : 0 < k) (hR : 0 < total r k) (i t : ℕ) :
    -((total r k : ℤ) - 1) ≤ glag r k i t := by
  induction t generalizing i with
  | zero =>
      have : (1:ℤ) ≤ (total r k : ℤ) := by exact_mod_cast hR
      simp only [glag, gcnt, Nat.cast_zero, mul_zero, sub_zero]
      omega
  | succ t ih =>
      rw [glag_succ]
      by_cases h : i = greedy r k t
      · rw [if_pos h]
        subst h
        have := one_le_obj_greedy hk hR t
        omega
      · rw [if_neg h]
        have h1 := ih i
        have h2 : (0:ℤ) ≤ (r i : ℤ) := Int.natCast_nonneg _
        rw [obj_eq]
        omega

/-- The other side: since the lags sum to zero and none of them is below `-(R-1)`, no client
is ever more than `(k-1)(R-1)` behind. -/
theorem glag_upper {r : ℕ → ℕ} {k : ℕ} (hk : 0 < k) (hR : 0 < total r k) {i : ℕ} (hi : i < k)
    (t : ℕ) : glag r k i t ≤ ((k : ℤ) - 1) * ((total r k : ℤ) - 1) := by
  have hmem : i ∈ Finset.range k := Finset.mem_range.mpr hi
  have hsplit : glag r k i t + ∑ j ∈ (Finset.range k).erase i, glag r k j t = 0 :=
    (Finset.add_sum_erase (Finset.range k) (fun j => glag r k j t) hmem).trans (sum_glag r hk t)
  have hcard : ((Finset.range k).erase i).card = k - 1 := by
    rw [Finset.card_erase_of_mem hmem, Finset.card_range]
  have hge : ((Finset.range k).erase i).card • (-((total r k : ℤ) - 1))
      ≤ ∑ j ∈ (Finset.range k).erase i, glag r k j t :=
    Finset.card_nsmul_le_sum _ _ _ (fun j _ => glag_lower hk hR j t)
  rw [hcard, nsmul_eq_mul] at hge
  have hk1 : ((k - 1 : ℕ) : ℤ) = (k : ℤ) - 1 := by
    have : (1:ℕ) ≤ k := hk
    push_cast [Nat.cast_sub this]
    ring
  rw [hk1] at hge
  nlinarith [hge, hsplit]

/-- **The greedy largest-lag schedule is fair for every positive rate profile.** -/
theorem greedy_isFair {r : ℕ → ℕ} {k : ℕ} (hk2 : 2 ≤ k) (hR : 0 < total r k) :
    IsFair (greedy r k) r k ((k - 1) * (total r k - 1)) := by
  have hk : 0 < k := by omega
  intro i hi t
  rw [schedCnt_greedy]
  have hlo := glag_lower hk hR i t
  have hup := glag_upper hk hR hi t
  have hglag : glag r k i t = (r i : ℤ) * t - (total r k : ℤ) * gcnt r k t i := rfl
  have hcast : (((k - 1) * (total r k - 1) : ℕ) : ℤ) = ((k : ℤ) - 1) * ((total r k : ℤ) - 1) := by
    have h1 : (1:ℕ) ≤ k := hk
    have h2 : (1:ℕ) ≤ total r k := hR
    push_cast [Nat.cast_sub h1, Nat.cast_sub h2]
    ring
  rw [hcast, abs_le]
  have hk1 : (1:ℤ) ≤ (k : ℤ) - 1 := by
    have : (2:ℤ) ≤ (k : ℤ) := by exact_mod_cast hk2
    omega
  have hR1 : (0:ℤ) ≤ (total r k : ℤ) - 1 := by
    have : (1:ℤ) ≤ (total r k : ℤ) := by exact_mod_cast hR
    omega
  constructor
  · nlinarith [hup, hglag]
  · nlinarith [hlo, hglag, hk1, hR1]

/-- Restatement of `glag_lower` in the `schedCnt` language: the greedy schedule never lets a
client run a full period ahead of its ideal share. -/
theorem greedy_no_overshoot {r : ℕ → ℕ} {k : ℕ} (hk : 0 < k) (hR : 0 < total r k) (i t : ℕ) :
    (total r k : ℤ) * schedCnt (greedy r k) i t - (r i : ℤ) * t ≤ (total r k : ℤ) - 1 := by
  have h := glag_lower hk hR i t
  rw [schedCnt_greedy]
  unfold glag at h
  omega

/-- **Separation.**  For the balanced two-client profile `(c, c)` with `c ≥ 2` the greedy
schedule never overshoots by a full period, while the exact-rate block schedule overshoots by
`c²  > R - 1` at the end of the first block. -/
theorem greedy_block_overshoot_separation {c : ℕ} (hc : 2 ≤ c) :
    (∀ i t, (total (fun _ => c) 2 : ℤ) * schedCnt (greedy (fun _ => c) 2) i t - (c : ℤ) * t
        ≤ (total (fun _ => c) 2 : ℤ) - 1) ∧
      (total (fun _ => c) 2 : ℤ) - 1
        < (total (fun _ => c) 2 : ℤ) * cnt (fun _ => c) 2 0 (pre (fun _ => c) 1)
            - (c : ℤ) * (pre (fun _ => c) 1 : ℕ) := by
  have htot : total (fun _ => c) 2 = 2 * c := total_const
  have hk : 0 < total (fun _ => c) 2 := by rw [htot]; omega
  refine ⟨fun i t => greedy_no_overshoot (by omega) hk i t, ?_⟩
  rw [cnt_at_block_end hk (by omega : (0:ℕ) < 2), pre_const_one, htot]
  have hc' : (2:ℤ) ≤ (c:ℤ) := by exact_mod_cast hc
  push_cast
  nlinarith

end FairSchedule