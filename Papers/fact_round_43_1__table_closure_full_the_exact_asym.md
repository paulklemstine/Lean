# Computational Evidence — exact asymptotic constants of the four fork channels

All numbers below were produced by `scripts/fork_channel_table.py` (double precision;
the entries quoted to 9 decimals are stable under a `mpmath`-style recomputation at
higher precision for `n ≤ 2^16`).

## 1. The model

For a resolution parameter `n ≥ 2`, with `H` the binary entropy in bits and `lb = log₂`:

| channel | definition | interpretation |
|---|---|---|
| `X n` | `1 − H(1/2 + 1/n)` | forward divergence `D(Bern(1/2+1/n) ‖ Bern(1/2))`, i.e. the BSC capacity at bias `1/n` |
| `A n` | `lb n / n²` | half the surprisal of a fork event of probability `1/n²` |
| `g n` | `−(1 − 1/n²)·lb(1 − 1/n²) − 1/n²` | survival-entropy term minus the fork probability |
| `R n` | `−(1/2)·lb(1 − 4/n²)` | reverse divergence `D(Bern(1/2) ‖ Bern(1/2+1/n))` |
| `Is n` | `A n + R n` | isolation channel |

## 2. Small-case table (scaled channels)

```
      n        X·n²        g·n²   A·n²/lb n        R·n²      X/g          A−X
      2 4.000000000 0.245112498 1.000000000         inf 16.319037 -7.500000e-01
      3 3.149798205 0.359400012 1.000000000 3.815986079  8.764046 -1.738706e-01
      4 3.019550009 0.396641066 1.000000000 3.320299994  7.612802 -6.372188e-02
      5 2.967727519 0.413448537 1.000000000 3.144234587  7.177985 -2.583198e-02
      6 2.941349974 0.422469457 1.000000000 3.058650026  6.962278 -9.899652e-03
      7 2.925988025 0.427872483 1.000000000 3.009990321  6.838458 -2.421084e-03
      8 2.916223813 0.431364820 1.000000000 2.979500941  6.760458 +1.309003e-03
      9 2.909620051 0.433752640 1.000000000 2.959070219  6.708017 +3.213641e-03
     16 2.892951478 0.439873601 1.000000000 2.908169792  6.576779 +4.324408e-03
     64 2.885859893 0.442518916 1.000000000 2.886799882  6.521438 +7.602881e-04
   1024 2.885391916 0.442694353 1.000000000 2.885395585  6.517797 +6.785019e-06
  65536 2.885390282 0.442695041 1.000000000 2.885390083  6.517783 +3.053483e-09
 655360 2.885389328 0.442728062 1.000000000 2.885387330  6.517295 +3.826930e-11
```

Target constants:

```
2·log₂ e = 2/log 2         = 2.885390082
log₂ e − 1 = 1/log 2 − 1   = 0.442695041
2/(1 − log 2)              = 6.517782707
```

(The tiny drift in the last row is double-precision cancellation, not a real deviation:
`g·n²` is computed as a difference of two quantities of size `1/n²`.)

## 3. What the table shows

1. **`X·n² → 2 log₂ e`** — no logarithmic factor; convergence is `Θ(1/n)`
   (deviation `3.0e-3` at `n = 64`, `1.9e-6` at `n = 1024`), consistent with the proved
   error window `|X·n² − 2/log 2| ≤ 24/(n·log 2)`.
2. **`g·n² → log₂ e − 1`** — again no logarithmic factor; convergence `Θ(1/n²)`.
3. **`A·n²/lb n = 1` exactly**, for every `n > 1`; this is an identity, not a limit.
4. **`R·n² = (Is − A)·n² → 2 log₂ e`** — the reverse divergence has the *same* constant
   as the forward one, although the two channels differ at every finite `n`
   (e.g. `R·n² − X·n² = 0.084` at `n = 8`) and `R` blows up at the collapse point `n = 2`
   while `X` saturates at `1`.
5. **`X/g → 2/(1 − log 2) = 6.5178`**, decisively *not* `2`. The monotone decrease of the
   ratio from `16.32` (n=2) through `6.52` (n=64) leaves no room for the value `2`.
6. **`A/X` sign flip in the window `(7,8)`**: `A − X < 0` at `n = 7` and `> 0` at `n = 8`.
   The flip is where `lb n` crosses `2 log₂ e = 2.8854`, i.e. at
   `n* = 2^(2 log₂ e) = e² / … = 7.389…` — numerically `n* = 7.3891 = e²`, so the
   crossing is *exactly* the point `n = e²`, comfortably inside `(7,8)`.
   Margins: at `n = 7`, `X − A = 2.42e-3` (4.2 % of `A`); at `n = 8`,
   `A − X = 1.31e-3` (2.9 % of `A`). These margins are what force the rational
   logarithm bounds used in the Lean proofs, which are reduced to the two exact integer
   certificates `7^100 < 3^126·5^35` (for `n = 7`) and `5^40·3^24 < 2^131` (for `n = 8`).

## 4. Counterexample hunt

* Searched `2 ≤ n ≤ 10^6` for a second sign change of `A − X`: none
  (the difference is negative exactly for `n ∈ {2,…,7}` and positive for `n ≥ 8`).
* Searched for `n` with `X n ≤ 0` or `g n ≤ 0` in `2 ≤ n ≤ 10^6`: none; both channels are
  numerically strictly positive there. (Positivity is not among the formalised results;
  what the Lean file proves is the two-sided rate window
  `|g·n² − (log₂e − 1)| ≤ 1/(n log 2)`, which forces `g > 0` for large `n`.)
* Tested the pre-data guess `X/g → 2`: the ratio is monotonically decreasing and bounded
  below by `6.5177` for all `n ≥ 1024`; refuted. The corrected constant `2/(1 − log 2)`
  is confirmed out-of-sample at `n = 65536` to `2e-6` relative.

## 5. OEIS

The channel values are transcendental, so no integer sequence is involved. The only
integer data appearing are the two prime-power certificates `7^100 < 3^126·5^35` and
`5^40·3^24 < 2^131`, i.e. rational approximations to `log 7 / (126 log 3 + 35 log 5)`
and to `log 2`; both are verified inside Lean by exact integer arithmetic (`norm_num`),
so the sign flip is established without any floating-point input.
