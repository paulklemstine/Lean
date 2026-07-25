/-
# Tropical Surprise Theory: A Max-Plus Framework for Incongruity

This module develops a rigorous mathematical framework connecting tropical
(max-plus) algebra to the theory of surprise and humor. The central insight
is that selecting the "most surprising interpretation" of an ambiguous stimulus
is a tropical (max) operation, while composing independent surprises is additive —
together these form a semiring structure.

## Main Results

* `surprise_decay_monotone` — Repeated exposure causes monotone surprise decay
* `surprise_tsum` — Total lifetime surprise converges to s₀·(1-r)⁻¹
* `jensen_surprise` — Convexity of -log gives Jensen's inequality for surprise
* `entropy_le_log_card` — Shannon entropy ≤ log(n) (uniform maximizes)
* `klDiv_nonneg` — KL divergence is non-negative (Gibbs' inequality)
* `novelty_familiarity_bound` — p·(-log p) ≤ 1/e (novelty-familiarity duality)

## Novel Concepts

* `SurpriseSpectrum` — Non-negative surprise weight distribution over outcomes
* `NarrativeChain` — Stochastic matrix model of joke delivery
-/

import Mathlib

open Real Set Filter Topology Finset BigOperators

noncomputable section

/-! ## Part 1: Surprise Decay Under Repetition -/

namespace TropicalSurprise

/-- The surprise of the n-th repetition with initial surprise s₀ and decay rate r. -/
def repeatedSurprise (s₀ r : ℝ) (n : ℕ) : ℝ := s₀ * r ^ n

theorem repeatedSurprise_zero (s₀ r : ℝ) : repeatedSurprise s₀ r 0 = s₀ := by
  simp [repeatedSurprise]

theorem repeatedSurprise_succ (s₀ r : ℝ) (n : ℕ) :
    repeatedSurprise s₀ r (n + 1) = r * repeatedSurprise s₀ r n := by
  simp [repeatedSurprise, pow_succ]; ring

/-- **Surprise Decay Monotonicity**: Each repetition is weakly less surprising. -/
theorem surprise_decay_monotone (s₀ r : ℝ) (hs₀ : 0 ≤ s₀) (hr₀ : 0 ≤ r) (hr₁ : r ≤ 1)
    (n : ℕ) : repeatedSurprise s₀ r (n + 1) ≤ repeatedSurprise s₀ r n := by
  simp only [repeatedSurprise, pow_succ]
  calc s₀ * (r ^ n * r) = (s₀ * r ^ n) * r := by ring
    _ ≤ (s₀ * r ^ n) * 1 := by
        apply mul_le_mul_of_nonneg_left hr₁
        exact mul_nonneg hs₀ (pow_nonneg hr₀ n)
    _ = s₀ * r ^ n := by ring

/-- **Geometric Surprise Sum**: Total surprise from n repetitions. -/
theorem surprise_partial_sum (s₀ r : ℝ) (n : ℕ) :
    ∑ i ∈ range n, repeatedSurprise s₀ r i = s₀ * ∑ i ∈ range n, r ^ i := by
  simp only [repeatedSurprise, Finset.mul_sum]

/-- **Surprise Convergence**: Total lifetime surprise converges. -/
theorem surprise_series_summable (s₀ r : ℝ) (hr₀ : 0 ≤ r) (hr₁ : r < 1) :
    Summable (repeatedSurprise s₀ r) :=
  (summable_geometric_of_lt_one hr₀ hr₁).mul_left s₀

/-- The total lifetime surprise equals s₀ · (1 - r)⁻¹. -/
theorem surprise_tsum (s₀ r : ℝ) (hr₀ : 0 ≤ r) (hr₁ : r < 1) :
    ∑' n, repeatedSurprise s₀ r n = s₀ * (1 - r)⁻¹ := by
  simp only [repeatedSurprise]
  rw [tsum_mul_left, tsum_geometric_of_lt_one hr₀ hr₁]

/-! ## Part 2: Convexity of Surprise and Jensen's Inequality -/

/-- Information-theoretic surprise: -log(p) / log(2). -/
def infoSurprise (p : ℝ) : ℝ := -Real.log p / Real.log 2

/-
Surprise is convex on (0, ∞): the function p ↦ -log(p) is convex.
Proved via the second derivative test: d²/dp²(-log p) = 1/p² > 0.
-/
theorem neg_log_convexOn : ConvexOn ℝ (Set.Ioi 0) (fun p : ℝ => -Real.log p) := by
  exact ( StrictConcaveOn.concaveOn <| strictConcaveOn_log_Ioi ).neg

/-
**Jensen's Surprise Inequality**: For a convex combination of probabilities,
the surprise of the mixture ≤ the weighted average of surprises.
-/
theorem jensen_surprise (p q t : ℝ) (hp : 0 < p) (hq : 0 < q)
    (ht₀ : 0 ≤ t) (ht₁ : t ≤ 1) :
    -Real.log (t * p + (1 - t) * q) ≤ t * (-Real.log p) + (1 - t) * (-Real.log q) := by
  convert ConvexOn.map_sum_le ( neg_log_convexOn ) _ _ _ <;> norm_num;
  rotate_left;
  rotate_left;
  exacts [ Fin 2, { 0, 1 }, fun i => if i = 0 then t else 1 - t, fun i => if i = 0 then p else q, by simp +decide [ ht₀, ht₁ ], by simp +decide [ ht₀, ht₁ ], by simp +decide [ hp, hq ], by simp +decide [ Fin.sum_univ_two ], by simp +decide [ Fin.sum_univ_two ] ; ring ]

/-! ## Part 3: Entropy Maximization -/

/-
**Entropy ≤ log(n)**: Shannon entropy of any distribution on n elements
is at most log(n), achieved by the uniform distribution.
This is the information-theoretic foundation: more outcomes = more potential surprise.
-/
theorem entropy_le_log_card (n : ℕ) (hn : 0 < n)
    (p : Fin n → ℝ) (hp_pos : ∀ i, 0 < p i) (hp_sum : ∑ i, p i = 1) :
    -∑ i, p i * Real.log (p i) ≤ Real.log n := by
  -- Apply Jensen's inequality to the concave function $f(x) = \log(x)$ with weights $p_i$.
  have h_jensen : (∑ i, p i * Real.log (1 / p i)) ≤ Real.log (∑ i, p i * (1 / p i)) := by
    have h_jensen : ConcaveOn ℝ (Set.Ioi 0) Real.log := by
      exact ( StrictConcaveOn.concaveOn <| strictConcaveOn_log_Ioi );
    apply_rules [ h_jensen.le_map_sum ];
    · exact fun i _ => le_of_lt ( hp_pos i );
    · exact fun i _ => one_div_pos.mpr ( hp_pos i );
  simp_all +decide [ ne_of_gt ]

/-! ## Part 4: The Surprise Spectrum -/

/-- A **surprise spectrum**: non-negative weight function over outcomes.
This captures the full distribution of surprise values across all possible
interpretations of a stimulus. -/
structure SurpriseSpectrum (α : Type*) [Fintype α] where
  weight : α → ℝ
  weight_nonneg : ∀ a, 0 ≤ weight a

namespace SurpriseSpectrum

variable {α : Type*} [Fintype α]

/-- The total surprise: sum of all weights. -/
def totalSurprise (S : SurpriseSpectrum α) : ℝ := ∑ a, S.weight a

theorem totalSurprise_nonneg (S : SurpriseSpectrum α) : 0 ≤ S.totalSurprise :=
  Finset.sum_nonneg (fun a _ => S.weight_nonneg a)

/-- The maximum surprise in the spectrum (tropical sum). -/
def maxSurprise (S : SurpriseSpectrum α) [Nonempty α] : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty S.weight

theorem le_maxSurprise (S : SurpriseSpectrum α) [Nonempty α] (a : α) :
    S.weight a ≤ S.maxSurprise :=
  Finset.le_sup' S.weight (Finset.mem_univ a)

/-- The max surprise is attained — the funniest interpretation exists. -/
theorem maxSurprise_attained (S : SurpriseSpectrum α) [Nonempty α] :
    ∃ a, S.weight a = S.maxSurprise := by
  obtain ⟨a, _, ha⟩ := Finset.exists_max_image Finset.univ S.weight Finset.univ_nonempty
  exact ⟨a, le_antisymm (le_maxSurprise S a) (Finset.sup'_le _ _ (fun b hb => ha b hb))⟩

/-- **Spectral Bound**: Total surprise ≤ card × max surprise. -/
theorem totalSurprise_le_card_mul_max (S : SurpriseSpectrum α) [Nonempty α] :
    S.totalSurprise ≤ Fintype.card α * S.maxSurprise := by
  unfold totalSurprise
  calc ∑ a, S.weight a
      ≤ ∑ _a : α, S.maxSurprise := Finset.sum_le_sum (fun a _ => le_maxSurprise S a)
    _ = Fintype.card α * S.maxSurprise := by simp [Finset.sum_const, Finset.card_univ]

/-- **Average-Max Inequality**: Average surprise ≤ max surprise. -/
theorem avg_surprise_le_max (S : SurpriseSpectrum α) [Nonempty α]
    (hcard : (0 : ℝ) < Fintype.card α) :
    S.totalSurprise / Fintype.card α ≤ S.maxSurprise := by
  rw [div_le_iff₀ hcard]
  calc S.totalSurprise ≤ ↑(Fintype.card α) * S.maxSurprise := totalSurprise_le_card_mul_max S
    _ = S.maxSurprise * ↑(Fintype.card α) := by ring

/-- **Spectrum Concentration**: The max is attained and dominates all. -/
theorem spectrum_witness (S : SurpriseSpectrum α) [Nonempty α] :
    ∃ a, S.weight a = S.maxSurprise ∧ ∀ b, S.weight b ≤ S.weight a := by
  obtain ⟨a, ha⟩ := maxSurprise_attained S
  exact ⟨a, ha, fun b => ha ▸ le_maxSurprise S b⟩

end SurpriseSpectrum

/-! ## Part 5: Narrative Chains -/

/-- A **narrative transition matrix**: row-stochastic matrix modeling
transitions between narrative states during joke delivery. -/
structure NarrativeChain (n : ℕ) where
  trans : Fin n → Fin n → ℝ
  trans_nonneg : ∀ i j, 0 ≤ trans i j
  trans_stochastic : ∀ i, ∑ j, trans i j = 1

namespace NarrativeChain

variable {n : ℕ}

/-- The surprise of transitioning from state i to state j. -/
def transitionSurprise (M : NarrativeChain n) (i j : Fin n) : ℝ :=
  -Real.log (M.trans i j)

/-- The conditional entropy (expected surprise) from state i. -/
def conditionalEntropy (M : NarrativeChain n) (i : Fin n) : ℝ :=
  ∑ j, M.trans i j * (-Real.log (M.trans i j))

/-- Conditional entropy is non-negative when all transitions are positive. -/
theorem conditionalEntropy_nonneg (M : NarrativeChain n) (i : Fin n)
    (hpos : ∀ j, 0 < M.trans i j) :
    0 ≤ M.conditionalEntropy i := by
  apply Finset.sum_nonneg
  intro j _
  apply mul_nonneg (le_of_lt (hpos j))
  apply neg_nonneg.mpr
  exact Real.log_nonpos (le_of_lt (hpos j))
    (by calc M.trans i j ≤ ∑ k, M.trans i k :=
          Finset.single_le_sum (fun k _ => M.trans_nonneg i k) (Finset.mem_univ j)
        _ = 1 := M.trans_stochastic i)

/-
**Conditional Entropy Bound**: H(X_{t+1}|X_t = i) ≤ log(n).
-/
theorem conditionalEntropy_le_log (M : NarrativeChain n) (hn : 0 < n)
    (i : Fin n) (hpos : ∀ j, 0 < M.trans i j) :
    M.conditionalEntropy i ≤ Real.log n := by
  convert entropy_le_log_card n hn ( fun j => M.trans i j ) ( fun j => hpos j ) ( M.trans_stochastic i ) using 1;
  unfold NarrativeChain.conditionalEntropy; norm_num [ mul_neg ] ;

end NarrativeChain

/-! ## Part 6: Surprise Composition and Max-Plus Structure -/

/-- **Surprise Composition**: Independent surprises compose additively. -/
theorem surprise_additive (p q : ℝ) (hp : 0 < p) (hq : 0 < q) :
    infoSurprise (p * q) = infoSurprise p + infoSurprise q := by
  unfold infoSurprise
  rw [Real.log_mul (ne_of_gt hp) (ne_of_gt hq)]
  ring

/-- **Max-Plus Distributivity**: Max distributes over addition of surprise values.
This is the tropical distributive law: ⊕ distributes over ⊙. -/
theorem max_distributes_over_add (a b c : ℝ) :
    max a b + c = max (a + c) (b + c) := by
  simp [max_add_add_right]

/-- **Surprise Dominance**: The max of two surprise values is at least their average.
The funniest interpretation beats the average interpretation. -/
theorem max_ge_avg (a b : ℝ) : max a b ≥ (a + b) / 2 := by
  rcases le_total a b with h | h
  · simp [max_eq_right h]; linarith
  · simp [max_eq_left h]; linarith

/-! ## Part 7: KL Divergence and Gibbs' Inequality -/

/-- KL divergence between two distributions on a finite type. -/
def klDiv (n : ℕ) (p q : Fin n → ℝ) : ℝ :=
  ∑ i, p i * Real.log (p i / q i)

/-
**KL Non-negativity** (Gibbs' inequality): D_KL(p ‖ q) ≥ 0.
This is the information-theoretic foundation of surprise theory:
any deviation from the reference distribution costs information.
-/
theorem klDiv_nonneg (n : ℕ) (hn : 0 < n)
    (p q : Fin n → ℝ) (hp_pos : ∀ i, 0 < p i) (hq_pos : ∀ i, 0 < q i)
    (hp_sum : ∑ i, p i = 1) (hq_sum : ∑ i, q i = 1) :
    0 ≤ klDiv n p q := by
  unfold klDiv;
  -- Apply Jensen's inequality to the convex function $f(x) = x \log x$.
  have h_jensen : ∑ i, p i * Real.log (p i / q i) ≥ ∑ i, p i * (1 - q i / p i) := by
    have h_jensen : ∀ i, Real.log (p i / q i) ≥ 1 - q i / p i := by
      intro i; have := Real.log_le_sub_one_of_pos ( div_pos ( hq_pos i ) ( hp_pos i ) ) ; simp_all +decide [ ne_of_gt, div_eq_mul_inv ] ;
      rw [ show p i * ( q i ) ⁻¹ = ( q i * ( p i ) ⁻¹ ) ⁻¹ by group, Real.log_inv ] ; linarith;
    exact Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( h_jensen i ) ( le_of_lt ( hp_pos i ) );
  simp_all +decide [ mul_sub, mul_div_cancel₀ _ ( ne_of_gt ( hp_pos _ ) ) ]

/-- KL divergence from a distribution to itself is zero. -/
theorem klDiv_self (n : ℕ) (p : Fin n → ℝ) (hp_pos : ∀ i, 0 < p i) :
    klDiv n p p = 0 := by
  unfold klDiv
  have h : ∀ i, p i / p i = 1 := fun i => div_self (ne_of_gt (hp_pos i))
  simp [h]

/-! ## Part 8: The Novelty–Familiarity Duality

Novelty (surprise) and familiarity (probability) are complementary:
their product p·(-log p) is bounded by 1/e.
This is because x·(-log x) achieves its maximum at x = 1/e.
-/

/-
**Novelty-Familiarity Bound**: p·(-log p) ≤ 1/e for p ∈ (0,1].
The product of familiarity and surprise is universally bounded.
-/
theorem novelty_familiarity_bound (p : ℝ) (hp₀ : 0 < p) (hp₁ : p ≤ 1) :
    p * (-Real.log p) ≤ 1 / Real.exp 1 := by
  have := Real.log_le_sub_one_of_pos ( div_pos ( inv_pos.mpr ( Real.exp_pos 1 ) ) hp₀ );
  rw [ Real.log_div ( by positivity ) ( by positivity ), Real.log_inv, Real.log_exp ] at this ; ring_nf at * ; nlinarith [ inv_pos.mpr ( Real.exp_pos 1 ), mul_inv_cancel₀ ( ne_of_gt ( Real.exp_pos 1 ) ), mul_inv_cancel₀ ( ne_of_gt hp₀ ) ]

/-! ## Part 9: Surprise under Refinement

Splitting an outcome into sub-outcomes increases entropy.
More detailed narratives have more potential for surprise.
-/

/-
**Refinement Increases Entropy**: Splitting outcome p into p₁ + p₂ = p
increases the entropy contribution: -p log p ≤ -p₁ log p₁ - p₂ log p₂.
-/
theorem refinement_increases_entropy (p p₁ p₂ : ℝ)
    (hp₁ : 0 < p₁) (hp₂ : 0 < p₂) (hsum : p₁ + p₂ = p) :
    -(p * Real.log p) ≤ -(p₁ * Real.log p₁) - p₂ * Real.log p₂ := by
  subst p;
  nlinarith [ Real.log_le_log ( by positivity ) ( by linarith : p₁ + p₂ ≥ p₁ ), Real.log_le_log ( by positivity ) ( by linarith : p₁ + p₂ ≥ p₂ ) ]

end TropicalSurprise

/-! ## Axiom Verification -/

#print axioms TropicalSurprise.surprise_decay_monotone
#print axioms TropicalSurprise.surprise_tsum
#print axioms TropicalSurprise.surprise_additive
#print axioms TropicalSurprise.max_distributes_over_add
#print axioms TropicalSurprise.SurpriseSpectrum.totalSurprise_le_card_mul_max
#print axioms TropicalSurprise.klDiv_self
#print axioms TropicalSurprise.NarrativeChain.conditionalEntropy_nonneg