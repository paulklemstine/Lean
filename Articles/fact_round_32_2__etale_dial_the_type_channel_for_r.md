# What a Sum Remembers

*Two secret numbers, a leaked hint, and the exact law that decides which secrets survive.*

---

## A secret with a hint

Take two secret primes, $p$ and $q$. Multiply them and publish the product $N = pq$ — this is how the RSA cryptosystem hides its key. Now imagine something leaks: not $p$ or $q$ themselves, but a small hint about their sum, say $p + q$ modulo $8$.

What has leaked? You might think the answer is obvious. If you know both the sum $s = p + q$ and the product $n = pq$ exactly, you know everything: $p$ and $q$ are the two roots of the quadratic
$$x^2 - s\,x + n = 0,$$
and the quadratic formula hands them to you. That is Vieta's observation from the sixteenth century: *sum and product determine the pair*.

But a hint "modulo $8$" is not exact knowledge. It lives in the world of clock arithmetic, where $17$ and $1$ and $9$ are all "the same" because they leave the same remainder after division by $8$. And clock arithmetic is a strange place. The quadratic formula can fail there. A quadratic can have more than two roots. And that single fact controls which pieces of information about $p$ and $q$ survive the leak and which dissolve.

This article tells the story of how that control was measured exactly — and how, along the way, a tidy explanation of an experimental puzzle turned out to be wrong.

## Dials: the information you actually want

In number theory one rarely cares about $p$ itself. One cares about *types*: coarse features of $p$ that govern how it behaves.

The classic example is whether $-1$ is a perfect square modulo $p$. Fermat knew the answer depends only on $p$ modulo $4$: if $p$ leaves remainder $1$ on division by $4$, then $-1$ is a square (and $p$ is a sum of two squares, like $13 = 4 + 9$); if $p$ leaves remainder $3$, it is not. Similarly, whether $2$ is a square modulo $p$ depends only on $p$ modulo $8$: yes when $p$ leaves remainder $1$ or $7$, no when it leaves $3$ or $5$.

These are called *Legendre symbols*, and they are the simplest members of a vast family. For every polynomial with integer coefficients, the way it breaks into factors modulo a prime $p$ — its *splitting type* — is an arithmetic fingerprint of $p$. For a large and important class of polynomials (those whose roots generate what are called abelian number fields), that fingerprint depends only on $p$ modulo some fixed number $m$, called the *conductor*. This is the content of the celebrated Kronecker–Weber theorem.

So think of each such fingerprint as a **dial**: a function $f$ that takes the remainder of $p$ modulo $m$ and outputs a type. The question becomes:

> **If I see only $p + q$ and $pq$ modulo $m$, which dials can I still read — in the sense that I can name the pair of types $\{f(p), f(q)\}$ without ambiguity?**

Call such a dial **readable**.

## The puzzle from the lab

An experimental study had looked at six dials of different symmetry types, with conductors $31$, $23$, $9$, $8$, $5$ and $11$, and measured how much type information flowed through the sum hint, how much through a difference hint, and how much appeared only when both were combined. Most dials required the combination. But one — a dial at conductor $8$ with the symmetry of a square (the group $D_4$) — seemed to be carried entirely by the sum.

The proposed explanation was short and appealing: *knowing $N = pq$ modulo $8$ and $p + q$ modulo $8$, you can solve for $p$ modulo $8$ — after all, $q$ is just $N$ divided by $p$.* Two equations, two unknowns. What could go wrong?

## The counterexample

Here is what goes wrong. Take the primes $17$ and $41$, and the primes $13$ and $29$. Compute:

- $17 \times 41 = 697$, which leaves remainder $1$ modulo $8$; and $13 \times 29 = 377$, which also leaves remainder $1$.
- $17 + 41 = 58$, remainder $2$ modulo $8$; and $13 + 29 = 42$, also remainder $2$.

So the two pairs look *identical* through the hint. Yet $17$ and $41$ both leave remainder $1$ modulo $8$, while $13$ and $29$ both leave remainder $5$. The hint does not determine $p$ modulo $8$. The appealing explanation is false.

The algebra behind it is a single line. Modulo $8$,
$$(x - 1)^2 = x^2 - 2x + 1 \quad\text{and}\quad (x-5)^2 = x^2 - 10x + 25 \equiv x^2 - 2x + 1.$$
The same quadratic factors in two genuinely different ways. The culprit is the number $4$: modulo $8$, $4 \times 4 = 16 \equiv 0$. A nonzero number whose square is zero — a *nilpotent* — lets you nudge both roots by $\pm 4$ without changing the sum or product: $(1+4) + (1-4) = 2$ and $(1+4)(1-4) = 1 - 16 \equiv 1$.

Once you see this, it is everywhere.

## Two ways to lose information

It turns out that clock arithmetic can blur a pair in exactly two ways.

**Nilpotents.** Whenever a square of a prime divides the modulus, say $m = \ell^2 c$, the number $a = \ell c$ is nonzero but $a^2 \equiv 0$. Then the pairs $\{1, 1\}$ and $\{1 + a, 1 - a\}$ have the same sum $2$ and the same product $1$. This is what happened at $m = 8$.

**Mismatched halves.** When the modulus splits into two coprime pieces — like $15 = 3 \times 5$ — the Chinese remainder theorem says a number modulo $15$ is really a pair of numbers, one modulo $3$ and one modulo $5$. Sums and products are computed piece by piece. So if you swap how the pieces are matched — pair the "mod-3 part" of $p$ with the "mod-5 part" of $q$ — every sum and product is unchanged. Concretely, modulo $15$ the pairs $\{1, 14\}$ and $\{4, 11\}$ both have sum $0$ and product $14$. The hint remembers each half, but forgets which half goes with which.

Rule out both failure modes and you are left with very few moduli. The first theorem is a clean classification:

> **Conductor Classification.** The hint $(p + q, pq)$ modulo $m$ determines the unordered pair $\{p, q\}$ of residues coprime to $m$ exactly when $m$ is $1$, $2$, an odd prime $\ell$, or twice an odd prime $2\ell$.

A computer search over every modulus up to $60$ finds precisely the list $1, 2, 3, 5, 6, 7, 10, 11, 13, 14, 17, 19, 22, 23, \dots, 58, 59$ — the primes and twice the primes, and nothing else.

## The half-conductor law

So at $m = 8$ the hint does not pin down $p$ modulo $8$. Does it pin down anything? Yes — and here the story becomes beautiful.

The key is an identity that holds for any four numbers:
$$(p - p')(p - q') = p\,\big[(p+q) - (p'+q')\big] - \big[pq - p'q'\big].$$
If two pairs $\{p, q\}$ and $\{p', q'\}$ share the same hint modulo $\ell^k$ (a prime power), the right-hand side is divisible by $\ell^k$, so the product $(p - p')(p - q')$ is too. Now a product can be divisible by $\ell^k$ only if its two factors *share out* the $k$ copies of $\ell$ between them. One of them must get at least half — at least $\lceil k/2 \rceil$ copies. That means $p$ agrees with $p'$ or with $q'$ modulo $\ell^{\lceil k/2 \rceil}$.

> **Half-Conductor Law.** If two pairs of integers have the same sum and the same product modulo $\ell^k$, then they agree as unordered pairs modulo $\ell^{\lceil k/2 \rceil}$. This is sharp: $\{1,1\}$ and $\{1 + \ell^{\lceil k/2\rceil}, 1 - \ell^{\lceil k/2\rceil}\}$ share a hint modulo $\ell^k$ but differ modulo any higher power.

The hint keeps exactly *half* the digits — in base $\ell$ — of the pair. At $8 = 2^3$ it keeps $2^2 = 4$. At $27 = 3^3$ it keeps $9$. At $64 = 2^6$ it keeps $8$. A computer confirms each of these resolutions directly by trying every pair.

There is a lovely bonus. The lost information comes only from pairs whose two members are close to each other. If $p$ and $q$ are *different* modulo $\ell$, the product $(p - p')(p - q')$ cannot share its factors of $\ell$ at all, and the hint determines the pair modulo the full $\ell^k$. This is the arithmetic heart of Hensel's lemma: distinct roots lift uniquely; only repeated roots blur.

## Which dials can be read

Now return to dials. A dial is readable if and only if it cannot tell apart numbers that the hint confuses. At a prime power this gives an exact answer:

> **Readable Dials at a Prime Power.** A dial of conductor $\ell^k$ is readable if and only if it depends only on the remainder modulo $\ell^{\lceil k/2 \rceil}$.

The "only if" direction has a neat proof. If $x$ and $y$ agree modulo $\ell^{\lceil k/2 \rceil}$, their difference $d$ squares to zero modulo $\ell^k$. Then $\{x, x\}$ and $\{y, x - d\}$ share the same sum $2x$ and product $x^2 - d^2 = x^2$ — so a readable dial must give $x$ and $y$ the same type.

At conductor $8$, the residues coprime to $8$ are $1, 3, 5, 7$, and the confusions all come from multiplying by $5$: $1 \leftrightarrow 5$ and $3 \leftrightarrow 7$. So:

> **Criterion at Conductor 8.** A dial of conductor $8$ is readable if and only if it gives $p$ and $5p$ the same type — that is, if and only if it only looks at $p$ modulo $4$.

## Three square roots, one survivor

Conductor $8$ hosts exactly three classical dials, one for each "quadratic field" hiding inside the eighth roots of unity:

- the $\mathbb{Q}(i)$ dial — is $-1$ a square mod $p$? — which depends on $p$ modulo $4$;
- the $\mathbb{Q}(\sqrt 2)$ dial — is $2$ a square mod $p$? — which is "yes" for $p \equiv 1, 7 \pmod 8$;
- the $\mathbb{Q}(\sqrt{-2})$ dial — is $-2$ a square mod $p$? — which is "yes" for $p \equiv 1, 3 \pmod 8$.

Apply the criterion. The first dial ignores multiplication by $5$; the other two both flip when $1$ becomes $5$. **Exactly one of the three survives the hint: the $\mathbb{Q}(i)$ dial.** If the experimental $D_4$ dial really is carried by the sum, then it can only be reading this $\mathbb{Q}(i)$ layer — not the full remainder modulo $8$ that the original explanation assumed.

## When a polynomial breaks in two

Here is where the title's "reducible polynomials" come in. Consider
$$F(x) = (x^2 + 1)(x^2 - 2).$$
Modulo a prime $p$, the first factor splits exactly when $-1$ is a square, the second exactly when $2$ is a square. So the full splitting type of $F$ — mathematicians call it the *étale type* — is the pair of answers to both questions.

The first factor's dial is readable. The combined dial is **not**: if you could read the pair, you could in particular read the second answer, and we just saw you cannot. Even the cruder "how many factors split?" is unreadable (it gives $2$ at $p \equiv 1$ and $1$ at $p \equiv 5$), as is the question "does $x^4 + 1$ split completely?", which holds exactly for $p \equiv 1 \pmod 8$.

The moral: **readability is not inherited from the factors of a polynomial.**

## Readable dials do not combine

Is that just bad luck with $x^2 - 2$? No. Go back to $15 = 3 \times 5$. The dial "$p$ modulo $3$" is readable — a field is Vieta-perfect. So is "$p$ modulo $5$". But the combined dial "($p$ modulo $3$, $p$ modulo $5$)" is just $p$ modulo $15$ in disguise, and the mismatched-halves collision $\{1, 14\} \sim \{4, 11\}$ kills it. Two readable dials, one unreadable join.

The deeper reason is a small combinatorial gem, the **swap dichotomy**: if a function on a grid always gives the same unordered pair of values to the "straight" pair of cells $\{(x,y), (x',y')\}$ and the "crossed" pair $\{(x,y'), (x',y)\}$, then it must ignore one of the two coordinates entirely. Because the Chinese remainder theorem makes every straight pair collide with its crossed partner, a readable dial on a product must look at only one factor.

## The complete answer

Put the two effects together — nilpotents halve the resolution, coprime splittings force you to pick one factor — and you get the final theorem, which settles the question for every conductor at once:

> **Readable Dials at Every Conductor.** A dial of conductor $m$ is readable if and only if there is a single prime power $\ell^k$ exactly dividing $m$ such that the dial depends only on the remainder modulo $\ell^{\lceil k/2 \rceil}$.

At $m = 24 = 8 \times 3$, for instance, a readable dial may look at $p$ modulo $4$ or at $p$ modulo $3$ — but never both. The proof goes by peeling off the smallest prime factor of $m$ and using the product rule and the half-conductor law repeatedly. A brute-force check on nearly 3,500 dials at every conductor up to $48$ agrees with the theorem in every single case.

## Why it matters

The empirical finding that "the routing is dial-dependent" — different dials leak through different channels — now has a structural explanation. The sum hint is a lens that focuses on **one prime-power layer of the conductor, at half its resolution**. Dials that live in that layer come through sharp; dials that straddle two layers, or need the full resolution, come through blurred and require combining the sum with other information.

The broader lesson is one mathematicians relearn constantly: facts that are obvious over the real numbers — "sum and product determine the pair" — can fail in illuminating ways in modular arithmetic, and the failures are not random. Here they are governed by just two mechanisms, nilpotents and mismatched halves, and they can be counted exactly. The quadratic formula, it turns out, remembers exactly half of what you hoped it would — and now we know precisely which half.
