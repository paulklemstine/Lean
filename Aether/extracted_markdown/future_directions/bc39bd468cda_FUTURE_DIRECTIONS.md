# Future Directions: Berggren Arithmetic Dynamics

## Conjecture 1: Universal Strong Connectivity for All Odd Moduli

**Precise statement**: For every odd integer m ≥ 3, the Berggren residue graph on Reachable(m) ⊆ (ℤ/mℤ)³ is strongly connected. That is, for any two residue classes t₁, t₂ ∈ Reachable(m), there exists a Berggren word w such that eval(w, t₁) ≡ t₂ (mod m).

**Test**: Verify computationally for all odd m ≤ 10000. Attempt CRT reduction to prime powers: prove strong connectivity mod p^k for odd primes p and k ≥ 1, then lift to composite moduli. A key subgoal is showing that the Berggren semigroup modulo odd p generates a group (i.e., every generator has a modular inverse expressible as a positive word).

**Falsification criterion**: A single odd m ≥ 3 where Reachable(m) has multiple strongly connected components. The separating invariant (if it exists) would likely be a modular polynomial in a, b, c beyond the Pythagorean congruence.

**Impact**: Would establish a concrete instance of strong approximation for the Berggren thin semigroup, connecting the combinatorics of Pythagorean triples to deep algebraic number theory. Would also validate the Berggren tree as a provably mixing finite-state dynamical system for cryptographic and sampling applications.

---

## Conjecture 2: C-ray is the Universal Second Extremal Geodesic

**Precise statement**: For every integer d ≥ 2, among all Berggren words of length d, the all-C word C^d is the unique word achieving the second-smallest hypotenuse. The second minimum equals 4d² + 8d + 5.

**Test**: Verified exhaustively for d ≤ 7 (2187 words at d=7). For d ≤ 4, the result is machine-verified in Lean 4. For larger d, develop an inductive proof using the refined growth bound: show that any word containing at least one non-C letter (other than the all-A word) has hypotenuse exceeding 4d²+8d+5. The key lemma needed: a tighter version of the min-component growth bound specific to words avoiding the all-A and all-C patterns.

**Falsification criterion**: A word of length d ≥ 5 that is neither all-A nor all-C but achieves hypotenuse ≤ 4d²+8d+5. Computational evidence makes this extremely unlikely.

**Impact**: Would complete the classification of the two extremal geodesics of the Berggren tree and provide the foundation for a full "thermodynamic formalism" — ranking all paths by growth rate and identifying the low-complexity language generating near-minimal triples.

---

## Conjecture 3: Generator Period Formula

**Precise statement**: For any odd prime p, the period of generator A from the root (3,4,5) mod p is exactly p. That is, A^p · (3,4,5) ≡ (3,4,5) (mod p) and no smaller positive power has this property. Similarly, the period of C from the root is p. The period of B from the root is p+1 for p ≡ 1 (mod 4) and divides p+1 for p ≡ 3 (mod 4).

**Test**: Verified computationally for all odd primes p < 100. The A-period equals p in every case. The B-period equals p+1 for p ∈ {5, 13, 17, 29, 37, 41, ...} (all ≡ 1 mod 4) and divides p+1 for p ≡ 3 mod 4. Prove the A-period result using the closed form: A^p · (3,4,5) = (2p+3, 2p²+6p+4, 2p²+6p+5) and reduce mod p to get (3, 4, 5). Minimality of the period requires showing that 2k+3 ≢ 3, 2k²+6k+4 ≢ 4, or 2k²+6k+5 ≢ 5 (mod p) for 0 < k < p.

**Falsification criterion**: An odd prime p where A has period strictly less than p from the root.

**Impact**: Would provide exact arithmetic data for the modular dynamics, connecting to finite field theory. The dichotomy for B-periods based on quadratic residuacity (p mod 4) suggests deep connections to quadratic reciprocity and the Legendre symbol.

---

## Conjecture 4: Reachable Set Cardinality Formula

**Precise statement**: For an odd prime p:
- |Reachable(p)| = p(p-1)/2 if p ≡ 1 (mod 4)
- |Reachable(p)| = p(p+1)/2 if p ≡ 3 (mod 4)

More generally, |Reachable(p)| equals the number of points on the projective conic x²+y²≡z² (mod p) satisfying a primitivity-parity condition.

**Test**: Verify against computed values:
- p=3: |R|=4, formula gives 3·4/2=6. **Fails** — needs refinement.
- p=5: |R|=12, formula gives 5·4/2=10. **Fails** — needs refinement.
- p=7: |R|=24, formula gives 7·8/2=28. **Fails** — needs refinement.

Actually, the data shows |Reachable(p)| = p²-1 for p=3 (4), does not obviously match. Refine: |Reachable(p)| appears to grow as Θ(p²). Find the exact formula.

**Falsification criterion**: The pattern is more complex than a simple polynomial in p. May require separate formulas for different residue classes of p.

**Impact**: An exact cardinality formula would determine the spectral dimension of the Berggren transition operator and is prerequisite to spectral gap estimates.

---

## Conjecture 5: Polynomial Diameter Bound

**Precise statement**: The directed diameter of the Berggren residue graph modulo odd prime p is O(p^α) for some universal α > 0. Specifically, we conjecture α ≤ 2: any reachable residue class can be reached from any other in at most O(p²) steps.

**Test**: Compute the diameter exactly for primes p < 50. Check whether the growth is polynomial or logarithmic. If logarithmic, this would imply expansion (spectral gap of order 1/polylog(p)), which would be even stronger than the polynomial spectral gap conjecture.

**Falsification criterion**: Diameter growing faster than any polynomial in p, or even super-polynomially.

**Impact**: A polynomial diameter bound, combined with strong connectivity, would yield the first explicit spectral gap estimate for the Berggren transition operator via Cheeger-type inequalities. This is the key bottleneck for establishing the Berggren tree as a concrete expander family, which would have implications for the affine sieve, equidistribution of Pythagorean triples modulo primes, and efficient sampling algorithms.

---

## Methodology Notes

Each conjecture above is designed to be:
- **Falsifiable**: concrete computational tests can rule it out
- **Progressive**: partial results (e.g., for specific prime families) have independent value
- **Formalizable**: positive results can be stated and proved in Lean 4
- **Connected**: the conjectures form a coherent program — the cardinality formula (4) feeds into the spectral gap (5), which together with connectivity (1) would establish full expansion. The extremal geodesic theory (2-3) provides independent structural insight.

The recommended attack order is: 3 (most accessible), 2 (builds on existing machinery), 1 (requires new group-theoretic ideas), 4 (requires enumerative combinatorics on quadratic cones), 5 (requires spectral theory infrastructure).
