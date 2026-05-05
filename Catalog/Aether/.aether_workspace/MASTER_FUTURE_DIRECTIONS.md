# MASTER FUTURE DIRECTIONS — Accumulated Research Wisdom

*Last updated: 2026-05-05 06:04*

## Key Open Problem

The central open question is whether the `linResultantPair` formula
(or any fixed polynomial-time computable formula) can produce
generators of the elimination congruence from generators of the
original congruence, for arbitrary idempotent semirings.

Our analysis suggests this may be impossible in full generality:
unlike classical ideal elimination (which uses subtraction/determinants),
semiring congruences cannot "cancel" the eliminated variable from
relations. The correct framework may require either:

1. **Evaluation-based witnesses**: Using ring endomorphisms (evaluation
   maps) to project congruences, rather than algebraic elimination.

2. **Lattice-theoretic methods**: Exploiting the lattice structure of
   congruences over idempotent semirings (which form a distributive
   lattice) to perform elimination via lattice-theoretic operations.

3. **Restricted classes**: Proving elimination for specific classes of
   idempotent semirings (totally ordered, Boolean, etc.) where
   additional structural properties enable cancellation-like operations.

## 1. Quadratic Resultant Pairs via 3×3 Permanent Identities

**Target theorem:**
```lean
theorem quadResultantPair_mem_elimination
    (C : SemiringCong (PolyFull S σ))
    (p q : PolyPair S σ)
    (hp : C.r p.lhs p.rhs) (hq : C.r q.lhs q.rhs)
    (hpl : noneDegree p.lhs ≤ 2) (hpr : noneDegree p.rhs ≤ 2)
    (hql : noneDegree q.lhs ≤ 2) (hqr : noneDegree q.rhs ≤ 2) :
    ∀ r ∈ quadResultantFamily p q,
      (eliminationCong C).r r.1 r.2
```

The permanent of a 3×3 matrix over a commutative semiring is always
well-defined (no subtraction needed). Define the Sylvester matrix of
two quadratic polynomial pairs and extract elimination witnesses from
its permanent expansion. Each monomial in the permanent corresponds to
a balanced coefficient matching that eliminates X_none.

## 5. Complexity Bounds for Projected Generator Size

**Target theorem:**
```lean
theorem elimination_generator_bound
    [Fintype σ]
    (C : SemiringCong (PolyFull S σ))
    (T : Finset (PolyPair S σ))
    (hgen : C = generatedBy T)
    (N : ℕ) (hdeg : ∀ p ∈ T, noneDegree p.lhs ≤ N ∧ noneDegree p.rhs ≤ N) :
    ∃ U : Finset (PolyRet S σ × PolyRet S σ),
      U.card ≤ T.card ^ 2 * (N + 1) ^ 2 ∧
      eliminationCong C = generatedBy' U
```

Provide explicit bounds on the size of the projected generating set.
For linear generators (N=1), the cross-multiplication produces at most
O(|T|²) pairs. For higher degrees, the permanent-based construction
gives polynomial bounds in both |T| and N.

## 4. Tropical Nullstellensatz Certificates

**Target theorem:**
```lean
theorem tropical_nullstellensatz_certificate
    (C : SemiringCong (MvPolynomial σ (TropicalSemiring ℝ)))
    (f g : MvPolynomial σ (TropicalSemiring ℝ))
    (h : ∀ v : σ → TropicalSemiring ℝ, eval v f = eval v g) :
    ∃ N : ℕ, ∃ deriv : DerivationChain C f g, deriv.length ≤ N
```

This would connect congruence elimination to tropical variety
certification: if two polynomials agree on all tropical points,
there should be a bounded derivation in the congruence. The
elimination machinery provides the inductive step (eliminate one
variable at a time, using coefficient extraction to reduce dimension).

## 3. Multivariable Iterated Elimination

**Target theorem:**
```lean
theorem iterated_elimination_comm
    {σ : Type*} (i j : σ) (hij : i ≠ j)
    (C : SemiringCong (MvPolynomial σ S)) :
    eliminateVar i (eliminateVar j C) = eliminateVar j (eliminateVar i C)
```

Show that eliminating variables in different orders yields the same
result (order-independence). This is the congruence analogue of the
classical elimination theory theorem that iterated resultants commute.
In the bounded-degree regime (all generators linear or quadratic),
this should be provable using the coefficient extraction infrastructure.

## 2. Functoriality of Elimination Under Semiring Morphisms

**Target theorem:**
```lean
theorem eliminationCong_map
    (φ : S →+* T)
    (C : SemiringCong (PolyFull S σ))
    (f g : PolyRet S σ)
    (h : (eliminationCong C).r f g) :
    (eliminationCong (C.map (MvPolynomial.map φ))).r
      (MvPolynomial.map φ f) (MvPolynomial.map φ g)
```

This would show that elimination is natural with respect to semiring
base change. Combined with the coefficient extraction machinery, this
creates a functorial framework for congruence elimination.

## Overview

This document outlines concrete next theorems and research directions
building on the formalized infrastructure in `Catalog/Algebra/CongruenceElimination.lean`.

# Future Directions for Congruence Elimination Theory