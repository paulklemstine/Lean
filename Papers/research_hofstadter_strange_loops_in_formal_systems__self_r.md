# Coded Strange Loops: Incompleteness, Undefinable Truth, Infinite Fixed Points, and Tangled Hierarchies

**Aristotle**  
**July 21, 2026**

## Abstract

We study self-reference in an abstract but carefully stratified setting where diagonalization applies only to predicates represented by object-language codes. A coded diagonal system consists of sentences, predicate codes, a denotation relation, semantic truth, provability, negation, and a diagonal operation. Soundness and a represented unprovability predicate yield a Gödel sentence $G$ satisfying $T(G)\leftrightarrow\neg P(G)$. We prove that $G$ is semantically true and independent: neither $G$ nor its object-language negation is provable. We then establish a Tarski-style barrier. No code represents semantic untruth; closure of represented predicates under negation therefore implies that no code represents semantic truth. Equivalently, the denotation map from codes to semantic predicates is not surjective. For ranked systems with rank-separated codes denoting unprovability, we construct an injectively indexed infinite family $G_n$ of true independent fixed points. Finally, we define truth-preserving, proof-reflecting interpretations and prove that they transport true-but-unprovable sentences. A two-way interpretability cycle consequently places native and translated incompleteness witnesses at both levels, giving a precise model of a tangled hierarchy. The framework isolates the assumptions responsible for each result and avoids the inconsistent demand that diagonalization range over all metatheoretic predicates.

## 1. Introduction

Self-reference in logic is often introduced through slogans: a sentence “says of itself” that it is unprovable, or a truth predicate turns back upon itself to create a liar. Such language conveys the central intuition but can hide an essential distinction. A diagonal principle does not normally act on every predicate available to an external mathematician. It acts on predicates represented by formulas or codes inside a specified language. If one silently identifies represented predicates with all semantic predicates, one can build inconsistency into the assumptions before any theorem begins.

The aim of this paper is to give a self-contained axiomatic account of strange loops that preserves this distinction. The basic objects are sentences and codes for predicates on sentences. A denotation relation tells us which semantic predicate a code represents. A diagonal operation converts a code into a sentence that has the property denoted by that code. The semantic notions of truth and provability remain separate, connected by soundness. Unprovability is assumed representable; full semantic truth is not.

Within this framework, four phenomena emerge.

First, diagonalizing the represented unprovability predicate produces a Gödel sentence. Its fixed-point equation, together with soundness, proves both semantic truth and independence.

Second, diagonalizing a hypothetical code for semantic untruth would produce a sentence true exactly when it is not true. Hence no such code exists. Since represented predicates are closed under negation, a uniform code for semantic truth is also impossible. This is a Tarski-style undefinability result internal to the abstract interface.

Third, one fixed point can be expanded into infinitely many. The needed hypothesis is explicit: for each natural number there is an unprovability code whose diagonal has that prescribed rank. The ranks separate the resulting sentences, while the Gödel argument proves each one true and independent.

Fourth, incompleteness can circulate through a hierarchy. A translation preserving truth and reflecting proofs transports every true-but-unprovable sentence. Two systems interpreting each other therefore carry incompleteness witnesses in both directions.

These results clarify three meanings of “strange loop.” There is a fixed-point loop, in which a sentence receives a predicate applied to itself; a semantic obstruction, in which an attempted internal truth predicate creates a liar; and an interpretive loop, in which information travels through a cycle of theories. The same diagonal theme appears in all three, but the hypotheses and conclusions differ.

## 2. Coded diagonal systems

We begin with the basic structure.

### Definition 2.1 (Coded diagonal system)

A **coded diagonal system** consists of:

1. a collection $\mathcal S$ of sentences;
2. a collection $\mathcal C$ of predicate codes;
3. a denotation relation $D(c,s)$ for $c\in\mathcal C$ and $s\in\mathcal S$;
4. a provability predicate $P(s)$ and a semantic truth predicate $T(s)$;
5. an object-language negation operation $s\mapsto\neg_s s$;
6. a code-negation operation $c\mapsto\bar c$;
7. a diagonal operation $\delta:\mathcal C\to\mathcal S$;
8. a distinguished code $u\in\mathcal C$ for unprovability;

subject to the following axioms, for all appropriate $c$ and $s$:

**Soundness:**

$$
P(s)\Longrightarrow T(s).
$$

**Semantic sentence negation:**

$$
T(\neg_s s)\Longleftrightarrow\neg T(s).
$$

**Semantic code negation:**

$$
D(\bar c,s)\Longleftrightarrow\neg D(c,s).
$$

**Diagonal specification:**

$$
T(\delta(c))\Longleftrightarrow D(c,\delta(c)).
$$

**Representation of unprovability:**

$$
D(u,s)\Longleftrightarrow\neg P(s).
$$

The notation $\neg_s$ emphasizes that sentence negation is an operation producing another sentence, whereas $\neg$ on the right side is ordinary semantic negation.

### Remark 2.2 (Representability is restricted)

The function $c\mapsto D(c,\cdot)$ maps codes to predicates on $\mathcal S$, but it is not assumed to reach every predicate. Diagonalization is available for each code, not for every metatheoretically definable property. This restriction is mathematically indispensable: Section 4 proves that semantic truth and semantic untruth cannot lie in the image.

### Definition 2.3 (Strange loop)

Given a represented predicate code $c$, its diagonal sentence $\delta(c)$ is a **fixed-point strange loop** because its truth is equivalent to the predicate denoted by $c$ holding of that very sentence:

$$
T(\delta(c))\Longleftrightarrow D(c,\delta(c)).
$$

When $c=u$, this is specifically an **unprovability strange loop**.

This definition captures self-reference extensionally. It does not require a sentence to contain its own visible quotation. The loop is mediated by coding and diagonalization.

## 3. Gödel fixed points and independence

### Definition 3.1 (Gödel sentence)

The **Gödel sentence** of a coded diagonal system is

$$
G:=\delta(u),
$$

where $u$ is the distinguished code representing unprovability.

### Theorem 3.2 (Gödel fixed-point theorem)

The Gödel sentence satisfies

$$
T(G)\Longleftrightarrow\neg P(G).
$$

#### Proof sketch

By definition, $G=\delta(u)$. The diagonal specification gives

$$
T(\delta(u))\Longleftrightarrow D(u,\delta(u)).
$$

The representation property of $u$ turns the right side into $\neg P(\delta(u))$. Substituting $G$ yields the claim. $\square$

The fixed-point equation alone does not yet identify which side holds. Soundness resolves it.

### Theorem 3.3 (Unprovability and truth)

In every sound coded diagonal system,

$$
\neg P(G)
$$

and

$$
T(G).
$$

#### Proof sketch

Assume $P(G)$. Soundness gives $T(G)$. The forward implication in the fixed-point theorem then gives $\neg P(G)$, a contradiction. Hence $\neg P(G)$. The reverse implication in the fixed-point theorem now gives $T(G)$. $\square$

### Theorem 3.4 (Gödel independence theorem)

Neither the Gödel sentence nor its object-language negation is provable:

$$
\neg P(G)\ \wedge\ \neg P(\neg_s G).
$$

Moreover, $G$ is true.

#### Proof sketch

The previous theorem proves $\neg P(G)$ and $T(G)$. Suppose $P(\neg_s G)$. By soundness, $T(\neg_s G)$. The semantic law for sentence negation gives $\neg T(G)$, contradicting $T(G)$. Therefore $\neg P(\neg_s G)$. $\square$

### Discussion 3.5

The theorem uses semantic soundness rather than merely syntactic consistency. This makes the proof short and transparent: proof implies truth, while negation reverses truth. In concrete arithmetic, weaker hypotheses can support refined incompleteness theorems, but they require more syntactic infrastructure.

The result also distinguishes independence from mere unprovability. A sentence is independent here when neither it nor its object-language negation is derivable. The truth of $G$ is a separate semantic conclusion.

## 4. The Tarski barrier

The Gödel construction succeeds because unprovability is among the represented predicates. What happens if semantic truth or untruth is represented at the same level?

### Definition 4.1 (Uniform representation)

A code $c$ **uniformly represents semantic truth** if

$$
\forall s\in\mathcal S,\qquad D(c,s)\Longleftrightarrow T(s).
$$

It **uniformly represents semantic untruth** if

$$
\forall s\in\mathcal S,\qquad D(c,s)\Longleftrightarrow\neg T(s).
$$

The word “uniformly” matters. The claim concerns one code correctly classifying every sentence, not isolated sentences or restricted truth predicates.

### Theorem 4.2 (Tarski barrier for semantic untruth)

No code uniformly represents semantic untruth.

#### Proof sketch

Suppose a code $f$ satisfies

$$
D(f,s)\Longleftrightarrow\neg T(s)
$$

for every $s$. Let $L=\delta(f)$. By diagonalization and the assumed meaning of $f$,

$$
T(L)\Longleftrightarrow D(f,L)\Longleftrightarrow\neg T(L).
$$

If $T(L)$ holds, the forward implication yields $\neg T(L)$. If $T(L)$ fails, the reverse implication yields $T(L)$. Either case is contradictory. Thus no such $f$ exists. $\square$

This is the abstract liar obstruction. It also demonstrates why unrestricted semantic diagonalization would be inconsistent: applying it to untruth would force $T(L)\leftrightarrow\neg T(L)$.

### Theorem 4.3 (Undefinability of semantic truth)

No code uniformly represents semantic truth.

#### Proof sketch

Suppose $t$ represents truth, so $D(t,s)\leftrightarrow T(s)$ for every $s$. By closure under code negation,

$$
D(\bar t,s)\Longleftrightarrow\neg D(t,s)\Longleftrightarrow\neg T(s).
$$

Thus $\bar t$ would uniformly represent semantic untruth, contradicting Theorem 4.2. $\square$

### Corollary 4.4 (Non-surjectivity of denotation)

The semantic map

$$
\Phi:\mathcal C\longrightarrow \mathcal P(\mathcal S),
\qquad
\Phi(c)=\{s\in\mathcal S:D(c,s)\}
$$

is not surjective.

#### Proof sketch

If $\Phi$ were surjective, some code would map to the set

$$
\{s\in\mathcal S:\neg T(s)\}.
$$

That code would uniformly represent semantic untruth, contradicting Theorem 4.2. $\square$

### Discussion 4.5

Gödel incompleteness and Tarski undefinability are related but not identical. The Gödel sentence is a stable fixed point of unprovability. Soundness determines that it is true and unprovable. A hypothetical liar sentence would be an unstable fixed point of semantic untruth, producing outright contradiction. Therefore the correct conclusion is not that diagonalization itself is paradoxical; rather, semantic untruth cannot be among the predicates represented at the same diagonal level.

The theorem permits stratified truth. A richer language may represent truth for a lower-level language, provided the truth predicate does not range over the very sentences to which the same diagonal mechanism applies. What fails is a universal, same-level truth predicate closed under the relevant self-reference.

## 5. Ranked systems and infinitely many strange loops

A single Gödel sentence establishes incompleteness. To obtain infinitely many distinct sentences, semantic equivalence is not enough; one needs a mechanism certifying syntactic separation.

### Definition 5.1 (Ranked diagonal system)

A **ranked diagonal system** is a coded diagonal system equipped with:

1. a rank function $r:\mathcal S\to\mathbb N$;
2. for each $n\in\mathbb N$, a code $u_n\in\mathcal C$;

such that, for every $n$ and $s$,

$$
D(u_n,s)\Longleftrightarrow\neg P(s),
$$

and

$$
r(\delta(u_n))=n.
$$

The codes $u_n$ have the same semantic extension, but their diagonal outputs are forced into distinct rank classes.

### Definition 5.2 (Ranked Gödel family)

For each $n\in\mathbb N$, define

$$
G_n:=\delta(u_n).
$$

### Lemma 5.3 (Prescribed rank)

For every $n\in\mathbb N$,

$$
r(G_n)=n.
$$

#### Proof sketch

This is the rank-separation axiom applied to the definition $G_n=\delta(u_n)$. $\square$

### Lemma 5.4 (Ranked fixed points)

For every $n\in\mathbb N$,

$$
T(G_n)\Longleftrightarrow\neg P(G_n).
$$

#### Proof sketch

Apply the diagonal specification to $u_n$, then use that $u_n$ represents unprovability. $\square$

### Theorem 5.5 (Truth and independence at every rank)

For every $n\in\mathbb N$,

$$
T(G_n)\ \wedge\ \neg P(G_n)\ \wedge\ \neg P(\neg_s G_n).
$$

#### Proof sketch

The argument of Theorems 3.3 and 3.4 applies separately to each fixed point in Lemma 5.4. If $G_n$ were provable, soundness and the fixed-point equivalence would contradict that proof. Hence $G_n$ is unprovable and therefore true. If $\neg_s G_n$ were provable, soundness and semantic negation would contradict the truth of $G_n$. $\square$

### Lemma 5.6 (Injectivity)

The map $n\mapsto G_n$ is injective.

#### Proof sketch

Suppose $G_m=G_n$. Apply the rank function to both sides. Lemma 5.3 gives

$$
m=r(G_m)=r(G_n)=n.
$$

Thus $m=n$. $\square$

### Theorem 5.7 (Infinitely many independent strange loops)

The set

$$
\{G_n:n\in\mathbb N\}
$$

is infinite. Every member is a true fixed point of unprovability, and neither it nor its object-language negation is provable.

#### Proof sketch

By Lemma 5.6, the image of the infinite set $\mathbb N$ under $n\mapsto G_n$ is infinite. The fixed-point, truth, and independence properties follow from Lemma 5.4 and Theorem 5.5. $\square$

### Discussion 5.8

The theorem proves a conditional form of the conjecture that sufficiently expressive systems contain infinitely many strange loops. “Sufficiently expressive” is made precise by the availability of rank-separated codes for unprovability. Without rank separation, many codes may collapse to the same diagonal sentence; infinitude of codes alone does not prove infinitude of fixed points.

In a concrete syntax, rank might be formula length, parse-tree depth, or another structural measure. One prospective construction pads formulas with syntactically distinct tautological material while preserving their represented predicate. Establishing that construction requires a specific coding of syntax and substitution, which lies beyond the abstract framework.

## 6. Interpretations and transport of incompleteness

Strange loops need not remain confined to one system. We now formulate translations strong enough to move semantic truth and proof-theoretic non-derivability.

### Definition 6.1 (Truth-preserving, proof-reflecting interpretation)

Let $S$ and $R$ be coded diagonal systems. An **interpretation** $I:S\to R$ assigns to every sentence $s$ of $S$ a sentence $I(s)$ of $R$ and satisfies:

**Truth preservation and reflection:**

$$
T_R(I(s))\Longleftrightarrow T_S(s).
$$

**Proof reflection:**

$$
P_R(I(s))\Longrightarrow P_S(s).
$$

The first condition is an equivalence because the translated sentence is required to match the source semantics exactly. The second points backward: a target proof must induce source provability. This direction is precisely what transports unprovability forward.

### Theorem 6.2 (Transport of incompleteness)

If $s$ is true but unprovable in $S$, then $I(s)$ is true but unprovable in $R$. Formally, from

$$
T_S(s)\wedge\neg P_S(s)
$$

one obtains

$$
T_R(I(s))\wedge\neg P_R(I(s)).
$$

#### Proof sketch

Truth follows from $T_R(I(s))\leftrightarrow T_S(s)$. For unprovability, suppose $P_R(I(s))$. Proof reflection gives $P_S(s)$, contradicting the hypothesis $\neg P_S(s)$. $\square$

### Definition 6.3 (Two-level tangled hierarchy)

A **two-level tangled hierarchy** consists of a lower coded diagonal system $L$, an upper coded diagonal system $U$, an interpretation

$$
I:L\to U,
$$

and an interpretation

$$
J:U\to L,
$$

both truth-preserving and proof-reflecting.

Let $G_L$ and $G_U$ denote the native Gödel sentences of $L$ and $U$, respectively.

### Theorem 6.4 (Incompleteness on both sides of a tangle)

In every two-level tangled hierarchy, all four of the following hold:

1. $G_L$ is true and unprovable in $L$;
2. $I(G_L)$ is true and unprovable in $U$;
3. $G_U$ is true and unprovable in $U$;
4. $J(G_U)$ is true and unprovable in $L$.

#### Proof sketch

Theorem 3.3 gives truth and unprovability of each native Gödel sentence in its own system. Apply Theorem 6.2 to $I$ and $G_L$ to obtain the translated witness in $U$. Apply it again to $J$ and $G_U$ to obtain the translated witness in $L$. $\square$

### Discussion 6.5

This theorem captures a tangled hierarchy without claiming that the two systems are identical or that translations are inverses. Each level has a native incompleteness witness, and each receives another witness through the interpretation from the other level. The cycle transports obstruction rather than dissolving it.

Proof reflection is indispensable to this argument. Truth preservation alone cannot rule out the possibility that the target system proves a translated sentence even though the source does not. Conversely, full proof preservation is not required for the stated direction; only reflection of target proofs back to the source is used.

## 7. Algorithms and finite demonstrations

The principal theorems concern abstract truth and provability, so no finite program can decide the full predicates in arbitrary sufficiently expressive systems. Nevertheless, finite data structures can demonstrate the logical dependency graph and the rank-separation argument.

### Algorithm 7.1 (Ranked witness generator)

Given a finite cutoff $N$, output symbolic witnesses $G_0,\ldots,G_{N-1}$ with rank labels and theorem-derived statuses.

1. For each $n$ from $0$ to $N-1$, create a record labeled $G_n$.
2. Assign rank $n$.
3. Record the fixed-point schema $T(G_n)\leftrightarrow\neg P(G_n)$.
4. Under soundness, record $T(G_n)$, $\neg P(G_n)$, and $\neg P(\neg_sG_n)$.
5. Check that rank labels are pairwise distinct.

The running time is $O(N)$ for generation and $O(N)$ for distinctness when a set is used; storage is $O(N)$. This is an illustration of the theorem, not a decision procedure for mathematical truth.

### Algorithm 7.2 (Interpretation-cycle propagation)

Represent two systems and the directed translations $I:L\to U$ and $J:U\to L$. Seed the records $(L,G_L)$ and $(U,G_U)$ as true but unprovable. Propagate each seed across its outgoing interpretation. The transport theorem certifies the same status for $(U,I(G_L))$ and $(L,J(G_U))$.

For a graph with $V$ levels and $E$ interpretations, a breadth-first propagation of labeled witnesses takes $O(V+E)$ per seed, ignoring the cost of constructing translations. In the two-level case the process is constant-sized.

### Algorithm 7.3 (Liar-obstruction truth table)

To display why a semantic-untruth code is impossible, enumerate the two possible values of $T(L)$. The demanded equivalence $T(L)\leftrightarrow\neg T(L)$ fails for both values. This constant-time truth table exposes the contradiction but does not replace the diagonal argument that would create $L$ from the hypothetical code.

## 8. Applications and conceptual consequences

### 8.1 Object language versus metalanguage

The framework provides a clean discipline for separating internal syntax from external semantics. Codes belong to the object-level representational apparatus. Truth is evaluated externally. Some external predicates may be represented, as unprovability is assumed to be, but representability must be proved or postulated individually. It cannot be inferred merely because a predicate is meaningful in the metalanguage.

### 8.2 Truth hierarchies

The Tarski barrier motivates stratification. A level $k+1$ may contain a truth predicate for level $k$ without containing a same-level universal truth predicate. As long as reference edges point downward, the hierarchy can remain acyclic. Closing a reference cycle reintroduces the diagonal obstruction. The two-level tangle theorem studies cycles of interpretations rather than truth predicates, but the same graph-theoretic viewpoint suggests a broader theory of semantic levels.

### 8.3 Specification and reflective computation

Computer systems routinely encode programs as data and inspect their own descriptions. Diagonal reasoning warns that universal same-level specifications can encounter fixed-point barriers. The abstract theorems do not imply that ordinary reflective software is paradoxical. Rather, they identify which combination is dangerous: sufficient self-application, a total internal semantic classifier, and closure properties strong enough to form negation.

### 8.4 Networks of theories

Interpretations are often organized as directed graphs rather than simple chains. The transport theorem says that true-but-unprovable witnesses move along edges that preserve truth and reflect proofs. Cycles therefore distribute incompleteness throughout a network. This perspective separates local incompleteness, generated natively at a vertex, from imported incompleteness, transported along an edge.

## 9. Scope and limitations

The framework is abstract. It assumes a diagonal operation and a code for unprovability rather than constructing them from arithmetic syntax. Consequently, it isolates the logical core but does not by itself establish that a particular recursively axiomatized arithmetic theory satisfies the assumptions.

The rank-separated infinitude theorem is likewise conditional. Rank separation is supplied as structure, not derived. A concrete realization must show how to generate semantically equivalent unprovability predicates whose diagonal sentences have distinct sizes, depths, or other ranks.

Soundness is stronger than the consistency hypotheses used in classical refinements of incompleteness. Replacing it with consistency, $1$-consistency, $\omega$-consistency, or Rosser-style assumptions would require an explicit derivation calculus and representability theory.

Finally, the interpretation theorem transports true unprovability but does not claim that arbitrary interpretations preserve independence of negations. Additional compatibility with sentence negation and proof behavior would support such strengthened conclusions.

## 10. Future research

Several extensions would connect this abstract theory to concrete metamathematics.

1. **Arithmetic realization.** Build sentences and derivations for a recursively axiomatized extension of Robinson arithmetic, together with Gödel coding, substitution, representability, and a syntactic diagonal lemma.

2. **Derived rank separation.** Construct rank-separated unprovability formulas by syntactic padding and prove both preservation of meaning and strict rank growth.

3. **Sharper consistency assumptions.** Distinguish consistency, $1$-consistency, and $\omega$-consistency, and develop Gödel and Rosser arguments under their standard hypotheses.

4. **Derivability logic.** Establish the Hilbert–Bernays–Löb conditions for an explicit proof predicate, leading to Löb’s theorem and the second incompleteness theorem.

5. **Graph-shaped tangled hierarchies.** Replace two levels by a directed graph or category of systems and interpretations. Characterize cycles that transport truth and unprovability.

6. **Intensional distinctions.** Separate literal syntactic inequality, alpha-equivalence, provable equivalence, and semantic equivalence among fixed points.

7. **Stratified truth.** Construct an acyclic hierarchy with truth predicates for lower levels and identify the exact obstruction created when a reference edge closes a cycle.

8. **Concrete extraction.** Once syntax is computational, implement examples of coding, substitution, diagonalization, and rank growth.

## 11. Conclusion

Coded diagonal systems provide a precise setting for strange loops. The decisive distinction is between all semantic predicates and those predicates represented by object-language codes. Within that boundary, a represented unprovability predicate yields a Gödel sentence that is true and independent in every sound system. Crossing the boundary by demanding a uniform same-level code for semantic truth or untruth triggers the Tarski barrier. Adding rank separation produces infinitely many distinct independent fixed points. Adding truth-preserving, proof-reflecting interpretations transports incompleteness between systems and around cycles.

Thus self-reference has more than one mathematical outcome. Applied to provability, it reveals truths beyond proof. Applied to an alleged universal truth classifier, it reveals non-representability. Routed through interpretations, it reveals how incompleteness persists across tangled hierarchies. The staircase does not collapse; it acquires loops, and those loops precisely mark the limits of internal description.
