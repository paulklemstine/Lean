# Future Directions — Sheaf-Theoretic Data Integration

## Synthesis

`MachineLearning/SheafDataIntegration.lean` makes precise the claim *"a database
with missing entries is a partial section of a sheaf"*. Modelling a row/feature
observation as a total map `ι → Option V` (`PartialSection`) turns restriction,
compatibility and gluing into computable operations and yields two clean,
machine-checked pillars:

1. **The sheaf/equalizer condition** (`exists_global_section_iff_compatible`,
   `sheaf_gluing`): a *consistent global imputation exists and is unique* exactly
   when the local observations agree on their overlaps. Consistent imputation is
   therefore not an optimization heuristic but the canonical global section of a
   sheaf — the `H⁰` (sections) counterpart of the `H¹` gluing-ambiguity story in
   `MachineLearning/CechComplex.lean` (`cocycle_eq_coboundary_on_total`,
   `CausalPresheafData.always_sheaf`).
2. **The probability law** `P(sheaf) = (1 - r)^{C(n,2)}`
   (`consistencyProb_eq_prod`, `consistencyProb_recurrence`,
   `consistencyProb_antitone/le_one/pos`, `numConstraints_succ`): consistency
   feasibility factors over independent cells, so it decays *exponentially* in
   the number of overlapping constraints `C(n,2)`, with the exact recurrence
   `P(C(n+1,2)) = P(C(n,2))·(1-r)^n`.

## Results summary

| Theorem | Statement |
|---|---|
| `exists_global_section_iff_compatible` | global section exists ⟺ local compatibility |
| `sheaf_gluing` | unique global section glued from compatible locals (∃!) |
| `glue_agrees_left/right`, `glue_dom` | restriction maps + domain = union |
| `consistencyProb_eq_prod` | `(1-r)^N` = product of per-cell keep-probabilities |
| `consistencyProb_recurrence` | `P(C(n+1,2)) = P(C(n,2))·(1-r)^n` |
| `consistencyProb_antitone/le_one/pos` | monotone, valid probability, positive for `r<1` |

All proofs are `sorry`-free and use only `propext`, `Classical.choice`,
`Quot.sound`. The gluing construction `glue` is computable (`#eval`-tested).

## Direction 1 — Finite-family (Čech) gluing, not just pairwise

Generalize `sheaf_gluing` from two sources to an arbitrary finite indexed family
`s : Fin k → PartialSection ι V` with *pairwise* compatibility, proving that a
unique global section glues from the whole cover. **The key insight is** that the
binary `glue` is associative and commutative on compatible sources, so the
`Finset.fold` of `glue` over a pairwise-compatible family is well defined and
independent of order — the sheaf condition for general covers reduces to the
`Compatible.symm` coherence already proved. **Why now?** The pairwise primitives
(`glue_agrees_left/right`, `glue_dom`, `Compatible.symm`) are in place, so the
inductive step `glue (fold …) sₖ` is the only new lemma needed; this is the exact
hypothesis a synthetic-data imputation experiment would stress.

## Direction 2 — The gluing obstruction is a Čech 1-cocycle class

Bridge `SheafDataIntegration` to `CechComplex` explicitly: assign to a cover of
incompatible local sections a `CechCausalComplex.CechOneCochain` whose value on a
pair `(i,j)` records their disagreement, and prove this cochain is a 1-cocycle
whose vanishing class in `H¹` equals `Compatible`. **The key insight is** that
"two sections disagree on an overlap" is precisely a nonzero coboundary defect,
so the imputation obstruction *is* the Čech cohomology class — making
`cocycle_eq_coboundary_on_total` the statement that the obstruction vanishes on
the full feature set. **Why now?** Both files already exist in the catalog with
matching posets-of-subsets framing; connecting them turns two separate results
into one cohomological theorem and is the project's strongest cross-domain bridge.

## Direction 3 — Quantitative imputation gain over mean/KNN

Formalize a measurable advantage of sheaf imputation: define a "consistency
error" functional and prove that the sheaf-glued section is the unique zero-error
completion while mean-imputation incurs error bounded below by the overlap
disagreement. **The key insight is** that `glue` exactly preserves every observed
cell (`glue_agrees_left/right`), so its consistency error is identically zero,
whereas any constant-fill strategy must violate at least one overlap constraint
whenever columns are correlated. **Why now?** With `glue` proven to restrict
correctly, the comparison reduces to a finite inequality over observed cells —
provable today and directly testable against the conjecture that sheaf imputation
wins for `r < 0.5`, `n > 10`.

## Direction 4 — Independence-to-exponential law made probabilistic

Lift `consistencyProb_eq_prod` from a deterministic product identity to a genuine
`MeasureTheory`/`PMF` statement: with each cell independently present with
probability `1-r`, the probability that the missingness pattern admits a global
section equals `(1-r)^{C(n,2)}`. **The key insight is** that compatibility of a
random database is an *intersection of independent per-constraint events*, so
`Finset.prod` of marginal probabilities is literally the joint probability via
independence — the product identity already proved is the combinatorial skeleton.
**Why now?** Mathlib's `PMF`/`Measure` product API is mature; the only missing
piece is the event-factorization lemma, and the exponent `C(n,2)` is already
isolated as `numConstraints`.

## Direction 5 — Decidable global-consistency checker with complexity bound

Make consistency *algorithmic*: define a `Decidable` instance for `Compatible`
over finite `ι` and prove the checker runs in `O(C(n,2))` overlap comparisons,
returning the glued section as a constructive witness. **The key insight is** that
`Compatible` is a bounded `∀` over `Fin n × Fin n`, hence decidable, and the
witness on acceptance is exactly `glue`, so the decision procedure and the
imputation algorithm are the same object. **Why now?** The constructive `glue`
and the `#eval`-verified examples show the computation already runs; wrapping it
as a certified `Decidable`/complexity result connects the sheaf theory to an
effective imputation algorithm, the engine's algorithmic-generation mandate.
