import Mathlib

/-!
# A bridge between graph coloring and Sudoku constraint satisfaction

Sudoku on an `n²×n²` grid is a constraint satisfaction problem (CSP): fill each cell with
one of `n²` symbols so that every row, every column and every `n×n` block contains each symbol
exactly once.  Graph coloring is a *different* area of combinatorics: assign colors to the
vertices of a graph so that adjacent vertices receive different colors.

This file makes the classical folklore correspondence **precise and machine-checked**:

* We build the **Sudoku constraint graph** `sudokuGraph n`, whose vertices are the cells and
  whose edges join any two distinct cells that share a row, a column, or a block.
* `isSudokuSolution_iff_properColoring` : a filling is a valid Sudoku solution **iff** it is a
  proper coloring of `sudokuGraph n`.  This is the cross-domain bridge (CSP ↔ graph coloring).
* `sudokuGraph_chromaticNumber` : the **chromatic number** of the Sudoku constraint graph is
  exactly `n²`, the number of symbols.  The lower bound comes from graph theory (a full row is
  a clique of size `n²`), the upper bound from an explicit CSP solution.
* `exists_isSudokuSolution` : every empty `n²×n²` Sudoku is solvable, via an explicit
  arithmetic construction.

The chromatic number being *exactly* `n²` is the graph-theoretic incarnation of the fact that a
Sudoku grid needs, and has enough room for, exactly `n²` symbols — connecting the "critical
number of symbols" of the CSP with a hard graph invariant.
-/

open SimpleGraph

namespace SudokuBridge

/-- The type of cells of an `n²×n²` Sudoku grid. -/
abbrev Cell (n : ℕ) := Fin (n * n) × Fin (n * n)

/-- Two cells are in the same **row**. -/
def sameRow {n : ℕ} (p q : Cell n) : Prop := p.1 = q.1

/-- Two cells are in the same **column**. -/
def sameCol {n : ℕ} (p q : Cell n) : Prop := p.2 = q.2

/-- Two cells are in the same `n×n` **block**. -/
def sameBox {n : ℕ} (p q : Cell n) : Prop :=
  (p.1 : ℕ) / n = (q.1 : ℕ) / n ∧ (p.2 : ℕ) / n = (q.2 : ℕ) / n

/-- The **Sudoku constraint graph**: distinct cells are adjacent iff they lie in a common
row, column, or block. -/
def sudokuGraph (n : ℕ) : SimpleGraph (Cell n) where
  Adj p q := p ≠ q ∧ (sameRow p q ∨ sameCol p q ∨ sameBox p q)
  symm := by
    rintro p q ⟨hne, h⟩
    refine ⟨hne.symm, ?_⟩
    rcases h with h | h | h
    · exact Or.inl h.symm
    · exact Or.inr (Or.inl h.symm)
    · exact Or.inr (Or.inr ⟨h.1.symm, h.2.symm⟩)
  loopless := ⟨by rintro p ⟨hne, _⟩; exact hne rfl⟩

/-- A filling `g` of the grid is a **valid Sudoku solution** if no two distinct cells sharing a
row, a column, or a block receive the same symbol. -/
def IsSudokuSolution (n : ℕ) (g : Cell n → Fin (n * n)) : Prop :=
  (∀ p q : Cell n, sameRow p q → p ≠ q → g p ≠ g q) ∧
  (∀ p q : Cell n, sameCol p q → p ≠ q → g p ≠ g q) ∧
  (∀ p q : Cell n, sameBox p q → p ≠ q → g p ≠ g q)

/-! ### The cross-domain bridge -/

/-- **Bridge theorem.**  A filling is a valid Sudoku solution iff it is a proper coloring of the
Sudoku constraint graph. This identifies the constraint-satisfaction notion of a Sudoku solution
with the graph-theoretic notion of a proper coloring. -/
theorem isSudokuSolution_iff_properColoring {n : ℕ} (g : Cell n → Fin (n * n)) :
    IsSudokuSolution n g ↔ ∀ p q : Cell n, (sudokuGraph n).Adj p q → g p ≠ g q := by
  constructor
  · rintro ⟨hrow, hcol, hbox⟩ p q ⟨hne, hor⟩
    rcases hor with h | h | h
    · exact hrow p q h hne
    · exact hcol p q h hne
    · exact hbox p q h hne
  · intro H
    refine ⟨?_, ?_, ?_⟩
    · intro p q hs hne; exact H p q ⟨hne, Or.inl hs⟩
    · intro p q hs hne; exact H p q ⟨hne, Or.inr (Or.inl hs)⟩
    · intro p q hs hne; exact H p q ⟨hne, Or.inr (Or.inr hs)⟩

/-! ### An explicit Sudoku solution (upper bound on the chromatic number) -/

/-- Explicit value of a completed Sudoku grid at integer coordinates `(r, c)`.
This is the classical "shift" construction `n·(r mod n) + (r div n) + c` reduced mod `n²`. -/
def sudokuVal (n r c : ℕ) : ℕ := (n * (r % n) + r / n + c) % (n * n)

lemma sudokuVal_lt {n : ℕ} (hn : 0 < n) (r c : ℕ) : sudokuVal n r c < n * n :=
  Nat.mod_lt _ (Nat.mul_pos hn hn)

/-- Base-`n` digit uniqueness. -/
lemma base_n_unique {n a b a' b' : ℕ} (hb : b < n) (hb' : b' < n)
    (h : n * a + b = n * a' + b') : a = a' ∧ b = b' := by
  have h1 : (n * a + b) % n = (n * a' + b') % n := by rw [h]
  rw [Nat.mul_add_mod, Nat.mul_add_mod, Nat.mod_eq_of_lt hb, Nat.mod_eq_of_lt hb'] at h1
  subst h1
  refine ⟨?_, rfl⟩
  have hab : n * a = n * a' := by omega
  exact Nat.eq_of_mul_eq_mul_left (by omega) hab

/-- Cancellation of a constant summand under a common modulus, for reduced summands. -/
lemma add_left_mod_cancel {N k x y : ℕ} (hx : x < N) (hy : y < N)
    (h : (k + x) % N = (k + y) % N) : x = y := by
  have h2 : x ≡ y [MOD N] := (Nat.ModEq.add_left_cancel' k h)
  calc x = x % N := (Nat.mod_eq_of_lt hx).symm
    _ = y % N := h2
    _ = y := Nat.mod_eq_of_lt hy

/-- Cancellation of a constant summand (on the right) under a common modulus. -/
lemma add_right_mod_cancel {N k x y : ℕ} (hx : x < N) (hy : y < N)
    (h : (x + k) % N = (y + k) % N) : x = y := by
  apply add_left_mod_cancel (k := k) hx hy
  rwa [Nat.add_comm k x, Nat.add_comm k y]

/-- Bound used for the column argument: the "row digit" `n·(r mod n) + r div n` is `< n²`. -/
lemma D_lt {n r : ℕ} (hn : 0 < n) (hr : r < n * n) : n * (r % n) + r / n < n * n := by
  have h1 : r % n < n := Nat.mod_lt _ hn
  have h2 : r / n < n := (Nat.div_lt_iff_lt_mul hn).2 hr
  have h3 : n * (r % n) ≤ n * (n - 1) := Nat.mul_le_mul_left n (by omega)
  nlinarith [h3, h2]

/-- Bound used for the block argument: the "digit pair" `n·(r mod n) + (c mod n)` is `< n²`. -/
lemma X_lt {n r c : ℕ} (hn : 0 < n) : n * (r % n) + c % n < n * n := by
  have h1 : r % n < n := Nat.mod_lt _ hn
  have h2 : c % n < n := Nat.mod_lt _ hn
  have h3 : n * (r % n) ≤ n * (n - 1) := Nat.mul_le_mul_left n (by omega)
  nlinarith [h3, h2]

/-- Distinctness of `sudokuVal` along a **row**. -/
lemma sudokuVal_row {n r c c' : ℕ} (hc : c < n * n) (hc' : c' < n * n)
    (h : sudokuVal n r c = sudokuVal n r c') : c = c' := by
  unfold sudokuVal at h
  exact add_left_mod_cancel hc hc' h

/-- Distinctness of `sudokuVal` along a **column**. -/
lemma sudokuVal_col {n r r' c : ℕ} (hn : 0 < n) (hr : r < n * n) (hr' : r' < n * n)
    (h : sudokuVal n r c = sudokuVal n r' c) : r = r' := by
  unfold sudokuVal at h
  have hD : n * (r % n) + r / n = n * (r' % n) + r' / n :=
    add_right_mod_cancel (D_lt hn hr) (D_lt hn hr') h
  have hb : r / n < n := (Nat.div_lt_iff_lt_mul hn).2 hr
  have hb' : r' / n < n := (Nat.div_lt_iff_lt_mul hn).2 hr'
  obtain ⟨he1, he2⟩ := base_n_unique hb hb' hD
  calc r = n * (r / n) + r % n := (Nat.div_add_mod r n).symm
    _ = n * (r' / n) + r' % n := by rw [he1, he2]
    _ = r' := Nat.div_add_mod r' n

/-- Distinctness of `sudokuVal` within a **block**. -/
lemma sudokuVal_box {n r c r' c' : ℕ} (hn : 0 < n)
    (hbr : r / n = r' / n) (hbc : c / n = c' / n)
    (h : sudokuVal n r c = sudokuVal n r' c') : r = r' ∧ c = c' := by
  unfold sudokuVal at h
  have key : ∀ a b : ℕ, n * (a % n) + a / n + b = (n * (a % n) + b % n) + (a / n + n * (b / n)) := by
    intro a b; have := Nat.div_add_mod b n; omega
  rw [key r c, key r' c'] at h
  have hC : r / n + n * (c / n) = r' / n + n * (c' / n) := by rw [hbr, hbc]
  rw [hC] at h
  have hX : n * (r % n) + c % n = n * (r' % n) + c' % n :=
    add_right_mod_cancel (X_lt hn) (X_lt hn) h
  have hb : c % n < n := Nat.mod_lt _ hn
  have hb' : c' % n < n := Nat.mod_lt _ hn
  obtain ⟨he1, he2⟩ := base_n_unique hb hb' hX
  refine ⟨?_, ?_⟩
  · calc r = n * (r / n) + r % n := (Nat.div_add_mod r n).symm
      _ = n * (r' / n) + r' % n := by rw [hbr, he1]
      _ = r' := Nat.div_add_mod r' n
  · calc c = n * (c / n) + c % n := (Nat.div_add_mod c n).symm
      _ = n * (c' / n) + c' % n := by rw [hbc, he2]
      _ = c' := Nat.div_add_mod c' n

/-- The explicit coloring induced by `sudokuVal`. -/
def sudokuColor (n : ℕ) (hn : 0 < n) (p : Cell n) : Fin (n * n) :=
  ⟨sudokuVal n (p.1 : ℕ) (p.2 : ℕ), sudokuVal_lt hn _ _⟩

/-- The explicit construction is a valid Sudoku solution. -/
theorem isSudokuSolution_sudokuColor {n : ℕ} (hn : 0 < n) :
    IsSudokuSolution n (sudokuColor n hn) := by
  have hval : ∀ p q : Cell n, sudokuColor n hn p = sudokuColor n hn q →
      sudokuVal n (p.1 : ℕ) (p.2 : ℕ) = sudokuVal n (q.1 : ℕ) (q.2 : ℕ) := by
    intro p q h; exact congrArg Fin.val h
  refine ⟨?_, ?_, ?_⟩
  · -- rows
    intro p q hs hne hcolor
    apply hne
    have hr : (p.1 : ℕ) = (q.1 : ℕ) := congrArg Fin.val hs
    have hvv := hval p q hcolor
    rw [hr] at hvv
    have hc : (p.2 : ℕ) = (q.2 : ℕ) := sudokuVal_row p.2.isLt q.2.isLt hvv
    exact Prod.ext (Fin.val_inj.mp hr) (Fin.val_inj.mp hc)
  · -- columns
    intro p q hs hne hcolor
    apply hne
    have hc : (p.2 : ℕ) = (q.2 : ℕ) := congrArg Fin.val hs
    have hvv := hval p q hcolor
    rw [hc] at hvv
    have hr : (p.1 : ℕ) = (q.1 : ℕ) := sudokuVal_col hn p.1.isLt q.1.isLt hvv
    exact Prod.ext (Fin.val_inj.mp hr) (Fin.val_inj.mp hc)
  · -- blocks
    intro p q hs hne hcolor
    apply hne
    obtain ⟨hbr, hbc⟩ := hs
    have hvv := hval p q hcolor
    obtain ⟨hr, hc⟩ := sudokuVal_box hn hbr hbc hvv
    exact Prod.ext (Fin.val_inj.mp hr) (Fin.val_inj.mp hc)

/-- Every empty `n²×n²` Sudoku (with `n ≥ 1`) admits a solution. -/
theorem exists_isSudokuSolution {n : ℕ} (hn : 0 < n) :
    ∃ g : Cell n → Fin (n * n), IsSudokuSolution n g :=
  ⟨sudokuColor n hn, isSudokuSolution_sudokuColor hn⟩

/-- The Sudoku constraint graph is `n²`-colorable. -/
theorem sudokuGraph_colorable {n : ℕ} (hn : 0 < n) :
    (sudokuGraph n).Colorable (n * n) := by
  have hproper :=
    (isSudokuSolution_iff_properColoring (sudokuColor n hn)).1 (isSudokuSolution_sudokuColor hn)
  have C : (sudokuGraph n).Coloring (Fin (n * n)) :=
    Coloring.mk (sudokuColor n hn) (fun {v w} hadj => hproper v w hadj)
  simpa using C.colorable

/-! ### A full row is a clique (lower bound on the chromatic number) -/

/-- The `n²` cells of the first row, as a finite set. -/
def firstRow (n : ℕ) (hn : 0 < n) : Finset (Cell n) :=
  Finset.univ.image (fun j : Fin (n * n) => (⟨0, Nat.mul_pos hn hn⟩, j))

lemma firstRow_card {n : ℕ} (hn : 0 < n) : (firstRow n hn).card = n * n := by
  unfold firstRow
  rw [Finset.card_image_of_injective _ (fun a b h => by simpa using h)]
  simp

lemma firstRow_isClique {n : ℕ} (hn : 0 < n) :
    (sudokuGraph n).IsClique (firstRow n hn : Set (Cell n)) := by
  intro p hp q hq hpq
  simp only [firstRow, Finset.coe_image, Set.mem_image, Finset.mem_coe,
    Finset.mem_univ, true_and] at hp hq
  obtain ⟨j, rfl⟩ := hp
  obtain ⟨j', rfl⟩ := hq
  exact ⟨hpq, Or.inl rfl⟩

/-! ### Main result: the chromatic number is exactly `n²` -/

/-- **Main theorem.** The chromatic number of the Sudoku constraint graph on the `n²×n²` grid is
exactly `n²`, the number of symbols. The lower bound is graph-theoretic (a full row is a clique
of size `n²`); the upper bound is a constraint-satisfaction solution (an explicit filling). -/
theorem sudokuGraph_chromaticNumber {n : ℕ} (hn : 0 < n) :
    (sudokuGraph n).chromaticNumber = (n * n : ℕ) := by
  apply le_antisymm
  · exact (sudokuGraph_colorable hn).chromaticNumber_le
  · have hclique := (firstRow_isClique hn).card_le_chromaticNumber
    rwa [firstRow_card hn] at hclique

end SudokuBridge