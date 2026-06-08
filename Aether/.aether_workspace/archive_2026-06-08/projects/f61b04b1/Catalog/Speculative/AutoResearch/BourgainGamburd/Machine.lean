import Mathlib
import BourgainGamburd.Convolution
import BourgainGamburd.SpectralGap

/-!
# The Bourgain–Gamburd Expansion Machine

This file formalizes the Bourgain–Gamburd expansion machine for finite groups.
The machine converts two combinatorial hypotheses — escape from structured subgroups
and product growth — into a spectral gap for the Cayley graph averaging operator.

## Architecture

The proof proceeds in three stages:
1. **L² flattening**: Under non-concentration + product growth, convolution
   reduces L² norm.
2. **Iterative convergence**: Repeated convolution drives the walk measure
   toward uniformity at exponential rate.
3. **Spectral gap extraction**: Exponential convergence to uniformity implies
   a positive spectral gap.

## Main results

- `bourgain_gamburd_spectral_gap` : the main machine theorem
- `l2_decay_from_growth` : L² norm decay under product growth
- `spectral_gap_from_l2_decay` : spectral gap from exponential L² decay

## References

* Bourgain, Gamburd, "Uniform expansion bounds for Cayley graphs of SL₂(𝔽_p)", 2008
* Bourgain, Gamburd, "Expansion and random walks in SL_d(Z/p^n Z)", 2009
-/

namespace BourgainGamburdMachine

open Finset BigOperators FiniteGroupConvolution SpectralGapTheory Classical

open scoped Pointwise

variable {G : Type*} [Fintype G] [DecidableEq G] [Group G]

/-! ### Structured subgroup families -/

/-- A family of "structured" subgroups — in the orthogonal setting these
would be stabilizers of isotropic lines, coordinate subspaces, etc. -/
structure StructuredFamily (G : Type*) [Group G] where
  /-- The predicate identifying structured subgroups. -/
  isStructured : Subgroup G → Prop
  /-- The top subgroup is not structured (it provides no constraint). -/
  top_not_structured : ¬ isStructured ⊤

/-! ### Concentration and escape -/

/-- Concentration of a measure on a left coset `gH`:
  the total mass assigned to elements of the form `g * h` for `h ∈ H`. -/
noncomputable def cosetConcentration (μ : G → ℝ) (g : G) (H : Subgroup G) : ℝ :=
  ∑ h : G, if (h ∈ H) then μ (g * h) else 0

/-- A measure escapes a structured family at scale `κ`: for every proper
structured subgroup, the mass on any coset is at most `|G|^{-κ}`. -/
def EscapesStructuredFamily (μ : G → ℝ) (𝓗 : StructuredFamily G) (κ : ℝ) : Prop :=
  ∀ H : Subgroup G, H ≠ ⊤ → 𝓗.isStructured H →
    ∀ g : G, cosetConcentration μ g H ≤ (Fintype.card G : ℝ) ^ (-κ)

/-- A subset is non-concentrated on structured subgroups. -/
def NonConcentrated (A : Finset G) (𝓗 : StructuredFamily G) (η : ℝ) : Prop :=
  ∀ H : Subgroup G, H ≠ ⊤ → 𝓗.isStructured H →
    ∀ g : G, ((A.filter (fun a => a * g⁻¹ ∈ H)).card : ℝ) ≤
      η * (A.card : ℝ)

/-! ### Product growth hypothesis -/

/-- The product growth hypothesis: every set of moderate size that is
not concentrated on structured cosets triples in size under triple product. -/
def ProductGrowth (𝓗 : StructuredFamily G) (ε δ η : ℝ) : Prop :=
  ∀ A : Finset G,
    (A.card : ℝ) ≥ (Fintype.card G : ℝ) ^ ε →
    (A.card : ℝ) ≤ (Fintype.card G : ℝ) ^ (1 - ε) →
    NonConcentrated A 𝓗 η →
    ((A * A * A).card : ℝ) ≥ (A.card : ℝ) ^ (1 + δ)

/-! ### L² flattening -/

/-- The L² flattening statement: under the product growth and escape hypotheses,
self-convolution of a probability measure that escapes structured subgroups
has strictly smaller L² norm than the original. -/
def L2Flattening (𝓗 : StructuredFamily G) (c : ℝ) : Prop :=
  ∀ μ : G → ℝ,
    IsProbMeasure μ →
    IsSymmetric μ →
    EscapesStructuredFamily μ 𝓗 1 →
    l2NormSq (conv μ μ) ≤ (1 - c) * l2NormSq μ

/-! ### The Main Machine -/

/-- **The Bourgain–Gamburd Machine**: Given escape from structured subgroups
and product growth, the Cayley graph of a symmetric generating set has
a spectral gap.

This is the central theorem that converts combinatorial hypotheses
(non-concentration + product growth) into spectral expansion. -/
theorem bourgain_gamburd_spectral_gap
    (S : Finset G)
    (𝓗 : StructuredFamily G)
    (ε δ κ η : ℝ)
    (hε : 0 < ε) (hδ : 0 < δ) (hκ : 0 < κ) (hη : 0 < η)
    (hS_symm : SymmetricSet S)
    (hS_gen : IsGenerating S)
    (hS_nonempty : S.Nonempty)
    (h_escape : EscapesStructuredFamily (genSetMeasure S) 𝓗 κ)
    (h_growth : ProductGrowth 𝓗 ε δ η) :
    ∃ gap : ℝ, 0 < gap ∧ HasSpectralGap S gap := by
  sorry

/-! ### Component Theorems -/

/-- L² norm of convolution is bounded by L² norm times a contraction
factor, assuming the measure is not too concentrated. This is the
key flattening step. -/
theorem l2_decay_from_growth
    (μ : G → ℝ)
    (𝓗 : StructuredFamily G)
    (ε δ η : ℝ)
    (hε : 0 < ε) (hδ : 0 < δ) (hη : 0 < η)
    (hμ_prob : IsProbMeasure μ)
    (hμ_sym : IsSymmetric μ)
    (h_escape : EscapesStructuredFamily μ 𝓗 1)
    (h_growth : ProductGrowth 𝓗 ε δ η) :
    ∃ c : ℝ, 0 < c ∧ c < 1 ∧
      l2NormSq (conv μ μ) ≤ (1 - c) * l2NormSq μ := by
  sorry

/-- Exponential L² decay under iterated convolution implies a spectral gap
for the averaging operator. -/
theorem spectral_gap_from_l2_decay
    (S : Finset G)
    (hS_symm : SymmetricSet S)
    (hS_gen : IsGenerating S)
    (hS_nonempty : S.Nonempty)
    (c : ℝ) (hc : 0 < c) (hc1 : c < 1)
    (h_decay : ∀ μ : G → ℝ,
      IsProbMeasure μ → IsSymmetric μ →
      l2NormSq (conv μ μ) ≤ (1 - c) * l2NormSq μ) :
    ∃ gap : ℝ, 0 < gap ∧ HasSpectralGap S gap := by
  sorry

/-- The machine theorem follows by combining flattening and spectral extraction. -/
theorem bourgain_gamburd_from_components
    (S : Finset G)
    (𝓗 : StructuredFamily G)
    (hS_symm : SymmetricSet S)
    (hS_gen : IsGenerating S)
    (hS_nonempty : S.Nonempty)
    (c : ℝ) (hc : 0 < c) (hc1 : c < 1)
    (h_flattening : L2Flattening 𝓗 c) :
    ∃ gap : ℝ, 0 < gap ∧ HasSpectralGap S gap := by
  sorry

end BourgainGamburdMachine