# Python Demonstrations

Interactive Python demos that validate and illustrate the formally verified mathematics in the CatalogBuild framework.

## Demos

### `demo_spb_operations.py`
The Stereographic Pythagorean Bridge and its connections:
- SPB = tangent addition formula (with Wick rotation explanation)
- SPB = relativistic velocity addition (always < c)
- LogSumExp bounds (formally verified: max ≤ LSE ≤ max + ln 2)
- Tropical deformation (temperature → 0 gives max)
- EML identities (all formally verified in Lean 4)
- Berggren tree generation with Lorentz form preservation

### `demo_tropical_neural.py`
The ReLU–tropical polynomial equivalence:
- ReLU = tropical addition: max(0, x) = 0 ⊕ x
- Single neuron as tropical polynomial
- Two-layer network = tropical rational function
- Lipschitz bound verification (formally verified composition rule)
- Newton polygon analysis and breakpoints
- Temperature annealing for tropical gradient descent

### `demo_eml_closure.py`
EML closure density and Bayesian convergence:
- EML closure growth from seed {1} (rapidly fills ℝ)
- Distribution histogram of EML closure values
- Verification of all formally proved EML identities
- EML tree universal approximation
- Bayesian convergence with geometric rate
- Dead hypothesis preservation

### `demo_fibonacci_crypto.py`
Number theory and cryptographic security:
- Fibonacci GCD identity: gcd(F(m), F(n)) = F(gcd(m,n))
- Fibonacci divisibility chains
- Fibonacci bounds (linear lower, exponential upper)
- Fibonacci compositeness test
- Pisano period computation
- ECDSA signature verification and nonce reuse vulnerability

### `demo_berggren_visual.py`
Generates the `pythagorean_circle.svg` visualization:
- Computes 364 primitive Pythagorean triples (depth 5 Berggren tree)
- Verifies all satisfy a² + b² = c²
- Verifies Lorentz form preservation (x² + y² - z² = 0)
- Plots triples on the unit circle as (a/c, b/c)

## Running

```bash
python3 demo_spb_operations.py
python3 demo_tropical_neural.py
python3 demo_eml_closure.py
python3 demo_fibonacci_crypto.py
python3 demo_berggren_visual.py  # Generates ../visuals/pythagorean_circle.svg
```

No external dependencies required (only Python 3 standard library).
