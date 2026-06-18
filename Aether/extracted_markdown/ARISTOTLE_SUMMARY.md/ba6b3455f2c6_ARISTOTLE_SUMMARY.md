# Summary of changes for run 5ce792ec-db32-4c6a-b3ee-781b60601469
Completed the research mission **EML Single-Operator Church–Turing Thesis** with fully verified Lean 4 (0 sorries; only `propext`/`Classical.choice`/`Quot.sound`).

## Diagnosis
The catalog's `Catalog/EML/SingleOperatorCompilation.lean` did not build: it imported a nonexistent module (`EML.SingleOperatorRepresentability`) and referenced undefined types/predicates (`EMLExpr`, `EMLOnlyExpr`, `EMLRepresentable`, `EMLOnlyRepresentable`). This was the central broken artifact of the mission.

## Deliverable 1 — Lean 4 proofs (4 files under `Catalog/EML/`)
- **`SingleOperatorRepresentability.lean` (new foundation)** — grammars and total denotational semantics for the *two-operator* language `EMLExpr` (`exp`, `log`) and the *single-operator* language `EMLOnlyExpr` whose sole transcendental primitive is `eml(x,y) = exp(x) − log(y)`; size functions; representability predicates over `(Fin n → ℝ) → ℝ`; and the recovery identities `exp(x)=eml(x,1)`, `log(y)=1−eml(0,y)`. This file supplies exactly the symbols the compilation file needs.
- **`SingleOperatorCompilation.lean`** — now builds. Its central results are now genuinely proved: `compile_correct`, `compile_size_bound (≤ 5·size)`, and the universality equivalence `EMLOnlyRepresentable f ↔ EMLRepresentable f`. I also removed its leftover unused-`simp`-argument linter warnings.
- **`SingleOperatorChurchTuring.lean` (new)** — the function-algebra structure: closure of the representable class under `+, ×, neg, −, inv, exp, log` and under the `eml` primitive itself; the reverse size bound `compileFromEMLOnly_size_bound (≤ 4·size)`; concrete `sinh`, `cosh`, natural powers; and the omnibus synthesis `single_operator_church_turing`.
- **`SingleOperatorActivations.lean` (new)** — finite sum/product closure; **polynomial completeness** (`EMLOnlyRepresentable_mvPolynomial`: every multivariate real polynomial function is single-operator representable); and the standard neural activations sigmoid, softplus, tanh, SiLU as single-operator representable (the concrete "Applications"-domain payoff).

## Deliverable 2 — Lab notes
Inline `-- !-- Lab Notes -- !--` blocks in `SingleOperatorChurchTuring.lean` and `SingleOperatorActivations.lean` record the hypotheses (closure as a true algebra; polynomial + activation completeness), the transport-across-equivalence experimental strategy, outcomes, insights (every activation secretly exercises the single primitive since `exp` is only available through `eml`), and failure analysis (the `emlEnv` literal-index reconciliation; `Finset.induction` membership bookkeeping).

## Deliverable 3 — `Catalog/EML/FUTURE_DIRECTIONS.md`
Five bold, testable conjectures: (C1) necessity/minimality — the field-only fragment is exactly the rational functions and `exp` is not among them; (C2) tightness of the 5/4 size constants; (C3) a domain-faithful partial-semantics thesis; (C4) Stone–Weierstrass approximation-universality of the single-operator class; (C5) differential-field closure of the single-operator class.

## Constraints honored
All output is standard Lean 4 plus the required `FUTURE_DIRECTIONS.md`; no prose articles, code, widgets, or package files; no added axioms or `@[implemented_by]`.

## Note
The repository-wide `EML` library target still fails to build, but only because of two pre-existing dangling references unrelated to this mission (`EML/Dvir.lean` imports a missing `EML.PolynomialMethod.UnivariateVanishing`, and an `Algebra/SpectralNovelty/CutMetric.lean` is missing). All four single-operator modules build cleanly on their own and together.