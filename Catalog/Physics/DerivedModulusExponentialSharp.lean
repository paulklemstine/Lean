import Mathlib
import Physics.DerivedModulusNoGo
import Physics.DerivedModulusHintFrontier

/-!
# Sharpness of the no-go: leaving the polynomial class restores leakage

Every result in this development so far says that an `N`-explicit **polynomial**
modulus is arithmetically invisible to `N`.  A no-go theorem is only as
interesting as its boundary, so this file shows the hypothesis cannot be
dropped: the *exponential* derived modulus `M(N) = 2^N - 1` — which is not
congruence-transporting, since `N ↦ 2^N` does not satisfy `a - b ∣ f(a) - f(b)`
— does share primes with `N`, for infinitely many `N`, and in favourable cases
it actually **factors a semiprime**.

## Main results

* `Physics.DerivedModulus.prime_dvd_mersenne_iff` : `p ∣ 2^N - 1` iff the
  multiplicative order of `2` mod `p` divides `N`.
* `Physics.DerivedModulus.mersenne_leak_criterion` : if `p ∣ N` and
  `ord_p(2) ∣ N`, the gcd attack on `2^N - 1` returns a multiple of `p`.
* `Physics.DerivedModulus.mersenne_sharing_infinite` : infinitely many `N`
  satisfy `gcd(N, 2^N - 1) > 1` — in sharp contrast with
  `sharedPrimes_finite` for polynomial moduli.
* `Physics.DerivedModulus.mersenne_factors_253` : an explicit factorisation,
  `gcd(253, 2^253 - 1) = 23` with `253 = 11 · 23`; the exponential modulus
  recovers a prime factor of a semiprime that no polynomial modulus can.
* `Physics.DerivedModulus.polynomial_hypothesis_necessary` : the two facts side
  by side, i.e. the barrier is tight to the polynomial class.
-/

namespace Physics.DerivedModulus

/-- `p` divides the Mersenne-type modulus `2^N - 1` exactly when the order of
`2` modulo `p` divides `N`.  (Stated for odd primes; `2 ∣ 2^N - 1` fails for
`N ≥ 1` anyway.) -/
theorem prime_dvd_mersenne_iff {p : ℕ} (hp : p.Prime) (N : ℕ) :
    p ∣ 2 ^ N - 1 ↔ orderOf (2 : ZMod p) ∣ N := by
  haveI : Fact p.Prime := ⟨hp⟩
  rw [← Nat.modEq_iff_dvd' Nat.one_le_two_pow]
  rw [show (orderOf (2 : ZMod p) ∣ N) ↔ ((2 : ZMod p) ^ N = 1) from
    orderOf_dvd_iff_pow_eq_one]
  constructor
  · intro h
    have hz : ((1 : ℕ) : ZMod p) = ((2 ^ N : ℕ) : ZMod p) :=
      (ZMod.natCast_eq_natCast_iff _ _ _).mpr h
    push_cast at hz
    exact hz.symm
  · intro h
    have hz : ((1 : ℕ) : ZMod p) = ((2 ^ N : ℕ) : ZMod p) := by push_cast; exact h.symm
    exact (ZMod.natCast_eq_natCast_iff _ _ _).mp hz

/-- **Leak criterion.**  If a prime factor `p` of `N` has `ord_p(2) ∣ N`, then
the exponential derived modulus exposes `p`. -/
theorem mersenne_leak_criterion {p N : ℕ} (hp : p.Prime) (hpN : p ∣ N)
    (hord : orderOf (2 : ZMod p) ∣ N) : p ∣ Nat.gcd N (2 ^ N - 1) :=
  Nat.dvd_gcd hpN ((prime_dvd_mersenne_iff hp N).mpr hord)

/-- Concrete infinite family: every multiple of `6` shares the prime `3` with
its exponential modulus. -/
theorem three_dvd_mersenne_gcd (k : ℕ) : 3 ∣ Nat.gcd (6 * (k + 1)) (2 ^ (6 * (k + 1)) - 1) := by
  refine Nat.dvd_gcd ⟨2 * (k + 1), by ring⟩ ?_
  have h1 : (1 : ℕ) ≡ 2 ^ 2 [MOD 3] := by decide
  have h2 : (2 : ℕ) ^ (6 * (k + 1)) = ((2 : ℕ) ^ 2) ^ (3 * (k + 1)) := by
    rw [← pow_mul]; ring_nf
  have h3 : (1 : ℕ) ≡ 2 ^ (6 * (k + 1)) [MOD 3] := by
    rw [h2]; simpa using h1.pow (3 * (k + 1))
  exact (Nat.modEq_iff_dvd' Nat.one_le_two_pow).mp h3

/-- **Contrast with `sharedPrimes_finite`.**  For the exponential modulus the
set of inputs sharing a factor with their derived modulus is infinite, whereas
for a polynomial modulus the shared *primes* are confined to the divisors of
`f(0)`. -/
theorem mersenne_sharing_infinite : {N : ℕ | 1 < Nat.gcd N (2 ^ N - 1)}.Infinite := by
  apply Set.infinite_of_injective_forall_mem (f := fun k : ℕ => 6 * (k + 1))
  · intro a b hab
    simpa using hab
  · intro k
    have h3 := three_dvd_mersenne_gcd k
    have hpos : 0 < Nat.gcd (6 * (k + 1)) (2 ^ (6 * (k + 1)) - 1) :=
      Nat.gcd_pos_of_pos_left _ (by positivity)
    have hle := Nat.le_of_dvd hpos h3
    simp only [Set.mem_setOf_eq]
    omega

/-- **Semiprime leak criterion.**  For a semiprime `N = p·q` with `p` an odd
prime, the exponential modulus exposes `p` exactly when the order of `2`
modulo `p` divides the *other* factor `q`.  This is the precise (and, for
random RSA primes, very rare) condition under which a non-polynomial derived
modulus factors `N`. -/
theorem mersenne_semiprime_leak_iff {p q : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) :
    p ∣ 2 ^ (p * q) - 1 ↔ orderOf (2 : ZMod p) ∣ q := by
  haveI : Fact p.Prime := ⟨hp⟩
  have h2ne : (2 : ZMod p) ≠ 0 := by
    intro h
    have : ((2 : ℕ) : ZMod p) = 0 := by push_cast; exact h
    exact hp2 ((Nat.prime_dvd_prime_iff_eq hp (by norm_num)).mp
      ((ZMod.natCast_eq_zero_iff _ _).mp this))
  have hord : orderOf (2 : ZMod p) ∣ p - 1 :=
    orderOf_dvd_of_pow_eq_one (ZMod.pow_card_sub_one_eq_one h2ne)
  have hpos : 0 < orderOf (2 : ZMod p) := by
    rcases Nat.eq_zero_or_pos (orderOf (2 : ZMod p)) with h0 | h
    · exfalso
      rw [h0] at hord
      have h2le := hp.two_le
      have : p - 1 = 0 := Nat.eq_zero_of_zero_dvd hord
      omega
    · exact h
  rw [prime_dvd_mersenne_iff hp]
  constructor
  · intro hdvd
    have hp2' := hp.two_le
    have hcop : Nat.Coprime (orderOf (2 : ZMod p)) p := by
      rcases Nat.coprime_or_dvd_of_prime hp (orderOf (2 : ZMod p)) with h | h
      · exact h.symm
      · exfalso
        have hle : p ≤ orderOf (2 : ZMod p) := Nat.le_of_dvd hpos h
        have hdle : orderOf (2 : ZMod p) ≤ p - 1 := Nat.le_of_dvd (by omega) hord
        omega
    exact hcop.dvd_of_dvd_mul_left hdvd
  · intro h
    exact h.trans (Dvd.intro_left p rfl)

/-! ## An explicit factorisation by an exponential modulus -/

theorem twentythree_dvd : (23 : ℕ) ∣ 2 ^ 253 - 1 := by
  have h1 : (1 : ℕ) ≡ 2 ^ 11 [MOD 23] := by decide
  have h2 : (2 : ℕ) ^ 253 = ((2 : ℕ) ^ 11) ^ 23 := by rw [← pow_mul]
  have h3 : (1 : ℕ) ≡ 2 ^ 253 [MOD 23] := by
    rw [h2]; simpa using h1.pow 23

  exact (Nat.modEq_iff_dvd' Nat.one_le_two_pow).mp h3

theorem eleven_not_dvd : ¬ ((11 : ℕ) ∣ 2 ^ 253 - 1) := by
  intro h
  have h3 : (1 : ℕ) ≡ 2 ^ 253 [MOD 11] := (Nat.modEq_iff_dvd' Nat.one_le_two_pow).mpr h
  have h1 : (1 : ℕ) ≡ 2 ^ 10 [MOD 11] := by decide
  have h2 : (2 : ℕ) ^ 253 = ((2 : ℕ) ^ 10) ^ 25 * 2 ^ 3 := by rw [← pow_mul, ← pow_add]
  have h4 : ((2 : ℕ) ^ 10) ^ 25 * 2 ^ 3 ≡ 1 ^ 25 * 2 ^ 3 [MOD 11] :=
    Nat.ModEq.mul (h1.symm.pow 25) rfl
  rw [h2] at h3
  have hcon : (1 : ℕ) ≡ 8 [MOD 11] := h3.trans (by simpa using h4)
  simp [Nat.ModEq] at hcon

/-- **The exponential modulus factors the semiprime `253 = 11 · 23`.**
Here `ord₂₃(2) = 11` divides `253`, so the prime `23` is exposed; `ord₁₁(2) = 10`
does not divide `253`, so the gcd is exactly `23` and the factorisation is
complete.  No polynomial derived modulus can do this for any semiprime
(`family_coprime`). -/
theorem mersenne_factors_253 : Nat.gcd 253 (2 ^ 253 - 1) = 23 ∧ 253 = 11 * 23 := by
  refine ⟨?_, by norm_num⟩
  have hdvd253 : Nat.gcd 253 (2 ^ 253 - 1) ∣ 11 * 23 := by
    have h := Nat.gcd_dvd_left 253 (2 ^ 253 - 1)
    norm_num at h ⊢
  have h23 : (23 : ℕ) ∣ Nat.gcd 253 (2 ^ 253 - 1) := Nat.dvd_gcd (by norm_num) twentythree_dvd
  rcases dvd_semiprime_cases (by norm_num) (by norm_num) hdvd253 with h | h | h | h
  · rw [h] at h23; omega
  · rw [h] at h23; omega
  · exact h
  · exfalso
    have hg : Nat.gcd 253 (2 ^ 253 - 1) ∣ 2 ^ 253 - 1 := Nat.gcd_dvd_right _ _
    rw [h] at hg
    exact eleven_not_dvd (dvd_trans ⟨23, by norm_num⟩ hg)

/-- **The polynomial hypothesis is necessary.**  Polynomial derived moduli are
coprime to `N` for every `N`; the exponential modulus shares a factor with `N`
for infinitely many `N` and even completes a factorisation at `N = 253`.  So
the MULTIMOD no-go is exactly a statement about the polynomial (congruence
transporting) class, and the open frontier is genuinely outside it. -/
theorem polynomial_hypothesis_necessary :
    (∀ (i : Fin 6) (N : ℤ), Int.gcd N (family i N) = 1) ∧
    {N : ℕ | 1 < Nat.gcd N (2 ^ N - 1)}.Infinite ∧
    Nat.gcd 253 (2 ^ 253 - 1) = 23 :=
  ⟨family_coprime, mersenne_sharing_infinite, mersenne_factors_253.1⟩

end Physics.DerivedModulus