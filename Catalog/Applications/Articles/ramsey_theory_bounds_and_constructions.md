# Six Friends, Nine Strangers, and the Arithmetic of Inevitable Order

## A party trick that hides a theorem

Invite six people to a party. Some pairs are old friends; the rest are
strangers meeting for the first time. No matter who knows whom, you are
guaranteed one of two things: three people who are all mutual friends, or
three people who are all mutual strangers. There is no way to seat your six
guests so as to avoid both. Try it on five guests, though, and the guarantee
evaporates — there is a clever seating of five people with no mutual triple of
either kind.

That sharp jump from "avoidable at five" to "inevitable at six" is the smallest
nontrivial fact in a subject called **Ramsey theory**, named after the British
mathematician and philosopher Frank Ramsey, who proved a sweeping version of it
in 1930 before dying at the age of twenty-six. Ramsey theory studies a single,
almost philosophical idea: *complete disorder is impossible*. If a structure is
large enough, some orderly pattern must appear inside it, whether you want it
to or not.

This article tells the story of three precise incarnations of that idea, all of
which we have nailed down completely:

- The party fact above, written $R(3,3) = 6$.
- Its bigger sibling, $R(3,4) = 9$: among nine people you cannot avoid both a
  mutual triple of friends *and* a mutual quadruple of strangers.
- A general ceiling, the **Erdős–Szekeres bound**, that controls how fast these
  thresholds can grow — and a probabilistic argument that shows they grow
  enormously fast in the other direction.

Along the way we will meet a beautiful and slightly surprising hero: a humble
fact about *odd and even numbers* that turns out to be the exact reason the
nine-person threshold is nine and not ten.

## Drawing the party as a graph

To reason about parties cleanly, mathematicians draw a dot for each person and
a line between every pair. Colour the line **red** if the pair are friends and
**blue** if they are strangers. Every possible friendship pattern is now a
two-colouring of all the lines of a complete network. The two patterns we hunt
for are:

- a **red triangle**: three dots, all three connecting lines red (a mutual
  triple of friends);
- a **blue triangle**: three dots, all three lines blue (a mutual triple of
  strangers).

We write $n \to (s, t)$ — read "$n$ arrows $(s,t)$" — to mean: *every* red/blue
colouring of the complete network on $n$ dots contains either a red clique of
$s$ dots (every pair among them red) or a blue clique of $t$ dots (every pair
among them blue). The **Ramsey number** $R(s,t)$ is the smallest $n$ for which
$n \to (s,t)$ holds. The party fact is exactly the statement that $R(3,3) = 6$.

## Why six is unavoidable

Here is the classic one-paragraph argument, and it is worth savouring because
the whole subject is built from variations on it.

Pick any one of the six guests; call her Alice. Alice has five lines leaving
her, each red or blue. By the pigeonhole principle, at least three of them share
a colour — say three are red, connecting Alice to Bob, Carol, and Dan. Now look
at the three lines *among* Bob, Carol, and Dan. If any one of them is red, that
pair together with Alice forms a red triangle, and we are done. If none is red,
then all three are blue — so Bob, Carol, and Dan themselves form a blue
triangle. Either way a monochromatic triangle appears. Inevitability achieved.

To prove that six is the *smallest* such number, we must exhibit a five-person
party with no monochromatic triangle. The answer is a pentagon. Seat five
people in a ring and let each person be friends only with their two immediate
neighbours; everyone else is a stranger. The red friendships form a five-cycle,
and a five-cycle has no triangle at all. The blue strangers form the
"pentagram" of long diagonals — which is *also* a five-cycle, and so also
triangle-free. Five people, no mutual triple either way. Hence the threshold is
exactly six:
$$R(3,3) = 6.$$

## The Erdős–Szekeres ceiling

How big can Ramsey numbers get? In 1935 Paul Erdős and George Szekeres found a
gorgeous recursive bound that still underlies every general upper estimate we
have. Phrased through the arrow relation, it says:

> If $m \to (s, t{+}1)$ and $n \to (s{+}1, t)$, then $(m+n) \to (s{+}1, t{+}1)$.

The proof is the six-person argument in disguise. Take a colouring on $m+n$
dots and single out one vertex $v$. Split everyone else into $v$'s red
neighbours $R$ and blue neighbours $B$. Since $|R| + |B| = m + n - 1$, either
$R$ has at least $m$ dots or $B$ has at least $n$. In the first case the
guarantee $m \to (s, t{+}1)$ kicks in inside $R$: it produces a blue
$(t{+}1)$-clique (done) or a red $s$-clique, and tacking $v$ onto that red
$s$-clique — every vertex of $R$ is a red neighbour of $v$ — yields a red
$(s{+}1)$-clique. The other case is the mirror image.

Feeding this recursion the trivial facts $1 \to (1, b)$ and $1 \to (a, 1)$ (a
single person is both a one-clique of friends and a one-clique of strangers),
and following the addition pattern of Pascal's triangle, gives the celebrated
binomial ceiling:
$$R(s{+}1,\, t{+}1) \;\le\; \binom{s+t}{s}.$$
For the diagonal case this means $R(k{+}1, k{+}1) \le \binom{2k}{k}$, which is
roughly $4^k$. The party number $R(3,3)$ fits perfectly: the formula gives
$\binom{4}{2} = 6$, exactly the right answer.

But the formula is not always exact. For $R(3,4)$ it predicts only
$\binom{5}{2} = 10$. The true value is **nine**. To shave off that last unit we
need a genuinely new idea — and it comes from parity.

## Nine, not ten: the handshake that decides it

Consider $R(3,4)$: we want the smallest $n$ guaranteeing a red triangle or a
blue clique of four strangers. The lower bound — that eight is not enough —
comes from an elegant explicit construction on eight vertices known as a
**Möbius ladder**. Label eight points $0,1,\dots,7$ arranged in a circle and
declare two of them friends exactly when their positions differ by $1$ (around
the rim) or by $4$ (straight across). This red graph has no triangle, and its
blue complement contains no clique of four. So
$$8 \not\to (3,4), \qquad \text{i.e.} \qquad R(3,4) > 8.$$

Now for the upper bound. We must show every red/blue colouring of *nine* dots
contains a red triangle or a blue four-clique. Suppose, for contradiction, that
some colouring of nine dots dodges both. A short counting argument shows each
vertex must have **exactly three** red neighbours — no more (four red
neighbours would force a red triangle or a blue four-clique among them) and no
fewer (too few red neighbours leaves too many blue ones, again forcing a blue
four-clique). In other words, the red friendship graph would have to be
perfectly *3-regular*: every one of the nine people has exactly three friends.

And here the whole edifice collapses on a single parity fact. Count friendships
by adding up everyone's number of friends. Each friendship gets counted twice —
once from each end — so the grand total is always an **even** number. This is
the *handshake lemma*: at any party, the total of everyone's handshake counts is
even. But a 3-regular graph on nine people gives a total of
$$9 \times 3 = 27,$$
which is **odd**. Contradiction. No such colouring can exist, so nine dots
always force the pattern, and combined with the eight-vertex construction:
$$R(3,4) = 9.$$

The binomial ceiling said "at most ten." Parity said "actually nine." A
question about cliques and colours was decided by the difference between odd and
even.

## The hidden engine, made general

What makes this story more than a cute coincidence is that the deciding step has
nothing to do with the numbers three and four. Strip away the specifics and you
are left with a clean, reusable theorem about *any* friendship pattern on *any*
finite set of people.

Define the **red-degree** of a person $v$, relative to a group $W$, to be the
number of $v$'s friends who also belong to $W$. Then:

> **The parity obstruction.** If a group $W$ has an *odd* number of members,
> then it is impossible for *every* member of $W$ to have an *odd* red-degree
> inside $W$.

The reason is exactly the handshake lemma: the red-degrees inside $W$ always sum
to an even number, and you cannot write an even number as a sum of an odd count
of odd numbers. From this one statement a sweeping corollary drops out:

> **No odd-regular colouring.** If $n \times d$ is odd, then no friendship
> pattern on $n$ people can be perfectly $d$-regular — you cannot have every
> single one of $n$ people owning exactly $d$ friends.

The $R(3,4) = 9$ proof is now simply the case $n = 9$, $d = 3$: since
$9 \times 3 = 27$ is odd, a 3-regular red graph on nine vertices is forbidden,
and the hypothetical counterexample never gets off the ground. The bespoke
"$27$ is odd" trick has been promoted to a general law that applies to *any*
future sharp Ramsey bound whose extremal colouring is forced to be odd-regular
on an odd number of vertices.

## The other side of the mountain: disorder is rare

So far we have been climbing *down*, capping how large Ramsey numbers can be.
What about climbing *up* — showing they are genuinely huge? Here Erdős
introduced, in 1947, one of the most influential ideas in modern combinatorics:
the **probabilistic method**. Instead of cleverly constructing a colouring that
avoids monochromatic cliques, simply flip a fair coin for every line and show
that, on average, a random colouring works.

In its general form for $r$-uniform hypergraphs (where instead of colouring
pairs we colour every $r$-element subset), the argument is a single inequality.
Colour each $r$-subset of $n$ points red or blue by an independent coin flip.
For any fixed candidate clique of $k$ points, the chance that *all* of its
$\binom{k}{r}$ constituent subsets came out the same colour is
$2 \cdot 2^{-\binom{k}{r}}$. There are $\binom{n}{k}$ candidate cliques, so the
expected number of monochromatic ones is at most $2\binom{n}{k} 2^{-\binom{k}{r}}$.
If that product is below $1$, then some colouring must have *zero*
monochromatic cliques. In symbols:

> **Probabilistic lower bound.** If $\;2 \binom{n}{k} < 2^{\binom{k}{r}}$, then
> there is an $r$-uniform colouring of $n$ points with no monochromatic
> $k$-clique — so the corresponding Ramsey number exceeds $n$.

For ordinary graphs ($r = 2$) this yields the famous estimate
$$R(k,k) > 2^{k/2}.$$
Pair it with the Erdős–Szekeres ceiling $R(k,k) \le 4^k$ and you get the
maddening sandwich that has stood, essentially, for over seventy years:
$$2^{k/2} \;<\; R(k,k) \;\le\; 4^k.$$
The base of the exponent — somewhere between $\sqrt2$ and $4$ — is one of the
great unknowns of combinatorics. Closing that gap by even a sliver was the
subject of a celebrated 2023 breakthrough, and the question of its true value
remains open.

What makes the probabilistic bound so philosophically striking is *how* it
works. It never builds a single example. It proves that good colourings exist by
showing they are *common* — a random one works with positive probability. Order
may be inevitable in the long run, but disorder, too, is abundant up to a
threshold that grows exponentially.

## Why any of this matters

Ramsey theory began as a question in pure logic, but its fingerprints are
everywhere. The same pigeonhole-and-counting machinery underlies error-correcting
codes that keep deep-space transmissions intact, the design of robust
communication networks that cannot be fully disconnected by an adversary,
lower bounds in theoretical computer science, and even the analysis of large
social and biological networks, where Ramsey-type results explain why tightly
knit clusters are unavoidable once a network passes a certain size.

But the deepest lesson is the one the party trick whispers: structure is not
something you always have to impose. Past a certain scale, it imposes itself.
Six guests already guarantee a clique. Nine guarantee more. And the precise
moment the guarantee snaps into place can hinge on something as small, and as
unyielding, as the difference between an odd number and an even one.
