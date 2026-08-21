import Mathlib
import Catalog.Shared.Ispythquadruple.IsPythQuadruple
import Catalog.Shared.HigherPythagorean.LorentzCore
import Catalog.Shared.HigherPythagorean.QuadrupleTree

/-!
# Branching: why the Berggren tree is a tree in dimension 2 and **not** in dimension 3

A *descent* at a node is a sign pattern `ε ∈ {±1}ⁿ` for which the all-ones reflection move
strictly decreases the height.  Parents in a Berggren-type tree are exactly descents, so a node
has a unique parent iff it admits exactly one descent.

Main results.

* `triple_unique_descent` : a primitive Pythagorean triple with positive legs admits **exactly one**
  descent, namely `ε = (+,+)`.  This is the structural reason the Berggren graph is a *tree*.
* `quad_at_most_two_descents` : a Pythagorean quadruple admits at most **two** descents
  (`ε = (+,+,+)` and at most one pattern with a single minus sign).
* `quad_two_parents_family` : for every `m ≥ 2` the primitive quadruple `(1, 2m, 2m², 2m²+1)`
  really has two descents, landing on two *distinct* primitive quadruples of strictly smaller
  height, both of which are reachable from the root.  Hence the quadruple graph contains
  infinitely many nodes with two parents: it is **not** a tree.
* `triple_height_annulus`, `quad_height_annulus` : the exact integral form of the growth
  constants `3+2√2 = (1+√2)²` (triples, silver ratio) and `2+√3` (quadruples).
-/

namespace HigherPythagorean

/-- `e` is a sign. -/
def IsSign (e : ℤ) : Prop := e = 1 ∨ e = -1

/-! ## Triples: exactly one descent, hence a tree -/

/-- The sign pattern `(e₁,e₂)` descends at the triple `(a,b,c)` iff the reflected height
`3c − 2(e₁a+e₂b)` is smaller than `c`, i.e. iff `e₁a+e₂b > c`. -/
def TDescends (e₁ e₂ a b c : ℤ) : Prop := c < e₁ * a + e₂ * b

lemma tdescends_iff_height_lt (e₁ e₂ a b c : ℤ) :
    TDescends e₁ e₂ a b c ↔ 3 * c - 2 * (e₁ * a + e₂ * b) < c := by
  unfold TDescends; constructor <;> intro h <;> linarith

/-- The all-plus pattern always descends at a triple with positive legs. -/
theorem triple_plus_descends {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) : TDescends 1 1 a b c := by
  unfold TDescends
  nlinarith [mul_pos ha hb]

/-- Only the all-plus pattern can descend at a triple with positive legs. -/
theorem triple_only_plus_descends {a b c e₁ e₂ : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) (h1 : IsSign e₁) (h2 : IsSign e₂)
    (hd : TDescends e₁ e₂ a b c) : e₁ = 1 ∧ e₂ = 1 := by
  unfold TDescends at hd
  have hac : a < c := by nlinarith
  have hbc : b < c := by nlinarith
  rcases h1 with rfl | rfl <;> rcases h2 with rfl | rfl
  · exact ⟨rfl, rfl⟩
  · exfalso; nlinarith
  · exfalso; nlinarith
  · exfalso; nlinarith

/-- **Tree property in dimension two.**  A primitive Pythagorean triple with positive legs has
exactly one descent, i.e. a unique parent: the Berggren graph is a tree. -/
theorem triple_unique_descent {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    ∃! p : ℤ × ℤ, (IsSign p.1 ∧ IsSign p.2) ∧ TDescends p.1 p.2 a b c := by
  refine ⟨(1, 1), ⟨⟨Or.inl rfl, Or.inl rfl⟩, triple_plus_descends ha hb hc h⟩, ?_⟩
  rintro ⟨e₁, e₂⟩ ⟨⟨hs1, hs2⟩, hdes⟩
  obtain ⟨rfl, rfl⟩ := triple_only_plus_descends ha hb hc h hs1 hs2 hdes
  rfl

/-! ## Quadruples: at most two descents -/

/-- The sign pattern `(e₁,e₂,e₃)` descends at the quadruple `(a,b,c,d)` iff the reflected height
`2d − (e₁a+e₂b+e₃c)` is smaller than `d`. -/
def Descends (e₁ e₂ e₃ a b c d : ℤ) : Prop := d < e₁ * a + e₂ * b + e₃ * c

lemma descends_iff_height_lt (e₁ e₂ e₃ a b c d : ℤ) :
    Descends e₁ e₂ e₃ a b c d ↔ 2 * d - (e₁ * a + e₂ * b + e₃ * c) < d := by
  unfold Descends; constructor <;> intro h <;> linarith

/-- Each space coordinate of a Pythagorean quadruple is at most the height. -/
lemma coord_le_height {a b c d : ℤ} (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c) (hd : 0 < d)
    (h : IsPythQuadruple a b c d) : a ≤ d ∧ b ≤ d ∧ c ≤ d := by
  unfold IsPythQuadruple at h
  refine ⟨by nlinarith, by nlinarith, by nlinarith⟩

/-- A descending sign pattern has at most one minus sign. -/
theorem descend_at_most_one_minus {a b c d e₁ e₂ e₃ : ℤ} (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c)
    (hd : 0 < d) (h : IsPythQuadruple a b c d) (h1 : IsSign e₁) (h2 : IsSign e₂) (h3 : IsSign e₃)
    (hdes : Descends e₁ e₂ e₃ a b c d) :
    e₁ = 1 ∧ e₂ = 1 ∨ e₁ = 1 ∧ e₃ = 1 ∨ e₂ = 1 ∧ e₃ = 1 := by
  obtain ⟨had, hbd, hcd⟩ := coord_le_height ha hb hc hd h
  unfold Descends at hdes
  rcases h1 with rfl | rfl <;> rcases h2 with rfl | rfl <;> rcases h3 with rfl | rfl
  · exact Or.inl ⟨rfl, rfl⟩
  · exact Or.inl ⟨rfl, rfl⟩
  · exact Or.inr (Or.inl ⟨rfl, rfl⟩)
  · exfalso; linarith
  · exact Or.inr (Or.inr ⟨rfl, rfl⟩)
  · exfalso; linarith
  · exfalso; linarith
  · exfalso; linarith

/-- Two different one-minus patterns cannot both descend. -/
theorem descend_minus_index_unique {a b c d e₁ e₂ e₃ f₁ f₂ f₃ : ℤ} (ha : 0 ≤ a) (hb : 0 ≤ b)
    (hc : 0 ≤ c) (hd : 0 < d) (h : IsPythQuadruple a b c d)
    (h1 : IsSign e₁) (h2 : IsSign e₂) (h3 : IsSign e₃)
    (g1 : IsSign f₁) (g2 : IsSign f₂) (g3 : IsSign f₃)
    (hde : Descends e₁ e₂ e₃ a b c d) (hdf : Descends f₁ f₂ f₃ a b c d) :
    (e₁, e₂, e₃) = (1, 1, 1) ∨ (f₁, f₂, f₃) = (1, 1, 1) ∨ (e₁, e₂, e₃) = (f₁, f₂, f₃) := by
  obtain ⟨had, hbd, hcd⟩ := coord_le_height ha hb hc hd h
  unfold Descends at hde hdf
  rcases h1 with rfl | rfl <;> rcases h2 with rfl | rfl <;> rcases h3 with rfl | rfl <;>
    rcases g1 with rfl | rfl <;> rcases g2 with rfl | rfl <;> rcases g3 with rfl | rfl <;>
    simp_all <;> linarith

/-- **At most two parents.**  Any two descending sign patterns other than the all-plus one
coincide, so a Pythagorean quadruple has at most two descents. -/
theorem quad_at_most_two_descents {a b c d e₁ e₂ e₃ f₁ f₂ f₃ : ℤ} (ha : 0 ≤ a) (hb : 0 ≤ b)
    (hc : 0 ≤ c) (hd : 0 < d) (h : IsPythQuadruple a b c d)
    (h1 : IsSign e₁) (h2 : IsSign e₂) (h3 : IsSign e₃)
    (g1 : IsSign f₁) (g2 : IsSign f₂) (g3 : IsSign f₃)
    (hde : Descends e₁ e₂ e₃ a b c d) (hdf : Descends f₁ f₂ f₃ a b c d)
    (hep : (e₁, e₂, e₃) ≠ (1, 1, 1)) (hfp : (f₁, f₂, f₃) ≠ (1, 1, 1)) :
    (e₁, e₂, e₃) = (f₁, f₂, f₃) := by
  rcases descend_minus_index_unique ha hb hc hd h h1 h2 h3 g1 g2 g3 hde hdf with hx | hx | hx
  · exact absurd hx hep
  · exact absurd hx hfp
  · exact hx

/-! ## Content shortcuts -/

theorem content_eq_one_of_fst_one (b c d : ℤ) : content 1 b c d = 1 := by
  have h1 := content_dvd_fst 1 b c d
  have : (content 1 b c d : ℕ) ∣ 1 := by exact_mod_cast h1
  exact Nat.dvd_one.mp this

theorem content_eq_one_of_consecutive (a b c : ℤ) : content a b c (c + 1) = 1 := by
  have h3 := content_dvd_thd a b c (c + 1)
  have h4 := content_dvd_fth a b c (c + 1)
  have hone : (content a b c (c + 1) : ℤ) ∣ 1 := by
    have := dvd_sub h4 h3
    simpa using this
  have : (content a b c (c + 1) : ℕ) ∣ 1 := by exact_mod_cast hone
  exact Nat.dvd_one.mp this

/-! ## An infinite family of quadruples with two parents -/

/-- The family `(1, 2m, 2m², 2m²+1)` consists of primitive Pythagorean quadruples. -/
theorem family_isPrimQuad (m : ℤ) : IsPrimQuad 1 (2 * m) (2 * m ^ 2) (2 * m ^ 2 + 1) := by
  refine ⟨by unfold IsPythQuadruple; ring, content_eq_one_of_fst_one _ _ _⟩

/-- First parent of `(1, 2m, 2m², 2m²+1)`: the all-plus descent, of height `2m²−2m+1`. -/
theorem family_parentA (m : ℤ) :
    IsPrimQuad (2 * m - 1) 0 (2 * m ^ 2 - 2 * m) (2 * m ^ 2 - 2 * m + 1) := by
  refine ⟨by unfold IsPythQuadruple; ring, content_eq_one_of_consecutive _ _ _⟩

/-- Second parent of `(1, 2m, 2m², 2m²+1)`: the one-minus descent, of height `2m²−2m+3`. -/
theorem family_parentB (m : ℤ) :
    IsPrimQuad (2 * m - 1) 2 (2 * m ^ 2 - 2 * m + 2) (2 * m ^ 2 - 2 * m + 3) := by
  refine ⟨by unfold IsPythQuadruple; ring, ?_⟩
  have := content_eq_one_of_consecutive (2 * m - 1) 2 (2 * m ^ 2 - 2 * m + 2)
  simpa [show 2 * m ^ 2 - 2 * m + 2 + 1 = 2 * m ^ 2 - 2 * m + 3 by ring] using this

/-- Both descents of the family node are genuine descents. -/
theorem family_two_descents (m : ℤ) (hm : 2 ≤ m) :
    Descends 1 1 1 1 (2 * m) (2 * m ^ 2) (2 * m ^ 2 + 1) ∧
      Descends (-1) 1 1 1 (2 * m) (2 * m ^ 2) (2 * m ^ 2 + 1) := by
  constructor <;> · unfold Descends; nlinarith

/-- The two moves land on quadruples of the stated (distinct, strictly smaller) heights. -/
theorem family_parent_heights (m : ℤ) (hm : 2 ≤ m) :
    2 * (2 * m ^ 2 + 1) - (1 + 2 * m + 2 * m ^ 2) = 2 * m ^ 2 - 2 * m + 1 ∧
    2 * (2 * m ^ 2 + 1) - (-1 + 2 * m + 2 * m ^ 2) = 2 * m ^ 2 - 2 * m + 3 ∧
    2 * m ^ 2 - 2 * m + 1 < 2 * m ^ 2 + 1 ∧
    2 * m ^ 2 - 2 * m + 3 < 2 * m ^ 2 + 1 ∧
    (2 * m ^ 2 - 2 * m + 1 : ℤ) ≠ 2 * m ^ 2 - 2 * m + 3 := by
  refine ⟨by ring, by ring, by linarith, by linarith, by omega⟩

/-- The images of the two moves really are the two claimed parents. -/
theorem family_parent_images (m : ℤ) (hm : 2 ≤ m) :
    (|1 - qk 1 (2 * m) (2 * m ^ 2) (2 * m ^ 2 + 1)|,
      |2 * m - qk 1 (2 * m) (2 * m ^ 2) (2 * m ^ 2 + 1)|,
      |2 * m ^ 2 - qk 1 (2 * m) (2 * m ^ 2) (2 * m ^ 2 + 1)|,
      (2 * m ^ 2 + 1) - qk 1 (2 * m) (2 * m ^ 2) (2 * m ^ 2 + 1)) =
        (2 * m - 1, 0, 2 * m ^ 2 - 2 * m, 2 * m ^ 2 - 2 * m + 1) ∧
    (|(-1) - qk (-1) (2 * m) (2 * m ^ 2) (2 * m ^ 2 + 1)|,
      |2 * m - qk (-1) (2 * m) (2 * m ^ 2) (2 * m ^ 2 + 1)|,
      |2 * m ^ 2 - qk (-1) (2 * m) (2 * m ^ 2) (2 * m ^ 2 + 1)|,
      (2 * m ^ 2 + 1) - qk (-1) (2 * m) (2 * m ^ 2) (2 * m ^ 2 + 1)) =
        (2 * m - 1, 2, 2 * m ^ 2 - 2 * m + 2, 2 * m ^ 2 - 2 * m + 3) := by
  have hqk1 : qk 1 (2 * m) (2 * m ^ 2) (2 * m ^ 2 + 1) = 2 * m := by unfold qk; ring
  have hqk2 : qk (-1) (2 * m) (2 * m ^ 2) (2 * m ^ 2 + 1) = 2 * m - 2 := by unfold qk; ring
  constructor
  · rw [hqk1]
    have e1 : |1 - 2 * m| = 2 * m - 1 := by rw [abs_of_nonpos (by linarith)]; ring
    have e2 : |2 * m - 2 * m| = 0 := by simp
    have e3 : |2 * m ^ 2 - 2 * m| = 2 * m ^ 2 - 2 * m := abs_of_nonneg (by nlinarith)
    have e4 : 2 * m ^ 2 + 1 - 2 * m = 2 * m ^ 2 - 2 * m + 1 := by ring
    rw [e1, e2, e3, e4]
  · rw [hqk2]
    have e1 : |(-1 : ℤ) - (2 * m - 2)| = 2 * m - 1 := by rw [abs_of_nonpos (by linarith)]; ring
    have e2 : |2 * m - (2 * m - 2)| = 2 := by rw [abs_of_nonneg (by linarith)]; ring
    have e3 : |2 * m ^ 2 - (2 * m - 2)| = 2 * m ^ 2 - 2 * m + 2 := by
      rw [abs_of_nonneg (by nlinarith)]; ring
    have e4 : 2 * m ^ 2 + 1 - (2 * m - 2) = 2 * m ^ 2 - 2 * m + 3 := by ring
    rw [e1, e2, e3, e4]

/-- **The quadruple graph is not a tree.**  For every `m ≥ 2` the primitive quadruple
`(1, 2m, 2m², 2m²+1)` has two distinct descents, landing on two primitive quadruples of
different (strictly smaller) heights, both reachable from the root.  In particular no
consistent notion of "the" parent exists, and the graph carries infinitely many cycles. -/
theorem quad_two_parents_family (m : ℤ) (hm : 2 ≤ m) :
    IsPrimQuad 1 (2 * m) (2 * m ^ 2) (2 * m ^ 2 + 1) ∧
    Descends 1 1 1 1 (2 * m) (2 * m ^ 2) (2 * m ^ 2 + 1) ∧
    Descends (-1) 1 1 1 (2 * m) (2 * m ^ 2) (2 * m ^ 2 + 1) ∧
    IsPrimQuad (2 * m - 1) 0 (2 * m ^ 2 - 2 * m) (2 * m ^ 2 - 2 * m + 1) ∧
    IsPrimQuad (2 * m - 1) 2 (2 * m ^ 2 - 2 * m + 2) (2 * m ^ 2 - 2 * m + 3) ∧
    Reach (2 * m - 1) 0 (2 * m ^ 2 - 2 * m) (2 * m ^ 2 - 2 * m + 1) ∧
    Reach (2 * m - 1) 2 (2 * m ^ 2 - 2 * m + 2) (2 * m ^ 2 - 2 * m + 3) ∧
    (2 * m ^ 2 - 2 * m + 1 : ℤ) ≠ 2 * m ^ 2 - 2 * m + 3 := by
  obtain ⟨hd1, hd2⟩ := family_two_descents m hm
  obtain ⟨hA1, hA2⟩ := family_parentA m
  obtain ⟨hB1, hB2⟩ := family_parentB m
  refine ⟨family_isPrimQuad m, hd1, hd2, ⟨hA1, hA2⟩, ⟨hB1, hB2⟩, ?_, ?_, by omega⟩
  · exact reach_of_prim (2 * m ^ 2 - 2 * m + 1).toNat _ _ _ _ le_rfl (by linarith) le_rfl
      (by nlinarith) (by nlinarith) hA1 hA2
  · exact reach_of_prim (2 * m ^ 2 - 2 * m + 3).toNat _ _ _ _ le_rfl (by linarith) (by norm_num)
      (by nlinarith) (by nlinarith) hB1 hB2

/-- Consequently the analogue of `triple_unique_descent` **fails** in dimension three. -/
theorem quad_descent_not_unique (m : ℤ) (hm : 2 ≤ m) :
    ¬ ∃! p : ℤ × ℤ × ℤ, (IsSign p.1 ∧ IsSign p.2.1 ∧ IsSign p.2.2) ∧
      Descends p.1 p.2.1 p.2.2 1 (2 * m) (2 * m ^ 2) (2 * m ^ 2 + 1) := by
  rintro ⟨p, -, huniq⟩
  obtain ⟨hd1, hd2⟩ := family_two_descents m hm
  have e1 : ((1 : ℤ), (1 : ℤ), (1 : ℤ)) = p :=
    huniq _ ⟨⟨Or.inl rfl, Or.inl rfl, Or.inl rfl⟩, hd1⟩
  have e2 : ((-1 : ℤ), (1 : ℤ), (1 : ℤ)) = p :=
    huniq _ ⟨⟨Or.inr rfl, Or.inl rfl, Or.inl rfl⟩, hd2⟩
  rw [← e2] at e1
  simp at e1

/-! ## Integral form of the growth constants -/

/-- For a Pythagorean triple, `S = e₁a+e₂b` satisfies `S² ≤ 2c²`; equivalently the height ratio
of a Berggren move lies in `[3−2√2, 3+2√2] = [(√2−1)², (√2+1)²]`, the silver-ratio annulus. -/
theorem triple_height_annulus {a b c e₁ e₂ : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2)
    (h1 : IsSign e₁) (h2 : IsSign e₂) :
    (3 * c - 2 * (e₁ * a + e₂ * b)) ^ 2 - 6 * c * (3 * c - 2 * (e₁ * a + e₂ * b)) + c ^ 2 ≤ 0 := by
  have hS : (e₁ * a + e₂ * b) ^ 2 ≤ 2 * c ^ 2 := by
    rcases h1 with rfl | rfl <;> rcases h2 with rfl | rfl <;> nlinarith [sq_nonneg (a - b),
      sq_nonneg (a + b)]
  nlinarith [hS]

/-- For a Pythagorean quadruple, `S = e₁a+e₂b+e₃c` satisfies `S² ≤ 3d²`; equivalently the height
ratio of a reflection move lies in `[2−√3, 2+√3]`, the dimension-three analogue of the
silver-ratio annulus. -/
theorem quad_height_annulus {a b c d e₁ e₂ e₃ : ℤ} (h : IsPythQuadruple a b c d)
    (h1 : IsSign e₁) (h2 : IsSign e₂) (h3 : IsSign e₃) :
    (2 * d - (e₁ * a + e₂ * b + e₃ * c)) ^ 2
      - 4 * d * (2 * d - (e₁ * a + e₂ * b + e₃ * c)) + d ^ 2 ≤ 0 := by
  unfold IsPythQuadruple at h
  have hS : (e₁ * a + e₂ * b + e₃ * c) ^ 2 ≤ 3 * d ^ 2 := by
    rcases h1 with rfl | rfl <;> rcases h2 with rfl | rfl <;> rcases h3 with rfl | rfl <;>
      nlinarith [sq_nonneg (a - b), sq_nonneg (b - c), sq_nonneg (a - c), sq_nonneg (a + b),
        sq_nonneg (b + c), sq_nonneg (a + c)]
  nlinarith [hS]

end HigherPythagorean