# Computational Evidence — Approximate Ramsey degrees (finite skeleton)

This stage verified the combinatorial landscape *before* committing to formal
proofs.  Every number reported here is now backed by a sorry-free Lean theorem in
`Core.lean` / `System.lean`; the evidence stage only fixed the conjectured values.

## 1. Small-case calculations (degree of one comparison step)

A step is `M = Hom(B,A)`, `N = Hom(C,A)`, `morph = Hom(C,B)`, with
`pull : morph → (M → N)`.  The degree is the least `d` such that every colouring
of `N` has a morphism whose pullback to `M` uses `≤ d` colours.

| step                                   | `|M|` | morphisms / pullbacks        | degree | meaning                         |
|----------------------------------------|-------|------------------------------|--------|---------------------------------|
| `step1` (constant pullbacks, `M=Bool`) | 2     | both constant maps `M→N`     | **1**  | extremely amenable / APR        |
| `step2` (identity pullback, `M=Bool`)  | 2     | only `id : M→N`              | **2**  | metrizable, *not* APR           |
| `idStep (Fin 1)`                       | 1     | only `id`                    | 1      | trivial object                  |
| `idStep (Fin 2)`                       | 2     | only `id`                    | 2      |                                 |
| `idStep (Fin 3)`                       | 3     | only `id`                    | 3      |                                 |
| `idStep (Fin (n+1))`                   | n+1   | only `id`                    | **n+1**| unbounded ⇒ non-metrizable      |

Key small-case observations that survived into the proofs:

* **No collapse without a collapsing morphism.**  For `idStep (Fin k)` the only
  morphism is the identity, and an *injective* colouring `Fin k ↪ ℕ` pulls back
  to itself, using all `k` colours.  Hence degree `= k` exactly
  (`idStep_degree`).  This is the crucial non-`decide` computation: it uses
  `Finset.card_image_of_injective`.
* **One collapsing morphism suffices for degree 1.**  In `step1` both morphisms
  are *constant* maps `M → N`, so every colouring `c` becomes constant after
  pullback; degree `= 1` (`step1_degree`).
* **Degree is always in `[1, |M|]`** (`one_le_degree`, `degree_le_card`): a
  nonempty domain forces `≥ 1`, and a colouring of an `n`-set uses `≤ n` colours.

## 2. Sequence check

The per-step degrees of `nonMetrizable` are `1, 2, 3, 4, …` (the identity
sequence A000027), confirmed by `nonMetrizable_step_degree n : degree = n + 1`.
Because this sequence is unbounded, the family has **no** finite uniform degree
(`nonMetrizable_not_finiteDegree`) — the non-metrizable regime is reachable, not
vacuous.  No OEIS surprise here; the point is precisely that the degree sequence
diverges.

## 3. Counterexample hunt (against the conjecture's separation)

We tried to break the predicted *strict* separation
`extremely amenable ⊊ metrizable ⊊ all` :

* Can a step with `|M| = 2` always be collapsed to 1 colour? **No** — `step2`
  with the single identity morphism cannot (`step2_not_reduces_one`).  So
  metrizable does *not* imply extremely amenable: `metrizableNotAmenable` has
  finite degree `2` but is not extremely amenable.
* Does finite per-step degree (each `≤ |M|`) force a finite *uniform* degree?
  **No** — `nonMetrizable` has every step finite yet no common bound.  So
  metrizability is a real restriction, not automatic.

Both attempted counterexamples instead became the two *strictness* theorems
`finiteDegree_strictly_weaker_than_extremelyAmenable` and
`not_finiteDegree_realizable`.

## Conclusion

The finite combinatorial landscape matches the conjecture's trichotomy exactly:
degree-1 (extreme amenability), finite-degree-but->1 (metrizable, not extremely
amenable), and unbounded (non-metrizable).  Proceeding to formalization was
justified, and all conjectured values are now theorems.
