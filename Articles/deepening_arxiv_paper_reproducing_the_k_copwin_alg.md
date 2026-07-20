# The Algebra of Forgetting

## Why every finite memory edits the past

A memory is often imagined as a container. Experiences enter, representations are stored, and—if the container is large enough—nothing essential need be lost. Mathematics suggests a different picture. Memory is less like a warehouse than an editor: it combines events, suppresses distinctions, and turns many possible histories into the same observable state.

That claim can be made precise without committing to neurons, computer hardware, or a particular learning model. Begin with an alphabet $A$ of possible experiences. A finite experience stream is a word

$$
a_1a_2\cdots a_n,
$$

where every $a_i$ lies in $A$. Streams combine by concatenation. The empty stream, denoted $\varepsilon$, does nothing under concatenation. All finite streams therefore form a monoid: an algebraic system with an associative product and a neutral element.

Now let $R$ be a monoid of memory representations. Its product describes how two stored summaries combine, and its identity $1_R$ is the neutral memory. A **compositional memory** is a function $M$ from streams to $R$ satisfying

$$
M(uv)=M(u)M(v),\qquad M(\varepsilon)=1_R.
$$

This simple law is the heart of the story. It says that remembering a combined history is equivalent to combining the memories of its parts. Running summaries, finite-state machines, symbolic filters, event logs, and many compressed sequence models fit this pattern.

From that one law emerge three facts: finite memory must lose information; total erasure has algebraic structure; and the entire observable world of the memory is exactly a quotient of the world of possible histories.

## The unavoidable collision

Suppose at least one experience symbol exists and the representation set $R$ is finite. Pick one symbol $a$. The streams

$$
\varepsilon,
\quad a,
\quad aa,
\quad aaa,
\quad \ldots
$$

are all different, so there are infinitely many possible histories. Yet only finitely many memory states are available. By the pigeonhole principle, two distinct streams $u$ and $v$ must satisfy

$$
M(u)=M(v).
$$

This is the **Finite-Memory Loss Theorem**: every compositional memory with finitely many states identifies at least two distinct histories whenever the experience alphabet is nonempty.

The theorem is stronger than the familiar observation that a small data structure cannot store an arbitrarily long input verbatim. It does not depend on how cleverly states are encoded, and it does not require the alphabet itself to be large. One repeatable event is enough. The obstruction is structural: unbounded streams meet bounded representation.

Information loss here does not necessarily mean failure. A thermostat deliberately treats countless temperature histories as equivalent once they lead to the same control state. A network monitor may ignore packet details irrelevant to an alarm. A human recollection may preserve the emotional outline of a day while discarding its minute chronology. Compression is useful precisely because distinctions are being removed. The theorem says only that the removal cannot be avoided when the memory is finite.

## Forgetting as a relation between histories

A collision suggests a natural relation. Call two streams $u$ and $v$ **observationally indistinguishable** when

$$
u\sim_M v \quad\text{if and only if}\quad M(u)=M(v).
$$

This relation is an equivalence relation, but it is more than that. It respects concatenation. If $u\sim_M v$ and $x\sim_M y$, then

$$
M(ux)=M(u)M(x)=M(v)M(y)=M(vy),
$$

so $ux\sim_M vy$. Such a multiplication-compatible equivalence relation is called a **monoid congruence**.

This observation changes the meaning of a memory state. A state is not merely a label assigned to a stream. It represents an entire class of histories that the memory can no longer tell apart. Finite memory guarantees that at least one such class contains distinct streams. The edited past is therefore partitioned into observational classes.

Some histories disappear even more completely. Define the **erased-stream set**

$$
E_M=\{u:M(u)=1_R\}.
$$

These are the streams whose net memory is indistinguishable from the empty history. The **Erased-Stream Closure Theorem** says that $E_M$ is a submonoid. First, $\varepsilon\in E_M$ because $M(\varepsilon)=1_R$. Second, if $u,v\in E_M$, then

$$
M(uv)=M(u)M(v)=1_R1_R=1_R,
$$

so $uv\in E_M$.

Thus total erasure is not a random collection of accidents. It is closed under repetition and combination. If two episodes separately leave no trace, placing one after the other also leaves no trace. This closure law offers a practical diagnostic: any purported compositional memory whose “fully forgotten” streams fail this test cannot obey the composition rule as stated.

## The quotient that memory actually sees

Imagine collapsing every pair of indistinguishable histories into one object. The resulting space is the quotient of the stream monoid by $\sim_M$, written informally as

$$
A^*/{\sim_M},
$$

where $A^*$ denotes all finite words over $A$. Because $\sim_M$ respects concatenation, classes can be multiplied by concatenating representatives.

On the other side lies the **observable range**

$$
\operatorname{im}(M)=\{M(u):u\in A^*\},
$$

the part of the representation monoid that can actually be reached by a stream.

The **Observable Quotient Theorem** states that these two monoids are isomorphic:

$$
A^*/{\sim_M}\;\cong\;\operatorname{im}(M).
$$

The map sends the class of $u$ to $M(u)$. It is well defined because all representatives of the same class have the same memory. It is onto by the definition of the range, and it is one-to-one because equal outputs mean equal classes. It also preserves products because $M$ preserves concatenation.

This theorem is the conceptual centerpiece. The observable memory algebra is neither a vague approximation nor merely a subset of possible histories. It is exactly what remains after histories that look identical to the memory have been identified. Forgetting is quotienting.

That perspective appears throughout science. In statistical mechanics, many microscopic arrangements share one macroscopic state. In automata, many input prefixes lead to the same internal state. In data privacy, records may be deliberately coarsened until sensitive distinctions disappear. In representation learning, different inputs may share an embedding. The quotient view asks the decisive question in every case: which distinctions survive?

## A programmable eraser

The framework also describes selective forgetting. Choose a retention rule

$$
r:A\to\{\text{keep},\text{erase}\}.
$$

Define $T_r$ on individual symbols by keeping a retained symbol as a one-letter word and replacing an erased symbol by the empty word. Extend this operation to streams by applying it letter by letter and concatenating the results. For example, if $r$ keeps $a$ and $c$ but erases $b$, then

$$
T_r(abcbac)=acac.
$$

This **targeted-forgetting map** is compositional:

$$
T_r(uv)=T_r(u)T_r(v).
$$

Every symbol marked “erase” belongs to its erased-stream set, since that one-letter stream is sent to $\varepsilon$. More generally, any word containing only erased symbols vanishes entirely, while retained symbols preserve their order.

The targeted operation satisfies a powerful universal principle. Let $G$ be any other compositional summary of streams. Suppose $G$ never distinguishes streams that targeted forgetting identifies; in symbols,

$$
T_r(u)=T_r(v)\implies G(u)=G(v).
$$

Then there is one and only one compositional map $\overline{G}$ from the quotient by targeted indistinguishability to the representation space of $G$ such that

$$
G=\overline{G}\circ q,
$$

where $q$ sends each stream to its equivalence class. This is the **Universal Factorization Theorem for Targeted Forgetting**.

Why is it true? Define $\overline{G}([u])=G(u)$. The hypothesis guarantees that choosing another representative of $[u]$ gives the same answer. Composition is inherited from $G$, and uniqueness follows because every quotient class has a representative. Any downstream analysis that ignores at least the distinctions erased by $T_r$ must therefore operate through the quotient. The quotient is not one implementation choice among many; it is the canonical interface for all such analyses.

Finally, the quotient for targeted forgetting is isomorphic to the range of $T_r$. Concretely, that range consists exactly of words built from retained symbols. The abstract quotient therefore has an immediate operational meaning: delete the unwanted letters and work with what remains.

## Designing with loss rather than against it

Together, the results form a compact theory of compositional memory. For every nonempty alphabet and every finite representation monoid:

1. distinct streams inevitably collide;
2. indistinguishability is compatible with concatenation;
3. streams erased to the neutral state form a submonoid; and
4. the observable algebra is exactly the quotient by indistinguishability.

Targeted forgetting adds a design principle: specify which symbols should survive, then obtain a canonical quotient through which every compatible downstream summary uniquely factors.

This shifts attention from storage capacity alone to the geometry of lost distinctions. Two memories with the same number of states may behave very differently because they partition histories differently. One may preserve recency, another parity, another the presence of a warning event. Their true semantics lies in their congruence classes.

The lesson is both sobering and useful. A finite memory cannot preserve an unbounded past. But once loss is acknowledged, it becomes mathematically manageable. We can identify what vanishes, prove how erasures combine, characterize exactly what remains observable, and build selective filters with a universal guarantee.

This also gives designers a better vocabulary for trust. Instead of asking whether a summary “keeps the important information,” they can state which histories must remain distinguishable, which may be merged, and whether those choices remain stable when histories are extended. Those are testable algebraic requirements. They expose accidental erasure, certify intentional erasure, and make downstream compatibility a theorem rather than a hope.

Memory does not merely hold the past. It constructs the past that can still be seen.
