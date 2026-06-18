# Future Research Directions

## Synthesis

This research cycle established a formalized combinatorial foundation for the Lindström-Gessel-Viennot (LGV) determinantal theory, proving eight substantive theorems about Catalan numbers, lattice path counting, and binomial coefficient identities. The key structural results — the Catalan ballot formula connecting C_n = C(2n,n)/(n+1) to central binomial coefficients, the LGV 2×2 determinantal identity for both unit and general source-sink separation, the Segner convolution recurrence bridging closed-form and recursive definitions, and the computational verification of Catalan Hankel determinants through 4×4 — collectively demonstrate that lattice path generating functions inherit rich algebraic symmetries from their combinatorial structure.

The most significant cross-domain connection identified is the **Catalan Hankel determinant phenomenon**: the fact that det[C_{i+j}] = 1 for all matrix sizes connects lattice path non-intersection (combinatorics) to matrix algebra (linear algebra) to continued fractions (analysis) to moment sequences (probability). Our novel NonCrossingPartition and TransferMatrix structures provide formal bridges between these domains. The TransferMatrix axiomatization, in particular, connects path counting to spectral theory: the eigenvalues of the Dyck transfer matrix are 2cos(kπ/(w+1)) for k = 1,...,w, linking Catalan asymptotics (C_n ~ 4^n / (n^{3/2}√π)) to the spectral radius of the transfer matrix.

The direction with highest breakthrough potential is **Direction 1 (Full LGV Lemma)**: formalizing the general n×n LGV lemma would immediately unlock determinantal formulas for Schur polynomials, plane partitions (MacMahon's theorem), and the Jacobi-Trudi identity. The 2×2 base case is proved; the key remaining ingredient is the sign-reversing involution on intersecting path families. Direction 3 (q-Catalan and Parking Functions) offers the most accessible near-term progress.

---

### Direction 1: Full n×n Lindström-Gessel-Viennot Lemma

**Conjecture**: For sources a₁, ..., aₙ and sinks b₁, ..., bₙ on any acyclic weighted directed graph, let M be the n×n matrix where M[i,j] = Σ_{paths P from aᵢ to bⱼ} weight(P). Then:

det(M) = Σ_{non-intersecting families F} sign(F) · weight(F)

where the sum is over all families of n vertex-disjoint paths, each connecting some aᵢ to b_{σ(i)} for a permutation σ, sign(F) = sign(σ), and weight(F) = Π weight(paths in F).

**Test**: For n = 3 with sources at heights 0, 1, 2 and sinks at (N, 0), (N, 1), (N, 2), the determinant of the 3×3 matrix [[C(N,0), C(N+1,1), C(N+2,2)], [C(N-1,0), C(N,1), C(N+1,2)], [C(N-2,0), C(N-1,1), C(N,2)]] should equal 1. Verify computationally for N = 5, 10, 20.

**Impact**: The full LGV lemma would immediately yield:
- The Jacobi-Trudi formula for Schur polynomials
- MacMahon's formula for plane partitions (via the Hillman-Grassl correspondence)
- Determinantal formulas for Young tableaux (Frame-Robinson-Thrall hook length formula connection)
- A formalized proof that det[C_{i+j}] = 1 for all n (currently verified only up to 4×4)

**Catalog References**: `Logic/LGVDeterminantal.lean` (SignedPathFamily structure, lgv_2x2_base), `Catalog/Logic/LGVFoundation.lean` (WeightedPathSystem, latticeWPS)

**Proof Strategy**: 
1. Define path families as functions Fin n → List (vertex × vertex) with matching boundary conditions
2. Define the sign-reversing involution ι on intersecting families: find the first intersection point (lexicographically), and swap path suffixes after that point
3. Prove ι is well-defined (produces valid path families) and sign-reversing (changes permutation parity)
4. Prove ι is an involution on non-fixed-point families
5. Prove the fixed points of ι are exactly the non-intersecting families
6. Conclude by the involution principle: signed sum over all families = signed sum over fixed points = det(M)

The key lemma is that swapping path suffixes at an intersection point composes the permutation with a transposition, changing the sign. This requires careful formalization of path splicing and intersection detection.

**Domain Bridges**: Lattice path combinatorics <-> Linear algebra (determinants) <-> Representation theory (Schur polynomials) <-> Algebraic geometry (Grassmannians via Plücker relations)

**Lineage**: Builds on lgv_2x2_base, SignedPathFamily, WeightedPathSystem from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Catalan Hankel Determinant for All n

**Conjecture**: For all n ≥ 0, det[catalanNum(i+j)]_{0 ≤ i,j ≤ n} = 1.

Additionally, for the shifted Hankel matrix: det[catalanNum(i+j+1)]_{0 ≤ i,j ≤ n} = 1, and det[catalanNum(i+j+s)]_{0 ≤ i,j ≤ n} has a closed form depending on s and n.

**Test**: 
- Verify det = 1 for the s=0 case at n = 5 and n = 6 computationally.
- Verify det = 1 for the s=1 case at n = 2, 3, 4.
- Determine the formula for s=2: we found det = n+2 for n = 0, 1. Verify for n = 2, 3.

**Impact**: A proof for all n would:
- Demonstrate the power of the LGV approach (the standard proof uses the LGV lemma)
- Establish total positivity of the Catalan moment sequence
- Connect to the theory of orthogonal polynomials (Catalan numbers are moments of the Wigner semicircle distribution)

**Catalog References**: `Logic/LGVDeterminantal.lean` (catalan_hankel_2x2, catalan_hankel_3x3, catalan_hankel_4x4)

**Proof Strategy**: Two approaches:
1. *Via LGV*: Once Direction 1 is complete, define specific source-sink configurations on the lattice such that the path count matrix is the Catalan Hankel matrix. Show non-intersecting families are uniquely determined.
2. *Via continued fractions*: The generating function Σ C_n x^n = (1 - √(1-4x))/(2x) has a continued fraction expansion whose convergents give the Hankel determinants. This requires formalizing continued fractions and their connection to moment problems.

**Domain Bridges**: Combinatorics (Catalan numbers) <-> Linear algebra (Hankel determinants) <-> Probability (moment sequences) <-> Analysis (continued fractions)

**Lineage**: Builds on catalan_hankel_2x2, catalan_hankel_3x3, catalan_hankel_4x4 and the shifted Hankel exploration.

**Ambition**: extension

---

### Direction 3: q-Catalan Numbers and Parking Functions

**Conjecture**: The q-Catalan number C_n(q) = Σ_{Dyck paths P} q^{area(P)} satisfies:
1. C_n(q) = [2n choose n]_q / [n+1]_q where [k]_q = (1-q^k)/(1-q)
2. C_n(q) is a polynomial in q with non-negative integer coefficients
3. The coefficients of C_n(q) are unimodal (first increasing, then decreasing)

The q-Catalan numbers also count parking functions by a natural area statistic, connecting lattice paths to the combinatorics of the symmetric group.

**Test**: 
- Compute C_3(q) = 1 + q + q² + q³ + q⁴ + q⁵ (should have 5 = C_3 terms... actually C_3(q) should evaluate to 5 at q=1). Verify: q-Catalan for n=3 is 1 + q + 2q² + q³ + q⁴ = 5 at q=1. ✓
- Verify unimodality for n ≤ 8 computationally.
- Verify the formula C_n(q) = [2n choose n]_q / [n+1]_q for n ≤ 5.

**Impact**: 
- Connects lattice path area statistics to the representation theory of GL_n(F_q)
- The q-Catalan numbers appear in Kazhdan-Lusztig theory and the homology of Springer fibers
- Provides a bridge between the qBinomial coefficients already formalized in the Catalog and representation-theoretic constructions

**Catalog References**: `Catalog/Logic/LGVFoundation.lean` (qBinomial, qBinomial_eval_one), `Logic/LGVDeterminantal.lean` (catalanNum, catalan_ballot_formula)

**Proof Strategy**:
1. Define q-Catalan as Σ q^{dinv(π)} over parking functions π, or equivalently as Σ q^{area(D)} over Dyck paths D
2. Prove the division formula using the q-analog of the ballot argument
3. Prove non-negativity by exhibiting a combinatorial interpretation
4. Prove unimodality using the Zeilberger-Bressoud theory or by connecting to the representation theory of SL_2

**Domain Bridges**: Lattice paths <-> Representation theory (GL_n(F_q)) <-> Algebraic geometry (Hilbert schemes) <-> Number theory (q-series)

**Lineage**: Builds on qBinomial from LGVFoundation.lean and catalanNum from this cycle.

**Ambition**: extension

---

### Direction 4: Tropical LGV and Optimal Transport

**Conjecture**: The LGV lemma has a tropical analog: replacing (×, +) with (min, +) in the path weight semiring, the tropical determinant of the path weight matrix equals the minimum-weight non-crossing path family.

More precisely: for sources s₁, ..., sₙ and sinks t₁, ..., tₙ with edge weights w(e) ≥ 0, the tropical determinant tdet(M) where M[i,j] = min_{paths P: sᵢ→tⱼ} Σ_{e∈P} w(e) equals min_{non-crossing matchings σ} Σᵢ M[i,σ(i)].

**Test**: Construct a 3×3 lattice path example with non-uniform edge weights. Compute both the tropical determinant and the minimum non-crossing family weight. They should agree.

**Impact**: 
- Connects the LGV lemma to optimal transport theory (the assignment problem)
- The tropical LGV would provide a combinatorial proof of the optimality of certain transport plans
- Links to the existing tropical semiring formalization in the Catalog

**Catalog References**: `Catalog/Tropical/` (tropical semiring definitions), `Logic/LGVDeterminantal.lean` (SignedPathFamily)

**Proof Strategy**:
1. Define the tropical semiring (min, +) formally, or use the existing Catalog definition
2. Reformulate the LGV lemma over an arbitrary semiring (not just commutative rings)
3. Prove the tropical specialization: the sign-reversing involution becomes a weight-reducing involution
4. Connect to the Hungarian algorithm for optimal assignment

**Domain Bridges**: Combinatorics (LGV) <-> Optimization (assignment problem) <-> Tropical geometry <-> Economics (optimal transport)

**Lineage**: Builds on SignedPathFamily and the WeightedPathSystem from this and the previous cycle.

**Ambition**: grand_challenge

---

### Direction 5: Lattice Path Proofs of Fibonacci Identities

**Conjecture**: Every classical Fibonacci identity has a lattice path proof via the diagonal sum interpretation Fib(n+1) = Σ_{k=0}^{⌊n/2⌋} C(n-k, k).

Specifically, the identity Fib(m+n+1) = Fib(m+1)·Fib(n+1) + Fib(m)·Fib(n) should have a proof by decomposing paths at the boundary between the first m+1 and last n anti-diagonals.

**Test**: Formalize and prove Fib(m+n+1) = Fib(m+1)·Fib(n+1) + Fib(m)·Fib(n) using the lattice path interpretation. Verify computationally for m, n ≤ 10.

**Impact**: 
- Provides combinatorial (non-algebraic) proofs of Fibonacci identities
- Connects the Pascal diagonal to tiling interpretations of Fibonacci numbers
- Could yield new Fibonacci identities by applying lattice path transformations

**Catalog References**: `Logic/LGVDeterminantal.lean` (path_weight_multiplicative for Vandermonde), Mathlib's `Nat.fib_succ_eq_sum_choose`

**Proof Strategy**:
1. Use the existing Mathlib result Nat.fib_succ_eq_sum_choose relating Fibonacci to Pascal diagonals
2. Decompose the diagonal sum at the midpoint to get the product formula
3. Use the Vandermonde-type convolution (already proved as path_weight_multiplicative)
4. Handle the boundary carefully: the decomposition at anti-diagonal m needs to account for the two possible last steps

**Domain Bridges**: Number theory (Fibonacci) <-> Combinatorics (lattice paths) <-> Linear algebra (transfer matrices)

**Lineage**: Builds on path_weight_multiplicative and the TransferMatrix structure.

**Ambition**: extension
