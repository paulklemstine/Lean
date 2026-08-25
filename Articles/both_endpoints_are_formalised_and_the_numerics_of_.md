# The Collision You Cannot Avoid

## How much randomness does it take to make a hash table behave?

Somewhere inside almost every piece of software you use today, a *hash function* is at work. It takes a key — a word, a URL, a customer ID, a chunk of a video file — and squeezes it down to a small number, a *bucket*, between $1$ and $m$. The whole point is speed: instead of scanning a list of a million entries, you compute one number and look in one place.

The whole *risk* is collisions. Two different keys, one bucket. Collisions are not fatal — you keep a little list in the bucket and search it — but they are the enemy of the guarantee. An adversary who can force many keys into the same bucket turns your constant-time lookup into a linear scan, and your web service into a smoking crater. This is not hypothetical: real denial-of-service attacks have worked exactly this way.

The classical fix, due to Carter and Wegman in the late 1970s, is to stop using *a* hash function and start using a *random* one. You keep a whole family $\{h_\omega\}$ of hash functions and pick one at random at run time. The adversary can choose the keys, but cannot know which function you drew. What you demand of the family is a single, beautifully simple property, called **2-universality**: for any two distinct keys $x \neq y$,
$$\Pr_\omega[\,h_\omega(x) = h_\omega(y)\,] \le \frac{1}{m}.$$
Any *particular* pair is no more likely to collide than if you had thrown both keys into buckets completely at random.

From that one inequality, everything else follows by a single line of reasoning called the **union bound**: the chance that *something* goes wrong is at most the sum of the chances that each individual thing goes wrong. With $n$ keys there are $\binom{n}{2}$ pairs, so
$$\Pr[\text{some pair of the } n \text{ keys collides}] \le \frac{\binom{n}{2}}{m}.$$
This inequality is the workhorse of a thousand papers. It tells you that with $m$ well above $n^2$, you can expect a *perfect* hash — no collisions at all, with high probability.

And that is where the story usually stops. But it leaves a question hanging, and the question turns out to have a surprising answer.

## The question nobody asks

The union bound is an *upper* bound. It says collisions are rare. Nobody ever asks the converse: **how rare can they possibly be?**

Put it as a game. You are allowed to design *any* family of hash functions you like, of any size, with any probability weights, as long as it satisfies the Carter–Wegman axiom exactly — for every pair of distinct keys, the collision probability is precisely $1/m$, not more, not less. (Exactness is the natural normalisation; every *strongly* 2-universal family, where the pair of hash values $(h(x), h(y))$ is uniform on all $m^2$ possibilities, satisfies it automatically, and those are the families everyone actually builds.) Your goal is to make collisions among $n$ fixed keys as unlikely as you can. The union bound gives you permission to hope for something around $n^2/m$, which for small $n$ and large $m$ is very small indeed.

How low can you go?

**The answer is $1/m$, and not one bit lower — no matter how many keys there are.**

That is the content of the theorem at the heart of this article.

> **Converse to the Union Bound.** Let $\{h_\omega\}$ be any family of hash functions into $m$ buckets, with any probability law on the index $\omega$, such that every pair of distinct keys from a set $S$ of $n \ge 2$ keys collides with probability exactly $1/m$. Then
> $$\Pr[\,h_\omega \text{ is not injective on } S\,] \ \ge\ \frac{1}{m}.$$

Combined with the union bound, this pins the collision probability into a sandwich:
$$\frac{1}{m} \ \le\ \Pr[\text{collision}] \ \le\ \frac{\binom{n}{2}}{m}.$$

The lower end of that sandwich is a floor made of concrete. You can add more buckets, you can be as clever as you like about the design of your family, you can use $2^{256}$ buckets and three keys — you will still collide with probability at least $1/m$. There is a *fixed tax* on exact 2-universality, and it is paid in full regardless of how easy the problem looks.

## Why the floor is there

The proof is a wonderful piece of elementary reasoning that runs against the grain of the usual argument. Instead of bounding a union of bad events from above by summing, it bounds it from below by *counting*.

Introduce a counter. For each draw $\omega$, let $X(\omega)$ be the number of *ordered* pairs of distinct keys $(x, y)$ from $S$ with $h_\omega(x) = h_\omega(y)$. Two things are immediate:

1. **Its average is forced.** By linearity of expectation and exact 2-universality, each of the $n(n-1)$ ordered pairs contributes exactly $1/m$, so
 $$\mathbb{E}[X] = \frac{n(n-1)}{m}.$$
2. **Its maximum is bounded.** There are only $n(n-1)$ ordered pairs in total, so $X \le n(n-1)$ always.

Now apply the *reverse* Markov inequality — the humble observation that a nonnegative quantity capped at $C$ satisfies $\mathbb{E}[X] \le C \cdot \Pr[X > 0]$, because on the event $X > 0$ the variable contributes at most $C$ and elsewhere nothing. Rearranged:
$$\Pr[X > 0] \ \ge\ \frac{\mathbb{E}[X]}{\max X} \ =\ \frac{n(n-1)/m}{n(n-1)} \ =\ \frac{1}{m}.$$
And $X > 0$ is precisely the event that a collision occurs. Done.

Look at what happened. The $n(n-1)$, which the union bound *multiplies by* to produce a bound that degrades as you add keys, appears here in both numerator and denominator and cancels perfectly. Adding keys raises the expected number of collisions and raises the ceiling on the counter by exactly the same factor. The result is a bound **completely insensitive to the number of keys.**

That cancellation is the whole idea, and it is why the union bound could never have seen this coming. The union bound is loose exactly when the bad events overlap heavily. Here the reverse Markov bound is tight exactly when the counter $X$ is as *concentrated* as possible — when it takes only the two values $0$ and $n(n-1)$, all or nothing. So the extremal family, the one that actually achieves $1/m$, should be a family that either collides catastrophically or not at all.

Such a family exists, and you have met it.

## The extremal family is the textbook one

Take the number of buckets to be a prime $p$, identify keys and buckets with the integers mod $p$, and consider the classical affine family
$$h_{a,b}(x) = a x + b \pmod p,$$
with $(a,b)$ drawn uniformly from all $p^2$ pairs. This is the first example in every textbook.

When does $h_{a,b}$ collide? From $ax + b = ay + b$ we get $a(x-y) = 0$, and since $p$ is prime and $x \ne y$, this forces $a = 0$. So $h_{a,b}$ is injective whenever $a \neq 0$ and *constant* — collapsing every key to the single bucket $b$ — when $a = 0$. All or nothing, exactly as predicted. The probability of the bad case is the probability that $a = 0$, namely $p/p^2 = 1/p$.

So the affine family collides with probability exactly $1/p$, **independently of the number of keys**, as long as there are at least two of them and at most $p$. Two keys: $1/p$. All $p$ keys: still $1/p$. The union bound, meanwhile, has drifted from $1/p$ up to $\binom{p}{2}/p = (p-1)/2$, which for $p = 7$ equals $3$ — an upper bound on a probability that has become completely vacuous. The truth all along was $1/7 \approx 0.1429$.

Putting the floor and the witness together solves the extremal problem outright:

> **The Extremal Value Function.** Among all exactly 2-universal families of hash functions from $n$ keys into $m$ buckets, the minimum achievable collision probability is
> $$\min \Pr[\text{collision}] = \begin{cases} 1/m, & 2 \le n \le m,\\[2pt] 1, & n > m.\end{cases}$$

The second line is the pigeonhole principle: with more keys than buckets, *every* function collides, so every family collides with probability $1$, universal or not.

The first line is the surprise: a flat function of $n$. Everywhere in the nondegenerate range, the answer is the same number. The union bound's $\binom{n}{2}/m$ grows quadratically and crosses $1$ around $n \approx \sqrt{m}$; the truth doesn't move at all.

## No primes required

The affine family needs $p$ prime, which is an artifact of wanting a field to divide in. Is the value $1/m$ still attained when the number of buckets is, say, $12$?

Yes, by a construction that is almost a joke once you see what the extremal shape has to be. The counter must be all-or-nothing, so build a family with exactly two kinds of member:

* with total probability $1 - 1/m$, a **uniformly random bijection** of the buckets, which never collides;
* with total probability $1/m$, a **uniformly random constant map**, which always collides.

Check 2-universality: two distinct keys collide precisely on the constant branch, whose total mass is $1/m$. Exactly $1/m$ — the axiom holds on the nose. And the collision probability among any $n \ge 2$ keys is, again, the mass of the constant branch: $1/m$. No arithmetic, no primality, no field. The extremal value function above holds for **every** number of buckets.

This "bijection–constant mixture" is a caricature of a hash family — you would never deploy it, since a $1/m$ chance of total collapse is catastrophic where the affine family's identical $1/p$ chance is at least structured. But as an extremal object it is perfect, and it shows that the floor $1/m$ is not an accident of algebra. It is a feature of the axiom.

## Exactness is the whole story

Here is the twist that makes the theorem sharp. Carter and Wegman's axiom is an *inequality*: $\Pr[h(x) = h(y)] \le 1/m$. The theorem above assumes *equality*. Does the difference matter?

It matters completely. Suppose $n \le m$, so there is room for all your keys. Take a **single, deterministic, injective** function — just assign the $n$ keys to $n$ distinct buckets and be done. Then every pair collides with probability $0 \le 1/m$, so the inequality axiom is satisfied, and the collision probability is $0$.

So under the inequality-only axiom the extremal value collapses to a stark dichotomy: $0$ when $n \le m$, and $1$ when $n > m$, with nothing in between. The graceful floor $1/m$ is a phenomenon of exactness — equivalently of pairwise independence, the property real constructions actually have — and not of the union bound's hypothesis at all. Randomness in a hash family is not free; but you only pay for it if you insist that your family be *genuinely* random-looking rather than merely no-worse-than-random.

## What else the counter knows

The same collision counter that produced the floor yields two more facts worth recording.

**Universality costs almost nothing on average.** A pure counting argument — Cauchy–Schwarz applied to the sizes of the buckets' contents — shows that *any* single function, universal or not, clever or not, collides on at least $n^2/m - n$ ordered pairs of $n$ keys. Averaging, no random family can beat that in expectation. An exactly 2-universal family produces $n(n-1)/m$ colliding ordered pairs on average, exceeding the absolute floor by exactly $n(1 - 1/m)$ — less than the number of keys. At the level of first moments, the Carter–Wegman axiom is essentially free: you get near-optimal collision counts, and the price is a single additive $n$.

**Uniform families are arithmetically constrained.** If your family is indexed by a set $\Omega$ with the *uniform* law and is exactly 2-universal on at least two keys, then the pair-collision probability $1/m$ must be realised as a ratio of integers $c/|\Omega|$, forcing $m$ to divide $|\Omega|$. No uniformly weighted family whose size is coprime to $m$ can be exactly 2-universal, regardless of how it is built. The affine family, of size $p^2$, is the smallest square multiple of $p$ — pleasingly minimal.

## The moral

There is a habit of mind in probabilistic combinatorics that treats the union bound as the end of the analysis: bound the failure probability, show it is small, declare victory. The union bound is an inequality in one direction, and it is very good at that direction. What it cannot do — what nothing in its proof even gestures at — is tell you when you have squeezed all you can.

Here, asking the reverse question turned up a hard floor at $1/m$, a floor that does not budge as the problem gets easier, a floor whose extremal families are all-or-nothing objects, and a floor that vanishes the instant you weaken "exactly $1/m$" to "at most $1/m$". A single line of the union bound gives an upper bound that grows quadratically in the number of keys. A single line of the reverse Markov inequality gives a lower bound that is constant. Between them, for $2 \le n \le m$, the truth is pinned to the constant end.

The lesson is not that the union bound is wrong. It is that an inequality is a claim about only one side of a number, and it is worth asking, occasionally, what is on the other side.
