# Substrate-Invariant Computational Complexity: Simulations, Witness Classes, Reductions, and Jump Hierarchies

**Aristotle**  
**19 July 2026**

## Abstract

We develop an architecture-neutral theory of bounded computation. A machine model consists only of programs, an acceptance relation, and a natural-valued cost. A simulation translates programs while preserving acceptance and controlling cost by a monotone overhead function. We prove that simulations compose and transport every bounded decision class, with the bound transformed by the declared overhead. Exact mutual simulations identify all bounded classes and every indexed complexity hierarchy level by level; consequently, adjacent hierarchy separations are substrate-invariant. We extend the framework to existential witness verification and prove that equality between deterministic and witness-based classes is invariant under exact changes of both decision and verifier substrates. We also isolate the condition under which extensional many-one reductions transfer resource bounds: the model must support semantic precomposition without additional cost. Finally, we define abstract jump hierarchies, prove successor separation and non-stabilization, and show that the complete jump structure survives exact substrate equivalence. These results do not decide P versus NP or construct a jump for every stronger model. Rather, they establish that, once semantic and resource equivalence is supplied, such questions concern the structure of computation rather than the material architecture implementing it.

## 1. Introduction

Computational complexity is commonly presented through particular machines: Turing tapes, random-access memory, Boolean circuits, distributed processors, or quantum devices. Such presentations risk mixing two questions. The first is semantic: which inputs does a program accept? The second is quantitative: what resource does acceptance consume? A substrate-independent account should retain precisely these ingredients while discarding incidental details of instruction sets and physical realization.

This distinction matters for comparing radically heterogeneous technologies. Two civilizations might implement computation in electronic gates and chemical reaction networks. They need not share an elementary operation, a clock rate, or even a familiar notion of hardware. Nevertheless, if each can compile the other's programs while preserving acceptance and controlling a common resource, then rigorous comparisons become possible.

The principal thesis is conditional and exact: complexity is invariant under resource-respecting semantic equivalence. General simulations transport a class only after transforming its budget by the simulation overhead. Exact mutual simulations, whose overhead is the identity, preserve every fixed bounded class. This immediately propagates to indexed hierarchies, hierarchy separations, existential witness classes, and the abstract deterministic-versus-witness equality that has the logical form of P versus NP.

The exact condition is stronger than the polynomial invariance normally used in classical complexity theory. That strength is useful: it makes the transport mechanism transparent and prevents an unjustified claim that arbitrary compilation preserves fixed budgets. It also identifies the natural extension—replace exact equality by a family of admissible overhead rescalings under which a chosen asymptotic class is closed.

A second theme concerns stronger-than-standard computation. Increased base power does not by itself eliminate hierarchy. Given a jump operation whose successor escapes the current resource tier, each successor witnesses a strict separation. Exact substrate equivalence preserves both membership at each tier and escape from it. Thus a hypercomputational civilization may begin above ordinary computability while still confronting a structurally analogous sequence of barriers.

The paper proceeds from definitions to transport theorems, witness computation, reductions, and jump hierarchies. Every result is extensional: languages remain sets of inputs, independent of the programs that decide them.

## 2. Machine models and bounded language classes

Let $X$ be an arbitrary set of inputs.

**Definition 2.1 (Machine model).** A machine model $M$ over $X$ consists of:

1. a set $\mathrm{Prog}_M$ of programs;
2. an acceptance predicate $\mathrm{Acc}_M(p,x)$ for $p\in\mathrm{Prog}_M$ and $x\in X$;
3. a cost function $c_M:\mathrm{Prog}_M\times X\to\mathbb N$.

No effectiveness, determinism, or physical interpretation is imposed beyond these data. The generality allows the cost to represent time, memory, communication, energy, or an abstract resource rank.

**Definition 2.2 (Decision).** A program $p\in\mathrm{Prog}_M$ decides a language $L\subseteq X$ if

$$
\forall x\in X,
\qquad \mathrm{Acc}_M(p,x)\Longleftrightarrow x\in L.
$$

**Definition 2.3 (Pointwise bounded execution).** For a budget $b:X\to\mathbb N$, program $p$ runs within $b$ when

$$
\forall x\in X,
\qquad c_M(p,x)\le b(x).
$$

**Definition 2.4 (Bounded class).** The language $L$ belongs to $\mathcal C_M(b)$ if some program $p$ decides $L$ and runs within $b$.

Pointwise bounds avoid committing to an input-length encoding. Standard size-based classes can be recovered by taking $b(x)=g(|x|)$ for a chosen size map and growth function $g$.

## 3. Simulations and the transport calculus

**Definition 3.1 (Simulation).** A simulation $S:M\to N$ between models over the same input set consists of a translation

$$
T_S:\mathrm{Prog}_M\to\mathrm{Prog}_N
$$

and a monotone overhead function $h_S:\mathbb N\to\mathbb N$ satisfying, for every program $p$ and input $x$,

$$
\mathrm{Acc}_N(T_S(p),x)
\Longleftrightarrow
\mathrm{Acc}_M(p,x)
$$

and

$$
c_N(T_S(p),x)\le h_S(c_M(p,x)).
$$

Monotonicity means $a\le b$ implies $h_S(a)\le h_S(b)$.

**Proposition 3.2 (Identity simulation).** Every model simulates itself by the identity translation and identity overhead.

*Proof sketch.* Take $T(p)=p$ and $h(n)=n$. Acceptance is unchanged and the cost inequality is equality.

**Theorem 3.3 (Composition of simulations).** If $S_1:M\to N$ has overhead $h_1$ and $S_2:N\to K$ has overhead $h_2$, then there is a simulation $S_2\circ S_1:M\to K$ with program translation $T_{S_2}\circ T_{S_1}$ and overhead $h_2\circ h_1$.

*Proof sketch.* Acceptance equivalence is transitive. For costs,

$$
\begin{aligned}
c_K(T_{S_2}(T_{S_1}(p)),x)
&\le h_2(c_N(T_{S_1}(p),x))\\
&\le h_2(h_1(c_M(p,x))),
\end{aligned}
$$

where the second inequality uses monotonicity of $h_2$. The composition of monotone functions is monotone.

**Theorem 3.4 (Bounded-Class Transport).** Let $S:M\to N$ be a simulation with overhead $h$. For every budget $b$ and language $L$,

$$
L\in\mathcal C_M(b)
\quad\Longrightarrow\quad
L\in\mathcal C_N(h\circ b).
$$

*Proof sketch.* Choose an $M$-program $p$ deciding $L$ within $b$. Semantic preservation makes $T_S(p)$ decide the same language. Moreover,

$$
c_N(T_S(p),x)
\le h(c_M(p,x))
\le h(b(x)),
$$

with the last step supplied by monotonicity.

The transformed budget is essential. Without restrictions on $h$, membership in $\mathcal C_M(b)$ need not imply membership in $\mathcal C_N(b)$. The theorem therefore gives both a positive invariance principle and the precise boundary of that principle.

**Definition 3.5 (Exact simulation).** A simulation is exact if $h(n)=n$ for all $n\in\mathbb N$.

**Corollary 3.6 (Exact class inclusion).** An exact simulation $M\to N$ implies

$$
\mathcal C_M(b)\subseteq\mathcal C_N(b)
$$

for every budget $b$.

**Definition 3.7 (Resource equivalence).** Models $M$ and $N$ are resource-equivalent if simulations exist in both directions. They are exactly resource-equivalent if both simulations are exact.

**Theorem 3.8 (Exact Substrate Invariance).** If $M$ and $N$ are exactly resource-equivalent, then for every budget $b$ and language $L$,

$$
L\in\mathcal C_M(b)
\Longleftrightarrow
L\in\mathcal C_N(b).
$$

*Proof sketch.* Apply exact class transport in the forward direction for one implication and in the backward direction for the other.

This theorem is the basic substrate-independence result. It does not assert that arbitrary substrates are equivalent; it states the complete consequence of an exact semantic and resource equivalence once established.

## 4. Indexed hierarchies and separation invariance

Let $B:\mathbb N\times X\to\mathbb N$ be an indexed family of budgets, and write $b_n(x)=B(n,x)$.

**Definition 4.1 (Complexity hierarchy).** The hierarchy generated by $M$ and $B$ is the sequence

$$
\mathcal H_M(n)=\{L\subseteq X:L\in\mathcal C_M(b_n)\}.
$$

**Theorem 4.2 (Levelwise Hierarchy Invariance).** If $M$ and $N$ are exactly resource-equivalent, then

$$
\forall n\in\mathbb N,
\qquad \mathcal H_M(n)=\mathcal H_N(n).
$$

Equivalently, the two hierarchy-valued functions are equal.

*Proof sketch.* Fix $n$ and apply Theorem 3.8 with budget $b_n$. Extensional equality follows because every language has identical membership on both sides.

**Theorem 4.3 (Adjacent-Separation Invariance).** Under the same hypotheses, for every $n$,

$$
\begin{aligned}
&\exists L\subseteq X,
\quad L\in\mathcal C_M(b_{n+1})
\text{ and }L\notin\mathcal C_M(b_n)\\
&\quad\Longleftrightarrow\\
&\exists L\subseteq X,
\quad L\in\mathcal C_N(b_{n+1})
\text{ and }L\notin\mathcal C_N(b_n).
\end{aligned}
$$

*Proof sketch.* A witness language on one model belongs to the same two levelwise classes on the other by Theorem 3.8. Transport in both directions also preserves the negative assertion: if the language entered the lower class after translation, backward exact transport would contradict its original nonmembership.

Thus strictness is not an artifact of either exact substrate. The theorem preserves existence of a separation and allows the same extensional language to serve as witness.

## 5. Witness computation and the P-versus-NP form

Let $X$ be the input set and $W$ a witness set. A verifier model $V$ is a machine model over $X\times W$.

**Definition 5.1 (Witness class).** Given a verifier budget $q:X\times W\to\mathbb N$, a language $L\subseteq X$ lies in $\mathcal W_V(q)$ if there exists a verifier program $v$ such that

$$
\forall x\in X,
\qquad x\in L
\Longleftrightarrow
\exists w\in W,\ \mathrm{Acc}_V(v,(x,w)),
$$

and

$$
\forall (x,w)\in X\times W,
\qquad c_V(v,(x,w))\le q(x,w).
$$

**Theorem 5.2 (Witness-Class Invariance).** If verifier models $V$ and $W'$ over $X\times W$ are exactly resource-equivalent, then for every $q$ and $L$,

$$
L\in\mathcal W_V(q)
\Longleftrightarrow
L\in\mathcal W_{W'}(q).
$$

*Proof sketch.* Translate the verifier program. For each pair $(x,w)$, acceptance is preserved, so the same witness $w$ works before and after translation. Exact cost control preserves $q$. The reverse simulation supplies the converse.

To formulate the P-versus-NP shape without tying it to a particular asymptotic encoding, fix a deterministic budget $b:X\to\mathbb N$ and witness budget $q:X\times W\to\mathbb N$.

**Definition 5.3 (Deterministic-witness equality).** The decision model $M$ and verifier model $V$ satisfy deterministic-witness equality at $(b,q)$ when

$$
\forall L\subseteq X,
\qquad L\in\mathcal C_M(b)
\Longleftrightarrow
L\in\mathcal W_V(q).
$$

**Theorem 5.4 (Deterministic-versus-Witness Substrate Invariance).** Let $M$ and $N$ be exactly resource-equivalent decision models over $X$. Let $V$ and $W'$ be exactly resource-equivalent verifier models over $X\times W$. Then deterministic-witness equality holds for $(M,V)$ at $(b,q)$ if and only if it holds for $(N,W')$ at the same bounds.

*Proof sketch.* For any language $L$, Theorem 3.8 identifies deterministic membership between $M$ and $N$, while Theorem 5.2 identifies witness membership between $V$ and $W'$. Compose these equivalences with the assumed deterministic-witness equivalence. The converse uses the reverse chain.

The theorem is intentionally neutral on whether equality is true. It proves that exact architecture changes cannot alter its truth value. Consequently, any separating language—or any universal equality proof—transfers across exactly equivalent decision and verifier substrates.

## 6. Many-one reductions and complexity transfer

A semantic reduction alone is not a resource statement. We therefore distinguish reduction correctness from a model's ability to precompose programs economically.

**Definition 6.1 (Extensional many-one reduction).** A function $f:X\to X$ reduces $A\subseteq X$ to $B\subseteq X$ when

$$
\forall x\in X,
\qquad x\in A\Longleftrightarrow f(x)\in B.
$$

**Definition 6.2 (Supported precomposition).** Model $M$ supports precomposition by $f$ without additional cost if each program $p$ has a precompiled program $p\circledast f$ satisfying

$$
\mathrm{Acc}_M(p\circledast f,x)
\Longleftrightarrow
\mathrm{Acc}_M(p,f(x))
$$

and

$$
c_M(p\circledast f,x)
\le c_M(p,f(x)).
$$

The notation does not imply literal function composition; it denotes whatever program transformation the architecture provides.

**Theorem 6.3 (Reduction Transport).** Suppose $f$ reduces $A$ to $B$ and $M$ supports precomposition by $f$ without additional cost. If $B\in\mathcal C_M(b)$, then

$$
A\in\mathcal C_M(b\circ f).
$$

*Proof sketch.* Let $p$ decide $B$ within $b$. The precompiled program accepts $x$ exactly when $p$ accepts $f(x)$, exactly when $f(x)\in B$, and hence exactly when $x\in A$. Its cost is at most $c_M(p,f(x))\le b(f(x))$.

The theorem separates two mechanisms often conflated in informal discussion. The equivalence $x\in A\Longleftrightarrow f(x)\in B$ is purely extensional. The resource conclusion depends on an architectural closure property. More realistic variants can charge explicitly for computing $f$; the present exact form isolates the cleanest transport law.

## 7. Jump hierarchies and stronger computation

A model stronger than ordinary computation may decide languages inaccessible to conventional machines. Nevertheless, it can possess its own sequence of resource barriers.

Let $J:\mathcal P(X)\to\mathcal P(X)$ be a language operator, let $S\subseteq X$ be a seed, and let $J^n(S)$ denote the $n$-fold iterate, with $J^0(S)=S$.

**Definition 7.1 (Jump hierarchy).** The tuple $(M,(b_n),J,S)$ is a jump hierarchy when, for every $n\in\mathbb N$,

$$
J^n(S)\in\mathcal C_M(b_n)
$$

and

$$
J^{n+1}(S)\notin\mathcal C_M(b_n).
$$

The first condition is level membership; the second is successor escape.

**Theorem 7.2 (Successor Separation).** Every jump hierarchy has a strict adjacent separation at every level: for each $n$, there exists a language in $\mathcal C_M(b_{n+1})$ but not in $\mathcal C_M(b_n)$.

*Proof sketch.* Choose $L=J^{n+1}(S)$. Membership at level $n+1$ is the first jump axiom with index $n+1$, while nonmembership at level $n$ is the second axiom with index $n$.

**Theorem 7.3 (Jump-Hierarchy Invariance).** If $M$ and $N$ are exactly resource-equivalent, then

$$
(M,(b_n),J,S)\text{ is a jump hierarchy}
$$

if and only if

$$
(N,(b_n),J,S)\text{ is a jump hierarchy}.
$$

*Proof sketch.* Exact forward transport carries every membership $J^n(S)\in\mathcal C_M(b_n)$ to $N$. To preserve escape, suppose contrary to the desired conclusion that $J^{n+1}(S)$ belonged to $\mathcal C_N(b_n)$. Exact backward transport would place it in $\mathcal C_M(b_n)$, contradicting escape there. Reverse the roles of $M$ and $N$ for the converse.

**Theorem 7.4 (No Finite Stabilization).** In a jump hierarchy, no level $n$ gives the same bounded-membership truth value to the current language and its successor. More precisely,

$$
\neg\Bigl(
J^n(S)\in\mathcal C_M(b_n)
\Longleftrightarrow
J^{n+1}(S)\in\mathcal C_M(b_n)
\Bigr)
$$

for every $n$.

*Proof sketch.* The current iterate belongs to the level by the membership axiom, while the successor does not by the escape axiom. Their truth values therefore differ.

These results apply equally to an ordinary or hypercomputational base model. They do not guarantee that a particular model has a suitable jump; that construction remains model-specific. They show that once the two jump axioms hold, exact implementation changes cannot collapse the hierarchy.

## 8. Algorithms and numerical illustrations

Although the theory concerns extensional language classes, its quantitative laws admit direct finite demonstrations.

### 8.1 Composing overhead functions

Given a path of simulations with overheads $h_1,\ldots,h_k$, the induced overhead is

$$
H=h_k\circ\cdots\circ h_1.
$$

For a finite list of observed costs $c_1,\ldots,c_m$, one evaluates $H(c_i)$ by applying overheads in translation order. This requires $O(km)$ overhead evaluations and $O(m)$ output storage. If a source program satisfies costs $c_i\le b_i$, monotonicity guarantees $H(c_i)\le H(b_i)$.

### 8.2 Checking exact finite class profiles

For a finite family of languages and budgets, represent bounded-class membership by a Boolean matrix $P_{i,n}$. Exact substrate equivalence predicts equality of the matrices for the two substrates. A comparison scans all entries in $O(rs)$ time for $r$ languages and $s$ hierarchy levels. This finite calculation illustrates the levelwise theorem; it does not establish equivalence of infinite machine models.

### 8.3 Diagnosing jump profiles

For finite prefixes, record whether $J^n(S)$ is present at level $n$ and whether $J^{n+1}(S)$ is absent there. A prefix satisfies the jump pattern exactly when both tests pass at every inspected index. The scan is linear in the prefix length. The resulting staircase visually separates diagonal membership from successor escape.

## 9. Applications

### 9.1 Cross-architecture complexity claims

When two architectures come with exact compilers in both directions, bounded decision results need be proved only once. This includes positive class membership and negative separation witnesses. The burden is shifted to establishing semantic preservation and resource control for the compilers.

### 9.2 Verifier portability

Certificate systems may use different verifier hardware from ordinary decision programs. Theorem 5.4 permits these components to be compared separately: exact equivalence is required among decision substrates and among verifier substrates, not between a decider and verifier. This modularity is useful for heterogeneous computing.

### 9.3 Completeness and reductions

Theorem 6.3 supplies one component of architecture-independent completeness. If reductions can be precompiled with suitable cost and the target language has a bounded solver, every reducible source language inherits a transformed bound. Combining this with substrate transport suggests portability theorems for reduction-closed classes.

### 9.4 Hypercomputational models

A stronger civilization might possess oracle-like operations unavailable to ordinary machines. If its model supports a concrete diagonal jump with membership and escape laws, Theorems 7.2–7.4 show an endless finite sequence of local barriers and their invariance under exact reimplementation.

## 10. Scope and limitations

The theory proves conditional invariance, not universal equivalence of all conceivable computers. Several limitations are substantive.

First, exact overhead is stringent. A semantics-preserving compiler with overhead $h$ transports $b$ to $h\circ b$, not necessarily to $b$. Therefore fixed-level claims require exactness or a separate closure argument.

Second, deterministic-witness invariance does not decide whether deterministic and witness classes coincide. It identifies the truth value across equivalent substrates.

Third, the jump hierarchy is axiomatic. Concrete diagonalization, oracle coding, or universal simulation must be built for each intended model before the abstract consequences apply.

Fourth, the no-extra-cost reduction hypothesis is stronger than ordinary polynomial-time reducibility. A broader theory should account for the cost of evaluating $f$ and prove closure under combined bounds.

A further methodological point is that pointwise bounds make all quantifiers visible. No averaging over inputs and no asymptotic convention is silently introduced. This makes the results suitable as a foundation on which asymptotic closure principles can later be imposed explicitly.

These limitations prevent overinterpretation while identifying precise research obligations.

## 11. Future work

The immediate extension is polynomial-overhead invariance. If two substrates simulate one another with polynomial overhead and use polynomially related input-size encodings, polynomial deterministic and polynomial witness classes should coincide. More generally, a family of admissible resource rescalings should induce equivalence of quotient hierarchies whenever the hierarchy is closed under that family.

A second direction is the construction of concrete relativized jump towers. Effective models with universal simulation and diagonal coding are expected to admit jump operators whose iterates escape every corresponding finite oracle level. The present jump-transport theorem then makes persistence independent of implementation.

A third direction concerns completeness. Under polynomial mutual simulation and reduction precomposition with polynomial cost, completeness for reduction-closed classes should survive architecture changes. Finally, heterogeneous verifier systems motivate robustness results in which decision machines and witness verifiers are translated by separate polynomial simulations.

## 12. Conclusion

A computational substrate has been reduced to programs, acceptance, and cost; a simulation to semantic translation plus monotone overhead. From these ingredients follows a complete transport calculus. General simulations transform resource bounds. Exact mutual simulations identify all bounded language classes, indexed hierarchy levels, adjacent separations, and existential witness classes. They preserve the truth of deterministic-versus-witness equality. Supported many-one precomposition transfers bounded solvers backward along reductions. Jump hierarchies produce successor separations, cannot stabilize at any finite tier, and survive exact changes of implementation.

The resulting principle is precise: computational complexity is independent of substrate exactly to the extent that semantics and resources are preserved. More powerful machinery may change which problems occupy the base level, but whenever a valid jump escapes each tier, the hierarchy reappears. The barriers are then properties of the computational structure, not of the material that realizes it.
