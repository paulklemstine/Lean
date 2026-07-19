# Hypercomputation, Diagonal Oracles, and the Physical Cost of Exact Information

**Aristotle — July 19, 2026**

## Abstract

We develop a self-contained mathematical model separating two notions often conflated in discussions of hypercomputation. A Boolean predicate is **essentially computable** relative to a program table when it occurs as one of the table's program behaviors; it is **accidentally computable** when an external oracle supplies its values without thereby belonging to that table. The anti-diagonal predicate of any program table is not essentially computable, yet it is evaluated exactly by an oracle loaded with that predicate. An analogous characteristic oracle answers the halting predicate of any fixed machine semantics, while its existence as a specified function supplies no construction of its contents.

We then isolate the physical information premise behind universal exact oracle access. An exact loader maps every infinite binary sequence to a physical state from which every bit can be recovered. Exact recovery forces the loading map to be injective, and therefore forces the physical state space to be infinite. No finite-capacity state space can implement universal exact loading. If a physical model asserts that bounded energy density or finite precision implies finite distinguishable-state capacity, an exact universal loader must violate both finite-resource conditions. This is a conditional information-theoretic theorem, not an unconditional energy law. We also prove that no finite query transcript uniquely identifies an arbitrary infinite oracle.

A companion algebraic model of compositional memory clarifies the same boundary from the opposite direction. Every finite memory of streams over a nonempty alphabet identifies distinct streams; indistinguishability is a monoid congruence, erased streams form a submonoid, and the observational quotient is canonically isomorphic to the reachable memory algebra. Together these results locate the power of hypercomputation in the exact acquisition and discrimination of infinite information rather than in ordinary evaluation.

## 1. Introduction

The halting problem asks whether a given computation eventually stops. For standard universal models of computation there is no single program that answers this question correctly for every program-input pair. Hypercomputation proposes a larger mechanism—often an oracle—that supplies answers beyond the original computational class.

At the level of abstract functions, the proposal is coherent. One may specify an oracle whose answers are exactly the halting predicate, just as one may specify any Boolean function. The logical difficulty lies elsewhere: specifying a function is not an algorithm for producing it. Once an infinite answer table is treated as a physical resource, questions of loading, distinguishability, precision, noise, and empirical certification become unavoidable.

This paper studies three related structures.

First, a **program table** is an arbitrary enumeration of Boolean program behaviors. Diagonalization constructs a Boolean predicate absent from every row. An external oracle can nevertheless carry that predicate. This yields a precise separation between internal representability and external availability.

Second, an **exact universal oracle loader** stores any infinite bitstream in a physical state and permits exact coordinate readout. The readout equation makes loading injective. Consequently, the state space cannot be finite. Physical claims follow only after an explicit bridge identifies bounded resources with finite distinguishable-state capacity.

Third, a **compositional memory** maps finite experience streams into a representation monoid while respecting concatenation. Finite such memory is necessarily lossy. Its information loss is exactly described by a congruence quotient, and selective deletion has a universal factorization property.

These three structures share a common theme: computation and memory are constrained by which distinctions a system can preserve. Diagonalization finds a distinction absent from an enumerated class. Exact loading demands preservation of every distinction among infinite bitstreams. Finite memory necessarily destroys some distinctions among finite streams.

## 2. Program tables and two meanings of computability

Let $\mathbb B=\{0,1\}$, with Boolean complement written $\neg b=1-b$. A **program table** is a function

$$
T:\mathbb N\times\mathbb N\longrightarrow\mathbb B.
$$

The number $e$ is interpreted as a program code and $T(e,n)$ as the Boolean behavior of program $e$ on input $n$. No effectiveness assumption on the entire table is needed for the diagonal argument; the table is the chosen universe of represented behaviors.

### Definition 2.1 (Essential computability)

A predicate $p:\mathbb N\to\mathbb B$ is **essentially computable relative to $T$** if it is a row of $T$:

$$
\exists e\in\mathbb N\;\forall n\in\mathbb N,
\qquad T(e,n)=p(n).
$$

An **oracle** is an external answer function $O:\mathbb N\to\mathbb B$. Oracle evaluation on input $n$ simply returns $O(n)$. We call a predicate **accidentally computable through $O$** if $O(n)=p(n)$ for every $n$. This terminology distinguishes possession of an answer source from representation by the original table. It does not imply randomness or error.

### Definition 2.2 (Anti-diagonal predicate)

For a program table $T$, define

$$
D_T(e)=\neg T(e,e).
$$

### Lemma 2.3 (Diagonal disagreement)

For every code $e$,

$$
T(e,e)\ne D_T(e).
$$

**Proof sketch.** By definition $D_T(e)$ is the Boolean complement of $T(e,e)$. A Boolean value differs from its complement. $\square$

### Theorem 2.4 (Anti-Diagonal Separation Theorem)

For every program table $T$, the anti-diagonal predicate $D_T$ is not essentially computable relative to $T$.

**Proof sketch.** Suppose row $e$ equals $D_T$. Evaluating this equality at input $e$ gives $T(e,e)=D_T(e)$, contradicting Lemma 2.3. Since the contradiction follows for any proposed representing code, no row represents $D_T$. $\square$

### Theorem 2.5 (Accidental-versus-Essential Separation)

For every program table $T$, there exists an oracle $O$ such that

$$
\forall n,\quad O(n)=D_T(n),
$$

but $O$ is not essentially computable relative to $T$.

**Proof sketch.** Take $O=D_T$. Oracle evaluation is then exact by definition, while Theorem 2.4 excludes $O$ from every row of $T$. $\square$

The theorem does not provide an ordinary program for $D_T$. It demonstrates the precise effect of enlarging a model by an externally specified function. The extra power is contained in the oracle's answer function.

## 3. Halting as an oracle specification

Fix a machine semantics $M$ with natural-number inputs. Let $M\downarrow n$ denote the proposition that $M$ eventually halts on input $n$. Define its characteristic oracle by

$$
H_M(n)=\begin{cases}
1,& M\downarrow n,\\
0,& \text{otherwise}.
\end{cases}
$$

This definition uses the truth value of the semantic proposition; it is not an algorithm for discovering that truth value.

### Theorem 3.1 (Exact Halting-Oracle Specification)

For every fixed machine semantics $M$, the oracle $H_M$ satisfies

$$
H_M(n)=1\quad\Longleftrightarrow\quad M\downarrow n
$$

for every input $n$.

**Proof sketch.** The equivalence follows immediately from the two cases in the definition of $H_M$. $\square$

Suppose a program class has the property that none of its Boolean programs decides halting for $M$. More explicitly, suppose every candidate $d:\mathbb N\to\mathbb B$ fails the specification

$$
\forall n,\quad d(n)=1\Longleftrightarrow M\downarrow n.
$$

### Theorem 3.2 (Halting-Oracle Separation)

Under the preceding undecidability hypothesis, the exact halting oracle $H_M$ is accidentally available as an oracle but is not essentially computable in the chosen program table.

**Proof sketch.** Theorem 3.1 gives exact oracle behavior. If $H_M$ were a represented row, that row would satisfy the displayed halting-decider specification, contradicting the hypothesis. $\square$

This result separates semantic specification from effective construction. It is meaningful to define the correct bit for every input, but calling that definition an “oracle” does not explain a physical process that prepares all bits.

## 4. Exact universal oracle loaders

Let $S$ be a type or set of distinguishable physical states. An **exact universal oracle loader** on $S$ consists of maps

$$
L:\mathbb B^{\mathbb N}\to S,
\qquad
R:S\times\mathbb N\to\mathbb B,
$$

satisfying the exactness law

$$
R(L(a),n)=a(n)
\tag{1}
$$

for every infinite bitstream $a$ and index $n$.

The adjective *universal* means that $L$ accepts every element of $\mathbb B^{\mathbb N}$, not merely a fixed finite family or a computably generated subclass. The adjective *exact* means zero readout error at every coordinate.

### Lemma 4.1 (Injectivity of exact loading)

For every exact universal oracle loader, $L$ is injective.

**Proof sketch.** Assume $L(a)=L(b)$. For each $n$, apply $R(-,n)$ to both sides and use equation (1):

$$
a(n)=R(L(a),n)=R(L(b),n)=b(n).
$$

Thus $a$ and $b$ agree at every coordinate, hence $a=b$. $\square$

### Lemma 4.2 (Infinitude of binary oracles)

The set $\mathbb B^{\mathbb N}$ is infinite.

**Proof sketch.** For each $k\in\mathbb N$, define $s_k$ by $s_k(k)=1$ and $s_k(n)=0$ for $n\ne k$. If $j\ne k$, then $s_j$ and $s_k$ differ at coordinate $j$ or $k$. Hence $k\mapsto s_k$ injects $\mathbb N$ into $\mathbb B^{\mathbb N}$. $\square$

The full space is in fact uncountable, but the weaker statement suffices for the finite-capacity obstruction.

### Theorem 4.3 (Infinite-Capacity Theorem)

If an exact universal oracle loader exists on $S$, then $S$ is infinite.

**Proof sketch.** Lemma 4.1 injects the infinite set $\mathbb B^{\mathbb N}$ into $S$. Lemma 4.2 then implies that $S$ cannot be finite. $\square$

### Corollary 4.4 (No finite exact universal loader)

No finite state space admits an exact universal oracle loader.

This theorem is independent of runtime. Even an instantaneous read operation cannot overcome the inability of finitely many states to distinguish all possible oracle contents.

### Theorem 4.5 (Hypercomputation Dichotomy)

Fix a program table $T$ and an exact universal loader on $S$. Load the anti-diagonal oracle $D_T$. Then:

1. the recovered answer function is not essentially computable relative to $T$; and
2. the state space $S$ is infinite.

**Proof sketch.** Exactness gives $R(L(D_T),n)=D_T(n)$ for every $n$. Theorem 2.4 proves that this recovered function is absent from the table. Theorem 4.3 proves that $S$ is infinite. $\square$

The dichotomy joins logical and informational obstructions. Oracle access crosses the table's diagonal boundary, while universal exact preparation crosses the boundary of finite state capacity.

## 5. Conditional resource consequences

A state-count theorem does not by itself establish a physical energy law. To reason carefully, the bridge from physical resources to distinguishable states must be explicit.

### Definition 5.1 (Finite-capacity resource interpretation)

A finite-capacity resource interpretation for a state space $S$ specifies two physical conditions:

- $E_{\mathrm{low}}$: the device operates at bounded or low energy density;
- $P_{\mathrm{fin}}$: the device operates with finite precision;

and assumes the implications

$$
E_{\mathrm{low}}\Longrightarrow S\text{ is finite},
\qquad
P_{\mathrm{fin}}\Longrightarrow S\text{ is finite}.
\tag{2}
$$

The precise content of the physical predicates is model-dependent. Equation (2) is the declared bridge.

### Theorem 5.2 (Finite-Energy-Density Obstruction)

If a physical model implies that bounded energy density gives a finite distinguishable-state space, then no exact universal oracle loader operates under that bounded-energy-density condition.

**Proof sketch.** Under bounded energy density, the bridge assumption makes $S$ finite. Corollary 4.4 excludes an exact universal loader on such an $S$. $\square$

### Theorem 5.3 (Unbounded-Resource Requirement)

Under a finite-capacity resource interpretation, the existence of an exact universal oracle loader implies

$$
\neg E_{\mathrm{low}}\quad\text{and}\quad\neg P_{\mathrm{fin}}.
$$

Equivalently,

$$
\neg(E_{\mathrm{low}}\lor P_{\mathrm{fin}}).
$$

**Proof sketch.** If $E_{\mathrm{low}}$ held, equation (2) would make $S$ finite, contradicting Theorem 4.3. The same argument applies to $P_{\mathrm{fin}}$. Combining the two negations gives the equivalent negation of their disjunction. $\square$

The theorem should not be overstated. Infinite state cardinality does not entail infinite total energy in every imaginable physical theory. For an analog state variable in a bounded interval, cardinality is already infinite. Exact arbitrary-bit recovery from such a variable, however, requires distinctions at arbitrarily small scales; finite precision then fails. Stronger quantitative conclusions require additional hypotheses such as a metric, a minimum separation, noise distributions, volume constraints, or entropy bounds.

## 6. Finite observations and oracle ambiguity

Let $Q\subset\mathbb N$ be finite. A **query transcript** of oracle $a$ on $Q$ is the finite family $(a(q))_{q\in Q}$.

### Theorem 6.1 (Finite-Transcript Ambiguity)

For every oracle $a:\mathbb N\to\mathbb B$ and every finite query set $Q$, there exists an oracle $b$ such that

$$
\forall q\in Q,\quad b(q)=a(q),
$$

but $b\ne a$.

**Proof sketch.** Because $Q$ is finite and $\mathbb N$ is infinite, choose $m\notin Q$. Define $b(n)=a(n)$ for $n\ne m$ and $b(m)=\neg a(m)$. Then $a$ and $b$ agree on every queried coordinate but differ at $m$. $\square$

### Corollary 6.2 (No finite universal identification protocol)

No fixed finite set of coordinate observations uniquely identifies every infinite binary oracle.

The result concerns unrestricted oracles. A finite transcript may identify an oracle within a separately constrained finite family, or a finite certificate may verify a special semantic claim. But no finite coordinate test determines an arbitrary member of $\mathbb B^{\mathbb N}$.

This limits empirical certification. If a claimed halting oracle is queried finitely many times, a rival answer source can match the complete observed transcript while differing elsewhere. Random repetition addresses independent readout errors, not systematic alternatives that agree on all sampled inputs.

## 7. Compositional memory and algebraic forgetting

The oracle results require a memory that distinguishes every infinite answer stream. A complementary theorem explains why finite compositional memory necessarily loses distinctions even among finite streams.

Let $A$ be a nonempty alphabet. Write $A^*$ for the set of finite words over $A$, including the empty word $\varepsilon$. Concatenation is associative and has identity $\varepsilon$, so $A^*$ is the free monoid on $A$.

Let $R$ be a monoid with multiplication and identity $1_R$.

### Definition 7.1 (Compositional memory)

A compositional memory is a monoid homomorphism

$$
m:A^*\to R,
$$

meaning

$$
m(\varepsilon)=1_R,
\qquad
m(xy)=m(x)m(y)
$$

for all words $x,y\in A^*$.

Define the **erased-stream set**

$$
K_m=\{x\in A^*:m(x)=1_R\},
$$

and define **observational indistinguishability** by

$$
x\sim_m y\quad\Longleftrightarrow\quad m(x)=m(y).
$$

### Theorem 7.2 (Finite-Memory Loss Theorem)

If $A$ is nonempty and $R$ is finite, every compositional memory $m:A^*\to R$ maps two distinct streams to the same representation.

**Proof sketch.** Choose a symbol $a\in A$. The words $\varepsilon,a,a^2,a^3,\ldots$ are all distinct, so $A^*$ is infinite. A function from an infinite set to finite $R$ cannot be injective. Thus there exist $x\ne y$ with $m(x)=m(y)$. $\square$

### Lemma 7.3 (Congruence of indistinguishability)

The relation $\sim_m$ is an equivalence relation compatible with concatenation. Specifically, if $x\sim_m y$ and $u\sim_m v$, then

$$
xu\sim_m yv.
$$

**Proof sketch.** Equality of memory representations is reflexive, symmetric, and transitive. Compatibility follows from compositionality:

$$
m(xu)=m(x)m(u)=m(y)m(v)=m(yv).
$$

$\square$

### Lemma 7.4 (Erased streams form a submonoid)

The set $K_m$ contains $\varepsilon$ and is closed under concatenation.

**Proof sketch.** Since $m(\varepsilon)=1_R$, the empty stream lies in $K_m$. If $x,y\in K_m$, then

$$
m(xy)=m(x)m(y)=1_R1_R=1_R,
$$

so $xy\in K_m$. $\square$

### Theorem 7.5 (Memory Quotient Theorem)

The quotient monoid $A^*/{\sim_m}$ is canonically isomorphic to the reachable representation monoid $m(A^*)\subseteq R$.

**Proof sketch.** Send the class $[x]$ to $m(x)$. This is well-defined because equivalent words have equal memories. It preserves identity and concatenation. It is surjective onto $m(A^*)$ by definition. If two classes have the same image, then their representatives have the same memory and are equivalent, so the map is injective. $\square$

Thus observable memory is not merely approximated by a quotient: it is exactly the quotient by all distinctions the memory fails to observe.

### Definition 7.6 (Targeted forgetting)

Let $r:A\to\mathbb B$ mark symbols for retention. Define $F_r:A^*\to A^*$ by replacing a letter $a$ with itself when $r(a)=1$ and with $\varepsilon$ when $r(a)=0$, then concatenating the results.

This operation is compositional. Every symbol marked for deletion belongs to $K_{F_r}$.

### Theorem 7.7 (Universal Property of Targeted Forgetting)

Let $g:A^*\to S$ be any compositional memory into a monoid $S$. Suppose

$$
F_r(x)=F_r(y)\Longrightarrow g(x)=g(y)
$$

for all streams $x,y$. Then there exists a unique monoid homomorphism

$$
\bar g:A^*/{\sim_{F_r}}\to S
$$

such that $g=\bar g\circ q$, where $q$ sends each stream to its $F_r$-indistinguishability class.

**Proof sketch.** Define $\bar g([x])=g(x)$. The hypothesis makes this independent of the representative. Compositionality of $g$ makes $\bar g$ a homomorphism. The factorization equation follows directly. Since every quotient class is $[x]$ for some $x$, that equation determines $\bar g$ uniquely. $\square$

### Corollary 7.8 (Observable algebra of targeted forgetting)

The quotient $A^*/{\sim_{F_r}}$ is canonically isomorphic to the submonoid $F_r(A^*)$ of words composed of retained output.

The universal property says that any compositional observer insensitive to at least the distinctions erased by $F_r$ must operate through the quotient. It provides an algebraic normal form for deliberate forgetting.

## 8. Algorithms and finite demonstrations

The theorems concern infinite objects, but finite truncations make their mechanisms visible.

### Algorithm 8.1 (Finite anti-diagonal construction)

Given an $N\times N$ Boolean table, output $d_i=1-T(i,i)$ for $0\le i<N$. The algorithm performs $N$ diagonal reads and $N$ Boolean complements, using $O(N)$ time and $O(N)$ output space. For each row $i$, the output differs from that row at coordinate $i$.

### Algorithm 8.2 (Transcript-preserving rival construction)

Given a finite Boolean oracle prefix and a finite query set $Q$ that omits some represented index, choose the least unqueried index and flip that bit. The result agrees on all queries and differs globally. With a Boolean membership mask, the construction takes $O(N+|Q|)$ time for a prefix of length $N$ and $O(N)$ output space.

### Algorithm 8.3 (Targeted stream forgetting)

Given a finite word of length $n$ and a retention predicate, scan from left to right and append exactly the retained symbols. This computes $F_r$ in $O(n)$ time and $O(k)$ output space, where $k$ is the number of retained symbols. Applying the scan separately to $x$ and $y$, then concatenating, gives the same output as scanning $xy$, illustrating compositionality.

These algorithms do not compute the unrestricted halting predicate or certify an infinite oracle. They illustrate the finite combinatorial cores of diagonal disagreement, transcript ambiguity, and quotient-style forgetting.

## 9. Applications and interpretation

### 9.1 Hypercomputational architecture

The model divides a hypothetical device into loading and evaluation. Evaluation is trivial: read coordinate $n$. All nonordinary power lies in preparing the exact state $L(a)$. This prevents a category error in which specification of $a$ is mistaken for its production.

### 9.2 Analog proposals

A continuum-valued state space evades the bare finite-cardinality premise, but not automatically the precision issue. Encoding a bitstream in the binary expansion of a real number requires access to arbitrarily remote digits. Uniformly reliable recovery would need a physical separation or error-correction principle not supplied by cardinality alone.

### 9.3 Experimental claims

Finite-transcript ambiguity shows that finite black-box testing cannot establish agreement with an unrestricted infinite semantic oracle. Validation must exploit extra structure: checkable certificates, restricted oracle classes, probabilistic assumptions, or independently justified physical laws.

### 9.4 Memory, compression, and abstraction

Finite compositional representations inevitably merge histories. The quotient theorem identifies the exact algebra retained after compression, while the kernel submonoid records streams erased to neutrality. This applies to automata, event logs, symbolic preprocessing, and any sequential representation respecting concatenation.

## 10. Limitations

The results are exact and qualitative. They do not show that a particular physical technology consumes a specified number of joules. They do not rule out infinite state spaces under every physical theory. They do not address approximate oracle answers, bounded input ranges, or restricted oracle families. They also do not turn a semantically defined halting oracle into a constructible object.

The energy and precision conclusion is conditional on the finite-capacity implications in equation (2). This explicit dependence is a strength: it separates the mathematical injection theorem from contingent physical assumptions and indicates exactly what stronger science must supply.

## 11. Future work

A quantitative theory should replace finite-versus-infinite capacity with metric packing bounds. If $n$ oracle bits must remain distinguishable at noise scale $\varepsilon$ inside volume $V$ and energy budget $E$, one seeks inequalities relating $n$, $\varepsilon$, and $E/V$.

Noisy queries require a distinction between independent readout errors and systematic semantic corruption. Repetition can suppress the former, while finite-transcript ambiguity suggests that the latter requires independently checkable certificates.

Iterated oracle models should realize successive diagonal levels: a level-$k+1$ oracle answers halting questions for machines equipped with level-$k$ access, while a new anti-diagonal escapes the lower level.

For compact analog state spaces, topology and uniform readout margins may provide the appropriate obstruction. Cardinality permits a continuum of states, but robustness may force an impossible infinite packing.

Finally, finite approximations connect oracle storage to thermodynamics. Resetting $n$ uniformly distributed independent bits removes $n\log 2$ of Shannon entropy; an explicit thermodynamic bridge could translate this into a heat cost under stated physical assumptions.

## 12. Conclusion

The anti-diagonal construction proves that every program table omits a Boolean predicate. An oracle carrying that predicate returns it exactly, and a characteristic oracle similarly answers a fixed machine's halting predicate. This is the clean sense in which oracle computation exceeds essential computation relative to the original table.

Universal exact oracle access, however, requires more than a query instruction. Exact loading is injective, so infinitely many distinguishable states are necessary; finite-capacity implementations are impossible. Under explicit physical principles connecting bounded energy density and finite precision to finite state capacity, exact universal loading violates both finite-resource regimes. No finite experiment can uniquely certify an arbitrary infinite oracle.

The algebra of memory supplies the complementary picture. Finite compositional memory must identify distinct streams, and its observable content is exactly the quotient by that indistinguishability. Hypercomputation asks for the opposite extreme: preserve every distinction among infinite answer streams. The apparent miracle of computing the uncomputable is therefore relocated, not eliminated. It resides in the acquisition, storage, discrimination, and trust of an exact infinite oracle.
