# Summary of changes for run a4c9b560-7bf3-4897-acb4-a420bd7955e5
Added two new, self-contained, axiom-clean Lean files extending the existing tent-map depth-separation work in `Catalog/MachineLearning/ReLUDepthWidth/Basic.lean`, plus a research roadmap.

## New files (under `Catalog/MachineLearning/ReLUDepthWidth/`)

**`Oscillation.lean`** — sharpens the "single steep ramp" into a Telgarsky-style oscillation count:
- `tent_iterate_dyadic`: the depth-`k` tent network realizes pure alternation on the dyadic grid, `tent^[k](j/2^k) = j mod 2` (0 at even nodes, 1 at odd nodes), proved by induction via the two affine branches of the tent.
- `tent_iterate_even_node` / `tent_iterate_odd_node`: the even/odd dyadic nodes are exactly the zeros/ones.
- `tent_forces_crossings`: any continuous `ε<1/2` approximant is forced (by the intermediate value theorem) to attain the level `1/2` inside every one of the `2^k` dyadic subintervals — a weight-magnitude-independent crossing lower bound.

**`AbstractObstruction.lean`** — isolates the single inequality behind several depth-separation results and bridges two catalog domains:
- `twoPoint_gap_le`: the unifying obstruction `|f a − f b| ≤ K·|a−b| + 2ε` for any `K`-Lipschitz `ε`-approximant `g`, with contrapositive `no_lipschitz_approx_of_gap`.
- `tent_depth_separation_via_gap`: re-derives the tent (slope-blowup) separation as an instance.
- `iterExp_endpoint_gap_pos` and `iterExp_depth_separation`: derive the iterated-exponential-tower (range-blowup) separation from the *same* abstract lemma — the cross-domain bridge between the tent map and the EML exponential tower.
- `tent_adversarial`: a robustness reading — any sub-`2^k`-Lipschitz classifier under-separates a `2^{-k}`-adversarial input pair whose true tent labels differ maximally.

Both files include `-- !--` proof-sketch blocks for each theorem and `-- !-- Lab Notebook -- !--` sections (Hypothesis / Result / Insight / Failure analysis). To work around the project's nested-package layout, the files re-state the small tent/`iterExp` foundation locally (with the proven proofs) and depend only on `import Mathlib`.

## Verification
- Both modules build successfully (`MachineLearning.ReLUDepthWidth.Oscillation` and `...AbstractObstruction`).
- No `sorry`/`admit` remain on any result.
- All main theorems depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`.

## Research roadmap
`FUTURE_DIRECTIONS.md` (in the same directory) lays out 5 falsifiable directions — exact width lower bound from the crossing count, matching shallow `Θ(K/ε)` interpolation upper bound, tensorized higher-dimensional separation, a measure-theoretic robustness certificate, and a witness-driven abstraction of separation — each with a "key insight" and "why now" justification.