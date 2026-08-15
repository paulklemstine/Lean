import MachineLearning.FreeWitnessSealing

/-!
# Cycle 5: beyond semiprimes — the product formula and a second information channel

The classification is stated for two factors, but its mechanism (a CRT-multiplicative
weight) says nothing about the number of factors.  This file pushes the SIGK witness to
arbitrary squarefree moduli and extracts a *second* leakage channel that the source paper
does not mention.

* `sigma_squarefree_prod` — for squarefree `N`,
  `σ_k(N) = ∏_{p ∣ N} (1 + p^k)`: the witness is the value at `1` of the local
  generating polynomial, for any number of prime factors.

* `two_adic_val_one_add_even_pow` — for an odd prime `p`, the local factor
  `1 + p^{2j}` is exactly `2 × odd`.

* `omega_eq_two_adic_valuation` — **the ω-channel.**  For odd squarefree `N` and every `j`,
  `v₂(σ_{2j}(N)) = ω(N)`,
  i.e. the 2-adic valuation of the witness *counts the prime factors of `N`*.  This is a
  genuine second factor-secret coordinate, obtained for free from the same scalar, and it
  is invisible in the two-factor picture (where it is the constant `2`).  It also shows
  that the "one coordinate per witness" slogan of the trace lemma is an artefact of the
  semiprime setting.

* `halfPlaneCount_not_polynomial` — the non-separable companion count `H(N)` of the
  catalog is not a polynomial in `N` either (`35 - 15 = 20` does not divide
  `H(35) - H(15) = 2`), so failing to be CRT-multiplicative does not make a count
  polynomial: the two barriers of the classification are logically independent.
-/

namespace FreeWitness

open ArithmeticFunction Finset

/-! ## The product formula for arbitrarily many factors -/

/-- **Product formula.**  For squarefree `N`, `σ_k(N) = ∏_{p ∣ N} (1 + p^k)`. -/
theorem sigma_squarefree_prod {k N : ℕ} (hsq : Squarefree N) :
    sigma k N = ∏ p ∈ N.primeFactors, (1 + p ^ k) := by
  have hprod : ∏ p ∈ N.primeFactors, p = N := Nat.prod_primeFactors_of_squarefree hsq
  have hpair : (↑N.primeFactors : Set ℕ).Pairwise (Function.onFun Nat.Coprime _root_.id) := by
    intro a ha b hb hab
    have hpa : a.Prime := Nat.prime_of_mem_primeFactors (by simpa using ha)
    have hpb : b.Prime := Nat.prime_of_mem_primeFactors (by simpa using hb)
    exact (Nat.coprime_primes hpa hpb).mpr hab
  have hmap := (isMultiplicative_sigma (k := k)).map_prod (_root_.id : ℕ → ℕ) N.primeFactors hpair
  simp only [_root_.id, hprod] at hmap
  rw [hmap]
  exact Finset.prod_congr rfl fun q hq => sigma_prime (Nat.prime_of_mem_primeFactors hq)

/-! ## The ω-channel: the 2-adic valuation counts the prime factors -/

/-- For an odd prime `p`, the local factor `1 + p^{2j}` has 2-adic valuation
exactly one: `p^{2j} ≡ 1 (mod 8)`, so `1 + p^{2j} ≡ 2 (mod 8)`. -/
theorem two_adic_val_one_add_even_pow {p j : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) :
    (1 + p ^ (2 * j)).factorization 2 = 1 := by
  have hodd : Odd p := hp.odd_of_ne_two hp2
  have h8 : (8 : ℤ) ∣ (p : ℤ) ^ (2 * j) - 1 := eight_dvd_even_pow_sub_one hodd j
  have hp1 : 1 ≤ p ^ (2 * j) := Nat.one_le_pow _ _ hp.pos
  have h8n : (8 : ℕ) ∣ p ^ (2 * j) - 1 := by
    have : ((p ^ (2 * j) - 1 : ℕ) : ℤ) = (p : ℤ) ^ (2 * j) - 1 := by
      push_cast [Nat.cast_sub hp1]
      ring
    exact_mod_cast this ▸ h8
  obtain ⟨t, ht⟩ := h8n
  have hval : 1 + p ^ (2 * j) = 2 * (4 * t + 1) := by omega
  have hne : 1 + p ^ (2 * j) ≠ 0 := by omega
  have hdvd : 2 ^ 1 ∣ 1 + p ^ (2 * j) := ⟨4 * t + 1, by omega⟩
  have hnot : ¬ (2 ^ 2 ∣ 1 + p ^ (2 * j)) := by
    rw [hval]
    intro hc
    obtain ⟨s, hs⟩ := hc
    omega
  have hle : 1 ≤ (1 + p ^ (2 * j)).factorization 2 :=
    (Nat.Prime.pow_dvd_iff_le_factorization Nat.prime_two hne).mp hdvd
  have hlt : ¬ (2 ≤ (1 + p ^ (2 * j)).factorization 2) := fun hc =>
    hnot ((Nat.Prime.pow_dvd_iff_le_factorization Nat.prime_two hne).mpr hc)
  omega

/-- **The ω-channel.**  For odd squarefree `N` and every `j`, the 2-adic valuation of
the witness equals the number of prime factors:
`v₂(σ_{2j}(N)) = ω(N)`.
So a single SIGK scalar leaks not only the trace of a semiprime but, in general, the
*number* of prime factors of the modulus. -/
theorem omega_eq_two_adic_valuation {j N : ℕ} (hodd : ¬ 2 ∣ N)
    (hsq : Squarefree N) :
    (sigma (2 * j) N).factorization 2 = N.primeFactors.card := by
  have hne : ∀ p ∈ N.primeFactors, (1 + p ^ (2 * j)) ≠ 0 := by
    intro p _
    positivity
  rw [sigma_squarefree_prod hsq, Nat.factorization_prod hne]
  simp only [Finset.sum_apply']
  rw [Finset.sum_congr rfl (fun p hp => ?_), Finset.sum_const, smul_eq_mul, mul_one]
  have hpp : p.Prime := Nat.prime_of_mem_primeFactors hp
  have hp2 : p ≠ 2 := by
    rintro rfl
    exact hodd (Nat.dvd_of_mem_primeFactors hp)
  exact two_adic_val_one_add_even_pow hpp hp2

/-- Two factors: the valuation is `2`, which is why the channel is invisible in the
semiprime setting. -/
theorem two_adic_valuation_semiprime {j p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q) :
    (sigma (2 * j) (p * q)).factorization 2 = 2 := by
  have hsq : Squarefree (p * q) :=
    (Nat.squarefree_mul_iff.mpr ⟨(Nat.coprime_primes hp hq).mpr hpq,
      hp.squarefree, hq.squarefree⟩)
  have hodd : ¬ 2 ∣ p * q := by
    intro hdvd
    rcases (Nat.Prime.dvd_mul Nat.prime_two).mp hdvd with h | h
    · exact hp2 ((Nat.prime_dvd_prime_iff_eq Nat.prime_two hp).mp h).symm
    · exact hq2 ((Nat.prime_dvd_prime_iff_eq Nat.prime_two hq).mp h).symm
  rw [omega_eq_two_adic_valuation (j := j) hodd hsq]
  rw [Nat.primeFactors_mul hp.ne_zero hq.ne_zero, hp.primeFactors, hq.primeFactors]
  rw [Finset.card_union_of_disjoint (by simp [hpq])]
  simp

/-! ## The two barriers are independent -/

/-- **The half-plane count is not a polynomial in `N` either.**  `H` is the catalog's
*non*-CRT-separable companion of the circle count; the witness pair `H(35) = 6`,
`H(15) = 4` with `35 - 15 = 20 ∤ 2` shows that leaving the CRT-multiplicative class does
not buy a polynomial closed form.  Non-separability and non-polynomiality are logically
independent properties of a counting aggregate. -/
theorem halfPlaneCount_not_polynomial :
    ∀ P : Polynomial ℤ, ¬ (∀ n ∈ ({15, 35} : Set ℕ),
      (HalfPlane.halfPlaneCount n : ℤ) = P.eval (n : ℤ)) := by
  have h35 : HalfPlane.halfPlaneCount 35 = 6 := by decide
  have h15 : HalfPlane.halfPlaneCount 15 = 4 := by decide
  refine not_polynomial_of_not_dvd (W := fun n => (HalfPlane.halfPlaneCount n : ℤ))
    (S := ({15, 35} : Set ℕ)) (N₁ := 35) (N₂ := 15) (by simp) (by simp) ?_
  simp only [h35, h15]
  norm_num

/-! ### Lab notes (cycle 5)

The ω-channel, `v₂(σ₂(N))` versus `ω(N)`:

```
N        factorisation   sigma_2(N)   v2(sigma_2)   omega(N)
15       3·5             260          2             2
105      3·5·7           13000        3             3
1155     3·5·7·11        1586000      4             4
15015    3·5·7·11·13     269620000    5             5
```
(`260 = 2^2·65`, `13000 = 2^3·1625`, `1586000 = 2^4·99125`,
`269620000 = 2^5·8425625`: each local factor `1 + p^2 = 2·odd` contributes exactly one
factor `2`, which is the content of `omega_eq_two_adic_valuation`.)

Half-plane (non-separable) count, difference test:
`H(15) = 4`, `H(21) = 4`, `H(33) = 8`, `H(35) = 6`, `H(51) = 12`;
`35 - 15 = 20` does not divide `H(35) - H(15) = 2`.
-/

example : HalfPlane.halfPlaneCount 33 = 8 := by decide

example : sigma 2 105 = 13000 := by decide

end FreeWitness