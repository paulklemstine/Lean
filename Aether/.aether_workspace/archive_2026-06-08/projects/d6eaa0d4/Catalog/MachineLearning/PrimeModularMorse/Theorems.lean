/-
# Prime-Modular Morse Stability: Theorems

This file proves the core theorems establishing an arithmetic-to-real dictionary
for critical-point geometry of polynomial loss functions.

## Main results

1. `prime_stability_of_nondegenerate_critical_point`: For all but finitely many primes,
   nondegenerate integer critical points remain nondegenerate mod p.

2. `separableCritFiber_eq_decomp`: The critical fiber of a separable loss decomposes
   as a dependent product over one-variable critical fibers.

3. `realMorseIndexDiag_eq_negOneCount`: For ±1 sign patterns, the Morse index equals
   the count of -1 entries.

4. `diagSignProduct_eq_neg_one_pow_negOneCount`: The sign product of ±1 entries equals
   (-1)^(number of -1 entries), providing an arithmetic signature for the Morse index.

5. `diagHessianDet_eq_two_pow_mul_sign`: The Hessian determinant of a diagonal quadratic
   factors as 2^n times the sign product.
-/

import Mathlib
import Catalog.Speculative.PrimeModularMorse.Defs

open Polynomial PrimeModularMorse

namespace PrimeModularMorse

/-! ## Theorem 1: Separable critical fiber decomposition -/

/-
The critical fiber of a separable loss equals the decomposed form.
This is the structural theorem that converts high-dimensional critical geometry
into additive convolution over one-variable problems.
-/
theorem separableCritFiber_eq_decomp {n : ℕ} (R : Type*) [CommRing R]
    (fs : SeparableLossData n) (t : R) :
    separableCritFiber R fs t = separableCritFiberDecomp R fs t := by
  ext θ;
  constructor;
  · intro hθ;
    use fun i => eval ( θ i ) ( map ( Int.castRingHom R ) ( fs i ) );
    exact ⟨ hθ.2, fun i => ⟨ hθ.1 i, rfl ⟩ ⟩;
  · rintro ⟨ τ, hτ₁, hτ₂ ⟩;
    exact ⟨ fun i => ( hτ₂ i ).1, hτ₁ ▸ Finset.sum_congr rfl fun i _ => ( hτ₂ i ).2 ⟩

/-! ## Theorem 2: Prime stability of nondegenerate critical points -/

/-
**Key helper**: evaluating an integer polynomial at an integer cast to `ZMod p`
equals the cast of the integer evaluation.
-/
theorem eval_map_intCast (f : Polynomial ℤ) (a : ℤ) (p : ℕ) [NeZero p] :
    eval (a : ZMod p) (map (Int.castRingHom (ZMod p)) f) =
    ↑(eval a f) := by
  simp +decide

/-
If `f'(a) = 0` over `ℤ`, then `f'(ā) = 0` over `ZMod p` for any `p`.
-/
theorem critical_point_reduces_mod_p
    (f : Polynomial ℤ) (a : ℤ) (p : ℕ) [NeZero p]
    (hcrit : eval a (derivative f) = 0) :
    eval (a : ZMod p) (map (Int.castRingHom (ZMod p)) (derivative f)) = 0 := by
  -- Apply the theorem that evaluating a polynomial at an integer cast to ZMod p is the same as casting the evaluation of the polynomial at that integer.
  have := eval_map_intCast (derivative f) a p; aesop

/-
If `f''(a) ≠ 0` over `ℤ` and `p` does not divide `f''(a)`, then `f''(ā) ≠ 0` mod `p`.
-/
theorem second_deriv_nonzero_mod_p
    (f : Polynomial ℤ) (a : ℤ) (p : ℕ) [hp : Fact (Nat.Prime p)]
    (_hnondeg : eval a (derivative (derivative f)) ≠ 0)
    (hnotdvd : ¬((p : ℤ) ∣ eval a (derivative (derivative f)))) :
    eval (a : ZMod p)
      (map (Int.castRingHom (ZMod p)) (derivative (derivative f))) ≠ 0 := by
  convert hnotdvd using 1;
  norm_num [ ← ZMod.intCast_zmod_eq_zero_iff_dvd, eval_map ]

/-
**Prime stability theorem**: If `a` is a nondegenerate integer critical point of `f`,
then for all but finitely many primes, `ā` remains a nondegenerate critical point mod `p`.

This is the arithmetic analogue of structural stability in Morse theory:
local critical-point type survives almost all prime reductions.
-/
theorem prime_stability_of_nondegenerate_critical_point
    (f : Polynomial ℤ) (a : ℤ)
    (hcrit : eval a (derivative f) = 0)
    (hnondeg : eval a (derivative (derivative f)) ≠ 0) :
    ∃ S : Finset ℕ,
      ∀ p : ℕ, Nat.Prime p → p ∉ S →
        (eval (a : ZMod p) (map (Int.castRingHom (ZMod p)) (derivative f)) = 0 ∧
         eval (a : ZMod p)
           (map (Int.castRingHom (ZMod p)) (derivative (derivative f))) ≠ 0) := by
  have h_second_deriv_nonzero_mod_p : ∀ p : ℕ, Nat.Prime p → ¬(p : ℤ) ∣ eval a (derivative (derivative f)) → eval (a : ZMod p) (map (Int.castRingHom (ZMod p)) (derivative (derivative f))) ≠ 0 := by
    intro p hp hnotdvd;
    haveI := Fact.mk hp; simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ] ;
  refine' ⟨ _, fun p hp hps => ⟨ _, h_second_deriv_nonzero_mod_p p hp _ ⟩ ⟩;
  exact ( Int.natAbs ( eval a ( derivative ( derivative f ) ) ) |> Nat.primeFactors );
  · convert critical_point_reduces_mod_p f a p _;
    · exact ⟨ hp.ne_zero ⟩;
    · grind;
  · exact fun h => hps <| Nat.mem_primeFactors.mpr ⟨ hp, Int.natAbs_dvd_natAbs.mpr h, by aesop ⟩

/-! ## Theorem 3: Morse index for diagonal quadratics -/

/-
For a ±1 sign pattern, `ε i < 0` iff `ε i = -1`.
-/
theorem pm_one_neg_iff {n : ℕ} (ε : Fin n → ℤ)
    (hpm : ∀ i, ε i = 1 ∨ ε i = -1) (i : Fin n) :
    ε i < 0 ↔ ε i = -1 := by
  cases hpm i <;> simp +decide [ * ]

/-
**Morse index formula**: For ±1 sign patterns, the real Morse index equals
the count of -1 entries.
-/
theorem realMorseIndexDiag_eq_negOneCount {n : ℕ} (ε : Fin n → ℤ)
    (hpm : ∀ i, ε i = 1 ∨ ε i = -1) :
    realMorseIndexDiag ε = negOneCount ε := by
  exact Fintype.card_congr ( Equiv.subtypeEquivRight fun i => pm_one_neg_iff ε hpm i )

/-! ## Theorem 4: Sign product formula -/

/-
For ±1 entries, each `(ε i)² = 1`.
-/
theorem pm_one_sq_eq_one {n : ℕ} (ε : Fin n → ℤ)
    (hpm : ∀ i, ε i = 1 ∨ ε i = -1) (i : Fin n) :
    (ε i) ^ 2 = 1 := by
  cases hpm i <;> simp +decide [ * ]

/-
The sign product `∏ εᵢ` for ±1 entries equals `(-1)^(count of -1 entries)`.
This is the key arithmetic-to-Morse bridge: the product captures index parity.
-/
theorem diagSignProduct_eq_neg_one_pow_negOneCount {n : ℕ} (ε : Fin n → ℤ)
    (hpm : ∀ i, ε i = 1 ∨ ε i = -1) :
    diagSignProduct ε = (-1) ^ (negOneCount ε) := by
  unfold diagSignProduct negOneCount;
  rw [ Fintype.card_subtype ];
  rw [ ← Finset.prod_const, Finset.prod_filter ] ; exact Finset.prod_congr rfl fun i hi => by cases hpm i <;> simp +decide [ * ] ;

/-! ## Theorem 5: Hessian determinant factorization -/

/-
The Hessian determinant of a diagonal quadratic factors as `2^n · ∏ εᵢ`.
-/
theorem diagHessianDet_eq_two_pow_mul_sign {n : ℕ} (ε : Fin n → ℤ) :
    diagHessianDet ε = 2 ^ n * diagSignProduct ε := by
  unfold diagHessianDet diagSignProduct;
  rw [ Finset.prod_mul_distrib, Finset.prod_const, Finset.card_fin ]

/-! ## Theorem 6: Derivative commutes with reduction mod p -/

/-
The derivative commutes with ring map: `(map φ f)' = map φ (f')`.
This is the algebraic backbone connecting real and modular critical loci.
-/
theorem derivative_map_comm (f : Polynomial ℤ) (p : ℕ) [NeZero p] :
    derivative (map (Int.castRingHom (ZMod p)) f) =
    map (Int.castRingHom (ZMod p)) (derivative f) := by
  exact derivative_map f (Int.castRingHom (ZMod p))

/-!
## Falsifiable Conjecture (formalized as a comment)

**Conjecture: Asymptotic modular determination of Morse histograms**

For generic separable polynomial losses with integer coefficients and simple integral
critical points, there exists a finite exceptional set of primes S such that the family
of finite-field critical-value profiles `{critProfile_p(L, ·)}_{p ∉ S}` determines the
real Morse index histogram up to finitely many ambiguities.

**Computational refutation test**: Search over pairs of distinct separable losses L₁, L₂
of bounded degree. The conjecture is refuted if L₁ and L₂ have different real Morse
histograms but their mod-p critical profiles agree for all tested good primes beyond
some threshold.
-/

end PrimeModularMorse