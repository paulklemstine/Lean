# Transreal Arithmetic: Formalized Ring Failure and Emergent Algebraic Structure

## Abstract

We present a complete formalization of Anderson's transreal number system ℝ ∪ {+∞, −∞, Φ} in Lean 4 with Mathlib, where Φ = 0/0 (nullity) makes division total. We prove that the ring axioms fail in two essential ways: (1) +∞ and Φ have no additive inverses, and (2) the distributive law fails, with the explicit witness ∞·(1+(−∞)) = −∞ ≠ Φ = ∞·1 + ∞·(−∞). Despite these failures, we establish that the transreal numbers retain significantly more algebraic structure than expected: addition and multiplication are both globally commutative and associative, negation distributes over addition globally, and nullity is the unique absorbing element. We characterize the resulting algebraic structure and identify the precise boundary between preserved and broken ring properties.

## 1. Introduction

Anderson's transreal numbers [1] extend the real line with three additional elements: positive infinity (+∞), negative infinity (−∞), and nullity (Φ), defined as 0/0. The primary motivation is to make division a total function, eliminating the need for "undefined" in arithmetic expressions involving division by zero.

Previous work has studied transreal arithmetic primarily through informal mathematical analysis. Our contribution is a complete mechanized formalization in Lean 4 with Mathlib, providing machine-verified proofs of the key structural results. This formalization resolves several questions about the algebraic structure:

1. **Which ring axioms survive?** Commutativity and associativity of both operations survive globally. The distributive law and existence of additive inverses do not.

2. **What is nullity's algebraic role?** Nullity is a universal absorber—the unique element that absorbs all operations from both sides.

3. **Is the resulting structure a wheel?** The structure shares key features with wheels (total division, loss of distributivity) but is strictly stronger due to full associativity.

## 2. Definitions

### 2.1 The Transreal Type

```
inductive Transreal where
  | ofReal : ℝ → Transreal
  | posInf : Transreal
  | negInf : Transreal
  | nullity : Transreal
```

### 2.2 Operations

**Addition** follows the convention that ∞ + (−∞) = Φ (the indeterminate form), nullity absorbs all additions, and finite + infinite = infinite:

| + | ofReal b | +∞ | −∞ | Φ |
|---|---------|-----|-----|---|
| ofReal a | ofReal(a+b) | +∞ | −∞ | Φ |
| +∞ | +∞ | +∞ | Φ | Φ |
| −∞ | −∞ | Φ | −∞ | Φ |
| Φ | Φ | Φ | Φ | Φ |

**Multiplication** is sign-dependent for mixed finite-infinite products:
- posInf × ofReal(b) = posInf if b > 0, negInf if b < 0, Φ if b = 0
- posInf × posInf = posInf, posInf × negInf = negInf, negInf × negInf = posInf
- nullity × x = Φ for all x

**Division** is total:
- ofReal(a) / ofReal(b) = ofReal(a/b) if b ≠ 0
- ofReal(a) / ofReal(0) = posInf if a > 0, negInf if a < 0, Φ if a = 0
- ∞/∞ = Φ, ∞/0 = Φ
- x / Φ = Φ for all x

**Negation**: −(posInf) = negInf, −(negInf) = posInf, −Φ = Φ.

### 2.3 Predicates

- **IsFinite(x)**: x = ofReal(r) for some r ∈ ℝ
- **IsDeterminate(x)**: x ≠ Φ
- **IsInfinite(x)**: x ∈ {+∞, −∞}

## 3. Main Results

### 3.1 Ring Axiom Failures

**Theorem 3.1 (No Additive Inverse for +∞).**
*There is no x ∈ Transreal such that +∞ + x = 0.*

*Proof.* By case analysis: +∞ + ofReal(r) = +∞, +∞ + (+∞) = +∞, +∞ + (−∞) = Φ, +∞ + Φ = Φ. None equal ofReal(0). □

**Theorem 3.2 (No Additive Inverse for Φ).**
*There is no x ∈ Transreal such that Φ + x = 0.*

*Proof.* Since Φ + x = Φ for all x, and Φ ≠ ofReal(0). □

**Theorem 3.3 (Distributivity Failure).**
*There exist a, b, c ∈ Transreal such that a·(b+c) ≠ a·b + a·c.*

*Proof.* Take a = +∞, b = ofReal(1), c = −∞.
- LHS: +∞ · (1 + (−∞)) = +∞ · (−∞) = −∞
- RHS: +∞ · 1 + (+∞) · (−∞) = +∞ + (−∞) = Φ
- −∞ ≠ Φ. □

### 3.2 Nullity Absorption

**Theorem 3.4 (Universal Absorption).**
*For all x ∈ Transreal: Φ + x = Φ, x + Φ = Φ, Φ · x = Φ, x · Φ = Φ, Φ / x = Φ, x / Φ = Φ, and −Φ = Φ.*

**Theorem 3.5 (Uniqueness of Absorber).**
*If e ∈ Transreal satisfies e + x = e for all x, then e = Φ.*

*Proof.* For e = ofReal(r): e + (+∞) = +∞ ≠ ofReal(r). For e = +∞: e + (−∞) = Φ ≠ +∞. For e = −∞: e + (+∞) = Φ ≠ −∞. Only e = Φ is consistent. □

### 3.3 Preserved Algebraic Structure

**Theorem 3.6 (Global Additive Commutativity and Associativity).**
*For all a, b, c ∈ Transreal: a + b = b + a and (a + b) + c = a + (b + c).*

*Proof of associativity.* By case analysis on all 4³ = 64 combinations. The key observation is that whenever an intermediate sum produces Φ, both sides of the associativity equation eventually reach Φ due to absorption. For the pure finite case, real number associativity applies. □

**Theorem 3.7 (Global Multiplicative Commutativity and Associativity).**
*For all a, b, c ∈ Transreal: a · b = b · a and (a · b) · c = a · (b · c).*

*Proof sketch for associativity.* The 64-case analysis is more involved because multiplication's sign-dependence creates branching. The critical lemma is that for finite elements r, s: sign(r·s) is determined by sign(r) and sign(s), so the composition of sign-dependent infinite multiplications is consistent. □

**Theorem 3.8 (Global Negation Homomorphism).**
*For all a, b ∈ Transreal: −(a + b) = (−a) + (−b).*

This is surprising because the analogous property for multiplication over addition (distributivity) fails.

### 3.4 The Real Embedding

**Theorem 3.9 (Faithful Embedding).**
*The map ofReal : ℝ → Transreal is injective and preserves both addition and multiplication.*

**Theorem 3.10 (Determinate Non-Closure).**
*The set of determinate elements is not closed under addition: +∞ and −∞ are determinate, but +∞ + (−∞) = Φ is not.*

### 3.5 Total Division Properties

**Theorem 3.11 (Division Totality and Defining Equations).**
- 0/0 = Φ (the defining equation of transreal arithmetic)
- r/0 = +∞ for r > 0
- r/0 = −∞ for r < 0
- +∞ · 0 = Φ
- +∞/+∞ = Φ

### 3.6 Double Negation and Involution

**Theorem 3.12.** *For all x ∈ Transreal: −(−x) = x.*

## 4. Algebraic Classification

The transreal numbers form what we call a **commutative monoid with universal absorption**: a structure (T, +, ·, 0, 1, Φ, −) where:

1. (T, +, 0) is a commutative monoid
2. (T, ·, 1) is a commutative monoid (restricted to non-nullity elements with appropriate absorption)
3. Φ is a universal absorber for +, ·, and /
4. Negation is an involution and additive homomorphism
5. Division is a total operation

This structure is strictly between a wheel and a ring:
- **Stronger than a wheel**: Full associativity of both operations (wheels may only have weak associativity)
- **Weaker than a ring**: No additive inverses for non-real elements, no distributive law

## 5. Analysis Consequences

### 5.1 What Survives

- Arithmetic on finite elements is fully preserved (the field structure of ℝ embeds faithfully)
- Limit-free algebraic identities that don't involve distribution survive
- The sign structure of products is preserved

### 5.2 What Collapses

- Any theorem relying on the existence of additive inverses for all elements
- Any theorem requiring distributivity (e.g., expanding products of sums)
- The total order (nullity is incomparable with all other elements)
- Algebraic cancellation: (a·b)/b ≠ a in general (e.g., (∞·0)/0 = Φ/0 = Φ ≠ ∞)

## 6. Connection to IEEE 754

The IEEE 754 floating-point standard's treatment of NaN (Not a Number) mirrors several properties of nullity:
- NaN propagates through operations (absorption)
- NaN ≠ NaN (though our formalization uses Φ = Φ)
- 0/0 = NaN, ∞ − ∞ = NaN, ∞/∞ = NaN

The transreal formalization provides a rigorous algebraic foundation for these conventions, proving that the absorption behavior is not just convenient but algebraically necessary (Theorem 3.5).

## 7. Future Directions

1. **Transreal topology**: Can a meaningful topology be defined on the transreal numbers? The natural candidate is the one-point compactification of the extended reals, with nullity as an isolated point.

2. **Transreal analysis**: Define limits, continuity, and differentiation in the transreal setting. Which theorems of real analysis have transreal analogs?

3. **Categorical structure**: Characterize transreal numbers as a universal object in some appropriate category of algebraic structures with total division.

4. **Computational applications**: Use the algebraic properties to verify IEEE 754-compliant arithmetic at the level of mathematical proofs.

## References

[1] J.A.D. Anderson, "Representing geometrical knowledge," *Phil. Trans. R. Soc. B*, vol. 352, pp. 1129–1139, 1997.

[2] J.A.D. Anderson, N. Völker, A.A. Adams, "Perspex machine VIII: Axioms of transreal arithmetic," in *Vision Geometry XV*, Proc. SPIE 6499, 2007.

[3] A. Setzer, "Wheels — On Division by Zero," *Mathematical Structures in Computer Science*, vol. 7, pp. 143–179, 1997.

[4] IEEE Standard for Floating-Point Arithmetic, IEEE Std 754-2019.
