This project was edited by [Aristotle](https://aristotle.harmonic.fun).

To cite Aristotle:
- Tag @Aristotle-Harmonic on GitHub PRs/issues
- Add as co-author to commits:
```
Co-authored-by: Aristotle (Harmonic) <aristotle-harmonic@harmonic.fun>
```

# The Pythagorean Cosmos

## A Unified Formal Mathematics Library in Lean 4

**3,158 machine-verified theorems** across **199 Lean files** (~33,700 lines), all built on Lean 4.28.0 with Mathlib. **Zero `sorry` remaining.**

---

## Quick Start

```bash
# Build the default targets (62 modules)
lake build

# Build all modules including research files
lake build SauerShelah Combinatorics Basic Berggren ...
```

## Project Overview

This project explores the deep interconnections radiating from the Pythagorean equation a² + b² = c², connecting:

- **Number Theory** → Four-channel integer signatures, Eisenstein norms, multiplicativity
- **Quantum Computing** → Gate synthesis via the theta subgroup of SL(2,ℤ)
- **Information Theory** → Compression impossibility, entropy bounds
- **Mathematical Physics** → Lorentz geometry, light cone structure
- **Algebraic Geometry** → Congruent numbers, elliptic curves, BSD connection

## Directory Structure

### Core Mathematics
| File | Description | Theorems |
|------|-------------|----------|
| `Basic.lean` | Pythagorean triple foundations, Euclid parametrization | 10 |
| `Berggren.lean` | Berggren tree matrices, Lorentz form preservation | 15 |
| `BerggrenTree.lean` | Tree traversal, triple generation | 8 |
| `FLT4.lean` | Fermat's Last Theorem for n=4 | 3 |
| `CongruentNumber.lean` | Congruent numbers, elliptic curve connection | 5 |
| `SauerShelah.lean` | **Sauer-Shelah lemma** (full inductive proof) | ~30 |

### Four-Channel Signature Theory
| File | Description | Theorems |
|------|-------------|----------|
| `ChannelEntropy.lean` | Channel formulas, dominance hierarchy | 13 |
| `PrimeSignatures.lean` | Constant Gap Theorem, Eisenstein connection | 4 |
| `Multiplicativity.lean` | σ₁*, σ₃± multiplicative structure | 6 |
| `Session2Theorems.lean` | Powers of 2, divisibility, geometric series | 19 |
| `Defs.lean` | Core definitions for four-channel signatures | — |

### Quantum Computing
| File | Description | Theorems |
|------|-------------|----------|
| `QuantumBerggren.lean` | Berggren gate group, simplification rules | 47 |
| `QuantumGateSynthesis.lean` | Theta group gates, factoring connection | 20 |
| `QuantumCircuits.lean` | Circuit evaluation, determinant preservation | 32 |
| `QuantumGateAlgebra.lean` | Deep algebraic structure of gates | 47 |

### Compression & Information Theory
| File | Description | Theorems |
|------|-------------|----------|
| `Compression.lean` | Pigeonhole compression impossibility | 10 |
| `CompressionTheory.lean` | Source coding, data processing inequality | 24 |
| `Entropy.lean` | Shannon entropy, KL divergence | 7 |

### Stereographic Projection & Möbius Theory
| File | Description | Theorems |
|------|-------------|----------|
| `InverseStereoMobius.lean` | Möbius transformations, stereographic maps | 41 |
| `OrderClassification.lean` | **Complete order classification** (orders 3,6 impossible) | 10 |
| `IntegerChains.lean` | Complete integer chain enumeration | 17 |

### Research Frontiers
| File | Description | Theorems |
|------|-------------|----------|
| `FrontierResearch.lean` | Lorentz structure, photon statistics, modular dictionary | 32 |
| `DeepResults.lean` | Cross-domain connections, Euler characteristics | 55 |
| `MoonshotResearch.lean` | Congruent numbers, Navier-Stokes connections | 84 |

## Key Discoveries

1. **Constant Gap Theorem**: |r₂(p) − r₂(q)| = 8 for bright vs dark primes, independent of magnitude
2. **Eisenstein Norm Connection**: r₈(p)/r₄(p) = 2(p² − p + 1), revealing Eisenstein integers
3. **Powers of 2 Channel Specificity**: r₂(2ᵏ) = 4, r₄(2ᵏ) = 24 for all k (exponent invisible to channels 2,3)
4. **Orders 3 and 6 Impossible**: No integer-pole Möbius map has order 3 or 6
5. **Berggren-Modular Dictionary**: M₁ = T²S, M₃ = T² connecting Pythagorean tree to quantum gates
6. **Sauer-Shelah Lemma**: Full inductive proof with coordinate splitting

## Documents

- **`RESEARCH_PAPER.md`** — Full research paper describing the unified framework
- **`THEOREM_CATALOG.md`** — Extensive catalog of all 3,158 theorems organized by topic
- **`SCIENTIFIC_AMERICAN_ARTICLES.md`** — Three popular science articles:
  1. *The Dark Matter of Numbers* — Channel theory and invisible integers
  2. *The Pythagorean Tree That Generates Quantum Circuits* — Berggren-modular connection
  3. *When Computers Verify Mathematics* — Inside the formal verification project
- **`Notes.md`** — Session 1 research notes
- **`Notes_Session2.md`** — Session 2 research notes
- **`FrontierResearchPaper.md`** — Extended research paper on frontier topics
- **`CLEANUP_NOTES.md`** — Project organization and cleanup documentation

## Build Requirements

- Lean 4.28.0 (`leanprover/lean4:v4.28.0`)
- Mathlib v4.28.0

## Statistics

| Metric | Value |
|--------|-------|
| Total Lean files | 199 |
| Lines of Lean code | ~33,700 |
| Theorems/lemmas | 3,158 |
| Sorry count | **0** |
| Mathematical domains | 17+ |
| Default build targets | 63 |
| Duplicate theorem names | 118 (cross-domain proofs) |
