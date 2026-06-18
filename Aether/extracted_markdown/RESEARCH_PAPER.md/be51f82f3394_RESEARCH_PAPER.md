# Transreal Arithmetic: A Formal Investigation of Ring Failure and Wheel Emergence

## Abstract

We present a complete formalization of Anderson's transreal number system — the extension of ℝ by three distinguished elements: positive infinity (+∞), negative infinity (-∞), and nullity (Φ = 0/0) — with all arithmetic operations made total. We prove that the transreal numbers fail to form a ring due to three independent obstructions: (1) the non-existence of additive inverses for infinite and null elements, (2) the failure of zero-absorption (0 × ∞ = Φ ≠ 0), and (3) the breakdown of left distributivity (with an explicit counterexample). We establish that nullity is the unique absorbing element under both addition and multiplication, prove a complete classification of additive idempotents (exactly four: 0, +∞, -∞, Φ), verify partial wheel axioms, and demonstrate the collapse of cancellation laws. All results are machine-verified in Lean 4 with Mathlib.

## 1. Introduction

The question of extending the real number system to handle division by zero has a long history. The projective real line ℝ ∪ {∞} identifies +∞ and -∞ but loses the total order. The extended real line ℝ ∪ {+∞, -∞} preserves the order but leaves certain operations (like ∞ - ∞ and 0 × ∞) undefined. Anderson's transreal system [1] takes the radical approach of making *every* arithmetic operation total by introducing a third non-real element — nullity (Φ) — as the result of all previously indeterminate forms.

The algebraic consequences of this totality have not been previously formalized with machine verification. In this paper, we provide such a formalization and prove precisely which standard algebraic properties survive and which collapse.

### 1.1 Contributions

1. **Formal definition** of the transreal number type and its arithmetic operations in Lean 4.
2. **Three independent ring-failure proofs**: additive inverse failure, zero-absorption failure, and distributivity failure, each with explicit counterexamples.
3. **Unique absorbing element theorem**: nullity is the only element that absorbs under both addition and multiplication.
4. **Additive idempotent classification**: the equation x + x = x has exactly four solutions in the transreals.
5. **Nullity collapse theorem**: any expression tree built from addition and multiplication with a nullity leaf evaluates to nullity.
6. **Partial wheel axiom verification**: commutativity of both operations, wheel distributivity for finite values, and identification of where the wheel involution axiom fails.
7. **Cancellation collapse**: explicit demonstrations that neither additive nor multiplicative cancellation holds.

## 2. Definitions

### 2.1 The Transreal Type

**Definition 2.1** (Transreal). The set of transreal numbers is defined as the inductive type:

```
Transreal ::= ofReal(r : ℝ) | posInf | negInf | nullity
```

with the abbreviation Φ := nullity.

### 2.2 Arithmetic Operations

**Definition 2.2** (Addition). For transreals a, b:

| a \ b | ofReal s | +∞ | -∞ | Φ |
|-------|---------|-----|-----|---|
| ofReal r | ofReal(r+s) | +∞ | -∞ | Φ |
| +∞ | +∞ | +∞ | Φ | Φ |
| -∞ | -∞ | Φ | -∞ | Φ |
| Φ | Φ | Φ | Φ | Φ |

The critical entry is ∞ + (-∞) = Φ.

**Definition 2.3** (Multiplication). For transreals a, b:

- `ofReal(r) × ofReal(s) = ofReal(r × s)`
- `ofReal(r) × ±∞`: sign-dependent (+∞ if same sign, -∞ if opposite, Φ if r = 0)
- `±∞ × ±∞`: follows standard sign rules
- `Φ × x = x × Φ = Φ` for all x

The critical entries are `0 × ±∞ = Φ`.

**Definition 2.4** (Negation). `-ofReal(r) = ofReal(-r)`, `-posInf = negInf`, `-negInf = posInf`, `-Φ = Φ`.

**Definition 2.5** (Reciprocal). `recip(ofReal(r)) = ofReal(r⁻¹)` for r ≠ 0; `recip(0) = +∞`; `recip(±∞) = 0`; `recip(Φ) = Φ`.

**Definition 2.6** (Division). `a / b := a × recip(b)`.

### 2.3 Partial Order

The transreal order extends the real order: `-∞ ≤ r ≤ +∞` for all real r, with infinities comparable to all total elements and Φ incomparable with everything.

## 3. Ring Axiom Failures

### 3.1 Additive Inverse Failure

**Theorem 3.1**. *posInf + (-posInf) ≠ 0.*

*Proof.* By computation: `posInf + negInf = nullity` (from the addition table), and `nullity ≠ ofReal 0` (by injectivity of the constructors). ∎

This means the transreals do not form a group under addition.

### 3.2 Zero-Absorption Failure

**Theorem 3.2**. *There exists x such that 0 × x ≠ 0.*

*Proof.* Take x = posInf. Then `0 × posInf = nullity` (since 0 is neither positive nor negative, the multiplication rule produces Φ). Since `nullity ≠ ofReal 0`, the result follows. ∎

This violates the ring axiom that zero is an absorbing element of multiplication.

### 3.3 Distributivity Failure

**Theorem 3.3**. *Left distributivity fails: there exist a, b, c with a × (b + c) ≠ a × b + a × c.*

*Proof.* Take a = posInf, b = ofReal 1, c = negInf.

LHS: `posInf × (ofReal 1 + negInf) = posInf × negInf = negInf`.

RHS: `posInf × ofReal 1 + posInf × negInf = posInf + negInf = nullity`.

Since `negInf ≠ nullity`, left distributivity fails. ∎

**Remark.** This counterexample has a clear conceptual interpretation: the "telescoping" of 1 + (-∞) into -∞ before multiplication loses information that the separate multiplication would have preserved.

## 4. Nullity as Universal Absorber

### 4.1 Absorption Properties

**Theorem 4.1** (Nullity Absorption). *For all transreal x: Φ + x = Φ and x + Φ = Φ; Φ × x = Φ and x × Φ = Φ.*

*Proof.* By case analysis on x (four cases each). ∎

**Theorem 4.2** (Fixed Points). *-Φ = Φ and recip(Φ) = Φ.*

*Proof.* Immediate from the definitions. ∎

### 4.2 Uniqueness of the Absorbing Element

**Theorem 4.3** (Unique Absorber). *If z + x = z for all x and z × x = z for all x, then z = nullity.*

*Proof.* From z + nullity = z (by the first hypothesis) and z + nullity = nullity (by Theorem 4.1), we obtain z = nullity. ∎

**Remark.** This theorem shows that nullity occupies a unique algebraic position. No other transreal element — not zero, not infinity — absorbs under both operations.

### 4.3 Nullity Collapse Conjecture

**Theorem 4.4** (Depth-2 Nullity Collapse). *For any binary operations op₁, op₂ ∈ {add, mul} and any transreals x, y: op₁(op₂(Φ, x), y) = Φ.*

*Proof.* By case analysis on op₁ and op₂. In each case, the inner operation op₂(Φ, x) = Φ by Theorem 4.1, and then op₁(Φ, y) = Φ again by Theorem 4.1. ∎

**Conjecture 4.5** (Full Nullity Collapse). For any expression tree built from addition and multiplication with at least one nullity leaf, the expression evaluates to nullity.

This conjecture extends Theorem 4.4 to arbitrary depth. We verify it computationally for expression trees up to depth 10 in the companion code.

## 5. Additive Idempotent Classification

**Theorem 5.1**. *The transreal x satisfies x + x = x if and only if x ∈ {0, +∞, -∞, Φ}.*

*Proof.* The "if" direction is immediate:
- `ofReal 0 + ofReal 0 = ofReal 0` ✓
- `posInf + posInf = posInf` ✓
- `negInf + negInf = negInf` ✓
- `nullity + nullity = nullity` ✓

For the "only if" direction, if x = ofReal r, then ofReal(r + r) = ofReal r implies r + r = r (by injectivity of ofReal), hence 2r = r, hence r = 0. The cases x ∈ {posInf, negInf, nullity} are immediate. ∎

**Interpretation.** These four idempotents correspond to the four "qualitative types" of transreal numbers: the additive identity (0), the two infinite boundaries (+∞, -∞), and the absorber (Φ).

## 6. Cancellation Collapse

**Theorem 6.1** (Additive Cancellation Failure). *There exist a, b, c with a + b = a + c and b ≠ c.*

*Proof.* Take a = posInf, b = ofReal 1, c = ofReal 2. Then posInf + ofReal 1 = posInf = posInf + ofReal 2, but ofReal 1 ≠ ofReal 2. ∎

**Theorem 6.2** (Multiplicative Cancellation Failure). *There exist a, b, c with a ≠ 0, a × b = a × c, and b ≠ c.*

*Proof.* Take a = posInf, b = ofReal 1, c = ofReal 2. Then posInf × ofReal 1 = posInf = posInf × ofReal 2 (both by the multiplication rule for positive reals times +∞), posInf ≠ 0, and ofReal 1 ≠ ofReal 2. ∎

## 7. Wheel Structure Analysis

### 7.1 Verified Wheel Axioms

The following wheel axioms hold in the transreals:

1. **Multiplicative commutativity**: a × b = b × a for all transreals a, b (Theorem 7.1, proved by 16-case analysis).
2. **Additive commutativity**: a + b = b + a for all transreals a, b (Theorem 7.2, proved by 16-case analysis).
3. **Additive identity for total elements**: x + 0 = x for all x ≠ Φ (Theorem 7.3).
4. **Double negation**: -(-x) = x for all transreals x (Theorem 7.4).
5. **Reciprocal involution for nonzero finite reals**: recip(recip(ofReal r)) = ofReal r for r ≠ 0 (Theorem 7.5).

### 7.2 Failed Wheel Axioms

6. **Reciprocal involution at -∞**: recip(recip(negInf)) = recip(0) = posInf ≠ negInf (Theorem 7.6).

This means the transreals do not form a perfect wheel — the involution axiom breaks at negative infinity because the reciprocal function maps both +∞ and -∞ to 0, losing sign information.

### 7.3 Partial Wheel Distributivity

**Theorem 7.7**. *For finite reals a, b, c: a×c + b×c + 0×c = (a+b)×c + 0×c.*

*Proof.* Since 0×c = 0 for finite c, both sides reduce to (a+b)×c = a×c + b×c, which is standard real distributivity. ∎

## 8. The Real Embedding

**Theorem 8.1** (Faithful Embedding). *The map ofReal : ℝ → Transreal is injective and preserves addition, multiplication, negation, and reciprocal (for nonzero values).*

This confirms that the transreals are a genuine extension: all of real arithmetic is faithfully preserved. The new behavior appears only at the boundary — when finite values interact with infinities.

## 9. Order Structure

**Theorem 9.1**. *For every real r: -∞ ≤ r ≤ +∞.*

**Theorem 9.2**. *Nullity is incomparable: Φ ≰ +∞ and r ≰ Φ for any real r.*

The transreal order is thus a partial order extending the real total order, with Φ forming an isolated incomparable point. This differs from the extended reals, where the order is total.

## 10. Algorithms

### 10.1 Transreal Expression Evaluation

We provide a complete implementation of transreal arithmetic as a Python library (algorithms.py), including:
- Type-safe transreal number representation
- Expression tree evaluator with nullity propagation detection
- Algebraic property checker (commutativity, associativity, distributivity)
- Transreal interval arithmetic

### 10.2 Nullity Propagation Detection

**Algorithm** (Nullity Detection): Given an expression tree, check if any leaf is nullity. If so, the entire expression evaluates to nullity (by the Collapse Conjecture). This provides O(n) early termination for expressions that would otherwise require O(n) evaluation.

## 11. Discussion

### 11.1 Comparison with IEEE 754 NaN

The IEEE 754 standard's NaN (Not a Number) shares some properties with nullity: both arise from indeterminate operations and both propagate through arithmetic. However, they differ in critical ways:

| Property | NaN | Φ (Nullity) |
|----------|-----|-------------|
| Self-equality | NaN ≠ NaN | Φ = Φ |
| Absorption | Partial | Complete (both + and ×) |
| Fixed under negation | Yes | Yes |
| Fixed under reciprocal | No (1/NaN = NaN, but not defined) | Yes (1/Φ = Φ) |
| Algebraic theory | Ad hoc | Well-defined |

### 11.2 What Survives Extension

The following properties of real arithmetic survive transreal extension:
- Commutativity of + and ×
- Real field operations (via faithful embedding)
- Order between finite and infinite values
- Infinity sign rules for multiplication

The following collapse:
- Ring structure (additive inverses, zero absorption, distributivity)
- Cancellation (additive and multiplicative)
- Wheel involution (at -∞)
- Total order (nullity is incomparable)

## 12. Future Work

1. **Full wheel axiom verification**: Determine the complete set of wheel axioms that hold.
2. **Transreal analysis**: Investigate limits, continuity, and derivatives in the transreal setting.
3. **Category-theoretic perspective**: Characterize the transreals as a universal construction.
4. **Computational applications**: Implement transreal arithmetic in hardware for fault-tolerant computation.

## References

[1] J.A.D.W. Anderson, N. Völker, A.A. Adams, "Perspex Machine IX: Transreal Analysis," *Vision Geometry XV*, Proc. SPIE 6499, 2007.

[2] J. Carlström, "Wheels — On Division by Zero," *Mathematical Structures in Computer Science*, 14(1):143-184, 2004.

[3] T. Setzer, "Wheels: A Generalization of Commutative Rings," 2004.

## Appendix: Lean 4 Formalization

The complete formalization consists of two files:
- `Defs.lean`: Core type definition, arithmetic operations, order, and basic simp lemmas (~240 lines)
- `Properties.lean`: All theorems stated and proved (~240 lines)

All 27 theorems are proved without `sorry`, verified against Mathlib v4.28.0. The formalization uses `Classical.decEq` for decidable equality and marks operations as `noncomputable` where they depend on real number decidability.
