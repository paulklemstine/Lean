/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# From MOLS families to nets and affine planes

Every family `S` of `k` mutually orthogonal Latin squares of order `n` coordinatizes a
**net**: the points are the grid cells `Fin n × Fin n` and the lines come in `k + 2`
*parallel classes*,

* the `n` **rows** `{(i, ·)}`,
* the `n` **columns** `{(·, j)}`,
* for each member `s` of the family and each symbol `c`, the `n` cells where `s` reads `c`.

The two structural facts proved here hold for an arbitrary MOLS family:

* `existsUnique_line_of_cls` — every point lies on exactly one line of each class
  (so "parallel" = "same class" satisfies Playfair's axiom);
* `existsUnique_meet` — two lines from *different* classes meet in exactly one point
  (this is precisely orthogonality when both lines come from squares);
* `line_join_unique` — two distinct points lie on *at most* one line.

The remaining affine-plane axiom, *existence* of a joining line, is exactly where the
Euler–MacNeish ceiling becomes an equality: it holds as soon as the family is
**saturated**, `k = n - 1` (`line_join_exists`, `existsUnique_line_join`).  Combined with
`Physics.OrthogonalNets.FieldMOLS` this produces an affine plane of order `n` for every
finite field order `n`.

Cardinality bookkeeping (`card_line`, `card_Line_saturated`) confirms the classical
parameters: `n²` points, `n² + n` lines, `n` points per line.
-/

import Computation.PosetTheory.ReticulationMOLS
import Physics.OrthogonalNets.PivotWindow

namespace Catalog.Physics.OrthogonalNets

open Function
open Catalog.Computation.ReticulationMOLS

variable {n k : ℕ}

/-- Lines of the net coordinatized by a MOLS family: rows, columns, and the symbol-fibres
of each member of the family. -/
inductive Line (n k : ℕ)
  /-- The row through the cells with first coordinate `i`. -/
  | row (i : Fin n)
  /-- The column through the cells with second coordinate `j`. -/
  | col (j : Fin n)
  /-- The fibre of symbol `c` in the `s`-th square of the family. -/
  | sq (s : Fin k) (c : Fin n)
deriving DecidableEq, Fintype

/-- Incidence between a cell of the grid and a line of the net. -/
def OnLine (S : MOLS n k) : Line n k → Fin n × Fin n → Prop
  | .row i, p => p.1 = i
  | .col j, p => p.2 = j
  | .sq s c, p => S.L s p.1 p.2 = c

/-- The parallel class of a line: `Sum.inr true` for rows, `Sum.inr false` for columns, and
`Sum.inl s` for the fibres of the `s`-th square. -/
def Line.cls : Line n k → Fin k ⊕ Bool
  | .row _ => Sum.inr true
  | .col _ => Sum.inr false
  | .sq s _ => Sum.inl s

/-! ## Parallel classes -/

/-- **Playfair, existence and uniqueness form.**  Every point of the grid lies on exactly
one line of each parallel class. -/
theorem existsUnique_line_of_cls (S : MOLS n k) (c : Fin k ⊕ Bool) (p : Fin n × Fin n) :
    ∃! ℓ : Line n k, ℓ.cls = c ∧ OnLine S ℓ p := by
  match c with
  | Sum.inr true =>
      refine ⟨.row p.1, ⟨rfl, rfl⟩, ?_⟩
      rintro (i | j | ⟨s, c⟩) ⟨hcls, hon⟩ <;> simp_all [Line.cls, OnLine]
  | Sum.inr false =>
      refine ⟨.col p.2, ⟨rfl, rfl⟩, ?_⟩
      rintro (i | j | ⟨s, c⟩) ⟨hcls, hon⟩ <;> simp_all [Line.cls, OnLine]
  | Sum.inl s =>
      refine ⟨.sq s (S.L s p.1 p.2), ⟨rfl, rfl⟩, ?_⟩
      rintro (i | j | ⟨s', c⟩) ⟨hcls, hon⟩ <;> simp_all [Line.cls, OnLine]

/-- Two distinct lines of the same parallel class are disjoint. -/
theorem disjoint_of_cls_eq (S : MOLS n k) {ℓ₁ ℓ₂ : Line n k} (hcls : ℓ₁.cls = ℓ₂.cls)
    (hne : ℓ₁ ≠ ℓ₂) (p : Fin n × Fin n) : ¬(OnLine S ℓ₁ p ∧ OnLine S ℓ₂ p) := by
  rintro ⟨h₁, h₂⟩
  obtain ⟨ℓ, -, hu⟩ := existsUnique_line_of_cls S ℓ₁.cls p
  exact hne ((hu ℓ₁ ⟨rfl, h₁⟩).trans (hu ℓ₂ ⟨hcls.symm, h₂⟩).symm)

/-- Swapping the two lines in a "unique meeting point" statement. -/
private theorem meet_swap {α : Type*} {A B : α → Prop} (h : ∃! p, A p ∧ B p) :
    ∃! p, B p ∧ A p := by
  obtain ⟨p, ⟨h1, h2⟩, hu⟩ := h
  exact ⟨p, ⟨h2, h1⟩, fun q hq => hu q ⟨hq.2, hq.1⟩⟩

/-- A row and a column meet in exactly one cell. -/
private theorem meet_row_col (S : MOLS n k) (i j : Fin n) :
    ∃! p : Fin n × Fin n, OnLine S (.row i) p ∧ OnLine S (.col j) p := by
  refine ⟨(i, j), ⟨rfl, rfl⟩, ?_⟩
  rintro ⟨a, b⟩ ⟨h1, h2⟩
  simp only [OnLine] at h1 h2
  simp [h1, h2]

/-- A row meets a symbol-fibre in exactly one cell: the row is a bijection onto symbols. -/
private theorem meet_row_sq (S : MOLS n k) (i : Fin n) (s : Fin k) (c : Fin n) :
    ∃! p : Fin n × Fin n, OnLine S (.row i) p ∧ OnLine S (.sq s c) p := by
  refine ⟨(i, (rowEquiv S s i).symm c), ⟨rfl, ?_⟩, ?_⟩
  · show S.L s i ((rowEquiv S s i).symm c) = c
    simp
  · rintro ⟨a, b⟩ ⟨h1, h2⟩
    simp only [OnLine] at h1 h2
    subst h1
    have hb : b = (rowEquiv S s a).symm c := by
      rw [← h2]
      exact ((rowEquiv S s a).symm_apply_apply b).symm
    simp [hb]

/-- A column meets a symbol-fibre in exactly one cell: the column is a bijection onto
symbols. -/
private theorem meet_col_sq (S : MOLS n k) (j : Fin n) (s : Fin k) (c : Fin n) :
    ∃! p : Fin n × Fin n, OnLine S (.col j) p ∧ OnLine S (.sq s c) p := by
  refine ⟨((colEquiv S s j).symm c, j), ⟨rfl, ?_⟩, ?_⟩
  · show S.L s ((colEquiv S s j).symm c) j = c
    simp
  · rintro ⟨a, b⟩ ⟨h1, h2⟩
    simp only [OnLine] at h1 h2
    subst h1
    have ha : a = (colEquiv S s b).symm c := by
      rw [← h2]
      exact ((colEquiv S s b).symm_apply_apply a).symm
    simp [ha]

/-- Symbol-fibres of two *distinct* members of the family meet in exactly one cell: this is
exactly the orthogonality of the two squares. -/
private theorem meet_sq_sq (S : MOLS n k) {s t : Fin k} (hst : s ≠ t) (c d : Fin n) :
    ∃! p : Fin n × Fin n, OnLine S (.sq s c) p ∧ OnLine S (.sq t d) p := by
  obtain ⟨p, hp⟩ := (S.ortho s t hst).2 (c, d)
  refine ⟨p, ⟨congrArg Prod.fst hp, congrArg Prod.snd hp⟩, ?_⟩
  rintro q ⟨h1, h2⟩
  refine (S.ortho s t hst).1 ?_
  simp only [OnLine] at h1 h2
  rw [hp]
  simp only [h1, h2]

/-- **Transversality.**  Two lines from different parallel classes meet in exactly one
point.  For two square-lines this is precisely the orthogonality of the two squares. -/
theorem existsUnique_meet (S : MOLS n k) {ℓ₁ ℓ₂ : Line n k} (hcls : ℓ₁.cls ≠ ℓ₂.cls) :
    ∃! p : Fin n × Fin n, OnLine S ℓ₁ p ∧ OnLine S ℓ₂ p := by
  rcases ℓ₁ with i | j | ⟨s, c⟩ <;> rcases ℓ₂ with i' | j' | ⟨s', c'⟩
  · exact absurd rfl hcls
  · exact meet_row_col S i j'
  · exact meet_row_sq S i s' c'
  · exact meet_swap (meet_row_col S i' j)
  · exact absurd rfl hcls
  · exact meet_col_sq S j s' c'
  · exact meet_swap (meet_row_sq S i' s c)
  · exact meet_swap (meet_col_sq S j' s c)
  · refine meet_sq_sq S (fun h => hcls ?_) c c'
    simp [Line.cls, h]

/-! ## Joining two points -/

/-- Two distinct points lie on at most one common line.  (No saturation hypothesis.) -/
theorem line_join_unique (S : MOLS n k) {p q : Fin n × Fin n} (hpq : p ≠ q)
    {ℓ₁ ℓ₂ : Line n k} (h₁ : OnLine S ℓ₁ p ∧ OnLine S ℓ₁ q)
    (h₂ : OnLine S ℓ₂ p ∧ OnLine S ℓ₂ q) : ℓ₁ = ℓ₂ := by
  by_contra hne
  by_cases hcls : ℓ₁.cls = ℓ₂.cls
  · exact disjoint_of_cls_eq S hcls hne p ⟨h₁.1, h₂.1⟩
  · obtain ⟨r, -, hu⟩ := existsUnique_meet S hcls
    exact hpq ((hu p ⟨h₁.1, h₂.1⟩).trans (hu q ⟨h₁.2, h₂.2⟩).symm)

/-- **Saturation gives joins.**  In a saturated family (`k = n - 1`) any two points of the
grid lie on a common line. -/
theorem line_join_exists {S : MOLS n k} (hk : k = n - 1) (p q : Fin n × Fin n) :
    ∃ ℓ : Line n k, OnLine S ℓ p ∧ OnLine S ℓ q := by
  by_cases h1 : p.1 = q.1
  · exact ⟨.row p.1, rfl, h1.symm⟩
  by_cases h2 : p.2 = q.2
  · exact ⟨.col p.2, rfl, h2.symm⟩
  obtain ⟨s, hs⟩ := saturated_join hk h1 h2
  exact ⟨.sq s (S.L s p.1 p.2), rfl, hs.symm⟩

/-- **A saturated MOLS family is an affine plane.**  Any two distinct points of the grid lie
on exactly one line of the net determined by a family of `n - 1` mutually orthogonal Latin
squares of order `n`. -/
theorem existsUnique_line_join {S : MOLS n k} (hk : k = n - 1) {p q : Fin n × Fin n}
    (hpq : p ≠ q) : ∃! ℓ : Line n k, OnLine S ℓ p ∧ OnLine S ℓ q := by
  obtain ⟨ℓ, hℓ⟩ := line_join_exists hk p q
  exact ⟨ℓ, hℓ, fun ℓ' hℓ' => line_join_unique S hpq hℓ' hℓ⟩

/-! ## Counting -/

/-- Every line of the net carries exactly `n` points. -/
theorem card_line (S : MOLS n k) (ℓ : Line n k) :
    Nat.card {p : Fin n × Fin n // OnLine S ℓ p} = n := by
  rcases ℓ with i | j | ⟨s, c⟩
  · have hbij : Bijective (fun b : Fin n => (⟨(i, b), rfl⟩ : {p // OnLine S (.row i) p})) := by
      constructor
      · intro b b' hb
        simpa using congrArg Prod.snd (Subtype.ext_iff.mp hb)
      · rintro ⟨⟨a, b⟩, h⟩
        simp only [OnLine] at h
        exact ⟨b, by simp [h]⟩
    rw [← Nat.card_eq_of_bijective _ hbij, Nat.card_eq_fintype_card, Fintype.card_fin]
  · have hbij : Bijective (fun a : Fin n => (⟨(a, j), rfl⟩ : {p // OnLine S (.col j) p})) := by
      constructor
      · intro a a' ha
        simpa using congrArg Prod.fst (Subtype.ext_iff.mp ha)
      · rintro ⟨⟨a, b⟩, h⟩
        simp only [OnLine] at h
        exact ⟨a, by simp [h]⟩
    rw [← Nat.card_eq_of_bijective _ hbij, Nat.card_eq_fintype_card, Fintype.card_fin]
  · have hmem : ∀ a : Fin n, OnLine S (.sq s c) (a, (rowEquiv S s a).symm c) := by
      intro a
      show S.L s a ((rowEquiv S s a).symm c) = c
      simp
    have hbij : Bijective
        (fun a : Fin n => (⟨(a, (rowEquiv S s a).symm c), hmem a⟩ : {p // OnLine S (.sq s c) p})) := by
      constructor
      · intro a a' ha
        simpa using congrArg Prod.fst (Subtype.ext_iff.mp ha)
      · rintro ⟨⟨a, b⟩, h⟩
        simp only [OnLine] at h
        refine ⟨a, ?_⟩
        have hb : (rowEquiv S s a).symm c = b := by
          rw [← h]
          exact (rowEquiv S s a).symm_apply_apply b
        simp [hb]
    rw [← Nat.card_eq_of_bijective _ hbij, Nat.card_eq_fintype_card, Fintype.card_fin]

/-- The lines of the net, listed as rows, columns, and square-fibres. -/
def lineEquiv (n k : ℕ) : Line n k ≃ Fin n ⊕ Fin n ⊕ (Fin k × Fin n) where
  toFun
    | .row i => Sum.inl i
    | .col j => Sum.inr (Sum.inl j)
    | .sq s c => Sum.inr (Sum.inr (s, c))
  invFun
    | Sum.inl i => .row i
    | Sum.inr (Sum.inl j) => .col j
    | Sum.inr (Sum.inr (s, c)) => .sq s c
  left_inv := by rintro (i | j | ⟨s, c⟩) <;> rfl
  right_inv := by rintro (i | j | ⟨s, c⟩) <;> rfl

/-- The net of a `k`-member family has `(k + 2) * n` lines. -/
theorem card_Line (n k : ℕ) : Fintype.card (Line n k) = (k + 2) * n := by
  rw [Fintype.card_congr (lineEquiv n k)]
  simp [Fintype.card_sum, Fintype.card_prod]
  ring

/-- A saturated family of order `n ≥ 1` yields the classical affine-plane line count
`n² + n`. -/
theorem card_Line_saturated {n k : ℕ} (hk : k = n - 1) (hn : 1 ≤ n) :
    Fintype.card (Line n k) = n ^ 2 + n := by
  have hk' : k + 2 = n + 1 := by omega
  rw [card_Line, hk']
  ring

end Catalog.Physics.OrthogonalNets