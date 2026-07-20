# Compositional Memory as Algebraic Quotienting

**Aristotle**  
**July 20, 2026**

## Abstract

We develop an algebraic theory of memory for finite streams. An experience stream is modeled as a word in the free monoid on an alphabet, while a compositional memory is a monoid homomorphism into a representation monoid. This minimal setup separates the syntax of histories from the algebra of their observable summaries. We prove that every finite-state compositional memory over a nonempty alphabet is necessarily lossy: two distinct streams receive the same representation. The induced observational indistinguishability is a monoid congruence, and the streams mapped to the neutral representation form a submonoid. The first isomorphism principle then identifies the quotient of all streams by observational indistinguishability with the reachable submonoid of representations. We also study targeted forgetting, a canonical filter that deletes selected symbols. Its quotient is isomorphic to the monoid of observable outputs, and it satisfies a universal factorization property: every compositional summary that respects its identifications factors uniquely through the quotient. Algorithms for collision detection, erasure testing, quotient exploration, and targeted filtering are given with complexity bounds. The results provide a common mathematical language for finite-state compression, event filtering, automata, privacy-preserving coarsening, and sequence representation.

## 1. Introduction

A sequential memory receives a history and returns a representation. In many applications the history is assembled from smaller histories, and its representation can likewise be assembled from the representations of those parts. This compositional law occurs in streaming computation, finite automata, event processing, symbolic filtering, and compressed sequence summaries. It suggests that the appropriate foundational object is not an arbitrary function but a homomorphism between monoids.

Let $A$ be an alphabet of experience symbols. The collection $A^*$ of all finite words over $A$ carries concatenation as an associative operation and the empty word $\varepsilon$ as its identity. It is the free monoid on $A$. Let $R$ be a representation monoid with identity $1_R$. A compositional memory is a map $M:A^*\to R$ satisfying

$$
M(uv)=M(u)M(v),\qquad M(\varepsilon)=1_R.
$$

No commutativity, cancellation, or finiteness is assumed unless explicitly stated. Consequently the framework includes order-sensitive and irreversible summaries.

The central theme is that information loss has algebraic form. Equality of memory states induces a congruence on streams. The quotient by that congruence is not merely related to the memory's observable behavior; it is isomorphic to the reachable part of the representation monoid. Thus a compositional memory can be understood exactly as a quotient followed by an injective encoding of the quotient classes.

The paper has four main contributions. First, we establish unavoidable collisions for finite representation spaces over any nonempty alphabet. Second, we identify the completely erased streams as a submonoid. Third, we prove the observable quotient theorem. Fourth, we define targeted forgetting and establish its universal factorization property. We then turn these structural results into explicit computational procedures and discuss applications and limitations.

## 2. Algebraic preliminaries

### 2.1 Monoids, words, and homomorphisms

A **monoid** is a set $S$ equipped with an associative binary operation, written multiplicatively, and an identity element $1_S$. Thus $(xy)z=x(yz)$ and $1_Sx=x1_S=x$ for all $x,y,z\in S$.

For an alphabet $A$, the **free monoid** $A^*$ is the set of finite sequences of elements of $A$. Multiplication is concatenation, and the identity is the empty sequence $\varepsilon$. A word of length $n$ is written $a_1\cdots a_n$. The adjective “free” expresses that a function from letters into any monoid extends uniquely to a homomorphism from words.

A **monoid homomorphism** $F:S\to T$ satisfies $F(1_S)=1_T$ and $F(xy)=F(x)F(y)$. Its image

$$
\operatorname{im}(F)=\{F(x):x\in S\}
$$

is a submonoid of $T$.

### 2.2 Compositional memories

**Definition 2.1 (Experience stream).** An experience stream over $A$ is an element of $A^*$.

**Definition 2.2 (Compositional memory).** Let $R$ be a monoid. A compositional memory with alphabet $A$ and representation monoid $R$ is a monoid homomorphism $M:A^*\to R$.

The homomorphism law allows a stream to be processed incrementally. If $u=a_1\cdots a_n$, then

$$
M(u)=M(a_1)M(a_2)\cdots M(a_n),
$$

where a letter is identified with its one-letter word. The order of factors matters when $R$ is noncommutative.

**Definition 2.3 (Observational indistinguishability).** For a compositional memory $M$, define

$$
u\sim_M v \quad\Longleftrightarrow\quad M(u)=M(v).
$$

**Lemma 2.4 (Congruence property).** The relation $\sim_M$ is an equivalence relation compatible with concatenation. More precisely, if $u\sim_M v$ and $x\sim_M y$, then $ux\sim_M vy$.

**Proof sketch.** Reflexivity, symmetry, and transitivity follow from equality in $R$. For compatibility, the hypotheses give $M(u)=M(v)$ and $M(x)=M(y)$, hence

$$
M(ux)=M(u)M(x)=M(v)M(y)=M(vy).
$$

Therefore $ux\sim_M vy$. $\square$

A multiplication-compatible equivalence relation is called a monoid congruence. This compatibility ensures that equivalence classes themselves can be multiplied.

**Definition 2.5 (Erased streams).** The erased-stream set of $M$ is

$$
E_M=\{u\in A^*:M(u)=1_R\}.
$$

These streams have exactly the same representation as the empty stream.

**Definition 2.6 (Observational quotient).** The quotient $A^*/{\sim_M}$ is the set of equivalence classes $[u]$ under $\sim_M$, with multiplication $[u][v]=[uv]$ and identity $[\varepsilon]$. Lemma 2.4 guarantees that this multiplication is independent of representatives.

## 3. Finite memory necessarily loses information

The first theorem requires only a nonempty alphabet and a finite representation set.

**Theorem 3.1 (Finite-Memory Loss Theorem).** Let $A$ be nonempty, let $R$ be a finite monoid, and let $M:A^*\to R$ be a compositional memory. Then there exist distinct streams $u,v\in A^*$ such that

$$
M(u)=M(v).
$$

**Proof sketch.** Choose $a\in A$. The powers $\varepsilon,a,a^2,a^3,\ldots$ are pairwise distinct words, so $A^*$ is infinite. A function from an infinite set to the finite set $R$ cannot be injective. Hence two distinct streams have the same image. $\square$

The theorem does not rely on compositionality for the cardinality argument; compositionality becomes decisive in describing the structure of the collisions. The result also does not require $A$ to be finite. A single available symbol already produces infinitely many distinct words.

**Corollary 3.2 (Nontrivial indistinguishability).** Under the hypotheses of Theorem 3.1, at least one equivalence class of $\sim_M$ contains two distinct streams. Equivalently, the observational congruence is not equality.

**Proof sketch.** The streams supplied by Theorem 3.1 are distinct and have equal images, so they belong to the same class. $\square$

A sharper unary observation is useful computationally. If $|R|=m$ and $a\in A$, then among

$$
\varepsilon,a,a^2,\ldots,a^m
$$

there are $m+1$ streams but only $m$ possible states. Thus a collision appears with word lengths at most $m$. This gives a finite certificate whenever the cardinality of $R$ is explicitly known.

**Proposition 3.3 (Bounded unary collision certificate).** If $|R|=m$ and $A$ is nonempty, then for every $a\in A$ there exist integers $0\leq i<j\leq m$ such that

$$
M(a^i)=M(a^j).
$$

**Proof sketch.** Apply the finite pigeonhole principle to the $m+1$ values $M(a^0),\ldots,M(a^m)$. $\square$

This proposition exposes eventual periodicity along repeated experiences. Since $M(a^n)=M(a)^n$, equality at indices $i<j$ implies, for every $t\geq 0$,

$$
M(a^{i+t})=M(a^i)M(a^t)=M(a^j)M(a^t)=M(a^{j+t}).
$$

Thus the remembered trajectory of a repeated event eventually cycles.

## 4. Erasure and the observable quotient

### 4.1 The algebra of complete erasure

**Theorem 4.1 (Erased-Stream Submonoid Theorem).** For every compositional memory $M:A^*\to R$, the erased-stream set $E_M$ is a submonoid of $A^*$. Explicitly,

$$
\varepsilon\in E_M,
$$

and whenever $u,v\in E_M$, one has $uv\in E_M$.

**Proof sketch.** Since $M$ is a homomorphism, $M(\varepsilon)=1_R$, so $\varepsilon\in E_M$. If $M(u)=M(v)=1_R$, then

$$
M(uv)=M(u)M(v)=1_R1_R=1_R.
$$

Therefore $uv\in E_M$. $\square$

The theorem is deliberately modest: in a general noncommutative monoid, $E_M$ need not be closed under insertion into arbitrary contexts, inverses need not exist, and a product can map to $1_R$ even when neither factor does. What is guaranteed is precisely the identity-and-concatenation structure of a submonoid.

### 4.2 The first isomorphism principle

**Theorem 4.2 (Observable Quotient Theorem).** Let $M:A^*\to R$ be a compositional memory. Then the observational quotient is isomorphic as a monoid to the reachable representation submonoid:

$$
A^*/{\sim_M}\;\cong\;\operatorname{im}(M).
$$

The isomorphism is given by

$$
\Phi([u])=M(u).
$$

**Proof sketch.** If $[u]=[v]$, then $u\sim_M v$, so $M(u)=M(v)$; hence $\Phi$ is well defined. It preserves the identity and multiplication because

$$
\Phi([u][v])=\Phi([uv])=M(uv)=M(u)M(v)=\Phi([u])\Phi([v]).
$$

It is surjective by the definition of $\operatorname{im}(M)$. If $\Phi([u])=\Phi([v])$, then $M(u)=M(v)$, so $u\sim_M v$ and $[u]=[v]$; therefore it is injective. $\square$

This theorem yields an exact normal form for a compositional memory. Let $q:A^*\to A^*/{\sim_M}$ be the quotient map. Then

$$
M=\iota\circ\Phi\circ q,
$$

where $\Phi$ is the isomorphism of Theorem 4.2 and $\iota:\operatorname{im}(M)\hookrightarrow R$ is inclusion. The only loss occurs in $q$; the remaining maps are injective onto the reachable range.

**Corollary 4.3 (Cardinality of observable classes).** If $R$ is finite, then the number of observational equivalence classes equals $|\operatorname{im}(M)|$ and is at most $|R|$.

**Proof sketch.** Isomorphic finite sets have equal cardinality, and the image is a subset of $R$. $\square$

**Corollary 4.4 (Exact criterion for losslessness).** A compositional memory $M$ is lossless on all finite streams if and only if every class of $\sim_M$ is a singleton, equivalently if and only if the quotient map $q$ is injective.

**Proof sketch.** Each condition restates injectivity of $M$: $M(u)=M(v)$ must imply $u=v$. $\square$

Combined with Theorem 3.1, Corollary 4.4 shows that no finite $R$ can support a globally lossless compositional memory over a nonempty alphabet.

## 5. Targeted forgetting

### 5.1 Construction

Let a retention policy be a function

$$
r:A\to\{0,1\},
$$

where $r(a)=1$ means retain $a$ and $r(a)=0$ means erase it.

**Definition 5.1 (Targeted-forgetting map).** Define $T_r:A^*\to A^*$ first on letters by

$$
T_r(a)=
\begin{cases}
a,&r(a)=1,\\
\varepsilon,&r(a)=0,
\end{cases}
$$

and extend to words multiplicatively. Thus for $u=a_1\cdots a_n$,

$$
T_r(u)=T_r(a_1)\cdots T_r(a_n).
$$

Operationally, $T_r$ deletes every unretained symbol and preserves the relative order of retained symbols.

**Lemma 5.2 (Compositionality).** For all words $u,v\in A^*$,

$$
T_r(uv)=T_r(u)T_r(v),\qquad T_r(\varepsilon)=\varepsilon.
$$

**Proof sketch.** The extension from letters is defined by concatenating their images. Splitting the list of letters at the boundary between $u$ and $v$ gives the product formula, while the empty concatenation is $\varepsilon$. $\square$

**Theorem 5.3 (Forgotten Symbols Are Erased).** If $r(a)=0$, then the one-letter stream $a$ lies in $E_{T_r}$; equivalently,

$$
T_r(a)=\varepsilon.
$$

**Proof sketch.** This is the erased branch of Definition 5.1. $\square$

**Proposition 5.4 (Concrete range).** The image of $T_r$ consists exactly of the words all of whose letters satisfy $r(a)=1$.

**Proof sketch.** Filtering can output only retained letters. Conversely, if every letter of $w$ is retained, then $T_r(w)=w$, so $w$ lies in the image. $\square$

The map is idempotent:

$$
T_r(T_r(u))=T_r(u),
$$

because every letter surviving the first pass is retained and hence survives the second. Therefore targeted forgetting is a projection onto the submonoid of retained words.

### 5.2 Universal property

The quotient induced by $T_r$ is canonical among all compositional summaries that respect its erasures.

**Theorem 5.5 (Universal Factorization Theorem for Targeted Forgetting).** Let $S$ be a monoid and let $G:A^*\to S$ be a monoid homomorphism. Assume that for all streams $u,v$,

$$
T_r(u)=T_r(v)\implies G(u)=G(v).
$$

Let $q_r:A^*\to A^*/{\sim_{T_r}}$ be the quotient map. Then there exists a unique monoid homomorphism

$$
\overline{G}:A^*/{\sim_{T_r}}\to S
$$

such that

$$
\overline{G}\circ q_r=G.
$$

**Proof sketch.** Define $\overline{G}([u])=G(u)$. If $[u]=[v]$, then $T_r(u)=T_r(v)$, and the assumption gives $G(u)=G(v)$, so the definition is independent of representatives. It preserves multiplication because $G$ does. The factorization equation follows immediately. If $H$ is another such homomorphism, then for every class $[u]$,

$$
H([u])=H(q_r(u))=G(u)=\overline{G}([u]),
$$

so $H=\overline{G}$. $\square$

The hypothesis says exactly that the congruence induced by targeted forgetting is contained in the congruence induced by $G$. Hence $G$ may discard additional distinctions, but it may not recover one already destroyed by $T_r$.

**Theorem 5.6 (Targeted-Forgetting Quotient Theorem).** The quotient induced by targeted forgetting is isomorphic to its image:

$$
A^*/{\sim_{T_r}}\;\cong\;\operatorname{im}(T_r).
$$

By Proposition 5.4, the right-hand side is the free monoid of words formed from retained symbols.

**Proof sketch.** Apply Theorem 4.2 to $T_r$, then use Proposition 5.4 to identify its image concretely. $\square$

Theorems 5.5 and 5.6 together say that retained words form a canonical interface. Every compatible downstream compositional computation can be defined uniquely on filtered outputs rather than on raw histories.

## 6. Algorithms and computational illustrations

### 6.1 Streaming targeted forgetting

Given a word of length $n$, scan from left to right and append a symbol exactly when the policy retains it. The output order agrees with the input order.

**Correctness.** After processing the first $i$ input symbols, the output equals $T_r$ applied to that prefix. The invariant holds initially for the empty prefix and is preserved by either appending a retained symbol or doing nothing for an erased one. At $i=n$, the output is $T_r(u)$.

**Complexity.** With constant-time policy lookup, the running time is $O(n)$ and the output storage is $O(k)$, where $k\leq n$ is the number of retained symbols. A streaming sink can reduce auxiliary storage to $O(1)$ beyond the output channel.

### 6.2 Unary collision search

For a finite monoid $R$ of size $m$ and a chosen letter $a$, compute successive states

$$
1_R,M(a),M(a)^2,\ldots,M(a)^m.
$$

Store the first index at which each state appears. The first repeated state supplies $i<j\leq m$ with $M(a^i)=M(a^j)$.

**Correctness.** Proposition 3.3 guarantees a repetition among the first $m+1$ states. The table reports two indices sharing that state.

**Complexity.** Assuming constant-time multiplication, hashing, and equality, time and space are $O(m)$. If state operations cost $C$ and $H$, these become $O(m(C+H))$ time and $O(m)$ states of storage.

### 6.3 Finite quotient exploration

When $A$ and the reachable representation range are finite, breadth-first search can enumerate observable classes. Begin at $1_R$. For each discovered state $s$ and letter $a$, compute $sM(a)$. Add unseen states to a queue. Each reached state represents one quotient class by Theorem 4.2.

If $q=|\operatorname{im}(M)|$ and $d=|A|$, the procedure performs at most $qd$ transitions. With constant-time state operations, the time complexity is $O(qd)$ and space complexity is $O(q)$. The output is the transition graph of the memory on its reachable states.

### 6.4 Example: parity memory

Let $A=\{a,b\}$ and $R=\mathbb{Z}/2\mathbb{Z}$ under addition. Assign $a\mapsto 1$ and $b\mapsto 0$. Then $M(u)$ records the parity of the number of occurrences of $a$. Distinct words collide whenever they have the same parity. The erased set consists of words containing an even number of $a$ symbols and is closed under concatenation. The quotient has exactly two classes, isomorphic to the reachable range $\{0,1\}$.

### 6.5 Example: selective event logging

Let $A=\{\text{INFO},\text{WARN},\text{ERROR}\}$ and retain only WARN and ERROR. Then

$$
T_r(\text{INFO WARN INFO ERROR WARN})
=
\text{WARN ERROR WARN}.
$$

Two logs are indistinguishable exactly when deleting INFO entries yields the same retained log. Any compositional alerting system that is insensitive to INFO must factor uniquely through these filtered logs.

## 7. Applications

### 7.1 Finite automata and streaming summaries

A deterministic finite-state stream processor often updates a state after each symbol. When its summaries combine associatively—for example through transition transformations or syntactic monoids—it fits the present model. Theorem 3.1 guarantees collisions, while Theorem 4.2 identifies states with equivalence classes of histories up to observable behavior. Quotient exploration gives a direct route to the reachable state graph.

### 7.2 Event filtering and logging

Targeted forgetting formalizes a common logging policy: retain selected event types and drop the rest. The universal factorization theorem ensures architectural modularity. If every downstream module is deliberately insensitive to dropped events, raw logs can be replaced by filtered logs without changing those modules' outputs. The uniqueness clause says their induced operations on the filtered interface are determined, not chosen arbitrarily.

### 7.3 Privacy-preserving coarsening

A privacy transformation removes distinctions between records or event sequences. In a compositional setting, its indistinguishability relation is a congruence. The quotient describes exactly the information still available. The universal principle clarifies a non-recovery guarantee at the algebraic level: a downstream compositional map that respects the privacy congruence cannot distinguish records that the coarsening has identified. This is a structural statement, not by itself a probabilistic privacy guarantee.

### 7.4 Representation learning

Sequence embeddings frequently map many inputs to one representation. When an embedding admits an associative composition law, the quotient viewpoint separates two questions: which streams are identified, and how the resulting classes are encoded. Theorem 4.2 shows that the reachable embedding algebra is completely determined, up to isomorphism, by the induced indistinguishability congruence.

## 8. Discussion and limitations

The framework makes few assumptions and therefore yields robust but structural conclusions. Finiteness forces collision, yet it does not quantify semantic importance: two colliding histories may differ in a negligible or crucial way. Such judgments require application-specific loss functions or task semantics.

Likewise, the model assumes exact compositionality. Systems with context-dependent updates, approximate equality, stochastic state transitions, or bounded windows may require enriched structures. Approximate memories suggest metric quotients or tolerance relations; randomized memories suggest distributions and Markov kernels; context-sensitive composition may call for categories, actions, or transducers rather than a single monoid homomorphism.

The erased-stream submonoid captures only streams sent exactly to the neutral representation. A memory can lose distinctions without mapping either stream to the identity, so $E_M$ records one special congruence class rather than all information loss. The full congruence $\sim_M$ remains the complete invariant.

Finally, finite memory is not automatically computationally efficient. A finite monoid may be enormous, and its multiplication may be expensive. The algebraic theorems identify what must be true independently of implementation costs; the algorithms require explicit representations and cost models.

## 9. Future work

Several extensions are natural. One may classify which congruences on a free monoid admit small finite quotient representations, optimize retention policies under a state budget, or compare two memories by refinement of their congruences. If $\sim_{M_1}$ is contained in $\sim_{M_2}$, then $M_1$ preserves at least as many distinctions as $M_2$, suggesting a partial order of information content.

Approximate variants could replace equality $M(u)=M(v)$ by a metric threshold and study when approximate indistinguishability is stable under concatenation. Probabilistic variants could quantify mutual information between streams and representations while retaining the algebraic quotient as the zero-error backbone. Another direction is learning a finite congruence from observed equivalence judgments, thereby reconstructing a minimal compositional representation.

Targeted forgetting also invites optimization questions: choose a retained subalphabet that satisfies a privacy or storage constraint while preserving a downstream task. The universal property guarantees correctness once compatibility is established; the remaining challenge is selecting the policy.

## 10. Conclusion

Compositional memory turns histories into algebra. Over a nonempty alphabet, any finite representation space necessarily identifies distinct streams. These identifications form a monoid congruence, completely erased histories form a submonoid, and the quotient by observational indistinguishability is isomorphic to the reachable representation algebra. Targeted forgetting realizes these principles as an explicit symbol filter and provides a canonical quotient through which every compatible compositional summary factors uniquely.

The resulting picture is exact: a memory first collapses histories into classes and then represents those classes. This viewpoint makes information loss visible, compositional, and amenable to algorithmic exploration.
