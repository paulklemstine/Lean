# The Six-Sevenths Law: How Ties Put a Ceiling on What a Measurement Can Tell You

## A dial that reads the bottom of a number

Suppose you are handed a 60-bit integer and asked to guess something about it — how long a certain computation will take, say, or how quickly some downstream process will succeed. You are allowed one cheap look. What should you look at?

One very cheap look is the *trailing-zero count*: how many zeros the number ends with in binary. Write $T(x)$ for that quantity — equivalently, the exponent of the largest power of two dividing $x$. It costs a single machine instruction. It is the humblest statistic imaginable, and yet, on real data, it works surprisingly well: in a controlled experiment on uniformly random 60-bit words, the rank correlation between $T$ and the measured downstream rate came out at

$$\rho = 0.669, \qquad \text{95\% interval } [0.634,\, 0.705],$$

comfortably inside the pre-registered acceptance band $[0.55, 0.85]$, and beating the obvious rival statistic — the *popcount*, the number of one-bits — by $+0.151$ with interval $[0.107, 0.193]$.

Now comes the question that this article is really about. A rank correlation of $0.669$ sounds respectable. But is it? Could $T$ have done better? Is $0.669$ close to what the statistic is *capable* of, or is it leaving most of its potential on the table? And, more sharply: when you change how you generate the inputs — say, from uniform 60-bit words to words with exactly thirty one-bits — does the yardstick itself move?

It does. And it moves according to a law with a startlingly clean constant in it: $6/7$.

## Ties are the enemy of rank

Rank correlation works by turning raw values into positions in a queue. Whatever the raw scale, you sort the observations and correlate the sort positions. This makes rank methods robust and scale-free, and it introduces a single, unavoidable weakness: **ties**.

A statistic that takes very few distinct values sorts your observations into a few large clumps. Within a clump, the statistic simply cannot tell you which item should come first — you are forced to give every member the same average rank. That lost resolution is not a defect of the data or of the model; it is a hard, arithmetic ceiling on how well the statistic could *ever* correlate with anything.

Here is the ceiling, exactly. Suppose your statistic partitions $n$ observations into tie blocks of sizes $m_1, m_2, \dots, m_k$ (so $\sum_j m_j = n$). Then no matter how perfectly the truth lines up with your statistic, the squared Spearman rank correlation you can attain is at most

$$\rho^2_{\max} \;=\; 1 \;-\; \frac{\sum_j (m_j^3 - m_j)}{n^3 - n}.$$

The formula has a pleasing reading: $n^3 - n$ is the total "rank budget" of a sample of size $n$, and each tie block of size $m$ burns $m^3 - m$ of it. If nothing is tied, every $m_j = 1$, nothing is burnt, and the ceiling is $1$. If everything is tied into one block, $m_1 = n$, the whole budget is burnt, and the ceiling is $0$ — a constant statistic tells you nothing, as it should.

The interesting cases are in between, and the trailing-zero count sits in a very interesting place indeed.

## The dyadic staircase and the number $6/7$

Draw a $b$-bit word uniformly at random. How many words have exactly $k$ trailing zeros? Exactly half end in a $1$, a quarter end in $10$, an eighth in $100$, and so on. So the tie blocks of $T$ are the *dyadic staircase*

$$2^{b-1},\; 2^{b-2},\; \dots,\; 2,\; 1,\; 1,$$

the final $1$ being the all-zero word, which sits alone in its own class. Feed this into the ceiling formula, put $N = 2^b$, and after a short computation the sums telescope into something exact and unexpectedly tidy:

$$\rho^2_{\max}(\text{uniform, } b \text{ bits}) \;=\; \frac{6}{7}\left(1 + \frac{1}{N(N+1)}\right), \qquad N = 2^b.$$

At $b = 60$ the correction term is about $7 \times 10^{-37}$. For all practical purposes the uniform ceiling *is* $6/7 = 0.857142\ldots$

Where does $6/7$ come from? From the cubes. A geometric tie profile with ratio $1/2$ has cube sum in ratio $1/8$, so the burnt fraction of the rank budget is $\frac{1}{1 + 2 + 4} = \frac{1}{7}$ of the total, and $1 - 1/7 = 6/7$. The seven is $1 + 2 + 4$; equivalently it is the value at $c = 1$ of the polynomial $(1+c)^3 - c^3 = 3c^2 + 3c + 1$. Keep that polynomial in mind — it is about to reappear twice more, in places that look completely unrelated.

The first consequence is already useful. The measured $\rho = 0.669$ gives $\rho^2 = 0.4476$, and even the top of the acceptance band, $0.85$, gives $0.7225$. Both are comfortably below $6/7$. So the measurement is nowhere near ceiling-limited: the dial has headroom, and a reading in the band means what it appears to mean.

## Change the draw, move the ceiling

Uniform words are one way to generate inputs. Another, very common in practice, is a *fixed-weight* draw: choose uniformly among the $b$-bit words with exactly $w$ one-bits. This is what you get when the generator is designed to control Hamming weight — and it changes the tie structure of $T$ completely.

Count the weight-$w$ words of $b$ bits whose lowest set bit sits in position $k$: fix that bit, and distribute the remaining $w-1$ ones among the $b-1-k$ positions above it. There are

$$\binom{b-1-k}{\,w-1\,}$$

such words. So the tie profile of $T$ under a fixed-weight law is not a geometric staircase but a *hockey stick*: a column of binomial coefficients whose sum, by the classical hockey-stick identity, is exactly $\binom{b}{w}$, as it must be.

Take the balanced case $b = 2v+2$, $w = v+1$ — half the bits are ones. The profile is
$$m_0 = \binom{2v+1}{v},\quad m_1 = \binom{2v}{v},\quad m_2 = \binom{2v-1}{v}, \quad \dots,\quad 1 .$$
At $v = 1$ (four bits, weight two) this is $3, 2, 1$; at $v = 2$ (six bits, weight three) it is $10, 6, 3, 1$; at $v = 3$, $35, 20, 10, 4, 1$.

Look at the ratios. Below the top the profile halves — or better than halves — at every step, exactly like the dyadic staircase. But the *first* step does not: $m_1/m_0 = (v+1)/(2v+1)$, which is a hair more than $1/2$. That single anomalous step is the entire difference between the two draw laws.

And the size of the anomaly is a number every combinatorialist recognises. Writing $\mathrm{Cat}_v = \frac{1}{v+1}\binom{2v}{v}$ for the $v$-th Catalan number, one has

$$m_0 = (2v+1)\,\mathrm{Cat}_v, \qquad m_1 = (v+1)\,\mathrm{Cat}_v, \qquad \textbf{so}\quad 2m_1 - m_0 = \mathrm{Cat}_v .$$

The shortfall of the first step from exact halving is a Catalan number — a count of Dyck paths, of balanced bracketings, of binary trees — appearing here as the measure of how far a fixed-weight bitstream deviates from a uniform one in the eyes of a rank statistic. For $v = 1,2,3,4$ the defect is $1, 2, 5, 14$: the Catalan numbers, on the nose.

Because the anomalous step makes the top of the profile slightly *flatter* than dyadic — a little less concentrated at the top, a little more mass just below — you might guess the balanced ceiling comes out slightly *higher*. It comes out lower. And this is the first genuinely surprising theorem of the story.

## The sandwich

> **Two-sided attractor.** For every $v \ge 2$, the balanced fixed-weight ceiling at bit length $2v+2$ is strictly below $6/7$, while the uniform ceiling at the same bit length is strictly above it. The two laws approach the universal constant from opposite sides and meet only in the limit.

Quantitatively the balanced ceiling satisfies
$$\frac{6}{7} - \frac{1}{15(v+1)} \;<\; \rho^2_{\max}(\text{balanced}) \;<\; \frac{6}{7},$$
so the deficit decays like $1/v$ — a *far* slower approach than the uniform side, whose excess over $6/7$ decays like $4^{-b}$. At bit length 60, the uniform ceiling is $6/7$ to thirty-six decimal places, while the balanced ceiling is $0.856239$, short of $6/7$ by about $9 \times 10^{-4}$.

There is one exception, and it is exact: at bit length four, the balanced profile $3,2,1$ has ceiling *precisely* $6/7$. The strict inequality begins at bit length six, where the ceiling is exactly $563/665$; at bit length eight it is exactly $1386/1633$.

Proving the strict bound at *every* bit length turned out to be the hard part of the story, for a reason worth telling. The geometric estimate "the profile at least halves below the top" is *tight* — it says exactly $6/7$, with no room to spare. All the strictness is carried by the Catalan defect, which is only of relative size $1/(2v+1)$. But if you try to capture the defect by expanding the top three, four, or $K$ blocks of the profile and bounding the rest crudely, the crude tail costs you $8^{-K}$, so a $K$-block argument only ever reaches $v \lesssim 8^K$. Adding blocks multiplies your reach by eight and gets you nowhere. The fix is to stop truncating: one runs a single induction *down the entire profile*, carrying an accumulated deficit against the geometric ideal whose coefficient grows linearly in the remaining depth. The coefficient is the fixed point of the recursion $e_{s-1} = (s-1) + e_s/8$, which is precisely why the induction closes.

## One boundary, at half weight

The balanced law is one point on a line. Vary the weight fraction $\theta = w/b$ continuously and you get a whole family of draw laws, each with its own hockey-stick profile and its own ceiling. Where does the ceiling sit relative to $6/7$?

> **Half-weight dichotomy.** For every fixed-weight draw law, the ceiling of the trailing-zero statistic is at most $6/7$ if the weight is at least half the bit length ($2w \ge b$), and strictly greater than $6/7$ if the weight is strictly below half ($2w < b$). The sign of $\rho^2_{\max} - 6/7$ is determined by the weight fraction alone, and the single phase boundary sits exactly at $2w = b$.

That is a genuine phase transition, with a sharp location and no intermediate regime. It is sharp in the strongest sense: at weight two on five bits — one step below half — the profile is $4,3,2,1$ and the ceiling is exactly $10/11 = 0.909\ldots$, above $6/7$; at weight two on four bits — exactly half — it is exactly $6/7$.

On the sparse side, the excess is quantified: one step below half weight the ceiling already exceeds $6/7$ by at least $\frac{1}{7(2v+3)}$.

And here the polynomial from before returns. Write the bit length as $b = w + r$ with $r = c\,w$ and let $w \to \infty$. The whole hockey-stick tail is dominated by a geometric series with ratio $r/(w+r)$, and the ceiling exceeds $6/7$ exactly when

$$(1+c)^3 - c^3 \;=\; 3c^2 + 3c + 1 \;>\; 7,$$

that is, exactly when $c > 1$ — which is exactly the half-weight line. The seemingly crude geometric estimate is asymptotically exact at the boundary, and the $7$ in $6/7$ and the location of the phase transition are two faces of the identity $3\cdot 1^2 + 3\cdot 1 + 1 = 7$.

## Why the rival collapses

The experiment compared $T$ against the popcount baseline, and $T$ won by $+0.151$. Is that a real advantage or a tie artefact?

Two theorems settle it, one for each draw law, and they point in the same direction for different reasons.

On **uniform** draws at 60 bits, the popcount has tie blocks $\binom{60}{k}$, whose ceiling is above $0.99$ — *higher* than the trailing-zero ceiling of $6/7$. So popcount has strictly more tie headroom than $T$ and still lost by $0.151$. The advantage runs *against* the headroom ordering and therefore cannot be manufactured by tie granularity.

On **fixed-weight** draws, the collapse is total: if the draw law fixes the popcount, then the popcount is a constant. Its tie profile is the single block $\big[\binom{b}{w}\big]$, and a one-block profile has ceiling exactly $0$. The baseline is not merely worse — it is *informationless*, while $T$ retains a ceiling of nearly $6/7$. On the balanced half of the deployment envelope, the advantage of $T$ over popcount is not an empirical finding at all; it is forced by the geometry of the draw law.

## The rule behind all the rules

Every comparison above is a comparison of cube sums at a fixed total, and that is not an accident. Since $\rho^2_{\max} = 1 - \frac{\sum_j m_j^3 - n}{n^3 - n}$, at fixed sample size the ceiling is a strictly *decreasing* function of $\sum_j m_j^3$ and of nothing else. So:

> **Transfer principle.** Move a single observation from a smaller tie block into a larger one. The cube sum strictly increases, and the ceiling strictly falls.

Concentration of ties destroys rank resolution; spreading them out preserves it. This is the rank-statistics analogue of a Robin-Hood, or Schur-convexity, argument, and the engine is once more the cubic difference $(x+1)^3 - x^3 = 3x^2 + 3x + 1$, strictly increasing in $x$. For two blocks it settles everything at once: among all ways of splitting $n$ observations into two tie classes, the even split maximises the ceiling, and pushing the split further apart lowers it monotonically. At $n = 12$: the split $6\!+\!6$ gives $0.7552$, then $5\!+\!7$ gives $0.7343$, $4\!+\!8$ gives $0.6713$, $3\!+\!9$ gives $0.5664$, down to $1\!+\!11$ at $0.2308$.

## What is $6/7$ a fact about?

Not about bits, it turns out, and not about the response variable. Run the same analysis over an alphabet of $q$ letters — count trailing zeros in base $q$ — and the tie profile is geometric with ratio $1/q$. The exact ceiling for uniform length-$b$ strings is

$$\rho^2_{\max}(q, b) \;=\; \frac{3q}{q^2 + q + 1}\left(1 + \frac{1}{q^b(q^b+1)}\right),$$

whose universal constant $\frac{3q}{q^2+q+1} = 1 - \frac{(q-1)^2}{q^2+q+1}$ equals $6/7$ at $q = 2$. There is that denominator again: $q^2 + q + 1$ is $\big((1+c)^3 - c^3\big)$ in another disguise, the same cubic identity for the third time.

The constant is *strictly decreasing* in the alphabet size: $6/7 \approx 0.857$ for bits, $9/13 \approx 0.692$ for trits, $12/21 \approx 0.571$ for base four. Richer alphabets produce fewer ties, which sounds like it should help — but it makes the trailing-zero statistic itself coarser relative to the sample, and the ceiling falls.

This has a sharp practical edge. The acceptance band $[0.55, 0.85]$ used in the experiment is *binary-specific*. Over any alphabet with three or more letters and length at least two, the ceiling is at most $7/10$, so a reading of $0.85$ would not be merely surprising — it would be arithmetically impossible. A band imported unchanged from the binary setting would be silently unfalsifiable at its top end.

## Back to the measurement

With all of this in hand, the original 60-bit reading can be placed exactly.

- Every value in the acceptance band $[0.55, 0.85]$ — not just the observed $0.669$ — lies strictly below the ceiling under *both* draw laws at bit length 60: uniform, where the ceiling is $6/7$ to thirty-six places, and balanced, where it is $0.856239$. The band is admissible; a reading inside it is a statement about the world, not about the arithmetic of ties.
- The observed $\rho^2 = 0.4476$ leaves roughly half the available rank budget unused, so the dial is not saturated and there is genuine room for a better statistic to do better.
- The advantage over popcount survives both audits: it runs against the headroom ordering on uniform draws, and it is structurally forced on fixed-weight draws.
- Robustness to a mis-specified generator is quantified: for every weight fraction between $1/2$ and $3/5$ — a ten-percentage-point imbalance — the ceiling stays above $0.73$, still above $0.85^2 = 0.7225$. The band remains admissible even if the generator drifts.

None of these are statements about one experiment. They are statements about what any rank-based validation of a coarse statistic can possibly mean, and they come with exact constants.

## The moral

Rank correlations are usually read as if the number $1$ were the target. For a coarse statistic it is not; the target is a computable constant determined entirely by how the statistic clumps its inputs, and that constant depends on the *draw law* as much as on the statistic. For trailing zeros the constant is $6/7$ — approached from above by uniform draws, from below by balanced draws, crossed exactly at half weight, and equal to $3q/(q^2+q+1)$ over a $q$-letter alphabet.

Along the way, the deviation between the two draw laws turned out to be a Catalan number, and one cubic identity, $(1+c)^3 - c^3 = 3c^2+3c+1$, turned out to be simultaneously the reason ties cost what they cost, the reason the phase boundary sits at half weight, and the reason the universal constant has $q^2+q+1$ in its denominator.

That is the sort of thing that happens when you take a humble question seriously: *compared to what?*
