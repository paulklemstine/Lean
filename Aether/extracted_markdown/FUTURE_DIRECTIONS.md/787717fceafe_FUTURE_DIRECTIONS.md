# Future Directions — Arithmetic Holography

## Synthesis

This cycle formalized the *rigorous kernel* of the "arithmetic holography"
conjecture: the only structural fact that forces putative zeta zeros onto the
critical line is **reality of a self-adjoint spectrum**, and the critical line is
*exactly* the fixed-point locus of the functional-equation symmetry
`s ↦ 1 - conj s`. The new file `Catalog/Computation/ArithmeticHolography.lean`
introduces the holographic dictionary `zetaMap t = 1/2 + i t`, proves it is a
bijection from the real "resonance" line onto the critical line that intertwines
negation with conjugation (conjugate-pair symmetry), and proves an unconditional
Hilbert–Pólya statement: *every* Hermitian model reconstructs points lying only on
the critical line. It then builds an explicit, truncation-stable arithmetic
family — the Cayley adjacency operators of `ℤ/Nℤ` with a symmetric connection set
`S = -S` — and shows the arithmetic symmetry is precisely what makes each finite
model self-adjoint, so its spectrum lands on the critical line uniformly in `N`.

This bridges three catalog domains: the modular/arithmetic matrix calculus of
`Catalog/EML/ModularForms.lean`, the tropical spectral lower bounds of
`Catalog/Computation/Spectral.lean`, and the quantum-walk Cayley constructions of
`Catalog/Computation/QuantumWalkCayley.lean`.

## Results Summary

- `mem_criticalLine_iff_functionalEq` — the critical line is the functional-equation symmetry locus.
- `zetaMap_range`, `zetaMap_injective`, `zetaEquiv` — the holographic dictionary is a faithful bijection `ℝ ≃ criticalLine`.
- `zetaMap_neg_eq_conj` — conjugate-pair symmetry of reconstructed zeros.
- `IsHermitian.zetaMap_eigenvalue_mem_criticalLine` — unconditional Hilbert–Pólya statement for arbitrary Hermitian models.
- `zetaMap_offLine_refutes_selfAdjoint` — explicit falsifiability criterion.
- `cayleyAdj_isHermitian`, `cayleyAdj_spectrum_on_criticalLine` — explicit arithmetic family, self-adjoint and on-line at every truncation `N`.

All main results compile with `sorry = 0` and depend only on the standard axioms
`propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. Spectral symmetry of the Cayley family mirrors the functional equation
The Cayley adjacency operators of `ℤ/Nℤ` with `S = -S` are *real* symmetric, so
their spectrum is symmetric under an involution determined by the group's `−1`
automorphism. **The key insight is** that the connection-set symmetry `S = -S`
is the finite-model avatar of the zeta functional equation `s ↔ 1 - s`: both are
the *same* `ℤ/2` symmetry, one acting on geometry and one on the critical strip.
Conjecture: for every symmetric `S`, the multiset of eigenvalues of `cayleyAdj N S`
is invariant under `λ ↦ -λ` whenever `S` avoids the involution's fixed points, and
the induced involution on `zetaMap`-images coincides with `s ↦ 1 - conj s`.
*Why now?* We already have `cayleyAdj_isHermitian` and the conjugation-equivariance
`zetaMap_neg_eq_conj`; closing the loop only needs a reality/eigenvalue-symmetry
lemma, which Mathlib's circulant-eigenvalue API can supply.

### 2. Ramanujan bound as a "Riemann Hypothesis for graphs"
**The key insight is** that the Ihara-zeta "Riemann Hypothesis" for a finite graph
is *equivalent* to the Ramanujan spectral bound `|λ| ≤ 2√(q)` on the nontrivial
adjacency eigenvalues — an honest, provable analogue of RH living entirely in
finite linear algebra. Conjecture: there is an explicit symmetric `S ⊂ ℤ/Nℤ`
(e.g. `S = {±g^k}` for a primitive root `g`) whose `cayleyAdj N S` satisfies a
sharp Ramanujan bound for all `N` in an arithmetic progression, giving a
truncation-stable family of graph-RH instances. *Why now?* The self-adjoint
framework and the truncation-stability theorem are in place; the missing piece is
a concrete eigenvalue estimate, reducible to Gauss/Kloosterman sum bounds already
adjacent to `Catalog/EML/ModularForms.lean`.

### 3. From bijection of points to bijection of *counting functions*
The current `zetaEquiv` matches individual points; the deeper conjecture matches
*densities*. **The key insight is** that a stable holographic dictionary should
intertwine the eigenvalue-counting function `N_H(t) = #{eigenvalues ≤ t}` of the
model with the zero-counting function of zeta, up to the explicit Riemann–von
Mangoldt main term `(t/2π) log(t/2π) − t/2π`. Conjecture: there is a normalization
of `cayleyAdj N S` under which the empirical eigenvalue-counting function converges
to the Riemann–von Mangoldt density as `N → ∞`. *Why now?* With self-adjointness
and on-line placement proved, counting-function asymptotics become a tractable
analytic-number-theory target rather than a structural one.

### 4. Trace-formula bridge to a length spectrum
**The key insight is** that the Selberg/Ihara trace formula equates a spectral sum
over eigenvalues with a geometric sum over closed geodesics (graph cycles), so a
holographic dictionary on the spectrum *forces* a dual dictionary on the length
spectrum. Conjecture: for the Cayley family, `tr(f(cayleyAdj N S))` admits a closed
cycle-length expansion whose leading term, under the `zetaMap` normalization,
reproduces the prime-counting main term `∑ Λ(n)`. *Why now?* The trace
`∑_i f(λ_i) = tr f(A)` is immediate from the spectral theorem already used in
`IsHermitian.zetaMap_eigenvalue_mem_criticalLine`; only the geometric side needs
new cycle-counting lemmas.

### 5. Off-line refutation as a certified search procedure
**The key insight is** that `zetaMap_offLine_refutes_selfAdjoint` turns the
conjecture into a *certified falsification engine*: any verified zero with
`Re s ≠ 1/2` would mechanically rule out every self-adjoint model. Conjecture:
one can formalize a decidable predicate `OnLine s` and a transfer lemma showing
that a single certified off-line zero contradicts the existence of *any* Hermitian
realization of the zeros, making the Hilbert–Pólya program a verifiable
all-or-nothing statement inside Lean. *Why now?* The falsifiability lemma already
exists; wrapping it in a `Decidable` interface and a contrapositive transfer is a
short, high-value formalization step.
