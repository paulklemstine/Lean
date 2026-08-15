import Mathlib
import Combinatorics.EllipticModP
import Applications.MordellInfiniteOrbit

/-!
# Counting the denominator-producing residue classes of a Mordell curve

This file bridges two strands of the catalog:

* the mod-`p` point-counting machinery of `EllipticModCount`
  (`Combinatorics.EllipticPointCount`, `Combinatorics.EllipticModP`), and
* the refutation of the "only bad primes" conjecture for denominators of multiples of
  points on Mordell curves `E_N : y² = x³ + N` (`Shared.MordellDenominatorPrimes`
  and the `Applications.Mordell*` chain).

The link is the following observation.  For an integral point `(x, y)` of `E_N` and a prime
`ℓ ≥ 5` of good reduction, `ℓ` divides the denominator of `x(2P)` **iff** `ℓ ∣ y`, iff the
reduction `x̄` of `x` is a root of the cubic `T³ + N` over `𝔽_ℓ` — that is, iff `x̄` lies in
the `2`-torsion locus `rootSet 0 N̄` counted by the point-counting file.  Denominator
production is therefore a *counting* phenomenon on the reduced curve, and the combinatorics
of the cubic `T³ + N̄` over `𝔽_ℓ` governs it completely.

## Main results

* `dvd_den_double_iff_mem_vanishingClasses` : the bridge.
  `ℓ ∣ den x(2P) ↔ x̄ ∈ vanishingClasses N ℓ`, where `vanishingClasses N ℓ = rootSet (0 : 𝔽_ℓ) N̄`.
* `card_vanishingClasses_of_two_mod_three` : if `ℓ ≡ 2 (mod 3)` there is **exactly one**
  denominator-producing class, for every `N`; a supersingular prime is always "active".
* `card_vanishingClasses_of_one_mod_three` : if `ℓ ≡ 1 (mod 3)` and `ℓ ∤ N` the number of
  classes is `0` or `3` — never `1`, never `2`.
* `sum_card_vanishingClasses` : summed over all `N mod ℓ` the count is exactly `ℓ`, so the
  *average* number of denominator-producing classes is exactly `1`, uniformly in `ℓ`.
* `exists_unique_vanishing_class` : the `∃!` form of the supersingular case, phrased directly
  in terms of denominators of `x(2P)`.
* `card_two_torsion_locus_of_two_mod_three` : the producing locus is exactly `1` point out of
  the `ℓ + 1` points of the reduced curve.
* `infinite_supersingular_active_primes` : for every `N` infinitely many primes (all
  `ℓ ≡ 2 mod 3`, a set of Dirichlet density `1/2`) are denominator-active; combined with
  `not_dvd_Δ` these are all primes of good reduction.
* `mem_good_violating_primes_iff`, `card_good_violating_primes_le` : for a *fixed* integral
  point the violating good primes are exactly the primes `≥ 5` dividing `y` and not `N`, and
  there are at most `log₅ |y|` of them.

-- !-- Lab Notes -- !--
Hypothesizer: the failure of the "only bad primes" conjecture should be *quantitative*: the
  good primes appearing in denominators should be governed by the number of `𝔽_ℓ`-roots of
  `T³ + N`, hence by the splitting behaviour of `ℓ` in `ℚ(∛N, ζ₃)`.  Prediction: exactly one
  producing class at supersingular primes `ℓ ≡ 2 (mod 3)`, `0` or `3` classes at ordinary
  primes `ℓ ≡ 1 (mod 3)`, and average exactly `1` class, i.e. density `1/ℓ`, over `N`.
Experimenter: all three predictions are proved below (`card_vanishingClasses_of_two_mod_three`,
  `card_vanishingClasses_of_one_mod_three`, `sum_card_vanishingClasses`).  The `0 ∨ 3`
  dichotomy uses Cauchy's theorem to produce a primitive cube root of unity in `𝔽_ℓ`, together
  with the catalog's `rootSet_card_cases` (no cubic has exactly two roots).
Analyst: the counting explains the survey data of the previous cycle.  For `N = 55`,
  `7 ≡ 1 (mod 3)` and `7 ∣ den x(2P)` because `9³ + 55 = 784 = 7²·16`; the three classes mod `7`
  with `T³ ≡ -55 ≡ 1` are `{1, 2, 4}`, and indeed `9 ≡ 2 (mod 7)` (`vanishingClasses_55_7`).
  For `13 ≡ 1 (mod 3)` we have `T³ ≡ -55 ≡ 10 (mod 13)` with *no* root (the cubes mod `13` are
  `{0,1,5,8,12}`), so `13` is inactive at the doubling layer (`vanishingClasses_55_13`) even
  though `13 ∣ den x(3P)` (see `Applications.MordellDenominatorOrbits`): the counting here
  governs the `2P` layer, and each higher layer has its own cubic.
Critic: `card_vanishingClasses_of_one_mod_three` genuinely needs `ℓ ∤ N` (for `N ≡ 0` the
  unique root `0` gives card `1`) and `ℓ ≠ 3`; both are hypotheses.  The bridge theorem needs
  `ℓ ≥ 5` because at `ℓ = 3` the numerator `x⁴ - 8Nx` can also vanish, and needs `y ≠ 0`
  because `x(2P)` is undefined at `2`-torsion.  The `∃!` statement is stated with the cubic
  condition included, since without it the universally quantified property is vacuous for
  curves without integral points and uniqueness would fail.  No `sorry` occurs below.
-/

namespace MordellPointCount

open Finset EllipticModCount MordellDenominators

variable {ℓ : ℕ}

/-! ## The denominator-producing residue classes -/

/-- The set of residue classes `x̄ ∈ 𝔽_ℓ` which force `ℓ` into the denominator of `x(2P)`:
the roots of `T³ + N` over `𝔽_ℓ`, i.e. the `x`-coordinates of the `2`-torsion of the reduced
Mordell curve. -/
def vanishingClasses (N : ℤ) (ℓ : ℕ) [Fact ℓ.Prime] : Finset (ZMod ℓ) :=
  EllipticModCount.rootSet (0 : ZMod ℓ) ((N : ZMod ℓ))

lemma mem_vanishingClasses_iff [Fact ℓ.Prime] {N : ℤ} {t : ZMod ℓ} :
    t ∈ vanishingClasses N ℓ ↔ t ^ 3 + (N : ZMod ℓ) = 0 := by
  simp [vanishingClasses, EllipticModCount.rootSet, EllipticModCount.wRHS]

/-- **Bridge theorem.**  For an integral point `(x, y)` of `E_N : y² = x³ + N` with `y ≠ 0`
and a prime `ℓ ≥ 5` of good reduction (`ℓ ∤ N`), the prime `ℓ` divides the denominator of
`x(2P) = (x⁴ - 8Nx)/(4y²)` if and only if the reduction of `x` lies in `vanishingClasses N ℓ`.

Denominator production at good primes is thus exactly the event "`x̄` is a `2`-torsion
`x`-coordinate of the reduced curve", a condition counted by the mod-`ℓ` machinery. -/
theorem dvd_den_double_iff_mem_vanishingClasses [Fact ℓ.Prime] {N x y : ℤ}
    (heq : y ^ 2 = x ^ 3 + N) (hy : y ≠ 0) (hl5 : 5 ≤ ℓ) (hlN : ¬(ℓ : ℤ) ∣ N) :
    ℓ ∣ (((x : ℚ) ^ 4 - 8 * (N : ℚ) * (x : ℚ)) / (4 * (y : ℚ) ^ 2)).den ↔
      ((x : ZMod ℓ) ∈ vanishingClasses N ℓ) := by
  have hl := (Fact.out : ℓ.Prime)
  rw [MordellDenominators.dvd_den_double_iff heq hy hl hl5 hlN, mem_vanishingClasses_iff]
  have hcast : ((x : ZMod ℓ)) ^ 3 + (N : ZMod ℓ) = ((y : ZMod ℓ)) ^ 2 := by
    exact_mod_cast congrArg (fun t : ℤ => (t : ZMod ℓ)) heq.symm
  rw [hcast, pow_eq_zero_iff two_ne_zero, ZMod.intCast_zmod_eq_zero_iff_dvd]

/-! ## Counting the classes -/

/-- At a **supersingular** prime `ℓ ≡ 2 (mod 3)` there is exactly one denominator-producing
class, for every `N`: cubing is a bijection of `𝔽_ℓ`, so `T³ = -N` has a unique solution. -/
theorem card_vanishingClasses_of_two_mod_three [Fact ℓ.Prime] (h3 : ℓ % 3 = 2) (N : ℤ) :
    (vanishingClasses N ℓ).card = 1 := by
  obtain ⟨hinj, hsurj⟩ := EllipticModCount.cube_bijective_zmod (p := ℓ) h3
  obtain ⟨t, ht⟩ := hsurj (-(N : ZMod ℓ))
  simp only at ht
  rw [Finset.card_eq_one]
  refine ⟨t, ?_⟩
  ext u
  simp only [Finset.mem_singleton, mem_vanishingClasses_iff]
  constructor
  · intro h
    refine hinj ?_
    simp only
    rw [ht]
    linear_combination h
  · rintro rfl
    rw [ht]; ring

/-- A primitive cube root of unity exists in `𝔽_ℓ` when `ℓ ≡ 1 (mod 3)` (Cauchy's theorem
applied to the cyclic group `𝔽_ℓˣ` of order `ℓ - 1`). -/
lemma exists_cube_root_unity [Fact ℓ.Prime] (h3 : ℓ % 3 = 1) :
    ∃ w : ZMod ℓ, w ^ 3 = 1 ∧ w ≠ 1 := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  have hcard : Fintype.card (ZMod ℓ)ˣ = ℓ - 1 := by
    rw [ZMod.card_units_eq_totient, Nat.totient_prime Fact.out]
  have hdvd : 3 ∣ Fintype.card (ZMod ℓ)ˣ := by rw [hcard]; omega
  obtain ⟨u, hu⟩ := exists_prime_orderOf_dvd_card 3 hdvd
  have h1 : u ^ 3 = 1 := hu ▸ pow_orderOf_eq_one u
  refine ⟨(u : ZMod ℓ), ?_, ?_⟩
  · have h2 := congrArg (Units.val) h1
    push_cast at h2
    exact h2
  · intro h
    have hu1 : u = 1 := Units.ext h
    rw [hu1] at hu
    simp at hu

/-- The (nonzero) discriminant of the reduced Mordell curve. -/
lemma disc_ne_zero_of_not_dvd [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) {N : ℤ} (hlN : ¬(ℓ : ℤ) ∣ N) :
    EllipticModCount.disc (0 : ZMod ℓ) ((N : ZMod ℓ)) ≠ 0 := by
  have hN : (N : ZMod ℓ) ≠ 0 := by rw [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]; exact hlN
  have h3ne : (3 : ZMod ℓ) ≠ 0 := EllipticModCount.three_ne_zero_zmod (by omega)
  simp only [EllipticModCount.disc]
  have h27 : (27 : ZMod ℓ) ≠ 0 := by
    have h : (27 : ZMod ℓ) = 3 ^ 3 := by norm_num
    rw [h]
    exact pow_ne_zero _ h3ne
  intro hc
  have hprod : (27 : ZMod ℓ) * (N : ZMod ℓ) ^ 2 = 0 := by linear_combination hc
  rcases mul_eq_zero.mp hprod with h | h
  · exact h27 h
  · exact hN (pow_eq_zero_iff two_ne_zero |>.mp h)

/-- At an **ordinary** prime `ℓ ≡ 1 (mod 3)` with `ℓ ≥ 5` and `ℓ ∤ N`, the number of
denominator-producing classes is `0` or `3`: a primitive cube root of unity in `𝔽_ℓ` permutes
the roots without fixed points, and no nonsingular cubic has exactly two roots. -/
theorem card_vanishingClasses_of_one_mod_three [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) (h3 : ℓ % 3 = 1)
    {N : ℤ} (hlN : ¬(ℓ : ℤ) ∣ N) :
    (vanishingClasses N ℓ).card = 0 ∨ (vanishingClasses N ℓ).card = 3 := by
  have hN : (N : ZMod ℓ) ≠ 0 := by rw [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]; exact hlN
  rcases EllipticModCount.rootSet_card_cases (disc_ne_zero_of_not_dvd hl5 hlN) with h | h | h
  · exact Or.inl h
  · exfalso
    obtain ⟨r, hr⟩ := Finset.card_eq_one.mp h
    obtain ⟨w, hw3, hw1⟩ := exists_cube_root_unity (ℓ := ℓ) h3
    have hrmem : r ∈ vanishingClasses N ℓ := by rw [vanishingClasses, hr]; simp
    rw [mem_vanishingClasses_iff] at hrmem
    have hwr : (w * r) ∈ vanishingClasses N ℓ := by
      rw [mem_vanishingClasses_iff]
      calc (w * r) ^ 3 + (N : ZMod ℓ) = w ^ 3 * r ^ 3 + (N : ZMod ℓ) := by ring
        _ = r ^ 3 + (N : ZMod ℓ) := by rw [hw3]; ring
        _ = 0 := hrmem
    have hfix : w * r = r := by
      rw [vanishingClasses, hr, Finset.mem_singleton] at hwr
      exact hwr
    have hr0 : r = 0 := by
      have hz : (w - 1) * r = 0 := by linear_combination hfix
      rcases mul_eq_zero.mp hz with hh | hh
      · exact absurd (by linear_combination hh : w = 1) hw1
      · exact hh
    rw [hr0] at hrmem
    simp at hrmem
    exact hN hrmem
  · exact Or.inr h

/-- **Exact average.**  Summed over all residues `c` of `N` modulo `ℓ`, the number of
denominator-producing classes is exactly `ℓ`; the average over `N` is therefore exactly `1`,
independently of `ℓ mod 3`.  (Each `x` contributes to exactly one `c`, namely `c = -x³`.) -/
theorem sum_card_vanishingClasses [Fact ℓ.Prime] :
    ∑ c : ZMod ℓ, (EllipticModCount.rootSet (0 : ZMod ℓ) c).card = ℓ := by
  have h1 : ∀ c : ZMod ℓ, (EllipticModCount.rootSet (0 : ZMod ℓ) c).card
      = ∑ x : ZMod ℓ, if c = -x ^ 3 then 1 else 0 := by
    intro c
    rw [EllipticModCount.rootSet, Finset.card_filter]
    refine Finset.sum_congr rfl fun x _ => ?_
    refine if_congr ?_ rfl rfl
    simp only [EllipticModCount.wRHS, zero_mul, add_zero]
    constructor
    · intro h; linear_combination h
    · intro h; linear_combination h
  rw [Finset.sum_congr rfl fun c _ => h1 c, Finset.sum_comm]
  have h2 : ∀ x : ZMod ℓ, (∑ c : ZMod ℓ, if c = -x ^ 3 then 1 else 0) = 1 := by
    intro x; simp
  rw [Finset.sum_congr rfl fun x _ => h2 x]
  simp [ZMod.card ℓ]

/-- The average number of denominator-producing classes is exactly `1`: the total count over
the `ℓ` possible residues of `N` equals `ℓ`, i.e. density exactly `1/ℓ` of the classes. -/
theorem average_card_vanishingClasses [Fact ℓ.Prime] :
    (∑ c : ZMod ℓ, ((EllipticModCount.rootSet (0 : ZMod ℓ) c).card : ℚ)) / (ℓ : ℚ) = 1 := by
  have hl := (Fact.out : ℓ.Prime)
  have hne : (ℓ : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr hl.ne_zero
  have h : (∑ c : ZMod ℓ, ((EllipticModCount.rootSet (0 : ZMod ℓ) c).card : ℚ)) = (ℓ : ℚ) := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℚ)) (sum_card_vanishingClasses (ℓ := ℓ))
  rw [h, div_self hne]

/-! ## Consequences for the "only bad primes" conjecture -/

/-- **Unique violating class at supersingular primes.**  For `ℓ ≥ 5`, `ℓ ≡ 2 (mod 3)` and
`ℓ ∤ N` there is a unique residue class `t` mod `ℓ` which is a root of `T³ + N`, and an
integral point `(x, y)` of `E_N` with `y ≠ 0` has `ℓ` in the denominator of `x(2P)` exactly
when `x ≡ t (mod ℓ)`. -/
theorem exists_unique_vanishing_class [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) (h3 : ℓ % 3 = 2) {N : ℤ}
    (hlN : ¬(ℓ : ℤ) ∣ N) :
    ∃! t : ZMod ℓ, t ^ 3 + (N : ZMod ℓ) = 0 ∧ ∀ x y : ℤ, y ^ 2 = x ^ 3 + N → y ≠ 0 →
      (ℓ ∣ (((x : ℚ) ^ 4 - 8 * (N : ℚ) * (x : ℚ)) / (4 * (y : ℚ) ^ 2)).den ↔
        (x : ZMod ℓ) = t) := by
  obtain ⟨t, ht⟩ := Finset.card_eq_one.mp (card_vanishingClasses_of_two_mod_three h3 N)
  have hmem : ∀ u : ZMod ℓ, u ^ 3 + (N : ZMod ℓ) = 0 ↔ u = t := by
    intro u
    rw [← mem_vanishingClasses_iff, ht, Finset.mem_singleton]
  refine ⟨t, ⟨(hmem t).mpr rfl, ?_⟩, ?_⟩
  · intro x y heq hy
    rw [dvd_den_double_iff_mem_vanishingClasses heq hy hl5 hlN, ht, Finset.mem_singleton]
  · rintro s ⟨hs, -⟩
    exact (hmem s).mp hs

/-- The `2`-torsion locus of the reduced curve — the affine points with `y = 0` — has exactly
one element at a supersingular prime, out of `cardPoints = ℓ + 1` points in all.  So the
denominator-producing locus is an exact `1/(ℓ+1)` fraction of the reduced group. -/
theorem card_two_torsion_locus_of_two_mod_three [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) (h3 : ℓ % 3 = 2)
    (N : ℤ) :
    ((EllipticModCount.affineLocus (0 : ZMod ℓ) ((N : ZMod ℓ))).filter
        (fun P => P.2 = 0)).card = 1 ∧
      EllipticModCount.cardPoints (0 : ZMod ℓ) ((N : ZMod ℓ)) = ℓ + 1 := by
  constructor
  · have hset : ((EllipticModCount.affineLocus (0 : ZMod ℓ) ((N : ZMod ℓ))).filter
        (fun P => P.2 = 0))
        = (vanishingClasses N ℓ).map ⟨fun t => (t, 0), fun a b hab => (Prod.mk.injEq .. ▸ hab).1⟩ := by
      ext P
      simp only [Finset.mem_filter, EllipticModCount.affineLocus, Finset.mem_univ, true_and,
        Finset.mem_map, Function.Embedding.coeFn_mk, mem_vanishingClasses_iff]
      constructor
      · rintro ⟨hP, hP2⟩
        refine ⟨P.1, ?_, ?_⟩
        · rw [hP2] at hP
          simp only [EllipticModCount.wRHS, zero_mul, add_zero] at hP
          linear_combination -hP
        · rw [← hP2]
      · rintro ⟨t, ht, rfl⟩
        refine ⟨?_, rfl⟩
        simp only [EllipticModCount.wRHS, zero_mul, add_zero]
        linear_combination -ht
    rw [hset, Finset.card_map, card_vanishingClasses_of_two_mod_three h3 N]
  · exact EllipticModCount.cardPoints_zmod_eq_of_three (by omega) h3 _

/-- A prime is **denominator-active** for `N` if some residue class mod `ℓ` forces `ℓ` into the
denominator of `x(2P)`, i.e. if `T³ + N` has a root mod `ℓ`. -/
def Active (N : ℤ) (ℓ : ℕ) : Prop := ∃ t : ZMod ℓ, t ^ 3 + (N : ZMod ℓ) = 0

lemma active_iff_nonempty [Fact ℓ.Prime] (N : ℤ) :
    Active N ℓ ↔ (vanishingClasses N ℓ).Nonempty := by
  constructor
  · rintro ⟨t, ht⟩
    exact ⟨t, mem_vanishingClasses_iff.mpr ht⟩
  · rintro ⟨t, ht⟩
    exact ⟨t, mem_vanishingClasses_iff.mp ht⟩

/-- Every supersingular prime is denominator-active, for every `N`. -/
theorem active_of_two_mod_three [Fact ℓ.Prime] (h3 : ℓ % 3 = 2) (N : ℤ) : Active N ℓ := by
  rw [active_iff_nonempty]
  exact Finset.card_pos.mp (by rw [card_vanishingClasses_of_two_mod_three h3 N]; norm_num)

/-- **Infinitely many good primes are denominator-active.**  For every `N`, every prime
`ℓ ≡ 2 (mod 3)` is active, and by Dirichlet's theorem there are infinitely many such primes.
So no finite set of primes — in particular no set determined by the factorisation of `N` —
can contain the denominator primes of doubled points. -/
theorem infinite_supersingular_active_primes (N : ℤ) :
    {ℓ : ℕ | ℓ.Prime ∧ ℓ % 3 = 2 ∧ Active N ℓ}.Infinite := by
  have hunit : IsUnit (2 : ZMod 3) := by decide
  have hinf := Nat.infinite_setOf_prime_and_eq_mod hunit
  refine Set.Infinite.mono (s := {p : ℕ | p.Prime ∧ (p : ZMod 3) = 2}) ?_ hinf
  rintro p ⟨hp, hp3⟩
  haveI : Fact p.Prime := ⟨hp⟩
  have hmod : p % 3 = 2 := by
    rw [show ((2 : ZMod 3)) = ((2 : ℕ) : ZMod 3) by norm_num,
      ZMod.natCast_eq_natCast_iff] at hp3
    have := hp3
    unfold Nat.ModEq at this
    omega
  exact ⟨hp, hmod, active_of_two_mod_three hmod N⟩

/-! ## A quantitative bound for a fixed point -/

/-- The violating good primes at `2P` are *exactly* the primes `≥ 5` dividing `y` and not `N`. -/
theorem mem_good_violating_primes_iff {N x y : ℤ} (heq : y ^ 2 = x ^ 3 + N) (hy : y ≠ 0)
    {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ) (hlN : ¬(ℓ : ℤ) ∣ N) :
    ℓ ∣ (((x : ℚ) ^ 4 - 8 * (N : ℚ) * (x : ℚ)) / (4 * (y : ℚ) ^ 2)).den ↔
      ℓ ∈ y.natAbs.primeFactors := by
  rw [MordellDenominators.dvd_den_double_iff heq hy hl hl5 hlN, Nat.mem_primeFactors]
  constructor
  · intro h
    refine ⟨hl, ?_, by simpa using hy⟩
    have : ((ℓ : ℤ)).natAbs ∣ y.natAbs := Int.natAbs_dvd_natAbs.mpr h
    simpa using this
  · rintro ⟨-, hdvd, -⟩
    have : ((ℓ : ℤ)).natAbs ∣ y.natAbs := by simpa using hdvd
    exact Int.natAbs_dvd_natAbs.mp this

/-- **Counting the violating primes of one doubling.**  For a fixed integral point `(x, y)`
with `y ≠ 0`, the good primes violating the "only bad primes" conjecture at `2P` are exactly
the primes `≥ 5` dividing `y` but not `N`; in particular `5 ^ (number of them) ≤ |y|`, i.e.
a single doubling can exhibit at most `log₅ |y|` violations. -/
theorem card_good_violating_primes_le {N y : ℤ} (hy : y ≠ 0) :
    5 ^ ((y.natAbs.primeFactors.filter
        (fun ℓ : ℕ => 5 ≤ ℓ ∧ ¬(ℓ : ℤ) ∣ N)).card) ≤ y.natAbs := by
  set S := y.natAbs.primeFactors.filter (fun ℓ : ℕ => 5 ≤ ℓ ∧ ¬(ℓ : ℤ) ∣ N) with hS
  have hpos : 0 < y.natAbs := Int.natAbs_pos.mpr hy
  have hle : 5 ^ S.card ≤ ∏ p ∈ S, p := by
    calc 5 ^ S.card = ∏ _p ∈ S, 5 := by rw [Finset.prod_const]
      _ ≤ ∏ p ∈ S, p := by
          refine Finset.prod_le_prod' ?_
          intro i hi
          exact ((Finset.mem_filter.mp hi).2).1
  have hdvd : (∏ p ∈ S, p) ∣ y.natAbs := by
    refine dvd_trans (Finset.prod_dvd_prod_of_subset _ _ _ (Finset.filter_subset _ _)) ?_
    exact Nat.prod_primeFactors_dvd _
  exact le_trans hle (Nat.le_of_dvd hpos hdvd)

/-! ## Concrete instances of the counting law -/

section Concrete

instance factPrimeSeven : Fact (Nat.Prime 7) := ⟨by norm_num⟩
instance factPrimeThirteen : Fact (Nat.Prime 13) := ⟨by norm_num⟩

/-- For `N = 55` and the ordinary prime `7 ≡ 1 (mod 3)`, there are exactly three
denominator-producing classes, namely `{1, 2, 4}`; and `x = 9 ≡ 2` is one of them, which is
why `7 ∣ den x(2P) = den (2601/3136)`. -/
theorem vanishingClasses_55_7 :
    vanishingClasses 55 7 = {1, 2, 4} := by decide

/-- For `N = 55` and the ordinary prime `13 ≡ 1 (mod 3)` there is no denominator-producing
class at all: `13` cannot divide the denominator of `x(2P)` for any integral point of `E_55`,
even though `13` does divide the denominator of `x(3P)`. -/
theorem vanishingClasses_55_13 : vanishingClasses 55 13 = ∅ := by decide

/-- The counting law at work: `3` classes at `7`, `0` classes at `13`, in accordance with the
`0 ∨ 3` dichotomy at primes `≡ 1 (mod 3)`. -/
theorem card_vanishingClasses_55 :
    (vanishingClasses 55 7).card = 3 ∧ (vanishingClasses 55 13).card = 0 := by
  rw [vanishingClasses_55_7, vanishingClasses_55_13]
  exact ⟨by decide, by decide⟩

end Concrete

end MordellPointCount