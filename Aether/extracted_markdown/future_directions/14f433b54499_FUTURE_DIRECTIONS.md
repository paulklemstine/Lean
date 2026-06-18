# Future Directions — Arithmetic Holography via Prime Geodesic Echoes on Modular Quantum Graphs

## Synthesis

The grand conjecture — that spectral form factors (SFFs) of modular quantum graphs carry
echoes of the Riemann zeta zeros beyond random-matrix universality — is, as stated, far
beyond present formalization. Our strategy was to isolate its *unconditional provable kernel*
and prove that kernel completely in Lean 4, so the next cycle can build upward from solid
ground rather than sideways into folklore.

Three rigid facts emerged, and together they localize *where* arithmetic must enter.

1. **The spectral form factor is nothing but a pair sum of eigenvalue gaps.**
   `ArithmeticHolography.sff_echo_decomposition` proves
   `sff μ t = ∑_{j,k} cos(t (μⱼ − μₖ))`. Every oscillatory ("echo") component is an
   eigenvalue *difference*; there is no hidden spectral information. The SFF is a transparent
   functional of the gap multiset, with the diagonal `j = k` terms (each `cos 0 = 1`) giving
   the plateau value `n` and the off-diagonal terms carrying all the oscillation. The two
   boundary facts `sff_nonneg` and `sff_zero` (`sff μ 0 = n²`) pin its dynamic range.

2. **Spectral moments count closed geodesics.** `closedWalks_eq_trace` gives
   `trace(Aᵏ) = ∑_v #{closed length-k walks at v}`, and `trace_pow_eq_sum_eigenvalues` gives
   `trace(Aᵏ) = ∑ᵢ μᵢᵏ` for Hermitian `A`. Chaining them yields the elementary trace formula
   `∑ᵢ μᵢᵏ = #{closed length-k walks}`: short closed geodesics ↔ low spectral moments.

3. **Modular graphs have arithmetic spectra.** `cayley_eigenvector` proves that on any finite
   abelian group every additive character `ψ` is an eigenvector of the Cayley adjacency
   operator `cayleyOpLin c`, with eigenvalue the finite Fourier / Gauss sum
   `cayleyEigenvalue c ψ = ∑ₛ c(s) ψ(s)`; `cayley_hasEigenvalue` lifts this to a genuine
   `Module.End.HasEigenvalue` statement.

Composing (1) and (3): the SFF frequencies of a modular (Cayley) graph are *differences of
character sums*. The arithmetic content of the conjecture is therefore localized exactly at
the bridge between (3) and (1).

## Results Summary

| Theorem | Statement | File | Status |
|---|---|---|---|
| `sff_nonneg` | `0 ≤ sff μ t` | `SpectralFormFactor.lean` | proved |
| `sff_zero` | `sff μ 0 = n²` | `SpectralFormFactor.lean` | proved |
| `sff_echo_decomposition` | `sff μ t = ∑_{j,k} cos(t(μⱼ−μₖ))` | `SpectralFormFactor.lean` | proved |
| `cayley_eigenvector` | characters diagonalize Cayley operators | `CayleySpectra.lean` | proved |
| `cayley_hasEigenvalue` | the Fourier sum is a genuine eigenvalue | `CayleySpectra.lean` | proved |
| `closedWalks_eq_trace` | `trace(Aᵏ) = #closed length-k walks` | `TraceFormula.lean` | proved |
| `trace_pow_eq_sum_eigenvalues` | `trace(Aᵏ) = ∑ᵢ μᵢᵏ` (Hermitian) | `TraceFormula.lean` | proved |

All depend only on `propext`, `Classical.choice`, `Quot.sound`. Zero `sorry`.

## Research Directions

### 1. Gauss-sum modulus law for prime-level modular graphs
For `G = ZMod p` with `p` prime and connection weights `c` supported on the quadratic
residues, the character eigenvalues `cayleyEigenvalue c ψₐ = ∑ₛ c(s) ψₐ(s)` become quadratic
Gauss sums, whose modulus is exactly `√p` for `a ≠ 0`. **The key insight is** that this is the
finite, unconditional avatar of "square-root cancellation" — the same phenomenon the zeta
conjecture invokes asymptotically — and it is fully provable from `cayley_eigenvector` plus
Mathlib's `gaussSum` API. *Why now?* We already have the eigenvector bridge formalized and
Mathlib carries `ZMod`, `quadraticChar`, and `gaussSum_sq`; the only missing step is
specializing `cayleyEigenvalue` to the residue indicator, a direct computation. A falsifiable
prediction: the SFF of the residue-Cayley graph has all nonzero off-diagonal frequencies of a
single magnitude `√p`, which a finite numeric check would immediately confirm or refute.

### 2. Ramp–plateau dichotomy for the averaged spectral form factor
Conjecture: for any spectrum with distinct eigenvalues, the long-time average
`lim_{T→∞} (1/T)∫₀ᵀ sff μ t dt = n` (the "plateau"), separating cleanly from the `t = 0`
value `n²`. **The key insight is** that `sff_echo_decomposition` already reduces this to the
statement that each off-diagonal `cos(t(μⱼ−μₖ))` time-averages to zero while the `n` diagonal
terms survive — a pure equidistribution fact, not a physical assumption. *Why now?* The
decomposition theorem hands us the exact integrand termwise; Mathlib's `Real.cos`
integrability and Cesàro/average lemmas close the off-diagonal terms, making this a finite,
falsifiable target rather than a heuristic. Falsifier: any spectrum whose averaged SFF
deviates from `n` would necessarily have a repeated gap `μⱼ − μₖ = 0` with `j ≠ k`.

### 3. Character orthogonality ⇒ full diagonalization and a Plancherel SFF
Upgrade the single eigenvector theorem to a full spectral decomposition: the `n` characters of
a finite abelian group form an orthogonal eigenbasis of *every* Cayley operator, giving the
SFF a closed form purely in terms of `{cayleyEigenvalue c ψ}`. **The key insight is** that
Cayley operators over abelian groups are *simultaneously* diagonalized by the character basis
independent of `c`, so the whole family is a commutative algebra and the SFF becomes a
Plancherel sum over the dual group. *Why now?* Mathlib's `AddChar` orthogonality relations
(`AddChar.sum_eq_zero_of_ne_one`-style) are available, so promoting `cayley_eigenvector` to a
basis statement is incremental, not foundational. Falsifier: if the character family failed to
be a basis, some Cayley operator would have an eigenvalue not of the form `∑ₛ c(s) ψ(s)`.

### 4. Stability of echo frequencies under congruence-level refinement
Conjecture: passing from `ZMod N` to `ZMod (N·M)` with a compatible connection set, a
distinguished subset of eigenvalue gaps is *preserved* (scale-stable echoes), realized via the
projection `ZMod (N·M) → ZMod N` and pullback of characters. **The key insight is** that
character pullback along a quotient map embeds the level-`N` spectrum inside the level-`NM`
spectrum, giving a literal, finite-dimensional mechanism for "scale-stable oscillatory
components" without invoking universality. *Why now?* `ZMod.castHom` and the induced `AddChar`
comap are in Mathlib, so the inclusion of spectra is a concrete lemma we can state and attack
immediately. Falsifier: exhibit a compatible connection set whose level-`N` gaps fail to
reappear at level `NM`.

### 5. Null-model separation: random-circulant SFF concentration
To make the conjecture falsifiable we need the *null* side: for connection weights `c` drawn
i.i.d. with mean zero, the expected SFF equals the diagonal `n` plus a vanishing off-diagonal
contribution — i.e. random modular graphs show *no* persistent echoes. **The key insight is**
that `sff_echo_decomposition` turns this into a statement about `E[cos(t(μⱼ−μₖ))]` for random
character sums, which factorizes through independence and is amenable to second-moment bounds.
*Why now?* With the deterministic decomposition proved, the probabilistic null model is a clean
add-on using Mathlib's `ProbabilityTheory` variance machinery, giving the signal-vs-null
contrast the original conjecture demands. Falsifier: a class of zero-mean random weights whose
expected SFF retains an order-`n` off-diagonal term would break the separation.
