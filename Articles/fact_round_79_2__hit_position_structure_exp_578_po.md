# Where the Easy Numbers Hide

## A story about factoring, sieves, and the geometry of a parabola

### The oldest trick in the book

Pierre de Fermat had a beautiful idea about how to break a number into pieces. Suppose you want to factor $N$, and suppose $N$ happens to be the difference of two squares, $N = x^2 - k^2$. Then you are done immediately, because $x^2 - k^2 = (x-k)(x+k)$, and you have your factors for free.

So Fermat suggested: start just above $\sqrt{N}$, and walk upward. Let $b = \lceil \sqrt{N}\,\rceil$ and consider the sequence of values
$$v(j) = (b + j)^2 - N, \qquad j = 0, 1, 2, 3, \dots$$
Every time $v(j)$ turns out to be a perfect square, you have factored $N$.

That is the whole method, and for a number whose two prime factors are close together it is devastatingly fast. But for a general number the perfect squares are far too rare to wait for, and the modern descendants of Fermat's idea — the quadratic sieve, the number field sieve, the algorithms that actually stand between the world and the collapse of public-key cryptography — soften the requirement. Instead of demanding that $v(j)$ be a perfect square outright, they ask only that $v(j)$ be **smooth**: that all of its prime factors be small, below some bound $B$. Smooth values can be collected in bulk and then combined, by linear algebra over the field with two elements, into the square that Fermat wanted. Every smooth value found is a row in a matrix; enough rows and the number falls apart.

This makes the practical question of factoring into a question about a parabola. The sequence $v(j) = (b+j)^2 - N$ traces the right-hand branch of a parabola, starting near zero and climbing. Somewhere along it sit the smooth values — call them the **hits**. Everything about the running time of the sieve depends on how many hits there are and where they are. And this is where a curious empirical fact enters.

### The clustering

Run the experiment. Take a hundred and twenty-eight carefully chosen numbers, each the product of two primes of the same size, each about ninety-six bits long. For each one, sample a long stretch of sieve positions $j$, test each value $v(j)$ for smoothness, and record the position of every hit. Then rescale: for each number, express each hit's position as a fraction of the total range searched, so that all positions live in the interval from $0$ to $1$. If hits were positionally indifferent, that rescaled coordinate would be uniform.

It is not. Pooling nearly ten thousand hits across the population, the distribution of rescaled positions deviates from uniformity by an amount that is astronomically unlikely to be chance — while a control group built from *non*-hits, matched in every other way, sits precisely on uniformity. Split the range into ten equal bins and the hit fractions read
$$0.162,\ 0.123,\ 0.109,\ 0.097,\ 0.091,\ 0.091,\ 0.090,\ 0.084,\ 0.081,\ 0.072,$$
a clean monotone decline: more than twice as much mass in the first tenth of the range as in the last. Hits like small $j$.

The obvious reaction is a shrug. Of course they do! The polynomial $v(j)$ is increasing. Small $j$ means small values, and small numbers are more likely to be smooth than big ones — that is the oldest heuristic in analytic number theory. The clustering could be nothing but a shadow of the size of the numbers involved.

So one controls for size: bin the hits by the magnitude of $v$, and compare each hit only against non-hits of the same magnitude. If the effect is a size artefact, it evaporates. It does not evaporate. Conditioning on eight magnitude cells *raises* the discrepancy rather than lowering it; seven of the eight cells show the effect independently; a permutation test inside the cells rules out coincidence. Something appears to be pulling hits toward small positions beyond what their size can account for.

That empirical claim is where the mathematics begins, because the honest reaction to a surprising statistic is not to believe it but to ask what mechanisms could possibly produce it, and to work out exactly what each one can and cannot do.

### The position–gcd law

Here is the first thing to notice, and it is exact, elementary, and (as far as such things go) rather lovely.

Expand the polynomial around its own starting point. Since
$$v(j) - v(0) = (b+j)^2 - b^2 = j\,(j + 2b),$$
the increment from position $0$ to position $j$ is a multiple of $j$. Hence $v(j)$ and $v(0)$ are congruent modulo $j$, and therefore:

> **The Position–GCD Law.** For every base $b$, every modulus $N$, and every position $j$,
> $$\gcd\bigl(j,\ v(j)\bigr) = \gcd\bigl(j,\ v(0)\bigr).$$
> In particular, $j$ divides $v(j)$ if and only if $j$ divides the single fixed integer $v(0) = b^2 - N$.

Read that again, because it is the hinge of the whole story. The arithmetic relationship between a sieve position and the value sitting at that position — how much of the value the position itself divides out — does not depend on where you are along the parabola in any complicated way. It is entirely determined by the *one* integer $v(0)$, which is fixed before the sieve begins.

And it matters for smoothness, because of an equally simple observation: if $g$ divides $v$ and $g$ is itself smaller than the smoothness bound $B$, then $v$ is $B$-smooth exactly when the cofactor $v/g$ is. Any factor below the bound is free; the smoothness test only has to be passed by what is left. So at position $j$, the effective number to be tested is not $v(j)$ but the smaller number
$$\frac{v(j)}{\gcd(j, v(0))}.$$
When the greatest common divisor is large, position $j$ is *arithmetically privileged*: it gets a discount on its smoothness test that has nothing to do with the size of $v(j)$. This is a genuine "beyond-magnitude" mechanism, and it is measurable: at matched magnitude, positions carrying a nontrivial guaranteed factor hit about $21\%$ more often, with a clean dose–response in the size of the factor.

### But the discount is spread evenly

A carrier that boosts the hit rate is not yet an explanation of *clustering*. For that, the boost must be concentrated at small $j$. And here the position–gcd law turns against the hypothesis it just created.

The quantity $\gcd(j, v(0))$ depends on $j$ only through $j \bmod v(0)$ — replacing $j$ by $j + v(0)$ changes nothing. The gcd carrier is periodic, with period $|v(0)|$. And periodic means uniform:

> **Window Equidistribution.** If a property of positions depends only on the position's residue modulo some fixed $T$, then every window of $T$ consecutive positions contains exactly the same number of positions with that property — namely the number of solutions among the residues themselves.

Apply it to the gcd carrier and the conclusion is immediate: the set of privileged positions has exactly the same density near the start of the sieve as anywhere else. The carrier is real; it enriches smoothness; it is invisible to magnitude; and it cannot cluster.

The same guillotine falls on every other "local" mechanism one might reach for. Take a prime $p$. Where does $p$ divide $v(j)$? Exactly where $(b+j)^2 \equiv N \pmod p$ — a quadratic congruence, with at most two solutions. So the positions divisible by any fixed prime form at most two residue classes modulo $p$, perfectly equidistributed. Prime powers behave no worse: for an odd prime $p$ not dividing $N$, any two positions where $p^k$ divides the value are either congruent modulo $p^k$ or *conjugate* to each other in the sense that their sum is $-2b$ modulo $p^k$ — again two classes, again exactly uniform. Not one small prime, not one prime power, and not the whole gcd carrier can prefer the left end of the sieve.

Indeed one can package this as a falsification instrument, which may be the most useful single output of the whole analysis:

> **Local Discrepancy Bound.** For a property of positions determined by residue modulo $T$, the counts in any two windows of the same length differ by at most $T$.

Contrapositively: **an observed excess of $E$ hits in one block over an equally long block rules out every local explanation of modulus $T < E$.** A clustering claim is no longer just a $p$-value; it becomes a lower bound on the complexity of any periodic mechanism that could be responsible. Report the excess and you have automatically reported which mechanisms are dead.

### One carrier that does decline

Is there *any* magnitude-free mechanism with a genuine taste for small positions? Yes — exactly one, and the position–gcd law identifies it precisely. The extreme case of the law is full self-divisibility: $j \mid v(j)$, which happens if and only if $j \mid v(0)$. Now count how often that occurs. Among any $d$ consecutive integers exactly one is divisible by $d$; among $d\,t$ consecutive integers exactly $t$ are. So the self-divisibility carrier has density exactly $1/d$ at scale $d$ — and $1/j$ is a *decreasing* function of the position.

That gives a proved decline. Compare the first block of positions with the block that follows it:

> **Harmonic Block Decline.** For every $K \ge 1$,
> $$\sum_{j=K+1}^{2K} \frac{1}{j} \;<\; \sum_{j=1}^{K} \frac 1 j .$$

The proof is two lines: the left-hand side has $K$ terms each at most $1/(K+1)$, so it is less than $1$, while the right-hand side already contains the term $j=1$ and so is at least $1$. From this follows the statement one actually wants, averaged over base values so that the densities are exact:

> **Small-$j$ Excess of the Self-Divisibility Carrier.** Averaged over a window of base values $v(0)$ long enough for all the densities to be exact, the expected number of positions $j$ in $[1, K]$ at which $j$ divides $v(j)$ strictly exceeds the expected number in the next block $(K, 2K]$.

So the shape observed in the data — monotone decline across blocks — does have an exact arithmetic ancestor. It is small in mass, being a harmonic tail, but it is real, it is provable, and it is the only local carrier that has this property.

### What magnitude can do, and why size-bins do not control it

The competing explanation has to be pinned down too, and it can be, exactly. When $b = \lceil \sqrt N\rceil$, so that $(b-1)^2 \le N \le b^2$, the polynomial is sandwiched:
$$2bj \;\le\; v(j) \;\le\; 2bj + j^2 + 2b .$$
For positions well below $b$ — which is the whole practical range — the value is essentially the *linear* function $2bj$. Magnitude and position are not merely correlated; they are two names for the same variable. In particular, every position whose value is at most $X$ satisfies $j \le X/(2b)$: the sub-$X$ part of the sieve is an initial block of positions, of length between $X/(4b)$ and $X/(2b)$.

This has a sharp consequence for the statistical protocol that produced the surprise. Because $v$ is strictly increasing, any classification of positions by a monotone function of the value has classes that are *intervals of positions*: a magnitude bin is a positional bin in disguise.

> **Cell Collapse.** If two positions lie in the same magnitude cell in the weak sense $v(j_2) \le 2\,v(j_1)$ — a cell one bit wide — then
> $$b\,j_2 \le 2b\,j_1 + 2b + j_1^2, \qquad\text{i.e.}\qquad j_2 \le 2 j_1 + 2 + \frac{j_1^2}{b}.$$
> In the small-position regime $j_1^2 \le b$ this sharpens to $j_2 \le 2 j_1 + 3$.

So conditioning on the bit-length of $|v|$ inside a single $N$ confines the positions to a factor-of-two window. It cannot decorrelate position from magnitude, because within one $N$ there is nothing to decorrelate. A "stratified" positional statistic computed this way is not measuring within-cell geometry — it is measuring the same tie between position and magnitude, one cell at a time. The strengthening of the effect under stratification therefore needs a different reading than the one it invites.

### And the deepest fact: smoothness is not local at all

One might hope that with enough patience the smooth locus itself could be described by a congruence — a modulus $T$ and a list of allowed residues. It cannot, and the counterexample is almost comically simple.

Take the degenerate sieve $b = 1$, $N = 0$, whose values are the squares $(j+1)^2$, and take the smoothness bound $B = 3$. A number is $3$-smooth exactly when it is a power of two; hence the sieve hits exactly at positions $j = 2^k - 1$. Now compare two adjacent blocks of length $2^n$. The block $[0, 2^n)$ contains the positions $2^0-1, 2^1-1, \dots, 2^n-1$ — at least $n+1$ hits. The block $[2^n, 2^{n+1})$ contains at most one. The imbalance grows without bound.

> **Non-locality of the Smooth Locus.** For every $T$ there exist two equally long blocks of positions whose hit counts differ by more than $T$. Consequently there is no modulus $T$ and no set of residues modulo $T$ describing the positions that carry smooth values.

Combine this with the local discrepancy bound and the dichotomy is complete: bounded, periodic, congruence-style mechanisms have bounded positional imbalance; the smooth locus has unbounded positional imbalance; therefore the clustering of hits is driven by something that is not a congruence — and the only candidate on the table with unbounded reach is the magnitude law $v(j) \approx 2bj$ itself.

### Fermat's own position, as a sanity check

There is one position whose geometry is known exactly rather than statistically, and it is worth keeping in view as a calibration. A position $j$ carries a perfect square, $v(j) = k^2$, precisely when $N = (b+j-k)(b+j+k)$ — that is, precisely when it exhibits a factorization of $N$. Writing $N = pq$ with $p+q = 2s$ and $q - p = 2d$, the position $j_0 = s - b$ carries the value $d^2$: this is the *terminal Fermat position*, where the method halts. For a semiprime there are no others besides the trivial factorization: if $v(j) = k^2$ with $b+j-k > 1$, then necessarily $2(b+j) = p+q$.

And the terminal position obeys the same magnitude law as everything else: $2b\,j_0 \le d^2$. A balanced semiprime — one whose primes are close, so $d$ is small — has its terminal position at small $j$ *because the value there is small*. Even the one position we understand completely turns out to be a magnitude phenomenon, not a positional one. That is a useful humility check on any claim that positions know something values do not.

### Where this leaves us

The picture that survives all of this is parsimonious and, I think, rather satisfying. Within a single number, the clustering of smooth values toward small sieve positions is the linear magnitude law $2bj \le v(j) \le 2bj + j^2 + 2b$, plus a genuinely arithmetic but *positionally uniform* divisibility enrichment governed by the single integer $v(0)$, plus one thin, provable, harmonically declining sliver contributed by full self-divisibility. Every congruence-type mechanism is now quantitatively bounded; the smooth locus itself is proved not to be of that type; and magnitude bins are proved not to separate position from size.

None of that makes the experimental signal go away. What it does is make the signal *expensive*: any surviving explanation must either be non-local, or have a modulus at least as large as the observed excess, or come from a comparison across different numbers rather than within one. Those are exactly the three doors left open, and each of them is now a precise question rather than a vague suspicion.

That is what a good negative theorem does. It does not close the subject; it narrows the corridor. Somewhere along the right-hand branch of a very old parabola, the easy numbers are hiding — and we now know a great deal about where they are *not*.
