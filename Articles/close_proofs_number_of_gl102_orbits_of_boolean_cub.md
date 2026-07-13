# Counting the Uncountable-Looking: How Many Truly Different Cubic Patterns Live in Ten Bits?

## A number with a story

Some numbers arrive without any drama. Others carry a whole hidden world.
The number

$$3{,}691{,}560$$

belongs firmly to the second kind. It counts something enormous, tames
something chaotic, and — most delightfully — it is *not* the number you would
first guess. It is the exact count of genuinely distinct cubic patterns you can
write down using ten yes/no switches, once you agree that two patterns are "the
same" whenever one can be turned into the other by relabeling and mixing the
switches.

To see why that is surprising, and why the true answer refuses to be the
"obvious" one, we need to take a short walk through the arithmetic of switches.

## Switches, and the algebra of on-or-off

Imagine ten light switches, each either **on** ($1$) or **off** ($0$). A
*Boolean function* is any rule that looks at the ten switches and answers with a
single bit, on or off. There are $2^{10} = 1024$ possible switch settings, and
a function must decide an output for each, so there are $2^{1024}$ Boolean
functions in ten variables — a number with over three hundred digits. That is
far too many to think about all at once.

Mathematicians tame this jungle by sorting functions according to their
*degree*, exactly as we sort ordinary polynomials into linear, quadratic, and
cubic. The twist is that our arithmetic lives in the world of bits, where
$1 + 1 = 0$. In that world $x \cdot x = x$ (a switch times itself is just the
switch), so the only interesting building blocks are products of *distinct*
switches:

- **Degree 1:** the single switches $x_1, \dots, x_{10}$.
- **Degree 2:** the pairs $x_i x_j$.
- **Degree 3:** the triples $x_i x_j x_k$.

A **cubic form** is a sum (remember, addition is bitwise) of such triples. How
many triples are there? Exactly the number of ways to choose $3$ switches out of
$10$:

$$\binom{10}{3} = 120.$$

So the pure cubic layer is a $120$-dimensional space of switches-worth of
choices: each of the $120$ triples is either included or not. That gives

$$2^{120} = 1{,}329{,}227{,}995{,}784{,}915{,}872{,}903{,}807{,}060{,}280{,}344{,}576$$

cubic forms, of which all but one — the empty sum — are nonzero. This is our
raw material: over $10^{36}$ cubic patterns, a number vastly larger than the
count of atoms on Earth.

## When are two patterns "really" the same?

Listing $10^{36}$ objects is pointless if most of them are cosmetic variants of
each other. And they are. Nothing forces us to call the first switch "the
first" — we could permute the labels, or, more powerfully, replace each switch
by a *combination* of switches. In bit-arithmetic, a legal, reversible change of
variables is exactly an invertible $10 \times 10$ matrix of bits. The collection
of all such matrices forms a group, the **general linear group** $GL(10,2)$, and
it acts on cubic forms by substitution: feed the new mixed switches into the old
formula and simplify.

Two cubic forms should count as "the same pattern" precisely when one is carried
to the other by some element of $GL(10,2)$. The bundles of mutually
interchangeable forms are called **orbits**, and the real question — the one
worth $3{,}691{,}560$ — is:

> **How many distinct orbits of nonzero cubic forms are there?**

This is a classification problem in disguise. Answering it means knowing every
essentially different way a cubic pattern in ten bits can behave.

## The size of the symmetry group

Before counting orbits, we should appreciate the size of the group doing the
shuffling. An invertible bit-matrix is built column by column: the first column
can be any nonzero vector ($2^{10} - 1$ choices), the second any vector outside
the line spanned by the first ($2^{10} - 2$ choices), the third any vector
outside the plane spanned by the first two ($2^{10} - 4$), and so on. Multiplying
these together gives the exact order

$$|GL(10,2)| = \prod_{i=0}^{9}\bigl(2^{10} - 2^{i}\bigr)
= 366{,}440{,}137{,}299{,}948{,}128{,}422{,}802{,}227{,}200,$$

a $30$-digit colossus. It is this staggering amount of symmetry that collapses
$10^{36}$ cubic forms down to a few million orbits.

## The naive guess — and why it must be wrong

Here is the tempting shortcut. If every orbit had the *full* size of the group —
that is, if the group never fixed a nonzero form and every reshuffle produced a
genuinely different form — then the orbits would simply partition the
$2^{120}-1$ forms into equal bundles of size $|GL(10,2)|$. The number of orbits
would then be

$$\frac{2^{120}-1}{|GL(10,2)|} \approx 3{,}627{,}408.6,$$

which is not even a whole number. Rounding, one might guess $3{,}627{,}408$ or
$3{,}627{,}409$. The true answer, $3{,}691{,}560$, sits *above* both.

That gap is not a rounding artefact — it is a theorem. And proving that the naive
guess *must* fail is one of the cleanest arguments in the whole story. It rests
on a single observation about parity:

- The group order $|GL(10,2)|$ is **even** (it has a factor $2^{10}-2 = 1022$).
- The number of nonzero forms $2^{120}-1$ is **odd**.

An even number can never divide an odd number. So $|GL(10,2)|$ does *not* divide
$2^{120}-1$. Now comes the punchline. A group action in which every orbit has the
full group size is called **free**, and a basic counting fact says that a free
action forces the group order to divide the size of the space:

> **Freeness Obstruction.** If a finite group $G$ acts on a finite set $X$ and
> every point has trivial stabilizer (the action is free), then $|G|$ divides
> $|X|$.

The proof is a one-liner in spirit: a free action chops $X$ into orbits each of
size exactly $|G|$, so $|X|$ is a multiple of $|G|$. Turning this around gives
the useful contrapositive:

> **If $|G|$ does not divide $|X|$, then some point of $X$ has a nontrivial
> stabilizer** — some nonzero element is fixed by a nontrivial symmetry.

Applied to our setting: because $|GL(10,2)|$ is even and $2^{120}-1$ is odd,
divisibility fails, so **there must exist a nonzero cubic form fixed by a
nontrivial linear substitution.** The action is not free, the naive
equal-bundles picture collapses, and the orbit count can never be the clean
quotient $3{,}627{,}408$. Parity alone rules it out.

## A lower bound you cannot escape

If we cannot get the exact count for free, can we at least fence it in? Yes —
and remarkably, without invoking any heavy machinery. The key is a general
inequality that any finite symmetry situation must obey:

> **Orbit Lower Bound.** For a finite group $G$ acting on a finite set $X$,
> $$|X| \le (\text{number of orbits}) \times |G|.$$
> Equivalently, the number of orbits is at least $|X| / |G|$.

The reasoning is transparent. Split $X$ into its orbits. Each orbit has size
equal to $|G|$ divided by the size of the stabilizer of any of its points — so
each orbit is *at most* $|G|$ in size. If you have $r$ orbits, none bigger than
$|G|$, then the total $|X|$ can be at most $r \cdot |G|$. Divide through and the
number of orbits is at least $|X|/|G|$.

Plugging in our numbers, the number of orbits of nonzero cubic forms must be at
least

$$\left\lceil \frac{2^{120}-1}{|GL(10,2)|} \right\rceil = 3{,}627{,}409.$$

So *any* correct answer lives at or above $3{,}627{,}409$. The classification
value $3{,}691{,}560$ comfortably clears this floor:

$$3{,}691{,}560 \ge 3{,}627{,}409,$$

and equivalently $3{,}691{,}560 \cdot |GL(10,2)| \ge 2^{120}-1$. The published
count is *consistent* with the elementary constraints — it passes the test that
would immediately expose a wrong answer.

## The meaning of the surplus

The difference between the true count and the forced floor is

$$3{,}691{,}560 - 3{,}627{,}409 = 64{,}151.$$

This surplus is not noise; it is a census. Every orbit smaller than the full
group size — every orbit whose forms enjoy some genuine internal symmetry —
nudges the count above the naive floor. The $64{,}151$ extra orbits are the
mathematical shadow of all those fixed forms the parity argument guaranteed must
exist. In other words, the two halves of the story fit together: the freeness
obstruction promises that special, symmetric forms exist, and the surplus counts
how much they inflate the answer beyond the "everything is generic" prediction.

## Why bother?

Boolean functions are the atoms of digital logic, and their cubic layer is a
recurring character in coding theory and cryptography. The space of cubic forms
in $n$ bits is precisely the top layer of the **Reed–Muller code** $RM(3,n)$ over
its predecessor $RM(2,n)$, a family of error-correcting codes that once guided
spacecraft telemetry back to Earth. Classifying cubic forms up to linear
equivalence is the same as classifying these codewords up to the code's natural
symmetries — knowledge that feeds directly into understanding nonlinearity,
resistance to certain attacks, and the geometry of the code itself. The count
$3{,}691{,}560$ is the ten-variable entry in a table that has fascinated
combinatorialists and cryptographers for decades, and each new entry is a small
landmark because the underlying spaces grow so ferociously fast.

## The shape of certainty

What makes this episode satisfying is that every claim rests on reasoning you
can hold in your head at once:

- The space of nonzero cubic forms has exactly $2^{120}-1$ elements, because
  there are $\binom{10}{3}=120$ triples.
- The symmetry group has exactly
  $\prod_{i=0}^{9}(2^{10}-2^{i}) = 366{,}440{,}137{,}299{,}948{,}128{,}422{,}802{,}227{,}200$
  elements.
- Any correct orbit count is at least $3{,}627{,}409$, by the orbit lower bound.
- The count can never be $3{,}627{,}408$, because an even group order cannot
  divide an odd space size, so the action is not free.
- The classification value $3{,}691{,}560$ clears the floor with $64{,}151$ to
  spare, and that surplus is exactly the fingerprint of forms with nontrivial
  symmetry.

A single number, $3{,}691{,}560$, and around it a small constellation of
theorems — about the size of a group, the arithmetic of parity, and the
unbreakable bookkeeping of orbits — that together pin it down, sanity-check it,
and explain the one thing you would never have guessed: that the honest answer
had to be *bigger* than the tidy one.
