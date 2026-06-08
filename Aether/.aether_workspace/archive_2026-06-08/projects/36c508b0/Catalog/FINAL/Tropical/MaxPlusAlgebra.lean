/-
  # Max-Plus (Tropical) Algebra: Foundations for Post-Idempotent Cryptography

  This file establishes the algebraic foundations of the max-plus semiring
  and tropical matrix-vector products, forming the basis for one-way
  function candidates in post-idempotent cryptography.

  Bridge: connects idempotent algebra → combinatorial optimization → cryptography

  Key results:
  - The max-plus semiring (ℤ, max, +) with its idempotent addition law
  - Tropical matrix-vector product and its algebraic properties
  - Non-invertibility of idempotent addition (fundamental obstruction)
  - Max operation lacks a left inverse (one-way property seed)
-/
import Mathlib

open Finset Matrix

namespace TropicalAlgebra

/-! ## Section 1: Max-Plus Operations and Idempotent Laws -/

/-- The max-plus "addition" on integers: tropical sum is classical maximum.
    This operation is idempotent: a ⊕ a = a, the cornerstone of tropical algebra. -/
abbrev tropicalAdd (a b : ℤ) : ℤ := max a b

/-- The max-plus "multiplication" on integers: tropical product is classical sum. -/
abbrev tropicalMul (a b : ℤ) : ℤ := a + b

/-- Idempotent law for tropical addition: the defining property that separates
    tropical algebra from classical algebra. Every element is its own additive
    idempotent, which has profound consequences for invertibility and quantum
    computation.
    Bridge: connects lattice theory (idempotent semilattices) to tropical geometry. -/
theorem tropical_add_idempotent (a : ℤ) : tropicalAdd a a = a := max_self a

/-- Commutativity of tropical addition. -/
theorem tropical_add_comm (a b : ℤ) : tropicalAdd a b = tropicalAdd b a := max_comm a b

/-- Associativity of tropical addition. -/
theorem tropical_add_assoc (a b c : ℤ) :
    tropicalAdd (tropicalAdd a b) c = tropicalAdd a (tropicalAdd b c) := max_assoc a b c

/-- Distributivity: tropical multiplication distributes over tropical addition.
    max(a+c, b+c) = max(a,b) + c.
    Bridge: connects semiring theory to max-plus optimization. -/
theorem tropical_mul_distrib_add (a b c : ℤ) :
    tropicalMul (tropicalAdd a b) c = tropicalAdd (tropicalMul a c) (tropicalMul b c) := by
  simp only [tropicalMul, tropicalAdd]; omega

/-- Left distributivity of tropical multiplication over tropical addition. -/
theorem tropical_mul_distrib_add_left (a b c : ℤ) :
    tropicalMul c (tropicalAdd a b) = tropicalAdd (tropicalMul c a) (tropicalMul c b) := by
  simp only [tropicalMul, tropicalAdd]; omega

/-- Zero element for tropical multiplication is the classical zero. -/
theorem tropical_mul_zero (a : ℤ) : tropicalMul a 0 = a := add_zero a

/-- Tropical addition absorbs smaller terms: if a ≤ b then max(a, b) = b.
    This "information loss" is what makes inversion hard. -/
theorem tropical_add_absorbs_le {a b : ℤ} (h : a ≤ b) : tropicalAdd a b = b :=
  max_eq_right h

/-- Tropical addition is bounded below by both arguments. -/
theorem tropical_add_ge_left (a b : ℤ) : a ≤ tropicalAdd a b := le_max_left a b
theorem tropical_add_ge_right (a b : ℤ) : b ≤ tropicalAdd a b := le_max_right a b

/-! ## Section 2: Tropical Matrix-Vector Product -/

/-- Tropical matrix-vector product: (A ⊗ x)[i] = max_j (A[i,j] + x[j]).
    This is the max-plus analogue of standard matrix-vector multiplication.
    Forward computation: O(m × n) tropical operations.
    Bridge: connects linear algebra to max-plus optimization. -/
noncomputable def tropicalMVP {m n : ℕ} [NeZero n]
    (A : Matrix (Fin m) (Fin n) ℤ) (x : Fin n → ℤ) : Fin m → ℤ :=
  fun i => Finset.univ.sup' univ_nonempty (fun j => A i j + x j)

/-- Tropical MVP is monotone in x: if x ≤ y componentwise, then A ⊗ x ≤ A ⊗ y.
    Bridge: connects order theory to tropical linear algebra. -/
theorem tropicalMVP_mono {m n : ℕ} [NeZero n] (A : Matrix (Fin m) (Fin n) ℤ)
    {x y : Fin n → ℤ} (h : ∀ j, x j ≤ y j) :
    ∀ i, tropicalMVP A x i ≤ tropicalMVP A y i := by
  intro i
  apply Finset.sup'_le univ_nonempty
  intro j _
  calc A i j + x j ≤ A i j + y j := by linarith [h j]
    _ ≤ tropicalMVP A y i := Finset.le_sup' (fun j => A i j + y j) (mem_univ j)

/-- Each term contributes a lower bound to the tropical MVP.
    For any column j, A[i,j] + x[j] ≤ (A ⊗ x)[i]. -/
theorem tropicalMVP_entry_le {m n : ℕ} [NeZero n] (A : Matrix (Fin m) (Fin n) ℤ)
    (x : Fin n → ℤ) (i : Fin m) (j : Fin n) :
    A i j + x j ≤ tropicalMVP A x i :=
  Finset.le_sup' (fun j => A i j + x j) (mem_univ j)

/-- The tropical MVP of the zero vector equals the row maximum. -/
theorem tropicalMVP_zero_vec {m n : ℕ} [NeZero n] (A : Matrix (Fin m) (Fin n) ℤ) (i : Fin m) :
    tropicalMVP A (fun _ => 0) i = Finset.univ.sup' univ_nonempty (fun j => A i j) := by
  simp [tropicalMVP]

/-! ## Section 3: One-Way Function Structures -/

/-- A tropical one-way function candidate based on max-plus MVP.
    Bridge: connects tropical linear algebra to cryptographic hardness.
    - Public parameter: matrix A ∈ ℤ^{m×n}
    - Secret: vector x ∈ ℤ^n
    - Image: A ⊗ x ∈ ℤ^m
    Forward computation: O(m × n) additions and comparisons. -/
structure TropicalOWFInstance (m n : ℕ) where
  /-- The public matrix parameter -/
  publicMatrix : Matrix (Fin m) (Fin n) ℤ
  /-- Security parameter (bit length) -/
  securityBits : ℕ

/-- Tropical LP feasibility: ∃ x, A ⊗ x ≤ b (componentwise).
    Bridge: connects linear programming to tropical geometry.
    This is the decision problem whose hardness underlies the OWF security. -/
structure TropicalLPInstance (m n : ℕ) where
  /-- Constraint matrix -/
  constraintMatrix : Matrix (Fin m) (Fin n) ℤ
  /-- Right-hand side vector -/
  rhs : Fin m → ℤ

/-- Feasibility of a tropical LP instance. -/
def TropicalLPInstance.Feasible {m n : ℕ} [NeZero n] (lp : TropicalLPInstance m n) : Prop :=
  ∃ x : Fin n → ℤ, ∀ i : Fin m, tropicalMVP lp.constraintMatrix x i ≤ lp.rhs i

/-- A feasibility certificate for a tropical LP.
    Bridge: connects proof theory (constructive witnesses) to optimization. -/
structure TropicalFeasibilityCert {m n : ℕ} [NeZero n] (lp : TropicalLPInstance m n) where
  /-- The witness vector -/
  solution : Fin n → ℤ
  /-- Proof that the witness satisfies all constraints -/
  satisfies : ∀ i : Fin m, tropicalMVP lp.constraintMatrix solution i ≤ lp.rhs i

/-- A certificate implies feasibility. -/
theorem cert_implies_feasible {m n : ℕ} [NeZero n] (lp : TropicalLPInstance m n)
    (cert : TropicalFeasibilityCert lp) : lp.Feasible :=
  ⟨cert.solution, cert.satisfies⟩

/-- Feasibility is equivalent to existence of a certificate. -/
theorem feasible_iff_cert {m n : ℕ} [NeZero n] (lp : TropicalLPInstance m n) :
    lp.Feasible ↔ Nonempty (TropicalFeasibilityCert lp) := by
  constructor
  · intro ⟨x, hx⟩; exact ⟨⟨x, hx⟩⟩
  · intro ⟨cert⟩; exact cert_implies_feasible lp cert

/-- OWF exact inversion implies LP feasibility: equality is stronger than inequality.
    Bridge: connects one-way function theory to tropical LP. -/
theorem owf_inversion_implies_lp_feasible {m n : ℕ} [NeZero n]
    (A : Matrix (Fin m) (Fin n) ℤ) (b : Fin m → ℤ)
    (h : ∃ x, tropicalMVP A x = b) :
    (TropicalLPInstance.mk A b).Feasible := by
  obtain ⟨x, hx⟩ := h
  exact ⟨x, fun i => le_of_eq (congr_fun hx i)⟩

/-- Tropical LP feasibility is monotone in the RHS. -/
theorem tropical_lp_feasible_mono {m n : ℕ} [NeZero n]
    (A : Matrix (Fin m) (Fin n) ℤ) (b₁ b₂ : Fin m → ℤ)
    (hb : ∀ i, b₁ i ≤ b₂ i)
    (hfeas : (TropicalLPInstance.mk A b₁).Feasible) :
    (TropicalLPInstance.mk A b₂).Feasible := by
  obtain ⟨x, hx⟩ := hfeas
  exact ⟨x, fun i => le_trans (hx i) (hb i)⟩

/-! ## Section 4: Non-Invertibility Results -/

/-- The max operation has no left inverse: there is no function `inv` such that
    `inv (max x y) y = x` for all x, y.
    This is the algebraic heart of the one-way property.
    Bridge: connects lattice-theoretic non-invertibility to cryptographic hardness. -/
theorem max_has_no_left_inverse :
    ¬∃ (inv : ℤ → ℤ → ℤ), ∀ x y : ℤ, inv (max x y) y = x := by
  intro ⟨inv, hinv⟩
  have h1 : inv 1 1 = 0 := by have := hinv 0 1; simp at this; exact this
  have h2 : inv 1 1 = 1 := by have := hinv 1 1; simp at this; exact this
  omega

/-- Max is non-injective in its first argument when the second argument
    is large enough: max(a, c) = max(b, c) does not imply a = b. -/
theorem max_non_injective_first_arg :
    ¬∀ (a b c : ℤ), max a c = max b c → a = b := by
  push_neg; exact ⟨0, 1, 2, by omega, by omega⟩

/-- Max-plus addition loses information: knowing max(a, b) = b does not
    determine a (only that a ≤ b). -/
theorem max_information_loss (b : ℤ) :
    ∃ a₁ a₂ : ℤ, a₁ ≠ a₂ ∧ max a₁ b = b ∧ max a₂ b = b := by
  exact ⟨b - 1, b - 2, by omega, by omega, by omega⟩

/-! ## Section 5: Idempotent Semiring Abstraction -/

/-- A typeclass for idempotent addition: a + a = a for all elements.
    This captures the essential algebraic property of tropical (max-plus) addition.
    Bridge: connects abstract algebra to tropical geometry and lattice theory. -/
class IdempotentAdd (α : Type*) [Add α] : Prop where
  /-- Every element is additively idempotent -/
  add_idem : ∀ a : α, a + a = a

/-- In any additive monoid with idempotent addition and additive inverses,
    every element equals zero.
    Bridge: connects idempotent algebra to quantum computing (no unitary representation). -/
theorem idempotent_no_additive_inverse {M : Type*} [AddMonoid M]
    [IdempotentAdd M] (a b : M) (h : a + b = 0) : a = 0 := by
  have hidem := IdempotentAdd.add_idem a
  calc a = a + 0 := (add_zero a).symm
    _ = a + (a + b) := by rw [h]
    _ = (a + a) + b := (add_assoc a a b).symm
    _ = a + b := by rw [hidem]
    _ = 0 := h

/-- An additive group with idempotent addition is trivial.
    Bridge: connects group theory to tropical algebra impossibility results. -/
theorem idempotent_group_trivial {G : Type*} [AddGroup G]
    (hidem : ∀ a : G, a + a = a) (a : G) : a = 0 := by
  have h := hidem a
  have : a + a - a = a - a := congrArg (· - a) h
  simp at this
  exact this

/-- In any semiring where addition is idempotent and additive inverses exist,
    every element is zero.
    Bridge: connects semiring theory to the impossibility of tropical group structure. -/
theorem idempotent_semiring_trivial_if_invertible {R : Type*} [Semiring R]
    (hidem : ∀ a : R, a + a = a) (neg : R → R) (hneg : ∀ a : R, a + neg a = 0) :
    ∀ a : R, a = 0 := by
  intro a
  calc a = a + 0 := (add_zero a).symm
    _ = a + (a + neg a) := by rw [hneg a]
    _ = (a + a) + neg a := (add_assoc a a (neg a)).symm
    _ = a + neg a := by rw [hidem a]
    _ = 0 := hneg a

/-- Corollary: an idempotent semiring with additive inverses forces 1 = 0. -/
theorem idempotent_kills_one {R : Type*} [Semiring R]
    (hidem : ∀ a : R, a + a = a) (neg : R → R) (hneg : ∀ a : R, a + neg a = 0) :
    (1 : R) = 0 :=
  idempotent_semiring_trivial_if_invertible hidem neg hneg 1

/-! ## Section 6: Boolean-Tropical Encoding -/

/-- A Boolean assignment encoded as a tropical vector:
    true → 0, false → -1.
    Bridge: connects Boolean satisfiability to tropical feasibility. -/
def boolToTropical {n : ℕ} (v : Fin n → Bool) : Fin n → ℤ :=
  fun j => if v j then 0 else -1

/-- The tropical encoding of true is non-negative. -/
theorem boolToTropical_true {n : ℕ} (v : Fin n → Bool) (j : Fin n) (h : v j = true) :
    0 ≤ boolToTropical v j := by simp [boolToTropical, h]

/-- The tropical encoding of false is negative. -/
theorem boolToTropical_false {n : ℕ} (v : Fin n → Bool) (j : Fin n) (h : v j = false) :
    boolToTropical v j < 0 := by simp [boolToTropical, h]

/-- Values of the tropical encoding are bounded: -1 ≤ x j ≤ 0. -/
theorem boolToTropical_range {n : ℕ} (v : Fin n → Bool) (j : Fin n) :
    -1 ≤ boolToTropical v j ∧ boolToTropical v j ≤ 0 := by
  simp [boolToTropical]; cases v j <;> simp

/-- The tropical encoding is injective: distinct Boolean assignments
    produce distinct tropical vectors.
    Bridge: connects Boolean logic to tropical geometry. -/
theorem boolToTropical_injective (n : ℕ) :
    Function.Injective (boolToTropical : (Fin n → Bool) → (Fin n → ℤ)) := by
  intro v w hvw
  ext j
  have := congr_fun hvw j
  simp [boolToTropical] at this
  cases hv : v j <;> cases hw : w j <;> simp_all

/-! ## Section 7: Weak Duality for Tropical LPs -/

/-- Weak duality for tropical LPs: any feasible point provides entry-level bounds.
    Bridge: connects LP duality theory to tropical optimization. -/
theorem tropical_weak_duality {m n : ℕ} [NeZero n]
    (A : Matrix (Fin m) (Fin n) ℤ) (b : Fin m → ℤ)
    (x : Fin n → ℤ) (hx : ∀ i, tropicalMVP A x i ≤ b i) :
    ∀ i j, A i j + x j ≤ b i := by
  intro i j
  exact le_trans (tropicalMVP_entry_le A x i j) (hx i)

end TropicalAlgebra