# Computational Evidence — Las Vegas compression and the one-way boundary

All numbers below were produced by `#eval` in Lean 4 (Mathlib v4.28.0) with the
reproduction script at the bottom of this file, before the corresponding theorems
in `Catalog/Novelty/CompressionLasVegasOWF.lean` were proved. Bit strings are
`List Bool`; `Kc D L y` brute-force searches all programs of length `≤ L`.

## 1. The pigeonhole ceiling is exact

Number of programs of length `≤ s` versus `2^(s+1) − 1`:

| s | #programs | 2^(s+1) − 1 |
|---|-----------|-------------|
| 0 | 1 | 1 |
| 1 | 3 | 3 |
| 2 | 7 | 7 |
| 3 | 15 | 15 |
| 4 | 31 | 31 |
| 5 | 63 | 63 |

This is the ceiling used throughout (`CompressionOWF.card_le_of_K_le`).

## 2. A concrete decompressor, `D p = p ++ p`

Number of 4-bit strings with `K D y ≤ s` (search limit `L = 4`), versus the
ceiling:

| s | #{y : |y| = 4, K ≤ s} | 2^(s+1) − 1 |
|---|----------------------|-------------|
| 0 | 0 | 1 |
| 1 | 0 | 3 |
| 2 | 4 | 7 |
| 3 | 4 | 15 |
| 4 | 4 | 31 |

Only the 4 strings of the form `pp` are describable; the ceiling is respected
with room to spare — as expected for a non-surjective decompressor.

## 3. Las Vegas success counts for the seeded prefix family

Seeds are pairs `(u, v)` with `|u| = j` (used) and `|v| = i` (wasted); the
decompressor is `D (u,v) p = u ++ p`, the target length budget is `s`, and the
targets are all strings of length `j + s`.

* `j = 2, i = 1, s = 1`: good-seed counts over the 8 targets =
  `[2, 2, 2, 2, 2, 2, 2, 2]` = `2^i`, out of `2^(i+j) = 8` seeds, i.e. success
  probability exactly `2^(-j) = 1/4`.
* `j = 1, i = 2, s = 2`: counts = `[4, 4, 4, 4, 4, 4, 4, 4]` = `2^i`, out of
  `2^(i+j) = 8` seeds, i.e. success probability `2^(-j) = 1/2`.

This is the numerical content of `prefixSeeded_goodSeeds_card`: the *number of
random bits* `i + j` is irrelevant; only `j` (equivalently the success
probability) governs how much is compressed.

## 4. Tightness of the Las Vegas bound

For `i = 1, j = 2, s = 1`: achieved `m * |T| = 2 * 8 = 16`, upper bound
`|R| * (2^(s+1) − 1) = 8 * 3 = 24`. Ratio `16/24 = 2/3 > 1/2`, matching the
factor-2 tightness proved in `lasVegas_bound_tight` (the theorem shows
`bound < 2 * (m * |T|)`, here `24 < 32`).

## 5. Average description length

Over all `2^4` strings of length 4:

| decompressor | Σ K | proved bound `(n−2)·|T|` = 2·16 |
|---|---|---|
| `D p = p` | 64 | 32 |
| `D p = p.reverse` | 64 | 32 |

The truth is `Σ K = 4·16 = 64`; the proved bound `n − 2` per element is a valid
but conservative estimate (`avg_description_length`). Seeded version with `2^1`
seeds `D u p = u ++ p`: `Σ Kseed = 48 = 3·16`, proved bound `(n−k−3)·|T| = 0`.
The additive constant `3` in `avg_description_length_seeded` is therefore loose
for small `n`; the theorem is only informative once `n > k + 3`, which is exactly
how it is stated.

## 6. Strict seed hierarchy (`k = 2, s = 1`)

Number of 3-bit strings compressible to 1 bit by the prefix family:

* with `2^2 = 4` seeds (`j = 2`): **8** of 8 — all strings covered;
* with `2^1 = 2` seeds (`j = 1`): **0** of 8.

The counting bound in `seed_hierarchy_strict` says at most
`2 * (2^2 − 1) = 6 < 8` are coverable by *any* family with 2 seeds, so no family
can match the 4-seed one; the concrete family achieves 0.

## 7. Las Vegas derandomization (`tryList`) on a toy example

`f p = true :: p`, seeded algorithm `A r y = y.drop 1` if `r = [true]`, else `y`.

* seed list `[[false], [true]]`: `tryList` inverts `f` on all 8 test values
  (`[true, true, …]`);
* seed list `[[false]]`: `tryList` fails on all 8 (`[false, false, …]`).

This is the behaviour formalized by `tryList_inverts`: verification lets a
deterministic algorithm harvest whichever seed happens to succeed — which is why
finite-seed Las Vegas randomness cannot beat a one-way function.

## Counterexample hunt

No counterexample was found to any statement that was subsequently formalized.
Two candidate statements were *refuted numerically before formalization* and are
therefore absent from the Lean file:

* "a Las Vegas compressor with `2^k` seeds compresses at most `2^k` times more
  objects *than the number it compresses with certainty*" — false already for the
  prefix family, where the zero-error count is 0 and the Las Vegas count is
  positive; the correct statement compares against the pigeonhole ceiling
  (`lasVegas_card_bound`);
* "average description length under `2^k` seeds is at least `n − k`" — the data
  in §5 show the additive slack cannot be removed by this argument (`n − k − 3`
  is what the layer-cake argument gives).

## Reproduction script

```lean
import Mathlib

def strs : ℕ → List (List Bool)
  | 0 => [[]]
  | n + 1 => (strs n).flatMap (fun p => [false :: p, true :: p])

def strsUpTo (n : ℕ) : List (List Bool) := (List.range (n + 1)).flatMap strs

def Kc (D : List Bool → List Bool) (L : ℕ) (y : List Bool) : Option ℕ :=
  (((strsUpTo L).filter (fun p => D p == y)).map List.length).min?

def countCompressible (D : List Bool → List Bool) (L s : ℕ) (T : List (List Bool)) : ℕ :=
  (T.filter (fun y => match Kc D L y with | some k => decide (k ≤ s) | none => false)).length

def seededPrefix (u _v p : List Bool) : List Bool := u ++ p

def goodSeedCount (j i s : ℕ) (y : List Bool) : ℕ :=
  (((strs j).flatMap (fun u => (strs i).map (fun v => (u, v)))).filter
    (fun r => decide (∃ p ∈ strsUpTo s, seededPrefix r.1 r.2 p = y))).length

#eval (List.range 6).map (fun s => ((strsUpTo s).length, 2 ^ (s + 1) - 1))
#eval (List.range 5).map (fun s => (s, countCompressible (fun p => p ++ p) 4 s (strs 4),
  2 ^ (s + 1) - 1))
#eval (strs 3).map (fun y => goodSeedCount 2 1 1 y)
#eval (strs 3).map (fun y => goodSeedCount 1 2 2 y)
#eval let i := 1; let j := 2; let s := 1;
  ((2 ^ i * (strs (j + s)).length), (2 ^ (i + j) * (2 ^ (s + 1) - 1)))
#eval let T := strs 4; ((T.map (fun y => (Kc (fun p => p) 4 y).getD 99)).sum, (4 - 2) * T.length)
#eval let T := strs 4;
  ((T.map (fun y => (Kc (fun p => p.reverse) 4 y).getD 99)).sum, (4 - 2) * T.length)
#eval let T := strs 4;
  ((T.map (fun y =>
      (((strs 1).filterMap (fun u => Kc (fun p => u ++ p) 4 y)).min?).getD 99)).sum,
   (4 - 1 - 3) * T.length)
#eval ((strs 3).filter (fun y => decide (goodSeedCount 2 0 1 y > 0))).length
#eval ((strs 3).filter (fun y => decide (goodSeedCount 1 0 1 y > 0))).length

def fTag (p : List Bool) : List Bool := true :: p
def Atoy (r y : List Bool) : List Bool := if r == [true] then y.drop 1 else y
def tryListToy (R : List (List Bool)) (y : List Bool) : List Bool :=
  match R.find? (fun r => decide (fTag (Atoy r y) = y)) with
  | some r => Atoy r y
  | none => y

#eval ((strs 3).map fTag).map (fun y => decide (fTag (tryListToy [[false], [true]] y) = y))
#eval ((strs 3).map fTag).map (fun y => decide (fTag (tryListToy [[false]] y) = y))
```

**Status of this file**: exploratory computation. Everything asserted as a
theorem is proved in `Catalog/Novelty/CompressionLasVegasOWF.lean`; the tables
above are evidence, not verification.
