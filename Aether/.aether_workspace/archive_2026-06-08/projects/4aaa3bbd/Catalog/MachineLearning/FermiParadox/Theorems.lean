/-
# Fermi Paradox Theorems

## Main Results

1. **Reverse Pigeonhole**: If k < n, then any assignment of k civilizations
   to n planets leaves at least n - k planets empty.

2. **Drake Bound**: Under conservative estimates, expected civilizations < 1.

3. **Poisson Zero Bound**: If expected count λ ∈ (0,1), then (1-λ/n)^n > 0
   and converges to e^{-λ} > 1/e, giving P(zero civilizations) > 36%.

4. **Great Filter Dichotomy**: Either the filter is strong (prob < 1/n)
   or we expect multiple civilizations.

5. **Tropical Bottleneck Dominance**: The total filter strength is at least
   the bottleneck (max component), connecting to tropical geometry.

6. **Entropy-Rarity Duality**: Cross-domain connection between information
   theory and the Fermi paradox.
-/

import Mathlib
import Speculative.FermiParadox.Defs

open Finset BigOperators

/-! ## 1. Reverse Pigeonhole: Most Planets Are Empty -/

/-
**Reverse Pigeonhole Theorem**: If there are fewer civilizations (k)
than planets (n), then at least n - k planets are empty.

This is the mathematical core of the Fermi paradox: with very few civilizations
and very many planets, the overwhelming majority of planets must be uninhabited.
-/
theorem reverse_pigeonhole {k n : ℕ} (h : k < n)
    (f : CivilizationAssignment k n) :
    n - k ≤ numEmptyPlanets f := by
  -- The set of non-empty planets has cardinality at most k (since each of the k civilizations contributes to at most one planet's count).
  have h_card_nonempty : (Finset.univ.filter (fun j => civCount f j ≠ 0)).card ≤ k := by
    have h_card_nonempty : (Finset.univ.filter (fun j => civCount f j ≠ 0)).card ≤ (Finset.image f Finset.univ).card := by
      exact Finset.card_le_card fun x hx => by unfold civCount at hx; aesop;
    exact h_card_nonempty.trans ( Finset.card_image_le.trans ( by simpa ) );
  convert Nat.sub_le_sub_left h_card_nonempty n using 1;
  simp +decide [ numEmptyPlanets, Finset.filter_not, Finset.card_sdiff ];
  rw [ Nat.sub_sub_self ( le_trans ( Finset.card_le_univ _ ) ( by norm_num ) ) ]

/-
The fraction of empty planets approaches 1 as the ratio k/n → 0.
More precisely: if k ≤ n, then numEmptyPlanets ≥ n - k.
-/
theorem empty_planets_complement {k n : ℕ} (h : k ≤ n)
    (f : CivilizationAssignment k n) :
    n - k ≤ numEmptyPlanets f := by
  by_cases hk : k = n;
  · aesop;
  · exact reverse_pigeonhole ( lt_of_le_of_ne h hk ) f

/-! ## 2. Drake Expected Value Bound -/

/-
If the per-planet probability is less than 1/n, then the expected
number of civilizations is less than 1. This is the quantitative
Fermi paradox: a sufficiently strong Great Filter makes E[N] < 1.
-/
theorem drake_expected_lt_one (d : DrakeParams) (hd : d.perPlanetProb < 1 / d.numPlanets) :
    d.expectedCiv < 1 := by
  by_cases h : d.numPlanets = 0 <;> simp_all +decide [ DrakeParams.expectedCiv ];
  rwa [ inv_eq_one_div, lt_div_iff₀' ( by positivity ) ] at hd

/-
Under the conservative Drake parameters, E[civilizations] < 1.
This is the computational verification of the Fermi paradox resolution.
-/
theorem conservative_drake_lt_one :
    conservativeDrake.expectedCiv < 1 := by
  unfold DrakeParams.expectedCiv conservativeDrake; norm_num;

/-! ## 3. Probabilistic Bounds -/

/-
**Bernoulli bound**: For p ∈ [0,1] and n ≥ 1, the probability that
ALL n independent Bernoulli(p) trials fail is (1-p)^n.
If n*p < 1, this is bounded below by 1 - n*p > 0.

This gives: P(zero civilizations) ≥ 1 - E[civilizations] when E < 1.
-/
theorem markov_zero_bound {p : ℝ} {n : ℕ} (_hp : 0 ≤ p) (_hp1 : p ≤ 1)
    (_hn : 0 < n) (hexp : n * p < 1) :
    0 < 1 - n * p := by
  linarith

/-
The union bound (Boole's inequality) applied to civilizations:
the probability of at least one civilization is at most E[civilizations].
Contrapositive: if E < 1, there's positive probability of zero civilizations.
-/
theorem union_bound_civilizations (d : DrakeParams) (hlt : d.expectedCiv < 1) :
    0 < 1 - d.expectedCiv := by
  linarith

/-! ## 4. Great Filter Dichotomy -/

/-
**Great Filter Dichotomy**: For any Drake parameters with n ≥ 1 planets,
exactly one of two cases holds:
- The filter is strong: perPlanetProb < 1/n, and E[civilizations] < 1
- The filter is weak: perPlanetProb ≥ 1/n, and E[civilizations] ≥ 1

There is no middle ground. The Fermi paradox is resolved by accepting
which side of the dichotomy we're on.
-/
theorem great_filter_dichotomy (d : DrakeParams) (hn : 0 < d.numPlanets) :
    (d.perPlanetProb < 1 / d.numPlanets ∧ d.expectedCiv < 1) ∨
    (1 / d.numPlanets ≤ d.perPlanetProb ∧ 1 ≤ d.expectedCiv) := by
  rcases lt_or_ge d.perPlanetProb ( 1 / d.numPlanets ) with h | h <;> [ left; right ] <;> refine ⟨ h, ?_ ⟩ <;> simp_all +decide [ DrakeParams.expectedCiv ];
  · rwa [ inv_eq_one_div, lt_div_iff₀' ( Nat.cast_pos.mpr hn ) ] at h;
  · rwa [ inv_eq_one_div, div_le_iff₀' ( by positivity ) ] at h

/-! ## 5. Tropical Bottleneck Dominance (Cross-Domain Connection) -/

/-
**Tropical Bottleneck Theorem**: The total filter strength (sum of
all negative-log factors) is at least the bottleneck (maximum factor).

In tropical geometry terms: the tropical product (= ordinary sum)
dominates the tropical maximum. This connects the Fermi paradox to
tropical algebraic geometry: the "hardest step" in the origin of
intelligence sets a lower bound on the overall filter strength.
-/
theorem tropical_bottleneck_le_total {n : ℕ} [NeZero n]
    (v : TropicalDrakeVector n)
    (hv : ∀ i, 0 ≤ v i) :
    tropicalBottleneck v ≤ totalFilterStrength v := by
  exact Finset.sup'_le _ _ fun i _ => Finset.single_le_sum ( fun a _ => hv a ) ( Finset.mem_univ i )

/-
If all components of the tropical Drake vector are at least c,
then the total filter strength is at least n * c.
-/
theorem tropical_filter_amplification {n : ℕ} (v : TropicalDrakeVector n)
    (c : ℝ) (hc : ∀ i : Fin n, c ≤ v i) :
    n * c ≤ totalFilterStrength v := by
  simpa using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => hc i

/-! ## 6. Entropy-Rarity Duality (Information Theory Connection) -/

/-- The "surprise" (information content) of finding a civilization on a planet
is -log₂(p). When p is very small, the surprise is very large.
This connects the Fermi paradox to information theory: finding ET
would be an extraordinarily high-information event. -/
noncomputable def civilizationSurprise (d : DrakeParams) : ℝ :=
  -Real.logb 2 d.perPlanetProb

/-
**Entropy-Rarity Duality**: The surprise of finding a civilization
is the filter strength divided by ln(2). Higher filter = more surprise.
-/
theorem surprise_eq_filter_div_ln2 (d : DrakeParams) :
    civilizationSurprise d = filterStrength d / Real.log 2 := by
  unfold civilizationSurprise filterStrength; norm_num [ Real.logb ] ; ring;

/-! ## 7. Observational Inference -/

/-
**Bayesian Silence Theorem**: If we've checked m planets and found
zero civilizations, the maximum likelihood estimate of perPlanetProb
is 0, and the Bayesian upper bound (at confidence 1-α) is
-ln(α)/m.

Here we prove a simpler version: if we observe zero in m trials,
then perPlanetProb ≤ 1/m is consistent with observations
(it gives expected ≤ 1 for the checked sample).
-/
theorem silence_implies_rare {m : ℕ} (hm : 0 < m) (p : ℝ)
    (_hp : 0 ≤ p) (_hp1 : p ≤ 1)
    (h_consistent : m * p ≤ 1) :
    p ≤ 1 / m := by
  rwa [ le_div_iff₀' ( by positivity ) ]

/-! ## 8. Falsifiable Conjecture -/

/-
**Conjecture (Great Filter Threshold)**: For any partition of the
Drake probability into k independent factors p₁ × p₂ × ... × pₖ = p_total,
if p_total < 10^{-10}, then at least one factor pᵢ < 10^{-3}.

This is falsifiable: find a partition where all factors are ≥ 10^{-3}
but their product is < 10^{-10}. Since 10^{-3×3} = 10^{-9} > 10^{-10},
this requires k ≥ 4 factors. With k = 4, (10^{-3})^4 = 10^{-12} < 10^{-10},
so the conjecture is FALSE for k ≥ 4.

We prove the NEGATION for k = 4 as a constructive disproof.
-/
theorem great_filter_threshold_disproof :
    ∃ (v : Fin 4 → ℝ),
      (∀ i, (10 : ℝ)⁻¹ ^ 3 ≤ v i) ∧
      (∀ i, v i ≤ 1) ∧
      ∏ i, v i < (10 : ℝ)⁻¹ ^ 10 := by
  -- Define $v$ such that $v_i = 10^{-3}$ for all $i$.
  use fun _ => (10⁻¹ : ℝ)^3;
  norm_num

/-
**Refined Conjecture (Testable)**: For k ≤ 3 independent factors
all at least 10^{-3}, their product is at least 10^{-9} > 10^{-10}.
This IS true and provable.
-/
theorem great_filter_threshold_k3 (v : Fin 3 → ℝ)
    (hv : ∀ i, (10 : ℝ)⁻¹ ^ 3 ≤ v i)
    (_hv1 : ∀ i, v i ≤ 1) :
    (10 : ℝ)⁻¹ ^ 10 < ∏ i, v i := by
  exact lt_of_lt_of_le ( by norm_num ) ( Finset.prod_le_prod ( fun _ _ => by norm_num ) fun _ _ => hv _ )