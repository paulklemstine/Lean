This project was edited by [Aristotle](https://aristotle.harmonic.fun).

To cite Aristotle:
- Tag @Aristotle-Harmonic on GitHub PRs/issues
- Add as co-author to commits:
```
Co-authored-by: Aristotle (Harmonic) <aristotle-harmonic@harmonic.fun>
```

# The Hidden Architecture of Numbers

A research exploration into five interconnected discoveries at the intersection of arithmetic, geometry, and dynamics.

## 📄 Paper

**[paper/paper.md](paper/paper.md)** — Full Scientific American–style research paper covering all five discoveries.

## 🔬 Key Discoveries

1. **The p^p Fixed Point Theorem** — The only fixed points of the arithmetic derivative are p^p for prime p (4, 27, 3125, 823543, ...). *Formally verified in Lean 4.*

2. **The Collatz Merge Metric** — A new metric on positive integers defined by orbit merging. Proven valid (triangle inequality holds) on tested data.

3. **Cross-Base Digit Sum Correlations** — Fourier analysis reveals why digit sums in power-related bases are correlated.

4. **The Resonance Index** — A novel number-theoretic invariant measuring cross-base digit harmony. Mersenne numbers are maximally discordant.

5. **Prime Gap Curvature** — Discrete curvature of the prime sequence scales as C/log(p).

## 🧮 Formal Proof (Lean 4)

The central theorem is machine-verified in [`RequestProject/ArithmeticDerivative.lean`](RequestProject/ArithmeticDerivative.lean):

```lean
theorem arithmeticDerivative_ppow_eq_self {p : ℕ} (hp : p.Prime) :
    arithmeticDerivative (p ^ p) = p ^ p
```

Build with: `lake build RequestProject.ArithmeticDerivative`

## 🐍 Python Demos

All experiments are in `demos/`:

| Script | Description |
|---|---|
| `experiment1_arithmetic_derivative.py` | Arithmetic derivative: fixed points, orbits, near-misses |
| `experiment2_prime_gap_geometry.py` | Prime gap autocorrelation, curvature, triple signatures |
| `experiment3_collatz_topology.py` | Collatz merge metric, fractal dimension, residue bias |
| `experiment4_spectral_digits.py` | Cross-base correlations, Fourier spectrum, digit entropy |
| `experiment5_deep_dive.py` | Deep dive: p^p proof, acceleration, resonance index |
| `experiment6_visualizations.py` | ASCII art visualizations of all discoveries |
| `experiment7_interactive.py` | Comprehensive interactive explorer |

Run any experiment: `python3 demos/experiment7_interactive.py`

## 📊 Data

Experimental results are saved as JSON in `figures/`.
