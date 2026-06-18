# Future Directions: Set-Local Distortion of Hausdorff Dimension

The file `Geometry/FractalDimension.lean` builds the **set-local** theory of Hausdorff
dimension distortion: the `AntilipschitzOnWith` predicate, the lower bound
`AntilipschitzOnWith.le_dimH_image`, the set-local bi-Lipschitz invariance
`dimH_image_eq_of_lipschitzOn_antilipschitzOn`, and the two-sided Hölder squeeze
`dimH_image_bounds_of_holderOn_holderOn_inverse`. Mathlib previously only had the
*global* versions (`AntilipschitzWith.le_dimH_image`, `Isometry.dimH_image`). The
following directions extend this frontier.

## 1. Quasi-symmetric distortion governed by the modulus η

A natural next theorem replaces the single Hölder exponent by a scale-dependent
modulus η, asking how `dimH (f '' s)` depends on the asymptotics of η near `0` and `∞`.
Note carefully: the naïve guess `dimH (f '' s) ≤ dimH s` is **false** — quasi-symmetric
maps genuinely change dimension (this is exactly why conformal dimension is interesting).
The key insight is that an η-quasi-symmetric map is, *at each fixed scale*, bi-Hölder with
exponents determined by `log η(t)/log t`, so our `dimH_image_bounds_of_holderOn_holderOn_inverse`
applied on a countable scale decomposition should yield a bound of the form
`dimH (f '' s) ≤ (limsup_{t→0} log η(t)/log t) · dimH s`. Why now? The two-sided Hölder
squeeze is already proved on arbitrary subsets, and `dimH_bUnion` lets us glue countable
scale pieces, so the only missing ingredient is the per-scale bi-Hölder extraction from η.

## 2. Conformal dimension as a quasi-symmetric invariant

Define `cdim(X) = inf { dimH Y : Y quasi-symmetrically equivalent to X }`. The first
checkable theorem is that `cdim` is invariant under quasi-symmetric homeomorphisms and
that `cdim(X) ≤ dimH(X)` always. The key insight is that our
`dimH_image_eq_of_lipschitzOn_antilipschitzOn` is precisely the bi-Lipschitz special case
(modulus η linear), so `cdim` is exactly what survives after quotienting the bi-Lipschitz
invariance by the larger quasi-symmetric equivalence relation. Why now? The set-local
invariance theorem already certifies bi-Lipschitz invariance on arbitrary subsets; building
the equivalence relation and taking the infimum is a direct formal step on top of it.

## 3. IFS attractor dimension via the coding map's Hölder section

For an iterated function system of contractions with ratios `r₁,…,rₙ`, the coding map
`π : {1,…,n}^ℕ → K` onto the attractor is Hölder, and under the open set condition it admits
an antilipschitz section on a large subset. Applying
`dimH_image_bounds_of_holderOn_holderOn_inverse` to π then squeezes `dimH K` between
multiples of the symbolic-space dimension, recovering `dimH K = s` where `Σ rᵢˢ = 1`. The
key insight is that the open set condition is exactly the hypothesis that upgrades π from
merely Hölder to having a Hölder/antilipschitz inverse on a full-measure piece, which is the
input our two-sided bound consumes. Why now? The two-sided Hölder squeeze is set-local, so it
applies directly to the "good" subset furnished by the open set condition without needing π to
be globally invertible.

## 4. Product sets: the lower inequality via Lipschitz projections

The classical bound `dimH (A × B) ≥ dimH A + dimH B` should follow from slicing: fix `b ∈ B`,
note the inclusion `A ↪ A × B`, `a ↦ (a,b)` is an isometric (hence antilipschitz) embedding, and
combine with a fibered covering argument. The key insight is that
`AntilipschitzOnWith.le_dimH_image` gives `dimH A ≤ dimH (A × {b})` for free on each slice, so
the remaining work is purely the additive covering estimate connecting slice dimensions to the
product dimension. Why now? The set-local antilipschitz lower bound removes the need for a global
inverse of the slice inclusion, which is the technical obstruction in the standard proof.

## 5. Bi-Lipschitz embedding dimension lower bound `bldim(X) ≥ ⌈dimH X⌉`

Define `bldim(X)` as the least `n` such that `X` bi-Lipschitz embeds into `ℝⁿ`. Because a
bi-Lipschitz embedding restricted to `X` is simultaneously Lipschitz and antilipschitz on its
domain, our `dimH_image_eq_of_lipschitzOn_antilipschitzOn` shows such an embedding preserves
`dimH` exactly, and since `dimH (ℝⁿ) = n` this forces `dimH X ≤ n`, i.e. `bldim(X) ≥ ⌈dimH X⌉`.
The key insight is that the lower bound needs only set-local bi-Lipschitz invariance — no global
inverse on all of `ℝⁿ` — which is exactly what we proved. Why now? The invariance theorem gives
the lower bound immediately; the matching upper bound (Assouad-type embedding for doubling spaces)
becomes the sole remaining target.
