/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Probability.TropicalSocialChoiceOligarchy

/-!
# Tropical social choice VI: the ordinal price of the tropical escape

`Probability.TropicalSocialChoice` showed that the tropical axioms admit non-dictatorial
rules once tropical multiplicativity is dropped (e.g. the Rawlsian minimum rule), and that
this particular rule violates *classical* (ordinal) independence of irrelevant
alternatives, so that Arrow's theorem is not contradicted.

Conjecture 4 of `FUTURE_DIRECTIONS.md` asserted that this is a general phenomenon: **every**
non-dictatorial unanimous tropical linear rule violates classical IIA.  This file proves it,
and deduces Arrow's theorem in the form

  tropical linearity + tropical Pareto + ordinal IIA ⟹ dictator.

## Main results

* `le_tropForm`, `tropForm_le` : a tropical linear form is the minimum of its terms.
* `exists_two_active_coeffs` : a unanimous tropical linear rule that is not a dictatorship
  has a voter `k` with coefficient `1` and a *second* voter `j ≠ k` with a finite
  coefficient `c ≥ 0`.
* `nondictatorial_violates_classical_IIA` : **Conjecture 4, proved.**  Such a rule fails
  classical IIA: two cost profiles that induce the same individual rankings of two
  alternatives are ranked oppositely by society.  Voter `j`'s *intensity* of preference,
  not merely its direction, moves the social ranking.
* `arrow_recovered` : consequently the rules satisfying tropical linearity, tropical Pareto
  and classical ordinal IIA are exactly the dictators — Arrow's theorem, recovered inside
  the tropical framework.
-/

namespace TropicalSocialChoice

open Tropical Finset

section Ordinal

variable {n : ℕ}

/-! ### A tropical linear form is the minimum of its terms -/

theorem le_tropForm {a x : Fin n → TR} {b : TR} (h : ∀ i, b ≤ a i * x i) : b ≤ tropForm a x := by
  rw [tropForm, ← untrop_le_iff, Finset.untrop_sum']
  refine Finset.le_inf fun i _ => ?_
  simpa [Function.comp] using (untrop_le_iff (x := b) (y := a i * x i)).mpr (h i)

theorem tropForm_le (a x : Fin n → TR) (i : Fin n) : tropForm a x ≤ a i * x i := by
  rw [tropForm, ← untrop_le_iff, Finset.untrop_sum']
  exact Finset.inf_le (Finset.mem_univ i)

theorem ofReal_mul_ofReal (c r : ℝ) : ofReal c * ofReal r = ofReal (c + r) := by
  simp [ofReal, ← trop_add]

/-! ### Two active voters -/

/-- If all coefficients other than `a k = 1` vanish, the rule is the dictatorship of `k`. -/
theorem tropForm_eq_tropDictator_of_coeffs {a : Fin n → TR} {k : Fin n} (hk : a k = 1)
    (hzero : ∀ j, j ≠ k → a j = 0) : tropForm a = tropDictator k := by
  classical
  funext x
  rw [tropForm, Finset.sum_eq_single k]
  · rw [hk, one_mul]; rfl
  · intro b _ hb; rw [hzero b hb, zero_mul]
  · intro h; simp at h

/-- A unanimous tropical linear rule which is not a dictatorship has, besides a voter with
coefficient `1`, a second voter whose coefficient is a finite nonnegative handicap. -/
theorem exists_two_active_coeffs {a : Fin n → TR} (hsum : ∑ i, a i = 1)
    (hnd : ¬ IsTropDictatorial (tropForm a)) :
    ∃ k j : Fin n, j ≠ k ∧ a k = 1 ∧ ∃ c : ℝ, 0 ≤ c ∧ a j = ofReal c := by
  obtain ⟨k, hk⟩ := exists_coeff_eq_one hsum
  by_cases hall : ∀ j, j ≠ k → a j = 0
  · exact absurd ⟨k, tropForm_eq_tropDictator_of_coeffs hk hall⟩ hnd
  · push_neg at hall
    obtain ⟨j, hjk, hj⟩ := hall
    have hne : untrop (a j) ≠ ⊤ := fun ht => hj (untrop_injective (by rw [ht]; rfl))
    obtain ⟨c, hc⟩ := WithTop.ne_top_iff_exists.mp hne
    have hac : a j = ofReal c := untrop_injective (by rw [← hc]; rfl)
    refine ⟨k, j, hjk, hk, c, ?_, hac⟩
    have h1 : (1 : TR) ≤ a j := one_le_coeff hsum j
    rw [hac, ← untrop_le_iff] at h1
    have : ((0 : ℝ) : WithTop ℝ) ≤ ((c : ℝ) : WithTop ℝ) := h1
    exact_mod_cast this

/-! ### Classical independence of irrelevant alternatives -/

/-- Classical (ordinal) IIA on two alternatives: the social ranking of the two
alternatives depends only on the individual *rankings* of those alternatives, not on the
cardinal costs. -/
def ClassicalIIA (f : (Fin n → TR) → TR) : Prop :=
  ∀ u v : Fin n → Bool → ℝ, (∀ i, (u i true ≤ u i false ↔ v i true ≤ v i false)) →
    (SocPrefers f u true false ↔ SocPrefers f v true false)

/-- Every dictator satisfies classical IIA. -/
theorem tropDictator_classicalIIA (k : Fin n) : ClassicalIIA (tropDictator k) :=
  fun u v h => dictator_classical_IIA k u v true false h

/-- **Conjecture 4, proved.**  A unanimous tropical linear rule that is not a dictatorship
violates classical independence of irrelevant alternatives.  Concretely: keep every voter's
*ranking* of the two alternatives fixed but let the second active voter `j` intensify its
preference; the social ranking flips.  Thus the tropical escape from Arrow's theorem is paid
for with cardinal (intensity) information. -/
theorem nondictatorial_violates_classical_IIA {f : (Fin n → TR) → TR} (hlin : IsTropLinear f)
    (hpar : TropPareto f) (hnd : ¬ IsTropDictatorial f) : ¬ ClassicalIIA f := by
  classical
  obtain ⟨a, ha⟩ := hlin
  have hf : f = tropForm a := funext ha
  subst hf
  have hsum : ∑ i, a i = 1 := (tropPareto_tropForm_iff a).mp hpar
  obtain ⟨k, j, hjk, hk, c, hc0, hcj⟩ := exists_two_active_coeffs hsum hnd
  intro hIIA
  -- the two profiles
  set u : Fin n → Bool → ℝ := fun i b =>
    if i = k then (if b then 0 else 1) else if i = j then (if b then 10 else 0) else 1000 with hu
  set v : Fin n → Bool → ℝ := fun i b =>
    if i = k then (if b then 0 else 1) else if i = j then (if b then 100 else -100 - c) else 1000
    with hv
  -- values of the two profiles
  have huk : ∀ b : Bool, u k b = if b then (0 : ℝ) else 1 := by intro b; rw [hu]; simp
  have huj : ∀ b : Bool, u j b = if b then (10 : ℝ) else 0 := by intro b; rw [hu]; simp [hjk]
  have huo : ∀ i : Fin n, i ≠ k → i ≠ j → ∀ b : Bool, u i b = 1000 := by
    intro i hik hij b; rw [hu]; simp [hik, hij]
  have hvk : ∀ b : Bool, v k b = if b then (0 : ℝ) else 1 := by intro b; rw [hv]; simp
  have hvj : ∀ b : Bool, v j b = if b then (100 : ℝ) else -100 - c := by
    intro b; rw [hv]; simp [hjk]
  have hvo : ∀ i : Fin n, i ≠ k → i ≠ j → ∀ b : Bool, v i b = 1000 := by
    intro i hik hij b; rw [hv]; simp [hik, hij]
  -- individual rankings agree
  have hsame : ∀ i, (u i true ≤ u i false ↔ v i true ≤ v i false) := by
    intro i
    by_cases hik : i = k
    · subst hik
      rw [huk, huk, hvk, hvk]
    · by_cases hij : i = j
      · subst hij
        rw [huj, huj, hvj, hvj]
        refine iff_of_false (by norm_num) ?_
        simp only [if_true, Bool.false_eq_true, if_false]
        intro h
        linarith
      · rw [huo i hik hij, huo i hik hij, hvo i hik hij, hvo i hik hij]
  -- all reported costs are nonnegative, except voter `j`'s cost for `false` in `v`
  have hunonneg : ∀ (i : Fin n) (b : Bool), 0 ≤ u i b := by
    intro i b
    by_cases hik : i = k
    · subst hik; rw [huk]; cases b <;> norm_num
    · by_cases hij : i = j
      · subst hij; rw [huj]; cases b <;> norm_num
      · rw [huo i hik hij]; norm_num
  have hvtrue : ∀ i : Fin n, 0 ≤ v i true := by
    intro i
    by_cases hik : i = k
    · subst hik; rw [hvk]; norm_num
    · by_cases hij : i = j
      · subst hij; rw [hvj]; norm_num
      · rw [hvo i hik hij]; norm_num
  -- a lower bound for the social cost when every reported cost is nonnegative
  have hlow : ∀ (w : Fin n → Bool → ℝ) (b : Bool), (∀ i, 0 ≤ w i b) →
      ofReal 0 ≤ tropForm a (fun i => ofReal (w i b)) := by
    intro w b hw
    refine le_tropForm fun i => ?_
    have h1 : (1 : TR) * ofReal 0 ≤ a i * ofReal (w i b) :=
      mul_le_mul' (one_le_coeff hsum i) (ofReal_le_ofReal.mpr (hw i))
    rwa [one_mul] at h1
  -- first profile: society weakly prefers `true`
  have hu_true : socialCost (tropForm a) u true = ofReal 0 := by
    refine le_antisymm ?_ (hlow u true fun i => hunonneg i true)
    have hle := tropForm_le a (fun i => ofReal (u i true)) k
    have hval : u k true = 0 := by rw [huk]; norm_num
    rw [hk, one_mul, hval] at hle
    exact hle
  have hpref_u : SocPrefers (tropForm a) u true false := by
    rw [SocPrefers, hu_true]
    exact hlow u false fun i => hunonneg i false
  -- second profile: society strictly prefers `false`
  have hv_false : socialCost (tropForm a) v false ≤ ofReal (-100) := by
    have hle := tropForm_le a (fun i => ofReal (v i false)) j
    have hval : v j false = -100 - c := by rw [hvj]; norm_num
    rw [hcj, hval, ofReal_mul_ofReal] at hle
    have : c + (-100 - c) = -100 := by ring
    rwa [this] at hle
  have hnpref_v : ¬ SocPrefers (tropForm a) v true false := by
    intro hpref
    have h1 : ofReal 0 ≤ socialCost (tropForm a) v true := hlow v true hvtrue
    have h2 : ofReal (0 : ℝ) ≤ ofReal (-100 : ℝ) := le_trans h1 (le_trans hpref hv_false)
    have := ofReal_le_ofReal.mp h2
    norm_num at this
  exact hnpref_v ((hIIA u v hsame).mp hpref_u)

/-- **Arrow's theorem, recovered.**  The tropically linear, unanimous rules that respect
classical (ordinal) independence of irrelevant alternatives are exactly the dictators: the
tropical axioms escape Arrow only by using cardinal information. -/
theorem arrow_recovered {f : (Fin n → TR) → TR} (hlin : IsTropLinear f) (hpar : TropPareto f)
    (hiia : ClassicalIIA f) : IsTropDictatorial f := by
  by_contra hnd
  exact nondictatorial_violates_classical_IIA hlin hpar hnd hiia

/-- The exact characterisation. -/
theorem arrow_recovered_iff (f : (Fin n → TR) → TR) :
    (IsTropLinear f ∧ TropPareto f ∧ ClassicalIIA f) ↔ IsTropDictatorial f := by
  constructor
  · rintro ⟨hlin, hpar, hiia⟩
    exact arrow_recovered hlin hpar hiia
  · rintro ⟨k, rfl⟩
    exact ⟨tropDictator_isTropLinear k, tropDictator_tropPareto k, tropDictator_classicalIIA k⟩

end Ordinal

end TropicalSocialChoice