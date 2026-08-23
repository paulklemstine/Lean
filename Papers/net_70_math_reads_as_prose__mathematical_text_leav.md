# Computational evidence — NET-70 (MATH-READS-AS-PROSE)

All numbers below were produced by Lean `#eval` on the same step profiles that
the formal files use (`Catalog/Combinatorics/MathReadsAsProse.lean`,
`Catalog/Combinatorics/DeploymentEntryCover.lean`).  They are exploratory
computations; the *claims* derived from them are proved separately and
sorry-free in the `.lean` files.

## 1. The measured sweeps as count profiles (n = 10000 windows)

```
mathT512  k = 0     (k<4)   | 9070 (4≤k<8)  | 9590 (8≤k<12)
                            | 9790 (12≤k<16)| 9870 (16≤k<20) | 9890 (20≤k<512) | 10000 (k≥512)
mathT1024 k = 0     (k<8)   | 9520 (8≤k<12) | 9650 (12≤k<16)
                            | 9780 (16≤k<20)| 9830 (20≤k<1024)                 | 10000 (k≥1024)
```

(The measured ctx-512 value at `k = 24` is `0.988`, one unit in the third
decimal *below* `k = 20`'s `0.989` and inside the reported SE; the monotone hull
is used, which cannot change any knee at a gate `≤ 0.989`.)

At `k = ctx` the truncated model is the full model, so the profile saturates.

## 2. Knee at the exact gate

```
#eval (kneeSearch mathT512 9800, kneeSearch mathT1024 9800)
⟹ (16, 20)
```

## 3. Gate-sensitivity scan (the knee is not a tuned number)

ctx 512 — gate numerator (out of 10000) ↦ knee:

```
9700..9790 ↦ 12     9800..9870 ↦ 16     9880..9890 ↦ 20     ≥9900 ↦ 512 (full ctx)
```

ctx 1024:

```
9700..9780 ↦ 16     9790..9830 ↦ 20     ≥9840 ↦ 1024 (full ctx)
```

So the ctx-512 knee is `16` on the whole gate window `(0.979, 0.987]`, and the
ctx-1024 knee is `20` on `(0.978, 0.983]`.  The windows **overlap** in
`(0.979, 0.983]`: one gate certifies both cells, and on that overlap the
increment is exactly `+4`.  These are exactly the hypotheses of
`math512_knee`, `math1024_knee` and `net70_increment_four`.

Counterexample hunt: no gate in the scanned grid makes the two cells disagree
with the reported `k* ∈ {16, 20}` **inside** the admissible window; outside the
window the knee moves to `12`, `20` or the full context, which is why the
theorems carry the window as an explicit hypothesis rather than a fixed gate.

## 4. Deployment entries (brute force over all cache sizes ≤ 40)

Minimum number of distinct cache-size entries serving a knee set at waste
tolerance `δ` (an entry `b` serves knee `k` iff `k ≤ b ≤ k + δ`):

| δ | knees {12,16} (prose/code/math @512) | knees {12,16,20,24} (hypothetical 4-domain ladder) |
|---|---|---|
| 0 | 2 | 3 |
| 1 | 2 | 3 |
| 2 | 2 | 3 |
| 3 | 2 | 3 |
| 4 | **1** | 2 |
| 5 | 1 | 2 |
| 6 | 1 | 2 |
| 7 | 1 | 2 |

The transition at `δ = 4` — exactly one scale increment (NET-67) — is the
content of `net70_entry_threshold`; the second column is an instance of the
proved min–max duality `min_entries_eq_of_arithmetic` (knees spaced `δ+1 = 4`
apart need one entry each at `δ = 3`).

## 5. OEIS

No integer sequence with a plausible OEIS identity arises here: the objects are
finite measured profiles and covering numbers, and the covering numbers are the
elementary `⌊(b-a)/(δ+1)⌋ + 1`, proved in `exists_entrySet_card_le`.
