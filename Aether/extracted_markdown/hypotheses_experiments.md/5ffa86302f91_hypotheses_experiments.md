# Hypothesis Testing: Experimental Log & Updated Knowledge

## Methodology

Each hypothesis was tested computationally using the Berggren tree generated to depth 13 (797,161 nodes). All experiments are reproducible via the Python demos in `demos/`.

---

## Hypothesis 1: Spectral Gap — ✓ CONFIRMED (with refinement)

### Original Claim
"The spectral gap of the Berggren matrices (3 + 2√2 − 1 ≈ 4.83) governs the convergence rate of oracle refinement."

### Experiment
Computed eigenvalues of B₁, B₂, B₃ using `numpy.linalg.eigvals`. Tracked meta-oracle convergence for 5 target ratios across 20 iterations.

### Results
- B₂ eigenvalues: {5.828, −1.000, 0.172} — spectral gap = **4.828** ✓
- B₁, B₃ eigenvalues: all ≈ 1.000 — spectral gap ≈ **0** (unexpected!)
- Convergence rate |λ₂/λ₁| = 1/(3+2√2) = 3−2√2 ≈ 0.172
- Empirical hypotenuse growth ≈ 3.92 (below 5.83 due to path mixing)

### Refinement
The spectral gap applies specifically to B₂. The full meta-oracle convergence involves all three matrices, and the effective rate depends on the proportion of B₂ steps in the greedy path. 

### Updated Knowledge
**B₂ is the "engine" of the tree** — it drives exponential growth in the hypotenuse. B₁ and B₃ are "rotational" — they change the shape but not the scale of triples.

---

## Hypothesis 2: Fractal Dimension — ✗ REFUTED (corrected)

### Original Claim
"The distribution of a/c ratios at depth n converges to a fractal measure with Hausdorff dimension approximately log(3)/log(3+2√2) ≈ 0.622."

### Experiment
Box-counting dimension estimation on a/c ratios at depths 1–13, with 20 logarithmically spaced scales.

### Results
- Predicted dimension: 0.623
- Observed dimension at depth 13: **0.952** (52.8% relative error)
- The ratios are **dense** in (0,1) — dimension of support = 1.0

### Root Cause of Error
The formula d = log(N)/log(1/r) assumes uniform contraction ratio r across all branches. But B₁ and B₃ have contraction ≈ 1 (near-isometric), so the IFS has heterogeneous rates. The correct model gives d = 1 for the support.

### Correction
The value 0.623 is a **multifractal exponent** (likely D_∞ or the minimum Hölder exponent of the natural measure), not the Hausdorff dimension.

### New Sub-Hypothesis
**H2a**: The natural counting measure at depth n has Rényi dimension D_q with D_∞ → log(3)/log(3+2√2) as n → ∞.
**Status**: Untested. Requires computation of Rényi entropies at multiple scales.

---

## Hypothesis 3: Effective Branching Factor — ✗ DECISIVELY REFUTED

### Original Claim
"Since the M₁ branch collapses for (0,1,1), the meta oracle's effective branching factor is 2, not 3."

### Experiment
Generated complete tree to depth 13, counted children of every node.

### Results
- Total nodes examined: 797,161
- Nodes with 3 children: 797,161 (100.000%)
- Nodes with <3 children: **0** (0.000%)
- Effective branching factor: **3.000000**
- Shannon entropy: n × log₂(3) = 1.584963n

### Explanation
(0,1,1) is not a primitive Pythagorean triple and never appears in the tree. The root (3,4,5) and all its descendants have all-positive components, ensuring all three branches are valid.

### Updated Knowledge
**The Berggren tree is a perfect ternary tree.** This is a theorem, not just an empirical observation — it follows from the positivity properties of primitive triples.

---

## Hypothesis 4: Quaternionic Extension — ◐ PARTIAL

### Original Claim
"The Pythagorean equation generalizes to a² + b² + c² = d² (quadruples). The corresponding quaternary tree should connect to a 'hyper-meta oracle.'"

### Experiment
1. Enumerated 347 primitive quadruples with d ≤ 100
2. Constructed 5 candidate 4×4 generator matrices
3. Tested whether they preserve a² + b² + c² = d²

### Results
- Quadruple enumeration: ✓ (347 found)
- Quaternionic interpretation: ✓ (pure quaternion q = ai+bj+ck, |q| = d)
- Matrix tree construction: **✗ FAILED** — none of the 5 candidates preserve the quadratic form

### Structural Obstruction
The group O(3,1;ℤ) does not admit a simple "Berggren-like" tree. The parameter space for quadruples is 3-dimensional, and the relevant arithmetic group is higher-rank.

### New Direction
Replace matrix generators with **quaternion multiplication**: multiply a Hurwitz integer by carefully chosen unit quaternions.

---

## Hypothesis 5: p-adic Periodicity — ◐ PARTIALLY REFUTED, REPLACED

### Original Claim
"The tree modulo p has period dividing p² − 1."

### Experiment
Computed ord(Bᵢ mod p) for p = 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47.

### Results
- Hypothesis holds for p = 2 only (1/15 primes)
- B₁, B₃: period = p for all odd primes tested
- B₂: period is more complex, related to multiplicative order of 3+2√2 in 𝔽_p

### Key Discovery
B₁ and B₃ are **unipotent** modulo every odd prime (all eigenvalues ≡ 1 mod p). Unipotent matrices in GL(n, 𝔽_p) have order dividing p^(n-1). For 3×3 matrices, this gives order dividing p², but experimentally the order equals exactly p.

### Replacement Conjecture
**H5a**: ord(B₁ mod p) = ord(B₃ mod p) = p for all primes p ≥ 3.

**H5b**: ord(B₂ mod p) divides (p−1) when 2 is a QR mod p, and divides 2(p+1) otherwise.

---

## New Hypotheses Generated by Experiments

### H6: Phase Space Foliation
**Claim**: The meta-oracle trajectories in (a/c, b/c) space foliate the quarter-circle arc (constraint: (a/c)² + (b/c)² = 1) into invariant curves. Each target ratio τ defines a unique invariant curve.

**Evidence**: The phase space plot (oracle_phase_space.png) shows non-crossing trajectories.

**Status**: Untested formally.

### H7: Growth Rate Mixing
**Claim**: The mean hypotenuse growth rate along meta-oracle paths equals the geometric mean of eigenvalues weighted by the branching probability: (5.828 × 1 × 1)^(1/3) ≈ 1.80.

**Evidence**: Empirical growth ≈ 2.86 on greedy paths (higher due to B₂ selection bias).

**Status**: Needs theoretical analysis.

### H8: Universality of Spectral Gap
**Claim**: For any number-theoretic tree generated by integer matrices preserving an indefinite form, the spectral gap of the dominant generator controls the meta-oracle convergence rate.

**Evidence**: Consistent with Berggren case, untested for other trees (e.g., Stern-Brocot tree, Calkin-Wilf tree).

**Status**: Open.

### H9: p-adic Oracle
**Claim**: The Berggren tree modulo p defines a "p-adic oracle" that predicts Pythagorean triples mod p. The oracle's period (= p for B₁, B₃) provides a p-adic error-correcting capability.

**Evidence**: Orbit analysis confirms Pythagorean relation is preserved mod p throughout orbits.

**Status**: Needs coding-theoretic analysis.

---

## Summary Scorecard

| # | Hypothesis | Status | Confidence |
|---|-----------|--------|------------|
| H1 | Spectral gap governs convergence | ✓ Confirmed (B₂ only) | 95% |
| H2 | Hausdorff dimension ≈ 0.623 | ✗ Refuted → multifractal | 99% |
| H3 | Branching factor = 2 | ✗ Refuted (it's 3) | 100% |
| H4 | Quaternionic tree exists | ◐ Algebra works, tree fails | 90% |
| H5 | Period divides p²−1 | ✗ Refuted → period = p | 99% |
| H6 | Phase space foliation | ◐ Visually supported | 60% |
| H7 | Growth rate = geometric mean | ✗ Doesn't match | 40% |
| H8 | Universal spectral gap control | ◐ Plausible | 50% |
| H9 | p-adic error correction | ◐ Promising | 45% |
