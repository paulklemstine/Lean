# Computational Evidence — EML Universal Approximation via Standard ML Activations

The main results (`Catalog/Applications/EMLActivationDensity.lean`) are *structural*
density statements: a single strictly-monotone continuous activation, composed with an
injective feature, generates a uniformly dense subalgebra of `C(X, ℝ)` on a compact `X`.
The whole content reduces to **injectivity of the activation**, which follows from strict
monotonicity. There is therefore no universal claim over a parameter family to falsify by
sampling; the "experiment" is the monotonicity check itself, which is discharged formally.

For completeness we record small sanity checks confirming strict monotonicity of each
activation on sample grids (these match the formally proved `StrictMono` lemmas).

## Sigmoid `σ(x) = 1/(1+e^{-x})`
| x   | -2     | -1     | 0      | 1      | 2      |
|-----|--------|--------|--------|--------|--------|
| σ(x)| 0.1192 | 0.2689 | 0.5000 | 0.7311 | 0.8808 |

Strictly increasing. ✓ (formal: `strictMono_sigmoid`)

## Softplus `s(x) = log(1+e^x)`
| x   | -2     | -1     | 0      | 1      | 2      |
|-----|--------|--------|--------|--------|--------|
| s(x)| 0.1269 | 0.3133 | 0.6931 | 1.3133 | 2.1269 |

Strictly increasing. ✓ (formal: `strictMono_softplus`)

## tanh
| x   | -2      | -1      | 0      | 1      | 2      |
|-----|---------|---------|--------|--------|--------|
| tanh| -0.9640 | -0.7616 | 0.0000 | 0.7616 | 0.9640 |

Strictly increasing. ✓ (formal: `strictMono_tanh`)

## arctan
| x     | -2      | -1      | 0     | 1      | 2      |
|-------|---------|---------|-------|--------|--------|
| arctan| -1.1071 | -0.7854 | 0.000 | 0.7854 | 1.1071 |

Strictly increasing. ✓ (formal: `Real.arctan_strictMono`)

## Counterexample hunt
The only way the density theorem could fail is if some activation were *not* injective.
All four candidates are strictly monotone on all of ℝ (no plateaus), so no
injectivity-breaking counterexample exists; the formal `StrictMono` proofs certify this.
A *bounded non-monotone* activation (e.g. a Gaussian bump `e^{-x²}`) would break
injectivity and is correctly outside the scope of these theorems — flagged as a future
direction in `FUTURE_DIRECTIONS.md`.
