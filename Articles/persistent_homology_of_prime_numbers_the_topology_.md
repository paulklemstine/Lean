# The Shape of the Primes

## What a topologist sees when she looks at 2, 3, 5, 7, 11, …

Lay the prime numbers out on a ruler. At $2$, a mark. At $3$, another. Then $5$, $7$, $11$, $13$ — a scatter of dots thinning out as you walk to the right, never quite stopping, never falling into an obvious rhythm. This is the **prime point cloud**, and for the last fifteen years there has been a fashionable way to interrogate a point cloud: ask about its *shape*.

The technique is called persistent homology, and it comes from data science. Give it a finite set of points in any space and it answers a deceptively simple question: *at what scale does this data look connected, and at what scale does it look like it has holes?* You take a dial marked $\varepsilon$, and you join any two points that are within distance $\varepsilon$ of one another. At $\varepsilon = 0$ each point is an island. As you turn the dial up, islands merge into archipelagos, archipelagos into continents, and along the way loops may appear and later fill in. Recording the birth and death of every connected component and every loop produces a **barcode**: a stack of horizontal bars, each one saying "this feature was alive from scale $a$ to scale $b$."

Persistent homology has found tumours in mammograms, distinguished breeds of protein folds, and mapped the filaments of the cosmic web. What does it see in the primes?

There was a beautiful guess on the table, and it went like this. The primes near a large number $x$ have average spacing $\log x$ — that is the Prime Number Theorem, in the form Gauss guessed as a teenager. A random set of points with that spacing is a *Poisson process*, and Poisson processes have a famously clean barcode: the lengths of the connected-component bars are **exponentially distributed** with mean $\log x$. So perhaps the primes, notoriously "random-looking," have the barcode of a Poisson process. And perhaps — this was the tantalising part — the loops in the higher barcode encode something arithmetic. Perhaps the longest loop in the prime cloud is born at scale $\varepsilon = 2$, the scale of twin primes, and never dies; perhaps the Twin Prime Conjecture is secretly a statement about a hole in the shape of the primes.

It is a gorgeous story. It is also, in both halves, false — and what replaces it is sharper and stranger than the guess.

## First: the barcode of a line is just the gaps

Start with the easy half, which is a small miracle of bookkeeping. Write $p_1 = 2, p_2 = 3, p_3 = 5, \dots$ for the primes and $g_i = p_{i+1} - p_i$ for the **prime gaps**: $1, 2, 2, 4, 2, 4, 2, 4, 6, 2, \dots$

On a line, two points are joined at scale $\varepsilon$ exactly when they are within $\varepsilon$, and a whole run of consecutive primes fuses into one component exactly when every gap inside the run is at most $\varepsilon$. So the components at scale $\varepsilon$ are precisely the runs cut apart by the gaps larger than $\varepsilon$. Counting them gives the **Betti curve**
$$b_0(\varepsilon, n) = 1 + \#\{\, i < n : g_i > \varepsilon \,\},$$
a descending staircase, and the component barcode of the first $n$ primes is nothing other than the list of gaps $g_0, g_1, \dots, g_{n-1}$, each read as a bar from scale $0$ to scale $g_i$.

That already dissolves the mystique: the topology of the primes in dimension zero *is* the arithmetic of prime gaps. But it also makes the Poisson conjecture testable, and here the first surprise arrives.

## The barcode is quantised

Every prime after $2$ is odd. The difference of two odd numbers is even. Therefore:

> **Quantisation Theorem.** The very first bar of the prime barcode has length exactly $1$ (from $2$ to $3$). Every other bar has even length $2k$ with $k \ge 1$.

One line of arithmetic, and the Poisson dream is dead. An exponential distribution is *continuous*: it spreads its mass smoothly over all positive lengths, and in particular it insists that a definite fraction of bars should have length strictly between $2$ and $4$, or between $4$ and $6$. Precisely, an exponential law of mean $m$ puts mass
$$e^{-2k/m} - e^{-(2k+2)/m} > 0$$
into the window $(2k, 2k+2)$ — a strictly positive number, for every $m > 0$ and every $k$. The primes put *nothing* there. Not "not much": exactly zero bars, at every truncation, forever. The same happens at the bottom of the range: the exponential law wants a positive fraction of bars shorter than $1$, and the primes have none, because two distinct primes differ by at least $1$.

Among the $78\,497$ finite bars produced by the primes below one million, exactly one has odd length — the initial bar of length $1$ — and every other length is even. The mass in the window $(2,4)$ is $0$ against an exponential prediction of about $9\,150$ bars. The refutation is not statistical. It is structural.

And it is robust. Every prime bar length sits at distance at least $1$ from every odd integer $\ge 3$, so you may jiggle the whole barcode by anything less than $1/2$ (in the standard bottleneck metric that persistence theorists use to compare barcodes) and the empty windows remain empty. No continuous law survives the perturbation either.

There is one more nail. An exponential law with a fixed mean has a thin tail: bars much longer than the mean are exponentially rare, and a fixed scale $\log x$ governs everything. But the prime barcode has bars of *every* length. Take the number $m!$ and look at $m! + 2, m! + 3, \dots, m! + m$: the first is divisible by $2$, the second by $3$, and so on down the line, so all $m-1$ of them are composite. That is a prime-free stretch of length $m - 1$ placed wherever you like, hence a bar at least that long. **The prime barcode contains arbitrarily long bars.** No single scale governs it.

## Second: there are no holes at all

Now the loops. This is where the guess fails not by a margin but by a category error.

A loop in a Rips complex is a cycle of points, each within $\varepsilon$ of the next, which does not bound a filled-in disc — a genuine hole. Here is the geometric fact that kills them all on a line. Take any closed cycle of points on the line, $v_1 \to v_2 \to \cdots \to v_k \to v_1$, each consecutive pair within $\varepsilon$, with $k \ge 4$. Look at the **leftmost** point $v$ of the cycle. Its two neighbours in the cycle, call them $u$ and $w$, both lie within distance $\varepsilon$ of $v$, and both lie to the *right* of $v$. So both sit in the window $[v, v + \varepsilon]$ — and therefore they are within $\varepsilon$ of *each other*. The chord $uw$ is present in the complex. The cycle was never chordless.

> **Chordality Theorem.** In the scale-$\varepsilon$ complex of any strictly increasing point cloud on a line, every closed cycle of length at least $4$ has a chord joining two vertices at cyclic distance $2$.

That is the combinatorial statement, and it can be upgraded to the honest topological one. Work with coefficients mod $2$, where a one-dimensional chain is just a finite set of edges, addition is symmetric difference, and a *cycle* is an edge set in which every vertex has even degree. Holes are cycles that are not sums of triangles; so proving there are no holes means proving:

> **Vanishing Theorem.** For any strictly increasing point cloud on the real line and any scale $\varepsilon$, every mod-$2$ one-cycle of the scale-$\varepsilon$ complex is a sum of triangles of that complex. Consequently the first homology of the complex vanishes at every scale: the point cloud has **no** loops, ever.

The proof is an algorithm, and a pretty one. Give each edge $(a,b)$ with $a < b$ the weight $b$, and give a chain the total weight of its edges. Take a nonempty cycle and look at its **rightmost** vertex $v$. The degree of $v$ is even and nonzero, so at least two edges $(u,v)$ and $(w,v)$ meet it, with $u < w < v$. Both $u$ and $w$ lie in the window $[v - \varepsilon, v]$, so the chord $(u,w)$ is an edge of the complex and $T = \{(u,w), (w,v), (u,v)\}$ is a genuine triangle. Add $T$ to the cycle. Every vertex of a triangle has degree $2$, so adding it preserves evenness — the result is still a cycle. And the weight strictly drops: two edges of weight $v$ vanish and at most one edge of weight $w < v$ appears. Repeat. The weight cannot decrease forever, so the process halts at the empty chain, having written the original cycle as a sum of triangles.

The picture is "pull the loop to the left": at every step the rightmost part of the loop is bypassed by a shortcut, until nothing is left. On a line there is simply no room for a hole. Whatever else is true of the primes, they do not have one.

To be clear that this is not vacuous — that the prime complex genuinely has cycles, and they genuinely fill in — consider the quadrilateral $3 \to 5 \to 7 \to 11 \to 3$ at scale $\varepsilon = 8$. It is a bona fide nonzero one-cycle. And it is the sum of the two triangles $\{3,5,7\}$ and $\{3,7,11\}$, both of which are present at that scale. The loop is there; the hole is not.

## So where did the twin primes go?

They were never in dimension one. They were downstairs all along, and the corrected statement is arguably prettier than the conjectured one.

Consider a single step of the Betti staircase — the drop that happens exactly as the dial crosses $\varepsilon = 2$:
$$\text{twin step}(n) = b_0(1, n) - b_0(2, n).$$
Turning the dial from just under $2$ to $2$ merges exactly those pairs of primes that differ by $2$ — the twin pairs. So the height of this one step counts the twin pairs among the first $n$ primes.

> **Twin Prime Reformulation.** There are infinitely many twin primes if and only if the single Betti step at scale $\varepsilon = 2$ is unbounded as the truncation $n$ grows.

The Twin Prime Conjecture is a statement about a component count, not about a hole. It says: the prime cloud's very first merge event never stops happening.

## The primes repel themselves

Killing the exponential law leaves a weaker Poisson hypothesis standing: perhaps the bar lengths, whatever their individual distribution, are at least *independent* of one another. This too is false, and here the arithmetic pushes back hard.

Suppose two consecutive bars both have length $2$: that means three primes $p, p+2, p+4$. But one of any three numbers spaced $2$ apart is divisible by $3$, and once $p \ge 5$ that number is too large to *be* $3$, so it is composite. Contradiction.

> **Exclusion Theorem.** Past the very beginning of the barcode, no two adjacent bars are both of length $2$. In fact, if two adjacent bars have the same length $d$, then $3$ divides $d$.

The single exception is the triple $3, 5, 7$ at the very start, and that exception is why the theorem must be stated with a caveat: the rule is sharp, not decorative. In the barcode of the primes below a million, the pattern $(2,2)$ occurs exactly once, the pattern $(4,4)$ never, the pattern $(8,8)$ never — while the *allowed* repeat $(6,6)$ occurs $1\,929$ times and the mixed patterns $(2,4)$ and $(4,2)$ occur $1\,393$ and $1\,444$ times. A model with independent bars and $\mathbb{P}(\text{length} = 2) = q > 0$ predicts about $(n-1)q^2$ adjacent twin pairs among $n$ bars — a large positive number. The primes deliver zero.

The exclusion is one member of an infinite family. For any prime $q$, the residues mod $q$ of $q$ consecutive primes (all past $q$) live in only $q-1$ possible classes, so two of them coincide; the bars strictly between those two primes then sum to a multiple of $q$.

> **Block Divisibility Theorem.** For every prime $q$ and every starting index whose prime exceeds $q$, some block of fewer than $q$ consecutive bars has total length divisible by $q$.

Take $q = 3$ and you recover the twin exclusion. Take $q = 5$: four consecutive bars all of length $2$ would give a block sum of $2, 4, 6$ or $8$ divisible by $5$, which is impossible — so five primes in arithmetic progression with common difference $2$ cannot occur past the start. The prime barcode is not a random point pattern; it is a *correlated* one, with a hard exclusion rule at every prime modulus.

## The area under the staircase

One last identity, because it is the cleanest bridge between the two worlds. The Betti curve is a staircase; ask for the area beneath it, above the level $1$ (that is, counting only the components that will eventually merge). Each bar of length $g_i$ contributes to the count precisely while the dial is below $g_i$, so it contributes area $g_i$. The gaps telescope, and:

> **Betti Area Identity.** For every $n$,
> $$\int_0^{\infty} \big( b_0(\varepsilon, n) - 1 \big)\, d\varepsilon \;=\; p_n - 2 .$$

An integral over a continuous scale parameter, on the left. The $n$-th prime, on the right. Dividing by $n$ turns this into the exact form of the "average prime gap" whose asymptotic behaviour the Prime Number Theorem predicts: the mean bar length is $(p_n - 2)/n$. For the primes below a million that is $12.739$, against $\log p_n = 13.815$ — the familiar, slow convergence of the prime counting function to its logarithmic model.

And running the staircase backwards recovers everything: the number of bars of length exactly $2k$ is the drop of $b_0$ across the window from $2k-1$ to $2k+1$. Nothing is lost in translating between the gap histogram and the Betti curve; they are the same object. Indeed the barcode is a **complete invariant** of the primes, since
$$p_n = 2 + \sum_{m < n} g_m .$$
Every arithmetic fact about the primes is, in principle, a fact about their barcode.

## What the shape of the primes actually is

Put it all together and the picture is this. The prime point cloud does have a topology, and it is entirely zero-dimensional. There are no holes at any scale — not because the primes are dull, but because a line is too thin to hold one. What remains is a barcode of connected components, and that barcode is:

- **atomic**, with lengths confined to $\{1\} \cup \{2, 4, 6, \dots\}$ and hard empty windows between the even integers;
- **heavy-tailed**, with bars of arbitrarily large length, so no single scale $\log x$ describes it;
- **correlated**, with a hard exclusion forbidding adjacent equal bars unless the length is a multiple of $3$, and an analogous block law at every prime modulus;
- **complete**, encoding the primes exactly; and
- **arithmetically calibrated**, with the area under its Betti curve equal to $p_n - 2$.

The Poisson heuristic — the idea that the primes behave like a random set with density $1/\log x$ — remains a magnificent guide to prime behaviour *in the large*, and nothing above touches its asymptotic successes. What the topology shows is where the heuristic breaks: it is wrong about the fine structure at small scales, exactly where the arithmetic lives. Divisibility by $2$ quantises the barcode; divisibility by $3$ makes it repel itself; divisibility by every prime $q$ imposes another exclusion. What looks like randomness at scale $\log x$ is a lattice of congruences at scale $2$.

And the deepest open question of the subject sits, plainly visible, in the barcode's very first step. Turn the dial from $1$ to $2$ and watch how many components merge. Does that number grow without bound? Nobody knows. That is the Twin Prime Conjecture, wearing a topologist's clothes.
