# Chips on a Graph, and the Shadow of a Riemann Surface

## A game with a hidden geometry

Imagine a network — a set of nodes joined by wires. On each node sits a pile of poker chips. Some piles may be *negative*: that node is in debt.

There is exactly one legal move. Pick any node and let it **fire**: it pushes one chip out along every wire attached to it. A node of degree six that fires loses six chips and hands one to each of its six neighbours. You may also fire a whole group of nodes at once, which is the same as firing them one after another; the chips traded strictly inside the group cancel out, so the net effect is that each edge leaving the group carries one chip outward.

That is the whole game. It looks like a toy. It is not.

Two chip configurations are called **equivalent** if some sequence of firings turns one into the other. Firing everybody at once does nothing at all, so the moves have a built-in redundancy, and the set of equivalence classes turns out to be a finite abelian group — the *sandpile group*, or *Jacobian*, of the network. The name is not an accident. In 2007 Matthew Baker and Serguei Norine proved that this combinatorial game obeys an exact analogue of the **Riemann–Roch theorem**, the central structural theorem about functions on algebraic curves. A finite graph, it turns out, behaves like a degenerate Riemann surface, and the chip game is its function theory.

To make the dictionary work you need three numbers.

A chip configuration $D$ — from now on, a **divisor** — has a **degree** $\deg D$, the total number of chips, counted with sign. Degree is unchanged by firing: chips move but are never created.

The network has a **genus**
$$g = |E| - |V| + 1,$$
the number of independent cycles. A tree has $g=0$; a single cycle has $g=1$; the complete graph on six nodes has $15 - 6 + 1 = 10$.

And a divisor has a **rank** $r(D)$, which measures not how many chips it has but how *useful* they are. Say $r(D) \ge r$ if the following is true: **no matter which $r$ chips an adversary demands** — one chip here, three chips there, any placement of exactly $r$ chips — you can pay the bill and, after some sequence of firings, be left with no node in debt. If you cannot even reach a debt-free position from $D$ at all, set $r(D) = -1$.

Rank is the delicate invariant. Degree you can read off at a glance; rank requires you to survive every possible demand. And the Baker–Norine theorem says the two are tied together by
$$r(D) - r(K - D) = \deg D - g + 1,$$
where $K$ is the **canonical divisor**, the configuration placing $\deg(v) - 2$ chips on each node $v$. Its total degree is exactly $2g-2$.

## The half-canonical degree: where the theorem goes silent

Look at that formula and ask where it stops helping. Riemann–Roch determines $r(D)$ outright when the degree is large: past $2g-2$, the residual term vanishes and $r(D) = \deg D - g$. It also pins things down at the bottom. The one place it says nothing is the exact midpoint,
$$\deg D = g - 1.$$
There the right-hand side is zero, so the identity degenerates to $r(D) = r(K-D)$: the rank of a divisor equals the rank of its residual, and *that is all you learn*. Both could be $-1$; both could be enormous. This is the **half-canonical degree**, and on Riemann surfaces it is precisely where the classical theory of theta characteristics and Brill–Noether loci lives.

So: how large can the rank be at the half-canonical degree, and can we guarantee it?

For **regular** graphs, where every node has the same degree $k$, the question sharpens beautifully. The canonical divisor becomes the constant $k-2$ chips per node, so
$$g - 1 = \tfrac{1}{2}(k-2)\,n,$$
where $n$ is the number of nodes. The genus is no longer an independent parameter — it is determined by $k$ and $n$. The natural guess, suggested by the geometry of the corresponding curves, is:

> **Half-canonical existence.** Every simple connected $k$-regular graph carries a divisor of degree $g-1$ whose rank is at least $k-1$.

Perhaps only once the graph is large enough. The expected shape of the answer was a *threshold* $N_0(k)$: true for all $k$-regular graphs on at least $N_0(k)$ nodes, with a plausible guess of $N_0(k) \approx 2k^2$.

The results described below say something much stronger, and much stranger: for almost every regular degree, **no threshold is needed at all.**

## The naive attempt, and why it must fail

Here is the obvious construction. Put $m$ chips on every node. If the total is right, you have a divisor of the correct degree, and it is invulnerable to any demand of at most $m$ chips at a single node.

How large can $m$ be? The degree budget is $g-1 = (k-2)n/2$, spread over $n$ nodes, so $m \le (k-2)/2$. Take $m = \lfloor (k-2)/2 \rfloor$, roughly $k/2$: about half of the target rank $k-1$.

And this ceiling is not an artefact of laziness. It is a genuine obstruction:

> **No uniform witness.** On a $k$-regular graph, a divisor of degree $g-1$ can never carry $r$ chips on *every* node once $2r > k-2$. Since $2(k-1) > k-2$ for every $k$, the conjectural rank-$(k-1)$ witness can never be certified by simply having enough chips everywhere.

So any proof must genuinely *move chips*. Pointwise abundance will not do. The whole content of the problem is chip-firing.

## The first idea: let everyone else fire

Suppose $D$ has at least $m$ chips on every node, and every node has degree at least $k$. An adversary places $m+t$ chips somewhere and demands them. When can you pay?

If the demand is spread out — never more than $m$ at any single node — you pay from local reserves and you are done. The only bad case is a single node $v$ that is asked for more than $m$: it goes into debt.

But then the arithmetic is on your side. The adversary spent more than $m$ chips at $v$, so *everywhere else* he has at most $t-1$ chips to spend, total.

Now make one move: **let every node except $v$ fire.** Node $v$ receives one chip along each of its $\deg(v) \ge k$ edges. Every other node $u$ pays out at most one chip — namely one, if $u$ happens to be adjacent to $v$, and zero otherwise.

Count the damage. At $v$ you had at least $m$, paid at most $m+t$, and received at least $k$: your balance is at least $k - t \ge 0$ as soon as $t \le k$. At any other node $u$ you had at least $m$, paid at most $t-1$, and lost at most $1$: your balance is at least $m - t \ge 0$ as soon as $t \le m$.

One move, no debt. This proves:

> **The receiving-move bound.** On a graph of minimum degree $k$, a divisor with at least $m \ge 1$ chips on every node has rank at least $m + t$ for every $t \le \min(m, k)$ — in particular, rank at least $2m$.

That is a factor-of-two improvement over the trivial bound $m$, obtained from a single firing. Applied at the half-canonical degree of a $k$-regular graph, with $m = \lfloor(k-2)/2\rfloor$, it produces a divisor of degree $g-1$ and rank at least $2\lfloor(k-2)/2\rfloor$ — which for even $k$ is exactly $k-2$. **One short of the conjecture.** No hypothesis on the number of nodes at all.

Frustratingly, tantalisingly, one short.

## The second idea: fire around the *set* of trouble spots

The gap in the argument above is that it only ever handles one debt node. But a smarter accounting shows there can never be many.

Let the adversary demand $d$ chips, placed as $E$. Define the **trouble set**
$$S = \{\,u : E(u) \ge m\,\}$$
— the nodes where the demand meets or exceeds your local reserve. Each such node absorbs at least $m$ of the adversary's budget, and at least one of them, the node actually pushed into debt, absorbs $m+1$. So
$$|S|\,m + 1 \;\le\; \sum_{u \in S} E(u) \;\le\; d .$$
If the total demand $d$ is capped at $3m - 1$, this forces $|S| \le 2$. **The trouble set has at most two elements.** This is the pivot of the whole argument: a global counting bound on the adversary's budget converts into a bound on the *shape* of the trouble.

Now fire the complement of $S$ — one move, again. Every node of $S$ receives one chip along each of its edges leaving $S$; since $|S|\le 2$, at most one edge per node stays inside, so a node $v\in S$ gains at least $\deg(v) - (|S|-1) \ge k - 1$ chips. Every node outside $S$ pays at most $|S| \le 2$ chips.

The two cases:

- **$|S| = 1$.** The single trouble node $v$ gains $\deg(v) \ge k$ and was asked for at most $d \le k+m$, against a reserve of $m$: it survives. Outside, a node pays exactly one chip and was asked for at most $m-1$ against a reserve of $m$: it survives.
- **$|S| = 2$.** A trouble node $v$ now shares $S$ with one other heavy node, which itself soaks up $m$ of the budget; so $v$ was asked for at most $d - m \le 2m-1$ against a reserve of $m$ plus a gain of at least $k-1$: it survives, because $m - 1 \le k-1$. Outside, a node pays at most $2$; and since $S$ already consumes $2m+1$ of the budget, an outside node was asked for at most $d - 2m - 1 \le m - 2$, against a reserve of $m$: it survives with two chips to spare.

Every case closes. What emerges is the engine of the whole story:

> **The set-firing bound.** On a graph of minimum degree $k$, a divisor carrying at least $m \ge 2$ chips on every node, with $m \le k$, has rank at least
> $$\min\bigl(3m - 1,\; k + m\bigr).$$

Compare: the trivial bound was $m$, the receiving move gave $2m$, and one carefully chosen set-firing gives $3m-1$. And the improvement is exactly what the conjecture needed.

## The payoff

Feed the half-canonical data into the set-firing bound. On a $k$-regular graph take $m = \lfloor (k-2)/2 \rfloor$ chips at every node, dumping the leftover chips anywhere you like on a single node. The degree is $g-1$ on the nose, and the rank is at least $3\lfloor(k-2)/2\rfloor - 1$.

Is that at least $k-1$? Write $k = 2j$ or $k = 2j+1$; either way $\lfloor(k-2)/2\rfloor = j-1$ and the bound reads $3j-4$.

- $k = 2j$ even: $3j - 4 \ge 2j - 1$ exactly when $j \ge 3$, i.e. $k \ge 6$. ✓
- $k = 2j+1$ odd: $3j - 4 \ge 2j$ exactly when $j \ge 4$, i.e. $k \ge 9$. ✓

The odd cases $k = 5$ and $k = 7$ slip through; every other case lands. So:

> **Half-canonical existence, unconditionally.** For every $k \ge 6$ with $k \ne 7$, **every** simple $k$-regular graph — on any number of nodes whatsoever, one node or a billion — carries a divisor of degree $g-1$ and rank at least $k-1$.

For those degrees the threshold $N_0(k)$ that everyone expected to need is simply $N_0(k) = 1$. There is no threshold. The quadratic scale $2k^2$ was a mirage.

## Where the mirage came from

It is worth seeing why $2k^2$ looked inevitable, because the answer is a lesson in distinguishing *counting* from *construction*.

Classical Brill–Noether theory attaches to a genus-$g$ curve, a degree $d$, and a rank $r$ the number
$$\rho = g - (r+1)(g - d + r),$$
the expected dimension of the family of degree-$d$, rank-$r$ linear systems. When $\rho \ge 0$ such systems exist on every curve; when $\rho < 0$ the generic curve has none. At the half-canonical degree $d = g-1$ the formula collapses elegantly to
$$\rho = g - (r+1)^2 .$$

For a $k$-regular graph and the target rank $r = k-1$ this is positive exactly when
$$2k^2 \le (k-2)\,n .$$
That is where $2k^2$ came from: the number of nodes needed to make the *count* plausible.

But the inequality is much weaker than it looks. Since $(k-2)(2k+7) = 2k^2 + 3k - 14 \ge 2k^2$ for all $k \ge 5$, the **linear** bound
$$n \ge 2k + 7$$
already guarantees $\rho \ge 1$. The numerical obstruction disappears at linear scale, not quadratic. And the theorem above disposes of the geometry at scale $n \ge 1$. The quadratic threshold was never a feature of the problem; it was an artefact of reading a dimension count as a construction.

## A duality, and self-dual witnesses

One structure at the half-canonical degree deserves its own spotlight. Because $\deg(K - D) = 2g - 2 - \deg D$, the **residual map** $D \mapsto K - D$ sends degree $g-1$ to degree $g-1$, and applying it twice returns you to where you started. It is an involution on exactly the divisors we care about. Riemann–Roch at this degree says $r(K-D) = r(D)$, so the involution permutes the set of witnesses: **half-canonical divisors of rank at least $r$ come in pairs, or are fixed.**

The fixed classes have a classical name. A divisor $D$ with $2D \sim K$ is a **theta characteristic** — a "square root of the canonical divisor". On Riemann surfaces theta characteristics are the objects controlling spin structures, quadratic forms, and the vanishing of theta functions. On graphs they are startlingly concrete: on a $2j$-regular graph the canonical divisor is the constant $2j-2$, so the constant divisor with $j-1$ chips at every node satisfies $2D = K$ exactly, on the nose, no firing required.

And it is a witness:

> **A self-dual witness.** On any simple $2j$-regular graph with $j \ge 3$, the constant divisor with $j-1$ chips at every node is a theta characteristic of degree $g-1$, fixed by the residual involution, and of rank at least $3j - 4 \ge k - 1$.

So for even degree $k \ge 6$ the conjectural witness can be taken to be as symmetric as possible: the same everywhere, and its own residual. For such divisors the rank identity $r(K-D) = r(D)$ needs no appeal to Riemann–Roch at all — the two divisors are literally equal.

## The two holdouts

That leaves $k = 5$ and $k = 7$, and they are not merely a defect of the method. Exhaustive computation shows:

On the complete graph $K_6$ — the smallest $5$-regular graph, with genus $10$ and half-canonical degree $9$ — a search over **every** chip configuration of degree $9$ finds maximal rank $\mathbf 2$. Not $4 = k-1$; not even $3$. So the $k=5$ statement is *false* for $n=6$: a genuine threshold $N_0(5) > 6$ is required. The problem at $k=5$ is not that the method is weak; it is that the theorem itself is asymptotic.

Yet largeness alone is not the story either. On the complete bipartite graph $K_{5,5}$ — also $5$-regular, with half-canonical degree $15$ — the divisor placing $2$ chips on one side and $1$ on the other has rank $\mathbf 5$, comfortably above the target $4$. Two $5$-regular graphs, wildly different answers. Whatever proves the case $k=5$ will have to *choose* its witness using the structure of the graph, not just its degree sequence.

Meanwhile the set-firing bound is not merely convenient — it is **sharp**. On $K_7$ ($6$-regular, half-canonical degree $14$) the constant divisor $2$ has rank exactly $5$, matching $3m-1 = 5$ precisely, and refuting the competing expression $k+m = 8$. The same value $5$ appears on the circulant graphs $C_8(1,2,3)$ and $C_9(1,2,3)$, and on $K_8$ ($7$-regular, half-canonical degree $20$), where the natural witness has rank exactly $5 = k-2$ — one below the target, exactly as the theory predicts for $k=7$. Even on $K_6$ the general bound is attained: the constant divisor $2$ there has rank exactly $5 = \min(3\cdot 2 - 1,\, 5+2)$.

The bound is not approached. It is hit, repeatedly, on the nose.

## Why any of this matters

Divisor theory on graphs is a bridge. On one side sits algebraic geometry: curves, line bundles, Riemann–Roch, Brill–Noether loci — a subject two centuries deep. On the other sits a chip-firing game that a child can play. The bridge is not a metaphor; the theorems really do transfer, and degenerating a family of curves to a graph is now a standard tool for proving statements about the curves themselves, including sharp cases of the Brill–Noether theorem.

What makes the half-canonical degree special is that it is the one place the bridge carries no traffic. Riemann–Roch, the workhorse, says nothing there beyond a symmetry. Everything must be built by hand.

The result above builds it by hand with a single firing move, chosen by a counting argument that caps the size of the trouble set at two. That such a crude instrument settles almost the entire conjecture — and with the strongest possible threshold, none at all — suggests the half-canonical problem was never about size. It was about knowing which set to fire.

Two degrees remain, $k=5$ and $k=7$, and the computations show they are genuinely different in character: at $k=5$ a threshold really is needed, and the witness really must depend on the graph. Those are exactly the cases where $\lfloor(k-2)/2\rfloor$ dips to $1$ or $2$ and one shot is no longer enough. Somewhere past one-shot firing there is a better move. Finding it is the next chapter.
