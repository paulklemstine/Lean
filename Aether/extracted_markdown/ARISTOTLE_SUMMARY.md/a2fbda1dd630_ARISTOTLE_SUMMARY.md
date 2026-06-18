# Summary of changes for run 8ff29ad6-e1e2-4ede-a672-9ea44ce4030f
## Completed: Lorentzian Polynomials in Determinantal Point Processes

### Lean Formalization (`Catalog/Pythagorean/DPPLorentzian.lean`)

Built a complete theory connecting determinantal point processes, Lorentzian polynomials, and negative dependence. The file defines 7 novel definitions and proves 11 theorems with only 1 sorry (the Lorentzian conjecture, explicitly marked as such).

**Novel Definitions:**
- `DPPKernel` — Bundled PSD symmetric real matrix
- `principalMinor` — Principal minor (determinant of principal submatrix)
- `dppPartitionFunction` — Multivariate generating polynomial Z_K(x) = Σ_S det(K_S) ∏_{i∈S} x_i
- `dppHomogeneousComponent` — Degree-d homogeneous layer
- `singleInclusionWeight` / `pairInclusionWeight` — Inclusion weight functions
- `IsBrandenHuhLorentzian` — Brändén–Huh Lorentzian polynomial predicate

**Proved Theorems (no sorry):**
1. `principalMinor_nonneg` — Principal minors of PSD matrices are nonneg
2. `principalMinor_empty` — Empty set minor equals 1
3. `dpp_pairwise_negative_dependence` — **Fischer inequality**: det(K_{ij}) ≤ K_ii · K_jj
4. `dpp_pairInclusionWeight_nonneg` — **2×2 Fischer lower bound**: 0 ≤ det(K_{ij})
5. `dpp_partitionFunction_ge_one` — **Spectral lower bound**: det(I+K) ≥ 1 for PSD K (uses eigenvalue decomposition)
6. `dpp_singleInclusion_nonneg` — Diagonal entries of PSD matrices are nonneg
7. `dpp_partitionFunction_aeval_eq_sum` — Polynomial evaluation equals principal minor sum
8. `dpp_partitionFunction_uniformSpecialization` — **Uniform specialization**: Z_K(t,...,t) = det(I+tK) (cross-domain bridge, proved via Leibniz formula + permutation restriction bijection)
9. `dpp_partitionFunction_eval_zero` — Partition function at zero is 1
10. `dpp_fischer_sandwich` — Full 0 ≤ det(K_{ij}) ≤ K_ii·K_jj sandwich
11. `dpp_pairInclusionWeight_symm` — Symmetry of pair weights
12. `dpp_diagonal_det_eq_prod` — det(I + t·diag(w)) = ∏(1 + t·w_i)

**Stated Conjecture (with sorry):**
- `dpp_partition_function_lorentzian_conjecture` — Lorentzianity of homogeneous components (requires stability → Lorentzianity bridge)

### Other Deliverables

- **ARTICLE.md** — 1750+ word popular science article about repulsive randomness and hidden geometry
- **RESEARCH_PAPER.md** — 3250+ word research paper with definitions, theorems, detailed proof sketches, algorithms, applications, computational experiments, and references
- **FUTURE_DIRECTIONS.md** — 5 research directions with structured format including conjectures, tests, proof strategies, and domain bridges (quantum entanglement, matroid Hodge theory, random matrix universality)
- **demo.py** — Working Python demo with 5 demonstrations (basic properties, negative dependence, Lorentzian test, spectral connection, matrix type comparison)
- **algorithms.py** — Certified algorithms for principal minor computation, negative dependence certification, and Lorentzian signature testing
- **applications.py** — Applications to diverse subset selection and repulsive particle simulation
- **3 visualization scripts** — Correlation heatmap, spectral bridge, Fischer inequality plots
- **1 interactive HTML demo** — Fischer inequality explorer with sliders
- **PACKAGE.json** — Complete JSON data package for web templating