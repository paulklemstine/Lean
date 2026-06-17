/-
  # The Order-`n` Sudoku Constraint Graph

  We formalize the finite combinatorics of the order-`n` Sudoku constraint graph.

  A *cell* of the order-`n` Sudoku board is a quadruple `(a, b, r, c)` of elements
  of `Fin n`.  We interpret it so that:

  * `(a, r)` is the *global row*  (band `a`, row `r` inside the band),
  * `(b, c)` is the *global column* (stack `b`, column `c` inside the stack),
  * `(a, b)` is the *box*.

  Two distinct cells are adjacent in `sudokuGraph n` iff they share a global row,
  a global column, or a box.

  ## Main results

  * `sudokuGraph_adj_iff` — unfolded description of adjacency.
  * `card_cell` — there are `n ^ 4 = (n ^ 2) ^ 2` cells.
  * `sudokuGraph_degree` — every vertex has degree `3 * n ^ 2 - 2 * n - 1`,
    proved by inclusion–exclusion on the row/column/box neighbourhoods, and
    `sudokuGraph_isRegular` packaging this as regularity.
  * `cellColor` and `sudokuGraph_colorable` — an explicit proper coloring with
    `n ^ 2` colors, hence `Colorable (n ^ 2)`.
  * `rowClique_isNClique` / `colClique_isNClique` — explicit cliques of size `n ^ 2`.
  * `sudokuGraph_chromaticNumber` — the chromatic number equals `n ^ 2`.

  ## A note on the coloring

  The naive color `(a,b,r,c) ↦ (r,c)` suggested by the "value inside a box"
  intuition is **not** a proper coloring: the two distinct cells `(a,b₁,r,c)` and
  `(a,b₂,r,c)` share the global row `(a,r)` (so are adjacent) yet both receive the
  color `(r,c)`.  We therefore use the mixed coloring
  `(a,b,r,c) ↦ (b + r, a + c)` (addition in `Fin n`), which one checks is injective
  on every row, column, and box and hence is a genuine proper coloring with `n ^ 2`
  colors.
-/
import Mathlib

open SimpleGraph Finset

namespace SudokuConstraintGraph

/-- A cell of the order-`n` Sudoku board, written `(a, b, r, c)`. -/
abbrev Cell (n : ℕ) := Fin n × Fin n × Fin n × Fin n

/-! ## The constraint graph -/

/-- The order-`n` Sudoku constraint graph: distinct cells are adjacent iff they
share a global row `(a, r)`, a global column `(b, c)`, or a box `(a, b)`. -/
def sudokuGraph (n : ℕ) : SimpleGraph (Cell n) where
  Adj v w :=
    v ≠ w ∧
      ((v.1 = w.1 ∧ v.2.2.1 = w.2.2.1) ∨
        (v.2.1 = w.2.1 ∧ v.2.2.2 = w.2.2.2) ∨
        (v.1 = w.1 ∧ v.2.1 = w.2.1))
  symm := by
    rintro v w ⟨hvw, h⟩
    refine ⟨hvw.symm, ?_⟩
    rcases h with ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩
    · exact Or.inl ⟨h1.symm, h2.symm⟩
    · exact Or.inr (Or.inl ⟨h1.symm, h2.symm⟩)
    · exact Or.inr (Or.inr ⟨h1.symm, h2.symm⟩)
  loopless := ⟨fun _v h => h.1 rfl⟩

instance (n : ℕ) : DecidableRel (sudokuGraph n).Adj := by
  intro v w; unfold sudokuGraph; infer_instance

/-- Adjacency in the Sudoku constraint graph, fully unfolded. -/
theorem sudokuGraph_adj_iff (n : ℕ) (v w : Cell n) :
    (sudokuGraph n).Adj v w ↔
      v ≠ w ∧
        ((v.1 = w.1 ∧ v.2.2.1 = w.2.2.1) ∨
          (v.2.1 = w.2.1 ∧ v.2.2.2 = w.2.2.2) ∨
          (v.1 = w.1 ∧ v.2.1 = w.2.1)) :=
  Iff.rfl

/-- Adjacency in coordinates `(a, b, r, c)`. -/
theorem sudokuGraph_adj_iff' (n : ℕ) (a₁ b₁ r₁ c₁ a₂ b₂ r₂ c₂ : Fin n) :
    (sudokuGraph n).Adj (a₁, b₁, r₁, c₁) (a₂, b₂, r₂, c₂) ↔
      (a₁, b₁, r₁, c₁) ≠ (a₂, b₂, r₂, c₂) ∧
        ((a₁ = a₂ ∧ r₁ = r₂) ∨ (b₁ = b₂ ∧ c₁ = c₂) ∨ (a₁ = a₂ ∧ b₁ = b₂)) :=
  Iff.rfl

/-! ## Vertex count -/

/-- There are `n ^ 4 = (n ^ 2) ^ 2` cells. -/
theorem card_cell (n : ℕ) : Fintype.card (Cell n) = (n ^ 2) ^ 2 := by
  simp [Cell, Fintype.card_prod, Fintype.card_fin]; ring

/-! ## Neighbourhood decomposition and degree -/

/-- Cells sharing the global row of `v` (including `v` itself). -/
def rowSet (n : ℕ) (v : Cell n) : Finset (Cell n) :=
  univ.filter (fun w => v.1 = w.1 ∧ v.2.2.1 = w.2.2.1)

/-- Cells sharing the global column of `v` (including `v` itself). -/
def colSet (n : ℕ) (v : Cell n) : Finset (Cell n) :=
  univ.filter (fun w => v.2.1 = w.2.1 ∧ v.2.2.2 = w.2.2.2)

/-- Cells sharing the box of `v` (including `v` itself). -/
def boxSet (n : ℕ) (v : Cell n) : Finset (Cell n) :=
  univ.filter (fun w => v.1 = w.1 ∧ v.2.1 = w.2.1)

theorem card_rowSet (n : ℕ) (v : Cell n) : (rowSet n v).card = n ^ 2 := by
  convert Finset.card_product ( Finset.univ : Finset ( Fin n ) ) ( Finset.univ : Finset ( Fin n ) ) using 1;
  · refine' Finset.card_bij ( fun w hw => ( w.2.1, w.2.2.2 ) ) _ _ _ <;> simp +decide [ rowSet ];
    aesop;
  · simp +decide [ sq ]

theorem card_colSet (n : ℕ) (v : Cell n) : (colSet n v).card = n ^ 2 := by
  convert Finset.card_product ( Finset.univ : Finset ( Fin n ) ) ( Finset.univ : Finset ( Fin n ) ) using 1;
  · refine' Finset.card_bij ( fun w hw => ( w.1, w.2.2.1 ) ) _ _ _ <;> simp +decide [ colSet ];
  · simp +decide [ sq ]

theorem card_boxSet (n : ℕ) (v : Cell n) : (boxSet n v).card = n ^ 2 := by
  convert Finset.card_product ( Finset.univ : Finset ( Fin n ) ) ( Finset.univ : Finset ( Fin n ) ) using 1;
  · refine' Finset.card_bij ( fun w hw => ( w.2.2.1, w.2.2.2 ) ) _ _ _ <;> simp +decide [ boxSet ];
    aesop;
  · simp +decide [ sq ]

theorem card_rowSet_inter_colSet (n : ℕ) (v : Cell n) :
    (rowSet n v ∩ colSet n v).card = 1 := by
  rw [ Finset.card_eq_one ] ; use v ; ext w ; simp +decide [ rowSet, colSet ] ; aesop;

theorem card_rowSet_inter_boxSet (n : ℕ) (v : Cell n) :
    (rowSet n v ∩ boxSet n v).card = n := by
  -- The intersection of rowSet and boxSet is the set of cells in the same row and box as v.
  have h_inter : rowSet n v ∩ boxSet n v = Finset.image (fun c => (v.1, v.2.1, v.2.2.1, c)) (Finset.univ : Finset (Fin n)) := by
    ext ⟨a, b, r, c⟩; simp [rowSet, boxSet];
    tauto;
  rw [ h_inter, Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ]

theorem card_colSet_inter_boxSet (n : ℕ) (v : Cell n) :
    (colSet n v ∩ boxSet n v).card = n := by
  have h_inter : colSet n v ∩ boxSet n v = Finset.image (fun r => (v.1, v.2.1, r, v.2.2.2)) (Finset.univ : Finset (Fin n)) := by
    ext ⟨ a, b, r, c ⟩ ; simp +decide [ colSet, boxSet ] ; aesop;
  rw [ h_inter, Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ]

theorem card_triple_inter (n : ℕ) (v : Cell n) :
    (rowSet n v ∩ colSet n v ∩ boxSet n v).card = 1 := by
  by_contra h;
  exact h ( Finset.card_eq_one.mpr ⟨ v, by ext w; simp +decide [ rowSet, colSet, boxSet ] ; aesop ⟩ )

/--
Three-set inclusion–exclusion, in additive form to avoid `ℕ` subtraction.
-/
theorem card_union3 {α : Type*} [DecidableEq α] (A B C : Finset α) :
    (A ∪ B ∪ C).card + (A ∩ B).card + (A ∩ C).card + (B ∩ C).card =
      A.card + B.card + C.card + (A ∩ B ∩ C).card := by
  have := Finset.card_union_add_card_inter ( A ∪ B ) C;
  have := Finset.card_union_add_card_inter A B; ( have := Finset.card_union_add_card_inter ( A ∩ C ) ( B ∩ C ) ; ( simp_all +decide [ Finset.inter_left_comm, Finset.inter_comm, Finset.inter_assoc ] ; ) );
  rw [ show C ∩ ( A ∪ B ) = ( A ∩ C ) ∪ ( B ∩ C ) by ext; aesop ] at * ; linarith

/--
The neighbour finset of `v` is the union of the row, column, and box sets,
with `v` itself removed.
-/
theorem neighborFinset_eq (n : ℕ) (v : Cell n) :
    (sudokuGraph n).neighborFinset v =
      (rowSet n v ∪ colSet n v ∪ boxSet n v).erase v := by
  ext w; simp [rowSet, colSet, boxSet];
  grind +locals

/--
Inclusion–exclusion value of the union, additive form.
-/
theorem card_union_rcb (n : ℕ) (v : Cell n) :
    (rowSet n v ∪ colSet n v ∪ boxSet n v).card + 2 * n + 1 = 3 * n ^ 2 + 1 := by
  have := @card_union3;
  convert @this _ _ ( rowSet n v ) ( colSet n v ) ( boxSet n v ) using 1 ; ring;
  · rw [ card_rowSet_inter_colSet, card_rowSet_inter_boxSet, card_colSet_inter_boxSet ] ; ring;
  · rw [ card_rowSet, card_colSet, card_boxSet, card_triple_inter ] ; ring

/--
Exact degree formula: every vertex has degree `3 * n ^ 2 - 2 * n - 1`.
-/
theorem sudokuGraph_degree (n : ℕ) (v : Cell n) :
    (sudokuGraph n).degree v = 3 * n ^ 2 - 2 * n - 1 := by
  rw [ SimpleGraph.degree, neighborFinset_eq ];
  rw [ Finset.card_erase_of_mem ];
  · grind +suggestions;
  · unfold rowSet colSet boxSet; aesop;

/-- The Sudoku constraint graph is `(3 * n ^ 2 - 2 * n - 1)`-regular. -/
theorem sudokuGraph_isRegular (n : ℕ) :
    (sudokuGraph n).IsRegularOfDegree (3 * n ^ 2 - 2 * n - 1) :=
  fun v => sudokuGraph_degree n v

/-! ## Proper coloring -/

/-- An explicit proper coloring: `(a, b, r, c) ↦ (b + r, a + c)` (addition in
`Fin n`).  See the file header for why the naive `(r, c)` is *not* proper. -/
def cellColor (n : ℕ) (v : Cell n) : Fin n × Fin n :=
  (v.2.1 + v.2.2.1, v.1 + v.2.2.2)

/--
The coloring assigns different colors to adjacent cells.
-/
theorem cellColor_ne_of_adj (n : ℕ) {v w : Cell n} (h : (sudokuGraph n).Adj v w) :
    cellColor n v ≠ cellColor n w := by
  -- By definition of adjacency, either v.1 = w.1, v.2.1 = w.2.1, or v.2.2.1 = w.2.2.1.
  cases' h with h1 h2;
  contrapose! h1; rcases h2 with ( h2 | h2 | h2 ) <;> simp_all +decide [ cellColor ] ;
  · grind;
  · grind;
  · grind

/-- The explicit proper coloring of `sudokuGraph n` by `Fin n × Fin n`. -/
def sudokuColoring (n : ℕ) : (sudokuGraph n).Coloring (Fin n × Fin n) :=
  Coloring.mk (cellColor n) (fun {_v _w} h => cellColor_ne_of_adj n h)

/--
The Sudoku constraint graph is `n ^ 2`-colorable.
-/
theorem sudokuGraph_colorable (n : ℕ) : (sudokuGraph n).Colorable (n ^ 2) := by
  convert ( sudokuColoring n ).colorable using 1;
  norm_num [ sq ]

/-! ## Explicit cliques -/

/-- The set of all cells lying in a fixed global row `(a, r)`. -/
def rowClique (n : ℕ) (a r : Fin n) : Finset (Cell n) :=
  univ.filter (fun w => w.1 = a ∧ w.2.2.1 = r)

/-- The set of all cells lying in a fixed global column `(b, c)`. -/
def colClique (n : ℕ) (b c : Fin n) : Finset (Cell n) :=
  univ.filter (fun w => w.2.1 = b ∧ w.2.2.2 = c)

/--
A fixed global row is a clique of size `n ^ 2`.
-/
theorem rowClique_isNClique (n : ℕ) (a r : Fin n) :
    (sudokuGraph n).IsNClique (n ^ 2) (rowClique n a r) := by
  constructor;
  · intro v hv w hw hne; simp_all +decide [ rowClique, sudokuGraph_adj_iff ] ;
  · convert card_rowSet n ( a, ⟨ 0, by linarith [ Fin.is_lt a ] ⟩, r, ⟨ 0, by linarith [ Fin.is_lt r ] ⟩ ) using 1;
    congr! 1;
    ext; simp [rowClique, rowSet];
    tauto

/--
A fixed global column is a clique of size `n ^ 2`.
-/
theorem colClique_isNClique (n : ℕ) (b c : Fin n) :
    (sudokuGraph n).IsNClique (n ^ 2) (colClique n b c) := by
  constructor <;> norm_num [ colClique, sudokuGraph ];
  · intro v hv w hw hne; aesop;
  · convert Finset.card_product ( Finset.univ : Finset ( Fin n ) ) ( Finset.univ : Finset ( Fin n ) ) using 1;
    · refine' Finset.card_bij ( fun w hw => ( w.1, w.2.2.1 ) ) _ _ _ <;> simp +decide [ colClique ];
    · norm_num [ sq ]

/-! ## Chromatic number -/

/--
The chromatic number of the order-`n` Sudoku constraint graph is exactly
`n ^ 2`.
-/
theorem sudokuGraph_chromaticNumber (n : ℕ) :
    (sudokuGraph n).chromaticNumber = (n ^ 2 : ℕ) := by
  refine' le_antisymm _ _;
  · convert ( sudokuGraph_colorable n ).chromaticNumber_le using 1;
  · by_cases hn : n = 0;
    · aesop;
    · convert ( rowClique_isNClique n ⟨ 0, Nat.pos_of_ne_zero hn ⟩ ⟨ 0, Nat.pos_of_ne_zero hn ⟩ ) |>.isClique.card_le_chromaticNumber;
      convert ( rowClique_isNClique n ⟨ 0, Nat.pos_of_ne_zero hn ⟩ ⟨ 0, Nat.pos_of_ne_zero hn ⟩ ) |>.card_eq.symm

end SudokuConstraintGraph