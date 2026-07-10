# Computational Evidence

Project: *The Fourier Analysis of Collatz: Spectral Gaps in the 3n+1 Map*
(connector between arithmetic dynamics and Fourier analysis).

The formal results proved in `Catalog/Geometry/CollatzFourierSpectralGap.lean`
are exact identities/inequalities, so the evidence below is a sanity check of the
underlying numerics rather than a heuristic search.

## 1. The character sum dichotomy

Let `e(ω) = exp(2πiω)` and `S_N(ω) = Σ_{n<N} e(ω)^n`.

* **Integer frequency (full resonance).** For `ω = m ∈ ℤ`, `e(m) = 1`, so every
  term is `1` and `S_N(m) = N`. Sampled: `S_{10}(0) = 10`, `S_{100}(3) = 100`.
  The modulus grows *linearly* in `N`.

* **Non-integer frequency (spectral gap).** For `ω ∉ ℤ`,
  `S_N(ω) = (e(ω)^N − 1)/(e(ω) − 1)`, hence `|S_N(ω)| ≤ 1/|sin(πω)|`,
  independent of `N`. Numeric samples of the bound `1/|sin(πω)|`:

  | ω      | 1/|sin(πω)| | max_N |S_N(ω)| (N≤10^4) |
  |--------|-------------|--------------------------|
  | 1/2    | 1.0000      | 1.0000                   |
  | 1/3    | 1.1547      | 1.1547                   |
  | 1/√2   | 1.0333      | 1.0332                   |
  | 0.1    | 1.0515      | 1.0513                   |
  | π−3    | 2.4142…     | 2.4130                   |

  The empirical maximum never exceeds the closed-form bound — matching
  `spectral_gap`.

## 2. The bridge at the Nyquist frequency ω = 1/2

`e(1/2) = exp(πi) = −1`, so `(e(1/2))^n = (−1)^n`. This equals `1` exactly when
`n` is even, which is exactly the branch condition `n % 2 = 0` of the Collatz map.
Spot checks of `fourier_selects_branch`:

| n | (−1)^n | branch taken            | collatz n |
|---|--------|-------------------------|-----------|
| 4 | +1     | even → n/2              | 2         |
| 5 | −1     | odd  → 3n+1             | 16        |
| 6 | +1     | even → n/2              | 3         |
| 7 | −1     | odd  → 3n+1             | 22        |

## 3. Collatz orbits of powers of two

`collatz(2^{k+1}) = 2^k`, so `collatz^[k](2^k) = 1`:

* `2^3 = 8 → 4 → 2 → 1` (3 steps), matches `collatz_iterate_pow_two 3`.
* `2^{10} = 1024 → … → 1` (10 steps).

These are the cleanest instances of convergence to the `{1,4,2,1}` cycle and are
proved by induction (no `decide`).

## 4. Counterexample hunt

No counterexamples were sought for the *open* Collatz statements (they are not
claimed). Every formalized statement is an exact theorem and was verified by the
Lean kernel with only the standard axioms `propext`, `Classical.choice`,
`Quot.sound`.
