# Future Directions — Proof Phase Transitions in Random k-SAT

The file `Physics/ProofPhaseTransitions/RandomKSAT.lean` now establishes, fully formally
and `sorry`-free (only `propext`, `Classical.choice`, `Quot.sound`):

* an **abstract partition-function first-moment law** `first_moment_general`: for any finite
  CSP whose every assignment satisfies a *constant* number `S` of constraints,
  `∑_F #{a : a ⊨ F} = |A| · S^m`, with the pigeonhole corollary `exists_unsat_general`
  (`|A|·S^m < |C|^m ⟹ ∃` unsatisfiable formula);
* the **Boolean k-SAT** instantiation `first_moment` (`= 2^n·((2n)^k − n^k)^m`),
  `exists_unsat`, and the density form `exists_unsat_of_real_density`
  (`2^n·(1 − 2^{−k})^m < 1 ⟹ ∃` unsat);
* **threshold monotonicity** `exists_unsat_of_density_mono`: the unsatisfiable region is an
  up-set in the clause count `m`;
* the **q-ary CSP generalization** `Qary.first_moment`
  (`= q^n·((nq)^k − (n(q−1))^k)^m`), `Qary.exists_unsat`, and
  `Qary.exists_unsat_of_real_density` with the model-independent density factor
  `1 − ((q−1)/q)^k` reducing to `1 − 2^{−k}` at `q = 2`.

These are the rigorous "upper half" (annealed/first-moment) of the satisfiability phase
transition, plus its monotonicity and its alphabet-independence. The directions below are
the natural next Lean targets. They reuse the per-constraint factorization machinery
(`card_models_form`, `card_sat_clause`, `card_qsat_clause`) already proved, and they
bridge to other catalog corpora (`Shared/EntropyAlgebra.lean`, `Tropical/`,
`Speculative/ProbabilisticMethod/Core.lean`).

## Direction 1 — A second-moment satisfiability lower bound

Prove the complementary "lower half": if the clause density is below the first-moment
threshold by a constant factor, a uniformly random formula is satisfiable with probability
bounded away from `0`. Formalize the Paley–Zygmund / Cauchy–Schwarz inequality
`(E[X])^2 ≤ P(X > 0)·E[X^2]` for `X = #{a : a ⊨ F}`, and compute `E[X^2]` as the exact
two-assignment correlation sum.

The key insight is that the second moment factorizes over clauses *exactly as the first
moment does* in `first_moment_general`, so
`E[X^2] = ∑_{a,b} ((2n)^k − 2·n^k + u(a,b))^m / (2n)^{km}`, where `u(a,b)` counts clauses
falsified by both `a` and `b` and depends only on the Hamming distance `|a Δ b|`; this
collapses the estimate to a one-dimensional sum over Hamming distance evaluable by the same
`Equiv.subtypePiEquivPi`/`Fintype.card_pi` toolkit already used for `card_unsat_clause`.
Why now? The single-assignment factorization is finished and proved; the joint
two-assignment count is the *same* `Fintype.card` computation with two predicates instead of
one, so the second moment is a finite closed-form cardinality rather than an analytic
estimate — no measure theory is needed, only one more application of the proved tools.

## Direction 2 — Exact integer crossing point of the threshold window

Strengthen `exists_unsat_of_density_mono` (which already shows the unsat phase is upward
closed) to pin the *exact* crossing clause-count
`m*(n,k) = ⌈ n / (−log₂(1 − 2^{−k})) ⌉`, proving every `m ≥ m*` is first-moment-unsat while
the real density exceeds `1` for every `m < m*`, so the transition window has width `< 1`
in `m` (independent of `n` for fixed `k`).

The key insight is that `m ↦ 2^n·(1 − 2^{−k})^m` is *strictly log-linear*: taking `log₂`
turns the threshold `2^n·(1 − 2^{−k})^m < 1` into the linear inequality
`n + m·log₂(1 − 2^{−k}) < 0`, whose integer solution set is exactly `{ m ≥ m* }` for a single
explicit `m*`. Why now? `exists_unsat_of_real_density` already isolates the real-analytic
quantity whose sign flips, and `exists_unsat_of_density_mono` already proves upward-closedness;
locating `m*` is a `Nat.ceil`/`Real.logb` monotonicity computation squarely inside Mathlib's
`StrictMono`/`Real.log` API, extending two theorems that are now in hand.

## Direction 3 — The "without replacement" model and a binomial first moment

Re-derive the first moment for the *combinatorial* random k-SAT model in which each clause
uses `k` distinct variables with independent signs. Conjecture the identity
`∑_F #{a : a ⊨ F} = q^n · (C(n,k)·2^k − C(n,k))^m = 2^n · (C(n,k)·(2^k − 1))^m` and the
same density threshold `2^n·(1 − 2^{−k})^m < 1`.

The key insight is that switching from "literals with replacement" to "distinct-variable
clauses" only replaces the per-clause base count `(2n)^k` by `C(n,k)·2^k` while the
*unsatisfied fraction stays exactly* `2^{−k}`, so the physics-level density threshold is
model independent — exactly the alphabet-independence already proved for the q-ary model in
`Qary.exists_unsat_of_real_density`, now in a different combinatorial direction. Why now?
The proof reuses `first_moment_general` verbatim after replacing the constraint type by the
subtype of injective literal tuples; the only new ingredient is the cardinality of
`k`-subsets, for which Mathlib has `Finset.card_powersetCard`, making this a clean
re-instantiation of the abstract law.

## Direction 4 — General partition function from `Shared/EntropyAlgebra.lean`

Reframe `first_moment_general` as a statement about the *annealed free energy* of a random
CSP: the quantity `log E[Z]` where `Z = ∑_a w(a)` and `w(a) = ∏_clauses [a ⊨ clause]` is a
product weight. Conjecture that the entropy/partition-function results in
`Shared/EntropyAlgebra.lean` give `log E[Z] = n·log q + m·log(allowed-fraction)`, so the
satisfiability threshold is precisely the sign change of an annealed free energy, and the
existing `exists_unsat_general` becomes a *zero of the annealed partition function*.

The key insight is that the whole first-moment argument is the statement `E[Z] = q^n·(allowed
fraction)^m`, i.e. the partition function factorizes into a site term `q^n` and a bond term
`(allowed fraction)^m` — exactly the structure of the entropy-algebra partition functions in
the catalog. Why now? `first_moment_general` is already stated for an arbitrary finite CSP
with constant per-constraint count, so bridging it to `Shared/EntropyAlgebra.lean` requires
only identifying `S/|C|` with the catalog's "allowed fraction" weight, turning a Physics
counting theorem into an honest Physics ↔ Algebra/Entropy bridge with `q^n·(1 − r q^{−k})^m`
as the shared invariant.

## Direction 5 — Tropical (min-plus) free energy and the MAX-SAT optimum

Lift `Z = ∑_a w(a)` to the tropical semiring (addition `min`, multiplication `+`), so that
`Z_trop(F) = min_a #{clauses falsified by a}` is the MAX-SAT optimum. Conjecture a tropical
first-moment law bounding `E[Z_trop]` and a *zero-temperature* threshold: above the density
where `2^n·(1 − 2^{−k})^m < 1`, `Z_trop(F) ≥ 1` for almost all `F` (every assignment
falsifies some clause), matching `exists_unsat`.

The key insight is that the ordinary first moment `E[X] = E[∑_a 1_{Z_trop = 0}]` is exactly
the count of *zero-temperature ground states*, so `exists_unsat` is precisely the statement
that the tropical optimum jumps off `0`; the tropical lift reinterprets the satisfiability
transition as a discontinuity in a min-plus free energy. Why now? The `Tropical/` corpus
already develops min-plus algebra and fiber counting (`Tropical/FiberEntropy.lean`), so
`Z_trop` can be built directly on that infrastructure, connecting the Physics phase-transition
theorems to the project's largest tropical corpus through one shared object — the
random-formula partition function — whose `+`-image is the first moment and whose
`min`-image is the MAX-SAT optimum.
