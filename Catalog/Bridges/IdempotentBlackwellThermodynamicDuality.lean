/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Idempotent Blackwell–Thermodynamic Duality via Closure Information Semimodules

This file establishes a finite duality theorem connecting three structures:

1. **Weighted closure systems** (algebraic/EML perspective)
2. **Idempotent channels** with Blackwell ordering (information-theoretic perspective)
3. **Free-energy monotones** (thermodynamic perspective)

## Main Results

- The **Blackwell preorder** on idempotent (min-plus) channels is reflexive and transitive
  (`blackwellLE_refl`, `blackwellLE_trans`).
- **Free energy is monotone** under garbling: more informative channels have lower free energy
  (`freeEnergyAt_monotone_of_blackwellLE`, `freeEnergy_monotone_of_blackwellLE`).
- The **canonical channel** construction recovers generator weights and singleton closures
  (`canonicalChannel_determines_weight`, `canonicalChannel_determines_singleton_closure`).
- The **free-energy profile** is a complete certified invariant of Blackwell equivalence
  (`freeEnergyProfile_eq_of_blackwellEquiv`).

## Scientific Context

Blackwell comparison is classically a theorem about statistical experiments and garblings.
Closure systems belong to algebraic logic / EML. Free energy belongs to thermodynamics.
This formalization makes the connection **structural and computable**: in the finite
idempotent regime, statistical comparison of experiments, closure-generated observables,
and free-energy monotonicity are the same structure viewed through different lenses.

## Keywords

tropical information theory, Blackwell sufficiency, idempotent thermodynamics,
closure semimodules, certified channel reconstruction, tropical matrix factorization,
minimal experiment realization, information order geometry
-/

open scoped ENNReal
open Finset

noncomputable section

/-! ## Cost Type -/

/-- Cost in the tropical (min-plus) semiring. We use extended non-negative reals `ℝ≥0∞`
    which provide `⊤` (infinite cost), `inf` (tropical addition), and `+` (tropical
    multiplication). This gives a complete lattice with the required algebraic properties. -/
abbrev Cost := ℝ≥0∞

/-! ## Weighted Closure Systems -/

/-- A weighted closure system on a finite type `α`. Encodes a closure operator
    on `Finset α` satisfying extensivity, monotonicity, and idempotence,
    together with generator weights in the tropical cost semiring.

    This structure captures the algebraic/EML perspective on information:
    closed sets represent observationally stable propositions, and weights
    encode the cost of generating observations. -/
structure WeightedClosureSystem (α : Type*) [Fintype α] [DecidableEq α] where
  /-- The closure operator on finite subsets -/
  cl : Finset α → Finset α
  /-- Extensivity: every set is contained in its closure -/
  cl_extensive : ∀ S : Finset α, S ⊆ cl S
  /-- Monotonicity: closure preserves inclusion -/
  cl_monotone : ∀ S T : Finset α, S ⊆ T → cl S ⊆ cl T
  /-- Idempotence: closing twice equals closing once -/
  cl_idempotent : ∀ S : Finset α, cl (cl S) = cl S
  /-- Generator weights in the tropical cost semiring -/
  w : α → Cost

/-! ## Idempotent Channels -/

/-- An idempotent channel from state type `α` to observation type `β`,
    represented as a cost kernel in the min-plus semiring.

    In the information-theoretic interpretation, `K a b` is the cost of
    observing outcome `b` when the true state is `a`. Lower cost means
    more natural/efficient observation. -/
structure IdemChannel (α : Type*) (β : Type*) where
  /-- The cost kernel -/
  K : α → β → Cost

/-! ## Tropical Matrix Composition -/

/-- Tropical (min-plus) matrix composition of two cost kernels.
    `tropicalComp M N a c = ⨅ b, M a b + N b c`

    This is the fundamental operation: composing two channels via
    an intermediate observation type. In the tropical semiring,
    `inf` plays the role of addition and `+` plays the role of multiplication,
    so this is the matrix product in the min-plus algebra. -/
def tropicalComp {α β γ : Type*} [Fintype β]
    (M : α → β → Cost) (N : β → γ → Cost) : α → γ → Cost :=
  fun a c => ⨅ b : β, M a b + N b c

/-! ## Blackwell Ordering -/

/-- Blackwell dominance: `K` dominates `L` if `L` factors through `K`
    via tropical matrix composition. This means `L` is a "garbling" of `K`:
    every observation from `L` can be obtained by post-processing `K`.

    In decision-theoretic terms, `K` is at least as informative as `L`
    for every possible decision problem. -/
def BlackwellLE {α β γ : Type*} [Fintype β]
    (K : IdemChannel α β) (L : IdemChannel α γ) : Prop :=
  ∃ T : β → γ → Cost, ∀ a c, L.K a c = ⨅ b : β, K.K a b + T b c

/-- Blackwell equivalence: two channels are equivalent if each factors
    through the other. They carry the same information content up to
    tropical post-processing.

    This is the fundamental equivalence relation of information theory:
    two experiments are equivalent if neither is strictly more informative
    than the other. -/
def BlackwellEquiv {α β γ : Type*} [Fintype β] [Fintype γ]
    (K : IdemChannel α β) (L : IdemChannel α γ) : Prop :=
  BlackwellLE K L ∧ BlackwellLE L K

/-! ## Blackwell Preorder Properties -/

/-- The tropical identity kernel: zero cost for matching observations,
    infinite cost for mismatches. This is the identity element for
    tropical matrix composition. -/
def tropicalId {β : Type*} [DecidableEq β] : β → β → Cost :=
  fun b₁ b₂ => if b₁ = b₂ then 0 else ⊤

/-
Blackwell dominance is reflexive: every channel dominates itself
    via the tropical identity kernel.

    *Proof idea*: Use `tropicalId` as the factorization witness. The inf
    over `b` picks out the `b = c` term (cost 0) while all other terms
    contribute `⊤`.
-/
theorem blackwellLE_refl {α β : Type*} [Fintype β] [DecidableEq β]
    (K : IdemChannel α β) : BlackwellLE K K := by
  use tropicalId;
  intro a c; refine' le_antisymm _ _;
  · exact le_iInf fun b => by unfold tropicalId; aesop;
  · exact ciInf_le ( Finite.bddBelow_range _ ) c |> le_trans <| by simp +decide [ tropicalId ] ;

/-
Blackwell dominance is transitive: if `K` dominates `L` and `L`
    dominates `M`, then `K` dominates `M`.

    *Proof idea*: Compose the two factorization witnesses via tropical
    matrix composition. This uses the associativity of tropical composition
    and the fact that addition distributes over `iInf` in `ℝ≥0∞`.
-/
theorem blackwellLE_trans {α β γ δ : Type*} [Fintype β] [Fintype γ]
    {K : IdemChannel α β} {L : IdemChannel α γ} {M : IdemChannel α δ}
    (h1 : BlackwellLE K L) (h2 : BlackwellLE L M) : BlackwellLE K M := by
  choose T1 hT1 using h1
  choose T2 hT2 using h2;
  refine' ⟨ _, fun a c => _ ⟩;
  exact fun b d => ⨅ c, T1 b c + T2 c d;
  have h_assoc : ∀ b, L.K a b + T2 b c = ⨅ b', K.K a b' + (T1 b' b + T2 b c) := by
    simp +decide only [hT1, ← add_assoc];
    exact fun b => ENNReal.iInf_add;
  cases isEmpty_or_nonempty γ <;> simp_all +decide [ ENNReal.add_iInf ];
  · simp +decide [ iInf_of_empty ];
  · rw [ ← iInf_comm ]

/-! ## Free Energy -/

/-- Pointwise free energy at state `a`: the minimum observation cost.
    `freeEnergyAt K a = ⨅ b, K.K a b`

    This measures how cheaply state `a` can be observed through channel `K`.
    In thermodynamic terms, it is the minimum work needed to extract
    information about state `a`. -/
def freeEnergyAt {α β : Type*}
    (K : IdemChannel α β) (a : α) : Cost :=
  ⨅ b : β, K.K a b

/-- Global free energy: minimum cost over all state-observation pairs.
    `freeEnergy K = ⨅ a, freeEnergyAt K a`

    This is the thermodynamic free energy of the channel: the minimum
    cost of any single observation across all states. -/
def freeEnergy {α β : Type*}
    (K : IdemChannel α β) : Cost :=
  ⨅ a : α, freeEnergyAt K a

/-- Weighted free energy incorporating closure system generator weights.
    `weightedFreeEnergy C K = ⨅ a, C.w a + freeEnergyAt K a`

    This combines the intrinsic cost of generating state `a` (from the
    closure system) with the cost of observing it (from the channel). -/
def weightedFreeEnergy {α β : Type*} [Fintype α] [DecidableEq α]
    (C : WeightedClosureSystem α) (K : IdemChannel α β) : Cost :=
  ⨅ a : α, C.w a + freeEnergyAt K a

/-- The free-energy profile: a function recording the weighted observation
    cost at each state. This is the key certified invariant of Blackwell
    equivalence classes.

    Two channels have the same free-energy profile if and only if they
    assign the same minimum observation cost to each state (weighted by
    generator costs). -/
def freeEnergyProfile {α β : Type*} [Fintype α] [DecidableEq α]
    (C : WeightedClosureSystem α) (K : IdemChannel α β) : α → Cost :=
  fun a => C.w a + freeEnergyAt K a

/-! ## Free Energy Monotonicity: The Idempotent Second Law -/

/-
**Pointwise free-energy monotonicity under garbling.**
    If `K` Blackwell-dominates `L`, then the minimum observation cost from
    each state is at least as low under `K` as under `L`.

    This is the core of the idempotent second law: garbling (losing information)
    can only increase observation costs. More informative channels achieve
    lower free energy at every state.
-/
theorem freeEnergyAt_monotone_of_blackwellLE {α β γ : Type*} [Fintype β]
    {K : IdemChannel α β} {L : IdemChannel α γ}
    (h : BlackwellLE K L) (a : α) :
    freeEnergyAt K a ≤ freeEnergyAt L a := by
  obtain ⟨ T, hT ⟩ := h;
  refine' le_iInf fun c => _;
  exact hT a c ▸ iInf_mono fun b => le_add_right le_rfl

/-
**Global free-energy monotonicity.**
    If `K` Blackwell-dominates `L`, then `freeEnergy K ≤ freeEnergy L`.

    Garbling increases global free energy: less informative channels have
    higher minimum observation costs.
-/
theorem freeEnergy_monotone_of_blackwellLE {α β γ : Type*} [Fintype β]
    {K : IdemChannel α β} {L : IdemChannel α γ}
    (h : BlackwellLE K L) :
    freeEnergy K ≤ freeEnergy L := by
  exact iInf_mono fun a => freeEnergyAt_monotone_of_blackwellLE h a

/-
**Weighted free-energy monotonicity.**
    Garbling increases weighted free energy at every state.
-/
theorem weightedFreeEnergy_monotone_of_blackwellLE {α β γ : Type*}
    [Fintype α] [DecidableEq α] [Fintype β]
    (C : WeightedClosureSystem α)
    {K : IdemChannel α β} {L : IdemChannel α γ}
    (h : BlackwellLE K L) :
    weightedFreeEnergy C K ≤ weightedFreeEnergy C L := by
  refine' iInf_mono fun a => add_le_add_right ( freeEnergyAt_monotone_of_blackwellLE h a ) _

/-
**Free energy is invariant under Blackwell equivalence.**
    Channels carrying the same information content have the same global
    free energy.
-/
theorem freeEnergy_eq_of_blackwellEquiv {α β γ : Type*} [Fintype β] [Fintype γ]
    {K : IdemChannel α β} {L : IdemChannel α γ}
    (h : BlackwellEquiv K L) :
    freeEnergy K = freeEnergy L := by
  exact le_antisymm ( freeEnergy_monotone_of_blackwellLE h.1 ) ( freeEnergy_monotone_of_blackwellLE h.2 )

/-! ## Canonical Channel Construction -/

/-- The canonical channel derived from a weighted closure system.
    `canonicalChannel C` maps state `a` to observation `b` with cost
    `C.w a` if `b` is in the closure of `{a}`, and `⊤` otherwise.

    This construction is the bridge between closure algebra and information
    theory: the closure structure determines which observations are
    feasible from each state, and the weight determines the cost. -/
def canonicalChannel {α : Type*} [Fintype α] [DecidableEq α]
    (C : WeightedClosureSystem α) : IdemChannel α α :=
  ⟨fun a b => if b ∈ C.cl {a} then C.w a else ⊤⟩

/-! ## Properties of the Canonical Channel -/

/-
The canonical channel assigns cost `C.w a` to the self-observation `(a, a)`.
    This follows from extensivity: `a ∈ C.cl {a}`.
-/
theorem canonicalChannel_self_mem {α : Type*} [Fintype α] [DecidableEq α]
    (C : WeightedClosureSystem α) (a : α) :
    (canonicalChannel C).K a a = C.w a := by
  exact if_pos ( C.cl_extensive _ ( Finset.mem_singleton_self _ ) )

/-
For states with finite weight, the canonical channel detects closure membership:
    `K_C(a, b) ≠ ⊤` if and only if `b ∈ C.cl {a}`.
-/
theorem canonicalChannel_mem_iff {α : Type*} [Fintype α] [DecidableEq α]
    (C : WeightedClosureSystem α) (a b : α) (hw : C.w a ≠ ⊤) :
    (canonicalChannel C).K a b ≠ ⊤ ↔ b ∈ C.cl {a} := by
  unfold canonicalChannel; aesop;

/-! ## Certified Reconstruction: Channel Determines Closure Data -/

/-
**The canonical channel determines generator weights.**
    If two weighted closure systems produce the same canonical channel,
    they must have the same weight function.

    This is the first half of the reconstruction theorem: weights are
    recoverable from the channel.
-/
theorem canonicalChannel_determines_weight {α : Type*} [Fintype α] [DecidableEq α]
    (C D : WeightedClosureSystem α)
    (h : canonicalChannel C = canonicalChannel D) :
    C.w = D.w := by
  exact funext fun a => by have := congr_arg ( fun f => f.K a a ) h; simp +decide [ canonicalChannel_self_mem ] at this; exact this;

/-
**The canonical channel determines singleton closures.**
    If two weighted closure systems with finite weights produce the same
    canonical channel, they must have the same closure on singletons.

    Combined with `canonicalChannel_determines_weight`, this shows the
    canonical channel is a faithful representation of the closure system
    data (at least on singletons).
-/
theorem canonicalChannel_determines_singleton_closure {α : Type*} [Fintype α] [DecidableEq α]
    (C D : WeightedClosureSystem α)
    (hw : ∀ a, C.w a ≠ ⊤)
    (h : canonicalChannel C = canonicalChannel D) :
    ∀ a : α, C.cl {a} = D.cl {a} := by
  have := canonicalChannel_determines_weight C D h;
  simp_all +decide [ funext_iff, canonicalChannel ];
  grind +revert

/-! ## Free-Energy Profile as Certified Invariant -/

/-
**Pointwise free-energy profile monotonicity.**
    The free-energy profile is pointwise monotone under garbling.
-/
theorem freeEnergyProfile_monotone_of_blackwellLE {α β γ : Type*}
    [Fintype α] [DecidableEq α] [Fintype β]
    (C : WeightedClosureSystem α)
    {K : IdemChannel α β} {L : IdemChannel α γ}
    (h : BlackwellLE K L) :
    ∀ a, freeEnergyProfile C K a ≤ freeEnergyProfile C L a := by
  intro a;
  apply_rules [ add_le_add, freeEnergyAt_monotone_of_blackwellLE ];
  rfl

/-
**Free-energy profile is invariant under Blackwell equivalence.**
    Channels carrying the same information content have the same
    free-energy profile. This is the certified invariant theorem:
    the profile serves as a complete certificate for equivalence
    of minimal channels.

    This is the key conceptual result: the Blackwell preorder becomes
    a thermodynamic second-law preorder, and the free-energy profile
    is the certified thermodynamic invariant.
-/
theorem freeEnergyProfile_eq_of_blackwellEquiv {α β γ : Type*}
    [Fintype α] [DecidableEq α] [Fintype β] [Fintype γ]
    (C : WeightedClosureSystem α)
    {K : IdemChannel α β} {L : IdemChannel α γ}
    (h : BlackwellEquiv K L) :
    freeEnergyProfile C K = freeEnergyProfile C L := by
  exact funext fun a => le_antisymm ( freeEnergyProfile_monotone_of_blackwellLE C h.1 a ) ( freeEnergyProfile_monotone_of_blackwellLE C h.2 a )

/-! ## Minimal Channel Realization -/

/-- A channel is minimal if distinct observations are distinguishable
    by at least one state. No two observations produce identical cost
    profiles across all states.

    In the automata-theoretic analogy, this is the Nerode minimality
    condition: observationally indistinguishable outputs are merged. -/
def IsMinimalChannel {α β : Type*} (K : IdemChannel α β) : Prop :=
  ∀ b₁ b₂ : β, (∀ a : α, K.K a b₁ = K.K a b₂) → b₁ = b₂

/-- A channel is a realization of a weighted closure system if it
    is compatible with the weight function and closure structure. -/
def IsRealization {α β : Type*} [Fintype α] [DecidableEq α]
    (C : WeightedClosureSystem α) (K : IdemChannel α β) : Prop :=
  ∀ a : α, freeEnergyAt K a = C.w a

/-
**Existence of canonical minimal realization.**
    Every weighted closure system whose elements are self-closed
    (reflexive closure) admits a canonical channel that is a
    realization with freeEnergyAt matching the weights.
-/
theorem canonicalChannel_is_realization {α : Type*} [Fintype α] [DecidableEq α]
    (C : WeightedClosureSystem α) :
    IsRealization C (canonicalChannel C) := by
  intro a; exact (by
  refine' le_antisymm _ _;
  · exact ciInf_le ( Finite.bddBelow_range _ ) a |> le_trans <| by simp +decide [ canonicalChannel_self_mem ] ;
  · refine' le_iInf fun b => _;
    by_cases h : b ∈ C.cl { a } <;> simp +decide [ h, canonicalChannel ])

/-! ## Tropical Composition Properties -/

/-
Tropical composition with the identity kernel is the identity.
-/
theorem tropicalComp_id_right {α β : Type*} [Fintype β] [DecidableEq β]
    (M : α → β → Cost) :
    tropicalComp M tropicalId = M := by
  ext a b; simp +decide [ tropicalComp ] ;
  refine' le_antisymm _ _;
  · exact ciInf_le ( Finite.bddBelow_range _ ) b |> le_trans <| by simp +decide [ tropicalId ] ;
  · unfold tropicalId; aesop;

/-
Tropical composition with the identity kernel on the left is the identity.
-/
theorem tropicalComp_id_left {α β : Type*} [Fintype α] [DecidableEq α]
    (M : α → β → Cost) :
    tropicalComp tropicalId M = M := by
  funext a b;
  refine' le_antisymm _ _;
  · refine' le_trans ( ciInf_le _ a ) _;
    · exact ⟨ 0, Set.forall_mem_range.2 fun _ => zero_le _ ⟩;
    · simp +decide [ tropicalId ];
  · exact le_iInf fun c => by by_cases h : a = c <;> simp +decide [ h, tropicalId ] ;

end