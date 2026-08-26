# Computational Evidence — exp589 spike-origin, positional layer

All computations below were run with exact natural-number arithmetic inside Lean
(`#eval`, no floating point).  They are *exploratory* evidence; the statements that are
actually **verified** are the theorems in `Catalog/Cryptography/SpikeOrigin*.lean`, which
compile with no `sorry` and depend only on the standard axioms.

Notation: `s = ⌊√N⌋`, window `j ∈ (s, 3s]`, residue `v(j) = j² − N`, normalised position
`u = (j − s)/(2s) ∈ (0, 1]`, full-size threshold `T = 2⁹⁵`, cut point
`m = ⌊√(N + T − 1)⌋` (largest window point whose residue is still sub-`T`).

## 1. Where the sub-2⁹⁵ band ends, for real 96-bit moduli

Excluded fraction of the window, `(m − s) / (2s)`, in basis points:

| N | (m−s)/(2s) |
|---|---|
| `2^95` | 0.2071 |
| `2^95 + 12345678901234567` | 0.2071 |
| `3·2^94` | 0.1454 |
| `7·2^93 + 13` | 0.1267 |
| `2^96 − 1` | 0.1123 |
| `(2^48−1)²` | 0.1123 |
| `199032864766431²` | 0.2071 |
| `5·2^93 + 2^60` | 0.1708 |

Every value lies in `[0.1123, 0.2072]`, i.e. inside the interval
`((√6 − 2)/4, (√2 − 1)/2]` that is **proved** in `SpikeOrigin.crossingPos_gt` /
`SpikeOrigin.crossingPos_le`, and the extreme values `0.2071 = (√2 − 1)/2` and
`0.1123 ≈ (√6 − 2)/4` are attained at `N = 2⁹⁵` and `N → 2⁹⁶⁻` exactly as the continuum
formula `u₀(N) = (√(1 + 2⁹⁵/N) − 1)/2` predicts.  The reported kept-support left edge
`u ≈ 0.110–0.114` matches the lower endpoint `(√6 − 2)/4 = 0.11237…`.

The discrete two-sided bound `11 % ≤ (m − s)/(2s) ≤ 21 %` is proved in
`SpikeOrigin.lowBand_fraction_bounds`.

## 2. Counterexample hunt for the degeneracy claim (small-scale analogue)

For the analogue at scale `k` — `N ∈ [2^(2k−1), 2^(2k))`, threshold `2^(2k−1)` — count the
first-decile points whose residue reaches the threshold:

| k (bits of N = 2k) | first-decile points with `v ≥ 2^(2k−1)` |
|---|---|
| 5 (10-bit) | 0 |
| 6 (12-bit) | 0 |
| 7 (14-bit) | 0 |
| 8 (16-bit) | 0 |

Zero violations, in agreement with `SpikeOrigin.firstDecile_resid_lt_two_pow_95` and its
scale-free source `resid_lt_of_firstDecile_scalefree`.

## 3. Where the scale-free constants actually break

The scale-free bounds carry a hypothesis `N ≥ 2¹⁶`.  Exhaustive scan over `N < 300000`:

* `100·v ≥ 45·N` occurs for 2348 moduli below 20000; the **largest** violating modulus is
  `N = 36482` (`s = 191`, `j = 230`, `v = 16418`, `100 v = 1641800 ≥ 1641690 = 45 N`).
* `2·v ≥ N` occurs only for small moduli; the **largest** violating modulus is `N = 962`
  (`s = 31`, `j = 38`, `v = 482`).

So the hypothesis `2¹⁶ ≤ N` is close to sharp for the `0.45` constant (true threshold
36483) and generous for the one-bit-drop statement (true threshold 963).  Both witnesses
are formalised as theorems: `scalefree_bound_needs_size_hypothesis` and
`bitdrop_needs_size_hypothesis`.

## 4. How small the tiny channel gets

At the extreme left end `j = s + 1` the residue is `≤ 2√N + 1`; for the sample moduli
above this is a number of about 48–49 bits versus 96 bits for `N` — i.e. the window really
does contain residues of roughly half the bit-length of the modulus.  Proved in
`SpikeOrigin.resid_left_end_le`.

## 5. OEIS

No integer sequence in the sense of an OEIS entry arises here: the objects are
modulus-dependent thresholds (`⌊√(N + 2⁹⁵ − 1)⌋`) rather than a single sequence, so no OEIS
lookup was performed.
