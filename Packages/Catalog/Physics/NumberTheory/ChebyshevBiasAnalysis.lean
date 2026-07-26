import Mathlib

/-! # CatalogBuild.Physics.ChebyshevBiasAnalysis

Auto-generated from theorem catalog database.
Domain: Physics
Declarations: 6
-/

/-- Count primes in a residue class. -/
def primeCountInClass (bound modulus residue : ℕ) : ℕ :=
  ((Finset.range bound).filter (fun p => Nat.Prime p ∧ p % modulus = residue)).card

/-- Chebyshev bias mod 4: 87 primes ≡ 3 vs 80 primes ≡ 1 (mod 4) below 1000. -/
theorem chebyshev_bias_mod4 :
    primeCountInClass 1000 4 3 = 87 ∧ primeCountInClass 1000 4 1 = 80 := by
  unfold primeCountInClass; constructor <;> native_decide

/-- Chebyshev bias universality: mod 3 and mod 4 give EXACTLY identical counts
for non-residues (87) and residues (80) below 1000. -/
theorem chebyshev_bias_universality :
    primeCountInClass 1000 4 3 = primeCountInClass 1000 3 2 ∧
    primeCountInClass 1000 4 1 = primeCountInClass 1000 3 1 := by
  unfold primeCountInClass; constructor <;> native_decide

/-- Mod 5 bias: non-residues vs residues. -/
theorem chebyshev_bias_mod5 :
    primeCountInClass 1000 5 2 = 47 ∧
    primeCountInClass 1000 5 3 = 42 ∧
    primeCountInClass 1000 5 4 = 38 ∧
    primeCountInClass 1000 5 1 = 40 := by
  unfold primeCountInClass; refine ⟨?_, ?_, ?_, ?_⟩ <;> native_decide

/-- Prime race mod 4: the bias at several milestones. -/
theorem prime_race_mod4_milestones :
    primeCountInClass 100 4 3 = 13 ∧ primeCountInClass 100 4 1 = 11 ∧
    primeCountInClass 500 4 3 = 50 ∧ primeCountInClass 500 4 1 = 44 ∧
    primeCountInClass 1000 4 3 = 87 ∧ primeCountInClass 1000 4 1 = 80 := by
  unfold primeCountInClass; refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> native_decide

/-- The mod 6 distribution: primes > 3 are in classes 1 or 5.
86 primes ≡ 5 and 80 primes ≡ 1 (mod 6) below 1000.
(The extra prime ≡ 2 mod 3 vs mod 6 is p=2, since 2%3=2 but 2%6=2.) -/
theorem prime_mod6_distribution :
    primeCountInClass 1000 6 1 = 80 ∧ primeCountInClass 1000 6 5 = 86 := by
  unfold primeCountInClass; constructor <;> native_decide