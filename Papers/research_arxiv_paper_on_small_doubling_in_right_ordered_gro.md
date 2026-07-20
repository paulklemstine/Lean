# Memory Editing as Algebraic Quotienting

## Abstract

Sequential experience may be modeled by the free monoid $A^*$ on an alphabet $A$, while a compositional memory is a monoid homomorphism $M:A^*\to R$ into a representation monoid $R$. This paper develops the elementary but robust structure forced by that model. If $A$ is nonempty and $R$ is finite, then $M$ necessarily identifies two distinct streams. The relation $u\sim_M v$ defined by $M(u)=M(v)$ is a monoid congruence, the streams mapped to the neutral representation form a submonoid, and the quotient $A^*/{\sim_M}$ is naturally isomorphic to the reachable submonoid $\operatorname{im}(M)$. We then study targeted forgetting, which deletes letters selected by a Boolean retention rule. Every deleted generator lies in the erased submonoid, and every compositional map constant on the fibers of targeted forgetting factors uniquely through its quotient. These results join a finite-state information constraint to the first isomorphism principle for monoids. Algorithms for filtering streams, detecting collisions in finite memories, constructing observational classes on bounded samples, and checking empirical homomorphism laws are presented with complexity analyses. Applications include finite automata, privacy filters, event logging, state abstraction, and sequential feature extraction.

## 1. Introduction

Many systems receive a sequence of events and preserve only a representation of that sequence. A finite-state controller reads inputs and updates its state. A logging system retains selected event types. A feature extractor converts a token stream into a compact summary. Human memory likewise preserves some distinctions and discards others. Despite their differences, these examples share a compositional ideal: the representation of a concatenated stream should agree with a suitable combination of the representations of its parts.

The natural domain for finite streams is a free monoid. Its multiplication is concatenation, and its identity is the empty stream. If the representation space also carries a monoid structure, a compositional memory is exactly a monoid homomorphism. This formulation separates three questions.

First, when is information loss inevitable? If the alphabet has at least one symbol, there are infinitely many finite streams. A finite representation space therefore forces collisions.

Second, how is information loss organized? Equal representations define an equivalence relation compatible with concatenation. Consequently, a memory does not merely discard isolated facts; it passes from the stream monoid to a quotient monoid.

Third, what remains observable? The quotient by representational equality is naturally isomorphic to the image of the memory map. Thus the quotient is neither an approximation nor an auxiliary object. It is exactly the algebra of reachable observations.

A particularly transparent memory operation is targeted forgetting. Given a Boolean predicate on symbols, delete every symbol marked false and retain every symbol marked true. This filter extends uniquely from generators to a homomorphism on all words. Its universal property states that every homomorphism insensitive to at least the distinctions erased by the filter descends uniquely to the corresponding quotient.

The contribution is a self-contained synthesis of these statements, including their proofs, algorithms, and applications. No cancellation, inverses, commutativity, or finiteness of the alphabet is required unless explicitly stated.

## 2. Algebraic model of sequential experience

### 2.1. Monoids and free streams

A **monoid** is a set $R$ equipped with an associative operation, written multiplicatively, and an identity element $1_R$. Thus, for all $x,y,z\in R$,

$$
(xy)z=x(yz),\qquad 1_Rx=x=x1_R.
$$

Let $A$ be an alphabet, meaning an arbitrary set of elementary symbols. The **free monoid** $A^*$ consists of all finite words over $A$, including the empty word $\varepsilon$. Its operation is concatenation. If

$$
u=a_1\cdots a_m,\qquad v=b_1\cdots b_n,
$$

then

$$
uv=a_1\cdots a_mb_1\cdots b_n.
$$

Concatenation is associative and has identity $\varepsilon$. The length of $w$ is denoted $|w|$.

The adjective “free” records a universal property: every function $f:A\to R$ into a monoid extends uniquely to a monoid homomorphism $\widehat f:A^*\to R$. Explicitly,

$$
\widehat f(a_1\cdots a_n)=f(a_1)\cdots f(a_n),
\qquad \widehat f(\varepsilon)=1_R.
$$

### 2.2. Compositional memories

A **compositional memory** with alphabet $A$ and representation monoid $R$ is a map $M:A^*\to R$ satisfying

$$
M(uv)=M(u)M(v),\qquad M(\varepsilon)=1_R.
$$

Equivalently, $M$ is a monoid homomorphism. The definition allows $R$ to be noncommutative, which is important when the order of summarized blocks matters.

The **reachable memory monoid** is

$$
\operatorname{im}(M)=\{M(w):w\in A^*\}.
$$

It contains $1_R=M(\varepsilon)$ and is closed under multiplication because $M(u)M(v)=M(uv)$. Hence it is a submonoid of $R$.

The **erased-stream submonoid candidate** is

$$
K_M=\{w\in A^*:M(w)=1_R\}.
$$

Finally, define **observational indistinguishability** by

$$
u\sim_M v\quad\Longleftrightarrow\quad M(u)=M(v).
$$

The distinction between $K_M$ and $\sim_M$ is essential. The former records streams equivalent to the empty stream. The latter records every pair that memory fails to distinguish. Without inverses, a general collision need not reduce to membership in $K_M$.

## 3. Finite representation forces information loss

We first isolate the information-theoretic component.

### Theorem 3.1 (Finite-Memory Loss Theorem)

Let $A$ be nonempty, let $R$ be a finite monoid, and let $M:A^*\to R$ be a compositional memory. Then there exist $u,v\in A^*$ such that

$$
u\ne v\qquad\text{and}\qquad M(u)=M(v).
$$

#### Proof sketch

Choose $a\in A$. The words $\varepsilon,a,a^2,a^3,\ldots$ are pairwise distinct because their lengths differ. Therefore $A^*$ is infinite. Since $R$ is finite, no map $A^*\to R$ can be injective. In particular, $M$ has a collision. $\square$

The homomorphism law is not needed for the bare collision conclusion; finiteness alone forces it. Compositionality becomes decisive when describing the collision structure.

### Corollary 3.2 (Nontrivial observational class)

Under the hypotheses of Theorem 3.1, at least one equivalence class of $\sim_M$ contains two distinct streams.

#### Proof sketch

The collision $M(u)=M(v)$ supplied by Theorem 3.1 says exactly that $u\sim_M v$, while $u\ne v$. $\square$

### Proposition 3.3 (Finite length bound for a witnessed collision)

If $|R|=N$ and $a\in A$, then among

$$
\varepsilon,a,a^2,\ldots,a^N
$$

there are two distinct words with equal memories.

#### Proof sketch

There are $N+1$ displayed words but only $N$ representation states. The finite pigeonhole principle yields the claim. $\square$

This strengthens the existence argument into a search guarantee. A collision can be found after evaluating at most $N+1$ powers of any fixed symbol.

## 4. Congruences, erasure, and observable quotients

### 4.1. Congruence of indistinguishability

A **monoid congruence** on a monoid $P$ is an equivalence relation $\sim$ such that

$$
u_1\sim v_1\ \text{and}\ u_2\sim v_2
\quad\Longrightarrow\quad
u_1u_2\sim v_1v_2.
$$

### Lemma 4.1 (Kernel congruence)

For every compositional memory $M:A^*\to R$, observational indistinguishability $\sim_M$ is a monoid congruence.

#### Proof sketch

Reflexivity, symmetry, and transitivity follow from equality in $R$. If $M(u_1)=M(v_1)$ and $M(u_2)=M(v_2)$, then

$$
M(u_1u_2)=M(u_1)M(u_2)=M(v_1)M(v_2)=M(v_1v_2).
$$

Thus $u_1u_2\sim_M v_1v_2$. $\square$

An equivalent contextual formulation is useful: if $u\sim_M v$, then $xuy\sim_M xvy$ for all $x,y\in A^*$. Indeed,

$$
M(xuy)=M(x)M(u)M(y)=M(x)M(v)M(y)=M(xvy).
$$

Therefore a forgotten distinction remains forgotten inside every larger history.

### 4.2. Completely erased streams

### Theorem 4.2 (Erased-Stream Submonoid Theorem)

For every compositional memory $M:A^*\to R$, the set

$$
K_M=\{w\in A^*:M(w)=1_R\}
$$

is a submonoid of $A^*$. In particular,

$$
\varepsilon\in K_M,
$$

and, for all $u,v\in A^*$,

$$
u\in K_M\ \text{and}\ v\in K_M\quad\Longrightarrow\quad uv\in K_M.
$$

#### Proof sketch

The identity law gives $M(\varepsilon)=1_R$, so $\varepsilon\in K_M$. If $M(u)=1_R$ and $M(v)=1_R$, then

$$
M(uv)=M(u)M(v)=1_R1_R=1_R.
$$

Hence $uv\in K_M$. $\square$

A useful caution is that $K_M$ need not by itself determine every fiber of $M$ in a non-group monoid. The congruence $\sim_M$ is the complete object of observational equality.

### 4.3. Quotient construction

Given a congruence $\sim$ on a monoid $P$, let $P/{\sim}$ be the set of equivalence classes. Define

$$
[x][y]=[xy],\qquad 1_{P/{\sim}}=[1_P].
$$

Compatibility of $\sim$ with multiplication makes this independent of representatives. The result is a monoid, called the quotient monoid.

### Theorem 4.3 (Observable-Quotient Theorem)

Let $M:A^*\to R$ be a compositional memory. Then the quotient monoid by observational indistinguishability is naturally isomorphic to the reachable memory monoid:

$$
A^*/{\sim_M}\ \cong\ \operatorname{im}(M).
$$

The isomorphism is given by

$$
\Phi([w])=M(w).
$$

#### Proof sketch

If $[u]=[v]$, then $u\sim_M v$, so $M(u)=M(v)$; therefore $\Phi$ is well defined. It is multiplicative because

$$
\Phi([u][v])=\Phi([uv])=M(uv)=M(u)M(v)=\Phi([u])\Phi([v]).
$$

It maps the identity class to $1_R$. It is surjective onto $\operatorname{im}(M)$ by definition. If $\Phi([u])=\Phi([v])$, then $M(u)=M(v)$, whence $u\sim_M v$ and $[u]=[v]$; thus it is injective. $\square$

The theorem is the monoid form of the first isomorphism principle. Its interpretation is exact: quotienting histories by all distinctions invisible to $M$ produces precisely the states that $M$ can reach.

### Theorem 4.4 (Finite Loss-and-Quotient Synthesis)

Let $A$ be nonempty, $R$ finite, and $M:A^*\to R$ compositional. Then all three statements hold:

1. there are distinct $u,v\in A^*$ with $M(u)=M(v)$;
2. $K_M$ contains $\varepsilon$ and is closed under concatenation;
3. $A^*/{\sim_M}$ is isomorphic to $\operatorname{im}(M)$.

#### Proof sketch

Apply Theorem 3.1, Theorem 4.2, and Theorem 4.3 respectively. $\square$

The synthesis joins a cardinality obstruction to a structural classification. Finiteness guarantees that a nontrivial quotient occurs; the isomorphism theorem identifies the quotient with the observable algebra.

## 5. Targeted forgetting

### 5.1. Definition and elementary properties

Let $r:A\to\{0,1\}$ be a retention rule. Define the letter-level map $f_r:A\to A^*$ by

$$
f_r(a)=
\begin{cases}
a,&r(a)=1,\\
\varepsilon,&r(a)=0.
\end{cases}
$$

By the universal property of the free monoid, this extends uniquely to a homomorphism

$$
T_r:A^*\to A^*.
$$

Concretely, $T_r$ deletes every unretained letter and preserves the order of retained letters. We call $T_r$ **targeted forgetting**.

### Proposition 5.1 (Filtering formula)

For $w=a_1\cdots a_n$,

$$
T_r(w)=f_r(a_1)\cdots f_r(a_n).
$$

Moreover,

$$
T_r(uv)=T_r(u)T_r(v),\qquad T_r(\varepsilon)=\varepsilon.
$$

#### Proof sketch

The formula is the defining extension of $f_r$ to the free monoid. Splitting the product at the boundary between $u$ and $v$ gives the concatenation law. $\square$

### Theorem 5.2 (Forgotten-Symbol Theorem)

If $a\in A$ satisfies $r(a)=0$, then

$$
a\in K_{T_r}.
$$

Equivalently, the one-letter stream $a$ is mapped to $\varepsilon$.

#### Proof sketch

By the definition of $f_r$, $T_r(a)=f_r(a)=\varepsilon$, the identity of $A^*$. $\square$

### Proposition 5.3 (Characterization of targeted fibers)

For all $u,v\in A^*$,

$$
u\sim_{T_r}v\quad\Longleftrightarrow\quad T_r(u)=T_r(v).
$$

Thus two streams are observationally indistinguishable precisely when their retained subsequences agree.

#### Proof sketch

This is the definition of the kernel congruence specialized to $T_r$, together with the operational description of $T_r$ as order-preserving filtering. $\square$

### Proposition 5.4 (Image of targeted forgetting)

Let

$$
A_r=\{a\in A:r(a)=1\}.
$$

Then $\operatorname{im}(T_r)$ consists exactly of words whose letters all belong to $A_r$. Consequently,

$$
A^*/{\sim_{T_r}}\cong A_r^*.
$$

#### Proof sketch

Every output of $T_r$ contains only retained letters. Conversely, if a word contains only retained letters, filtering leaves it unchanged, so it lies in the image. Apply Theorem 4.3 to identify the quotient with this image. $\square$

This makes the quotient concrete: deleting selected generators collapses the original stream monoid onto the free monoid generated by the surviving alphabet.

### 5.2. Universal factorization

### Theorem 5.5 (Universal Property of Targeted Forgetting)

Let $S$ be a monoid, let $G:A^*\to S$ be a monoid homomorphism, and assume that

$$
T_r(u)=T_r(v)\quad\Longrightarrow\quad G(u)=G(v)
$$

for every $u,v\in A^*$. Then there exists a unique monoid homomorphism

$$
\overline G:A^*/{\sim_{T_r}}\to S
$$

such that

$$
\overline G([w])=G(w)
$$

for every $w\in A^*$. Equivalently, if $\pi:A^*\to A^*/{\sim_{T_r}}$ is the quotient map, then

$$
G=\overline G\circ\pi.
$$

#### Proof sketch

Define $\overline G([w])=G(w)$. If $[u]=[v]$, then $T_r(u)=T_r(v)$, and the hypothesis gives $G(u)=G(v)$; hence the definition is independent of representatives. Multiplicativity follows from

$$
\overline G([u][v])=\overline G([uv])=G(uv)=G(u)G(v).
$$

The identity is preserved similarly. For uniqueness, every quotient element is $[w]$ for some $w$. Any homomorphism satisfying the factorization must send $[w]$ to $G(w)$, so it equals $\overline G$ everywhere. $\square$

The assumption can be phrased as inclusion of congruences: every pair identified by $T_r$ is also identified by $G$. The conclusion says that quotienting by targeted forgetting is the most general compositional operation imposing exactly those identifications.

## 6. Algorithms and computational demonstrations

### 6.1. Linear targeted filtering

Represent a word as a finite list or string and a retention rule as a predicate.

**Algorithm 1: Targeted Stream Filtering**

1. Initialize an empty output sequence.
2. Scan the input from left to right.
3. Append the current symbol exactly when the retention predicate is true.
4. Return the output.

For input length $n$, the running time is $O(n)$. The output uses $O(n)$ space in the worst case and $O(1)$ auxiliary space beyond the output under an appendable representation. The algorithm directly exhibits

$$
T_r(uv)=T_r(u)T_r(v).
$$

### 6.2. Bounded collision search

Suppose $R$ has $N$ states and the transition associated with a fixed letter $a$ can be evaluated. Proposition 3.3 gives a finite procedure.

**Algorithm 2: Repeated-Symbol Collision Search**

1. Set the current memory to $1_R$ and record that it occurs at exponent $0$.
2. For $j=1,\ldots,N$, multiply the current memory by $M(a)$.
3. If the resulting state was recorded at exponent $i<j$, return $(a^i,a^j)$.
4. Otherwise record exponent $j$ and continue.

A collision must occur by step $N$. With hash-table state lookup, expected time is $O(N)$ and space is $O(N)$. With a balanced search tree, time is $O(N\log N)$. The returned words are distinct because their lengths differ.

### 6.3. Finite observational partition

Although $A^*$ is usually infinite, one can inspect all words up to a length bound $L$ when $A$ is finite. Enumerate these words, compute $M(w)$, and group by output. The number of words is

$$
1+|A|+|A|^2+\cdots+|A|^L.
$$

For $|A|>1$, this equals

$$
\frac{|A|^{L+1}-1}{|A|-1}.
$$

The procedure is exponential in $L$, as exhaustive bounded-word enumeration must be. It makes quotient classes visible on a finite window and can reveal representative collisions.

### 6.4. Empirical compositionality checks

For a finite sample $W\subseteq A^*$, compare $M(uv)$ with $M(u)M(v)$ for all $(u,v)\in W^2$. This costs $O(|W|^2)$ memory evaluations, apart from stream-processing costs. Such a test can refute compositionality on the sample but cannot establish the universal law on an infinite domain. For targeted filtering, the law follows directly from the definition rather than empirical testing.

## 7. Examples

### 7.1. Parity memory

Let $A=\{a,b\}$ and let $R=\mathbb Z/2\mathbb Z$ under addition. Define

$$
M(w)=|w|\bmod 2.
$$

Then concatenation adds lengths, so $M$ is compositional. All even-length words map to $0$, and all odd-length words map to $1$. Hence $K_M$ is the submonoid of even-length words, and the quotient has two classes. The Observable-Quotient Theorem identifies it with $\mathbb Z/2\mathbb Z$.

### 7.2. Modular counting memory

Fix a distinguished symbol $a\in A$ and $m\ge 1$. Define

$$
M(w)=\#_a(w)\bmod m,
$$

where $\#_a(w)$ counts occurrences of $a$. Since counts add under concatenation, $M$ is a homomorphism into $\mathbb Z/m\mathbb Z$. Two words are indistinguishable exactly when their $a$-counts are congruent modulo $m$. The erased submonoid consists of words whose $a$-count is divisible by $m$.

### 7.3. Selective event logging

Let $A=\{\text{login},\text{read},\text{write},\text{logout}\}$. Retain only login, write, and logout. Then a stream such as

$$
\text{login}\,\text{read}\,\text{read}\,\text{write}\,\text{logout}
$$

is mapped to

$$
\text{login}\,\text{write}\,\text{logout}.
$$

All inserted or deleted read events are observationally invisible. Every downstream homomorphism that depends only on the retained event sequence factors uniquely through the targeted-forgetting quotient.

## 8. Applications

### 8.1. Finite automata

A deterministic finite automaton induces a finite transition monoid action. When one records only a suitable finite transformation or state effect of each word, infinitely many words necessarily coincide observationally. The congruence viewpoint explains why equivalent words can be substituted inside larger contexts without changing the recorded behavior.

### 8.2. Privacy and data minimization

A preprocessing layer may delete sensitive event categories before downstream analysis. Targeted forgetting models exact deletion while preserving event order. The universal property provides a criterion for architectural compliance: any downstream compositional analysis insensitive to the deleted data must factor through the sanitized quotient. This is an algebraic statement, not by itself a complete security guarantee, because side channels and noncompositional dependencies lie outside the model.

### 8.3. Logging and observability

Logs preserve selected events and omit others. Two execution histories with the same retained log become observationally indistinguishable. The quotient describes precisely what incident analysis can infer from the log under the compositional model. Enlarging the retained alphabet refines the congruence; deleting more symbols coarsens it.

### 8.4. Sequential feature extraction

Some features compose across blocks: counts add, transition summaries multiply, and hashes combine under suitable constructions. Any finite feature monoid must collide on an unbounded stream space. The quotient identifies the semantic resolution of the feature: two streams are equivalent exactly when the extractor cannot separate them.

## 9. Discussion and limitations

The framework is deliberately minimal. It assumes finite streams, exact equality of representations, and strict compositionality. Real memory systems may be stochastic, approximate, context-dependent, time-varying, or nonassociative. Extending the theory to those settings may require probability kernels, metrics, enriched categories, or semigroup actions.

Finiteness of $R$ is used only to force a collision. The congruence, erased-submonoid, quotient, and universal-factorization results hold for arbitrary representation monoids. Conversely, a finite image is enough for loss even when the ambient monoid $R$ is infinite.

The model also distinguishes erasure from indistinguishability. Sending a stream to the identity is one form of forgetting, but many collisions can occur away from the identity. In group-valued representations, inverses often let one translate equalities into kernel statements. General monoids do not permit that reduction, making congruences the appropriate primitive.

Targeted forgetting is idempotent:

$$
T_r(T_r(w))=T_r(w).
$$

After the first pass, only retained symbols remain, so a second pass changes nothing. This further characterizes $T_r$ as a projection onto the submonoid $A_r^*$. Its fibers are exactly the quotient classes, and its fixed points are exactly its image.

## 10. Future work

Several extensions arise naturally. One may replace the Boolean retention rule by a letter substitution $A\to B^*$, thereby studying redaction, coarsening, and token rewriting in a common framework. Stochastic memory maps could replace exact fibers with distributions and exact congruences with approximate indistinguishability. Quantitative questions include the growth of the largest collision class among words of bounded length and lower bounds on representation size required to distinguish prescribed stream families.

A second direction is algorithmic minimization. Given a finite-state compositional memory, one may seek the smallest observable monoid realizing the same congruence. The Observable-Quotient Theorem identifies the canonical target as the reachable image; efficient representations of that image are a computational problem.

Finally, interacting memories can be compared by inclusion of congruences. If every distinction forgotten by $M_1$ is forgotten by $M_2$, then $M_2$ factors through the quotient induced by $M_1$, subject to the same well-definedness argument used for targeted forgetting. This yields a natural partial order of information content and a foundation for compositional abstraction pipelines.

## 11. Conclusion

A compositional memory on finite streams is a monoid homomorphism. From that single premise, a coherent theory of information loss follows. A finite representation cannot distinguish all streams over a nonempty alphabet. Equality of representations is a congruence, neutralized streams form a submonoid, and the quotient by indistinguishability is exactly the reachable observable algebra. Targeted deletion supplies a concrete projection whose deleted generators are erased and whose quotient satisfies a unique factorization property.

The finite-state argument explains why loss must happen. The quotient theorem explains what the loss is. Together they show that compositional forgetting is not an arbitrary degradation of history: it is an algebraically organized passage from a free stream space to its observable quotient.