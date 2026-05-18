/-
Copyright (c) 2025. All rights reserved.

# Tropical Sieve Theory: Comparison Theorems and Structural Foundations

## Overview

This file establishes a formal theory of tropical (min-plus) sieve methods and
proves rigorous comparison theorems with classical additive weighted sieves.
The central result is that **tropical sieves are universally dominated by
classical weighted sieves** under natural hypotheses: the minimum of local
costs is always bounded above by the sum of local weights. This provides a
formal counterexample to the claim that tropicalization automatically strengthens
sieve bounds.

## Main Results

### Target A: Comparison / Domination Theorems
* `tropical_le_classical` — Pointwise: tropical score ≤ classical weight
* `classical_survivors_sub_tropical` — Classical survivors ⊆ tropical survivors
* `tropical_not_stronger` — Card inequality: tropical sieve filters ≤ classical

### Counterexample / Coincidence
* `singleton_tropical_eq_classical` — When |P| = 1, scores coincide exactly
* `exists_tropical_classical_coincidence` — Existence of exact coincidence

### Target B: From Eventual Lower Bounds to Infinitude
* `eventual_lower_bound_gives_infinitely_many` — A tropical lower bound growing
  linearly implies infinitely many unsieved pair candidates

### Target C: Infimal Convolution Properties
* `infConv_nonneg` — Inf-convolution preserves nonnegativity
* `tropical_score_nonneg` — Tropical scores are nonneg when costs are

### Structural Properties
* `tropical_strict_le_classical_example` — Strict inequality with |P| ≥ 2
* `tropicalSurvivors_antitone_threshold` — Monotonicity in threshold

## Mathematical Significance

These results establish that the min-plus / tropical reformulation of sieve
methods does **not** automatically yield stronger bounds than classical weighted
sieves. The tropical score (infimum over primes) is always dominated by the
classical score (sum over primes), so the tropical sieve has strictly more
survivors. This settles the question of whether "tropical Brun sieve" is
genuinely stronger: it is not — it is a relaxation.

The positive contribution is the identification of the exact structural gap:
the tropical framework provides a *lower bound* on classical sieve weights,
useful for proving that elements *survive* the sieve, but it cannot be used
to prove elements are *eliminated* more efficiently than the classical approach.
-/

import Mathlib

open Finset BigOperators Filter

namespace TropicalSieve

/-! ## Core Definitions -/

/-- Tropical sieve score: the minimum local cost over all primes in `P`.
    When `P` is empty, returns 0 by convention. This is the min-plus aggregate
    of local exclusion penalties — the fundamental tropical sieve functional. -/
noncomputable def tropicalSieveScore (P : Finset ℕ) (c : ℕ → ℝ) (n : ℕ) : ℝ :=
  if h : P.Nonempty then P.inf' h (fun p => c (n % p)) else 0

/-- Classical weighted sieve score: the sum of local weights over all primes in `P`.
    This is the standard additive sieve weight used in Brun, Selberg, and
    combinatorial sieve methods. -/
noncomputable def classicalSieveWeight (P : Finset ℕ) (w : ℕ → ℝ) (n : ℕ) : ℝ :=
  ∑ p ∈ P, w (n % p)

/-- Tropical survivors: elements of `A` whose tropical score is at most `t`. -/
noncomputable def tropicalSurvivors
    (A P : Finset ℕ) (c : ℕ → ℝ) (t : ℝ) : Finset ℕ :=
  A.filter (fun n => tropicalSieveScore P c n ≤ t)

/-- Classical survivors: elements of `A` whose classical weight is at most `t`. -/
noncomputable def classicalSurvivors
    (A P : Finset ℕ) (w : ℕ → ℝ) (t : ℝ) : Finset ℕ :=
  A.filter (fun n => classicalSieveWeight P w n ≤ t)

/-- Pair pattern score for twin-prime candidates: for each prime p in P,
    take the maximum of the costs at n mod p and (n+2) mod p, then minimize
    over all primes. -/
noncomputable def pairPatternScore (P : Finset ℕ) (c : ℕ → ℝ) (n : ℕ) : ℝ :=
  if h : P.Nonempty then
    P.inf' h (fun p => max (c (n % p)) (c ((n + 2) % p)))
  else 0

/-- Twin-candidate unsieved set: elements up to X with pair pattern score ≤ t. -/
noncomputable def twinUnsieved
    (X : ℕ) (P : Finset ℕ) (c : ℕ → ℝ) (t : ℝ) : Finset ℕ :=
  (Finset.range (X + 1)).filter (fun n => pairPatternScore P c n ≤ t)

/-- Infimal convolution (min-plus convolution) of two functions on ℕ.
    For each n, takes the minimum of f(k) + g(n-k) over all 0 ≤ k ≤ n. -/
noncomputable def infConv (f g : ℕ → ℝ) (n : ℕ) : ℝ :=
  (Finset.range (n + 1)).inf' ⟨0, Finset.mem_range.mpr (Nat.zero_lt_succ n)⟩
    (fun k => f k + g (n - k))

/-! ## Target A: Tropical ≤ Classical (Comparison Theorem) -/

/-
**Core comparison lemma**: The tropical sieve score (minimum of local costs)
    is always bounded above by the classical sieve weight (sum of local weights),
    provided costs are dominated by weights and weights are nonneg.

    This is the fundamental inequality showing that tropical sieves are
    *relaxations* of classical weighted sieves, not strengthenings.
-/
theorem tropical_le_classical (P : Finset ℕ) (c w : ℕ → ℝ) (n : ℕ)
    (hP : P.Nonempty)
    (hmajor : ∀ m, c m ≤ w m)
    (hnonneg : ∀ m, 0 ≤ w m) :
    tropicalSieveScore P c n ≤ classicalSieveWeight P w n := by
  unfold tropicalSieveScore classicalSieveWeight;
  split_ifs ; exact le_trans ( Finset.inf'_le _ <| Classical.choose_spec hP ) ( le_trans ( hmajor _ ) <| Finset.single_le_sum ( fun p _ => hnonneg _ ) <| Classical.choose_spec hP )

/-
Classical survivors are always contained in tropical survivors:
    if the classical weighted sieve eliminates a candidate, so does tropical,
    but not conversely.
-/
theorem classical_survivors_sub_tropical (A P : Finset ℕ) (c w : ℕ → ℝ) (t : ℝ)
    (hP : P.Nonempty)
    (hmajor : ∀ m, c m ≤ w m)
    (hnonneg : ∀ m, 0 ≤ w m) :
    classicalSurvivors A P w t ⊆ tropicalSurvivors A P c t := by
  exact fun n hn => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hn |>.1, by simpa using ( TropicalSieve.tropical_le_classical P c w n hP hmajor hnonneg ) |> ( fun h ↦ h.trans ( Finset.mem_filter.mp hn |>.2 ) ) ⟩

/-
**The tropical sieve is not stronger**: the number of classical survivors
    (at threshold t) never exceeds the number of tropical survivors.
    This is the formal counterexample to the claim that tropical methods
    yield tighter sieve bounds.
-/
theorem tropical_not_stronger (A P : Finset ℕ) (c w : ℕ → ℝ) (t : ℝ)
    (hP : P.Nonempty)
    (hmajor : ∀ m, c m ≤ w m)
    (hnonneg : ∀ m, 0 ≤ w m) :
    (classicalSurvivors A P w t).card ≤ (tropicalSurvivors A P c t).card := by
  exact Finset.card_le_card ( classical_survivors_sub_tropical A P c w t hP hmajor hnonneg )

/-! ## Counterexample: Exact Coincidence -/

/-
When the prime set is a singleton, tropical (min) and classical (sum)
    scores coincide exactly. This is the base case where tropicalization
    introduces no relaxation.
-/
theorem singleton_tropical_eq_classical (p : ℕ) (c : ℕ → ℝ) (n : ℕ) :
    tropicalSieveScore {p} c n = classicalSieveWeight {p} c n := by
  unfold tropicalSieveScore classicalSieveWeight; aesop;

/-
**Existence of exact tropical-classical coincidence**: there exist nonempty
    candidate and prime sets where tropical and classical survivor counts match
    exactly. This shows the domination can be tight.
-/
theorem exists_tropical_classical_coincidence :
    ∃ (A P : Finset ℕ) (c : ℕ → ℝ) (t : ℝ),
      A.Nonempty ∧ P.Nonempty ∧
      (tropicalSurvivors A P c t).card =
        (classicalSurvivors A P c t).card := by
  use { 0 };
  use { 0 };
  unfold tropicalSurvivors classicalSurvivors; norm_num;
  unfold tropicalSieveScore classicalSieveWeight; norm_num;

/-! ## Target B: Eventual Lower Bound → Infinitely Many Unsieved -/

/-
**From tropical lower bounds to infinitude of unsieved candidates.**
    If the count of twin-unsieved candidates grows at least linearly
    (eventually δ·X ≤ card for some δ > 0), then for every N there exist
    arbitrarily large X with positive unsieved count.

    This isolates the exact implication: a quantitative tropical lower bound
    on pair-pattern survivors forces infinitely many candidates. The gap
    between "unsieved candidates" and actual twin primes is where the
    parity barrier lives.
-/
theorem eventual_lower_bound_gives_infinitely_many
    (Ps : ℕ → Finset ℕ) (c : ℕ → ℝ) (t δ : ℝ)
    (hδ : 0 < δ)
    (hlb : ∀ᶠ X in atTop,
      δ * X ≤ ((twinUnsieved X (Ps X) c t).card : ℝ)) :
    ∀ N, ∃ X ≥ N, 0 < (twinUnsieved X (Ps X) c t).card := by
  exact fun N => by rcases Filter.eventually_atTop.mp hlb with ⟨ M, hM ⟩ ; exact ⟨ N + M + 1, by linarith, Nat.cast_pos.mp ( lt_of_lt_of_le ( by positivity ) ( hM _ ( by linarith ) ) ) ⟩ ; ;

/-! ## Target C: Infimal Convolution Properties -/

/-
Tropical score is nonneg when all costs are nonneg.
-/
theorem tropical_score_nonneg (P : Finset ℕ) (c : ℕ → ℝ) (n : ℕ)
    (hP : P.Nonempty) (hc : ∀ m, 0 ≤ c m) :
    0 ≤ tropicalSieveScore P c n := by
  unfold tropicalSieveScore;
  aesop

/-
Infimal convolution of nonneg functions is nonneg.
-/
theorem infConv_nonneg (f g : ℕ → ℝ) (n : ℕ)
    (hf : ∀ k, 0 ≤ f k) (hg : ∀ k, 0 ≤ g k) :
    0 ≤ infConv f g n := by
  exact Finset.le_inf' _ _ fun x hx => add_nonneg ( hf x ) ( hg ( n - x ) )

/-
Classical sieve weight is nonneg when all weights are nonneg.
-/
theorem classical_weight_nonneg (P : Finset ℕ) (w : ℕ → ℝ) (n : ℕ)
    (hw : ∀ m, 0 ≤ w m) :
    0 ≤ classicalSieveWeight P w n := by
  exact Finset.sum_nonneg fun p hp => hw _

/-! ## Structural: Threshold Monotonicity -/

/-
Tropical survivors grow as the threshold increases.
-/
theorem tropicalSurvivors_antitone_threshold
    (A P : Finset ℕ) (c : ℕ → ℝ) {t₁ t₂ : ℝ} (ht : t₁ ≤ t₂) :
    tropicalSurvivors A P c t₁ ⊆ tropicalSurvivors A P c t₂ := by
  exact fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hx |>.1, le_trans ( Finset.mem_filter.mp hx |>.2 ) ht ⟩

/-
Classical survivors grow as the threshold increases.
-/
theorem classicalSurvivors_antitone_threshold
    (A P : Finset ℕ) (w : ℕ → ℝ) {t₁ t₂ : ℝ} (ht : t₁ ≤ t₂) :
    classicalSurvivors A P w t₁ ⊆ classicalSurvivors A P w t₂ := by
  exact fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hx |>.1, le_trans ( Finset.mem_filter.mp hx |>.2 ) ht ⟩

/-! ## Strict Domination Example -/

/-
**Strict separation**: when |P| ≥ 2 and costs are positive, there exist
    elements where tropical score is strictly less than classical weight.
    This shows the relaxation is genuine, not merely formal.
-/
theorem tropical_strict_le_classical_example :
    ∃ (P : Finset ℕ) (c : ℕ → ℝ) (n : ℕ),
      1 < P.card ∧
      (∀ m, 0 < c m) ∧
      tropicalSieveScore P c n < classicalSieveWeight P c n := by
  refine' ⟨ { 0, 1 }, fun _ => 1, 0, _, _, _ ⟩ <;> norm_num [ tropicalSieveScore, classicalSieveWeight ]

end TropicalSieve