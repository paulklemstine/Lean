# Factoring Algorithm Demos

Python demonstrations of the 50 novel factoring algorithms described in `FACTORING_RESEARCH_PAPER.md`.

## Running the Demos

Each demo is self-contained and requires only Python 3 (no external dependencies).

```bash
python3 inside_out_factoring.py    # Algorithm 1: Berggren tree descent
python3 tropical_factoring.py      # Algorithm 22: Tropical valuation sieve
python3 quaternion_factoring.py    # Algorithm 15: Quaternion norm factoring
python3 fibonacci_factoring.py     # Algorithms 29-35: Fibonacci-based methods
python3 chimera_factoring.py       # Algorithm 9: Multi-strategy chimera
python3 energy_landscape.py        # Algorithm 43: Energy landscape descent
```

## Demo Descriptions

### `inside_out_factoring.py` — Berggren Tree Descent (Algorithm 1)
Given an odd composite N, constructs the trivial Pythagorean triple
(N, (N²-1)/2, (N²+1)/2) and descends the Berggren ternary tree by
applying inverse matrices B₁⁻¹, B₂⁻¹, B₃⁻¹. At each node, checks
GCD(leg, N) for nontrivial factors. Success rate: 17/18 on test suite.

### `tropical_factoring.py` — Tropical Valuation Sieve (Algorithm 22)
Factors integers using p-adic valuations. Demonstrates tropical profiles,
smoothness detection, perfect square testing via even/odd valuations, and
smooth number sieving. All operations correspond to verified theorems
in `Speculative/TropicalFactoring.lean`.

### `quaternion_factoring.py` — Quaternion Norm Factoring (Algorithm 15)
Uses multiple four-square representations of N and the Euler identity
(quaternion norm multiplicativity) to extract factors via cross-term GCDs.
Also includes the Brahmagupta-Fibonacci two-square method.

### `fibonacci_factoring.py` — Fibonacci Methods (Algorithms 29-35)
Demonstrates Pisano period computation, the GCD identity gcd(F_m,F_n) = F_{gcd(m,n)},
Fibonacci pseudoprime testing, and the Fibonacci sieve (analogous to Pollard p-1).

### `chimera_factoring.py` — Multi-Strategy Attack (Algorithm 9)
Combines Fermat's method (congruence of squares), Shor's algebraic core
(classical emulation), and Pollard's rho into a unified factoring engine.

### `energy_landscape.py` — Energy Landscape Descent (Algorithm 43)
Models factoring as an optimization problem with an energy function
whose minima correspond to divisors of N. Includes gradient descent
and Morse theory perspectives.

## Formal Verification

All algorithms are grounded in formally verified mathematics in the Lean 4
project. Key verified theorems:

| Theorem | File | Used By |
|---------|------|---------|
| `congruence_of_squares_zmod` | `ChimeraFactoring.lean` | Chimera |
| `quat_norm_mul` | `QuaternionFactoring.lean` | Quaternion |
| `fib_gcd_identity` | `Fib_gcd_identity.lean` | Fibonacci |
| `semiprime_valuation` | `TropicalFactoring.lean` | Tropical |
| `inv_B1_preserves` | `TreeFactoring/Core.lean` | IOF |
| `shor_algebraic_core` | `ChimeraFactoring.lean` | Chimera |
