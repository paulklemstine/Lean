import Mathlib

/-!
# The asymmetric CRT split of `a^(N-1) mod N` for a semiprime `N = p*q`

This file formalises the *structural* half of the FETQ experiment: the cheap,
factorisation-free quantity

  `Q(a) = a^(N-1) mod N`,   `N = p*q`, `p ≠ q` primes,

has an internally **asymmetric** Chinese-Remainder description:

  `Q(a) ≡ a^(q-1) (mod p)`  and  `Q(a) ≡ a^(p-1) (mod q)`.

Each CRT component of `Q` is governed by the *other* prime's Fermat exponent.
The arithmetic engine is the exponent identity `pq - 1 = (p-1)q + (q-1)`, which
is not symmetric in `p` and `q` even though `pq - 1` is.

Main results.

* `AsymmetricExponent.semiprime_exp_split` — the exponent identity.
* `AsymmetricExponent.pow_modEq_left` / `pow_modEq_right` — the asymmetric
  congruences.
* `AsymmetricExponent.fetq_mod_left` / `fetq_mod_right` — the same statements
  for the *reduced* quantity `fetq N a = a^(N-1) % N`.
* `AsymmetricExponent.fetq_unique` — `fetq N a` is the **unique** residue below
  `N` with these two components (CRT exactness; this is the "24/24 verified"
  claim, proved for all `p, q, a`).
* `AsymmetricExponent.gcd_exp_left` / `gcd_exp_right` — the exponent gcd
  collapse `gcd(N-1, p-1) = gcd(p-1, q-1) = gcd(N-1, q-1)`: the Fermat exponent
  `N-1` sees each prime only through the *common* gap `g = gcd(p-1, q-1)`.
* `AsymmetricExponent.gcd_variant_fires_left` — the gcd variant
  `gcd(a^(N-1) - 1, N)` picks up the factor `p` exactly when
  `ord_p(a) ∣ q - 1`.
-/

namespace AsymmetricExponent

/-- The FETQ quantity `Q(a) = a^(N-1) mod N`.  Note that it is defined from `N`
alone: no knowledge of the factorisation enters. -/
def fetq (N a : ℕ) : ℕ := a ^ (N - 1) % N

/-! ## The asymmetric exponent identity -/

/-- **The asymmetric exponent split.** For positive `p, q`,
`pq - 1 = (p-1)·q + (q-1)`.  Reading the same number the other way gives
`pq - 1 = (q-1)·p + (p-1)`; the two readings are what produce the asymmetry. -/
theorem semiprime_exp_split {p q : ℕ} (hp : 0 < p) (hq : 0 < q) :
    p * q - 1 = (p - 1) * q + (q - 1) := by
  have h : (p - 1) * q = p * q - q := Nat.sub_one_mul p q
  have h2 : q ≤ p * q := Nat.le_mul_of_pos_left q hp
  omega

/-- Fermat's little theorem in `ℕ`-congruence form. -/
theorem fermat_little {p a : ℕ} (hp : p.Prime) (ha : Nat.Coprime a p) :
    a ^ (p - 1) ≡ 1 [MOD p] := by
  have := Nat.ModEq.pow_totient ha
  rwa [Nat.totient_prime hp] at this

/-- **Asymmetry, first component.** Modulo `p`, the exponent `N-1` acts as the
*other* prime's Fermat exponent `q-1`. -/
theorem pow_modEq_left {p q a : ℕ} (hp : p.Prime) (hq : 0 < q)
    (ha : Nat.Coprime a p) :
    a ^ (p * q - 1) ≡ a ^ (q - 1) [MOD p] := by
  have hexp : p * q - 1 = (p - 1) * q + (q - 1) := semiprime_exp_split hp.pos hq
  calc a ^ (p * q - 1) = (a ^ (p - 1)) ^ q * a ^ (q - 1) := by
        rw [hexp, pow_add, pow_mul]
    _ ≡ 1 ^ q * a ^ (q - 1) [MOD p] :=
        Nat.ModEq.mul ((fermat_little hp ha).pow q) (Nat.ModEq.refl _)
    _ = a ^ (q - 1) := by ring

/-- **Asymmetry, second component.** Modulo `q`, the exponent `N-1` acts as
`p-1`. -/
theorem pow_modEq_right {p q a : ℕ} (hp : 0 < p) (hq : q.Prime)
    (ha : Nat.Coprime a q) :
    a ^ (p * q - 1) ≡ a ^ (p - 1) [MOD q] := by
  have := pow_modEq_left (p := q) (q := p) hq hp ha
  rwa [Nat.mul_comm q p] at this

/-! ## The same statements for the reduced quantity -/

theorem fetq_mod_left {p q a : ℕ} (hp : p.Prime) (hq : 0 < q)
    (ha : Nat.Coprime a p) :
    fetq (p * q) a % p = a ^ (q - 1) % p := by
  have hdvd : p ∣ p * q := Dvd.intro q rfl
  have : fetq (p * q) a % p = a ^ (p * q - 1) % p := Nat.mod_mod_of_dvd _ hdvd
  rw [this]
  exact pow_modEq_left hp hq ha

theorem fetq_mod_right {p q a : ℕ} (hp : 0 < p) (hq : q.Prime)
    (ha : Nat.Coprime a q) :
    fetq (p * q) a % q = a ^ (p - 1) % q := by
  have hdvd : q ∣ p * q := Dvd.intro_left p rfl
  have : fetq (p * q) a % q = a ^ (p * q - 1) % q := Nat.mod_mod_of_dvd _ hdvd
  rw [this]
  exact pow_modEq_right hp hq ha

/-- **CRT exactness.** `fetq N a` is the unique residue `x < N` whose CRT
components are `a^(q-1) mod p` and `a^(p-1) mod q`.  This is the exhaustive
form of the experimental "asymmetric decomposition is exact" observation. -/
theorem fetq_unique {p q a x : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p ≠ q) (hap : Nat.Coprime a p) (haq : Nat.Coprime a q)
    (hx : x < p * q)
    (h1 : x ≡ a ^ (q - 1) [MOD p]) (h2 : x ≡ a ^ (p - 1) [MOD q]) :
    x = fetq (p * q) a := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  have hleft : x ≡ a ^ (p * q - 1) [MOD p] :=
    h1.trans (pow_modEq_left hp hq.pos hap).symm
  have hright : x ≡ a ^ (p * q - 1) [MOD q] :=
    h2.trans (pow_modEq_right hp.pos hq haq).symm
  have hall : x ≡ a ^ (p * q - 1) [MOD p * q] :=
    (Nat.modEq_and_modEq_iff_modEq_mul hcop).mp ⟨hleft, hright⟩
  have := hall
  unfold Nat.ModEq at this
  rw [fetq, ← this, Nat.mod_eq_of_lt hx]

/-! ## The exponent gcd collapse -/

/-- `gcd(N-1, p-1) = gcd(q-1, p-1)`: modulo `p-1`, the Fermat exponent `N-1`
is just `q-1`. -/
theorem gcd_exp_left {p q : ℕ} (hp : 0 < p) (hq : 0 < q) :
    Nat.gcd (p * q - 1) (p - 1) = Nat.gcd (q - 1) (p - 1) := by
  rw [semiprime_exp_split hp hq, Nat.add_comm, Nat.gcd_add_mul_left_left]

/-- `gcd(N-1, q-1) = gcd(p-1, q-1)`. -/
theorem gcd_exp_right {p q : ℕ} (hp : 0 < p) (hq : 0 < q) :
    Nat.gcd (p * q - 1) (q - 1) = Nat.gcd (p - 1) (q - 1) := by
  rw [Nat.mul_comm p q]
  exact gcd_exp_left hq hp

/-- Both exponent gcds collapse to the same **Euler gap** `g = gcd(p-1, q-1)`:
the Fermat exponent is blind to which prime it is reduced against. -/
theorem gcd_exp_symmetric {p q : ℕ} (hp : 0 < p) (hq : 0 < q) :
    Nat.gcd (p * q - 1) (p - 1) = Nat.gcd (p * q - 1) (q - 1) := by
  rw [gcd_exp_left hp hq, gcd_exp_right hp hq, Nat.gcd_comm]

/-! ## The gcd variant -/

/-- **When the gcd variant fires.** For `a` coprime to `p`, the prime `p`
divides `a^(N-1) - 1` exactly when the multiplicative order of `a` modulo `p`
divides `q - 1` — the *other* prime's Fermat exponent.  This is the precise
"EULERGAP" firing condition for `gcd(a^(N-1) - 1, N)`. -/
theorem gcd_variant_fires_left {p q a : ℕ} [Fact p.Prime] (hp : p.Prime)
    (hq : 0 < q) (ha : Nat.Coprime a p) :
    ((a : ZMod p) ^ (p * q - 1) = 1) ↔ orderOf (a : ZMod p) ∣ q - 1 := by
  constructor
  · intro h
    refine orderOf_dvd_of_pow_eq_one ?_
    have hmod : a ^ (p * q - 1) ≡ a ^ (q - 1) [MOD p] := pow_modEq_left hp hq ha
    have : ((a ^ (p * q - 1) : ℕ) : ZMod p) = ((a ^ (q - 1) : ℕ) : ZMod p) :=
      (ZMod.natCast_eq_natCast_iff _ _ _).mpr hmod
    push_cast at this
    rw [← this]; exact h
  · intro h
    have hmod : a ^ (p * q - 1) ≡ a ^ (q - 1) [MOD p] := pow_modEq_left hp hq ha
    have hc : ((a ^ (p * q - 1) : ℕ) : ZMod p) = ((a ^ (q - 1) : ℕ) : ZMod p) :=
      (ZMod.natCast_eq_natCast_iff _ _ _).mpr hmod
    push_cast at hc
    rw [hc]
    exact orderOf_dvd_iff_pow_eq_one.mp h

end AsymmetricExponent