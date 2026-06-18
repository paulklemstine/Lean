Formalize a complete, self-contained Lean 4 development for the local algebra of `2×2` Markov moves on two-way integer contingency tables, and do not attempt the full global fiber-connectivity theorem unless everything before it is already complete and robust.

Primary goal:
Build a trustworthy foundation around `Table m n := Fin m → Fin n → ℤ` that fully formalizes the standard `2×2` basic move and its local consequences. The previous attempt overreached by stating major global theorems without complete proofs. This retry must prioritize a smaller but finished artifact.

Required scope:
1. Define:
   - `Table m n := Fin m → Fin n → ℤ`
   - row sums and column sums
   - total sum
   - table addition/subtraction as needed
   - nonnegativity predicate `Nonneg u := ∀ i j, 0 ≤ u i j`
   - the standard oriented `basicMove i i' j j'` with support on four cells
   - an admissible step structure/predicate `Step u u'` meaning `u' = u + basicMove ...` and the two decremented cells of `u` are at least `1`
   - `tdist u v := ∑ i, ∑ j, |u i j - v i j|`

2. Fully prove the exact invariance lemmas:
   - `basicMove_preserves_rowSums`
   - `basicMove_preserves_colSums`
   - `basicMove_preserves_totalSum`
   - bundled margin preservation lemmas for a `Step`
   - nonnegativity preservation for an admissible `Step`

3. Prove a precise local sign/rectangle lemma for `d = v - u` under equal row and column margins and `u ≠ v`. The target is not yet full connectivity, but a concrete witness-extraction statement of the following flavor:
   - there exists a positive entry `d i j > 0`
   - from zero row sum in row `i`, there exists `j' ≠ j` with `d i j' < 0`
   - from zero column sum in column `j`, there exists `i' ≠ i` with `d i' j < 0`
   - using the zero row/column constraints, derive a fourth corner giving the rectangle pattern needed for the oriented `2×2` move
   State the theorem in a form that is actually provable in Lean with your chosen intermediate lemmas.

4. If feasible, prove a separate arithmetic lemma analyzing `tdist` under a correctly oriented basic move. Keep this local and explicit: compute the change in the four affected coordinates and show the resulting inequality under the required sign hypotheses. It is acceptable to stop at a theorem of the form “under these four coordinate inequalities, applying this basic move strictly decreases `tdist`.”

5. Only after all of the above is complete, optionally package a one-step existence theorem `exists_candidate_reducing_step` or `exists_reducing_step` if the proof is genuinely complete. Do not state `twoWay_fiber_connected` unless you fully prove it.

Technical guidance:
- Keep the development elementary and explicit. Avoid introducing unnecessary global combinatorial machinery.
- Prefer small lemmas about `Finset.sum`, indicator-like support of the basic move, and pointwise evaluation of updated tables.
- It is fine to assume `[Fintype (Fin m)]` and use standard `Finset.univ` sums.
- Be careful about degenerate sizes (`m < 2` or `n < 2`). Either parameterize the main move theorems by explicit distinct indices `i ≠ i'`, `j ≠ j'`, or state existence lemmas only under hypotheses guaranteeing enough rows/columns.
- The final file must compile without `sorry`.

What to deliver:
- One coherent Lean file focused on local `2×2` move theory for two-way tables.
- Include theorem statements that are modest, precise, and fully proved.
- Do not pad the file with speculative later theorems.

Success criterion:
A complete formalization of the local algebraic infrastructure and at least one nontrivial witness-extraction/sign lemma, plus (ideally) a local `tdist` reduction lemma. A smaller finished artifact is strictly better than an ambitious incomplete one.