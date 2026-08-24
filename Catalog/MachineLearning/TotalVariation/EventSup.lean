/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Sharp normalization for total variation: the event-supremum characterization

The catalog already carries the *arithmetic* half of total variation: the file
`MachineLearning.UniversalRedundancy.Rigidity` defines

`d_TV(p, q) = (∑ₓ |p x − q x|) / 2`

and uses it to price universal codes.  What the catalog does **not** carry is
the *operational* half — the reason for the factor `1/2`.  This file supplies
it, in the sharp (attained) form:

`d_TV(p, q) = max_{A ⊆ X} (p(A) − q(A))`.

Everything downstream is then tight rather than off by the customary factor of
two that one gets from the lazy `ℓ¹` estimate
`|p(A) − q(A)| ≤ ∑ₓ |p x − q x| = 2 d_TV(p, q)`.

## Main results

* `eventGap_le_tvDist`, `abs_eventGap_le_tvDist` — every event is `d_TV`-bounded;
* `eventGap_sepEvent` — the Neyman–Pearson event `{q ≤ p}` attains the bound;
* `isGreatest_eventGap`, `tvDist_eq_sSup_eventGap`, `tvDist_eq_iSup_eventGap` —
  the supremum characterization, in `IsGreatest`, `sSup` and `⨆` form;
* `isGreatest_boolAdvantage`, `tvDist_eq_iSup_boolAdvantage` — the same statement
  read as the optimal advantage of a Boolean distinguisher;
* `abs_softAdvantage_le_tvDist` — randomized `[0,1]`-valued tests do no better
  than Boolean ones (the extreme points of the test polytope are deterministic);
* `abs_expectation_diff_le_osc_mul_tvDist` — the sharp bounded-difference form:
  `|E_p g − E_q g| ≤ (M − m)·d_TV` for `m ≤ g ≤ M`, with the sharpness witness
  `exists_expectation_diff_eq_osc_mul_tvDist`;
* `tvDist_lt_l1_of_ne` — the `ℓ¹` bound is *strictly* lossy whenever `p ≠ q`,
  quantifying exactly what the sharper normalization buys;
* `tvDist_le_one`, `tvDist_eq_zero_iff`, `tvDist_eq_one_iff_singular` — the range
  and the two rigid endpoints, now with operational readings.

## Application keywords

total variation, statistical distance, Neyman–Pearson, distinguishing advantage,
hypothesis testing, indistinguishability, sample complexity
-/

import MachineLearning.UniversalRedundancy.Rigidity

open Finset

namespace UniversalRedundancy

variable {X : Type*} [Fintype X]

/-! ## Events, gaps and the Neyman–Pearson event -/

/-- Probability that the law `p` assigns to the event `A`. -/
def eventProb (p : X → ℝ) (A : Finset X) : ℝ := ∑ x ∈ A, p x

/-- The *distinguishing gap* of an event: how much more likely `A` is under `p`
than under `q`. -/
def eventGap (p q : X → ℝ) (A : Finset X) : ℝ := eventProb p A - eventProb q A

@[simp] lemma eventProb_univ (p : X → ℝ) : eventProb p univ = ∑ x, p x := rfl

omit [Fintype X] in
@[simp] lemma eventProb_empty (p : X → ℝ) : eventProb p ∅ = 0 := rfl

omit [Fintype X] in
@[simp] lemma eventGap_empty (p q : X → ℝ) : eventGap p q ∅ = 0 := by
  simp [eventGap]

omit [Fintype X] in
lemma eventGap_eq_sum (p q : X → ℝ) (A : Finset X) :
    eventGap p q A = ∑ x ∈ A, (p x - q x) := by
  simp [eventGap, eventProb, Finset.sum_sub_distrib]

omit [Fintype X] in
lemma eventGap_neg (p q : X → ℝ) (A : Finset X) :
    -eventGap p q A = eventGap q p A := by
  simp [eventGap]

lemma tvDist_comm (p q : X → ℝ) : tvDist p q = tvDist q p := by
  unfold tvDist
  simp_rw [abs_sub_comm]

open Classical in
/-- The **Neyman–Pearson event** `{x : q x ≤ p x}`: the likelihood-ratio test at
threshold `1`.  It is the event on which the supremum defining `d_TV` is
attained. -/
noncomputable def sepEvent (p q : X → ℝ) : Finset X := univ.filter fun x => q x ≤ p x

/-! ## The bound and its attainment -/

/-- Every event is bounded by the total variation distance.  This is the sharp
version of the naive `ℓ¹` estimate: the right-hand side is `‖p − q‖₁ / 2`, not
`‖p − q‖₁`. -/
theorem eventGap_le_tvDist {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1)
    (A : Finset X) : eventGap p q A ≤ tvDist p q := by
  rw [← SourceClass.sum_posPart_eq_tvDist hp hq, eventGap_eq_sum]
  calc ∑ x ∈ A, (p x - q x) ≤ ∑ x ∈ A, max (p x - q x) 0 :=
        Finset.sum_le_sum fun x _ => le_max_left _ _
    _ ≤ ∑ x, max (p x - q x) 0 :=
        Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ A)
          (fun x _ _ => le_max_right _ _)

/-- Two-sided form: no event separates `p` from `q` by more than `d_TV(p, q)`,
in either direction. -/
theorem abs_eventGap_le_tvDist {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1)
    (A : Finset X) : |eventGap p q A| ≤ tvDist p q := by
  rcases abs_cases (eventGap p q A) with ⟨h, _⟩ | ⟨h, _⟩
  · rw [h]; exact eventGap_le_tvDist hp hq A
  · rw [h, eventGap_neg, tvDist_comm]
    exact eventGap_le_tvDist hq hp A

/-- **Attainment.**  The likelihood-ratio event realises the total variation
distance exactly. -/
theorem eventGap_sepEvent {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1) :
    eventGap p q (sepEvent p q) = tvDist p q := by
  classical
  rw [← SourceClass.sum_posPart_eq_tvDist hp hq, eventGap_eq_sum]
  have hsplit : ∑ x, max (p x - q x) 0
      = (∑ x ∈ sepEvent p q, max (p x - q x) 0)
        + ∑ x ∈ univ.filter (fun x => ¬ q x ≤ p x), max (p x - q x) 0 := by
    rw [sepEvent]
    exact (Finset.sum_filter_add_sum_filter_not univ _ _).symm
  have h1 : ∑ x ∈ sepEvent p q, max (p x - q x) 0 = ∑ x ∈ sepEvent p q, (p x - q x) := by
    refine Finset.sum_congr rfl fun x hx => ?_
    have hle : q x ≤ p x := by
      rw [sepEvent] at hx
      exact (Finset.mem_filter.mp hx).2
    exact max_eq_left (by linarith)
  have h2 : ∑ x ∈ univ.filter (fun x => ¬ q x ≤ p x), max (p x - q x) 0 = 0 := by
    refine Finset.sum_eq_zero fun x hx => ?_
    have hlt : p x < q x := lt_of_not_ge (Finset.mem_filter.mp hx).2
    exact max_eq_right (by linarith)
  rw [hsplit, h1, h2, add_zero]

/-- **The event-supremum characterization of total variation.**  `d_TV(p, q)` is
the greatest distinguishing gap of an event — bound *and* witness together. -/
theorem isGreatest_eventGap {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1) :
    IsGreatest (Set.range (eventGap p q)) (tvDist p q) :=
  ⟨⟨sepEvent p q, eventGap_sepEvent hp hq⟩, by
    rintro r ⟨A, rfl⟩; exact eventGap_le_tvDist hp hq A⟩

/-- Supremum form. -/
theorem tvDist_eq_sSup_eventGap {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1) :
    tvDist p q = sSup (Set.range (eventGap p q)) :=
  ((isGreatest_eventGap hp hq).csSup_eq).symm

/-- Indexed-supremum form: the familiar textbook identity
`d_TV(p, q) = sup_{A} (p(A) − q(A))`. -/
theorem tvDist_eq_iSup_eventGap {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1) :
    tvDist p q = ⨆ A : Finset X, (eventProb p A - eventProb q A) :=
  tvDist_eq_sSup_eventGap hp hq

/-! ## Boolean distinguishers -/

open Classical in
/-- Advantage of a Boolean distinguisher `f`: the difference of its acceptance
probabilities under the two laws. -/
noncomputable def boolAdvantage (p q : X → ℝ) (f : X → Bool) : ℝ :=
  eventGap p q (univ.filter fun x => f x = true)

lemma boolAdvantage_eq_sum (p q : X → ℝ) (f : X → Bool) :
    boolAdvantage p q f = ∑ x, (if f x then p x - q x else 0) := by
  classical
  rw [boolAdvantage, eventGap_eq_sum, Finset.sum_filter]

/-- **Optimal Boolean distinguishing advantage = total variation.**  No test can
do better than `d_TV`, and the likelihood-ratio test achieves it. -/
theorem isGreatest_boolAdvantage {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1) :
    IsGreatest (Set.range (boolAdvantage p q)) (tvDist p q) := by
  classical
  constructor
  · refine ⟨fun x => decide (q x ≤ p x), ?_⟩
    rw [← eventGap_sepEvent hp hq, boolAdvantage, sepEvent]
    congr 1
    apply Finset.filter_congr
    intro x _
    simp
  · rintro r ⟨f, rfl⟩
    exact eventGap_le_tvDist hp hq _

theorem tvDist_eq_iSup_boolAdvantage {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1) :
    tvDist p q = ⨆ f : X → Bool, boolAdvantage p q f :=
  ((isGreatest_boolAdvantage hp hq).csSup_eq).symm

/-! ## Randomized tests do not help -/

/-- A `[0,1]`-valued (randomized) test has advantage at most `d_TV`: the extreme
points of the test polytope are the Boolean tests, so randomization buys
nothing. -/
theorem abs_softAdvantage_le_tvDist {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1)
    {g : X → ℝ} (hg0 : ∀ x, 0 ≤ g x) (hg1 : ∀ x, g x ≤ 1) :
    |∑ x, (p x - q x) * g x| ≤ tvDist p q := by
  have key : ∀ r s : X → ℝ, (∑ x, r x = 1) → (∑ x, s x = 1) →
      ∑ x, (r x - s x) * g x ≤ tvDist r s := by
    intro r s hr hs
    rw [← SourceClass.sum_posPart_eq_tvDist hr hs]
    refine Finset.sum_le_sum fun x _ => ?_
    rcases le_total (s x) (r x) with h | h
    · have hmax : max (r x - s x) 0 = r x - s x := max_eq_left (by linarith)
      rw [hmax]
      nlinarith [hg1 x, hg0 x]
    · have h0 : (0:ℝ) ≤ max (r x - s x) 0 := le_max_right _ _
      nlinarith [hg0 x]
  rcases abs_cases (∑ x, (p x - q x) * g x) with ⟨h, _⟩ | ⟨h, _⟩
  · rw [h]; exact key p q hp hq
  · rw [h]
    have hneg : -∑ x, (p x - q x) * g x = ∑ x, (q x - p x) * g x := by
      rw [← Finset.sum_neg_distrib]
      exact Finset.sum_congr rfl fun x _ => by ring
    rw [hneg, tvDist_comm]
    exact key q p hq hp

/-! ## The sharp bounded-difference (oscillation) bound -/

/-- **Sharp Lipschitz form.**  For any observable `g` taking values in `[m, M]`,
the two laws disagree on its expectation by at most `(M − m)·d_TV(p, q)`.  With
`g` Boolean (`m = 0`, `M = 1`) this is exactly the event bound; with the crude
`ℓ¹` estimate one would only get `(M − m)·2·d_TV`. -/
theorem abs_expectation_diff_le_osc_mul_tvDist {p q : X → ℝ} [Nonempty X]
    (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1) {g : X → ℝ} {m M : ℝ}
    (hm : ∀ x, m ≤ g x) (hM : ∀ x, g x ≤ M) :
    |∑ x, p x * g x - ∑ x, q x * g x| ≤ (M - m) * tvDist p q := by
  have hmM : m ≤ M := le_trans (hm (Classical.arbitrary X)) (hM (Classical.arbitrary X))
  have hrew : ∑ x, p x * g x - ∑ x, q x * g x = ∑ x, (p x - q x) * (g x - m) := by
    have h0 : ∑ x, (p x - q x) = 0 := by
      rw [Finset.sum_sub_distrib, hp, hq]; ring
    have hexp : ∑ x, (p x - q x) * (g x - m)
        = (∑ x, (p x - q x) * g x) - m * ∑ x, (p x - q x) := by
      rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl fun x _ => by ring
    rw [hexp, h0, mul_zero, sub_zero, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun x _ => by ring
  rcases eq_or_lt_of_le hmM with heq | hlt
  · have hconst : ∀ x, g x - m = 0 := fun x => by
      have h1 := hm x; have h2 := hM x; rw [← heq] at h2; linarith
    rw [hrew, Finset.sum_congr rfl fun x _ => by rw [hconst x, mul_zero]]
    rw [← heq]
    simp
  · have hpos : 0 < M - m := by linarith
    have hh0 : ∀ x, 0 ≤ (g x - m) / (M - m) :=
      fun x => div_nonneg (by linarith [hm x]) (le_of_lt hpos)
    have hh1 : ∀ x, (g x - m) / (M - m) ≤ 1 :=
      fun x => (div_le_one hpos).mpr (by linarith [hM x])
    have hsoft := abs_softAdvantage_le_tvDist hp hq hh0 hh1
    have hfac : ∑ x, (p x - q x) * (g x - m)
        = (M - m) * ∑ x, (p x - q x) * ((g x - m) / (M - m)) := by
      rw [Finset.mul_sum]
      refine Finset.sum_congr rfl fun x _ => ?_
      field_simp
    rw [hrew, hfac, abs_mul, abs_of_pos hpos]
    exact mul_le_mul_of_nonneg_left hsoft (le_of_lt hpos)

/-- Sharpness of the oscillation bound: with the indicator of the
Neyman–Pearson event (`m = 0`, `M = 1`) the inequality is an equality, so no
constant smaller than `M − m` works. -/
theorem exists_expectation_diff_eq_osc_mul_tvDist {p q : X → ℝ}
    (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1) :
    ∃ g : X → ℝ, (∀ x, 0 ≤ g x) ∧ (∀ x, g x ≤ 1) ∧
      ∑ x, p x * g x - ∑ x, q x * g x = (1 - 0) * tvDist p q := by
  classical
  refine ⟨fun x => if x ∈ sepEvent p q then 1 else 0, fun x => by positivity,
    fun x => by by_cases h : x ∈ sepEvent p q <;> simp [h], ?_⟩
  have hind : ∀ r : X → ℝ, ∑ x, r x * (if x ∈ sepEvent p q then (1:ℝ) else 0)
      = eventProb r (sepEvent p q) := by
    intro r
    simp only [mul_ite, mul_one, mul_zero, Finset.sum_ite_mem, Finset.univ_inter, eventProb]
  rw [hind p, hind q, sub_zero, one_mul, ← eventGap, eventGap_sepEvent hp hq]

/-! ## Comparison with the crude `ℓ¹` bound -/

/-- The `ℓ¹` normalization: `‖p − q‖₁ = 2 d_TV(p, q)`. -/
lemma l1_eq_two_mul_tvDist (p q : X → ℝ) : ∑ x, |p x - q x| = 2 * tvDist p q := by
  unfold tvDist; ring

lemma tvDist_pos_of_ne {p q : X → ℝ} (hne : p ≠ q) : 0 < tvDist p q := by
  rcases lt_or_eq_of_le (tvDist_nonneg p q) with h | h
  · exact h
  · exfalso
    apply hne
    funext x
    have hsum : ∑ y, |p y - q y| = 0 := by
      have h' := h.symm
      unfold tvDist at h'
      linarith
    have hx := (Finset.sum_eq_zero_iff_of_nonneg
      (fun y _ => abs_nonneg (p y - q y))).mp hsum x (Finset.mem_univ x)
    have := abs_eq_zero.mp hx
    linarith

/-- **The `ℓ¹` bound is strictly lossy.**  Whenever the two laws differ, the
`ℓ¹` estimate `|p(A) − q(A)| ≤ ‖p − q‖₁` overshoots the truth by a factor two:
the sharp constant `d_TV` is *strictly* below `‖p − q‖₁`. -/
theorem tvDist_lt_l1_of_ne {p q : X → ℝ} (hne : p ≠ q) :
    tvDist p q < ∑ x, |p x - q x| := by
  have hpos := tvDist_pos_of_ne hne
  rw [l1_eq_two_mul_tvDist]
  linarith

/-! ## Range and rigid endpoints -/

/-- Total variation is at most `1` for probability vectors. -/
theorem tvDist_le_one {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1)
    (hp0 : ∀ x, 0 ≤ p x) (hq0 : ∀ x, 0 ≤ q x) : tvDist p q ≤ 1 := by
  rw [← eventGap_sepEvent hp hq, eventGap, eventProb, eventProb]
  have h1 : ∑ x ∈ sepEvent p q, p x ≤ 1 := by
    rw [← hp]
    exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
      (fun x _ _ => hp0 x)
  have h2 : (0:ℝ) ≤ ∑ x ∈ sepEvent p q, q x :=
    Finset.sum_nonneg fun x _ => hq0 x
  linarith

/-- `d_TV = 0` iff the laws coincide: no event distinguishes them at all. -/
theorem tvDist_eq_zero_iff (p q : X → ℝ) : tvDist p q = 0 ↔ p = q := by
  constructor
  · intro h
    by_contra hne
    exact absurd h (ne_of_gt (tvDist_pos_of_ne hne))
  · rintro rfl
    unfold tvDist
    simp

/-- `d_TV = 1` iff the laws are mutually singular: some event separates them
perfectly. -/
theorem tvDist_eq_one_iff_singular {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1)
    (hp0 : ∀ x, 0 ≤ p x) (hq0 : ∀ x, 0 ≤ q x) :
    tvDist p q = 1 ↔ ∀ x, p x = 0 ∨ q x = 0 := by
  have hmin := SourceClass.sum_min_eq_one_sub_tvDist hp hq
  constructor
  · intro h1 x
    rw [h1] at hmin
    have hz : ∑ y, min (p y) (q y) = 0 := by linarith
    have hx := (Finset.sum_eq_zero_iff_of_nonneg
      (fun y _ => le_min (hp0 y) (hq0 y))).mp hz x (Finset.mem_univ x)
    rcases min_cases (p x) (q x) with ⟨he, _⟩ | ⟨he, _⟩
    · exact Or.inl (by rw [← he]; exact hx)
    · exact Or.inr (by rw [← he]; exact hx)
  · intro hsing
    have hz : ∑ y, min (p y) (q y) = 0 := by
      refine Finset.sum_eq_zero fun y _ => ?_
      rcases hsing y with h | h
      · rw [h, min_eq_left (hq0 y)]
      · rw [h, min_eq_right (hp0 y)]
    linarith

end UniversalRedundancy