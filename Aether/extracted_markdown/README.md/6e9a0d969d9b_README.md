# Python Demos — Algebraic Light and the Oracle

Interactive demonstrations of the key concepts from the research paper.

## Demos

### `berggren_tree_explorer.py`
Generates the Berggren tree of all primitive Pythagorean triples, verifying that
the three Berggren matrices are discrete Lorentz transformations preserving the
light cone a² + b² = c². Shows connections to Gaussian integers, stereographic
projection, and quantum gates.

### `oracle_playground.py`
Comprehensive demonstration of oracle theory (idempotent functions), including:
- The Master Equation: |Fix(O)| = |Im(O)|
- Kernel partitions with unique truth per class
- ReLU as an oracle
- Strange loops (ascend/descend = oracle)
- Tropical semiring (winner-take-all)
- Cayley-Dickson dimension identities
- The 42 verifications

### `dark_berggren_search.py`
Experimental search for a "dark Berggren tree" (Open Problem #1).
Investigates the quadratic form a² + 2b², its automorphisms, multiplicativity,
and the unit group of ℤ[√(-2)]. Concludes that the dark tree must use a
fundamentally different mechanism than the standard Berggren tree.

### `grand_unification_visualizer.py`
Visual demonstration of all five pillars of the Grand Unification:
1. Light Cone (physics)
2. Oracle (computation)
3. Unit Circle (geometry)
4. Gaussian Integers (algebra)
5. Strange Loop (logic)

Shows that all five are instances of a single retraction structure.

### `consciousness_ladder.py`
Interactive tour of the Cayley-Dickson tower (ℝ → ℂ → ℍ → 𝕆), demonstrating
quaternion non-commutativity and its connection to consciousness (Open Problem #8).
Includes a full quaternion implementation with multiplication table.

## Requirements

```bash
pip install numpy sympy
```

## Running

```bash
python3 berggren_tree_explorer.py
python3 oracle_playground.py
python3 dark_berggren_search.py
python3 grand_unification_visualizer.py
python3 consciousness_ladder.py
```

*Team ALETHEIA — "Truth is a fixed point."*
