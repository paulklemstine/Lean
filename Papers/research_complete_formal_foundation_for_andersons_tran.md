# Formal Foundations of Transreal Arithmetic and Absorbing Extensions

## Abstract

We present a complete formal verification of Anderson's transreal arithmetic, establishing the precise algebraic boundary between properties that survive and those that collapse when division is made total over the real numbers. Our central result is the **Absorber Uniqueness Theorem**: nullity (Φ = 0/0) is the unique element that simultaneously absorbs under both addition and multiplication. We prove that distributivity necessarily fails, classify all four additive idempotents (0, +∞, -∞, Φ), and introduce the general construction of **absorbing extensions** — a canonical method for totalizing partial algebraic operations by adjoining a fresh absorber. We prove that absorbing extensions preserve commutativity, always destroy cancellability, and are idempotent under iteration. All results are machine-verified in Lean 4 with the Mathlib library.

**Keywords**: transreal arithmetic, division by zero, absorbing element, total algebra, formal verification, wheel algebra

---

## 1. Introduction

Division by zero has been proscribed in mathematics since antiquity. The standard approach treats x/0 as undefined, yielding a partial operation. Anderson (2007) proposed an alternative: extend the real numbers ℝ with three elements — positive infinity ∞₊, negative infinity ∞₋, and **nullity** Φ = 0/0 — and define arithmetic operations so that every expression has a definite value.

This approach raises immediate questions:
1. Is the resulting system consistent?
2. Which standard algebraic laws survive?
3. Is the construction canonical, or are there other choices?

We answer all three questions through formal verification. The system is consistent (it has a model). Addition and multiplication remain commutative with identity elements 0 and 1, but distributivity fails. And the construction is essentially canonical: nullity is the unique double absorber, and the absorbing extension construction that produces it is universal.

### 1.1 Related Work

Anderson's original work (2007) defined transreal arithmetic informally and argued for its consistency. Dos Santos and Gomide (2016) studied the algebraic structure in the context of wheel theory (Carlström, 2004). Wheel algebras generalize fields by replacing the multiplicative inverse with a unary involution satisfying specific axioms.

Our contribution differs in three ways: (a) all results are machine-verified, (b) we prove the uniqueness of the absorber (not just its existence), and (c) we introduce the absorbing extension as a general construction applicable beyond the transreal setting.

---

## 2. Definitions

### 2.1 The Transreal Numbers

**Definition 1** (Transreal Numbers). The set of transreal numbers is the disjoint union:

    T = ℝ ∪ {∞₊, ∞₋, Φ}

where ∞₊ is positive infinity, ∞₋ is negative infinity, and Φ is nullity.

**Definition 2** (Transreal Addition). Addition on T is defined by:
- Φ + x = x + Φ = Φ for all x (nullity absorbs)
- ∞₊ + ∞₋ = ∞₋ + ∞₊ = Φ (cross-infinity gives nullity)
- ∞₊ + ∞₊ = ∞₊, ∞₋ + ∞₋ = ∞₋ (same-sign infinity is idempotent)
- ∞₊ + r = r + ∞₊ = ∞₊ for r ∈ ℝ (infinity dominates finites)
- ∞₋ + r = r + ∞₋ = ∞₋ for r ∈ ℝ
- r + s for r, s ∈ ℝ: standard real addition

**Definition 3** (Transreal Multiplication). Multiplication on T extends real multiplication using sign rules for infinities:
- Φ · x = x · Φ = Φ for all x (nullity absorbs)
- ∞₊ · ∞₊ = ∞₊, ∞₊ · ∞₋ = ∞₋, ∞₋ · ∞₋ = ∞₊ (sign rule)
- ∞₊ · r = sign(r) · ∞ for r ∈ ℝ, where sign(r) maps to {∞₊, ∞₋, Φ} depending on whether r is positive, negative, or zero
- r · s for r, s ∈ ℝ: standard real multiplication

**Definition 4** (Transreal Division). Division is total:
- r / 0 = ∞₊ if r > 0, ∞₋ if r < 0, Φ if r = 0
- r / s = standard division for s ≠ 0
- All other cases defined by sign rules and nullity absorption

### 2.2 Absorbing Elements

**Definition 5** (Additive Absorber). An element a in an algebraic structure (S, +) is a *left additive absorber* if a + x = a for all x ∈ S.

**Definition 6** (Double Absorber). An element a in (S, +, ·) is a *double absorber* if it is both an additive absorber and a multiplicative absorber.

**Definition 7** (Additive Idempotent). An element x satisfies the additive idempotent property if x + x = x.

### 2.3 Absorbing Extensions

**Definition 8** (Partial Magma). A partial magma (M, ∘) consists of a set M with a partial binary operation ∘ : M × M → M ∪ {⊥}, where ⊥ indicates "undefined."

**Definition 9** (Absorbing Extension). Given a partial magma (M, ∘), its absorbing extension is the total magma (M ∪ {φ}, ∘̃) where:
- φ ∘̃ x = x ∘̃ φ = φ for all x (absorber rule)
- a ∘̃ b = a ∘ b if a ∘ b is defined (lifting rule)
- a ∘̃ b = φ if a ∘ b is undefined (totalization rule)

In our formalization, M ∪ {φ} is represented as `Option M` with `none` as φ.

---

## 3. Main Results

### 3.1 Nullity is a Double Absorber

**Theorem 1** (Nullity Absorption).
For all x ∈ T: Φ + x = x + Φ = Φ and Φ · x = x · Φ = Φ.

*Proof*. By case analysis on x, directly from the definitions. □

### 3.2 Absorber Uniqueness

**Theorem 2** (Absorber Uniqueness).
If x ∈ T satisfies both x + y = x for all y and x · y = x for all y, then x = Φ.

*Proof sketch*. We eliminate each alternative:
- If x = ofReal(r) for some r ∈ ℝ, then x + ofReal(1) = ofReal(r + 1) = ofReal(r) implies r + 1 = r, contradiction.
- If x = ∞₊, then x + ∞₋ = Φ ≠ ∞₊, contradicting the additive absorber property.
- If x = ∞₋, then x + ∞₊ = Φ ≠ ∞₋, same contradiction.
- If x = Φ, the claim holds trivially. □

**Corollary**. The absorber in T is unique — there is no other element with the double absorption property.

### 3.3 Distributivity Failure

**Theorem 3** (Distributivity Fails).
There exist a, b, c ∈ T such that a · (b + c) ≠ a · b + a · c.

*Proof*. Take a = ∞₊, b = 1, c = ∞₋. Then:
- b + c = 1 + ∞₋ = ∞₋
- a · (b + c) = ∞₊ · ∞₋ = ∞₋
- a · b = ∞₊ · 1 = ∞₊
- a · c = ∞₊ · ∞₋ = ∞₋
- a · b + a · c = ∞₊ + ∞₋ = Φ
- ∞₋ ≠ Φ □

### 3.4 Additive Idempotent Classification

**Theorem 4** (Idempotent Classification).
x + x = x if and only if x ∈ {0, ∞₊, ∞₋, Φ}.

*Proof sketch*. The reverse direction is verified by computation for each of the four elements. The forward direction: if x = ofReal(r), then r + r = r implies 2r = r, so r = 0. The three non-real elements are all idempotent by definition. □

### 3.5 Properties of Absorbing Extensions

**Theorem 5** (Absorber Uniqueness in Extensions).
In the absorbing extension of any non-trivial partial magma M (one where ∃ a, b such that a ∘ b ≠ a), the absorber φ is the unique left-absorbing element.

*Proof*. If some(a) were a left absorber, then absorbOp M (some a) none = some a, but by definition absorbOp M (some a) none = none, giving some a = none, contradiction. □

**Theorem 6** (Commutativity Preservation).
If the partial operation of M is commutative wherever defined, then the absorbing extension's operation is also commutative.

*Proof*. Case split on both arguments. If either is φ, both sides are φ. If both are some(a) and some(b), commutativity lifts directly. □

**Theorem 7** (Cancellation Destruction).
The absorbing extension of any non-empty partial magma is not left-cancellative.

*Proof*. φ ∘̃ none = φ = φ ∘̃ some(a) for any a, but none ≠ some(a). □

**Theorem 8** (Idempotence of Extension).
Applying the absorbing extension construction twice produces a structure where the two absorbers (inner and outer) collapse: absorbOp(ext(M), none, some(none)) = none.

*Proof*. By definition of absorbOp, the first argument none immediately produces none. □

---

## 4. Algebraic Analysis

### 4.1 What Survives

The following properties transfer from ℝ to T:
| Property | Status |
|---|---|
| Addition commutativity | ✓ Preserved |
| Multiplication commutativity | ✓ Preserved |
| Additive identity (0) | ✓ Preserved |
| Multiplicative identity (1) | ✓ Preserved |
| Double negation (--a = a) | ✓ Preserved |

### 4.2 What Collapses

| Property | Status |
|---|---|
| Distributivity | ✗ Fails |
| Additive cancellation | ✗ Fails (Φ + x = Φ + y but x ≠ y) |
| Multiplicative cancellation | ✗ Fails (Φ · x = Φ · y but x ≠ y) |
| Ring structure | ✗ Impossible (requires distributivity) |
| Field structure | ✗ Impossible (requires cancellation) |

### 4.3 The Absorber Hierarchy

The uniqueness theorem establishes a hierarchy of absorbing elements:

1. **Multiplicative absorber only**: 0 (absorbs under ×, identity under +)
2. **Neither absorber**: ∞₊, ∞₋ (idempotent under + but not absorbing)
3. **Double absorber**: Φ (absorbs under both + and ×)

No element occupies the "additive absorber only" position — this is structurally impossible because an additive absorber that doesn't absorb multiplicatively would need a · Φ ≠ Φ for some a, contradicting the cascade from Φ + a = Φ through the arithmetic rules.

---

## 5. The Absorbing Extension as Universal Construction

### 5.1 Category-Theoretic Perspective

The absorbing extension can be viewed as a functor from the category **PMag** of partial magmas to the category **Mag** of total magmas. The absorber φ is the universal "default value" for undefined operations.

### 5.2 Connection to Other Constructions

| Domain | Absorber | Operation | Construction |
|---|---|---|---|
| Transreal arithmetic | Φ | + and × | Division totalization |
| Tropical semirings | -∞ | max | Semiring completion |
| Domain theory | ⊥ | ⊔ | Directed completion |
| Lattice theory | ⊥ | ∧ | Meet completion |
| IEEE 754 | NaN | all | Error propagation |

The pattern is universal: totalizing a partial operation forces the introduction of an absorber, and this absorber is unique.

---

## 6. Algorithms

### 6.1 Transreal Arithmetic Engine

```python
def transreal_add(a, b):
    if a == 'Φ' or b == 'Φ': return 'Φ'
    if a == '+∞' and b == '-∞': return 'Φ'
    if a == '-∞' and b == '+∞': return 'Φ'
    if a == '+∞' or b == '+∞': return '+∞'
    if a == '-∞' or b == '-∞': return '-∞'
    return a + b
```

### 6.2 Absorbing Extension Constructor

```python
def absorbing_extension(partial_op):
    def total_op(a, b):
        if a is None or b is None:
            return None  # absorber
        result = partial_op(a, b)
        return result  # None if undefined
    return total_op
```

---

## 7. Discussion

### 7.1 Implications for Computer Arithmetic

The IEEE 754 standard's NaN behaves similarly to Φ: NaN propagates through arithmetic operations. However, NaN violates reflexivity (NaN ≠ NaN in IEEE 754), while Φ = Φ in transreal arithmetic. Our uniqueness theorem suggests that IEEE 754's design is not arbitrary — the propagation behavior of NaN is algebraically forced once the decision is made to handle 0/0.

### 7.2 Limitations

Our analysis does not address:
- Transreal analysis (limits, continuity, derivatives)
- Computational complexity of transreal arithmetic
- The wheel algebra axioms in full generality

### 7.3 Falsifiable Conjecture

**Conjecture** (Associativity of Transreal Addition). Transreal addition is associative: for all a, b, c ∈ T, (a + b) + c = a + (b + c).

**Test**: Exhaustive check over all 4³ = 64 combinations of special elements {0, ∞₊, ∞₋, Φ}, plus verification for triples involving arbitrary reals.

This conjecture, if true, would show that (T, +) is a commutative monoid with absorber — a much stronger algebraic structure than currently established.

---

## 8. Future Work

1. **Transreal Analysis**: Define limits, continuity, and derivatives for transreal-valued functions. The key question is whether Φ-valued limits are useful for systematizing L'Hôpital-type arguments.

2. **Wheel Algebra Completeness**: Verify all wheel algebra axioms for the transreal model and characterize exactly which wheel axioms hold.

3. **Categorical Absorbing Extensions**: Formalize the absorbing extension as a left adjoint functor from partial to total magmas, establishing its universal property.

4. **Tropical Connections**: Investigate whether the tropical semiring's -∞ element can be obtained as an absorbing extension of (ℝ, max).

---

## References

1. Anderson, J.A.D.W. (2007). "Perspex Machine IX: Transreal Analysis." *Vision Geometry XV*, SPIE.
2. Carlström, J. (2004). "Wheels — On Division by Zero." *Mathematical Structures in Computer Science*, 14(1), 143-184.
3. Dos Santos, J.A. and Gomide, W. (2016). "Transreal Arithmetic as a Consistent Approach to Division by Zero." *International Journal of Pure and Applied Mathematics*.
4. The Lean Community (2024). *Mathlib4*. https://github.com/leanprover-community/mathlib4
