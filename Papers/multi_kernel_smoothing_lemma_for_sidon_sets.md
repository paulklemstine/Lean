# Computational Evidence — Sidon multi-kernel support counts

All computations below were run over `Finset ℤ` (exact integer arithmetic, no
floating point). A finite set `s` is *Sidon* (a `B₂` set) when all pairwise sums
are distinct.

## 1. Small-case calculations

For the power-of-two Sidon sets `s = {2⁰, …, 2^{k-1}}` (a genuine Sidon family):

| `s`            | `k=|s|` | `|s+s|` | `|s-s|` | `|s|(|s|+1)` vs `2|s+s|` | `|s|²-|s|+1` vs `|s-s|` |
|----------------|---------|---------|---------|--------------------------|------------------------|
| `{1}`          | 1       | 1       | 1       | `2 = 2·1`                | `1 = 1`                |
| `{1,2}`        | 2       | 3       | 3       | `6 = 2·3`                | `3 = 3`                |
| `{1,2,4}`      | 3       | 6       | 7       | `12 = 2·6`               | `7 = 7`                |
| `{1,2,4,8}`    | 4       | 10      | 13      | `20 = 2·10`              | `13 = 13`              |
| `{1,2,4,8,16}` | 5       | 15      | 21      | `30 = 2·15`              | `21 = 21`              |

Both exact support laws hold on every case:

* **Sum kernel:**   `2·|s + s| = |s|·(|s| + 1)`.
* **Difference kernel:** `|s - s| = |s|² - |s| + 1`, i.e. `|s-s| + |s| = |s|²+1`.

## 2. The conservation law

Checking `2·|s + s| = |s - s| + 2·|s| - 1`:

| `k` | `2|s+s|` | `|s-s| + 2|s| - 1` |
|-----|----------|--------------------|
| 1   | 2        | `1 + 2 - 1 = 2`    |
| 2   | 6        | `3 + 4 - 1 = 6`    |
| 3   | 12       | `7 + 6 - 1 = 12`   |
| 4   | 20       | `13 + 8 - 1 = 20`  |
| 5   | 30       | `21 + 10 - 1 = 30` |

The identity holds exactly in every case.

## 3. Counterexample hunt (necessity of the Sidon hypothesis)

The individual support laws are *false* for non-Sidon sets, confirming the Sidon
hypothesis is load-bearing:

| non-Sidon `s` | `k` | `|s-s|` | `|s|²-|s|+1` | `2|s+s|` | `|s|(|s|+1)` |
|---------------|-----|---------|--------------|----------|--------------|
| `{1,2,3,4}`   | 4   | 7       | 13           | 14       | 20           |
| `{1,2,3,5}`   | 4   | 9       | 13           | 16       | 20           |
| `{0,1,3,4}`   | 4   | 9       | 13           | 18       | 20           |

For every non-Sidon sample the difference-set count drops strictly below the
maximal value `|s|² - |s| + 1`. This is exactly the content of the *sharp
characterisation* proved in `DifferenceKernel.lean`: a nonempty set is Sidon
**iff** `|s - s| + |s| = |s|² + 1`.

## 4. Edge cases

* **Empty set:** `|∅ - ∅| = 0`, while `|s|² - |s| + 1 = 1`. The formula requires
  nonemptiness; this hypothesis is retained in all statements.
* **Singletons:** `k = 1` gives `|s+s| = |s-s| = 1`, and all three laws hold.

## 5. Sequence note

The difference-set sizes `1, 3, 7, 13, 21, 31, …` for `k = 1,2,3,…` follow
`k² - k + 1` (centered polygonal-type numbers, OEIS A002061), and the sum-set
sizes `1, 3, 6, 10, 15, …` are the triangular numbers `k(k+1)/2` (OEIS A000217).
Both match the proved closed forms.
