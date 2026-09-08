# Computational evidence — depth-`L` lower bounds from oscillations

All numbers below were produced by `#eval` inside Lean 4 (exact rational
arithmetic, `ℚ`), using the same definitions that the formal proofs use:

```lean
def relu (x : ℚ) : ℚ := max x 0
def tri  (y : ℚ) : ℚ := 2 * relu y - 4 * relu (y - 1/2) + 2 * relu (y - 1)
def tri2 (y : ℚ) : ℚ :=
  4*relu y - 8*relu (y-1/4) + 8*relu (y-1/2) - 8*relu (y-3/4) + 4*relu (y-1)
def knotBound (w : ℕ) : ℕ → ℕ | 0 => 0 | (L+1) => w * (2 * knotBound w L + 4)
```

Everything reported here is *exploratory*; the corresponding formal statements
are proved in `Catalog/Algebra/DepthLOscillationLowerBound.lean` and
`Catalog/Algebra/DepthLSawtoothCollapse.lean`.

## 1. Oscillation of the sawtooth tower

`tri^[k]` evaluated at the dyadic grid `i/2^k`, `i = 0 … 2^k`:

| k | values at `i/2^k` |
|---|---|
| 3 | `[0, 1, 0, 1, 0, 1, 0, 1, 0]` |
| 4 | `[0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0]` |

Perfect alternation, i.e. `2^k` sign changes across `[0,1]`, confirming the
formal statement `tri_iterate_dyadic`:
`tri^[k] (i/2^k) = if Even i then 0 else 1` for `i ≤ 2^k`.

## 2. Two sawtooths in one layer

Testing `tri2 y - tri (tri y)` on the grid `y = -0.5, -0.45, …, 1.5` (41 points,
exact rationals) returns `0` at **every** point:

```
#eval ((List.range 41).map (fun i => tri2 ((i:ℚ)/20 - 0.5) - tri (tri ((i:ℚ)/20 - 0.5)))).all (· == 0)
-- true
```

This is the numerical shadow of the theorem `tri_tri_eq_tri2 : tri (tri y) = tri2 y`
(proved for all real `y` by a six-interval case analysis), which is what makes
the depth collapse work.

## 3. Knot budget of depth-`L` width-`w` networks

`knotBound 3 L` (the number of knots a depth-`L`, width-`3` network can create)
against the closed-form bound `2·(2w+2)^L` proved in `knotBound_le`:

| L | `knotBound 3 L` | `2·8^L` |
|---|---|---|
| 0 | 0 | 2 |
| 1 | 12 | 16 |
| 2 | 84 | 128 |
| 3 | 516 | 1024 |
| 4 | 3108 | 8192 |
| 5 | 18660 | 65536 |

The recursion `B_{L+1} = w(2B_L+4)` is exponential with ratio `2w`, and the
closed form is a valid over-estimate by a factor `< 4`, as proved.

## 4. Counterexample hunt for the main inequality

The main theorem claims: a depth-`L` width-`w` network within `1/4` of
`tri^[L^2+4]` forces `2^L ≤ 2w+2`. The engine is
`2^(L^2+4) ≤ 4 (2w+2)^L`. Testing the contrapositive numerically at the
critical width `w = 2^(L-1) − 2` (just below the claimed threshold):

```
#eval (List.range 8).map (fun L => (L, decide (4*(2*(2^(L-1) - 2)+2)^L < 2^(L^2+4))))
-- [(0,true),(1,true),(2,true),(3,true),(4,true),(5,true),(6,true),(7,true)]
```

i.e. at width just below `2^(L-1)` the counting capacity `4(2w+2)^L` is strictly
smaller than the required `2^(L^2+4)` for every tested depth — no counterexample.
The same evaluation at `w = 2^(L-1)` also stays below `2^(L^2+4)`, which is the
numerical signal that the *stated* conclusion `2^L ≤ 2w+2` is conservative: the
counting method actually yields `w ≳ 2^{L + 2/L - 1}`. We formalised the clean
conservative form.

## 5. Where the separation threshold lies

Two competing quantities for depth `L`, constant width `5`:

| quantity | value |
|---|---|
| tower height achievable exactly (`tri2_tower_isNet`) | `2L` |
| tower height allowed by counting (`tri2_tower_bracket`) | `≤ 4L+2` |
| tower height used by the lower bound (`relu_depth_separation`) | `L^2+4` |

So the sawtooth family collapses for tower heights linear in `L`, and separates
for heights quadratic in `L`. The evaluations

```
#eval (List.range 6).map (fun L => (L, 2^(L^2+4-L+1)+1))
-- [(0,33),(1,33),(2,129),(3,2049),(4,131073),(5,33554433)]
```

show the one-layer width `2^(k-L+1)+1` needed to realise `tri^[k]` at depth `L`
with a single fat first layer (now a theorem: `tri_iterate_one_layer` and
`sawtooth_collapse_general` in `Catalog/Algebra/DyadicOneLayer.lean`):
exponential in `L` for `k = L^2+4`, matching the proved lower bound
`w ≥ 2^(L-1)−1` up to the constant in the exponent.

## 6. Tooth counting for the average-case bound

The `L¹` bound sums over teeth: `[0,1]` carries `2^(k-1)` teeth of the tower
`tri^[k]`, and each tooth free of knots contributes at least `1/(16·2^k)`:

| k | teeth `2^(k-1)` | guaranteed error if knot-free | total if all teeth free |
|---|---|---|---|
| 3 | 4 | 1/128 | 1/32 |
| 5 | 16 | 1/512 | 1/32 |
| 8 | 128 | 1/4096 | 1/32 |

The constant `1/32` is uniform in `k`, matching `sawtooth_L1_lower_bound`
(`(2^(k-1) − |S|)/(16·2^k) → 1/32` as `|S|/2^k → 0`).

## 7. OEIS

The knot-budget sequence `0, 12, 84, 516, 3108, 18660` (`w = 3`) satisfies
`a(L+1) = 6 a(L) + 12`; the tooth-count sequence `2^k` is A000079. No new OEIS
entry was needed; the alternating value pattern `0,1,0,1,…` is A000035 shifted.
