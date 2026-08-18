# Computational Evidence — Quantized Transformer Weight Lattices

All numbers below were produced with exact rational arithmetic (`ℚ`) inside Lean 4
(`#eval`), using a rational mirror of the formal quantizer

```lean
def gr (d x : ℚ) : ℚ := d * (round (x / d) : ℤ)                       -- ≡ gridRound
def defect (f : ℚ → ℚ) (d x y : ℚ) : ℚ :=
  f (gr d ((x+y)/2)) - (f (gr d x) + f (gr d y))/2                     -- midpoint convexity defect
```

`defect` is exactly the quantity that `ApproxConvexOn ε` bounds by `ε` for the
midpoint `a = b = 1/2`.  The theory (Theorem A, `quantized_approxConvex`) predicts
`defect ≤ 2·L·r = L·δ` for an `L`-Lipschitz convex loss on the mesh-`δ` grid.

## 1. Maximal midpoint defect, exhaustive scan

Domain `[-2, 2]` scanned at step `1/40` (161 points, 25 921 pairs), exact arithmetic.

| loss `f`            | Lipschitz const. on `[-2,2]` | mesh `δ` | measured max defect | theory bound `L·δ` |
|---------------------|------------------------------|----------|---------------------|--------------------|
| `\|x\|`             | 1                            | 1        | **1/2**             | 1                  |
| `\|x\|`             | 1                            | 1/2      | **1/4**             | 1/2                |
| `\|x\|`             | 1                            | 1/4      | **1/8**             | 1/4                |
| `x²`                | 4                            | 1        | **3/2**             | 4                  |
| `x²`                | 4                            | 1/2      | **7/8**             | 2                  |
| `x²`                | 4                            | 1/4      | **15/32**           | 1                  |
| `\|x-1/3\|+\|x+1/3\|` | 2                          | 1/3      | **1/3**             | 2/3                |

**Observations.**

1. No counterexample to Theorem A was found: every measured defect is `≤ L·δ`.
2. For `f = |x|` the defect is *exactly* `δ/2`, i.e. exactly half the proven bound.
   This is the numerical signature that became Theorem S1
   (`quantized_abs_defect_ge`: the defect is `≥ δ/2`) and Theorem S3
   (`defect_bound_sharp`: the bound `2Lr` is sharp within a factor 2).
3. The defect decays linearly in the mesh (`1/2 → 1/4 → 1/8`), matching the
   tower statement `gridTower_defect_tendsto_zero` and the bit-width scaling law
   `bitwidth_defect_halves` (one extra bit halves the defect).
4. For `x²` the ratio measured/bound is `≈ 0.37, 0.44, 0.47`, drifting towards
   `1/2`: the factor-2 gap appears to be the true asymptotic constant, not an
   artefact of the piecewise-linear example.

## 2. Witness for the sharpness theorem

```
#eval (gr 1 (2/5), gr 1 (3/5), gr 1 (1/2))    -- (0, 1, 1)
```

`2/5` rounds down to `0`, `3/5` rounds up to `1`, but the midpoint `1/2` rounds
*up* to `1`; hence for `f = |·|`

```
f(Q(mid)) = 1 > 1/2 = (f(Q(2/5)) + f(Q(3/5)))/2 ,
```

a bump of height `1/2 = δ/2`.  These are precisely the witnesses used in the Lean
proof of `quantized_abs_defect_ge`.

## 3. Codebook counts (arithmetic layer)

```
#eval (codes 8).length                                    -- 8
#eval ((codes 12).map (gr (1/4))).eraseDups.length        -- 5
```

* the `m`-level codebook in one period has exactly `m` symbols — the finite check
  matching `nat_card_torsion` (`Nat.card {x : AddCircle δ | m • x = 0} = m`);
* collapsing the 12-grid onto the 4-grid leaves 5 distinct values on `[0,1]`
  (`0, 1/4, 1/2, 3/4, 1`), i.e. `4` classes plus the endpoint — the finite shadow
  of the tower inclusion `torsion_mono_of_dvd` for `4 ∣ 12` and of the index
  formula `torsion_card_ratio` (`12/4 = 3`).

## 4. Counterexample hunt

The universal claims that were *tested and survived*:

* `defect ≤ L·δ` — 25 921 pairs per row of the table above, three losses, three
  meshes: no violation.
* `gridRound` idempotence `gr d (gr d x) = gr d x` — verified on the whole scan.
* `|gr d x − x| ≤ d/2` — verified on the whole scan.

The universal claim that was *refuted* numerically before being refuted formally:

* "the quantized landscape of a convex loss is convex" — false already for
  `f = |x|`, `δ = 1` (defect `1/2 > 0`), now a theorem: `quantized_abs_not_convex`.

No OEIS sequence is involved: the numerical content is a family of exact rational
bounds rather than an integer sequence.  (The codebook sizes `m^{|ι|}` are the
trivial sequence of prime-power-free growth and were not searched.)

---

# Cycle 2 — the unbalanced regime (evidence for `QuantizedWeightLatticesSharpConstant.lean`)

The scans of §1 above measure only the **midpoint** defect (`a = b = 1/2`).  That
restriction is exactly why every measurement came out at `L·δ/2` rather than at
the proven bound `L·δ`.  Cycle 2 re-ran the scan over *all* convex weights
`a ∈ {0, 1/n, …, 1}`, again in exact rational arithmetic inside Lean:

```lean
def gr (d x : ℚ) : ℚ := d * (round (x / d) : ℤ)
def gdefect (f : ℚ → ℚ) (d a x y : ℚ) : ℚ :=
  f (gr d (a * x + (1 - a) * y)) - (a * f (gr d x) + (1 - a) * f (gr d y))
def Astat (d a x y : ℚ) : ℚ := a * gr d x + (1 - a) * gr d y - gr d (a * x + (1 - a) * y)
```

Grid: `x, y ∈ [-2, 2]` and `a ∈ [0,1]`, all at step `1/12`; mesh `δ = 1`.

| quantity | balanced (`a = 1/2`) | all weights `a` |
|---|---|---|
| max `\|Astat\|` (rounding discrepancy) | **1/2** | **11/12** |
| max defect of `f = \|z − 1\|` (`L = 1`) | 1/2 | **11/12** |

The explicit witness family (`a = 1 − 1/n`, `x = δ/2`, `y = −δ/2`, loss
`f z = |z − δ|`) evaluates to

| `n` | 3 | 5 | 10 | 100 | 1000 |
|---|---|---|---|---|---|
| defect | 2/3 | 4/5 | 9/10 | 99/100 | 999/1000 |

i.e. the defect tends to `δ = 2·L·r` and the step-`1/12` scan attains the largest
value `1 − 1/12` compatible with that grid.  Both observations are now theorems:

* balanced case — `two_round_midpoint_sub_le` (`|round X + round Y − 2·round((X+Y)/2)| ≤ 1`),
  `gridRound_midpoint_dist`, `quantizeTensor_midpoint_defect` (defect `≤ L·r`),
  and sharpness `midpoint_constant_sharp`;
* unbalanced case — `targetLoss_defect_ge` (defect `≥ (1 − 1/n)·δ` for all `n ≥ 3`)
  and `gridRound_defect_ge` (defect `≥ δ`), giving `grid_defect_constant_exact`.

**Counterexample hunt, cycle 2.**  The universal claim tested and *refuted*:
"for nearest-point grid quantization the convexity defect is at most `L·r`"
(Conjecture 1 of the cycle-1 `FUTURE_DIRECTIONS.md`).  It fails for every mesh,
by the witness family above — now the theorem `grid_defect_Lr_refuted`.

## Cycle 2b — the denominator law

Same exact-rational setting (`δ = 1`, `L = 1`), scanning `x, y` over a wide window
(`[-8, 8]`, step `1/48`) for a *fixed* interpolation weight `a`, and recording the
maximal rounding discrepancy `|Astat|` (which equals the maximal defect over
convex `1`-Lipschitz losses, by `convex_defect_le_discrepancy`):

| `a` | 1/2 | 1/3 | 1/4 | 2/5 | 5/12 | 1/12 |
|---|---|---|---|---|---|---|
| max `\|Astat\|` | 1/2 | 2/3 | 3/4 | 4/5 | 11/12 | 11/12 |
| `1 − 1/q` (`q` = denominator) | 1/2 | 2/3 | 3/4 | 4/5 | 11/12 | 11/12 |

The measured maximum equals `1 − 1/q` in every case, `q` being the denominator of
`a` in lowest terms — an arithmetic (not metric) dependence.  The upper bound
`defect ≤ (1 − 1/q)·L·δ` is now the theorem `gridRound_defect_denominator`, and
equality at `a = (q−1)/q` is `targetLoss_defect_eq`.  Attainment for the other
residues `k` remains Conjecture 1 of `FUTURE_DIRECTIONS.md`.

A caveat learned the hard way: a scan restricted to a small window in `x, y`
*under*-reports the discrepancy (a window of `[-1,1]` returns `max(a, 1−a)`
instead of `1 − 1/q`), because `Astat` is not invariant under integer shifts of
`x` and `y` unless `a` is an integer.

## Cycle 3 — the full defect spectrum at a coprime mixing weight

Cycle 2 left open whether the bound `(1 − 1/q)·L·δ` is *attained* at every
numerator `k` coprime to `q` (and, more finely, which intermediate defects occur).
The following exact-rational experiment, run inside Lean with `#eval` at mesh
`δ = 1` and `L = 1`, instantiates the witness family that cycle 3 then proved
correct in general: for a residue `j` pick `d` with `k·d ≡ j (mod q)`, set
`s = (k·d − j)/q`, `C = max(d, s, 0)`, and take

```lean
def gr (x : ℚ) : ℚ := (round x : ℤ)          -- δ = 1 grid rounding
def tl (c x : ℚ) : ℚ := |x - c|              -- "distance to target weight" loss
-- weights x = d − 1/2, y = −1/2, target c = C, mixing weight a = k/q
--   defect = tl c (gr (a*x + (1-a)*y)) − (a * tl c (gr x) + (1-a) * tl c (gr y))
```

Measured defects (all exact rationals, `q` fixed, `j = 0, 1, …, q−1`):

| `k/q` | measured defect sequence |
|---|---|
| `2/5`  | `0, 1/5, 2/5, 3/5, 4/5` |
| `3/7`  | `0, 1/7, 2/7, 3/7, 4/7, 5/7, 6/7` |
| `4/9`  | `0, 1/9, 2/9, 1/3, 4/9, 5/9, 2/3, 7/9, 8/9` |
| `5/12` | `0, 1/12, 1/6, 1/4, 1/3, 5/12, 1/2, 7/12, 2/3, 3/4, 5/6, 11/12` |

In every case the measured set is exactly `{j/q : 0 ≤ j < q}` and its maximum is
`1 − 1/q`, independently of the numerator `k` — including numerators far from
`q − 1` (e.g. `k = 2, q = 5` and `k = 4, q = 9`).  This is now the theorem
`defect_spectrum`, with the maximality statement
`denominator_constant_exact : IsGreatest (defectSet δ k q) (δ * (1 − 1/q))` and the
non-reduced version `denominator_constant_reduced` (sharp constant
`(1 − gcd(k,q)/q)·δ`).

**Counterexample hunt, cycle 3.**  The universal claim tested was
"some residue `k` coprime to `q` fails to attain `(1 − 1/q)·δ`".  No instance was
found for any `q ≤ 12`, and the Bézout covering argument shows why none can exist:
the reachable discrepancy numerators are exactly the subgroup of `ℤ/qℤ` generated
by `k`.  For non-coprime `k` the scan does show a strictly smaller maximum — e.g.
`k = 2, q = 6` gives `1/3, 2/3` only, maximum `2/3 = 1 − gcd(2,6)/6` — matching
`denominator_constant_reduced` exactly.
