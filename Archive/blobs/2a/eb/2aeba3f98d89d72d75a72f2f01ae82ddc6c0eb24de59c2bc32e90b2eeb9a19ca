# Future Directions — The Fourier Analysis of Collatz

## Synthesis

The research brief proposed that the Collatz conjecture is *equivalent* to a spectral-gap
statement for the "Collatz Fourier transform"
`F(N, ω) = (1/N) Σ_{n=1}^N exp(2π i ω T(n)/n)`, with the headline bound `|F(N,ω)| < C`,
`C < √N`, for irrational `ω`. We took an adversarial ground-truth stance and formalized the
honest skeleton of this framing in `CollatzFourier.lean`. Two findings dominate.

First, the literal bound `C < √N` is **content-free**: `trivial_spectral_gap` shows
`‖F(N,ω)‖ ≤ 1 < √N` for *every* real `ω` and every `N ≥ 2`, using nothing about Collatz
dynamics — just unit-modulus phases and the triangle inequality (`phase_norm_one`,
`fourierSum_norm_le`, `F_norm_le_one`). Any nonvacuous mixing claim must therefore demand
`‖F(N,ω)‖ = o(1)`, not `< √N`.

Second, the map **genuinely resonates at rational frequencies**. The even branch satisfies
`T(n)/n = 1/2` exactly (`ratio_even`), so at `ω = 2` every even-`n` phase collapses to `1`
(`phase_even_two`); summed over the even progression in `{1,…,N}` the Fourier mass is the
*maximum possible*, `⌊N/2⌋` (`even_resonance`, `card_evens`, `even_branch_norm`), which pierces
the trivial `√N` envelope for `N ≥ 16` (`even_branch_beats_sqrt`). Mixing fails completely at
rationals, which is exactly why the brief restricts its conjecture to irrational `ω`.

This work connects to the catalog's Collatz dynamics (`Collatz.accelCollatzOdd`, the 2-adic
valuation in `MachineLearning/Accelerated.lean`, the cycle obstructions in
`MachineLearning/Cycles.lean`): the even/odd dichotomy that powers the 2-adic orbit analysis
there is the same dichotomy that creates spectral resonance here.

## Results Summary

- `phase_norm_one` — each Fourier phase lies on the unit circle.
- `F_zero` — the DC component `F(N,0) = 1` (normalization anchor).
- `trivial_spectral_gap` — the conjectured bound `< √N` holds for all `ω`, hence is vacuous.
- `even_resonance` / `even_branch_norm` — exact resonance mass `⌊N/2⌋` at `ω = 2`.
- `even_branch_beats_sqrt` — that mass exceeds `√N`; no mixing at rationals.

## Research Directions

### 1. The honest mixing statement: a decay bound for irrational ω
The trivial bound must be replaced by genuine cancellation. **The key insight is** that the
even/odd split decomposes `F(N,ω)` into a rational-resonant part (`ω`-coherent on the even
progression, value `exp(πiω)` per even term) and an odd part where `T(n)/n = 3 + 1/n` spreads
the phase as `exp(2πiω(3 + 1/n))`; for irrational `ω` the residues `{ω/n}` equidistribute, so
the odd contribution should be `o(N)`. A falsifiable target: prove `‖F_odd(N,ω)‖/N → 0` for
all irrational `ω` via Weyl's criterion on `{ω·T(n)/n}`. **Why now?** The exact even-branch
identity (`even_resonance`) isolates precisely the part that does *not* decay, so the remaining
analytic burden is confined to the odd branch where Mathlib's `Real.tendsto_...` and
equidistribution API can be brought to bear.

### 2. Even-branch resonance at every even integer frequency
We proved resonance only at `ω = 2`. **The key insight is** that for *every* even integer
`ω = 2k`, the even-`n` phase is `exp(2π i k) = 1`, so `even_branch_norm` should generalize to
`‖Σ_{even n ≤ N} phase (2k) n‖ = ⌊N/2⌋` for all `k ∈ ℤ`, exhibiting a full lattice of rational
resonances. Falsifiable: prove the generalization, and prove it *fails* (mass `< ⌊N/2⌋`) at
odd-integer `ω`, where `exp(πiω) = -1` forces sign alternation. **Why now?** `phase_even_two`
already contains the entire argument; only the arithmetic `2π(2k)(1/2) = 2π k ∈ 2πℤ` changes,
making this a low-risk, high-coverage extension that maps the resonance spectrum exactly.

### 3. Contrast map 5n+1: resonance signature of a divergent dynamics
Define `T₅(n) = n/2` (even) and `5n+1` (odd), whose orbits are believed to diverge. **The key
insight is** that the even branch is *identical* to Collatz (`ratio = 1/2`), so the
even-frequency resonance lattice is the same — meaning the spectral *difference* between a
convergent and a divergent map lives entirely in the odd branch's ratio `5 + 1/n` vs `3 + 1/n`.
Falsifiable conjecture: the odd-branch Fourier mass of `T₅` at irrational `ω` does *not* decay
to `0` (a measurable resonance the Collatz map lacks). **Why now?** Our `T`, `ratio`, `phase`
definitions are parametric in the branch formula; cloning them for `5n+1` is mechanical and lets
the next cycle test "spectral gap ⇔ convergence" directly against a known-divergent control.

### 4. Quantitative gap vs. stopping time
The brief links gap width `Ω(1/log n)` to stopping time `O(log n)`. **The key insight is** that
the *single-step* transform studied here is the `k=1` case of an iterated transform
`F^{(k)}(N,ω) = (1/N) Σ exp(2π i ω T^k(n)/n)`; the ratio `T^k(n)/n` is exactly the geometric
mean expansion over `k` steps, whose log is the quantity controlling stopping time. Falsifiable:
formalize `T^k(n)/n = Π_{j<k} ratio(T^j n)` and prove that bounded stopping time forces the
iterated ratios into a *finite* set of rationals, hence a pure-point (gap-free in the mixing
sense) spectrum. **Why now?** The catalog's `accelSeq`/`accelCollatzOdd` already provide the
iterated orbit and its 2-adic factorization, giving a ready-made `T^k` to plug into the
iterated transform.

### 5. Parseval / energy identity for the Collatz transform
**The key insight is** that integrating `‖F(N,ω)‖²` over `ω ∈ [0,1)` yields, by orthogonality
of `exp(2π i m ω)`, a *counting* identity: the energy equals `(1/N²)·#{(m,n) : T(m)/m = T(n)/n}`,
i.e. the number of index pairs sharing a one-step expansion ratio. Falsifiable: prove this
Parseval identity and show the diagonal alone forces total energy `≥ 1/N`, while the even-branch
coincidences (`ratio = 1/2` for all even `m,n`) contribute `≈ 1/4`, recovering the
non-mixing mass of Direction 2 from an integral viewpoint. **Why now?** Mathlib's
`Complex.exp` orthogonality over the circle and `Finset` double-counting lemmas make the
discrete Parseval identity provable today, turning the qualitative resonance result into a
quantitative energy budget.
