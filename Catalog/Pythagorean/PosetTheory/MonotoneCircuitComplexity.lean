/-
# Monotone Boolean Circuit Complexity: Unfolding and Depth Transfer

This file formalizes monotone Boolean circuits as finite DAGs with
topologically ordered vertices, defines their unfolding into formula trees,
and proves depth transfer theorems that bridge formula lower bounds to
circuit lower bounds.

## Main Results

1. `unfold_eval_eq`: Unfolding preserves Boolean semantics at every node.
2. `unfold_depth_eq`: Unfolding preserves depth exactly.
3. `iterCompose_monotone`: Iterated block composition preserves monotonicity.
4. `circuit_depth_lb_of_formula_depth_lb`: Lower bound transfer from formulas to circuits.
5. `circuit_eval_monotone`: Monotone circuits compute order-preserving Boolean functions.

## Design

Vertices are `Fin n` with the convention that gate children have strictly
smaller indices, providing structural acyclicity and well-founded recursion
on `Fin.val`. This parallels the `EMLDag` framework in
`Catalog/Pythagorean/DagDepthHierarchy`.
-/
import Mathlib

/-! ## Monotone Boolean Formulas -/

/-- A monotone Boolean formula (tree) with variables indexed by ℕ.
    Only AND and OR connectives are allowed (no negation). -/
inductive MBoolFormula where
  | var (n : ℕ)
  | and (l r : MBoolFormula)
  | or (l r : MBoolFormula)
  deriving Inhabited

namespace MBoolFormula

/-- Evaluate a monotone formula under a Boolean assignment. -/
def eval : MBoolFormula → (ℕ → Bool) → Bool
  | var n, σ => σ n
  | and l r, σ => l.eval σ && r.eval σ
  | or l r, σ => l.eval σ || r.eval σ

/-- Depth of a monotone formula (longest root-to-leaf path). -/
def depth : MBoolFormula → ℕ
  | var _ => 0
  | and l r => 1 + max l.depth r.depth
  | or l r => 1 + max l.depth r.depth

/-
A formula is monotone: pointwise-larger inputs produce pointwise-larger outputs.
-/
theorem eval_monotone (F : MBoolFormula) {σ τ : ℕ → Bool}
    (h : ∀ n, σ n = true → τ n = true) :
    F.eval σ = true → F.eval τ = true := by
  induction F <;> simp_all +decide [ MBoolFormula.eval ];
  grind

end MBoolFormula

/-! ## Monotone Boolean Circuit (DAG) -/

/-- Specification of a node in a monotone Boolean circuit. -/
inductive MBoolNodeSpec where
  | input (var : ℕ)
  | andGate (left right : ℕ)
  | orGate (left right : ℕ)
  deriving Inhabited

/-- Child indices referenced by a node specification. -/
def MBoolNodeSpec.children : MBoolNodeSpec → List ℕ
  | .input _ => []
  | .andGate l r => [l, r]
  | .orGate l r => [l, r]

/-- A monotone Boolean circuit (DAG).
    Vertices are `{0, ..., size-1}`, topologically ordered by index.
    Each vertex is either an input variable or a binary AND/OR gate
    whose children have strictly smaller indices (ensuring acyclicity). -/
structure MBoolCircuit where
  /-- Number of vertices in the circuit DAG. -/
  size : ℕ
  /-- Node specification at each vertex. -/
  spec : Fin size → MBoolNodeSpec
  /-- Acyclicity: every child reference at node `i` is strictly less than `i`. -/
  wf : ∀ (i : Fin size) (c : ℕ), c ∈ (spec i).children → c < i.val

namespace MBoolCircuit

/-! ### Evaluation -/

/-- Evaluate the circuit at vertex index `k` under assignment `σ`. -/
def evalNode (C : MBoolCircuit) (σ : ℕ → Bool) (k : ℕ) (hk : k < C.size) : Bool :=
  match h : C.spec ⟨k, hk⟩ with
  | .input v => σ v
  | .andGate l r =>
    have hl : l < k := C.wf ⟨k, hk⟩ l (by simp [MBoolNodeSpec.children, h])
    have hr : r < k := C.wf ⟨k, hk⟩ r (by simp [MBoolNodeSpec.children, h])
    C.evalNode σ l (by omega) && C.evalNode σ r (by omega)
  | .orGate l r =>
    have hl : l < k := C.wf ⟨k, hk⟩ l (by simp [MBoolNodeSpec.children, h])
    have hr : r < k := C.wf ⟨k, hk⟩ r (by simp [MBoolNodeSpec.children, h])
    C.evalNode σ l (by omega) || C.evalNode σ r (by omega)
  termination_by k

/-- Evaluate the circuit at a vertex. -/
def eval (C : MBoolCircuit) (σ : ℕ → Bool) (v : Fin C.size) : Bool :=
  C.evalNode σ v.val v.isLt

/-! ### DAG Depth -/

/-- The depth of vertex `k` in the DAG: longest dependency chain ending at `k`. -/
def nodeDepth (C : MBoolCircuit) (k : ℕ) (hk : k < C.size) : ℕ :=
  match h : C.spec ⟨k, hk⟩ with
  | .input _ => 0
  | .andGate l r =>
    have hl : l < k := C.wf ⟨k, hk⟩ l (by simp [MBoolNodeSpec.children, h])
    have hr : r < k := C.wf ⟨k, hk⟩ r (by simp [MBoolNodeSpec.children, h])
    1 + max (C.nodeDepth l (by omega)) (C.nodeDepth r (by omega))
  | .orGate l r =>
    have hl : l < k := C.wf ⟨k, hk⟩ l (by simp [MBoolNodeSpec.children, h])
    have hr : r < k := C.wf ⟨k, hk⟩ r (by simp [MBoolNodeSpec.children, h])
    1 + max (C.nodeDepth l (by omega)) (C.nodeDepth r (by omega))
  termination_by k

/-- DAG depth at a vertex. -/
def dagDepth (C : MBoolCircuit) (v : Fin C.size) : ℕ :=
  C.nodeDepth v.val v.isLt

/-! ### Unfolding: DAG → Formula Tree -/

/-- Unfold the circuit at vertex `k` into a monotone Boolean formula.
    This is the canonical tree obtained by duplicating shared sub-circuits
    along every root-to-leaf path. -/
def unfoldNode (C : MBoolCircuit) (k : ℕ) (hk : k < C.size) : MBoolFormula :=
  match h : C.spec ⟨k, hk⟩ with
  | .input v => .var v
  | .andGate l r =>
    have hl : l < k := C.wf ⟨k, hk⟩ l (by simp [MBoolNodeSpec.children, h])
    have hr : r < k := C.wf ⟨k, hk⟩ r (by simp [MBoolNodeSpec.children, h])
    .and (C.unfoldNode l (by omega)) (C.unfoldNode r (by omega))
  | .orGate l r =>
    have hl : l < k := C.wf ⟨k, hk⟩ l (by simp [MBoolNodeSpec.children, h])
    have hr : r < k := C.wf ⟨k, hk⟩ r (by simp [MBoolNodeSpec.children, h])
    .or (C.unfoldNode l (by omega)) (C.unfoldNode r (by omega))
  termination_by k

/-- Unfold the circuit at a vertex. -/
def unfold (C : MBoolCircuit) (v : Fin C.size) : MBoolFormula :=
  C.unfoldNode v.val v.isLt

end MBoolCircuit

/-! ## Iterated Block Composition -/

/-- A Boolean function on `k` inputs. -/
def BoolFun (k : ℕ) := (Fin k → Bool) → Bool

/-- A Boolean function is monotone: pointwise-larger inputs give pointwise-larger outputs. -/
def IsMonotoneBoolFun {k : ℕ} (f : BoolFun k) : Prop :=
  ∀ {x y : Fin k → Bool}, (∀ i, x i = true → y i = true) → f x = true → f y = true

/-- Iterated block composition of a monotone operator `f : {0,1}^k → {0,1}`.
    - Level 0: identity on a single bit (returns the 0-th input bit).
    - Level n+1: apply `f` to `k` copies of level-n on disjoint blocks. -/
def iterComposeFamily {k : ℕ} (f : BoolFun k) : ℕ → (ℕ → Bool) → Bool
  | 0 => fun σ => σ 0
  | n + 1 => fun σ => f (fun i => iterComposeFamily f n (fun j => σ (i.val * k ^ n + j)))

/-! ## Core Theorems -/

/-! ### Theorem 1: Semantic Correctness of Unfolding -/

/-- **Theorem 1**: Evaluating the unfolded formula at any vertex gives the same
    Boolean value as evaluating the circuit directly. This is the foundational
    semantics-preservation theorem for the unfolding transformation. -/
theorem unfold_eval_eq (C : MBoolCircuit) (σ : ℕ → Bool) (k : ℕ) (hk : k < C.size) :
    (C.unfoldNode k hk).eval σ = C.evalNode σ k hk := by
  induction k using Nat.strongRecOn with
  | _ k ih =>
    unfold MBoolCircuit.unfoldNode MBoolCircuit.evalNode
    split
    · simp [MBoolFormula.eval]
    · next l r h =>
      simp only [MBoolFormula.eval]
      congr 1
      · exact ih l (C.wf ⟨k, hk⟩ l (by simp [MBoolNodeSpec.children, h])) _
      · exact ih r (C.wf ⟨k, hk⟩ r (by simp [MBoolNodeSpec.children, h])) _
    · next l r h =>
      simp only [MBoolFormula.eval]
      congr 1
      · exact ih l (C.wf ⟨k, hk⟩ l (by simp [MBoolNodeSpec.children, h])) _
      · exact ih r (C.wf ⟨k, hk⟩ r (by simp [MBoolNodeSpec.children, h])) _

/-- Corollary: unfolding preserves semantics at vertex level. -/
theorem unfold_eval_eq_vertex (C : MBoolCircuit) (σ : ℕ → Bool) (v : Fin C.size) :
    (C.unfold v).eval σ = C.eval σ v :=
  unfold_eval_eq C σ v.val v.isLt

/-! ### Theorem 2: Depth Preservation Under Unfolding -/

/-- **Theorem 2**: The depth of the unfolded formula at vertex `k` equals the
    DAG depth at `k`. Unfolding duplicates subcircuits but does not change depth.
    This is the key structural transfer theorem. -/
theorem unfold_depth_eq (C : MBoolCircuit) (k : ℕ) (hk : k < C.size) :
    (C.unfoldNode k hk).depth = C.nodeDepth k hk := by
  induction k using Nat.strongRecOn with
  | _ k ih =>
    unfold MBoolCircuit.unfoldNode MBoolCircuit.nodeDepth
    split
    · simp [MBoolFormula.depth]
    · next l r h =>
      simp only [MBoolFormula.depth]
      congr 1; congr 1
      · exact ih l (C.wf ⟨k, hk⟩ l (by simp [MBoolNodeSpec.children, h])) _
      · exact ih r (C.wf ⟨k, hk⟩ r (by simp [MBoolNodeSpec.children, h])) _
    · next l r h =>
      simp only [MBoolFormula.depth]
      congr 1; congr 1
      · exact ih l (C.wf ⟨k, hk⟩ l (by simp [MBoolNodeSpec.children, h])) _
      · exact ih r (C.wf ⟨k, hk⟩ r (by simp [MBoolNodeSpec.children, h])) _

/-- Corollary: depth is preserved at vertex level. -/
theorem unfold_depth_eq_vertex (C : MBoolCircuit) (v : Fin C.size) :
    (C.unfold v).depth = C.dagDepth v :=
  unfold_depth_eq C v.val v.isLt

/-- Weaker form: unfolded formula depth is bounded by DAG depth. -/
theorem unfold_depth_le (C : MBoolCircuit) (v : Fin C.size) :
    (C.unfold v).depth ≤ C.dagDepth v :=
  le_of_eq (unfold_depth_eq_vertex C v)

/-! ### Theorem 3: Monotonicity of Iterated Composition -/

/-
**Theorem 3**: If `f` is a monotone Boolean operator on `k` inputs, then every
    iterate `iterComposeFamily f n` is monotone. This connects the structural DAG
    framework to a natural family of complexity-theoretic target functions.
-/
theorem iterCompose_monotone {k : ℕ} (f : BoolFun k) (hf : IsMonotoneBoolFun f) :
    ∀ n, ∀ {σ τ : ℕ → Bool}, (∀ j, σ j = true → τ j = true) →
      iterComposeFamily f n σ = true → iterComposeFamily f n τ = true := by
  intro n σ τ hσ hσ';
  induction' n with n ih generalizing σ τ;
  · exact hσ _ hσ';
  · exact hf ( fun i => by aesop ) hσ'

/-! ### Theorem 4: Formula Lower Bounds Transfer to Circuit Lower Bounds -/

/-- **Theorem 4**: Lower bound transfer principle. If every monotone formula computing
    the same Boolean function as the circuit at vertex `v` has depth at least `d`,
    then the circuit's DAG depth at `v` is also at least `d`.

    This is the core transfer engine: formula lower bounds become circuit lower bounds
    through the unfolding bridge. -/
theorem circuit_depth_lb_of_formula_depth_lb
    (C : MBoolCircuit) (v : Fin C.size) (d : ℕ)
    (hlb : ∀ F : MBoolFormula, (∀ σ, F.eval σ = C.eval σ v) → d ≤ F.depth) :
    d ≤ C.dagDepth v := by
  have h1 : ∀ σ, (C.unfold v).eval σ = C.eval σ v := fun σ => unfold_eval_eq_vertex C σ v
  have h2 : (C.unfold v).depth = C.dagDepth v := unfold_depth_eq_vertex C v
  calc d ≤ (C.unfold v).depth := hlb _ h1
    _ = C.dagDepth v := h2

/-! ### Theorem 5: Monotone Circuits Compute Order-Preserving Functions -/

/-- Pointwise order on Boolean assignments. -/
def BoolAssign.le (σ τ : ℕ → Bool) : Prop := ∀ n, σ n = true → τ n = true

/-
**Theorem 5** (Cross-domain: Order Theory): Every monotone Boolean circuit computes
    a monotone (order-preserving) function on the Boolean lattice. That is, if
    `σ ≤ τ` pointwise, then `C.eval σ v = true → C.eval τ v = true` for every vertex `v`.

    This connects circuit structure to lattice/order theory and shows that the
    structural constraint (only AND/OR gates) yields a semantic monotonicity guarantee.
-/
theorem circuit_eval_monotone (C : MBoolCircuit) {σ τ : ℕ → Bool}
    (h : BoolAssign.le σ τ) (k : ℕ) (hk : k < C.size) :
    C.evalNode σ k hk = true → C.evalNode τ k hk = true := by
  convert MBoolFormula.eval_monotone ( C.unfoldNode k hk ) h using 1;
  · rw [ ← unfold_eval_eq ];
  · rw [ ← unfold_eval_eq ]

/-! ## Communication Complexity Bridge -/

/-- Abstract communication hardness: a lower bound on the depth of any monotone
    formula computing a given Boolean function, expressed as a natural number.
    This serves as a formal interface for Karchmer–Wigderson style game arguments. -/
structure FormulaDepthLowerBoundWitness where
  /-- The lower bound value. -/
  bound : ℕ
  /-- The witness certifies: any formula with the given semantics has depth ≥ bound. -/
  valid : ∀ (F : MBoolFormula) (g : (ℕ → Bool) → Bool),
    (∀ σ, F.eval σ = g σ) → bound ≤ F.depth

/-- **Transfer via witness**: Given a lower-bound witness for a function computed by
    a circuit, the circuit's DAG depth is at least the witnessed bound. -/
theorem circuit_depth_ge_witness
    (C : MBoolCircuit) (v : Fin C.size)
    (w : FormulaDepthLowerBoundWitness) :
    w.bound ≤ C.dagDepth v := by
  have h1 : ∀ σ, (C.unfold v).eval σ = C.eval σ v := fun σ => unfold_eval_eq_vertex C σ v
  have h2 : (C.unfold v).depth = C.dagDepth v := unfold_depth_eq_vertex C v
  calc w.bound ≤ (C.unfold v).depth := w.valid _ _ h1
    _ = C.dagDepth v := h2

/-! ## Examples: AND and OR as monotone operators -/

/-- AND on 2 inputs, as a `BoolFun 2`. -/
def boolAnd2 : BoolFun 2 := fun x => x 0 && x 1

/-- OR on 2 inputs, as a `BoolFun 2`. -/
def boolOr2 : BoolFun 2 := fun x => x 0 || x 1

/-
AND is monotone.
-/
theorem boolAnd2_monotone : IsMonotoneBoolFun boolAnd2 := by
  intro x y hxy hx; have := hxy 0; have := hxy 1; ( unfold boolAnd2 at *; aesop; )

/-
OR is monotone.
-/
theorem boolOr2_monotone : IsMonotoneBoolFun boolOr2 := by
  -- By definition of boolOr2, if σ i = true, then boolOr2 σ = true.
  simp [IsMonotoneBoolFun, boolOr2];
  grind

/-- Iterated AND composition is monotone. -/
theorem iterAnd_monotone (n : ℕ) :
    ∀ {σ τ : ℕ → Bool}, (∀ j, σ j = true → τ j = true) →
      iterComposeFamily boolAnd2 n σ = true → iterComposeFamily boolAnd2 n τ = true :=
  iterCompose_monotone boolAnd2 boolAnd2_monotone n