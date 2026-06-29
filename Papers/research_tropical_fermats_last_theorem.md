# Tropical Fermat's Last Theorem: Complete Characterization of Solutions and a Kapranov-Type Theorem for Tropical Fermat Curves

## Abstract

We present a complete formal characterization of solutions to the tropical Fermat equation x^n ⊕ y^n = z^n in the min-plus tropical semiring over the integers. We prove that for all n ≥ 1, this equation reduces to x ⊕ y = z, establishing that every tropical Fermat curve is the standard tropical line. We formalize tropical polynomials in two variables, define tropical varieties as loci of multiple minimum achievement, and prove a Kapranov-type theorem showing that the tropical Fermat variety decomposes into exactly three rays satisfying the tropical balancing condition. All results have been machine-verified in the Lean 4 theorem prover using the Mathlib library.

**Keywords:** tropical geometry, tropical semiring, Fermat's Last Theorem, tropical varieties, Kapranov theorem, min-plus algebra, formal verification

## 1. Introduction

### 1.1 Background

The tropical semiring (ℤ, min, +) replaces classical addition with the minimum operation and classical multiplication with addition. This deceptively simple change of arithmetic has profound geometric consequences, giving rise to tropical geometry—a piecewise-linear shadow of classical algebraic geometry that preserves combinatorial structure while simplifying algebraic complexity.

Fermat's Last Theorem, proved by Wiles (1995) building on work of Frey, Serre, Ribet, and Taylor, states that x^n + y^n = z^n has no solutions in positive integers for n ≥ 3. The tropical analogue of this equation was studied informally by several authors (see Itenberg, Mikhalkin, and Shustin; Maclagan and Sturmfels), but a complete formal treatment has been lacking.

### 1.2 Contributions

This paper provides:

1. **Tropical power characterization** (Theorem 3.1): A proof that a^n = trop(n · untrop(a)) in any tropical semiring.

2. **Fermat reduction theorem** (Theorem 3.2): For n ≥ 1, the equation x^n ⊕ y^n = z^n is equivalent to x ⊕ y = z.

3. **Complete solution characterization** (Theorem 3.3): The solution set is {(x,y,z) : untrop(z) = min(untrop(x), untrop(y))}.

4. **Degree independence** (Theorem 3.4): All tropical Fermat curves are equal to the tropical line.

5. **Kapranov-type theorem** (Theorem 4.1): The tropical Fermat variety equals the standard tropical line variety, decomposing into three balanced rays.

6. **Balancing condition** (Theorem 4.2): The weighted direction vectors at the vertex sum to zero.

7. **Infinite solutions** (Theorem 3.5): Every tropical Fermat curve has infinitely many points.

## 2. Preliminaries

### 2.1 The Tropical Semiring

We work with the Mathlib formalization of the tropical semiring `Tropical ℤ`, where:

- **Tropical addition**: x ⊕ y = trop(min(untrop(x), untrop(y)))
- **Tropical multiplication**: x ⊗ y = trop(untrop(x) + untrop(y))
- **Tropical multiplicative identity**: 1 = trop(0)

The functions `trop : ℤ → Tropical ℤ` and `untrop : Tropical ℤ → ℤ` are mutually inverse bijections.

### 2.2 Tropical Polynomials

We define a concrete representation of tropical polynomials in two variables.

**Definition 2.1** (Tropical Monomial). A tropical monomial is a triple (c, i, j) ∈ ℤ × ℕ × ℕ representing the function (x, y) ↦ c + ix + jy (in classical arithmetic), corresponding to the tropical expression c ⊗ x^⊗i ⊗ y^⊗j.

**Definition 2.2** (Tropical Polynomial). A tropical polynomial is a finite list of tropical monomials. Its evaluation at (x, y) is the minimum (tropical sum) of all monomial evaluations.

**Definition 2.3** (Tropical Variety). The tropical variety V(f) of a tropical polynomial f is the set of points where the minimum is achieved by at least two distinct monomials.

### 2.3 The Fermat Polynomial

**Definition 2.4**. The tropical Fermat polynomial of degree n is:
```
fermatPoly(n) = [⟨0, n, 0⟩, ⟨0, 0, n⟩, ⟨0, 0, 0⟩]
```
representing min(nx, ny, 0) in classical coordinates.

## 3. Main Results: Tropical Fermat Equations

### Theorem 3.1 (Tropical Power)

For any a ∈ Tropical ℤ and n ∈ ℕ:
```
a^n = trop(n · untrop(a))
```

*Proof.* By induction on n. The base case a^0 = 1 = trop(0) = trop(0 · untrop(a)) is immediate. For the inductive step, a^(n+1) = a^n ⊗ a = trop(n · untrop(a)) ⊗ a = trop(n · untrop(a) + untrop(a)) = trop((n+1) · untrop(a)). □

### Theorem 3.2 (Fermat Reduction)

For any x, y, z ∈ Tropical ℤ and n ≥ 1:
```
x^n ⊕ y^n = z^n  ⟺  x ⊕ y = z
```

*Proof.* By Theorem 3.1, x^n ⊕ y^n = trop(min(n · untrop(x), n · untrop(y))) and z^n = trop(n · untrop(z)). The equation becomes min(n · untrop(x), n · untrop(y)) = n · untrop(z). Since n ≥ 1, the left side equals n · min(untrop(x), untrop(y)) (by monotonicity of scalar multiplication on ℤ), giving n · min(untrop(x), untrop(y)) = n · untrop(z). Since n ≥ 1 (hence n ≠ 0), we can cancel to obtain min(untrop(x), untrop(y)) = untrop(z), which is precisely x ⊕ y = z. □

### Theorem 3.3 (Solution Characterization)

For n ≥ 1, a triple (x, y, z) satisfies x^n ⊕ y^n = z^n if and only if untrop(z) = min(untrop(x), untrop(y)).

*Proof.* Immediate from Theorem 3.2 and the definition of tropical addition. □

### Theorem 3.4 (Degree Independence)

For any n, m ≥ 1:
```
TropicalFermatCurve(n) = TropicalFermatCurve(m) = TropicalLine
```

where TropicalFermatCurve(n) = {(a,b) ∈ ℤ² : trop(a)^n ⊕ trop(b)^n = 1^n} and TropicalLine = {(a,b) : min(a,b) = 0}.

*Proof.* Both sides equal TropicalLine by Theorem 3.2 applied with z = 1 = trop(0). □

### Theorem 3.5 (Infinite Solutions)

For any n ≥ 1, TropicalFermatCurve(n) is an infinite set.

*Proof.* By Theorem 3.4, TropicalFermatCurve(n) = TropicalLine. The map k ↦ (k, 0) for k ∈ ℕ is injective and maps into TropicalLine (since min(k, 0) = 0 for all k ≥ 0), giving infinitely many solutions. □

## 4. Tropical Varieties and the Kapranov Theorem

### 4.1 The Standard Tropical Line Variety

**Definition 4.1**. The standard tropical line variety is:
```
StandardTropicalLineVariety = {(x,y) : (x = y ∧ x ≤ 0) ∨ (x = 0 ∧ y ≥ 0) ∨ (y = 0 ∧ x ≥ 0)}
```

This decomposes into three rays:
- **Ray 1** (positive x-axis): {(t, 0) : t ≥ 0} with primitive direction (1, 0)
- **Ray 2** (positive y-axis): {(0, t) : t ≥ 0} with primitive direction (0, 1)
- **Ray 3** (negative diagonal): {(t, t) : t ≤ 0} with primitive direction (-1, -1)

### Theorem 4.1 (Kapranov-Type Theorem for Tropical Fermat Curves)

For any n ≥ 1:
```
TropicalFermatVariety(n) = StandardTropicalLineVariety
```

*Proof.* A point (x, y) lies in TropicalFermatVariety(n) iff min(nx, ny, 0) is achieved by at least two of the three terms {nx, ny, 0}.

**Forward direction.** If the minimum is achieved twice:
- nx = ny and both ≤ 0: Since n ≥ 1, x = y and x ≤ 0 (diagonal ray).
- nx = 0 and 0 ≤ ny: Since n ≥ 1, x = 0 and y ≥ 0 (y-axis ray).
- ny = 0 and 0 ≤ nx: Since n ≥ 1, y = 0 and x ≥ 0 (x-axis ray).

**Backward direction.** For each ray, exhibit two monomials achieving the minimum:
- Diagonal ray: monomials 0 and 1 both evaluate to nx = ny ≤ 0.
- y-axis ray: monomials 0 and 2 both evaluate to 0 (since nx = 0).
- x-axis ray: monomials 1 and 2 both evaluate to 0 (since ny = 0). □

### Theorem 4.2 (Balancing Condition)

The tropical Fermat curve of degree n satisfies the balancing condition: the weighted sum of primitive direction vectors at the origin is zero.

```
n · (-1, -1) + n · (1, 0) + n · (0, 1) = (0, 0)
```

*Proof.* Direct computation. □

### 4.2 Geometric Interpretation

The tropical Fermat variety is a tropical curve of degree n with:
- **One vertex** at the origin (0, 0)
- **Three unbounded rays** with weights n
- **Genus 0** (the graph is a tree)
- **No bounded edges**

The genus is always 0 regardless of n, in sharp contrast with the classical genus formula g = (n-1)(n-2)/2 for smooth plane curves.

## 5. Algorithms

### Algorithm 5.1: Tropical Fermat Solution Test

```
Input: x, y, z ∈ ℤ, n ∈ ℕ with n ≥ 1
Output: Whether (trop(x), trop(y), trop(z)) satisfies x^n ⊕ y^n = z^n

1. Return (min(x, y) == z)
```

Time complexity: O(1). By Theorem 3.3, the test is independent of n.

### Algorithm 5.2: Tropical Variety Membership

```
Input: (x, y) ∈ ℤ², tropical polynomial f = [(c₁,i₁,j₁), ..., (cₖ,iₖ,jₖ)]
Output: Whether (x,y) ∈ V(f)

1. Compute vals[t] = cₜ + iₜx + jₜy for each t
2. Compute m = min(vals)
3. Count how many vals[t] equal m
4. Return (count ≥ 2)
```

Time complexity: O(k) where k is the number of monomials.

### Algorithm 5.3: Tropical Fermat Variety Ray Classification

```
Input: (x, y) ∈ StandardTropicalLineVariety
Output: Which ray the point lies on

1. If x = y and x ≤ 0: return "diagonal ray"
2. If x = 0 and y ≥ 0: return "y-axis ray"  
3. If y = 0 and x ≥ 0: return "x-axis ray"
4. return "not on variety"
```

## 6. Discussion

### 6.1 Classical vs. Tropical Comparison

| Property | Classical Fermat (n ≥ 3) | Tropical Fermat (n ≥ 1) |
|----------|-------------------------|------------------------|
| Solutions in positive integers | None (Wiles, 1995) | Infinitely many |
| Proof difficulty | Extremely hard | Elementary |
| Genus of curve | (n-1)(n-2)/2 | 0 |
| Dependence on n | Critical | None (degree-independent) |
| Curve structure | Smooth algebraic | Piecewise linear (3 rays) |

### 6.2 Connection to Kapranov's Theorem

Kapranov's theorem (2000) states that for a polynomial f over a non-Archimedean valued field K, the tropical variety of the tropicalization of f equals the closure of the coordinate-wise valuation image of the zero set V(f) ⊂ (K*)^n. Our Theorem 4.1 is a concrete verification of this principle for the Fermat polynomial family.

### 6.3 The Balancing Condition and Realizability

The fact that tropical Fermat curves satisfy the balancing condition (Theorem 4.2) ensures they are *realizable*—each is the tropicalization of an actual algebraic Fermat curve over a non-Archimedean field. This connects our combinatorial results back to classical algebraic geometry.

### 6.4 Degree Independence as a Tropical Phenomenon

The degree independence of tropical Fermat curves (Theorem 3.4) is a manifestation of the general principle that tropicalization collapses information. The map from algebraic curves to their tropical shadows is many-to-one, and the Fermat family provides a particularly clean example: infinitely many algebraically distinct curves (parameterized by degree) map to the same tropical object.

## 7. Future Work

Several directions for future investigation emerge:

1. **Higher-dimensional Fermat hypersurfaces.** Does the tropical Fermat hypersurface min(nx₁, ..., nxₖ, 0) have analogous degree-independence? The combinatorial structure should be related to the permutohedron.

2. **Tropical Fermat over non-integer tropical semirings.** Working over Tropical ℝ or Tropical ℚ may reveal continuous phenomena not visible over ℤ.

3. **Enumerative geometry.** Count tropical Fermat curves through specified point configurations, extending Mikhalkin's correspondence theorem.

4. **Connection to classical Fermat.** Can tropical degeneration techniques provide alternative approaches to results about classical Fermat curves?

5. **Supertropical extensions.** In the supertropical semiring, where a ⊕ a = aᵍ (a "ghost"), does degree-independence persist?

## 8. References

1. I. Simon, "Recognizable sets with multiplicities in the tropical semiring," *MFCS 1988*, LNCS 324, pp. 107–120, 1988.

2. M. Kapranov, "Amoebas over non-Archimedean fields," preprint, 2000.

3. G. Mikhalkin, "Enumerative tropical algebraic geometry in ℝ²," *J. Amer. Math. Soc.*, vol. 18, pp. 313–377, 2005.

4. D. Maclagan and B. Sturmfels, *Introduction to Tropical Geometry*, Graduate Studies in Mathematics, vol. 161, AMS, 2015.

5. I. Itenberg, G. Mikhalkin, and E. Shustin, *Tropical Algebraic Geometry*, Oberwolfach Seminars, vol. 35, Birkhäuser, 2007.

6. A. Wiles, "Modular elliptic curves and Fermat's Last Theorem," *Ann. of Math.*, vol. 141, pp. 443–551, 1995.

7. J.-P. Serre, *A Course in Arithmetic*, Graduate Texts in Mathematics, vol. 7, Springer, 1973.

## Appendix: Formal Verification Details

All theorems in this paper have been formally verified in Lean 4 (version 4.28.0) using the Mathlib library. The formalization consists of approximately 300 lines of Lean code with zero unproved (`sorry`) statements. The axioms used are limited to the standard foundational axioms: `propext`, `Classical.choice`, and `Quot.sound`.

The source file `Tropical/FermatCurve.lean` contains the complete formalization and can be type-checked independently.
