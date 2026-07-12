# Counting the Uncountable-Looking: Fuss–Catalan Numbers and the Hidden Order of $m$-Tamari Intervals

## A number that refuses to be a fraction

Here is a small miracle you may have met without noticing. Take the number of ways to arrange $2n$ objects into two equal piles — the central binomial coefficient $\binom{2n}{n}$. Now divide it by $n+1$. You might expect a ragged fraction. Instead you always get a whole number:

$$C_n \;=\; \frac{1}{n+1}\binom{2n}{n} \;=\; 1,\,1,\,2,\,5,\,14,\,42,\,132,\,\dots$$

These are the **Catalan numbers**, and they are among the most ubiquitous integers in mathematics. They count the ways to correctly nest parentheses, the triangulations of a polygon, the binary trees on $n$ nodes, the paths that stay above a diagonal, and — the hero of this story — the elements of the **Tamari lattice**, a beautiful structure that organizes all the different ways of parenthesizing a product.

That a division should *always* land exactly on an integer is not an accident. It is a signal that something is being counted, and behind every such "coincidence" there is a combinatorial reason. This article is about what happens when you turn a single dial — replacing the number $2$ by a general parameter $m+1$ — and watch the entire edifice of Catalan combinatorics reappear in a richer, layered form.

## Turning the dial: from Tamari to $m$-Tamari

The Tamari lattice is a way of laying out the parenthesizations of an expression so that "moving one pair of parentheses to the right" becomes a step upward. It is a lattice: any two arrangements have a well-defined meeting point below and joining point above. Its elements are counted by the Catalan numbers.

Now generalize. Fix an integer $m \ge 1$. The **$m$-Tamari lattice** of size $n$ plays the same organizing role, but for a wider world of objects: $(m+1)$-ary trees with $n$ internal nodes, or equivalently lattice paths that stay above a line of slope $m$. When $m=1$ we recover the classical Tamari lattice. As $m$ grows, the objects branch more and the lattice swells.

Two questions immediately present themselves:

1. **How many elements** does the $m$-Tamari lattice of size $n$ have?
2. **How many intervals** — pairs (bottom, top) with bottom $\le$ top — does it contain?

The answers are governed by two families of numbers, and the deep and still partly conjectural story is that the second family also counts something that looks utterly different: the **planar $(m+1)$-constellations**, a class of maps drawn on the sphere. This article makes the two counting families precise, proves the exact arithmetic that makes them integers, and explains what the numbers are trying to tell us about the bridge to constellations.

## The element count: Fuss–Catalan numbers

The number of elements of the $m$-Tamari lattice of size $n$ is the **Fuss–Catalan number**

$$\mathrm{Cat}_m(n) \;=\; \frac{1}{mn+1}\binom{(m+1)n}{n}.$$

Set $m=1$ and you get $\frac{1}{n+1}\binom{2n}{n}$ — the Catalan numbers, exactly as promised. These generalized numbers were studied by Nicolaus Fuss, a student and collaborator of Euler, more than two centuries ago, and they count the $(m+1)$-ary trees on $n$ internal nodes just as Catalan numbers count binary trees.

But writing $\mathrm{Cat}_m(n)$ as a fraction hides the very fact that makes it interesting: it is an integer. To *prove* that, we take a different route. Define the number not by a division but by an honest **difference of two whole numbers**:

$$\mathrm{Cat}_m(n) \;=\; \binom{(m+1)n}{n} \;-\; m\binom{(m+1)n}{n-1}.$$

This expression is manifestly a non-negative integer — no division in sight. The first theorem below shows the two descriptions agree.

> **Theorem (Closed form).** For all $m,n \ge 0$,
> $$(mn+1)\,\Big[\binom{(m+1)n}{n} - m\binom{(m+1)n}{n-1}\Big] \;=\; \binom{(m+1)n}{n}.$$
> In words: the integer-valued difference formula, multiplied by $mn+1$, reproduces the central binomial coefficient. Hence the two descriptions of $\mathrm{Cat}_m(n)$ coincide, and in particular $\mathrm{Cat}_m(n)$ is always a whole number.

The proof is a single, clean cancellation. The binomial coefficients satisfy the elementary recurrence
$$n\binom{N}{n} = (N-n+1)\binom{N}{n-1},$$
and when $N=(m+1)n$ the factor $N-n+1$ becomes exactly $mn+1$. Feed this into the difference formula and everything collapses to the identity above. From it we get a genuine arithmetic fact for free:

> **Corollary (Divisibility).** For all $m,n$, the quantity $mn+1$ divides $\binom{(m+1)n}{n}$.

For $m=1$ this is the classical statement that $n+1$ divides $\binom{2n}{n}$ — the reason the Catalan numbers are integers. Our result is its full $m$-generalization, and it comes not from a counting bijection but from a two-line binomial manipulation.

A few sanity checks confirm the sequence behaves. We find $\mathrm{Cat}_m(0)=1$, $\mathrm{Cat}_m(1)=1$, and $\mathrm{Cat}_m(2)=m+1$. That last value is a small delight: it shows the sequence genuinely depends on $m$ (for $m\ge 1$ it already exceeds $1$ at $n=2$), so the Fuss–Catalan family really is a one-parameter deformation, not a disguise for a single sequence. And at $m=1$ the difference formula reproduces the ordinary Catalan numbers term for term.

## The interval count: the Bousquet-Mélou–Chapoton numbers

Counting *elements* is only half the story. The richer invariant is the number of **intervals** — the pairs of comparable elements. Mireille Bousquet-Mélou and Frédéric Chapoton discovered a strikingly clean formula for it:

$$\mathrm{Int}_m(n) \;=\; \frac{m+1}{n(mn+1)}\binom{(m+1)^2 n + m}{\,n-1\,}.$$

For $m=1$ this produces the sequence
$$1,\;3,\;13,\;68,\;399,\;\dots$$
These are exactly the numbers that count intervals in the classical Tamari lattice — and, remarkably, also the number of planar triangulations of certain types. For $m=2$ the sequence begins
$$1,\;6,\;58,\;\dots$$

Two features of these numbers are worth pausing on.

**Intervals vastly outnumber elements.** Already at $m=1,\ n=2$, the lattice has $\mathrm{Cat}_1(2)=2$ elements but $\mathrm{Int}_1(2)=3$ intervals. This is the qualitative fingerprint the whole theory must respect: any bijection linking the $m$-Tamari world to constellations cannot be a correspondence between *elements* — it has to live at the level of *intervals*. The intervals are where the real information hides.

**Why is $\mathrm{Int}_m(n)$ an integer?** The formula has a denominator $n(mn+1)$, and it is not at all obvious that it always divides the binomial coefficient on top. The two factors $n$ and $mn+1$ are coprime — they share no common divisor, since any common factor of $n$ and $mn+1$ would have to divide $1$. So integrality splits cleanly into two independent divisibility questions, one for each factor.

We settle the first one completely.

> **Theorem ($n$ divides the numerator).** For every $m$ and every $n\ge 1$,
> $$n \;\big|\; (m+1)\binom{(m+1)^2 n + m}{\,n-1\,}.$$

The proof, once again, is a single binomial absorption identity. Write $N=(m+1)^2 n + m$. The recurrence $n\binom{N}{n} = (N-n+1)\binom{N}{n-1}$ has $N-n+1 = m(m+2)n + (m+1)$ in this case, which rearranges to express $(m+1)\binom{N}{n-1}$ as $n$ times an explicit integer. Because $n$ and $mn+1$ are coprime, this reduces the full integrality of $\mathrm{Int}_m(n)$ to a *single* remaining question: does $mn+1$ divide the same numerator? That is the frontier — and unlike the $n$-factor, it resists a one-step absorption argument, because the index $n-1$ and the target modulus $mn+1$ are not directly related. It appears to demand a cycle-lemma or Lagrange-inversion argument, the same circle of ideas behind the Fuss–Catalan divisibility.

## Two tempting shortcuts that fail

Part of doing mathematics honestly is testing the guesses that *look* right and reporting when they are wrong. Two natural conjectures about the Fuss–Catalan numbers turn out to be false, and each failure is instructive.

**"Surely the numbers are symmetric in $m$ and $n$."** They are not. We have $\mathrm{Cat}_1(2)=2$ but $\mathrm{Cat}_2(1)=1$. Swapping the two roles changes the answer. The parameter $m$ (how much the trees branch) and the parameter $n$ (how big they are) play genuinely different roles.

**"Surely the extra factor of $m$ in the difference formula is a typo."** The clean-looking formula $\binom{(m+1)n}{n} - \binom{(m+1)n}{n-1}$ — with no $m$ multiplying the second term — is exactly the shape of the classical Catalan number when $m=1$, so it is tempting to believe it works in general. It does not. At $m=2,\ n=2$ it evaluates to $9$, whereas the true value is $\mathrm{Cat}_2(2)=3$. The multiplier $m$ on the second binomial is essential — and its presence is precisely what the cancellation in the closed-form proof relies on. What looks like a blemish on the formula is the load-bearing beam.

## Why this matters

Zoom out. The Catalan numbers are a hub where dozens of combinatorial families meet. The $m$-Tamari story is the discovery that this hub is really a *slice* of a larger, parameterized landscape — one where trees branch more, lattices grow taller, and a second, richer sequence (the interval numbers) emerges alongside the first. The conjecture driving the whole program is that these interval numbers count planar $(m+1)$-constellations: intricate maps drawn on the sphere, objects that arise in the study of factorizations of permutations and in mathematical physics' matrix models. That a lattice of parenthesizations and a family of surface maps should be counted by the *same* integers is the kind of coincidence that, historically, has always concealed a bijection waiting to be found.

The arithmetic proved here is the enumerative bedrock of that bridge. It pins down exactly which integers are in play, proves the non-obvious fact that they *are* integers, isolates precisely the one divisibility step that remains open, and clears away two plausible-but-false shortcuts that would otherwise send searchers down blind alleys. The elements are counted by Fuss–Catalan numbers; the intervals, more numerous, by the Bousquet-Mélou–Chapoton numbers; and the space between them is where a beautiful, still-unfinished correspondence lives.

Sometimes the deepest way to understand a structure is to count it — and then to ask, with genuine curiosity, *what else* is counted by the very same numbers.
