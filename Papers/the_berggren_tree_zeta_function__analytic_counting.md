# Computational Evidence — The Berggren Tree Zeta Function

All numbers below were produced with `#eval` **on the project's own Lean definitions**
(`BerggrenZeta.node`, `chyp`, `layer`, `N`, `spineHyp`), so they are computed from exactly the
objects the theorems talk about. They are numerical exploration, not proofs; every claim that is
asserted as a theorem is proved separately and `sorry`-free in `Catalog/Computation/`.

## 1. The tree itself

Root seed `(m,n) = (2,1)` ↔ triple `(3,4,5)`. Moves in Euclid coordinates:
`s₀(m,n) = (2m−n, m)`, `s₁(m,n) = (2m+n, m)`, `s₂(m,n) = (m+2n, n)`
(these are the three Barning matrices; see `berggren_step_eq_barning`).

Hypotenuses by layer (`chyp` over all `3^k` words):

| depth k | 3^k | hypotenuses |
|---|---|---|
| 0 | 1 | 5 |
| 1 | 3 | 13, 29, 17 |
| 2 | 9 | 25, 73, 53, 89, 169, 85, 65, 97, 37 |
| 3 | 27 | 41, 137, 109, 233, 425, 205, 193, 305, 125, 185, 505, 349, 505, 985, 509, 337, 481, 173, 149, 373, 241, 277, 565, 305, 157, 205, 65 |

Note the repetitions `505`, `305`, `205` (each twice) *within* layer 3: hypotenuses repeat even though
the **nodes** (seeds) never do (`node_injective`, `card_layer = 3^k`).

## 2. Extremes inside a layer: the source of the refutation

| depth k | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|---|
| max `c` | 5 | 29 | 169 | 985 | 5741 | 33461 | 195025 | 1136689 | 6625109 |
| min `c` | 5 | 13 | 25 | 41 | 61 | 85 | 113 | 145 | 181 |

* The **maxima** are the odd-indexed Pell numbers `5, 29, 169, 985, 5741, …` (OEIS A001653,
  "numbers `k` with `2k²−2k+1` a square"; also the `s₁`-spine). Successive ratios
  `29/5 = 5.8, 169/29 = 5.828, 985/169 = 5.828…` converge to `λ = 3+2√2 = 5.8284…`, the Barning
  eigenvalue, i.e. the silver ratio squared. Proved: `spine_hyp_rec` (`c_{k+2} = 6c_{k+1} − c_k`),
  `spine_hyp_closed`, `spine_hyp_bounds`, `spine_hyp_log_growth`.
* The **minima** are `2k² + 6k + 5 = (k+2)² + (k+1)²`, i.e. **quadratic** in the depth (the
  `s₂`-spine `(k+2, k+1)`). Fitted and confirmed for `k ≤ 8`.

So inside one layer the hypotenuse ranges from `Θ(k²)` to `Θ(λ^k)`. This spread — not any
failure of the growth theorem — is what destroys the silver-ratio prediction for the abscissa.

## 3. Layer sums of the Dirichlet series `Σ_{|w|=k} c(w)^{-s}`

| k | s = 0.8 | s = 1.0 | s = 1.2 |
|---|---|---|---|
| 0 | 0.2759 | 0.2000 | 0.1450 |
| 1 | 0.2998 | 0.1702 | 0.0970 |
| 2 | 0.3397 | 0.1542 | 0.0708 |
| 3 | 0.3915 | 0.1437 | 0.0541 |
| 4 | 0.4549 | 0.1361 | 0.0425 |
| 5 | 0.5311 | 0.1303 | 0.0340 |
| 6 | 0.6217 | 0.1256 | 0.0277 |
| 7 | 0.7290 | 0.1217 | 0.0229 |
| 8 | 0.8559 | 0.1184 | 0.0191 |

* `s = 0.8`: layer sums **grow** — the series diverges, even though `0.8 > log 3/log λ = 0.6232`,
  where the *layer-majorant* `3^k (max c)^{-s}` already converges. This is the numerical face of
  `majorant_converges_zeta_diverges` and `zetaAbscissa_gt_silver_prediction`.
* `s = 1.0`: layer sums decay far too slowly (≈ `k^{-0.25}`) — divergence
  (`not_summable_zterm_one`, and independently `not_summable_zterm_one_of_counting`).
* `s = 1.2`: geometric-looking decay with ratio ≈ 0.83 — convergence (`summable_zterm`).

## 4. The counting function `N(H)`

`N(H) = #{nodes with hypotenuse ≤ H}` computed exactly from `BerggrenZeta.N`:

| H | 10 | 50 | 100 | 200 | 400 | 800 | 1600 | 3200 | 6400 | 12800 |
|---|---|---|---|---|---|---|---|---|---|---|
| N(H) | 1 | 7 | 16 | 32 | 63 | 128 | 254 | 507 | 1017 | 2034 |
| N(H)/H | .100 | .140 | .160 | .160 | .158 | .160 | .159 | .158 | .159 | .159 |

The ratio is flat: `N(H) = Θ(H)`, exactly as proved (`N_theta`: `H/50 ≤ N(H) ≤ 2H` for
`H ≥ 512`). The empirical constant `≈ 0.1590` is strikingly close to `1/(2π) = 0.15915…`, which
is the classical density of primitive Pythagorean hypotenuse-counts; sharpening the proved
constants to this exact value is Conjecture 1 of `FUTURE_DIRECTIONS.md`.

`N(H)/H^{log 3/log λ} = N(H)/H^{0.6232}` is *not* bounded (it grows like `H^{0.377}`), a direct
numerical refutation of the silver-ratio counting exponent.

## 5. Counterexample hunt

* Enumerated all nodes of depth `≤ 8`: `1+3+⋯+3^8 = 9841` words, and `9841` **distinct** seeds
  after de-duplication — no collision (consistent with `node_injective`).
* Ran the greedy descent `back` (choose `unstep i` according to the class `m<2n`, `2n<m<3n`,
  `3n<m`) on all `8156` seeds with `m ≤ 200`: every one reaches the root `(2,1)`; zero failures
  (consistent with `seed_complete`).
* Tested `c(w) ≤ 2·λ^{|w|+1}` on all `9841` nodes of depth `≤ 8` (with `λ` replaced by the
  under-approximation `5.8284`): no violation (consistent with `chyp_le_silver`).
* The one hypothesis that **did** fall to computation is the headline one: no exponent
  `σ < 1` bounds `N(H)`, and the layer sums at `s = 0.8` grow. The silver-ratio abscissa
  prediction is false, and this is now a theorem.
