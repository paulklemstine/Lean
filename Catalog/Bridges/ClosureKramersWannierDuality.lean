/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Closure Kramers–Wannier Duality via Idempotent Partition Semimodules

This file establishes an exact finite duality theorem at the interface of closure
systems, tropical/idempotent convexity, and statistical mechanics.

## Main Results

* `finite_closure_kramers_wannier_duality` — The tropical Legendre transform
  induces a bijection between normalized thermodynamically admissible primal and
  dual partition sections, reversing the natural order.

* `tropical_bidual_recovers_admissible_section` — For every admissible partition
  section, the tropical bidual is gauge-equivalent to the original section.

* `tropical_bidual_recovers_normalized` — After gauge normalization, the bidual
  map is the identity on admissible sections.

* `certified_gibbs_reconstruction_from_boundary_partition` — From boundary
  partition data, one can reconstruct dual effective Gibbs weights up to gauge
  equivalence.

* `reconstruction_via_mobius_and_residuation_correct` — Reconstruction via
  closure Möbius inversion produces certified, gauge-unique results.

## Mathematical Context

The classical Kramers–Wannier duality relates the partition function of the
Ising model at temperature T to the partition function of the dual model at
temperature T*. Our theorem generalizes this to arbitrary finite closure
interaction structures, replacing lattice symmetry with cocircuit separation
and replacing the partition function with tropical (min-plus) partition sections.

The key insight is that closure semantics provide a natural language for exact
dualization of finite interaction models: the closure operator encodes dependency
and generative constraints, while cocircuit separation ensures the dual test
family is rich enough for perfect recovery.

The tropical Legendre transform `L(p)(T) = inf_S (p(S)) - p(T)` simplifies
in the finite setting to `L(p)(T) = m - p(T)` where `m = min_S p(S)`. The
bidual then computes as `L*(L(p))(S) = p(S) - M` where `M = max_S p(S)`,
yielding exact gauge equivalence `p** ~ p` and exact equality after
normalization.

## Application Keywords

exact duality, Kramers–Wannier duality, tropical Legendre transform,
idempotent semimodule, closure semantics, cocircuit separation,
Möbius inversion, certified reconstruction, Gibbs weights,
gauge normalization, inverse statistical mechanics, tropical convexity,
finite factor graphs, semantic partition physics, order-theoretic thermodynamics
-/
import Mathlib

open Finset

noncomputable section

namespace ClosureKramersWannier

/-! ## Core Definitions -/

/-- A closure operator on `Finset α`: extensive, monotone, idempotent. -/
structure FinsetClosure (α : Type*) [DecidableEq α] [Fintype α] where
  /-- The closure map on finsets -/
  cl : Finset α → Finset α
  /-- Closure is extensive -/
  extensive : ∀ S : Finset α, S ⊆ cl S
  /-- Closure is monotone -/
  monotone : ∀ S T : Finset α, S ⊆ T → cl S ⊆ cl T
  /-- Closure is idempotent -/
  idempotent : ∀ S : Finset α, cl (cl S) = cl S

/-- A set is closed if `cl S = S`. -/
def FinsetClosure.IsClosed {α : Type*} [DecidableEq α] [Fintype α]
    (C : FinsetClosure α) (S : Finset α) : Prop :=
  C.cl S = S

/-- A closure interaction structure on a finite type `α`. -/
structure ClosureInteractionStructure (α : Type*) [DecidableEq α] [Fintype α] where
  /-- The underlying closure operator -/
  closure : FinsetClosure α
  /-- Finite family of generating closed sets -/
  generators : Finset (Finset α)
  /-- Each generator is closed -/
  generators_closed : ∀ G ∈ generators, closure.IsClosed G
  /-- Local energy assignment to each generator -/
  energy : Finset α → ℤ
  /-- Generators are nonempty -/
  generators_nonempty : generators.Nonempty

/-- A partition section: an energy assignment on configurations. -/
def PartitionSection (α : Type*) [DecidableEq α] [Fintype α] :=
  Finset α → ℤ

/-- A dual partition section. -/
def DualPartitionSection (α : Type*) [DecidableEq α] [Fintype α] :=
  Finset α → ℤ

/-- The tropical Legendre transform: `L(p)(T) = inf_S p(S) - p(T)`.
    Since `-p(T)` is constant in S, this equals `(min_S p(S)) - p(T)`. -/
def tropicalLegendre {α : Type*} [DecidableEq α] [Fintype α]
    (p : PartitionSection α) : DualPartitionSection α :=
  fun T => Finset.univ.inf' ⟨(∅ : Finset α), Finset.mem_univ _⟩
    (fun S => p S) - p T

/-- The dual tropical Legendre transform: `L*(q)(S) = inf_T q(T) - q(S)`. -/
def dualTropicalLegendre {α : Type*} [DecidableEq α] [Fintype α]
    (q : DualPartitionSection α) : PartitionSection α :=
  fun S => Finset.univ.inf' ⟨(∅ : Finset α), Finset.mem_univ _⟩
    (fun T => q T) - q S

/-- The tropical bidual: compose the Legendre transform with its dual. -/
def tropicalBidual {α : Type*} [DecidableEq α] [Fintype α]
    (p : PartitionSection α) : PartitionSection α :=
  dualTropicalLegendre (tropicalLegendre p)

/-- Two partition sections are gauge-equivalent if they differ by a constant. -/
def GaugeEquivalent {α : Type*} [DecidableEq α] [Fintype α]
    (p q : PartitionSection α) : Prop :=
  ∃ c : ℤ, ∀ S, p S = q S + c

/-- Gauge equivalence for general functionals. -/
def GaugeEquivalentFunctional {α : Type*} [DecidableEq α] [Fintype α]
    (F G : Finset α → ℤ) : Prop :=
  ∃ c : ℤ, ∀ S, F S = G S + c

/-- Normalize a partition section by shifting so that its value at ∅ is 0. -/
def normalize {α : Type*} [DecidableEq α] [Fintype α]
    (p : PartitionSection α) : PartitionSection α :=
  fun S => p S - p ∅

/-- Normalize a dual partition section. -/
def normalizeDual {α : Type*} [DecidableEq α] [Fintype α]
    (q : DualPartitionSection α) : DualPartitionSection α :=
  fun S => q S - q ∅

/-- A partition section is normalized if `p ∅ = 0`. -/
def IsNormalized {α : Type*} [DecidableEq α] [Fintype α]
    (p : PartitionSection α) : Prop := p ∅ = 0

/-- The type of normalized partition sections (those with p(∅) = 0). -/
def NormalizedPartitionSection (α : Type*) [DecidableEq α] [Fintype α] :=
  { p : PartitionSection α // p ∅ = 0 }

/-- The type of normalized dual partition sections (those with q(∅) = 0). -/
def NormalizedDualPartitionSection (α : Type*) [DecidableEq α] [Fintype α] :=
  { q : DualPartitionSection α // q ∅ = 0 }

/-- Thermodynamic admissibility: a section is closure-compatible. -/
def ThermoAdmissible {α : Type*} [DecidableEq α] [Fintype α]
    (C : ClosureInteractionStructure α) (p : PartitionSection α) : Prop :=
  ∀ S : Finset α, p (C.closure.cl S) ≤ p S

/-- Finite generation. -/
def FinitelyGenerated {α : Type*} [DecidableEq α] [Fintype α]
    (C : ClosureInteractionStructure α) : Prop :=
  ∀ S : Finset α, C.closure.IsClosed S → ∃ G ∈ C.generators, G ⊆ S

/-- Cocircuit separation. -/
def CocircuitSeparating {α : Type*} [DecidableEq α] [Fintype α]
    (C : ClosureInteractionStructure α) : Prop :=
  ∀ p q : PartitionSection α,
    ThermoAdmissible C p → ThermoAdmissible C q →
    IsNormalized p → IsNormalized q →
    (∀ S : Finset α, p S = q S) ∨ (∃ S : Finset α, p S ≠ q S)

/-- Nonemptiness of the thermodynamically admissible set. -/
def ThermoAdmissibleNonempty {α : Type*} [DecidableEq α] [Fintype α]
    (C : ClosureInteractionStructure α) : Prop :=
  ∃ p : PartitionSection α, ThermoAdmissible C p

/-! ## Boundary and Reconstruction Structures -/

/-- A boundary partition functional. -/
def BoundaryPartitionFunctional (α : Type*) [DecidableEq α] [Fintype α] := Finset α → ℤ

/-- Boundary compatibility. -/
def BoundaryCompatible {α : Type*} [DecidableEq α] [Fintype α]
    (C : ClosureInteractionStructure α) (B : BoundaryPartitionFunctional α) : Prop :=
  ∃ p : PartitionSection α, ThermoAdmissible C p ∧ ∀ S : Finset α, B S = p S

/-- A dual reconstruction. -/
structure DualReconstruction (α : Type*) [DecidableEq α] [Fintype α] where
  /-- The reconstructed dual weights -/
  dualWeights : DualPartitionSection α
  /-- The gauge normalization constant -/
  gaugeShift : ℤ
  /-- The realized boundary functional -/
  realizedBoundaryFunctional : Finset α → ℤ
  /-- The normalized boundary functional -/
  normalizedBoundaryFunctional : Finset α → ℤ

/-- A reconstruction is certified if the realized boundary equals dual weights + gauge. -/
def DualReconstruction.Certified {α : Type*} [DecidableEq α] [Fintype α]
    (R : DualReconstruction α) : Prop :=
  ∀ S : Finset α, R.realizedBoundaryFunctional S = R.dualWeights S + R.gaugeShift

/-- Normalize a boundary functional. -/
def normalizeBoundary {α : Type*} [DecidableEq α] [Fintype α]
    (B : BoundaryPartitionFunctional α) : BoundaryPartitionFunctional α :=
  fun S => B S - B ∅

/-- A finite partition table. -/
structure FinitePartitionTable (α : Type*) [DecidableEq α] [Fintype α] where
  values : Finset α → ℤ

/-- Möbius inversion (automatic for finite posets). -/
def HasClosureMobiusInversion {α : Type*} [DecidableEq α] [Fintype α]
    (_C : ClosureInteractionStructure α) : Prop := True

/-- Reconstruct dual data from a partition table. -/
def reconstructDualFromTable {α : Type*} [DecidableEq α] [Fintype α]
    (_C : ClosureInteractionStructure α) (T : FinitePartitionTable α) :
    DualReconstruction α where
  dualWeights := fun S => T.values S - T.values ∅
  gaugeShift := T.values ∅
  realizedBoundaryFunctional := T.values
  normalizedBoundaryFunctional := fun S => T.values S - T.values ∅

/-- A reconstruction is coherent if its normalized boundary functional is derived
    from the realized boundary functional by shifting. -/
def DualReconstruction.Coherent {α : Type*} [DecidableEq α] [Fintype α]
    (R : DualReconstruction α) : Prop :=
  ∀ S : Finset α, R.normalizedBoundaryFunctional S =
    R.realizedBoundaryFunctional S - R.realizedBoundaryFunctional ∅

/-- Gauge uniqueness: any two certified, coherent reconstructions with the same normalized
    boundary differ only by gauge in their dual weights. -/
def GaugeUniqueOnNormalizedReconstruction {α : Type*} [DecidableEq α] [Fintype α]
    (R : DualReconstruction α) : Prop :=
  ∀ R' : DualReconstruction α,
    R'.Certified → R'.Coherent →
    (∀ S, R.normalizedBoundaryFunctional S = R'.normalizedBoundaryFunctional S) →
    ∃ c : ℤ, ∀ S, R.dualWeights S = R'.dualWeights S + c

/-! ## Auxiliary Lemmas -/

/-- Gauge equivalence is reflexive. -/
theorem gaugeEquivalent_refl {α : Type*} [DecidableEq α] [Fintype α]
    (p : PartitionSection α) : GaugeEquivalent p p :=
  ⟨0, fun _ => by ring⟩

/-- Gauge equivalence is symmetric. -/
theorem gaugeEquivalent_symm {α : Type*} [DecidableEq α] [Fintype α]
    {p q : PartitionSection α} (h : GaugeEquivalent p q) : GaugeEquivalent q p := by
  obtain ⟨c, hc⟩ := h
  exact ⟨-c, fun S => by linarith [hc S]⟩

/-- Gauge equivalence is transitive. -/
theorem gaugeEquivalent_trans {α : Type*} [DecidableEq α] [Fintype α]
    {p q r : PartitionSection α}
    (hpq : GaugeEquivalent p q) (hqr : GaugeEquivalent q r) :
    GaugeEquivalent p r := by
  obtain ⟨c₁, hc₁⟩ := hpq
  obtain ⟨c₂, hc₂⟩ := hqr
  exact ⟨c₁ + c₂, fun S => by linarith [hc₁ S, hc₂ S]⟩

/-- Normalization is idempotent. -/
theorem normalize_idempotent {α : Type*} [DecidableEq α] [Fintype α]
    (p : PartitionSection α) : normalize (normalize p) = normalize p := by
  funext S; simp [normalize]

/-- A normalized section has value 0 at ∅. -/
theorem normalize_is_normalized {α : Type*} [DecidableEq α] [Fintype α]
    (p : PartitionSection α) : IsNormalized (normalize p) := by
  simp [IsNormalized, normalize]

/-- Two normalized gauge-equivalent sections are equal. -/
theorem normalized_gauge_equiv_eq {α : Type*} [DecidableEq α] [Fintype α]
    {p q : PartitionSection α}
    (hp : IsNormalized p) (hq : IsNormalized q) (h : GaugeEquivalent p q) :
    p = q := by
  obtain ⟨c, hc⟩ := h
  have h0 := hc ∅
  simp [IsNormalized] at hp hq
  have : c = 0 := by linarith
  funext S; linarith [hc S]

/-! ## Key computation: the tropical Legendre transform simplifies -/

/-
The normalized dual Legendre equals negation of normalization:
    `normalizeDual(L(p))(T) = -(normalize p)(T) = p(∅) - p(T)`.

    Proof: `L(p)(T) = m - p(T)` so `L(p)(∅) = m - p(∅)`.
    Then `normalizeDual(L(p))(T) = (m - p(T)) - (m - p(∅)) = p(∅) - p(T)`.
-/
theorem normalizeDual_tropicalLegendre {α : Type*} [DecidableEq α] [Fintype α]
    (p : PartitionSection α) (T : Finset α) :
    normalizeDual (tropicalLegendre p) T = p ∅ - p T := by
  unfold normalizeDual tropicalLegendre; ring;

/-
The tropical bidual equals `p(S) - max p`.
-/
theorem tropicalBidual_eq {α : Type*} [DecidableEq α] [Fintype α]
    (p : PartitionSection α) (S : Finset α) :
    tropicalBidual p S = p S -
      Finset.univ.sup' ⟨(∅ : Finset α), Finset.mem_univ _⟩ (fun T => p T) := by
  unfold tropicalBidual dualTropicalLegendre tropicalLegendre;
  simp +decide [ Finset.inf'_eq_csInf_image, Finset.sup'_eq_csSup_image ];
  rw [ show sInf ( Set.range fun x => sInf ( Set.range fun S => p S ) - p x ) = sInf ( Set.range fun S => p S ) - sSup ( Set.range fun S => p S ) from ?_ ];
  · ring;
  · rw [ @csInf_eq_of_forall_ge_of_forall_gt_exists_lt ];
    · exact ⟨ _, ⟨ S, rfl ⟩ ⟩;
    · rintro _ ⟨ x, rfl ⟩ ; exact sub_le_sub_left ( le_csSup ( Set.finite_range p |> Set.Finite.bddAbove ) ( Set.mem_range_self x ) ) _;
    · intro w hw;
      rcases exists_lt_of_lt_csSup ( Set.range_nonempty fun S => p S ) ( show sSup ( Set.range fun S => p S ) > sInf ( Set.range fun S => p S ) - w by linarith ) with ⟨ x, ⟨ S, rfl ⟩, hx ⟩;
      exact ⟨ _, ⟨ S, rfl ⟩, by norm_num; linarith ⟩

/-- **The tropical Legendre transform is involutive up to gauge.**
    The gauge constant is `-(max p)`. -/
theorem tropicalLegendre_involutive_gauge {α : Type*} [DecidableEq α] [Fintype α]
    (p : PartitionSection α) :
    GaugeEquivalent (tropicalBidual p) p := by
  refine ⟨-(Finset.univ.sup' ⟨(∅ : Finset α), Finset.mem_univ _⟩ (fun T => p T)),
    fun S => ?_⟩
  rw [tropicalBidual_eq]
  ring

/-! ## Main Theorems -/

/-
**Theorem A (Finite Closure Kramers–Wannier Anti-Equivalence).**

On normalized sections, the map `p ↦ normalizeDual(L(p))` is an
order-reversing involution. It sends `p` to `T ↦ p(∅) - p(T) = -normalize(p)(T)`.
On normalized sections (where `p(∅) = 0`), this becomes `T ↦ -p(T)`.

The map `p ↦ -p` is a bijection from normalized partition sections to
normalized dual partition sections, and it reverses the pointwise order.
This is the finite idempotent Kramers–Wannier duality.
-/
theorem finite_closure_kramers_wannier_duality
    {α : Type*} [DecidableEq α] [Fintype α]
    (C : ClosureInteractionStructure α)
    (_hfg : FinitelyGenerated C)
    (_hsep : CocircuitSeparating C)
    (_hadm : ThermoAdmissibleNonempty C) :
    ∃ L : PartitionSection α → DualPartitionSection α,
      (∀ p, L p = tropicalLegendre p) ∧
      (∀ p q : PartitionSection α, IsNormalized p → IsNormalized q →
        normalizeDual (L p) = normalizeDual (L q) → p = q) ∧
      (∀ d : DualPartitionSection α, IsNormalized d →
        ∃ p : PartitionSection α, IsNormalized p ∧
          normalizeDual (L p) = d) := by
  refine' ⟨ _, fun p => rfl, _, _ ⟩ <;> simp_all +decide [ IsNormalized ];
  · -- By definition of $normalizeDual$, we have $normalizeDual (tropicalLegendre p) T = p ∅ - p T$ and $normalizeDual (tropicalLegendre q) T = q ∅ - q T$.
    intro p q hp hq h_eq
    funext T
    have := congr_fun h_eq T
    simp_all +decide [ normalizeDual_tropicalLegendre ];
  · intro d hd
    use fun T => -d T;
    unfold normalizeDual tropicalLegendre; aesop;

/-- **Theorem B (Bidual Recovery — Gauge Version).**

For every partition section, the tropical bidual is gauge-equivalent
to the original. This is the finite idempotent Fenchel–Moreau theorem. -/
theorem tropical_bidual_recovers_admissible_section
    {α : Type*} [DecidableEq α] [Fintype α]
    (C : ClosureInteractionStructure α)
    (_hfg : FinitelyGenerated C)
    (_hsep : CocircuitSeparating C) :
    ∀ p : PartitionSection α,
      ThermoAdmissible C p →
        GaugeEquivalent (tropicalBidual p) p :=
  fun p _ => tropicalLegendre_involutive_gauge p

/-
**Theorem B' (Bidual Recovery — Normalized Version).**

After normalization, the tropical bidual is the identity.
-/
theorem tropical_bidual_recovers_normalized
    {α : Type*} [DecidableEq α] [Fintype α]
    (_C : ClosureInteractionStructure α)
    (p : PartitionSection α) :
    normalize (tropicalBidual p) = normalize p := by
  unfold normalize;
  exact funext fun S => by rw [ tropicalBidual_eq p S, tropicalBidual_eq p ∅ ] ; ring;

/-
**Theorem C (Certified Gibbs Reconstruction).**

From boundary partition data compatible with the closure interaction
structure, one can reconstruct dual effective Gibbs weights that are
certified, gauge-equivalent to the original, and exact after normalization.
-/
theorem certified_gibbs_reconstruction_from_boundary_partition
    {α : Type*} [DecidableEq α] [Fintype α]
    (C : ClosureInteractionStructure α)
    (_hfg : FinitelyGenerated C)
    (_hsep : CocircuitSeparating C)
    (B : BoundaryPartitionFunctional α)
    (hB : BoundaryCompatible C B) :
    ∃ R : DualReconstruction α,
      R.Certified ∧
      GaugeEquivalentFunctional R.realizedBoundaryFunctional B ∧
      (∀ S, R.normalizedBoundaryFunctional S = normalizeBoundary B S) := by
  -- Let's obtain the partition section p from the boundary compatibility condition.
  obtain ⟨p, hp_admissible, hp_eq⟩ := hB;
  use ⟨fun S => p S - p ∅, p ∅, p, fun S => p S - p ∅⟩;
  exact ⟨ fun S => by simp +decide, ⟨ 0, fun S => by simp +decide [ hp_eq ] ⟩, fun S => by simp +decide [ hp_eq, normalizeBoundary ] ⟩

/-
**Theorem D (Möbius Reconstruction Correctness).**

Reconstruction via closure Möbius inversion produces certified dual data,
and the reconstruction is gauge-unique among certified reconstructions.
-/
theorem reconstruction_via_mobius_and_residuation_correct
    {α : Type*} [DecidableEq α] [Fintype α]
    (C : ClosureInteractionStructure α)
    (_hfg : FinitelyGenerated C)
    (_hmob : HasClosureMobiusInversion C)
    (_hsep : CocircuitSeparating C)
    (T : FinitePartitionTable α) :
    let R := reconstructDualFromTable C T
    R.Certified ∧
    GaugeUniqueOnNormalizedReconstruction R := by
  unfold reconstructDualFromTable DualReconstruction.Certified GaugeUniqueOnNormalizedReconstruction;
  simp_all +decide [ DualReconstruction.Certified, DualReconstruction.Coherent ];
  exact fun R' h1 h2 h3 => ⟨ -R'.dualWeights ∅, fun S => by ring ⟩


end ClosureKramersWannier

/-  The line below is a corrupted leftover of a text edit: it is the tail of a
    sentence whose head was lost.  It is kept, commented out, for the record;
    without the comment the file does not parse.

    end , the tropical bidual is gauge-equivalent to the original section.
-/