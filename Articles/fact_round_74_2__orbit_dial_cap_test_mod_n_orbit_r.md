# The Sieve That Knows Nothing

### Why a filter can be twice as fast as brute force and still tell you absolutely nothing

Suppose someone hands you a large odd number $N$ and asks you to find a factor. The dumbest honest method is to try every candidate divisor below $\sqrt{N}$, one at a time. It works. It is slow. And it is the baseline against which every clever idea gets measured.

Now suppose a friend offers you a hint. "Don't bother with the even candidates," she says. "A divisor of an odd number is odd." You immediately halve your work. You are twice as fast.

Here is the question this article is about: **how much did that hint tell you about $N$?**

The answer, when you measure it properly, is *nothing*. Zero bits. Not "almost nothing" — exactly nothing. Your friend did not look at $N$. She would have said the same sentence about every odd number in the universe. And yet you are twice as fast.

That tension — a filter that doubles your speed while carrying zero information — turns out to be the key to a precise and rather beautiful law about how much any filter can ever be worth. This article is about that law, about where it comes from, about the exact loophole through which the parity hint escapes it, and about a family of triangle-generating matrices that made the whole thing visible.

---

## Dials, and what they cost

Let's build a tiny economic model. Normalise: sweeping all candidates costs exactly $1$.

A **dial** is any rule that looks at the candidate list and throws some of it away. Two numbers describe a dial:

- its **retention** $\theta \in (0,1]$ — the fraction of candidates it keeps;
- its **soundness** $s \in [0,1]$ — the probability that the true factor is among the kept ones.

Run the dial. You sweep the retained fraction, at cost $\theta$. With probability $s$ the answer was in there and you are done. With probability $1-s$ the dial *threw the answer away*, and you must now go back and sweep the rest too, for a total cost of $1$. So the expected cost is

$$\mathrm{cost}(s,\theta) \;=\; s\theta + (1-s)\cdot 1 \;=\; 1 - s + s\theta,$$

and the **speedup** over brute force is the reciprocal,

$$\mathrm{speedup}(s,\theta) \;=\; \frac{1}{1-s+s\theta}.$$

That is the entire model. Everything below is a consequence of this one formula.

Notice the shape of it. A dial has an upside ($\theta$ small: you sweep less) and a downside ($s$ small: you sometimes pay twice). The interesting question is what happens when those two are yoked together.

---

## The $4/3$ barrier

Call a dial **exchangeable** if it is no more likely to keep the true factor than to keep any other candidate — formally, if $s = \theta$. This is the honest description of a filter with no special insight: it keeps a $\theta$-fraction of everything, including, with probability $\theta$, the answer.

Substituting $s = \theta$:

$$\mathrm{cost}(\theta,\theta) = 1-\theta+\theta^2 = \frac34 + \Bigl(\theta-\tfrac12\Bigr)^2 \;\ge\; \frac34.$$

There is the whole proof, in one completed square. An exchangeable dial can never cost less than three quarters of brute force, so:

> **The Cap Law.** Every exchangeable dial has speedup at most $4/3$, whatever fraction it retains. Equality holds if and only if it retains exactly half.

$4/3 \approx 1.333$. That is the entire achievable value of *any* filter that treats the answer like everything else. Retain $10\%$ of candidates and you get $1.10$; retain $90\%$ and you get $1.10$ again; the sweet spot in the middle gives $1.333$ and not a hair more. The function is a parabola in disguise, and its minimum cost sits at $\theta = 1/2$.

This is worth pausing on, because it is counterintuitive: aggressive filtering does not help an exchangeable dial. Throwing away $99\%$ of the candidates buys almost nothing, since $99\%$ of the time you threw away the answer too and must sweep everything anyway. The cap is not a statement about weak filters; it is a statement about *all* of them.

---

## What it takes to break the cap

Since we have an exact formula, we can say exactly when the cap breaks. A little algebra on $\frac{1}{1-s+s\theta} > \frac43$ gives a clean threshold:

> **Sharp criterion.** A dial beats the $4/3$ cap **if and only if** $s(1-\theta) > \tfrac14$.

And now the cap law is a one-liner about arithmetic means: exchangeability means $s = \theta$, so the criterion asks for $\theta(1-\theta) > 1/4$ — which is false for every real $\theta$, by the same completed square. A product of two numbers summing to $1$ never exceeds a quarter. The barrier is AM–GM in a lab coat.

We can do better than "it never fires" and quantify the *escape cost*. If a dial does beat the cap, then its soundness must exceed its retention by a definite margin:

$$s - \theta \;>\; \frac{(1-2\theta)^2}{4(1-\theta)}.$$

At extreme retentions this margin is punishing: a dial that keeps only $10\%$ of candidates must be at least $0.178$ more sound than exchangeable — it needs a genuine, substantial bias toward the factor. At $\theta = 1/2$ the margin collapses to zero, which is why half-retention is the *extremal test point*: it is the one place where the tiniest bias already helps. Any experiment designed to detect a cap violation should run there, and that is exactly where the numbers below were taken.

The immediate corollary is a dichotomy that will organise the rest of this article:

> Any dial that beats $4/3$ satisfies $s > \theta$: it is **strictly more likely to keep the true factor than a random candidate**.

So something must be biasing it toward the answer. There are exactly two ways to arrange that. Either the dial *looked at $N$* and learned something — or it didn't, and the bias was baked into the problem before the dial arrived.

---

## Triangles that never change their minds

The setting where this came into focus is a classical object: the tree of Pythagorean triples.

Every primitive Pythagorean triple — $(3,4,5)$, $(5,12,13)$, $(8,15,17)$, and so on — sits in a single infinite ternary tree rooted at $(3,4,5)$. You move down the tree by applying one of three fixed integer matrices to a triple $(a,b,c)$:

$$B_1 = \begin{pmatrix} 1 & -2 & 2\\ 2 & -1 & 2\\ 2 & -2 & 3\end{pmatrix},\quad B_2 = \begin{pmatrix} 1 & 2 & 2\\ 2 & 1 & 2\\ 2 & 2 & 3\end{pmatrix},\quad B_3 = \begin{pmatrix} -1 & 2 & 2\\ -2 & 1 & 2\\ -2 & 2 & 3\end{pmatrix}.$$

Each matrix maps triples to triples: if $a^2+b^2=c^2$, the same holds for the image, which one verifies by expanding. Every primitive triple appears exactly once. It is one of the tidiest facts in elementary number theory.

The idea under test was: walk this tree, reduce the coordinates you find modulo some small number $m$, and use the resulting *revealed residue set* as a factoring dial — the classes that show up are allowed, the ones that don't are forbidden. If the revealed set depended on the target $N$ in some subtle way, that would be a source of per-$N$ information, and the cap might genuinely be in danger.

It does not depend on $N$. It cannot. Here is why:

> **Orbit invariant.** Every triple in the tree rooted at $(3,4,5)$ has $a$ odd, $b$ divisible by $4$, and $c \equiv 1 \pmod 4$.

The proof is an induction with three cases, one per matrix, and each case is pure modular bookkeeping. The root $(3,4,5)$ satisfies it. If $(a,b,c)$ does, then in $B_2(a,b,c) = (a+2b+2c,\ 2a+b+2c,\ 2a+2b+3c)$ the first coordinate is odd $+$ even $+$ even, hence odd; the second is even, and tracing the $4$s shows it is divisible by $4$; and the third is $\equiv 3c \equiv 3 \cdot 1 \cdot$ … it works out to $1 \bmod 4$. The other two matrices are the same computation with signs flipped.

The consequence is stark. Project the whole infinite tree to residues mod $4$ and you get

$$\{(1,0,1),\ (3,0,1)\}.$$

Two points. Not "two points for this $N$" — two points, full stop, for all time, for every target, at every search depth. The dial you build from the orbit is one **universal exclusion table**. It is the same table whether you are factoring a 40-bit number or a 4000-bit one. There is nothing in it to learn.

(A cousin of the same argument, worth stating because it is charming: in *any* Pythagorean triple, one of the two legs is divisible by $3$. Proof: check all $27$ possibilities for $(a,b,c)$ modulo $3$ and observe that $a^2+b^2=c^2$ forces $ab \equiv 0$. Squares mod $3$ are $0$ and $1$, and $1+1=2$ is not a square, so at least one leg is $\equiv 0$.)

---

## Zero bits, twice the speed

Now let us measure the information properly, because this is where the paradox bites.

For a target $X$ (say, the residue class of $N$) and a dial output $Y$, the mutual information is

$$I(X;Y) = \sum_{x,y} p(x,y)\,\log\frac{p(x,y)}{p(x)p(y)}.$$

Two computations, both short:

**A constant dial has $I(X;Y) = 0$ exactly.** If the dial emits the same symbol $y_0$ whatever the target, then $p(x,y_0) = p(x)$ and $p(y_0)=1$, so every term in the sum is $p(x) \log 1 = 0$. And $0$ is the floor, not merely a small value: mutual information is always nonnegative, by the Gibbs inequality $\log r \ge 1 - 1/r$ applied cell by cell. So the orbit dial sits *exactly* on the information floor. It is as uninformative as a thing can be.

**An ordinary residue dial has $1$ bit.** Take a perfectly correlated pair on two equiprobable classes — the model of a genuine congruence hint, like the observation that if $N \equiv 3 \pmod 4$ and $N = pq$ with $p,q$ odd, then exactly one of $p,q$ is $\equiv 1$ and the other $\equiv 3 \pmod 4$. Its mutual information is $\log 2$, i.e. one bit on the nose. This is real per-$N$ content: the dial's output changes when $N$ changes.

And yet: the constant dial reads $\mathrm{speedup} = 2$, and the one-bit dial, being exchangeable, is capped at $4/3$.

**The zero-information dial is faster than the one-bit dial.** That is the paradox in its sharpest form, and resolving it is the point of the whole story.

---

## The resolution: it's the prior, not the information

Here is the loophole, and it is not in the mathematics — it is in what we were implicitly assuming about the world.

Take a *fixed* dial: a set $K$ of retained candidates, decided in advance, inside a candidate pool $C$. Its retention is the density $|K \cap C|/|C|$. Now ask for its soundness — but soundness against *what*? Soundness is a probability, and probabilities need a prior over where the true factor lives.

- **Against a uniform prior** — the factor equally likely to be any candidate — the soundness of a fixed dial is a sum of $|K \cap C|$ equal terms $1/|C|$, which is precisely the retention. Soundness equals retention. The dial is automatically exchangeable, and the $4/3$ cap applies. *A zero-information dial cannot beat the cap on its own.*

- **Against a supported prior** — one that already puts zero mass outside $K$ — the soundness is exactly $1$, no matter how small the retention. And no information about $N$ was consulted to arrange this.

The parity skip is the second case, and now you can see it plainly. The divisors of an odd number are odd. That is not a fact the dial learned about $N$; it is a fact about the *shape of the problem*, true before anyone chose an $N$. The prior over factors was already concentrated inside the kept set. The dial did not have to aim; the target had already moved to meet it.

So the dichotomy is complete:

> **A dial with $s > \theta$ is biased toward the factor, and that bias comes from exactly one of two sources: per-$N$ information (a dial that varies with $N$), or a prior already concentrated on the kept set (a structural congruence). The cap governs any dial with no such bias. Both kinds of bias can lift a dial above it — but the second kind costs nothing and reveals nothing.**

The right way to state the $4/3$ barrier, then, is not "no filter beats $4/3$." It is: **a filter with no bias toward the answer cannot beat $4/3$** — and a blind structural exclusion supplies that bias for free, while knowing nothing at all. So a reading above $4/3$ is evidence of bias, never by itself evidence of insight.

That has a practical consequence for anyone measuring a filter. Before crediting a speedup to instance knowledge, you must discount the blind structure the filter silently contains — measure it against a candidate pool from which the structural exclusion has *already* been removed. A filter that looks impressive on the raw pool because it quietly re-derives "divisors of odd numbers are odd" collapses, on the discounted pool, right back onto the cap.

---

## How far can blindness take you?

The parity skip is the smallest member of an infinite family. Fix a squarefree modulus $M$ coprime to $N$ — a condition you can check blind, with a single gcd — and keep only the candidates coprime to $M$. Sieve theorists call this a **wheel**.

A wheel is sound (every divisor of $N$ is coprime to $M$, since $N$ is), and it retains exactly $\varphi(M)/M$ of all residues, so its speedup is

$$\frac{M}{\varphi(M)} \;=\; \prod_{p \mid M} \frac{p}{p-1}.$$

Parity ($M=2$) gives $2$. The $\{2,3\}$ wheel gives $3$. The $\{2,3,5\}$ wheel gives $15/4 = 3.75$. All of them beat $4/3$, and all of them carry zero bits.

How high does this go? Since $\frac{p}{p-1} \ge 1 + \frac1p$, the Weierstrass bound $\prod(1+x_i) \ge 1 + \sum x_i$ gives

$$\frac{M}{\varphi(M)} \;\ge\; 1 + \sum_{p \mid M} \frac1p,$$

and the sum of reciprocals of primes **diverges** — Euler's theorem, the sharpening of Euclid. Therefore:

> **Structural dials are unbounded.** For every bound $B$ there is a squarefree wheel with information-free speedup exceeding $B$.

This settles the matter completely. The $4/3$ cap is *not* a bound on speedups. There are zero-information filters worth $10\times$, $100\times$, any constant you like. What the cap bounds is a different quantity: the value of *knowing something about $N$* by way of a filter that keeps the answer only as often as it keeps anything else.

There is a pleasing way to see the two regimes as different objects rather than two ends of one scale. Stacking independent structural dials *multiplies* their speedups — $1/(\theta_1\theta_2) = (1/\theta_1)(1/\theta_2)$ — so in logarithmic coordinates their weights *add*. That is precisely the arithmetic of the tropical semiring, where multiplication becomes addition and addition becomes minimum. In these tropical coordinates:

- structural dials have weights $\log(M/\varphi(M))$ that form an **unbounded** additive family, with the parity skip sitting at weight $\log 2 \approx 0.693$;
- exchangeable dials are confined to the **bounded window** $[0, \log(4/3)] \approx [0, 0.288]$, and stacking them never leaves it — the composition of exchangeable dials is exchangeable, hence still capped.

Two regimes; one bounded, one not; and a clean additive bookkeeping in between.

---

## What the experiment actually saw

All of this was tested at half-retention, on a population of 800 semiprimes, with the six moduli $3,4,5,7,8,16$, against stratified permutation nulls.

The matched-random arm — a dial keeping a random half of the candidates — read a speedup of $1.3387$, with confidence interval $[1.3008,\ 1.382]$. The prediction is $4/3 = 1.3333$. **The cap law holds to about four parts in a thousand.** A co-inflation control designed to detect spurious enhancement came back clean.

The orbit arm read $2.0000$ with a confidence interval of zero width and a failure rate of exactly $0.000$. Twice as fast, never wrong. And when it was compared, target by target, against a fixed universal dial computable with no knowledge of $N$ whatsoever, the paired difference was **$0.0$ exactly** — not small, not within noise, but identically zero on every single case.

That is the signature of a constant shave: the orbit dial is not a discovery about the tree's interaction with $N$, it is the parity skip wearing a costume. The information side matched — across $48$ measurement cells the largest standardised deviation was $+2.29$ and no feature carried more than $0.09$ bits, against ordinary residue-dial baselines of $1$ to $3$ bits.

And when each arm was charged for its own overhead, *every arm dropped below $1$*: the filters cost more to run than they saved. That is the practical epilogue, and the reason no one factors large numbers this way — the constants are real, but so is the bookkeeping, and at the sizes that matter the bookkeeping wins.

---

## The moral

The result that survives is a scope note, and scope notes are underrated.

Before: "no filter can beat a $4/3$ speedup." That statement is false, and easily so — the parity skip refutes it in one line.

After: "no filter that treats the answer like any other candidate can beat a $4/3$ speedup; to beat it a filter must be *biased toward the answer*, and that bias comes either from information about this instance or from the structure of the problem — where the structural kind is blind, free, unbounded, and worth exactly its constant factor." That statement is true, sharp, and it comes with an exact threshold ($s(1-\theta) > 1/4$), an exact escape cost ($s - \theta > (1-2\theta)^2/4(1-\theta)$), and an exact extremal point ($\theta = 1/2$).

The distinction matters far beyond factoring. Every time a heuristic speeds up a search, it is fair to ask which kind it is: did it *learn* something about this instance, or did it merely *exploit* something true of all instances? The two feel identical from the inside — both look like the answer arriving sooner — but they behave completely differently under composition, under scaling, and under adversarial pressure. Structural exclusions are cheap, universal, and bounded in reach only by whatever the problem's symmetries happen to permit. Information is expensive and instance-specific, and a filter that carries none of it is pinned to $4/3$.

And there is a concrete test, which costs nothing to run: recompute the filter's kept set with the instance withheld. If the table does not move, the speedup was structure, not knowledge — and should be measured against a baseline that already includes the structure everyone else has too. In the case that started this story, the table did not move by so much as a single residue class.

A filter that knows nothing can still be fast. It just isn't fast *because* it knows something.
