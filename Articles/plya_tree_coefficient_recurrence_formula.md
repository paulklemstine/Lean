# Counting Trees Without Drawing Them: The Hidden Arithmetic of Pólya Trees

## A child's question with a surprisingly deep answer

How many different shapes can a rooted tree have?

Picture a tree the way a computer scientist or a chemist does: a single root at the
top, from which branches sprout, and from those branches more branches, and so on. We
do not care about left-versus-right ordering of the children — only the *shape* matters.
Two trees are "the same" if you can wiggle the branches around (without cutting them) to
make one look like the other. These objects are called **Pólya trees**, after the
Hungarian mathematician George Pólya, who turned the art of counting symmetric structures
into a science.

With one node, there is exactly one shape: a lone root. With two nodes, still one shape:
a root with a single child hanging below it. With three nodes there are two shapes: a
path of three, or a root with two children. With four nodes there are four shapes. With
five, nine. The counts march on:

$$1,\; 1,\; 2,\; 4,\; 9,\; 20,\; 48,\; 115,\; 286,\; 719,\; 1842,\; 4766,\; \dots$$

This is one of the most famous integer sequences in all of mathematics, catalogued as
A000081 in the Online Encyclopedia of Integer Sequences. It appears when chemists count
isomers of saturated hydrocarbons, when computer scientists count the shapes of data
structures, and when biologists count evolutionary trees. The numbers grow quickly — by
the time you reach trees with thirty nodes there are well over a billion shapes — so
drawing them all is hopeless. We need a *formula*.

This article is about one particularly beautiful formula: a **recurrence** that computes
each term of the sequence from the terms before it, using a piece of arithmetic that, at
first glance, has nothing to do with trees at all. The surprise is where that arithmetic
comes from. It is not a clever guess bolted on after the fact; it is *forced* upon us by
the structure of the problem, hiding inside a single, elegant equation.

## The equation that knows about all trees at once

The standard trick for counting infinitely many objects is to pack the counts into a
single algebraic object called a **generating function**. Write $a_k$ for the number of
Pólya trees with $k$ nodes, and bundle them together as a power series

$$A(z) = a_1 z + a_2 z^2 + a_3 z^3 + \cdots = z + z^2 + 2z^3 + 4z^4 + 9z^5 + \cdots$$

The variable $z$ is just a bookkeeping device: the coefficient sitting in front of $z^k$
*is* the number of trees with $k$ nodes. The miracle of generating functions is that
relationships between counts become ordinary algebra.

For Pólya trees, that relationship is the celebrated functional equation

$$A(z) = z \cdot \exp\!\big(A(z)\big) \cdot \Phi(z), \qquad \Phi(z) = \exp\!\left(\sum_{i \ge 2} \frac{A(z^i)}{i}\right).$$

Let us decode it. A rooted tree is a root (that is the factor of $z$, contributing one
node) sitting above a *collection* of subtrees. The factor $\exp(A(z))$ is the standard
algebraic incantation for "an unordered multiset of trees." But there is a subtlety that
makes Pólya trees genuinely hard: because we ignore the ordering of children, two
identical subtrees must not be double-counted. The correction factor $\Phi(z)$, built
from the values of $A$ at $z^2, z^3, z^4, \dots$, is exactly the device that accounts for
this symmetry. The terms $A(z^i)$ — feeding the series into itself at higher powers —
are the fingerprints of repeated, interchangeable branches.

It is a gorgeous equation, but also an intimidating one. It involves an exponential of a
power series, and inside that exponential the unknown $A$ appears evaluated at infinitely
many different powers of $z$. How could anyone hope to extract clean numbers from such a
tangle?

## A change of clothes: from exponentials to a single sum

The first move is to give the messy exponent a name of its own. Collect everything inside
the exponentials into one series:

$$S(z) = \sum_{i \ge 1} \frac{A(z^i)}{i} = A(z) + \frac{A(z^2)}{2} + \frac{A(z^3)}{3} + \cdots$$

With this abbreviation the whole functional equation collapses into the strikingly simple

$$A(z) = z \cdot \exp\!\big(S(z)\big).$$

The series $S$ is the quiet protagonist of this story. It looks innocent, but it carries
all the symmetry corrections in one tidy package.

Now comes the decisive idea, and it is one of the oldest tricks in the analyst's
notebook: instead of wrestling with the exponential directly, take its **logarithmic
derivative**. If $A = z\,e^{S}$, then taking logarithms gives $\log A = \log z + S$, and
differentiating turns products into sums and kills the exponential entirely:

$$\frac{A'(z)}{A(z)} = \frac{1}{z} + S'(z).$$

Clearing denominators yields what we will call the **log-derivative identity**:

$$z \, A'(z) = A(z)\,\big(1 + z\,S'(z)\big).$$

This is the same information as the original functional equation — no content has been
lost — but every exponential has vanished. We are left with nothing but multiplication
and differentiation of power series, operations we know how to handle coefficient by
coefficient. This reformulation is the workhorse of the entire argument.

## The divisor weight: arithmetic crashes the party

Here is where the story takes its unexpected turn. Let us look at the single most
important quantity that emerges when we extract coefficients from the term $z\,S'(z)$.

Define, for each whole number $n$, the **divisor weight**

$$\omega_n = \sum_{d \mid n} d \cdot a_d,$$

where the sum runs over every positive divisor $d$ of $n$. For example, since the
divisors of $6$ are $1, 2, 3, 6$,

$$\omega_6 = 1\cdot a_1 + 2\cdot a_2 + 3\cdot a_3 + 6\cdot a_6 = 1\cdot 1 + 2\cdot 1 + 3\cdot 2 + 6\cdot 20 = 129.$$

Stare at this definition for a moment. It mixes a *number-theoretic* operation — running
over the divisors of $n$ — with the *combinatorial* tree counts $a_d$. There is no
obvious reason a tree-counting problem should care about which numbers divide which. Yet
this weight is precisely what we need, and the reason is a clean little identity that I
will call the **bridge**.

Recall that $S(z) = \sum_{i\ge 1} A(z^i)/i$. When you expand each $A(z^i)$ and collect the
coefficient of $z^n$, you find that the $n$-th coefficient of $S$ is

$$[z^n]\,S(z) = \sum_{i \mid n} \frac{a_{n/i}}{i},$$

again a sum over divisors. Now multiply by $n$. The bridge identity states that this
product is exactly the divisor weight:

$$n \cdot [z^n]\,S(z) = \omega_n.$$

In words: **the divisor weight is not an arbitrary invention — it is what the
logarithmic derivative of the functional equation hands you, automatically.** The factor
of $n$ comes from differentiation (it is what $z\,S'(z)$ does to the coefficient of
$z^n$), and the divisor structure comes from the fact that $S$ feeds $A$ into itself at
the powers $z^i$. The proof is a one-line reflection: pair each divisor $d$ of $n$ with
its partner $n/d$, and the two sums match term for term. This single identity is the
mathematical heart of the whole subject; everything else is bookkeeping.

## The payoff: a recurrence anyone can run

Once the bridge is in place, we read off coefficients from the log-derivative identity
$z A'(z) = A(z)(1 + zS'(z))$ like reading entries from a ledger. The coefficient of
$z^n$ on the left is $n\,a_n$. On the right, the product of two power series produces a
*convolution* — a sum of cross terms — and the bridge converts every divisor-weighted
piece into an $\omega$. After the dust settles, the $a_n$ on both sides cancels and we are
left with the **Pólya tree recurrence**: with $a_1 = 1$, for every $k \ge 2$,

$$\boxed{\,a_k = \frac{1}{k-1}\sum_{j=1}^{k-1} a_j \, \omega_{k-j}\,}, \qquad \omega_m = \sum_{d \mid m} d\,a_d.$$

This is a genuine algorithm. To find a new term, you take a weighted sum of all the
earlier terms — weighting $a_j$ by the divisor weight of the gap $k - j$ — and divide by
$k-1$. Nothing else is needed. Let us watch it produce a number from scratch.

We start with $a_1 = 1$. The divisor weights we need along the way are
$\omega_1 = 1$, $\omega_2 = a_1 + 2a_2 = 1 + 2 = 3$, $\omega_3 = a_1 + 3a_3 = 1 + 6 = 7$,
$\omega_4 = a_1 + 2a_2 + 4a_4 = 1 + 2 + 16 = 19$.

- $k = 2$: $a_2 = \tfrac{1}{1}\,(a_1\,\omega_1) = 1\cdot 1 = 1.$
- $k = 3$: $a_3 = \tfrac{1}{2}\,(a_1\,\omega_2 + a_2\,\omega_1) = \tfrac{1}{2}(1\cdot 3 + 1\cdot 1) = 2.$
- $k = 4$: $a_4 = \tfrac{1}{3}\,(a_1\,\omega_3 + a_2\,\omega_2 + a_3\,\omega_1) = \tfrac{1}{3}(7 + 3 + 2) = 4.$
- $k = 5$: $a_5 = \tfrac{1}{4}\,(a_1\,\omega_4 + a_2\,\omega_3 + a_3\,\omega_2 + a_4\,\omega_1) = \tfrac{1}{4}(19 + 7 + 6 + 4) = 9.$

There they are: $1, 1, 2, 4, 9$ — the opening of A000081, conjured purely from
arithmetic. Continue the same process and the full sequence
$20, 48, 115, 286, 719, \dots$ tumbles out, each term as exact as the last. Notice
something remarkable: although the formula divides by $k-1$ and everything happens over
the rational numbers, the answer is *always a whole number*. The fractions conspire to
cancel perfectly, every single time — a small miracle that itself hints at deeper
structure (and is one of the open directions this work points toward).

## Two faces of one equation

There is a final twist worth savoring. We derived the recurrence *from* the functional
equation. But it turns out the two are not just related — they are **logically
equivalent**. Given any candidate sequence of numbers $a_k$, the statement "these
numbers satisfy the log-derivative form of the Pólya functional equation" is *exactly the
same statement* as "these numbers satisfy the recurrence for all $k \ge 2$." Each one
implies the other, and the bridge identity is the hinge on which the equivalence turns.

This is more than a curiosity. It means the recurrence is not a lossy shadow of the
generating function — a mere computational convenience — but a faithful, complete
re-encoding of it. The continuous, analytic world of power series and the discrete,
arithmetic world of divisor sums are, here, two descriptions of one and the same object.
That is the sense in which this result is a *bridge*: it shows that an equation about
exponentials of infinite series and a humble for-loop over divisors are saying precisely
the same thing.

## Why it matters

Recurrences like this one are the engines behind every modern enumeration. They let us
compute thousands of terms of A000081 in the blink of an eye, feed those terms into
studies of the sequence's astonishing growth (it multiplies by roughly $2.9557\ldots$ —
the Otter constant — at each step), and serve as the template for counting whole families
of related structures: forests, series-reduced trees, and the molecular graphs of
chemistry. The same divisor-bridge mechanism reappears across all of them, because the
weight $\omega_k = \sum_{d \mid k} d\,a_d$ is the *universal* signature of unordered,
symmetry-corrected counting.

The lesson is one that recurs throughout mathematics: a hard problem becomes easy not by
brute force but by finding the right disguise. Hidden inside an intimidating equation
full of exponentials was a simple loop over divisors, waiting to be uncovered by a
two-hundred-year-old trick. The trees, it turns out, were keeping time with the
arithmetic of the integers all along.
