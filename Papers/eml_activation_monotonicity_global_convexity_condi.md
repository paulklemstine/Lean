# Computational evidence

Exploratory floating-point computations carried out before formalization.
**These are not verified results**; the verified statements are the theorems in
`Applications/EML/ActivationMonotonicityTropicalBridge.lean`, which are proved
in Lean 4 with no `sorry` and only the standard axioms.

Notation: `E(a,b,x) = a·x + log(1 + e^{bx})`, `lse(b,x,y) = (1/b)·log(e^{bx} + e^{by})`.

## 1. Softplus vs. tropical max

Values of `E(0,b,x)/b − max(x,0)` (the deformation defect):

| b \ x | −2 | −1 | −0.5 | 0 | 0.5 | 1 | 2 | log 2 / b |
|---|---|---|---|---|---|---|---|---|
| 1  | 0.12693 | 0.31326 | 0.47408 | 0.69315 | 0.47408 | 0.31326 | 0.12693 | 0.69315 |
| 4  | 0.00008 | 0.00454 | 0.03173 | 0.17329 | 0.03173 | 0.00454 | 0.00008 | 0.17329 |
| 16 | 0.00000 | 0.00000 | 0.00002 | 0.04332 | 0.00002 | 0.00000 | 0.00000 | 0.04332 |

The defect is positive, maximal at `x = 0` where it equals exactly `log 2 / b`,
and tends to `0` uniformly at rate `1/b`. This matched the conjectured sharp
bound `max x y < lse(b,x,y) ≤ max x y + log 2 / b`, later proved as
`lse_gt_max` and `lse_le_max_add_log_two`.

## 2. Counterexample hunt for the sharp bound

50 000 random triples `(b, x, y)` with `b ∈ (0.01, 50)`, `x, y ∈ (−20, 20)`:

* violations of `max x y ≤ lse(b,x,y) ≤ max x y + log 2 / b`: **0**;
* worst observed ratio `(lse − max)·b / log 2`: **0.99985** (approached only when
  `x = y`, consistent with the exact identity `lse(b,x,x) = x + log 2 / b`,
  formalized as `lse_self`), confirming the constant `log 2` is sharp.

## 3. Monotonicity threshold in `a`

Scanning `x ∈ [−40, 40]` with step `0.05`, `b = 1`:

| a | −0.5 | −0.2 | −0.05 | 0 | 0.01 | 0.5 | 2 |
|---|---|---|---|---|---|---|---|
| decrease detected | yes | yes | yes | no | no | no | no |

So the monotonicity threshold appears to be exactly `a = 0`; note the failure for
small `a < 0` only shows up far to the left (`x ≈ −log(−b/a)/b`), matching the
proof of `emlAct_not_monotone`, which extracts the contradiction from the limit
`x → −∞`. This is the content of `emlAct_strictMono_iff`.

## 4. Second derivative

Central finite differences of `E(0.3,b,·)` on a grid `x ∈ [−5,5]`, `b ∈ {0.2,1,3}`
give `E'' / b² > 0` throughout (minimum observed `2.4·10⁻⁷`, attained at the edge
of the grid where `σ(bx)(1−σ(bx))` is exponentially small). Consistent with the
proved identity `E''(x) = b²σ(bx)(1−σ(bx))` (`emlAct_deriv2`,
`emlAct_deriv2_pos`).

## 5. Semiring identities

2 000 random `(b,x,y,z)`: maximal absolute error in
`lse(b, lse(b,x,y), z) = lse(b, x, lse(b,y,z))` and in
`lse(b, x+z, y+z) = lse(b,x,y) + z` was `1.8·10⁻¹⁵`, i.e. round-off only. These
identities are exact and are proved as `lse_assoc` and `lse_add_right`.

## 6. OEIS

No integer sequence arises in this problem, so no OEIS search was applicable.
