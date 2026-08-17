# Computational Evidence — Hyper-Awareness: 11-dimensional perception layers

All computations below were performed **inside Lean 4** in exact rational arithmetic (`ℚ`),
in `Catalog/MachineLearning/HyperAwareness11D/LabNotes.lean`, which compiles as part of the
project. No floating point and no external scripts were used. The `#eval` outputs quoted
here are reproduced verbatim from the build log.

## 1. Is 21 units enough? (counterexample hunt)

The most natural "almost optimal" lossless architecture on `ℝ¹¹` keeps all 11 positive
detectors `x ↦ x_j⁺` but drops one negative detector, giving 21 units — one below the width
that the main theorem claims to be necessary. Testing it on the percepts

```
xA = (0,…,0,−1)      xB = (0,…,0,−2)
```

gives identical 21-dimensional outputs (both are the zero vector) while `xA ≠ xB`:

```
#eval (List.ofFn (layer21 xA) == List.ofFn (layer21 xB), List.ofFn xA == List.ofFn xB)
-- (true, false)
```

This is not merely evaluated: it is **proved** in Lean as
`HyperAwareness11D.LabNotes.collision_21`. The counterexample hunt therefore found no
counterexample to the theorem `two_mul_le_card_of_injective` (2n = 22 units are necessary);
instead it produced an explicit witness of failure at 21 units.

## 2. Frame ratios of the optimal 22-unit split layer

For the optimal layer `Φ x = (x⁺, x⁻)` we computed the squared expansion ratio
`ratio x y = ‖Φx − Φy‖² / ‖x − y‖²` on five percept pairs (`e₀` vs `−e₀`, `e₀` vs `0`, two
"generic" vectors `v₁, v₂` against each other, `v₁` vs `−v₁`, `v₂` vs `0`):

```
#eval (ratio e0 (−e0), ratio e0 0, ratio v1 v2, ratio v1 (−v1), ratio v2 0)
-- (1/2, 1, 61/102, 1/2, 1)
```

| pair                | ratio    | decimal |
|---------------------|----------|---------|
| `e₀` vs `−e₀`       | `1/2`    | 0.5000  |
| `e₀` vs `0`         | `1`      | 1.0000  |
| `v₁` vs `v₂`        | `61/102` | 0.5980  |
| `v₁` vs `−v₁`       | `1/2`    | 0.5000  |
| `v₂` vs `0`         | `1`      | 1.0000  |

Every value lies in `[1/2, 1]`, and both endpoints occur. This is exactly the sandwich later
proved as `double_frame`, together with the sharpness statements
`double_frame_lower_sharp` (antipodal pairs are the worst case, ratio `1/2`) and
`double_frame_upper_sharp` (ratio `1`). No pair was found below `1/2`, which is consistent
with — and was the motivation for — the frame lower bound.

## 3. Activation balance at antipodal probes

For the split layer we counted the active units at `x` and at `−x`:

```
#eval (activeCounts v1, activeCounts v2, activeCounts (fun j => j + 1))
-- ((10, 10), (10, 10), 11, 11)
```

i.e. the pairs `(10,10)`, `(10,10)`, `(11,11)`.

The vectors `v₁` and `v₂` each have a vanishing coordinate, and there one unit is inactive on
*both* sides, so the counts drop to `10 + 10 = 20 < 22`. The third percept `(1,2,…,11)` has
all coordinates nonzero and gives the perfectly balanced `11 + 11 = 22` split.

This experiment is what forced the *transversality* hypothesis in the theorems: the
statement `balanced_activation_at_optimum` is proved with probe percepts chosen far out along
a direction transverse to every weight row, and the data above shows this hypothesis cannot
be dropped.

## 4. Sequences

The counting sequence produced by the main theorem is `a(n) = 2n` (minimum lossless ReLU
width in dimension `n`: `2, 4, 6, …`, with `a(11) = 22`), and for order-`k` tensor percepts
`2·11^k = 22, 242, 2662, 29282, …`. These are elementary sequences (`2n` and `2·11^k`); no
OEIS lookup was performed and none is claimed.

## 5. What the evidence did *not* settle

The experiments cannot distinguish "no injective layer of width 21 exists" from "the
particular width-21 layers we tried fail". That gap is what the Lean proof of
`two_mul_le_card_of_injective` closes, by a genericity + local-rank + half-space duality
argument valid for *all* weight matrices and biases.
