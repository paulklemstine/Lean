/-
# Cycle 6: every cyclotomic polynomial `Φ_n` (`n ≥ 2`) is self-reciprocal

Cycle 4 proved `Φ_{pq}.reverse = Φ_{pq}` for distinct primes by transporting the Poincaré
duality symmetry of the torus knot `T(p,q)` through `Δ_{p,q} = Φ_{pq}`. This cycle removes
the hypothesis entirely: the same sign computation `(X^n − 1).reverse = −(X^n − 1)`, combined
with the divisor-product identity `∏_{d ∣ n} Φ_d = X^n − 1`, gives self-reciprocity of *every*
`Φ_n` with `n ≥ 2` by strong induction on `n`.

Main results:

* `reverse_prod` : `reverse` is multiplicative over finite products in `ℤ[X]`;
* `cyclotomic_reverse` : `Φ_n.reverse = Φ_n` for `n ≥ 2`;
* `cyclotomic_one_reverse_ne` : the bound `n ≥ 2` is sharp — `Φ_1 = X − 1` is anti-palindromic;
* `cyclotomic_coeff_symm` : the coefficient sequence of `Φ_n` is a palindrome.

The statement is a companion to the knot-theoretic symmetry: for `n = ab` with `a, b`
coprime and `> 1` it is exactly the palindromicity of the torus knot `T(a,b)` restricted to
its top cyclotomic factor.
-/
import Computation.AlexanderTorusKnot.Palindromic

namespace Computation.AlexanderTorusKnot

open Polynomial Finset

/-- `reverse` is multiplicative over finite products of integer polynomials. -/
lemma reverse_prod {ι : Type*} (s : Finset ι) (f : ι → ℤ[X]) :
    (∏ i ∈ s, f i).reverse = ∏ i ∈ s, (f i).reverse := by
  classical
  induction s using Finset.induction with
  | empty => simp [Polynomial.reverse]
  | insert a s ha ih =>
      rw [Finset.prod_insert ha, reverse_mul_of_domain, ih, Finset.prod_insert ha]

/-- **Cyclotomic reciprocity.** For `n ≥ 2` the cyclotomic polynomial `Φ_n` is its own
reverse. -/
theorem cyclotomic_reverse : ∀ {n : ℕ}, 2 ≤ n → (cyclotomic n ℤ).reverse = cyclotomic n ℤ := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro hn
    have hpos : 0 < n := by omega
    have hprod := prod_cyclotomic_eq_X_pow_sub_one hpos ℤ
    have h1mem : (1 : ℕ) ∈ n.divisors := Nat.one_mem_divisors.2 hpos.ne'
    have hnmem : n ∈ (n.divisors).erase 1 :=
      Finset.mem_erase.2 ⟨by omega, Nat.mem_divisors_self _ hpos.ne'⟩
    set S : Finset ℕ := ((n.divisors).erase 1).erase n with hS
    -- factor `X^n - 1 = (X - 1) * Φ_n * P`
    have hsplit : (X : ℤ[X]) ^ n - 1
        = (X - 1) * (cyclotomic n ℤ * ∏ d ∈ S, cyclotomic d ℤ) := by
      rw [← hprod, ← Finset.mul_prod_erase _ _ h1mem, cyclotomic_one,
        ← Finset.mul_prod_erase _ _ hnmem, hS]
    -- every remaining divisor is `≥ 2` and `< n`, so the induction hypothesis applies
    have hIH : ∀ d ∈ S, (cyclotomic d ℤ).reverse = cyclotomic d ℤ := by
      intro d hd
      rw [hS] at hd
      have hdn : d ≠ n := (Finset.mem_erase.1 hd).1
      have hd' := Finset.mem_of_mem_erase hd
      have hd1 : d ≠ 1 := (Finset.mem_erase.1 hd').1
      have hdmem : d ∈ n.divisors := (Finset.mem_erase.1 hd').2
      have hdvd : d ∣ n := (Nat.mem_divisors.1 hdmem).1
      have hdpos : 0 < d := Nat.pos_of_mem_divisors hdmem
      have hdlt : d < n := lt_of_le_of_ne (Nat.le_of_dvd hpos hdvd) hdn
      exact ih d hdlt (by omega)
    have hPrev : (∏ d ∈ S, cyclotomic d ℤ).reverse = ∏ d ∈ S, cyclotomic d ℤ := by
      rw [reverse_prod]
      exact Finset.prod_congr rfl hIH
    -- reverse the factorization
    have hrev := congrArg Polynomial.reverse hsplit
    rw [reverse_X_pow_sub_one hpos, reverse_mul_of_domain, reverse_mul_of_domain, hPrev] at hrev
    have hX1 : ((X : ℤ[X]) - 1).reverse = -((X : ℤ[X]) - 1) := by
      simpa using reverse_X_pow_sub_one (n := 1) one_pos
    rw [hX1] at hrev
    -- cancel `(X-1)` and `P`
    have hne1 : ((X : ℤ[X]) - 1) ≠ 0 := fun hc => by
      simpa using congrArg (Polynomial.eval 0) hc
    have hneP : (∏ d ∈ S, cyclotomic d ℤ) ≠ 0 :=
      (monic_prod_of_monic _ _ fun d _ => cyclotomic.monic d ℤ).ne_zero
    have hkey : (X - 1 : ℤ[X]) * ((cyclotomic n ℤ).reverse * ∏ d ∈ S, cyclotomic d ℤ)
        = (X - 1 : ℤ[X]) * (cyclotomic n ℤ * ∏ d ∈ S, cyclotomic d ℤ) := by
      have h := hrev
      rw [hsplit] at h
      linear_combination h
    have := mul_left_cancel₀ hne1 hkey
    exact mul_right_cancel₀ hneP this

/-- Sharpness: `Φ_1 = X - 1` is *anti*-palindromic, so the hypothesis `2 ≤ n` cannot be
dropped. -/
theorem cyclotomic_one_reverse_ne : (cyclotomic 1 ℤ).reverse ≠ cyclotomic 1 ℤ := by
  rw [cyclotomic_one]
  intro h
  have h0 := congrArg (Polynomial.eval 0) h
  rw [show ((X : ℤ[X]) - 1).reverse = -((X : ℤ[X]) - 1) by
    simpa using reverse_X_pow_sub_one (n := 1) one_pos] at h0
  simp at h0

/-- The coefficient sequence of `Φ_n` is a palindrome for `n ≥ 2`. -/
theorem cyclotomic_coeff_symm {n : ℕ} (hn : 2 ≤ n) {i : ℕ} (hi : i ≤ Nat.totient n) :
    (cyclotomic n ℤ).coeff i = (cyclotomic n ℤ).coeff (Nat.totient n - i) := by
  have hdeg : (cyclotomic n ℤ).natDegree = Nat.totient n := natDegree_cyclotomic n ℤ
  have h := congrArg (fun p => Polynomial.coeff p i) (cyclotomic_reverse hn)
  simp only [coeff_reverse, hdeg, revAt_le (by omega : i ≤ Nat.totient n)] at h
  exact h.symm

end Computation.AlexanderTorusKnot