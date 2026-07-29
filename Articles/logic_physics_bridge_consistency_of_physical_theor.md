# When Physics Meets the Limits of Proof

## What does it mean for a physical theory to be consistent?

A physical theory can fail in at least two very different ways. Its equations might contain a contradiction, allowing every statement to be derived. Or its equations might be logically impeccable yet describe no possible physical world. These failures are often blurred in conversation, but separating them reveals a sharp boundary between logic and physics—and a precise route by which Gödel’s incompleteness phenomena enter the foundations of physical theory.

Imagine a proposed quantum field theory as a vast rulebook. Some pages specify fields and particles, others prescribe interactions, and still others explain how conclusions follow from assumptions. We can ask a syntactic question: can the rulebook derive an outright contradiction? We can also ask a semantic question: is there at least one physically admissible world in which every rule is satisfied? The first is about what strings of symbols can be proved. The second is about whether the rules can be realized.

The central message is simple but easy to misstate:

> Physical realizability implies mathematical consistency when the interpretation of the theory is sound, but mathematical consistency alone does not imply physical realizability. Moreover, the consistency sentence of a physical theory is independent of Peano arithmetic only when explicit reflection and soundness conditions connect the two theories.

This corrected statement matters because a tempting slogan—“if a physical theory is consistent, then its consistency is independent of arithmetic”—is false without those connecting assumptions.

## Three meanings that must not be confused

Let $T$ be a theory and let $P$ denote its proof rules. Write $\bot$ for contradiction. The theory is **mathematically consistent** when there is no derivation of contradiction:

$$
P,T\nvdash\bot.
$$

Now let $\mathcal W$ be a class of physically admissible worlds, with a satisfaction relation telling us when a world obeys a sentence. The theory is **physically consistent** when at least one world realizes all its claims:

$$
\exists w\in\mathcal W\;\forall\varphi\in T,\mathcal M,w\models\varphi.
$$

Here $\mathcal M$ denotes the chosen semantics. Finally, the semantics is **sound** when every derivable conclusion is true in every admissible world satisfying the assumptions. In particular, if $T$ derives $\bot$, then every physical realization of $T$ would have to satisfy $\bot$, which no world can do.

That observation gives the first bridge theorem.

**Physical-to-Mathematical Consistency Theorem.** If the semantics is sound and $T$ has a physical realization, then $T$ is mathematically consistent.

The proof is a one-paragraph contradiction argument. Choose a world realizing $T$. If $T$ derived $\bot$, soundness would force that world to satisfy $\bot$. Since contradiction is false in every world, no such derivation exists.

The reverse direction fails. A collection of rules may avoid contradiction without possessing any realization in the selected class of worlds. The gap is existential: “no proof of impossibility” does not manufacture an object that meets all the constraints. A sound semantics can even have no admissible worlds at all. Then soundness holds vacuously and an appropriately chosen proof system can remain consistent, while no theory is physically realizable. More realistic counterexamples can arise when the admissible world class is nonempty but too narrow to realize a jointly constrained theory.

## Turning consistency into a sentence

To connect this distinction with arithmetic, consistency itself must be represented by a sentence. Let $\Box_U\varphi$ mean “the theory $U$ proves $\varphi$.” The usual consistency sentence for $U$ is

$$
\operatorname{Con}(U):=\neg\Box_U\bot,
$$

or equivalently,

$$
\operatorname{Con}(U):=\Box_U\bot\to\bot.
$$

A sentence $A$ is **independent** of a proof system $S$ when $S$ proves neither $A$ nor its negation:

$$
S\nvdash A
\qquad\text{and}\qquad
S\nvdash\neg A.
$$

Independence therefore has two halves. Showing that arithmetic cannot prove $\operatorname{Con}(T)$ is not enough; one must also show that arithmetic cannot prove $\neg\operatorname{Con}(T)$.

## The self-reference engine

The positive half is driven by Gödel’s second incompleteness phenomenon. In a sufficiently expressive arithmetical theory, provability behaves according to three familiar principles: the theory proves propositional tautologies and respects modus ponens; theorems can be internalized as provability statements; and Löb’s principle holds:

$$
\Box_S(\Box_S A\to A)\to\Box_S A.
$$

Suppose such a theory $S$ is consistent and nevertheless proves its own consistency,

$$
\Box_S\bot\to\bot.
$$

Internalizing that theorem yields

$$
\Box_S(\Box_S\bot\to\bot).
$$

Löb’s principle then gives $\Box_S\bot$, and modus ponens with the alleged consistency theorem gives $\bot$. Thus $S$ would prove a contradiction. Consequently:

**Second Incompleteness Theorem in Provability Form.** Any consistent theory satisfying the stated provability principles cannot prove its own consistency sentence.

But this theorem concerns $\operatorname{Con}(S)$, not automatically $\operatorname{Con}(T)$ for some physical theory $T$. A bridge is required.

## The missing bridge conditions

Let $\mathrm{PA}$ stand for Peano arithmetic and $T$ for an arithmetically encoded physical theory. Four conditions suffice for the desired independence result.

1. **Provability structure:** arithmetic’s provability predicate satisfies the principles needed for the second incompleteness argument.
2. **Arithmetic consistency:** $\mathrm{PA}$ is consistent.
3. **Reflection toward arithmetic:** arithmetic proves
   $$
   \operatorname{Con}(T)\to\operatorname{Con}(\mathrm{PA}).
   $$
4. **Contradiction-proof soundness:** arithmetic does not prove that $T$ proves a contradiction:
   $$
   \mathrm{PA}\nvdash\Box_T\bot.
   $$

These are not decorative technicalities. Each performs a specific job.

Assume first that $\mathrm{PA}$ proves $\operatorname{Con}(T)$. Combining that proof with the reflection implication gives a proof of $\operatorname{Con}(\mathrm{PA})$. The second incompleteness theorem forbids this. Hence

$$
\mathrm{PA}\nvdash\operatorname{Con}(T).
$$

For the other half, note that $\neg\operatorname{Con}(T)$ is the double negation of $\Box_T\bot$. Classical arithmetic proves double-negation elimination, so a proof of $\neg\operatorname{Con}(T)$ would yield a proof of $\Box_T\bot$. The contradiction-proof soundness condition rules that out. Therefore

$$
\mathrm{PA}\nvdash\neg\operatorname{Con}(T).
$$

Together these establish the main result.

**Arithmetic Independence Theorem for a Physical Theory.** If the four bridge conditions hold, then $\operatorname{Con}(T)$ is independent of $\mathrm{PA}$.

When $T$ also has a physical realization under sound semantics, two conclusions arrive side by side: $T$ is mathematically consistent, and its encoded consistency sentence is independent of arithmetic. Crucially, the first conclusion comes from the physical model and semantic soundness; the second comes from the separate arithmetic bridge conditions. Physical existence does not secretly perform the work of reflection.

## Why consistency alone is too weak

One can build a consistent modal proof system in which every statement of the form $\Box_U A$ is accepted, including $\Box_T\bot$. Such a system can still avoid proving the unboxed contradiction $\bot$, yet it proves the negation of every sentence $\operatorname{Con}(T)$. Its own consistency therefore does not make those consistency sentences independent.

This counterexample exposes the logical error in the unrestricted slogan. Meta-level consistency merely says that the ambient system does not derive $\bot$. It does not guarantee that the system is accurate about another theory’s alleged contradiction proofs. The fourth bridge condition supplies exactly that missing accuracy.

## What the result says about physics

The theorem does not claim that a particular quantum field theory has already been encoded in arithmetic with all four conditions established. Rather, it provides a rigorous blueprint for what such a claim must contain. Any future statement that a physical theory’s consistency is independent of arithmetic must identify:

- the physical theory and its effective proof calculus;
- the arithmetic sentence expressing the absence of contradiction proofs;
- a sound semantics linking derivations to physically admissible worlds;
- an arithmetic proof that consistency of the physical theory implies consistency of arithmetic; and
- a justified reason arithmetic cannot falsely certify a contradiction proof in the physical theory.

This division of labor is scientifically useful. It prevents semantic evidence—such as the existence of a model, simulation, or state space—from being confused with proof-theoretic reflection. It also warns against the opposite mistake: a contradiction-free symbolic calculus need not correspond to any possible physical system.

The deepest lesson is not that logic blocks physics. It is that “consistency” names several different achievements. A world realizing equations is one achievement. A calculus unable to derive absurdity is another. An arithmetic theory unable to settle a sentence about that calculus is a third. The bridge among them can be crossed, but every load-bearing beam must be visible.
## A practical map for future theories

The framework also suggests a disciplined research program. Begin on the physical side by specifying what counts as a world: perhaps a Hilbert-space representation, a family of fields satisfying locality and covariance, or an operational network of preparations and measurements. Prove that the deductive rules preserve truth in those worlds. A single realization then guarantees ordinary mathematical consistency.

Next move to arithmetic. The syntax of the physical calculus must be effectively coded so that finite derivations become arithmetic objects. Only then does $\Box_T\bot$ express a checkable claim about a purported contradiction proof. The reflection implication $\operatorname{Con}(T)\to\operatorname{Con}(\mathrm{PA})$ is especially demanding: it says that, from arithmetic’s own point of view, any contradiction in arithmetic could be transferred into the physical theory. Establishing it requires an explicit interpretation or proof translation, not an appeal to physical plausibility.

Finally, the negative half of independence requires calibrated soundness. Full arithmetical soundness may be more than necessary; what is needed here is specifically the inability of arithmetic to prove the existential claim that a coded $T$-derivation ends in contradiction when no such derivation should be certified. Determining the weakest sufficient condition is a natural open direction.

These stages resemble building a suspension bridge from opposite shores. Semantics anchors the physical shore. Arithmetization and reflection anchor the logical shore. Incompleteness governs the span between them. Remove an anchor and the conclusion does not become daring—it becomes unsupported.

That clarity has consequences beyond quantum field theory. Any scientific formalism with an effective calculus—models of computation, axiomatic thermodynamics, causal theories, or rigorous fragments of statistical mechanics—faces the same three questions. Is there a model? Is contradiction underivable? Can arithmetic decide the encoded claim that contradiction is underivable? The answers need not coincide, and understanding their separation is part of understanding what a theory actually tells us.
