# Skip Evidence Justification — Σ-ramified Iwasawa torsionness

The main result is a *universally quantified structural theorem*:

> Every `Λ = R[[T]]`-module that is finitely generated over the base ring `R`
> (with `R` an integral domain, e.g. `R = ℤ_p`) is `Λ`-torsion.

There is no numeric sequence, no finite search space, and no universal numerical
claim to sample: the statement quantifies over all modules in a typeclass-defined
class, so a counterexample hunt is not meaningful — disproof would require a
*module*, not a number.

Instead of tabular/numeric evidence, the file provides the analogues appropriate to
an algebraic existence/structure result:

* **Concrete witness (non-vacuousness):** `trivialModule_isTorsion` exhibits an
  explicit instance — the base ring `R` with `T` acting through the augmentation
  `T ↦ 0` — satisfying all hypotheses, so the theorem is not vacuous.
* **Sharpness witness:** `iwasawaAlg_self_not_isTorsion` shows the boundary of the
  hypothesis — `Λ` over itself is `Λ`-finite but *not* `Λ`-torsion — confirming that
  finiteness must be measured over the base `ℤ_p`, not over `Λ`.
* **Invariant check:** `charpoly_natDegree_eq_lambda` ties the degree of the
  characteristic generator to the `λ`-invariant `rank_{ℤ_p} M`.

These formal witnesses play the role of small-case verification and are themselves
machine-checked (0 sorries), which is strictly stronger than informal computation.
