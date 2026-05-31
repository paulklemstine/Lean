/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic Research
-/
import Mathlib

/-!
# Interaction Information and Synergy Detection for Presheaves on Finite Sites

This file develops a **ternary interaction information** theory for presheaf compression
on finite sites, extending the pairwise mutual compression framework from the chain rule
catalog to detect **synergistic** (jointly-but-not-separately informative) structure.

## Main Definitions

* `interactionCompression J F G H` — ternary interaction information in ℤ
* `SynergyWitness J F G H` — categorical XOR synergy witness
* `SecretSharingWitness J F G H` — secret sharing interpretation

## Main Theorems

### Chain-Rule Identities
* `interactionCompression_eq_mutual_sub_conditional` —
  `I(F;G;H) = I(F;H) - I(F;H|G)` where `I(F;H|G) = conditionalMutualCompression J F G H`
* `interactionCompression_eq_mutual_sub_conditional'` —
  `I(F;G;H) = I(F;G) - I(F;G|H)` (symmetric variant)

### Synergy
* `interactionCompression_neg_of_synergyWitness` — XOR synergy forces negativity
* `secretSharing_implies_negative_interaction` — cross-domain (cryptography)

### Characterization
* `interactionCompression_neg_iff_conditional_exceeds` —
  `I(F;G;H) < 0 ⟺ I(F;H|G) > I(F;H)` (synergy = conditioning unlocks information)

## References

* Chain rule infrastructure: `Catalog.Bridges.Catalog.Pythagorean.ProbeComplexity.ChainRule`
-/

open CategoryTheory Finset Opposite

noncomputable section

universe u v

namespace InteractionInformation

variable {C : Type u} [Category.{v} C]

/-! ## Core Infrastructure (self-contained) -/

/-- Presheaf separated by probes. -/
def PresheafSeparatedByProbes (P : Finset C) (F : Cᵒᵖ ⥤ Type v) : Prop :=
  ∀ (X : C) (s t : F.obj (Opposite.op X)),
    (∀ Z ∈ P, ∀ (f : Z ⟶ X), F.map f.op s = F.map f.op t) → s = t

/-- Topology-compatible probe family. -/
def TopologyCompatibleProbes (J : GrothendieckTopology C) (P : Finset C) : Prop :=
  ∀ (X : C) (S : Sieve X), S ∈ J X → ∃ Z ∈ P, ∃ (f : Z ⟶ X), S.arrows f

/-- Valid compression cardinalities. -/
def sheafCompressionCards (J : GrothendieckTopology C) (F : Cᵒᵖ ⥤ Type v) : Set ℕ :=
  {n | ∃ P : Finset C, P.card = n ∧ PresheafSeparatedByProbes P F ∧
    TopologyCompatibleProbes J P}

/-- Sheaf compression number. -/
def sheafCompressionNumber [Fintype C] (J : GrothendieckTopology C)
    (F : Cᵒᵖ ⥤ Type v) : ℕ :=
  sInf (sheafCompressionCards J F)

/-- Pointwise coproduct presheaf. -/
@[simps]
def PresheafCoprod (F G : Cᵒᵖ ⥤ Type v) : Cᵒᵖ ⥤ Type v where
  obj X := Sum (F.obj X) (G.obj X)
  map f := Sum.map (F.map f) (G.map f)
  map_id X := by ext x; cases x <;> simp
  map_comp f g := by ext x; cases x <;> simp [types_comp]

/-- Mutual compression: `I_sh(F;G) := κ_sh(F) + κ_sh(G) - κ_sh(F⊕G)`. -/
def mutualCompression [Fintype C] (J : GrothendieckTopology C)
    (F G : Cᵒᵖ ⥤ Type v) : ℤ :=
  (sheafCompressionNumber J F : ℤ) + (sheafCompressionNumber J G : ℤ) -
    (sheafCompressionNumber J (PresheafCoprod F G) : ℤ)

/-- Conditional mutual compression: `I_sh(F;H|G) := I_sh(F;G⊕H) - I_sh(F;G)`.
This measures the mutual information between `F` and `H`, conditioned on
already having access to `G`. -/
def conditionalMutualCompression [Fintype C] (J : GrothendieckTopology C)
    (F G H : Cᵒᵖ ⥤ Type v) : ℤ :=
  mutualCompression J F (PresheafCoprod G H) - mutualCompression J F G

/-! ## Symmetry Infrastructure -/

theorem coprod_swap_separating (P : Finset C) (F G : Cᵒᵖ ⥤ Type v)
    (h : PresheafSeparatedByProbes P (PresheafCoprod F G)) :
    PresheafSeparatedByProbes P (PresheafCoprod G F) := by
  intro X s t hst
  have hinj : Function.Injective
      (Sum.swap : Sum (G.obj (op X)) (F.obj (op X)) →
        Sum (F.obj (op X)) (G.obj (op X))) := by
    intro a b hab; cases a <;> cases b <;> simp [Sum.swap] at hab <;> exact congrArg _ hab
  apply hinj
  apply h X (Sum.swap s) (Sum.swap t)
  intro Z hZ f; have := hst Z hZ f
  cases s <;> cases t <;> simp_all [PresheafCoprod, Sum.swap]

theorem sheafCompressionCards_coprod_swap
    (J : GrothendieckTopology C) (F G : Cᵒᵖ ⥤ Type v) :
    sheafCompressionCards J (PresheafCoprod F G) ⊆
      sheafCompressionCards J (PresheafCoprod G F) :=
  fun _ ⟨P, hcard, hsep, hcompat⟩ =>
    ⟨P, hcard, coprod_swap_separating P F G hsep, hcompat⟩

/-- `κ(F⊕G) = κ(G⊕F)`. -/
theorem sheafCompressionNumber_coprod_comm [Fintype C]
    (J : GrothendieckTopology C) (F G : Cᵒᵖ ⥤ Type v) :
    sheafCompressionNumber J (PresheafCoprod F G) =
      sheafCompressionNumber J (PresheafCoprod G F) := by
  unfold sheafCompressionNumber
  congr 1
  exact Set.Subset.antisymm
    (sheafCompressionCards_coprod_swap J F G)
    (sheafCompressionCards_coprod_swap J G F)

/-- `I_sh(F;G) = I_sh(G;F)`. -/
theorem mutualCompression_comm [Fintype C]
    (J : GrothendieckTopology C) (F G : Cᵒᵖ ⥤ Type v) :
    mutualCompression J F G = mutualCompression J G F := by
  unfold mutualCompression
  rw [sheafCompressionNumber_coprod_comm J F G]; omega

/-- Inner coproduct swap: separation of `F⊕(G⊕H)` implies separation of `F⊕(H⊕G)`. -/
theorem coprod_inner_swap_separating (P : Finset C)
    (F G H : Cᵒᵖ ⥤ Type v)
    (h : PresheafSeparatedByProbes P (PresheafCoprod F (PresheafCoprod G H))) :
    PresheafSeparatedByProbes P (PresheafCoprod F (PresheafCoprod H G)) := by
  intro X s t hst
  -- Map PresheafCoprod F (PresheafCoprod H G) → PresheafCoprod F (PresheafCoprod G H)
  -- by swapping the inner components
  let embed : (PresheafCoprod F (PresheafCoprod H G)).obj (op X) →
      (PresheafCoprod F (PresheafCoprod G H)).obj (op X) :=
    fun x => match x with
      | Sum.inl a => Sum.inl a
      | Sum.inr (Sum.inl b) => Sum.inr (Sum.inr b)
      | Sum.inr (Sum.inr c) => Sum.inr (Sum.inl c)
  have embed_inj : Function.Injective embed := by
    intro a b hab; cases a with
    | inl a => cases b with
      | inl b => simp_all [embed]
      | inr b => cases b <;> simp_all [embed]
    | inr a => cases a with
      | inl a => cases b with
        | inl b => simp_all [embed]
        | inr b => cases b <;> simp_all [embed]
      | inr a => cases b with
        | inl b => simp_all [embed]
        | inr b => cases b <;> simp_all [embed]
  apply embed_inj
  apply h X (embed s) (embed t)
  intro Z hZ f
  have := hst Z hZ f
  cases s with
  | inl a => cases t with
    | inl b => simp_all [embed, PresheafCoprod]
    | inr b => cases b <;> simp_all [embed, PresheafCoprod]
  | inr a => cases a with
    | inl a => cases t with
      | inl b => simp_all [embed, PresheafCoprod]
      | inr b => cases b <;> simp_all [embed, PresheafCoprod]
    | inr a => cases t with
      | inl b => simp_all [embed, PresheafCoprod]
      | inr b => cases b <;> simp_all [embed, PresheafCoprod]

/-- `κ(F⊕(G⊕H)) = κ(F⊕(H⊕G))`. -/
theorem sheafCompressionNumber_coprod_inner_comm [Fintype C]
    (J : GrothendieckTopology C) (F G H : Cᵒᵖ ⥤ Type v) :
    sheafCompressionNumber J (PresheafCoprod F (PresheafCoprod G H)) =
      sheafCompressionNumber J (PresheafCoprod F (PresheafCoprod H G)) := by
  unfold sheafCompressionNumber
  congr 1
  ext n
  constructor
  · rintro ⟨P, hcard, hsep, hcompat⟩
    exact ⟨P, hcard, coprod_inner_swap_separating P F G H hsep, hcompat⟩
  · rintro ⟨P, hcard, hsep, hcompat⟩
    exact ⟨P, hcard, coprod_inner_swap_separating P F H G hsep, hcompat⟩

/-- `I(F; G⊕H) = I(F; H⊕G)` — mutual compression sees through inner swaps. -/
theorem mutualCompression_coprod_comm [Fintype C]
    (J : GrothendieckTopology C) (F G H : Cᵒᵖ ⥤ Type v) :
    mutualCompression J F (PresheafCoprod G H) =
      mutualCompression J F (PresheafCoprod H G) := by
  unfold mutualCompression
  rw [sheafCompressionNumber_coprod_comm J G H,
      sheafCompressionNumber_coprod_inner_comm J F G H]

/-! ## Core New Definitions -/

/-- **Interaction compression (ternary interaction information).**
`I_sh(F;G;H) := I_sh(F;G) + I_sh(F;H) - I_sh(F;G⊕H)`.

Negative values indicate **synergy**: information emerging only from joint observation. -/
def interactionCompression [Fintype C] (J : GrothendieckTopology C)
    (F G H : Cᵒᵖ ⥤ Type v) : ℤ :=
  mutualCompression J F G + mutualCompression J F H -
    mutualCompression J F (PresheafCoprod G H)

/-- **Synergy witness**: `F` is jointly but not separately informative from `G,H`.
This is the categorical analogue of XOR synergy: no individual component carries
information, but the pair does. -/
structure SynergyWitness [Fintype C] (J : GrothendieckTopology C)
    (F G H : Cᵒᵖ ⥤ Type v) : Prop where
  /-- No pairwise information between F and G -/
  no_left_info : mutualCompression J F G = 0
  /-- No pairwise information between F and H -/
  no_right_info : mutualCompression J F H = 0
  /-- Positive joint information between F and G⊕H -/
  joint_info : 0 < mutualCompression J F (PresheafCoprod G H)

/-- **Secret sharing witness**: `G,H` are shares of secret `F`.
Mathematically equivalent to `SynergyWitness` but conceptually bridges
to cryptography and distributed computation.

In a threshold secret-sharing scheme, no single share reveals any information
about the secret (privacy), but combining all shares allows full reconstruction.
This structure captures exactly that pattern in the presheaf compression setting. -/
structure SecretSharingWitness [Fintype C] (J : GrothendieckTopology C)
    (F G H : Cᵒᵖ ⥤ Type v) : Prop where
  /-- Left share reveals nothing about the secret -/
  left_privacy : mutualCompression J F G = 0
  /-- Right share reveals nothing about the secret -/
  right_privacy : mutualCompression J F H = 0
  /-- Joint shares reveal information about the secret -/
  joint_recovery : 0 < mutualCompression J F (PresheafCoprod G H)

/-- Joint information splits additively: no synergy and no redundancy.
This is the "boring" case where components contribute independently. -/
def SplitJointInformation [Fintype C] (J : GrothendieckTopology C)
    (F G H : Cᵒᵖ ⥤ Type v) : Prop :=
  mutualCompression J F (PresheafCoprod G H) =
    mutualCompression J F G + mutualCompression J F H

/-! ## Theorem 1: Chain-Rule Identities -/

/-- **Interaction information equals mutual minus conditional (primary form).**

`I(F;G;H) = I(F;H) - I(F;H|G)`

where `I(F;H|G) = conditionalMutualCompression J F G H`.

This identity reveals the meaning of negative interaction:
- `I(F;G;H) < 0` iff `I(F;H|G) > I(F;H)`: conditioning on `G` *unlocks*
  information about `H` that was previously latent. This is the hallmark of synergy.
- `I(F;G;H) > 0` iff `I(F;H|G) < I(F;H)`: conditioning on `G` makes `H`
  less informative (redundancy).
- `I(F;G;H) = 0` iff conditioning has no effect. -/
theorem interactionCompression_eq_mutual_sub_conditional [Fintype C]
    (J : GrothendieckTopology C) (F G H : Cᵒᵖ ⥤ Type v) :
    interactionCompression J F G H =
      mutualCompression J F H - conditionalMutualCompression J F G H := by
  unfold interactionCompression conditionalMutualCompression
  omega

/-- **Symmetric chain-rule identity.**

`I(F;G;H) = I(F;G) - I(F;G|H)`

Uses commutativity of the coproduct to swap the roles of G and H. -/
theorem interactionCompression_eq_mutual_sub_conditional' [Fintype C]
    (J : GrothendieckTopology C) (F G H : Cᵒᵖ ⥤ Type v) :
    interactionCompression J F G H =
      mutualCompression J F G - conditionalMutualCompression J F H G := by
  unfold interactionCompression conditionalMutualCompression
  have := mutualCompression_coprod_comm J F G H
  linarith

/-- Chain rule: `I(F;G⊕H) = I(F;G) + I(F;H|G)`. -/
theorem mutualCompression_chain_rule [Fintype C]
    (J : GrothendieckTopology C) (F G H : Cᵒᵖ ⥤ Type v) :
    mutualCompression J F (PresheafCoprod G H) =
      mutualCompression J F G + conditionalMutualCompression J F G H := by
  unfold conditionalMutualCompression; omega

/-! ## Symmetry of Interaction Information -/

/-- **Interaction information is symmetric in observed components.**
`I(F;G;H) = I(F;H;G)`. -/
theorem interactionCompression_comm [Fintype C]
    (J : GrothendieckTopology C) (F G H : Cᵒᵖ ⥤ Type v) :
    interactionCompression J F G H = interactionCompression J F H G := by
  unfold interactionCompression
  have := mutualCompression_coprod_comm J F G H
  linarith

/-! ## Theorem 2: XOR-Style Synergy Criterion -/

/-- **Synergy witnesses force negative interaction information.**

If `F` shares no information with `G` or `H` individually, but shares positive
information with their joint observation `G⊕H`, then interaction information
is strictly negative. This is the **categorical XOR synergy theorem**.

The proof is direct: `I(F;G;H) = 0 + 0 - I(F;G⊕H) = -I(F;G⊕H) < 0`. -/
theorem interactionCompression_neg_of_synergyWitness [Fintype C]
    (J : GrothendieckTopology C)
    (F G H : Cᵒᵖ ⥤ Type v)
    (h : SynergyWitness J F G H) :
    interactionCompression J F G H < 0 := by
  unfold interactionCompression
  linarith [h.no_left_info, h.no_right_info, h.joint_info]

/-- **Explicit negativity from XOR-like hypotheses.** -/
theorem interactionCompression_neg_of_xorLike [Fintype C]
    (J : GrothendieckTopology C)
    (F G H : Cᵒᵖ ⥤ Type v)
    (hFG : mutualCompression J F G = 0)
    (hFH : mutualCompression J F H = 0)
    (hjoint : 0 < mutualCompression J F (PresheafCoprod G H)) :
    interactionCompression J F G H < 0 :=
  interactionCompression_neg_of_synergyWitness J F G H ⟨hFG, hFH, hjoint⟩

/-! ## Theorem 3: Secret Sharing Cross-Domain -/

/-- **Secret sharing implies negative interaction information.**

When `G` and `H` are shares of a secret `F`—each individually uninformative
but jointly reconstructive—the interaction information is negative.

This connects categorical information theory to:
- **Cryptography**: threshold secret-sharing schemes (Shamir, Blakley)
- **Neuroscience**: population codes where individual neurons carry no signal
  but the ensemble encodes the stimulus
- **Distributed computing**: coordination requiring joint local views
- **Physics**: entanglement where subsystems are individually uninformative -/
theorem secretSharing_implies_negative_interaction [Fintype C]
    (J : GrothendieckTopology C)
    (F G H : Cᵒᵖ ⥤ Type v)
    (h : SecretSharingWitness J F G H) :
    interactionCompression J F G H < 0 :=
  interactionCompression_neg_of_xorLike J F G H
    h.left_privacy h.right_privacy h.joint_recovery

/-- Converting between synergy witness and secret sharing witness. -/
theorem synergyWitness_iff_secretSharingWitness [Fintype C]
    (J : GrothendieckTopology C) (F G H : Cᵒᵖ ⥤ Type v) :
    SynergyWitness J F G H ↔ SecretSharingWitness J F G H :=
  ⟨fun h => ⟨h.no_left_info, h.no_right_info, h.joint_info⟩,
   fun h => ⟨h.left_privacy, h.right_privacy, h.joint_recovery⟩⟩

/-! ## Theorem 4: Positivity Barrier — Split Information -/

/-- **Split joint information implies zero interaction.**
When `I(F;G⊕H) = I(F;G) + I(F;H)` (joint information is additive),
interaction information vanishes—no synergy and no redundancy.

This identifies the exact condition under which ternary information reduces to
pairwise: the components contribute independently, like independent
random variables in classical information theory. -/
theorem interactionCompression_eq_zero_of_split [Fintype C]
    (J : GrothendieckTopology C)
    (F G H : Cᵒᵖ ⥤ Type v)
    (hsplit : SplitJointInformation J F G H) :
    interactionCompression J F G H = 0 := by
  unfold interactionCompression
  unfold SplitJointInformation at hsplit
  linarith

/-- **Nonneg interaction when joint ≤ sum of marginals.** -/
theorem interactionCompression_nonneg_of_joint_le_sum [Fintype C]
    (J : GrothendieckTopology C)
    (F G H : Cᵒᵖ ⥤ Type v)
    (hle : mutualCompression J F (PresheafCoprod G H) ≤
      mutualCompression J F G + mutualCompression J F H) :
    0 ≤ interactionCompression J F G H := by
  unfold interactionCompression; linarith

/-! ## Theorem 5: Characterization via Conditional Information -/

/-- **Negative interaction iff conditioning increases information.**
`I(F;G;H) < 0 ⟺ I(F;H|G) > I(F;H)`.

This is the conceptual theorem: synergy means that observing `G` *unlocks*
information about `H` that was latent before. The conditional information
exceeds the unconditional—a phenomenon impossible for independent variables
and the hallmark of emergent structure. -/
theorem interactionCompression_neg_iff_conditional_exceeds [Fintype C]
    (J : GrothendieckTopology C)
    (F G H : Cᵒᵖ ⥤ Type v) :
    interactionCompression J F G H < 0 ↔
      mutualCompression J F H < conditionalMutualCompression J F G H := by
  rw [interactionCompression_eq_mutual_sub_conditional]
  omega

/-- **Nonneg interaction iff conditioning does not increase information.** -/
theorem interactionCompression_nonneg_iff [Fintype C]
    (J : GrothendieckTopology C)
    (F G H : Cᵒᵖ ⥤ Type v) :
    0 ≤ interactionCompression J F G H ↔
      conditionalMutualCompression J F G H ≤ mutualCompression J F H := by
  rw [interactionCompression_eq_mutual_sub_conditional]
  omega

/-- **Zero interaction iff conditional equals unconditional.** -/
theorem interactionCompression_eq_zero_iff [Fintype C]
    (J : GrothendieckTopology C)
    (F G H : Cᵒᵖ ⥤ Type v) :
    interactionCompression J F G H = 0 ↔
      conditionalMutualCompression J F G H = mutualCompression J F H := by
  rw [interactionCompression_eq_mutual_sub_conditional]
  omega

/-! ## Additional Structural Results -/

/-- **Synergy from joint observation zero.**
If `I(F;G⊕H) = 0` then interaction = sum of marginals. -/
theorem interactionCompression_of_joint_zero [Fintype C]
    (J : GrothendieckTopology C) (F G H : Cᵒᵖ ⥤ Type v)
    (hjoint : mutualCompression J F (PresheafCoprod G H) = 0) :
    interactionCompression J F G H =
      mutualCompression J F G + mutualCompression J F H := by
  unfold interactionCompression; linarith

/-- **Interaction information as failure of chain-rule additivity.**
The chain rule gives `I(F;G⊕H) = I(F;G) + I(F;H|G)`.
Interaction information measures `I(F;H) - I(F;H|G)`:
positive means redundancy (conditioning wastes information),
negative means synergy (conditioning creates information). -/
theorem interactionCompression_measures_conditional_shift [Fintype C]
    (J : GrothendieckTopology C) (F G H : Cᵒᵖ ⥤ Type v) :
    interactionCompression J F G H =
      mutualCompression J F H - conditionalMutualCompression J F G H :=
  interactionCompression_eq_mutual_sub_conditional J F G H

/-- **Both chain-rule forms agree.** This connects the two perspectives:
`I(F;H) - I(F;H|G) = I(F;G) - I(F;G|H)`. -/
theorem conditional_shift_consistency [Fintype C]
    (J : GrothendieckTopology C) (F G H : Cᵒᵖ ⥤ Type v) :
    mutualCompression J F H - conditionalMutualCompression J F G H =
      mutualCompression J F G - conditionalMutualCompression J F H G := by
  rw [← interactionCompression_eq_mutual_sub_conditional,
      ← interactionCompression_eq_mutual_sub_conditional']

end InteractionInformation

end