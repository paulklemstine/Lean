# Future Directions: Countable Gluing and Embedding Obstructions for Set-Local Hausdorff Dimension

## Synthesis of this cycle

The catalog already carried the *single-set* set-local distortion theory
(`Geometry/FractalDimension.lean`: `AntilipschitzOnWith`,
`AntilipschitzOnWith.le_dimH_image`, `dimH_image_eq_of_lipschitzOn_antilipschitzOn`,
the two-sided Hölder squeeze) and its *composition* sequel
(`Geometry/QuasiSymmetricComposition.lean`). The missing structural axes were
**aggregation across scales** and **ambient-dimension obstructions**. This cycle
closes both in `Geometry/FractalDimensionGluing.lean`.

## Results summary (all proved, `sorry = 0`, standard axioms only)

1. `dimH_image_iUnion_eq_of_lipschitzOn_antilipschitzOn` — set-local bi-Lipschitz
   invariance is **exact under countable unions**: per-piece bi-Lipschitz control
   forces `dimH (f '' ⋃ sᵢ) = dimH (⋃ sᵢ)`.
2. `dimH_image_iUnion_le_of_holderOn` — a **uniform** Hölder exponent `r` glues to
   the single one-sided bound `dimH (f '' ⋃ sᵢ) ≤ dimH (⋃ sᵢ) / r`, with
   per-scale Hölder *constants* allowed to vary.
3. `dimH_le_of_antilipschitzOn_euclidean` — any antilipschitz map of `s` into `ℝⁿ`
   forces `dimH s ≤ n` (only the antilipschitz half is used).
4. `dimH_le_of_holderOn_leftInverse_euclidean` — a Hölder-of-exponent-`r` left
   inverse into `ℝⁿ` forces `dimH s ≤ n / r` (snowflake/Hölder embeddings).
5. `not_exists_antilipschitzOn_euclidean_of_lt_dimH` — the adversarial
   contrapositive: `dimH s > n` makes **any** antilipschitz embedding into `ℝⁿ`
   impossible. This is the lower half of `bldim(X) ≥ ⌈dimH X⌉`.

Two boundary facts pinned down the honest scope. First, gluing *requires*
countability (`[Countable ι]`): with an uncountable index `dimH_iUnion` fails, so
the equality cannot survive. Second, the glued Hölder bound is genuinely specific
to a **uniform** exponent: with per-piece exponents `rᵢ` one has
`⨆ (aᵢ / rᵢ) ≠ (⨆ aᵢ) / (⨆ rᵢ)` in general, so no single quotient bound exists —
this is why direction 1 below must track the *distribution* of exponents, not just
their supremum.

## Direction A — The η-quasisymmetric scale-decomposition bound

The natural sharpening of result (2) replaces the uniform exponent by a
scale-dependent modulus η and asks for `dimH (f '' s) ≤ (limsup_{t→0} log η(t)/log t) · dimH s`.
The key insight is that the boundary analysis of this cycle already shows the
obstruction precisely: because `⨆ (aᵢ / rᵢ)` does not factor, the correct invariant
is not a single exponent but the *limsup of the per-scale exponents* `log η(t)/log t`,
and result (2) is exactly the special case where that limsup is the constant `r`.
A falsifiable first target: prove that if `f` is bi-Hölder with exponent `rᵢ` on the
dyadic annulus `sᵢ` and `rᵢ → ρ`, then `dimH (f '' ⋃ sᵢ) ≤ dimH (⋃ sᵢ) / ρ`; the
conjecture is false if `liminf` rather than `limsup` is the governing quantity, which
a single two-scale example would refute. Why now? `dimH_image_iUnion_le_of_holderOn`
plus `ENNReal.iSup_div` already provide the gluing machinery; only the
`limsup`-vs-supremum upgrade of the exponent aggregation remains.

## Direction B — Conformal dimension `cdim(X) ≤ dimH(X)` as a clean inequality

Define `cdim(X) = ⨅ { dimH Y : Y quasisymmetric to X }`. The first checkable theorem
is `cdim(X) ≤ dimH(X)` together with quasisymmetric invariance of `cdim`. The key
insight is that the infimum is well-defined *as an `ℝ≥0∞` infimum over a nonempty
family* (X itself is in the family via the identity quasisymmetry), so `cdim ≤ dimH`
is immediate from `iInf_le`, and invariance reduces to showing the defining family is
the same for quasisymmetrically equivalent spaces — a direct transport along the
equivalence already certified bi-Lipschitz-locally by
`dimH_image_eq_of_lipschitzOn_antilipschitzOn`. A falsifiable sub-claim: `cdim` is
**not** bi-Lipschitz-trivial, i.e. there exist `X` with `cdim(X) < dimH(X)` (the
classic snowflake), which result (4) makes precise via the `n/r` gap. Why now? Only
the `ℝ≥0∞`-infimum packaging is missing; every metric input already exists in the
catalog.

## Direction C — IFS attractor dimension via a Hölder coding section

For an IFS of contractions with ratios `r₁,…,rₖ` satisfying the open set condition,
the coding map `π : {1,…,k}^ℕ → K` is Hölder and admits an antilipschitz section on a
large subset. The key insight is that result (4),
`dimH_le_of_holderOn_leftInverse_euclidean`, is *already the exact consumer* of "a
Hölder left inverse on a good subset": the open set condition is precisely the
hypothesis that upgrades `π` from merely Hölder to having a Hölder/antilipschitz
inverse on a full-measure piece, squeezing `dimH K` to the similarity dimension `s`
with `Σ rᵢˢ = 1`. A falsifiable checkpoint: drop the open set condition and the
two-sided squeeze must fail — exhibit overlapping maps where `dimH K < s`. Why now?
The two-sided bound is set-local, so it applies directly to the "good" subset without
needing `π` globally invertible; the only new work is constructing that subset.

## Direction D — The matching embedding upper bound (Assouad for doubling sets)

Results (3)–(5) give `bldim(X) ≥ ⌈dimH X⌉`; the open frontier is the matching upper
bound `bldim(X) ≤ N(dimH X)` for doubling spaces via an Assouad-type embedding into
`ℝᴺ`. The key insight is that our obstruction is purely about the *antilipschitz*
direction, so the remaining target is orthogonal: construct an explicit Lipschitz
*and* antilipschitz map into `ℝᴺ` for doubling `X`, after which
`dimH_image_eq_of_lipschitzOn_antilipschitzOn` certifies dimension preservation for
free. A falsifiable boundary: the embedding must fail for non-doubling spaces, so a
non-doubling `X` of finite `dimH` that does **not** bi-Lipschitz embed into any `ℝᴺ`
would both confirm the necessity of doubling and sharpen the gap between `bldim` and
`⌈dimH⌉`. Why now? The lower bound is fully formalized this cycle; the upper bound is
the sole remaining ingredient and reuses the already-proven invariance theorem
verbatim.

## Direction E — Product/slice lower bound `dimH (A × B) ≥ dimH A + dimH B`

Slicing fixes `b ∈ B` and uses the isometric (hence antilipschitz) embedding
`a ↦ (a,b)`. The key insight is that `dimH_le_of_antilipschitzOn_euclidean`'s parent,
`AntilipschitzOnWith.le_dimH_image`, gives `dimH A ≤ dimH (A × {b})` on each slice
*set-locally* — removing the need for a global inverse of the slice inclusion, which
is the usual technical obstruction. A falsifiable boundary: the inequality can be
**strict** (Besicovitch–Moran sets), so any proposed equality `dimH (A × B) =
dimH A + dimH B` in `ℝⁿ` is false in general and a counterexample search should be run
first. Why now? The set-local antilipschitz lower bound is exactly the slice tool;
only the additive covering estimate connecting slice dimensions to the product
dimension remains, and it is now isolated as the single missing lemma.
