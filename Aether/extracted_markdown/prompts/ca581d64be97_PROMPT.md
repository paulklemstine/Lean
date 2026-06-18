Formalize a small, complete companion file for the Smooth Poincaré binary-code library, with no placeholders and no dangling theorem declarations. Work entirely in the finite setting of binary codes as `Finset (Fin n → ZMod 2)`, and build on the already verified weight machinery in `Catalog/FINAL/Applications/SmoothPoincare/TropicalWeightCollapse.lean` if available.

Target file: `Catalog/Applications/SmoothPoincare/ThresholdCount.lean`.

Primary goal: define and completely formalize cumulative and exact Hamming-weight counts for finite binary codes, proving a theorem cluster that is self-contained and actually closes.

Required definitions:
- `thresholdCount (C : Finset (Fin n → ZMod 2)) (k : ℕ) : ℕ := (C.filter (fun c => k ≤ wt c)).card`
- `exactCount (C : Finset (Fin n → ZMod 2)) (k : ℕ) : ℕ := (C.filter (fun c => wt c = k)).card`

Required theorems, in this order:
1. `thresholdCount_antitone`: if `k ≤ l` then `thresholdCount C l ≤ thresholdCount C k`.
2. `thresholdCount_zero`: `thresholdCount C 0 = C.card`.
3. `thresholdCount_eq_zero_of_maxWt_lt`: if `maxWt C < k` then `thresholdCount C k = 0`.
4. Basic exact-count facts that make the later finite sum usable, e.g.:
   - `exactCount_eq_card_filter`
   - `exactCount_eq_zero_of_maxWt_lt`: if `maxWt C < k` then `exactCount C k = 0`
5. A finite partition/decomposition theorem expressing threshold counts in terms of exact counts over a bounded range up to `maxWt C`. One acceptable form is:
   `thresholdCount C k = ∑ j in Finset.range (maxWt C + 1), if k ≤ j then exactCount C j else 0`
   or an equivalent bounded finite sum statement that is easier to prove in Lean.

Optional theorem only if the necessary infrastructure is already present and cleanly reusable from existing files:
6. `exactCount_append` / direct-sum convolution: for the code direct sum operation already formalized in the Smooth Poincaré library, prove the exact-count convolution identity at weight `k`. Use the precise existing constructor/notation from the library; do not invent a new direct-sum abstraction unless it is already essentially there. If this theorem starts to require substantial new infrastructure about products, embeddings, or code equivalences, skip it for this cycle.

Proof strategy requirements:
- Prefer elementary `Finset` arguments: `filter`, subset/filter monotonicity, extensional counting identities, and bounded sums.
- Reuse any existing lemmas about `wt`, `maxWt`, and weight bounds from the FINAL Smooth Poincaré files.
- Avoid unfinished theorem headers entirely. Every theorem included in the file must have a complete proof.
- Keep the file standalone and honest: if convolution is not tractable from current library support, leave it out rather than inserting placeholders.

Deliverable standard:
- The resulting file should compile cleanly.
- No `sorry`, no placeholders, no incomplete declarations.
- The theorem cluster should be mathematically coherent on its own even without the optional convolution theorem.

Why now? The existing tropical collapse file already supplies the finite code/weight framework and likely a `maxWt` notion, so the missing step is not new abstract theory but a careful finite combinatorics formalization that turns partial declarations into a reliable counting toolkit.