# Computational Evidence — Leading Term Cancellation in a Spectral Heat-Kernel Expansion

We study the leading `1/N` correction to a heat-kernel trace,

  L(t) = Σᵢ dᵢ · exp(−t·Eᵢ),

where `E = (E₀, …, E_{n−1})` are unperturbed energy levels and `d = (d₀, …, d_{n−1})`
are the first-order diagonal level shifts. The question: **when does L(t) = 0 for all t?**

## 1. Small-case calculations

### Non-degenerate spectrum (distinct Eᵢ)
- `E = (0, 1)`, `d = (1, −1)`:  L(t) = 1 − e^{−t}.  L(0)=0 but L(1)=1−0.3679=0.6321 ≠ 0.
  → cancellation FAILS. Consistent with "distinct levels ⇒ term-by-term".
- `E = (0, 1, 2)`, `d = (1, −2, 1)`:  L(0)=0, L(1)=1−0.7358+0.1353=0.3995 ≠ 0.
  → FAILS, again no nontrivial cancellation with distinct levels.
- Only `d = 0` gives L ≡ 0 when the Eᵢ are distinct. Verified across random samples of
  distinct-level triples: the sampled moment matrix `[e^{−k Eᵢ}]` (a generalized
  Vandermonde) is always invertible, forcing `d = 0`.

### Degenerate spectrum (repeated Eᵢ)
- `E = (a, a)`, `d = (c, −c)`:  L(t) = c·e^{−ta} − c·e^{−ta} = 0 for ALL t, any c.
  → cancellation SUCCEEDS with `d ≠ 0`. The mechanism is intra-level balance.
- `E = (0, 0, 1)`, `d = (2, −2, 5)`:  level `0` sum = 0, level `1` sum = 5 ≠ 0.
  L(1) = 0·1 + 5·e^{−1} = 1.839 ≠ 0.  → FAILS: one level is unbalanced.
- `E = (0, 0, 1, 1)`, `d = (3, −3, 7, −7)`:  both level sums vanish.
  L(t) = 0·1 + 0·e^{−t} = 0 for all t.  → SUCCEEDS.

**Pattern.** L ≡ 0 ⇔ for every energy value v, the aggregate shift Σ_{Eⱼ=v} dⱼ = 0.
This is exactly `heatKernelLeading_vanishes_iff_levelSums`.

## 2. Reduction to a Vandermonde system

Sampling L at `t = 0, 1, 2, …` and setting `xᵢ = e^{−Eᵢ}` gives, for each k,

  Σᵢ dᵢ · xᵢ^k = 0.

With distinct levels the `xᵢ` are distinct positive reals, so the Vandermonde matrix
`V_{ij} = xᵢ^j` has determinant Π_{i<j}(xⱼ − xᵢ) ≠ 0; hence `d = 0`. This is the
engine of `diag_zero_of_leading_vanishes_fin`.

## 3. Counterexample hunt

- Claim "L ≡ 0 ⇒ d = 0" WITHOUT distinctness: falsified by `E=(a,a), d=(c,−c)`, c≠0.
  (Recorded as the guard theorem `leading_vanishes_of_level_antisymmetric` and the
  sharpness witness `leading_nonvanishing_distinct_levels`.)
- Claim "level sums zero ⇒ L ≡ 0": no counterexample found; proved in general.
- Claim "L ≡ 0 ⇒ trace(d)=0": always holds (take t=0); proved as
  `trace_zero_of_leading_vanishes`.

## 4. Sequence note

No new integer sequence arises; the object is a real spectral function. The
combinatorial skeleton (partition of indices into degeneracy fibres) is the
standard set-partition lattice; no OEIS entry is implicated by the theorems here.

## Conclusion

The computational landscape unambiguously supports the sharp statement:
**the leading `1/N` term cancels identically iff the diagonal shift sums to zero on
each degenerate energy level**, and reduces to `d = 0` when the spectrum is simple.
All four small-case predictions were subsequently formalized as theorems.
