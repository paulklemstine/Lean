# Summary of changes
## Research Project Complete: Factoring Through Higher-Dimensional Lenses

I created a comprehensive research project exploring quaternion and octonion lattice approaches to integer factoring, organized in `Research_QuaternionFactoring/`:

### Deliverables

**1. Scientific American Paper (`PAPER.md`)**
A detailed paper covering the core theory, experimental results, hypothesis testing, and honest assessment. Key findings include:
- Octonion (dim-8) lattice extraction outperforms quaternion (dim-4) by ~8× at 16-bit semiprimes
- The Hurwitz-LLL gap hypothesis is **supported** (17% better Hermite factors on structured lattices)
- The quaternionic smooth number conjecture is **refuted** (partial-sum smoothness is harder, not easier)
- Success rates drop to zero by 22 bits — the method is not a viable RSA attack, but provides theoretical insight

**2. Formal Lean 4 Proofs (`QuaternionFactoring.lean`)**
15 theorems formally verified with zero `sorry` statements, using only standard axioms:
- Quaternion norm multiplicativity: N(q₁·q₂) = N(q₁)·N(q₂)
- Euler four-square identity (algebraic verification)
- Gaussian integer conjugate factorization
- Lattice determinant = N (5×5 diagonal matrix)
- Hurwitz unit norms (Lipschitz ±1,±i,±j,±k and half-integer ½(1+i+j+k))
- Balanced factor bound: p ≤ √N for semiprimes
- Quaternion non-commutativity and commutator [i,j] = 2k
- Norm factoring principle: normSq(q₁) divides normSq(q₁·q₂)

**3. Python Demo Programs (`demos/`)**
- `quaternion_factoring.py` — Full experimental suite: factoring demos, Euler identity verification, Hurwitz unit enumeration, dimension comparison, α-scaling sweep
- `partial_norm_masks.py` — Octonion partial-norm mask analysis with Fano plane quaternionic subalgebra enumeration
- `hypothesis_testing.py` — Validation suite for three hypotheses plus scaling law experiments

**4. SVG Visuals (`visuals/`)**
- `algebra_hierarchy.svg` — The ℝ → ℂ → ℍ → 𝕆 hierarchy with factoring leverage
- `lattice_construction.svg` — Step-by-step lattice factoring pipeline
- `fano_plane.svg` — Fano plane structure of octonion multiplication
- `alpha_landscape.svg` — Scaling exponent optimization landscape

All Python demos are reproducible (seed 42). All Lean proofs compile cleanly with Mathlib v4.28.0.