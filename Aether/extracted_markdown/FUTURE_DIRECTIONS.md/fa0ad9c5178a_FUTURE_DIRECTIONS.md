# Future Directions: Certified Categorification and Beyond

## Overview

This work establishes the algebraic and combinatorial foundations for certified Khovanov homology. The following directions represent concrete, actionable research opportunities that build directly on this infrastructure.

---

## Direction 1: Full Chain Complex Differential and d² = 0

**Status**: Sign anti-commutativity and Frobenius algebra axioms are verified. The missing piece is the explicit construction of edge maps.

**Hypothesis**: The Khovanov chain differential can be formalized as a `HomologicalComplex` in Mathlib, with `d_comp_d` proved from the sign anti-commutativity (Theorem 3.2) and the Frobenius face commutativity.

**Strategy**:
1. Formalize `V^⊗k` as `Fin k → KhBasis → R` (free R-module on tensor product basis).
2. For each cube edge (state s, position k), determine whether circles merge or split by tracking circle identities through the resolution.
3. Implement merge maps via `mulBasis` and split maps via `comulBasis`, tensored with identity on remaining circles.
4. Prove face commutativity using the Frobenius relation (already verified on basis elements).
5. Combine with sign anti-commutativity to get d² = 0.

**Key challenge**: Circle tracking — determining which circles merge or split at each edge — requires either an explicit combinatorial model (e.g., planar diagrams with arc labels) or an abstract axiomatization (e.g., a functor from the cube category to R-modules).

**Impact**: Completes the chain complex formalization, enabling homology computation.

---

## Direction 2: Reidemeister Invariance via Chain Homotopy Equivalences

**Status**: The bracket-level Reidemeister invariances (RI, RIII) are already formalized. Chain-level invariance requires lifting these to chain homotopy equivalences.

**Hypothesis**: For each Reidemeister move, there exists an explicit chain homotopy equivalence between the Khovanov complexes of diagrams related by that move.

**Strategy**:
- **RI**: The complex of a diagram with a positive kink is chain homotopy equivalent to a grading-shifted complex of the diagram without the kink. The chain map is constructed by explicit projection/inclusion.
- **RII**: Use Bar-Natan's "Gaussian elimination" approach: identify a direct sum decomposition of the complex and show two summands are acyclic.
- **RIII**: The most involved move. Use the "movie move" decomposition or the foam-based approach of Blanchet–Khovanov.

**Proof architecture**: Each move should be decomposed into:
1. An explicit chain map `f : C(D₁) → C(D₂)`.
2. An explicit chain map `g : C(D₂) → C(D₁)`.
3. Chain homotopies `h₁ : f ∘ g ∼ id` and `h₂ : g ∘ f ∼ id`.

**Impact**: Establishes that Khovanov homology is a link invariant, not just a diagram invariant.

---

## Direction 3: Homology Computation and Benchmarking

**Status**: Chain groups and bigraded dimensions are computed. Homology requires implementing the differential matrices and computing kernels/images.

**Hypothesis**: For small knots (up to 10 crossings), the Khovanov homology can be computed explicitly and matched against known tables.

**Strategy**:
1. Implement the differential as a matrix over ℤ in each bigrading.
2. Use Smith normal form to compute homology groups (free rank and torsion).
3. Verify against the KnotInfo database for trefoil, figure-eight, and torus knots.
4. Formalize the Smith normal form computation in Lean (or use `native_decide` for specific instances).

**Expected results for the trefoil**:
- Kh⁰(trefoil) ≅ ℤ (supported in j = 1)
- Kh²(trefoil) ≅ ℤ (supported in j = -1) ⊕ ℤ/2ℤ
- Kh³(trefoil) ≅ ℤ (supported in j = -3)

**Impact**: Provides certified computations of homological invariants, a capability not available in any other formal system.

---

## Direction 4: Generic Frobenius Algebra Framework (TQFT Machine)

**Status**: The rank-2 Khovanov algebra is fully verified. The axioms are stated at the level of basis elements.

**Hypothesis**: A generic Frobenius algebra structure in Lean can be used to construct chain complexes for any commutative Frobenius algebra, recovering Khovanov homology, Lee homology, and Bar-Natan homology as special cases.

**Strategy**:
1. Define a `CommutativeFrobeniusAlgebra` structure in Lean:
   ```
   structure CommFrobAlg (R : Type*) [CommRing R] (A : Type*) where
     [inst : Module R A]
     mul : A →ₗ[R] A →ₗ[R] A
     comul : A →ₗ[R] TensorProduct R A A
     unit : R →ₗ[R] A
     counit : A →ₗ[R] R
     assoc : ...
     frobenius : ...
   ```
2. Construct the cube complex functor generically from any such algebra.
3. Prove d² = 0 from the abstract Frobenius axioms.
4. Instantiate to get:
   - Khovanov homology (V = R[X]/(X²))
   - Lee homology (V = R[X]/(X²-1))
   - Bar-Natan homology (V = R[X]/(X²), modified differential)

**Impact**: Creates a reusable categorification engine applicable far beyond Khovanov homology.

---

## Direction 5: Rasmussen s-Invariant and Slice Genus Bounds

**Status**: No current formalization. Requires Lee homology as prerequisite.

**Hypothesis**: The Rasmussen s-invariant can be extracted from the Lee spectral sequence and provides certified lower bounds on the slice genus.

**Strategy**:
1. Formalize Lee homology using the modified Frobenius algebra (Direction 4).
2. Construct the spectral sequence from Khovanov to Lee homology.
3. The Lee homology of a knot is always 2-dimensional, supported in two specific quantum degrees.
4. The s-invariant is the average of these two degrees.
5. Prove the key inequality: |s(K)| ≤ 2g*(K) where g* is the slice genus.

**Landmark application**: A formal proof that s(trefoil) = 2 would give a certified proof that the trefoil has slice genus 1, confirming the Milnor conjecture for this case.

**Impact**: First certified slice genus computation from categorified invariants.

---

## Cross-Domain Connections

### Topological Quantum Computing
The categorified Jones polynomial directly connects to topological quantum computation via the representation theory of the braid group. Certified Khovanov computations could verify quantum circuit designs based on braiding operations.

### Homological Algebra Infrastructure
The chain complex and homotopy equivalence machinery developed here is applicable to any area of homological algebra in Lean, including:
- Derived categories and triangulated categories
- Spectral sequences
- Sheaf cohomology computations

### Algorithmic Knot Theory
The verified computation pipeline (diagram → state sum → bracket → chain complex → homology) constitutes a certified algorithm for knot invariant computation. This could be extracted to a certified knot calculator.

### 4-Dimensional Topology
Khovanov homology is conjectured to be related to gauge-theoretic invariants of 4-manifolds (instanton Floer homology). Formalizing this connection would be a major advance in certified low-dimensional topology.

---

## Technical Infrastructure Needed

1. **Tensor product algebra in Lean**: Improved support for `TensorProduct R M N` computations.
2. **Matrix Smith normal form**: Certified integer matrix decomposition.
3. **Spectral sequences**: Formal framework for filtered complexes and spectral sequences in Mathlib.
4. **Planar diagram combinatorics**: A library for manipulating planar link diagrams (PD codes, Gauss codes).

---

## Estimated Timeline

| Direction | Effort | Prerequisites | Expected Outcome |
|-----------|--------|---------------|-----------------|
| 1. Full differential | Medium | Current work | d² = 0 theorem |
| 2. Reidemeister invariance | High | Direction 1 | Link invariance theorem |
| 3. Homology computation | Medium | Direction 1 | Verified trefoil homology |
| 4. Generic Frobenius | Medium | Current work | Reusable TQFT framework |
| 5. s-invariant | High | Directions 1, 4 | Certified genus bounds |
