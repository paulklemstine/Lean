import Mathlib
import Novelty.RigidCY3Modularity

/-!
# Arithmetic Mirror Symmetry IX — split primes are represented by `L² + 27M²`

This file closes the open half of **Conjecture D** of the previous cycle's
`FUTURE_DIRECTIONS.md`.

Cycle 1 proved the CM package for a rigid Calabi–Yau threefold with weight-four newform of
CM type: the trace identity `4p³ − a_p² = 27M²(L² − p)²`, the Ramanujan bound it implies,
and the *non*-representability `4p ≠ L² + 27M²` at inert primes `p ≡ 2 (mod 3)`
(`Novelty.MirrorBridge.no_cm_representation_of_inert`).  What remained open was the
converse — the *existence* of the CM parameters at split primes:

> for every prime `p ≡ 1 (mod 3)` the equation `4p = L² + 27M²` has an integral solution.

That is proved here from scratch, with no appeal to class field theory: the required
Eisenstein-integer arithmetic is replaced by a cube-root-of-unity computation in `ZMod p`,
Thue's pigeonhole lemma, and an explicit descent.

## Main results

* `isSquare_neg_three_of_one_mod_three` — if `p ≡ 1 (mod 3)` then `−3` is a square in
  `ZMod p`; the square root is `2ω + 1` for a primitive cube root of unity `ω`, obtained
  from Cauchy's theorem in `(ZMod p)ˣ`.
* `thue_lemma` — **Thue's lemma**: for `n > 1` and any `a`, the congruence `x ≡ a y (mod n)`
  has a solution with `(x, y) ≠ (0, 0)` and `x², y² ≤ n`.  Pure pigeonhole.
* `prime_eq_sq_add_three_sq` — the descent: every prime `p ≡ 1 (mod 3)` is of the form
  `a² + 3b²`.  The auxiliary multiplier `k ∈ {1,2,3,4}` is eliminated by a parity argument
  (`k = 2`, `k = 4`) and by a divisibility argument (`k = 3`).
* `four_mul_prime_eq_sq_add_27_sq` — **Conjecture D, existence half**: every prime
  `p ≡ 1 (mod 3)` satisfies `4p = L² + 27M²` for some integers `L, M`.  The rotation
  `(a, b) ↦ (a ± 3b, a ∓ b)` moves the representation onto the sublattice `3 ∣ M`.
* `cm_representation_iff` — combining with the cycle-1 inert obstruction: for a prime
  `p ≠ 3`, `4p = L² + 27M²` is solvable **iff** `p ≡ 1 (mod 3)`.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  The CM parameters `(L, M)` of the weight-four newform
  should exist at exactly the split primes, and the obstruction proved in cycle 1 at inert
  primes should be the only one — i.e. the representability is a clean congruence condition.
* **Experiment (Experimenter).**  Mathlib has no Eisenstein integers and no `x² + 3y²`
  theory, so the classical `ℤ[ω]`-factorization argument was unavailable.  Replaced it by:
  (i) a primitive cube root `ω` in `ZMod p`, whence `(2ω+1)² = 4(ω²+ω) + 1 = −3`;
  (ii) Thue's pigeonhole lemma on `(m+1)² > p` pairs, `m = ⌊√p⌋`;
  (iii) descent on `x² + 3y² = k p`, `1 ≤ k ≤ 4`.  Cases `k = 2, 4` die on parity, `k = 3`
  descends to `y² + 3(x/3)² = p`.
* **Analysis (Analyst).**  The step that is *not* automatic is the last one: `p = a² + 3b²`
  gives `4p = (2a)² + 3(2b)²`, which is the form `L² + 27M²` only when `3 ∣ b`.  The three
  associates of the Eisenstein prime — visible here as the rotations
  `(a, b) ↦ (a + 3b, a − b)` and `(a, b) ↦ (a − 3b, a + b)` — supply `b`, `a − b`, `a + b` as
  candidate values of `3M`, and since `3 ∤ a` (forced by `p ≡ 1 mod 3`) at least one of them
  is divisible by `3`.  This is exactly where the class number one of `ℚ(√−3)` enters, in
  the disguise of a three-case arithmetic split.
* **Critique (Critic).**  No `decide`, no `native_decide`, no numerical table: the theorem is
  proved for all primes at once.  Thue's lemma is stated and proved separately so it can be
  reused.  The hypothesis `p ≡ 1 (mod 3)` is load-bearing in both directions, as
  `cm_representation_iff` records.
* **Synthesis (PI).**  Conjecture D is now an equivalence rather than a one-sided
  obstruction: the CM parameters of the rigid Calabi–Yau threefold exist exactly at the
  split primes, and the trace identity `4p³ − a_p² = 27M²(L² − p)²` of cycle 1 therefore has
  content at every good prime with `p ≡ 1 (mod 3)`.
-/

namespace Novelty.MirrorBridge

/-- **`−3` is a square modulo a prime `p ≡ 1 (mod 3)`.**  A primitive cube root of unity
`ω ∈ (ZMod p)ˣ` exists by Cauchy's theorem, satisfies `ω² + ω + 1 = 0`, and then
`(2ω + 1)² = 4(ω² + ω) + 1 = −3`. -/
theorem isSquare_neg_three_of_one_mod_three (p : ℕ) [Fact p.Prime] (hp : p % 3 = 1) :
    ∃ u : ZMod p, u ^ 2 = -3 := by
  have h3 : (3 : ℕ) ∣ Fintype.card (ZMod p)ˣ := by
    rw [ZMod.card_units_eq_totient, Nat.totient_prime Fact.out]
    omega
  obtain ⟨w, hw⟩ := exists_prime_orderOf_dvd_card (G := (ZMod p)ˣ) 3 h3
  refine ⟨2 * (w : ZMod p) + 1, ?_⟩
  have hw3 : (w : ZMod p) ^ 3 = 1 := by
    have h : w ^ 3 = 1 := by rw [← hw]; exact pow_orderOf_eq_one w
    simpa using congrArg (Units.val) h
  have hwne : (w : ZMod p) ≠ 1 := by
    intro h
    have hw1 : w = 1 := Units.ext h
    rw [hw1] at hw
    simp at hw
  have hfac : ((w : ZMod p) - 1) * ((w : ZMod p) ^ 2 + (w : ZMod p) + 1) = 0 := by
    linear_combination hw3
  have h2 : (w : ZMod p) ^ 2 + (w : ZMod p) + 1 = 0 := by
    rcases mul_eq_zero.mp hfac with h | h
    · exact absurd (sub_eq_zero.mp h) hwne
    · exact h
  linear_combination 4 * h2

/-- **Thue's lemma.**  For `n > 1` and any `a`, the congruence `x ≡ a y (mod n)` admits a
solution with `(x, y) ≠ (0, 0)` and `x² ≤ n`, `y² ≤ n`.  Pure pigeonhole: the `(⌊√n⌋+1)²`
pairs `(u, v)` with `0 ≤ u, v ≤ ⌊√n⌋` outnumber the `n` residues, so two of them have the
same value of `u − a v`. -/
theorem thue_lemma (n : ℕ) (hn : 1 < n) (a : ℤ) :
    ∃ x y : ℤ, (x ≠ 0 ∨ y ≠ 0) ∧ x ^ 2 ≤ (n : ℤ) ∧ y ^ 2 ≤ (n : ℤ) ∧
      (n : ℤ) ∣ (x - a * y) := by
  haveI : NeZero n := ⟨by omega⟩
  set m := Nat.sqrt n with hm
  set S : Finset (ℕ × ℕ) := Finset.range (m + 1) ×ˢ Finset.range (m + 1) with hS
  have hcard : (Finset.univ : Finset (ZMod n)).card < S.card := by
    rw [Finset.card_univ, ZMod.card, hS, Finset.card_product, hm]
    simpa using Nat.lt_succ_sqrt n
  have hmn : (m : ℤ) ^ 2 ≤ (n : ℤ) := by
    have h0 : m * m ≤ n := Nat.sqrt_le n
    have h1 : ((m * m : ℕ) : ℤ) ≤ (n : ℤ) := by exact_mod_cast h0
    push_cast at h1
    nlinarith
  obtain ⟨P, hP, Q, hQ, hPQ, hfeq⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to hcard
      (f := fun z : ℕ × ℕ => ((z.1 : ℤ) : ZMod n) - (a : ZMod n) * ((z.2 : ℤ) : ZMod n))
      (fun z _ => Finset.mem_univ _)
  have hp1 : P.1 ≤ m := by
    have := (Finset.mem_product.mp hP).1; simp [Finset.mem_range] at this; omega
  have hq1 : Q.1 ≤ m := by
    have := (Finset.mem_product.mp hQ).1; simp [Finset.mem_range] at this; omega
  have hp2 : P.2 ≤ m := by
    have := (Finset.mem_product.mp hP).2; simp [Finset.mem_range] at this; omega
  have hq2 : Q.2 ≤ m := by
    have := (Finset.mem_product.mp hQ).2; simp [Finset.mem_range] at this; omega
  refine ⟨(P.1 : ℤ) - (Q.1 : ℤ), (P.2 : ℤ) - (Q.2 : ℤ), ?_, ?_, ?_, ?_⟩
  · by_contra h
    push_neg at h
    obtain ⟨h1, h2⟩ := h
    exact hPQ (Prod.ext (by omega) (by omega))
  · have b1 : ((P.1 : ℤ) - (Q.1 : ℤ)) ≤ (m : ℤ) := by
      have h3 : (P.1 : ℤ) ≤ (m : ℤ) := by exact_mod_cast hp1
      have h2 : (0 : ℤ) ≤ (Q.1 : ℤ) := Int.natCast_nonneg _
      linarith
    have b2 : -(m : ℤ) ≤ ((P.1 : ℤ) - (Q.1 : ℤ)) := by
      have h3 : (Q.1 : ℤ) ≤ (m : ℤ) := by exact_mod_cast hq1
      have h2 : (0 : ℤ) ≤ (P.1 : ℤ) := Int.natCast_nonneg _
      linarith
    nlinarith
  · have b1 : ((P.2 : ℤ) - (Q.2 : ℤ)) ≤ (m : ℤ) := by
      have h3 : (P.2 : ℤ) ≤ (m : ℤ) := by exact_mod_cast hp2
      have h2 : (0 : ℤ) ≤ (Q.2 : ℤ) := Int.natCast_nonneg _
      linarith
    have b2 : -(m : ℤ) ≤ ((P.2 : ℤ) - (Q.2 : ℤ)) := by
      have h3 : (Q.2 : ℤ) ≤ (m : ℤ) := by exact_mod_cast hq2
      have h2 : (0 : ℤ) ≤ (P.2 : ℤ) := Int.natCast_nonneg _
      linarith
    nlinarith
  · have hz : ((((P.1 : ℤ) - (Q.1 : ℤ)) - a * ((P.2 : ℤ) - (Q.2 : ℤ)) : ℤ) : ZMod n) = 0 := by
      push_cast
      push_cast at hfeq
      linear_combination hfeq
    exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ _).mp hz

/-- A prime cannot be a perfect square. -/
theorem prime_ne_sq (p : ℕ) (hp : p.Prime) (x : ℤ) : x ^ 2 ≠ (p : ℤ) := by
  intro hx
  have hpx : (p : ℤ) ∣ x ^ 2 := ⟨1, by rw [hx, mul_one]⟩
  have hpi : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  have hdvd : (p : ℤ) ∣ x := hpi.dvd_of_dvd_pow hpx
  obtain ⟨t, rfl⟩ := hdvd
  have hp1 : (1 : ℤ) < (p : ℤ) := by exact_mod_cast hp.one_lt
  have hpne : (p : ℤ) ≠ 0 := by positivity
  have h1 : (p : ℤ) * ((p : ℤ) * t ^ 2) = (p : ℤ) * 1 := by linear_combination hx
  have h2 : (p : ℤ) * t ^ 2 = 1 := mul_left_cancel₀ hpne h1
  have h3 := Int.le_of_dvd one_pos ⟨t ^ 2, h2.symm⟩
  omega

/-- **Descent: every prime `p ≡ 1 (mod 3)` is of the form `a² + 3b²`.** -/
theorem prime_eq_sq_add_three_sq (p : ℕ) (hp : p.Prime) (hp3 : p % 3 = 1) :
    ∃ a b : ℤ, (p : ℤ) = a ^ 2 + 3 * b ^ 2 := by
  haveI : Fact p.Prime := ⟨hp⟩
  have hp2 : p ≠ 2 := by intro h; rw [h] at hp3; norm_num at hp3
  have hpodd : p % 2 = 1 := Nat.odd_iff.mp (hp.odd_of_ne_two hp2)
  have hp1lt : 1 < p := hp.one_lt
  have hpZ : (0 : ℤ) < (p : ℤ) := by exact_mod_cast hp.pos
  have hp1Z : (1 : ℤ) < (p : ℤ) := by exact_mod_cast hp1lt
  have hpi : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  obtain ⟨u, hu⟩ := isSquare_neg_three_of_one_mod_three p hp3
  obtain ⟨a, ha⟩ : ∃ a : ℤ, ((a : ℤ) : ZMod p) = u := ⟨(u.val : ℤ), by simp⟩
  obtain ⟨x, y, hxy0, hx2, hy2, hdvd⟩ := thue_lemma p hp1lt a
  -- the congruence forces `p ∣ x² + 3y²`
  have hkey : (p : ℤ) ∣ x ^ 2 + 3 * y ^ 2 := by
    have hxz : ((x : ℤ) : ZMod p) = u * ((y : ℤ) : ZMod p) := by
      have h := (ZMod.intCast_zmod_eq_zero_iff_dvd (x - a * y) p).mpr hdvd
      push_cast at h
      rw [← ha]
      linear_combination h
    have hzero : (((x ^ 2 + 3 * y ^ 2 : ℤ)) : ZMod p) = 0 := by
      push_cast
      rw [hxz]
      linear_combination ((y : ℤ) : ZMod p) ^ 2 * hu
    exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ _).mp hzero
  -- `y ≠ 0`, since otherwise `p ∣ x` while `x² ≤ p`
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
  have hpos : 0 < x ^ 2 + 3 * y ^ 2 := by nlinarith [sq_nonneg x]
  obtain ⟨k, hk⟩ := hkey
  have hkpos : 0 < k := by nlinarith
  have hkle : k ≤ 4 := by nlinarith
  interval_cases k
  · exact ⟨x, y, by linarith⟩
  · -- `k = 2` is impossible by parity
    exfalso
    have hodd : ¬ (2 : ℤ) ∣ (p : ℤ) := by
      rintro ⟨c, hc⟩
      have hpmod : (p : ℤ) % 2 = 1 := by
        have hcast : ((p % 2 : ℕ) : ℤ) = (p : ℤ) % 2 := by
          simp
        rw [← hcast, hpodd]; norm_num
      omega
    rcases Int.even_or_odd x with ⟨s, hs⟩ | ⟨s, hs⟩ <;>
      rcases Int.even_or_odd y with ⟨t, ht⟩ | ⟨t, ht⟩ <;> subst hs <;> subst ht
    · exact hodd ⟨s ^ 2 + 3 * t ^ 2, by linarith⟩
    · have hbad : (2 : ℤ) ∣ 3 := ⟨(p : ℤ) - 2 * s ^ 2 - 6 * t ^ 2 - 6 * t, by linarith⟩
      omega
    · have hbad : (2 : ℤ) ∣ 1 := ⟨(p : ℤ) - 2 * s ^ 2 - 2 * s - 6 * t ^ 2, by linarith⟩
      omega
    · exact hodd ⟨s ^ 2 + s + 3 * t ^ 2 + 3 * t + 1, by linarith⟩
  · -- `k = 3`: descend
    have h3x : (3 : ℤ) ∣ x ^ 2 := ⟨(p : ℤ) - y ^ 2, by linarith⟩
    have hdx : (3 : ℤ) ∣ x := Int.prime_three.dvd_of_dvd_pow h3x
    obtain ⟨t, rfl⟩ := hdx
    exact ⟨y, t, by linarith⟩
  · -- `k = 4` forces `x² = p`, impossible for a prime
    exfalso
    have hxp : x ^ 2 = (p : ℤ) := by linarith
    exact prime_ne_sq p hp x hxp

/-- **Conjecture D, existence half.**  Every prime `p ≡ 1 (mod 3)` admits CM parameters:
there are integers `L, M` with `4p = L² + 27M²`.  Equivalently, the Eisenstein prime above
`p` has a generator of the shape `(L + 3M√−3)/2`. -/
theorem four_mul_prime_eq_sq_add_27_sq (p : ℕ) (hp : p.Prime) (hp3 : p % 3 = 1) :
    ∃ L M : ℤ, 4 * (p : ℤ) = L ^ 2 + 27 * M ^ 2 := by
  obtain ⟨a, b, hab⟩ := prime_eq_sq_add_three_sq p hp hp3
  have hp3Z : (p : ℤ) % 3 = 1 := by
    have h : ((p % 3 : ℕ) : ℤ) = (p : ℤ) % 3 := by simp
    rw [← h, hp3]; norm_num
  -- `p ≡ 1 (mod 3)` forces `3 ∤ a`
  have hna : ¬ (3 : ℤ) ∣ a := by
    rintro ⟨c, rfl⟩
    have h3p : (3 : ℤ) ∣ (p : ℤ) := ⟨3 * c ^ 2 + b ^ 2, by linarith⟩
    omega
  have htri : (3 : ℤ) ∣ b ∨ (3 : ℤ) ∣ (a - b) ∨ (3 : ℤ) ∣ (a + b) := by
    have ha3 : a % 3 = 1 ∨ a % 3 = 2 := by omega
    have hb3 : b % 3 = 0 ∨ b % 3 = 1 ∨ b % 3 = 2 := by omega
    rcases ha3 with h1 | h1 <;> rcases hb3 with h2 | h2 | h2 <;> omega
  rcases htri with ⟨c, hc⟩ | ⟨c, hc⟩ | ⟨c, hc⟩
  · refine ⟨2 * a, 2 * c, ?_⟩
    rw [hc] at hab
    linarith
  · refine ⟨a + 3 * b, c, ?_⟩
    have hc2 : 9 * c ^ 2 = (a - b) ^ 2 := by rw [hc]; ring
    linarith
  · refine ⟨a - 3 * b, c, ?_⟩
    have hc2 : 9 * c ^ 2 = (a + b) ^ 2 := by rw [hc]; ring
    linarith

/-- **Conjecture D, full equivalence.**  For a prime `p ≠ 3` the CM representation
`4p = L² + 27M²` exists **iff** `p ≡ 1 (mod 3)`.  The forward direction is the mod-`3`
obstruction of cycle 1, the backward direction is `four_mul_prime_eq_sq_add_27_sq`. -/
theorem cm_representation_iff (p : ℕ) (hp : p.Prime) (hp3 : p ≠ 3) :
    (∃ L M : ℤ, 4 * (p : ℤ) = L ^ 2 + 27 * M ^ 2) ↔ p % 3 = 1 := by
  constructor
  · intro hrep
    have hcases : p % 3 = 0 ∨ p % 3 = 1 ∨ p % 3 = 2 := by omega
    rcases hcases with h | h | h
    · exfalso
      have hdvd : (3 : ℕ) ∣ p := Nat.dvd_of_mod_eq_zero h
      rcases Nat.Prime.eq_one_or_self_of_dvd hp 3 hdvd with h1 | h1
      · norm_num at h1
      · exact hp3 h1.symm
    · exact h
    · exact absurd hrep (no_cm_representation_of_inert p h)
  · intro h
    exact four_mul_prime_eq_sq_add_27_sq p hp h

/-- **Capstone: the CM package exists at every split prime.**  Combining the existence of
the representation with the cycle-1 identities, for every prime `p ≡ 1 (mod 3)` there are CM
parameters `(L, M)` for which the predicted trace `a_p = 3pL − L³` satisfies the exact Weil
identity `4p³ − a_p² = 27M²(L² − p)²` and hence the Ramanujan bound `a_p² ≤ 4p³`.  With the
inert case `no_cm_representation_of_inert` this settles Conjecture D at every prime `≠ 3`. -/
theorem split_prime_cm_package (p : ℕ) (hp : p.Prime) (hp3 : p % 3 = 1) :
    ∃ L M : ℤ, 4 * (p : ℤ) = L ^ 2 + 27 * M ^ 2 ∧
      4 * (p : ℤ) ^ 3 - (cmTrace (p : ℤ) L) ^ 2 = 27 * M ^ 2 * (L ^ 2 - (p : ℤ)) ^ 2 ∧
      (cmTrace (p : ℤ) L) ^ 2 ≤ 4 * (p : ℤ) ^ 3 := by
  obtain ⟨L, M, hLM⟩ := four_mul_prime_eq_sq_add_27_sq p hp hp3
  exact ⟨L, M, hLM, cm_weil_identity (p : ℤ) L M hLM, cm_ramanujan_bound (p : ℤ) L M hLM⟩

end Novelty.MirrorBridge