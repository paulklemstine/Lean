# Summary of changes for run 4a8c8196-7e61-4c2a-a055-aee0c5130a64
## Tropical Height Monotonicity on Berggren Words — Phase A complete

I added one new Lean file, `Catalog/Bridges/TropicalHeightBerggren.lean`, plus `FUTURE_DIRECTIONS.md`, building directly on the existing catalog (it `import`s `Cryptography.BerggrenLatticeReduction` and reuses `actGen`, `evalWord`, `evalAtRoot`, `rootTriple`, `GoodTriple`, `tripleHeight`, `evalAtRoot_good`, `height_lower_bound_root`, `height_mono_prepend`; it also references the height philosophy of `Bridges/ArithmeticVCDimension.lean`'s `ratArithHeight` and the O(2,1) matrix view in `Algebra/BerggrenLorentz/Core.lean`).

### Build fix (required)
The project could not build because the lakefile globs (`Bridges.+`, etc.) did not point at the actual source root `Catalog/`. I added `srcDir = "Catalog"` to `lakefile.toml`, a minimal, correct fix; the whole catalog and the new file now compile.

### New invariant
`maxCoord t = max |a| (max |b| |c|)` (a max-plus coordinate norm) and `tropHeight t = log₂ (maxCoord t)` (its tropical/logarithmic height). Tropicalizing turns the multiplicative matrix growth of the Berggren action into additive cost.

### Proved theorems (13, all sorry-free; verified to depend only on `propext`, `Classical.choice`, `Quot.sound`)
- `maxCoord_good`, `tropHeight_good`: for good triples the invariant equals/`log₂` of the hypotenuse.
- `maxCoord_actGen_le_seven`: each generator scales the norm by ≤ 7.
- `tropHeight_actGen_le`: **generator tropical Lipschitz** `tropHeight (actGen g t) ≤ tropHeight t + 3`.
- `tropHeight_evalWord_le`, `tropHeight_evalAtRoot_le`: **depth bound** — a node at depth `n` has tropical height ≤ `2 + 3n`.
- `tropHeight_concat_le`: **concatenation control** `tropHeight (evalWord (u++v) t) ≤ tropHeight (evalWord v t) + 3|u|`.
- `tropHeight_mono`, `tropHeight_evalAtRoot_lower`, `tropHeight_mono_prepend`: monotonicity, a ≥ 2 lower bound, and prepend-monotonicity (soundness of tropical pruning).
- `finite_bounded_tropHeight`: **algorithmic certificate** — only finitely many words have tropical height ≤ `H`, so bounded-tropical-height search terminates.
- plus the helper `log2_seven_mul_le` and `tropHeight_root`.

### Conjectures (2, clearly marked with `sorry`, as the protocol permits)
- `hyp_submultiplicative` (`c_{u++v} ≤ c_u·c_v`) and `tropHeight_subadditive`. I verified the first computationally (0 violations among all 65536 word pairs of length ≤ 4) and isolated why it is hard: the third row of every word-matrix satisfies the Lorentz relation `p²+q²+1=r²`, but the relaxation using only that relation is false, so reachability (hyperbolic geometry of the O(2,1;ℤ) orbit) is essential. This analysis seeds Direction 1.

### Notes deliverables
Each major theorem carries a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis) and short `-- !-- comment -- !--` proof sketches. `FUTURE_DIRECTIONS.md` contains the required `## Synthesis`, `## Results Summary`, and 5 falsifiable `## Research Directions`, each with a "key insight" sentence and a "Why now" justification. No prose/article/demo files were produced, per the Phase A constraints.