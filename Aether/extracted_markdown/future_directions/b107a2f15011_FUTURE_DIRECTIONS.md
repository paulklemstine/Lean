# Future Directions: Berggren Semigroup Spectral Theory

## Hypothesis 1: k-th Extremal Hierarchy

**Conjecture:** For each fixed k ≥ 1, there exists an explicit symbolic family F_k of Berggren words such that for all n ≥ n_0(k), the k-th smallest hypotenuse at depth n is achieved uniquely by the word F_k(n).

**Known cases:**
- k=1: F_1(n) = A^n, hyp = 2n² + 6n + 5 (classical)
- k=2: F_2(n) = C^n, hyp = 4n² + 8n + 5 (proved in this work)
- k=3: F_3(n) = A^{n-1}C, hyp = 10n² + 6n + 1 (computationally verified through n=12)

**Predicted pattern:** F_k(n) involves at most k distinct "blocks" of generators, with hypotenuse given by a degree-2 polynomial in n whose leading coefficient grows with k.

**Test:** Enumerate all words at depths n = 8, 9, ..., 15 and extract the k-th extremal word for k = 4, 5, 6. Fit the hypotenuse to quadratic polynomials and verify consistency.

**Expected failure mode:** The hierarchy may become non-unique at some k (two distinct words tie for the k-th position). Computations suggest uniqueness holds at least through k = 5.

**Impact if true:** Provides a complete "density of states" for the Berggren depth shell, analogous to eigenvalue spacing in random matrix theory. Could feed into triple-counting formulas with symbolic constraints.

---

## Hypothesis 2: Uniform B-Gap with Explicit Polynomial

**Conjecture:** Any word of length n containing at least one B generator satisfies:
  c(w) ≥ c(C^n) + 6n² + 6n − 4
i.e., the gap between the smallest B-containing word and the second-extremal C^n is at least quadratic.

More precisely, the minimum hypotenuse among B-containing words of length n equals 10n² + 14n + 5 (achieved by A^{n-1}B), and the gap from C^n is 6n² + 6n.

**Test:** 
- Verify the formula c(A^{n-1}B) = 10n² + 14n + 5 by computation through n = 20.
- Verify minimality of A^{n-1}B among all B-containing words through n = 8 (by exhaustive enumeration).
- Formally prove the closed form using the unipotent matrix formula.

**Expected failure mode:** The formula may be incorrect under different Berggren conventions; the minimizer among B-words might not be A^{n-1}B for very large n.

**Impact if true:** Gives a clean spectral gap separating {A,C}-words from B-words, with an explicit polynomial lower bound. This is the integer-matrix analog of a spectral gap in operator theory.

---

## Hypothesis 3: Prime-Quotient Strong Connectivity

**Conjecture:** For every odd prime p ≥ 7, the directed multigraph on the Berggren orbit of (3,4,5) mod p under generators {A, B, C} is strongly connected.

**Test:** Compute the Berggren orbit mod p and check strong connectivity for all primes p ≤ 200 using BFS/DFS. Our computations confirm strong connectivity for all primes 7 ≤ p ≤ 47.

**Expected failure mode:** Connectivity could fail for specific primes where the generators reduce to a proper subgroup of the light-cone symmetry group mod p. The primes 2, 3, 5 are known exceptions.

**Impact if true:** Establishes that the Berggren semigroup satisfies a form of strong approximation: the finite quotients are mixing. This is a prerequisite for Ramanujan-type expansion bounds and connects Pythagorean triple theory to additive combinatorics over finite fields.

---

## Hypothesis 4: Logarithmic Diameter of Modular Graphs

**Conjecture:** For the Berggren orbit graph G_p, the diameter satisfies diam(G_p) = Θ(log p).

**Test:** Compute the exact diameter for primes 7 ≤ p ≤ 101 (feasible since orbit sizes are O(p²)). Fit diameter vs log₂(p) to a linear model and measure R² goodness of fit.

**Preliminary data:**
- p=7: orbit=16, diam≤3
- p=11: orbit=40, diam≤4
- p=13: orbit=56, diam≤4
- p=17: orbit=96, diam≤5
- p=19: orbit=120, diam≤5

The data suggests diameter ≈ 1.5 log₂(p), consistent with expansion.

**Expected failure mode:** The diameter could grow as √p or faster for special primes, indicating a failure of rapid mixing.

**Impact if true:** Would imply the Berggren generators form an expander family on modular light cones, with applications to randomized algorithms for Pythagorean triple generation in finite fields.

---

## Hypothesis 5: Transfer-Operator Ordering

**Conjecture:** Define the "energy" of a word w of length n as E(w) = c(w) / c(A^n). The extremal hierarchy at depth n is determined by a symbolic transfer operator: the k-th smallest energy state corresponds to the k-th smallest eigenvalue of a finite-state Markov operator on the symbolic space {A, B, C}^n, where transition weights are derived from the leg-ratio a/b.

**Test:**
1. Compute the leg ratio r(w) = a(w)/b(w) for all words at depth n = 8.
2. Define a 3-state Markov chain with transition weights based on hypotenuse growth ratios.
3. Verify that the stationary measure correctly predicts the ordering of the first 10 extremal words.

**Expected failure mode:** The Markov approximation may break for words that oscillate between a > b and b > a regimes; the memory of past generators may extend beyond one step.

**Impact if true:** Would provide a complete dynamical-systems framework for Berggren spectral theory, connecting the discrete variational principle proved in this work to continuous transfer-operator theory. This opens the door to asymptotic counting of triples by hypotenuse with symbolic constraints, analogous to prime-counting with Selberg sieves.
