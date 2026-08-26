# The Shape of a Cellular Automaton

*What happens when you ask an algebraic geometer to measure the complexity of Wolfram's rules — and the answer comes back "one point"*

---

## A universe on a strip of paper

Draw a row of cells. Colour each one black or white. Now fix a rule: the new colour of a cell depends only on its own colour and the colours of its two immediate neighbours. Apply the rule to every cell at once, print the new row underneath the old one, and repeat.

That is an *elementary cellular automaton*. There are exactly $256$ of them, because a rule is nothing more than a choice of output colour for each of the $2^3 = 8$ possible three-cell neighbourhoods, and $2^8 = 256$. Stephen Wolfram numbered them $0$ through $255$ by reading the eight outputs as an eight-bit binary number, and the names stuck: Rule 30, Rule 90, Rule 110.

The startling thing about this list of $256$ toys is how wildly their behaviour varies. Rule 0 blanks the paper on the first step and never does anything again. Rule 90 draws the Sierpiński triangle. Rule 30 produces a stream of black and white cells so statistically featureless that it was used for decades as a random-number generator. And Rule 110 — a rule you can describe to a child in one sentence — is a universal computer: given the right initial row, it can simulate any algorithm whatsoever.

Wolfram famously sorted the $256$ rules into four qualitative classes: **Class 1**, which die into uniformity; **Class 2**, which settle into stripes and blinkers; **Class 3**, which boil chaotically forever; and **Class 4**, the rarest and strangest, in which localised "gliders" drift across a patterned background and collide in intricate ways. Class 4 is where universal computation lives. Rule 110 is its flagship.

The classification is famous, useful — and stubbornly informal. It is a taxonomy by eyeball. Nobody has ever written down a formula that takes a rule number and returns its class, and there are excellent reasons (the undecidability of almost everything about Rule 110) to expect that nobody ever will, at least not in any simple form. So the obvious dream persists: *find a clean algebraic invariant that recovers Wolfram's classes.*

This article is the story of one such dream, and of exactly how it dies.

## Rules are polynomials

Here is the observation that starts everything. Replace "white" with $0$, "black" with $1$, and work in the field $\mathbb{F}_2 = \{0,1\}$, where addition is exclusive-or ($1+1=0$) and multiplication is the logical AND. Every function from $\mathbb{F}_2^3$ to $\mathbb{F}_2$ — that is, every one of the $256$ rules — is then given by a *unique* polynomial in three variables $l, c, r$ (for left, centre, right) in which no variable ever appears squared. The reason is simple: over $\mathbb{F}_2$ we have $x^2 = x$, so nothing beyond the eight monomials
$$1,\quad l,\quad c,\quad r,\quad lc,\quad lr,\quad cr,\quad lcr$$
can survive, and eight coefficients over $\mathbb{F}_2$ is exactly $256$ possibilities.

So the $256$ automata are not merely $256$ lookup tables. They are the $256$ multilinear cubic polynomials over the two-element field. For instance:

- Rule 0 is $f = 0$.
- Rule 204, which copies each cell to itself, is $f = c$.
- Rule 90, the Sierpiński rule, is $f = l + r$.
- Rule 150 is $f = l + c + r$.
- Rule 30, the chaotic one, is $f = l + c + r + cr$.
- Rule 232, "majority vote", is $f = lc + lr + cr$.
- And Rule 110, the universal computer, is
$$f_{110}(l,c,r) \;=\; c + r + cr + lcr .$$

Of the $256$ rules, $128$ have degree exactly $3$, $112$ have degree $2$, $14$ are affine-linear and $2$ are constant.

Now put $n$ cells on a circle, so that a configuration is a point $s = (s_0, \dots, s_{n-1})$ of the affine space $\mathbb{A}^n$ over $\mathbb{F}_2$, and one time step is the polynomial map
$$s \;\longmapsto\; \bigl(f(s_{i-1}, s_i, s_{i+1})\bigr)_{i \in \mathbb{Z}/n} .$$
A cellular automaton has become a morphism of affine spaces. And the moment you have a polynomial map, algebraic geometry offers you its most basic invariant for free: the *variety* cut out by the equations you care about.

## The fixed-point variety

The equations one obviously cares about are the ones saying that nothing changes. Call
$$V(f, n) \;=\; \{\, s \in \mathbb{F}_2^n \;:\; f(s_{i-1}, s_i, s_{i+1}) = s_i \ \text{ for all } i \,\}$$
the **fixed-point variety** of the rule: the zero locus of $n$ cubic equations in $n$ unknowns, the set of configurations the automaton leaves alone forever.

This is a real geometric object, and it comes with real structure. It is invariant under rotating the circle, so it is not an arbitrary subset of $\mathbb{F}_2^n$ but a *cyclic subshift of finite type* — a set of cyclic words defined by which three-letter windows are permitted. When the local polynomial happens to be linear (which occurs for exactly eight rules: $0, 60, 90, 102, 150, 170, 204, 240$), the variety is the kernel of a circulant matrix and hence an honest linear subspace, with an honest dimension $\dim V(f,n)$, and $|V(f,n)| = 2^{\dim V(f,n)}$.

And now the dream can be stated. Rule 0 kills everything; its variety is the single point $0$, dimension $0$. Rule 204 changes nothing; its variety is all of $\mathbb{A}^n$, dimension $n$. Between these two extremes there is a whole scale of dimensions from $0$ to $n$ — and there is a whole scale of Wolfram classes from $1$ to $4$. Surely they match? The conjecture writes itself:

> **The Dimension Conjecture.** For a Class 1 rule, $\dim V(f,n) = 0$; for Class 2, $\dim V(f,n) \le n/2$; for Class 3, $\dim V(f,n) \ge n/2$; and for the universal Class 4 rules, $\dim V(f,n) = n$. Complexity is dimension.

It is a beautiful idea. If it were true, one could compute Wolfram's classification with linear algebra, and the mystery of Rule 110 would reduce to counting solutions of a polynomial system.

It is false. Not marginally false, not false-except-for-edge-cases — false in four logically independent ways, each one of which is fatal on its own.

## Failure one: Rule 110 is rigid

Write out the fixed-point condition for Rule 110. Stationarity says $f_{110}(l,c,r) = c$, and since $f_{110} = c + r + cr + lcr$, subtracting $c$ leaves
$$r\,(1 + c + lc) = 0 .$$
This is a startlingly tight constraint. Over $\mathbb{F}_2$ the factor $1 + c + lc$ vanishes exactly when $c = 1$ and $l = 0$. So a three-cell window is stationary **if and only if** either its right cell is $0$, or its centre is $1$ and its left is $0$.

Now suppose some cell $s_i$ equals $1$, and look one step to the left, at the window centred at $i-1$. Its right cell is $s_i = 1$, not $0$, so the second alternative must hold: $s_{i-1} = 1$ and $s_{i-2} = 0$. Fine. But now look one step further left, at the window centred at $i-2$. *Its* right cell is $s_{i-1} = 1$, again not $0$, so again the second alternative must hold — forcing $s_{i-2} = 1$. And we have just proved $s_{i-2} = 0$.

Contradiction. There is no cell carrying a $1$.

> **Theorem (Rigidity of Rule 110).** For every ring size $n$, and also for the bi-infinite line, the only configuration fixed by Rule 110 is the all-zero configuration. That is, $V(f_{110}, n) = \{0\}$.

The argument is two lines long, entirely local, and completely uniform in $n$: no induction on the circle, no case analysis on parity, nothing. The Turing-complete automaton, the one that can simulate any computer that will ever be built, has a fixed-point variety consisting of a **single point** — precisely the same variety as Rule 0, the rule that does nothing at all.

The consequence is not that the Dimension Conjecture predicted the wrong number. It is far worse:

> **Theorem (Total blindness).** $V(f_{110}, n) = V(f_0, n)$ for every $n$. Consequently, *any* property whatsoever of the fixed-point variety — its dimension, its cardinality, its scheme structure, its sheaf of sections, its cohomology — holds for Rule 110 if and only if it holds for Rule 0.

No invariant of $V$, however sophisticated, can ever distinguish a universal computer from a rule that erases the tape. This closes not just one conjecture but an entire genre of them.

The rigidity is also not a coincidence of one rule number. The $256$ rules carry a natural symmetry group of order four, generated by *reflection* (swap left and right) and *colour inversion* (swap black and white); Wolfram's classes are constant on the orbits. The fixed-point variety turns out to transform covariantly: reflecting the rule reflects the variety, inverting the colours translates the variety by the all-ones configuration. Rule 110's orbit is $\{110, 124, 137, 193\}$, and covariance immediately gives $V(f_{124}) = \{0\}$, $V(f_{137}) = \{1\}$, $V(f_{193}) = \{1\}$. The entire universal orbit has a one-point variety.

## Failure two: maximal dimension means *nothing happens*

The conjecture's boldest clause is the Class 4 prediction $\dim V = n$, i.e. that the variety fills the whole space. Which rules actually do that? All of them, exactly one.

> **Theorem (Maximality classifies triviality).** Fix $n \ge 3$. Among the $256$ elementary rules, $V(f,n)$ is all of $\mathbb{A}^n$ — equivalently $\dim V(f,n) = n$ — if and only if the rule is Rule 204, the identity.

The proof is a two-step affair. First, on a circle of three or more cells, any prescribed three-cell window occurs in some configuration; so if every configuration is stationary, the local polynomial must satisfy $f(l,c,r) = c$ for all eight inputs, i.e. it must be the centre projection. Second, reading off the eight bits of the truth table of the centre projection gives exactly the binary number $11001100 = 204$.

So "maximal dimension" is not a certificate of maximal complexity. It is a certificate of *no dynamics whatsoever* — the automaton that sits perfectly still. The conjecture had the scale exactly upside down.

## Failure three: usually there is no dimension at all

Talking about $\dim V$ presupposes that $V$ *has* a dimension: that it is a linear subspace, or at the very least a translate of one (an affine subvariety). For most rules it is neither, and there are two independent reasons.

The first is trivial once noticed. A linear subspace contains the origin, and the all-zero configuration is stationary exactly when the rule maps the all-white neighbourhood to white — that is, exactly when the rule number is **even**. So for all $128$ odd rules, on every ring size, the fixed-point variety misses the origin and is not a linear subspace.

The second reason is a counting argument of Lagrange type. If $V$ is an affine subvariety — a translate $v + W$ of a linear subspace $W$ of $\mathbb{F}_2^n$ — then $|V| = |W|$, and $W$ is a subgroup of the additive group $\mathbb{F}_2^n$ of order $2^n$, so $|V|$ must divide $2^n$: it must be a power of two. Any rule whose stationary configurations number something else has a locus that is not affine, hence carries no dimension in any reasonable sense.

This happens constantly. The majority rule (Rule 232) has exactly $6$ stationary configurations on the ring of size $4$ — the two constants and four domain-wall patterns — and $6$ is not a power of two. Rule 45 has exactly $3$ on the ring of size $3$. On the ring of size $6$, an exhaustive check shows that only $91$ of the $256$ rules have a fixed-point variety that is a linear subspace at all.

## Failure four: Rule 30's three points, forever

The sharpest version of the third failure comes from the most celebrated chaotic rule of all. Rule 30 is $f = l + c + r + cr$, so its stationarity equation is $l + r + cr = 0$, which decomposes into two crisp implications:
$$s_i = 0 \implies s_{i-1} = s_{i+1}, \qquad\qquad s_i = 1 \implies s_{i-1} = 0 .$$
Either way, knowing two consecutive cells determines the next; chasing the implications shows that **every stationary configuration of Rule 30 has spatial period two**. The rest is arithmetic. On a circle of odd size, a period-two pattern is forced to be constant, and among the constants only all-white is stationary. On a circle of even size, period-two patterns come in exactly four flavours — all-white, all-black, and the two alternating waves $0101\ldots$ and $1010\ldots$ — and all-black fails the equation.

> **Theorem (Rule 30's locus).** For odd $n$, $V(f_{30}, n) = \{0\}$. For even $n \ge 2$, $V(f_{30},n)$ consists of exactly three configurations: the all-white configuration and the two alternating waves.

Three is never a power of two. So on *every even ring simultaneously*, the fixed-point locus of the canonical chaotic automaton is not an affine subvariety and has no dimension. What began as a lucky counterexample at one ring size becomes an infinite family — and it strikes the very rule the conjecture placed at $\dim \ge n/2$.

## What the variety actually measures

If the fixed-point variety is not measuring complexity, what *is* it measuring? The additive rules answer that question cleanly, because for them the variety really is a linear subspace and one can compute.

Rule 90 is $f = l+r$, so stationarity reads $s_{i-1} + s_i + s_{i+1} = 0$, i.e. $s_{i+1} = s_{i-1} + s_i$: a two-term linear recurrence over $\mathbb{F}_2$ whose characteristic polynomial $x^2 + x + 1$ has roots of multiplicative order three. Every stationary configuration therefore has spatial period three, and when $3$ is invertible modulo $n$ that period collapses to period one, forcing the configuration to be constant — and then the equation $s+s+s = 0$ forces it to be zero.

> **Theorem (Rule 90's mod-3 dichotomy).** If $3 \nmid n$ then $V(f_{90},n) = \{0\}$. If $3 \mid n$ then $V(f_{90},n)$ also contains the period-three wave $011011\ldots$ and so is strictly larger. In all cases $\dim V(f_{90},n) \le 2$.

The dimension cap comes from a general principle worth isolating: if a stationary configuration is determined by its values at two seed cells — as it is whenever the stationarity relation is a two-term recurrence — then the variety injects linearly into a plane, so its dimension is at most $2$, no matter how enormous $n$ is. Rule 90 is Wolfram Class 3 and so should have had $\dim \ge n/2$; instead it is stuck at $2$ forever.

Rule 45, also Class 3, does something even less compatible with an $n$-independent classification:

> **Theorem (Rule 45's existence criterion).** $V(f_{45},n)$ is non-empty if and only if $3 \mid n$. When $3 \mid n$ it contains the pulse train $100100\ldots$.

So this rule's fixed-point variety is *empty* two thirds of the time. Its "class" would have to depend on the size of the circle. Rule 150, $f = l+c+r$, tells the same story one prime down: stationarity says $s_{i-1} = s_{i+1}$, the variety is the space of period-two configurations, and so it equals $\{0, 1\}$ (dimension $1$) for odd $n$ and jumps to four elements (dimension $2$) for even $n$.

The pattern is unmistakable. The fixed-point variety of an elementary cellular automaton is a **number-theoretic** object. Its size is governed by $n$ modulo a small integer determined by the order of the roots of a characteristic polynomial — three for Rules 90 and 45, two for Rules 30 and 150. A Wolfram class is a property of the rule alone, blind to $n$. These two things cannot possibly be equal, and now we know precisely why.

There is an appealing structural reason behind all of this. Stationary configurations on a circle of size $n$ are exactly the closed walks of length $n$ in a four-vertex graph: the vertices are the possible pairs $(s_{i-1}, s_i)$, and an arrow runs from $(a,b)$ to $(b,c)$ precisely when the window $(a,b,c)$ is stationary. Counting closed walks of length $n$ in a graph is counting the trace of the $n$-th power of its adjacency matrix, so one expects
$$|V(f,n)| \;=\; \operatorname{tr}\bigl(T_f^{\,n}\bigr)$$
for a $4 \times 4$ matrix of zeros and ones read directly off the rule's truth table. Exhaustive computation confirms this for all $256$ rules and all ring sizes up to $12$. It explains everything we have seen: the counts obey a linear recurrence of order at most four, so they are eventually periodic modulo any modulus and are governed by the eigenvalues of a tiny integer matrix — a spectrum with four numbers in it cannot possibly encode the undecidable question of whether a rule is universal.

## Where complexity actually lives

Is the whole algebraic-geometric programme therefore doomed? No — the diagnosis points straight at the cure. The fixed-point variety fails because it looks at a single instant of time. Complexity is not a property of the automaton's stationary states; it is a property of its *orbits*. So climb one level up and consider, for each $k \ge 1$, the **temporal variety**
$$\mathrm{Per}_k(f,n) \;=\; \{\, s \;:\; f^{\,k}(s) = s \,\},$$
the zero locus of the $k$-fold composite — a polynomial map of degree $3^k$. The bottom of this tower, $\mathrm{Per}_1$, is the old fixed-point variety; the whole tower is the sequence of coefficients of the dynamical zeta function.

The tower is genuinely structured. If a configuration returns to itself after $k$ steps and after $\ell$ steps, then it returns after $\gcd(k,\ell)$ steps — a small exercise in the Euclidean algorithm — which says exactly that
$$\mathrm{Per}_k(f,n) \cap \mathrm{Per}_\ell(f,n) \;=\; \mathrm{Per}_{\gcd(k,\ell)}(f,n) .$$
The levels form a lattice indexed by divisibility, and the automaton acts *bijectively* on each level, with inverse $f^{k-1}$.

And it does the job the fixed-point variety could not. For Rule 0, every level of the tower collapses to the single point $0$. For Rule 110 it does not: on the ring of size four the configuration $1110$ maps to $1011$ and back, an honest two-cycle. Hence
$$\mathrm{Per}_1(f_{110},4) = \mathrm{Per}_1(f_0,4) = \{0\}, \qquad \mathrm{Per}_2(f_{110},4) \ne \mathrm{Per}_2(f_0,4),$$
and the tower separates the universal rule from the null rule at the very first opportunity.

A caution comes with the cure, and it is instructive. $\mathrm{Per}_2(f_{110},4)$ has exactly five points — the origin plus a single two-cycle's worth of four rotations — and five does not divide sixteen. So the repaired invariant is not a *dimension* either. Whatever measures the complexity of a cellular automaton, it is a counting function, not a dimension: something like a zeta function $\zeta_f(t) = \exp\bigl(\sum_k |\mathrm{Per}_k| \, t^k / k\bigr)$, whose growth rate is the topological entropy, rather than a single integer read off a linear space.

## The moral

The failure here is not "the dimension approximately tracks the class". It is total: the variety of the universal rule is literally identical to the variety of the rule that does nothing. And the reason is structural. The fixed-point variety of an elementary cellular automaton is a subshift of finite type on four states, and four states cannot hold a universal computer; its point counts are traces of powers of a $4 \times 4$ integer matrix, and such sequences are as far from undecidable as a sequence can be.

The lesson generalises well beyond these $256$ toys. An invariant of a dynamical system that ignores time can only see time-independent things. If you want to see computation, you must look at trajectories — at the whole tower $\mathrm{Per}_1 \subseteq \mathrm{Per}_2 \subseteq \cdots$, at how the counts grow, at the zeta function. The single snapshot, no matter how elegantly you geometrise it, will always show you a still photograph of a machine standing still.

And there is a consolation prize. Along the way, the fixed-point loci of some of the most famous automata in the subject have been determined completely, for all ring sizes at once: Rule 110 and its whole universal orbit fix exactly one configuration; Rule 30 fixes three on even circles and one on odd; Rule 90 sees the prime $3$; Rule 45 exists only when $3$ divides $n$; Rule 150 sees the prime $2$; and Rule 204 alone fills the space. These are small, exact, permanent facts about objects that usually resist exact statements — and each was uncovered while chasing an idea that turned out to be wrong.
