# The Arithmetic of Taking Turns

## How to share a single stream of moments among many hungry clients

Every second, somewhere, a machine is deciding whose turn it is.

A router has one outgoing link and a dozen flows competing for it. A CPU has one core and thirty threads. A factory line has one robot arm and five feeders. A streaming server has one send window and hundreds of subscribers. In every case, the resource is *indivisible in time*: at each tick exactly one client is served, and nobody can be served half a tick.

But the demands are almost never equal. Client $0$ pays for $70\%$ of the bandwidth, client $1$ for $20\%$, client $2$ for $10\%$. The scheduler cannot give anybody $0.7$ of a slot. It must produce an infinite word over the alphabet $\{0,1,2\}$ — a sequence like

$$0,\;0,\;1,\;0,\;0,\;2,\;0,\;1,\;0,\;0,\;\dots$$

whose *long-run frequencies* are $0.7$, $0.2$, $0.1$, and — this is the hard part — whose *short-run* frequencies are as close to that as an integer sequence can manage. A schedule that gave client $0$ its seventy slots, then client $1$ its twenty, then client $2$ its ten, and repeated, would have perfect long-run frequencies and be a disaster in practice: client $2$ would wait ninety consecutive ticks for its first byte.

This article is about the exact arithmetic of that tension. How close to its fair share can a client be *kept at all times*? What is the price of insisting on exactness? And what does a genuinely good schedule look like when there are many clients with wildly different rates?

The answers turn out to be crisp, and slightly surprising.

---

## The setup, in one paragraph

Fix positive integers $r_0, r_1, \dots, r_{k-1}$ — the *rate profile*. Let

$$P_i \;=\; r_0 + r_1 + \dots + r_{i-1}, \qquad R \;=\; P_k \;=\; \sum_{j<k} r_j .$$

$R$ is the *period*: in every block of $R$ slots, client $i$ "deserves" exactly $r_i$ of them. A *schedule* is a function $f$ from time slots $0,1,2,\dots$ to clients, and its counters are

$$N_i(t) \;=\; \#\{u < t : f(u) = i\},$$

the number of services client $i$ has actually received by time $t$. Its ideal entitlement at time $t$ is $r_i t / R$. The single number that measures unfairness is the *discrepancy*

$$D_i(t) \;=\; R\, N_i(t) - r_i\, t ,$$

and dividing by $R$ turns it into a count of whole services: $|D_i(t)|/R$ is how many services the client is ahead of, or behind, where it should be. A schedule is *$B$-fair* if $|D_i(t)| \le B$ for every client and every moment; the *normalised discrepancy* $B/R$ is the honest, scale-free figure of merit.

Everything below is about how small the normalised discrepancy can be made.

---

## Cutting a period with prefix sums

The most natural schedule is the one everybody writes first. Lay the $R$ slots of one period on a line, and cut it at the prefix sums:

$$B_i \;=\; \{\,P_i,\; P_i+1,\; \dots,\; P_{i+1}-1\,\} .$$

The interval $B_i$ contains exactly $r_i$ slots, the intervals are pairwise disjoint, and together they tile $\{0,1,\dots,R-1\}$ perfectly. Repeat forever: at time $t$, serve the unique client $i$ whose interval contains $t \bmod R$. Call this the **block schedule**. It is exact by construction, and it is the scheduling reading of the elementary fact that prefix sums cut an interval into pieces of prescribed sizes.

What is remarkable is that its counter has a *closed form* — not an asymptotic, not a recursion, an exact formula valid at every instant:

> **Counter formula.** For every client $i$ and every time $t$,
> $$N_i(t) \;=\; \left\lfloor \frac{t}{R} \right\rfloor r_i \;+\; \min\!\bigl(r_i,\; (t \bmod R) - P_i\bigr)^{+},$$
> where $x^+$ means $\max(x, 0)$.

Read it aloud: complete periods contribute $r_i$ each, and inside the current, partial period the client has received nothing yet if the clock has not reached its block, is being served right now if the clock is inside its block, and has already been fully served if the clock is past it.

From this one identity everything else falls out like corollaries, and the corollaries are sharp.

**At period boundaries the schedule is perfect.** Setting $t = nR$ gives $N_i(nR) = n\,r_i$: every client has exactly its due, on the nose, forever.

**In between, the error is governed by the prefix mass.** The exact two-sided bound is

$$-\,r_i P_i \;\le\; D_i(t) \;\le\; r_i\,(R - P_{i+1}),$$

and both ends are attained: the worst lag happens at the very first slot of client $i$'s block (it has waited through all $P_i$ slots belonging to earlier clients and received nothing), and the worst lead happens at the last slot of its block (it has just been served $r_i$ times in a row and now the $R - P_{i+1}$ slots of the later clients still lie ahead). A client's unfairness is exactly the mass in front of it and the mass behind it. In particular $|D_i(t)| \le r_i (R - r_i)$, which for a big client is quadratically large: normalised, the block schedule can be $\Theta(R)$ services out of true.

**Nobody starves.** Client $i$ is served at least once in every window of $R - r_i + 1$ consecutive slots, and that window length cannot be shortened, because the schedule serves each client in one contiguous burst per period.

**And it degenerates to the right thing.** If all rates are $1$, the block schedule is precisely round robin, $f(t) = t \bmod k$; multiplying every rate by $m$ slows the schedule down by exactly the factor $m$, so the construction is genuinely a function of the *ratios*, as it should be.

So the block schedule is the exactness champion — and, in a strong sense, exactness is all it is good for.

---

## Perfection is impossible, and we can say exactly how impossible

Could some cleverer schedule be exact at *every* instant — $R\,N_i(t) = r_i t$ for all $i$ and all $t$?

No, and the proof takes one line. Look at time $t = 1$. Somebody was served in slot $0$; call it client $j$. Then $R\,N_j(1) = R$, while the ideal is $r_j$. Exactness would force $r_j = R$, i.e. client $j$ has *all* the rate, contradicting the assumption that at least two clients have positive rates. So:

> **No schedule is exact.** With two or more clients of positive rate, no schedule meets every client's exact share at every time. The block schedule's exactness at all multiples of the period is the best form of exactness available.

Moreover — and this is a satisfying refinement — for the block schedule those are exactly the times of exactness: with $k \ge 2$ positive rates, all clients are simultaneously on target at time $t$ if and only if $R$ divides $t$.

The same one-line argument yields a universal lower bound on fairness itself: whichever client is served first immediately overshoots by $R - r_{f(0)}$, so *every* $B$-fair schedule must have $B \ge R - r_{f(0)}$. For the uniform profile that reads $B \ge k-1$, and round robin achieves $k-1$. Round robin is not merely traditional; it is optimal.

---

## Two clients: the line-drawing trick

For two clients there is a beautiful classical answer, and it comes from computer graphics. To draw a straight line of slope $a/R$ on a pixel grid, Bresenham's algorithm steps right, and steps up exactly when the ideal line crosses a pixel boundary. Transplant it: with rates $a$ and $R-a$, serve client $0$ in slot $t$ precisely when

$$\left\lfloor \frac{t a}{R} \right\rfloor \;<\; \left\lfloor \frac{(t+1)a}{R} \right\rfloor,$$

and client $1$ otherwise. The counters are then literally the staircase of the ideal line, $N_0(t) = \lfloor t a / R\rfloor$ and $N_1(t) = t - \lfloor ta/R\rfloor$, so the discrepancy is a rounding error:

> **Unit fairness for two clients.** The Bresenham schedule satisfies $|D_i(t)| \le R-1$ for both clients and all times: normalised discrepancy strictly below one service.

Compare with the block schedule on the balanced profile $(c,c)$, where $R = 2c$. At the end of client $0$'s block, at time $t = c$, we have $D_0(c) = 2c\cdot c - c\cdot c = c^2$ — that is $c/2$ whole services of lead, unbounded as $c$ grows, while Bresenham never exceeds one. Exactness and smoothness are genuinely different goals, and the gap between them is as large as you like.

Bresenham also comes with tight waiting times: the fast client, of rate $a$, is served at least once in every $\lceil R/a \rceil$ slots, and the slow client at least once in every $\lceil R/(R-a)\rceil$ slots — exactly what you would demand of a "smooth" interleaving.

---

## The trap: the obvious generalisation is not a schedule at all

With two clients, Bresenham's counters are the differences of two floor functions. So here is the tempting generalisation to $k$ clients: define the candidate counters by differencing the floors of the *scaled prefix sums*,

$$\widehat N_i(t) \;=\; \left\lfloor \frac{t\,P_{i+1}}{R} \right\rfloor - \left\lfloor \frac{t\,P_i}{R} \right\rfloor .$$

For $k = 2$ this is exactly Bresenham. The formula has the right long-run frequencies, it sums to $t$ over all clients, and it looks like the natural multi-dimensional answer.

It is not a schedule. It is not the counter of *any* schedule.

The reason is beautifully simple. Take the three-client profile $(3,1,3)$, so $R = 7$, with prefix sums $0,3,4,7$. The middle client's candidate counter at $t = 2$ is $\lfloor 8/7\rfloor - \lfloor 6/7 \rfloor = 1 - 0 = 1$, and at $t = 3$ it is $\lfloor 12/7 \rfloor - \lfloor 9/7 \rfloor = 1 - 1 = 0$. The count goes *down*. But counters of genuine schedules are non-decreasing: nobody can be un-served.

> **Obstruction.** For $k \ge 3$ the nested-floor counter is not realisable by any schedule, though for $k = 2$ it coincides with Bresenham.

Geometrically, $\widehat N_i$ counts the jumps of one Beatty sequence minus the jumps of another; when two of the underlying staircases happen to jump in the same slot, the difference dips, and the arithmetic of the profile decides whether that can happen. The moral is that the two-client theory is not a special case of a multi-client theory that lives on the same formula; the multi-client problem needs a different idea.

---

## The right idea: split the stream like a tournament bracket

Here is the idea that works, and it is essentially a divide-and-conquer.

Take your $k$ clients and split them into two teams, left and right, with total rates $w_\ell$ and $w_r$. Use the two-client Bresenham rule with rates $(w_\ell, w_\ell + w_r)$ to decide, at each global slot, which *team* gets it. Now each team receives its own thinned sub-stream of slots, indexed by its own local clock, and can recursively use the same trick inside itself. Continue down a binary tree whose leaves are the individual clients, each labelled with its own rate. The result is a perfectly concrete, easily computed schedule.

What does it cost? Each level of the tree is a two-client Bresenham decision, and Bresenham costs strictly less than one service of discrepancy. The remarkable fact is that these errors *add* rather than multiply:

> **Splitting-tree theorem.** For a splitting tree $T$ with distinct client labels and positive leaf rates, the recursive schedule satisfies
> $$\bigl| W\, N_i(t) - w_i\, t \bigr| \;\le\; W \cdot \operatorname{depth}(T)$$
> for every client $i$ and every time $t$, where $W$ is the total rate of the tree and $w_i$ the rate of client $i$. In normalised terms: **the discrepancy is at most the depth of the tree, no matter what the rates are.**

Note what is *not* in the bound: the rates. Not their sizes, not their ratios, not their arithmetic relationships. Only the shape of the tree.

So build a balanced tree. Splitting $n$ clients into $\lfloor n/2 \rfloor$ and $\lceil n/2 \rceil$ and recursing gives a tree of depth at most $\lceil \log_2 k \rceil$, and therefore:

> **Logarithmic fairness.** For every client count $k \ge 1$ and every profile of positive rates there is an explicit schedule whose normalised discrepancy never exceeds $\lceil \log_2 k \rceil$.

Three clients with rates $(1, 1, 10^6)$? Discrepancy at most $2$ services. A thousand clients with a thousand incommensurable rates? At most $10$. Contrast this with the block schedule, whose discrepancy on the innocuous profile $(c,c)$ already grows without bound. Fairness is not about the rates being nice; it is about the *shape* in which you decompose the problem.

---

## The online rule: always serve whoever is furthest behind

The splitting-tree schedule is computed from the profile in advance. What if clients arrive with rates that change, and you must decide slot by slot?

The natural online rule is: **serve the client whose lag after this slot would still be largest** — formally, maximise $r_i(t+1) - R\,N_i(t)$ over all clients. This is the largest-lag or "max deficit" rule familiar from packet scheduling and from apportionment theory. It has a clean guarantee:

> **The greedy rule never overshoots by a full period.** For every profile and all times, $D_i(t) \le R - 1$: no client is ever a whole service ahead of its entitlement.

The proof is a small gem. The $k$ greedy objective values sum to exactly $R$ at every step, because the rates sum to $R$ and the counters sum to $t$. Hence the maximum of the objectives is at least $1$, so the client that gets served was at least one unit "owed" — which is precisely the statement that nobody is pushed more than $R-1$ ahead. Since the discrepancies of all clients sum to zero at every instant, no client can be more than $(k-1)(R-1)$ behind either, so the greedy schedule is $(k-1)(R-1)$-fair. And greedy beats the block schedule at its own game: on the profile $(c,c)$ the block schedule leads by $c^2 > R-1$.

Is greedy actually *unit-fair* — normalised discrepancy below one on both sides, the multi-client analogue of Bresenham's guarantee? It is tempting to believe: for hundreds of small profiles the worst case sits comfortably below $1$. But the answer is no. Direct simulation of the rule on the six-client profile $(1,1,1,5,5,5)$, with $R = 18$, shows the last client falling $19$ units behind at time $11$ — normalised lag $19/18 > 1$. The failure is systematic, not accidental: the family "$m$ clients of rate $1$ together with $m$ clients of rate $c$" pushes the normalised discrepancy steadily upward, reaching about $1.44$ for $m = 30$, $c = 50$, and appearing to creep towards $3/2$ without ever reaching it. Greedy is one-sided: the *lead* is provably tight at one service, while the *lag* is not.

That asymmetry is itself the interesting phenomenon, and pinning down the true constant — is it exactly $3/2$? — is an inviting open problem.

---

## What the arithmetic teaches

Three ideas emerge from this landscape.

The first is that **prefix sums are the right coordinate system**. The exact-rate batches, the closed-form counter, the sharp discrepancy bounds, the waiting-time windows, and even the obstruction for the naive multi-client Bresenham are all statements about prefix sums $P_i$ and the position of the clock $t \bmod R$ relative to them.

The second is that **exactness and smoothness are in genuine tension**, and the tension is quantifiable. No schedule can be exact always; the block schedule is exact precisely at period boundaries and pays for it with $\Theta(R)$ discrepancy; the smooth schedules are never exact except at the boundaries they happen to hit.

The third, and most useful in practice, is that **fairness is a property of decomposition, not of numbers**. The bound $\lceil \log_2 k \rceil$ holds for every conceivable rate profile, with no arithmetic hypotheses whatsoever, because the schedule is built by recursively halving a set of clients rather than by manipulating the rates. Once you see scheduling as a tournament bracket over the clients — each internal node a two-client line-drawing problem — the multi-client problem stops looking like number theory and starts looking like a data structure.

Which, for the router with a dozen flows and one outgoing link, is very good news indeed.
