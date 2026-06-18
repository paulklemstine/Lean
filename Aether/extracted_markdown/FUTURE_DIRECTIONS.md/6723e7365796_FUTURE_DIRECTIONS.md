# Future Directions: Proof-Theoretic Ordinal Analysis III

This cycle's Lean artifact is
`Catalog/Pythagorean/ProofTheoreticOrdinalsWQO.lean`, which builds directly on the
catalog module `Catalog/Pythagorean/ProofTheoreticOrdinalsLattice.lean`
(the `OrdinalTheory` structure, `pto`, `ofOrdinal`, `join`/`meet`, `le_total_theory`,
and the `depthDist` quasi-metric).

## Synthesis

The catalog had established two facts about the abstract model of theories by their
provably-well-ordered ordinals: that inclusion is *total* (`le_total_theory`) and that
the proof-theoretic ordinal `pto` is monotone but not injective. Both facts were proved
"by hand" and left unexplained. This cycle gives the single structural reason behind
them. The key discovery is a **complete classification**: a set of ordinals is the
`provablyWO` of some theory exactly when it is a bounded initial segment, and every such
segment is `Set.Iio α` for a *unique* ordinal `α` — the **characteristic ordinal**
`charOrd T`, defined as the least ordinal the theory does *not* prove well-ordered
(`provablyWO_eq_Iio`, `theory_eq_ofOrdinal`). The whole abstract framework is therefore
nothing more than the family of initial segments of `Ordinal`.

From the classification everything else falls out mechanically. The map `charOrd` is an
**order isomorphism** `OrdinalTheory ≃o Ordinal` (`theoryOrderIso`); the catalog's
totality is just the pullback of the linear order on ordinals, and well-foundedness of
the ordinals transports to **well-foundedness of theory strength**
(`theory_lt_wellFounded`). Combined with totality, this resolves the catalog's stated
"well-quasi-order" conjecture (Direction 4) in the strongest possible form: theories
form a *well-order*, so they have no infinite antichains
(`theory_antichain_subsingleton`) and every sequence contains an ascending pair
(`theory_isWQO`). The combinatorial WQO machinery (Kruskal-style) hoped for in the
catalog's Direction 4 turns out to be unnecessary — totality collapses WQO to
well-foundedness.

The cycle also clarifies *why* the catalog's `pto` was non-injective: `pto` is a
supremum and so collapses successor characteristic ordinals (`pto (ofOrdinal (α+1)) =
α`), whereas `charOrd` retains the gap. We prove `pto T ≤ charOrd T` always
(`pto_le_charOrd`) with strict inequality witnessed at `ofOrdinal 1`
(`pto_lt_charOrd_example`), so `charOrd`, not `pto`, is the canonical invariant. Nothing
in this cycle failed outright; the main correction to the prior mental model is that
`pto` should be demoted in favour of `charOrd` for all order-theoretic purposes (the two
agree exactly at limit characteristic ordinals).

## Results Summary

- `OrdinalTheory.ext_provablyWO`: proved — a theory is determined by its `provablyWO`
  set (proof-irrelevance extensionality), the technical engine for the classification.
- `OrdinalTheory.compl_nonempty`: proved — boundedness forces a least non-provable
  ordinal to exist.
- `OrdinalTheory.charOrd_not_mem`: proved — the characteristic ordinal is itself not
  provably well-ordered.
- `provablyWO_eq_Iio`: proved — every theory's provable set is exactly `Iio (charOrd T)`;
  the core classification lemma.
- `theory_eq_ofOrdinal`: proved — every `OrdinalTheory` equals `ofOrdinal (charOrd T)`,
  so the abstract framework is exactly the initial segments of `Ordinal`.
- `charOrd_ofOrdinal`: proved — `charOrd` inverts `ofOrdinal`.
- `charOrd_le_iff`: proved — `charOrd` reflects and preserves inclusion (order embedding).
- `theoryOrderIso`: proved — `charOrd` is an order isomorphism `OrdinalTheory ≃o Ordinal`,
  the cycle's central structural result.
- `theory_lt_wellFounded`: proved — strict theory inclusion is well-founded (Direction 4).
- `theory_antichain_subsingleton`: proved — inclusion is total, so antichains are trivial.
- `theory_isWQO`: proved — every sequence of theories has an ascending pair; theories form
  a well-quasi-order (indeed a well-order).
- `pto_le_charOrd`: proved — the catalog `pto` is bounded by the characteristic ordinal.
- `pto_lt_charOrd_example`: proved (constructive counterexample) — `pto` is strictly
  coarser than `charOrd`, witnessed by `ofOrdinal 1` (pto 0, charOrd 1).

## Research Directions

### Direction 1: Successor/limit dichotomy of the `pto`–`charOrd` defect
**Hypothesis**: For every theory `T`, `pto T = charOrd T` if and only if `charOrd T` is
zero or a limit ordinal, and `pto T + 1 = charOrd T` exactly when `charOrd T` is a
successor.
**Test**: Prove two lemmas — `pto_eq_charOrd_iff_not_succ` and
`charOrd_eq_pto_succ_of_isSuccPrelimit`-style — by casing `charOrd T` with
`Order.IsSuccLimit`/`Ordinal.isSuccLimit` and computing `sSup (Iio α)` in each case
(`csSup_Iio` of a limit is `α`; of a successor is the predecessor).
**Why now**: `pto_le_charOrd` and `pto_lt_charOrd_example` from this cycle already pin
the inequality and one strict instance; the only missing ingredient is the limit-case
supremum computation, which Mathlib supports via `Ordinal.isSuccLimit` API.
**If true**: It gives an exact formula recovering `pto` from `charOrd`, completing the
demotion of `pto` to a derived invariant and making the catalog's non-injectivity a
precise "successor-collapse" phenomenon.
**If false**: It would reveal a third regime of characteristic ordinals where the
supremum behaves unexpectedly — surprising, and worth isolating.

### Direction 2: Transporting the lattice and metric structure across `theoryOrderIso`
**Hypothesis**: Under `theoryOrderIso`, `join` corresponds to `max`, `meet` to `min`,
and the catalog `depthDist T₁ T₂` equals the symmetric ordinal difference
`(charOrd T₁ - charOrd T₂) + (charOrd T₂ - charOrd T₁)`; consequently `depthDist`
satisfies the triangle inequality on any triple whose characteristic ordinals are
linearly arranged through the middle point.
**Test**: Prove `charOrd_join = max`, `charOrd_meet = min`, and rederive the catalog's
`depthDist_chain_additive` purely from `theoryOrderIso` + ordinal arithmetic, then
characterize the failure set using `Ordinal.add` non-commutativity.
**Why now**: The iso `theoryOrderIso` reduces every lattice/metric statement about
theories to a statement about ordinals, where Mathlib's arithmetic API is rich; the
catalog already isolated the additivity and the `1 + ω = ω` obstruction.
**If true**: It unifies the catalog's lattice file and this file under one isomorphism,
and yields a clean "additive-principal" criterion for the triangle inequality.
**If false**: The discrepancy would mean `join`/`meet`/`depthDist` see structure beyond
the order — i.e. the model carries data the characteristic ordinal forgets.

### Direction 3: A genuine order type — `OrdinalTheory` as an honest `LinearOrder`
**Hypothesis**: The relations on `OrdinalTheory` extend to a `LinearOrder` (indeed a
`ConditionallyCompleteLinearOrder`) instance for which `theoryOrderIso` is an order
isomorphism of *ordered types*, and under which arbitrary suprema of theories
(`⨆ join`) correspond to suprema of their characteristic ordinals.
**Test**: Build the `LinearOrder OrdinalTheory` instance by pulling back along `charOrd`
(`LinearOrder.lift'` / `OrderIso`), then prove `charOrd (⨆ i, T i) = ⨆ i, charOrd (T i)`
for bounded families.
**Why now**: `theory_lt_wellFounded`, totality, and the bijection are all in hand this
cycle; assembling them into a bundled instance is the natural next packaging step and
makes the framework reusable by downstream files.
**If true**: Downstream catalog files could treat theories literally as ordinals,
enabling transport of any ordinal theorem (e.g. fixed-point/Veblen results) to theories.
**If false** (e.g. unbounded suprema escape the structure): it would sharpen exactly
which closure properties the "bounded" hypothesis is responsible for.

### Direction 4: Dropping boundedness — the one-point compactification of theories
**Hypothesis**: Removing `bddAbove` and allowing the improper theory
`provablyWO = univ`, the resulting type is order-isomorphic to `WithTop Ordinal` (the
ordinals with a top element), still totally ordered and still well-founded.
**Test**: Define `OrdinalTheory'` without `bddAbove`, prove every member is `Iio α` or
`univ`, and construct `OrdinalTheory' ≃o WithTop Ordinal`; check whether
`theory_lt_wellFounded` survives (it should, as `WithTop` preserves well-foundedness).
**Why now**: This cycle showed boundedness is exactly what makes `charOrd` total; the
classification proof localizes precisely where `bddAbove` is used
(`compl_nonempty`), so its removal is a controlled experiment.
**If true**: It identifies the "inconsistent theory" as a genuine top element and frames
the bounded model as its initial segment — a clean conceptual completion.
**If false**: The breakdown would expose a hidden role of boundedness beyond
non-emptiness of the complement, refining the classification.

### Direction 5: Concrete anchoring via `ONote` and fast-growing hierarchies
**Hypothesis**: The order isomorphism restricts to a computable sub-order-isomorphism
between theories with characteristic ordinal below `ε₀` and Mathlib's `ONote`
(notations below `ε₀`), under which `charOrd` is the `ONote.repr` of a notation and
"provable totality of `ONote.fastGrowing α`" matches `charOrd T ≥ α.repr`.
**Test**: Define `FinitelyDescribedTheory` carrying an `ONote`, prove
`charOrd (ofNotation o) = o.repr`, and connect to `ONote.fastGrowing` monotonicity.
**Why now**: With `theoryOrderIso` reducing abstract theories to ordinals, the only
remaining gap to concreteness is the ordinal-to-notation bridge, which `ONote.repr`
already provides computably in Mathlib.
**If true**: It is the first formal link between the abstract PTO model and an effective
notation system, opening the historically primary (growth-rate) route to PTOs.
**If false**: A mismatch between `charOrd` and `ONote.repr` would reveal that the
abstract supremum model and concrete notations diverge below `ε₀` — itself a notable
finding.
