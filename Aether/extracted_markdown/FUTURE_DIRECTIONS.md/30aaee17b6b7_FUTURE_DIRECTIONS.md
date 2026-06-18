# Future Directions: PL Hodge Theory for Neural Networks

## 1. Tight Zaslavsky Bounds via Arrangement Matroid Theory

The current `zaslavsky_type_bound` proves ∑_{k≤d} C(n,k) ≤ (n+1)^d, but the
classical Zaslavsky theorem gives the *exact* count of regions as the characteristic
polynomial of the arrangement's matroid evaluated at 1. For a ReLU network with
generic weights, the arrangement matroid is the uniform matroid U_{d,n}, and the
region count equals ∑_{k≤d} C(n,k) exactly.

**Conjecture**: For a ReLU network with algebraically independent weights, the
number of linear regions equals ∑_{k≤d} C(N,k) where d is the input dimension
and N the total neuron count.

The key insight is that "generic" weights correspond to the uniform matroid, and
the Zaslavsky formula specializes to the binomial sum. A non-generic arrangement
(degenerate weights) has strictly fewer regions, bounded by the Tutte polynomial.

**Why now?** Mathlib has matroids (`Matroid.Basic`) and characteristic polynomials.
Connecting these to the arrangement region count via the Zaslavsky formula would
be a genuine formalization achievement — the classical proof uses deletion-contraction
on the matroid, which aligns perfectly with Mathlib's matroid API.

## 2. Higher-Dimensional PL Hodge Numbers via Persistent Homology

The current formalization works with 2-term chain complexes (β₀ and β₁). Extending
to full n-term chain complexes would give Betti numbers β_k for all k, with the
bound β_k ≤ f_k ≤ C(N,k). The deeper question: for a fixed network architecture,
which Betti number vectors (β₀, β₁, ..., β_d) are *achievable*?

**Conjecture**: For a ReLU network with depth L and uniform width w in ℝ^d, the
achievable Betti vectors form a polytope P(L,w,d) ⊂ ℝ^{d+1} with vertices at
the "extremal" configurations (maximum β_k for a single k, zero for others).

The key insight is that the face vector (f₀, f₁, ..., f_d) satisfies the
Dehn-Sommerville relations for the polyhedral complex, and these linear constraints
on face vectors translate to constraints on Betti vectors via the universal
coefficient theorem.

**Why now?** The `betti_rank_nullity` theorem provides the exact formula β₁ = f₁ - rank(∂).
Extending this to a full chain complex and computing the rank of each boundary map
would give all Betti numbers. Mathlib's `HomologicalComplex` provides the categorical
framework; what's needed is the connection to finite polyhedral combinatorics.

## 3. Tropical Hodge Theory: Weight Filtrations on Decision Boundaries

Classical Hodge theory decomposes cohomology via the (p,q)-decomposition. For
tropical varieties (which ReLU network decision boundaries are), there is an
analogous "tropical Hodge theory" due to Itenberg-Katzarkov-Mikhalkin-Zharkov
where the Hodge filtration comes from a weight filtration on the tropical homology.

**Conjecture**: For a ReLU network with L layers, the weight filtration on the
tropical homology of the decision boundary has at most L non-trivial graded pieces.
Each graded piece W_k/W_{k-1} has rank ≤ ∏_{i=1}^{L} C(w_i, k).

The key insight is that each layer of the network contributes one step of the
weight filtration. The tropical Hodge-to-de Rham spectral sequence degenerates
at E₁ for PL varieties, making the weight filtration computable from the
combinatorial data of the polyhedral complex.

**Why now?** The `PLComplex` structure defined here, combined with the existing
tropical algebra from `NeuralDecisionBoundary.Core`, provides the foundation.
The weight filtration can be defined as a sequence of submodules of the chain
groups, one per network layer.

## 4. VC Dimension Bounds from Tropical Degree

The `product_face_bound` gives an upper bound on regions in terms of total
neuron count. The VC dimension of a ReLU network is known to be Θ(WL) where
W is the total number of parameters and L is the depth. But the connection
between VC dimension and the tropical degree (the degree of the tropical
polynomial representing the network output) is not formalized.

**Conjecture**: For a ReLU network f, the VC dimension of the classifier
sign(f) equals the tropical degree of f, which equals the number of linear
pieces of f minus 1.

The key insight is that each linear piece of f corresponds to a distinct
labeling of training points, and the VC dimension counts the maximum number
of points that can be shattered — which is exactly the number of distinct
sign patterns achievable by the linear pieces.

**Why now?** The `zaslavsky_type_bound` and `product_face_bound` theorems
provide the combinatorial bounds. Formalizing the VC dimension (which Mathlib
lacks) and connecting it to the tropical degree would bridge learning theory
and algebraic geometry in a machine-verified way.

## 5. Effective PL Hodge Decomposition via Smith Normal Form

The `betti_rank_nullity` theorem shows β₁ = f₁ - rank(∂), but computing rank(∂)
for a specific network requires computing the Smith normal form of the boundary
matrix (over ℤ). For ℚ-coefficients, this reduces to Gaussian elimination.

**Conjecture**: There exists a polynomial-time algorithm that, given a ReLU
network with rational weights, computes all Betti numbers of its decision
boundary. The running time is O(N^ω) where N is the total neuron count and
ω is the matrix multiplication exponent.

The key insight is that the boundary matrices of the polyhedral complex are
sparse (each cell has at most d+1 faces), so the Smith normal form computation
can exploit sparsity. For ℚ-coefficients, the Betti numbers equal the nullities
of the boundary matrices, computable by Gaussian elimination.

**Why now?** Mathlib has `Matrix.rank` and Gaussian elimination over fields.
The missing piece is connecting the abstract chain complex to concrete matrices
whose entries are determined by the network weights, and proving that the
resulting computation is correct.
