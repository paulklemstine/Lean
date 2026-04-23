# SPB Research Framework — Demos & Visuals

This directory contains Python demonstrations and SVG visualizations illustrating key algorithms and concepts from the Stereographic Pythagorean Bridge (SPB) research framework.

## Python Demos

### `spb_demo.py` — Core SPB Operations
Demonstrates the foundational SPB operation and its connections:
- **Tangent/Hyperbolic tangent addition** — SPB as tanh addition, with Wick rotation to classical tangent
- **Relativistic velocity addition** — SPB as Einstein's velocity composition formula
- **Berggren tree generation** — All primitive Pythagorean triples from (3,4,5)
- **Lorentz invariance** — Berggren matrices preserve x² + y² − z² = 0
- **EML operations** — Exp-Minus-Log and its algebraic properties
- **Tropical geometry** — LogSumExp as smooth max approximation
- **Fibonacci compositeness test** — F(n)² ≡ 1 (mod n) for primes
- **SPB group law** — Commutativity, associativity, identity, inverses
- **EML closure density** — Reaching any real number from 1

```bash
python3 spb_demo.py
```

### `crypto_demo.py` — Cryptography Applications
Demonstrates cryptographic algorithms and vulnerabilities:
- **ECDSA signing/verification** — Simplified demonstration with formal verification references
- **Nonce reuse attack** — Formally verified private key recovery
- **Fibonacci compositeness test** — Detection rates for composite numbers
- **Quantum security analysis** — Classical vs quantum attack complexity comparison

```bash
python3 crypto_demo.py
```

### `ml_tropical_demo.py` — Machine Learning & Tropical Geometry
Demonstrates ML and tropical geometry connections:
- **Tropical algebra basics** — Max-plus operations and distributivity
- **LogSumExp smoothing** — Temperature-scaled smooth max with provable bounds
- **ReLU ↔ tropical polynomials** — Neural networks as piecewise-linear functions
- **EML universal approximation** — Approximating any real from {1}
- **Lipschitz-certified networks** — Composition rules for adversarial robustness
- **Bayesian convergence** — Formally verified belief update dynamics

```bash
python3 ml_tropical_demo.py
```

## SVG Visualizations

### `svg_berggren_tree.svg` — The Berggren Tree
Visual representation of the ternary tree generating all primitive Pythagorean triples, showing:
- Root (3,4,5) and first three levels
- Berggren matrices B₁, B₂, B₃
- Verification that a² + b² = c² for each node
- Lorentz form preservation annotation

### `svg_spb_connections.svg` — SPB Connection Map
Hub-and-spoke diagram showing how SPB connects seven mathematical domains:
- Number Theory (6,038 declarations)
- Tropical Geometry (1,445 declarations)
- Machine Learning (1,120 declarations)
- Cryptography (741 declarations)
- Physics (2,830 declarations)
- EML Framework (4,530 declarations)
- Computation (3,079 declarations)

### `svg_tropical_neural.svg` — ReLU ↔ Tropical Polynomials
Side-by-side visualization showing the equivalence between:
- A ReLU neural network (left)
- Its tropical polynomial representation (right)
- The piecewise-linear function both compute

### `svg_algorithm_taxonomy.svg` — 50 Algorithm Taxonomy
Color-coded grid of all 50 novel algorithm applications:
- Organized by domain (Number Theory, ML, Cryptography, Physics, Systems)
- Color-coded by Technology Readiness Level (TRL 2-7)
- Impact distribution statistics

### `svg_eml_irrationality.svg` — Irrationality of e Proof
Step-by-step visualization of the formally verified proof that e is irrational:
- Four proof steps (assume, multiply, bound, contradict)
- Key Lean 4 code highlights
- Verification badge

## Running All Demos

```bash
cd demos
python3 spb_demo.py
python3 crypto_demo.py
python3 ml_tropical_demo.py
```

All demos are self-contained (no external dependencies beyond Python 3.6+ standard library).
