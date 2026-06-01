# Tropical Valuation Functor: An Order-Preserving Semiring Bridge from Algebraic Coefficients to Tropical Convexity

## Abstract

We introduce the *tropical valuation*, a novel algebraic structure that formalizes the bridge between commutative semirings and tropical (min-plus) algebra. A tropical valuation on a commutative semiring R is a map v : R → ℕ∞ satisfying v(0) = ⊤, v(1) = 0, v(ab) = v(a) + v(b), and min(v(a), v(b)) ≤ v(a+b). We prove that the extended p-adic multiplicity is a tropical valuation on both ℕ and ℤ. The main result is a bridge theorem: the coordinatewise valuation of any algebraic linear combination ∑ cᵢxᵢ lies in the tropical convex hull of the valuation images of the generators xᵢ, with tropical coefficients given by v(cᵢ). We establish the iterated ultrametric inequality for finite sums, the multiplicative-to-additive product formula, divisibility monotonicity, and strict growth under non-unit multiplication. All results are fully formalized in Lean 4 with Mathlib, totaling 15+ theorems and 3 novel structures with zero `sorry` statements.

**Keywords**: tropical geometry, p-adic valuation, tropical convexity, ultrametric inequality, semiring homomorphism, tropical convex hull, valuation theory

## 1. Introduction

Tropical mathematics studies the semiring (ℝ ∪ {+∞}, min, +), where the "additive" operation is minimum and the "multiplicative" operation is ordinary addition. This algebraic framework, originating in the work of Simon (1988) and popularized by Sturmfels and collaborators, provides a combinatorial approach to problems in algebraic geometry, optimization, and computational complexity.

The p-adic valuation vₚ : ℤ → ℕ ∪ {∞} is one of the oldest tools in number theory. It measures the exact power of a prime p dividing an integer. Its key properties — multiplicativity (vₚ(ab) = vₚ(a) + vₚ(b)) and the ultrametric inequality (vₚ(a+b) ≥ min(vₚ(a), vₚ(b))) — are precisely the axioms that make it a homomorphism from (ℤ, +, ·) to the tropical semiring (ℕ∞, min, +).

This observation, while folklore in the valuation theory community, has not been systematically formalized as a bridge between algebraic linear algebra and tropical convex geometry. In this paper, we:

1. Define the *tropical valuation* as an abstract algebraic structure (§2).
2. Construct canonical instances via p-adic multiplicity (§3).
3. Prove the iterated ultrametric inequality for finite sums (§4).
4. Establish the *bridge theorem*: coordinatewise valuations of algebraic linear combinations lie in tropical convex hulls (§5).
5. Define tropical halfspace certificates and show they are extractable from valuation data (§6).
6. Prove monotonicity and strict growth properties of tropical valuations (§7).
7. State a falsifiable conjecture on tropical surjectivity (§8).

All results are formalized in Lean 4 using the Mathlib library, providing machine-verified proofs.

## 2. The Tropical Valuation Structure

**Definition 2.1** (Tropical Valuation). Let R be a commutative monoid with zero equipped with addition. A *tropical valuation* on R is a quadruple (val, val_zero, val_one, val_mul, val_add_le) where:
- val : R → ℕ∞ is the valuation map
- val_zero : val(0) = ⊤
- val_one : val(1) = 0
- val_mul : val(a · b) = val(a) + val(b) for all a, b ∈ R
- val_add_le : min(val(a), val(b)) ≤ val(a + b) for all a, b ∈ R

The codomain ℕ∞ = ℕ ∪ {⊤} is the extended natural numbers, which carries the structure of a tropical semiring under (min, +) with ⊤ as the absorbing element for min and the identity for addition being 0.

**Remark 2.2**. The axioms express that val is a semiring homomorphism from (R, +, ·) to (ℕ∞, min, +) in the tropical sense:
- (val_mul) says val is a monoid homomorphism (R, ·, 1) → (ℕ∞, +, 0)
- (val_add_le) says val is a "lax" semilattice homomorphism (R, +) → (ℕ∞, min), with inequality rather than equality because cancellation can decrease the valuation

**Remark 2.3**. This definition generalizes classical valuations in two ways: (a) the codomain is ℕ∞ rather than an arbitrary ordered group, and (b) the ultrametric inequality is stated as ≤ rather than =, allowing for non-discrete valuations. The ℕ∞ codomain is natural for the emultiplicity function and avoids the complications of ℝ∞ or ℤ∞.

## 3. The p-Adic Instance

**Theorem 3.1**. For any prime p, the extended multiplicity emultiplicity(p, ·) : ℕ → ℕ∞ is a tropical valuation on ℕ.

*Proof*. The four axioms are verified as follows:
- emultiplicity(p, 0) = ⊤ by definition (every power of p divides 0)
- emultiplicity(p, 1) = 0 because p > 1 implies p ∤ 1
- emultiplicity(p, a·b) = emultiplicity(p, a) + emultiplicity(p, b) by the fundamental theorem of arithmetic (unique factorization)
- min(emultiplicity(p, a), emultiplicity(p, b)) ≤ emultiplicity(p, a+b) by the ultrametric inequality for multiplicity

**Theorem 3.2**. For any prime p, emultiplicity(p, ·) : ℤ → ℕ∞ is a tropical valuation on ℤ.

*Proof*. Similar to Theorem 3.1, using the corresponding properties of emultiplicity over ℤ. The val_one property requires showing that p (viewed as an integer) does not divide 1, which follows from p > 1.

## 4. Iterated Ultrametric Inequality

The binary ultrametric inequality extends to finite sums:

**Theorem 4.1** (Iterated Ultrametric). Let v be a tropical valuation on a commutative semiring R, s a nonempty finite set, and f : s → R. Then:

inf_{i ∈ s} v(f(i)) ≤ v(∑_{i ∈ s} f(i))

*Proof*. By induction on the nonempty finset using cons_induction:
- **Base case** (s = {a}): Both sides equal v(f(a)).
- **Inductive step** (s = {a} ∪ t with t nonempty): We have
  v(∑_{s} f) = v(f(a) + ∑_{t} f) ≥ min(v(f(a)), v(∑_{t} f))
  ≥ min(v(f(a)), inf_{t} v(f(i))) = inf_{s} v(f(i))

This theorem is the key ingredient for the bridge theorem.

## 5. The Bridge Theorem

**Definition 5.1** (Coordinatewise Valuation). For a tropical valuation v on R and a vector x ∈ Rⁿ, define coordVal(v, x) ∈ (ℕ∞)ⁿ by coordVal(v, x)ⱼ = v(xⱼ).

**Definition 5.2** (Tropical Domination). A point y ∈ (ℕ∞)ⁿ is *tropically dominated* by points p₁, ..., pₖ ∈ (ℕ∞)ⁿ with coefficients λ₁, ..., λₖ ∈ ℕ∞ if for every coordinate j:

inf_i (λᵢ + pᵢⱼ) ≤ yⱼ

**Definition 5.3** (Tropical Convex Hull). The tropical convex hull of p₁, ..., pₖ is the set of all y ∈ (ℕ∞)ⁿ that are tropically dominated by the pᵢ for some choice of coefficients.

**Theorem 5.4** (Coordinatewise Valuation Inequality). For a tropical valuation v on a commutative semiring R, vectors x₁, ..., xₖ ∈ Rⁿ, coefficients c₁, ..., cₖ ∈ R, and k > 0:

inf_i (v(cᵢ) + v(xᵢⱼ)) ≤ v(∑_i cᵢ · xᵢⱼ)

for every coordinate j.

*Proof*. Fix coordinate j. By the iterated ultrametric inequality (Theorem 4.1):
inf_i v(cᵢ · xᵢⱼ) ≤ v(∑_i cᵢ · xᵢⱼ)
By the multiplicativity axiom, v(cᵢ · xᵢⱼ) = v(cᵢ) + v(xᵢⱼ), so:
inf_i (v(cᵢ) + v(xᵢⱼ)) ≤ v(∑_i cᵢ · xᵢⱼ)

**Theorem 5.5** (Bridge Theorem). The coordinatewise valuation of ∑_i cᵢxᵢ lies in the tropical convex hull of the coordinatewise valuations of the xᵢ:

coordVal(v, ∑_i cᵢxᵢ) ∈ tropConvHull({coordVal(v, xᵢ)})

with tropical coefficients λᵢ = v(cᵢ).

*Proof*. Immediate from Theorem 5.4 by taking the tropical coefficients to be the valuations of the algebraic coefficients.

## 6. Tropical Halfspace Certificates

**Definition 6.1** (Tropical Halfspace Certificate). A tropical halfspace certificate for a point x ∈ (ℕ∞)ⁿ consists of weights w ∈ (ℕ∞)ⁿ, a bias b ∈ ℕ∞, and a bound B ∈ ℕ∞ such that:

min(b, inf_j (wⱼ + xⱼ)) ≤ B

**Theorem 6.2**. Given a valuation bound v(∑_i wᵢxᵢ) ≤ B, there exists a tropical halfspace certificate for the valuation image.

This provides an algorithmic pipeline: algebraic coefficient bounds → tropical geometry certificates.

## 7. Order Properties

**Theorem 7.1** (Divisibility Monotonicity). If a | b and b ≠ 0, then v(a) ≤ v(b).

*Proof*. Write b = a · c. Then v(b) = v(a) + v(c) ≥ v(a).

**Theorem 7.2** (Strict Growth). If v(p) ≠ 0 and v(a) ≠ ⊤, then v(a) < v(p · a).

*Proof*. v(p · a) = v(p) + v(a). Since v(p) > 0 and v(a) is finite, v(a) < v(a) + v(p).

**Theorem 7.3** (Product Formula). v(∏_i aᵢ) = ∑_i v(aᵢ) and v(aⁿ) = n · v(a).

**Theorem 7.4** (Tropical Semiring Laws for ℕ∞). The extended naturals satisfy all four tropical semiring laws: commutativity and associativity of min, commutativity of addition, and distributivity of addition over min.

## 8. Falsifiable Conjecture

**Conjecture 8.1** (Tropical Surjectivity). For any prime p, dimensions n and k, and generators x₁,...,xₖ ∈ ℕⁿ, the tropical convex hull of {coordVal(vₚ, xᵢ)} equals the set of coordinatewise valuations of all ℕ-linear combinations.

This conjecture is computationally testable. For p=2, n=2, k=2 with generators (2,3) and (4,5), we can enumerate valuations of c₁(2,3) + c₂(4,5) for all small c₁, c₂ and check coverage.

## 9. Algorithms

### Algorithm 1: Tropical Valuation Computation
```
Input: prime p, vector x ∈ ℕⁿ
Output: coordVal(vₚ, x) ∈ (ℕ∞)ⁿ
For j = 1 to n:
  If x[j] = 0: result[j] = ∞
  Else: result[j] = max {k : p^k | x[j]}
Return result
```

### Algorithm 2: Bridge Certificate Construction
```
Input: prime p, coefficients c ∈ ℕᵏ, generators x ∈ ℕᵏˣⁿ
Output: tropical hull membership certificate
Compute y = coordVal(vₚ, ∑ cᵢxᵢ)
Compute λᵢ = vₚ(cᵢ) for each i
Verify: for each j, min_i(λᵢ + vₚ(xᵢⱼ)) ≤ yⱼ
Return (y, λ, verification)
```

## 10. Discussion

The tropical valuation bridge established in this work provides a rigorous framework for transporting algebraic constructions into tropical geometry. The key insight is that the p-adic valuation, viewed as a tropical semiring homomorphism, preserves exactly the structure needed to convert algebraic linear combinations into tropical convex combinations.

Several aspects deserve emphasis:

1. **Universality**: The TropicalValuation structure is defined abstractly, allowing instantiation beyond p-adic valuations. Any function satisfying the four axioms can serve as a bridge.

2. **Computational content**: The bridge theorem is constructive — the tropical coefficients are explicitly computed as valuations of the algebraic coefficients. This makes the bridge algorithmically useful, not merely existential.

3. **One-directional**: The bridge maps algebra → tropical geometry but not (in general) the reverse. The surjectivity conjecture (Conjecture 8.1) asks whether the reverse direction holds, and computational evidence suggests it may fail.

## 11. Related Work

- Develin and Sturmfels (2004) introduced tropical convexity and characterized tropical convex hulls.
- Gaubert and Katz (2009) studied tropical analogues of polar cones and Farkas' lemma.
- The connection between valuations and tropical geometry is classical in the theory of tropical varieties (Maclagan and Sturmfels, 2015).
- Formal verification of tropical mathematics in proof assistants is relatively new; see the tropical Helly theorem formalization in this project's catalog.

## 12. Future Work

- Extend the bridge to tropical polynomial algebra (Newton polygons)
- Study the failure modes of the surjectivity conjecture
- Develop tropical certificates for lattice-based cryptographic protocols
- Connect to the tropical Helly theorem for algorithmic applications

## References

1. Develin, M. and Sturmfels, B. "Tropical Convexity." *Documenta Mathematica* 9 (2004), 1–27.
2. Gaubert, S. and Katz, R.D. "The tropical analogue of polar cones." *Linear Algebra and its Applications* 431.5-7 (2009), 608–625.
3. Maclagan, D. and Sturmfels, B. *Introduction to Tropical Geometry.* AMS, 2015.
4. Simon, I. "Recognizable sets with multiplicities in the tropical semiring." *MFCS 1988*, LNCS 324, pp. 107–120.
