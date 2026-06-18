# Summary of changes for run 783480fc-b257-4ebb-9b22-71795232224b
## Completed: Formal Arithmetic Dynamics of Integer Polynomials

I've created a comprehensive formal mathematics development around Mahler measure, Lehmer's problem, and the arithmetic-dynamics connection. **All Lean proofs compile with zero `sorry` statements** and use only standard axioms (propext, Classical.choice, Quot.sound).

### Formally Verified Mathematics (Lean 4)

**4 files, 16 theorems, 0 sorry:**

**`Speculative/MahlerMeasure/Defs.lean`** — Core definitions and root-factorization theory:
- `logMahlerMeasureInt` / `mahlerMeasureInt`: Mahler measure for ℤ[X] via complexification
- `logMahlerMeasureInt_eq_sum_roots`: **Root-factorization formula** — log M(P) = Σ max(0, log‖αᵢ‖) for monic P ∈ ℤ[X]
- `logMahlerMeasureInt_nonneg`: Nonnegativity for monic integer polynomials
- `logMahlerMeasureInt_pos_of_exists_root_norm_gt_one`: Root escape ⟹ positive Mahler measure
- `logMahlerMeasureInt_eq_zero_iff_all_roots_norm_le_one`: Zero iff all roots bounded (biconditional)
- `logMahlerMeasureInt_mul`: Multiplicativity
- `lehmer_reduction_principle`: Structural dichotomy — either log M = 0 or a root escapes

**`Speculative/MahlerMeasure/Cyclotomic.lean`** — Cyclotomic neutrality:
- `logMahlerMeasureInt_cyclotomic_eq_zero`: log M(Φ_n) = 0
- `mahlerMeasureInt_cyclotomic_eq_one`: M(Φ_n) = 1
- `logMahlerMeasureInt_mul_cyclotomic`: Cyclotomic factors are entropy-neutral
- `exp_logMahlerMeasureInt_cyclotomic`: exp(log M(Φ_n)) = 1

**`Speculative/MahlerMeasure/Companion.lean`** — Spectral entropy bridge:
- `companionMatrix`: Companion matrix definition for any commutative ring
- `spectralEntropy`: Sum of max(0, log|λ|) over eigenvalues
- `logMahlerMeasureInt_eq_spectral_entropy`: **log M(P) = spectral entropy of companion matrix** (conditional on charpoly(C_P) = P, a standard result not yet in Mathlib)

**`Speculative/MahlerMeasure/Lehmer.lean`** — Certified positivity for Lehmer's polynomial:
- `lehmerPoly`: X¹⁰ + X⁹ − X⁷ − X⁶ − X⁵ − X⁴ − X³ + X + 1
- `lehmerPoly_monic`, `lehmerPoly_natDegree` (= 10), `lehmerPoly_ne_zero`
- `lehmerPoly_not_cyclotomic`: L ≠ Φ_n for all n (via eval at 1 and cyclotomic nonnegativity)
- `mahlerMeasureInt_lehmerPoly_ne_one`: M(L) ≠ 1 (via IVT: L has a real root in (1,2))
- `logMahlerMeasureInt_lehmerPoly_pos`: **0 < log M(L)** — certified nonzero entropy

### Key Mathematical Achievement

The proof of `logMahlerMeasureInt_lehmerPoly_pos` uses the **intermediate value theorem**: since L(1) = −1 < 0 and L(2) = 1291 > 0, there exists a real root z₀ ∈ (1, 2). This root has |z₀| > 1, so by the entropy-positivity theorem, log M(L) > 0. This is a genuinely nontrivial formally verified result connecting analysis (IVT) to number theory (Mahler measure).

### Other Deliverables

- **`ARTICLE.md`**: ~2500-word popular science article about Lehmer's problem
- **`RESEARCH_PAPER.md`**: ~4000-word research paper with full theorem statements, proof sketches, and computational results
- **`FUTURE_DIRECTIONS.md`**: 5 falsifiable hypotheses (reciprocal sparse gap, entropy rigidity, tropical support bounds, spectral gap coefficient bounds, height-entropy equality)
- **`demo.py`**: Interactive demonstrations of all five key results with numerical verification
- **`algorithms.py`**: Complete algorithmic implementations (root-factorization, circle integral, companion matrix, cyclotomic detection, exhaustive search)
- **`applications.py`**: Applications to toral automorphism entropy, Weil heights, Lehmer landscape analysis
- **`PACKAGE.json`**: Complete JSON data package for web templating