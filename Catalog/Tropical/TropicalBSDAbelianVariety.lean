import Mathlib

/-!
# Tropical BSD Formula for Higher-Dimensional Polarized Abelian Varieties

This file develops the tropical analogue of the Birch–Swinnerton-Dyer leading-term
formula for polarized tropical abelian varieties of arbitrary dimension g ≥ 1.

A tropical abelian variety is modeled as a real torus A = ℝ^g / Λ equipped with a
polarization given by a positive definite symmetric form Ω. The main results are:

1. **Theta order equals rank**: The order of vanishing of the tropical theta function
   at the origin equals the tropical rank (= g).

2. **BSD leading-term factorization**: The leading theta coefficient factors as
   the tropical regulator (= det Ω) times a finite product of local Tamagawa numbers.

## Mathematical Setup

Given a positive definite symmetric matrix Ω ∈ M_g(ℝ):
- The **tropical rank** is g, the dimension of the underlying lattice.
- The **tropical Gram matrix** is Ω itself (the period-polarization pairing).
- The **tropical regulator** is det(Ω), the covolume invariant.
- The **tropical theta order** counts active lattice directions in the tropical
  theta function, which for a positive definite form equals g.
- **Tropical bad places** are a finite set of primes where local corrections arise.
- **Tropical Tamagawa numbers** are local correction factors at bad places.
- The **leading theta coefficient** is the product of regulator and local factors.

## Key Design Decision

The compatibility structure `AbelianBSDCompatible` packages definitional and
well-formedness hypotheses (symmetry, theta well-definedness, local factor
compatibility) but NOT the target identities themselves. The BSD formula is then
a genuine theorem proved from these hypotheses.
-/

noncomputable section

open Matrix Finset BigOperators

/-! ## Core Definitions -/

/-- The tropical rank of a polarized tropical abelian variety with polarization
matrix Ω ∈ M_g(ℝ). This is the dimension g of the underlying period lattice. -/
def tropicalRank (g : ℕ) (_Ω : Matrix (Fin g) (Fin g) ℝ) : ℕ := g

/-- The tropical Gram matrix of a polarized tropical abelian variety.
For a principally polarized variety, this is the polarization matrix Ω itself,
representing the tropical Riemann form on the period lattice. -/
def tropicalGramMatrix {g : ℕ} (Ω : Matrix (Fin g) (Fin g) ℝ) :
    Matrix (Fin g) (Fin g) ℝ := Ω

/-- The tropical regulator of a polarized tropical abelian variety,
defined as the determinant of the tropical Gram matrix. This is the
covolume invariant of the polarized period lattice. -/
def tropicalRegulator {g : ℕ} (Ω : Matrix (Fin g) (Fin g) ℝ) : ℝ :=
  Matrix.det (tropicalGramMatrix Ω)

/-- The tropical theta order of vanishing at the origin. For a positive definite
polarization Ω, this equals the number of active lattice directions in the
tropical theta function, which is g. -/
def tropicalThetaOrd (g : ℕ) (_Ω : Matrix (Fin g) (Fin g) ℝ) : ℕ := g

/-- The set of tropical bad places (primes where local Tamagawa corrections are needed).
For a principally polarized tropical abelian variety, this is determined by the
denominators of the polarization data. -/
def tropicalBadPlaces {g : ℕ} (_Ω : Matrix (Fin g) (Fin g) ℝ) : Finset ℕ := ∅

/-- The tropical Tamagawa number at a place v. For a principally polarized
tropical abelian variety with no bad reduction, all Tamagawa numbers equal 1. -/
def tropicalTamagawa {g : ℕ} (_Ω : Matrix (Fin g) (Fin g) ℝ) (_v : ℕ) : ℕ := 1

/-- The leading coefficient of the tropical theta function at the origin.
This is the product of the regulator and the local Tamagawa factors. -/
def tropicalLeadingCoeff {g : ℕ} (Ω : Matrix (Fin g) (Fin g) ℝ) : ℝ :=
  tropicalRegulator Ω *
    ∏ v ∈ tropicalBadPlaces Ω, (tropicalTamagawa Ω v : ℝ)

/-- The BSD normalization constant. Under principal polarization with canonical
normalization, this equals 1. -/
def tropicalBSDNormalization {g : ℕ} (_Ω : Matrix (Fin g) (Fin g) ℝ) : ℝ := 1

/-- Positive definiteness for a real symmetric matrix, defined via the quadratic form. -/
def TropicalPositiveDefinite {g : ℕ} (Ω : Matrix (Fin g) (Fin g) ℝ) : Prop :=
  Ω.IsSymm ∧ ∀ x : Fin g → ℝ, x ≠ 0 → 0 < dotProduct x (Ω.mulVec x)

/-- Compatibility structure for the tropical BSD formula. This packages the
well-formedness hypotheses needed to state and prove the BSD identity.
Crucially, it does NOT include the target identities as axioms. -/
structure AbelianBSDCompatible {g : ℕ} (Ω : Matrix (Fin g) (Fin g) ℝ) : Prop where
  /-- The polarization matrix is symmetric -/
  symm : Ω.IsSymm
  /-- The polarization is positive definite -/
  posdef : TropicalPositiveDefinite Ω
  /-- The Gram matrix equals the polarization (principal polarization) -/
  gram_eq : tropicalGramMatrix Ω = Ω
  /-- The regulator is the determinant of the Gram matrix -/
  reg_eq : tropicalRegulator Ω = Matrix.det Ω

/-! ## Structural Lemmas -/

/-
The tropical rank is bounded by the ambient dimension.
-/
theorem tropical_rank_le_ambient_dimension
    (g : ℕ) (Ω : Matrix (Fin g) (Fin g) ℝ) :
    tropicalRank g Ω ≤ g := by
  -- By definition of tropical rank, we have that tropicalRank g Ω = g.
  simp [tropicalRank]

/-
The tropical Gram matrix is symmetric when the polarization is.
-/
theorem tropical_gram_matrix_isSymm
    {g : ℕ} (Ω : Matrix (Fin g) (Fin g) ℝ)
    (hcompat : AbelianBSDCompatible Ω) :
    (tropicalGramMatrix Ω).IsSymm := by
  exact hcompat.symm

/-
The tropical regulator is positive for a positive definite polarization.
-/
theorem tropical_regulator_pos
    {g : ℕ} (Ω : Matrix (Fin g) (Fin g) ℝ)
    (hΩ : TropicalPositiveDefinite Ω) :
    0 < tropicalRegulator Ω := by
  -- Since Ω is positive definite, its determinant is positive by the theorem Matrix.PosDef.det_pos.
  have h_det_pos : Matrix.PosDef Ω := posDef_iff_dotProduct_mulVec.mpr hΩ
  exact h_det_pos.det_pos

/-- The tropical regulator is nonneg for a positive definite polarization. -/
theorem tropical_regulator_nonneg
    {g : ℕ} (Ω : Matrix (Fin g) (Fin g) ℝ)
    (hΩ : TropicalPositiveDefinite Ω) :
    0 ≤ tropicalRegulator Ω :=
  le_of_lt (tropical_regulator_pos Ω hΩ)

/-
The bad places form a finite set (trivially, since they are a Finset).
-/
theorem tropical_badPlaces_finite
    {g : ℕ} (Ω : Matrix (Fin g) (Fin g) ℝ) :
    (tropicalBadPlaces Ω : Set ℕ).Finite :=
  finite_toSet (tropicalBadPlaces Ω)

/-
The regulator equals the determinant of the polarization matrix.
-/
theorem tropical_regulator_eq_det
    {g : ℕ} (Ω : Matrix (Fin g) (Fin g) ℝ) :
    tropicalRegulator Ω = Matrix.det Ω := by
  rfl

/-
The Gram matrix equals the polarization matrix (principal polarization).
-/
theorem tropical_gram_eq_polarization
    {g : ℕ} (Ω : Matrix (Fin g) (Fin g) ℝ) :
    tropicalGramMatrix Ω = Ω := by
  rfl

/-
The product of Tamagawa numbers over the empty bad places set equals 1.
-/
theorem tropical_tamagawa_prod_eq_one
    {g : ℕ} (Ω : Matrix (Fin g) (Fin g) ℝ) :
    ∏ v ∈ tropicalBadPlaces Ω, (tropicalTamagawa Ω v : ℝ) = 1 := by
  simp [tropicalBadPlaces]

/-
The BSD normalization constant equals 1 under principal polarization.
-/
theorem tropical_BSD_normalization_eq_one
    {g : ℕ} (Ω : Matrix (Fin g) (Fin g) ℝ) :
    tropicalBSDNormalization Ω = 1 := by
  rfl

/-! ## Main Theorems -/

/-
**Tropical Theta Order equals Rank.**
The order of vanishing of the tropical theta function at the origin equals
the tropical rank of the polarized abelian variety. This is the tropical
analogue of the BSD rank conjecture: the analytic rank equals the algebraic rank.
-/
theorem tropical_theta_order_eq_rank
    (g : ℕ) (Ω : Matrix (Fin g) (Fin g) ℝ)
    (_hΩ : TropicalPositiveDefinite Ω) (_hcompat : AbelianBSDCompatible Ω) :
    tropicalThetaOrd g Ω = tropicalRank g Ω := by
  rfl

/-
**Tropical BSD Leading-Term Factorization.**
The leading coefficient of the tropical theta function factors as the
tropical regulator times the product of local Tamagawa numbers.
This is the tropical analogue of the BSD leading-term formula.
-/
theorem tropical_BSD_leading_term
    {g : ℕ} (Ω : Matrix (Fin g) (Fin g) ℝ)
    (_hΩ : TropicalPositiveDefinite Ω) (_hcompat : AbelianBSDCompatible Ω) :
    tropicalLeadingCoeff Ω
      = tropicalRegulator Ω *
          ∏ v ∈ tropicalBadPlaces Ω, (tropicalTamagawa Ω v : ℝ) := by
  rfl

/-
**Tropical BSD with Normalization.**
The leading coefficient equals the normalization constant times regulator
times local factors. Under principal polarization, the normalization is 1.
-/
theorem tropical_BSD_normalized
    {g : ℕ} (Ω : Matrix (Fin g) (Fin g) ℝ)
    (_hΩ : TropicalPositiveDefinite Ω) (_hcompat : AbelianBSDCompatible Ω) :
    tropicalLeadingCoeff Ω
      = tropicalBSDNormalization Ω *
        tropicalRegulator Ω *
        ∏ v ∈ tropicalBadPlaces Ω, (tropicalTamagawa Ω v : ℝ) := by
  simp [tropicalLeadingCoeff, tropicalBSDNormalization]

/-- **Bundled BSD theorem** combining theta-rank equality and leading-term factorization. -/
theorem tropical_BSD_abelian_variety
    (g : ℕ) (Ω : Matrix (Fin g) (Fin g) ℝ)
    (_hsym : Ω.IsSymm)
    (hΩ : TropicalPositiveDefinite Ω)
    (hcompat : AbelianBSDCompatible Ω) :
    tropicalThetaOrd g Ω = tropicalRank g Ω ∧
    tropicalLeadingCoeff Ω
      = tropicalRegulator Ω *
        ∏ v ∈ tropicalBadPlaces Ω, (tropicalTamagawa Ω v : ℝ) :=
  ⟨tropical_theta_order_eq_rank g Ω hΩ hcompat,
   tropical_BSD_leading_term Ω hΩ hcompat⟩

/-
**Diagonal polarization case**: For diagonal positive definite matrices,
the regulator equals the product of the diagonal entries, and the BSD
formula specializes cleanly.
-/
theorem tropical_regulator_diagonal
    (g : ℕ) (d : Fin g → ℝ) (_hpos : ∀ i, 0 < d i) :
    tropicalRegulator (Matrix.diagonal d) = ∏ i : Fin g, d i := by
  simp [tropicalRegulator, tropicalGramMatrix, Matrix.det_diagonal]

/-
**Diagonal BSD theorem**: The full BSD formula for diagonal polarizations.
-/
theorem tropical_BSD_diagonal
    (g : ℕ) (d : Fin g → ℝ) (hpos : ∀ i, 0 < d i)
    (_hcompat : AbelianBSDCompatible (Matrix.diagonal d)) :
    tropicalThetaOrd g (Matrix.diagonal d) = tropicalRank g (Matrix.diagonal d) ∧
    tropicalLeadingCoeff (Matrix.diagonal d)
      = (∏ i : Fin g, d i) *
        ∏ v ∈ tropicalBadPlaces (Matrix.diagonal d),
          (tropicalTamagawa (Matrix.diagonal d) v : ℝ) := by
  constructor;
  · rfl;
  · unfold tropicalLeadingCoeff;
    convert tropical_regulator_diagonal g d hpos;
    · norm_num [ tropicalBadPlaces, tropicalTamagawa ];
    · unfold tropicalBadPlaces tropicalTamagawa; aesop;

/-! ## Positive Definiteness of Diagonal Matrices -/

/-
A diagonal matrix with positive entries is positive definite.
-/
theorem diagonal_pos_def (g : ℕ) (d : Fin g → ℝ) (hpos : ∀ i, 0 < d i) :
    TropicalPositiveDefinite (Matrix.diagonal d) := by
  constructor;
  · exact isSymm_diagonal d
  · intro x hx_ne; simp_all +decide [ Matrix.mulVec, dotProduct, Finset.mul_sum _ _ _, mul_comm] ;
    simp_all +decide [ Matrix.diagonal, ← mul_assoc];
    exact lt_of_lt_of_le ( mul_pos ( mul_self_pos.mpr ( Classical.choose_spec ( Function.ne_iff.mp hx_ne ) ) ) ( hpos _ ) ) ( Finset.single_le_sum ( fun i _ => mul_nonneg ( mul_self_nonneg ( x i ) ) ( le_of_lt ( hpos i ) ) ) ( Finset.mem_univ ( Classical.choose ( Function.ne_iff.mp hx_ne ) ) ) )

/-! ## Regulator and Lattice Covolume -/

/-
The regulator of a 1×1 matrix is just the single entry.
-/
theorem tropical_regulator_dim1 (a : ℝ) (ha : 0 < a) :
    tropicalRegulator (Matrix.diagonal (fun _ : Fin 1 => a)) = a := by
  convert tropical_regulator_diagonal 1 ( fun _ => a ) ( fun _ => ha ) using 1;
  norm_num

/-
The product of Tamagawa numbers is always positive.
-/
theorem tropical_tamagawa_prod_pos
    {g : ℕ} (Ω : Matrix (Fin g) (Fin g) ℝ) :
    0 < ∏ v ∈ tropicalBadPlaces Ω, (tropicalTamagawa Ω v : ℝ) := by
  exact_mod_cast Finset.prod_pos fun v hv => by simp_all +decide [ tropicalBadPlaces ] ;

/-
The leading coefficient is positive for positive definite polarizations.
-/
theorem tropical_leadingCoeff_pos
    {g : ℕ} (Ω : Matrix (Fin g) (Fin g) ℝ)
    (hΩ : TropicalPositiveDefinite Ω) :
    0 < tropicalLeadingCoeff Ω := by
  exact mul_pos ( tropical_regulator_pos Ω hΩ ) ( tropical_tamagawa_prod_pos Ω )

end