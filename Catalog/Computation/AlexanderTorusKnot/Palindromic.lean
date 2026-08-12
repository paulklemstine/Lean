/-
# Poincaré duality on torus knots: `Δ_{a,b}` is palindromic, and cyclotomic reciprocity

Fourth cycle. Alexander polynomials of knots satisfy the duality `Δ(t) ≐ Δ(t⁻¹)`; for the
`(2,N)` pencil this is `Bridges.AlexanderKnotNumberBridgeIII.alexander_reverse`. Here we
prove it for **all** torus knots, directly from the defining identity of cycle 1, and we
harvest a purely number-theoretic corollary that is not in Mathlib: the cyclotomic
polynomial `Φ_{pq}` of a product of two distinct primes is self-reciprocal.

Main results:

* `reverse_X_pow_sub_one` : `(X^n - 1).reverse = -(X^n - 1)` for `n > 0`;
* `torusAlexander_reverse` : `Δ_{a,b}.reverse = Δ_{a,b}` for coprime `a, b > 0`;
* `torusAlexander_coeff_symm` : the coefficient sequence of `Δ_{a,b}` is a palindrome;
* `cyclotomic_semiprime_reverse` : `Φ_{pq}.reverse = Φ_{pq}` for distinct primes `p ≠ q`,
  obtained from the knot-theoretic symmetry via `Δ_{p,q} = Φ_{pq}`.

The last item is a genuine transfer of information *from* topology *to* number theory: the
symmetry of the Seifert form of a torus knot forces the reciprocity of a cyclotomic
polynomial.
-/
import Computation.AlexanderTorusKnot.Primality

namespace Computation.AlexanderTorusKnot

open Polynomial Finset

/-- Reversing `X^n - 1` flips its sign. -/
lemma reverse_X_pow_sub_one {n : ℕ} (hn : 0 < n) :
    ((X : ℤ[X]) ^ n - 1).reverse = -((X : ℤ[X]) ^ n - 1) := by
  have hdeg : ((X : ℤ[X]) ^ n - 1).natDegree = n := by
    have hC : ((X : ℤ[X]) ^ n - 1) = (X ^ n + C (-1)) := by simp [sub_eq_add_neg]
    rw [hC, natDegree_X_pow_add_C]
  ext m
  rw [coeff_reverse, hdeg]
  rcases le_or_gt m n with h | h
  · rw [revAt_le h]
    simp only [coeff_sub, coeff_X_pow, coeff_one, coeff_neg]
    by_cases hm0 : m = 0
    · subst hm0
      simp [hn.ne, hn.ne']
    · by_cases hmn : m = n
      · subst hmn
        simp [hn.ne, hn.ne']
      · rw [if_neg (by omega), if_neg (by omega), if_neg hmn, if_neg hm0]
        ring
  · rw [revAt_eq_self_of_lt h]
    have h1 : ((X : ℤ[X]) ^ n - 1).coeff m = 0 := by
      simp only [coeff_sub, coeff_X_pow, coeff_one]
      rw [if_neg (by omega), if_neg (by omega)]
      ring
    rw [h1, coeff_neg, h1, neg_zero]

/-- **Palindromicity of the torus-knot Alexander polynomial.** For coprime positive `a, b`,
`Δ_{a,b}` equals its own reverse — the polynomial shadow of the duality `Δ(t) ≐ Δ(t⁻¹)`. -/
theorem torusAlexander_reverse {a b : ℕ} (hab : Nat.Coprime a b) (ha : 0 < a) (hb : 0 < b) :
    (torusAlexander a b).reverse = torusAlexander a b := by
  have hspec := torusAlexander_spec hab ha hb
  have hrev := congrArg Polynomial.reverse hspec
  rw [reverse_mul_of_domain, reverse_mul_of_domain, reverse_mul_of_domain,
    reverse_X_pow_sub_one (Nat.mul_pos ha hb), reverse_X_pow_sub_one ha,
    reverse_X_pow_sub_one hb] at hrev
  have hX1 : ((X : ℤ[X]) - 1).reverse = -((X : ℤ[X]) - 1) := by
    simpa using reverse_X_pow_sub_one (n := 1) one_pos
  rw [hX1] at hrev
  -- `hrev` says `(X^{ab}-1)(X-1) = reverse Δ · (X^a-1)(X^b-1)`, up to the sign flips
  have hrev' : (X ^ (a * b) - 1 : ℤ[X]) * (X - 1)
      = (torusAlexander a b).reverse * ((X ^ a - 1) * (X ^ b - 1)) := by
    have := hrev
    ring_nf at this ⊢
    linear_combination this
  rw [hspec] at hrev'
  have hne : ((X : ℤ[X]) ^ a - 1) * (X ^ b - 1) ≠ 0 := by
    intro hc
    rcases mul_eq_zero.1 hc with h | h
    · have := congrArg (Polynomial.eval 0) h
      simp [zero_pow ha.ne'] at this
    · have := congrArg (Polynomial.eval 0) h
      simp [zero_pow hb.ne'] at this
  exact (mul_right_cancel₀ hne hrev').symm

/-- The coefficient sequence of `Δ_{a,b}` is a palindrome of length `(a-1)(b-1) + 1`. -/
theorem torusAlexander_coeff_symm {a b : ℕ} (hab : Nat.Coprime a b) (ha : 0 < a) (hb : 0 < b)
    {i : ℕ} (hi : i ≤ (a - 1) * (b - 1)) :
    (torusAlexander a b).coeff i
      = (torusAlexander a b).coeff ((a - 1) * (b - 1) - i) := by
  have hdeg := torusAlexander_natDegree hab ha hb
  have hrev := torusAlexander_reverse hab ha hb
  have h := congrArg (fun p => Polynomial.coeff p i) hrev
  simp only [coeff_reverse, hdeg, revAt_le hi] at h
  exact h.symm

/-- **Cyclotomic reciprocity from knot symmetry.** For distinct primes `p ≠ q`, the
cyclotomic polynomial `Φ_{pq}` is self-reciprocal. -/
theorem cyclotomic_semiprime_reverse {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q) :
    (cyclotomic (p * q) ℤ).reverse = cyclotomic (p * q) ℤ := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).2 hne
  have h := torusAlexander_reverse hcop hp.pos hq.pos
  rwa [torusAlexander_eq_cyclotomic_of_primes hp hq hne] at h

end Computation.AlexanderTorusKnot