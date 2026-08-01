# A Probability Smaller Than Every Ordinary Scale

## Giving every point a chance without spending the whole budget

Imagine throwing a perfectly sharp dart at the interval from zero to one. Classical probability says that every individual landing point has probability zero. This is not a declaration that the point is impossible: it is the consequence of describing a continuous distribution with ordinary real numbers. Any one point occupies no length, even though the entire interval has length one.

That answer is mathematically coherent, but it leaves a persistent intuition unsatisfied. If the dart must land somewhere, could each point receive a positive chance—one so tiny that even every *finite* collection of points still consumes less than the total probability budget?

Ordinary real numbers cannot supply such a chance. If a real number $p$ is positive, then enough copies of $p$ eventually exceed $1$. This is the Archimedean property. The escape route is to enlarge the number system. Conway’s surreal numbers contain not only the real numbers but also positive infinitesimals: numbers greater than $0$ and smaller than every positive real scale in a prescribed descending family.

The construction developed here combines one such infinitesimal with a deliberately modest collection of events. On any infinite sample space—and therefore on $[0,1]$—it produces a normalized, nonnegative, finitely additive probability in which every singleton has the same positive infinitesimal mass. The qualification “finitely additive” and the choice of event algebra are not fine print. They are the boundary that makes the construction precise.

## Carving out an infinitesimal

Surreal numbers can be introduced by cuts. A cut $\{L\mid R\}$ denotes the simplest surreal number lying strictly above every number in the left set $L$ and strictly below every number in the right set $R$, provided every left option is below every right option.

Consider

$$
\varepsilon=\left\{0\ \middle|\ 1,\frac12,\frac14,\frac18,\ldots\right\}.
$$

The left option says that $\varepsilon>0$. Each right option says that

$$
\varepsilon<2^{-n}
$$

for every nonnegative integer $n$. Thus $\varepsilon$ is positive, yet it lies below every dyadic scale. No positive real number has this property: for an ordinary $r>0$, repeated halving eventually produces $2^{-n}<r$.

A second fact is crucial for probability. Every finite multiple of $\varepsilon$ remains below one:

$$
n\varepsilon<1\qquad\text{for every }n\in\mathbb N.
$$

One quick reason is that $n\le 2^n$ and $\varepsilon<2^{-n}$. Positivity preserves order under multiplication, so

$$
n\varepsilon\le 2^n\varepsilon<2^n2^{-n}=1.
$$

This is precisely the feature unavailable in the real numbers. We may spend $\varepsilon$ once, twice, or any finite number of times and never exhaust the unit budget.

## Choosing the events carefully

Let $X$ be an infinite sample space. We admit two kinds of events:

1. **Finite events**, containing only finitely many points.
2. **Cofinite events**, whose complements contain only finitely many points.

Together these form the finite–cofinite event algebra. It includes the impossible event $\varnothing$, the certain event $X$, every singleton, complements, and finite unions. It does not include every subset of $X$. For instance, when $X=[0,1]$, a typical proper subinterval is neither finite nor cofinite.

This restrained algebra is enough to ask whether finitely many named outcomes occur or whether all but finitely many outcomes occur. It also makes the probability rule inevitable. Define

$$
P(A)=
\begin{cases}
|A|\varepsilon, & A\text{ is finite},\\[4pt]
1-|X\setminus A|\varepsilon, & A\text{ is cofinite}.
\end{cases}
$$

Because $X$ is infinite, no subset can be both finite and cofinite: otherwise $X$ would be the union of two finite sets. The two clauses therefore never conflict.

The formula has a clear interpretation. A finite event is priced point by point. A cofinite event is almost certain; its probability is one minus the infinitesimal cost of the finitely many exceptions.

## The probability theorem

The central result can now be stated without ambiguity.

**Finite–cofinite surreal probability theorem.** *For every infinite set $X$, the rule above defines a nonnegative, normalized, finitely additive surreal-valued probability on the finite–cofinite event algebra. More precisely, $P(X)=1$, every point $x\in X$ satisfies $P(\{x\})=\varepsilon>0$ and $P(\{x\})<2^{-n}$ for every $n\in\mathbb N$, and whenever admissible events $A$ and $B$ are disjoint,*

$$
P(A\cup B)=P(A)+P(B).
$$

Normalization is immediate because the complement of $X$ is empty:

$$
P(X)=1-|\varnothing|\varepsilon=1.
$$

For a singleton, $|\{x\}|=1$, hence $P(\{x\})=\varepsilon$. Nonnegativity is also transparent. A finite event has mass $n\varepsilon\ge0$. A cofinite event has mass $1-n\varepsilon>0$, because every finite multiple of $\varepsilon$ is less than one.

Additivity contains the most interesting bookkeeping. If $A$ and $B$ are disjoint and finite, then ordinary counting gives $|A\cup B|=|A|+|B|$, and therefore

$$
P(A\cup B)=(|A|+|B|)\varepsilon=P(A)+P(B).
$$

Suppose instead that $A$ is finite and $B$ is cofinite. Disjointness forces every point of $A$ to be among the finitely many points missing from $B$. Passing from $B$ to $A\cup B$ restores exactly $|A|$ of those missing points. If $|X\setminus B|=m$, then $|X\setminus(A\cup B)|=m-|A|$, so

$$
P(A\cup B)=1-(m-|A|)\varepsilon
=|A|\varepsilon+(1-m\varepsilon)
=P(A)+P(B).
$$

The case with $A$ cofinite and $B$ finite is symmetric. Two cofinite events cannot be disjoint: their complements are finite, while disjointness would force those two finite complements to cover the infinite set $X$. These cases exhaust the possibilities.

Taking $X=[0,1]$ gives the promised model for the unit interval. Every real point receives the same positive infinitesimal mass, the whole interval has mass one, and every disjoint pair of finite–cofinite events obeys additivity.

## Why the interval is not being “added point by point”

A common objection arrives immediately: if every point has mass $\varepsilon$, why is the mass of the interval not some enormous uncountable multiple of $\varepsilon$? The answer is that finite additivity never asks for such a sum. It says how to combine two disjoint events, and by repetition any finite list of disjoint events. It does not define a sum indexed by all real points.

This distinction already matters in classical probability. Countable additivity governs sequences $A_0,A_1,A_2,\ldots$, but $[0,1]$ has uncountably many singleton subsets. Even there, the total mass of the interval is not computed by applying countable additivity to every singleton at once. In the surreal setting another issue appears: before discussing an infinite series such as $\sum_n\varepsilon$, one must decide what convergence and summation mean for surreal values.

The present model avoids pretending that this later theory is automatic. The value of $X$ is fixed by normalization, the values of finite sets follow from point masses, and the values of cofinite sets follow from complements. Every required calculation uses only finitely many additions. That restraint is what turns the provocative picture into a well-defined theorem.

## Symmetry and finite exceptions

The probability also treats points with perfect symmetry. If a permutation rearranges the elements of $X$, it preserves the number of points in every finite event and the number of missing points in every cofinite event. The probability therefore remains unchanged. No location, label, or geometric coordinate is preferred.

Yet the infinitesimal terms preserve information erased by the ordinary zero–one finite–cofinite probability. A set missing one point has mass $1-\varepsilon$; a set missing a thousand points has mass $1-1000\varepsilon$. Both look “certain” if infinitesimal detail is discarded, but they are not equal. Likewise, a pair of points has twice the probability of a singleton, although both would receive ordinary mass zero. The construction functions as a microscope for finite exceptions.

## A symbolic microscope

Because $\varepsilon$ is not an ordinary floating-point number, decimal approximations are a poor way to display the theory. The relevant probabilities all have the affine form

$$
a+b\varepsilon,
$$

where $a$ is either $0$ or $1$ and $b$ is an integer. A finite event of size $k$ has symbolic mass $(0,k)$; a cofinite event missing $m$ points has mass $(1,-m)$. Addition is exact:

$$
(a,b)+(c,d)=(a+c,b+d).
$$

For example, suppose a cofinite event omits five points and a disjoint finite event consists of two of those exceptions. Their masses are

$$
1-5\varepsilon\quad\text{and}\quad2\varepsilon.
$$

Their union now omits three points, so its mass is $1-3\varepsilon$, exactly the sum of the first two masses. The calculation is tiny, but it captures the general mixed finite–cofinite argument.

## What this does—and does not—change

The construction does not replace ordinary continuous probability on all measurable subsets of $[0,1]$. It gives no probability here to a typical interval such as $[0,1/2]$, because that set and its complement are both infinite. Nor does finite additivity automatically imply countable additivity. An infinite sum of surreal numbers requires its own definition and convergence theory; one cannot silently import the real-valued notion.

This limitation is also conceptually productive. It isolates three ingredients that are often blended together: the chosen number system, the chosen family of events, and the chosen additivity law. Changing the codomain to the surreals makes positive point masses possible. Restricting events to the finite–cofinite algebra makes their masses unambiguous. Requiring only finite additivity keeps every sum algebraic and finite.

The model therefore acts as a clean laboratory for non-Archimedean probability. It offers a precise answer to the original question: yes, every point of an infinite space can have the same nonzero infinitesimal probability while the whole space has probability one—provided probability is surreal-valued and is defined on the finite–cofinite algebra with finite additivity.

Beyond that laboratory lie harder questions. Can interval-like events be added consistently? Can one define useful countable sums of nonnegative surreal families? Is there a “classical shadow” that discards infinitesimal detail and returns the ordinary zero–one finite–cofinite probability? Hyperfinite grids suggest another bridge: use $N$ equally weighted atoms of mass $1/N$ for an infinite $N$, then compare the resulting picture with the surreal cut above.

The deeper lesson is not that zero was wrong. Classical probability’s zero-mass points remain exactly right for real-valued, countably additive measures. The lesson is that probability is a structure assembled from choices. Once the arithmetic admits genuine infinitesimals, a point can be smaller than every familiar scale and still be more than nothing.