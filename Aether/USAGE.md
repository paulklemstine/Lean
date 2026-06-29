# AETHER Usage Guide

## Current State

AETHER v1.0 is fully operational with:
- **55 verified Lean 4 files**, **~466 theorems**, **0 sorries**
- Pi-Agent (Ollama `kimi-k2.6:cloud`) for concept generation
- Aristotle API integration for formal proof
- `autoresearch.sh` / `autoresearch.checks.sh` for verification and metrics
- 8 major theorem chains spanning foundations to applications

## Quick Start

### Continuous Cycle Mode (production)

```bash
cd /home/raver1975/lean/Aether
PYTHONPATH=. python3 research_loop.py --continuous --max-inflight 3 --max-cycles 50
```

### Single Cycle (test one dispatch)

```bash
cd /home/raver1975/lean/Aether
PYTHONPATH=. python3 research_loop.py --single-cycle
```

### Dry Run (no actual dispatch)

```bash
cd /home/raver1975/lean/Aether
PYTHONPATH=. python3 research_loop.py --dry-run
```

### Autoresearch verification (independent of Aristotle)

```bash
cd /home/raver1975/lean
bash autoresearch.sh          # Count theorems, check metrics
bash autoresearch.checks.sh   # Verify all 55 files compile with 0 sorries
```

## Pipeline Architecture

```
Aether (orchestrator)
  → Pi (brains: decides WHAT to research, HOW to present it)
    → "Prove this theorem about X. Create python demos.
       Write a research paper with a Scientific American discussion.
       Show useful applications."
  → Aristotle (worker: proves theorems, creates all artifacts)
  → Pi (integrator: evaluates quality, places in Catalog)
  → Aether (commits, tracks metrics, loops)
```

Key principle: Aristotle has creative freedom. We tell it WHAT outcomes
we need (verified math, demos, papers, applications) but not HOW to
organize or name them. Pi evaluates and integrates the results.

## Manual Workflow (step by step)

### Phase 1: Generate Proposals

```bash
cd /home/raver1975/lean/Aether
PYTHONPATH=. python3 engine.py --mode generate --arc "speculative_scifi" --count 5
```

### Phase 2: Review Proposals

```bash
PYTHONPATH=. python3 manual_dispatch.py --list
```

### Phase 3: Dispatch to Aristotle

```bash
PYTHONPATH=. python3 manual_dispatch.py --index 0    # single prompt
PYTHONPATH=. python3 manual_dispatch.py --all        # all job packages
```

### Phase 4: Integrate into Catalog

```bash
cp manual_jobs/job_abc123/result.lean ../Catalog/Speculative/SciFi/AutoGen/my_theorem.lean
cd ../Catalog && lake build
```

## Verified Theorem Inventory (55 files, ~466 theorems, 0 sorries)

### Analysis & Calculus
| File | Thms | Key Results |
|------|------|-------------|
| DifferentialCalculusBridge | 7 | Mean Value Theorem, Rolle's, monotonicity from derivatives, f''≥0→convex |
| TranscendentalDerivativeBridge | 9 | exp'=exp (FIXED POINT of d/dx), chain rules for exp/log |
| ExponentialBoundBridge | 11 | exp/log bounds, strict convexity |
| JensenInequalityBridge | 3 | Jensen's inequality (MASTER inequality), exp convex |
| SubadditiveSequenceBridge | 6 | Fekete's Lemma, subadditive convergence |
| ContinuousFunctionBridge | 12 | Continuous functions form a ring (add/mul/comp/abs/max/min) |

### Topology & Metric Spaces
| File | Thms | Key Results |
|------|------|-------------|
| MetricSpaceBridge | 6 | Metric axioms, **Baire Category Theorem** |
| TopologyBridge | 7 | Open/closed duality, compact+Hausdorff, closure |
| TopologicalRobustnessBridge | 8 | Compact→bounded, sup/inf attained |
| HeineCantorBridge | 6 | Compact→uniform continuous |
| TopologicalConnectednessBridge | 7 | Connectedness, generalized IVT |
| IntermediateValueBridge | 6 | IVT→adversarial examples exist |

### Algebra & Number Theory
| File | Thms | Key Results |
|------|------|-------------|
| RingTheoryBridge | 3+1inst | Maximal⟹Prime, R/I field⟺Maximal, R/I domain⟺Prime |
| ElementaryNumberTheoryBridge | 7 | GCD comm/assoc/mul, coprime powers, divisibility |
| NumberTheoryBridge | 15 | FLT, Wilson, CRT, totient, prime properties |
| FiniteFieldBridge | 9 | Frobenius homomorphism, Freshman's Dream |
| GroupTheoryBridge | 4 | Lagrange's theorem, element orders, ZMod cardinality |
| PolynomialBridge | 6 | deg(pq)=deg p+deg q, degree of powers/constants |
| CombinatorialBridge | 6 | Pigeonhole principle, union bounds |
| PigeonholeInjectionBridge | 6 | Type-level pigeonhole, injection/surjection bounds |

### Linear Algebra & Functional Analysis
| File | Thms | Key Results |
|------|------|-------------|
| InnerProductBridge | 9 | Cauchy-Schwarz, parallelogram law, polarization identity |
| BesselInequalityBridge | 5 | Bessel inequality, Gram determinant non-negativity |
| HilbertSpaceBridge | 8 | Sesquilinearity, norm from inner product, orthonormal families |
| DeterminantBridge | 5 | det(AB)=det(A)det(B), det transpose/negation/scalar |

### Order Theory & Foundations
| File | Thms | Key Results |
|------|------|-------------|
| GaloisConnectionBridge | 10 | Galois connections, closure operators, lattice bounds |
| KnasterTarskiBridge | 11 | Order-theoretic fixed points (LFP = sInf of pre-fixed) |
| WellFoundedInductionBridge | 3+1def | Well-founded induction, Zorn's Lemma (≡AC) |

### Machine Learning & Robustness
| File | Thms | Key Results |
|------|------|-------------|
| BanachFixedPointBridge | 10 | Contraction mapping, GD convergence |
| NeuralCompositionBridge | 7 | Lipschitz composition laws |
| ResNetLipschitz.lean | 7 | ResNet polynomial vs exponential growth |
| GronwallDiscreteBridge | 8 | Discrete Gronwall, geometric decay |
| ResNetRobustnessBridge | 8 | Certified robustness bounds |
| MultiClassCertificationBridge | 9 | Multiclass certification |
| HammingDistanceBridge | 7 | Coding theory↔metric spaces |
| NormInequalityBridge | 12 | Norm inequalities |

### Tropical Geometry
| File | Thms | Key Results |
|------|------|-------------|
| TropicalSatakeGL3 | 15 | S₃ invariance, tropical Chevalley, dominant Weyl chamber (Aristotle) |
| SatakeIsomorphism | 22 | Satake isomorphism for GL₂ |
| ConvexTropicalBridge | 9 | Tropical convexity, LSE≥max |
| LSEConvexity.lean | 12 | Log-sum-exp convexity |
| EMLTropicalBridge | 7 | EML↔tropical bridge |
| NDimLogSumExp.lean | 9 | N-dimensional LSE properties |

### EML & Stone-Weierstrass
| File | Thms | Key Results |
|------|------|-------------|
| EMLStoneWeierstrassBridge | 17 | Stone-Weierstrass approximation |
| SatakeEMLBridge | 8 | Satake↔EML bridge |
| AlgebraEMLBridge | 6 | Algebra↔EML bridge |

## Key Theorem Chains

1. **Analysis**: DifferentialCalculus → TranscendentalDerivative → ExponentialBound → Jensen → Fekete
2. **Topology→Calculus**: Baire → Topology → Robustness → HeineCantor → Connectedness → ContinuousFunction → DifferentialCalculus
3. **Algebra**: RingTheory → ElementaryNT → NumberTheory → FiniteField → GroupTheory (Lagrange)
4. **Linear Algebra**: InnerProduct(Cauchy-Schwarz) → Bessel → HilbertSpace → Determinant
5. **Order Theory**: WellFoundedInduction → KnasterTarski → GaloisConnection
6. **Robustness**: TopologicalRobustness → NeuralComposition → ResNetLipschitz → GronwallDiscrete
7. **Algebra→Geometry**: RingTheory → Polynomial → Determinant → HilbertSpace

## Configuration

Key settings in `Aether/config.yaml`:

```yaml
pi_agent:
  model: "kimi-k2.6:cloud"          # Ollama model
  ollama_base_url: "http://127.0.0.1:11434"
  temperature: 0.85
  num_predict: 4096

aristotle:
  api_base_url: "https://aristotle.harmonic.fun/api/v1"
  api_key: "${ARISTOTLE_API_KEY}"
  concurrent_jobs: 10

autoresearch:
  enabled: true
  metric_name: "concept_quality"
  direction: "higher"
```

## Research Arcs

| Arc | Command | Status |
|-----|---------|--------|
| Tropical Langlands | `--arc "tropical_langlands"` | Aristotle GL₃ Satake completed |
| Gravitational Factoring | `--arc "gravitational_factoring"` | Berggren tree structure |
| Quantum Pythagoras | `--arc "quantum_pythagoras"` | QDF factoring |
| Neural Proof Mining | `--arc "neural_proof_mining"` | RSIL distillation |
| EML Cosmology | `--arc "eml_cosmology"` | Stone-Weierstrass bridge |
| Speculative Sci-Fi | `--arc "speculative_scifi"` | 5 sorry-depth theorems pending |

## Metrics & Benchmarks

```bash
bash autoresearch.sh           # Primary metrics
bash autoresearch.checks.sh    # All 55 file verification checks
```

Current output:
```
concept_quality=1   verified_decls≈466   verified_files=55   sorry_files=0
```

## Troubleshooting

**"Module not found: aether"**
```bash
export PYTHONPATH=/home/raver1975/lean/Aether:$PYTHONPATH
```

**"Ollama not responding"**
```bash
ollama serve    # Start the Ollama daemon
ollama pull kimi-k2.6:cloud    # Pull model if needed
```

**"Aristotle API 404"**
The API requires `ARISTOTLE_API_KEY` environment variable. Use `manual_dispatch.py` for copy-paste workflow as fallback.

**"lake build fails"**
```bash
cd /home/raver1975/lean/Catalog && lake build
```