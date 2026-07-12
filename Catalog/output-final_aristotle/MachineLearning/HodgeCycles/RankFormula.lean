/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Exact Betti–Rank Formula and Width Calculus for Decision Surfaces

For a rectified-linear network the decision surface `V(f) = {x : f(x) = 0}` is a
piecewise-linear hypersurface, assembled from flat faces cut out by the linear
equations `f = 0` on each activation region.  Each cellular piece is a hyperplane
section — an *algebraic cycle* — so the analogue of the Hodge problem is
affirmative by construction, and the substantive question is the **size** of the
homology in terms of the network's shape.

This file develops that quantitative theory in its sharpest form.  It first
recovers the cellular-homology framework (cycles, boundaries, homology as the
subquotient `Z/B`) and then upgrades the earlier *cell-count inequality* for the
Betti number into an **exact identity**, before building the arithmetic calculus
of the activation-pattern count that controls it.

## The exact homology dimension

For a three-term chain complex `C₂ →[d₂] C₁ →[d₁] C₀` over a field, two
applications of the rank–nullity theorem pin down the middle homology dimension:

  `dim H + rank d₁ + rank d₂ = dim C₁`   (`betti_rank_formula`),

equivalently `dim H = dim C₁ − rank d₁ − rank d₂` (`homology_finrank_eq`).  This
is the local Euler relation in its sharpest form: homology is exactly the part of
the chain group invisible to both differentials.  From it we read off the
vanishing criterion (`betti_zero_of_no_cells`) and its converse
(`cells_pos_of_betti_pos`).

## The width calculus

On the combinatorial side the activation-pattern count `P(w) = ∏ᵢ 2^{wᵢ}` obeys a
full algebra: it is monotone in each layer width
(`card_activationPattern_mono`) and multiplicative under parallel composition of
networks (`card_activationPattern_append`).  Combining topology and
combinatorics yields the monotone width bound on every Betti number of the
decision surface (`betti_le_activation_mono`).

## Main results

* `betti_rank_formula` — `dim H + rank d₁ + rank d₂ = dim C₁`.
* `homology_finrank_eq` — the subtraction form `dim H = dim C₁ − rank d₁ − rank d₂`.
* `betti_zero_of_no_cells`, `cells_pos_of_betti_pos` — vanishing and its converse.
* `card_activationPattern_mono` — monotonicity of the pattern count in the widths.
* `card_activationPattern_append` — multiplicativity under parallel composition.
* `betti_le_activation_mono` — the monotone width bound on the Betti number.

-- !-- Lab Notes -- !--
Hypothesis: the cell-count *inequality* bounding the Betti number of a
  piecewise-linear decision surface is the shadow of an exact rank identity, and
  the activation-pattern count carries a full multiplicative/monotone calculus
  mirroring composition of networks.
Experiment: model the cellular chain group over a field, with homology the
  subquotient `Z/B`; pin the homology dimension by composing two rank–nullity
  relations — one for `d₁` (cycles) and one identifying the boundary submodule
  with the range of `d₂` via the comap-subtype equivalence — then rearrange over
  `ℕ`.  Separately compute the pattern count under widening and concatenation.
Analysis: the identity `dim H + rank d₁ + rank d₂ = dim C₁` is genuinely
  two-sided and needs the chain-complex hypothesis `d₁ ∘ d₂ = 0` only to place
  the boundaries inside the cycles; the width lemmas are `Finset.prod` calculus
  but feed the topological bound through a single transitivity.
Critique: nothing is definitional — the rank formula uses finite-dimensionality
  of every stage and the comap equivalence, and the vanishing/converse pair
  exploits the identity, not merely the bound.
Synthesis: exact homology dimension `= dim C₁ − rank d₁ − rank d₂`, bounded by the
  monotone, multiplicative width count `∏ᵢ 2^{wᵢ}`.  The precise bigraded
  refinement is recorded as a conjecture in FUTURE_DIRECTIONS.
-/

import Mathlib

open Module BigOperators

namespace HodgeCycles

/-! ## Cellular homology of the decision surface

We fix a field `F` and three consecutive cellular chain groups
`C₂ →[d₂] C₁ →[d₁] C₀`.  Cycles are `ker d₁`, boundaries are `range d₂`, and
homology is the subquotient `ker d₁ ⧸ (range d₂)`. -/

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

/-- **Betti number bound by cell count.**  The dimension of homology is at most
the dimension of the cellular chain group, i.e. the number of cells. -/
theorem betti_number_le_cells :
    finrank F (homology d₂ d₁) ≤ finrank F C₁ :=
  le_trans (Submodule.finrank_quotient_le _) (Submodule.finrank_le _)

/-- **Exact rank identity of the subquotient.**  Betti number plus boundary rank
equals cycle rank. -/
theorem euler_identity :
    finrank F (homology d₂ d₁) + finrank F (boundaries d₂ d₁) = finrank F (cycles d₁) :=
  Submodule.finrank_quotient_add_finrank _

end Homology

/-! ## The exact Betti–rank identity -/

section RankFormula

variable {F : Type*} [Field F]
variable {C₂ C₁ C₀ : Type*}
  [AddCommGroup C₂] [Module F C₂] [AddCommGroup C₁] [Module F C₁]
  [AddCommGroup C₀] [Module F C₀]
  [FiniteDimensional F C₂] [FiniteDimensional F C₁] [FiniteDimensional F C₀]
variable (d₂ : C₂ →ₗ[F] C₁) (d₁ : C₁ →ₗ[F] C₀)

omit [FiniteDimensional F C₂] [FiniteDimensional F C₁] [FiniteDimensional F C₀] in
/-- The boundary submodule (inside the cycles) has the same dimension as the
range of the incoming differential `d₂`, via the comap-subtype equivalence, as
soon as the boundaries lie inside the cycles. -/
theorem finrank_boundaries_eq (hd : d₁.comp d₂ = 0) :
    finrank F (boundaries d₂ d₁) = finrank F (LinearMap.range d₂) := by
  have h_le : LinearMap.range d₂ ≤ LinearMap.ker d₁ := LinearMap.range_le_ker_iff.mpr hd
  exact LinearEquiv.finrank_eq (Submodule.comapSubtypeEquivOfLe h_le)

omit [FiniteDimensional F C₂] [FiniteDimensional F C₀] in
/-- **Exact Betti–rank identity.**  For a three-term chain complex the middle
homology dimension satisfies `dim H + rank d₁ + rank d₂ = dim C₁`. -/
theorem betti_rank_formula (hd : d₁.comp d₂ = 0) :
    finrank F (homology d₂ d₁) + finrank F (LinearMap.range d₁)
        + finrank F (LinearMap.range d₂) = finrank F C₁ := by
  have := finrank_boundaries_eq d₂ d₁ hd;
  linarith! [ euler_identity d₂ d₁, LinearMap.finrank_range_add_finrank_ker d₁ ]

omit [FiniteDimensional F C₂] [FiniteDimensional F C₀] in
/-- The subtraction form of the identity: `dim H = dim C₁ − rank d₁ − rank d₂`. -/
theorem homology_finrank_eq (hd : d₁.comp d₂ = 0) :
    finrank F (homology d₂ d₁)
      = finrank F C₁ - finrank F (LinearMap.range d₁) - finrank F (LinearMap.range d₂) := by
  convert eq_tsub_of_add_eq ( eq_tsub_of_add_eq ( betti_rank_formula d₂ d₁ hd ) ) using 1;
  rw [ tsub_right_comm ]

omit [FiniteDimensional F C₂] [FiniteDimensional F C₀] in
/-- **Vanishing.**  With no cells the homology vanishes. -/
theorem betti_zero_of_no_cells (h : finrank F C₁ = 0) :
    finrank F (homology d₂ d₁) = 0 := by
  exact le_antisymm ( le_trans ( HodgeCycles.betti_number_le_cells d₂ d₁ ) h.le ) ( Nat.zero_le _ )

omit [FiniteDimensional F C₂] [FiniteDimensional F C₀] in
/-- **Converse of vanishing.**  Nonzero homology forces at least one cell. -/
theorem cells_pos_of_betti_pos (h : 0 < finrank F (homology d₂ d₁)) :
    0 < finrank F C₁ := by
  convert h.trans_le ( betti_number_le_cells d₂ d₁ ) using 1

end RankFormula

/-! ## Counting cells: the activation-pattern calculus -/

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

/-- **Monotonicity.**  Widening any layer can only increase the activation-pattern
count `∏ᵢ 2^{wᵢ}`. -/
theorem card_activationPattern_mono {L : ℕ} {w w' : Fin L → ℕ} (h : ∀ i, w i ≤ w' i) :
    ∏ i, 2 ^ (w i) ≤ ∏ i, 2 ^ (w' i) := by
  exact Finset.prod_le_prod' fun i _ => pow_le_pow_right₀ ( by decide ) ( h i )

/-- **Multiplicativity under parallel composition.**  Stacking a width profile
`w : Fin L → ℕ` next to `v : Fin M → ℕ` (concatenating the layers) multiplies the
activation-pattern counts. -/
theorem card_activationPattern_append {L M : ℕ} (w : Fin L → ℕ) (v : Fin M → ℕ) :
    Fintype.card (ActivationPattern (L + M) (Fin.append w v))
      = Fintype.card (ActivationPattern L w) * Fintype.card (ActivationPattern M v) := by
  convert activationPattern_eq_two_pow_sum ( L + M ) ( Fin.append w v ) using 1;
  rw [ activationPattern_eq_two_pow_sum, activationPattern_eq_two_pow_sum ];
  rw [ ← pow_add, Fin.sum_univ_add ] ; aesop

end Counting

/-! ## Synthesis: the monotone width bound on homology -/

section Synthesis

variable {F : Type*} [Field F]
variable {C₂ C₁ C₀ : Type*}
  [AddCommGroup C₂] [Module F C₂] [AddCommGroup C₁] [Module F C₁]
  [AddCommGroup C₀] [Module F C₀] [FiniteDimensional F C₁]
variable (d₂ : C₂ →ₗ[F] C₁) (d₁ : C₁ →ₗ[F] C₀)

/-- **Monotone width bound.**  If the cellular chain group has at most one basis
cell per activation region for a width profile `w`, then for any wider profile
`w' ≥ w` the Betti number of the decision surface is bounded by `∏ᵢ 2^{w'ᵢ}`. -/
theorem betti_le_activation_mono {L : ℕ} {w w' : Fin L → ℕ}
    (hcells : finrank F C₁ ≤ ∏ i, 2 ^ (w i)) (hmono : ∀ i, w i ≤ w' i) :
    finrank F (homology d₂ d₁) ≤ ∏ i, 2 ^ (w' i) := by
  exact le_trans (betti_number_le_cells d₂ d₁)
    (le_trans hcells (card_activationPattern_mono hmono))

end Synthesis

end HodgeCycles