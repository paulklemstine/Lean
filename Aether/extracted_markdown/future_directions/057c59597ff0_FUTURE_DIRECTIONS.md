# Future Directions — Proof Phase Transitions in Random k-SAT

The file `Catalog/Physics/ProofPhaseTransitions/RandomKSAT.lean` establishes, fully
formally and `sorry`-free, the **first-moment (annealed) counting identity** for the
random `k`-SAT model with replacement,

>  `∑_F #{a : a ⊨ F} = 2^n · ((2n)^k − n^k)^m`  (`first_moment`),

together with the **sharp existence threshold** it implies: once the first moment falls
below the number of formulas, an unsatisfiable instance is forced to exist
(`exists_unsat`), and its statistical-physics density form
`2^n · (1 − 2^{−k})^m < 1 ⟹ ∃` unsatisfiable formula (`exists_unsat_of_real_density`).

These results are the rigorous "upper half" of the satisfiability phase transition. The
directions below are concrete, falsifiable, and each is a natural next Lean target. They
also indicate cross-domain bridges to existing catalog material (entropy/partition
functions in `Shared/EntropyAlgebra.lean`, tropical/idempotent counting in `Tropical/`,
and the probabilistic method in `Speculative/ProbabilisticMethod/Core.lean`).

## Direction 1 — A second-moment satisfiability lower bound

Prove the complementary half: if the clause density is *below* the first-moment
threshold by a constant factor, then a uniformly random formula is satisfiable with
probability bounded away from `0`. Concretely, formalize the inequality
`(E[X])^2 ≤ P(X > 0) · E[X^2]` (Paley–Zygmund / Cauchy–Schwarz) for `X` = number of
satisfying assignments, and bound `E[X^2]` by computing the exact two-assignment
correlation `∑_{a,b} (per-clause joint-sat probability)^m` as an explicit function of the
Hamming distance `d(a,b)`.

The key insight is that the second moment factorizes over clauses exactly as the first
moment does, so `E[X^2] = ∑_{a,b} ((2n)^k − 2·n^k + u(a,b))^m / (2n)^{km}` where
`u(a,b)` counts clauses falsified by *both* `a` and `b`, a quantity that depends only on
`|a Δ b|`; this reduces the whole estimate to a one-dimensional sum over Hamming
distance that the same `subtypePiEquivPi`/`Fintype.card_pi` machinery already in the file
can evaluate. Why now? The counting infrastructure (`card_unsat_clause`, `card_sat_form`)
is exactly the per-clause factorization needed, so the second moment is a *finite,
closed-form* `Fintype.card` computation rather than an analytic estimate — no new
probability theory is required, only one more application of the tools already proved.

## Direction 2 — Sharpness of the threshold (a 0/1 transition window)

Conjecture and formalize that the existence threshold is *sharp* in `m`: there is an
explicit width `w(n,k)` such that for `m` below `m*(n,k) − w` every formula in a positive
fraction is satisfiable, while for `m` above `m*(n,k) + w` the first moment already forces
unsatisfiability, with `w(n,k) = O(1)` independent of `n` for fixed `k`.

The key insight is that `m ↦ 2^n(1 − 2^{−k})^m` is strictly log-linear, so the crossing
of the value `1` happens within a single unit interval of `m`, giving a transition window
whose width is governed entirely by `−1/log(1 − 2^{−k})` and not by `n`. Why now? The
density criterion `exists_unsat_of_real_density` already isolates the exact real-analytic
quantity whose sign flips; bounding the integer crossing point is a monotonicity argument
on a concrete real sequence, well within reach of `Mathlib`'s `StrictMono`/`Real.log`
API and directly extends the theorem just proved.

## Direction 3 — The "without replacement" model and an exact binomial identity

Re-derive the first moment for the *combinatorial* random `k`-SAT model in which each
clause uses `k` distinct variables with independent signs. Conjecture the exact identity
`∑_F #{a : a ⊨ F} = 2^n · (C(n,k)·2^k − C(n,k))^m = 2^n · (C(n,k)·(2^k − 1))^m`
over the space of `m`-tuples of such clauses, and the corresponding threshold
`2^n · (1 − 2^{−k})^m < 1` (identical density form, different normalization).

The key insight is that switching from "literals with replacement" to "distinct-variable
clauses" only replaces the per-clause base count `(2n)^k` by `C(n,k)·2^k` while the
*unsatisfied* fraction stays exactly `2^{−k}`, so the physics-level density threshold is
model-independent even though the underlying `Fintype` changes. Why now? The proof reuses
`subtypePiEquivPi` verbatim after replacing `Lit n` with the subtype of injective
literal tuples; the only new ingredient is `Fintype.card` of `k`-subsets, for which
`Mathlib` already has `Finset.card_powersetCard`, making this a clean re-instantiation of
the existing file.

## Direction 4 — General finite-domain CSP and a product partition function

Generalize from Boolean variables to variables over a finite domain of size `q` and from
clauses forbidding one assignment-pattern to constraints forbidding `r` of the `q^k`
local patterns. Conjecture the first-moment identity
`∑_F #{a : a ⊨ F} = q^n · (q^k − r)^m` and the threshold
`q^n · (1 − r·q^{−k})^m < 1 ⟹ ∃` unsatisfiable instance, recovering the Boolean case at
`q = 2, r = 1`.

The key insight is that the entire argument is a statement about the *partition function*
`Z = ∑_a w(a)` of a product weight `w(a) = ∏_clauses [a satisfies clause]`, so the
annealed average `E[Z]` always factorizes as `q^n · (fraction of allowed local
patterns)^m` regardless of the alphabet — the threshold is a sign change of `log E[Z]`,
i.e. of an annealed free energy. Why now? This reframes the catalog's
`Shared/EntropyAlgebra.lean` partition-function/entropy results as the `q`-ary free energy
of a random CSP, turning a Physics-domain counting theorem into an honest cross-domain
bridge (Physics ↔ Algebra/Entropy) with `q^n(1 − r q^{−k})^m` as the shared invariant.

## Direction 5 — Tropical (min-plus) free energy and a zero-temperature transition

Lift the partition function `Z = ∑_a w(a)` to the **tropical semiring**, where addition
is `min` and multiplication is `+`, so that `Z_trop(F) = min_a (#clauses falsified by a)`
is the minimum number of unsatisfied clauses (the MAX-SAT optimum). Conjecture a tropical
first-moment law bounding `E[Z_trop]` and a *zero-temperature* threshold: above the
density at which `2^n(1 − 2^{−k})^m < 1`, we have `Z_trop(F) ≥ 1` for almost all `F`
(every assignment falsifies a clause), matching the Boolean `exists_unsat`.

The key insight is that the ordinary first moment `E[X] = E[∑_a 1_{Z_trop = 0}]` is
exactly the count of *zero-temperature ground states*, so `exists_unsat` is precisely the
statement that the tropical optimum jumps off `0`; the tropical lift therefore reinterprets
the satisfiability transition as a discontinuity in a min-plus free energy. Why now? The
`Tropical/` catalog already develops min-plus algebra and `Tropical/FiberEntropy.lean`
develops fiber counting, so the tropical free energy `Z_trop` can be built directly on
that infrastructure, connecting the Physics phase-transition theorem to the project's
largest (1353-theorem) tropical corpus through a single shared object: the random-formula
partition function.
