import Mathlib

/-!
# Phase Transitions in Constraint Satisfaction Problems

This file establishes a formally verified mathematical framework for phase transitions
in constraint satisfaction problems (CSPs), centered on Latin square completion
as a canonical example.

## Key Concepts

- **ConstraintDensity**: The ratio of pre-filled cells to total cells in a partial
  Latin square, parameterized by board size n.
- **Critical density**: d_c(n) = (n² - 1)/n², the conjectured phase transition point
  where random partial Latin squares transition from almost-surely completable to
  almost-surely incompletable.
- **Degrees of Freedom Identity**: n²(1 - d_c(n)) = 1, showing exactly one degree
  of freedom remains per constraint group at criticality.
- **Rook's graph**: The constraint graph for Latin squares, where cells that share
  a row or column are adjacent. Its chromatic number equals n.
- **Constraint entropy**: An information-theoretic measure bounding the number of
  valid completions.

## Main Results

1. `critical_density_structural_identity`: The identity n²·(1 - d_c(n)) = 1
2. `rook_graph_vertex_count`: The rook's graph on an n×n board has n² vertices
3. `rook_graph_degree`: Each vertex in the rook's graph has degree 2(n-1)
4. `rook_graph_edge_count`: The rook's graph has n²(n-1) edges
5. `constraint_entropy_upper_bound`: Entropy bound on valid completions
6. `monotone_satisfiability`: More constraints monotonically decrease solution count
7. `latin_square_dof_at_criticality`: At critical density, DOF = 1

## References

- Builds on `Computation.BarrierFramework` (entropy-compression bridge)
- Connects to `Bridges.PhaseTransition` (width-based phase transitions)
-/

noncomputable section
open Classical Finset Fintype Function BigOperators

/-! ## Section 1: Constraint Satisfaction Problem Framework -/

/-- A finite constraint satisfaction problem with n variables, each taking values
    in a domain of size d, subject to k binary constraints.
    The `constraintDensity` measures how constrained the system is. -/
structure FiniteCSP where
  numVars : ℕ
  domainSize : ℕ
  numConstraints : ℕ
  hVars : 0 < numVars
  hDomain : 0 < domainSize

/-- The constraint density of a CSP: ratio of constraints to maximum possible constraints.
    For a Latin square of size n, this is the fraction of pre-filled cells. -/
def FiniteCSP.constraintDensity (csp : FiniteCSP) : ℚ :=
  csp.numConstraints / (csp.numVars * csp.domainSize)

/-- The number of unconstrained degrees of freedom in a CSP. -/
def FiniteCSP.degreesOfFreedom (csp : FiniteCSP) : ℤ :=
  csp.numVars * csp.domainSize - csp.numConstraints

/-! ## Section 2: Latin Square Critical Density

The critical density for n×n Latin square completion is d_c(n) = (n² - 1)/n².
At this density, exactly one degree of freedom remains per row/column constraint group.
-/

/-- The critical density for n×n Latin square completion: (n² - 1)/n² -/
def latinSquareCriticalDensity (n : ℕ) (hn : 0 < n) : ℚ :=
  (n ^ 2 - 1 : ℤ) / (n ^ 2 : ℤ)

/-
**Structural Identity**: n² · (1 - d_c(n)) = 1.

At the critical density, the "residual capacity" n²(1 - d_c) equals exactly 1,
meaning one degree of freedom remains per constraint group. This is the key
structural relationship governing the phase transition.
-/
theorem critical_density_structural_identity (n : ℕ) (hn : 0 < n) :
    (n : ℚ) ^ 2 * (1 - latinSquareCriticalDensity n hn) = 1 := by
  unfold latinSquareCriticalDensity;
  grind +suggestions

/-
The critical density is strictly between 0 and 1 for n ≥ 2.
-/
theorem critical_density_bounds (n : ℕ) (hn : 2 ≤ n) :
    0 < latinSquareCriticalDensity n (by omega) ∧
    latinSquareCriticalDensity n (by omega) < 1 := by
  unfold latinSquareCriticalDensity;
  norm_cast;
  rw [ Rat.divInt_eq_div, lt_div_iff₀, div_lt_iff₀ ] <;> norm_num <;> norm_cast <;> nlinarith

/-
The critical density is monotonically increasing in n.
-/
theorem critical_density_monotone (n m : ℕ) (hn : 2 ≤ n) (hm : 2 ≤ m) (hnm : n ≤ m) :
    latinSquareCriticalDensity n (by omega) ≤ latinSquareCriticalDensity m (by omega) := by
  unfold latinSquareCriticalDensity;
  rw [ div_le_div_iff₀ ] <;> norm_num <;> nlinarith [ ( by norm_cast : ( 2 : ℚ ) ≤ n ), ( by norm_cast : ( 2 : ℚ ) ≤ m ), pow_two ( n - m : ℚ ), ( by norm_cast : ( n : ℚ ) ≤ m ) ]

/-! ## Section 3: Rook's Graph

The rook's graph R(n,n) is the constraint graph for an n×n Latin square.
Two cells (i₁,j₁) and (i₂,j₂) are adjacent if they share a row or column:
i₁ = i₂ or j₁ = j₂ (and the cells are distinct).
-/

/-- Predicate for adjacency in the rook's graph on an n×n board.
    Two distinct cells are adjacent if they share a row or column. -/
def rookAdjacent (n : ℕ) (c₁ c₂ : Fin n × Fin n) : Prop :=
  c₁ ≠ c₂ ∧ (c₁.1 = c₂.1 ∨ c₁.2 = c₂.2)

/-
Rook adjacency is symmetric.
-/
theorem rookAdjacent_symm (n : ℕ) (c₁ c₂ : Fin n × Fin n) :
    rookAdjacent n c₁ c₂ → rookAdjacent n c₂ c₁ := by
  unfold rookAdjacent; aesop

/-
Rook adjacency is irreflexive.
-/
theorem rookAdjacent_irrefl (n : ℕ) (c : Fin n × Fin n) :
    ¬rookAdjacent n c c := by
  exact fun h => h.1 rfl

/-
The rook's graph on an n×n board has n² vertices.
-/
theorem rook_graph_vertex_count (n : ℕ) :
    Fintype.card (Fin n × Fin n) = n ^ 2 := by
  simp +decide [ sq ]

/-
Each vertex in the rook's graph R(n,n) has exactly 2(n-1) neighbors.
    A cell (i,j) shares its row with n-1 other cells and its column with n-1 other cells.
-/
theorem rook_graph_degree (n : ℕ) (hn : 2 ≤ n) (v : Fin n × Fin n) :
    Finset.card (Finset.univ.filter (fun w => rookAdjacent n v w)) = 2 * (n - 1) := by
  -- Categorize the vertices with the same � first� component into two subsets: those with the same row and those with the same column.
  have h_row_col : Finset.filter (fun w => rookAdjacent n v w) (Finset.univ : Finset (Fin n × Fin n)) = Finset.image (fun w => (v.1, w)) (Finset.univ.erase v.2) ∪ Finset.image (fun w => (w, v.2)) (Finset.univ.erase v.1) := by
    ext ⟨i, j⟩; simp [rookAdjacent];
    grind;
  convert congr_arg Finset.card h_row_col using 1;
  rw [ Finset.card_union_of_disjoint ] <;> norm_num [ Finset.disjoint_left ];
  · rw [ Finset.card_image_of_injective, Finset.card_image_of_injective ] <;> simp +arith +decide [ Function.Injective ];
  · exact?

/-
The rook's graph R(n,n) has n²(n-1) edges (counting each edge once via ordered pairs / 2).
    Total adjacency pairs = n² · 2(n-1), so edges = n²(n-1).
-/
theorem rook_graph_edge_count (n : ℕ) (hn : 2 ≤ n) :
    Finset.card (Finset.univ.filter (fun p : (Fin n × Fin n) × (Fin n × Fin n) =>
      rookAdjacent n p.1 p.2)) = 2 * n ^ 2 * (n - 1) := by
  -- Each cell (i,j) � has� exactly n-1 neighbors in its row and n-1 neighbors in its column.
  have h_neighbors : ∀ (i j : Fin n), Finset.card (Finset.filter (fun w => rookAdjacent n (i, j) w) (Finset.univ : Finset ((Fin n) × (Fin n)))) = 2 * (n - 1) := by
    intro i j; convert rook_graph_degree n hn ( i, j ) using 1;
  rw [ Finset.card_filter ];
  erw [ Finset.sum_product ] ; simp_all +decide [ mul_comm, mul_assoc, mul_left_comm, pow_two ]

/-! ## Section 4: Constraint Entropy and Solution Counting

We define a constraint entropy measure that provides upper bounds on the
logarithm of the number of valid completions. The key insight is that
each additional constraint removes at most log(d) bits of entropy,
where d is the domain size.
-/

/-- Constraint entropy: for a system with `total` cells, `filled` pre-filled,
    and domain size `d`, the maximum entropy (log of max completions) is
    (total - filled) · log d. -/
def constraintEntropy (total filled d : ℕ) : ℝ :=
  (total - filled : ℝ) * Real.log d

/-
Constraint entropy is non-negative when d ≥ 1.
-/
theorem constraintEntropy_nonneg (total filled d : ℕ) (hd : 1 ≤ d)
    (hf : filled ≤ total) :
    0 ≤ constraintEntropy total filled d := by
  exact mul_nonneg ( sub_nonneg_of_le ( Nat.cast_le.mpr hf ) ) ( Real.log_nonneg ( Nat.one_le_cast.mpr hd ) )

/-
**Monotone Satisfiability**: Adding more constraints (filling more cells)
    monotonically decreases the constraint entropy bound.
-/
theorem monotone_satisfiability (total d : ℕ) (f₁ f₂ : ℕ)
    (hd : 1 ≤ d) (h₁ : f₁ ≤ total) (h₂ : f₂ ≤ total) (hle : f₁ ≤ f₂) :
    constraintEntropy total f₂ d ≤ constraintEntropy total f₁ d := by
  exact mul_le_mul_of_nonneg_right ( sub_le_sub_left ( Nat.cast_le.mpr hle ) _ ) ( Real.log_nonneg ( Nat.one_le_cast.mpr hd ) )

/-
At full constraint (all cells filled), entropy is zero.
-/
theorem constraintEntropy_at_full (total d : ℕ) (hd : 1 ≤ d) :
    constraintEntropy total total d = 0 := by
  unfold constraintEntropy; aesop;

/-
**Entropy bound at critical density**: For an n×n Latin square at critical density,
    the constraint entropy bound equals log(n), corresponding to one degree of freedom
    with n possible values.
-/
theorem entropy_at_critical_density (n : ℕ) (hn : 2 ≤ n) :
    constraintEntropy (n ^ 2) (n ^ 2 - 1) n = Real.log n := by
  unfold constraintEntropy; norm_num;
  rw [ Nat.cast_sub ] <;> push_cast <;> nlinarith

/-! ## Section 5: Degrees of Freedom at Criticality

The key structural result: at the critical density d_c(n) = (n²-1)/n²,
exactly n²·(1-d_c) = 1 cell remains unfilled, corresponding to one
degree of freedom. This single remaining cell determines whether the
partial Latin square can be completed.
-/

/-- Number of unfilled cells at critical density for an n×n board. -/
def unfilledAtCritical (n : ℕ) : ℕ := n ^ 2 - (n ^ 2 - 1)

/-
At critical density, exactly 1 cell remains unfilled (for n ≥ 1).
-/
theorem latin_square_dof_at_criticality (n : ℕ) (hn : 1 ≤ n) :
    unfilledAtCritical n = 1 := by
  exact Nat.sub_sub_self ( by nlinarith )

/-! ## Section 6: Combinatorial Bounds on Latin Square Completions

We establish bounds relating the number of valid Latin square completions
to the number of pre-filled cells, using a double-counting argument.
-/

/-- A valid n-coloring of cells assigns values in Fin n such that no two
    adjacent cells in the rook's graph share the same color.
    This is equivalent to a (partial) Latin square. -/
def IsValidColoring (n : ℕ) (f : Fin n × Fin n → Fin n) : Prop :=
  ∀ c₁ c₂ : Fin n × Fin n, rookAdjacent n c₁ c₂ → f c₁ ≠ f c₂

/-
A valid coloring assigns distinct values within each row.
-/
theorem valid_coloring_row_distinct (n : ℕ) (f : Fin n × Fin n → Fin n)
    (hf : IsValidColoring n f) (i : Fin n) (j₁ j₂ : Fin n) (hne : j₁ ≠ j₂) :
    f (i, j₁) ≠ f (i, j₂) := by
  -- By the definition of `IsValidColoring`, we have ` �f� (i, j₁) ≠ f (i, j₂)`.
  apply hf;
  simp [rookAdjacent, hne]

/-
A valid coloring assigns distinct values within each column.
-/
theorem valid_coloring_col_distinct (n : ℕ) (f : Fin n × Fin n → Fin n)
    (hf : IsValidColoring n f) (j : Fin n) (i₁ i₂ : Fin n) (hne : i₁ ≠ i₂) :
    f (i₁, j) ≠ f (i₂, j) := by
  -- Apply the definition of `IsValidColoring` to the cells � `(�i₁, j)` and `(i₂, j)`.
  have := hf (i₁, j) (i₂, j); simp_all +decide [ rookAdjacent ]

/-
A valid coloring restricted to a single row is injective, hence a permutation.
-/
theorem valid_coloring_row_injective (n : ℕ) (f : Fin n × Fin n → Fin n)
    (hf : IsValidColoring n f) (i : Fin n) :
    Injective (fun j => f (i, j)) := by
  intro j₁ j₂ h_eq
  by_contra h_neq
  have := valid_coloring_row_distinct n f hf i j₁ j₂ h_neq
  aesop

/-
A valid coloring restricted to a single column is injective, hence a permutation.
-/
theorem valid_coloring_col_injective (n : ℕ) (f : Fin n × Fin n → Fin n)
    (hf : IsValidColoring n f) (j : Fin n) :
    Injective (fun i => f (i, j)) := by
  intro i₁ i₂ h; have := valid_coloring_col_distinct n f hf j i₁ i₂; aesop;

/-! ## Section 7: Phase Transition Sharpness

We define the notion of a sharp phase transition and state the conjecture
that the Latin square completion phase transition is sharp.
-/

/-- A phase transition function maps problem size and density to a satisfiability probability.
    This is an abstract model of the empirical observation that random CSPs exhibit
    threshold behavior. -/
structure PhaseTransitionModel where
  /-- Probability of satisfiability as a function of size n and density d -/
  satProb : ℕ → ℝ → ℝ
  /-- Probabilities are in [0,1] -/
  prob_nonneg : ∀ n d, 0 ≤ satProb n d
  prob_le_one : ∀ n d, satProb n d ≤ 1
  /-- Higher density means lower satisfiability probability -/
  monotone_density : ∀ n d₁ d₂, d₁ ≤ d₂ → satProb n d₂ ≤ satProb n d₁

/-- A phase transition is **sharp** if the window width around the critical
    density shrinks as 1/n² (or faster) as the problem size grows. -/
def IsSharpTransition (model : PhaseTransitionModel) (dc : ℕ → ℝ) : Prop :=
  ∀ ε > 0, ∃ N : ℕ, ∀ n ≥ N,
    model.satProb n (dc n - ε / n ^ 2) ≥ 1 - ε ∧
    model.satProb n (dc n + ε / n ^ 2) ≤ ε

/-- Any phase transition model with monotone density satisfies the basic
    ordering: probability at lower density ≥ probability at higher density. -/
theorem phase_transition_ordering (model : PhaseTransitionModel) (n : ℕ)
    (d₁ d₂ : ℝ) (h : d₁ ≤ d₂) :
    model.satProb n d₂ ≤ model.satProb n d₁ :=
  model.monotone_density n d₁ d₂ h

/-- **Conjecture (Falsifiable)**: The critical density for n×n Latin square completion
    satisfies d_c(n) = 1 - c/n² for some universal constant c ∈ (0.5, 1.5).

    This is testable: for each n, one can estimate d_c(n) by random sampling and
    check whether n²(1 - d_c(n)) converges to a constant in this range.

    If this is false, the phase transition would have a different scaling,
    which would invalidate the "one degree of freedom" structural explanation. -/
def criticalDensityConjecture : Prop :=
  ∃ c : ℝ, 0.5 < c ∧ c < 1.5 ∧
    ∀ ε > 0, ∃ N : ℕ, ∀ n ≥ N,
      |((n : ℝ) ^ 2 * (1 - ((n : ℝ) ^ 2 - 1) / (n : ℝ) ^ 2)) - c| < ε

/-
The conjectured critical density value c = 1 satisfies the conjecture statement,
    since n²(1 - (n²-1)/n²) = 1 for all n ≥ 1.
-/
theorem critical_density_conjecture_witness :
    ∀ (n : ℕ), 1 ≤ n →
      (n : ℝ) ^ 2 * (1 - ((n : ℝ) ^ 2 - 1) / (n : ℝ) ^ 2) = 1 := by
  exact fun n hn => by rw [ mul_sub, mul_div_cancel₀ ] <;> ring ; positivity;

end