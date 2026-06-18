# FUTURE_DIRECTIONS — Tropicalization of Arithmetic Height on the Berggren Monoid

## Synthesis

This cycle built a genuine **Bridges ↔ Tropical ↔ Computation** bridge by comparing
two a-priori unrelated complexity measures on Berggren words: the *arithmetic
height* of the generated Pythagorean triple (its hypotenuse), reused from
`Cryptography/BerggrenLatticeReduction.lean` and the rational height
`ArithmeticVCDim.ratArithHeight` of `Bridges/ArithmeticVCDimension.lean`, versus a
*tropical (min-plus) transfer cost* `tCost` of the generating word. The new file is
`Bridges/TropicalArithmeticHeight.lean`. We proved the tropical cost is additive
under concatenation (the min-plus "multiplicativity" law), and that the arithmetic
height is sandwiched as `tCost + 5 ≤ height ≤ 5·7^{tCost}` — a linear lower bound
(inherited from `height_lower_bound_root`) against a new exponential upper bound
`height_upper_bound_pow`, folded from the generator-step estimate `hyp_upper_mul`
(`c' < 7·c`). This transports verbatim onto the catalog's `ratArithHeight` via
`ratArithHeight_word_eq` (`ratArithHeight = tripleHeight + 1`), and onto finite
boundaries via `boundary_height_le_trop_energy`.

The decisive structural insight came from the **Critic**: the comparison is
*one-sided*. We proved `log_height_le_tCost` (`log₇ height ≤ tCost`), but the
converse quasi-isometry is FALSE. The all-`A` spine has the exact closed form
`evalAtRoot (replicate n A) = (2n+3, 2n²+6n+4, 2n²+6n+5)`
(`evalAtRoot_replicate_A`), so its height is the **quadratic** `2n²+6n+5`
(`height_replicate_A`) while its tropical cost is `n`. Hence `log₇ height ~
2·log₇ n ≪ n = tCost`: arithmetic height is *sub-tropical* — controlled from above
by an exponential of the tropical cost, but able to grow only polynomially along
thin branches. The obstruction is precisely that generator `A` has no uniform
multiplicative lower factor (its factor tends to 1 on thin triples).

The methodological lesson: the tropical-additive surrogate captures the *worst-case*
(branch `B`, where `a+b>c` forces factor `>5`) but overestimates *thin* branches.
A faithful two-sided tropical theory therefore needs a *branch-sensitive* weight,
not a uniform one — which is the thread the directions below pull on.

## Results Summary

- `tCost_append`: proved — tropical cost is additive under concatenation (min-plus multiplicativity).
- `tCost_subadditive`: proved — subadditivity `tCost(uv) ≤ tCost u + tCost v` (here equality).
- `tCost_eq_length`: proved — unit-weight tropical cost equals word length.
- `hyp_upper_mul`: proved — generator step multiplies the hypotenuse by `< 7`.
- `tripleHeight_step_le`: proved — `ℕ`-height step bound `height(g·t) ≤ 7·height(t)`.
- `height_upper_bound_pow`: proved — tropical upper bound `height ≤ 5·7^{tCost}`.
- `tropical_height_sandwich`: proved — two-sided comparison `tCost+5 ≤ height ≤ 5·7^{tCost}`.
- `log_height_le_tCost`: proved — one-sided quasi-isometry `log₇ height ≤ tCost`.
- `ratArithHeight_word_eq`: proved — cross-domain bridge `ratArithHeight = tripleHeight + 1`.
- `ratArithHeight_sandwich`: proved — sandwich transported to the catalog rational height.
- `boundary_height_le_trop_energy`: proved — boundary heights bounded by `5·7^{tropEnergy S}`.
- `evalAtRoot_replicate_A`: proved — closed form of the all-`A` spine.
- `height_replicate_A`: proved — quadratic height `2n²+6n+5` on the all-`A` spine; **disproves** the reverse (two-sided log) quasi-isometry.

## Research Directions

### Direction 1: Branch-sensitive tropical weights restore a two-sided bound
**Hypothesis**: With per-generator weights `wt(A)=wt(C)=0`, `wt(B)=1` and tropical
cost `tCostB w = (number of B-letters in w)`, there exist constants `c₁,c₂>0` with
`c₁·tCostB w ≤ log₇ height(w)` and `log₇ height(w) ≤ tCostB w + c₂·log₇(|w|+2)`.
**Test**: Prove the lower bound by showing each `B` contributes a multiplicative
factor `≥5` (since `a+b>c` ⇒ `2a+2b+3c>5c`) while `A`,`C` contribute `≥1`; prove the
upper bound by combining `height_upper_bound_pow` with the polynomial spine bound.
**Why now**: `hyp_upper_mul` and the quadratic spine `height_replicate_A` already
isolate `B` as the only super-linear driver; we only need the matching `c'>5c` step
lemma for `B`.
**If true**: arithmetic height *is* quasi-isometric to a refined tropical cost,
giving a true Bridges↔Tropical equivalence rather than a one-sided estimate.
**If false**: thin `A`/`C` chains still leak super-logarithmic height, revealing a
second growth mode beyond the `B`-count.

### Direction 2: Exact closed forms for the `B`- and `C`-spines
**Hypothesis**: `evalAtRoot (replicate n B)` and `evalAtRoot (replicate n C)` have
closed forms whose hypotenuse is `Θ(ρ^n)` for an explicit algebraic `ρ` with
`5 ≤ ρ ≤ 7` (the `B`-spine genuinely exponential, unlike the quadratic `A`-spine).
**Test**: Mirror `evalAtRoot_replicate_A`: guess the vector recurrence from the
transfer matrix of `actGen .B`, prove it by induction, and extract the dominant
eigenvalue bound.
**Why now**: the `A`-spine method (`evalAtRoot_replicate_A`) is a turnkey template;
only the algebra of the matrix changes.
**If true**: pins the tropical upper constant `7` to the true `B`-growth `ρ`,
sharpening `height_upper_bound_pow` to `ρ^{tCost}`.
**If false**: the spine is not a clean geometric sequence, suggesting the dominant
eigenvalue is irrational and forcing an analytic (Perron–Frobenius) treatment.

### Direction 3: Tropical energy controls boundary *sums*, not just suprema
**Hypothesis**: For a finite prefix-closed boundary `S`,
`∑_{w∈S} height(evalAtRoot w) ≤ |S| · 5·7^{tropEnergy S}`, and more sharply the sum
is `Θ(5·7^{tropEnergy S})` when `S` is the depth-`d` boundary.
**Test**: Sum `boundary_height_le_trop_energy` over `S`; for sharpness, count the
depth-`d` boundary (`3^d` words) and use the `B`-spine lower bound from Direction 2.
**Why now**: `boundary_height_le_trop_energy` already gives the per-word bound; the
catalog's `boundaryWords`/`prefixClosed` infrastructure supplies the index sets.
**If true**: yields a tropical "partition-function" estimate linking arithmetic
height energy to min-plus energy on Berggren subtrees.
**If false**: the boundary sum is dominated by a few heavy `B`-rich words, i.e. the
measure concentrates — itself a useful extremal statement.

### Direction 4: A height-maximizer is a tropical-cost maximizer on finite subtrees
**Hypothesis**: On any finite prefix-closed subtree, a word maximizing
`tripleHeight (evalAtRoot ·)` also maximizes `tCostB` (the `B`-count), i.e. the
all-`B` word at maximal depth is the joint extremizer.
**Test**: Show `height` is strictly increasing when an `A`/`C` letter is swapped to
`B` at fixed length (a single-step exchange lemma via `hyp_upper_mul` plus the
`c'>5c` lemma for `B`), then fold the exchange argument over the subtree.
**Why now**: the generator-step lemmas already compare per-letter growth; the
exchange argument is local.
**If true**: a clean extremal principle — arithmetic and tropical maxima coincide,
the strongest form of the bridge.
**If false**: a non-`B`-maximal word can win, exposing interaction effects between
adjacent generators that the single-letter weights miss.

### Direction 5: Sub-tropicality as a general phenomenon for matrix-word heights
**Hypothesis**: For any finite set of `SL₃(ℤ)`-style integer matrices acting on a
positive cone, the coordinate height is tropically *upper*-controlled
(`height ≤ C·Λ^{length}` with `Λ = max operator norm`) but admits polynomial spines
exactly when some generator has a unipotent (eigenvalue-1) direction on the cone.
**Test**: Abstract `hyp_upper_mul`/`height_upper_bound_pow` to a typeclass of
"cone-positive integer generators" and re-derive the sandwich; characterize
polynomial spines via Jordan structure.
**Why now**: the Berggren proof only used `a,b<c` (cone positivity) and a uniform
operator bound — both generic; the quadratic `A`-spine is a textbook unipotent
signature.
**If true**: a reusable Bridges↔Tropical pipeline transporting min-plus
subadditivity into arithmetic-height estimates for any such monoid.
**If false**: the Berggren cone has special structure (the Pythagorean form) without
which the upper bound degrades, pinpointing what makes the bridge work.
