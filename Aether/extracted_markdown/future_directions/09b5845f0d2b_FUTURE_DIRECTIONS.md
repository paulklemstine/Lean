# Future Directions: Tropical Helly Certificates from Finite Closure Systems

## 1. Dimension-Dependent Helly Bounds via Closure Rank

The obstruction closure operator `obstructionCl` collapses to `Finset.univ` for
any infeasible subfamily (since the empty feasible region is trivially contained
in every halfspace). This means the "naive" closure cannot distinguish different
infeasible subfamilies. A *refinement* would track not just implication but
*degree of implication*: define a graded closure where `cl_k(S)` consists of
indices `j` such that `H j` is implied by at most `k` constraints from `S`.
The conjecture is that for tropical halfspaces in `ℝⁿ`, `cl_{n+1}(S)` already
equals the full obstruction closure, recovering the tropical Helly number `n+1`.

The key insight is that the Helly number should emerge as the *stabilization
index* of this graded closure filtration, connecting combinatorial dimension
to closure-theoretic rank in a way that makes the tropical Helly theorem a
consequence of finite closure stabilization.

Why now? The current file proves that the obstruction closure forms a valid
`FiniteClosureSystem'` and that feasible regions are invariant under closure.
The graded refinement would give the first closure-theoretic proof of the
tropical Helly theorem, which remains sorry'd in `TropicalHelly.lean`.

## 2. Tropical Farkas Duality via Closed-Set Lattice Isomorphism

The theorem `obstructionCl_eq_iff_feasibleRegion_eq` establishes that the
closed-set lattice of the obstruction closure is isomorphic to the lattice of
feasible regions. For tropical halfspaces specifically, this lattice should be
isomorphic to the face lattice of a tropical polytope. The conjecture: the
atoms of this lattice (minimal non-trivial closed sets) correspond to the
vertices of the tropical polytope dual to the halfspace arrangement, and
the tropical Farkas lemma (`tropical_farkas_weak` in `TropicalHelly.lean`)
can be restated as a covering condition on the closed-set lattice.

The key insight is that the Farkas alternative (either the intersection is
nonempty or there exists a "separating" configuration) should correspond
exactly to the dichotomy between the closed-set lattice having a minimum
element vs. being filtered.

Why now? The lattice isomorphism `obstructionCl_eq_iff_feasibleRegion_eq`
is the needed algebraic handle; combining it with the existing weak Farkas
lemma should yield the full tropical Farkas theorem.

## 3. Algorithmic Certificate Extraction via Irredundant Bases

The theorem `irredundant_not_in_cl_erase` shows that irredundant sets have
no element implied by the rest. Conjecture: every feasible subfamily can be
algorithmically reduced to an irredundant subset with the same closure (hence
the same feasible region), and this irredundant basis has cardinality at most
`n + 1` for tropical halfspaces in `ℝⁿ`. This would give a constructive,
formally verified algorithm for extracting minimal feasibility certificates.

The key insight is that the greedy deletion algorithm (remove constraints one
at a time while preserving the feasible region) always terminates at an
irredundant set, and the bound `n + 1` on irredundant set size would follow
from the tropical Helly theorem applied to the complementary family.

Why now? The irredundancy theory (`IsIrredundant`, `irredundant_not_in_cl_erase`)
is now formalized, providing the foundation for greedy extraction algorithms.

## 4. Connection to Matroid Theory via Closure Exchange

The obstruction closure satisfies extensive, monotone, and idempotent, but not
necessarily the *exchange property* (Mac Lane–Steinitz). Conjecture: for
tropical halfspaces in general position, the obstruction closure satisfies
the exchange property and thus defines a matroid on constraint indices. The
independent sets of this matroid would be exactly the irredundant subfamilies,
and the matroid rank would equal the tropical Helly number `n + 1`.

The key insight is that general-position tropical halfspaces should satisfy
a tropical analogue of linear independence, making the obstruction closure
a *geometric lattice* and connecting tropical Helly theory to matroid duality.

Why now? The closure axioms are verified; the exchange property is the single
missing axiom for matroid structure, and it should be testable computationally
for small dimensions.

## 5. Thermodynamic Pressure on the Obstruction Closure Lattice

The `FiniteClosureSystem'` structure connects to the `FiniteClosureSystem`
from `AlgebraicEMLThermodynamicFormalism.lean`, which already defines closure
pressure and Gibbs states. Conjecture: the partition function over the
closed-set lattice of the obstruction closure, weighted by feasible-region
volume, recovers a tropical analogue of the Barvinok partition function,
and its pressure at inverse temperature β → ∞ selects the closed set with
maximum feasible-region volume (i.e., the least constrained subfamiliy).

The key insight is that the Gibbs fixed-point theorem
(`closureGibbs_fixed_point_uniform_of_zero_potential`) should specialize to
a tropical equilibrium theorem when applied to the obstruction closure lattice.

Why now? Both the obstruction closure system and the thermodynamic formalism
are now formalized; the bridge requires only defining the appropriate energy
functional on the closed-set lattice and invoking existing pressure bounds.
