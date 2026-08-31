# The Tree That Refuses to Give Directions

## A perfect map, an unreadable address

Every right triangle with whole-number sides — $3,4,5$; $5,12,13$; $8,15,17$ — has a home. Not a metaphorical home: an exact, unique address in a single infinite family tree that contains every primitive Pythagorean triple exactly once, and nothing else.

The tree is built from pairs. Write a primitive triple as
$$(m^2 - n^2,\; 2mn,\; m^2 + n^2),$$
where $m > n \ge 1$ are coprime and of opposite parity. Call such a pair $(m,n)$ a **node**, and call $N = m^2 + n^2$ its **hypotenuse**. The root is $(2,1)$, the triple $(3,4,5)$. Each node has exactly three children:
$$A:(m,n) \mapsto (2m-n,\, m), \qquad B:(m,n)\mapsto (2m+n,\, m), \qquad C:(m,n)\mapsto (m+2n,\, n).$$
Start at $(2,1)$, apply these three maps forever, and you sweep out every primitive triple, each exactly once. That is a classical fact, and it is beautiful: the chaotic-looking set of Pythagorean triples is really a perfectly regular ternary tree, free on three generators.

Regular in the strongest sense. Distinct words in the alphabet $\{A,B,C\}$ always land on distinct nodes, so every node carries a unique **ascent word** — the sequence of turns that leads to it from the root. The level at depth $h$ has exactly $3^h$ nodes, and each of the three letters is worn by exactly a third of them. The tree is a perfect ternary filing cabinet, and each triple has a filing code.

Here is the question that this work answers. You are handed a number $N$ — say a big semiprime, a product of two primes each congruent to $1$ modulo $4$, the kind of number that sits at a node of the tree because it is a sum of two coprime squares. You would like to *find* its node: to climb from the root, one turn at a time, toward the address of $N$. Each step is a three-way choice. If you could guess the correct letter reliably and cheaply — from some spectrum, some transform, some statistic computed from $N$ alone — you would walk to the node in a few dozen steps, read off $m$ and $n$, and with them the Gaussian factorisation of $N$, and with *that*, its prime factors.

The tree, in other words, is a candidate shortcut to factoring. The result reported here is that the shortcut is sealed shut, at four independent strengths, and that the economics of the remaining loophole are unforgiving.

## The one bit that matters

The whole question turns on a single quantity. Given a node $(m,n)$, the **ascent letter** records which branch produced it. It is determined by the ratio $m/n$ alone:
$$\text{letter}(m,n) = \begin{cases} A & \text{if } m < 2n,\\ B & \text{if } 2n < m < 3n,\\ C & \text{if } 3n < m.\end{cases}$$
(The excluded ratios $m=2n$ and $m=3n$ cannot occur at a node except at the root.) The letter is *the* piece of positional information: if you can read the letter, you can invert one step, take the parent, and repeat. A perfect letter oracle plus $O(\sqrt{N})$ patience takes you all the way home.

So: is the ascent letter computable — even noisily, even partially — from $N$?

## Strength one: every dial with a modulus is blind

The first family of probes to try are **residue dials**: anything computed from $N$ modulo some fixed number $M$. The idea is natural — the arithmetic of sums of two squares is governed by congruences, so surely the residue knows something about the position.

It knows nothing. Fix any modulus $M \ge 1$. Choose any even $n \ge 2$ that is a multiple of $M$, and look at the three nodes
$$(n+1,\,n), \qquad (2n+1,\,n), \qquad (3n+1,\,n).$$
Their ratios are just below $2$, just above $2$, and just above $3$, so their letters are exactly $A$, $B$, and $C$. And their hypotenuses are
$$2n^2+2n+1,\qquad 5n^2+4n+1,\qquad 10n^2+6n+1,$$
every one of which is congruent to $1$ modulo $M$, because $M$ divides $n$. Three nodes, three different letters, one residue.

Hence no function whatsoever of $N \bmod M$ can compute the ascent letter — for *every* $M$, and (taking $n = 2Mt$) at arbitrarily large scale, so the failure is not an artefact of small numbers. Whatever a residue dial reports, it reports the same thing for an $A$, a $B$, and a $C$.

## Strength two: Gauss sums are residue dials in disguise

The probes that actually motivated this programme were more sophisticated: **magnitude spectra** built from quadratic Gauss sums,
$$G_M(N) = \sum_{x \bmod M} e^{2\pi i N x^2 / M},$$
evaluated at a smooth modulus such as $M = 720720 = 2^4\cdot 3^2\cdot 5\cdot 7\cdot 11\cdot 13$. These objects are genuinely subtle — they encode quadratic-reciprocity data, and their magnitudes fluctuate in an intricate way with $N$.

But $G_M(N)$ depends on $N$ only through $N \bmod M$: replacing $N$ by $N + kM$ leaves every summand untouched. So a Gauss-sum probe, whatever readout you apply to it — magnitude, phase, argument, a learned classifier on top — is a residue dial, and Strength One kills it. The same holds for an entire *battery* of Gauss sums at many moduli at once: if all the moduli divide a common $M$, the joint readout is still a function of $N \bmod M$, and still blind.

This upgrades a purely empirical finding — "the spectra carry no positional signal" — into a theorem about what they *can* carry: exactly zero.

## Strength three: the structural sensors are literally constant

A third family of probes reads structure rather than arithmetic: the parities of the three sides, sign counts, bracket patterns, the quadratic form. These fail for the most humiliating reason available. At *every* node, the parity profile of the triple $(m^2-n^2,\,2mn,\,m^2+n^2)$ is exactly
$$(\text{odd},\ \text{even},\ \text{odd}),$$
and the Lorentz-type form
$$(m^2-n^2)^2 + (2mn)^2 - (m^2+n^2)^2$$
vanishes identically — it is the Pythagorean identity itself. A sensor that returns the same value at every node has zero mutual information with anything, the letter included. Measured empirically, these channels report a mutual information of $0.000000$ bits; the identities say the zero is exact, not a rounding of something small.

## Strength four: even the magnitude itself is blind

The last and strongest seal removes the modulus entirely. Could there be a probe that reads $N$ itself — its size, its logarithm, its decile in some distribution — and predicts the letter better than chance?

No, and the obstruction is a collision. For every $t \ge 1$, the two nodes
$$(20t-1,\ 10t+2) \qquad\text{and}\qquad (20t+1,\ 10t-2)$$
have the *same* hypotenuse,
$$(20t-1)^2 + (10t+2)^2 = (20t+1)^2 + (10t-2)^2 = 500t^2 + 5,$$
and *different* letters: the first has $m < 2n$ (letter $A$), the second has $2n < m < 3n$ (letter $B$). The smallest case is famous enough to be checked by hand:
$$505 = 19^2 + 12^2 = 21^2 + 8^2 = 5\cdot 101 .$$
A single number, two legitimate addresses, two different first turns. Therefore *no* function of $N$ — monotone, non-monotone, learned, exact, it makes no difference — agrees with the ascent letter at every node. The letter is not a function of the hypotenuse, full stop. (The same collision shows the odd leg is not a function of the hypotenuse either.)

A softer version kills the "log-magnitude decile" probes that survived the earlier rounds. For every $X \ge 661$ and each of the three letters, there is a node carrying that letter whose hypotenuse lies in the window $[X, 2X)$ — witnessed by the three explicit families
$$2m^2+2m+1\ (A), \qquad 20u^2+8u+1\ (B), \qquad 68u^2+16u+1\ (C),$$
each of which grows slowly enough to drop a value into every dyadic window. Knowing the order of magnitude of $N$ does not even restrict which letters are *possible*, let alone shift their odds.

## Where the information actually lives

If the letter is invisible from $N$, where is it? In the factorisation — and the collisions say exactly how.

Two representations of the same number as a sum of two squares come from the two Brahmagupta–Fibonacci compositions of a factorisation:
$$(a^2+b^2)(c^2+d^2) = (ac-bd)^2 + (ad+bc)^2 = (ac+bd)^2 + (ad-bc)^2 .$$
Take $(a,b)=(2,1)$, so $a^2+b^2 = 5$, and $(c,d) = (k,1)$ with $k = 10t$. The two compositions give precisely $(2k-1,\, k+2)$ and $(2k+1,\, k-2)$ — the two colliding nodes above. The ambiguity in the address is *identical* to the ambiguity in which composition you take, and resolving it requires knowing $a,b,c,d$: that is, knowing how $N$ splits.

This is the sharp shape of the closure. Positional information exists — empirically the best factor-derived oracle tested peaks at about $0.48$ bits per step — but every route to it that does not already know the factorisation is provably closed. You may have the answer only if you already have the answer.

## Two conjectures that died

Two natural attempts to rescue the programme were tried and both turned out to be false; the refutations are now theorems.

The first was the **representation-orbit conjecture**: perhaps a magnitude collision *always* splits the letters, so that "does $N$ have two representations?" is itself the signal. It does not. The Sophie Germain identity
$$u^4 + 4 = (u^2 - 2u + 2)(u^2 + 2u + 2)$$
gives, for odd $u$, the two distinct nodes $(u^2-2,\,2u)$ and $(u^2,\,2)$ of the same composite number $u^4+4$ — and both have letter $C$, since both ratios exceed $3$. The smallest instance is
$$2405 = 47^2 + 14^2 = 49^2 + 2^2,$$
and semiprimes are not spared: $50629 = 197\cdot 257 = 223^2 + 30^2 = 225^2 + 2^2$, again with both letters $C$. Worse, both behaviours occur above every bound — there are at least $\sqrt{(X-5)/500}$ letter-splitting collisions below $X$ and at least on the order of $X^{1/4}$ letter-preserving ones — so "does $N$ admit a collision?" is itself letter-free information.

The second was the **sharp two-adic cap**. Along a different tree, Price's, the natural sensor is the $2$-adic valuation $v_2(p+q)$ of the sum of two factors. Its first two letters obey exact laws: for odd $p,q$,
$$v_2(p+q) = 1 \iff pq \equiv 1 \pmod 4, \qquad v_2(p+q) = 2 \iff pq \equiv 3 \pmod 8, \qquad v_2(p+q)\ge 3 \iff pq \equiv 7 \pmod 8 .$$
So the first two Price letters are a pure dial on $N \bmod 8$ — beautifully exact, and beautifully useless, because being a function of $N$ they are already covered by Strength Four. The hope was that the *third* letter escapes. It escapes in the wrong direction: it is not a function of $N$ at all. For every $m \equiv 7 \pmod{16}$ the number $9m$ factors as $9\cdot m$ and as $3\cdot(3m)$, and the two factorisations disagree at position $2$ — the smallest case being $63 = 9\cdot 7 = 3\cdot 21$ with $v_2(16)=4$ but $v_2(24)=3$. And the conjecture that the sensor at least *discriminates* is false too: for every prime $q \equiv 1 \pmod{16}$, the semiprime $N=7q$ has $v_2(a+b) = 3$ for *every* factorisation $N = ab$. By Dirichlet's theorem such $N$ exist above every bound; the smallest is $119 = 7\cdot 17$, where $v_2(120) = v_2(24) = 3$. The sensor is constant on an infinite family — blind by pure repetition.

## The economics of climbing anyway

Suppose you had an imperfect oracle: a probe that guesses the correct letter with probability $a$ at each step, independently. Climb $h$ levels, restarting from scratch after any failure. Success needs all $h$ guesses right, so the expected number of nodes you visit is the **restart energy**
$$E(h,a) = \frac{h}{a^{h}} .$$
This little formula does a lot of work. It is at least $h$ (you must take $h$ steps); it strictly increases with $h$ whenever $a<1$; it strictly decreases as accuracy improves; and the budget constraint $E(h,a)\le c$ is exactly $h \le c\,a^{h}$.

Two consequences settle the question of whether a noisy oracle could ever help.

First, the **threshold against brute force** is exactly $1/3$, the reciprocal of the branching number. If $a > 1/3$, then for all large $h$ the guided ascent costs less than the $3^h$ nodes of an exhaustive sweep of level $h$; if $a < 1/3$, it eventually costs more. At $a = 1/2$ the guided ascent wins at every single depth, since $h\,2^h < 3^h$ for all $h$. So a probe must beat one-in-three — random guessing — just to be worth switching on.

Second, and far more demanding, is the **competitive threshold** against the incumbent method. To reach depth $30$ within a realistic budget of $3000$ node visits, the required accuracy $\alpha^\ast$ satisfies
$$0.85 < \alpha^\ast \le 0.86 ,$$
because $E(30, 0.85) > 3000$ while $E(30,0.86) \le 3000$, and $E$ is decreasing in accuracy so *every* accuracy at most $0.85$ blows the budget. Against this, the best measured positional signal available even to a factor-derived oracle peaks near $0.48$ bits — and every probe tested that does not use the factorisation is, by the four seals above, exactly $0$ bits.

Two further facts frame the picture. Errors **compound**: with per-step accuracy $a<1$ the chance of a clean height-$h$ ascent is $a^h$, which decays geometrically to zero and eventually falls below any fixed level a saturating "class hint" could provide. And the alternative is not cheap: exhaustive search of the ternary tree to depth $30$ visits $(3^{31}-1)/2 > 10^{14}$ nodes. There is no comfortable middle: either you have a sharply accurate oracle, or you are counting to a hundred trillion.

The lower bounds are as clean as the arithmetic. Because the letters are unreadable from $N$, an adversary is free to place the target anywhere on level $h$; any searcher that visits fewer than $3^h$ nodes provably misses one, and if its budget is below half the level it misses a strict majority. Adaptivity does not help: a searcher issuing $k < 3^h$ guessed ascent words always leaves some depth-$h$ word unguessed, so certainty costs at least $3^h$ guesses. And depth is expensive to reach in the first place — along the pure-$A$ spine, the word of length $k$ lands on $(k+2,k+1)$, whose hypotenuse is $2k^2+6k+5$. Depth there grows like $\sqrt{N}$, not $\log N$. In general a word of length $L$ read from the root reaches a node whose leading coordinate lies between $2+L$ and $2\cdot 3^L$; both ends are attained.

## What would reopen the case

A closure worth the name says precisely what it does not cover. This one leaves exactly one door, and specifies its dimensions: a probe that is

* of none of the four sealed kinds — not a function of $N \bmod M$ for any $M$, not a Gauss-sum readout, not a structural constant, and **not a function of $N$ at all**;
* non-monotone in $|N|$ (the collision families forbid anything that only sees magnitude);
* accurate above $\alpha^\ast \approx 0.85$ per step, at a cost of at most $3000$ visit-equivalents.

Since the letter provably is not a function of $N$, any such probe must consume side information — factorisation data, an auxiliary oracle, a quantum resource. The geometry does contain positional content, up to roughly half a bit per step by the best measurement available. Nothing cheap reads it.

## The moral, and a methodological one

There is an old temptation in computational number theory: a beautiful combinatorial structure sits next to a hard problem, and it feels as if the structure must be a lever. The Berggren tree is exactly such a structure — free, ternary, complete, with a perfectly defined address for every triple. And it is a lever for nothing, because the map from address to number destroys the address. Two turns of the tree, two nodes, one number. All the elegance is in the forward direction.

The programme also produced a methodological lesson worth more than the negative result. Early rounds "detected" signal by comparing a sensor against a **row-shuffle null** — permuting labels and re-measuring. For a deterministic function of $N$, this is the wrong null: shuffling breaks the correlation with $N$ itself, so any sensor that merely tracks magnitude scores as informative. The correct null conditions on magnitude, comparing only within a decile of $\log N$. Under that null, the spectral summaries that had looked promising collapsed to what the theorems say they are — mirrors of $|N|$, carrying nothing about position. Derivation before validation; and when a smoke run behaves suspiciously well, treat it as a mechanism detector, not a discovery.

The tree keeps its perfect addresses. It just will not tell you yours.
