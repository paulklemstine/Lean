# Computational Evidence — EML / exp–log duality with the scaling group

All numbers below were produced by executing the script at the end of this file
with the project toolchain (`lake env lean`, `Float` arithmetic).  They are
*evidence only*: every claim they support is proved without `sorry` in
`Catalog/Probability/EMLExpLogDuality.lean` and
`Catalog/Probability/EMLScalingGroupDuality.lean`.  Nothing in the formal
development depends on these computations.

## 1. The EML commutator closes on the pure-scaling line

Claim tested (`emlField_vfBracket`): for `f = emlField (a,b)`, `h = emlField (a',b')`
on `(0,∞)`, the vector-field commutator `f h' - h f'` equals
`emlField (0, a'b - ab')`, i.e. the `log` terms cancel *identically*.
Derivatives were taken by central finite differences with step `1e-6`.

| `(a,b)` | `(a',b')` | `y` | numeric `f h' - h f'` | predicted `y (a'b - ab')` |
|---|---|---|---|---|
| `(1, 2)` | `(3, -1)` | `2.5` | `17.500000` | `17.500000` |
| `(-0.7, 0.4)` | `(2, 5)` | `0.3` | `1.290000` | `1.290000` |
| `(0, 1)` | `(1, 0)` | `7.0` | `7.000000` | `7.000000` |

The affine side (`affField_vfBracket`) matches likewise: `(1,2),(3,-1)` at
`x = 2.5` gives `7.000000` on both sides, `(-0.7,0.4),(2,5)` at `x = 0.3` gives
`4.300000` on both sides.

## 2. The exp–log intertwiner

Claim tested (`expLog_intertwines_bracket`):
`vfBracket (emlField g) (emlField h) y = y * vfBracket (affField g) (affField h) (log y)`.

| `(a,b)` | `(a',b')` | `y` | EML side | `y ×` affine side at `log y` |
|---|---|---|---|---|
| `(1.3, -0.6)` | `(0.5, 2.2)` | `4.0` | `-12.640000` | `-12.640000` |

## 3. The flow really is a scaling transformation

Claim tested (`emlFlow_hasDerivAt`, `emlFlow_eq_scaling`): integrating
`y' = y (a log y + b)` from `y₀` should reproduce
`c(t) y₀^{k(t)}` with `k(t) = e^{a t}`, `c(t) = exp(b (e^{a t} - 1)/a)`
(and `c(t) = e^{b t}`, `k(t) = 1` when `a = 0`).
Explicit Euler integration with `2·10⁵` steps:

| `(a,b)` | `y₀` | `T` | Euler | closed form | rel. error |
|---|---|---|---|---|---|
| `(0.5, 1.0)` | `2.0` | `1.0` | `11.475755` | `11.475898` | `1.2e-5` |
| `(-1.2, 0.3)` | `0.5` | `2.0` | `1.178733` | `1.178732` | `8e-7` |
| `(0, 0.8)` | `3.0` | `1.5` | `9.960315` | `9.960351` | `3.6e-6` |

The residuals shrink like the Euler step size, as expected.

## 4. The exponential map hits the identity component

Claim tested (`emlExpMap_surjective`): given `c, k > 0` with `k ≠ 1`, the
generator `a = log k`, `b = log c · log k/(k-1)` has time-one flow parameters
exactly `(c, k)`.

| target `(c,k)` | computed `(exp(b∫₀¹e^{as}ds), e^a)` |
|---|---|
| `(3, 2)` | `(3.000000, 2.000000)` |
| `(0.25, 5)` | `(0.250000, 5.000000)` |

Counterexample hunt for surjectivity onto the *whole* group: `e^a > 0` always,
so no generator can produce `k < 0`.  The inversion `y ↦ 1/y` (`k = -1`) is
therefore outside the image — this is `emlExpMap_not_surjective`, and it is the
reason the group has torsion (`ScalingMap.sq_eq_one_iff`).

## 5. Non-commutativity of the scaling group

`d = (c,k) = (1,2)` (squaring) and `e = (2,1)` (doubling) at `y = 3`:
`d(e(y)) = 36`, `e(d(y)) = 18`.  Hence `d e ≠ e d`
(`scalingMap_not_commutative`), the global shadow of `⁅D, T⁆ = T`.

## 6. Action on cumulant generating functions

Claim tested (`discreteCGF_scaling`): with weights `p = (0.2, 0.5, 0.3)` and
states `y = (1.5, 2.0, 4.0)`,
`log Σ pᵢ (c yᵢ^k)^s = s log c + log Σ pᵢ yᵢ^{k s}`.

| `(c, k, s)` | left side | right side |
|---|---|---|
| `(2, 1.5, 0.7)` | `1.451250` | `1.451250` |
| `(0.4, -2, 1.3)` | `-3.021735` | `-3.021735` |

No counterexample was found in any sampled configuration; the two sides agree to
`Float` precision, and the identity is proved exactly in Lean.

## Script

```lean
import Mathlib
def emlF (a b y : Float) : Float := y * (a * Float.log y + b)
def affF (a b x : Float) : Float := a * x + b
def dnum (f : Float → Float) (y : Float) : Float := (f (y + 1e-6) - f (y - 1e-6)) / 2e-6
def vfb (f h : Float → Float) (y : Float) : Float := f y * dnum h y - h y * dnum f y
def check1 (a b a' b' y : Float) : Float × Float :=
  (vfb (emlF a b) (emlF a' b') y, emlF 0.0 (a' * b - a * b') y)
#eval check1 1.0 2.0 3.0 (-1.0) 2.5
#eval check1 (-0.7) 0.4 2.0 5.0 0.3
#eval check1 0.0 1.0 1.0 0.0 7.0
def check2 (a b a' b' x : Float) : Float × Float :=
  (vfb (affF a b) (affF a' b') x, affF 0.0 (a' * b - a * b') x)
#eval check2 1.0 2.0 3.0 (-1.0) 2.5
#eval check2 (-0.7) 0.4 2.0 5.0 0.3
def check3 (a b a' b' y : Float) : Float × Float :=
  (vfb (emlF a b) (emlF a' b') y, y * vfb (affF a b) (affF a' b') (Float.log y))
#eval check3 1.3 (-0.6) 0.5 2.2 4.0
def expInt (a t : Float) : Float := if a == 0.0 then t else (Float.exp (a*t) - 1.0)/a
def flowClosed (a b y0 t : Float) : Float := Float.exp (b * expInt a t) * (y0 ^ (Float.exp (a*t)))
partial def euler (a b y t n : Float) (k : Nat) : Float :=
  if k = 0 then y else euler a b (y + (t/n) * emlF a b y) t n (k-1)
def check4 (a b y0 T : Float) : Float × Float :=
  (euler a b y0 T 200000.0 200000, flowClosed a b y0 T)
#eval check4 0.5 1.0 2.0 1.0
#eval check4 (-1.2) 0.3 0.5 2.0
#eval check4 0.0 0.8 3.0 1.5
def cgf (p y : List Float) (s : Float) : Float :=
  Float.log ((p.zip y).foldl (fun acc (pi, yi) => acc + pi * (yi ^ s)) 0.0)
def check5 (c k s : Float) : Float × Float :=
  let p := [0.2, 0.5, 0.3]
  let y := [1.5, 2.0, 4.0]
  (cgf p (y.map (fun yi => c * yi ^ k)) s, s * Float.log c + cgf p y (k * s))
#eval check5 2.0 1.5 0.7
#eval check5 0.4 (-2.0) 1.3
#eval ((1.0 * (2.0 * 3.0 ^ 1.0) ^ 2.0), (2.0 * (1.0 * 3.0 ^ 2.0) ^ 1.0))
def expMapCheck (c k : Float) : Float × Float :=
  let a := Float.log k
  let b := Float.log c * Float.log k / (k - 1.0)
  (Float.exp (b * expInt a 1.0), Float.exp a)
#eval expMapCheck 3.0 2.0
#eval expMapCheck 0.25 5.0
```

---

## Cycle 2 — evidence for the representation obstructions and the rigidity ODE

All figures below were produced by `#eval` inside Lean itself (exact rational
arithmetic for the matrix data, `Float` for the vector-field data), and each
identity that the data suggests is proved in
`Catalog/Probability/EMLLieRigidity.lean`.

### 1.  The relation `⁅A, B⁆ = B` in the catalog `2 × 2` model

With `A = !![1,0;0,0]` (image of `D`) and `B = !![0,1;0,0]` (image of `T`):

| quantity | value |
|---|---|
| `A*B - B*A = B` | `true` |
| `tr(B), tr(B²), tr(B³)` | `0, 0, 0` |
| `det B` | `0` |

This is the smallest instance of `rep_shift_trace_pow_eq_zero` and
`rep_shift_det_not_isUnit`: the pure-scaling generator is *always* traceless in
all powers and singular, in every representation.

### 2.  The trace obstruction on a random `3 × 3` skew matrix

`A = !![2,-1,3;0,5,1;4,1,-2]`, `B = !![0,7,-2;-7,0,5;2,-5,0]` (`Bᵀ = -B`):

* `tr(⁅A,B⁆ · B) = 0` — the identity `trace_lie_mul_self`, valid for *all* `A, B`.
* `tr(B·B) = -156 ≠ 0` — a nonzero skew matrix always has strictly negative
  `tr(B²)`.

Combining the two lines: no skew `B ≠ 0` can satisfy `⁅A,B⁆ = B`, since that
would force `tr(B²) = tr(⁅A,B⁆B) = 0`.  This is the numerical shadow of
`no_faithful_skew_representation`.

### 3.  The rigidity ODE

Testing the eigenvector equation `y log y · F'(y) - F(y)(log y + 1) = -F(y)`
at `y = 2`:

| candidate field `F` | left-hand side | `-F(2)` | eigenvector? |
|---|---|---|---|
| `F y = y` | `-2.000000` | `-2.000000` | yes |
| `F y = y²` | `-1.227411` | `-4.000000` | no |

Only the pure scaling field passes; the counterexample hunt over the monomials
`y^m` (all `m ≠ 1` fail, since the equation forces `y F' = F` off `y = 1`) is
what `emlField_rigidity` turns into a proof: *every* differentiable solution is
a multiple of `y`.

## Cycle 3 evidence (for `Catalog/Probability/EMLNilpotentCentralizer.lean`)

All figures below were produced by `#eval` inside Lean (exact `ℚ` arithmetic for
the matrix data, `Float` central differences for the vector-field data), and
every identity they suggest is proved in the file.

### A. Nilpotency of an `ad`-eigenvector of eigenvalue one (NC1)

Two exact solutions of `A B − B A = B`:

| `n` | `A` | `B` | `tr B, tr B², tr B³` | `B² = 0?` | `B³ = 0?` |
|---|---|---|---|---|---|
| 2 | `diag(1,0)` | `!![0,1;0,0]` | `0, 0, 0` | `true` | `true` |
| 3 | `diag(2,1,0)` | strict upper shift | `0, 0, 0` | **`false`** | `true` |

The `n = 3` row is the interesting one: the power traces all vanish already at
`k = 1`, but `B² ≠ 0`, so the exponent `n` in `B ^ n = 0`
(`pow_card_eq_zero_of_lie_eq_self`) is sharp and cannot be lowered to `2`.  Both
rows also exhibit the eigenvalue pattern behind the proof: `ad A` sends
`B ↦ 1·B`, `B² ↦ 2·B²`, `B³ ↦ 3·B³`, and it is precisely the impossibility of
having infinitely many eigenvalues that forces the powers to die.

### B. The centralizer is one-dimensional even for a nonvanishing field (NC3)

Take the pure-scaling field `X y = b y` with `b = 1`, i.e. the case
`g.scale = 0` for which cycle 2 conjectured an infinite-dimensional
centralizer.  A natural candidate for an extra solution is
`F y = y sin(log y)` (any `y·h(log y)` with `h` periodic would do if the naive
"one function's worth of freedom" heuristic were correct).  Central differences
give for `y F′(y) − F(y)`:

| `y` | 1.5 | 2.0 | 3.0 |
|---|---|---|---|
| `y F′ − F` | `1.3784` | `1.5385` | `1.3645` |

— far from zero, whereas the same expression for `F y = 3 y` gives
`−0.000000, −0.000000, −0.000000`.  The Euler equation `y F′ = F` really does
pin the solution space down to the single line `ℝ · y`, which is what
`emlField_centralizer_of_scale_eq_zero` proves.

### C. The singular case, and why the glueing lemma is needed

For `X y = y log y` (`g = D`) and `F = 5 X`, the bracket
`X F′ − F X′` evaluates to `−0.000000, 0.000000, 0.000000` at
`y = 0.5, 1.5, 4.0`: multiples of the field do commute with it.

Now break the glue deliberately: let `F = 1·X` on `(0,1)` and `F = 2·X` on
`(1,∞)`.  This `F` is continuous at the singular point `y = 1` (both pieces
vanish there) and satisfies the centralizer equation off `y = 1`, so *continuity
alone cannot rule it out* — which is exactly why the cycle-2 glueing lemma is
insufficient.  The one-sided difference quotients at `y = 1` are

| side | left | right |
|---|---|---|
| slope | `0.99995` | `2.00010` |

i.e. `c₁ · X′(1)` and `c₂ · X′(1)` with `X′(1) = 1`.  They disagree, so `F` is
not differentiable at `1`: this is precisely the mechanism of
`const_glue_of_differentiableAt`, and it shows the differentiability hypothesis
at the singular point is load-bearing rather than cosmetic.

## Cycle 4 evidence (for `Catalog/Probability/EMLGroupCentralizer.lean`)

Exact `ℚ` computation with affine maps written as pairs `(lin, trans)` and
composition `(f ∘ g) = (f.lin g.lin, f.lin g.trans + f.trans)`.  The column
`crit` is `g.trans (f.lin − 1) − f.trans (g.lin − 1)`, the quantity that
`AffMap.commute_iff` claims vanishes exactly on commuting pairs.

| `f` | `g` | `f g = g f`? | `crit` |
|---|---|---|---|
| `(2, 3)` | `(4, 9)` | `true` | `0` |
| `(2, 3)` | `(4, 8)` | `false` | `-1` |
| `(1, 5)` | `(1, 7)` | `true` | `0` |
| `(1, 5)` | `(2, 0)` | `false` | `-5` |
| `(-1, 4)` | `(3, 4)` | `false` | `-16` |

The criterion matches the brute-force composition in every row, including the
translation row `(1,5), (1,7)` (two translations always commute) and the row
`(1,5), (2,0)` showing a nontrivial translation does not commute with a
non-translation, which is `AffMap.commute_iff_of_lin_eq_one`.

The commuting pair `(2,3), (4,9)` illustrates
`AffMap.commute_iff_fixes_fixedPoint`: the fixed point of `f = (2,3)` is
`x* = 3 / (1 − 2) = −3`, and indeed `4·(−3) + 9 = −3 = 2·(−3) + 3`, i.e. both
maps fix `x*`.
