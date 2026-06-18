# Future Directions: Egyptian Fraction Decompositions and the Erdős–Straus Conjecture

This document identifies five specific, testable scientific hypotheses emerging from our formal study of the Erdős–Straus conjecture. Each is falsifiable with a clear computational or formal test.

---

## Conjecture 1: Ordered Small First-Denominator Bound

**Statement:** For every integer n ≥ 2, there exists an ordered witness (x ≤ y ≤ z) for the Erdős–Straus equation 4/n = 1/x + 1/y + 1/z with x ≤ n.

**Formalization:**
```
∀ n : ℕ, 2 ≤ n → ∃ x y z : ℕ, OrderedESWitness n x y z ∧ x ≤ n
```

**Test:** Run the verified search algorithm `searchESVerified` with bound B = n for all n ≤ 10^6. A single failure disproves the conjecture. Success for all tested values provides strong evidence.

**Impact:** If true, this would dramatically reduce the search space for the remaining n ≡ 1 (mod 4) cases, as one would only need to check O(n²) candidate pairs instead of an unbounded search.

---

## Conjecture 2: Polynomial Template Completeness for n ≡ 1 (mod 4)

**Statement:** There exists a finite family of at most 20 polynomial templates (x(k), y(k), z(k)) in the parameter k such that for every n ≡ 1 (mod 4), at least one template produces a valid decomposition when k is chosen appropriately from the divisor or residue structure of n.

**Test:** Enumerate polynomial templates arising from the identity
  4/(4k+1) - 1/a = remainder
for various choices of a as a function of k. For each template, check which values of n ≡ 1 (mod 4) up to 10^6 it covers. Track coverage as templates are added. If fewer than 20 templates achieve 100% coverage up to 10^6, the conjecture is supported.

**Impact:** A finite template library would reduce the Erdős–Straus conjecture to a finite verification problem in formal algebra, potentially allowing a complete machine-checked proof via certified template matching.

---

## Conjecture 3: Search-Space Sparsity

**Statement:** For a fixed n, the number of ordered pairs (x, y) with 1 ≤ x ≤ y ≤ B that yield a valid integer z in the Erdős–Straus equation is O(B^ε) for any ε > 0 as B → ∞.

In other words, valid lattice points on the cubic surface 4xyz = n(xy + xz + yz) are extremely sparse among all candidate pairs.

**Test:** For several fixed values of n (e.g., n = 5, 13, 17, 29, 37), compute the count of valid (x, y) pairs for B = 10^2, 10^3, 10^4, 10^5. Plot log(count) vs log(B). If the slope approaches 0, the conjecture is supported. A slope bounded away from 0 would refute sub-polynomial growth.

**Impact:** Sparsity would explain why naive enumeration is computationally efficient despite searching a seemingly large space, and would connect the problem to questions about rational points on algebraic varieties.

---

## Conjecture 4: Divisor-Scaled Coverage Density

**Statement:** Define the "coverage set" C as the union of all multiples of integers covered by the even and mod-4≡3 families. Then the natural density of C among integers ≡ 1 (mod 4) exceeds 90%.

More precisely, among n ≡ 1 (mod 4) with n ≤ N, the fraction that can be written as n = k·m where m is even or m ≡ 3 (mod 4) exceeds 0.9 for all sufficiently large N.

**Test:** For N = 10^5, enumerate all n ≡ 1 (mod 4) up to N. For each, check whether any divisor m of n satisfies m even or m ≡ 3 (mod 4), with m ≥ 2 and k = n/m ≥ 1. Compute the fraction covered.

**Impact:** If the density is indeed very high, this would show that the scaling principle alone, combined with two simple seed families, resolves almost all cases. The remaining "hard core" of integers resisting all transfer methods would be identified, focusing future effort.

---

## Conjecture 5: Cubic Surface Geometry — Convex Hull Dimension

**Statement:** For every n ≥ 2 admitting at least 3 non-collinear ordered witnesses, the convex hull of the set {(x, y, z) : OrderedESWitness n x y z, x ≤ n²} has full dimension (dimension 2, as a subset of the surface) in ℝ³.

**Test:** For n = 5, 7, 11, 13, enumerate all ordered witnesses with x, y, z ≤ n². Compute the convex hull of these integer points and check its dimension. If for any n the witnesses are collinear (dimension ≤ 1), the conjecture is refuted.

**Impact:** Full-dimensional convex hulls would confirm that the solution surface has rich geometric structure, supporting approaches to the conjecture based on the geometry of numbers (e.g., Minkowski-type arguments for lattice points in convex bodies on cubic surfaces).

---

## Methodology Note

All conjectures above are designed to interface directly with the verified search algorithm `searchESVerified` defined in our formalization. Computational tests should use the verified Python implementation in `demo.py` and `algorithms.py` for initial exploration, with formal verification of any positive results achievable by extending the Lean framework.
