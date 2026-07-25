/-
Copyright (c) 2025. All rights reserved.

# Weak Morse Inequalities for Three-Term Chain Complexes

This file formalizes the algebraic core of Morse inequalities: for any finite-dimensional
three-term chain complex `C₂ → C₁ → C₀` over a field, the alternating partial sums of
homology dimensions are bounded by those of the chain group dimensions.

## Main results

- `ThreeTermComplex.weak_morse_ineq_deg0`: `dim H₀ ≤ dim C₀`
- `ThreeTermComplex.weak_morse_ineq_deg1`: `dim H₁ - dim H₀ ≤ dim C₁ - dim C₀`
- `ThreeTermComplex.euler_characteristic_eq`: alternating sums of chain/homology dims are equal
- `PolyhedralComplex2D.polyhedral_euler_characteristic`: `#V - #E + #F = β₀ - β₁ + β₂`
- `DiscreteMorseData2D.betti_le_critical_cells`: `βₖ ≤ cₖ` for each degree
-/
import Mathlib

open Module LinearMap Submodule

noncomputable section

universe u

/-! ## Three-term chain complex -/

/-- A three-term chain complex `C₂ →[d₂] C₁ →[d₁] C₀` of finite-dimensional
vector spaces over a field, with `d₁ ∘ d₂ = 0`. -/
structure ThreeTermComplex (K : Type u) [Field K] where
  C0 : Type u
  C1 : Type u
  C2 : Type u
  [ag0 : AddCommGroup C0]
  [ag1 : AddCommGroup C1]
  [ag2 : AddCommGroup C2]
  [mod0 : Module K C0]
  [mod1 : Module K C1]
  [mod2 : Module K C2]
  [fd0 : FiniteDimensional K C0]
  [fd1 : FiniteDimensional K C1]
  [fd2 : FiniteDimensional K C2]
  d1 : C1 →ₗ[K] C0
  d2 : C2 →ₗ[K] C1
  dd : d1.comp d2 = 0

attribute [instance] ThreeTermComplex.ag0 ThreeTermComplex.ag1 ThreeTermComplex.ag2
  ThreeTermComplex.mod0 ThreeTermComplex.mod1 ThreeTermComplex.mod2
  ThreeTermComplex.fd0 ThreeTermComplex.fd1 ThreeTermComplex.fd2

variable {K : Type u} [Field K]

namespace ThreeTermComplex

variable (A : ThreeTermComplex K)

/-- The chain condition implies `im(d₂) ≤ ker(d₁)`: boundaries are cycles. -/
theorem range_d2_le_ker_d1 : LinearMap.range A.d2 ≤ LinearMap.ker A.d1 := by
  intro x ⟨y, hy⟩
  simp only [LinearMap.mem_ker]
  rw [← hy]
  exact LinearMap.ext_iff.mp A.dd y

/-- `im(d₂)` as a submodule of `ker(d₁)`. -/
def B1_in_Z1 : Submodule K (LinearMap.ker A.d1) :=
  (LinearMap.range A.d2).comap (LinearMap.ker A.d1).subtype

/-! ### Betti numbers (homology dimensions) -/

/-- `β₀ = dim(C₀ / im d₁)`. -/
def betti0 : ℕ := finrank K (A.C0 ⧸ LinearMap.range A.d1)

/-- `β₁ = dim(ker d₁ / im d₂)`. -/
def betti1 : ℕ := finrank K ((LinearMap.ker A.d1) ⧸ A.B1_in_Z1)

/-- `β₂ = dim(ker d₂)`. -/
def betti2 : ℕ := finrank K (LinearMap.ker A.d2)

/-! ### Key dimension identities -/

/-- `dim C₀ = β₀ + dim(im d₁)` -/
theorem finrank_C0_eq :
    finrank K A.C0 = A.betti0 + finrank K (LinearMap.range A.d1) := by
  unfold betti0
  linarith [Submodule.finrank_quotient_add_finrank (LinearMap.range A.d1)]

/-- `dim(ker d₁) = β₁ + dim(B₁ in Z₁)` -/
theorem finrank_ker_d1_eq :
    finrank K (LinearMap.ker A.d1) = A.betti1 + finrank K A.B1_in_Z1 := by
  unfold betti1
  linarith [Submodule.finrank_quotient_add_finrank A.B1_in_Z1]

/-
`dim(B₁ in Z₁) = dim(im d₂)`, since `im d₂ ≤ ker d₁`.
-/
theorem finrank_B1_in_Z1_eq :
    finrank K A.B1_in_Z1 = finrank K (LinearMap.range A.d2) := by
  convert Submodule.finrank_map_subtype_eq _ _;
  convert rfl;
  convert Submodule.finrank_map_subtype_eq _ _;
  convert Submodule.finrank_map_subtype_eq _ _;
  rw [ show map A.d1.ker.subtype A.B1_in_Z1 = A.d2.range from ?_ ];
  ext x;
  constructor <;> intro hx;
  · aesop;
  · exact ⟨ ⟨ x, by simpa using A.range_d2_le_ker_d1 hx ⟩, by simpa using hx ⟩

/-
`dim C₁ = dim(ker d₁) + dim(im d₁)` (rank-nullity for `d₁`).
-/
theorem finrank_C1_split :
    finrank K A.C1 = finrank K (LinearMap.ker A.d1) + finrank K (LinearMap.range A.d1) := by
  convert LinearMap.finrank_range_add_finrank_ker A.d1 |> Eq.symm using 1;
  exact add_comm _ _

/-- **Master decomposition**: `dim C₁ = β₁ + dim(im d₂) + dim(im d₁)`. -/
theorem finrank_C1_decompose :
    finrank K A.C1 = A.betti1 + finrank K (LinearMap.range A.d2) +
      finrank K (LinearMap.range A.d1) := by
  linarith [A.finrank_C1_split, A.finrank_ker_d1_eq, A.finrank_B1_in_Z1_eq]

/-
`dim C₂ = β₂ + dim(im d₂)` (rank-nullity for `d₂`).
-/
theorem finrank_C2_eq :
    finrank K A.C2 = A.betti2 + finrank K (LinearMap.range A.d2) := by
  have := LinearMap.finrank_range_add_finrank_ker ( A.d2 );
  linarith!

/-! ### Weak Morse inequalities -/

/-- **Weak Morse inequality, degree 0**: `β₀ ≤ dim C₀`. -/
theorem weak_morse_ineq_deg0 : A.betti0 ≤ finrank K A.C0 := by
  linarith [A.finrank_C0_eq]

/-- **Weak Morse inequality, degree 1** (over ℤ):
`β₁ - β₀ ≤ dim C₁ - dim C₀`. -/
theorem weak_morse_ineq_deg1 :
    (A.betti1 : ℤ) - A.betti0 ≤ (finrank K A.C1 : ℤ) - finrank K A.C0 := by
  have h1 := A.finrank_C1_decompose
  have h2 := A.finrank_C0_eq
  omega

/-- **Euler characteristic identity**:
`dim C₀ - dim C₁ + dim C₂ = β₀ - β₁ + β₂`. -/
theorem euler_characteristic_eq :
    (finrank K A.C0 : ℤ) - finrank K A.C1 + finrank K A.C2 =
    (A.betti0 : ℤ) - A.betti1 + A.betti2 := by
  have h1 := A.finrank_C0_eq
  have h2 := A.finrank_C1_decompose
  have h3 := A.finrank_C2_eq
  omega

/-- **Weak Morse inequality, degree 2** (alternating, equals Euler identity). -/
theorem weak_morse_ineq_deg2 :
    (A.betti2 : ℤ) - A.betti1 + A.betti0 ≤
    (finrank K A.C2 : ℤ) - finrank K A.C1 + finrank K A.C0 := by
  linarith [A.euler_characteristic_eq]

/-- All three weak Morse inequalities packaged together. -/
theorem weak_morse_inequalities :
    ((A.betti0 : ℤ) ≤ finrank K A.C0) ∧
    ((A.betti1 : ℤ) - A.betti0 ≤ (finrank K A.C1 : ℤ) - finrank K A.C0) ∧
    ((A.betti2 : ℤ) - A.betti1 + A.betti0 ≤
      (finrank K A.C2 : ℤ) - finrank K A.C1 + finrank K A.C0) :=
  ⟨Int.ofNat_le.mpr A.weak_morse_ineq_deg0, A.weak_morse_ineq_deg1, A.weak_morse_ineq_deg2⟩

end ThreeTermComplex

/-! ## Finite 2D Polyhedral Complex -/

/-- A finite 2D polyhedral complex with vertices, edges, and faces,
and boundary maps over a field `K` satisfying `∂₁ ∘ ∂₂ = 0`. -/
structure PolyhedralComplex2D (K : Type u) [Field K] where
  V : Type u
  E : Type u
  F : Type u
  [finV : Fintype V]
  [finE : Fintype E]
  [finF : Fintype F]
  [decV : DecidableEq V]
  [decE : DecidableEq E]
  [decF : DecidableEq F]
  d1 : (E → K) →ₗ[K] (V → K)
  d2 : (F → K) →ₗ[K] (E → K)
  dd : d1.comp d2 = 0

attribute [instance] PolyhedralComplex2D.finV PolyhedralComplex2D.finE PolyhedralComplex2D.finF
  PolyhedralComplex2D.decV PolyhedralComplex2D.decE PolyhedralComplex2D.decF

namespace PolyhedralComplex2D

variable {K : Type u} [Field K] (P : PolyhedralComplex2D K)

/-- The underlying three-term chain complex. -/
def toTTC : ThreeTermComplex K where
  C0 := P.V → K
  C1 := P.E → K
  C2 := P.F → K
  d1 := P.d1
  d2 := P.d2
  dd := P.dd

private theorem finrank_fun_eq_card {K₀ : Type u} [Field K₀]
    (X : Type u) [Fintype X] [DecidableEq X] :
    finrank K₀ (X → K₀) = Fintype.card X := by
  rw [Module.finrank_pi_fintype]; simp [Module.finrank_self]

/-- **Polyhedral Euler characteristic**: `#V - #E + #F = β₀ - β₁ + β₂`. -/
theorem polyhedral_euler_characteristic :
    (Fintype.card P.V : ℤ) - Fintype.card P.E + Fintype.card P.F =
    (P.toTTC.betti0 : ℤ) - P.toTTC.betti1 + P.toTTC.betti2 := by
  have euler := P.toTTC.euler_characteristic_eq
  have hV : finrank K P.toTTC.C0 = Fintype.card P.V := finrank_fun_eq_card P.V
  have hE : finrank K P.toTTC.C1 = Fintype.card P.E := finrank_fun_eq_card P.E
  have hF : finrank K P.toTTC.C2 = Fintype.card P.F := finrank_fun_eq_card P.F
  omega

/-- **Polyhedral weak Morse, degree 0**: `β₀ ≤ #V`. -/
theorem polyhedral_weak_morse_deg0 : P.toTTC.betti0 ≤ Fintype.card P.V := by
  have h := P.toTTC.weak_morse_ineq_deg0
  have hV : finrank K P.toTTC.C0 = Fintype.card P.V := finrank_fun_eq_card P.V
  omega

/-- **Polyhedral weak Morse, degree 1**: `β₁ - β₀ ≤ #E - #V`. -/
theorem polyhedral_weak_morse_deg1 :
    (P.toTTC.betti1 : ℤ) - P.toTTC.betti0 ≤ (Fintype.card P.E : ℤ) - Fintype.card P.V := by
  have h := P.toTTC.weak_morse_ineq_deg1
  have hV : finrank K P.toTTC.C0 = Fintype.card P.V := finrank_fun_eq_card P.V
  have hE : finrank K P.toTTC.C1 = Fintype.card P.E := finrank_fun_eq_card P.E
  omega

end PolyhedralComplex2D

/-! ## Discrete Morse Data -/

/-- A discrete Morse datum: an original complex, a Morse complex with critical-cell-sized
chain groups, and a proof that homology dimensions match. -/
structure DiscreteMorseData2D (K : Type u) [Field K] where
  original : ThreeTermComplex K
  morse : ThreeTermComplex K
  numCrit0 : ℕ
  numCrit1 : ℕ
  numCrit2 : ℕ
  dim_M0 : finrank K morse.C0 = numCrit0
  dim_M1 : finrank K morse.C1 = numCrit1
  dim_M2 : finrank K morse.C2 = numCrit2
  iso_H0 : original.betti0 = morse.betti0
  iso_H1 : original.betti1 = morse.betti1
  iso_H2 : original.betti2 = morse.betti2

namespace DiscreteMorseData2D

variable {K : Type u} [Field K] (D : DiscreteMorseData2D K)

/-- `β₀ ≤ c₀`. -/
theorem betti_le_critical_deg0 : D.original.betti0 ≤ D.numCrit0 := by
  rw [D.iso_H0, ← D.dim_M0]; exact D.morse.weak_morse_ineq_deg0

/-- `β₁ ≤ c₁`. -/
theorem betti_le_critical_deg1 : D.original.betti1 ≤ D.numCrit1 := by
  rw [D.iso_H1, ← D.dim_M1]
  have := D.morse.weak_morse_ineq_deg1
  have := D.morse.weak_morse_ineq_deg0
  omega

/-- `β₂ ≤ c₂`. -/
theorem betti_le_critical_deg2 : D.original.betti2 ≤ D.numCrit2 := by
  rw [D.iso_H2, ← D.dim_M2]
  have := D.morse.euler_characteristic_eq
  have := D.morse.weak_morse_ineq_deg0
  have := D.morse.weak_morse_ineq_deg1
  omega

/-- **Critical cell inequality**: `βₖ ≤ cₖ` for all degrees. -/
theorem betti_le_critical_cells (k : Fin 3) :
    (match k with | 0 => D.original.betti0 | 1 => D.original.betti1 | 2 => D.original.betti2) ≤
    (match k with | 0 => D.numCrit0 | 1 => D.numCrit1 | 2 => D.numCrit2) := by
  fin_cases k <;> [exact D.betti_le_critical_deg0; exact D.betti_le_critical_deg1;
    exact D.betti_le_critical_deg2]

/-- **Weak Morse for critical cells, deg 1**: `β₁ - β₀ ≤ c₁ - c₀`. -/
theorem weak_morse_critical_deg1 :
    (D.original.betti1 : ℤ) - D.original.betti0 ≤ (D.numCrit1 : ℤ) - D.numCrit0 := by
  have h := D.morse.weak_morse_ineq_deg1
  rw [D.iso_H1, D.iso_H0]
  calc (D.morse.betti1 : ℤ) - D.morse.betti0
      ≤ (finrank K D.morse.C1 : ℤ) - finrank K D.morse.C0 := h
    _ = (D.numCrit1 : ℤ) - D.numCrit0 := by rw [D.dim_M1, D.dim_M0]

/-- **Euler via critical cells**: `c₀ - c₁ + c₂ = β₀ - β₁ + β₂`. -/
theorem euler_critical_cells :
    (D.numCrit0 : ℤ) - D.numCrit1 + D.numCrit2 =
    (D.original.betti0 : ℤ) - D.original.betti1 + D.original.betti2 := by
  have euler := D.morse.euler_characteristic_eq
  rw [D.dim_M0, D.dim_M1, D.dim_M2] at euler
  rw [D.iso_H0, D.iso_H1, D.iso_H2]
  linarith

end DiscreteMorseData2D

end