# Computational Evidence (Cycle 1, thread `th_e10b0054`)

All numbers below were produced by direct evaluation in Lean (`#eval` on `Float`
arithmetic) before the corresponding Lean theorems were stated.  Each numeric claim is
matched by a formally proved statement; the file records which.

## 1. The fiber-entropy gap `E[log₂ |fiber|] − H(x ∣ f x)`

System: the collapsing normalization map `f = ![0,0,1] : Fin 3 → Fin 2`
(`FiberEntropy.collapse32` in the catalog).  Its fibers are `{0,1}` and `{2}`, so the
fiber-counting estimate charges `1` bit to terms `0, 1` and `0` bits to term `2`.

| law `p = (p₀, p₁, p₂)`   | `E[log₂ |fiber|]` | `H(x ∣ f x)` | gap      | fiberwise uniform? |
|--------------------------|-------------------|--------------|----------|--------------------|
| `(1/2, 1/4, 1/4)`        | `0.750000`        | `0.688722`   | `0.061278` | no  (`p₀ ≠ p₁`)   |
| `(1/3, 1/3, 1/3)`        | `0.666667`        | `0.666667`   | `0.000000` | yes               |
| `(0.6, 0.2, 0.2)`        | `0.800000`        | `0.649022`   | `0.150978` | no                |
| `(0.7, 0.1, 0.2)`        | `0.800000`        | `0.434852`   | `0.365148` | no                |
| `(0.4, 0.4, 0.2)`        | `0.800000`        | `0.800000`   | `0.000000` | yes (`p₀ = p₁`)   |

**Counterexample hunt.** The universal claim tested was "the gap vanishes *iff* `p₀ = p₁`",
i.e. iff the law is constant on the non-trivial fiber `{0,1}`.  No counterexample was found
in the sample; note in particular that uniformity of `p` on the *whole* space is *not*
needed — `(0.4, 0.4, 0.2)` is not uniform yet attains equality, while normalisation of `p`
plays no role at all.  This is what led to stating the law with the hypothesis
`∀ x y, f x = f y → p x = p y` rather than `p = unif`, and with no normalisation hypothesis.

**Formalised as.** `FiberUniformity.fiber_entropy_law` (the `iff`),
`FiberUniformity.fiber_entropy_strict` (strictness), and the exact values
`FiberUniformity.expectedLogFiber_biased32 = 3/4`,
`FiberUniformity.condEntropyW_biased32 = (3/4)·log₂ 3 − 1/2` (`≈ 0.688722`),
with `FiberUniformity.biased32_gap_pos` proving `5/4 − (3/4)·log₂ 3 > 0`.

## 2. The compositional saving `separate − joint`

System: two proof obligations over `Fin 2`, each verified by the total collapse
`Fin 2 → Fin 1` (so the outputs carry no information and `I(outputs) = 0`).
The predicted saving is `I(inputs) − I(outputs) = I(inputs)`.

| joint law `(p₀₀, p₀₁, p₁₀, p₁₁)` | separate cost | joint cost | saving     | `I(inputs)` |
|----------------------------------|---------------|------------|------------|-------------|
| `(1/2, 0, 0, 1/2)`  (same lemma) | `2.000000`    | `1.000000` | `1.000000` | `1.000000`  |
| `(1/4, 1/4, 1/4, 1/4)` (indep.)  | `2.000000`    | `2.000000` | `0.000000` | `0.000000`  |
| `(0.4, 0.1, 0.1, 0.4)`           | `2.000000`    | `1.721928` | `0.278072` | `0.278072`  |
| `(0.3, 0.2, 0.2, 0.3)`           | `2.000000`    | `1.970951` | `0.029049` | `0.029049`  |

The saving matched `I(inputs)` to machine precision in every sample, and was never negative —
the two observations that became `compositional_landauer_identity` (the exact identity, with
the extra `− I(outputs)` term needed once the verifiers are *not* total collapses) and
`dpi_mutualInfo` / `joint_verification_saving_nonneg`.

**Counterexample hunt.** The *naive* form of the conjecture, "saving `=` mutual information
of the inputs", was tested against verifiers that are not total collapses (e.g. the identity
on both coordinates), where the saving is `0` while `I(inputs) = 1`.  The naive form is
therefore **false**, and the corrected invariant is the *drop* `I(inputs) − I(outputs)`.
This is recorded in the Lab Notes of `Catalog/Computation/CompositionalLandauer.lean`.

**Formalised as.** `CompositionalLandauer.compositional_landauer_identity`,
`CompositionalLandauer.independent_landauer_additive`,
`CompositionalLandauer.sharedLemma_separate` (`= 2`),
`CompositionalLandauer.sharedLemma_joint` (`= 1`),
`CompositionalLandauer.sharedLemma_saving_eq_one` (`= 1`).

## 3. The bureaucratic calculus

For the calculus `Bureaucracy.Deriv n` (`n` independent commuting blocks, `n`-bit
conclusions):

| `n` | derivations `4ⁿ` | conclusions `2ⁿ` | normal derivations `2ⁿ` | fiber size `2ⁿ` | max reduction length | bits erased |
|-----|------------------|------------------|--------------------------|-----------------|----------------------|-------------|
| `1` | `4`              | `2`              | `2`                      | `2`             | `1`                  | `1`         |
| `2` | `16`             | `4`              | `4`                      | `4`             | `2`                  | `2`         |
| `3` | `64`             | `8`              | `8`                      | `8`             | `3`                  | `3`         |

`Fintype.card (Bureaucracy.Deriv 3) = 64` was checked by `decide`.

**Formalised as.** `Bureaucracy.card_fiber_normalForm` (`= 2 ^ n` for every `n`),
`Bureaucracy.reachIn_normalForm` (`≤ n` steps), `Bureaucracy.erasedBits_normalForm` (`= n`),
`Bureaucracy.condEntropyW_normalForm` (`= n`), `Bureaucracy.strongly_normalizing`.

## 4. Pipelines: entropy additive, fiber counting not

System: `f = ![0,1,1] : Fin 3 → Fin 2` (fiber sizes `1` and `2`), `g : Fin 2 → Fin 1` the
total collapse, so the composite has a single fiber of size `3`.

| law `p`                | `E[log₂|fiber_f|]` | `E[log₂|fiber_g|]` (pushed) | sum   | `E[log₂|fiber_{g∘f}|]` | subadditive? |
|------------------------|--------------------|------------------------------|-------|-------------------------|--------------|
| uniform `(1/3,1/3,1/3)`| `0.666667`         | `1.000000`                   | `1.666667` | `1.584963`         | yes          |
| `(4/5, 1/10, 1/10)`    | `0.200000`         | `1.000000`                   | `1.200000` | `1.584963`         | **no**       |
| `(1, 0, 0)`            | `0.000000`         | `1.000000`                   | `1.000000` | `1.584963`         | **no**       |

The failure is driven by weight concentrating on a *small* `f`-fiber sitting next to a large
one; the uniform law makes the two effects cancel.  The conditional entropy, by contrast, was
additive in every sample.

**Formalised as.** `NormalizationPipeline.condEntropyW_comp` (exact additivity, any
non-negative law), `NormalizationPipeline.expectedLogFiber_comp_le_unif` (subadditivity under
the uniform law), `NormalizationPipeline.expectedLogFiber_comp_eq_unif_iff` (equality iff all
`f`-fibers over a common `g`-fiber have equal size), and
`NormalizationPipeline.expectedLogFiber_not_subadditive` (`6/5 < log₂ 3`, using the fully
supported law `(4/5, 1/10, 1/10)`).

## 5. OEIS

The integer sequences that appear (`2ⁿ` = A000079, `4ⁿ` = A000302) are the elementary
powers of two and four; no new sequence arose, so no OEIS lookup was informative.
