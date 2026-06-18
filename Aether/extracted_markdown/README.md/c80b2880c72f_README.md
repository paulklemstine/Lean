# 🌴🔬 Quantum Tropical Neural Computing

## A Unified Framework for Learning, Inference, and Simulation in the Max-Plus Semiring

This package provides a complete research ecosystem for **Quantum Tropical Neural Computing (QTNC)** — the mathematical theory that unifies quantum gate computation, neural networks, and probabilistic inference through the tropical (max-plus) semiring **T** = (ℝ ∪ {−∞}, max, +).

### The Core Insight

Three pillars of modern computation — quantum circuits, deep learning, and Bayesian inference — all converge to the same algebraic structure when viewed through the Maslov dequantization:

$$\lim_{\beta \to \infty} \frac{1}{\beta} \log(e^{\beta a} + e^{\beta b}) = \max(a, b)$$

- **ReLU activation** = tropical addition with zero: max(x, 0) = x ⊕ 0
- **Viterbi decoding** = tropical matrix power
- **MAP inference** = tropical marginalization
- **Winner-take-all** = tropical Hadamard gate
- **Synaptic integration** = tropical CNOT gate

---

## 📂 Contents

### 📄 Papers
| File | Description |
|------|-------------|
| [`papers/research_paper.md`](papers/research_paper.md) | Full technical research paper |
| [`papers/scientific_american.md`](papers/scientific_american.md) | Popular science article |

### 🐍 Python Library (`qtlib`)
| Module | Description |
|--------|-------------|
| [`qtlib/semiring.py`](qtlib/semiring.py) | Tropical semiring arithmetic, Maslov deformation, LogSumExp |
| [`qtlib/gates.py`](qtlib/gates.py) | 6 tropical quantum gates with Maslov deformation |
| [`qtlib/circuits.py`](qtlib/circuits.py) | Circuit simulator with annealing and measurement |
| [`qtlib/tensor.py`](qtlib/tensor.py) | Tropical tensors, entanglement, Schmidt decomposition |
| [`qtlib/networks.py`](qtlib/networks.py) | Tropical neural network layers and architectures |
| [`qtlib/learning.py`](qtlib/learning.py) | Morphological backpropagation and tropical SGD |
| [`qtlib/inference.py`](qtlib/inference.py) | Viterbi, Bayesian networks, belief propagation |

### 🎮 Simulator
| File | Description |
|------|-------------|
| [`simulator/run_simulator.py`](simulator/run_simulator.py) | Interactive quantum tropical circuit simulator |

### 📊 Demos (with visualizations)
| Script | Generated Images | Description |
|--------|-----------------|-------------|
| [`demos/demo_01_tropical_gates_extended.py`](demos/demo_01_tropical_gates_extended.py) | `tropical_gate_zoo.png`, `maslov_gate_spectrum.png`, `gate_composition_algebra.png` | Gate operations and composition algebra |
| [`demos/demo_02_tropical_learning.py`](demos/demo_02_tropical_learning.py) | `tropical_learning_curves.png`, `tropical_decision_boundary.png`, `tropical_vs_classical.png` | Tropical neural network learning |
| [`demos/demo_03_quantum_tropical_simulator.py`](demos/demo_03_quantum_tropical_simulator.py) | `circuit_beta_sweep.png`, `circuit_entanglement.png`, `circuit_annealing.png`, `viterbi_tropical.png` | Circuit simulation and inference |
| [`demos/demo_04_universal_inference.py`](demos/demo_04_universal_inference.py) | `tropical_bayes_inference.png`, `tropical_belief_propagation.png`, `tropical_universal_computation.png` | Universal inference engines |

### 📐 Lean 4 Formalization
| File | Description |
|------|-------------|
| [`core/Tropical/QuantumTropicalComputing.lean`](../core/Tropical/QuantumTropicalComputing.lean) | **30+ machine-verified theorems, 0 sorries** |

### 📝 Research Notes
| File | Description |
|------|-------------|
| [`research_notes/00_team_formation.md`](research_notes/00_team_formation.md) | Team formation, Oracle consultations, hypotheses, iteration log |

---

## 🚀 Quick Start

```bash
# Install dependencies
pip install numpy matplotlib

# Run all demos (generates all visualization PNGs)
cd QuantumTropicalComputing/demos
python3 demo_01_tropical_gates_extended.py
python3 demo_02_tropical_learning.py
python3 demo_03_quantum_tropical_simulator.py
python3 demo_04_universal_inference.py

# Run the interactive simulator
cd ../simulator
python3 run_simulator.py

# Verify Lean proofs
cd ../..
lake build core.Tropical.QuantumTropicalComputing
```

---

## 🔑 Key Results

### Machine-Verified Theorems (Lean 4, zero sorries)

| Theorem | Statement |
|---------|-----------|
| Maslov Sandwich | max(a,b) ≤ LSE_β(a,b) ≤ max(a,b) + log(2)/β |
| Hadamard Idempotency | H_T² = H_T |
| CNOT Power Law | CNOT_T^n(a,b) = (a, n·a+b) |
| Phase Group | P(φ)∘P(ψ) = P(φ+ψ) |
| SWAP Involutivity | SWAP² = I |
| WTA Idempotency | WTA(WTA(v)) = WTA(v) |
| Consciousness Positivity | C(β) > 0 for β > 0 |

### Computational Validation

- ✅ Tropical neural networks learn on XOR, circles, and linear tasks
- ✅ Tropical gates exhibit expected algebraic properties
- ✅ Maslov annealing converges to optimal solutions
- ✅ Tropical entanglement detection works correctly
- ✅ Viterbi decoding produces correct MAP sequences
- ✅ Belief propagation converges on factor graphs

---

## 📐 The Tropical Computing Trinity

```
         Tropical Circuits
        /                 \
    ReLU = max         Viterbi = tropical
   (tropical add)      matrix power
      /                     \
 Neural Networks ——— Inference Engines
           Backprop = tropical
              path tracing
```

**All three are computation in the tropical semiring T = (ℝ, max, +).**
