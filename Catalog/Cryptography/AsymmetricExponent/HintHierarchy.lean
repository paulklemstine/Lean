import Cryptography.AsymmetricExponent.FermatLiars

/-!
# The hint hierarchy: which cheap quantities actually factor?

`Q(a) = a^(N-1) mod N` costs `O(log N)` (see `PolyTime.lean`) and its CRT
components are asymmetric (see `Core.lean`), yet every multiplicative
consequence of `Q` factors through the single number `g = gcd(p-1, q-1)`
(see `FermatLiars.lean`).  This file contrasts that with a hint that *does*
factor: Euler's totient.

Main results.

* `AsymmetricExponent.factor_from_totient` — from `N = p*q` and `φ(N)` one
  writes down `p` in closed form.  So `φ` is a factoring hint.
* `AsymmetricExponent.liarGroupIsoOfEulerGapEq` — semiprimes with equal Euler
  gap have *isomorphic* Fermat-liar groups.  Everything the Fermat/`Q` surface
  can see is an isomorphism invariant of that group, hence a function of `g`
  alone: it cannot separate two semiprimes with the same `g`.
* `AsymmetricExponent.liarGroup_33_iso_35` — a concrete instance: `33 = 3·11`
  and `35 = 5·7` have isomorphic liar groups although their factors differ.
-/

namespace AsymmetricExponent

/-! ## Euler's totient *is* a factoring hint -/

/-- The totient of a semiprime determines the sum of its prime factors. -/
theorem sum_of_primes_from_totient {p q : ℕ} (hp : 2 ≤ p) (hq : 2 ≤ q) :
    p * q + 1 - (p - 1) * (q - 1) = p + q := by
  obtain ⟨a, rfl⟩ : ∃ a, p = a + 1 := ⟨p - 1, by omega⟩
  obtain ⟨b, rfl⟩ : ∃ b, q = b + 1 := ⟨q - 1, by omega⟩
  have h : (a + 1) * (b + 1) = a * b + a + b + 1 := by ring
  simp only [Nat.add_sub_cancel]
  omega

/-- The difference of the primes is the square root of `s^2 - 4N`. -/
theorem sq_diff_from_sum {p q : ℕ} (hlt : q < p) :
    (p + q) ^ 2 - 4 * (p * q) = (p - q) * (p - q) := by
  obtain ⟨d, rfl⟩ : ∃ d, p = q + d := ⟨p - q, by omega⟩
  have h1 : (q + d + q) ^ 2 = 4 * q * q + 4 * q * d + d * d := by ring
  have h2 : 4 * ((q + d) * q) = 4 * q * q + 4 * q * d := by ring
  simp only [Nat.add_sub_cancel_left]
  omega

/-- **Knowing `φ(N)` factors `N`.** For a semiprime `N = p*q` with `q < p`, the
larger prime is the closed-form expression

  `p = (s + √(s² - 4N)) / 2`,  `s = N + 1 - φ(N)`.

Contrast this with `Q`: the totient is an equally "cheap-looking" quantity, but
it is *not* factor-blind — one gcd-free formula recovers the factorisation. -/
theorem factor_from_totient {p q : ℕ} (hp : 2 ≤ p) (hq : 2 ≤ q) (hlt : q < p) :
    p = ((p * q + 1 - (p - 1) * (q - 1)) +
          Nat.sqrt ((p * q + 1 - (p - 1) * (q - 1)) ^ 2 - 4 * (p * q))) / 2 := by
  rw [sum_of_primes_from_totient hp hq, sq_diff_from_sum hlt, Nat.sqrt_eq]
  omega

/-- The companion formula for the smaller prime. -/
theorem smaller_factor_from_totient {p q : ℕ} (hp : 2 ≤ p) (hq : 2 ≤ q)
    (hlt : q < p) :
    q = ((p * q + 1 - (p - 1) * (q - 1)) -
          Nat.sqrt ((p * q + 1 - (p - 1) * (q - 1)) ^ 2 - 4 * (p * q))) / 2 := by
  rw [sum_of_primes_from_totient hp hq, sq_diff_from_sum hlt, Nat.sqrt_eq]
  omega

/-! ## `Q` cannot separate semiprimes with the same Euler gap -/

/-- **Equal Euler gap ⇒ isomorphic liar groups.** Any invariant of the
Fermat-liar group — hence any statistic extracted from the `Q`-surface that is
invariant under group isomorphism — is a function of `g` alone. -/
noncomputable def liarGroupIsoOfEulerGapEq {p q p' q' : ℕ} [Fact p.Prime]
    [Fact q.Prime] [Fact p'.Prime] [Fact q'.Prime] (hpq : p ≠ q) (hpq' : p' ≠ q')
    (h : eulerGap p q = eulerGap p' q') :
    ((powMonoidHom (p * q - 1) : (ZMod (p * q))ˣ →* (ZMod (p * q))ˣ).ker) ≃*
      ((powMonoidHom (p' * q' - 1) : (ZMod (p' * q'))ˣ →* (ZMod (p' * q'))ˣ).ker) := by
  have e1 := liarGroupEquiv (p := p) (q := q) hpq
  have e2 := liarGroupEquiv (p := p') (q := q') hpq'
  rw [h] at e1
  exact e1.trans e2.symm

theorem eulerGap_33_eq_35 : eulerGap 3 11 = eulerGap 5 7 := by
  simp [eulerGap]

/-- A concrete instance of factor-blindness: the liar groups of `33 = 3·11` and
`35 = 5·7` are isomorphic. -/
noncomputable def liarGroup_33_iso_35 :
    ((powMonoidHom (3 * 11 - 1) : (ZMod (3 * 11))ˣ →* (ZMod (3 * 11))ˣ).ker) ≃*
      ((powMonoidHom (5 * 7 - 1) : (ZMod (5 * 7))ˣ →* (ZMod (5 * 7))ˣ).ker) := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  haveI : Fact (Nat.Prime 11) := ⟨by norm_num⟩
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  haveI : Fact (Nat.Prime 7) := ⟨by norm_num⟩
  exact liarGroupIsoOfEulerGapEq (by norm_num) (by norm_num) eulerGap_33_eq_35

end AsymmetricExponent