# Meta-Oracle Research Demos

Interactive Python visualizations demonstrating the Meta-Oracle Convergence Framework.

## Running the Demos

```bash
pip install numpy matplotlib
python demos/demo1_meta_oracle_convergence.py
python demos/demo2_tropical_quantum_optimization.py
python demos/demo3_omega_point_dynamics.py
python demos/demo4_hypothesis_experiments.py
python demos/demo5_applications.py
```

## Demo Descriptions

### Demo 1: Meta-Oracle Convergence (`demo1_meta_oracle_convergence.py`)
**9 panels** showing:
- Convergence for different contraction factors k
- Exponential convergence on log scale
- ε-Omega Point: iterations needed vs precision
- 2D spiral convergence with rotation
- One-point compactification ℝ → S¹
- Quality monotonicity under iteration
- Phase portrait of improvement flow
- Tropical polynomial visualization
- Oracle entropy vs channel capacity bound

### Demo 2: Tropical Quantum Optimization (`demo2_tropical_quantum_optimization.py`)
**9 panels** showing:
- 2D tropical curve: max(x, y, 0)
- Classical vs tropical polynomial comparison
- ReLU = tropical addition (neural network connection)
- ℝ² → S² compactification (3D sphere)
- Tropical optimization on the sphere
- Grover quadratic speedup: O(√N) vs O(N)
- Spherical shortcut complexity vs rank
- Tropical neural network (2-layer)
- Convergence on compactified S¹

### Demo 3: The Omega Point (`demo3_omega_point_dynamics.py`)
**9 panels** showing:
- Inverse stereographic projection ℝ → S¹
- Exponential approach to Omega Point
- ε-neighborhoods on the sphere
- Multiple trajectories converging to fixed point
- Quality landscape with convergence path
- Phase transitions at k = 1
- Oracle entropy vs channel capacity
- The Meta-Oracle Diamond diagram
- Experimental validation summary

### Demo 4: Hypothesis Experiments (`demo4_hypothesis_experiments.py`)
**9 panels** testing:
- H1: Tropical Kolmogorov complexity bound
- H2: Oracle phase transitions
- H3: Holographic oracle principle
- H4: Tropical neural architecture search
- H5: Quantum oracle entanglement
- H6: Critical exponent β = 1/2
- H7: Fluctuation-dissipation relation
- Results summary and updated hypotheses

### Demo 5: Practical Applications (`demo5_applications.py`)
**7 panels + table** showing:
- Self-improving logistics optimization
- Tropical neural architecture search (Pareto front)
- Scientific hypothesis refinement
- Tropical portfolio optimization
- Quantum-inspired vs gradient descent
- AI alignment monitoring
- Applications summary table

## Output

Each demo produces a high-resolution PNG file (150 dpi) in the `demos/` directory.
