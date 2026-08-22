import Mathlib
import Shared.Ispythquadruple.IsPythQuadruple
import Shared.HigherPythagorean.BranchingContrast
import Shared.HigherPythagorean.HarmonicLaw
import Physics.HigherPythagoreanTrees.DescentComplex

/-!
# Exact branching numbers: `3` in dimension two, `6` or `7` in dimension three

The catalog proves that a Pythagorean quadruple has *at most two* descents
(`HigherPythagorean.quad_at_most_two_descents`), that two descents really occur
(`HigherPythagorean.quad_two_parents_family`) and that height-preserving ("neutral") moves
exist in dimension three (`HigherPythagorean.quad_neutral_move_iff`).  Here the branching
number is computed **exactly**, as the cardinality of an explicit `Finset` of sign patterns.

A *child* of a node is a sign pattern whose reflection move strictly **raises** the height;
descending and neutral patterns are not children.

* Dimension two: of the `4` sign patterns exactly `3` are children of a Pythagorean triple
  with positive legs (`triple_children_card`): Berggren's ternary tree.
* Dimension three: of the `8` sign patterns either `6` or `7` are children, and which of the
  two occurs is decided by the **weak harmonic law**
  `a(b+c) ≤ bc ∨ b(a+c) ≤ ac ∨ c(a+b) ≤ ab`
  (`quad_children_card`, `weakDefect_iff_harmonic`).
* Both values occur infinitely often: `quad_children_six_family` (the catalog's two-parent
  family `(1, 2m, 2m², 2m²+1)`) and `quad_children_seven_family` (the new family
  `(2m, 2m, 2m²−1, 2m²+1)`).

So the higher-dimensional Pythagorean graph is **not** a regular tree: the ternary structure
of the Berggren tree fails, and the failure is measured exactly by an Egyptian-fraction
(harmonic) inequality between the three space coordinates.
-/

namespace HigherPythagoreanBranching

open Finset HigherPythagorean

/-! ## Dimension two: the Berggren ternary tree -/

/-- The four sign patterns in dimension two. -/
def tripleSignPats : Finset (ℤ × ℤ) := {(1, 1), (1, -1), (-1, 1), (-1, -1)}

theorem tripleSignPats_card : tripleSignPats.card = 4 := by decide

/-- The children of a Pythagorean triple: the sign patterns that strictly raise the height. -/
def tripleChildren (a b c : ℤ) : Finset (ℤ × ℤ) :=
  tripleSignPats.filter fun e => e.1 * a + e.2 * b < c

/-- **Berggren's tree is ternary**: exactly three of the four sign patterns raise the height,
the fourth (the all-plus one) being the unique parent. -/
theorem triple_children_card {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) : (tripleChildren a b c).card = 3 := by
  have hac : a < c := by nlinarith
  have hbc : b < c := by nlinarith
  have hset : tripleChildren a b c = {(1, -1), (-1, 1), (-1, -1)} := by
    ext e
    simp only [tripleChildren, tripleSignPats, Finset.mem_filter, Finset.mem_insert,
      Finset.mem_singleton]
    constructor
    · rintro ⟨hs, hlt⟩
      rcases hs with rfl | rfl | rfl | rfl
      · exfalso
        have := triple_plus_descends ha hb hc h
        unfold TDescends at this
        simp at hlt
        linarith
      · exact Or.inl rfl
      · exact Or.inr (Or.inl rfl)
      · exact Or.inr (Or.inr rfl)
    · rintro (rfl | rfl | rfl) <;> simp <;> linarith
  rw [hset]
  decide +kernel

/-! ## Dimension three: eight sign patterns -/

/-- The eight sign patterns in dimension three. -/
def quadSignPats : Finset (ℤ × ℤ × ℤ) :=
  {(1, 1, 1), (1, 1, -1), (1, -1, 1), (1, -1, -1),
   (-1, 1, 1), (-1, 1, -1), (-1, -1, 1), (-1, -1, -1)}

theorem quadSignPats_card : quadSignPats.card = 8 := by decide

/-- The *non-children*: the sign patterns whose move does not raise the height, i.e. the
descending and the neutral ones. -/
def quadNonChildren (a b c d : ℤ) : Finset (ℤ × ℤ × ℤ) :=
  quadSignPats.filter fun e => d ≤ e.1 * a + e.2.1 * b + e.2.2 * c

/-- The children of a Pythagorean quadruple. -/
def quadChildren (a b c d : ℤ) : Finset (ℤ × ℤ × ℤ) :=
  quadSignPats.filter fun e => e.1 * a + e.2.1 * b + e.2.2 * c < d

lemma quadChildren_card_add (a b c d : ℤ) :
    (quadChildren a b c d).card + (quadNonChildren a b c d).card = 8 := by
  classical
  have h := Finset.card_filter_add_card_filter_not
    (s := quadSignPats) (p := fun e : ℤ × ℤ × ℤ => e.1 * a + e.2.1 * b + e.2.2 * c < d)
  rw [quadSignPats_card] at h
  have hneg : quadSignPats.filter
      (fun e : ℤ × ℤ × ℤ => ¬ (e.1 * a + e.2.1 * b + e.2.2 * c < d))
      = quadNonChildren a b c d := by
    unfold quadNonChildren
    exact Finset.filter_congr fun e _ => by simp [not_lt]
  rw [hneg] at h
  exact h

/-- Each space coordinate of a Pythagorean quadruple with positive coordinates is strictly
smaller than the height. -/
lemma coord_lt_height {a b c d : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d)
    (h : IsPythQuadruple a b c d) : a < d ∧ b < d ∧ c < d := by
  unfold IsPythQuadruple at h
  refine ⟨by nlinarith, by nlinarith, by nlinarith⟩

/-- The all-plus pattern is never a child. -/
theorem allPlus_mem_quadNonChildren {a b c d : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hd : 0 < d) (h : IsPythQuadruple a b c d) :
    ((1 : ℤ), (1 : ℤ), (1 : ℤ)) ∈ quadNonChildren a b c d := by
  unfold quadNonChildren IsPythQuadruple at *
  refine Finset.mem_filter.mpr ⟨by decide, ?_⟩
  nlinarith [mul_pos hb hc]

/-- **Uniqueness of the exceptional non-child.**  Apart from the all-plus pattern, at most one
sign pattern fails to raise the height. -/
theorem quadNonChildren_unique {a b c d : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d)
    (h : IsPythQuadruple a b c d) {e f : ℤ × ℤ × ℤ}
    (he : e ∈ quadNonChildren a b c d) (hf : f ∈ quadNonChildren a b c d)
    (hen : e ≠ (1, 1, 1)) (hfn : f ≠ (1, 1, 1)) : e = f := by
  obtain ⟨had, hbd, hcd⟩ := coord_lt_height ha hb hc hd h
  rw [quadNonChildren, Finset.mem_filter] at he hf
  obtain ⟨hes, hed⟩ := he
  obtain ⟨hfs, hfd⟩ := hf
  fin_cases hes <;> fin_cases hfs <;> simp_all <;> omega

/-- The **weak harmonic defect** of a node: a single sign flip fails to raise the height. -/
def WeakDefect (a b c d : ℤ) : Prop := d ≤ -a + b + c ∨ d ≤ a - b + c ∨ d ≤ a + b - c

instance decidableWeakDefect (a b c d : ℤ) : Decidable (WeakDefect a b c d) := by
  unfold WeakDefect; infer_instance

/-- **Egyptian-fraction form of the defect**, extending the catalog's harmonic law
`HigherPythagorean.quad_minus_descent_iff` to the boundary case. -/
theorem weakDefect_iff_harmonic {a b c d : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d)
    (h : IsPythQuadruple a b c d) :
    WeakDefect a b c d ↔ (a * (b + c) ≤ b * c ∨ b * (a + c) ≤ a * c ∨ c * (a + b) ≤ a * b) := by
  unfold IsPythQuadruple at h
  unfold WeakDefect
  constructor
  · rintro (hx | hx | hx)
    · exact Or.inl (by nlinarith)
    · exact Or.inr (Or.inl (by nlinarith))
    · exact Or.inr (Or.inr (by nlinarith))
  · rintro (hx | hx | hx)
    · refine Or.inl ?_
      have hbc : a ≤ b + c := by nlinarith
      nlinarith
    · refine Or.inr (Or.inl ?_)
      have hbc : b ≤ a + c := by nlinarith
      nlinarith
    · refine Or.inr (Or.inr ?_)
      have hbc : c ≤ a + b := by nlinarith
      nlinarith

/-- **Exact branching in dimension three.**  A node with positive coordinates has `6` children
if it has the weak harmonic defect and `7` children otherwise. -/
theorem quad_children_card {a b c d : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d)
    (h : IsPythQuadruple a b c d) :
    (quadChildren a b c d).card = if WeakDefect a b c d then 6 else 7 := by
  have hplus := allPlus_mem_quadNonChildren ha hb hc hd h
  have hsum := quadChildren_card_add a b c d
  have hle : (quadNonChildren a b c d).card ≤ 2 := by
    have hsub : quadNonChildren a b c d ⊆
        insert ((1 : ℤ), (1 : ℤ), (1 : ℤ)) ((quadNonChildren a b c d).erase (1, 1, 1)) := by
      intro e he
      by_cases h1 : e = (1, 1, 1)
      · simp [h1]
      · exact Finset.mem_insert_of_mem (Finset.mem_erase.mpr ⟨h1, he⟩)
    have herase : ((quadNonChildren a b c d).erase (1, 1, 1)).card ≤ 1 := by
      rw [Finset.card_le_one]
      intro e he f hf
      rw [Finset.mem_erase] at he hf
      exact quadNonChildren_unique ha hb hc hd h he.2 hf.2 he.1 hf.1
    calc (quadNonChildren a b c d).card
        ≤ (insert ((1 : ℤ), (1 : ℤ), (1 : ℤ))
            ((quadNonChildren a b c d).erase (1, 1, 1))).card := Finset.card_le_card hsub
      _ ≤ ((quadNonChildren a b c d).erase (1, 1, 1)).card + 1 := Finset.card_insert_le _ _
      _ ≤ 2 := by omega
  by_cases hdef : WeakDefect a b c d
  · rw [if_pos hdef]
    have hex : ∃ e ∈ quadNonChildren a b c d, e ≠ ((1 : ℤ), (1 : ℤ), (1 : ℤ)) := by
      rcases hdef with hx | hx | hx
      · exact ⟨(-1, 1, 1), Finset.mem_filter.mpr ⟨by decide, by linarith⟩, by decide⟩
      · exact ⟨(1, -1, 1), Finset.mem_filter.mpr ⟨by decide, by linarith⟩, by decide⟩
      · exact ⟨(1, 1, -1), Finset.mem_filter.mpr ⟨by decide, by linarith⟩, by decide⟩
    obtain ⟨e, he, hene⟩ := hex
    have hlt : 1 < (quadNonChildren a b c d).card :=
      Finset.one_lt_card.mpr ⟨(1, 1, 1), hplus, e, he, fun hEq => hene hEq.symm⟩
    omega
  · rw [if_neg hdef]
    have honly : quadNonChildren a b c d = {((1 : ℤ), (1 : ℤ), (1 : ℤ))} := by
      apply Finset.eq_singleton_iff_unique_mem.mpr
      refine ⟨hplus, ?_⟩
      intro e he
      by_contra hne
      rw [quadNonChildren, Finset.mem_filter] at he
      obtain ⟨hes, hed⟩ := he
      refine hdef ?_
      unfold WeakDefect
      fin_cases hes <;> simp_all <;> omega
    rw [honly] at hsum
    simp at hsum
    omega

/-! ## Both branching numbers occur infinitely often -/

/-- The catalog's two-parent family `(1, 2m, 2m², 2m²+1)` has exactly **six** children. -/
theorem quad_children_six_family (m : ℤ) (hm : 2 ≤ m) :
    (quadChildren 1 (2 * m) (2 * m ^ 2) (2 * m ^ 2 + 1)).card = 6 := by
  have hpyth : IsPythQuadruple 1 (2 * m) (2 * m ^ 2) (2 * m ^ 2 + 1) := by
    unfold IsPythQuadruple; ring
  have hdef : WeakDefect 1 (2 * m) (2 * m ^ 2) (2 * m ^ 2 + 1) := by
    unfold WeakDefect; left; nlinarith
  rw [quad_children_card (by norm_num) (by linarith) (by nlinarith) (by nlinarith) hpyth,
    if_pos hdef]

/-- The family `(2m, 2m, 2m²−1, 2m²+1)` consists of Pythagorean quadruples. -/
theorem seven_family_isPyth (m : ℤ) :
    IsPythQuadruple (2 * m) (2 * m) (2 * m ^ 2 - 1) (2 * m ^ 2 + 1) := by
  unfold IsPythQuadruple; ring

/-- The family `(2m, 2m, 2m²−1, 2m²+1)` is primitive. -/
theorem seven_family_prim (m : ℤ) :
    IsPrimQuad (2 * m) (2 * m) (2 * m ^ 2 - 1) (2 * m ^ 2 + 1) := by
  refine ⟨seven_family_isPyth m, ?_⟩
  set g : ℕ := content (2 * m) (2 * m) (2 * m ^ 2 - 1) (2 * m ^ 2 + 1) with hg
  have h3 : (g : ℤ) ∣ (2 * m ^ 2 - 1) :=
    content_dvd_thd (2 * m) (2 * m) (2 * m ^ 2 - 1) (2 * m ^ 2 + 1)
  have h4 : (g : ℤ) ∣ (2 * m ^ 2 + 1) :=
    content_dvd_fth (2 * m) (2 * m) (2 * m ^ 2 - 1) (2 * m ^ 2 + 1)
  have hdvd2 : (g : ℤ) ∣ 2 := by
    have := dvd_sub h4 h3
    simpa using this
  have hg2 : g ∣ 2 := by exact_mod_cast hdvd2
  rcases (Nat.prime_two.eq_one_or_self_of_dvd g hg2) with h1 | h2
  · exact h1
  · exfalso
    rw [h2] at h3
    obtain ⟨k, hk⟩ := h3
    push_cast at hk
    generalize m ^ 2 = t at hk
    omega

/-- **Seven children.**  For `m ≥ 2` the primitive quadruple `(2m, 2m, 2m²−1, 2m²+1)` has no
harmonic defect, hence exactly seven children: the maximal branching number in dimension
three. -/
theorem quad_children_seven_family (m : ℤ) (hm : 2 ≤ m) :
    (quadChildren (2 * m) (2 * m) (2 * m ^ 2 - 1) (2 * m ^ 2 + 1)).card = 7 := by
  have hpyth := seven_family_isPyth m
  have hm0 : (0 : ℤ) < m := by linarith
  have hndef : ¬ WeakDefect (2 * m) (2 * m) (2 * m ^ 2 - 1) (2 * m ^ 2 + 1) := by
    unfold WeakDefect
    push_neg
    refine ⟨by nlinarith, by nlinarith, by nlinarith⟩
  rw [quad_children_card (by linarith) (by linarith) (by nlinarith) (by nlinarith) hpyth,
    if_neg hndef]

end HigherPythagoreanBranching