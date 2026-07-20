# Self-Modifying Termination, Diagonal Fixed Points, and Algebraic Forgetting

**Aristotle**  
**July 20, 2026**

## Abstract

We study universal termination prediction for machines whose program may change during execution and connect the resulting impossibility to two broader mathematical structures: diagonal fixed-point theorems and quotient models of finite memory. A self-modifying machine has configurations in $P\times S$ and a transition that may update both the program $p\in P$ and the ordinary state $s\in S$. We prove a step-for-step simulation theorem: placing the current program inside the state yields an ordinary fixed-program machine with identical finite runs and identical termination behavior. We then construct an explicit universal monitor using a bounded evaluator. From initial configuration $(c,0)$ it halts exactly when code $c$ halts on a fixed input. Hence its halting predicate is undecidable, although it is recursively enumerable, while its nonhalting predicate is not recursively enumerable.

The logical source of this asymmetry is expressed through Lawvere’s fixed-point theorem. A surjection $A\to B^A$ forces every endomap of $B$ to have a fixed point; choosing fixed-point-free Boolean negation yields Cantor’s theorem and the diagonal obstruction underlying termination undecidability. Kleene’s recursion theorem supplies the complementary positive result that every computable program rewriter has a behavioral fixed point. Finally, we model experience streams as a free monoid and compositional memories as monoid homomorphisms. Any finite memory merges distinct streams; erased streams form a submonoid; and the observable algebra is canonically isomorphic to the quotient by observational indistinguishability. A targeted deletion filter satisfies the corresponding universal factorization property. Together these results separate representational flexibility from computability, and characterize precisely both the impossibility of universal prediction and the structure of information lost by finite observation.

## 1. Introduction

Self-modifying systems allow executable descriptions to participate in state evolution. Such systems include runtime optimizers, adaptive interpreters, evolutionary programs, mobile code, and malicious software that rewrites itself to evade static signatures. Their apparent circularity raises two questions. First, does changing the program during execution increase computational power beyond ordinary universal computation? Second, can a general analyzer predict whether every such execution terminates?

The answers are respectively no and no. The first answer follows from a direct encoding: the current program can be stored as part of an ordinary machine state. The second follows because ordinary universal computation already embeds into the self-modifying model. More significantly, the impossibility is not peculiar to any instruction set. It is an instance of diagonalization: a total predictor would enable construction of behavior that disagrees with the predictor on its own code.

We organize this phenomenon around three bridges.

1. **Operational bridge.** A self-modifying transition system and a fixed-program system over an enlarged state space have identical runs.
2. **Logical bridge.** Lawvere’s fixed-point theorem, Cantor’s theorem, the halting problem, and computable self-reproduction share one diagonal mechanism.
3. **Observational bridge.** Finite compositional memories of unbounded streams necessarily identify distinct histories, and their observable content is exactly a quotient algebra.

The third bridge complements undecidability. A predictor or monitor never sees raw execution history without mediation; it stores a representation. Modeling that representation algebraically reveals unavoidable collision and a canonical description of what remains observable.

The paper is self-contained at the level of its mathematical argument. We assume a standard universal programming system: programs have effective codes, there is a partial universal evaluator, and bounded evaluation is computable. These are precisely the usual ingredients of Turing completeness.

## 2. Fixed points and diagonalization

### 2.1. Point-surjective families

For sets $A$ and $B$, write $B^A$ for the set of functions $A\to B$. A map $g:A\to B^A$ associates to each $a\in A$ a function $g(a):A\to B$. It is **point-surjective** here when it is surjective as a map into the full function space: every function $A\to B$ equals $g(a)$ for some $a$.

**Theorem 2.1 (Lawvere Fixed-Point Theorem).** Let $g:A\to B^A$ be surjective. Then every function $f:B\to B$ has a fixed point; that is, there exists $b\in B$ such that $f(b)=b$.

**Proof sketch.** Define $h:A\to B$ by

$$
h(a)=f(g(a)(a)).
$$

By surjectivity, choose $a_0$ with $g(a_0)=h$. Then

$$
g(a_0)(a_0)=h(a_0)=f(g(a_0)(a_0)).
$$

Thus $b=g(a_0)(a_0)$ is fixed by $f$. The crucial operation is evaluation on the diagonal $(a,a)$. $\square$

The contrapositive is often the more useful form.

**Corollary 2.2 (Fixed-Point Obstruction).** If $f:B\to B$ has no fixed point, then no map $A\to B^A$ is surjective.

Take $B=\{0,1\}$ and let $\nu$ be Boolean negation. Since $\nu(0)=1$ and $\nu(1)=0$, it has no fixed point.

**Corollary 2.3 (Boolean Cantor Theorem).** For every set $A$, no map $A\to\{0,1\}^A$ is surjective.

Identifying a subset $U\subseteq A$ with its characteristic function $\chi_U:A\to\{0,1\}$ gives the familiar power-set statement.

**Corollary 2.4 (Power-Set Cantor Theorem).** No function $A\to\mathcal P(A)$ is surjective.

The usual diagonal subset is $D=\{a\in A:a\notin g(a)\}$. If $D=g(d)$, then $d\in D$ if and only if $d\notin D$.

### 2.2. A table formulation

Suppose $e:A\to(A\to\{0,1\})$ claims to enumerate every Boolean predicate on $A$. Any table $d:A\times A\to\{0,1\}$ agreeing with every entry of this enumeration satisfies $d(i,a)=e(i)(a)$. The diagonal complement $a\mapsto\nu(d(a,a))$ cannot equal any row.

**Theorem 2.5 (Diagonal Impossibility).** If $e:A\to(A\to\{0,1\})$ is surjective, there is no total table $d:A\times A\to\{0,1\}$ satisfying $d(i,a)=e(i)(a)$ for all $i,a\in A$.

**Proof sketch.** Such a table would merely reproduce $e$. But the assumed surjectivity contradicts Corollary 2.3. Equivalently, choose a row representing the diagonal complement and evaluate it at its own index. $\square$

This formulation anticipates termination prediction: rows are programs, columns are inputs, and table entries are alleged yes-or-no halting verdicts.

## 3. Self-modifying transition systems

### 3.1. Definitions

Let $P$ be a set of programs and $S$ a set of ordinary machine states.

**Definition 3.1 (Self-Modifying Machine).** A self-modifying machine is a transition map

$$
T:P\times S\longrightarrow (P\times S)\sqcup\{\mathsf{halt}\}.
$$

If $T(p,s)=(p',s')$, one step updates both code and state. If $T(p,s)=\mathsf{halt}$, execution terminates.

Define the bounded run $R_T((p,s),n)$ recursively. At depth $0$, it returns $(p,s)$. At depth $n+1$, it returns $\mathsf{halt}$ if the first transition halts; otherwise, if the first transition returns $(p',s')$, it computes $R_T((p',s'),n)$. We say that $T$ **halts from** $(p,s)$ if $R_T((p,s),n)=\mathsf{halt}$ for some $n\in\mathbb N$.

**Definition 3.2 (Fixed-Program Machine).** A fixed-program machine over a state set $X$ is a transition

$$
U:X\longrightarrow X\sqcup\{\mathsf{halt}\}.
$$

Its bounded run and halting predicate are defined by the same recursion.

### 3.2. Encoding code as data

Given $T$, define a fixed-program machine $\widehat T$ over $P\times S$ by

$$
\widehat T(p,s)=T(p,s).
$$

The right side is interpreted simply as a transition of the enlarged ordinary state. The simulator’s own transition law is fixed; the value $p$ is data stored in that state.

**Theorem 3.3 (Step-for-Step Simulation).** For every self-modifying machine $T$, configuration $(p,s)$, and $n\in\mathbb N$,

$$
R_T((p,s),n)=R_{\widehat T}((p,s),n).
$$

**Proof sketch.** Induct on $n$. At $n=0$, both runs return the initial pair. For $n+1$, inspect $T(p,s)$. If it halts, both runs halt immediately. If it returns $(p',s')$, both recursive calls begin from the same pair, and the induction hypothesis applies. $\square$

**Corollary 3.4 (Termination Equivalence).** A self-modifying machine $T$ halts from $(p,s)$ if and only if its fixed-program simulation $\widehat T$ halts from $(p,s)$.

The corollary follows by existentially quantifying the common finite step bound. It establishes that self-modification adds representational convenience but no new class of computable partial functions.

## 4. An explicit universal termination monitor

### 4.1. Universal codes and bounded evaluation

Let $C$ be an effective set of program codes. For $c\in C$ and input $x\in\mathbb N$, let $\varphi_c(x)$ denote the associated partial computation. Its domain statement $\varphi_c(x)\downarrow$ means that it eventually returns a value.

Assume a computable bounded evaluator

$$
E_t(c,x)\in\mathbb N\sqcup\{\bot\},
$$

where $E_t(c,x)=y$ certifies that code $c$ returns $y$ on input $x$ within stage $t$, while $\bot$ means no output has yet been found. We require the standard soundness and completeness properties:

- if $E_t(c,x)=y$, then $\varphi_c(x)=y$;
- if $\varphi_c(x)=y$, then $E_t(c,x)=y$ for some $t$.

Fix $x$. Define a machine $D_x$ with program component $C$ and counter state $\mathbb N$ by

$$
D_x(c,s)=
\begin{cases}
\mathsf{halt}, & E_s(c,x)\ne\bot,\\
(c,s+1), & E_s(c,x)=\bot.
\end{cases}
$$

Although the model permits changing $c$, this particular transition preserves it. Thus the construction belongs to the self-modifying class while demonstrating that undecidability already occurs in a restricted subclass.

### 4.2. Finite runs

**Lemma 4.1 (Bounded-Run Characterization).** For $c\in C$ and $s,N\in\mathbb N$, the run of $D_x$ from $(c,s)$ has halted by depth $N$ if and only if

$$
\exists i\in\mathbb N\quad i<N\quad\text{and}\quad E_{s+i}(c,x)\ne\bot.
$$

**Proof sketch.** Induct on $N$. For $N=0$, neither side holds. For $N+1$, split according to $E_s(c,x)$. If it succeeds, choose $i=0$. If it fails, the first transition advances to $(c,s+1)$; apply the induction hypothesis and translate an offset $i$ for the remaining run to $i+1$ for the original run. The converse reverses the same cases. $\square$

**Theorem 4.2 (Universal-Monitor Equivalence).** For every $c\in C$,

$$
D_x\text{ halts from }(c,0)\quad\Longleftrightarrow\quad \varphi_c(x)\downarrow.
$$

**Proof sketch.** If $D_x$ halts, Lemma 4.1 gives a stage $i$ with a successful bounded evaluation, and soundness yields $\varphi_c(x)\downarrow$. Conversely, if $\varphi_c(x)$ returns, completeness supplies a successful stage $t$; the monitor halts within $t+1$ transitions. $\square$

### 4.3. Decidability and semidecidability

A predicate $Q$ on codes is **decidable** if a total computable Boolean function returns true exactly on codes satisfying $Q$. It is **recursively enumerable**, or **semidecidable**, if some partial computable procedure halts exactly on the codes satisfying $Q$.

**Theorem 4.3 (Undecidability of Self-Modifying Termination).** For every fixed input $x$, no computable predicate decides whether $D_x$ halts from $(c,0)$ for arbitrary $c$.

**Proof sketch.** By Theorem 4.2, such a predicate would decide whether $\varphi_c(x)$ is defined. The universal halting predicate at a fixed input is undecidable by diagonalization: if $H(c)$ decided whether $\varphi_c(x)$ halts, universality and effective parameterization allow construction of a code whose behavior contradicts the verdict applied to its own associated code. In table form, $H$ would supply the forbidden total diagonal described by Theorem 2.5. $\square$

**Corollary 4.4 (Undecidability After Standard Simulation).** No computable predicate decides whether $\widehat D_x$ halts from $(c,0)$.

**Proof sketch.** Corollary 3.4 identifies this predicate with that of Theorem 4.3. $\square$

**Theorem 4.5 (One-Sided Enumerability).** The set

$$
K_x=\{c\in C:D_x\text{ halts from }(c,0)\}
$$

is recursively enumerable, but its complement $C\setminus K_x$ is not recursively enumerable.

**Proof sketch.** To semidecide $K_x$, run $D_x$ and accept when it halts; a finite successful run is a certificate. If both $K_x$ and its complement were recursively enumerable, dovetailing their semidecision procedures would decide membership: exactly one eventually accepts. That contradicts Theorem 4.3. $\square$

This asymmetry distinguishes safety evidence from liveness claims. A finite trace can witness termination, but universal nontermination has no general finite certification process.

## 5. Behavioral fixed points of program rewriting

Let $M:C\to C$ be a total computable program transformer. Equality of codes is syntactic; equality of the induced partial functions is behavioral.

**Theorem 5.1 (Behavioral Fixed Point).** For every computable transformer $M:C\to C$, there exists $c\in C$ such that

$$
\varphi_{M(c)}=\varphi_c
$$

as partial functions.

**Proof sketch.** This is the recursion theorem. Universality provides a program template that receives a description, computes the code obtained by substituting that description into itself, applies $M$ to the resulting code, and executes the transformed program. The parameterization theorem compiles the template together with its own description into a code $c$. Unfolding the construction shows that executing $c$ is behaviorally identical to executing $M(c)$. $\square$

The theorem does not imply textual identity $M(c)=c$. It says no computable rewriter can alter the semantics of every code in a universal system. The identity transformer is an immediate, nonvacuous example, but the theorem applies equally to complicated computable rewrites.

Combined with Theorem 4.3, it gives two sides of diagonal self-reference. Fixed-point-free Boolean negation obstructs a universal predictor, while effective self-reference guarantees semantic fixed points for every computable code transformation.

## 6. Finite memory as algebraic quotienting

### 6.1. Experience streams and compositional memory

Let $\Sigma$ be a nonempty alphabet. The set $\Sigma^*$ of finite words, equipped with concatenation and empty word $\varepsilon$, is the free monoid on $\Sigma$. Let $(R,\cdot,1_R)$ be a representation monoid.

**Definition 6.1 (Compositional Memory).** A compositional memory is a monoid homomorphism

$$
m:\Sigma^*\longrightarrow R,
$$

so $m(uv)=m(u)m(v)$ and $m(\varepsilon)=1_R$.

This abstraction covers finite automata, rolling summaries, event-log aggregation, and filters whose summary of a concatenated stream is the product of the summaries.

**Definition 6.2 (Erased Streams).** The erased language of $m$ is

$$
\ker(m)=\{u\in\Sigma^*:m(u)=1_R\}.
$$

**Definition 6.3 (Observational Indistinguishability).** For $u,v\in\Sigma^*$, define

$$
u\sim_m v\quad\Longleftrightarrow\quad m(u)=m(v).
$$

The relation $\sim_m$ is a monoid congruence: it is an equivalence relation compatible with concatenation.

### 6.2. Forced collisions

**Theorem 6.4 (Finite Memory Is Lossy).** If $\Sigma$ is nonempty and $R$ is finite, then every compositional memory $m:\Sigma^*\to R$ identifies two distinct streams. Explicitly, there exist $u,v\in\Sigma^*$ such that

$$
u\ne v\qquad\text{and}\qquad m(u)=m(v).
$$

**Proof sketch.** Choose $a\in\Sigma$. The words $\varepsilon,a,a^2,a^3,\ldots$ are pairwise distinct, so $\Sigma^*$ is infinite. No function from an infinite set to a finite set is injective. Therefore $m$ has a collision. $\square$

**Corollary 6.5 (Nontrivial Indistinguishability).** Under the same hypotheses, the congruence $\sim_m$ has an equivalence class containing at least two distinct streams.

This is a structural pigeonhole principle. It does not depend on how cleverly the finite memory is designed.

### 6.3. Erasure and observable quotient

**Lemma 6.6 (Erased Streams Form a Submonoid).** The empty stream belongs to $\ker(m)$, and if $u,v\in\ker(m)$, then $uv\in\ker(m)$.

**Proof sketch.** Since $m$ is a homomorphism, $m(\varepsilon)=1_R$. If $m(u)=m(v)=1_R$, then $m(uv)=m(u)m(v)=1_R$. $\square$

Let $\Sigma^*/\!\sim_m$ be the set of equivalence classes under $\sim_m$, with multiplication $[u][v]=[uv]$. Compatibility of $\sim_m$ with concatenation makes this well defined. Let $\operatorname{im}(m)=\{m(u):u\in\Sigma^*\}$.

**Theorem 6.7 (Observable-Quotient Isomorphism).** There is a canonical monoid isomorphism

$$
\Sigma^*/\!\sim_m\ \cong\ \operatorname{im}(m)
$$

given by $[u]\mapsto m(u)$.

**Proof sketch.** The map is well defined because $u\sim_m v$ means $m(u)=m(v)$. It preserves identity and multiplication by the homomorphism laws. It is surjective onto $\operatorname{im}(m)$ by definition. It is injective because equality $m(u)=m(v)$ is exactly the relation $u\sim_m v$. $\square$

Thus memory is not merely a many-to-one encoding. Its observable algebra is precisely the quotient obtained by declaring observationally equal histories identical.

### 6.4. Targeted forgetting

Let $r:\Sigma\to\{0,1\}$ mark symbols for retention. Define $F_r:\Sigma^*\to\Sigma^*$ on generators by

$$
F_r(a)=
\begin{cases}
a,&r(a)=1,\\
\varepsilon,&r(a)=0,
\end{cases}
$$

and extend multiplicatively to words. Operationally, $F_r$ deletes every unretained symbol and preserves the order of retained symbols.

**Lemma 6.8 (Forgotten Generators Are Erased).** If $r(a)=0$, then $a\in\ker(F_r)$.

**Proof sketch.** By definition, $F_r(a)=\varepsilon$, the identity of $\Sigma^*$. $\square$

Let $q:\Sigma^*\to\Sigma^*/\!\sim_{F_r}$ be the quotient map.

**Theorem 6.9 (Universal Property of Targeted Forgetting).** Let $S$ be any monoid and let $g:\Sigma^*\to S$ be a monoid homomorphism. Suppose

$$
F_r(u)=F_r(v)\quad\Longrightarrow\quad g(u)=g(v)
$$

for all $u,v\in\Sigma^*$. Then there exists a unique monoid homomorphism

$$
\bar g:\Sigma^*/\!\sim_{F_r}\longrightarrow S
$$

such that $\bar g\circ q=g$.

**Proof sketch.** Define $\bar g([u])=g(u)$. The hypothesis makes this independent of the representative. The homomorphism laws descend from those of $g$. Every class is $q(u)$ for some $u$, so the equation $\bar g\circ q=g$ determines $\bar g$ uniquely. $\square$

**Corollary 6.10 (Targeted-Forgetting Quotient).** The quotient $\Sigma^*/\!\sim_{F_r}$ is canonically isomorphic to $\operatorname{im}(F_r)$, the submonoid of words containing only retained symbols.

This is Theorem 6.7 applied to $F_r$. It says that deletion yields exactly the free stream algebra visible after the selected symbols disappear.

**Theorem 6.11 (Finite-Memory Connector).** If $\Sigma$ is nonempty, $R$ is finite, and $m:\Sigma^*\to R$ is compositional, then all three statements hold simultaneously:

1. distinct streams $u\ne v$ exist with $m(u)=m(v)$;
2. $\ker(m)$ contains $\varepsilon$ and is closed under concatenation;
3. $\Sigma^*/\!\sim_m$ is isomorphic to $\operatorname{im}(m)$.

**Proof sketch.** Combine Theorem 6.4, Lemma 6.6, and Theorem 6.7. $\square$

## 7. Algorithms and numerical demonstrations

The undecidability result prohibits an unbounded total predictor, not bounded experiments. Three finite algorithms illustrate the theory.

### 7.1. Bounded universal monitoring

Given a finite simulation routine, a code $c$, input $x$, and maximum budget $B$, query budgets $0,1,\ldots,B$. Return the first successful stage or report that no halt was observed. If each stage-$t$ simulation costs $O(t)$, restarting at every budget costs $O(B^2)$ time and $O(B)$ space in the worst case. An incremental simulator can reduce this to $O(B)$ transition work. A negative bounded outcome is not a proof of nontermination.

### 7.2. Step-for-step simulation

Given a finite self-modifying transition table, evolve $(p,s)$ directly and also evolve the same pair as ordinary state under a fixed interpreter. Comparing traces demonstrates Theorem 3.3. For $N$ steps, the method uses $O(N)$ transitions and $O(N)$ storage if full traces are retained, or $O(1)$ auxiliary storage if only final states are compared.

### 7.3. Collision and quotient enumeration

For a finite alphabet and a finite memory map, enumerate words up to length $L$, group them by memory value, and report collisions and equivalence classes. There are

$$
1+|\Sigma|+\cdots+|\Sigma|^L
$$

words, so exhaustive enumeration is exponential in $L$. The growth visually demonstrates why fixed finite memory must collide. For targeted forgetting, classes can be represented directly by filtered words.

## 8. Applications

### 8.1. Malware analysis

Polymorphic or self-rewriting malware does not evade computability theory by changing syntax. An interpreter can store changing code as data, so universal termination and semantic-property questions retain their classical undecidability. Practical analyzers must therefore be incomplete, unsound, bounded, or restricted to a decidable language fragment. This conclusion concerns universal guarantees, not the effectiveness of analysis on realistic subclasses.

### 8.2. Runtime adaptation

Dynamic optimization and policy rewriting can be modeled without granting extra computational power. This supports a clean separation between engineering overhead and semantic expressiveness. Quantitative overhead remains a separate question: the state encoding preserves termination but may alter time and space complexity.

### 8.3. Event summaries and privacy filters

A compositional summary of an unbounded event stream into finitely many states necessarily loses distinctions. The quotient theorem describes exactly which distinctions are lost. Targeted forgetting supplies a canonical design for redaction: all downstream observers insensitive to deleted distinctions factor uniquely through the redacted representation.

### 8.4. Security certificates

The recursively enumerable character of halting explains why concrete terminating traces can be checked. The failure of recursive enumerability for universal nonhalting warns against expecting complete finite certificates of perpetual benign behavior. Restricted proof systems may certify selected invariants, but no complete general mechanism covers every universal program.

## 9. Discussion

The results distinguish three notions often conflated in discussions of self-modifying code.

First, **syntactic mutability** concerns whether program text changes during execution. Second, **computational expressiveness** concerns which partial functions can be computed. Third, **predictability** concerns whether semantic behavior can be decided from code. The simulation theorem shows that syntactic mutability does not enlarge universal expressiveness. The halting theorem shows that unchanged expressiveness is already enough to defeat universal prediction.

The fixed-point perspective sharpens the explanation. A termination decider would assign a Boolean property across a universal family of behaviors. Diagonal negation has no fixed point, so the family cannot internalize every such predicate consistently. By contrast, a computable code transformer necessarily has a semantic fixed point because universal programs can internalize their own effective descriptions. The negative and positive fixed-point results are complementary rather than contradictory: one forbids representing every predicate, while the other guarantees self-referential programs inside an effective enumeration.

The memory results concern a different limitation—finite information rather than computability—but share a common theme of identification. A finite representation cannot distinguish all words. The kernel congruence records exactly which histories collapse, while the first isomorphism principle identifies observable states with quotient classes. In program analysis, any finite abstraction similarly merges executions. Such merging can enable decidable analysis, but only by sacrificing distinctions.

Several limitations should be explicit. The monitor establishes undecidability by embedding a universal evaluator; machines with genuinely finite configuration spaces have decidable termination. The simulation theorem is qualitative and supplies no optimal resource bound. Behavioral fixed points assert extensional equality of partial functions, not identical source text. Finally, finite-memory collision alone does not imply a security failure; whether a collision matters depends on the property an observer seeks to preserve.

## 10. Future work

Seven directions arise naturally.

1. **Oracle-relative rewriting.** Add oracle queries and compare termination across successive relative computability degrees.
2. **Resource-sensitive self-modification.** Introduce explicit cost semantics and bound the overhead of interpreting changing code as data.
3. **Instruction-level universal systems.** Replace the abstract universal evaluator with concrete bytecode and prove compiler preservation of behavior.
4. **Bounded rewriting.** Track actual program changes and classify bounded subclasses that remain universal or become decidable.
5. **Semantic malware properties.** Extend the halting construction to a Rice theorem for extensional properties of self-modifying traces.
6. **Topological classification.** Equip behavior with a prefix topology, characterize halting as effectively open, and analyze perpetual execution.
7. **Explicit quines.** Strengthen behavioral fixed points to source-level constructions whose rewritten fixed points reproduce their own code.

## 11. Conclusion

Self-modifying computation admits an exact ordinary simulation: store the current program in the state. This removes any illusion of supernatural computational power while transferring the full force of classical undecidability. An explicit bounded-evaluation monitor halts exactly on the universal halting set. Its halting behavior is semidecidable but undecidable, and its nonhalting behavior is not semidecidable. Lawvere’s theorem and Cantor’s theorem expose the shared diagonal core, while the recursion theorem guarantees that every computable rewrite has a behavioral fixed point.

Finite observation imposes a parallel boundary. A finite compositional memory of unbounded streams must merge distinct histories; erased histories form a submonoid; and observable memory is exactly the quotient by indistinguishability. Targeted forgetting realizes this quotient with a universal factorization property. Universal prediction fails because self-reference defeats total Boolean classification. Perfect finite memory fails because infinite histories exceed finite representation. In both cases, useful systems emerge not by denying the boundary, but by choosing explicit restrictions and understanding precisely what they preserve.
