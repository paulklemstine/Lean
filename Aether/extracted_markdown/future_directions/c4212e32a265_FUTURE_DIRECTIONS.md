# Future Directions: Perfect Cuboid Euler Product Sieve

## Summary of Established Results

We have formally verified:
- **CRT multiplicativity**: `survivorCount(m·n) = survivorCount(m) · survivorCount(n)` for coprime m, n.
- **Certified prime counts**: Exact survivor counts at primes 2, 3, 5, 7, 11, 13 (with computational verification through 31).
- **Mod-105 factorization**: `survivorCount(105) = 7 × 37 × 55 = 14,245`, density ≈ 1.23%.
- **Mod-1155 factorization**: `survivorCount(1155) = 7 × 37 × 55 × 151 = 2,150,995`, density ≈ 0.14%.
- **Density product formula**: The mod-1155 density equals the product of local densities at 3, 5, 7, 11.
- **Bridge theorem**: Any integer perfect cuboid reduces to a cuboid survivor modulo every n.
- **Quartic fiber reduction**: The cuboid surface equation reduces to W² = r²s⁴ + (r⁴+1)s² + r² under Pythagorean parametrization.
- **Quartic factorization**: W² = (r²s² + 1)(s² + r²), revealing product-of-quadratics structure.

---

## Hypothesis 1: Prime-Uniform Shrinkage

**Conjecture:** There exists δ > 0 such that for all primes p ≥ 3,
```
survivorCount(p) ≤ (1 - δ) · p³
```
Specifically, we conjecture δ ≥ 0.7 (i.e., density ≤ 30% at every odd prime).

**Current evidence:**
| p | Density | 1 - density |
|---|---------|-------------|
| 3 | 0.259 | 0.741 |
| 5 | 0.296 | 0.704 |
| 7 | 0.160 | 0.840 |
| 11 | 0.113 | 0.887 |
| 13 | 0.159 | 0.841 |
| 17 | 0.166 | 0.834 |
| 19 | 0.071 | 0.929 |
| 23 | 0.089 | 0.911 |
| 29 | 0.134 | 0.866 |
| 31 | 0.082 | 0.918 |

All densities are below 0.30, with the maximum at p = 5 (0.296).

**Test:** Compute survivorCount(p) for all primes p ≤ 1000. If any prime has density > 0.30, the conjecture is falsified. A Lean-verifiable test would certify counts at primes through 47 or beyond using `native_decide`.

**Impact if true:** The Euler product ∏_p (density(p)) converges to 0 at least as fast as ∏_p (1 - δ), which goes to 0 since Σ δ diverges. This would provide a rigorous heuristic argument that the expected number of perfect cuboids is 0 — analogous to the Hardy-Littlewood heuristic for prime k-tuples.

**Impact if false:** A prime with density > 0.30 would indicate a structural resonance between quadratic residue conditions, potentially linked to the arithmetic of the prime (e.g., p ≡ 1 mod 4 vs p ≡ 3 mod 4).

---

## Hypothesis 2: Asymptotic Density Formula

**Conjecture:** As p → ∞ through primes,
```
survivorCount(p) / p³ → C
```
for some constant C with 0.10 < C < 0.20, or more precisely,
```
survivorCount(p) = C · p³ + O(p^{5/2})
```
where C can be expressed as a product of probabilities related to the quadratic character χ_p.

**Rationale:** For large p, the quadratic residues mod p form approximately half the nonzero elements. Four independent "is square" conditions would predict density ≈ (1/2)⁴ = 1/16 ≈ 0.0625. The observed densities are consistently higher (0.07 – 0.30), suggesting correlations whose strength should be computable by character-sum methods.

**Test:** 
1. Compute densities for primes up to 200 and fit the data to C + A/p + B/p² using least squares.
2. Derive a character-sum formula for the exact leading coefficient.
3. Compare: if the character-sum prediction matches the data to < 1% relative error, the formula is confirmed.

**Impact if true:** Provides an explicit Euler product convergence rate. The cuboid Euler product would behave like ∏_p C, whose convergence/divergence can be determined. If C < 1 (which it is), the product converges to 0, strengthening the nonexistence heuristic.

**Impact if false:** Density oscillations that don't converge would suggest deeper arithmetic structure — potentially connections to L-functions or automorphic forms.

---

## Hypothesis 3: No Finite Complete Obstruction

**Conjecture:** For every positive integer n ≥ 1,
```
survivorCount(n) ≥ 1
```
That is, no single modulus provides a complete local obstruction to perfect cuboids.

**Current evidence:** For all tested moduli (including products of primes through 31), the survivor count is strictly positive. The trivial triple (0, 0, 0) always survives.

**Test:** By CRT multiplicativity, it suffices to check prime powers. For primes p ≤ 100, compute survivorCount(p) and survivorCount(p²). If any equals 0, the conjecture is falsified and perfect cuboids are proven impossible.

**Impact if true (nonexistence at some n):** This would be a complete resolution of the perfect cuboid problem — a modular impossibility proof. It would be a major result in number theory.

**Impact if false (all counts positive):** The obstruction to perfect cuboids, if any, must be global rather than local. This would point toward:
- Brauer-Manin obstructions on the cuboid surface
- Height-growth arguments
- Mordell-Weil rank constraints on the quartic fibers

---

## Hypothesis 4: Quadratic Residue Class Bias

**Conjecture:** The local density survivorCount(p)/p³ depends systematically on the quadratic character of p. Specifically:
- For p ≡ 1 (mod 4): density tends to be higher (≈ 0.15 – 0.30), because -1 is a QR.
- For p ≡ 3 (mod 4): density tends to be lower (≈ 0.07 – 0.16), because -1 is a QNR.

**Current evidence:**
- p ≡ 1 (mod 4): 5 (0.296), 13 (0.159), 17 (0.166), 29 (0.134) → avg ≈ 0.189
- p ≡ 3 (mod 4): 3 (0.259), 7 (0.160), 11 (0.113), 19 (0.071), 23 (0.089), 31 (0.082) → avg ≈ 0.129

The p ≡ 3 (mod 4) primes have lower average density, consistent with the conjecture.

**Test:** Compute densities for primes p ≤ 200 and perform a statistical test (t-test or Mann-Whitney) comparing the two classes. Additionally, test whether the density depends on p mod 8, p mod 12, or p mod 24 (to capture higher residue structure).

**Impact if true:** Provides a precise arithmetic-geometric explanation for density fluctuations. Would enable sharper estimates of the Euler product convergence rate by separating prime classes.

**Impact if false:** Density fluctuations may be more subtle, potentially depending on the full quadratic residue structure rather than just the Legendre symbol (-1/p).

---

## Hypothesis 5: Elliptic Fiber Rank Obstruction

**Conjecture:** For "generic" rational r ≠ 0, the elliptic curve obtained from the quartic fiber
```
W² = (r²s² + 1)(s² + r²)
```
(after transformation to Weierstrass form) has Mordell-Weil rank 0 over Q(r), meaning only finitely many rational points exist.

**Rationale:** The factored form W² = (r²s² + 1)(s² + r²) is a product of two positive-definite quadratics. For W² to be a perfect square, we need a simultaneous "square-splitting" condition. Such conditions often force rank 0 in families of elliptic curves.

**Test:**
1. For 50 rational values of r (e.g., r = n/m for small n, m), transform the quartic to Weierstrass form.
2. Compute the rank using SAGE/Magma's `mwrank` or the LMFDB database.
3. Check whether all fibers have rank 0, and if torsion points correspond to degenerate cuboids.

**Impact if true:** If generic fibers have rank 0, rational points on the cuboid surface are extremely constrained. Combined with a descent argument, this could potentially prove that only degenerate solutions (with a zero edge) exist — resolving the perfect cuboid problem.

**Impact if false:** Fibers with positive rank would provide candidate parameter values where cuboid-like solutions might exist. Understanding these exceptional fibers would be a new direction for constructive approaches.

---

## Prioritized Action Plan

### Immediate (next cycle):
1. **Extend prime table to p ≤ 100** with Python computation; certify key primes in Lean.
2. **Test Hypothesis 4** with the extended data — does p mod 4 predict density?
3. **Formalize the product-over-Finset theorem** in Lean: survivorCount(∏ p_i) = ∏ survivorCount(p_i).

### Medium-term (2-3 cycles):
4. **Derive character-sum formula** for survivorCount(p) using Gauss/Jacobi sums.
5. **Convert quartic fibers to Weierstrass form** and analyze ranks computationally.
6. **Compute survivorCount(p²)** for small primes — test prime-power multiplicativity.

### Long-term (4+ cycles):
7. **Prove asymptotic formula** for survivorCount(p)/p³ using analytic methods.
8. **Formalize the Euler product convergence** to zero, conditional on the asymptotic formula.
9. **Study the Brauer-Manin obstruction** on the cuboid surface, connecting local and global failures.
10. **Attempt to prove nonexistence** of perfect cuboids via the geometric approach (if rank obstruction holds).
