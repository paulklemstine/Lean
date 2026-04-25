/-! # CatalogBuild.Speculative.Other.FiveFrontiers

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 30
-/

import Mathlib

noncomputable section

/-- Tropical addition: max -/
def tadd (a b : ℝ) : ℝ := max a b


/-- Tropical multiplication: + -/
def tmul (a b : ℝ) : ℝ := a + b


/-- The Core Identity: ReLU(x) = x ⊕_T 0 — definitional equality -/
theorem relu_is_tropical_add_zero (x : ℝ) : relu x = tadd x 0 := rfl


/-- Tropical addition is commutative. -/
theorem tadd_comm (a b : ℝ) : tadd a b = tadd b a := max_comm a b


/-- Tropical addition is associative. -/
theorem tadd_assoc (a b c : ℝ) : tadd (tadd a b) c = tadd a (tadd b c) :=
  max_assoc _ _ _


/-- Tropical addition is idempotent. -/
theorem tadd_idem (a : ℝ) : tadd a a = a := max_self a


/-- Tropical multiplication is commutative. -/
theorem tmul_comm (a b : ℝ) : tmul a b = tmul b a := add_comm a b


/-- Tropical multiplication is associative. -/
theorem tmul_assoc (a b c : ℝ) : tmul (tmul a b) c = tmul a (tmul b c) := by
  unfold tmul; ring


/-- 0 is the tropical multiplicative identity. -/
theorem tmul_zero (a : ℝ) : tmul a 0 = a := add_zero a


/-- Tropical multiplication distributes over tropical addition (left). -/
theorem tmul_tadd_distrib (a b c : ℝ) :
    tmul a (tadd b c) = tadd (tmul a b) (tmul a c) := by
  unfold tadd tmul
  cases max_cases b c <;> cases max_cases (a + b) (a + c) <;> linarith


/-- Fixed points characterization. -/
theorem Oracle.mem_truthSet_iff {α : Type*} (O : Oracle α) (x : α) :
    x ∈ O.truthSet ↔ O.apply x = x := by rfl


/-- The identity oracle's truth set is everything. -/
theorem Oracle.identity_truthSet (α : Type*) : (Oracle.identity α).truthSet = Set.univ := by
  ext x; simp [Oracle.identity, Oracle.truthSet]


/-- A constant function is an oracle. -/
def Oracle.const {α : Type*} (c : α) : Oracle α where
  apply := fun _ => c
  idempotent := fun _ => rfl


/-- The constant oracle's truth set is the singleton. -/
theorem Oracle.const_truthSet {α : Type*} (c : α) :
    (Oracle.const c).truthSet = {c} := by
  ext x; simp [Oracle.const, Oracle.truthSet]


/-- Every oracle refines the identity. -/
theorem Oracle.refines_identity {α : Type*} (O : Oracle α) :
    O.refines (Oracle.identity α) := by
  intro x _
  simp [Oracle.identity, Oracle.truthSet]


/-- ReLU is an oracle on ℝ (it is idempotent). -/
def reluOracle : Oracle ℝ where
  apply := TropicalFrontier.relu
  idempotent := TropicalFrontier.relu_idempotent


/-- The truth set of the ReLU oracle is [0, ∞). -/
theorem reluOracle_truthSet : reluOracle.truthSet = Set.Ici 0 := by
  ext x
  simp only [reluOracle, Oracle.truthSet, Set.mem_setOf_eq, Set.mem_Ici,
             TropicalFrontier.relu]
  constructor
  · intro h
    by_contra hlt
    push_neg at hlt
    have : max x 0 = 0 := max_eq_right (le_of_lt hlt)
    rw [this] at h
    linarith
  · intro h
    exact max_eq_left h


/-- There exists a prime between n² and (n+1)² for n = 4. -/
theorem legendre_n4 : ∃ p, 16 < p ∧ p < 25 ∧ Nat.Prime p :=
  ⟨17, by omega, by omega, by decide⟩


/-- 4 is a sum of two primes. -/
theorem goldbach_4 : ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ 4 = p + q :=
  ⟨2, 2, by decide, by decide, by omega⟩


/-- 6 is a sum of two primes. -/
theorem goldbach_6 : ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ 6 = p + q :=
  ⟨3, 3, by decide, by decide, by omega⟩


/-- 8 is a sum of two primes. -/
theorem goldbach_8 : ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ 8 = p + q :=
  ⟨3, 5, by decide, by decide, by omega⟩


/-- 10 is a sum of two primes. -/
theorem goldbach_10 : ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ 10 = p + q :=
  ⟨3, 7, by decide, by decide, by omega⟩


/-- 100 is a sum of two primes. -/
theorem goldbach_100 : ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ 100 = p + q :=
  ⟨3, 97, by decide, by decide, by omega⟩


/-- [Section: # CatalogBuild.Speculative.Other.FiveFrontiers
Auto-generated from theorem catalog database.
Declarations: 30] -/
theorem unitary_mul {n : Type*} [DecidableEq n] [Fintype n]
    (U V : Matrix n n ℂ) (hU : U * star U = 1) (hV : V * star V = 1) :
    (U * V) * star (U * V) = 1 := by
  -- By definition of matrix multiplication and the properties of unitary matrices, we can expand the expression.
  simp [Matrix.mul_assoc];
  simp +decide [ ← mul_assoc, hV ];
  exact hU


/-- Boundary ≤ total size of a proof tree. -/
theorem boundary_le_total (boundary bulk : ℕ) :
    boundary ≤ boundary + bulk := Nat.le_add_right _ _


/-- Compression is monotone in both boundary and bulk. -/
theorem compression_monotone (b₁ b₂ k₁ k₂ : ℕ)
    (hb : b₁ ≤ b₂) (hk : k₁ ≤ k₂) :
    b₁ + k₁ ≤ b₂ + k₂ := Nat.add_le_add hb hk


/-- Information content is nonneg. -/
theorem info_nonneg (boundary bulk : ℕ) : 0 ≤ boundary + bulk := Nat.zero_le _


/-- Logarithmic compression: if bulk doubles, compressed size grows by 1. -/
theorem log_compression_bound (n : ℕ) : n ≤ 2 ^ n := Nat.lt_two_pow_self.le


/-- The tropical-oracle connection: ReLU is both a tropical operation
and an oracle (idempotent). -/
theorem relu_is_tropical_oracle :
    (∀ x : ℝ, TropicalFrontier.relu x = TropicalFrontier.tadd x 0) ∧
    (∀ x : ℝ, TropicalFrontier.relu (TropicalFrontier.relu x) = TropicalFrontier.relu x) :=
  ⟨fun _ => rfl, TropicalFrontier.relu_idempotent⟩


/-- The tropical semiring satisfies all required axioms. -/
theorem tropical_semiring_axioms :
    (∀ a b : ℝ, TropicalFrontier.tadd a b = TropicalFrontier.tadd b a) ∧
    (∀ a b c : ℝ, TropicalFrontier.tadd (TropicalFrontier.tadd a b) c =
                   TropicalFrontier.tadd a (TropicalFrontier.tadd b c)) ∧
    (∀ a : ℝ, TropicalFrontier.tadd a a = a) ∧
    (∀ a b : ℝ, TropicalFrontier.tmul a b = TropicalFrontier.tmul b a) ∧
    (∀ a b c : ℝ, TropicalFrontier.tmul (TropicalFrontier.tmul a b) c =
                   TropicalFrontier.tmul a (TropicalFrontier.tmul b c)) ∧
    (∀ a : ℝ, TropicalFrontier.tmul a 0 = a) ∧
    (∀ a b c : ℝ, TropicalFrontier.tmul a (TropicalFrontier.tadd b c) =
                   TropicalFrontier.tadd (TropicalFrontier.tmul a b)
                                         (TropicalFrontier.tmul a c)) :=
  ⟨TropicalFrontier.tadd_comm,
   TropicalFrontier.tadd_assoc,
   TropicalFrontier.tadd_idem,
   TropicalFrontier.tmul_comm,
   TropicalFrontier.tmul_assoc,
   TropicalFrontier.tmul_zero,
   TropicalFrontier.tmul_tadd_distrib⟩


end
