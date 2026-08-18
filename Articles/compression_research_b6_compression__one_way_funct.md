# The Price of a Shortcut: Why Compression Stops Exactly Where Cryptography Begins

## A wish, and its shadow

Everybody who has ever waited for a file to upload has had the same wish: *make it smaller*. And everybody who has thought about it for five minutes has met the same wall. There are $2^{n}$ binary strings of length $n$, but only $2^{n} - 1$ strings shorter than $n$. If your compressor never loses information, it cannot map $2^n$ different files into fewer than $2^n$ different codes. Somebody always gets a longer file. This is the pigeonhole principle, and it is the single most robust theorem in data compression: for any decoder $D$ whatsoever — any program, any lookup table, any oracle from beyond the stars — the number of objects that can be written with at most $s$ bits is at most
$$2^{s+1}-1 .$$

The interesting question is not whether you can beat the pigeonhole bound. You cannot. The interesting question is: **what does it cost to come close to it?** Because the bound says only that short descriptions are *scarce*, not that they are *hard to find*. Every string of length $1000$ that happens to be the first million digits of $\pi$ in binary has a description of a few dozen bits. Finding that description is another matter entirely.

This article is about the gap between scarcity and difficulty, and about two ideas people habitually reach for when they hit that gap:

1. **"Let's add randomness."** Maybe a compressor that flips coins can do better than a deterministic one — at least most of the time, at least on average.
2. **"Let's ask a simpler question."** Maybe deciding *whether* a short description exists is easier than actually producing one.

The results below say, in a way that can be made completely precise: **randomness buys you exactly the logarithm of your failure probability and not one bit more; and asking the easier question buys you nothing at all.** Beyond that, the only thing standing between you and perfect compression is the same thing that stands between an attacker and your bank password. Compression and cryptography turn out to be two views of a single wall.

## Randomness as a budget, not a miracle

Let us make the randomized compressor precise. Instead of a single decoder $D$, imagine a whole family $\{D_r\}_{r \in R}$ indexed by a finite set $R$ of random seeds. To compress an object $y$, you draw a seed $r$ at random and try to write $y$ as $D_r(p)$ for some short program $p$. This is a *Las Vegas* scheme: it never lies — whatever it outputs decodes correctly — but it may fail for unlucky seeds. Call $y$ *$s$-compressible under seed $r$* if some program of length at most $s$ decodes to $y$ under $D_r$, and write $G_s(y) \subseteq R$ for the set of seeds that work.

Now count. Each individual seed $r$ is just a deterministic decoder, so it can $s$-compress at most $2^{s+1}-1$ objects. Summing over all seeds and exchanging the order of summation gives the whole story in one line.

> **Las Vegas Counting Theorem.** For any seeded family $\{D_r\}_{r\in R}$ with $R$ finite, any target length $s$, and any finite set $T$ of objects,
> $$\sum_{y \in T} \bigl|G_s(y)\bigr| \;\le\; |R|\,\bigl(2^{s+1}-1\bigr).$$

That is a *budget*. The right-hand side is the total supply of (seed, short program) pairs; the left-hand side is the total demand. Randomness does not create description length out of nothing; it redistributes a fixed amount of it across the target set.

The consequences fall out immediately, and they are sharper than one might expect.

**Success probability is what you pay for — not seed length.** Suppose your scheme succeeds with probability at least $\delta = m/|R|$ on every object of $T$, meaning at least $m$ of the $|R|$ seeds work for each $y \in T$. Then $m\,|T| \le |R|(2^{s+1}-1)$, that is
$$|T| \;\le\; \frac{2^{s+1}-1}{\delta}.$$
Compare the deterministic ceiling $2^{s+1}-1$: the randomized scheme handles at most a factor $1/\delta$ more objects, a gain of $\log_2(1/\delta) + 1$ bits. Notice what does *not* appear in this formula: the number of random bits. You may consume a megabyte of entropy per file; if your success probability is $1/2$, you gain one bit. Randomness is not a resource measured in bits of seed. It is a resource measured in bits of *allowed failure*.

**Zero-error randomness is worthless.** Push $\delta$ to $1$ — demand that *every* seed work for every object — and the seed space cancels out completely: $|T| \le 2^{s+1}-1$. You are back at the deterministic pigeonhole ceiling exactly. A randomized compressor that is never allowed to fail is a deterministic compressor wearing a hat.

**The bound is essentially attained.** Nothing here is a weak estimate. Consider the *seeded prefix system*: a seed is a pair $(u,v)$ with $u \in \{0,1\}^{j}$ and $v \in \{0,1\}^{i}$, and the decoder simply glues its seed's first component onto the front of the program, $D_{(u,v)}(p) = u \, p$. If $y$ has length $j+s$, the seeds that work are exactly those whose $u$ equals the first $j$ bits of $y$ — precisely $2^{i}$ of the $2^{i+j}$ seeds, a success probability of exactly $2^{-j}$, whatever $i$ is. Every string of length $j+s$ is compressed to $s$ bits, and one checks that the resulting demand exceeds half the budget. So the counting theorem is tight up to a single bit — and the $i$ "wasted" random bits really are wasted, exactly as the theory predicts.

**Incompressible strings survive randomization.** For any seeded family at all, any $s$ and any $k$, there is a string of length $k+s+1$ whose success probability is strictly below $2^{-k}$. You cannot randomize away the hard cases; you can only make them rarer at a fixed exchange rate.

## Averages don't help either

A natural retreat: fine, the worst case is hopeless, but surely on *average* things look better? Real files are not adversarial. Here the counting argument is upgraded by a layer-cake trick. If $c$ is any complexity measure and you know, for each $s$ below some threshold $S$, that at most $\mathrm{bnd}(s)$ elements of $T$ satisfy $c(y)\le s$, then summing the sublevel-set bounds over $s$ yields
$$S\,|T| \;\le\; \sum_{y\in T} c(y) \;+\; \sum_{s<S}\mathrm{bnd}(s).$$
Feeding in the pigeonhole ceiling gives a Shannon-type theorem from pure counting, with no probability distribution in sight:

> **Average Description Length.** For any decoder $D$ and any set $T$ of at least $2^{n}$ objects, all describable, the average description length is at least $n-2$.

And with randomness, using the seeded ceiling instead:

> **Average Description Length with Randomness.** If the seed space has at most $2^{k}$ elements and every object of a set $T$ of size at least $2^n$ is describable under some seed, then the average of the best-seed complexity over $T$ is at least $n-k-3$.

So randomness saves at most $k + O(1)$ bits on average, exactly as it does in the worst case. The additive constant is not an artifact: the identity decoder over the set of *all* strings of length at most $m$ achieves the exact identity
$$\sum_{y} K(y) + 2\cdot 2^{m+1} = (m+1)\,2^{m+1} + 2, \qquad |T| + 1 = 2^{m+1},$$
so the average sits at $n-2+o(1)$ with $n=m+1$. The bound is asymptotically optimal; only the constant is up for negotiation.

There is even a clean *hierarchy*: with $2^{k}$ seeds the prefix system compresses **every** string of length $k+s$ down to $s$ bits, while with only $2^{k-1}$ seeds **no** family whatsoever — however ingenious — can do the same: some string of length $k+s$ is missed by all its seeds simultaneously. Each random bit is worth exactly one bit of compression, and no two are interchangeable.

## The other wall: finding the description

Everything so far is counting: true for all decoders, computable or not. Now impose *efficiency*, and the landscape changes character completely.

Fix a class $\mathcal C$ of "feasible" algorithms — think polynomial time — closed under the mild operations you would expect: guarding a computation with a test, running a bounded search. Say a function $f \in \mathcal C$ is **one-way** for $\mathcal C$ if it is honest (its preimages are not absurdly long) and no algorithm in $\mathcal C$ inverts it: for every $A \in \mathcal C$ there is some $y$ in the range of $f$ with $f(A(y)) \neq y$. The existence of such an $f$ is the foundational assumption of modern cryptography.

Here is the bridge. Read the one-way function $f$ *as a decoder*: a preimage of $y$ is a program for $y$. Then "find a shortest program for $y$ under $f$" is literally "invert $f$ at $y$, as efficiently in length as possible". A compression-search algorithm is an inverter. That is the whole trick, and it gives an exact equivalence: **one-way functions exist if and only if compression search is hard for some honest decoder.**

Now the question this cycle was built to answer: does randomness cross that line?

> **One-Way Functions Defeat Las Vegas Algorithms Totally.** Let $\mathcal C$ be closed, in addition, under the following natural operation: given a seeded algorithm and a finite list of seeds, run all of them and return the first output that passes verification. If $f$ is one-way for $\mathcal C$, then for every seeded algorithm whose every slice lies in $\mathcal C$ and every finite seed list $R$, there is a value $y$ in the range of $f$ on which **all** seeds fail at once.

The proof is a two-liner once stated properly. If for every $y$ *some* seed worked, then the "run all seeds, keep the first verified answer" algorithm is a deterministic inverter — it lies in the class by assumption — contradicting one-wayness. Note how much stronger the conclusion is than "the randomized algorithm fails with noticeable probability": there is an input on which it fails with probability *one*. This is the computational mirror of the counting fact that zero-error randomness gains nothing.

The same argument kills approximate compression: no seeded family produces, for any additive slack function $g$ you care to allow, a correct program within $g$ bits of optimal for every describable value. The obstruction is not to finding an *optimal* description. It is to finding *any* description at all.

And the equivalence closes both ways: Las Vegas inversion of all honest functions in the class is equivalent to plain deterministic inversion, and the existence of a one-way function is equivalent to the hardness of Las Vegas compression search. Randomness is worth exactly zero at the cryptographic boundary.

Two sanity checks keep this from being empty. In the class of *all* functions there is no one-way function and compression search is trivially easy — so the barrier really is the cryptographic assumption, not a hidden unconditional impossibility. And in the class of length-nondecreasing algorithms, the closure property holds and a genuine one-way function exists, so the theorem has real content there.

## The last escape route: just answer yes or no

One route remains. Producing a short program is a *search* problem, and search problems have the feature that answers are checkable: run the program, see if it outputs $y$. That checkability is exactly what let us collapse randomness to determinism. So try the *decision* version instead:

> Given $y$, a prefix $w$, and a length $n$: is there a string $p$ of length $n$ such that $D(w p) = y$?

A yes/no answer carries no certificate. You cannot verify it. It looks like precisely the kind of task where a Las Vegas algorithm might have room to breathe.

It does not, and the reason is beautiful. The decision oracle's answers cannot be checked one at a time — but they can be *composed into something that can be*. Walk down the binary tree of prefixes: start with the empty prefix and the correct total length $n$; ask the oracle whether extending by a $0$ keeps a solution alive; if yes take the $0$ branch, otherwise take the $1$ branch; repeat. After $n$ steps you hold a full program, and you can simply run it. The oracle's answers were unverifiable; the program they assemble is not.

Two refinements make this into a theorem about randomness.

> **Local Correctness Suffices.** The bit-by-bit reconstruction returns a shortest program for $y$ provided the decision oracle answers correctly about **the single string $y$** — its answers about all other strings may be arbitrary garbage.

The proof is a piece of mathematical sleight of hand: patch the oracle by replacing its answers about every string other than $y$ with the (non-effective, but perfectly well-defined) true answers. The patched oracle is globally correct, so the classical reconstruction theorem applies to it; and the patch never touches a query the reconstruction at $y$ actually makes, so the two runs are literally identical.

> **Las Vegas Deciders Derandomize Into Inverters.** Suppose that for every value $y$ in the range of $f$, at least one seed from a finite list carries a decision oracle that is locally correct at $y$. Then running the reconstruction under each seed and keeping the first program that verifies inverts $f$ deterministically.

> **Consequently: One-Way Functions Defeat Las Vegas Deciders.** For a one-way $f$ and any finite seed list, there is a value $y$ in the range of $f$ at which **every** seeded decision oracle answers some prefix query wrongly.

Randomizing the decision version of compressibility buys nothing. It hits the same wall, at the same place, for the same reason — because its answers, though individually uncheckable, compose into a certificate.

## The obstruction is computational, not informational

One might worry that these impossibility results are secretly about information: perhaps the decision oracle is asking for something that does not exist. It is not. The *classical* oracle — the one that simply says "yes" precisely when a suitable continuation exists — is a perfectly well-defined mathematical object, and fed into the reconstruction it produces a genuine shortest program for every describable string. Nothing information-theoretic stands in the way. The oracle exists; it merely fails to be efficient.

That gives the final picture, four failures and one success in a single frame. For a one-way $f$ in such a class, with any finite seed list: Las Vegas inversion fails totally on some input; Las Vegas exact compression search fails; Las Vegas approximate compression search fails for every slack; Las Vegas prefix-decision of compressibility fails; and yet the ideal, non-effective oracle solves the very same task perfectly. Every one of these failures is the cryptographic assumption in disguise.

## What it all means

Put the two halves together and you get a calibration, which is what this line of work was really after.

On the **information** side, randomness helps compression by exactly $\log_2(1/\delta)$ bits, where $\delta$ is the probability you allow yourself to fail — in the worst case, on average, and with the exchange rate exact to within one bit. Seed length is irrelevant. Zero-error randomness is worth nothing.

On the **computation** side, randomness helps by exactly nothing. Every task in the compression dictionary — produce a shortest program, produce an approximately shortest program, produce any valid program, decide whether a program of a given length exists — sits at precisely the same level of difficulty as inverting a one-way function, and stays there when you allow coin flips.

The moral for anyone designing a compressor is bracing. If your scheme is allowed to fail one time in a thousand, you may hope for about ten extra bits; you should not hope for eleven, and you should not hope that a longer seed will change the answer. And if your scheme aims to be *optimal* — to find the genuinely shortest description of arbitrary data — then you are not writing a compression algorithm at all. You are writing a universal codebreaker. The security of every deployed cryptosystem is a bet that you will fail.

That is a strange and rather wonderful place for the pigeonhole principle to end up.
