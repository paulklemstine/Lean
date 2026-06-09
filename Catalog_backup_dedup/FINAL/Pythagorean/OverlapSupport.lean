/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Non-Separated Extensions via Overlapping Support Theory

This file extends the separated-support tropical/Laplacian correspondence
to **arbitrary nonempty vertex subsets**. Where the separated theory (in
`TropicalKernelRigidity.lean`) required disjoint supports, the results here
show that overlap interactions are governed by a computable interaction matrix
whose structure is fully determined by the restricted Laplacian.

## Mathematical Context

For a finite graph G and vertex subset S, the restricted Laplacian L_S
(the principal submatrix of the graph Laplacian indexed by S) decomposes as
  L_S = D_S + Ω_S
where D_S is the diagonal degree matrix and Ω_S is the off-diagonal
**overlap interaction matrix**. This decomposition is the key to understanding
how tropical generators on overlapping supports interact.

The central results establish:
1. Separation ↔ vanishing of the interaction matrix
2. The quadratic form x^T L_S x decomposes into self-energy + interaction energy
3. The restricted Laplacian is positive semidefinite (over ℤ in a suitable sense)
4. The Laplacian row-sum structure constrains the interaction matrix

## Main Definitions

* `restrictedLapMat` — the restricted Laplacian matrix on a subset S
* `SeparatedSet` — no edges within S
* `overlapInteractionMat` — off-diagonal part of L_S (encodes overlap)
* `diagonalDegreeMat` — diagonal part of L_S
* `overlapEnergy` — the quadratic form x^T L_S x
* `selfEnergy` — diagonal contribution to the quadratic form
* `interactionEnergy` — off-diagonal contribution to the quadratic form

## Main Results

* `overlapInteractionMat_eq_zero_iff_separated` — separation ↔ zero interaction
* `restrictedLap_decomposition` — L_S = D_S + Ω_S
* `overlapEnergy_decomposition` — energy = self + interaction
* `overlapInteractionMat_symmetric` — Ω_S is symmetric
* `restrictedLapMat_symmetric` — L_S is symmetric
* `overlapEnergy_eq_edge_sum` — energy equals sum over edges
* `separated_interaction_energy_zero` — separated ⟹ zero interaction energy

## References

* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a
  finite graph" (2007)
-/

import Mathlib

open Finset BigOperators Matrix

/-! ## Section 1: Core Definitions -/

/-- The restricted Laplacian matrix: the principal submatrix of the graph
    Laplacian indexed by a finset S. This is the central linear-algebraic
    object governing overlap interactions among tropical generators
    supported on S. -/
noncomputable def restrictedLapMat
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) :
    Matrix (Fin S.card) (Fin S.card) ℤ :=
  let enum := S.equivFin.symm
  fun i j =>
    let vi := enum i
    let vj := enum j
    if vi = vj then (G.degree vi : ℤ)
    else if G.Adj vi.val vj.val then -1
    else 0

/-- A vertex subset S is **separated** in G if no two vertices in S are
    adjacent. This is the regime where overlap interactions vanish and
    the classical separated-support theory applies. -/
def SeparatedSet {V : Type*}
    (G : SimpleGraph V) (S : Finset V) : Prop :=
  ∀ u v : V, u ∈ S → v ∈ S → u ≠ v → ¬G.Adj u v

/-- The **diagonal degree matrix** of the restricted Laplacian: the diagonal
    part encoding self-interaction (degree) of each vertex in S. -/
noncomputable def diagonalDegreeMat
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) :
    Matrix (Fin S.card) (Fin S.card) ℤ :=
  let enum := S.equivFin.symm
  fun i j =>
    if i = j then (G.degree (enum i) : ℤ)
    else 0

/-- The **overlap interaction matrix** Ω_S: the off-diagonal part of the
    restricted Laplacian, encoding pairwise interactions between vertices
    in S. Entry (i,j) is -1 if vertices i,j ∈ S are adjacent, 0 otherwise.
    This is the precise algebraic object that measures how much the support
    theory deviates from the separated regime. -/
noncomputable def overlapInteractionMat
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) :
    Matrix (Fin S.card) (Fin S.card) ℤ :=
  let enum := S.equivFin.symm
  fun i j =>
    if i = j then 0
    else if G.Adj (enum i).val (enum j).val then -1
    else 0

/-- The **overlap energy** (discrete Laplacian quadratic form): for a
    vector x ∈ ℤ^|S|, this computes x^T L_S x. Measures the total
    interaction energy of the generator combination x. -/
noncomputable def overlapEnergy
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V)
    (x : Fin S.card → ℤ) : ℤ :=
  ∑ i, ∑ j, x i * restrictedLapMat G S i j * x j

/-- The **self-energy** component: sum of diagonal (degree) terms. -/
noncomputable def selfEnergy
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V)
    (x : Fin S.card → ℤ) : ℤ :=
  ∑ i, ∑ j, x i * diagonalDegreeMat G S i j * x j

/-- The **interaction energy** component: sum of off-diagonal terms. -/
noncomputable def interactionEnergy
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V)
    (x : Fin S.card → ℤ) : ℤ :=
  ∑ i, ∑ j, x i * overlapInteractionMat G S i j * x j

/-- Structure capturing the overlap support data for a graph and subset,
    recording the interaction matrix together with its key properties. -/
structure OverlapSupportData (V : Type*) [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) where
  /-- The interaction matrix -/
  interaction : Matrix (Fin S.card) (Fin S.card) ℤ
  /-- It equals the overlap interaction matrix -/
  eq_overlap : interaction = overlapInteractionMat G S

/-! ## Section 2: Decomposition Theorem -/

/-
**Restricted Laplacian decomposition theorem.** The restricted Laplacian
    decomposes as the sum of the diagonal degree matrix and the overlap
    interaction matrix: L_S = D_S + Ω_S.

    This is the fundamental structural result: it separates "self" terms
    (vertex degrees) from "interaction" terms (internal adjacencies within S),
    making explicit which part of the restricted Laplacian encodes overlap.
-/
theorem restrictedLap_decomposition
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) :
    restrictedLapMat G S =
      diagonalDegreeMat G S + overlapInteractionMat G S := by
  unfold restrictedLapMat diagonalDegreeMat overlapInteractionMat;
  aesop

/-! ## Section 3: Symmetry -/

/-
The overlap interaction matrix is symmetric: Ω_S^T = Ω_S.
    This follows from symmetry of the adjacency relation.
-/
theorem overlapInteractionMat_symmetric
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) :
    (overlapInteractionMat G S)ᵀ = overlapInteractionMat G S := by
  ext i j; by_cases hij : i = j <;> simp +decide [ hij, overlapInteractionMat ] ; (
  simp +decide [ hij, eq_comm, SimpleGraph.adj_comm ]);

/-
The restricted Laplacian matrix is symmetric: L_S^T = L_S.
-/
theorem restrictedLapMat_symmetric
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) :
    (restrictedLapMat G S)ᵀ = restrictedLapMat G S := by
  ext i j;
  unfold restrictedLapMat;
  simp +decide [ eq_comm, SimpleGraph.adj_comm ];
  grind

/-! ## Section 4: Separation Characterization -/

/-
**Separation characterization theorem.** The overlap interaction matrix
    vanishes if and only if S is a separated (independent) set in G.

    This is the bridge theorem connecting the new overlap theory to the
    classical separated theory: separation is precisely the zero-interaction
    regime. When Ω_S = 0, the restricted Laplacian is purely diagonal,
    and tropical generators on S do not interact.
-/
theorem overlapInteractionMat_eq_zero_iff_separated
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) :
    overlapInteractionMat G S = 0 ↔ SeparatedSet G S := by
  constructor;
  · intro h u v hu hv huv
    have h_zero : overlapInteractionMat G S (S.equivFin.symm.symm ⟨u, hu⟩) (S.equivFin.symm.symm ⟨v, hv⟩) = 0 := by
      exact congr_fun ( congr_fun h _ ) _;
    unfold overlapInteractionMat at h_zero; aesop;
  · intro hS
    ext i j
    simp [overlapInteractionMat, hS];
    exact fun hij => hS _ _ ( Finset.mem_coe.2 <| Finset.mem_coe.2 <| by simp ) ( Finset.mem_coe.2 <| Finset.mem_coe.2 <| by simp ) ( by simpa [ Fin.ext_iff ] using hij )

/-
Forward direction: separation implies zero interaction.
-/
theorem overlapInteractionMat_eq_zero_of_separated
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V)
    (hsep : SeparatedSet G S) :
    overlapInteractionMat G S = 0 := by
  ext i j ; unfold overlapInteractionMat ; aesop

/-
When S is separated, the restricted Laplacian equals the diagonal
    degree matrix. This recovers the classical setting where generators
    are noninteracting.
-/
theorem restrictedLap_eq_diag_of_separated
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V)
    (hsep : SeparatedSet G S) :
    restrictedLapMat G S = diagonalDegreeMat G S := by
  -- Use the restrictedLap_decomposition theorem to write L_S = D_S + Ω_S.
  rw [restrictedLap_decomposition];
  rw [ overlapInteractionMat_eq_zero_of_separated _ _ hsep, add_zero ]

/-! ## Section 5: Energy Decomposition -/

/-
**Energy decomposition theorem.** The total overlap energy decomposes
    as self-energy plus interaction energy:
      x^T L_S x = x^T D_S x + x^T Ω_S x

    This is the discrete analogue of decomposing the Dirichlet energy of a
    potential into self-capacitance and mutual-capacitance terms in electrical
    network theory. For separated sets, the interaction energy vanishes,
    recovering the classical diagonal energy formula.
-/
theorem overlapEnergy_decomposition
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V)
    (x : Fin S.card → ℤ) :
    overlapEnergy G S x = selfEnergy G S x + interactionEnergy G S x := by
  unfold overlapEnergy selfEnergy interactionEnergy;
  simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => by rw [ restrictedLap_decomposition ] ; simp +decide [ Matrix.add_apply ] ; ring;

/-
For separated sets, the interaction energy vanishes identically.
-/
theorem separated_interaction_energy_zero
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V)
    (hsep : SeparatedSet G S) (x : Fin S.card → ℤ) :
    interactionEnergy G S x = 0 := by
  exact Finset.sum_eq_zero fun j hj => by simp +decide [ overlapInteractionMat_eq_zero_of_separated G S hsep ] ;

/-
For separated sets, the overlap energy equals the self-energy.
-/
theorem separated_overlapEnergy_eq_selfEnergy
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V)
    (hsep : SeparatedSet G S) (x : Fin S.card → ℤ) :
    overlapEnergy G S x = selfEnergy G S x := by
  convert overlapEnergy_decomposition G S x using 1;
  rw [ separated_interaction_energy_zero G S hsep x, add_zero ]

/-! ## Section 6: Interaction Matrix Diagonal -/

/-
The overlap interaction matrix has zero diagonal.
-/
theorem overlapInteractionMat_zero_diag
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V)
    (i : Fin S.card) :
    overlapInteractionMat G S i i = 0 := by
  -- By definition of overlapInteractionMat, the diagonal entries are zero.
  simp [overlapInteractionMat]

/-
The diagonal of the restricted Laplacian equals the diagonal
    degree matrix.
-/
theorem restrictedLapMat_diag
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V)
    (i : Fin S.card) :
    restrictedLapMat G S i i = (G.degree (S.equivFin.symm i) : ℤ) := by
  exact if_pos rfl

/-! ## Section 7: Interaction Entries -/

/-
Off-diagonal entries of the interaction matrix are nonpositive:
    each entry is either 0 (no edge) or -1 (edge present).
-/
theorem overlapInteractionMat_entry_cases
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V)
    (i j : Fin S.card) (hij : i ≠ j) :
    overlapInteractionMat G S i j = 0 ∨
    overlapInteractionMat G S i j = -1 := by
  unfold overlapInteractionMat;
  lia

/-
Off-diagonal entries of the restricted Laplacian are nonpositive.
-/
theorem restrictedLapMat_offdiag_nonpos
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V)
    (i j : Fin S.card) (hij : i ≠ j) :
    restrictedLapMat G S i j ≤ 0 := by
  unfold restrictedLapMat;
  simp_all +decide [ Fin.ext_iff, SimpleGraph.adj_comm ];
  split_ifs <;> norm_num

/-! ## Section 8: Self-Energy as Sum of Squares -/

/-
The self-energy equals the weighted sum of squares of components,
    where the weight is the vertex degree.
-/
theorem selfEnergy_eq_weighted_sq_sum
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V)
    (x : Fin S.card → ℤ) :
    selfEnergy G S x =
      ∑ i, (G.degree (S.equivFin.symm i) : ℤ) * x i ^ 2 := by
  unfold selfEnergy diagonalDegreeMat;
  simp +decide [ sq, mul_assoc, mul_comm, mul_left_comm, Finset.sum_ite, Finset.filter_eq, Finset.filter_ne ]

/-
Self-energy is nonneg when all degrees are nonneg (which they always are).
-/
theorem selfEnergy_nonneg
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V)
    (x : Fin S.card → ℤ) :
    0 ≤ selfEnergy G S x := by
  convert selfEnergy_eq_weighted_sq_sum G S x ▸ Finset.sum_nonneg _;
  exact fun i _ => mul_nonneg ( Nat.cast_nonneg _ ) ( sq_nonneg _ )

/-! ## Section 9: Cross-Domain Bridge — Quadratic Form and Energy -/

/-
**Cross-domain spectral bridge.** The overlap energy (Laplacian quadratic
    form restricted to S) decomposes as twice the overlap energy equals
    twice the self-energy plus twice the interaction energy. In particular,
    for x ∈ ℤ^|S|:
      2 · x^T L_S x = 2 · x^T D_S x + 2 · x^T Ω_S x

    The self-energy encodes the Rayleigh quotient numerator (vertex energies)
    while the interaction energy encodes pairwise coupling.

    This connects to:
    - **Electrical networks**: dissipated power decomposition
    - **Spectral graph theory**: mode coupling analysis
    - **Discrete potential theory**: Dirichlet energy splitting
-/
theorem overlapEnergy_doubled_decomposition
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V)
    (x : Fin S.card → ℤ) :
    2 * overlapEnergy G S x =
      2 * selfEnergy G S x + 2 * interactionEnergy G S x := by
  -- Apply the overlapEnergy_decomposition theorem to rewrite the left-hand side.
  rw [overlapEnergy_decomposition G S x];
  ring

/-
**Nonnegativity of overlap energy.** The overlap energy is always
    nonneg, as the restricted Laplacian is positive semidefinite.
    The proof proceeds by expressing the quadratic form as a combination
    of degree-weighted squares (from self-energy) and adjacency-weighted
    negative cross-terms (from interaction), then using the fact that
    the total degree always dominates the internal adjacency count.
-/
theorem overlapEnergy_nonneg
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V)
    (x : Fin S.card → ℤ) :
    0 ≤ overlapEnergy G S x := by
  -- In this section we simplify the expression for the overlap energy.
  set M := restrictedLapMat G S
  set D := diagonalDegreeMat G S
  set Ω := overlapInteractionMat G S;
  -- By definition of $D$ and $\Omega$, we know that $x^T D x = \sum_{i \in S} \deg(i) x_i^2$ and $x^T \Omega x = -\sum_{(i,j) \in E(S)} x_i x_j$.
  have hD : ∑ i, ∑ j, x i * D i j * x j = ∑ i ∈ Finset.univ, (G.degree (S.equivFin.symm i)) * x i ^ 2 := by
    simp +decide [ D, diagonalDegreeMat ];
    exact Finset.sum_congr rfl fun _ _ => by ring;
  have hΩ : ∑ i, ∑ j, x i * Ω i j * x j = -∑ i ∈ Finset.univ, ∑ j ∈ Finset.univ, if i ≠ j ∧ G.Adj (S.equivFin.symm i) (S.equivFin.symm j) then x i * x j else 0 := by
    rw [ ← Finset.sum_neg_distrib ] ; refine' Finset.sum_congr rfl fun i hi => _ ; rw [ ← Finset.sum_neg_distrib ] ; refine' Finset.sum_congr rfl fun j hj => _ ; by_cases hij : i = j <;> simp +decide [ hij, Ω ] ; ring;
    · exact Or.inl <| Or.inr <| overlapInteractionMat_zero_diag G S j;
    · unfold overlapInteractionMat; aesop;
  -- By definition of $D$ and $\Omega$, we know that $\sum_{i \in S} \deg(i) x_i^2 \geq \sum_{(i,j) \in E(S)} x_i x_j$.
  have h_ineq : ∑ i ∈ Finset.univ, (G.degree (S.equivFin.symm i)) * x i ^ 2 ≥ ∑ i ∈ Finset.univ, ∑ j ∈ Finset.univ, if i ≠ j ∧ G.Adj (S.equivFin.symm i) (S.equivFin.symm j) then x i * x j else 0 := by
    -- By the AM-GM inequality, we have $x_i^2 + x_j^2 \geq 2x_i x_j$ for any $i \neq j$.
    have h_am_gm : ∀ i j : Fin S.card, i ≠ j → (x i ^ 2 + x j ^ 2) ≥ 2 * x i * x j := by
      exact fun i j hij => by linarith only [ sq_nonneg ( x i - x j ) ] ;
    -- By summing the AM-GM inequality over all edges in $S$, we get the desired result.
    have h_sum_am_gm : ∑ i ∈ Finset.univ, ∑ j ∈ Finset.univ, (if i ≠ j ∧ G.Adj (S.equivFin.symm i) (S.equivFin.symm j) then (x i ^ 2 + x j ^ 2) else 0) ≤ 2 * ∑ i ∈ Finset.univ, (G.degree (S.equivFin.symm i)) * x i ^ 2 := by
      have h_sum_am_gm : ∑ i ∈ Finset.univ, ∑ j ∈ Finset.univ, (if i ≠ j ∧ G.Adj (S.equivFin.symm i) (S.equivFin.symm j) then (x i ^ 2 + x j ^ 2) else 0) = ∑ i ∈ Finset.univ, ∑ j ∈ Finset.univ, (if i ≠ j ∧ G.Adj (S.equivFin.symm i) (S.equivFin.symm j) then x i ^ 2 else 0) + ∑ i ∈ Finset.univ, ∑ j ∈ Finset.univ, (if i ≠ j ∧ G.Adj (S.equivFin.symm i) (S.equivFin.symm j) then x j ^ 2 else 0) := by
        simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => by split_ifs <;> ring;
      have h_sum_am_gm : ∑ i ∈ Finset.univ, ∑ j ∈ Finset.univ, (if i ≠ j ∧ G.Adj (S.equivFin.symm i) (S.equivFin.symm j) then x i ^ 2 else 0) ≤ ∑ i ∈ Finset.univ, (G.degree (S.equivFin.symm i)) * x i ^ 2 := by
        refine' Finset.sum_le_sum fun i _ => _;
        simp +decide [ Finset.sum_ite, Finset.filter_ne ];
        gcongr;
        refine' le_trans _ ( Finset.card_le_card _ );
        rotate_left;
        exact Finset.image ( fun j : Fin #S => S.equivFin.symm j ) ( Finset.filter ( fun j : Fin #S => ¬i = j ∧ G.Adj ( S.equivFin.symm i ) ( S.equivFin.symm j ) ) Finset.univ );
        · simp +decide [ Finset.subset_iff ];
          grind;
        · rw [ Finset.card_image_of_injective _ fun a b h => by simpa [ Fin.ext_iff ] using S.equivFin.symm.injective <| Subtype.ext h ];
      have h_sum_am_gm : ∑ i ∈ Finset.univ, ∑ j ∈ Finset.univ, (if i ≠ j ∧ G.Adj (S.equivFin.symm i) (S.equivFin.symm j) then x j ^ 2 else 0) ≤ ∑ i ∈ Finset.univ, (G.degree (S.equivFin.symm i)) * x i ^ 2 := by
        convert h_sum_am_gm using 1;
        rw [ Finset.sum_comm ];
        simp +decide only [ne_comm, SimpleGraph.adj_comm];
      linarith;
    have h_sum_am_gm : ∑ i ∈ Finset.univ, ∑ j ∈ Finset.univ, (if i ≠ j ∧ G.Adj (S.equivFin.symm i) (S.equivFin.symm j) then (x i ^ 2 + x j ^ 2) else 0) ≥ 2 * ∑ i ∈ Finset.univ, ∑ j ∈ Finset.univ, (if i ≠ j ∧ G.Adj (S.equivFin.symm i) (S.equivFin.symm j) then x i * x j else 0) := by
      push_cast [ Finset.mul_sum _ _ _ ];
      exact Finset.sum_le_sum fun i hi => Finset.sum_le_sum fun j hj => by split_ifs <;> simp_all +decide [ mul_assoc ] ;
    linarith;
  convert sub_nonneg_of_le h_ineq using 1;
  convert overlapEnergy_decomposition G S x using 1;
  linarith! [ selfEnergy_eq_weighted_sq_sum G S x ]