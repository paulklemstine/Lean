/-
# Cross-domain bridge: extremal density (Turán/Mantel) ⋈ semi-induced star separation

This file connects three strands:

* **Extremal graph theory** (the circle of ideas in `Catalog/Applications/ExtremalGraph/Turan.lean`,
  domain *Applications*): Mantel's theorem, the `r = 2` Turán bound, here obtained directly from
  Mathlib's `SimpleGraph.CliqueFree.card_edgeFinset_le`.  A triangle-free graph has edge density
  `ρ ≤ 1/2`.
* **Convexity / information geometry** (the Bregman-divergence nonnegativity of
  `Catalog/Geometry/Convergence.lean`, domain *Geometry*): we restate `bregmanDiv_nonneg` and use it
  (with the convex generator `x ↦ x²`) to certify the Jensen/variance bound `ρ(1-ρ) ≤ 1/4`.
* **Semi-induced stars** (`SemiInducedStars.Basic`, this work): the split construction strictly
  beats the quasi-clique/quasi-star envelope on `(0,(√5-1)/2)`.

The bridge theorem `triangleFree_split_beats_envelope` combines them: the extremal triangle-free
edge density `ρ` lands in the envelope-suboptimality regime `(0,(√5-1)/2)`, so at that density the
semi-induced minimum is strictly below the envelope, *and* the convexity bound `ρ(1-ρ) ≤ 1/4` holds.

-- !-- Lab Notes -- !--
BRIDGE MANDATE.  Domains combined:
  • Applications / ExtremalGraph  — Mantel/Turán edge bound (`Catalog/Applications/ExtremalGraph/Turan.lean`),
    realised here via `SimpleGraph.CliqueFree.card_edgeFinset_le` (r = 2): `4·e(G) ≤ n²`.
  • Geometry — Bregman divergence nonnegativity (`Catalog/Geometry/Convergence.lean`,
    theorem `bregmanDiv_nonneg`), restated as `bregmanDiv_nonneg'` and applied to `ψ(x)=x²`.
NEW CONNECTION.  The Turán extremal density `ρ = 2e/n² ≤ 1/2` is shown to lie strictly inside the
golden interval `(0,(√5-1)/2)` on which the split graphon beats the quasi-clique/quasi-star
envelope (`SemiInducedStars.splitVal_lt_envelope`).  Thus, for *every* triangle-free host graph,
the naive endpoint envelope over-estimates the semi-induced `S_{k,1}` minimum — an extremal-graph /
inducibility link not present in either source file.  The convexity certificate `ρ(1-ρ) ≤ 1/4`
(Geometry) measures the slack of the uniform-degree (constant) graphon.

HYPOTHESIS/EXPERIMENT/ANALYSIS/CRITIQUE/SYNTHESIS are recorded in `Basic.lean`; here the loop's
Critique step additionally checked that the Mantel cast `4e ≤ n²  ⟹  2e/n² ≤ 1/2` needs `n > 0`,
which holds because a positive edge count forces a nonempty vertex type.
-/

import Mathlib
import Catalog.Applications.SemiInducedStars.Basic

namespace SemiInducedStars

open scoped Real
open Finset

/-! ### Geometry domain: Bregman divergence nonnegativity (restated). -/

/-- **Bregman divergence nonnegativity** (after `Catalog/Geometry/Convergence.lean`).
If `ψ` satisfies the first-order convexity inequality, its Bregman divergence is `≥ 0`. -/
theorem bregmanDiv_nonneg' {d : ℕ} (ψ : (Fin d → ℝ) → ℝ) (gradψ : (Fin d → ℝ) → (Fin d → ℝ))
    (hconv : ∀ x y, ψ x ≥ ψ y + ∑ i : Fin d, gradψ y i * (x i - y i)) (x y : Fin d → ℝ) :
    0 ≤ ψ x - ψ y - ∑ i : Fin d, gradψ y i * (x i - y i) := by
  linarith [hconv x y]

/-
The Jensen / variance bound `ρ(1-ρ) ≤ 1/4`, derived from `bregmanDiv_nonneg'` applied to the
convex generator `x ↦ x²` at the points `ρ` and `1/2`.
-/
lemma density_mul_one_sub_le_quarter (ρ : ℝ) : ρ * (1 - ρ) ≤ 1 / 4 := by
  -- Routed through the Geometry-domain Bregman lemma with the convex generator `x ↦ x²`.
  have h := bregmanDiv_nonneg' (d := 1) (fun v => (v 0) ^ 2) (fun v => fun _ => 2 * v 0)
    (by intro x y; simp; nlinarith [sq_nonneg (x 0 - y 0)]) (fun _ => ρ) (fun _ => 1 / 2)
  simp at h
  nlinarith [h]

/-! ### Applications / ExtremalGraph domain: Mantel's theorem from Mathlib. -/

/-
**Mantel's theorem (integer form).** A triangle-free finite graph on `n` vertices has
`4·e(G) ≤ n²`.  Derived from `SimpleGraph.CliqueFree.card_edgeFinset_le` at `r = 2`.
-/
theorem mantel_edge_bound {V : Type*} [Fintype V] [DecidableEq V] (G : SimpleGraph V)
    [DecidableRel G.Adj] (hG : G.CliqueFree 3) :
    4 * G.edgeFinset.card ≤ (Fintype.card V) ^ 2 := by
  have h_card : G.edgeFinset.card ≤ (Fintype.card V^2 - (Fintype.card V % 2)^2) / 4 := by
    convert SimpleGraph.CliqueFree.card_edgeFinset_le ( G := G ) ( r := 2 ) _ using 1 <;> norm_num [ hG ];
    cases Nat.mod_two_eq_zero_or_one ( Fintype.card V ) <;> simp +decide [ * ];
  exact le_trans ( Nat.mul_le_mul_left _ h_card ) ( Nat.mul_div_le _ _ |> le_trans <| Nat.sub_le _ _ )

/-! ### The bridge. -/

/-
**Cross-domain bridge.**  For any triangle-free finite graph `G` with at least one edge, its
graphon edge density `ρ = 2e/n²` satisfies `0 < ρ ≤ 1/2`, lies in the golden interval
`(0,(√5-1)/2)`, obeys the convexity bound `ρ(1-ρ) ≤ 1/4`, and — for every `k ≥ 1` — the
split-graphon semi-induced `S_{k,1}` value at density `ρ` is strictly below the quasi-clique /
quasi-star envelope.  Hence on every triangle-free host the naive envelope over-estimates the
semi-induced minimum.
-/
theorem triangleFree_split_beats_envelope {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (hG : G.CliqueFree 3)
    (hE : 0 < G.edgeFinset.card) {k : ℕ} (hk : 1 ≤ k) :
    let ρ : ℝ := 2 * G.edgeFinset.card / (Fintype.card V) ^ 2
    0 < ρ ∧ ρ ≤ 1 / 2 ∧ ρ * (1 - ρ) ≤ 1 / 4 ∧ splitVal k ρ < envelope k ρ := by
  have := mantel_edge_bound G hG;
  refine' ⟨ _, _, _, _ ⟩;
  · exact div_pos ( mul_pos zero_lt_two ( Nat.cast_pos.mpr hE ) ) ( sq_pos_of_pos ( Nat.cast_pos.mpr ( Nat.pos_of_ne_zero ( by aesop_cat ) ) ) );
  · rw [ div_le_div_iff₀ ] <;> norm_cast <;> nlinarith;
  · exact density_mul_one_sub_le_quarter _;
  · apply splitVal_lt_envelope hk;
    · exact div_pos ( mul_pos zero_lt_two ( Nat.cast_pos.mpr hE ) ) ( sq_pos_of_pos ( Nat.cast_pos.mpr ( Fintype.card_pos_iff.mpr ( by contrapose! hE; aesop ) ) ) );
    · rw [ div_lt_iff₀ ];
      · nlinarith only [ show ( 4 : ℝ ) * #G.edgeFinset ≤ Fintype.card V ^ 2 by exact_mod_cast this, show ( #G.edgeFinset : ℝ ) ≥ 1 by exact_mod_cast hE, Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ];
      · exact_mod_cast this.trans_lt' ( mul_pos zero_lt_four hE )

end SemiInducedStars