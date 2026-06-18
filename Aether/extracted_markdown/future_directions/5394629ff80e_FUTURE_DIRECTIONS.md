# Future Directions: Tropical Satake Skeleton Theory

## Overview

The Tropical Satake Skeleton framework established here opens several breakthrough research directions at the intersection of tropical algebra, semiring geometry, building theory, and certified computation. Below are five concrete next steps, each with specific theorem targets, proof strategies, and cross-domain connections.

---

## Direction 1: Intrinsic Presentation-Independence via Common Refinements

### Goal
Prove that the building skeleton `B(H, S)` depends only on the underlying semiring `H`, not on the choice of finite presentation.

### Specific Theorem Target

```
theorem skeleton_presentation_independent
    (P₁ : HeckeSemiringPresentation n₁)
    (P₂ : HeckeSemiringPresentation m₂)
    (hiso : SemiringIsomorphism (presented P₁) (presented P₂)) :
    ∃ Φ : PolyhedralIsomorphism (BuildingSkeleton P₁) (BuildingSkeleton P₂),
      Φ.isCanonical
```

### Proof Strategy
1. Define a **common refinement presentation** from two presentations of the same semiring by adding generators and relations.
2. Show that adding redundant generators/relations refines the skeleton without changing the underlying set (via the `skeleton_add_redundant` theorem already proved).
3. Show that the refinement maps form a directed system whose colimit is independent of presentation.
4. Formalize the polyhedral isomorphism type and show uniqueness.

### Cross-Domain Connection
This parallels the **presentation-independence of the Berkovich analytification** in non-archimedean geometry. The semiring-theoretic version is more elementary but captures the same essential structure.

---

## Direction 2: Weak Affine Building Axiomatization from Semiring Relations

### Goal
Show that the polyhedral complex `B(H, S)` satisfies a weak form of the Tits axioms for affine buildings when `H` models a spherical Hecke semiring.

### Specific Theorem Target

```
structure WeakBuildingAxioms (B : PolyhedralComplex) where
  chambers : Finset (Cell B)
  adjacency : Cell B → Cell B → Prop
  gallery_connected : ∀ c₁ c₂, ∃ gallery, gallery.connects c₁ c₂
  convex_intersection : ∀ A₁ A₂ : Apartment B, IsConvex (A₁ ∩ A₂)
  retraction : ∀ A : Apartment B, ∀ c ∈ A, ∃ r : B → A, IsRetraction r ∧ r.fixesPointwise c

theorem weyl_chamber_is_weak_building
    (P : HeckeSemiringPresentation n)
    (hWeyl : IsWeylType P) :
    WeakBuildingAxioms (BuildingSkeleton P)
```

### Proof Strategy
1. Define chambers as maximal-dimensional cells of the polyhedral complex.
2. Define adjacency as sharing a codimension-1 face.
3. For Weyl-type presentations (those arising from root system data), verify gallery connectedness combinatorially.
4. Prove convex intersection by showing it reduces to intersection of half-spaces, which preserves convexity.
5. Construct retractions using the Hecke generator actions (already shown to be concave/PL).

### Cross-Domain Connection
This creates a **purely tropical reconstruction of Bruhat–Tits buildings**, bypassing the usual detour through reductive groups over local fields. It connects to the geometric representation theory program of Berkovich, Bruhat, and Tits but via computable semiring data.

---

## Direction 3: Tropical Satake Transform Comparison Theorem

### Goal
Relate the tropical Satake skeleton to the classical Satake isomorphism by showing that tropicalization of the Satake transform commutes with the skeleton construction.

### Specific Theorem Target

```
theorem tropical_satake_comparison
    (G : SplitReductiveGroup K) -- K a non-archimedean local field
    (H_cl : SphericalHeckeAlgebra G)
    (H_tr : TropicalizationSemiring H_cl) :
    SkeletonOf H_tr ≅ᵖ TropicalizationOf (SatakeSpectrum H_cl)
```

### Proof Strategy
1. Start with a split reductive group `G` over a local field with spherical Hecke algebra `H_cl`.
2. Apply the Satake isomorphism to identify `H_cl` with polynomial invariants of the Weyl group.
3. Tropicalize both sides: the Hecke algebra becomes an idempotent semiring, the spectrum becomes a tropical variety.
4. Show the skeleton construction on the tropicalized semiring yields the same polyhedral complex as the tropicalization of the classical Satake spectrum.

### Cross-Domain Connection
This would be the first **formally verified bridge between classical Langlands theory and tropical geometry**, providing a computational pathway from automorphic representations to polyhedral combinatorics.

---

## Direction 4: Certified Eigenprofile Extraction Algorithms

### Goal
Implement and formally verify an algorithm that, given a finite Hecke presentation, computes all eigenprofile data (tropical eigencharacters, fixed-point loci, spectral decompositions).

### Specific Theorem Target

```
theorem eigenprofile_algorithm_correct
    (P : HeckeSemiringPresentation n)
    (T : HeckeGeneratorAction n) :
    ∀ v ∈ BuildingSkeleton P,
      eigenprofileAlgorithm P T v = {eigval | isTropicalEigencharacter T.action v eigval}

theorem eigenprofile_algorithm_terminates
    (P : HeckeSemiringPresentation n) :
    Terminates (eigenprofileAlgorithm P)
```

### Algorithm Design
1. **Input**: A finite presentation `P` and a Hecke generator `T`.
2. **Step 1**: Compute the tropical relation locus by enumerating the active-minimum regions (each region determined by which arguments achieve the minimum in each `min` expression).
3. **Step 2**: On each linear region, the Hecke map is an explicit affine map. Solve the fixed-point equation `Tv = v + λ·1` by linear algebra.
4. **Step 3**: Collect all eigenvalues and classify the eigenprofile.
5. **Output**: The set of eigenvalues and their multiplicities, certified by explicit witnesses.

### Complexity Analysis
- Number of linear regions: at most `2^m` where `m` is the total number of `min` operations in all relation expressions.
- Per-region computation: `O(n³)` for linear algebra on `n × n` systems.
- Total: `O(2^m · n³)`, which is polynomial when `m` is bounded.

### Cross-Domain Connection
This connects to **tropical optimization** and **min-plus spectral theory**. The eigenprofile extraction is analogous to computing the min-plus eigenvalue of a matrix (Howard's policy iteration), but generalized to arbitrary presentation-defined loci.

---

## Direction 5: Extension to Hall-Type and Parahoric Semirings

### Goal
Extend the framework from commutative spherical Hecke semirings to:
- Non-commutative Hall algebra semirings (categorical Hecke algebras)
- Parahoric Hecke semirings (partial flag data)
- Affine Hecke semirings with Bernstein center structure

### Specific Theorem Target (Hall case)

```
structure TropicalHallSemiring (C : Category) where
  carrier : Type*
  instSemiring : Semiring carrier
  instIdempotent : IdempotentAdd carrier
  hallProduct : carrier → carrier → carrier
  hallRelations : List (TropRelation n)

theorem hall_skeleton_is_schubert_complex
    (H : TropicalHallSemiring C) :
    ∃ Σ : SchubertComplex, BuildingSkeleton H.toPresentation ≅ᵖ Σ
```

### Proof Strategy
1. Define the tropical Hall product as a min-plus convolution on isomorphism classes.
2. Show that the resulting semiring is finitely presented when the category has finitely many indecomposables.
3. Apply the skeleton construction and show it recovers the Schubert cell decomposition.

### Cross-Domain Connection
- **Geometric representation theory**: Hall algebras encode the category of sheaves on curves; tropicalizing gives combinatorial shadows.
- **Quantum groups**: The positive part of a quantum group is a Hall algebra. Its tropicalization should give the string parameterization of canonical bases.
- **Machine learning**: Tropical Hall algebras model composable min-plus operations, relevant to tropical neural network architecture theory.

---

## Connections Summary

| Direction | Primary Domain | Secondary Connections | Difficulty |
|-----------|---------------|----------------------|------------|
| 1. Presentation-independence | Semiring geometry | Berkovich theory | Medium |
| 2. Building axioms | Combinatorial geometry | Bruhat–Tits theory | Hard |
| 3. Satake comparison | Representation theory | Langlands program | Very Hard |
| 4. Certified algorithms | Verified computation | Tropical optimization | Medium |
| 5. Hall/parahoric extension | Categorical algebra | Quantum groups, ML | Hard |

---

## Technical Prerequisites

### For Directions 1–2
- Polyhedral geometry library (cell complexes, face lattices, subdivisions)
- Convex geometry (supporting hyperplanes, polyhedral fans)
- Combinatorial topology (simplicial complexes, gallery connectivity)

### For Direction 3
- Formalized reductive group theory (root systems, Weyl groups)
- Non-archimedean analysis (valuations, completions)
- Representation theory (Satake isomorphism, unramified representations)

### For Direction 4
- Certified linear programming / linear algebra
- Termination proofs for polyhedral enumeration
- Computational complexity formalization

### For Direction 5
- Category theory (finitary categories, Hall products)
- Non-commutative semiring theory
- Schubert calculus
