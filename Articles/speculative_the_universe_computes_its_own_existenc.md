# When a World Computes the Rules It Lives By

## A precise mathematical core for a provocative idea

Imagine a universe-sized machine. Feed it a description of physical laws and a description of a present state, and it returns the next state. Ordinarily, the laws sit outside the calculation: they are the program, while matter and fields are the data. But what if the proposed laws were themselves part of the input? Could the machine process a candidate rulebook and return that same rulebook, making the laws a fixed point of their own dynamics?

The phrase “the universe computes its own existence” is irresistible. It is also dangerously easy to leave vague. What exactly is computing? In what space do laws live? Why should a self-consistent law exist? Would it be unique? And how could a static fixed-point equation say anything about the states actually reached over time?

A clean answer begins not with a particular theory of particles, but with order. Candidate laws can be ordered by information or inclusion. One law may allow every behavior allowed by another, and perhaps more. Once this order has enough limits, monotone simulation produces a canonical self-consistent law. In the especially concrete case where a “law” is a region of state space, that law is simply the smallest region containing the initial states and closed under one-step evolution. It consists exactly of the states reachable after finitely many steps.

That conclusion is mathematically rigorous, useful, and more restrained than the original speculation. It proves a canonical least solution, not a unique fixed point of every possible kind. It also does not predict a physical constant. What it offers is a bridge among computation, dynamics, and geometry: three vocabularies describing the same closure process.

## Ordering possible laws

Let $A$ be a collection of candidate laws equipped with an order $\leq$. Read $a\leq b$ as saying that $a$ is no more permissive, no more informative, or no larger than $b$, depending on the application. We require $A$ to be a **complete lattice**: every family $S\subseteq A$ has both a greatest lower bound $\bigwedge S$ and a least upper bound $\bigvee S$. Thus arbitrary collections of proposals can be intersected or combined without leaving the universe of discourse.

A function $f:A\to A$ is **monotone** when $a\leq b$ implies $f(a)\leq f(b)$. Monotonicity says that supplying a larger approximation cannot produce a smaller result. For such a function, define

$$
\operatorname{lfp}(f)=\bigwedge\{a\in A:f(a)\leq a\}.
$$

This is the least fixed point of $f$. It is a genuine fixed point, $f(\operatorname{lfp}(f))=\operatorname{lfp}(f)$, and it lies below every other fixed point. Existence follows from completeness and monotonicity. The construction is canonical because it chooses the least self-consistent answer rather than an arbitrary one.

Now introduce a binary simulator $U:A\times A\to A$. The first argument may be read as the proposed law and the second as the object or state description to which it is applied. Assume $U$ is monotone in both arguments. There are two natural ways to ask for self-reference.

First, for each provisional law $a$, solve the inner equation $b=U(a,b)$ by choosing its least solution, then solve the outer equation

$$
a=\operatorname{lfp}(b\mapsto U(a,b)).
$$

Second, feed the same candidate into both sockets and solve the diagonal equation

$$
a=U(a,a).
$$

The **Fixed-Point Diagonal Theorem** says these constructions agree at the least solution:

$$
\operatorname{lfp}\!\left(a\mapsto \operatorname{lfp}(b\mapsto U(a,b))\right)
=
\operatorname{lfp}(a\mapsto U(a,a)).
$$

This is the abstract heart of self-simulation. Resolving the simulated object first and then resolving the law yields the same canonical result as direct self-application.

Why? Let $p$ denote the nested least fixed point. Its defining equations imply $p=U(p,p)$, so it is a diagonal fixed point. Conversely, every diagonal pre-fixed point $q$ satisfying $U(q,q)\leq q$ also bounds the inner least solution at $q$; the outer least solution must therefore lie below $q$. These two comparisons identify the same least diagonal solution.

## Laws as regions of possibility

The abstraction becomes vivid when candidate laws are subsets of a state space $X$. Ordered by inclusion, the power set $\mathcal P(X)$ is a complete lattice: intersections are greatest lower bounds and unions are least upper bounds.

Choose a set $I\subseteq X$ of initial conditions and a deterministic update rule $s:X\to X$. Define an operator on regions by

$$
F(R)=I\cup s[R],
$$

where $s[R]=\{s(x):x\in R\}$. A region $R$ is a fixed point of $F$ precisely when it contains the initial conditions and every point in it is generated either initially or as the successor of another point in it, with no surplus beyond that equation. More generally, the condition $F(R)\subseteq R$ means that $R$ contains $I$ and is **forward invariant**: $x\in R$ implies $s(x)\in R$.

The **Least Invariant Region Theorem** states that $F$ has a least fixed point $R_*$ and that $R_*$ is the unique least region containing $I$ and closed under $s$. In symbols,

$$
R_*=\operatorname{lfp}(F),
$$

and whenever $I\subseteq R$ and $s[R]\subseteq R$, one has $R_*\subseteq R$.

This result gives “uniqueness” its correct meaning. There can be many forward-invariant regions. The entire state space $X$ is always one. A system with two disconnected cycles can have each cycle and their union as invariant regions. The distinguished object is unique because it is generated from the specified initial conditions and contains nothing forced by neither initialization nor evolution.

## The operational meaning: finite reachability

A least fixed point can sound static, as though it were obtained by contemplating all possible regions at once. Dynamics supplies an equivalent, step-by-step picture.

Write $s^0(x)=x$ and $s^{n+1}(x)=s(s^n(x))$. A state $x$ is **finitely reachable** from $I$ if there are an initial state $i\in I$ and a natural number $n$ such that $x=s^n(i)$. Define

$$
\operatorname{Reach}(I,s)=\{x\in X:\exists i\in I,\ \exists n\in\mathbb N,\ x=s^n(i)\}.
$$

The **Finite Reachability Theorem** identifies this operational set exactly with the least invariant region:

$$
R_*=\operatorname{Reach}(I,s).
$$

The proof has two simple halves. The reachable set contains $I$, because zero steps are allowed, and it is closed under $s$, because one more update turns an $n$-step path into an $(n+1)$-step path. Minimality therefore gives $R_*\subseteq\operatorname{Reach}(I,s)$. In the other direction, $R_*$ contains every initial point and is forward invariant, so induction on $n$ shows that every $s^n(i)$ belongs to $R_*$. Thus the two sets coincide.

This equality unites two styles of reasoning. Denotationally, the law is a least fixed point in a lattice. Operationally, it is the collection of states produced by finite execution. Geometrically, it is the smallest forward-invariant region containing the initial data.

## A miniature universe

Consider the state space $X=\{0,1,2,3,4,5,6,7\}$ with update rule

$$
s(x)=(2x+1)\bmod 8
$$

and initial set $I=\{0\}$. Iteration gives

$$
0\longmapsto1\longmapsto3\longmapsto7\longmapsto7.
$$

The least invariant region is therefore $\{0,1,3,7\}$. Starting with $R_0=\varnothing$ and repeatedly applying $F$ produces

$$
R_1=\{0\},\qquad R_2=\{0,1\},\qquad
R_3=\{0,1,3\},\qquad R_4=\{0,1,3,7\}.
$$

Further applications change nothing. Other invariant regions exist—for example, the full eight-state space—but none is smaller while still containing $0$ and respecting the update rule.

For a finite state space, this suggests a direct algorithm: begin with the initial region, repeatedly add successors, and stop when no new state appears. Since at least one new point is added at every nonterminal round, stabilization occurs after at most $|X|$ growth rounds. A queue-based graph search is more efficient: each reachable state need be processed only once.

## What the theorem does—and does not—say about physics

The framework captures a real structure that appears across science. In model checking, reachable-state closure determines whether a forbidden state can occur. In control theory, forward-invariant sets encode safety. In program semantics, least fixed points describe loops and recursion. In dynamical systems, an orbit closure under finite iteration records what evolution can generate. In geometry, regions ordered by inclusion provide the ambient lattice.

But mathematical precision also draws boundaries. Monotonicity and completeness guarantee a least fixed point; they do not guarantee that it is the only fixed point. Unrestricted uniqueness requires additional assumptions, such as contraction in a metric setting or a suitable uniqueness principle after quotienting by behavioral equivalence.

Nor does the framework determine the fine-structure constant $\alpha$. Nothing in the order-theoretic assumptions singles out the observed value near $1/137.036$. A numerical prediction would require an independently justified physical model connecting candidate laws, measurable quantities, and the lattice semantics. “Simplicity” alone is not an equation.

Finally, the least reachable region is not automatically an attractor. Reachability says which states occur after finitely many updates; attraction concerns limiting behavior and requires topology or a metric. Closedness, measurability, convergence, and stability must each be earned through additional hypotheses.

## A disciplined version of cosmic self-computation

The grand slogan survives, but in a sharpened form. A monotone simulator acting on a complete lattice admits a canonical law under least-solution semantics. Nested simulation and diagonal self-application select the same law. When laws are regions of state space, the selected law is the smallest forward-invariant region containing the initial conditions, and its points are exactly those reached in finitely many steps.

This does not derive all of physics from logic. It does something more modest and more durable: it identifies the mathematical architecture any serious theory of self-computing laws would need. Self-reference becomes a fixed-point equation. Canonical choice becomes minimality. Dynamics becomes reachability. Geometry becomes invariant closure.

The universe may or may not compute its own rulebook. But if that idea is to become mathematics rather than metaphor, this is where the computation begins.
