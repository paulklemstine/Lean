# Computational evidence — GENERIC-RECOVERY (experiment 390)

All numbers below were produced by `#eval` inside the project's own Lean 4 /
Mathlib toolchain (exact integer arithmetic, no floating point, no sampling).
They were used to *select* the statements that were then proved formally in
`Catalog/Combinatorics/GenericRecoveryHintTaxonomy.lean`,
`…HintSharpness.lean` and `…HintSymmetry.lean`.  Everything marked **theorem**
below is now machine-checked; the remaining rows are exploratory data.

## 1. Square (trace) hint on the odd residues mod `2^t`

Hint `x ↦ x² mod 2^t`, candidate set = odd residues mod `2^t`
(`|S| = 2^{t-1}`).

| t | \|S\| | #readings | max class |
|---|------|-----------|-----------|
| 3 | 4 | 1 | 4 |
| 4 | 8 | 2 | 4 |
| 5 | 16 | 4 | 4 |
| 6 | 32 | 8 | 4 |
| 7 | 64 | 16 | 4 |
| 8 | 128 | 32 | 4 |
| 9 | 256 | 64 | 4 |
| 10 | 512 | 128 | 4 |

`#readings = 2^{t-3}` and every class has exactly `4` elements.  **Theorem**
(`card_image_sqHint`, `worstCost_sqHint`, `card_sq_fiber_eq_four`): a `t`-bit
trace hint carries exactly `t − 3` usable bits — one lost to parity, two to the
square-root ambiguity.

## 2. Value hints are parity-constrained

Image sizes of `p ↦ c·p mod 2^t` and `p ↦ (p XOR m) mod 2^t` over the odd
`p < 2^12`:

| t | `c=3` | `c=5` | `m=7` | `m=10` | `2^t` | `2^{t-1}` |
|---|------|------|------|-------|------|----------|
| 1 | 1 | 1 | 1 | 1 | 2 | 1 |
| 2 | 2 | 2 | 2 | 2 | 4 | 2 |
| 4 | 8 | 8 | 8 | 8 | 16 | 8 |
| 6 | 32 | 32 | 32 | 32 | 64 | 32 |
| 8 | 128 | 128 | 128 | 128 | 256 | 128 |

Never `2^t`, always exactly `2^{t-1}`.  **Theorem**
(`worstCost_mulHint_ge`, `worstCost_xorHint_ge`).

## 3. Bit-vector hints are information-exact *and position-free*

Class sizes of "read the bits of `p` in the position set `A`", `k = 10`:

* `A = {0,1,2}` → all classes `128 = 2^{10-3}`
* `A = {7,8,9}` (top bits) → all classes `128`
* `A = {0,4,9}` (scattered) → all classes `128`

GF(2) linear forms with random masks (`popcount` parities), `k = 10`:

* one form (mask 341) → classes `[512, 512]`
* two forms (341, 598) → classes `[256,256,256,256]`
* three forms (341,598,823) → eight classes, all `128`
* four forms (7,11,13,19) → sixteen classes, all `64`

No anomalous class anywhere: the partition is exactly uniform.  **Theorem**
(`card_fiber_gf2`, `card_fiber_coordRestrict`, `card_fiber_coordRestrict_congr`).

## 4. Sharpness of the master bound

Block hint `p ↦ p/5` on `range (5·2³)`: `8 = 2^3` readings, class sizes
`[5,5,5,5,5,5,5,5]`.  The bound `|S|/2^t` is attained.  **Theorem**
(`worstCost_blockHint`).

## 5. Klein four-group of square roots of unity mod `2^t`

`c = 1 + 2^{t-1}`; computed `c² mod 2^t`, `(−1)² mod 2^t`, `(−c)² mod 2^t`:

| t | c | c² | (−1)² | (−c)² |
|---|---|----|-------|-------|
| 3 | 5 | 1 | 1 | 1 |
| 4 | 9 | 1 | 1 | 1 |
| 5 | 17 | 1 | 1 | 1 |
| 6 | 33 | 1 | 1 | 1 |
| 7 | 65 | 1 | 1 | 1 |

Exactly four square roots of `1`, and they are the reason the square hint has
four-element classes.  **Theorem** (`card_kleinMul`, `kleinMul_sq_eq_one`,
`cost_sqHint_ge_four`).

## 6. Counterexample hunt: the *full* trace congruence

The formal theorem covers the square core `x² ≡ u² (mod 2^t)` (exactly four
roots).  The full trace congruence `x² − s·x + N ≡ 0 (mod 2^t)` with
`N = p·q`, `s = p+q` has *more* roots, because completing the square costs a
factor of two:

| t | p=61, q=53 | p=1009, q=1013 |
|---|-----------|----------------|
| 3 | 2 | 2 |
| 4 | 4 | 4 |
| 5 | 4 | 8 |
| 6 | 8 | 8 |
| 8 | 16 | 8 |
| 10 | 16 | 8 |

`C_t` saturates at `8` or `16` depending on the 2-adic valuation of `p − q` —
consistent with the experiment's "median saturating 4–8" and with
`log₂ C_t ≈ 3`.  This is an honest boundary of the formal result: the proved
statement is the exact count `4` for the square hint, and it is a *lower* bound
for the trace hint (the extra factor only makes the trace hint worse).  No
counterexample to any proved statement was found.

## 7. OEIS

The only sequences that appear are `2^{k-t}` (A000079 shifted) and the constant
`4`; no non-trivial sequence arises, which is itself the content of the
"information-exact, no anomalous class" finding.
