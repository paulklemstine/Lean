/-
# Bridge: the catalog's `ℝ` phantom topology is an instance of the general theorem

`Catalog/Novelty/PhantomTopology.lean` built two concrete observers on `ℝ`
(`Phantom.lowerTop`, `Phantom.upperTop`) and proved, by a metric `ε`–`δ`
argument, that the Euclidean topology is their consensus
(`Phantom.consensus_eq_standard`).

`Catalog/Novelty/PhantomTopologyOrderGeneral.lean` proved a *metric-free*
generalisation for every dense endpoint-free linear order
(`PhantomOrder.consensus_orderTop`, `PhantomOrder.orderTop_phantom_number_two`).

This file records the **bridge**: the catalog's `ℝ`-specific observers are
*definitionally* the generic order observers specialised to `ℝ`
(`lowerTop_eq_general`, `upperTop_eq_general`), so the catalog's headline theorem
is a special case of the general one.  As a payoff we assemble the full
phantom-number-two statement for `ℝ` — consensus, distinctness, and strict
refinement of each observer — reusing the catalog's Bool-indexed packaging
`Phantom.consensus` together with the general strict-refinement lemmas.

-- !-- Lab Notes -- !--

Hypothesis (Hypothesizer): the two `ℝ` developments are not merely equivalent but
  identical — the concrete `lowerTop` and the generic `lowerTopGen` have the same
  open sets by definition, so the metric proof was never necessary.

Experiment (Experimenter): checked that `Phantom.lowerOpen` and
  `PhantomOrder.lowerOpenGen (α := ℝ)` unfold to the *same* predicate, so the two
  `TopologicalSpace ℝ` structures agree on their only relevant field.

Analysis (Analyst): `lowerTop_eq_general`/`upperTop_eq_general` hold by
  `TopologicalSpace.ext` + `rfl`, confirming the metric detour was avoidable.  The
  general theorem strictly subsumes the catalog one (it also covers `ℚ`).

Critique (Critic): the bridge theorem is not a rename — it equates two
  independently defined topologies and then *uses* both files' theorems
  (`Phantom.consensus_pair_eq_standard` and the general strict-finer lemmas) to
  produce a statement neither file states alone.

Synthesis (PI): "reality needs two observers" for `ℝ` is one point of a spectrum:
  every dense endpoint-free chain needs exactly two, discrete chains need one.
-/
import Catalog.Novelty.PhantomTopology
import Catalog.Novelty.PhantomTopologyOrderGeneral

open Set

namespace PhantomOrder

/-- The catalog's concrete lower-limit observer on `ℝ` **is** the generic
lower-limit observer specialised to `ℝ`. -/
theorem lowerTop_eq_general : Phantom.lowerTop = (lowerTopGen : TopologicalSpace ℝ) := by
  apply TopologicalSpace.ext
  rfl

/-- The catalog's concrete upper-limit observer on `ℝ` **is** the generic
upper-limit observer specialised to `ℝ`. -/
theorem upperTop_eq_general : Phantom.upperTop = (upperTopGen : TopologicalSpace ℝ) := by
  apply TopologicalSpace.ext
  rfl

/-- **Bridge / subsumption.**  The catalog's metric proof that Euclidean `ℝ` is
the consensus of `lowerTop` and `upperTop` is exactly the general order-theoretic
theorem specialised to `ℝ`.  We derive the catalog statement from the general one
through the definitional identification above. -/
theorem catalog_consensus_from_general :
    Phantom.lowerTop ⊔ Phantom.upperTop = (inferInstance : TopologicalSpace ℝ) := by
  rw [lowerTop_eq_general, upperTop_eq_general]
  exact real_consensus_orderTop

/-- **Full phantom-number-two statement for `ℝ`, assembled from both files.**
Reusing the catalog's Bool-indexed consensus packaging together with the general
strict-refinement lemmas, `ℝ` has a genuine two-observer phantom representation:
the two Bool-indexed observers consense to the Euclidean topology, they are
distinct, and each is strictly finer than reality. -/
theorem real_phantom_number_two_full :
    Phantom.consensus Phantom.observersℝ = (inferInstance : TopologicalSpace ℝ) ∧
      Phantom.lowerTop ≠ Phantom.upperTop ∧
      Phantom.lowerTop < (inferInstance : TopologicalSpace ℝ) ∧
      Phantom.upperTop < (inferInstance : TopologicalSpace ℝ) := by
  refine ⟨Phantom.consensus_pair_eq_standard, Phantom.lowerTop_ne_upperTop, ?_, ?_⟩
  · rw [lowerTop_eq_general]; exact lowerTopGen_lt_orderTop
  · rw [upperTop_eq_general]; exact upperTopGen_lt_orderTop

end PhantomOrder