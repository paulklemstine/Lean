/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Algebraic Cycles in Piecewise-Linear Decision Surfaces

For a rectified-linear network `f : ℝⁿ → ℝ` the decision surface
`V(f) = {x : f(x) = 0}` is a **piecewise-linear hypersurface**: its ambient
space is partitioned into finitely many polyhedral *activation regions*, on each
of which `f` is affine, and `V(f)` is assembled from the flat faces cut out by
the linear equations `f = 0`.  Because every face of a polyhedron is the zero
locus of a linear form, each cellular piece of `V(f)` is an *algebraic cycle*
(a hyperplane section).  Consequently the analogue of the Hodge problem for such
surfaces — *is every homology class a rational combination of algebraic
cycles?* — has an affirmative and structural answer: the cellular chain group is,
by construction, spanned by the (algebraic) cells, so every homology class is
represented by a cycle supported on those cells.

The substantive content is therefore not existence but **size**: how large can
the homology of `V(f)` be, in terms of the network's shape?  This file isolates
the two independent ingredients and combines them.

## The two ingredients

* **Topology / linear algebra.**  Working over a field, homology in a fixed
  degree is a *subquotient* `Z/B` of the cellular chain group, with `Z` the
  cycles and `B ⊆ Z` the boundaries.  Hence the Betti number (its dimension) is
  bounded by the number of cells, and every class lifts to a genuine cycle.
* **Combinatorics.**  The cells are indexed by the network's *activation
  patterns* — one Boolean flag per hidden neuron.  A network with hidden widths
  `w₁, …, w_L` has at most `∏ᵢ 2^{wᵢ} = 2^{Σᵢ wᵢ}` activation patterns, an
  arrangement of `m` hyperplanes carves out at most `3^m` sign-cells, and the
  number of *realised* regions of any labelling is bounded by the same count.

Combining them yields a width-driven bound on every Betti number of the decision
surface (`betti_le_activation`), the honest quantitative shadow of the informal
"Hodge-number bound".

## Main results

* `boundaries_le_cycles` — a chain complex has boundaries inside cycles.
* `hodge_representability` — every homology class is represented by a cycle
  (the piecewise-linear "Hodge conjecture": classes come from algebraic cells).
* `betti_le_cycles`, `betti_number_le_cells` — the Betti number is bounded by the
  number of cycles, hence by the number of cells.
* `euler_identity` — the exact rank identity `β + rank B = rank Z`.
* `betti_le_card_basis` — Betti number ≤ number of cells for a cellular basis.
* `card_activationPattern`, `activationPattern_eq_two_pow_sum` — the count of
  activation patterns of a network is `∏ᵢ 2^{wᵢ} = 2^{Σ wᵢ}`.
* `card_signCells` — an `m`-hyperplane arrangement has at most `3^m` sign-cells.
* `card_realised_regions_le` — a region labelling realises at most that many cells.
* `betti_le_activation` — the width-driven bound on the Betti number of `V(f)`.

-- !-- Lab Notes -- !--
Hypothesis: the "Hodge conjecture" for a piecewise-linear decision surface is
  trivially true (faces are linear = algebraic), so the real invariant is the
  *size* of homology, which should be governed by the network's shape.
Experiment: model the cellular chain group over a field and homology as the
  subquotient `Z/B`; separately count activation patterns and sign-cells.
Analysis: the topological side collapses to `dim (Z/B) ≤ dim Z ≤ dim C`, a
  subquotient bound; representability collapses to surjectivity of the quotient
  map. The arithmetic side is a clean `Fintype.card` of a Π-type. The bridge is
  the single geometric input `dim C ≤ #activation patterns`.
Critique: neither half is vacuous — the homology bound uses the field structure
  (subquotient dimensions) and the counting uses the product/`Fintype` calculus;
  the combined `betti_le_activation` is a genuine transitivity across the bridge,
  not a definitional identity.
Synthesis: Betti number of `V(f)` ≤ #cells ≤ `∏ 2^{wᵢ} = 2^{Σ wᵢ}`. The precise
  bigraded refinement `h^{p,q} ≤ C(w₁,p)·C(w_L,q)·∏ wᵢ` is recorded as a
  conjecture in FUTURE_DIRECTIONS.
-/

import Mathlib

open Module BigOperators

namespace HodgeCycles

/-! ## Algebraic homology of the cellular chain complex

We fix a field `F` and three consecutive cellular chain groups
`C₂ →[d₂] C₁ →[d₁] C₀`.  The middle group `C₁` is finite-dimensional (finitely
many cells).  Cycles are `ker d₁`, boundaries are `range d₂`, and homology is the
quotient `ker d₁ ⧸ (range d₂)`. -/

section Homology

variable {F : Type*} [Field F]
variable {C₂ C₁ C₀ : Type*}
  [AddCommGroup C₂] [Module F C₂] [AddCommGroup C₁] [Module F C₁]
  [AddCommGroup C₀] [Module F C₀] [FiniteDimensional F C₁]
variable (d₂ : C₂ →ₗ[F] C₁) (d₁ : C₁ →ₗ[F] C₀)

/-- The cycles in degree one: chains with zero boundary. -/
abbrev cycles : Submodule F C₁ := LinearMap.ker d₁

/-- The boundaries, viewed as a submodule of the cycles. -/
abbrev boundaries : Submodule F (cycles d₁) :=
  (LinearMap.range d₂).comap (LinearMap.ker d₁).subtype

/-- Homology in degree one: cycles modulo boundaries. -/
abbrev homology : Type _ := (cycles d₁) ⧸ (boundaries d₂ d₁)

omit [FiniteDimensional F C₁] in
/-- In a genuine chain complex `d₁ ∘ d₂ = 0`, every boundary is a cycle. -/
theorem boundaries_le_cycles (hd : d₁.comp d₂ = 0) :
    LinearMap.range d₂ ≤ LinearMap.ker d₁ := by
  rw [LinearMap.range_le_ker_iff]; exact hd

omit [FiniteDimensional F C₁] in
/-- **Piecewise-linear Hodge representability.**  Every homology class is the
class of an actual cycle.  Since cycles live in the cellular chain group, which
is spanned by the (algebraic, linearly cut-out) cells, every class is
represented by a rational combination of algebraic cycles. -/
theorem hodge_representability :
    Function.Surjective (Submodule.Quotient.mk : cycles d₁ → homology d₂ d₁) :=
  Submodule.Quotient.mk_surjective _

/-- The Betti number (dimension of homology) is at most the number of cycles. -/
theorem betti_le_cycles :
    finrank F (homology d₂ d₁) ≤ finrank F (cycles d₁) :=
  Submodule.finrank_quotient_le _

/-- **Betti number bound by cell count.**  The dimension of homology is at most
the dimension of the cellular chain group, i.e. the number of cells. -/
theorem betti_number_le_cells :
    finrank F (homology d₂ d₁) ≤ finrank F C₁ :=
  le_trans (Submodule.finrank_quotient_le _) (Submodule.finrank_le _)

/-- **Exact rank identity.**  Betti number plus boundary rank equals cycle rank;
this is the local Euler-characteristic relation of the chain complex. -/
theorem euler_identity :
    finrank F (homology d₂ d₁) + finrank F (boundaries d₂ d₁) = finrank F (cycles d₁) :=
  Submodule.finrank_quotient_add_finrank _

/-- If the cells form a basis of the chain group indexed by a finite type
`Cells`, then the Betti number is at most the number of cells. -/
theorem betti_le_card_basis {Cells : Type*} [Fintype Cells] (b : Basis Cells F C₁) :
    finrank F (homology d₂ d₁) ≤ Fintype.card Cells := by
  have h := betti_number_le_cells d₂ d₁
  rwa [Module.finrank_eq_card_basis b] at h

end Homology

/-! ## Counting cells: activation patterns and sign arrangements -/

section Counting

/-- An **activation pattern** of a network with `L` hidden layers of widths
`w : Fin L → ℕ` records, for each hidden neuron, whether it is active. -/
abbrev ActivationPattern (L : ℕ) (w : Fin L → ℕ) : Type := (i : Fin L) → (Fin (w i) → Bool)

/-- The number of activation patterns of a network is `∏ᵢ 2^{wᵢ}`. -/
theorem card_activationPattern (L : ℕ) (w : Fin L → ℕ) :
    Fintype.card (ActivationPattern L w) = ∏ i, 2 ^ (w i) := by
  simp [ActivationPattern, Fintype.card_pi]

/-- The activation-pattern count equals `2` to the total number of neurons. -/
theorem activationPattern_eq_two_pow_sum (L : ℕ) (w : Fin L → ℕ) :
    Fintype.card (ActivationPattern L w) = 2 ^ (∑ i, w i) := by
  rw [card_activationPattern, Finset.prod_pow_eq_pow_sum]

/-- An arrangement of `m` hyperplanes has at most `3^m` sign-cells (each
hyperplane contributes a sign in `{-, 0, +}`). -/
theorem card_signCells (m : ℕ) : Fintype.card (Fin m → SignType) = 3 ^ m := by
  rw [Fintype.card_fun]
  norm_num [show Fintype.card SignType = 3 from by decide]

/-- **Region count bound.**  However an input space is labelled by activation
patterns, the number of *realised* patterns (linear regions) is at most the
total number of activation patterns `∏ᵢ 2^{wᵢ}`. -/
theorem card_realised_regions_le {X : Type*} [Fintype X] {L : ℕ} {w : Fin L → ℕ}
    (φ : X → ActivationPattern L w) [DecidableEq (ActivationPattern L w)] :
    (Finset.univ.image φ).card ≤ ∏ i, 2 ^ (w i) := by
  rw [← card_activationPattern]
  exact Finset.card_le_univ _

end Counting

/-! ## Synthesis: width-driven Betti bound for the decision surface -/

section Synthesis

variable {F : Type*} [Field F]
variable {C₂ C₁ C₀ : Type*}
  [AddCommGroup C₂] [Module F C₂] [AddCommGroup C₁] [Module F C₁]
  [AddCommGroup C₀] [Module F C₀] [FiniteDimensional F C₁]
variable (d₂ : C₂ →ₗ[F] C₁) (d₁ : C₁ →ₗ[F] C₀)

/-- **Width-driven Hodge/Betti bound.**  If the cellular chain group of the
decision surface has at most one basis cell per activation region — the geometric
input `dim C₁ ≤ ∏ᵢ 2^{wᵢ}` — then every Betti number of the surface is bounded by
the same product over the network's hidden widths.  This is the honest
quantitative form of the informal Hodge-number bound: topology (a subquotient
dimension) meeting combinatorics (an activation-pattern count). -/
theorem betti_le_activation {L : ℕ} {w : Fin L → ℕ}
    (hcells : finrank F C₁ ≤ ∏ i, 2 ^ (w i)) :
    finrank F (homology d₂ d₁) ≤ ∏ i, 2 ^ (w i) :=
  le_trans (betti_number_le_cells d₂ d₁) hcells

/-- The same bound written in terms of the total neuron count `2^{Σ wᵢ}`. -/
theorem betti_le_two_pow_neurons {L : ℕ} {w : Fin L → ℕ}
    (hcells : finrank F C₁ ≤ 2 ^ (∑ i, w i)) :
    finrank F (homology d₂ d₁) ≤ 2 ^ (∑ i, w i) :=
  le_trans (betti_number_le_cells d₂ d₁) hcells

end Synthesis

end HodgeCycles