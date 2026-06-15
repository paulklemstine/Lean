# Dream Logic III: A First-Principles Structural Core of Paraconsistent Consequence

## Abstract

We present a self-contained, first-principles reconstruction of the *Logic of Paradox*
(LP, Priest's three-valued paraconsistent logic) together with a fresh layer of
*structural* meta-theory. From a three-line semantic kernel — three truth values
(`tt`, `bb`, `ff`), the De Morgan operations `min`/`max`/antitone-involution, and a
designation predicate marking the "at least partly true" values — we establish two
sharply separated families of results. The first is *structural* and entirely
orthogonal to the three-valued character of the logic: a homomorphism lemma showing
evaluation commutes with substitution (`eval_subst`), from which uniform-substitution
closure (`lpvalid_subst_closed`) and the Tarskian idempotence of the consequence
operator (`Cn_idempotent`) follow with no truth-value case analysis whatsoever; and a
conservativity result (`entails_imp_entailsMin`) placing LP inside its non-monotone
glut-minimal refinement LPm. The second family is genuinely *paraconsistent* and turns
on a single fact, the *glut fixpoint* (`eval_allbb`): the constant valuation `n ↦ bb`
evaluates every formula to `bb` and hence satisfies *every* formula (`absolute_glut_models_all`).
This single terminal model yields the joint satisfiability of every contradiction
(`contradiction_satisfiable`), the failure of explosion (`explosion_fails`), and — in
clean counterpoint — the validity of both Excluded Middle and Non-Contradiction
(`lem_valid`, `lnc_valid`). The headline conceptual contribution is the identification
of the absolute glut as simultaneously (i) the source of paraconsistency and (ii) the
exact model excised by minimal-model semantics during classical recapture: glut-fixpoint
and recapture are two sides of one coin. All results are formalized; this paper gives
their statements and proof sketches.

**Keywords:** paraconsistent logic, Logic of Paradox, three-valued semantics, glut,
uniform substitution, Tarskian closure operator, non-monotonic recapture, structurality.

---

## 1. Introduction

Classical logic is *explosive*: from a contradiction, every formula follows
(*ex contradictione quodlibet*). For any reasoning system that must operate over
inconsistent information — conflicting sensor data, clashing legal statutes,
overlapping knowledge bases — explosion is a fatal fragility, since a single local
inconsistency renders the entire theory trivial.

Priest's *Logic of Paradox* (LP) is the canonical *paraconsistent* response: it
augments the classical two-valued semantics with a third value representing
statements that are *both true and false*, and thereby blocks explosion while
retaining a remarkable amount of classical structure. The present work — "Dream Logic
III" — is a companion to a prior meta-level development ("Dream Logic II") that
established the dichotomy *structural rules survive paraconsistency; connective
elimination rules die*. Where that work analyzed individual inference rules, the
present development rebuilds LP from a minimal semantic kernel in order to isolate the
*structural skeleton* of the logic and to demonstrate, by the very form of the proofs,
that this skeleton is orthogonal to the three-valued connective table.

Our central methodological claim is empirical and is borne out by the proofs:

> The structural identity of LP as a *logic* (closure under substitution, the Tarski
> closure operator, conservativity of glut-minimisation) can be erected without any
> connective-level case analysis. Only the *paraconsistent* theorems touch the
> three-value table — and they all reduce to one fact about a single valuation.

Section 2 fixes the semantic kernel. Section 3 develops the structural layer.
Section 4 develops the paraconsistent layer around the glut fixpoint. Section 5
treats validity-versus-triviality. Section 6 discusses recapture and the closure
operator. Section 7 discusses consequences, applications, and limitations. Section 8
lists future directions.

---

## 2. The semantic kernel

### 2.1 Truth values

**Definition 2.1 (Truth values).** The set of LP truth values is

```
LPval = { tt, bb, ff }
```

read as *true only* (`tt`), *both true and false* — the *glut* (`bb`), and *false
only* (`ff`). We order them in the *truth order*

```
ff < bb < tt.
```

**Definition 2.2 (Connectives on values).** Negation is the antitone involution that
flips the truth order and *fixes the glut*:

```
neg(tt) = ff,   neg(bb) = bb,   neg(ff) = tt.
```

Conjunction is the meet (minimum) and disjunction the join (maximum) in the truth
order:

```
conj(a,b) = min(a,b)      (ff is absorbing; bb dominates tt)
disj(a,b) = max(a,b)      (tt is absorbing; bb dominates ff)
```

Explicitly, `conj` returns `ff` if either argument is `ff`, else `bb` if either is
`bb`, else `tt`; dually `disj` returns `tt` if either argument is `tt`, else `bb` if
either is `bb`, else `ff`. These make `(LPval, conj, disj, neg)` a De Morgan lattice.

**Definition 2.3 (Designation).** A value is *designated* — counts as asserted — iff
it is at least partly true:

```
desig(tt) = True,   desig(bb) = True,   desig(ff) = False.
```

The crucial structural feature, isolated in Dream Logic II, is that designation is
closed under `min` and `max` of designated values but that *no value is disjoint from
its negation*: `bb` and `neg(bb) = bb` are both designated. The first fact powers the
surviving monotone introduction rules; the second is what defeats the eliminative
rules and explosion.

### 2.2 Syntax

**Definition 2.4 (Formulas).** Formulas over countably many atoms (indexed by `ℕ`)
are generated by

```
Form ::= atom n | neg A | conj A B | disj A B          (n : ℕ)
```

Material implication is the defined abbreviation `imp A B := disj (neg A) B`.

### 2.3 Semantics

**Definition 2.5 (Valuation and evaluation).** A *valuation* is a function
`v : ℕ → LPval` assigning a value to each atom. Evaluation `eval v : Form → LPval`
is the unique homomorphic extension:

```
eval v (atom n)    = v n
eval v (neg A)     = neg (eval v A)
eval v (conj A B)  = conj (eval v A) (eval v B)
eval v (disj A B)  = disj (eval v A) (eval v B)
```

**Definition 2.6 (Holding, consequence, validity).**

```
Holds v A      :≡  desig (eval v A)
entails Γ A    :≡  ∀ v, (∀ B ∈ Γ, Holds v B) → Holds v A
LPvalid A      :≡  ∀ v, Holds v A
```

`Holds v A` says `A` is *accepted* under `v`; `entails Γ A` is LP-consequence
(designation is preserved from all premises to the conclusion across every
valuation); `LPvalid A` is validity.

---

## 3. The structural layer (orthogonal to paraconsistency)

The results in this section never inspect a truth value. They would hold verbatim for
any value algebra and any designated subset; this is precisely the point.

### 3.1 Substitution

**Definition 3.1 (Uniform substitution).** For `σ : ℕ → Form`, define `subst σ : Form → Form` by

```
subst σ (atom n)    = σ n
subst σ (neg A)     = neg (subst σ A)
subst σ (conj A B)  = conj (subst σ A) (subst σ B)
subst σ (disj A B)  = disj (subst σ A) (subst σ B)
```

**Theorem 3.2 (Substitution lemma — `eval_subst`).** For every valuation `v`,
substitution `σ`, and formula `A`,

```
eval v (subst σ A) = eval (fun n ↦ eval v (σ n)) A.
```

*Proof sketch.* Structural induction on `A`. The atomic case is `eval v (σ n) =
(fun n ↦ eval v (σ n)) n`, true by definition. Each connective case rewrites the
outer connective through `eval` and `subst` and applies the induction hypotheses to
the immediate subformulas. No truth value is examined; the proof is a single chain of
definitional unfoldings plus the inductive hypotheses. ∎

The content of Theorem 3.2 is that `eval` is a *homomorphism* with respect to
substitution: evaluating a substituted formula equals evaluating the original under
the *pre-evaluated* valuation `n ↦ eval v (σ n)`. This is the algebraic engine of the
entire structural layer.

### 3.2 Structurality

**Theorem 3.3 (Structurality — `lpvalid_subst_closed`).** If `LPvalid A` then for
every substitution `σ`, `LPvalid (subst σ A)`.

*Proof sketch.* Fix `v`. Unfolding `Holds`, the goal is `desig (eval v (subst σ A))`.
By Theorem 3.2 this equals `desig (eval (fun n ↦ eval v (σ n)) A)`, which is exactly
`Holds w A` for the valuation `w := fun n ↦ eval v (σ n)`. Since `A` is valid it holds
under *every* valuation, in particular under `w`. ∎

Closure under uniform substitution is the Tarski–Łoś defining property of *being a
logic*: validity must be a purely *formal* (schematic) notion. Theorem 3.3 certifies
that LP is a genuine logic, and its proof exhibits this as a structural fact divorced
from the three-valued semantics.

### 3.3 The closure operator

Define the *consequence operator* `Cn Γ := { A | entails Γ A }`. Two elementary
structural rules — proved in the companion development by quantifier manipulation —
underlie its closure-operator status:

- **Reflexivity:** `A ∈ Γ ⟹ entails Γ A`.
- **Monotonicity:** `Γ ⊆ Δ ⟹ entails Γ A ⟹ entails Δ A`.

**Theorem 3.4 (Idempotence — `Cn_idempotent`).** `Cn (Cn Γ) = Cn Γ`.

*Proof sketch.* The inclusion `Cn Γ ⊆ Cn (Cn Γ)` is reflexivity together with
monotonicity: every member of `Cn Γ` is trivially entailed by the larger premise set
`Cn Γ`. For the reverse `Cn (Cn Γ) ⊆ Cn Γ`, suppose `entails (Cn Γ) A` and let `v`
designate all of `Γ`. Then `v` designates every member of `Cn Γ` (because each such
member is entailed by `Γ` and `v` is a model of `Γ`), so the hypothesis gives
`Holds v A`. Hence `entails Γ A`. ∎

Idempotence packages reflexivity and monotonicity into the single Tarskian law
`Cn ∘ Cn = Cn`: once the deductive closure is taken, taking it again yields nothing
new. Together with Cut (established in Dream Logic II) this exhibits `entails` as a
bona fide Tarskian closure operator.

---

## 4. The paraconsistent layer: the absolute glut

Every theorem in this section traces back to one fact about the constant valuation
`g := fun _ ↦ bb`.

### 4.1 The glut fixpoint

**Theorem 4.1 (Glut fixpoint — `eval_allbb`).** For every formula `A`,
`eval (fun _ ↦ bb) A = bb`.

*Proof sketch.* Structural induction on `A`, using that `bb` is a *simultaneous
fixpoint* of all connectives: `neg bb = bb`, `conj bb bb = bb`, `disj bb bb = bb`. The
atomic case is immediate; each connective case rewrites by the induction hypotheses to
reduce to one of these three fixpoint equations. ∎

### 4.2 A model of everything

**Theorem 4.2 (Absolute glut models all — `absolute_glut_models_all`).** For every
formula `A`, `Holds (fun _ ↦ bb) A`.

*Proof sketch.* By Theorem 4.1, `eval g A = bb`, and `desig bb = True`. ∎

This is impossible in classical logic, where no single model can satisfy a formula and
its negation, let alone *all* formulas. In LP a single, maximally simple valuation is
a *terminal model* for satisfaction.

**Theorem 4.3 (Contradictions are satisfiable — `contradiction_satisfiable`).** For
every formula `A`, the set `{A, neg A}` is jointly satisfiable: there is a valuation
designating both `A` and `neg A`.

*Proof sketch.* The absolute glut works: by Theorem 4.2 it designates `A` and it
designates `neg A` (indeed `eval g (neg A) = neg bb = bb`, designated). ∎

This is paraconsistency in its purest model-theoretic form: the premise that detonates
classical logic is, in LP, simultaneously satisfiable for *every* `A`.

### 4.3 Explosion fails

**Theorem 4.4 (Ex contradictione non quodlibet — `explosion_fails`).** With `p := atom 0`
and `q := atom 1`, `¬ entails {p, neg p} q`. Equivalently, there is a valuation
designating `p` and `neg p` but not `q`.

*Proof sketch.* Use the *surgical* valuation `v` with `v 0 = bb` and `v 1 = ff`
(the absolute glut also works but is less informative). Then `eval v p = bb` and
`eval v (neg p) = neg bb = bb`, both designated, so all premises hold; but
`eval v q = ff`, not designated, so the conclusion fails. Hence `q` is not an
LP-consequence of `{p, neg p}`. ∎

Notably, only the joint satisfiability (Theorem 4.3 / 4.2) is *needed* for
non-triviality, but the explicit counter-model makes the failure of the *inference*
fully concrete; it requires the `DecidablePred desig` instance to evaluate the
concrete valuation.

---

## 5. Validity is not triviality

The deepest conceptual point of LP is that it cleanly separates *validity* (designated
in every model) from *unsatisfiability of the negation* (refuted in some model) —
notions that classical logic identifies.

**Theorem 5.1 (Excluded middle is valid — `lem_valid`).** `LPvalid (disj A (neg A))`
for every `A`.

*Proof sketch.* Fix `v` and let `a := eval v A`. We need `desig (disj a (neg a))`. Case
on `a`: if `a = tt`, `disj tt ff = tt`; if `a = ff`, `disj ff tt = tt`; if `a = bb`,
`disj bb bb = bb`. All three are designated. ∎

**Theorem 5.2 (Non-contradiction is valid — `lnc_valid`).** `LPvalid (neg (conj A (neg A)))`
for every `A`.

*Proof sketch.* With `a := eval v A`, evaluate `neg (conj a (neg a))`. If `a = tt`:
`neg (conj tt ff) = neg ff = tt`. If `a = ff`: `neg (conj ff tt) = neg ff = tt`. If
`a = bb`: `neg (conj bb bb) = neg bb = bb`. All designated. ∎

**Remark 5.3 (The apparent paradox, resolved).** Theorem 4.3 says every contradiction
`{A, neg A}` is *satisfiable*, while Theorem 5.2 says `neg (conj A (neg A))` is
*valid*. These coexist because in the glut world the law of non-contradiction
evaluates to `bb` — it is designated (so *valid*: never strictly false-only) but also
partly false (so its negation, the contradiction, is *also* designated, hence
satisfiable). Classical logic collapses "valid" and "negation unsatisfiable" into one
notion; LP keeps them apart. *The glut adds no refutations of the classical laws even
as it satisfies contradictions.* This is the hallmark separation of validity from
triviality.

---

## 6. Recapture and conservativity

LP discards some intuitively desirable classical inferences (e.g. disjunctive
syllogism / modus ponens fail on the glut). A standard remedy is *minimal-model*
(glut-minimising) semantics, which restricts attention to the models of the premises
that contain *as few gluts as possible*, deliberately excluding paranoid worlds such
as the absolute glut whenever a more consistent model exists. Write `entailsMin` (LPm)
for the resulting non-monotone consequence relation.

**Theorem 6.1 (Conservative recapture — `entails_imp_entailsMin`).** Every
LP-consequence is an LPm-consequence: `entails Γ A ⟹ entailsMin Γ A`.

*Proof sketch.* Minimal models of `Γ` form a *subset* of all models of `Γ`. An LP-valid
inference holds across *all* models of `Γ`, hence in particular across the minimal
ones. Thus restricting to minimal models can only *add* conclusions, never remove one;
LP ⊆ LPm. ∎

**Insight (the two-sided coin).** The absolute glut of Section 4 is *exactly* the model
that minimal-model semantics excises during recapture: it is the source of
paraconsistency (it satisfies every contradiction) and simultaneously the obstacle
that LPm removes to recover classical-strength inference on consistent premise sets.
Glut-fixpoint (`eval_allbb`) and recapture (`entails_imp_entailsMin`) are two faces of
the same phenomenon. The dial between "maximally safe" and "classically sharp" is
precisely *how much weight one gives the glut*.

---

## 7. Discussion, applications, and limitations

**Methodological payoff.** The proofs make the structure/paraconsistency split
*visible in their form*. `eval_subst` is a single structural induction; `lpvalid_subst_closed`,
`Cn_idempotent`, and `entails_imp_entailsMin` are pure quantifier/set manipulations
with zero truth-value case analysis. Only `eval_allbb`, `absolute_glut_models_all`,
`lem_valid`, and `lnc_valid` touch the 3×3 connective tables — and the first two reduce
to three fixpoint equations about a single value. This confirms the working hypothesis:
the structural skeleton of LP is orthogonal to its paraconsistency.

**A formalization note.** Designation is defined as a `Prop`-valued match
(`desig : LPval → Prop`) rather than a `Bool`, which keeps `Holds` propositional and the
structural proofs free of decidability obligations. The price is an explicit
`DecidablePred desig` instance, needed only to evaluate the concrete counter-model in
`explosion_fails`. An early attempt to prove `contradiction_satisfiable` by
`simp ; decide` stalled precisely because `desig` is propositional; exposing
`eval g (neg A) = bb` via the fixpoint lemma and discharging designation directly is
the clean route.

**Applications.** Paraconsistent consequence relations underpin robust reasoning over
inconsistent data: knowledge bases that merge conflicting sources, belief-revision and
database systems that must continue functioning in the presence of contradictions,
formal models of legal and normative reasoning where statutes conflict, and
inconsistency-tolerant components of automated reasoners. The structural results matter
here too: closure under substitution guarantees that inference *schemas* are sound
regardless of instantiation, and the closure-operator view licenses caching of
deductive closures (idempotence: recomputing the closure is wasted work). Conservative
recapture provides a principled "best of both worlds" deployment: reason in LPm for
strength, fall back to LP's guarantees for safety.

**Limitations.** (i) The logic is propositional; quantifiers and a proof theory
(sequent calculus / natural deduction) are not treated here. (ii) Only the monotone
relation `entails` is fully developed in this core; the non-monotone `entailsMin` is
used at the interface (Theorem 6.1) but its independent meta-theory is the subject of
the companion work. (iii) The connective set is `{neg, conj, disj}` with material
implication defined; LP's well-known lack of a *detachable* conditional is inherited
and not repaired here.

---

## 8. Future directions

A categorical reading of the absolute glut is the most promising next step:
conjecturally, in the preorder of valuations ordered by the pointwise truth order with
satisfaction as morphisms, the constant-`bb` valuation is a *terminal object* for the
satisfaction relation (every formula's "designation cone" factors through it) and dually
the all-`ff` valuation is initial for refutation. Under this reading `eval_allbb` is the
object-level shadow of a terminal object, and the entire collapse/recapture machinery
should be re-derivable as the unique mediating map into that terminal object. Further
directions include: extending the structural core to first-order LP and verifying that
`eval_subst` lifts to substitution under binders; a proof-theoretic counterpart of the
closure operator; a quantitative theory of "glut budget" interpolating between LP and
classical logic via the recapture dial; and machine-checked integration with
inconsistency-tolerant knowledge-base reasoning.

---

## Appendix A. Index of results

| Name | Statement | Role |
|---|---|---|
| `eval_subst` | `eval v (subst σ A) = eval (n ↦ eval v (σ n)) A` | structural engine |
| `lpvalid_subst_closed` | validity is substitution-closed | LP is a genuine logic |
| `eval_allbb` | constant-`bb` evaluates everything to `bb` | glut fixpoint |
| `absolute_glut_models_all` | one valuation models all formulas | non-triviality / terminal model |
| `contradiction_satisfiable` | every `{A, neg A}` is satisfiable | paraconsistency |
| `explosion_fails` | `{p, neg p} ⊭ q` | ex contradictione non quodlibet |
| `lem_valid` | `⊨ A ∨ ¬A` | validity ≠ triviality |
| `lnc_valid` | `⊨ ¬(A ∧ ¬A)` | validity ≠ triviality |
| `entails_imp_entailsMin` | `LP ⊆ LPm` | conservative recapture |
| `Cn_idempotent` | `Cn (Cn Γ) = Cn Γ` | Tarskian closure operator |
