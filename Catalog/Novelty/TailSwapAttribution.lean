import Novelty.KVDecisionDissociation

/-!
# Tail-swap attribution: predicting the causal experiment (NET-51, Part D)

NET-51's proposed next experiment is a *causal tail swap*: take two fine-tunes of
one base model, exchange only the last two layers, and see whose behaviour the
hybrid inherits.  This file proves what the shared-core measurement already
forces about that experiment.

A model is factored as `tail ∘ core`, with `core` mapping the input to the
layer-`s` state and `tail` producing the final score vector.  Write
`coreDiv = ‖core_A x - core_B x‖` (measured to be small: the cores are shared
machinery) and `tailDiv` for the disagreement of the two tails *on the same
state*.

* `output_divergence_upper` — the output divergence is at most
  `K * coreDiv + tailDiv`, with `K` the Lipschitz constant of the tail.
* `tail_contribution_lower` — hence, contrapositively, a large observed output
  divergence with a small core divergence is a **lower bound on the tail's own
  contribution**: `tailDiv ≥ outputDiv - K * coreDiv`.  Identity that is measured
  at the output and absent from the core must live in the tail.
* `tail_swap_transfers_decision` — the predicted outcome of the causal swap: if
  model `B`'s tail holds its decision with margin `> 2 K ε` and the cores agree to
  `ε`, then the hybrid `tail_B ∘ core_A` makes model `B`'s decision.  The tail
  carries the decision; the core is interchangeable.
* `tail_swap_needs_margin` — the boundary: with no margin the conclusion fails,
  by the cosine/decision dissociation of `KVDecisionDissociation`.
-/

namespace Catalog.Novelty.TailSwapAttribution

open Catalog.Novelty.KVDecisionDissociation

variable {E G : Type*} [NormedAddCommGroup E] [NormedAddCommGroup G]

/-- Splitting the output divergence of two factored models into a core part
(amplified by the tail's Lipschitz constant) and a genuine tail part. -/
theorem output_divergence_upper (coreA coreB : E → E) (tailA tailB : E → G)
    (x : E) (K : ℝ) (hlip : ∀ y z, ‖tailA y - tailA z‖ ≤ K * ‖y - z‖) :
    ‖tailA (coreA x) - tailB (coreB x)‖
      ≤ K * ‖coreA x - coreB x‖ + ‖tailA (coreB x) - tailB (coreB x)‖ := by
  calc ‖tailA (coreA x) - tailB (coreB x)‖
      ≤ ‖tailA (coreA x) - tailA (coreB x)‖ + ‖tailA (coreB x) - tailB (coreB x)‖ :=
        norm_sub_le_norm_sub_add_norm_sub _ _ _
    _ ≤ K * ‖coreA x - coreB x‖ + ‖tailA (coreB x) - tailB (coreB x)‖ := by
        have := hlip (coreA x) (coreB x); linarith

/-- **Attribution.**  Whatever output divergence is observed beyond `K` times the
core divergence is carried by the tails: identity that is not in the shared core
must be in the personal tail. -/
theorem tail_contribution_lower (coreA coreB : E → E) (tailA tailB : E → G)
    (x : E) (K eps D : ℝ) (hlip : ∀ y z, ‖tailA y - tailA z‖ ≤ K * ‖y - z‖)
    (hK : 0 ≤ K) (hcore : ‖coreA x - coreB x‖ ≤ eps)
    (hout : D ≤ ‖tailA (coreA x) - tailB (coreB x)‖) :
    D - K * eps ≤ ‖tailA (coreB x) - tailB (coreB x)‖ := by
  have h1 := output_divergence_upper coreA coreB tailA tailB x K hlip
  have h2 : K * ‖coreA x - coreB x‖ ≤ K * eps := mul_le_mul_of_nonneg_left hcore hK
  linarith

/-- **Predicted outcome of the causal tail swap.**  If the two cores agree to `ε`,
the tail is `K`-Lipschitz coordinatewise, and model `B` holds its top-1 decision
with margin greater than `2 K ε`, then the hybrid model obtained by running
model `B`'s tail on model `A`'s core makes exactly model `B`'s decision.  Under a
margin hypothesis the tail — not the core — determines the decision. -/
theorem tail_swap_transfers_decision {m : ℕ} (coreA coreB : E → E)
    (tailB : E → Fin m → ℝ) (x : E) (i : Fin m) (K eps : ℝ) (hK : 0 ≤ K)
    (hlip : ∀ y z, ∀ j, |tailB y j - tailB z j| ≤ K * ‖y - z‖)
    (hcore : ‖coreB x - coreA x‖ ≤ eps)
    (hmargin : ∀ j, j ≠ i → 2 * (K * eps) < tailB (coreB x) i - tailB (coreB x) j) :
    IsStrictTop (tailB (coreA x)) i := by
  refine strictTop_of_margin (tailB (coreB x)) (tailB (coreA x)) i (K * eps) hmargin ?_
  intro j
  calc |tailB (coreB x) j - tailB (coreA x) j| ≤ K * ‖coreB x - coreA x‖ :=
        hlip (coreB x) (coreA x) j
    _ ≤ K * eps := mul_le_mul_of_nonneg_left hcore hK

/-- The margin hypothesis in `tail_swap_transfers_decision` cannot be dropped:
for every `ε > 0` there are two score vectors that are cosine-similar to within
`ε` yet decide differently, so "the caches look alike" never licenses a swap. -/
theorem tail_swap_needs_margin (eps : ℝ) (heps : 0 < eps) :
    ∃ u v : Fin 2 → ℝ, 1 - eps < cosSim u v ∧ IsStrictTop u 0 ∧ IsStrictTop v 1 :=
  cosine_near_one_decision_flip eps heps

end Catalog.Novelty.TailSwapAttribution