import Mathlib
import Novelty.EisensteinRepresentation

/-!
# Arithmetic Mirror Symmetry IX — Thue descent at the Gaussian discriminant `D = −4`

This file is the second half of cycle 4 of the research thread.  It closes sub-conjecture
**N3** of `FUTURE_DIRECTIONS.md` (the `D = −4` case of Conjecture I, "Thue descent extends
to all class-number-one CM discriminants") and, in doing so, **corrects the shape of the
trace identity displayed in Conjecture I**.

Cycle 2 proved the Eisenstein (`D = −3`) case: every prime `p ≡ 1 (mod 3)` satisfies
`4p = L² + 27M²`, and the weight-four CM trace `a_p = 3pL − L³` obeys
`4p³ − a_p² = 27M²(L² − p)²`.  Conjecture I extrapolated the *same shape*
`4p³ − a_p² = |D| M² (L² − p)²` to the other class-number-one discriminants.  Here the
`D = −4` case is carried out from scratch, reusing cycle 2's `thue_lemma` verbatim, and the
extrapolated shape is shown to be wrong: the correct Gaussian identity is

`4p³ − a_p² = 4b²(3a² − b²)²`   for   `p = a² + b²`,  `a_p = 2a(a² − 3b²)`,

which at `p = 5` gives `16`, not the `64` predicted by the displayed shape.

## Main results

* `isSquare_neg_one_of_one_mod_four` — a square root of `−1` mod `p` for `p ≡ 1 (mod 4)`.
* `prime_eq_sq_add_sq_of_one_mod_four` — **Thue descent, Gaussian case**: every prime
  `p ≡ 1 (mod 4)` is `a² + b²`.  Proved by the same pigeonhole-plus-descent scheme as the
  Eisenstein case, with the two-step descent `k ∈ {1, 2}` and the halving trick
  `x² + y² = 2p ⟹ ((x+y)/2)² + ((x−y)/2)² = p`.
* `prime_eq_sq_add_four_sq` — **N3, existence half**: `p ≡ 1 (mod 4) ⟹ p = L² + 4M²`.
* `prime_sq_add_four_sq_iff` — **N3, full equivalence** for odd primes:
  `(∃ L M, p = L² + 4M²) ↔ p ≡ 1 (mod 4)`.
* `gaussian_cm_weil_identity` — the Gaussian weight-four CM identity
  `4(a²+b²)³ − (2a(a²−3b²))² = 4b²(3a²−b²)²`, a polynomial identity over `ℤ`.
* `gaussian_cm_ramanujan_bound` — hence `a_p² ≤ 4p³`, the Ramanujan/Deligne bound.
* `gaussian_cm_trace_ne_zero` — every prime `p ≡ 1 (mod 4)` is **ordinary** for this CM
  family: the trace never vanishes.
* `conjecture_I_shape_refuted` — the displayed shape `4p³ − a_p² = |D| M² (L² − p)²` fails
  at `D = −4`, `p = 5`.
* `cm_trace_identity_symmetric` — the **uniform** replacement:
  `4n³ − (s³ − 3ns)² = −(s² − 4n)(s² − n)²` in the trace `s` and norm `n` of the CM
  generator, with `cm_trace_identity_eisenstein` and `cm_trace_identity_gaussian` recovering
  the `D = −3` identity of cycle 2 and the `D = −4` identity above as the two specializations.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  Cycle 2's proof of `p ≡ 1 (mod 3) ⟹ p = a² + 3b²` used
  only (i) a square root of the discriminant mod `p` and (ii) `thue_lemma`.  Neither
  mentions `3`, so the same argument should run at `D = −4`; the only `D`-dependent step is
  the descent bounding the multiplier `k` in `x² + |D|y² = kp`.  At `D = −4` the bound is
  `k ≤ 2` instead of `k ≤ 4`, so the case analysis should be *shorter*, not longer.
* **Experiment (Experimenter).**  Running it: Thue gives `x² ≤ p`, `y² ≤ p`, hence
  `0 < x² + y² ≤ 2p` and `k ∈ {1, 2}`.  `k = 2` is not impossible (unlike the parity
  obstruction at `k = 2` in the Eisenstein case) — it is *repaired*: `x` and `y` must then
  have the same parity, and both-even contradicts `p` odd, while both-odd gives the explicit
  solution `p = (s+t+1)² + (s−t)²`.  So the Gaussian descent has a genuinely different
  shape: a repair rather than an exclusion.
* **Analysis (Analyst).**  Extrapolating the *trace* identity, however, fails.  With
  `π = a + bi`, `a_p = π³ + π̄³ = 2a(a² − 3b²)` and the factorization
  `(A+B)³ − A(A−3B)² = B(3A − B)²` (with `A = a²`, `B = b²`) gives
  `4p³ − a_p² = 4b²(3a² − b²)²`.  Written in the `(L, M)` coordinates of Conjecture I
  (`p = L² + 4M²`, so `L² − p = −4M²`) this is `64M²(3L² − 4M²)²/(4M²)`-shaped, i.e. it is
  *not* of the form `|D|M²(L² − p)²`; numerically at `p = 5` the two sides are `16` and
  `64`.  The uniform object across discriminants is therefore the factorization
  `B(3A − B)²`, not the displayed monomial.
* **Critique (Critic).**  No `decide`, no `native_decide`, no table: the descent is proved
  for all primes at once, and the refutation is one explicit prime with both sides
  evaluated by `norm_num`.  The hypothesis `p ≠ 2` in `prime_sq_add_four_sq_iff` is
  necessary (`2 = 1 + 4·?` has no solution, yet `2 % 4 = 2`), and it is carried explicitly.
* **Synthesis (PI).**  Thue descent is discriminant-agnostic; the CM *trace* identity is
  not.  Cycle 5 should therefore look for the uniform statement at the level of the norm
  form `B(3A − B)²` rather than at the level of the `(L, M)` parametrization.
-/

namespace Novelty.MirrorBridge

open Finset

/-- **A square root of `−1` modulo a prime `p ≡ 1 (mod 4)`.** -/
theorem isSquare_neg_one_of_one_mod_four (p : ℕ) [Fact p.Prime] (hp : p % 4 = 1) :
    ∃ u : ZMod p, u * u = -1 := by
  have h : IsSquare (-1 : ZMod p) := by
    rw [ZMod.exists_sq_eq_neg_one_iff]; omega
  obtain ⟨u, hu⟩ := h
  exact ⟨u, hu.symm⟩

/-- **Thue descent at the Gaussian discriminant.**  Every prime `p ≡ 1 (mod 4)` is a sum of
two squares.  The proof reuses cycle 2's `thue_lemma` unchanged; only the descent step
(`k ≤ 2`, with `k = 2` repaired by halving) is new. -/
theorem prime_eq_sq_add_sq_of_one_mod_four (p : ℕ) (hp : p.Prime) (hp4 : p % 4 = 1) :
    ∃ a b : ℤ, (p : ℤ) = a ^ 2 + b ^ 2 := by
  haveI : Fact p.Prime := ⟨hp⟩
  have hp2 : p ≠ 2 := by intro h; rw [h] at hp4; norm_num at hp4
  have hpodd : p % 2 = 1 := Nat.odd_iff.mp (hp.odd_of_ne_two hp2)
  have hp1lt : 1 < p := hp.one_lt
  have hpZ : (0 : ℤ) < (p : ℤ) := by exact_mod_cast hp.pos
  have hp1Z : (1 : ℤ) < (p : ℤ) := by exact_mod_cast hp1lt
  have hpZodd : (p : ℤ) % 2 = 1 := by
    have hcast : ((p % 2 : ℕ) : ℤ) = (p : ℤ) % 2 := by simp
    rw [← hcast, hpodd]; norm_num
  have hpi : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  obtain ⟨u, hu⟩ := isSquare_neg_one_of_one_mod_four p hp4
  obtain ⟨a, ha⟩ : ∃ a : ℤ, ((a : ℤ) : ZMod p) = u := ⟨(u.val : ℤ), by simp⟩
  obtain ⟨x, y, hxy0, hx2, hy2, hdvd⟩ := thue_lemma p hp1lt a
  have hkey : (p : ℤ) ∣ x ^ 2 + y ^ 2 := by
    have hxz : ((x : ℤ) : ZMod p) = u * ((y : ℤ) : ZMod p) := by
      have h := (ZMod.intCast_zmod_eq_zero_iff_dvd (x - a * y) p).mpr hdvd
      push_cast at h
      rw [← ha]
      linear_combination h
    have hzero : (((x ^ 2 + y ^ 2 : ℤ)) : ZMod p) = 0 := by
      push_cast
      rw [hxz]
      linear_combination ((y : ℤ) : ZMod p) ^ 2 * hu
    exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ _).mp hzero
  -- `y ≠ 0`: otherwise `p ∣ x` with `0 < x² ≤ p`, forcing `p² ≤ p`
  have hyne : y ≠ 0 := by
    intro hy
    subst hy
    have hxne : x ≠ 0 := by
      rcases hxy0 with h | h
      · exact h
      · exact absurd rfl h
    have hpx : (p : ℤ) ∣ x ^ 2 := by simpa using hkey
    have hdx : (p : ℤ) ∣ x := hpi.dvd_of_dvd_pow hpx
    obtain ⟨t, rfl⟩ := hdx
    have htne : t ≠ 0 := by
      intro h; rw [h, mul_zero] at hxne; exact hxne rfl
    have ht1 : 1 ≤ t ^ 2 := by
      rcases lt_trichotomy t 0 with h | h | h
      · nlinarith
      · exact absurd h htne
      · nlinarith
    have hbound : ((p : ℤ) * t) ^ 2 ≤ (p : ℤ) := by simpa using hx2
    nlinarith [hbound, ht1, hp1Z, hpZ, sq_nonneg ((p : ℤ)), mul_pos hpZ hpZ]
  have hy1 : 1 ≤ y ^ 2 := by
    rcases lt_trichotomy y 0 with h | h | h
    · nlinarith
    · exact absurd h hyne
    · nlinarith
  have hpos : 0 < x ^ 2 + y ^ 2 := by nlinarith [sq_nonneg x]
  obtain ⟨k, hk⟩ := hkey
  have hkpos : 0 < k := by nlinarith
  have hkle : k ≤ 2 := by nlinarith
  interval_cases k
  · exact ⟨x, y, by linarith⟩
  · -- `k = 2`: `x` and `y` have the same parity, and halving produces a genuine solution
    rcases Int.even_or_odd x with ⟨s, hs⟩ | ⟨s, hs⟩ <;>
      rcases Int.even_or_odd y with ⟨t, ht⟩ | ⟨t, ht⟩ <;> subst hs <;> subst ht
    · -- both even: `p = 2(s² + t²)` contradicts `p` odd
      exfalso
      have : (p : ℤ) = 2 * (s ^ 2 + t ^ 2) := by linarith
      omega
    · -- mixed parity: `x² + y²` is odd, but it equals `2p`
      exfalso
      have h2 : 2 * (p : ℤ) = (s + s) ^ 2 + (2 * t + 1) ^ 2 := by linarith
      have h3 : 2 * (p : ℤ) = 2 * (2 * s ^ 2 + 2 * t ^ 2 + 2 * t) + 1 := by linarith
      omega
    · exfalso
      have h3 : 2 * (p : ℤ) = 2 * (2 * s ^ 2 + 2 * s + 2 * t ^ 2) + 1 := by linarith
      omega
    · -- both odd: `p = (s+t+1)² + (s−t)²`
      exact ⟨s + t + 1, s - t, by linarith⟩

/-- **N3, existence half.**  Every prime `p ≡ 1 (mod 4)` has a Gaussian CM representation
`p = L² + 4M²`: in `p = a² + b²` exactly one of `a, b` is even, and halving it gives `M`. -/
theorem prime_eq_sq_add_four_sq (p : ℕ) (hp : p.Prime) (hp4 : p % 4 = 1) :
    ∃ L M : ℤ, (p : ℤ) = L ^ 2 + 4 * M ^ 2 := by
  obtain ⟨a, b, hab⟩ := prime_eq_sq_add_sq_of_one_mod_four p hp hp4
  have hp2 : p ≠ 2 := by intro h; rw [h] at hp4; norm_num at hp4
  have hpodd : p % 2 = 1 := Nat.odd_iff.mp (hp.odd_of_ne_two hp2)
  have hpZodd : (p : ℤ) % 2 = 1 := by
    have hcast : ((p % 2 : ℕ) : ℤ) = (p : ℤ) % 2 := by simp
    rw [← hcast, hpodd]; norm_num
  rcases Int.even_or_odd a with ⟨s, hs⟩ | ⟨s, hs⟩ <;>
    rcases Int.even_or_odd b with ⟨t, ht⟩ | ⟨t, ht⟩ <;> subst hs <;> subst ht
  · exfalso
    have : (p : ℤ) = 2 * (2 * s ^ 2 + 2 * t ^ 2) := by linarith
    omega
  · exact ⟨2 * t + 1, s, by linarith⟩
  · exact ⟨2 * s + 1, t, by linarith⟩
  · exfalso
    have : (p : ℤ) = 2 * (2 * s ^ 2 + 2 * s + 2 * t ^ 2 + 2 * t + 1) := by linarith
    omega

/-- **N3, full equivalence.**  For an odd prime `p`, a Gaussian CM representation
`p = L² + 4M²` exists **iff** `p ≡ 1 (mod 4)`.  The forward direction is the mod-`4`
obstruction: `L² + 4M² ≡ L² (mod 4)` and `L` must be odd. -/
theorem prime_sq_add_four_sq_iff (p : ℕ) (hp : p.Prime) (hp2 : p ≠ 2) :
    (∃ L M : ℤ, (p : ℤ) = L ^ 2 + 4 * M ^ 2) ↔ p % 4 = 1 := by
  have hpodd : p % 2 = 1 := Nat.odd_iff.mp (hp.odd_of_ne_two hp2)
  have hpZodd : (p : ℤ) % 2 = 1 := by
    have hcast : ((p % 2 : ℕ) : ℤ) = (p : ℤ) % 2 := by simp
    rw [← hcast, hpodd]; norm_num
  constructor
  · rintro ⟨L, M, hLM⟩
    have hpZ4 : (p : ℤ) % 4 = 1 := by
      rcases Int.even_or_odd L with ⟨s, hs⟩ | ⟨s, hs⟩ <;> subst hs
      · exfalso
        have : (p : ℤ) = 2 * (2 * s ^ 2 + 2 * M ^ 2) := by linarith
        omega
      · have h1 : (p : ℤ) = 4 * (s ^ 2 + s + M ^ 2) + 1 := by linarith
        omega
    have hcast : ((p % 4 : ℕ) : ℤ) = (p : ℤ) % 4 := by simp
    have : ((p % 4 : ℕ) : ℤ) = (1 : ℤ) := by rw [hcast, hpZ4]
    exact_mod_cast this
  · intro h
    exact prime_eq_sq_add_four_sq p hp h

/-- **The Gaussian weight-four CM identity.**  For `π = a + bi` with norm `p = a² + b²`, the
weight-four CM trace is `a_p = π³ + π̄³ = 2a(a² − 3b²)`, and

`4p³ − a_p² = 4b²(3a² − b²)²`.

This is the `D = −4` analogue of cycle 2's `4p³ − a_p² = 27M²(L² − p)²`; note the different
shape.  It rests on the factorization `(A+B)³ − A(A−3B)² = B(3A − B)²` with `A = a²`,
`B = b²`. -/
theorem gaussian_cm_weil_identity (a b : ℤ) :
    4 * (a ^ 2 + b ^ 2) ^ 3 - (2 * a * (a ^ 2 - 3 * b ^ 2)) ^ 2
      = 4 * b ^ 2 * (3 * a ^ 2 - b ^ 2) ^ 2 := by
  ring

/-- **Ramanujan/Deligne bound at `D = −4`.**  The Gaussian CM trace satisfies
`a_p² ≤ 4p³`, with equality only when `b(3a² − b²) = 0`. -/
theorem gaussian_cm_ramanujan_bound (a b : ℤ) :
    (2 * a * (a ^ 2 - 3 * b ^ 2)) ^ 2 ≤ 4 * (a ^ 2 + b ^ 2) ^ 3 := by
  nlinarith [gaussian_cm_weil_identity a b, sq_nonneg (b * (3 * a ^ 2 - b ^ 2))]

/-- **Ordinarity.**  For a prime `p ≡ 1 (mod 4)` written as `p = a² + b²`, the Gaussian CM
trace `a_p = 2a(a² − 3b²)` is never zero: the family has no supersingular split primes.
(Both vanishing cases would force `p` to be a perfect square.) -/
theorem gaussian_cm_trace_ne_zero (p : ℕ) (hp : p.Prime) (a b : ℤ)
    (hab : (p : ℤ) = a ^ 2 + b ^ 2) :
    2 * a * (a ^ 2 - 3 * b ^ 2) ≠ 0 := by
  intro h0
  have hfac : a = 0 ∨ a ^ 2 - 3 * b ^ 2 = 0 := by
    rcases mul_eq_zero.mp h0 with h | h
    · rcases mul_eq_zero.mp h with h' | h'
      · exact absurd h' (by norm_num)
      · exact Or.inl h'
    · exact Or.inr h
  rcases hfac with rfl | h
  · exact prime_ne_sq p hp b (by linarith)
  · exact prime_ne_sq p hp (2 * b) (by nlinarith)

/-- **Conjecture I's displayed trace shape is refuted at `D = −4`.**

Take `p = 5 = 1² + 2²`, so `L = 1`, `M = 1` in `p = L² + 4M²`, and `a_p = 2·1·(1 − 12) = −22`.
Then `4p³ − a_p² = 500 − 484 = 16`, whereas the displayed shape `|D| M² (L² − p)²` gives
`4 · 1 · (1 − 5)² = 64`.  The correct value is the one produced by
`gaussian_cm_weil_identity`, namely `4b²(3a² − b²)² = 4·4·(3 − 4)² = 16`. -/
theorem conjecture_I_shape_refuted :
    (5 : ℤ) = 1 ^ 2 + 2 ^ 2 ∧ (5 : ℤ) = 1 ^ 2 + 4 * 1 ^ 2 ∧
      4 * (5 : ℤ) ^ 3 - (2 * 1 * (1 ^ 2 - 3 * 2 ^ 2)) ^ 2 = 16 ∧
      (4 : ℤ) * 1 ^ 2 * ((1 : ℤ) ^ 2 - 5) ^ 2 = 64 ∧ (16 : ℤ) ≠ 64 := by
  refine ⟨by norm_num, by norm_num, ?_, by norm_num, by norm_num⟩
  norm_num

/-! ### The uniform CM trace identity

The two discriminant-specific identities — cycle 2's `4p³ − a_p² = 27M²(L² − p)²` at
`D = −3` and the Gaussian `4p³ − a_p² = 4b²(3a² − b²)²` at `D = −4` — are two shadows of a
*single* identity in the symmetric functions of the CM generator.  Writing `π`, `π̄` for the
two conjugate generators, `s = π + π̄` and `n = ππ̄ = p`, the weight-four trace is the power
sum `a_p = π³ + π̄³ = s³ − 3ns`, and `4p³ − a_p² = −(π³ − π̄³)²` factors through the
discriminant `s² − 4n`.  This is the uniform statement Conjecture I was reaching for. -/

/-- **The uniform weight-four CM trace identity.**  For any `s` (trace of the CM generator)
and `n` (its norm, `= p`),

`4n³ − (s³ − 3ns)² = −(s² − 4n)(s² − n)²`,

because `4n³ − (π³ + π̄³)² = −(π³ − π̄³)² = −(π − π̄)²(π² + ππ̄ + π̄²)²`.  The
discriminant `s² − 4n` is the only discriminant-dependent factor. -/
theorem cm_trace_identity_symmetric (s n : ℤ) :
    4 * n ^ 3 - (s ^ 3 - 3 * n * s) ^ 2 = -(s ^ 2 - 4 * n) * (s ^ 2 - n) ^ 2 := by
  ring

/-- **Specialization to `D = −3`.**  With `4p = L² + 27M²` the discriminant factor is
`L² − 4p = −27M²`, and the uniform identity becomes cycle 2's Eisenstein identity
`4p³ − a_p² = 27M²(L² − p)²` for `a_p = 3pL − L³`. -/
theorem cm_trace_identity_eisenstein (p L M : ℤ) (hLM : 4 * p = L ^ 2 + 27 * M ^ 2) :
    4 * p ^ 3 - (3 * p * L - L ^ 3) ^ 2 = 27 * M ^ 2 * (L ^ 2 - p) ^ 2 := by
  have h := cm_trace_identity_symmetric L p
  have hdisc : L ^ 2 - 4 * p = -(27 * M ^ 2) := by linarith
  rw [hdisc] at h
  linear_combination h

/-- **Specialization to `D = −4`.**  With `p = a² + b²` the CM generator has trace `s = 2a`
and norm `n = p`, so the discriminant factor is `4a² − 4p = −4b²` and the uniform identity
becomes `gaussian_cm_weil_identity`. -/
theorem cm_trace_identity_gaussian (a b : ℤ) :
    4 * (a ^ 2 + b ^ 2) ^ 3 - ((2 * a) ^ 3 - 3 * (a ^ 2 + b ^ 2) * (2 * a)) ^ 2
      = 4 * b ^ 2 * (3 * a ^ 2 - b ^ 2) ^ 2 := by
  have h := cm_trace_identity_symmetric (2 * a) (a ^ 2 + b ^ 2)
  linear_combination h

end Novelty.MirrorBridge