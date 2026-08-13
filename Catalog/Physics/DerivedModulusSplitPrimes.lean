import Mathlib
import Physics.DerivedModulusNoGo

/-!
# Congruence rigidity: the spectrum of a derived modulus is `N`-independent

The two previous files show that a derived modulus `M = f(N)` shares nothing
with `N` (barrier 1/5) and that its own factorisation is fresh and unbounded
(barrier 4).  This file adds the sharpest structural statement of the three,
and it is genuinely cross-domain: the *set of primes that can occur at all* in
a derived modulus is a fixed set of split primes of a cyclotomic field,
determined by the polynomial alone and completely independent of `N`.

Concretely, for the two quadratic MULTIMOD moduli:

* every prime factor of `N² + 1` is `2` or `≡ 1 (mod 4)` — the split primes of
  `ℚ(i)`;
* every prime factor of `Φ₃(N) = N² + N + 1` is `3` or `≡ 1 (mod 3)` — the
  split primes of `ℚ(ζ₃)`;

and conversely every such prime does occur, for a suitable `N`.  So the map
`N ↦ (prime support of f(N))` has image inside one fixed arithmetic
progression: a "superselection sector" fixed by the Galois group of `f`, never
by the factorisation of `N`.

The physical reading: the derived modulus is an observable whose *spectrum* is
a property of the apparatus (the polynomial `f`), not of the state (`N`).  In
particular, for a Blum integer `N = p·q` with `p ≡ q ≡ 3 (mod 4)` the primes
`p, q` are *excluded by congruence* from ever appearing in `N² + 1` — a second,
independent proof of the no-go, orthogonal to the gcd argument.

## Main results

* `Physics.DerivedModulus.sqSucc_support_iff`,
  `Physics.DerivedModulus.cyc3_support_iff` : exact description of the prime
  spectra.
* `Physics.DerivedModulus.sqSucc_spectrum_N_independent` : the spectrum is the
  same fixed set for every `N`.
* `Physics.DerivedModulus.blum_factor_excluded` : congruence exclusion of the
  factors of a Blum integer.
-/

namespace Physics.DerivedModulus

/-- A divisor of `4` that does not divide `2` equals `4`. -/
theorem eq_four_of_dvd_four_not_dvd_two {d : ℕ} (h1 : d ∣ 4) (h2 : ¬ d ∣ 2) : d = 4 := by
  have hle : d ≤ 4 := Nat.le_of_dvd (by norm_num) h1
  interval_cases d <;> omega

/-! ## Forward direction: congruence constraints -/

/-- Every odd prime factor of `N² + 1` is `≡ 1 (mod 4)`: it splits in `ℚ(i)`.
The proof is a genuine order computation — the residue `N` has multiplicative
order exactly `4` modulo `p`. -/
theorem sqSucc_prime_mod_four {p N : ℕ} (hp : p.Prime) (h : p ∣ N ^ 2 + 1)
    (h2 : p ≠ 2) : p % 4 = 1 := by
  haveI : Fact p.Prime := ⟨hp⟩
  have hx : ((N : ZMod p)) ^ 2 + 1 = 0 := by
    have h0 : ((N ^ 2 + 1 : ℕ) : ZMod p) = 0 := (ZMod.natCast_eq_zero_iff _ _).mpr h
    push_cast at h0
    exact h0
  set x : ZMod p := (N : ZMod p) with hxdef
  have hsq : x ^ 2 = -1 := by linear_combination hx
  have h4 : x ^ 4 = 1 := by
    have hh : x ^ 4 = (x ^ 2) ^ 2 := by ring
    rw [hh, hsq]; ring
  have hx0 : x ≠ 0 := by
    intro h0; rw [h0] at hx; norm_num at hx
  have hne2 : x ^ 2 ≠ 1 := by
    intro h1
    rw [hsq] at h1
    have hz : ((2 : ℕ) : ZMod p) = 0 := by push_cast; linear_combination -h1
    exact h2 ((Nat.prime_dvd_prime_iff_eq hp (by norm_num)).mp
      ((ZMod.natCast_eq_zero_iff _ _).mp hz))
  have hord : orderOf x ∣ 4 := orderOf_dvd_of_pow_eq_one h4
  have hnd2 : ¬ (orderOf x ∣ 2) := fun hd => hne2 (orderOf_dvd_iff_pow_eq_one.mp hd)
  have hord4 : orderOf x = 4 := eq_four_of_dvd_four_not_dvd_two hord hnd2
  have hdvd : orderOf x ∣ p - 1 := orderOf_dvd_of_pow_eq_one (ZMod.pow_card_sub_one_eq_one hx0)
  rw [hord4] at hdvd
  have := hp.two_le
  omega

/-- Every prime factor of `Φ₃(N) = N² + N + 1` other than `3` is `≡ 1 (mod 3)`:
it splits in `ℚ(ζ₃)`.  Here `N` has multiplicative order exactly `3`. -/
theorem cyc3_prime_mod_three {p N : ℕ} (hp : p.Prime) (h : p ∣ N ^ 2 + N + 1)
    (h3 : p ≠ 3) : p % 3 = 1 := by
  haveI : Fact p.Prime := ⟨hp⟩
  have hx : ((N : ZMod p)) ^ 2 + (N : ZMod p) + 1 = 0 := by
    have h0 : ((N ^ 2 + N + 1 : ℕ) : ZMod p) = 0 := (ZMod.natCast_eq_zero_iff _ _).mpr h
    push_cast at h0
    exact h0
  set x : ZMod p := (N : ZMod p) with hxdef
  have hcube : x ^ 3 = 1 := by linear_combination (x - 1) * hx
  have hne1 : x ≠ 1 := by
    intro h1
    rw [h1] at hx
    have h3' : ((3 : ℕ) : ZMod p) = 0 := by push_cast; linear_combination hx
    exact h3 ((Nat.prime_dvd_prime_iff_eq hp (by norm_num)).mp
      ((ZMod.natCast_eq_zero_iff _ _).mp h3'))
  have hx0 : x ≠ 0 := by
    intro h0; rw [h0] at hx; norm_num at hx
  have hord : orderOf x ∣ 3 := orderOf_dvd_of_pow_eq_one hcube
  have hord3 : orderOf x = 3 := by
    rcases Nat.Prime.eq_one_or_self_of_dvd (by norm_num) _ hord with h1 | h1
    · exact absurd (orderOf_eq_one_iff.mp h1) hne1
    · exact h1
  have hdvd : orderOf x ∣ p - 1 := orderOf_dvd_of_pow_eq_one (ZMod.pow_card_sub_one_eq_one hx0)
  rw [hord3] at hdvd
  have := hp.two_le
  omega

/-! ## Converse direction: every allowed prime really occurs -/

/-- Every prime `≡ 1 (mod 4)` divides some `N² + 1`. -/
theorem exists_dvd_sqSucc_of_mod_four {p : ℕ} (hp : p.Prime) (h : p % 4 = 1) :
    ∃ N : ℕ, p ∣ N ^ 2 + 1 := by
  haveI : Fact p.Prime := ⟨hp⟩
  obtain ⟨y, hy⟩ : IsSquare (-1 : ZMod p) := ZMod.exists_sq_eq_neg_one_iff.mpr (by omega)
  refine ⟨y.val, ?_⟩
  have hz : ((y.val ^ 2 + 1 : ℕ) : ZMod p) = 0 := by
    push_cast [ZMod.natCast_val, ZMod.cast_id]
    rw [pow_two, ← hy]; ring
  exact (ZMod.natCast_eq_zero_iff _ _).mp hz

/-- Every prime `≡ 1 (mod 3)` divides some `Φ₃(N) = N² + N + 1`.  The witness is
built from an element of order `3` in `(ℤ/p)ˣ` (Cauchy's theorem). -/
theorem exists_dvd_cyc3_of_mod_three {p : ℕ} (hp : p.Prime) (h : p % 3 = 1) :
    ∃ N : ℕ, p ∣ N ^ 2 + N + 1 := by
  haveI : Fact p.Prime := ⟨hp⟩
  have hcard : Fintype.card (ZMod p)ˣ = p - 1 :=
    ZMod.card_units_eq_totient p ▸ Nat.totient_prime hp
  have h3 : 3 ∣ Fintype.card (ZMod p)ˣ := by
    rw [hcard]; have := hp.two_le; omega
  obtain ⟨u, hu⟩ := exists_prime_orderOf_dvd_card 3 h3
  set x : ZMod p := (u : ZMod p) with hxdef
  have hx3 : x ^ 3 = 1 := by
    have h1 : u ^ 3 = 1 := by rw [← hu]; exact pow_orderOf_eq_one u
    have := congrArg Units.val h1
    simpa using this
  have hx1 : x ≠ 1 := by
    intro h1
    have hu1 : u = 1 := Units.ext h1
    rw [hu1] at hu
    simp at hu
  have hkey : x ^ 2 + x + 1 = 0 := by
    have hfac : (x - 1) * (x ^ 2 + x + 1) = 0 := by linear_combination hx3
    rcases mul_eq_zero.mp hfac with h' | h'
    · exact absurd (by linear_combination h' : x = 1) hx1
    · exact h'
  refine ⟨x.val, ?_⟩
  have hz : ((x.val ^ 2 + x.val + 1 : ℕ) : ZMod p) = 0 := by
    push_cast [ZMod.natCast_val, ZMod.cast_id]
    exact hkey
  exact (ZMod.natCast_eq_zero_iff _ _).mp hz

/-! ## Exact spectra -/

/-- **Spectrum of the modulus `N² + 1`:** exactly the split primes of `ℚ(i)`. -/
theorem sqSucc_support_iff {p : ℕ} (hp : p.Prime) :
    (∃ N : ℕ, p ∣ N ^ 2 + 1) ↔ (p = 2 ∨ p % 4 = 1) := by
  constructor
  · rintro ⟨N, hN⟩
    by_cases h2 : p = 2
    · exact Or.inl h2
    · exact Or.inr (sqSucc_prime_mod_four hp hN h2)
  · rintro (rfl | h)
    · exact ⟨1, by norm_num⟩
    · exact exists_dvd_sqSucc_of_mod_four hp h

/-- **Spectrum of the modulus `Φ₃(N)`:** exactly the split primes of `ℚ(ζ₃)`. -/
theorem cyc3_support_iff {p : ℕ} (hp : p.Prime) :
    (∃ N : ℕ, p ∣ N ^ 2 + N + 1) ↔ (p = 3 ∨ p % 3 = 1) := by
  constructor
  · rintro ⟨N, hN⟩
    by_cases h3 : p = 3
    · exact Or.inl h3
    · exact Or.inr (cyc3_prime_mod_three hp hN h3)
  · rintro (rfl | h)
    · exact ⟨1, by norm_num⟩
    · exact exists_dvd_cyc3_of_mod_three hp h

/-- **`N`-independence of the spectrum.**  The prime support of the derived
modulus `N² + 1` is contained in one fixed set of primes for *every* `N`, and
that set is attained.  No feature of the spectrum can therefore vary with the
factorisation of `N`. -/
theorem sqSucc_spectrum_N_independent :
    {p : ℕ | p.Prime ∧ ∃ N : ℕ, p ∣ N ^ 2 + 1} = {p : ℕ | p.Prime ∧ (p = 2 ∨ p % 4 = 1)} := by
  ext p
  constructor
  · rintro ⟨hp, hN⟩
    exact ⟨hp, (sqSucc_support_iff hp).mp hN⟩
  · rintro ⟨hp, h⟩
    exact ⟨hp, (sqSucc_support_iff hp).mpr h⟩

/-- Same for `Φ₃`. -/
theorem cyc3_spectrum_N_independent :
    {p : ℕ | p.Prime ∧ ∃ N : ℕ, p ∣ N ^ 2 + N + 1}
      = {p : ℕ | p.Prime ∧ (p = 3 ∨ p % 3 = 1)} := by
  ext p
  constructor
  · rintro ⟨hp, hN⟩
    exact ⟨hp, (cyc3_support_iff hp).mp hN⟩
  · rintro ⟨hp, h⟩
    exact ⟨hp, (cyc3_support_iff hp).mpr h⟩

/-! ## Congruence exclusion -/

/-- **Blum rigidity.**  If `p ≡ 3 (mod 4)` — the standard choice for RSA/Blum
moduli — then `p` cannot divide `M² + 1` for *any* `M`, in particular not for
`M = N = p·q`.  This is an obstruction of a different nature from the gcd
barrier: it is a congruence condition on `p` alone. -/
theorem blum_factor_excluded {p : ℕ} (hp : p.Prime) (h3 : p % 4 = 3) (M : ℕ) :
    ¬ (p ∣ M ^ 2 + 1) := by
  intro hdvd
  have h2 : p ≠ 2 := by omega
  have := sqSucc_prime_mod_four hp hdvd h2
  omega

/-- Companion exclusion for `Φ₃`: a prime `≡ 2 (mod 3)` never divides
`M² + M + 1`. -/
theorem cyc3_factor_excluded {p : ℕ} (hp : p.Prime) (h : p % 3 = 2) (M : ℕ) :
    ¬ (p ∣ M ^ 2 + M + 1) := by
  intro hdvd
  have h3 : p ≠ 3 := by omega
  have := cyc3_prime_mod_three hp hdvd h3
  omega

/-- **Two independent proofs of the same no-go.**  For a Blum semiprime
`N = p·q` (both factors `≡ 3 mod 4`), the factor `p` is excluded from `N² + 1`
both by the gcd/polynomial barrier and by the congruence barrier; the second
excludes it even from *every* value `M² + 1`, `M` arbitrary. -/
theorem blum_double_barrier {p q : ℕ} (hp : p.Prime) (hp3 : p % 4 = 3) :
    ¬ ((p : ℤ) ∣ ((p * q : ℕ) : ℤ) ^ 2 + 1) ∧ ∀ M : ℕ, ¬ (p ∣ M ^ 2 + 1) := by
  refine ⟨?_, fun M => blum_factor_excluded hp hp3 M⟩
  intro hdvd
  have hnat : p ∣ (p * q) ^ 2 + 1 := by
    have h' : ((p : ℤ)) ∣ (((p * q) ^ 2 + 1 : ℕ) : ℤ) := by push_cast; exact hdvd
    exact_mod_cast h'
  exact blum_factor_excluded hp hp3 (p * q) hnat

end Physics.DerivedModulus