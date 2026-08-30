# Computational Evidence

All numbers below were produced by `#eval` inside Lean 4 (mathlib4, toolchain
`leanprover/lean4:v4.28.0`) against the definitions actually used in the proofs, i.e. the
same `goldenWords`, `blockPos` and coding maps that appear in
`Catalog/MachineLearning/CantorCompactness.lean`,
`Catalog/MachineLearning/CantorSubshiftDimension.lean` and
`Catalog/MachineLearning/GoldenMeanHomeomorph.lean`.

The evidence stage was used only to *choose and check* the statements; every claim that
appears in the papers' theorem list is proved formally (0 sorries, axioms
`propext / Classical.choice / Quot.sound` only).

## 1. Counting admissible words (cylinders of the golden-mean subshift)

`goldenWords n` is the recursively defined finite set of length-`n` binary words with no two
consecutive `true`s (`w = false :: w'` or `w = true :: false :: w''`).

```
#eval (List.range 13).map (fun n => (goldenWords n).card)
-- [1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377]

#eval (List.range 13).map (fun n => Nat.fib (n+2))
-- [1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377]
```

Independent brute-force cross-check (enumerate **all** `2^n` words and filter those with no
`true true` factor, using a different recursion):

```
#eval (List.range 13).map (fun n => ((allWords n).filter noTwoTrue).length)
-- [1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377]
```

All three agree, and `decide (∀ n ∈ List.range 13, (goldenWords n).card = Nat.fib (n+2))`
evaluates to `true`.  The sequence `1, 2, 3, 5, 8, 13, ...` is the Fibonacci sequence
(OEIS A000045, shifted: `fib (n+2)`); this is the classical count of binary strings avoiding
`11`.

Formalised as `card_goldenWords : (goldenWords n).card = Nat.fib (n + 2)`.

## 2. Growth rate / box dimension

| n  | N(n) = fib(n+2) | log N(n) / (n log 2) |
|----|-----------------|-----------------------|
| 4  | 8               | 0.750000              |
| 8  | 55              | 0.722670              |
| 16 | 2584            | 0.708462              |
| 32 | 5702887         | 0.701352              |
| 64 | 27777890035288  | 0.697797              |

Limit predicted: `log φ / log 2 = 0.6942419...`.  The two-sided bound
`φ ^ n ≤ fib (n+2) ≤ φ ^ (n+1)` (checked numerically for `n ≤ 30` before being proved) gives
the squeeze that is formalised in `tendsto_boxDimension`.

## 3. Counterexample hunt for the substitution `0 ↦ 0`, `1 ↦ 10`

A computable mirror `codeAux` of the (noncomputable, classical) `code` was evaluated on
sample inputs to check that the image really avoids `11`, and that block positions behave:

```
x    = 1,0,1,1,0,0,0,...
blk  = [0, 2, 3, 5, 7, 8]                       -- block start positions
code = [1,0,0,1,0,1,0,0,0,0,0,0]                -- "10"+"0"+"10"+"10"+"0"+"0"
```

No sample produced two consecutive `true`s in the output, and no two distinct sampled inputs
produced the same output.  Both observations were then proved:
`code_mem_goldenMean` and `code_injective`; surjectivity onto the subshift is `code_decode`.

## 4. Failed / rejected conjectures found computationally

* *"The subshift is shift-conjugate to the full shift"* — rejected immediately: the growth
  rates `fib (n+2) ~ φⁿ` and `2ⁿ` differ, so no conjugacy can exist.  This is what forced the
  cycle-3 statement to be a **homeomorphism** and not a conjugacy.
* *"`code` is an isometry"* — rejected.  Substitution inserts letters, so two inputs that
  first differ at index `n` produce outputs that first differ at index `blockPos n ≥ n`; the
  output distance can therefore be strictly smaller than the input distance.  Only the
  inequality `dist (code x) (code y) ≤ dist x y` survives, and that is what is proved
  (`dist_code_le`), which is all that continuity needs.

---

# Cycles 5–8 (dynamics, capacity, learning, rigidity)

## 5. Periodic points of the golden-mean shift

`cyc w` repeats the buffered word `w ++ [false]`.  Evaluated directly in Lean:

```
cyc [true]        = 1,0,1,0,1,0,1,0,1,0,...     period 2
cyc [true,false]  = 1,0,0,1,0,0,1,0,0,1,...     period 3
```

Both avoid `11`, as required, and both are exactly periodic with period `w.length + 1`.  These
two observations became `cyc_mem_goldenMean` and `cyc_periodic`; combined with
`prefixOf_cyc` they give density of periodic points (`goldenMean_periodicPoints_dense`).

## 6. The two Fekete inequalities, checked before proving

`#L n` denotes `(goldenWords n).card`.  Table of
`(#L n · #L m, #L (n+m+1), #L (n+m))` for `0 ≤ n, m ≤ 4`:

```
(n,m)   #L n·#L m   #L(n+m+1)   #L(n+m)
(1,1)       4           5           3
(2,2)       9          13           8
(3,3)      25          34          21
(4,4)      64          89          55
(2,3)      15          21          13
(4,3)      40          55          34
```

In every sampled pair `#L(n+m) ≤ #L n · #L m ≤ #L(n+m+1)`, with both inequalities strict for
`n, m ≥ 1`.  No counterexample was found in the `0 ≤ n,m ≤ 4` window; the two inequalities were
then proved *structurally* (gluing injection and cutting injection) as
`card_goldenWords_mul_le` and `card_goldenWords_add_le`, and re-exported as the Fibonacci
inequalities `fib_mul_fib_le_fib`, `fib_le_fib_mul_fib`.

## 7. Exponential sparseness

`(n, #L n, 2ⁿ)` for `n ≤ 11`:

```
(0,1,1) (1,2,2) (2,3,4) (3,5,8) (4,8,16) (5,13,32) (6,21,64)
(7,34,128) (8,55,256) (9,89,512) (10,144,1024) (11,233,2048)
```

Equality holds exactly at `n = 0, 1`; from `n = 2` on the gap widens geometrically.  This is
`card_goldenWords_lt_two_pow` (stated for lengths `n + 2`, matching the data).

## 8. Sharpness of the `true`-density bound

Maximum number of `true`s over all admissible words of length `n`, against the proved bound
`⌊(n+1)/2⌋`:

```
n        0  1  2  3  4  5  6  7  8
max      0  1  1  2  2  3  3  4  4
(n+1)/2  0  1  1  2  2  3  3  4  4
```

The bound is attained at every length, and the maximiser at odd lengths is the alternating
word — this is exactly `admissible_count_true` together with `admissible_count_true_sharp`.

## 9. The online adversary (cycle 7)

Two concrete predictors were run against the adversary stream `adv p` produced by the
formalised construction, over the first 10 rounds:

```
p_smart h = if h ends in `true` then false else true
  adv p_smart = 0,0,0,0,0,0,0,0,0,0        mistakes after n rounds: 0,1,2,3,...,10
p_alt   h = decide (h.length % 2 = 0)
  adv p_alt   = 0,1,0,1,0,1,0,1,0,1        mistakes after n rounds: 0,1,2,3,...,10
```

Both predictors are forced into a mistake in *every* round — better than the guaranteed `n/2`.
Meanwhile the trivial predictor `alwaysFalse` scores `0` mistakes on the all-`false` stream, so
the upper bound `2·mistakes ≤ n + 1` is also not vacuous.  These runs are what suggested the
minimax statement `goldenMean_minimax_mistake_bound`.

## 10. Rejected in cycles 5–8

* *"The golden-mean shift is injective on the subshift"* — rejected by inspection: `0·allFalse`
  and `1·allFalse` are both admissible and have the same image.  Formalised as
  `not_injOn_shift_goldenMean`.
* *"The homeomorphism of cycle 4 can be upgraded to a conjugacy"* — rejected by counting fixed
  points (`2` versus `1`), which is cheaper than the entropy argument and is what
  `not_exists_shift_conjugacy` uses.
* *"Prediction difficulty is governed by entropy"* — rejected.  The constraint lowers the
  minimax mistake rate from `1` (unconstrained) to exactly `1/2`, which is *not* the entropy
  ratio `log φ / log 2 ≈ 0.694`: the adversary regains a free choice immediately after each
  forced move, so the rate tracks the forced-run length rather than the word count.

## 11. Cycles 9–10: transitive point and the period-2 census

The transitive point of cycle 9 is the concatenation `w₀ 0 w₁ 0 w₂ 0 …` over an enumeration of
all finite words, keeping only the admissible ones.  Two checks preceded the proof:

* every finite stage `segs n` ends in the buffer letter, so appending anything admissible
  cannot create `11` — formalised as `segs_admissible`;
* stage lengths are strictly increasing (`le_length_segs : n ≤ (segs n).length`), so the
  stream `transPoint k = (segs (k+1)).getD k false` is well defined and stable under passing
  to a longer stage (`transPoint_eq_getD`).

For the period-`2` census the streams of period `2` are exactly the alternations `per2 a b`,
of which there are `4`; discarding `per2 true true` (which contains `11`) leaves `3`:

```
period 1:  golden mean 1  (0^∞)                 full shift 2
period 2:  golden mean 3  (00)^∞ (01)^∞ (10)^∞  full shift 4
Lucas:     L1 = 1, L2 = 3
```

The two golden-mean counts match the Lucas numbers, which is the evidence behind the
periodic-census conjecture in `FUTURE_DIRECTIONS.md`.

## 12. Cycle 11: the full periodic census

Before proving the census we evaluated the two sides in Lean.  With
`cyclicGoldenWords n` the admissible words of length `n` whose first and last letters are not
both `true`, and `lucas` the Lucas recursion `L 0 = 2`, `L 1 = 1`, `L (n+2) = L n + L (n+1)`:

```
#eval (List.range 8).map (fun n => ((cyclicGoldenWords (n+1)).card, lucas (n+1)))
-- [(1, 1), (3, 3), (4, 4), (7, 7), (11, 11), (18, 18), (29, 29), (47, 47)]
```

so the counts agree with `L 1 … L 8 = 1, 3, 4, 7, 11, 18, 29, 47` (OEIS A000032, the Lucas
numbers; the same sequence counts binary necklaces avoiding `11` cyclically).  The comparison
sequence for the full shift is `2 ^ n = 2, 4, 8, 16, 32, 64, 128, 256`, strictly larger at
every `n ≥ 1` — the numerical form of the conjugacy obstruction.

The two ingredients were checked separately as well: the "starts with `false`" and "ends with
`false`" classes each have `fib (n+1)` elements and their intersection has `fib n`, so
inclusion–exclusion predicts `2·fib (n+1) − fib n = fib (n+1) + fib (n−1)`, which is exactly
the Lucas number.  All of these statements are now theorems in
`Catalog/MachineLearning/GoldenMeanPeriodicCensus.lean`, so the table above is reproduced by
the proofs rather than only by evaluation.

## 13. Cycle 12: transfer matrix, trace formula and the rational census series

Two numerical checks preceded the formal proofs of
`Catalog/MachineLearning/GoldenMeanZeta.lean`.

**(a) Trace formula.** With `A = !![1,1;1,0]` over `ℤ`:

```
#eval (List.range 9).map (fun n => ((transferMatrix ℤ ^ n).trace, (lucas n : ℤ)))
-- [(2, 2), (1, 1), (3, 3), (4, 4), (7, 7), (11, 11), (18, 18), (29, 29), (47, 47)]
```

so `trace (A ^ n) = lucas n` on `0 ≤ n ≤ 8`, including the degenerate `n = 0` where both sides
are `2` (`A ^ 0` is the `2 × 2` identity, and `L₀ = 2`).  Combined with the cycle-11 census this
predicts the Artin–Mazur trace formula `#{x ∈ GoldenMean | shift^[n] x = x} = trace (A ^ n)`
for `n ≥ 1`, which is now the theorem `periodicPoints_trace_formula`.

**(b) Denominator of the generating series.** Multiplying the census series by `1 - X - X²`
coefficientwise:

```
#eval (List.range 9).map (fun n =>
  let L : ℕ → ℤ := fun k => (lucas k : ℤ)
  (L n) - (if n ≥ 1 then L (n-1) else 0) - (if n ≥ 2 then L (n-2) else 0))
-- [2, -1, 0, 0, 0, 0, 0, 0, 0]
```

i.e. `(1 - X - X²) · ∑ₙ Lₙ Xⁿ = 2 - X` to the computed order, with the two nonzero
coefficients coming exactly from the initial values `L₀ = 2` and `L₁ = 1` and every higher
coefficient vanishing by the Lucas recursion.  This is the theorem `censusSeries_rational`,
and `det_one_sub_smul_transferMatrix` identifies the polynomial `1 - X - X²` as
`det (1 - X • A)`, so the denominator really is the characteristic series of the transfer
matrix.  The corresponding full-shift check is `2ⁿ - 2·2ⁿ⁻¹ = 0` for `n ≥ 1`, i.e.
`(1 - 2X) · ∑ₙ 2ⁿ Xⁿ = 1` (`fullShift_censusSeries_rational`).
