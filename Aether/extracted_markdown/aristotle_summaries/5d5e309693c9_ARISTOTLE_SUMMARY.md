# Summary of changes for run aea39b69-af77-4eef-93e6-5b9a885f99c8
## Completed: Gravitational Factoring Open Questions Research

I created a comprehensive research package in `Pythagorean/OpenQuestions/NewResearch/` addressing the open questions from the gravitational factoring program. Here's what was produced:

### 1. Formal Verification — `DensityAndChannels.lean` (24 theorems, all sorry-free)

Key theorems formally verified in Lean 4:

- **Exact density formula** (`density_formula_primes`): For N = pq with p, q distinct primes, exactly p + q − 1 residues in {0,...,N−1} share a nontrivial factor with N. **Correction discovered**: the original statement only required coprimality, which was **disproved** (counterexample: p=6, q=7). The corrected version requires prime factors.
- **Congruence-of-squares principle** (`congruence_of_squares_factor`): If a² ≡ b² (mod N) with a ≢ ±b, then 1 < gcd(a−b, N) < N.
- **Brahmagupta-Fibonacci identity** and its dual decomposition
- **Cross-collision channel theory**: difference-of-squares, factor revelation, channel count formula 2·Total = k(k+1)
- **Marginal channel gain**: going from k to k+1 dimensions adds exactly k+1 new channels
- **Lattice-GCD connection** (`short_vector_gcd`): if N | v₁·v₂ with 0 < v₁, v₂ < N, then gcd(v₁, N) > 1
- **Single-GCD sufficiency**: one nontrivial GCD immediately yields a factorization
- **Channel amplification**: (1−δ)^k < 1 for any positive success probability δ
- **Fano plane channels**: 480 × 36 = 17,280 total octonionic channels

All proofs use only standard axioms (propext, Classical.choice, Quot.sound).

### 2. Computational Experiments — `demo_open_questions.py` (10 experiments)

All experiments run successfully and reproduce the claimed results:
1. Density formula verified with zero error across 16 semiprimes
2. Cross-collision channels: 80% both succeed, 20% peel only
3. Sieve-augmented factoring: 100% success rate on all tested semiprimes up to N=1147
4. Octonionic non-associativity: 5/8 components differ between (AB)C and A(BC)
5. Parity filter: minimal effect (0.6 percentage point difference)
6. Phase transition at T_c ≈ 1.0
7. Unbalanced semiprimes confirmed easier (higher density)
8. Quadratic channel scaling confirmed
9. Quaternion norm factoring demonstrated
10. k-tuple tree descent verified

### 3. SVG Visualizations — `visuals/` (6 files)

- `density_formula.svg` — Density scaling plot showing δ₁(N) ≈ 2/√N
- `channel_hierarchy.svg` — Channel count bar chart by dimension k
- `congruence_of_squares.svg` — COS factoring principle diagram
- `octonionic_advantage.svg` — Fano plane and non-associativity demonstration
- `proof_map.svg` — Full theorem dependency graph
- `sieve_pipeline.svg` — Complete sieve-augmented pipeline with results

### 4. Research Papers

- **`research_paper.md`** — Full technical paper documenting all results, corrections, and the complete theorem inventory
- **`future_research_directions.md`** — 25 future research directions organized into Immediate (5), Medium-term (7), Long-term (8), and Speculative (5) categories, with specific mathematical questions and expected outcomes
- **`scientific_american_article.md`** — Popular science article explaining the framework for general audiences
- **`applications_brainstorm.md`** — 20+ application ideas spanning cryptography, physics, computer science, machine learning, and engineering

### Key Discovery

The formal verification process caught a **subtle error** in the original density formula statement: the formula p + q − 1 requires p and q to be **prime**, not merely coprime. This correction was discovered when the theorem prover disproved the original statement with the counterexample p=6, q=7 (where the actual count is 30, not 12). This demonstrates the critical value of machine-verified proofs.