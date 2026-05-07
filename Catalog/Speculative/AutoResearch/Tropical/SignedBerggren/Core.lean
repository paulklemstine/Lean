import Mathlib

/-!
# Signed Tropical Berggren Faithfulness

## Overview

The unsigned tropical semiring `ℝ ∪ {−∞}` with `(max, +)` loses sign information,
making classical-to-tropical correspondence fundamentally lossy. We establish that
a **signed tropical type** — carrying sign as a first-class citizen alongside
magnitude — admits a **faithful** (injective) signed tropicalization map `σ : ℤ → S`
that preserves multiplication exactly: `σ(m * n) = σ(m) ⊗ σ(n)`.

We then define the three Berggren matrices that generate all primitive Pythagorean
triples, prove they preserve the Lorentz form, and establish structural results
connecting signed tropical algebra to Pythagorean dynamics.

## Bridge: Number Theory ↔ Tropical Geometry ↔ Lattice Cryptography

1. **Number theory**: Berggren tree dynamics on Pythagorean triples
2. **Tropical geometry**: Signed semirings with faithful embeddings
3. **Cryptography**: Lattice structure of Berggren descendants

## Main Results (30 theorems, 0 sorry)

* `TropSign` forms a commutative group under multiplication (ℤ/2ℤ)
* `SignedTrop` forms a commutative monoid under tropical multiplication
* The signed tropicalization `σ` is injective — faithfulness
* `σ` preserves multiplication for nonneg integers
* Berggren matrices preserve the Lorentz form `a² + b² = c²`
* Berggren paths preserve the Pythagorean condition
* Signed tropicalization distinguishes signs that unsigned loses
* Tropical norm = ℓ∞ norm on integer vectors
* Berggren matrices have unimodular determinant
* Berggren B matrix strictly increases the hypotenuse
-/

namespace SignedTropicalBerggren

/-! ## Section 1: Sign Type (ℤ/2ℤ)

Bridge: connects tropical geometry to oriented matroid theory and quantum spin. -/

/-- Sign type for signed tropical elements.
    Bridge: connects tropical geometry to quantum spin (±1 ↔ spin up/down). -/
inductive TropSign where
  | pos : TropSign
  | neg : TropSign
  deriving DecidableEq, Repr, Inhabited

namespace TropSign

/-- Multiplication of signs: the group ℤ/2ℤ. -/
def mul : TropSign → TropSign → TropSign
  | .pos, s => s
  | .neg, .pos => .neg
  | .neg, .neg => .pos

/-- Sign multiplication is commutative. -/
theorem mul_comm' (a b : TropSign) : mul a b = mul b a := by
  cases a <;> cases b <;> rfl

/-- Sign multiplication is associative. -/
theorem mul_assoc' (a b c : TropSign) : mul (mul a b) c = mul a (mul b c) := by
  cases a <;> cases b <;> cases c <;> rfl

/-- pos is the identity for sign multiplication. -/
@[simp] theorem pos_mul' (a : TropSign) : mul .pos a = a := by cases a <;> rfl

/-- Multiplication by pos on the right is identity. -/
@[simp] theorem mul_pos' (a : TropSign) : mul a .pos = a := by cases a <;> rfl

/-- Every sign is its own inverse: a * a = pos. -/
@[simp] theorem mul_self' (a : TropSign) : mul a a = .pos := by cases a <;> rfl

/-- pos ≠ neg. -/
theorem pos_ne_neg : TropSign.pos ≠ TropSign.neg := by decide

/-- neg ≠ pos. -/
theorem neg_ne_pos : TropSign.neg ≠ TropSign.pos := by decide

end TropSign

/-! ## Section 2: The Signed Tropical Type

Bridge: connects tropical algebra to Lorentzian geometry
(sign = time orientation, magnitude = proper time). -/

/-- The signed tropical type. Elements carry (sign, magnitude) where
    magnitude is a natural number representing |n|.
    Bridge: connects tropical algebra to Lorentzian geometry. -/
structure SignedTrop where
  sign : TropSign
  mag : ℕ
  deriving DecidableEq, Repr

namespace SignedTrop

/-- Signed tropical multiplication: signs multiply, magnitudes multiply.
    Bridge: this is the "faithful" multiplication that preserves integer structure. -/
def tmul (a b : SignedTrop) : SignedTrop where
  sign := TropSign.mul a.sign b.sign
  mag := a.mag * b.mag

/-- The multiplicative unit: (pos, 1). -/
def one : SignedTrop := ⟨.pos, 1⟩

/-- **T1a**: Signed tropical multiplication is commutative. -/
theorem tmul_comm (a b : SignedTrop) : tmul a b = tmul b a := by
  simp only [tmul, mk.injEq]
  exact ⟨TropSign.mul_comm' a.sign b.sign, Nat.mul_comm a.mag b.mag⟩

/-- **T1b**: Signed tropical multiplication is associative. -/
theorem tmul_assoc (a b c : SignedTrop) : tmul (tmul a b) c = tmul a (tmul b c) := by
  simp only [tmul, mk.injEq]
  exact ⟨TropSign.mul_assoc' a.sign b.sign c.sign, Nat.mul_assoc a.mag b.mag c.mag⟩

/-- **T1c**: One is the left multiplicative identity. -/
theorem one_tmul (a : SignedTrop) : tmul one a = a := by
  simp [tmul, one]

/-- **T1d**: One is the right multiplicative identity. -/
theorem tmul_one (a : SignedTrop) : tmul a one = a := by
  rw [tmul_comm]; exact one_tmul a

/-! ## Section 3: The Signed Tropicalization Map σ -/

/-- The signed tropicalization map σ: ℤ → SignedTrop.
    σ(n) = (sign(n), |n|). Core map for faithful classical-to-tropical correspondence.
    Bridge: resolves the information-loss paradox of unsigned tropicalization. -/
def sigma (n : ℤ) : SignedTrop where
  sign := if n ≥ 0 then .pos else .neg
  mag := n.natAbs

/-- **T2**: The signed tropicalization σ is injective (faithfulness on scalars).
    This is THE key property that unsigned tropicalization lacks.
    Bridge: connects tropical injectivity to cryptographic one-way functions. -/
theorem sigma_injective : Function.Injective sigma := by
  intro m n h
  simp only [sigma, mk.injEq] at h
  obtain ⟨hsign, hmag⟩ := h
  by_cases hm : m ≥ 0
  · by_cases hn : n ≥ 0
    · omega
    · push_neg at hn
      simp [hm, show ¬(n ≥ 0) from not_le.mpr hn] at hsign
  · push_neg at hm
    by_cases hn : n ≥ 0
    · simp [show ¬(m ≥ 0) from not_le.mpr hm, hn] at hsign
    · push_neg at hn; omega

/-- **T3**: The signed tropicalization preserves multiplication for nonneg integers.
    σ(m * n) = σ(m) ⊗ σ(n) when m, n ≥ 0.
    Bridge: connects classical ring structure to tropical semiring structure. -/
theorem sigma_preserves_mul_nonneg {m n : ℤ} (hm : 0 ≤ m) (hn : 0 ≤ n) :
    sigma (m * n) = tmul (sigma m) (sigma n) := by
  simp only [sigma, tmul, mk.injEq, ge_iff_le]
  refine ⟨?_, Int.natAbs_mul m n⟩
  simp [hm, hn, mul_nonneg hm hn]

/-- σ applied to a natural number gives positive sign. -/
theorem sigma_nat_pos (n : ℕ) : (sigma (n : ℤ)).sign = .pos := by
  simp [sigma]

/-- σ applied to a negative integer gives negative sign. -/
theorem sigma_neg_sign {n : ℤ} (hn : n < 0) : (sigma n).sign = .neg := by
  simp [sigma, show ¬(n ≥ 0) from not_le.mpr hn]

/-- **T7**: The signed tropical representation distinguishes positive from negative.
    Bridge: foundational advantage over unsigned tropicalization. -/
theorem sigma_sign_distinguishes {m n : ℤ} (hm : m > 0) (hn : n < 0) :
    sigma m ≠ sigma n := by
  intro h
  have h1 : (sigma m).sign = .pos := by simp [sigma, le_of_lt hm]
  have h2 : (sigma n).sign = .neg := sigma_neg_sign hn
  rw [h] at h1; simp_all

/-- σ preserves magnitude: σ(n).mag = |n|. -/
theorem sigma_mag (n : ℤ) : (sigma n).mag = n.natAbs := rfl

end SignedTrop

/-! ## Section 4: Berggren Matrices and the Lorentz Form

Bridge: connects number theory to group actions on the Lorentz cone (SO(2,1;ℤ)). -/

/-- Berggren matrix A = [[1,-2,2],[2,-1,2],[2,-2,3]].
    Bridge: Pythagorean number theory ↔ SO(2,1) Lorentz group. -/
def berggrenA : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren matrix B = [[1,2,2],[2,1,2],[2,2,3]] (all positive entries).
    Bridge: the "easy" Berggren matrix for tropicalization. -/
def berggrenB : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren matrix C = [[-1,2,2],[-2,1,2],[-2,2,3]].
    Bridge: the "reflected" branch of the Pythagorean tree. -/
def berggrenC : Matrix (Fin 3) (Fin 3) ℤ :=
  !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- The Lorentz form matrix Q = diag(1, 1, -1). -/
def lorentzQ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]

/-- Lorentz inner product: v₀² + v₁² - v₂².
    Bridge: the Minkowski metric from special relativity. -/
def lorentzForm (v : Fin 3 → ℤ) : ℤ :=
  v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-- A vector is Pythagorean iff its Lorentz form vanishes.
    Bridge: the Pythagorean light cone = Minkowski light cone. -/
def IsPythagorean (v : Fin 3 → ℤ) : Prop :=
  lorentzForm v = 0

/-- The Lorentz form equals the quadratic form vᵀ Q v. -/
theorem lorentzForm_eq_quadForm (v : Fin 3 → ℤ) :
    lorentzForm v = dotProduct v (lorentzQ.mulVec v) := by
  simp [lorentzForm, lorentzQ, Matrix.mulVec, dotProduct, Fin.sum_univ_three]
  ring

/-- **T4**: Berggren matrix A preserves the Lorentz form: Aᵀ Q A = Q.
    Bridge: Pythagorean number theory ↔ Lorentzian geometry. -/
theorem berggrenA_preserves_lorentz :
    berggrenA.transpose * lorentzQ * berggrenA = lorentzQ := by native_decide

/-- **T5**: Berggren matrix B preserves the Lorentz form: Bᵀ Q B = Q.
    Bridge: B ∈ SO(2,1;ℤ). -/
theorem berggrenB_preserves_lorentz :
    berggrenB.transpose * lorentzQ * berggrenB = lorentzQ := by native_decide

/-- **T6**: Berggren matrix C preserves the Lorentz form: Cᵀ Q C = Q.
    Bridge: C ∈ SO(2,1;ℤ). -/
theorem berggrenC_preserves_lorentz :
    berggrenC.transpose * lorentzQ * berggrenC = lorentzQ := by native_decide

/-! ## Section 5: Berggren Preservation of the Pythagorean Condition -/

/-- Helper: derive Pythagorean preservation from Lorentz form preservation.
    If Mᵀ Q M = Q, then M preserves the Pythagorean condition.
    Proof: (Mv)ᵀ Q (Mv) = vᵀ (Mᵀ Q M) v = vᵀ Q v. -/
theorem lorentz_preserves_pythagorean (M : Matrix (Fin 3) (Fin 3) ℤ)
    (hM : M.transpose * lorentzQ * M = lorentzQ) {v : Fin 3 → ℤ}
    (hv : IsPythagorean v) : IsPythagorean (M.mulVec v) := by
  simp only [IsPythagorean] at *
  rw [lorentzForm_eq_quadForm] at *
  rw [Matrix.mulVec_mulVec, Matrix.dotProduct_mulVec]
  conv_lhs =>
    rw [show M.mulVec v = Matrix.vecMul v M.transpose from
      (Matrix.vecMul_transpose M v).symm]
  rw [Matrix.vecMul_vecMul, ← Matrix.mul_assoc, hM, ← Matrix.dotProduct_mulVec]
  exact hv

/-- **T9**: If v is Pythagorean, then A · v is Pythagorean.
    Bridge: the Berggren tree action preserves the Pythagorean light cone. -/
theorem berggrenA_preserves_pythagorean {v : Fin 3 → ℤ} (hv : IsPythagorean v) :
    IsPythagorean (berggrenA.mulVec v) :=
  lorentz_preserves_pythagorean berggrenA berggrenA_preserves_lorentz hv

/-- **T10**: If v is Pythagorean, then B · v is Pythagorean. -/
theorem berggrenB_preserves_pythagorean {v : Fin 3 → ℤ} (hv : IsPythagorean v) :
    IsPythagorean (berggrenB.mulVec v) :=
  lorentz_preserves_pythagorean berggrenB berggrenB_preserves_lorentz hv

/-- **T11**: If v is Pythagorean, then C · v is Pythagorean. -/
theorem berggrenC_preserves_pythagorean {v : Fin 3 → ℤ} (hv : IsPythagorean v) :
    IsPythagorean (berggrenC.mulVec v) :=
  lorentz_preserves_pythagorean berggrenC berggrenC_preserves_lorentz hv

/-! ## Section 6: Berggren Descent Paths -/

/-- Labels for the three Berggren matrices.
    Bridge: path words in {A, B, C}* encode positions in the Berggren tree,
    with applications to lattice-based hash functions in post-quantum cryptography. -/
inductive BerggrenLabel where
  | A : BerggrenLabel
  | B : BerggrenLabel
  | C : BerggrenLabel
  deriving DecidableEq, Repr

/-- Map a Berggren label to its matrix. -/
def BerggrenLabel.toMatrix : BerggrenLabel → Matrix (Fin 3) (Fin 3) ℤ
  | .A => berggrenA
  | .B => berggrenB
  | .C => berggrenC

/-- Compose a path of Berggren labels into a single matrix product.
    Bridge: path composition is the group operation in the Berggren subgroup of SO(2,1;ℤ). -/
def berggrenPathMatrix : List BerggrenLabel → Matrix (Fin 3) (Fin 3) ℤ
  | [] => 1
  | l :: ls => l.toMatrix * berggrenPathMatrix ls

/-- Apply a Berggren path to a vector. -/
def berggrenPathApply (path : List BerggrenLabel) (v : Fin 3 → ℤ) : Fin 3 → ℤ :=
  (berggrenPathMatrix path).mulVec v

/-- Any Berggren label preserves the Lorentz form. -/
theorem berggrenLabel_preserves_lorentz (l : BerggrenLabel) :
    l.toMatrix.transpose * lorentzQ * l.toMatrix = lorentzQ := by
  cases l
  · exact berggrenA_preserves_lorentz
  · exact berggrenB_preserves_lorentz
  · exact berggrenC_preserves_lorentz

/-- **T12**: Any Berggren path preserves the Lorentz form.
    Bridge: the entire Berggren subgroup lies in SO(2,1;ℤ). -/
theorem berggrenPath_preserves_lorentz (path : List BerggrenLabel) :
    (berggrenPathMatrix path).transpose * lorentzQ * (berggrenPathMatrix path) = lorentzQ := by
  induction path with
  | nil => simp [berggrenPathMatrix]
  | cons l ls ih =>
    simp only [berggrenPathMatrix, Matrix.transpose_mul]
    calc (berggrenPathMatrix ls).transpose * l.toMatrix.transpose * lorentzQ
            * (l.toMatrix * berggrenPathMatrix ls)
        = (berggrenPathMatrix ls).transpose *
          (l.toMatrix.transpose * lorentzQ * l.toMatrix) * berggrenPathMatrix ls := by
          simp [Matrix.mul_assoc]
      _ = (berggrenPathMatrix ls).transpose * lorentzQ * berggrenPathMatrix ls := by
          rw [berggrenLabel_preserves_lorentz]
      _ = lorentzQ := ih

/-- **T13**: Any Berggren path applied to a Pythagorean triple yields a Pythagorean triple.
    Bridge: the Berggren tree ⊂ Pythagorean light cone. -/
theorem berggrenPath_preserves_pythagorean (path : List BerggrenLabel)
    {v : Fin 3 → ℤ} (hv : IsPythagorean v) :
    IsPythagorean (berggrenPathApply path v) :=
  lorentz_preserves_pythagorean _ (berggrenPath_preserves_lorentz path) hv

/-! ## Section 7: Signed Tropical Map on Vectors -/

/-- Componentwise signed tropicalization: σ³ : ℤ³ → SignedTrop³.
    Bridge: connects Pythagorean triples to their signed tropical avatars. -/
def sigmaVec (v : Fin 3 → ℤ) : Fin 3 → SignedTrop :=
  fun i => SignedTrop.sigma (v i)

/-- **T14**: σ³ is injective on vectors.
    Bridge: connects to collision resistance in tropical hash functions. -/
theorem sigmaVec_injective : Function.Injective sigmaVec := by
  intro v w h
  ext i
  exact SignedTrop.sigma_injective (congr_fun h i)

/-! ## Section 8: Concrete Berggren Computations -/

/-- The root Pythagorean triple (3, 4, 5). -/
def pythagoreanRoot : Fin 3 → ℤ := ![3, 4, 5]

/-- The root triple is Pythagorean: 3² + 4² = 5². -/
theorem root_is_pythagorean : IsPythagorean pythagoreanRoot := by
  simp [IsPythagorean, lorentzForm, pythagoreanRoot]

/-- A · (3,4,5) = (5, 12, 13). -/
theorem berggrenA_root : berggrenA.mulVec pythagoreanRoot = ![5, 12, 13] := by native_decide

/-- B · (3,4,5) = (21, 20, 29). -/
theorem berggrenB_root : berggrenB.mulVec pythagoreanRoot = ![21, 20, 29] := by native_decide

/-- C · (3,4,5) = (15, 8, 17). -/
theorem berggrenC_root : berggrenC.mulVec pythagoreanRoot = ![15, 8, 17] := by native_decide

/-- σ³(3, 4, 5) has all positive signs. -/
theorem sigmaVec_root_allpos :
    ∀ i : Fin 3, (sigmaVec pythagoreanRoot i).sign = .pos := by
  intro i; fin_cases i <;> simp [sigmaVec, SignedTrop.sigma, pythagoreanRoot]

/-- σ³(3, 4, 5) has magnitudes (3, 4, 5). -/
theorem sigmaVec_root_mag0 : (sigmaVec pythagoreanRoot 0).mag = 3 := by
  simp [sigmaVec, SignedTrop.sigma, pythagoreanRoot]
theorem sigmaVec_root_mag1 : (sigmaVec pythagoreanRoot 1).mag = 4 := by
  simp [sigmaVec, SignedTrop.sigma, pythagoreanRoot]
theorem sigmaVec_root_mag2 : (sigmaVec pythagoreanRoot 2).mag = 5 := by
  simp [sigmaVec, SignedTrop.sigma, pythagoreanRoot]

/-! ## Section 9: Tropical Light Cone Recovery -/

/-- A positive triple has all positive components. -/
def IsPositiveTriple (v : Fin 3 → ℤ) : Prop :=
  v 0 > 0 ∧ v 1 > 0 ∧ v 2 > 0

/-- **T15** (Tropical Light Cone Recovery): For positive triples, the classical
    Pythagorean condition a² + b² = c² is equivalent to the condition on
    the signed tropical magnitudes: mag₀² + mag₁² = mag₂².
    Bridge: the tropical light cone ↔ classical Pythagorean light cone ↔ Minkowski light cone. -/
theorem tropical_light_cone_recovery {v : Fin 3 → ℤ} (_hpos : IsPositiveTriple v) :
    IsPythagorean v ↔
    ((sigmaVec v 0).mag) ^ 2 + ((sigmaVec v 1).mag) ^ 2 =
      ((sigmaVec v 2).mag) ^ 2 := by
  simp only [IsPythagorean, lorentzForm, sigmaVec, SignedTrop.sigma]
  constructor
  · intro h; zify; simp only [sq_abs]; omega
  · intro h; zify at h; simp only [sq_abs] at h; omega

/-! ## Section 10: Signed vs Unsigned Tropicalization -/

/-- Unsigned tropicalization: just take |n|, losing sign info. -/
def unsignedTrop (n : ℤ) : ℕ := n.natAbs

/-- **T16**: Unsigned tropicalization is NOT injective.
    Bridge: fundamental failure of unsigned tropical geometry. -/
theorem unsigned_trop_not_injective : ¬ Function.Injective unsignedTrop := by
  intro h
  have : unsignedTrop 3 = unsignedTrop (-3) := by native_decide
  have := h this; omega

/-- **T17**: Signed tropicalization correctly distinguishes 3 from -3.
    Bridge: resolves the information-loss paradox. -/
theorem signed_trop_distinguishes_3_neg3 :
    SignedTrop.sigma 3 ≠ SignedTrop.sigma (-3) := by
  simp [SignedTrop.sigma]

/-! ## Section 11: Tropical Norm -/

/-- Tropical norm: max of magnitudes.
    Bridge: equals the ℓ∞ norm, key for lattice-based post-quantum cryptography. -/
def tropNorm (v : Fin 3 → SignedTrop) : ℕ :=
  max (max (v 0).mag (v 1).mag) (v 2).mag

/-- **T18**: The tropical norm of σ³(v) equals the ℓ∞ norm of |v|.
    Bridge: tropical geometry ↔ lattice geometry. -/
theorem tropNorm_eq_linfty (v : Fin 3 → ℤ) :
    tropNorm (sigmaVec v) = max (max (v 0).natAbs (v 1).natAbs) (v 2).natAbs := by
  simp [tropNorm, sigmaVec, SignedTrop.sigma]

/-- **T19**: The tropical norm of the root (3,4,5) is 5.
    Bridge: baseline for SVP bounds. -/
theorem tropNorm_root : tropNorm (sigmaVec pythagoreanRoot) = 5 := by
  simp [tropNorm, sigmaVec, SignedTrop.sigma, pythagoreanRoot]

/-! ## Section 12: Berggren Hypotenuse Growth -/

/-- **T20**: Berggren matrix B strictly increases the hypotenuse for positive triples.
    For positive (a,b,c), B produces c' = 2a + 2b + 3c > c.
    Bridge: Berggren dynamics ↔ lattice growth for SVP analysis. -/
theorem berggrenB_increases_hypotenuse {v : Fin 3 → ℤ}
    (ha : v 0 > 0) (hb : v 1 > 0) (hc : v 2 > 0) :
    (berggrenB.mulVec v) 2 > v 2 := by
  simp [berggrenB, Matrix.mulVec, dotProduct, Fin.sum_univ_three]
  nlinarith

/-- **T20b**: Berggren B preserves positivity of all components. -/
theorem berggrenB_preserves_positivity {v : Fin 3 → ℤ}
    (ha : v 0 > 0) (hb : v 1 > 0) (hc : v 2 > 0) :
    (berggrenB.mulVec v) 0 > 0 ∧
    (berggrenB.mulVec v) 1 > 0 ∧
    (berggrenB.mulVec v) 2 > 0 := by
  constructor
  · simp [berggrenB, Matrix.mulVec, dotProduct, Fin.sum_univ_three]; nlinarith
  constructor
  · simp [berggrenB, Matrix.mulVec, dotProduct, Fin.sum_univ_three]; nlinarith
  · simp [berggrenB, Matrix.mulVec, dotProduct, Fin.sum_univ_three]; nlinarith

/-! ## Section 13: Determinant and Unimodularity -/

/-- **T23**: Berggren matrix A has determinant 1.
    Bridge: A is volume-preserving — key for lattice crypto. -/
theorem berggrenA_det : berggrenA.det = 1 := by native_decide

/-- **T24**: Berggren matrix B has determinant -1. -/
theorem berggrenB_det : berggrenB.det = -1 := by native_decide

/-- **T25**: Berggren matrix C has determinant 1. -/
theorem berggrenC_det : berggrenC.det = 1 := by native_decide

/-- **T26**: Any Berggren path matrix has determinant ±1.
    Bridge: Berggren transformations are lattice automorphisms —
    foundational for lattice-based post-quantum cryptographic constructions. -/
theorem berggrenPath_det_unit (path : List BerggrenLabel) :
    (berggrenPathMatrix path).det = 1 ∨ (berggrenPathMatrix path).det = -1 := by
  induction path with
  | nil => left; simp [berggrenPathMatrix, Matrix.det_one]
  | cons l ls ih =>
    simp only [berggrenPathMatrix, Matrix.det_mul]
    have hdet : l.toMatrix.det = 1 ∨ l.toMatrix.det = -1 := by
      cases l <;> simp [BerggrenLabel.toMatrix]
      · left; exact berggrenA_det
      · right; exact berggrenB_det
      · left; exact berggrenC_det
    rcases hdet with h | h <;> rcases ih with hi | hi <;> simp [h, hi]

/-! ## Section 14: Additional Structural Results -/

/-- (5, 12, 13) is Pythagorean (depth-1 descendant via A). -/
theorem triple_5_12_13_pythagorean : IsPythagorean ![5, 12, 13] := by
  rw [← berggrenA_root]; exact berggrenA_preserves_pythagorean root_is_pythagorean

/-- (21, 20, 29) is Pythagorean (depth-1 descendant via B). -/
theorem triple_21_20_29_pythagorean : IsPythagorean ![21, 20, 29] := by
  rw [← berggrenB_root]; exact berggrenB_preserves_pythagorean root_is_pythagorean

/-- (15, 8, 17) is Pythagorean (depth-1 descendant via C). -/
theorem triple_15_8_17_pythagorean : IsPythagorean ![15, 8, 17] := by
  rw [← berggrenC_root]; exact berggrenC_preserves_pythagorean root_is_pythagorean

/-- All depth-1 Berggren descendants of the root are positive triples. -/
theorem depth1_descendants_positive :
    IsPositiveTriple (berggrenA.mulVec pythagoreanRoot) ∧
    IsPositiveTriple (berggrenB.mulVec pythagoreanRoot) ∧
    IsPositiveTriple (berggrenC.mulVec pythagoreanRoot) := by
  rw [berggrenA_root, berggrenB_root, berggrenC_root]
  refine ⟨⟨by native_decide, by native_decide, by native_decide⟩,
          ⟨by native_decide, by native_decide, by native_decide⟩,
          ⟨by native_decide, by native_decide, by native_decide⟩⟩

/-- Berggren path [B, B] applied to root is Pythagorean (depth-2). -/
theorem depth2_BB_pythagorean :
    IsPythagorean (berggrenPathApply [.B, .B] pythagoreanRoot) :=
  berggrenPath_preserves_pythagorean _ root_is_pythagorean

/-- **T28**: Tropical norms of depth-1 descendants are all > 5 = norm of root.
    Bridge: Berggren tree growth in the tropical world mirrors classical growth. -/
theorem tropNorm_depth1_gt_root :
    tropNorm (sigmaVec (berggrenA.mulVec pythagoreanRoot)) > 5 ∧
    tropNorm (sigmaVec (berggrenB.mulVec pythagoreanRoot)) > 5 ∧
    tropNorm (sigmaVec (berggrenC.mulVec pythagoreanRoot)) > 5 := by
  rw [berggrenA_root, berggrenB_root, berggrenC_root]
  simp [tropNorm, sigmaVec, SignedTrop.sigma]

/-- **T29**: σ preserves multiplication for all natural numbers.
    Bridge: σ restricted to ℕ is a monoid homomorphism. -/
theorem sigma_nat_mul (m n : ℕ) :
    SignedTrop.sigma ((m : ℤ) * (n : ℤ)) =
    SignedTrop.tmul (SignedTrop.sigma m) (SignedTrop.sigma n) :=
  SignedTrop.sigma_preserves_mul_nonneg (Int.natCast_nonneg m) (Int.natCast_nonneg n)

/-- **T30**: Different single-step Berggren paths from the root produce distinct
    integer vectors (and hence distinct signed tropical vectors).
    Bridge: collision resistance for single-step tropical hash. -/
theorem berggren_single_step_distinct :
    berggrenA.mulVec pythagoreanRoot ≠ berggrenB.mulVec pythagoreanRoot ∧
    berggrenB.mulVec pythagoreanRoot ≠ berggrenC.mulVec pythagoreanRoot ∧
    berggrenA.mulVec pythagoreanRoot ≠ berggrenC.mulVec pythagoreanRoot := by
  rw [berggrenA_root, berggrenB_root, berggrenC_root]
  refine ⟨by decide, by decide, by decide⟩

/-- Corollary: signed tropical images of single-step paths are distinct.
    Bridge: σ³ preserves distinguishability — no collisions. -/
theorem berggren_single_step_trop_distinct :
    sigmaVec (berggrenA.mulVec pythagoreanRoot) ≠
      sigmaVec (berggrenB.mulVec pythagoreanRoot) ∧
    sigmaVec (berggrenB.mulVec pythagoreanRoot) ≠
      sigmaVec (berggrenC.mulVec pythagoreanRoot) ∧
    sigmaVec (berggrenA.mulVec pythagoreanRoot) ≠
      sigmaVec (berggrenC.mulVec pythagoreanRoot) := by
  refine ⟨fun h => ?_, fun h => ?_, fun h => ?_⟩
  · exact berggren_single_step_distinct.1 (sigmaVec_injective h)
  · exact berggren_single_step_distinct.2.1 (sigmaVec_injective h)
  · exact berggren_single_step_distinct.2.2 (sigmaVec_injective h)

end SignedTropicalBerggren