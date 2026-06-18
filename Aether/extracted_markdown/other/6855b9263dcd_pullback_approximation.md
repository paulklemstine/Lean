# Pullback Stability of Universal Approximation under Continuous Feature Maps

## Abstract

We establish a formally verified transport principle for uniform approximation
by dense function classes: given a continuous map φ : X → Y between compact
Hausdorff spaces and a dense subalgebra A of C(Y, ℝ), the pullbacks
{f ∘ φ : f ∈ A} are dense in the closed subalgebra FiberConst(φ) of continuous
functions on X that are constant on fibers of φ. When φ is injective, this
recovers full density in C(X, ℝ). The proof, formalized in Lean 4 with Mathlib,
proceeds through an image factorization theorem (every fiber-constant function
factors continuously through the image of φ, via Tietze extension) and a
density restriction argument. We provide a sharp structural characterization:
FiberConst(φ) = C(X, ℝ) if and only if φ is injective (using Urysohn
separation for the reverse direction). This gives a reusable categorical
principle for transporting universal approximation theorems—including
Stone–Weierstrass and neural network density results—along continuous maps,
with the precise information-theoretic obstruction quantified by the
fiber structure of the feature map.

**Keywords:** universal approximation, pullback, feature map, fiber-constant
functions, Stone–Weierstrass, compact Hausdorff spaces, formal verification,
Lean 4

---

## 1. Introduction

Universal approximation theorems assert that certain parametric function
classes are dense in spaces of continuous functions. The classical prototype
is the Stone–Weierstrass theorem: any subalgebra of C(X, ℝ) that separates
points and contains the constants is uniformly dense. In machine learning,
analogous results establish that neural networks with various activation
functions can approximate any continuous function on compact domains.

A natural question arises when one works not directly with functions on X,
but through a *feature map* φ : X → Y. If a function class A is dense in
C(Y, ℝ), what can be said about {f ∘ φ : f ∈ A} as a subset of C(X, ℝ)?
This question is fundamental to understanding learned representations,
encoder-decoder architectures, and any pipeline where raw inputs are first
mapped to a feature space before function approximation occurs.

The answer depends critically on the *injectivity* of φ:

- **Injective φ:** The pullbacks {f ∘ φ : f ∈ A} are dense in all of C(X, ℝ).
  No information is lost, and full universal approximation transports from Y
  to X.

- **Non-injective φ:** Information is lost. Points that φ identifies cannot
  be distinguished by any pullback f ∘ φ. The achievable target is precisely
  the closed subalgebra FiberConst(φ) of functions constant on fibers of φ—
  and the pullbacks are dense there.

This paper formalizes and proves this transport principle in full generality
for compact Hausdorff spaces, with complete machine-verified proofs in
Lean 4 using the Mathlib library.

### 1.1 Contributions

1. **FiberConst(φ) as a closed subalgebra.** We define the subalgebra of
   fiber-constant functions and prove it is closed in the uniform topology.

2. **Image factorization theorem.** Every fiber-constant function factors
   continuously through the image of φ, using the quotient map property of
   the corestriction and Tietze extension.

3. **Density transport theorem.** If A is dense in C(Y, ℝ), then
   {f ∘ φ : f ∈ A} is dense in FiberConst(φ). The closure equals
   FiberConst(φ) exactly.

4. **Sharp injectivity characterization.** FiberConst(φ) = C(X, ℝ) if and
   only if φ is injective, using Urysohn separation for the non-trivial
   direction.

5. **ε-approximation corollaries.** Quantitative versions giving, for any
   ε > 0 and any fiber-constant target g, an explicit approximant f ∈ A
   with ‖f ∘ φ − g‖ < ε.

6. **Complete formal verification** in Lean 4 with Mathlib, with no axioms
   beyond `propext`, `Classical.choice`, and `Quot.sound`.

---

## 2. Mathematical Framework

### 2.1 Setup

Let X and Y be compact Hausdorff spaces. Write C(X, ℝ) for the ℝ-algebra
of continuous real-valued functions on X, equipped with the supremum norm
‖g‖ = sup\_{x ∈ X} |g(x)|. Let φ : X → Y be a continuous map.

**Definition 2.1** (Fiber-constant functions). The *fiber-constant
subalgebra* of φ is

> FiberConst(φ) = {g ∈ C(X, ℝ) : φ(x) = φ(x') ⟹ g(x) = g(x')}.

This is the set of continuous functions that are constant on the fibers
φ⁻¹({y}) of φ.

**Definition 2.2** (Pullback homomorphism). The *pullback* of φ is the
ℝ-algebra homomorphism

> φ\* : C(Y, ℝ) → C(X, ℝ),  f ↦ f ∘ φ.

### 2.2 Basic Properties

**Proposition 2.3.** FiberConst(φ) is a subalgebra of C(X, ℝ). Moreover:
- The image of φ\* is contained in FiberConst(φ).
- FiberConst(φ) is closed in the uniform topology on C(X, ℝ).
- The pullback map φ\* is norm-nonincreasing: ‖φ\*f‖ ≤ ‖f‖ for all f.
- When φ is surjective, φ\* is an isometry: ‖φ\*f‖ = ‖f‖.

*Proof.* The subalgebra property is immediate from pointwise arithmetic.
Closedness follows because FiberConst(φ) = ⋂\_{φ(x)=φ(x')} {g : g(x) = g(x')},
where each set {g : g(x) = g(x')} is closed (evaluations are continuous).
The norm bound follows from ‖(f ∘ φ)(x)‖ = ‖f(φ(x))‖ ≤ ‖f‖. Surjectivity
gives the reverse bound: for any y, choose x with φ(x) = y and use
‖f(y)‖ = ‖(f ∘ φ)(x)‖ ≤ ‖f ∘ φ‖. □

**Theorem 2.4** (Injectivity characterization). FiberConst(φ) = C(X, ℝ)
if and only if φ is injective.

*Proof.* (⟹) If φ(x) = φ(x') with x ≠ x', by Urysohn's lemma for
normal spaces (compact Hausdorff spaces are normal), there exists
g ∈ C(X, ℝ) with g(x) = 0 and g(x') = 1. Then g ∉ FiberConst(φ).
(⟸) If φ is injective, φ(x) = φ(x') implies x = x', so g(x) = g(x')
trivially. □

---

## 3. Image Factorization

The key structural result is that every fiber-constant function factors
through the image of φ.

**Theorem 3.1** (Factorization). FiberConst(φ) ⊆ range(φ\*). That is,
every g ∈ FiberConst(φ) can be written as g = F ∘ φ for some
F ∈ C(Y, ℝ).

*Proof sketch.* Let Z = range(φ) ⊆ Y with the subspace topology.

1. **Define the lift.** For z ∈ Z, choose any x ∈ φ⁻¹({z}) and set
   h(z) = g(x). Fiber-constancy ensures this is independent of the
   choice.

2. **Prove continuity.** The corestriction X → Z is a quotient map
   (it is a continuous surjection from a compact space to a Hausdorff
   space, hence a closed map). Since h composed with this corestriction
   equals g (which is continuous), the quotient map property gives
   continuity of h.

3. **Extend to all of Y.** Since X is compact and Y is Hausdorff,
   Z = range(φ) is compact, hence closed in Y. By the Tietze extension
   theorem, h extends to F ∈ C(Y, ℝ). Then F ∘ φ = g.  □

**Corollary 3.2.** When φ is surjective, FiberConst(φ) = range(φ\*).
This is a descent theorem: fiber-constant functions on X correspond
exactly to functions on Y.

---

## 4. Density Transport

**Theorem 4.1** (Main theorem). Let A be a dense subalgebra of C(Y, ℝ).
Then

> closure({f ∘ φ : f ∈ A}) = FiberConst(φ)

in the uniform topology on C(X, ℝ).

*Proof.* The inclusion ⊆ follows from closedness of FiberConst(φ) and
the fact that all pullbacks are fiber-constant (closure of a subset of
a closed set is contained in the closed set).

For ⊇, let g ∈ FiberConst(φ). By Theorem 3.1, g = F ∘ φ for some
F ∈ C(Y, ℝ). Since A is dense, for any ε > 0 there exists a ∈ A with
‖a − F‖ < ε. Then a ∘ φ ∈ {f ∘ φ : f ∈ A} and

> ‖a ∘ φ − g‖ = ‖(a − F) ∘ φ‖ ≤ ‖a − F‖ < ε

by the norm-nonincreasing property of pullback. □

**Corollary 4.2** (Injective case). If φ is injective, then
closure({f ∘ φ : f ∈ A}) = C(X, ℝ).

**Corollary 4.3** (ε-approximation). For any g ∈ FiberConst(φ) and
ε > 0, there exists f ∈ A with ‖f ∘ φ − g‖ < ε. When φ is injective,
this holds for all g ∈ C(X, ℝ).

---

## 5. Applications

### 5.1 Neural Network Feature Embeddings

Consider a neural network architecture with an encoder φ : X → ℝ^d
mapping inputs to a d-dimensional representation, followed by a
function head h : ℝ^d → ℝ drawn from a dense class A. The composed
model h ∘ φ can approximate exactly FiberConst(φ).

**Practical consequence:** If the encoder φ is injective (i.e., it
preserves all information about inputs), the network can approximate
any continuous function. If φ collapses distinct inputs, there is an
irreducible approximation barrier for functions that distinguish
those inputs.

This gives a precise information-theoretic criterion for representation
quality: an encoder is universally good if and only if it is injective.

### 5.2 Invariant and Equivariant Learning

When φ encodes a symmetry (e.g., φ(x) = φ(gx) for a group action),
FiberConst(φ) is exactly the algebra of *invariant* functions. The
theorem then says: dense classes on the quotient space pull back to
dense classes among invariant functions.

This validates the common practice of building invariant features
first and then fitting functions—the resulting architecture can
approximate any invariant function, and only invariant functions.

### 5.3 Dimensionality Reduction

If φ : ℝ^n → ℝ^d with d < n, then φ is generically non-injective.
The theorem quantifies the approximation cost of dimensionality
reduction: only functions in FiberConst(φ) are achievable. This gives
a rigorous foundation for understanding the trade-off between
compression and expressiveness.

### 5.4 Transfer Learning

If models trained on domain Y (with dense class A) are applied to
domain X via a feature map φ : X → Y, the achievable approximation
on X is precisely FiberConst(φ). This explains why transfer learning
works well when the feature map preserves task-relevant distinctions
(injectivity on the support of the target function) and fails when
it does not.

---

## 6. Discussion: What the Telescope Can See

*A Scientific American-style discussion*

Imagine you are looking at a landscape through a telescope. The telescope
has a certain resolving power: it can distinguish two stars if they are
far enough apart, but if two stars appear at the same point in the
telescope's field of view, no amount of image processing can tell them
apart.

A feature map φ is like a telescope pointed at the input space X. Two
inputs x and x' that map to the same feature φ(x) = φ(x') are
"unresolvable"—they look identical through the lens of φ. Any function
computed from features alone must assign the same value to x and x'.

Our theorem makes this intuition precise and proves it is sharp:

- **What you CAN see:** Any pattern that depends only on features can
  be approximated arbitrarily well. These are the "fiber-constant"
  functions—they assign the same value to points with the same features.

- **What you CANNOT see:** Patterns that distinguish points with
  identical features are invisible through the telescope. No amount of
  post-processing (no matter how powerful the function class A is) can
  recover this lost information.

- **The dividing line:** FiberConst(φ) is the exact boundary between
  the learnable and the unlearnable.

This has profound implications for machine learning. When we train a
neural network, the early layers learn a feature map φ and the later
layers fit functions of those features. Our theorem says the bottleneck
is entirely in φ: if the features preserve all relevant distinctions
(injectivity), the network can learn anything. If features lose
information, there is a hard, mathematically proven limit on what
can be learned.

The classical Stone–Weierstrass theorem tells us *that* certain function
classes are universal. Our pullback theorem tells us *how* universality
transforms when we change coordinates—when we look through a different
telescope. It is a bridge theorem, connecting approximation theory on
one space to approximation theory on another.

Historically, approximation theory and representation theory developed
somewhat independently. Functions approximate; representations encode.
Our result unifies these perspectives: the quality of an approximation
scheme after a change of coordinates is entirely determined by the
fiber structure of the coordinate change. This is a topological
invariant—it depends on the *topology* of the map φ, not on its
analytic details.

The formal verification in Lean 4 provides a level of certainty
unusual in this area. Every step of the proof has been mechanically
checked, from the closedness of FiberConst to the Tietze extension
argument to the final ε-approximation. This is mathematics with a
certificate of correctness.

---

## 7. Formal Verification Details

The entire theorem package has been formalized in Lean 4 using the
Mathlib library (version 4.28.0). The formalization comprises
approximately 270 lines of Lean code in a single file
(`Catalog/EML/PullbackApprox/Basic.lean`), organized into four sections:

1. **Definitions and basic properties** (~80 lines): `FiberConst`,
   `pullbackAlg`, closedness, norm estimates, injectivity characterization.

2. **Image factorization** (~60 lines): quotient map property of the
   corestriction, `fiberConstLift`, Tietze extension argument.

3. **Density transport** (~40 lines): main closure equality theorem,
   injective corollary.

4. **ε-approximation** (~30 lines): quantitative corollaries.

Key Mathlib dependencies:
- `ContinuousMap` (continuous function algebra with sup norm)
- `Topology.IsQuotientMap` (quotient map characterization)
- `ContinuousMap.exists_extension` (Tietze extension theorem)
- `exists_continuous_zero_one_of_isClosed` (Urysohn's lemma)
- `Continuous.isClosedMap` (closed map lemma for compact→Hausdorff)

The proof uses only the standard axioms: `propext`, `Classical.choice`,
and `Quot.sound`.

### 7.1 Theorem Inventory

| Lean Name | Mathematical Statement |
|-----------|----------------------|
| `fiberConst_closed` | FiberConst(φ) is closed in C(X, ℝ) |
| `norm_pullback_le` | ‖φ\*f‖ ≤ ‖f‖ |
| `pullback_isometry_of_surjective` | ‖φ\*f‖ = ‖f‖ when φ is surjective |
| `fiberConst_eq_top_iff_injective` | FiberConst(φ) = ⊤ ↔ φ is injective |
| `fiberConst_subset_range_pullback` | FiberConst(φ) ⊆ range(φ\*) |
| `fiberConst_eq_range_pullback_of_surjective` | FiberConst(φ) = range(φ\*) when φ is surjective |
| `closure_range_pullback_eq_fiberConst` | closure(φ\*(A)) = FiberConst(φ) |
| `closure_range_pullback_eq_top_of_injective` | closure(φ\*(A)) = C(X,ℝ) when φ is injective |
| `exists_pullback_approx_of_fiberConst` | ε-approximation in FiberConst(φ) |
| `exists_pullback_approx_of_injective` | ε-approximation in all of C(X,ℝ) when φ is injective |

---

## 8. Future Directions

1. **Quantitative rates.** What is the modulus of approximation? If A
   has a known approximation rate (e.g., Jackson-type theorems for
   polynomials), what is the inherited rate on FiberConst(φ)?

2. **Equivariant extensions.** Extend to vector-valued functions and
   equivariant maps, connecting to representation theory of groups
   acting on X and Y.

3. **Infinite-dimensional targets.** Replace ℝ by a Banach space or
   even a topological algebra.

4. **Non-compact domains.** Extend to locally compact spaces using
   vanishing-at-infinity functions and one-point compactification.

5. **Measurable category.** Replace continuous functions by L^p spaces
   and continuous maps by measurable maps, connecting to ergodic
   theory and measure-preserving dynamics.

6. **Computational complexity.** Given computational constraints on the
   approximants in A, how does the complexity transfer through φ?
   This connects to circuit complexity and depth-efficiency questions
   in neural network theory.

---

## References

1. M.H. Stone, "The generalized Weierstrass approximation theorem,"
   *Mathematics Magazine* 21 (1948), 167–184.

2. G.B. Folland, *Real Analysis: Modern Techniques and Their
   Applications*, 2nd ed., Wiley, 1999.

3. K. Hornik, M. Stinchcombe, H. White, "Multilayer feedforward
   networks are universal approximators," *Neural Networks* 2 (1989),
   359–366.

4. The Mathlib Community, "Mathlib: a unified library of mathematics
   formalized in Lean," 2020–present.
   https://github.com/leanprover-community/mathlib4
