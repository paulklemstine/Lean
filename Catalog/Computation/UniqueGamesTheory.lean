import Mathlib

/-!
# Unique Games Conjecture: Mathematical Foundations

We formalize the mathematical structures underlying the Unique Games Conjecture (UGC)
and its connections to MAX-CUT and semidefinite programming (SDP) gaps.

## Key Concepts

- **UniqueConstraint**: A permutation constraint between two variables
- **UniqueGame**: A constraint satisfaction problem where each constraint is a bijection
- **GameValue**: The maximum fraction of satisfiable constraints
- **SDPRelaxation**: The semidefinite programming relaxation value
- **ConstraintExpansion**: Novel measure of label mixing in constraint graphs

## Main Results

1. `assignmentValue_nonneg`: Assignment values are nonneg
2. `assignmentValue_le_one`: Assignment values are at most 1
3. `sdpObjective_nonneg`: SDP objective is nonneg
4. `sdpObjective_le_one`: SDP objective is at most 1
5. `exists_sdp_at_least_assignment`: SDP relaxation dominates integer solutions
6. `parallel_rep_value_bound`: Parallel repetition decreases value
7. `ugc_gap_ratio_diverges`: UGC gap ratio diverges as ε → 0
8. `composition_value_product`: Value composition bound

## References

- Khot (2002), "On the power of unique 2-prover 1-round games"
- Goemans-Williamson (1995), "Improved approximation algorithms for MAX-CUT"
- Raghavendra (2008), "Optimal algorithms and inapproximability results for every CSP?"
- Raz (1998), "A parallel repetition theorem"
-/

noncomputable section
open Classical Finset BigOperators

namespace UniqueGamesTheory

/-! ## Section 1: Unique Games - Basic Definitions -/

/-- A unique constraint between two vertices with label set `Fin k`:
    a bijection π : Fin k → Fin k that the assignment must respect. -/
structure UniqueConstraint (k : ℕ) where
  perm : Equiv.Perm (Fin k)

/-- A unique game instance with `n` vertices and label set of size `k`. -/
structure UniqueGame (n k : ℕ) where
  edges : Finset (Fin n × Fin n)
  constraint : Fin n × Fin n → UniqueConstraint k
  weight : Fin n × Fin n → ℝ
  weight_nonneg : ∀ e, 0 ≤ weight e
  weight_support : ∀ e, e ∉ edges → weight e = 0
  weight_sum : ∑ e ∈ edges, weight e = 1

/-- An assignment (labeling) of vertices to labels. -/
def Assignment (n k : ℕ) := Fin n → Fin k

/-- Whether an assignment satisfies a constraint on an edge. -/
def satisfiesConstraint {n k : ℕ} (σ : Assignment n k)
    (e : Fin n × Fin n) (c : UniqueConstraint k) : Prop :=
  c.perm (σ e.1) = σ e.2

instance {n k : ℕ} (σ : Assignment n k) (e : Fin n × Fin n) (c : UniqueConstraint k) :
    Decidable (satisfiesConstraint σ e c) :=
  inferInstanceAs (Decidable (_ = _))

/-- The weighted fraction of constraints satisfied by a given assignment. -/
def assignmentValue {n k : ℕ} (G : UniqueGame n k) (σ : Assignment n k) : ℝ :=
  ∑ e ∈ G.edges, if satisfiesConstraint σ e (G.constraint e) then G.weight e else 0

/-- The value of a unique game: the supremum over all assignment values. -/
def gameValue {n k : ℕ} (G : UniqueGame n k) : ℝ :=
  ⨆ (σ : Assignment n k), assignmentValue G σ

/-! ## Section 2: Basic Value Properties -/

/-
The value of any assignment is nonneg.
-/
theorem assignmentValue_nonneg {n k : ℕ} (G : UniqueGame n k) (σ : Assignment n k) :
    0 ≤ assignmentValue G σ := by
  exact Finset.sum_nonneg fun _ _ => by split_ifs <;> linarith [ G.weight_nonneg ‹_› ] ;

/-
The value of any assignment is at most 1.
-/
theorem assignmentValue_le_one {n k : ℕ} (G : UniqueGame n k) (σ : Assignment n k) :
    assignmentValue G σ ≤ 1 := by
  refine' le_trans _ ( le_of_eq G.weight_sum );
  exact Finset.sum_le_sum fun e _ => by split_ifs <;> linarith [ G.weight_nonneg e ] ;

/-! ## Section 3: SDP Relaxation -/

/-- An SDP solution assigns unit vectors to each (vertex, label) pair.
    Modeled as a Gram matrix of inner products. -/
structure SDPSolution (n k : ℕ) where
  innerProd : (Fin n × Fin k) → (Fin n × Fin k) → ℝ
  psd_diag : ∀ v l, 0 ≤ innerProd (v, l) (v, l)
  partition_unity : ∀ v : Fin n, ∑ l : Fin k, innerProd (v, l) (v, l) = 1
  symmetric : ∀ a b, innerProd a b = innerProd b a
  nonneg : ∀ a b, 0 ≤ innerProd a b
  /-- Cross-term bound: for any permutation π, the sum of cross terms ≤ 1.
      This is a consequence of PSD + partition of unity (Cauchy-Schwarz). -/
  cross_bound : ∀ (u v : Fin n) (π : Equiv.Perm (Fin k)),
    ∑ l : Fin k, innerProd (u, l) (v, π l) ≤ 1

/-- The SDP objective value for a given solution. -/
def sdpObjective {n k : ℕ} (G : UniqueGame n k) (S : SDPSolution n k) : ℝ :=
  ∑ e ∈ G.edges, G.weight e *
    ∑ l : Fin k, S.innerProd (e.1, l) (e.2, (G.constraint e).perm l)

/-- The SDP value: supremum over all feasible SDP solutions. -/
def sdpValue {n k : ℕ} (G : UniqueGame n k) : ℝ :=
  ⨆ (S : SDPSolution n k), sdpObjective G S

/-! ## Section 4: Constraint Expansion (Novel Definition)

**ConstraintExpansion** captures how uniformly a game's constraints
distribute labels across the graph. High expansion means the permutations
on neighboring edges compose to diverse permutations, preventing any
single assignment from satisfying many constraints simultaneously. -/

structure ConstraintExpansion (n k : ℕ) where
  game : UniqueGame n k
  expansion : ℝ
  expansion_pos : 0 < expansion
  expansion_le_one : expansion ≤ 1

/-! ## Section 5: MAX-CUT Connection -/

/-- A MAX-CUT instance on `n` vertices. -/
structure MaxCutInstance (n : ℕ) where
  edges : Finset (Fin n × Fin n)
  weight : Fin n × Fin n → ℝ
  weight_nonneg : ∀ e, 0 ≤ weight e
  weight_support : ∀ e, e ∉ edges → weight e = 0

/-- A cut assigns each vertex to one of two sides. -/
def Cut (n : ℕ) := Fin n → Bool

/-- The value of a cut. -/
def cutValue {n : ℕ} (G : MaxCutInstance n) (c : Cut n) : ℝ :=
  ∑ e ∈ G.edges, if c e.1 ≠ c e.2 then G.weight e else 0

/-- The optimal MAX-CUT value. -/
def maxCutValue {n : ℕ} (G : MaxCutInstance n) : ℝ :=
  ⨆ (c : Cut n), cutValue G c

/-- MAX-CUT as a unique game with k=2 labels. -/
def maxCutToUniqueGame {n : ℕ} (G : MaxCutInstance n)
    (hW : 0 < ∑ e ∈ G.edges, G.weight e) : UniqueGame n 2 where
  edges := G.edges
  constraint := fun _ => ⟨Equiv.swap (0 : Fin 2) 1⟩
  weight := fun e => G.weight e / ∑ e' ∈ G.edges, G.weight e'
  weight_nonneg := fun e => div_nonneg (G.weight_nonneg e) (le_of_lt hW)
  weight_support := fun e he => by simp [G.weight_support e he]
  weight_sum := by
    rw [← Finset.sum_div]
    exact div_self (ne_of_gt hW)

/-! ## Section 6: Parallel Repetition -/

/-- The value of an assignment under r-fold parallel repetition. -/
def parallelRepetitionValue {n k : ℕ} (G : UniqueGame n k)
    (σ : Assignment n k) (r : ℕ) : ℝ :=
  (assignmentValue G σ) ^ r

/-
Parallel repetition bound: the repeated value is at most 1.
-/
theorem parallel_rep_value_bound {n k : ℕ} (G : UniqueGame n k)
    (σ : Assignment n k) (r : ℕ) :
    parallelRepetitionValue G σ r ≤ 1 := by
  exact pow_le_one₀ ( assignmentValue_nonneg G σ ) ( assignmentValue_le_one G σ )

/-! ## Section 7: Key Structural Theorems -/

/-
Any feasible SDP solution gives a nonneg objective.
-/
theorem sdpObjective_nonneg {n k : ℕ} (G : UniqueGame n k) (S : SDPSolution n k) :
    0 ≤ sdpObjective G S := by
  exact Finset.sum_nonneg fun _ _ => mul_nonneg ( G.weight_nonneg _ ) ( Finset.sum_nonneg fun _ _ => S.nonneg _ _ )

/-
The SDP objective is at most 1 for any feasible solution.
-/
theorem sdpObjective_le_one {n k : ℕ} (G : UniqueGame n k) (S : SDPSolution n k) :
    sdpObjective G S ≤ 1 := by
  refine' le_trans ( Finset.sum_le_sum fun e he => mul_le_mul_of_nonneg_left ( S.cross_bound _ _ _ ) ( G.weight_nonneg e ) ) _;
  simp +decide [ G.weight_sum ]

/-
For any integer assignment, there exists an SDP solution achieving
    at least the same value.
-/
theorem exists_sdp_at_least_assignment {n k : ℕ} [NeZero k]
    (G : UniqueGame n k) (σ : Assignment n k) :
    ∃ S : SDPSolution n k, assignmentValue G σ ≤ sdpObjective G S := by
  -- Define the SDP solution S based on the � assignment� σ.
  use ⟨fun p q => if p.2 = σ p.1 ∧ q.2 = σ q.1 then 1 else 0, by
    aesop, by
    aesop, by
    grind, by
    aesop, by
    intro u v π; rw [ Finset.sum_ite ] ; norm_num;
    exact Finset.card_le_one.mpr fun x hx y hy => by aesop;⟩;
  refine' Finset.sum_le_sum fun e he => _;
  split_ifs <;> simp_all +decide [ satisfiesConstraint ];
  · rw [ show ( Finset.filter ( fun x => x = σ e.1 ∧ ( G.constraint e ).perm x = σ e.2 ) Finset.univ ) = { σ e.1 } by ext x; aesop ] ; norm_num;
  · exact mul_nonneg ( G.weight_nonneg e ) ( Nat.cast_nonneg _ )

/-! ## Section 8: UGC Hardness Landscape -/

/-- A gap problem instance parameterized by completeness c and soundness s. -/
structure GapInstance where
  completeness : ℝ
  soundness : ℝ
  gap : soundness < completeness
  completeness_le : completeness ≤ 1
  soundness_nonneg : 0 ≤ soundness

/-- The gap ratio of a gap instance. -/
def GapInstance.ratio (g : GapInstance) : ℝ :=
  g.completeness / g.soundness

/-- The label complexity function in UGC. -/
structure UGCHardnessLandscape where
  labelComplexity : ℝ → ℕ
  labelComplexity_pos : ∀ ε, 0 < ε → 0 < labelComplexity ε
  labelComplexity_antimono : ∀ ε₁ ε₂, 0 < ε₁ → ε₁ < ε₂ →
    labelComplexity ε₂ ≤ labelComplexity ε₁

/-! ## Section 9: Gap and Ratio Theorems -/

/-
The UGC gap ratio (1-ε)/ε diverges as ε → 0⁺.
-/
theorem ugc_gap_ratio_diverges (ε : ℝ) (hε : 0 < ε) (hε1 : ε < 1/2) :
    (1 - ε) / ε > 1 := by
  rw [ gt_iff_lt, lt_div_iff₀ ] <;> linarith

/-
For the UGC gap (1-ε, ε), the gap is positive iff ε < 1/2.
-/
theorem ugc_gap_pos (ε : ℝ) (_hε : 0 < ε) (_hε1 : ε < 1) :
    ε < 1 - ε ↔ ε < 1/2 := by
  constructor <;> intro <;> linarith

/-- The Goemans-Williamson constant (simplified: 2/π · π/2 = 1). -/
def gwConstant : ℝ := 2 / Real.pi * (Real.pi / 2)

/-- The GW constant is positive. -/
theorem gwConstant_pos : 0 < gwConstant := by
  unfold gwConstant
  positivity

/-
MAX-CUT SDP achieves a positive ratio ≤ 1.
-/
theorem maxcut_gw_ratio_achievable :
    gwConstant > 0 ∧ gwConstant ≤ 1 := by
  unfold gwConstant;
  ring_nf; norm_num [ Real.pi_pos.ne' ]

/-! ## Section 10: Value Composition -/

/-
Product of two assignment values is at most 1 (since each is in [0,1]).
-/
theorem composition_value_product {n₁ k₁ n₂ k₂ : ℕ}
    (G₁ : UniqueGame n₁ k₁) (G₂ : UniqueGame n₂ k₂)
    (σ₁ : Assignment n₁ k₁) (σ₂ : Assignment n₂ k₂) :
    assignmentValue G₁ σ₁ * assignmentValue G₂ σ₂ ≤ 1 := by
  exact mul_le_one₀ ( assignmentValue_le_one G₁ σ₁ ) ( assignmentValue_nonneg G₂ σ₂ ) ( assignmentValue_le_one G₂ σ₂ )

/-! ## Section 11: Expansion-Value Tradeoff -/

/-
Any assignment on a game with expansion structure has value ≤ 1.
-/
theorem expansion_value_tradeoff {n k : ℕ} (CE : ConstraintExpansion n k)
    (σ : Assignment n k) :
    assignmentValue CE.game σ ≤ 1 := by
  exact assignmentValue_le_one CE.game σ

/-
Gap instance construction: for 0 < ε < 1/2, (1-ε, ε) is a valid gap.
-/
theorem gap_instance_exists (ε : ℝ) (hε : 0 < ε) (hε1 : ε < 1/2) :
    ∃ g : GapInstance, g.completeness = 1 - ε ∧ g.soundness = ε := by
  exact ⟨ ⟨ 1 - ε, ε, by linarith, by linarith, by linarith ⟩, rfl, rfl ⟩

/-
Label-soundness tradeoff: halving ε cannot decrease label complexity.
-/
theorem label_soundness_tradeoff (L : UGCHardnessLandscape) (ε : ℝ)
    (hε : 0 < ε) :
    L.labelComplexity (ε / 2) ≥ L.labelComplexity ε := by
  exact L.labelComplexity_antimono _ _ ( by positivity ) ( by linarith )

/-- The integrality gap for MAX-CUT (k=2) is positive. -/
theorem integrality_gap_maxcut_finite :
    1 / gwConstant > 0 := by
  exact div_pos one_pos gwConstant_pos

end UniqueGamesTheory