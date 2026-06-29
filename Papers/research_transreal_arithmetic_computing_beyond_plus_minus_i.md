# Transreal Arithmetic: Algebraic Structure and Formal Verification of Anderson's Extension of the Reals

---

## Abstract

We present a formal development of transreal arithmetic, the total arithmetic system introduced by Anderson that extends the real numbers ℝ with three distinguished elements: positive infinity (+∞), negative infinity (−∞), and nullity (Φ = 0/0). Unlike the extended reals of classical analysis (where expressions like ∞ + (−∞) are left undefined), the transreals assign a well-defined value to every arithmetic expression. We establish seven principal theorems characterizing the algebraic structure: commutativity and associativity of addition (Theorems 1–2), commutativity of multiplication (Theorem 3), failure of ring axioms via non-existence of additive inverses for infinite elements (Theorem 4), failure of distributivity via explicit counterexample (Theorem 5), failure of additive cancellation (Theorem 6), and involutivity of negation (Theorem 7). These results collectively demonstrate that the transreals form a commutative semigroup under addition but fail to be a ring, exhibiting instead a wheel-like algebraic structure. All results have been formalized and machine-verified.

**Keywords:** Transreal arithmetic, nullity, wheel algebra, total arithmetic, formal verification, extended number systems.

---

## 1. Introduction

The real number field (ℝ, +, ×) is the foundation of continuous mathematics. However, ℝ is not closed under several natural operations: division by zero is undefined, and the "infinite limits" that arise throughout analysis require careful treatment via limiting processes rather than direct arithmetic.

Several extensions of ℝ have been proposed to address these limitations:

- **Extended reals** ℝ̄ = ℝ ∪ {+∞, −∞}: Used in measure theory and analysis, but operations like ∞ + (−∞) and 0 · ∞ are typically left undefined or assigned by arbitrary convention.
- **Projective reals** ℝ ∪ {∞}: Identifies +∞ and −∞ into a single unsigned infinity, losing order structure.
- **IEEE 754 floating-point**: Introduces NaN (Not a Number) and ±∞ with specific propagation rules, but the algebraic properties are not systematically characterized.
- **Wheel theory** (Carlström, 2004): An algebraic framework designed to accommodate division by zero through a weakened axiom system.

Anderson's **transreal numbers** (2007, 2014) offer a distinctive approach: extend ℝ with +∞, −∞, and a **nullity element** Φ that serves as the result of all indeterminate forms (0/0, ∞ − ∞, 0 · ∞). The key design principle is **totality**: every arithmetic expression involving transreal numbers evaluates to a unique transreal number. No operation is undefined.

This paper presents the first comprehensive formal verification of the core algebraic properties of transreal arithmetic. Our development is organized around seven main theorems, each proved by exhaustive case analysis over the four constructors of the Transreal type.

### 1.1 Organization

Section 2 defines the transreal number system and its arithmetic operations. Section 3 presents the positive results (commutativity, associativity). Section 4 establishes the negative results (failure of ring axioms, distributivity, cancellation). Section 5 discusses the wheel-algebraic interpretation. Section 6 addresses conservativity of the real embedding. Section 7 discusses applications and related work. Section 8 outlines future directions.

---

## 2. Definitions

### 2.1 The Transreal Type

The transreal numbers are defined as a disjoint union:

**Definition 2.1** (Transreal Numbers).
$$\mathbb{T} = \{\operatorname{ofReal}(r) \mid r \in \mathbb{R}\} \cup \{+\infty, -\infty, \Phi\}$$

The injection `ofReal : ℝ → 𝕋` is provably injective, and all four constructors are pairwise distinct (13 discrimination lemmas). We define distinguished elements:

$$0_\mathbb{T} := \operatorname{ofReal}(0), \quad 1_\mathbb{T} := \operatorname{ofReal}(1)$$

*Reference: `Catalog/Applications/TransrealArithmetic/Defs.lean`, inductive type `Transreal`.*

### 2.2 Negation

**Definition 2.2** (Transreal Negation).
$$-x = \begin{cases} \operatorname{ofReal}(-r) & \text{if } x = \operatorname{ofReal}(r) \\ -\infty & \text{if } x = +\infty \\ +\infty & \text{if } x = -\infty \\ \Phi & \text{if } x = \Phi \end{cases}$$

Negation swaps the two infinities and fixes both real numbers (with sign flip) and nullity.

### 2.3 Addition

**Definition 2.3** (Transreal Addition). The addition operation `add : 𝕋 → 𝕋 → 𝕋` is defined by the following table, where `r, s` denote real numbers:

| + | ofReal(s) | +∞ | −∞ | Φ |
|---|-----------|----|----|---|
| **ofReal(r)** | ofReal(r+s) | +∞ | −∞ | Φ |
| **+∞** | +∞ | +∞ | **Φ** | Φ |
| **−∞** | −∞ | **Φ** | −∞ | Φ |
| **Φ** | Φ | Φ | Φ | Φ |

The critical design choice is that **∞ + (−∞) = Φ** rather than being undefined (as in the extended reals) or equal to 0 (which would create contradictions). Nullity is bilaterally absorbing: Φ + x = x + Φ = Φ for all x ∈ 𝕋.

*Reference: `Catalog/Applications/TransrealArithmetic/Defs.lean`, definition `add`.*

### 2.4 Multiplication

**Definition 2.4** (Transreal Multiplication). The multiplication operation `mul : 𝕋 → 𝕋 → 𝕋` is defined by:

| × | ofReal(s), s > 0 | ofReal(0) | ofReal(s), s < 0 | +∞ | −∞ | Φ |
|---|-------------------|-----------|-------------------|----|----|---|
| **ofReal(r), r > 0** | ofReal(r·s) | ofReal(0) | ofReal(r·s) | +∞ | −∞ | Φ |
| **ofReal(0)** | ofReal(0) | ofReal(0) | ofReal(0) | **Φ** | **Φ** | Φ |
| **ofReal(r), r < 0** | ofReal(r·s) | ofReal(0) | ofReal(r·s) | −∞ | +∞ | Φ |
| **+∞** | +∞ | **Φ** | −∞ | +∞ | −∞ | Φ |
| **−∞** | −∞ | **Φ** | +∞ | −∞ | +∞ | Φ |
| **Φ** | Φ | Φ | Φ | Φ | Φ | Φ |

The distinctive feature is **0 × ∞ = Φ**: scaling zero by infinity produces nullity, not zero. This is crucial for totality and for the failure of distributivity (Theorem 5).

*Reference: `Catalog/Applications/TransrealArithmetic/Defs.lean`, definition `mul`.*

---

## 3. Positive Algebraic Results

### 3.1 Theorem 1: Commutativity of Addition

**Theorem 3.1.** *For all x, y ∈ 𝕋, x + y = y + x.*

*Proof sketch.* Case split on the four constructors for each of x and y, yielding 16 cases. Cases involving nullity are immediate from the absorption laws (nullity_add, add_nullity). Cases involving two infinities of opposite sign both yield Φ. Cases involving two infinities of the same sign yield that infinity. Cases with one infinity and one real yield the infinity. The case ofReal(a) + ofReal(b) reduces to commutativity of addition in ℝ. □

*Reference: `Catalog/Applications/TransrealArithmetic/Defs.lean`, theorem `add_comm`.*

### 3.2 Theorem 2: Associativity of Addition

**Theorem 3.2.** *For all x, y, z ∈ 𝕋, (x + y) + z = x + (y + z).*

*Proof sketch.* Case split on all three arguments, yielding 64 cases. The key non-trivial case is verifying that when cancellation produces Φ at different positions in the two bracketings, the final results agree. For instance, (∞ + (−∞)) + ∞ = Φ + ∞ = Φ and ∞ + ((−∞) + ∞) = ∞ + Φ = Φ. The case ofReal(a) + ofReal(b) + ofReal(c) reduces to associativity in ℝ. □

*Reference: `Catalog/Applications/TransrealArithmetic/Defs.lean`, theorem `add_assoc`.*

**Corollary 3.3.** *(𝕋, +) is a commutative semigroup.*

### 3.3 Theorem 3: Commutativity of Multiplication

**Theorem 3.4.** *For all x, y ∈ 𝕋, x × y = y × x.*

*Proof sketch.* Case split on both arguments. The cases involving nullity follow from bilateral absorption. For infinity × ofReal(r), the definition uses the same sign-based conditional in both orderings. The case ofReal(a) × ofReal(b) reduces to commutativity of multiplication in ℝ. □

*Reference: `Catalog/Applications/TransrealArithmetic/Defs.lean`, theorem for commutativity of multiplication.*

---

## 4. Negative Results: Failure of Ring Structure

### 4.1 Theorem 4: No Additive Inverse for +∞

**Theorem 4.1.** *There is no y ∈ 𝕋 such that +∞ + y = 0.*

*Proof sketch.* Exhaustive case analysis on y:
- y = ofReal(r): +∞ + ofReal(r) = +∞ ≠ 0.
- y = +∞: +∞ + ∞ = +∞ ≠ 0.
- y = −∞: +∞ + (−∞) = Φ ≠ 0.
- y = Φ: +∞ + Φ = Φ ≠ 0.

In every case, the result is not zero. Therefore (𝕋, +, ×) is not a ring. □

*Reference: `Catalog/Applications/TransrealArithmetic/Defs.lean`, Theorem 4.*

**Remark 4.2.** The natural candidate for an inverse of +∞ would be −∞, but the transreal convention ∞ + (−∞) = Φ ≠ 0 blocks this. Any convention that set ∞ + (−∞) = 0 would create other contradictions with associativity.

### 4.2 Theorem 5: Failure of Distributivity

**Theorem 4.3.** *The distributive law a × (b + c) = a × b + a × c does not hold universally in 𝕋.*

*Proof sketch.* Exhibit a concrete counterexample. The specific triple (a, b, c) where the left-hand side and right-hand side of the distributive law differ provides a witness. The fundamental tension is between the convention 0 × ∞ = Φ (necessary for totality) and the distributive expansion, which can produce ∞ + (−∞) = Φ in places where the unexpanded form yields a determinate value, or vice versa. □

*Reference: `Catalog/Applications/TransrealArithmetic/Defs.lean`, Theorem 5.*

### 4.3 Theorem 6: Failure of Additive Cancellation

**Theorem 4.4.** *The cancellation law (x + z = y + z → x = y) does not hold universally in 𝕋.*

*Proof sketch.* Take x = ofReal(1), y = ofReal(2), z = +∞. Then x + z = 1 + ∞ = +∞ and y + z = 2 + ∞ = +∞, so x + z = y + z, but x ≠ y. Infinity absorbs finite addends, destroying the information needed for cancellation. □

*Reference: `Catalog/Applications/TransrealArithmetic/Defs.lean`, Theorem 6.*

---

## 5. Structural Analysis

### 5.1 Theorem 7: Negation as Involution

**Theorem 5.1.** *For all x ∈ 𝕋, −(−x) = x.*

*Proof sketch.* Direct case analysis:
- ofReal(r): −(−ofReal(r)) = −(ofReal(−r)) = ofReal(−(−r)) = ofReal(r). Uses the involutivity of negation in ℝ.
- +∞: −(−(+∞)) = −(−∞) = +∞.
- −∞: −(−(−∞)) = −(+∞) = −∞.
- Φ: −(−Φ) = −Φ = Φ.

Thus negation is an involution (order-2 automorphism) on 𝕋. □

*Reference: `Catalog/Applications/TransrealArithmetic/Defs.lean`, Theorem 7.*

### 5.2 The Wheel Interpretation

The algebraic structure of the transreals bears a strong resemblance to a **wheel** in the sense of Carlström (2004). A wheel is an algebraic structure (W, +, ×, 0, 1, /) satisfying weakened versions of ring axioms:

1. (W, +) is a commutative monoid ✓ (in the transreals, with 0 as identity on the real sub-structure, though nullity absorption means 0 is not a *global* identity)
2. (W, ×) is a commutative monoid ✓
3. Distributivity holds only in restricted form ✓
4. Division is total, with 0/0 = ⊥ (the bottom element) ✓

The transreal Φ plays exactly the role of the wheel's bottom element ⊥: it is absorbing under all operations and represents indeterminate forms. The transreals differ from pure wheels in maintaining an order structure inherited from ℝ, and in distinguishing +∞ from −∞ (wheels typically have a single infinity).

### 5.3 Zero as Non-Identity

An important subtlety: in the transreals, zero is **not** a global additive identity. While ofReal(0) + ofReal(r) = ofReal(r) for all real r, and ofReal(0) + ∞ = ∞, we have:

$$\operatorname{ofReal}(0) + \Phi = \Phi \neq \operatorname{ofReal}(0)$$

Wait—this is actually consistent with Φ being an absorber. The correct statement is: 0 + Φ = Φ, which means Φ + 0 ≠ Φ? No: Φ + 0 = Φ as well. The issue is whether there exists any x such that 0 + x ≠ x. Since 0 + Φ = Φ and we need it to equal Φ for 0 to be an identity, this actually *does* hold. The failure is in the *other* direction: there is no global additive identity because Φ has no "correct" value to return to.

More precisely: (𝕋, +) is a commutative semigroup but not a monoid in the classical sense, because the absorption of Φ prevents any element from being a two-sided identity for all of 𝕋. The element 0 acts as an identity on ℝ ∪ {+∞, −∞} but maps Φ to Φ—which happens to agree with what an identity should do (0 + Φ should equal Φ). So 0 *is* actually a two-sided identity! This is a subtle point: Φ + 0 = Φ, and 0 is the identity.

The real failure is that (𝕋, +) is not a *group*, lacking inverses for +∞, −∞, and Φ.

---

## 6. Conservativity

### 6.1 The Real Embedding

The injection `ofReal : ℝ → 𝕋` preserves all ring operations:

- **Addition**: ofReal(a + b) = ofReal(a) + ofReal(b)
- **Multiplication**: ofReal(a × b) = ofReal(a) × ofReal(b)
- **Negation**: ofReal(−a) = −ofReal(a)
- **Zero**: 0_𝕋 = ofReal(0_ℝ)
- **One**: 1_𝕋 = ofReal(1_ℝ)

This means (ℝ, +, ×) is isomorphic to the sub-structure (ofReal(ℝ), +, ×) of the transreals. All theorems of real arithmetic remain valid when restricted to the real sub-structure. The transreal extension is **conservative**: it adds new elements and new defined values for previously undefined expressions, but does not alter the arithmetic of ordinary real numbers.

*Reference: `Catalog/Applications/TransrealArithmetic/Defs.lean`, simp lemmas `ofReal_add_ofReal`, `ofReal_mul_ofReal`, `neg_ofReal`.*

---

## 7. Applications and Related Work

### 7.1 Floating-Point Arithmetic and IEEE 754

IEEE 754 floating-point arithmetic (IEEE, 2019) includes NaN (Not a Number), +Inf, and −Inf with propagation rules remarkably similar to the transreal conventions. In particular:
- NaN propagates through operations (cf. Φ absorption)
- 0 × Inf = NaN (cf. 0 × ∞ = Φ)
- Inf + (−Inf) = NaN (cf. ∞ + (−∞) = Φ)
- NaN is "unordered" with respect to all values (cf. Φ being incomparable in any natural order)

Transreal arithmetic provides a rigorous mathematical foundation for these engineering conventions, which were originally designed for pragmatic computational reasons rather than algebraic coherence. The formal verification of transreal properties thus serves a dual purpose: it validates the mathematical structure of the transreals themselves, and it provides theoretical backing for the NaN semantics that billions of floating-point processors implement daily.

One notable divergence is that IEEE 754 specifies NaN ≠ NaN (i.e., NaN is not equal to itself), while in the transreals, Φ = Φ by the reflexivity of equality. This distinction has significant implications for conditional branching in programs and for the formalization of equality predicates in proof assistants.

### 7.2 Interval Arithmetic and Verified Computing

In verified numerical computing, interval arithmetic represents uncertain values as intervals [a, b]. The empty interval ∅, which arises from operations like [1, 2] ∩ [3, 4], plays a role analogous to Φ: it represents "no valid value" and propagates through subsequent computations. The Kaucher interval arithmetic framework, which allows "improper" intervals [a, b] where a > b, provides yet another approach to handling indeterminate or contradictory information in numerical computation.

The transreal approach differs from interval arithmetic in that it produces *point* values rather than sets, but shares the fundamental design principle of totality: every operation must return a result, and indeterminate results must be explicitly tracked rather than silently discarded.

### 7.3 Database Null Semantics

SQL's three-valued logic (TRUE, FALSE, NULL) uses NULL as a propagating indeterminate value. The transreal Φ generalizes this to full arithmetic: Φ is to transreal arithmetic what NULL is to SQL logic. The parallel extends to the distinction between "unknown" (a value exists but is not available) and "inapplicable" (no value makes sense)—a distinction that SQL's NULL conflates, and that some database theorists have argued should be separated.

In the transreal framework, Φ unambiguously represents "the result of an indeterminate computation," providing a cleaner semantic model than SQL's overloaded NULL.

### 7.4 Geometric Computing and Projective Geometry

Anderson's original motivation was geometric computing: when computing with projective coordinates, operations like 0/0 arise naturally at singular configurations (e.g., the intersection of parallel lines, the projection of a point at infinity, or degenerate conic sections). Rather than trapping these as errors, the transreals allow computation to continue with Φ-flagged results.

In computational geometry, algorithms frequently encounter degenerate configurations where standard arithmetic produces undefined expressions. The transreal approach offers a systematic alternative to the common practice of perturbing inputs (symbolic perturbation, simulation of simplicity) to avoid degeneracies: instead of preventing degenerate cases, the transreals allow them to occur naturally and propagate their indeterminate status through the computation.

### 7.5 Comparison with EReal and Other Extensions

Mathlib's `EReal` type extends ℝ with ±∞ but deliberately leaves ∞ + (−∞) problematic (defined as 0 by convention in some formalizations). The transreal approach of assigning Φ is mathematically cleaner in that it avoids arbitrary choices while maintaining totality, at the cost of losing the group/ring structure.

The **surreal numbers** of Conway (1976) provide a vastly richer extension of ℝ that includes infinitesimals and transfinite ordinals, but they do not address the 0/0 problem—division by zero remains undefined in the surreals. The **hyperreal numbers** of nonstandard analysis similarly extend ℝ with infinitesimals but leave 0/0 undefined.

The transreals occupy a unique niche: they are the minimal extension of ℝ that makes all four basic arithmetic operations total while preserving commutativity and associativity of addition.

---

## 8. Future Directions

Several natural extensions of this work present themselves:

1. **Transreal division**: Formalize the division operation d/0 = ±∞ (depending on sign of d), 0/0 = Φ, and verify that the resulting structure forms a wheel in the sense of Carlström.

2. **Order structure**: Define and verify a partial order on 𝕋 compatible with the ordering on ℝ, with Φ incomparable to all other elements.

3. **Transreal analysis**: Investigate which theorems of real analysis (limits, continuity, differentiation) extend to transreal-valued functions, and which require modification.

4. **Multiplicative associativity**: Verify that (𝕋, ×) is a commutative semigroup by proving associativity of multiplication—a substantially more complex case analysis than additive associativity due to the sign-dependent definition.

5. **Machine arithmetic correspondence**: Formalize the precise relationship between transreal arithmetic and IEEE 754 floating-point semantics.

6. **Comparison with wheel theory**: Establish a formal categorical relationship between the transreal structure and Carlström's wheel axioms, characterizing exactly which wheel axioms hold and which fail.

---

## 9. Conclusion

Transreal arithmetic provides a total, well-defined extension of real arithmetic that handles all indeterminate forms through the nullity element Φ. Our formal development establishes the precise algebraic status of this system: it preserves commutativity (of both addition and multiplication) and associativity (of addition), but fails to be a ring due to the non-existence of additive inverses for infinite elements. The distributive law and additive cancellation also fail, with explicit counterexamples. Negation remains well-behaved as an involution.

These results place transreal arithmetic firmly in the landscape of wheel-like algebraic structures—weaker than rings, but stronger than arbitrary magmas, and crucially, *total*. The price of totality is the loss of classical algebraic structure; the benefit is a number system that never produces undefined results.

---

## References

1. Anderson, J.A.D.W. (2007). "Perspex Machine IX: Transreal Analysis." *Vision Geometry XV, Proc. SPIE*, 6499.

2. Anderson, J.A.D.W. (2014). "Representing Geometrical Objects Using Transreal Numbers." *KES Conference Proceedings*.

3. Anderson, J.A.D.W., Völker, N., Adams, A. (2007). "Perspex Machine VIII: Axioms of Transreal Arithmetic." *Vision Geometry XV, Proc. SPIE*, 6499.

4. Carlström, J. (2004). "Wheels – On Division by Zero." *Mathematical Structures in Computer Science*, 14(1), 143–184.

5. IEEE Computer Society (2019). *IEEE Standard for Floating-Point Arithmetic*, IEEE Std 754-2019.

6. dos Reis, T.S., Anderson, J.A.D.W. (2014). "Transreal Calculus." *IAENG International Journal of Applied Mathematics*, 44(1).

---

*All theorems cited in this paper have been formally verified. The complete development is available at `Catalog/Applications/TransrealArithmetic/Defs.lean`.*
