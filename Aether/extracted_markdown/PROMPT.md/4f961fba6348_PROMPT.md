Produce a single clean Lean 4 development formalizing a tropical-style coefficient-profile theory for finitely supported rational sequences, with no unrelated material and no placeholders.

Target file: `Catalog/Applications/SpeciesTropicalProfile.lean`.

Mathematical scope:
- Work with finitely supported sequences `f : ℕ →₀ ℚ`.
- Define `ord : (ℕ →₀ ℚ) → WithTop ℕ` as the least index with nonzero coefficient, with `ord 0 = ⊤`.
- Define `deg : (ℕ →₀ ℚ) → WithBot ℕ` as the greatest index with nonzero coefficient, with `deg 0 = ⊥`.
- Define a finitely supported binomial convolution `bconv f g : ℕ →₀ ℚ` using the catalog’s binomial convolution on coefficient functions; package it so all statements are about `ℕ →₀ ℚ`.

Required deliverable:
- The file must compile on its own.
- Include only theorems/definitions needed for this development.
- No `sorry`, no placeholders, no theorem stubs without proofs.
- Avoid importing or reproducing unrelated material.

Precise theorem targets:
1. Basic support/extremal-index lemmas.
   - Prove existence/characterization lemmas for the minimum and maximum support index of a nonzero finitely supported sequence.
   - Establish lemmas of the form: if `ord f = n`, then coefficients below `n` vanish and coefficient at `n` is nonzero; similarly for `deg`.
   - Provide zero/nonzero characterization lemmas for `ord` and `deg`.

2. Tropical laws for addition.
   - Prove `ord_add_ge : min (ord f) (ord g) ≤ ord (f + g)`.
   - Prove `deg_add_le : deg (f + g) ≤ max (deg f) (deg g)`.
   - These are inequalities only; do not force equality under cancellation hypotheses.

3. Exact tropical laws for binomial convolution.
   - Define `bconv` on finitely supported sequences in the way compatible with the catalog’s EGF multiplication theorem.
   - Prove `ord_bconv : ord (bconv f g) = ord f + ord g`.
   - Prove `deg_bconv : deg (bconv f g) = deg f + deg g`.
   - The proof strategy should explicitly isolate the unique extremal index pair for the first/last nonzero convolution term and use that over `ℚ` the corresponding binomial coefficient and product of extremal coefficients are nonzero.
   - Handle zero cases cleanly first, then the nonzero/nonzero case.

4. EGF compatibility.
   - State and prove the finitely supported versions of:
     - `egf_add_finsupp` for pointwise addition;
     - `egf_bconv` for binomial convolution.
   - Reuse catalog lemmas rather than reproving the full EGF algebra.

5. Small explicit examples.
   - Include a few concrete finitely supported sequences (for example monomials or two-term sequences) and prove their `ord`, `deg`, and `bconv` profile values.
   - Keep examples minimal and directly illustrative.

Proof strategy guidance:
- Follow the future direction exactly: this is a small complete bridge on finite support, not a broad species theory project.
- Prefer support-based arguments on `Finsupp.support` and finite-set extrema.
- For `ord_bconv` and `deg_bconv`, prove vanishing away from the extremal candidate by support bounds, then show the extremal coefficient is nonzero by identifying the unique contributing pair and using `Rat` as an integral domain.
- If the catalog already has a function-level binomial convolution and EGF theorem, wrap them carefully for finitely supported inputs instead of rebuilding the theory.

What to avoid:
- No ultrametrics, valuations on fields, p-adics, or number theory.
- No abstract generalization beyond `ℚ` unless it is genuinely necessary for the proofs.
- No giant theorem dump or cross-domain imports unrelated to species/EGFs/finsupp support reasoning.

Expected output quality:
- A coherent, standalone formalization that could upgrade the prior partial result to substantial/complete.
- The key insight is that a narrow finitely supported coefficient-profile bridge is both mathematically meaningful and tractable in Lean.
- Why now? Because the catalog should already supply the algebraic EGF/binomial-convolution backbone, leaving a sharply focused extremal-support formalization task.