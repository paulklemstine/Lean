import Mathlib
import Catalog.Shared.Ispythquadruple.IsPythQuadruple
import Catalog.Shared.HigherPythagorean.LorentzCore
import Catalog.Shared.HigherPythagorean.QuadrupleTree
import Catalog.Shared.HigherPythagorean.QuadrupleGroupoid

/-!
# The canonical spanning tree of the Pythagorean quadruple graph

The quadruple graph is not a tree (`BranchingContrast.quad_two_parents_family`), but the
all-plus reflection singles out a *canonical* parent, and this canonical parent map does define
a rooted tree structure: it preserves primitivity, strictly decreases the height above height
one, and its iterates reach a node of height one in finitely many steps; the nodes of height one
are exactly the three permutations of the root `(1,0,0,1)`.

* `canonStep` : the canonical parent map.
* `canonStep_isNode` : it preserves the class of primitive non-negative nodes.
* `canonStep_height_lt` : it strictly decreases the height above height one.
* `height_one_classification` : the height-one nodes are the permutations of `(1,0,0,1)`.
* `canonStep_iterate_reaches_root` : finitely many canonical steps reach height one — the
  canonical parent map is well-founded, so the graph has a canonical spanning tree.
-/

namespace HigherPythagorean

/-- A node: a primitive Pythagorean quadruple in the positive cone. -/
def IsNode (p : Quad) : Prop :=
  0 ≤ p.1 ∧ 0 ≤ p.2.1 ∧ 0 ≤ p.2.2.1 ∧ 0 < p.2.2.2 ∧
    IsPythQuadruple p.1 p.2.1 p.2.2.1 p.2.2.2 ∧ content p.1 p.2.1 p.2.2.1 p.2.2.2 = 1

/-- The canonical parent map: the all-plus reflection followed by taking absolute values. -/
def canonStep (p : Quad) : Quad :=
  (|p.1 - qk p.1 p.2.1 p.2.2.1 p.2.2.2|, |p.2.1 - qk p.1 p.2.1 p.2.2.1 p.2.2.2|,
    |p.2.2.1 - qk p.1 p.2.1 p.2.2.1 p.2.2.2|, p.2.2.2 - qk p.1 p.2.1 p.2.2.1 p.2.2.2)

/-- The canonical parent of a node is a node. -/
theorem canonStep_isNode {p : Quad} (h : IsNode p) : IsNode (canonStep p) := by
  obtain ⟨a, b, c, d⟩ := p
  obtain ⟨ha, hb, hc, hd, hpyth, hcont⟩ := h
  refine ⟨abs_nonneg _, abs_nonneg _, abs_nonneg _, ?_, ?_, ?_⟩
  · exact sub_qk_pos ha hb hc hd hpyth
  · have hmove := qmove_pyth hpyth
    unfold IsPythQuadruple at hmove ⊢
    simp only [canonStep]
    rw [sq_abs, sq_abs, sq_abs]
    exact hmove
  · simp only [canonStep]
    rw [content_abs3, content_move]
    exact hcont

/-- Above height one the canonical parent map strictly decreases the height. -/
theorem canonStep_height_lt {p : Quad} (h : IsNode p) (hd : 1 < p.2.2.2) :
    (canonStep p).2.2.2 < p.2.2.2 := by
  obtain ⟨a, b, c, d⟩ := p
  obtain ⟨ha, hb, hc, hd0, hpyth, hcont⟩ := h
  dsimp only at ha hb hc hd0 hpyth hcont
  replace hd : 1 < d := hd
  have hk := qk_pos ha hb hc hd hpyth hcont
  show d - qk a b c d < d
  omega

/-- The nodes of height one are exactly the three permutations of the root `(1,0,0,1)`. -/
theorem height_one_classification {p : Quad} (h : IsNode p) (hd : p.2.2.2 = 1) :
    p = (1, 0, 0, 1) ∨ p = (0, 1, 0, 1) ∨ p = (0, 0, 1, 1) := by
  obtain ⟨a, b, c, d⟩ := p
  obtain ⟨ha, hb, hc, hd0, hpyth, hcont⟩ := h
  simp only at hd
  subst hd
  unfold IsPythQuadruple at hpyth
  have h' : a ^ 2 + b ^ 2 + c ^ 2 = 1 := by linarith
  have ha1 : a ≤ 1 := by nlinarith
  have hb1 : b ≤ 1 := by nlinarith
  have hc1 : c ≤ 1 := by nlinarith
  have hcase : (a = 1 ∧ b = 0 ∧ c = 0) ∨ (a = 0 ∧ b = 1 ∧ c = 0) ∨ (a = 0 ∧ b = 0 ∧ c = 1) := by
    interval_cases a <;> interval_cases b <;> interval_cases c <;> simp_all
  rcases hcase with ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩
  · exact Or.inl rfl
  · exact Or.inr (Or.inl rfl)
  · exact Or.inr (Or.inr rfl)

/-- Height-one nodes are fixed by the canonical parent map: they are the roots. -/
theorem canonStep_fixed_of_height_one {p : Quad} (h : IsNode p) (hd : p.2.2.2 = 1) :
    canonStep p = p := by
  rcases height_one_classification h hd with rfl | rfl | rfl <;>
    simp [canonStep, qk]

/-- **The canonical parent map is well founded.**  Finitely many canonical steps take any node to
a node of height one, i.e. to a permutation of the root; the canonical parent edges therefore
form a spanning tree of the quadruple graph rooted at `(1,0,0,1)`. -/
theorem canonStep_iterate_reaches_root :
    ∀ (N : ℕ) (p : Quad), p.2.2.2.toNat ≤ N → IsNode p →
      ∃ k : ℕ, IsNode (canonStep^[k] p) ∧ (canonStep^[k] p).2.2.2 = 1 := by
  intro N
  induction N with
  | zero =>
      intro p hN h
      exact absurd h.2.2.2.1 (by omega)
  | succ N ih =>
      intro p hN h
      rcases eq_or_lt_of_le (show (1 : ℤ) ≤ p.2.2.2 from h.2.2.2.1) with hd1 | hd1
      · exact ⟨0, by simpa using h, by simpa using hd1.symm⟩
      · have hnode := canonStep_isNode h
        have hlt := canonStep_height_lt h hd1
        have hpos : 0 < (canonStep p).2.2.2 := hnode.2.2.2.1
        have hsmall : (canonStep p).2.2.2.toNat ≤ N := by omega
        obtain ⟨k, hk1, hk2⟩ := ih (canonStep p) hsmall hnode
        exact ⟨k + 1, by rwa [Function.iterate_succ_apply], by
          rw [Function.iterate_succ_apply]; exact hk2⟩

/-- Every node reaches a root in finitely many canonical steps. -/
theorem exists_canonStep_to_root {p : Quad} (h : IsNode p) :
    ∃ k : ℕ, canonStep^[k] p = (1, 0, 0, 1) ∨ canonStep^[k] p = (0, 1, 0, 1) ∨
      canonStep^[k] p = (0, 0, 1, 1) := by
  obtain ⟨k, hk1, hk2⟩ := canonStep_iterate_reaches_root p.2.2.2.toNat p le_rfl h
  exact ⟨k, height_one_classification hk1 hk2⟩

end HigherPythagorean