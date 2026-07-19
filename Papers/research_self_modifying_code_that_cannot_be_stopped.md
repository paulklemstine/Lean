# Self-Modifying Computation: Exact Simulation, Halting Equivalence, and the Limits of Semantic Monitoring

**Aristotle**  
**July 19, 2026**

## Abstract

Self-modifying programs can replace their own instructions during execution, suggesting a model stronger than ordinary fixed-program computation. This paper isolates the computability-theoretic effect of that capability. A self-modifying configuration is represented by a current program and a current data state, and each transition may update both. Moving the mutable program into the state of a fixed interpreter yields an exact, step-preserving simulation. Conversely, every fixed program is a degenerate self-modifying machine with an immutable singleton program component. The two halting problems are therefore mutually reducible, so effective self-modification is not strictly harder than classical computation in computability degree.

The equivalence transfers classical negative results without weakening them. No total computable Boolean predictor decides termination for all program codes on a fixed input. Perpetual execution is exactly the complement of eventual halting, so an exact total perpetual-safety monitor would decide halting. Moreover, perpetual execution at a fixed input is not recursively enumerable: finite evidence can witness termination but cannot provide a complete certificate system for running forever. Finally, a Rice-style argument excludes exact computable classifiers for every nontrivial extensional property of partial computable behavior, covering semantic malware detection and unrestricted behavioral alignment tests. Bounded simulation remains decidable, clarifying the boundary between feasible finite-horizon analysis and impossible universal prediction. The results show that rewriting changes operational presentation and may change resource costs, but does not create a higher degree of undecidability by itself.

## 1. Introduction

Self-modifying computation appears in polymorphic malware, dynamic binary translation, just-in-time compilation, reflective languages, genetic programming, and adaptive agents. Its characteristic operation is not merely updating ordinary data but changing the program that determines subsequent updates. This invites two different claims that must be separated.

The first claim is that termination of arbitrary self-modifying programs is undecidable. This is correct for a universal effective model. The second is that self-modifying termination is *strictly harder* than the classical halting problem. Under the ordinary effectiveness assumptions studied here, this is false. A fixed interpreter can store the changing program as data and simulate each rewrite exactly. The familiar slogan “code is data” is therefore not merely an implementation observation; it determines the computability degree of the model.

This distinction is especially important for security and alignment. A semantic detector that claims to decide whether arbitrary code eventually exhibits malicious behavior is not blocked specifically by syntactic mutation. It is blocked by a broader theorem about nontrivial properties of computed behavior. Likewise, a monitor that claims to accept exactly those adaptive systems that remain perpetually safe would decide the complement of halting. Rewriting can make finite analysis difficult in practice, but universal exactness was already impossible.

The paper develops these points from first principles. Section 2 defines self-modifying machines, fixed-state machines, halting, reductions, extensional properties, and recursive enumerability. Section 3 gives the exact simulation in both directions and proves mutual reducibility. Section 4 establishes universal termination unpredictability. Section 5 studies perpetual-safety monitoring and the stronger nonenumerability obstruction. Section 6 gives the semantic classification theorem and applies it to malware and alignment. Section 7 presents executable finite demonstrations and algorithms. Sections 8–10 discuss applications, limitations, and further questions.

## 2. Definitions and computational setting

### 2.1 Self-modifying machines

Let $P$ be a countable set of program representations and $S$ a countable set of ordinary machine states. A **self-modifying configuration** is a pair

$$
(p,s)\in P\times S.
$$

A deterministic **self-modifying machine** is an effective partial transition map

$$
\delta:P\times S\rightharpoonup P\times S.
$$

If $\delta(p,s)$ is undefined, the machine has halted at $(p,s)$. If

$$
\delta(p,s)=(p',s'),
$$

then one execution step changes the current program from $p$ to $p'$ and the ordinary state from $s$ to $s'$. Nothing requires $p'=p$.

Define the finite run recursively. For a starting configuration $c=(p,s)$, let

$$
\operatorname{run}_\delta(c,0)=c.
$$

If $\operatorname{run}_\delta(c,n)=c_n$ and $\delta(c_n)=c_{n+1}$ is defined, then

$$
\operatorname{run}_\delta(c,n+1)=c_{n+1}.
$$

If a required transition is undefined, later stages are undefined. The **halting predicate** is

$$
\operatorname{Halts}_\delta(c)
\quad\Longleftrightarrow\quad
\exists n\in\mathbb N\text{ such that the next transition after stage $n$ is undefined}.
$$

Equivalent indexing conventions do not affect any result.

### 2.2 Fixed-program machines

A **fixed-program machine** on a state set $X$ is an effective partial transition

$$
\tau:X\rightharpoonup X.
$$

Its transition rule $\tau$ does not change during execution. The state $x\in X$ may nevertheless contain arbitrary encoded objects, including program text. Its run and halting predicate are defined exactly as above.

The distinction between the models is therefore organizational. In the self-modifying presentation, the configuration has designated program and state components. In the fixed presentation, both may be stored in a single state and manipulated by an immutable interpreter.

### 2.3 Effective reductions and strict hardness

For predicates $A$ on a countable set $X$ and $B$ on a countable set $Y$, a **many-one reduction** from $A$ to $B$ is a total computable map $f:X\to Y$ such that

$$
A(x)\quad\Longleftrightarrow\quad B(f(x))
$$

for every $x\in X$. We write $A\le_m B$. Predicates are **many-one equivalent** when each reduces to the other.

We say that $A$ is **strictly harder** than $B$ when

$$
B\le_m A
\quad\text{and}\quad
A\not\le_m B.
$$

This definition concerns computability degree, not time, space, description length, or practical difficulty.

### 2.4 Partial computable behavior and extensional properties

A program code $c$ denotes a partial computable function

$$
\varphi_c:\mathbb N\rightharpoonup\mathbb N.
$$

A set $\mathcal C$ of partial functions is an **extensional behavioral property**: membership depends on the function computed, rather than on the syntax of a code. It is **nontrivial among partial computable functions** if there exist partial computable functions $f$ and $g$ such that

$$
f\in\mathcal C
\quad\text{and}\quad
g\notin\mathcal C.
$$

A Boolean classifier for $\mathcal C$ would be a total computable function $D$ satisfying

$$
D(c)=1
\quad\Longleftrightarrow\quad
\varphi_c\in\mathcal C.
$$

### 2.5 Recursive enumerability

A predicate is **recursively enumerable** if there is an effective procedure that eventually accepts exactly its positive instances, or equivalently if its positive instances can be effectively listed. Halting is recursively enumerable: a dovetailing simulator eventually discovers every halting computation. Its complement need not be recursively enumerable.

## 3. Exact simulation and degree equivalence

The principal structural observation is that the mutable program can be internalized as ordinary data.

**Theorem 1 (Exact fixed-state simulation).** Let $\delta:P\times S\rightharpoonup P\times S$ be any effective self-modifying transition. There exists a fixed-program machine on the state set $P\times S$ whose transition is

$$
\tau(p,s)=\delta(p,s).
$$

For every initial configuration $c$ and every $n\in\mathbb N$, the fixed and self-modifying runs agree at stage $n$ whenever that stage exists. Consequently,

$$
\operatorname{Halts}_\delta(c)
\quad\Longleftrightarrow\quad
\operatorname{Halts}_\tau(c).
$$

**Proof sketch.** The simulator’s program is a fixed interpreter for $\delta$; its data state stores the pair $(p,s)$. At one step, the interpreter decodes the stored pair, computes $\delta(p,s)$, and stores the result. The stage-zero states coincide. If the states coincide at stage $n$, both machines apply the same effective transition and therefore either halt together or reach the same next pair. Induction on $n$ proves step-for-step equality, and existence of a finite halting stage is preserved in both directions. $\square$

This construction is uniform and does not bound the number, size, or content of rewrites. A newly generated program is simply the next value of the stored program component.

**Lemma 2 (Embedding fixed computation).** Every fixed-program machine $\tau:X\rightharpoonup X$ can be represented as a self-modifying machine with program set $P=\{\ast\}$ and state set $S=X$, using

$$
\delta(\ast,x)=(\ast,\tau(x))
$$

whenever $\tau(x)$ is defined, and halting otherwise.

**Proof sketch.** The sole program value $\ast$ cannot change. Each self-modifying step performs exactly one transition of $\tau$ on the state component. Induction again gives equality of finite runs and equivalence of halting. $\square$

**Theorem 3 (Mutual reducibility of halting).** The halting predicate of every effective self-modifying machine reduces to the halting predicate of its fixed-state simulation. Conversely, the latter reduces to the halting predicate of a self-modifying machine with a singleton program component. Hence self-modifying halting is not strictly harder than its fixed-program counterpart.

**Proof sketch.** For the forward reduction, map $(p,s)$ to the identical pair used as simulator state. Theorem 1 supplies equivalence. For the reverse reduction, map simulator state $(p,s)$ to $(\ast,(p,s))$ in the singleton-program embedding of Lemma 2. Both maps are computable, and both preserve and reflect halting. Strict hardness would require the absence of the forward reduction, contradicting its explicit construction. $\square$

**Corollary 4 (No computability-degree hierarchy from rewriting alone).** Allowing an unbounded effective number of code rewrites does not, by itself, produce a halting predicate of higher computability degree than ordinary halting.

This corollary is extensional. It permits substantial differences in simulation overhead. Encoding and interpreting mutable programs may increase running time or storage, and direct rewriting may offer compression or specialization. Such quantitative distinctions require a resource-sensitive theory.

## 4. Universal termination prediction

Fix a universal effective numbering $c\mapsto\varphi_c$ of partial computable functions. For an input $x$, suppose a total computable Boolean function $D_x$ satisfies

$$
D_x(c)=1
\quad\Longleftrightarrow\quad
\varphi_c(x)\text{ is defined}.
$$

Classical diagonalization excludes such a function.

**Theorem 5 (No general termination predictor).** For every fixed input $x\in\mathbb N$, there is no total computable Boolean function $D_x$ that decides whether $\varphi_c(x)$ halts for every code $c$.

**Proof sketch.** If $D_x$ existed, standard parameterization and universal interpretation would yield a total halting decider for arbitrary program-input pairs: transform $(c,y)$ effectively into code for a program that ignores its own input and simulates $c$ on $y$, then query $D_x$. A diagonal program can then halt exactly when the alleged decider predicts that it does not halt on its own code. Evaluating the prediction on that diagonal code produces a contradiction in either Boolean case. $\square$

**Corollary 6 (No universal self-modifying termination predictor).** For any universal self-modifying model capable of representing the singleton-program embeddings above, no total computable classifier decides halting for all initial configurations.

**Proof sketch.** Such a classifier, composed with the computable embedding of ordinary programs into self-modifying configurations, would contradict Theorem 5. $\square$

The theorem concerns unbounded termination. The bounded version is decidable.

**Proposition 7 (Bounded halting is decidable).** Given an effective self-modifying transition $\delta$, a configuration $c$, and a bound $N$, there is an algorithm deciding whether the run halts within at most $N$ transitions.

**Proof sketch.** Simulate at most $N$ transitions. Accept if an undefined transition occurs and reject if all $N$ transitions are completed. The loop is finite, so the algorithm always terminates. $\square$

If one transition takes time $T_\delta$ and the largest stored configuration uses space $M$, this direct algorithm takes $O(NT_\delta)$ time and $O(M)$ working space, apart from output logging.

## 5. Perpetual safety and finite evidence

Define the **perpetual-execution predicate** by

$$
\operatorname{NeverHalts}_\delta(c)
\quad\Longleftrightarrow\quad
\forall n\in\mathbb N,\ \operatorname{run}_\delta(c,n)\text{ is defined}.
$$

This may model a narrow safety requirement in which an execution is considered safe precisely while it continues. More general temporal safety properties can often encode this one.

**Lemma 8 (Complement identity).** For every configuration $c$,

$$
\operatorname{NeverHalts}_\delta(c)
\quad\Longleftrightarrow\quad
\neg\operatorname{Halts}_\delta(c).
$$

**Proof sketch.** Halting means that an undefined stage is reached after finitely many transitions. Negating this existential statement says that no finite stage is undefined, which is exactly the universal definition of perpetual execution. $\square$

**Theorem 9 (No exact perpetual-safety monitor).** Let $\delta$ be a self-modifying machine whose fixed-state simulation has undecidable halting. There is no total computable Boolean monitor $M$ satisfying

$$
M(c)=1
\quad\Longleftrightarrow\quad
\operatorname{NeverHalts}_\delta(c)
$$

for every configuration $c$.

**Proof sketch.** Assume $M$ exists. Define $H(c)=1-M(c)$. By Lemma 8, $H(c)=1$ exactly when $c$ halts. Composing $H$ with the identity simulation encoding decides halting for the fixed-state simulator, contradicting the hypothesis. $\square$

Undecidability alone leaves open whether perpetual executions could at least be enumerated by a procedure that sometimes runs forever on negative cases. They cannot in a universal model.

**Theorem 10 (Perpetual execution is not recursively enumerable).** For every fixed input $x$, the set

$$
\{c:\varphi_c(x)\text{ is undefined}\}
$$

is not recursively enumerable.

**Proof sketch.** The halting set at $x$ is recursively enumerable by simulation. If its complement were also recursively enumerable, run the two recognizers in dovetailing fashion. Exactly one must eventually accept, producing a total halting decider and contradicting Theorem 5. $\square$

**Corollary 11 (No complete finite-certificate discipline).** In a universal model, there is no effective finite-certificate system that is both sound and complete for perpetual execution, where certificate validity is decidable.

**Proof sketch.** Enumerate all pairs of codes and finite certificates and output each code having a valid certificate. Soundness and completeness would enumerate exactly the perpetually executing codes, contradicting Theorem 10. $\square$

The corollary permits sound but incomplete methods. Type systems, ranking arguments for selected liveness properties, invariants, proof-carrying updates, and restricted languages may certify broad classes while necessarily omitting some valid cases.

## 6. Nontrivial semantic properties

Termination is only one behavioral property. The more general obstruction is extensional.

**Theorem 12 (Semantic classification impossibility).** Let $\mathcal C$ be a set of partial functions $\mathbb N\rightharpoonup\mathbb N$. Suppose there exist partial computable functions $f\in\mathcal C$ and $g\notin\mathcal C$. Then no total computable classifier $D$ satisfies

$$
D(c)=1
\quad\Longleftrightarrow\quad
\varphi_c\in\mathcal C
$$

for every program code $c$.

**Proof sketch.** Choose computable behaviors on opposite sides of $\mathcal C$. Given a program-input pair whose halting is unknown, effectively construct a program whose extensional behavior switches between suitable reference behavior and the other side according to whether the unknown computation halts. A hypothetical exact classifier for $\mathcal C$ would then decide the original halting question. The construction is a standard Rice-style reduction and uses only extensionality and nontriviality. $\square$

Both hypotheses are necessary. A property that contains all partial computable functions, or none, is decided by a constant classifier. A syntactic property such as “the source contains a designated byte string” may also be decidable because it is not extensional.

### 6.1 Malware detection

Let $\mathcal M$ denote a behavioral notion of malware, such as “on some input, eventually emits a designated harmful command,” provided membership depends only on partial input-output behavior. If at least one computable behavior is malicious and another is benign, Theorem 12 yields the following.

**Corollary 13 (No exact universal semantic malware detector).** No total computable procedure classifies every program exactly according to $\mathcal M$.

Polymorphism and self-rewriting make signature methods easier to evade, but the corollary is stronger: even perfect access to program text cannot enable an exact classifier for arbitrary universal programs. Practical systems must use syntactic approximations, restricted execution, bounded analysis, probabilistic judgments, or incomplete semantic methods.

### 6.2 Behavioral alignment under self-revision

Let $\mathcal A$ be a nontrivial extensional property representing a desired partial behavior, such as never producing a forbidden observable output. If arbitrary adaptive agents can express universal partial computations, exact classification is impossible.

**Corollary 14 (No exact universal extensional alignment classifier).** If $\mathcal A$ contains one partial computable behavior and excludes another, no total computable algorithm decides for every program whether its complete partial behavior belongs to $\mathcal A$.

This is not a prohibition on all alignment techniques. It identifies which combinations cannot coexist: unrestricted universal programs, a nontrivial extensional criterion, total termination of the evaluator, and exact soundness and completeness. Restricting any one of these dimensions can recover useful guarantees.

## 7. Algorithms and numerical demonstrations

### 7.1 Fixed-interpreter simulation

The exact simulator maintains a pair `(program, state)`. Its fixed loop applies a supplied effective transition to that pair. The algorithm halts exactly when the transition reports no successor.

**Algorithm 1 (Step-preserving fixed-state simulation).**

1. Store the initial pair $(p_0,s_0)$ as the simulator state.
2. Apply the fixed transition interpreter to the stored pair.
3. If there is no successor, report halting.
4. Otherwise replace the stored pair by $(p_1,s_1)$ and repeat.

After $N$ simulated steps, the stored pair is exactly the self-modifying configuration after $N$ steps. The time is $O(NT_\delta)$ and the additional working space is $O(M)$, where $T_\delta$ is transition cost and $M$ bounds the current encoded configuration.

### 7.2 A finite rewriting example

For illustration, let a program be a pair $(a,b)$ of integers and let the state be an integer $x$. A transition updates

$$
x' = x+a,
$$

then rewrites

$$
(a',b')=(b,a+b).
$$

The machine halts once $x$ reaches a chosen threshold. Beginning with $(a,b,x)=(1,1,0)$, the increments are Fibonacci numbers:

$$
1,1,2,3,5,8,\ldots
$$

The fixed simulator stores the triple $(a,b,x)$ and applies the same recurrence. The two traces coincide exactly; only the interpretation of $(a,b)$ as “program” versus “data” differs.

### 7.3 Finite-horizon monitors

A horizon-$N$ monitor can truthfully report one of three outcomes: “halt observed,” “survived $N$ steps,” or “invalid transition.” The second outcome is not a proof of perpetual execution. Increasing $N$ increases evidence without crossing the logical gap between a long finite prefix and an infinite run.

## 8. Applications

### 8.1 Security architecture

The semantic impossibility theorem motivates layered malware defense. Signature checks address decidable syntax. Sandboxes restrict effects. Bounded emulation detects behaviors appearing within a resource budget. Proof-carrying code certifies a selected enumerable fragment. Statistical models trade exactness for empirical coverage. None is an exact total solver for arbitrary nontrivial semantics, and their specifications should not imply otherwise.

### 8.2 Adaptive systems and governance

For a system that proposes self-updates, a conservative gate can require each update to carry a checkable local certificate. Corollary 11 implies that no such effective finite-certificate regime can recognize every safe universal computation. This makes abstention a mathematically necessary outcome for any sound general monitor. Governance mechanisms should distinguish “rejected as unsafe” from “not certified.”

### 8.3 Compiler and runtime design

The equivalence theorem legitimizes fixed-interpreter analysis of mutable-code systems. A semantics can represent code heaps, generated procedures, or policies as explicit state and study one fixed transition relation. This may enlarge states dramatically, but it loses no execution behavior. The representation is therefore suitable for trace comparison, bounded exploration, and resource analysis.

## 9. Discussion and limitations

The principal conclusion is negative only at a specific level. Self-modification does not raise computability degree when each rewrite and transition is effective and finitely representable. The analysis does not cover machines endowed with noncomputable oracles, physically infinite precision, or transition rules that are themselves noneffective. Such additions—not rewriting alone—could alter computability power.

Mutual reducibility also does not imply equal practical complexity. A universal interpreter may introduce substantial overhead, while direct code generation may specialize away interpretation costs. Bounded numbers of rewrites may form strict hierarchies in time, space, communication, or description complexity even though all levels have the same computable functions.

The perpetual-safety model equates safety with nonhalting. Real systems use richer predicates over traces. The result applies directly whenever a richer exact monitor could encode perpetual execution, but each application must establish that reduction. Similarly, the semantic classification theorem concerns extensional properties. Syntactic policies, decidable type disciplines, and restricted domains can remain fully decidable.

Finally, undecidability is a worst-case theorem. It does not quantify error under a probability distribution, average running time, or performance on naturally occurring code. Distributional malware detection and empirical alignment evaluation require additional assumptions and quantitative analysis.

## 10. Future work

Several directions follow from the separation between computability degree and resources.

First, a **resource-bounded rewrite hierarchy** may compare machines permitted at most $k$ and $k+1$ rewrites. The exact simulation theorem rules out a hierarchy of computable functions but leaves open strict improvements in optimal time, space, communication, or description overhead.

Second, **oracle-relative self-modification** should preserve the same pattern: with oracle $A$, mutable code can be stored as state, while oracle access remains the source of additional power. The expected halting degree is the jump $A'$, not a further jump caused by rewriting.

Third, a **quantitative monitor tradeoff** should measure the unavoidable blind spots of total sound monitors. Nonenumerability suggests not merely isolated missed cases but infinite structured families of safe configurations that cannot be certified, potentially even under bounded rewrite rates.

Fourth, **distributional semantic detection** can replace worst-case exactness with error probabilities. Under computable full-support distributions, one may ask whether entropy or complexity conditions force universal positive lower bounds on false positives or false negatives.

Fifth, **proof-carrying alignment** motivates characterizing large recursively enumerable fragments of configurations admitting finite certificates that every reachable rewrite preserves a chosen safety property. No complete universal fragment exists, but maximal fragments under a fixed certificate logic may still be mathematically and practically valuable.

## 11. Conclusion

Effective self-modification is computationally dramatic but computability-theoretically conservative. A fixed interpreter stores mutable code alongside ordinary state and reproduces every step. Ordinary computation embeds back as the special case of an unchanging singleton program. Their halting predicates are mutually reducible, refuting strict hardness from rewriting alone.

The classical barriers nevertheless remain intact. Universal termination prediction is impossible. Perpetual execution is the complement of halting and admits neither an exact total monitor nor a complete effective enumeration. Every nontrivial extensional property of partial computable behavior defeats exact total classification, encompassing semantic malware detection and unrestricted behavioral alignment judgments.

These limits define a constructive design boundary. Bounded simulation, restricted languages, conservative certificates, syntactic controls, and probabilistic methods remain available. What must be abandoned is the demand for a universal algorithm that is simultaneously total, exact, and complete about the unbounded semantic future of arbitrary code.