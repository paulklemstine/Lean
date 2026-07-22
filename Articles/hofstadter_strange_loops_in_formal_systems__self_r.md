# When Logic Climbs a Staircase and Meets Itself

## Strange loops, undecidable sentences, and the limits of truth inside a system

A staircase normally separates levels. Stand on one landing, climb, and you arrive somewhere higher. But imagine an impossible staircase whose last flight returns to the first step. You have moved upward at every moment, yet the hierarchy has folded back onto itself.

Logic has staircases like this. A formal language speaks about numbers, proofs, or other mathematical objects. Then, once the language is expressive enough, sentences can encode claims about formulas and deductions. The apparent hierarchy—objects below, statements above, statements about statements higher still—can bend into a loop. A sentence can indirectly point back to itself.

Such a loop need not be paradoxical. It can instead expose a precise boundary between truth and proof.

This article develops that boundary through four results. First, a Gödel sentence is a true but undecidable fixed point of unprovability. Second, semantic truth cannot be uniformly represented inside the same coded language, a Tarski-style barrier. Third, a suitable rank system produces infinitely many distinct undecidable loops rather than just one. Finally, interpretations between systems carry incompleteness around a cycle, turning a metaphorical “tangled hierarchy” into an exact mathematical structure.

## The stage: sentences, codes, truth, and proof

Consider a formal system with a collection of sentences and a collection of codes for predicates on sentences. If $c$ is a code and $s$ is a sentence, write $D(c,s)$ for “the predicate represented by $c$ holds of $s$.” Not every conceivable semantic property must have a code. That restriction is crucial.

The system also has two notions that must not be confused:

* $P(s)$ means that $s$ is provable in the system.
* $T(s)$ means that $s$ is true in the intended semantics.

We assume **soundness**: proofs do not establish falsehoods. In symbols,

$$
P(s)\Longrightarrow T(s).
$$

The language has sentence negation $\neg_s s$, satisfying

$$
T(\neg_s s)\Longleftrightarrow \neg T(s).
$$

Predicate codes can also be negated: from $c$ one obtains $\bar c$ such that

$$
D(\bar c,s)\Longleftrightarrow \neg D(c,s).
$$

The engine of self-reference is **diagonalization**. For each represented predicate code $c$, there is a diagonal sentence $\delta(c)$ satisfying

$$
T(\delta(c))\Longleftrightarrow D(c,\delta(c)).
$$

This is a semantic fixed-point principle: $\delta(c)$ has exactly the property that $c$ assigns to it. Finally, assume that unprovability is represented by some code $u$:

$$
D(u,s)\Longleftrightarrow \neg P(s).
$$

These assumptions define the kind of coded diagonal system studied here. The careful phrase is “represented predicate.” Diagonalization is not granted for every property imaginable. In particular, semantic truth itself will turn out to resist such internal coding.

## The sentence that escapes its own proof system

Define the Gödel sentence by

$$
G=\delta(u).
$$

Combining diagonalization with the meaning of $u$ gives the **Gödel Fixed-Point Theorem**:

$$
T(G)\Longleftrightarrow \neg P(G).
$$

In words, $G$ is true exactly when it is not provable. This is the strange loop: the sentence receives the predicate of its own unprovability.

Why does the loop not explode into contradiction? Suppose $G$ were provable. Soundness would make $G$ true. But the fixed-point equivalence would then say that $G$ is not provable, contradicting the supposition. Therefore $G$ is unprovable. Feeding that conclusion back through the equivalence shows that $G$ is true.

There is more. The negation of $G$ is also unprovable. If $\neg_s G$ were provable, soundness would make it true. By the semantics of negation, $G$ would then be false, contradicting the truth just established. Thus we obtain the **Gödel Independence Theorem**:

> In every sound coded diagonal system, the Gödel sentence $G$ is true, while neither $G$ nor its object-language negation $\neg_s G$ is provable.

The result does not say that truth is mysterious or subjective. It says something sharper: truth in the intended semantics outruns derivability within the chosen system.

## Why the system cannot carry its own universal truth label

A tempting response is to enrich the language with a code for truth. Let $t$ supposedly satisfy

$$
D(t,s)\Longleftrightarrow T(s)
$$

for every sentence $s$. Because represented predicates are closed under code negation, $\bar t$ would represent semantic untruth:

$$
D(\bar t,s)\Longleftrightarrow \neg T(s).
$$

But no such untruth code can exist. If $f$ represented untruth, diagonalization would produce $L=\delta(f)$ with

$$
T(L)\Longleftrightarrow D(f,L)\Longleftrightarrow \neg T(L).
$$

Whether $L$ is true or false, the equivalence reverses its status and yields a contradiction. This proves the **Tarski Barrier for Semantic Untruth**:

> No predicate code in a coded diagonal system can represent the property of being semantically untrue for all sentences.

Closure under code negation immediately gives the **Undefinability of Semantic Truth Theorem**:

> No predicate code can uniformly represent semantic truth for all sentences of the same system.

This does not forbid an isolated sentence that happens to say something truth-like, nor does it deny that a richer metalanguage may discuss truth for the original language. It forbids one uniform truth predicate living at the same level and covering every sentence to which diagonalization applies.

A useful corollary is that the map $c\mapsto D(c,\cdot)$ from codes to predicates on sentences is not onto. There are semantic properties—untruth is an explicit example—that no code reaches. Syntax cannot exhaust its own semantics.

## One strange loop becomes infinitely many

Gödel’s sentence is often presented as a singular jewel. Yet a sufficiently organized system can contain an endless family of such loops.

Add a rank function $r$ assigning a natural number to every sentence. For each $n\in\mathbb N$, suppose there is a code $u_n$ that still represents unprovability,

$$
D(u_n,s)\Longleftrightarrow \neg P(s),
$$

but whose diagonal sentence has prescribed rank:

$$
r(\delta(u_n))=n.
$$

Define

$$
G_n=\delta(u_n).
$$

For every $n$, the same fixed-point argument gives

$$
T(G_n)\Longleftrightarrow \neg P(G_n).
$$

Soundness then shows that $G_n$ is true, $G_n$ is unprovable, and $\neg_s G_n$ is unprovable. The ranks ensure distinctness: if $G_m=G_n$, applying $r$ gives $m=n$.

This yields the **Infinite Strange-Loop Theorem**:

> In a sound ranked diagonal system with rank-separated codes for unprovability, the family $\{G_n:n\in\mathbb N\}$ is infinite and injectively indexed. Every $G_n$ is true, and neither $G_n$ nor its object-language negation is provable.

The extra rank hypothesis matters. Merely possessing many codes with the same meaning does not by itself ensure that diagonalization produces different sentences. Rank separation supplies the syntactic resource that turns repetition into genuine infinitude.

## Tangled hierarchies between systems

Self-reference can also travel between languages. Suppose systems $S$ and $R$ are connected by an interpretation $I$ that translates each sentence $s$ of $S$ into a sentence $I(s)$ of $R$. The interpretation is **truth-preserving** when

$$
T_R(I(s))\Longleftrightarrow T_S(s),
$$

and **proof-reflecting** when

$$
P_R(I(s))\Longrightarrow P_S(s).
$$

These conditions imply the **Transport of Incompleteness Theorem**:

> If $s$ is true but unprovable in $S$, then $I(s)$ is true but unprovable in $R$.

Truth transfers directly. If the translation were provable in $R$, proof reflection would make the original provable in $S$, contradicting its unprovability.

Now place two coded diagonal systems on two levels, with a truth-preserving, proof-reflecting interpretation upward and another downward. Each system has its own Gödel sentence. The lower sentence remains true and unprovable after translation upstairs; the upper sentence remains true and unprovable after translation downstairs. Consequently, each level contains both a native incompleteness witness and a witness arriving through the interpretive cycle.

This is the **Two-Level Tangled-Hierarchy Theorem**:

> In a two-way cycle of truth-preserving, proof-reflecting interpretations, the lower system’s Gödel sentence and its upward translation are true but unprovable at their respective levels, and the upper system’s Gödel sentence and its downward translation are likewise true but unprovable.

The hierarchy is tangled not because “higher” and “lower” become meaningless, but because semantic and proof-theoretic information can complete a round trip.

## The shape of the boundary

The four results fit together into a single picture.

Diagonalization allows represented predicates to fold back onto sentences. Applied to unprovability, it creates stable self-reference: a true sentence outside the proof system’s reach. Applied hypothetically to semantic untruth, it creates an impossible liar equivalence. The difference explains why unprovability may be represented while full semantic truth cannot be uniformly internalized.

Rank separation reveals that incompleteness need not be a lone defect; under explicit syntactic conditions it forms an infinite landscape. Interpretations show that this landscape is not trapped inside one formal language. It can be transported through networks of systems, provided truth is preserved and proofs are reflected.

Real mathematical practice constantly moves between levels: object and metadata, program and specification, theory and interpretation. The lesson of strange loops is not that hierarchy fails. It is that sufficiently expressive hierarchies have topology. Some paths close. When they do, they mark exact limits on what a system can say, prove, or define about itself.

There is also a practical virtue in stating assumptions this carefully. It prevents three seductive mistakes: confusing a sentence with its code, confusing provability with truth, and assuming that every meaningful external property is internally expressible. Once those distinctions are maintained, the drama of self-reference becomes more, not less, compelling. Gödel’s loop is not a word game; it is a fixed point governed by soundness. Tarski’s barrier is not a vague ban on discussing truth; it is a precise failure of uniform same-level representation. The infinite family is not obtained by renaming one sentence; rank proves genuine distinctness. And the tangled hierarchy is not merely an image from art; it is a cycle whose translations preserve truth and reflect proofs. Each metaphor has an exact mathematical spine.
