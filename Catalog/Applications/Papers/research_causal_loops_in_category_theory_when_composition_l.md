# Causal Loops in Category Theory: Associator Defects, Pentagon Obstructions, and Almost-Monoids

## Abstract

We develop a quantitative theory of controlled non-associativity, introducing the **associator defect** as a computable invariant that measures how far a binary operation deviates from associativity. For subtraction on abelian groups, we prove the defect equals exactly −2c, depending only on the rightmost operand — a "causal" property. We show that the pentagon coherence condition, which characterizes when non-associativity can be systematically corrected, fails for subtraction with an explicit obstruction of −4d. We introduce **almost-monoids** as algebraic structures with controlled non-associativity and prove that strict almost-monoids are exactly monoids. We establish **loop rotation invariance** as a group-theoretic property that characterizes associative causal loops, and prove depth bounds for free magma words. All results are machine-verified in Lean 4 with Mathlib.

## 1. Introduction

The associativity axiom (a · b) · c = a · (b · c) is one of the most fundamental properties in algebra. When it holds, the order of evaluation is irrelevant, and n-fold products are unambiguously defined. When it fails — as in the octonions, Lie algebras, or even ordinary subtraction — the situation becomes dramatically more complex.

The modern perspective, originating in Mac Lane's coherence theorem for monoidal categories [1] and developed through the theory of bicategories [2], is that controlled non-associativity — where the two parenthesizations are related by a coherent family of isomorphisms — gives rise to higher categorical structure. The pentagon identity provides the fundamental coherence condition.

In this paper, we make this perspective computationally explicit. Rather than working with abstract natural isomorphisms, we introduce the **associator defect** — an element of the ambient algebraic structure — and study its properties directly. This defect-theoretic approach yields:

1. **Exact computations**: The defect for subtraction is exactly −2c (Theorem 3.1).
2. **Causal structure**: The defect depends only on the rightmost operand (Theorem 3.2).
3. **Pentagon obstruction**: The pentagon coherence condition fails for subtraction, with computable obstruction −4d (Theorems 4.3, 4.4).
4. **Structural characterization**: Zero defect characterizes associativity (Theorem 3.3).
5. **Almost-monoids**: Strict almost-monoids are exactly monoids (Theorem 6.1).

## 2. Definitions

### 2.1 The Associator Defect

**Definition 2.1** (Associator Defect). Let (R, +, −) be an additive group and op : R → R → R a binary operation. The *associator defect* of op at (a, b, c) is:

    AssocDefect(op, a, b, c) = op(op(a, b), c) − op(a, op(b, c))

The defect is zero at (a, b, c) if and only if op is associative at that triple.

### 2.2 Twisted Composition

**Definition 2.2** (Twisted Composition). On ℤ × ℤ, define:

    TwistedComp((p₁, p₂), (q₁, q₂)) = (p₁ + q₁, p₂ − q₂)

This operation is partially associative (in the first component) and non-associative (in the second component).

### 2.3 The Pentagon Condition

**Definition 2.3** (Pentagon Condition). A binary operation op : R → R → R satisfies the *pentagon condition* if for all a, b, c, d ∈ R:

    AssocDefect(op, a, b, c) + AssocDefect(op, a, op(b,c), d) + AssocDefect(op, b, c, d)
    = AssocDefect(op, op(a,b), c, d) + AssocDefect(op, a, b, op(c,d))

This encodes the commutativity of the pentagonal diagram in the associahedron.

### 2.4 Almost-Monoids

**Definition 2.4** (Almost-Monoid). An *almost-monoid* (M, op, e, σ) consists of:
- A binary operation op : M → M → M
- An identity element e with op(e, a) = a and op(a, e) = a
- A corrector σ : M → M → M → M satisfying:
  - σ(a, b, σ(a, b, c)) = c (involution)
  - op(op(a, b), c) = op(a, op(b, σ(a, b, c))) (controlled non-associativity)

An almost-monoid is *strict* if σ(a, b, c) = c for all a, b, c.

### 2.5 Free Magma Words

**Definition 2.5** (Magma Word). A *magma word* over a set α is either a generator gen(a) for a ∈ α, or a composition comp(l, r) of two magma words l and r. The depth and size are defined recursively.

### 2.6 Causal Loops

**Definition 2.6** (Loop). A path [g₁, ..., gₙ] in a group G is a *loop* if g₁ · g₂ · ... · gₙ = 1.

## 3. The Associator Defect for Subtraction

**Theorem 3.1** (Subtraction Defect). For any additive commutative group R and elements a, b, c ∈ R:

    AssocDefect(HSub.hSub, a, b, c) = −(2 • c)

*Proof sketch*: (a − b) − c = a − b − c, while a − (b − c) = a − b + c. The difference is (a − b − c) − (a − b + c) = −2c. □

**Theorem 3.2** (Causal Dependence). The defect of subtraction depends only on the third argument:

    AssocDefect(HSub.hSub, a₁, b₁, c) = AssocDefect(HSub.hSub, a₂, b₂, c)

*Proof*: Both sides equal −(2 • c) by Theorem 3.1. □

**Theorem 3.3** (Defect Characterization). A binary operation op is associative if and only if its defect vanishes everywhere:

    (∀ a b c, AssocDefect(op, a, b, c) = 0) ↔ (∀ a b c, op(op(a,b), c) = op(a, op(b,c)))

*Proof*: By the characterization x − y = 0 ↔ x = y. □

## 4. The Pentagon Obstruction

**Theorem 4.1** (Pentagon for Associative Operations). If op is associative, then op satisfies the pentagon condition.

*Proof*: All defect terms are zero by Theorem 3.3. □

**Theorem 4.2** (Pentagon Failure for Subtraction). Subtraction on ℤ does not satisfy the pentagon condition.

*Proof*: Take a = b = c = 0, d = 1. Using Theorem 3.1:
- LHS = −(2·0) + (−(2·1)) + (−(2·0)) = −2
- RHS = −(2·1) + (−(2·(0−1))) = −2 + 2 = 0
Since −2 ≠ 0, the pentagon condition fails. □

**Theorem 4.3** (Pentagon Obstruction Formula). The pentagon defect for subtraction is:

    LHS − RHS = −4d

where LHS and RHS are the two sides of the pentagon condition. This shows the obstruction is linear in d and vanishes only when d = 0.

## 5. Twisted Composition

**Theorem 5.1** (Twisted Defect). For twisted composition on ℤ × ℤ:

    TwistedComp(TwistedComp(p, q), r) − TwistedComp(p, TwistedComp(q, r)) = (0, −2r₂)

The first component is perfectly associative; the second carries the full defect.

**Theorem 5.2** (Non-Associativity). Twisted composition is not associative.

**Theorem 5.3** (Asymmetric Identity). Twisted composition has a right identity (0, 0) but no left identity, demonstrating the inherent directionality of non-associative operations.

## 6. Almost-Monoids and Strictification

**Theorem 6.1** (Strictification). If an almost-monoid (M, op, e, σ) is strict (σ(a,b,c) = c for all a,b,c), then op is associative. Conversely, every monoid gives rise to a strict almost-monoid.

This establishes the bijection between strict almost-monoids and monoids, providing the algebraic foundation for the strictification theorem in bicategory theory.

## 7. Causal Loop Theory

**Theorem 7.1** (Loop Rotation Invariance). In a group G, if a path [g₁, ..., gₙ] is a loop, then every rotation [gₖ₊₁, ..., gₙ, g₁, ..., gₖ] is also a loop.

*Proof*: Let a = g₁···gₖ and b = gₖ₊₁···gₙ. Then ab = 1 by assumption, so b = a⁻¹, hence ba = a⁻¹a = 1. □

**Theorem 7.2** (Loop Concatenation). The concatenation of two loops is a loop.

**Theorem 7.3** (Loop Detection). A single-element list [g] is a loop if and only if g = 1.

## 8. Free Magma Depth Bounds

**Theorem 8.1** (Size-Leaves Correspondence). The size of a magma word equals the length of its leaf sequence.

**Theorem 8.2** (Depth Bound). The depth of any magma word is strictly less than its size.

This bound is tight: it is achieved by the linear tree (left or right comb).

## 9. Coherence Dimension

**Definition 9.1**. The *coherence dimension* at level n is defined as Nat.centralBinom(n) / (n + 1), the nth Catalan number.

**Theorem 9.1** (Coherence Growth). For n ≥ 3, the coherence dimension is at least n.

This reflects the super-exponential growth of Catalan numbers: the number of coherence conditions to check grows faster than any polynomial.

## 10. Defect Accumulation

**Theorem 10.1** (Accumulation Example). For the list [10, 3, 5, 2]:
- Left-associated subtraction: 10 − 3 − 5 − 2 = 0
- Right-associated subtraction: 10 − (3 − (5 − 2)) = 10

The defect between left and right association is 10, demonstrating that non-associativity accumulates with each additional operation.

## 11. Discussion

### 11.1 Causal Structure of Defects

The most striking result is the *causal* nature of the subtraction defect: it depends only on the rightmost operand. This is reminiscent of causal structures in physics, where the effect of an operation depends on what happens "downstream" rather than "upstream." This suggests a deeper connection between non-associative algebra and directed graphical models.

### 11.2 Pentagon as Phase Boundary

The pentagon identity serves as a phase boundary between coherent and incoherent non-associativity. Operations satisfying the pentagon identity (like those arising from bicategories) admit coherent corrections at all levels. Operations failing it (like subtraction) have wild non-associativity that cannot be systematically tamed.

The explicit computation of the pentagon obstruction (−4d) provides a quantitative measure of "how far" subtraction is from being coherent.

### 11.3 Relation to Higher Category Theory

Almost-monoids as defined here are algebraic shadows of bicategories. The corrector function σ plays the role of the associator 2-morphism, and the involution condition ensures it is an isomorphism. The full bicategory structure requires additional data (composition of 2-morphisms, horizontal composition) and additional coherence conditions (including the pentagon identity for the associator).

## 12. Future Work

1. Extend the defect calculus to n-ary operations and study the resulting higher defects.
2. Classify all binary operations on ℤ whose defect is "causal" (depends only on a subset of arguments).
3. Develop a computational framework for checking pentagon coherence for arbitrary operations.
4. Connect the winding defect to topological invariants of non-associative causal loops.
5. Investigate whether the −4d pentagon obstruction has a homological interpretation.

## References

[1] S. Mac Lane, "Natural associativity and commutativity," Rice University Studies, vol. 49, no. 4, pp. 28–46, 1963.

[2] J. Bénabou, "Introduction to bicategories," Reports of the Midwest Category Seminar, Lecture Notes in Mathematics, vol. 47, pp. 1–77, 1967.

[3] J. Stasheff, "Homotopy associativity of H-spaces, I, II," Transactions of the AMS, vol. 108, pp. 275–312, 1963.

[4] T. Leinster, "Higher Operads, Higher Categories," London Mathematical Society Lecture Note Series, vol. 298, Cambridge University Press, 2004.

[5] C. Simpson, "Homotopy Theory of Higher Categories," Cambridge University Press, 2012.
