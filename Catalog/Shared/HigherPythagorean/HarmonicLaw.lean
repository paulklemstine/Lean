import Mathlib
import Catalog.Shared.Ispythquadruple.IsPythQuadruple
import Catalog.Shared.HigherPythagorean.LorentzCore
import Catalog.Shared.HigherPythagorean.QuadrupleTree
import Catalog.Shared.HigherPythagorean.BranchingContrast

/-!
# The harmonic branching law for Pythagorean quadruples

`BranchingContrast` shows that a Pythagorean quadruple has at most two parents.  Here we
determine *exactly when* the second parent exists, and the answer is an Egyptian-fraction
("harmonic") law:

> the reflection move with a minus sign on the coordinate `a` descends **iff** `1/a > 1/b + 1/c`.

This is the dimension-three replacement for the (empty) second-parent condition of the Berggren
tree, and it explains all the phenomena observed in dimension three:

* `quad_minus_descent_iff` / `quad_minus_descent_iff_rat` : the law, in integral and harmonic form.
* `harmonic_law_at_most_one_index` : the harmonic inequality can hold for at most one coordinate
  (a two-line proof of the "at most two parents" bound).
* `quad_neutral_move_iff` : the boundary case `1/a = 1/b + 1/c` gives a *height preserving*
  ("horizontal") move — a phenomenon that does not exist for triples (`triple_no_neutral_move`),
  realised e.g. by the quadruple `(1,2,2,3)`.
* `quad_one_descent_family` : the family `(2m, 2m, 2m²−1, 2m²+1)` has a **unique** parent, while
  `(1, 2m, 2m², 2m²+1)` has two; hence (`quad_branching_not_constant`) the branching number of
  the quadruple graph is genuinely non-constant, taking both possible values infinitely often.
-/

namespace HigherPythagorean

/-! ## The harmonic law -/

/-- **Harmonic branching law (integral form).**  The move with a minus sign on the first
coordinate strictly decreases the height iff `a(b+c) < bc`. -/
theorem quad_minus_descent_iff {a b c d : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d)
    (h : IsPythQuadruple a b c d) : Descends (-1) 1 1 a b c d ↔ a * (b + c) < b * c := by
  unfold IsPythQuadruple at h
  unfold Descends
  constructor
  · intro hdes
    nlinarith
  · intro hlaw
    have hbc : a < b + c := by nlinarith
    nlinarith

/-- **Harmonic branching law (Egyptian-fraction form).**  The second parent exists exactly when
the reciprocal of one leg exceeds the sum of the reciprocals of the other two. -/
theorem quad_minus_descent_iff_rat {a b c d : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hd : 0 < d) (h : IsPythQuadruple a b c d) :
    Descends (-1) 1 1 a b c d ↔ (1 : ℚ) / (b : ℚ) + 1 / (c : ℚ) < 1 / (a : ℚ) := by
  rw [quad_minus_descent_iff ha hb hc hd h]
  have ha' : (0 : ℚ) < (a : ℚ) := by exact_mod_cast ha
  have hb' : (0 : ℚ) < (b : ℚ) := by exact_mod_cast hb
  have hc' : (0 : ℚ) < (c : ℚ) := by exact_mod_cast hc
  rw [div_add_div _ _ (ne_of_gt hb') (ne_of_gt hc'), div_lt_div_iff₀ (by positivity) ha']
  constructor
  · intro hlaw
    have : ((a : ℚ)) * ((b : ℚ) + (c : ℚ)) < (b : ℚ) * (c : ℚ) := by exact_mod_cast hlaw
    nlinarith
  · intro hlaw
    have : ((a : ℚ)) * ((b : ℚ) + (c : ℚ)) < (b : ℚ) * (c : ℚ) := by nlinarith
    exact_mod_cast this

/-- The harmonic inequality can hold for at most one coordinate: a two-line proof that a
Pythagorean quadruple has at most two parents. -/
theorem harmonic_law_at_most_one_index {a b c : ℤ} (ha : 0 < a) (hb : 0 < b)
    (h1 : a * (b + c) < b * c) (h2 : b * (a + c) < a * c) : False := by
  nlinarith [mul_pos ha hb]

/-! ## Neutral (height preserving) moves -/

/-- The boundary case of the harmonic law gives a *height preserving* move.  Such horizontal
edges exist in dimension three (e.g. at `(1,2,2,3)`) and are impossible in dimension two. -/
theorem quad_neutral_move_iff {a b c d : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d)
    (h : IsPythQuadruple a b c d) :
    2 * d - ((-1) * a + b + c) = d ↔ a * (b + c) = b * c := by
  unfold IsPythQuadruple at h
  constructor
  · intro hneutral
    nlinarith
  · intro hlaw
    have hbc : a < b + c := by nlinarith
    nlinarith

/-- The quadruple `(1,2,2,3)` is primitive and carries a neutral (horizontal) move. -/
theorem neutral_example :
    IsPrimQuad 1 2 2 3 ∧ 2 * 3 - ((-1) * 1 + 2 + 2) = 3 ∧ (1 : ℤ) * (2 + 2) = 2 * 2 := by
  refine ⟨⟨by unfold IsPythQuadruple; norm_num, ?_⟩, by norm_num, by norm_num⟩
  exact content_eq_one_of_fst_one 2 2 3

/-- In dimension two there are no neutral moves: every non-plus pattern *strictly* increases the
height of a triple with positive legs. -/
theorem triple_no_neutral_move {a b c e₁ e₂ : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) (h1 : IsSign e₁) (h2 : IsSign e₂)
    (hne : ¬(e₁ = 1 ∧ e₂ = 1)) : c < 3 * c - 2 * (e₁ * a + e₂ * b) := by
  have hac : a < c := by nlinarith
  have hbc : b < c := by nlinarith
  rcases h1 with rfl | rfl <;> rcases h2 with rfl | rfl
  · exact absurd ⟨rfl, rfl⟩ hne
  · linarith
  · linarith
  · linarith

/-! ## A family with a unique parent -/

lemma descends_swap12 (a b c d : ℤ) : Descends 1 (-1) 1 a b c d ↔ Descends (-1) 1 1 b a c d := by
  unfold Descends; constructor <;> intro h <;> linarith

lemma descends_swap13 (a b c d : ℤ) : Descends 1 1 (-1) a b c d ↔ Descends (-1) 1 1 c b a d := by
  unfold Descends; constructor <;> intro h <;> linarith

/-- The family `(2m, 2m, 2m²−1, 2m²+1)` consists of primitive Pythagorean quadruples. -/
theorem oneParent_family_isPrimQuad (m : ℤ) :
    IsPrimQuad (2 * m) (2 * m) (2 * m ^ 2 - 1) (2 * m ^ 2 + 1) := by
  refine ⟨by unfold IsPythQuadruple; ring, ?_⟩
  have h3 := content_dvd_thd (2 * m) (2 * m) (2 * m ^ 2 - 1) (2 * m ^ 2 + 1)
  have h4 := content_dvd_fth (2 * m) (2 * m) (2 * m ^ 2 - 1) (2 * m ^ 2 + 1)
  have h2 : ((content (2 * m) (2 * m) (2 * m ^ 2 - 1) (2 * m ^ 2 + 1) : ℕ) : ℤ) ∣ 2 := by
    have := dvd_sub h4 h3
    simpa [show 2 * m ^ 2 + 1 - (2 * m ^ 2 - 1) = 2 from by ring] using this
  have hg2 : content (2 * m) (2 * m) (2 * m ^ 2 - 1) (2 * m ^ 2 + 1) ∣ 2 := by exact_mod_cast h2
  rcases (Nat.prime_two.eq_one_or_self_of_dvd _ hg2) with h | h
  · exact h
  · exfalso
    rw [h] at h3
    omega

/-- **Unique parent for the family `(2m, 2m, 2m²−1, 2m²+1)`.**  In contrast with
`quad_two_parents_family`, these nodes admit exactly one descent. -/
theorem quad_one_descent_family (m : ℤ) (hm : 2 ≤ m) :
    ∃! p : ℤ × ℤ × ℤ, (IsSign p.1 ∧ IsSign p.2.1 ∧ IsSign p.2.2) ∧
      Descends p.1 p.2.1 p.2.2 (2 * m) (2 * m) (2 * m ^ 2 - 1) (2 * m ^ 2 + 1) := by
  have hpos1 : (0 : ℤ) < 2 * m := by linarith
  have hpos3 : (0 : ℤ) < 2 * m ^ 2 - 1 := by nlinarith
  have hposd : (0 : ℤ) < 2 * m ^ 2 + 1 := by nlinarith
  have hq : IsPythQuadruple (2 * m) (2 * m) (2 * m ^ 2 - 1) (2 * m ^ 2 + 1) := by
    unfold IsPythQuadruple; ring
  have hq12 : IsPythQuadruple (2 * m) (2 * m) (2 * m ^ 2 - 1) (2 * m ^ 2 + 1) := hq
  have hq13 : IsPythQuadruple (2 * m ^ 2 - 1) (2 * m) (2 * m) (2 * m ^ 2 + 1) := by
    unfold IsPythQuadruple; ring
  refine ⟨(1, 1, 1), ⟨⟨Or.inl rfl, Or.inl rfl, Or.inl rfl⟩, by unfold Descends; nlinarith⟩, ?_⟩
  rintro ⟨e₁, e₂, e₃⟩ ⟨⟨hs1, hs2, hs3⟩, hdes⟩
  -- no coordinate satisfies the harmonic inequality
  have hno1 : ¬ Descends (-1) 1 1 (2 * m) (2 * m) (2 * m ^ 2 - 1) (2 * m ^ 2 + 1) := by
    rw [quad_minus_descent_iff hpos1 hpos1 hpos3 hposd hq]
    push_neg
    nlinarith
  have hno2 : ¬ Descends 1 (-1) 1 (2 * m) (2 * m) (2 * m ^ 2 - 1) (2 * m ^ 2 + 1) := by
    rw [descends_swap12, quad_minus_descent_iff hpos1 hpos1 hpos3 hposd hq12]
    push_neg
    nlinarith
  have hno3 : ¬ Descends 1 1 (-1) (2 * m) (2 * m) (2 * m ^ 2 - 1) (2 * m ^ 2 + 1) := by
    rw [descends_swap13, quad_minus_descent_iff hpos3 hpos1 hpos1 hposd hq13]
    push_neg
    nlinarith
  have hcoord := descend_at_most_one_minus (le_of_lt hpos1) (le_of_lt hpos1) (le_of_lt hpos3)
    hposd hq hs1 hs2 hs3 hdes
  rcases hs1 with rfl | rfl <;> rcases hs2 with rfl | rfl <;> rcases hs3 with rfl | rfl
  · rfl
  · exact absurd hdes hno3
  · exact absurd hdes hno2
  · simp at hcoord
  · exact absurd hdes hno1
  · simp at hcoord
  · simp at hcoord
  · simp at hcoord

/-- **The branching number of the quadruple graph is not constant.**  Above any height there are
primitive quadruples with a unique parent and primitive quadruples with two distinct parents. -/
theorem quad_branching_not_constant (N : ℤ) :
    (∃ a b c d : ℤ, N < d ∧ IsPrimQuad a b c d ∧
      ∃! p : ℤ × ℤ × ℤ, (IsSign p.1 ∧ IsSign p.2.1 ∧ IsSign p.2.2) ∧
        Descends p.1 p.2.1 p.2.2 a b c d) ∧
    (∃ a b c d : ℤ, N < d ∧ IsPrimQuad a b c d ∧
      Descends 1 1 1 a b c d ∧ Descends (-1) 1 1 a b c d) := by
  set m := max 2 N with hm
  have hm2 : 2 ≤ m := le_max_left _ _
  have hmN : N ≤ m := le_max_right _ _
  have hbig : N < 2 * m ^ 2 + 1 := by nlinarith
  refine ⟨⟨2 * m, 2 * m, 2 * m ^ 2 - 1, 2 * m ^ 2 + 1, hbig,
      oneParent_family_isPrimQuad m, quad_one_descent_family m hm2⟩, ?_⟩
  obtain ⟨hprim, hd1, hd2, -⟩ := quad_two_parents_family m hm2
  exact ⟨1, 2 * m, 2 * m ^ 2, 2 * m ^ 2 + 1, hbig, hprim, hd1, hd2⟩

end HigherPythagorean