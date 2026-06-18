# Summary of changes for run 31ae8d9f-1f0b-4c11-a9ca-75a650c19f12
# Nonlinear Tropical Secure Hash Algorithm (NTSHA) — Research Cycle Complete

## Summary

Established the theory of **nonlinear tropical hash functions** through NTSHA, which augments the standard tropical hash TSHA(m,h) = min_i(m_i + h_i) with modular reduction: NTSHA_p(m,h) = min_i((m_i + h_i) mod p). This simple modification breaks the shift equivariance that makes TSHA cryptographically trivial, while introducing a periodic lattice structure connecting to post-quantum cryptography.

## Lean 4 Proofs (17 theorems, 0 sorries)

### `Shared/NTSHACore.lean` — 11 theorems
- **tropicalHash_shift_equivariant**: TSHA satisfies TSHA(m+c, h) = TSHA(m,h) + c
- **ntsha_shift_equivariance_breaks**: NTSHA breaks this property (constructive counterexample: p=5, m=(0,3), c=3)
- **ntsha_fiber_periodic / _general**: Shifting any coordinate by multiples of p preserves the hash
- **ntsha_fiber_lattice_invariance**: Full (pℤ)^k lattice invariance of preimage fibers
- **ntsha_collision_exists**: Collisions always exist via lattice translations
- **ntsha_range_bounded**: Output is always in [0, p)
- **ntsha_locally_determined**: Piecewise-linear structure — hash equals the minimizing component
- **avalancheDeficiency_bounded**: Avalanche deficiency < p
- **ntshaComponent_range / _periodic**: Component-level modular properties

### `Shared/NTSHAFiber.lean` — 6 theorems
- **ntshaFiberSize_nonneg**: Fiber sizes are nonnegative
- **ntshaFiberSize_antitone**: Fiber sizes decrease with hash value (convexity argument)
- **ntshaFiberSize_sum**: Fiber sizes telescope to p^k (partition of input space)
- **ntshaFiberSize_at_zero / _at_max**: Extremal fiber sizes (p^k-(p-1)^k and 1)
- **ntsha_output_bias_lower_bound**: Most probable output has probability ≥ 1/p

## Key Mathematical Insights

1. **Symmetry breaking**: Modular reduction destroys shift equivariance ~66% of the time (p=7, k=4)
2. **Lattice structure**: Fibers are unions of cosets of (pℤ)^k, connecting to lattice-based post-quantum crypto
3. **Exact counting**: Fiber size for hash value y is (p-y)^k - (p-y-1)^k — a telescoping formula
4. **Output bias**: Strong bias toward zero; imbalance ratio can exceed 100:1

## Other Deliverables

- **ARTICLE.md**: Popular science article about the ideas (no mention of formal verification)
- **RESEARCH_PAPER.md**: Full research paper with proofs, algorithms, and discussion
- **FUTURE_DIRECTIONS.md**: 5 research directions including tropical-lattice security reduction (grand challenge) and multi-round avalanche optimization
- **PACKAGE.json**: Complete artifact bundle with 3 interactive HTML demos
- **demo.py / algorithms.py**: Python implementations and numerical demonstrations
- **visualize_ntsha.py**: Matplotlib visualization script

## Novel Definitions
- NTSHA hash function (nonlinear tropical hash with modular reduction)
- NTSHA fiber (preimage set with lattice structure)
- Avalanche deficiency (measuring deviation from ideal avalanche)
- Fiber size function S_p(y,k) = (p-y)^k - (p-y-1)^k

## Falsifiable Conjecture
The Tropical Avalanche Threshold conjecture was tested computationally and found to be FALSE in its original form — zero-avalanche proportions *increase* with dimension (~73% for k=4), not decrease. This is because higher dimensions make it less likely that a perturbed component is the minimizer. A revised multi-round conjecture is proposed in FUTURE_DIRECTIONS.md.