# Important Questions Answered: EML–Pythagorean Bridge

## Questions Definitively Answered (with Formal Proofs)

### Q1: Do the Berggren matrices preserve the Pythagorean property?
**Answer: Yes.** All three Berggren matrices M₁, M₂, M₃ preserve the Pythagorean relation a² + b² = c². This is proven by showing they preserve the Lorentz form Q(a,b,c) = a² + b² − c², so Q = 0 is invariant.

*Lean theorems: `M₁_preserves`, `M₂_preserves`, `M₃_preserves`, `M₁_preserves_lorentz`, `M₂_preserves_lorentz`, `M₃_preserves_lorentz`*

### Q2: What algebraic group do the Berggren matrices belong to?
**Answer: O(2,1; ℤ).** The Berggren matrices preserve the indefinite quadratic form Q(a,b,c) = a² + b² − c², placing them in the integer orthogonal group of signature (2,1). This is the same Lorentz group that appears in special relativity.

*Lean theorems: `lorentz_zero_iff_pyth`, `evalPath_lorentz`, `root_lorentz`*

### Q3: Do Berggren matrices have inverses?
**Answer: Yes.** Since the matrices preserve the Lorentz form, M⁻¹ = Q⁻¹ Mᵀ Q. We explicitly construct M₁⁻¹ and verify it is both a left and right inverse.

*Lean theorems: `M₁_inv_left`, `M₁_inv_right`, `M₁_inv_example`*

### Q4: Does the hypotenuse always increase along the Berggren tree?
**Answer: Yes, for M₂ applied to positive triples.** We prove c' = 2a + 2b + 3c > c when a, b, c > 0. Numerically, the B-path growth ratio converges to 3 + 2√2 ≈ 5.828.

*Lean theorem: `M₂_hyp_growth`*

### Q5: Can the Pythagorean equation be expressed in EML coordinates?
**Answer: Yes.** For positive (a,b,c) with a² + b² = c², the log-space coordinates satisfy exp(2 log a) + exp(2 log b) = exp(2 log c), which is naturally expressed through EML operations.

*Lean theorems: `eml_sq_encoding`, `pyth_to_log_variety`*

### Q6: Does EML have a real fixed point?
**Answer: No.** The function eml(x, 1) = exp(x) satisfies exp(x) > x for all real x, so there is no fixed point. (Complex fixed points exist and are related to the Lambert W function.)

*Lean theorem: `eml_exp_no_fixed_point`*

### Q7: Is the product of Pythagorean hypotenuses again a hypotenuse?
**Answer: Yes.** The Brahmagupta–Fibonacci identity shows (a₁² + b₁²)(a₂² + b₂²) = (a₁a₂ − b₁b₂)² + (a₁b₂ + a₂b₁)², so hypotenuse products are hypotenuses.

*Lean theorems: `brahmagupta_fibonacci`, `pyth_hyp_product`, `sum_sq_multiplicative`*

### Q8: What parity patterns do Berggren tree triples follow?
**Answer: Always (odd, even, odd).** Starting from (3, 4, 5), which has pattern (odd, even, odd), all three Berggren matrices preserve this pattern. This means in the entire Berggren tree, the first leg is always odd, the second is always even, and the hypotenuse is always odd.

*Lean theorems: `M₁_preserves_parity`, `M₂_preserves_parity`, `M₃_preserves_parity`, `evalPath_parity`*

### Q9: What is the EML complexity of a depth-d Berggren path?
**Answer: O(d).** Each Berggren step requires a fixed number K of EML operations (estimated K ≈ 45 with constant sharing), so a d-step path needs ≤ Kd nodes. This is optimal up to constants.

*Lean theorem: `berggren_eml_linear_bound`*

### Q10: How do triples embed into quadruples?
**Answer: Via zero-padding.** Every Pythagorean triple (a,b,c) is also a quadruple (a,b,0,c). Both are characterized by the vanishing of their respective Lorentz forms.

*Lean theorems: `triple_to_quad`, `quad_lorentz_zero`*

---

## Questions Partially Answered (Numerical Evidence)

### Q11: Are Berggren tree angles uniformly distributed?
**Partial answer:** The angles θ = arctan(b/a) converge to mean 45° with standard deviation ≈17.5° (vs 25.98° for uniform). The distribution appears concentrated around 45° and is **not exactly uniform**.

### Q12: What are the growth rates along different Berggren paths?
**Answer:**
- B-path: ratio → 3 + 2√2 ≈ 5.828 (dominant eigenvalue of M₂)
- A-path: decreasing sequence starting from 2.60
- C-path: decreasing sequence starting from 3.40
- Mixed paths: oscillate between these extremes

### Q13: Does a Berggren-like tree exist for quadruples?
**Partial answer:** Quadruples exist and are formalized. The generator matrices for O(3,1; ℤ) are an active research area; 6+ generators are conjectured.

---

## Questions Identified as Open

### Q14: What is the exact minimum EML tree size for each Berggren matrix?
**Status: Open.** Estimated 20–50 nodes per matrix; exact computation requires exhaustive search.

### Q15: Can gradient descent on EML log-variety parameters find large triples?
**Status: Open.** Promising but untested at scale.

### Q16: Do the Berggren tree zeta functions have analytic continuation?
**Status: Open.** Deep connection to Selberg zeta functions via the Lorentz group.

### Q17: Does a finite matrix tree generate all primitive N-tuples for N ≥ 5?
**Status: Open.** The orthogonal groups O(N-1, 1; ℤ) become more complex with N.
