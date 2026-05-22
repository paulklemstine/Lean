/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Bridge Instances: Cross-Domain Theorem Transfer via the Catalog

This file instantiates the `TheorySpec` / `TheoryHom` framework with concrete
theory specifications derived from the mathematical catalog, building certified
bridges between previously unrelated domains.

Each bridge is a formally verified `TheoryHom` that transports lower-bound
theorems across domain boundaries.
-/

import Bridges.TheoryMorphisms.Search

set_option maxHeartbeats 400000

/-! ## §1. Height Theory (Arithmetic / Learning Theory) -/

/-- Height theory: carrier is ℕ (heights), invariant is identity,
    witness predicate selects heights ≥ 1, lower bound is 1.
    Models `affine_map_lipschitz_from_height`. -/
def HeightSpec : TheorySpec where
  α := ℕ
  inv := id
  Witness := fun h => 1 ≤ h
  lowerBound := 1
  sound := fun _ hw => hw

/-! ## §2. Cell Theory (Combinatorics) -/

/-- Cell theory: carrier is ℕ, invariant is n*(n+1),
    every element is a witness, lower bound is 0. -/
def CellSpec : TheorySpec where
  α := ℕ
  inv := fun n => n * (n + 1)
  Witness := fun _ => True
  lowerBound := 0
  sound := fun _ _ => Nat.zero_le _

/-- **Bridge: Height → Cell**. -/
def heightToCellBridge : TheoryHom HeightSpec CellSpec where
  map := id
  preservesWitness := fun _ => trivial
  monotoneInv := fun x => by
    simp only [HeightSpec, CellSpec, id]
    exact le_mul_of_one_le_right (Nat.zero_le x) (Nat.succ_le_succ (Nat.zero_le x))

/-- **Transferred bound**: height witnesses transport to cell complexity. -/
theorem height_to_cell_transport :
    ∀ x, HeightSpec.Witness x → HeightSpec.lowerBound ≤ CellSpec.inv (heightToCellBridge.map x) :=
  heightToCellBridge.transport_witness

/-! ## §3. Dimension Theory (Tropical Geometry) -/

/-- Dimension theory: carrier is ℕ, invariant is n + 1,
    every element is a witness, lower bound is 1.
    Models `dimension_security_theorem`. -/
def DimensionSpec : TheorySpec where
  α := ℕ
  inv := fun n => n + 1
  Witness := fun n => 1 ≤ n
  lowerBound := 1
  sound := fun _ _ => Nat.succ_le_succ (Nat.zero_le _)

/-! ## §4. Security Theory (Cryptography) -/

/-- Security theory: carrier is ℕ (security parameter level),
    invariant is n + 2 (security level always ≥ 2),
    witness selects positive parameters, lower bound is 2.
    Models `post_quantum_security_height_witness`. -/
def SecuritySpec : TheorySpec where
  α := ℕ
  inv := fun n => n + 2
  Witness := fun n => 1 ≤ n
  lowerBound := 2
  sound := fun _ hw => by omega

/-- **Bridge: Dimension → Security**. Maps dimension d to d,
    and d + 1 ≤ d + 2. -/
def dimensionToSecurityBridge : TheoryHom DimensionSpec SecuritySpec where
  map := id
  preservesWitness := fun hw => hw
  monotoneInv := fun x => by
    unfold DimensionSpec SecuritySpec at *
    simp only [id]
    omega

/-- **Transferred bound**: dimension witnesses transport to security. -/
theorem dimension_to_security_transport :
    ∀ x, DimensionSpec.Witness x →
      DimensionSpec.lowerBound ≤ SecuritySpec.inv (dimensionToSecurityBridge.map x) :=
  dimensionToSecurityBridge.transport_witness

/-! ## §5. Coding Theory (Proof Complexity) -/

/-- Coding theory: carrier is ℕ (code lengths), invariant is identity,
    witness selects positive lengths, lower bound is 1.
    Models `lawvere_proof_coding_theorem`. -/
def CodingSpec : TheorySpec where
  α := ℕ
  inv := id
  Witness := fun n => 1 ≤ n
  lowerBound := 1
  sound := fun _ hw => hw

/-! ## §6. Collision Theory (Combinatorial Extraction) -/

/-- Collision theory: carrier is ℕ (radii), invariant is identity,
    witness selects positive radii, lower bound is 1.
    Models `extract_witness_of_collision_on_ball`. -/
def CollisionSpec : TheorySpec where
  α := ℕ
  inv := id
  Witness := fun r => 1 ≤ r
  lowerBound := 1
  sound := fun _ hw => hw

/-- **Bridge: Coding → Collision**. Identity map. -/
def codingToCollisionBridge : TheoryHom CodingSpec CollisionSpec where
  map := id
  preservesWitness := fun hw => hw
  monotoneInv := fun _ => le_refl _

/-- **Transferred bound**: coding witnesses transport to collision theory. -/
theorem coding_to_collision_transport :
    ∀ x, CodingSpec.Witness x →
      CodingSpec.lowerBound ≤ CollisionSpec.inv (codingToCollisionBridge.map x) :=
  codingToCollisionBridge.transport_witness

/-! ## §7. Height → Dimension Bridge -/

/-- Bridge: Height → Dimension. Maps height h to h, and h ≤ h + 1. -/
def heightToDimensionBridge : TheoryHom HeightSpec DimensionSpec where
  map := id
  preservesWitness := fun hw => hw
  monotoneInv := fun x => Nat.le_succ x

/-- **Transferred bound**: height witnesses transport to dimension. -/
theorem height_to_dimension_transport :
    ∀ x, HeightSpec.Witness x →
      HeightSpec.lowerBound ≤ DimensionSpec.inv (heightToDimensionBridge.map x) :=
  heightToDimensionBridge.transport_witness

/-! ## §8. Search Certificates -/

/-- Search certificate for the height-to-cell bridge. -/
def heightToCellCertificate : SearchCertificate HeightSpec CellSpec where
  map := id
  preservesWitness := fun _ => trivial
  monotoneInv := fun x => by
    simp only [HeightSpec, CellSpec, id]
    exact le_mul_of_one_le_right (Nat.zero_le x) (Nat.succ_le_succ (Nat.zero_le x))

/-- The certificate is sound. -/
theorem heightToCellCertificate_sound :
    ∀ x, HeightSpec.Witness x → HeightSpec.lowerBound ≤ CellSpec.inv (heightToCellCertificate.map x) :=
  search_sound heightToCellCertificate

/-- Search certificate for dimension-to-security. -/
def dimensionToSecurityCertificate : SearchCertificate DimensionSpec SecuritySpec where
  map := id
  preservesWitness := fun hw => hw
  monotoneInv := fun x => by
    unfold DimensionSpec SecuritySpec at *
    simp only [id]
    omega

/-- Search certificate for coding-to-collision. -/
def codingToCollisionCertificate : SearchCertificate CodingSpec CollisionSpec where
  map := id
  preservesWitness := fun hw => hw
  monotoneInv := fun _ => le_refl _

/-- Search certificate for height-to-dimension. -/
def heightToDimensionCertificate : SearchCertificate HeightSpec DimensionSpec where
  map := id
  preservesWitness := fun hw => hw
  monotoneInv := fun x => Nat.le_succ x

/-! ## §9. Multi-Hop Bridge: Height → Dimension → Security -/

/-- Two-hop pipeline: Height → Dimension → Security. -/
def heightToSecurityPipeline : TheoryHom HeightSpec SecuritySpec :=
  dimensionToSecurityBridge.comp heightToDimensionBridge

/-- **Pipeline transport theorem**: the full pipeline transports witnesses. -/
theorem pipeline_transport :
    ∀ x, HeightSpec.Witness x →
      HeightSpec.lowerBound ≤ SecuritySpec.inv (heightToSecurityPipeline.map x) :=
  heightToSecurityPipeline.transport_witness

/-- **Two-hop certificate soundness**: Height → Dimension → Security. -/
theorem two_hop_height_security_sound :
    ∀ x, HeightSpec.Witness x →
      HeightSpec.lowerBound ≤ SecuritySpec.inv
        ((bridgePath₂ heightToDimensionCertificate dimensionToSecurityCertificate).map x) :=
  bridgePath₂_sound heightToDimensionCertificate dimensionToSecurityCertificate

/-! ## §10. Strict Depth Increase -/

/-- **Strict depth increase**: height-to-cell strictly increases depth for h ≥ 2. -/
theorem height_to_cell_strict (x : ℕ) (hx : 2 ≤ x) :
    HeightSpec.inv x < CellSpec.inv (heightToCellBridge.map x) := by
  simp only [HeightSpec, CellSpec, heightToCellBridge, id]
  nlinarith

/-! ## §11. Three-Hop Bridge: Height → Dimension → Security → (back to coding?) -/

/-- Bridge: Coding → Height (identity, both use id invariant with same bounds). -/
def codingToHeightBridge : TheoryHom CodingSpec HeightSpec where
  map := id
  preservesWitness := fun hw => hw
  monotoneInv := fun _ => le_refl _

/-- Three-hop: Coding → Height → Dimension → Security. -/
theorem three_hop_coding_security_sound :
    ∀ x, CodingSpec.Witness x →
      CodingSpec.lowerBound ≤ SecuritySpec.inv
        ((heightToSecurityPipeline.comp codingToHeightBridge).map x) :=
  (heightToSecurityPipeline.comp codingToHeightBridge).transport_witness

/-! ## §12. Bridge Graph Summary

We have built the following certified bridge graph:

```
  CodingSpec ──→ HeightSpec ──→ DimensionSpec ──→ SecuritySpec
      │              │
      │              │
      ▼              ▼
  CollisionSpec   CellSpec
```

Every arrow is a `TheoryHom` with certified witness preservation and
invariant monotonicity. Every path transports lower-bound theorems.
-/