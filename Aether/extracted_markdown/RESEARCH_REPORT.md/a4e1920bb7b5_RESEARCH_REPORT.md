# Research Report: Tropical Degree Lipschitz Certificate

## Summary

We formally proved in Lean 4 that the **tropical degree** of a max-plus polynomial provides a certified upper bound on its L∞ Lipschitz constant. This result bridges tropical geometry and certified adversarial robustness for ReLU neural networks.

## Mathematical Content

### Tropical Polynomials and ReLU Networks

A **tropical polynomial** is a function `p : ℝⁿ → ℝ` of the form:

```
p(x) = max_{α ∈ A} (a_α + α · x)
```

where `A ⊂ ℤⁿ` is a finite set of exponent vectors and `a_α ∈ ℝ` are coefficients. ReLU neural networks compute **tropical rational functions** — differences `f = p - q` of two tropical polynomials — as established by Zhang et al. (2018) and Alfarra et al. (2022).

### Main Results

We proved the following chain of results:

1. **Monomial Lipschitz bound** (`tropical_monomial_lipschitz`): A single tropical monomial `x ↦ a + α·x` is `‖α‖₁`-Lipschitz with respect to the L∞ norm, by Hölder duality.

2. **Finite supremum preservation** (`lipschitz_finset_sup'`): The pointwise supremum of finitely many K-Lipschitz functions is K-Lipschitz.

3. **Tropical polynomial bound** (`tropical_poly_lipschitz_bound`): A tropical polynomial `max_{α∈A}(a_α + α·x)` is `max_{α∈A} ‖α‖₁`-Lipschitz.

4. **Tropical rational bound** (`tropical_rational_lipschitz_bound`): A tropical rational function `p - q` is `(Lp + Lq)`-Lipschitz, where `Lp, Lq` are the tropical degree bounds of `p` and `q`.

5. **Robustness certificate** (`tropical_certified_robustness`): If `f(x₀) > 0` (correct classification), then `f(x) > 0` for all `x` with `‖x - x₀‖∞ < f(x₀) / (Lp + Lq)`.

### Proof Architecture

- **Step 1** uses the Hölder inequality `|v·w| ≤ ‖v‖₁ · ‖w‖∞` applied to the difference `x - y`.
- **Step 2** uses Finset induction and the Mathlib lemma `LipschitzWith.max`.
- **Step 3** combines Steps 1–2 with monotonicity (`LipschitzWith.mono`).
- **Step 4** applies `LipschitzWith.sub` from Mathlib.
- **Step 5** combines the Lipschitz bound with the triangle inequality to establish a certified radius.

## Significance

### For Verified AI Safety

This provides the first **machine-verified** proof that tropical degree bounds yield adversarial robustness certificates. Unlike empirical robustness evaluations (which can be circumvented by stronger attacks), these certificates are mathematically guaranteed.

### For Tropical Geometry

The formalization demonstrates that core results in tropical geometry — specifically the Lipschitz properties of tropical polynomials — can be mechanized in modern proof assistants with access to Mathlib's analysis library.

### For Certified Deep Learning

The robustness radius `r = f(x₀) / (Lp + Lq)` is:
- **Computable**: the tropical degree can be read off the network architecture.
- **Sound**: formally verified to provide a true lower bound.
- **Architecture-aware**: tighter bounds arise from smaller tropical degrees (shallower/narrower networks).

## Lean 4 Formalization Details

- **File**: `Tropical/TropicalLipschitz.lean`
- **Imports**: `Mathlib` (using Mathlib v4.28.0)
- **Axioms**: Only standard axioms (`propext`, `Classical.choice`, `Quot.sound`)
- **No sorry**: All theorems fully proved
- **Lines**: ~120 lines of Lean 4 code

## References

- Zhang, L., Naitzat, G., & Lim, L.-H. (2018). Tropical Geometry of Deep Neural Networks. ICML.
- Alfarra, M., Bibi, A., Hammoud, H., Gaafar, M., & Ghanem, B. (2022). On the Decision Boundaries of Neural Networks: A Tropical Geometry Perspective. IEEE TPAMI.
- Maragos, P., Charisopoulos, V., & Theodosis, E. (2021). Tropical Geometry and Machine Learning. Proceedings of the IEEE.
