# Future Directions: Spectral Universality of Proof Graphs

## 1. Cheeger Inequality for Finite Simple Graphs

Formalize the discrete Cheeger inequality relating the vertex expansion constant h(G)
to the spectral gap λ₂ of the normalized Laplacian: λ₂/2 ≤ h(G) ≤ √(2λ₂). This
would require formalizing the normalized Laplacian matrix of a finite graph and its
eigenvalues in Lean/Mathlib, then proving the classical Alon-Milman / Dodziuk
inequality.

The key insight is that the vertex boundary machinery developed here (vertexBoundary,
monotonicity, connectivity characterization) provides exactly the combinatorial side
of the Cheeger inequality — what remains is connecting it to the algebraic
(eigenvalue) side.

Why now? Mathlib's linear algebra and matrix theory has matured enough that eigenvalue
computations for symmetric matrices over ℝ are becoming feasible. The combinatorial
infrastructure in Cheeger.lean eliminates half the work.

## 2. Spectral Gap Scaling Laws for Random Graph Families

Formalize the Erdős-Rényi phase transition: for G(n, p) with p = c/n, prove that
the expected vertex expansion transitions from 0 (c < 1, disconnected w.h.p.) to
positive (c > 1, giant component has expansion). This would formalize the connection
between edge density thresholds and expansion phase transitions.

The key insight is that `connected_iff_vertexBoundary_nonempty` converts the
connectivity phase transition of G(n,p) directly into an expansion phase transition,
and the monotonicity theorem `vertexBoundary_mono` ensures that adding edges can only
improve expansion.

Why now? The monotonicity and connectivity-expansion equivalence are now proven, so
the combinatorial framework is ready. The probabilistic component (concentration
inequalities for random graphs) is the main remaining challenge.

## 3. Vertex Expansion under Graph Products

Formalize how vertex expansion behaves under standard graph products (Cartesian,
tensor, lexicographic). For the Cartesian product G □ H, the vertex expansion
satisfies h(G □ H) ≥ min(h(G), h(H)). This would model how composing proof
libraries (which corresponds to graph products on dependency structures) preserves
or degrades expansion.

The key insight is that the monotonicity theorem `vertexBoundary_mono` already
captures one direction (adding edges helps), but graph products introduce new
vertices, requiring a fundamentally different analysis. The product expansion
inequality is non-trivial and connects to the tensor product conjecture in
spectral graph theory.

Why now? The vertex boundary definition is product-friendly (defined via neighbor
sets), and Mathlib has good support for product types and Finset operations on
products. The infrastructure gap is small.

## 4. Proof-Theoretic Strength Stratification

Formalize the conjecture that dependency graphs of proof libraries naturally
stratify by proof-theoretic strength. Specifically: define a "strength homomorphism"
from a proof graph to ordinals, where the strength function is monotone with respect
to the dependency order. Prove that the existence of such a homomorphism constrains
the Cheeger constant — graphs admitting strength homomorphisms to small ordinals
have bounded expansion.

The key insight is that a monotone strength function partitions the vertex set into
level sets, and the vertex boundary between consecutive levels is constrained by the
ordinal structure. This creates a formal bridge between proof-theoretic ordinals and
graph expansion.

Why now? The `ProofGraph` structure with its strength function is already defined.
The next step is formalizing the monotonicity constraint and deriving expansion
bounds from the level-set structure.

## 5. Algorithmic Expansion Testing via Boundary Computation

Formalize decidability and complexity of computing the Cheeger constant for finite
graphs. The Cheeger constant is NP-hard to compute exactly (by reduction from
bisection width), but can be approximated via spectral methods. Formalize the
2-approximation: prove that the sweep-cut algorithm on the Fiedler vector produces
a set S with h(S) ≤ √(2λ₂), where λ₂ is the spectral gap.

The key insight is that `vertexBoundary` is already computable (defined via
Finset.filter), so the Cheeger constant is computable by enumeration. The
approximation algorithm would connect the spectral and combinatorial definitions
in a constructive way.

Why now? All definitions in Cheeger.lean are computable (they use DecidableRel and
Finset), so the exact computation is already possible. The approximation algorithm
requires only the Cheeger inequality from Direction 1.
