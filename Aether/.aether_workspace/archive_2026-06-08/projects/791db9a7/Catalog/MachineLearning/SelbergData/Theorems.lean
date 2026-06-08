/-
# Theorems on Selberg Data Algebra

## Main Results

1. **Spectral complexity is additive** under the Rankin-Selberg product
2. **Counting bound factorization**: N_{d₁+d₂}(Q,B) = N_{d₁}(1,B) · N_{d₂}(Q,B)
3. **Tropical valuation homomorphism**: spectral complexity → tropical semiring
4. **Well-foundedness**: the strict factorization order is well-founded
5. **Tropical semiring axioms**: idempotency, identity, associativity, commutativity
6. **Spectral entropy bounds**
-/
import MachineLearning.SelbergData.Defs

open Finset BigOperators

namespace SelbergDatum

/-! ## Spectral Complexity Additivity -/

/-
**Spectral complexity is additive under the Rankin-Selberg product.**
  This is the key property making it a "tropical valuation" — it transforms
  the multiplicative monoid structure into additive structure.
-/
theorem spectralComplexity_add (a b : SelbergDatum) :
    spectralComplexity (a * b) = spectralComplexity a + spectralComplexity b := by
  unfold SelbergDatum.spectralComplexity;
  convert congr_arg₂ ( · + · ) ( SelbergDatum.mul_degree a b ) ( SelbergDatum.mul_spectral_dim a b ) using 1 ; ring

/-! ## Counting Bound Identities -/

/-
The counting bound is explicitly Q * (2(2B+1))^d.
-/
theorem countingBound_eq (d Q B : ℕ) :
    countingBound d Q B = Q * (2 * (2 * B + 1)) ^ d := by
  rfl

/-
The counting bound at conductor 1 reduces to the exponential factor.
-/
theorem countingBound_unit_conductor (d B : ℕ) :
    countingBound d 1 B = (2 * (2 * B + 1)) ^ d := by
  exact one_mul _

/-
**Factorization identity for the counting bound.**
  N_{d₁+d₂}(Q, B) = N_{d₁}(1, B) · N_{d₂}(Q, B)

  This connects the algebraic product structure (degree addition) to the
  combinatorial counting function. The factorization reflects the Cartesian
  product decomposition of the parameter space of a product L-function.
-/
theorem countingBound_factorization (d₁ d₂ Q B : ℕ) :
    countingBound (d₁ + d₂) Q B = countingBound d₁ 1 B * countingBound d₂ Q B := by
  unfold countingBound; ring;

/-
The counting bound at degree 0 equals Q (just the conductor count).
-/
theorem countingBound_degree_zero (Q B : ℕ) :
    countingBound 0 Q B = Q := by
  unfold countingBound; norm_num;

/-
Growth rate: the counting bound at degree d+1 is a fixed multiple of degree d.
-/
theorem countingBound_succ (d Q B : ℕ) :
    countingBound (d + 1) Q B = countingBound d Q B * (2 * (2 * B + 1)) := by
  unfold countingBound; ring;

/-
Monotonicity of counting bound in conductor bound.
-/
theorem countingBound_mono_conductor {Q₁ Q₂ : ℕ} (h : Q₁ ≤ Q₂) (d B : ℕ) :
    countingBound d Q₁ B ≤ countingBound d Q₂ B := by
  exact Nat.mul_le_mul_right _ h

/-! ## Tropical Valuation -/

/-- The tropical valuation map. -/
def tropicalVal (s : SelbergDatum) : TropicalNat :=
  TropicalNat.ofNat' (spectralComplexity s)

/-
**The tropical valuation is a multiplicative homomorphism:**
  it sends the Rankin-Selberg product to tropical multiplication.
  This is the formal statement that spectral complexity provides
  a bridge between the Selberg data monoid and tropical algebra.
-/
theorem tropicalVal_mul (a b : SelbergDatum) :
    tropicalVal (a * b) = tropicalVal a * tropicalVal b := by
  exact congr_arg TropicalNat.ofNat' ( spectralComplexity_add a b )

/-
The tropical valuation sends the unit to tropical 1.
-/
theorem tropicalVal_one : tropicalVal 1 = 1 := by
  rfl

/-! ## Well-Founded Factorization Order -/

/-
**The strict factorization order is well-founded.**
  This follows because `strictDiv a b` implies `a.degree < b.degree`,
  and `<` on `ℕ` is well-founded. This guarantees that every Selberg
  datum has a unique factorization into irreducible data (by Noetherian
  induction on the degree).
-/
theorem strictDiv_wellFounded : WellFounded strictDiv := by
  have h_wf : WellFounded (fun a b : ℕ => a < b) := by
    exact wellFounded_lt;
  have h_wf : WellFounded (fun a b : SelbergDatum => a.degree < b.degree) := by
    convert h_wf using 1;
    constructor <;> intro h <;> rw [ WellFounded.wellFounded_iff_has_min ] at *;
    · exact h_wf;
    · intro s hs; specialize h ( s.image ( fun x => x.degree ) ) ; aesop;
  exact h_wf.mono fun a b h => h.2

/-! ## Tropical Semiring Laws -/

/-
Tropical addition is commutative.
-/
theorem tropical_add_comm (a b : TropicalNat) : a + b = b + a := by
  exact congr_arg _ ( min_comm _ _ )

/-
Tropical addition is associative.
-/
theorem tropical_add_assoc (a b c : TropicalNat) : a + b + c = a + (b + c) := by
  exact congr_arg TropicalNat.mk ( by apply min_assoc )

/-
Tropical addition is idempotent: min(a, a) = a.
-/
theorem tropical_add_idem (a : TropicalNat) : a + a = a := by
  cases a ; aesop

/-
Tropical zero is the additive identity: min(∞, a) = a.
-/
theorem tropical_zero_add (a : TropicalNat) : 0 + a = a := by
  exact TropicalNat.ext ( by simp +decide )

/-
Tropical multiplication is commutative.
-/
theorem tropical_mul_comm (a b : TropicalNat) : a * b = b * a := by
  -- TropicalNat.ext, simp, add_comm
  apply TropicalNat.ext
  simp [add_comm]

/-
Tropical multiplication is associative.
-/
theorem tropical_mul_assoc (a b c : TropicalNat) : a * b * c = a * (b * c) := by
  exact congr_arg ( fun x => TropicalNat.mk x ) ( add_assoc _ _ _ )

/-
Tropical one is the multiplicative identity.
-/
theorem tropical_one_mul (a : TropicalNat) : 1 * a = a := by
  cases a ; aesop

/-
Tropical zero absorbs multiplication: ∞ + a = ∞.
-/
theorem tropical_zero_mul (a : TropicalNat) : 0 * a = 0 := by
  exact TropicalNat.ext ( by simp +decide )

/-
**Tropical distributivity**: multiplication distributes over
  min-plus addition. This is the key non-trivial semiring axiom.
-/
theorem tropical_distrib (a b c : TropicalNat) :
    a * (b + c) = a * b + (a * c) := by
  exact congr_arg _ ( min_add_add_left _ _ _ |> Eq.symm )

/-! ## Spectral Entropy Bounds -/

/-
Spectral entropy is bounded below by spectral dimension.
-/
theorem spectralEntropy_ge_spectral_dim (s : SelbergDatum) :
    s.spectral_dim ≤ s.spectralEntropy := by
  exact Nat.le_add_left _ _

/-
For a product, spectral entropy preserves the spectral dimension component.
-/
theorem spectralEntropy_product_spectral_bound (a b : SelbergDatum) :
    a.spectral_dim + b.spectral_dim ≤ (a * b).spectralEntropy := by
  convert spectralEntropy_ge_spectral_dim ( a * b ) using 1

/-! ## Realization Count Bound -/

/-
The realization count is trivially bounded by Q.
-/
theorem realizationCount_le (P : RealizationPredicate) [DecidablePred P]
    (d Q B : ℕ) : realizationCount P d Q B ≤ Q := by
  exact le_trans ( Finset.card_filter_le _ _ ) (by simp)

end SelbergDatum