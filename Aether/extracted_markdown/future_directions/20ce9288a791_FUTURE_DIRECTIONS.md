# FUTURE DIRECTIONS — Fourier Analysis of Collatz (Spectral Gaps in the 3n+1 Map)

This cycle isolated the **affine branch** `A x = 3x+1` of the Collatz/Syracuse step
on the finite cyclic groups `ℤ/N` and analysed its Koopman operator `U f = f ∘ A`
in the additive-character (Fourier) basis. The central, fully formalized finding
(`Catalog/Novelty/CollatzFourier.lean`) is a **no-spectral-gap theorem**: when
`gcd(3,N)=1`, `U` is a unitary phase-permutation of the character basis (frequency
map `m ↦ 3m`, geometric-sum phase), every character is an eigenvector of `U^L`
with a unimodular eigenvalue whenever `3^L = 1`, and `U` is an exact `L²`-isometry.
The contraction needed for Collatz therefore must come *entirely* from the `n/2`
branch — the `3n+1` branch alone is non-mixing.

The conjectures below are concrete, falsifiable, and chosen to be formalizable in
Lean in follow-up cycles.

## C1 — Spectral gap of the FULL (coupled) Syracuse operator
Let `S` be the *coupled* Koopman/transfer operator of the genuine Syracuse map on
`ℤ/2^k` (odd `n ↦ (3n+1)/2^{v₂(3n+1)}`), restricted to the orthogonal complement
of constants. **Conjecture:** the second-largest singular value `σ₂(S_k)` is
bounded away from `1` uniformly in `k`, i.e. `σ₂(S_k) ≤ 1 - c` for an absolute
`c > 0`. This is the precise sense in which the `2`-adic branch *restores* the gap
that C0 (this cycle) shows the affine branch lacks. Testable numerically on small
`k` before formalization.

## C2 — Order-of-3 controls the iterate period exactly
Define the Fourier period `P(N)` = least `L>0` with `U^L` acting as a scalar on
*every* character. **Conjecture:** `P(N) = ord_N(3)` for all `N` with `gcd(3,N)=1`
(this cycle proves `ord_N(3) | P(N)` direction implicitly via
`koopman_eigen_of_order`; the reverse — minimality — is open). Equivalently, the
nontrivial-character eigenphase `c(ψ,L) = ψ(∑_{j<L} 3^j)` equals `1` for all `ψ`
iff `ord_N(3) | L`. Falsifiable: search for `N` where some `L < ord_N(3)` already
scalarizes `U`.

## C3 — Eigenphase equidistribution / Weyl sum decay
The eigenphases `c(ψ,L) = ψ(∑_{j<L} 3^j)` are `N`-th roots of unity indexed by the
character `ψ` and time `L`. **Conjecture:** as `N → ∞` (over `N` coprime to 6) the
multiset `{ arg c(ψ_m, L) : m ∈ (ℤ/N)^× }` equidistributes on the circle, with the
associated Weyl/exponential sum `∑_m c(ψ_m,L)` of size `O(N^{1/2+ε})`. This links
the Collatz affine dynamics to standard exponential-sum cancellation and is a
clean target once finite-group Fourier `L²` bounds are in place.

## C4 — 2-adic transfer operator and a true contraction
On the 2-adic integers `ℤ₂`, the accelerated Syracuse map `T` is measure
preserving (Bernstein–Lagarias). **Conjecture:** the *signed* transfer operator
weighted by the halving exponent, `(L f)(x) = ∑_{T y = x} 2^{-v₂(...)} f(y)`,
has spectral radius `< 1` on mean-zero functions, and its leading eigenfunction is
real-analytic. A finite-level (`ℤ/2^k`) version is formalizable and would give a
quantitative mixing rate; the affine no-gap result of this cycle is the `k`-free
"infinite temperature" boundary case.

## C5 — Generalized (3→a) maps and a gap dichotomy
Replace `3` by a general odd `a ≥ 3` in `A_a x = a x + 1` on `ℤ/N`.
**Conjecture (dichotomy):** the affine Koopman operator `U_a` has NO spectral gap
on `ℤ/N` for *every* `a` with `gcd(a,N)=1` (the no-gap phenomenon is universal,
not special to `3`), while the *coupled* `(an+1)/2`-style maps have a gap iff
`a < 4` (the known `a≥5` divergence threshold). This separates the
"affine = always non-mixing" phenomenon (provable now by generalizing
`no_spectral_gap` to arbitrary unit coefficient) from the genuinely hard coupled
question, and pins the Collatz convergence/divergence boundary to the coupling.
