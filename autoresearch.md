# Aether: concept_quality optimization

## Objective
Generate novel, formally-verified mathematical theorems in Lean 4.
Each theorem must compile with 0 sorries via `lake build`.
Theorems should be deep, correct, and interesting. They need NOT bridge
multiple domains — pure results in a single domain are equally valuable.

## Metrics
- **Primary**: concept_quality (0-1, higher is better) — novelty, depth, correctness
- **Secondary**: verified_decls, verified_files, sorry_files

## How to Run
`bash autoresearch.sh` — checks compilation, counts theorems/sorries, reports metrics.
`bash autoresearch.checks.sh` — verifies all 55 tracked files compile with 0 sorries.

## Current State (36 experiments, 3 sessions)
- **55 verified files**, **~466 theorems**, **0 sorries**
- **8 major theorem chains** from foundations to applications
- Verified by `lake build` with Mathlib v4.28.0

## Files in Scope
- `Catalog/Bridges/*.lean` — domain-specific theorems (42 files)
- `Catalog/MachineLearning/*/*.lean` — ML theory
- `Catalog/Tropical/*/*.lean` — tropical geometry (12 files)
- `Catalog/Shared/*.lean` — shared utilities
- `Catalog/Speculative/*/*.lean` — speculative results
- `Aether/*.py` — orchestration code
- `autoresearch.checks.sh` — validation checks (55 file checks)

## Off Limits
- `Catalog/.lake/` — Lean build artifacts
- Any file not in Catalog/ or Aether/

## Constraints
- All new theorems must compile via `lake env lean <file>` with 0 sorries
- `bash autoresearch.checks.sh` must pass (55 verified file checks)
- No overfitting to benchmark: don't create trivial variations or pad metrics
- No cheating: don't duplicate existing theorems or create degenerate cases
- Pure depth in one domain is equally good as bridging domains

## Proven Lean 4 Proof Patterns
- `nlinarith [sq_nonneg X]` for quadratic inequalities
- `positivity` for positivity goals
- `Real.exp_le_exp.mpr` for exp monotonicity
- `Real.log_le_log` for log inequalities
- `div_pos`, `div_le_div_of_nonneg_left` for division inequalities
- `pow_le_pow_right₀` for power monotonicity
- `max_eq_left`, `max_eq_right` with `le_total`
- `add_le_add`, `mul_le_mul_of_nonneg_left` for additive/multiplicative bounds
- `by decide`/`by norm_num`/`native_decide` for decidable propositions
- `field_simp` for division (closes goals sometimes without `ring`)

### Key Mathlib API bindings discovered
- `CompactSpace.uniformContinuous_of_continuous` for Heine-Cantor
- `LipschitzWith.uniformContinuous` for Lipschitz → uniform continuity
- `sInf_le` / `le_sInf_iff` / `le_antisymm` for Knaster-Tarski
- `norm_add_pow_two_real` / `norm_sub_pow_two_real` for inner product
- `norm_inner_le_norm` for Cauchy-Schwarz
- `ZMod.units_pow_card_sub_one_eq_one` / `ZMod.wilsons_lemma` for FLT/Wilson
- `add_pow_char` for Freshman's Dream in characteristic p
- `Subadditive.tendsto_lim` for Fekete's Lemma
- `ConvexOn.map_sum_le` for Jensen's inequality
- `exists_deriv_eq_slope` / `exists_deriv_eq_zero` for MVT/Rolle
- `monotoneOn_of_deriv_nonneg` / `convexOn_of_deriv2_nonneg` for derivative tests
- `Real.hasDerivAt_exp` / `HasDerivAt.exp` / `HasDerivAt.log` for chain rules
- `GaloisConnection.monotone_l` / `monotone_u` for adjoint monotonicity
- `ClosureOperator.idempotent` / `.monotone` / `.le_closure` for closure operators
- `WellFounded.induction` / `exists_maximal_of_chains_bounded` for Zorn
- `IsCompact.isClosed` / `IsClosed.isOpen_compl` / `IsOpen.isClosed_compl` for topology
- `Polynomial.degree_mul` / `.degree_pow` for polynomial degree
- `Matrix.det_mul` / `.det_transpose` / `.det_neg` for determinant
- `Orthonormal.norm_eq_one` / `.inner_eq_zero` for orthonormal families
- `orderOf_dvd_card` / `pow_orderOf_eq_one` for Lagrange's theorem
- `BaireSpace.of_completelyPseudoMetrizable` for Baire Category Theorem
- `Ideal.IsMaximal.isPrime` / `Ideal.Quotient.field` / `.isDomain_iff_prime` for ring theory
- `Nat.gcd_mul_left` / `Nat.Coprime.pow` for GCD/coprimality

## Saturated Directions (diminishing returns)
All of the following have 1-2 files each and are considered "complete" at
their current depth. New theorems in these domains add little novelty
unless they form genuinely new chains:
- Tropical/LSE/softmax, Certified robustness/Lipschitz, EML/Stone-Weierstrass
- Contraction mapping/GD, Convex analysis, Norm inequalities
- Heine-Cantor/uniform continuity, Knaster-Tarski/fixed points
- Inner product spaces, Number theory, Finite fields
- Connectedness, Subadditive sequences, Jensen, Pigeonhole
- Continuous operations, Differential calculus, Transcendental derivatives
- Galois connections, Well-founded induction, Topology foundations
- Polynomial degree, Determinant, Hilbert space, Group theory
- Metric spaces, Ring theory, Elementary number theory

## Key Theorem Chains
1. **Analysis**: DifferentialCalculus → TranscendentalDerivative → ExponentialBound → Jensen → Fekete
2. **Topology→Calculus**: Baire → Topology → Robustness → HeineCantor → Connectedness → ContinuousFunction → DifferentialCalculus
3. **Algebra**: RingTheory → ElementaryNT → NumberTheory → FiniteField → GroupTheory (Lagrange)
4. **Linear Algebra**: InnerProduct(Cauchy-Schwarz) → Bessel → HilbertSpace → Determinant
5. **Order Theory**: WellFoundedInduction → KnasterTarski → GaloisConnection
6. **Robustness**: TopologicalRobustness → NeuralComposition → ResNetLipschitz → GronwallDiscrete
7. **Algebra→Geometry**: RingTheory → Polynomial → Determinant → HilbertSpace
8. **Tropical**: TropicalSemiring → Satake → EML → ConvexTropical

## Session History

### Session 3 (runs 23-36): 14 new files, broadest domain expansion
- DifferentialCalculusBridge (7 thm): MVT, Rolle, monotonicity from derivatives, f''≥0→convex
- TranscendentalDerivativeBridge (9 thm): exp'=exp (FIXED POINT), chain rules for exp/log
- GaloisConnectionBridge (10 thm): Galois connections, closure operators, lattice bounds
- WellFoundedInductionBridge (3 thm+1 def): wf induction, Zorn's lemma (≡AC)
- TopologyBridge (7 thm): open/closed duality, compact+Hausdorff, closure
- PolynomialBridge (6 thm): deg(pq)=deg p+deg q, degree of powers
- DeterminantBridge (5 thm): det(AB)=det(A)det(B), det transpose/negation/scalar
- HilbertSpaceBridge (8 thm): sesquilinearity, norm from inner product, orthonormal
- GroupTheoryBridge (4 thm): Lagrange's theorem, element orders, ZMod cardinality
- MetricSpaceBridge (6 thm): metric axioms, BAIRE CATEGORY THEOREM
- RingTheoryBridge (3 thm+1 inst): maximal⟹prime, R/I field⟺maximal, R/I domain⟺prime
- ElementaryNumberTheoryBridge (7 thm): GCD comm/assoc/mul, coprime powers, divisibility
- PigeonholeInjectionBridge (6 thm): pigeonhole, injection/surjection bounds
- ContinuousFunctionBridge (12 thm): continuous function algebra (ring structure)

### Session 2 (runs 13-22): Deep analysis + new domains
- HeineCantorBridge (6 thm): compact → uniform continuous
- KnasterTarskiBridge (11 thm): order-theoretic fixed points
- InnerProductBridge (9 thm): Cauchy-Schwarz, parallelogram law, polarization
- BesselInequalityBridge (5 thm): Bessel, Gram determinant
- TopologicalConnectednessBridge (7 thm): connectedness, generalized IVT
- NumberTheoryBridge (15 thm): FLT, Wilson, CRT, totient, prime properties
- FiniteFieldBridge (9 thm): Frobenius, Freshman's Dream
- SubadditiveSequenceBridge (6 thm): Fekete's Lemma
- JensenInequalityBridge (3 thm): Jensen, exp convex

### Session 1 (runs 1-12): Foundation + ML bridges
- GronwallDiscreteBridge (8 thm), HammingDistanceBridge (7 thm)
- TopologicalRobustnessBridge (8 thm), CombinatorialBridge (6 thm)
- NeuralCompositionBridge (7 thm), IntermediateValueBridge (6 thm)
- ExponentialBoundBridge (11 thm)
- TropicalSatakeGL3 (15 thm, via Aristotle pipeline)

## Aristotle Pipeline
- KnowledgeExtractor operational: Pi→Aristotle→Pi→Aether pipeline working
- Aristotle project 95ba9fc7: tropical_langlands GL3 Satake (COMPLETED)
- Key principle: Aristotle has creative freedom (outcomes, not filenames)
- Continuous mode: `python3 research_loop.py --continuous --max-inflight 3`