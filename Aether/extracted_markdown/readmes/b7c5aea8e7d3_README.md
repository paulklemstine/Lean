# Python Demos

Interactive Python demonstrations of the 50 algorithms enabled by the SPB framework.
Each demo is backed by formally verified mathematics in the corresponding Lean 4 files.

## Prerequisites

```bash
pip install numpy
```

## Demos

### 1. `berggren_tree.py` — Berggren Tree Explorer & Factoring
Demonstrates **Algorithms 1, 31**: Generates the ternary tree of primitive Pythagorean triples, verifies Lorentz invariance, traces triples back to the root, and attempts integer factoring via tree descent.

```bash
python3 demos/berggren_tree.py
```

### 2. `eml_operations.py` — EML Universal Arithmetic
Demonstrates **Algorithms 11, 22, 32**: Verifies all 8 formally proven EML algebraic identities, demonstrates EML closure density, neural network compression ratios, and the EML instruction set architecture.

```bash
python3 demos/eml_operations.py
```

### 3. `fibonacci_factoring.py` — Fibonacci Primality & Factoring
Demonstrates **Algorithms 2, 3, 5**: Fibonacci GCD identity verification, compositeness testing, Pisano period factoring, and the primitive divisor sieve (Carmichael's theorem).

```bash
python3 demos/fibonacci_factoring.py
```

### 4. `tropical_geometry.py` — Tropical Algebra & Neural Networks
Demonstrates **Algorithms 12, 15, 23, 33**: Tropical semiring operations, LogSumExp smooth maximum bounds, tropical shortest paths via matrix exponentiation, and tropical ReLU network analysis.

```bash
python3 demos/tropical_geometry.py
```

### 5. `cryptographic_analysis.py` — Cryptographic Security
Demonstrates **Algorithms 6, 8, 9**: Simplified ECDSA with nonce-reuse vulnerability detection, Grover-aware post-quantum security calculator, and SPB key agreement protocol.

```bash
python3 demos/cryptographic_analysis.py
```

### 6. `bayesian_convergence.py` — Verified Bayesian Inference
Demonstrates **Algorithms 19, 34**: Dead hypothesis theorem, zero-likelihood elimination, belief distance metric properties, geometric convergence, and Bayesian A/B testing.

```bash
python3 demos/bayesian_convergence.py
```

### 7. `stereographic_projection.py` — SPB & Stereographic Projection
Demonstrates **Algorithms 14, 21, 24, 27**: Stereographic projection from unit circle, SPB group properties, Wick duality between Euclidean and Minkowski signatures, relativistic velocity addition, SPB activation function, and conformal mesh generation.

```bash
python3 demos/stereographic_projection.py
```

## Verified Foundations

Every computation in these demos corresponds to a formally verified theorem:

| Demo | Key Verified Theorems | Lean File |
|------|----------------------|-----------|
| Berggren Tree | `B₁_preserves_lorentz`, `inv_B1_comp_B1` | `Pythagorean/Berggren/` |
| EML Operations | `EMLd_exp`, `EMLd_double_neg`, `EMLd_log_split` | `Computation/DensityTheory.lean` |
| Fibonacci | `fib_gcd_identity`, `fib_composite_test` | `Shared/Fib_gcd_identity.lean` |
| Tropical | `lse2_le_max_log2`, `trop_convex_comp` | `Tropical/` |
| Cryptography | `ecdsa_nonce_reuse`, `ecdsa_completeness` | `Cryptography/QuantumSecurity/` |
| Bayesian | `dead_hypothesis_stays_dead`, belief metric | `Algebra/Convergence.lean` |
| Stereographic | `tan_add_eq_spb`, `wick_duality` | `Geometry/Stereographic/` |
