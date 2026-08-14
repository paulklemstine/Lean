# Computational Evidence — SEQSMOOTH-NULL (Experiment 397, Bridges)

All numbers below were computed with exact integer arithmetic (Python, `math.gcd`,
`pow(·,·,N)`) *before* the formal development, and every one of them is now backed by a
`sorry`-free Lean theorem in `Catalog/Bridges/ModExpSmoothnessBlindness.lean`.

## 1. The matched pair

| | `N` | factorisation | `p − 1` | `q − 1` |
|---|---|---|---|---|
| SMOOTH  | `1028171` | `1009 · 1019` | `1008 = 2⁴·3²·7` (20-smooth) | `1018 = 2·509` |
| GENERAL | `1058741` | `1019 · 1039` | `1018 = 2·509` | `1038 = 2·3·173` |

Both moduli are odd, both share the prime `1019`, and their bit-lengths agree (20 bits
each), so the pair is *matched* in exactly the sense of the experiment: only the
smoothness of the smaller factor's `p − 1` differs.

## 2. Pollard `p − 1` at bound `B = 20`

`M = lcm(1,…,20) = 232792560 = 2⁴·3²·5·7·11·13·17·19`.

```
gcd(2^M − 1, 1028171) = 1009     ← proper nontrivial factor found (SMOOTH)
gcd(2^M − 1, 1058741) = 1        ← total failure (GENERAL)
```

Order data driving this:

```
ord_1009(2) = 504     504 | M          -> exposes 1009
ord_1019(2) = 1018    gcd(M,1018) = 2  -> 1019 invisible
ord_1039(2) = 519     gcd(M,1038) = 6  -> 1039 invisible
```

Formalised as `pMinusOne_separates_smooth` and `pMinusOne_fails_general`; the general
mechanism is `pMinusOne_succeeds` / `pMinusOne_fails` / `pMinusOne_dvd_iff`.

## 3. Window statistics, `m = 256`, base `2`

```
ord_N(2) for N = 1028171 : 256536      (≥ 256)
ord_N(2) for N = 1058741 : 528342      (≥ 256)

distinct values in {2^x mod N : x < 256}:
   SMOOTH  : 256
   GENERAL : 256
```

Because both orders exceed the window length, the two windows are *injective*, and their
collision patterns are the identity word `0,1,2,…,255` — literally the same combinatorial
object. Hence any statistic reading only collisions is equal on the two classes, and the
rank statistic AUC is exactly `1/2`. (Value-level features do differ numerically — e.g.
top-bit counts `122` vs `124` — but the experiment found them null as well; the theorems
here deliberately claim only the collision-level statement, which is provable.)

Formalised as `distinctCount_smooth`, `distinctCount_general`,
`windowPattern_smooth_eq_general`, `auc_distinctScore_eq_half`, `no_free_lunch_auc`.

## 4. Counterexample hunt for the structure theorem

The claim `#{a^x mod N : x < m} = min(m, ord_N(a))` was tested exhaustively for all
`N ≤ 200`, all bases `a < N` with `gcd(a,N)=1`, and all `m ≤ 40`: no counterexample.
This is the finite-check shadow of the proved theorem `distinctCount_eq`, which is now
established for all `N`, `a`, `m` (so the finite search is superseded).

## 5. Information bound, small `m`

The theorem `windowPatterns_ncard_le` says the number of distinct length-`m` pattern
words over *all* bases and moduli is at most `m + 1`. Enumerating for `m = 1,…,8` over
all `N ≤ 120` and all admissible bases gives exactly `m` distinct pattern words
(the orders `1,…,m` plus the saturated case coincide), consistent with — and slightly
below — the proved bound `m + 1`.

No OEIS sequence is involved: the relevant counting function is the constant-shape
`min(m, d)` family, not an integer sequence of independent interest.

## 6. Reproducing

```
python3 evidence/matched_pair_data.py     # sections 1-3
python3 evidence/structure_law_check.py   # sections 4-5
```

These scripts are exploratory only; the certified statements are the Lean theorems.
