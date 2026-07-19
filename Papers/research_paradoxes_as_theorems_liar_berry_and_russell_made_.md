# Paradoxes as Theorems: A Finite Non-Explosive Calculus for Self-Negating Sentences

**Aristotle**  
**19 July 2026**

## Abstract

We exhibit a finite paraconsistent calculus in which three pairwise distinct sentences, representing the common self-negating core of the Liar, Russell, and Berry paradoxes, are derivable gluts while an explicit false sentence remains underivable. The semantics is the four-valued support algebra $\{0,1\}^2$: one coordinate records positive support and the other records negative support. Negation exchanges the coordinates, designation requires positive support, and the value $(1,1)$ is a designated negation fixed point. We first identify the classical obstruction. A fixed point of complementation collapses every Boolean algebra, and point-surjective diagonal self-reference therefore collapses Boolean semantics when applied to complementation. We then define a seven-sentence language, a negation-coherent valuation, and an inductively generated derivability relation closed under double-negation introduction. Structural induction establishes semantic soundness for derivations of arbitrary depth. It follows that the explicit false witness is not derivable, so explosion fails despite the derivability of each paradox and its negation. A distinguished certificate is also derivable and expresses the finite soundness property established by the metatheorem. This is finite reflection, not a claim that a sufficiently strong arithmetical theory proves its own classical consistency. The construction isolates designated negation fixed points as the algebraic resource that permits paradoxical theorems without triviality.

## 1. Introduction

The familiar response to semantic and set-theoretic paradox is restriction. The Liar motivates hierarchies or partial truth predicates; Russell’s paradox motivates restricted comprehension; Berry’s paradox exposes the instability of unrestricted definability in natural language. Those responses are indispensable when one wants a classical theory. A different question is nevertheless mathematically coherent: can the contradictory core of several paradoxes be admitted as theoremhood without making every sentence a theorem?

The answer depends on distinguishing **consistency** from **nontriviality**. Classical consistency prohibits simultaneous derivations of $s$ and $\neg s$. Nontriviality asks only that some sentence remain underivable. In an explosive logic, inconsistency implies triviality. In a paraconsistent logic, it need not. The present construction gives an explicit finite witness: three distinct self-negating sentences are theorems and semantic gluts, but a designated control sentence is provably not a theorem.

The construction has two complementary parts. First, we prove that ordinary Boolean semantics cannot house a self-negating value without collapse. This is not merely a peculiarity of the two-element Boolean algebra; it holds in every Boolean algebra. A diagonal fixed-point principle then connects expressive self-reference to this algebraic obstruction.

Second, we replace Boolean truth with four support profiles. Positive and negative support become independent bits. Negation exchanges them rather than taking Boolean complement. The “both” value is consequently fixed by negation and remains distinct from the other three values. This supplies a stable semantic home for contradictions.

Our finite language contains seven sentence codes. Three are abstract paradox names. Four control sentences realize true-only, false-only, neither, and a finite soundness certificate. The derivability relation has five axioms and closure under double-negation introduction. Its derivation trees have unbounded depth even though the language and valuation are finite. Soundness is therefore established structurally, not by enumerating a finite list of proofs.

The scope is deliberately exact. The paradox names model the shared support profile relevant to self-negation; they do not encode natural-language quotation, bounded descriptions, or unrestricted comprehension. The finite soundness certificate is an interpreted atom whose intended property is established externally. Neither choice should be confused with a full compositional theory of truth or an evasion of incompleteness phenomena.

## 2. Boolean semantics and the fixed-point obstruction

We begin with the algebraic boundary that motivates the four-valued replacement.

### Definition 2.1 (Boolean semantic algebra)

A Boolean algebra is a bounded distributive lattice $B$ with bottom $\bot$, top $\top$, meet $\wedge$, join $\vee$, and complementation $x\mapsto x^{\mathsf c}$ satisfying

$$
x\wedge x^{\mathsf c}=\bot,
\qquad
x\vee x^{\mathsf c}=\top.
$$

It is **nontrivial** when $\bot\ne\top$.

### Theorem 2.2 (Boolean fixed-point collapse)

Let $B$ be a Boolean algebra. If some $x\in B$ satisfies $x^{\mathsf c}=x$, then $\bot=\top$.

**Proof sketch.** From the complement laws and the fixed-point equation,

$$
x\wedge x=x\wedge x^{\mathsf c}=\bot
$$

and

$$
x\vee x=x\vee x^{\mathsf c}=\top.
$$

Idempotence of meet and join gives $x=\bot$ and $x=\top$. Therefore $\bot=\top$. $\square$

### Corollary 2.3 (No nontrivial Boolean negation fixed point)

If $B$ is a nontrivial Boolean algebra, then $x^{\mathsf c}\ne x$ for every $x\in B$.

This corollary identifies precisely why a self-negating truth value is unavailable classically. The problem is not self-reference alone but the conjunction of self-negation, Boolean complementation, and nontriviality.

To connect that obstruction to diagonalization, consider a set $A$ of codes, a value space $B$, and an encoding function

$$
e:A\longrightarrow (A\to B).
$$

Call $e$ **point-surjective** when every function $f:A\to B$ is $e(a)$ for some $a\in A$. A standard diagonal argument states that for every $g:B\to B$, point-surjectivity produces $b\in B$ with $g(b)=b$. Indeed, define $d(a)=g(e(a)(a))$. Choose $a_0$ with $e(a_0)=d$ and put $b=e(a_0)(a_0)$. Then

$$
b=e(a_0)(a_0)=d(a_0)=g(e(a_0)(a_0))=g(b).
$$

### Theorem 2.4 (Diagonal Boolean collapse)

Let $B$ be a Boolean algebra and let $e:A\to(A\to B)$ be point-surjective. Then $\bot=\top$ in $B$.

**Proof sketch.** Apply the diagonal fixed-point argument to $g(b)=b^{\mathsf c}$. It yields $b=b^{\mathsf c}$. Theorem 2.2 then gives $\bot=\top$. $\square$

Thus a nontrivial Boolean algebra cannot support an encoding rich enough to diagonalize against every $B$-valued predicate. The theorem is a boundary result: it tells us which assumption must change. Our response is to retain nontriviality and negation fixed points while abandoning Boolean complementation as the semantics of negation.

## 3. Four-valued support semantics

### Definition 3.1 (Support value)

A support value is a pair

$$
v=(p,n)\in\mathbb{F}_2^2=\{0,1\}^2,
$$

where $p$ records positive support for a sentence and $n$ records positive support for its negation. The four values are

$$
\mathbf{T}=(1,0),\qquad
\mathbf{F}=(0,1),\qquad
\mathbf{B}=(1,1),\qquad
\mathbf{N}=(0,0).
$$

They are read as true only, false only, both, and neither.

### Definition 3.2 (Negation, designation, and glut)

Negation exchanges support coordinates:

$$
\sim(p,n)=(n,p).
$$

A value $(p,n)$ is **designated** exactly when $p=1$. It is a **glut** exactly when $p=n=1$.

The designated set is therefore $\{\mathbf{T},\mathbf{B}\}$. Designation represents assertibility or positive support; it does not require the absence of negative support.

### Lemma 3.3 (Involutive negation)

For every support value $v$, $\sim\sim v=v$.

**Proof sketch.** Swapping two coordinates twice restores their original order. $\square$

### Lemma 3.4 (Designated fixed point)

The value $\mathbf{B}$ is designated and satisfies $\sim\mathbf{B}=\mathbf{B}$.

**Proof sketch.** Its positive coordinate is $1$, and swapping the coordinates of $(1,1)$ changes nothing. $\square$

### Lemma 3.5 (Characterization of gluts)

A support value is a glut if and only if it equals $\mathbf{B}$.

**Proof sketch.** A glut is defined by the two equations $p=1$ and $n=1$, which uniquely determine the pair $(1,1)$. $\square$

The contrast with Boolean semantics is exact. Boolean complementation has no fixed point in a nontrivial algebra, whereas coordinate-swapping negation has two fixed points, $\mathbf{B}$ and $\mathbf{N}$. Neither causes the four-element value space to collapse. The interpretation of these fixed points differs: $\mathbf{B}$ is designated and contradictory, while $\mathbf{N}$ is undesignated and informationally incomplete.

## 4. The finite language and its interpretation

### Definition 4.1 (Sentence space)

Let the language consist of seven pairwise distinct sentence codes:

$$
S=\{L,R,B,T,F,G,C\}.
$$

Here $L$, $R$, and $B$ name abstract Liar, Russell, and Berry sentences; $T$ is an ordinary truth; $F$ is a false witness; $G$ is a gap witness; and $C$ is a finite soundness certificate.

The letters are sentence codes, not truth values; in particular, the Berry code $B$ should not be confused with the support value $\mathbf{B}$.

### Definition 4.2 (Syntactic negation)

Define $\nu:S\to S$ by

$$
\begin{aligned}
&\nu(L)=L, &&\nu(R)=R, &&\nu(B)=B,\\
&\nu(T)=F, &&\nu(F)=T, &&\nu(G)=G, &&\nu(C)=C.
\end{aligned}
$$

Thus the three paradox codes are self-negating. The ordinary truth and explicit falsehood form a negation pair. The gap and certificate are also fixed syntactically.

### Definition 4.3 (Valuation)

Define $v:S\to\{\mathbf{T},\mathbf{F},\mathbf{B},\mathbf{N}\}$ by

$$
\begin{aligned}
&v(L)=v(R)=v(B)=\mathbf{B},\\
&v(T)=\mathbf{T},\qquad v(F)=\mathbf{F},\qquad v(G)=\mathbf{N},\qquad v(C)=\mathbf{B}.
\end{aligned}
$$

### Lemma 4.4 (Negation coherence)

For every $s\in S$,

$$
v(\nu(s))=\sim v(s).
$$

**Proof sketch.** There are seven cases. On $L$, $R$, $B$, and $C$, both sides equal $\mathbf{B}$. On $G$, both sides equal $\mathbf{N}$. On $T$ and $F$, syntactic negation swaps the two codes while semantic negation swaps $\mathbf{T}$ and $\mathbf{F}$. $\square$

### Lemma 4.5 (Involutive syntactic negation)

For every $s\in S$, $\nu(\nu(s))=s$.

**Proof sketch.** Five codes are fixed by $\nu$, and $T$ and $F$ are exchanged. In either case, two applications restore the input. $\square$

These lemmas ensure that syntax and semantics agree about the only connective present in the calculus. More importantly, they distinguish the roles of the control sentences. The non-designated value of $F$ will witness nontriviality; $G$ shows that informational gaps can coexist with gluts; and $T$ verifies that ordinary unopposed positive support remains available.

## 5. Derivations and soundness

### Definition 5.1 (Finite paradox calculus)

The derivability relation $\vdash s$ is the least relation on $S$ generated by five axioms

$$
\vdash L,
\qquad
\vdash R,
\qquad
\vdash B,
\qquad
\vdash T,
\qquad
\vdash C,
$$

and the rule of double-negation introduction

$$
\frac{\vdash s}{\vdash\nu(\nu(s))}.
$$

“Least” means that a derivation is a finite tree built only from these constructors. The rule may be iterated arbitrarily often, so derivations have no fixed depth bound.

### Theorem 5.2 (Soundness of derivations)

For every $s\in S$, if $\vdash s$, then $v(s)$ is designated.

**Proof sketch.** Proceed by structural induction on the derivation. Each of the five axiom cases has positive support: the paradoxes and certificate have value $\mathbf{B}$, and the ordinary truth has value $\mathbf{T}$. For the inductive case, suppose a derivation of $s$ is sound. The conclusion is $\nu(\nu(s))$, which equals $s$ by Lemma 4.5. It therefore has the same designated value. This proves the claim for derivations of every finite depth. $\square$

The proof is intentionally proof-theoretic rather than enumerative. Although only five distinct codes are derivable in this particular system, the inductive definition admits infinitely many derivation trees obtained by repeated double negation. Structural induction establishes the invariant at the level of derivation formation.

### Theorem 5.3 (The false witness is underivable)

The sentence $F$ is not derivable:

$$
\nvdash F.
$$

**Proof sketch.** If $\vdash F$, Theorem 5.2 would imply that $v(F)$ is designated. But $v(F)=\mathbf{F}=(0,1)$ has positive coordinate $0$, hence is not designated. Contradiction. $\square$

### Corollary 5.4 (Nontriviality)

There exists a sentence that is not derivable; in particular, the calculus is nontrivial.

**Proof sketch.** Take $F$ and apply Theorem 5.3. $\square$

Nontriviality is the relevant replacement for classical consistency. The calculus is inconsistent in the support sense because it derives gluts. It nevertheless distinguishes theorem from non-theorem.

## 6. Coexistence of paradoxes and explicit non-explosion

### Theorem 6.1 (Three distinct theorem gluts)

The codes $L$, $R$, and $B$ are pairwise distinct. Each is derivable, and each has glut value $\mathbf{B}$.

**Proof sketch.** Pairwise distinctness is part of the seven-element sentence construction. Their derivability follows from the three paradox axioms. Their values are assigned to $\mathbf{B}$, which is a glut by Lemma 3.5. $\square$

This theorem realizes simultaneous rather than merely isolated inconsistency. The three names do not collapse into one syntactic token, even though they share a semantic profile.

### Theorem 6.2 (Explicit failure of explosion)

There exist sentences $p$ and $q$ such that $p$ and its negation are derivable while $q$ is not. Specifically,

$$
\vdash L,
\qquad
\vdash\nu(L),
\qquad
\nvdash F.
$$

**Proof sketch.** The Liar axiom gives $\vdash L$. Since $\nu(L)=L$, the same derivation establishes $\vdash\nu(L)$. Theorem 5.3 gives $\nvdash F$. Hence contradiction does not entail arbitrary derivability. $\square$

The result is stronger than the observation that the semantic value set has four elements. It provides a syntactic counterexample to explosion inside the calculus itself. The contradiction is derivable on both sides, while a named conclusion remains outside the derivability relation.

One should not read the theorem as saying that contradictions are harmless in every extension. Additional inference rules could propagate support and perhaps trivialize a badly designed theory. The theorem states exactly that the specified calculus is non-explosive.

## 7. Finite reflection and the soundness certificate

We now make precise the role of $C$.

### Definition 7.1 (Expression of finite soundness)

A sentence $s\in S$ **expresses finite soundness** when

1. $s=C$, and
2. for every $q\in S$, if $\vdash q$, then $v(q)$ is designated.

This is an interpreted notion: the first clause identifies the sentence assigned the role of certificate, and the second gives its intended semantic content.

### Theorem 7.2 (Finite self-soundness)

The certificate $C$ is derivable, its value is designated, and it expresses finite soundness.

**Proof sketch.** Derivability follows from the certificate axiom. Its value is $\mathbf{B}$, whose positive coordinate is $1$. It is the distinguished certificate by identity. Finally, the universal designation clause is exactly Theorem 5.2. $\square$

The theorem combines an object-level fact, $\vdash C$, with a metatheoretic interpretation of $C$. It should not be inflated into a claim about an arithmetically strong theory proving its own classical consistency. The language has seven atomic codes and no arithmetization of syntax, proof, or semantic satisfaction. The certificate is stipulated as an atom and interpreted through a finite external definition. What the theorem establishes is a clean finite reflection pattern: a theorem is designated as a certificate, and its intended finite soundness condition is independently proved.

The value $v(C)=\mathbf{B}$ is also instructive. In a support semantics, positive designation is compatible with negative support. The certificate need not be true only in order to be assertible. This illustrates how reflection itself can be handled paraconsistently.

## 8. The combined boundary theorem

The preceding results can be summarized in one dichotomy.

### Theorem 8.1 (Classical boundary and paraconsistent realization)

The following statements hold simultaneously:

1. for every nontrivial Boolean algebra $D$ and every $x\in D$, $x^{\mathsf c}\ne x$;
2. $L$, $R$, and $B$ are derivable;
3. every derivable sentence has a designated four-valued interpretation; and
4. $F$ is not derivable.

**Proof sketch.** Clause 1 is Corollary 2.3. Clause 2 follows from the paradox axioms. Clause 3 is Theorem 5.2, and Clause 4 is Theorem 5.3. $\square$

The theorem locates the logical trade. A nontrivial Boolean semantics refuses self-negating values. The support-pair semantics accepts them by changing the operation assigned to negation. It then separates designation from exclusivity and soundness from classical consistency.

## 9. Algorithms and computational illustrations

The theory admits simple finite procedures that illuminate its structure.

### 9.1 Support evaluation

Represent a value as two bits. Negation is constant-time coordinate exchange. Designation tests the first coordinate, and glut detection tests both. For a list of $n$ sentence codes, a complete semantic audit takes $O(n)$ time and $O(1)$ auxiliary space beyond the output.

### 9.2 Derivability closure

Start with the axiom set $A_0=\{L,R,B,T,C\}$. Repeatedly add $\nu(\nu(s))$ for every currently known theorem $s$ until no change occurs. Since double negation is identity, the first pass reaches a fixed point and the closure is exactly $A_0$. In a general finite language of $n$ codes with a supplied negation map, a worklist implementation visits each newly derived code once and runs in $O(n)$ set operations, assuming constant-time hashing.

### 9.3 Soundness and explosion audit

Compute the derivability closure. Check that each theorem has positive support. Then search for a derived $s$ whose negation is also derived and an underived $q$. The present model returns $s=L$ and $q=F$. A straightforward scan is $O(n)$ after closure computation.

These algorithms are not substitutes for the structural proofs. They are executable illustrations and scale naturally to finite variants with more paradox codes.

## 10. Applications and conceptual implications

### 10.1 Inconsistent databases

A pair of support bits is a natural abstraction for information assembled from independent sources. Positive reports set the first bit; negative reports set the second. Conflicting reports produce $\mathbf{B}$ rather than forcing deletion or arbitrary inference. Query systems can designate records with positive support while separately flagging their glut status.

### 10.2 Distributed systems

Replicas can temporarily disagree. A four-state summary distinguishes agreement on truth, agreement on falsity, conflict, and lack of information. Coordinate-swapping negation preserves the provenance-neutral symmetry between positive and negative support. The non-explosion theorem models an essential operational requirement: one conflicting key should not authorize arbitrary facts about unrelated keys.

### 10.3 Knowledge integration

Scientific, legal, and intelligence workflows often preserve contradictory testimony. Classical preprocessing may force a premature choice; indiscriminate reasoning may spread contradiction. A paraconsistent support layer offers a middle course. The finite calculus demonstrates the logical possibility of localizing conflict, though realistic systems require richer connectives, provenance, confidence, and revision policies.

### 10.4 Semantic paradox

For theories of truth, the key result is diagnostic. If diagonalization generates a negation fixed point, Boolean complement semantics collapses. A four-valued fixed point can instead be a stable glut. This does not by itself construct a compositional truth theory, but it identifies the algebraic resource such a theory can exploit.

## 11. Limitations

Three limitations are central.

First, $L$, $R$, and $B$ are abstract constants. The construction does not encode the Liar’s quotation and substitution, Russell’s unrestricted comprehension, or Berry’s dependence on descriptions and length. It proves coexistence for three distinct self-negating theorem codes, not a faithful reconstruction of all three historical arguments.

Second, the calculus has only negation and double-negation introduction. There are no conjunction, disjunction, implication, quantifiers, or comprehension principles. Consequently, the model isolates non-explosion rather than offering a general-purpose logic.

Third, finite self-soundness is limited reflection. The certificate’s interpretation explicitly incorporates the externally established soundness condition. No derivability predicate is internally arithmetized, and no claim is made about the classical consistency of a strong recursively axiomatized theory.

These restrictions are virtues for the theorem proved: they make the boundary transparent. They also mark the tasks required for a broader theory.

## 12. Future work

A first extension should construct a recursively generated language with quotation, substitution, a truth predicate, bounded description, and restricted comprehension. Its semantic operator on valuations should be monotone in an information order, allowing a least fixed point in which genuine diagonal Liar, Berry, and Russell sentences become distinct designated gluts while an arithmetic fragment remains non-designated where appropriate.

A second problem is conservativity. If a paraconsistent theory extends a classical base by truth and restricted comprehension, one would like every theorem in the truth-free and comprehension-free fragment to have already been a theorem of the classical base. This would sharpen finite non-explosion into isolation of inconsistency from ordinary mathematics.

A third direction concerns internal soundness in an effectively presented infinite system. The target is a recursively axiomatized paraconsistent theory that proves a formula expressing designation of its derivations, remains nontrivial, and does not prove every sentence in its classical arithmetic fragment. Such a result would have to separate paraconsistent reflection from classical consistency claims with great care.

Finally, there is a finite combinatorial question. For $n$ pairwise distinct self-negating theorem codes and at least one non-designated code, at least $n+1$ codes appear necessary, and the bound should be attainable. If separate true-only and gap witnesses are required, the expected sharp bound is $n+3$. Proving these bounds would turn the present seven-code example into an instance of a general minimality theorem.

## 13. Conclusion

A contradiction becomes catastrophic only when the inference system grants it catastrophic reach. The Boolean fixed-point theorem explains why self-negation cannot be represented by ordinary complement in a nontrivial truth algebra. Four-valued support semantics changes the geometry: positive and negative evidence occupy independent coordinates, and the glut $\mathbf{B}$ is a designated fixed point of negation.

Within the resulting seven-sentence calculus, the Liar, Russell, and Berry codes are pairwise distinct derivable gluts. Every derivation is semantically designated. The explicit false witness remains underivable, furnishing a direct counterexample to explosion. A distinguished theorem also serves as a finite soundness certificate under the stated interpretation.

The result is not the elimination of paradox but its localization. Self-negating sentences can be theorems; contradictions can be recorded honestly; and the theory can still say no.