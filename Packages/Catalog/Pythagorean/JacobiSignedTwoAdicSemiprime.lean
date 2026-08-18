import Tropical.JacobiSignedTwoAdic
import Tropical.JacobiSignedNonDial

/-!
# The 2-adic content of the Jacobi-signed circle count

This file settles conjecture **C3** of the JACSIGN future-directions list and repairs its
false half.

Recall from `Catalog/Tropical/JacobiSigned*.lean`:

* `JacSign.WZ n = ∑_{x : ZMod n} (x(1-x²) / n)` is the Jacobi-signed circle count,
* `JacSign.WZ_mul` : it is multiplicative in the modulus,
* `JacSign.W_mod_four` : for a prime `p ≡ 1 (mod 4)` one has `W p = 2 s` with `s` odd,
* `JacSign.W_eq_zero_of_three_mod_four` : `W p = 0` for `p ≡ 3 (mod 4)`,
* `JacSign.two_squares_odd_leg` : `p = a² + b²` with `2a = W p` and `a` odd.

Main results.

* `JacSign.WZ_semiprime_two_adic` : for `N = p q` with distinct primes `p ≡ q ≡ 1 (mod 4)`,
  `WZ N = 4 s` with `s` odd — i.e. `v₂(WZ N) = 2` **exactly**.
* `JacSign.padicValInt_WZ_semiprime` : the same statement phrased with `padicValInt 2`.
* `JacSign.WZ_two_adic_squarefree` : the general case — for squarefree `N` all of whose prime
  factors are `≡ 1 (mod 4)`, `WZ N = 2^{ω(N)} s` with `s` odd, so
  `v₂(WZ N) = #{p ∣ N}`.
* `JacSign.WZ_semiprime_eq_zero_iff` : for distinct odd primes, `WZ (p q) = 0` **iff** one of
  the primes is `≡ 3 (mod 4)`; so the statistic detects exactly the `3 mod 4` factors.
* `JacSign.two_adic_blind_to_split` : the 2-adic valuation is *constant* on the family of
  semiprimes with both factors `≡ 1 (mod 4)`, hence carries zero bits about the split.
* `JacSign.vanishing_not_determined_by_mod_four` and
  `JacSign.not_two_adic_dial_mod_four` : the *false* half of C3.  It is **not** true that the
  2-adic content of `WZ` is determined by `N mod 4`: `21 ≡ 85 ≡ 1 (mod 4)` but `WZ 21 = 0`
  while `WZ 85 = -4`.
* `JacSign.WZ_semiprime_four_squares` and `JacSign.WZ_semiprime_gaussian_leg` : the exact
  Brahmagupta refinement of the semiprime Weil floor.  `N = pq` is a sum of four squares whose
  first leg is `WZ N / 4`, and `WZ N ≡ 4u (mod 16)` where `u` is an **odd Gaussian leg** of
  `N = u² + v²`.  The statistic therefore pins down `u mod 4`, and nothing more.
-/

open Finset

namespace JacSign

/-! ### Elementary 2-adic bookkeeping -/

theorem ne_two_of_one_mod_four {p : ℕ} (h1 : p % 4 = 1) : p ≠ 2 := by omega

/-- If `x = 2^k · s` with `s` odd then the 2-adic valuation of `x` is exactly `k`. -/
theorem padicValInt_two_eq {x s : ℤ} {k : ℕ} (hx : x = 2 ^ k * s) (hs : ¬ (2 : ℤ) ∣ s) :
    padicValInt 2 x = k := by
  have hs0 : s ≠ 0 := by
    rintro rfl
    exact hs ⟨0, by ring⟩
  have hpow : ((2 : ℤ) ^ k) ≠ 0 := pow_ne_zero _ (by norm_num)
  have hpowval : padicValInt 2 ((2 : ℤ) ^ k) = k := by
    rw [show ((2 : ℤ) ^ k) = (((2 ^ k : ℕ) : ℤ)) by push_cast; ring, padicValInt.of_nat,
      padicValNat.prime_pow]
  have hsval : padicValInt 2 s = 0 := by
    refine padicValInt.eq_zero_of_not_dvd ?_
    simpa using hs
  rw [hx, padicValInt.mul hpow hs0, hpowval, hsval, add_zero]

/-- A product of two odd integers is odd. -/
theorem not_two_dvd_mul {a b : ℤ} (ha : ¬ (2 : ℤ) ∣ a) (hb : ¬ (2 : ℤ) ∣ b) :
    ¬ (2 : ℤ) ∣ a * b := by
  intro h
  rcases (Int.prime_two.dvd_mul).mp h with h | h
  · exact ha h
  · exact hb h

/-! ### The exact 2-adic valuation at a semiprime -/

/-- **C3, semiprime case.** For `N = p q` with distinct primes `p ≡ q ≡ 1 (mod 4)` the
Jacobi-signed circle count is `4` times an odd number: `v₂(WZ N) = 2` exactly. -/
theorem WZ_semiprime_two_adic {p q : ℕ} [Fact p.Prime] [Fact q.Prime] (hpq : p ≠ q)
    (hp1 : p % 4 = 1) (hq1 : q % 4 = 1) :
    ∃ s : ℤ, WZ (p * q) = 4 * s ∧ ¬ (2 : ℤ) ∣ s := by
  obtain ⟨a, ha, hao⟩ := W_mod_four p (ne_two_of_one_mod_four hp1) hp1
  obtain ⟨b, hb, hbo⟩ := W_mod_four q (ne_two_of_one_mod_four hq1) hq1
  exact ⟨a * b, by rw [WZ_semiprime hpq, ha, hb]; ring, not_two_dvd_mul hao hbo⟩

/-- The valuation statement in divisibility form: `4 ∣ WZ N` but `8 ∤ WZ N`. -/
theorem WZ_semiprime_four_dvd_not_eight {p q : ℕ} [Fact p.Prime] [Fact q.Prime] (hpq : p ≠ q)
    (hp1 : p % 4 = 1) (hq1 : q % 4 = 1) :
    (4 : ℤ) ∣ WZ (p * q) ∧ ¬ (8 : ℤ) ∣ WZ (p * q) := by
  obtain ⟨s, hs, hodd⟩ := WZ_semiprime_two_adic hpq hp1 hq1
  refine ⟨⟨s, hs⟩, ?_⟩
  rintro ⟨t, ht⟩
  exact hodd ⟨t, by omega⟩

/-- The 2-adic valuation of the statistic at such a semiprime is exactly `2`. -/
theorem padicValInt_WZ_semiprime {p q : ℕ} [Fact p.Prime] [Fact q.Prime] (hpq : p ≠ q)
    (hp1 : p % 4 = 1) (hq1 : q % 4 = 1) : padicValInt 2 (WZ (p * q)) = 2 := by
  obtain ⟨s, hs, hodd⟩ := WZ_semiprime_two_adic hpq hp1 hq1
  exact padicValInt_two_eq (k := 2) (by rw [hs]; ring) hodd

/-- In particular the statistic does not vanish on this family. -/
theorem WZ_semiprime_ne_zero {p q : ℕ} [Fact p.Prime] [Fact q.Prime] (hpq : p ≠ q)
    (hp1 : p % 4 = 1) (hq1 : q % 4 = 1) : WZ (p * q) ≠ 0 := by
  obtain ⟨s, hs, hodd⟩ := WZ_semiprime_two_adic hpq hp1 hq1
  intro h
  rw [h] at hs
  exact hodd ⟨0, by omega⟩

/-- **Exact vanishing criterion.**  For distinct odd primes the Jacobi-signed count of the
semiprime vanishes precisely when one of the two factors is `≡ 3 (mod 4)`. -/
theorem WZ_semiprime_eq_zero_iff {p q : ℕ} [Fact p.Prime] [Fact q.Prime] (hpq : p ≠ q)
    (hp : p ≠ 2) (hq : q ≠ 2) : WZ (p * q) = 0 ↔ (p % 4 = 3 ∨ q % 4 = 3) := by
  have hpodd : p % 2 = 1 := (Fact.out : p.Prime).eq_two_or_odd.resolve_left hp
  have hqodd : q % 2 = 1 := (Fact.out : q.Prime).eq_two_or_odd.resolve_left hq
  constructor
  · intro h
    by_contra hcon
    push_neg at hcon
    have hp1 : p % 4 = 1 := by omega
    have hq1 : q % 4 = 1 := by omega
    exact WZ_semiprime_ne_zero hpq hp1 hq1 h
  · exact fun h => WZ_semiprime_eq_zero_of_three_mod_four hpq h

/-- **Zero information about the split.**  On the whole family of semiprimes with both prime
factors `≡ 1 (mod 4)` the 2-adic valuation of the statistic is the constant `2`: it cannot
distinguish one factorisation from another. -/
theorem two_adic_blind_to_split {p q p' q' : ℕ} [Fact p.Prime] [Fact q.Prime] [Fact p'.Prime]
    [Fact q'.Prime] (hpq : p ≠ q) (hp1 : p % 4 = 1) (hq1 : q % 4 = 1)
    (hpq' : p' ≠ q') (hp1' : p' % 4 = 1) (hq1' : q' % 4 = 1) :
    padicValInt 2 (WZ (p * q)) = padicValInt 2 (WZ (p' * q')) := by
  rw [padicValInt_WZ_semiprime hpq hp1 hq1, padicValInt_WZ_semiprime hpq' hp1' hq1']

/-! ### The general squarefree case -/

/-- Transporting `WZ` along an equality of moduli (the `NeZero` instance is irrelevant). -/
theorem WZ_congr {m n : ℕ} (h : m = n) (i : NeZero m) (j : NeZero n) :
    @WZ m i = @WZ n j := by
  subst h; rfl

theorem WZ_one (i : NeZero 1) : @WZ 1 i = 1 := by
  simp [WZ, jchar]

/-- **C3, general case (finset form).**  For a finite set `S` of primes, all `≡ 1 (mod 4)`,
the Jacobi-signed count of `∏ S` is `2^{|S|}` times an odd number. -/
theorem WZ_prod_two_adic (S : Finset ℕ) (hS : ∀ p ∈ S, p.Prime ∧ p % 4 = 1)
    (i : NeZero (∏ p ∈ S, p)) :
    ∃ s : ℤ, @WZ (∏ p ∈ S, p) i = 2 ^ S.card * s ∧ ¬ (2 : ℤ) ∣ s := by
  induction S using Finset.cons_induction with
  | empty =>
      refine ⟨1, ?_, by norm_num⟩
      have h1 : (∏ p ∈ (∅ : Finset ℕ), p) = 1 := by simp
      rw [WZ_congr h1 i (⟨one_ne_zero⟩ : NeZero 1), WZ_one]
      simp
  | cons a T ha ih =>
      have hprime : a.Prime := (hS a (Finset.mem_cons_self a T)).1
      have h1 : a % 4 = 1 := (hS a (Finset.mem_cons_self a T)).2
      have hT : ∀ p ∈ T, p.Prime ∧ p % 4 = 1 := fun p hp =>
        hS p (Finset.mem_cons_of_mem hp)
      haveI : Fact a.Prime := ⟨hprime⟩
      haveI ia : NeZero a := ⟨hprime.ne_zero⟩
      have hTpos : 0 < ∏ p ∈ T, p :=
        Finset.prod_pos fun p hp => (hT p hp).1.pos
      haveI iT : NeZero (∏ p ∈ T, p) := ⟨hTpos.ne'⟩
      obtain ⟨t, htq, htodd⟩ := ih hT iT
      -- coprimality of `a` with the rest of the product
      have hcop : a.Coprime (∏ p ∈ T, p) := by
        refine Nat.Coprime.prod_right fun b hb => ?_
        have hb' : b.Prime := (hT b hb).1
        have hne : a ≠ b := by
          rintro rfl
          exact ha hb
        exact (Nat.coprime_primes hprime hb').mpr hne
      obtain ⟨s, hs, hsodd⟩ := W_mod_four a (ne_two_of_one_mod_four h1) h1
      have hcons : (∏ p ∈ Finset.cons a T ha, p) = a * ∏ p ∈ T, p := Finset.prod_cons ha
      refine ⟨s * t, ?_, not_two_dvd_mul hsodd htodd⟩
      have hmul : @WZ (a * ∏ p ∈ T, p) (by infer_instance) = WZ a * @WZ (∏ p ∈ T, p) iT :=
        WZ_mul a (∏ p ∈ T, p) hcop
      rw [WZ_congr hcons i (by infer_instance), hmul, WZ_prime a, hs, htq,
        Finset.card_cons, pow_succ]
      ring

/-- **C3, general case.**  For squarefree `N` whose prime factors are all `≡ 1 (mod 4)`,
`WZ N = 2^{ω(N)} · (odd)`, i.e. the 2-adic valuation of the statistic counts exactly the number
of prime factors of `N`. -/
theorem WZ_two_adic_squarefree {N : ℕ} (i : NeZero N) (hN : Squarefree N)
    (hfac : ∀ p ∈ N.primeFactors, p % 4 = 1) :
    ∃ s : ℤ, @WZ N i = 2 ^ N.primeFactors.card * s ∧ ¬ (2 : ℤ) ∣ s := by
  have hprod : (∏ p ∈ N.primeFactors, p) = N := Nat.prod_primeFactors_of_squarefree hN
  haveI j : NeZero (∏ p ∈ N.primeFactors, p) := ⟨by rw [hprod]; exact i.out⟩
  obtain ⟨s, hs, hodd⟩ := WZ_prod_two_adic N.primeFactors
    (fun p hp => ⟨Nat.prime_of_mem_primeFactors hp, hfac p hp⟩) j
  exact ⟨s, (WZ_congr hprod j i).symm.trans hs, hodd⟩

/-- The 2-adic valuation of `WZ N` counts the prime factors of a squarefree `N`
all of whose prime factors are `≡ 1 (mod 4)`. -/
theorem padicValInt_WZ_squarefree {N : ℕ} (i : NeZero N) (hN : Squarefree N)
    (hfac : ∀ p ∈ N.primeFactors, p % 4 = 1) :
    padicValInt 2 (@WZ N i) = N.primeFactors.card := by
  obtain ⟨s, hs, hodd⟩ := WZ_two_adic_squarefree i hN hfac
  exact padicValInt_two_eq hs hodd

/-! ### The false half of C3: the 2-adic content is *not* a function of `N mod 4` -/

/-- **Refutation.** `21 = 3·7` and `85 = 5·17` are both `≡ 1 (mod 4)` semiprimes, yet
`WZ 21 = 0` and `WZ 85 = -4`.  Hence the vanishing (and a fortiori the 2-adic valuation) of the
statistic is *not* determined by `N mod 4`, contrary to the "already publicly computable"
half of conjecture C3. -/
theorem vanishing_not_determined_by_mod_four :
    ∃ M N : ℕ, M % 4 = N % 4 ∧
      (∃ p q : ℕ, p.Prime ∧ q.Prime ∧ p ≠ q ∧ M = p * q) ∧
      (∃ p q : ℕ, p.Prime ∧ q.Prime ∧ p ≠ q ∧ N = p * q) ∧
      (∃ iM : NeZero M, @WZ M iM = 0) ∧ (∃ iN : NeZero N, @WZ N iN ≠ 0) := by
  refine ⟨21, 85, by norm_num, ⟨3, 7, by norm_num, by norm_num, by norm_num, by norm_num⟩,
    ⟨5, 17, by norm_num, by norm_num, by norm_num, by norm_num⟩,
    ⟨⟨by norm_num⟩, WZ_21⟩, ⟨⟨by norm_num⟩, ?_⟩⟩
  rw [WZ_85]
  norm_num

/-- The statistic is not a dial modulo `4` for composite moduli either. -/
theorem not_two_adic_dial_mod_four :
    ¬ ∃ f : ℕ → ℤ, ∀ (n : ℕ) (inst : NeZero n), @WZ n inst = f (n % 4) := by
  rintro ⟨f, hf⟩
  have h21 := hf 21 ⟨by norm_num⟩
  have h85 := hf 85 ⟨by norm_num⟩
  rw [WZ_21] at h21
  rw [WZ_85] at h85
  norm_num at h21 h85
  omega

/-! ### Brahmagupta refinement: the statistic and the Gaussian coordinates of `N` -/

/-- For `p ≡ 1 (mod 4)` written as `p = a² + b²` with `2a = W p` odd, the companion leg `b` is
even. -/
theorem even_companion_leg {p : ℕ} [Fact p.Prime] (h1 : p % 4 = 1) {a b : ℤ}
    (hab : (p : ℤ) = a ^ 2 + b ^ 2) (ha : ¬ (2 : ℤ) ∣ a) : (2 : ℤ) ∣ b := by
  have hp4 : (p : ℤ) % 4 = 1 := by omega
  by_contra hb
  obtain ⟨k, hk⟩ : Odd a := Int.odd_iff.mpr (by omega)
  obtain ⟨m, hm⟩ : Odd b := Int.odd_iff.mpr (by omega)
  have hsum : (p : ℤ) = 4 * (k ^ 2 + k + m ^ 2 + m) + 2 := by
    rw [hab, hk, hm]; ring
  omega

/-- **The four-square refinement of the semiprime floor.**  For `N = p q` with distinct primes
`p ≡ q ≡ 1 (mod 4)`, `N` is a sum of four explicit squares whose first leg is `WZ N / 4`
(an odd number).  Multiplying by `16`, this is an exact identity refining
`WZ N ² ≤ 16 N` — the deficiency `16N - WZ(N)²` is itself a sum of three squares. -/
theorem WZ_semiprime_four_squares {p q : ℕ} [Fact p.Prime] [Fact q.Prime] (hpq : p ≠ q)
    (hp1 : p % 4 = 1) (hq1 : q % 4 = 1) :
    ∃ s u v w : ℤ, ((p * q : ℕ) : ℤ) = s ^ 2 + u ^ 2 + v ^ 2 + w ^ 2 ∧
      WZ (p * q) = 4 * s ∧ ¬ (2 : ℤ) ∣ s ∧
      16 * ((p * q : ℕ) : ℤ) = (WZ (p * q)) ^ 2 + (4 * u) ^ 2 + (4 * v) ^ 2 + (4 * w) ^ 2 := by
  obtain ⟨a, b, hab, haW, hao⟩ := two_squares_odd_leg p (ne_two_of_one_mod_four hp1) hp1
  obtain ⟨c, d, hcd, hcW, hco⟩ := two_squares_odd_leg q (ne_two_of_one_mod_four hq1) hq1
  have hN : ((p * q : ℕ) : ℤ) = (p : ℤ) * (q : ℤ) := by push_cast; ring
  have hWZ : WZ (p * q) = 4 * (a * c) := by
    rw [WZ_semiprime hpq, ← haW, ← hcW]; ring
  refine ⟨a * c, a * d, b * c, b * d, ?_, hWZ, not_two_dvd_mul hao hco, ?_⟩
  · rw [hN, hab, hcd]; ring
  · rw [hWZ, hN, hab, hcd]; ring

/-- **The statistic reads the odd Gaussian coordinate of `N` modulo `4`.**  For `N = pq` with
distinct primes `≡ 1 (mod 4)` there is a two-square representation `N = u² + v²` with `u` odd
such that `WZ N ≡ 4u (mod 16)`.  Thus the 4-divisible part of the statistic is the odd Gaussian
leg of `N` mod `4` — an invariant of `N` itself, computable from `N` without its factorisation,
so no information about the split leaks. -/
theorem WZ_semiprime_gaussian_leg {p q : ℕ} [Fact p.Prime] [Fact q.Prime] (hpq : p ≠ q)
    (hp1 : p % 4 = 1) (hq1 : q % 4 = 1) :
    ∃ u v : ℤ, ((p * q : ℕ) : ℤ) = u ^ 2 + v ^ 2 ∧ ¬ (2 : ℤ) ∣ u ∧
      (16 : ℤ) ∣ (WZ (p * q) - 4 * u) := by
  obtain ⟨a, b, hab, haW, hao⟩ := two_squares_odd_leg p (ne_two_of_one_mod_four hp1) hp1
  obtain ⟨c, d, hcd, hcW, hco⟩ := two_squares_odd_leg q (ne_two_of_one_mod_four hq1) hq1
  obtain ⟨b', hb'⟩ := even_companion_leg (p := p) hp1 hab hao
  obtain ⟨d', hd'⟩ := even_companion_leg (p := q) hq1 hcd hco
  have hN : ((p * q : ℕ) : ℤ) = (p : ℤ) * (q : ℤ) := by push_cast; ring
  have hWZ : WZ (p * q) = 4 * (a * c) := by
    rw [WZ_semiprime hpq, ← haW, ← hcW]; ring
  refine ⟨a * c - b * d, a * d + b * c, ?_, ?_, ⟨b' * d', ?_⟩⟩
  · rw [hN, hab, hcd]; ring
  · intro h
    have hbd : (2 : ℤ) ∣ b * d := ⟨b' * d, by rw [hb']; ring⟩
    obtain ⟨k, hk⟩ := h
    obtain ⟨l, hl⟩ := hbd
    exact not_two_dvd_mul hao hco ⟨k + l, by omega⟩
  · rw [hWZ, hb', hd']; ring

end JacSign