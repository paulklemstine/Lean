import Mathlib

open scoped BigOperators ComplexConjugate

namespace LargeMOQLS

/-- The standard coordinate vector indexed by `ι`. -/
def basisVector {ι : Type*} [DecidableEq ι] (i : ι) : ι → ℂ :=
  fun j => if j = i then 1 else 0

/-- An array of vectors is a quantum Latin square when every row and every column
is an orthonormal basis. -/
structure QuantumLatinSquare (ι : Type*) [Fintype ι] [DecidableEq ι] where
  entry : ι → ι → (ι → ℂ)
  row_orthonormal : ∀ i j k,
    (∑ x, conj (entry i j x) * entry i k x) = if j = k then 1 else 0
  column_orthonormal : ∀ i j k,
    (∑ x, conj (entry j i x) * entry k i x) = if j = k then 1 else 0

/-- Two quantum Latin squares are orthogonal when the entrywise tensor products
form an orthonormal basis of the tensor-square coordinate space. -/
def QuantumOrthogonal {ι : Type*} [Fintype ι] [DecidableEq ι]
    (A B : QuantumLatinSquare ι) : Prop :=
  ∀ i j k l,
    (∑ p : ι × ι,
      conj (A.entry i j p.1 * B.entry i j p.2) *
        (A.entry k l p.1 * B.entry k l p.2)) =
      if i = k ∧ j = l then 1 else 0

/-- Replace each symbol in a classical array by its standard basis vector. -/
def basisArray {ι : Type*} [DecidableEq ι] (L : ι → ι → ι) :
    ι → ι → (ι → ℂ) :=
  fun i j => basisVector (L i j)

lemma basisVector_inner {ι : Type*} [Fintype ι] [DecidableEq ι] (a b : ι) :
    (∑ x, conj (basisVector a x) * basisVector b x) = if a = b then 1 else 0 := by
  unfold basisVector;
  rw [ Finset.sum_eq_single a ] <;> aesop

/-
Any classical Latin square gives a quantum Latin square in the computational basis.
-/
def classicalToQuantum {ι : Type*} [Fintype ι] [DecidableEq ι]
    (L : ι → ι → ι)
    (hrow : ∀ i, Function.Injective (L i))
    (hcol : ∀ j, Function.Injective (fun i => L i j)) : QuantumLatinSquare ι where
  entry := basisArray L
  row_orthonormal := by
    unfold basisArray;
    simp +decide [ basisVector ];
    grind
  column_orthonormal := by
    intro i j k; rw [ Finset.sum_eq_single ( L j i ) ] <;> simp +decide [ basisArray, basisVector ] ;
    · simp +decide [ hcol i |> Function.Injective.eq_iff ];
    · tauto

/-
Orthogonal classical arrays induce orthogonal quantum Latin squares.
-/
theorem classicalToQuantum_orthogonal {ι : Type*} [Fintype ι] [DecidableEq ι]
    (L M : ι → ι → ι)
    (Lrow : ∀ i, Function.Injective (L i))
    (Lcol : ∀ j, Function.Injective (fun i => L i j))
    (Mrow : ∀ i, Function.Injective (M i))
    (Mcol : ∀ j, Function.Injective (fun i => M i j))
    (hpair : Function.Injective (fun p : ι × ι => (L p.1 p.2, M p.1 p.2))) :
    QuantumOrthogonal (classicalToQuantum L Lrow Lcol)
      (classicalToQuantum M Mrow Mcol) := by
  intro i j k l;
  convert Finset.sum_eq_single ( L i j, M i j ) _ _ using 1;
  · simp +decide [ classicalToQuantum, basisArray, basisVector ];
    have := @hpair ( i, j ) ( k, l ) ; aesop;
  · unfold classicalToQuantum; simp +decide [ basisArray, basisVector ] ;
    grind +splitImp;
  · aesop

section Affine

variable {K : Type*} [Fintype K] [DecidableEq K] [Field K]

/-- The affine square of slope `a`: its `(x,y)` entry is `a*x+y`. -/
def affineSquare (a : K) : K → K → K := fun x y => a * x + y

omit [Fintype K] [DecidableEq K] in
lemma affineSquare_row_injective (a x : K) :
    Function.Injective (affineSquare a x) := by
  exact fun b c h => by unfold affineSquare at h; simpa using h;

omit [Fintype K] [DecidableEq K] in
lemma affineSquare_column_injective {a : K} (ha : a ≠ 0) (y : K) :
    Function.Injective (fun x => affineSquare a x y) := by
  exact fun x x' h => mul_left_cancel₀ ha <| by unfold affineSquare at h; linear_combination' h;

/-- Every nonzero slope produces an affine quantum Latin square. -/
def affineQuantumLatinSquare (a : K) (ha : a ≠ 0) : QuantumLatinSquare K :=
  classicalToQuantum (affineSquare a) (affineSquare_row_injective a)
    (affineSquare_column_injective ha)

omit [Fintype K] [DecidableEq K] in
lemma affine_pair_injective {a b : K} (hab : a ≠ b) :
    Function.Injective (fun p : K × K =>
      (affineSquare a p.1 p.2, affineSquare b p.1 p.2)) := by
  intro p q; simp +decide [ affineSquare ] ;
  grind

/-
Distinct nonzero affine slopes give orthogonal quantum Latin squares.
-/
theorem affineQuantumLatinSquare_orthogonal {a b : K}
    (ha : a ≠ 0) (hb : b ≠ 0) (hab : a ≠ b) :
    QuantumOrthogonal (affineQuantumLatinSquare a ha)
      (affineQuantumLatinSquare b hb) := by
  convert classicalToQuantum_orthogonal ( affineSquare a ) ( affineSquare b ) _ _ _ _ _;
  exact affine_pair_injective hab

/-
The nonzero elements of a finite field index a mutually orthogonal family
of quantum Latin squares.
-/
theorem affine_family_mutually_orthogonal :
    ∀ a b : {x : K // x ≠ 0}, a ≠ b →
      QuantumOrthogonal (affineQuantumLatinSquare a.1 a.2)
        (affineQuantumLatinSquare b.1 b.2) := by
  grind +suggestions

/-
The affine construction contains exactly `|K|-1` squares.
-/
theorem affine_family_cardinality :
    Fintype.card {x : K // x ≠ 0} = Fintype.card K - 1 := by
  rw [ Fintype.card_subtype_compl ] ; aesop

end Affine

/-- The order-three affine construction has two quantum Latin squares. -/
theorem orderThree_affine_family_cardinality :
    Fintype.card {x : ZMod 3 // x ≠ 0} = 2 := by
  norm_num [affine_family_cardinality]

/-- The two nonzero slopes in `ZMod 3` give orthogonal quantum Latin squares. -/
theorem orderThree_slopes_orthogonal :
    QuantumOrthogonal
      (affineQuantumLatinSquare (1 : ZMod 3) (by decide))
      (affineQuantumLatinSquare (2 : ZMod 3) (by decide)) := by
  exact affineQuantumLatinSquare_orthogonal (by decide) (by decide) (by decide)

/-- At order five the affine construction has four members. -/
theorem orderFive_affine_family_cardinality :
    Fintype.card {x : ZMod 5 // x ≠ 0} = 4 := by
  norm_num [affine_family_cardinality]

end LargeMOQLS