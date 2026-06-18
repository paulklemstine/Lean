# Isomorphisms of Meaning: Semantic Opacity and the Torsor Structure of Identification Spaces

## Abstract

We develop a rigorous framework for **semantic opacity** — the phenomenon that isomorphic mathematical structures can carry genuinely different meanings when embedded in richer contexts. Our central result is the **Iso-Torsor Theorem**: the space of isomorphisms between two isomorphic groups G ≅ H is in natural bijection with the automorphism group Aut(G), quantifying the exact degree of "semantic freedom" in any identification. We prove that this semantic freedom is itself an isomorphism invariant (Aut-Conjugation Invariance), establish the Semantic Opacity Theorem showing ℤ/4ℤ and ℤ/2ℤ × ℤ/2ℤ are non-isomorphic despite equicardinality, prove the Rigid Uniqueness Theorem characterizing structures with trivial semantic ambiguity, demonstrate that faithful functors preserve all semantic distinctions (Faithful Iso-Reflection), and establish the Invariant Separation Theorem generalizing classical non-isomorphism criteria. All results are formalized in Lean 4 with complete machine-verified proofs.

**Keywords**: isomorphism, automorphism group, torsor, semantic opacity, faithful functor, invariant separation, categorical equivalence

## 1. Introduction

### 1.1 The Problem of Meaning in Formal Systems

A fundamental tension in mathematics concerns the relationship between structure and meaning. The principle of structural invariance — that isomorphic objects are interchangeable for all mathematical purposes — is foundational to modern algebra and category theory. Yet mathematicians routinely distinguish between objects that are "abstractly isomorphic" but carry different meanings in context.

This paper makes this tension precise. We formalize the notion of **semantic opacity**: the gap between structural identity (isomorphism) and contextual meaning (embedding in a richer structure). Our key tool is the **iso-torsor structure**, which reveals that the "space of meanings" for any identification between isomorphic structures is governed by the automorphism group.

### 1.2 Connection to Prior Work

Our work deepens two results from the research catalog:

1. **`different_euler_char_not_iso`** (Bridges/HigherSimplicial.lean): This theorem shows that simplicial complexes with different Euler characteristics cannot be isomorphic. We generalize this to the **Invariant Separation Theorem**: *any* isomorphism invariant that separates two structures proves their non-isomorphism. Euler characteristic is one instance among many.

2. **`oracle_preserves_truth`** (Computation/GravityOracle.lean): This theorem shows that certain oracles preserve truth. We complement this by showing that while isomorphisms preserve all formal properties (truth), they do not preserve meaning — there are |Aut(G)|-many equally valid truth-preserving identifications.

### 1.3 Connection to Hofstadter's Copycat

Hofstadter's Copycat architecture for analogical reasoning posits that cognition fundamentally involves finding structural correspondences between domains. Our Torsor Theorem gives this a precise mathematical formulation: an analogy is a choice of isomorphism, and the space of possible analogies is a torsor for the symmetry group. The "quality" of an analogy corresponds to which element of the automorphism group it represents.

## 2. Definitions and Setup

### 2.1 Semantic Rigidity

**Definition 2.1** (Semantically Rigid Group). A group G is *semantically rigid* if every automorphism is the identity:
$$\forall \sigma \in \text{Aut}(G), \quad \sigma = \text{id}_G$$

Semantically rigid groups have no "internal symmetry" — every element is distinguishable by the group structure alone.

### 2.2 The Iso-Torsor Construction

**Definition 2.2** (Iso-Torsor Equivalence). Given groups G, H with a fixed isomorphism φ : G ≃* H, define:
$$\Phi_\phi : \text{Aut}(G) \to \text{Iso}(G, H), \quad \sigma \mapsto \sigma \circ \phi$$
$$\Phi_\phi^{-1} : \text{Iso}(G, H) \to \text{Aut}(G), \quad \psi \mapsto \psi \circ \phi^{-1}$$

These are mutually inverse bijections, establishing Iso(G, H) as a (right) torsor for Aut(G).

### 2.3 Isomorphism Invariants

**Definition 2.3** (Invariant). A function f assigning values to groups is an *isomorphism invariant* if G ≅ H implies f(G) = f(H).

Examples include cardinality, exponent, center size, number of subgroups, and (for simplicial complexes) Euler characteristic.

## 3. Main Results

### 3.1 The Iso-Torsor Theorem

**Theorem 3.1** (Iso-Torsor Theorem). For any groups G, H and isomorphism φ : G ≃* H, the map σ ↦ σ.trans φ defines a bijection:
$$\text{Aut}(G) \xrightarrow{\sim} \{f : G \cong H\}$$

*Proof*. The inverse is ψ ↦ ψ.trans φ⁻¹. Both compositions reduce to the identity by associativity of composition and the cancellation φ ∘ φ⁻¹ = id, φ⁻¹ ∘ φ = id. ∎

**Corollary 3.2** (Semantic Fiber Cardinality). For finite groups G ≅ H:
$$|\text{Iso}(G, H)| = |\text{Aut}(G)|$$

This is the quantitative heart of semantic opacity: the number of distinct "meanings" for an identification G ≅ H equals the number of symmetries of G.

### 3.2 Semantic Opacity

**Theorem 3.3** (Semantic Opacity). The additive groups ℤ/4ℤ and ℤ/2ℤ × ℤ/2ℤ have equivalent underlying sets (both of cardinality 4) but are not isomorphic as additive groups.

*Proof*. In ℤ/2ℤ × ℤ/2ℤ, every element x satisfies 2x = 0 (since each component is in ℤ/2ℤ). In ℤ/4ℤ, the element 1 satisfies 2·1 = 2 ≠ 0. Any group isomorphism would preserve the nsmul operation, so e(2·1) = 2·(e(1)) = 0, giving e(2) = 0 = e(0), contradicting injectivity. ∎

This demonstrates that algebraic "meaning" (the group operation) transcends set-theoretic structure (the underlying set).

### 3.3 Rigidity and Uniqueness

**Theorem 3.4** (Rigid Uniqueness). If G is semantically rigid, then for any group H, any two isomorphisms φ, ψ : G ≃* H are equal.

*Proof*. The composition ψ ∘ φ⁻¹ is an automorphism of G. By rigidity, it equals the identity. Therefore ψ = φ. ∎

*Interpretation*. Rigid groups have zero semantic ambiguity — there is exactly one way to identify any two isomorphic copies. This is the "opposite" of rich symmetry.

### 3.4 Aut-Conjugation Invariance

**Theorem 3.5** (Automorphism Group Invariant). If G ≅ H then Aut(G) ≅ Aut(H), via conjugation σ ↦ φ ∘ σ ∘ φ⁻¹.

Combined with the Torsor Theorem, this implies that the "semantic capacity" — the number of distinct meanings a structure can carry — is itself preserved by isomorphism.

**Theorem 3.6** (Conjugation-Torsor Compatibility). For any φ : G ≃* H and σ ∈ Aut(G):
$$\sigma \circ \phi = \phi \circ (\text{conj}_\phi(\sigma))$$

This says the torsor action (precomposition) is interchangeable with the conjugation action (postcomposition), connecting the two natural operations on the iso-space.

### 3.5 Faithful Functors and Meaning Preservation

**Theorem 3.7** (Faithful Iso-Reflection). If F : C → D is a faithful functor and F(f) = F(g) for isomorphisms f, g : X ≅ Y in C, then f = g.

*Proof*. Since F is faithful, F.map is injective on Hom-sets. The hypothesis F.mapIso f = F.mapIso g implies F.map(f.hom) = F.map(g.hom). Injectivity gives f.hom = g.hom, and since an isomorphism is determined by its forward map, f = g. ∎

*Interpretation*. A faithful functor preserves all semantic distinctions at the morphism level. Faithfulness is the categorical formalization of "meaning preservation."

### 3.6 Automorphism Order Bound

**Theorem 3.8** (Aut-Factorial Divisibility). For any finite group G:
$$|\text{Aut}(G)| \;\big|\; |G|!$$

*Proof*. Every automorphism is in particular a permutation of the underlying set, giving an injection Aut(G) ↪ Sym(G). By Lagrange's theorem applied to the permutation group, |Aut(G)| divides |Sym(G)| = |G|!. ∎

This bounds the "semantic entropy": the number of possible meanings grows at most factorially in the size of the structure.

### 3.7 Invariant Separation

**Theorem 3.9** (Invariant Separation). If f is an isomorphism invariant and f(G) ≠ f(H), then G ≇ H.

*Proof*. Contrapositive of the definition: if G ≅ H then f(G) = f(H). ∎

While the proof is immediate, the theorem's power lies in its generality: it unifies Euler characteristic separation, exponent separation, cardinality separation, and all other invariant-based non-isomorphism proofs into a single framework.

**Theorem 3.10** (Cardinality Invariance). Group isomorphisms preserve cardinality.

## 4. The PEGB Framework

### 4.1 Iso-Torsor Theorem (PEGB)

- **Proof**: Complete formalization in `isoTorsorEquiv`, constructing the explicit bijection with verified inverse.
- **Example**: For ℤ/4ℤ, Aut(ℤ/4ℤ) ≅ ℤ/2ℤ (the only non-trivial automorphism is x ↦ 3x). So there are exactly 2 self-isomorphisms.
- **Generalization**: The theorem holds for any algebraic structure, not just groups. The next level would be monoids, rings, or general categories with chosen objects.
- **Boundary**: The theorem requires the existence of at least one isomorphism. For non-isomorphic objects, Iso(G, H) is empty and the torsor structure degenerates.

### 4.2 Semantic Opacity Theorem (PEGB)

- **Proof**: Complete formalization in `semantic_opacity_Z4_Klein`, using exponent as the separating invariant.
- **Example**: ℤ/4ℤ = {0, 1, 2, 3} with 1+1=2, 2+2=0. Klein = {(0,0), (1,0), (0,1), (1,1)} with every element self-inverse.
- **Generalization**: The same technique applies to any pair of non-isomorphic groups of equal order: find a separating invariant (exponent, center size, number of elements of each order).
- **Boundary**: For groups of prime order, there is only one group up to isomorphism (all cyclic). Semantic opacity requires composite order.

### 4.3 Rigid Uniqueness Theorem (PEGB)

- **Proof**: Complete formalization in `rigid_iso_unique`, using the torsor structure to reduce to the automorphism group.
- **Example**: The trivial group {e} is rigid; there is exactly one isomorphism from {e} to any other trivial group.
- **Generalization**: Semi-rigidity (Aut(G) is small but not trivial) gives a bounded number of identifications.
- **Boundary**: No non-trivial finite group of order > 2 is rigid (the inversion map x ↦ x⁻¹ is a non-trivial automorphism for abelian groups of order > 2, and inner automorphisms exist for non-abelian groups).

## 5. Algorithm: Semantic Distance

We define a **semantic distance** between two isomorphisms φ, ψ : G → H as the automorphism σ = ψ ∘ φ⁻¹ ∈ Aut(G). In the Cayley graph of Aut(G) with a chosen generating set, the word length of σ measures "how different" the two identifications are.

```
ALGORITHM SemanticDistance(φ, ψ : Iso(G, H)):
  σ ← ψ ∘ φ⁻¹  // The "semantic difference"
  return CayleyWordLength(Aut(G), generators, σ)
```

This gives a metric on the space of meanings that is invariant under the torsor action.

## 6. Discussion

### 6.1 The Duality of Symmetry and Meaning

Our results reveal a fundamental duality:
- **High symmetry** (large Aut(G)) → **many identifications** (rich iso-space) → **ambiguous meaning**
- **Low symmetry** (small Aut(G)) → **few identifications** (sparse iso-space) → **precise meaning**

This is the mathematical version of a deep philosophical principle: the more symmetric an object, the harder it is to pin down what it "means" in context.

### 6.2 Implications for Analogical Reasoning

In Hofstadter's Copycat framework, analogies between domains are choices of structural correspondence. Our framework adds:
1. The space of analogies has group structure (it's a torsor)
2. "Better" analogies correspond to specific automorphisms
3. The number of essentially different analogies equals |Aut(G)|
4. Rigid domains admit only one analogy (no creativity needed)

### 6.3 Bridge to Simplicial Invariants

The Invariant Separation Theorem subsumes `different_euler_char_not_iso` from the catalog: if two simplicial complexes have different Euler characteristics, they cannot be isomorphic. Our generalization shows this is one instance of a universal principle — any measurable property that is preserved by isomorphisms can serve as a non-isomorphism detector.

## 7. Future Work

1. **Higher Torsors**: Extend the iso-torsor structure to higher categories, where the "space of isomorphisms between isomorphisms" becomes a 2-torsor.
2. **Semantic Entropy**: Define and compute the Shannon entropy of the uniform distribution on Aut(G)-orbits of decorations, giving a quantitative measure of semantic richness.
3. **Tropical Semantics**: Apply the framework to tropical geometry, where the min-plus semiring creates semantic distinctions invisible in classical algebra.

## References

1. Bridges/HigherSimplicial.lean — `different_euler_char_not_iso`: Non-isomorphism detection via Euler characteristic.
2. Computation/GravityOracle.lean — `oracle_preserves_truth`: Truth preservation under structural transformations.
3. FINAL/Bridges/HomologicalDeepLearning.lean — `five_lemma_architecture_equivalence`: Architectural equivalence via homological algebra.
4. Hofstadter, D. R. (1995). *Fluid Concepts and Creative Analogies*. Basic Books.
5. Mac Lane, S. (1998). *Categories for the Working Mathematician*. Springer.
