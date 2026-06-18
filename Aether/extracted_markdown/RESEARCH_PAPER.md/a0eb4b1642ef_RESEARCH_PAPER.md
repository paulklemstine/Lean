# Dream Logic II: A Structural Meta-Theory of Paraconsistent Consequence

## Abstract

We give a complete structural meta-theory for the consequence relation of Priest's
**Logic of Paradox** (`LP`), the canonical three-valued paraconsistent logic. Where
the object-level theory studies how `LP` evaluates individual formulas, we study the
*consequence relation itself* and establish a sharp dichotomy:

> **Structural rules survive paraconsistency; connective elimination rules die.**

Precisely, `LP`-consequence is a genuine **Tarskian closure operator**: it satisfies
reflexivity, monotonicity (weakening), and Cut. It further validates the *monotone*
connective **introduction** rules — adjunction (`∧`-introduction) and addition
(`∨`-introduction) — while **rejecting** the *eliminative* rules disjunctive syllogism
and modus ponens. We isolate the precise value-theoretic cause: the surviving rules
require only that the set of *designated* (accepted) truth values is closed under the
order operations `min` and `max`, whereas the eliminative rules require a
*disjointness* between a value and its negation that the glut value `bb` (a fixed
point of negation, `neg bb = bb`) flatly denies. We then study the non-monotone
minimal-glut refinement `LPm` ("dream logic"), proving that it **recaptures** modus
ponens on consistent premise sets — recovering exactly the conclusions classical
logic licenses where no contradiction is forced — at the cost of monotonicity.
Finally we settle **Priest's validity characterization**: a formula is `LP`-valid iff
it is classically valid, via an asymmetric *Collapsing Lemma* that circumvents the
failure of the naive truth-order squeeze under (antitone) negation. The upshot is a
precise *conservativity* statement: gluts subtract inferences but add no theorems.
All results are mechanically verified; here we present the mathematics with proof
sketches.

**Keywords.** paraconsistent logic, Logic of Paradox, glut, Tarskian closure
operator, Cut elimination, disjunctive syllogism, non-monotonic logic, structural
rules.

---

## 1. Introduction

### 1.1 The problem of explosion

In classical logic, a single contradiction trivializes a theory. From premises `A`
and `¬A` one derives an arbitrary `B` by the principle *ex contradictione quodlibet*:

```
A,  ¬A
─────────  (weakening / addition)
A ∨ B,  ¬A
─────────  (disjunctive syllogism)
   B
```

The detonating step is **disjunctive syllogism** (DS): from `A ∨ B` and `¬A`,
conclude `B`. A logic is **paraconsistent** if it blocks explosion, i.e. if `A, ¬A ⊬
B` in general. Priest's **Logic of Paradox** (`LP`) is the best-known paraconsistent
logic; it does so by admitting truth-value *gluts* (statements both true and false)
and consequently invalidating DS.

### 1.2 Object level versus meta level

The object-level theory of `LP` (developed in a companion file `Paraconsistent.lean`)
establishes the classic phenomena on *individual formulas*: explosion fails, gluts are
satisfiable, excluded middle and non-contradiction remain valid, modus ponens fails,
double negation holds, and the minimal-glut relation is non-monotone. What was missing
was a systematic account of *which structural properties of the consequence relation
survive paraconsistency.* This paper supplies that account.

### 1.3 Contributions

1. **A structural dichotomy** (§4–§6). `LP`-consequence is a Tarskian closure
   operator (reflexivity, monotonicity, Cut), and validates the monotone connective
   *introductions*, while the *eliminations* (DS, MP) fail. We trace the dividing
   line to a single fact about truth values.
2. **Value-level engines** (§3). Two lemmas, `desig_conj` and `desig_disj_left`,
   isolate closure of designation under `min`/`max` as the exact cause of the
   surviving introductions.
3. **Recapture of classical inference** (§7). The non-monotone refinement `LPm`
   recovers modus ponens on consistent premise sets, formalizing the slogan
   "classical when you can be, paraconsistent only when forced."
4. **Priest's validity characterization** (§8). `LP`-valid ⟺ classically valid, via
   an asymmetric Collapsing Lemma that repairs the failure of the naive squeeze under
   negation. Consequence: `LP` is conservative over classical tautologies.

---

## 2. The semantic framework

### 2.1 Truth values

The truth-value space of `LP` is the three-element chain

```
LPval  =  { ff, bb, tt },        ordered    ff < bb < tt.
```

We read `ff` as *false*, `tt` as *true*, and `bb` as *both* — the **glut**, a value
that is simultaneously true and false. The **designated** (accepted) values are those
that count as assertible:

> **Definition 2.1 (Designation).** A value `a : LPval` is *designated*, written
> `a.desig`, iff `a ∈ {bb, tt}`; equivalently iff `a ≥ bb` in the chain.

### 2.2 Connectives

The connectives are the Kleene/Priest operations on the chain:

> **Definition 2.2 (Connectives on values).**
> - `neg ff = tt`, `neg tt = ff`, and `neg bb = bb` (negation fixes the glut);
> - `conj a b = min(a, b)` (conjunction is the order meet);
> - `disj a b = max(a, b)` (disjunction is the order join).

The defining peculiarity is the negation fixed point `neg bb = bb`: a glut is its own
negation. This single equation drives every positive and negative result below.

### 2.3 Formulas, valuations, evaluation

> **Definition 2.3 (Formulas).** `Form` is the inductive type of propositional
> formulas over atoms `ℕ`: `atom n`, `neg A`, `conj A B`, `disj A B`, and the defined
> conditional `imp A B := disj (neg A) B`.

> **Definition 2.4 (Valuation and evaluation).** A *valuation* is a function
> `v : ℕ → LPval`. Evaluation `eval v : Form → LPval` extends `v` homomorphically over
> the connectives (`eval v (neg A) = neg (eval v A)`, etc.).

> **Definition 2.5 (Holding and models).** A formula `A` *holds* in `v`, written
> `Holds v A`, iff `(eval v A).desig`. A valuation `v` is a *model* of a theory
> `Γ : Set Form`, written `Models Γ v`, iff `Holds v B` for every `B ∈ Γ`.

### 2.4 The consequence relations

> **Definition 2.6 (`LP`-consequence).** `entails Γ A` holds iff every model of `Γ`
> holds `A`:
> `entails Γ A  :⟺  ∀ v, Models Γ v → Holds v A.`

> **Definition 2.7 (Glut set and minimal models).** The *glut set* of a valuation is
> `GlutSet v := { n | v n = bb }`. A model `v` of `Γ` is *minimal* iff no model `w` of
> `Γ` has `GlutSet w ⊊ GlutSet v`.

> **Definition 2.8 (`LPm`-consequence — "dream logic").** `entailsMin Γ A` holds iff
> every *minimal* model of `Γ` holds `A`.

> **Definition 2.9 (Validity).** `A` is *`LP`-valid* (`LPvalid A`) iff `Holds v A` for
> all `v`. A valuation is *classical* if it never takes value `bb`; `A` is *classically
> valid* (`ClassicallyValid A`) iff `Holds v A` for all classical `v`.

---

## 3. Value-level designation lemmas (the engine)

The surviving connective introductions reduce to two elementary facts about the
designated set. Both are proved by exhausting the finite (`3 × 3`) value table.

> **Lemma 3.1 (`desig_conj`).** If `a.desig` and `b.desig` then `(conj a b).desig`.
>
> *Proof sketch.* `conj = min`. Designation means `≥ bb`. If both inputs are `≥ bb`
> then so is their minimum. (Equivalently: `min(a,b)` is `ff` only when some input is
> `ff`, which is excluded.) ∎

> **Lemma 3.2 (`desig_disj_left`).** If `a.desig` then `(disj a b).desig` for any `b`.
>
> *Proof sketch.* `disj = max ≥ a`. A maximum dominates its left argument, so if `a`
> is designated the join is designated regardless of `b`. ∎

These are the *only* connective facts the introductions need: closure of the
designated set under `min` and `max`. Crucially, **neither lemma has any analogue for
elimination** — there is no lemma of the form "if `(neg a).desig` then `a` is *not*
designated," because for `a = bb` both `a` and `neg a = bb` are designated. The
absence of this disjointness is what §6 exploits.

---

## 4. Structural rules: `entails` is a Tarskian closure operator

A consequence relation `⊢` is a **Tarskian closure operator** if it satisfies
reflexivity, monotonicity, and Cut. We prove all three for `entails`. Notably, *none*
of the proofs inspects the connectives: they manipulate only the model quantifier of
Definition 2.6, which is why they are indifferent to paraconsistency.

> **Theorem 4.1 (`entails_refl` — Reflexivity).** If `A ∈ Γ` then `entails Γ A`.
>
> *Proof.* Let `v` be a model of `Γ`. By Definition 2.5, `Holds v B` for every
> `B ∈ Γ`; instantiate at `B = A ∈ Γ`. ∎

> **Theorem 4.2 (`entails_monotone` — Monotonicity / Weakening).** If `Γ ⊆ Δ` and
> `entails Γ A` then `entails Δ A`.
>
> *Proof.* Any model `v` of `Δ` holds every formula in `Δ`, hence (since `Γ ⊆ Δ`)
> every formula in `Γ`, so `v` models `Γ`; apply `entails Γ A`. ∎

> **Theorem 4.3 (`entails_cut` — Cut).** If `entails Γ A` and
> `entails (insert A Γ) B` then `entails Γ B`.
>
> *Proof.* Let `v` model `Γ`. To apply the second hypothesis we must show `v` models
> `insert A Γ`, i.e. holds every `C ∈ {A} ∪ Γ`. If `C = A`, use `entails Γ A` and that
> `v` models `Γ`. If `C ∈ Γ`, use that `v` models `Γ`. Hence `Holds v B`. ∎

> **Corollary 4.4.** `entails` is a Tarskian closure operator: the operator
> `Cn(Γ) := { A | entails Γ A }` satisfies `Γ ⊆ Cn(Γ)` (4.1), `Γ ⊆ Δ ⇒ Cn(Γ) ⊆ Cn(Δ)`
> (4.2), and `Cn(Cn(Γ)) = Cn(Γ)` (4.3 plus 4.1). ∎

---

## 5. Surviving connective rules: the introductions

> **Theorem 5.1 (`entails_and_intro` — Adjunction).** If `entails Γ A` and
> `entails Γ B` then `entails Γ (conj A B)`.
>
> *Proof.* Fix a model `v` of `Γ`. Then `Holds v A` and `Holds v B`, i.e.
> `(eval v A).desig` and `(eval v B).desig`. Since `eval v (conj A B) =
> conj (eval v A) (eval v B)`, Lemma 3.1 gives `(eval v (conj A B)).desig`. ∎

> **Theorem 5.2 (`entails_or_intro_left` — Addition).** If `entails Γ A` then
> `entails Γ (disj A B)` for any `B`.
>
> *Proof.* Fix a model `v` of `Γ`; then `(eval v A).desig`. Since
> `eval v (disj A B) = disj (eval v A) (eval v B)`, Lemma 3.2 gives the result. ∎

Excluded middle (`disj A (neg A)` always holds) and non-contradiction
(`neg (conj A (neg A))` always holds) are companion object-level validities of the
same monotone character; they too require only `min`/`max` monotonicity of the
designated set.

---

## 6. The dying connective rule: elimination

> **Theorem 6.1 (`disjunctive_syllogism_fails`).** The premise set
> `{ p, ¬p ∨ q }` does **not** entail `q`, where `p = atom 0`, `q = atom 1`. Formally,
> `¬ entails {atom 0, disj (neg (atom 0)) (atom 1)} (atom 1)`.
>
> *Proof.* Consider the glut valuation `v` with `v 0 = bb` and `v 1 = ff` (all other
> atoms arbitrary). We check `v` is a model of the premise set:
> - `eval v p = bb`, designated;
> - `eval v (¬p ∨ q) = max(neg bb, ff) = max(bb, ff) = bb`, designated.
>
> Yet `eval v q = ff` is **not** designated, so `¬ Holds v q`. Thus `v` is a
> countermodel and DS is invalid. The finite check is by decision over the value
> tables. ∎

> **Corollary 6.2 (`mp_fails`).** Modus ponens fails: `{ p, p ⊃ q } ⊬ q`, since
> `p ⊃ q := disj (neg p) q` is the same formula as the DS minor premise.

**The dividing line.** Compare §5 and §6. The introductions needed only that
designation is closed under `min`/`max` (Lemmas 3.1–3.2). The elimination needs more:
that knowing `neg p` is designated *rules out* `p` being designated — a disjointness
between a value and its negation. For the glut `bb`, `neg bb = bb` is itself
designated, so this disjointness fails *at a single value*. That one value, `bb`,
simultaneously (i) keeps excluded middle/non-contradiction valid and (ii) destroys
DS/MP. The dichotomy is therefore not a coincidence but a value-level theorem.

---

## 7. Recapture: the non-monotone `LPm` recovers modus ponens

The cautious relation `entails` permanently forfeits MP. The minimal-glut refinement
`entailsMin` (Definition 2.8) recovers it exactly where prudence permits — on
*consistent* premises.

> **Theorem 7.1 (`entailsMin_recovers_mp`).** On the consistent premises
> `{ p, p ⊃ q }` (with `p = atom 0`, `q = atom 1`),
> `entailsMin {atom 0, imp (atom 0) (atom 1)} (atom 1)` holds.
>
> *Proof sketch.* Let `v` be a *minimal* model of `Γ = {p, p ⊃ q}`. We show every
> minimal model is glut-free, whence classical, whence MP applies.
>
> 1. The constant valuation `c := λ_. tt` is a model of `Γ` (everything is plainly
>    true) with `GlutSet c = ∅`.
> 2. If `v` had a nonempty glut set, then `GlutSet c = ∅ ⊊ GlutSet v`, contradicting
>    minimality of `v` (a model `c` with strictly smaller glut set exists). Hence
>    `GlutSet v = ∅`, i.e. `v n ≠ bb` for all `n`: `v` is **classical**.
> 3. On a classical (two-valued) valuation the glut pathology disappears: `neg` is the
>    Boolean complement and designation coincides with classical truth. Since
>    `Holds v p` and `Holds v (p ⊃ q) = Holds v (¬p ∨ q)`, and `p` is true, the
>    disjunct `¬p` is false, forcing `q` true. Hence `Holds v q`. ∎

> **Theorem 7.2 (`retraction_nonmonotone`, companion).** `entailsMin` is **not**
> monotone: there exist `Γ ⊆ Δ` and `A` with `entailsMin Γ A` but
> `¬ entailsMin Δ A`.
>
> *Discussion.* Adding a premise can *force* a glut that the previous minimal models
> avoided, shifting the set of minimal models and thereby retracting a conclusion.
> Thus `LPm` trades the structural rule of monotonicity (Theorem 4.2) for the
> recapture power of Theorem 7.1. Neither `LP` nor `LPm` dominates: `LP` keeps all
> structure; `LPm` keeps more classical conclusions. The trade isolates *monotonicity*
> as the exact structural cost of classical recapture.

---

## 8. Priest's validity characterization

We finally relate `LP`-validity to classical validity (Definition 2.9). One inclusion
is immediate; the converse is the substantive theorem.

> **Theorem 8.1 (`LPvalid_imp_classicallyValid`, easy direction).** If `LPvalid A`
> then `ClassicallyValid A`.
>
> *Proof.* Classical valuations are a subset of all valuations (those avoiding `bb`),
> so universal holding over all valuations implies holding over the classical ones. ∎

The converse requires care. The natural strategy — "squeeze" a glut valuation between
two classical collapses and conclude — fails, because negation is **antitone**: a
collapse that pushes `bb ↦ tt` raises `eval` on positive subformulas but, after a
negation, the inequality flips, so a single monotone squeeze cannot survive a `neg`.
The repair is *asymmetric*.

> **Definition 8.2 (Classical collapse).** For a valuation `v`, let `v⁺` be the
> classical valuation obtained by `bb ↦ tt` (and fixing `ff`, `tt`); concretely
> `v⁺ n = tt` if `v n ∈ {bb, tt}` and `v⁺ n = ff` if `v n = ff`.

> **Lemma 8.3 (Collapsing Lemma, `collapse_preserve`).** For every formula `A` and
> valuation `v`: if `eval v⁺ A = tt` then `(eval v A).desig`, and if `eval v⁺ A = ff`
> then `eval v A = ff`. Equivalently, the single collapse `v⁺` preserves *both*
> classical outputs of `eval` simultaneously.
>
> *Proof sketch.* Structural induction on `A`.
> - **Atom.** By construction of `v⁺`: if `v⁺ n = tt` then `v n ∈ {bb, tt}`
>   (designated); if `v⁺ n = ff` then `v n = ff`.
> - **Negation `neg A`.** The two-sided statement is exactly what makes this case go
>   through: `eval v⁺ (neg A) = tt` means `eval v⁺ A = ff`, so by the *second* half of
>   the induction hypothesis `eval v A = ff`, hence `eval v (neg A) = neg ff = tt`,
>   designated; symmetrically for the `ff` case using the *first* half. (A one-sided
>   squeeze would have only one half available and would stall here — the technical
>   heart of why the asymmetric two-sided formulation is necessary.)
> - **Conjunction / disjunction.** `min`/`max` are monotone and the two-sided
>   hypothesis on each subformula supplies exactly the needed bounds; e.g. for
>   `conj`, `eval v⁺ (conj A B) = tt` forces both subformulas to `tt` under `v⁺`, hence
>   both designated under `v` by IH, hence designated meet by Lemma 3.1. ∎

> **Theorem 8.4 (`lp_validity_eq_classical` — Priest's characterization).** For every
> formula `A`: `LPvalid A ↔ ClassicallyValid A`.
>
> *Proof.* (⇒) Theorem 8.1. (⇐) Suppose `A` is classically valid and let `v` be any
> valuation. Then `v⁺` is classical, so `Holds v⁺ A`, i.e. `(eval v⁺ A).desig`, so
> `eval v⁺ A ∈ {bb, tt}`. But `v⁺` is classical, hence `eval v⁺ A ∈ {ff, tt}`
> (no classical valuation produces `bb`), forcing `eval v⁺ A = tt`. By the first half
> of Lemma 8.3, `(eval v A).desig`, i.e. `Holds v A`. As `v` was arbitrary,
> `LPvalid A`. ∎

> **Corollary 8.5 (Conservativity).** `LP` proves *exactly* the classical
> tautologies. Gluts **subtract inferences** (DS, MP fail) but **add no theorems**
> (the valid-formula sets coincide).

---

## 9. Algorithms

The semantics is finite and decidable, which makes every claim above computationally
checkable. We record the key procedures.

### 9.1 Brute-force validity / consequence checking

Because a formula mentions finitely many atoms and `LPval` has three elements, both
`LPvalid` and `entails` over a finite premise set are decidable by enumerating
`3^k` valuations over the `k` occurring atoms.

```
function IS_LP_VALID(A):
    atoms ← occurring atoms of A
    for each assignment ρ : atoms → {ff, bb, tt}:
        if not DESIG(EVAL(ρ, A)):
            return (False, ρ)          # ρ is a countermodel
    return (True, none)

function ENTAILS(Γ, A):
    atoms ← occurring atoms of (Γ ∪ {A})
    for each assignment ρ : atoms → {ff, bb, tt}:
        if (for all B in Γ: DESIG(EVAL(ρ, B))) and not DESIG(EVAL(ρ, A)):
            return (False, ρ)          # ρ witnesses non-entailment
    return (True, none)
```

Complexity: `Θ(3^k · |A|)` for validity, `Θ(3^k · (|A| + Σ|B|))` for consequence,
where `k` is the number of distinct atoms. This is the engine that certifies
`disjunctive_syllogism_fails` (it returns the countermodel `0 ↦ bb, 1 ↦ ff`).

### 9.2 Minimal-glut consequence (`LPm`)

`entailsMin` filters the models of `Γ` to those whose glut set is `⊆`-minimal, then
checks `A`.

```
function ENTAILS_MIN(Γ, A):
    atoms ← occurring atoms of (Γ ∪ {A})
    models ← [ ρ : atoms → {ff,bb,tt} | for all B in Γ: DESIG(EVAL(ρ, B)) ]
    minimal ← [ ρ in models | no σ in models with GLUTSET(σ) ⊊ GLUTSET(ρ) ]
    for ρ in minimal:
        if not DESIG(EVAL(ρ, A)):
            return (False, ρ)
    return (True, none)
```

Complexity: model collection `Θ(3^k · ΣΓ)`, minimality filtering `Θ(|models|²·k)`.
This certifies `entailsMin_recovers_mp` (every minimal model of `{p, p⊃q}` is the
glut-free `0↦tt, 1↦tt`, which holds `q`) and exhibits `retraction_nonmonotone`.

### 9.3 The classical collapse

The constructive content of Theorem 8.4 is the map `v ↦ v⁺`.

```
function COLLAPSE_PLUS(ρ):
    return λ n. (tt if ρ(n) ∈ {bb, tt} else ff)
```

Lemma 8.3 is the assertion that `EVAL(COLLAPSE_PLUS(ρ), A)`'s classical value
controls `EVAL(ρ, A)`'s designation, the algorithmic core of conservativity.

---

## 10. Applications

- **Inconsistency-tolerant knowledge bases.** A database told both `A` and `¬A`
  should not derive every fact. `LP`-consequence localizes the contradiction (DS
  fails) while preserving the closure structure needed for query answering (Cut).
- **Belief revision and defaults.** `LPm`'s recapture (Theorem 7.1) models the
  intuition "reason classically until forced otherwise," with the non-monotonicity
  (Theorem 7.2) capturing genuine retraction under new, conflicting information.
- **Conservativity guarantees.** Corollary 8.5 certifies that swapping a classical
  reasoner for an `LP` reasoner never introduces *new* universal theorems — only
  refuses certain dangerous eliminations — a safety property for systems that must
  tolerate dirty data without changing their valid-formula footprint.

---

## 11. Discussion

The results assemble into a single conceptual picture. Reasoning has two layers: a
*structural* layer (how premises and conclusions are bookkept) and a *connective*
layer (what `∧`, `∨`, `¬` mean). Paraconsistency is a phenomenon of the connective
layer — specifically, of negation's fixed point `neg bb = bb` — and is therefore
*invisible* to the structural layer. This is why the Tarskian package (reflexivity,
monotonicity, Cut) survives verbatim. Within the connective layer, a finer split
appears: *introduction* rules need only monotonicity of designation under `min`/`max`
and survive, while *elimination* rules need a value/negation disjointness that the
glut destroys and so perish. The whole dichotomy is forced by the behavior of one
truth value.

The `LP`/`LPm` pair then exhibits a precise trade-off. `LP` is maximally
well-behaved structurally but weak on classical conclusions; `LPm` recaptures
classical strength on consistent theories but spends monotonicity to do so. The
recapture theorem and the non-monotonicity theorem together *locate* monotonicity as
the exact currency of the trade. Finally, the validity characterization shows the
price of paraconsistency is paid *entirely* in inferences and *not at all* in
theorems: the valid-formula sets of `LP` and classical logic are identical.

---

## 12. Future work

The companion future-directions note (reproduced in the package metadata) lays out
five concrete programs: (1) sharpening the validity characterization into a reusable
bridge lemma; (2) determining whether Cut fails for `LPm`, which would complete the
structural dichotomy by pinpointing the structural rule distinguishing monotone `LP`
from non-monotone `LPm`; (3) realizing the space of `LP`-models satisfying a theory as
a *pre-topological dream space*, with contradiction corresponding to failure of the
union axiom; (4) quantifying the exact "recapture zone" of `LPm` as the consistent
theories on which it collapses to classical consequence; and (5) building a sound (and
ideally complete) sequent/Hilbert calculus whose structural rules are exactly
reflexivity + weakening + Cut and whose connective rules are the surviving
introductions, double negation, LEM and LNC — but no DS/MP.

---

## Appendix A. Glossary of formal names

| Name | Statement |
|---|---|
| `desig_conj` | `min` of two designated values is designated |
| `desig_disj_left` | `max` of a designated value with anything is designated |
| `entails_refl` | `A ∈ Γ ⟹ entails Γ A` |
| `entails_monotone` | `Γ ⊆ Δ ⟹ entails Γ A ⟹ entails Δ A` |
| `entails_cut` | `entails Γ A ⟹ entails (insert A Γ) B ⟹ entails Γ B` |
| `entails_and_intro` | `entails Γ A ⟹ entails Γ B ⟹ entails Γ (conj A B)` |
| `entails_or_intro_left` | `entails Γ A ⟹ entails Γ (disj A B)` |
| `disjunctive_syllogism_fails` | `¬ entails {p, ¬p ∨ q} q` |
| `mp_fails` | `¬ entails {p, p ⊃ q} q` |
| `entailsMin_recovers_mp` | `entailsMin {p, p ⊃ q} q` |
| `retraction_nonmonotone` | `entailsMin` is not monotone |
| `LPvalid_imp_classicallyValid` | `LPvalid A ⟹ ClassicallyValid A` |
| `collapse_preserve` | the asymmetric Collapsing Lemma (8.3) |
| `lp_validity_eq_classical` | `LPvalid A ↔ ClassicallyValid A` |
