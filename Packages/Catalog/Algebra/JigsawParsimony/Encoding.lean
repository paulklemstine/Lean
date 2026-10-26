module

public import Catalog.Algebra.JigsawParsimony.Basic

/-!
# The encoding, not the mathematics, breaks parsimony

The abstract assembly count (`count`) counts *choices of variable pieces*.  A
physical jigsaw solver, however, places *labelled* physical pieces into slots, and
the piece-count encoding of the SAT reduction uses many physically identical
pieces: `2` corner pieces and `m` clause pieces of one boundary shape (here called
`frame`), `n` identical tab variable pieces and `n` identical blank variable pieces,
for `2n + m + 2` pieces in total.

A *labelled assembly* is an abstract assembly together with a shape-preserving
relabelling of the physical pieces.  We prove:

* `card_relabel_eq_prod` (general multiplicity law) : for an arbitrary shape map,
  the number of shape-preserving relabellings is `∏ (multiplicity)!`, and it is `1`
  exactly when the shape map is injective (`prod_factorial_eq_one_iff`).
* `card_labeledAssembly` : for the SAT encoding,
  `#labelled = count P · (m+2)! · n! · n!`.
* `even_card_labeledAssembly` : the labelled count is always even, so it carries no
  mod-2 information at all, whereas `count` can be odd (`labeled_parity_collapse`).
* `labeled_not_parsimonious` : labelled counting is parsimonious for *no* solvable
  puzzle — piece multiplicities, not complementation, are what break parsimony.
* `count_eq_card_labeled_div` : the exact count is recovered by dividing out the
  multiplicity factor, so the multiplicities carry exactly the lost counting data.
-/

@[expose] public section

namespace JigsawParsimony

open Finset

/-! ## General multiplicity law -/

theorem card_subtype_sum {α β : Type*} [Fintype α] [Fintype β] (p : α ⊕ β → Prop)
    [DecidablePred p] :
    Fintype.card {x // p x} =
      Fintype.card {a // p (Sum.inl a)} + Fintype.card {b // p (Sum.inr b)} := by
  rw [← Fintype.card_sum]
  exact Fintype.card_congr Equiv.subtypeSum

/-- Number of shape-preserving relabellings of a finite set of pieces. -/
theorem card_relabel_eq_prod {α ι : Type*} [Fintype α] [DecidableEq α] [DecidableEq ι]
    [Fintype ι] (f : α → ι) :
    Fintype.card {g : Equiv.Perm α // f ∘ g = f} = ∏ i, (Fintype.card {a // f a = i}).factorial :=
  DomMulAct.stabilizer_card f

/-- The multiplicity factor is trivial exactly when no two pieces share a shape. -/
theorem prod_factorial_eq_one_iff {α ι : Type*} [Fintype α] [DecidableEq ι] [Fintype ι]
    (f : α → ι) :
    ∏ i, (Fintype.card {a // f a = i}).factorial = 1 ↔ Function.Injective f := by
  rw [Finset.prod_eq_one_iff_of_one_le'
    (fun i _ => Nat.one_le_iff_ne_zero.2 (Nat.factorial_ne_zero _))]
  simp only [Finset.mem_univ, true_implies, Nat.factorial_eq_one]
  constructor
  · intro h x y hxy
    exact congrArg Subtype.val (Fintype.card_le_one_iff.1 (h (f y)) ⟨x, hxy⟩ ⟨y, rfl⟩)
  · intro hf i
    exact Fintype.card_le_one_iff.2 fun a b => Subtype.ext (hf (a.2.trans b.2.symm))

/-! ## The physical pieces of the SAT encoding -/

/-- Physical piece shapes used by the encoding. -/
inductive PieceShape
  | frame
  | tabVar
  | blankVar
  deriving DecidableEq, Fintype

/-- Physical slots: `m + 2` frame-shaped pieces (two corners and `m` clause pieces),
`n` tab variable pieces, and `n` blank variable pieces. -/
abbrev Slot (n m : ℕ) := Fin (m + 2) ⊕ Fin n ⊕ Fin n

/-- The shape of the physical piece in each slot. -/
def slotShape {n m : ℕ} : Slot n m → PieceShape :=
  Sum.elim (fun _ => .frame) (Sum.elim (fun _ => .tabVar) (fun _ => .blankVar))

/-- The encoding uses exactly `2n + m + 2` physical pieces. -/
theorem card_slot (n m : ℕ) : Fintype.card (Slot n m) = 2 * n + m + 2 := by
  simp only [Fintype.card_sum, Fintype.card_fin]; ring

theorem card_frame (n m : ℕ) :
    Fintype.card {a : Slot n m // slotShape a = .frame} = m + 2 := by
  rw [card_subtype_sum, card_subtype_sum]; simp [slotShape]

theorem card_tabVar (n m : ℕ) :
    Fintype.card {a : Slot n m // slotShape a = .tabVar} = n := by
  rw [card_subtype_sum, card_subtype_sum]; simp [slotShape]

theorem card_blankVar (n m : ℕ) :
    Fintype.card {a : Slot n m // slotShape a = .blankVar} = n := by
  rw [card_subtype_sum, card_subtype_sum]; simp [slotShape]

/-- Shape-preserving relabellings of the physical pieces. -/
abbrev Relabel (n m : ℕ) := {g : Equiv.Perm (Slot n m) // slotShape ∘ g = slotShape}

/-- **Multiplicity factor of the encoding.** -/
theorem card_relabel (n m : ℕ) :
    Fintype.card (Relabel n m) = (m + 2).factorial * n.factorial * n.factorial := by
  rw [card_relabel_eq_prod, Fintype.prod_eq_mul_prod_compl PieceShape.frame]
  have hcompl : ({PieceShape.frame}ᶜ : Finset PieceShape) = {.tabVar, .blankVar} := by decide
  rw [hcompl, Finset.prod_pair (by decide), card_frame, card_tabVar, card_blankVar, mul_assoc]

variable {n : ℕ}

/-- A labelled assembly: an abstract assembly together with a shape-preserving
relabelling of the `2n + m + 2` physical pieces. -/
abbrev LabeledAssembly (P : Puzzle n) := {a : Cube n // Assembles P a} × Relabel n P.length

/-- **Labelled count = abstract count × multiplicity factor.** -/
theorem card_labeledAssembly (P : Puzzle n) :
    Fintype.card (LabeledAssembly P) =
      count P * ((P.length + 2).factorial * n.factorial * n.factorial) := by
  rw [Fintype.card_prod, card_relabel, ← count_eq_card_subtype]

/-- The labelled count is always even: it erases the mod-2 count. -/
theorem even_card_labeledAssembly (P : Puzzle n) : Even (Fintype.card (LabeledAssembly P)) := by
  rw [card_labeledAssembly]
  have h2 : 2 ∣ (P.length + 2).factorial := Nat.dvd_factorial (by norm_num) (by omega)
  exact even_iff_two_dvd.2 (Dvd.dvd.mul_left (Dvd.dvd.mul_right (Dvd.dvd.mul_right h2 _) _) _)

/-- Labelled counting is parsimonious for **no** solvable puzzle. -/
theorem labeled_not_parsimonious (P : Puzzle n) (hP : 0 < count P) :
    Fintype.card (LabeledAssembly P) ≠ count P := by
  rw [card_labeledAssembly]
  intro h
  have hf : (P.length + 2).factorial * n.factorial * n.factorial = 1 := by
    have := Nat.eq_of_mul_eq_mul_left hP (h.trans (mul_one _).symm)
    exact this
  have h2 : 2 ≤ (P.length + 2).factorial := by
    calc 2 = (2 : ℕ).factorial := rfl
      _ ≤ (P.length + 2).factorial := Nat.factorial_le (by omega)
  have : (P.length + 2).factorial ≤ 1 := by
    rw [← hf, mul_assoc]
    exact Nat.le_mul_of_pos_right _ (Nat.mul_pos (Nat.factorial_pos _) (Nat.factorial_pos _))
  omega

/-- The multiplicities carry exactly the lost counting information: dividing them
out recovers the abstract count. -/
theorem count_eq_card_labeled_div (P : Puzzle n) :
    count P = Fintype.card (LabeledAssembly P) /
      ((P.length + 2).factorial * n.factorial * n.factorial) := by
  rw [card_labeledAssembly, Nat.mul_div_cancel _ (by positivity)]

/-- The shape map of the encoding is never injective, so by the general
multiplicity law it can never be parsimonious. -/
theorem slotShape_not_injective (m : ℕ) : ¬ Function.Injective (slotShape (n := n) (m := m)) := by
  intro h
  have := h (a₁ := Sum.inl 0) (a₂ := Sum.inl 1) rfl
  exact absurd (Sum.inl.inj this) (by simp)

/-- **Parity collapse.**  On one variable, the unit clause `x₀` has an odd abstract
count, and its complement too (complementation preserves parity), yet both labelled
counts are even. -/
theorem labeled_parity_collapse :
    let P : Puzzle 1 := [[(0, 1)]]
    count P = 1 ∧ count (compPuzzle P) = 1 ∧
      Even (Fintype.card (LabeledAssembly P)) ∧
      Even (Fintype.card (LabeledAssembly (compPuzzle P))) := by
  intro P
  have h1 : count P = 1 := by decide
  exact ⟨h1, (count_compPuzzle P).trans h1, even_card_labeledAssembly P,
    even_card_labeledAssembly _⟩

end JigsawParsimony