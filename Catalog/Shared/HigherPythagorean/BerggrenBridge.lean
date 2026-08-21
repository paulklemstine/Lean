import Mathlib
import Catalog.Bridges.BerggrenTrees.BerggrenPythagoreanCore
import Catalog.Shared.HigherPythagorean.LorentzCore
import Catalog.Shared.HigherPythagorean.QuadrupleTree
import Catalog.Shared.HigherPythagorean.BranchingContrast

/-!
# Bridge to the classical Berggren moves, and the child count

The catalog contains the three classical Berggren moves `bergA`, `bergB`, `bergC` and their
matrices `B₁_mat`, `B₂_mat`, `B₃_mat` acting on Pythagorean triples.  Here we show that they are
*exactly* the dimension-two instance of the machinery of this development:

* `bergA_eq_tripleMove`, `bergB_eq_tripleMove`, `bergC_eq_tripleMove` : each Berggren move is the
  all-ones Lorentz reflection precomposed with one of the three non-trivial sign patterns, and the
  remaining (all-plus) pattern is the descent, i.e. the parent map (`tripleMove_plus_eq_parent`).
* `lorentzJ_two`, `B₃_isIntegralLorentz` : the catalog Gram matrix `QLor` is our `lorentzJ 2`, and
  the Berggren matrices are integral Lorentz automorphisms in the sense of `LorentzCore`.
* `triple_child_count` : in dimension two exactly `4 − 1 = 3` of the four sign patterns are
  non-descending: the Berggren tree is **ternary**.
* `quad_child_count_ge` : in dimension three at least `8 − 2 = 6` of the eight sign patterns are
  non-descending, and both values `6` and `7` occur (see `HarmonicLaw`).
-/

namespace HigherPythagorean

open Matrix

/-! ## The three Berggren moves are reflection ∘ sign -/

/-- The dimension-two all-ones reflection move with sign pattern `(e₁,e₂)`: it subtracts
`2k`, `k = e₁a+e₂b−c`, from every coordinate of `(e₁a, e₂b, c)`. -/
def tripleMove (e₁ e₂ a b c : ℤ) : ℤ × ℤ × ℤ :=
  (e₁ * a - 2 * (e₁ * a + e₂ * b - c), e₂ * b - 2 * (e₁ * a + e₂ * b - c),
    c - 2 * (e₁ * a + e₂ * b - c))

theorem bergA_eq_tripleMove (a b c : ℤ) : bergA a b c = tripleMove (-1) 1 a b c := by
  simp only [bergA, tripleMove]
  refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> simp <;> ring

theorem bergB_eq_tripleMove (a b c : ℤ) : bergB a b c = tripleMove (-1) (-1) a b c := by
  simp only [bergB, tripleMove]
  refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> simp <;> ring

theorem bergC_eq_tripleMove (a b c : ℤ) : bergC a b c = tripleMove 1 (-1) a b c := by
  simp only [bergC, tripleMove]
  refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> simp <;> ring

/-- The remaining sign pattern is the descent: its hypotenuse is the catalog's parent
hypotenuse `3c − 2(a+b)`. -/
theorem tripleMove_plus_eq_parent (a b c : ℤ) :
    (tripleMove 1 1 a b c).2.2 = -2 * a - 2 * b + 3 * c := by
  simp only [tripleMove]; ring

/-- The catalog's parent estimate `parent_hyp_lt` is exactly the statement that the all-plus
pattern descends. -/
theorem parent_hyp_lt_iff_tdescends {a b c : ℤ} :
    (tripleMove 1 1 a b c).2.2 < c ↔ TDescends 1 1 a b c := by
  rw [tripleMove_plus_eq_parent]
  unfold TDescends
  constructor <;> intro h <;> linarith

/-! ## The Berggren matrices in the Lorentz framework -/

theorem lorentzJ_two : lorentzJ 2 = QLor := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [lorentzJ, QLor, Matrix.diagonal, Fin.last, Fin.ext_iff]

theorem B₁_isIntegralLorentz : IsIntegralLorentz B₁_mat := by
  unfold IsIntegralLorentz
  rw [lorentzJ_two]
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [B₁_mat, QLor, Matrix.mul_apply, Fin.sum_univ_three]

theorem B₂_isIntegralLorentz : IsIntegralLorentz B₂_mat := by
  unfold IsIntegralLorentz
  rw [lorentzJ_two]
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [B₂_mat, QLor, Matrix.mul_apply, Fin.sum_univ_three]

theorem B₃_isIntegralLorentz : IsIntegralLorentz B₃_mat := by
  unfold IsIntegralLorentz
  rw [lorentzJ_two]
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [B₃_mat, QLor, Matrix.mul_apply, Fin.sum_univ_three]

/-- The catalog matrix `B₃_mat` implements the Berggren move `bergC`, i.e. the reflection with
sign pattern `(+,−)`. -/
theorem B₃_mulVec (a b c : ℤ) :
    B₃_mat *ᵥ ![a, b, c] =
      ![(tripleMove 1 (-1) a b c).1, (tripleMove 1 (-1) a b c).2.1,
        (tripleMove 1 (-1) a b c).2.2] := by
  ext i
  fin_cases i <;>
    simp [B₃_mat, tripleMove, Matrix.mulVec, dotProduct, Fin.sum_univ_three] <;> ring

/-! ## Counting children -/

open scoped Classical in
/-- The four sign patterns in dimension two. -/
def tripleSignPatterns : Finset (ℤ × ℤ) := {(1, 1), (1, -1), (-1, 1), (-1, -1)}

open scoped Classical in
/-- The eight sign patterns in dimension three. -/
def quadSignPatterns : Finset (ℤ × ℤ × ℤ) :=
  {(1, 1, 1), (1, 1, -1), (1, -1, 1), (1, -1, -1),
   (-1, 1, 1), (-1, 1, -1), (-1, -1, 1), (-1, -1, -1)}

open scoped Classical in
/-- **The Berggren tree is ternary**: for a primitive Pythagorean triple with positive legs,
exactly three of the four sign patterns fail to descend, i.e. every node has three children. -/
theorem triple_child_count {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (tripleSignPatterns.filter (fun p => ¬ TDescends p.1 p.2 a b c)).card = 3 := by
  have h11 : TDescends 1 1 a b c := triple_plus_descends ha hb hc h
  have hne : ∀ e₁ e₂ : ℤ, IsSign e₁ → IsSign e₂ → ¬(e₁ = 1 ∧ e₂ = 1) → ¬ TDescends e₁ e₂ a b c := by
    intro e₁ e₂ hs1 hs2 hno hdes
    exact hno (triple_only_plus_descends ha hb hc h hs1 hs2 hdes)
  have h1 : ¬ TDescends 1 (-1) a b c := hne 1 (-1) (Or.inl rfl) (Or.inr rfl) (by simp)
  have h2 : ¬ TDescends (-1) 1 a b c := hne (-1) 1 (Or.inr rfl) (Or.inl rfl) (by simp)
  have h3 : ¬ TDescends (-1) (-1) a b c := hne (-1) (-1) (Or.inr rfl) (Or.inr rfl) (by simp)
  have hset : tripleSignPatterns.filter (fun p => ¬ TDescends p.1 p.2 a b c) =
      {(1, -1), (-1, 1), (-1, -1)} := by
    ext p
    simp only [tripleSignPatterns, Finset.mem_filter, Finset.mem_insert, Finset.mem_singleton]
    constructor
    · rintro ⟨hp, hnd⟩
      rcases hp with rfl | rfl | rfl | rfl
      · exact absurd h11 hnd
      · exact Or.inl rfl
      · exact Or.inr (Or.inl rfl)
      · exact Or.inr (Or.inr rfl)
    · rintro (rfl | rfl | rfl)
      · exact ⟨by simp, h1⟩
      · exact ⟨by simp, h2⟩
      · exact ⟨by simp, h3⟩
  rw [hset]
  decide

open scoped Classical in
/-- At most two of the eight sign patterns descend at a Pythagorean quadruple. -/
theorem quad_descending_card_le_two {a b c d : ℤ} (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c)
    (hd : 0 < d) (h : IsPythQuadruple a b c d) :
    (quadSignPatterns.filter (fun p => Descends p.1 p.2.1 p.2.2 a b c d)).card ≤ 2 := by
  set T := quadSignPatterns.filter (fun p => Descends p.1 p.2.1 p.2.2 a b c d) with hT
  have hsign : ∀ p ∈ quadSignPatterns, IsSign p.1 ∧ IsSign p.2.1 ∧ IsSign p.2.2 := by
    intro p hp
    simp only [quadSignPatterns, Finset.mem_insert, Finset.mem_singleton] at hp
    rcases hp with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
      exact ⟨by simp [IsSign], by simp [IsSign], by simp [IsSign]⟩
  have hsub : ∀ x ∈ T.erase (1, 1, 1), ∀ y ∈ T.erase (1, 1, 1), x = y := by
    intro x hx y hy
    have hx' := Finset.mem_of_mem_erase hx
    have hy' := Finset.mem_of_mem_erase hy
    have hxne : x ≠ (1, 1, 1) := Finset.ne_of_mem_erase hx
    have hyne : y ≠ (1, 1, 1) := Finset.ne_of_mem_erase hy
    rw [hT, Finset.mem_filter] at hx' hy'
    obtain ⟨hxmem, hxdes⟩ := hx'
    obtain ⟨hymem, hydes⟩ := hy'
    obtain ⟨hs1, hs2, hs3⟩ := hsign x hxmem
    obtain ⟨ht1, ht2, ht3⟩ := hsign y hymem
    have := quad_at_most_two_descents ha hb hc hd h hs1 hs2 hs3 ht1 ht2 ht3 hxdes hydes
      (by simpa using hxne) (by simpa using hyne)
    simpa using this
  have hcard1 : (T.erase (1, 1, 1)).card ≤ 1 := Finset.card_le_one.mpr hsub
  by_cases hmem : ((1 : ℤ), (1 : ℤ), (1 : ℤ)) ∈ T
  · have := Finset.card_erase_of_mem hmem
    omega
  · rw [Finset.erase_eq_of_notMem hmem] at hcard1
    omega

open scoped Classical in
/-- **At least six children in dimension three.**  Of the eight sign patterns at a Pythagorean
quadruple, at least six fail to descend.  Together with `HarmonicLaw.quad_branching_not_constant`
this shows the branching number takes both values `6` and `7` infinitely often — in contrast with
the constant ternary branching of the Berggren tree. -/
theorem quad_child_count_ge {a b c d : ℤ} (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c) (hd : 0 < d)
    (h : IsPythQuadruple a b c d) :
    6 ≤ (quadSignPatterns.filter (fun p => ¬ Descends p.1 p.2.1 p.2.2 a b c d)).card := by
  have hcard : (quadSignPatterns.filter (fun p => Descends p.1 p.2.1 p.2.2 a b c d)).card +
      (quadSignPatterns.filter (fun p => ¬ Descends p.1 p.2.1 p.2.2 a b c d)).card =
      quadSignPatterns.card := Finset.card_filter_add_card_filter_not _
  have h8 : quadSignPatterns.card = 8 := by decide
  have hle := quad_descending_card_le_two ha hb hc hd h
  omega

end HigherPythagorean