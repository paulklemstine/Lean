# How a Machine Knows It Just Discovered Something New

## The problem with a tireless inventor

Imagine a research engine that never sleeps. Day and night it generates
mathematical statements, proves them, and files them away. After a year it has a
library of a hundred thousand theorems. After a decade, millions. There is a
quiet danger lurking inside this productivity: how do you know the machine isn't
just rediscovering the Pythagorean theorem in a thousand disguises?

A human mathematician feels novelty in their bones. They recognize the contour of
an old idea, the family resemblance between a fresh claim and something proved
generations ago. A machine has no such instinct — unless we build it one. And if
we are going to trust a machine to tell us *"this result is genuinely new,"* we
should demand more than a confident-sounding label. We should demand a
**certificate**: a guarantee, checkable and unfakeable, that the new result truly
stands apart from everything already known.

This is the story of how to build that certificate, and of a surprising payoff at
the end: a single classical fact about Fibonacci numbers turns out to be an
*inexhaustible spring* of provably-new theorems.

## Turning ideas into points

The first move is the oldest trick in applied mathematics: turn the thing you
care about into a number, or a list of numbers, so that geometry can do your
thinking for you.

We imagine an **embedding space** — a space $X$ in which every known theorem is a
single point. Two theorems that say "almost the same thing" sit close together;
two theorems about wildly different subjects sit far apart. We do not need to
commit to *how* the embedding is computed (that is the job of a learned model, the
same way modern language systems turn sentences into vectors). We only need the
space to come equipped with a way of measuring distance between points. In the
language of mathematics, $X$ is a **metric space**: for any two points $x$ and
$y$ there is a distance $\operatorname{dist}(x,y) \ge 0$, distances are
symmetric, and the **triangle inequality** holds,
$$\operatorname{dist}(x,z) \le \operatorname{dist}(x,y) + \operatorname{dist}(y,z).$$

The library of everything the machine already knows becomes a finite cloud of
points — we call it the **catalog** $C$. A *candidate* new result is just another
point $x$. The question "is $x$ new?" becomes a question about geometry: *how far
is the point $x$ from the nearest point of the cloud $C$?*

## The definition that does all the work

We define the **novelty** of a candidate $x$ relative to a catalog $C$ as its
distance to the closest catalog entry:
$$\operatorname{novelty}(C, x) \;=\; \min_{c \in C} \operatorname{dist}(x, c).$$

That is the whole idea, and its simplicity is the point. If $x$ lands right on top
of some known theorem, its novelty is zero — it is a duplicate. If the nearest
known theorem is a comfortable distance away, the novelty is large, and we have
geometric grounds to call $x$ new.

A **novelty certificate at level $\varepsilon$** is then a proof of a single
inequality:
$$\varepsilon \le \operatorname{novelty}(C, x), \qquad \varepsilon > 0.$$

A certificate is a number $\varepsilon$ together with a guarantee that *every*
known result is at least $\varepsilon$ away. The larger $\varepsilon$, the bolder
and more defensible the claim of novelty.

For this to be honest, three things must be true. The certificate must be
**sound** (a positive number really does mean the result is not already in the
catalog), **separating** (the margin $\varepsilon$ really does hold against
*every* entry, not just most of them), and **stable** (a small error in computing
the embedding cannot flip a genuinely new result into a fake one, or vice versa).
Each of these is a theorem, and each has been proved.

## Soundness: no false alarms

The most basic promise is that the system never cries wolf in reverse — it never
stamps "NEW" on something already sitting in the library. This is the soundness
theorem:

> **Soundness.** If $\operatorname{novelty}(C, x) > 0$, then $x \notin C$.

The proof is a single clean observation. Suppose, to the contrary, that $x$ were
already in the catalog. Then $x$ is one of the points we minimize over, and the
distance from $x$ to itself is zero. So the minimum distance — the novelty —
would be at most zero, contradicting the assumption that it is strictly positive.
A positive novelty score is therefore an airtight proof of genuine absence from
the catalog.

## Separation: a margin against everything

Soundness says "$x$ is not a duplicate." But we usually want something stronger:
that $x$ is *comfortably* far from everything known, with a quantitative buffer.
That is the separation guarantee:

> **Separation.** If $\varepsilon \le \operatorname{novelty}(C, x)$, then
> $\varepsilon \le \operatorname{dist}(x, c)$ for *every* catalog entry $c$.

This follows immediately from the definition: the novelty is, by construction, the
*smallest* of all the distances from $x$ to catalog points. If even the smallest
of them is at least $\varepsilon$, then all of them are. A single inequality about
the minimum unpacks into a separation guarantee against the entire library at
once. This is what lets a one-line certificate stand in for a check against
millions of stored theorems.

## Stability: why a fuzzy ruler still works

Here is the subtle part, and the heart of the whole construction. In the real
world the embedding is computed numerically. There is always error. The point we
*think* is $x$ might really be a slightly different point $y$. If a tiny wobble in
the embedding could send the novelty score crashing from "certified new" to
"duplicate," the certificate would be worthless.

The rescue is a property called being **1-Lipschitz**. It says that novelty
cannot change faster than the points themselves move:
$$\bigl|\operatorname{novelty}(C, x) - \operatorname{novelty}(C, y)\bigr|
   \;\le\; \operatorname{dist}(x, y).$$

In words: if your embedding is off by at most $\delta$, then your novelty score is
off by at most $\delta$ — never more. Errors do not amplify. They pass through the
novelty function without being magnified.

The proof is a beautiful little dance with the triangle inequality. Let $c$ be the
catalog point closest to $y$, so that $\operatorname{dist}(y, c)$ equals $y$'s
novelty. Then
$$\operatorname{novelty}(C, x) \le \operatorname{dist}(x, c)
   \le \operatorname{dist}(x, y) + \operatorname{dist}(y, c)
   = \operatorname{dist}(x, y) + \operatorname{novelty}(C, y).$$
The first step uses that novelty is a *minimum* (so it is at most the distance to
this particular $c$); the second is the triangle inequality. Rearranging gives
$\operatorname{novelty}(C,x) - \operatorname{novelty}(C,y) \le
\operatorname{dist}(x,y)$. Running the same argument with $x$ and $y$ swapped
gives the other direction, and together they bound the absolute difference.

The consequence is exactly the robustness we wanted: **if a certificate has margin
$\varepsilon$ and the embedding error is smaller than $\varepsilon$, the
certificate survives.** Numerical distance becomes a genuine guarantee, not a
guess.

A small but principled design choice supports all of this. We allow $X$ to be a
*pseudo*metric space, meaning two distinct theorems are permitted to sit at
distance zero if their embeddings coincide. For a system whose job is to be
*conservative* about claiming novelty, this is the safe convention: if two results
look identical to the embedding, the certifier reports novelty zero and refuses to
call either one new. It would rather miss a real discovery than announce a false
one.

## Monotonicity: knowledge only raises the bar

The system is meant to keep learning. Every time it proves something, that result
joins the catalog. What does growing the library do to novelty?

> **Monotonicity.** If $C \subseteq D$, then
> $\operatorname{novelty}(D, x) \le \operatorname{novelty}(C, x)$.

Enlarging the catalog can only *lower* novelty, never raise it. This is exactly as
it should be: the more you know, the harder it is for something to be new. Adding
points to the cloud can only bring some point closer to $x$; it can never push the
nearest neighbour away. Novelty is a moving target that drifts only downward as
knowledge accumulates — a built-in safeguard against grade inflation.

There is even a tidy bookkeeping rule for adding one theorem at a time. When a
single new result $a$ joins the catalog, the novelty of every candidate updates by
a single comparison:
$$\operatorname{novelty}(C \cup \{a\}, x)
   = \min\bigl(\operatorname{dist}(x, a),\, \operatorname{novelty}(C, x)\bigr).$$
You never have to recompute distances to the whole library; you just check the
candidate against the newcomer and take the smaller of the two. The certifier runs
incrementally, in real time, as the catalog grows.

## The budget: how much novelty can a bounded world hold?

A natural worry now appears. If knowledge keeps growing and novelty keeps
shrinking, does the engine eventually run dry? In a *bounded* world, yes — and the
mathematics says precisely how dry.

Picture all theorems living inside a box of side $R$, and suppose we insist that
every pair of catalog entries be at least $\varepsilon$ apart (an
$\varepsilon$-separated catalog, the densest packing of genuinely distinct
results). Then the number of theorems you can fit is finite and capped: chop the
box into a grid of small cells of side roughly $\varepsilon$, and note that no two
$\varepsilon$-separated points can share a cell. The count of cells — on the order
of $(R/\varepsilon)^d$ in $d$ dimensions — is therefore a hard ceiling on the size
of any $\varepsilon$-novel catalog. This is the **novelty budget**: in a bounded
embedding space, only finitely many mutually-novel theorems can ever coexist.
Novelty, in a confined world, is a genuinely scarce resource.

## The twist: an infinite spring of new theorems

So is the well destined to run dry? Only if the world is bounded. The final act of
this story is the discovery that the *right* mathematical universe is not bounded
at all — and that a single, centuries-old fact about Fibonacci numbers pumps out
provably-novel theorems forever.

Recall the Fibonacci sequence $F_1 = 1, F_2 = 1, F_3 = 2, F_4 = 3, F_5 = 5,
F_6 = 8, \dots$, each term the sum of the previous two. A deep classical result —
the prime-index case of **Carmichael's primitive divisor theorem** — says:

> For every prime $p \ge 3$, the Fibonacci number $F_p$ has a **primitive prime
> divisor**: a prime $q$ that divides $F_p$ but divides *none* of the earlier
> Fibonacci numbers $F_1, \dots, F_{p-1}$.

For example $F_5 = 5$ has the primitive prime $5$; $F_7 = 13$ has the primitive
prime $13$; $F_{11} = 89$ has the primitive prime $89$. The word *primitive* is
the key. Because each such prime $q$ appears for the first time at index $p$ and
never before, the primes attached to different prime indices must all be
**distinct** — no prime can be the first-appearing divisor at two different
indices.

Now build the novelty stream. Embed each prime index $p \ge 3$ as a point on the
real line by sending it to its primitive prime, $\operatorname{carEmbed}(p) =
q_p$. Since the $q_p$ are distinct *integers*, any two of them differ by at least
$1$. So this catalog of points is automatically **$1$-separated**: every pair sits
at distance at least $1$. By the separation guarantee, *every* one of these
infinitely many points carries a novelty certificate at level $1$ against all the
others.

The contrast with the budget result is the punchline. In a bounded box, novelty is
finite and rationed. But the prime line is not bounded — the primitive primes
march off to infinity — and so the same machinery that *limited* novelty in a
confined space now *guarantees an endless supply* of it. One classical theorem
about Fibonacci numbers, run through the novelty certifier, becomes a perpetual
generator of theorems each of which is certifiably unlike all the rest.

## Why this matters beyond the machine

The deepest ideas here are not really about theorem provers. They are about what it
means to certify, rather than merely assert, that something is new — a question
that reaches into patent examination, plagiarism detection, drug discovery, and
the management of any growing body of knowledge.

The recipe is general and reusable. Represent your objects as points. Measure
novelty as distance to the nearest known thing. Prove three guarantees — *no false
positives* (soundness), *a margin against everything* (separation), and
*robustness to measurement error* (the 1-Lipschitz bound) — and you have turned a
vague human feeling into a checkable mathematical object. Add monotonicity and an
incremental update rule, and the certifier runs live as your knowledge base grows.

And then the geometry repays you. It tells you when novelty is a scarce resource to
be budgeted, and it reveals, in the unbounded landscape of the primes, structures
that will never stop surprising you. The same triangle inequality that promises a
fuzzy ruler still works is the one that, applied to Fibonacci's primitive divisors,
promises an inexhaustible frontier. That is the quiet beauty of certified novelty:
it does not merely watch a machine invent — it proves, line by line, that the
inventing is real.
