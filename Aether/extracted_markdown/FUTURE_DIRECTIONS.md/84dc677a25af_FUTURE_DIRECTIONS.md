# Future Directions — Spectral Universality of Transformer Weight Dynamics

## Synthesis

This cold-start cycle built the rigorous algebraic backbone for the
spectral-universality conjecture: weight-update covariance spectra are encoded by
the moment sequence `specMoment M k = tr(Mᵏ)`, and we proved exactly *which*
transformations leave that sequence invariant. The invariance group splits into
two physically meaningful symmetries — change of basis / similarity
(`specMoment_conj_invariant`, specialized to orthogonal preconditioners in
`specMoment_orthogonal_conj`) and covariance orientation
(`specMoment_orientation`, the exact finite-`k` identity `tr((AB)ᵏ⁺¹) =
tr((BA)ᵏ⁺¹)`) — together with the scalar normalization law (`specMoment_smul`)
and the order-1 additivity of the mean spectrum (`specMoment_one_add`). Every
result is an exact finite-dimensional identity over an arbitrary commutative
ring, so the foundation invokes no analysis or randomness and is maximally
reusable.

The most informative outcome was a *failure*. The Critic asked whether the clean
additivity `specMoment_one_add` extends to higher moments; the answer is no, and
we proved it with an explicit 1×1 counterexample (`secondMoment_not_additive`):
`tr((M+N)²) = 4 ≠ 2 = tr(M²) + tr(N²)` for `M = N = !![1]`. The obstruction is
the cross term `2 tr(MN)`, which is exactly the quantity that free probability's
non-crossing-partition machinery is built to organize. So the disproof is not a
dead end — it pinpoints *why* free cumulants (rather than ordinary sums) are the
correct higher-order generalization, sharpening Direction 2 below.

The structural insight tying the cycle together: the moment sequence is a
*ring-valued invariant of a similarity-and-orientation orbit*, and the second
moment is simultaneously (i) a spectral quantity, (ii) an entrywise data
statistic — `tr(M²) = Σᵢⱼ Mᵢⱼ Mⱼᵢ`, equal to the squared Frobenius norm when `M`
is symmetric (`specMoment_two_eq_sum`, `specMoment_two_symm_eq_frob`). This
double identity is the concrete bridge from data statistics to spectral geometry
that the entropy-rate program (Direction 5) needs.

## Results Summary

- `specMoment_zero`: proved — the zeroth moment is the dimension `card n`, fixing the trivial normalization constant.
- `specMoment_one`: proved — the first moment is the trace, anchoring the moment hierarchy.
- `specMoment_smul`: proved — moments obey the scaling law `tr((c•M)ᵏ) = cᵏ tr(Mᵏ)`, isolating the single global normalization degree of freedom.
- `specMoment_one_add`: proved — the mean spectrum is additive, the order-1 shadow of free additive convolution.
- `conj_pow`: proved — `(PMQ)ᵏ = P Mᵏ Q` for a one-sided inverse `QP = 1`, the engine behind similarity invariance.
- `specMoment_conj_invariant`: proved — similarity transforms preserve all spectral moments (basis/architecture-microdetail invariance).
- `specMoment_orthogonal_conj`: proved — orthogonal preconditioners (`SᵀS = 1`) preserve the spectrum, the optimizer-class invariance of Direction 4.
- `mul_pow_succ_swap`: proved — the rectangular identity `(AB)ᵏ⁺¹ = A (BA)ᵏ B`.
- `specMoment_orientation`: proved — `tr((AB)ᵏ⁺¹) = tr((BA)ᵏ⁺¹)`, exact orientation independence of the Wishart spectrum (Direction 3).
- `specMoment_two_eq_sum`: proved — `tr(M²) = Σᵢⱼ Mᵢⱼ Mⱼᵢ`, the spectral-to-entrywise data bridge.
- `specMoment_two_symm_eq_frob`: proved — for symmetric `M`, `tr(M²) = Σᵢⱼ Mᵢⱼ²` (squared Frobenius norm = total weight variance).
- `secondMoment_not_additive`: disproved (counterexample) — moment additivity fails at order 2, motivating the free-cumulant generalization.

## Research Directions

### Direction 1: Finite moment-determinacy of the empirical spectral measure
**Hypothesis**: For self-adjoint `M : Matrix (Fin n) (Fin n) ℝ`, the first `n`
normalized moments `k ↦ tr(Mᵏ)/n` (`k = 0,…,n-1`) uniquely determine the
multiset of eigenvalues, hence the empirical spectral measure; consequently
`(∀ k, specMoment M k = specMoment N k)` for two `n×n` self-adjoint matrices is
equivalent to equality of their spectral measures.
**Test**: Formalize the power-sum ↔ elementary-symmetric (Newton's identities)
bridge so that the moments determine `Matrix.charpoly`, then invoke uniqueness of
the characteristic polynomial's root multiset. A finite Vandermonde-invertibility
lemma over distinct eigenvalues closes it; disproof would require two matrices
with equal moments but different spectra (impossible for distinct eigenvalues, so
the live question is the repeated-eigenvalue boundary).
**Why now**: We already have `specMoment` and the invariance group; the only
missing piece is the algebraic moment→charpoly inversion, and Mathlib's
`Matrix.charpoly` plus `MvPolynomial`/Newton-identity API are now mature enough.
**If true**: It upgrades every theorem in this file from a moment-level statement
to a genuine *spectral-measure* statement, exactly the bridge the catalog wants.
**If false**: The failure would localize precisely at eigenvalue collisions,
telling us the universality class must be defined on moments rather than measures.

### Direction 2: Free cumulants repair higher-order additivity
**Hypothesis**: Define free cumulants `κ_k` via non-crossing-partition
moment-cumulant relations; then for *freely independent* blocks the cumulants are
additive at every order, `κ_k(M+N) = κ_k(M) + κ_k(N)`, even though the moments
are not (as `secondMoment_not_additive` shows). The order-1 cumulant is the
trace, recovering `specMoment_one_add`.
**Test**: Formalize `Finset`-indexed non-crossing partitions, the moment-cumulant
sum, and prove additivity of `κ_2` first: `κ_2(X) = tr(X²) - (tr X)²/n`, so the
cross term `2 tr(MN)` that broke additivity is absorbed by the second-cumulant
correction. Then push to general `k`.
**Why now**: `secondMoment_not_additive` exhibits the exact cross-term obstruction
`2 tr(MN)`, giving a concrete target the cumulant correction must cancel — a
self-contained `Finset` combinatorics project independent of any training dynamics.
**If true**: It generalizes our order-1 additivity to all orders and lands a
genuinely novel free-probability contribution.
**If false**: A counterexample to cumulant additivity would mean freeness is the
wrong independence notion for weight blocks, redirecting the whole program.

### Direction 3: Marchenko–Pastur moments are orientation-blind
**Hypothesis**: For the sample covariance of a rectangular factor, the normalized
moments satisfy the Catalan/Narayana recursion of the Marchenko–Pastur law, and
the limit is intrinsic to the factor (independent of the `AB` vs `BA`
orientation) because `specMoment_orientation` already equates the two oriented
moment sequences at every finite `k`.
**Test**: Prove the finite-`k` MP moment formula `m_k = Σ_{non-crossing} c^{·}`
combinatorially, then take the `p/n → c` limit; the orientation independence is
*already proven* finitely, so only the combinatorial moment count is new.
**Why now**: `specMoment_orientation` is dimension-agnostic and proven; it
supplies the orientation half of the theorem for free, leaving a pure
lattice-path counting problem.
**If true**: It is the first concrete member of the conjectured universal family,
realized rigorously in Lean.
**If false**: A mismatch in the moment recursion would reveal a hidden dependence
on the entry distribution beyond mean/variance, refuting naive universality.

### Direction 4: Non-orthogonal preconditioners deform moments architecture-independently
**Hypothesis**: For an invertible (not necessarily orthogonal) preconditioner `S`,
the deformed moment `tr((Sᵀ M S)ᵏ) − tr(Mᵏ)` factors through `S` and the *moment
data of `M`* in a way that is independent of `M`'s architectural origin; in
particular it vanishes for all `M` iff `Sᵀ S = 1` (a positive-definite refinement
of `specMoment_orthogonal_conj`).
**Test**: Prove the "iff orthogonal" direction: if `tr((Sᵀ M S)ᵏ) = tr(Mᵏ)` for
all symmetric `M` at `k = 2`, then `(SSᵀ)` acts as the identity on the trace form,
forcing `Sᵀ S = 1`. The forward direction is `specMoment_orthogonal_conj`.
**Why now**: We have the clean orthogonal-invariance theorem; the boundary case
(where invariance *fails*) is one `k = 2` computation away using
`specMoment_two_eq_sum`.
**If true**: It converts "optimizer class sets the universality class" into a
crisp, refutable algebraic dichotomy.
**If false**: A non-orthogonal `S` preserving all moments would expose an extra
hidden symmetry of the spectrum worth classifying.

### Direction 5: Entropy rate as the single scalar pinning the normalization
**Hypothesis**: Within a fixed optimizer class, after the basis/orientation
quotient, the limiting law is a one-parameter family with the normalized second
moment `tr(M²)/n` an affine function of the data entropy rate `h`; matching `h`
forces all higher normalized moments to agree.
**Test**: Using `specMoment_two_symm_eq_frob`, identify `tr(M²)/n` with the mean
squared weight magnitude, then connect it to an information-theoretic `h` via the
catalog entropy machinery (`Shared/MutualInformation.lean`,
`Shared/EntropyAlgebra.lean`); test whether fixing `h` plus the proven scaling
law `specMoment_smul` pins the remaining scale.
**Why now**: `specMoment_two_symm_eq_frob` makes the second moment a concrete data
statistic, and `specMoment_smul` shows the only residual freedom is one global
scale — exactly the slot an entropy parameter can fill.
**If true**: It closes the loop from data statistics to spectral geometry with a
single scalar, the boldest form of the universality conjecture.
**If false**: Needing two or more parameters would quantify exactly how far real
weight spectra are from one-parameter universality.
