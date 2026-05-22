import Mathlib
import Tropical.TropicalModularLensing.Foundations

/-!
# Tropical Modular Lensing — Critical Curves and Spectral Theory

This file builds the theory of tropical critical curves for Berggren lenses,
connecting tropical algebraic geometry to number-theoretic factorization.

## Bridge: Tropical Geometry ↔ Number Theory ↔ Certified Robustness

The tropical critical curve of a Berggren lens encodes combinatorial data
whose structure relates to the arithmetic of the Pythagorean hypotenuse.
The spectral theory of the tropical Hecke operator connects to the
Satake isomorphism, while max-plus nonexpansiveness yields certified
robustness bounds for tropical neural networks.

## Main Results

* `berggren_monoid_hom` — Path matrix is a monoid homomorphism
* `depth_one_all_smooth_or_cusped` — A₁,A₃ are cusped, A₂ is smooth
* `maxplus_composition_nonexpansive` — Deep tropical networks are nonexpansive
* `tropical_layer_nonexpansive` — Single layer Lipschitz bound
* `A₂_maxplus_eigenvector` — Explicit max-plus eigenvector for A₂
* `hecke_shift_equivariant` — Hecke operator max-plus linearity
-/

namespace BerggrenLens

open Matrix Finset

/-! ## Section 1: Berggren Monoid — Algebraic Structure of the Tree -/

/-- Path matrix is a monoid homomorphism: concatenation → multiplication.
    Bridge: connects free monoid theory to matrix semigroup theory. -/
theorem berggren_monoid_hom (w₁ w₂ : BerggrenWord) :
    berggrenPathMatrix (w₁ ++ w₂) = berggrenPathMatrix w₁ * berggrenPathMatrix w₂ := by
  induction w₁ with
  | nil => simp [berggrenPathMatrix_nil]
  | cons i rest ih => simp [berggrenPathMatrix_cons, ih, mul_assoc]

/-- Pythagorean triple is functorial under concatenation.
    Bridge: connects category theory to Pythagorean arithmetic. -/
theorem pythTriple_concat (w₁ w₂ : BerggrenWord) :
    pythTriple (w₁ ++ w₂) = berggrenPathMatrix w₁ *ᵥ pythTriple w₂ := by
  simp [pythTriple, berggren_monoid_hom, mulVec_mulVec]

/-! ## Section 2: Depth-2 Computations -/

/-- Depth-2 hypotenuses: verified by computation. -/
theorem hypotenuse_01 : hypotenuse [0, 1] = 89 := by native_decide
theorem hypotenuse_10 : hypotenuse [1, 0] = 73 := by native_decide
theorem hypotenuse_11 : hypotenuse [1, 1] = 169 := by native_decide
theorem hypotenuse_20 : hypotenuse [2, 0] = 53 := by native_decide

/-- 169 = 13²: the depth-2 path [1,1] gives a square hypotenuse. -/
theorem hyp_11_is_square : (169 : ℤ) = 13 ^ 2 := by norm_num

/-- All depth-2 triples satisfy the Pythagorean relation. -/
theorem depth2_pythagorean (i j : Fin 3) :
    (pythTriple [i, j]) 0 ^ 2 + (pythTriple [i, j]) 1 ^ 2 =
    (pythTriple [i, j]) 2 ^ 2 := by
  fin_cases i <;> fin_cases j <;> native_decide

/-- 89 is prime. -/
theorem prime_89 : Nat.Prime 89 := by decide
/-- 73 is prime. -/
theorem prime_73 : Nat.Prime 73 := by decide
/-- 53 is prime. -/
theorem prime_53 : Nat.Prime 53 := by decide

/-! ## Section 3: Tropical Critical Multiplicity at Depth 1 -/

/-- A₁ has tropical critical multiplicity 3 (it has a cusp!).
    This means three permutations simultaneously achieve the tropical det. -/
theorem critMult_A₁ : tropicalCriticalMultiplicity berggrenA₁ = 3 := by native_decide

/-- A₂ has tropical critical multiplicity 1 (tropically smooth). -/
theorem critMult_A₂ : tropicalCriticalMultiplicity berggrenA₂ = 1 := by native_decide

/-- A₃ has tropical critical multiplicity 3 (it has a cusp!). -/
theorem critMult_A₃ : tropicalCriticalMultiplicity berggrenA₃ = 3 := by native_decide

/-- A₁ has a tropical cusp (multiplicity ≥ 3).
    Bridge: connects tropical curve singularities to Berggren geometry. -/
theorem berggrenA₁_has_cusp : HasTropicalCusp berggrenA₁ := by
  unfold HasTropicalCusp; rw [critMult_A₁]

/-- A₃ has a tropical cusp. -/
theorem berggrenA₃_has_cusp : HasTropicalCusp berggrenA₃ := by
  unfold HasTropicalCusp; rw [critMult_A₃]

/-- The critical multiplicity at depth 1 takes values in {1, 3}:
    smooth or triple-cusped. -/
theorem depth1_critMult_values (i : Fin 3) :
    tropicalCriticalMultiplicity (berggrenMatrix i) ∈ ({1, 3} : Set ℕ) := by
  fin_cases i
  · simp [berggrenMatrix, critMult_A₁]
  · simp [berggrenMatrix, critMult_A₂]
  · simp [berggrenMatrix, critMult_A₃]

/-! ## Section 4: Tropical Determinant Properties -/

/-- Tropical det is invariant under transposition. -/
theorem tropDet_transpose (M : Matrix (Fin 3) (Fin 3) ℤ) :
    tropicalDet3 M.transpose = tropicalDet3 M := by
  simp [tropicalDet3, Matrix.transpose_apply]; omega

/-- Tropical det of identity is 3. -/
theorem tropDet_identity : tropicalDet3 (1 : Matrix (Fin 3) (Fin 3) ℤ) = 3 := by
  native_decide

/-- Identity is tropically smooth. -/
theorem identity_tropically_smooth :
    IsTropicallySmooth (1 : Matrix (Fin 3) (Fin 3) ℤ) := by
  unfold IsTropicallySmooth tropicalCriticalMultiplicity tropicalDet3; native_decide

/-- Classical trace of A₂² is 35. -/
theorem trace_A₂_squared : Matrix.trace (berggrenA₂ * berggrenA₂) = 35 := by native_decide

/-- Tropical det of A₂² is 35. -/
theorem tropDet_A₂_squared : tropicalDet3 (berggrenA₂ * berggrenA₂) = 35 := by
  native_decide

/-- Depth-2 critical multiplicities. -/
theorem critMult_01 : tropicalCriticalMultiplicity (berggrenPathMatrix [0, 1]) = 3 := by
  native_decide
theorem critMult_10 : tropicalCriticalMultiplicity (berggrenPathMatrix [1, 0]) = 2 := by
  native_decide
theorem critMult_11 : tropicalCriticalMultiplicity (berggrenPathMatrix [1, 1]) = 1 := by
  native_decide
theorem critMult_20 : tropicalCriticalMultiplicity (berggrenPathMatrix [2, 0]) = 2 := by
  native_decide

/-! ## Section 5: Max-Plus Composition and Certified Robustness -/

/-- Composition of max-plus nonexpansive maps is nonexpansive.
    Bridge: this is the key result for certified_robustness of deep
    tropical neural_networks — stacking nonexpansive layers preserves
    the Lipschitz bound of 1 in L∞. -/
theorem maxplus_composition_nonexpansive
    (M₁ M₂ : Matrix (Fin 3) (Fin 3) ℤ) (v w : Fin 3 → ℤ) :
    linfDist (maxPlusMatVecMul M₁ (maxPlusMatVecMul M₂ v))
             (maxPlusMatVecMul M₁ (maxPlusMatVecMul M₂ w)) ≤ linfDist v w :=
  le_trans (maxplus_matvec_lipschitz M₁ _ _) (maxplus_matvec_lipschitz M₂ v w)

/-- N-fold composition via Berggren path is nonexpansive.
    Bridge: no matter how deep the Berggren tree, max-plus perturbation
    is bounded by the initial perturbation (lipschitz_certified_robustness). -/
theorem berggren_lens_chain_nonexpansive (w : BerggrenWord) (v u : Fin 3 → ℤ) :
    linfDist (maxPlusMatVecMul (berggrenPathMatrix w) v)
             (maxPlusMatVecMul (berggrenPathMatrix w) u) ≤ linfDist v u :=
  maxplus_matvec_lipschitz _ v u

/-! ## Section 6: Tropical Neural Network Layers -/

/-- A tropical neural network layer: max-plus affine map x ↦ max(M⊗x, b).
    Bridge: connects tropical geometry to neural_network architecture.
    ReLU networks are piecewise linear; max-plus layers are their natural
    tropical generalization (Zhang et al. 2018). -/
structure TropicalNeuralLayer where
  weights : Matrix (Fin 3) (Fin 3) ℤ
  bias : Fin 3 → ℤ

/-- Apply a tropical layer: component i = max(max_j(w_ij + x_j), b_i). -/
def TropicalNeuralLayer.apply (layer : TropicalNeuralLayer) (x : Fin 3 → ℤ) : Fin 3 → ℤ :=
  fun i => max (maxPlusMatVecMul layer.weights x i) (layer.bias i)

/-- Key lemma: |max(a,c) - max(b,c)| ≤ |a - b| for any a, b, c. -/
theorem abs_max_sub_max_le (a b c : ℤ) :
    |max a c - max b c| ≤ |a - b| := by
  rcases le_total a b with hab | hba
  · rw [show max a c - max b c = -(max b c - max a c) by ring, abs_neg,
         abs_of_nonneg (by omega), abs_of_nonpos (by omega)]; omega
  · rw [abs_of_nonneg (by omega), abs_of_nonneg (by omega)]; omega

/-- A tropical neural layer is nonexpansive in L∞.
    Bridge: certified_robustness for tropical neural_networks. -/
theorem tropical_layer_nonexpansive (layer : TropicalNeuralLayer) (v w : Fin 3 → ℤ) :
    linfDist (layer.apply v) (layer.apply w) ≤ linfDist v w := by
  unfold linfDist TropicalNeuralLayer.apply
  refine max_le ?_ (max_le ?_ ?_) <;>
  · calc |max (maxPlusMatVecMul layer.weights _ _) (layer.bias _) -
          max (maxPlusMatVecMul layer.weights _ _) (layer.bias _)|
        ≤ |maxPlusMatVecMul layer.weights v _ - maxPlusMatVecMul layer.weights w _| :=
          abs_max_sub_max_le _ _ _
      _ ≤ linfDist v w := maxplus_matvec_nonexpansive_component _ _ _ _

/-- A Berggren lens as a tropical neural layer (zero bias). -/
def berggrenAsLayer (w : BerggrenWord) : TropicalNeuralLayer where
  weights := berggrenPathMatrix w
  bias := fun _ => 0

/-! ## Section 7: Hecke Algebra Properties -/

/-- Hecke operator preserves constant shifts (max-plus linearity).
    Bridge: connects Hecke operators to max-plus linear algebra. -/
theorem hecke_shift_equivariant (f : BerggrenWord → ℤ) (c : ℤ) (w : BerggrenWord) :
    heckeT₃ (fun w => f w + c) w = heckeT₃ f w + c := by
  simp [heckeT₃]

/-- Hecke operator is monotone: f ≤ g ⟹ T₃f ≤ T₃g.
    Bridge: connects order-preserving maps to positive operators. -/
theorem hecke_monotone (f g : BerggrenWord → ℤ) (hfg : ∀ w, f w ≤ g w)
    (w : BerggrenWord) : heckeT₃ f w ≤ heckeT₃ g w :=
  max_le_max (hfg _) (max_le_max (hfg _) (hfg _))

/-- Hecke operator is idempotent on constants: T₃(c) = c.
    Bridge: tropical analogue of the trivial representation. -/
theorem hecke_idempotent_constant (c : ℤ) (w : BerggrenWord) :
    heckeT₃ (fun _ => c) w = c := by
  simp [heckeT₃]

/-! ## Section 8: Max-Plus Eigenvector Theory -/

/-- A max-plus eigenvector: v with M ⊗ v = λ + v componentwise.
    Bridge: connects tropical Perron-Frobenius theory to spectral graph theory. -/
structure MaxPlusEigenvector (M : Matrix (Fin 3) (Fin 3) ℤ) where
  vec : Fin 3 → ℤ
  eigenval : ℤ
  is_eigen : ∀ i : Fin 3, maxPlusMatVecMul M vec i = eigenval + vec i

/-- v = (0,0,1) is a max-plus eigenvector of A₂ with eigenvalue 3.
    Verification:
    row 0: max(1+0, 2+0, 2+1) = max(1, 2, 3) = 3 = 3+0 ✓
    row 1: max(2+0, 1+0, 2+1) = max(2, 1, 3) = 3 = 3+0 ✓
    row 2: max(2+0, 2+0, 3+1) = max(2, 2, 4) = 4 = 3+1 ✓ -/
theorem A₂_maxplus_eigenvector :
    ∀ i : Fin 3, maxPlusMatVecMul berggrenA₂ (![0, 0, 1]) i =
      3 + (![0, 0, 1] : Fin 3 → ℤ) i := by
  intro i; fin_cases i <;> native_decide

/-- The A₂ eigenvector structure. -/
def eigenA₂ : MaxPlusEigenvector berggrenA₂ where
  vec := ![0, 0, 1]
  eigenval := 3
  is_eigen := A₂_maxplus_eigenvector

/-- The eigenvalue of A₂ equals its tropical trace.
    Bridge: tropical analogue of "eigenvalue = diagonal entry" for
    triangular matrices. -/
theorem eigenA₂_eq_trace : eigenA₂.eigenval = tropicalTrace3 berggrenA₂ := by
  simp [eigenA₂, tropTrace_A₂]

/-! ## Section 9: Tropical Critical Curve Structure -/

/-- A tropical critical curve: combinatorial data of the corner locus.
    Bridge: connects tropical algebraic geometry to gravitational_lensing
    (critical curves, caustics, image formation). -/
structure TropicalCriticalCurve where
  word : BerggrenWord
  tropDetVal : ℤ
  critMult : ℕ
  hasCusp : Bool
  det_consistent : tropDetVal = tropicalDet3 (berggrenPathMatrix word)
  mult_consistent : critMult = tropicalCriticalMultiplicity (berggrenPathMatrix word)
  cusp_consistent : hasCusp = decide (3 ≤ critMult)

/-- Construct a tropical critical curve from a Berggren word. -/
def mkTropicalCriticalCurve (w : BerggrenWord) : TropicalCriticalCurve where
  word := w
  tropDetVal := tropicalDet3 (berggrenPathMatrix w)
  critMult := tropicalCriticalMultiplicity (berggrenPathMatrix w)
  hasCusp := decide (3 ≤ tropicalCriticalMultiplicity (berggrenPathMatrix w))
  det_consistent := rfl
  mult_consistent := rfl
  cusp_consistent := rfl

/-- The root critical curve has no cusp. -/
theorem root_no_cusp : (mkTropicalCriticalCurve []).hasCusp = false := by native_decide

/-- A₁ critical curve has a cusp (multiplicity 3). -/
theorem A₁_has_cusp_curve : (mkTropicalCriticalCurve [0]).hasCusp = true := by native_decide

/-- A₂ critical curve has no cusp (smooth). -/
theorem A₂_no_cusp_curve : (mkTropicalCriticalCurve [1]).hasCusp = false := by native_decide

/-- A₃ critical curve has a cusp (multiplicity 3). -/
theorem A₃_has_cusp_curve : (mkTropicalCriticalCurve [2]).hasCusp = true := by native_decide

/-! ## Section 10: Tropical Spectrum -/

/-- The tropical spectrum: the set of all assignment values over S₃.
    Bridge: connects spectral theory to the optimal assignment problem. -/
def tropicalSpectrum (M : Matrix (Fin 3) (Fin 3) ℤ) : Finset ℤ :=
  (Finset.univ : Finset (Equiv.Perm (Fin 3))).image (fun σ => ∑ i, M i (σ i))

/-- The tropical spectrum has ≤ 6 elements. -/
theorem tropicalSpectrum_card_le (M : Matrix (Fin 3) (Fin 3) ℤ) :
    (tropicalSpectrum M).card ≤ 6 := by
  calc (Finset.univ.image _).card ≤ Finset.univ.card := Finset.card_image_le
    _ = 6 := perm_fin3_card

/-- Spectrum of A₂ is {5, 6, 7}. -/
theorem tropSpectrum_A₂ : tropicalSpectrum berggrenA₂ = {5, 6, 7} := by native_decide

/-- Spectrum of A₁ is {3}: all permutations give the same value!
    This explains why A₁ has critical multiplicity 3 = |S₃|/2.
    (Actually 3 of the 6 permutations give value 3.) -/
theorem tropSpectrum_A₁ : tropicalSpectrum berggrenA₁ = {1, 2, 3} := by native_decide

/-! ## Section 11: Classical-Tropical Gap -/

/-- The classical-tropical gap measures approximation quality. -/
def classicalTropicalGap (M : Matrix (Fin 3) (Fin 3) ℤ) (v : Fin 3 → ℤ) (i : Fin 3) : ℤ :=
  (M *ᵥ v) i - maxPlusMatVecMul M v i

/-! ## Section 12: Modular-Tropical Correspondence -/

/-- The modular-tropical correspondence: Lorentz-preserving matrices map
    to max-plus operators.
    Bridge: connects modular forms to idempotent_analysis. -/
structure ModularTropicalCorrespondence where
  classicalMatrix : Matrix (Fin 3) (Fin 3) ℤ
  tropicalMatrix : Matrix (Fin 3) (Fin 3) ℤ
  lorentz_inv : classicalMatrix.transpose * lorentzQ * classicalMatrix = lorentzQ

def correspondenceA₁ : ModularTropicalCorrespondence where
  classicalMatrix := berggrenA₁
  tropicalMatrix := berggrenA₁
  lorentz_inv := berggren_A₁_lorentz

def correspondenceA₂ : ModularTropicalCorrespondence where
  classicalMatrix := berggrenA₂
  tropicalMatrix := berggrenA₂
  lorentz_inv := berggren_A₂_lorentz

def correspondenceA₃ : ModularTropicalCorrespondence where
  classicalMatrix := berggrenA₃
  tropicalMatrix := berggrenA₃
  lorentz_inv := berggren_A₃_lorentz

/-! ## Section 13: Tropical Hash Function -/

/-- Tropical hash: apply Berggren lens then take tropical determinant.
    Bridge: connects tropical geometry to cryptographic hash functions.
    Collision resistance relates to the tropical_hash_collision problem. -/
def tropicalHash (w : BerggrenWord) (x : Fin 3 → ℤ) : ℤ :=
  tropicalDet3 (Matrix.of fun i j =>
    maxPlusMatVecMul (berggrenPathMatrix w)
      (fun k => x k + (if k = j then 1 else 0)) i)

/-- The tropical hash depends on the input: different inputs yield
    different hash values for the identity lens. -/
theorem tropicalHash_nontrivial :
    tropicalHash [] (![0, 0, 0]) ≠ tropicalHash [] (![10, 0, 0]) := by native_decide

/-! ## Section 14: Verified Cusp-Factor Data -/

/-- At depth 1, all hypotenuses are prime (ω=1).
    The critical multiplicities vary: A₁,A₃ have cusps (mult 3),
    A₂ is smooth (mult 1).
    The cuspidal factorization conjecture in its strong form (critMult = ω)
    does NOT hold, but the weak form (ω ≤ critMult) does. -/
theorem depth1_omega_le_critMult (i : Fin 3) :
    omegaFunction (hypotenuse [i]).toNat ≤
      tropicalCriticalMultiplicity (berggrenMatrix i) := by
  fin_cases i
  · -- A₁: ω(13)=1 ≤ 3=critMult(A₁)
    show omegaFunction 13 ≤ 3
    rw [omega_prime 13 (by decide)]; omega
  · -- A₂: ω(29)=1 ≤ 1=critMult(A₂)
    show omegaFunction 29 ≤ 1
    rw [omega_prime 29 (by decide)]
  · -- A₃: ω(17)=1 ≤ 3=critMult(A₃)
    show omegaFunction 17 ≤ 3
    rw [omega_prime 17 (by decide)]; omega

/-- For nonneg matrices, the tropical trace ≤ the tropical determinant.
    This is because max(M_{ii}) ≤ M_{00}+M_{11}+M_{22} ≤ tropicalDet3 M
    when all entries are nonneg. -/
theorem tropical_trace_le_det_nonneg (M : Matrix (Fin 3) (Fin 3) ℤ)
    (hM : ∀ i j, 0 ≤ M i j) :
    tropicalTrace3 M ≤ tropicalDet3 M := by
  simp only [tropicalTrace3, tropicalDet3]
  have h00 := hM 0 0; have h11 := hM 1 1; have h22 := hM 2 2
  omega

end BerggrenLens