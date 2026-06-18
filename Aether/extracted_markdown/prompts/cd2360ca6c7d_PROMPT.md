Formalize a self-contained Lean 4 file proving a tropical extremal-support theory for finitely supported rational sequences, but reduce the dependency on combinatorial species to a final corollary section only. Do not attempt a broad species API. Work with `f : ℕ →₀ ℚ`.

Main task:
1. Define `ord : (ℕ →₀ ℚ) → WithTop ℕ` as the least `n` in `f.support`, with `ord 0 = ⊤`.
2. Define `deg : (ℕ →₀ ℚ) → WithBot ℕ` as the greatest `n` in `f.support`, with `deg 0 = ⊥`.
3. Prove the basic support API carefully and completely:
   - `ord_zero`, `deg_zero`
   - if `f ≠ 0`, existence of extremal support indices realizing `ord f` and `deg f`
   - `n < ord f -> f n = 0`
   - `deg f < n -> f n = 0`
   - if `ord f = n` or `deg f = n`, then `f n ≠ 0`
   - useful converse lemmas from support containment to inequalities on `ord`/`deg`
4. Define ordinary finitely supported Cauchy convolution
   `cconv (f g : ℕ →₀ ℚ) : ℕ →₀ ℚ`
   with coefficient formula
   `cconv f g n = ∑ i in Finset.range (n+1), f i * g (n - i)`.
   Implement it in a way that is easy to reason about coefficientwise.
5. Prove the tropical laws for addition:
   - `min (ord f) (ord g) ≤ ord (f + g)`
   - `deg (f + g) ≤ max (deg f) (deg g)`
   These should be proved by support containment / vanishing outside extremal windows.
6. Prove the exact convolution laws:
   - `ord (cconv f g) = ord f + ord g`
   - `deg (cconv f g) = deg f + deg g`
   The proof strategy must explicitly use the unique extremal contributing pair:
   - for indices below `ord f + ord g`, every summand vanishes
   - at index `ord f + ord g`, only the pair `(ord f, ord g)` contributes, so the coefficient is nonzero because `ℚ` is a domain
   - dually for `deg`
   Handle zero cases cleanly first, then the nonzero case.
7. Only after the above is fully complete, add a short bridge section to catalog material: if there is an already-verified file connecting coefficient sequences to EGF multiplication or binomial convolution, state a corollary or explanatory theorem showing how the extremal-profile result transfers to that setting. Keep this section lightweight and avoid introducing new species abstractions.

Requirements:
- Produce complete proofs with no placeholders.
- Prefer elementary support and finite-sum lemmas over sophisticated algebraic abstractions.
- Include a few tiny examples computing `ord`/`deg` and one nontrivial convolution example.
- If ordinary Cauchy convolution is much easier than the catalog's packaged binomial convolution, prioritize finishing the exact theorem for `cconv`; the species/EGF bridge can remain a final corollary layer.

Mathematical focus:
The deliverable is not a vague exploration but a fully checked theorem package showing that extremal support indices behave tropically under addition and exactly add under convolution for finitely supported rational sequences.

Suggested file placement:
`Catalog/Applications/SpeciesTropicalProfile.lean` is fine, but the content should be centered on finitely supported sequence profiles and convolution, with the species connection presented only as an application.

Be explicit in the file header that the core theorem is about finitely supported sequences, and the species/EGF interpretation is a downstream corollary.