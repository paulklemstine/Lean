# Omega Meta-Oracle: Python Demos & Visualizations

## Quick Start

```bash
pip install matplotlib numpy
python3 demo1_stereographic_omega_point.py
python3 demo2_meta_oracle_convergence.py
python3 demo3_tropical_neural_bridge.py
python3 demo4_quantum_gates_sphere.py
python3 demo5_lift_solve_project.py
python3 demo6_hypotheses_experiments.py
```

## Demo Descriptions

| Demo | Output | Description |
|------|--------|-------------|
| `demo1` | `stereographic_omega_point.png` | Inverse stereographic projection, convergence to the Omega Point (north pole), oracle hierarchy on S¹ |
| `demo2` | `meta_oracle_convergence.png` | Contractive meta-oracle convergence, geometric error decay, oracle entropy, 2D spiral convergence, composition |
| `demo3` | `tropical_neural_bridge.png` | ReLU = tropical addition, max of affines, tropical dequantization (LogSumExp), softmax temperature, exp homomorphism |
| `demo4` | `quantum_gates_sphere.png` | Pauli & Hadamard gates on the Bloch sphere, gate algebra table, stereographic projection of Bloch sphere |
| `demo5` | `lift_solve_project.png` | Full Lift-Solve-Project pipeline: optimize f(t) = sin(t)·exp(-t²/10) via compactification |
| `demo6` | `hypotheses_experiments.png` | Testing 5 novel hypotheses: tropical NAS, quantum compactification, entropy bounds, universal tropical compiler, acceleration |

## Key Insight

All demos illustrate the same core idea: **lifting problems to compact spaces guarantees solutions exist**.
- Stereographic projection: ℝ → S¹ (compact)
- Quantum states: Hilbert space → Bloch sphere S² (compact)  
- ReLU networks: ℝⁿ → tropical polynomials on compact domains
- Meta-oracles: complete metric space → unique fixed point via Banach theorem
