/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Tournament Bracket Certified Robustness

This file proves the main certified robustness theorems for tournament-style
multiclass classification with piecewise-linear / tropical score maps.

The key insight is that tournament (bracket) semantics differs from flat argmax:
robustness depends only on the sparse chain of comparisons traversed by the
champion, not on all pairwise class gaps. This yields a structurally sharper
certification condition with logarithmically many active constraints.

## Main Results

- `score_gap_positive_on_ball`: one-step comparison stability from Lipschitz gap
- `bracket_winner_const_of_recursive_cert`: recursive stabilization theorem
- `bracket_winner_const_of_uniform_margin`: uniform Lipschitz constant version
- `bracket_winner_const_of_allNodes_margin`: pathwise version using all-nodes list
- `le_certifiedRadius`: certified radius lower bound
- `diff_lipschitz_of_individual_lipschitz`: bridge from individual Lipschitz constants
-/
import Mathlib
import MachineLearning.BracketDefs

open Classical in
noncomputable section

namespace TournamentRobustness

variable {α : Type} [DecidableEq α] {d : ℕ}

/-! ## One-step comparison stability -/

/-- If the score difference `u(x0) - v(x0)` exceeds `L * r`, the difference is
    L-Lipschitz with L ≥ 0, and ‖y - x0‖ ≤ r, then `u(y) > v(y)`. -/
lemma score_gap_positive_on_ball
    {u v : (Fin d → ℝ) → ℝ} {x0 y : Fin d → ℝ}
    {L r : ℝ}
    (hL : 0 ≤ L)
    (hLip : |(u y - v y) - (u x0 - v x0)| ≤ L * ‖y - x0‖)
    (hy : ‖y - x0‖ ≤ r)
    (hgap : L * r < u x0 - v x0) :
    u y > v y := by
  nlinarith [abs_le.mp hLip]

/-- If scores f a, f b have individual Lipschitz constants Ka, Kb, then their
    difference is Lipschitz with constant Ka + Kb. -/
lemma diff_lipschitz_of_individual_lipschitz
    {f : α → (Fin d → ℝ) → ℝ} {a b : α}
    {Ka Kb : ℝ}
    {x y : Fin d → ℝ}
    (ha : |f a x - f a y| ≤ Ka * ‖x - y‖)
    (hb : |f b x - f b y| ≤ Kb * ‖x - y‖) :
    |(f a x - f b x) - (f a y - f b y)| ≤ (Ka + Kb) * ‖x - y‖ :=
  abs_le.mpr ⟨by linarith [abs_le.mp ha, abs_le.mp hb],
               by linarith [abs_le.mp ha, abs_le.mp hb]⟩

/-! ## Main recursive stabilization theorem -/

/-
**Recursive Stabilization Theorem.**
    If the recursive margin certificate holds for bracket T at point x0 with
    radius r and Lipschitz bounds L, and the score differences are L-Lipschitz,
    then the tournament winner is constant on the ball of radius r around x0.

    Proof by induction on `RecursiveMarginCert`:
    - Leaves are trivial.
    - At an internal node, IH freezes both child winners on the ball, then
      `score_gap_positive_on_ball` preserves the parent comparison.
-/
theorem bracket_winner_const_of_recursive_cert
    (T : Bracket α)
    (f : α → (Fin d → ℝ) → ℝ)
    (x0 : Fin d → ℝ)
    (r : ℝ)
    (_hr : 0 ≤ r)
    (L : α → α → ℝ)
    (hL_nonneg : ∀ a b, 0 ≤ L a b)
    (hLip : ∀ a b x y,
      |(f a x - f b x) - (f a y - f b y)| ≤ L a b * ‖x - y‖)
    (hcert : RecursiveMarginCert f x0 r L T) :
    ∀ y, ‖y - x0‖ ≤ r → T.winner f y = T.winner f x0 := by
      have h_rec_ind : ∀ T, RecursiveMarginCert f x0 r L T → ∀ y, ‖y - x0‖ ≤ r → Bracket.winner f T y = Bracket.winner f T x0 := by
        intros T hcert y hy; induction' hcert with l r hl hr hge hgap; simp_all +decide [ Bracket.winner ] ;
        · have := score_gap_positive_on_ball ( hL_nonneg _ _ ) ( hLip _ _ _ _ ) hy ‹_›; simp_all +decide [ Bracket.winner ] ;
          exact fun h => False.elim <| this.not_ge <| by linarith;
        · rename_i l r hl hr hlt hgap hl_ih hr_ih; simp_all +decide [ Bracket.winner ] ;
          split_ifs <;> simp_all +decide;
          · have := score_gap_positive_on_ball ( hL_nonneg _ _ ) ( hLip _ _ _ _ ) hy hgap; linarith;
          · linarith;
      exact h_rec_ind T hcert

/-! ## All-nodes list for pathwise interface -/

/-- Collect all internal comparison nodes of the bracket: at each internal node,
    record the winning child label and the opposing child label. -/
noncomputable def Bracket.allNodes (score : α → X → ℝ) :
    Bracket α → X → List (WinnerPathNode α)
  | .leaf _, _ => []
  | .node l r, x =>
    let wl := l.winner score x
    let wr := r.winner score x
    let thisNode : WinnerPathNode α :=
      if score wl x ≥ score wr x then ⟨wl, wr⟩ else ⟨wr, wl⟩
    thisNode :: l.allNodes score x ++ r.allNodes score x

variable {X : Type}

/-
If margins hold at ALL internal nodes, the recursive cert is satisfied.
-/
lemma recursiveMarginCert_of_allNodes_margin
    (T : Bracket α)
    (f : α → (Fin d → ℝ) → ℝ)
    (x0 : Fin d → ℝ)
    (r : ℝ)
    (L : α → α → ℝ)
    (hmargin : ∀ v ∈ T.allNodes f x0,
      L v.winLabel v.oppLabel * r < f v.winLabel x0 - f v.oppLabel x0) :
    RecursiveMarginCert f x0 r L T := by
      -- By definition of `RecursiveMarginCert`, we can prove this by induction on `T`.
      have h_ind : ∀ T : Bracket α, (∀ v ∈ Bracket.allNodes f T x0, L v.winLabel v.oppLabel * r < f v.winLabel x0 - f v.oppLabel x0) → RecursiveMarginCert f x0 r L T := by
        intro T hT;
        induction' T with l r ihl ihr;
        · constructor;
        · by_cases h : f ( r.winner f x0 ) x0 ≥ f ( ihl.winner f x0 ) x0 <;> simp_all +decide [ Bracket.allNodes ];
          · exact RecursiveMarginCert.node_left ihr ‹_› h hT.1;
          · exact RecursiveMarginCert.node_right ihr ‹_› h ( by linarith );
      exact h_ind T hmargin

/-- **All-Nodes Margin Theorem.**
    If every internal comparison node has a score gap exceeding the Lipschitz
    drift, the tournament winner is constant on the perturbation ball.
    This is the list-based interface to `bracket_winner_const_of_recursive_cert`. -/
theorem bracket_winner_const_of_allNodes_margin
    (T : Bracket α)
    (f : α → (Fin d → ℝ) → ℝ)
    (x0 : Fin d → ℝ)
    (r : ℝ)
    (hr : 0 ≤ r)
    (L : α → α → ℝ)
    (hL_nonneg : ∀ a b, 0 ≤ L a b)
    (hLip : ∀ a b x y,
      |(f a x - f b x) - (f a y - f b y)| ≤ L a b * ‖x - y‖)
    (hmargin : ∀ v ∈ T.allNodes f x0,
      L v.winLabel v.oppLabel * r < f v.winLabel x0 - f v.oppLabel x0) :
    ∀ y, ‖y - x0‖ ≤ r → T.winner f y = T.winner f x0 :=
  bracket_winner_const_of_recursive_cert T f x0 r hr L hL_nonneg hLip
    (recursiveMarginCert_of_allNodes_margin T f x0 r L hmargin)

/-! ## Uniform Lipschitz corollary -/

/-- **Uniform Margin Theorem.**
    When all score differences share a common Lipschitz bound Kdiff
    (as is typical for tropical / ReLU networks), the margin
    condition simplifies to checking comparisons against Kdiff. -/
theorem bracket_winner_const_of_uniform_margin
    (T : Bracket α)
    (f : α → (Fin d → ℝ) → ℝ)
    (x0 : Fin d → ℝ)
    (r Kdiff : ℝ)
    (hr : 0 ≤ r)
    (hK : 0 ≤ Kdiff)
    (hLip : ∀ a b x y,
      |(f a x - f b x) - (f a y - f b y)| ≤ Kdiff * ‖x - y‖)
    (hmargin : ∀ v ∈ T.allNodes f x0,
      Kdiff * r < f v.winLabel x0 - f v.oppLabel x0) :
    ∀ y, ‖y - x0‖ ≤ r → T.winner f y = T.winner f x0 :=
  bracket_winner_const_of_allNodes_margin T f x0 r hr
    (fun _ _ => Kdiff) (fun _ _ => hK) (fun a b => hLip a b) hmargin

/-! ## Certified radius lower bound -/

/-
**Certified Radius Theorem.**
    The minimum ratio of margin to Lipschitz constant over all internal
    nodes gives a lower bound on the certified radius:
    \[
    r^*(x_0) \ge \min_{v} \frac{f(w_v, x_0) - f(o_v, x_0)}{L(w_v, o_v)}
    \]
-/
theorem le_certifiedRadius
    (T : Bracket α)
    (f : α → (Fin d → ℝ) → ℝ)
    (x0 : Fin d → ℝ)
    (L : α → α → ℝ)
    (hL_pos : ∀ a b, 0 < L a b)
    (hLip : ∀ a b x y,
      |(f a x - f b x) - (f a y - f b y)| ≤ L a b * ‖x - y‖)
    (_hpos : ∀ v ∈ T.allNodes f x0,
      0 < f v.winLabel x0 - f v.oppLabel x0) :
    let nodes := T.allNodes f x0
    let margins := nodes.map (fun v =>
      (f v.winLabel x0 - f v.oppLabel x0) / L v.winLabel v.oppLabel)
    ∀ r, 0 ≤ r → (∀ m ∈ margins, r < m) →
      ∀ y, ‖y - x0‖ ≤ r → T.winner f y = T.winner f x0 := by
        simp +zetaDelta at *;
        intro r hr h;
        convert bracket_winner_const_of_allNodes_margin T f x0 r hr L ( fun a b => le_of_lt ( hL_pos a b ) ) hLip _;
        exact fun v hv => by have := h v hv; rwa [ lt_div_iff₀' ( hL_pos _ _ ) ] at this;

/-! ## Winner path is subset of all nodes -/

/-
The winner path is a sublist of all internal nodes.
-/
lemma winnerPath_subset_allNodes
    (T : Bracket α) (score : α → (Fin d → ℝ) → ℝ) (x : Fin d → ℝ) :
    ∀ v ∈ T.winnerPath score x, v ∈ T.allNodes score x := by
      induction' T with l r ihl ihr generalizing x;
      · tauto;
      · unfold Bracket.winnerPath Bracket.allNodes;
        grind

/-! ## Composition with individual Lipschitz constants -/

/-
**Bridge Theorem**: When individual scores have Lipschitz constants K(a),
    the score difference f(a,·) - f(b,·) has Lipschitz constant K(a) + K(b).
    Combined with the bracket robustness theorem, this gives a certified
    robustness result directly from per-class Lipschitz bounds.
-/
theorem bracket_winner_const_of_individual_lipschitz
    (T : Bracket α)
    (f : α → (Fin d → ℝ) → ℝ)
    (x0 : Fin d → ℝ)
    (r : ℝ)
    (hr : 0 ≤ r)
    (K : α → ℝ)
    (hK_nonneg : ∀ a, 0 ≤ K a)
    (hLip : ∀ a x y, |f a x - f a y| ≤ K a * ‖x - y‖)
    (hmargin : ∀ v ∈ T.allNodes f x0,
      (K v.winLabel + K v.oppLabel) * r <
        f v.winLabel x0 - f v.oppLabel x0) :
    ∀ y, ‖y - x0‖ ≤ r → T.winner f y = T.winner f x0 := by
      intro y hy;
      apply bracket_winner_const_of_allNodes_margin T f x0 r hr (fun a b => K a + K b) (fun a b => add_nonneg (hK_nonneg a) (hK_nonneg b)) (fun a b x y => diff_lipschitz_of_individual_lipschitz (hLip a x y) (hLip b x y)) hmargin y hy

end TournamentRobustness

end