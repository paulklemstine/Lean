# Cellular Automata as Algebraic Geometry

## When a row of bits becomes a landscape of equations

A cellular automaton begins with almost nothing: a line of cells, each either dark or bright, and a local instruction repeated everywhere at once. Yet this spare mechanism can freeze into crystals, churn like static, launch gliders across the screen, or carry out arbitrary computations. The most famous family, the elementary cellular automata, contains exactly $256$ rules. Their apparent simplicity hides a difficult question: how should we measure the complexity of a rule without relying only on pictures of its evolution?

Algebra offers a seductive answer. Replace darkness and light by the two elements $0$ and $1$ of the field $\mathbb F_2$. In this arithmetic, $1+1=0$. A local update rule is no longer merely an eight-entry lookup table; it is a polynomial function of three binary variables. A complete configuration becomes a point in a vast binary state space, and one synchronous update becomes a polynomial map of that space to itself.

This change of language is more than cosmetic. It lets us ask geometric questions. Which configurations are fixed points? Which equations cut them out? Do simple rules have small fixed-point sets while complex rules have large ones? The answers at the extremes are beautifully clean—but Rule 110, the celebrated universal rule, also supplies a decisive warning. Dynamical complexity does not equal abundance of stationary states.

## The eight-neighborhood dictionary

Let a configuration be a bi-infinite sequence $s:\mathbb Z\to\{0,1\}$. At position $i$, an elementary rule reads the triple

$$
(s_{i-1},s_i,s_{i+1}).
$$

Write this triple as $(\ell,c,r)$, for left, center, and right. Its binary index is

$$
4\ell+2c+r,
$$

an integer from $0$ to $7$. A rule number $R$ between $0$ and $255$ stores eight output bits. The output on $(\ell,c,r)$ is the bit of $R$ at position $4\ell+2c+r$. Applying this local function simultaneously at every site defines a global update $F_R$:

$$
(F_R(s))_i=f_R(s_{i-1},s_i,s_{i+1}).
$$

A stable configuration, or fixed point, is a state satisfying

$$
F_R(s)=s.
$$

Thus stability is an equation. For a finite periodic ring it becomes a finite system of polynomial equations over $\mathbb F_2$; for the bi-infinite line it is an infinite, translation-invariant system of local constraints.

Every Boolean function of three variables has a unique multilinear polynomial representation over $\mathbb F_2$. “Multilinear” means that no variable needs an exponent greater than one, because on binary inputs $x^2=x$. The general form is

$$
a_0+a_1\ell+a_2c+a_3r+a_4\ell c+a_5\ell r+a_6cr+a_7\ell cr,
$$

with each coefficient in $\mathbb F_2$. This is the algebraic normal form of the rule.

## Rule 110 in one polynomial

Rule 110 has local polynomial

$$
f_{110}(\ell,c,r)=r+c+cr+\ell cr
$$

over $\mathbb F_2$. This identity can be checked on all eight possible neighborhoods. For example, at $(1,1,1)$ the value is

$$
1+1+1+1=0,
$$

because addition is modulo $2$. At $(0,0,1)$ the value is $1$. The eight evaluations reproduce exactly the eight bits encoded by the number $110$.

The formula exposes interactions that the lookup table conceals. The terms $r$ and $c$ are linear contributions; $cr$ couples the center and right cells; and $\ell cr$ is a genuinely cubic, three-way interaction. The global fixed-point equations are therefore

$$
s_i=s_{i+1}+s_i+s_is_{i+1}+s_{i-1}s_is_{i+1}
$$

for every $i\in\mathbb Z$, with all arithmetic in $\mathbb F_2$.

This is the promised bridge to algebraic geometry: stable states are simultaneous zeros of the equations $f_R(s_{i-1},s_i,s_{i+1})-s_i=0$. On a ring of length $n$, they form a finite algebraic set inside $\mathbb F_2^n$.

## Two poles of the fixed-point spectrum

Rule 0 ignores its input and always outputs $0$. Consequently, one update sends every configuration to the all-zero state. A configuration can be fixed only if every one of its cells was already zero.

**Rule 0 Fixed-Point Theorem.** A bi-infinite binary configuration is fixed by Rule 0 if and only if it is identically zero. In particular, Rule 0 has exactly one fixed configuration.

The proof is immediate but instructive. If $F_0(s)=s$, then at each site $i$ the left-hand side has value $0$, so $s_i=0$. Conversely, the all-zero configuration plainly remains all zero.

At the opposite pole stands Rule 204. Its output is simply the center cell:

$$
f_{204}(\ell,c,r)=c.
$$

**Rule 204 Identity Theorem.** Every bi-infinite binary configuration is fixed by Rule 204.

Indeed, $(F_{204}(s))_i=s_i$ at every site. Rule 204 therefore has the largest possible fixed-point locus: the entire configuration space. On a periodic ring of length $n$, it has all $2^n$ states as fixed points, whereas Rule 0 has only one.

These two examples validate part of the geometric intuition. A rule that erases all information has the smallest possible stable set, while a rule that changes nothing has the largest. But they also reveal the essential distinction: a large fixed set can arise from complete dynamical inactivity.

## The Rule 110 surprise

Rule 110 is famous not because it leaves many states untouched, but because its evolving patterns can support universal computation. If complexity were literally the size or “dimension” of the fixed-point locus, one might predict that every state should be fixed by Rule 110, or at least that its stationary set should be maximal. A single configuration refutes the strongest version of that prediction.

Take the all-one configuration $\mathbf 1$, defined by $s_i=1$ for every $i$. Every neighborhood is $(1,1,1)$. The polynomial calculation above gives

$$
f_{110}(1,1,1)=0.
$$

So one update sends every cell to zero. In particular,

$$
F_{110}(\mathbf 1)\ne\mathbf 1.
$$

**Rule 110 Nonmaximality Theorem.** Not every configuration is fixed by Rule 110; specifically, the all-one configuration is not fixed.

There is also a fixed state at hand.

**Rule 110 Zero-State Theorem.** The all-zero configuration is fixed by Rule 110.

For the neighborhood $(0,0,0)$, every term in $r+c+cr+\ell cr$ vanishes. Thus the zero state remains zero.

Together these results locate Rule 110 strictly between the two elementary extremes: its fixed-point locus is nonempty, but it is not the whole state space. More importantly, they overturn the proposed equation “universal computation equals maximal fixed-point dimension.” Rule 204, whose dynamics are trivial, has the maximal fixed set; Rule 110, whose dynamics are computationally universal, does not.

## Why “dimension” needs care

The word dimension carries several meanings here, and confusing them can produce false conclusions. For a finite ring of length $n$, the fixed configurations are a finite subset of $\mathbb F_2^n$. If one regards only those rational points as a finite topological space in the usual algebraic-geometric sense, its Krull dimension is typically $0$ whenever it is nonempty. That invariant cannot distinguish one fixed point from $2^n$ fixed points.

Other quantities can distinguish them. One may count fixed points. One may study the quotient ring obtained from the fixed-point equations and measure its vector-space dimension over $\mathbb F_2$. One may count periodic fixed configurations as $n$ grows and extract an entropy. Or one may enlarge the object being studied—from stationary configurations to whole spacetime histories—and then investigate components, recurrence, propagation, and computational structure.

The lesson is not that geometry is the wrong language. It is that the geometric object and its invariant must match the dynamical question. Fixed points describe perfect stillness. Universal computation depends on long evolution, moving signals, collisions, memory, and unbounded time. A photograph cannot by itself measure the complexity of a film.

## A practical experimental program

The algebraic viewpoint nevertheless gives a powerful computational pipeline. For a periodic ring of length $n$:

1. enumerate the $2^n$ binary states;
2. update each state according to the chosen rule, with indices taken modulo $n$;
3. retain the states satisfying $F_R(s)=s$;
4. compare fixed-point counts across rules and ring sizes;
5. derive each rule’s algebraic normal form by a Möbius transform of its truth table.

For Rule 0, this experiment always returns one fixed state. For Rule 204, it returns $2^n$. For Rule 110, it returns at least the zero state but excludes the all-one state. These are not merely numerical patterns: they are consequences of exact local identities and therefore hold for every ring length as well as for the bi-infinite line.

The next step is a systematic census of all $256$ rules and many periods. Yet fixed-point count should be treated as one coordinate in a larger complexity profile, not as a universal ranking. The profile might include growth rates of periodic solutions, cycle lengths, transient depths, sensitivity to perturbations, polynomial degree, and invariants of spacetime constraint systems.

## The larger idea

Elementary cellular automata sit at a rare crossroads. They are discrete dynamical systems, Boolean circuits, symbolic shifts, polynomial maps over finite fields, and generators of spacetime geometry. Each language illuminates a different feature. The polynomial for Rule 110 compresses eight cases into four monomials. The fixed-point equations turn stability into an algebraic set. The comparison of Rules 0, 204, and 110 then draws a sharp conceptual boundary.

Algebraic geometry can organize the stationary configurations of cellular automata. It can reveal interaction terms, formulate constraint varieties, and support exact counting algorithms. But the richness of a computation is not captured by how many states refuse to move. Rule 204 owns every state as a fixed point and does nothing; Rule 110 fails to fix even the uniform one-state and can nevertheless compute.

That contrast is the real discovery. The geometry of stillness is valuable, but computation lives in motion. A successful Grothendieck-style theory of cellular automata will therefore need not only the variety of fixed points, but a geometry of histories: an algebraic account of signals traveling, colliding, persisting, and transforming through time.