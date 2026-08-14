# The Sequence That Refuses to Talk

## How a stream of numbers can carry a secret weakness and reveal absolutely nothing about it

Imagine you are handed a locked box. You know that some boxes in the pile have a manufacturing flaw: a particular key, cut in a particular way, opens them instantly. Other boxes don't have the flaw, and the same key does nothing. Your job is to sort the pile — flawed from sound — *without trying the key*. You may shake the box, weigh it, listen to it, photograph it under any light you like. You may build a machine-learning classifier from a thousand such measurements.

This article is about a mathematical version of that puzzle, and about a clean and slightly unnerving answer: for one of the most-studied "manufacturing flaws" in all of cryptography, no amount of shaking, weighing, or listening helps. The flaw is genuinely there. It is genuinely exploitable. And the only thing that sees it is the very key you were forbidden to try.

---

## The flaw: smooth numbers and a 50-year-old attack

Modern public-key cryptography leans on a simple asymmetry: multiplying two large primes $p$ and $q$ to get $N = pq$ is easy, but recovering $p$ and $q$ from $N$ is hard. "Hard," though, is not "hard for every $N$." Some semiprimes are catastrophically weak, and the oldest famous example is *Pollard's $p-1$ method*, published in 1974.

The idea is one line of group theory. Fermat's little theorem says that for any prime $p$ and any base $a$ not divisible by $p$,
$$a^{p-1} \equiv 1 \pmod p.$$
So if $M$ is any multiple of $p-1$, then $a^{M} \equiv 1 \pmod p$, which means $p$ divides $a^{M} - 1$. Compute
$$g = \gcd\!\left(a^{M} - 1,\; N\right)$$
and $p$ falls out — even though you never knew $p$.

The catch is choosing $M$ without knowing $p-1$. Pollard's trick: guess that $p-1$ is *smooth*, i.e. built only out of small prime factors, and take
$$M = \operatorname{lcm}(1, 2, \ldots, B)$$
for some bound $B$. If every prime power dividing $p-1$ is at most $B$, then $p - 1 \mid M$ automatically and the attack succeeds. If $p-1$ has a big prime factor, $M$ misses it and the gcd comes back as $1$ — a useless answer.

Call a semiprime **SMOOTH** if one of its prime factors $p$ has $p-1$ smooth, and **GENERAL** otherwise. SMOOTH keys are broken in milliseconds. GENERAL keys shrug the method off. The two classes are, from the attacker's point of view, night and day.

Here is a concrete matched pair we will carry through the whole story. Take $B = 20$, so
$$M = \operatorname{lcm}(1,\ldots,20) = 232\,792\,560 = 2^4\cdot 3^2\cdot 5\cdot 7\cdot 11\cdot 13\cdot 17\cdot 19,$$
and set
$$N_{\text{smooth}} = 1009 \cdot 1019 = 1\,028\,171, \qquad N_{\text{general}} = 1019 \cdot 1039 = 1\,058\,741.$$
For the first, $1009 - 1 = 1008 = 2^4\cdot 3^2\cdot 7$ divides $M$ exactly, so $\gcd(2^{M}-1, N_{\text{smooth}}) = 1009$ — a proper, nontrivial factor, handed over on a plate. For the second, $1019 - 1 = 2\cdot 509$ and $1039 - 1 = 2\cdot 3\cdot 173$; the primes $509$ and $173$ are far past the bound $B=20$, so $\gcd(2^{M}-1, N_{\text{general}}) = 1$ and the method learns nothing.

Two numbers of nearly identical size, built from primes of the same bit-length. One is broken. One is not.

---

## The tempting shortcut

Running the $p-1$ method costs a full modular exponentiation with an enormous exponent — for realistic bounds, $M$ has millions of bits. Someone auditing a large keyring, or a cryptanalyst triaging candidate targets, would love a *cheap screen*: a quick test that flags the likely-SMOOTH keys so the expensive attack is only run where it will pay off.

The obvious place to look is the **mod-exponential sequence** itself:
$$s_0, s_1, s_2, \ldots, \qquad s_x = a^x \bmod N.$$
This sequence is the beating heart of the attack — the attack is literally one very deep term of it. It is cheap to generate: each step is one multiplication. And it is a rich object; the sequence of $2^x \bmod N$ looks, to the naked eye, like a jumble of pseudorandom numbers with a great deal of internal structure.

So: take a short window, say the first $m = 256$ terms. Extract every statistic you can think of — how many distinct values appear, how long until the sequence repeats a value, the balance of high bits, the distribution of consecutive differences, autocorrelations, spectral flatness of the resulting waveform, the longest run. Feed all of it to a classifier. Does the SMOOTH class look different from the GENERAL class?

An experiment on $36$ matched pairs, with $42$ such features across bases $2$, $3$, and $5$, answered with a resounding **no**. Under a permutation test the largest observed standardized difference between classes was $0.473$, against a null mean of $0.495$ — $p = 0.502$, the very definition of nothing. A cross-validated logistic classifier scored an area under the ROC curve of $\mathrm{AUC} = 0.500$: precisely chance, as if the labels had been assigned by coin flip. Meanwhile, on the very same instances, the $p-1$ method at $B=100$ factored $35$ of the $36$ SMOOTH cases and $0$ of the $36$ GENERAL cases.

A hard null is usually where a research programme goes to die. Here it turned out to be where the mathematics began — because the null is not a fact about that dataset. It is a theorem.

---

## The structure theorem: a window is a clock

The key realization is to ask what a window of the sequence actually *is*, combinatorially.

Fix a base $a$ coprime to $N$, and let $d = \operatorname{ord}_N(a)$ be the multiplicative order of $a$ modulo $N$ — the least positive $d$ with $a^d \equiv 1$. Then:

> **Collision Law.** For all indices $x, y$, we have $a^y \equiv a^x \pmod N$ if and only if $y \equiv x \pmod d$.

This is elementary — it is just the statement that the powers of $a$ cycle with period exactly $d$ — but its consequences are severe.

Define the **pattern word** of the sequence: for each index $x$, let $\mathrm{first}(x)$ be the *smallest* index carrying the same value as $x$. The pattern word records exactly which positions of the window collide with which, and nothing else — it is the "shape" of the window with all the actual numerical values erased.

> **Structure Theorem.** For every $x$, $\;\mathrm{first}(x) = x \bmod d$.

That is the whole story. The collision structure of a mod-exponential sequence is *literally* the residue map modulo the order. Nothing else about $N$, about $p$, about $q$, about the factorization of $p-1$ into primes — nothing survives into the pattern.

Now truncate to a window of length $m$. Inside the window, indices only run from $0$ to $m-1$, so $x \bmod d$ and $x \bmod \min(m,d)$ agree everywhere. Hence:

> **Truncation Theorem.** The pattern word of a length-$m$ window depends on $(a, N)$ only through the single integer $\min(m, \operatorname{ord}_N(a))$.

A window of length $m$ is a clock with $\min(m,d)$ marks on its face. That is all it is.

---

## Blindness, and an information bound with teeth

Two immediate corollaries, and they are the whole null result.

> **Blindness Theorem.** If two instances $(a_1, N_1)$ and $(a_2, N_2)$ satisfy $\min(m, \operatorname{ord}_{N_1}(a_1)) = \min(m, \operatorname{ord}_{N_2}(a_2))$, then their length-$m$ pattern words are *identical*. Consequently, for *every* function $F$ whatsoever on pattern words, $F$ returns the same value on both.

Not "approximately the same." Identical. There is no clever feature to be discovered, because there is nothing left to be a function *of*.

> **Information Bound.** Across all bases $a$ and all moduli $N$, there are at most $m+1$ distinct length-$m$ pattern words in existence.

The proof is a one-liner given the truncation theorem: the pattern word is determined by $\min(m,d) \in \{0,1,\ldots,m\}$. So the entire information content of a length-$m$ window's collision structure is at most $\log_2(m+1)$ bits. For $m = 256$ that is about $8$ bits — against the $\Theta(\log N)$ bits, hundreds or thousands of them, that you would need just to *name* a factor of $N$. The channel is not narrow; it is essentially closed.

There is a pigeonhole restatement that makes the poverty vivid:

> **Pigeonhole Corollary.** Among any $m+2$ odd moduli, two of them already have *identical* length-$m$ windows (as combinatorial objects). Hence no feature of the window can be injective on such a set.

A length-$256$ window cannot even tell $258$ moduli apart. Asking it to detect a subtle arithmetic property of $p-1$ is not ambitious; it is arithmetically impossible.

---

## Why $\mathrm{AUC} = 0.500$ was never a measurement

Machine-learning practice evaluates a classifier by its area under the ROC curve. Given a real-valued score $f$, a set $S$ of positives and a set $G$ of negatives, $\mathrm{AUC}$ is the probability that a random positive outranks a random negative, with ties counted at weight $\tfrac12$:
$$\mathrm{AUC}(S,G,f) = \frac{1}{|S|\,|G|}\sum_{s \in S}\sum_{g \in G}\Big[\mathbf{1}\{f(g) < f(s)\} + \tfrac12\mathbf{1}\{f(g) = f(s)\}\Big].$$

The bridge to our structure theory is embarrassingly short:

> **AUC Bridge.** If $f$ takes the same value on every positive as on every negative, then $\mathrm{AUC}(S,G,f) = \tfrac12$ exactly.

Every pair is a tie; every tie contributes $\tfrac12$; the sum is $|S||G|/2$. Combine with the Blindness Theorem and you get the punchline:

> **No-Free-Lunch Theorem.** Let $F$ be *any* real-valued statistic of the pattern word of a length-$m$ window. On any set of moduli whose base-$2$ orders all meet or exceed $m$, and under *any* partition of that set into positives and negatives — in particular the SMOOTH/GENERAL partition, whose two halves genuinely behave differently under the $p-1$ method — the classifier scoring by $F$ has $\mathrm{AUC} = \tfrac12$, exactly.

The experiment's $0.500$ was not a sampling artefact, not a small-data disappointment, not a hyperparameter one tweak away from $0.62$. It is the theorem's value, to all decimal places, forever.

Return to the matched pair. Both $N_{\text{smooth}} = 1009\cdot 1019$ and $N_{\text{general}} = 1019\cdot 1039$ are divisible by the prime $1019$, and the base-$2$ order modulo $1019$ divides $1018 = 2 \cdot 509$ while not dividing $2$ (since $2^2 = 4 \not\equiv 1$), so $509$ divides it — the order is at least $509$, in fact exactly $1018$. Since the order modulo a divisor divides the order modulo the whole modulus, both $\operatorname{ord}_{N_{\text{smooth}}}(2)$ and $\operatorname{ord}_{N_{\text{general}}}(2)$ exceed $256$. Therefore both length-$256$ windows have the *same* pattern word — the identity on $\{0,\ldots,255\}$, no collisions at all, $256$ distinct values in each. Every collision feature you can name returns the same number on the broken key and the sound one. $\mathrm{AUC} = \tfrac12$.

---

## It is not a coincidence, and it is not just $256$

Two upgrades stop this from looking like a lucky example.

**First: infinitely many such pairs, at every window length.** The moduli $N$ that are odd multiples of a fixed odd prime $p$ form an infinite family, and every one of them inherits a base-$2$ order at least as large as $\operatorname{ord}_p(2)$. So if $\operatorname{ord}_p(2) \geq m$, the entire infinite family has one and the same length-$m$ window. And such a $p$ always exists, by an argument of one line: since $p$ divides $2^{\operatorname{ord}_p(2)} - 1$, we get
$$p < 2^{\operatorname{ord}_p(2)},$$
so a prime larger than $2^m$ automatically has base-$2$ order exceeding $m$, and primes are infinite. Conclusion: **for every window length $m$ there is an infinite family of moduli, containing both smoothness classes, on which every real statistic of the length-$m$ window scores exactly chance.** Lengthening the window does not chip away at the barrier; the barrier moves with you.

**Second: the phenomenon has nothing to do with factoring.** Nowhere in the structure theorem did we use that the modulus is a semiprime, or a modulus at all. Let $g$ be any element of finite order in *any* monoid, and record the collision pattern of the orbit $g^0, g^1, g^2, \ldots$. The pattern is again $x \mapsto x \bmod \operatorname{ord}(g)$; two elements of two entirely different algebraic structures with equal order have literally the same orbit pattern. Elliptic-curve point multiples, function-field analogues, matrix powers — all inherit the blindness. The result is not a fact about $\mathbb{Z}/N\mathbb{Z}$; it is a fact about cyclic prefixes.

---

## Past the pattern: what the *values* give away

Everything so far erased the numerical values and kept only the collision shape. What if a feature reads the actual integers — top-bit balance, adjacent differences, the histogram of values?

Over a **full period** there is a clean answer, and it is again a blindness statement. The base of a mod-exponential sequence is not canonical: if $t$ is coprime to $d = \operatorname{ord}_N(a)$, then $a^t$ generates the same cyclic subgroup $\langle a \rangle$ and its orbit is just a reindexing of the original one.

> **Value-Level Invariance.** For $\gcd(t,d) = 1$, the set of values visited by a full period of $a^t$ equals the set of values visited by a full period of $a$. Consequently every *symmetric* feature of the full-period window — the histogram, the maximum, the top-bit count, anything reading the window as a set — is a function of the subgroup $\langle a \rangle$ alone, never of which generator you picked. And the one number the full-period value set does reveal is its cardinality, which is exactly the order $d$.

So even at the value level, over a full period, the only readable invariant is again the order. And here the mechanism closes the loop. For coprime $p,q$, the Chinese Remainder Theorem gives
$$\operatorname{ord}_{pq}(a) = \operatorname{lcm}\big(\operatorname{ord}_p(a), \operatorname{ord}_q(a)\big).$$
The local order $\operatorname{ord}_p(a)$ divides $p-1$ — but its *size* says nothing about whether $p-1$ factors into small primes or has one enormous prime factor. A large order is perfectly compatible with either class. The single channel the sequence leaves open is precisely the channel that is smoothness-agnostic.

(One honest caveat: value-level features of a *short* window — the first $256$ terms, with $256$ far below the period — are not covered by these theorems. The two windows in our matched pair really do differ as integer sequences: one has $122$ high bits set, the other $124$. Their statistical nullity is, so far, an experimental finding rather than a proved one. It is the sharpest open question this work leaves behind.)

---

## The exact price of the weakness

If the sequence tells you nothing, what *does* tell you something? There is a precise answer, and it is unforgiving.

> **Exact Criterion.** For any base $a \geq 1$, any $r$, and any exponent $M$: $\;r \mid a^{M} - 1$ if and only if $\operatorname{ord}_r(a) \mid M$.

Read this carefully. The quantity that distinguishes SMOOTH from GENERAL is exactly one bit: does the local order divide $M$? And that bit is not stored anywhere in the sequence's short prefix — it is the answer to a divisibility question about an exponent of astronomical size. Extracting it requires computing $a^M \bmod N$. But computing $a^M \bmod N$ *is* Pollard's $p-1$ method. There is no shortcut, because the shortcut and the destination are the same object.

This closes the loop with three general obstructions that any proposed "self-hint" for factoring must clear. A statistic computable from $N$ alone is symmetric in the two prime factors, so it cannot break the tie between them. A statistic that compresses the instance to $O(\log m)$ bits cannot name a factor requiring $\Theta(\log N)$ bits — and we proved the window's collision structure compresses to at most $\log_2(m+1)$ bits, class-independently. And a statistic that does succeed turns out to be a known method in disguise — here, quite literally, the $p-1$ method itself.

---

## What a null result is worth

There is a folk belief that negative results are the consolation prize of research. This one argues the opposite. The empirical finding — "our classifier got $\mathrm{AUC} = 0.500$" — is worth roughly nothing on its own; the next person tries $84$ features instead of $42$, or a transformer instead of logistic regression, and the cycle repeats. The theorem — "every real statistic of a length-$m$ window scores exactly $\tfrac12$ on an infinite family containing both classes, for every $m$" — retires the question. Nobody has to run that experiment again.

And the retirement is *sharp*, which is the mark of a good barrier. It does not say "smoothness is undetectable." Smoothness is extremely detectable: run the $p-1$ method. It says the detection is confined to exactly one computation, and identifies the confining mechanism (the pattern is a clock; the clock's only reading is the order; the order is an lcm of local orders whose *size* is decoupled from their *factorization*).

That is the shape of the best negative results in the subject. They do not merely close a door. They hand you a map of the wall, marked with the one place a door could ever be — and a note that someone built it there in 1974.
