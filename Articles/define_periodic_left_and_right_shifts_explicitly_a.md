# The Arithmetic of Standing Still

## What a cellular automaton's frozen patterns can — and cannot — tell you

### A row of lamps

Imagine a circular corridor lined with $n$ lamps, each either on or off. Every second, each lamp looks at itself and at its two immediate neighbours — three bits of information — and decides, according to a fixed rulebook, whether to be on or off in the next second. All lamps update simultaneously. That is the whole of an *elementary cellular automaton*.

The rulebook is small: there are $2^3 = 8$ possible neighbourhood patterns, and for each one the rulebook prescribes a single output bit. So there are $2^8 = 256$ rulebooks in total, and by long convention each is named by the number whose binary digits are those eight outputs. Rule $110$, Rule $30$, Rule $184$, Rule $90$: these are the celebrities of a very small universe.

They are celebrities for good reason. Rule $110$ is *computationally universal*: with the right initial arrangement of lamps, its evolution simulates any computation whatsoever, so predicting its distant future is as hard as any problem in mathematics. Rule $30$ looks like static — its patterns pass statistical tests for randomness well enough that they were once used as a random-number generator. Rule $184$ is the physicists' toy model of traffic: read $1$ as "a car here" and $0$ as "empty road", and the rule makes each car advance exactly when the space ahead is free, producing jams that drift backwards through forward-moving traffic, exactly as real jams do.

This article is about the *simplest* question one can ask of such a system, asked with unusual insistence: **which arrangements of lamps do not change at all?**

Call such an arrangement a *still life*, or, more formally, a fixed configuration: a state $s$ with $F(s) = s$, where $F$ is the global one-second update. We write $\#V(g,n)$ for the number of still lifes of the rule $g$ on the circle of $n$ lamps. The question is deceptively finite — for each $n$ there are only $2^n$ arrangements to check — but the honest question is about *all* $n$ at once, and that is not a finite question at all. It turns out to have clean, complete, and rather surprising answers.

---

### The still lifes of the universal rule: there is exactly one

Rule $110$'s rulebook, written over the two-element field $\mathbb{F}_2 = \{0,1\}$ where addition is XOR, is
$$g_{110}(a,b,c) = b + c + bc + abc,$$
where $a$, $b$, $c$ are the left neighbour, the cell itself, and the right neighbour.

**Theorem (Rule 110 Singleton Theorem).** *On the circle of $n$ lamps, for every $n \ge 1$, Rule $110$ has exactly one fixed configuration: all lamps off.*

For a universal rule — one that can, in principle, simulate a chess engine or a weather model — this austerity is startling. But the proof is a single observation, repeated around the circle.

Look at the rulebook restricted to a cell that is currently off: setting $b = 0$ gives $g_{110}(a,0,c) = c$. So if a lamp is off *and stays off*, its right-hand neighbour must be off too. Off-ness propagates rightwards, one step per lamp. Since the corridor is a circle, following the propagation all the way around forces every lamp off — provided some lamp was off to begin with. And some lamp must be, because the all-on configuration is not fixed: $g_{110}(1,1,1) = 1+1+1+1 = 0$ over $\mathbb{F}_2$, so a fully lit circle goes dark in one second. Hence every still life contains an off lamp, that lamp forces its neighbour off, and the wave sweeps the circle. Only darkness survives.

What is worth noticing is that the argument never mentions Rule $110$ except through three entries of its rulebook. Abstract those, and you get a criterion:

**Theorem (Local Singleton Criterion).** *Suppose a rulebook $g$ satisfies (i) $g(a,0,c) = 0$ implies $c = 0$, for all $a,c$; (ii) $g(1,1,1) \ne 1$; (iii) $g(0,0,0) = 0$. Then on every circle of $n \ge 1$ lamps the fixed configurations of $g$ are exactly $\{\,\text{all off}\,\}$, so $\#V(g,n) = 1$ for all $n$.*

Which rulebooks pass? Condition (i) turns out to constrain only two table entries, and the criterion in total is equivalent to four bits of the rule number being pinned: the outputs on $000$, $001$, $101$ and $111$ must be $0$, $1$, $1$, $0$ respectively. The other four bits are free. So **exactly $16$ of the $256$ elementary rules are certified, in one stroke and for all lattice sizes at once, to have precisely one still life.** Rule $110$ is one of them. So is Rule $46$ — which Wolfram places in a different qualitative class entirely.

That coincidence is the first shot fired in this article's real argument, so let us name it: *no statistic built from fixed-point counts can ever separate Rule $46$ from Rule $110$*, because they agree in all four of the bits that decide the count, for every $n$. If you hoped that counting still lifes would detect computational universality, this is where the hope dies.

---

### Symmetry triples the harvest

Every elementary rulebook has three siblings. **Reflection** reads the neighbourhood right-to-left: $(\text{mirror } g)(a,b,c) = g(c,b,a)$. **Complementation** swaps the roles of "on" and "off" everywhere: $(\text{dual } g)(a,b,c) = 1 + g(1+a, 1+b, 1+c)$. Each operation is an involution, and they commute, so together they generate a Klein four-group acting on the $256$ rules.

Crucially, these are not just relabellings of tables. Reflecting the *lamps* through a point of the circle, $(\rho s)(i) = s(-i)$, satisfies
$$F_{\text{mirror } g}(\rho s) = \rho(F_g(s)),$$
and complementing every lamp, $(\kappa s)(i) = 1 + s(i)$, satisfies $F_{\text{dual }g}(\kappa s) = \kappa(F_g(s))$. In the language of dynamics, these are *conjugacies*: the two systems are the same system seen through a change of coordinates. Everything a dynamicist cares about therefore transfers verbatim. The number of still lifes is one such invariant:
$$\#V(\text{mirror } g, n) = \#V(\text{dual } g, n) = \#V(g,n) \quad \text{for every } n.$$
So is the *exact* period of every individual orbit, not merely which periods occur.

The payoff is immediate. Closing the $16$ certified rules under the four-group produces **$48$ rules with provably exactly one still life on every circle** — three times what the local criterion sees by itself. Rule $110$'s three siblings are Rules $124$, $137$ and $193$, and each inherits the Singleton Theorem even though none of them passes the local test. Rule $124$, for instance, propagates off-ness *leftwards*; the criterion, being one-handed, is blind to it, but the conjugacy is not.

---

### Counts that are genuinely arithmetic

So far all the counts have been the constant $1$. Other rules are more interesting: their still-life counts depend on the *number theory of $n$*.

Rule $150$ is the "sum of three neighbours" rule, $g(a,b,c) = a+b+c$ over $\mathbb{F}_2$. Rule $90$ is "sum of the two outer neighbours", $g(a,b,c) = a+c$. Both are linear, and their fixed-point equations are linear recurrences over $\mathbb{F}_2$. Rule $150$'s fixed-point equation $a+b+c = b$ says $a = c$: the configuration is $2$-periodic. Rule $90$'s equation $a+c = b$ is the Fibonacci recurrence over $\mathbb{F}_2$, whose period is $3$.

That periodicity is the whole story, once one has the right general principle.

**Theorem (Periodic Descent).** *Let $d \mid n$. The pullback map that turns a configuration on the small circle of $d$ lamps into a $d$-periodic configuration on the big circle of $n$ lamps is injective and commutes with the dynamics of every rule. Consequently: (a) $\#V(g,d) \le \#V(g,n)$ for every rule $g$ and every $d \mid n$; (b) if in addition every fixed configuration on the big circle happens to be $d$-periodic, then $\#V(g,n) = \#V(g,d)$ exactly; (c) each configuration and its pullback have the identical exact orbit period.*

Descent converts an infinite family of counting problems into a *single finite check*. And there is a complementary trick for the sizes that descent does not reach: if $d$ is invertible modulo $n$ — which happens exactly when $\gcd(d,n) = 1$ — then "$d$-periodic" degenerates to "constant", and constancy is easy to analyse by hand.

Put together, one gets exact formulas valid for all $n$ simultaneously:

$$\#V(150, n) = \begin{cases} 4 & n \text{ even} \\ 2 & n \text{ odd}\end{cases} \qquad \#V(90, n) = \begin{cases} 4 & 3 \mid n \\ 1 & \text{otherwise}\end{cases} \qquad \#V(30, n) = \begin{cases} 3 & n \text{ even} \\ 1 & n \text{ odd}\end{cases}$$

The Rule $30$ case is the pretty one, because Rule $30$ is *not* linear: $g_{30}(a,b,c) = a+b+c+bc$. Its fixed-point equation is $s_{i-1} + s_{i+1} + s_i s_{i+1} = 0$, and a short case analysis on whether $s_{i+1}$ is on or off — the interesting branch forces two neighbouring lamps off — still yields $2$-periodicity. So Wolfram's poster child for chaos has a still-life count as tame and as periodic as any linear rule's: $3$ on even circles, $1$ on odd ones.

Notice what these formulas record. The counts are periodic in $n$ with periods $3$, $2$, $2$ — precisely the periods of the recurrences that cut out the fixed-point sets. **The still-life count remembers the period of the recurrence attached to the rule, and nothing about the rule's dynamical richness.**

---

### Traffic jams, and a count of exactly two

Rule $184$, the traffic rule, plays by a different and pleasingly symmetric logic. Decoding its table gives two implications: $g(a,0,c) = 0$ forces $a = 0$, and $g(a,1,c) = 1$ forces $c = 1$. In words: *emptiness travels leftwards, cars travel rightwards*. Abstracting them gives a second criterion, whose conclusion is a pair rather than a point.

**Theorem (Constant-Pair Theorem).** *Suppose a rulebook satisfies: $g(a,0,c)=0 \Rightarrow a=0$; $g(a,1,c)=1 \Rightarrow c=1$; $g(0,0,0)=0$; and $g(1,1,1)=1$. Then on every circle the fixed configurations are exactly the two constant ones — all off and all on — so $\#V(g,n) = 2$ for all $n$.*

The argument mirrors the singleton proof but runs in both directions: if some lamp is off, leftward propagation empties the whole circle; if no lamp is off, the configuration is all on, which is fixed. Exactly **four** rules pass: $176$, $178$, $184$ and $186$. Together with the $48$ certified by the symmetry-closed singleton criterion, that is $52$ of the $256$ rules whose still-life count is known for every circle size by proof rather than by enumeration.

For the traffic interpretation this is exactly right: an empty road and a bumper-to-bumper jam are the only two stationary traffic states on a ring road, at every ring size. Everything else moves.

---

### Still lifes are the wrong invariant — here is a better one

The moral tightens once one looks past fixed points. A fixed configuration is an orbit of period $1$; the natural object is the whole *orbit spectrum*, the multiset of exact periods.

Rule $51$, which simply complements every lamp, has **no** still lifes at all on any nonempty circle, yet every single configuration lies on an orbit of exact period $2$. Rule $170$, the pure left shift, has as its still lifes only the two constant configurations, yet the "one lamp on" configuration has exact period $n$ — so orbit lengths grow without bound while the fixed-point count stays flat at $2$. And a pigeonhole argument on the finite state space shows that *every* elementary rule has some periodic orbit on every circle, whatever its still-life count.

Rule $110$ is the decisive example. Its still-life count is the constant $1$. But on the circle of four lamps the configuration $1110$ is not fixed and returns to itself after two seconds; its exact period is $2$. Periodic descent then transports it: **Rule $110$ has a configuration of exact period two on every circle whose size is divisible by $4$**, and that configuration is never the all-off one. The one-point still-life variety of the universal rule sits inside a genuinely nontrivial orbit structure — and the $1110$ two-cycle is, recognisably, the smallest glider-like object of Rule $110$, the seed of the mechanism that makes it universal.

So a final tally of separations. The still-life statistic distinguishes Rule $90$ from Rule $110$ exactly on the multiples of $3$ and nowhere else. It distinguishes Rule $150$ from Rule $110$ at every size, and the traffic rule $184$ from Rule $110$ at every size. But it never distinguishes Rule $110$ from Rule $46$, or from the other fifteen members of its census, or from its three symmetry siblings. Universality leaves no trace in the count of things that stand still.

---

### An algebraic coda

There is a way to make all of this algebra rather than combinatorics. A configuration on $n$ lamps is a point of $\mathbb{F}_2^n$, and the local rule can be written as an honest polynomial: for each site $i$ there is a polynomial $P_i$ in the variables $x_0, \dots, x_{n-1}$, built from the $\mathbb{F}_2$ interpolation identity $\prod (1 + a + x) $, with the property that evaluating $P_i$ at a configuration returns exactly the next value of lamp $i$. Translating the variables by $i$ carries $P_0$ to $P_i$ — shift-equivariance, at the level of polynomials.

The still lifes are then the $\mathbb{F}_2$-points of an ideal: the one generated by the update equations $P_i - x_i$ together with the Boolean relations $x_i^2 - x_i$ that force the coordinates to be bits. For Rule $110$ this ideal is proper — the coordinate ring of its fixed-point scheme is not the zero ring — because the all-off configuration is a point of it. Every counting theorem above is, in this language, a statement about the number of rational points of an explicit affine scheme over $\mathbb{F}_2$, and the "arithmetic in $n$" of the counts becomes the arithmetic of a variety whose defining equations depend on $n$ only through the cyclic index group.

That reframing is what makes the results feel inevitable rather than accidental. And it suggests the sharpest open question in the subject. The still lifes of a rule are precisely the closed walks of length $n$ in a four-vertex graph — the de Bruijn graph on overlapping pairs of lamps, with an edge $(a,b) \to (b,c)$ kept exactly when $g(a,b,c) = b$. Hence $\#V(g,n)$ is the trace of the $n$-th power of a $4 \times 4$ matrix of zeros and ones. Everything above is, in retrospect, spectral: constant count $1$ means the matrix has a single eigenvalue on the unit circle and nothing else contributing; a count periodic with period $3$ means primitive cube roots of unity in the spectrum.

Enumeration shows that exactly $78$ rules have still-life count $1$ for all sizes up to $7$; $48$ of these are certified for all $n$ by the symmetry-closed criterion above. It is conjectured that the small-size check is already conclusive — that a rule with a unique still life on circles of size $1$ through $7$ has a unique still life on every circle — leaving precisely $30$ rules whose unit count demands a non-local, spectral argument. A graph on four vertices, a matrix of zeros and ones, and a question still open. Small universes are not always small.
