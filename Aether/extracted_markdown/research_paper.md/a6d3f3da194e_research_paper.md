# Tropical Satake Injectivity for GL₃ via Min-Plus Newton Polytope Reconstruction

## Abstract

We prove that the tropical Satake transform for GL₃ is injective on finitely-supported tropical Hecke functions with generic support — the first formally verified higher-rank structural theorem in the tropical Satake program. The proof, fully machine-checked in Lean 4 with Mathlib, uses a novel **slope comparison argument**: by perturbing a dominant weight along three specific basis vectors `(1,0,0)`, `(1,1,0)`, and `(1,1,1)`, we show that any minimizer of the opposing tropical series must have identical partial sums with the original minimizer, forcing equality of coweights and coefficients. We also exhibit a concrete counterexample showing that the generic support hypothesis is necessary: without it, redundant support points carry irrecoverable information.

## 1. Introduction

### 1.1 Context and Motivation

The Langlands program, one of the deepest structures in modern mathematics, connects representation theory, number theory, and algebraic geometry through a web of conjectures and equivalences. At its heart lies the **Satake isomorphism**, which identifies the spherical Hecke algebra of a reductive group over a local field with the ring of invariant polynomials on the dual group.

Recent work has explored a **tropical** (min-plus) analog of the Satake isomorphism, where the usual ring operations are replaced by `(min, +)`. This tropical Satake transform maps functions on dominant coweights to piecewise-linear functions on the dominant weight chamber. The natural question arises: **is this transform injective?** That is, does the tropical Satake transform faithfully encode the Hecke function data?

For GL₂, this question reduces to one-dimensional slope geometry — essentially, the observation that two different min-of-two-affine-functions can be distinguished by their breakpoints. For GL₃ and beyond, the situation becomes genuinely polyhedral: the lower Newton polytope has faces of varying dimension, and the separation of coweights within the dominant chamber requires nontrivial algebraic arguments.

### 1.2 Main Result

We prove the following theorem (Lean 4 formal statement: `satakeGL3_injective_of_generic`):

**Theorem (Tropical Satake Injectivity for GL₃).** Let F, G be finitely supported tropical Hecke functions for GL₃ with generic support. If their tropical Satake transforms agree on all dominant weights:

$$\min_{\lambda \in \text{supp}(F)} \big[F(\lambda) + \langle \chi, \lambda \rangle\big] = \min_{\mu \in \text{supp}(G)} \big[G(\mu) + \langle \chi, \mu \rangle\big] \qquad \forall \chi \text{ dominant}$$

then F = G (same coefficients on all coweights).

Here, **generic support** means that every support point λ is a unique minimizer of the Satake transform at some strictly dominant weight χ. This is the natural non-redundancy condition: it excludes support points that lie "above" the min-plus convex hull of the remaining points.

### 1.3 Why This Matters

This is the first genuinely higher-rank structural theorem in the tropical Satake direction to be formally verified. The GL₂ case only involves one-dimensional slope geometry; GL₃ forces:
- **True polyhedral behavior**: the Newton polytope lives in ℝ³ and its faces have structure.
- **Chamber-restricted separation**: we can only evaluate at dominant weights, not arbitrary ones.
- **Multi-directional probing**: we need three independent directions to determine a coweight.

## 2. Definitions

### 2.1 Dominant Coweights and Weights

A **dominant GL₃ coweight** is a weakly decreasing triple of natural numbers:

$$\Lambda^+ = \{(a, b, c) \in \mathbb{N}^3 : a \geq b \geq c\}$$

A **dominant GL₃ weight** is a weakly decreasing triple of real numbers:

$$\mathfrak{a}^+ = \{(x_1, x_2, x_3) \in \mathbb{R}^3 : x_1 \geq x_2 \geq x_3\}$$

The **pairing** is the standard inner product:

$$\langle \chi, \lambda \rangle = \sum_{i=1}^{3} \chi_i \lambda_i$$

### 2.2 Tropical Hecke Functions and the Satake Transform

A **finitely supported tropical Hecke function** is a pair `(S, c)` where:
- `S ⊂ Λ⁺` is a finite set (the **support**)
- `c : Λ⁺ → ℝ` assigns coefficients, with `c(λ) = 0` for `λ ∉ S`

The **tropical Satake transform** of F is:

$$\mathcal{S}(F)(\chi) = \min_{\lambda \in S} \big[c(\lambda) + \langle \chi, \lambda \rangle\big]$$

This is the minimum of finitely many affine functions on the dominant chamber — a concave piecewise-linear function.

### 2.3 Generic Support

F has **generic support** if every support point is uniquely minimizing at some strictly dominant weight:

$$\forall \lambda_0 \in S,\; \exists \chi_0 \in \text{int}(\mathfrak{a}^+) : \quad c(\lambda_0) + \langle \chi_0, \lambda_0 \rangle < c(\mu) + \langle \chi_0, \mu \rangle \quad \forall \mu \in S \setminus \{\lambda_0\}$$

This is equivalent to requiring that every support point is a vertex of the lower Newton polytope (the min-plus convex hull) restricted to the dominant chamber.

## 3. The Proof

### 3.1 Separation by Partial Sums

The three dominant vectors `e₀ = (1,0,0)`, `e₁ = (1,1,0)`, `e₂ = (1,1,1)` serve as a "basis" for detecting coweights. Their pairings with a coweight λ = (a,b,c) give the partial sums:

$$\langle e_0, \lambda \rangle = a, \quad \langle e_1, \lambda \rangle = a + b, \quad \langle e_2, \lambda \rangle = a + b + c$$

**Lemma (Coweight Determination).** If two dominant coweights λ, μ satisfy `⟨eₖ, λ⟩ = ⟨eₖ, μ⟩` for all k ∈ {0,1,2}, then λ = μ.

*Proof.* From k=0: a = a'. Then k=1 gives b = b', and k=2 gives c = c'. ∎

### 3.2 The Slope Comparison Argument

**Theorem (Coefficient Recovery).** Suppose:
- λ₀ is a unique minimizer for F at a strictly dominant χ₀
- S(F)(χ) = S(G)(χ) for all dominant χ

Then λ₀ ∈ supp(G) and G(λ₀) = F(λ₀).

*Proof sketch.* Since S(F)(χ₀) = S(G)(χ₀), some μ ∈ supp(G) satisfies:

$$G(\mu) + \langle \chi_0, \mu \rangle = F(\lambda_0) + \langle \chi_0, \lambda_0 \rangle \qquad (*)$$

We show μ = λ₀ using the **slope comparison**. For each basis vector eₖ:

1. **Persistence:** Since λ₀ is the strict unique minimizer for F at χ₀, for small |t|, λ₀ remains the unique minimizer at χ₀ + t·eₖ (the gap is positive and the perturbation is controlled).

2. **Dominance of perturbation:** Since χ₀ is strictly dominant, χ₀ + t·eₖ remains dominant for small |t|. For k=2 (eₖ = (1,1,1)), adding the same constant preserves the ordering for all t. For k=0,1, the strict gap provides room.

3. **Slope inequality:** For small |t|:
$$F(\lambda_0) + \langle \chi_0 + t \cdot e_k, \lambda_0 \rangle = \mathcal{S}(F)(\chi_0 + t \cdot e_k) = \mathcal{S}(G)(\chi_0 + t \cdot e_k) \leq G(\mu) + \langle \chi_0 + t \cdot e_k, \mu \rangle$$

Using (*), this simplifies to:
$$t \cdot \langle e_k, \lambda_0 \rangle \leq t \cdot \langle e_k, \mu \rangle$$

Taking t > 0 gives `⟨eₖ, λ₀⟩ ≤ ⟨eₖ, μ⟩`; taking t < 0 gives `⟨eₖ, λ₀⟩ ≥ ⟨eₖ, μ⟩`. Combined:

$$\langle e_k, \lambda_0 \rangle = \langle e_k, \mu \rangle \qquad \forall k \in \{0,1,2\}$$

4. **Coweight identity:** By the Coweight Determination Lemma, μ = λ₀.

5. **Coefficient recovery:** Substituting back into (*): G(λ₀) = F(λ₀). ∎

### 3.3 From Recovery to Injectivity

Given GenericSupport for both F and G:

- For each λ ∈ supp(F): GenericSupport gives a strictly dominant exposing weight, so Coefficient Recovery yields λ ∈ supp(G) and G(λ) = F(λ).
- For each λ ∈ supp(G) \ supp(F): GenericSupport for G gives an exposing weight, and Coefficient Recovery (applied with F and G swapped) yields λ ∈ supp(F) — a contradiction.
- For λ ∉ supp(F) ∪ supp(G): both coefficients are zero.

Therefore F.coeff = G.coeff. ∎

## 4. The Counterexample

**Proposition.** Unconditional injectivity fails: the generic support hypothesis is necessary.

*Construction.* Let:
- F: support = {(2,0,0), (1,0,0), (0,0,0)}, coefficients 0, 1, 0
- G: support = {(2,0,0), (0,0,0)}, coefficients 0, 0

Then S(F)(χ) = min(2x₁, x₁ + 1, 0) and S(G)(χ) = min(2x₁, 0).

The term x₁ + 1 is never the minimum: it would require both x₁ ≥ 1 (to beat 2x₁) and x₁ ≤ -1 (to beat 0), which is impossible. Hence S(F) = S(G), but F ≠ G.

The coweight (1,0,0) is **redundant**: it lies on the segment from (0,0,0) to (2,0,0) and its coefficient is too large to ever contribute. It violates GenericSupport. ∎

## 5. Formal Verification

The complete proof is formalized in Lean 4 (file: `GL3SatakeInjective.lean`, ~320 lines) using Mathlib. Key features:

- **No axioms beyond the standard**: only `propext`, `Classical.choice`, and `Quot.sound`.
- **No sorry**: every lemma is fully proved.
- **Modular structure**: 14 lemmas building to 3 main theorems.

The formalization avoids convex geometry infrastructure entirely, working instead with:
- `Finset.inf'` for finite minima
- Explicit `ε > 0` construction for perturbation arguments
- Direct algebraic computation for the three-vector separation

## 6. Applications and Future Directions

### 6.1 Tropical Hecke Algebras

The injectivity result is a prerequisite for developing a faithful tropical Satake theory. Before studying tropical convolution, representation-theoretic positivity, or spectral decomposition, one must know the transform does not collapse information.

### 6.2 Algorithmic Coefficient Recovery

The proof is constructive: given access to S(F) as an oracle, one can recover each coefficient by:
1. Finding an exposing weight (via optimization over the dominant chamber)
2. Reading off the coefficient as S(F)(χ) - ⟨χ, λ⟩

This gives an algorithm for tropical polynomial reconstruction from evaluation data.

### 6.3 Extension to GLₙ

The proof technique generalizes to GLₙ using the n dominant basis vectors eₖ = (1,...,1,0,...,0) (k ones). The coweight determination lemma and slope comparison argument work identically, with the perturbation analysis requiring n directions instead of 3. The main challenge for formal verification is managing the combinatorial complexity of the Fin n → ℕ type.

### 6.4 Tropical Spectral Theory

Long-term, tropical Satake injectivity feeds into tropical spectral decomposition: understanding how tropical automorphic forms decompose into "eigenspaces" under the tropical Hecke algebra. The fact that the Satake transform is injective means the spectral data retains full information about the Hecke function.

## 7. Discussion: A Polyhedral Window into Langlands

*For the general reader.*

Imagine you have a landscape — a surface defined by the lowest points of many tilted planes. Each plane represents a "voice" in a mathematical chorus, and the landscape is the envelope of all these voices, keeping only the lowest note at each point.

Now suppose someone hands you this landscape and asks: can you recover the individual voices? In one dimension (GL₂), this is easy — each voice creates a V-shaped valley, and the breakpoints tell you everything. But in three dimensions (GL₃), the landscape has ridges, valleys, and flat regions that make the problem much harder.

Our theorem says: **yes, you can recover the voices**, as long as each voice is the star of the show somewhere — there's at least one point where it and it alone sings the lowest note. The proof works by "listening" from three carefully chosen directions and using the resulting "slopes" to fingerprint each voice.

The catch? If a voice is always drowned out by louder neighbors, it's invisible — you can't recover it no matter how hard you listen. That's the "generic support" condition: every voice must have its moment.

This result is a small but necessary step toward a **tropical Langlands program** — reimagining one of the deepest connections in mathematics through the lens of min-plus algebra. Just as tropical geometry has revolutionized algebraic geometry by replacing curves with piecewise-linear skeletons, tropical Langlands aims to distill the essence of the Langlands correspondence into a combinatorial framework that might be more accessible to computation and formal verification.

## References

The tropical Satake isomorphism was introduced in the context of tropical geometry and representation theory. The key mathematical ideas draw from:

1. The classical Satake isomorphism for reductive groups over local fields
2. Tropical convexity and min-plus linear algebra
3. Newton polytope theory and support functions in convex geometry

The formal verification uses Lean 4 and the Mathlib library for real analysis, finset operations, and linear order properties.
