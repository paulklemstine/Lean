import Mathlib
import Bridges.TwoTreeClosure.PriceTwoAdicLaw

/-!
# The sharp two-adic cap conjecture is false: valuation-constant semiprimes

`Bridges.TwoTreeClosure.PriceTwoAdicLaw` proves the *death at position 2* of the Price
word: for `m ≡ 7 [MOD 16]` the number `N = 9m` has two odd factorisations whose two-adic
valuations differ, so no letter past position 1 is a function of `N`.  Direction 2 of
the previous cycle's `FUTURE_DIRECTIONS.md` conjectured the sharp converse:

> for **every** odd `N ≡ 7 (mod 8)` with two distinct odd factorisations, some two of
> them realise different values of `v₂(p + q)`,

which would have made the two-adic sensor a *complete* discriminator of factorisations
at `N ≡ 7 (mod 8)`.

This file **refutes** it, at the strongest possible level: an infinite family of
**semiprimes** on which the two-adic sensor is exactly constant.

For a prime `q ≡ 1 (mod 16)` put `N = 7q`.  Then `N ≡ 7 (mod 8)`, the only odd
factorisations of `N` are `1 · N` and `7 · q`, and

* `v₂(1 + N) = 3` because `7q + 1 ≡ 8 (mod 16)`,
* `v₂(7 + q) = 3` because `q ≡ 1 (mod 16)`.

So `v₂(p + q')` is the same for every factorisation: the sensor separates nothing.
By Dirichlet's theorem on primes in arithmetic progression there are infinitely many
such `q`, hence arbitrarily large such `N` (`two_adic_cap_conjecture_false`).
The smallest instance is `N = 119 = 7 · 17`, with `v₂(120) = v₂(24) = 3`.

Together with `Bridges.TwoTreeClosure.RepresentationOrbit` this closes both sharpening
attempts of the previous cycle in the negative: neither the geometric collision sensor
nor the two-adic sensor becomes a discriminator when restricted to the arithmetically
cleanest inputs.
-/

namespace TwoTreeClosure

/-! ### Divisor structure of a semiprime `7q` -/

/-- The factorisations of `7q`, for a prime `q`, are exactly `1 · 7q`, `7 · q`,
`q · 7` and `7q · 1`. -/
theorem factorisations_seven_mul {q a b : ℕ} (hq : q.Prime) (hab : a * b = 7 * q) :
    (a = 1 ∧ b = 7 * q) ∨ (a = 7 ∧ b = q) ∨ (a = q ∧ b = 7) ∨ (a = 7 * q ∧ b = 1) := by
  have h7 : Nat.Prime 7 := by norm_num
  have hqpos : 0 < q := hq.pos
  have hdvd : (7 : ℕ) ∣ a * b := ⟨q, hab⟩
  rcases (Nat.Prime.dvd_mul h7).1 hdvd with ⟨c, hc⟩ | ⟨c, hc⟩
  · subst hc
    have hcb : c * b = q := by
      refine Nat.eq_of_mul_eq_mul_left (show 0 < 7 by norm_num) ?_
      rw [← hab]; ring
    rcases hq.eq_one_or_self_of_dvd c ⟨b, hcb.symm⟩ with h | h
    · subst h
      exact Or.inr (Or.inl ⟨by ring, by omega⟩)
    · subst h
      have hb : b = 1 :=
        Nat.eq_of_mul_eq_mul_left hqpos (by rw [hcb]; ring)
      exact Or.inr (Or.inr (Or.inr ⟨by ring, hb⟩))
  · subst hc
    have hac : a * c = q := by
      refine Nat.eq_of_mul_eq_mul_left (show 0 < 7 by norm_num) ?_
      rw [← hab]; ring
    rcases hq.eq_one_or_self_of_dvd c ⟨a, by rw [← hac]; ring⟩ with h | h
    · subst h
      exact Or.inr (Or.inr (Or.inl ⟨by omega, by ring⟩))
    · subst h
      have ha : a = 1 :=
        Nat.eq_of_mul_eq_mul_right hqpos (by rw [hac]; ring)
      exact Or.inl ⟨ha, by ring⟩

/-! ### The valuation is constant on the family -/

/-- **Valuation-constant semiprimes.**  For a prime `q ≡ 1 (mod 16)`, the semiprime
`N = 7q` is `7` mod `8` and *every* factorisation `N = a · b` has `v₂(a + b) = 3`:
the two-adic sensor is constant across the factorisations of `N`. -/
theorem two_adic_constant_of_prime {q : ℕ} (hq : q.Prime) (hq16 : q % 16 = 1) :
    (7 * q) % 8 = 7 ∧ ∀ a b : ℕ, a * b = 7 * q → V2 (a + b) 3 := by
  have h1 : V2 (1 + 7 * q) 3 := by
    refine ⟨?_, ?_⟩
    · show (2 : ℕ) ^ 3 ∣ 1 + 7 * q
      norm_num
      omega
    · intro hdvd
      rw [show (2 : ℕ) ^ (3 + 1) = 16 from by norm_num] at hdvd
      omega
  have h2 : V2 (7 + q) 3 := by
    refine ⟨?_, ?_⟩
    · show (2 : ℕ) ^ 3 ∣ 7 + q
      norm_num
      omega
    · intro hdvd
      rw [show (2 : ℕ) ^ (3 + 1) = 16 from by norm_num] at hdvd
      omega
  refine ⟨by omega, ?_⟩
  intro a b hab
  rcases factorisations_seven_mul hq hab with ⟨ha, hb⟩ | ⟨ha, hb⟩ | ⟨ha, hb⟩ | ⟨ha, hb⟩ <;>
    subst ha <;> subst hb
  · exact h1
  · exact h2
  · rw [Nat.add_comm]; exact h2
  · rw [Nat.add_comm]; exact h1

/-- The concrete smallest witness: `119 = 7 · 17 ≡ 7 (mod 8)`, and both of its odd
factorisations have `v₂ = 3` (`120 = 8 · 15`, `24 = 8 · 3`). -/
theorem smallest_valuation_constant_semiprime :
    (119 : ℕ) % 8 = 7 ∧ Nat.Prime 7 ∧ Nat.Prime 17 ∧ 7 * 17 = 119 ∧
      V2 (1 + 119) 3 ∧ V2 (7 + 17) 3 := by
  refine ⟨by norm_num, by norm_num, by norm_num, by norm_num, ⟨by norm_num, ?_⟩,
    ⟨by norm_num, ?_⟩⟩
  · rintro ⟨c, hc⟩; omega
  · rintro ⟨c, hc⟩; omega

/-! ### Infinitely many, by Dirichlet -/

/-- **The sharp two-adic cap conjecture is false.**  Above every bound there is an odd
`N ≡ 7 (mod 8)` which is a product of two primes — so it has two distinct odd
factorisations — on which the two-adic sensor `v₂(a + b)` is *constant* over all
factorisations.  Hence the mechanism of `priceLetter_two_not_function_of_N` cannot be
upgraded to a statement about every `N ≡ 7 (mod 8)`. -/
theorem two_adic_cap_conjecture_false (T : ℕ) :
    ∃ N : ℕ, T < N ∧ N % 8 = 7 ∧ (∃ p q : ℕ, p.Prime ∧ q.Prime ∧ p ≠ q ∧ N = p * q) ∧
      ∀ a b : ℕ, a * b = N → V2 (a + b) 3 := by
  obtain ⟨q, hqT, hqp, hqmod⟩ :=
    Nat.forall_exists_prime_gt_and_modEq (max T 20) (q := 16) (a := 1) (by norm_num)
      (by norm_num)
  have hq16 : q % 16 = 1 := by
    have h : q % 16 = 1 % 16 := hqmod
    omega
  obtain ⟨-, hval⟩ := two_adic_constant_of_prime hqp hq16
  have hTle : T ≤ max T 20 := le_max_left _ _
  have h20 : 20 ≤ max T 20 := le_max_right _ _
  exact ⟨7 * q, by omega, by omega, ⟨7, q, by norm_num, hqp, by omega, rfl⟩, hval⟩

end TwoTreeClosure