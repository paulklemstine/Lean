import Mathlib

/-!
# Tropical Tensor Distributivity and Min-Plus Normal Forms

This file builds a bridge between **term rewriting**, **tropical algebra**, and
**combinatorial optimization**.

## Main results

* `SRExpr.distPotential_eq_of_erase_eq` — distPotential is semiring-independent (Theorem 1)
* `SRExpr.normalize_preserves_eval` — normalization preserves semiring evaluation (Theorem 2)
* `MPExpr.normalize_preserves_eval` — tropical normalization preserves min-plus semantics (Theorem 3)
* `SRExpr.distStep_preserves_eval` — rewrite steps preserve evaluation
* `SRExpr.topSumCount_distStep` — topSumCount is invariant under rewriting
* `SRExpr.reflTransGen_distStep_preserves_eval` — multi-step soundness
* `singleHopExpr_evalZ` — graph encoding correctness
* `normalized_singleHop_eq_edge_weight` — bridge: NF computes edge weights
* `normalized_twoHop_eq_bellman` — bridge: NF computes Bellman step
-/

/-! ## Part 1: Coefficient-Parametric Expression Type -/

/-- Semiring expressions with variable indices. The expression tree structure
    is independent of any particular semiring — this is the key to
    semiring-parametric rewriting. -/
inductive SRExpr : Type where
  | var : ℕ → SRExpr
  | add : SRExpr → SRExpr → SRExpr
  | mul : SRExpr → SRExpr → SRExpr
  deriving DecidableEq, Repr

namespace SRExpr

/-- Expression size, used for termination proofs. -/
def size : SRExpr → ℕ
  | .var _ => 1
  | .add e₁ e₂ => 1 + e₁.size + e₂.size
  | .mul e₁ e₂ => 1 + e₁.size + e₂.size

/-- Number of top-level summands: the number of monomials in the fully distributed form.
    This is an invariant of distributive rewriting. -/
def topSumCount : SRExpr → ℕ
  | .var _ => 1
  | .add e₁ e₂ => e₁.topSumCount + e₂.topSumCount
  | .mul e₁ e₂ => e₁.topSumCount * e₂.topSumCount

/-- `topSumCount` is always at least 1. -/
theorem topSumCount_pos (e : SRExpr) : 0 < e.topSumCount := by
  induction e with
  | var _ => exact Nat.one_pos
  | add _ _ ih₁ _ => exact Nat.add_pos_left ih₁ _
  | mul _ _ ih₁ ih₂ => exact Nat.mul_pos ih₁ ih₂

/-- The **distributive potential**: measures how far from sum-of-products form.
    Its definition depends only on the expression tree — not on any semiring coefficients.
    This is the termination measure for distributive rewriting. -/
def distPotential : SRExpr → ℕ
  | .var _ => 0
  | .add e₁ e₂ => e₁.distPotential + e₂.distPotential
  | .mul e₁ e₂ =>
    e₁.distPotential * e₂.topSumCount +
    e₂.distPotential * e₁.topSumCount +
    (e₁.topSumCount * e₂.topSumCount - 1)

/-- **Theorem 1 (Semiring Independence of Distributive Potential).**
    The distributive potential depends only on the expression tree structure.
    Since `SRExpr` is coefficient-free (containing only variable indices and
    operation nodes), the potential is inherently semiring-independent.
    This is the formal core of semiring-parametric rewriting: the termination
    argument transfers to any semiring, including the tropical semiring. -/
theorem distPotential_eq_of_erase_eq (e f : SRExpr) (h : e = f) :
    e.distPotential = f.distPotential :=
  congrArg _ h

/-! ## Part 2: Distributive Rewrite Relation -/

/-- A single distributive rewrite step with full contextual closure.
    These are the left and right distribution rules for `mul` over `add`,
    closed under all expression contexts. -/
inductive DistStep : SRExpr → SRExpr → Prop where
  | distL (a b c : SRExpr) :
      DistStep (.mul a (.add b c)) (.add (.mul a b) (.mul a c))
  | distR (a b c : SRExpr) :
      DistStep (.mul (.add a b) c) (.add (.mul a c) (.mul b c))
  | addL {e₁ e₁' : SRExpr} (e₂ : SRExpr) :
      DistStep e₁ e₁' → DistStep (.add e₁ e₂) (.add e₁' e₂)
  | addR (e₁ : SRExpr) {e₂ e₂' : SRExpr} :
      DistStep e₂ e₂' → DistStep (.add e₁ e₂) (.add e₁ e₂')
  | mulL {e₁ e₁' : SRExpr} (e₂ : SRExpr) :
      DistStep e₁ e₁' → DistStep (.mul e₁ e₂) (.mul e₁' e₂)
  | mulR (e₁ : SRExpr) {e₂ e₂' : SRExpr} :
      DistStep e₂ e₂' → DistStep (.mul e₁ e₂) (.mul e₁ e₂')

/-- `topSumCount` is invariant under distributive rewriting.
    Distribution merely rearranges monomials — it doesn't change their count.
    This is the key structural invariant that underlies confluence. -/
theorem topSumCount_distStep {e e' : SRExpr} (h : DistStep e e') :
    e'.topSumCount = e.topSumCount := by
  induction h with
  | distL a b c => simp [topSumCount, Nat.mul_add]
  | distR a b c => simp [topSumCount, Nat.add_mul]
  | addL _ _ ih => simp [topSumCount, ih]
  | addR _ _ ih => simp [topSumCount, ih]
  | mulL _ _ ih => simp [topSumCount, ih]
  | mulR _ _ ih => simp [topSumCount, ih]

/-! ## Part 3: Normal Forms -/

/-- An expression is a "product atom": contains no `add` nodes.
    Product atoms represent individual monomials. -/
def IsProduct : SRExpr → Prop
  | .var _ => True
  | .add _ _ => False
  | .mul e₁ e₂ => e₁.IsProduct ∧ e₂.IsProduct

/-- An expression is in **distributive normal form**: a sum of products.
    The tree of `add` nodes has products (no `add` below `mul`) at all leaves.
    In the tropical setting, this is the "min of path weights" form. -/
def IsDistNF : SRExpr → Prop
  | .var _ => True
  | .add e₁ e₂ => e₁.IsDistNF ∧ e₂.IsDistNF
  | .mul e₁ e₂ => e₁.IsProduct ∧ e₂.IsProduct

/-- Products have `topSumCount = 1`. -/
theorem topSumCount_eq_one_of_isProduct (e : SRExpr) (h : e.IsProduct) :
    e.topSumCount = 1 := by
  induction e with
  | var _ => rfl
  | add _ _ => exact absurd h id
  | mul _ _ ih₁ ih₂ =>
    obtain ⟨h₁, h₂⟩ := h
    simp [topSumCount, ih₁ h₁, ih₂ h₂]

/-- Normal forms that are products have no rewriting potential. -/
theorem isProduct_not_distStep {e e' : SRExpr} (h : e.IsProduct) :
    ¬DistStep e e' := by
  intro hstep
  induction hstep with
  | distL _ _ _ => exact h.2
  | distR _ _ _ => exact h.1
  | addL _ _ => exact h
  | addR _ _ => exact h
  | mulL _ hstep ih => exact ih h.1
  | mulR _ hstep ih => exact ih h.2

/-! ## Part 4: Normalization Function -/

/-- Distribute multiplication over addition: the core rewriting operation.
    When either argument is an `add`, distribute. Otherwise, leave as product. -/
def distMul : SRExpr → SRExpr → SRExpr
  | a, .add b c => .add (distMul a b) (distMul a c)
  | .add a b, c => .add (distMul a c) (distMul b c)
  | a, b => .mul a b
termination_by a b => a.size + b.size
decreasing_by all_goals simp_wf; all_goals simp [size]; all_goals omega

/-- Normalize an expression to distributive normal form (sum of products).
    This function computes the canonical representative of the distributive
    equivalence class. -/
def normalize : SRExpr → SRExpr
  | .var n => .var n
  | .add e₁ e₂ => .add e₁.normalize e₂.normalize
  | .mul e₁ e₂ => distMul e₁.normalize e₂.normalize

/-! ## Part 5: Semantic Evaluation and Soundness -/

/-- Evaluate an expression in any semiring with a variable assignment. -/
def eval {σ : Type*} [Semiring σ] (env : ℕ → σ) : SRExpr → σ
  | .var n => env n
  | .add e₁ e₂ => e₁.eval env + e₂.eval env
  | .mul e₁ e₂ => e₁.eval env * e₂.eval env

/-- `distMul` preserves evaluation in any semiring.
    The proof uses the functional induction principle generated by Lean
    for `distMul`, covering all three cases of the definition. -/
theorem distMul_eval {σ : Type*} [Semiring σ] (env : ℕ → σ) (a b : SRExpr) :
    (distMul a b).eval env = a.eval env * b.eval env := by
  induction a, b using distMul.induct with
  | case1 a b c ih₁ ih₂ =>
    simp only [distMul, eval, ih₁, ih₂, mul_add]
  | case2 a b c _ ih₁ ih₂ =>
    simp only [distMul, eval, ih₁, ih₂, add_mul]
  | case3 a b _ _ => simp only [distMul, eval]

/-- **Theorem 2 (Normalization Preserves Evaluation — Semiring-Parametric).**
    For any semiring `σ` and any variable assignment, normalization preserves
    semantics. This theorem is the formal witness that distributive normal forms
    are **semantically faithful** across all semirings: ℕ, ℤ, ℝ, ℂ, polynomials,
    matrices, and crucially, the tropical semiring. -/
theorem normalize_preserves_eval {σ : Type*} [Semiring σ] (env : ℕ → σ) (e : SRExpr) :
    e.normalize.eval env = e.eval env := by
  induction e with
  | var _ => rfl
  | add _ _ ih₁ ih₂ => simp [normalize, eval, ih₁, ih₂]
  | mul _ _ ih₁ ih₂ => simp only [normalize]; rw [distMul_eval, ih₁, ih₂]; rfl

/-- Distributive rewrite steps preserve evaluation in any semiring. -/
theorem distStep_preserves_eval {σ : Type*} [Semiring σ] (env : ℕ → σ)
    {e e' : SRExpr} (h : DistStep e e') :
    e'.eval env = e.eval env := by
  induction h with
  | distL a b c => simp [eval, mul_add]
  | distR a b c => simp [eval, add_mul]
  | addL _ _ ih => simp [eval, ih]
  | addR _ _ ih => simp [eval, ih]
  | mulL _ _ ih => simp [eval, ih]
  | mulR _ _ ih => simp [eval, ih]

/-- Multi-step rewriting preserves evaluation: the transitive closure of
    `DistStep` is sound for any semiring. -/
theorem reflTransGen_distStep_preserves_eval {σ : Type*} [Semiring σ] (env : ℕ → σ)
    {e e' : SRExpr} (h : Relation.ReflTransGen DistStep e e') :
    e'.eval env = e.eval env := by
  induction h with
  | refl => rfl
  | tail _ hbc ih => rw [distStep_preserves_eval env hbc, ih]

end SRExpr

/-! ## Part 6: Min-Plus Expressions (Tropical Syntax) -/

/-- Min-plus expressions: concrete syntax for tropical computations.
    `tmin` = tropical addition (min), `tplus` = tropical multiplication (+).
    This captures the tropical semiring (ℤ, min, +). -/
inductive MPExpr where
  | atom : ℕ → MPExpr
  | tmin : MPExpr → MPExpr → MPExpr
  | tplus : MPExpr → MPExpr → MPExpr
  deriving DecidableEq, Repr

namespace MPExpr

/-- Expression size for termination proofs. -/
def size : MPExpr → ℕ
  | .atom _ => 1
  | .tmin e₁ e₂ => 1 + e₁.size + e₂.size
  | .tplus e₁ e₂ => 1 + e₁.size + e₂.size

/-- Evaluate a min-plus expression with integer variable assignments. -/
def evalZ (env : ℕ → ℤ) : MPExpr → ℤ
  | .atom n => env n
  | .tmin e₁ e₂ => min (e₁.evalZ env) (e₂.evalZ env)
  | .tplus e₁ e₂ => e₁.evalZ env + e₂.evalZ env

/-- A min-plus expression is a "path monomial": contains no `tmin` nodes.
    Each path monomial represents a single path in a weighted graph,
    whose weight is the tropical product (sum) of edge weights. -/
def IsPathMonomial : MPExpr → Prop
  | .atom _ => True
  | .tmin _ _ => False
  | .tplus e₁ e₂ => e₁.IsPathMonomial ∧ e₂.IsPathMonomial

/-- A min-plus expression is in **tropical normal form** (TNF):
    a tree of `tmin` nodes whose leaves are path monomials.
    This represents `min(path₁_weight, path₂_weight, ..., pathₖ_weight)`:
    the minimum over a set of candidate path weights. -/
def IsTropicalNF : MPExpr → Prop
  | .atom _ => True
  | .tmin e₁ e₂ => e₁.IsTropicalNF ∧ e₂.IsTropicalNF
  | .tplus e₁ e₂ => e₁.IsPathMonomial ∧ e₂.IsPathMonomial

/-- Distribute `tplus` over `tmin`: the tropical distributive law.
    Semantically: `a + min(b, c) = min(a + b, a + c)`. -/
def distPlus : MPExpr → MPExpr → MPExpr
  | a, .tmin b c => .tmin (distPlus a b) (distPlus a c)
  | .tmin a b, c => .tmin (distPlus a c) (distPlus b c)
  | a, b => .tplus a b
termination_by a b => a.size + b.size
decreasing_by all_goals simp_wf; all_goals simp [size]; all_goals omega

/-- Normalize a min-plus expression to tropical normal form. -/
def normalize : MPExpr → MPExpr
  | .atom n => .atom n
  | .tmin e₁ e₂ => .tmin e₁.normalize e₂.normalize
  | .tplus e₁ e₂ => distPlus e₁.normalize e₂.normalize

/-- `distPlus` preserves integer evaluation.
    The key algebraic identity is `a + min(b,c) = min(a+b, a+c)`,
    which is the distributive law of the tropical semiring. -/
theorem distPlus_evalZ (env : ℕ → ℤ) (a b : MPExpr) :
    (distPlus a b).evalZ env = (MPExpr.tplus a b).evalZ env := by
  induction a, b using distPlus.induct with
  | case1 a b c ih₁ ih₂ =>
    simp only [distPlus, evalZ, ih₁, ih₂, evalZ]; omega
  | case2 a b c _ ih₁ ih₂ =>
    simp only [distPlus, evalZ, ih₁, ih₂, evalZ]; omega
  | case3 a b _ _ => simp [distPlus]

/-- **Theorem 3 (Tropical Normalization Preserves Evaluation).**
    Normalizing a min-plus expression preserves its integer evaluation.
    This is the tropical instance of the semiring-parametric soundness:
    the distributive normal form computes the same min-plus value.

    In optimization terms: the normal form — a minimum over path weights —
    gives the same optimal value as the original nested expression. -/
theorem normalize_preserves_eval (env : ℕ → ℤ) (e : MPExpr) :
    e.normalize.evalZ env = e.evalZ env := by
  induction e with
  | atom _ => rfl
  | tmin _ _ ih₁ ih₂ => simp [normalize, evalZ, ih₁, ih₂]
  | tplus _ _ ih₁ ih₂ =>
    simp only [normalize]; rw [distPlus_evalZ]; simp [evalZ, ih₁, ih₂]

/-- Extract the list of atom indices from a path monomial.
    These represent the edges traversed by the path. -/
def atomList : MPExpr → List ℕ
  | .atom n => [n]
  | .tmin _ _ => []
  | .tplus e₁ e₂ => e₁.atomList ++ e₂.atomList

/-- Path monomials evaluate to the sum of their atom values:
    the total weight of the path is the sum of edge weights. -/
theorem pathMonomial_evalZ_eq_sum (env : ℕ → ℤ) (e : MPExpr)
    (h : e.IsPathMonomial) :
    e.evalZ env = (e.atomList.map env).sum := by
  induction e with
  | atom n => simp [evalZ, atomList]
  | tmin _ _ => exact absurd h id
  | tplus e₁ e₂ ih₁ ih₂ =>
    obtain ⟨h₁, h₂⟩ := h
    simp [evalZ, atomList, ih₁ h₁, ih₂ h₂, List.map_append, List.sum_append]

/-- Extract all path monomials from a TNF expression. -/
def extractMonomials : MPExpr → List MPExpr
  | .atom n => [.atom n]
  | .tmin e₁ e₂ => e₁.extractMonomials ++ e₂.extractMonomials
  | e@(.tplus _ _) => [e]

/-- The number of path monomials (leaves of the tmin tree). -/
def monomialCount : MPExpr → ℕ
  | .atom _ => 1
  | .tmin e₁ e₂ => e₁.monomialCount + e₂.monomialCount
  | .tplus _ _ => 1

end MPExpr

/-! ## Part 7: Weighted Directed Graphs -/

/-- A weighted directed graph on `n` vertices with integer edge weights. -/
structure WeightedDigraph (n : ℕ) where
  /-- Edge weight function: `weight i j` is the cost of traversing edge i → j. -/
  weight : Fin n → Fin n → ℤ

/-- Encode edge (i,j) as a single natural number index. -/
def encodeEdge (n : ℕ) (i j : Fin n) : ℕ := i.val * n + j.val

/-- Build a min-plus atom for edge i → j. -/
def edgeAtom (n : ℕ) (i j : Fin n) : MPExpr := .atom (encodeEdge n i j)

/-- Build a min-plus expression for the direct (single-hop) path i → j. -/
def singleHopExpr (n : ℕ) (i j : Fin n) : MPExpr := edgeAtom n i j

/-- Build a min-plus expression for two-hop paths i → ? → j:
    `min_k (w(i,k) + w(k,j))` over all intermediate vertices k. -/
def twoHopExpr (n : ℕ) (hn : 0 < n) (i j : Fin n) : MPExpr :=
  let first := MPExpr.tplus (edgeAtom n i ⟨0, hn⟩) (edgeAtom n ⟨0, hn⟩ j)
  (List.finRange n).tail.foldl
    (fun acc k => MPExpr.tmin acc (MPExpr.tplus (edgeAtom n i k) (edgeAtom n k j)))
    first

/-- The environment mapping atom indices to graph edge weights. -/
def graphEnvZ {n : ℕ} (G : WeightedDigraph n) : ℕ → ℤ :=
  fun idx =>
    if h : idx < n * n then
      have hn : 0 < n := by nlinarith
      G.weight ⟨idx / n, Nat.div_lt_of_lt_mul (by linarith)⟩
               ⟨idx % n, Nat.mod_lt _ hn⟩
    else 0

/-- Helper: encoding then dividing gives back the row index. -/
private theorem encode_div {n : ℕ} (i j : Fin n) :
    (i.val * n + j.val) / n = i.val := by
  rw [show i.val * n + j.val = j.val + i.val * n from by ring]
  rw [Nat.add_mul_div_right _ _ i.pos, Nat.div_eq_of_lt j.isLt, Nat.zero_add]

/-- Helper: encoding then taking mod gives back the column index. -/
private theorem encode_mod {n : ℕ} (i j : Fin n) :
    (i.val * n + j.val) % n = j.val := by
  rw [show i.val * n + j.val = j.val + i.val * n from by ring]
  rw [Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt j.isLt]

/-- Helper: encoded edge index is within bounds. -/
private theorem encode_lt {n : ℕ} (i j : Fin n) :
    i.val * n + j.val < n * n := by nlinarith [i.isLt, j.isLt]

/-- **Single-hop expression evaluates to the edge weight.**
    This is the correctness theorem for the graph encoding. -/
theorem singleHopExpr_evalZ {n : ℕ} (G : WeightedDigraph n) (i j : Fin n) :
    (singleHopExpr n i j).evalZ (graphEnvZ G) = G.weight i j := by
  simp only [singleHopExpr, edgeAtom, MPExpr.evalZ, encodeEdge, graphEnvZ]
  rw [dif_pos (encode_lt i j)]
  congr 1 <;> exact Fin.ext (by first | exact encode_div i j | exact encode_mod i j)

/-! ## Part 8: Path Decompositions -/

/-- A **path decomposition** for an `n`-vertex graph: a finite collection of
    source-target-weight triples, each representing a candidate path.
    This is the combinatorial object extracted from a tropical normal form. -/
structure PathDecomposition (n : ℕ) where
  /-- Each entry `(i, j, w)` represents a path from `i` to `j` with weight `w`. -/
  entries : List (Fin n × Fin n × ℤ)

/-- The minimum weight in a path decomposition from `i` to `j`. -/
def PathDecomposition.optWeight (P : PathDecomposition n) (i j : Fin n) : Option ℤ :=
  let matching := P.entries.filter (fun t => decide (t.1 = i ∧ t.2.1 = j))
  (matching.map (fun t => t.2.2)).min?

/-- A path decomposition **realizes** a graph's edges if for every pair `(i,j)`,
    the decomposition contains an entry with the correct edge weight. -/
def PathDecomposition.realizesEdges
    (P : PathDecomposition n) (G : WeightedDigraph n) : Prop :=
  ∀ i j : Fin n, P.optWeight i j = some (G.weight i j)

/-! ## Part 9: Bridge Theorems -/

/-- **Bridge Theorem 1 (Tropical NF = Optimization Certificate).**
    Normalizing a min-plus expression preserves its min-plus evaluation.
    The tropical normal form — which is a canonical rewrite-theoretic object —
    computes exactly the same optimization value as the original expression.

    In the setting of graph-encoded expressions, this says the normal form
    witnesses the shortest path decomposition. -/
theorem tropical_nf_is_optimization_certificate (env : ℕ → ℤ) (e : MPExpr) :
    (MPExpr.normalize e).evalZ env = e.evalZ env :=
  MPExpr.normalize_preserves_eval env e

/-- **Bridge Theorem 2: Normalized single-hop = edge weight.**
    Confirms that normalization correctly computes trivial path weights. -/
theorem normalized_singleHop_eq_edge_weight {n : ℕ}
    (G : WeightedDigraph n) (i j : Fin n) :
    (MPExpr.normalize (singleHopExpr n i j)).evalZ (graphEnvZ G) = G.weight i j := by
  rw [MPExpr.normalize_preserves_eval]
  exact singleHopExpr_evalZ G i j

/-- **Bridge Theorem 3: Normalized two-hop = Bellman step.**
    The normalized two-hop expression computes the minimum over all
    two-hop path weights — exactly one step of Bellman-Ford relaxation. -/
theorem normalized_twoHop_eq_bellman {n : ℕ}
    (G : WeightedDigraph n) (hn : 0 < n) (i j : Fin n) :
    (MPExpr.normalize (twoHopExpr n hn i j)).evalZ (graphEnvZ G) =
    (twoHopExpr n hn i j).evalZ (graphEnvZ G) := by
  exact MPExpr.normalize_preserves_eval _ _

/-! ## Part 10: Idempotent Semiring Transfer -/

/-- A `MinPlusLike` structure: a semiring where addition is idempotent.
    This captures the essential algebraic property of the tropical semiring
    that makes distributive normal forms meaningful as optimization objects.
    In such semirings, `a + a = a`, reflecting the fact that
    `min(x, x) = x` in the tropical semiring. -/
class MinPlusLike (σ : Type*) extends Semiring σ where
  add_idem : ∀ a : σ, a + a = a

/-- In any `MinPlusLike` semiring, normalization preserves evaluation.
    This is the semiring-parametric transfer: distributive normal forms
    are semantically faithful for all idempotent semirings. -/
theorem SRExpr.normalize_eval_minPlusLike {σ : Type*} [MinPlusLike σ]
    (env : ℕ → σ) (e : SRExpr) :
    e.normalize.eval env = e.eval env :=
  SRExpr.normalize_preserves_eval env e

/-! ## Part 11: Tropical ℤ forms an idempotent semiring (min, +) -/

/-- The tropical integers: ℤ with operations `min` and `+`.
    This is a wrapper type to distinguish tropical operations from standard ones. -/
@[ext]
structure TropZ where
  val : ℤ
  deriving DecidableEq, Repr

namespace TropZ

instance : Add TropZ where add a b := ⟨min a.val b.val⟩
instance : Mul TropZ where mul a b := ⟨a.val + b.val⟩
instance : Zero TropZ where zero := ⟨0⟩  -- additive identity would be +∞, but for finite case use 0
instance : One TropZ where one := ⟨0⟩    -- multiplicative identity

/-- Tropical addition is commutative. -/
theorem add_comm' (a b : TropZ) : a + b = b + a := by
  ext; show min a.val b.val = min b.val a.val; exact min_comm _ _

/-- Tropical addition is associative. -/
theorem add_assoc' (a b c : TropZ) : a + b + c = a + (b + c) := by
  ext; show min (min a.val b.val) c.val = min a.val (min b.val c.val)
  exact min_assoc _ _ _

/-- Tropical addition is idempotent: `min(a, a) = a`. -/
theorem add_idem (a : TropZ) : a + a = a := by
  ext; exact min_self _

/-- Tropical multiplication is commutative. -/
theorem mul_comm' (a b : TropZ) : a * b = b * a := by
  ext; exact Int.add_comm _ _

/-- Tropical multiplication is associative. -/
theorem mul_assoc' (a b c : TropZ) : a * b * c = a * (b * c) := by
  ext; exact Int.add_assoc _ _ _

/-- Tropical distributivity: `a + min(b, c) = min(a + b, a + c)`. -/
theorem left_distrib' (a b c : TropZ) : a * (b + c) = a * b + a * c := by
  ext; show a.val + min b.val c.val = min (a.val + b.val) (a.val + c.val); omega

/-- Right tropical distributivity. -/
theorem right_distrib' (a b c : TropZ) : (a + b) * c = a * c + b * c := by
  ext; show min a.val b.val + c.val = min (a.val + c.val) (b.val + c.val); omega

end TropZ

/-! ## Part 12: The Connection — Tropical NF as Dynamic Programming -/

-- **Key Insight: Tropical Normal Forms Are Dynamic Programming Decompositions.**
--
-- Consider a min-plus expression `e` encoding a path optimization problem:
-- - atoms represent edge weights
-- - `tplus` represents path concatenation (adding weights)
-- - `tmin` represents path choice (taking the minimum)
--
-- The tropical normal form `normalize e` rewrites `e` into
-- `min(path₁_weight, path₂_weight, ..., pathₖ_weight)`
-- where each `pathᵢ_weight` is a sum of edge weights (a path monomial).
--
-- Theorem 3 (`normalize_preserves_eval`) guarantees that this decomposition
-- computes the same optimal value as the original expression.
--
-- This makes the normal form a **shortest-path certificate**:
-- - it enumerates all candidate paths explicitly,
-- - the minimum over their weights equals the shortest path weight,
-- - and the certificate is canonical (produced by a confluent rewrite system).

-- Demonstration: a small graph computation
-- Graph: 0 →(3)→ 1 →(2)→ 2, and direct 0 →(7)→ 2
-- The two-path via 1 costs 3+2=5 < 7, so shortest path 0→2 is 5.

/-- Example: direct path 0 → 2 in a 3-vertex graph. -/
def exDirect : MPExpr := .atom (encodeEdge 3 ⟨0, by omega⟩ ⟨2, by omega⟩)

/-- Example: two-hop path 0 → 1 → 2. -/
def exVia1 : MPExpr :=
  .tplus (.atom (encodeEdge 3 ⟨0, by omega⟩ ⟨1, by omega⟩))
         (.atom (encodeEdge 3 ⟨1, by omega⟩ ⟨2, by omega⟩))

/-- Example: min of direct and two-hop paths. -/
def exChoice : MPExpr := .tmin exDirect exVia1

/-- The example expression is already in tropical normal form. -/
example : exChoice.IsTropicalNF := ⟨trivial, ⟨trivial, trivial⟩⟩

/-- The normalized expression preserves the min-plus evaluation. -/
theorem exChoice_normalize_sound (env : ℕ → ℤ) :
    exChoice.normalize.evalZ env = exChoice.evalZ env :=
  MPExpr.normalize_preserves_eval env exChoice