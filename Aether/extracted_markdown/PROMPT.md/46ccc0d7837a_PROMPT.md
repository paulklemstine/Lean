Formalize a focused Applications/Bridges result about exponential generating functions over ℚ, keeping the scope narrow enough to finish completely with no placeholders.

Title: EGF order profile via coefficient support over ℚ

Problem statement:
Build a self-contained Lean file showing that the X-adic order of the exponential generating function of a sequence a : ℕ → ℚ is exactly the first index where a is nonzero, and therefore defines a valuation-like order on sequences that is additive for binomial convolution and ultrametric for pointwise addition.

Precise mathematical targets:
1. Use the existing EGF interface from Applications/CombinatorialSpecies.lean. Do not redefine the theory if the file already provides egf, coefficient formulas, or binomial convolution lemmas.
2. Prove a coefficient-support lemma specialized to ℚ:
   - coeff_egf_eq : coeff (egf a) n = a n / n!
     or the exact equivalent statement already available in the catalog.
   - coeff_egf_ne_zero_iff : coeff (egf a) n ≠ 0 ↔ a n ≠ 0.
   This should rely only on the nonvanishing of n! in ℚ.
3. Define
   - egfOrder (a : ℕ → ℚ) : WithTop ℕ := PowerSeries.order (egf a)
   or the exact order codomain used by Mathlib/catalog.
4. Prove the support-identification theorem for order:
   - egfOrder_eq_order_egf is definitional if you define it that way;
   - then prove a usable characterization such as
     egfOrder a ≤ n ↔ ∃ m ≤ n, a m ≠ 0,
     or a first-nonzero-index statement if convenient.
   Keep this statement aligned with the existing order API in Mathlib.
5. Prove the two central valuation laws on sequences:
   - egfOrder_binConv : egfOrder (binConv a b) = egfOrder a + egfOrder b
     using egf_mul and the power series order multiplication theorem.
   - min_egfOrder_le_egfOrder_add : min (egfOrder a) (egfOrder b) ≤ egfOrder (a + b)
     using egf_add and the order inequality for sums.
6. If and only if the above is completed cleanly, add one small truncation corollary. Define a finite-support truncation truncate N a by keeping coefficients < N. Prove a monotonicity statement about the induced order profile, for example that enlarging N cannot increase the first nonzero index past its previous value once a nonzero term has appeared. Keep this optional and only include it if straightforward.

Constraints:
- This is a formalize task, not a speculative theorem-proposal. Every theorem in the final file must have a complete proof and no sorry.
- Remove unrelated material. Do not include tropical semiring wrappers, zeta integrals, obstruction systems, or any other appended experiments unless they are directly used and fully proved.
- Prefer importing the most relevant existing catalog files rather than bare Mathlib when possible.
- Keep notation/API compatible with the catalog’s existing species and power series infrastructure.
- If some desired statement about PowerSeries.order is unavailable in the imported environment, adapt the theorem statements to the exact API that exists rather than inventing unsupported abstractions.

Expected deliverable:
A single coherent Lean file, likely named Catalog/Applications/EGFOrderProfile.lean or similar, containing a compact sequence of definitions and proved lemmas culminating in egfOrder_binConv and min_egfOrder_le_egfOrder_add. The file should read as a finished mini-development, not a sketch.

Proof strategy:
First mine Applications/CombinatorialSpecies.lean for the exact coefficient and multiplication/addition lemmas for egf. Next check the Mathlib/catalog API for PowerSeries.order lemmas under addition and multiplication. Then specialize all support arguments to ℚ so that factorial denominators are automatically nonzero. Only after the exact support-transfer lemma is proved should you define egfOrder and derive the valuation laws by transport along egf. If truncation is added, define it concretely and prove only the easiest monotonicity fact that follows immediately from the support description.