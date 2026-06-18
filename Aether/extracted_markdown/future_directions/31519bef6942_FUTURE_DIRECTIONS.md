# Future Directions — Topological Quantum Computing: Braiding Universality

## Synthesis

This cycle isolated the *mathematical kernel* of why anyon braiding is a
universal model of quantum computation, and split that claim into a provable
algebraic part and a provable number-theoretic part, with the genuinely hard
geometric part cleanly quarantined as a conjecture. On the algebraic side we
formalized the reduced **Burau representation** of the three-strand braid group
`B₃` (`burauSigma₁`, `burauSigma₂`) — the linear skeleton from which the **Jones
polynomial** is extracted as a normalized Markov trace — and proved it satisfies
the defining **Yang–Baxter / braid relation** `σ₁σ₂σ₁ = σ₂σ₁σ₂`
(`burau_braid_relation`) for *every* value of the loop parameter `t`, together
with invertibility (`burau_det₁`, `burau_det₂`: `det = -t`, upgraded to `IsUnit`
over a field in `burau_isUnit₁`/`burau_isUnit₂`). The braid relation is a
polynomial identity in `t`, which is precisely why the Jones invariant is a
Laurent polynomial rather than a single number, and connects directly to the
catalog's `Applications/Jones.lean` (Kauffman-bracket Jones polynomial) and
`Bridges/CyclotomicKnotSpectra.lean` (Alexander-polynomial machinery).

On the analytic/number-theoretic side we proved the sharp universality
dichotomy on the maximal torus: the orbit of a phase gate `exp(2πiθ)` is dense
in the phase circle **iff** `θ` is irrational (`phaseGate_dense_iff`, with the
forward direction packaged as `phaseGate_orbit_dense`). The decisive structural
insight — and the most important note for the next team — is that *universality
is a number-theoretic property of the phase, not a topological one*: the very
same lemma (`AddCircle.denseRange_zsmul_coe_iff`) that produces density for
irrational phases produces its **failure** for the Fibonacci anyon eigenphase
`4/5` (`fibonacci_phase_not_dense`). This is the Critic's counterexample, and it
is conceptually load-bearing: a *single* braiding phase can never be universal,
so full universality must come from the **non-commutativity** of distinct
braids. We captured that non-commutativity already at the linear level:
`burau_braid_nontrivial` shows `σ₁σ₂ ≠ σ₂σ₁` whenever `t ≠ 0`. The one piece we
could not close — `su2_braiding_dense`, the existence of two `SU(2)` braid gates
generating a dense subgroup — is recorded below as Direction 1, because Mathlib
lacks the classification of closed subgroups of `SU(2)`.

## Results Summary

- `burau_braid_relation`: **proved** — Burau matrices satisfy the braid relation
  for all `t` (the Jones-polynomial backbone, a genuine `B₃` representation).
- `burau_det₁`, `burau_det₂`: **proved** — `det σᵢ = -t`.
- `burau_isUnit₁`, `burau_isUnit₂`: **proved** — invertibility over a field for
  `t ≠ 0` (the representation lands in `GL₂`).
- `burau_braid_nontrivial`: **proved** — `σ₁σ₂ ≠ σ₂σ₁` for `t ≠ 0`; the linear
  shadow of why universality needs non-commuting braids.
- `phaseGate_orbit_dense` / `phaseGate_dense_iff`: **proved** — the torus orbit is
  dense iff the braiding phase is irrational (the one-parameter Solovay–Kitaev
  kernel and its sharp dichotomy).
- `fibonacci_phase_not_dense`: **proved (counterexample)** — the rational
  eigenphase `4/5` has a non-dense orbit; pure-phase braiding is not universal.
- `su2_braiding_dense`: **conjecture** — two `SU(2)` braid gates generate a dense
  subgroup; the missing ingredient is the closed-subgroup classification of
  `SU(2)`.

## Research Directions

### Direction 1: Closed subgroups of `SU(2)` and the density theorem
Every closed subgroup of `SU(2)` that is non-abelian and not contained in the
normalizer of a maximal torus equals all of `SU(2)`; consequently two generic
braid unitaries generate a dense subgroup (`su2_braiding_dense`). The test is to
formalize the classification of closed subgroups of the compact group `SU(2)`
(finite groups, tori, their normalizers, and `SU(2)` itself), then exhibit an
explicit pair `U, V` escaping every proper closed subgroup. The key insight is
that `fibonacci_phase_not_dense` already proves the *only* obstructions to
density are abelian/finite, so the classification is provably sufficient — there
is nothing else to rule out. Why now? This cycle reduced full universality to
exactly this one statement; the surrounding scaffolding (`burau_braid_relation`
giving genuine non-abelian generators, the torus dichotomy isolating the abelian
case) is already in place. If true, it closes the central universality theorem
and yields a reusable `SU(2)` density toolkit; if false, it would expose an
exotic closed subgroup, reshaping the picture of compact-group density.

### Direction 2: Jones polynomial as a Markov trace of Burau words
The normalized weighted trace of the Burau matrix of a braid word `β`, with the
Markov-move normalization, is invariant under both Markov moves and therefore
defines a link invariant equal to the Jones polynomial of `Applications/Jones.lean`.
The test is to define the trace functional on Burau words over `B₃` and prove
invariance under conjugation (Markov I) and stabilization (Markov II). The key
insight is that `burau_braid_relation` already certifies a *well-defined* `B₃`
representation, so the trace functional is now expressible as a function on the
braid group rather than on words — only the two Markov invariances remain. Why
now? The representation just became available this cycle, and the catalog already
contains a Kauffman-bracket Jones polynomial to check the trace against. If true,
it produces the first *trace-theoretic* Jones polynomial in the catalog and ties
it to `CyclotomicKnotSpectra.lean`; if false, it would expose a normalization
error and pin down the exact trace weights.

### Direction 3: The irrationality dichotomy as a multi-gate universality classifier
A single-qubit phase gate set `{exp(2πiθ₁), …, exp(2πiθₖ)}` is torus-dense iff
the `ℚ`-vector space spanned by `1, θ₁, …, θₖ` has dimension `> 1` (some `θᵢ` is
irrational relative to the rest). The test is to generalize `phaseGate_dense_iff`
from `zmultiples` of one element to finitely generated subgroups of `AddCircle 1`
via a two-generator density lemma and Kronecker's theorem. The key insight is
that the proved single-gate dichotomy is exactly the `k = 1` instance, so the
general statement is a clean induction over generators rather than a new idea.
Why now? Both proved torus results are special cases and Mathlib already supplies
the equidistribution and two-generator density machinery. If true, it gives a
decidable-flavored criterion for which finite gate sets are torus-universal; if
false, it pinpoints a phase configuration dense without satisfying the dimension
criterion, refining Kronecker in the circle setting.

### Direction 4: Burau at roots of unity and finite-order braiding
When `t = exp(2πi/n)` the Burau image of `B₃` is a *finite* group whose order is
a computable function of `n`, matching finite anyon models (Ising at `n = 4`).
The test is, for small `n`, to compute the order of the group generated by
`burauSigma₁ t, burauSigma₂ t` and prove finiteness via a finite invariant
lattice, contrasting with the irrational-phase dense case. The key insight is
that `fibonacci_phase_not_dense` already exhibits the finite-order phenomenon at
the *abelian* (torus) level, and the Burau picture lifts it to the full
non-abelian generators `burauSigma₁`/`burauSigma₂`. Why now? The representation
and its determinants are now proved, so the generated subgroup is a well-defined
finite-matrix-group question. If true, it cleanly separates universal
(`SU(2)`-dense) from non-universal (finite, e.g. Ising) anyon models inside one
formal framework; if false, it reveals a root-of-unity value where Burau is
unexpectedly infinite — a representation-theoretic anomaly.

### Direction 5: Quantitative Solovay–Kitaev approximation rate
For irrational `θ` with bounded continued-fraction coefficients, the phase-gate
orbit `{n • θ}` approximates any target phase to accuracy `ε` using `O(1/ε)`
braids — linear, beating the generic `polylog(1/ε)` geometric Solovay–Kitaev
bound on the torus. The test is to combine `phaseGate_orbit_dense` with the
three-distance (Steinhaus) theorem to bound the gap sizes of `{n • θ}` and
extract an explicit word-length bound. The key insight is that density alone
(this cycle) gives only *existence*, whereas the gap structure of the *same*
orbit converts existence into an effective rate — the quantitative content lives
in the same object we already analyzed. Why now? `phaseGate_dense_iff` is the
existence statement, and Mathlib's equidistribution / three-distance tools are
the exact next ingredient. If true, it is the first formal *quantitative*
universality estimate, turning an existence theorem into an algorithmically
meaningful bound; if false, it identifies phases where approximation is provably
slower, mapping the boundary of efficient compilation.
