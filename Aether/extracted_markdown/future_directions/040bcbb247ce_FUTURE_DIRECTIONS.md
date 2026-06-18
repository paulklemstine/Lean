# Future Research Directions

## Synthesis

This research cycle established a formal oracle hierarchy for L-functions and proved that conductor arithmetic enables integer factoring via GCD extraction. The key discovery is that different types of L-function data (point values, derivatives, zero certificates) carry genuinely different computational power, forming a strict hierarchy with cryptographic implications.

The most promising cross-domain connection is between the **conductor factoring mechanism** and the **Selberg class census** from the existing catalog (`MachineLearning/LFunctionCensus`). The census framework counts L-functions by degree, conductor, and spectral parameters, while the factoring results show that conductor data is the critical bridge between L-function theory and integer factoring. Combining these gives a precise prediction: the number of L-functions that provide useful factoring data for a given semiprime n is controlled by the conductor counting function N_d(Q, B). This connection has the highest breakthrough potential because it translates an abstract counting problem into concrete cryptographic consequences.

The oracle separation results (point oracle cannot determine vanishing order) connect to the barrier theorem framework in `Computation/BarrierFramework.lean` and the information-theoretic lower bounds in `Cryptography/Commitments.lean`. The entropy lower bound from fiber size maps directly to the information-theoretic content of oracle queries: each point evaluation provides at most one complex value, while vanishing order requires derivative data — a higher-bandwidth information channel.

---

### Direction 1: Quantitative Oracle Separation via Information Theory

**Conjecture**: For a function f with vanishing order r at s₀, any algorithm using only point evaluations at N adaptively chosen points requires N ≥ C · r queries to distinguish vanishing order r from vanishing order r+1, where C is a constant depending on the function class (e.g., the Selberg class). Specifically, for L-functions of elliptic curves of conductor ≤ Q, C ≥ (log Q)^{1/2}.

**Test**: Formalize the information-theoretic lower bound by constructing, for each query set of size N < Cr, two L-functions in the Selberg class of degree ≤ 2 and conductor ≤ Q that agree on all N query points but have different vanishing orders. The existing `point_oracle_insufficient` theorem handles the case N = |Q| with Q finite; extend this to adaptive queries where each query point depends on previous oracle responses.

**Impact**: If true, this gives the first quantitative lower bound on oracle-assisted BSD verification, showing that derivative data is not just qualitatively but quantitatively superior to point data. If false, it would reveal that clever adaptive querying can simulate derivative access — a breakthrough result.

**Catalog References**: `Cryptography/LFunctionOracle/Hierarchy.lean` (point_oracle_insufficient), `Cryptography/Commitments.lean` (entropy_lower_bound_from_fiber), `MachineLearning/LFunctionCensus/Theorems.lean` (conductorCount_eq)

**Proof Strategy**: Use the Schwarz lemma to bound how much information a single point evaluation reveals about the Taylor coefficients at s₀. The key lemma: if f and g are in the Selberg class with conductor ≤ Q, and f(z_i) = g(z_i) for i = 1,...,N, then |f^(k)(s₀) - g^(k)(s₀)| ≤ C_k · Q^A · ∏|s₀ - z_i|^{-1}. This bounds the information content of N queries. Combine with the conductor counting function to count how many L-functions are indistinguishable.

**Domain Bridges**: Number Theory (L-function analytic properties) ↔ Information Theory (query complexity lower bounds) ↔ Cryptography (factoring hardness)

**Lineage**: Builds on `point_oracle_insufficient` and `entropy_lower_bound_from_fiber` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Euler Product Recovery from Vertical Line Integrals

**Conjecture**: Given oracle access to L(s) on the vertical line Re(s) = 2, the Euler factor at prime p can be recovered using O(log p) oracle queries via a discretized Perron's formula. Specifically, for L(s) = ∏_p (1 - a_p · p^{-s})^{-1}, the coefficient a_p satisfies a_p = lim_{T→∞} (1/2T) ∫_{-T}^{T} L(2+it) · p^{2+it} dt, and the discretized version with O(log p) sample points achieves error < 1/2.

**Test**: Implement the discretized Perron formula numerically for the Riemann zeta function (where a_p = 1 for all p). Verify that O(log p) sample points on Re(s) = 2 recover a_p = 1 for all primes p ≤ 1000. Then extend to Dirichlet L-functions where a_p = χ(p).

**Impact**: If true, this shows that point evaluation on a *single vertical line* suffices to recover all Euler factors, upgrading a point oracle to an Euler factor oracle. This would collapse the oracle hierarchy partially: the separation between Level 1 and Euler factor access disappears for L-functions with known functional equations. If false, it would demonstrate that the analytic continuation barrier is essential — information on Re(s) = 2 fundamentally cannot reach the critical strip.

**Catalog References**: `Cryptography/LFunctionOracle/Hierarchy.lean` (factoring_from_conductor_oracle), `Computation/GravityOracle.lean` (IsGravOracle)

**Proof Strategy**: Bound the truncation error in Perron's formula using the Phragmén-Lindelöf principle. The key estimate: |L(2+it)| ≤ ζ(2) for Re(s) ≥ 2, giving exponential decay in the integrand when weighted by p^{-s}. The discretization error is bounded by the Nyquist sampling theorem applied to the Fourier transform of the Dirichlet series coefficients.

**Domain Bridges**: Analytic Number Theory (Perron's formula) ↔ Signal Processing (sampling theory) ↔ Computation (oracle simulation)

**Lineage**: Builds on the oracle hierarchy framework and the Euler factor independence concept.

**Ambition**: extension

---

### Direction 3: Conductor Factoring Complexity for Multi-Prime Composites

**Conjecture**: The conductor GCD factoring algorithm extends to k-prime composites n = p₁ · p₂ · ... · p_k with O(k · (log n)²) total oracle queries. Specifically, iterating the GCD extraction k-1 times recovers all prime factors, with each iteration requiring O((log n)²) queries.

**Test**: Formalize the extension of `semiprime_gcd_eq_factor` to the case where n has k prime factors. The key lemma: if p_i | a and p_j ∤ a for all j ≠ i, then gcd(a, n) = p_i. Verify computationally for 3-prime composites like 30030 = 2 × 3 × 5003.

**Impact**: If true, this extends the factoring results from semiprimes to general composites, showing that L-function conductor data enables complete factorization in polynomial oracle queries. If false, the failure point reveals whether the difficulty lies in isolating individual prime factors when the conductor mixes multiple primes.

**Catalog References**: `Cryptography/LFunctionOracle/Hierarchy.lean` (conductor_gcd_factoring, prime_power_separates), `Cryptography/FactorQuadruples.lean` (fermat_factoring_from_difference_of_squares)

**Proof Strategy**: Generalize the separating family framework from two primes to k primes. The local conductor at p_i is p_i^{e_i}, which is divisible by p_i but not by any other p_j (by prime_power_separates). Apply gcd extraction iteratively: gcd(p₁^{e₁}, n) = p₁, then gcd(p₂^{e₂}, n/p₁) = p₂, etc. The key challenge is formalizing the iteration and proving that each step reduces the number of unknown factors.

**Domain Bridges**: Number Theory (conductor theory) ↔ Cryptography (general integer factoring) ↔ Algebra (multiplicative structure of conductors)

**Lineage**: Direct extension of `factoring_from_conductor_oracle` and the conductor decomposition framework.

**Ambition**: extension

---

### Direction 4: Oracle-Assisted BSD via Analytic Rank Computation

**Conjecture**: For an elliptic curve E of conductor N, the analytic rank r_an(E) is computable from O(r_an(E) + 1) derivative oracle queries at s = 1. Moreover, for curves in the LMFDB with conductor ≤ 10^6, the algebraic rank equals the analytic rank (i.e., weak BSD holds).

**Test**: Formalize the reduction: "derivative oracle + jet_rank_detection ⟹ analytic rank computation." Then state weak BSD as: for all E in a specified family, the algebraic rank (from Mordell-Weil) equals the analytic rank (from the derivative oracle). Verify computationally for the first 100 elliptic curves in Cremona's tables.

**Impact**: If true, this gives the first formal proof that an L-function oracle decides BSD for bounded-conductor curves — connecting the oracle hierarchy to a Millennium Problem. If false, it would identify specific curves where BSD fails or where the analytic rank computation requires more than r+1 queries (suggesting the Taylor expansion converges slowly).

**Catalog References**: `Cryptography/LFunctionOracle/Hierarchy.lean` (jet_rank_detection, vanishing_order_unique), `MachineLearning/LFunctionCensus/Defs.lean` (SelbergDatum)

**Proof Strategy**: The formal reduction is: (1) given derivative oracle, evaluate f^(k)(1) for k = 0, 1, 2, ...; (2) the first nonzero value determines the vanishing order by `vanishing_order_unique`; (3) the vanishing order equals the analytic rank by definition. The challenge is connecting the abstract vanishing order to the concrete analytic rank of an elliptic curve, which requires formalizing the completed L-function L(E, s).

**Domain Bridges**: Number Theory (BSD conjecture) ↔ Analysis (Taylor expansion, vanishing orders) ↔ Algebra (Mordell-Weil groups)

**Lineage**: Builds on `jet_rank_detection` and `vanishing_order_unique`.

**Ambition**: grand_challenge

---

### Direction 5: Tropical L-Functions and Combinatorial Oracle Analogs

**Conjecture**: There exists a "tropical L-function" over the tropical semiring (ℝ ∪ {∞}, min, +) whose "zeros" (tropical roots) encode combinatorial data analogous to prime distributions. Specifically, the tropical zeta function ζ_trop(s) = min_n (n · s) has tropical zeros at s = -log p / log n for primes p, and a tropical oracle for ζ_trop enables polynomial-time computation of prime gaps.

**Test**: Define the tropical L-function formally as a piecewise-linear function over ℝ. Compute its tropical zeros for the first 100 primes. Verify that the tropical conductor of a composite number n factors into tropical local conductors at each prime, analogous to the archimedean case.

**Impact**: If true, this creates a purely combinatorial analog of the entire L-function oracle framework, accessible without complex analysis. The tropical setting would provide a testing ground for conjectures about L-function data before attempting them in the archimedean case. If false, the failure would identify which L-function properties are essentially analytic (requiring complex-valued functions) versus combinatorial.

**Catalog References**: `Tropical/` (tropical semiring infrastructure), `Cryptography/TropicalPostQuantum.lean`, `Cryptography/TropicalMinPlusOWF.lean`

**Proof Strategy**: Define ζ_trop(s) = min_{n≥1} (log(n) + n·s) as the tropical analog of the Dirichlet series. The tropical Euler product becomes ζ_trop(s) = min_p min_{k≥0} (k·log(p) + k·p·s). Tropical zeros are values of s where the minimum is achieved by two or more terms — these are breakpoints of the piecewise-linear function. Prove that these breakpoints encode prime gap information.

**Domain Bridges**: Tropical Geometry (min-plus algebra) ↔ Number Theory (prime distribution) ↔ Cryptography (combinatorial oracle reductions)

**Lineage**: Connects the L-function oracle framework to the existing tropical cryptography infrastructure.

**Ambition**: extension
