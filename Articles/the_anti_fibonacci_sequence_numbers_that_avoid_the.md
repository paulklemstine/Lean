# The Anti-Fibonacci Sequence: Numbers That Refuse to Add Up

## A famous recipe, run in reverse

Almost everyone has met the Fibonacci sequence. Start with $1, 1$ and let each new number be the sum of the two before it:

$$1,\ 1,\ 2,\ 3,\ 5,\ 8,\ 13,\ 21,\ 34,\ \dots$$

Fibonacci's numbers are addicted to addition. Every term is *built* from its two predecessors, and this relentless gluing has a beautiful side effect: the ratio of consecutive terms creeps ever closer to a single magic constant, the **golden ratio**

$$\varphi = \frac{1+\sqrt5}{2} \approx 1.618\dots$$

The golden ratio shows up in sunflowers, pinecones, art, and architecture precisely because Fibonacci's rule funnels everything toward it.

But what if we flipped the rule on its head? Instead of *seeking* the sum of two recent terms, what if a sequence went out of its way to *avoid* it? Start at $1$, and at every step take the **smallest positive integer you have not already used that is not the sum of two consecutive earlier terms.** Call this the **greedy anti-Fibonacci sequence**. It is a contrarian: where Fibonacci embraces addition, this sequence dodges it at every turn.

The natural guess is that such a rebellious rule produces something wild and unpredictable. The surprise — and the point of this article — is that it produces something astonishingly clean.

## Running the rule by hand

Let's build it. We start with $1$.

- The two most recent terms so far sum to nothing forbidden yet, so the next candidate after $1$ is $2$. Is $2$ a sum of two consecutive earlier terms? The only earlier "consecutive pair" available is just $1$ itself so far; nothing forces us to skip $2$. Take it. Now we have $1, 2$.
- Their sum is $1 + 2 = 3$. So $3$ is **forbidden**. The next smallest unused, non-forbidden integer is $4$. Take it: $1, 2, 4$.
- The newest consecutive sum is $2 + 4 = 6$. So $6$ joins the forbidden list. The smallest available integer is $5$ — not forbidden — so take it: $1, 2, 4, 5$.
- Now $4 + 5 = 9$ is forbidden. Next available is $7$: $1, 2, 4, 5, 7$.
- $5 + 7 = 12$ is forbidden. Next is $8$: $1, 2, 4, 5, 7, 8$.

Continuing, we get

$$1,\ 2,\ 4,\ 5,\ 7,\ 8,\ 10,\ 11,\ 13,\ 14,\ 16,\ 17,\ \dots$$

Stare at that list for a moment. Something jumps out: **these are exactly the positive whole numbers that are not multiples of $3$.** And the forbidden values — the sums the sequence keeps stepping around — are exactly the multiples of $3$:

$$3,\ 6,\ 9,\ 12,\ 15,\ 18,\ \dots$$

The rebellious, self-avoiding rule collapses into the humblest pattern in arithmetic: *skip every third number.*

## The closed form

This is not a coincidence of the first dozen terms; it holds forever. If we index the sequence starting from $k = 0$, there is an exact formula:

$$A(k) = \left\lfloor \frac{3k+2}{2} \right\rfloor,$$

where $\lfloor \cdot \rfloor$ means "round down." Plugging in $k = 0, 1, 2, 3, \dots$ gives $1, 2, 4, 5, 7, 8, \dots$ on the nose.

Everything about the sequence follows from one elegant identity relating two consecutive terms:

$$A(k) + A(k+1) = 3(k+1).$$

Read that carefully — it is the heart of the whole story. **The sum of two consecutive anti-Fibonacci numbers is always a multiple of $3$.** For example, $A(2) + A(3) = 4 + 5 = 9 = 3\cdot 3$, and $A(4)+A(5) = 7 + 8 = 15 = 3 \cdot 5$. Since these sums are precisely the values the sequence forbids itself from landing on, and since no term of the sequence is ever a multiple of $3$, the sequence can *never* collide with one of its own consecutive sums. The avoidance is automatic and permanent.

## Three theorems that pin it down

To be sure the tidy formula really *is* the greedy rule — and not just a lookalike that agrees for a while — three facts must line up.

**1. Characterization.** A positive integer $m$ appears somewhere in the sequence if and only if $m$ is not divisible by $3$. Nothing is missing, nothing is extra.

**2. Avoidance (the "anti" property).** No term $A(k)$ ever equals a consecutive sum $A(i) + A(i+1)$. This is immediate from the two facts above: consecutive sums are multiples of $3$, and terms never are, so the two sets are disjoint.

**3. Greedy minimality.** Every integer strictly between two consecutive terms $A(n)$ and $A(n+1)$ is a multiple of $3$ — that is, it was skipped *because* it was forbidden, not by accident. This is what makes each term genuinely the *smallest* legal choice, which is the definition of "greedy."

Together these three say something strong: the closed form is not a redefinition or a lucky guess. It is a *theorem* about the greedy construction. The self-avoiding rule and the "skip every third number" rule are one and the same.

## Correcting the folklore

There is a popular but mistaken belief about this sequence. A quick, careless reading of the "avoid the sum of the two previous terms" rule leads people to the list

$$1,\ 1,\ 2,\ 4,\ 7,\ 11,\ 16,\ 22,\ \dots$$

and to the conjecture that anti-Fibonacci numbers grow like $n^2/4$, quadratically, with the ratio of consecutive terms bouncing forever between $1$ and $2$ and never settling down. It is a romantic picture: a sequence that grows explosively while dodging the golden ratio by refusing to converge at all.

It is also wrong — at least for the honest greedy rule. Those quadratic numbers are the **lazy-caterer numbers** $1 + \binom{n}{2}$ (the maximum number of pieces you can cut a pancake into with $n$ straight cuts), a lovely sequence in its own right, but a *different* object. Crucially, the lazy-caterer numbers are not sum-avoiding: they contain genuine coincidences where one term really is the sum of two earlier ones. They do not satisfy the defining "anti" property.

The true greedy anti-Fibonacci sequence behaves quite differently:

- **It grows linearly, not quadratically.** Since the sequence is "every third number removed," about two out of every three integers survive. Concretely, $A(n) \approx \tfrac{3}{2}\,n$, and the ratio $A(n)/n$ converges exactly to $3/2$. There is no $n^2/4$.

- **Its consecutive ratio converges — to $1$.** Because $A(n+1) - A(n)$ is only ever $1$ or $2$ while the terms themselves march off to infinity, the ratio $A(n+1)/A(n)$ is squeezed toward $1$. It does *not* oscillate forever between $1$ and $2$.

- **The forbidden set is dense, not sparse.** The avoided values are exactly the positive multiples of $3$, which make up a full one-third of all integers — density $1/3$, not density $0$.

So the sequence *does* dramatically avoid the golden ratio, just not in the way the folklore imagined. Where Fibonacci's ratio homes in on $\varphi \approx 1.618$, the anti-Fibonacci ratio homes in on the most boring number imaginable: $1$.

## Why avoiding addition leads to arithmetic

There is a satisfying moral here. Fibonacci's rule is *multiplicative in disguise*: repeatedly adding the previous two terms behaves, in the long run, like repeatedly multiplying by a fixed factor, and that factor is $\varphi$. Exponential growth is what produces a nontrivial, irrational ratio limit.

The greedy anti-Fibonacci rule refuses to feed each term back into the next in that compounding way. By systematically stepping *around* sums rather than *onto* them, it never builds exponential momentum. What is left is the gentlest possible growth — a straight line — and straight-line growth always forces the consecutive ratio to $1$. In other words:

> **To reach the golden ratio, a sequence must grow geometrically. A sequence that merely avoids addition can only grow linearly, and linear growth can only ever converge to a ratio of $1$.**

The golden ratio is not something you stumble into. You have to earn it through exponential growth. Take that engine away — as the anti-Fibonacci rule does — and the magic constant vanishes, replaced by plain arithmetic.

## The bigger picture

This small sequence is a doorway to richer questions. What if, instead of forbidding sums of *two* consecutive terms, we forbid sums of any $k$ consecutive terms? The $k=2$ case gives the non-multiples of $3$; the general pattern appears to always be a finite patchwork of arithmetic progressions with a rational density, governed by a simple bounded-memory "look at the last few terms" mechanism. And one can ask, across *all* additively defined greedy sequences, exactly which real numbers can appear as consecutive-ratio limits — with the conjecture that polynomial growth always forces the answer to be exactly $1$, and only genuinely exponential rules can produce exotic limits like $\varphi$.

The anti-Fibonacci sequence began as a joke — Fibonacci's mischievous twin, defined to do the opposite. But run the joke honestly and it delivers a genuine punchline: the sequence that tries hardest to avoid addition ends up being the simplest arithmetic progression of all, and in doing so reveals *why* the golden ratio is special. It is not the numbers that avoid addition that are strange. It is the ones, like Fibonacci's, that embrace it.
