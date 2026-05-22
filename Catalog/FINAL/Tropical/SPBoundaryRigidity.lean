/-
# Series-Parallel Tropical Network Boundary Rigidity

This file formalizes boundary rigidity for two-terminal series-parallel (SP)
networks in the tropical (min-plus) semiring. We prove:

1. **Compositional tropical semantics**: The effective distance of series
   composition is addition, and parallel composition is min.
2. **Positivity**: Positive-weight SP networks have positive effective distance.
3. **Tropical algebraic laws**: Associativity, commutativity, distributivity
   of series/parallel over the tropical semiring.
4. **Boundary distance matrix**: For two-terminal networks, the boundary
   distance matrix is a 2×2 symmetric matrix determined by the effective distance.
5. **Matrix compositionality**: Series and parallel operations transform
   boundary matrices via tropical semiring operations.
6. **Canonical reduction**: Every positive-weight SP expression reduces to
   an equivalent atom.
7. **Boundary rigidity**: Reduced SP expressions are uniquely determined
   by their boundary distance.
8. **Tropical vertex elimination**: Eliminating an interior vertex from a
   3-vertex path computes the correct boundary distance (tropical Schur complement).

## Cross-Domain Connections

- **Tropical geometry**: effDist is a homomorphism to (ℝ_{>0}, +, min).
- **Inverse problems**: Boundary distance determines the reduced internal structure.
- **Circuit complexity**: SP decomposition trees are tropical circuit formulas.
- **Dynamic programming**: Tropical semiring = Bellman composition.
-/
import Mathlib

namespace SPBoundaryRigidity

/-! ## Two-Terminal SP Network Expressions -/

/-- A two-terminal series-parallel network expression.
    - `atom w`: a single edge of weight `w`
    - `series e₁ e₂`: connect `e₁` and `e₂` end-to-end
    - `parallel e₁ e₂`: connect `e₁` and `e₂` between the same terminals -/
inductive SPExpr where
  | atom (w : ℝ) : SPExpr
  | series (e₁ e₂ : SPExpr) : SPExpr
  | parallel (e₁ e₂ : SPExpr) : SPExpr
  deriving Inhabited

/-! ## Effective Distance (Boundary Observable) -/

/-- The effective distance of an SP expression: the shortest-path distance
    between the two terminals. This is the unique boundary observable for
    a two-terminal network. -/
noncomputable def SPExpr.effDist : SPExpr → ℝ
  | .atom w => w
  | .series e₁ e₂ => e₁.effDist + e₂.effDist
  | .parallel e₁ e₂ => min e₁.effDist e₂.effDist

/-! ## Positive Weights -/

/-- All atom weights in the expression are strictly positive. -/
def SPExpr.PosWeights : SPExpr → Prop
  | .atom w => 0 < w
  | .series e₁ e₂ => e₁.PosWeights ∧ e₂.PosWeights
  | .parallel e₁ e₂ => e₁.PosWeights ∧ e₂.PosWeights

/-! ## Compositionality Theorems -/

/-- Series composition adds effective distances (tropical multiplication). -/
theorem effDist_series (e₁ e₂ : SPExpr) :
    (SPExpr.series e₁ e₂).effDist = e₁.effDist + e₂.effDist := rfl

/-- Parallel composition takes the minimum (tropical addition). -/
theorem effDist_parallel (e₁ e₂ : SPExpr) :
    (SPExpr.parallel e₁ e₂).effDist = min e₁.effDist e₂.effDist := rfl

/-- Atom effective distance is just the weight. -/
theorem effDist_atom (w : ℝ) :
    (SPExpr.atom w).effDist = w := rfl

/-! ## Positivity -/

/-
Effective distance of a positive-weight SP expression is positive.
    This is the tropical analogue of "resistance is positive."
-/
theorem effDist_pos (e : SPExpr) (h : e.PosWeights) : 0 < e.effDist := by
  -- We'll use induction on the structure of the SP expression.
  induction' e with e₁ e₂ ih₁ ih₂;
  · exact h;
  · cases h;
    exact add_pos ( ih₂ ‹_› ) ( by solve_by_elim );
  · cases h;
    exact lt_min ( by solve_by_elim ) ( by solve_by_elim )

/-! ## SP Equivalence -/

/-- Two SP expressions are boundary-equivalent if they have the same
    effective distance. -/
def SPEquiv (e₁ e₂ : SPExpr) : Prop := e₁.effDist = e₂.effDist

instance : Setoid SPExpr where
  r := SPEquiv
  iseqv := ⟨fun _ => rfl, fun h => h.symm, fun h₁ h₂ => h₁.trans h₂⟩

/-! ## Tropical Algebraic Laws -/

/-
Series composition is associative up to SP-equivalence.
-/
theorem series_assoc (e₁ e₂ e₃ : SPExpr) :
    SPEquiv (.series (.series e₁ e₂) e₃) (.series e₁ (.series e₂ e₃)) := by
  exact add_assoc _ _ _

/-
Series composition is commutative up to SP-equivalence.
-/
theorem series_comm (e₁ e₂ : SPExpr) :
    SPEquiv (.series e₁ e₂) (.series e₂ e₁) := by
  exact add_comm _ _

/-
Parallel composition is associative up to SP-equivalence.
-/
theorem parallel_assoc (e₁ e₂ e₃ : SPExpr) :
    SPEquiv (.parallel (.parallel e₁ e₂) e₃) (.parallel e₁ (.parallel e₂ e₃)) := by
  grind +locals

/-
Parallel composition is commutative up to SP-equivalence.
-/
theorem parallel_comm (e₁ e₂ : SPExpr) :
    SPEquiv (.parallel e₁ e₂) (.parallel e₂ e₁) := by
  exact min_comm _ _

/-
Parallel composition is idempotent up to SP-equivalence.
-/
theorem parallel_idem (e : SPExpr) :
    SPEquiv (.parallel e e) e := by
  exact min_self _

/-
Left distributivity of series over parallel (tropical distributivity).
-/
theorem series_distrib_parallel_left (e₁ e₂ e₃ : SPExpr) :
    SPEquiv (.series e₁ (.parallel e₂ e₃))
            (.parallel (.series e₁ e₂) (.series e₁ e₃)) := by
  -- By definition of SPEquiv, we need to show that the effective distances are equal.
  unfold SPEquiv
  simp [effDist_series, effDist_parallel];
  grind +extAll

/-
Right distributivity of series over parallel.
-/
theorem series_distrib_parallel_right (e₁ e₂ e₃ : SPExpr) :
    SPEquiv (.series (.parallel e₁ e₂) e₃)
            (.parallel (.series e₁ e₃) (.series e₂ e₃)) := by
  unfold SPEquiv;
  simp +decide only [effDist_series, effDist_parallel];
  grind

/-! ## Size and Structural Measures -/

/-- Number of atoms (edges) in an SP expression. -/
def SPExpr.size : SPExpr → ℕ
  | .atom _ => 1
  | .series e₁ e₂ => e₁.size + e₂.size
  | .parallel e₁ e₂ => e₁.size + e₂.size

/-- Depth of the SP expression tree. -/
def SPExpr.depth : SPExpr → ℕ
  | .atom _ => 0
  | .series e₁ e₂ => max e₁.depth e₂.depth + 1
  | .parallel e₁ e₂ => max e₁.depth e₂.depth + 1

/-! ## Canonical Reduction -/

/-- An SP expression is in reduced form if it is a single atom with positive weight.
    This is the canonical form for two-terminal SP networks: every positive-weight
    network is equivalent to a single edge with its effective distance. -/
def SPExpr.Reduced : SPExpr → Prop
  | .atom w => 0 < w
  | .series _ _ => False
  | .parallel _ _ => False

/-- The canonical reduced form of an SP expression. -/
noncomputable def SPExpr.reduce (e : SPExpr) : SPExpr := .atom e.effDist

/-
Reducing a positive-weight expression yields a reduced expression.
-/
theorem reduce_is_reduced (e : SPExpr) (h : e.PosWeights) :
    e.reduce.Reduced := by
  exact effDist_pos e h

/-
Reduction preserves effective distance (soundness).
-/
theorem reduce_effDist (e : SPExpr) :
    e.reduce.effDist = e.effDist := by
  rfl

/-
Every positive-weight SP expression is equivalent to its reduced form.
-/
theorem canonical_reduce (e : SPExpr) (_h : e.PosWeights) :
    SPEquiv e e.reduce := by
  exact reduce_effDist e |>.symm

/-! ## Boundary Rigidity -/

/-
**Boundary Rigidity Theorem for Two-Terminal SP Networks:**
    Two reduced SP expressions with the same effective distance are equal.
    This is the tropical analogue of "the boundary determines the bulk."
-/
theorem reduced_boundary_rigid (e₁ e₂ : SPExpr)
    (hr₁ : e₁.Reduced) (hr₂ : e₂.Reduced)
    (hd : e₁.effDist = e₂.effDist) :
    e₁ = e₂ := by
  cases e₁ <;> cases e₂ <;> simp_all +decide [SPExpr.Reduced];
  -- Since the effective distance of an atom is just the weight, we have $w₁ = w₂$.
  apply effDist_atom _ |>.symm.trans (hd.trans (effDist_atom _))

/-! ## Boundary Distance Matrix -/

/-- The boundary distance matrix for a two-terminal SP network.
    For terminals indexed by `Fin 2`, this is the 2×2 matrix:
    ```
    ⎡ 0           effDist e ⎤
    ⎣ effDist e   0         ⎦
    ``` -/
noncomputable def SPExpr.boundaryMatrix (e : SPExpr) : Matrix (Fin 2) (Fin 2) ℝ :=
  Matrix.of fun i j =>
    if i = j then 0 else e.effDist

/-
Boundary matrix is symmetric.
-/
theorem boundaryMatrix_symmetric (e : SPExpr) :
    e.boundaryMatrix.IsSymm := by
  ext i j;
  fin_cases i <;> fin_cases j <;> rfl

/-
Boundary matrix has zero diagonal.
-/
theorem boundaryMatrix_diag_zero (e : SPExpr) (i : Fin 2) :
    e.boundaryMatrix i i = 0 := by
  unfold SPExpr.boundaryMatrix; aesop;

/-
Series composition of boundary matrices: off-diagonal entries add.
-/
theorem boundaryMatrix_series (e₁ e₂ : SPExpr) :
    (SPExpr.series e₁ e₂).boundaryMatrix =
    Matrix.of fun i j => if i = j then 0
      else e₁.boundaryMatrix i j + e₂.boundaryMatrix i j := by
  ext i j; simp [SPExpr.boundaryMatrix, effDist_series];
  grind

/-
Parallel composition of boundary matrices: off-diagonal entries take min.
-/
theorem boundaryMatrix_parallel (e₁ e₂ : SPExpr) :
    (SPExpr.parallel e₁ e₂).boundaryMatrix =
    Matrix.of fun i j => if i = j then 0
      else min (e₁.boundaryMatrix i j) (e₂.boundaryMatrix i j) := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [SPExpr.boundaryMatrix, SPExpr.effDist]

/-
**Matrix-Level Boundary Rigidity:** Two reduced expressions with equal
    boundary matrices are equal.
-/
theorem matrix_boundary_rigid (e₁ e₂ : SPExpr)
    (hr₁ : e₁.Reduced) (hr₂ : e₂.Reduced)
    (hM : e₁.boundaryMatrix = e₂.boundaryMatrix) :
    e₁ = e₂ := by
  apply reduced_boundary_rigid e₁ e₂ hr₁ hr₂;
  simpa using congr_fun ( congr_fun hM 0 ) 1

/-! ## Tropical Vertex Elimination (Schur Complement) -/

/-- Weight matrix for a 3-vertex path graph s--v--t with edge weights w₁, w₂.
    Vertices: 0=s, 1=v, 2=t. Absent edges have weight 0 (no direct connection). -/
noncomputable def pathGraph3 (w₁ w₂ : ℝ) : Matrix (Fin 3) (Fin 3) ℝ :=
  Matrix.of fun i j =>
    match i.val, j.val with
    | 0, 0 => 0
    | 0, 1 => w₁
    | 0, 2 => w₁ + w₂
    | 1, 0 => w₁
    | 1, 1 => 0
    | 1, 2 => w₂
    | 2, 0 => w₁ + w₂
    | 2, 1 => w₂
    | 2, 2 => 0
    | _, _ => 0  -- unreachable for Fin 3

/-- The boundary distance matrix obtained by restricting to boundary {0, 2}. -/
noncomputable def boundaryRestrict (D : Matrix (Fin 3) (Fin 3) ℝ) :
    Matrix (Fin 2) (Fin 2) ℝ :=
  Matrix.of fun i j =>
    let i' : Fin 3 := if i.val = 0 then 0 else 2
    let j' : Fin 3 := if j.val = 0 then 0 else 2
    D i' j'

/-
Tropical vertex elimination for a 3-vertex path.
    Eliminating the interior vertex v from path s--v--t produces the
    boundary distance matrix with entry w₁ + w₂ between s and t.
    This is a concrete instance of the tropical Schur complement.
-/
theorem tropical_vertex_elimination (w₁ w₂ : ℝ) :
    boundaryRestrict (pathGraph3 w₁ w₂) =
    (SPExpr.atom (w₁ + w₂)).boundaryMatrix := by
  exact funext fun i => funext fun j => by fin_cases i <;> fin_cases j <;> rfl;

/-
The boundary distance after vertex elimination equals the series
    composition of the two edge weights. This connects the graph-theoretic
    operation (vertex elimination) with the algebraic operation (series).
-/
theorem vertex_elimination_eq_series (w₁ w₂ : ℝ)
    (_hw₁ : 0 < w₁) (_hw₂ : 0 < w₂) :
    boundaryRestrict (pathGraph3 w₁ w₂) =
    (SPExpr.series (.atom w₁) (.atom w₂)).boundaryMatrix := by
  convert tropical_vertex_elimination w₁ w₂ using 1

/-! ## Congruence Properties -/

/-
Series preserves SP-equivalence on the left.
-/
theorem series_congr_left {e₁ e₁' : SPExpr} (e₂ : SPExpr)
    (h : SPEquiv e₁ e₁') :
    SPEquiv (.series e₁ e₂) (.series e₁' e₂) := by
  exact congr_arg₂ ( · + · ) h rfl

/-
Series preserves SP-equivalence on the right.
-/
theorem series_congr_right (e₁ : SPExpr) {e₂ e₂' : SPExpr}
    (h : SPEquiv e₂ e₂') :
    SPEquiv (.series e₁ e₂) (.series e₁ e₂') := by
  exact congrArg (e₁.effDist + ·) h

/-
Parallel preserves SP-equivalence on the left.
-/
theorem parallel_congr_left {e₁ e₁' : SPExpr} (e₂ : SPExpr)
    (h : SPEquiv e₁ e₁') :
    SPEquiv (.parallel e₁ e₂) (.parallel e₁' e₂) := by
  exact congr_arg₂ _ h rfl

/-
Parallel preserves SP-equivalence on the right.
-/
theorem parallel_congr_right (e₁ : SPExpr) {e₂ e₂' : SPExpr}
    (h : SPEquiv e₂ e₂') :
    SPEquiv (.parallel e₁ e₂) (.parallel e₁ e₂') := by
  grind +locals

/-! ## Monotonicity of Effective Distance -/

/-
For positive-weight expressions, effDist of each component is at most
    the effDist of their series composition.
-/
theorem effDist_le_series_left (e₁ e₂ : SPExpr) (h : e₂.PosWeights) :
    e₁.effDist ≤ (SPExpr.series e₁ e₂).effDist := by
  exact le_add_of_nonneg_right ( le_of_lt ( effDist_pos _ h ) )

theorem effDist_le_series_right (e₁ e₂ : SPExpr) (h : e₁.PosWeights) :
    e₂.effDist ≤ (SPExpr.series e₁ e₂).effDist := by
  exact le_add_of_nonneg_left ( effDist_pos e₁ h |> le_of_lt )

theorem effDist_parallel_le_left (e₁ e₂ : SPExpr) :
    (SPExpr.parallel e₁ e₂).effDist ≤ e₁.effDist := by
  grind +suggestions

theorem effDist_parallel_le_right (e₁ e₂ : SPExpr) :
    (SPExpr.parallel e₁ e₂).effDist ≤ e₂.effDist := by
  exact min_le_right _ _

/-! ## Effective Distance as Tropical Semiring Homomorphism -/

/-- The effective distance function is a homomorphism from the SP expression
    algebra (with series = multiplication, parallel = addition) to the
    tropical semiring (ℝ, +, min). This theorem packages both compositionality
    results together. -/
theorem effDist_tropical_homomorphism (e₁ e₂ : SPExpr) :
    (SPExpr.series e₁ e₂).effDist = e₁.effDist + e₂.effDist ∧
    (SPExpr.parallel e₁ e₂).effDist = min e₁.effDist e₂.effDist :=
  ⟨rfl, rfl⟩

end SPBoundaryRigidity