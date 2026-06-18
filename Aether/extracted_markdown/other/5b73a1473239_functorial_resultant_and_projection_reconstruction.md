# Functorial Resultant and Projection Reconstruction for Idempotent Semiring Congruences

## Abstract

We develop a formal framework for eliminating variables from semiring congruences on multivariate polynomial rings, analogous to classical resultant elimination but adapted to the setting of commutative idempotent semirings (tropical algebras). Our construction centers on three key innovations: (1) a coefficient extraction operator `coeffNone` that decomposes multivariate polynomials relative to a distinguished variable using Mathlib's `optionEquivLeft` equivalence, (2) an elimination congruence `eliminationCong` defined as the pullback of a semiring congruence along the canonical embedding, and (3) a cross-multiplication theorem that derives new congruence relations from existing ones. All definitions and structural theorems are machine-verified in Lean 4 with Mathlib.

## 1. Introduction

Classical elimination theory provides algorithms for removing variables from systems of polynomial equations. The resultant of two univariate polynomials f(x) and g(x) is a polynomial expression in the coefficients that vanishes precisely when f and g share a common root. This theory relies fundamentally on the ring structure of the coefficient domain — specifically, on the availability of subtraction and determinants.

In tropical and idempotent algebra, the situation is fundamentally different. A **commutative idempotent semiring** satisfies `a + a = a` for all elements (addition is idempotent), with no additive inverses. Examples include:

- The **tropical semiring** (ℝ ∪ {-∞}, max, +) used in optimization and algebraic geometry
- The **Boolean semiring** ({0, 1}, ∨, ∧) used in logic and formal verification
- **Max-plus algebras** used in scheduling and discrete event systems

In these structures, the classical resultant formula (a determinant involving subtraction) is unavailable. Nevertheless, the *notion* of eliminating a variable from a congruence is well-defined: given a semiring congruence C on polynomials in variables (x, y₁, ..., yₙ), the **elimination congruence** consists of all relations between polynomials in (y₁, ..., yₙ) that are implied by C.

This paper formalizes this elimination construction and proves its basic properties in Lean 4, creating infrastructure for a congruence-based elimination theory in idempotent algebra.

## 2. Mathematical Framework

### 2.1 Semiring Congruences

A **semiring congruence** on a semiring A is an equivalence relation ∼ on A that is compatible with both addition and multiplication:
- a ∼ b and c ∼ d implies a + c ∼ b + d
- a ∼ b and c ∼ d implies a · c ∼ b · d

Unlike ideals (which are defined via subtraction: a - b ∈ I), semiring congruences are the natural "quotient" structure in the absence of negation.

### 2.2 The Option Decomposition

We work with polynomial variables indexed by `Option σ`, where:
- `none` is the distinguished variable to be eliminated
- `some i` for `i : σ` are the retained variables

The key mathematical tool is the algebra equivalence (from Mathlib):

```
optionEquivLeft : MvPolynomial (Option σ) S ≃ₐ[S] Polynomial (MvPolynomial σ S)
```

This views a multivariate polynomial in `Option σ` variables as a univariate polynomial in the `none` variable, with coefficients in the retained-variable ring.

### 2.3 Coefficient Extraction

We define:

```
coeffNone n f = Polynomial.coeff (optionEquivLeft S σ f) n
```

This extracts the n-th coefficient of the `none` variable from f, returning a polynomial in the retained variables. Key properties:

1. **Additivity**: `coeffNone n (f + g) = coeffNone n f + coeffNone n g`
2. **Lifting**: `coeffNone 0 (liftSome r) = r` and `coeffNone (n+1) (liftSome r) = 0`
3. **Power formula**: `coeffNone n (X_none^k * liftSome a) = if n = k then a else 0`

### 2.4 Linear Expansion

For polynomials of degree ≤ 1 in the eliminated variable:

**Theorem (Linear Expansion).** If `noneDegree f ≤ 1`, then:
```
f = liftSome (coeffNone 0 f) + liftSome (coeffNone 1 f) * X_none
```

This decomposition is the foundation for analyzing linear congruence generators.

## 3. The Elimination Congruence

### 3.1 Definition

Given a semiring congruence C on `MvPolynomial (Option σ) S`, the **elimination congruence** is:

```
eliminationCong C = { (f, g) : R × R | C (liftSome f) (liftSome g) }
```

where `liftSome = rename Option.some` is the canonical embedding of the retained-variable ring into the full ring.

**Theorem.** `eliminationCong C` is a semiring congruence on `MvPolynomial σ S`.

*Proof.* Since `liftSome` is a ring homomorphism:
- Reflexivity, symmetry, transitivity follow from C being an equivalence relation.
- Addition compatibility: If C(liftSome a, liftSome b) and C(liftSome c, liftSome d), then C(liftSome a + liftSome c, liftSome b + liftSome d), and since liftSome preserves addition, C(liftSome(a+c), liftSome(b+d)).
- Multiplication: analogous.

### 3.2 Basic Properties

- **Characterization**: `(eliminationCong C).r f g ↔ C.r (liftSome f) (liftSome g)`
- **Monotonicity**: `C ≤ D → eliminationCong C ≤ eliminationCong D`
- **Injectivity of liftSome**: `liftSome f = liftSome g → f = g` (since `rename` along an injective function is injective)

## 4. Cross-Multiplication Theorem

The core algebraic operation for building elimination relations:

**Theorem (Cross-Multiplication).** If C(p.lhs, p.rhs) and C(q.lhs, q.rhs), then:
```
C(p.lhs * q.rhs, p.rhs * q.lhs)
```

*Proof.* By transitivity of congruence:
1. C(p.lhs * q.rhs, p.rhs * q.rhs) — from C(p.lhs, p.rhs) and reflexivity of q.rhs
2. C(p.rhs * q.rhs, p.rhs * q.lhs) — from reflexivity of p.rhs and C(q.rhs, q.lhs)
3. C(p.lhs * q.rhs, p.rhs * q.lhs) — by transitivity

This is the semiring congruence analogue of the classical identity:
```
f(x)g'(x) - f'(x)g(x) ∈ (f - f', g - g')
```
but expressed without subtraction.

## 5. The Evaluation Map

We also formalize evaluation of the eliminated variable:

```
evalNone c f = aeval (fun v => match v with | none => C c | some i => X i) f
```

**Theorem.** `evalNone c (liftSome r) = r` for all c and r.

This shows that `evalNone` is a left inverse of `liftSome`, establishing that `liftSome` is injective and that the eliminated variable is genuinely "extra."

## 6. The Linrear Resultant Pair

We define the **linear resultant pair** of two congruence generators:

```
linResultantPair p q =
  (coeffNone 1 p.lhs * coeffNone 0 q.lhs + coeffNone 0 p.rhs * coeffNone 1 q.rhs,
   coeffNone 0 p.lhs * coeffNone 1 q.lhs + coeffNone 1 p.rhs * coeffNone 0 q.rhs)
```

This formula is motivated by the 2×2 Sylvester matrix permanent:
```
perm | a₁  a₀ |  =  a₁·d₀ + a₀·d₁
     | c₁  c₀ |
```
adapted to the congruence setting by using both the lhs and rhs coefficients.

**Open Conjecture.** Whether this pair lies in the elimination congruence for linear generators over general idempotent semirings remains open. Our analysis shows that the formula may require additional structural hypotheses or a fundamentally different approach. The difficulty is that, unlike classical algebra, semiring congruences do not support "coefficient extraction from relations" — one cannot isolate the constant part of a congruence relation from its variable-dependent part without subtraction.

## 7. Discussion: A Scientific American Perspective

Imagine you're planning a construction project with multiple workers, machines, and tasks. Each task has constraints: "the foundation must be poured before framing starts," "painting takes at least 3 days," "the inspector must arrive after both plumbing and electrical are done." These constraints involve timing variables connected by max (the latest prerequisite determines the start) and plus (durations add up) — exactly the operations of the tropical semiring.

Now suppose you want to understand just the relationship between the project start date and completion date, eliminating all the intermediate timing variables. In classical algebra, this is variable elimination — you compute resultants or Gröbner bases to project out the internal variables. But tropical arithmetic has no subtraction: you can't "cancel" a shared term from both sides of an equation.

This paper formalizes a new approach: instead of equations, we work with **congruences** — equivalence relations that respect the algebra. The "elimination congruence" captures exactly which relationships between the remaining variables are forced by the full system. We prove that this is always a well-defined semiring congruence, and we build tools for computing with it.

The cross-multiplication theorem is our main algebraic tool: from two congruence relations, it produces a new one that mixes their information. Think of it as a "tropical Cramer's rule" — combining two constraints to derive a third, without needing subtraction.

Our work is fully machine-verified in Lean 4, using the Mathlib mathematical library. This means every step has been checked by computer, achieving a level of certainty impossible with traditional mathematical proofs.

## 8. Connections to Existing Work

- **Classical elimination theory**: Our `eliminationCong` is the congruence analogue of the eliminated ideal in classical commutative algebra.
- **Tropical geometry**: The elimination congruence captures the image of a tropical variety under coordinate projection.
- **Universal algebra**: The construction `eliminationCong = comap liftSome` is an instance of the universal algebraic construction of pulling back congruences along homomorphisms.
- **Max-plus linear algebra**: For linear congruence generators, our framework specializes to projection in max-plus linear systems.

## 9. Formal Verification Summary

All of the following are machine-verified in Lean 4 with Mathlib:

| Result | Status |
|--------|--------|
| `coeffNone` definition and additive structure | ✓ Proved |
| `coeffNone_X_none_pow_mul_liftSome` | ✓ Proved |
| `linear_expand_of_noneDegree_le_one` | ✓ Proved |
| `eliminationCong` is a `SemiringCong` | ✓ Proved |
| `mem_eliminationCong_iff` | ✓ Proved |
| `eliminationCong_mono` | ✓ Proved |
| `liftSome_injective` | ✓ Proved |
| `cross_mul_mem` | ✓ Proved |
| `evalNone_liftSome` | ✓ Proved |
| `linResultantPair_mem_elimination` | Open conjecture |

## References

1. Maclagan, D., Sturmfels, B. *Introduction to Tropical Geometry*. AMS, 2015.
2. Golan, J.S. *Semirings and their Applications*. Springer, 1999.
3. Baccelli, F., et al. *Synchronization and Linearity*. Wiley, 1992.
4. The Mathlib Community. *Mathlib: The Lean Mathematical Library*. 2024.
