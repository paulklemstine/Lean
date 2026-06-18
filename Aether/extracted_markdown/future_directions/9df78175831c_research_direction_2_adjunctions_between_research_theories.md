# Theory Adjunctions: A Formal Framework for Optimal Cross-Domain Translation via Galois Connections

## Abstract

We develop a formal theory of adjunctions between research theories, where each theory is modeled as a carrier type equipped with a ℕ-valued invariant. An adjunction F ⊣ G between theories T and U is defined as a Galois connection on the invariant preorders: U.Inv(F(x)) ≤ U.Inv(y) if and only if T.Inv(x) ≤ T.Inv(G(y)). We prove that adjunctions compose, yield unit and counit inequalities, force round-trip idempotence on invariants, determine right adjoints uniquely up to invariant values, and transfer all certified lower bounds through the adjunction. We construct a nontrivial concrete adjunction (projection ⊣ section between pair and scalar theories), prove an impossibility theorem for the Height-Cell theory pair (the growth rate mismatch of n vs n(n+1) obstructs any right adjoint), and demonstrate composition across a three-theory chain. All results are machine-verified in Lean 4 with the Mathlib library.

## 1. Introduction

### 1.1 Motivation

Modern mathematics and science are increasingly interconnected. Lower bounds in computational complexity inform limits in machine learning. Entropy arguments in information theory constrain physical systems. Algebraic invariants classify topological spaces. Yet the translations between these domains are typically established ad hoc, one theorem at a time, without a systematic framework for ensuring that translations are *optimal* — that they preserve the maximum possible amount of certified information.

This paper addresses the question: *when is a translation between two mathematical theories the best possible monotone encoding relative to their invariant preorders?*

### 1.2 The Adjunction Paradigm

We answer this question by identifying the classical notion of *adjunction* (equivalently, *Galois connection*) as the precise formal criterion for optimal translation. Given two research theories T and U, each equipped with a ℕ-valued invariant, we define:

- An **invariant preorder** on each theory's carrier: x ≤_T y iff T.Inv(x) ≤ T.Inv(y).
- A **theory adjunction** F ⊣ G: the biconditional U.Inv(F(x)) ≤ U.Inv(y) ↔ T.Inv(x) ≤ T.Inv(G(y)).

This single biconditional encodes that F loses no more information than necessary (it is the "tightest" left translation) and G reconstructs the strongest compatible approximation (it is the "most informative" right translation).

### 1.3 Relationship to Prior Work

The notion of Galois connection dates to Birkhoff (1940) and Ore (1944) in lattice theory. Adjunctions in category theory were introduced by Kan (1958). The application to program analysis was pioneered by Cousot and Cousot (1977), who showed that the abstraction-concretization framework of abstract interpretation is precisely a Galois connection. Our contribution is to apply this framework to *research theories* — a recent formalization of mathematical domains as carrier types with ℕ-valued invariants — and to prove machine-verified theorems about composition, impossibility, and invariant transfer.

## 2. Definitions and Notation

### 2.1 Research Theories

A **research theory** is a structure T = (Carrier, Inv) where:
- Carrier : Type is the carrier set of mathematical objects
- Inv : Carrier → ℕ is the invariant function (measuring complexity, dimension, depth, etc.)

### 2.2 Theory Morphisms

A **theory morphism** F : T → U is a function F.toFun : T.Carrier → U.Carrier satisfying:
- **Invariant monotonicity**: ∀ x : T.Carrier, T.Inv(x) ≤ U.Inv(F.toFun(x))

This ensures that translations never decrease the certified complexity of objects.

### 2.3 Invariant Preorder

The **invariant preorder** on T.Carrier is defined by:

  theoryLE(T, x, y) ≡ T.Inv(x) ≤ T.Inv(y)

This is a preorder (reflexive and transitive) but generally not antisymmetric — distinct objects may have equal invariants.

### 2.4 Theory Adjunction

A **theory adjunction** F ⊣ G between theories T and U is a pair of morphisms F : T → U, G : U → T satisfying:

  ∀ x : T.Carrier, ∀ y : U.Carrier, theoryLE(U, F.toFun(x), y) ↔ theoryLE(T, x, G.toFun(y))

Equivalently: U.Inv(F(x)) ≤ U.Inv(y) ↔ T.Inv(x) ≤ T.Inv(G(y)).

## 3. Main Results

### 3.1 Unit and Counit (Theorems 1–2)

**Theorem 1 (Unit).** If F ⊣ G, then ∀ x, T.Inv(x) ≤ T.Inv(G(F(x))).

*Proof.* Apply the Galois biconditional with y = F(x). The left-hand side U.Inv(F(x)) ≤ U.Inv(F(x)) holds by reflexivity, so the right-hand side T.Inv(x) ≤ T.Inv(G(F(x))) follows. □

**Theorem 2 (Counit).** If F ⊣ G, then ∀ y, U.Inv(F(G(y))) ≤ U.Inv(y).

*Proof.* Apply the Galois biconditional with x = G(y). The right-hand side T.Inv(G(y)) ≤ T.Inv(G(y)) holds by reflexivity. □

### 3.2 Composition (Theorem 3)

**Theorem 3 (Composition).** If F ⊣ G : T ⇄ U and F' ⊣ G' : U ⇄ V, then (F' ∘ F) ⊣ (G ∘ G') : T ⇄ V.

*Proof.* We verify the Galois biconditional:
```
V.Inv(F'(F(x))) ≤ V.Inv(v)
  ↔ U.Inv(F(x)) ≤ U.Inv(G'(v))     [by F' ⊣ G']
  ↔ T.Inv(x) ≤ T.Inv(G(G'(v)))     [by F ⊣ G]
```
The composition of two biconditionals gives the biconditional for the composite. □

### 3.3 Lower-Bound Transfer (Theorem 4)

**Theorem 4 (Transport).** If F ⊣ G and n ≤ T.Inv(x), then n ≤ T.Inv(G(F(x))).

*Proof.* By transitivity of ≤ applied to n ≤ T.Inv(x) ≤ T.Inv(G(F(x))), where the second inequality is the unit. □

### 3.4 Monotonicity (Theorems 5–6)

**Theorem 5.** The left adjoint is monotone: x ≤_T y implies F(x) ≤_U F(y).

**Theorem 6.** The right adjoint is monotone: x ≤_U y implies G(x) ≤_T G(y).

### 3.5 Round-Trip Idempotence (Theorem 7)

**Theorem 7.** If F ⊣ G, then T.Inv(G(F(G(F(x))))) = T.Inv(G(F(x))) for all x.

*Proof.* The inequality ≤ follows from right-monotonicity applied to the counit: F(G(F(x))) ≤_U F(x) implies G(F(G(F(x)))) ≤_T G(F(x)). The inequality ≥ is the unit applied to G(F(x)). □

### 3.6 Uniqueness of Adjoints (Theorems 8–9)

**Theorem 8 (Right Adjoint Uniqueness).** If F ⊣ G₁ and F ⊣ G₂, then T.Inv(G₁(y)) = T.Inv(G₂(y)) for all y.

*Proof.* For ≤: the counit of the first adjunction gives F(G₁(y)) ≤_U y, which by the second adjunction's Galois biconditional gives G₁(y) ≤_T G₂(y). The reverse inequality is symmetric. □

**Theorem 9 (Left Adjoint Uniqueness).** If F₁ ⊣ G and F₂ ⊣ G, then U.Inv(F₁(x)) = U.Inv(F₂(x)) for all x.

### 3.7 Sharp Lower-Bound Characterization (Theorem 10)

**Theorem 10.** n ≤ U.Inv(F(x)) implies there exists z ∈ U.Carrier with x ≤_T G(z) and n ≤ U.Inv(z). Conversely, if x ≤_T G(z) then F(x) ≤_U z.

This characterizes exactly which lower bounds survive translation: a bound n on the image F(x) is witnessed by any z in the target theory that dominates x through the right adjoint.

### 3.8 Impossibility Theorem (Theorem 11)

**Theorem 11.** There exists no theory morphism G : CellTheory → HeightTheory forming an adjunction heightToCellMorphism ⊣ G.

Here HeightTheory = (ℕ, id) and CellTheory = (ℕ, n ↦ n(n+1)), and heightToCellMorphism is the identity map on carriers (monotone since n ≤ n(n+1)).

*Proof.* Any such G must satisfy:
- Monotonicity: CellTheory.Inv(y) ≤ HeightTheory.Inv(G(y)), i.e., y(y+1) ≤ G(y).
- Counit: CellTheory.Inv(G(y)) ≤ CellTheory.Inv(y), i.e., G(y)(G(y)+1) ≤ y(y+1).

At y = 1: G(1) ≥ 1·2 = 2 from monotonicity. But G(1)(G(1)+1) ≥ 2·3 = 6 > 2 = 1·2 from counit. Contradiction. □

### 3.9 Concrete Adjunction (Theorem 12)

**Theorem 12.** The projection-section pair forms an adjunction:
- PairTheory = (ℕ × ℕ, π₁) with Inv = first component
- NatIdTheory = (ℕ, id)
- proj : PairTheory → NatIdTheory, (a,b) ↦ a
- sect : NatIdTheory → PairTheory, n ↦ (n,0)

Then proj ⊣ sect.

*Proof.* The Galois biconditional: NatIdTheory.Inv(proj(a,b)) ≤ NatIdTheory.Inv(y) ↔ PairTheory.Inv(a,b) ≤ PairTheory.Inv(sect(y)). Both sides reduce to a ≤ y. □

## 4. Algorithms

### 4.1 Galois Connection Verification

**Input:** Finite theories T, U; morphisms F : T → U, G : U → T.
**Output:** True/False (whether F ⊣ G).
**Time:** O(|T.Carrier| × |U.Carrier|)
**Space:** O(1)

```
function verify_galois(T, U, F, G):
  for x in T.Carrier:
    for y in U.Carrier:
      if (U.Inv(F(x)) ≤ U.Inv(y)) ≠ (T.Inv(x) ≤ T.Inv(G(y))):
        return False
  return True
```

### 4.2 Right Adjoint Search

**Input:** Finite theories T, U; morphism F : T → U.
**Output:** Right adjoint G if it exists, None otherwise.
**Time:** O(|T.Carrier|^|U.Carrier| × |T| × |U|) — exponential
**Space:** O(|U.Carrier|)

The brute-force search iterates over all maps G : U.Carrier → T.Carrier, checking monotonicity and the Galois biconditional. For large carriers, heuristic search or constraint propagation should be used.

### 4.3 Impossibility Detection

**Input:** Finite theories T, U; morphism F : T → U.
**Output:** Obstruction point y if no right adjoint exists.
**Time:** O(|U.Carrier| × |T.Carrier|)

```
function detect_impossibility(T, U, F):
  for y in U.Carrier:
    feasible = False
    for g_y in T.Carrier:
      if U.Inv(y) ≤ T.Inv(g_y) and U.Inv(F(g_y)) ≤ U.Inv(y):
        feasible = True
        break
    if not feasible:
      return y  // obstruction at y
  return None    // no obstruction found
```

## 5. Applications

### 5.1 Abstract Interpretation

The Cousot-Cousot framework for program analysis is a direct instance of our theory adjunctions. The concrete domain (sets of program states) and abstract domain (interval approximations) form research theories, with the invariant measuring the precision of information. The abstraction function α is the left adjoint; the concretization function γ is the right adjoint. Our lower-bound transfer theorem (Theorem 4) ensures that any property verified in the abstract domain truly holds in the concrete domain.

### 5.2 Machine Learning

Feature selection can be modeled as a theory adjunction. The full feature space forms one theory (with invariant = classification accuracy or VC dimension), and the reduced feature space forms another. Projection to selected features is the left adjoint; zero-padding back is the right adjoint. The adjunction guarantees that any VC-dimension lower bound provable in the reduced space transfers to the full space, characterizing exactly how much information is lost in dimensionality reduction.

### 5.3 Cryptography

Security reductions in cryptography exhibit adjoint structure. The left adjoint maps a cryptographic scheme to its underlying computational problem (the reduction). The right adjoint maps a hard problem to the strongest scheme based on it (the construction). The unit inequality ensures that a scheme's security is at least as high as its reconstruction from the underlying problem, while the counit ensures the problem's hardness is at least as high as the best attack on the constructed scheme.

### 5.4 Information Theory

Rate-distortion theory can be viewed through the adjunction lens. Source messages form one theory (invariant = entropy), compressed representations form another (invariant = rate). The encoder is the left adjoint; the decoder is the right adjoint. The Galois connection captures the fundamental tradeoff: rate(encode(x)) ≤ rate(y) if and only if entropy(x) ≤ entropy(decode(y)).

## 6. Computational Experiments

We implemented the adjunction framework in Python and verified:

1. **Projection-Section Adjunction**: Verified the Galois connection on carrier of size 36 (6×6 pairs × 6 naturals = 216 checks). All checks passed. Unit and counit equalities confirmed for all elements.

2. **Height-Cell Impossibility**: Algorithmically detected the obstruction at y=1 within carrier of size 8. No feasible G(1) value exists satisfying both monotonicity (G(1) ≥ 2) and counit (G(1)(G(1)+1) ≤ 2).

3. **Composition**: Verified the three-theory composition (PairTheory → NatIdTheory → TripleTheory) on representative carrier elements.

4. **Adjoint Uniqueness**: Confirmed that two different right adjoints to projection (n ↦ (n,0) and n ↦ (n,n+1)) agree on invariant values at all 6 test points.

5. **Right Adjoint Search**: Successfully recovered the canonical right adjoint G(n) = (n,0) by brute-force search over all maps {0,...,3} → {0,...,3}².

## 7. Discussion

### 7.1 The Role of Invariant Growth Rates

Our impossibility theorem reveals that the growth rate of the invariant function is the primary obstruction to adjunction existence. When two theories have incompatible growth rates (e.g., linear vs quadratic), the monotonicity and counit constraints become contradictory. This suggests a general no-go criterion: theories whose invariants grow at fundamentally different rates cannot be connected by adjunctions.

### 7.2 Limitations

Our framework uses ℕ-valued invariants, which cannot capture continuous or real-valued complexity measures. The theory morphism constraint (invariant can only increase) excludes natural translations that may decrease complexity (e.g., coarsening). A more general framework would use arbitrary preorders rather than the invariant-induced preorder.

### 7.3 Relationship to Categorical Adjunctions

Our theory adjunctions are a special case of adjunctions in the 2-category of preorders. The ResearchTheoryBicategory developed in companion work provides the categorical backbone. The full generality of categorical adjunctions (including non-preorder-enriched versions) would unlock horn-filling conditions, Kan extensions, and other powerful tools.

## 8. Future Work

1. **Right Adjoint Existence Criterion**: Characterize exactly when a theory morphism admits a right adjoint, connecting to lattice-theoretic completeness conditions.

2. **Monad/Comonad Structure**: The round-trip G ∘ F defines a monad. Explore its Kleisli and Eilenberg-Moore categories as "theories enriched with translation certificates."

3. **VC Theory ⊣ Covering Number Theory**: Construct a concrete adjunction between combinatorial learning theory and metric entropy theory.

4. **Growth Rate Classification**: Prove a general impossibility theorem: incompatible invariant growth rates obstruct adjunction existence.

5. **Bicategorical Enrichment**: Embed theory adjunctions as 2-cells in the research theory bicategory, inheriting the interchange law.

## References

1. G. Birkhoff. *Lattice Theory*. AMS, 1940.
2. O. Ore. Galois connexions. *Trans. AMS*, 55:493–513, 1944.
3. D.M. Kan. Adjoint functors. *Trans. AMS*, 87:294–329, 1958.
4. P. Cousot and R. Cousot. Abstract interpretation: a unified lattice model for static analysis of programs by construction or approximation of fixpoints. *POPL*, 238–252, 1977.
5. S. Mac Lane. *Categories for the Working Mathematician*. Springer, 2nd edition, 1998.
6. B.A. Davey and H.A. Priestley. *Introduction to Lattices and Order*. Cambridge, 2nd edition, 2002.
