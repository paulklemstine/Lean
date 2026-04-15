/-! # CatalogBuild.Computation.Oracles.OracleLaplacian

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 37
-/

import Mathlib

noncomputable section

/-- A projection on a module: P² = P. -/
structure OracleProjection (R M : Type*) [CommRing R] [AddCommGroup M] [Module R M] where
  toLinearMap : M →ₗ[R] M
  idempotent : toLinearMap ∘ₗ toLinearMap = toLinearMap

/-- The anti-projection: Q = id - P. -/

def OracleProjection.anti (P : OracleProjection R M) : M →ₗ[R] M :=
  LinearMap.id - P.toLinearMap

/-
PROBLEM
The anti-projection is idempotent: (I-P)² = I-P.

PROVIDED SOLUTION
Expand P.anti = id - P, then compute (id - P) ∘ (id - P) = id - 2P + P² = id - 2P + P = id - P, using P.idempotent.
-/

theorem anti_idempotent (P : OracleProjection R M) :
    P.anti ∘ₗ P.anti = P.anti := by
      ext x; exact (by
      simp +decide [ OracleProjection.anti ];
      exact sub_eq_zero_of_eq ( congr_arg ( fun f => f x ) P.idempotent.symm ));

/-
PROBLEM
**Dialectical Vanishing**: P(I-P) + (I-P)P = 0 for projections.

PROVIDED SOLUTION
Expand P.anti = id - P. Then P(id-P) + (id-P)P = P - P² + P - P² = 2P - 2P² = 2P - 2P = 0, using P.idempotent.
-/

theorem dialectical_sq_zero (P : OracleProjection R M) :
    P.toLinearMap ∘ₗ P.anti + P.anti ∘ₗ P.toLinearMap = 0 := by
      -- By definition of anti, we have P.anti = id - P.toLinearMap.
      have h_anti : P.anti = LinearMap.id - P.toLinearMap := by
        rfl;
      simp +decide [ h_anti, LinearMap.ext_iff ];
      intro x; rw [ show P.toLinearMap ( P.toLinearMap x ) = P.toLinearMap x from by simpa using LinearMap.congr_fun P.idempotent x ] ; abel_nf;

/-
PROBLEM
**Oracle Uncertainty**: Fixed points of both P₁ and P₂ kill their commutator.

PROVIDED SOLUTION
Just expand the linear maps and use h₁ and h₂ to simplify P₁(P₂(x)) = P₁(x) = x and P₂(P₁(x)) = P₂(x) = x, so the difference is x - x = 0.
-/

theorem oracle_uncertainty (P₁ P₂ : OracleProjection R M) (x : M)
    (h₁ : P₁.toLinearMap x = x) (h₂ : P₂.toLinearMap x = x) :
    (P₁.toLinearMap ∘ₗ P₂.toLinearMap - P₂.toLinearMap ∘ₗ P₁.toLinearMap) x = 0 := by
      aesop

/-! ## §2: Oracle on Finite Types — Boundaries -/

/-- An oracle on a finite type. -/

def FinOracle (n : ℕ) := Fin n → Bool

/-- Count transitions on a path graph (adjacent positions with different values). -/

def oracleTransitions (n : ℕ) (O : FinOracle (n + 1)) : ℕ :=
  ((Finset.univ : Finset (Fin n)).filter (fun i : Fin n =>
    O ⟨i.val, by omega⟩ != O ⟨i.val + 1, by omega⟩)).card

/-
PROBLEM
A constant oracle has zero transitions.

PROVIDED SOLUTION
The filter condition O ⟨i, _⟩ != O ⟨i+1, _⟩ is false for constant O since both return b, so b != b is false. The filter is empty, card is 0.
-/

theorem constant_oracle_no_transitions (n : ℕ) (b : Bool) :
    oracleTransitions n (fun (_ : Fin (n + 1)) => b) = 0 := by
      unfold oracleTransitions; aesop;

/-
PROBLEM
The number of transitions is at most n.

PROVIDED SOLUTION
The filtered set is a subset of Finset.univ (Fin n), which has cardinality n. Use card_filter_le.
-/

theorem oracle_transitions_le (n : ℕ) (O : FinOracle (n + 1)) :
    oracleTransitions n O ≤ n := by
      exact le_trans ( Finset.card_filter_le _ _ ) ( by norm_num )

/-- The anti-oracle. -/

def FinOracle.anti (O : FinOracle n) : FinOracle n := fun i => !O i

/-
PROBLEM
**Anti-Oracle Boundary Symmetry**: Anti-oracle has the same boundary.

PROVIDED SOLUTION
For FinOracle.anti, (!O i) != (!O j) iff O i != O j, since negation is injective on Bool. So the filter conditions are equivalent.
-/

theorem anti_oracle_same_boundary (n : ℕ) (O : FinOracle (n + 1)) :
    oracleTransitions n O.anti = oracleTransitions n O := by
      -- The set of indices where the anti-oracle changes its value is the same as the set of indices where the oracle changes its value.
      have h_set_eq : {i : Fin n | O.anti ⟨i.val, by omega⟩ != O.anti ⟨i.val + 1, by omega⟩} = {i : Fin n | O ⟨i.val, by omega⟩ != O ⟨i.val + 1, by omega⟩} := by
        unfold FinOracle.anti; aesop;
      convert congr_arg Finset.card ( Finset.ext fun x => ?_ ) using 2 ; simp_all +decide [ Finset.ext_iff, Set.ext_iff ]

/-- The XOR oracle. -/

def FinOracle.xor (O₁ O₂ : FinOracle n) : FinOracle n := fun i => O₁ i ^^ O₂ i

/-! ## §3: Oracle Thermodynamics -/

/-- Oracle energy = number of transitions. -/

def oracleEnergy (n : ℕ) (O : FinOracle (n + 1)) : ℕ := oracleTransitions n O

/-- Ground state = zero energy. -/

def isGroundState (n : ℕ) (O : FinOracle (n + 1)) : Prop := oracleEnergy n O = 0

/-- **Energy Symmetry**: Oracle and anti-oracle have equal energy. -/

theorem energy_anti_symmetric (n : ℕ) (O : FinOracle (n + 1)) :
    oracleEnergy n O.anti = oracleEnergy n O :=
  anti_oracle_same_boundary n O

/-- **Ground State Duality**: If O is ground state, so is ¬O. -/

theorem ground_state_anti (n : ℕ) (O : FinOracle (n + 1))
    (h : isGroundState n O) : isGroundState n O.anti := by
  unfold isGroundState at *; rw [energy_anti_symmetric]; exact h

/-! ## §4: Anti-Meta Oracle -/

/-- Oracle with confidence levels. -/

structure ConfidentOracle (n : ℕ) where
  answer : Fin n → Bool
  confidence : Fin n → ℕ

/-- Blind spot size at a given threshold. -/

def blindSpotSize (O : ConfidentOracle n) (threshold : ℕ) : ℕ :=
  ((Finset.univ : Finset (Fin n)).filter (fun i => O.confidence i < threshold)).card

/-
PROBLEM
**Anti-Meta Oracle Monotonicity**

PROVIDED SOLUTION
If t₁ ≤ t₂ then {i | confidence i < t₁} ⊆ {i | confidence i < t₂}, so card is monotone.
-/

theorem blind_spot_monotone (O : ConfidentOracle n) {t₁ t₂ : ℕ} (h : t₁ ≤ t₂) :
    blindSpotSize O t₁ ≤ blindSpotSize O t₂ := by
      exact Finset.card_le_card fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_univ _, lt_of_lt_of_le ( Finset.mem_filter.mp hx |>.2 ) h ⟩

/-
PROBLEM
**Complete Blindness**

PROVIDED SOLUTION
Since ∀ i, confidence i < bound, the filter equals univ, so card = card_univ = n.
-/

theorem total_blindness (O : ConfidentOracle n) (bound : ℕ)
    (hmax : ∀ i, O.confidence i < bound) :
    blindSpotSize O bound = n := by
      unfold blindSpotSize; aesop;

/-
PROBLEM
**Oracle Duality Partition**: blind + confident = n

PROVIDED SOLUTION
Use Finset.filter_card_add_filter_neg_card_eq_card on univ with predicate (confidence i < threshold). The result equals card univ = n.
-/

theorem oracle_duality_partition (O : ConfidentOracle n) (threshold : ℕ) :
    blindSpotSize O threshold +
    ((Finset.univ : Finset (Fin n)).filter (fun i => ¬(O.confidence i < threshold))).card = n := by
  convert Finset.card_add_card_compl ( Finset.filter ( fun i => O.confidence i < threshold ) Finset.univ ) using 1 ; aesop;
  norm_num

/-! ## §5: Oracle Fixed Points -/

/-- Oracle iteration via self-reference map φ. -/

def oracleIterate (O : FinOracle n) (φ : Fin n → Fin n) : ℕ → FinOracle n
  | 0 => O
  | k + 1 => fun i => oracleIterate O φ k (φ i)

/-- Fixed-point oracle: O = O ∘ φ. -/

def isOracleFixedPoint (O : FinOracle n) (φ : Fin n → Fin n) : Prop :=
  ∀ i, O i = O (φ i)

/-- **Fixed-Point Stability**: Fixed points are stable under all iterations. -/

theorem fixed_point_stable (O : FinOracle n) (φ : Fin n → Fin n)
    (h : isOracleFixedPoint O φ) (k : ℕ) :
    oracleIterate O φ k = O := by
  induction k with
  | zero => rfl
  | succ k ih =>
    funext i
    simp only [oracleIterate]
    rw [ih]
    exact (h i).symm

/-! ## §6: Oracle Information Geometry -/

/-- Hamming distance between oracles. -/

def oracleHamming (O₁ O₂ : FinOracle n) : ℕ :=
  ((Finset.univ : Finset (Fin n)).filter (fun i => O₁ i != O₂ i)).card

/-
PROBLEM
Hamming distance is symmetric.

PROVIDED SOLUTION
The filter condition O₁ i != O₂ i is the same as O₂ i != O₁ i since bne is symmetric.
-/

theorem hamming_symm (O₁ O₂ : FinOracle n) :
    oracleHamming O₁ O₂ = oracleHamming O₂ O₁ := by
      -- The condition O₁ i != O₂ i is symmetric, so the sets of indices where they differ are the same.
      have h_symm : {i : Fin n | O₁ i != O₂ i} = {i : Fin n | O₂ i != O₁ i} := by
        grind +ring;
      exact congr_arg Finset.card ( Finset.ext fun x => by simpa using Set.ext_iff.mp h_symm x )

/-
PROBLEM
Hamming distance from self is zero.

PROVIDED SOLUTION
O i != O i is always false, so the filter is empty, card is 0.
-/

theorem hamming_self (O : FinOracle n) : oracleHamming O O = 0 := by
  unfold oracleHamming; aesop;

/-
PROBLEM
**Oracle-Anti Maximal Distance**: d(O, ¬O) = n.

PROVIDED SOLUTION
O i != !O i is always true (a Bool is never equal to its negation), so the filter equals univ, card = n.
-/

theorem hamming_anti_maximal (O : FinOracle n) :
    oracleHamming O O.anti = n := by
      unfold FinOracle.anti oracleHamming; aesop;

/-
PROBLEM
**Hamming Triangle Inequality**

PROVIDED SOLUTION
If O₁ i ≠ O₃ i, then either O₁ i ≠ O₂ i or O₂ i ≠ O₃ i (by Bool transitivity). So the filter set for d(O₁,O₃) is a subset of the union of the filter sets for d(O₁,O₂) and d(O₂,O₃). Then use card_le_card and card_union_le.
-/

theorem hamming_triangle (O₁ O₂ O₃ : FinOracle n) :
    oracleHamming O₁ O₃ ≤ oracleHamming O₁ O₂ + oracleHamming O₂ O₃ := by
      unfold oracleHamming;
      rw [ ← Finset.card_union_add_card_inter ];
      exact le_add_right ( Finset.card_le_card fun x hx => by by_cases h₁ : O₁ x = O₂ x <;> by_cases h₂ : O₂ x = O₃ x <;> aesop )

/-! ## §7: Oracle Tensor Products -/

/-- AND-tensor. -/

def oracleTensorAnd (O₁ : FinOracle n₁) (O₂ : FinOracle n₂) :
    Fin n₁ → Fin n₂ → Bool := fun i j => O₁ i && O₂ j

/-- OR-tensor. -/

def oracleTensorOr (O₁ : FinOracle n₁) (O₂ : FinOracle n₂) :
    Fin n₁ → Fin n₂ → Bool := fun i j => O₁ i || O₂ j

/-
PROBLEM
**De Morgan for Oracle Tensors**

PROVIDED SOLUTION
Unfold definitions. !(O₁ i && O₂ j) = (!O₁ i || !O₂ j) by Bool.not_and or Bool De Morgan. The right side is O₁.anti i || O₂.anti j = !O₁ i || !O₂ j. Use cases on O₁ i and O₂ j.
-/

theorem tensor_de_morgan (O₁ : FinOracle n₁) (O₂ : FinOracle n₂)
    (i : Fin n₁) (j : Fin n₂) :
    !(oracleTensorAnd O₁ O₂ i j) = oracleTensorOr O₁.anti O₂.anti i j := by
      unfold oracleTensorAnd oracleTensorOr; simp +decide [ FinOracle.anti ] ; cases O₁ i <;> cases O₂ j <;> simp +decide [ * ] ;

/-- True-count of an oracle. -/

def oracleTrueCount (O : FinOracle n) : ℕ :=
  ((Finset.univ : Finset (Fin n)).filter (fun i => O i = true)).card

/-
PROBLEM
**Anti-Oracle True Count**: |O| + |¬O| = n.

PROVIDED SOLUTION
Use Finset.filter_card_add_filter_neg_card_eq_card with predicate (O i = true). The complement filter is {i | O i ≠ true} = {i | O i = false} = {i | !O i = true} = {i | O.anti i = true}. Card of univ is n.
-/

theorem true_count_complement (O : FinOracle n) :
    oracleTrueCount O + oracleTrueCount O.anti = n := by
      unfold oracleTrueCount;
      unfold FinOracle.anti; rw [ Finset.card_filter, Finset.card_filter ] ; rw [ ← Finset.sum_add_distrib ] ; rw [ Finset.sum_congr rfl fun _ _ => by aesop ] ; aesop;

/-! ## §8: Oracle Spin / Magnetization -/

/-- Oracle → spin: true → 1, false → -1. -/

def oracleToSpin (O : FinOracle n) : Fin n → ℤ :=
  fun i => if O i then 1 else -1

/-- Total magnetization. -/

def oracleMagnetization (O : FinOracle n) : ℤ :=
  ∑ i : Fin n, oracleToSpin O i

/-
PROBLEM
**Anti-Magnetization**: Anti-oracle has opposite magnetization.

PROVIDED SOLUTION
Expand definitions. oracleToSpin O.anti i = if !O i then 1 else -1. Cases on O i: if true, !true = false, so spin is -1 = -(1); if false, !false = true, so spin is 1 = -(-1). So each term negates. Use Finset.sum_neg_distrib.
-/

theorem anti_magnetization (O : FinOracle n) :
    oracleMagnetization O.anti = -oracleMagnetization O := by
      unfold oracleMagnetization;
      unfold oracleToSpin;
      rw [ ← Finset.sum_neg_distrib ] ; congr ; ext i ; unfold FinOracle.anti ; aesop


end
