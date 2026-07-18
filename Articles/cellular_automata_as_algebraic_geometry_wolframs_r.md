# Cellular Automata as Algebraic Geometry: What Fixed Points Really Reveal

A row of black and white cells seems an unlikely place to look for algebraic geometry. Yet every tick of an elementary cellular automaton hides a polynomial calculation. Each cell reads three bits—its left neighbor, itself, and its right neighbor—and replaces itself according to a fixed lookup table. There are only $256$ such tables, but their behavior ranges from immediate extinction to intricate moving structures and universal computation.

This algebraic viewpoint is illuminating, but it also carries a warning. A tempting slogan says that a more complicated automaton should have a larger geometric space of fixed configurations. The fixed points tell a subtler story. Rule $110$, famous for supporting universal computation, can have only one fixed configuration under a broad connectivity condition. Rule $204$, which merely copies every cell, fixes every possible configuration. Thus the size—or dimension—of a fixed-point set does not measure dynamical complexity by itself.

The useful discovery is not the slogan but the framework that exposes why it fails.

## From lookup tables to polynomials

An elementary cellular automaton uses a local rule

$$
f:\{0,1\}^3\longrightarrow\{0,1\}.
$$

There are $8$ possible three-cell neighborhoods and $2$ possible outputs for each, so the number of rules is

$$
2^8=256.
$$

Now identify the two symbols with the field $\mathbb F_2$, where addition is exclusive-or and multiplication is logical conjunction. Every Boolean function of three variables then has a unique algebraic normal form

$$
f(l,c,r)=a_0+a_1l+a_2c+a_3lc+a_4r+a_5lr+a_6cr+a_7lcr,
$$

with coefficients $a_j\in\mathbb F_2$. The degree is at most $3$ because the inputs satisfy $l^2=l$, $c^2=c$, and $r^2=r$ on Boolean values. The coefficients are recovered from the truth table by Möbius inversion on the Boolean cube. For example, $a_0=f(0,0,0)$ and $a_1=f(1,0,0)+f(0,0,0)$, with addition in $\mathbb F_2$.

This is more than a change of notation. A row of $n$ cells is a point

$$
s=(s_0,\ldots,s_{n-1})\in\mathbb F_2^n.
$$

Once left- and right-neighbor maps $L,R:\{0,\ldots,n-1\}\to\{0,\ldots,n-1\}$ are chosen, the global update is the polynomial map $F:\mathbb F_2^n\to\mathbb F_2^n$ given coordinatewise by

$$
F(s)_i=f(s_{L(i)},s_i,s_{R(i)}).
$$

Periodic boundaries, reflecting boundaries, and more unusual network couplings all fit into this single definition.

## Fixed points as solutions of equations

A stable configuration is a fixed point: $F(s)=s$. Coordinate by coordinate, it solves

$$
f(s_{L(i)},s_i,s_{R(i)})-s_i=0
\qquad (0\le i<n),
$$

where subtraction and addition agree in $\mathbb F_2$. To describe Boolean states algebraically, one should also impose

$$
s_i^2-s_i=0.
$$

The resulting equations define a fixed-point scheme, while their $\mathbb F_2$-valued solutions are exactly the stable binary configurations. That distinction matters: the number of rational points and the Krull dimension of a coordinate ring are different invariants. Once all Boolean relations are included for finite $n$, the coordinate ring is finite and its Krull dimension is $0$, even when there are many fixed points. Counting fixed states is therefore not the same as measuring geometric dimension.

Three rules make the lesson vivid.

## Rule $0$: total extinction

Rule $0$ outputs $0$ for every neighborhood. Therefore $F(s)$ is the all-zero row for every initial state. A fixed state must equal its update, so it must be all zero. Conversely, the all-zero state is fixed. Hence, for every array size and every choice of neighbor maps, Rule $0$ has exactly one fixed configuration.

This matches intuition: a rule that erases everything has a single resting place.

## Rule $204$: maximal stillness

Rule $204$ returns the center bit. Its local polynomial is simply

$$
f(l,c,r)=c.
$$

Consequently $F(s)_i=s_i$ at every site, regardless of the boundary convention. Every state is fixed. Since an $n$-cell binary array has $2^n$ states, Rule $204$ has exactly $2^n$ fixed configurations.

Yet Rule $204$ is dynamically trivial: time does nothing. Maximal fixed-point count here means maximal stillness, not maximal computational power.

## Rule $110$: rich evolution, sparse equilibrium

Rule $110$ has outputs, in neighborhood order $000,001,010,011,100,101,110,111$,

$$
0,1,1,1,0,1,1,0.
$$

Its all-zero configuration is fixed because $000$ maps to $0$. Its all-one configuration is not fixed on any nonempty array because $111$ maps to $0$. Thus Rule $110$ always has at least one fixed state but strictly fewer than the ambient total of $2^n$.

A stronger theorem follows from a tiny local observation. Suppose $s$ is fixed and $s_i=0$. At site $i$, the center bit is $0$. Among Rule $110$ neighborhoods with center $0$, a right bit equal to $1$ produces output $1$, not the required output $0$. Therefore

$$
s_i=0\quad\Longrightarrow\quad s_{R(i)}=0.
$$

Zeros propagate forward along the right-neighbor map.

Assume now that $R$ has one forward orbit: for every pair of sites $i,j$, some nonnegative iterate $R^k(i)$ equals $j$. This is a connectivity condition saying that repeatedly moving right from any site eventually reaches every site. In a fixed Rule $110$ state, the all-one state is impossible, so at least one site is zero. Zero propagation and the one-orbit condition then force every site to be zero. We obtain the **Rule $110$ Singleton Fixed-Point Theorem**: on a nonempty finite array whose right-neighbor map has one forward orbit, the all-zero configuration is the unique fixed configuration.

The proof is short, but its interpretation is powerful. Rule $110$ can generate complicated spacetime behavior precisely while having almost no static behavior. Computation lives in transients, moving defects, periodic structures, and interactions—not necessarily in equilibria.

## Why the original complexity idea breaks

The proposed correspondence “simple means few fixed points; universal means maximal fixed-point dimension” fails in two independent ways.

First, fixed-point count reverses the expected ranking. The identity-like Rule $204$ has all $2^n$ states fixed, while Rule $110$ may have only one. Second, geometric dimension is not interchangeable with point count. For a finite Boolean state space equipped with the equations $s_i^2-s_i=0$, every fixed-point coordinate ring is zero-dimensional. A collection of $2^n$ isolated points is larger than a single point in cardinality, but not in Krull dimension.

This does not make algebraic geometry irrelevant. It tells us to ask better questions. One may compare coordinate rings without collapsing them to one number, study polynomial equations for periodic orbits, examine how solution counts grow with $n$, or organize local data with a precisely defined sheaf. But none of these structures should be presumed to encode computational universality before a theorem establishes the connection.

## A practical computational pipeline

For a chosen rule and finite boundary convention, the basic experiment is transparent:

1. Decode the rule number into its eight truth-table outputs.
2. Convert the truth table into eight algebraic-normal-form coefficients.
3. Enumerate the $2^n$ states, apply the synchronous update, and retain those satisfying $F(s)=s$.
4. Optionally build the Boolean polynomial equations and compare point counts across sizes and rules.

Exhaustive enumeration costs on the order of $n2^n$ bit operations for one rule, so it is ideal for small arrays. The algebraic normal form takes constant work for a three-input rule. For larger systems, symbolic elimination, constraint solving, transfer matrices, or orbit-specific algorithms can replace brute force.

Simple numerical examples immediately recover the theorems. On a cyclic row, Rule $0$ has one fixed state for every tested $n$. Rule $204$ has $2^n$. Rule $110$ has only the zero state because the cyclic right shift is a single orbit. The contrast becomes sharper as $n$ grows: at $n=12$, Rule $204$ fixes all $4096$ configurations, while Rule $110$ fixes one.

## Geometry after the correction

The meeting of cellular automata and algebraic geometry remains fertile. The right lesson is methodological. A truth table can indeed be turned into a polynomial. Stable configurations can indeed be cut out by equations. But a proposed complexity invariant must survive elementary counterexamples and must distinguish cardinality, dimension, and dynamics.

For Rule $110$, the richest object is unlikely to be its fixed-point set. More promising targets include solutions of $F^p(s)=s$ for periods $p>1$, the growth of orbit languages with system size, polynomial encodings of spacetime diagrams, and structures that preserve how local patterns glue across regions. Universality concerns arbitrarily long evolution; an invariant designed to detect it should remember time.

The algebra therefore delivers both a bridge and a boundary. Every elementary cellular automaton is a cubic Boolean polynomial system, and its fixed states form an algebraically defined set. Yet equilibrium geometry alone cannot rank computational complexity. Sometimes the most complicated machine has one place to rest, while the simplest machine rests everywhere.
## What the equations let us see

Once a rule is written as a polynomial, questions that look unrelated become parts of one picture. A fixed pattern is a solution of simultaneous equations. A repeating pattern of temporal period $p$ is a solution of $F^p(s)=s$. A local implication, such as the forward spread of zero in a Rule $110$ equilibrium, becomes a constraint that travels through the graph of neighbor relations. This is useful in applications where cells represent genes, switches, pixels, agents, or components of a distributed circuit: one can ask which global steady states are compatible with local response laws.

The framework is also honest about scale. Exhausting all $2^n$ configurations becomes expensive quickly, but the local polynomial always has only eight coefficients. That compact representation can reveal linearity, interaction terms, and symmetries before any global enumeration begins. Rule $204$ has only the center term; its enormous stable set is then obvious. Rule $110$ includes nonlinear interactions, yet its equilibrium constraints collapse under cyclic connectivity. Algebra and dynamics answer different questions, and their contrast is itself informative.

Most importantly, a failed conjecture here is productive. It replaces a vague analogy with exact definitions and testable alternatives. Instead of asking whether “geometric richness” sounds like “computational richness,” one can specify a ring, a family of system sizes, a boundary convention, and an invariant. One can then prove a theorem, compute a table, or find a counterexample. That is how a metaphor becomes mathematics.
