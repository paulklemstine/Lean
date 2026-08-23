# The Octave That Isn't There

## What happens when you turn numbers into music — and what the numbers can actually tell you back

There is a genre of mathematical folklore that never quite dies: *listen to the digits of $\pi$*. Map each decimal digit to a note — $0$ to middle C, $1$ to the note above it, and so on up to $9$ — and you get a melody. People have played these melodies on pianos, on harps, in concert halls. And every so often, someone runs a statistic on the digit sequence, finds a bump at lag $12$, and announces that the digits of $\pi$ contain a hidden **octave structure**.

That announcement contains a beautiful and instructive mistake. This article is about the mistake, about the exact mathematics that dissolves it, and about the surprisingly rich structure that appears once you separate the two things it confuses.

---

## Two twelves that are not the same twelve

A melody is a function of one variable with values in another. Write the digit melody as a sequence
$$x_0, x_1, x_2, \ldots \in \{0,1,\ldots,9\}.$$
There are two entirely different distances you can measure here.

The first is **temporal**: how far apart in *time* two notes are. Comparing $x_i$ with $x_{i+12}$ means comparing note number $i$ with the note twelve beats later. The number $12$ here is a count of beats.

The second is **pitch**: how far apart in *sound* two notes are. If $x_i = 3$ and $x_j = 7$, the interval between them is $|3 - 7| = 4$ semitones — a major third. The number $4$ here is a count of semitones.

An **octave** is a pitch fact: two notes twelve semitones apart. It has nothing to do with time. But the autocorrelation of a sequence at lag $12$ — the quantity
$$A(12) = \sum_i x_i\, x_{i+12}$$
that produces those celebrated bumps — is a *temporal* statistic. It compares digit positions twelve steps apart. Both quantities involve the number twelve, and the coincidence is the entire source of the folklore.

Once you write the two variables down side by side, the punchline is immediate and, in its way, funny.

> **The Octave Vanishing Theorem.** *In a decimal digit melody, no two notes are ever an octave apart. For every window, every temporal lag, and every pair of positions, the number of note pairs realizing a twelve-semitone interval is exactly zero.*

The proof is one line: the digits live in $\{0,\ldots,9\}$, so $|x_i - x_j| \le 9 < 12$. A ten-note scale simply does not span an octave. The digits of $\pi$ cannot exhibit octave structure for the same reason a nine-rung ladder cannot reach the twelfth rung.

So what *is* the lag-$12$ autocorrelation measuring? It is measuring **unisons**: the number of positions where $x_i = x_{i+12}$, together with a weighting by loudness. That is a real and meaningful statistic. It is just not about octaves.

---

## The right object: the interval distribution

If you want to talk about musical intervals, you should count musical intervals. For a melody $x$, a window length $n$, a temporal lag $\ell$, and an interval size $v$, define
$$N_x(n,\ell,v) \;=\; \#\bigl\{\, i < n \;:\; |x_i - x_{i+\ell}| = v \,\bigr\}.$$
This is the **pitch-interval distribution at lag $\ell$**: a histogram over semitone sizes, built from a clearly specified pair of positions. The temporal parameter $\ell$ says *which pairs* you look at; the value $v$ says *what you hear*.

Two facts pin this object down. First, it really is a distribution: summing over all admissible interval sizes recovers the window length,
$$\sum_{v=0}^{9} N_x(n,\ell,v) = n,$$
because each of the $n$ position pairs contributes exactly one interval. Second, its support is confined to $\{0,\ldots,9\}$ — the Octave Vanishing Theorem again, now as a statement about where the histogram can be nonzero.

Everything you might want to compute from lag-$\ell$ intervals is a *moment* of this histogram. For any weight function $g$,
$$\sum_{v} g(v)\, N_x(n,\ell,v) \;=\; \sum_{i<n} g\bigl(|x_i - x_{i+\ell}|\bigr).$$
That identity is the hinge of the whole story, and it lets us say something precise about what autocorrelation does and does not see.

---

## Autocorrelation is exactly one number about the histogram

Work on a cyclic window of length $n$, where indices wrap around. Define the **energy** $E = \sum_i x_i^2$ and the autocorrelation at lag $k$, $A(k) = \sum_i x_i x_{i+k}$. Expanding the square $(x_{i+k}-x_i)^2$ and summing gives the classical polarization identity
$$2A(k) \;=\; 2E \;-\; \sum_i \bigl(x_{i+k}-x_i\bigr)^2 .$$
The subtracted term is the total squared interval across the lag — and by the moment identity above, that is precisely the *second moment of the pitch-interval histogram*. So:

> **The Moment Bridge.** *For a digit melody on a cyclic window,*
> $$2A(k) \;=\; 2E \;-\; \sum_{v=0}^{9} v^2\, N_k(v),$$
> *where $N_k(v)$ is the number of positions at which the lag-$k$ pair sounds a $v$-semitone interval.*

This is the exact translation between the temporal language and the pitch language. It says three things at once.

**First: autocorrelation is a legitimate pitch statistic** — but only one number's worth. Two melodies with the same energy and the same lag-$k$ interval histogram necessarily have the same lag-$k$ autocorrelation, no matter how unrelated they are otherwise.

**Second: the bridge runs one way only.** Autocorrelation compresses a ten-bin histogram into a single weighted sum, so it cannot possibly recover the histogram. A tiny example makes this vivid. Take the four-note cyclic melodies
$$d = (0,0,0,5), \qquad e = (0,3,0,4).$$
Both have energy $25$. Both have lag-$1$ autocorrelation exactly $0$ — every adjacent product vanishes. Yet $d$ contains **two unisons** at lag $1$ (the pairs $0\!-\!0$), and $e$ contains **none**; $e$'s lag-$1$ intervals are $3,3,4,4$. Identical correlation, different music. A correlation statistic can never certify a claim about which intervals occur.

**Third: the peak has a clean meaning.** Autocorrelation at lag $k$ hits its ceiling, $A(k) = E$, exactly when *every* lag-$k$ interval is a unison — that is, when the melody repeats itself with period $k$. A perfect lag-$12$ peak is a statement that $N_{12}(0)$ carries all the mass. It is a unison phenomenon. The value $v=12$ carries zero mass, always.

---

## What "no correlation" should mean

If a study reports a lag-$12$ anomaly, it needs a baseline: what would the interval histogram look like for a structureless melody? Count ordered pairs of digits at each interval size. For an alphabet of $b$ digits, the number of ordered pairs $(a,c)$ with $|a-c| = v$ is
$$P_b(v) = \begin{cases} b, & v = 0,\\ 2(b-v), & 0 < v < b,\\ 0, & v \ge b.\end{cases}$$
This **triangular null distribution** has total mass $b^2$ — all ordered pairs — and $P_{10}(12) = 0$, one more sighting of the missing octave. Its second moment has a closed form,
$$\sum_{v} v^2 P_b(v) = \frac{b^4 - b^2}{6},$$
which for $b = 10$ equals $1650$: a mean squared interval of exactly $16.5$ semitones$^2$ over the $100$ ordered digit pairs.

Feed that into the Moment Bridge and the baseline becomes an equation rather than a simulation.

> **The Null Deficit Law.** *If the lag-$k$ interval histogram of a digit melody is exactly $m$ copies of the triangular null distribution, then*
> $$12\,(E - A(k)) = m\,(b^4 - b^2).$$
> *In the decimal case, $E - A(k) = 825\,m$ exactly.*

No randomness, no simulation, no structural hypothesis about the melody — a purely combinatorial identity. A measured deficit that differs from $825m$ is the only legitimate form of a "lag-$k$ anomaly" claim; a deficit that matches it is precisely no news at all.

---

## Time has arithmetic. Pitch has none.

Having separated the two variables, one can ask what structure each of them carries on its own. The answers are strikingly asymmetric.

### The temporal variable is rigid

Track the **lag spectrum** of a melody: the largest interval it ever sounds across a given lag,
$$M_x(\ell) = \sup_i\, |x_i - x_{i+\ell}| .$$
For decimal melodies $M_x(\ell) \le 9$ always. And it obeys a triangle inequality on lags:
$$M_x(k+\ell) \le M_x(k) + M_x(\ell),$$
because going from time $i$ to time $i+k+\ell$ can be routed through the intermediate note at time $i+k$, and pitch distance is a metric. In the language of *tropical* (min-plus) algebra — where "addition" is taking a minimum and "multiplication" is ordinary addition — this says exactly that $\ell \mapsto M_x(\ell)$ is a **seminorm on the additive monoid of lags**, submultiplicative for the tropical product.

The kernel of a seminorm is where the story gets interesting. The lags with $M_x(\ell) = 0$ are exactly the **unison lags**: those $\ell$ for which $x_i = x_{i+\ell}$ for *every* $i$, i.e. the periods of the melody. These form a monoid — sums of periods are periods — but far more is true:

> **Rigidity of the unison lags.** *The set of unison lags is closed under greatest common divisors. Consequently, if a melody has any positive period at all, its unison lags are precisely the multiples of a single number, its minimal period. If it has none, the only unison lag is $0$. And two coprime periods force the melody to be constant.*

The gcd-closure is proved by a Euclidean descent: if $p$ and $q$ are both periods then so is $q \bmod p$, and iterating the Euclidean algorithm lands on $\gcd(p,q)$.

The consequence for the lag-$12$ debate is sharp and complete:

> **Lag Twelve, Resolved.** *If a decimal melody has perfect lag-$12$ correlation — i.e. $M_x(12) = 0$ — then its minimal period divides $12$, every lag-$12$ pair sounds a unison, and no lag-$12$ pair sounds an octave. If instead $M_x(12) \ne 0$, then some lag-$12$ pair sounds a nontrivial interval, of size between $1$ and $9$ semitones — again never an octave.*

Either way, the answer is about periods and unisons. The octave never appears in the dichotomy, because it cannot appear in the melody.

And the temporal structure is genuinely nonlinear: subadditivity is a one-way street. The square wave $s(i) = 7 \cdot (\lfloor i/12 \rfloor \bmod 2)$ — seven semitones up, twelve beats, seven back down — has lag spectrum $7$ at lag $12$ (every lag-$12$ pair jumps a perfect fifth, *no unisons at all*), yet lag spectrum $0$ at lag $24$, since the melody is $24$-periodic. Maximal regularity at one lag; maximal irregularity at half of it. A vanishing spectrum at $2\ell$ says nothing about $\ell$.

### The pitch variable is free

The interval histogram has no such rigidity. Its only constraint is its support.

> **The Inverse Theorem.** *Let $N$ be any assignment of multiplicities to the interval sizes $0,1,\ldots,9$ with total mass $n$. Then there exists a decimal melody whose lag-$1$ interval histogram, on the window of length $n$, is exactly $N$. Moreover, for every lag $\ell \ge 1$ there is a decimal melody whose lag-$\ell$ histogram on a window of length $\ell n$ is exactly $\ell \cdot N$.*

The construction is charming. First rearrange the demanded intervals into non-increasing order using a *layer-cake* formula: at time $t$, ask how many of the levels $w = 1,\ldots,9$ still have tail mass $\sum_{u \ge w} N(u)$ exceeding $t$; that count is the interval to be played at step $t$. Then play the intervals with an **alternating walk**: start at pitch $0$, step *up* by the demanded amount at even times, *down* at odd times. Because the demands are non-increasing, the walk never escapes the ten-note range — it zig-zags inside a shrinking band — and every demanded interval is realized exactly once. Finally, to move a histogram from lag $1$ to lag $\ell$, **interleave**: run $\ell$ independent copies of the melody, one per residue class, each advancing one step per $\ell$ beats. Every lag-$\ell$ comparison in the interleaved melody is a lag-$1$ comparison in the original, and each is realized $\ell$ times over.

The consequences are pointed. Every constant interval value $v \le 9$ occurs as the constant lag-$12$ interval of some decimal melody, and no value above $9$ ever occurs at any lag. In particular there is a decimal melody whose ten-pair window contains one unison and nine major sixths, and still no octave. **The temporal lag constrains nothing whatsoever about the pitch histogram beyond its support.**

So the two variables sit at opposite ends of a spectrum of rigidity: lags are organized by divisibility, pitches are unconstrained, and the only bridge between them is a single number — the second moment.

---

## A matrix of intervals that squares to itself

There is one more structure worth meeting, because it explains *why* the temporal side behaves tropically. Collect all pairwise intervals of the first $n$ notes into a matrix $A$ with $A_{ij} = |x_i - x_j|$, and read it inside the min-plus semiring: matrix "multiplication" takes
$$(A \odot A)_{ij} = \min_k \bigl(A_{ik} + A_{kj}\bigr),$$
the cheapest two-step voice-leading from note $i$ to note $j$ through an intermediate note $k$.

> **Tropical idempotency.** *The interval matrix satisfies $A \odot A = A$, and hence $A^{\odot m} = A$ for every $m \ge 1$.*

One direction is the triangle inequality: no detour beats the direct interval. The other is choosing $k = i$, whose cost is $0 + A_{ij}$. Musically: the cheapest voice-leading between two notes, allowed any number of intermediate stops, is simply to move there directly. The matrix is its own tropical Kleene closure — it is already "shortest-path complete". Its diagonal is the tropical unit (every note is a unison with itself), it is symmetric, its entries never exceed $9$, and no entry ever equals $12$.

---

## And what about pitch classes?

The standard fix for octave confusion in music theory is to work with *pitch classes*: reduce every pitch modulo $12$, so that notes an octave apart become the same. On the digit scale this fix is, delightfully, empty.

> *On a ten-note scale, reduction modulo $12$ is injective: two digits have the same pitch class exactly when they are the same digit. Consequently interval classes carry exactly the same information as intervals — nothing is identified, nothing is lost.*

Octave equivalence is a no-op below the octave. The boundary is sharp: move to base $13$, and the digits $0$ and $12$ finally become octave-equivalent while remaining different notes. From that alphabet on, mod-$12$ analysis and interval analysis genuinely diverge. Below it, they are the same theory wearing different clothes.

---

## The moral

None of this says the digit-melody game is worthless. It says something more useful: the game has two dials, and they must be turned separately.

Turn the **temporal** dial and you enter a world of arithmetic rigidity, where the answers are about periods, divisibility, gcds, and a tropical seminorm on the monoid of lags. Turn the **pitch** dial and you enter a world of complete freedom, where every histogram is achievable at every lag, and the only law is that a ten-note alphabet cannot produce an interval larger than nine semitones.

An autocorrelation is a bridge between the two — but it is a bridge of width one, carrying the second moment across and leaving the rest of the histogram behind. If a claim about music is to be extracted from a sequence of digits, it has to be extracted from the interval distribution at a clearly specified pair of positions, measured against the triangular null distribution and its exact deficit law $E - A = 825m$.

The digits of $\pi$ may well be beautiful to listen to. But whatever they contain, it is not an octave — and the reason is not deep statistics. It is that nobody gave them enough notes.
