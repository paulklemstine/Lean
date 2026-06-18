# Idempotent Collapse: The Universal Theory

## f ∘ f = f — Nine Directions of Mathematical Simplification

This project explores **idempotent collapse** — the equation f(f(x)) = f(x) — across nine distinct mathematical domains. All theorems are formally verified in Lean 4 with Mathlib. **Zero sorries remain.**

## The Nine Directions

| # | Direction | File | Key Result |
|---|-----------|------|------------|
| 1 | **Quantum Measurement** | `QuantumCollapse.lean` | Born rule from projection geometry |
| 2 | **Optimal Transport** | `OptimalCollapse.lean` | Transport cost bounds |
| 3 | **Computational** | `ComputationalCollapse.lean` | sort²=sort, compiler convergence |
| 4 | **Topological** | `TopologicalCollapse.lean` | Retraction-Idempotent correspondence |
| 5 | **Closure Operators** | `ClosureCollapse.lean` | Galois connections → closures |
| 6 | **Fixed Points** | `FixedPointCollapse.lean` | Banach contraction, Kleene |
| 7 | **Information Theory** | `InformationCollapse.lean` | Data processing inequality |
| 8 | **Category Theory** | `CategoryCollapse.lean` | Karoubi envelope, e^n = e |
| 9 | **Neural Collapse** | `NeuralCollapse.lean` | Feature convergence, ETF |
| Core | **Universal Theory** | `Core.lean` | Universal Collapse Theorem |

## Statistics

- **79 theorems** across 10 Lean files
- **0 sorries** — all proofs complete
- **0 non-standard axioms** — only propext, Classical.choice, Quot.sound
- **~600 lines** of formalized mathematics

## Directory Structure

```
IdempotentCollapse/
├── Core.lean                    # Universal Collapse Theorem + core results
├── QuantumCollapse.lean         # Direction 1: Quantum measurement
├── OptimalCollapse.lean         # Direction 2: Optimal transport
├── ComputationalCollapse.lean   # Direction 3: Sorting, memoization
├── TopologicalCollapse.lean     # Direction 4: Retractions
├── ClosureCollapse.lean         # Direction 5: Closure operators
├── FixedPointCollapse.lean      # Direction 6: Fixed-point iteration
├── InformationCollapse.lean     # Direction 7: Compression, quantization
├── CategoryCollapse.lean        # Direction 8: Karoubi envelope
├── NeuralCollapse.lean          # Direction 9: Deep learning
├── demos/
│   ├── idempotent_collapse_demo.py    # Original 6 demos
│   └── nine_directions_demo.py        # All 9 direction demos
├── visuals/
│   ├── nine_directions.svg            # Radial map of all 9 directions
│   ├── quantum_collapse.svg           # Quantum measurement diagram
│   ├── universal_theorem.svg          # Universal Collapse Theorem
│   ├── collapse_spectrum.svg          # Collapse spectrum
│   ├── four_pillars.svg               # Original 4 pillars
│   └── idempotent_collapse.svg        # Overview
├── research/
│   ├── RESEARCH_PAPER.md              # Full research paper
│   ├── SCIENTIFIC_AMERICAN.md         # Popular science article
│   └── RESEARCH_NOTES.md              # Research log and notes
└── README.md                          # This file
```

## Key Theorems

### Universal Collapse Theorem
```
∀ S : Set α, S.Nonempty → ∃ f : α → α, Idempotent f ∧ range f = S
```

### Born Rule (Probability Conservation)
```
∀ x : V, ∑ i, ‖(M.proj i).toFun x‖² = ‖x‖²
```

### Banach Contraction (Total Collapse)
```
∃ k, 0 ≤ k ∧ k < 1 ∧ (∀ x y, dist (f x) (f y) ≤ k * dist x y) → ∃! p, f p = p
```

### Galois Closure Idempotent
```
GaloisConnection f g → ∀ x, g (f (g (f x))) = g (f x)
```

## Running

```bash
# Build all Lean files
lake build IdempotentCollapse

# Run Python demos
cd demos && python3 nine_directions_demo.py
```
