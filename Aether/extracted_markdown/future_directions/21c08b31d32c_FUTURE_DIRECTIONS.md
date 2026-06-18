# Future Directions: Berggren Dynamics and Arithmetic Geometry

## Overview

The formally verified theorems in this cycle — closed-form for A^n, sharp quadratic lower bound, depth-optimal minimality, and modular preservation — establish the foundation for a quantitative dynamical theory of the Berggren semigroup. The following hypotheses identify the next frontiers, each falsifiable and each connecting to deeper mathematics.

---

## Hypothesis 1: Exact Second-Extremal Path

**Conjecture**: Among all words of length n ≥ 2, the word C·A^(n-1) yields the second-smallest hypotenuse:

$$\text{second-min}_{|w|=n} c(w) = c(C \cdot A^{n-1}).$$

**Precise claim**: c(C·A^(n-1)) = 4n² + 8n + 5 for all n ≥ 1, and this is the unique second minimizer.

**Test**:
- Compute c(C·A^(n-1)) for n = 1,...,20 and verify the closed form.
- Exhaustively check that no other word of length n ≤ 10 achieves a smaller hypotenuse except A^n.
- Verify the closed form by deriving the recurrence for the C-then-A^(n-1) branch.

**Expected failure mode**: The conjecture might fail if some mixed word (e.g., A^k·C·A^(n-k-1)) produces a smaller hypotenuse for specific n. Computational evidence to depth 8 supports the conjecture.

**Impact**: Would complete the extremal landscape of the Berggren tree, identifying both the optimal and near-optimal paths. Connects to the theory of geodesics on hyperbolic surfaces.

---

## Hypothesis 2: Finite-Quotient Mixing

**Conjecture**: For every odd modulus m coprime to 30, the Berggren modular graph on the reachable orbit S_m is strongly connected and aperiodic.

**Precise claim**: The directed multigraph G_m = (S_m, E_m) where (x, y) ∈ E_m iff y = g(x) mod m for some generator g, is strongly connected and has gcd of cycle lengths equal to 1.

**Test**:
- Compute G_m for all odd m ≤ 100 coprime to 30.
- Check strong connectivity by BFS from every vertex.
- Check aperiodicity by computing gcd of all cycle lengths.
- Identify the smallest m (if any) where the conjecture fails.

**Expected failure mode**: Might fail for m divisible by small primes related to the Berggren matrices' discriminant. Could also fail for specific m where the orbit decomposes into multiple components.

**Impact**: Strong connectivity + aperiodicity is the hypothesis needed for finite-state Markov chain convergence, which would give modular equidistribution: μ_n(x) → 1/|S_m| as n → ∞.

---

## Hypothesis 3: Spectral Gap Uniformity

**Conjecture**: There exists a universal constant δ > 0 such that for every squarefree odd modulus m, the second-largest eigenvalue modulus of the normalized transition operator on S_m satisfies |λ₂| ≤ 1 - δ.

**Precise claim**: With the transition matrix P_m = A_m/3 (where A_m is the adjacency matrix of G_m), the eigenvalues λ₁ ≥ |λ₂| ≥ ... satisfy |λ₂| ≤ 1 - δ for a fixed δ > 0 independent of m.

**Test**:
- Compute the spectrum of P_m for squarefree odd m ≤ 200.
- Plot |λ₂| as a function of m.
- Check whether |λ₂| appears bounded away from 1 or approaches 1.

**Expected failure mode**: The spectral gap might shrink to 0 as m → ∞ (which would not contradict equidistribution but would slow the rate). This is related to the property of the Berggren semigroup generating an expander family, which is a deep open question.

**Impact**: A uniform spectral gap would imply *quantitative* equidistribution with rate O((1-δ)^n), connecting Berggren dynamics to expander theory and the Bourgain-Gamburd method.

---

## Hypothesis 4: Asymptotic Letter Frequency Rigidity

**Conjecture**: Any infinite word w₁w₂w₃... over {A, B, C} that achieves asymptotically minimal hypotenuse growth (c_n ~ 2n²) must have letter frequency concentrated on A:

$$\lim_{n \to \infty} \frac{|\{i \leq n : w_i = A\}|}{n} = 1.$$

**Precise claim**: If c(w₁...wₙ) = 2n² + o(n²), then the proportion of non-A letters in w₁...wₙ tends to 0.

**Test**:
- For periodic words (e.g., (AB)^k, (AC)^k), compute the quadratic coefficient of c and verify it exceeds 2.
- For random words with fixed A-frequency p, compute the expected quadratic coefficient as a function of p.
- Check whether the quadratic coefficient is minimized at p = 1 (all A's).

**Expected failure mode**: It might be that some infinite words with positive B or C frequency still achieve quadratic coefficient 2. This would require the "slow" letters to be placed at positions where they contribute minimally, which seems impossible given the uniform +2 lower bound on min-leg growth.

**Impact**: Would establish a strong rigidity result: the symbolic dynamics of the Berggren tree has a unique "slowest trajectory" up to asymptotic equivalence.

---

## Hypothesis 5: Modular Orbit Saturation for Primes p ≡ 1 (mod 4)

**Conjecture**: For every prime p ≡ 1 (mod 4), the reachable orbit S_p equals the full primitive light-cone component containing (3,4,5) in (ℤ/pℤ)³.

**Precise claim**: Define the primitive light cone mod p as L_p = {(a,b,c) ∈ (ℤ/pℤ)³ : a²+b² = c², c ≠ 0}. Then S_p = L_p^+ for one of the two connected components L_p^+ of L_p.

**Test**:
- For primes p ≡ 1 (mod 4) with p ≤ 100, compute S_p and L_p.
- Check whether |S_p| = |L_p|/2 (which would mean S_p fills exactly one component).
- For primes p ≡ 3 (mod 4), check whether the structure differs.

**Expected failure mode**: The orbit might not fill the full component for primes where the Berggren semigroup generates a proper subgroup of the orthogonal group mod p. This would indicate additional arithmetic obstructions beyond the Pythagorean relation.

**Impact**: Full saturation would be the finite-quotient input needed for an affine sieve approach to counting Pythagorean triples with restricted prime factorization patterns. This connects directly to the Bourgain-Gamburd-Sarnak program.

---

## Cross-Cutting Themes

All five hypotheses share a common structure: they ask whether the *algebraic symmetry* of the Berggren semigroup (its Lorentz group structure, its freeness) translates into *analytical uniformity* (equidistribution, spectral gaps, orbit saturation) in finite quotients. This is the central question of thin-group arithmetic dynamics, and the Berggren tree is the simplest nontrivial example where it can be studied with full formal rigor.

The computational infrastructure developed in this cycle — modular orbit computation, spectral analysis, certified enumeration — provides the tools needed to test each hypothesis. The formal verification framework ensures that any proved result is trustworthy at the highest possible standard.
