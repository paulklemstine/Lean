# Computational Evidence: The P vs NP of Cooking

We model a recipe `R` by two natural numbers: cooking time `C(R)` and verification
time `V(R)`. Classes:

- **Quick** (`C = V`): salads / assemble-and-serve (`P = NP` in the kitchen).
- **Traditional** (`V < C`): cooking beats tasting (`P ≠ NP`).
- **Overhard** (`C < V`): verifying is harder than cooking (`NP`-hard, e.g. soufflé).

## 1. Small-case sample table (C, V, ratio C/V, class)

| Dish            | C   | V  | C/V   | class        |
|-----------------|-----|----|-------|--------------|
| Salad           | 5   | 5  | 1.00  | quick        |
| Cheese plate    | 3   | 3  | 1.00  | quick        |
| Beef stew       | 180 | 3  | 60.0  | traditional  |
| Roast chicken   | 90  | 4  | 22.5  | traditional  |
| Soufflé         | 20  | 45 | 0.44  | overhard     |
| Fugu (pufferfish)| 30 | 120| 0.25  | overhard     |

Observations matching the conjecture:
- Quick recipes have `C/V = 1` exactly (ratio on the diagonal).
- Traditional recipes have `C/V > 1` (often `C >> V`).
- Overhard recipes have `C/V < 1`.

These three facts are proved in Lean as `IsQuick.ratio_eq_one`,
`IsTraditional.ratio_gt_one`, `IsOverhard.ratio_lt_one`.

## 2. Composition (`seq`) is additive

For `seq R S` we have `C(seq R S) = C(R)+C(S)` and `V(seq R S) = V(R)+V(S)`.
Checked on samples, e.g. `seq stew salad = (185, 8)`, ratio `23.1` (still traditional),
consistent with `IsTraditional.seq_physical`.

## 3. Counterexample hunt for the Batch Quickness Theorem

Claim: a batch of **physical** recipes (`V ≤ C`) is quick iff every dish is quick.

- Physical + all quick menus tested (e.g. `[salad, cheese]`, C=8, V=8): batch quick. ✓
- Physical + one traditional (`[salad, stew]`, C=185, V=8): batch not quick. ✓
- **Physicality is necessary.** Drop it: `[stew=(180,3), souffle=(20,45)]` gives
  C=200, V=48, batch traditional (not quick), so no clean cancellation here; but the
  designed counterexample `[(1,0)=fast, (0,1)=overhard]` gives C=1, V=1 → batch quick
  even though the second dish is **not** quick. This confirms the physicality
  hypothesis in `batch_quick_iff` cannot be removed: an overhard dish can be masked by
  an extra-fast one. ✓

No counterexample to the *hypothesized* theorem (with physicality) was found; the only
"counterexample" is to the version *without* the hypothesis, which we deliberately
excluded.

## 4. OEIS

No integer sequence is central to the statements (the content is structural/algebraic
rather than enumerative), so no OEIS lookup applies.
