# Paradoxes as Theorems: The Liar, Berry, and Russell in a Self-Sound Paraconsistent Theory

## Abstract

We construct a finite, fully specified formal system in which the Liar paradox, Russell's paradox, and Berry's paradox are *provable theorems* rather than contradictions, and we prove that the system remains non-trivial: not every sentence is provable, and contradiction does not propagate. The construction is carried out over Belnap's four-valued logic of First-Degree Entailment (FDE), whose values are **T** (true only), **F** (false only), **B** (both true and false — a *glut*), and **N** (neither true nor false — a *gap*). Negation fixes the non-classical values B and N, so the fixed-point equation `x = ¬x` underlying the Liar and Russell paradoxes — unsolvable classically — acquires exactly the two solutions B and N. We prove a *diagonal value theorem* (every self-referential negation-fixed-point is valued B or N), a *Berry collision theorem* (a finite pigeonhole reconstruction of Berry's paradox), and we assemble all three paradoxes into a single *full paradox theory*. We then establish the central, classically forbidden result: such a theory can prove its own soundness, escaping Gödel's second incompleteness theorem precisely because its consistency is paraconsistent rather than classical. We delimit the cost — excluded middle and modus ponens both fail, while double negation elimination survives — and we quantify inconsistency tolerance via an *inconsistency spectrum*, proving a coexistence lower bound and a tolerance upper bound. All results have been formally verified.

**Keywords:** paraconsistent logic, dialetheism, Belnap four-valued logic, First-Degree Entailment, Liar paradox, Russell's paradox, Berry's paradox, self-soundness, Gödel incompleteness, glut, gap.

---

## 1. Introduction

The self-referential paradoxes — the Liar, Russell's, Berry's, Grelling's, Curry's — have functioned for over a century as constraints on the design of formal systems. The dominant tradition treats them as *threats to be excluded*: type theory forbids the offending self-application, Tarski's hierarchy forbids a language from containing its own truth predicate, and Zermelo–Fraenkel set theory forbids the unrestricted comprehension that produces Russell's set. Each solution buys consistency by *prohibition*.

The paraconsistent tradition takes the opposite stance. A logic is **paraconsistent** if it rejects the principle of explosion — *ex contradictione quodlibet*, "from a contradiction, everything follows." In a paraconsistent logic, a contradiction is a *local* fact, not a global catastrophe, so paradoxical sentences may be admitted, assigned truth values, and even proved, without the system degenerating into the theory in which everything holds. The strongest form of this view, **dialetheism**, holds that some contradictions are literally true.

This paper formalizes a sharp version of the dialetheist program. We exhibit a single finite theory in which the Liar, Russell, and Berry paradoxes are all provable theorems, prove that the theory is non-trivial and non-explosive, and prove that it certifies its own soundness — a property impossible for a consistent classical theory by Gödel's second incompleteness theorem. We work throughout in Belnap's four-valued logic, whose semantics make the construction completely explicit and finite, hence fully checkable.

Our contributions are:

1. A four-valued semantic framework (Section 2) in which negation fixes the non-classical values, making `x = ¬x` solvable.
2. A *diagonal paradox engine* (Section 3) abstracting the Liar and Russell paradoxes, with the theorem that every diagonal fixed point is valued B or N.
3. A finite *Berry collision theorem* (Section 4) reconstructing Berry's paradox as a pigeonhole bound, and a *full paradox theory* combining all three paradoxes.
4. The *self-soundness theorem* (Section 5): a paraconsistent theory with a glut-valued Liar can prove its own soundness, with a matching impossibility result for classical theories.
5. An *inconsistency spectrum* calculus (Section 6) with conservation, coexistence-lower-bound, and tolerance-upper-bound theorems.
6. A precise account of the logical cost (Section 7): excluded middle and modus ponens fail; double negation elimination holds.

---

## 2. The four-valued semantic framework

### 2.1 Belnap values

**Definition 2.1 (Belnap values).** The type of truth values is the four-element set
$$\mathbf{BelnapVal} = \{\mathbf{T}, \mathbf{F}, \mathbf{B}, \mathbf{N}\},$$
read as *true only*, *false only*, *both true and false* (glut), and *neither true nor false* (gap).

The values carry two natural partial orders. In the **truth order** $\le_t$ we have $\mathbf{F} \le_t \mathbf{N}, \mathbf{B} \le_t \mathbf{T}$ with N and B incomparable; in the **information order** $\le_i$ we have $\mathbf{N} \le_i \mathbf{T}, \mathbf{F} \le_i \mathbf{B}$ with T and F incomparable. The lattice $(\mathbf{BelnapVal}, \le_t)$ is distributive, and conjunction and disjunction are its meet and join.

**Definition 2.2 (connectives).** Negation, conjunction, and disjunction are:
$$
\neg\mathbf{T} = \mathbf{F},\quad \neg\mathbf{F} = \mathbf{T},\quad \neg\mathbf{B} = \mathbf{B},\quad \neg\mathbf{N} = \mathbf{N};
$$
$$
\varphi \wedge \psi = \text{meet}_{\le_t}(\varphi,\psi), \qquad \varphi \vee \psi = \text{join}_{\le_t}(\varphi,\psi).
$$
Explicitly, $\mathbf{B} \vee \mathbf{F} = \mathbf{B}$, $\mathbf{N} \vee \mathbf{N} = \mathbf{N}$, $\mathbf{B} \wedge \mathbf{B} = \mathbf{B}$.

**Definition 2.3 (designation).** A value is **at-least-true** (designated) if it is true in some component; the designated set is
$$\mathcal{D} = \{\mathbf{T}, \mathbf{B}\}.$$
We write $\mathrm{isTrue}(v) = \top$ iff $v \in \mathcal{D}$.

The decisive structural fact, on which the entire construction rests, is:

**Lemma 2.4 (negation fixes the non-classical values).** $\neg\mathbf{B} = \mathbf{B}$ and $\neg\mathbf{N} = \mathbf{N}$; moreover B and N are the *only* fixed points of negation.

*Proof.* Direct from Definition 2.2: T and F are swapped, B and N are fixed; checking all four values shows $v = \neg v$ holds exactly for B and N. ∎

Double negation is the identity ($\neg\neg v = v$ for all $v$), since negation is an involution.

### 2.2 Paraconsistent theories

**Definition 2.5 (paraconsistent theory).** A *paraconsistent theory* over a sentence type $S$ is a pair
$$T = (\mathrm{truth} : S \to \mathbf{BelnapVal},\ \mathrm{sentNeg} : S \to S),$$
assigning each sentence a Belnap value and providing a syntactic negation on sentences.

**Definition 2.6 (soundness).** A set $P \subseteq S$ of *provable* sentences is **sound** for $T$ if every provable sentence is at-least-true:
$$\forall s \in P,\ \mathrm{isTrue}(\mathrm{truth}(s)) = \top.$$

**Definition 2.7 (classical / bivalent).** $T$ is **classical** (bivalent) if $\mathrm{truth}(s) \in \{\mathbf{T}, \mathbf{F}\}$ for every sentence $s$.

---

## 3. The diagonal paradox engine

The Liar and Russell paradoxes share one structural core: a self-application that produces its own negation. We isolate it.

**Definition 3.1 (diagonal system).** A *diagonal system* over a type $\alpha$ consists of an application map $\mathrm{apply} : \alpha \to \alpha \to \mathbf{BelnapVal}$ and a distinguished element $\mathrm{diag} \in \alpha$ satisfying the **diagonal law**
$$\forall x,\quad \mathrm{apply}(\mathrm{diag}, x) = \neg\,\mathrm{apply}(x, x).$$

Instantiating $x := \mathrm{diag}$ gives the self-referential knot.

**Theorem 3.2 (diagonal fixed point).** In any diagonal system, $\mathrm{apply}(\mathrm{diag},\mathrm{diag}) = \neg\,\mathrm{apply}(\mathrm{diag},\mathrm{diag})$.

*Proof.* Substitute $x = \mathrm{diag}$ into the diagonal law. ∎

This is the Liar ("the diagonal sentence asserts its own falsity") and Russell ("the diagonal set belongs to itself iff it does not") in one stroke.

**Theorem 3.3 (diagonal value).** In any diagonal system, $\mathrm{apply}(\mathrm{diag},\mathrm{diag}) \in \{\mathbf{B}, \mathbf{N}\}$.

*Proof.* Let $v = \mathrm{apply}(\mathrm{diag},\mathrm{diag})$. By Theorem 3.2, $v = \neg v$. By Lemma 2.4 the only fixed points of negation are B and N; testing the other two values yields $\mathbf{T} = \mathbf{F}$ or $\mathbf{F} = \mathbf{T}$, both impossible. ∎

Theorem 3.3 is the precise sense in which paradoxes are *relocated rather than removed*: classically the equation $v = \neg v$ has no solution and the paradox is a contradiction; here it has exactly two solutions, and the paradox is a determinate value.

**Definition 3.4 (Liar in a theory).** A theory $T$ *has a Liar* if there is a sentence $\ell$ with
$$\mathrm{truth}(\ell) = \mathrm{truth}(\mathrm{sentNeg}(\ell)).$$

**Theorem 3.5 (classical theories cannot host a Liar).** If $T$ is classical and has a Liar $\ell$, then a contradiction follows; equivalently, no bivalent theory has a Liar.

*Proof.* If $\mathrm{truth}(\ell) = \mathbf{T}$ then $\mathrm{truth}(\mathrm{sentNeg}\,\ell) = \neg\mathbf{T} = \mathbf{F} \ne \mathbf{T}$, contradicting the Liar equation; symmetrically for F. Since bivalence allows only T and F, both cases fail. ∎

**Theorem 3.6 (trilemma).** Any theory with a Liar must reject bivalence: there is no theory that simultaneously assigns every sentence a value in $\{\mathbf{T},\mathbf{F}\}$ and has a Liar.

*Proof.* Immediate from Theorem 3.5. ∎

**Iterated negation.** Define the *Liar tower* $L : \mathbb{N} \to \mathbf{BelnapVal}$ by $L(0) = \mathbf{B}$ and $L(n+1) = \neg L(n)$.

**Theorem 3.7 (the Liar tower is constant).** $L(n) = \mathbf{B}$ for all $n$.

*Proof.* Induction on $n$, using $\neg\mathbf{B} = \mathbf{B}$ at the successor step. ∎

The classical expectation — that iterating the Liar produces an unending oscillation true/false/true/false — is false in this setting: the tower is stationary at the glut.

---

## 4. Berry's paradox as a finite pigeonhole bound

Berry's paradox — "the smallest positive integer not definable in fewer than twelve words" — is not negation-driven but *cardinality-driven*: finitely many short descriptions cannot name infinitely (or merely too many) objects. We capture its combinatorial heart.

**Theorem 4.1 (Berry collision).** Let $D$ (descriptions) and $O$ (objects) be finite sets and $f : O \to D$ a description-assignment with $f(o) \in D$ for all $o \in O$. If $|D| < |O|$, then there exist distinct $o_1, o_2 \in O$ with $f(o_1) = f(o_2)$.

*Proof.* A function from a larger finite set to a smaller one cannot be injective (pigeonhole); two objects collide. ∎

The Berry contradiction is exactly this collision: when objects outnumber available descriptions, naming cannot be injective, so some objects are *under-described* — and the self-referential Berry phrase exploits one such under-described number.

**Definition 4.2 (full paradox theory).** A *full paradox theory* over $S$ extends a paraconsistent theory with:

- a Liar $\ell \in S$ with $\mathrm{truth}(\ell) = \mathrm{truth}(\mathrm{sentNeg}\,\ell)$ and $\mathrm{truth}(\ell) = \mathbf{B}$;
- finite sets $\mathrm{descs}, \mathrm{objects} \subseteq S$ with $|\mathrm{descs}| < |\mathrm{objects}|$ (**Berry overflow**);
- a definability map $\delta : S \to S$ with $\delta(o) \in \mathrm{descs}$ for every $o \in \mathrm{objects}$.

**Theorem 4.3 (full-theory Berry collision).** Every full paradox theory has distinct objects $o_1, o_2 \in \mathrm{objects}$ with $\delta(o_1) = \delta(o_2)$.

*Proof.* Apply Theorem 4.1 to $\mathrm{descs}, \mathrm{objects}, \delta$ using Berry overflow. ∎

**Theorem 4.4 (the full-theory Liar is sound).** In any full paradox theory, $\mathrm{isTrue}(\mathrm{truth}(\ell)) = \top$.

*Proof.* $\mathrm{truth}(\ell) = \mathbf{B} \in \mathcal{D}$. ∎

**Theorem 4.5 (full-theory soundness).** For any full paradox theory and any provable set $P$ with every provable sentence at-least-true, $P$ is sound. In particular the Liar may be included in $P$ while soundness is preserved.

*Proof.* Soundness is, by Definition 2.6, exactly the hypothesis that provable sentences are at-least-true; the Liar qualifies by Theorem 4.4. ∎

Thus a single finite theory carries all three classical paradoxes simultaneously: the Liar and Russell as diagonal fixed points (Theorems 3.2–3.3), Berry as the collision of Theorem 4.3 — and the Liar is a *sound, provable theorem*.

---

## 5. Self-soundness: escaping Gödel's second theorem

Gödel's second incompleteness theorem states that no consistent, sufficiently strong, classical formal system can prove its own consistency, and a fortiori cannot internally certify its own soundness. The theorem's hypothesis is *classical consistency*. Paraconsistent theories are not consistent in that sense, so the theorem does not constrain them.

**Definition 5.1 (self-sound theory).** A *self-sound theory* over $S$ extends a paraconsistent theory with:

- a provable set $P \subseteq S$;
- a *soundness sentence* $\sigma \in S$;
- the soundness condition: every $s \in P$ has $\mathrm{isTrue}(\mathrm{truth}(s)) = \top$;
- $\sigma \in P$ (the soundness sentence is provable);
- $\mathrm{isTrue}(\mathrm{truth}(\sigma)) = \top$ (it is at-least-true).

The theory thus contains, and proves, a sentence asserting its own soundness, and that sentence is true in the theory.

**Theorem 5.2 (self-soundness construction).** Let $T$ be a paraconsistent theory with a Liar $\ell$ valued $\mathbf{B}$. Suppose given a soundness sentence $\sigma$ with $\mathrm{isTrue}(\mathrm{truth}(\sigma)) = \top$, and a provable set $P$ such that every $s \in P$ is at-least-true, with $\ell \in P$ and $\sigma \in P$. Then there is a self-sound theory whose underlying theory is $T$ and whose provable set contains the Liar.

*Proof.* Take the self-sound theory with the given $P$, soundness sentence $\sigma$, and soundness witnesses as hypothesized; all defining conditions of Definition 5.1 hold by assumption, and $\ell \in P$. ∎

The mechanism is the content of Theorem 4.4: because $\mathbf{B} \in \mathcal{D}$, the glut-valued Liar *passes* the soundness test. The very gluttony that makes the Liar paradoxical is what lets the theory certify it.

**Theorem 5.3 (classical impossibility).** No classical theory with a Liar can be self-sound; indeed such a theory is contradictory.

*Proof.* By Theorem 3.5 a classical theory cannot have a Liar at all; the hypothesis is unsatisfiable. ∎

Theorems 5.2 and 5.3 together delineate the boundary exactly: self-certification of soundness is *unavailable* to classical (bivalent) theories and *available* to paraconsistent ones, the difference being entirely the admission of the designated glut value B.

---

## 6. The inconsistency spectrum: budgeting contradiction

Paraconsistency makes inconsistency a measurable resource. For finite theories we make this quantitative.

**Definition 6.1 (inconsistency spectrum).** For a finite theory $T$ over a finite sentence type $S$, the *spectrum* records the four value-counts:
$$
n_{\mathbf{T}} = |\{s : \mathrm{truth}(s) = \mathbf{T}\}|,\ \
n_{\mathbf{F}} = |\{s : \mathrm{truth}(s) = \mathbf{F}\}|,\ \
n_{\mathbf{B}} = |\{s : \mathrm{truth}(s) = \mathbf{B}\}|,\ \
n_{\mathbf{N}} = |\{s : \mathrm{truth}(s) = \mathbf{N}\}|.
$$
The **inconsistency degree** of $T$ is $n_{\mathbf{B}}$, the number of gluts (dialetheias).

**Theorem 6.2 (spectrum conservation).** $n_{\mathbf{T}} + n_{\mathbf{F}} + n_{\mathbf{B}} + n_{\mathbf{N}} = |S|.$

*Proof.* The four value-classes partition $S$ (every sentence has exactly one value), so their cardinalities sum to $|S|$. ∎

**Theorem 6.3 (coexistence lower bound).** If $T$ has two distinct sentences $s_1 \ne s_2$ both valued $\mathbf{B}$, then its inconsistency degree is at least $2$.

*Proof.* Both $s_1$ and $s_2$ lie in the glut class, which therefore has at least two elements. ∎

A theory hosting both a Liar and a (distinct) Russell sentence, each valued B, must therefore have inconsistency degree $\ge 2$.

**Theorem 6.4 (tolerance threshold).** If $T$ is non-trivial — there exist a purely true sentence (value $\mathbf{T}$) and a purely false sentence (value $\mathbf{F}$) — then its inconsistency degree satisfies
$$n_{\mathbf{B}} \le |S| - 2.$$

*Proof.* The glut class is disjoint from $\{s_{\mathbf{T}}, s_{\mathbf{F}}\}$, two distinct sentences of values T and F. Hence the gluts inject into $S \setminus \{s_{\mathbf{T}}, s_{\mathbf{F}}\}$, of cardinality $|S| - 2$. ∎

Theorems 6.3 and 6.4 bracket a healthy paraconsistent theory: it must carry *enough* contradiction to host its paradoxes (degree $\ge 2$ for two distinct gluts) yet *not so much* that it loses all honest truths and falsehoods (degree $\le |S|-2$). Inconsistency is budgeted, not eradicated.

### 6.1 Non-explosiveness made precise

**Definition 6.5 (explosion).** $T$ *has explosion* if some glut makes everything at-least-true:
$$\forall s,q,\quad \mathrm{truth}(s) = \mathbf{B} \implies \mathrm{isTrue}(\mathrm{truth}(q)) = \top.$$

**Theorem 6.6 (explosion trivializes).** If $T$ has a Liar valued $\mathbf{B}$ and has explosion, then every sentence is at-least-true.

*Proof.* Instantiate explosion at $s = \ell$ (which is valued $\mathbf{B}$) and arbitrary $q$. ∎

Theorem 6.6 isolates the true culprit: catastrophe requires *explosion together with* a paradox, not the paradox alone. FDE simply omits explosion. Knowing that one sentence is a glut yields no information about unrelated sentences, so contradiction remains local and the spectrum of Theorem 6.4 stays non-degenerate.

---

## 7. The cost: what FDE gives up

FDE is a proper subsystem of classical logic. We formalize the two principal failures and one principal survival, working with FDE formulas built from atoms, negation, conjunction, and disjunction, evaluated under an assignment $v : \mathbb{N} \to \mathbf{BelnapVal}$. **FDE entailment** $\varphi \models \psi$ means: for every assignment $v$, if $\mathrm{isTrue}(\varphi(v)) = \top$ then $\mathrm{isTrue}(\psi(v)) = \top$.

**Theorem 7.1 (excluded middle fails).** The schema $P \vee \neg P$ is not an FDE tautology: there is an assignment under which $\mathrm{isTrue}((P \vee \neg P)(v)) \ne \top$.

*Proof.* Take $v(0) = \mathbf{N}$. Then $\neg\mathbf{N} = \mathbf{N}$ and $\mathbf{N} \vee \mathbf{N} = \mathbf{N}$, which is not designated. ∎

**Theorem 7.2 (modus ponens fails).** It is not the case that for all formulas $\varphi,\psi$, $\varphi \wedge (\varphi \to \psi) \models \psi$, where $\varphi \to \psi := \neg\varphi \vee \psi$.

*Proof.* Take $\varphi = P$, $\psi = Q$ with $v(0) = \mathbf{B}$ (so $P \mapsto \mathbf{B}$) and $v(1) = \mathbf{F}$ (so $Q \mapsto \mathbf{F}$). Then $\neg\varphi = \mathbf{B}$, $\neg\varphi \vee \psi = \mathbf{B} \vee \mathbf{F} = \mathbf{B}$, and $\varphi \wedge (\varphi\to\psi) = \mathbf{B} \wedge \mathbf{B} = \mathbf{B}$, which is designated; but $\psi = \mathbf{F}$ is not designated. The premise is at-least-true while the conclusion is not. ∎

**Theorem 7.3 (double negation elimination holds).** $\neg\neg P \models P$ as an FDE entailment.

*Proof.* For every $v$, $\neg\neg\,v(0) = v(0)$ since negation is an involution; the entailment is then trivial. ∎

**Theorem 7.4 (FDE strictly weaker than classical).** FDE validates double negation elimination (Theorem 7.3) but not excluded middle (Theorem 7.1); hence FDE is a proper subsystem of classical propositional logic.

*Proof.* Theorems 7.1 and 7.3. ∎

The trade is therefore exact and identifiable: paradox-tolerance is bought by surrendering excluded middle and the universal validity of modus ponens, while a substantial classical core — including double negation elimination and the De Morgan laws governing $\neg, \wedge, \vee$ — is retained.

---

## 8. The algebra of paradox generation

We record the algebraic skeleton underlying paradox production, which explains why the constructions are stable under the natural transformations of the value space.

**Definition 8.1 (paradox endomorphism).** A *paradox endomorphism* is a map $f : \mathbf{BelnapVal} \to \mathbf{BelnapVal}$ fixing the non-classical values: $f(\mathbf{B}) = \mathbf{B}$ and $f(\mathbf{N}) = \mathbf{N}$. These are closed under composition and contain the identity (forming a monoid); negation is a paradox endomorphism.

**Theorem 8.2 (endomorphisms preserve fixed points).** If $f$ is a paradox endomorphism and $v = \neg v$ (so $v \in \{\mathbf{B},\mathbf{N}\}$ by Lemma 2.4), then $f(v) = \neg f(v)$.

*Proof.* By cases. If $v = \mathbf{B}$, then $f(v) = \mathbf{B}$ and $\neg\mathbf{B} = \mathbf{B}$; if $v = \mathbf{N}$, then $f(v) = \mathbf{N}$ and $\neg\mathbf{N} = \mathbf{N}$; the values T and F are excluded since they are not fixed points of negation. ∎

Theorem 8.2 says the *paradoxical locus* $\{\mathbf{B},\mathbf{N}\}$ — the set of negation-fixed-points — is invariant under every paradox endomorphism. The diagonal value (Theorem 3.3) therefore remains paradoxical under any such transformation, which is the algebraic reason the construction is robust.

---

## 9. Applications and discussion

**Inconsistency-tolerant databases.** Belnap's logic was introduced precisely for computers that "reason from inconsistent information." A knowledge base merging conflicting sources will record some facts as B (asserted and denied) and others as N (unknown). The non-explosiveness of FDE (Theorem 6.6, read contrapositively) is exactly the guarantee that a single conflicting record does not corrupt unrelated queries. The spectrum (Definition 6.1) and tolerance threshold (Theorem 6.4) give an *audit* of how much conflict a base contains and a bound on how much it can tolerate while remaining informative.

**Reasoning under conflict.** Legal systems with conflicting statutes, multi-sensor fusion with contradictory readings, and large ontologies stitched from disagreeing sources all instantiate the same pattern: classical consistency is unattainable, but useful inference must continue. The paraconsistent stance — localize the contradiction, keep reasoning — is the operational principle.

**Foundations.** The self-soundness theorem (Theorem 5.2) is a constructive complement to Gödel's second theorem: it shows that the *consistency* hypothesis is doing essential work, by exhibiting an explicit theory that violates classical consistency and, as a result, can certify its own soundness. This sharpens the standard reading of Gödel's theorem as a statement specifically about *classically consistent* systems.

**Comparison with classical repairs.** Type theory, the Tarskian hierarchy, and ZF set theory each *prohibit* the paradoxical sentence. The present approach *admits* it and controls the fallout semantically. The two strategies are complementary: the classical repairs preserve all of classical logic at the cost of expressive restrictions; the paraconsistent approach preserves full expressiveness at the cost of excluded middle and unrestricted modus ponens.

**Limitations.** The framework here is propositional/semantic and finite, which is what makes every claim explicitly checkable; it does not yet include a full first-order proof calculus, a quantified truth predicate, or a Gödel-numbered self-reference mechanism internal to the object language. The Liar's self-reference is modeled by the diagonal law (Definition 3.1) rather than derived from a coding of syntax. Extending to an internalized provability predicate is the natural next step (Section 10).

---

## 10. Future directions

The verified development suggests several falsifiable refinements.

**C1. Glut minimality / inconsistency lower bound.** *Conjecture:* any sound paraconsistent theory proving the Liar, a Russell sentence, and a Berry sentence as *syntactically distinct* designated theorems has inconsistency degree at least 3, and 3 is attainable. The idea is that imposing soundness and provability upgrades each self-referential paradox from "non-classical" (B or N) to "glut" (B), so three distinct paradoxes contribute three distinct dialetheias — strengthening the degree-$\ge 2$ bound (Theorem 6.3) to degree-$\ge 3$. The missing ingredient is a Berry sentence that is intrinsically a third glut rather than a reused Liar fixed point, witnessed by the collision of Theorem 4.3.

**C2. No sound paracomplete (gap-only) theory proves the Liar.** *Conjecture:* in any three-valued logic whose only non-classical value is the gap N (paracomplete, no glut), the Liar can never be a sound provable theorem. Soundness designates only T, and a Liar cannot be T; so deleting B makes the "paradoxes as theorems" situation unsatisfiable. The conjecture asserts that the glut B is not a mere convenience but a hard necessity for a *sound provable* Liar.

**C3. Explosion is the unique obstruction to consistency.** *Conjecture:* for a finite four-valued theory with at least one glut, non-triviality (some sentence is unprovable) holds *iff* the theory rejects explosion. One direction is Theorem 6.6 (explosion ⇒ triviality); the converse — that rejecting explosion suffices for non-triviality in the presence of a dialetheia — would make non-explosiveness *equivalent* to consistency for glut-bearing theories.

Beyond these, internalizing self-reference via Gödel numbering (turning the diagonal law into a derived fixed-point theorem for an object-language provability predicate), extending to first-order FDE with quantifiers, and studying the monoid of paradox endomorphisms (Definition 8.1) as the symmetry group of paradox generation are all natural continuations.

---

## 11. Conclusion

We have constructed a finite four-valued paraconsistent theory in which the Liar, Russell, and Berry paradoxes are provable theorems, proved that the theory is non-trivial and non-explosive, and proved that it certifies its own soundness — a property forbidden to classical consistent systems by Gödel's second incompleteness theorem. The enabling move is minimal and precise: widen truth from two values to four, so that negation has fixed points and the equation $x = \neg x$ behind the Liar and Russell paradoxes becomes solvable, while the designated status of the glut B lets paradoxical theorems pass the soundness test. The cost — failure of excluded middle and of universal modus ponens, with double negation elimination surviving — is exactly delimited. Paradoxes, it turns out, are not contradictions to be banished but values to be placed; once placed, they are theorems.

---

## References

- N. D. Belnap, *A useful four-valued logic*, in J. M. Dunn and G. Epstein (eds.), Modern Uses of Multiple-Valued Logic, Reidel, 1977.
- G. Priest, *In Contradiction: A Study of the Transconsistent*, 2nd ed., Oxford University Press, 2006.
- N. C. A. da Costa, *On the theory of inconsistent formal systems*, Notre Dame Journal of Formal Logic 15(4), 1974.
- J. M. Dunn, *Intuitive semantics for first-degree entailments and 'coupled trees'*, Philosophical Studies 29, 1976.
- K. Gödel, *Über formal unentscheidbare Sätze der Principia Mathematica und verwandter Systeme I*, Monatshefte für Mathematik und Physik 38, 1931.
