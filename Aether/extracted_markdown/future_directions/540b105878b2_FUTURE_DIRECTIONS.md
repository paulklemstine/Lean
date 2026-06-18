# Future Directions — The Fourier Analysis of Collatz: Spectral Gaps in the 3n+1 Map

Companion to `Catalog/Bridges/CollatzFourierSpectralGap.lean`.

## Synthesis

This cycle turned the slogan "the Collatz conjecture is a spectral gap problem" into a
set of *provable* statements about the additive exponential sum
`F_T(ω) = Σ_{n<N} e(ω·T(n))`, where `e(x) = exp(2πi x)`. The central structural insight
is a clean **branch decomposition in Fourier coordinates** that exactly mirrors the
log-coordinate branch decomposition used in the catalog's tropical/Bellman treatment
(`Computation.CollatzTropicalContraction`, even branch `x ↦ x − log 2`, odd branch
`x ↦ x + log(3/2)`). Where the tropical file linearizes Collatz to obtain a *metric
contraction*, this file linearizes it via characters to obtain *cancellation*. The even
branch `T(2m) = m` collapses the Fourier sum to a pure geometric series, and we proved
its magnitude is bounded **independently of N** (`evenBranch_bounded`): energy `O(1)`,
far below the `√N` "gap" threshold. This is the rigorous core of the "Collatz is mixing
in Fourier" claim — but only on the even half.

What failed, productively, was the *naive* form of the conjecture. The DC component is a
hard resonance: `F_T(0) = N` (`F_zero_eq`, `F_zero_resonance`), so "‖F_T(ω)‖ < √N for
*all* ω" is simply false (`no_uniform_spectral_gap`); the gap can only be asked for at
*non-integer* (irrational) frequencies. More importantly, the Critic found that the
even-branch gap is shared verbatim by the **5n+1 map** (`collatz5_evenBranch_bounded`),
which is *not* believed to converge. So an even-branch spectral gap **cannot** certify
convergence — the proposed "gap ⇒ convergence" implication is false on the even branch.

The emergent structural lesson: all the difficulty of Collatz lives on the **odd
branch** `n ↦ 3n+1`, which couples the summation index `n` to the summand multiplicatively
and breaks the geometric/root-of-unity cancellation that makes the even branch trivial.
The rational shadow of true mixing — perfect root-of-unity cancellation over a full
period — is proved unconditionally (`spectral_gap_full_period`), giving a concrete target
to lift to irrational frequencies.

## Results Summary

- `e_add`, `e_norm`, `e_zero`, `e_natMul`, `e_intCast`, `e_eq_one_iff`: proved — the
  additive character `e(x)=exp(2πi x)` is a unit-modulus homomorphism with integer kernel
  (the harmonic-analysis toolkit underpinning everything below).
- `F_zero_eq`: proved — DC component `F_T(0) = N`; all energy sits at frequency 0.
- `F_norm_le`: proved — universal ceiling `‖F_T(ω)‖ ≤ N` from the triangle inequality.
- `F_zero_resonance`: proved — the ceiling is saturated at ω=0, `‖F_T(0)‖ = N`.
- `no_uniform_spectral_gap`: proved (disproof) — the naive "`‖F_T(ω)‖ < √N` for all ω"
  is false; ω=0 is an unavoidable resonance for `N ≥ 2`.
- `spectral_gap_full_period`: proved — perfect cancellation `Σ_{k<q} e((p/q)·k) = 0`
  whenever `q ∤ p`; the exact root-of-unity mechanism of the spectral gap at rationals.
- `evenBranch_geometric`: proved — on even inputs the Collatz–Fourier sum is geometric.
- `evenBranch_bounded`: proved — hence bounded by `2/‖e(ω)−1‖`, independent of N: a
  genuine `O(1)` spectral gap on the even branch.
- `collatz5_evenBranch_bounded`: proved (Critic's counterexample) — the identical bound
  holds for the non-convergent 5n+1 map, so the even-branch gap cannot detect convergence.
- `irrational_spectral_gap`: conjecture (`sorry`) — square-root cancellation of the full
  sum at irrational ω; the deep mixing statement, obstructed entirely by the odd branch.

## Research Directions

### Direction 1: Quantitative even-branch gap with explicit Dirichlet-kernel constant
**Hypothesis**: For non-integer `ω`, the even-branch sum satisfies the sharper bound
`‖Σ_{k<N} e(ω·T(2(k+1)))‖ ≤ 1/|sin(π ω)|`, and this is asymptotically tight as `N → ∞`
along the convergents of `ω`.
**Test**: Replace `2/‖e(ω)−1‖` by `1/|sin(πω)|` using `‖e(ω)−1‖ = 2|sin(πω)|`
(`Complex.norm_exp_ofReal_mul_I_sub_one`-style identities) and prove the upgraded
`evenBranch_bounded`; check tightness by evaluating at `ω = 1/N`.
**Why now**: `evenBranch_bounded` already reduces everything to `‖e(ω)−1‖`; only the
half-angle identity is missing.
**If true**: it pins the even-branch gap width to the classical Dirichlet kernel,
linking Collatz Fourier sums to equidistribution constants.
**If false**: the geometric bound is not the true growth rate, signaling a subtler
cancellation we have mis-modeled.

### Direction 2: The odd branch is the sole obstruction — isolate and bound it
**Hypothesis**: Writing `F_T(ω) = E_N(ω) + O_N(ω)` (sum over even resp. odd `n`), the even
part `E_N` is `O(1)` (proved in spirit) and the *entire* growth of `‖F_T(ω)‖` comes from
`O_N(ω) = Σ_{n odd, n<N} e(ω(3n+1))`, which is itself a geometric sum in `e(3ω)`, hence
also `O(1/‖e(3ω)−1‖)` for non-integer `3ω`.
**Test**: Prove `oddBranch_geometric` (for odd `n`, `T(n)=3n+1`, an arithmetic progression
so `e(ω(3n+1))` is geometric in `e(6ω)` over `n = 1,3,5,…`) and an `oddBranch_bounded`
analogue; then combine to bound the *full* `F_T(ω)` for ω with `ω, 3ω ∉ ℤ`.
**Why now**: the key realization of this cycle is that BOTH raw branches are arithmetic
progressions in `n`, so the same `geom_sum_eq` machinery that closed the even branch
should close the odd branch — the difficulty is only in the *interleaving*.
**If true**: it yields an unconditional `O(1)` bound on the *static-branch* `F_T(ω)` and
shows the genuine difficulty is the *data-dependent* choice of branch (parity of the
running orbit), not the arithmetic of either branch.
**If false**: the odd progression resists `geom_sum_eq`, exposing exactly which
arithmetic coupling breaks Fourier cancellation.

### Direction 3: Orbit-indexed transform — where the real Collatz difficulty enters
**Hypothesis**: Define the *orbit* transform `G_n(ω) = Σ_{j<τ(n)} e(ω·T^[j](n))` along the
trajectory of a single `n` (τ = stopping time). Then `G_n` has a spectral gap
`‖G_n(ω)‖ = o(τ(n))` for irrational ω **iff** the orbit is non-eventually-periodic,
making the spectral gap genuinely equivalent to "no nontrivial cycle through `n`".
**Test**: Formalize `G_n`, prove the easy direction (an eventually-periodic orbit forces a
resonance at the rational ω matching its period, so `‖G_n(ω)‖ = Ω(τ)` there), then attack
the converse for specific small `n` by `decide`/computation.
**Why now**: `spectral_gap_full_period` already proves that periodicity creates a rational
resonance; the orbit transform is the natural object where that resonance becomes a
cycle-detector.
**If true**: it recasts "no nontrivial Collatz cycle" as a per-orbit spectral-gap
statement — a falsifiable, computable reformulation.
**If false**: spectral gaps see periodicity but not divergence, clarifying the limits of
the Fourier bridge.

### Direction 4: Spectral separation of 3n+1 vs 5n+1 via a cycle-resonance fingerprint
**Hypothesis**: Although the even-branch gaps of 3n+1 and 5n+1 coincide
(`collatz5_evenBranch_bounded`), the *orbit* transforms differ: the 5n+1 map has the known
cycle `13 → 66 → 33 → … → 13`, which forces an exact rational resonance
`‖G^{5}_{13}(p/period)‖ = period` that the 3n+1 orbit of 13 (which reaches 1) does not
exhibit.
**Test**: Compute both orbit transforms for `n = 13` at the resonant rational frequency
and prove the 5n+1 value equals its period while the 3n+1 value is strictly smaller
(a finite `decide`/`norm_num` computation once `G_n` is defined).
**Why now**: this cycle proved the two maps are *Fourier-indistinguishable on the even
branch*; the orbit transform is the minimal upgrade that should *distinguish* them, and we
already have an explicit 5n+1 cycle to target.
**If true**: it gives the first formal Fourier invariant separating a convergent from a
non-convergent accelerated-Collatz map.
**If false**: even orbit-level Fourier data fails to separate the maps, a strong negative
result about the spectral-gap programme.

### Direction 5: L² (Parseval) energy budget instead of L∞ gaps
**Hypothesis**: Summing `|F_T(k/N)|²` over `k = 0,…,N−1` (a discrete Parseval budget)
equals `N · #{collision pairs}` and is dominated by the DC term `N²`, so the *average*
non-DC gap satisfies `(1/N) Σ_{k≠0} |F_T(k/N)|² ≤ C·N`, i.e. typical irrational-like
frequencies already have `√N`-cancellation **on average** even though no *uniform* gap
exists (`no_uniform_spectral_gap`).
**Test**: Prove the discrete Parseval identity for `F_T` over the `N`-th roots of unity
(`Finset.sum` of `‖·‖²` = `N · Σ_n 1` via orthogonality, reusing
`spectral_gap_full_period` as the orthogonality input) and extract the average bound.
**Why now**: `spectral_gap_full_period` IS the orthogonality relation Parseval needs, and
`no_uniform_spectral_gap` tells us the right notion is average, not pointwise.
**If true**: it establishes square-root cancellation *in mean square* unconditionally —
the strongest Collatz-Fourier statement reachable without resolving the conjecture.
**If false**: even the averaged budget concentrates away from `√N`, indicating Collatz
exponential sums are far less random than heuristics predict.
