# The Coupons That Refuse to Be Collected

## A puzzle wearing a familiar disguise

Almost everyone has, at some point, fallen for the same small trap. You buy
cereal to complete a set of collectible cards, or you scratch lottery tickets
hoping to fill out a bingo board, and you notice that the *last* few items always
seem to take forever. This is the famous **coupon collector's problem**: if there
are $n$ different coupons and every purchase gives you one chosen uniformly at
random, the expected number of purchases needed to own all $n$ of them is
roughly $n \ln n$. The tail of the collection is where all the pain lives.

Now change the game slightly. Instead of receiving *one* coupon per draw, imagine
each draw hands you a small *bundle* of coupons at once. Bundles cover more
ground, so you finish faster. But here is the subtle part: **how you choose the
bundles matters**. Two collectors, each receiving bundles of the same size, drawn
the same number at a time from the same pool of coupons, can still finish at
noticeably different average speeds — purely because of the *combinatorial shape*
of the bundles.

This article is about a startlingly clean instance of that phenomenon, built out
of one of the most beautiful objects in mathematics: the **Fano plane**. The
punchline is counterintuitive. A collection of bundles engineered to be perfectly
balanced and efficient — the seven lines of the Fano plane — turns out to be
*slower*, on average, than simply grabbing random bundles of the same size. The
structure that looks optimal is, for this particular task, a handicap.

## The Fano plane in one paragraph

Picture seven points. Group them into seven three-point "lines" so that the whole
arrangement is as symmetric as possible: every point lies on exactly three lines,
every line contains exactly three points, and — the magic condition — **any two
points lie on exactly one common line**. This object exists, it is unique, and it
is the Fano plane. A convenient way to write its seven lines is the cyclic recipe
"start at $i$, then take $i+1$ and $i+3$, all modulo $7$":
$$\{0,1,3\},\ \{1,2,4\},\ \{2,3,5\},\ \{3,4,6\},\ \{4,5,0\},\ \{5,6,1\},\ \{0,2,6\}.$$
It is the smallest **projective plane**, the geometric world where "any two lines
meet in exactly one point" and "any two points determine exactly one line" hold
in perfect duality. It shows up in error-correcting codes, in finite geometry, in
the multiplication table of the octonions, and — as we will see — in a
probability puzzle about collecting coupons.

## Two ways to bundle seven coupons

Our ground set is the seven points of the Fano plane. Each "draw" gives us a
three-point block, and a point is *collected* the first time a drawn block
contains it. We keep drawing until all seven points are collected, and we ask for
the **expected cover time** — the average number of draws needed.

We compare two collectors.

- **The geometer** draws uniformly from the *seven Fano lines*. Every block is one
  of those seven perfectly balanced triples.
- **The gambler** draws uniformly from *all thirty-five* three-point subsets of
  the seven points. Any triple is fair game; there are $\binom{7}{3}=35$ of them.

Both draw blocks of size three. Both draw uniformly. Intuition says the tidy,
balanced Fano design should be at least as good as the anarchic full collection.
The intuition is wrong.

## Turning "cover time" into arithmetic

To compute an average cover time exactly, we use a classic trick. For each point
$p$, let $\tau_p$ be the first draw that collects $p$. The cover time is the
*latest* of these, $\max_p \tau_p$. There is a beautiful identity — the
inclusion–exclusion principle applied to a maximum — that turns a maximum of
random times into an alternating sum of much simpler *minimums*:
$$\mathbb{E}\big[\max_p \tau_p\big] \;=\; \sum_{\varnothing \neq S}\;(-1)^{|S|+1}\,\mathbb{E}\big[\min_{p\in S}\tau_p\big],$$
where the sum runs over every nonempty set $S$ of points.

Each minimum is easy. The quantity $\min_{p\in S}\tau_p$ is simply the first draw
of *any* block that touches $S$ — a block with at least one point in $S$. If we
let $c(S)$ be the number of blocks meeting $S$, out of $|B|$ total blocks, then
each draw hits $S$ with probability $c(S)/|B|$, and the average wait for the first
hit is the reciprocal, $|B|/c(S)$. Substituting gives a completely explicit
formula:
$$\mathbb{E}[\text{cover time}] \;=\; \sum_{\varnothing \neq S}\;(-1)^{|S|+1}\,\frac{|B|}{c(S)}.$$

Everything now reduces to counting: for each of the $2^7-1=127$ nonempty subsets
$S$, how many blocks meet $S$? The geometer and the gambler differ only through
these coverage counts $c(S)$.

## The verdict

Carrying out the sum exactly — with fractions, no rounding — yields two clean
rational numbers.

For the gambler, drawing all thirty-five triples,
$$\mathbb{E}[\text{cover time}] \;=\; \frac{85691}{15810} \;\approx\; 5.42005.$$

For the geometer, drawing the seven Fano lines,
$$\mathbb{E}[\text{cover time}] \;=\; \frac{163}{30} \;\approx\; 5.43333.$$

And so
$$\frac{85691}{15810} \;<\; \frac{163}{30}.$$

The Fano lines are **strictly slower** — by about $0.0133$ of a draw on average.
The margin is small but it is exact and it is real. The elegant design loses the
race.

## Why elegance backfires

The reason cuts to the heart of what "collecting" rewards. A collector wants
*independence*: each new block should, as much as possible, surprise you with
points you did not already have. The Fano plane is built to do the opposite. Its
defining property — any two points share exactly one line — means the seven lines
overlap in a rigid, correlated pattern. Once you have collected a point, the lines
that could deliver its Fano-partners are concentrated, not spread out. Coverage
events become **positively correlated**: covering one point makes its collinear
neighbors *more* likely to already be covered by the same lucky draws, and less
likely to be picked up by future ones. Positive correlation is exactly what
lengthens the tail of a coupon collection.

The gambler's thirty-five triples have no such conspiracy. They are as spread out
as three-element blocks can be, so their coverage events are closer to
independent, and the wait for the final straggler is shorter. Structure, here, is
a liability precisely because the task rewards disorder.

## A conjecture that fell

This little inequality is not just a curiosity. In the 1970s a natural conjecture
of Grünbaum and Yaakobi predicted the opposite ordering — that the balanced
design should win. The exact computation above **disproves** it in the smallest
case. The perfectly symmetric object that every geometer loves is, for coupon
collection, a genuine underdog.

## Does it keep happening?

The Fano plane is only the first in an infinite family. For every prime power
$q \ge 2$ there is a projective plane of order $q$: it has $n = q^2+q+1$ points,
the same number of lines, and every line is a $(q+1)$-point block with the same
"any two points on exactly one line" magic. The natural question is whether the
geometer *always* loses.

**Conjecture.** For every prime power $q \ge 2$, drawing uniformly random lines of
the projective plane of order $q$ takes strictly longer, on average, to cover all
$q^2+q+1$ points than drawing uniformly random $(q+1)$-subsets of the same points.

The evidence is encouraging. Repeating the exact computation for the projective
plane of order $q=3$ — thirteen points, thirteen lines of four points each,
compared against all $\binom{13}{4}=715$ four-point subsets — gives
$$\text{lines: } \frac{43633}{4620}\approx 9.44437, \qquad \text{uniform: } \approx 9.42973,$$
and once again the lines are slower. The same pattern holds in the tested cases
$q=4$ and $q=5$. A general proof remains open, but the mechanism points the way:
for every fixed target set $S$, the number of *lines* meeting $S$ can never exceed
the number of $(q+1)$-subsets meeting $S$, and the two counts diverge most exactly
when $S$ is built out of a few whole lines. This per-set domination survives the
alternating inclusion–exclusion sum and should force the strict inequality in
general.

## The moral

The coupon collector's problem is usually told as a lesson about waiting: the last
few items are agony. The Fano plane adds a second, sharper lesson. When you get to
*design* your draws, symmetry and balance are not automatically your friends. A
structure optimized for one purpose — the flawless incidence geometry of a
projective plane — can be quietly pessimal for another. Sometimes the fastest way
to collect everything is to embrace a little chaos, and the most beautiful object
in the room is the one that finishes last.
