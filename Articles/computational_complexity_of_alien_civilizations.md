# The Laws of Computation an Alien Civilization Cannot Avoid

Imagine first contact not as a meeting of bodies, but of algorithms. A signal arrives bearing a proof, a star map, or a compressed history. Its authors may think with crystal defects, chemical waves, engineered organisms, or structures we have no words for. Their hardware could make our fastest machines look like abacuses. Would they nevertheless recognize the same boundaries between easy and difficult problems?

A precise answer begins by separating computation from the material that performs it. The central conclusion is both strong and carefully qualified: **complexity is invariant under resource-respecting semantic equivalence**. If two computational substrates can translate programs back and forth without changing what they accept and without inflating the chosen resource, then they classify every decision problem identically at every resource level. They also agree about deterministic computation, witness-assisted computation, separations in an infinite hierarchy, and any successive “jump” to harder problems.

This is not a solution of the famous P-versus-NP problem. It says something different: for exactly equivalent substrates, the truth or falsity of the corresponding deterministic-versus-witness equality cannot depend on the substance of the computer.

## What counts as a computational world?

Fix a collection $X$ of possible inputs. A **machine model** consists of three ingredients: a collection of programs; a statement saying whether program $p$ accepts input $x$; and a natural-number cost $c(p,x)$. The cost might count time steps, memory cells, energy quanta, communication rounds, or another agreed resource.

A language is simply a set $L\subseteq X$. Program $p$ **decides** $L$ when it accepts exactly the members of $L$. Given a pointwise budget $b:X\to\mathbb N$, the language lies in the bounded class $\mathcal C_M(b)$ when some program on model $M$ decides $L$ and satisfies

$$
c_M(p,x)\le b(x)
$$

for every input $x$.

This spare definition is intentionally indifferent to architecture. It can describe familiar computers, distributed networks, biological information processors, or hypothetical machines. What matters is behavior and cost.

## Translation is the bridge

Suppose model $M$ can be simulated by model $N$. Such a simulation translates every $M$-program $p$ into an $N$-program $T(p)$. It must preserve acceptance:

$$
N\text{ accepts }T(p)\text{ on }x
\quad\Longleftrightarrow\quad
M\text{ accepts }p\text{ on }x.
$$

It must also have a monotone overhead function $h:\mathbb N\to\mathbb N$ such that

$$
c_N(T(p),x)\le h(c_M(p,x)).
$$

Monotonicity means that a larger original cost never receives a smaller advertised allowance. Simulations compose: if $M$ translates to $N$ with overhead $h_1$, and $N$ translates to $K$ with overhead $h_2$, then $M$ translates to $K$ with overhead $h_2\circ h_1$. The identity translation has identity overhead. Thus models and simulations form a coherent calculus of compilation.

The first transport theorem follows immediately but carries the whole story.

**Bounded-Class Transport Theorem.** If $L\in\mathcal C_M(b)$ and $M$ is simulated by $N$ with monotone overhead $h$, then

$$
L\in\mathcal C_N(h\circ b).
$$

Indeed, translate a deciding program. Its answers remain the same. Since its old cost is at most $b(x)$, monotonicity turns the simulation bound into a new cost at most $h(b(x))$.

The theorem can be pictured as a customs declaration attached to every migrating algorithm: meaning passes unchanged, but resource consumption must be declared. This distinction separates a universal law from a merely optimistic slogan.

This theorem exposes an important limit. An arbitrary compiler does not preserve the original budget. A machine taking $b(x)$ steps may require $h(b(x))$ steps elsewhere. Claims of substrate independence are meaningless unless the overhead is stated.

## Exact equivalence and universal hierarchies

Call a simulation **exact** when its overhead is the identity function. This permits the translated program to cost no more than the original. Call two models **resource-equivalent** when each simulates the other. If both directions are exact, bounded classes coincide:

**Exact Substrate-Invariance Theorem.** For every language $L$ and every pointwise budget $b$,

$$
L\in\mathcal C_M(b)
\quad\Longleftrightarrow\quad
L\in\mathcal C_N(b).
$$

The proof transports a program forward for one implication and backward for the other. No biology, physics, or instruction set appears in the conclusion.

Now choose budgets $b_0,b_1,b_2,\ldots$. They define a **complexity hierarchy** whose $n$th level is

$$
\mathcal H_M(n)=\{L\subseteq X:L\in\mathcal C_M(b_n)\}.
$$

Exact mutual simulation identifies this entire hierarchy level by level: $\mathcal H_M(n)=\mathcal H_N(n)$ for every $n$. Consequently, an adjacent separation is also invariant. There exists a language decidable at level $n+1$ but not at level $n$ on $M$ if and only if the same is true on $N$. The separating language itself can be carried across unchanged because languages are extensional sets of inputs, not pieces of hardware.

One may imagine two observatories exchanging programs together with certified cost ledgers. Exact equivalence says that neither side can hide an advantage in translation: each ledger remains valid after crossing the bridge and after returning.

A civilization may choose unfamiliar units, but if its translations preserve the agreed resource exactly, it sees the same ladder.

## The P-versus-NP shape

Witness computation adds a second input. Let $X$ be the ordinary input space and $W$ a space of certificates. A verifier model acts on pairs $(x,w)$. Given a verifier budget $q:X\times W\to\mathbb N$, a language $L$ belongs to the witness class when there is a verifier program $v$ such that

$$
x\in L
\quad\Longleftrightarrow\quad
\text{there exists }w\in W\text{ accepted by }v,
$$

and $c_V(v,(x,w))\le q(x,w)$ for every pair.

Exact mutual simulations of verifier architectures preserve this witness class, just as exact simulations of ordinary machines preserve deterministic bounded classes. Put the two observations together:

**Deterministic-versus-Witness Invariance Theorem.** Suppose $M$ and $N$ are exactly resource-equivalent decision models, while $V$ and $W$ are exactly resource-equivalent verifier models. For fixed bounds $b$ and $q$, the statement

$$
\forall L\subseteq X,
\quad L\in\mathcal C_M(b)
\Longleftrightarrow
L\in\mathcal W_V(q)
$$

holds if and only if the analogous statement with $N$ and $W$ holds.

This theorem captures the logical shape of P versus NP at fixed bounds. It neither proves equality nor separation. Instead, it proves that an exact change of substrate cannot flip the answer. If one civilization establishes a separating language under these shared resource conventions, another exactly equivalent civilization inherits it. If one establishes equality, the other inherits that too.

## Reductions: reusing a solver

Complexity theory advances by translating problems as well as programs. Suppose $f:X\to X$ reduces language $A$ to language $B$:

$$
x\in A\quad\Longleftrightarrow\quad f(x)\in B.
$$

Assume model $M$ can precompose any program for $B$ with $f$ without extra cost beyond running that program on $f(x)$. Then a $b$-bounded solver for $B$ becomes a $(b\circ f)$-bounded solver for $A$.

**Reduction Transport Theorem.** Under this precomposition support,

$$
B\in\mathcal C_M(b)
\quad\Longrightarrow\quad
A\in\mathcal C_M(b\circ f).
$$

The algorithm is simple: transform $x$ into $f(x)$ and invoke the solver for $B$. The theorem clarifies why architectural support matters. Extensional reducibility describes logical equivalence of membership; complexity transfer additionally requires a cost-respecting way to perform the precomposition.

## Why stronger machines still meet horizons

Perhaps an alien civilization has “hypercomputers” that decide questions our machines cannot. Does greater power erase hierarchy? Not in the presence of a jump operation.

Choose a seed language $S$ and an operation $J$ that maps a language to a harder one. Write $J^n(S)$ for the result of applying $J$ $n$ times. A **jump hierarchy** for model $M$ and budgets $b_n$ satisfies two laws:

1. $J^n(S)$ is decidable within $b_n$.
2. $J^{n+1}(S)$ is not decidable within $b_n$.

The first law places each current problem at its tier; the second says the next jump escapes that tier.

It follows that every adjacent pair is genuinely separated: $J^{n+1}(S)$ lies at level $n+1$ but not level $n$. No finite level stabilizes by already containing its own next jump. And exact mutual simulation preserves the whole jump hierarchy in both directions.

**Jump-Barrier Invariance Theorem.** If $M$ and $N$ are exactly resource-equivalent, then $(S,J,(b_n))$ is a jump hierarchy on $M$ if and only if it is a jump hierarchy on $N$.

So hypercomputation changes the starting altitude, not the logic of the mountain range. Once a stronger model has a successor operation satisfying the two jump laws, architecture changes cannot flatten its successive barriers.

## The message in the signal

The theory does not claim that every physically possible computer is equivalent, nor that every simulation is exact. Exactness is deliberately stringent. Real complexity classes such as polynomial time usually tolerate polynomial overhead, suggesting a broader next theorem based on admissible rescalings rather than identity cost. Concrete hypercomputational models also need concrete jump constructions; the abstract result tells us what follows once those constructions exist.

Yet the established core is already a powerful guide to first contact. To compare computational sciences, we should not ask whether alien devices resemble ours. We should ask for translations: Do they preserve accepted languages? What is their overhead? Can programs travel both ways? Can verifiers and reductions travel too?

If the answers meet the exact hypotheses, then complexity is not provincial knowledge. Hierarchy separations, witness barriers, and successive jumps belong to the structure of computation shared by both civilizations. Their processors may be grown, assembled, condensed, or woven into spacetime. The laws proved here do not care. They live in the bridge between meaning and resource—and any civilization that builds that bridge encounters the same mathematics.
