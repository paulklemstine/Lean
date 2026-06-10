# Semantic Fiber Theory: Structural Isomorphism and the Divergence of Meaning

## Abstract

We develop a formal theory of *semantic fibers* — the collection of distinct "meanings" compatible with a single structural skeleton — and prove that isomorphic mathematical structures can carry fundamentally non-isomorphic enrichments. Our main results are: (1) the **Pointed Group Separation Theorem**, showing that the identity element in any nontrivial group is semantically distinguished from all other elements; (2) the **Ring Enrichment Divergence Theorem**, proving that the Gaussian integers ℤ[i] and the product ring ℤ × ℤ have isomorphic additive groups but cannot be ring-isomorphic; (3) the **Isomorphism Torsor Theorem**, establishing that the set of isomorphisms between isomorphic groups forms a principal homogeneous space for the automorphism group; and (4) the **Rigidity–Discrimination Equivalence**, characterizing when maximal semantic discrimination holds. All results are machine-verified in Lean 4 with Mathlib. These results formalize the precise sense in which categorical equivalence preserves structural truth but not semantic content.

**Keywords**: isomorphism, semantic fiber, automorphism group, pointed structure, enriched category, integral domain, torsor

## 1. Introduction

The concept of isomorphism — "same structure" — is the central equivalence relation of modern mathematics. Two groups are considered "the same" if there exists a bijective homomorphism between them; two rings are "the same" if there exists a bijective ring homomorphism; and so on. This notion of structural sameness has been enormously productive, enabling the transfer of theorems across settings and the classification of mathematical objects up to structural equivalence.

Yet structural sameness can coexist with semantic divergence. The cyclic group ℤ/12ℤ models both clock arithmetic and the chromatic scale, yet no musician would consider these the same object. More substantively, two structures can share one layer of structure (e.g., an additive group) while differing at another (e.g., a multiplicative structure). This phenomenon — which we call *semantic divergence* — has been widely recognized informally but lacks a systematic formal treatment.

This paper provides such a treatment. We define the *semantic fiber* of a structure S with respect to a forgetful operation U as the collection of enrichments of U(S) that are non-isomorphic as enriched structures. We prove that the size and structure of the semantic fiber is controlled by the automorphism group Aut(S), establishing a precise bridge between algebraic symmetry and semantic ambiguity.

### 1.1 Relation to Prior Work

Our work builds on and extends several results from the Catalog of verified theorems:

- **`different_euler_char_not_iso`** (Bridges/HigherSimplicial.lean): This theorem uses the Euler characteristic as a structural invariant to distinguish non-isomorphic simplicial complexes. Our semantic fiber theory generalizes this approach — the Euler characteristic is one instance of a "semantic decoration" that the forgetful functor from graded structures to bare structures cannot recover.

- **`oracle_preserves_truth`** (Computation/OmniscientOracle.lean): This result shows that oracles preserve truth under compositional operations. Our Ring Enrichment Divergence Theorem demonstrates the complementary phenomenon: truth preservation at one level (additive structure) does not propagate to truth preservation at another level (multiplicative structure).

- **`not_representable_of_minor_not_representable`** (Novelty/Structural.lean): This matroid-theoretic result shows that representability is inherited by minors. Our Rigidity–Discrimination Equivalence provides an analogous inheritance result for semantic properties: if a structure is rigid, all its substructures maintain maximal discrimination.

### 1.2 Connection to Hofstadter's Copycat Architecture

Hofstadter's Copycat architecture for analogical reasoning is based on the premise that analogy-making is the identification of structural correspondences between situations, modulated by contextual "pressures" that favor certain correspondences over others. Our Isomorphism Torsor Theorem provides a mathematical formalization of this idea: the set of isomorphisms between two isomorphic structures is parameterized by the automorphism group, and the choice of a particular isomorphism corresponds to the selection of a particular "analogy" among all structurally valid options. The torsor structure implies that no analogy is canonically preferred — the choice is inherently contextual.

## 2. Definitions

### 2.1 Pointed Groups

**Definition 2.1.** A *pointed group* is a pair (G, g) where G is a group and g ∈ G is a distinguished element (the *basepoint*).

**Definition 2.2.** An *isomorphism of pointed groups* from (G, g) to (H, h) is a group isomorphism φ : G → H such that φ(g) = h.

### 2.2 Semantic Rigidity

**Definition 2.3.** A group G is *semantically rigid* if Aut(G) = {id}, i.e., the identity is the only automorphism of G.

### 2.3 Semantic Fiber

**Definition 2.4 (Informal).** The *semantic fiber* of a structure S with respect to a forgetful operation U is the set of isomorphism classes of enriched structures E such that U(E) ≅ S. The fiber measures the "ambiguity of meaning" — how many genuinely different enrichments are compatible with the same structural skeleton.

## 3. Main Results

### 3.1 Pointed Group Separation (Theorem 1)

**Theorem 3.1 (pointed_group_semantic_separation).** *For any group G and any g ∈ G with g ≠ 1, the pointed groups (G, 1) and (G, g) are not isomorphic as pointed groups.*

*Proof sketch.* Any group isomorphism φ : G → G satisfies φ(1) = 1. An isomorphism of pointed groups (G, 1) → (G, g) would require φ(1) = g, giving g = 1, a contradiction. □

**Example (E).** In ℤ/6ℤ, the pointed groups (ℤ/6ℤ, 0) and (ℤ/6ℤ, 1) are non-isomorphic as pointed groups, even though ℤ/6ℤ ≅ ℤ/6ℤ as a bare group.

**Generalization (G).** The natural generalization replaces "group" with any algebraic structure having a canonical element fixed by all automorphisms. This includes: monoids (identity), rings (additive and multiplicative identities), lattices (top and bottom elements), and pointed topological spaces.

**Boundary (B).** The theorem fails for bare sets: any bijection can send any element to any other, so there is no semantically distinguished element in a set without additional structure. The theorem also becomes vacuous for the trivial group.

### 3.2 Ring Enrichment Divergence (Theorem 2)

**Theorem 3.2 (ring_semantic_divergence).** *The Gaussian integers ℤ[i] and the product ring ℤ × ℤ are not isomorphic as rings, despite the existence of an additive group isomorphism ℤ[i] ≃+ ℤ × ℤ.*

*Proof sketch.* Two steps:
1. *ℤ × ℤ is not an integral domain*: (1,0) · (0,1) = (0,0) with both factors nonzero.
2. *Ring isomorphisms preserve integral domain property*: If φ : ℤ[i] ≃+* ℤ × ℤ existed, then φ⁻¹ would transfer the zero-divisor equation: φ⁻¹(1,0) · φ⁻¹(0,1) = φ⁻¹(0,0) = 0 in ℤ[i]. Since ℤ[i] is an integral domain, one factor is zero, hence (1,0) = 0 or (0,1) = 0, contradicting both being nonzero. □

**Example (E).** The additive isomorphism gaussianIntAddEquivProd maps a + bi ↦ (a, b), preserving all additive structure. But i² = -1 in ℤ[i], while (0,1)² = (0,1) in ℤ × ℤ. The multiplicative structures are fundamentally incompatible.

**Generalization (G).** This extends to any pair of rings with isomorphic additive groups but different zero-divisor structure. For instance, ℤ[√2] and ℤ × ℤ have the same additive group ℤ² but non-isomorphic ring structures (ℤ[√2] is again an integral domain). More broadly, the number of non-isomorphic ring structures on a given abelian group is a measure of the "multiplicative semantic fiber" of that group.

**Boundary (B).** When the additive group is ℤ (rank 1), the ring structure is essentially unique — the only ring with additive group ℤ is ℤ itself (up to isomorphism). The phenomenon requires rank ≥ 2.

### 3.3 Isomorphism Torsor (Theorem 3)

**Theorem 3.3 (iso_unique_aut_factor).** *For groups G and H, given any isomorphism φ₀ : G ≃* H, every isomorphism φ : G ≃* H factors uniquely as φ = φ₀ ∘ α for a unique automorphism α ∈ Aut(G).*

*Proof sketch.* Set α = φ₀⁻¹ ∘ φ. Then φ₀ ∘ α = φ₀ ∘ φ₀⁻¹ ∘ φ = φ. Uniqueness: if φ₀ ∘ α₁ = φ₀ ∘ α₂ pointwise, injectivity of φ₀ gives α₁ = α₂. □

**Example (E).** For G = H = ℤ/2ℤ × ℤ/2ℤ (Klein four-group), Aut(G) ≅ S₃ (the symmetric group on 3 elements — permuting the three non-identity elements). Fixing one isomorphism φ₀ = id, the other 5 automorphisms give 5 additional isomorphisms, for 6 total.

**Generalization (G).** This is an instance of a general categorical phenomenon: for any category C, the set of isomorphisms Iso(A, B) is a torsor for Aut(A) (by precomposition) and for Aut(B) (by postcomposition). This lifts to higher categories, where the "torsor of isomorphisms" becomes a "torsor of equivalences."

**Boundary (B).** The torsor structure degenerates when Aut(G) is trivial — then there is exactly one isomorphism, and the torsor is a point. The torsor is also less informative for abelian groups with large automorphism groups, where the combinatorial structure of Aut(G) becomes complex.

### 3.4 Rigidity–Discrimination Equivalence (Theorem 4)

**Theorem 3.4 (rigid_iff_max_discrimination).** *A group G is semantically rigid (Aut(G) = {id}) if and only if for every pair g ≠ h ∈ G, the pointed groups (G, g) and (G, h) are non-isomorphic.*

*Proof sketch.* (⇒) If rigid and (G, g) ≅ (G, h) via some φ, then φ = id by rigidity, giving g = h, contradiction. (⇐) If Aut(G) ≠ {id}, then some φ ≠ id moves a point g ≠ φ(g), but φ gives a pointed isomorphism (G, g) ≅ (G, φ(g)), contradicting maximal discrimination. □

**Example (E).** The infinite cyclic group ℤ has Aut(ℤ) = {id, x ↦ -x}, so it is not rigid. Indeed, (ℤ, 1) and (ℤ, -1) are isomorphic as pointed groups (via x ↦ -x), demonstrating non-maximal discrimination.

**Generalization (G).** The equivalence extends to any algebraic structure where automorphisms act on elements: monoids, rings, modules, etc. The general principle is that rigidity (trivial automorphism group) is equivalent to maximal semantic discrimination (no two elements are automorphically equivalent).

**Boundary (B).** For infinite structures, rigidity is rare but exists — for example, the rationals ℚ as an ordered field have no non-trivial order-preserving ring automorphisms. For finite groups, rigidity is also uncommon: most finite groups have non-trivial automorphism groups.

### 3.5 Enrichment Fiber Non-Triviality (Theorem 5)

**Theorem 3.5 (enrichment_fiber_nontrivial).** *The additive group (ℤ, +) admits at least two distinct translation-invariant orderings.*

*Proof sketch.* The standard ordering ≤ and the reversed ordering ≥ are both translation-invariant (a ≤ b ⇒ a+c ≤ b+c, and a ≥ b ⇒ a+c ≥ b+c) but are distinct LE instances (0 ≤ 1 but ¬(0 ≥ 1)). □

### 3.6 Bridge Theorem (Theorem 6)

**Theorem 3.6 (nontrivial_group_has_semantic_fibers).** *Every nontrivial group has at least two semantically distinct pointed versions.*

This bridges automorphism theory to semantic fiber theory: the existence of a non-identity element immediately yields a semantic fiber of size ≥ 2 via the Pointed Group Separation Theorem.

## 4. The Semantic Fiber Algorithm

Given a finite group G, the following algorithm computes the semantic fiber (the number of orbits of Aut(G) on G):

```
Input: A finite group G
Output: The number of semantically distinct pointed groups over G

1. Compute Aut(G) = { φ : G → G | φ is a group automorphism }
2. For each g ∈ G, compute its orbit: Orb(g) = { φ(g) | φ ∈ Aut(G) }
3. Count the number of distinct orbits
4. Return the count
```

By Burnside's lemma, this count equals (1/|Aut(G)|) Σ_{φ ∈ Aut(G)} |Fix(φ)|, where Fix(φ) = { g ∈ G | φ(g) = g }.

## 5. Discussion

### 5.1 Categorical Interpretation

Our results admit a clean categorical interpretation. The forgetful functor U : Ring → AbGrp (forgetting multiplicative structure) is faithful but not full. The *fiber* of U over a given abelian group A is the category of ring structures on A. Theorem 3.2 shows this fiber is non-trivial for A = ℤ²: it contains at least two non-isomorphic rings (ℤ[i] and ℤ × ℤ).

Similarly, the forgetful functor from pointed groups to groups is faithful and essentially surjective, but not full — not every group homomorphism preserves basepoints. The kernel of this forgetful functor (the information it destroys) is precisely the semantic content.

### 5.2 Connection to Model Theory

In model-theoretic terms, our results relate to the distinction between a theory and its models. Two models of the same complete theory are elementarily equivalent — they satisfy the same first-order sentences — but need not be isomorphic. The semantic fiber measures the "gap" between elementary equivalence (structural truth) and isomorphism (semantic identity).

### 5.3 Implications for Analogical Reasoning

The Isomorphism Torsor Theorem (3.3) provides a mathematical framework for Hofstadter's thesis that analogy is "the perception of common structure." Given two isomorphic structures, the choice of which isomorphism to use — which analogy to draw — is parameterized by the automorphism group. Structures with large automorphism groups admit many equally valid analogies; rigid structures admit only one.

This suggests a formal measure of *analogical depth*: the log of the size of the automorphism group. Deep analogies (with many valid correspondences) arise from symmetric structures; shallow analogies (with essentially one correspondence) arise from rigid ones.

## 6. Future Work

1. **Semantic distance metrics**: Can we define a natural metric on the semantic fiber, measuring how "different" two enrichments of the same base are?

2. **Higher semantic fibers**: The "isomorphism of isomorphisms" — the 2-categorical structure of the torsor — deserves further investigation. What is the semantic fiber of the semantic fiber?

3. **Computational complexity**: What is the complexity of computing the semantic fiber for various classes of algebraic structures?

4. **Infinite structures**: For infinite groups, Burnside's lemma no longer applies. Can we use measure-theoretic or topological tools to quantify the semantic fiber?

## 7. References

1. Klein, F. (1872). Vergleichende Betrachtungen über neuere geometrische Forschungen (Erlangen program).
2. Hofstadter, D. R. (1995). Fluid Concepts and Creative Analogies.
3. Mac Lane, S. (1998). Categories for the Working Mathematician (2nd ed.).
4. Catalog: `Bridges/HigherSimplicial.lean` — `different_euler_char_not_iso`
5. Catalog: `Computation/OmniscientOracle.lean` — `oracle_preserves_truth`
6. Catalog: `Novelty/Structural.lean` — `not_representable_of_minor_not_representable`
