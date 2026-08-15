import Novelty.MordellApparitionEffective

/-!
# Density of the good-prime violations in a Mordell orbit

Cycle 7 of the "only bad primes" thread.  Cycle 6
(`Novelty.MordellApparitionEffective`) showed that *every* prime `ℓ ≥ 5` of good reduction
divides the denominator of `x(nP)` for some `n ≤ 4ℓ`.  Combined with the apparition law
(the indices at which `ℓ` appears form the multiples of a modulus `m`), this turns the
qualitative refutation of the "only bad primes" conjecture into a *quantitative* statement:
the violating indices have positive density `1/m ≥ 1/(4ℓ)` inside every initial segment.

## Main results

* `card_orbit_violations_eq` : the number of `n ∈ (0, K]` with `ℓ ∣ den x(nP)` is exactly
  `⌊K/m⌋`, where `m ≤ 4ℓ` is the apparition index.
* `card_orbit_violations_ge` : hence at least `⌊K/(4ℓ)⌋` of the first `K` multiples violate
  the conjecture at `ℓ`.
* `card_good_primes_appearing_ge` : at least as many distinct good primes appear among the
  first `K` denominators as there are good primes `ℓ` with `4ℓ ≤ K`.
* `joint_apparition_91_55` : on `E_55` with `P = (9,28)` the two good primes `7` and `13`
  appear *simultaneously* exactly at the multiples of `6`, so `91 = 7 · 13` divides
  `den x(kP)` iff `6 ∣ k`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer, cycle 7): the violation locus of a fixed good prime is not merely
  infinite (cycle 5) but of positive density, and the density is controlled by the effective
  bound of cycle 6.
Experiment (Experimenter): on `E_55`, `P = (9,28)`, the prime `7` has apparition index `2` and
  `13` has index `3`; the predicted densities `1/2` and `1/3` match the computed valuation
  tables `v₇ = 2` at `n = 2,4,6,8` and `v₁₃ = 2` at `n = 3,6`.  The joint index is `6`, i.e.
  `lcm(2,3)`, as the CRT heuristic predicts.
Analysis (Analyst): the two ingredients are logically independent — the subgroup structure of
  the kernel gives *periodicity*, the pigeonhole over the reduced curve gives an *upper bound
  for the period*.  Only their combination yields a density lower bound.
Critique (Critic): the density statement is sharp in the sense that `m` can be as large as the
  order of the reduction, so no bound better than `1/(2ℓ + O(√ℓ))` is possible in general; the
  factor `4` is the cost of the elementary point count `#E(F_ℓ) ≤ 2ℓ` in place of Hasse.
-/

namespace MordellDenominators

open WeierstrassCurve WeierstrassCurve.Affine

open scoped Classical in
/-- **Exact count of the violating indices.**  For a good prime `ℓ ≥ 5` there is a modulus
`m` with `0 < m ≤ 4ℓ` such that, in every initial segment `(0, K]`, the number of indices `n`
at which `ℓ` divides the denominator of `x(nP)` is exactly `⌊K/m⌋`. -/
theorem card_orbit_violations_eq {N : ℤ} {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ)
    (hlN : ¬(ℓ : ℤ) ∣ N) (P : (mordell ((N : ℤ) : ℚ)).toAffine.Point) :
    ∃ m : ℕ, 0 < m ∧ m ≤ 4 * ℓ ∧ ∀ K : ℕ,
      ((Finset.Ioc 0 K).filter
        (fun n : ℕ => ∀ Y : ℚ, xCoord (n • P) = some Y → ℓ ∣ Y.den)).card = K / m := by
  obtain ⟨m, hm0, hmle, hm⟩ := apparition_index_pos_le hl hl5 hlN P
  refine ⟨m, hm0, hmle, fun K => ?_⟩
  have hfil : ((Finset.Ioc 0 K).filter
      (fun n : ℕ => ∀ Y : ℚ, xCoord (n • P) = some Y → ℓ ∣ Y.den))
      = (Finset.Ioc 0 K).filter (fun n : ℕ => m ∣ n) := by
    refine Finset.filter_congr ?_
    intro n _
    constructor
    · intro h
      have h' : (m : ℤ) ∣ (n : ℤ) := by
        refine (hm (n : ℤ)).1 ?_
        intro Y hY
        rw [natCast_zsmul] at hY
        exact h Y hY
      exact_mod_cast h'
    · intro h Y hY
      have h' : (m : ℤ) ∣ (n : ℤ) := by exact_mod_cast h
      exact (hm (n : ℤ)).2 h' Y (by rwa [natCast_zsmul])
  rw [hfil, Nat.Ioc_filter_dvd_card_eq_div]

open scoped Classical in
/-- **Positive density of violations.**  At least `⌊K/(4ℓ)⌋` of the first `K` multiples of `P`
have `ℓ` in the denominator of their `x`-coordinate.  The "only bad primes" conjecture thus
fails at a positive proportion of indices, for *every* good prime `ℓ ≥ 5`. -/
theorem card_orbit_violations_ge {N : ℤ} {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ)
    (hlN : ¬(ℓ : ℤ) ∣ N) (P : (mordell ((N : ℤ) : ℚ)).toAffine.Point) (K : ℕ) :
    K / (4 * ℓ) ≤ ((Finset.Ioc 0 K).filter
      (fun n : ℕ => ∀ Y : ℚ, xCoord (n • P) = some Y → ℓ ∣ Y.den)).card := by
  obtain ⟨m, hm0, hmle, hcount⟩ := card_orbit_violations_eq hl hl5 hlN P
  rw [hcount K]
  exact Nat.div_le_div_left hmle hm0

open scoped Classical in
/-- **Many distinct good primes appear early.**  Every good prime `ℓ` with `4ℓ ≤ K` divides some
denominator among the first `K` multiples of a point of infinite order, so the set of primes
occurring in the first `K` denominators is at least as large as the set of good primes below
`K/4`. -/
theorem card_good_primes_appearing_ge {N : ℤ} {P : (mordell ((N : ℤ) : ℚ)).toAffine.Point}
    (hP : ∀ n : ℕ, 0 < n → n • P ≠ 0) (K : ℕ) :
    ((Finset.range (K + 1)).filter
        (fun ℓ : ℕ => ℓ.Prime ∧ 5 ≤ ℓ ∧ ¬(ℓ : ℤ) ∣ N ∧ 4 * ℓ ≤ K)).card
      ≤ ((Finset.range (K + 1)).filter
        (fun ℓ : ℕ => ∃ n : ℕ, 0 < n ∧ n ≤ K ∧
          ∃ X : ℚ, xCoord (n • P) = some X ∧ ℓ ∣ X.den)).card := by
  refine Finset.card_le_card ?_
  intro ℓ hℓ
  simp only [Finset.mem_filter, Finset.mem_range] at hℓ ⊢
  obtain ⟨hrange, hprime, hl5, hlN, hle⟩ := hℓ
  obtain ⟨n, hn0, hnle, X, hX, hdvd⟩ := exists_small_multiple_dvd_den hprime hl5 hlN hP
  exact ⟨hrange, n, hn0, le_trans hnle hle, X, hX, hdvd⟩

open scoped Classical in
/-- **Positive density of genuine violations.**  For a point of infinite order the vacuous case
(the multiple being the point at infinity) never occurs, so the counted indices really do carry
an affine `x`-coordinate whose denominator is divisible by `ℓ`. -/
theorem card_orbit_genuine_violations_ge {N : ℤ} {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ)
    (hlN : ¬(ℓ : ℤ) ∣ N) {P : (mordell ((N : ℤ) : ℚ)).toAffine.Point}
    (hP : ∀ n : ℕ, 0 < n → n • P ≠ 0) (K : ℕ) :
    K / (4 * ℓ) ≤ ((Finset.Ioc 0 K).filter
      (fun n : ℕ => ∃ X : ℚ, xCoord (n • P) = some X ∧ ℓ ∣ X.den)).card := by
  have hfil : ((Finset.Ioc 0 K).filter
      (fun n : ℕ => ∀ Y : ℚ, xCoord (n • P) = some Y → ℓ ∣ Y.den))
      = (Finset.Ioc 0 K).filter (fun n : ℕ => ∃ X : ℚ, xCoord (n • P) = some X ∧ ℓ ∣ X.den) := by
    refine Finset.filter_congr ?_
    intro n hn
    simp only [Finset.mem_Ioc] at hn
    rcases point_eq_zero_or_some (n • P) with hz | ⟨x, y, h, hc⟩
    · exact absurd hz (hP n hn.1)
    · have hxc : xCoord (n • P) = some x := by rw [hc]; rfl
      constructor
      · intro hall
        exact ⟨x, hxc, hall x hxc⟩
      · rintro ⟨X, hX, hdvd⟩ Y hY
        rw [hX] at hY
        have : X = Y := by simpa using hY
        rwa [← this]
  rw [← hfil]
  exact card_orbit_violations_ge hl hl5 hlN P K

/-! ## Simultaneous apparition of a finite set of good primes -/

/-- **Simultaneous apparition law.**  For any finite set `S` of primes `≥ 5` of good reduction,
the product `∏_{ℓ ∈ S} ℓ` divides the denominator of `x(kP)` exactly on an arithmetic
progression `M ∣ k`, with `0 < M ≤ ∏_{ℓ ∈ S} 4ℓ`.  Thus arbitrarily many good primes violate
the "only bad primes" conjecture *simultaneously*, at a positive-density set of indices. -/
theorem joint_apparition_finset {N : ℤ} (P : (mordell ((N : ℤ) : ℚ)).toAffine.Point)
    {S : Finset ℕ} (hS : ∀ ℓ ∈ S, ℓ.Prime ∧ 5 ≤ ℓ ∧ ¬(ℓ : ℤ) ∣ N) :
    ∃ M : ℕ, 0 < M ∧ M ≤ ∏ ℓ ∈ S, 4 * ℓ ∧
      ∀ k : ℤ, ((∀ Y : ℚ, xCoord (k • P) = some Y → (∏ ℓ ∈ S, ℓ) ∣ Y.den) ↔ (M : ℤ) ∣ k) := by
  classical
  induction S using Finset.induction with
  | empty =>
      refine ⟨1, by norm_num, by norm_num, fun k => ?_⟩
      simp
  | @insert a S ha ih =>
      have hSsub : ∀ ℓ ∈ S, ℓ.Prime ∧ 5 ≤ ℓ ∧ ¬(ℓ : ℤ) ∣ N := fun ℓ hℓ =>
        hS ℓ (Finset.mem_insert_of_mem hℓ)
      obtain ⟨ha1, ha5, haN⟩ := hS a (Finset.mem_insert_self a S)
      obtain ⟨M, hM0, hMle, hM⟩ := ih hSsub
      obtain ⟨m, hm0, hmle, hm⟩ := apparition_index_pos_le ha1 ha5 haN P
      have hcop : Nat.Coprime a (∏ ℓ ∈ S, ℓ) := by
        refine Nat.Coprime.prod_right ?_
        intro ℓ hℓ
        obtain ⟨hl1, -, -⟩ := hSsub ℓ hℓ
        refine (Nat.coprime_primes ha1 hl1).mpr ?_
        rintro rfl
        exact ha hℓ
      refine ⟨Nat.lcm m M, Nat.pos_of_ne_zero (fun hc => by
        simp [Nat.lcm_eq_zero_iff] at hc
        omega), ?_, fun k => ?_⟩
      · rw [Finset.prod_insert ha]
        refine le_trans (Nat.le_of_dvd (by positivity) (Nat.lcm_dvd_mul m M)) ?_
        exact Nat.mul_le_mul hmle hMle
      · rw [Finset.prod_insert ha]
        constructor
        · intro h
          have h1 : (m : ℤ) ∣ k := by
            refine (hm k).1 (fun Y hY => ?_)
            exact dvd_trans (Dvd.intro _ rfl) (h Y hY)
          have h2 : (M : ℤ) ∣ k := by
            refine (hM k).1 (fun Y hY => ?_)
            exact dvd_trans (Dvd.intro_left _ rfl) (h Y hY)
          have h1' : m ∣ k.natAbs := by
            rwa [← Int.natAbs_dvd_natAbs, Int.natAbs_natCast] at h1
          have h2' : M ∣ k.natAbs := by
            rwa [← Int.natAbs_dvd_natAbs, Int.natAbs_natCast] at h2
          rw [← Int.natAbs_dvd_natAbs, Int.natAbs_natCast]
          exact Nat.lcm_dvd h1' h2'
        · intro h Y hY
          have h1 : (m : ℤ) ∣ k :=
            dvd_trans (Int.natCast_dvd_natCast.mpr (Nat.dvd_lcm_left m M)) h
          have h2 : (M : ℤ) ∣ k :=
            dvd_trans (Int.natCast_dvd_natCast.mpr (Nat.dvd_lcm_right m M)) h
          exact Nat.Coprime.mul_dvd_of_dvd_of_dvd hcop ((hm k).2 h1 Y hY) ((hM k).2 h2 Y hY)

/-! ## Two good primes at once on `E_55` -/

/-- **Joint apparition on `E_55`.**  For `P = (9,28)` on `E_55 : y² = x³ + 55`, the product
`91 = 7 · 13` of two *good* primes divides the denominator of `x(kP)` exactly at the multiples
of `6`.  The violating locus of a set of good primes is thus an arithmetic progression with
modulus the lcm of the individual apparition indices — the failure of the "only bad primes"
conjecture is simultaneous, not sporadic. -/
theorem joint_apparition_91_55 (k : ℤ) :
    (∀ Y : ℚ, xCoord (k • (Point.some nonsingular_int_55_9_28 :
      (mordell (((55 : ℤ)) : ℚ)).toAffine.Point)) = some Y → 91 ∣ Y.den) ↔ (6 : ℤ) ∣ k := by
  constructor
  · intro h
    have h7 : (2 : ℤ) ∣ k := by
      refine (seven_apparition_index_eq_two_55 k).1 ?_
      intro Y hY
      exact dvd_trans ⟨13, by norm_num⟩ (h Y hY)
    have h13 : (3 : ℤ) ∣ k := by
      refine (thirteen_apparition_index_eq_three_55 k).1 ?_
      intro Y hY
      exact dvd_trans ⟨7, by norm_num⟩ (h Y hY)
    omega
  · intro h Y hY
    have h2 : (2 : ℤ) ∣ k := dvd_trans ⟨3, by norm_num⟩ h
    have h3 : (3 : ℤ) ∣ k := dvd_trans ⟨2, by norm_num⟩ h
    have d7 : 7 ∣ Y.den := (seven_apparition_index_eq_two_55 k).2 h2 Y hY
    have d13 : 13 ∣ Y.den := (thirteen_apparition_index_eq_three_55 k).2 h3 Y hY
    exact Nat.Coprime.mul_dvd_of_dvd_of_dvd (by norm_num) d7 d13

end MordellDenominators