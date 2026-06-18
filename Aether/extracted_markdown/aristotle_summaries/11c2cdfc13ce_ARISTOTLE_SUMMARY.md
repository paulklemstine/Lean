# Summary of changes for run ec065c65-a142-4c3d-8528-9c21476055a2
# Beal Obstruction Theory: CRT Compression and Certified Cubic Obstructions

## Summary

I built a formally verified local-global theory of primitive residue obstructions for Beal-type equations (A^x + B^y = C^z), with **zero `sorry` statements** in all Lean proofs.

## Formally Verified Theorems (Lean 4, all sorry-free)

The Lean code is organized in `Speculative/Beal/` with five files:

### Core Infrastructure (`Defs.lean`, `Monotonicity.lean`)
- **`PrimitiveResidueSolution N x y z`**: Definition — existence of unit triples in ZMod N satisfying a^x + b^y = c^z
- **`primitiveResidueSolution_of_dvd`**: Solutions descend from N to any divisor M
- **`no_primitiveResidueSolution_of_dvd`**: Obstructions propagate to all multiples — one obstructing modulus blocks infinitely many

### CRT Compression Theorem (`CRT.lean`)
- **`primitiveResidueSolution_mul_iff`**: For coprime M, N: PRS(M·N) ↔ PRS(M) ∧ PRS(N). This is the foundational local-global decomposition theorem, proved using Mathlib's `ZMod.chineseRemainder` ring isomorphism.
- **`cubic_obstruction_of_prime_power_obstruction`**: Any prime power obstruction propagates to the full modulus.

### Certified Cubic Obstructions (`CubicObstruction.lean`)
- **`no_primitiveResidueSolution_7_cube`**: ¬PRS(7, 3, 3, 3) — verified by exhaustive computation
- **`no_primitiveResidueSolution_2_cube`**: ¬PRS(2, 3, 3, 3)
- **`no_primitiveResidueSolution_13_cube`**: ¬PRS(13, 3, 3, 3)
- **`exists_small_cubic_obstruction`**: ∃ N, 2 ≤ N ∧ N ≤ 10^6 ∧ ¬PRS(N, 3, 3, 3) — witness N = 7
- **`no_pairwise_coprime_sum_of_cubes_mod_7`**: For all A,B,C coprime to 7: A³ + B³ ≠ C³ (a key step in Euler's FLT³ proof)

### Structural Classification (`CubeSubgroup.lean`)
- **`every_unit_is_cube_of_prime_mod3_eq2`**: For primes p ≡ 2 (mod 3), every unit has a cube root — the cube map is a bijection
- **`primitiveResidueSolution_of_prime_mod3_eq2`**: For such primes with p ≥ 5, PRS(p, 3, 3, 3) always holds — obstruction is impossible
- **`cubic_obstructing_primes`**: Certified: {2, 7, 13} all obstruct (3,3,3)
- **`cubic_non_obstructing_primes`**: Certified: {3, 5, 11} all admit solutions

## Other Deliverables

- **ARTICLE.md**: A ~2500-word popular science article explaining how modular arithmetic turns infinite impossibility proofs into finite puzzles
- **RESEARCH_PAPER.md**: A comprehensive ~5000-word research paper with full theorem statements, proof sketches, algorithms, complexity analysis, and computational experiments
- **FUTURE_DIRECTIONS.md**: Five falsifiable hypotheses including the finiteness conjecture for cubic obstructors, Cauchy-Davenport threshold analysis, and the ABC+residue hybrid program
- **demo.py**: Working demonstrations of cube image sets, sumset avoidance, CRT compression, and multi-signature comparison
- **algorithms.py**: Complete implementations of the PRS checker, CRT decomposition engine, cube subgroup analysis, and systematic obstruction search
- **applications.py**: Certificate generation, CRT obstruction compilation, FLT³ analysis, and multi-signature comparison
- **PACKAGE.json**: Complete JSON bundle of all deliverables

## Key Mathematical Finding

The primes 2, 7, and 13 are the only primes below 1000 that obstruct signature (3,3,3). Together they cover ~60.4% of all positive integers. The structural explanation is that obstruction requires cubes to form a proper subgroup (only possible when p ≡ 1 mod 3), and among such primes, only p = 7 and p = 13 have cube subgroups sparse enough for sumset avoidance.