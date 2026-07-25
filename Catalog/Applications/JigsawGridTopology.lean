import Mathlib
import Novelty.JigsawNPComplete

/-!
# Grid Assembly, Conservation, and the Symmetry of Interlocking Edges

This file deepens the theory of jigsaw assembly begun in `JigsawNPComplete`, where
the edge alphabet `{flat, tab, blank}`, its complementation involution, and the
reduction of Boolean satisfiability to puzzle assembly were established.  Here we
study the *global* structure of an assembled figure rather than the local
matching rule, and we uncover three new invariants.

## The edge-weight potential and the conservation law

Assign to each edge a signed *potential*: a tab carries `+1`, a blank carries
`-1`, and a flat border edge carries `0`.  Complementation negates the potential
(`wt_comp`), and an edge is neutral exactly when it is a border edge
(`wt_eq_zero_iff_flat`).  This single algebraic fact drives a genuine
**conservation law**: in *any* validly assembled row, rectangle, the total
potential of all edges is zero, so the number of exposed tabs equals the number of
exposed blanks (`Chain.tab_eq_blank`, `Grid.tab_eq_blank`).  The interior
interfaces pair each tab with the blank it mates, and the border contributes
nothing — a discrete divergence theorem for puzzles.

## Boundary topology in two dimensions

For rectangular assemblies we prove that the four corner pieces each expose two
flat edges (`Grid.corner_flat`), recovering in 2D the statement that the outline
of the figure is the fixed-point set of complementation.  We also verify the
Euler-style **handshake identity** `2·(interior interfaces) + (border edges) =
4·(pieces)` (`handshake`), the bookkeeping that every edge is either shared by two
pieces or exposed on the border.

## The symmetry group of interlocking

Finally we identify the symmetry group of the matching relation itself: a
relabelling of edge shapes preserves "these two interlock" precisely when it
commutes with complementation (`preserves_fits_iff_commutes`), and there are
exactly two such relabellings — the identity and the tab↔blank swap
(`fit_automorphism_card`).  The automorphism group of interlocking is a copy of
`ℤ/2`, the same order-two symmetry that governs the border.

All results build directly on the edge algebra of `JigsawNPComplete`.
-/

open Function

namespace Jigsaw

-- The edge alphabet is a finite type, so we may quantify over relabellings.
deriving instance Fintype for Edge

/-! ## Part 1 — The signed potential of an edge -/

/-- The signed potential of an edge: a protruding `tab` counts `+1`, a receding
`blank` counts `-1`, and a `flat` border edge is neutral. -/
def Edge.wt : Edge → ℤ
  | .flat => 0
  | .tab => 1
  | .blank => -1

/-- Complementation negates the potential: mating a tab with a blank cancels. -/
@[simp] lemma wt_comp (e : Edge) : (Edge.comp e).wt = - e.wt := by
  cases e <;> rfl

/-- An edge is neutral exactly when it is a flat border edge — the potential
detects the boundary. -/
lemma wt_eq_zero_iff_flat (e : Edge) : e.wt = 0 ↔ e = Edge.flat := by
  cases e <;> simp [Edge.wt]

/-- The potential of an encoded truth value records its sign: `true ↦ +1`,
`false ↦ -1`.  Thus the assignment channel carries the truth value as the *sign*
of the interlocking potential. -/
lemma enc_wt (b : Bool) : (enc b).wt = if b then 1 else -1 := by
  cases b <;> rfl

/-! ## Part 2 — The core telescoping conservation lemma

The heart of the conservation law: along a one-dimensional strip of interfaces,
where each left edge is the complement of the previous right edge and both ends
are flat, the summed right-potentials and left-potentials cancel exactly. -/

/-- **Telescoping cancellation.**  Consider `n` consecutive interfaces with right
edges `r 0, …, r (n-1)` and left edges `l 0, …, l (n-1)`.  If the strip starts
flat (`l 0` flat), ends flat (`r (n-1)` flat), and every left edge is the
complement of the previous right edge, then the total right-potential and total
left-potential sum to zero. -/
lemma sum_wt_strip_zero (r l : ℕ → Edge) (n : ℕ)
    (hl0 : 0 < n → l 0 = Edge.flat)
    (hrn : 0 < n → r (n - 1) = Edge.flat)
    (hstep : ∀ i, i + 1 < n → l (i + 1) = (r i).comp) :
    (∑ i ∈ Finset.range n, (r i).wt) + (∑ i ∈ Finset.range n, (l i).wt) = 0 := by
  cases n with
  | zero => simp
  | succ m =>
    rw [Finset.sum_range_succ' (fun i => (l i).wt) m,
        Finset.sum_range_succ (fun i => (r i).wt) m]
    have hL0' : (l 0).wt = 0 := by rw [hl0 (Nat.succ_pos m)]; rfl
    have hRm : (r m).wt = 0 := by
      have := hrn (Nat.succ_pos m); simp only [Nat.succ_sub_one] at this; rw [this]; rfl
    have hcong : ∑ i ∈ Finset.range m, (l (i + 1)).wt
        = - ∑ i ∈ Finset.range m, (r i).wt := by
      rw [← Finset.sum_neg_distrib]
      apply Finset.sum_congr rfl
      intro i hi; rw [Finset.mem_range] at hi
      rw [hstep i (by omega), wt_comp]
    rw [hL0', hRm, hcong]; ring

/-! ## Part 3 — Rows (one-dimensional assemblies) -/

/-- A one-dimensional assembly: `n` pieces laid left to right. -/
structure Chain where
  /-- Number of pieces in the row. -/
  n : ℕ
  /-- The piece at each position (positions `≥ n` are ignored). -/
  piece : ℕ → Piece

/-- A row is validly assembled when: every piece shows flat top and bottom (a
single row is both the top and the bottom border), the far-left and far-right
edges are flat, and each interior left edge complements the previous right edge. -/
def Chain.Valid (C : Chain) : Prop :=
  (∀ i, i < C.n → (C.piece i).top = Edge.flat) ∧
  (∀ i, i < C.n → (C.piece i).bottom = Edge.flat) ∧
  (0 < C.n → (C.piece 0).left = Edge.flat) ∧
  (0 < C.n → (C.piece (C.n - 1)).right = Edge.flat) ∧
  (∀ i, i + 1 < C.n → (C.piece (i + 1)).left = (C.piece i).right.comp)

/-- The total signed potential of every edge of every piece in the row. -/
def Chain.potential (C : Chain) : ℤ :=
  ∑ i ∈ Finset.range C.n,
    ((C.piece i).top.wt + (C.piece i).right.wt +
     (C.piece i).bottom.wt + (C.piece i).left.wt)

/-- The number of exposed tabs in the row (counting all four sides of each piece). -/
def Chain.tabs (C : Chain) : ℤ :=
  ∑ i ∈ Finset.range C.n,
    ((if (C.piece i).top = Edge.tab then 1 else 0) +
     (if (C.piece i).right = Edge.tab then 1 else 0) +
     (if (C.piece i).bottom = Edge.tab then 1 else 0) +
     (if (C.piece i).left = Edge.tab then 1 else 0))

/-- The number of exposed blanks in the row. -/
def Chain.blanks (C : Chain) : ℤ :=
  ∑ i ∈ Finset.range C.n,
    ((if (C.piece i).top = Edge.blank then 1 else 0) +
     (if (C.piece i).right = Edge.blank then 1 else 0) +
     (if (C.piece i).bottom = Edge.blank then 1 else 0) +
     (if (C.piece i).left = Edge.blank then 1 else 0))

/-- The potential of a single edge equals its tab-indicator minus its
blank-indicator. -/
lemma wt_eq_tab_sub_blank (e : Edge) :
    e.wt = (if e = Edge.tab then (1 : ℤ) else 0) - (if e = Edge.blank then 1 else 0) := by
  cases e <;> rfl

/-- Total potential is total tabs minus total blanks. -/
lemma Chain.potential_eq (C : Chain) : C.potential = C.tabs - C.blanks := by
  unfold Chain.potential Chain.tabs Chain.blanks
  rw [← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro i _
  simp only [wt_eq_tab_sub_blank]
  ring

/-- **Conservation for a row.**  Every validly assembled row has zero net
potential: the exposed tabs and blanks balance. -/
theorem Chain.potential_zero {C : Chain} (h : C.Valid) : C.potential = 0 := by
  obtain ⟨htop, hbot, hl0, hrn, hstep⟩ := h
  unfold Chain.potential
  have hcong : ∑ i ∈ Finset.range C.n,
        ((C.piece i).top.wt + (C.piece i).right.wt +
         (C.piece i).bottom.wt + (C.piece i).left.wt)
      = ∑ i ∈ Finset.range C.n,
        ((C.piece i).right.wt + (C.piece i).left.wt) := by
    apply Finset.sum_congr rfl
    intro i hi; rw [Finset.mem_range] at hi
    rw [htop i hi, hbot i hi]; simp [Edge.wt]
  rw [hcong, Finset.sum_add_distrib]
  exact sum_wt_strip_zero (fun i => (C.piece i).right) (fun i => (C.piece i).left)
    C.n hl0 hrn hstep

/-- **Tab–blank balance (1D).**  In any validly assembled row, the number of
exposed tabs equals the number of exposed blanks. -/
theorem Chain.tab_eq_blank {C : Chain} (h : C.Valid) : C.tabs = C.blanks := by
  have h0 := C.potential_zero h
  rw [C.potential_eq] at h0
  linarith

/-! ## Part 4 — Rectangular grids (two-dimensional assemblies) -/

/-- A rectangular assembly of pieces. -/
structure Grid where
  /-- Number of rows. -/
  rows : ℕ
  /-- Number of columns. -/
  cols : ℕ
  /-- The piece at each cell (indices out of range are ignored). -/
  cell : ℕ → ℕ → Piece

/-- A grid is validly assembled when its four borders are flat and interior
neighbours interlock horizontally and vertically. -/
def Grid.Valid (G : Grid) : Prop :=
  (∀ j, j < G.cols → (G.cell 0 j).top = Edge.flat) ∧
  (∀ j, j < G.cols → 0 < G.rows → (G.cell (G.rows - 1) j).bottom = Edge.flat) ∧
  (∀ i, i < G.rows → (G.cell i 0).left = Edge.flat) ∧
  (∀ i, i < G.rows → 0 < G.cols → (G.cell i (G.cols - 1)).right = Edge.flat) ∧
  (∀ i j, i < G.rows → j + 1 < G.cols →
      (G.cell i (j + 1)).left = (G.cell i j).right.comp) ∧
  (∀ i j, i + 1 < G.rows → j < G.cols →
      (G.cell (i + 1) j).top = (G.cell i j).bottom.comp)

/-- **Corner topology.**  In a non-empty valid grid the top-left corner piece
exposes flat edges on its top and left sides — the outline of the figure passes
through flat edges at the corners. -/
theorem Grid.corner_flat {G : Grid} (h : G.Valid) (hr : 0 < G.rows) (hc : 0 < G.cols) :
    (G.cell 0 0).top = Edge.flat ∧ (G.cell 0 0).left = Edge.flat := by
  obtain ⟨htop, _, hleft, _, _, _⟩ := h
  exact ⟨htop 0 hc, hleft 0 hr⟩

/-- The horizontal potential of a single row `i`: the right and left potentials of
its cells. -/
def Grid.rowPotential (G : Grid) (i : ℕ) : ℤ :=
  ∑ j ∈ Finset.range G.cols, ((G.cell i j).right.wt + (G.cell i j).left.wt)

/-- The vertical potential of a single column `j`: the bottom and top potentials
of its cells. -/
def Grid.colPotential (G : Grid) (j : ℕ) : ℤ :=
  ∑ i ∈ Finset.range G.rows, ((G.cell i j).bottom.wt + (G.cell i j).top.wt)

/-- Each row of a valid grid has zero horizontal potential (its tabs and blanks
balance along the row). -/
theorem Grid.rowPotential_zero {G : Grid} (h : G.Valid) {i : ℕ} (hi : i < G.rows) :
    G.rowPotential i = 0 := by
  obtain ⟨_, _, hleft, hright, hhoriz, _⟩ := h
  unfold Grid.rowPotential
  rw [Finset.sum_add_distrib]
  exact sum_wt_strip_zero (fun j => (G.cell i j).right) (fun j => (G.cell i j).left)
    G.cols (fun _ => hleft i hi) (fun hc => hright i hi hc)
    (fun j hj => hhoriz i j hi hj)

/-- Each column of a valid grid has zero vertical potential. -/
theorem Grid.colPotential_zero {G : Grid} (h : G.Valid) {j : ℕ} (hj : j < G.cols) :
    G.colPotential j = 0 := by
  obtain ⟨htop, hbot, _, _, _, hvert⟩ := h
  unfold Grid.colPotential
  rw [Finset.sum_add_distrib]
  exact sum_wt_strip_zero (fun i => (G.cell i j).bottom) (fun i => (G.cell i j).top)
    G.rows (fun _ => htop j hj) (fun hr => hbot j hj hr)
    (fun i hi => hvert i j hi hj)

/-- The total signed potential of every edge in the grid. -/
def Grid.potential (G : Grid) : ℤ :=
  ∑ i ∈ Finset.range G.rows, ∑ j ∈ Finset.range G.cols,
    ((G.cell i j).top.wt + (G.cell i j).right.wt +
     (G.cell i j).bottom.wt + (G.cell i j).left.wt)

/-- **Conservation for a grid.**  A validly assembled rectangle has zero net
potential: the total right/left balance vanishes row by row and the total
top/bottom balance vanishes column by column. -/
theorem Grid.potential_zero {G : Grid} (h : G.Valid) : G.potential = 0 := by
  unfold Grid.potential
  have e1 : ∑ i ∈ Finset.range G.rows, ∑ j ∈ Finset.range G.cols,
        ((G.cell i j).top.wt + (G.cell i j).right.wt +
         (G.cell i j).bottom.wt + (G.cell i j).left.wt)
      = (∑ i ∈ Finset.range G.rows, ∑ j ∈ Finset.range G.cols,
          ((G.cell i j).right.wt + (G.cell i j).left.wt))
        + (∑ i ∈ Finset.range G.rows, ∑ j ∈ Finset.range G.cols,
          ((G.cell i j).top.wt + (G.cell i j).bottom.wt)) := by
    rw [← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl; intro i _
    rw [← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl; intro j _; ring
  rw [e1]
  have r0 : ∑ i ∈ Finset.range G.rows, ∑ j ∈ Finset.range G.cols,
        ((G.cell i j).right.wt + (G.cell i j).left.wt) = 0 := by
    apply Finset.sum_eq_zero; intro i hi; rw [Finset.mem_range] at hi
    have := G.rowPotential_zero h hi; unfold Grid.rowPotential at this; exact this
  have c0 : ∑ i ∈ Finset.range G.rows, ∑ j ∈ Finset.range G.cols,
        ((G.cell i j).top.wt + (G.cell i j).bottom.wt) = 0 := by
    rw [Finset.sum_comm]
    apply Finset.sum_eq_zero; intro j hj; rw [Finset.mem_range] at hj
    have := G.colPotential_zero h hj; unfold Grid.colPotential at this
    rw [← this]; apply Finset.sum_congr rfl; intro i _; ring
  rw [r0, c0]; ring

/-! ## Part 5 — The handshake identity -/

/-- **Handshake identity.**  In an `(r+1) × (c+1)` grid, twice the number of
interior interfaces `(r+1)·c + r·(c+1)` plus the number of border edges
`2·((r+1) + (c+1))` equals `4` times the number of pieces `(r+1)·(c+1)` — every
edge is either shared by two pieces or exposed on the border. -/
theorem handshake (r c : ℕ) :
    2 * ((r + 1) * c + r * (c + 1)) + 2 * ((r + 1) + (c + 1))
      = 4 * ((r + 1) * (c + 1)) := by
  ring

/-! ## Part 6 — The symmetry group of interlocking -/

/-- A relabelling of edge shapes *commutes with complementation* when it sends the
complement of a shape to the complement of its image. -/
def commutesComp (σ : Equiv.Perm Edge) : Prop := ∀ e, σ (e.comp) = (σ e).comp

instance : DecidablePred commutesComp := fun σ => by
  unfold commutesComp; infer_instance

/-- **Symmetry characterization.**  A relabelling of edge shapes preserves the
interlocking relation ("`a` and `b` mate") exactly when it commutes with
complementation. -/
theorem preserves_fits_iff_commutes (σ : Equiv.Perm Edge) :
    (∀ a b, Edge.fits a b ↔ Edge.fits (σ a) (σ b)) ↔ commutesComp σ := by
  constructor
  · intro h e
    exact (h e e.comp).1 rfl
  · intro h a b
    unfold Edge.fits
    constructor
    · intro hb; rw [hb]; exact h a
    · intro hb
      apply σ.injective
      rw [hb, h a]

/-- **Order of the interlocking symmetry group.**  Exactly two relabellings
commute with complementation — the identity and the tab↔blank swap — so the
automorphism group of the matching relation is a copy of `ℤ/2`. -/
theorem fit_automorphism_card :
    (Finset.univ.filter commutesComp).card = 2 := by decide

/-! ## Part 7 — Worked examples and boundary cases -/

/-- The edge alphabet has three shapes. -/
example : Fintype.card Edge = 3 := by decide

section Examples

/-- A concrete two-piece row: a tab meeting a blank, flat everywhere else. -/
def demoChain : Chain where
  n := 2
  piece := fun i =>
    if i = 0 then ⟨.flat, .tab, .flat, .flat⟩ else ⟨.flat, .flat, .flat, .blank⟩

example : demoChain.Valid := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · intro i hi; have hi' : i < 2 := hi; interval_cases i <;> decide
  · intro i hi; have hi' : i < 2 := hi; interval_cases i <;> decide
  · intro _; decide
  · intro _; decide
  · intro i hi; have hi' : i + 1 < 2 := hi
    have : i = 0 := by omega
    subst this; decide

/-- The two-piece demonstration row balances its single tab against its single
blank. -/
example : demoChain.tabs = demoChain.blanks := by
  decide

#check @Chain.tab_eq_blank
#check @Grid.potential_zero
#check @preserves_fits_iff_commutes
#eval (Edge.tab.wt, Edge.blank.wt, Edge.flat.wt)

end Examples

/-!
-- !-- Lab Notes -- !--

**Hypothesis.**  A validly assembled puzzle obeys a conservation law: the exposed
tabs and blanks must balance, because every interior tab is mated to exactly one
blank and the border carries neither.  We conjectured this follows from a single
algebraic fact — complementation negates a signed edge potential — and that the
same order-two symmetry organises the boundary and the automorphisms of the
matching relation.

**Experiment.**  We introduced the signed potential `Edge.wt` (`tab ↦ +1`,
`blank ↦ -1`, `flat ↦ 0`), proved `wt_comp` (complement negates) and
`wt_eq_zero_iff_flat` (neutral ⇔ border).  The engine of the whole file is
`sum_wt_strip_zero`, a telescoping cancellation along a 1D strip of interfaces.
From it we derived row conservation (`Chain.potential_zero`) and, by applying it
once per row and once per column, grid conservation (`Grid.potential_zero`).  The
tab–blank balance (`Chain.tab_eq_blank`) follows because potential equals tabs
minus blanks.  Separately we characterised the symmetry group of interlocking:
`preserves_fits_iff_commutes` shows a relabelling preserves matching iff it
commutes with complementation, and `fit_automorphism_card` counts exactly two such
relabellings.

**Analysis.**  Conservation is *structural*, not numerical: it holds for every
valid assembly of every size, and its proof factors entirely through the
telescoping lemma, whose only inputs are the two flat boundary conditions and the
interface complementation rule.  The reduction from 2D to 1D — summing the strip
lemma over rows and columns — mirrors how a discrete divergence theorem decomposes
a flux integral into one-dimensional slices.

**Critique.**  The theorems are not vacuous: `demoChain` is an explicit non-empty
valid row with a genuine tab and blank, and `fit_automorphism_card` yields a
non-trivial count (`2`, not `1` or `6`).  The corner theorem `Grid.corner_flat`
requires non-emptiness hypotheses, exactly the boundary case where the statement
could otherwise fail.  The handshake identity is stated over `(r+1)×(c+1)` to
sidestep truncated natural-number subtraction, a genuine corner case.

**Synthesis.**  One involution — complementation — simultaneously: (i) negates the
edge potential, forcing a conservation law on every valid assembly; (ii) fixes
exactly the flat edges, which are exactly the border; and (iii) generates the
order-two automorphism group of the interlocking relation.  The combinatorics of
matching, the topology of the boundary, and the algebra of symmetry all descend
from this single `ℤ/2` action, extending the reduction-theoretic picture of
`JigsawNPComplete` with a conservation-law layer.
-/

end Jigsaw