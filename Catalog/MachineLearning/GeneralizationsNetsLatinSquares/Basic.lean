import Mathlib

/-!
# Generalizations of nets and Latin squares

A finite, coordinate-level formalization of the basic regularity and representation
results in Brian Curtin, *Generalizations of nets and Latin squares* (2026).

The paper's two types of parallel families are represented by coordinate maps.
Their fibres are the lines; bijectivity of every cross-coordinate map says exactly
that a line of either type meets a line of the other type in one point.  This avoids
irrelevant bookkeeping about finite partitions while retaining the incidence
content of axioms (R-1) and (R-2).
-/

namespace GeneralizationsNetsLatinSquares

abbrev Grid (m n : ℕ) := Fin m × Fin n
abbrev Matrix (m n a : ℕ) := Grid m n → Fin a

/-- Every symbol occurs exactly once in every column. -/
def ColumnLatin {m n : ℕ} (C : Matrix m n m) : Prop :=
  ∀ j : Fin n, Function.Bijective (fun i : Fin m => C (i, j))

/-- Every symbol occurs exactly once in every row. -/
def RowLatin {m n : ℕ} (R : Matrix m n n) : Prop :=
  ∀ i : Fin m, Function.Bijective (fun j : Fin n => R (i, j))

/-- Every ordered pair of symbols occurs at exactly one grid position. -/
def Orthogonal {m n : ℕ} (C : Matrix m n m) (R : Matrix m n n) : Prop :=
  Function.Bijective (fun p => (C p, R p))

/-- The horizontal and vertical coordinate matrices from Example 7.4. -/
def horizontal {m n : ℕ} : Matrix m n m := fun p => p.1
def vertical {m n : ℕ} : Matrix m n n := fun p => p.2

/-- A cooperative pair (Definition 7.2). -/
structure CooperativePair (m n : ℕ) where
  C : Matrix m n m
  R : Matrix m n n
  columnLatin : ColumnLatin C
  rowLatin : RowLatin R
  orthogonal : Orthogonal C R

/-- A family of cooperative pairs, indexed independently on the two sides. -/
structure CooperativeSystem (m n : ℕ) (U V : Type*) where
  C : U → Matrix m n m
  R : V → Matrix m n n
  columnLatin : ∀ u, ColumnLatin (C u)
  rowLatin : ∀ v, RowLatin (R v)
  orthogonal : ∀ u v, Orthogonal (C u) (R v)

/-- Coordinate form of a reticulation. Fibres of `weftCoord u` and
`warpCoord v` are the two types of lines. -/
structure Reticulation (P : Type*) (m n : ℕ) (U V : Type*) where
  weftCoord : U → P → Fin m
  warpCoord : V → P → Fin n
  cross_bijective : ∀ u v, Function.Bijective (fun p => (weftCoord u p, warpCoord v p))

/-- Coordinate form of a svelte semi-orthogonal array (Definition 6.1). -/
structure SvelteArray (m n : ℕ) (U V : Type*) where
  Row : Type*
  [finiteRow : Fintype Row]
  left : Row → U → Fin m
  right : Row → V → Fin n
  cross_bijective : ∀ u v, Function.Bijective (fun y => (left y u, right y v))

attribute [instance] SvelteArray.finiteRow

/-
The first nontrivial regularity fact: a column-Latin matrix has a unique
position carrying any prescribed symbol in a prescribed column.
-/
theorem columnLatin_unique_position {m n : ℕ} {C : Matrix m n m}
    (hC : ColumnLatin C) (j : Fin n) (q : Fin m) :
    ∃! i : Fin m, C (i, j) = q := by
  obtain ⟨ i, hi ⟩ := hC j |>.2 q;
  exact ⟨ i, hi, fun k hk => by have := hC j |>.1 ( by aesop : C ( k, j ) = C ( i, j ) ) ; aesop ⟩

/-
In a cooperative pair, each weft line has exactly one point in each grid
column. This is the fibre/line version of column-Latin regularity.
-/
theorem cooperative_weft_unique_in_column {m n : ℕ} (A : CooperativePair m n)
    (j : Fin n) (q : Fin m) : ∃! i : Fin m, A.C (i, j) = q := by
  convert columnLatin_unique_position A.columnLatin j q

/-
Dually, each warp line has exactly one point in each grid row.
-/
theorem cooperative_warp_unique_in_row {m n : ℕ} (A : CooperativePair m n)
    (i : Fin m) (r : Fin n) : ∃! j : Fin n, A.R (i, j) = r := by
  exact A.rowLatin i |>.surjective r |> fun ⟨ j, hj ⟩ => ⟨ j, hj, fun j' hj' => A.rowLatin i |>.injective <| hj'.trans hj.symm ⟩

/-
A weft line and a warp line in a cooperative pair meet in exactly one point
(the reticulation axiom (R-1)).
-/
theorem cooperative_cross_unique {m n : ℕ} (A : CooperativePair m n)
    (q : Fin m) (r : Fin n) :
    ∃! p : Grid m n, A.C p = q ∧ A.R p = r := by
  convert A.orthogonal.existsUnique ( q, r ) using 1;
  grind

/-
Lemma 7.5(i): column-Latin is equivalent to orthogonality with the vertical
coordinate matrix.
-/
theorem columnLatin_iff_orthogonal_vertical {m n : ℕ} (C : Matrix m n m) :
    ColumnLatin C ↔ Orthogonal C vertical := by
  constructor;
  · intro hC;
    refine' ⟨ _, _ ⟩;
    · intro p q h; have := hC p.2; have := this.1; aesop;
    · intro ⟨ q, j ⟩ ; cases' columnLatin_unique_position hC j q with i hi; use ( i, j ) ; aesop;
  · intro h j;
    have := h.2;
    exact ⟨ fun i i' h' => by have := @h.1 ( i, j ) ( i', j ) ; aesop, fun q => by have := @this ( q, j ) ; aesop ⟩

/-
Lemma 7.5(ii), the row/column dual of the preceding result.
-/
theorem rowLatin_iff_orthogonal_horizontal {m n : ℕ} (R : Matrix m n n) :
    RowLatin R ↔ Orthogonal horizontal R := by
  constructor;
  · intro h;
    refine' Function.bijective_iff_has_inverse.mpr _;
    refine' ⟨ fun p => ( p.1, Classical.choose ( h p.1 |>.2 p.2 ) ), _, _ ⟩ <;> simp +decide [ Function.LeftInverse, Function.RightInverse ];
    · intro a b; have := Classical.choose_spec ( h a |>.2 ( R ( a, b ) ) ) ; have := h a |>.1; aesop;
    · exact fun a b => ⟨ rfl, Classical.choose_spec ( h a |>.2 b ) ⟩;
  · intro h i; have := h.2; simp_all +decide [ Function.Bijective ] ;
    constructor <;> intro j <;> have := this ( i, j ) <;> simp_all +decide [Function.Surjective] ;
    · intro k hk; have := h.1 ( show ( horizontal ( i, j ), R ( i, j ) ) = ( horizontal ( i, k ), R ( i, k ) ) from by aesop ) ; aesop;
    · obtain ⟨ a, b, ha, hb ⟩ := this i j; use b; have := h.1; have := @this ( i, b ) ( a, b ) ; aesop;

/-- Example 7.4: the coordinate matrices form a cooperative pair. -/
def coordinateCooperativePair (m n : ℕ) : CooperativePair m n where
  C := horizontal
  R := vertical
  columnLatin := (columnLatin_iff_orthogonal_vertical horizontal).2 <| by
    simp [Orthogonal, horizontal, vertical]
  rowLatin := (rowLatin_iff_orthogonal_horizontal vertical).2 <| by
    simp [Orthogonal, horizontal, vertical]
  orthogonal := by
    simp [Orthogonal, horizontal, vertical]

/-- Every cooperative system yields a reticulation on its underlying grid. -/
def CooperativeSystem.toReticulation {m n : ℕ} {U V : Type*}
    (S : CooperativeSystem m n U V) : Reticulation (Grid m n) m n U V where
  weftCoord := S.C
  warpCoord := S.R
  cross_bijective := S.orthogonal

/-
In the induced reticulation, every chosen pair of opposite-type lines has a
unique intersection point.
-/
theorem system_lines_unique_intersection {m n : ℕ} {U V : Type*}
    (S : CooperativeSystem m n U V) (u : U) (v : V) (q : Fin m) (r : Fin n) :
    ∃! p : Grid m n,
      S.toReticulation.weftCoord u p = q ∧ S.toReticulation.warpCoord v p = r := by
  convert S.orthogonal u v |>.existsUnique ⟨ q, r ⟩ using 1;
  simp +decide [ Prod.ext_iff ];
  rfl

/-- The row encoding of a cooperative system, as in Theorem 7.7(i). -/
def CooperativeSystem.toSvelteArray {m n : ℕ} {U V : Type*}
    (S : CooperativeSystem m n U V) : SvelteArray m n U V where
  Row := Grid m n
  left p u := S.C u p
  right p v := S.R v p
  cross_bijective := S.orthogonal

/-
The encoding retains exactly one row with any prescribed pair of coordinates.
-/
theorem encoded_array_unique_row {m n : ℕ} {U V : Type*}
    (S : CooperativeSystem m n U V) (u : U) (v : V) (q : Fin m) (r : Fin n) :
    ∃! y : S.toSvelteArray.Row,
      S.toSvelteArray.left y u = q ∧ S.toSvelteArray.right y v = r := by
  simpa [CooperativeSystem.toSvelteArray, CooperativeSystem.toReticulation] using
    system_lines_unique_intersection S u v q r

/-- Reading the two groups of coordinates as line labels turns a svelte array
back into a coordinate reticulation, the construction in Theorem 6.3(ii). -/
def SvelteArray.toReticulation {m n : ℕ} {U V : Type*}
    (S : SvelteArray m n U V) : Reticulation S.Row m n U V where
  weftCoord u y := S.left y u
  warpCoord v y := S.right y v
  cross_bijective := S.cross_bijective

/-
Combinatorial regularity, Theorem 3.1(i): every finite coordinate
reticulation has exactly `m*n` points.
-/
theorem Reticulation.card_points {P : Type*} [Fintype P] {m n : ℕ}
    {U V : Type*} (R : Reticulation P m n U V) (u : U) (v : V) :
    Fintype.card P = m * n := by
  have := R.cross_bijective u v;
  simpa using Fintype.card_congr ( Equiv.ofBijective _ this )

/-
Consequently every svelte semi-orthogonal array has exactly `m*n` rows.
-/
theorem SvelteArray.card_rows {m n : ℕ} {U V : Type*}
    (S : SvelteArray m n U V) (u : U) (v : V) :
    Fintype.card S.Row = m * n := by
  exact S.toReticulation.card_points u v

end GeneralizationsNetsLatinSquares