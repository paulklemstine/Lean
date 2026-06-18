
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   **Must be fully self-contained and publishable without any external
   references.** State every theorem, result, and definition inline —
   do NOT use @file references or point to other files. A reader with
   only this article must understand every result without looking elsewhere.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work.
   **Must be fully self-contained and publishable quality without any
   external references.** State every theorem, lemma, and definition
   inline with its full mathematical statement and proof sketch. Do NOT
   use @file references or reference other files. A reader with only this
   paper must be able to follow every result from start to finish.
3. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "demo": "demo.py",
  "demos": [
    {"name": "Descriptive and Professional Title of the Python Demo", "description": "A comprehensive, high-quality description of what this Python demo calculates and shows mathematically.", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "Formal Mathematical Title of the Algorithm",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
  ],
  "visualizations": [
    {"name": "Descriptive Visualization Title", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Beautiful Math-Rich Interactive Widget Title", "description": "Detailed description of the interactive widget and what users can explore.", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: This cycle moved the catalog's Dream Logic line of work from the *object level* 
**Domain**: Logic
**Mathematical framing**: # Future Directions — Dream Logic II: Structural Meta-Theory of Paraconsistent Consequence

## Synthesis

This cycle moved the catalog's Dream Logic line of work from the *object level* to the
*meta level*. The existing `Logic.DreamLogic.Paraconsistent` file had established how
Priest's Logic of Paradox (`LP`) behaves on individual formulas — contradictions do not
explode (`explosion_fails`), gluts are satisfiable (`contradiction_satisfiable`), excluded
middle and non-contradiction remain laws (`lem_valid`, `lnc_valid`), modus ponens fails
(`mp_fails`), and the minimal-glut relation `entailsMin` is non-monotone
(`retraction_nonmonotone`). What was missing was a clean account of *which structural
properties of a consequence relation survive paraconsistency*. The new file
`NonMonotone.lean` answers this: `LP`-consequence (`entails`) is a genuine Tarskian closure
operator — it satisfies reflexivity, monotonicity, and **Cut** — even though it rejects the
connective inferences of disjunctive syllogism and modus ponens.

The structural insight that emerged is a sharp dichotomy: **structural rules survive,
connective rules die.** The structural rules go through purely because `entails` quantifies
over models and "holding" is preserved under shrinking the premise set or substituting an
already-entailed formula. The connective failures (DS, MP), by contrast, are powered by a
single semantic fact — that a value `a` and its negation `LP.neg a` can be *simultaneously*
designated (the glut `bb`). The two value-level lemmas `LP.desig_conj` and
`LP.desig_disj_left` isolate exactly the monotonicity of designation under `min`/`max` that
makes adjunction and addition valid, while the *absence* of a disjointness law between a
value and its negation is what kills DS/MP. We also pinned down the precise sense in which
the non-monotone `LPm` is an *improvement* on `LP`: on a consistent premise set it recovers
the very modus-ponens conclusion `LP` discards (`entailsMin_recovers_mp`), i.e. classical
inference is recaptured exactly where no impossible object is forced.

What did not close: the deep half of Priest's characterization, that the `LP`-valid formulas
are *exactly* the classical tautologies. The easy direction (`LPvalid_imp_classicallyValid`)
is proved; the converse is recorded as the conjecture `lp_validity_eq_classical`. Its proof
needs a "squeeze" induction over formula structure using the two classical collapses of a
glut valuation, which is the natural next experiment.

## Results Summary

- `LP.desig_conj`: proved — designation is closed under conjunction (`min`), the engine of adjunction.
- `LP.desig_disj_left`: proved — designation is closed under disjunction (`max`), the engine of addition.
- `entails_refl`: proved — `LP`-consequence is reflexive.
- `entails_monotone`: proved — `LP`-consequence is monotone (the rule `LPm` deliberately breaks).
- `entails_cut`: proved — `LP`-consequence admits Cut, so it is a genuine Tarskian closure operator.
- `entails_and_intro`: proved — `LP` validates conjunction introduction (adjunction).
- `entails_or_intro_left`: proved — `LP` validates left disjunction introduction (addition).
- `disjunctive_syllogism_fails`: proved (disproof/counterexample) — the signature paraconsistent invalidity `{p, ¬p ∨ q} ⊭ q`.
- `entailsMin_recovers_mp`: proved — `LPm` recovers a modus-ponens conclusion that `LP` loses, so `LPm` is strictly stronger on consistent premises.
- `LPvalid_imp_classicallyValid`: proved — `LP`-validity implies classical validity (easy half of Priest's theorem).
- `lp_validity_eq_classical`: conjecture — the full equivalence "`LP`-valid ⟺ classically valid" (hard converse left as `sorry`).

## Research Directions

### Direction 1: Close Priest's validity characterization
**Hypothesis**: For every `Form` `A`, `LPvalid A ↔ ClassicallyValid A`; equivalently, the
converse `ClassicallyValid A → LPvalid A` holds.
**Test**: Prove by induction on `A` the "collapse" lemma: for any valuation `v`, define the
classical collapses `v⁺` (gluts `bb ↦ tt`) and `v⁻` (gluts `bb ↦ ff`); show
`eval v⁻ A ≤ eval v A ≤ eval v⁺ A` in the order `ff < bb < tt`, then deduce that if both
classical collapses designate `A` so does `v`. Refute by finding a classically valid `A`
with a glut valuation making `eval v A = ff`.
**Why now**: The forward direction and all the value-level designation lemmas
(`LP.desig_conj`, `LP.desig_disj_left`) are already in place; the order structure on `LP` is
exactly the `ff < bb < tt` chain these lemmas exploit, so the squeeze induction is a short
hop from existing machinery.
**If true**: Confirms that gluts add zero theorems while subtracting inferences — a precise
"conservativity over classical tautologies" statement, and a reusable bridge lemma for any
later `LP`/`LPm` completeness work.
**If false**: Would expose a divergence between this formalization's connectives and standard
`LP`, flagging a definitional bug in `eval`/`neg`/`conj`/`disj` worth fixing.

### Direction 2: Does Cut fail for the non-monotone `LPm`?
**Hypothesis**: `entailsMin` does **not** admit Cut: there exist `Γ, A, B` with
`entailsMin Γ A` and `entailsMin (insert A Γ) B` but `¬ entailsMin Γ B`.
**Test**: Search small premise sets over atoms `{0,1,2}` for a counterexample, using the
minimal-glut models computed by brute force over the finite valuation space restricted to the
occurring atoms; then formalize the witness. Conversely, attempt a Cut proof and locate the
exact step where minimality of models is not preserved under adding `A`.
**Why now**: `entails_cut` gives a clean template of what a working Cut proof looks like, and
`retraction_nonmonotone` already exhibits the non-monotone behaviour of `entailsMin` on a
two-atom set — the same machinery should produce a Cut counterexample.
**If true**: Pinpoints Cut as the structural rule that distinguishes monotone `LP` from
non-monotone `LPm`, completing the structural dichotomy started this cycle.
**If false** (Cut holds): `LPm` would be a surprisingly well-behaved non-monotone logic,
suggesting it is a closure operator despite non-monotonicity — a genuinely novel result.

### Direction 3: Bridge gluts to the pre-topological dream spaces
**Hypothesis**: The set of `LP`-valuations satisfying a fixed theory `Γ` carries a
`DreamSpace` structure (from `Logic.DreamLogic.DreamSpace`) whose "open" sets are exactly the
sets definable by single formulas, and this dream space is non-topological precisely when `Γ`
forces at least one glut.
**Test**: Define the map sending a formula `A` to its satisfying valuation set `{v | Holds v A}`,
show these sets satisfy the `DreamSpace` axioms (closure under finite intersection via
`entails_and_intro`), and exhibit a union of definable sets that is not definable iff a glut
is forced — mirroring `singletonDream_not_topological`.
**Why now**: `entails_and_intro` gives the finite-intersection closure for free, and
`DreamSpace.lean` already supplies the target structure and a non-topological separation
template; the two catalog files have never been connected.
**If true**: A genuine cross-domain bridge — paraconsistent semantics realized as
pre-topological geometry, with "contradiction" corresponding to "failure of the union axiom".
**If false**: Tells us definable sets are too rich (closed under union after all), redirecting
the bridge toward a coarser sub-collection of opens.

### Direction 4: Quantify the "recapture zone" of `LPm`
**Hypothesis**: For every premise set `Γ` with a glut-free (classical) model,
`entailsMin Γ A ↔ ClassicalConsequence Γ A` for all `A`; i.e. `LPm` collapses exactly to
classical logic on consistent theories.
**Test**: Define classical consequence over `Classical2` valuations, prove that any
glut-free model of `Γ` is minimal (its glut set `∅` cannot be properly shrunk), and conclude
both inclusions. The non-trivial inclusion `LPm ⊆ classical` needs that minimal models of a
consistent `Γ` are all glut-free.
**Why now**: `entailsMin_recovers_mp` is the first instance of exactly this collapse on a
concrete consistent set; generalizing the witness argument (every minimal model is glut-free)
is the obvious next step, and `classical_no_contradiction` already supplies the consistency
lemma for classical valuations.
**If true**: Establishes `LPm` as a conservative *non-monotone* extension of classical logic —
classical when you can be, paraconsistent only when forced — a precise formal statement of the
"dream logic" slogan.
**If false**: Reveals minimal models that carry unnecessary gluts even over consistent
theories, which would be a striking and instructive pathology of the minimality definition.

### Direction 5: A proof-theoretic (Hilbert/sequent) calculus matching `entails`
**Hypothesis**: There is a finite sound-and-complete sequent calculus for `entails`, and its
structural rules are exactly reflexivity + monotonicity (weakening) + Cut, with the
connective rules being adjunction, addition, double negation, LEM and LNC — but **no** DS/MP.
**Test**: Define a syntactic derivability relation `⊢` inductively from these rules and prove
soundness (`Γ ⊢ A → entails Γ A`) using this cycle's structural and connective theorems as the
rule-validity lemmas; then attempt completeness via a maximal-consistent-set construction.
**Why now**: This cycle already proved *every individual rule* of the proposed calculus
(`entails_refl`, `entails_monotone`, `entails_cut`, `entails_and_intro`,
`entails_or_intro_left`, plus the catalog's `lem_valid`/`lnc_valid`/`double_negation`), so
soundness is essentially assembling existing lemmas.
**If true**: Yields a fully verified proof system for dream logic, turning the semantic
results into a usable deductive apparatus.
**If false**: The failing rule identifies a semantic inference with no finite syntactic
counterpart — a concrete incompleteness phenomenon worth isolating.

Research domain: Logic
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Logic/DreamLogic/NonMonotone.lean
import Logic.DreamLogic.Paraconsistent

/-!
# Dream Logic II: Structural Meta-Theory of Paraconsistent Consequence

Where `Logic.DreamLogic.Paraconsistent` studied how `LP` behaves on *individual formulas*,
this file studies the *consequence relation itself*.  The central finding is a sharp
dichotomy:

> **Structural rules survive paraconsistency; connective rules die.**

Concretely, `LP`-consequence `entails` is a genuine **Tarskian closure operator** — it
satisfies reflexivity (`entails_refl`), monotonicity (`entails_monotone`) and **Cut**
(`entails_cut`) — and it validates the *monotone* connective introductions adjunction
(`entails_and_intro`) and addition (`entails_or_intro_left`).  Yet it *rejects* the
*eliminative* connective inferences: disjunctive syllogism / modus ponens fail
(`disjunctive_syllogism_fails`, and `mp_fails` in the companion file).

The two value-level lemmas `desig_conj` and `desig_disj_left` isolate exactly the
monotonicity of designation under `min`/`max` powering the surviving introductions; the
*absence* of any disjointness law between a value and its negation (the glut `bb` designates
together with `neg bb = bb`) is what kills the eliminations.

Finally we relate `LP` to classical logic.  **Priest's validity characterization**
`lp_validity_eq_classical` is proved in full: a formula is `LP`-valid iff it is classically
valid.  The forward inclusion is trivial (`LPvalid_imp_classicallyValid`); the converse goes
through the **Collapsing Lemma** `collapse_preserve`, which shows a single classical collapse
(`bb ↦ tt`) preserves every classical output of `eval`.  We also pin down the precise sense
in which the non-monotone `LPm` *improves* on `LP`: on a consistent premise set it
**recovers** the very modus-ponens conclusion that `LP` discards (`entailsMin_recovers_mp`).

-- !-- Lab Notebook -- !--
Hypothesis: The Tarski structural rules (reflexivity, monotonicity, Cut) are orthogonal to
  paraconsistency and should survive verbatim, while the explosive connective rules should
  fail; the dividing line should be expressible at the level of single truth values.
Result: Confirmed. All three structural rules go through by elementary model-quantifier
  manipulation; adjunction/addition reduce to `desig_conj`/`desig_disj_left`; DS/MP fail on
  the single glut valuation `p ↦ bb, q ↦ ff`.
Insight: The monotone connectives (∧,∨ introductions) need only that designation is closed
  under `min`/`max`; the eliminative ones additionally need a value to be *disjoint* from its
  negation, which the glut `bb` violates. One value, `bb`, simultaneously explains LEM/LNC
  validity and DS/MP failure.
Failure analysis: The full Priest equivalence `LPvalid ↔ ClassicallyValid` does NOT close by
  a naive ≤-squeeze, because negation is *antitone* and flips the squeeze direction. The fix
  was the asymmetric **Collapsing Lemma**: a *single* classical collapse `bb ↦ tt` preserves
  both classical outputs simultaneously (`collapse_preserve`), so the negation case (which
  swaps `tt`/`ff`) and the binary cases (which need one refinement for both subformulas) all
  go through. The earlier two-collapse attempt failed precisely on negation.
-/

namespace DreamLogic

/-! ### Value-level designation lemmas (the engine of the surviving rules) -/

-- !-- `conj = min`: designated unless some conjunct is `ff`, so two designated values stay
--    designated. Proof by the 3×3 case table. -- !--
/-- Designation is closed under conjunction (`min`) — the engine of **adjunction**. -/
theorem desig_conj {a b : LPval} (ha : a.desig) (hb : b.desig) : (LPval.conj a b).desig := by
  cases a <;> cases b <;> simp_all [LPval.conj, LPval.desig]

-- !-- `disj = max ≥ a`, so a designated left disjunct is preserved. -- !--
/-- Designation is closed under (left) disjunction (`max`) — the engine of **addition**. -/
theorem desig_disj_left {a b : LPval} (ha : a.desig) : (LPval.disj a b).desig := by
  cases a <;> cases b <;> simp_all [LPval.disj, LPval.desig]

/-! ### Structural rules: `entails` is a Tarskian closure operator -/

-- !-- Reflexivity: a premise holds in every model of the premise set, by definition. -- !--
/-- **Reflexivity.** Any premise is a consequence of the premise set. -/
theorem entails_refl {Γ : Set Form} {A : Form} (hA : A ∈ Γ) : entails Γ A := by
  intro v hv; exact hv A hA

-- !-- Monotonicity: a model of the larger set is a model of the smaller set. -- !--
/-- **Monotonicity (weakening).** Enlarging the premise set preserves consequence.
The non-monotone relation `entailsMin` deliberately breaks this (`retraction_nonmonotone`). -/
theorem entails_monotone {Γ Δ : Set Form} {A : Form} (hsub : Γ ⊆ Δ) (h : entails Γ A) :
    entails Δ A :=
  fun v hv => h v (fun B hB => hv B (hsub hB))

-- !-- Cut: a model of Γ already models `insert A Γ` because `A` is entailed by Γ. -- !--
/-- **Cut.** If `Γ ⊢ A` and `Γ, A ⊢ B` then `Γ ⊢ B`. Together with reflexivity and
monotonicity this makes `entails` a genuine Tarskian closure operator. -/
theorem entails_cut {Γ : Set Form} {A B : Form} (hA : entails Γ A)
    (hB : entails (insert A Γ) B) : entails Γ B := by
  intro v hv
  apply hB v
  intro C hC
  rcases Set.mem_insert_iff.mp hC with rfl | h
  · exact hA v hv
  · exact hv C h

/-! ### Surviving connective rules: the *introductions* -/

-- !-- Adjunction follows pointwise from `desig_conj`. -- !--
/-- **Adjunction (∧-introduction).** `LP` validates conjunction introduction. -/
theorem entails_and_intro {Γ : Set Form} {A B : Form} (hA : entails Γ A) (hB : entails Γ B) :
    entails Γ (Form.conj A B) := by
  intro v hv; exact desig_conj (hA v hv) (hB v hv)

-- !-- Addition follows pointwise from `desig_disj_left`. -- !--
/-- **Addition (∨-introduction, left).** `LP` validates left disjunction introduction. -/
theorem entails_or_intro_left {Γ : Set Form} {A B : Form} (hA : entails Γ A) :
    entails Γ (Form.disj A B) := by
  intro v hv; exact desig_disj_left (hA v hv)

/-! ### Dying connective rule: the *elimination* -/

-- !-- The glut valuation `p ↦ bb, q ↦ ff` designates `p` and `¬p ∨ q` but not `q`. -- !--
/-- **Disjunctive syllogism fails.** `{p, ¬p ∨ q} ⊭ q` — the signature paraconsistent
invalidity, the dual of `mp_fails`. -/
theorem disjunctive_syllogism_fails :
    ¬ entails {Form.atom 0, Form.disj (Form.neg (Form.atom 0)) (Form.atom 1)} (Form.atom 1) := by
  intro h
  have key := h (fun n => if n = 0 then LPval.bb else LPval.ff) (by
    intro B hB
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hB
    rcases hB with rfl | rfl <;> (simp only [Holds]; decide))
  exact (by simp only [Holds]; decide :
    ¬ Holds (fun n => if n = 0 then LPval.bb else LPval.ff) (Form.atom 1)) key

/-! ### Recapture: the non-monotone `LPm` recovers MP on consistent premises -/

-- !-- Every minimal model is glut-free (the all-`tt` model has empty glut set ⊂ any
--    nonempty one), and a glut-free model of `{p, ¬p∨q}` forces `p = q = tt`. -- !--
/-- **Recapture of modus ponens.** On the *consistent* premise set `{p, p ⊃ q}` the
non-monotone relation `LPm` recovers the modus-ponens conclusion `q` that `LP` discards
(`mp_fails`). Hence `LPm` is strictly stronger than `LP` exactly where no impossible
object is forced. -/
theorem entailsMin_recovers_mp :
    entailsMin {Form.atom 0, Form.imp (Form.atom 0) (Form.atom 1)} (Form.atom 1) := by
  intro v hv
  obtain ⟨hmod, hminl⟩ := hv
  set c : Valuation := fun _ => LPval.tt with hc
  have hcmod : Models {Form.atom 0, Form.imp (Form.atom 0) (Form.atom 1)} c := by
    intro B hB
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hB
    rcases hB with rfl | rfl <;> (simp only [Holds]; decide)
  have hcempty : GlutSet c = ∅ := by ext n; simp [GlutSet, hc]
  have hvempty : GlutSet v = ∅ := by
    by_contra hne
    apply hminl c hcmod
    rw [hcempty]
    exact Set.empty_ssubset.mpr (Set.nonempty_iff_ne_empty.mpr hne)
  have hglutfree : ∀ n, v n ≠ LPval.bb := by
    intro n
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
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

## Research Directi
```

## Your task

Produce the deliverables listed above. The Lean file is the source of truth —
your prose must accurately explain it. Both ARTICLE.md and RESEARCH_PAPER.md
MUST be self-contained and publishable without referencing any external files.
State every theorem, definition, and result inline so a reader can follow the
entire argument from the document alone.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a clear, professional mathematical title in 'name' (do not use generic placeholders; this will be displayed as the header on the interactive site), a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. For each Python demo in the demos array, provide a highly descriptive title in 'name', a comprehensive functional description in 'description', and the implementation code in 'code'. For each interactive HTML demo in interactive_demos, provide a beautiful title in 'title' and a detailed description in 'description'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
