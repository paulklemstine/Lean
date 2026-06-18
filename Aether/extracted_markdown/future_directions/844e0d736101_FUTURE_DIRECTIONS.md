# Future Directions — Arithmetic Holography via Prime Geodesic Echoes on Modular Quantum Graphs

## Synthesis

The grand conjecture — that spectral form factors of modular quantum graphs carry echoes
of the Riemann zeta zeros beyond random-matrix universality — is, as stated, far beyond
present formalization. Our strategy was to isolate its *unconditional provable kernel* and
prove that kernel completely in Lean 4, so that the next cycle can build upward from solid
ground rather than sideways into folklore.

Three rigid facts emerged, and together they pin down *where* arithmetic must enter:

1. **The spectral form factor is nothing but a pair sum of eigenvalue gaps.**
   `sff_echo_decomposition` proves `SFF(μ, t) = ∑_{j,k} cos(t (μⱼ − μₖ))`. Every
   oscillatory ("echo") component is an eigenvalue *difference*. There is no hidden
   spectral information — the SFF is a transparent functional of the gap multiset.

2. **Spectral moments count closed geodesics.** `trace_pow_eq_sum_eigenvalues` /
   `closedWalks_eq_sum_eigenvalues` give `∑ᵢ μᵢ^k = trace(A^k) = #{closed length-k walks}`.
   This is the elementary trace formula: short closed geodesics ↔ low spectral moments.

3. **Modular graphs have arithmetic spectra.** `cayley_eigenvector` proves that on any
   finite abelian group every additive character `ψ` is an eigenvector of the Cayley
   adjacency operator, with eigenvalue the finite Fourier/Gauss sum `∑ₛ c(s) ψ(s)`.

Composing (1) and (3): the SFF frequencies of a modular (Cayley) graph are *differences of
character sums*. The arithmetic content of the conjecture is therefore localized exactly at
the bridge between (3) and (1).

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `sff_nonneg` | `0 ≤ SFF(μ,t)` | ✅ proved |
| `sff_zero` | `SFF(μ,0) = n²` | ✅ proved |
| `sff_echo_decomposition` | `SFF(μ,t) = ∑_{j,k} cos(t(μⱼ−μₖ))` | ✅ proved |
| `trace_pow_eq_sum_eigenvalues` | `trace(A^k) = ∑ᵢ μᵢ^k` (Hermitian) | ✅ proved |
| `closedWalks_eq_sum_eigenvalues` | closed-walk count = `k`-th power sum | ✅ proved |
| `cayley_eigenvector` / `cayley_hasEigenvalue` | characters diagonalize Cayley graphs | ✅ proved |

All depend only on `propext`, `Classical.choice`, `Quot.sound`. Zero `sorry`.

## Research Directions

### 1. Gauss-sum modulus law for prime-level modular graphs
For `G = ZMod p` with `p` prime and connection weights `c` supported on the quadratic
residues, the character eigenvalues `∑ₛ c(s) ψₐ(s)` become quadratic Gauss sums, whose
modulus is exactly `√p` for `a ≠ 0`. **The key insight is** that this is the finite,
unconditional avatar of "square-root cancellation" — the same phenomenon the zeta
conjecture invokes asymptotically — and it is fully provable from `cayley_eigenvector`
plus Mathlib's `gaussSum` API. *Why now?* We already have the eigenvector bridge formalized
and Mathlib carries `ZMod`, `quadraticChar`, and `gaussSum_sq`; the only missing step is
specializing `cayleyEigenvalue` to the residue indicator, which is a direct computation.

### 2. Ramp–plateau dichotomy for the averaged spectral form factor
Conjecture: for any spectrum with distinct eigenvalues, the long-time average
`lim_{T→∞} (1/T)∫₀ᵀ SFF(μ,t) dt = n` (the "plateau"), separating cleanly from the `t=0`
value `n²`. **The key insight is** that `sff_echo_decomposition` already reduces this to the
statement that each off-diagonal `cos(t(μⱼ−μₖ))` time-averages to zero while the `n`
diagonal terms survive — a pure equidistribution fact, not a physical assumption.
*Why now?* The decomposition theorem hands us the exact integrand termwise; Mathlib's
`Real.cos` integrability and average lemmas close the off-diagonal terms, making this a
finite, falsifiable target rather than a heuristic.

### 3. Character orthogonality ⇒ full diagonalization and a Plancherel SFF
The single eigenvector theorem should be upgraded to a full spectral decomposition: the `n`
characters of a finite abelian group form an orthogonal eigenbasis of every Cayley operator,
giving `SFF` a closed form purely in terms of `{cayleyEigenvalue c ψ}`. **The key insight
is** that Cayley operators over abelian groups are *simultaneously* diagonalized by the
character basis independent of `c`, so the whole family is a commutative von-Neumann-style
algebra and the SFF becomes a Plancherel sum over the dual group. *Why now?* Mathlib's
`AddChar` orthogonality relations (`AddChar.sum_eq_zero_of_ne` style) are already available,
so promoting `cayley_eigenvector` to a basis statement is incremental, not foundational.

### 4. Stability of echo frequencies under congruence-level refinement
Conjecture: as one passes from `ZMod N` to `ZMod (N·M)` with a compatible connection set,
a distinguished subset of eigenvalue gaps is *preserved* (scale-stable echoes), realized via
the projection `ZMod (N·M) → ZMod N` and pullback of characters. **The key insight is** that
character pullback along a quotient map embeds the level-`N` spectrum inside the level-`NM`
spectrum, giving a literal, finite-dimensional mechanism for "scale-stable oscillatory
components" without invoking universality. *Why now?* `ZMod.castHom` and the induced
`AddChar` comap are in Mathlib, so the inclusion of spectra is a concrete lemma we can state
and attack immediately, turning the vague "persistence across levels" into a theorem.

### 5. Null-model separation: random-circulant SFF concentration
To make the conjecture falsifiable we need the *null* side: for connection weights `c`
drawn i.i.d. with mean zero, the expected SFF equals the diagonal `n` plus a vanishing
off-diagonal contribution, i.e. random modular graphs show *no* persistent echoes. **The
key insight is** that `sff_echo_decomposition` turns this into a statement about
`E[cos(t(μⱼ−μₖ))]` for random character sums, which factorizes through independence and is
amenable to second-moment bounds. *Why now?* With the deterministic decomposition proved,
the probabilistic null model is a clean add-on using Mathlib's `ProbabilityTheory` variance
machinery, giving the contrast (signal vs. null) that the original test demands.
