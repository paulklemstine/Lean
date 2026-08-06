# Computational evidence: half-canonical divisors on regular graphs

All numbers below were produced with an exact Baker–Norine rank computation
(`evidence/bn_rank.py`): divisors are reduced with the standard "level-by-level"
debt-clearing pass followed by Dhar's burning algorithm, `D` is equivalent to an
effective divisor iff its `q`-reduced form is non-negative at `q`, and
`rank(D) ≥ r` is decided by testing *every* effective divisor `E` of degree `r`.
These computations are exploratory: they guided the statements that are proved
in Lean, and they are **not** themselves formally verified.  Every claim that is
asserted as a theorem lives in `Catalog/Pythagorean/BrillNoether/*.lean` and is
proved there without `sorry`.

Throughout, `G` is simple, connected and `k`-regular on `n` vertices,
`g = #E - n + 1`, and the half-canonical degree is
`g - 1 = (k-2)n/2` (this identity is `two_mul_genus_sub_one_regular`).

## 1. Rank of the natural (near-uniform) half-canonical witness

`D` is the divisor with `m = ⌊(k-2)/2⌋` chips everywhere and the remaining
`g - 1 - mn` chips distributed one per vertex.

| graph | n | k | g | deg = g-1 | rank(D) | `2m` (proved, `rankAtLeast_add_of_forall_le`) | `min(3m-1, k+m)` (proved, `rankAtLeast_of_forall_le_three_mul`) | target `k-1` |
|---|---|---|---|---|---|---|---|---|
| K₆ | 6 | 5 | 10 | 9 | **2** | 2 | – (`m=1`) | 4 |
| C₈(1,2,4) | 8 | 5 | 13 | 12 | **2** | 2 | – | 4 |
| C₁₀(1,2,5) | 10 | 5 | 16 | 15 | **2** | 2 | – | 4 |
| C₁₂(1,2,6) | 12 | 5 | 19 | 18 | **2** | 2 | – | 4 |
| C₁₄(1,2,7) | 14 | 5 | 22 | 21 | **2** | 2 | – | 4 |
| icosahedron | 12 | 5 | 19 | 18 | **3** | 2 | – | 4 |
| K₅,₅ | 10 | 5 | 16 | 15 | **5** | 2 | – | 4 |
| K₇ | 7 | 6 | 15 | 14 | **5** | 4 | 5 | 5 |
| C₈(1,2,3) | 8 | 6 | 17 | 16 | **5** | 4 | 5 | 5 |
| C₉(1,2,3) | 9 | 6 | 19 | 18 | **5** | 4 | 5 | 5 |
| K₈ | 8 | 7 | 21 | 20 | **5** | 4 | 5 | 6 |
| K₉ | 9 | 8 | 28 | 27 | **≥ 9** | 6 | 8 | 7 |

Observations that drove the formalisation.

* For `k = 6` the proved bound `min(3m-1, k+m) = 5 = k-1` is **attained exactly**
  on K₇, C₈(1,2,3) and C₉(1,2,3): the set-firing bound is sharp there, and the
  conjectured value `k-1` is reached already at `n = 7`, i.e. with no threshold.
* For `k = 7` no witness we tested on K₈ exceeded `5 = k - 2`, which is exactly
  the proved bound.  This is the one residual case `k = 7` of
  `exists_halfCanonical_rank_conjecture`.
* For `k = 5` the near-uniform witness stalls at rank `2` for circulants of every
  size tested (`n = 6, 8, 10, 12, 14`), while K₅,₅ reaches `5`.  So at `k = 5`
  the witness must be chosen graph-dependently; a uniform construction fails.

## 2. Exhaustive check at `k = 5`, `n = 6`

For K₆ we enumerated **all** `5⁵ = 3125` linear equivalence classes of divisors
of degree `g - 1 = 9` (via `q`-reduced representatives) and computed the rank of
each.  The maximum over all classes is `2`.  Hence:

* the conjectured rank `k - 1 = 4` genuinely **fails** at `n = 6` for `k = 5`, so
  a threshold `N₀(5) > 6` is necessary — the uniform statement cannot hold with
  `N₀(k) = 1` for `k = 5`;
* the proved bound `2⌊(k-2)/2⌋ = 2` is attained, hence optimal for `k = 5` at
  this size.

Consistently, the Brill–Noether number at `d = g-1`, `r = k-1` is
`g - k² = 10 - 25 < 0` for K₆: the failure at `n = 6` is already visible
numerically (`bnNumber_regular_pos_iff`).

## 3. Numerical threshold versus the conjectured `2k²`

`bnNumber_regular_pos_iff` shows `ρ = g - k² ≥ 1 ⟺ 2k² ≤ (k-2)n`, i.e.
`n ≥ ⌈2k²/(k-2)⌉`.  The exact minimal `n` (also respecting the parity constraint
`kn` even and `n ≥ k+1`) compared with `2k²`:

| k | `⌈2k²/(k-2)⌉` | minimal admissible n | `2k+7` | `2k²` |
|---|---|---|---|---|
| 5 | 17 | 18 | 17 | 50 |
| 6 | 18 | 18 | 19 | 72 |
| 7 | 20 | 20 | 21 | 98 |
| 8 | 22 | 22 | 23 | 128 |
| 10 | 25 | 26 | 27 | 200 |
| 20 | 45 | 46 | 47 | 800 |

The numerical obstruction therefore disappears at a **linear** scale
`n ≈ 2k + 4`, not at `2k²`; the proved statement
`bnNumber_regular_pos_of_linear_threshold` uses the clean sufficient bound
`n ≥ 2k + 7` (valid for `k ≥ 5`).

## 4. OEIS

No new integer sequence is singled out by these computations: the quantities
involved (`g - 1 = (k-2)n/2`, `⌈2k²/(k-2)⌉`) are elementary polynomial/rational
expressions, and the observed rank values (`2, 5, 8, …`) are the values of the
proved bounds `2⌊(k-2)/2⌋` and `3⌊(k-2)/2⌋ - 1`, not an independent sequence.
No OEIS lookup was therefore informative.

## 5. Counterexample hunt

* Against the *proved* bounds: for each graph in the table above, and for the
  constant divisors `const m` on K₆, C₈(1,2,4), C₈(1,2,3), K₉, the computed rank
  was always `≥` the bound; no counterexample was found (as expected: they are
  theorems).
* Against the *conjecture* `rank ≥ k-1` at degree `g-1`: for `k = 5` all
  circulants tested and the exhaustive search on K₆ fall short, confirming that
  a threshold is needed at `k = 5`; for `k = 7` the tested witnesses on K₈ fall
  short by exactly one.  For `k = 6` and `k = 8` no shortfall occurs at any size
  tested, in agreement with the theorem
  `exists_halfCanonical_rank_conjecture` (`k ≥ 6`, `k ≠ 7`).
