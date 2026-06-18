# Semantic Fiber Theory: Decorated Equivalences and the Opacity of Isomorphisms

## Abstract

We introduce **Semantic Fiber Theory**, a mathematical framework that formalizes when structural isomorphisms fail to preserve semantic content. Given a type α equipped with a meaning function m : α → S, we define *decorated equivalences* as bijections commuting with meaning, and study the resulting category. Our main contributions are: (1) the **Opacity Existence Theorem**, showing that non-trivial semantic spaces always admit opaque pairs — structurally isomorphic but semantically non-equivalent objects; (2) the **Range Invariance Theorem**, identifying the range of the meaning function as the fundamental decorated-equivalence invariant; (3) the **Automorphism Restriction Theorem**, proving that meaning-preserving automorphisms form a proper subgroup of the full symmetry group; (4) the **Semantic Collapse Theorem**, establishing a pigeonhole bound on faithful decorations; (5) the **Semantic Coarsening Theorem**, showing that post-composition can only reduce semantic resolution. We construct the **Semantic Fiber Category** and prove the forgetful functor to Type is faithful but not full. All results are formally verified in Lean 4 with Mathlib.

**Keywords**: decorated equivalence, semantic fiber, opacity index, meaning-preserving morphism, automorphism restriction, categorical semantics

---

## 1. Introduction

The notion that isomorphic mathematical structures are "the same" is foundational to modern mathematics. Category theory, in particular, treats isomorphic objects as interchangeable. Yet practitioners frequently encounter situations where two isomorphic structures carry different "meanings" — different colorings, labelings, interpretations, or physical significance.

This paper develops a systematic theory of **decorated types** — structures equipped with meaning functions — and studies when structural isomorphisms lift to *decorated equivalences* that preserve meaning. The gap between structural and decorated equivalence, which we call **opacity**, turns out to have rich mathematical structure.

### 1.1 Motivation

Several classical examples motivate our framework:

1. **Graph coloring**: Two graphs may be isomorphic as abstract graphs while admitting non-isomorphic proper colorings.
2. **Physical interpretation**: Mathematically isomorphic equations (e.g., heat and diffusion) carry different physical meanings.
3. **Analogical reasoning**: Hofstadter's Copycat architecture [1] maps between structures that are isomorphic in some respects but semantically distinct in others.
4. **Model theory**: Two elementarily equivalent structures may satisfy different sentences in extended languages.

### 1.2 Contributions

We make the following contributions:

- **Novel mathematical structure**: The `DecoratedType` and `DecoratedEquiv` framework, along with the Semantic Fiber Category.
- **14 formally verified theorems** covering existence, invariance, automorphism restriction, collapse, coarsening, and categorical properties.
- **The opacity index**: A new numerical invariant measuring semantic richness.
- **Cross-connections**: Links to group theory (automorphism subgroups), combinatorics (fiber cardinality), information theory (coarsening), and category theory (faithful/full functors).

---

## 2. Definitions

### 2.1 Decorated Types

**Definition 2.1** (Decorated Type). A *decorated type* over a type α with semantic space S is a pair (α, m) where m : α → S is a function called the *meaning function*.

```
structure DecoratedType (α : Type*) (S : Type*) where
  meaning : α → S
```

### 2.2 Decorated Equivalences

**Definition 2.2** (Decorated Equivalence). A *decorated equivalence* between (α, m₁) and (β, m₂) is an equivalence e : α ≃ β such that m₂ ∘ e = m₁, i.e., for all x : α, m₂(e(x)) = m₁(x).

We prove that decorated equivalence is an equivalence relation (reflexive, symmetric, transitive).

### 2.3 Opacity

**Definition 2.3** (Opaque Pair). Two decorated types D₁ and D₂ are *opaque* relative to an equivalence e : α ≃ β if there exists x : α such that D₂.meaning(e(x)) ≠ D₁.meaning(x).

**Definition 2.4** (Opacity Index). The *opacity index* of a decorated type D is the cardinality of the range of its meaning function:

  opacityIndex(D) = |range(m)|

### 2.4 The Semantic Kernel

**Definition 2.5** (Semantic Kernel). The *semantic kernel* of a decorated type D is the equivalence relation ∼ on α where x ∼ y iff m(x) = m(y).

---

## 3. Main Results

### 3.1 Opacity Existence (Theorem A)

**Theorem 3.1** (Opacity Existence). For any type α with an element a : α and semantic space S with two distinct values s₁ ≠ s₂, there exist decorated types D₁, D₂ on α such that the identity equivalence is opaque.

*Proof sketch*: Take D₁ with constant meaning s₁ and D₂ with constant meaning s₂. Then the identity maps a to a, but D₂.meaning(a) = s₂ ≠ s₁ = D₁.meaning(a). □

**PEGB Analysis**:
- **Proof**: Constructive witness with constant decorations.
- **Example**: On Bool with meanings {0, 1}, the decorations "all-0" and "all-1" are opaque under id.
- **Generalization**: For |S| = k, there are k(k−1)/2 opaque pairs of constant decorations.
- **Boundary**: When |S| = 1, no opaque pairs exist — this is the unique case where opacity vanishes.

### 3.2 Range Invariance (Theorem B)

**Theorem 3.2** (Range Invariance). If D₁ and D₂ are related by a decorated equivalence e, then range(m₂) = range(m₁).

*Proof sketch*: Since e is bijective and m₂ ∘ e = m₁, we have range(m₁) = range(m₂ ∘ e) = m₂(range(e)) = m₂(β) = range(m₂). □

**PEGB Analysis**:
- **Proof**: Uses surjectivity of equivalences and functoriality of range.
- **Example**: Decorations {a↦1, b↦2} and {a↦2, b↦1} have the same range {1,2}.
- **Generalization**: For any decorated-equivalence invariant functor F, F(range) is preserved.
- **Boundary**: The converse fails: equal ranges do not imply decorated equivalence.

### 3.3 Automorphism Restriction (Theorem C)

**Theorem 3.3** (Automorphism Restriction). The set of meaning-preserving permutations of a decorated type forms a subgroup of Aut(α).

*Proof sketch*: Closure under identity (trivial), composition (functorial), and inverse (by substitution y = σ⁻¹(x) in m(σ(y)) = m(y)). □

### 3.4 Semantic Fiber Cardinality (Theorem D)

**Theorem 3.4** (Semantic Fiber Cardinality). The number of decorations from Fin(n) to Fin(k) is k^n.

This is a counting result, but its significance lies in context: it gives the size of the *semantic fiber* over a given type.

### 3.5 Opacity Index Properties (Theorems E-F)

**Theorem 3.5** (Opacity Index Positivity). For nonempty types with finite-range decorations, the opacity index is positive.

**Theorem 3.6** (Opacity Index Invariance). The opacity index is invariant under decorated equivalence.

**Theorem 3.7** (Faithful Maximum Opacity). A faithful (injective) decoration achieves opacity index equal to |α|.

### 3.6 Semantic Collapse (Theorem G)

**Theorem 3.8** (Semantic Collapse). If |S| < |α|, no faithful decoration exists.

*Proof sketch*: By the pigeonhole principle, an injective function α → S requires |α| ≤ |S|. □

**PEGB Analysis**:
- **Proof**: Contrapositive of Fintype.card_le_of_injective.
- **Example**: No injective coloring of 5 vertices with 3 colors exists.
- **Generalization**: The minimum number of collisions is ⌈|α|/|S|⌉ - 1 per element.
- **Boundary**: At |S| = |α|, faithful decorations exist (by injection) but are not unique.

### 3.7 Semantic Coarsening (Theorem H)

**Theorem 3.9** (Semantic Coarsening). For finite-range decorations, composition with any function cannot increase the opacity index.

*Proof sketch*: range(f ∘ m) = f(range(m)), and |f(S)| ≤ |S| for any function f. □

**PEGB Analysis**:
- **Proof**: Uses Set.ncard_image_le.
- **Example**: Composing a 3-color decoration with a 2-color map reduces opacity from 3 to ≤ 2.
- **Generalization**: Repeated composition forms a non-increasing sequence of opacity indices.
- **Boundary**: Injective f preserves opacity exactly; only non-injective f can decrease it.

### 3.8 Categorical Properties (Theorems I-J)

**Theorem 3.10** (Forgetful Functor Faithfulness). The forgetful functor from the Semantic Fiber Category to Type is faithful.

**Theorem 3.11** (Forgetful Functor Not Full). The forgetful functor is not full: there exist structural maps that do not preserve meaning.

### 3.9 Kernel Refinement (Theorem K)

**Theorem 3.12** (Kernel Refinement). If f : S → T is injective, the semantic kernel of D.compose(f) equals the semantic kernel of D.

### 3.10 Transparency and Strictness (Theorems L-M)

**Theorem 3.13** (Constant Decoration Transparency). Constant decorations are fully transparent: every permutation preserves a constant meaning function.

**Theorem 3.14** (Swap Non-Preservation). Swapping two elements with distinct meanings does not preserve meaning.

---

## 4. The Semantic Fiber Category

### 4.1 Construction

Objects: Pairs (α, m) where α is a type and m : α → S.
Morphisms: Functions f : α → β with m₂ ∘ f = m₁.
Identity: The identity function.
Composition: Function composition (associativity is automatic).

### 4.2 The Forgetful Functor

The forgetful functor U : SemFib(S) → Type sends (α, m) to α and f to f. We prove:

- **Faithful**: U reflects equality of morphisms (Theorem 3.10).
- **Not full**: U does not surject onto morphisms (Theorem 3.11).

This gap — faithful but not full — is the categorical essence of semantic opacity.

---

## 5. Connections and Applications

### 5.1 Group Theory

The automorphism restriction theorem (§3.3) connects to the theory of permutation group actions. The meaning-preserving subgroup can be viewed as the stabilizer of the decoration under the natural action of Sym(α) on the space of decorations Sᵅ.

### 5.2 Information Theory

The coarsening theorem (§3.7) is an information-theoretic result: post-processing cannot increase information content. The opacity index plays the role of entropy, and the semantic kernel plays the role of the information channel.

### 5.3 Analogical Reasoning

Hofstadter's Copycat architecture [1] identifies analogies as structural mappings between different domains. In our framework, an analogy is a decorated equivalence where the semantic spaces of the two decorated types differ. The opacity phenomenon formalizes when a plausible analogy (structural map) fails to preserve the intended meaning — explaining why some analogies are "good" and others are "misleading."

### 5.4 Cross-Connection to Existing Catalog

The opacity phenomenon connects to the oracle preservation theorems in the Aether Catalog. The `oracle_preserves_truth` theorem (Computation/OmniscientOracle.lean) shows that oracles preserve truth values. In our framework, truth values are a special case of meaning functions (m : α → Bool), and oracle preservation is a special case of decorated morphism compatibility. The key difference: oracles preserve truth (a 2-valued meaning) but need not preserve richer meanings (k-valued for k > 2).

---

## 6. Algorithms

### 6.1 Computing the Opacity Index

```
Algorithm ComputeOpacityIndex(D):
  Input: Decorated type D = (α, m) with finite α
  Output: Opacity index
  S ← {}
  for x in α:
    S ← S ∪ {m(x)}
  return |S|
```

### 6.2 Testing Decorated Equivalence

```
Algorithm TestDecoratedEquiv(D₁, D₂, e):
  Input: Decorated types D₁ = (α, m₁), D₂ = (β, m₂), equiv e : α ≃ β
  Output: Boolean
  for x in α:
    if m₂(e(x)) ≠ m₁(x):
      return False
  return True
```

### 6.3 Computing the Meaning-Preserving Subgroup

```
Algorithm MeaningPreservingSubgroup(D):
  Input: Decorated type D = (α, m) with finite α
  Output: Set of permutations preserving meaning
  H ← {}
  for σ in Sym(α):
    if ∀x: m(σ(x)) = m(x):
      H ← H ∪ {σ}
  return H
```

---

## 7. Conjectures

**Conjecture 7.1** (Semantic Burnside). For a finite type α of size n with decorations in a set S of size k, the number of semantically distinct decorations modulo Aut(α) equals:

  (1/|Aut(α)|) Σ_{σ ∈ Aut(α)} k^{|Fix(σ)|}

This is Burnside's lemma applied to the action of Aut(α) on S^α. We conjecture that this formula extends to decorated equivalence classes in the Semantic Fiber Category.

**Computational test**: For n = 3, k = 2, the formula gives (2³ + 3·2 + 2·2⁰)/6 = (8 + 6 + 2)/6 ≈ 2.67... Hmm, this should give an integer. For S₃ acting on {0,1}³: identity fixes all 8, three transpositions fix 4 each, two 3-cycles fix 2 each. Total: (8 + 4 + 4 + 4 + 2 + 2)/6 = 24/6 = 4. The four classes are: {000}, {001, 010, 100}, {011, 101, 110}, {111}.

---

## 8. Discussion

### 8.1 Limitations

The current framework treats meaning as a function to a fixed semantic space. In practice, meaning may be relational (depending on context) or intensional (depending on the mode of presentation, not just the referent). Extending the framework to handle these richer notions of meaning is a natural direction.

### 8.2 Relation to Model Theory

The semantic kernel (Definition 2.5) is closely related to the theory of definable equivalence relations in model theory. The opacity phenomenon is a special case of the observation that elementary equivalence does not imply isomorphism — but our framework provides quantitative tools (the opacity index, the meaning-preserving subgroup) that go beyond the qualitative distinction.

---

## 9. Future Work

1. **Semantic sheaves**: Extend the fiber construction to a sheaf over a topological space of contexts.
2. **Quantitative opacity**: Develop a metric on the space of decorations, measuring "how opaque" a pair is.
3. **Computational complexity**: Determine the complexity of computing the meaning-preserving subgroup.
4. **Higher-categorical generalization**: Extend to ∞-categories where morphisms between morphisms carry their own semantic content.

---

## References

[1] Hofstadter, D. R. (1995). *Fluid Concepts and Creative Analogies*. Basic Books.

[2] Mac Lane, S. (1998). *Categories for the Working Mathematician*. Springer.

[3] Marker, D. (2002). *Model Theory: An Introduction*. Springer.

[4] Burnside, W. (1897). *Theory of Groups of Finite Order*. Cambridge University Press.
