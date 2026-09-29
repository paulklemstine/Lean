# Angle: Lacunary / spectral — does the B-smooth indicator of a structured form have a sparse spectral signature?

## Verdict: KILL, with a measured mechanism. A real comb EXISTS and is exactly the sieve.

### Instrument (validated against trivial bounds before use)
`z(k) = |fhat(k)|^2 / (M*var f)` for real f on Z/MZ, DC removed. Null `zmax/log M = 1`.
- binary random (rho=.05): 1.01 ± 0.13 | Gaussian: 0.99 ± 0.10 | PERMUTED real: 0.99 ± 0.10
- POS comb period 6: 808 | POS 4 sinusoids: 394 | POS |sin(3)|: 1498
- Parseval checked exactly.
- **Two instrument failures caught and fixed** (both would have produced a false HANDLE):
  1. the binary normalisation M*rho*(1-rho) is WRONG for non-binary signals — it made a
     permutation null read 0.27–0.98 instead of 1.00;
  2. the notch test INFLATED z (6.2 -> 163) because zeroing coefficients shrinks var(f);
     fixed by a mask-matched null. Do not reuse the naive notch.

### Engine
Exact B-smooth indicator of F(t)=t^2-N by segmented sieve. Verified 1200/1200 against
`sympy.factorint` (0 mismatches, 3 real 41-bit semiprimes).

### Measurement (B=2000, M=32768, 41-bit real semiprimes, one instance per row)
- Raw comb is REAL: zmax/logM = 7.42 mean, up to 25.6 (null 1.00).
- Every top frequency is a small-denominator rational whose denominator is a SPLIT prime
  (1/2, 3/5, 2/7, 4/23, 8/11, ...); the one exception is d=9, a power of the split prime 3.
- Split-prime freqs carry 87–99.6% of prime-frequency energy; inert primes 0.01–0.32%.

### MECHANISM (model-free, theorem-level)
Every prime p <= B dividing t^2-N satisfies (N/p)=+1, since t^2 = N mod p is solvable.
Verified: 24,373 small-prime divisibilities, 0 non-split occurrences.
=> the comb is the SIEVE ITSELF, in Fourier clothing. It is the split set Q, re-encoded.

### Lacunarity: NO
Concentration in top 1% of frequencies = 0.056–0.081 across B = 300..12000, against a
matched null of 0.053–0.056. Flat at every B. The sequence is NOT lacunary.

### Quantity, direction, and pricing (rules 2/3/7)
- Quantity measured: E_split/E_inert, a per-instance AMPLITUDE RATIO.
- With rho held in a 5x window (n=51): corr(log E_s/E_i, Q/pi) = +0.896, corr(., rho) = +0.630.
  => governed by the SPLIT STRUCTURE, not the naive total — a SIXTH family for the closing law.
- BUT corr(log E_s/E_i, Q_full(B)) = +0.232 only. The paid GF(2) column count is at the FULL
  B; the comb is a SMALL-PRIME (p<=31) amplitude. MISMATCH with the target parameter.
- Direction: the comb rides the SAME Q that rounds 42/43 already priced. A new AMPLITUDE for an
  existing lever, not a new lever. And round 43/#447 prices the COMPLETE cost as INCREASING in
  Q, so a Q-amplifying spectral method pushes the WRONG way.
- Out-of-sample predictiveness: split-class model R^2 = +0.0014, +0.0015, +0.0006, **-0.0019**.
  ZERO out-of-sample gain over an intercept. The comb does not predict smoothness.
- Triviality: log E_s/E_i = 0.75*log(#split/#inert)^2 + 2.15, R^2 = 0.842, residual sd 0.499
  (a factor e^0.5 ~ 1.65). An O(pi(B) log B) Legendre sweep — already in the record (#447, #484) —
  predicts the comb. Honest: 16% of log-variance is NOT explained by the trivial count.
- COST, against the largest term: the FFT that measures the comb costs
  M*log2(M) vs the sieve's M*loglog(B) = **10.5x at 41 bits, 24.1x at 160, 98.9x at 1024,
  1030x at 16384 bits**. Monotone increasing: the method is more expensive the larger N gets,
  because it pays log M for a signal whose useful content is only the period-p comb.

### Novelty (record AND tracker checked)
`grep periodogram | lacunar | comb | Fourier decay | spectral signature` over the whole
FactoringBarriers directory: ZERO hits. All 28 tracker issues matching
spectral/fourier/lacunary concern other objects — Berggren matrices, ML participation ratios,
Walsh spectra of FACTOR BITS (#69), mod-exp window statistics (#78). None is the smoothness
indicator of a structured form. The angle is new; the RESULT is a kill.
