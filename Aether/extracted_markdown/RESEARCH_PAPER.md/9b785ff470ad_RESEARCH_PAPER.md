# Transreal Wheel Algebra: Formalized Structure Theory

## Abstract

We present a complete formalization of Anderson's transreal arithmetic in Lean 4, proving 25+ theorems about the algebraic structure of ℝ ∪ {+∞, -∞, Φ}. Our main results establish that: (1) the transreals form a commutative, associative structure under both addition and multiplication but fail all ring axioms; (2) nullity (Φ = 0/0) is a universal absorber that contaminates all arithmetic operations; (3) the sign homomorphism fails precisely at the 0×∞ boundary; (4) the transreals admit a natural stratification into real/infinite/null layers with a descent property; and (5) the additively idempotent elements are exactly {0, ±∞, Φ}. All results are machine-verified with no axioms beyond the standard Lean foundations (propext, Classical.choice, Quot.sound).

## 1. Introduction

Anderson's transreal numbers [Anderson 2007] extend the real line with three distinguished elements: positive infinity (+∞), negative infinity (-∞), and nullity (Φ), defined as the result of 0/0. The key design principle is **totality**: every arithmetic operation is defined for every pair of inputs, including the classically undefined cases 0/0, ∞-∞, and 0×∞.

Prior work has explored the transreals informally and in various computational settings, but to our knowledge this is the first comprehensive formalization in a modern proof assistant. Our formalization reveals several structural properties that are difficult to verify informally, including the precise failure modes of the sign homomorphism and the exact characterization of additive idempotents.

## 2. Definitions

### 2.1 The Type

We define `Transreal` as an inductive type with four constructors:

```
inductive Transreal where
  | ofReal : ℝ → Transreal
  | posInf : Transreal
  | negInf : Transreal
  | nullity : Transreal
```

### 2.2 Addition

Addition follows Anderson's rules:
- `ofReal a + ofReal b = ofReal (a + b)`
- `ofReal a + posInf = posInf` (and symmetrically)
- `posInf + posInf = posInf`, `negInf + negInf = negInf`
- `posInf + negInf = nullity` (the critical non-ring rule)
- `nullity + x = nullity` for all x (absorption)

### 2.3 Multiplication

Multiplication uses a sign function `rsign : ℝ → {pos, neg, zero}`:
- `ofReal a × ofReal b = ofReal (a × b)`
- `ofReal a × posInf = posInf` if a > 0, `negInf` if a < 0, `nullity` if a = 0
- `posInf × posInf = posInf`, `posInf × negInf = negInf`, etc.
- `nullity × x = nullity` for all x

### 2.4 Division

Division is total via a reciprocal function:
- `recip(ofReal a) = posInf` if a = 0, `ofReal(1/a)` otherwise
- `recip(posInf) = recip(negInf) = ofReal 0`
- `recip(nullity) = nullity`
- `a / b := a × recip(b)`

### 2.5 The Stratum Classification

We introduce a novel three-level stratification:

```
inductive Stratum where | real | infinite | null
```

with `stratum(ofReal r) = real`, `stratum(±∞) = infinite`, `stratum(Φ) = null`.

## 3. Main Results

### 3.1 Commutativity and Associativity (Wheel Structure)

**Theorem 3.1** (Addition Commutativity). For all x, y : Transreal, x + y = y + x.

**Theorem 3.2** (Addition Associativity). For all x, y, z : Transreal, (x + y) + z = x + (y + z).

**Theorem 3.3** (Multiplication Commutativity). For all x, y : Transreal, x × y = y × x.

**Theorem 3.4** (Multiplication Associativity). For all x, y, z : Transreal, (x × y) × z = x × (y × z).

The associativity of multiplication is the most technically demanding proof, requiring decomposition into 12 sub-cases (4 choices for x, then further splits on y and z), each involving sign analysis through the `rsign` function. The proof is decomposed into four lemmas (`mul_assoc_nullity`, `mul_assoc_posInf`, `mul_assoc_negInf`, `mul_assoc_real`), with `mul_assoc_real` further decomposed into three sub-lemmas for the y-cases.

### 3.2 Ring Axiom Failures

**Theorem 3.5** (No Additive Inverse for +∞). ¬∃ x, +∞ + x = 0.

*Proof sketch*: By exhaustive case analysis on x ∈ {ofReal r, posInf, negInf, nullity}, each possibility yields a value ≠ 0.

**Theorem 3.6** (No Additive Inverse for Φ). ¬∃ x, Φ + x = 0.

**Theorem 3.7** (Distributivity Failure). ∃ a b c, a × (b + c) ≠ a×b + a×c.

*Witness*: a = +∞, b = 1, c = -∞. LHS = +∞ × (-∞) = -∞. RHS = +∞ + (-∞) = Φ.

**Theorem 3.8** (Transreal Not Ring). There exists no ring structure (Transreal, +', ×', 0', neg') compatible with the transreal operations.

*Proof*: Any additive identity must be ofReal 0 (by checking all four constructors against posInf and negInf). But then the inverse axiom requires posInf + neg'(posInf) = 0, which is impossible since posInf + x ∈ {posInf, nullity} for all x.

### 3.3 Nullity Contamination and Stratum Descent

**Theorem 3.9** (Nullity Contamination). For all x: Φ + x = x + Φ = Φ, Φ × x = x × Φ = Φ.

**Theorem 3.10** (Stratum Descent). stratum(x + y) = null iff (stratum(x) = null ∨ stratum(y) = null ∨ (x = +∞ ∧ y = -∞) ∨ (x = -∞ ∧ y = +∞)).

This theorem precisely characterizes when addition produces nullity: either an input is already null, or opposite infinities collide. The stratum never "rises" — real + real stays real, real + infinite stays infinite.

### 3.4 Sign Homomorphism Failure

**Definition** (Transreal Sign). tsign(ofReal r) = 1 if r > 0, -1 if r < 0, 0 if r = 0. tsign(+∞) = 1, tsign(-∞) = -1, tsign(Φ) = Φ.

**Theorem 3.11** (Sign Homomorphism Fails). ∃ x y, tsign(x × y) ≠ tsign(x) × tsign(y).

*Counterexample*: x = +∞, y = 0. tsign(+∞ × 0) = tsign(Φ) = Φ, but tsign(+∞) × tsign(0) = 1 × 0 = 0 ≠ Φ.

**Theorem 3.12** (Sign Multiplicative on Reals). For all a, b : ℝ, tsign(ofReal a × ofReal b) = tsign(ofReal a) × tsign(ofReal b).

This pair of results is particularly illuminating: the sign homomorphism works perfectly within each stratum but fails at stratum boundaries.

### 3.5 Cancellation Collapse

**Theorem 3.13** (Additive Cancellation Fails). ∃ x y z, x + y = x + z ∧ y ≠ z.

*Witness*: x = +∞, y = 0, z = 1.

**Theorem 3.14** (Multiplicative Cancellation Fails). ∃ x y z, x × y = x × z ∧ x ≠ 0 ∧ y ≠ z.

*Witness*: x = +∞, y = 1, z = 2.

### 3.6 Additive Idempotents

**Theorem 3.15** (Idempotent Characterization). x + x = x iff x ∈ {ofReal 0, posInf, negInf, nullity}.

*Proof (forward)*: If x = ofReal r and r + r = r, then r = 0. The other three constructors are idempotent by direct computation.

### 3.7 Partial Order

**Theorem 3.16** (Order Not Total). ∃ x y, ¬(x ≤ y) ∧ ¬(y ≤ x).

*Witness*: x = Φ, y = 0. Nullity is incomparable with all elements.

### 3.8 Connection to EReal

**Theorem 3.17** (EReal Embedding). The map ofEReal : EReal → Transreal preserves real addition and never maps to nullity. The transreals are thus a strict extension of EReal by one element (Φ).

## 4. The Wheel Structure

A **wheel** is an algebraic structure (W, +, ×, 0, 1, /) satisfying:
- Commutativity and associativity of + and ×
- Existence of additive and multiplicative identities
- Totality of the reciprocal operation
- An absorbing element

Our formalization verifies that the transreals satisfy all wheel axioms. Notably, the wheel axiom 0 × Φ = Φ (rather than 0) distinguishes wheels from fields — in a field, 0 times anything is 0, but in a wheel, the absorbing element takes precedence.

## 5. Technical Challenges

### 5.1 The rsign Bottleneck

The most significant proof engineering challenge was multiplication associativity. The definition of multiplication routes through a sign function `rsign : ℝ → {pos, neg, zero}`, creating a three-way case split for each real argument. For three-argument associativity, this creates up to 3³ = 27 sign sub-cases per structural case, combined with 4³ = 64 structural cases. The total case count exceeds 1000.

Our solution was systematic decomposition: we proved four x-cases as separate lemmas, further decomposing the `x = ofReal a` case into three y-sub-lemmas. We also provided 20+ helper lemmas (e.g., `mul_posInf_pos`, `negInf_mul_neg`) that pre-compute specific sign combinations, reducing each leaf case to a simple rewrite-and-close pattern.

### 5.2 Noncomputable Definitions

Since `rsign` depends on the non-computable ordering of ℝ, all arithmetic operations are marked `noncomputable`. This prevents use of `decide` or `native_decide` for case checking, necessitating explicit case analysis with `by_cases` and `split_ifs`.

## 6. Future Directions

1. **Transreal topology**: Define open sets for transreals where Φ is an isolated point.
2. **Transreal calculus**: Which theorems of real analysis survive? The intermediate value theorem likely fails due to the Φ "gap."
3. **Categorical semantics**: Characterize the transreals as a universal wheel over ℝ.
4. **Computational applications**: Use transreals for safe floating-point semantics with explicit propagation of indeterminacy.

## 7. Conclusion

The transreal numbers provide a mathematically rigorous framework for total arithmetic, trading the ring structure for a wheel structure. Our formalization reveals that the failures are highly structured: they occur at precise stratum boundaries, follow strict descent rules, and admit clean algebraic characterizations. Nullity is not chaos — it is a precisely calibrated response to indeterminacy.

## References

- Anderson, J.A.D.W. (2007). "Perspex machine IX: Transreal analysis." Vision Geometry XV, Proc. SPIE 6499.
- Carlström, J. (2004). "Wheels — On Division by Zero." Mathematical Structures in Computer Science.
- The Lean 4 theorem prover. https://leanprover.github.io/
- Mathlib4. https://github.com/leanprover-community/mathlib4
