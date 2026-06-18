Create a new Lean file `Catalog/Applications/EGFOrderProfile.lean` that is self-contained, compiles without placeholders, and stays tightly scoped to exponential generating functions over `ℚ`.

Work in the namespace already used by `Catalog.Applications.CombinatorialSpecies`, and import only what is needed plus that file. Reuse the existing definitions and lemmas from the catalog, especially `egf`, `coeff_egf`, `egf_add`, `egf_mul`, and the convolution operation already paired with `egf_mul`.

Concrete objectives:

1. Restate the coefficient formula over `ℚ`:
   `PowerSeries.coeff n (egf a) = a n / n.factorial`.
   Use the exact existing lemma if available; do not reprove the species theory.

2. Prove the vanishing equivalence
   `PowerSeries.coeff n (egf a) = 0 ↔ a n = 0`.
   This is the central theorem. Use the coefficient formula and the fact that `(n.factorial : ℚ) ≠ 0`.
   If the nonzero form is easier first, prove
   `PowerSeries.coeff n (egf a) ≠ 0 ↔ a n ≠ 0`
   and derive the zero form.

3. Define
   `egfOrder (a : ℕ → ℚ) : ℕ∞ := PowerSeries.order (egf a)`.

4. Prove only robust order statements that can be discharged from generic `PowerSeries.order` lemmas already in Mathlib. Preferred targets, in order:
   - an addition/ultrametric statement for pointwise addition, obtained from `egf_add` plus the generic order inequality for sums;
   - a convolution/product lower bound for the sequence operation corresponding to `egf_mul`, obtained from `egf_mul` plus any generic multiplicative order inequality available.
   If exact equality for convolution requires unavailable lemmas or extra hypotheses, do not force it: a lower bound is acceptable.

5. If there is a clean existing characterization of `PowerSeries.order ≥ N` by coefficient vanishing below `N`, specialize it to EGFs and derive a support criterion for sequences. Otherwise skip this part.

6. Keep the file focused. Remove all unrelated pasted material. Do not introduce tropical semirings, truncation machinery, or broad abstractions. The deliverable is a small verified bridge theorem package around EGF coefficient support and induced order.

Implementation guidance:
- Prefer theorem names that reflect what is actually proved, e.g. `coeff_egf_eq`, `coeff_egf_eq_zero_iff`, `egfOrder`, `min_egfOrder_le_egfOrder_add`, `egfOrder_binConv_le`.
- Before stating any multiplicative exactness theorem, check whether the imported environment provides a directly usable theorem such as `PowerSeries.order_mul` with hypotheses. If not, weaken the statement.
- Use `norm_num`, `field_simp`, or simple algebraic rewriting only as needed; avoid brittle proof scripts.
- The final file must compile cleanly.

The key insight is that over `ℚ`, the EGF denominator `n!` never vanishes, so the support of the sequence is exactly the support of the EGF coefficients; this gives a concrete order profile without needing any tropical formalism. Why now? The catalog already contains the EGF API (`egf`, coefficient formula, additive and multiplicative compatibility), so a narrow formalization that packages support/order consequences is tractable immediately, whereas the previous attempt failed mainly because it aimed too broadly and included malformed unrelated code.