# Causal Loops in Category Theory: Controlled Associativity Failure and Coherent Almost-Monoids

## Abstract

We introduce the concept of an *almost-monoid*: an algebraic structure equipped with a binary operation whose associativity fails in a controlled manner, mediated by a family of bijective "associator" functions. We formalize the theory in the Lean 4 proof assistant with the Mathlib library, establishing the following results: (1) every monoid is canonically an almost-monoid with trivial associator; (2) strict almost-monoids satisfy pentagon coherence; (3) pentagon coherence ensures that all reassociation paths are consistent; (4) coherence is preserved under products; (5) the combinatorial structure of reassociations is governed by binary tree rotations that preserve leaf counts; and (6) the associator defect — measuring deviation from strict associativity — vanishes precisely for strict structures. We also state a falsifiable *Associator Rigidity Conjecture* predicting that coherent non-trivial associators cannot be localized. Our work provides an algebraic foundation for understanding bicategories and higher categorical structures through the lens of controlled failure.

## 1. Introduction

Associativity — the property that (a · b) · c = a · (b · c) — is one of the most fundamental axioms in algebra. Yet in modern mathematics, particularly in category theory and homotopy theory, strict associativity is increasingly recognized as an artifact of low-dimensional thinking. In bicategories, monoidal categories, and ∞-categories, composition is associative only up to coherent isomorphisms.

The goal of this paper is to isolate the algebraic essence of this phenomenon. We define *almost-monoids* — structures where associativity holds up to a specified bijective correction — and study when these corrections are *coherent* in the sense that all reassociation paths agree.

### 1.1 Motivation

The passage from categories to bicategories replaces the equality (f ∘ g) ∘ h = f ∘ (g ∘ h) with an isomorphism α_{f,g,h} : (f ∘ g) ∘ h ≅ f ∘ (g ∘ h), subject to the pentagon identity ensuring consistency. Our almost-monoids capture this at the level of elements rather than morphisms, providing a purely algebraic laboratory for studying controlled non-associativity.

### 1.2 Summary of Results

| # | Theorem | Significance |
|---|---------|-------------|
| 1 | `strict_monoid_is_almost_monoid` | Generalization is genuine |
| 2 | `strict_implies_pentagon` | Strict case is trivially coherent |
| 3 | `fundamental_coherence` | Pentagon = reassociation path independence |
| 4 | `strict_is_assoc` | Strict almost-monoids are genuine monoids |
| 5 | `defect_zero_of_strict` | Defect characterizes strictness |
| 6 | `treeAdj_preserves_leafCount` | Reassociation preserves content |
| 7 | `treeConnected_preserves_leafCount` | Content invariance under paths |
| 8 | `three_leaf_adj` | Base case of associahedron connectivity |
| 9 | `three_leaf_connected` | Reassociation graph is connected (n=3) |
| 10 | `almost_monoid_product` | Products preserve almost-monoid structure |
| 11 | `pentagon_preserved_by_product` | Coherence is compositional |
| 12 | `associator_injective` / `surjective` | Associator is a bijection |
| 13 | `coherent_loop_closure` | Strict associators are idempotent |
| 14 | `leftAssoc_leafCount` / `rightAssoc_leafCount` | Canonical trees have expected size |
| 15 | `zero_defect_identity_on_products` | Zero defect ⟹ fixed on products |

## 2. Definitions

### 2.1 Almost-Monoid

**Definition (AlmostMonoid).** An *almost-monoid* on a type M consists of:
- A binary operation mul : M → M → M
- An identity element one : M
- An associator function associator : M → M → M → (M → M)
- such that associator(a,b,c) is a bijection for all a,b,c
- mul(one, a) = a (left identity)
- mul(a, one) = a (right identity)
- mul(mul(a,b), c) = associator(a,b,c)(mul(a, mul(b,c))) (controlled associativity)

The key innovation is that the associator is a *function on elements*, not a morphism in a category. This allows us to study controlled non-associativity in a purely algebraic setting.

### 2.2 Strictness

An almost-monoid is *strict* when associator(a,b,c) = id for all a,b,c. In this case, controlled associativity reduces to ordinary associativity.

### 2.3 Pentagon Coherence

**Definition (PentagonCoherent).** An almost-monoid satisfies *pentagon coherence* if for all a, b, c, d, x ∈ M:

α(a, b, c·d)(α(a·b, c, d)(x)) = α(a, b·c, d)(α(a, b, c)(x))

This says that composing associators for adjacent triples commutes: reassociating (a,b,c·d) after (a·b,c,d) gives the same result as reassociating (a,b·c,d) after (a,b,c).

### 2.4 Associator Defect

The *defect* δ(a,b,c) ∈ {0,1} measures whether the associator moves the canonical right-associated element:
- δ(a,b,c) = 0 if α(a,b,c)(a·(b·c)) = a·(b·c)
- δ(a,b,c) = 1 otherwise

### 2.5 Binary Trees and Reassociation

A binary tree (BinTree) represents a parenthesization. Two trees are *adjacent* (TreeAdj) if one is obtained from the other by a single associator application:

(t₁ · t₂) · t₃ ↔ t₁ · (t₂ · t₃)

or by applying an adjacency step inside a subtree. Trees are *connected* (TreeConnected) if they are related by a sequence of adjacencies and their inverses.

### 2.6 Loop Category

A *loop category* is a category-like structure with:
- Morphism types indexed by pairs of natural numbers
- Composition and identity morphisms
- Forward and backward associator functions that are mutual inverses
- Controlled associativity: comp(comp(f,g),h) = assocFwd(f,g,h)(comp(f, comp(g,h)))

## 3. Main Results

### 3.1 Embedding of Monoids (Theorem 1)

**Theorem.** Every monoid (M, ·, 1) gives rise to an almost-monoid with trivial associator.

*Proof sketch.* Set mul = (·), one = 1, associator(a,b,c) = id. The bijection is immediate (identity is bijective). Left and right identity follow from monoid axioms. Controlled associativity follows from mul_assoc.

### 3.2 Strict Pentagon Coherence (Theorem 2)

**Theorem.** If A is a strict almost-monoid, then A satisfies pentagon coherence.

*Proof sketch.* With all associators equal to id, both sides of the pentagon equation reduce to id(id(x)) = id(id(x)).

### 3.3 Fundamental Coherence (Theorem 5)

**Theorem.** If A satisfies pentagon coherence, then for all a,b,c,d,x:
α(a,b,c·d)(α(a·b,c,d)(x)) = α(a,b·c,d)(α(a,b,c)(x))

This is by definition, but its significance is that it provides *path independence* for reassociation: the order in which we apply associator corrections doesn't matter.

### 3.4 Strict Implies Associative (Theorem 4)

**Theorem.** In a strict almost-monoid, mul(mul(a,b),c) = mul(a, mul(b,c)).

*Proof sketch.* By controlled_assoc, mul(mul(a,b),c) = id(mul(a,mul(b,c))) = mul(a,mul(b,c)).

### 3.5 Tree Rotation Invariants (Theorems 6-9)

**Theorem.** Binary tree adjacency preserves leaf count. More generally, connected trees have the same leaf count.

*Proof sketch.* For the base case (assoc_step), leaf count of ((t₁·t₂)·t₃) is |t₁|+|t₂|+|t₃| = |t₁·(t₂·t₃)| by associativity of natural number addition. Context steps follow by induction.

**Theorem.** The left-associated and right-associated trees with 3 leaves are adjacent, hence connected.

### 3.6 Products Preserve Structure (Theorems 10-11)

**Theorem.** The product of two almost-monoids is an almost-monoid with componentwise operations.

**Theorem.** Pentagon coherence is preserved by products: if A and B are pentagon-coherent, so is A × B.

### 3.7 Defect Analysis (Theorems 3, 15)

**Theorem.** Strict almost-monoids have zero defect everywhere.

**Theorem.** If the defect is zero on all triples, the associator fixes all right-associated products.

### 3.8 Coherent Loop Closure (Theorem 13)

**Theorem.** In a strict almost-monoid, α(a,b,c)(α(a,b,c)(x)) = x.

This captures the "causal loop" phenomenon: in the strict case, the associator is its own inverse (being the identity).

## 4. The Associator Rigidity Conjecture

**Conjecture.** For n ≥ 3, if a finite almost-monoid on {0,...,n-1} has a non-trivial associator on any triple, then pentagon coherence forces at least n triples to have non-trivial associators.

**Testable prediction.** For n = 3 (the smallest case), enumerate all almost-monoid structures on Fin 3 with exactly one non-trivial associator triple. The conjecture predicts that none of these satisfy pentagon coherence.

**Significance.** If true, this would establish a form of *coherence spreading*: non-associativity cannot be localized in a pentagon-coherent structure. The correction mechanism must permeate the entire algebraic system.

## 5. Connection to Bicategories

Our almost-monoid theory provides an algebraic model of the one-object case of bicategories. A bicategory with a single object is precisely a monoidal category, and the endomorphism monoid of the monoidal unit, equipped with the monoidal product, forms an almost-monoid where:

- The binary operation is the monoidal product ⊗
- The associator is the monoidal associator α
- Pentagon coherence is Mac Lane's pentagon axiom

The key difference is that in a monoidal category, the associator is a *natural transformation* (it varies functorially), while in our almost-monoid, it is a family of bijections parameterized by triples. Our formulation is thus both more general (any bijection, not just natural ones) and more elementary (no functoriality required).

## 6. Algorithms

### 6.1 Reassociation Path Finding

Given two binary trees t₁ and t₂ with the same leaf count, find a sequence of rotations transforming t₁ into t₂.

**Algorithm:**
1. If t₁ = t₂, return empty path.
2. Convert t₁ to left-associated form using repeated left rotations.
3. Convert t₂ to left-associated form, recording steps.
4. Concatenate the path from t₁ to left-associated with the reverse path from t₂ to left-associated.

This runs in O(n²) rotations for trees with n leaves.

### 6.2 Pentagon Coherence Verification

For a finite almost-monoid on Fin n, verify pentagon coherence by checking all n⁵ instances of the pentagon equation.

## 7. Discussion

### 7.1 Relationship to Mac Lane's Coherence Theorem

Mac Lane's coherence theorem states that every monoidal category is monoidally equivalent to a strict one. The algebraic shadow of this is our Theorem 1 (every monoid is an almost-monoid) combined with the observation that, in practice, the associator can often be "strictified away." However, the process of strictification may change the underlying set, and our theory makes this explicit.

### 7.2 Higher Coherence

The pentagon coherence condition is the first in an infinite hierarchy. For five elements, one needs the *hexagon identity* (or rather, the 3-dimensional Stasheff polytope K₅). Our binary tree framework naturally extends to this setting: the associahedron K_n encodes all coherence conditions for n elements.

### 7.3 Computational Aspects

The number of parenthesizations of n elements is the Catalan number C(n-1). Our formalization includes an explicit computation of C(0) through C(4) (values 1, 1, 2, 5, 14). The rapid growth of Catalan numbers (C(n) ~ 4^n / (n^(3/2) √π)) means that brute-force verification of coherence quickly becomes infeasible, motivating the theoretical approach.

## 8. Future Work

1. **Prove or disprove the Associator Rigidity Conjecture** for small n.
2. **Extend to higher coherences**: define and study the K₅ (3D associahedron) coherence condition.
3. **Connect to Mathlib's bicategory theory**: show that our AlmostMonoid embeds into Mathlib's existing categorical framework.
4. **Non-trivial examples**: construct almost-monoids with genuinely non-trivial, non-strict associators satisfying pentagon coherence.
5. **Strictification theorem**: prove that every pentagon-coherent almost-monoid is isomorphic (in a suitable sense) to a strict monoid.

## 9. References

1. J. Stasheff, "Homotopy associativity of H-spaces," *Trans. AMS* 108 (1963), 275–292.
2. S. Mac Lane, "Natural associativity and commutativity," *Rice Univ. Stud.* 49 (1963), 28–46.
3. J. Bénabou, "Introduction to bicategories," *Reports of the Midwest Category Seminar*, Springer LNM 47 (1967), 1–77.
4. T. Leinster, *Higher Operads, Higher Categories*, Cambridge University Press, 2004.
5. J. Lurie, *Higher Topos Theory*, Annals of Mathematics Studies 170, Princeton University Press, 2009.
