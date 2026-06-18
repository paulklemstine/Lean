# Future Directions: Oracle-Trace Cobham Invariance

## Breakthrough Opportunities (ranked by impact)

### 1. Coinductive Trace Extension and Infinite Oracle Streams

**Theorem Statement**: For coinductive oracle traces (infinite streams), define the lcvpDepth as the supremum of finite prefix agreement depths. Prove that the ultrametric completion of finite trace spaces under lcvpDist yields a compact ultrametric space, and that admissible simulations extend continuously to the completion.

**Proof Strategy**:
- Use Lean 4's coinductive types to define `Stream' α` traces
- Define the completion metric via `1/(lcvpDepth+1)` extended to supremum
- Prove continuity of admissible transductions using the depth-loss bound
- Apply Banach fixed-point theorem for oracle iteration semantics

**Why This Is Revolutionary**: Extends Cobham invariance from finite computations to reactive/streaming oracle systems. Connects to process algebra bisimulation and continuous model checking.

**Catalog Leverage**: Build on `traceBall_intersection_rigidity`, `admissibleSimulation_ball_image`

**Research Mode**: formalize

**Estimated Depth**: 4

---

### 2. Tropical/Entropy Data-Processing Inequality for Transduced Traces

**Theorem Statement**: Define the tropical entropy of a trace set S as `h_trop(S) = limsup_{n→∞} (1/n) · log_trop(|{x ∈ S : |x| ≤ n}|)` where log_trop is the tropical logarithm. Prove that for any admissible simulation A, `h_trop(A(S)) ≤ h_trop(S)`, establishing a data-processing inequality in the tropical semiring.

**Proof Strategy**:
- Formalize tropical logarithm via the min-plus semiring
- Use `traceComplexity_mono` and ball-image control to bound transduced set sizes
- Apply subadditivity / Fekete's lemma (`Subadditive.tendsto_lim`) for the limsup
- Derive the DPI as a consequence of monotonicity under bounded-distortion maps

**Why This Is Revolutionary**: Creates a tropical information theory for oracle computation, connecting to rate-distortion theory and the `rate_distortion_duality_of_coherent_proof_semiring` already in the catalog.

**Catalog Leverage**: `traceComplexity_mono`, `oracleTrace_thermodynamic_entropy_bridge`, `rate_distortion_duality_of_coherent_proof_semiring`

**Research Mode**: formalize

**Estimated Depth**: 3

---

### 3. Multiplicative Distortion Invariance (True Quasi-Isometry)

**Theorem Statement**: Strengthen `AdmissibleSimulation` to require `lcvpDepth(f(x), f(y)) ≥ (1/K) · lcvpDepth(x,y) - C` (multiplicative + additive). Prove that under mutual quasi-isometric simulation, the exponential growth rate `exp_rate(S) = lim_{n→∞} (traceComplexity(S,n))^{1/n}` is invariant up to the K-th root.

**Proof Strategy**:
- Define `QuasiIsometricSimulation` with multiplicative constant K and additive C
- Prove ball-volume comparison: `|B(c, r/K - C)| ≤ |f(B(c,r))| ≤ |B(f(c), Kr+C)|`
- Use these volume comparisons to bound exponential growth rates
- Derive invariance of `exp_rate^{1/K}` as a corollary

**Why This Is Revolutionary**: Gives the full Cobham thesis analogue: polynomial degree is preserved under polynomial-time reductions, exponential rate under quasi-isometric reductions.

**Catalog Leverage**: `admissibleSimulation_ball_image`, `cobham_invariance_sandwich`

**Research Mode**: formalize

**Estimated Depth**: 4

---

### 4. Semiring-Valued Myhill–Nerode for Oracle Traces

**Theorem Statement**: Define the Nerode equivalence on oracle traces: `x ~ y` iff for all continuations `z`, `weight(xz) = weight(yz)` in the semiring W. Prove that the number of Nerode equivalence classes equals the rank of the Hankel matrix of trace weights, and that this rank is invariant under admissible bi-simulation.

**Proof Strategy**:
- Define Hankel matrix `H[x,y] = weight(x ++ y)` over W
- Prove Nerode classes = rows of H up to W-linear dependence
- Show admissible simulation induces a bounded-rank perturbation of H
- Conclude rank invariance up to the depth-loss constant

**Why This Is Revolutionary**: Connects automata minimization to oracle complexity. The Hankel matrix approach links to weighted automata learning (the Angluin-style algorithm) and provides a concrete algorithm for determining if two oracle-trace systems are Cobham-equivalent.

**Catalog Leverage**: `WeightedTraceTransducer`, `BiAdmissibleEquiv`, `bounded_rel_zero_iff_output_eq` (TropicalNerode)

**Research Mode**: formalize

**Estimated Depth**: 5

---

### 5. Neural Trace Compression and Lipschitz Certification

**Theorem Statement**: For a neural sequence model f : OracleTrace α → OracleTrace β, if f is PrefixLipschitz with constants (K, C), then the ε-covering number of f's image satisfies `N(ε, f(S)) ≤ N(ε/K, S)`. Derive certified robustness radii from this bound.

**Proof Strategy**:
- Define ε-covering numbers in terms of traceBall
- Use `admissibleSimulation_ball_image` to relate input/output coverings
- Derive `CertifiedPrefixRobust` bounds as corollaries
- Connect to existing `certified_robustness_from_margin_and_lipschitz`

**Why This Is Revolutionary**: Provides a foundation for certifiably robust sequence classifiers (NLP, genomics, time series) using ultrametric geometry instead of Euclidean Lipschitz bounds.

**Catalog Leverage**: `certified_radius_transfer_quantum_neural`, `PrefixLipschitz`, `certified_robustness_from_margin_and_lipschitz`

**Research Mode**: formalize

**Estimated Depth**: 3

---

## Under-explored Territory

- **Tropical Zeta Functions of Trace Languages**: Define `Z_S(t) = Σ_n traceComplexity(S,n) · t^n` as a formal power series. Prove rationality criteria for recognizable trace languages, connecting to the `EMLZetaSemantics` work.

- **Quantum Oracle Channels**: Model quantum oracle queries as channels mapping density matrices. The lcvpDepth becomes a quantum fidelity measure, and admissible simulations become quantum channels with bounded noise.

- **Lattice Cryptographic Hardness Surrogates**: The exponential growth rate of trace balls over lattice-point alphabets provides a complexity surrogate for shortest-vector problems. Cobham invariance would show that different lattice bases yield equivalent complexity.

## Cross-Domain Bridges

| Source Domain | Target Domain | Bridge Mechanism |
|---|---|---|
| Ultrametric geometry | ML robustness | PrefixLipschitz → CertifiedPrefixRobust |
| Cobham invariance | Post-quantum crypto | Growth exponent invariance under simulation |
| Weighted automata | Thermodynamic entropy | Weight sums → partition functions |
| Coarse geometry | Complexity theory | Quasi-isometry → bounded distortion |
| Tropical semirings | Information theory | Min-plus entropy → rate-distortion |

## Open Problems Encountered

1. **Exact characterization of lcvpDepth for append**: We proved `lcvpDepth(x++s, y++s) ≥ lcvpDepth(x,y)` but the exact value depends on whether one list is a prefix of the other. A complete characterization would enable tighter bounds.

2. **Finiteness of traceComplexity without [Fintype]**: The current `Nat.card`-based definition returns 0 for infinite types. A constructive version using decidable membership would be more useful.

3. **Composing BiAdmissibleEquiv**: Composition of bi-admissible equivalences should yield a bi-admissible equivalence with bounded depth loss. This requires careful tracking of the round-trip distortion.
