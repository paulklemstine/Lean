# Research Report: Tropical Degree Certified Robustness

## Summary

We provide a machine-verified proof (in Lean 4 with Mathlib) that the tropical degree of a feedforward ReLU network yields a deterministic, efficiently computable certificate for adversarial robustness in the L∞ threat model.

## Mathematical Result

### Definitions

- **L∞ norm** on ℝⁿ: `‖x‖_∞ = max_i |xᵢ|`
- **L∞-Lipschitz**: A function `f : ℝⁿ → ℝ` is L-Lipschitz if `|f(x) − f(y)| ≤ L · ‖x − y‖_∞` for all x, y.
- **Classification margin**: For a classifier `f : ℝⁿ → ℝᵐ`, the margin at input x for true label y is `γ = min_{j ≠ y} [f(x)_y − f(x)_j]`.
- **Certified robustness**: The classifier is certified robust at x with radius r if no L∞ perturbation of norm < r changes the predicted class.

### Main Theorems

**Theorem (Tropical Monomial Lipschitz Bound).** A tropical monomial `a + Σᵢ wᵢxᵢ` has L∞-Lipschitz constant at most `Σᵢ |wᵢ|`.

**Theorem (Lipschitz Preservation under Max/Min).** The pointwise supremum (resp. infimum) of finitely many L-Lipschitz functions is again L-Lipschitz.

**Theorem (Margin Preservation).** If every output component of `f` is L-Lipschitz and the classification margin γ at input x is positive, then f is certified robust at x with radius `γ / (2L)`.

**Theorem (Certified Robustness from Tropical Degree).** If the tropical degree of a ReLU network is d and the per-layer weight norm bound is K, then each component is (K·d)-Lipschitz. For margin γ > 0, the certified robustness radius is `γ / (2Kd)`.

## Proof Architecture

The proof proceeds in four stages:

1. **Monomial bound** (`tropical_monomial_lipschitz`): Uses Hölder's inequality (ℓ¹–ℓ∞ duality) to bound the difference of affine functions.

2. **Max/min preservation** (`sup_of_lipschitz_is_lipschitz`, `inf_of_lipschitz_is_lipschitz`): Since tropical polynomials are built from max and plus, and tropical rational functions involve differences, these lemmas lift component-wise Lipschitz bounds to the full tropical expression.

3. **Margin preservation** (`margin_preservation`): The core robustness argument. If `‖δ‖_∞ < γ/(2L)`, then each component can shift by at most `L·‖δ‖_∞ < γ/2`, so the margin can decrease by at most `2 · (γ/2) = γ`, preserving the argmax.

4. **Main theorem** (`certifiedRobustness_from_margin`): Instantiates the Lipschitz constant as `K·d` where d is the tropical degree and K is the weight norm product.

## Significance

This result bridges **tropical algebraic geometry** and **neural network verification**:

- The tropical degree is a *geometric invariant* of the network's piecewise-linear function, computable from the network architecture without solving any optimization problem.
- The robustness certificate is *deterministic* (no randomness or relaxation needed) and *sound* (machine-verified in Lean 4).
- The approach provides a polynomial-time alternative to NP-hard exact verification methods, at the cost of potential conservatism.

## Verification

All proofs compile in Lean 4.28.0 with Mathlib. The only axioms used are the standard ones (`propext`, `Classical.choice`, `Quot.sound`). No `sorry` placeholders remain.

## File Structure

- `TropicalDegreeRobustness.lean` — Complete formalization (all proofs verified)
- `RESEARCH_REPORT.md` — This report
- `demo.py` — Numerical demonstration
- `diagram.svg` — Conceptual diagram
- `DISCUSSION.md` — Popular-science discussion
