# The Code That Spreads Itself Evenly

## A puzzle about balance

Imagine you are handed an enormous box of points. Not a few dozen, not a few
million, but a number so vast it dwarfs the count of atoms in the observable
universe. Each point is a string of $n$ symbols drawn from a small alphabet
of size $q$ — think of the four letters of DNA, the two bits of a computer, or
the digits $0$ through $q-1$. The whole box is the space $\mathbb{F}_q^n$, the
set of all such strings, and it holds exactly $q^n$ of them.

Now pick out a special, highly structured subset of these strings, called a
*linear code* $C$. A code is the mathematical backbone of every reliable
communication system you have ever used: the bars of a QR code, the redundancy
that lets a scratched DVD still play, the error correction that keeps a
spacecraft's faint signal intelligible across billions of kilometres. The points
of $C$ are the "legal" messages; everything else is noise or corruption.

Here is the question that has fascinated coding theorists for decades. Take a
sphere of fixed radius around any point $z$ in the whole space — the set of all
strings that differ from $z$ in at most a fixed fraction $\rho$ of their
coordinates. This is a **Hamming ball** $B_\rho(z)$, and it is exactly the set
of strings you might receive if $z$ were sent and then lightly corrupted. The
question is:

> **Does our code $C$ distribute itself *evenly* across the space, so that
> every Hamming ball — no matter where it is centred — contains its fair share
> of codewords?**

If the answer is yes, the code is a near-perfect *spreader*. No region is
starved of codewords; no region is overcrowded. This even-spreading property,
called **low discrepancy**, is exactly what you want from a good code, a good
random number generator, or a good sampling scheme.

This article is about a clean, surprising, and completely rigorous piece of that
puzzle — the part that turns out to be true *with absolute certainty*, for
*every* code, with no randomness required at all.

## What "fair share" means

Suppose your code $C$ contains $|C|$ points scattered through the space of
$q^n$ points. A particular Hamming ball $B_\rho(z)$ has some volume $|B_\rho|$
— a count of how many strings lie inside it. If the code were sprinkled
perfectly uniformly, like raisins distributed flawlessly through a cake, then
the fraction of all space occupied by the ball, $|B_\rho| / q^n$, should also
be the fraction of the *code* that lands in the ball. So the expected number of
codewords inside any one ball is

$$\text{fair share} \;=\; \frac{|C| \cdot |B_\rho|}{q^n}.$$

The grand conjecture — the **discrepancy conjecture for random linear codes** —
says that if you build $C$ at random with exactly the right dimension
$$k = \Big\lceil \big(1 - \tfrac{1}{n}\log_q |B_\rho| + \varepsilon\big)\, n \Big\rceil,$$
then with overwhelming probability *every single ball*, centred anywhere, holds
$(1 \pm o(1))$ times its fair share. The dimension formula is finely tuned: it
is the smallest code that still expects a positive constant number of codewords
in each ball, so the claim is that even at the very edge of possibility, balance
reigns.

That full statement needs randomness and a delicate probabilistic argument. But
buried inside it is a hard, exact mathematical fact that needs none of that —
and that fact is what we have proved with complete rigour.

## The first surprise: the average is exact

Here is the central discovery, stated as plainly as possible.

> **The averaging identity.** For *any* set of strings $C$ whatsoever — random
> or not, linear or not, large or small — the *average* number of codewords
> across all the balls of radius $r$, as the centre $z$ ranges over every point
> of the space, is *exactly* the fair share. No approximation, no error term,
> no probability:
> $$\frac{1}{q^n}\sum_{z} |C \cap B_r(z)| \;=\; \frac{|C|\cdot|B_r|}{q^n}.$$

Equivalently, the total count of codeword-ball incidences is exactly
$$\sum_{z} |C \cap B_r(z)| \;=\; |C|\cdot|B_r|.$$

Why is this surprising? Because the "fair share" $|C|\cdot|B_\rho|/q^n$ looks
like a *heuristic* — the kind of back-of-the-envelope guess you make by
pretending things are uniform when they are not. The theorem says it is not a
guess at all. It is the precise, dead-on average, and it holds for *every*
configuration of points. The cake might have all its raisins clustered in one
corner; the *average* number of raisins per ball-shaped scoop is still exactly
what perfect uniformity would predict.

The proof is a gem of a technique called **double counting**. Picture a giant
table with one row for each codeword $c \in C$ and one column for each centre
$z$. Put a checkmark in cell $(c, z)$ whenever $c$ lies inside the ball around
$z$ — that is, whenever the Hamming distance from $c$ to $z$ is at most $r$.
Now count the checkmarks two ways.

- **Column by column.** The number of checkmarks in column $z$ is the number of
  codewords inside $B_r(z)$, namely $|C \cap B_r(z)|$. Summing over columns gives
  the total $\sum_z |C \cap B_r(z)|$ — the left side of our identity.

- **Row by row.** The number of checkmarks in row $c$ is the number of centres
  $z$ whose ball contains $c$. But "the ball around $z$ contains $c$" means
  exactly "$c$ is within distance $r$ of $z$," which by symmetry means "$z$ is
  within distance $r$ of $c$." So the row count is just the volume of a ball
  centred at $c$.

And here is the keystone: **every Hamming ball has the same volume, no matter
where it is centred.** A ball around the point $z$ is just the ball around the
origin, shifted by $z$ — and shifting cannot change how many points you have.
Formally, Hamming distance is *translation invariant*: moving both points by the
same vector $a$ leaves their distance unchanged,
$$d(x + a,\, y + a) = d(x, y).$$
So every row of our table has the same count, $|B_r|$, and there are $|C|$ rows.
Multiplying, the total number of checkmarks is $|C| \cdot |B_r|$. The two counts
must agree, and the identity falls out.

This translation invariance is the load-bearing wall of the whole argument. If
balls in different places had different volumes, the rows would have different
counts and the clean product $|C|\cdot|B_r|$ would collapse. That is why, in
the formal development, the humble fact "$d(x+a, y+a) = d(x,y)$" is singled out
and proved first, before anything else.

## The second surprise: where the difficulty really lives

Once you know the average is exactly right, the conjecture transforms. It is no
longer asking "what is the typical number of codewords in a ball?" — we *know*
that, exactly. It is asking the sharper question: **does the actual count stay
close to that average for every single ball at once?**

That is a *concentration* question, and it is genuinely where the hard,
probabilistic work lives. The averaging identity is like knowing that a class
of students has an average test score of exactly $75$. That alone tells you
nothing about whether everyone scored near $75$ or whether half the class
scored $50$ and half scored $100$. The conjecture is the claim that, for a
randomly built code, the "scores" — the ball counts — really do cluster tightly
around their exact mean, all of them simultaneously.

Isolating this cleanly is itself a contribution: it tells future researchers
*exactly* what remains to be done. The mean is settled, deterministically and
forever. The only thing randomness is needed for is the spread.

## A free half of the answer

We can go one step further with no randomness at all. Suppose you worry only
about *overcrowding* — balls that contain far too many codewords. The averaging
identity already pins down how many such balls there can be.

> **The Markov discrepancy bound.** For any threshold $t$, the number of centres
> $z$ at which the ball $B_r(z)$ contains at least $t$ codewords is at most
> $$\frac{|C| \cdot |B_r|}{t}.$$

The reasoning is a one-line consequence of the average. Each "bad" centre
contributes at least $t$ to the total incidence count, and the total is exactly
$|C|\cdot|B_r|$. You cannot have more than $|C|\cdot|B_r| / t$ items each worth
at least $t$ when the sum is fixed — otherwise the sum would be too big. This is
the discrete cousin of **Markov's inequality**, and it hands us, for free, one
half of the concentration story: there can be only a small number of
overcrowded balls. The genuinely random part of the conjecture is then the
*other* half — ruling out balls that are too *empty* — and ensuring the few
exceptions vanish as $n$ grows.

## Putting a number on the ball

To use any of this in practice, you need to know the ball volume $|B_\rho|$ as
an actual number. Here too there is a beautifully classical formula, and it is
worth seeing where it comes from.

How many strings lie at Hamming distance *exactly* $r$ from a fixed centre?
Such a string disagrees with the centre in precisely $r$ of its $n$
coordinates. First choose *which* $r$ coordinates differ — there are
$\binom{n}{r}$ ways. Then, in each of those chosen coordinates, pick any symbol
*other* than the centre's symbol — there are $q - 1$ choices in each of the $r$
spots, for $(q-1)^r$ combinations. Multiplying:

$$|\text{sphere of radius } r| \;=\; \binom{n}{r}\,(q-1)^r.$$

A ball of radius $r$ is just the union of the spheres of radii
$0, 1, \dots, r$, and these don't overlap, so its volume is the running sum:

$$|B_r| \;=\; \sum_{i=0}^{r} \binom{n}{i}\,(q-1)^i.$$

This single closed form is what makes the dimension threshold in the conjecture
concrete. Taking logarithms base $q$, the exponent $\frac1n\log_q|B_\rho|$
converges, as $n$ grows, to the **$q$-ary entropy** $H_q(\rho)$, the universal
quantity that governs how much information can be packed into a noisy channel.
So the dimension formula $k \approx (1 - H_q(\rho))\,n$ is exactly the famous
Gilbert–Varshamov / channel-capacity frontier in disguise. The discrepancy
conjecture is, at heart, a statement that codes can spread *evenly* right up to
that information-theoretic edge.

## A hidden symmetry for free

For codes that really are *linear* — closed under addition — there is one more
elegant structural fact. The function that sends a centre $z$ to its ball count
$|C \cap B_\rho(z)|$ is not just any function: it is **constant on cosets**.
Two centres that differ by a codeword always see *exactly* the same number of
codewords in their balls.

This is more than a curiosity. The conjecture quantifies over all $q^n$
centres, but coset invariance says those $q^n$ tests are really only
$q^n / |C|$ *distinct* tests — one per coset. That is an exponential reduction
in the number of things that can go wrong, and it sharpens any "union bound"
over centres dramatically. The natural arena for the whole problem turns out to
be not the space of points but the *quotient* of the space by the code.

## Why any of this matters

The Hamming ball is not an abstract toy. It is the geometric shape of *error*
itself: when a message is corrupted, the result lands somewhere in a ball around
the original. A code that spreads evenly across all balls is a code whose
decoding regions are balanced, whose list-decoding behaviour is predictable, and
whose performance does not depend on which message happened to be sent. The same
even-spreading ideal drives the design of low-discrepancy sequences used in
high-dimensional numerical integration (the engine behind much of computational
finance and physics simulation), of hash functions that scatter data uniformly
across a table, and of pseudorandom generators that must imitate true randomness
under every statistical test.

What this work pins down, with certainty, is the part of that ideal that is
*automatic*: the average is always exactly right, the ball volume is always the
same everywhere, overcrowding is always rare, and for linear codes the whole
question collapses onto cosets. These are not approximations that hold "with
high probability" or "for large enough $n$." They are exact identities, true
for every code, every radius, every alphabet, in every dimension.

The remaining mystery — does *every* ball, simultaneously, stay close to that
exact average? — now stands in sharp relief, stripped of everything that was
ever certain, waiting for the one genuinely probabilistic idea that will close
it. Sometimes the deepest progress in mathematics is not solving the whole
problem at once, but discovering precisely which part of it was never in doubt.
