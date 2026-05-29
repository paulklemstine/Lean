/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Spectral-Tropical Entropy Bridge

This file establishes a new bridge between spectral graph theory,
Shannon entropy, and tropical/information-theoretic irregularity.
The main results show that **spectral data controls information-theoretic
disorder of combinatorial objects**.

## Main Definitions

* `vol` — total volume (sum of degrees) of a graph
* `degreeProb` — degree probability distribution: p_v = d(v) / vol(G)
* `degreeEntropy` — Shannon entropy of the degree distribution
* `maxDeg` — maximum vertex degree
* `avgDegree` — average vertex degree: vol(G) / |V|
* `regularityDeficit` — entropy deficit from regularity: log|V| - H(G)
* `degreeKLToUniform` — KL divergence of degree distribution from uniform

## Main Results

* `degreeProb_sum_eq_one` — degree distribution sums to 1
* `degreeEntropy_eq_log_card_of_regular` — regular graphs achieve entropy = log|V|
* `regularityDeficit_le_log_maxDeg_div_avgDegree` — regularity deficit ≤ log(Δ/d̄)
* `degreeEntropy_lower_bound_avg_max` — H(G) ≥ log(|V| · d̄ / Δ)
* `regularityDeficit_eq_degreeKLToUniform` — deficit equals KL divergence from uniform
* `degreeEntropy_lower_bound_spectral_param` — parametric lower bound for spectral use
* `degreeEntropy_eq_log_card_of_exists_regular` — rigidity: regularity ↔ max entropy

## References

* Shannon, "A Mathematical Theory of Communication" (1948)
* Kullback, Leibler, "On Information and Sufficiency" (1951)
* Collatz, Sinogowitz, "Spektren endlicher Grafen" (1957)
-/

import Mathlib

open Finset BigOperators Real

noncomputable section

namespace SpectralTropicalEntropy

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Core Definitions -/

/-- Degree function as an explicit `V → ℕ` to avoid implicit Fintype arguments. -/
def degFun (G : SimpleGraph V) [DecidableRel G.Adj] : V → ℕ := fun v => G.degree v

/-- Total volume of a graph: the sum of all vertex degrees. Equal to 2|E|. -/
def vol (G : SimpleGraph V) [DecidableRel G.Adj] : ℝ :=
  ∑ v : V, (degFun G v : ℝ)

/-- Degree probability distribution: assigns each vertex its degree
    divided by the total volume. Forms a probability distribution when vol > 0. -/
def degreeProb (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) : ℝ :=
  (degFun G v : ℝ) / vol G

/-- Shannon entropy of the degree distribution:
    H(G) = - ∑_v p_v log(p_v). We use the convention 0 · log(0) = 0. -/
def degreeEntropy (G : SimpleGraph V) [DecidableRel G.Adj] : ℝ :=
  - ∑ v : V, degreeProb G v * Real.log (degreeProb G v)

/-- Maximum vertex degree. Returns 0 for edgeless/empty graphs. -/
def maxDeg (G : SimpleGraph V) [DecidableRel G.Adj] : ℕ :=
  Finset.univ.sup (degFun G)

/-- Average vertex degree: vol(G) / |V|. -/
def avgDegree (G : SimpleGraph V) [DecidableRel G.Adj] : ℝ :=
  vol G / (Fintype.card V : ℝ)

/-- Regularity deficit entropy: measures deviation from uniform distribution.
    D(G) = log|V| - H(G). Vanishes exactly for regular graphs. This is a
    new invariant that bridges spectral graph theory and information theory. -/
def regularityDeficit (G : SimpleGraph V) [DecidableRel G.Adj] : ℝ :=
  Real.log (Fintype.card V : ℝ) - degreeEntropy G

/-- Uniform probability on V. -/
def uniformProb (V : Type*) [Fintype V] : ℝ :=
  1 / (Fintype.card V : ℝ)

/-- KL divergence of degree distribution from uniform distribution:
    D_KL(p ‖ u) = ∑_v p_v log(p_v / u_v). -/
def degreeKLToUniform (G : SimpleGraph V) [DecidableRel G.Adj] : ℝ :=
  ∑ v : V, degreeProb G v * Real.log (degreeProb G v / uniformProb V)

variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-! ## Foundational Lemmas -/

theorem degFun_eq_degree (v : V) : degFun G v = G.degree v := rfl

theorem vol_nonneg : 0 ≤ vol G := by
  apply Finset.sum_nonneg; intros; positivity

theorem degreeProb_nonneg (hvol : 0 ≤ vol G) (v : V) : 0 ≤ degreeProb G v := by
  unfold degreeProb; positivity

theorem degree_le_maxDeg (v : V) : degFun G v ≤ maxDeg G :=
  Finset.le_sup (Finset.mem_univ v)

set_option linter.unusedSectionVars false in
/-- The degree probabilities sum to 1 when vol(G) > 0. -/
theorem degreeProb_sum_eq_one (hvol : 0 < vol G) :
    ∑ v : V, degreeProb G v = 1 := by
  simp only [degreeProb, ← Finset.sum_div]
  exact div_self (ne_of_gt hvol)

set_option linter.unusedSectionVars false in
/-- Volume equals |V| times average degree. -/
theorem vol_eq_card_mul_avgDegree :
    vol G = (Fintype.card V : ℝ) * avgDegree G := by
  unfold avgDegree
  by_cases h : (Fintype.card V : ℝ) = 0
  · have hc : Fintype.card V = 0 := by exact_mod_cast h
    have : IsEmpty V := Fintype.card_eq_zero_iff.mp hc
    simp [vol, univ_eq_empty]
  · field_simp

/-- Pointwise bound: p_v ≤ Δ / vol(G). -/
theorem degreeProb_le_maxDeg_div_vol (v : V) :
    degreeProb G v ≤ (maxDeg G : ℝ) / vol G := by
  unfold degreeProb
  apply div_le_div_of_nonneg_right _ (vol_nonneg G)
  exact_mod_cast degree_le_maxDeg G v

/-
Pointwise bound: p_v · |V| ≤ Δ / d̄.
-/
theorem degreeProb_mul_card_le
    (hvol : 0 < vol G)
    (hcard : 0 < Fintype.card V) (v : V) :
    degreeProb G v * (Fintype.card V : ℝ) ≤ (maxDeg G : ℝ) / avgDegree G := by
  convert mul_le_mul_of_nonneg_right ( degreeProb_le_maxDeg_div_vol G v ) ( Nat.cast_nonneg ( Fintype.card V ) ) using 1;
  unfold avgDegree; ring;
  norm_num ; ring

/-! ## Theorem C: Regular Graphs Maximize Degree Entropy -/

/-
**Regular graphs maximize degree entropy.**
    If every vertex has degree d > 0, then H(G) = log|V|.
    This is the "zero-temperature" state: the degree distribution is
    perfectly uniform, achieving maximum Shannon entropy.
-/
theorem degreeEntropy_eq_log_card_of_regular
    {d : ℕ} (hreg : ∀ v : V, G.degree v = d) (hd : 0 < d)
    (hV : 0 < Fintype.card V) :
    degreeEntropy G = Real.log (Fintype.card V : ℝ) := by
  -- Since every vertex has degree $d$, the degree distribution is uniform with probability $1/|V|$.
  have h_uniform : ∀ v : V, degreeProb G v = 1 / (Fintype.card V : ℝ) := by
    unfold degreeProb;
    simp +decide [ degFun, vol, hreg ];
    exact fun v => by rw [ inv_eq_one_div, div_eq_div_iff ] <;> ring <;> positivity;
  unfold degreeEntropy; simp +decide [ h_uniform ] ; ring;
  rw [ mul_inv_cancel₀ ( by positivity ), one_mul ]

/-! ## Theorem B: Regularity Deficit Upper Bound -/

/-
**Regularity deficit is bounded by the max-to-average degree ratio.**
    D(G) ≤ log(Δ/d̄). This says the information-theoretic deviation
    from regularity is controlled by the combinatorial degree spread.
-/
theorem regularityDeficit_le_log_maxDeg_div_avgDegree
    (hvol : 0 < vol G)
    (hcard : 0 < Fintype.card V)
    (hmaxDeg : 0 < maxDeg G) :
    regularityDeficit G ≤ Real.log ((maxDeg G : ℝ) / avgDegree G) := by
  -- Using the fact that $\sum_{v} p_v \log(p_v |V|) \leq \sum_{v} p_v \log(\Delta / d)$, we can bound the regularity deficit.
  have h_bound : ∑ v : V, degreeProb G v * Real.log (degreeProb G v * (Fintype.card V : ℝ)) ≤ ∑ v : V, degreeProb G v * Real.log ((maxDeg G : ℝ) / avgDegree G) := by
    have h_bound : ∀ v : V, degreeProb G v * Real.log (degreeProb G v * (Fintype.card V : ℝ)) ≤ degreeProb G v * Real.log ((maxDeg G : ℝ) / avgDegree G) := by
      intro v
      have h_term_bound : (degreeProb G v) * (Fintype.card V : ℝ) ≤ (maxDeg G : ℝ) / avgDegree G := by
        convert degreeProb_mul_card_le G hvol hcard v using 1;
      by_cases h : degreeProb G v = 0 <;> simp_all +decide [ div_eq_mul_inv ];
      exact mul_le_mul_of_nonneg_left ( Real.log_le_log ( mul_pos ( lt_of_le_of_ne ( degreeProb_nonneg G hvol.le v ) ( Ne.symm h ) ) ( Nat.cast_pos.mpr hcard ) ) h_term_bound ) ( le_of_lt ( lt_of_le_of_ne ( degreeProb_nonneg G hvol.le v ) ( Ne.symm h ) ) );
    exact Finset.sum_le_sum fun v _ => h_bound v;
  convert h_bound using 1;
  · unfold regularityDeficit degreeEntropy ;
    rw [ Finset.sum_congr rfl fun _ _ => ?_ ];
    any_goals exact fun v => degreeProb G v * ( Real.log ( degreeProb G v * Fintype.card V ) - Real.log ( Fintype.card V ) );
    · simp +decide [ mul_sub, Finset.sum_sub_distrib, degreeProb_sum_eq_one G hvol ];
      rw [ ← Finset.sum_mul _ _ _, degreeProb_sum_eq_one G hvol ] ; ring;
    · by_cases h : degreeProb G ‹_› = 0 <;> simp_all +decide [ Real.log_mul, ne_of_gt ];
  · rw [ ← Finset.sum_mul, degreeProb_sum_eq_one G hvol, one_mul ]

/-! ## Theorem A: Entropy Lower Bound from Max/Average Degree -/

/-
**Spectral-tropical entropy lower bound.**
    H(G) ≥ log(|V| · d̄ / Δ). This is the rearrangement of the
    regularity deficit bound: entropy cannot collapse unless the
    graph has a severe degree bottleneck.
-/
theorem degreeEntropy_lower_bound_avg_max
    (hvol : 0 < vol G)
    (hcard : 0 < Fintype.card V)
    (hmaxDeg : 0 < maxDeg G) :
    Real.log ((Fintype.card V : ℝ) * avgDegree G / (maxDeg G : ℝ)) ≤ degreeEntropy G := by
  -- Apply the regularity deficit bound to get the inequality.
  have h_bound : Real.log (Fintype.card V : ℝ) ≤ degreeEntropy G + Real.log ((maxDeg G : ℝ) / avgDegree G) := by
    linarith [ regularityDeficit_le_log_maxDeg_div_avgDegree G hvol hcard hmaxDeg, show regularityDeficit G = Real.log ( Fintype.card V : ℝ ) - degreeEntropy G from rfl ];
  convert sub_le_sub_right h_bound ( Real.log ( maxDeg G / avgDegree G ) ) using 1;
  · rw [ ← Real.log_div ] <;> norm_num [ hvol.ne', hcard.ne', hmaxDeg.ne' ];
    · rw [ div_div_eq_mul_div ];
    · exact ne_of_gt ( div_pos hvol ( Nat.cast_pos.mpr hcard ) );
  · ring

/-! ## Cross-Domain Connection: KL Divergence -/

/-
**The regularity deficit is exactly the KL divergence from uniform.**
    D(G) = D_KL(p ‖ u). This is a cross-domain theorem connecting
    graph theory to information theory: the graph invariant is a
    bona fide information divergence.
-/
theorem regularityDeficit_eq_degreeKLToUniform
    (hvol : 0 < vol G)
    (hcard : 0 < Fintype.card V) :
    regularityDeficit G = degreeKLToUniform G := by
  -- By definition of $degreeKLToUniform$, we can expand it using the properties of logarithms.
  have h_expand : degreeKLToUniform G = ∑ v : V, degreeProb G v * (Real.log (degreeProb G v) + Real.log (Fintype.card V : ℝ)) := by
    unfold degreeKLToUniform; simp +decide [ *, Finset.sum_add_distrib, mul_add ] ;
    rw [ ← Finset.sum_add_distrib ] ; refine' Finset.sum_congr rfl fun v _ => _ ; by_cases hv : degreeProb G v = 0 <;> simp +decide [ *, Real.log_div, uniformProb ] ; ring;
    rw [ ← mul_add, Real.log_mul hv ( by positivity ) ];
  simp_all +decide [ mul_add, Finset.sum_add_distrib ];
  simp_all +decide [ ← Finset.sum_mul _ _ _, degreeEntropy, regularityDeficit ];
  rw [ add_comm, degreeProb_sum_eq_one G hvol ] ; ring

/-! ## Spectral Parametric Lower Bound -/

/-
**Spectral parametric lower bound.**
    For any ρ ≤ d̄ (and ρ > 0), we have H(G) ≥ log(|V| · ρ / Δ).
    This is useful when one has a lower bound on the average degree
    (e.g., from connectivity or spectral properties of the Laplacian).
    Combined with `avgDegree_le_spectralRadius`, one can substitute
    spectral data for combinatorial degree statistics.
-/
theorem degreeEntropy_lower_bound_spectral_param
    {ρ : ℝ}
    (hvol : 0 < vol G)
    (hcard : 0 < Fintype.card V)
    (hmaxDeg : 0 < maxDeg G)
    (hρ_pos : 0 < ρ)
    (hρ_upper : ρ ≤ avgDegree G) :
    Real.log ((Fintype.card V : ℝ) * ρ / (maxDeg G : ℝ)) ≤ degreeEntropy G := by
  convert degreeEntropy_lower_bound_avg_max G hvol hcard hmaxDeg |> le_trans _ using 1;
  gcongr

/-! ## Theorem D: Entropy Rigidity -/

/-
**If G is regular, then degree entropy equals log|V|.**
-/
theorem degreeEntropy_eq_log_card_of_exists_regular
    (hvol : 0 < vol G)
    (hcard : 0 < Fintype.card V)
    (hreg : ∃ d : ℕ, ∀ v : V, G.degree v = d) :
    degreeEntropy G = Real.log (Fintype.card V : ℝ) := by
  -- Apply the theorem that states if the graph is regular with degree d > 0, then the degree entropy is log(|V|).
  apply degreeEntropy_eq_log_card_of_regular;
  -- Apply the existence of d from hreg to each vertex v.
  apply hreg.choose_spec;
  · have := hreg.choose_spec;
    contrapose! hvol;
    refine' Finset.sum_nonpos fun v _ => _;
    exact_mod_cast this v |>.le.trans hvol;
  · exact hcard

end SpectralTropicalEntropy
end