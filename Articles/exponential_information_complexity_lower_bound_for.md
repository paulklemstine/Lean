# The Average That Cannot Lie: How One Exact Count Tames the Geometry of High-Dimensional Codes

## A puzzle hidden in the word "average"

Imagine you scatter a handful of pebbles across a vast, dark field. You are handed a
flashlight whose beam lights up a circle of fixed radius, and you are told to walk to every
possible spot in the field, shine the light, and count how many pebbles fall inside the
circle. Some spots will catch a cluster of pebbles; others will catch none. The numbers
jump around. They look random.

Now someone asks a deceptively simple question: *on average*, across all the places you
could stand, how many pebbles does your circle catch?

Your instinct might be that this depends on the messy details — where the pebbles landed,
whether they bunched up, whether the field has a lumpy middle. It turns out that, in the
right setting, none of that matters. The average is fixed in advance, exactly, with no error
term and no fine print. It equals the number of pebbles multiplied by the area of your
circle, divided by the area of the field. The chaos of where the pebbles sit washes out
completely the moment you average over where you stand.

This is the small miracle at the heart of this article. It is a statement about a structure
that engineers and mathematicians care about deeply — *error-correcting codes* in
high-dimensional spaces — and it is the kind of fact that, once you see it, reorganizes how
you think about an entire hard problem. The "field" is the space of all possible messages.
The "pebbles" are the codewords. The "flashlight circle" is a *Hamming ball*. And the exact
average is what separates the easy part of a famous conjecture from the genuinely hard part.

## The space where messages live

Start with an alphabet of $q$ symbols — think of $q = 2$ for bits, or $q = 4$ for the
letters of DNA. A message of length $n$ is a string of $n$ such symbols. The collection of
*all* such strings is the space we will call $G$. It is enormous: there are $q^n$ strings in
total, a number that explodes as $n$ grows. With a binary alphabet and length 100, that is
already more strings than there are atoms in the observable universe.

To compare two strings, we use the most natural ruler imaginable: count the positions where
they disagree. If `CAT` and `COT` differ in exactly one position, their **Hamming distance**
is 1. If `CAT` and `DOG` differ in all three, their distance is 3. Formally, the Hamming
distance between strings $x$ and $y$ is

$$d(x, y) = \#\{\, i : x_i \neq y_i \,\}.$$

A **Hamming ball** of radius $r$ around a centre $z$ is just every string within distance
$r$ of $z$:

$$B_r(z) = \{\, x \in G : d(x, z) \le r \,\}.$$

If $z$ is a received, possibly-corrupted message and $r$ is the number of errors a channel
might introduce, then $B_r(z)$ is exactly the set of strings that could have been the true
transmission. This is why Hamming balls are the central geometric object in coding theory:
they *are* the uncertainty.

A **code** $C$ is simply a chosen subset of $G$ — the strings we agree to use as legitimate
messages. A good code spreads its codewords out so that the balls around them don't overlap,
letting a receiver decode unambiguously. The quantity that controls almost everything is
the count $|C \cap B_r(z)|$: how many codewords sit inside the ball around a given centre
$z$. We would love this count to be roughly the same for every centre — a property called
low *discrepancy*. Codes with low discrepancy behave like idealized random sets and are
prized in cryptography, compressed sensing, and the theory of pseudorandomness.

## The conjecture, and the gap it hides

There is a well-known conjecture about *random linear codes*. It predicts that if you build
a code at random with the right dimension, then with overwhelming probability, **every**
centre $z$ catches almost exactly the same number of codewords, namely

$$|C \cap B_r(z)| \approx \frac{|C| \cdot |B_r|}{q^n}.$$

The right-hand side is the "ideal" count — what you'd get if codewords were sprinkled
uniformly at random and the ball volume $|B_r|$ didn't depend on where you centred it.

For years this target value was treated as a *heuristic*: a back-of-the-envelope expectation
that the real, messy counts hover around. The central insight of this work is to ask whether
that heuristic is actually a *theorem* — and to discover that half of it is, exactly, with
no probability and no randomness at all.

## The headline identity

Here is the result, stripped to its essence. Take **any** code $C$ whatsoever — no
randomness, no linearity, no special structure, just any subset of strings. Sum the counts
$|C \cap B_r(z)|$ over *all* possible centres $z$. Then:

$$\sum_{z \in G} |C \cap B_r(z)| \;=\; |C| \cdot |B_r|.$$

The total, summed over every centre, is *exactly* the number of codewords times the volume
of a single ball. Divide both sides by the number of centres, $q^n$, and you learn that the
average count over centres is *exactly* $|C| \cdot |B_r| / q^n$ — the conjecture's target
value, on the nose.

Why is this true? The trick is a piece of mathematical jujitsu called **double counting**.
Instead of asking "for each centre, how many codewords does it catch?", flip the question:
"for each codeword, how many centres catch *it*?" A codeword $c$ is caught by centre $z$
precisely when $d(c, z) \le r$ — that is, when $z$ lies in the ball around $c$. So the number
of centres catching a fixed codeword is just the volume of a ball, $|B_r|$. There are $|C|$
codewords, each contributing $|B_r|$ to the grand total, giving $|C| \cdot |B_r|$. The same
total, counted two ways, must agree. Done.

The proof fits in a sentence, yet the consequence is sharp: the conjecture's mysterious
"target value" is not a guess. It is the *mean*, and it is exact for every code in existence.
What the famous conjecture really asks, then, is not *what* the average is — that is settled
— but whether the individual counts *concentrate* tightly around that average. The hard part
of the problem has been surgically separated from the part that was free all along.

## Why every ball is the same size

A subtle assumption sneaks into that argument: that the volume $|B_r(z)|$ of a ball is the
same no matter where you put its centre. In a curved or lopsided space this could fail, and
the whole identity would collapse. So it must be earned.

The reason it holds is a symmetry that feels obvious once stated: the Hamming ruler doesn't
care where you stand. If you shift two strings by the same amount, the positions where they
disagree don't change, so their distance is unchanged:

$$d(x + a, \; y + a) = d(x, y).$$

This *translation invariance* means the ball around any centre $z$ is just the ball around
the origin, slid over to $z$. Sliding doesn't change how many points a set contains, so

$$|B_r(z)| = |B_r(0)| \quad \text{for every } z.$$

Every ball in this space is a perfect copy of every other. That single, centre-free number
$|B_r(0)|$ is what threads through the averaging identity and makes it clean. It is the
mathematical embodiment of the idea that high-dimensional message space, despite its
unimaginable size, is perfectly homogeneous — it looks the same from every vantage point.

And we can write that number down explicitly. A string at distance *exactly* $r$ from the
origin is built by choosing which $r$ of the $n$ coordinates to change — there are
$\binom{n}{r}$ ways — and then choosing a new, different symbol in each of those positions —
there are $(q-1)$ choices each, so $(q-1)^r$ in total. That gives the size of a **sphere**
(the shell at exact distance $r$):

$$|S_r(0)| = \binom{n}{r}(q-1)^r.$$

A ball is just the spheres of radius $0, 1, \dots, r$ stacked together, so

$$|B_r(0)| = \sum_{i=0}^{r} \binom{n}{i}(q-1)^i.$$

Now the conjecture's once-mysterious target is a concrete rational number you can punch into
a calculator: $|C| \cdot \big(\sum_{i \le r}\binom{n}{i}(q-1)^i\big) / q^n$.

## What the average *cannot* tell you — and what it can

An average is a powerful thing, but it is also famously deceptive. A person with their head
in the freezer and their feet in the oven is, on average, comfortable. Knowing the mean count
of codewords per ball does not, by itself, stop some unlucky centre from catching a huge
crowd while another catches none. Concentration — the promise that *no* centre strays far
from the mean — genuinely requires more than the average. That is the residue the conjecture
still guards, and it is where randomness and the linear structure of the code finally have to
do real work.

But the exact average is not powerless. It immediately delivers a one-sided guarantee, for
free, with no assumptions at all. Suppose you worry about "crowded" centres — those catching
at least $t$ codewords. How many such centres can there possibly be? Each one contributes at
least $t$ to a grand total that we have just proved equals exactly $|C| \cdot |B_r|$. You
cannot have more crowded centres than the budget allows, so the number of centres with count
at least $t$ is at most

$$\frac{|C| \cdot |B_r|}{t}.$$

This is the Markov inequality in its purest combinatorial form. It says: *crowding is rare*.
Only a small fraction of centres can be heavily over-subscribed, because the total amount of
"catching" is fixed and finite. The upper tail of the discrepancy is controlled by the
averaging identity alone — no probability theory needed. What remains genuinely open is the
*lower* tail: ruling out centres that are suspiciously *empty*. Symmetric concentration, on
both sides at once, is the prize the full conjecture still holds.

## Codes that repeat: the periodic structure

There is one more layer of beauty when the code has algebraic structure. If $C$ is a *linear*
code — closed under addition, like the rows and combinations of a generator matrix — then it
tiles the space periodically. Shifting the whole picture by a codeword maps the code onto
itself, and a short calculation shows the intersection count is unchanged:

$$|C \cap B_r(z)| = |C \cap B_r(z')| \quad \text{whenever } z - z' \in C.$$

The discrepancy landscape is *periodic*: it repeats identically across every translate of
the code. This is the bridge to the language of **periodic discrepancy**, where one studies
how evenly a structured set distributes across a space that wraps around on itself. The same
duality that powered the averaging identity — count pairs, then flip which index you sum over
first — reappears here as the engine behind a whole family of lower bounds for how many
sample points an algorithm needs to estimate an integral accurately. In high dimensions those
bounds grow exponentially: the dreaded *curse of dimensionality*, where doubling the number
of dimensions can square the cost of any reliable computation.

## The bigger picture

It is easy to be seduced by complexity — to assume that a hard problem must hide its
treasure behind an equally hard sub-problem. The story here is the opposite. By insisting on
an *exact* statement rather than an approximate one, and by choosing the right thing to count,
an entire stratum of a famous conjecture turns out to be free. The "target value" everyone
had been chasing was never a target to be hit approximately; it was a mean to be computed
exactly. The genuine difficulty — concentration around that mean — stands out all the more
clearly once the easy part is removed.

This is the quiet power of duality and double counting. A single change of perspective —
*count the centres that catch each codeword, not the codewords caught by each centre* — turns
an intimidating sum over an astronomically large space into a one-line identity. The pebbles
can land wherever they like. Average over where you stand, and the truth comes out exact,
every time.
