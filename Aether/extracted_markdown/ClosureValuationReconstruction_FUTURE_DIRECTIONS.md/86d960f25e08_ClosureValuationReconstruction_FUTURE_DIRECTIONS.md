# Future Directions: Closure-stable probe reconstruction from valuation-depth profiles

The file `Bridges/ClosureValuationReconstruction.lean` establishes a bridge between
abstract finite closure systems (`ClosureSemimoduleSystem`, `ProbeFamily`,
`ClosureStableProbe`) and computable valuation-style invariants
(`ValuationDepthMeasure`, `vdepth_add`). The core results are:

- `profile_eq_of_closure_eq` / `closure_eq_of_profile_eq` — the two-directional
  reconstruction equivalence between closure equivalence and response-profile
  equivalence, packaged in `closure_eq_iff_profile_eq` and certified set-wise by
  `profileClass_eq_closureClass`;
- `decidableClosureEq` — decidability of closure equivalence by finite profile
  comparison;
- `vdepth_listSum_le` — a valuation-depth pruning bound on aggregated observables;
- `separation_necessary` — a finite counterexample showing the separation axiom is
  indispensable for the converse.

The following conjectures extend this frontier. Each is intended to be testable and
falsifiable, with a concrete Lean target.

## 1. Minimal separating probe bases and a profile-rank invariant

**Conjecture.** For a finite `ClosureSemimoduleSystem` over a field `K`, among all
separating closure-stable probe families there is one of minimum cardinality, and
this minimum equals the number of distinct closure classes minus one (an analogue of
a spanning/dimension count), with the response-profile map factoring through a
free `K`-module of exactly that rank.

The key insight is that the response-profile map `respProfile` is `K`-affine in the
probes, so the smallest separating family is governed by the rank of the matrix of
probe responses over the finite set of closure classes — a linear-algebra invariant
sitting on top of the purely order-theoretic closure lattice. Why now: the present
file already proves that profile equality *equals* closure equality under separation
(`closure_eq_iff_profile_eq`); turning "some separating family exists" into "a
minimum one exists with a computable size" is the natural quantitative refinement,
and Mathlib's finite-dimensional rank API makes the bound formalizable directly.

## 2. Logarithmic-depth aggregation via balanced probe trees

**Conjecture.** The linear pruning bound `vdepth_listSum_le` (depth ≤ max + length)
is loose: aggregating `n` observables by a balanced binary combination tree achieves
valuation depth ≤ `max + ⌈log₂ n⌉`, and this logarithmic bound is tight for a
generic separating family.

The key insight is that `vdepth_add` charges exactly one depth unit per binary
combination regardless of operand depth, so a balanced fold over `n` observables
incurs only the tree height `⌈log₂ n⌉` rather than the chain length `n`. Why now:
`vdepth_listSum_le` already isolates the inductive cost of the left-leaning fold;
replacing `List.foldr` by a balanced `mergeSort`-style combinator and re-running the
same `vdepth_add` induction is a self-contained next step that turns an `O(n)`
pruning lemma into the asymptotically optimal `O(log n)` one used by real
reconstruction pipelines.

## 3. Lifting reconstruction from singletons to finitely generated closed sets

**Conjecture.** The singleton reconstruction `closure {x} = closure {y} ↔ profile x
= profile y` lifts to finite generating sets: for finitely generated `S, T`,
`closure S = closure T` iff their *set profiles* `fun p => p '' S` (as multisets of
responses) coincide, under a strengthened set-separation axiom.

The key insight is that a closure-stable probe is constant along closure expansion,
so the profile of a finite set is a closure invariant; separation upgraded to finite
sets makes the multiset of responses a complete invariant, exactly mirroring the
singleton proof in `stable_probe_eq_of_closure_eq`. Why now: the catalog's
`SetClosureOperator` (`Bridges/AlgebraEMLReconstruction.lean`) supplies the
finitary-closure machinery, and our singleton argument is already phrased through
`M.closure {x}`, so generalizing `{x}` to a `Finset` is a direct structural
extension rather than a new theory.

## 4. Robustness of profiles under bounded probe perturbation

**Conjecture.** Over a metric semiring (e.g. `ℝ`), if every probe is `L`-Lipschitz
on states and two states have profiles within `ε`, then their closures are equal
whenever `ε` is below the separation margin `δ` of the family; i.e. reconstruction
is robust to additive noise up to a quantifiable threshold.

The key insight is that the separation axiom can be made quantitative — a *margin*
`δ = min over distinct closure classes of the response gap` — and any perturbation
strictly smaller than `δ` cannot flip a profile inequality into equality. Why now:
the catalog already studies `lipschitz_certified_robustness_identity` in
`Bridges/AlgebraEMLReconstruction.lean`; combining that certified-robustness style
with our exact `closure_eq_of_profile_eq` gives a noisy reconstruction theorem,
which is the form actually needed for floating-point or measured observables.

## 5. Functoriality: closure morphisms induce profile morphisms

**Conjecture.** A morphism of closure semimodule systems (a state map commuting with
`step`, `closure`, and pulling back probes) induces a natural transformation of
response profiles, so that profile equivalence is preserved and reflected; the
reconstruction certificate `profileClass_eq_closureClass` is then natural in the
system.

The key insight is that `respProfile` is contravariant in probes and covariant in
states, exactly the shape of a (co)presheaf, so a structure-preserving system map
yields a commuting square of profiles — making reconstruction a functorial, not
merely pointwise, phenomenon. Why now: with the pointwise equivalence now proven,
the only missing ingredient is the morphism category of `ClosureSemimoduleSystem`,
which the catalog's reconstruction files (`AlgebraEMLReconstruction`,
`AlgebraEMLClosureComputation`) already gesture at via endomorphism-monoid
reconstruction; formalizing the morphism structure turns isolated theorems into a
reusable categorical bridge.
