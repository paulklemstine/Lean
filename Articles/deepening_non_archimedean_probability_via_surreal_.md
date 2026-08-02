# A Fair Chance for Every Point

## Infinitesimal probability on an infinite continuum

Choose a real number at random from the closed interval $[0,1]$. What is the probability of choosing exactly $1/2$?

The standard answer is zero. The same answer applies to every individual point, even though some point must be selected. This is not a contradiction. Ordinary probability is designed so that countably additive measures can spread total mass $1$ over a continuum while assigning mass $0$ to each singleton. Yet the answer can still feel incomplete. Could every point receive a genuinely positive chance—one smaller than every familiar positive scale—without the total probability exceeding $1$?

Surreal numbers make a precise version of that idea possible. They enlarge the real numbers with infinitesimals: positive numbers smaller than $1/2^n$ for every natural number $n$. Using one such infinitesimal, we can build a coherent probability theory on an infinite set, including the unit interval, in which every point has the same positive mass.

There is a price, and it is mathematically revealing. The allowed events are not all subsets of the interval, and the probability is finitely additive rather than countably additive. Within those boundaries, however, the familiar laws survive: the whole space has mass $1$, probabilities lie between $0$ and $1$, complements have complementary masses, inclusion implies no decrease in probability, and disjoint unions add.

## A number beneath every dyadic microscope

The surreal numbers can be created from cuts. A cut places previously constructed numbers to the left and right, with every left option smaller than every right option. Consider

$$
\varepsilon=\{0\mid 1,1/2,1/4,1/8,\ldots\}.
$$

This notation asks for the simplest surreal number greater than $0$ but less than every number in the sequence $1,1/2,1/4,\ldots$. Thus

$$
0<\varepsilon<2^{-n}
$$

for every natural number $n$. It is not merely “very small.” Any positive real number eventually exceeds some dyadic scale $2^{-n}$, while $\varepsilon$ remains below them all. That is the non-Archimedean step: the ordered number system contains positive quantities beyond the resolution of every real-valued microscope.

The essential safety property is that every finite multiple remains below one:

$$
k\varepsilon<1
$$

for every natural number $k$. To see why, use the elementary inequality $k\leq 2^k$. Since $\varepsilon<2^{-k}$, multiplying by $2^k$ gives $2^k\varepsilon<1$, and hence $k\varepsilon\leq 2^k\varepsilon<1$. No finite collection of points can exhaust the available probability.

## Which events can be measured?

Let $\Omega$ be any infinite sample space. An event $A\subseteq\Omega$ is called **finite–cofinite** if either $A$ is finite or its complement

$$
A^c=\Omega\setminus A
$$

is finite. These events form a Boolean algebra. The empty set and the whole space are included. Taking a complement swaps finite and cofinite events. Unions and intersections remain in the family.

This algebra records two kinds of observations. A finite event names finitely many exceptional outcomes: “the result is one of these seven points.” A cofinite event excludes finitely many outcomes: “anything happens except these three points.” It does not include a typical interval such as $[0,1/2]$ inside $[0,1]$, because both that interval and its complement are infinite. The construction is therefore not a replacement for ordinary continuous probability. It is a sharply focused model that makes point probabilities visible.

Assign probability by counting finite exceptions:

$$
P(A)=
\begin{cases}
|A|\varepsilon, & A\text{ is finite},\\
1-|A^c|\varepsilon, & A^c\text{ is finite}.
\end{cases}
$$

Because $\Omega$ is infinite, an event cannot be both finite and cofinite. The formula is therefore unambiguous. It also makes the intended picture immediate. A finite event has an infinitesimal mass proportional to its number of points. A cofinite event has probability infinitesimally close to certainty, with one unit of $\varepsilon$ deducted for every excluded point.

## The probability laws

The first main result can now be stated in ordinary probabilistic language.

**Finite–cofinite surreal probability theorem.** Let $\Omega$ be an infinite set, and let $\varepsilon$ be the positive surreal number defined by

$$
\varepsilon=\{0\mid 1,1/2,1/4,\ldots\}.
$$

On the Boolean algebra of finite–cofinite subsets of $\Omega$, the formula above defines a nonnegative, normalized, finitely additive probability. Every singleton has probability $\varepsilon$, and every event has probability between $0$ and $1$.

Normalization is almost visible from the definition. The whole space omits no points, so

$$
P(\Omega)=1-0\varepsilon=1.
$$

A singleton contains one point, so

$$
P(\{x\})=\varepsilon>0.
$$

Moreover, $P(\{x\})<2^{-n}$ for every natural number $n$. Thus all points receive the same strictly positive infinitesimal chance.

Nonnegativity separates into two cases. If $A$ is finite, then $P(A)=|A|\varepsilon\geq 0$. If $A$ is cofinite, then $P(A)=1-|A^c|\varepsilon>0$, because every finite multiple of $\varepsilon$ is below $1$.

Finite additivity says that for disjoint events $A$ and $B$,

$$
P(A\cup B)=P(A)+P(B).
$$

If both are finite, this is just the cardinality identity $|A\cup B|=|A|+|B|$. If one is finite and the other cofinite, disjointness says that adding the finite event removes the same number of points from the cofinite event’s finite complement. The corresponding multiples of $\varepsilon$ balance exactly. Two cofinite sets cannot be disjoint in an infinite space: their finite complements could not cover all of $\Omega$. These cases exhaust the possibilities.

## Order, complements, and subtraction

The construction supports more than the minimum probability axioms.

**Complement law.** For every finite–cofinite event $A$,

$$
P(A^c)=1-P(A).
$$

Indeed, $A$ and $A^c$ are disjoint and fill the whole space. Finite additivity gives $P(A)+P(A^c)=1$.

This immediately gives the upper bound $P(A)\leq 1$, because $P(A^c)\geq 0$. Together with nonnegativity,

$$
0\leq P(A)\leq 1.
$$

**Monotonicity theorem.** If $A\subseteq B$, then

$$
P(A)\leq P(B).
$$

The reason is the familiar decomposition

$$
B=A\sqcup(B\setminus A).
$$

The difference is again finite–cofinite, so finite additivity and nonnegativity yield

$$
P(B)=P(A)+P(B\setminus A)\geq P(A).
$$

The same decomposition gives a useful subtraction law:

$$
P(A\setminus B)=P(A)-P(B)
$$

whenever $B\subseteq A$.

Finally, the model detects the smallest finite change. If $A$ is finite and $x\notin A$, then

$$
P(A\cup\{x\})=P(A)+\varepsilon>P(A).
$$

Ordinary atomless probability cannot distinguish a finite set from the same set with one extra point: both have probability zero. Here the difference is exactly one infinitesimal unit.

## The unit interval revisited

Take $\Omega=[0,1]$. This set is infinite, so all the preceding results apply. The finite–cofinite events on the interval carry a normalized surreal-valued probability with

$$
P([0,1])=1
$$

and

$$
0<P(\{x\})=\varepsilon<2^{-n}
$$

for every $x\in[0,1]$ and every natural number $n$. Disjoint finite–cofinite events add, complements subtract from one, and inclusion preserves order.

This resolves the motivating question in a precise but qualified way. Yes: one can assign an equal, nonzero infinitesimal probability to every point of $[0,1]$ while retaining total mass $1$. The construction lives on the finite–cofinite event algebra and obeys finite additivity. It does not claim a measure on every subset, nor does it silently treat an uncountable sum of infinitesimals as an ordinary convergent series.

That distinction matters. Countable additivity is powerful because it controls limits of infinite decompositions. Finite additivity asks only that every finite disjoint union behave correctly. The surreal number system supplies the infinitesimal values; the restricted event algebra prevents incompatible infinite bookkeeping. Number system, event algebra, and additivity principle work as a matched set.

## Why this model matters

The construction is a laboratory for a recurring idea across mathematics and science: a quantity may be negligible at every standard scale without being zero. Perturbation theory tracks tiny corrections; economics studies agents whose individual influence is negligible but whose collective behavior matters; statistical mechanics moves between microscopic constituents and macroscopic totals. In many applications, ordinary real numbers are enough because limits encode the small quantities. Here the infinitesimal is retained as an actual ordered value.

The model also exposes what probability axioms do separately. Normalization does not force singleton probabilities to vanish. Finite additivity does not force them to vanish. The familiar zero mass of points in continuous distributions emerges from stronger structural choices—especially the event algebra and countable additivity—not from the word “probability” alone.

A useful way to picture the arithmetic is to keep two ledgers. The first records the macroscopic part, either $0$ or $1$. The second records a finite coefficient of $\varepsilon$. A finite set of $m$ points has ledger entry $0+m\varepsilon$; a set missing $r$ points has entry $1-r\varepsilon$. Complementation flips one ledger into the other. Adding a new point raises the infinitesimal coefficient by one, while excluding a new point lowers it by one. No decimal approximation can reproduce this exactly: any positive floating-point number eventually becomes larger than the dyadic scale under inspection. The right representation is symbolic, preserving $\varepsilon$ as a genuine new unit.

This ledger also explains why geometry is absent. Two finite sets with the same number of points receive equal probability, no matter how far apart their points lie. Two cofinite sets are compared only by how many exceptions they exclude. The construction sees cardinality at the finite fringe, not length, distance, or density. That is precisely why it can be applied to any infinite set, not just an interval, and precisely why it should not be confused with ordinary uniform area or length.

There are natural next questions. Does finite additivity extend from pairs to arbitrary finite disjoint families? Can one prove strict monotonicity for every proper inclusion, not only when a point is adjoined to a finite set? Does inclusion–exclusion hold in its usual form? Can the event algebra be enlarged while preserving equal infinitesimal singleton masses? And what explicit notion of convergence would rule out a countably additive extension?

The key achievement is not to make infinity disappear. It is to account for finite changes inside an infinite world. Every point has a chance. Every finite handful has the corresponding finite multiple. Certainty remains exactly $1$. Between zero and every positive real scale, the surreal infinitesimal gives probability a new place to live.
