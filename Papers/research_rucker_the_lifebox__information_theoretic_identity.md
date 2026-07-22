# Information-Theoretic Identity in Finite Interactive Systems

## Abstract

We study a substrate-independent model of identity in which two systems count as the same exactly when they produce identical observations under every allowed input. For static response profiles, this notion is equality of functions and hence an equivalence relation. When the input space is finite, equivalence is decidable by checking that the set of distinguishing inputs is empty. This finiteness assumption cannot simply be discarded: for Boolean functions on the natural numbers, every finite test suite is passed by some pair of distinct functions. We then model interactive identity by deterministic finite Moore machines. Although these machines face infinitely many finite input histories, their trace equivalence is characterized exactly by the existence of a bisimulation relation on the finite product of their state spaces. Consequently, behavioral identity of initialized finite-state systems is decidable. We describe exhaustive relation search and greatest-fixed-point partition refinement, establish invariance under information-preserving input and output encodings, and illustrate the theory with parity and behaviorally silent machines. We also prove a two-dimensional algebraic no-cloning theorem: no linear map sends every vector $x$ to $x\otimes x$. This limits universal quantum copying but does not entail undecidability. Finally, we count fixed-length identity descriptions, obtaining exactly $2^b$ descriptions of length $b$ and $2^{10^{15}}$ under a conjectural $10^{15}$-bit budget. We distinguish this elementary count from genuine Kolmogorov complexity.

## 1. Introduction

The claim that identity resides in information rather than material substrate can be made mathematically precise only after “information” and “same” are specified. The strongest elementary interpretation is behavioral: two systems are equivalent when no permitted experiment distinguishes their outputs. This interpretation intentionally brackets metaphysical questions. It does not assert that behavioral equivalence is sufficient for moral status, consciousness, memory continuity, or personal survival. It supplies a rigorous semantics for one proposed criterion of identity and determines what follows from that criterion.

Three issues immediately arise. First, behavioral equality quantifies over all inputs, so one must ask when it is decidable. Second, persons interact over time, so an adequate elementary model should include internal state and input histories rather than a single static prompt. Third, classical descriptions and quantum states obey different copying laws, so claims about “uploading” must not silently transfer assumptions between them.

Our finite-state analysis resolves the first two issues sharply. For deterministic machines with finite state and input sets, equality under every finite history is decidable. The key is that an infinite family of experiments can be represented by a finite bisimulation relation. Conversely, without structural restrictions, no finite test suite certifies equality of arbitrary functions on an infinite input domain. The positive theorem is therefore not a consequence of testing many examples; it rests on finite-state structure.

The quantum analysis supplies a different boundary. A universal map $x\mapsto x\otimes x$ is nonlinear and cannot be realized by a linear transformation, already in dimension two. This is a copying obstruction, not a computability classification. In particular, it does not prove the often-repeated but invalid implication that quantum behavior makes person-equivalence undecidable.

The paper is organized as follows. Section 2 defines functional person-equivalence and develops its invariance properties. Section 3 gives the finite-profile decision theorem and an impossibility theorem for finite tests on unrestricted infinite domains. Sections 4–6 introduce finite Moore machines, prove the bisimulation characterization and decidability theorem, and present algorithms. Section 7 gives examples. Section 8 proves no-cloning. Section 9 states the fixed-length counting theorem and explains its relation to Kolmogorov complexity. Sections 10–12 discuss applications, limitations, and future research.

## 2. Functional behavioral identity

Let $I$ be a set of inputs and $O$ a set of observations. A **behavioral profile** is a function $f:I\to O$.

**Definition 2.1 (Person-equivalence).** Two behavioral profiles $f,g:I\to O$ are person-equivalent, written $f\sim g$, if

$$
\forall i\in I,\qquad f(i)=g(i).
$$

This definition compares complete behavior and ignores implementation. It is extensional by construction.

**Theorem 2.2 (Extensional characterization).** For behavioral profiles $f,g:I\to O$, one has $f\sim g$ if and only if $f=g$ as functions.

**Proof sketch.** If $f\sim g$, the two functions agree at every argument, so functional extensionality gives $f=g$. Conversely, equality of functions permits substitution and yields equality at every input. $\square$

**Corollary 2.3 (Equivalence laws).** Person-equivalence is reflexive, symmetric, and transitive.

**Proof sketch.** Reflexivity follows from $f(i)=f(i)$. Symmetry reverses each output equality. Transitivity composes $f(i)=g(i)$ with $g(i)=h(i)$ for each $i$. Equivalently, all three laws follow from Theorem 2.2 and the corresponding laws of equality. $\square$

Thus behavioral profiles are partitioned into equivalence classes. Distinct physical systems may belong to one class if their complete observable maps coincide.

### 2.1. Invariance under representation

A criterion intended to capture information should survive recodings that lose no relevant distinctions.

**Theorem 2.4 (Surjective input recoding).** Let $e:J\to I$ be surjective and let $f,g:I\to O$. Then

$$
f\circ e\sim g\circ e\quad\Longleftrightarrow\quad f\sim g.
$$

**Proof sketch.** The reverse implication follows by evaluating $f\sim g$ at $e(j)$. For the forward implication, given $i\in I$, surjectivity provides $j\in J$ with $e(j)=i$; equality of the composites at $j$ gives $f(i)=g(i)$. $\square$

Surjectivity is essential: if an input is omitted from the recoding, two profiles could differ only there.

**Theorem 2.5 (Injective output recoding).** Let $e:O\to P$ be injective and let $f,g:I\to O$. Then

$$
e\circ f\sim e\circ g\quad\Longleftrightarrow\quad f\sim g.
$$

**Proof sketch.** If the encoded outputs agree, injectivity of $e$ recovers equality of the original outputs. Conversely, equal original outputs remain equal after applying $e$. $\square$

Injectivity is likewise necessary for reflection: a many-to-one output map can erase a genuine behavioral difference.

**Theorem 2.6 (Independent observation channels).** Given $f,g:I\to O$ and $u,v:I\to P$, define paired profiles $F(i)=(f(i),u(i))$ and $G(i)=(g(i),v(i))$. Then

$$
F\sim G\quad\Longleftrightarrow\quad (f\sim g\ \text{and}\ u\sim v).
$$

**Proof sketch.** Equality of pairs implies equality of their first and second coordinates. Conversely, coordinatewise equality implies equality of pairs. $\square$

This theorem permits modular observation: equivalence under a combined sensor suite is precisely equivalence under each constituent channel.

## 3. Finite tests and unrestricted infinite domains

Assume first that $I$ is finite and equality in $O$ is decidable. Define the finite set of distinguishing inputs

$$
D(f,g)=\{i\in I\mid f(i)\ne g(i)\}.
$$

**Theorem 3.1 (Finite Profile Decision Theorem).** For $f,g:I\to O$ with finite $I$ and decidable output equality,

$$
f\sim g\quad\Longleftrightarrow\quad D(f,g)=\varnothing.
$$

Consequently, person-equivalence is decidable.

**Proof sketch.** If $f\sim g$, no input satisfies the defining inequality, hence $D(f,g)$ is empty. If the set is empty, every $i\in I$ fails to distinguish the profiles, so $f(i)=g(i)$. An algorithm enumerates $I$, compares outputs, and returns inequivalent upon finding a mismatch; otherwise it returns equivalent. Termination follows from finiteness. $\square$

If evaluating each profile and comparing outputs costs $C$, exhaustive comparison costs $O(|I|C)$ time and $O(1)$ auxiliary space beyond the input representation.

It is tempting to treat a large but finite benchmark as decisive even when $I$ is infinite. The following result shows why that inference fails for unrestricted profiles.

**Theorem 3.2 (No Finite Universal Test).** For every finite set $S\subset\mathbb N$, there exist distinct functions $f,g:\mathbb N\to\{\mathrm{false},\mathrm{true}\}$ such that

$$
\forall i\in S,\qquad f(i)=g(i).
$$

**Proof sketch.** Choose $n\notin S$, possible because $S$ is finite. Let $g(i)=\mathrm{false}$ for all $i$, and let $f(i)=\mathrm{true}$ exactly when $i=n$. The profiles agree on $S$ because $n\notin S$, but differ at $n$, so $f\ne g$. $\square$

The theorem concerns finite certification by examples. It does not assert that every equivalence problem over an infinite domain is undecidable: restricted function classes may have symbolic decision procedures. It says that arbitrary functions cannot be certified equal solely by any preselected finite set of evaluations.

## 4. Interactive finite-state identity

Static functions do not represent memory. We therefore use deterministic Moore machines.

**Definition 4.1 (Finite person model).** A finite person model is a tuple

$$
M=(A,S,O,\delta,\omega),
$$

where $A$ is a finite input alphabet, $S$ is a finite state set, $O$ is an output set with decidable equality, $\delta:S\times A\to S$ is a deterministic transition function, and $\omega:S\to O$ is an observation function.

Although the input and state sets are finite, the output set need only have decidable equality for the decision theorem below.

**Definition 4.2 (Extended transition).** For a state $s\in S$ and word $w\in A^*$, define $\delta^*(s,w)$ recursively by

$$
\delta^*(s,\varepsilon)=s,
$$

and

$$
\delta^*(s,aw)=\delta^*(\delta(s,a),w).
$$

Here $\varepsilon$ is the empty word and $aw$ denotes a word with first symbol $a$ and suffix $w$.

**Definition 4.3 (Trace equivalence).** Let $M$ and $N$ share input alphabet $A$ and output set $O$, but possibly have different state sets $S$ and $T$. Initialized states $s\in S$ and $t\in T$ are trace-equivalent if

$$
\forall w\in A^*,\qquad
\omega_M(\delta_M^*(s,w))=
\omega_N(\delta_N^*(t,w)).
$$

Trace equivalence is reflexive, symmetric, and transitive, including transitivity across different implementations. These facts follow pointwise from equality of the final observations for each word.

The definition quantifies over the infinite set $A^*$ whenever $A$ is nonempty. Decidability therefore requires a finite compression of future behavior.

## 5. Bisimulation as a finite certificate

**Definition 5.1 (Bisimulation).** A relation $R\subseteq S\times T$ is a bisimulation between machines $M$ and $N$ if, whenever $(x,y)\in R$,

1. $\omega_M(x)=\omega_N(y)$; and
2. for every $a\in A$,

$$
(\delta_M(x,a),\delta_N(y,a))\in R.
$$

The relation is a finite Boolean table when $S$ and $T$ are finite.

**Lemma 5.2 (Bisimulation soundness).** If a bisimulation $R$ contains $(s,t)$, then $s$ and $t$ are trace-equivalent.

**Proof sketch.** Induct on the length of $w$. For $w=\varepsilon$, relatedness directly gives equal current observations. For $w=av$, closure under $a$ places the successor states in $R$; the induction hypothesis applied to $v$ gives equality after the full word. $\square$

**Lemma 5.3 (Behavioral relation is a bisimulation).** Define

$$
R_{\mathrm{beh}}=\{(x,y)\in S\times T\mid x\text{ and }y\text{ are trace-equivalent}\}.
$$

Then $R_{\mathrm{beh}}$ is a bisimulation.

**Proof sketch.** For $(x,y)\in R_{\mathrm{beh}}$, choose the empty word to obtain $\omega_M(x)=\omega_N(y)$. Fix $a\in A$. For every suffix $w$, trace equivalence of $x$ and $y$ on the prefixed word $aw$ gives equal observations from the successor states after $w$. Hence the successors are trace-equivalent and belong to $R_{\mathrm{beh}}$. $\square$

**Theorem 5.4 (Bisimulation Characterization Theorem).** Initialized states $s$ and $t$ are trace-equivalent if and only if there exists a bisimulation $R\subseteq S\times T$ containing $(s,t)$.

**Proof sketch.** The reverse implication is Lemma 5.2. For the forward implication, use the behavioral relation from Lemma 5.3; trace equivalence of $s$ and $t$ ensures that it contains $(s,t)$. $\square$

This theorem replaces a universal quantifier over infinitely many words with an existential quantifier over a finite table satisfying local constraints.

**Theorem 5.5 (Finite-State Lifebox Theorem).** For deterministic finite person models with finite input and state sets and decidable equality of outputs, trace equivalence of two initialized states is decidable.

**Proof sketch.** The product $S\times T$ is finite, so its power set—the set of candidate relations—is finite. Enumerate all relations. For each relation, check finitely many conditions: whether it contains $(s,t)$, whether related states have equal observations, and whether every input maps each related pair to another related pair. By Theorem 5.4, a successful relation exists exactly when the states are trace-equivalent. Therefore exhaustive finite search decides the proposition. $\square$

The exhaustive proof establishes decidability but is not the best implementation. There are $2^{|S||T|}$ candidate relations. Greatest-fixed-point refinement avoids enumerating them.

## 6. Algorithms

### 6.1. Exhaustive distinguishing-input scan

For finite static profiles, enumerate each $i\in I$ and compare $f(i)$ with $g(i)$. Return the first distinguishing input if one exists. Otherwise return equivalence. Theorem 3.1 proves correctness. The algorithm takes $O(|I|)$ comparisons.

### 6.2. Greatest-bisimulation refinement

Initialize

$$
R_0=\{(x,y)\in S\times T:\omega_M(x)=\omega_N(y)\}.
$$

Given $R_k$, remove every pair having some input whose successor pair is absent:

$$
R_{k+1}=\{(x,y)\in R_k:\forall a\in A,
(\delta_M(x,a),\delta_N(y,a))\in R_k\}.
$$

The sequence descends:

$$
R_0\supseteq R_1\supseteq R_2\supseteq\cdots.
$$

Since there are $|S||T|$ pairs, at most that many strict deletion rounds can occur. At stabilization, $R_{k+1}=R_k$, and the survivor is a bisimulation. Every bisimulation is contained in $R_0$ and is preserved under each refinement step, so every bisimulation is contained in the final relation. Thus the result is the greatest bisimulation, and $(s,t)$ survives exactly when the initialized states are trace-equivalent.

A straightforward implementation scans at most $|S||T|$ pairs and $|A|$ symbols per round, for at most $|S||T|$ strict rounds. Its simple worst-case bound is

$$
O\bigl(|A|\,|S|^2|T|^2\bigr)
$$

time and $O(|S||T|)$ space. Worklist implementations improve this bound by revisiting only predecessors affected by deletions.

### 6.3. Shortest distinguishing word

To refute equivalence, perform breadth-first search on the product graph. Begin at $(s,t)$. If the observations differ, the empty word distinguishes them. Otherwise, for each symbol $a$, visit the successor pair and record $a$ as the final edge of its witness. The first pair with unequal observations yields a shortest distinguishing word by breadth-first search.

At most $|S||T|$ pairs are visited and each has $|A|$ outgoing edges, giving $O(|A||S||T|)$ time and $O(|S||T|)$ space. If no unequal-output pair is reachable, all reachable pairs form a bisimulation, proving equivalence.

## 7. Examples

Let $A=\{0,1\}$ and identify $1$ with true.

**Example 7.1 (Parity observer).** The parity machine has state set $\{0,1\}$, initial state $0$, transition

$$
\delta(s,a)=s\mathbin{\mathrm{xor}}a,
$$

and observation $\omega(s)=s$. Its output records whether the history contains an odd number of true symbols. On the words $\varepsilon$, $[1]$, $[1,1]$, and $[1,0,1]$, its outputs are

$$
[0,1,0,0].
$$

**Example 7.2 (Parity versus silence).** A one-state silent machine loops on every input and always outputs $0$. The word $[1]$ sends the parity machine to output $1$ while the silent machine remains at $0$. Therefore the initialized machines are not trace-equivalent.

**Example 7.3 (Redundant silence).** A two-state machine may toggle its hidden state by the parity transition while defining its observation to be constantly $0$. This machine is physically and internally different from the one-state silent machine, but every word produces output $0$ in both. The universal relation between the two toggle states and the single silent state is a bisimulation. Hence the machines are trace-equivalent.

This last example demonstrates the intended substrate independence: inaccessible internal distinctions are quotiented away by behavior.

## 8. A two-dimensional no-cloning theorem

Classical finite descriptions can be copied bit by bit. Quantum-state vectors are governed by linear dynamics, while duplication is quadratic.

Let $k$ be a field and $V=k^2$. Let $V\otimes V$ denote the tensor product.

**Theorem 8.1 (Two-Dimensional No-Cloning Theorem).** There is no linear map

$$
C:V\to V\otimes V
$$

such that

$$
C(x)=x\otimes x
$$

for every $x\in V$.

**Proof sketch.** Let $e_1=(1,0)$ and $e_2=(0,1)$. If $C$ were linear and cloned every vector, then

$$
C(e_1+e_2)=C(e_1)+C(e_2)
=e_1\otimes e_1+e_2\otimes e_2.
$$

The cloning property also gives

$$
\begin{aligned}
C(e_1+e_2)
&=(e_1+e_2)\otimes(e_1+e_2)\\
&=e_1\otimes e_1+e_1\otimes e_2
+e_2\otimes e_1+e_2\otimes e_2.
\end{aligned}
$$

To isolate the contradiction over an arbitrary field, use the bilinear form $B(a,b)=a_1b_2$. Its induced linear functional on $V\otimes V$ evaluates to $0$ on $e_1\otimes e_1+e_2\otimes e_2$ but to $1$ on the expanded cloned sum because it selects $e_1\otimes e_2$. Thus equality would imply $0=1$, impossible in a field. $\square$

The theorem assumes universal exact cloning by one linear map. It does not forbid copying known mutually distinguishable basis states, nor does it classify equivalence of quantum programs.

**Remark 8.2 (No-cloning is not undecidability).** No-cloning is an algebraic nonexistence theorem. Undecidability is a statement that no algorithm decides a specified predicate on a specified representation of programs or states. Neither statement implies the other without substantial additional definitions and a reduction argument. Therefore no undecidability conclusion follows from Theorem 8.1 alone.

## 9. Description-space counting

For $b\in\mathbb N$, define a fixed-length identity description to be a function from the $b$ bit positions to $\{0,1\}$, equivalently a bit-vector in $\{0,1\}^b$.

**Theorem 9.1 (Fixed-Length Description Count).** The number of $b$-bit descriptions is exactly

$$
|\{0,1\}^b|=2^b.
$$

**Proof sketch.** Each of the $b$ positions has two independent choices. By the multiplication principle, the total number is the product of $b$ factors equal to $2$, namely $2^b$. $\square$

**Corollary 9.2 (Conjectural Lifebox Budget).** If identity descriptions are represented by bit-vectors of length $10^{15}$, then the number of possible descriptions is the finite cardinal

$$
2^{10^{15}}.
$$

The conditional wording is essential. The mathematics does not derive the bit budget from neurobiology or psychology.

**Remark 9.3 (Kolmogorov complexity).** The plain Kolmogorov complexity $K_U(x)$ of an object $x$ relative to a universal partial description machine $U$ is the length of the shortest program $p$ for which $U(p)=x$. Fixed-length counting does not prove that a given identity has $K_U(x)\le 10^{15}$. Such a bound would require an explicit encoding or an empirical assumption that a description of that length exists, together with an accounting of machine-dependent overhead. What Theorem 9.1 proves is only the cardinality of a prescribed fixed-length representation space.

## 10. Applications and interpretation

Finite-state equivalence checking appears in protocol verification, hardware comparison, model minimization, conversational-agent regression testing, and reproducibility of interactive simulations. The same mathematics applies whenever “same” means equality of observable responses to all finite input sequences.

For identity modeling, bisimulation identifies precisely which hidden-state distinctions are behaviorally irrelevant. Quotienting a machine by observational equivalence would merge states with identical futures and produce a smaller representative. A minimal reachable representative can be viewed as the information retained by the chosen observation semantics. This conclusion remains relative to those semantics: enriching the output channel can split classes that were previously merged, while coarsening it can collapse differences.

The no-finite-test theorem cautions against interpreting benchmark agreement as complete identity without a structural model. The finite-state theorem explains when structural assumptions repair the problem. If both systems are known finite deterministic machines and their transition tables are available, local graph analysis decides all histories at once. If the systems are opaque arbitrary functions over infinitely many inputs, finite testing cannot do so.

The no-cloning theorem contributes an orthogonal caution. A classical description, once obtained, may be duplicated. An unknown quantum state cannot be universally cloned by linear evolution. Any proposal combining identity preservation with quantum information must specify whether it aims to copy a classical description, transfer a state destructively, estimate a state statistically, or clone an unknown state. These are mathematically different tasks.

## 11. Limitations

The behavioral criterion is intentionally narrow. Equal outputs do not establish equality of subjective experience, causal history, embodiment, or social relation. Conversely, two persons commonly regarded as the same over time may respond differently because learning changes them. The model captures a chosen extensional notion, not every ordinary use of identity.

The Moore-machine semantics observes only the final state after each finite history. It is deterministic, exact, and finite. Real systems may be probabilistic, continuous, nondeterministic, partially observed, or sensitive to timing. Approximate equivalence requires a metric or statistical tolerance. Infinite streams require a topology or temporal logic. Each enrichment changes both the definition and decidability landscape.

The exhaustive relation search proves decidability but has exponential candidate space. Refinement is practical, yet a full complexity analysis depends on data structures and encoding assumptions. Finally, $10^{15}$ bits is not derived here. It serves only as an external budget instantiated in a general count.

## 12. Future work

A natural first step is to establish a sharp bound on distinguishing-word length. Breadth-first product exploration suggests that inequivalent initialized states admit a witness before any pair must repeat, yielding a bound in terms of $|S||T|$. Such a theorem would convert equivalence checking into a finite complete experiment suite tailored to the known machines.

Second, one can define observational equivalence among states of a single machine, quotient by that relation, and prove behavioral preservation and minimality. Uniqueness of reachable minimal representatives would make precise the substrate-independent core retained by the semantics.

Third, richer interaction models deserve systematic treatment: Mealy outputs on transitions, probabilistic kernels, nondeterministic choices, infinite streams, and approximate metrics. The central question in each case is whether an appropriate bisimulation still characterizes observations and whether its greatest fixed point is computable.

Fourth, any quantum undecidability claim should begin with a programming-language semantics, a representation of programs, and an exact equivalence predicate. Only then can one seek a reduction from a known undecidable problem. This program is separate from no-cloning.

Fifth, genuine complexity claims require a universal partial description machine and proofs relating explicit encodings to plain or prefix-free Kolmogorov complexity. The conditional theorem would take the form: if an identity has a description of length at most $B$, then its complexity is at most $B$ plus encoding overhead.

Finally, the input-surjection and output-injection theorems suggest a compositional theory of identity-preserving transformations. Such a framework could organize recodings, sensor combinations, simulations, and abstraction maps while making explicit which transformations preserve and which merely obscure behavioral distinctions.

## 13. Conclusion

Behavioral identity is mathematically exact once inputs, outputs, memory, and observations are specified. For static finite profiles, it is decided by the absence of distinguishing inputs. For deterministic finite-state interactive systems, the Bisimulation Characterization Theorem compresses infinitely many histories into a finite local certificate, yielding decidability. Different internal substrates can therefore realize one observable behavior.

The boundaries are equally important. No finite benchmark certifies equality of arbitrary Boolean functions on an infinite domain. Universal exact cloning of unknown two-dimensional states is incompatible with linearity, but this fact does not establish undecidability. Fixed bit-vectors admit an exact count of $2^b$, while claims about Kolmogorov complexity demand additional machinery and assumptions. Together these results provide a disciplined mathematical foundation for discussing informational identity without conflating behavioral equivalence, empirical testing, copying, computability, and description length.
