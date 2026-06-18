# Summary of changes for run 7e5de6e1-2f99-459c-9f49-6aefe7825946
Created a single, self-contained Lean file `Catalog/Tropical/MinPlusPolynomialCore.lean` (namespace `Tropical.MinPlusPolynomialCore`) developing a narrowly scoped core of one-variable min-plus tropical polynomial theory over `ℤ`. It compiles with no errors, no warnings, and no `sorry`s, and every result depends only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`.

Contents:

1. Tropical operations: `tadd a b := min a b` and `tmul a b := a + b`, with simp lemmas `tadd_def`, `tmul_def`.

2. Elementary laws (concrete, no abstract semiring): `tadd_comm`, `tadd_assoc`, `tadd_idem`, `tmul_comm`, `tmul_assoc`, `zero_tmul`, `tmul_zero`, the two distributivity facts `tmul_tadd` / `tadd_tmul`, and a monotonicity fact `tmul_le_tmul_right`.

3. Monomials and polynomials: `monoEval (m,c) x = (m:ℤ)*x + c`; a tropical polynomial is a `List (ℕ × ℤ)`; `polyEval` evaluates a nonempty list as the minimum of its monomial values (empty list sent to `0` as a placeholder), with helper lemmas `polyEval_nil`, `polyEval_cons`.

4. Classification of small families: `polyEval_singleton` (`[(m,c)]` is exactly `(m:ℤ)*x + c`); `polyEval_slopeZero` together with `polyEval_slopeZero_const` (a slope-0 list evaluates to the fold-minimum of its intercepts, independent of `x`), supported by `foldl_min_slopeZero`; and `polyEval_two_term` (`[(0,a),(1,b)]` evaluates to `min a (x+b)`).

5. Roots: `IsRoot l x` holds when two distinct list positions both attain the polynomial minimum `polyEval l x` (distinctness via distinct `Fin l.length` indices, which keeps the two-term reasoning clean). The general corner fact is `isRoot_two_term_iff : IsRoot [(0,a),(1,b)] z ↔ z = a - b`.

6. Full root classification for `[(0,a),(1,b)]`, with the root set `rootSet a b` defined as the nonnegative integer roots `{z | 0 ≤ z ∧ IsRoot [(0,a),(1,b)] z}`: `rootSet_two_term_lt` (`a < b` ⇒ no roots, i.e. `∅`), `rootSet_two_term_le` (`b ≤ a` ⇒ roots are exactly `{a - b}`), and `rootSet_two_term_subsingleton` (the root set has at most one element in all cases).

Note on the root domain (documented in the module docstring): over all of `ℤ` the degree-one tropical polynomial `min a (x+b)` always has its unique corner at `z = a - b`. The requested dichotomy "`a < b` ⇒ no roots, `b ≤ a` ⇒ root `a - b`" is exactly the statement obtained by counting roots among the nonnegative integers, since `a - b ≥ 0 ↔ b ≤ a`. The root set was therefore defined as the set of nonnegative integer roots so that the requested classification holds verbatim (and matches the literal singleton `{a - b}`); the general `ℤ` picture is recorded separately in `isRoot_two_term_iff`.

The work stays entirely within the Tropical domain with no entropy/compression/information-theory/cross-domain material. (An unrelated, pre-existing missing file in a different build target — `Algebra/SpectralNovelty/CutMetric.lean` — prevents a whole-project build but is independent of this file, which was verified to compile and is axiom-clean on its own.)