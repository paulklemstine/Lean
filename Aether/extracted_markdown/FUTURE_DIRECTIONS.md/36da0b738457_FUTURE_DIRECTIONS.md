# Future Directions: Quadratic Dynamics and Number Theory

## Synthesis

This research cycle established a rigorous bridge between the algebraic structure of
quadratic iteration z ↦ z² + c and classical number theory. The key discoveries are:
(1) the exact bifurcation threshold c = -3/4 for period-2 orbits, with the subtlety
that the boundary case produces a degenerate fixed point rather than a genuine period-2
orbit; (2) the Mandelbrot polynomials Φ_n ∈ ℤ[X] are monic of degree 2^{n-1},
structurally paralleling cyclotomic polynomials; (3) periodic orbit counts decompose
via minimal periods in a way that enables Möbius inversion, connecting dynamics directly
to the Möbius function μ(n) and Euler's totient φ(n); (4) the Burnside necklace identity
reveals that orbit counting, binary necklaces, and irreducible polynomials over F₂ are
the same combinatorial problem viewed from different angles.

The most promising cross-domain connection is the **Mandelbrot-cyclotomic parallel**:
the degree/monicity properties of Mandelbrot polynomials mirror those of cyclotomic
polynomials, and the dynatomic factorization of Mandelbrot polynomials (separating
primitive periods from divisor periods) directly parallels the cyclotomic factorization
x^n - 1 = ∏_{d|n} Ψ_d(x). Formalizing this parallel — and especially the irreducibility
of dynatomic polynomials — has the highest breakthrough potential, as it would connect
algebraic dynamics to class field theory and modular forms.

The bridge to Catalog results `sp_boundary_determines_structure` (boundary determines
interior) and `rational_angle_period_3` (period-3 dynamics) provides a foundation for
extending to higher periods and complex parameters.

---

### Direction 1: Dynatomic Polynomial Irreducibility (Gleason's Conjecture)

**Conjecture**: For each n ≥ 1, the dynatomic polynomial Ψ*_n(c) — defined by the
relation Φ_n(c) = ∏_{d|n} Ψ*_d(c) where Φ_n(c) is the n-th Mandelbrot polynomial
(the n-th iterate of 0 under z ↦ z² + c, as a polynomial in c) — is irreducible
over ℤ for all n.

For context: Φ_1(c) = c, Φ_2(c) = c² + c, Φ_3(c) = c⁴ + 2c³ + c² + c.
Then Ψ*_1(c) = c, Ψ*_2(c) = Φ_2(c)/Φ_1(c) = c + 1,
Ψ*_3(c) = Φ_3(c)/Φ_1(c) = c³ + 2c² + c + 1.
The conjecture states Ψ*_n is irreducible over ℤ for all n.

**Test**: Compute Ψ*_n(c) for n ≤ 10 and verify irreducibility using standard
algorithms (e.g., reduction modulo primes + Hensel lifting). Check the Galois group
of the splitting field for n ≤ 8.

**Impact**: If true, this would establish that dynatomic polynomials are the
"cyclotomic polynomials of dynamics" — a fundamental structural result in
arithmetic dynamics. If false for some n₀, the factorization would reveal
unexpected algebraic structure in period-n₀ components of the Mandelbrot set.

**Catalog References**: `Novelty/QuadraticDynamics/Basic.lean` (mandelbrotPoly_degree,
mandelbrotPoly_monic), `Cryptography/LogisticChaos/Dynamics.lean` (rational_angle_period_3)

**Proof Strategy**: Define dynatomic polynomials formally as Ψ*_n = ∏_{d|n} Φ_d^{μ(n/d)}
using Möbius inversion on the polynomial level. Prove they are in ℤ[X] (not obvious
from the definition since it involves division). Then attack irreducibility via:
(a) Newton polygon analysis for specific primes,
(b) Eisenstein criterion after suitable substitution,
(c) reduction to showing the Galois group is Sym(deg) for small cases.

**Domain Bridges**: Algebraic dynamics ↔ Algebraic number theory (cyclotomic analogy),
Arithmetic dynamics ↔ Combinatorics (necklace polynomial connection)

**Lineage**: Builds on mandelbrotPoly_degree, mandelbrotPoly_monic, and the
factorization identity Φ_n = ∏_{d|n} Ψ*_d from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Higher-Degree Mandelbrot Polynomials: z ↦ z^d + c

**Conjecture**: For the degree-d iteration z ↦ z^d + c with d ≥ 2, the n-th iterate
Φ_{d,n}(c) (starting from z₀ = 0) is a monic polynomial of degree d^{n-1} in c.
Moreover, the Burnside necklace identity generalizes: the number of primitive period-n
orbits of the d-fold angle map θ ↦ dθ (mod 1) equals (1/n) Σ_{k|n} μ(n/k) · d^k,
which counts d-ary necklaces and irreducible polynomials of degree n over F_d.

**Test**: Implement the iteration for d = 3, 4, 5 and verify:
(a) degree of Φ_{d,n} equals d^{n-1} for n ≤ 6,
(b) leading coefficient is 1,
(c) necklace count formula matches for n ≤ 20.

**Impact**: This would extend the Mandelbrot-Möbius bridge from binary dynamics
(d = 2) to arbitrary-base dynamics, revealing a uniform theory. The case d = p
(prime) connects to the theory of irreducible polynomials over F_p, which has
applications in coding theory and cryptography.

**Catalog References**: `Novelty/QuadraticDynamics/Basic.lean` (mandelbrotPoly_degree),
`Novelty/QuadraticDynamics/Bridge.lean` (burnside_necklace_identity)

**Proof Strategy**: Generalize mandelbrotPoly to `mandelbrotPolyD d n` with recurrence
Φ₀ = 0, Φ_{n+1} = Φ_n^d + X. The degree proof generalizes directly (replace 2 with d
throughout). The necklace identity proof needs Burnside's lemma for the cyclic group
acting on d-ary strings. The key new ingredient is that the number of d-ary strings
fixed by k-fold rotation is d^{gcd(n,k)}.

**Domain Bridges**: Dynamical systems ↔ Finite field theory (F_d polynomials),
Fractal geometry ↔ Coding theory (d-ary codes)

**Lineage**: Direct generalization of mandelbrotPoly_degree and burnside_necklace_identity.

**Ambition**: extension

---

### Direction 3: Tropical Mandelbrot Iteration

**Conjecture**: Define the *tropical Mandelbrot iteration* by replacing (z² + c) with
max(2z, c) (the tropical semiring analogue of z² + c). Then the tropical Mandelbrot
set M_trop = {c ∈ ℝ : tropical orbit of 0 is bounded} equals the interval (-∞, 0].
The tropical period-n orbits correspond to piecewise-linear cycles, and their counting
follows a "tropical Möbius inversion" where the Möbius function acts on a lattice of
tropical divisibility.

**Test**: Compute the tropical orbit for c = -1, 0, 1, 2 and verify boundedness.
Enumerate period-n tropical orbits for n ≤ 6 and compare counts with the classical
Möbius formula. Identify where the tropical theory diverges from the classical theory.

**Impact**: The tropical Mandelbrot set would be a piecewise-linear shadow of the
classical Mandelbrot set, providing combinatorial approximations to complex-analytic
phenomena. This connects to the existing Catalog work on tropical geometry
(Tropical/Bridge.lean) and could bridge to optimization theory.

**Catalog References**: `Tropical/Bridge.lean` (sp_boundary_determines_structure),
`Novelty/QuadraticDynamics/Bridge.lean` (burnside_necklace_identity)

**Proof Strategy**: Define tropical operations (max-plus semiring) in Lean 4.
The tropical quadratic map is max(2z, c). Prove that the orbit starting from 0 is:
z_0 = 0, z_1 = max(0, c) = c if c ≥ 0 else 0, etc. Characterize boundedness:
if c > 0, the orbit grows without bound (z_n ~ 2^n · c). If c ≤ 0, the orbit
stabilizes at 0. Period analysis: tropical period-2 requires max(2·max(2z, c), c) = z,
which constrains z and c to specific piecewise-linear regions.

**Domain Bridges**: Complex dynamics ↔ Tropical geometry,
Mandelbrot iteration ↔ Min-plus optimization (from `Tropical/Bridge.lean`)

**Lineage**: Extends the dynamical framework to the tropical semiring, connecting
to sp_boundary_determines_structure from the Catalog.

**Ambition**: grand_challenge

---

### Direction 4: Mandelbrot Orbit Entropy and the Prime Number Theorem

**Conjecture**: Define the *dynamical entropy* of the Mandelbrot iteration at parameter c
as h(c) = lim_{n→∞} (1/n) log |Φ_n(c)|, where Φ_n(c) is the n-th iterate (as a real
number). Then for c outside the Mandelbrot set (c > 1/4 on the real line), h(c) = log|c|.
Moreover, the distribution of parameters c_n where Φ_n(c) = 0 (roots of the n-th
Mandelbrot polynomial) asymptotically follows a logarithmic law connected to the
prime-counting function π(n): specifically, the number of real roots of Φ_n in [-2, 1/4]
grows as 2^{n-1}/n (the "dynamical prime number theorem").

**Test**: Compute roots of Φ_n for n ≤ 8 numerically. Count real roots in [-2, 1/4].
Compare growth rate with 2^{n-1}/n. Compute h(c) numerically for c = 3, 4, 5 by
taking (1/n) log|Φ_n(c)| for large n and comparing with log|c|.

**Impact**: A "prime number theorem" for dynatomic polynomials would be a deep
structural result connecting the root distribution of dynamical polynomials to
classical analytic number theory. Even a partial result (asymptotics of root counts)
would be novel.

**Catalog References**: `Novelty/QuadraticDynamics/Basic.lean` (mandelbrotPoly_degree),
`Physics/PrimeFractalDimension.lean` (exists_prime_with_small_log_inv)

**Proof Strategy**: For h(c) = log|c|: use the recursion z_{n+1} = z_n² + c and the
fact that for |c| large, z_n ~ c^{2^{n-1}}, so (1/n) log|z_n| ~ (2^{n-1}/n) log|c|.
This diverges, so refine: perhaps h(c) = lim (1/2^n) log|z_n| = log|c|. For root
counting: use Mahler measure theory and the connection between root distributions
of monic integer polynomials and their height.

**Domain Bridges**: Algebraic dynamics ↔ Analytic number theory (PNT analogue),
Polynomial root distribution ↔ Fractal dimension (from `Physics/PrimeFractalDimension.lean`)

**Lineage**: Combines mandelbrotPoly_degree with escape growth bounds from this cycle.

**Ambition**: extension

---

### Direction 5: Periodic Orbit Cryptographic Hash from Quadratic Iteration

**Conjecture**: For a prime p > 2^{256}, the map c ↦ (Φ_n(c) mod p) for suitable n
(e.g., n = 128) defines a collision-resistant hash function from ℤ/pℤ to ℤ/pℤ.
Collision resistance is equivalent to: finding c₁ ≠ c₂ with Φ_n(c₁) ≡ Φ_n(c₂) (mod p)
requires factoring the dynatomic polynomial Ψ*_n over F_p, which is hard if Ψ*_n is
irreducible over F_p.

**Test**: For small primes (p = 101, 1009, 10007), compute the image distribution
of c ↦ Φ_n(c) mod p for n = 4, 8, 16. Measure collision rates and compare with
random function model. Test near-collision resistance for n = 4 by exhaustive search.

**Impact**: If the hash function is secure, it would provide a new cryptographic
primitive based on the arithmetic of Mandelbrot polynomials. The security proof
would require Gleason's conjecture (Direction 1) as a key ingredient. Even partial
security results would be interesting.

**Catalog References**: `Cryptography/BerggrenDiophantineLattice.lean`,
`Novelty/QuadraticDynamics/Bridge.lean` (sqMap_iterate, sqMap_fixed_iff)

**Proof Strategy**: Define the hash function formally in Lean 4 over ZMod p.
Prove basic properties: polynomial-time computability (since Φ_n has degree 2^{n-1},
evaluation is O(n) multiplications in F_p). For collision resistance, relate collisions
to roots of Φ_n(c₁) - Φ_n(c₂) = 0 in two variables, which factors through the
resultant of dynatomic polynomials. Security reduces to irreducibility of Ψ*_n over F_p.

**Domain Bridges**: Arithmetic dynamics ↔ Cryptography (hash functions),
Mandelbrot polynomials ↔ Post-quantum security (polynomial hardness)

**Lineage**: Extends sqMap_iterate and the finite field dynamics from this cycle,
connecting to the cryptography catalog via BerggrenDiophantineLattice.

**Ambition**: extension
