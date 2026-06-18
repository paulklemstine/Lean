# Future Directions: Tropical Geometric Langlands via MV Polytopes

## Overview

The formalization of tropical MV polytope classification, convolution–Minkowski transport, and certified reconstruction opens several concrete breakthrough-level research programs. Each direction below includes specific theorem targets, proof strategies, and cross-domain connections.

---

## Direction 1: Tropical Crystal Operators from MV Edge Moves

**Goal**: Define crystal operators (Kashiwara's ẽ_i, f̃_i) in the tropical setting as edge-weight modification operations on tropical MV polytopes, and prove they satisfy the crystal axioms (Stembridge local characterization).

**Specific Theorem Targets**:
```
theorem crystal_edge_move_preserves_admissibility
  (P : TropicalMVPolytope C) (e : ι) (he : is_simple_root e) :
  IsAdmissible C (P.level) (crystal_raise e P).weight

theorem crystal_operators_satisfy_stembridge_axioms
  (P : TropicalMVPolytope C) :
  StembridegeLocalAxioms (crystalGraph P)

theorem crystal_connected_component_eq_mv_family
  (P : TropicalMVPolytope C) :
  connectedComponent P = { Q | Q.level = P.level ∧ highestWeight Q = highestWeight P }
```

**Proof Strategy**: Define `crystal_raise e P` by incrementing the weight at chamber `e` while maintaining edge inequalities via propagation. The Stembridge axioms follow from the submodularity properties already proved (pointwise_max_edge, pointwise_min_edge). Connected components correspond to MV polytopes with the same highest weight, which follows from reconstruction uniqueness.

**Cross-Domain Connection**: Links tropical representation theory to combinatorial crystal bases (Kashiwara–Nakashima), enabling algorithmic computation of tensor product multiplicities via tropical MV calculus.

---

## Direction 2: Tropical Canonical Basis Reconstruction

**Goal**: Prove that the dual canonical basis (Lusztig/Kashiwara) has a tropical shadow: each basis element corresponds to an integer point in the tropical MV polytope, and the basis multiplication constants can be computed from Minkowski decomposition data.

**Specific Theorem Targets**:
```
theorem tropical_canonical_basis_parametrized_by_mv_lattice_points
  (P : TropicalMVPolytope C) :
  Fintype (LatticePoints P) ∧
  card (LatticePoints P) = dimension_of_representation (highestWeight P)

theorem minkowski_decomposition_gives_tensor_multiplicities
  (P Q : TropicalMVPolytope C) :
  tensor_multiplicity (highestWeight P) (highestWeight Q) (highestWeight R) =
    card { (A, B) | mvMinkowski A B = R ∧ A ∈ mvFamily P ∧ B ∈ mvFamily Q }
```

**Proof Strategy**: Define lattice points as integer vectors in the convex hull of the chamber weight data. Use the scaling theorem (mvScale_add) to decompose scaled polytopes into Minkowski summands. Tensor multiplicities are computed by counting Minkowski decompositions, which is a finite enumeration problem over the lattice.

**Cross-Domain Connection**: Connects to quantum group theory (Lusztig canonical bases), cluster algebras (Fomin–Zelevinsky), and algorithmic representation theory.

---

## Direction 3: Extension to Affine Coxeter Data

**Goal**: Extend the finite chamber complex formalization to affine Weyl groups, enabling tropical MV polytopes for loop groups and affine Lie algebras. This requires handling infinite but periodic chamber structures.

**Specific Theorem Targets**:
```
theorem affine_chamber_complex_periodic
  (W : AffineCoxeterGroup) :
  ∃ (fundamental_domain : Finset (Chamber W)),
    ∀ c : Chamber W, ∃ w ∈ W.translation_subgroup,
      w • c ∈ fundamental_domain

theorem affine_mv_polytope_finite_support
  (P : AffineTropicalMVPolytope W) :
  (support P.weight).Finite

theorem affine_tropical_satake_classification
  (W : AffineCoxeterGroup) :
  AffineTropicalMVPolytope W ≃ AffineAdmissibleCharacter W
```

**Proof Strategy**: Quotient the infinite affine chamber complex by the translation lattice to obtain a finite fundamental domain. Tropical MV polytopes then become finitely supported weight functions on this quotient, and the classification theorem lifts from the finite case via the periodicity.

**Cross-Domain Connection**: Links to geometric Langlands for loop groups (Frenkel–Gaitsgory), integrable systems (KP hierarchy), and mathematical physics (conformal field theory characters).

---

## Direction 4: Certified Comparison with Classical MV Polytopes via Valuation Functors

**Goal**: Build a formal comparison functor from classical MV polytopes (over ℝ) to tropical MV polytopes (over ℤ), using the p-adic valuation as the bridge. Prove that the tropical MV classification is the image of the classical one under this functor.

**Specific Theorem Targets**:
```
theorem valuation_functor_preserves_mv_structure
  (v : ValuationRing K) (P : ClassicalMVPolytope K) :
  IsTropicalMVPolytope (v.map P)

theorem valuation_functor_preserves_minkowski
  (v : ValuationRing K) (P Q : ClassicalMVPolytope K) :
  v.map (minkowski P Q) = mvMinkowski (v.map P) (v.map Q)

theorem tropical_classification_is_valuation_image
  (v : ValuationRing K) :
  Set.range (v.map : ClassicalMVPolytope K → TropicalMVPolytope C) =
    Set.univ
```

**Proof Strategy**: Define the valuation functor using the TropicalValuationFunctor infrastructure already in the catalog (padicValNat, valuation_additive_on_products). The key step is showing that the valuation of a classical edge inequality becomes a tropical edge inequality, which follows from the order-preserving property of valuations.

**Cross-Domain Connection**: Connects to p-adic Hodge theory, Berkovich analytification, and non-Archimedean geometry. Also links to the existing TropicalValuationFunctor catalog theorem.

---

## Direction 5: Tropical Automorphic Packets from Semiring Characters

**Goal**: Define tropical automorphic packets as fibers of the character-to-MV-polytope map over local data, and prove a tropical analogue of the Arthur multiplicity formula.

**Specific Theorem Targets**:
```
theorem tropical_automorphic_packet_finite
  (P : TropicalMVPolytope C) :
  Set.Finite { M : TropicalHeckeSemimodule C n | semimoduleToMV hn M = P }

theorem tropical_multiplicity_formula
  (P : TropicalMVPolytope C) :
  packet_size P = ∏ e ∈ edges C, local_multiplicity e P

theorem tropical_endoscopic_transfer
  (C₁ C₂ : ChamberComplex ι) (f : C₁ →ₘ C₂) :
  ∀ P : TropicalMVPolytope C₁,
    packet_size (f.map P) = ∑ Q ∈ fiber f P, transfer_factor Q * packet_size Q
```

**Proof Strategy**: The packet is the set of semimodules (up to isomorphism) with a given MV polytope. Finiteness follows from the finite state space. The multiplicity formula decomposes into local edge contributions using the edge inequality structure. Endoscopic transfer uses the functoriality of the chamber complex morphisms.

**Cross-Domain Connection**: Links tropical geometry to the Langlands program proper, suggesting that tropical/idempotent methods can illuminate automorphic structure. Also connects to the Tannaka reconstruction results already in the catalog.

---

## Implementation Priorities

1. **Direction 4** (Valuation Functors) — most immediately achievable given existing catalog infrastructure
2. **Direction 1** (Crystal Operators) — highest mathematical impact, moderate formalization difficulty
3. **Direction 2** (Canonical Bases) — deepest mathematical content, requires significant new infrastructure
4. **Direction 3** (Affine Extension) — systematic generalization, well-defined scope
5. **Direction 5** (Automorphic Packets) — most speculative but potentially transformative

## Key Technical Dependencies

All directions benefit from:
- The `ChamberComplex` abstraction as the organizing data structure
- The `mvMinkowski` operation and its cancellation/associativity properties
- The reconstruction correctness and uniqueness theorems
- The concrete A₂ example for testing new constructions

## Broader Impact

These directions collectively establish **tropical geometric Langlands** as a computationally effective framework where:
- Representations are classified by finite combinatorial data (polytopes)
- Tensor products are computed by Minkowski addition
- Characters are decoded by certified reconstruction algorithms
- Classical results are recovered via valuation functors

This represents a new organizing principle: **in idempotent representation theory, geometry is the convex envelope of spectral extremals**.
