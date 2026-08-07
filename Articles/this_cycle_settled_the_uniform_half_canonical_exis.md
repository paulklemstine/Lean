# The Dollar Game on a Round Table

*How a two-hundred-year-old identity about floor functions pins down, exactly, how much debt a crowded graph can absorb — and why the answer doesn't care how many people are at the table.*

---

## A game with chips

Sit $n$ people around a table. Everybody is connected to everybody else — it is that kind of table. Each person holds some number of chips, and, crucially, that number is allowed to be **negative**: you can be in debt.

There is exactly one legal move. A person may *fire*: hand one chip to each of their neighbours. At a round table of $n$ people that costs them $n-1$ chips and enriches everyone else by one. A person may also *borrow*, which is the same move run backwards: take one chip from each neighbour.

This is Biggs's **dollar game**, and the question is the obvious one: starting from a given distribution of chips and debts, can the group fire and borrow its way to a state in which **nobody is in debt**?

The answer depends on the arrangement, not just on the total. With four people holding $(-1,0,1,2)$ — a net of two chips in the room — no sequence of moves will ever clear the debt. With four people holding $(-1,0,1,3)$, one chip richer, it can be done immediately.

That razor-thin boundary is the subject of this article. It turns out to be governed by a formula of startling economy, and behind that formula lies a piece of mathematics that Riemann would have recognised: a theory of divisors, genus, and canonical classes for graphs, developed by Matthew Baker and Serguei Norine, in which a finite graph behaves uncannily like an algebraic curve.

## From chips to divisors

Write a chip configuration as a **divisor**: an assignment $D$ of an integer $D(v)$ to each vertex $v$ of a graph $G$. Its **degree** is the total number of chips, $\deg D = \sum_v D(v)$, and it is **effective** — debt-free — when $D(v) \ge 0$ everywhere.

Firing a set of vertices changes $D$ by adding a vector of the shape
$$(Lf)(v) = \deg_G(v)\, f(v) - \sum_{u \sim v} f(u),$$
where $f(v)$ counts how many times $v$ fired. This $L$ is the graph Laplacian, and two divisors that differ by such a vector are called **linearly equivalent**, written $D \sim D'$. The dollar game asks: *is $D$ linearly equivalent to an effective divisor?*

Baker and Norine turned this yes/no question into a number. The **rank** $r(D)$ measures not just whether $D$ can be rescued, but how much extra adversity it can survive:

> $r(D) \ge r$ means: **no matter** which $r$ chips an adversary removes from the table — all from one person, or scattered however they like — the remaining configuration can still be fired into a debt-free state.

If $D$ cannot even be rescued as it stands, $r(D) = -1$. So the rank is a measure of *robustness*: the depth of the crisis the configuration can absorb.

There is a third player in the story, the **genus**
$$g = |E| - |V| + 1,$$
the number of independent cycles in the graph. And there is a canonical configuration $K(v) = \deg_G(v) - 2$, of degree $2g-2$. With these, Baker and Norine proved a theorem that is word-for-word the Riemann–Roch theorem of algebraic geometry:
$$r(D) - r(K - D) = \deg D - g + 1.$$

A graph, it turns out, has a genus, a canonical class, and a Riemann–Roch theorem. The dictionary is not an analogy; it is an equality of formulas.

## The round table collapses the problem

Riemann–Roch is powerful but it never tells you a rank outright — it relates two unknown ranks. Computing a Baker–Norine rank exactly is, in general, genuinely hard: the naive definition quantifies over *all* effective divisors of a given degree, an exponentially large set, and the problem is known to be NP-hard for general graphs.

The complete graph is where the fog lifts. On $K_n$ every vertex is adjacent to every other, so the Laplacian collapses:
$$(Lf)(v) = n\,f(v) - \sum_u f(u).$$
Each vertex's fate depends on its own firing count and on one single global number, the total $\sum_u f(u)$. A firing strategy stops being a *sequence* of local moves and becomes a *single* integer vector, with a single scalar coupling all the vertices together.

Chase that observation and you get a criterion of remarkable compactness.

> **Effectivity criterion.** A divisor $D$ on $K_n$ is linearly equivalent to an effective divisor **if and only if** there is an integer $s$ with
> $$\sum_{v} \left\lceil \frac{s - D(v)}{n} \right\rceil \le s .$$

The proof fits in a paragraph, and both directions are the same computation read in opposite orders. Suppose $D + Lf \ge 0$ and put $s = \sum_u f(u)$; then $n f(v) \ge s - D(v)$ for every $v$, so $f(v) \ge \lceil (s - D(v))/n \rceil$, and summing over $v$ gives exactly the inequality. Conversely, given such an $s$, define $f(v) := \lceil (s - D(v))/n \rceil$. Its total $S = \sum_v f(v)$ is at most $s$ by assumption, and then
$$(D + Lf)(v) = D(v) + n f(v) - S \ \ge\ D(v) + \big(s - D(v)\big) - S \ =\ s - S \ \ge\ 0 .$$
So the criterion is not merely a test: the optimal $s$ *hands you the winning strategy*.

Call the best possible slack
$$d(D) = \min_{s \in \mathbb{Z}} \left( \sum_v \left\lceil \tfrac{s - D(v)}{n} \right\rceil - s \right)$$
the **deficiency** of $D$. Then $D$ can be rescued precisely when $d(D) \le 0$. And the deficiency is cheap to compute. Write $\varphi(s)$ for the expression being minimised. Raising $s$ by one increases exactly those ceiling terms whose argument crosses an integer, namely the vertices with $D(v) \equiv s \pmod n$, so
$$\varphi(s+1) - \varphi(s) = \#\{v : D(v) \equiv s \ (\mathrm{mod}\ n)\} - 1 .$$
The increments over a full period of $n$ consecutive shifts sum to $n - n = 0$, so $\varphi$ is $n$-periodic. Bucket the vertices by residue class, evaluate $\varphi$ once, walk one period by prefix sums, and you have the deficiency in time proportional to $n$. A problem that is NP-hard on general graphs has a linear-time solution at the round table.

## Riemann's inequality, out of Hermite's identity

The criterion immediately buys a classical-looking theorem. In algebraic geometry, *Riemann's inequality* says that any divisor of degree at least the genus is equivalent to an effective one. On $K_n$, where $g = \binom{n-1}{2}$, that is:

> **Riemann's inequality on a round table.** Every divisor on $K_n$ of degree at least $g = \frac{(n-1)(n-2)}{2}$ is linearly equivalent to an effective divisor; consequently $r(D) \ge \deg D - g$.

The proof is an averaging argument, and the tool is a two-hundred-year-old identity of Hermite:
$$\sum_{s=0}^{n-1} \left\lfloor \frac{z + s}{n} \right\rfloor = z \qquad \text{for every integer } z .$$
(Read it as: among the $n$ shifted quotients, exactly $z \bmod n$ of them have been rounded up a step, and the rest sit at $\lfloor z/n \rfloor$; the bookkeeping comes out to $z$ on the nose.)

Suppose $D$ could *not* be rescued. Then the criterion fails for every $s$: for $s = 0, 1, \dots, n-1$ we get $\sum_v \lceil (s - D(v))/n \rceil \ge s+1$. Add these $n$ inequalities. On the left, $\sum_{s<n}(s+1) = n(n+1)/2$. On the right, rewrite each ceiling as a floor, $\lceil (s-D(v))/n\rceil = \lfloor (-D(v) + n - 1 + s)/n \rfloor$, swap the order of summation, and let Hermite collapse the inner sum: the right-hand side is exactly $\sum_v (-D(v) + n - 1) = n(n-1) - \deg D$. Rearranged:
$$\deg D \le n(n-1) - \tfrac{n(n+1)}{2} = \tfrac{n(n-3)}{2} = g - 1 .$$
So a divisor of degree $\ge g$ always wins. One identity about floor functions, and Riemann's inequality falls out.

The bound $g$ cannot be lowered by even one. The **staircase** divisor
$$S = (-1, 0, 1, 2, \dots, n-2)$$
— one vertex a single chip in debt, the others holding $0, 1, 2, \dots$ — has degree exactly $g - 1$, and its deficiency is exactly $1$. It is a hair's breadth away from solvable and permanently stuck.

## The main theorem: a rank that ignores the crowd

Now to the central question of this work. Give **every** person at the table the same number of chips, $m$ apiece. How robust is that? Formally: what is the rank of the uniform divisor $m \cdot \mathbf{1}$ on $K_n$?

Two guesses suggest themselves, and both are wrong. You might guess the answer grows with $n$ — after all, there are $mn$ chips in play, and $mn$ grows. Or you might trust Riemann's inequality, which gives $r \ge mn - g$; but $g$ grows quadratically in $n$ while $mn$ grows linearly, so that bound goes negative and becomes worthless for large tables. Before this work, the best unconditional estimates available for uniform configurations were linear in $m$ — bounds like $3m-1$, or $2m + \lfloor m^2/4 \rfloor$ from a cleverer single firing — while the best known ceiling was quadratic. A factor-of-two gap in the leading term.

The gap is now closed.

> **Theorem (exact rank of a uniform divisor).** On the complete graph $K_n$ with $n \ge m+2$, the divisor with $m$ chips at every vertex has Baker–Norine rank exactly
> $$r(m \cdot \mathbf{1}) \;=\; \frac{m(m+3)}{2},$$
> a value **independent of $n$**.

So a uniform holding of $m = 4$ chips per person survives the removal of any $14$ chips — and that is true whether there are $6$ people at the table or six million. Add more people and you add more chips and more genus, and the two effects cancel exactly.

The values are $0, 2, 5, 9, 14, 20, 27, 35, \dots$ for $m = 0, 1, 2, 3, \dots$: the triangular-ish numbers $m(m+3)/2$, growing quadratically where every earlier general-purpose estimate grew linearly. For $m \ge 3$ the truth strictly exceeds $2m + \lfloor m^2/4\rfloor$, the best bound obtainable from a *single* threshold firing — so the theorem also proves that one-shot strategies are genuinely insufficient. You must fire a whole coordinated vector.

### Why the ceiling holds

The upper bound is a single explicit adversary. Let the adversary remove
$$E = (m+1,\ m,\ m-1,\ \dots,\ 1,\ 0,\ 0,\ \dots,\ 0),$$
a staircase of chips totalling $\frac{m(m+3)}{2} + 1$. What remains is
$$m\cdot\mathbf{1} - E = (-1,\ 0,\ 1,\ \dots,\ m,\ m,\ \dots, m),$$
the staircase divisor again, now with a plateau. Its deficiency is exactly $1$: for every shift $s$ in a full period, the count $\#\{v : (m\cdot\mathbf{1}-E)(v) < s\}$ lands exactly one *above* the break-even point. One chip short, forever. So $r(m\cdot\mathbf{1}) \le \frac{m(m+3)}{2}$.

### Why the floor holds

The lower bound is the harder half, and this is where the new idea lives. The adversary hands us an arbitrary effective $E$ of degree $\frac{m(m+3)}{2}$; we must produce a firing vector. Consider, for a **threshold** $t$ ranging over $1, \dots, m$, the quantity
$$T(t) = \sum_v \left\lceil \frac{E(v) - (m-t)}{n} \right\rceil_{\!+} ,$$
the total cost of the firing vector that the criterion would suggest at that threshold. $T$ is increasing in $t$: a more aggressive threshold costs more. What we need is a $t$ that pays for itself, $T(t) \le t$.

Such a $t$ must exist, and the reason is a counting identity. For any single value $a$ and any $m \le n-2$,
$$\sum_{j=0}^{m-1} \left\lceil \frac{a-j}{n} \right\rceil_{\!+} \;=\; m\left\lfloor \frac{a}{n} \right\rfloor + \min\!\left(m,\ a \bmod n\right) \;\le\; a,$$
with **strict** inequality as soon as $a > m$. Summing the hypothetical failures $T(t) \ge t+1$ over all $t = 1, \dots, m$ produces, on one side, $\sum_{j=0}^{m-1}(j+2) = \frac{m(m+3)}{2}$, and on the other, by the identity, something strictly smaller than $\deg E = \frac{m(m+3)}{2}$. The two are incompatible. Some threshold works.

The finishing touch is an observation about *which* threshold to take: choose the **least** $t$ that works. Minimality plus monotonicity force $T(t) = t$ exactly, an equilibrium, and at that fixed point the vector
$$f(v) = \left\lceil \frac{E(v) - (m-t)}{n} \right\rceil_{\!+} - 1$$
is a certified winning strategy: fire it once and every debt is gone. The proof is an algorithm, running in time $O(nm)$, and it is completely explicit — hand it a table of a million people and an adversarial theft of chips, and it prints the moves.

## Half-canonical divisors, and how special a round table is

There is a reason to care about degree $g-1$ specifically. It is the *self-dual* degree: the Riemann–Roch involution $D \mapsto K - D$ preserves it, and the fixed points are the **theta characteristics**, the classes with $2D = K$. Classical geometry says these are the interesting extremes.

On $K_n$ with $n$ odd, say $n = 2m+3$, the canonical divisor is $K(v) = n - 3 = 2m$, uniformly. So the uniform divisor $m\cdot\mathbf{1}$ satisfies $2D = K$ *exactly, on the nose* — it is a theta characteristic — and its degree is $m(2m+3) = g-1$. By the main theorem its rank is $\frac{m(m+3)}{2}$.

This is spectacularly large. There is a general theorem guaranteeing that every $k$-regular graph (for $k \ge 6$, $k \ne 7$) carries some divisor of degree $g-1$ with rank at least $k-1$. Here $K_{2m+3}$ is $k$-regular with $k = 2m+2$, so the universal guarantee is rank $\ge 2m+1$ — linear in $k$. The truth is $\frac{m(m+3)}{2}$, which matches at $m=2$ (the graph $K_7$, where rank $5 = k-1$ exactly) and then pulls away quadratically: at $m = 8$ the guarantee is $17$ and the truth is $44$.

Better yet, compare with the genus. Since $g = 2m^2+3m+1$ and $r = \frac{m^2+3m}{2}$, we have
$$4r > g$$
for every $m \ge 1$ — the rank is asymptotically a full quarter of the genus. For a "generic" object of genus $g$, the Brill–Noether heuristic predicts that a divisor of degree $g-1$ has rank at most about $\sqrt{g}$. Complete graphs violate that by a wide margin. In the language of the theory, they are as far from Brill–Noether general as one can imagine: the round table is the most special object in the room.

There is a pleasing internal check here. On $K_n$ the canonical divisor is $(n-3)\cdot\mathbf{1}$, so the residual of $m\cdot\mathbf{1}$ is $(n-3-m)\cdot\mathbf{1}$ — uniform again. Riemann–Roch then reads
$$\frac{m(m+3)}{2} - \frac{(n-3-m)(n-m)}{2} = mn - \frac{(n-1)(n-2)}{2} + 1 ,$$
an identity one can verify by expanding. The upper and lower bounds of the main theorem are *exchanged* by the involution $m \leftrightarrow n-3-m$: each is the Riemann–Roch shadow of the other. Prove either half for all $m$ and the other half follows.

## What is still open

The picture at the round table is now complete for uniform configurations, but the surrounding landscape is not.

**The maximum over all classes.** The uniform divisor is not always the best one of its degree. Numerical evidence points to a clean answer: the maximum rank over all classes of degree $d$ on $K_n$ should be attained at the *concentrated* divisor that piles all $d$ chips on one vertex, with value $\frac{a(a+1)}{2} + \min(b,a)$ where $d = a(n-1) + b$ and $0 \le b \le n-2$. At the half-canonical degree $d = g-1$ this gives the sequence $0, 0, 2, 2, 5, 5, 9, 9, 14, 14, \dots$ — each term repeated twice — and it says $K_n$ hits the universal target $k-1 = n-2$ only at $n = 7$. Exhaustive search confirms this for the small cases; a proof is missing.

**Two stubborn degrees.** The universal half-canonical existence theorem covers every regularity $k \ge 6$ except $k = 7$, and it leaves $k = 5$ open. These are exactly the two degrees where the one-shot estimates fall a hair short. Enumerating all $3125$ degree-$9$ classes on $K_6$ shows the maximum rank there is $2$, well below $k-1 = 4$, so at $k = 5$ a genuine size threshold *is* required — no universal statement can hold. At $k = 7$ every tested witness on $K_8$ has rank exactly $5$, one below the target. Whether a threshold exists in either case, and how large it must be, is unknown; the numerical obstruction suggests the answer is linear in $k$, roughly $2k+7$, rather than the quadratic scale earlier arguments seemed to require.

**Beyond the round table.** The whole edifice above rests on one structural fact: the Laplacian of $K_n$ has rank one plus a scalar. What is the right generalisation? Complete multipartite graphs, strongly regular graphs, and circulants all have Laplacians with few distinct eigenvalues; do their dollar games also reduce to a one-parameter optimisation? Where that happens, one should expect exact rank formulas of the same flavour — and, if the pattern of $K_n$ is any guide, ranks that are quadratic where the general theory only promises linear.

---

The prettiest thing here may be the shape of the argument. A question about coordinated group behaviour on an arbitrarily large network turns into a one-variable minimisation over the integers; that minimisation is controlled by an identity Hermite wrote down in the nineteenth century; and the extremal configuration is a staircase $-1, 0, 1, 2, \dots$ that any child could draw. The answer — $m(m+3)/2$, no matter how big the table — is the kind of fact that feels, once you see the proof, as though it could not have been otherwise.
