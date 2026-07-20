# Computational Evidence

## Small-case calculations

For a finite window `Z`, define `H(Z) = Σ_{ρ∈Z} ρ⁻¹`.

| Window | Harmonic |
|---|---:|
| `∅` | `0` |
| `{ρ}` | `ρ⁻¹` |
| `{ρ, conjugate(ρ)}` with nonreal `ρ` | `2 Re(ρ) / |ρ|²` |
| Distinct roots `{α,β}` of `1-lu+qu²` | `l/q` |

The last identity follows from `α+β=l` and `αβ=q`:
`α⁻¹+β⁻¹=(α+β)/(αβ)=l/q`.

For the proposed zeta cutoffs, standard high-precision tables place the first positive ordinate of a nontrivial Riemann-zeta zero near `14.1347`. Thus numerical exploration predicts that the windows at cutoffs `2` and `3` are both empty and both harmonics are `0`. This numerical fact is recorded only as evidence; the mathematical results use an explicit emptiness hypothesis rather than treating a decimal computation as a proof.

## OEIS search results

No integer sequence is naturally produced by the reciprocal sums at cutoffs `2` and `3`, since both predicted windows are empty. No OEIS identification is claimed.

## Counterexample hunt

The proposed statements `H(2)=1` and “`H(3)` is transcendental” fail immediately if the corresponding windows are empty: the empty sum is `0`, which is rational and not `1`. The formal development proves this implication exactly.

A second edge case appeared in the finite graph model. A `Finset` removes duplicate roots, so the identity `H({α,β})=l/q` needs `α≠β`; at a repeated root the coefficient-ratio formula counts multiplicity while the set does not. The theorem therefore includes a distinct-root hypothesis.

## Relevant table

| Claim under investigation | Evidence status | Outcome |
|---|---|---|
| Cutoff `2` harmonic equals `1` | First known ordinate is far above `2` | Refuted conditional on certified window emptiness |
| Cutoff `3` harmonic is transcendental | First known ordinate is far above `3` | Refuted conditional on certified window emptiness |
| Conjugate-paired harmonic is real | Exact finite algebra | Proved |
| Separated-window harmonic obeys a counting bound | Triangle inequality and inverse norm bound | Proved |
| Quadratic graph-zeta harmonic is rational for rational coefficients | Vieta relations | Proved for distinct roots |
