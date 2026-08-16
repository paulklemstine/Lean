# The Ladder Hidden in the Data: Why a Measured Number Was Never Free to Be Anything Else

## Three numbers that looked like noise

Imagine an experiment that produces a single number. You run it three times, with three different random starting conditions, and you get three answers:

$$96, \qquad 112, \qquad 128.$$

The first instinct of anyone trained in the empirical sciences is to reach for statistics: compute a mean ($112$), compute a median ($112$), note that the spread is $\pm 16$, and report a distribution. The second instinct — the interesting one — is to ask whether those three numbers *could* have come out any other way.

They could not. And the reason is not statistical at all. It is arithmetic.

Write the three numbers in binary:

$$96 = 1100000_2, \qquad 112 = 1110000_2, \qquad 128 = 10000000_2.$$

Every one of them has the same shape: a solid block of $1$s, then a solid block of $0$s. Nothing ragged, nothing interleaved. In a range containing $128$ possible values, these three all landed on the same rare template. That is the clue this article is about.

## Staircase numbers

Call a positive integer a **staircase number** if its binary expansion consists of a nonempty run of $1$s followed by a run of $0$s. Every such number has the form

$$\mathrm{st}(b, j) \;=\; 2^{b}\,(2^{j} - 1) \;=\; 2^{\,b+j} - 2^{b},$$

where $j \ge 1$ counts the ones and $b \ge 0$ counts the trailing zeros. So $96 = \mathrm{st}(5,2)$, $112 = \mathrm{st}(4,3)$, and $128 = \mathrm{st}(7,1)$ — the powers of two are the staircase numbers with a single one.

The name is apt: fix the total width $n = b + j$ and let $j$ grow. You get

$$2^{n-1},\quad 2^{n} - 2^{n-2},\quad 2^{n} - 2^{n-3},\ \ldots,\ 2^{n} - 1,$$

a ladder of rungs climbing toward the top point $2^{n}$, each rung closing exactly half of the remaining gap. For $n = 7$: $64, 96, 112, 120, 124, 126, 127$, with $128$ overhead as the ceiling that the ladder approaches but never touches.

Two facts about this ladder are worth stating precisely, because everything else follows from them.

**The Midpoint Law.** *For all $b, j \ge 0$,*
$$2\,\mathrm{st}(b, j+1) \;=\; \mathrm{st}(b+1, j) \;+\; 2^{\,b+j+1}.$$
*Equivalently, the triple $\big(\mathrm{st}(b+1,j),\ \mathrm{st}(b,j+1),\ 2^{\,b+j+1}\big)$ is an arithmetic progression with common difference $2^{b}$.*

At $b = 4$, $j = 2$ this reads $2 \cdot 112 = 96 + 128$. The observed "mean equals median" was not a coincidence about the experiment; it is a theorem about consecutive rungs of a binary ladder. The proof is one line once you write $\mathrm{st}(b,j) = 2^{b+j} - 2^{b}$: both gaps telescope to $2^{b}$.

**The Fraction Law.** *For all $b, j \ge 0$,*
$$2^{\,j+1}\cdot \mathrm{st}(b, j+1) \;=\; \big(2^{\,j+1} - 1\big)\cdot 2^{\,b+j+1},$$
*so the rung with $j+1$ ones is exactly the fraction $\dfrac{2^{j+1}-1}{2^{j+1}}$ of the top point.*

At $j = 2$: $8 \cdot 112 = 7 \cdot 128$. The famous-looking "$7/8$" is the fraction $\frac{2^3 - 1}{2^3}$, and its appearance says only that the middle number carries three ones.

## The census: how many answers were even possible?

Here is where the argument turns from description into prediction. In the experiment that produced $96, 112, 128$, the quantity being measured was searched on a *grid*: only multiples of $16$ were tested, inside the window from $64$ to $128$. So ask the sharp question: **which staircase numbers lie in the window $(64, 128]$ and are divisible by $16$?**

Only three: $96$, $112$, $128$.

The three measured values were not a sample of a spread. They were the *entire population of admissible answers*. Three runs exhausted the space.

This generalises exactly. Fix a top point $2^{n}$ and a grid step $2^{g}$ with $g < n$, and consider the dyadic octave $(2^{n-1}, 2^{n}]$.

**The Census Theorem.** *A number in $(2^{n-1}, 2^{n}]$ is a staircase number divisible by $2^{g}$ if and only if it is $2^{n}$ itself or one of the rungs $2^{n} - 2^{\,n-j}$ with $2 \le j \le n - g$. Consequently the octave contains exactly*
$$n - g \;=\; \log_2\!\frac{\text{top point}}{\text{grid step}}$$
*admissible values.*

Two ingredients make it work. First, divisibility is transparent in the normal form: $2^{g} \mid \mathrm{st}(b,j)$ exactly when $g \le b$, because the odd part $2^{j}-1$ contributes no factors of two. Second, a staircase number in the octave has to have total width $n$ or be the top point itself — a two-sided squeeze, since any staircase rung satisfies $2^{\,b+j} \le 2\,\mathrm{st}(b,j) $ and $\mathrm{st}(b,j) < 2^{\,b+j}$.

The count is startling in its rigidity. Halving the grid step adds *exactly one* candidate — never two, never none. The number of possible answers grows logarithmically in the resolution of the search.

## The $7/8$ law is a law about rulers, not about the thing being measured

Set $r = n - g$, the *grid ratio*: how many halvings separate the grid step from the top point. When $r = 3$ — the grid is one eighth of the top point — the census has exactly three members, they form an arithmetic progression, and the middle one is

$$\frac{7}{8}\cdot 2^{n}.$$

That is the whole content of the "$7/8$ median". It is a property of the measuring grid. Any experiment, on any subject, whose answer is a staircase number, searched on a grid one eighth as coarse as its ceiling, will produce a three-point spread with median $\frac78$ of the ceiling. No property of the system under study is involved.

This immediately becomes a falsifiable prediction. Double the top point to $2^{8} = 256$ and double the grid to $32$: the grid ratio is still $3$, and the census must be

$$\{192,\ 224,\ 256\}, \qquad \text{median } 224 = \tfrac78 \cdot 256.$$

Refine the grid instead to $16$ at the same top point, and the grid ratio becomes $4$: a fourth candidate, $240$, enters, and the median moves to $232$ — which is *not* a census member, and not $\frac{7}{8}$ of anything. The law is sharp enough to break.

## What the spread can and cannot do

Because every census member lies between $\frac34 \cdot 2^{n}$ and $2^{n}$, the entire seed-to-seed spread is confined to a factor of $\frac43$:

**The Bracket.** *Every grid-admissible staircase value in the octave $(2^{n-1}, 2^{n}]$ satisfies $\tfrac34 \cdot 2^{n} \le k \le 2^{n}$, and the lower end $\tfrac34\cdot 2^n = 2^n - 2^{n-2}$ is attained whenever the grid is at least four times finer than the top point.*

So the top point is a *guarantee* — an upper bound valid for every run — and the cost of using it instead of the true smallest answer is at most $4/3$, permanently, independently of scale and of grid. That is a rare thing in an empirical setting: a variance bound derived without any variance estimate.

Two further structural facts sharpen the picture.

**Identifiability.** *A census determines the experiment that produced it.* The largest member recovers the top point $2^{n}$; the number of members recovers the grid ratio $n-g$ and hence the grid step. A reported set of values carries its own metadata.

**The grid step is a greatest common divisor.** *When $r = 3$, the two coarsest census members have $\gcd$ exactly the grid step $2^{g}$.* At the measured cell, $\gcd(96, 112) = 16$, and adjoining $128$ changes nothing. The resolution at which an experiment was run is recoverable from its outputs by a two-line computation.

**Self-similarity.** *Doubling both the top point and the grid step doubles the census pointwise.* The population is exactly scale-invariant under $(n, g) \mapsto (n+1, g+1)$ — the arithmetic shadow of a proportionality law.

## Divisibility: the members of a census never divide one another

How do the admissible values relate arithmetically? Completely rigidly. Divisibility of staircase numbers factors into two independent comparisons:

**The Product Order.** *For $j, j' \ge 1$,*
$$\mathrm{st}(b,j) \mid \mathrm{st}(b',j') \iff b \le b' \ \text{ and } \ j \mid j'.$$

Zero blocks compare by size; one blocks compare by divisibility — the latter because $(2^{j}-1) \mid (2^{j'}-1)$ precisely when $j \mid j'$, the classical Mersenne criterion. The family is therefore closed under greatest common divisors,
$$\gcd\big(\mathrm{st}(b,j), \mathrm{st}(b',j')\big) = \mathrm{st}\big(\min(b,b'),\ \gcd(j,j')\big),$$
but it is *not* closed under least common multiples: $3 = 11_2$ and $7 = 111_2$ are staircase numbers, while $\mathrm{lcm}(3,7) = 21 = 10101_2$ is emphatically not. The family is a meet-semilattice, never a sublattice, of the divisibility order.

A pleasing consequence: **within one census no member divides another.** Distinct admissible values in a single octave form an antichain. Two runs of the experiment can never report values one of which is a clean multiple of the other. At the measured cell this says $96 \nmid 112$, $112 \nmid 128$, $96 \nmid 128$.

## A detour into perfect numbers

Once the divisor structure is on the table, an old subject walks in. Since $2^{b}$ and $2^{j}-1$ are coprime, the sum-of-divisors function splits:

$$\sigma\big(\mathrm{st}(b,j)\big) = \big(2^{\,b+1} - 1\big)\,\sigma\big(2^{j}-1\big).$$

From this single identity a classification falls out.

* If $2 \le j \le b$ — at least two ones, at least as many zeros as ones — the number is **abundant**: $\sigma(k) > 2k$. Both $96 = \mathrm{st}(5,2)$ and $112 = \mathrm{st}(4,3)$ qualify.
* If $j = 1$ the number is a power of two, hence **deficient**. The top point $128$ is deficient.
* For $b \ge 1$, the number $\mathrm{st}(b,j)$ is **perfect** if and only if $j = b+1$ and $2^{j}-1$ is prime — Euclid's construction $2^{p-1}(2^{p}-1)$, with the Euler converse holding inside this family without any appeal to the general theory.

So the $\pm 16$ jitter observed in the experiment moves the answer *across the abundant/deficient boundary*: the two lower readings are abundant, the ceiling is deficient. And no rung of the width-$7$ ladder is perfect: perfection forces odd width $2b+1$, so $b = 3, j = 4$ is the only candidate at width $7$, and it fails because $2^4 - 1 = 15$ is composite. (The number in question is $120$ — famously the smallest number whose divisors sum to *three* times itself, but not perfect.)

There is even an asymptotic statement. Along the "add a zero" direction, the abundancy index $\sigma(k)/k$ increases strictly and converges:

$$\frac{\sigma\big(\mathrm{st}(b,j)\big)}{\mathrm{st}(b,j)} \ \nearrow\ \frac{2\,\sigma(2^{j}-1)}{2^{j}-1} \qquad (b \to \infty).$$

Abundance in this family has a ceiling that depends only on the number of ones — never on the size of the number. Growing a staircase number by padding zeros makes it more abundant, but only up to a finite, computable limit.

## How rare is a staircase number?

Finally, the question that makes the whole story a real constraint rather than a cute observation: how surprising is it that a measured value has staircase form?

Counting is easy once the census is known. Each octave $(2^{n}, 2^{n+1}]$ contains exactly $n+1$ staircase numbers (take $g = 0$ in the census theorem), so the totals satisfy $A(n+1) = A(n) + (n+1)$, giving

$$A(n) \;=\; \#\{\text{staircase numbers in } [1, 2^{n}]\} \;=\; \frac{n(n+1)}{2} + 1,$$

a triangular number plus one. At $n = 7$ there are $A(7) = 29$ staircase numbers among the $128$ values up to the top point — and only three of those survive the grid. And as the scale grows,

$$\frac{A(n)}{2^{n}} = \frac{n(n+1)/2 + 1}{2^{n}} \longrightarrow 0.$$

Staircase numbers have density zero: quadratically many among exponentially many. The chance that an unconstrained measurement lands on one, at scale $2^{n}$, decays like $n^{2}/2^{n+1}$. Landing on one repeatedly is not luck. It is structure.

## What the story teaches

The moral is a small methodological one, and it generalises far beyond the experiment that prompted it.

When a measured quantity is searched on a dyadic grid and the answer is reported as a power-of-two-flavoured number, the reported "distribution" may be describing the ruler rather than the world. Before fitting a variance, count the admissible values. If the count is $n - g$, and the values are forced into arithmetic progression, and the median is pinned at $\frac{2^{r}-1}{2^{r}}$ of the ceiling, then the spread you measured has no statistical content at all: it is the shape of your grid, reflected back at you.

The converse is the useful half. Because staircase numbers are so rare — density zero, exactly $n(n+1)/2 + 1$ below $2^n$ — the *observation* that measurements land on them, repeatedly, across scales, is a strong structural claim about the underlying quantity. It says the true answer is of the form "the ceiling minus a single power of two". That is a hypothesis with teeth, and the census theorem tells you exactly which experiment will break it: change the grid ratio from $3$ to $4$, and see whether the median moves to $232$ as the arithmetic demands, or stays at $\frac78$ of the ceiling as a genuinely non-grid effect would require.

Three numbers, one binary pattern, and a ladder that turns a noise estimate into a theorem.
