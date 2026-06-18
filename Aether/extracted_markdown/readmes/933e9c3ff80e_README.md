# Quantum Reversibility × Elliptic Curve Security

## Research Investigation

This directory contains a comprehensive investigation into the mathematical
relationship between quantum gate inversion and elliptic curve cryptography,
with specific focus on secp256k1 (Bitcoin's curve).

## Key Findings

1. **secp256k1 has NO backdoor** — parameters are transparently derived
2. **All quantum gates are invertible** — circuit inversion is a feature, not a vulnerability
3. **Shor's algorithm** is the real threat, requiring ~2,330 logical qubits (~20M physical)
4. **Current hardware gap** is ~20,000× too small to break secp256k1

## Files

### Research Papers
- `RESEARCH_PAPER.md` — Full technical paper with proofs and analysis
- `SCIENTIFIC_AMERICAN.md` — Accessible popular science article

### Lean Formalizations
- `../QuantumECCGateInversion.lean` — Machine-verified proofs (all sorry-free ✅)
  - Pauli algebra (X², Z², XZ anticommutation)
  - Circuit inversion (2, 3, 4-gate, and n-gate versions)
  - secp256k1 parameter properties
  - Quantum resource estimates
  - CNOT self-inverse
  - Hasse bound verification

### Python Demos (in `demos/`)
- `demo_elliptic_curve.py` — Visualize EC points, group law, parameter comparison
- `demo_quantum_gate_inversion.py` — Gate unitarity, circuit inversion, uncomputation
- `demo_shor_tiny.py` — Shor's algorithm simulation on small curves
- `demo_hypothesis_experiments.py` — Test 4 novel hypotheses with experiments

### Generated Visualizations (after running demos)
- `elliptic_curve_visualization.png` — EC points over finite fields
- `group_law_and_security.png` — Group law and secp256k1 vs Dual_EC_DRBG
- `scalar_multiplication_ecdlp.png` — ECDLP difficulty visualization
- `quantum_gate_inversion.png` — Forward/inverse circuit diagram
- `shor_ecdlp_circuit.png` — Shor's algorithm circuit structure
- `quantum_vs_classical_ecdlp.png` — Complexity comparison
- `shor_period_finding.png` — Period-finding simulation results
- `hypothesis_results.png` — All hypothesis test results

## Running the Demos

```bash
cd demos
pip install numpy matplotlib
python demo_elliptic_curve.py
python demo_quantum_gate_inversion.py
python demo_shor_tiny.py
python demo_hypothesis_experiments.py
```

## Hypotheses Tested

| # | Hypothesis | Result |
|---|-----------|--------|
| H1 | Group homomorphism preserved under quantum embedding | ✅ Confirmed |
| H2 | T-gate complexity scales as Ω(n²) | ✅ Confirmed |
| H3 | Transparency metric distinguishes safe vs backdoored curves | ✅ Validated |
| H4 | Gate entropy grows sub-logarithmically | ✅ Confirmed |

## Proposed Applications

1. **Post-quantum migration planning** — Use resource estimates to set timelines
2. **Curve transparency auditing** — Apply the transparency metric to new curves
3. **Circuit optimization** — Use involution properties to simplify quantum circuits
4. **Educational tools** — Interactive demos for teaching quantum cryptography
