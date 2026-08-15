import Novelty.MordellApparitionDensity

/-!
# The spectrum of denominator primes of a Mordell orbit

Cycle 9 of the "only bad primes" thread.  Cycle 6
(`Novelty.MordellApparitionEffective`) proved that every prime `ℓ ≥ 5` of good reduction
divides the denominator of `x(nP)` for some `n ≤ 4ℓ`; cycle 7–8
(`Novelty.MordellApparitionDensity`) turned this into a density statement and a simultaneous
apparition law for a finite set of good primes.  This file assembles those into the two
global statements the thread was aiming at.

## Main results

* `good_primes_infinite` : for `N ≠ 0` the set of primes `ℓ ≥ 5` with `ℓ ∤ N` is infinite.
* `appearing_good_primes_infinite` : *infinitely many primes of good reduction* occur in the
  denominators of a single orbit.
* `only_bad_primes_conjecture_false` : the "only bad primes" conjecture is false for **every**
  Mordell curve `E_N` (`N ≠ 0`) and **every** rational point of infinite order — not merely
  for the numerical counterexample `N = 55`, `P = (9,28)`.
* `card_joint_violations_eq` / `card_joint_violations_ge` : the indices `n ≤ K` at which a whole
  finite set `S` of good primes divides the denominator simultaneously number exactly `⌊K/M⌋`,
  with `M ≤ ∏_{ℓ ∈ S} 4ℓ`; so simultaneous violations also have positive density.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer, cycle 9): the refutation is not curve-specific.  For *every* `N ≠ 0`
  and every point of infinite order, infinitely many good primes appear in the denominators,
  and finite sets of them appear simultaneously along an arithmetic progression.
Experiment (Experimenter): the numerical table in `ComputationalEvidence.md` for `E_55`,
  `P = (9,28)` lists first apparition indices for all primes `ℓ < 120`; every good prime occurs,
  with index far below the proved bound `4ℓ` (e.g. `ℓ = 7` at `n = 2`, `ℓ = 13` at `n = 3`,
  `ℓ = 103` at `n = 12`).  No good prime was found to be absent, in agreement with the theorem.
Analysis (Analyst): the passage from "every good prime appears" to "infinitely many appear" is
  purely the cofiniteness of the good primes inside all primes, which needs `N ≠ 0`; the
  passage to the universal refutation needs, in addition, only the nonemptiness of that set.
  The simultaneous count is the apparition law for `∏ S` fed into the same divisor count as in
  cycle 7 — no new arithmetic.
Critique (Critic): the universal statement is stated as the negation of the conjecture in the
  exact form "every prime dividing a denominator lies in `{2,3} ∪ {p ∣ N}`", so it cannot be
  satisfied vacuously: the witness produced is an explicit prime `ℓ ≥ 5` with `ℓ ∤ N` together
  with an index `n > 0` and an affine `x`-coordinate whose denominator `ℓ` divides.  The
  hypothesis `N ≠ 0` is necessary (for `N = 0` the "curve" is singular and every prime divides
  `N`), and the infinite-order hypothesis is necessary (a torsion point has a finite orbit, so
  only finitely many primes can occur).
-/

namespace MordellDenominators

open WeierstrassCurve WeierstrassCurve.Affine

/-! ## Cofiniteness of the good primes -/

/-- **The good primes are infinite.**  For `N ≠ 0` only finitely many primes are "bad"
(`2`, `3`, or a divisor of `N`), so infinitely many primes `ℓ ≥ 5` satisfy `ℓ ∤ N`. -/
theorem good_primes_infinite {N : ℤ} (hN : N ≠ 0) :
    {ℓ : ℕ | ℓ.Prime ∧ 5 ≤ ℓ ∧ ¬(ℓ : ℤ) ∣ N}.Infinite := by
  have hfin : (({2, 3} : Set ℕ) ∪ (N.natAbs.primeFactors : Set ℕ)).Finite :=
    ((Set.finite_singleton 3).insert 2).union (N.natAbs.primeFactors.finite_toSet)
  have hinf : ({ℓ : ℕ | ℓ.Prime} \ (({2, 3} : Set ℕ) ∪ (N.natAbs.primeFactors : Set ℕ))).Infinite :=
    Nat.infinite_setOf_prime.diff hfin
  refine hinf.mono ?_
  rintro ℓ ⟨hl, hbad⟩
  simp only [Set.mem_union, Set.mem_insert_iff, Set.mem_singleton_iff, Finset.mem_coe,
    Nat.mem_primeFactors, not_or, not_and] at hbad
  obtain ⟨⟨h2, h3⟩, hpf⟩ := hbad
  have hl5 : 5 ≤ ℓ := by
    have h2le := hl.two_le
    rcases Nat.lt_or_ge ℓ 5 with hlt | hge
    · interval_cases ℓ
      · exact absurd rfl h2
      · exact absurd rfl h3
      · exact absurd hl (by norm_num)
    · exact hge
  refine Set.mem_setOf_eq ▸ ⟨hl, hl5, fun hdvd => ?_⟩
  exact hpf hl (by simpa using Int.natAbs_dvd_natAbs.mpr hdvd) (Int.natAbs_ne_zero.mpr hN)

/-! ## Infinitely many good primes appear -/

/-- **Infinitely many primes of good reduction occur in a single orbit.**  For `N ≠ 0` and a
rational point `P` of infinite order on `E_N : y² = x³ + N`, the set of primes `ℓ ≥ 5` with
`ℓ ∤ N` that divide the denominator of some `x(nP)` is infinite. -/
theorem appearing_good_primes_infinite {N : ℤ} (hN : N ≠ 0)
    {P : (mordell ((N : ℤ) : ℚ)).toAffine.Point} (hP : ∀ n : ℕ, 0 < n → n • P ≠ 0) :
    {ℓ : ℕ | ℓ.Prime ∧ 5 ≤ ℓ ∧ ¬(ℓ : ℤ) ∣ N ∧
      ∃ n : ℕ, 0 < n ∧ ∃ X : ℚ, xCoord (n • P) = some X ∧ ℓ ∣ X.den}.Infinite := by
  refine (good_primes_infinite hN).mono ?_
  rintro ℓ ⟨hl, hl5, hlN⟩
  obtain ⟨n, hn0, -, X, hX, hdvd⟩ := exists_small_multiple_dvd_den hl hl5 hlN hP
  exact ⟨hl, hl5, hlN, n, hn0, X, hX, hdvd⟩

/-- **The "only bad primes" conjecture fails for every Mordell curve and every point of
infinite order.**  The conjecture asserts that every prime dividing the denominator of some
`x(nP)` lies in `{2, 3} ∪ {p : p ∣ N}` (the primes dividing the discriminant `-432N²`).  This
is false for all `N ≠ 0`: there is always a prime `ℓ ≥ 5` of good reduction, an index `n > 0`
and an affine point `nP` whose `x`-coordinate has `ℓ` in its denominator. -/
theorem only_bad_primes_conjecture_false {N : ℤ} (hN : N ≠ 0)
    {P : (mordell ((N : ℤ) : ℚ)).toAffine.Point} (hP : ∀ n : ℕ, 0 < n → n • P ≠ 0) :
    ¬ (∀ ℓ n : ℕ, ℓ.Prime → 0 < n → ∀ X : ℚ, xCoord (n • P) = some X → ℓ ∣ X.den →
        ℓ = 2 ∨ ℓ = 3 ∨ (ℓ : ℤ) ∣ N) := by
  intro hconj
  obtain ⟨ℓ, hl, hl5, hlN, n, hn0, X, hX, hdvd⟩ :=
    (appearing_good_primes_infinite hN hP).nonempty
  rcases hconj ℓ n hl hn0 X hX hdvd with h | h | h
  · omega
  · omega
  · exact hlN h

/-- **The orbit denominators are unbounded, by good primes alone.**  For any bound `B` some
multiple `nP` has an `x`-coordinate whose denominator exceeds `B` *and* is divisible by a prime
`ℓ > B` of good reduction: the growth of the denominators is not accounted for by the primes
dividing the discriminant. -/
theorem denominator_unbounded_by_good_primes {N : ℤ} (hN : N ≠ 0)
    {P : (mordell ((N : ℤ) : ℚ)).toAffine.Point} (hP : ∀ n : ℕ, 0 < n → n • P ≠ 0) (B : ℕ) :
    ∃ ℓ n : ℕ, ℓ.Prime ∧ B < ℓ ∧ ¬(ℓ : ℤ) ∣ N ∧ 0 < n ∧
      ∃ X : ℚ, xCoord (n • P) = some X ∧ ℓ ∣ X.den ∧ B < X.den := by
  obtain ⟨ℓ, ⟨hl, -, hlN, n, hn0, X, hX, hdvd⟩, hBl⟩ :=
    (appearing_good_primes_infinite hN hP).exists_gt B
  exact ⟨ℓ, n, hl, hBl, hlN, hn0, X, hX, hdvd,
    lt_of_lt_of_le hBl (Nat.le_of_dvd X.pos hdvd)⟩

/-! ## Density of the simultaneous violations -/

open scoped Classical in
/-- **Exact count of the simultaneous violations.**  For a finite set `S` of good primes `≥ 5`
there is a modulus `M ≤ ∏_{ℓ ∈ S} 4ℓ` such that exactly `⌊K/M⌋` of the first `K` multiples of
`P` have all of `S` in the denominator of their `x`-coordinate at once. -/
theorem card_joint_violations_eq {N : ℤ} (P : (mordell ((N : ℤ) : ℚ)).toAffine.Point)
    {S : Finset ℕ} (hS : ∀ ℓ ∈ S, ℓ.Prime ∧ 5 ≤ ℓ ∧ ¬(ℓ : ℤ) ∣ N) :
    ∃ M : ℕ, 0 < M ∧ M ≤ ∏ ℓ ∈ S, 4 * ℓ ∧ ∀ K : ℕ,
      ((Finset.Ioc 0 K).filter
        (fun n : ℕ => ∀ Y : ℚ, xCoord (n • P) = some Y → (∏ ℓ ∈ S, ℓ) ∣ Y.den)).card
        = K / M := by
  obtain ⟨M, hM0, hMle, hM⟩ := joint_apparition_finset P hS
  refine ⟨M, hM0, hMle, fun K => ?_⟩
  have hfil : ((Finset.Ioc 0 K).filter
      (fun n : ℕ => ∀ Y : ℚ, xCoord (n • P) = some Y → (∏ ℓ ∈ S, ℓ) ∣ Y.den))
      = (Finset.Ioc 0 K).filter (fun n : ℕ => M ∣ n) := by
    refine Finset.filter_congr ?_
    intro n _
    constructor
    · intro h
      have h' : (M : ℤ) ∣ (n : ℤ) := by
        refine (hM (n : ℤ)).1 ?_
        intro Y hY
        rw [natCast_zsmul] at hY
        exact h Y hY
      exact_mod_cast h'
    · intro h Y hY
      have h' : (M : ℤ) ∣ (n : ℤ) := by exact_mod_cast h
      exact (hM (n : ℤ)).2 h' Y (by rwa [natCast_zsmul])
  rw [hfil, Nat.Ioc_filter_dvd_card_eq_div]

open scoped Classical in
/-- **Positive density of simultaneous violations.**  At least `⌊K / ∏_{ℓ ∈ S} 4ℓ⌋` of the first
`K` multiples of `P` violate the "only bad primes" conjecture at *all* the primes of `S`
simultaneously. -/
theorem card_joint_violations_ge {N : ℤ} (P : (mordell ((N : ℤ) : ℚ)).toAffine.Point)
    {S : Finset ℕ} (hS : ∀ ℓ ∈ S, ℓ.Prime ∧ 5 ≤ ℓ ∧ ¬(ℓ : ℤ) ∣ N) (K : ℕ) :
    K / (∏ ℓ ∈ S, 4 * ℓ) ≤ ((Finset.Ioc 0 K).filter
      (fun n : ℕ => ∀ Y : ℚ, xCoord (n • P) = some Y → (∏ ℓ ∈ S, ℓ) ∣ Y.den)).card := by
  obtain ⟨M, hM0, hMle, hcount⟩ := card_joint_violations_eq P hS
  rw [hcount K]
  exact Nat.div_le_div_left hMle hM0

end MordellDenominators