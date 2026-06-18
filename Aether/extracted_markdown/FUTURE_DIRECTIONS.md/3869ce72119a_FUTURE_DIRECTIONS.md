# Future Directions — Dream Logic III: After the Structural Dichotomy

## Synthesis

This cycle built the **meta-theory of paraconsistent consequence** for Priest's Logic of
Paradox (`LP`) from a cold start, in two self-contained Lean files:

- `Catalog/Logic/DreamLogic/Paraconsistent.lean` — the object level. Truth values
  `ff < bb < tt` with the glut `bb` (a fixed point of negation, `neg bb = bb`), the
  designated set `{bb, tt}`, and the Kleene/Priest connectives `neg`, `conj = min`,
  `disj = max`. We prove the classic phenomena: no explosion (`explosion_fails`), gluts are
  satisfiable (`contradiction_satisfiable`), excluded middle and non-contradiction remain
  valid (`lem_valid`, `lnc_valid`), modus ponens fails (`mp_fails`), double negation holds
  (`double_negation`), and the minimal-glut relation `entailsMin` is non-monotone
  (`retraction_nonmonotone`).
- `Catalog/Logic/DreamLogic/NonMonotone.lean` — the meta level. The central finding is a
  sharp dichotomy: **structural rules survive paraconsistency, connective elimination rules
  die.** `LP`-consequence `entails` is a genuine **Tarskian closure operator**
  (`entails_refl`, `entails_monotone`, `entails_cut`) and validates the *monotone*
  introductions (`entails_and_intro`, `entails_or_intro_left`), while disjunctive syllogism
  fails (`disjunctive_syllogism_fails`). The two value-level lemmas `desig_conj`,
  `desig_disj_left` isolate the monotonicity of designation under `min`/`max` that powers the
  survivors. We further prove that the non-monotone `LPm` **recaptures** modus ponens on
  consistent premises (`entailsMin_recovers_mp`).

The deep half of Priest's characterization — flagged as a conjecture in the seeding concept —
was **closed this cycle**: `lp_validity_eq_classical` proves a formula is `LP`-valid iff it is
classically valid. The naive truth-order squeeze fails because negation is antitone; the fix
is the asymmetric **Collapsing Lemma** `collapse_preserve`, showing a *single* classical
collapse `bb ↦ tt` preserves every classical output of `eval` simultaneously, so the negation
and binary-connective cases all go through by one structural induction.

## Results Summary (all proved, `sorry = 0`, only `propext`/`Classical.choice`/`Quot.sound`)

- `explosion_fails`, `contradiction_satisfiable`, `lem_valid`, `lnc_valid`, `mp_fails`,
  `double_negation`, `retraction_nonmonotone` — object-level `LP` phenomena.
- `desig_conj`, `desig_disj_left` — designation closed under `min`/`max`.
- `entails_refl`, `entails_monotone`, `entails_cut` — `entails` is a Tarskian closure operator.
- `entails_and_intro`, `entails_or_intro_left` — surviving monotone introductions.
- `disjunctive_syllogism_fails` — the signature paraconsistent invalidity.
- `entailsMin_recovers_mp` — `LPm` recaptures MP on consistent premises.
- `LPvalid_imp_classicallyValid`, `eval_embed_classical`, `collapse_preserve`,
  `lp_validity_eq_classical` — the full Priest validity characterization.

## Research Directions

### Direction 1: Does Cut fail for the non-monotone `LPm`?
**Conjecture.** `entailsMin` does **not** admit Cut: there exist `Γ`, `A`, `B` with
`entailsMin Γ A` and `entailsMin (insert A Γ) B` but `¬ entailsMin Γ B`.
**Test.** Search small premise sets over atoms `{0,1,2}` for a witness, computing minimal
models by brute force over the finite valuation space restricted to the occurring atoms; then
formalize the counterexample against the existing `IsMinModel`/`entailsMin` definitions.
Conversely, attempt a Cut proof and locate the exact step where minimality of models is not
preserved under adding `A` (the candidate failure point: adding `A` can *force a new glut*,
enlarging every model's glut set and thereby changing the minimal ones).
**The key insight is** that `entails_cut` succeeds only because *every* model of `Γ` already
models `insert A Γ` when `Γ ⊢ A`; for `entailsMin` the analogous step must preserve
*minimality*, and forcing `A` can destroy a previously-minimal glut-free model. **Why now?**
`entails_cut` gives a clean template of a working Cut proof, and `retraction_nonmonotone`
already exhibits exactly the glut-forcing phenomenon (adding `¬p` to a consistent set) that
should also break Cut, so the counterexample is one short modification away. *If true*, Cut is
pinpointed as the structural rule separating monotone `LP` from non-monotone `LPm`, completing
the dichotomy. *If false*, `LPm` is a closure operator despite non-monotonicity — a genuinely
surprising result worth a paper on its own.

### Direction 2: Quantify the exact "recapture zone" of `LPm`
**Conjecture.** For every premise set `Γ` possessing a glut-free model,
`entailsMin Γ A ↔ ClassicalConsequence Γ A` for all `A`; i.e. `LPm` collapses *exactly* to
classical logic on consistent theories.
**Test.** Define classical consequence over boolean (`embed`) valuations. Prove the pivotal
lemma **"every minimal model of a consistent `Γ` is glut-free"** by generalizing the argument
in `entailsMin_recovers_mp` (the all-`tt`/glut-free model has empty glut set, strictly below
any nonempty one). Then both inclusions follow; the non-trivial one is `LPm ⊆ classical`.
**The key insight is** that minimality is measured by the glut set under strict inclusion, and
a consistent theory admits an empty-glut model, which is `⊂`-below every glutty model — so
minimal models *cannot* carry gluts. **Why now?** `entailsMin_recovers_mp` is already a
concrete instance of this collapse; the only new ingredient is the general "minimal ⟹
glut-free" lemma, and `lp_validity_eq_classical`'s collapse machinery (`collapse`,
`collapse_preserve`) provides the glut-elimination tooling. *If true*, `LPm` is a conservative
*non-monotone* extension of classical logic — classical when consistent, paraconsistent only
when forced — a precise formalization of the "dream logic" slogan. *If false*, some consistent
theory has a minimal model carrying an unnecessary glut, exposing a pathology of the
minimality definition.

### Direction 3: A sound (and complete?) sequent calculus matching `entails`
**Conjecture.** There is a finite sequent calculus whose structural rules are exactly
reflexivity + weakening + Cut and whose connective rules are adjunction, addition, double
negation, LEM and LNC — but **no** DS/MP — and it is sound and complete for `entails`.
**Test.** Define an inductive derivability relation `Derives : Set Form → Form → Prop` from
these rules, prove **soundness** `Derives Γ A → entails Γ A` by assembling this cycle's rule
lemmas (`entails_refl`, `entails_monotone`, `entails_cut`, `entails_and_intro`,
`entails_or_intro_left`, plus `lem_valid`/`lnc_valid`/`double_negation`), then attempt
completeness via a maximal-`LP`-consistent-set / canonical-model construction.
**The key insight is** that this cycle already proved *every individual rule* of the proposed
calculus as a semantic validity, so soundness is essentially a structural induction that
glues existing lemmas together. **Why now?** The rule lemmas exist and are sorry-free, so
soundness is low-risk and immediate; completeness is the genuinely open, high-value part.
*If true*, dream logic gains a fully verified deductive apparatus, turning the semantics into
usable proof theory. *If false* for completeness, the failing rule isolates a semantic
inference with no finite syntactic counterpart — a concrete incompleteness phenomenon.

### Direction 4: Glut models as pre-topological "dream spaces"
**Conjecture.** For a fixed theory `Γ`, the family of *definable* sets
`{ v | Holds v A }` (one per formula `A`) is closed under finite intersection but **fails**
closure under arbitrary union, and the failure of the union axiom occurs *precisely* when `Γ`
forces a glut.
**Test.** Map each formula `A` to its satisfying-valuation set `S A := { v | Holds v A }`.
Show `S (conj A B) = S A ∩ S B` (immediate from `desig_conj`, giving finite-intersection
closure), then exhibit definable sets whose union is *not* definable exactly when a glut is
forced, mirroring the standard separation between a pre-topology and a topology.
**The key insight is** that `Holds v (conj A B) ↔ Holds v A ∧ Holds v B` makes the definable
sets a `∩`-closed family (a π-system), so the only obstruction to being a topology lives in
the union axiom — and that obstruction is exactly the glut. **Why now?** `desig_conj` already
hands us the intersection law for free, and the glut value is the single new ingredient versus
classical (`Bool`) semantics, where definable sets *are* closed under the relevant unions.
*If true*, paraconsistency is realized as honest pre-topological geometry, with "contradiction"
= "failure of the union axiom" — a cross-domain bridge. *If false*, definable sets are richer
(union-closed after all), redirecting the bridge to a coarser sub-family of "opens".

### Direction 5: First-order / quantified `LP` and the fate of the Collapsing Lemma
**Conjecture.** The Collapsing Lemma `collapse_preserve` — and hence
`lp_validity_eq_classical` — extends to a **first-order** `LP` with `∀`/`∃` interpreted as
infinitary `min`/`max` over a domain, so that first-order `LP`-validity again coincides with
classical first-order validity over the *same* models.
**Test.** Add `Form.all`/`Form.ex` binding a domain variable, evaluate `∀` as the infimum and
`∃` as the supremum of the body over domain elements in the chain `ff < bb < tt`, and attempt
to push `collapse_preserve` through the quantifier cases (the infimum/supremum of classical
values stays classical, mirroring the `conj`/`disj` cases). Refute by finding a classically
valid first-order sentence with a glut model whose collapse makes it `ff`.
**The key insight is** that `∀`/`∃` are just infinitary `conj`/`disj`, and the Collapsing
Lemma already handles the binary cases by a *single* global collapse `bb ↦ tt` that works for
both polarities — the same global collapse should survive infinitary `min`/`max`. **Why now?**
The propositional Collapsing Lemma is freshly proved and its structure (one collapse, two
preserved polarities) is exactly what is needed to commute with arbitrary `inf`/`sup`; the
quantifier step is a direct generalization rather than a new idea. *If true*, the propositional
conservativity result lifts to predicate logic, a substantially stronger "gluts add no
theorems" statement. *If false*, quantifiers genuinely add paraconsistent validities absent
classically — the most interesting possible outcome, isolating where infinitary gluts bite.
