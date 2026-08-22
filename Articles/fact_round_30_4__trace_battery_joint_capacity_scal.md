# The Dial Battery: How Much Can a Handful of Clocks Tell You Apart?

## A room full of strangers and a bag of broken clocks

Imagine a room containing several thousand people, and imagine that you are not
allowed to look at any of them. All you are given is a set of *dials*. Each dial
is a small instrument: you feed it a person, and it clicks to one of finitely
many positions. One dial has $31$ positions, another $23$, another $9$, another
$8$. The dials are crude. Two different people can — and often do — leave a dial
in the same position. A single dial cannot possibly identify a stranger.

But you have several dials, and you may read them all at once. The question of
this article is the obvious one: **how much do you learn?** And the sharper
question behind it: **as you switch on more dials, how does what you learn
grow?**

This is not an idle puzzle. It is the shape of an enormous number of real
measurement problems. A geneticist reads a handful of markers and asks how many
individuals the panel can distinguish. A number theorist reduces an integer
modulo several small primes and asks when the residues determine the integer. A
privacy researcher asks how many coarse attributes — birth month, postcode
prefix, browser fingerprint fragment — it takes before a "de-identified" record
is unique. In every case the object is the same: a finite population, a family
of low-resolution readings, and a demand for a number saying how much the
readings reveal.

That number has a name: the **joint capacity** of the battery of dials. This
article is about what can be proved about it — not measured, *proved* — and
about how the proofs turn a table of experimental numbers into a story that
cannot have gone otherwise.

## The right way to count "how much you learn"

Fix a finite population $\Omega$ with $N = |\Omega|$ individuals, and a reading
$f$ that assigns to each individual $x$ some label $f(x)$. For each label $a$
that actually occurs, let $n_a$ be the number of individuals carrying it. The
labels partition the room into blocks; $n_a$ is the size of block $a$.

The **capacity** of the reading is

$$H(f) \;=\; \sum_{a} \frac{n_a}{N}\,\log_2\!\frac{N}{n_a} \quad \text{bits.}$$

Read it out loud: pick a person uniformly at random; with probability $n_a/N$
they land in block $a$; learning that they are in block $a$ narrows the field
from $N$ candidates to $n_a$, a factor of $N/n_a$, which is
$\log_2(N/n_a)$ bits of narrowing. The capacity is the average narrowing.

Because the reading is a *deterministic* function of the individual, this
quantity is exactly the mutual information between "who the person is" and "what
the dials say". There is no noise model to argue about, no prior to choose: the
population is the prior, and the capacity is a combinatorial statistic of a
partition. This is what makes everything below provable rather than merely
plausible.

Two extremes anchor the scale. If every individual gets the same label, every
block is the whole room, $n_a = N$, and the capacity is $0$: the dial is blind.
If every individual gets a *different* label, every block is a singleton,
$n_a = 1$, and the capacity is exactly $\log_2 N$: the dial is a perfect
identifier. Nothing in between can beat $\log_2 N$, and that innocuous remark
turns out to be one of the two hard walls of the subject.

## A battery of dials

Now the real object. A **dial** on the population is a reading $r$ together with
a **modulus** $m$, subject to $r(x) < m$ for every individual: the dial has $m$
positions, numbered $0$ through $m-1$. A **battery** is a finite family of dials
$d_1, \dots, d_k$ with moduli $m_1, \dots, m_k$. For a subset $S$ of the dials,
the **joint reading** sends each individual to the tuple of the readings of the
dials in $S$, and the **joint capacity** $C(S)$ is the capacity of that tuple.

The experiment that motivated this work read four such dials on a population of
several thousand and reported three numbers, one for each of three nested
sub-batteries:

| dials switched on | positions $M = \prod m_i$ | measured capacity |
|---|---|---|
| moduli $31, 23$ | $713$ | $7.9455$ bits |
| $+$ modulus $9$ | $6\,417$ | $10.4462$ bits |
| $+$ modulus $8$ | $51\,336$ | $12.1080$ bits |

The numbers go up. That was the headline: **the scaling is confirmed**. But a
table of three increasing numbers is a very weak thing to publish. What follows
is the attempt to say *which parts of that table could not have come out any
other way*, and which parts are genuine information about the population.

## Fact one: the numbers had to go up

**Monotone scaling.** *If $S \subseteq T$ are sub-batteries, then
$C(S) \le C(T)$.*

Switching on more dials never lowers the capacity. The proof is the classical
**data processing** principle in its cleanest finite form. The joint reading of
$S$ is obtained from the joint reading of $T$ by *forgetting* the coordinates
outside $S$ — that is, $\text{reading}_S = \pi \circ \text{reading}_T$ for the
projection $\pi$. And post-processing never creates information:
$H(g \circ f) \le H(f)$ for any $g$.

Why is that true? Because $g$ merges blocks. Each block of $g \circ f$ is a
disjoint union of blocks of $f$, and the contribution of a merged block of size
$n$ is at most the sum of the contributions of its pieces: each piece of size
$n' \le n$ narrows the field by at least as much as the merged block,
$\log_2(N/n') \ge \log_2(N/n)$, and the pieces' probabilities add up to the
merged block's probability. Sum over blocks and the inequality falls out.

So the ascent $7.9455 \to 10.4462 \to 12.1080$ was guaranteed before any data
was collected. A table of *decreasing* numbers would have been evidence of a
bug, not of physics.

## Fact two: when the numbers had to go up *strictly*

Monotonicity permits stagnation: a new dial can be a carbon copy of an old one
and add nothing. What forces genuine growth?

**Strict scaling criterion.** *Let $S \subseteq T$, and suppose there are two
individuals $x, y$ that the sub-battery $S$ cannot tell apart — every dial in
$S$ reads them identically — while some dial in $T$ separates them. Then
$C(S) < C(T)$ strictly.*

The condition is exactly "the new dial resolves at least one old collision", and
it is both natural and easy to check on data. Behind it is a strict version of
data processing: if the coarsening $g$ genuinely merges two attained labels of
$f$, then $H(g \circ f) < H(f)$. In the fibrewise accounting above, the block
containing $x$ and $y$ now splits into at least two strictly smaller pieces, and
the inequality $\log_2(N/n') \ge \log_2(N/n)$ becomes strict for those pieces.
One strict term in a sum of valid inequalities makes the whole sum strict.

The criterion is not vacuous, and one can see it in a toy that fits on a
napkin. Take the population $\{0,1,2,3\}$, a parity dial $x \mapsto x \bmod 2$
and a half dial $x \mapsto \lfloor x/2 \rfloor$, both with two positions. Parity
alone confuses $0$ and $2$; the half dial separates them; so the two-dial
capacity strictly exceeds the one-dial capacity. (Indeed $1 < 2$ bits.)

## Fact three: two ceilings, and they are different in kind

Growth must stop somewhere. There are two distinct reasons why, and telling them
apart is where the subject gets interesting.

**The multiplicative ceiling.** *For any sub-battery $S$,*
$$C(S) \;\le\; \log_2 \prod_{i \in S} m_i .$$

The joint reading of $S$ lands in a grid of $\prod_{i\in S} m_i$ cells, so it can
take at most that many distinct values, so it partitions the room into at most
that many blocks, so — by the maximum-entropy bound $H(f) \le \log_2 K$ for a
reading with $K$ attained values — its capacity is at most the logarithm. (The
maximum-entropy bound itself is the classical Gibbs estimate: compare the block
distribution to the uniform distribution on attained labels using
$\log t \le t - 1$.)

This is the ceiling one would naively quote, and for the experiment's three
sub-batteries it reads $\log_2 713 \approx 9.478$, $\log_2 6417 \approx 12.648$,
$\log_2 51336 \approx 15.648$. The measured values $7.9455$, $10.4462$,
$12.1080$ sit strictly below all three. The table is *consistent*, and one can
certify the three inequalities by hand with nothing more than
$2^8 \le 713$, $2^{12} \le 6417$, $2^{15} \le 51336$.

**The sample ceiling.** *For any sub-battery $S$,* $C(S) \le \log_2 N$, *where
$N$ is the size of the population — whatever the moduli are.*

This one has nothing to do with the dials. A reading of $N$ individuals produces
at most $N$ distinct labels, so its capacity is at most $\log_2 N$. Add a
thousand dials of modulus a million each; the ceiling does not move.

The distinction matters enormously in practice, and it is the source of what
practitioners call **sparse-table bias**. If your table has $N$ rows and
$M = \prod m_i$ cells with $N \ll M$, most cells are empty, and the measured
capacity is pinned near $\log_2 N$ rather than near $\log_2 M$. Read backwards,
this is a free consistency check on any reported number: the final measurement of
$12.1080$ bits *forces* the population to have contained at least
$2^{12.108} \approx 4415$ individuals. No population, no capacity.

## Fact four: the multiplicative ceiling is not a fantasy

An upper bound is only interesting if something reaches it. It does, and the
witness is the Chinese Remainder Theorem.

**Saturation.** *A reading that separates all individuals has capacity exactly
$\log_2 N$.* (All blocks are singletons.) *Consequently, on the population
$\mathbb{Z}/31 \times \mathbb{Z}/23$ — which has exactly $713$ elements — the
two-dial battery that reads the two coordinates has capacity exactly*
$\log_2 713$.

Because $31$ and $23$ are coprime, the pair of residues determines the element:
this is the Chinese Remainder Theorem, and it says precisely that the joint
reading is injective. So the multiplicative ceiling is attained, exactly, with no
slack. The shortfall in the experiment — $7.9455$ against a ceiling of
$9.478$ — is therefore *a fact about that population*, not an artefact of a
loose inequality. Somewhere in that data set, individuals genuinely collide.

## Fact five: the per-dial budget, and the paradox of the blind dial

The last structural fact bounds the joint capacity by what the dials can afford
individually.

**Per-dial budget (subadditivity).** *$C(S) \le \sum_{i \in S} C(\{i\})$: the
joint capacity of a battery never exceeds the sum of the capacities of its dials
read one at a time.*

The proof is again Gibbs, now comparing the joint block distribution against the
product of the marginals; the slack in the inequality is exactly the mutual
information between the dials, which is why equality holds precisely when the
dials are statistically independent across the population.

And here is where the experiment produced its most arresting number. The
per-dial capacities were wildly unequal: a dial of modulus $11$ carried $3.46$
bits, while a dial of modulus $31$ carried $0.04$ bits. That is an eighty-fold
spread, and the two ends mean completely different things:

* A dial of modulus $11$ can carry at most $\log_2 11 = 3.4594\ldots$ bits, and
  $3.4594 < 3.46$. So the reported $3.46$ is a rounded report of a dial that is
  **saturated**: it is spreading the population as evenly as eleven positions
  permit, and it has nothing left to give. Note the delicacy — one can certify
  $\log_2 11 < 3.46$ from the single integer inequality
  $11^{50} < 2^{173}$, and the margin is under two thousandths of a bit.
* A dial of modulus $31$ can carry up to $\log_2 31 > 4.9$ bits, and it carried
  $0.04$. That is a hundred-fold shortfall against its own ceiling. This dial is
  not limited by its resolution; it is nearly **blind**, dumping almost the
  entire population into one position.

The budget has a sharp corollary that turns it into an audit. Switching on one
new dial $a$ raises the joint capacity by exactly the *conditional* capacity of
$a$ given the dials already on — the average, over the blocks of the existing
partition, of how much $a$ resolves inside a block. And because the slack in
subadditivity is a mutual information, which is never negative, that conditional
value can never exceed the dial's solo value:

$$C(S \cup \{a\}) - C(S) \;\le\; c_a .$$

A nearly blind dial is therefore nearly useless *jointly as well as alone*. It
might seem that a dial which is almost constant globally could still split
exactly the right collisions of the other dials and buy resolution out of all
proportion to its solo score; the inequality says flatly that it cannot. A dial
worth $0.04$ bits by itself can never add more than $0.04$ bits to anything.

This is exactly the kind of statement that lets a theory bite back at a
measurement. The first row of the reported table gives $7.9455$ bits for the
battery consisting of the modulus-$31$ and modulus-$23$ dials. But the budget
caps that pair at
$$c_{31} + c_{23} \;\le\; 0.04 + \log_2 23 \;=\; 0.04 + 4.524 \;=\; 4.564 \text{ bits},$$
using the reported $0.04$ for the modulus-$31$ dial and the best conceivable
value for its partner. That is not close to $7.9455$; it is short by nearly three
and a half bits. The two numbers cannot both describe the same dials on the same
population. Either the per-dial figures were collected on a different population
or a different instrument configuration from the joint ones — which the
description of the experiment as a fresh, independent population suggests — or
one of them is mis-attributed. No amount of clever interpretation removes the
gap, because subadditivity is a theorem.

That is a useful thing for a theory to be able to say. A trend can be confirmed
by a pipeline that is quietly comparing apples to oranges; an inequality cannot.

## The wall that is really a thermometer

The experiment reported one more number, a "which-factor wall" at $0.4677$ bits:
a certain binary readout — a yes/no question about each individual — could never
be pushed past that value. The temptation is to read a wall as a mystery. It is
not. For binary readings the whole story collapses to a single number.

**The binary law.** *A reading attaining exactly two labels, with a fraction $p$
of the population in the first class, has capacity exactly*
$$h(p) \;=\; -p\log_2 p - (1-p)\log_2(1-p),$$
*the binary entropy function.*

$h$ is strictly increasing on $[0, 1/2]$ and caps at $h(1/2) = 1$ bit. Two
consequences follow immediately, and they are what makes a reported wall value
useful.

*First*, a binary capacity can never exceed one bit, so any reported wall below
$1$ is admissible on its face; the value $0.4677$ is not, by itself, evidence of
anything unusual.

*Second — and this is the real content — the wall value **inverts**.* Because $h$
is strictly monotone on $[0,1/2]$, it is injective there, so a reported binary
capacity determines the class imbalance *uniquely*. The wall is not a barrier; it
is a thermometer reading the split. Solving $h(p) = 0.4677$ gives
$p \approx 0.0996$: the yes/no question in question divides the population
roughly $10\%$ against $90\%$. That is a concrete, checkable claim about the
data extracted from a single reported number.

It also yields a falsifiable cross-population prediction. Two independent
populations reporting the same wall value, to within measurement error, must have
the same imbalance in their binary split — an equality of proportions that can be
tested directly, with no free parameters.

## What the confirmation actually confirmed

Return to the verdict: *the scaling is confirmed*. With the structure above in
hand, we can partition that verdict into three parts of very different value.

**Guaranteed.** That the three numbers increase. That each lies below
$\log_2 M$. That each lies below $\log_2 N$. That the per-dial values sum to at
least the joint value. None of this could have failed; observing it confirms that
the measurement pipeline is not broken, which is worth knowing and is not a
discovery.

**Informative.** *How far below* the ceilings the numbers sit. The gap between
$7.9455$ and $\log_2 713 = 9.478$ is not slack in an inequality — the Chinese
Remainder witness proves the inequality can be tight — so the gap is a
measurement of collision structure in the population. Likewise the $80\times$
per-dial spread genuinely separates a saturated dial from a blind one, since one
end sits within $0.001$ bits of its own ceiling and the other sits a factor of a
hundred below.

**Inverted.** The wall value $0.4677$, which is not a wall at all but an exact
report of a $10\%/90\%$ class split.

**Inconsistent.** And one thing the audit rules out: the per-dial figure of
$0.04$ bits and the joint figure of $7.9455$ bits cannot both be readings of the
same dials on the same population, since the per-dial budget caps that pair at
$4.564$ bits. A theory earns its keep not only by explaining measurements but by
refusing to accept incompatible ones.

The moral generalizes past dials and populations. When an experiment reports a
number and a trend, the first job of theory is not to explain the number; it is
to compute how much of the number was *forced*. Everything forced is a check on
the apparatus. What is left over — the shortfalls, the spreads, the inverted
parameters — is the data. Here, the forced part is monotonicity and two ceilings;
the residue is a collision structure, an eighty-fold spread between a saturated
dial and a blind one, and a population split ten to ninety.

That residue is small. But it is real, and, unlike the headline, it could have
come out otherwise.
