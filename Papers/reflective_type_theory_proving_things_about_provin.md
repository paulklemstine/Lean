# Computational Evidence: Reflective Type Theory

## Small-case calculation: the witnessing model
Frame on three stages `{0, 1, 2}` with step relation `R = {2⟶1, 1⟶0}`
(non-transitive: `2⟶1⟶0` but not `2⟶0`). Take `P = {1}`.

Stage-by-stage membership:

| world w | successors | w ∈ □P ? | w ∈ □□P ? |
|--------:|-----------:|:--------:|:---------:|
| 0       | none       | yes (vacuous) | yes (vacuous) |
| 1       | {0}        | 0∈P? no ⇒ **no** | — |
| 2       | {1}        | 1∈P? yes ⇒ **yes** | need 1∈□P; but 1∉□P ⇒ **no** |

So at stage `2`: `□P` holds while `□□P` fails — a concrete inhabitant of
`□P ∧ ¬□□P`. This is `provable_not_provably_provable`.

## Counterexample hunt for the boundary
We searched for any *transitive* frame realising `□P ∧ ¬□□P`. None exists: if
`R` is transitive then `w ∈ □P` and `R w v`, `R v u` give `R w u`, hence `u ∈ P`,
so `v ∈ □P` and therefore `w ∈ □□P`. This is exactly `box_four_of_transitive`,
confirming the phenomenon is unique to non-transitive reflection.

## Sanity checks on the modality laws
Testing the normal-modality package on the empty/terminal stage:
- `0 ∈ □∅` (vacuously, no successors) — consistent with `box_necessitation`
  degenerating at leaves.
- Monotonicity, `∩`-preservation, `K`, and the `◇ = ¬□¬` duality were checked to
  hold on the three-stage frame and are proved in general.

## Fixpoint spot-check (μ-calculus link)
For the three-stage frame, iterating `□` from the top element `univ` stabilises
after finitely many steps at the greatest fixpoint, matching the general
`box_gfp_fixpoint`; iterating from `∅` gives the least fixpoint `box_lfp_fixpoint`.
No infinite ascending chain exists here, so Löb's law `loeb` applies.

## Note on scope
The claims are finite/combinatorial at their core (finite frames suffice to
witness satisfiability and non-satisfiability), so the evidence above is
exhaustive for the separating example, and the general statements are then
established uniformly.


# Computational Evidence: Reflective Type Theory

## Small-case calculation: the witnessing model
Frame on three stages `{0, 1, 2}` with step relation `R = {2⟶1, 1⟶0}`
(non-transitive: `2⟶1⟶0` but not `2⟶0`). Take `P = {1}`.

Stage-by-stage membership:

| world w | successors | w ∈ □P ? | w ∈ □□P ? |
|--------:|-----------:|:--------:|:---------:|
| 0       | none       | yes (vacuous) | yes (vacuous) |
| 1       | {0}        | 0∈P? no ⇒ **no** | — |
| 2       | {1}        | 1∈P? yes ⇒ **yes** | need 1∈□P; but 1∉□P ⇒ **no** |

So at stage `2`: `□P` holds while `□□P` fails — a concrete inhabitant of
`□P ∧ ¬□□P`. This is `provable_not_provably_provable`.

## Counterexample hunt for the boundary
We searched for any *transitive* frame realising `□P ∧ ¬□□P`. None exists: if
`R` is transitive then `w ∈ □P` and `R w v`, `R v u` give `R w u`, hence `u ∈ P`,
so `v ∈ □P` and therefore `w ∈ □□P`. This is exactly `box_four_of_transitive`,
confirming the phenomenon is unique to non-transitive reflection.

## Sanity checks on the modality laws
Testing the normal-modality package on the empty/terminal stage:
- `0 ∈ □∅` (vacuously, no successors) — consistent with `box_necessitation`
  degenerating at leaves.
- Monotonicity, `∩`-preservation, `K`, and the `◇ = ¬□¬` duality were checked to
  hold on the three-stage frame and are proved in general.

## Fixpoint spot-check (μ-calculus link)
For the three-stage frame, iterating `□` from the top element `univ` stabilises
after finitely many steps at the greatest fixpoint, matching the general
`box_gfp_fixpoint`; iterating from `∅` gives the least fixpoint `box_lfp_fixpoint`.
No infinite ascending chain exists here, so Löb's law `loeb` applies.

## Note on scope
The claims are finite/combinatorial at their core (finite frames suffice to
witness satisfiability and non-satisfiability), so the evidence above is
exhaustive for the separating example, and the general statements are then
established uniformly.
