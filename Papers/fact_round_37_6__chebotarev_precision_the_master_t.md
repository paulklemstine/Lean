# Computational Evidence — Paper 134 (Chebotarev precision)

All numbers below come from a short exploratory Python script (exact rational/float arithmetic,
naive root counting). They are **exploratory only**. The claims that matter were then proved in
Lean, and the files are listed next to each item.

## 1. Fresh law constants (L = log₂ 3)

| group | closed form (proved in Lean) | numerical value | recorded 6-dec | Lean |
|---|---|---|---|---|
| S₃, S₄, regular S₃ | 1 | 1 | 1 | `master_table_precision` |
| A₄ | L − 2/3 | 0.918295834 | 0.918296 | ✓ |
| D₄ | 9/4 − 3L/8 | 1.655639062 | 1.655639 | ✓ |
| V₄ | 2 − 3L/4 | 0.811278124 | 0.811278 | ✓ |
| C₄ | 3/2 | 1.5 | 1.5 | ✓ |
| D₆ (faithful type) | 4/3 + L/4 | 1.729573959 | 1.729574 | ✓ |
| D₆ (quartic readout) | 1 + L/4 | 1.396240625 | 1.396241 | ✓ |
| **F₂₀ (new row)** | **3/2** | 1.5 | 1.5 | `F20_channel` |
| C₅ (seeding control) | log₂5 − 8/5 | 0.721928095 | — | `C5t_channel` |

The enclosure we used is 1054/665 = 1.58496240… < L = 1.58496250… < 3647/2301 = 1.58496306…,
which comes from \(2^{1054} < 3^{665}\) and \(3^{2301} < 2^{3647}\). Its width of 6.5·10⁻⁷ is enough
to fix every constant to 6 decimals. Lean: `logb2_three_gt_conv`, `logb2_three_lt_conv`.

## 2. The F₂₀ joint table (counted by `decide` in Lean)

The coset readout is the multiplier a of x ↦ a·x + b on ℤ/5. The splitting type is
(#fixed points, #points on 2-cycles).

| coset a | types (count) |
|---|---|
| 1 (= C₅) | (5,0)×1, (0,0)×4 |
| 4 (= −1) | (1,4)×5 |
| 2 | (1,0)×5 |
| 3 | (1,0)×5 |

These counts give H(T) = 11/10 + log₂5/4, H(c) = 2, H(c,T) = 8/5 + log₂5/4, so I = 3/2. That is the
same value as C₄ (**law collision**, `F20_C4_collision`).

## 3. S3d-style field x³ − x − 1 (disc −23): plug-in channel vs prime range

Plug-in I(p mod 23 ; root count) over the unramified primes p < N. The coprime control is the dial p mod 29.

| N | #primes | I(p mod 23; type) | dictionary mismatches | I(p mod 29; type) (coprime control) |
|---|---|---|---|---|
| 10² | 24 | 1.0920 | 0 | 0.9772 |
| 10³ | 167 | 1.0036 | 0 | 0.2063 |
| 10⁴ | 1228 | 1.0006 | 0 | 0.0159 |
| 10⁵ | 9591 | 1.0001 | 0 | 0.0016 |

What the table shows:
* The plug-in estimate approaches the law value 1 **from above**, so the small-population bias is
  positive. This fits the historical S3d value 1.0078. In Lean the population law is exactly 1 for
  *every* uniform dial (`S3_anyDial_law`), while a sparse sample can overshoot it
  (`S3d_plugin_overshoot`: the sample {2, 5, 59} gives log₂ 3).
* The coprime dial falls towards 0. This is the "null bias floor". In Lean the population value is
  exactly 0 (`mutualInfo_prod_eq_zero`), and a coprime residue adds nothing on top of the Artin dial
  (`coprimeDial_adds_nothing`).
* The dictionary (one root ⇔ non-residue mod 23) had 0 mismatches up to 10⁵. In Lean it is checked
  for p < 100 (`S3d_dictionary`).

## 4. Counterexample hunt

* The literal hypothesis "a finer dial can carry more than log₂[G:G'] bits in the population" is
  **false**: `fineDial_law_le_logb_index`.
* "The plug-in estimate is always ≤ the law" is **false**: `S3d_plugin_overshoot`.
* "Distinct groups have distinct law values" is **false**: `F20_C4_collision`.

No OEIS sequence is relevant here (the objects are real constants, not integer sequences).
