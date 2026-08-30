import Mathlib
import Bridges.TreeSieveLottery
import Bridges.MultiTargetTrialDivision
import Bridges.NormFormBlindness

/-!
# No fixed search order escapes the size barrier, and blind moduli are infinite

Two open items from `FUTURE_DIRECTIONS.md` are settled here, both of them
quantitative sharpenings of the round-72 verdicts.

## 1. No-free-lunch for enumeration orders (direction 4)

`MultiTargetTrialDivision.lean` proves that the *ascending* sweep first hits at
`a = min p q`, so its cost is exactly the trial-division cost.  One could hope
that a cleverer, `N`-independent order of candidate values does better.
`enumeration_defeated` shows it cannot: for **every** function `f : ℕ → ℕ` and
every prefix length `K` there are semiprimes — arbitrarily large ones — on which
the first `K` probes of `f` all miss.  The reason is structural and matches the
lottery analysis: an `N`-independent prefix is a finite set of integers, and a
finite set of integers only ever exposes the primes below its maximum.

## 2. The blind moduli form an infinite family, for every norm form (direction 3)

`NormFormBlindness.lean` shows that a search whose values are primitively
represented by `x² + D y²` has `gcd(value, N) = 1` whenever every prime factor
of `N` is inert.  Here we show that this is not a measure-zero curiosity:
by Dirichlet's theorem on primes in arithmetic progressions the set of blind
composite moduli is *infinite*, both for `D = 1` (factors `≡ 3 mod 4`,
`infinite_blindOne_semiprimes`) and for `D = 2` (factors `≡ 5 mod 8`,
`infinite_blindTwo_semiprimes`).

## 3. Capstone

`enumeration_and_hypotenuse_face_both_defeated` combines the two: given any
enumeration order and any prefix length, there is a semiprime, larger than any
prescribed bound, on which the order's whole prefix misses *and* on which the
entire (infinite) Berggren hypotenuse face has gcd `1`.  The two failure modes
are simultaneous, so trading one for the other cannot help.
-/

namespace SearchOrder

open MultiTarget NormFormBlindness TreeSieve

/-! ## Part 1 — no `N`-independent enumeration order beats the size barrier -/

/-- A finite prefix of an `N`-independent enumeration is bounded. -/
theorem prefix_bounded (f : ℕ → ℕ) (K : ℕ) {k : ℕ} (hk : k < K) :
    f k ≤ (Finset.range K).sup f :=
  Finset.le_sup (f := f) (Finset.mem_range.mpr hk)

/-- **No-free-lunch for candidate orders.**  For any `N`-independent enumeration
`f` of candidate values and any prefix length `K`, there is a semiprime `p * q`
with both primes larger than any prescribed bound `B` on which every one of the
first `K` probes misses: `gcd (f k) (p * q) = 1` for all `k < K`.

Together with `MultiTarget.isLeast_hit_min` this pins the situation exactly: the
ascending sweep pays `min p q`, and no fixed reordering of the candidates can
avoid paying a cost that grows with the smaller prime factor. -/
theorem enumeration_defeated (f : ℕ → ℕ) (K B : ℕ) :
    ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ B < p ∧ p < q ∧ ∀ k < K, ¬ Hit (p * q) (f k) := by
  set M := max B ((Finset.range K).sup f) with hM
  obtain ⟨p, hpM, hp⟩ := Nat.exists_infinite_primes (M + 1)
  obtain ⟨q, hqp, hq⟩ := Nat.exists_infinite_primes (p + 1)
  refine ⟨p, q, hp, hq, ?_, ?_, ?_⟩
  · have : B ≤ M := le_max_left _ _
    omega
  · omega
  · intro k hk hhit
    have hmin : min p q ≤ f k := min_le_of_hit hp hq hhit
    have hpq : min p q = p := min_eq_left (by omega)
    have hfk : f k ≤ M := le_trans (prefix_bounded f K hk) (le_max_right _ _)
    omega

/-! ## Part 2 — the blind moduli are infinite -/

/-- `N` is *blind* for the form `x² + y²`: no primitively represented value of
the form shares a factor with `N`. -/
def BlindOne (N : ℕ) : Prop :=
  ∀ a b c : ℤ, (∀ r : ℕ, r.Prime → ¬ ((r : ℤ) ∣ a ∧ (r : ℤ) ∣ b)) →
    a ^ 2 + b ^ 2 = c → Int.gcd c (N : ℤ) = 1

/-- `N` is *blind* for the form `x² + 2y²`. -/
def BlindTwo (N : ℕ) : Prop :=
  ∀ a b c : ℤ, (∀ r : ℕ, r.Prime → ¬ ((r : ℤ) ∣ a ∧ (r : ℤ) ∣ b)) →
    a ^ 2 + 2 * b ^ 2 = c → Int.gcd c (N : ℤ) = 1

/-- A semiprime with both factors `≡ 3 mod 4` is blind for `x² + y²`. -/
theorem blindOne_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hp4 : p % 4 = 3) (hq4 : q % 4 = 3) : BlindOne (p * q) := by
  intro a b c hprim hrep
  refine normForm_gcd_eq_one (D := 1) hprim (by linear_combination hrep) ?_
  intro r hr hrN
  refine (inert_one_iff hr).mpr ?_
  rcases (Nat.Prime.dvd_mul hr).mp hrN with h | h
  · rw [(Nat.prime_dvd_prime_iff_eq hr hp).mp h]; exact hp4
  · rw [(Nat.prime_dvd_prime_iff_eq hr hq).mp h]; exact hq4

/-- A semiprime with both factors `≡ 5 mod 8` is blind for `x² + 2y²`. -/
theorem blindTwo_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hp8 : p % 8 = 5) (hq8 : q % 8 = 5) : BlindTwo (p * q) := by
  intro a b c hprim hrep
  exact two_normForm_blind_semiprime hprim hrep hp hq (Or.inl hp8) (Or.inl hq8)

/-- Dirichlet supplies primes `≡ 3 mod 4` beyond any bound. -/
theorem exists_prime_gt_three_mod_four (n : ℕ) : ∃ p > n, p.Prime ∧ p % 4 = 3 := by
  obtain ⟨p, hpn, hp, hmod⟩ :=
    Nat.forall_exists_prime_gt_and_modEq n (q := 4) (a := 3) (by norm_num) (by decide)
  exact ⟨p, hpn, hp, by simpa [Nat.ModEq] using hmod⟩

/-- Dirichlet supplies primes `≡ 5 mod 8` beyond any bound. -/
theorem exists_prime_gt_five_mod_eight (n : ℕ) : ∃ p > n, p.Prime ∧ p % 8 = 5 := by
  obtain ⟨p, hpn, hp, hmod⟩ :=
    Nat.forall_exists_prime_gt_and_modEq n (q := 8) (a := 5) (by norm_num) (by decide)
  exact ⟨p, hpn, hp, by simpa [Nat.ModEq] using hmod⟩

/-- A product of two primes is composite. -/
theorem not_prime_mul_of_prime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) :
    ¬ (p * q).Prime := by
  intro h
  have hdvd : p ∣ p * q := Dvd.intro q rfl
  rcases (Nat.Prime.eq_one_or_self_of_dvd h p hdvd) with h1 | h2
  · exact absurd h1 (by have := hp.two_le; omega)
  · have hq1 : 1 < q := hq.one_lt
    have : p * 1 < p * q := by nlinarith [hp.two_le, hq1]
    omega

/-- **Blind composite moduli beyond any bound, `D = 1`.** -/
theorem exists_blindOne_composite_gt (B : ℕ) :
    ∃ N : ℕ, B < N ∧ ¬ N.Prime ∧ BlindOne N := by
  obtain ⟨p, hpB, hp, hp4⟩ := exists_prime_gt_three_mod_four B
  obtain ⟨q, hqp, hq, hq4⟩ := exists_prime_gt_three_mod_four p
  refine ⟨p * q, ?_, not_prime_mul_of_prime hp hq, blindOne_semiprime hp hq hp4 hq4⟩
  have h1 : p * 1 < p * q := by nlinarith [hp.two_le, hq.one_lt]
  omega

/-- **Blind composite moduli beyond any bound, `D = 2`.** -/
theorem exists_blindTwo_composite_gt (B : ℕ) :
    ∃ N : ℕ, B < N ∧ ¬ N.Prime ∧ BlindTwo N := by
  obtain ⟨p, hpB, hp, hp8⟩ := exists_prime_gt_five_mod_eight B
  obtain ⟨q, hqp, hq, hq8⟩ := exists_prime_gt_five_mod_eight p
  refine ⟨p * q, ?_, not_prime_mul_of_prime hp hq, blindTwo_semiprime hp hq hp8 hq8⟩
  have h1 : p * 1 < p * q := by nlinarith [hp.two_le, hq.one_lt]
  omega

/-- **The blind set is infinite for `x² + y²`.**  The obstruction found on the
Berggren hypotenuse face is not an artefact of small examples: infinitely many
composite moduli defeat the whole (infinite) family of primitively represented
values. -/
theorem infinite_blindOne_semiprimes :
    {N : ℕ | ¬ N.Prime ∧ BlindOne N}.Infinite := by
  refine Set.infinite_of_not_bddAbove ?_
  rintro ⟨B, hB⟩
  obtain ⟨N, hNB, hNp, hNblind⟩ := exists_blindOne_composite_gt B
  exact absurd (hB (Set.mem_setOf.mpr ⟨hNp, hNblind⟩)) (by omega)

/-- **The blind set is infinite for `x² + 2y²`.** -/
theorem infinite_blindTwo_semiprimes :
    {N : ℕ | ¬ N.Prime ∧ BlindTwo N}.Infinite := by
  refine Set.infinite_of_not_bddAbove ?_
  rintro ⟨B, hB⟩
  obtain ⟨N, hNB, hNp, hNblind⟩ := exists_blindTwo_composite_gt B
  exact absurd (hB (Set.mem_setOf.mpr ⟨hNp, hNblind⟩)) (by omega)

/-! ## Part 3 — both failure modes strike at once -/

/-- **Capstone.**  Fix any `N`-independent enumeration order `f`, any prefix
length `K`, and any bound `B`.  Then there is a semiprime `p * q` with
`B < p < q` such that

* the first `K` probes of the enumeration all miss (`Part 1`), and
* every hypotenuse of the Berggren tree — all infinitely many of them — has
  gcd `1` with `p * q` (`Part 2`, via the `≡ 3 mod 4` blindness class).

So the value-order route and the arithmetic-face route fail simultaneously on the
same moduli; improving one cannot rescue the other. -/
theorem enumeration_and_hypotenuse_face_both_defeated (f : ℕ → ℕ) (K B : ℕ) :
    ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ B < p ∧ p < q ∧ p % 4 = 3 ∧ q % 4 = 3 ∧
      (∀ k < K, ¬ Hit (p * q) (f k)) ∧
      (∀ w : List (Fin 3), Int.gcd ((bergOf w).2.2 ^ 2) ((p * q : ℕ) : ℤ) = 1) := by
  set M := max B ((Finset.range K).sup f) with hM
  obtain ⟨p, hpM, hp, hp4⟩ := exists_prime_gt_three_mod_four M
  obtain ⟨q, hqp, hq, hq4⟩ := exists_prime_gt_three_mod_four p
  have hmod : ∀ r : ℕ, r.Prime → r ∣ p * q → r % 4 = 3 := by
    intro r hr hrN
    rcases (Nat.Prime.dvd_mul hr).mp hrN with h | h
    · rw [(Nat.prime_dvd_prime_iff_eq hr hp).mp h]; exact hp4
    · rw [(Nat.prime_dvd_prime_iff_eq hr hq).mp h]; exact hq4
  refine ⟨p, q, hp, hq, ?_, hqp, hp4, hq4, ?_, fun w => berg_hyp_gcd_one_of_three_mod_four w hmod⟩
  · have : B ≤ M := le_max_left _ _
    omega
  · intro k hk hhit
    have hmin : min p q ≤ f k := min_le_of_hit hp hq hhit
    have hpq : min p q = p := min_eq_left (by omega)
    have hfk : f k ≤ M := le_trans (prefix_bounded f K hk) (le_max_right _ _)
    omega

end SearchOrder