import Bridges.CRTSplitNoGoClosureTime

/-!
# The CRT-Split No-Go, Part V: general moduli, barrier 5, and the boundary of the no-go

Three complements to Parts I–IV.

* **General moduli.**  Fact 1 is not special to semiprimes: for any `N > 1`, an integer `d`
  reveals a nontrivial factor of `N` iff some prime factor of `N` divides `d` while `N` itself
  does not (`reveal_iff_general`).  Reveal = *partial* agreement across the CRT decomposition.

* **Barrier 5 (structurally simple maps reveal nothing at all).**  A map that forgets its
  input — a constant polynomial, the paradigmatic "`N`-only" iteration — never reveals a
  factor, at any pair of times `1 ≤ s < t` (`constant_map_no_reveal`).  More generally any map
  whose two reduced orbits close *simultaneously* is blind (`no_reveal_of_simultaneous`).

* **The boundary (adversarial review).**  The no-go is a statement about *regimes*, not a
  universal lower bound: there are `N` for which an `N`-independent iteration reveals a factor
  at an exponent that is reached in `O(log M)` multiplications.  We verify this on the CTST
  modulus itself: `ord_631(2) = 45` divides `45` while `ord_541(2) = 540` does not, so
  `gcd(2^45 - 1, 341371) = 631` (`pollard_pm1_fast_demo`).  Both `630 = 2·3²·5·7` and
  `540 = 2²·3³·5` are smooth, which is exactly regime (b): the cost is the smoothness of the
  orders, an invariant of `p` and `q` that is invisible in `N` — so no *algorithm* can decide
  in advance which regime it is in.  A universal `poly(log N)` lower bound valid for *all*
  `N`-explicit maps would be equivalent to the hardness of factoring and is not claimed here.
-/

namespace CRTSplitNoGo

open Polynomial

/-! ## Fact 1 for an arbitrary modulus -/

/-- **Fact 1, general form.**  For any `N > 1`, `d` reveals a nontrivial factor of `N` iff some
prime factor of `N` divides `d` but `N` does not: the CRT agreement is partial. -/
theorem reveal_iff_general {N : ℕ} (hN : 1 < N) (d : ℤ) :
    RevealsFactor N d ↔ (∃ r : ℕ, r.Prime ∧ r ∣ N ∧ (r : ℤ) ∣ d) ∧ ¬ ((N : ℤ) ∣ d) := by
  set g : ℕ := Int.gcd d (N : ℤ) with hg
  have hgN : g ∣ N := Int.ofNat_dvd.mp (by simpa using Int.gcd_dvd_right d (N : ℤ))
  have hgd : (g : ℤ) ∣ d := Int.gcd_dvd_left d (N : ℤ)
  have hgle : g ≤ N := Nat.le_of_dvd (by omega) hgN
  constructor
  · rintro ⟨h1, h2⟩
    refine ⟨?_, ?_⟩
    · obtain ⟨r, hr, hrg⟩ := Nat.exists_prime_and_dvd (by omega : g ≠ 1)
      exact ⟨r, hr, hrg.trans hgN, (Int.natCast_dvd_natCast.mpr hrg).trans hgd⟩
    · intro hNd
      have : N ∣ g := Int.dvd_gcd hNd dvd_rfl
      have := Nat.le_of_dvd (by omega) this
      omega
  · rintro ⟨⟨r, hr, hrN, hrd⟩, hNd⟩
    have hrg : r ∣ g := Int.dvd_gcd hrd (Int.natCast_dvd_natCast.mpr hrN)
    have hgpos : 0 < g := by
      rcases Nat.eq_zero_or_pos g with h0 | h0
      · rw [h0] at hgN; exact absurd (Nat.eq_zero_of_zero_dvd hgN) (by omega)
      · exact h0
    refine ⟨lt_of_lt_of_le hr.one_lt (Nat.le_of_dvd hgpos hrg), ?_⟩
    rcases lt_or_eq_of_le hgle with h | h
    · exact h
    · exact absurd (h ▸ hgd) hNd

/-! ## Barrier 5: structurally simple maps -/

lemma polyOrbit_const (c x0 : ℤ) (n : ℕ) : polyOrbit (C c) x0 (n + 1) = c := by
  rw [polyOrbit_succ]; simp

/-- **Barrier 5.**  A constant ("`N`-only") iteration never reveals a factor: after the first
step all trajectory values coincide, so every difference is `0` and every gcd is `N`. -/
theorem constant_map_no_reveal {N : ℕ} (c x0 : ℤ) (s t : ℕ) (hs : 1 ≤ s) (hst : s < t) :
    ¬ RevealsFactor N (polyOrbit (C c) x0 t - polyOrbit (C c) x0 s) := by
  obtain ⟨s', rfl⟩ : ∃ s', s = s' + 1 := ⟨s - 1, by omega⟩
  obtain ⟨t', rfl⟩ : ∃ t', t = t' + 1 := ⟨t - 1, by omega⟩
  rw [polyOrbit_const, polyOrbit_const, sub_self]
  rintro ⟨-, h2⟩
  simp [Int.gcd] at h2

/-- A map whose two reduced orbits close simultaneously is blind: the CRT components agree,
so the gcd is trivial.  (The exclusive-or in Fact 1 is essential.) -/
theorem no_reveal_of_simultaneous {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (f : ℤ[X]) (x0 : ℤ) (s t : ℕ)
    (hsim : (modOrbit f p x0 t = modOrbit f p x0 s) ↔ (modOrbit f q x0 t = modOrbit f q x0 s)) :
    ¬ RevealsFactor (p * q) (polyOrbit f x0 t - polyOrbit f x0 s) := by
  intro hrev
  rcases (reveal_iff_xor_closure hp hq hne f x0 s t).mp hrev with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · exact h2 (hsim.mp h1)
  · exact h2 (hsim.mpr h1)

/-! ## The boundary of the no-go: a fast reveal in regime (b) -/

lemma orderOf_two_zmod631_dvd_45 : orderOf ((2 : ZMod 631)) ∣ 45 := by
  rw [orderOf_dvd_iff_pow_eq_one]
  decide

lemma orderOf_two_zmod541_not_dvd_45 : ¬ orderOf ((2 : ZMod 541)) ∣ 45 := by
  rw [orderOf_dvd_iff_pow_eq_one]
  decide

/-- **Boundary of the no-go (regime (b) can be fast).**  On the CTST modulus
`341371 = 631 · 541`, the `N`-independent datum `2^45 - 1` already reveals the factor `631`,
because `ord_631(2) = 45` divides `45` while `ord_541(2) = 540` does not.  Reaching the
exponent `45` costs `O(log 45)` modular multiplications — dramatically fewer than the `36`
rho steps of Part III.  The barrier is therefore genuinely regime-dependent: what is
exponential for a generic nonlinear map can be cheap when the orders are smooth. -/
theorem pollard_pm1_fast_demo :
    RevealsFactor (631 * 541) ((2 : ℤ) ^ 45 - 1) := by
  have hp : Nat.Prime 631 := by norm_num
  have hq : Nat.Prime 541 := by norm_num
  refine (pollard_pm1_reveal_iff hp hq (by norm_num) 2 45).mpr (Or.inl ⟨?_, ?_⟩)
  · simpa using orderOf_two_zmod631_dvd_45
  · simpa using orderOf_two_zmod541_not_dvd_45

end CRTSplitNoGo