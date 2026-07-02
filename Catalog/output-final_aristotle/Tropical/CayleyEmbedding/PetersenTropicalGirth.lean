/-
# Odd-girth obstruction to embedding into tropical abelian Cayley graphs

This file abstracts the mechanism behind
`petersen_no_isometric_into_tropicalCayley`
(in `PetersenTropicalCayley.lean`) into a general **odd-closed-walk** obstruction:
*any* graph carrying a closed walk of odd length fails to embed isometrically into
a bipartite host, and in particular into the tropical Cayley graphs whose
connection set is the odd-valuation level structure of a valuation `v : A →+ ℤ`.

We also record two sanity facts guaranteeing the results are **not vacuous**:
the tropical Cayley host `tropicalCayley (latticeVal k)` genuinely has edges for
`k ≥ 1`, and the Petersen pentagon is genuinely an odd closed walk.

## Main results

* `not_colorable_two_of_odd_closed_walk` : a graph with an odd closed walk is not
  bipartite.
* `odd_walk_no_isometric_into_tropicalCayley` : **main theorem** — a graph with an
  odd closed walk admits no isometric embedding into a tropical Cayley graph.
* `tropicalCayley_latticeVal_has_edge` : non-vacuity — the integer-lattice
  tropical host has an edge for `k ≥ 1`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The Petersen obstruction should not need the specific
Kneser combinatorics — only the presence of ONE odd closed walk (odd girth).
Conjecture: the property "carries an odd closed walk" is the exact source-side
invariant that a bipartite (in particular tropical odd-valuation) host cannot
receive isometrically.

Experiment (Experimenter): Replaced `Petersen_not_colorable_two` by the generic
`not_colorable_two_of_odd_closed_walk`, obtained from
`two_colorable_iff_forall_loop_even` by exhibiting the odd walk directly, then
fed it into the metric obstruction `no_isometric_into_colorable` together with
`tropicalCayley_colorable_two`.  For non-vacuity, exhibited the explicit edge
`0 ~ e₀` (standard basis vector) in the lattice host, whose valuation `1` is odd.

Analysis (Analyst): The generalization shows the tropical result is an instance
of a single clean principle: odd girth ⊥ tropical-bipartite host.  Failure mode:
graphs with no odd closed walk (bipartite sources) are unconstrained — they may
well embed — so oddness is genuinely necessary, not an artefact.

Critique (Critic): `not_colorable_two_of_odd_closed_walk` is not `decide`; it
routes through the parity-of-walks bridge.  The non-vacuity lemma prevents the
"empty host" degeneracy (a graph with no edges is trivially bipartite and the
statement would be uninteresting).

Synthesis (PI): The abstract odd-walk form is the reusable engine; Petersen is
one witness among many, and every tropical odd-valuation host is ruled out
uniformly.
-- !-- end Lab Notes -- !--
-/
import Mathlib
import Catalog.Tropical.CayleyEmbedding.PetersenTropicalCayley

open SimpleGraph

namespace TropicalPetersen

/-! ## §1. The generic odd-closed-walk obstruction -/

/-- A graph carrying a closed walk of **odd** length is not `2`-colorable. -/
theorem not_colorable_two_of_odd_closed_walk {V : Type*} {G : SimpleGraph V}
    {u : V} (w : G.Walk u u) (hw : Odd w.length) : ¬ G.Colorable 2 := by
  rw [two_colorable_iff_forall_loop_even]
  push_neg
  exact ⟨u, w, by simpa [Nat.not_even_iff_odd] using hw⟩

/-- **Main theorem (odd-girth form).** A graph carrying an odd closed walk admits
no isometric embedding into a tropical Cayley graph `tropicalCayley v` of any
abelian group `A` with valuation `v : A →+ ℤ`. -/
theorem odd_walk_no_isometric_into_tropicalCayley {V : Type*} {G : SimpleGraph V}
    {u : V} (w : G.Walk u u) (hw : Odd w.length)
    {A : Type*} [AddCommGroup A] (v : A →+ ℤ) (f : V → A) :
    ¬ (∀ x y, (tropicalCayley v).dist (f x) (f y) = G.dist x y) :=
  no_isometric_into_colorable (not_colorable_two_of_odd_closed_walk w hw)
    (tropicalCayley_colorable_two v) f

/-- The Petersen non-embeddability of `PetersenTropicalCayley.lean` recovered as
an instance of the odd-girth obstruction (the pentagon has odd length `5`). -/
theorem petersen_no_isometric_into_tropicalCayley' {A : Type*} [AddCommGroup A]
    (v : A →+ ℤ) (f : PetersenV → A) :
    ¬ (∀ u w, (tropicalCayley v).dist (f u) (f w) = Petersen.dist u w) :=
  odd_walk_no_isometric_into_tropicalCayley petersenPentagon (by decide) v f

/-! ## §2. Non-vacuity of the tropical hosts -/

/-- The standard basis vector `e₀` in `ℤ^k` (for `k ≥ 1`) is a generator of the
tropical lattice host: its coordinate-sum valuation is `1`, which is odd. -/
theorem tropicalCayley_latticeVal_has_edge (k : ℕ) (hk : 0 < k) :
    (tropicalCayley (latticeVal k)).Adj 0 (Pi.single ⟨0, hk⟩ 1) := by
  show (Pi.single (⟨0, hk⟩ : Fin k) (1 : ℤ) - 0) ∈ oddValGen (latticeVal k)
  simp only [oddValGen, Set.mem_setOf_eq, sub_zero]
  have : latticeVal k (Pi.single (⟨0, hk⟩ : Fin k) (1 : ℤ)) = 1 := by
    simp [latticeVal, Finset.sum_pi_single']
  rw [this]
  decide

end TropicalPetersen