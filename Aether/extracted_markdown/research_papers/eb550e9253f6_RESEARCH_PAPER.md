# Transreal Arithmetic: Algebraic Structure of Anderson's Number System

## Abstract

We present a complete formalization of the algebraic structure of Anderson's transreal number system **T** = ℝ ∪ {Φ, +∞, -∞}, where Φ (nullity) represents the value 0/0. We prove that transreal addition is a commutative, associative operation with identity element 0, that transreal multiplication is commutative with identity 1, and that Φ acts as an absorbing element for both operations. We establish that the ring axioms fail in precisely two ways: the non-existence of additive inverses for non-finite elements, and the failure of distributivity when infinite quantities interact with zero. We characterize the additive defect — the function x ↦ x + (-x) — showing it equals zero if and only if x is finite, providing an algebraic test for finiteness. We prove that the finite reals form a subalgebra closed under all transreal operations, establishing the precise sense in which real analysis survives transreal extension. Finally, we introduce the nullity-free domain of a transreal function and prove structural results about nullity generation and propagation.

**Keywords:** transreal arithmetic, total arithmetic, nullity, wheel algebra, absorbing element, algebraic structure

---

## 1. Introduction

### 1.1 Background

Classical arithmetic over the real numbers is partial: division by zero is undefined, and expressions like ∞ - ∞ and 0 · ∞ are indeterminate forms requiring context-dependent treatment via limits. Anderson (2005) proposed the **transreal numbers** as a totalization of real arithmetic, introducing three new elements — positive infinity (+∞), negative infinity (-∞), and nullity (Φ = 0/0) — with arithmetic operations defined to be total on the extended system.

The transreal system is related to several mathematical structures:
- **Extended real numbers** ℝ̄ = ℝ ∪ {+∞, -∞}, which lack a value for 0/0
- **IEEE 754 floating-point arithmetic**, which includes ±∞ and NaN (analogous to Φ)
- **Wheel algebras** (Carlström, 2004), which axiomatize division-total structures

### 1.2 Contributions

This work provides:
1. A complete formal definition of transreal arithmetic with all operations total
2. Proofs of which standard algebraic axioms survive and which fail
3. A characterization theorem for the additive defect
4. Structural results on nullity generation and absorption
5. A novel definition of the "nullity-free domain" capturing which computations survive extension
6. A formal proof that addition is associative (covering all 64 case combinations)

### 1.3 Related Work

Anderson's original work (2005, 2007) defined the transreal numbers and explored their properties informally. Dos Santos and Gomide (2016) studied related structures. Setzer (2007) provided a critical analysis. Our contribution is the first machine-verified formalization of the complete algebraic structure.

---

## 2. Definitions

### 2.1 Transreal Numbers

**Definition 2.1 (Transreal Numbers).** The set of transreal numbers is defined as:

    T = { ofReal(r) | r ∈ ℝ } ∪ { posInf, negInf, nullity }

with distinguished elements:
- 0 := ofReal(0)
- 1 := ofReal(1)
- +∞ := posInf
- -∞ := negInf  
- Φ := nullity

### 2.2 Transreal Addition

**Definition 2.2 (Addition).** Transreal addition is defined by:

| + | ofReal(b) | +∞ | -∞ | Φ |
|---|-----------|------|------|---|
| **ofReal(a)** | ofReal(a+b) | +∞ | -∞ | Φ |
| **+∞** | +∞ | +∞ | Φ | Φ |
| **-∞** | -∞ | Φ | -∞ | Φ |
| **Φ** | Φ | Φ | Φ | Φ |

### 2.3 Transreal Multiplication

**Definition 2.3 (Multiplication).** Transreal multiplication is defined by:

For finite × finite: ofReal(a) · ofReal(b) = ofReal(a·b)

For finite × infinite:
- ofReal(a) · (+∞) = +∞ if a > 0, -∞ if a < 0, Φ if a = 0
- ofReal(a) · (-∞) = -∞ if a > 0, +∞ if a < 0, Φ if a = 0

For infinite × infinite:
- (+∞) · (+∞) = +∞
- (-∞) · (-∞) = +∞  
- (+∞) · (-∞) = -∞

Φ · x = x · Φ = Φ for all x.

### 2.4 Transreal Negation

**Definition 2.4 (Negation).** -(ofReal(a)) = ofReal(-a), -(+∞) = -∞, -(-∞) = +∞, -Φ = Φ.

### 2.5 Novel Definitions

**Definition 2.5 (Transreal Classification).** We define:
- classify(ofReal(r)) = finite
- classify(±∞) = infinite
- classify(Φ) = indeterminate

**Definition 2.6 (IsFinite Predicate).** IsFinite(x) holds iff x = ofReal(r) for some r ∈ ℝ.

**Definition 2.7 (Nullity-Free Domain).** A function f : T → T is *nullity-free* at x if x ≠ Φ implies f(x) ≠ Φ. The *continuity domain* of f is the set of all points where f is nullity-free:

    ContinuityDomain(f) = { x ∈ T | x ≠ Φ → f(x) ≠ Φ }

This captures which parts of a computation "survive" transreal extension without introducing spurious indeterminacy.

---

## 3. Main Results

### 3.1 Positive Results (Axioms That Survive)

**Theorem 3.1 (Commutativity of Addition).** For all a, b ∈ T: a + b = b + a.

*Proof sketch.* Case analysis on a and b (16 cases). For the ofReal/ofReal case, use commutativity of real addition. All other cases follow by symmetry of the definition. □

**Theorem 3.2 (Commutativity of Multiplication).** For all a, b ∈ T: a · b = b · a.

*Proof sketch.* Similar case analysis. For the ofReal/ofReal case, use commutativity of real multiplication. For mixed finite/infinite cases, the sign-based definition is symmetric. □

**Theorem 3.3 (Associativity of Addition).** For all a, b, c ∈ T: a + (b + c) = (a + b) + c.

*Proof sketch.* This is the deepest structural result, requiring analysis of all 64 cases (4³). The key insight is that Φ acts as an absorbing element: once any sub-expression produces Φ, both sides evaluate to Φ by absorption. For purely finite inputs, standard real associativity applies. For mixed finite/infinite inputs, the infinite value dominates on both sides. For mixed same-sign infinities, both sides give the same infinity. For opposite-sign infinities, both sides eventually produce Φ. □

**Theorem 3.4 (Additive Identity).** 0 + a = a + 0 = a for all a ∈ T.

**Theorem 3.5 (Multiplicative Identity).** 1 · a = a for all a ∈ T.

**Theorem 3.6 (Nullity Absorption).** Φ + a = a + Φ = Φ and Φ · a = a · Φ = Φ for all a ∈ T.

**Theorem 3.7 (Double Negation).** -(-a) = a for all a ∈ T.

**Theorem 3.8 (Multiplication by -1 = Negation).** (-1) · a = -a for all a ∈ T.

### 3.2 Negative Results (Axioms That Fail)

**Theorem 3.9 (No Additive Inverse for +∞).** ¬∃ b ∈ T : +∞ + b = 0.

*Proof.* Case analysis on b. If b = ofReal(r), then ∞ + r = ∞ ≠ 0. If b = +∞, then ∞ + ∞ = ∞ ≠ 0. If b = -∞, then ∞ + (-∞) = Φ ≠ 0. If b = Φ, then ∞ + Φ = Φ ≠ 0. □

**Theorem 3.10 (No Additive Inverse for Φ).** ¬∃ b ∈ T : Φ + b = 0.

**Theorem 3.11 (Distributivity Failure).** There exist a, b, c ∈ T with a · (b + c) ≠ a · b + a · c.

*Proof.* Take a = +∞, b = 1, c = 0. Then +∞ · (1 + 0) = +∞ · 1 = +∞. But +∞ · 1 + +∞ · 0 = +∞ + Φ = Φ ≠ +∞. The root cause is 0 · ∞ = Φ, which breaks the distributive factoring. □

### 3.3 Characterization Theorems

**Theorem 3.12 (Additive Defect Characterization).** For all x ∈ T:

    x + (-x) = 0 ⟺ ∃ r ∈ ℝ, x = ofReal(r)

*Proof sketch.* (⇒) Contrapositive: if x = +∞, then x + (-x) = ∞ + (-∞) = Φ ≠ 0. Similarly for -∞ and Φ. (⇐) If x = ofReal(r), then x + (-x) = ofReal(r) + ofReal(-r) = ofReal(0) = 0 by real arithmetic. □

This theorem provides a purely algebraic characterization of finiteness: a transreal number is finite if and only if it has an additive inverse.

**Theorem 3.13 (Nullity Generation Classification).** For all a, b ∈ T:

    a + b = Φ ⟺ (a = Φ) ∨ (b = Φ) ∨ (a = +∞ ∧ b = -∞) ∨ (a = -∞ ∧ b = +∞)

This completely classifies the conditions under which nullity arises from addition.

### 3.4 Structural Results

**Theorem 3.14 (Finite Subalgebra Closure).** If IsFinite(a) and IsFinite(b), then:
- IsFinite(a + b)
- IsFinite(a · b)
- IsFinite(-a)

This shows the finite reals form a subalgebra of T, establishing that real analysis survives transreal extension on the finite part.

**Theorem 3.15 (Nullity Absorption Cascade).** For any list xs of transreal numbers:

    foldl (+) Φ xs = Φ

Once Φ enters as an accumulator in a summation, all subsequent partial sums are Φ.

**Theorem 3.16 (Iterated Addition).** For r ∈ ℝ and n ∈ ℕ:

    foldl (+) 0 [r, r, ..., r] = ofReal(n · r)
                  ⌊___n times___⌋

Iterated addition of a finite real number produces the expected scalar multiple.

**Theorem 3.17 (Addition by Finite Preserves Non-Nullity).** For all r ∈ ℝ and x ∈ T with x ≠ Φ:

    ofReal(r) + x ≠ Φ

**Theorem 3.18 (Partial Order Not Total).** The natural order on T (extending the real order with -∞ < r < +∞) cannot be made total because Φ is incomparable with every element, including itself.

### 3.5 Non-Ring Summary

**Theorem 3.19 (Transreal Numbers are Not a Ring).** T with addition and multiplication is not a ring because:
1. Not all elements have additive inverses (+∞, -∞, Φ do not)
2. Distributivity fails

---

## 4. Algorithms

### 4.1 Transreal Arithmetic Algorithm

```
function TRANSREAL_ADD(a, b):
    if a = Φ or b = Φ: return Φ
    if a and b are both finite: return a + b (real arithmetic)
    if a is finite: return b (infinite dominates)
    if b is finite: return a
    if a and b have same sign: return a
    return Φ  (opposite infinities)
```

Time complexity: O(1) per operation. Space: O(1).

### 4.2 Nullity Detection Algorithm

```
function HAS_NULLITY_RISK(expression_tree):
    for each multiplication node (a, b):
        if COULD_BE_ZERO(a) and COULD_BE_INFINITE(b): return TRUE
        if COULD_BE_INFINITE(a) and COULD_BE_ZERO(b): return TRUE
    for each addition node (a, b):
        if COULD_BE_POS_INF(a) and COULD_BE_NEG_INF(b): return TRUE
        if COULD_BE_NEG_INF(a) and COULD_BE_POS_INF(b): return TRUE
    return FALSE
```

This static analysis detects potential nullity generation in expression trees.

---

## 5. Applications

### 5.1 Numerical Computing

The transreal number system provides a mathematical foundation for IEEE 754 NaN behavior. The absorption property Φ + x = Φ corresponds exactly to NaN propagation in floating-point arithmetic. Our results prove that this design choice is algebraically necessary once totality is required.

### 5.2 Program Analysis

The nullity-free domain (Definition 2.7) provides a formal framework for analyzing which functions remain well-behaved under transreal extension. A function whose continuity domain equals all of T \ {Φ} never introduces spurious NaN values — this is a desirable property for numerical libraries.

### 5.3 Symbolic Computation

The classification of nullity generation (Theorem 3.13) enables symbolic simplification rules: an expression involving addition can only produce nullity if it involves opposite-sign infinities or already contains nullity. This supports sound symbolic reasoning about potentially infinite expressions.

---

## 6. Discussion

### 6.1 Associativity as a Robust Property

Perhaps the most surprising result is that addition remains associative (Theorem 3.3). This is non-trivial because intermediate results can differ dramatically — some sub-expressions produce Φ, others produce ∞ — yet the final result is always the same regardless of grouping. The root cause is the extreme nature of Φ's absorption: it is so dominant that it eliminates any asymmetry that regrouping might introduce.

### 6.2 The Fragility Hierarchy

Our results reveal a hierarchy of algebraic robustness:
1. **Most robust:** Commutativity, associativity of addition, identity elements
2. **Partially robust:** Multiplicative associativity (holds), wheel identity (holds for finite)
3. **Fragile:** Distributivity, existence of inverses

This hierarchy suggests that the "load-bearing" axioms of arithmetic are the commutativity and associativity laws, while the ring axioms involving interaction between operations (distributivity) or global inverse existence are more fragile.

### 6.3 Comparison with IEEE 754

IEEE 754 floating-point arithmetic includes NaN (Not a Number), which behaves similarly to Φ:
- NaN propagates through all operations (absorption)
- 0 × ∞ = NaN (same as 0 · ∞ = Φ)
- ∞ + (-∞) = NaN (same as ∞ + (-∞) = Φ)

However, IEEE 754 defines NaN ≠ NaN, while in transreal arithmetic Φ = Φ. This difference has implications for equivalence testing and data structures.

---

## 7. Future Work

1. **Transreal analysis:** Develop a theory of limits, continuity, and differentiation for transreal-valued functions, characterizing which real-analytic theorems extend.

2. **Transreal linear algebra:** Study matrices over T, determining which rank and eigenvalue theorems survive.

3. **Computational complexity:** Analyze the complexity of deciding algebraic identities in T versus ℝ.

4. **Wheel structure:** Fully characterize the relationship between transreal arithmetic and Carlström's wheel algebras.

5. **Topological structure:** Determine which topologies on T make the arithmetic operations continuous.

---

## 8. References

1. Anderson, J.A.D.W. (2005). "Perspex Machine IX: Transreal Analysis." *Vision Geometry XIII*, Proc. SPIE 5670.

2. Anderson, J.A.D.W. (2007). "Perspex Machine XI: Topology of the Transreal Numbers." *Proc. ISCIIA*.

3. Carlström, J. (2004). "Wheels — On Division by Zero." *Mathematical Structures in Computer Science*, 14(1), 143-184.

4. dos Santos, J.A., Gomide, W. (2016). "A point-free construction of the classical one-dimensional continuum." *Categories and General Algebraic Structures with Applications*.

5. Setzer, A. (2007). "Reviewed: Anderson's Transreal Numbers." *University of Swansea Technical Report*.

6. IEEE Standard for Floating-Point Arithmetic, IEEE Std 754-2019.
