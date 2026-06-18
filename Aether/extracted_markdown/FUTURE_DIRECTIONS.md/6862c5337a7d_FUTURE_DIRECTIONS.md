# Future Directions — HoTT Foundations Cycle

Artifacts produced this cycle:
- `Catalog/Logic/HoTT/IdentityCharacterization.lean`
- `Catalog/Logic/HoTT/PropUnivalence.lean`

## Synthesis

This cycle pushed two catalog HoTT threads — the *Fundamental Theorem of
Identity Types* (`Logic.FundamentalTheorem`) and *univalence* (so far only the
finite/tropical shadow in `Logic.TropicalHoTT`) — past the one-directional
results that were already on file. The structural insight that unifies both
new files is that **contractibility is the universal organizing principle**:
identity types are exactly the fibers of a contractible total space, and
equivalences of propositions are unique precisely because the relevant total
spaces are subsingletons.

Concretely, `IdentityCharacterization.lean` upgrades the catalog's
`fundamental_theorem_id'` (which only gave `Σ C contractible → fiberwise
equivalence`) into a genuine biconditional `fundamental_characterization`:
`isContr (Σ x, C x) ↔ ∀ x, Nonempty ((a = x) ≃q C x)`. The new converse is
powered by `sigmaCongrFiber`, the principle that `Σ` respects fiberwise
equivalence, transported onto the singleton contraction
`HoTT.singletonContraction`. The one genuinely instructive failure was a
universe mismatch: the based-path family `a = x` lives in `Sort 0` while a
general fiber `C x` lives in `Sort v`, so a single-universe `sigmaCongrFiber`
could not be instantiated. Splitting it across two universes (`v` and `w`) is
what made the converse go through — a reminder that HoTT's "everything is a
type" slogan still has to respect Lean's predicative universe discipline.

`PropUnivalence.lean` isolates a fragment where univalence is not an axiom but
a *theorem*: on the universe of propositions, `(P = Q) ≃q (P ≃q Q)`. The
engine is `qequiv_prop_unique` (equivalences between propositions are unique),
which collapses all the coherence bookkeeping that makes full univalence hard.
This is the cleanest possible evidence for the project thesis ("HoTT is a
constructive foundation"): on `Prop`, the central axiom is realized using only
`propext` plus definitional proof irrelevance, with `qequiv_prop_unique`
needing no axioms at all.

## Results Summary

- `HoTT.sigmaCongrFiber`: proved — a fiberwise quasi-equivalence (across two
  universes) lifts to an equivalence of total `Σ`-spaces; the reusable engine
  behind the converse fundamental theorem.
- `HoTT.contr_total_of_fiberwise`: proved — if every fiber `C x` is equivalent
  to `a = x`, the total space `Σ x, C x` is contractible (converse of the
  catalog fundamental theorem).
- `HoTT.fundamental_characterization`: proved — full biconditional
  characterizing contractible total spaces as identity-type families.
- `HoTT.PropUniv.qequiv_prop_unique`: proved (axiom-free) — quasi-equivalences
  between two propositions are unique.
- `HoTT.PropUniv.propUnivalence`: proved — univalence holds on the universe of
  propositions: `(P = Q) ≃q (P ≃q Q)`.
- `HoTT.PropUniv.prop_eq_iff_equiv`: proved — propositional form of the above.

## Research Directions

### Direction 1: Equivalence induction (the "J rule" for QEquiv)
**Hypothesis**: For a fixed `A`, the family `fun B => A ≃q B` is an identity
system based at `A`; equivalently, `Σ B, (A ≃q B)` is contractible, so any
motive `D : ∀ B, (A ≃q B) → Sort*` is determined by its value on
`D A (QEquiv.refl A)`.
**Test**: State `equivInduction : (∀ B (e : A ≃q B), D B e)` from
`D A (QEquiv.refl A)`, and try to derive it from `fundamental_characterization`
applied to the family `fun B => A ≃q B`. The crux is showing
`Σ B, (A ≃q B)` contractible, which in turn needs univalence for general types
(not just `Prop`) — so the experiment doubles as a probe of how far the
`Prop`-univalence of this cycle can be stretched.
**Why now**: `fundamental_characterization` reduces "is an identity system" to
"total space contractible", turning equivalence induction into a single
contractibility goal instead of a transport-coherence slog.
**If true**: Gives a clean, reusable `J`-style recursor for the catalog's
`QEquiv`, the workhorse of every encode–decode argument.
**If false / blocked**: Pinpoints exactly which contractibility fails without
full univalence, sharpening what an axiom would have to provide.

### Direction 2: Univalence for h-sets with decidable equality
**Hypothesis**: For types `A B` with `DecidableEq` and at most countably many
elements (e.g. `Fintype`), `(A = B) ≃q (A ≃q B)` is provable in Lean without
any new axiom, by reducing equivalences to explicit bijections.
**Test**: Build `idtoeqv`/`ua` for `Fintype` types using `Fintype.card` and
`Equiv` from Mathlib, and prove the round-trips via decidable case analysis.
Compare the proof obligations to `qequiv_prop_unique`.
**Why now**: This cycle showed univalence is a theorem on `Prop` via a
uniqueness lemma; the analogous uniqueness ("a bijection of finite sets is
determined by its graph") is decidable, so the same template should transfer.
**If true**: A second axiom-free univalence island, bridging to the catalog's
`Logic.TropicalHoTT` finite classification (`tropUnivalence_finite`).
**If false**: Reveals an obstruction (likely choice-of-bijection) that
clarifies the boundary between decidable and general univalence.

### Direction 3: Identity systems characterize encode–decode completeness
**Hypothesis**: A family `C` with `c : C a` admits a *complete* encode–decode
characterization of `a = x` **iff** `fundamental_characterization` holds for it;
i.e. the existence of any fiberwise section `(a = x) → C x → (a = x)` that is a
retraction already forces contractibility of `Σ C`.
**Test**: Weaken the hypothesis of `contr_total_of_fiberwise` from a full
`QEquiv` to a mere fiberwise retraction (a section of `encode`) and attempt the
same `singletonContraction` transport; locate the minimal data that still
yields contractibility.
**Why now**: The proof of `contr_total_of_fiberwise` only ever uses the
`rightInv` half of the equivalence through `qequiv_preserves_isContr`, hinting
that less than a full equivalence suffices.
**If true**: Substantially lowers the bar for invoking the fundamental theorem
in practice (retractions are far easier to build than equivalences).
**If false**: Produces an explicit family with a retraction but non-contractible
total space — a sharp counterexample delimiting the theorem.

### Direction 4: Propositional univalence ⇒ propositional function extensionality
**Hypothesis**: From `propUnivalence` one can derive function extensionality for
`Prop`-valued families internally, i.e. `(∀ x, P x = Q x) → ((∀ x, P x) = (∀ x, Q x))`
as a `QEquiv`, with no appeal to Lean's primitive `funext` beyond what `propext`
already entails.
**Test**: Construct the map and its inverse using `idtoeqv`/`ua` pointwise plus
`sigmaCongrFiber`-style gluing on `Π`-types, then check `#print axioms` shows
only `propext`.
**Why now**: `prop_eq_iff_equiv` already converts pointwise equalities into
pointwise equivalences; the missing step is assembling them, exactly the dual of
`sigmaCongrFiber` for `Π` instead of `Σ`.
**If true**: Demonstrates a self-contained extensionality principle, reinforcing
the "constructive foundation" thesis with minimal axiom footprint.
**If false**: Shows where `Π`-gluing genuinely needs `funext`, separating the
`propext` and `funext` axioms in this fragment.

### Direction 5: Boundary case — does the characterization survive without a basepoint?
**Hypothesis**: Dropping the basepoint witness `c : C a` from
`fundamental_characterization` breaks the forward direction: there is a family
`C` with `Σ C` contractible whose contraction center is **not** over `a`, so no
fiberwise equivalence `(a = x) ≃q C x` can exist (in particular `C a` is empty).
**Test**: Take `A := Bool`, `a := true`, `C := fun b => (b = false)`. Then
`Σ b, C b` is the singleton `{(false, rfl)}` (contractible), but `C true` is
empty while `true = true` is inhabited, so no equivalence exists — a concrete
disproof of the basepoint-free statement.
**Why now**: This cycle kept `c : C a` as a hypothesis precisely on suspicion it
was load-bearing; the converse `contr_total_of_fiberwise` does *not* need it,
making the asymmetry worth pinning down with an explicit counterexample.
**If true (counterexample verifies)**: Confirms `c : C a` is essential and the
biconditional is tight; a clean `disproved` companion to the main theorem.
**If false**: Would mean a hidden way to recover the basepoint, surprising and
worth a dedicated lemma.
