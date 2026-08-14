# The Weak Key That Cannot Be Spotted

## On a number that knows its own secret — and refuses to tell

Every day, billions of encrypted connections rest on a single stubborn fact: multiplying two large prime numbers is easy, and undoing the multiplication is hard. You are handed a number $N$, roughly six hundred digits long. Somewhere inside it hide two primes $p$ and $q$ with $N = pq$. Find them and the encryption falls apart. Nobody knows how to find them quickly.

But "hard in general" is not the same as "hard always". Cryptography's real nightmare is the *weak instance*: the occasional key that happens to be easy. And there is a famous family of weak instances, discovered by John Pollard in 1974 and refined into the elliptic curve method a decade later. The idea is disarmingly simple.

Suppose $p$ is one of the hidden primes. Look at the number $p - 1$. If $p - 1$ happens to factor entirely into small primes — say, nothing bigger than a million — then $p$ can be extracted from $N$ almost instantly. The technical word is **smooth**: a number is $B$-smooth if all of its prime factors are at most $B$. Smooth $p-1$ means dead key.

For instance, $p = 2\,161$ is prime and
$$p - 1 = 2160 = 2^4 \cdot 3^3 \cdot 5,$$
which is $5$-smooth. A modulus with such a factor is a gift to an attacker. By contrast, $p = 2\,963$ has $p - 1 = 2962 = 2 \cdot 1481$ with $1481$ prime — hopeless for this attack.

Here is the disquieting part. If you generate random primes of moderate size, a *large fraction* of them are weak in this sense. Experiments with random semiprimes of $14$, $16$, and $18$ bits — hundreds of thousands of them — find that between roughly $60\%$ and $78\%$ have a factor $p$ with $p-1$ smooth to the bound $1000$. That is not a rare accident. That is a majority.

Which raises the question this article is about:

> **Given only $N$, can you tell whether you have been handed a weak key?**

Not factor it. Just *recognize* it. A screening test — some quick statistic computable from $N$ alone that whispers "this one is worth attacking". Call such a thing a **self-hint**: a hint about the secret, extracted from the public data itself.

The answer, it turns out, is a clean and total no. And the proof of that no comes with a beautiful consolation prize: a precise account of exactly which questions about the hidden factors *are* visible in $N$, and exactly how many bits of them leak. The dividing line is not between easy questions and hard ones. It is between **asymmetric** questions and **symmetric** ones.

---

## The smallest possible version of the question

Full smoothness of $p-1$ is a complicated event. Strip it down to its atom. Fix a small prime $\ell$ — say $3$ — and ask the simplest sub-question:

> Is $p - 1$ divisible by $3$?

That is one tiny building block of smoothness. And the natural place to look for an answer is the *residue* of $N$: what is $N$ modulo $3$? That single digit of information is free — anyone can compute it.

The experiment is easy to run. Take hundreds of thousands of random semiprimes, compute $N \bmod 3$ and the true answer to "$3 \mid p-1$", and measure how much one tells you about the other. The standard measure is **mutual information**, counted in bits: zero means total independence, and one bit means the residue determines the answer outright.

The measurement comes back $0.0000$ bits. Not "small". Not "below the noise floor". Zero, for $\ell = 3, 5, 7, 11$, at every key size.

Now change one word in the question. Instead of asking about $p$, ask about *either* factor:

> Is $3 \mid p-1$ **or** $3 \mid q-1$?

Same primes. Same modulus. Same free residue $N \bmod 3$. The measurement now returns $0.313$ bits — a third of a bit, an enormous signal by the standards of this subject. And at $\ell = 5, 7, 11$ the leaks are $0.036$, $0.015$, $0.005$ bits: small, but stubbornly nonzero and perfectly stable across key sizes.

One version of the question is invisible. The other is loud. This is the **asymmetric/symmetric dichotomy**, and it is not a numerical coincidence — it is a theorem about the geometry of multiplication.

---

## Why $N$ can never point at a factor

Here is the mechanism, and it is a one-line miracle once you see it.

Forget primes for a moment. Work in any finite group $G$ — for us, $G$ is the group of nonzero residues modulo $\ell$, which has $\ell - 1$ elements. A semiprime $N = pq$ reduces to a *factorisation* $n = ab$ in $G$, where $a$ is the class of $p$ and $b$ the class of $q$. Fix a target set $A \subseteq G$: for our question, $A = \{1\}$, the single element $1$, since "$\ell \mid p-1$" says exactly "$p \equiv 1$".

Now count. Given the product $n$, how many factorisations $n = ab$ have the first factor in $A$?

**Theorem (asymmetric invisibility).** *For every finite group $G$, every subset $A \subseteq G$, and every $n \in G$, the number of pairs $(a,b)$ with $ab = n$ and $a \in A$ is exactly $|A|$ — independent of $n$.*

The reason is that $a$ determines $b$: given any $a$, the unique partner is $b = a^{-1}n$. So the pairs are in perfect bijection with the elements of $A$, whatever $n$ happens to be. Every product value is served by precisely the same number of "first factor in $A$" factorisations. The count cannot vary with $n$, so it cannot carry information about $n$.

Translate back: the residue of $N$ is statistically independent of the event "$\ell \mid p - 1$". The measured $0.0000$ bits is not an approximation. It is the exact truth, and it holds for *every* group, *every* modulus, and *every* target property of a single designated factor.

Now the symmetric version. Count factorisations $n = ab$ where *some* factor lies in $A$. The first-factor solutions give $A$; the second-factor solutions give the set $nA^{-1} = \{na^{-1} : a \in A\}$; and the two families overlap. So:

**Theorem (symmetric visibility).** *The number of factorisations $n = ab$ with $a \in A$ or $b \in A$ equals*
$$|A \cup nA^{-1}| \;=\; 2|A| - |A \cap nA^{-1}|.$$

The correction term $|A \cap nA^{-1}|$ is an **autocorrelation** of the set $A$ — it measures how much $A$ overlaps a translated reflection of itself — and it genuinely moves as $n$ moves. That wobble is the leak.

For the arithmetic case $A = \{1\}$ the formula collapses to something you can hold in your hand: the symmetric count is $1$ when $n = 1$ and $2$ otherwise. Two elements of every fibre satisfy the condition, except in the single fibre over the identity, where they collide into one. That collapse — one accidental coincidence — is the entire leak.

At $\ell = 3$ it becomes a hard logical implication. There the group has only two elements, $\{1, 2\}$, so a fibre has only two factorisations, and if two of them satisfy the condition, *all* of them do:

**Theorem (forcing at $\ell = 3$).** *If $N = pq$ with $p, q$ primes different from $3$ and $N \equiv 2 \pmod 3$, then $3 \mid p-1$ or $3 \mid q-1$.*

You can check the mechanism by hand. If neither factor is $\equiv 1$, both are $\equiv 2$, and $2 \cdot 2 = 4 \equiv 1 \pmod 3$ — so $N \equiv 1$, not $2$. The experimental "probability of the symmetric event $= 1.000$" is a genuine certainty, not a rounded statistic.

And yet in the very same residue class, the asymmetric question stays undecided. Both $77 = 7 \cdot 11$ and $65 = 5 \cdot 13$ are $\equiv 2 \pmod 3$; the smaller factor of the first satisfies $3 \mid p - 1$, the smaller factor of the second does not. The residue knows that *someone* is guilty. It has no idea *who*.

---

## Exactly how loud is the leak?

Because the fibre counts are so simple, the mutual information can be computed in closed form. In a group of order $d$ (so $d = \ell - 1$), the symmetric leak is exactly
$$
I(d) \;=\; \frac{1}{d^2}\Big[\log_2\tfrac{d}{2d-1} + (d-1)\log_2\tfrac{d}{d-1} + 2(d-1)\log_2\tfrac{2d}{2d-1} + (d-1)(d-2)\log_2\tfrac{d(d-2)}{(d-1)^2}\Big]
$$
bits. At $d = 2$, that is $\tfrac32 - \tfrac34\log_2 3 = 0.31128\ldots$ bits. The experiment reported $0.313$.

Evaluate it at the other tested primes and the agreement is uncanny:

| $\ell$ | $d = \ell - 1$ | predicted | measured |
|---|---|---|---|
| $3$ | $2$ | $0.31128$ | $0.313$ |
| $5$ | $4$ | $0.03588$ | $0.036$ |
| $7$ | $6$ | $0.01439$ | $0.015$ |
| $11$ | $10$ | $0.00484$ | $0.005$ |

Four numbers from a hundred thousand random semiprimes, reproduced to three decimals by a formula whose only input is the *order of a group*.

The formula also settles the shape of the phenomenon. The leak decays quadratically: $I(d) < 2/d^2$ for all $d \ge 2$, and it tends to zero. More sharply,
$$d^2 \, I(d) \;\longrightarrow\; \log_2 e - 1 = 0.442695\ldots,$$
so the symmetric leak in a modulus $\ell$ is asymptotically exactly
$$\frac{\log_2 e - 1}{(\ell-1)^2}\ \text{bits}.$$
The visible half of the dichotomy is itself vanishing. The dramatic $0.313$ bits at $\ell = 3$ is not the beginning of a trend — it is an outlier caused by the group of order two, where the two-element fibre is exhausted by a two-element event.

---

## Which questions leak at all?

Once the counting theorem is in hand, one can ask the classification question: for *which* target sets $A$ does the symmetric statistic leak nothing? The answer is a clean equivalence.

**Theorem (classification).** *The symmetric leak vanishes if and only if the autocorrelation $n \mapsto |A \cap nA^{-1}|$ is constant.*

That is precisely the defining property of a **perfect difference set** — a classical and rare object in combinatorics. So invisibility is not generic; it is a strong design condition. And in the commutative groups that arise here it never happens nontrivially:

**Theorem (abelian classification).** *In a finite commutative group, the autocorrelation of $A$ is constant if and only if $A$ is empty or all of $G$. Consequently, every nontrivial property of the factors leaks symmetrically, while every property whatsoever is asymmetrically invisible.*

The proof is a Fourier argument: writing $S(\psi) = \sum_{a \in A}\psi(a)$ for a character $\psi$, constancy of the autocorrelation forces $S(\psi)^2 = 0$ for every nontrivial character, and Fourier inversion then makes the indicator of $A$ constant.

A tempting guess is that structured targets — quadratic residues, $k$-th powers, cosets of subgroups — might be the invisible ones. Exactly the reverse is true. If $A = H$ is a subgroup, the symmetric fibre count is $|H|$ when $n \in H$ and $2|H|$ when $n \notin H$ — the most violently non-constant behaviour possible. Structured targets are the *loudest*.

---

## Bits that leak but cannot be spent

Here the story takes its most cryptographically pointed turn. A third of a bit sounds alarming. Is it usable?

A statistical hint is only an attack if it lets you *predict* better than the trivial guess. Model an attacker as a function $f$ from residues to yes/no answers, and score it by how often it is right. Compare against the two constant strategies, "always yes" and "always no".

For the asymmetric event, no predictor beats the better constant — the advantage is exactly zero, which is the algorithmic shadow of the zero mutual information. But for the symmetric event, in any group with at least four elements — that is, for every prime $\ell \ge 5$ — the same is true:

**Theorem (positive information, zero advantage).** *For $\ell \ge 5$, the symmetric divisibility event leaks a strictly positive number of bits about $N \bmod \ell$, and yet no function of $N \bmod \ell$ predicts it more accurately than the constant guess.*

The hypothesis is sharp: in a group of order three the Bayes predictor "$n \ne 1$" does score strictly better than either constant. But above that threshold, the leaked information is real and useless — the distribution shifts, but never far enough to move the majority answer in any residue class. It is a case study in the gap between information and advantage.

---

## Closing every door

Small moduli, then, are a dead end for the asymmetric question and an operational dead end for the symmetric one. What about bigger, cleverer statistics? The experiments tried the obvious ones and found nothing: the joint residue $N \bmod 1155$ (that is, modulo $3, 5, 7, 11$ at once) carries $0.006$ bits about the full smoothness of $p-1$ — indistinguishable from the $0.005$ bits a deliberately shuffled control produces. And the smoothness of $N-1$ and $N+1$, which anyone can compute, correlates with the smoothness of $p-1$ at the level of $0.014$: noise.

These are measurements. They can be upgraded to theorems, and they were.

**Theorem (no residue hint, any modulus).** *Let $\ell > 2$ and let $M$ be any modulus whatsoever. There is no function $f$ such that $f(N \bmod M)$ decides whether $\ell \mid p - 1$, for semiprimes $N = pq$ with $p < q$.*

The proof is a swap. By Dirichlet's theorem on primes in arithmetic progressions, choose primes $p_1 \equiv 1$, $q_1 \equiv -1$, $p_2 \equiv -1$, $q_2 \equiv 1$ modulo $\ell M$, with $p_1 < q_1 < p_2 < q_2$. Then $p_1q_1 \equiv p_2q_2 \equiv -1$, so the two semiprimes are indistinguishable modulo $M$ — while $\ell \mid p_1 - 1$ and $\ell \nmid p_2 - 1$. The residue sees the *unordered* product; the ordered information, which factor is which, has been destroyed by construction.

The same swap kills the smoothness question directly: no function of $N \bmod 1155$ decides whether $p-1$ is $10$-smooth. And it is not special to two factors — for three-prime moduli $N = pqr$ the count of factorisations with a designated factor in $A$ is $|A| \cdot |G|$, again independent of $N$, so the impossibility carries over verbatim.

Even the $N \pm 1$ heuristic is refuted by four small numbers rather than by statistics. All four combinations of ("$N-1$ is $10$-smooth", "$p-1$ is $10$-smooth") actually occur, at $N = 253, 1081, 143, 667$; and $253 = 11 \cdot 23$ and $1081 = 23 \cdot 47$ share the *same* pair of publicly computable smoothness bits while disagreeing on the secret one. The public bits are logically independent of the private one.

---

## A tropical coda

One last twist reveals what the dichotomy really is. Counting is just one way to evaluate a fibre. Replace "add up the contributions" with any commutative operation and the theorem persists: for any commutative monoid and any weight $f$ on group elements, the total of $f(a)$ over all factorisations $n = ab$ equals the total of $f$ over the whole group — independent of $n$.

Take the operation to be *minimum* and the product to be *addition* — the min-plus, or **tropical**, semiring, the arithmetic of shortest paths and optimal costs. There the statement reads: the cheapest factorisation cost, measured on the first factor alone, does not depend on $n$. But the symmetric tropical statistic — the cost of the cheapest factorisation *all of whose factors are cheap*, which is precisely a smoothness profile in disguise — does depend on $n$, already in the two-element group.

So the dichotomy is not an artefact of counting or of entropy. It is a property of the fibration of a group over its multiplication map, and it shows up in every semiring you evaluate it in.

---

## What it all means

The verdict on the original question is negative and complete: the $p-1$/ECM-weak instance class is **undetectable from $N$**. There is no residue test, no threshold dial, no filter, no statistical smoothness proxy that flags a weak modulus. The majority of these keys are weak — and none of them can be told apart from the strong ones without doing the work.

That is genuinely good news for cryptography, and it is also a clean structural statement about what public data can and cannot reveal. A product remembers the *multiset* of its factors and forgets the labels. Any question phrased about "the factor $p$" is a question about a label, and labels are exactly the information multiplication destroys. Any question phrased about "some factor" survives — and now we know precisely how much of it survives: $|A \cup nA^{-1}|$ factorisations, $(\log_2 e - 1)/(\ell-1)^2$ bits, and, above the smallest cases, not one usable guess.

The number knows its own secret. It is simply not built to say it out loud.
