import Mathlib

/-!
# Transfer Operators and Partition Functions for Tropical Branching Programs

This file establishes a structural equivalence between min-plus path optimization
in layered tropical branching programs, tropical linear algebra via transfer matrices,
and dynamic programming as operator iteration.

## Main definitions

* `MinPlusBP` — a layered min-plus branching program with `w` nodes per layer and `d` layers
* `MinPlusBP.transferMatrix` — the tropical transfer matrix at layer `i`
* `MinPlusBP.startVec` — the initial state vector (0 at start, ⊤ elsewhere)
* `MinPlusBP.layerState` — the min-cost state vector after `i` layers
* `tropMatMul` — min-plus matrix multiplication
* `tropMulVec` — min-plus matrix-vector multiplication
* `transferProductUpTo` — prefix product of transfer matrices

## Main results

* `layerState_succ` — one-step Bellman recursion for layer states
* `bp_layer_state_eq_transfer_fold` — layer state equals transfer product applied to start vector
* `bp_eval_eq_transfer_matrix_product` — min-cost extraction via transfer product
* `tropMatMul_assoc` — associativity of tropical matrix multiplication
* `circuit_eval_eq_transfer_unroll` — compiled circuit semantics equal transfer operator unrolling

## Mathematical significance

This formalizes the tropical analogue of the transfer-matrix formalism from statistical
mechanics. A depth-`d` branching program with transfer matrices `M₀, …, M_{d-1}` computes
a zero-temperature partition function: the minimum-cost path is the ground-state energy
of a layered system with transfer operators. The compiled tropical circuit is the explicit
time-unrolling of this operator iteration — making branching program evaluation a semiring-valued
evolution law rather than merely a recursive combinational procedure.
-/

noncomputable section

open Finset

/-! ## Tropical (min-plus) matrix and vector operations -/

/-- Min-plus matrix-vector multiplication: `(M ⬝ v)(j) = min_i (v(i) + M(i,j))`.
    This propagates costs from sources through the matrix to targets. -/
def tropMulVec {w : ℕ} (M : Fin w → Fin w → ℕ∞) (v : Fin w → ℕ∞) : Fin w → ℕ∞ :=
  fun j => Finset.inf univ (fun i => v i + M i j)

/-- Min-plus matrix multiplication: `(A * B)(i,j) = min_k (A(i,k) + B(k,j))`. -/
def tropMatMul {w : ℕ} (A B : Fin w → Fin w → ℕ∞) : Fin w → Fin w → ℕ∞ :=
  fun i j => Finset.inf univ (fun k => A i k + B k j)

/-- Tropical identity matrix: 0 on the diagonal, ⊤ elsewhere. -/
def tropIdentity {w : ℕ} : Fin w → Fin w → ℕ∞ :=
  fun i j => if i = j then 0 else ⊤

/-! ## Min-plus branching program -/

/-- A layered min-plus branching program with `w` nodes per layer and `d` layers.
    Edge costs are given by `edgeCost i u v` = cost of edge from node `u` at layer `i`
    to node `v` at layer `i+1`. The value `⊤` indicates no edge exists. -/
structure MinPlusBP (w : ℕ) (d : ℕ) where
  /-- Edge costs: `edgeCost i u v` = cost from node `u` to node `v` at layer `i` -/
  edgeCost : Fin d → Fin w → Fin w → ℕ∞
  /-- Start node at layer 0 -/
  start : Fin w
  /-- Accept node at layer d -/
  accept : Fin w

namespace MinPlusBP

variable {w d : ℕ}

/-- The transfer matrix at layer `i`: this is exactly the edge cost matrix. -/
def transferMatrix (P : MinPlusBP w d) (i : Fin d) : Fin w → Fin w → ℕ∞ :=
  P.edgeCost i

/-- The initial state vector: 0 at the start node, ⊤ elsewhere.
    This represents "we are at the start node with zero cost." -/
def startVec (P : MinPlusBP w d) : Fin w → ℕ∞ :=
  fun v => if v = P.start then 0 else ⊤

/-- The layer state vector: minimum cost to reach each node at layer `i`.
    Defined recursively by Bellman propagation through transfer matrices. -/
def layerState (P : MinPlusBP w d) : (i : ℕ) → i ≤ d → (Fin w → ℕ∞)
  | 0, _ => P.startVec
  | k + 1, h => tropMulVec (P.transferMatrix ⟨k, by omega⟩) (P.layerState k (by omega))

/-- The minimum cost of any accepting path: the cost at the accept node after `d` layers. -/
def minCost (P : MinPlusBP w d) : ℕ∞ :=
  P.layerState d le_rfl P.accept

/-! ## Prefix product of transfer matrices -/

/-- The prefix product of the first `i` transfer matrices.
    `transferProductUpTo P 0` is the tropical identity.
    `transferProductUpTo P (i+1) = transferProductUpTo P i * transferMatrix P i`. -/
def transferProductUpTo (P : MinPlusBP w d) : (i : ℕ) → i ≤ d →
    (Fin w → Fin w → ℕ∞)
  | 0, _ => tropIdentity
  | k + 1, h => tropMatMul (P.transferProductUpTo k (by omega)) (P.transferMatrix ⟨k, by omega⟩)

/-! ## One-step Bellman recursion -/

/-- **One-step Bellman recursion.** The layer state at `k+1` is obtained by
    applying the transfer matrix at layer `k` to the layer state at `k`.
    This is the fundamental dynamic programming equation. -/
theorem layerState_succ (P : MinPlusBP w d) (k : ℕ) (h : k + 1 ≤ d) :
    P.layerState (k + 1) h =
      tropMulVec (P.transferMatrix ⟨k, by omega⟩) (P.layerState k (by omega)) := by
  rfl

/-! ## Key algebraic lemmas for min-plus operations -/

/-- Addition distributes over `Finset.inf` from the left in `ℕ∞`:
    `c + inf_i f(i) = inf_i (c + f(i))` for nonempty finite index sets. -/
theorem ENat.add_finset_inf {ι : Type*} (s : Finset ι) (hs : s.Nonempty)
    (f : ι → ℕ∞) (c : ℕ∞) :
    c + s.inf f = s.inf (fun i => c + f i) := by
  induction' s using Finset.cons_induction with i s hi ih
  · exact False.elim (Finset.not_nonempty_empty hs)
  · by_cases hs : s.Nonempty <;> simp_all +decide [add_min]

/-- Addition distributes over `Finset.inf` from the right in `ℕ∞`. -/
theorem ENat.finset_inf_add {ι : Type*} (s : Finset ι) (hs : s.Nonempty)
    (f : ι → ℕ∞) (c : ℕ∞) :
    s.inf f + c = s.inf (fun i => f i + c) := by
  convert ENat.add_finset_inf s hs (fun i => f i) c using 1
  · exact add_comm _ _
  · simp +decide only [add_comm]

/-
Commutativity of nested `Finset.inf`: swapping the order of minimization.
-/
theorem Finset.inf_comm_of' {α β : Type*} (s : Finset α) (t : Finset β)
    [SemilatticeInf γ] [OrderTop γ] (f : α → β → γ) :
    s.inf (fun a => t.inf (fun b => f a b)) =
    t.inf (fun b => s.inf (fun a => f a b)) := by
  exact Finset.inf_comm s t fun b b_1 => f b b_1

/-- Tropical matrix-vector multiplication is associative:
    `tropMulVec A (tropMulVec B v) = tropMulVec (tropMatMul B A) v`.

    This is the key algebraic identity that makes the transfer product
    formulation equivalent to iterated Bellman propagation. -/
theorem tropMulVec_comp {w : ℕ} (A B : Fin w → Fin w → ℕ∞)
    (v : Fin w → ℕ∞) :
    tropMulVec A (tropMulVec B v) = tropMulVec (tropMatMul B A) v := by
  funext j
  unfold tropMulVec
  have h_assoc : ∀ (i : Fin w), (Finset.univ.inf fun i_1 => v i_1 + B i_1 i) + A i j =
      Finset.univ.inf fun i_1 => v i_1 + (B i_1 i + A i j) := by
    intro i; rw [ENat.finset_inf_add]; simp +decide [add_assoc]
    exact ⟨i, Finset.mem_univ i⟩
  simp +decide only [h_assoc, tropMatMul]
  convert Finset.inf_comm_of' Finset.univ Finset.univ _ using 1
  exact Finset.inf_congr rfl fun _ _ => by
    rw [ENat.add_finset_inf _ (Finset.univ_nonempty_iff.mpr ⟨j⟩)]

/-- The tropical identity matrix is a left identity for `tropMulVec`. -/
theorem tropMulVec_identity {w : ℕ} (v : Fin w → ℕ∞) :
    tropMulVec tropIdentity v = v := by
  unfold tropMulVec tropIdentity
  ext j
  exact le_antisymm
    (Finset.inf_le (Finset.mem_univ j) |> le_trans <| by simp +decide)
    (Finset.le_inf fun i hi => by aesop)

/-- The tropical identity matrix is a left identity for `tropMatMul`. -/
theorem tropMatMul_identity_left {w : ℕ} (M : Fin w → Fin w → ℕ∞) :
    tropMatMul tropIdentity M = M := by
  ext i j; simp +decide [tropMatMul, tropIdentity]
  exact le_antisymm
    (Finset.inf_le (Finset.mem_univ i) |> le_trans <| by aesop)
    (Finset.le_inf fun k hk => by aesop)

/-- The tropical identity matrix is a right identity for `tropMatMul`. -/
theorem tropMatMul_identity_right {w : ℕ} (M : Fin w → Fin w → ℕ∞) :
    tropMatMul M tropIdentity = M := by
  funext i j
  exact le_antisymm
    (Finset.inf_le (Finset.mem_univ j) |> le_trans <| by simp +decide [tropIdentity])
    (Finset.le_inf fun k _ => by by_cases hk : k = j <;> simp +decide [hk, tropIdentity])

/-
**Associativity of tropical matrix multiplication.** This establishes that
    the transfer matrices form a semigroup under min-plus multiplication,
    which is essential for the transfer-operator formalism.
-/
theorem tropMatMul_assoc {w : ℕ} (A B C : Fin w → Fin w → ℕ∞) :
    tropMatMul (tropMatMul A B) C = tropMatMul A (tropMatMul B C) := by
  funext i j; exact (by
  by_cases hw : w = 0;
  · subst hw; fin_cases i;
  · convert Finset.inf_comm_of' ( Finset.univ : Finset ( Fin w ) ) ( Finset.univ : Finset ( Fin w ) ) ( fun k l => A i l + B l k + C k j ) using 1;
    · exact Finset.inf_congr rfl fun _ _ => ENat.finset_inf_add _ ( Finset.univ_nonempty_iff.mpr ⟨ i ⟩ ) _ _;
    · simp +decide [ tropMatMul, add_assoc ] ;
      exact Finset.inf_congr rfl fun _ _ => ENat.add_finset_inf _ ( Finset.univ_nonempty_iff.mpr ⟨ j ⟩ ) _ _)

/-! ## Core semantic theorem: layer state = transfer fold -/

/-- **Core semantic theorem.** The layer state at layer `i` equals the
    transfer product of the first `i` matrices applied to the start vector.

    This is the induction invariant that makes the transfer-operator
    semantics canonical. It says that iterated Bellman propagation is
    exactly tropical matrix product applied to the initial state. -/
theorem bp_layer_state_eq_transfer_fold
    (P : MinPlusBP w d) :
    ∀ i (hi : i ≤ d),
      P.layerState i hi =
        tropMulVec (P.transferProductUpTo i hi) P.startVec := by
  intro i
  induction' i with i ih
  · intro hi
    simp [MinPlusBP.layerState]
    exact Eq.symm (tropMulVec_identity _)
  · intro hi
    rw [show P.layerState (i + 1) hi =
        tropMulVec (P.transferMatrix ⟨i, by linarith⟩) (P.layerState i (by linarith)) from rfl]
    rw [ih (by linarith)]
    convert tropMulVec_comp _ _ _ using 2

/-! ## Endpoint extraction / min-cost theorem -/

/-- **Min-cost extraction theorem.** The minimum cost of any accepting path
    equals the accept-node entry of the transfer product applied to the
    start vector. This is the zero-temperature partition function. -/
theorem bp_eval_eq_transfer_matrix_product
    (P : MinPlusBP w d) :
    P.minCost =
      tropMulVec (P.transferProductUpTo d le_rfl) P.startVec P.accept := by
  unfold minCost
  rw [bp_layer_state_eq_transfer_fold]

/-! ## Circuit unrolling as transfer operator iteration -/

/-- The unrolled transfer operator evaluation: this is the semantic value
    obtained by iterating the transfer matrices on the start vector.
    It is definitionally equal to the layer state at depth `d`. -/
def evalUnrolledTransfer (P : MinPlusBP w d) : ℕ∞ :=
  P.layerState d le_rfl P.accept

/-- **Circuit-transfer equivalence.** The unrolled iterative computation equals
    the transfer product applied to the start vector.

    This identifies the dynamic-programming iteration (layer-by-layer Bellman
    propagation) with the single transfer-product computation. The former is
    the "circuit" view (explicit time steps); the latter is the "algebraic" view
    (matrix product). Their equivalence is the semantic circuit theorem. -/
theorem circuit_eval_eq_transfer_unroll
    (P : MinPlusBP w d) :
    evalUnrolledTransfer P =
      tropMulVec (P.transferProductUpTo d le_rfl) P.startVec P.accept := by
  unfold evalUnrolledTransfer
  rw [bp_layer_state_eq_transfer_fold]

/-- **Circuit-BP equivalence.** The unrolled transfer computation evaluates
    to the same value as the branching program's minimum cost. -/
theorem circuit_eval_eq_minCost
    (P : MinPlusBP w d) :
    evalUnrolledTransfer P = P.minCost := by
  rfl

/-! ## Path formalization -/

/-- A path through a min-plus branching program: a sequence of nodes,
    one per layer (0 through d), connected by edges. -/
structure Path (P : MinPlusBP w d) where
  /-- Node visited at each layer (from 0 to d) -/
  nodes : Fin (d + 1) → Fin w
  /-- Consecutive nodes are connected by finite-cost edges -/
  connected : ∀ (i : Fin d),
    P.edgeCost i (nodes i.castSucc) (nodes i.succ) ≠ ⊤

/-- A path from the start node to a specific target node at layer `d`. -/
structure PathTo (P : MinPlusBP w d) (target : Fin w) extends Path P where
  /-- Path starts at the start node -/
  startsAtStart : nodes 0 = P.start
  /-- Path ends at the target node -/
  endsAtTarget : nodes ⟨d, Nat.lt_succ_self d⟩ = target

/-- The cost of a path: sum of all edge costs along the path. -/
def Path.cost {P : MinPlusBP w d} (p : Path P) : ℕ∞ :=
  ∑ i : Fin d, P.edgeCost i (p.nodes i.castSucc) (p.nodes i.succ)

/-- An accepting path: starts at start, ends at accept. -/
abbrev AcceptingPath (P : MinPlusBP w d) := PathTo P P.accept

/-! ## Transfer product as monoid structure -/

/-- The collection of all `w × w` tropical matrices forms a monoid under
    min-plus multiplication, with the tropical identity as the unit. -/
theorem tropMatMul_one_left {w : ℕ} (M : Fin w → Fin w → ℕ∞) :
    tropMatMul tropIdentity M = M :=
  tropMatMul_identity_left M

theorem tropMatMul_one_right {w : ℕ} (M : Fin w → Fin w → ℕ∞) :
    tropMatMul M tropIdentity = M :=
  tropMatMul_identity_right M

/-! ## Composition of transfer products -/

/-- Transfer product at step 0 is the identity. -/
theorem transferProductUpTo_zero (P : MinPlusBP w d) (h : 0 ≤ d) :
    P.transferProductUpTo 0 h = tropIdentity := rfl

/-- Transfer product at step k+1 multiplies by the next transfer matrix. -/
theorem transferProductUpTo_succ (P : MinPlusBP w d) (k : ℕ) (h : k + 1 ≤ d) :
    P.transferProductUpTo (k + 1) h =
      tropMatMul (P.transferProductUpTo k (by omega))
        (P.transferMatrix ⟨k, by omega⟩) := rfl

end MinPlusBP

end