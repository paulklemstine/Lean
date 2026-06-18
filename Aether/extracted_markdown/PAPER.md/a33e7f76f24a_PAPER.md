# Tropical Satake Support Reconstruction for GL₃:  
# Formalized Min-Plus Algebra and Convolution Multiplicativity

## Abstract

We present a formally verified treatment of the tropical Satake transform
for GL₃, encoding dominant coweights as pairs (a,b) ∈ ℕ × ℕ representing
the coweight (a+b, b, 0). Our main contributions are:

1. **Direction separation** (Theorem A): Any two distinct dominant coweights
   are separated by a linear form in the dominant chamber {(p,q) : 0 ≤ q ≤ p}.

2. **Maximal support theory**: Every nonzero finitely supported function has
   a nonempty maximal support in the product order, and the maximal layer
   peeling operation strictly reduces support size.

3. **Min-plus product decomposition**: The minimum over a Cartesian product
   decomposes as the sum of individual minima — the algebraic engine behind
   tropical multiplicativity.

4. **Tropical convolution multiplicativity**: The tropical Satake transform
   converts min-plus convolution to ordinary addition of piecewise-linear
   functions.

5. **Cancellation at the evaluation level**: Equal sums of tropical evaluations
   imply equal tropical evaluations — a pointwise cancellation theorem.

6. **Strict ray domination**: Terms with smaller linear forms eventually
   dominate along any ray, by an Archimedean argument.

All results are machine-verified in Lean 4 with Mathlib, totaling 13 complete
proofs with no `sorry` or non-standard axioms.

---

## 1. Introduction

### 1.1 The Tropical Satake Transform

The Satake transform is a classical tool in representation theory that relates
functions on a reductive group to functions on a maximal torus. In the tropical
(min-plus) setting, this transform takes a particularly elegant form.

For GL₃, dominant coweights are triples (λ₁, λ₂, λ₃) with λ₁ ≥ λ₂ ≥ λ₃.
Normalizing λ₃ = 0, we parametrize by pairs (a, b) ∈ ℕ × ℕ where
λ = (a+b, b, 0). The pairing with dominant weights in fundamental weight
coordinates is simply ⟨(a,b), (x,y)⟩ = ax + by.

Given a finitely supported function f : (ℕ × ℕ) →₀ ℝ, its **tropical
Satake transform** is the min-plus polynomial:

$$\operatorname{trop}(f)(x,y) = \min_{(a,b) \in \operatorname{supp}(f)} \big(f(a,b) + ax + by\big)$$

This is a concave piecewise-linear function of (x,y), whose combinatorial
structure — the active regions, the Newton polytope, the facial decomposition
— encodes deep information about the support and coefficients of f.

### 1.2 Our Contribution

We provide the first machine-verified treatment of the algebraic foundations
of this transform, focusing on:

- The **separation** of distinct coweights by dominant directions
- The **product order** structure of the support and its maximal elements
- The **multiplicativity** of the transform under min-plus convolution
- **Cancellation** properties that follow from multiplicativity

Our formalization carefully identifies which classical claims about support
reconstruction hold in the Finsupp encoding and which require additional
hypotheses (see Section 5 for a detailed discussion).

---

## 2. Mathematical Setup

### 2.1 Dominant Coweights

We work with `DomWt := ℕ × ℕ`, where (a, b) represents the dominant
coweight (a+b, b, 0) for GL₃. The **product partial order** on DomWt is:

$$(a₁, b₁) ≤ (a₂, b₂) \iff a₁ ≤ a₂ \text{ and } b₁ ≤ b₂$$

This is a well-founded partial order (every nonempty subset has a minimal
element), and every nonempty finite subset has at least one maximal element.

### 2.2 The Tropical Transform

For f : DomWt →₀ ℝ (a Finsupp with real coefficients), we define:

```
tropEval f x y := min_{u ∈ f.support} (f(u) + u.1 · x + u.2 · y)
```

When f = 0 (empty support), we set tropEval f x y = 0 by convention.

### 2.3 Maximal Support

The **maximal support** of f is:

```
maximalSupport f := {u ∈ f.support : ∀ v ∈ f.support, u ≤ v → u = v}
```

These are the elements of the support that are maximal in the product order.
They form an antichain (no two are comparable) and represent the "top layer"
of the support, analogous to highest weights in representation theory.

### 2.4 Min-Plus Convolution

The tropical (min-plus) convolution of f and g is defined by:

$$(f \star g)(\lambda) = \min_{\mu + \nu = \lambda} \big(f(\mu) + g(\nu)\big)$$

where the minimum is over pairs (μ, ν) with μ ∈ supp(f), ν ∈ supp(g),
and μ + ν = λ (componentwise addition).

---

## 3. Main Results

### 3.1 Direction Separation (Theorem A)

**Theorem** (`dominant_direction_strictly_orders`).
*For any distinct u ≠ v in ℕ × ℕ, there exist p, q ∈ ℕ with q ≤ p such that
the linear forms u₁p + u₂q and v₁p + v₂q are distinct.*

**Proof.** If u₁ ≠ v₁, take (p,q) = (1,0). If u₁ = v₁ (forcing u₂ ≠ v₂
since u ≠ v), take (p,q) = (1,1). In both cases q ≤ p. □

This is the GL₃ analogue of "distinct slopes" in GL₂. It says the dominant
chamber directions {(p,q) : 0 ≤ q ≤ p} are rich enough to separate any pair
of coweights. The two directions (1,0) and (1,1) suffice as a separating family.

### 3.2 Maximal Support Properties

**Theorem** (`maximalSupport_nonempty`).
*If f ≠ 0, then maximalSupport f is nonempty.*

**Proof.** Since f.support is nonempty and finite, take an element u maximizing
u₁ + u₂ (the total weight). Then u is maximal: if v ≥ u with v ∈ support,
then v₁ + v₂ ≥ u₁ + u₂, forcing equality, hence v = u. □

**Theorem** (`support_card_eraseMaxLayer_lt`).
*If f ≠ 0, then |supp(eraseMaxLayer f)| < |supp(f)|.*

This ensures the layer-peeling operation terminates in at most |supp(f)| steps.

### 3.3 Min-Plus Product Decomposition

**Theorem** (`finset_inf'_product_eq_add`).
*For nonempty finite sets S, T and functions f : S → ℝ, g : T → ℝ:*

$$\min_{(a,b) \in S \times T} \big(f(a) + g(b)\big) = \min_{a \in S} f(a) + \min_{b \in T} g(b)$$

**Proof.** The inequality ≤ follows from choosing (a₀, b₀) achieving the
individual minima. The inequality ≥ follows because f(a) + g(b) ≥ min f + min g
for all (a,b). □

This seemingly simple identity is the algebraic engine behind all tropical
multiplicativity results. It expresses the key fact that the minimum over a
product space decomposes when the objective function is separable.

### 3.4 Convolution Multiplicativity

**Theorem** (`tropEval_conv_eq_add`).
*For nonzero f, g:*

$$\min_{(\mu,\nu) \in \operatorname{supp}(f) \times \operatorname{supp}(g)} \big(f(\mu) + g(\nu) + (\mu_1+\nu_1)x + (\mu_2+\nu_2)y\big) = \operatorname{trop}(f)(x,y) + \operatorname{trop}(g)(x,y)$$

**Proof.** The LHS equals min_{(μ,ν)} [(f(μ) + μ·(x,y)) + (g(ν) + ν·(x,y))],
which decomposes by the product decomposition theorem. □

### 3.5 Cancellation

**Theorem** (`tropEval_cancel_left`).
*If f ≠ 0 and trop(f) + trop(g) = trop(f) + trop(h) pointwise on {0 ≤ y ≤ x},
then trop(g) = trop(h) on {0 ≤ y ≤ x}.*

**Proof.** Pointwise cancellation of real-valued functions. □

### 3.6 Strict Ray Domination

**Theorem** (`strict_domination_along_ray`).
*If (u₁p + u₂q) < (v₁p + v₂q) (as integers), then for any fixed
coefficients cᵤ, c_v, there exists N such that for all n ≥ N:*

$$c_u + u_1 \cdot np + u_2 \cdot nq < c_v + v_1 \cdot np + v_2 \cdot nq$$

**Proof.** The difference is cᵤ - c_v + n·((u₁-v₁)p + (u₂-v₂)q). Since the
coefficient of n is negative (by hypothesis), the expression tends to -∞.
Use the Archimedean property to find N. □

---

## 4. Applications

### 4.1 Tropical Optimization

The min-plus polynomial framework directly applies to optimization problems
where one seeks to minimize a piecewise-linear objective over a discrete
set of configurations. The convolution multiplicativity theorem means that
sequential optimization can be decomposed into independent stages.

**Example**: In logistics, if f(μ) represents the cost of a first-stage
decision μ and g(ν) the cost of a second-stage decision ν, then
the total cost min_{μ+ν=λ} (f(μ) + g(ν)) = (f⋆g)(λ) has a tropical
evaluation that decomposes multiplicatively. This enables efficient
computation of optimal total costs along parametric families.

### 4.2 Representation Theory

In the representation theory of p-adic groups, the Satake transform
relates spherical functions on GLₙ(Qₚ) to symmetric functions.
Our tropical version captures the "leading order" behavior as p → ∞,
where the representation-theoretic quantities are dominated by
their tropical (max/min) asymptotics.

The direction separation theorem shows that the fundamental weight
coordinates provide enough "resolution" to distinguish any two
dominant coweights, even with the restriction to dominant directions.

### 4.3 Algebraic Geometry

Tropical varieties — defined as corners of piecewise-linear functions
— are the tropical analogues of algebraic varieties. Our tropEval
function defines such a tropical variety in ℝ². The active region
decomposition (which term achieves the minimum where) gives the
dual subdivision of the Newton polytope, a key construction in
toric geometry.

---

## 5. On Support Reconstruction: Subtleties and Corrections

### 5.1 The Redundancy Issue

A natural question is whether tropEval is injective on Finsupp: does
tropEval f = tropEval g (pointwise) imply f = g?

**The answer is no.** Consider f with support {(2,0), (0,2), (1,1)} and
all coefficients 1, versus g with support {(2,0), (0,2)} and coefficients 1.
Then:

$$\operatorname{trop}(f)(x,y) = \min(1+2x, 1+2y, 1+x+y) = \min(1+2x, 1+2y) = \operatorname{trop}(g)(x,y)$$

because x + y ≥ min(2x, 2y) for all x, y ∈ ℝ. The term at (1,1) is
**tropically redundant**: it never achieves the minimum anywhere.

This is a known phenomenon in tropical geometry. The correct injectivity
statement requires restricting to **irredundant** (or **essential**)
representations, where every support point achieves the minimum at some
evaluation point.

### 5.2 Implications for Cancellation

The min-plus polynomial ring (ℕ × ℕ) →₀ ℝ with tropical convolution is
**not** an integral domain. A concrete counterexample: with
f = {(0,0): 1, (1,0): 1}, g = {(0,0): 1, (2,0): 10}, and
h = {(0,0): 1, (1,0): 10, (2,0): 10}, we have f⋆g = f⋆h as Finsupps
but g ≠ h. The extra term (1,0) → 10 in h is always dominated.

However, cancellation **does** hold at the evaluation level:
if trop(f) + trop(g) = trop(f) + trop(h) pointwise, then
trop(g) = trop(h) pointwise. This is our `tropEval_cancel_left` theorem.

### 5.3 What IS Recoverable

From the tropical polynomial trop(f), one can recover:
1. The **essential support** — the set of irredundant terms.
2. The **coefficients** on the essential support.
3. The **Newton polytope** — the convex hull of the support.
4. The **tropical variety** — the locus of non-smoothness.

The gap between f and its essential reduction is precisely the set of
redundant terms, which contribute nothing to the tropical polynomial.

---

## 6. Discussion: A Scientific American Perspective

### What Are Tropical Numbers?

Imagine a world where "addition" means "taking the minimum" and
"multiplication" means "ordinary addition." This is the min-plus
semiring, the algebraic foundation of tropical mathematics. Named
(somewhat whimsically) after Brazilian mathematician Imre Simon,
tropical math turns familiar algebraic structures inside out.

In classical algebra, a polynomial like 3x² + 5x + 7 is evaluated
by multiplying and adding. In tropical algebra, the same expression
becomes min(3 + 2x, 5 + x, 7) — each term is a linear function, and
the "polynomial" is their lower envelope. The result is a concave
piecewise-linear function, and its corners (where two linear pieces
meet) form a "tropical variety."

### Why GL₃?

GL₃ is the group of invertible 3×3 matrices. Its representation theory
is controlled by "dominant coweights" — essentially, triples of
non-increasing integers (λ₁ ≥ λ₂ ≥ λ₃). By normalizing λ₃ = 0,
we encode these as pairs (a, b) where the coweight is (a+b, b, 0).

The Satake transform is a bridge between functions on GL₃ and symmetric
functions. In the tropical world, this bridge becomes particularly
transparent: the transform is just a min-plus polynomial evaluation,
and its structure is governed by elementary combinatorics of pairs of
natural numbers.

GL₂ (2×2 matrices) is too simple to reveal the interesting phenomena:
coweights are just natural numbers, and everything reduces to 1D.
GL₃ is the first case where genuinely 2D phenomena appear: antichains,
incomparable elements, and the rich geometry of Newton polygons.

### What Did We Prove?

Our main achievement is the **convolution multiplicativity theorem**:
the tropical Satake transform converts convolution (a combinatorial
operation on coefficient functions) into addition (a simple operation
on piecewise-linear functions). This is the tropical analogue of the
classical fact that Fourier transforms convert convolution to pointwise
multiplication.

From multiplicativity, we derived a **cancellation principle**: knowing
f⋆g and f determines g (at the evaluation level). This is the tropical
analogue of deconvolution, and it opens the door to tropical analytic
techniques in representation theory.

### The Surprise: What We Can't Prove

Perhaps the most interesting finding is what does **not** hold: the
naive injectivity theorem (equal tropical polynomials imply equal
coefficient functions) is **false**. Some terms can be "tropically
invisible" — dominated everywhere by other terms. This phenomenon has
no classical analogue (ordinary polynomials with the same values must
have the same coefficients) and reveals the fundamentally different
nature of min-plus algebra.

### Future Directions

1. **Higher rank**: Extending from GL₃ to GLₙ requires working with
   n-1 dimensional support and the full Weyl chamber geometry.

2. **Tropical canonical bases**: The irredundancy condition should
   connect to Lusztig's canonical bases via tropicalization.

3. **Computational applications**: Min-plus polynomial arithmetic
   has applications in optimal control, scheduling, and network
   optimization.

4. **Tropical Hecke algebras**: The convolution structure we studied
   is the tropical shadow of the spherical Hecke algebra, and our
   results should extend to Iwahori-Hecke algebras and their
   tropical degenerations.

---

## 7. Formalization Details

### 7.1 Lean 4 Implementation

Our formalization uses Lean 4 with Mathlib. Key design decisions:

- **Finsupp encoding**: We use `(ℕ × ℕ) →₀ ℝ` where f(u) = 0 means
  u is not in the tropical support. This is efficient but conflates
  "coefficient 0" with "not in support."

- **Tropical evaluation**: Defined via `Finset.inf'` (minimum over a
  nonempty finset), returning 0 when the support is empty.

- **Product order**: We use Lean's built-in `PartialOrder` on `ℕ × ℕ`.

### 7.2 Proof Statistics

| Theorem | Lines | Strategy |
|---------|-------|----------|
| Direction separation | 3 | Case split + omega |
| Maximal support nonempty | 10 | Max image + grind |
| Support card decrease | 5 | Filter subset |
| Min-plus product | 4 | le_antisymm |
| Convolution multiplicativity | 4 | Convert + ring |
| Cancellation (chamber) | 1 | linear_combination |
| Cancellation (full) | 1 | grind |
| Strict ray domination | 6 | Archimedean + nlinarith |
| Chain exposure | 2 | Unfold + grind |

### 7.3 Files

- `Tropical/SatakeGL3/Defs.lean` — Core definitions (tropEval, maximalSupport, etc.)
- `Tropical/SatakeGL3/Theorems.lean` — All 13 theorems, fully proved
- `Tropical/demos/tropical_satake_demo.py` — Python demonstrations

---

## References

1. I. Simon. "Recognizable sets with multiplicities in the tropical
   semiring." MFCS 1988.

2. D. Maclagan and B. Sturmfels. *Introduction to Tropical Geometry.*
   AMS, 2015.

3. J. Tits. "Reductive groups over local fields." Automorphic Forms,
   Representations and L-functions, AMS, 1979.

4. I. Satake. "Theory of spherical functions on reductive algebraic
   groups over p-adic fields." IHES, 1963.

5. Mathlib contributors. *Mathlib4: A mathematical library for Lean 4.*
   https://github.com/leanprover-community/mathlib4

---

*All proofs have been machine-verified in Lean 4.28.0 with Mathlib.
No sorry, axiom, or @[implemented_by] declarations are used.*
