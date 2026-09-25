import Mathlib

/-!
# The sum-and-product precision law (paper 105, HINT-S-D-DECOMPOSITION)

Paper 105 explained the empirical *sum-sufficiency* of the `D₄@8` dial by the claim

  "`(p+q) mod 8` determines `p mod 8` and `q mod 8` uniquely (`q = N·p⁻¹ mod 8`)".

This file proves the exact law that governs how much of an (unordered) factor pair
is determined by the sum and the product of the factors at a finite precision, for
**every** prime `ℓ`:

* `vieta_precision` — if `p + q ≡ p' + q'` and `p q ≡ p' q'` modulo `ℓ^k`, then the
  unordered pairs `{p, q}` and `{p', q'}` agree modulo `ℓ^⌈k/2⌉`.
* `vieta_precision_sharp` — this is optimal: for every `c ≥ 1` there are pairs whose
  sums and products agree modulo `ℓ^(2c)` (hence modulo `ℓ^k` for all `k ≤ 2c`) but
  whose unordered pairs differ modulo `ℓ^(c+1)`.  At `ℓ = 2` the witnesses are odd.
* `vieta_full_precision_of_separated` — Hensel regime: if `ℓ ∤ p - q` the pair is
  determined at full precision `ℓ^k`; `two_adic_never_separated` shows odd factors
  are never separated at `ℓ = 2`.
* `vieta_exact` — the infinite-precision limit: over an integral domain sum and
  product determine the unordered pair exactly.

The engine is the valuation pigeonhole `pow_dvd_or_pow_dvd_of_pow_dvd_mul`
(`ℓ^(a+b+1) ∣ x y → ℓ^(a+1) ∣ x ∨ ℓ^(b+1) ∣ y`) applied to the Vieta identity
`(p - p')(p - q') = p² - p(p'+q') + p'q'`.

Consequence for the `D₄@8` dial (whose type map reads `p mod 8 = p mod 2³`): one
needs `⌈k/2⌉ ≥ 3`, i.e. the sum and `N` modulo `2⁵ = 32`; modulo `8` or `16` the
type pair is *not* determined (see `Mod8Refutation.lean`).
-/

namespace HintSD

/-- **Valuation pigeonhole.**  If `ℓ^(a+b+1)` divides `x*y` then either `ℓ^(a+1) ∣ x`
or `ℓ^(b+1) ∣ y`: the valuations cannot both be small. -/
theorem pow_dvd_or_pow_dvd_of_pow_dvd_mul {ℓ : ℤ} (hℓ : Prime ℓ) :
    ∀ (a b : ℕ) (x y : ℤ), ℓ ^ (a + b + 1) ∣ x * y → ℓ ^ (a + 1) ∣ x ∨ ℓ ^ (b + 1) ∣ y := by
  intro a
  induction a with
  | zero =>
    intro b x y h
    by_cases hx : ℓ ∣ x
    · left; simpa using hx
    · right
      have hc : IsCoprime (ℓ ^ (0 + b + 1)) x :=
        ((Prime.coprime_iff_not_dvd hℓ).mpr hx).pow_left
      simpa using hc.dvd_of_dvd_mul_left h
  | succ a ih =>
    intro b x y h
    by_cases hx : ℓ ∣ x
    · obtain ⟨x', rfl⟩ := hx
      have hℓ0 : ℓ ≠ 0 := hℓ.ne_zero
      have h' : ℓ ^ (a + b + 1) ∣ x' * y := by
        have : ℓ * ℓ ^ (a + b + 1) ∣ ℓ * (x' * y) := by
          have e : ℓ ^ (a + 1 + b + 1) = ℓ * ℓ ^ (a + b + 1) := by ring
          rw [← e, ← mul_assoc]; exact h
        exact (mul_dvd_mul_iff_left hℓ0).mp this
      rcases ih b x' y h' with h1 | h1
      · left
        rw [pow_succ']
        exact mul_dvd_mul_left ℓ h1
      · right; exact h1
    · right
      have hc : IsCoprime (ℓ ^ (a + 1 + b + 1)) x :=
        ((Prime.coprime_iff_not_dvd hℓ).mpr hx).pow_left
      have hy := hc.dvd_of_dvd_mul_left h
      exact (pow_dvd_pow ℓ (by omega)).trans hy

/-- The Vieta identity behind the law: the difference of the two quadratics
`(X - p)(X - q)` and `(X - p')(X - q')`, evaluated at `X = p`. -/
theorem vieta_identity (p q p' q' : ℤ) :
    (p - p') * (p - q') = p * ((p + q) - (p' + q')) + (p' * q' - p * q) := by
  ring

/-- **The precision law.**  Agreement of sum and product modulo `ℓ^k` forces the
unordered pairs to agree modulo `ℓ^⌈k/2⌉` (written `ℓ^((k+1)/2)`). -/
theorem vieta_precision {ℓ : ℤ} (hℓ : Prime ℓ) (k : ℕ) {p q p' q' : ℤ}
    (hs : p + q ≡ p' + q' [ZMOD ℓ ^ k]) (hn : p * q ≡ p' * q' [ZMOD ℓ ^ k]) :
    (p ≡ p' [ZMOD ℓ ^ ((k + 1) / 2)] ∧ q ≡ q' [ZMOD ℓ ^ ((k + 1) / 2)]) ∨
    (p ≡ q' [ZMOD ℓ ^ ((k + 1) / 2)] ∧ q ≡ p' [ZMOD ℓ ^ ((k + 1) / 2)]) := by
  set c := (k + 1) / 2 with hc
  have hck : c ≤ k := by omega
  have hsd : ℓ ^ c ∣ (p + q) - (p' + q') :=
    (pow_dvd_pow ℓ hck).trans (Int.ModEq.dvd hs.symm)
  rcases Nat.eq_zero_or_pos c with h0 | hpos
  · left; rw [h0]; simp [Int.modEq_iff_dvd]
  -- the product `(p - p')(p - q')` is divisible by `ℓ^k`
  have hprod : ℓ ^ k ∣ (p - p') * (p - q') := by
    rw [vieta_identity]
    refine dvd_add (dvd_mul_of_dvd_right (Int.ModEq.dvd hs.symm) _) ?_
    exact Int.ModEq.dvd hn
  obtain ⟨a, ha⟩ : ∃ a, c = a + 1 := ⟨c - 1, by omega⟩
  have hk : ℓ ^ (a + a + 1) ∣ (p - p') * (p - q') :=
    (pow_dvd_pow ℓ (by omega)).trans hprod
  rcases pow_dvd_or_pow_dvd_of_pow_dvd_mul hℓ a a _ _ hk with h1 | h1
  · left
    rw [← ha] at h1
    refine ⟨(Int.modEq_iff_dvd).mpr ?_, (Int.modEq_iff_dvd).mpr ?_⟩
    · have : p' - p = -(p - p') := by ring
      rw [this]; exact (dvd_neg).mpr h1
    · have : q' - q = (p - p') - ((p + q) - (p' + q')) := by ring
      rw [this]; exact dvd_sub h1 hsd
  · right
    rw [← ha] at h1
    refine ⟨(Int.modEq_iff_dvd).mpr ?_, (Int.modEq_iff_dvd).mpr ?_⟩
    · have : q' - p = -(p - q') := by ring
      rw [this]; exact (dvd_neg).mpr h1
    · have : p' - q = (p - q') - ((p + q) - (p' + q')) := by ring
      rw [this]; exact dvd_sub h1 hsd

/-- **Sharpness of the precision law**, uniformly in the prime.  With `p = 1`,
`q = 1 - 2ℓ^c`, `p' = q' = 1 - ℓ^c` the sums agree exactly and the products agree
modulo `ℓ^(2c)`, yet the unordered pairs differ modulo `ℓ^(c+1)`. -/
theorem vieta_precision_sharp {ℓ : ℤ} (hℓ : Prime ℓ) (c : ℕ) :
    let p : ℤ := 1
    let q : ℤ := 1 - 2 * ℓ ^ c
    let p' : ℤ := 1 - ℓ ^ c
    let q' : ℤ := 1 - ℓ ^ c
    p + q = p' + q' ∧ p * q ≡ p' * q' [ZMOD ℓ ^ (2 * c)] ∧
      ¬ p ≡ p' [ZMOD ℓ ^ (c + 1)] ∧ ¬ p ≡ q' [ZMOD ℓ ^ (c + 1)] := by
  intro p q p' q'
  have hnd : ¬ ℓ ^ (c + 1) ∣ ℓ ^ c := by
    intro h
    have h0 : ℓ ^ c ≠ 0 := pow_ne_zero _ hℓ.ne_zero
    rw [pow_succ] at h
    have : ℓ ∣ 1 := by
      obtain ⟨m, hm⟩ := h
      exact ⟨m, by
        have : ℓ ^ c * 1 = ℓ ^ c * (ℓ * m) := by rw [mul_one]; linarith [hm]
        exact (mul_left_cancel₀ h0 this)⟩
    exact hℓ.not_dvd_one this
  have key : ¬ (1 : ℤ) ≡ 1 - ℓ ^ c [ZMOD ℓ ^ (c + 1)] := by
    rw [Int.modEq_iff_dvd]
    simpa using hnd
  refine ⟨by simp only [p, q, p', q']; ring, ?_, key, key⟩
  rw [Int.modEq_iff_dvd]
  exact ⟨1, by simp only [p, q, p', q']; ring⟩

/-- At `ℓ = 2` the sharpness witnesses are odd, so they are admissible factor
residues of an RSA-type semiprime. -/
theorem vieta_precision_sharp_odd (c : ℕ) (hc : 1 ≤ c) :
    Odd (1 - 2 * (2 : ℤ) ^ c) ∧ Odd (1 - (2 : ℤ) ^ c) := by
  obtain ⟨d, rfl⟩ : ∃ d, c = d + 1 := ⟨c - 1, by omega⟩
  refine ⟨⟨-(2 : ℤ) ^ (d + 1), by ring⟩, ⟨-(2 : ℤ) ^ d, by ring⟩⟩

/-- **Infinite precision (Vieta over a domain).**  Exact sum and product determine
the unordered pair exactly — the limit `k → ∞` of `vieta_precision`. -/
theorem vieta_exact {R : Type*} [CommRing R] [IsDomain R] {p q p' q' : R}
    (hs : p + q = p' + q') (hn : p * q = p' * q') :
    (p = p' ∧ q = q') ∨ (p = q' ∧ q = p') := by
  have h : (p - p') * (p - q') = 0 := by
    have : (p - p') * (p - q') = p * ((p + q) - (p' + q')) + (p' * q' - p * q) := by ring
    rw [this, hs, hn]; ring
  rcases mul_eq_zero.mp h with h1 | h1
  · left
    have e1 : p = p' := sub_eq_zero.mp h1
    exact ⟨e1, by subst e1; exact add_left_cancel hs⟩
  · right
    have e1 : p = q' := sub_eq_zero.mp h1
    refine ⟨e1, ?_⟩
    subst e1
    have : q + p = p' + p := by rw [add_comm q p, hs]
    exact add_right_cancel this

/-- **The `D₄` corollary (positive half).**  Sum and product modulo `2⁵ = 32`
determine the unordered pair of residues modulo `8`, hence the unordered pair of
`D₄@8` splitting types. -/
theorem d4_pair_determined_mod32 {p q p' q' : ℤ}
    (hs : p + q ≡ p' + q' [ZMOD 32]) (hn : p * q ≡ p' * q' [ZMOD 32]) :
    (p ≡ p' [ZMOD 8] ∧ q ≡ q' [ZMOD 8]) ∨ (p ≡ q' [ZMOD 8] ∧ q ≡ p' [ZMOD 8]) := by
  have h := vieta_precision Int.prime_two 5 (p := p) (q := q) (p' := p') (q' := q')
    (by norm_num; exact hs) (by norm_num; exact hn)
  norm_num at h
  exact h

/-- **The `D₄` corollary (negative half).**  Modulo `16` the sum and product do *not*
determine the unordered pair modulo `8`: `(1, 9)` and `(13, 13)` (all odd) have the
same sum and product modulo `16`, but `{1, 9} ≠ {5, 5}` modulo `8`. -/
theorem d4_pair_not_determined_mod16 :
    (1 + 9 : ℤ) ≡ 13 + 13 [ZMOD 16] ∧ (1 * 9 : ℤ) ≡ 13 * 13 [ZMOD 16] ∧
      ¬ (1 : ℤ) ≡ 13 [ZMOD 8] ∧ ¬ (9 : ℤ) ≡ 13 [ZMOD 8] := by
  refine ⟨by decide, by decide, by decide, by decide⟩

end HintSD

namespace HintSD

/-- **Hensel regime (separated roots).**  If the two factors are distinct modulo the
prime `ℓ` (`ℓ ∤ p - q`), then agreement of sum and product modulo `ℓ^k` determines the
unordered pair at *full* precision `ℓ^k`.  At `ℓ = 2` this hypothesis fails for every
pair of odd factors — which is why the `2`-power dials lose half their precision. -/
theorem vieta_full_precision_of_separated {ℓ : ℤ} (hℓ : Prime ℓ) (k : ℕ) {p q p' q' : ℤ}
    (hsep : ¬ ℓ ∣ p - q)
    (hs : p + q ≡ p' + q' [ZMOD ℓ ^ k]) (hn : p * q ≡ p' * q' [ZMOD ℓ ^ k]) :
    (p ≡ p' [ZMOD ℓ ^ k] ∧ q ≡ q' [ZMOD ℓ ^ k]) ∨
    (p ≡ q' [ZMOD ℓ ^ k] ∧ q ≡ p' [ZMOD ℓ ^ k]) := by
  rcases Nat.eq_zero_or_pos k with rfl | hk
  · left; simp [Int.modEq_iff_dvd]
  have hsd : ℓ ^ k ∣ (p + q) - (p' + q') := Int.ModEq.dvd hs.symm
  have hprod : ℓ ^ k ∣ (p - p') * (p - q') := by
    rw [vieta_identity]
    exact dvd_add (dvd_mul_of_dvd_right hsd _) (Int.ModEq.dvd hn)
  have hℓs : ℓ ∣ (p + q) - (p' + q') :=
    (dvd_pow_self ℓ (by omega)).trans hsd
  -- not both factors can be divisible by `ℓ`
  have hnot : ¬ (ℓ ∣ p - p' ∧ ℓ ∣ p - q') := by
    rintro ⟨h1, h2⟩
    apply hsep
    have : p - q = (p - p') + (p - q') - ((p + q) - (p' + q')) := by ring
    rw [this]; exact dvd_sub (dvd_add h1 h2) hℓs
  have hq_of : ∀ {x y : ℤ}, ℓ ^ k ∣ x * y → ¬ ℓ ∣ x → ℓ ^ k ∣ y := fun h hx =>
    ((Prime.coprime_iff_not_dvd hℓ).mpr hx).pow_left.dvd_of_dvd_mul_left h
  by_cases h1 : ℓ ∣ p - p'
  · have h2 : ¬ ℓ ∣ p - q' := fun h2 => hnot ⟨h1, h2⟩
    have hpp : ℓ ^ k ∣ p - p' := by
      rw [mul_comm] at hprod; exact hq_of hprod h2
    left
    refine ⟨(Int.modEq_iff_dvd).mpr ?_, (Int.modEq_iff_dvd).mpr ?_⟩
    · have : p' - p = -(p - p') := by ring
      rw [this]; exact (dvd_neg).mpr hpp
    · have : q' - q = (p - p') - ((p + q) - (p' + q')) := by ring
      rw [this]; exact dvd_sub hpp hsd
  · have hpq : ℓ ^ k ∣ p - q' := hq_of hprod h1
    right
    refine ⟨(Int.modEq_iff_dvd).mpr ?_, (Int.modEq_iff_dvd).mpr ?_⟩
    · have : q' - p = -(p - q') := by ring
      rw [this]; exact (dvd_neg).mpr hpq
    · have : p' - q = (p - q') - ((p + q) - (p' + q')) := by ring
      rw [this]; exact dvd_sub hpq hsd

/-- At `ℓ = 2` odd factors are never separated: `2 ∣ p - q` for all odd `p, q`.
So the `2`-adic dials (such as `D₄@8`) always sit in the half-precision regime of
`vieta_precision`, never in the Hensel regime. -/
theorem two_adic_never_separated {p q : ℤ} (hp : Odd p) (hq : Odd q) : (2 : ℤ) ∣ p - q := by
  obtain ⟨a, rfl⟩ := hp; obtain ⟨b, rfl⟩ := hq
  exact ⟨a - b, by ring⟩

end HintSD