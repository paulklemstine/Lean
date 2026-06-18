# Future Directions: Berggren Tree Arithmetic Dynamics

## Hypothesis 1: Universal Modular Strong Connectivity

**Conjecture**: For every odd integer m ≥ 3, the Berggren residue graph modulo m is strongly connected. That is, for any two primitive Pythagorean triples t₁, t₂ with t₁ ≡ t₂ (mod m) reachable from (3,4,5), there exists a Berggren word w such that eval(w, t₁) ≡ t₂ (mod m).

**Test**: Compute the Berggren residue graph for all odd m ≤ 200. For each, verify strong connectivity by BFS/DFS. If any m fails, classify the strongly connected components.

**Falsification criterion**: Exhibit an odd m and two reachable residue classes that are not connected by any word.

**Impact**: If true, this would establish that the Berggren tree equidistributes primitive Pythagorean triples across all admissible congruence classes, with implications for the affine sieve and arithmetic statistics of Pythagorean triples.

---

## Hypothesis 2: Spectral Gap Lower Bound

**Conjecture**: For every odd prime p, the normalized transition operator of the Berggren residue graph modulo p has spectral gap at least c/p² for some universal constant c > 0. Specifically, if λ₂ is the second-largest eigenvalue modulus of the 3-regular transition matrix on reachable states modulo p, then 1 − λ₂ ≥ c/p² for all odd primes p.

**Test**: Compute the exact spectrum of the Berggren transition matrix modulo p for all odd primes p < 100. Plot 1 − λ₂ against 1/p² and fit the constant c. Check whether c stabilizes.

**Falsification criterion**: Find a sequence of primes pₙ → ∞ such that (1 − λ₂(pₙ)) · pₙ² → 0.

**Impact**: A spectral gap bound would establish quantitative mixing for the Berggren Markov chain on residue classes, connecting the Berggren tree to expander graph theory and providing explicit convergence rates for equidistribution.

---

## Hypothesis 3: Second Extremal Trajectory Classification

**Conjecture**: For every depth d ≥ 2, the triple with the second-smallest hypotenuse at depth d is produced by the word A^(d-1)C (i.e., d−1 copies of A followed by one C), with hypotenuse 10(d-1)² + 26(d-1) + 17 = 10d² + 6d + 1.

**Test**: Enumerate all words of length d for d = 2, 3, ..., 10 and identify the second-smallest hypotenuse and its word. Verify against the predicted formula.

**Falsification criterion**: Find a depth d ≥ 2 where the second-smallest hypotenuse is not achieved by A^(d-1)C, or where its value differs from 10d² + 6d + 1.

**Impact**: If true, this would extend the extremal geodesic theory to a complete classification of the top-k minimizers, revealing the fine structure of hypotenuse distribution near the extremal boundary. It would also suggest whether the "extremal cone" has a simple combinatorial description.

---

## Hypothesis 4: Extremal Geodesic for Arbitrary Starting Triples

**Conjecture**: For every primitive Pythagorean triple t with a < b (where a is the odd leg), and for all sufficiently large d, the all-A word A^d minimizes hypotenuse among all words of length d applied to t. Moreover, the threshold depth beyond which A^d is optimal is at most O(log(c/a)).

**Test**: For each of the first 100 primitive triples (ordered by hypotenuse), compute the hypotenuse-minimizing word at each depth d = 1, ..., 20. Determine the threshold depth at which A^d first becomes optimal. Regress the threshold against log(c/a).

**Falsification criterion**: Find a primitive triple t with a < b such that for infinitely many d, the all-A word does not minimize hypotenuse at depth d.

**Impact**: This would generalize the extremal geodesic theorem from the root (3,4,5) to arbitrary starting points, establishing that the A-generator universally dominates for hypotenuse minimization. It would confirm that the extremal phenomenon is a property of the generator A itself, not an artifact of the specific starting triple.

---

## Hypothesis 5: Berggren-Lyapunov Exponent Gap

**Conjecture**: Among all infinite words w = g₁g₂g₃... over {A, B, C}, the asymptotic growth rate of the hypotenuse—defined as lim_{d→∞} log(hyp(g₁...g_d · (3,4,5))) / d—is minimized uniquely by the constant sequence A^∞, with Lyapunov exponent 0 (polynomial growth). All other ergodic sequences have positive Lyapunov exponent (exponential growth), with the infimum over non-constant ergodic sequences being the logarithm of the spectral radius of the matrix C restricted to the Pythagorean cone.

**Test**: Compute hypotenuse growth rates for 1000 random infinite words of length 100. Estimate the Lyapunov exponent distribution. Verify that A^∞ is the unique word with sub-exponential growth. Compute the spectral radius of C on the Pythagorean cone numerically.

**Falsification criterion**: Find a non-constant word with sub-exponential hypotenuse growth, or show that the infimum Lyapunov exponent over non-constant sequences is 0 (no gap).

**Impact**: This would connect the Berggren extremal problem to the theory of Lyapunov exponents and the joint spectral radius, establishing that the all-A geodesic is not only depth-wise optimal but trajectory-wise singular—the unique ray along which hypotenuse grows polynomially rather than exponentially.
