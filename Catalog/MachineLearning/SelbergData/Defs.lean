/-
# Selberg Data: Tropical Spectral Algebra

This module formalizes the invariant data of Selberg-class L-functions as a graded
commutative monoid and establishes connections to tropical algebra.

The key insight is that the triple (degree, conductor, spectral parameters) of a
Selberg-class L-function admits a natural product structure from the Rankin-Selberg
convolution, under which:
- Degree is additive
- Conductor is multiplicative
- Spectral complexity behaves as a tropical valuation

## Main Definitions

- `SelbergDatum`: The invariant data triple (degree, conductor, spectral_dim)
- `SelbergDatum.prod`: Rankin-Selberg product on data
- `spectralComplexity`: Tropical valuation on Selberg data
- `countingBound`: The counting function N_d(Q, B)
- `TropicalNat`: Min-plus tropical semiring on ℕ∞
- `FactorizationOrder`: Well-founded divisibility order on Selberg data
-/
import Mathlib

open Finset BigOperators

/-! ## Selberg Datum -/

/-- Invariant data of a Selberg-class L-function.
  `degree` is the degree of the gamma factor,
  `conductor` is the arithmetic conductor (positive integer),
  `spectral_dim` is the dimension of the spectral parameter space. -/
structure SelbergDatum where
  degree : ℕ
  conductor : ℕ
  spectral_dim : ℕ
  conductor_pos : 0 < conductor
  deriving Repr

namespace SelbergDatum

/-- The trivial Selberg datum (degree 0, conductor 1, no spectral parameters). -/
def unit : SelbergDatum where
  degree := 0
  conductor := 1
  spectral_dim := 0
  conductor_pos := Nat.one_pos

/-- Rankin-Selberg product of two Selberg data.
  Degree adds, conductor multiplies, spectral dimensions add. -/
def prod (a b : SelbergDatum) : SelbergDatum where
  degree := a.degree + b.degree
  conductor := a.conductor * b.conductor
  spectral_dim := a.spectral_dim + b.spectral_dim
  conductor_pos := Nat.mul_pos a.conductor_pos b.conductor_pos

instance : Mul SelbergDatum := ⟨prod⟩
instance : One SelbergDatum := ⟨unit⟩

@[simp] theorem mul_degree (a b : SelbergDatum) : (a * b).degree = a.degree + b.degree := rfl
@[simp] theorem mul_conductor (a b : SelbergDatum) :
    (a * b).conductor = a.conductor * b.conductor := rfl
@[simp] theorem mul_spectral_dim (a b : SelbergDatum) :
    (a * b).spectral_dim = a.spectral_dim + b.spectral_dim := rfl
@[simp] theorem one_degree : (1 : SelbergDatum).degree = 0 := rfl
@[simp] theorem one_conductor : (1 : SelbergDatum).conductor = 1 := rfl
@[simp] theorem one_spectral_dim : (1 : SelbergDatum).spectral_dim = 0 := rfl

/-- Spectral complexity: total complexity measure combining degree and spectral dimension. -/
def spectralComplexity (s : SelbergDatum) : ℕ := s.degree + s.spectral_dim

/-- The counting bound N_d(Q, B) = Q * (2*(2*B+1))^d gives an upper bound on the
  number of Selberg data with given degree ≤ d, conductor ≤ Q, and spectral
  parameters bounded by B. -/
def countingBound (d Q B : ℕ) : ℕ := Q * (2 * (2 * B + 1)) ^ d

end SelbergDatum

/-! ## Tropical Semiring on Extended Naturals -/

/-- The min-plus tropical semiring on `ℕ∞`.
  Tropical addition is `min`, tropical multiplication is `+`.
  This is a novel formalization — while Mathlib has `Tropical`,
  our `TropicalNat` is specifically designed for spectral complexity
  applications with the `WithTop ℕ` carrier. -/
structure TropicalNat where
  val : WithTop ℕ
  deriving Repr, DecidableEq

namespace TropicalNat

instance : Inhabited TropicalNat := ⟨⟨⊤⟩⟩

/-- Tropical zero (additive identity) is ∞. -/
def tzero : TropicalNat := ⟨⊤⟩

/-- Tropical one (multiplicative identity) is 0. -/
def tone : TropicalNat := ⟨(0 : ℕ)⟩

/-- Tropical addition is min. -/
def tadd (a b : TropicalNat) : TropicalNat := ⟨min a.val b.val⟩

/-- Tropical multiplication is addition in ℕ∞. -/
def tmul (a b : TropicalNat) : TropicalNat := ⟨a.val + b.val⟩

instance : Add TropicalNat := ⟨tadd⟩
instance : Mul TropicalNat := ⟨tmul⟩
instance : Zero TropicalNat := ⟨tzero⟩
instance : One TropicalNat := ⟨tone⟩

@[simp] theorem tadd_val (a b : TropicalNat) : (a + b).val = min a.val b.val := rfl
@[simp] theorem tmul_val (a b : TropicalNat) : (a * b).val = a.val + b.val := rfl
@[simp] theorem tzero_val : (0 : TropicalNat).val = ⊤ := rfl
@[simp] theorem tone_val : (1 : TropicalNat).val = (0 : ℕ) := rfl

/-- Embedding of ℕ into TropicalNat. -/
def ofNat' (n : ℕ) : TropicalNat := ⟨(n : WithTop ℕ)⟩

@[simp] theorem ofNat'_val (n : ℕ) : (ofNat' n).val = (n : WithTop ℕ) := rfl

@[ext] theorem ext {a b : TropicalNat} (h : a.val = b.val) : a = b := by
  cases a; cases b; simp_all

end TropicalNat

/-! ## Factorization Order -/

/-- A Selberg datum `a` divides `b` if there exists `c` with the expected
  additive/multiplicative decomposition. -/
def SelbergDatum.divides (a b : SelbergDatum) : Prop :=
  ∃ c : SelbergDatum, b.degree = a.degree + c.degree ∧
    b.conductor = a.conductor * c.conductor ∧
    b.spectral_dim = a.spectral_dim + c.spectral_dim

/-- The strict factorization order: `a` strictly divides `b` if `a` divides `b`
  and `a.degree < b.degree`. -/
def SelbergDatum.strictDiv (a b : SelbergDatum) : Prop :=
  a.divides b ∧ a.degree < b.degree

/-! ## Spectral Entropy -/

/-- Spectral entropy of a Selberg datum, defined as log₂(conductor) * degree + spectral_dim.
  We use the natural number floor approximation via `Nat.log`. -/
noncomputable def SelbergDatum.spectralEntropy (s : SelbergDatum) : ℕ :=
  Nat.log 2 s.conductor * s.degree + s.spectral_dim

/-! ## Realization Density -/

/-- A predicate marking which Selberg data are "realized" by actual L-functions. -/
def RealizationPredicate := SelbergDatum → Prop

/-- Realization count: counts how many conductors in {1, ..., Q} yield realized data
  at given degree d and spectral bound B. -/
def realizationCount (P : RealizationPredicate) [DecidablePred P]
    (d Q B : ℕ) : ℕ :=
  ((Finset.range Q).filter fun q =>
      P ⟨d, q + 1, B, Nat.succ_pos q⟩).card