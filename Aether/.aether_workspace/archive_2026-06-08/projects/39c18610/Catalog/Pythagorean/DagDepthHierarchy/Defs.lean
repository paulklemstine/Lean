/-
# DAG Semantics for Inverse-Free EML — Definitions

This file introduces a DAG (directed acyclic graph) representation of EML
computations where subexpression sharing is allowed.

## Key Definitions
- `DagOp`: operation labels for DAG nodes
- `EMLDag`: a DAG of EML operations with structural acyclicity
- `EMLDag.eval`: semantic evaluation of a DAG
- `EMLDag.depth`: longest dependency chain (critical path / parallel time)
- `EMLDag.InverseFree`: predicate excluding inversion nodes
- `EMLDag.unfold`: unfolding a DAG into an EML expression tree

## Design
A DAG of `size` nodes uses indices `0 .. size-1`. Each node's operation
references children by ℕ index, with a well-formedness condition ensuring
all references are to strictly earlier nodes. Evaluation and unfolding
proceed by well-founded recursion on the node index.
-/
import Algebra.TightDepthHierarchy.Defs

noncomputable section

open Real EMLExpr

/-! ## DAG Node Operations -/

/-- Operations that a DAG node can perform. Children are referenced by ℕ index. -/
inductive DagOp where
  | var : DagOp
  | const : ℝ → DagOp
  | add : ℕ → ℕ → DagOp
  | mul : ℕ → ℕ → DagOp
  | neg : ℕ → DagOp
  | inv : ℕ → DagOp
  | eml : ℕ → ℕ → DagOp
  deriving Inhabited

namespace DagOp

/-- Whether this operation is inverse-free. -/
def isInverseFree : DagOp → Prop
  | .inv _ => False
  | _ => True

/-- The child indices referenced by this operation. -/
def children : DagOp → List ℕ
  | .var => []
  | .const _ => []
  | .add a b => [a, b]
  | .mul a b => [a, b]
  | .neg a => [a]
  | .inv a => [a]
  | .eml a b => [a, b]

end DagOp

/-! ## EML DAG -/

/-- An EML DAG: a finite sequence of operations with a distinguished output node.
    Well-formedness requires every child reference to point to an earlier node. -/
structure EMLDag where
  /-- Number of nodes in the DAG. -/
  size : ℕ
  /-- Operation at each node. -/
  op : Fin size → DagOp
  /-- The output node. -/
  output : Fin size
  /-- Acyclicity: every child reference at node `i` is strictly less than `i`. -/
  wf : ∀ (i : Fin size), ∀ j ∈ (op i).children, j < i.val

namespace EMLDag

/-- All nodes in the DAG are inverse-free. -/
def InverseFree (G : EMLDag) : Prop :=
  ∀ i : Fin G.size, (G.op i).isInverseFree

/-! ## Semantic Evaluation -/

/-- Evaluate node `k` of the DAG at input `x`.
    Well-founded recursion on `k`. -/
def evalNode (G : EMLDag) (x : ℝ) (k : ℕ) (hk : k < G.size) : ℝ :=
  let getChild : (j : ℕ) → j < k → ℝ := fun j hj =>
    evalNode G x j (Nat.lt_trans hj hk)
  match G.op ⟨k, hk⟩ with
  | .var => x
  | .const c => c
  | .add a b =>
    (if ha : a < k then getChild a ha else 0) +
    (if hb : b < k then getChild b hb else 0)
  | .mul a b =>
    (if ha : a < k then getChild a ha else 0) *
    (if hb : b < k then getChild b hb else 0)
  | .neg a => -(if ha : a < k then getChild a ha else 0)
  | .inv a => (if ha : a < k then getChild a ha else 0)⁻¹
  | .eml a b =>
    (if ha : a < k then getChild a ha else 0) *
    exp (if hb : b < k then getChild b hb else 0)
termination_by k

/-- Evaluate the output node of the DAG at input `x`. -/
def eval (G : EMLDag) (x : ℝ) : ℝ :=
  G.evalNode x G.output.val G.output.isLt

/-! ## Unfolding to EMLExpr Tree -/

/-- Unfold node `k` into an `EMLExpr` tree. -/
def unfoldNode (G : EMLDag) (k : ℕ) (hk : k < G.size) : EMLExpr :=
  let getChild : (j : ℕ) → j < k → EMLExpr := fun j hj =>
    unfoldNode G j (Nat.lt_trans hj hk)
  match G.op ⟨k, hk⟩ with
  | .var => EMLExpr.var
  | .const c => EMLExpr.const c
  | .add a b =>
    EMLExpr.add
      (if ha : a < k then getChild a ha else EMLExpr.var)
      (if hb : b < k then getChild b hb else EMLExpr.var)
  | .mul a b =>
    EMLExpr.mul
      (if ha : a < k then getChild a ha else EMLExpr.var)
      (if hb : b < k then getChild b hb else EMLExpr.var)
  | .neg a =>
    EMLExpr.neg (if ha : a < k then getChild a ha else EMLExpr.var)
  | .inv a =>
    EMLExpr.inv (if ha : a < k then getChild a ha else EMLExpr.var)
  | .eml a b =>
    EMLExpr.eml
      (if ha : a < k then getChild a ha else EMLExpr.var)
      (if hb : b < k then getChild b hb else EMLExpr.var)
termination_by k

/-- Unfold the entire DAG to an `EMLExpr` tree at the output node. -/
def unfold (G : EMLDag) : EMLExpr :=
  G.unfoldNode G.output.val G.output.isLt

/-! ## Depth (Critical Path Length) -/

/-- The depth of node `k`: length of the longest dependency chain ending at `k`.
    For `eml` nodes: 1 + max(children). For `add`/`mul`/`neg`: max of children.
    For leaves: 0. -/
def nodeDepth (G : EMLDag) (k : ℕ) (hk : k < G.size) : ℕ :=
  let getChildDepth : (j : ℕ) → j < k → ℕ := fun j hj =>
    nodeDepth G j (Nat.lt_trans hj hk)
  match G.op ⟨k, hk⟩ with
  | .var => 0
  | .const _ => 0
  | .add a b =>
    max (if ha : a < k then getChildDepth a ha else 0)
        (if hb : b < k then getChildDepth b hb else 0)
  | .mul a b =>
    max (if ha : a < k then getChildDepth a ha else 0)
        (if hb : b < k then getChildDepth b hb else 0)
  | .neg a =>
    if ha : a < k then getChildDepth a ha else 0
  | .inv a =>
    if ha : a < k then getChildDepth a ha else 0
  | .eml a b =>
    1 + max (if ha : a < k then getChildDepth a ha else 0)
            (if hb : b < k then getChildDepth b hb else 0)
termination_by k

/-- The depth of the DAG: the depth of its output node.
    This is the critical path length — the minimum parallel time. -/
def depth (G : EMLDag) : ℕ :=
  G.nodeDepth G.output.val G.output.isLt

/-- Sequential depth, equal to `depth`. Named to emphasize the parallel-time
    interpretation as the longest dependency chain. -/
def SequentialDepth (G : EMLDag) : ℕ := G.depth

end EMLDag

end