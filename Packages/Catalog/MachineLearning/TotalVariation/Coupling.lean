/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The coupling (Strassen) characterization of total variation

Third leg of the sharp-normalization thread.  `EventSup` characterized

`d_TV(p, q) = max_A (p(A) − q(A))`

as a supremum over *events*, and `Testing` cashed that in for hypothesis
testing.  This file proves the dual, *infimum*, characterization:

`d_TV(p, q) = min_{couplings c of (p, q)} ℙ_c[X ≠ Y]`.

Both directions are proved:

* every coupling has disagreement probability at least `d_TV`
  (`tvDist_le_disagreeProb`), by pushing the optimal *event* of `EventSup`
  through the coupling — so the two characterizations are genuinely dual;
* the explicit **maximal coupling**

  `c(x, y) = min(p x, q x)·[x = y] + (p x − min)₊ (q y − min)₊ / d_TV`

  attains it (`isCoupling_maxCoupling`, `disagreeProb_maxCoupling`).

The two together give `isLeast_disagreeProb`, and the sandwich
`max_A (p(A) − q(A)) = d_TV = min_c ℙ_c[X ≠ Y]` (`max_eventGap_eq_min_disagree`)
— a minimax identity whose two sides are witnessed by explicit optima.

The factor `1/2` is exactly what makes this work: with the `ℓ¹` normalization the
identity would read `min_c ℙ[X ≠ Y] = ‖p − q‖₁/2`, and the naive `ℓ¹` bound would
be off by two.

## Main results

* `IsCoupling`, `disagreeProb` — the coupling framework;
* `tvDist_le_disagreeProb` — the easy (but event-driven) direction;
* `isCoupling_maxCoupling`, `disagreeProb_maxCoupling` — the maximal coupling;
* `isLeast_disagreeProb`, `max_eventGap_eq_min_disagree` — the minimax identity;
* `eventGap_le_disagreeProb` — the coupling bound on distinguishing advantage.

## Application keywords

maximal coupling, Strassen's theorem, total variation, transport, minimax,
distinguishing advantage
-/

import MachineLearning.TotalVariation.EventSup

open Finset

namespace UniversalRedundancy

variable {X : Type*} [Fintype X] [DecidableEq X]

/-! ## Couplings -/

/-- `c` is a coupling of the laws `p` and `q`: a joint law on `X × X` with the
prescribed marginals. -/
structure IsCoupling (p q : X → ℝ) (c : X → X → ℝ) : Prop where
  nonneg : ∀ x y, 0 ≤ c x y
  left : ∀ x, ∑ y, c x y = p x
  right : ∀ y, ∑ x, c x y = q y

/-- Probability that the two coordinates of the joint law `c` disagree. -/
def disagreeProb (c : X → X → ℝ) : ℝ := ∑ x, ∑ y, if x = y then 0 else c x y

lemma disagreeProb_eq_one_sub_diag {p q : X → ℝ} {c : X → X → ℝ}
    (hc : IsCoupling p q c) (hp : ∑ x, p x = 1) :
    disagreeProb c = 1 - ∑ x, c x x := by
  have hrow : ∀ x : X, ∑ y, (if x = y then (0:ℝ) else c x y) = p x - c x x := by
    intro x
    have hsplit : ∀ y : X, (if x = y then (0:ℝ) else c x y)
        = c x y - (if x = y then c x y else 0) := by
      intro y; by_cases h : x = y <;> simp [h]
    rw [Finset.sum_congr rfl fun y _ => hsplit y, Finset.sum_sub_distrib,
      Finset.sum_ite_eq, hc.left x]
    simp
  rw [disagreeProb, Finset.sum_congr rfl fun x _ => hrow x, Finset.sum_sub_distrib, hp]

/-! ## Every coupling dominates the total variation distance -/

/-- The distinguishing gap of an event is controlled by the disagreement
probability of *any* coupling: this is the coupling bound in its raw form. -/
theorem eventGap_le_disagreeProb {p q : X → ℝ} {c : X → X → ℝ} (hc : IsCoupling p q c)
    (A : Finset X) : eventGap p q A ≤ disagreeProb c := by
  classical
  have hind : ∀ r : X → ℝ, ∀ B : Finset X, ∑ x ∈ B, r x
      = ∑ x, r x * (if x ∈ B then (1:ℝ) else 0) := by
    intro r B
    simp only [mul_ite, mul_one, mul_zero, Finset.sum_ite_mem, Finset.univ_inter]
  have hleft : eventProb p A = ∑ x, ∑ y, c x y * (if x ∈ A then (1:ℝ) else 0) := by
    rw [eventProb, hind p A]
    refine Finset.sum_congr rfl fun x _ => ?_
    rw [← hc.left x, Finset.sum_mul]
  have hright : eventProb q A = ∑ x, ∑ y, c x y * (if y ∈ A then (1:ℝ) else 0) := by
    rw [eventProb, hind q A, Finset.sum_comm]
    refine Finset.sum_congr rfl fun y _ => ?_
    rw [← hc.right y, Finset.sum_mul]
  have hdiff : eventGap p q A
      = ∑ x, ∑ y, c x y * ((if x ∈ A then (1:ℝ) else 0) - (if y ∈ A then (1:ℝ) else 0)) := by
    rw [eventGap, hleft, hright, ← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl fun x _ => ?_
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun y _ => by ring
  rw [hdiff, disagreeProb]
  refine Finset.sum_le_sum fun x _ => Finset.sum_le_sum fun y _ => ?_
  by_cases hxy : x = y
  · subst hxy; simp
  · rw [if_neg hxy]
    have hle : (if x ∈ A then (1:ℝ) else 0) - (if y ∈ A then (1:ℝ) else 0) ≤ 1 := by
      by_cases h1 : x ∈ A <;> by_cases h2 : y ∈ A <;> simp [h1, h2]
    nlinarith [hc.nonneg x y]

/-- **Coupling lower bound.**  Every coupling of `p` and `q` disagrees with
probability at least `d_TV(p, q)`.  The proof runs the optimal *event* of the
supremum characterization through the coupling, so the sharp constant here is
inherited from the sharp normalization. -/
theorem tvDist_le_disagreeProb {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1)
    {c : X → X → ℝ} (hc : IsCoupling p q c) : tvDist p q ≤ disagreeProb c := by
  rw [← eventGap_sepEvent hp hq]
  exact eventGap_le_disagreeProb hc _

/-! ## The maximal coupling -/

open Classical in
/-- The **maximal coupling** of `p` and `q`: keep the shared mass
`min(p, q)` on the diagonal and match the two leftovers independently, rescaled
by `d_TV`. -/
noncomputable def maxCoupling (p q : X → ℝ) : X → X → ℝ := fun x y =>
  (if x = y then min (p x) (q x) else 0)
    + (if tvDist p q = 0 then 0
        else (p x - min (p x) (q x)) * (q y - min (p y) (q y)) / tvDist p q)

omit [DecidableEq X] in
lemma sum_posPart_left {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1) :
    ∑ x, (p x - min (p x) (q x)) = tvDist p q := by
  rw [Finset.sum_sub_distrib, hp, SourceClass.sum_min_eq_one_sub_tvDist hp hq]
  ring

omit [DecidableEq X] in
lemma sum_posPart_right {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1) :
    ∑ y, (q y - min (p y) (q y)) = tvDist p q := by
  rw [Finset.sum_sub_distrib, hq, SourceClass.sum_min_eq_one_sub_tvDist hp hq]
  ring

omit [Fintype X] [DecidableEq X] in
lemma leftover_mul_eq_zero (p q : X → ℝ) (x : X) :
    (p x - min (p x) (q x)) * (q x - min (p x) (q x)) = 0 := by
  rcases le_total (p x) (q x) with h | h
  · rw [min_eq_left h]; ring
  · rw [min_eq_right h]; ring

omit [Fintype X] [DecidableEq X] in
lemma leftover_left_nonneg (p q : X → ℝ) (x : X) : 0 ≤ p x - min (p x) (q x) := by
  have := min_le_left (p x) (q x); linarith

omit [Fintype X] [DecidableEq X] in
lemma leftover_right_nonneg (p q : X → ℝ) (y : X) : 0 ≤ q y - min (p y) (q y) := by
  have := min_le_right (p y) (q y); linarith

/-- Pointwise unfolding of the maximal coupling. -/
lemma maxCoupling_apply (p q : X → ℝ) (x y : X) :
    maxCoupling p q x y = (if x = y then min (p x) (q x) else 0)
      + (if tvDist p q = 0 then 0
          else (p x - min (p x) (q x)) * (q y - min (p y) (q y)) / tvDist p q) := by
  simp only [maxCoupling]

/-- The maximal coupling really is a coupling. -/
theorem isCoupling_maxCoupling {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1)
    (hp0 : ∀ x, 0 ≤ p x) (hq0 : ∀ x, 0 ≤ q x) :
    IsCoupling p q (maxCoupling p q) := by
  classical
  have hzero : tvDist p q = 0 → p = q := fun h => (tvDist_eq_zero_iff p q).mp h
  refine ⟨?_, ?_, ?_⟩
  · intro x y
    rw [maxCoupling_apply]
    have h1 : (0:ℝ) ≤ if x = y then min (p x) (q x) else 0 := by
      by_cases h : x = y
      · rw [if_pos h]; exact le_min (hp0 x) (hq0 x)
      · simp [h]
    have h2 : (0:ℝ) ≤ if tvDist p q = 0 then 0
        else (p x - min (p x) (q x)) * (q y - min (p y) (q y)) / tvDist p q := by
      by_cases h : tvDist p q = 0
      · simp [h]
      · rw [if_neg h]
        have hpos : 0 < tvDist p q := lt_of_le_of_ne (tvDist_nonneg p q) (Ne.symm h)
        exact div_nonneg (mul_nonneg (leftover_left_nonneg p q x)
          (leftover_right_nonneg p q y)) hpos.le
    exact add_nonneg h1 h2
  · intro x
    rw [Finset.sum_congr rfl fun y (_ : y ∈ univ) => maxCoupling_apply p q x y,
      Finset.sum_add_distrib, Finset.sum_ite_eq]
    by_cases h : tvDist p q = 0
    · have hpq := hzero h
      subst hpq
      simp
    · rw [Finset.sum_congr rfl fun y (_ : y ∈ univ) => if_neg h]
      have hfac : ∑ y, (p x - min (p x) (q x)) * (q y - min (p y) (q y)) / tvDist p q
          = (p x - min (p x) (q x)) * (∑ y, (q y - min (p y) (q y))) / tvDist p q := by
        rw [Finset.mul_sum, Finset.sum_div]
      rw [hfac, sum_posPart_right hp hq, mul_div_assoc, div_self h, mul_one,
        if_pos (Finset.mem_univ x)]
      ring
  · intro y
    have hcol : ∀ x : X, maxCoupling p q x y
        = (if x = y then min (p y) (q y) else 0)
          + (if tvDist p q = 0 then 0
              else (p x - min (p x) (q x)) * (q y - min (p y) (q y)) / tvDist p q) := by
      intro x
      rw [maxCoupling_apply]
      by_cases h : x = y
      · subst h; simp
      · simp [h]
    rw [Finset.sum_congr rfl fun x (_ : x ∈ univ) => hcol x, Finset.sum_add_distrib]
    have hdiag : ∑ x, (if x = y then min (p y) (q y) else 0) = min (p y) (q y) := by
      simp
    rw [hdiag]
    by_cases h : tvDist p q = 0
    · have hpq := hzero h
      subst hpq
      simp
    · rw [Finset.sum_congr rfl fun x (_ : x ∈ univ) => if_neg h]
      have hfac : ∑ x, (p x - min (p x) (q x)) * (q y - min (p y) (q y)) / tvDist p q
          = (∑ x, (p x - min (p x) (q x))) * (q y - min (p y) (q y)) / tvDist p q := by
        rw [Finset.sum_mul, Finset.sum_div]
      rw [hfac, sum_posPart_left hp hq, mul_comm, mul_div_assoc, div_self h, mul_one]
      ring

/-- **The maximal coupling is optimal**: its two coordinates disagree with
probability exactly `d_TV(p, q)`.  The cross term contributes nothing on the
diagonal because `(p − min)` and `(q − min)` have disjoint supports. -/
theorem disagreeProb_maxCoupling {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1)
    (hp0 : ∀ x, 0 ≤ p x) (hq0 : ∀ x, 0 ≤ q x) :
    disagreeProb (maxCoupling p q) = tvDist p q := by
  classical
  have hdiag : ∑ x, maxCoupling p q x x = 1 - tvDist p q := by
    have hpt : ∀ x : X, maxCoupling p q x x = min (p x) (q x) := by
      intro x
      rw [maxCoupling_apply]
      by_cases h : tvDist p q = 0
      · simp [h]
      · rw [if_pos rfl, if_neg h, leftover_mul_eq_zero p q x, zero_div, add_zero]
    rw [Finset.sum_congr rfl fun x _ => hpt x, SourceClass.sum_min_eq_one_sub_tvDist hp hq]
  rw [disagreeProb_eq_one_sub_diag (isCoupling_maxCoupling hp hq hp0 hq0) hp, hdiag]
  ring

/-- **Strassen's identity in finite form.**  `d_TV(p, q)` is the *least*
disagreement probability over all couplings — bound and optimal coupling
together. -/
theorem isLeast_disagreeProb {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1)
    (hp0 : ∀ x, 0 ≤ p x) (hq0 : ∀ x, 0 ≤ q x) :
    IsLeast {r : ℝ | ∃ c, IsCoupling p q c ∧ r = disagreeProb c} (tvDist p q) := by
  constructor
  · exact ⟨maxCoupling p q, isCoupling_maxCoupling hp hq hp0 hq0,
      (disagreeProb_maxCoupling hp hq hp0 hq0).symm⟩
  · rintro r ⟨c, hc, rfl⟩
    exact tvDist_le_disagreeProb hp hq hc

/-- **Minimax form of the sharp normalization.**  The greatest distinguishing
gap over events equals the least disagreement probability over couplings; both
optima are attained (by the Neyman–Pearson event and the maximal coupling). -/
theorem max_eventGap_eq_min_disagree {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1)
    (hp0 : ∀ x, 0 ≤ p x) (hq0 : ∀ x, 0 ≤ q x) :
    IsGreatest (Set.range (eventGap p q)) (tvDist p q) ∧
      IsLeast {r : ℝ | ∃ c, IsCoupling p q c ∧ r = disagreeProb c} (tvDist p q) :=
  ⟨isGreatest_eventGap hp hq, isLeast_disagreeProb hp hq hp0 hq0⟩

end UniversalRedundancy