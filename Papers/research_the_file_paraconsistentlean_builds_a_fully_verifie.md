# A Verified Semantics for the Logic of Paradox and its Minimally-Inconsistent Strengthening, with a Tropical-Semiring Bridge

## Abstract

We present a complete, formally verified model theory for Priest's three-valued **Logic of Paradox** (`LP`) and its minimally-inconsistent refinement (`LPm`). The semantics is built on the three truth values `ff` (false only), `bb` (both true and false — a *glut*), and `tt` (true only), ordered as a chain `ff < bb < tt`, with designated set `{bb, tt}`. We establish the characteristic paraconsistent profile of `LP`: contradictions are *satisfiable* and do not *explode*, the Laws of Excluded Middle and Non-Contradiction survive as *validities* even though the *inferences* of explosion and material modus ponens fail, and glut-free valuations collapse exactly to classical two-valued reasoning. We then define the minimally-inconsistent consequence relation `entailsMin` by restricting attention to models whose glut sets are `⊂`-minimal, and prove that it is genuinely **non-monotone**: a conclusion `q` that is a minimal consequence of `{p, p→q}` is *retracted* when the contradictory premise `¬p` is added. Finally, we identify a cross-domain bridge: under `disj = max` and `conj = min`, the value set `(LP, disj, conj)` is a commutative idempotent semiring with additive identity `ff` and multiplicative identity `tt`, and the designated set `{bb, tt}` is a prime filter for both operations. This exhibits the `LP` truth tables as a genuine two-spaced tropical / min-plus structure and opens a translation between paraconsistent satisfiability and min-plus solvability. Every result is stated with its full mathematical content and a proof sketch; the formalization uses only the axioms `propext`, `Classical.choice`, and `Quot.sound`.

**Keywords.** paraconsistent logic, Logic of Paradox, dialetheism, many-valued logic, non-monotonic reasoning, belief revision, tropical semiring, idempotent algebra, prime filter, formal verification.

---

## 1. Introduction

Classical logic validates *ex contradictione quodlibet* (ECQ): from `A` and `¬A`, every formula `B` follows. ECQ makes classical reasoning *explosive* — a single inconsistency trivializes the entire theory, since everything becomes derivable. For information systems that must reason from conflicting sensor data, inconsistent legal codes, or merged knowledge bases, explosiveness is fatal: an inconsistent theory loses all discriminating power.

**Paraconsistent logics** reject ECQ as an inference while retaining as much classical structure as possible. Among the most studied is Graham Priest's **Logic of Paradox** (`LP`, 1979), a three-valued logic whose third value records that a statement may be *both* true and false. `LP` is the canonical *dialetheic* semantics: it takes seriously the possibility of true contradictions (dialetheia) without trivialization.

`LP` has a well-known weakness: by refusing explosion it also refuses too much, including disjunctive syllogism and material modus ponens, leaving the consequence relation too weak for practical inference. Priest's response, `LPm` (minimally-inconsistent `LP`), recovers classical strength wherever consistency permits, by quantifying only over models that carry a `⊂`-minimal set of gluts. The price — and, we argue, the prize — is **non-monotonicity**: conclusions can be withdrawn when new premises force previously avoidable inconsistencies into the open.

This paper contributes a from-scratch, machine-checked model theory for both `LP` and `LPm`, together with a previously underexploited observation: the `LP` connectives, read as `min`/`max` on the value chain, form a tropical (idempotent) semiring, providing an algebraic bridge between paraconsistent reasoning and min-plus mathematics. All statements below are theorems we have formally verified.

---

## 2. The three-valued algebra of truth

### 2.1 Truth values, order, and designation

**Definition 2.1 (Truth values).** The value set is the three-element type
```
LP = { ff, bb, tt },
```
ordered as the chain `ff < bb < tt`. Intuitively `ff` = *false only*, `tt` = *true only*, and `bb` = *both true and false* (a **glut**).

**Definition 2.2 (Designation).** A value is **designated** (assertible, "true enough") iff it is not `ff`:
```
desig(ff) = False,   desig(bb) = True,   desig(tt) = True.
```
Thus the designated set is `D = {bb, tt}`. Crucially, the glut `bb` is designated: a both-true-and-false statement is still assertible, because it is (in part) true.

**Lemma 2.3 (Designation characterization).** For every `x`, `desig(x) ↔ x ≠ ff`.
*Proof.* Immediate three-case check. ∎

### 2.2 Connectives

**Definition 2.4 (Negation).**
```
neg(ff) = tt,   neg(bb) = bb,   neg(tt) = ff.
```
Negation swaps the endpoints and **fixes the glut**: the negation of an impossible object is again impossible. This is the structural heart of `LP` — gluts are stable under denial.

**Definition 2.5 (Conjunction = min).** `conj(x, y)` is the `min` of `x, y` on the chain `ff < bb < tt`:
```
conj    | ff bb tt
   ff   | ff ff ff
   bb   | ff bb bb
   tt   | ff bb tt
```

**Definition 2.6 (Disjunction = max).** `disj(x, y)` is the `max` of `x, y`:
```
disj    | ff bb tt
   ff   | ff bb tt
   bb   | bb bb tt
   tt   | tt tt tt
```

**Definition 2.7 (Material implication).** As usual in `LP`, `impl(p, q) := disj(neg(p), q)`.

### 2.3 Key value-level facts

These finite truth-table facts drive every subsequent theorem.

**Lemma 2.8 (`ff` is the disjunctive bottom).** `disj(ff, x) = x` for all `x`. *(Proof: case analysis.)* This says `ff` is the additive identity / `max`-zero.

**Lemma 2.9 (Gluts are the only self-contradictory designated values).** If `desig(x)` and `desig(neg(x))`, then `x = bb`.
*Proof.* Check the three cases: `ff` is not designated; `tt` has `neg(tt) = ff` undesignated; only `bb` has both `bb` and `neg(bb) = bb` designated. ∎
This is the algebraic engine behind the failure of modus ponens and the forced gluts of `LPm`.

**Lemma 2.10 (Non-glut designated values are `tt`).** If `x ≠ bb` and `desig(x)`, then `x = tt`. *(Proof: case analysis.)* This drives the classical collapse.

---

## 3. Syntax and evaluation

**Definition 3.1 (Formulas).** Propositional formulas over `ℕ`-indexed atoms:
```
Form ::= atom n | neg p | conj p q | disj p q          (n : ℕ;  p, q : Form)
impl p q := disj (neg p) q.
```

**Definition 3.2 (Valuation and evaluation).** A *valuation* is a function `v : ℕ → LP`. Evaluation `eval v : Form → LP` is defined by recursion:
```
eval v (atom n)   = v n
eval v (neg p)    = neg (eval v p)
eval v (conj p q) = conj (eval v p) (eval v q)
eval v (disj p q) = disj (eval v p) (eval v q)
eval v (impl p q) = disj (neg (eval v p)) (eval v q).
```

A formula `A` is **satisfied** by `v` iff `desig(eval v A)`; it is **valid** iff satisfied by every valuation.

---

## 4. The paraconsistent profile of LP

We now state the four signature theorems that distinguish `LP` from classical logic, sharply separating *laws* (single valid formulas) from *inferences* (premise-to-conclusion licenses).

### 4.1 Classical laws survive as validities

**Theorem 4.1 (Excluded Middle is `LP`-valid).** For every valuation `v` and formula `p`,
```
desig( eval v (disj p (neg p)) ).
```
*Proof sketch.* Let `x = eval v p`. The disjunction evaluates to `max(x, neg x)`. If `x = ff`, `neg x = tt`, max `= tt`; if `x = tt`, max `= tt`; if `x = bb`, `neg x = bb`, max `= bb`. All three results are designated. ∎

**Theorem 4.2 (Non-Contradiction is `LP`-valid).** For every `v` and `p`,
```
desig( eval v (neg (conj p (neg p))) ).
```
*Proof sketch.* With `x = eval v p`, the inner conjunction is `min(x, neg x)`; negating gives, by cases: `x = ff → neg(min(ff,tt)) = neg(ff) = tt`; `x = tt → neg(ff) = tt`; `x = bb → neg(bb) = bb`. Designated in all cases. ∎

The two cornerstone classical laws hold *as laws* in `LP`. What changes is the inference layer.

### 4.2 Contradictions are satisfiable and do not explode

**Theorem 4.3 (Contradiction satisfiability).** There exist `v, p` with `desig(eval v (conj p (neg p)))`.
*Proof.* Take `v ≡ bb` (constant glut) and `p = atom 0`. Then `conj(bb, neg bb) = conj(bb, bb) = bb`, which is designated. ∎

Note the apparent tension with Theorem 4.2: *the Law of Non-Contradiction is valid, yet a contradiction is satisfiable.* There is no inconsistency — Theorem 4.2 says the formula `¬(p ∧ ¬p)` is always designated, while Theorem 4.3 says the formula `p ∧ ¬p` is *sometimes also* designated. In `LP` a formula and its negation can both be designated (precisely at a glut); designation is not a classical truth predicate.

**Theorem 4.4 (Explosion fails — paraconsistency).** There exist `v, p, q` with
```
desig(eval v p)  ∧  desig(eval v (neg p))  ∧  ¬ desig(eval v q).
```
*Proof.* Take `v` with `v 0 = bb`, `v 1 = ff`, `p = atom 0`, `q = atom 1`. Then `p` evaluates to `bb` (designated), `neg p` to `bb` (designated), but `q` to `ff` (undesignated). ∎

So `{p, ¬p} ⊭ q`: a contradiction does **not** entail an arbitrary conclusion. This is the defining property of a paraconsistent logic.

### 4.3 Material modus ponens fails

**Theorem 4.5 (Modus ponens fails).** There exist `v, p, q` with
```
desig(eval v p)  ∧  desig(eval v (impl p q))  ∧  ¬ desig(eval v q).
```
*Proof.* With `v 0 = bb`, `v 1 = ff`, `p = atom 0`, `q = atom 1`: `p = bb` (designated); `impl p q = disj(neg bb, ff) = disj(bb, ff) = bb` (designated); but `q = ff` (undesignated). ∎

The culprit is Lemma 2.9: when `p` is a glut, `neg p` is *also* designated, so the material conditional `¬p ∨ q` is already designated regardless of `q`. Material implication is too weak to transmit assertibility across a glut.

### 4.4 Glut-free valuations are classical

**Definition 4.6 (Glut-free valuation).** `v` is *glut-free* iff `v n ≠ bb` for all atoms `n`.

**Theorem 4.7 (No glut is manufactured).** If `v` is glut-free, then `eval v A ≠ bb` for every formula `A`.
*Proof sketch.* Structural induction on `A`. Base: atoms are glut-free by hypothesis. Step: `bb` is never an output of `neg`, `min`, or `max` when the inputs avoid `bb` — e.g. `min(x,y) = bb` requires one input to be `bb` (since `bb` is the middle of the chain and `min` returns the smaller, which equals `bb` only if both inputs are `≥ bb` and one equals `bb`). A finite check of each connective on glut-free inputs closes every case. ∎

**Theorem 4.8 (Classical collapse).** If `v` is glut-free, then for every `A`,
```
¬ ( desig(eval v A)  ∧  desig(eval v (neg A)) ).
```
*Proof sketch.* By Theorem 4.7, `eval v A ∈ {ff, tt}`. If `A` evaluates to `tt`, then `neg A` evaluates to `ff`, undesignated; if `A` evaluates to `ff`, `A` itself is undesignated. Either way the conjunction of designations fails. ∎

Thus on glut-free valuations `LP` is exactly classical logic: contradictions are impossible and the third value is inert. `LP` strictly *extends* classical logic, recovering it as the glut-free fragment.

---

## 5. Consequence relations: `entails` (LP) and `entailsMin` (LPm)

### 5.1 Classical-style LP consequence

**Definition 5.1 (Model).** A valuation `v` is a **model** of a premise set `Γ ⊆ Form`, written `isModel Γ v`, iff it designates every premise:
```
isModel Γ v  :≡  ∀ B ∈ Γ, desig(eval v B).
```

**Definition 5.2 (LP consequence).**
```
entails Γ A  :≡  ∀ v, isModel Γ v → desig(eval v A).
```
`A` is an `LP`-consequence of `Γ` iff every model of `Γ` designates `A`.

By Theorem 4.4, `entails {p, ¬p} q` is **false**, confirming that `entails` is paraconsistent. By Theorem 4.5, `entails {p, impl p q} q` is also false: `LP` consequence is too weak to license modus ponens unconditionally. This is precisely the motivation for `LPm`.

### 5.2 Minimal-glut (LPm) consequence

The minimally-inconsistent strategy: do not assume the world is *more* paradoxical than the premises force.

**Definition 5.3 (Glut set).** For a valuation `v`, its glut set is
```
gluts(v) = { n : ℕ | v n = bb }.
```

**Definition 5.4 (Minimal model).** A valuation `v` is a **minimal model** of `Γ`, written `minimal Γ v`, iff it is a model with `⊂`-minimal glut set among models:
```
minimal Γ v  :≡  isModel Γ v  ∧  ¬ ∃ w, isModel Γ w ∧ gluts(w) ⊂ gluts(v).
```

**Definition 5.5 (LPm consequence).**
```
entailsMin Γ A  :≡  ∀ v, minimal Γ v → desig(eval v A).
```
Only conclusions designated by *every minimally-paradoxical* model of `Γ` count.

Because `minimal Γ v` is strictly stronger than `isModel Γ v`, the quantifier ranges over fewer valuations, so `entailsMin` is *at least as strong* as `entails`: whenever `entails Γ A`, also `entailsMin Γ A`. The interesting case is strict gain — and strict gain is exactly what produces non-monotonicity.

### 5.3 The central theorem: non-monotonicity / retraction

**Theorem 5.6 (Retraction — `LPm` is non-monotone).** With `p = atom 0`, `q = atom 1`:
```
entailsMin {p, impl p q} q          holds,
entailsMin {p, impl p q, neg p} q   fails.
```
That is, `q` is a minimal consequence of `{p, p→q}`, but adding the contradictory premise `¬p` *retracts* it: `q` is no longer a minimal consequence of `{p, p→q, ¬p}`.

*Proof sketch.*

**(i) `q` follows from `{p, p→q}`.** A glut-free valuation with `p ↦ tt`, `q ↦ tt` is a model (both premises designated) and carries no gluts, so the minimal glut set among models is `∅`. Every model achieving `gluts = ∅` must, to designate `p`, set `p = tt` (since `p ≠ bb` and `desig p` force `p = tt` by Lemma 2.10), and then designating `impl p q = disj(neg tt, q) = disj(ff, q) = q` forces `q` designated, hence (being glut-free) `q = tt`. Thus every minimal model designates `q`, so `entailsMin {p, impl p q} q`. 

**(ii) `q` is retracted upon adding `¬p`.** Now both `p` and `neg p` must be designated; by Lemma 2.9 this forces `p = bb`, so *every* model of `{p, p→q, ¬p}` has `0 ∈ gluts(v)`. The minimal glut set is therefore `{0}` (it cannot be smaller, and `{0}` is realized). With `p = bb`, the implication `impl p q = disj(neg bb, q) = disj(bb, q)` is designated for *every* value of `q` (since `disj(bb, ff) = bb` is designated). Hence the valuation `v` with `v 0 = bb`, `v 1 = ff` is a model with glut set `{0}` — minimal — yet `eval v q = ff` is undesignated. So `entailsMin {p, impl p q, neg p} q` fails. ∎

**Interpretation.** Monotonicity requires that enlarging `Γ` never shrinks the consequence set. Here the conclusion `q` is *lost* upon adding a premise. The mechanism is precise: minimality is informative *exactly when consistency fails*. While the premises admit a glut-free model, minimal models avoid gluts and `LPm` behaves classically (recovering modus ponens, step (i)). The moment the premises force a glut (here, `¬p` makes `p = bb` unavoidable), the minimal-glut models become genuinely paradoxical and previously-licensed inferences can collapse. Contradiction-tolerance and the capacity to revise beliefs are two aspects of one mechanism.

---

## 6. The tropical / idempotent-semiring bridge

The combination rules `conj = min`, `disj = max` are not merely convenient — they are literally the operations of a tropical (min-plus / max-plus style) semiring on a three-point chain.

**Theorem 6.1 (Idempotent commutative semiring).** `(LP, +, ·) := (LP, disj, conj)` is a commutative semiring with:
- **additive identity** `ff`: `disj(ff, x) = x` (Lemma 2.8);
- **multiplicative identity** `tt`: `conj(tt, x) = x`;
- commutativity and associativity of both `disj` and `conj` (they are `max`/`min` on a total order);
- distributivity of `conj` over `disj`: `conj(x, disj(y, z)) = disj(conj(x, y), conj(x, z))` (the absorption/distribution law for `min` over `max` on a chain);
- **additive idempotence** `disj(x, x) = x` and **multiplicative idempotence** `conj(x, x) = x`.
*Proof sketch.* All identities are finite (`3` or `3³` cases) and verified by exhaustive evaluation; idempotence and the identities are immediate from `max`/`min` on a chain. ∎

Idempotent additivity (`x + x = x`) is exactly the hallmark of tropical/idempotent semirings; the structure is a bounded distributive lattice presented as a semiring, the two-element-spaced analogue of the min-plus semiring `(ℝ ∪ {∞}, min, +)`.

**Theorem 6.2 (Designated set is a prime filter).** The designated set `D = {bb, tt}` satisfies, for all `x, y`:
```
desig(conj(x, y)) ↔ desig(x) ∧ desig(y)        (filter / multiplicative)
desig(disj(x, y)) ↔ desig(x) ∨ desig(y)        (prime / additive)
```
*Proof sketch.* Both are `3 × 3` truth-table checks. The first says `conj = min` lands in `D` iff both arguments do (since `ff` is the unique non-designated value and the bottom of the chain); the second says `disj = max` lands in `D` iff at least one argument does. ∎

In lattice-theoretic terms `D = {bb, tt}` is an up-set closed under meet (`conj`) and prime with respect to join (`disj`) — a *prime filter* of the bounded distributive lattice `LP`. This is the algebraic face of the everyday assertibility rules "a conjunction is assertible iff both conjuncts are" and "a disjunction is assertible iff some disjunct is."

**Consequences of the bridge.** Because satisfaction is "evaluation lands in the prime filter `D`," paraconsistent satisfiability of a premise set becomes a question about whether a system of `min`/`max` (tropical) constraints has a solution inside the filter `D`. This places `LP` semantics inside the toolbox of tropical/idempotent algebra: fixed-point and eigenvalue theorems for min-plus systems translate into statements about stable belief states under iterated revision, and the order-theoretic minimality of `gluts` used in `LPm` is minimization along one axis of the underlying (bi)lattice.

---

## 7. Algorithms

The semantics is fully computable over finite atom sets, since `eval v A` depends only on the finitely many atoms occurring in `A`, and `LP` is finite. We describe the three core procedures used in the accompanying numerical demonstrations.

### 7.1 Formula evaluation

Recursive descent over the formula tree applying `neg`, `min`, `max`. For a formula of size `s`, evaluation under a fixed valuation is `O(s)`.

### 7.2 Deciding `entails Γ A`

Collect the `k` atoms occurring in `Γ ∪ {A}`; enumerate all `3^k` valuations; keep those that are models of `Γ`; return `True` iff all of them designate `A`. Complexity `O(3^k · (|Γ| · s))`. This is a decision procedure: `entails` over finite premises is decidable because the value space is finite and evaluation is local to the occurring atoms.

### 7.3 Deciding `entailsMin Γ A`

Enumerate the `3^k` valuations and the model subset `M`; compute each model's glut set; retain the `⊂`-minimal models `M_min` (a model is kept iff no other model has a strictly smaller glut set); return `True` iff all of `M_min` designate `A`. Minimality is a *finite* `⊂`-comparison of glut sets rather than a quantifier over all valuations, so the whole relation is decidable; complexity `O(3^k · (|M| + |Γ| · s))`.

---

## 8. Applications

- **Inconsistency-tolerant knowledge bases.** A knowledge base merged from conflicting sources can be queried under `entails`/`entailsMin` without trivialization: contradictions are localized to gluts, and `LPm` answers queries using the least-inconsistent reading of the data.
- **Belief revision and defeasible reasoning.** Theorem 5.6 shows `LPm` performs genuine retraction: conclusions are withdrawn when new information forces a previously avoidable inconsistency. This models the non-monotonic core of commonsense and scientific reasoning natively, without a bolt-on revision operator.
- **Database integrity with conflicting records.** Treating "both" as a first-class answer lets a query engine return useful, non-explosive answers in the presence of integrity-constraint violations.
- **Tropical reformulation of satisfiability.** Via Theorems 6.1–6.2, paraconsistent satisfiability is a min-plus feasibility problem, enabling transfer of optimization and fixed-point machinery from tropical mathematics to belief dynamics.

---

## 9. Discussion

The contribution is two-fold. First, a clean separation of *law* from *inference*: `LP` keeps every classical *validity* (Theorems 4.1–4.2) while shedding the explosive and material-MP *inferences* (Theorems 4.4–4.5). This dissolves the apparent paradox that a logic can validate non-contradiction yet satisfy contradictions. Second, the demonstration that the strength deficit of `LP` is repaired by `LPm` at the cost — and benefit — of non-monotonicity (Theorem 5.6), with the precise mechanism identified: minimality matters exactly when the premises force inconsistency.

The tropical bridge (Section 6) reframes the entire semantics algebraically. The `min`/`max` identity is not a notational coincidence; it places three-valued paraconsistent logic and min-plus algebra in the same structural class (commutative idempotent semirings with a prime filter of designated values), suggesting a systematic transfer of results between the fields.

A caveat: material implication is provably inadequate (Theorem 4.5). Practical inference in dialetheic settings typically requires a stronger, non-material conditional; designing and verifying such a conditional that respects the gluts is a natural next step.

---

## 10. Future work

The following directions are each phrased so that a single theorem (or its disproof) settles it.

1. **Sound and complete Hilbert calculus for `entails`.** Conjecture: a finite axiom schema plus the rule of adjunction yields a finitary derivability relation `⊢` with `Γ ⊢ A ↔ entails Γ A` for finite `Γ`. Since the classical tautologies all survive, the calculus is obtained from a classical Hilbert system by deleting ex-falso and disjunctive syllogism, and completeness can be proved via a three-valued canonical model built on the verified `eval`/`desig` pair.

2. **Verified decision procedure for `entailsMin`.** Conjecture: over finitely many atoms, `entailsMin Γ A` is decidable with a correctness-proven decision instance. The argument: `eval v A` depends only on the occurring atoms, minimal models are searched over the finite cube `LP^k`, and minimality is a finite `⊂`-comparison of glut sets.

3. **Monotonicity boundary theorem.** Conjecture: `entailsMin Γ A ↔ entails Γ A` exactly on the consistent fragment — if `Γ` has a glut-free model, the two relations coincide; they diverge only when every model of `Γ` is forced to contain a glut. This upgrades the single retraction example into a structural dividing line between monotone and non-monotone reasoning.

4. **Belnap's four-valued `FOUR` and information-order retraction.** Conjecture: adding a fourth value `nn` ("neither") yields the bilattice `FOUR = {ff, nn, bb, tt}` with two independent orders (truth and information), in which retraction along the information order is dual to the glut-minimization of `LPm`; monotonicity should hold along the information order even where it fails along the truth order, cleanly separating "more data" from "more commitment."

5. **Deepening the tropical bridge.** Conjecture: recasting paraconsistent satisfiability as min-plus solvability lets tropical eigenvalue/idempotency theorems transfer to statements about stable belief states under iterated revision, with `(LP, conj, disj)` as the explicit two-spaced tropical semiring and `{bb, tt}` as its prime filter.

---

## 11. Conclusion

We have given a fully verified model theory for the Logic of Paradox and its minimally-inconsistent strengthening, establishing the complete paraconsistent profile (satisfiable non-explosive contradictions; valid excluded-middle and non-contradiction; failing explosion and modus ponens; classical collapse on glut-free valuations), the centerpiece non-monotonic retraction theorem for `LPm`, and a tropical-semiring bridge that recasts the logic as an idempotent min-plus structure with a prime designated filter. Together these results show that contradiction-tolerance, the capacity to revise beliefs, and the algebra of shortest paths are facets of a single, small, and rigorously controlled mathematical object.
