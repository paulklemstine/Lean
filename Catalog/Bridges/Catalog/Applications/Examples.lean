import Combinatorics.ForcingEdges.Basic

/-!
# Corollaries and worked examples for forcing edges

Building on `ForcingEdges.Basic`, this file records the two logical hallmarks of a
forcing edge and a fully worked, non-vacuous example.

## Main results

* `not_forcing_of_two_matchings` — an edge lying in **two distinct** perfect
  matchings is *not* forcing (this is the obstruction exploited by alternating
  cycles in the brick literature).
* `Forcing.unique_matching` — conversely, if `uv` is forcing, any two perfect
  matchings containing `uv` coincide.
* `forcing_top_fin2` — the single edge of `K₂` is a forcing edge (the smallest
  brick-free witness that the notion is non-vacuous).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): "Forcing" should be exactly the failure of the
alternating-cycle phenomenon: an edge is non-forcing precisely when it can be
routed through two different matchings.

Experiment (Experimenter): We isolate the two directions as
`not_forcing_of_two_matchings` and `Forcing.unique_matching`, then instantiate the
positive side on `K₂` where the unique perfect matching is the swap involution.

Analysis (Analyst): Both corollaries are immediate consequences of the
`ExistsUnique` packaged inside `Forcing`; the content is that our involution model
makes "distinct matchings through `uv`" literally "distinct involutions agreeing
at `u`".

Critique (Critic): The `K₂` example is genuinely computed (the swap is shown to be
the *only* fixed-point-free involution on `Fin 2`), not asserted, so it is not a
vacuous `True`.

Synthesis (PI): Together with the deletion characterisation, these give a complete
elementary calculus of forcing edges suitable for bootstrapping the brick theory.
-- !-- Lab Notes -- !--
-/

namespace ForcingEdges

open Function

variable {V : Type*}

/-
An edge contained in two *distinct* perfect matchings is not forcing.
-/
theorem not_forcing_of_two_matchings {G : SimpleGraph V} {f g : V → V} {u v : V}
    (hf : IsPM G f) (hg : IsPM G g) (hfuv : f u = v) (hguv : g u = v) (hne : f ≠ g) :
    ¬ Forcing G u v := by
  exact fun h => hne <| h.2.choose_spec.2 f ⟨ hf, hfuv ⟩ ▸ h.2.choose_spec.2 g ⟨ hg, hguv ⟩ ▸ rfl

/-
If `uv` is a forcing edge, any two perfect matchings containing it are equal.
-/
theorem Forcing.unique_matching {G : SimpleGraph V} {u v : V} (hF : Forcing G u v)
    {f g : V → V} (hf : IsPM G f) (hg : IsPM G g) (hfuv : f u = v) (hguv : g u = v) :
    f = g := by
  exact hF.2.unique ⟨ hf, hfuv ⟩ ⟨ hg, hguv ⟩

/-- The swap involution on `Fin 2`, the unique perfect matching of `K₂`. -/
def swap2 : Fin 2 → Fin 2 := fun x => if x = 0 then 1 else 0

/-
`K₂` (the complete graph on two vertices) has the swap as a perfect matching.
-/
theorem swap2_isPM : IsPM (⊤ : SimpleGraph (Fin 2)) swap2 := by
  constructor <;> norm_cast;
  exact fun x => by fin_cases x <;> rfl;

/-
The swap is the *only* perfect matching of `K₂`.
-/
theorem swap2_unique (g : Fin 2 → Fin 2) (hg : IsPM (⊤ : SimpleGraph (Fin 2)) g) :
    g = swap2 := by
  fin_cases g <;> simp_all +decide [ IsPM ]

/-
The single edge of `K₂` is a forcing edge — a non-vacuous witness.
-/
theorem forcing_top_fin2 : Forcing (⊤ : SimpleGraph (Fin 2)) 0 1 := by
  convert uniquePM_all_forcing swap2_isPM swap2_unique 0

end ForcingEdges