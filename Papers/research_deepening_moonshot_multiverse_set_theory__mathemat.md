# The Modal Logic of Forcing in a Combinatorial Multiverse

## Abstract

We develop a self-contained combinatorial model of the set-theoretic multiverse in the sense of Hamkins, and use it to derive the modal logic of forcing from first principles. A *world* is abstracted to a truth assignment on a type of atomic set-theoretic assertions (such as the Continuum Hypothesis $\mathrm{CH}$, the axiom of constructibility $V=L$, and the existence of a measurable cardinal); a *sentence* is a propositional combination of atoms; a *multiverse* is a collection of worlds. Forcing is modelled by the operation that toggles a single atom, and a multiverse is *forcing-closed* when it is stable under all such toggles. Our first main result is that in any nonempty forcing-closed multiverse every atomic assertion is independent — forcing settles nothing. We then equip the multiverse with a Kripke accessibility relation by declaring two worlds mutually accessible when they disagree on only finitely many atoms, the combinatorial signature of a generic extension. We prove that this relation is an equivalence relation and that, over it, the necessity operator ($\Box p$ = "$p$ holds in every reachable world") and possibility operator ($\Diamond p$ = "$p$ holds in some reachable world") satisfy the full $\mathbf{S5}$ suite: the duality $\Diamond p \leftrightarrow \neg\Box\neg p$, Necessitation, and the axioms $\mathbf K$, $\mathbf T$, $\mathbf 4$, $\mathbf B$, $\mathbf 5$, together with Hamkins' Maximality Principle $\Diamond\Box p \to \Box p$. Every atom is shown to be a *switch* — possible and refutable from every world — so that no atom is ever necessary; specialized to the Gödel–Cohen two-world multiverse this recovers the classical independence and non-necessity of $\mathrm{CH}$. All results are established rigorously.

**Keywords:** set-theoretic multiverse, forcing, Continuum Hypothesis, modal logic, Kripke semantics, $\mathbf{S5}$, Maximality Principle, independence.

---

## 1. Introduction

The independence phenomenon is the defining feature of modern set theory. Gödel (1938) showed the Continuum Hypothesis $\mathrm{CH}$ is consistent with $\mathrm{ZFC}$ by constructing the inner model $L$ of constructible sets; Cohen (1963) showed $\neg\mathrm{CH}$ is consistent by inventing *forcing*, a method for building generic extensions of a model in which a designated statement is decided as desired. Together these results place $\mathrm{CH}$ beyond the reach of the standard axioms.

Hamkins' *multiverse* program reinterprets this situation not as a limitation but as ontology: there is no single privileged universe of sets, but a plurality of set-theoretic universes, related to one another by forcing and other model-building operations, and a statement such as $\mathrm{CH}$ simply takes different truth values across the plurality. A striking technical outcome of the program is that forcing carries an intrinsic *modal* character. Reading "possibly $p$" as "$p$ holds in some forcing extension" and "necessarily $p$" as "$p$ holds in every forcing extension" turns the class of universes into a Kripke frame, and one may ask which propositional modal principles are valid.

This paper isolates the *combinatorial core* of that picture and carries the modal analysis through completely in an elementary, fully rigorous setting. We deliberately abstract away the internal structure of models of $\mathrm{ZFC}$, retaining only what distinguishes universes for the purpose of independence: their answers to a chosen family of atomic questions. In this abstraction forcing becomes the flip of a single truth value, and the modal logic of forcing becomes a theorem of propositional modal logic derived from the frame conditions of the forcing relation. The result is a bridge: the object of study is set-theoretic forcing, but the conclusions are clean modal-logical identities.

### Contributions

1. A precise combinatorial model of the multiverse: worlds as truth assignments, sentences as propositional formulas, multiverses as sets of worlds, with the three-way classification of each sentence as valid, refutable, or independent (Section 2).
2. The absoluteness of propositional logical validities across every multiverse, contrasted with the independence of atoms (Section 3).
3. A model of forcing as atom-flipping, the notion of a forcing-closed multiverse, and the theorem that in any nonempty forcing-closed multiverse every atom is independent (Section 4).
4. The Gödel–Cohen two-world multiverse, recovering the classical independence of $\mathrm{CH}$ and $V=L$, the validity of $V=L\to\mathrm{CH}$, and the persistence of $\mathrm{CH}$'s independence under adoption of that implication as a law (Section 5).
5. The Kripke accessibility relation of finite disagreement, its proof of being an equivalence relation, and the full $\mathbf{S5}$ modal suite plus the Maximality Principle for the forcing modalities, together with the switch/non-necessity phenomenon for atoms and its concrete instance at Gödel's universe (Section 6).

---

## 2. The combinatorial multiverse

Throughout, $\alpha$ is a type of *atomic assertions*.

**Definition 2.1 (Sentence).** The set $\mathrm{Sentence}(\alpha)$ of *sentences over $\alpha$* is generated inductively by: an atom $\mathrm{atom}(a)$ for each $a:\alpha$; the constants $\top$ and $\bot$; negation $\neg p$; conjunction $p\land q$; disjunction $p\lor q$; and implication $p\to q$.

**Definition 2.2 (World).** A *world* is a truth assignment $w:\alpha\to\{\mathrm{true},\mathrm{false}\}$. We write $\mathrm{World}(\alpha)$ for the type of worlds.

**Definition 2.3 (Evaluation and satisfaction).** The Boolean value $\mathrm{eval}_w(p)$ of a sentence $p$ in a world $w$ is defined by recursion in the usual way: $\mathrm{eval}_w(\mathrm{atom}(a)) = w(a)$; $\mathrm{eval}_w(\top)=\mathrm{true}$; $\mathrm{eval}_w(\bot)=\mathrm{false}$; $\mathrm{eval}_w(\neg p) = \lnot\,\mathrm{eval}_w(p)$; and the binary connectives evaluate by the corresponding Boolean operations, with $\mathrm{eval}_w(p\to q)=\lnot\,\mathrm{eval}_w(p)\lor\mathrm{eval}_w(q)$. We say $w$ *satisfies* $p$, written $w\models p$, when $\mathrm{eval}_w(p)=\mathrm{true}$.

The satisfaction relation obeys the expected clauses, each an immediate consequence of the definition: $w\models\mathrm{atom}(a)\iff w(a)=\mathrm{true}$; $w\models\top$; $w\not\models\bot$; $w\models\neg p\iff w\not\models p$; $w\models p\land q\iff (w\models p)\land(w\models q)$; $w\models p\lor q\iff(w\models p)\lor(w\models q)$; and $w\models p\to q\iff(w\models p\Rightarrow w\models q)$.

**Definition 2.4 (Multiverse).** A *multiverse* is a set $M\subseteq\mathrm{World}(\alpha)$ of worlds.

**Definition 2.5 (Validity, refutability, independence, settledness).** Fix a multiverse $M$ and a sentence $p$.
- $p$ is *valid* in $M$, written $M\models p$, if $w\models p$ for every $w\in M$.
- $p$ is *refutable* in $M$ if $w\not\models p$ for every $w\in M$.
- $p$ is *independent* in $M$ if there exist $w_1,w_2\in M$ with $w_1\models p$ and $w_2\not\models p$.
- $p$ is *settled* in $M$ if it is valid or refutable in $M$.

These notions are related by elementary but useful facts. An independent sentence is neither valid nor refutable, hence not settled; a valid sentence is never independent. Independence is invariant under negation: $p$ is independent in $M$ if and only if $\neg p$ is.

**Proposition 2.6 (Cardinality of the full world space).** If $\alpha$ is finite with $|\alpha| = n$, then the number of worlds is $|\mathrm{World}(\alpha)| = 2^{n}$.

*Proof.* A world is a function $\alpha\to\{\mathrm{true},\mathrm{false}\}$ from an $n$-element set into a $2$-element set, and there are $2^{n}$ such functions. $\qquad\blacksquare$

---

## 3. Absoluteness of logic

Some sentences are settled in *every* multiverse because they are true in every world. These are the propositional logical validities, and they form the immovable substrate against which independence is measured.

**Theorem 3.1 (Absolute validities).** For every multiverse $M$ and every sentence $p$:
1. (Excluded middle) $M\models p\lor\neg p$;
2. (Non-contradiction) $M\models \neg(p\land\neg p)$;
3. (Self-implication) $M\models p\to p$.

*Proof.* Each holds worldwise. In any world $w$, exactly one of $w\models p$ or $w\not\models p$ holds, giving (1) directly and (2) as its contrapositive form; and $w\models p\Rightarrow w\models p$ gives (3). Since each holds in every $w\in M$, each is valid in $M$. $\qquad\blacksquare$

These absolute validities are the qualitative opposite of the atoms studied below: no choice of worlds can make them fail, whereas — as we show next — the atoms cannot be settled at all once forcing is admitted.

---

## 4. Forcing as atom-flipping

We now model the essential combinatorial content of forcing. A generic extension decides a target assertion the opposite way while, in our abstraction, leaving everything else fixed.

**Definition 4.1 (Generic extension / flip).** For a world $w$ and an atom $a$ (with decidable equality on $\alpha$), the *generic extension of $w$ along $a$* is the world
$$\mathrm{flip}(w,a)(x) = \begin{cases} \lnot\,w(a) & x = a,\\ w(x) & x\ne a. \end{cases}$$

Immediately $\mathrm{flip}(w,a)(a) = \lnot w(a)$ and $\mathrm{flip}(w,a)(x) = w(x)$ for $x\ne a$, so
$$\mathrm{flip}(w,a)\models\mathrm{atom}(a)\iff w\not\models\mathrm{atom}(a).$$
Flipping toggles satisfaction of exactly the targeted atom.

**Definition 4.2 (Forcing-closed multiverse).** A multiverse $M$ is *forcing-closed* if it is stable under generic extensions: for all $w\in M$ and all atoms $a$, $\mathrm{flip}(w,a)\in M$.

This condition abstracts Hamkins' multiverse axioms asserting that each universe possesses the forcing extensions realizing the alternatives to its forceable statements.

**Theorem 4.3 (Forcing settles no atom).** In any nonempty forcing-closed multiverse $M$, every atomic sentence $\mathrm{atom}(a)$ is independent.

*Proof.* Pick $w\in M$ (nonemptiness). By forcing-closure $\mathrm{flip}(w,a)\in M$. If $w(a)=\mathrm{true}$, then $w\models\mathrm{atom}(a)$ while $\mathrm{flip}(w,a)\not\models\mathrm{atom}(a)$; if $w(a)=\mathrm{false}$, the two roles are exchanged. Either way $\mathrm{atom}(a)$ is true in one world of $M$ and false in another, hence independent. $\qquad\blacksquare$

**Corollary 4.4.** In a nonempty forcing-closed multiverse no atom is settled.

**The full multiverse.** The *full multiverse* over $\alpha$ is $\mathrm{Full}(\alpha) = \mathrm{World}(\alpha)$, the set of all worlds. It is nonempty (whenever a world exists) and forcing-closed, since it contains every world and in particular every flip. Consequently every atom is independent in $\mathrm{Full}(\alpha)$. More is true: for distinct atoms $a\ne b$ the conjunction $\mathrm{atom}(a)\land\neg\,\mathrm{atom}(b)$ has a model in $\mathrm{Full}(\alpha)$ (take the world assigning $\mathrm{true}$ exactly to $a$), while some world falsifies it; so all joint truth-value combinations of distinct atoms are realized.

---

## 5. The Gödel–Cohen multiverse

We instantiate the framework with three atoms and the two canonical universes, and verify that the classical facts are reproduced.

**Definition 5.1.** Let $\alpha = \{\mathrm{CH}, V{=}L, \mathrm{Meas}\}$, where $\mathrm{Meas}$ denotes "there exists a measurable cardinal." Define two worlds:
$$\text{G\"odel: } \mathrm{CH}\mapsto\mathrm{true},\ V{=}L\mapsto\mathrm{true},\ \mathrm{Meas}\mapsto\mathrm{false};$$
$$\text{Cohen: } \mathrm{CH}\mapsto\mathrm{false},\ V{=}L\mapsto\mathrm{false},\ \mathrm{Meas}\mapsto\mathrm{false}.$$
The world "Gödel" represents the constructible universe $L$, in which $V=L$ holds and therefore $\mathrm{CH}$ holds and there is no measurable cardinal; "Cohen" represents a forcing extension refuting $\mathrm{CH}$ (and hence $V=L$). Let $GC = \{\text{Gödel}, \text{Cohen}\}$.

**Theorem 5.2 (Independence of $\mathrm{CH}$).** $\mathrm{atom}(\mathrm{CH})$ is independent in $GC$: it is true in the Gödel world and false in the Cohen world.

*Proof.* By the definitions, Gödel$\models\mathrm{CH}$ and Cohen$\not\models\mathrm{CH}$. $\qquad\blacksquare$

**Theorem 5.3 (Independence of $V=L$).** $\mathrm{atom}(V{=}L)$ is independent in $GC$.

*Proof.* Gödel$\models V{=}L$ and Cohen$\not\models V{=}L$. $\qquad\blacksquare$

**Theorem 5.4 (Constructibility entails $\mathrm{CH}$).** The implication $V{=}L\to\mathrm{CH}$ is valid in $GC$.

*Proof.* Check both worlds. In the Gödel world both antecedent and consequent are $\mathrm{true}$; in the Cohen world the antecedent is $\mathrm{false}$, so the implication is vacuously $\mathrm{true}$. $\qquad\blacksquare$

Thus a compound sentence can be settled while each of its atoms is independent. We can even promote such a settled implication to a *law*.

**Definition 5.5 (Law multiverse).** Let $\mathrm{Law} = \{\, w : w\models (V{=}L\to\mathrm{CH})\,\}$ be the multiverse of worlds obeying the implication.

Both Gödel and Cohen belong to $\mathrm{Law}$ (the former satisfies the implication because both sides are true, the latter because the antecedent is false).

**Theorem 5.6 (Robustness of independence under law-adoption).** $\mathrm{atom}(\mathrm{CH})$ is independent in $\mathrm{Law}$.

*Proof.* Gödel and Cohen both lie in $\mathrm{Law}$, and they disagree on $\mathrm{CH}$. $\qquad\blacksquare$

Adopting the true principle $V=L\to\mathrm{CH}$ constrains the multiverse but does not decide $\mathrm{CH}$: it removes only worlds satisfying $V=L\land\neg\mathrm{CH}$, of which there are none among the classical witnesses. Finally, over the full three-atom multiverse we noted the count $|\mathrm{World}(\alpha)| = 2^{3} = 8$, and the sentence $\mathrm{CH}\land\neg(V{=}L)$ — a Cohen-style extension adding non-constructible reals while retaining $\mathrm{CH}$ — has a model there.

---

## 6. The modal logic of forcing

We now equip the multiverse with the Kripke structure that turns forcing into modality. The key modelling decision is the accessibility relation.

**Definition 6.1 (Forcing accessibility / reachability).** Two worlds $w,v$ are *reachable from one another*, written $w\sim v$, when they disagree on only finitely many atoms:
$$w\sim v \quad\Longleftrightarrow\quad \{\,x : w(x)\ne v(x)\,\}\ \text{is finite}.$$

The motivation is that a generic extension alters only *finitely much* information; two universes obtainable from one another by (iterated) forcing therefore differ in a finite amount of data. In the abstraction this becomes finite disagreement of answer sheets.

**Theorem 6.2 (Reachability is an equivalence relation).**
1. (Reflexivity) $w\sim w$;
2. (Symmetry) if $w\sim v$ then $v\sim w$;
3. (Transitivity) if $w\sim v$ and $v\sim u$ then $w\sim u$.

*Proof.* (1) The disagreement set $\{x : w(x)\ne w(x)\}$ is empty, hence finite. (2) The sets $\{x : v(x)\ne w(x)\}$ and $\{x : w(x)\ne v(x)\}$ are equal. (3) If $w(x)\ne u(x)$ then $w(x)\ne v(x)$ or $v(x)\ne u(x)$, so the disagreement set of $w,u$ is contained in the union of the disagreement sets of $w,v$ and of $v,u$; a subset of a finite set (a union of two finite sets) is finite. $\qquad\blacksquare$

Two basic moves land in accessible worlds: flipping a single atom, $w\sim\mathrm{flip}(w,a)$, and updating a single atom to a value $b$, $w\sim (w \text{ with } a\mapsto b)$; in each case the disagreement set is contained in $\{a\}$.

**Definition 6.3 (Modal operators).** For a multiverse $M$, a world $w\in\mathrm{World}(\alpha)$, and a sentence $p$:
- *Necessity*: $\Box_{M,w}\,p$ holds iff $v\models p$ for every $v\in M$ with $w\sim v$ — "$p$ holds in every reachable world," i.e. every forcing extension satisfies $p$.
- *Possibility*: $\Diamond_{M,w}\,p$ holds iff $v\models p$ for some $v\in M$ with $w\sim v$ — "$p$ holds in some reachable world," i.e. some forcing extension satisfies $p$.

**Theorem 6.4 (Duality).** $\Diamond_{M,w}\,p \iff \lnot\,\Box_{M,w}\,\neg p$.

*Proof.* If $\Diamond_{M,w}\,p$ is witnessed by $v$ with $v\models p$, then $\Box_{M,w}\,\neg p$ would give $v\models\neg p$, a contradiction; hence $\lnot\Box_{M,w}\,\neg p$. Conversely, if $\lnot\Box_{M,w}\,\neg p$, some reachable $v\in M$ fails $\neg p$, i.e. $v\models p$, witnessing $\Diamond_{M,w}\,p$. $\qquad\blacksquare$

The frame conditions of Theorem 6.2 now yield the standard modal axioms. Recall that reflexivity validates $\mathbf T$, transitivity validates $\mathbf 4$, symmetry validates $\mathbf B$, and an equivalence relation validates the whole of $\mathbf{S5}$.

**Theorem 6.5 (The $\mathbf{S5}$ suite).** For every multiverse $M$, world $w$, and sentences $p,q$:
1. (Necessitation) If $p$ is valid in $M$, then $\Box_{M,w}\,p$ for every $w$.
2. (Axiom $\mathbf K$) If $\Box_{M,w}(p\to q)$ and $\Box_{M,w}\,p$, then $\Box_{M,w}\,q$.
3. (Axiom $\mathbf T$, reflexivity) If $\Box_{M,w}\,p$ and $w\in M$, then $w\models p$.
4. (Axiom $\mathbf 4$, transitivity) If $\Box_{M,w}\,p$, then $\Box_{M,v}\,p$ for every $v\in M$ with $w\sim v$.
5. (Axiom $\mathbf B$, Brouwer) If $w\in M$ and $w\models p$, then $\Diamond_{M,v}\,p$ for every $v\in M$ with $w\sim v$.
6. (Axiom $\mathbf 5$, Euclidean) If $\Diamond_{M,w}\,p$, then $\Diamond_{M,v}\,p$ for every $v\in M$ with $w\sim v$.

*Proof.* (1) If $p$ is valid then every $v\in M$ satisfies $p$, a fortiori every reachable one. (2) For reachable $v\in M$, the hypotheses give $v\models p\to q$ and $v\models p$, hence $v\models q$. (3) Reflexivity gives $w\sim w$, so $\Box_{M,w}\,p$ applied to $w$ yields $w\models p$. (4) For $v$ reachable from $w$ and $u\in M$ reachable from $v$, transitivity gives $w\sim u$, so $\Box_{M,w}\,p$ yields $u\models p$; thus $\Box_{M,v}\,p$. (5) Given $v$ reachable from $w$, symmetry gives $v\sim w$; the world $w$ itself is then a reachable witness in $M$ with $w\models p$, so $\Diamond_{M,v}\,p$. (6) Let $u\in M$ with $w\sim u$ and $u\models p$ witness $\Diamond_{M,w}\,p$. For $v$ reachable from $w$, symmetry and transitivity give $v\sim u$, so $u$ also witnesses $\Diamond_{M,v}\,p$. $\qquad\blacksquare$

**Theorem 6.6 (Maximality Principle).** If there is a world $v\in M$ with $w\sim v$ and $\Box_{M,v}\,p$, then $\Box_{M,w}\,p$. Equivalently, $\Diamond\Box p \to \Box p$.

*Proof.* Let $u\in M$ be reachable from $w$. By symmetry $v\sim w$, and with $w\sim u$ transitivity gives $v\sim u$; then $\Box_{M,v}\,p$ yields $u\models p$. As $u$ was arbitrary, $\Box_{M,w}\,p$. $\qquad\blacksquare$

The Maximality Principle is the modal signature of $\mathbf{S5}$: a statement that is *possibly necessary* is necessary. In set-theoretic terms, if forcing can secure $p$ permanently in some extension, $p$ is already settled throughout the forcing-equivalence class.

### 6.1 Atoms are switches

**Theorem 6.7 (Switch property).** In the full multiverse, for every world $w$ and every atom $a$, both $\Diamond_{\mathrm{Full},w}\,\mathrm{atom}(a)$ and $\Diamond_{\mathrm{Full},w}\,\neg\,\mathrm{atom}(a)$ hold.

*Proof.* Update $w$ at $a$ to $\mathrm{true}$: the resulting world is reachable (disagreement set $\subseteq\{a\}$), lies in the full multiverse, and satisfies $\mathrm{atom}(a)$. Updating instead to $\mathrm{false}$ produces a reachable world satisfying $\neg\,\mathrm{atom}(a)$. $\qquad\blacksquare$

**Corollary 6.8 (No atom is necessary).** In the full multiverse, $\lnot\,\Box_{\mathrm{Full},w}\,\mathrm{atom}(a)$ for every $w$ and $a$.

*Proof.* By Theorem 6.7 there is a reachable world satisfying $\neg\,\mathrm{atom}(a)$, i.e. failing $\mathrm{atom}(a)$; this refutes necessity. $\qquad\blacksquare$

### 6.2 Concrete forcing modalities at Gödel's universe

Specializing to $GC = \{\text{Gödel}, \text{Cohen}\}$: the two worlds differ only on $\mathrm{CH}$ and $V=L$, a finite amount of information, so they are reachable, $\text{Gödel}\sim\text{Cohen}$.

**Theorem 6.9 ($\mathrm{CH}$ is not necessary at Gödel's universe).** $\lnot\,\Box_{GC,\text{Gödel}}\,\mathrm{atom}(\mathrm{CH})$.

*Proof.* Cohen is reachable from Gödel and lies in $GC$, yet Cohen$\not\models\mathrm{CH}$; so necessity fails. $\qquad\blacksquare$

Correspondingly $\mathrm{CH}$ is possible at Gödel's universe (witnessed by Gödel itself) and $\neg\mathrm{CH}$ is possible there (witnessed by Cohen). Standing in the constructible universe, where $\mathrm{CH}$ is true, forcing nevertheless reaches an extension in which it fails: $\mathrm{CH}$ is a switch, actually true yet not necessary.

---

## 7. Algorithms

The framework is entirely computable over finite atom sets, which makes every notion above decidable by finite search. We record the core procedures.

**Algorithm 7.1 (Independence test).** Given a finite multiverse $M$ (a list of worlds) and a sentence $p$, evaluate $p$ in each world; report *valid* if all values are $\mathrm{true}$, *refutable* if all are $\mathrm{false}$, and *independent* if both values occur. Complexity $O(|M|\cdot|p|)$.

**Algorithm 7.2 (Forcing-closure and modal evaluation).** For a finite atom set, enumerate the $2^{n}$ worlds; the full multiverse is trivially forcing-closed. To evaluate $\Box_{M,w}\,p$ (respectively $\Diamond_{M,w}\,p$) over a finite $M$, filter $M$ to the worlds reachable from $w$ (finite disagreement is automatic over a finite atom set) and test whether $p$ holds in all (respectively some) of them. Complexity $O(|M|\cdot|p|)$ per query.

**Algorithm 7.3 (Switch/button classifier).** For each atom $a$, test $\Diamond\,\mathrm{atom}(a)$ and $\Diamond\,\neg\,\mathrm{atom}(a)$ from a base world; classify $a$ as a *switch* if both hold and as a *button* (settled) otherwise. Over the full multiverse every atom is a switch.

---

## 8. Applications and discussion

**Independence made checkable.** The framework converts qualitative independence claims into finite verifications: to exhibit the independence of $\mathrm{CH}$ it suffices to display two worlds disagreeing on it and to confirm both belong to the multiverse. This is the combinatorial residue of the Gödel and Cohen theorems.

**Forcing as modality, rigorously.** By fixing the accessibility relation to be finite disagreement and proving it an equivalence relation, we obtain the $\mathbf{S5}$ logic of forcing as a consequence of frame conditions rather than as an external stipulation. The Maximality Principle, a landmark of the modal-forcing literature, drops out of symmetry-plus-transitivity.

**Absolute versus contingent.** The sharp separation between propositional validities (absolute across all multiverses) and atoms (never necessary in the full multiverse) formalizes the intuition that logic is invariant under forcing while set-theoretic content is not.

**Limitations.** The model is propositional: atoms are opaque and their internal set-theoretic meaning — the machinery of names, generic filters, and the definability of the forcing relation — is not represented. Entailments among atoms hold only when imposed as laws (Section 5). Consequently the model captures the *shape* of the multiverse and the modal logic of forcing, not the theory of forcing itself.

---

## 9. Future directions

This cycle deepened the combinatorial core of the set-theoretic multiverse by equipping it with a modal structure of forcing: possibility as truth in some generic extension, necessity as truth in every generic extension. Modelling a generic extension as a change of only finitely much information yields a Kripke frame whose accessibility relation is an equivalence, and over that frame the whole $\mathbf{S5}$ suite ($\mathbf T$, $\mathbf 4$, $\mathbf B$, $\mathbf 5$) together with the Maximality Principle is derivable, while every atomic set-theoretic assertion — the Continuum Hypothesis included — turns out to be a switch that forcing can toggle at will. Three directions extend the picture.

**1. The forcing order is genuinely $\mathbf{S4.2}$, not $\mathbf{S5}$.** If accessibility is taken to be the *directed but antisymmetric* extension order (a world accesses exactly its own forcing extensions, never its grounds), the resulting modal logic should be exactly $\mathbf{S4.2}$: it validates $\mathbf T$, $\mathbf 4$, and the directedness axiom $\Diamond\Box p\to\Box\Diamond p$, but refutes both the Brouwer axiom $\mathbf B$ and the Euclidean axiom $\mathbf 5$. Symmetry is the single frame condition responsible for the collapse to $\mathbf{S5}$; dropping it while retaining directedness — the true combinatorics of iterated forcing — should land precisely on the Hamkins–Löwe value $\mathbf{S4.2}$. The finite-information equivalence relation is already in place; intersecting it with a monotone information order yields the directed order, so the two logics can be compared inside a single frame.

**2. A dichotomy of buttons and switches.** In any directed forcing frame every atom should be either a *switch* (both it and its negation possible from every world) or a *button* (once true, necessarily true); the buttons should be exactly the assertions monotone along the extension order, and should generate a distributive lattice under conjunction and disjunction. The switch/button distinction would then be a lattice-theoretic invariant of the accessibility order: buttons are the fixed points of the necessity operator, switches its strictly non-trivial orbits.

**3. Independence is closed under Boolean law-adoption up to a rank bound.** Adopting finitely many implications among atoms as laws of the multiverse (restricting to worlds that obey them) should leave an atom independent unless the laws *entail* a definite truth value for it; and the number of atoms that become settled should be exactly the number forced by unit propagation on the adopted implications.

---

## 10. Conclusion

Abstracting a model of set theory to its answers on a chosen family of questions renders the independence phenomenon finite and the modal logic of forcing elementary. Forcing becomes the flip of a switch; the multiverse becomes a Kripke frame under finite disagreement; and the equivalence-relation structure of that frame yields the complete $\mathbf{S5}$ modal logic together with the Maximality Principle. The Continuum Hypothesis appears not as an unanswerable question but as a switch — true in some worlds, false in others, never necessary — with forcing as the road between the settings.
