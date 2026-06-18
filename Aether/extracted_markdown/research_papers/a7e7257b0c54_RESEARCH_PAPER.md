# The Tropical Newton Polygon Bridge: A Rigorous Functor from Algebraic Polynomial Evaluation to Tropical Piecewise-Linear Geometry

## Abstract

We construct a rigorous bridge between classical polynomial arithmetic over commutative semirings equipped with tropical valuations and the piecewise-linear world of tropical polynomial evaluation. The central result is the **Ultrametric Evaluation Theorem**: for a tropical valuation v on a commutative semiring R, the valuation of a polynomial evaluation v(∑ aᵢrⁱ) is bounded below by the tropical polynomial evaluation min_i(v(aᵢ) + i·v(r)). This theorem, combined with the multiplicative-to-additive property of valuations, yields a functorial pipeline from algebraic coefficient data to tropical certificates. We introduce three novel structures — `TropPolyData` (tropical polynomial data), `NewtonSlopeSpectrum` (slope multisets of Newton polygons), and `termsCompete` (tropical breakpoint detection) — and prove their key properties. All results are formalized in Lean 4 with the Mathlib library, providing machine-verified correctness.

**Keywords**: tropical geometry, Newton polygon, p-adic valuation, ultrametric inequality, tropical polynomial, formal verification

---

## 1. Introduction

The Newton polygon of a polynomial f(x) = ∑ aᵢxⁱ over a valued field (K, v) is a classical tool connecting the arithmetic of coefficients to the geometry of roots. Given a non-archimedean valuation v: K → ℝ ∪ {∞}, one plots the points (i, v(aᵢ)) and takes their lower convex hull. The slopes of the resulting polygon determine the valuations of the roots of f, counted with multiplicity — a result going back to Newton and systematized by Puiseux, Eisenstein, and Hensel.

In parallel, tropical geometry has emerged as a powerful framework where algebraic varieties are replaced by piecewise-linear objects. The tropicalization of a polynomial f = ∑ aᵢxⁱ under a valuation v is the function trop(f)(y) = min_i(v(aᵢ) + iy), which is a piecewise-linear concave function whose breakpoints encode the Newton polygon data.

This paper makes the bridge between these two perspectives rigorous and constructive. We work at the level of commutative semirings (not just fields) and extended natural number valuations (not just real-valued), capturing the essential algebraic structure in maximal generality. Our main contributions are:

1. **Novel structures**: We define `TropPolyData` (tropical polynomial data as coefficient sequences in ℕ∞), `NewtonSlopeSpectrum` (sorted slope multisets), and `termsCompete` (breakpoint detection predicate).

2. **Ultrametric Evaluation Theorem** (Theorem 5.1): For any tropical valuation v on a commutative semiring R, v(∑ aᵢrⁱ) ≥ min_i(v(aᵢ) + i·v(r)). This is the fundamental bridge inequality.

3. **Tropical Vieta** (Theorem 6.1): For a factored polynomial ∏(x - rⱼ), v(∏ rⱼ) = ∑ v(rⱼ), connecting constant term valuations to root valuation sums.

4. **Product Functoriality** (Theorem 9.1): Tropical evaluations of factors add under products, reflecting the Minkowski sum structure of Newton polygons.

5. **Falsifiable Conjecture**: The slope-root correspondence for Newton polygons over ℤₚ, with explicit computational tests.

---

## 2. Tropical Valuations

**Definition 2.1** (Tropical Valuation). Let R be a commutative monoid with zero equipped with addition. A *tropical valuation* on R is a function v: R → ℕ∞ satisfying:
- (TV1) v(0) = ⊤ (zero maps to the absorbing element)
- (TV2) v(1) = 0 (unit maps to tropical unit)
- (TV3) v(ab) = v(a) + v(b) (multiplication becomes tropical multiplication)
- (TV4) min(v(a), v(b)) ≤ v(a + b) (ultrametric inequality)

The prototypical example is the p-adic valuation vₚ on ℕ, defined by vₚ(n) = emultiplicity(p, n), the multiplicity of p in the prime factorization of n.

**Remark.** Our formulation using ℕ∞ = WithTop ℕ rather than ℝ ∪ {∞} is deliberate: it captures the discrete, combinatorial nature of Newton polygon slopes for polynomials over ℤ while avoiding measure-theoretic complications. The theory generalizes directly to ℝ∞-valued valuations, but the ℕ∞ case suffices for our applications and has cleaner computational properties.

---

## 3. Tropical Polynomial Data

**Definition 3.1** (Tropical Polynomial Data). A *tropical polynomial of degree ≤ n* is a function coeffs: Fin(n+1) → ℕ∞, representing the tropicalization of a classical polynomial. Its *tropical evaluation* at y ∈ ℕ∞ is:

  eval(y) = inf_{i ∈ Fin(n+1)} (coeffs(i) + i · y)

where i · y denotes the i-fold sum y + y + ⋯ + y in ℕ∞.

**Definition 3.2** (Tropicalization Map). Given a tropical valuation v on R and a coefficient sequence a: Fin(n+1) → R, the *tropicalization* is tropicalize(v, a) with coefficients i ↦ v(aᵢ).

**Proposition 3.3** (Evaluation at Zero). trop_eval(0) = inf_i coeffs(i), the minimum coefficient.

**Proposition 3.4** (Evaluation at ⊤). trop_eval(⊤) = coeffs(0), the constant term coefficient.

*Proof.* At y = ⊤, all terms with i > 0 have i · ⊤ = ⊤, so coeffs(i) + ⊤ = ⊤. Only the i = 0 term survives. □

---

## 4. Valuation of Powers and Monomials

**Lemma 4.1** (Power Valuation). For any tropical valuation v and element r ∈ R, v(rᵏ) = k · v(r).

*Proof.* Induction on k using (TV3): v(r^{k+1}) = v(r · rᵏ) = v(r) + v(rᵏ) = v(r) + k·v(r) = (k+1)·v(r). □

**Lemma 4.2** (Monomial Valuation). v(a · rⁱ) = v(a) + i · v(r).

*Proof.* Direct from (TV3) and Lemma 4.1. □

---

## 5. The Ultrametric Evaluation Theorem

**Theorem 5.1** (Ultrametric Evaluation — Bridge Theorem). Let v be a tropical valuation on a commutative semiring R, let a: Fin(n+1) → R be polynomial coefficients, and let r ∈ R be an evaluation point. Then:

  (tropicalize v a).eval(v(r)) ≤ v(∑_i aᵢ · rⁱ)

That is, the tropical evaluation of the tropicalized polynomial at v(r) bounds the valuation of the classical evaluation from below.

*Proof.* First, by the ultrametric sum bound (Lemma 5.2 below), inf_i v(aᵢ · rⁱ) ≤ v(∑_i aᵢ · rⁱ). By Lemma 4.2, v(aᵢ · rⁱ) = v(aᵢ) + i · v(r), so the left side equals inf_i(v(aᵢ) + i · v(r)) = (tropicalize v a).eval(v(r)). □

**Lemma 5.2** (Ultrametric Sum Bound). For a nonempty finset S and function f: S → R, inf_{i∈S} v(f(i)) ≤ v(∑_{i∈S} f(i)).

*Proof.* Induction on |S|. For |S| = 1, equality holds. For S = S' ∪ {a}, by induction inf_{S'} v(f(i)) ≤ v(∑_{S'} f(i)), and by (TV4) min(v(f(a)), v(∑_{S'} f(i))) ≤ v(f(a) + ∑_{S'} f(i)). The result follows since inf_{S} = min(v(f(a)), inf_{S'}) ≤ min(v(f(a)), v(∑_{S'} f(i))). □

**Remark.** The ultrametric evaluation theorem is constructive: the tropical coefficients witnessing the bound are simply the valuations of the classical coefficients. This provides an algorithmic pipeline from polynomial data to tropical certificates.

---

## 6. Tropical Vieta's Formula

**Theorem 6.1** (Tropical Vieta). For a tropical valuation v and elements r₁, ..., rₖ ∈ R:

  v(∏_j rⱼ) = ∑_j v(rⱼ)

*Proof.* Induction on k using (TV3): v(∏_{j≤k+1} rⱼ) = v(r_{k+1} · ∏_{j≤k} rⱼ) = v(r_{k+1}) + v(∏_{j≤k} rⱼ) = v(r_{k+1}) + ∑_{j≤k} v(rⱼ). □

**Corollary 6.2.** For a monic polynomial f = ∏(x - rⱼ) over a commutative ring, the valuation of the constant term (up to sign) equals the sum of root valuations. In Newton polygon terms, the height at index 0 equals the total weight of the slope spectrum.

---

## 7. Newton Cloud Height Bounds

**Proposition 7.1.** For any tropical polynomial f and index i, f.eval(y) ≤ f.coeffs(i) + i · y. That is, each "Newton cloud point" (i, v(aᵢ)) gives an upper bound on the tropical evaluation.

*Proof.* The evaluation is an infimum, hence bounded above by each term. □

**Theorem 7.2** (Coefficient Monotonicity). If f.coeffs(i) ≤ g.coeffs(i) for all i, then f.eval(y) ≤ g.eval(y) for all y. Lowering Newton cloud heights lowers the tropical evaluation.

---

## 8. Product Functoriality

**Theorem 8.1** (Product Bound). For two polynomial sequences a (degree ≤ n) and b (degree ≤ m):

  (tropicalize v a).eval(v(r)) + (tropicalize v b).eval(v(r)) ≤ v((∑_i aᵢrⁱ)(∑_j bⱼrʲ))

*Proof.* By (TV3), v(fg) = v(f) + v(g). Apply Theorem 5.1 to each factor. □

This reflects the fact that Newton polygons of products relate via Minkowski sum: the slopes of the product polygon are the sorted merge of the factors' slopes.

---

## 9. Breakpoint Detection

**Definition 9.1** (Term Competition). Two terms i and j of a tropical polynomial f *compete* at y if coeffs(i) + i·y = coeffs(j) + j·y. Competition points correspond to vertices of the Newton polygon and breakpoints of the tropical evaluation function.

**Proposition 9.2.** Competition is symmetric: terms i and j compete at y iff j and i compete at y.

The breakpoints of the tropical evaluation — where the achieving term changes — correspond precisely to the vertices of the Newton polygon. Between consecutive breakpoints, the tropical evaluation is affine with slope equal to the index of the achieving term.

---

## 10. Unit Evaluation

**Theorem 10.1** (Unit Evaluation Bound). If v(r) = 0, then inf_i v(aᵢ) ≤ v(∑_i aᵢrⁱ).

When the evaluation point has valuation zero (is a "tropical unit"), the tropical evaluation reduces to the minimum coefficient valuation. This is the "horizontal line" case: the relevant part of the Newton polygon is the minimum height.

---

## 11. Quadratic Example

**Theorem 11.1.** For a quadratic c + br + ar², min(min(v(c), v(b)+v(r)), v(a)+2·v(r)) ≤ v(c + br + ar²).

This provides the explicit tropical bound for degree-2 polynomials. The three affine functions v(c), v(b)+y, v(a)+2y (in the variable y = v(r)) form the tropical parabola, and the minimum of these bounds the valuation of the classical evaluation.

---

## 12. Falsifiable Conjecture

**Conjecture 12.1** (Newton Slope-Root Correspondence). For a monic polynomial f ∈ ℤ[x] of degree n with n roots in ℤₚ, the sum of slopes of the Newton polygon of f with respect to vₚ equals vₚ(f(0)).

**Computational Test.** Take f = x² - 6x + 8 = (x-2)(x-4) at p = 2:
- Valuations: v₂(8) = 3, v₂(6) = 1, v₂(1) = 0
- Newton cloud: {(0,3), (1,1), (2,0)}
- Slopes (negated): {2, 1}, sum = 3
- v₂(constant term) = v₂(8) = 3 ✓

**Status.** The full slope-root correspondence (individual slopes matching root valuations) requires Hensel's lemma and p-adic completeness. Our Tropical Vieta (Theorem 6.1) establishes the "total weight" case, which is a necessary condition.

---

## 13. Algorithms

### Algorithm 1: Tropicalization Pipeline

**Input:** Polynomial coefficients a₀, ..., aₙ ∈ ℤ, prime p  
**Output:** Tropical polynomial data and Newton cloud

```
for i = 0 to n:
    compute v_p(a_i) = multiplicity of p in a_i
    tropical_coeffs[i] = v_p(a_i)
return TropPolyData(tropical_coeffs)
```

### Algorithm 2: Tropical Evaluation

**Input:** TropPolyData f, evaluation point y ∈ ℕ∞  
**Output:** min_i(f.coeffs[i] + i * y)

```
result = ∞
for i = 0 to degree:
    term = f.coeffs[i] + i * y
    result = min(result, term)
return result
```

### Algorithm 3: Newton Polygon Extraction

**Input:** Newton cloud points (i, v_i) for i = 0, ..., n  
**Output:** Lower convex hull slopes

```
# Graham scan on lower hull
hull = [point_0]
for i = 1 to n:
    while |hull| >= 2 and cross_product check fails:
        remove last point from hull
    add point_i to hull
slopes = [(hull[i+1].y - hull[i].y) / (hull[i+1].x - hull[i].x) for i in range(|hull|-1)]
return slopes (negated for the standard convention)
```

---

## 14. Discussion

The tropical Newton polygon bridge reveals that the relationship between classical algebra and tropical geometry is not merely analogical but functorial. The valuation map v acts as a morphism from the algebraic world (R, +, ·) to the tropical semiring (ℕ∞, min, +), and the ultrametric evaluation theorem shows this morphism preserves the essential structure of polynomial evaluation.

Several features distinguish our approach:

1. **Generality**: We work over arbitrary commutative semirings with tropical valuations, not just discrete valuation rings. This allows applications to semirings like ℕ where "roots" may not exist classically but tropical certificates still make sense.

2. **Constructivity**: The tropical coefficients witnessing our bounds are explicitly the valuations of the algebraic coefficients — no choices or existence arguments are needed.

3. **Compositionality**: The product functoriality theorem shows that the bridge composes well: products of polynomials yield sums of tropical evaluations.

4. **Machine verification**: All results are formalized in Lean 4, providing mathematical certainty beyond traditional peer review.

---

## 15. Future Work

1. **Slope-root correspondence**: Formalize the full Newton polygon theorem, connecting individual slopes to root valuations. This requires formalizing Hensel's lemma and p-adic completions.

2. **Tropical convexity bridge**: Compose the Newton polygon bridge with the tropical convex hull membership theorem to derive intersection properties of tropical polytopes from algebraic data.

3. **Higher-dimensional generalization**: Extend to multivariate polynomials, where Newton polygons become Newton polytopes and tropical evaluation becomes a minimum over lattice points.

4. **Algorithmic applications**: Use the tropical evaluation bounds for certified polynomial root isolation algorithms.

---

## References

1. Maclagan, D. and Sturmfels, B. *Introduction to Tropical Geometry*. Graduate Studies in Mathematics, AMS, 2015.
2. Einsiedler, M., Kapranov, M., and Lind, D. "Non-Archimedean amoebae and tropical varieties." *Journal für die reine und angewandte Mathematik*, 2006.
3. Baker, M. "An introduction to Berkovich analytic spaces and non-Archimedean potential theory on curves." In *p-adic Geometry*, AMS, 2008.
4. Neukirch, J. *Algebraic Number Theory*. Grundlehren der mathematischen Wissenschaften, Springer, 1999.
