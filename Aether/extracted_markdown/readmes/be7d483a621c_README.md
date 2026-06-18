# The Arithmetic Kaleidoscope — Demo Programs

## Overview

These Python programs explore novel dynamical systems on the integers,
discovered through computational exploration and verified with formal proofs.

## Demos

### `demo1_pisano_kaleidoscope.py` — Fibonacci Residue Networks
Explores the Pisano period and discovers which moduli allow Fibonacci to visit
all residues. Introduces the "Fibonacci shadow" concept.

```bash
python3 demo1_pisano_kaleidoscope.py
```

### `demo2_digit_gravity.py` — Digit Gravity Dynamics
The novel map G(n) = |n - reverse(n)| + digit_sum(n) and its rich attractor
landscape dominated by powers of 2.

```bash
python3 demo2_digit_gravity.py
```

### `demo3_prime_gap_triangles.py` — Prime Gap Geometry
Forms triangles from consecutive prime gap triples, studies mod-6 structure,
autocorrelation, and gap "DNA" patterns.

```bash
python3 demo3_prime_gap_triangles.py
```

### `demo4_orbit_weaving.py` — Orbit Weaving
The map W(x,y) = (x+y, x·y) mod n and its complete fixed-point classification.

```bash
python3 demo4_orbit_weaving.py
```

## Raw Experiments

The `experiment*.py` files contain the original computational explorations
that led to the discoveries formalized in the demos and research papers.

## Formal Proofs

Key theorems are machine-verified in `../Research/MetaOracleDiscoveries.lean`.
