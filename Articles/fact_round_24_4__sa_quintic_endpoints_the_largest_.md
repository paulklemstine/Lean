# The Prime That Refuses to Talk

## How a fifth-degree equation decides exactly how much a prime number is allowed to tell you

There is a game that number theorists have been playing, in one form or another, since Gauss. Pick a polynomial with whole-number coefficients — say
$$f(x) = x^5 - x - 1.$$
Now pick a prime $p$, and ask what happens to $f$ when you do arithmetic *modulo* $p$, that is, when you keep only the remainder after dividing by $p$. Over the ordinary integers $f$ is stubbornly irreducible: it cannot be broken into smaller polynomial pieces. But modulo a prime, it very often shatters.

Modulo $2$ it stays in one piece. Modulo $3$ it splits as a quadratic times a cubic. Modulo $19$ something strange happens — it acquires a repeated factor. And modulo $1\,234\,567\,811$ (say) it does something too, and if you had to bet in advance on *which* something, you would want to know the odds.

The shape of the shattering — is it one irreducible quintic? a linear times a quartic? five separate linear factors? — is called the **splitting type** of $p$. There are exactly seven possible shapes, one for each way of writing $5$ as a sum of positive whole numbers:
$$5,\quad 1+4,\quad 2+3,\quad 1+1+3,\quad 1+2+2,\quad 1+1+1+2,\quad 1+1+1+1+1.$$

Here is the question this article is about, and it is a question about *information*, not about any single prime:

> Suppose I tell you the remainder of $p$ after dividing by some fixed number $m$ — I tell you $p \bmod m$, and nothing else. How much have I told you about the splitting type of $p$?

The answer, it turns out, is decided entirely by a piece of abstract algebra attached to the polynomial, and it can be computed to the last decimal place. For $x^5 - x - 1$ the answer is **exactly one bit** — a single yes-or-no — no matter how cleverly you choose $m$, no matter how large you let it be, and no matter how many primes you are allowed to multiply together first. And for a sibling polynomial, $x^5 + 20x + 16$, the answer is **exactly zero bits**. Not "small". Not "asymptotically negligible". Zero, provably, with nothing to tune.

That contrast — the largest information source in the family transmitting one bit, and its closest relative transmitting none at all — is the subject of what follows.

## Frobenius: the dictionary between primes and permutations

The reason the question has a clean answer is a nineteenth- and twentieth-century idea of extraordinary reach: to a polynomial one attaches a *symmetry group*, the group of all the ways its five roots can be permuted without disturbing any algebraic relation among them. For $x^5 - x - 1$ this group is as big as it can possibly be: all $120$ permutations of five objects, the symmetric group $S_5$. For $x^5 + 20x + 16$ it is only half as big: the $60$ *even* permutations, the alternating group $A_5$.

The bridge to primes is a construction of Frobenius. Each prime $p$ (avoiding a finite bad set) is assigned an element of that symmetry group — its **Frobenius element** — and the miracle is that the splitting type of $f$ modulo $p$ is precisely the *cycle type* of that permutation. If the Frobenius element is a $5$-cycle, $f$ is irreducible mod $p$. If it is a transposition times nothing, $f$ has three roots and one quadratic factor. The arithmetic question has become a question about permutations.

The Chebotarev density theorem completes the dictionary: as $p$ ranges over all primes, the Frobenius element is *equidistributed* over the group. Each conjugacy class gets a share of the primes exactly proportional to its size. So the long-run statistics of splitting types are not empirical mysteries; they are conjugacy-class counts in a finite group, computable by hand.

That is why we may replace the infinitely many primes by a finite, completely explicit probability space: the group itself, with every element equally likely. Everything below happens in that space.

## Counting the bits

Take the $120$ permutations of five letters and sort them by cycle type. The identity is alone ($1$ element). Transpositions: $10$. Double transpositions: $15$. Three-cycles: $20$. Three-cycles times a transposition: $20$. Four-cycles: $30$. Five-cycles: $24$. Seven boxes, $120$ elements.

The information content of a random draw from a distribution is measured by its Shannon entropy, in bits: $H = -\sum_t P(t)\log_2 P(t)$. Feeding in those seven probabilities gives a closed form that is pretty enough to write down:
$$H(T)\;=\;\frac{7}{5} \;+\; \frac{17}{40}\log_2 3 \;+\; \frac{5}{24}\log_2 5 \;=\; 2.55734\ldots \text{ bits}.$$

Learning the splitting type of a random prime for $x^5-x-1$ is worth just over two and a half bits — more than any other quintic, and more than any lower-degree polynomial: this is the richest source in the whole family.

Now the alternating case. Restrict to the $60$ even permutations and the picture collapses: the odd cycle types — the transposition, the four-cycle, the three-cycle-times-transposition — simply never occur. Only four shapes survive, with sizes $1, 15, 20, 24$, and
$$H(T)\;=\;\frac{2}{15} \;+\; \frac{7}{20}\log_2 3 \;+\; \frac{5}{12}\log_2 5 \;=\; 1.65554\ldots \text{ bits}.$$

Still a genuinely random source: a prime chosen at random carries more than a bit and a half of surprise about how $x^5+20x+16$ factors.

## What a residue class is allowed to hear

So each polynomial produces a rich stream of splitting types. The question is what part of that stream is *audible* from a congruence condition — from knowing $p \bmod m$.

The answer, in one sentence: **a congruence can only hear the abelian part of the symmetry group.**

This is the content of class field theory, and it is the deepest ingredient in the story, but the shape of it is intuitive. Congruences are commutative objects: the residues mod $m$ form an abelian group, remainders multiply and the order does not matter. Any quantity a residue class can compute about the Frobenius element must therefore be a function that turns multiplication in the symmetry group into multiplication in an abelian group — a homomorphism into an abelian target. Call such a function a **dial**: it is the knob a residue class can actually read.

And the largest abelian image any group has is its **abelianization**: the group with all commutators forcibly set to one. Everything non-commutative gets erased.

- For $S_5$, the abelianization is the two-element group. The surviving dial is the **sign** of the permutation: even or odd. Arithmetically it is the quadratic character of the discriminant, the number $\mathrm{disc}(x^5-x-1) = 2869 = 19 \cdot 151$: knowing whether $2869$ is a perfect square modulo $p$ is *exactly* knowing whether the Frobenius element of $p$ is an even permutation.
- For $A_5$, the abelianization is *trivial*. $A_5$ is a **perfect** group: it equals its own commutator subgroup. There is no dial at all. Every homomorphism from $A_5$ into any abelian group is constant.

Now we can state the two theorems.

> **The abelianization law at $S_5$.** For a quintic with full symmetry group $S_5$, the mutual information between the sign dial and the splitting type is exactly $1$ bit. Moreover the law is *sharp*: for **every** homomorphism $\varphi$ of $S_5$ into **any** abelian group, the information transmitted between $\varphi$ and the splitting type is exactly $1$ bit if $\varphi$ is nontrivial and exactly $0$ if it is trivial. There is no intermediate regime.

> **The $A_5$ seal.** For a quintic with symmetry group $A_5$, *every* multiplicative read-out of the Frobenius element into an abelian group is constant on the group. Hence the mutual information between any such dial and **any** read-out whatsoever is exactly $0$ — a parameter-free zero. The $1.65554\ldots$ bits of splitting entropy are real, and not a single one of them can be reached from any residue direction.

The proof of the second one is four lines of group theory once the right fact is isolated: $A_5$ is simple, so a homomorphism out of it has kernel either everything or nothing; the "nothing" option would force $A_5$ to be abelian, which it visibly is not (two three-cycles overlapping in one letter do not commute); so the kernel is everything, and the dial is constant.

## The bit budget, in general

Both statements are shadows of one inequality, valid for any finite symmetry group $G$ whatsoever:
$$I(\varphi ; T) \;\le\; \log_2 |G^{\mathrm{ab}}|,$$
where $G^{\mathrm{ab}}$ is the abelianization. *Everything a residue class can hear about a splitting type is capped by the size of the abelianization, with no arithmetic input at all.* For $S_5$, $|G^{\mathrm{ab}}| = 2$ gives the one-bit ceiling; for $A_5$, $|G^{\mathrm{ab}}| = 1$ gives the zero, since $\log_2 1 = 0$.

And the inequality can be upgraded to an *equality* under a hypothesis the examples always satisfy. A homomorphic dial has a special structure: its fibres are cosets of its kernel, so they all have exactly the same size. A dial of that shape is *perfectly uniform on its image*, which is the best-case scenario for entropy: $H(\varphi) = \log_2|\mathrm{image}\,\varphi|$. If, in addition, the splitting type *determines* the dial — which is what "the sign is a function of the cycle type" says — then no information is lost in transmission, and
$$I(\varphi ; T) \;=\; \log_2 |\mathrm{image}\,\varphi|$$
on the nose. That single formula contains both extremes and the one-bit law of every degree.

## Multiplying primes buys nothing

A natural hope: maybe one prime yields one bit, but a *semiprime* $N = pq$ — the workhorse of public-key cryptography — yields more. You get two splitting types instead of one, after all.

It does not — and in some cases combining primes actively hurts. If the dial is the product of the individual dials, as the multiplicative structure of characters forces it to be, then for the $k$-fold product dial with the whole tuple of splitting types as read-out, the transmitted information is again $\log_2|\mathrm{image}\,\varphi|$ — *independent of $k$*. Two primes, ten primes, a thousand primes: exactly one bit for $S_5$, exactly zero for $A_5$. There is no almost-prime bonus. A product of quadratic characters is still a quadratic character; the extra structure is invisible to the channel.

The flatness comes from a hypothesis that happens to hold at $S_5$ and $A_5$: the splitting type *determines* the dial. When it does not, combining primes is strictly harmful. For the quintic symmetry group of order $20$ — the one whose abelianization is cyclic of order four — the factorisation type $[1,4]$ is compatible with two different dial values, and the $k$-prime channel transmits $1 + 2^{-k}$ bits: $3/2$ for one prime, $5/4$ for a semiprime, and down towards a single bit as more primes are multiplied in. Each ambiguous factor adds one more random step to the product, and the signal erodes.

## Not a degree-five accident

One might suspect that five is special. It is not, and the tower makes that precise. For permutations of *any* finite set with at least two elements, the sign is a function of the cycle type and the two sign classes are exactly the same size, so
$$I(\text{sign} ; \text{cycle type}) = 1 \text{ bit},$$
in every degree. And from degree five upwards, $A_n$ is perfect, so the sharp dichotomy and the seal hold verbatim: every abelian dial of $S_n$ transmits exactly one bit or exactly none, and every abelian dial of $A_n$ transmits exactly none.

What *is* special about five is the size of what is locked away. Knowing the parity of a splitting type leaves
$$H(T \mid \text{sign}) = \frac{2}{5} + \frac{17}{40}\log_2 3 + \frac{5}{24}\log_2 5 = 1.55734\ldots \text{ bits}$$
of residual uncertainty in the $S_5$ case. So the channel is spectacularly lossy in the other direction: the splitting type knows the residue bit perfectly, and the residue bit knows almost nothing about the splitting type. That asymmetry is the signature of non-abelian arithmetic, and it is the reason that non-abelian class field theory is hard: the information the type carries is *there*, in the primes, but congruences cannot see it.

## Measuring a zero honestly

It is worth saying how one verifies a claim like "the information is exactly zero", because the naive experiment gets it wrong every time.

Estimate the mutual information between $p \bmod 2869$ and the splitting type from a finite list of primes, by simply counting. The estimate will come out far above $1$ — and every fraction of a bit above $1$ is an artefact. A dial with $2868$ classes, estimated from a few thousand primes, sees each class a handful of times; random coincidences between sparse classes and types manufacture apparent information out of pure noise. The estimator is biased upward, and severely so.

The cure is not a bigger computer; it is a **permutation reference**. Reshuffle the residues *within* each parity stratum — that is, preserve exactly the channel the theorem predicts and randomise only the finer assignment — and re-estimate. Whatever the estimator reports on the shuffled data is the bias. In a campaign of this kind, the raw estimate for $x^5-x-1$ came out at $1.2157$ bits against a permutation reference of $1.2188$ bits: the observed value sits *inside* its own null, less than one standard deviation below it, and the entire $0.22$-bit excess over the theoretical $1$ is plug-in bias. Meanwhile the parity of the splitting type agreed with the quadratic character of $2869$ on $100.00\%$ of the primes tested — an exact $0$ or $1$ is the fingerprint of a law holding identically, and anything strictly between the two would have been the fingerprint of a bug.

For $x^5+20x+16$ the same discipline was applied in four residue directions at once, modulo $3$, $7$, $11$ and $31$. Every raw estimate landed on its own permutation null, the worst discrepancy under two standard deviations; the two-prime version came out at $0.0004$ bits; and no odd splitting type was ever observed, in any run. The seal holds exactly where the algebra says it must.

Along the way the measurement campaign caught six genuine defects by design — a wrong discriminant inherited from a lower-degree example, an inverted sign convention that showed up as a suspicious *perfect anti-correlation*, a null that accidentally destroyed the very channel it was meant to preserve, an off-by-one in a root-counting dictionary revealed by a crash at $p = 2$. The lesson generalises far beyond this problem: **build the checks that can fail loudly, and compare every information estimate against a reference that keeps the structure you believe in and randomises everything else.**

## Why it matters

The abstract picture is now complete for every quintic symmetry type that exists: from the abelian cases, where congruences see *everything* (this is the classical reciprocity of Gauss, Eisenstein and Kummer, in its information-theoretic clothes), through the intermediate group of order $20$ where the abelianization is cyclic of order $4$, up to $S_5$ with its single surviving bit, and finally $A_5$, where the door is shut. Every possible abelianization in degrees two through five — trivial, order two, order three, order four, and the Klein four-group — has now been measured, and in every case the transmitted information is exactly the logarithm of the abelianization's size.

There is a practical moral, too. Splitting types are a rich, cheap, computable statistic attached to primes, and the temptation to use them as features — in factoring heuristics, in primality-flavoured classifiers, in any statistical model built on congruence data — is real. These theorems say precisely what such a feature can and cannot carry. Against an $A_5$ quintic, congruence features are provably worthless, no matter how much data you collect, no matter what model you fit: the information is not merely hard to extract, it is not there. Against an $S_5$ quintic, you get one bit, and no amount of ensembling, no multiplying of primes, no enlargement of the modulus will ever get you a second.

Impossibility results of this kind are the most useful kind of negative knowledge. They tell you where not to look — and, by contrast, exactly where the remaining $1.55734\ldots$ bits are hiding. They are not in the residue classes. They are in the non-abelian part of the symmetry group, and reaching them is the open problem that the whole Langlands programme was built to attack.
