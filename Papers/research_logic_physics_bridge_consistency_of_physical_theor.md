# Consistency of Physical Theories as a Proof-Theoretic Question

## Abstract

We separate three notions that are frequently conflated in foundational discussions: physical consistency, understood as existence of a realization in a designated semantics; mathematical consistency, understood as non-derivability of contradiction; and arithmetic independence of an encoded consistency sentence. For a sound semantics, physical consistency implies mathematical consistency. The converse fails, even when the semantics is sound, because syntactic non-contradiction does not supply a realizing world. We then give precise sufficient conditions under which the consistency sentence of an arithmetically represented physical theory $T$ is independent of Peano arithmetic $\mathrm{PA}$. Besides the standard provability conditions and consistency of $\mathrm{PA}$, the argument requires an internal reflection implication $\operatorname{Con}(T)\to\operatorname{Con}(\mathrm{PA})$ and a soundness condition excluding a $\mathrm{PA}$-proof that $T$ proves contradiction. We prove both halves of independence and exhibit a consistent modal system in which independence fails, showing that consistency alone is insufficient. The resulting framework identifies the exact logical interfaces needed to turn physical realizability into a valid proof-theoretic claim.

## 1. Introduction

Claims about the “consistency of physics” can refer to importantly different objects. One claim says that a deductive calculus cannot derive contradiction. Another says that the theory’s constraints are jointly realized by a physically admissible world. A third says that a background arithmetical theory can neither prove nor refute the sentence asserting the theory’s syntactic consistency. These claims live, respectively, at syntactic, semantic, and metamathematical levels.

The distinctions become essential when invoking Gödelian incompleteness. The unrestricted assertion

$$
T\text{ is consistent}\quad\Longrightarrow\quad
\operatorname{Con}(T)\text{ is independent of }\mathrm{PA}
$$

is not valid. Gödel’s second incompleteness theorem prevents a suitable consistent theory from proving its *own* consistency. It does not by itself prevent that theory from deciding the consistency of an arbitrary external theory. To pass from $\operatorname{Con}(T)$ to $\operatorname{Con}(\mathrm{PA})$, one needs a reflection or interpretability bridge. To prevent $\mathrm{PA}$ from proving $\neg\operatorname{Con}(T)$, one also needs enough soundness to exclude a false arithmetic assertion that a contradiction proof exists in $T$.

This paper formulates those interfaces abstractly. The framework is applicable to any effectively presented physical calculus; quantum field theory supplies the motivating case but no specific field-theoretic axiom system is assumed. This level of abstraction has two advantages. It isolates the logical content of the argument, and it makes clear what additional work would be required for a concrete physical theory.

The principal results are:

1. under semantic soundness, physical realizability implies syntactic consistency;
2. syntactic consistency does not imply physical realizability, even for sound semantics;
3. under explicit derivability, consistency, reflection, and contradiction-proof soundness assumptions, $\operatorname{Con}(T)$ is independent of $\mathrm{PA}$;
4. consistency of the ambient proof system alone does not force such independence.

## 2. Deductive and semantic foundations

### 2.1 Proof systems and theories

Let $L$ be a type or set of sentences. A **proof system** $P$ determines a derivability relation $T\vdash_P\varphi$, where $T\subseteq L$ is a theory and $\varphi\in L$. Fix a distinguished sentence $\bot\in L$ representing contradiction.

**Definition 2.1 (Mathematical consistency).** A theory $T$ is mathematically consistent relative to $P$ if

$$
T\nvdash_P\bot.
$$

This is a purely syntactic property. It quantifies over finite derivations admitted by $P$ and makes no assertion that any intended object realizes $T$.

### 2.2 Physical semantics

A **physical semantics** $\mathcal M$ consists of a class $W$ of admissible worlds and a satisfaction relation $w\models_{\mathcal M}\varphi$. Depending on the application, a world may be a state-space model, an operator-algebraic representation, a spacetime field configuration, or an operational theory of preparations and observations.

Write $w\models_{\mathcal M}T$ when $w\models_{\mathcal M}\varphi$ for every $\varphi\in T$.

**Definition 2.2 (Physical consistency).** A theory $T$ is physically consistent in $\mathcal M$ if

$$
\exists w\in W\; w\models_{\mathcal M}T.
$$

Thus physical consistency is an existence statement. It depends not only on the sentences of $T$ but also on the chosen class of admissible worlds.

**Definition 2.3 (Sound semantics).** The semantics $\mathcal M$ is sound for $P$ if, for every $T$ and $\varphi$,

$$
T\vdash_P\varphi
\quad\Longrightarrow\quad
\forall w\in W\,\bigl(w\models_{\mathcal M}T\to w\models_{\mathcal M}\varphi\bigr),
$$

and no admissible world satisfies $\bot$.

The second clause may instead be included in the meaning of contradiction. It is stated explicitly to expose the proof of the next theorem.

**Theorem 2.4 (Physical realizability implies mathematical consistency).** If $\mathcal M$ is sound for $P$ and $T$ is physically consistent in $\mathcal M$, then $T$ is mathematically consistent relative to $P$.

**Proof sketch.** Choose $w\in W$ satisfying every sentence of $T$. If $T\vdash_P\bot$, soundness gives $w\models_{\mathcal M}\bot$, contrary to the semantic clause for contradiction. Hence $T\nvdash_P\bot$. $\square$

### 2.3 Failure of the converse

**Theorem 2.5 (Mathematical consistency need not imply physical consistency).** There exist a proof system $P$, a sound semantics $\mathcal M$, and a theory $T$ such that

$$
T\nvdash_P\bot
\qquad\text{but}\qquad
\neg\exists w\in W\;w\models_{\mathcal M}T.
$$

**Proof sketch.** Take a proof system with a theory $T$ from which $\bot$ is not derivable, and choose an empty class $W$ of admissible worlds. Every semantic preservation implication is then true, so the semantics is sound, while no world realizes $T$. The example isolates the existential gap: non-derivability alone cannot create a model. $\square$

The empty-world witness is deliberately minimal. It shows that soundness alone cannot reverse Theorem 2.4. For physically richer applications one should demand $W\neq\varnothing$ and seek a finitely presented set of mutually unrealizable constraints. The logical point remains unchanged: a converse requires an appropriate completeness theorem, not merely soundness.

## 3. Provability and consistency sentences

### 3.1 Modal notation

Let $S$ be a proof system capable of reasoning about encoded proofs. Write

$$
\Box_U A
$$

for the sentence saying that theory $U$ proves $A$. The subscript records whose proofs are represented; the ambient system in which the sentence is proved may be different.

**Definition 3.1 (Consistency sentence).** The encoded consistency sentence of $U$ is

$$
\operatorname{Con}(U):=\neg\Box_U\bot.
$$

In classical implicational notation this is

$$
\operatorname{Con}(U):=\Box_U\bot\to\bot.
$$

**Definition 3.2 (Independence).** A sentence $A$ is independent of a proof system $S$ if

$$
S\nvdash A
\quad\text{and}\quad
S\nvdash\neg A.
$$

The two clauses are logically distinct. Incompleteness arguments addressing only the first do not establish independence.

### 3.2 Provability conditions

We assume the ambient system $S$ has a classical propositional calculus, modus ponens, and a provability operator satisfying the following principles.

1. **Necessitation:** if $S\vdash A$, then $S\vdash\Box_S A$.
2. **Löb principle:** for every $A$,
   $$
   S\vdash\Box_S(\Box_S A\to A)\to\Box_S A.
   $$
3. **Classical tautologies:** in particular, $S$ proves
   $$
   \neg\neg A\to A.
   $$

These assumptions abstract the standard derivability behavior of sufficiently strong arithmetical theories.

**Theorem 3.3 (Second incompleteness in provability form).** If $S$ satisfies the preceding provability principles and is consistent, then

$$
S\nvdash\operatorname{Con}(S).
$$

**Proof sketch.** Suppose $S\vdash\operatorname{Con}(S)$, that is,

$$
S\vdash\Box_S\bot\to\bot.
$$

By necessitation,

$$
S\vdash\Box_S(\Box_S\bot\to\bot).
$$

Applying the Löb principle with $A=\bot$ and then modus ponens gives $S\vdash\Box_S\bot$. A second application of modus ponens, now using the assumed proof of $\Box_S\bot\to\bot$, yields $S\vdash\bot$, contradicting consistency. $\square$

This proof makes the scope of the result transparent: it forbids $S$ from proving $\operatorname{Con}(S)$. Nothing here forbids $S$ from proving or refuting $\operatorname{Con}(T)$ for an unrelated theory $T$.

## 4. Conditions for arithmetic independence

Let $\mathrm{PA}$ denote Peano arithmetic, or more generally a fixed arithmetical proof system with the preceding provability structure. Let $T$ be an effectively represented physical theory.

**Definition 4.1 (Arithmetic independence bridge).** The pair $(\mathrm{PA},T)$ satisfies the arithmetic independence bridge when all four conditions hold:

1. $\mathrm{PA}$ satisfies necessitation, the Löb principle, modus ponens, and classical propositional reasoning for its provability predicate;
2. $\mathrm{PA}$ is consistent;
3. $\mathrm{PA}$ proves the reflection implication
   $$
   \operatorname{Con}(T)\to\operatorname{Con}(\mathrm{PA});
   $$
4. $\mathrm{PA}$ does not prove that $T$ proves contradiction:
   $$
   \mathrm{PA}\nvdash\Box_T\bot.
   $$

Condition 3 can arise from a proof interpretation that transfers any $\mathrm{PA}$-derivation of contradiction to a $T$-derivation of contradiction. Condition 4 is a restricted soundness requirement about the existential arithmetic claim that a coded contradiction proof exists in $T$.

**Theorem 4.2 (Independence of the physical theory’s consistency sentence).** If $(\mathrm{PA},T)$ satisfies the arithmetic independence bridge, then $\operatorname{Con}(T)$ is independent of $\mathrm{PA}$:

$$
\mathrm{PA}\nvdash\operatorname{Con}(T)
\qquad\text{and}\qquad
\mathrm{PA}\nvdash\neg\operatorname{Con}(T).
$$

**Proof sketch.** For the first clause, suppose $\mathrm{PA}\vdash\operatorname{Con}(T)$. By Condition 3 and modus ponens,

$$
\mathrm{PA}\vdash\operatorname{Con}(\mathrm{PA}),
$$

contradicting Theorem 3.3 using Conditions 1 and 2.

For the second clause, observe that

$$
\neg\operatorname{Con}(T)
=\neg\neg\Box_T\bot.
$$

If $\mathrm{PA}$ proved this sentence, classical double-negation elimination and modus ponens would yield $\mathrm{PA}\vdash\Box_T\bot$, contradicting Condition 4. Neither the consistency sentence nor its negation is therefore provable in $\mathrm{PA}$. $\square$

The proof separates cleanly into positive and negative halves. Reflection is decisive for the positive half; contradiction-proof soundness is decisive for the negative half.

**Corollary 4.3 (Combined logic–physics bridge).** Let $T$ have a physical realization in a semantics sound for its proof system. If $(\mathrm{PA},T)$ satisfies the arithmetic independence bridge, then

$$
T\nvdash\bot
$$

and $\operatorname{Con}(T)$ is independent of $\mathrm{PA}$.

**Proof sketch.** Mathematical consistency follows from Theorem 2.4. Independence follows independently from Theorem 4.2. $\square$

The word “independently” in the proof sketch is conceptually important. Physical realizability does not imply the arithmetic reflection condition. It contributes the syntactic consistency conclusion through semantic soundness, while the arithmetical assumptions contribute independence.

## 5. Necessity of the bridge: a counterexample

The assumptions cannot be replaced by consistency of the ambient proof system alone.

**Theorem 5.1 (Consistency alone does not force independence).** There is a consistent modal proof system $S^{\top}$ such that, for every indexed theory $T$,

$$
S^{\top}\vdash\neg\operatorname{Con}(T).
$$

Consequently, $\operatorname{Con}(T)$ is not independent of $S^{\top}$.

**Proof sketch.** Interpret every boxed formula $\Box_T A$ as true, while retaining a valuation under which unboxed contradiction $\bot$ is false. The resulting modal system does not prove $\bot$ and is therefore consistent at the meta-level. Yet $\Box_T\bot$ is true for every index $T$. Since

$$
\neg\operatorname{Con}(T)=\neg(\Box_T\bot\to\bot),
$$

and the antecedent is true while the consequent is false, the negated consistency sentence is provable. Hence its consistency does not imply independence. $\square$

This example distinguishes two assertions:

$$
S^{\top}\nvdash\bot
$$

and

$$
S^{\top}\nvdash\Box_T\bot.
$$

The first is ambient consistency. The second is exactly the kind of cross-theory accuracy required by Condition 4. They are not interchangeable.

## 6. Algorithmic diagnostics

The theorems are qualitative, but their logical architecture supports finite diagnostic procedures for concrete encoded examples. Such procedures do not decide unrestricted theoremhood; rather, they inspect bounded proof databases or supplied certificates.

### 6.1 Bounded physical-to-mathematical audit

Given a finite theory $T$, a finite collection of candidate worlds, a decidable satisfaction predicate, and a finite list of recorded derivations, one may:

1. search for a world satisfying every member of $T$;
2. inspect whether any recorded derivation concludes $\bot$;
3. if a realizing world exists and the derivation checker is sound, flag any recorded contradiction derivation as an integrity failure.

For $m$ worlds and $n$ theory sentences, model search takes $O(mn)$ satisfaction checks. Derivation validation adds the cost of checking the supplied proof objects.

### 6.2 Independence-condition audit

A certificate-oriented audit accepts four Boolean certificates corresponding to the bridge conditions: valid provability structure, ambient consistency, reflection, and contradiction-proof soundness. It reports which half of the independence argument is supported. The positive half requires the first three certificates; the negative half requires classical reasoning and the fourth. This is best viewed as dependency tracking, not as a decision procedure for consistency.

### 6.3 Countermodel search

For a finite modal valuation, assign truth values to $\bot$ and each boxed contradiction claim $\Box_T\bot$. Search for a row satisfying

$$
\bot=\mathrm{false},
\qquad
\Box_T\bot=\mathrm{true}.
$$

Such a row witnesses the separation between ambient consistency and the soundness condition. Exhaustive search over $k$ independent Boolean atoms takes $O(2^k)$ time and $O(k)$ working memory.

## 7. Applications and interpretation

### 7.1 Axiomatic quantum field theory

For a concrete quantum field theory $T$, the semantic side could consist of operator-algebraic or distributional models satisfying specified axioms. A realization, together with sound inference rules, would establish mathematical consistency of the chosen calculus. This says less than empirical adequacy: a model may exist without describing nature. It also says more than mere failure to find a contradiction: it supplies a semantic witness.

The arithmetic side is distinct. Derivations must be recursively encoded, the formula $\Box_T\bot$ must faithfully express existence of a contradiction proof, and a proof interpretation must establish

$$
\mathrm{PA}\vdash\operatorname{Con}(T)\to\operatorname{Con}(\mathrm{PA}).
$$

Without this implication, second incompleteness for $\mathrm{PA}$ has no route back to $\operatorname{Con}(T)$.

### 7.2 Simulation and finite evidence

A numerical simulation can exhibit approximate solutions or test finite families of constraints, but it does not generally establish physical consistency of an infinite theory. Nor does it prove arithmetic reflection. The framework clarifies the role of such evidence: simulation may suggest candidate worlds, while mathematical analysis must certify that they satisfy all axioms.

### 7.3 Theory comparison

Suppose two theories $T$ and $U$ admit faithful proof translations in both directions, and arithmetic verifies that each translation preserves derivations of $\bot$. Then their consistency sentences should become tightly connected in arithmetic. This motivates an independence-transfer principle: under sufficiently faithful mutual interpretations, arithmetic independence of $\operatorname{Con}(T)$ should coincide with arithmetic independence of $\operatorname{Con}(U)$. Establishing exact hypotheses is a natural continuation of the present framework.

## 8. Discussion

The main conclusion is a correction of logical scope. Physical consistency, mathematical consistency, and arithmetic independence are related but nonidentical.

First, the implication

$$
\text{physical consistency}\Longrightarrow\text{mathematical consistency}
$$

is a soundness theorem. Its converse is a completeness question and fails without further semantic assumptions.

Second, the implication

$$
\operatorname{Con}(T)\Longrightarrow\operatorname{Con}(\mathrm{PA})
$$

must be available *inside arithmetic* to transfer second incompleteness from $\mathrm{PA}$ to $T$. A meta-level belief that $T$ is strong, expressive, or physically compelling does not substitute for this formal reflection.

Third, independence has a negative half. Even if reflection blocks a proof of $\operatorname{Con}(T)$, arithmetic might still refute that sentence unless it is prevented from asserting a spurious $T$-proof of contradiction. Condition 4 supplies the needed barrier.

Finally, the counterexamples are structurally informative. Empty semantics show why soundness cannot imply completeness. Box-true modal semantics show why ambient consistency cannot imply cross-theory soundness. These examples are not pathologies to be ignored; they identify the exact missing hypotheses.


## 8.1 Assumption ledger and logical dependency

It is useful to record exactly which hypotheses support which conclusions. The semantic soundness assumption and the existence of a physical realization are sufficient for $T\nvdash\bot$; none of the modal or arithmetic hypotheses is needed for that conclusion. Conversely, the independence proof does not use a physical world directly. Its positive half uses the provability structure of $\mathrm{PA}$, consistency of $\mathrm{PA}$, and the reflection implication. Its negative half uses classical propositional reasoning and contradiction-proof soundness.

This modularity prevents accidental circularity. In particular, one must not justify the reflection implication merely by citing the intended physical consistency of $T$. Reflection is an arithmetic theorem about transformations of encoded proofs. A valid proof typically supplies a primitive-recursive map that converts a hypothetical $\mathrm{PA}$-proof of $\bot$ into a $T$-proof of $\bot$, and then verifies within $\mathrm{PA}$ that the map preserves correctness. Contraposition at the represented level yields the desired implication.

Similarly, Condition 4 should not be silently inferred from the meta-level statement $T\nvdash\bot$. The former says that $\mathrm{PA}$ does not prove a particular existential arithmetic sentence; the latter says externally that no actual $T$-proof of contradiction exists. Passing from truth to unprovability requires an appropriate soundness assumption on $\mathrm{PA}$ for the relevant formula class.

## 8.2 Edge cases

Several edge cases illuminate the definitions. If $T$ is inconsistent and its proof relation is faithfully represented, then $\Box_T\bot$ is true and $\operatorname{Con}(T)$ is false. A sound arithmetic theory should not prove $\operatorname{Con}(T)$, but it may prove its negation by verifying a concrete finite contradiction proof.

If $T$ is very weak, $\mathrm{PA}$ may directly prove $\operatorname{Con}(T)$. In that case the reflection implication to $\operatorname{Con}(\mathrm{PA})$ cannot coexist with consistency and the required provability conditions, for together they would violate Theorem 3.3. Thus the bridge conditions correctly exclude familiar theories whose consistency is provable in arithmetic.

If the physical semantics is unsound, a world might satisfy all axioms while the proof calculus nevertheless derives $\bot$. A “model” relative to such a defective satisfaction relation provides no consistency guarantee. The soundness hypothesis in Theorem 2.4 is therefore essential rather than conventional.

Finally, if the semantics is sound and complete for all theories under consideration, then mathematical and physical consistency coincide: consistency excludes a proof of $\bot$, completeness supplies a model, and soundness gives the reverse implication. Theorem 2.5 shows that soundness without completeness does not suffice.

## 8.3 Scope and limitations

The framework is conditional. It does not identify a canonical recursively enumerable axiomatization of all quantum field theory, nor establish the bridge conditions for one. Different formulations of physical theory may have different proof calculi, model classes, and arithmetic strengths. Consequently, consistency and independence claims must always name the formulation to which they apply.

The treatment is also classical. The negative half uses $\neg\neg\Box_T\bot\to\Box_T\bot$. In an intuitionistic setting, refuting $\operatorname{Con}(T)$ need not yield the positive assertion that a contradiction proof exists without an additional stability principle. A constructive version would therefore require either a stable proof predicate or a reformulated notion of independence.

## 9. Future work

Five directions are immediate.

1. **Arithmetized quantum-field-theory reflection.** Construct an explicit recursively enumerable first-order theory $\mathrm{QFT}_0$ and an arithmetic interpretation for which
   $$
   \mathrm{PA}\vdash\operatorname{Con}(\mathrm{QFT}_0)\to\operatorname{Con}(\mathrm{PA}).
   $$
2. **Minimal negative-half soundness.** Determine whether $1$-consistency is stronger than necessary to obtain $\mathrm{PA}\nvdash\neg\operatorname{Con}(T)$ for recursively axiomatized extensions of weak arithmetic.
3. **Constructive physical countermodels.** Replace the empty-world example by a nonempty finitely presented operational semantics containing a mathematically consistent but unrealizable finite constraint theory.
4. **Completeness boundaries.** Characterize conditions on physical semantics under which physical and mathematical consistency coincide for every theory.
5. **Transfer along interpretations.** Prove or refute invariance of consistency-sentence independence under mutually faithful interpretations whose proof translations preserve contradiction.

## 10. Conclusion

A valid logic–physics bridge requires more than attaching Gödel’s name to a consistent physical theory. Sound semantics carries physical realization to mathematical consistency. Provability conditions and arithmetic consistency activate second incompleteness. Internal reflection transfers that obstruction from arithmetic’s own consistency sentence to the physical theory’s consistency sentence. Restricted soundness blocks arithmetic from proving the opposite sentence. With all four beams in place, $\operatorname{Con}(T)$ is independent of $\mathrm{PA}$; without them, consistency alone is insufficient.

The resulting framework is both a theorem and a checklist. It tells us what can be concluded from a physical model, what requires a proof-theoretic interpretation, and where counterexamples arise when those roles are confused.