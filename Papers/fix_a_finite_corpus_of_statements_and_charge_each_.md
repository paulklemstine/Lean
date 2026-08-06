# Computational Evidence — Fitness Landscapes of Mathematical Theories

All numbers below were produced by `#eval` inside the Lean development itself
(`Catalog/Pythagorean/TheoryFitness/*.lean`), so the model used for the evidence
is literally the model that the theorems are about.  Each table is followed by
the theorem in the development that turns the observation into a proof.

## 1. Candidate populations: exact counts of usable sub-libraries

A *usable sub-library* of a library `U` is a subset of `U` closed under direct
dependencies.  Two extreme dependency structures, `n = 0, …, 8`:

| n | independent (`noDeps`) | chain (`chainDeps`) |
|---|---|---|
| 0 | 1 | 1 |
| 1 | 2 | 2 |
| 2 | 4 | 3 |
| 3 | 8 | 4 |
| 4 | 16 | 5 |
| 5 | 32 | 6 |
| 6 | 64 | 7 |
| 7 | 128 | 8 |
| 8 | 256 | 9 |

The two sequences are `2^n` (OEIS **A000079**: 1, 2, 4, 8, 16, 32, 64, 128, 256)
and `n + 1` (OEIS **A000027** shifted: 1, 2, 3, 4, 5, …).  Both are *proved*
exactly, not merely observed: `card_closedSubsets_independent`,
`card_closedSubsets_chain`, and the strict gap `chain_lt_independent`
(for `n ≥ 2`).  The multiplicativity behind "independent populations multiply"
is proved by an explicit bijection in `closedSubsets_mul_of_split`.

## 2. The composition phase transition

Two libraries of four declarations each (uniform source length 10) sharing two
declarations.  Duplicated cost `80`, pooled cost `60`, shared mass `20`, corpus
of `4` statements.  Fitness of the composite as a function of the adapter
charge `A`:

| A | composed cost | composed fitness | vs duplicated fitness `1/20` |
|---|---|---|---|
| 0 | 60 | 1/15 ≈ 0.0667 | gain |
| 5 | 65 | 4/65 ≈ 0.0615 | gain |
| 10 | 70 | 2/35 ≈ 0.0571 | gain |
| 15 | 75 | 4/75 ≈ 0.0533 | gain |
| **20** | **80** | **1/20 = 0.0500** | **neutral (threshold)** |
| 25 | 85 | 4/85 ≈ 0.0471 | loss |
| 30 | 90 | 2/45 ≈ 0.0444 | loss |

The transition sits exactly at `A = sharedMass = 20`.  This is proved as an
if-and-only-if in `compose_gain_iff_adapter_lt_shared`, `compose_neutral_iff`,
`compose_loss_iff`, in normalised density form in `compose_gain_iff_density`,
and instantiated on this very table in `phaseTransitionUp`,
`phaseTransitionCritical`, `phaseTransitionDown`.

## 3. k-fold reuse: library versus a suite of specialists

Core of cost `100`, private material of cost `10` per specialist:

| k | shared library | suite of specialists | saving |
|---|---|---|---|
| 1 | 110 | 110 | 0 |
| 2 | 120 | 220 | 100 |
| 3 | 130 | 330 | 200 |
| 4 | 140 | 440 | 300 |
| 5 | 150 | 550 | 400 |
| 6 | 160 | 660 | 500 |

The saving is exactly `(k − 1) ·` core, as proved by the accounting identity
`cost_library_add_card_core` and its strict consequences
`library_cost_lt_specialists`, `library_fitness_gt_specialists`.

## 4. Counterexample hunt: is raw fitness bounded?

In the concrete `sqrtLanguage` (adding `n` independently stated consequences
costs `Nat.sqrt n` extra lines), starting from the development `(1 theorem,
1 line)`:

| n | count | length | raw fitness |
|---|---|---|---|
| 0 | 1 | 1 | 1 |
| 4 | 5 | 3 | 5/3 ≈ 1.67 |
| 16 | 17 | 5 | 17/5 = 3.4 |
| 100 | 101 | 11 | 101/11 ≈ 9.2 |
| 10 000 | 10 001 | 101 | ≈ 99.0 |
| 1 000 000 | 1 000 001 | 1001 | ≈ 999.0 |

No maximum was found, and none exists: `no_global_maximum` proves raw fitness is
unbounded on any language with conservative sublinear inflation, and
`unbounded_witnesses_are_semantically_inert` proves that every witness in the
divergent family has *the same semantics* as the development it came from.  The
hunt for a bounded example therefore fails by theorem, not by sampling.

## 5. The three-style landscape

Measured fitness of nine developments, three per methodological style
(algebraic `0,1,2`; analytic `3,4,5`; combinatorial `6,7,8`):

```
style      0  0  0 | 1  1  1 | 2  2  2
fitness    1  2  5 | 3  7  4 | 6  2  9
```

Local maxima under style-preserving refactorings: indices `2`, `4`, `8`, one per
style, with only `8` global.  Proved in `three_style_metastability` and
`three_style_not_global` via the general `strictLocalMax_of_style_closed`.

## 6. Adapter valley instance

Migration `A → adapter → B` with content `100`, endpoints of length `110`
(`1.1`-efficient) and adapter state of length `150` (`1.5 ×` content).
Guaranteed relative overshoot `(0.5 − 0.1)/1.1 = 4/11 ≈ 0.364`; observed
overshoot `(150 − 110)/110 = 4/11`.  The bound is therefore *tight* on this
instance, and is proved in general by `adapter_valley`.
