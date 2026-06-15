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
* `degreeEntropy_eq_log_card_iff_regular` — rigidity: regularity ↔ max entropy
* `regularityDeficit_nonneg` — regularity deficit is always ≥ 0
* `degreeEntropy_le_log_card` — degree entropy is at most log|V|
* `spectral_entropy_stability_bridge` — stability-entropy cross-domain bridge

## References

* Shannon, "A Mathematical Theory of Communication" (1948)
* Kullback, Leibler, "On Information and Sufficiency" (1951)
* Collatz, Sinogowitz, "Spektren endlicher Grafen" (1957)
-/

import Mathlib

open Finset BigOperators Real

noncomputable section

set_option linter.unusedSectionVars false

namespace SpectralTropicalEntropy

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Core Definitions -/

/-- Degree function as an explicit `V → ℕ`. -/
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
    D(G) = log|V| - H(G). Vanishes exactly for regular graphs. -/
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

theorem degreeProb_nonneg (v : V) : 0 ≤ degreeProb G v := by
  unfold degreeProb
  apply div_nonneg (Nat.cast_nonneg _) (vol_nonneg G)

theorem degree_le_maxDeg (v : V) : degFun G v ≤ maxDeg G :=
  Finset.le_sup (Finset.mem_univ v)

/-- The degree probabilities sum to 1 when vol(G) > 0. -/
theorem degreeProb_sum_eq_one (hvol : 0 < vol G) :
    ∑ v : V, degreeProb G v = 1 := by
  simp only [degreeProb, ← Finset.sum_div]
  exact div_self (ne_of_gt hvol)

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
  unfold degreeProb avgDegree;
  field_simp;
  exact_mod_cast degree_le_maxDeg G v

/-! ## Theorem C: Regular Graphs Maximize Degree Entropy -/

/-
**Regular graphs maximize degree entropy.**
    If every vertex has degree d > 0, then H(G) = log|V|.
-/
theorem degreeEntropy_eq_log_card_of_regular
    {d : ℕ} (hreg : ∀ v : V, G.degree v = d) (hd : 0 < d)
    (hV : 0 < Fintype.card V) :
    degreeEntropy G = Real.log (Fintype.card V : ℝ) := by
  convert neg_eq_iff_eq_neg.mpr _ using 1;
  unfold degreeProb;
  unfold degFun vol; simp +decide [ hreg, hd.ne', hV.ne' ] ; ring;
  simp +decide [ degFun, hreg, hd.ne', hV.ne', mul_assoc, mul_comm, mul_left_comm ]

/-! ## Theorem B: Regularity Deficit Upper Bound -/

/-
**Regularity deficit is bounded by the max-to-average degree ratio.**
    D(G) ≤ log(Δ/d̄).
-/
theorem regularityDeficit_le_log_maxDeg_div_avgDegree
    (hvol : 0 < vol G)
    (hcard : 0 < Fintype.card V)
    (hmaxDeg : 0 < maxDeg G) :
    regularityDeficit G ≤ Real.log ((maxDeg G : ℝ) / avgDegree G) := by
  -- By definition, $D(G) = \sum_{v} p_v \log(p_v \cdot |V|)$.
  have h_def : regularityDeficit G = ∑ v, degreeProb G v * Real.log (degreeProb G v * (Fintype.card V : ℝ)) := by
    unfold regularityDeficit degreeEntropy;
    -- Apply the logarithm property $\log(ab) = \log(a) + \log(b)$ to each term in the sum.
    have h_log_prop : ∀ v, degreeProb G v * Real.log (degreeProb G v * (Fintype.card V : ℝ)) = degreeProb G v * Real.log (degreeProb G v) + degreeProb G v * Real.log (Fintype.card V : ℝ) := by
      intro v; by_cases hv : degreeProb G v = 0 <;> simp +decide [ hv, Real.log_mul, hcard.ne' ] ; ring;
    simp_all +decide [ Finset.sum_add_distrib, ← Finset.sum_mul _ _ _ ];
    rw [ add_comm, degreeProb_sum_eq_one G hvol ] ; ring;
  -- Since $p_v * |V| \leq \Delta / \bar{d}$, we have $\log(p_v * |V|) \leq \log(\Delta / \bar{d})$.
  have h_log_bound : ∀ v, degreeProb G v * Real.log (degreeProb G v * (Fintype.card V : ℝ)) ≤ degreeProb G v * Real.log ((maxDeg G : ℝ) / avgDegree G) := by
    intro v
    by_cases h_deg_zero : degreeProb G v = 0
    · simp [h_deg_zero]
    ·
      exact mul_le_mul_of_nonneg_left ( Real.log_le_log ( mul_pos ( lt_of_le_of_ne ( degreeProb_nonneg G v ) ( Ne.symm h_deg_zero ) ) ( Nat.cast_pos.mpr hcard ) ) ( by simpa only [ mul_comm ] using degreeProb_mul_card_le G hvol hcard v ) ) ( degreeProb_nonneg G v );
  convert Finset.sum_le_sum fun v _ => h_log_bound v using 1;
  rw [ ← Finset.sum_mul _ _ _, degreeProb_sum_eq_one ] <;> aesop

/-! ## Theorem A: Entropy Lower Bound from Max/Average Degree -/

/-
**Spectral-tropical entropy lower bound.**
    H(G) ≥ log(|V| · d̄ / Δ).
-/
theorem degreeEntropy_lower_bound_avg_max
    (hvol : 0 < vol G)
    (hcard : 0 < Fintype.card V)
    (hmaxDeg : 0 < maxDeg G) :
    Real.log ((Fintype.card V : ℝ) * avgDegree G / (maxDeg G : ℝ)) ≤ degreeEntropy G := by
  convert sub_le_sub_left ( regularityDeficit_le_log_maxDeg_div_avgDegree G hvol hcard hmaxDeg ) ( Real.log ( Fintype.card V : ℝ ) ) using 1;
  · rw [ ← Real.log_div ( by positivity ) ( by exact div_ne_zero ( by positivity ) ( by exact div_ne_zero ( by positivity ) ( Nat.cast_ne_zero.mpr hcard.ne' ) ) ), div_div_eq_mul_div ];
  · unfold regularityDeficit; ring;

/-! ## Cross-Domain Connection: KL Divergence -/

/-
**The regularity deficit is exactly the KL divergence from uniform.**
    D(G) = D_KL(p ‖ u).
-/
theorem regularityDeficit_eq_degreeKLToUniform
    (hvol : 0 < vol G)
    (hcard : 0 < Fintype.card V) :
    regularityDeficit G = degreeKLToUniform G := by
  -- By definition of regularityDeficit and degreeKLToUniform, we can expand both expressions.
  have h_expand : regularityDeficit G = Real.log (Fintype.card V : ℝ) + ∑ v : V, degreeProb G v * Real.log (degreeProb G v) := by
    unfold regularityDeficit degreeEntropy; ring;
  -- By definition of degreeKLToUniform, we can expand it.
  have h_degreeKLToUniform_expand : degreeKLToUniform G = ∑ v : V, degreeProb G v * Real.log (degreeProb G v) - ∑ v : V, degreeProb G v * Real.log (uniformProb V) := by
    rw [ ← Finset.sum_sub_distrib ];
    refine' Finset.sum_congr rfl fun v _ => _;
    by_cases h : degreeProb G v = 0 <;> simp +decide [ h, Real.log_div, uniformProb ];
    rw [ Real.log_mul h ( by positivity ), mul_add ];
  simp_all +decide [ ← Finset.sum_mul _ _ _, degreeProb_sum_eq_one ];
  unfold uniformProb; norm_num [ Real.log_div, hcard.ne' ] ; ring;

/-! ## Spectral Parametric Lower Bound -/

/-- **Spectral parametric lower bound.**
    For any ρ ≤ avgDegree G with ρ > 0, we have H(G) ≥ log(|V| · ρ / Δ). -/
theorem degreeEntropy_lower_bound_spectral_param
    {ρ : ℝ}
    (hvol : 0 < vol G)
    (hcard : 0 < Fintype.card V)
    (hmaxDeg : 0 < maxDeg G)
    (hρ_pos : 0 < ρ)
    (hρ_upper : ρ ≤ avgDegree G) :
    Real.log ((Fintype.card V : ℝ) * ρ / (maxDeg G : ℝ)) ≤ degreeEntropy G := by
  calc Real.log ((Fintype.card V : ℝ) * ρ / (maxDeg G : ℝ))
      ≤ Real.log ((Fintype.card V : ℝ) * avgDegree G / (maxDeg G : ℝ)) := by
        gcongr
    _ ≤ degreeEntropy G := degreeEntropy_lower_bound_avg_max G hvol hcard hmaxDeg

/-! ## Entropy Upper Bound and Regularity Deficit Nonnegativity -/

/-
**Degree entropy is at most log|V|.**
-/
theorem degreeEntropy_le_log_card
    (hvol : 0 < vol G)
    (hcard : 0 < Fintype.card V) :
    degreeEntropy G ≤ Real.log (Fintype.card V : ℝ) := by
  have h_deg_entropy_le_log_card : ∑ v : V, degreeProb G v * Real.log (degreeProb G v / uniformProb V) ≥ 0 := by
    have h_nonneg : ∀ v : V, degreeProb G v * Real.log (degreeProb G v / uniformProb V) ≥ degreeProb G v - uniformProb V := by
      intro v
      by_cases h_pos : 0 < degreeProb G v;
      · have h_nonneg : Real.log (degreeProb G v / uniformProb V) ≥ 1 - uniformProb V / degreeProb G v := by
          have h_nonneg : ∀ x : ℝ, 0 < x → Real.log x ≥ 1 - 1 / x := by
            exact fun x x_pos => by have := Real.log_le_sub_one_of_pos ( inv_pos.mpr x_pos ) ; norm_num at * ; linarith;
          simpa using h_nonneg ( degreeProb G v / uniformProb V ) ( div_pos h_pos ( one_div_pos.mpr ( Nat.cast_pos.mpr hcard ) ) );
        nlinarith [ mul_div_cancel₀ ( uniformProb V ) h_pos.ne' ];
      · simp_all +decide [ degreeProb, uniformProb ];
    refine' le_trans _ ( Finset.sum_le_sum fun v _ => h_nonneg v );
    simp +decide [ degreeProb_sum_eq_one G hvol, uniformProb ];
    exact div_self_le_one _;
  unfold degreeEntropy;
  simp_all +decide [ Real.log_div, degreeProb, uniformProb ];
  have h_split : ∑ x : V, (degFun G x : ℝ) / vol G * Real.log ((degFun G x : ℝ) / vol G * (Fintype.card V : ℝ)) = ∑ x : V, (degFun G x : ℝ) / vol G * (Real.log ((degFun G x : ℝ) / vol G) + Real.log (Fintype.card V : ℝ)) := by
    refine' Finset.sum_congr rfl fun x _ => _;
    by_cases hx : degFun G x = 0 <;> simp_all +decide [ Real.log_mul, ne_of_gt ];
  simp_all +decide [ mul_add, Finset.sum_add_distrib ];
  simp_all +decide [ ← Finset.sum_mul _ _ _, ← Finset.sum_div, vol ];
  rw [ div_self ] at h_deg_entropy_le_log_card <;> linarith

/-- **Regularity deficit is nonneg.** D(G) ≥ 0. -/
theorem regularityDeficit_nonneg
    (hvol : 0 < vol G)
    (hcard : 0 < Fintype.card V) :
    0 ≤ regularityDeficit G := by
  unfold regularityDeficit
  linarith [degreeEntropy_le_log_card G hvol hcard]

/-! ## Theorem D: Entropy Rigidity -/

/-- **Forward direction of rigidity: regular implies max entropy.** -/
theorem degreeEntropy_eq_log_card_of_exists_regular
    (hvol : 0 < vol G)
    (hcard : 0 < Fintype.card V)
    (hreg : ∃ d : ℕ, ∀ v : V, G.degree v = d) :
    degreeEntropy G = Real.log (Fintype.card V : ℝ) := by
  obtain ⟨d, hd⟩ := hreg
  apply degreeEntropy_eq_log_card_of_regular G hd
  · contrapose! hvol
    interval_cases d
    simp [vol, degFun, hd]
  · exact hcard

/-
**Backward direction of rigidity: max entropy implies regular.**
-/
theorem exists_regular_of_degreeEntropy_eq_log_card
    (hvol : 0 < vol G)
    (hcard : 0 < Fintype.card V)
    (hent : degreeEntropy G = Real.log (Fintype.card V : ℝ)) :
    ∃ d : ℕ, ∀ v : V, G.degree v = d := by
  -- By definition of degreeEntropy, we know that degreeKLToUniform G = 0.
  have hkl_zero : degreeKLToUniform G = 0 := by
    rw [ ← regularityDeficit_eq_degreeKLToUniform G hvol hcard, regularityDeficit, hent, sub_self ];
  -- By definition of degreeKLToUniform, we know that each term in the sum is nonnegative.
  have hkl_nonneg : ∀ v : V, degreeProb G v * Real.log (degreeProb G v / uniformProb V) ≥ degreeProb G v - uniformProb V := by
    intro v
    by_cases hv : degreeProb G v = 0;
    · simp [hv];
      exact div_nonneg zero_le_one ( Nat.cast_nonneg _ );
    · have hkl_nonneg : ∀ x y : ℝ, 0 < x → 0 < y → x * Real.log (x / y) ≥ x - y := by
        intros x y hx hy; rw [ Real.log_div hx.ne' hy.ne' ] ; ring_nf; (
        have := Real.log_le_sub_one_of_pos ( div_pos hy hx ) ; rw [ Real.log_div hy.ne' hx.ne' ] at this; nlinarith [ mul_div_cancel₀ y hx.ne' ] ;);
      exact hkl_nonneg _ _ ( lt_of_le_of_ne ( degreeProb_nonneg G v ) ( Ne.symm hv ) ) ( one_div_pos.mpr ( Nat.cast_pos.mpr hcard ) );
  -- Since $\sum_{v} (degreeProb G v - uniformProb V) = 0$, we have $degreeProb G v = uniformProb V$ for all $v$.
  have h_eq : ∀ v : V, degreeProb G v = uniformProb V := by
    have h_eq : ∀ v : V, degreeProb G v * Real.log (degreeProb G v / uniformProb V) = degreeProb G v - uniformProb V := by
      have hkl_zero_terms : ∑ v : V, (degreeProb G v * Real.log (degreeProb G v / uniformProb V) - (degreeProb G v - uniformProb V)) = 0 := by
        simp_all +decide [ degreeKLToUniform ];
        rw [ show uniformProb V = 1 / ( Fintype.card V : ℝ ) by rfl, mul_div_cancel₀ _ ( by positivity ), degreeProb_sum_eq_one ] ; aesop;
        exact hvol;
      exact fun v => le_antisymm ( by contrapose! hkl_zero_terms; exact ne_of_gt ( lt_of_lt_of_le ( by aesop ) ( Finset.single_le_sum ( fun v _ => sub_nonneg_of_le ( hkl_nonneg v ) ) ( Finset.mem_univ v ) ) ) ) ( hkl_nonneg v );
    intro v
    by_contra h_neq
    have h_pos : 0 < degreeProb G v := by
      by_cases h_deg_zero : degFun G v = 0;
      · specialize h_eq v; simp_all +decide [ degreeProb, uniformProb ] ;
      · exact div_pos ( Nat.cast_pos.mpr ( Nat.pos_of_ne_zero h_deg_zero ) ) hvol
    have h_pos_uniform : 0 < uniformProb V := by
      exact one_div_pos.mpr ( Nat.cast_pos.mpr hcard )
    have h_log_pos : Real.log (degreeProb G v / uniformProb V) > 1 - uniformProb V / degreeProb G v := by
      have h_log_pos : ∀ x : ℝ, 0 < x → x ≠ 1 → Real.log x > 1 - 1 / x := by
        exact fun x x_pos x_ne => by have := Real.log_lt_sub_one_of_pos ( inv_pos.mpr x_pos ) ( by aesop ) ; norm_num at * ; linarith;
      simpa using h_log_pos ( degreeProb G v / uniformProb V ) ( div_pos h_pos h_pos_uniform ) ( div_ne_one_of_ne h_neq )
    have h_contra : degreeProb G v * Real.log (degreeProb G v / uniformProb V) > degreeProb G v - uniformProb V := by
      nlinarith [ mul_div_cancel₀ ( uniformProb V ) h_pos.ne' ]
    exact absurd h_contra (by linarith [h_eq v]);
  unfold degreeProb uniformProb at h_eq;
  use (vol G) / (Fintype.card V) |> Nat.floor;
  intro v; specialize h_eq v; rw [ div_eq_div_iff ] at h_eq <;> norm_cast at * <;> simp_all +decide [ vol ] ;
  · rw [ ← h_eq, mul_div_cancel_right₀ _ ( by positivity ), Nat.floor_natCast ] ; rfl;
  · linarith;
  · linarith

/-- **Full entropy rigidity theorem (iff).**
    For a graph with positive volume, H(G) = log|V| iff G is regular. -/
theorem degreeEntropy_eq_log_card_iff_regular
    (hvol : 0 < vol G)
    (hcard : 0 < Fintype.card V) :
    degreeEntropy G = Real.log (Fintype.card V : ℝ) ↔
      ∃ d : ℕ, ∀ v : V, G.degree v = d := by
  exact ⟨exists_regular_of_degreeEntropy_eq_log_card G hvol hcard,
         degreeEntropy_eq_log_card_of_exists_regular G hvol hcard⟩

/-- **Regularity deficit vanishes exactly for regular graphs.** -/
theorem regularityDeficit_eq_zero_iff_regular
    (hvol : 0 < vol G)
    (hcard : 0 < Fintype.card V) :
    regularityDeficit G = 0 ↔ ∃ d : ℕ, ∀ v : V, G.degree v = d := by
  unfold regularityDeficit
  constructor
  · intro h
    exact (degreeEntropy_eq_log_card_iff_regular G hvol hcard).mp (by linarith)
  · intro h
    have := (degreeEntropy_eq_log_card_iff_regular G hvol hcard).mpr h
    linarith

/-! ## Stability-Entropy Cross-Domain Bridge -/

/-
**Cross-domain bridge theorem.**
    If every vertex has degree ≤ D, then H(G) ≥ log(|V| · d̄ / D).
    This connects the `Stability.lean` file's `GraphMaxDegreeLE` predicate
    to our entropy theory: bounded tropical stability constant implies
    an entropy floor.
-/
theorem spectral_entropy_stability_bridge
    (D : ℕ) (hD : ∀ v : V, G.degree v ≤ D)
    (hvol : 0 < vol G) (hcard : 0 < Fintype.card V)
    (hDpos : 0 < D) :
    Real.log ((Fintype.card V : ℝ) * avgDegree G / (D : ℝ)) ≤ degreeEntropy G := by
  -- Since `maxDeg G ≤ D`, we can apply the inequality `degreeEntropy_lower_bound_avg_max` with `maxDeg G` replaced by `D`.
  have h_maxDegree_le_D : maxDeg G ≤ D := by
    exact Finset.sup_le fun v _ => hD v;
  refine' le_trans _ ( degreeEntropy_lower_bound_avg_max G hvol hcard _ );
  · gcongr;
    · exact div_pos ( mul_pos ( Nat.cast_pos.mpr hcard ) ( div_pos hvol ( Nat.cast_pos.mpr hcard ) ) ) ( Nat.cast_pos.mpr hDpos );
    · exact mul_nonneg ( Nat.cast_nonneg _ ) ( div_nonneg hvol.le ( Nat.cast_nonneg _ ) );
    · contrapose! hvol;
      simp_all +decide [ maxDeg ];
      exact Finset.sum_nonpos fun v _ => by simpa [ degFun ] using hvol v |> le_of_eq;
  · contrapose! hvol; simp_all +decide [ vol ] ;
    exact Finset.sum_nonpos fun v _ => mod_cast le_trans ( Finset.le_sup ( f := degFun G ) ( Finset.mem_univ v ) ) hvol.le

end SpectralTropicalEntropy
end