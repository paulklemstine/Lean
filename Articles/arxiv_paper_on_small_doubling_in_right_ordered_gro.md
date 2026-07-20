# The Algebra of Forgetting

## Why every finite memory edits the past

A life arrives as a sequence. A red light, a horn, a turn, a familiar doorway: each event follows another, and order matters. Yet memory does not preserve this stream as an immaculate recording. It compresses. It selects. It sometimes erases. Two genuinely different histories can leave exactly the same trace.

That observation sounds psychological, but it has a clean mathematical core. The right language is the algebra of words. Choose an alphabet $A$ whose letters represent elementary experiences. A finite experience stream is a word

$$
w=a_1a_2\cdots a_n,
$$

where each $a_i$ belongs to $A$. The empty stream is denoted by $\varepsilon$. Two streams can be concatenated: if $u$ happens before $v$, their combined history is $uv$. Concatenation is associative, and $\varepsilon$ changes nothing. The collection $A^*$ of all finite words therefore forms a monoid, called the free monoid on $A$.

Now suppose remembered states also form a monoid $R$. Its operation describes how two remembered pieces combine, and its identity $1_R$ represents neutral memory. A **compositional memory** is a map $M:A^*\to R$ satisfying

$$
M(uv)=M(u)M(v), \qquad M(\varepsilon)=1_R.
$$

This simple law is the organizing principle of the theory. It says that remembering a concatenated history agrees with combining the memories of its parts. The remembered world may be much smaller than the experienced world, but it still respects sequence composition.

## The unavoidable collision

Assume there is at least one possible experience and only finitely many memory states. Then loss is not merely likely. It is mathematically unavoidable.

**Finite-Memory Loss Theorem.** If $A$ is nonempty, $R$ is finite, and $M:A^*\to R$ is a compositional memory, then there are distinct streams $u\ne v$ such that

$$
M(u)=M(v).
$$

The reason is the pigeonhole principle in its starkest form. Pick one letter $a\in A$. The streams

$$
\varepsilon,
a,
aa,
aaa,\ldots
$$

are all different, so $A^*$ is infinite. A map from this infinite set into the finite set $R$ cannot be one-to-one. Somewhere, two histories collide.

This theorem does not depend on the quality of an encoding scheme, cleverness of design, or statistical properties of the input. It applies to every finite compositional memory. A finite diary, a finite-state controller, a bounded cache, and a finite summary statistic all face the same obstruction: infinitely many possible histories must be packed into finitely many observable outcomes.

The collision is stronger than an isolated accident. Define two streams to be **observationally indistinguishable**, written $u\sim_M v$, when $M(u)=M(v)$. Because memory is compositional, indistinguishability survives context. If $u\sim_M v$ and $x\sim_M y$, then

$$
ux\sim_M vy.
$$

Thus $\sim_M$ is a multiplicative congruence: it divides all histories into equivalence classes in a way compatible with concatenation. The finite-memory theorem therefore says that at least one such class contains two genuinely different streams.

## Erasure has structure

Some streams do more than collide with one another. They disappear completely. Define the **erased language**

$$
K_M=\{w\in A^*:M(w)=1_R\}.
$$

These are precisely the histories whose remembered effect is neutral. The empty stream lies in $K_M$, since $M(\varepsilon)=1_R$. Moreover, if $u,v\in K_M$, then

$$
M(uv)=M(u)M(v)=1_R1_R=1_R,
$$

so $uv\in K_M$. Hence the erased language is a submonoid of $A^*$.

**Erased-Language Theorem.** For every compositional memory, the completely erased streams contain the empty stream and are closed under concatenation.

This is a small theorem with a useful message: complete forgetting is not an arbitrary list of exceptions. It has algebraic closure. Once two episodes are independently neutral to the memory, placing one after the other remains neutral. In a communication system, these are invisible input blocks. In a state machine, they are loops returning the machine to its reference state. In data processing, they are sequences annihilated by the summary.

The theorem does not claim that every collision comes from neutral erasure. In groups, equality $M(u)=M(v)$ can often be rearranged into a kernel condition, but a general monoid need not have inverses. That is why the full relation $\sim_M$ matters: it captures all observational identifications, not only words sent to $1_R$.

## The quotient is the observable world

Once indistinguishable streams have been identified, the right object is the quotient $A^*/{\sim_M}$. Its elements are not individual histories but classes $[w]$ of histories with the same remembered state. Multiplication is defined by

$$
[u][v]=[uv].
$$

Because $\sim_M$ is compatible with concatenation, this operation is well defined.

Let $\operatorname{im}(M)=\{M(w):w\in A^*\}$ be the set of memory states that can actually occur. It is itself a submonoid of $R$. The central structural result is the following.

**Observable-Quotient Theorem.** For every compositional memory $M:A^*\to R$, the quotient monoid $A^*/{\sim_M}$ is naturally isomorphic to the reachable memory monoid $\operatorname{im}(M)$.

The isomorphism sends the class $[w]$ to $M(w)$. It is well defined because all representatives of $[w]$ have the same memory. It preserves multiplication because $M(uv)=M(u)M(v)$. It is onto by the definition of the image, and it is one-to-one because equal memories mean equal equivalence classes.

This theorem gives a precise answer to a philosophical question: what remains after forgetting? Not a damaged copy of the original stream, but a quotient world. Every distinction that memory cannot observe is collapsed, and the resulting algebra is exactly the algebra of observable states. Compression and quotienting are two descriptions of the same operation.

## Editing by deleting selected symbols

The theory becomes concrete when forgetting is targeted. Choose a rule $r:A\to\{0,1\}$. A letter $a$ is retained when $r(a)=1$ and deleted when $r(a)=0$. Define $T_r:A^*\to A^*$ by scanning a stream and keeping only retained letters, in their original order. For example, if vowels are retained, then

$$
T_r(\text{stream})=\text{e}.
$$

The empty output acts as the neutral word. Since filtering a concatenation is the same as filtering each part and concatenating the outputs,

$$
T_r(uv)=T_r(u)T_r(v).
$$

Thus targeted forgetting is compositional.

**Forgotten-Symbol Theorem.** If $r(a)=0$, then the one-letter stream $a$ belongs to the erased language of $T_r$.

Indeed, filtering $a$ produces the empty word. More generally, every word made entirely of deleted symbols is erased, while words containing retained symbols may still become indistinguishable when they have the same retained subsequence.

For instance, let $A=\{a,b,c\}$ and retain only $a$ and $c$. Then

$$
T_r(abbcba)=aca,
$$

and the streams $abcba$, $abbcba$, and $acbba$ are indistinguishable whenever each filters to $aca$. Their differences live entirely in positions occupied by the forgotten letter $b$.

## The universal route through forgetting

Targeted forgetting is not only an example; it is canonical. Suppose another compositional map $G:A^*\to S$ never distinguishes two streams that targeted forgetting identifies. In symbols,

$$
T_r(u)=T_r(v)\quad\Longrightarrow\quad G(u)=G(v).
$$

Then $G$ depends only on the retained output, not on the discarded details.

**Universal Factorization Theorem.** Under the preceding condition, there is a unique compositional map

$$
\overline{G}:A^*/{\sim_{T_r}}\to S
$$

such that

$$
G(w)=\overline{G}([w])
$$

for every stream $w$.

Existence is obtained by defining $\overline{G}([w])=G(w)$. The hypothesis makes this independent of the representative. Uniqueness follows because every quotient class has a representative: any map satisfying the factorization is already forced on every class.

This theorem formalizes a common engineering pattern. A privacy filter removes selected fields; every downstream computation that is insensitive to the removed information must operate through the filtered quotient. A compiler discards comments and whitespace; later stages that treat programs with the same token stream alike factor through that normalization. A sensor converts a detailed signal into finite states; every decision based only on those states factors through the induced observational classes.

## Three views of one phenomenon

The results fit together into a single picture.

1. A nonempty alphabet generates infinitely many finite histories.
2. A finite memory has only finitely many states, so distinct histories must collide.
3. Equality of remembered states forms a congruence compatible with concatenation.
4. Completely erased histories form a submonoid.
5. The quotient by observational indistinguishability is exactly the reachable memory algebra.
6. Selective deletion has a universal property: every compatible downstream memory factors uniquely through its quotient.

This synthesis connects information limits with algebraic structure. The pigeonhole principle proves that loss must occur; the quotient theorem explains what shape the loss takes. One is quantitative and unavoidable, the other structural and exact.

The lesson extends far beyond human recollection. Whenever sequential data are compressed compositionally, the encoder edits the space of possible histories by merging them into classes. Finite-state systems cannot avoid those mergers. What they can control is the congruence they create: which distinctions survive, which streams become neutral, and which observable algebra remains.

That perspective also changes how one might design a summary. Asking only how many states it has measures capacity, but not meaning. Two memories with the same number of states may divide history in radically different ways. One may remember parity of length; another may count a particular event modulo a fixed number; a third may retain an exact subsequence while discarding every other symbol. The decisive design object is the partition of histories, together with its compatibility under concatenation. Capacity tells us that collisions exist. Congruence tells us which collisions the system treats as legitimate equivalences.

Forgetting, in this sense, is not chaos. It is an organized collapse. The past is partitioned, the invisible pieces close under combination, and the surviving world is a quotient with its own coherent multiplication. Algebra does not tell us which memories matter. It tells us, with complete precision, what any compositional act of remembering must do.