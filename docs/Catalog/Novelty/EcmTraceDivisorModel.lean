/-
# Which null model produces the ECM early-fire trace?  Divisor model vs integer
# model (exp 570 / paper 218, second cycle)

`Novelty.EcmStageOneTraceLaw` proved the *trace law*: a stage-1 reachable order
`n` fires at schedule position `maxPF n`, its largest prime factor, and it
bounded the density of *late* firers among the integers in `(0, M]` by the
reciprocal sum of the large schedule primes (`< 0.08` at `B1 = 100`).

That bound is a statement about a specific null model — the order is a uniform
*integer*.  The competing null model, the one implicitly assumed when one says
"guarded-affine accounting is collision-dominated", is that the order is a
uniform *divisor of the stage-1 multiplier* `K(B1)`.  This file computes the
firing law of the divisor model exactly and shows the two models make
*opposite* predictions, so the measured trace discriminates between them.

## Main results

* `divisors_fire_filter` — the divisors of `K(B1)` that fire by position `y` are
  *exactly* the divisors of the partial product `stageProd B1 y` (a corollary of
  the trace law).
* `card_divisors_prod_prime_pow` — the divisor count of a product of prime
  powers over a finset of primes is `∏ (e_p + 1)`.
* `card_divisors_stageProd_split` — hence the exact **divisor-model firing law**:
  `τ(K(B1)) = τ(K_y) · ∏_{y < p ≤ B1} (⌊log_p B1⌋ + 1)`, i.e. the probability
  that a uniform divisor fires by `y` is `∏_{y<p≤B1} (⌊log_p B1⌋+1)⁻¹`.
* `divisor_model_hundred` — at `B1 = 100`, `y = 67` that probability is `1/64`:
  the divisor model predicts a **late** firing index, with the last six schedule
  steps carrying `63/64 ≈ 98%` of the mass.
* `integer_model_beats_divisor_model` — the integer model caps the same tail at
  `8%`.  The two null models differ by more than a factor of twelve on the
  observable that exp 570 measured.
* `empty_tail_likelihood_ratio` — the measured `0/55` empty tail is more than
  `1000` times more likely under the integer/structural law (`≤ 8%` tail) than
  under the pre-registered uniform law (`20%` tail): `(23/25)^55 > 1000·(4/5)^55`.
  This is the formal counterpart of the reported binomial rejection.

-- !-- Lab Notes -- !--
-- exp 570 measured 0 hits in the final 20% of the schedule out of 55 hits.
-- Uniformity (H1) gives likelihood (4/5)^55 ≈ 4.7·10⁻⁶ (`uniform_tail_tiny`).
-- The structural cap of `Novelty.EcmStageOneTraceLaw` (tail ≤ 2/25) gives
-- likelihood ≥ (23/25)^55 ≈ 1.0·10⁻² (`structural_tail_plausible`), a ratio
-- above 2000 (`empty_tail_likelihood_ratio` proves > 1000).
-- The divisor null model, by contrast, predicts the tail carries 63/64 of the
-- mass, so it is refuted by the same data even harder than uniformity:
-- (1/64)^55 is astronomically small.  Conclusion: the ECM order behaves like a
-- random *integer* below `B1`, not like a random *divisor* of `K(B1)`; the
-- early-fire trace is the π-compression of a typical largest prime factor.
-/

import Novelty.EcmStageOneTraceLaw

namespace Catalog.Novelty.EcmTraceDivisorModel

open Finset Catalog.Novelty.EcmStageOneTraceLaw Catalog.Novelty.SmoothNumberLowerBound

/-! ### The divisor model fires late -/

/-- Schedule primes beyond `B1` contribute a trivial factor, so the partial
product saturates at `y = B1`. -/
lemma stageProd_min (B1 y : ℕ) : stageProd B1 y = stageProd B1 (min y B1) := by
  refine (Finset.prod_subset (primesUpTo_mono (min_le_left y B1)) ?_).symm
  intro p hp hnot
  have hpy : p ≤ y := (mem_primesUpTo.mp hp).1
  have hpp : p.Prime := (mem_primesUpTo.mp hp).2
  have hgt : B1 < p := by
    by_contra hcon
    exact hnot (mem_primesUpTo.mpr ⟨le_min hpy (not_lt.mp hcon), hpp⟩)
  have : Nat.log p B1 = 0 := Nat.log_eq_zero_iff.mpr (Or.inl hgt)
  simp [this]

/-- Every partial stage-1 product divides the full stage-1 multiplier. -/
lemma stageProd_dvd_full (B1 y : ℕ) : stageProd B1 y ∣ stageProd B1 B1 := by
  rw [stageProd_min]
  exact stageProd_dvd_mono (min_le_right y B1)

/-- The divisors of the full stage-1 multiplier that fire by schedule position
`y` are exactly the divisors of the partial product.  (Corollary of the trace
law `dvd_stageProd_iff_maxPF_le`.) -/
theorem divisors_fire_filter (B1 y : ℕ) :
    {d ∈ (stageProd B1 B1).divisors | maxPF d ≤ y} = (stageProd B1 y).divisors := by
  ext d
  simp only [Finset.mem_filter, Nat.mem_divisors]
  constructor
  · rintro ⟨⟨hdvd, hne⟩, hmax⟩
    have hd0 : d ≠ 0 := by rintro rfl; exact hne (Nat.eq_zero_of_zero_dvd hdvd)
    exact ⟨(dvd_stageProd_iff_maxPF_le hd0 hdvd).mpr hmax, (stageProd_pos B1 y).ne'⟩
  · rintro ⟨hdvd, -⟩
    have hreach : d ∣ stageProd B1 B1 := hdvd.trans (stageProd_dvd_full B1 y)
    have hd0 : d ≠ 0 := by
      rintro rfl
      exact (stageProd_pos B1 y).ne' (Nat.eq_zero_of_zero_dvd hdvd ▸ rfl)
    exact ⟨⟨hreach, (stageProd_pos B1 B1).ne'⟩,
      (dvd_stageProd_iff_maxPF_le hd0 hreach).mp hdvd⟩

/-- The divisor count of a product of prime powers indexed by a finset of primes
is `∏ (e_p + 1)`. -/
theorem card_divisors_prod_prime_pow (S : Finset ℕ) (hS : ∀ p ∈ S, p.Prime) (f : ℕ → ℕ) :
    (∏ p ∈ S, p ^ f p).divisors.card = ∏ p ∈ S, (f p + 1) := by
  classical
  induction S using Finset.induction_on with
  | empty => simp
  | insert p S hp ih =>
      have hpp : p.Prime := hS p (Finset.mem_insert_self p S)
      have hS' : ∀ q ∈ S, q.Prime := fun q hq => hS q (Finset.mem_insert_of_mem hq)
      have hcop : Nat.Coprime (p ^ f p) (∏ q ∈ S, q ^ f q) := by
        refine Nat.Coprime.pow_left _ (Nat.Coprime.prod_right fun q hq => ?_)
        refine Nat.Coprime.pow_right _ ?_
        have hqp : q.Prime := hS' q hq
        refine (Nat.coprime_primes hpp hqp).mpr ?_
        rintro rfl
        exact hp hq
      rw [Finset.prod_insert hp, Finset.prod_insert hp, hcop.card_divisors_mul, ih hS',
        Nat.divisors_prime_pow hpp]
      simp

/-- **The divisor-model firing law.**  The number of divisors of the full
stage-1 multiplier splits as the number of early firers times the local factor
`∏_{y < p ≤ B1} (⌊log_p B1⌋ + 1)` contributed by the late schedule primes. -/
theorem card_divisors_stageProd_split (B1 y : ℕ) :
    (stageProd B1 B1).divisors.card
      = (stageProd B1 y).divisors.card * ∏ p ∈ largePrimes B1 y, (Nat.log p B1 + 1) := by
  classical
  have hsplitset : primesUpTo B1 = primesUpTo (min y B1) ∪ largePrimes B1 y := by
    ext p
    simp only [Finset.mem_union, mem_primesUpTo, largePrimes, Finset.mem_filter,
      Finset.mem_Ioc, le_min_iff]
    constructor
    · rintro ⟨hle, hpp⟩
      rcases le_or_gt p y with h | h
      · exact Or.inl ⟨⟨h, hle⟩, hpp⟩
      · exact Or.inr ⟨⟨h, hle⟩, hpp⟩
    · rintro (⟨⟨h1, h2⟩, hpp⟩ | ⟨⟨_, h2⟩, hpp⟩)
      · exact ⟨h2, hpp⟩
      · exact ⟨h2, hpp⟩
  have hdisj : Disjoint (primesUpTo (min y B1)) (largePrimes B1 y) := by
    rw [Finset.disjoint_left]
    intro p hp hq
    have h1 : p ≤ y := le_trans (mem_primesUpTo.mp hp).1 (min_le_left _ _)
    have h2 : y < p := (Finset.mem_Ioc.mp (Finset.mem_filter.mp hq).1).1
    omega
  have hprod : stageProd B1 B1 = stageProd B1 (min y B1) *
      ∏ p ∈ largePrimes B1 y, p ^ Nat.log p B1 := by
    rw [stageProd, stageProd, hsplitset, Finset.prod_union hdisj]
  have hminy : stageProd B1 (min y B1) = stageProd B1 y := (stageProd_min B1 y).symm
  have hcop : Nat.Coprime (stageProd B1 (min y B1))
      (∏ p ∈ largePrimes B1 y, p ^ Nat.log p B1) := by
    refine Nat.Coprime.prod_left fun p hp => Nat.Coprime.pow_left _
      (Nat.Coprime.prod_right fun q hq => Nat.Coprime.pow_right _ ?_)
    have hpp : p.Prime := (mem_primesUpTo.mp hp).2
    have hqq : q.Prime := (Finset.mem_filter.mp hq).2
    refine (Nat.coprime_primes hpp hqq).mpr ?_
    rintro rfl
    have h1 : p ≤ y := le_trans (mem_primesUpTo.mp hp).1 (min_le_left _ _)
    have h2 : y < p := (Finset.mem_Ioc.mp (Finset.mem_filter.mp hq).1).1
    omega
  rw [hprod, hcop.card_divisors_mul, hminy,
    card_divisors_prod_prime_pow (largePrimes B1 y)
      (fun p hp => (Finset.mem_filter.mp hp).2) (fun p => Nat.log p B1)]

/-- At `B1 = 100`, `y = 67` the late factor is `2^6 = 64`. -/
lemma late_factor_hundred : ∏ p ∈ largePrimes 100 67, (Nat.log p 100 + 1) = 64 := by
  rw [largePrimes_hundred]
  decide

/-- **The divisor model fires late.**  Only one divisor in `64` of the `B1 = 100`
stage-1 multiplier fires within the first `19` of the `25` schedule steps; the
final six steps carry `63/64 ≈ 98%` of the divisor mass.  Contrast the integer
model, where the same tail carries less than `8%`
(`late_tail_density_lt_one_fifth`). -/
theorem divisor_model_hundred :
    (stageProd 100 100).divisors.card = 64 * (stageProd 100 67).divisors.card := by
  rw [card_divisors_stageProd_split 100 67, late_factor_hundred, Nat.mul_comm]

/-- The divisor-model early-firing fraction at `B1 = 100` is exactly `1/64`. -/
theorem divisor_model_early_fraction :
    ((stageProd 100 67).divisors.card : ℝ) / (stageProd 100 100).divisors.card = 1 / 64 := by
  have hpos : (0 : ℝ) < ((stageProd 100 67).divisors.card : ℝ) := by
    have : 0 < (stageProd 100 67).divisors.card :=
      Finset.card_pos.mpr ⟨1, Nat.one_mem_divisors.mpr (stageProd_pos 100 67).ne'⟩
    exact_mod_cast this
  rw [divisor_model_hundred]
  push_cast
  field_simp

/-- **Model discrimination.**  On the observable measured by exp 570 — the mass
in the final six of the `25` schedule steps at `B1 = 100` — the divisor model
predicts `63/64 > 0.98` while the integer model caps the same mass at `2/25 <
0.08`.  The models are more than a factor of twelve apart, so the empty measured
tail selects the integer model. -/
theorem integer_model_beats_divisor_model (M : ℕ) (hM : 0 < M) :
    (#(lateOrders M 100 67) : ℝ) < 2 / 25 * M ∧
      (1 : ℝ) - ((stageProd 100 67).divisors.card : ℝ) / (stageProd 100 100).divisors.card
        = 63 / 64 ∧ (2 : ℝ) / 25 * 12 < 63 / 64 := by
  refine ⟨late_tail_density_lt_one_fifth M hM, ?_, by norm_num⟩
  rw [divisor_model_early_fraction]
  norm_num

/-! ### The likelihood of the measured empty tail -/

/-- Under the pre-registered uniform law the probability of seeing no hit in the
final 20% of the schedule across all `55` recorded hits is `(4/5)^55 < 10⁻⁵`. -/
theorem uniform_tail_tiny : ((4 : ℝ) / 5) ^ 55 < 1 / 100000 := by norm_num

/-- Under the structural cap proved in `Novelty.EcmStageOneTraceLaw` (late mass
at most `2/25`) the same empty tail has probability at least `(23/25)^55 >
1/100`: perfectly ordinary. -/
theorem structural_tail_plausible : (1 : ℝ) / 100 < (23 / 25 : ℝ) ^ 55 := by norm_num

/-- **Likelihood ratio.**  The measured `0/55` empty tail is more than a thousand
times more likely under the structural firing law than under the pre-registered
uniform law — the formal counterpart of the reported binomial rejection of H1. -/
theorem empty_tail_likelihood_ratio :
    1000 * ((4 : ℝ) / 5) ^ 55 < (23 / 25 : ℝ) ^ 55 := by
  have h1 : 1000 * ((4 : ℝ) / 5) ^ 55 < 1000 * (1 / 100000) := by
    have := uniform_tail_tiny
    linarith
  have h2 : (1 : ℝ) / 100 < (23 / 25 : ℝ) ^ 55 := structural_tail_plausible
  linarith

end Catalog.Novelty.EcmTraceDivisorModel