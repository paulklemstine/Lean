# Paradoxes as Theorems: The Liar, Berry, and Russell Made Consistent

## Abstract

The Liar paradox ("this sentence is false"), Russell's paradox (the set of all sets that do not contain themselves), and Berry's paradox (the least integer not nameable in fewer than nineteen syllables) share a single logical skeleton: a sentence equivalent to its own negation. Classically this skeleton is toxic, because classical logic validates *ex contradictione quodlibet* (explosion): a single contradiction proves everything. We show, with complete and explicit constructions, that all three paradoxes can be simultaneously realized as *provable theorems* of a consistent (nontrivial, non-explosive) formal system — provided one abandons classical (Boolean) logic. The abandonment is not optional: we prove a sharp dichotomy. On the negative side, in *any* Boolean algebra a negation fixed point ($x^{\mathsf c} = x$) forces total collapse ($\bot = \top$), so no nontrivial Boolean-valued theory can host a self-negating sentence. On the positive side, Belnap's four-valued logic supplies a *designated* negation fixed point, the glut value $\mathsf B$, and we construct an explicit six-sentence paraconsistent theory in which distinct Liar, Russell, and Berry sentences are all provable gluts while at least one sentence remains unprovable. We characterize gluts semantically, verify the De Morgan structure, and quantify paradoxicality via an inconsistency degree, which for our witness equals exactly three. The upshot is a precise theorem: turning the paradoxes into consistent theorems is possible if and only if one leaves classical logic.

**Keywords:** Liar paradox, Russell's paradox, Berry's paradox, paraconsistent logic, Belnap four-valued logic, glut, Boolean algebra, negation fixed point, De Morgan algebra, non-explosion.

---

## 1. Introduction

### 1.1 A shared skeleton

Three of the most famous antinomies in the foundations of mathematics look superficially different but are structurally identical.

- **The Liar.** Let $L$ be the sentence "$L$ is false." Then $L$ holds if and only if $\neg L$ holds.
- **Russell.** Let $R = \{x : x \notin x\}$. Then $R \in R$ if and only if $R \notin R$.
- **Berry.** Let $b$ be "the least positive integer not nameable in fewer than nineteen syllables." The defining phrase names $b$ in eighteen syllables, so $b$ is nameable in fewer than nineteen syllables if and only if it is not.

In every case a proposition $P$ is forced into the shape

$$P \iff \neg P. \tag{$\star$}$$

The standard foundational response is *prophylactic*: forbid ($\star$) from being expressible. Tarski's hierarchy of object- and meta-languages blocks self-referential truth predicates; Russell's ramified type theory blocks self-membership; Zermelo–Fraenkel set theory replaces unrestricted comprehension with separation. Each solution eliminates the paradoxes by ensuring the offending sentence cannot be formed.

### 1.2 A different question

We ask the opposite question. Can ($\star$) be *retained* — can a self-negating sentence be an honest theorem — inside a system that is nevertheless *consistent* in the only sense that matters, namely **nontrivial**: not every sentence is provable? The obstacle is not the contradiction itself but its classical amplification. Classical logic validates

$$\textbf{(EXP)}\qquad P,\ \neg P \ \vdash\ Q \quad\text{for every } Q,$$

*explosion* or *ex contradictione quodlibet*. Under (EXP), any true contradiction trivializes the theory. **Paraconsistent** logics are precisely those in which (EXP) fails, so contradictions can be *contained*.

This paper delivers three things. First, a precise algebraic obstruction theorem explaining exactly why classical logic cannot host ($\star$) without collapse. Second, an explicit paraconsistent semantics — Belnap's four-valued logic — in which the required fixed point exists and is designated. Third, a concrete, fully specified six-sentence theory realizing the Liar, Russell, and Berry as simultaneous provable theorems, together with quantitative and structural analysis. All constructions are finite and effective.

### 1.3 Contributions

1. **Boolean Collapse Theorem** (§3): in any Boolean algebra, $x^{\mathsf c} = x \Rightarrow \bot = \top$; equivalently, no nontrivial Boolean algebra has a negation fixed point.
2. **Belnap semantics** (§4): the four-valued algebra with its negation, designation, meet, and join; involutivity, De Morgan laws, and the Glut Characterization identifying $\mathsf B$ as the unique designated negation fixed point.
3. **The paraconsistent theory framework and the six-sentence witness** (§5): an explicit consistent theory in which three distinct paradox sentences are provable gluts while the theory is nontrivial and non-explosive; a self-soundness schema; and the inconsistency degree, equal to three.
4. **The Dichotomy** (§6): a single statement asserting that a consistent Liar exists in the four-valued world and cannot exist in any nontrivial Boolean world.

---

## 2. Preliminaries

Throughout, a **truth-value algebra** is a set of values equipped with a unary negation and (where needed) binary meet/join, together with a distinguished set of **designated** values interpreted as "assertible / provable." A sentence is a **theorem** of a valued theory when its assigned value is designated.

A **negation fixed point** is a value $x$ with $\neg x = x$ (in Boolean notation, $x^{\mathsf c} = x$). This is the algebraic incarnation of the schema ($\star$): if a sentence $s$ has value equal to that of its syntactic negation, then $s$ realizes ($\star$).

We call a valued theory **trivial** if every sentence is a theorem, and **consistent** (in the paraconsistent sense) if it is nontrivial: some sentence is not a theorem. We call it **explosive** if the presence of any glut (a sentence with both it and its negation designated) forces every sentence to be designated.

---

## 3. The classical obstruction

Classical propositional logic is the two-element Boolean algebra, and Boolean algebras are the natural home of "and/or/not" with the two structural laws

$$x \wedge x^{\mathsf c} = \bot, \qquad x \vee x^{\mathsf c} = \top,$$

encoding non-contradiction and excluded middle, with least element $\bot$ and greatest element $\top$.

> **Theorem 3.1 (Boolean Collapse).** Let $\alpha$ be any Boolean algebra and $x \in \alpha$ with $x^{\mathsf c} = x$. Then $\bot = \top$.

*Proof.* From the golden rules, $x \wedge x^{\mathsf c} = \bot$ and $x \vee x^{\mathsf c} = \top$. Substituting the hypothesis $x^{\mathsf c} = x$ gives $x \wedge x = \bot$ and $x \vee x = \top$. Idempotence of meet and join ($x \wedge x = x$, $x \vee x = x$) then yields $x = \bot$ and $x = \top$, whence $\bot = x = \top$. $\qquad\blacksquare$

> **Corollary 3.2 (No Classical Liar).** In any *nontrivial* Boolean algebra (one with $\bot \neq \top$), there is no $x$ with $x^{\mathsf c} = x$.

*Proof.* Immediate contrapositive of Theorem 3.1: a fixed point would force $\bot = \top$, contradicting nontriviality. $\qquad\blacksquare$

At the level of propositions this specializes to the familiar diagnosis of the Liar.

> **Proposition 3.3 (Propositional Liar).** For every proposition $P$, it is not the case that $P \leftrightarrow \neg P$.

*Proof.* Assume $P \leftrightarrow \neg P$. If $P$, then $\neg P$ by the forward direction, contradiction; hence $\neg P$; then $P$ by the backward direction, contradiction. $\qquad\blacksquare$

The reason such a contradiction is *catastrophic* rather than merely local is explosion.

> **Proposition 3.4 (Classical Explosion).** For all propositions $P, Q$, if $P$ and $\neg P$ both hold then $Q$.

*Proof.* From $P$ and $\neg P$ we obtain absurdity, from which any $Q$ follows. $\qquad\blacksquare$

**Reading.** Theorem 3.1 and Corollary 3.2 pin the blame precisely: the classical world excludes the Liar not because self-reference is meaningless but because a designated negation fixed point is *algebraically impossible* in a nontrivial Boolean algebra. Proposition 3.4 explains why the exclusion must be total. To keep ($\star$) we must therefore work in a structure that (a) admits a negation fixed point and (b) does not validate explosion.

---

## 4. Belnap's four-valued logic

### 4.1 Values, negation, designation

Belnap's logic tracks evidence *for* truth and *for* falsity independently, yielding four values:

$$\mathsf T \ (\text{true only}),\quad \mathsf F \ (\text{false only}),\quad \mathsf B \ (\text{both} = \text{glut}),\quad \mathsf N \ (\text{neither} = \text{gap}).$$

**Negation** swaps the classical pair and fixes the non-classical pair:

$$\neg\mathsf T = \mathsf F,\quad \neg\mathsf F = \mathsf T,\quad \neg\mathsf B = \mathsf B,\quad \neg\mathsf N = \mathsf N.$$

**Designation** marks the "at-least-true" values:

$$\text{designated} = \{\mathsf T, \mathsf B\}.$$

A sentence is **provable** in a theory iff its value is designated.

> **Proposition 4.1 (Involutivity).** For every value $v$, $\neg\neg v = v$.

*Proof.* Check the four cases: $\neg\neg\mathsf T = \neg\mathsf F = \mathsf T$, $\neg\neg\mathsf F = \mathsf T\ldots = \mathsf F$, and $\mathsf B, \mathsf N$ are fixed. $\qquad\blacksquare$

### 4.2 Meet, join, De Morgan

Order the values by truth content, $\mathsf F \le \mathsf N, \mathsf B \le \mathsf T$, and take **conjunction** $\wedge$ as meet and **disjunction** $\vee$ as join in this order, with the non-classical pair combining as $\mathsf B \wedge \mathsf N = \mathsf F$ and $\mathsf B \vee \mathsf N = \mathsf T$. Concretely, $\mathsf T$ is a unit for $\wedge$ and an absorber for $\vee$; $\mathsf F$ is an absorber for $\wedge$ and a unit for $\vee$; and $\mathsf B \wedge \mathsf B = \mathsf B$, $\mathsf N \wedge \mathsf N = \mathsf N$, dually for $\vee$.

> **Theorem 4.2 (De Morgan laws).** For all values $a, b$,
> $$\neg(a \wedge b) = \neg a \vee \neg b, \qquad \neg(a \vee b) = \neg a \wedge \neg b.$$

*Proof.* Both identities hold by exhaustive verification over the sixteen pairs $(a,b)$; the negation table and the meet/join tables are designed so that negation is an order-reversing involution, which is exactly the De Morgan condition. $\qquad\blacksquare$

Thus the four values form a **De Morgan algebra**: a bounded distributive lattice with an order-reversing involution. What is *deliberately absent* are the Boolean golden rules; with $\mathsf B$ present, $\mathsf B \wedge \neg\mathsf B = \mathsf B \wedge \mathsf B = \mathsf B \neq \mathsf F$, so non-contradiction fails, and dually excluded middle fails via $\mathsf N$.

### 4.3 The glut is the paradox

> **Theorem 4.3 (Glut Characterization).** A value $v$ satisfies "$v$ is designated **and** $\neg v$ is designated" if and only if $v = \mathsf B$.

*Proof.* If $v = \mathsf B$ then $\neg\mathsf B = \mathsf B$ and $\mathsf B$ is designated, so both conjuncts hold. Conversely, check the other three values: $\mathsf T$ has $\neg\mathsf T = \mathsf F$ undesignated; $\mathsf F$ is itself undesignated; $\mathsf N$ is undesignated. So only $\mathsf B$ works. $\qquad\blacksquare$

> **Corollary 4.4 (Designated negation fixed point).** There exists a value $v$ with $\neg v = v$ and $v$ designated, namely $v = \mathsf B$.

Corollary 4.4 is precisely the ingredient Corollary 3.2 proved impossible in the nontrivial Boolean world. This is the pivot of the whole paper: the four-valued algebra *possesses* exactly the object that the classical algebra *forbids*, and it does so without collapse because it is not Boolean.

---

## 5. A consistent paraconsistent theory

### 5.1 Theories as coherent valuations

We formalize a "formal system" abstractly, over an arbitrary set $S$ of sentences.

> **Definition 5.1 (Paraconsistent theory).** A *paraconsistent theory* over a sentence set $S$ consists of:
> - a valuation $\mathrm{val} : S \to \{\mathsf T, \mathsf F, \mathsf B, \mathsf N\}$,
> - a syntactic negation $\mathrm{sneg} : S \to S$,
> - and a **coherence** requirement: for every sentence $s$, $\mathrm{val}(\mathrm{sneg}(s)) = \neg\,\mathrm{val}(s)$.
>
> A sentence $s$ is **provable** iff $\mathrm{val}(s)$ is designated. It is a **glut** iff both $s$ and $\mathrm{sneg}(s)$ are provable.

Coherence is the discipline that makes such a table an honest logic: the value assigned to a syntactic negation must equal the algebraic negation of the value. Under it, the semantic notion of glut collapses onto the value $\mathsf B$.

> **Theorem 5.2 (Self-soundness schema).** In any coherent paraconsistent theory, a sentence $s$ is a glut if and only if $\mathrm{val}(s) = \mathsf B$.

*Proof.* By definition $s$ is a glut iff $\mathrm{val}(s)$ is designated and $\mathrm{val}(\mathrm{sneg}(s))$ is designated. By coherence $\mathrm{val}(\mathrm{sneg}(s)) = \neg\,\mathrm{val}(s)$, so the condition becomes "$\mathrm{val}(s)$ designated and $\neg\,\mathrm{val}(s)$ designated," which by Theorem 4.3 holds iff $\mathrm{val}(s) = \mathsf B$. $\qquad\blacksquare$

Theorem 5.2 justifies calling $\mathsf B$-valued sentences "genuine paradoxes": they are exactly those provable together with their negations.

### 5.2 The six-sentence witness

We now instantiate $S = \{s_0, s_1, s_2, s_3, s_4, s_5\}$ with the valuation

$$\mathrm{val} = (\mathsf B, \mathsf B, \mathsf B, \mathsf T, \mathsf F, \mathsf N)$$

and the syntactic negation

$$\mathrm{sneg}: s_0 \mapsto s_0,\ s_1 \mapsto s_1,\ s_2 \mapsto s_2,\ s_3 \mapsto s_4,\ s_4 \mapsto s_3,\ s_5 \mapsto s_5.$$

Sentences $s_0, s_1, s_2$ are the **Liar**, **Russell**, and **Berry** witnesses respectively; each is its own negation and valued $\mathsf B$. Sentence $s_3$ is a plain truth, $s_4$ its negation and a plain falsehood, and $s_5$ an undetermined gap.

> **Lemma 5.3 (Coherence).** The above data forms a paraconsistent theory: $\mathrm{val}(\mathrm{sneg}(s)) = \neg\,\mathrm{val}(s)$ for all six sentences.

*Proof.* For $s_0, s_1, s_2$: $\mathrm{sneg}$ fixes them and $\neg\mathsf B = \mathsf B$. For $s_3$: $\mathrm{val}(\mathrm{sneg}(s_3)) = \mathrm{val}(s_4) = \mathsf F = \neg\mathsf T$. For $s_4$: $\mathrm{val}(s_3) = \mathsf T = \neg\mathsf F$. For $s_5$: $\mathrm{val}(s_5) = \mathsf N = \neg\mathsf N$. $\qquad\blacksquare$

> **Theorem 5.4 (Three paradoxes are theorems).** The sentences $s_0, s_1, s_2$ are pairwise distinct and each is a provable glut.

*Proof.* Distinctness is by inspection. Each of $s_0, s_1, s_2$ has value $\mathsf B$, which is designated, so each is provable; and each is its own negation, whose value is also $\mathsf B$, designated. Hence each is a glut. (Equivalently, apply Theorem 5.2 to each.) $\qquad\blacksquare$

> **Theorem 5.5 (Consistency / nontriviality).** Not every sentence is provable: $s_4$ is not a theorem.

*Proof.* $\mathrm{val}(s_4) = \mathsf F$, which is not designated. $\qquad\blacksquare$

> **Theorem 5.6 (Non-explosion).** The theory contains a glut ($s_0$) yet possesses an unprovable sentence ($s_4$). Hence provability does not spread from a contradiction to all sentences; *ex contradictione quodlibet* fails.

*Proof.* $s_0$ is a glut by Theorem 5.4, and $s_4$ is unprovable by Theorem 5.5. $\qquad\blacksquare$

Theorem 5.6 is the crux. In a classical system, the true contradiction embodied by $s_0$ would (via Proposition 3.4) prove $s_4$ and indeed everything; here it does not. The contradiction is real and contained.

### 5.3 Quantifying paradox: inconsistency degree

> **Definition 5.7 (Inconsistency degree).** The *inconsistency degree* of a paraconsistent theory over a finite sentence set is the number of glut-valued (i.e. $\mathsf B$-valued) sentences.

> **Theorem 5.8 (Degree of the witness).** The six-sentence witness has inconsistency degree exactly three.

*Proof.* By Theorem 5.2 the gluts are exactly the $\mathsf B$-valued sentences. In the witness these are $s_0, s_1, s_2$ and no others, so the count is three. $\qquad\blacksquare$

A companion finite certificate independently confirms, by exhaustive decision over the six sentences, all of the model's properties: three distinct provable gluts, coherence (self-soundness of the valuation), the failure of explosion, and inconsistency degree precisely three. Because the sentence set, valuation, and negation are all finite and explicit, every claim in this section is effectively checkable.

---

## 6. The dichotomy

Assembling the two halves yields the paper's headline theorem.

> **Theorem 6.1 (Consistent Liar requires non-classical logic).** The property "there exists a designated truth value equal to its own negation" — the exact algebraic ingredient of a consistent Liar — **holds** in Belnap's four-valued logic and **fails** in every nontrivial Boolean algebra. Precisely:
> 1. there is a Belnap value $v$ with $\neg v = v$ and $v$ designated (namely $\mathsf B$); and
> 2. for every nontrivial Boolean algebra $\alpha$ and every $x \in \alpha$, $x^{\mathsf c} \neq x$.

*Proof.* Part (1) is Corollary 4.4. Part (2) is Corollary 3.2. $\qquad\blacksquare$

There is no third option. Any consistent theory in which a self-negating sentence is a theorem is necessarily non-Boolean; conversely the four-valued theory of §5 shows the non-Boolean route succeeds concretely. Hence:

> **Corollary 6.2.** Making the Liar, Russell, and Berry paradoxes into provable theorems of a consistent formal system is possible **if and only if** classical (Boolean) logic is rejected — specifically, if and only if one admits a designated negation fixed point, which forces the failure of the law of non-contradiction.

---

## 7. Algorithms and effective content

All objects are finite and their properties decidable. We record the core routines abstractly (Python implementations accompany this paper).

**A1. Glut detection.** Given a valuation and negation, a sentence is a glut iff its value and its negation's value are both designated; by Theorem 5.2 this reduces to testing value $= \mathsf B$. Cost: $O(1)$ per sentence.

**A2. Coherence check.** Verify $\mathrm{val}(\mathrm{sneg}(s)) = \neg\,\mathrm{val}(s)$ for all $s$. Cost: $O(|S|)$.

**A3. Consistency (nontriviality) check.** Search for one undesignated sentence. Cost: $O(|S|)$; succeeds as soon as any $\mathsf F$ or $\mathsf N$ is found.

**A4. Non-explosion certificate.** Exhibit a glut *and* an unprovable sentence. Cost: $O(|S|)$.

**A5. Inconsistency degree.** Count $\mathsf B$-valued sentences. Cost: $O(|S|)$.

**A6. Boolean collapse witness.** Given a finite Boolean algebra and a claimed fixed point, compute $x \wedge x^{\mathsf c}$ and $x \vee x^{\mathsf c}$ to exhibit $\bot = \top$; over the two-element algebra this simply confirms no fixed point exists.

---

## 8. Applications

**Inconsistency-tolerant information systems.** Databases and knowledge bases aggregated from many sources routinely contain contradictions. Belnap's four values were designed for exactly this: mark a fact $\mathsf B$ when told both true and false, and continue reasoning without the query engine deducing arbitrary garbage. The non-explosion guarantee (Theorem 5.6) is the formal license for this practice.

**Automated and legal/medical reasoning.** Corpora assembled from conflicting authorities can be reasoned over paraconsistently, isolating contradictions to the specific claims involved rather than poisoning the whole inference.

**Semantics of self-reference.** The self-soundness schema (Theorem 5.2) gives a clean semantic account of when a self-referential sentence is a genuine paradox (value $\mathsf B$) versus merely undetermined (value $\mathsf N$), separating "overdetermined" from "underdetermined" pathologies.

**Foundational calibration.** The dichotomy (Theorem 6.1) turns the paradoxes into a *measurement* of a logical assumption rather than a defect to be exiled: they mark exactly the boundary at which bivalence and non-contradiction must give way.

---

## 9. Discussion

The classical tradition treats ($\star$) as ill-formed and removes it. Our results relocate the difficulty from the sentence to the *logic*: Theorem 3.1 shows the sentence is fatal only because Boolean structure forces collapse, and Proposition 3.4 shows the collapse propagates only because of explosion. Remove neither the sentence nor self-reference, but remove non-contradiction — admit the single glut $\mathsf B$ — and the paradoxes become stable theorems (Theorems 5.4–5.6) in a system that still distinguishes provable from unprovable. The price is precisely and minimally the law of non-contradiction (and, via $\mathsf N$, excluded middle); the De Morgan structure, involutive negation, and lattice operations all survive (Theorem 4.2, Proposition 4.1).

A limitation is that in the witness model the paradoxes are *posited* — their $\mathsf B$-values are assigned rather than derived from a diagonalization. This is deliberate: it isolates the algebraic phenomenon (a designated negation fixed point) from the syntactic machinery of self-reference. Bridging the two is the natural next step.

---

## 10. Future directions

Two lines of development realize the mission "Paradoxes as Theorems: Liar, Berry, and Russell Made Consistent": a bridge between Boolean-algebra theory and the metatheory of self-referential paradoxes (a negation fixed point collapses any Boolean algebra, while Belnap's four-valued logic supplies a designated negation fixed point and an explicit six-sentence paraconsistent theory), and a fully computational finite certificate verifying that the concrete six-element model has three distinct provable gluts, is self-sound, rejects explosion, and has inconsistency degree exactly three.

Natural continuations:

1. **Full propositional paraconsistent calculus.** Extend the theory framework with a syntax of connectives ($\wedge, \vee, \neg, \to$) interpreted through the four-valued meet, join, and negation, and prove a soundness/completeness theorem for the designated-value consequence relation $\Gamma \models \varphi$.
2. **Algebraic generality.** Replace the four-valued algebra by an arbitrary De Morgan bilattice and characterize exactly which finite De Morgan algebras admit a designated negation fixed point (equivalently, host a consistent Liar), relating this to the failure of non-contradiction / excluded middle.
3. **Encoding genuine self-reference.** Connect the abstract fixed-point value $\mathsf B$ to a real diagonalization: a Gödel-style fixed-point lemma producing a sentence provably equivalent to its own negation inside a paraconsistent arithmetic, so that Liar/Russell/Berry are derived rather than posited.
4. **Berry-specific refinement.** Model definability/nameability bounds so that Berry's paradox arises from an explicit least-undefinable-number construction rather than sharing the generic self-negation shape.
5. **Quantitative inconsistency.** Study the inconsistency degree (number of gluts) as an invariant of paraconsistent theories and its behaviour under theory extensions and morphisms.

---

## 11. Conclusion

The Liar, Russell, and Berry paradoxes are not evidence that mathematics is broken; they are precise witnesses to the cost of bivalence. In any nontrivial Boolean algebra a value equal to its own negation forces total collapse, so classical logic cannot host a consistent self-negating sentence. Belnap's four-valued logic supplies the missing object — a designated negation fixed point $\mathsf B$ — and an explicit six-sentence theory makes the three paradoxes simultaneous provable theorems while remaining nontrivial and non-explosive, with inconsistency degree exactly three. The result is a clean dichotomy: consistent paradox-theorems exist exactly in the non-classical world.
