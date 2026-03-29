# 🧠 Tropical Quantum Brain

## How the Brain Uses Quantum Gates in the Tropical Max-Plus Ring

This research package explores the deep mathematical connections between:
- **Tropical (max-plus) algebra**: The semiring (ℝ ∪ {−∞}, max, +)
- **Quantum gate computation**: Unitary transformations on qubits
- **Neural computation**: Winner-take-all circuits, synaptic integration, consciousness

### The Core Insight

Quantum gates have natural "tropicalizations" obtained in the semiclassical limit ℏ → 0 (equivalently, high neural gain β → ∞). These tropical quantum gates are *exactly* the computational operations performed by biological neural circuits:

| Quantum Gate | Tropical Gate | Neural Operation |
|-------------|--------------|-----------------|
| Hadamard (superposition) | max(a,b) broadcast | Winner-take-all |
| CNOT (entanglement) | a + b accumulation | Synaptic integration |
| Phase (rotation) | a + φ shift | Synaptic weight |

**Consciousness** is hypothesized to arise at the critical point of the Maslov deformation — the exact boundary between quantum-like (soft, superposition) and tropical (hard, winner-take-all) computation.

---

## Contents

### 📄 Papers
- **[Research Paper](papers/research_paper.md)** — Full technical paper with all theorems and proofs
- **[Scientific American Article](papers/scientific_american.md)** — Popular science article for general audience

### 🔬 Hypotheses & Experiments
- **[Hypotheses & Experiments](HYPOTHESES_AND_EXPERIMENTS.md)** — 7 new hypotheses, 6 computational experiments, 6 proposed applications

### 🐍 Python Demos (with visualizations)
All demos are in `demos/`. Run with `python3 <demo_name>.py`.

| Demo | Description | Output |
|------|-------------|--------|
| `demo_tropical_gates.py` | Tropical vs quantum gate comparison | 4 figures |
| `demo_maslov_deformation.py` | LogSumExp → max interpolation | 3 figures |
| `demo_neural_wta.py` | Winner-take-all = tropical projection | 1 multi-panel figure |
| `demo_consciousness_phase_transition.py` | Phase transition & consciousness | 2 multi-panel figures |

### 📐 Lean 4 Formalization
- **[`Tropical/TropicalQuantumBrain.lean`](../Tropical/TropicalQuantumBrain.lean)** — Machine-verified proofs of all core theorems

**All 27 theorems proven, zero sorries.** Key results:
- Tropical semiring axioms (commutativity, associativity, distributivity, idempotency)
- ReLU = tropical addition with zero
- Tropical Hadamard idempotency (H_T² = H_T)
- Tropical CNOT non-involutivity (CNOT_T² ≠ I)
- Tropical phase gate group structure
- Maslov sandwich theorem (LogSumExp approximation bounds)
- Winner-take-all idempotency (WTA² = WTA)
- Consciousness functional positivity

---

## Generated Visualizations

After running the demos, these images are produced:

### Tropical Gates
![Tropical vs Quantum Hadamard](demos/tropical_vs_quantum_hadamard.png)
![Tropical CNOT](demos/tropical_cnot.png)
![Tropical Gate Composition](demos/tropical_gate_composition.png)
![Tropical-Quantum-Neural Dictionary](demos/tropical_dictionary.png)

### Maslov Deformation
![Maslov Deformation](demos/maslov_deformation.png)
![Neural Beta Regimes](demos/neural_beta_regimes.png)
![Phase Diagram](demos/maslov_phase_diagram.png)

### Neural & Consciousness
![Neural WTA = Tropical Projection](demos/neural_wta_tropical.png)
![Consciousness Phase Transition](demos/consciousness_phase_transition.png)
![Tropical Decoherence](demos/tropical_decoherence.png)

---

## Quick Start

```bash
# Run all demos
cd TropicalQuantumBrain/demos
pip install numpy matplotlib
python3 demo_tropical_gates.py
python3 demo_maslov_deformation.py
python3 demo_neural_wta.py
python3 demo_consciousness_phase_transition.py

# Check Lean proofs
cd ../..
lake build Tropical.TropicalQuantumBrain
```

---

## Key Equations

**Maslov Deformation (the bridge between quantum and tropical)**:
```
a ⊕_β b = (1/β) · log(e^{βa} + e^{βb})

β → 0:  arithmetic mean    (quantum-like)
β = 1:  LogSumExp/softmax   (machine learning)  
β → ∞:  max(a, b)          (tropical)
```

**Maslov Sandwich Theorem** (proven in Lean 4):
```
max(a,b) ≤ (1/β)·log(e^{βa} + e^{βb}) ≤ max(a,b) + log(2)/β
```

**Consciousness Functional**:
```
C(β) = β · exp(-(β - β_c)² / σ²)
```
Maximized at β = β_c (the critical point). Zero at β = 0. Positive for all β > 0.
