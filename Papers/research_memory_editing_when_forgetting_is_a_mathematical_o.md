# Memory Editing as Algebraic Quotienting

## Abstract

We develop an algebraic model of compositional memory in which finite experience streams form a free monoid and a memory mechanism is a monoid homomorphism into a representation monoid. This framework separates three forms of information loss: collisions between distinct streams, complete erasure to the neutral representation, and the global congruence of observational indistinguishability. We prove that every finite-state memory over a nonempty alphabet is lossy; that completely erased streams form a submonoid; and that the observable memory algebra is isomorphic to the quotient of the stream monoid by indistinguishability. We then study targeted forgetting, a symbolwise policy that deletes rejected experiences while retaining the order of accepted ones. Rejected symbols are erased, the quotient induced by the policy is isomorphic to its observable range, and every compositional map that respects the policy’s identifications factors uniquely through that quotient. These results provide a unified account of bounded memory, filtering, redaction, and downstream compatibility, with applications to privacy, automata, event processing, and finite-state summarization.

## 1. Introduction

A memory mechanism receives a sequence of experiences and produces a representation. The representation may be an internal state of a finite automaton, a rolling database summary, a filtered event log, or a compressed feature vector. In many such systems, sequential composition is fundamental: processing one stream after another should correspond to combining their representations.

This paper takes that compositional principle as its starting point. The domain of histories is the free monoid on an alphabet, and a memory is a monoid homomorphism. The model is intentionally abstract. It does not prescribe whether representations are strings, matrices, transformations, counters, or finite machine states. It requires only an associative combination law, a neutral representation, and compatibility between concatenation and representation.

The abstraction exposes a precise relation between forgetting and quotienting. A memory map determines an equivalence relation on streams: two streams are equivalent when they produce the same representation. Because the map respects multiplication, this relation is a monoid congruence. Collapsing each equivalence class to one point yields a quotient monoid, and the first isomorphism principle identifies that quotient with the reachable part of the representation space. Thus the observable memory is exactly the algebra of histories after all unobservable distinctions have been removed.

Several consequences follow. First, if the alphabet is nonempty, the stream monoid is infinite. A finite representation space therefore cannot distinguish all streams. Second, streams mapped to the neutral representation form a submonoid, giving complete erasure a closure law. Third, a symbolwise deletion policy is not merely an informal filter; it induces a quotient characterized by a universal property. Every compatible downstream homomorphism factors uniquely through the edited memory.

The presentation is self-contained. Section 2 introduces monoids, streams, memory maps, images, kernels, congruences, and quotients. Section 3 proves unavoidable loss for finite memories. Section 4 studies completely erased streams. Section 5 establishes the quotient description of observable memory. Sections 6 and 7 develop targeted forgetting and its universal property. Section 8 gives algorithms and finite experiments, while Sections 9–11 discuss applications, limitations, and future directions.

## 2. Algebraic framework

### 2.1 Monoids and experience streams

A **monoid** is a set $M$ equipped with an associative binary operation, written multiplicatively, and an identity element $1_M$. Thus, for all $x,y,z\in M$,

$$
(xy)z=x(yz), \qquad 1_Mx=x=x1_M.
$$

Let $\alpha$ be an alphabet of elementary experiences. An **experience stream** is a finite word over $\alpha$. The empty word is denoted by $\varepsilon$, and the product of two words is their concatenation. The set $\alpha^*$ of all finite words is a monoid, called the **free monoid** on $\alpha$. Its identity is $\varepsilon$.

The word “free” expresses a universal property: any assignment of alphabet symbols to a monoid $R$ extends uniquely to a monoid homomorphism from $\alpha^*$ to $R$. Concretely, once the memory of each elementary experience is chosen, the memory of a stream is forced to be the ordered product of the symbol memories.

### 2.2 Compositional memory

Let $R$ be a representation monoid. A **compositional memory map** is a function

$$
m:\alpha^*\to R
$$

satisfying

$$
m(\varepsilon)=1_R, \qquad m(xy)=m(x)m(y)
$$

for all streams $x,y\in\alpha^*$. Equivalently, $m$ is a monoid homomorphism.

This definition permits several interpretations. If $R$ is a transformation monoid, each stream determines a state update. If $R$ is finite, $m$ records a bounded machine state. If $R$ is another free monoid, $m$ may be a stream filter. If $R$ is commutative, ordering information may be partially or entirely discarded.

The **observable range** of $m$ is

$$
\operatorname{im}(m)=\{m(x):x\in\alpha^*\}.
$$

It is a submonoid of $R$: it contains $1_R=m(\varepsilon)$, and $m(x)m(y)=m(xy)$ lies in the image whenever both factors do. The distinction between $R$ and $\operatorname{im}(m)$ is essential because some nominal representation states may be unreachable.

### 2.3 Erasure and indistinguishability

The **erased-stream set** of $m$ is the inverse image of the neutral representation:

$$
E_m=\{x\in\alpha^*:m(x)=1_R\}.
$$

A stream in $E_m$ leaves exactly the same memory as the empty stream.

Define **observational indistinguishability** by

$$
x\sim_m y \quad\Longleftrightarrow\quad m(x)=m(y).
$$

The relation $\sim_m$ is an equivalence relation. It is also compatible with multiplication. If $x\sim_m y$ and $u\sim_m v$, then

$$
m(xu)=m(x)m(u)=m(y)m(v)=m(yv),
$$

hence $xu\sim_m yv$. An equivalence relation with this compatibility is called a **monoid congruence**.

The erased-stream set is precisely the equivalence class of the empty stream:

$$
E_m=[\varepsilon]_{\sim_m}.
$$

It captures complete erasure, whereas $\sim_m$ captures all lost distinctions.

### 2.4 Quotient memory algebra

Given a congruence $\sim$ on a monoid $M$, the **quotient monoid** $M/{\sim}$ consists of equivalence classes $[x]$. Multiplication is defined by

$$
[x][y]=[xy].
$$

Compatibility of the congruence makes this definition independent of the selected representatives. The canonical quotient map is

$$
q:M\to M/{\sim}, \qquad q(x)=[x].
$$

It is a surjective monoid homomorphism. For a memory map $m$, the quotient $\alpha^*/{\sim_m}$ is the **quotient memory algebra**.

## 3. Finite memory necessarily loses information

The first result is a capacity theorem independent of the internal multiplication in $R$.

### Theorem 1 (Finite-Memory Loss)

Let $\alpha$ be a nonempty alphabet, let $R$ be a finite monoid, and let $m:\alpha^*\to R$ be a compositional memory map. Then there exist distinct streams $x,y\in\alpha^*$ such that

$$
x\ne y \quad\text{and}\quad m(x)=m(y).
$$

#### Proof sketch

Choose a symbol $a\in\alpha$. The words

$$
\varepsilon,a,a^2,a^3,\ldots
$$

are pairwise distinct, so $\alpha^*$ is infinite. The finite set $R$ cannot receive an injective map from an infinite domain. By the pigeonhole principle, two distinct streams have the same image under $m$.

The theorem needs only that $\alpha$ be inhabited and $R$ finite. It does not require commutativity, cancellation, or any assumption about the distribution of memory states.

### Corollary 2 (Nontrivial Indistinguishability)

Under the assumptions of Theorem 1, the congruence $\sim_m$ is nontrivial: at least one equivalence class contains two distinct streams.

#### Proof sketch

The collision $m(x)=m(y)$ furnished by Theorem 1 is exactly the statement $x\sim_m y$, with $x\ne y$.

This corollary distinguishes unavoidable collision from complete erasure. The colliding streams need not map to $1_R$; they may meet at any reachable state. Consequently, a finite memory can have a trivial erased-stream set and still be highly lossy.

### A quantitative finite-horizon observation

Although the theorem concerns arbitrarily long streams, a finite calculation illustrates the onset of collisions. If $\alpha$ has $k$ symbols, then the number of words of length at most $n$ is

$$
N(k,n)=\sum_{j=0}^{n}k^j.
$$

For $k>1$ this equals

$$
N(k,n)=\frac{k^{n+1}-1}{k-1},
$$

while $N(1,n)=n+1$. If $R$ has $s$ states and $N(k,n)>s$, some two words of length at most $n$ collide under every map into $R$, whether or not that map is compositional. The compositional structure becomes decisive when interpreting all collisions coherently as a congruence.

## 4. Completely erased streams form a submonoid

### Theorem 3 (Erasure Closure)

For any alphabet $\alpha$, any monoid $R$, and any compositional memory map $m:\alpha^*\to R$, the erased-stream set $E_m$ is a submonoid of $\alpha^*$. Explicitly,

$$
\varepsilon\in E_m,
$$

and for all $x,y\in\alpha^*$,

$$
x\in E_m \ \text{and}\ y\in E_m \quad\Longrightarrow\quad xy\in E_m.
$$

#### Proof sketch

Because $m$ preserves identities, $m(\varepsilon)=1_R$, so $\varepsilon\in E_m$. If $x,y\in E_m$, then $m(x)=m(y)=1_R$. Homomorphicity gives

$$
m(xy)=m(x)m(y)=1_R1_R=1_R,
$$

hence $xy\in E_m$.

The theorem assigns compositional structure to total information loss. It does not state that inserting an erased stream into an arbitrary context is always invisible. Indeed, from $m(e)=1_R$ one obtains

$$
m(xey)=m(x)m(e)m(y)=m(x)m(y)=m(xy),
$$

so insertion or deletion of an erased stream *is* invisible in every two-sided context. This follows directly from the homomorphism law and explains why the identity class belongs naturally to the full congruence.

The converse implication must be treated carefully. If $m(xy)=1_R$, it need not follow in an arbitrary monoid that $m(x)=1_R$ and $m(y)=1_R$. Cancellation or positivity assumptions would be needed. Thus $E_m$ is closed under concatenation but need not be factor-closed.

## 5. Observable memory is a quotient

### Theorem 4 (Observable Quotient Theorem)

Let $m:\alpha^*\to R$ be a compositional memory map. Then the quotient monoid by observational indistinguishability is isomorphic to the observable range:

$$
\alpha^*/{\sim_m}\cong \operatorname{im}(m).
$$

The isomorphism sends the class $[x]$ to $m(x)$.

#### Proof sketch

Define

$$
\Phi:\alpha^*/{\sim_m}\to\operatorname{im}(m),\qquad \Phi([x])=m(x).
$$

If $[x]=[y]$, then $x\sim_m y$, hence $m(x)=m(y)$; therefore $\Phi$ is well-defined. It preserves multiplication because

$$
\Phi([x][y])=\Phi([xy])=m(xy)=m(x)m(y)=\Phi([x])\Phi([y]).
$$

It is surjective by the definition of the image. If $\Phi([x])=\Phi([y])$, then $m(x)=m(y)$, so $x\sim_m y$ and $[x]=[y]$; thus it is injective. Therefore $\Phi$ is a monoid isomorphism.

The theorem makes “forgetting is quotienting” exact. A representation remembers precisely an equivalence class of streams. No information relevant to the output is lost by replacing a stream with its quotient class, and no distinction between members of one class can be recovered from the output.

### Theorem 5 (Finite Memory: Loss, Erasure Structure, and Quotient)

Let $\alpha$ be nonempty, let $R$ be a finite monoid, and let $m:\alpha^*\to R$ be compositional. Then all of the following hold:

1. There are distinct streams $x$ and $y$ with $m(x)=m(y)$.
2. The set $E_m$ contains $\varepsilon$ and is closed under concatenation.
3. The quotient $\alpha^*/{\sim_m}$ is isomorphic to $\operatorname{im}(m)$.

#### Proof sketch

Apply Theorem 1 for the collision, Theorem 3 for erasure closure, and Theorem 4 for the quotient isomorphism. The three conclusions concern different aspects of one map and require no additional compatibility argument.

## 6. Targeted forgetting

Let a retention policy be a function

$$
r:\alpha\to\{0,1\},
$$

where $r(a)=1$ means that symbol $a$ is retained and $r(a)=0$ means that it is erased.

### Definition 6 (Targeted-Forgetting Map)

The targeted-forgetting map $T_r:\alpha^*\to\alpha^*$ is defined on symbols by

$$
T_r(a)=
\begin{cases}
a,&r(a)=1,\\
\varepsilon,&r(a)=0,
\end{cases}
$$

and extended to words by concatenation. Equivalently, $T_r$ deletes every rejected symbol and preserves the order and multiplicity of retained symbols.

For a word $w=a_1a_2\cdots a_n$,

$$
T_r(w)=T_r(a_1)T_r(a_2)\cdots T_r(a_n).
$$

Therefore $T_r(uv)=T_r(u)T_r(v)$ and $T_r(\varepsilon)=\varepsilon$, so $T_r$ is a monoid homomorphism.

### Proposition 7 (Rejected Symbols Are Erased)

If $r(a)=0$, then the one-letter stream $a$ belongs to the erased-stream submonoid of $T_r$:

$$
T_r(a)=\varepsilon.
$$

#### Proof sketch

This is the rejected branch of Definition 6. Since the erased-stream set is a submonoid, every finite concatenation of rejected symbols is erased as well.

A useful concrete characterization follows directly from the definition:

$$
T_r(x)=T_r(y)
$$

exactly when deleting all rejected symbols from $x$ and $y$ yields the same retained word. Thus targeted forgetting may identify streams that differ in the number, identities, and locations of rejected symbols, while preserving the retained subsequence exactly.

### Corollary 8 (Targeted Forgetting as a Quotient)

For every retention policy $r$,

$$
\alpha^*/{\sim_{T_r}}\cong\operatorname{im}(T_r).
$$

#### Proof sketch

Apply the Observable Quotient Theorem to the homomorphism $T_r$.

The image consists exactly of words containing only retained symbols. One inclusion is immediate because deletion cannot output a rejected symbol. Conversely, any word made solely of retained symbols is fixed by $T_r$ and therefore lies in the image. Hence the quotient can be viewed concretely as the free monoid on the retained alphabet, embedded in $\alpha^*$.

## 7. Universal property of targeted forgetting

The quotient is characterized not only by its elements but also by the maps out of it.

### Theorem 9 (Universal Targeted-Forgetting Theorem)

Let $r$ be a retention policy on $\alpha$, let $S$ be a monoid, and let $g:\alpha^*\to S$ be a monoid homomorphism. Assume that $g$ respects every identification made by targeted forgetting:

$$
T_r(x)=T_r(y)\quad\Longrightarrow\quad g(x)=g(y)
$$

for all streams $x,y\in\alpha^*$. Then there exists a unique monoid homomorphism

$$
\bar g:\alpha^*/{\sim_{T_r}}\to S
$$

such that

$$
g=\bar g\circ q,
$$

where $q(x)=[x]$ is the quotient map.

#### Proof sketch

Define $\bar g([x])=g(x)$. To show this is well-defined, suppose $[x]=[y]$. Then $T_r(x)=T_r(y)$, and the hypothesis gives $g(x)=g(y)$. The homomorphism law follows from

$$
\bar g([x][y])=\bar g([xy])=g(xy)=g(x)g(y)=\bar g([x])\bar g([y]).
$$

For every $x$,

$$
(\bar g\circ q)(x)=\bar g([x])=g(x),
$$

so the factorization exists. If $h$ is any other map with $g=h\circ q$, then every quotient element has the form $[x]$, and

$$
h([x])=h(q(x))=g(x)=\bar g([x]).
$$

Thus $h=\bar g$, proving uniqueness.

The theorem supplies a precise compatibility test. A downstream compositional computation can be performed entirely after targeted forgetting if and only if it is constant on the policy’s indistinguishability classes. The “only if” direction is immediate for any factorization through $q$; the theorem supplies the “if” direction and uniqueness.

### Example 10 (Counting retained events)

Let $S=(\mathbb{N},+,0)$ and define $g(w)$ to be the number of retained symbols in $w$. Then $g(x)$ depends only on $T_r(x)$, so it factors uniquely through the quotient. The induced map sends an observable retained word to its length.

### Example 11 (Incompatible downstream computation)

Suppose $g(w)$ counts rejected symbols. Two words can have the same retained output but different numbers of rejected symbols. Therefore $g$ does not respect $\sim_{T_r}$ and cannot factor through the quotient. Once rejected symbols are deleted, this statistic is genuinely unavailable.

## 8. Algorithms and numerical experiments

### 8.1 Targeted deletion algorithm

Given a finite word $w=a_1\cdots a_n$ and a Boolean policy $r$, scan from left to right and append $a_i$ exactly when $r(a_i)=1$. The algorithm takes $O(n)$ policy queries and $O(n)$ output space in the worst case. With buffered output, its running time is $O(n)$ under constant-time symbol handling.

The key invariant after processing the first $i$ symbols is that the output equals $T_r(a_1\cdots a_i)$. Initialization holds for the empty prefix. Each step either appends a retained symbol or leaves the output unchanged for a rejected symbol. At termination, the output is $T_r(w)$.

### 8.2 Finite collision search

For an explicitly given finite-state memory, enumerate words up to a chosen length, compute their states, and store the first word seen for each state. When a state repeats, the stored word and current word form a collision. If $s$ states exist, any enumeration of more than $s$ distinct words guarantees success.

The cost is $O(N)$ memory evaluations and $O(\min(N,s))$ stored representatives for $N$ enumerated words, apart from the cost of constructing words. The procedure illustrates Theorem 1 but cannot prove injectivity over an infinite domain by finite testing.

### 8.3 Quotient-class enumeration on a finite horizon

To inspect indistinguishability classes among words of length at most $n$, group words by their memory values. If $N=N(k,n)$ words are enumerated and memory states are hashable, expected running time is $O(N)$ plus evaluation cost, with $O(N)$ total storage for members. For targeted forgetting, grouping by the retained subsequence gives a concrete finite window into the quotient.

For example, over $\{a,b,c\}$ with only $a$ and $c$ retained, all of

$$
ac,\quad abc,\quad abbc,\quad bacb
$$

map to $ac$. They therefore occupy one observable class, even though their raw lengths and rejected-symbol patterns differ.

## 9. Applications

### 9.1 Privacy-preserving event processing

A redaction policy can be represented by targeted forgetting when sensitive event types are removed wholesale. The quotient contains exactly what remains observable. The universal property then gives a rigorous criterion for downstream safety: an analysis can be computed after redaction precisely when it gives the same result to any two raw histories with identical redacted outputs.

This criterion concerns functional dependence rather than implementation. It does not itself establish statistical privacy, resistance to side channels, or protection against auxiliary information. It does identify which exact stream distinctions a deterministic pipeline has discarded.

### 9.2 Finite-state controllers and automata

A deterministic finite-state system induces a map from input words to state transformations, or from words to reached states after fixing an initial state. When represented homomorphically in a finite transformation monoid, Theorem 1 guarantees collisions. The congruence viewpoint relates state-based indistinguishability to algebraic language theory: streams in one class have the same observable algebraic action.

### 9.3 Event sourcing and audit summaries

Systems often retain a compact current state while discarding the full event history. The finite-memory theorem shows that no bounded state can uniquely determine every arbitrarily long history. The quotient identifies histories compatible with the same summary. The erased submonoid captures event batches that have neutral aggregate effect, though domain-specific semantics are needed before treating such batches as safe to discard from an audit record.

### 9.4 Feature extraction and sequence models

A compositional feature extractor maps concatenated inputs to combined features. Its kernel congruence expresses representational invariance. If the implementation has finitely many possible states, collisions are inevitable. Even with an infinite mathematical codomain, quantization or bounded digital storage can induce a finite effective range. The framework clarifies the distinction between a collision forced by capacity and an invariance deliberately built into a feature map.

## 10. Discussion and limitations

The model uses exact equality. Two representations are either identical or distinct, and two streams are either perfectly indistinguishable or not. Probabilistic memory, noisy recall, and approximate similarity require richer notions, such as distributions, metrics, divergences, or Markov kernels.

The homomorphism law is also strong. Many practical memories update by an action $s\mapsto F(s,a)$ from a chosen initial state rather than by a direct homomorphism into the state set. Such systems can often be represented through a transformation monoid, where each word acts as a state transition. The appropriate codomain is then the monoid of transformations, not necessarily the set of states itself.

Finiteness is a qualitative capacity assumption. It proves existence of collisions but provides no bound on the size of the largest class unless the relevant set of input words is counted. Quantitative bounds require a finite horizon or a probability distribution over streams.

Finally, targeted forgetting is symbolwise. More expressive policies might erase patterns, summarize blocks, or depend on context. Any compositional policy still induces a congruence and quotient, but a context-dependent transducer may require an enlarged state space or a different algebraic category.

## 11. Future research

A quantitative theory should restrict attention to streams of length at most $n$, count them over a finite alphabet, and derive lower bounds on the largest indistinguishability class from the number of available memory states.

The finite-index congruences arising from finite memories invite comparison with Myhill–Nerode theory, syntactic monoids, and minimal deterministic automata. This would connect compositional memory directly to formal-language recognition.

For targeted forgetting, the abstract quotient can be developed into a normalization theorem: two streams are equivalent exactly when deletion produces the same retained stream, and the range is the free monoid on the retained subtype.

Successive policies should correspond to intersection of retained alphabets. This suggests a lattice of forgetting policies, with refinement represented contravariantly by quotient maps.

Probabilistic extensions could replace deterministic monoid maps by distributional or kernel-valued composition and study approximate indistinguishability, entropy contraction, and data-processing inequalities.

Representations with group, ring, or module structure lead respectively to normal-subgroup, ideal, or submodule quotients. Comparing these settings may reveal which kinds of loss each composition law can express.

At a categorical level, the universal property should be expressible through coequalizers or regular epimorphisms in categories of algebraic structures. Such a formulation would make forgetting functorial and clarify its behavior under products and iterated quotients.

## 12. Conclusion

Compositional memory turns finite streams into algebraic representations. When the representation space is finite and the alphabet is nonempty, some distinct histories must collide. Streams erased to the neutral state form a submonoid, and all observational collisions assemble into a congruence. The quotient by that congruence is not an auxiliary construction: it is isomorphic to the reachable memory algebra itself.

For symbolwise targeted forgetting, rejected symbols map to the empty stream, observable histories form the retained output monoid, and every compatible downstream homomorphism factors uniquely through the quotient. These facts provide a compact mathematical foundation for treating forgetting as a deliberate, compositional transformation of information rather than merely as failed storage.