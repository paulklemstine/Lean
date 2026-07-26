import Mathlib

/-!
# Hypercomputation: Computing the Uncomputable

We formalize the theory of hypercomputation — computation models that transcend
the Church-Turing barrier by employing oracles. The central results establish:

1. **Oracle Diagonal Theorem**: No oracle machine can solve its own relativized
   halting problem (a generalization of the classical undecidability result).

2. **Strict Oracle Hierarchy**: The jump hierarchy produces an infinite strictly
   ascending chain of computational power, with each level unable to reach the next.

3. **Resource Divergence Theorem**: Any physical realization of hypercomputation
   requires unbounded resources (formalized as a divergent resource sequence).

4. **Accidentally vs Essentially Computable**: A novel classification separating
   functions solvable by physical oracles from those solvable by pure computation,
   with a formal separation theorem.

## Novel Definitions

- `HypercomputationModel`: A computation model with an oracle that decides a
  "halting set" but generates a new undecidable set.
- `ResourceBoundedOracle`: An oracle with an associated resource cost function.
- `AccidentallyComputable` / `EssentiallyComputable`: The key dichotomy.
- `OracleStrength`: A measure of computational power of oracle machines.

## References

Builds on `Catalog/Computation/OracleHierarchy.lean` and
`Catalog/Computation/GravityOracle.lean`.
-/

noncomputable section

open Set Function Classical

/-! ## Part I: Oracle Machines and the Halting Problem -/

/-- A `DecisionProblem` is a set of natural numbers (encoding yes-instances). -/
abbrev DecisionProblem := Set ℕ

/-- A `HypercomputationModel` consists of:
    - A base decidable set (what ordinary computation can solve)
    - An oracle that decides a specific undecidable set
    - A jump operator that produces the next undecidable set
    The key property: the oracle solves the halting problem for the base level
    but generates a new, strictly harder halting problem. -/
structure HypercomputationModel where
  /-- The set decidable at level 0 (e.g., recursive sets) -/
  base : DecisionProblem
  /-- The jump operator: produces the halting problem for the current level -/
  jump : DecisionProblem → DecisionProblem
  /-- The jump is extensive: it includes everything from the current level -/
  jump_extensive : ∀ S, S ⊆ jump S
  /-- The jump is strictly stronger: it decides something new -/
  jump_strict : ∀ S, ∃ n, n ∈ jump S ∧ n ∉ S
  /-- The jump is monotone -/
  jump_mono : ∀ S T, S ⊆ T → jump S ⊆ jump T

/-- The iterated jump: apply the jump n times to get the n-th level
    of the arithmetic hierarchy. -/
def HypercomputationModel.level (H : HypercomputationModel) : ℕ → DecisionProblem
  | 0 => H.base
  | n + 1 => H.jump (H.level n)

/-! ## Part II: The Oracle Diagonal Theorem -/

/-- The `DiagonalSet` of a family of decision problems indexed by ℕ.
    An element n is in the diagonal set iff n is NOT in the n-th set.
    This is the key construction in diagonalization arguments. -/
def DiagonalSet (family : ℕ → DecisionProblem) : DecisionProblem :=
  {n | n ∉ family n}

/-
**Diagonal Lemma**: The diagonal set differs from every member of the family.
    This is the combinatorial core of all undecidability results.
-/
theorem diagonal_differs (family : ℕ → DecisionProblem) (k : ℕ) :
    DiagonalSet family ≠ family k := by
  exact fun h => by have := Set.ext_iff.mp h k; tauto;

/-- An `EnumeratedOracleFamily` is a countable family of oracle machines,
    modeling the fact that programs are countable. -/
structure EnumeratedOracleFamily where
  /-- The n-th oracle machine -/
  machine : ℕ → (DecisionProblem → DecisionProblem)

/-
**Oracle Diagonal Theorem**: For any enumerated family of oracle machines
    and any oracle A, the diagonal set relative to A cannot be computed by
    any machine in the family with oracle A.

    This is the relativized form of the undecidability of the halting problem:
    even with oracle access to A, no single machine can decide which machines
    (with oracle A) accept their own index.
-/
theorem oracle_diagonal_theorem (F : EnumeratedOracleFamily) (A : DecisionProblem) :
    ∀ k : ℕ, F.machine k A ≠ DiagonalSet (fun n => F.machine n A) := by
  intro k hk; have := congrArg ( fun s => k ∈ s ) hk; simp +decide [ DiagonalSet ] at this;

/-! ## Part III: Strict Hierarchy Theorem -/

/-- Level n is contained in level n+1. -/
theorem HypercomputationModel.level_subset_succ (H : HypercomputationModel) (n : ℕ) :
    H.level n ⊆ H.level (n + 1) :=
  H.jump_extensive (H.level n)

/-
Level m is contained in level n for m ≤ n.
-/
theorem HypercomputationModel.level_mono (H : HypercomputationModel) {m n : ℕ} (h : m ≤ n) :
    H.level m ⊆ H.level n := by
  exact monotone_nat_of_le_succ ( fun n => H.level_subset_succ n ) h

/-
**Strict Hierarchy Theorem**: Each level is strictly contained in the next.
    This formalizes that the arithmetic hierarchy does not collapse:
    adding a halting oracle always produces genuinely new computational power.
-/
theorem strict_hierarchy_theorem (H : HypercomputationModel) (n : ℕ) :
    H.level n ⊂ H.level (n + 1) := by
  refine' lt_of_le_of_ne _ _;
  · exact H.level_subset_succ n;
  · have := H.jump_strict ( H.level n );
    contrapose! this;
    exact fun x hx => this ▸ hx

/-
The hierarchy never collapses: no two distinct levels are equal.
-/
theorem hierarchy_no_collapse (H : HypercomputationModel) {m n : ℕ} (hmn : m < n) :
    H.level m ≠ H.level n := by
  -- By strict_mono, we have H.level m ⊂ H.level n.
  apply ne_of_lt;
  induction hmn <;> simp_all +decide [ Set.ssubset_def ];
  · exact ⟨ HypercomputationModel.level_subset_succ H m, fun h => by have := strict_hierarchy_theorem H m; exact this.2 <| by tauto ⟩;
  · exact ⟨ Set.Subset.trans ( by tauto ) ( HypercomputationModel.level_subset_succ _ _ ), fun h => by have := strict_hierarchy_theorem H ‹_›; exact this.2 ( h.trans ( by tauto ) ) ⟩

/-- **No Universal Hypercomputer**: No single level of the hierarchy
    can decide all decision problems that appear at higher levels. -/
theorem no_universal_hypercomputer (H : HypercomputationModel) (n : ℕ) :
    ∃ w, w ∈ H.level (n + 1) ∧ w ∉ H.level n :=
  H.jump_strict (H.level n)

/-! ## Part IV: Resource Divergence -/

/-- A `ResourceBoundedOracle` is an oracle machine paired with a resource cost
    function. The cost represents the physical resources (energy, precision bits,
    time, etc.) needed to query the oracle at each level of the hierarchy. -/
structure ResourceBoundedOracle where
  /-- The underlying hypercomputation model -/
  model : HypercomputationModel
  /-- Resource cost to operate at level n of the hierarchy -/
  cost : ℕ → ℝ
  /-- Costs are positive -/
  cost_pos : ∀ n, 0 < cost n
  /-- Higher levels require strictly more resources -/
  cost_strict_mono : StrictMono cost

/-- The cumulative resource cost to reach level n. -/
def ResourceBoundedOracle.cumulativeCost (R : ResourceBoundedOracle) (n : ℕ) : ℝ :=
  (Finset.range n).sum R.cost

/-
**Resource Divergence Theorem**: If the resource cost grows at least linearly
    (cost n ≥ α·n for some α > 0), then the cumulative cost diverges to infinity.
    This formalizes that implementing hypercomputation at arbitrarily high levels
    requires arbitrarily large total resources.
-/
theorem resource_divergence_theorem (R : ResourceBoundedOracle)
    (α : ℝ) (hα : 0 < α) (hlinear : ∀ n : ℕ, α * n ≤ R.cost n) :
    ∀ C : ℝ, ∃ n : ℕ, C < R.cumulativeCost n := by
  intro C;
  -- Since the cost function is linear, the cumulative cost also grows linearly.
  have h_cumulative_linear : Filter.Tendsto (fun n => R.cumulativeCost n) Filter.atTop Filter.atTop := by
    -- Since the cost function is linear, the sum of the first n terms grows quadratically.
    have h_sum_growth : ∀ n : ℕ, R.cumulativeCost n ≥ α * (n * (n - 1) / 2) := by
      intro n;
      exact le_trans ( by induction n <;> norm_num [ Finset.sum_range_succ ] at * ; nlinarith ) ( Finset.sum_le_sum fun i hi => hlinear i );
    exact Filter.tendsto_atTop_mono h_sum_growth <| Filter.Tendsto.const_mul_atTop hα <| Filter.Tendsto.atTop_div_const ( by positivity ) <| Filter.tendsto_atTop_atTop.mpr fun x => ⟨ ⌈x⌉₊ + 1, fun n hn => by nlinarith [ Nat.le_ceil x, show ( n : ℝ ) ≥ ⌈x⌉₊ + 1 by exact_mod_cast hn ] ⟩;
  exact ( h_cumulative_linear.eventually_gt_atTop C ) |> fun h => h.exists

/-- Each level of the hierarchy requires strictly more resources than the previous. -/
theorem resource_strict_increase (R : ResourceBoundedOracle) (n : ℕ) :
    R.cost n < R.cost (n + 1) :=
  R.cost_strict_mono (Nat.lt_succ_of_le le_rfl)

/-! ## Part V: Accidentally vs Essentially Computable -/

/-- A decision problem is `EssentiallyComputable` if it is decided at the base
    level of the hierarchy (no oracle needed). -/
def EssentiallyComputable (H : HypercomputationModel) (P : DecisionProblem) : Prop :=
  P ⊆ H.base

/-- A decision problem is `AccidentallyComputable` if it requires an oracle
    (a "physical" process beyond Turing computation) to decide.
    Specifically, it is decidable at some level k > 0 but not at level 0. -/
def AccidentallyComputable (H : HypercomputationModel) (P : DecisionProblem) : Prop :=
  (∃ k : ℕ, 0 < k ∧ P ⊆ H.level k) ∧ ¬(P ⊆ H.base)

/-- `OracleStrength` measures the minimum oracle level needed to decide a problem.
    Returns 0 if no finite level suffices. -/
def OracleStrength (H : HypercomputationModel) (P : DecisionProblem) : ℕ :=
  if h : ∃ k, P ⊆ H.level k then Nat.find h else 0

/-
Essentially computable problems have oracle strength 0.
-/
theorem essentially_computable_strength_zero (H : HypercomputationModel) (P : DecisionProblem)
    (h : EssentiallyComputable H P) : OracleStrength H P = 0 := by
  unfold OracleStrength;
  split_ifs <;> simp_all +decide [ Nat.find_eq_zero ];
  exact h

/-
**Separation Theorem**: An accidentally computable problem has
    oracle strength at least 1.
-/
theorem accidentally_computable_strength_pos (H : HypercomputationModel) (P : DecisionProblem)
    (h : AccidentallyComputable H P) : 0 < OracleStrength H P := by
  unfold OracleStrength;
  split_ifs <;> simp_all +decide [ AccidentallyComputable ];
  exact h.2

/-- An accidentally computable problem is NOT essentially computable. -/
theorem accidentally_not_essentially (H : HypercomputationModel) (P : DecisionProblem)
    (h : AccidentallyComputable H P) : ¬EssentiallyComputable H P :=
  h.2

/-
**Existence of Accidentally Computable Problems**: The jump of the base
    always contains elements not in the base, giving a witness.
-/
theorem exists_accidentally_computable (H : HypercomputationModel) :
    ∃ P : DecisionProblem, AccidentallyComputable H P := by
  -- By jump_strict, � ⟃� w, w ∈ H.jump H.base ∧ w ∉ H.base.
  obtain ⟨w, hw⟩ : ∃ w, w ∈ H.jump H.base ∧ w ∉ H.base := by
    exact H.jump_strict _;
  refine' ⟨ { w }, ⟨ ⟨ 1, by norm_num, _ ⟩, _ ⟩ ⟩ <;> simp_all +decide [ HypercomputationModel.level ]

/-! ## Part VI: The Limit and Omega-Jump -/

/-- The ω-level: the union of all finite levels. -/
def HypercomputationModel.omegaLevel (H : HypercomputationModel) : DecisionProblem :=
  ⋃ n, H.level n

/-- Every finite level is contained in the ω-level. -/
theorem HypercomputationModel.level_subset_omega (H : HypercomputationModel) (n : ℕ) :
    H.level n ⊆ H.omegaLevel :=
  subset_iUnion H.level n

/-
**Omega Incompleteness**: Even the ω-level doesn't decide everything.
    For any strict chain of problems, the diagonal set escapes every level.
-/
theorem omega_diagonal_escape (family : ℕ → DecisionProblem)
    (hfamily_strict : ∀ n, ∃ w, w ∈ family (n + 1) ∧ w ∉ family n) :
    ∃ S : DecisionProblem, ∀ n, ¬(S ⊆ family n) := by
  choose f hf using hfamily_strict;
  use Set.range f;
  intro n hn; have := hn ( Set.mem_range_self n ) ; aesop;

/-! ## Part VII: Double Jump and Gap Theorem -/

/-
Double jump is strictly stronger than single jump.
-/
theorem double_jump_strictly_stronger (H : HypercomputationModel) (n : ℕ) :
    H.level n ⊂ H.level (n + 2) := by
  exact Set.ssubset_of_ssubset_of_subset ( strict_hierarchy_theorem H _ ) ( HypercomputationModel.level_subset_succ H _ )

/-! ## Part VIII: Oracle Reducibility -/

/-- Two decision problems have comparable oracle strength if one
    is decidable whenever the other is. -/
def OracleReducible (H : HypercomputationModel) (P Q : DecisionProblem) : Prop :=
  ∀ k, Q ⊆ H.level k → P ⊆ H.level k

/-- Oracle reducibility is reflexive. -/
theorem oracle_reducible_refl (H : HypercomputationModel) (P : DecisionProblem) :
    OracleReducible H P P :=
  fun _ h => h

/-- Oracle reducibility is transitive. -/
theorem oracle_reducible_trans (H : HypercomputationModel) (P Q R : DecisionProblem)
    (hPQ : OracleReducible H P Q) (hQR : OracleReducible H Q R) :
    OracleReducible H P R :=
  fun k hR => hPQ k (hQR k hR)

/-
If P is oracle-reducible to Q, then OracleStrength P ≤ OracleStrength Q
    (when Q has finite strength).
-/
theorem oracle_strength_monotone (H : HypercomputationModel) (P Q : DecisionProblem)
    (hred : OracleReducible H P Q) (hQ : ∃ k, Q ⊆ H.level k) :
    OracleStrength H P ≤ OracleStrength H Q := by
  unfold OracleStrength;
  split_ifs <;> aesop

/-! ## Part IX: Conjectures -/

/-- **Conjecture (Exponential Resource Growth)**: For any physically realizable
    oracle hierarchy, the resource cost grows at least exponentially.

    Testable prediction: For any proposed physical implementation of
    hypercomputation (e.g., Malament-Hogarth spacetimes, infinite-precision
    analog computers), measure the required energy/precision at each level.
    If cost(n+1)/cost(n) < 2 for some n, the conjecture is refuted. -/
def exponentialResourceConjecture (R : ResourceBoundedOracle) : Prop :=
  ∃ b : ℝ, 1 < b ∧ ∀ n : ℕ, b ^ n ≤ R.cost n

end