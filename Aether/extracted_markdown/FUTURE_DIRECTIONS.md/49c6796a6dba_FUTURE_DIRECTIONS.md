# Future Directions — Tropical Helly Certificates via Finite Closure-Probe Systems

The new module `Catalog/Bridges/TropicalHellyClosure.lean` recasts tropical
halfspace feasibility as a problem about a single canonical closure operator — the
**consequence closure** `consequenceClosure H G = {j | (⋂ i∈G, H i) ⊆ H j}` — and
turns *geometric infeasibility* into the *combinatorial event* "a `⊥` sentinel
enters the closure" (`infeasible_iff_sentinel_mem_closure`). It then proves that
**one-sided** tropical halfspaces `{x | ⨆ k (aₖ + xₖ) ≥ b}` are always jointly
feasible (`tropHalfspace_iInter_nonempty`), so no infeasibility certificate can
ever exist for them (`tropHalfspace_no_infeasibility_certificate`). The directions
below extend this bridge from "no certificate exists" to "small certificates always
exist" in the genuinely infeasible two-sided regime.

## Direction 1: Two-sided tropical halfspaces and the first real certificates

Replace one-sided constraints with *two-sided* tropical halfspaces of
Develin–Sturmfels type, `{x | ⨆_{k∈I}(aₖ + xₖ) ≥ ⨆_{k∈J}(cₖ + xₖ)}` where `I, J`
partition the coordinates. Conjecture: a finite family of such sets in `ℝⁿ` with
empty intersection has a certificate subfamily of size at most `n+1` whose
consequence closure already contains the `⊥` sentinel, and this bound is tight.

The key insight is that two-sided constraints are exactly what make the realized
intersection `realized H G` collapse to `∅` for some bounded `G`, so the upward-closed
certificate poset (proved here via `infeasible_mono`) acquires *minimal* elements of
controlled size — turning the vacuous "no certificate" theorem into a quantitative
Helly-number statement. Why now? The current file already supplies the closure
operator, the sentinel encoding, the infeasibility-iff-sentinel equivalence, and
the monotonicity needed to define minimal certificates; only the two-sided geometry
is missing, and `IsTropConvex.inter`/`tropHalfspace_isTropConvex` from
`TropicalHelly.lean` give the convexity inputs for an induction on `n`.

## Direction 2: A certified extraction algorithm with a correctness theorem

Define an explicit function `extractCertificate : Finset ι → Option (Finset ι)`
that, given a finite family, returns a minimal index subset whose closure reaches
`⊥` (or `none` when the family is feasible), and prove `extractCertificate F = some C
→ realized H ↑C = ∅ ∧ C ⊆ F` together with minimality `∀ C' ⊂ C, realized H ↑C' ≠ ∅`.

The key insight is that the consequence closure is *finitary* on finite carriers, so
greedy removal of redundant indices is a terminating closure-stabilization loop whose
fixed point is exactly a minimal certificate — the same finite-witness phenomenon that
`Bridges/AlgebraEMLReconstruction.lean` exploits in `algebraicLike_finite_witness`.
Why now? `consequenceClosure_idempotent` and `consequenceClosure_monotone` already
certify the loop invariant, and `infeasible_mono` certifies that removing a
non-redundant index cannot destroy infeasibility; the only remaining work is the
`Finset` recursion and its termination measure.

## Direction 3: Helly number = closure rank of the consequence operator

Define the *closure rank* of `consequenceClosure H` as the length of the longest
strictly increasing chain `G₀ ⊊ cl G₀ ⊊ cl² G₀ ⊊ …` of closed sets, and conjecture
that the tropical Helly number of the family `H` equals this rank plus one whenever
the underlying sets are tropically convex.

The key insight is that Helly numbers are usually proved by ad hoc dimension
induction, but the consequence closure exposes them as an *intrinsic lattice
invariant* of the closed-set lattice, decoupling the combinatorial Helly bound from
the ambient coordinate dimension `n`. Why now? The closed-set lattice is already
available through `consequenceClosure_idempotent` (every closure value is a fixed
point), and the EML reconstruction file's `closure_eq_of_sameClosedSets` shows the
lattice determines the operator — so "Helly number = lattice invariant" is the
natural next theorem on top of both files.

## Direction 4: Discretized coordinates give an effective, decidable certificate search

Restrict tropical halfspaces to integer (or `Fin q`-valued) coefficients and a
bounded coordinate box, and conjecture that feasibility becomes decidable with a
certificate whose size is bounded by an explicit function of `n` and the bit-width,
recovered by enumerating closed sets of `consequenceClosure`.

The key insight is that discretization makes `Set ι` and the candidate point space
both finite, so the consequence closure becomes a *computable* `Finset`-valued
operator and the sentinel test `none ∈ cl(...)` becomes a decidable predicate — the
infeasibility-iff-sentinel bridge then yields a verified decision procedure, not just
an existence theorem. Why now? The present file is fully constructive apart from the
real-valued witness in `tropHalfspace_iInter_nonempty`; swapping `ℝ` for a
`LinearOrderedField` with decidable order (or `ℤ`) is a mechanical generalization
that immediately unlocks `Decidable` instances.

## Direction 5: Closure-pressure thermodynamics of certificate families

Couple the consequence closure to the finite Gibbs/pressure formalism of
`Bridges/AlgebraicEMLThermodynamicFormalism.lean`: assign each subfamily `G` an
energy `−log |closed sets above G|` and conjecture that the partition function over
certificate subfamilies has a phase transition exactly at the Helly number, with the
free energy detecting the onset of infeasibility.

The key insight is that the upward-closed poset of infeasible subfamilies (built here
from `infeasible_mono`) is a monotone lattice ideal, and monotone ideals are precisely
where closure-pressure functionals are convex — so a thermodynamic order parameter can
*detect* the smallest certificate without enumerating it. Why now? Both ingredients
now live in the same `Bridges/` namespace: this file supplies the certificate lattice
and the thermodynamic formalism file supplies `closurePressure` and
`closurePartitionFunction`, so the coupling is a direct cross-domain composition.
