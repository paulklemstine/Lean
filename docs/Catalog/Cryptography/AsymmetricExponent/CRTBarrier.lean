import Cryptography.AsymmetricExponent.Core

/-!
# Barrier 6: reading a CRT component of `Q` *is* factoring

`Core.lean` shows that `Q(a) = a^(N-1) mod N` has genuinely asymmetric CRT
components, `a^(q-1) mod p` and `a^(p-1) mod q`.  The natural hope is to read
one component off and learn something about the other prime.  This file proves
that the read itself is already equivalent to factoring.

Main results.

* `AsymmetricExponent.gcd_crt_idempotent` — any `e` with `e ≡ 1 (mod p)` and
  `e ≡ 0 (mod q)` satisfies `gcd(e, N) = q`: the CRT idempotent *is* the
  factorisation.
* `AsymmetricExponent.exists_crt_idempotent` and
  `AsymmetricExponent.crt_idempotent_iff_factor` — conversely the idempotent
  exists once the factorisation is known, so the two data are interchangeable.
* `AsymmetricExponent.componentReader_factors` — the barrier in its intended
  form: **any** procedure that returns the left CRT component of `Q` as a
  residue vanishing mod `q` yields the factor `q` from its value at the single
  point `a = 1`.
* `AsymmetricExponent.gcd_splits_of_dvd_mul` — the general splitting engine.
* `AsymmetricExponent.nontrivial_idempotent_splits` — a nontrivial idempotent
  modulo `N` splits `N`.
* `AsymmetricExponent.nontrivial_sqrt_one_splits` — Rabin's split: a nontrivial
  square root of `1` modulo `N` splits `N` as well.
-/

namespace AsymmetricExponent

/-! ## A gcd extraction lemma -/

/-- If `d ∣ m` and the prime `r` does not divide `m`, then `gcd(m, d*r) = d`. -/
theorem gcd_eq_of_dvd_of_not_dvd {m d r : ℕ} (hr : r.Prime) (hdm : d ∣ m)
    (hrm : ¬ r ∣ m) : Nat.gcd m (d * r) = d := by
  have hcop : Nat.Coprime r m := (Nat.Prime.coprime_iff_not_dvd hr).mpr hrm
  rw [Nat.mul_comm d r, Nat.Coprime.gcd_mul_left_cancel_right d hcop,
    Nat.gcd_eq_right hdm]

/-! ## Idempotents split a semiprime -/

/-- **The CRT idempotent is the factorisation.** If `e ≡ 1 (mod p)` and
`e ≡ 0 (mod q)` then `gcd(e, pq) = q`. -/
theorem gcd_crt_idempotent {p q e : ℕ} (hp : p.Prime) (h1 : e ≡ 1 [MOD p])
    (h2 : e ≡ 0 [MOD q]) :
    Nat.gcd e (q * p) = q := by
  have hqe : q ∣ e := (Nat.modEq_zero_iff_dvd).mp h2
  have hpe : ¬ p ∣ e := by
    intro hdvd
    have h0 : e ≡ 0 [MOD p] := (Nat.modEq_zero_iff_dvd).mpr hdvd
    have hone : (1 : ℕ) ≡ 0 [MOD p] := h1.symm.trans h0
    exact hp.one_lt.ne' (Nat.dvd_one.mp ((Nat.modEq_zero_iff_dvd).mp hone))
  exact gcd_eq_of_dvd_of_not_dvd hp hqe hpe

/-- Conversely, knowing the factorisation produces the idempotent. -/
theorem exists_crt_idempotent {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p ≠ q) :
    ∃ e : ℕ, e ≡ 1 [MOD p] ∧ e ≡ 0 [MOD q] := by
  have hcop : Nat.Coprime q p := (Nat.coprime_primes hq hp).mpr (Ne.symm hpq)
  obtain ⟨e, he1, he2⟩ := Nat.chineseRemainder hcop 0 1
  exact ⟨e, he2, he1⟩

/-- **Idempotent ⟺ factor.** For `N = p*q` with distinct prime factors,
producing a CRT idempotent and producing the factor `q` are the same task. -/
theorem crt_idempotent_iff_factor {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p ≠ q) :
    (∃ e : ℕ, e ≡ 1 [MOD p] ∧ e ≡ 0 [MOD q]) ∧
      (∀ e : ℕ, e ≡ 1 [MOD p] → e ≡ 0 [MOD q] → Nat.gcd e (q * p) = q) :=
  ⟨exists_crt_idempotent hp hq hpq, fun _ h1 h2 => gcd_crt_idempotent hp h1 h2⟩

/-- **The component-reading barrier.** Suppose some procedure `s` returns, for
every input `a`, a residue that agrees with the *left* CRT component
`a^(q-1) mod p` of `Q(a)` and vanishes modulo `q` — i.e. it genuinely isolates
one CRT coordinate of `Q`.  Then a single gcd at `a = 1` returns the factor
`q`.  Isolating a component of the asymmetric split is therefore not a step
towards factoring: it already *is* factoring. -/
theorem componentReader_factors {p q : ℕ} (hp : p.Prime) (s : ℕ → ℕ)
    (hleft : ∀ a, s a ≡ a ^ (q - 1) [MOD p]) (hright : ∀ a, s a ≡ 0 [MOD q]) :
    Nat.gcd (s 1) (q * p) = q := by
  refine gcd_crt_idempotent hp ?_ (hright 1)
  have := hleft 1
  simpa using this

/-! ## Splitting lemmas: nontrivial idempotents and square roots of one -/

/-- **The general splitting lemma.** Suppose `N = p*q` divides a product `u*v`,
neither factor of the product is divisible by `N`, and no prime of `N` divides
both `u` and `v`.  Then `gcd(u, N)` is a prime factor of `N`.  This is the
common engine behind the idempotent split and behind Rabin's square-root
split. -/
theorem gcd_splits_of_dvd_mul {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p ≠ q) {u v : ℤ} (hmul : ((p * q : ℕ) : ℤ) ∣ u * v)
    (h0 : ¬ ((p * q : ℕ) : ℤ) ∣ u) (h1 : ¬ ((p * q : ℕ) : ℤ) ∣ v)
    (hpuv : ¬ ((p : ℤ) ∣ u ∧ (p : ℤ) ∣ v))
    (hquv : ¬ ((q : ℤ) ∣ u ∧ (q : ℤ) ∣ v)) :
    Nat.gcd u.natAbs (p * q) = p ∨ Nat.gcd u.natAbs (p * q) = q := by
  have hcopn : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  have hcop : IsCoprime (p : ℤ) (q : ℤ) := Nat.isCoprime_iff_coprime.mpr hcopn
  have hppr : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  have hqpr : Prime (q : ℤ) := Nat.prime_iff_prime_int.mp hq
  have hNdvd : ∀ x : ℤ, (p : ℤ) ∣ x → (q : ℤ) ∣ x → ((p * q : ℕ) : ℤ) ∣ x := by
    intro x hx hy
    have h := hcop.mul_dvd hx hy
    push_cast
    exact h
  have hcast : ∀ (r : ℕ) (x : ℤ), (r : ℤ) ∣ x ↔ r ∣ x.natAbs := by
    intro r x
    constructor
    · intro h
      have := Int.natAbs_dvd_natAbs.mpr h
      simpa using this
    · intro h
      have : ((r : ℤ)).natAbs ∣ x.natAbs := by simpa using h
      exact Int.natAbs_dvd_natAbs.mp this
  have hpdvd : (p : ℤ) ∣ u * v :=
    dvd_trans (by push_cast; exact Dvd.intro (q : ℤ) rfl) hmul
  have hqdvd : (q : ℤ) ∣ u * v :=
    dvd_trans (by push_cast; exact Dvd.intro_left (p : ℤ) rfl) hmul
  rcases hppr.dvd_mul.mp hpdvd with hpu | hpv
  · rcases hqpr.dvd_mul.mp hqdvd with hqu | hqv
    · exact absurd (hNdvd u hpu hqu) h0
    · left
      exact gcd_eq_of_dvd_of_not_dvd hq ((hcast p u).mp hpu)
        (fun h => hquv ⟨(hcast q u).mpr h, hqv⟩)
  · rcases hqpr.dvd_mul.mp hqdvd with hqu | hqv
    · right
      rw [Nat.mul_comm p q]
      exact gcd_eq_of_dvd_of_not_dvd hp ((hcast q u).mp hqu)
        (fun h => hpuv ⟨(hcast p u).mpr h, hpv⟩)
    · exact absurd (hNdvd v hpv hqv) h1

/-- **A nontrivial idempotent splits `N`.** If `N = p*q` divides `e*(e-1)` while
`e` is neither `0` nor `1` modulo `N`, then `gcd(e, N)` is a prime factor. -/
theorem nontrivial_idempotent_splits {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p ≠ q) {e : ℤ} (hidem : ((p * q : ℕ) : ℤ) ∣ e * (e - 1))
    (h0 : ¬ ((p * q : ℕ) : ℤ) ∣ e) (h1 : ¬ ((p * q : ℕ) : ℤ) ∣ (e - 1)) :
    Nat.gcd e.natAbs (p * q) = p ∨ Nat.gcd e.natAbs (p * q) = q := by
  refine gcd_splits_of_dvd_mul hp hq hpq hidem h0 h1 ?_ ?_
  · rintro ⟨hu, hv⟩
    have hone : (p : ℤ) ∣ 1 := by simpa using dvd_sub hu hv
    exact hp.one_lt.ne' (by exact_mod_cast Int.eq_one_of_dvd_one (by positivity) hone)
  · rintro ⟨hu, hv⟩
    have hone : (q : ℤ) ∣ 1 := by simpa using dvd_sub hu hv
    exact hq.one_lt.ne' (by exact_mod_cast Int.eq_one_of_dvd_one (by positivity) hone)

/-- **Rabin's split.** A nontrivial square root of `1` modulo `N = p*q` (with
`p, q` odd) yields a prime factor of `N` as `gcd(x - 1, N)`.  This is the exact
point at which the Miller–Rabin test turns from a *witness* of compositeness
into a *factorisation* — and it, too, is an oracle for the CRT split. -/
theorem nontrivial_sqrt_one_splits {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p ≠ q) (hp2 : p ≠ 2) (hq2 : q ≠ 2) {x : ℤ}
    (hsq : ((p * q : ℕ) : ℤ) ∣ (x - 1) * (x + 1))
    (h0 : ¬ ((p * q : ℕ) : ℤ) ∣ (x - 1)) (h1 : ¬ ((p * q : ℕ) : ℤ) ∣ (x + 1)) :
    Nat.gcd (x - 1).natAbs (p * q) = p ∨ Nat.gcd (x - 1).natAbs (p * q) = q := by
  have key : ∀ r : ℕ, r.Prime → r ≠ 2 → ¬ ((r : ℤ) ∣ (x - 1) ∧ (r : ℤ) ∣ (x + 1)) := by
    rintro r hr hr2 ⟨hu, hv⟩
    have htwo : (r : ℤ) ∣ 2 := by
      have := dvd_sub hv hu
      simpa using this
    have : r ∣ 2 := by
      have := Int.natAbs_dvd_natAbs.mpr htwo
      simpa using this
    rcases (Nat.dvd_prime Nat.prime_two).mp this with h | h
    · exact hr.one_lt.ne' h
    · exact hr2 h
  exact gcd_splits_of_dvd_mul hp hq hpq hsq h0 h1 (key p hp hp2) (key q hq hq2)

end AsymmetricExponent