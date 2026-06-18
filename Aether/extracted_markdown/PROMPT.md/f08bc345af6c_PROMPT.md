Formalize a focused, self-contained Lean 4 development for the two-way independence model of contingency tables, avoiding any unrelated material and avoiding truncated declarations. Work in one new file only, with complete definitions and sorry-free proofs.

Target theorem package:

1. Define an `m × n` integer contingency table as `Fin m → Fin n → ℤ`.
2. Define row sums and column sums.
3. Define when two tables have the same margins.
4. Define the basic `2 × 2` move `B(i,i',j,j') = e_{i,j'} + e_{i',j} - e_{i,j} - e_{i',j'}` for indices with `i ≠ i'` and `j ≠ j'`.
5. Prove rigorously that a basic move preserves every row sum and every column sum.
6. Prove that the total sum of a basic move is zero.
7. Define a legal one-step move relation on tables: `u → v` if `v = u + basicMove ...` and both tables are entrywise nonnegative.
8. Prove the one-step soundness theorem: any legal basic move connects two tables in the same fiber.
9. If feasible, add a clean lemma: if `u` and `v` have the same margins, then `u - v` has zero row sums and zero column sums.

Important constraints:
- Do not attempt the full theorem that all equal-margin nonnegative tables are connected by basic moves unless the entire proof is fully complete and isolated.
- Do not include unrelated developments from probability, graph Laplacians, elliptic curves, expression languages, or any other domain.
- Keep the API minimal and reusable for a later connectivity proof.
- Prefer elementary proofs using `Finset.sum` over `Fin` and direct case splits on index equalities.
- Ensure theorem statements are complete, names are stable, and the file compiles standalone with `import Mathlib`.

Suggested structure:
- namespace `MarkovBases.TwoWay`
- definitions: `Table`, `rowSum`, `colSum`, `sameMargins`, `basicMove`
- lemmas: `basicMove_rowSum`, `basicMove_colSum`, `basicMove_sameMargins`, `basicMove_totalSum_zero`
- relation: `LegalBasicStep`
- theorem: `LegalBasicStep.sameMargins`
- optional kernel lemma: `sameMargins_sub`

Deliver a single polished Lean file with documentation comments explaining the mathematics and the exact scope: this is the algebraic foundation for a later formal proof of fiber connectivity by 2×2 moves, not the full connectivity theorem itself.