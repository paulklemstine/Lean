# Dream Logic, Finitary Information Geometry, and Algebraic Forgetting

**Aristotle**  
**19 July 2026**

## Abstract

We develop a self-contained model of reasoning with signed literals in which contradictory evidence can coexist without entailing unrelated claims. Belief revision inserts a literal and retracts its opposite, producing a local, non-monotone, and order-sensitive dynamics. Semantic consistency is shown to coincide exactly with conflict-freedom in the graph of complementary literals, and revision preserves this invariant. Finite belief states are interpreted as finitarily open subsets: they are closed under finite unions and intersections but fail the arbitrary-union axiom of ordinary topology. The countable union of singleton subsets of $\mathbb N$ provides the decisive obstruction. The semantic and finitary views combine in a bridge theorem asserting that revision carries finite consistent states to finite conflict-free states.

We then extend the perspective from unordered belief states to ordered experience streams. A compositional memory is a monoid homomorphism from the free monoid of streams to a representation monoid. Every finite-state memory over a nonempty alphabet is necessarily lossy; completely erased streams form a submonoid; and the observable memory algebra is canonically isomorphic to the quotient of streams by observational indistinguishability. Targeted symbol deletion realizes a universal quotient: every compatible compositional summary factors uniquely through it. Algorithms and finite examples illustrate revision, conflict detection, finitary-union obstruction, selective forgetting, and memory collisions.

## 1. Introduction

Information encountered in practice need not be globally consistent. Databases merge reports from fallible sources, sensors disagree, narratives admit incompatible descriptions, and memory is revised after later experience. Classical consequence is designed for truth-preserving deduction from consistent premises; in its usual form, accepting both $p$ and $\neg p$ allows any conclusion. This principle of explosion is unsuitable when acceptance records currently held evidence rather than settled truth.

The aim here is not to weaken reasoning indiscriminately, but to isolate a small mathematical structure in which four phenomena can be studied precisely:

1. contradictory evidence remains local rather than explosive;
2. revision can retract beliefs and depends on temporal order;
3. finite information fragments support finite set operations but not arbitrary accumulation;
4. finite or selective memory identifies histories through an algebraic quotient.

The first three phenomena are represented using signed sets. Every atom has a positive and a negative literal. A state is an arbitrary set of literals, so it may support neither sign, one sign, or both. Consequence is intentionally minimal: a state entails exactly the literals it contains. Revision by one literal removes its complement and inserts the new literal.

A complementary-attack graph then connects the semantics to abstract argumentation. Its only edges join opposite signs of the same atom. Consequently, consistency is exactly conflict-freedom. When states are finite, they can also be regarded as elements of the family of finite subsets of the literal space. This family behaves like an open-set system for finite operations, but it is not generally a topology because arbitrary unions can be infinite. We call its members finitarily open to emphasize the distinction.

The final part studies ordered histories rather than sets. Streams form a free monoid under concatenation, and a compositional memory is a monoid homomorphism. Its kernel congruence identifies histories with the same observable representation. Standard counting and quotient principles then produce a unified description of information loss.

A recurring theme is locality. Contradiction concerns one atom. Revision edits one complementary pair. Conflict-freedom checks complementary pairs. Finiteness bounds the current support. Memory quotienting identifies only what observation cannot distinguish. These local mechanisms yield global invariants without forcing either consistency or perfect recall.

## 2. Signed states and paraconsistent consequence

### 2.1 Literals, opposites, and entailment

Let $A$ be a set of atoms. Define the literal space by

$$
L(A)=A\times\{+,-\}.
$$

For $\ell=(a,s)$, its **opposite** $\bar\ell$ has the same atom and the other sign. Thus

$$
\overline{(a,+)}=(a,-),\qquad \overline{(a,-)}=(a,+).
$$

The opposite operation preserves the underlying atom, has no fixed points, and is involutive:

$$
\operatorname{atom}(\bar\ell)=\operatorname{atom}(\ell),\qquad
\bar\ell\ne\ell,\qquad
\overline{\bar\ell}=\ell.
$$

A **belief state** is any subset $B\subseteq L(A)$. We define the consequence relation by membership:

$$
B\models\ell\quad\Longleftrightarrow\quad \ell\in B.
$$

An atom $a$ is **contradictory in $B$** if both signs occur:

$$
(a,+)\in B\quad\text{and}\quad(a,-)\in B.
$$

A state is **consistent** when no atom is contradictory. Notice that consistency is a property, not a prerequisite for being a state.

### 2.2 Non-explosion

**Theorem 2.1 (Contradiction without explosion).** Let $a,b\in A$ with $a\ne b$, and set

$$
B_a=\{(a,+),(a,-)\}.
$$

Then $a$ is contradictory in $B_a$, while $B_a\not\models(b,+)$.

**Proof sketch.** Both signed literals over $a$ occur by construction. The only members of $B_a$ have underlying atom $a$, whereas $(b,+)$ has underlying atom $b\ne a$. Hence $(b,+)\notin B_a$. $\square$

This is paraconsistency in its most direct form. The state records a conflict but remains nontrivial. The hypothesis $a\ne b$ is essential: without it, the allegedly unrelated conclusion could be one of the two literals already present.

The theorem does not propose a general deductive calculus. Rather, it gives a semantic base layer suitable for evidence stores: unsupported literals remain unsupported even when another atom is contradictory. Richer rules may be added if they preserve the desired locality.

## 3. Non-monotone revision

### 3.1 Definition and immediate behavior

For a state $B$ and literal $\ell$, define **revision by $\ell$** as

$$
R_\ell(B)=\{\ell\}\cup\left(B\setminus\{\bar\ell\}\right).
$$

This is a local overwrite. It removes the unique complementary literal and inserts the requested one; every literal over every other atom is unchanged.

**Theorem 3.1 (Acceptance and retraction).** For every state $B$ and literal $\ell$,

$$
R_\ell(B)\models\ell
\qquad\text{and}\qquad
R_\ell(B)\not\models\bar\ell.
$$

**Proof sketch.** The first assertion follows because $\ell$ is explicitly inserted. For the second, $\bar\ell$ is deleted from $B$, and it cannot equal the inserted literal because the opposite operation has no fixed point. $\square$

Two useful consequences follow. Revision is idempotent at a fixed literal,

$$
R_\ell(R_\ell(B))=R_\ell(B),
$$

and it changes no literal whose underlying atom differs from that of $\ell$. These observations follow directly from the set formula and motivate the future study of revision histories.

### 3.2 Failure of monotonicity

A state transformer $T$ is inflationary if $B\subseteq T(B)$ for every $B$. Revision is not inflationary.

**Theorem 3.2 (Genuine non-monotonicity).** For every literal $\ell$, if

$$
C_\ell=\{\ell,\bar\ell\},
$$

then

$$
C_\ell\nsubseteq R_\ell(C_\ell).
$$

**Proof sketch.** The old state contains $\bar\ell$. By Theorem 3.1, the revised state does not. Therefore at least one former member has been lost. $\square$

Retraction distinguishes revision from mere expansion. This is the appropriate behavior when later information replaces a contrary earlier commitment.

### 3.3 Order sensitivity

Updates at the same atom also fail to commute.

**Theorem 3.3 (Contrary revisions do not commute).** For every state $B$ and literal $\ell$,

$$
R_{\bar\ell}(R_\ell(B))\ne R_\ell(R_{\bar\ell}(B)).
$$

**Proof sketch.** By Theorem 3.1, the left side contains $\bar\ell$ and excludes $\ell$. The right side contains $\ell$ and excludes $\bar\ell$. Since $\ell\ne\bar\ell$, the states differ. $\square$

Thus contrary revision obeys a last-write-wins law. Revisions at different atoms, by contrast, affect disjoint complementary pairs and therefore commute. This contrast suggests normal forms based on the last occurrence of each revised atom.

## 4. Complementary attack and consistency

### 4.1 The attack graph

Define the **complementary attack relation** on $L(A)$ by

$$
\ell\rightsquigarrow k
\quad\Longleftrightarrow\quad
k=\bar\ell.
$$

A set $B\subseteq L(A)$ is **conflict-free** when it contains no pair $\ell,k\in B$ with $\ell\rightsquigarrow k$. Since opposition is symmetric, this relation may be pictured as a graph consisting of one edge between $(a,+)$ and $(a,-)$ for each atom $a$.

**Theorem 4.1 (Consistency equals conflict-freedom).** A belief state $B$ is consistent if and only if it is conflict-free under complementary attack.

**Proof sketch.** If $B$ is inconsistent, some atom $a$ contributes both $(a,+)$ and $(a,-)$; these literals attack one another, so $B$ is not conflict-free. Conversely, an attack within $B$ consists of a literal and its opposite. They share an atom and carry opposite signs, so that atom is contradictory. $\square$

This exact equivalence is specific to complementary attack. It does not identify consistency with conflict-freedom for an arbitrary argumentation relation.

### 4.2 Revision preserves consistency

**Theorem 4.2 (Consistency preservation).** If $B$ is consistent, then $R_\ell(B)$ is consistent for every literal $\ell$.

**Proof sketch.** Let $a$ be the atom underlying $\ell$. Revision deletes $\bar\ell$ before inserting $\ell$, so the revised state cannot contain both signs over $a$. For any atom $b\ne a$, revision changes neither signed literal over $b$; a contradiction there would already have existed in $B$. Therefore no atom is contradictory after revision. $\square$

Combining Theorems 4.1 and 4.2 shows that revision maps conflict-free states to conflict-free states whenever conflict is defined by opposition.

For a finite atom set of size $n$, the consistent states form a simplicial complex. Each atom offers three consistent local statuses—absent, positive, or negative—so there are $3^n$ consistent states. The maximal states choose exactly one sign for every atom and number $2^n$. Revision moves between faces by fixing one coordinate to a chosen sign.

## 5. Finitary openness

### 5.1 Finite subsets as information regions

Let $X$ be any set. A subset $U\subseteq X$ is **finitarily open** if $U$ is finite. We use this term to express finite accessibility while avoiding the false claim that these sets always form an ordinary topology.

The elementary closure laws are as follows.

**Proposition 5.1 (Finite lattice laws).** The empty subset of $X$ is finitarily open. If $U$ and $V$ are finitarily open, then $U\cap V$ and $U\cup V$ are finitarily open. More generally, if $\mathcal U$ is a finite family of finite subsets of $X$, then

$$
\bigcup\mathcal U
$$

is finite.

**Proof sketch.** The empty set has cardinality zero. Subsets of finite sets are finite, giving the intersection claim. Cardinalities satisfy $|U\cup V|\le |U|+|V|$. Induction on the size of $\mathcal U$ proves the finite-family statement. $\square$

Singletons are therefore finitarily open. On a finite carrier, every subset is finite and the construction coincides with the discrete topology. The distinction appears on infinite carriers.

### 5.2 The arbitrary-union boundary

**Theorem 5.2 (Union of natural-number singletons).**

$$
\bigcup_{n\in\mathbb N}\{n\}=\mathbb N.
$$

**Proof sketch.** Every element of the union belongs to some singleton $\{n\}$ and is therefore a natural number. Conversely, each $m\in\mathbb N$ belongs to the singleton indexed by $m$. $\square$

**Theorem 5.3 (Arbitrary-union obstruction).** Every singleton $\{n\}\subseteq\mathbb N$ is finitarily open, but their countable union is not finitarily open.

**Proof sketch.** Each singleton is finite. By Theorem 5.2 their union is $\mathbb N$, which is infinite. $\square$

Ordinary topologies must contain the whole carrier and must be closed under arbitrary unions. Consequently, on an infinite $X$, the family of finite subsets is not a topology: it omits $X$ and fails arbitrary-union closure. The accurate structure is a finitary lattice or pretopological information system.

### 5.3 Revision remains finitary

**Theorem 5.4 (Finiteness preservation).** If $B$ is a finite belief state, then $R_\ell(B)$ is finite.

**Proof sketch.** The set $B\setminus\{\bar\ell\}$ is a subset of the finite set $B$, and adjoining one element preserves finiteness. $\square$

**Theorem 5.5 (Revision bridge).** Let $B$ be a finite consistent belief state. For every literal $\ell$, the revised state $R_\ell(B)$ is finite and conflict-free under complementary attack.

**Proof sketch.** Finiteness follows from Theorem 5.4. Consistency follows from Theorem 4.2, and Theorem 4.1 converts consistency into conflict-freedom. $\square$

This theorem joins three readings of the same operation. Semantically, revision remains consistent. Combinatorially, it remains in the conflict-free complex. Resource-theoretically, it remains a finite information fragment.

## 6. Ordered experience and algebraic memory

### 6.1 Streams and compositional memories

Let $\Sigma$ be an alphabet of experience symbols. The set $\Sigma^*$ of finite words, including the empty word $\varepsilon$, is the **free monoid** on $\Sigma$ under concatenation. A **compositional memory** with representation monoid $(R,\cdot,1)$ is a map

$$
M:\Sigma^*\to R
$$

satisfying

$$
M(uv)=M(u)\cdot M(v),\qquad M(\varepsilon)=1.
$$

Define the set of **completely erased streams** by

$$
K_M=\{u\in\Sigma^*:M(u)=1\}.
$$

Define **observational indistinguishability** by

$$
u\sim_M v\quad\Longleftrightarrow\quad M(u)=M(v).
$$

Because $M$ respects concatenation, $\sim_M$ is a monoid congruence: if $u\sim_M u'$ and $v\sim_M v'$, then $uv\sim_M u'v'$.

### 6.2 Finite memory is necessarily lossy

**Theorem 6.1 (Finite-memory loss).** Suppose $\Sigma$ is nonempty and $R$ is finite. For every compositional memory $M:\Sigma^*\to R$, there exist distinct streams $u\ne v$ such that

$$
M(u)=M(v).
$$

**Proof sketch.** Choose a symbol $a\in\Sigma$. The words $\varepsilon,a,a^2,a^3,\ldots$ are all distinct, so $\Sigma^*$ is infinite. A function from an infinite set to finite $R$ cannot be injective. Therefore two distinct streams share a representation. $\square$

Equivalently, the indistinguishability congruence has a non-singleton class. The result uses only finiteness and a nonempty alphabet; no special memory architecture is required.

**Theorem 6.2 (Erased streams form a submonoid).** For every compositional memory $M$, the set $K_M$ contains $\varepsilon$ and is closed under concatenation.

**Proof sketch.** Since $M(\varepsilon)=1$, the empty stream lies in $K_M$. If $u,v\in K_M$, then

$$
M(uv)=M(u)M(v)=1\cdot1=1,
$$

so $uv\in K_M$. $\square$

The set $K_M$ records complete erasure, whereas the full congruence $\sim_M$ records every observational collision. In general monoids, the latter contains more information than the former.

### 6.3 Observable memory as a quotient

Let $\Sigma^*/{\sim_M}$ denote the monoid of equivalence classes under observational indistinguishability, and let $\operatorname{im}(M)=\{M(u):u\in\Sigma^*\}$.

**Theorem 6.3 (Observable-quotient theorem).** The map

$$
\Phi:\Sigma^*/{\sim_M}\longrightarrow\operatorname{im}(M),
\qquad
\Phi([u])=M(u),
$$

is a monoid isomorphism.

**Proof sketch.** The definition is independent of the representative because $[u]=[v]$ means $M(u)=M(v)$. It preserves multiplication by compositionality. It is surjective by the definition of the image. If $\Phi([u])=\Phi([v])$, then $M(u)=M(v)$, hence $u\sim_M v$ and $[u]=[v]$; thus it is injective. $\square$

Combined with Theorems 6.1 and 6.2, this yields a three-part connector: finite memory forces collisions, complete erasures form a submonoid, and observable states are exactly quotient classes of streams.

## 7. Targeted forgetting and universality

Choose a retention predicate $\rho:\Sigma\to\{0,1\}$. Define targeted forgetting $F_\rho:\Sigma^*\to\Sigma^*$ on symbols by

$$
F_\rho(a)=
\begin{cases}
a,&\rho(a)=1,\\
\varepsilon,&\rho(a)=0,
\end{cases}
$$

and extend it compositionally to words. Operationally, $F_\rho$ scans a stream from left to right, deletes unretained symbols, and preserves the retained symbols in their original order.

**Proposition 7.1 (Marked symbols are erased).** If $\rho(a)=0$, then $F_\rho(a)=\varepsilon$, so the one-symbol stream $a$ belongs to the erased-stream submonoid of $F_\rho$.

**Proof sketch.** This is the deleting branch of the definition. $\square$

The quotient by equality of filtered outputs is isomorphic to the submonoid of streams consisting solely of retained output. More strongly, targeted forgetting has a universal property.

**Theorem 7.2 (Universal property of targeted forgetting).** Let $G:\Sigma^*\to S$ be a compositional map into a monoid $S$. Assume that whenever $F_\rho(u)=F_\rho(v)$, one also has $G(u)=G(v)$. Then there exists a unique monoid homomorphism

$$
\overline G:\Sigma^*/{\sim_{F_\rho}}\to S
$$

such that

$$
G=\overline G\circ q,
$$

where $q(u)=[u]$ is the quotient map.

**Proof sketch.** Define $\overline G([u])=G(u)$. The compatibility assumption ensures that this does not depend on the representative. Multiplicativity follows from that of $G$. Every quotient class has a representative, so the factorization determines $\overline G$ uniquely. $\square$

Thus the quotient is the most economical compositional domain on which every summary compatible with the chosen deletions can operate.

## 8. Algorithms and complexity

### 8.1 Local literal revision

Represent a literal as a pair $(a,s)$ and a finite state as a hash set. To revise by $(a,s)$, remove $(a,-s)$ if present and insert $(a,s)$. Expected running time is $O(1)$ with hashing and worst-case additional space is $O(1)$ beyond the state. With a balanced tree, time is $O(\log |B|)$.

For a history of $m$ revisions, sequential application costs expected $O(m)$. A normal-form implementation can keep one final sign per mentioned atom; this also costs expected $O(m)$ time and $O(k)$ space for $k$ distinct atoms, although a general uniqueness theorem for revision histories remains future work.

### 8.2 Consistency and conflict checks

Scan all literals while recording the signs seen for each atom. Encountering both signs reports a contradiction and, equivalently, an attack within the state. For $n=|B|$, hash-based time is expected $O(n)$ and storage is $O(n)$. This algorithm simultaneously tests semantic consistency and complementary conflict-freedom by Theorem 4.1.

### 8.3 Selective stream filtering

Scan a word of length $m$, append a symbol precisely when $\rho(a)=1$, and preserve order. Time is $O(m)$ and output space is $O(r)$, where $r\le m$ is the number of retained symbols. Comparing filtered outputs decides observational indistinguishability for targeted forgetting in $O(m+n)$ time for inputs of lengths $m$ and $n$.

### 8.4 Finite collision search

Given a finite-state memory evaluator and a finite enumeration of candidate streams, store the first stream observed at each representation. When a representation repeats, return the two distinct streams. If $N$ streams are examined and representation evaluation costs $T$, the search costs expected $O(NT)$ time and $O(\min(N,|R|))$ stored entries. Theorem 6.1 guarantees a collision when the enumeration eventually covers sufficiently many distinct streams and $R$ is finite.

## 9. Examples and applications

For atoms $a$ and $b$, the state $\{(a,+),(a,-)\}$ is contradictory but says nothing about either sign of $b$. Revising by $(a,+)$ yields $\{(a,+)\}$; revising next by $(a,-)$ yields $\{(a,-)\}$. If the initial state also contains $(b,+)$, that unrelated literal survives both revisions.

For finitary openness, the first $N$ singleton subsets of $\mathbb N$ have union $\{0,\ldots,N-1\}$ and cardinality $N$. Every finite stage remains admissible. The limiting family indexed by all natural numbers has infinite union, demonstrating that the obstruction is genuinely infinitary rather than visible at any fixed finite stage.

For targeted forgetting, let the alphabet be $\{\texttt{red},\texttt{noise},\texttt{blue}\}$ and retain only colors. The streams

$$
(\texttt{red},\texttt{noise},\texttt{blue})
\quad\text{and}\quad
(\texttt{red},\texttt{blue})
$$

have identical filtered memories. Their difference is real at the stream level but invisible to this observer.

A simple finite compositional memory counts word length modulo $k$. It maps concatenation to addition modulo $k$. The empty stream and any stream of length $k$ collide, making the finite-memory theorem concrete. Streams whose lengths are multiples of $k$ form the erased submonoid.

These constructions apply naturally to inconsistent databases, editable knowledge bases, event logs with redaction, finite-state summaries, and local conflict analysis. The mathematical claims are modest enough to remain transparent while separating several notions often conflated: inconsistency versus triviality, revision versus accumulation, finite closure versus topology, and erasure versus general indistinguishability.

## 10. Discussion

The signed-state model is deliberately extensional. It says what is currently accepted, not why. This simplicity makes non-explosion immediate and revision local. More expressive consequence relations could add rules between atoms, but then non-explosion would require conditions ensuring that contradictory support does not propagate indiscriminately.

The topological language requires care. Finite subsets of an infinite carrier are not the open sets of a topology. They do satisfy empty-set, finite-intersection, and finite-union laws, and they accurately represent finite information fragments. The arbitrary-union obstruction should therefore be read as a boundary theorem: it identifies exactly why ideal or domain-theoretic completion is needed to accommodate infinite states.

The algebraic memory model complements rather than duplicates belief revision. Revision chooses the current sign at a coordinate; memory maps ordered histories into representations. A current state may forget the order and multiplicity of previous updates, while a stream quotient describes precisely which histories become observationally equal. The universal property of targeted forgetting ensures that compatible downstream summaries depend only on the retained quotient class.

## 11. Future work

A first direction is a last-occurrence normal-form theorem: every finite revision history should reduce uniquely to the final sign assigned to each mentioned atom, while untouched atoms preserve their initial status. Distinct-atom revisions commute, and same-atom revisions obey last-write-wins, providing the expected rewriting laws.

Second, for finite atom sets, consistent states and one-atom revisions should form an oriented cubical or cross-polytopal geometry. Strongly connected components may be classified by which atoms have acquired a sign, depending on whether deletion-only moves are admitted.

Third, the ideal completion of finite signed states should recover arbitrary signed states under a Scott-style topology. Every arbitrary state is the directed union of its finite fragments, suggesting a canonical repair of arbitrary-union failure.

Fourth, non-explosion should persist under irrelevant revision histories: if a literal over atom $b$ is absent and no update mentions $b$, then its absence should remain invariant even when another atom is repeatedly revised through contradictory states.

Finally, one may ask how much structure can be reconstructed from the conflict-free complex and its oriented revision dynamics. Maximal faces encode total consistent assignments, while directed local overwrites may determine the partition of literals into complementary pairs up to relabeling.

## 12. Conclusion

Signed belief states provide a minimal model in which contradiction coexists without explosion. Local revision accepts new evidence, retracts its opposite, fails monotonicity, and records temporal order. Complementary attack translates consistency exactly into conflict-freedom, while revision preserves the resulting combinatorial invariant. Finite states support robust finite operations but encounter a precise arbitrary-union obstruction on infinite carriers.

For ordered experience streams, compositional memory inevitably loses distinctions when its representation is finite. Complete erasures form a submonoid, all observational collisions form a congruence, and the quotient by that congruence is exactly the observable memory algebra. Selective deletion realizes this quotient universally.

The combined framework gives precise answers to four questions: how can conflict remain local, how can beliefs be corrected, where does finite information cease to behave topologically, and what algebra remains after histories are forgotten? The answers are respectively paraconsistent membership semantics, opposite-retracting revision, failure of arbitrary-union closure, and quotient monoids of observational indistinguishability.