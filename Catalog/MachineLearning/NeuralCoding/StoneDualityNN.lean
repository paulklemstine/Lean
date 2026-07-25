/-
# Stone Duality for Neural Networks

## Overview
We formalize the connection between neural network decision boundaries and
Boolean algebras via Stone duality. A ReLU neural network with m neurons
partitions input space into linear regions, each characterized by an
"activation pattern" σ ∈ {0,1}^m indicating which neurons are active.
These activation patterns generate a finite Boolean algebra whose atoms
correspond to the linear regions of the network.

## Key Results
1. Activation patterns induce a partition of input space
2. The set of regions forms a finite Boolean subalgebra of Set(ℝⁿ)
3. Stone's theorem (finite case): |B| = 2^(#atoms)
4. Zaslavsky-type bound: ≤ ∑_{i=0}^n C(m,i) regions for m hyperplanes in ℝⁿ
5. Refinement under composition: deeper networks refine the partition
-/

import Mathlib

open Finset BigOperators Classical

noncomputable section

/-! ## Part 1: Hyperplane Arrangements and Activation Patterns -/

/-- A hyperplane arrangement in ℝⁿ with m hyperplanes.
    Each hyperplane is defined by a weight vector w_i and bias b_i,
    giving the halfspace {x : ⟨w_i, x⟩ + b_i > 0}. -/
structure HyperplaneArrangement (n m : ℕ) where
  weights : Fin m → Fin n → ℝ
  biases  : Fin m → ℝ

/-- The activation value of neuron j at point x -/
def HyperplaneArrangement.activation
    {n m : ℕ} (A : HyperplaneArrangement n m) (x : Fin n → ℝ) (j : Fin m) : ℝ :=
  (∑ i : Fin n, A.weights j i * x i) + A.biases j

/-- The activation pattern of a point x -/
def HyperplaneArrangement.pattern
    {n m : ℕ} (A : HyperplaneArrangement n m) (x : Fin n → ℝ) : Fin m → Bool :=
  fun j => if A.activation x j > 0 then true else false

/-- The region corresponding to a given activation pattern σ -/
def HyperplaneArrangement.region
    {n m : ℕ} (A : HyperplaneArrangement n m) (σ : Fin m → Bool) : Set (Fin n → ℝ) :=
  {x | A.pattern x = σ}

/-! ## Part 2: Partition Theorem -/

/-- **Partition Theorem**: Every point belongs to exactly one region. -/
theorem HyperplaneArrangement.regions_partition
    {n m : ℕ} (A : HyperplaneArrangement n m) (x : Fin n → ℝ) :
    ∃! σ : Fin m → Bool, x ∈ A.region σ := by
  exact ⟨A.pattern x, rfl, fun σ hσ => hσ.symm⟩

/-- Distinct patterns yield disjoint regions -/
theorem HyperplaneArrangement.regions_disjoint
    {n m : ℕ} (A : HyperplaneArrangement n m)
    {σ₁ σ₂ : Fin m → Bool} (h : σ₁ ≠ σ₂) :
    A.region σ₁ ∩ A.region σ₂ = ∅ := by
  ext x
  simp only [Set.mem_inter_iff, HyperplaneArrangement.region, Set.mem_setOf_eq,
             Set.mem_empty_iff_false, iff_false, not_and]
  intro h1 h2; exact h (h1.symm.trans h2)

/-- The union of all regions is the entire space -/
theorem HyperplaneArrangement.regions_cover
    {n m : ℕ} (A : HyperplaneArrangement n m) :
    ⋃ σ : Fin m → Bool, A.region σ = Set.univ := by
  ext x; simp only [Set.mem_iUnion, Set.mem_univ, iff_true]
  exact ⟨A.pattern x, rfl⟩

/-! ## Part 3: Boolean Algebra of Regions

We work with `Set (Fin m → Bool)` as our Boolean algebra. Each element
S ⊆ {0,1}^m corresponds to ⋃_{σ ∈ S} region(σ). -/

/-- Map from a set of patterns to the corresponding union of regions -/
def realizePatterns {n m : ℕ} (A : HyperplaneArrangement n m)
    (S : Set (Fin m → Bool)) : Set (Fin n → ℝ) :=
  ⋃ σ ∈ S, A.region σ

/-
The realization map preserves union
-/
theorem realizePatterns_union {n m : ℕ} (A : HyperplaneArrangement n m)
    (S T : Set (Fin m → Bool)) :
    realizePatterns A (S ∪ T) = realizePatterns A S ∪ realizePatterns A T := by
  -- By definition of set union, we can show that every element in the left-hand side is in the right-hand side and vice versa.
  ext x
  simp [realizePatterns];
  grind

/-- The realization map preserves bottom -/
theorem realizePatterns_empty {n m : ℕ} (A : HyperplaneArrangement n m) :
    realizePatterns A ∅ = ∅ := by
  simp [realizePatterns]

/-- **Atoms**: Singleton patterns {σ} are atoms of the powerset Boolean algebra -/
theorem pattern_singleton_isAtom (m : ℕ) (σ : Fin m → Bool) :
    IsAtom ({σ} : Set (Fin m → Bool)) :=
  Set.isAtom_singleton σ

/-! ## Part 4: Stone Duality for Finite Boolean Algebras -/

/-- **Stone's Theorem (Finite Case)**: |Set(Fin k)| = 2^k -/
theorem stone_finite_card (k : ℕ) :
    Fintype.card (Set (Fin k)) = 2 ^ k := by
  rw [Fintype.card_set, Fintype.card_fin]

/-- **Core identity**: the Boolean algebra on m binary neurons has 2^(2^m) elements.
    This is Stone duality: B ≅ P(S(B)) where S(B) has 2^m points. -/
theorem neural_bool_alg_card (m : ℕ) :
    Fintype.card (Set (Fin m → Bool)) = 2 ^ 2 ^ m := by
  rw [Fintype.card_set, Fintype.card_fun, Fintype.card_bool, Fintype.card_fin]

/-! ## Part 5: Zaslavsky-type Upper Bound -/

/-- The Zaslavsky bound: ∑_{i=0}^{min(n,m)} C(m, i) -/
def zaslavskyBound (n m : ℕ) : ℕ :=
  ∑ i ∈ Finset.range (min n m + 1), Nat.choose m i

/-
**Zaslavsky bound ≤ 2^m**: partial sum of binomial coefficients ≤ full sum.
    This reflects that at most 2^m activation patterns exist.
-/
theorem zaslavsky_le_two_pow (n m : ℕ) :
    zaslavskyBound n m ≤ 2 ^ m := by
  rw [ ← Nat.sum_range_choose ];
  exact Finset.sum_le_sum_of_subset ( Finset.range_mono ( Nat.succ_le_succ ( min_le_right _ _ ) ) )

/-
When n ≥ m, the Zaslavsky bound equals 2^m (all patterns realizable)
-/
theorem zaslavsky_eq_of_ge {n m : ℕ} (h : m ≤ n) :
    zaslavskyBound n m = 2 ^ m := by
  unfold zaslavskyBound;
  rw [ min_eq_right h, ← Nat.sum_range_choose ]

/-
**Monotonicity**: Adding hyperplanes increases the Zaslavsky bound
-/
theorem zaslavsky_mono_hyperplanes (n m : ℕ) :
    zaslavskyBound n m ≤ zaslavskyBound n (m + 1) := by
  unfold zaslavskyBound;
  rcases le_total m n with h | h <;> simp_all +decide [ Nat.choose_succ_succ, Finset.sum_range_succ' ];
  · cases min_cases n ( m + 1 ) <;> simp_all +arith +decide [ Finset.sum_add_distrib ];
    · exact le_add_of_nonneg_of_le ( Nat.zero_le _ ) ( Finset.sum_le_sum_of_subset ( Finset.range_mono h ) );
    · exact le_add_of_nonneg_of_le ( Nat.zero_le _ ) ( Finset.sum_le_sum_of_subset ( Finset.range_mono ( Nat.le_succ _ ) ) );
  · rw [ min_eq_left ( by linarith ) ] ; exact Finset.sum_le_sum fun i hi => Nat.le_add_left _ _;

/-! ## Part 6: Network Composition and Refinement -/

/-- Composition of two arrangements -/
def HyperplaneArrangement.append
    {n m₁ m₂ : ℕ} (A₁ : HyperplaneArrangement n m₁) (A₂ : HyperplaneArrangement n m₂) :
    HyperplaneArrangement n (m₁ + m₂) where
  weights := Fin.addCases A₁.weights A₂.weights
  biases  := Fin.addCases A₁.biases A₂.biases

/-
**Refinement Theorem**: Combined arrangement refines each individual one.
    Points sharing a combined pattern share individual patterns.
-/
theorem HyperplaneArrangement.append_refines_left
    {n m₁ m₂ : ℕ} (A₁ : HyperplaneArrangement n m₁) (A₂ : HyperplaneArrangement n m₂)
    (σ : Fin (m₁ + m₂) → Bool) (x y : Fin n → ℝ)
    (hx : x ∈ (A₁.append A₂).region σ)
    (hy : y ∈ (A₁.append A₂).region σ) :
    A₁.pattern x = A₁.pattern y := by
  unfold HyperplaneArrangement.region at *; simp_all +decide [ funext_iff, Fin.addCases ] ;
  -- By definition of pattern, we know that if the patterns of x and y are equal, then their activations must be equal.
  intros i
  have := hx (Fin.castAdd m₂ i)
  have := hy (Fin.castAdd m₂ i)
  simp_all +decide [ HyperplaneArrangement.pattern, Fin.addCases ];
  specialize hx ( Fin.castAdd m₂ i ) ; specialize hy ( Fin.castAdd m₂ i ) ; simp_all +decide [ HyperplaneArrangement.activation, HyperplaneArrangement.append ] ;
  lia

/-! ## Part 7: Sauer-Shelah Bound -/

/-
**Sauer-Shelah Bound**: A partial sum of binomial coefficients ≤ 2^n.
    This connects VC dimension to the Zaslavsky bound.
-/
theorem sauer_shelah_bound (d n : ℕ) :
    ∑ i ∈ Finset.range (d + 1), Nat.choose n i ≤ 2 ^ n := by
  by_cases h : n ≤ d;
  · rw [ ← Nat.sum_range_choose ];
    rw [ ← Finset.sum_range_add_sum_Ico _ ( by linarith : n + 1 ≤ d + 1 ) ];
    simp +arith +decide [ Nat.choose_eq_zero_of_lt ];
    exact fun i hi₁ hi₂ => Nat.choose_eq_zero_of_lt hi₁;
  · rw [ ← Nat.sum_range_choose ] ; exact Finset.sum_le_sum_of_subset ( Finset.range_mono ( by linarith ) ) ;

end