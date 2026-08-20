/-
# Finite-sample breakdown theory of order statistics (the seed-count parity law)

This file is the mathematical engine behind the **low-tail experiment** of round NET-48.
The catalog files `Logic.KneeMedianLaw`, `Logic.KneeQuotaScaling` and
`Probability.SeedFourSeedMedian` established the three-seed picture at the `16×` cell
(knee set `{160, 224, 256}`, product point `P = 256`, median `224 = (7/8) P`) and asked what
a *fourth* seed can buy.  Two of the three answers there were about the location of the
centre.  The remaining question — *how robust is the centre?* — needs a genuine
finite-sample breakdown theory, which is what we build here, in full generality and over `ℤ`
(so that corruption is unbounded in **both** directions; over `ℕ` downward corruption is
artificially capped at `0`).

## Contents

* `IsOStat K k v` — the counting characterisation of "`v` is the `k`-th smallest of the
  sample `K`": at least `k` sample points are `≤ v`, and fewer than `k` are `≤ w` for every
  `w < v`.  `isOStat_unique` and `exists_isOStat` show this pins down a unique value for
  every feasible quota `1 ≤ k ≤ n`.
* `countLE_le_perturb` — corrupting `m` coordinates moves every counting function by at
  most `m`.  This single inequality drives everything else.
* `ostat_bounded_of_agree` — **stability.**  If at most `m` coordinates are corrupted and
  `m < k`, `k + m ≤ n`, then the `k`-th order statistic of the corrupted sample still lies
  inside the range of the *original* sample.  No amount of adversarial power in `m` such
  coordinates can move it out.
* `ostat_break_up`, `ostat_break_down` — **attacks.**  With `n - k + 1` corrupted
  coordinates the `k`-th order statistic exceeds any prescribed bound; with `k` corrupted
  coordinates it falls below any prescribed bound.  Both attacks are oblivious: they need no
  knowledge of the uncorrupted data.
* `breakdownNumber_eq` — **the exact finite-sample breakdown number**
  `bd(n, k) = min k (n - k + 1)`, sharp in both directions.
* `breakdownNumber_lowerMedian` — for the lower median `k = ⌈n/2⌉` this is `⌈n/2⌉`, and
  `lowerMedianBreakdown_even_eq_pred` / `lowerMedianBreakdown_odd_gt` give the **parity
  law**: the breakdown number is unchanged when an odd sample size is padded to the next
  even one, and strictly increases only at the next *odd* size.  Adding a fourth seed to
  three cannot improve robustness; a fifth can.  This is the formal content of "a fourth
  seed improves neither the breakdown number nor the calibration".
-/
import Mathlib

namespace Catalog.Physics.LowTail

open Finset

section General

variable {ι : Type*} [Fintype ι]

/-! ## 1.  Counting functions and order statistics -/

/-- Number of sample points at or below `w`. -/
def countLE (K : ι → ℤ) (w : ℤ) : ℕ := (univ.filter (fun i => K i ≤ w)).card

theorem countLE_mono (K : ι → ℤ) {w w' : ℤ} (h : w ≤ w') : countLE K w ≤ countLE K w' := by
  refine card_le_card ?_
  intro i hi
  simp only [mem_filter, mem_univ, true_and] at hi ⊢
  exact hi.trans h

theorem countLE_le_card (K : ι → ℤ) (w : ℤ) : countLE K w ≤ Fintype.card ι := by
  rw [countLE, ← card_univ]
  exact card_filter_le _ _

/-- `v` is the `k`-th smallest value of the sample `K` (order statistics are `1`-indexed). -/
def IsOStat (K : ι → ℤ) (k : ℕ) (v : ℤ) : Prop :=
  k ≤ countLE K v ∧ ∀ w, w < v → countLE K w < k

/-- Order statistics are unique. -/
theorem isOStat_unique {K : ι → ℤ} {k : ℕ} {v v' : ℤ} (h : IsOStat K k v)
    (h' : IsOStat K k v') : v = v' := by
  by_contra hne
  rcases lt_or_gt_of_ne hne with hlt | hlt
  · exact absurd h.1 (Nat.not_le.2 (h'.2 v hlt))
  · exact absurd h'.1 (Nat.not_le.2 (h.2 v' hlt))

/-- Every feasible quota `1 ≤ k ≤ n` is realised by an order statistic. -/
theorem exists_isOStat [Nonempty ι] (K : ι → ℤ) {k : ℕ} (hk1 : 1 ≤ k)
    (hk : k ≤ Fintype.card ι) : ∃ v, IsOStat K k v := by
  classical
  have hne : (univ : Finset ι).Nonempty := univ_nonempty
  have hbdd : ∃ b : ℤ, ∀ z : ℤ, k ≤ countLE K z → b ≤ z := by
    refine ⟨univ.inf' hne K, fun z hz => ?_⟩
    have hpos : 0 < (univ.filter (fun i => K i ≤ z)).card := lt_of_lt_of_le (by omega) hz
    obtain ⟨i, hi⟩ := card_pos.1 hpos
    simp only [mem_filter, mem_univ, true_and] at hi
    exact le_trans (inf'_le K (mem_univ i)) hi
  have hinh : ∃ z : ℤ, k ≤ countLE K z := by
    refine ⟨univ.sup' hne K, ?_⟩
    have : (univ.filter (fun i => K i ≤ univ.sup' hne K)) = univ := by
      ext i
      simp only [mem_filter, mem_univ, true_and, iff_true]
      exact le_sup' K (mem_univ i)
    rw [countLE, this, card_univ]
    exact hk
  obtain ⟨v, hv, hmin⟩ := Int.exists_least_of_bdd hbdd hinh
  refine ⟨v, hv, fun w hw => ?_⟩
  by_contra hcon
  exact absurd (hmin w (Nat.not_lt.1 hcon)) (not_le.2 hw)

variable [DecidableEq ι]

/-! ## 2.  The perturbation inequality -/

/-- **Corrupting `m` coordinates moves every counting function by at most `m`.** -/
theorem countLE_le_perturb {K K' : ι → ℤ} {S : Finset ι} (h : ∀ i ∉ S, K i = K' i) (w : ℤ) :
    countLE K w ≤ countLE K' w + S.card := by
  classical
  have hsub : univ.filter (fun i => K i ≤ w) ⊆ (univ.filter (fun i => K' i ≤ w)) ∪ S := by
    intro i hi
    simp only [mem_filter, mem_univ, true_and] at hi
    by_cases hiS : i ∈ S
    · exact mem_union_right _ hiS
    · refine mem_union_left _ ?_
      simp only [mem_filter, mem_univ, true_and]
      rwa [← h i hiS]
  calc countLE K w ≤ ((univ.filter (fun i => K' i ≤ w)) ∪ S).card := card_le_card hsub
    _ ≤ countLE K' w + S.card := card_union_le _ _

/-! ## 3.  Stability: few corruptions cannot move an order statistic out of range -/

/-- **Downward stability.**  Fewer than `k` corrupted coordinates cannot pull the `k`-th
order statistic below the minimum of the clean sample.  Only the quota `k` matters here:
the sample size is irrelevant. -/
theorem inf_le_ostat_of_agree [Nonempty ι] {K K' : ι → ℤ} {S : Finset ι}
    (hagree : ∀ i ∉ S, K i = K' i) {k : ℕ} {v : ℤ} (hv : IsOStat K' k v)
    (hlo : S.card < k) : univ.inf' univ_nonempty K ≤ v := by
  classical
  by_contra hcon
  push_neg at hcon
  have hzero : countLE K' v ≤ S.card := by
    have h0 : countLE K v = 0 := by
      simp only [countLE, card_eq_zero, filter_eq_empty_iff]
      intro i _
      exact not_le.2 (lt_of_lt_of_le hcon (inf'_le K (mem_univ i)))
    have := countLE_le_perturb (K := K') (K' := K) (S := S) (fun i hi => (hagree i hi).symm) v
    omega
  have := hv.1
  omega

/-- **Upward stability.**  If `k + S.card ≤ n` then corrupting `S` cannot push the `k`-th
order statistic above the maximum of the clean sample.  Here only the *co-quota* `n - k`
matters: the design is asymmetric, which is the source of the `min` in the breakdown
number. -/
theorem ostat_le_sup_of_agree [Nonempty ι] {K K' : ι → ℤ} {S : Finset ι}
    (hagree : ∀ i ∉ S, K i = K' i) {k : ℕ} {v : ℤ} (hv : IsOStat K' k v)
    (hhi : k + S.card ≤ Fintype.card ι) : v ≤ univ.sup' univ_nonempty K := by
  classical
  by_contra hcon
  push_neg at hcon
  have hfull : countLE K (univ.sup' univ_nonempty K) = Fintype.card ι := by
    have : (univ.filter (fun i => K i ≤ univ.sup' univ_nonempty K)) = univ := by
      ext i
      simp only [mem_filter, mem_univ, true_and, iff_true]
      exact le_sup' K (mem_univ i)
    rw [countLE, this, card_univ]
  have h1 := hv.2 _ hcon
  have h2 := countLE_le_perturb (K := K) (K' := K') (S := S) hagree
    (univ.sup' univ_nonempty K)
  omega

/-- **Stability.**  If `K'` differs from `K` only on `S`, with `S.card < k` and
`k + S.card ≤ n`, then the `k`-th order statistic of the corrupted sample `K'` still lies
between the minimum and the maximum of the *original* sample.  The adversary owns `S`
entirely and may place arbitrary values there. -/
theorem ostat_bounded_of_agree [Nonempty ι] {K K' : ι → ℤ} {S : Finset ι}
    (hagree : ∀ i ∉ S, K i = K' i) {k : ℕ} {v : ℤ} (hv : IsOStat K' k v)
    (hlo : S.card < k) (hhi : k + S.card ≤ Fintype.card ι) :
    univ.inf' univ_nonempty K ≤ v ∧ v ≤ univ.sup' univ_nonempty K :=
  ⟨inf_le_ostat_of_agree hagree hv hlo, ostat_le_sup_of_agree hagree hv hhi⟩

/-! ## 4.  Attacks: the two oblivious corruption strategies -/

/-- **Upward attack.**  Corrupting any `n - k + 1` coordinates pushes the `k`-th order
statistic above any prescribed bound.  The attack is oblivious: the corrupted values do not
depend on the clean data. -/
theorem ostat_break_up [Nonempty ι] (K : ι → ℤ) {k : ℕ} (hk1 : 1 ≤ k)
    (hk : k ≤ Fintype.card ι) (S : Finset ι) (hS : Fintype.card ι < k + S.card) (B : ℤ) :
    ∃ (K' : ι → ℤ) (v : ℤ), (∀ i ∉ S, K i = K' i) ∧ IsOStat K' k v ∧ B < v := by
  classical
  refine ⟨fun i => if i ∈ S then B + 1 else K i, ?_⟩
  obtain ⟨v, hv⟩ := exists_isOStat (K := fun i => if i ∈ S then B + 1 else K i) hk1 hk
  refine ⟨v, fun i hi => by simp [hi], hv, ?_⟩
  by_contra hcon
  push_neg at hcon
  have hsub : univ.filter (fun i => (if i ∈ S then B + 1 else K i) ≤ v) ⊆ univ \ S := by
    intro i hi
    simp only [mem_filter, mem_univ, true_and] at hi
    simp only [mem_sdiff, mem_univ, true_and]
    intro hiS
    rw [if_pos hiS] at hi
    omega
  have hcard : (univ \ S).card = Fintype.card ι - S.card := card_univ_diff S
  have := card_le_card hsub
  rw [hcard] at this
  have hk' := hv.1
  simp only [countLE] at hk'
  omega

/-- **Downward attack.**  Corrupting any `k` coordinates pushes the `k`-th order statistic
below any prescribed bound. -/
theorem ostat_break_down [Nonempty ι] (K : ι → ℤ) {k : ℕ} (hk1 : 1 ≤ k)
    (hk : k ≤ Fintype.card ι) (S : Finset ι) (hS : k ≤ S.card) (B : ℤ) :
    ∃ (K' : ι → ℤ) (v : ℤ), (∀ i ∉ S, K i = K' i) ∧ IsOStat K' k v ∧ v < B := by
  classical
  refine ⟨fun i => if i ∈ S then B - 1 else K i, ?_⟩
  obtain ⟨v, hv⟩ := exists_isOStat (K := fun i => if i ∈ S then B - 1 else K i) hk1 hk
  refine ⟨v, fun i hi => by simp [hi], hv, ?_⟩
  have hcount : k ≤ countLE (fun i => if i ∈ S then B - 1 else K i) (B - 1) := by
    refine le_trans hS (card_le_card ?_)
    intro i hi
    simp only [mem_filter, mem_univ, true_and, hi, if_pos, le_refl]
  by_contra hcon
  push_neg at hcon
  exact absurd hcount (Nat.not_le.2 (hv.2 (B - 1) (by omega)))

/-! ## 5.  The finite-sample breakdown number -/

/-- The `k`-th order statistic can be driven above every bound by corrupting at most `m`
coordinates. -/
def BreaksUp (K : ι → ℤ) (k m : ℕ) : Prop :=
  ∀ B : ℤ, ∃ (K' : ι → ℤ) (S : Finset ι) (v : ℤ),
    S.card ≤ m ∧ (∀ i ∉ S, K i = K' i) ∧ IsOStat K' k v ∧ B < v

/-- The `k`-th order statistic can be driven below every bound by corrupting at most `m`
coordinates. -/
def BreaksDown (K : ι → ℤ) (k m : ℕ) : Prop :=
  ∀ B : ℤ, ∃ (K' : ι → ℤ) (S : Finset ι) (v : ℤ),
    S.card ≤ m ∧ (∀ i ∉ S, K i = K' i) ∧ IsOStat K' k v ∧ v < B

/-- `m` corruptions suffice to break the estimator (in one direction or the other). -/
def Breaks (K : ι → ℤ) (k m : ℕ) : Prop := BreaksUp K k m ∨ BreaksDown K k m

/-- The **finite-sample breakdown number**: the least number of corrupted sample points
that makes the `k`-th order statistic arbitrary. -/
noncomputable def breakdownNumber (K : ι → ℤ) (k : ℕ) : ℕ := sInf {m | Breaks K k m}

/-- Below the breakdown number the estimator is confined to the range of the clean sample. -/
theorem not_breaks_of_lt [Nonempty ι] (K : ι → ℤ) {k m : ℕ}
    (hm : m < min k (Fintype.card ι - k + 1)) (hk : k ≤ Fintype.card ι) : ¬ Breaks K k m := by
  have hmk : m < k := lt_of_lt_of_le hm (min_le_left _ _)
  have hmn : k + m ≤ Fintype.card ι := by
    have := lt_of_lt_of_le hm (min_le_right _ _)
    omega
  rintro (hup | hdown)
  · obtain ⟨K', S, v, hcard, hagree, hv, hlt⟩ := hup (univ.sup' univ_nonempty K)
    exact absurd (ostat_bounded_of_agree hagree hv (by omega) (by omega)).2 (not_le.2 hlt)
  · obtain ⟨K', S, v, hcard, hagree, hv, hlt⟩ := hdown (univ.inf' univ_nonempty K)
    exact absurd (ostat_bounded_of_agree hagree hv (by omega) (by omega)).1 (not_le.2 hlt)

/-- At `min k (n - k + 1)` corruptions the estimator does break. -/
theorem breaks_at_min [Nonempty ι] (K : ι → ℤ) {k : ℕ} (hk1 : 1 ≤ k)
    (hk : k ≤ Fintype.card ι) : Breaks K k (min k (Fintype.card ι - k + 1)) := by
  classical
  rcases le_total k (Fintype.card ι - k + 1) with h | h
  · right
    intro B
    obtain ⟨S, -, hScard⟩ := exists_subset_card_eq (s := (univ : Finset ι)) (n := k)
      (by rwa [card_univ])
    obtain ⟨K', v, hagree, hv, hlt⟩ := ostat_break_down K hk1 hk S (by omega) B
    exact ⟨K', S, v, by omega, hagree, hv, hlt⟩
  · left
    intro B
    obtain ⟨S, -, hScard⟩ := exists_subset_card_eq (s := (univ : Finset ι))
      (n := Fintype.card ι - k + 1) (by rw [card_univ]; omega)
    obtain ⟨K', v, hagree, hv, hlt⟩ := ostat_break_up K hk1 hk S (by omega) B
    exact ⟨K', S, v, by omega, hagree, hv, hlt⟩

/-- **The exact finite-sample breakdown number of the `k`-th order statistic.**
`bd(n, k) = min k (n - k + 1)`: it takes `k` corruptions to drag it down and `n - k + 1` to
drag it up, and fewer than the smaller of the two leaves it inside the clean range. -/
theorem breakdownNumber_eq [Nonempty ι] (K : ι → ℤ) {k : ℕ} (hk1 : 1 ≤ k)
    (hk : k ≤ Fintype.card ι) :
    breakdownNumber K k = min k (Fintype.card ι - k + 1) := by
  refine le_antisymm (Nat.sInf_le (breaks_at_min K hk1 hk)) ?_
  refine le_csInf ⟨_, breaks_at_min K hk1 hk⟩ ?_
  intro m hm
  by_contra hcon
  exact not_breaks_of_lt K (by omega) hk hm

end General

/-! ## 6.  The parity law for the lower median -/

/-- The breakdown number of the lower median of an `n`-point sample. -/
def lowerMedianBreakdown (n : ℕ) : ℕ := (n + 1) / 2

/-- For the lower median `k = ⌈n/2⌉` of an `n`-point sample the general formula collapses to
`⌈n/2⌉`: the median is exactly as hard to drag down as it is to drag up. -/
theorem breakdownNumber_lowerMedian {ι : Type*} [Fintype ι] [DecidableEq ι] [Nonempty ι]
    (K : ι → ℤ) :
    breakdownNumber K ((Fintype.card ι + 1) / 2) = lowerMedianBreakdown (Fintype.card ι) := by
  have hpos : 1 ≤ Fintype.card ι := Fintype.card_pos
  rw [breakdownNumber_eq K (by omega) (by omega), lowerMedianBreakdown]
  omega

/-- **Parity law, part 1.**  Padding an odd sample to the next even size buys no robustness:
a fourth seed has the breakdown number of three seeds. -/
theorem lowerMedianBreakdown_even_eq_pred (m : ℕ) (hm : 1 ≤ m) :
    lowerMedianBreakdown (2 * m) = lowerMedianBreakdown (2 * m - 1) := by
  unfold lowerMedianBreakdown; omega

/-- **Parity law, part 2.**  The next odd size is a strict improvement: the fifth seed does
what the fourth could not. -/
theorem lowerMedianBreakdown_odd_gt (m : ℕ) :
    lowerMedianBreakdown (2 * m) < lowerMedianBreakdown (2 * m + 1) := by
  unfold lowerMedianBreakdown; omega

/-- The breakdown number is a nondecreasing step function of the sample size which increases
exactly at the odd sizes. -/
theorem lowerMedianBreakdown_mono : Monotone lowerMedianBreakdown := by
  intro a b hab
  unfold lowerMedianBreakdown
  omega

end Catalog.Physics.LowTail