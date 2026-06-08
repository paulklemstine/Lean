import Mathlib
import Speculative.PrimalityTesting.Defs

/-!
# AKS Primality Testing

This file formalizes the core algebraic criterion of the AKS primality test
and proves that primes satisfy the AKS polynomial congruence condition.

## Main results

* `aks_congruence_holds_for_prime` - Primes satisfy the AKS congruence
* `aks_criterion` - The AKS correctness criterion (partial)
* `isPerfectPower_spec` - Perfect power detection

## References

* Agrawal, Kayal, Saxena. "PRIMES is in P." Annals of Mathematics (2004)
-/

open Polynomial Finset Nat

/-! ## Perfect power infrastructure -/

/-- Check if n is a perfect power (n = a^b for some a, b ≥ 2). -/
def isPerfectPower (n : ℕ) : Bool :=
  if n ≤ 3 then false
  else
    let maxExp := Nat.log 2 n + 1
    (List.range (maxExp - 1)).any fun i =>
      let b := i + 2
      let a := n.sqrt  -- approximate; check nearby values
      -- Check if any base works for this exponent
      (List.range (a + 2)).any fun j =>
        let base := j
        base ^ b == n

/-
Specification of perfect power detection.
-/
theorem isPerfectPower_correct (n : ℕ) (hn : 4 ≤ n) :
    isPerfectPower n = true → ∃ a b : ℕ, 2 ≤ b ∧ n = a ^ b := by
      unfold isPerfectPower;
      grind

/-! ## Order modulo specification -/

/-
The multiplicative order satisfies its defining property.
-/
theorem orderMod_spec (n r : ℕ) (hcop : Nat.Coprime n r) (_hr : 1 < r) :
    n ^ orderMod n r ≡ 1 [MOD r] := by
      have h_order : orderOf (ZMod.unitOfCoprime (n : ℕ) hcop) ∣ orderMod n r := by
        unfold orderMod; aesop;
      have h_order : (ZMod.unitOfCoprime (n : ℕ) hcop) ^ orderMod n r = 1 := by
        rw [ ← orderOf_dvd_iff_pow_eq_one ] ; aesop;
      simpa [ ← ZMod.natCast_eq_natCast_iff ] using congr_arg ( fun x : ( ZMod r )ˣ => ( x : ZMod r ) ) h_order

/-
The order is positive when n and r are coprime and r > 1.
-/
theorem orderMod_pos (n r : ℕ) (hcop : Nat.Coprime n r) (_hr : 1 < r) (_hn : 1 < n) :
    0 < orderMod n r := by
      unfold orderMod;
      have h_order_pos : 0 < orderOf (ZMod.unitOfCoprime n hcop) := by
        have h_group : Finite (ZMod r)ˣ := by
          cases r <;> [ tauto; exact inferInstance ]
        exact?;
      aesop

/-! ## AKS congruence for primes -/

/-
The key algebraic fact: primes satisfy the AKS polynomial congruence.
    For prime p, `(X + a)^p ≡ X^p + a (mod (p, X^r - 1))`.

    This follows from the Frobenius endomorphism: in characteristic p,
    `(X + a)^p = X^p + a^p = X^p + a` since `a^p = a` in `ZMod p`.
-/
theorem aks_congruence_holds_for_prime
    (p r a : ℕ) (hp : Nat.Prime p) (_hr : 0 < r) :
    PolynomialCongruenceModXRMinusOne p r a := by
      -- By the properties of the Frobenius endomorphism in characteristic p, we have $(X + C a)^p = X^p + (C a)^p$.
      have h_frobenius : (Polynomial.X + Polynomial.C (a : ZMod p)) ^ p = Polynomial.X ^ p + Polynomial.C (a : ZMod p) := by
        haveI := Fact.mk hp; rw [ add_pow_char ];
        rw [ ← map_pow, ZMod.pow_card ];
      unfold PolynomialCongruenceModXRMinusOne;
      aesop

/-! ## AKS criterion (mathematical core) -/

/-- The AKS correctness criterion: if n satisfies the AKS conditions, then n is prime.

    Conditions:
    1. n ≥ 2
    2. n is not a perfect power
    3. There exists r with ord_r(n) > (log₂ n)²
    4. For all a ≤ ⌊√φ(r) · log₂ n⌋, the polynomial congruence holds

    Then n is prime. -/
theorem aks_criterion
    (n r : ℕ)
    (hn : 2 ≤ n)
    (hpowfree : ¬ ∃ a b : ℕ, 2 ≤ b ∧ 1 < a ∧ n = a ^ b)
    (hord : orderMod n r > (Nat.log 2 n) ^ 2)
    (hcong : ∀ a : ℕ, a ≤ bound_AKS n r →
        PolynomialCongruenceModXRMinusOne n r a)
    (hr_cop : Nat.Coprime n r)
    (hr : 1 < r) :
    Nat.Prime n := by sorry