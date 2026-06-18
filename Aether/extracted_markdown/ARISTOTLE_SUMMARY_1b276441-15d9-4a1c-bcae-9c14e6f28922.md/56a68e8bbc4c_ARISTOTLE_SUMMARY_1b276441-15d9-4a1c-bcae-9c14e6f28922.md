# Summary of changes
## What the "algorithm" actually is

The "Quantum Manifold Repulsor" is **Fermat's factorization method** (c. 1643) with quadratic residue sieving — a well-known classical algorithm, not a novel breakthrough. The Python code's impressive output is misleading because:

1. **For "stepping stones" (RSA-110 through RSA-155)**: It generates easy fake "Doppelgänger" semiprimes instead of factoring the actual RSA numbers.
2. **For RSA-100**: It injects the known factors as a "hint."
3. **For truly unfactored RSA numbers (RSA-260+)**: It also generates doppelgängers, not factoring the real targets.
4. **It crashes on RSA-1024** with `ValueError: isqrt() argument must be nonnegative` because x² - N goes negative.

The algorithm has complexity O((q-p)²/√N) per Fermat step, which is exponential in the bit length for RSA numbers where |p-q| ≈ √N. This is not a polynomial-time factoring algorithm.

## What was formalized and proved in Lean 4

I created `Factoring/GeometricRepulsor.lean` with **all proofs machine-verified** (zero `sorry`s, only standard axioms):

### Correctness theorems
- **`fermat_diff_sq`**: x² - y² = (x - y)(x + y) — the core algebraic identity
- **`fermat_factor_correct`**: If N = x² - y², then N = (x-y)(x+y)
- **`odd_fermat_rep`**: Every product of odd integers p·q equals ((p+q)/2)² - ((q-p)/2)²
- **`fermat_nontrivial`**: The factors are nontrivial when y > 0 and x - y > 1
- **`fermat_solution_point`**: The exact solution coordinates for N = p·q

### Sieve soundness (the optimization used by the algorithm)
- **`quad_residues_mod_64`**: k² mod 64 ∈ {0,1,4,9,16,17,25,33,36,41,49,57}
- **`quad_residues_mod_11`**, **`quad_residues_mod_13`**, **`quad_residues_mod_17`**, **`quad_residues_mod_19`**: Analogous for each sieve modulus
- **`sieve_sound_all`**: A perfect square passes ALL sieve checks — the sieve never produces false negatives

### Computable implementation
- **`fermatSearchSieved`**: A computable Fermat search with the mod-64 and mod-11 sieves
- **`fermatFactorSieved`**: Top-level factoring function, verified via `#eval` on examples (15, 77, 143, 221, 1073, 10403, 997×1009, 10007×10009)

### Infrastructure fix
I also created `BerggrenTree.lean` (the missing dependency for the pre-existing `FermatFactor.lean` and `InsideOutFactor.lean`), which defines the Berggren ternary tree for generating Pythagorean triples and proves that every node produces a valid Pythagorean triple. The entire `Factoring` module now builds successfully.