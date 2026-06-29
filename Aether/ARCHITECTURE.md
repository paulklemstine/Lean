# AETHER: Automated Epic Theorem Hypothesis Engine & Research

**Version:** 0.3.0  
**Codename:** Project Prometheus  
**Objective:** Autonomously generate, prove, and integrate novel master-level mathematics into the Catalog using Aristotle formal verification.

---

## Current State

- **55 verified Lean 4 files** with **~466 theorems** and **0 sorries**
- **8 major theorem chains** from foundations (Zorn's Lemma) to applications (GD convergence)
- Pi-Agent (Ollama `kimi-k2.6:cloud`) for concept generation
- Aristotle API integration for formal proof
- Full autoresearch pipeline: `autoresearch.sh` + `autoresearch.checks.sh`

---

## Philosophy

AETHER treats the Catalog not as a static archive but as a **living mathematical organism**. It operates on three principles:

1. **Combinatorial Creativity**: Novel theorems emerge at the intersection of distant domains. The engine systematically discovers these bridges.
2. **Formal Immortality**: Every generated hypothesis must survive Aristotle's verification crucible before earning a place in the Catalog.
3. **Epic Narrative**: Research is not random. It follows thematic arcs — producing coherent bodies of work, not isolated trivia.

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              AETHER ENGINE v1.0                              │
│                                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  CONCEPT     │  │ HYPOTHESIS   │  │ ARISTOTLE    │  │ INTEGRATION  │      │
│  │  MINER       │─▶│ GENERATOR    │─▶│ DISPATCHER   │─▶│ GATE         │      │
│  │  (miner.py)  │  │ (generator)  │  │ (aristotle)  │  │ (integrator) │      │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                  │                  │                 │              │
│         ▼                  ▼                  ▼                 ▼              │
│  ┌────────────────────────────────────────────────────────────────────┐     │
│  │              AUTORESEARCH & KNOWLEDGE EXTRACTION                    │     │
│  │  • research_loop.py  • knowledge_extractor.py  • autoresearch.sh   │     │
│  │  • 55 verified files  • ~466 theorems  • 0 sorries  • 8 chains     │     │
│  └────────────────────────────────────────────────────────────────────┘     │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────┐     │
│  │                     TELEMETRY & META-LEARNING                       │     │
│  │  • autoresearch.jsonl  • concept_quality metric  • success models   │     │
│  └────────────────────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Data Flow

```
Aether (orchestrator)
  → Pi (brains: decides WHAT to research)
    → "Prove this theorem about X. Create python demos.
       Write a research paper. Show useful applications."
  → Aristotle (worker: proves theorems, creates all artifacts)
  → Pi (integrator: evaluates quality, places in Catalog)
  → Aether (commits, tracks metrics, loops)
```

Key principle: **Aristotle has creative freedom**. Tell it outcomes
(verified math, demos, papers, applications) not HOW to organize files.

---

## Component Specification

### 1. ConceptMiner (`miner.py`)

Discovers patterns, gaps, and fertile ground in the Catalog:
- Cross-Domain Bridge Detection
- Hotspot Analysis (high fan-in/fan-out declarations)
- Sorry Mining (rank open problems by strategic impact)
- Axiom Dependency Graph
- Theme Extraction

**Output:** `ResearchLandscape` — JSON describing the current frontier.

### 2. HypothesisGenerator (`generator.py`)

Synthesizes novel conjectures, algorithms, and experiments in modes:
- **Bridge Mode**: Given two domains, generate bridging theorems
- **Generalization Mode**: Concrete → abstract categorical/tropical analogue
- **Sci-Fi Mode**: Project mathematics into speculative frameworks
- **Algorithm Mode**: Design algorithms with formal specifications
- **Experiment Mode**: Propose computational experiments

### 3. PiAgentClient (`pi_agent_client.py`)

LLM-powered research partner using Ollama:
- Generates breakthrough concepts from catalog context
- Evaluates Aristotle results for quality
- Decides theorem placement in Catalog
- Config: `kimi-k2.6:cloud` model via Ollama at `localhost:11434`

### 4. AristotleDispatcher (`aristotle_sdk_client.py`)

Submits proposals to Harmonic's Aristotle agent:
- Package → Submit → Poll → Receive → Validate
- Manages job lifecycle with retry and backoff
- Async polling with configurable intervals

### 5. KnowledgeExtractor (`knowledge_extractor.py`)

7-phase pipeline: DISCOVER → DISPATCH → AWAIT → EXTRACT → EVALUATE → INTEGRATE → COMMIT
- Orchestrates the full research loop
- Manages catalog state, verified files, metrics

### 6. IntegrationGate (`integrator.py`, `smart_integrator.py`)

Safely merges Aristotle output into Catalog:
- Syntax validation (`lake build` passes)
- Semantic validation (no new sorries)
- Deduplication, import graph integrity
- Thematic placement

### 7. Autoresearch Bridge (`autoresearch_bridge.py`)

Connects the Aristotle pipeline to the `autoresearch.sh` benchmark framework:
- Tracks `concept_quality` metric (0-1, higher better)
- Logs experiments to `autoresearch.jsonl` with ASI
- Verification via `autoresearch.checks.sh` (55 file checks)

---

## Theorem Chains (8 major chains)

```
ANALYSIS:        DifferentialCalculus → TranscendentalDeriv → ExpBound → Jensen → Fekete
TOPOLOGY→CALC:   Baire → Topology → Robustness → HeineCantor → Connected → Continuous → MVT
ALGEBRA:         RingTheory → ElementaryNT → NumberTheory → FiniteField → GroupTheory
LINEAR ALGEBRA:  InnerProduct → Bessel → HilbertSpace → Determinant
ORDER THEORY:    WellFounded → KnasterTarski → GaloisConnection
ROBUSTNESS:      TopoRobust → NeuralComp → ResNet → Gronwall
ALG→GEOMETRY:    RingTheory → Polynomial → Determinant → HilbertSpace
TROPICAL:        Tropical → Satake → EML → ConvexTropical
```

---

## Research Arcs

| Arc | Status | Key Results |
|-----|--------|-------------|
| Tropical Langlands | ✅ Completed | GL₃ Satake (15 theorems, Aristotle) |
| Gravitational Factoring | Active | Berggren tree structure |
| Quantum Pythagoras | Active | QDF factoring |
| Neural Proof Mining | Active | RSIL adaptive distillation |
| EML Cosmology | Active | Stone-Weierstrass bridge |
| Speculative Sci-Fi | Pending | 5 sorry-depth theorems ready for Aristotle |

---

## Verified Catalog (55 files, ~466 theorems, 0 sorries)

### By Domain

| Domain | Files | Theorems | Highlights |
|--------|-------|----------|-----------|
| Analysis & Calculus | 6 | 48 | MVT, exp'=exp, Jensen, Fekete |
| Topology & Metric | 6 | 40 | Baire Category, Heine-Cantor, IVT |
| Algebra & Number Theory | 8 | 58 | Lagrange, GCD, ideal theory, FLT |
| Linear Algebra & Hilbert | 4 | 27 | Cauchy-Schwarz, det(AB)=det(A)det(B) |
| Order Theory & Foundations | 3 | 24 | Zorn's Lemma, Galois connections |
| ML & Robustness | 7 | 49 | Neural composition, Gronwall, certified radius |
| Tropical Geometry | 6 | 70 | Satake GL₃, LSE convexity |
| EML & Approximation | 3 | 31 | Stone-Weierstrass |
| Other | 12 | ~119 | ResNet, Hamming, norm inequalities |

---

## Usage

```bash
# Continuous autonomous research (production)
cd /home/raver1975/lean/Aether
PYTHONPATH=. python3 research_loop.py --continuous --max-inflight 3

# Single research cycle
PYTHONPATH=. python3 research_loop.py --single-cycle

# Dry run (concept generation only, no dispatch)
PYTHONPATH=. python3 research_loop.py --dry-run

# AetherDaemon (alternative orchestrator)
PYTHONPATH=. python3 daemon.py --config config.yaml

# Autoresearch verification and metrics
cd /home/raver1975/lean
bash autoresearch.sh
bash autoresearch.checks.sh
```

### Key Parameters

| Flag | Default | Description |
|------|---------|-------------|
| `--continuous` | off | Run continuous loop |
| `--max-inflight` | 3 | Max concurrent Aristotle jobs |
| `--max-cycles` | 50 | Total dispatch cycles |
| `--poll-interval` | 60 | Seconds between polls |
| `--domain` | auto-rotate | Force specific research domain |
| `--dry-run` | off | Show concepts without dispatching |

---

## Configuration

See `config.yaml` for:
- Aristotle API endpoint and credentials (`${ARISTOTLE_API_KEY}`)
- Pi-Agent model and Ollama endpoint
- Catalog database path
- Research arc definitions
- Difficulty thresholds, retry policies

---

## Prerequisites

| Requirement | Status | Check |
|-------------|--------|-------|
| Lean 4 + Mathlib v4.28.0 | ✅ Compiled | `cd Catalog && lake build` |
| Ollama + kimi-k2.6:cloud | ✅ Running | `curl localhost:11434/api/tags` |
| ARISTOTLE_API_KEY | ✅ Set | `echo $ARISTOTLE_API_KEY` |
| Python 3.10+ | ✅ Available | `python3 --version` |
| 55 verified files, 0 sorries | ✅ All pass | `bash autoresearch.checks.sh` |

---

*AETHER v1.0 — Autonomous Mathematical Knowledge Discovery Engine.*  
*55 verified files. 466 theorems. 0 sorries. 8 theorem chains.*