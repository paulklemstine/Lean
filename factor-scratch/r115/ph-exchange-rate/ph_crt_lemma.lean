import Mathlib

/-!
# Axis A, Lean stretch goal: the CRT combination lemma behind Pohlig–Hellman

Axis A of the ECDSA brief is the *cost* of Pohlig–Hellman as a function of how
much of `n = ∏ ℓᵢ^eᵢ` the attacker knows.  The cost experiment lives in
`ph_exchange.sage` / `ph_analyze.py` beside this file; this file is the Lean
half: the algebraic fact that makes the attack work at all, namely that a
discrete log in a cyclic group **splits** over a coprime factorisation of the
group order and **recombines** by CRT.

## What already exists in Mathlib (checked, not assumed)

`ZMod.chineseRemainder (h : m.Coprime n) : ZMod (m * n) ≃+* ZMod m × ZMod n`
is already a `RingEquiv`, defined in `Mathlib/Data/ZMod/Basic.lean` (line 875).
Verified with `lake env lean`:

    #check @ZMod.chineseRemainder
    -- @ZMod.chineseRemainder : {m n : ℕ} → m.Coprime n → ZMod (m * n) ≃+* ZMod m × ZMod n

So the pure CRT statement needs nothing new.  What is *not* in Mathlib is the
**discrete-log transfer**: that solving the dlog in the two factors and running
CRT back really recovers the dlog in the product.  That is `pohlig_hellman_crt`
below, plus its two supporting pieces.

## Conventions

Everything is stated multiplicatively: `M` is a commutative group, `^` is the
group power.  For an elliptic curve / additive group read `^` as `•`.
Note `a ≡ b [MOD n]` is `Nat.ModEq` (ℕ); `a ≡ b [ZMOD n]` is `Int.ModEq`.
-/

namespace PohligHellman

variable {M : Type} [CommGroup M] [Finite M] {g x : M} {m n a a₁ a₂ d : ℕ}

/-- The two subgroup generators have the expected orders.  No coprimality is
needed here: `Nat.gcd (m * n) n = n` always holds because `n ∣ m * n`, so
`orderOf (g ^ n) = (m * n) / n = m`.  Coprimality enters only in the CRT
recombination below. -/
theorem orderOf_pow_mul (hm : 0 < m) (hn : 0 < n) (hg : orderOf g = m * n) :
    orderOf (g ^ n) = m ∧ orderOf (g ^ m) = n := by
  constructor
  · rw [orderOf_pow, hg]
    have h1 : (m * n).gcd n = n :=
      Nat.dvd_antisymm (Nat.gcd_dvd_right (m * n) n)
        (Nat.dvd_gcd (Nat.dvd_mul_left n m) (dvd_refl n))
    rw [h1, Nat.mul_div_left m hn]
  · rw [orderOf_pow, hg]
    have h1 : (m * n).gcd m = m :=
      Nat.dvd_antisymm (Nat.gcd_dvd_right (m * n) m)
        (Nat.dvd_gcd (Nat.dvd_mul_right m n) (dvd_refl m))
    rw [h1, Nat.mul_div_right n hm]

omit [Finite M] in
/-- **Restriction (m-part).**  A dlog `g ^ d = x` in the big group determines the
dlog in the `m`-part: any exponent congruent to `d` mod `m` already solves the
`m`-part, because `x ^ n = (g ^ d) ^ n = g ^ (d * n)` and `d * n` only depends
on `d` mod `m` (up to the order `m * n` of `g`). -/
theorem ph_restrict_m (hg : orderOf g = m * n) (hx : g ^ d = x) (h : a₁ ≡ d [MOD m]) :
    (g ^ n) ^ a₁ = x ^ n := by
  have hL : (g ^ n) ^ a₁ = g ^ (n * a₁) := (pow_mul g n a₁).symm
  have hR : x ^ n = g ^ (d * n) := by
    rw [← hx, pow_mul g d n]
  rw [hL, hR]
  apply pow_eq_pow_iff_modEq.2
  rw [hg, Nat.mul_comm d n, Nat.mul_comm m n]
  exact h.mul_left' n

omit [Finite M] in
/-- **Restriction (n-part).**  Same, for the `n`-part. -/
theorem ph_restrict_n (hg : orderOf g = m * n) (hx : g ^ d = x) (h : a₂ ≡ d [MOD n]) :
    (g ^ m) ^ a₂ = x ^ m := by
  have hL : (g ^ m) ^ a₂ = g ^ (m * a₂) := (pow_mul g m a₂).symm
  have hR : x ^ m = g ^ (d * m) := by
    rw [← hx, pow_mul g d m]
  rw [hL, hR]
  apply pow_eq_pow_iff_modEq.2
  rw [hg]
  have hh : m * a₂ ≡ m * d [MOD m * n] := h.mul_left' m
  rwa [Nat.mul_comm m d] at hh

/-- **The Pohlig–Hellman CRT combination lemma.**  This is the lemma the brief
asks for.  Suppose
  * `g` has order `m * n` with `m`, `n` coprime,
  * the `m`-part solve produces `a₁` with `(g ^ n) ^ a₁ = x ^ n`,
  * the `n`-part solve produces `a₂` with `(g ^ m) ^ a₂ = x ^ m`,
  * CRT combines them into `a` with `a ≡ a₁ [MOD m]` and `a ≡ a₂ [MOD n]`.
Then `a` solves the ORIGINAL dlog: `g ^ a = x`. -/
theorem pohlig_hellman_crt (hmn : Nat.Coprime m n) (hm : 0 < m) (hn : 0 < n)
    (hg : orderOf g = m * n) (hd : g ^ d = x)
    (h₁ : (g ^ n) ^ a₁ = x ^ n) (h₂ : (g ^ m) ^ a₂ = x ^ m)
    (ha₁ : a ≡ a₁ [MOD m]) (ha₂ : a ≡ a₂ [MOD n]) :
    g ^ a = x := by
  obtain ⟨hord₁, hord₂⟩ := orderOf_pow_mul hm hn hg
  -- the m-part solve pins the answer down to d mod m
  have hm1 : a₁ ≡ d [MOD m] := by
    have hh : (g ^ n) ^ a₁ = (g ^ n) ^ (d % m) := by
      rw [h₁, ph_restrict_m hg hd (Nat.mod_mod d m)]
    have hconj := pow_eq_pow_iff_modEq.1 hh
    rw [hord₁] at hconj
    exact hconj.trans (Nat.mod_mod d m)
  -- the n-part solve pins the answer down to d mod n
  have hn1 : a₂ ≡ d [MOD n] := by
    have hh : (g ^ m) ^ a₂ = (g ^ m) ^ (d % n) := by
      rw [h₂, ph_restrict_n hg hd (Nat.mod_mod d n)]
    have hconj := pow_eq_pow_iff_modEq.1 hh
    rw [hord₂] at hconj
    exact hconj.trans (Nat.mod_mod d n)
  -- CRT: a ≡ d mod m and mod n, hence mod m * n, which is the order of g
  have hA : a ≡ d [MOD m] := ha₁.trans hm1
  have hB : a ≡ d [MOD n] := ha₂.trans hn1
  have hAB : a ≡ d [MOD m * n] := (Nat.modEq_and_modEq_iff_modEq_mul hmn).1 ⟨hA, hB⟩
  have hfin : g ^ a = g ^ d := pow_eq_pow_iff_modEq.2 (by rw [hg]; exact hAB)
  rwa [hd] at hfin

omit [Finite M] in
/-- Uniqueness: two exponents of `g` give the same group element only mod the order. -/
theorem dlog_unique (hg : orderOf g = m * n) (h : g ^ a = g ^ d) : a ≡ d [MOD m * n] := by
  have := pow_eq_pow_iff_modEq.1 h
  rwa [hg] at this

/-- The pure CRT statement, restated from the existing `ZMod.chineseRemainder`.
Asserted with `example` so that no new proof is introduced: the point is that
Mathlib *already has it*.  (This is also the reason Axis A's Lean target is the
dlog transfer above, not the CRT itself.) -/
example {m n : ℕ} (h : Nat.Coprime m n) : ZMod (m * n) ≃+* ZMod m × ZMod n :=
  ZMod.chineseRemainder h

omit [Finite M] in
/-- **The additive phrasing** — the one directly applicable to an elliptic curve
or any additive cyclic group: read `^` as `•` and `M` as `Multiplicative G`.
If the `m`-part solve gives `a₁` and the `n`-part solve gives `a₂`, and CRT
combines them into `a`, then `a` solves the original dlog. -/
theorem pohlig_hellman_crt_additive {G : Type} [AddCommGroup G] [Finite G] {g x : G}
    {m n a a₁ a₂ d : ℕ} (hmn : Nat.Coprime m n) (hm : 0 < m) (hn : 0 < n)
    (hg : addOrderOf g = m * n) (hd : d • g = x)
    (h₁ : a₁ • (n • g) = n • x) (h₂ : a₂ • (m • g) = m • x)
    (ha₁ : a ≡ a₁ [MOD m]) (ha₂ : a ≡ a₂ [MOD n]) :
    a • g = x := by
  have hG : orderOf (Multiplicative.ofAdd g) = m * n := by
    rw [orderOf_ofAdd_eq_addOrderOf, hg]
  have hd' : (Multiplicative.ofAdd g) ^ d = Multiplicative.ofAdd x := by
    rw [← ofAdd_nsmul]; exact congrArg _ hd
  have h₁' : ((Multiplicative.ofAdd g) ^ n) ^ a₁ = (Multiplicative.ofAdd x) ^ n := by
    rw [← ofAdd_nsmul n g, ← ofAdd_nsmul a₁ (n • g), ← ofAdd_nsmul n x]
    exact congrArg _ h₁
  have h₂' : ((Multiplicative.ofAdd g) ^ m) ^ a₂ = (Multiplicative.ofAdd x) ^ m := by
    rw [← ofAdd_nsmul m g, ← ofAdd_nsmul a₂ (m • g), ← ofAdd_nsmul m x]
    exact congrArg _ h₂
  have hfin := pohlig_hellman_crt hmn hm hn hG hd' h₁' h₂' ha₁ ha₂
  rw [← ofAdd_nsmul] at hfin
  exact congrArg Multiplicative.toAdd hfin

-- Axiom audit: the CRT combination lemma must not depend on `sorry`.
#print axioms PohligHellman.pohlig_hellman_crt
#print axioms PohligHellman.pohlig_hellman_crt_additive
#print axioms PohligHellman.ph_restrict_m
#print axioms PohligHellman.orderOf_pow_mul

end PohligHellman
