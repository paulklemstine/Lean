import Mathlib

/-!
# Laplacian decomposition for generalized join digraphs

This file formalizes the linear-algebraic mechanism behind the spanning-tree formulas for a
generalized join digraph.  A vector on the generalized join is represented fiberwise.  Its
Laplacian is the internal fiber Laplacian, plus the external out-degree, minus the complete
bipartite coupling to every adjacent fiber.

The main results split the operator into two parts:

* on vectors whose coordinate sum in every fiber is zero, every internal eigenvalue is shifted
  by the external out-degree (`zeroMass_eigenvector`);
* on vectors constant on every fiber, the full operator intertwines with an explicit weighted
  quotient Laplacian (`joinAction_fiberConstant`).

This is the spectral decomposition used before applying the directed matrix-tree theorem.
The development works over any commutative ring and permits weighted base arcs.
-/

namespace GeneralizedJoinDigraphs

open scoped BigOperators

variable {I : Type*} [Fintype I]
variable (V : I → Type*) [∀ i, Fintype (V i)]
variable {R : Type*} [CommRing R]

/-- Vectors on the disjoint union of the fibers, represented as dependent functions. -/
abbrev FiberVec (V : I → Type*) (R : Type*) := (i : I) → V i → R

/-- Total mass of a vector in one fiber. -/
def fiberMass (x : FiberVec V R) (i : I) : R := ∑ v, x i v

/-- Weighted external out-degree contributed to a vertex in fiber `i`. -/
def externalDegree (A : I → I → R) (i : I) : R :=
  ∑ j, A i j * (Fintype.card (V j) : R)

/-- The Laplacian action of the generalized join.  `L i` is the internal Laplacian action in
fiber `i`, while `A i j` is the weight of every arc from fiber `i` to fiber `j`. -/
def joinAction (L : (i : I) → (V i → R) → V i → R) (A : I → I → R)
    (x : FiberVec V R) : FiberVec V R :=
  fun i u =>
    L i (x i) u + externalDegree V A i * x i u - ∑ j, A i j * fiberMass V x j

/-- The weighted quotient Laplacian governing vectors constant on each fiber. -/
def quotientAction (A : I → I → R) (z : I → R) (i : I) : R :=
  externalDegree V A i * z i - ∑ j, A i j * (Fintype.card (V j) : R) * z j

/-- Lift a vector on the base to a vector constant on each fiber. -/
def fiberConstant (z : I → R) : FiberVec V R := fun i _ => z i

/-
If all fiber masses vanish, all complete-bipartite coupling terms vanish.
-/
theorem joinAction_of_zeroMass
    (L : (i : I) → (V i → R) → V i → R) (A : I → I → R)
    (x : FiberVec V R) (hx : ∀ i, fiberMass V x i = 0) (i : I) (u : V i) :
    joinAction V L A x i u = L i (x i) u + externalDegree V A i * x i u := by
  unfold joinAction;
  simp +decide [ hx ]

/-
**Shifted internal spectrum.** A fiberwise zero-mass vector assembled from internal
`(ρ - dᵢ)`-eigenvectors is a `ρ`-eigenvector of the generalized-join Laplacian.
-/
theorem zeroMass_eigenvector
    (L : (i : I) → (V i → R) → V i → R) (A : I → I → R)
    (x : FiberVec V R) (ρ : R)
    (hmass : ∀ i, fiberMass V x i = 0)
    (heig : ∀ i u, L i (x i) u = (ρ - externalDegree V A i) * x i u) :
    joinAction V L A x = ρ • x := by
  ext i u; simp +decide [ *, joinAction ] ; ring;

/-
A convenient one-fiber form of the shifted-eigenvalue theorem.
-/
theorem supportedFiber_eigenvector
    (L : (i : I) → (V i → R) → V i → R) (A : I → I → R)
    (x : FiberVec V R) (i₀ : I) (μ : R)
    (hsupport : ∀ j, j ≠ i₀ → x j = 0)
    (hmass : fiberMass V x i₀ = 0)
    (hzero : ∀ j, L j 0 = 0)
    (heig : ∀ u, L i₀ (x i₀) u = μ * x i₀ u) :
    joinAction V L A x = (μ + externalDegree V A i₀) • x := by
  ext j; by_cases hj : j = i₀ <;> simp_all +decide [ funext_iff ] ;
  · unfold joinAction; simp_all +decide [ add_mul ] ;
    rw [ Finset.sum_eq_single i₀ ] <;> simp_all +decide [ fiberMass ];
    aesop;
  · unfold joinAction; simp +decide [ *, fiberMass ] ;
    rw [ show x j = 0 from funext ( hsupport j hj ) ] ; simp +decide [ hzero ] ;
    rw [ Finset.sum_eq_single i₀ ] <;> simp_all +decide [ fiberMass ]

/-
Internal Laplacians kill constants precisely when the generalized-join Laplacian on
fiber-constant vectors is the weighted quotient Laplacian.
-/
theorem joinAction_fiberConstant
    (L : (i : I) → (V i → R) → V i → R) (A : I → I → R)
    (hconst : ∀ i (c : R), L i (fun _ => c) = 0) (z : I → R) :
    joinAction V L A (fiberConstant V z) = fiberConstant V (quotientAction V A z) := by
  unfold joinAction quotientAction fiberConstant;
  simp +decide [ hconst, fiberMass, mul_assoc ]

/-
Every quotient eigenvector lifts to a generalized-join Laplacian eigenvector.
-/
theorem quotient_eigenvector_lifts
    (L : (i : I) → (V i → R) → V i → R) (A : I → I → R)
    (hconst : ∀ i (c : R), L i (fun _ => c) = 0)
    (z : I → R) (ρ : R) (heig : quotientAction V A z = ρ • z) :
    joinAction V L A (fiberConstant V z) = ρ • fiberConstant V z := by
  rw [ joinAction_fiberConstant ] ; aesop;
  exact hconst

/-
The weighted quotient Laplacian kills the all-ones vector.
-/
theorem quotientAction_one (A : I → I → R) :
    quotientAction V A (fun _ => 1) = 0 := by
  ext i; simp +decide [ quotientAction, externalDegree ] ;

/-
Consequently the generalized-join Laplacian kills the global constant vector whenever all
internal Laplacians kill constants.
-/
theorem joinAction_one
    (L : (i : I) → (V i → R) → V i → R) (A : I → I → R)
    (hconst : ∀ i (c : R), L i (fun _ => c) = 0) :
    joinAction V L A (fun _ _ => 1) = 0 := by
  convert joinAction_fiberConstant V L A hconst ( fun _ => 1 ) using 1;
  exact Eq.symm ( quotientAction_one V A ▸ rfl )

/-
The direct sum of the fiberwise zero-mass spaces is invariant under the generalized-join
Laplacian, provided each internal Laplacian preserves zero mass.
-/
theorem zeroMass_invariant
    (L : (i : I) → (V i → R) → V i → R) (A : I → I → R)
    (hL : ∀ i (y : V i → R), (∑ u, y u) = 0 → ∑ u, L i y u = 0)
    (x : FiberVec V R) (hx : ∀ i, fiberMass V x i = 0) :
    ∀ i, fiberMass V (joinAction V L A x) i = 0 := by
  unfold fiberMass joinAction;
  simp_all +decide [ Finset.sum_add_distrib, ← Finset.mul_sum _ _ _, fiberMass ]

/-! ## Direct-sum decomposition over a field -/

section Decomposition

variable {K : Type*} [Field K] [CharZero K] [∀ i, Nonempty (V i)]

/-- The average value of a vector on each (nonempty) fiber. -/
noncomputable def fiberAverage (x : FiberVec V K) (i : I) : K :=
  fiberMass V x i / (Fintype.card (V i) : K)

/-- Subtract the fiber average, producing the internal fluctuation component. -/
noncomputable def centered (x : FiberVec V K) : FiberVec V K :=
  fun i u => x i u - fiberAverage V x i

omit [Fintype I] in
/-- Centering really gives zero mass on every fiber. -/
lemma fiberMass_centered (x : FiberVec V K) (i : I) :
    fiberMass V (centered V x) i = 0 := by
  unfold fiberMass centered fiberAverage
  rw [Finset.sum_sub_distrib]
  simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  have hn : (Fintype.card (V i) : K) ≠ 0 :=
    Nat.cast_ne_zero.mpr Fintype.card_ne_zero
  field_simp
  simp [fiberMass]

omit [Fintype I] [CharZero K] [∀ i, Nonempty (V i)] in
/-- Every vector is the sum of its zero-mass fluctuation and its fiber-constant average. -/
lemma centered_add_average (x : FiberVec V K) :
    centered V x + fiberConstant V (fiberAverage V x) = x := by
  funext i u
  change (x i u - fiberAverage V x i) + fiberAverage V x i = x i u
  exact sub_add_cancel _ _

omit [Fintype I] in
/-- The intersection of fiber-constant vectors and fiberwise zero-mass vectors is zero. -/
lemma fiberConstant_eq_zero_of_zeroMass (z : I → K)
    (hz : ∀ i, fiberMass V (fiberConstant V z) i = 0) :
    fiberConstant V z = 0 := by
  funext i u
  have hi := hz i
  unfold fiberMass fiberConstant at hi
  simp only [Finset.sum_const, Finset.card_univ] at hi
  rw [nsmul_eq_mul] at hi
  have hn : (Fintype.card (V i) : K) ≠ 0 :=
    Nat.cast_ne_zero.mpr Fintype.card_ne_zero
  have hzi : z i = 0 := (mul_eq_zero.mp hi).resolve_left hn
  exact hzi

/-
**Invariant direct-sum theorem.** Under the standard Laplacian hypotheses, the generalized
join operator preserves both complementary summands: fiberwise zero-mass vectors remain
fiberwise zero-mass, and fiber-constant vectors remain fiber-constant.
-/
theorem invariant_splitting
    (L : (i : I) → (V i → K) → V i → K) (A : I → I → K)
    (hL : ∀ i (y : V i → K), (∑ u, y u) = 0 → ∑ u, L i y u = 0)
    (hconst : ∀ i (c : K), L i (fun _ => c) = 0) (x : FiberVec V K) :
    (∀ i, fiberMass V (joinAction V L A (centered V x)) i = 0) ∧
      ∃ z, joinAction V L A (fiberConstant V (fiberAverage V x)) = fiberConstant V z := by
  constructor;
  · exact zeroMass_invariant V L A hL _ ( fiberMass_centered V x );
  · exact ⟨ _, joinAction_fiberConstant V L A hconst _ ⟩

end Decomposition

end GeneralizedJoinDigraphs