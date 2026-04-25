# AETHER: Automated Epic Theorem Hypothesis Engine & Research

**Version:** 0.1.0-alpha  
**Codename:** Project Prometheus  
**Objective:** Autonomously generate, prove, and integrate novel master-level mathematics into the Catalog using Aristotle formal verification.

---

## Philosophy

AETHER treats the Catalog not as a static archive but as a **living mathematical organism**. It operates on three principles:

1. **Combinatorial Creativity**: Novel theorems emerge at the intersection of distant domains. The engine systematically discovers these bridges.
2. **Formal Immortality**: Every generated hypothesis must survive Aristotle's verification crucible before earning a place in the Catalog.
3. **Epic Narrative**: Research is not random. It follows thematic arcs — gravitational factoring, tropical geometry, quantum computation — producing coherent bodies of work, not isolated trivia.

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              AETHER ENGINE                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  CONCEPT     │  │ HYPOTHESIS   │  │ ARISTOTLE    │  │ INTEGRATION  │      │
│  │  MINER       │─▶│ GENERATOR    │─▶│ DISPATCHER   │─▶│ GATE         │      │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                  │                  │                 │              │
│         ▼                  ▼                  ▼                 ▼              │
│  ┌────────────────────────────────────────────────────────────────────┐     │
│  │                     TELEMETRY & META-LEARNING                       │     │
│  │  • Experiment registry  • Benchmark leaderboard  • Success models     │     │
│  └────────────────────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Component Specification

### 1. ConceptMiner (`miner.py`)

**Function:** Introspect the Catalog database to discover patterns, gaps, and fertile ground.

**Operations:**
- **Cross-Domain Bridge Detection**: Identify concept pairs appearing in multiple domains but lacking formal bridges
- **Hotspot Analysis**: Find declarations with high fan-in (many dependents) and high fan-out (many dependencies)
- **Sorry Mining**: Rank open problems by strategic impact (downstream theorem count × domain centrality)
- **Axiom Dependency Graph**: Map which axioms are load-bearing; flag opportunities for reduction
- **Theme Extraction**: Cluster declarations by semantic similarity to identify ongoing research narratives

**Output:** `ResearchLandscape` — a JSON object describing the current frontier.

### 2. HypothesisGenerator (`generator.py`)

**Function:** Synthesize novel conjectures, algorithms, and experiments.

**Modes:**
- **Bridge Mode**: Given two domains and a shared concept, generate bridging theorems
- **Generalization Mode**: Take a concrete theorem and propose its abstract categorical / tropical / quantum analogue
- **Sci-Fi Mode**: Project existing mathematics into speculative frameworks (e.g., "What if gravitational factoring worked in tropical geometry?")
- **Algorithm Mode**: Design novel algorithms with formal specifications and complexity bounds
- **Experiment Mode**: Propose computational experiments, benchmark suites, and statistical hypotheses

**Prompt Architecture:**
Each hypothesis is packaged with:
- **Context Block**: Relevant existing theorems, definitions, and imports from the Catalog
- **Conjecture Statement**: Formal Lean 4 type signature (with `sorry` for the proof)
- **Narrative**: A short paper-style motivation connecting the conjecture to the broader research arc
- **Difficulty Estimate**: Master / PhD / Graduate / Undergraduate
- **Risk Assessment**: Probability of being true, interesting, or trivial

**Output:** `ResearchProposal` — a structured document ready for Aristotle dispatch.

### 3. AristotleDispatcher (`aristotle_client.py`)

**Function:** Submit proposals to Harmonic's Aristotle agent and manage the proof lifecycle.

**Workflow:**
1. **Package**: Bundle the Lean 4 file (imports + context + conjecture) into a project-compatible format
2. **Submit**: POST to Aristotle API with the research brief
3. **Poll**: Check job status until completion, timeout, or failure
4. **Receive**: Extract the patched Lean source, proof statistics, and verification report
5. **Validate**: Run `lake build` on the result locally before acceptance

**Structured Prompt Template:**
```
RESEARCH BRIEF: {title}
DOMAIN: {domain}
DIFFICULTY: {difficulty}

CONTEXT:
{relevant_theorems}

CONJECTURE TO PROVE:
```lean
{lean_code}
```

REQUIREMENTS:
- Provide a complete formal proof in Lean 4
- Use only mathlib4 (v4.28.0) and the provided context
- Do not change the theorem statement (only fill the sorry)
- If the theorem is false, explain why and suggest a corrected statement
- Include proof strategy comments
```

### 4. IntegrationGate (`integrator.py`)

**Function:** Safely merge Aristotle's output into the Catalog.

**Checks:**
- Syntax validation (`lake build` passes)
- Semantic validation (no new sorries introduced unless explicitly allowed)
- Deduplication check (doesn't duplicate existing declarations)
- Import graph integrity (no circular dependencies created)
- Thematic placement (file and domain assignment)

**Actions:**
- **Accept**: Write to `Catalog/{domain}/{file}.lean`, run `rescan`
- **Reject**: Log failure, update success model weights
- **Retry**: If near-success (few sorries), resubmit with hints

### 5. Telemetry & Meta-Learning (`telemetry.py`)

**Metrics:**
- **Throughput**: Proposals submitted / hour, proofs completed / day
- **Success Rate**: By domain, difficulty, concept combination type
- **Time-to-Proof**: Latency distribution from submission to verification
- **Novelty Score**: How many new declarations reference the new theorem
- **Epicness Index**: Subjective quality score (human + LLM-judged)

**Outputs:**
- `logs/experiments.jsonl` — append-only experiment log
- `logs/benchmarks.json` — rolling leaderboard
- `logs/telemetry_report.html` — dashboard-ready summary

---

## Research Arcs (Active Themes)

AETHER maintains a set of **research arcs** — long-running thematic programs that guide hypothesis generation:

| Arc | Description | Current Frontier |
|-----|-------------|------------------|
| **Gravitational Factoring** | Using geometric/spacetime structures for integer factorization | Tropical analogues of gravitational lenses |
| **Quantum Pythagoras** | Formalizing quantum computing on Berggren tree structures | QDF (Quantum Diophantine Factoring) |
| **Tropical Langlands** | Tropical geometry meets representation theory | Tropical automorphic forms |
| **Neural Proof Mining** | ML-guided theorem discovery | RSIL adaptive distillation |
| **Temporal Computation** | Time-travel logic and reversible computation | OISCC oracle hierarchies |
| **EML Cosmology** | Emergent meta-language as universe model | Self-pairing in curved spacetime |
| **Cryptographic Gravity** | Post-quantum crypto via geometric invariants | Lattice reduction in Berggren trees |

---

## Experiment Registry

Each experiment receives a UUID and tracks:
- Generation timestamp
- Research arc affiliation
- Concept combination provenance
- Aristotle job ID
- Final status (proven / counterexample-found / timeout / rejected)
- Integration commit hash (if accepted)
- Performance telemetry

---

## Configuration

See `config.yaml` for:
- Aristotle API endpoint and credentials
- Catalog database path
- Research arc definitions
- Difficulty thresholds
- Retry policies
- Telemetry destinations

---

## Usage

```bash
# Run a single research cycle (mine → generate → dispatch → integrate)
python3 -m aether.engine --mode single --arc "Quantum Pythagoras"

# Run continuous autonomous research
python3 -m aether.engine --mode daemon --arcs all

# Generate proposals without dispatching (dry run)
python3 -m aether.engine --mode generate --count 10

# Dispatch pending proposals to Aristotle
python3 -m aether.engine --mode dispatch

# Integrate completed Aristotle jobs
python3 -m aether.engine --mode integrate

# View telemetry dashboard
python3 -m aether.telemetry --report html
```

---

## Integration with Existing Pipeline

AETHER does not replace the catalog pipeline — it **feeds** it:

1. AETHER writes new `.lean` files into `Catalog/`
2. The user (or CI) runs `tools/rescan` to rebuild the database
3. `lake build` verifies correctness
4. The new theorems enter the next cycle of ConceptMiner analysis

This creates a **closed loop** of autonomous mathematical discovery.

---

*Generated by AETHER v0.1.0-alpha — Theorem Forge Initialized.*
