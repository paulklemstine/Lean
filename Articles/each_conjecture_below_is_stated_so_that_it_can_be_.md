# The Silver Thread: What Happens When You Try to Break a Sequence

## A number that ruins everything

Start counting with a rule almost as simple as the one behind the Fibonacci numbers. Begin with $0$ and $1$. Then, forever after, double the last number and add the one before it:

$$P_0 = 0,\quad P_1 = 1,\quad P_{n+2} = 2P_{n+1} + P_n.$$

Out comes

$$0,\ 1,\ 2,\ 5,\ 12,\ 29,\ 70,\ 169,\ 408,\ 985,\ 2378,\ \dots$$

These are the **Pell numbers**, and they have been quietly useful for two and a half millennia: they are the sequence that solves $x^2 - 2y^2 = \pm 1$, the sequence hidden inside the best rational approximations to $\sqrt{2}$, and the sequence that produces right triangles whose two legs differ by exactly one.

Look at the eighth entry. $P_7 = 169$. That is $13^2$.

It looks harmless. It is not. That single number is a demolition charge planted under half a dozen perfectly reasonable conjectures — and it goes off in all of them at once.

This article is about a research programme run on an unusual principle: **state every guess so sharply that one number can kill it.** Seven guesses died. The ones that survived were pushed all the way to theorems. And the corpses turned out to be more interesting than the survivors, because they all shared the same cause of death.

---

## The silver ratio and its integer shadow

Before the demolition, the architecture.

The golden ratio $\varphi = \tfrac{1+\sqrt5}{2}$ governs the Fibonacci numbers. Its less famous sibling, the **silver ratio**

$$\delta = 1 + \sqrt{2} = 2.41421356\dots,$$

governs the Pell numbers. Raise $\delta$ to a power and you get a number of the form $q + p\sqrt2$ with $p,q$ integers:

$$(1+\sqrt2)^1 = 1 + 1\sqrt2, \qquad (1+\sqrt2)^2 = 3 + 2\sqrt2, \qquad (1+\sqrt2)^3 = 7 + 5\sqrt2, \ \dots$$

The coefficients of $\sqrt2$ are the Pell numbers $P_n$. The rational parts form a second sequence, the **half-companion Pell numbers**,

$$Q_0 = 1,\quad Q_1 = 1,\quad Q_{n+2} = 2Q_{n+1} + Q_n: \qquad 1,\ 1,\ 3,\ 7,\ 17,\ 41,\ 99,\ 239,\ 577,\ \dots$$

so that in one line,

$$(1+\sqrt2)^n = Q_n + P_n\sqrt2.$$

Call the interleaved pair $(Q_n, P_n)$ the **Pell spine**. Two strands, one backbone.

The spine's defining property falls out immediately from multiplying $(1+\sqrt2)^n$ by its conjugate $(1-\sqrt2)^n$: since $(1+\sqrt2)(1-\sqrt2) = -1$,

$$Q_n^2 - 2P_n^2 = (-1)^n.$$

Check it: $3^2 - 2\cdot2^2 = 1$; $7^2 - 2\cdot 5^2 = -1$; $17^2 - 2 \cdot 12^2 = 1$. This one identity is the whole engine room. It says every spine point is a *unit* — an invertible element — in the number system $\mathbb{Z}[\sqrt2]$ of numbers $a + b\sqrt2$ with integer $a,b$. And the alternating sign $(-1)^n$, apparently a cosmetic detail, turns out to be the hidden variable behind nearly everything that follows.

Three immediate consequences, each a small theorem.

**The spine is exactly the unit group.** A pair of non-negative integers $(x,y)$ satisfies $x^2 - 2y^2 = \pm 1$ **if and only if** $(x,y) = (Q_n, P_n)$ for some $n$. Nothing else works. The proof is a descent: given any solution, the map $(x,y) \mapsto (3x - 4y,\ 3y - 2x)$ — multiplication by $3 - 2\sqrt2$, the inverse of $\delta^2$ — produces a strictly smaller solution, so repeated application must land on $(1,0)$ or $(1,1)$, and climbing back up retraces the spine. The sign of the norm records the parity of $n$: even indices give $+1$, odd indices $-1$.

**The spine approximates $\sqrt2$ perfectly.** The conjugate $(1-\sqrt2)^n = Q_n - P_n\sqrt2$ shrinks geometrically, giving the *exact* error formula

$$\bigl|Q_n - P_n\sqrt2\bigr| = (\sqrt2-1)^n = (0.41421\dots)^n,$$

and therefore $\bigl|\sqrt2 - Q_n/P_n\bigr| < 1/P_n^2$ for every $n \geq 1$. Each fraction $1/1, 3/2, 7/5, 17/12, 41/29, \dots$ is accurate to roughly the square of its denominator — the best you can ask of a rational approximation. And the sign of $Q_n - P_n\sqrt2$ alternates with $n$, so the fractions zigzag across $\sqrt2$, never approaching from one side.

**The spine draws right triangles.** A Pythagorean triple is *near-isosceles* if its legs are consecutive integers: $(3,4,5)$, $(20,21,29)$, $(119,120,169)$. These are exactly the odd-index spine points: $a^2 + (a+1)^2 = c^2$ holds precisely when $2a+1 = Q_{2k+1}$ and $c = P_{2k+1}$. Every such hypotenuse leaves remainder $1$ on division by $4$.

Beautiful, orderly, complete. Now let us try to break it.

---

## The rule that governs divisibility

Here is the deepest structural fact about the Pell numbers, and the source of most of the trouble.

> **Strong Divisibility Theorem.** For all $m, n \geq 0$,
> $$\gcd(P_m, P_n) = P_{\gcd(m,n)}.$$

The greatest common divisor of two Pell numbers is the Pell number of the greatest common divisor of their indices. Divisibility *of indices* is mirrored exactly in divisibility *of values*: $m \mid n$ if and only if $P_m \mid P_n$, with no exceptions and no fine print.

Why is it true? Because of an addition law: $P_{m+n} = P_m Q_n + Q_m P_n$. Reduce this modulo $P_n$ and the second term vanishes, leaving $P_{m+n} \equiv P_m Q_n$. Since $Q_n$ is coprime to $P_n$ — which is exactly what $Q_n^2 - 2P_n^2 = \pm1$ tells you — the factor $Q_n$ is invisible to the gcd. So $\gcd(P_{m+n}, P_n) = \gcd(P_m, P_n)$. That is the Euclidean algorithm, running on indices. Iterate it and the gcd of indices drops out.

This theorem is a licence to be greedy. Once you know it, four or five strengthenings suggest themselves, all natural, all plausible. Every one of them is false.

---

## Seven guesses, seven corpses

**Guess 1: a prime index gives a prime Pell number.** It is true that if $P_n$ is prime then $n$ must be prime (an immediate consequence of strong divisibility: a composite index forces a proper divisor). Does the converse hold? $P_2 = 2$: prime. $P_3 = 5$: prime. $P_5 = 29$: prime. $P_7 = 169 = 13^2$. Dead.

**Guess 2: Pell numbers are squarefree.** The corresponding question for Fibonacci numbers is a well-known open problem — nobody knows whether every Fibonacci number is squarefree. For Pell numbers there is nothing to wonder about. $P_7 = 13^2$. Dead at the seventh term.

**Guess 3: no Pell number beyond the first is a perfect square.** $169 = 13^2$. Dead. (It happens that $169$ is the *only* Pell square, but a single counterexample already settles the question.)

**Guess 4: the companion strand $Q$ is a strong divisibility sequence too.** The two strands look symmetric; they obey the same recursion. Surely the same law holds? Take $m = 3$, $n = 6$. Then $3 \mid 6$, so we would need $Q_3 = 7$ to divide $Q_6 = 99$. It does not: $\gcd(7, 99) = 1$. Dead — and dead in a maximally embarrassing way, since the gcd is not merely wrong, it is as small as it could possibly be.

**Guess 5: near-isosceles right triangles have prime hypotenuses.** The hypotenuses run $1, 5, 29, 169, 985, 5741, \dots$; the first three are prime. The fourth is $169 = 13^2$. Dead — and note *what* killed it: a purely geometric statement about triangles, destroyed by an arithmetic accident four terms into a sequence.

**Guess 6: a Fermat-style law $p \mid P_{p-1}$ for odd primes $p$.** Fermat's little theorem has an analogue for most such sequences. Try $p = 3$: is $3 \mid P_2 = 2$? No. Dead at the very first test.

**Guess 7: the approximation constant can be improved.** We proved $|\sqrt2 - Q_n/P_n| < 1/P_n^2$. Can the right-hand side be shrunk to $1/(3P_n^2)$? At $n=1$ the fraction is $1/1$ and the error is $|\sqrt2 - 1| = 0.414\dots$, which exceeds $1/3$. Dead. (Relatedly, the approximations are not one-sided: $Q_1/P_1 = 1 < \sqrt2$, so no "always from above" statement survives either.)

Seven guesses, all buried inside the first thirty terms. And notice how many of the tombstones read the same: **$P_7 = 169$**. Primality, squarefreeness, squareness, prime hypotenuses — one number, four kills. Arithmetic accidents cluster.

---

## Rebuilding: where does a modulus first appear?

A refutation is only half a result. The interesting question is always: *what is the true statement?*

Take a whole number $m$ — any one you like, say $m = 47$. Does $47$ divide *some* Pell number? It is not obvious that it should. But it does, and so does every other modulus.

> **Apparition Theorem.** Every integer $m \geq 1$ divides some positive Pell number.

The proof is a small gem of finite combinatorics. Track the pair $(P_n, P_{n+1})$ modulo $m$. There are only $m^2$ possible pairs, so as $n$ runs through infinitely many values, some pair must repeat: $(P_i, P_{i+1}) \equiv (P_j, P_{j+1})$ for some $i < j$. Now comes the trick. The recursion $P_{n+2} = 2P_{n+1} + P_n$ can be run *backwards*: $P_n = P_{n+2} - 2P_{n+1}$. So the repetition at $(i, j)$ can be rewound one step to a repetition at $(i-1, j-1)$, then $(i-2, j-2)$, and so on all the way to the origin. We land on $(P_0, P_1) \equiv (P_t, P_{t+1})$ where $t = j - i > 0$. But $P_0 = 0$. Hence $m \mid P_t$. $\square$

That justifies a definition. The **rank of apparition** $\alpha(m)$ is the least positive $n$ with $m \mid P_n$ — the index at which the modulus $m$ first shows up on the spine. A short table:

| $m$ | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 31 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| $\alpha(m)$ | 2 | 4 | 4 | 3 | 4 | 6 | 8 | 12 | 6 | 12 | 4 | 7 | 30 |

And now the payoff — the theorem that makes the whole rank concept worth having:

> **Divisibility Law.** For every $m \geq 1$ and every $n$,
> $$m \mid P_n \quad\Longleftrightarrow\quad \alpha(m) \mid n.$$

The set of indices at which $m$ appears is not merely infinite — it is *exactly* the multiples of the first one. Nothing is skipped, nothing extra creeps in.

The proof is a lovely handshake between combinatorics and arithmetic. Suppose $m \mid P_n$. We also know $m \mid P_{\alpha(m)}$, so $m$ divides $\gcd(P_{\alpha(m)}, P_n)$. By strong divisibility, that gcd is $P_{\gcd(\alpha(m), n)}$. So $m$ appears at index $\gcd(\alpha(m), n)$ — but $\alpha(m)$ was the *smallest* index where $m$ appears, and this gcd is at most $\alpha(m)$. Minimality forces $\gcd(\alpha(m), n) = \alpha(m)$, i.e. $\alpha(m) \mid n$. Pigeonhole supplies existence; the gcd law supplies rigidity; minimality clicks them together.

A structural corollary follows at once: if $a$ and $b$ are coprime then $\alpha(ab) = \operatorname{lcm}(\alpha(a), \alpha(b))$. So the entire rank function is determined by its values on prime powers — the arithmetic equivalent of a Chinese Remainder Theorem for apparition.

---

## Repairing the Fermat law

Guess 6 died at $p = 3$. What is the truth?

Here is the honest theorem, and its proof is my favourite in the whole story:

> **Fermat Law for the Pell Spine.** For every odd prime $p$,
> $$p \mid P_{p-1}\, P_{p+1}.$$
> Equivalently, $\alpha(p)$ divides $p-1$ **or** $\alpha(p)$ divides $p+1$.

The proof takes place inside $\mathbb{Z}[\sqrt2]$ and uses the "freshman's dream" — the fact that in characteristic $p$, the map $x \mapsto x^p$ is additive. Concretely, for any commutative ring and any prime $p$, one has $(x+y)^p = x^p + y^p + p\,xy\,r$ for some ring element $r$. Apply this with $x = 1$ and $y = \sqrt2$:

$$(1+\sqrt2)^p = 1 + (\sqrt2)^p + p\cdot(\text{stuff}).$$

The left side is $Q_p + P_p\sqrt2$ by definition of the spine. On the right, since $p$ is odd, write $p = 2m+1$ and note $(\sqrt2)^{2m+1} = 2^m\sqrt2$. Comparing the coefficients of $\sqrt2$ on both sides gives

$$P_p \equiv 2^{(p-1)/2} \pmod p.$$

That is **Euler's criterion**, appearing unbidden on the Pell spine: $2^{(p-1)/2}$ is $+1$ or $-1$ modulo $p$ according to whether $2$ is or is not a square modulo $p$. Squaring and invoking Fermat's little theorem gives $P_p^2 \equiv 1 \pmod p$. Finally, an addition-law identity — a consequence of $Q_p^2 - 2P_p^2 = -1$ at the odd index $p$ — says

$$P_{p-1}P_{p+1} = P_p^2 - 1,$$

which is therefore divisible by $p$. Since $p$ is prime, it divides one of the two factors. $\square$

Now the counterexample makes perfect sense. For $p = 3$ we have $\alpha(3) = 4$, and $4 \nmid 2 = p-1$; but $4 \mid 4 = p+1$. Which side you land on is dictated by the Legendre symbol $\left(\tfrac{2}{p}\right)$, i.e. by whether $p \equiv \pm 1 \pmod 8$: the true law is $\alpha(p) \mid p - \left(\tfrac{2}{p}\right)$. And $2$ is a non-residue modulo $3$. The "counterexample" was never an anomaly; it was the theorem, correctly stated, showing its second face.

---

## Repairing the companion law: parity is the hidden variable

Guess 4 died because $Q_3 = 7$ does not divide $Q_6 = 99$. But then *when* does $Q_m$ divide $Q_n$? The complete answer is a genuinely new kind of law, one with no counterpart on the $P$ strand:

> **Companion Divisibility Law.** For every $m \geq 2$,
> $$Q_m \mid Q_n \quad\Longleftrightarrow\quad n = mk \ \text{ for some odd } k.$$

Odd multiples of the index work; even multiples never do. Take $m = 3$, so $Q_3 = 7$. Then $Q_9 = 1393 = 7 \cdot 199$ and $Q_{15} = 275807 = 7 \cdot 39401$: both divisible, both with odd quotient $9/3 = 3$ and $15/3 = 5$. But $Q_6 = 99$ and $Q_{12} = 19601$ are not divisible by $7$ at all, and their quotients $2$ and $4$ are even.

The proof splits cleanly into two halves that never talk to each other.

*The index step.* One shows $Q_m \mid P_{2m}$ (from the doubling formula $P_{2m} = 2P_mQ_m$). Feeding this into strong divisibility for $P$ forces $Q_m$ to divide $P_{2\gcd(m,n)}$. If $\gcd(m,n)$ were smaller than $m$, that divisor would exceed the dividend — impossible. So $m \mid n$.

*The parity step.* Work modulo $Q_m$. The addition law collapses to a clean two-step recursion: $Q_{a+2m} \equiv 2P_m^2\,Q_a$. Iterating, $Q_{2jm} \equiv (2P_m^2)^j$. Now, $Q_m$ is always odd, and it is coprime to $P_m$, so $2P_m^2$ is a *unit* modulo $Q_m$ — its powers are never zero. Hence $Q_m$ can never divide $Q_{2jm}$. Even multiples are excluded, permanently.

The same grading controls gcds, with no side conditions at all. Writing $g = \gcd(m,n)$:

$$\gcd(Q_m, Q_n) = \begin{cases} Q_g & \text{if } m/g \text{ and } n/g \text{ are both odd},\\[2pt] 1 & \text{otherwise.}\end{cases}$$

Not a broken version of strong divisibility — a *graded* version, with the grading by parity of index quotients. The failed guess was not a dead end; it was a signpost pointing at a finer structure.

Why parity? Because of $(-1)^n$. Look back at the norm identity $Q_n^2 - 2P_n^2 = (-1)^n$. That sign simultaneously decides which side of $\sqrt2$ the convergent $Q_n/P_n$ falls on, whether the index produces a Pythagorean triple, and whether $\alpha(p)$ divides $p-1$ or $p+1$. Parity is the hidden variable running through the entire theory, and the companion law is where it becomes impossible to ignore.

---

## The prime 13, and a rarity that isn't rare

We saved the best refutation for last.

For Fibonacci numbers there is a celebrated open question. Define the Fibonacci rank of apparition analogously. It is expected — and in a precise sense generic — that when you pass from a prime $p$ to $p^2$, the rank multiplies by $p$. A prime for which this *fails*, i.e. one with $p^2 \mid F_{\alpha(p)}$, is called a **Wall–Sun–Sun prime**. They matter: before Wiles, the existence of such primes was tied to the first case of Fermat's Last Theorem. And despite enormous computational searches, **not a single Fibonacci Wall–Sun–Sun prime is known**. None below $10^{17}$.

Run the same conjecture on the Pell spine:

$$\alpha(p^2) \stackrel{?}{=} p \cdot \alpha(p).$$

Recall $P_7 = 169 = 13^2$. The rank of $13$ is $7$. But since $13^2$ already divides $P_7$, the rank of $169$ is also $7$ — not $7 \times 13 = 91$. Dead, at the smallest interesting prime.

And it is not a fluke. The second Pell number with this property is not far away:

$$31^2 \mid P_{30} = 107\,578\,520\,350, \qquad \alpha(31) = \alpha(961) = 30.$$

So the Pell spine hands you **two** Wall–Sun–Sun-type primes, $13$ and $31$, below $50$ — in a setting where the Fibonacci analogue has resisted searches out to seventeen digits.

Is this luck? Probably not. The heuristic for Wall–Sun–Sun primes predicts a counting function of order $\log\log x$ — brutally slow growth, which is why Fibonacci turns up nothing. The Pell case has an extra structural feature: the relevant discriminant is $8$, and the prime $2$ is *ramified*, which doubles the heuristic density. Two hits below $10^2$ is still a small-numbers coincidence — but a coincidence that the structure predicts should be twice as likely as in the golden-ratio world. The conjecture that the set of such primes is infinite, with counting function $\sim\log\log x$, is a natural next target.

---

## What the wreckage teaches

Step back and three patterns emerge from the rubble.

**Norm versus trace.** Strong divisibility is a property of the *norm-form* sequence $P$ — the one that solves $x^2 - 2y^2 = \pm1$ — and not of the *trace* sequence $Q$. On $Q$ it does not vanish; it degrades into the parity-graded law. Whenever you meet a pair of companion sequences, expect the two strands to obey different divisibility theories, and expect the difference to be a grading rather than a collapse.

**Parity is the hidden variable.** The alternating sign $(-1)^n$ in $Q_n^2 - 2P_n^2 = (-1)^n$ is not decoration. It sorts the spine into two halves: even indices solve the positive Pell equation, odd indices solve the negative one and manufacture near-isosceles right triangles; even indices approximate $\sqrt2$ from above, odd from below; even multiples break companion divisibility, odd ones respect it. One sign, four consequences.

**Failures cluster.** Four independent-looking conjectures — a prime index gives a prime value, Pell numbers are squarefree, no Pell number is a square, near-isosceles hypotenuses are prime — all die at the *same term*, $P_7 = 169$. And that same term makes $13$ a Wall–Sun–Sun prime. When a sequence has an arithmetic accident, the accident tends to be visible from many directions at once. If you want to falsify a family of conjectures about a sequence, do not test them independently; find its accidents and aim everything at them.

There is a broader methodological point here, and it is the reason the "state it so one number can kill it" discipline is worth adopting. A vaguely stated conjecture can absorb a counterexample and limp on. A sharply stated one dies cleanly — and its death certificate names the true theorem. Guess 6 died at $p=3$ and handed us the Legendre symbol. Guess 4 died at $(3,6)$ and handed us the parity grading. Guess "Wall–Sun–Sun" died at $p=13$ and handed us a phenomenon that number theorists have been hunting unsuccessfully in the golden-ratio world for decades.

The Pell numbers are $2\,500$ years old. They still have things to say — and the fastest way to hear them is to say something false, precisely.
