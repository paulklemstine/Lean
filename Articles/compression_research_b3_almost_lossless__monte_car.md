# Cheating the Pigeonhole — Almost

## How giving up on certainty (just a little) changes what compression can do, and why the real cost is not space but time

There is a theorem so simple that children discover it, and so unyielding that it has flattened a century of ambitious inventors: if you put $n+1$ pigeons into $n$ holes, two pigeons share a hole. Applied to data compression it says something bleak. Suppose you want a scheme that turns every one of $N$ possible files into a shorter codeword, and turns each codeword faithfully back into the original file. Then the number of codewords you use must be at least $N$. There is no universal compressor. A program that shrinks every input is as impossible as a pair of pigeons who each get their own hole when there are not enough holes.

Every so often someone announces that they have beaten this. They have not. But there is a crack in the argument, and it is much wider than it looks. The pigeonhole theorem governs *exact* decoding of *all* inputs. What if we ask for something a shade weaker: decode correctly with probability at least $1 - \varepsilon$, and on the rare failures, say so out loud instead of silently lying?

This is the question of *almost-lossless* compression. The answer turns out to be sharp, surprising in two directions at once, and — once you push past the question of how many bits you send and ask how long decoding takes — genuinely open at its frontier. This article tells that story.

---

## Setting the stage: honesty first

Fix a finite set $S$ of possible source words and a probability distribution $\mu$ on it — say, $\mu(s)$ is how often the file $s$ actually shows up in the world. A **code** consists of an encoder $\mathrm{enc} : S \to C$ into some alphabet $C$ of codewords, and a decoder $\mathrm{dec} : C \to S \cup \{\bot\}$, where $\bot$ is an explicit "I refuse to answer" symbol. The word $s$ is *decoded correctly* if $\mathrm{dec}(\mathrm{enc}(s)) = s$, and the **failure probability** is
$$P_{\text{fail}} \;=\; \mu\big(\{\, s : \mathrm{dec}(\mathrm{enc}(s)) \neq s \,\}\big).$$

A code is **honest** if for every source word the decoder either returns the true word or returns $\bot$. It never hands back a *different* file and calls it yours. This is not a technicality: a compressor that occasionally, silently, corrupts your data is worthless no matter what its failure probability is, because you can never tell which outputs to trust. Honesty is the difference between a lossy scheme and a *detectably* lossy one.

The first thing to notice is that the pigeonhole obstruction survives, untouched, in this weaker world — but only where it should. Here is the core, stripped of probability:

> **Counting Lemma.** For any code, the set of correctly decoded source words injects into the codeword alphabet. Hence at most $|C|$ source words can decode correctly.

The proof is two lines. If $s$ and $t$ both decode correctly and $\mathrm{enc}(s) = \mathrm{enc}(t)$, then $s = \mathrm{dec}(\mathrm{enc}(s)) = \mathrm{dec}(\mathrm{enc}(t)) = t$. So the encoder is injective on the good set, and a set that injects into $C$ has at most $|C|$ elements. Notice that neither honesty nor randomness appears anywhere. Whatever the decoder does on the bad words — abort, guess, lie — the good words are still pigeons.

## How much does $\varepsilon$ buy you?

Now put a source on top. If the source is uniform on all $N = |S|$ words, then the correct set has probability $|{\text{correct}}|/N \le |C|/N$, so:

> **Uniform Converse.** For a uniform source, every code — honest or not, clever or not — fails with probability at least $1 - |C|/|S|$. Equivalently, an $\varepsilon$-reliable code needs $|C| \ge (1-\varepsilon)\,|S|$ codewords.

So the relaxation buys you a factor $1 - \varepsilon$, and *exactly* that. Want to fail one time in a thousand? You save 0.1% of your alphabet. That is not compression; that is a rounding error. On a uniform source, the crack in the pigeonhole is hairline.

At which point one naturally reaches for the great trick of information theory: **randomness**. Shannon's proof that reliable communication is possible at capacity does not construct a code; it draws one at random and shows that the average is good. Surely a shared random number generator — the encoder and decoder agreeing on a seed in advance — can do something here?

It cannot. Not a bit, literally.

> **Randomness Buys Nothing (uniform case).** Let $\{K_\omega\}_{\omega \in \Omega}$ be *any* ensemble of codes with alphabet $C$, and draw $\omega$ uniformly. On a uniform source the average failure probability is still at least $1 - |C|/|S|$.

The reason is disarming: the deterministic bound holds for every single $\omega$, and an average of numbers each $\ge b$ is $\ge b$. Randomness cannot help because there is nothing to average over — every member of the ensemble is individually stuck.

And the same averaging argument runs in the other direction, for *any* source, giving a clean derandomisation principle: if a randomized ensemble achieves average failure $\le \varepsilon$, then some particular seed achieves failure $\le \varepsilon$, so a single deterministic code does as well. **Shared randomness is never necessary.** It is a convenience, an engineering device for avoiding a search — never a source of power.

## What the relaxed pigeonhole really says

If randomness is not the answer, what is? The honest answer is that on a uniform source there is no answer, and the whole game is that real sources are not uniform. This is captured by an exact characterisation that replaces the counting bound entirely:

> **The $\varepsilon$-Relaxed Pigeonhole Principle.** There exists a code with alphabet $C$ and failure probability at most $\varepsilon$ **if and only if** there exists a set $T \subseteq S$ with $|T| \le |C|$ and $\mu(T) \ge 1 - \varepsilon$.

Read it twice; it is the whole subject in one line. The relaxed bound is not "the old bound times $(1-\varepsilon)$". It is a statement about *concentration*: the question "how few codewords suffice?" becomes the question "how small can a set of probability $1-\varepsilon$ be?" For a uniform source, every set of size $|C|$ has probability $|C|/|S|$ and you recover the depressing bound. For a concentrated source — English text, sensor readings, anything real — a $1-\varepsilon$ fraction of the mass can sit on a vanishingly small *typical set* $T$, and then $|T|+1$ codewords suffice: enumerate $T$, send the index, send $\bot$ for anything else. That extra symbol is the honesty guarantee, paid for once.

The "only if" direction is the Counting Lemma; the "if" direction is that table code. Both are trivial once stated correctly, which is exactly the sign of a good statement. It also has a pleasant corollary about honesty:

> **Honesty Is Free.** Every code, honest or not, is matched by an honest one: there is a scheme with the *same* set of correctly decoded words, whose decoder never returns a wrong answer and probes at most one candidate. The only cost is a single extra alphabet symbol.

So there is never a reason to build a silently-corrupting compressor. You cannot buy anything with the corruption.

---

## The real obstacle is the clock

Here the story turns. Rate is settled: $|T|+1$ symbols, optimal, done. But the optimal scheme is a *table*, and a table of the typical set of a realistic source is astronomically large — you cannot enumerate the typical English strings of length 1000. Practical schemes therefore replace the table with a *hash*: pick a seeded function $h_a : S \to M$ from a small family, send $h_a(x)$, and have the decoder find the typical word with that hash value.

The classic device is a **2-universal** family: for any two distinct words $x \ne y$, the fraction of seeds $a$ with $h_a(x) = h_a(y)$ is at most $1/|M|$. The canonical example is the inner product over a finite field: source words are vectors $x \in \mathbb{F}_p^k$, the seed is a vector $a \in \mathbb{F}_p^k$ chosen by your random number generator, and the codeword is the single field element $\langle a, x\rangle$. This family is not merely 2-universal but *exactly pairwise independent*: for $x \ne y$, precisely a $1/p$ fraction of seeds collide, because $a \mapsto \langle a, x-y\rangle$ is a nonzero linear functional and all its fibres have the same size.

Union-bounding over the ordered pairs of the typical set gives the Monte Carlo guarantee. Writing $t = |T|$:

> **Monte Carlo Reliability.** With a 2-universal hash, a uniformly random seed confuses two typical words with probability at most $t(t-1)/|M|$. Consequently the average failure probability of the resulting compressor is at most $\varepsilon + t(t-1)/|M|$, where $\varepsilon$ is the atypicality loss — and **every** failure is detected: whatever the seed, the decoder returns the true word or $\bot$, never a wrong word.

The honesty here is unconditional, which is the point of the design. The decoder does not trust the seed. It scans its candidates and answers only if the match is *unique*; if the seed happened to be catastrophic, the scan sees two matches and aborts. Corruption is converted into detected failure by construction.

And the randomness can be removed. If $|M| > t(t-1)$, the fraction of bad seeds is less than $1$, so a good seed exists — the probabilistic method in its purest form. Combined with the fact that there is always a prime between $n$ and $2n$, this yields a fully explicit, fully deterministic scheme:

> **Quadratic-Rate Deterministic Scheme.** For every typical set $T$ of size $t$ there is a prime $p$ with $t^2 < p \le 2t^2$ and an explicit inner-product hash over $\mathbb{F}_p$ whose code is honest, decodes *every* typical word correctly, and transmits one of only $p+1 \le 2t^2+1$ symbols.

Against the information-theoretic optimum of $t$ symbols, the constructive scheme pays a squaring — the *birthday penalty* — and nothing more. $\log_2 p \approx 2\log_2 t$: it sends twice as many bits as necessary, in exchange for being explicit and table-free.

## Counting the ticks

That leaves the question the whole thread was really about: **how long does decoding take?** Naive random coding is a disaster here — you scan the entire codebook. The natural fix is *bucketing*: use one hash $h_1$ with range $m_1$ to select a bucket of a precomputed index of $T$, and a second, independently seeded hash $h_2$ as a checksum to single out the right word inside that bucket. The decoder's cost, measured honestly in candidate tests, is the size of the bucket.

How big is a bucket? Exactly one true candidate plus the false ones, and averaging over the seed gives not a bound but an identity:

> **Exact Expected Decoder Cost.** For a pairwise independent bucket hash with $m_1$ buckets, the expected number of candidate tests performed when decoding a typical word is *exactly*
> $$1 + \frac{t-1}{m_1}.$$

Not "at most". Exactly. So as soon as you take $m_1 \ge t$, decoding costs fewer than two probes on average, against $t$ for the naive scan and $|S|$ for a naive random codebook. And since it is an equality, no cleverness inside this class of hash families can improve it.

Could a completely different scheme do better? Only up to an additive constant, and here is the reason — a bound that holds for *every* scheme and *every* seed:

> **The Rate–Time Hyperbola.** Consider any scheme in which the decoder, on receiving a codeword, tests a set of candidate typical words containing the true one. For any seed, the total number of candidate tests spent decoding the whole typical set is at least $t^2/|M|$. Hence the average cost per typical word is at least $t/|M|$: with $m$ codewords you cannot decode a typical set of size $t$ in fewer than $t/m$ expected tests.

The proof is Cauchy–Schwarz over the buckets. The typical set is partitioned by its codeword into at most $|M|$ groups of sizes $n_1, \dots, n_{|M|}$ summing to $t$; every member of a group is necessarily a candidate when that codeword arrives, so the total work is at least $\sum_j n_j^2$, and $\sum_j n_j^2 \ge (\sum_j n_j)^2/|M| = t^2/|M|$ by the power-mean inequality. Rate and decoding time trade off along a hyperbola: send fewer bits and you *must* search longer, and the bucketed decoder sits within an additive $1$ of the frontier.

## Exactly how likely is failure? Ask geometry

One last surprise. The union bound $t(t-1)/|M|$ is the standard estimate for the Monte Carlo failure probability, and standard estimates are usually loose. In the plane, one can compute the truth exactly — and the computation is not probabilistic at all, but *projective-geometric*.

A seed $a$ is bad for $T$ precisely when $\langle a, x-y \rangle = 0$ for some pair of distinct typical words: that is, when $a$ lies on the line orthogonal to some difference direction. Proportional differences give the *same* line, so what matters is not the number of pairs but the number of distinct **projective directions** among the differences. Each such line has $p$ points, all of them pass through the origin, and (in the plane) two distinct directions meet only there. Counting:

> **Exact Planar Failure Probability.** If the differences of $T \subseteq \mathbb{F}_p^2$ realise exactly $d$ distinct projective directions, then the number of bad seeds is exactly $1 + d(p-1)$, and the failure probability of the compressor is exactly
> $$\frac{1 + d(p-1)}{p^2}.$$

Take $T = \{(1,0), (0,1), (2,3)\} \subseteq \mathbb{F}_{11}^2$. Its three differences point in three distinct directions, so the theorem predicts $1 + 3 \cdot 10 = 31$ bad seeds out of $121$: a failure probability of $31/121 \approx 0.256$. Brute-force enumeration of all 121 seeds confirms 31, exactly. The union bound for the same example gives $6/11 = 66/121 \approx 0.545$ — loose by more than a factor of two. Whenever two differences happen to be proportional, $d$ drops and the true probability drops with it, while the union bound notices nothing.

That reframing — *probability of collision = measure of a pencil of hyperplanes* — is the doorway to the open problems. In dimension $k \ge 3$ the bad set is a union of hyperplanes that intersect each other in nontrivial subspaces, so the exact count becomes a Möbius-function computation over the lattice of subspaces spanned by the difference directions; the union bound is precisely its first Bonferroni term. Numerical experiment already shows the naive planar formula failing at $p = 13$, $k = 3$, exactly where the higher-order terms switch on.

## What the crack is worth

So: can you beat the pigeonhole bound? On a uniform source, no — not with error tolerance, not with randomness, not with any ensemble, not by a bit. On a concentrated source, yes, spectacularly, and the exact price is the size of the smallest set carrying $1-\varepsilon$ of the mass. Randomness never helps the rate, but it makes explicit constructions easy, at the cost of a squaring that no pairwise-independent family can avoid. And once you insist on decoding *fast*, a second, independent conservation law appears: rate times time is bounded below, and a two-hash bucketed decoder achieves it to within one probe, with every failure loudly announced.

The pigeons, it turns out, were never the problem. The problem was always how long it takes to find which hole your pigeon is in.
