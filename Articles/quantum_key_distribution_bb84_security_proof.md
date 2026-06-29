# The 11% Rule: How Two Physicists, an Eavesdropper, and a Coin-Flipping Hash Function Make Perfect Secrecy Possible

## A secret you can *prove* is safe

Every secret message you have ever sent online rests on a hope. The hope is that a certain mathematical problem — factoring a gigantic number, say — is too hard for anyone to solve in a reasonable amount of time. It is a good hope. But it is still a hope. A clever new algorithm, or a large enough quantum computer, could one day turn today's unbreakable cipher into tomorrow's open book.

In 1984, Charles Bennett and Gilles Brassard proposed something radically different: a way to share a secret key whose security does not depend on any unproven assumption about how hard a computation is. Instead, it rests on the laws of physics themselves. Their protocol, now called **BB84**, uses individual particles of light — photons — to carry the bits of a secret key. The guarantee is not "no one *can* break this with today's computers"; it is "no one can break this without violating quantum mechanics."

This article is about the *mathematics* underneath that guarantee. Three numbers will recur, and by the end each will feel inevitable:

- **25%** — the unavoidable noise an eavesdropper creates by listening.
- **11%** — the sharp line between "we can still extract a secret" and "give up."
- **exponentially small** — how much an eavesdropper ultimately learns about the final key.

Let us see where each comes from.

## The setup: bits hidden in the angle of light

Alice wants to send Bob a random string of bits. She encodes each bit on a single photon, choosing — at random — one of two "bases," which you can picture as two different sets of polarizer angles: a *rectilinear* basis (horizontal/vertical) and a *diagonal* basis (the two diagonals). A `0` and a `1` look different within a basis, but the two bases are *conjugate*: if you measure a photon in the wrong basis, you get a completely random answer and you destroy the original information.

Bob, who doesn't know which basis Alice used, also picks a basis at random for each photon and measures. Afterward, over a public channel, Alice and Bob announce *which bases* they used (never the bit values). They keep only the rounds where, by luck, they happened to choose the same basis. This step is called **sifting**, and on those sifted rounds — in a perfect world — their bits agree exactly.

The magic is in the word "conjugate." Because measuring in the wrong basis randomizes the outcome, *anyone* who intercepts a photon faces the same dilemma Bob does: they must guess a basis, and half the time they guess wrong. And a wrong guess doesn't just cost the eavesdropper information — it leaves a trace.

## The eavesdropper's dilemma: the 25% fingerprint

Meet Eve. The most natural attack she can mount is **intercept–resend**: she grabs each photon, measures it in some basis of her choosing, and sends Bob a fresh photon prepared according to what she saw. It feels almost free. But quantum mechanics charges a toll.

Consider a single sifted round, where Alice and Bob both used basis $a$. Eve measures in basis $e$.

- If $e = a$ (she guessed right), she learns the bit and resends it faithfully. Bob recovers the correct bit. Error contribution: $0$.
- If $e \neq a$ (she guessed wrong), the photon she resends is in the *conjugate* basis to Bob's. Bob's measurement is now a coin flip — wrong half the time. Error contribution: $1/2$.

Eve's basis is right or wrong with equal probability $1/2$. So the **quantum bit error rate** (QBER) she induces is

$$\text{QBER} = \tfrac{1}{2}\cdot 0 + \tfrac{1}{2}\cdot \tfrac{1}{2} = \tfrac{1}{4} = 25\%.$$

This is the formal statement `interceptResendQBER_eq`: for *either* common basis $a$, the averaged Bob-error equals exactly $1/4$. The model encodes Bob's conditional error as a function `bobErrorProb a e` (zero if Eve guessed the basis, $1/2$ if not) and averages it over Eve's uniform basis choice. The number $1/4$ falls out, and — crucially — it does **not** depend on which basis Alice happened to use.

That $25\%$ is Eve's fingerprint. Alice and Bob can *measure* their error rate by sacrificing a handful of sifted bits and comparing them publicly. A full intercept–resend attack would jump the error rate to a quarter, far above the tiny errors caused by an honest, noisy fiber. They would see it and abort.

But Eve is cleverer than that. She might intercept only *some* photons, or use a subtler quantum attack that produces *less* error. This raises the real question: **how much error can Alice and Bob tolerate and still salvage a secret?**

## The key rate: turning entropy into a budget

Here we leave the cartoon of single attacks and enter information theory. The right way to think about a noisy, partially-compromised key is as a tug-of-war between two quantities:

- How much *fresh randomness* Alice and Bob share (good for them).
- How much Eve could *infer* from the errors she introduced (good for her).

For one-way post-processing — where Alice sends correction information to Bob but not vice versa — the famous **Shor–Preskill** analysis gives the asymptotic fraction of secret key bits you can extract per sifted bit:

$$r(Q) = 1 - 2\,H_2(Q),$$

where $Q$ is the error rate and $H_2$ is the **binary entropy function**

$$H_2(Q) = -Q\log_2 Q - (1-Q)\log_2(1-Q).$$

The binary entropy measures uncertainty: it is $0$ when $Q=0$ (no surprise) and rises to $1$ bit at $Q = 1/2$ (maximum confusion). The formula $r(Q) = 1 - 2H_2(Q)$ has a clean reading: one term of $H_2(Q)$ is the cost of *correcting* Bob's errors, and the second term is the cost of *erasing* Eve's potential knowledge. When the two costs together exceed the one bit you started with, there is nothing left.

In the formalization, entropy is measured in *nats* (natural logarithm) rather than bits, so the key rate is written

$$\texttt{secureKeyRate}(Q) = \log 2 - 2\,\text{binEntropy}(Q),$$

which is just $\log 2$ times the textbook $1 - 2H_2(Q)$. The condition for distilling key is simply that this be positive. The lemma `secureKeyRate_pos_iff` states the equivalence precisely:

$$0 < \texttt{secureKeyRate}(Q) \iff \text{binEntropy}(Q) < \tfrac{\log 2}{2}.$$

In words: **secret key can be distilled exactly when the entropy of the error is below half of $\log 2$.**

## Where the 11% comes from — and why it is exactly one number

We now have a function $r(Q)$ that is positive for small error and negative for large error. Three facts pin down the threshold completely.

**First, the key rate only ever goes down.** As the error rate climbs, distilling secrets only gets harder; it never gets easier. Formally, `secureKeyRate_strictAntiOn` proves that $\texttt{secureKeyRate}$ is *strictly decreasing* on the interval $[0, 1/2]$. Strict monotonicity is the workhorse: it guarantees the function crosses zero **at most once**.

**Second, it really does cross zero — somewhere between 6.25% and 12.5%.** This is `exists_threshold`: there is a critical error rate

$$p^\star \in \left(\tfrac{1}{16}, \tfrac{1}{8}\right) = (6.25\%, 12.5\%)$$

at which $\texttt{secureKeyRate}(p^\star) = 0$. The bracketing endpoints are certified by a genuinely beautiful trick. Checking that $r(1/8) < 0$ and $r(1/16) > 0$ would seem to require evaluating logarithms to high precision. Instead, clearing logarithms turns each inequality into a comparison of *integers*:

- $\texttt{binEntropy}(1/8) > \tfrac{\log 2}{2}$ collapses to $7^7 < 2^{20}$, i.e. $823{,}543 < 1{,}048{,}576$ (lemma `binEntropy_one_eighth_gt`).
- $\texttt{binEntropy}(1/16) < \tfrac{\log 2}{2}$ collapses to $2^{56} < 15^{15}$ (lemma `binEntropy_one_sixteenth_lt`).

No floating point, no interval arithmetic on transcendental functions — a transcendental threshold certified by two whole-number inequalities. Existence then follows from the Intermediate Value Theorem applied to the continuous entropy function.

**Third, the crossing point is unique.** Combine monotonicity with existence and you get `threshold_unique`: any two error rates in $[0, 1/2]$ at which the key rate vanishes must be equal. There is *one* threshold, not a fuzzy band.

The true value of $p^\star$, solving $H_2(p^\star) = 1/2$, is approximately $0.110$ — the celebrated **~11% QBER threshold** of BB84. Below it, secret key flows; above it, the channel is too compromised and the protocol aborts.

And now the two stories click together. Eve's full intercept–resend attack produces error $1/4 = 25\%$, which sits *above* the threshold. The lemma `secureKeyRate_one_quarter_neg` proves $\texttt{secureKeyRate}(1/4) < 0$ directly (via the easy integer comparison underlying `binEntropy_one_quarter_gt`), and `interceptResend_insecure` chains this to the protocol model: the intercept–resend QBER always yields a negative key rate. **The strongest naive attack is always detectable**, because it pushes the error past the line where any secret can survive.

## The last mile: making Eve's knowledge vanish

Suppose Alice and Bob measured an error rate comfortably below 11%. They reconcile their bits (fixing the few disagreements) and arrive at a shared raw key that is *correct* but *not perfectly secret* — Eve may hold partial information about it. The final step, **privacy amplification**, squeezes that raw key through a hash function to produce a shorter key about which Eve knows almost nothing.

Why does this work? The intuition is dilution. Eve's partial knowledge is spread thinly across many possible raw keys. A good hash function blends those possibilities so thoroughly that the output looks, to Eve, indistinguishable from pure randomness. The quantitative engine is the **Leftover Hash Lemma**, and its mathematical heart is a single inequality proved as `statDist_le_collision`.

Imagine the output key takes one of $M$ values with probabilities $p_1, \dots, p_M$ (as seen by Eve, who holds side information). How far is this from the uniform distribution, in which each value has probability $1/M$? Measure the gap by the total deviation $\sum_i |p_i - 1/M|$. The theorem says this is controlled by a *single second moment*, the **collision probability** $\sum_i p_i^2$:

$$\sum_{i=1}^{M} \left| p_i - \tfrac{1}{M} \right| \;\le\; \sqrt{\,M \cdot \sum_{i=1}^{M} p_i^2 \;-\; 1\,}.$$

The proof is a clean Cauchy–Schwarz argument on the *centered* vector $d_i = p_i - 1/M$, which sums to zero. (Strikingly, the bound never uses that the $p_i$ are nonnegative — it is a pure statement about any vector summing to $1$.) The collision probability is exactly the quantity an eavesdropper's guessing power controls: low collision probability means high *min-entropy*, the cryptographer's measure of unpredictability.

Plug in the regime that matters. If the final key has $\ell$ bits, there are $M = 2^\ell$ values, and if Eve's residual collision probability is at most $2^{-k}$ (min-entropy at least $k$), then `privacyAmplification_exp_bound` delivers the punchline:

$$\sum_{i} \left| p_i - 2^{-\ell} \right| \;\le\; \sqrt{2^{\,\ell - k}}.$$

When the **entropy gap** $k - \ell$ is positive and growing — exactly when Alice and Bob extract a key shorter than Eve's residual uncertainty — the right side is $2^{-(k-\ell)/2}$, which **shrinks exponentially**. Sacrifice a little length, gain overwhelming secrecy. That is privacy amplification in one line.

## The coin-flipping hash: why randomness is mandatory

One subtlety remains: *which* hash function? Here the mathematics issues a warning and then a remedy.

The warning, `injective_extractor_impossible`, is the humble pigeonhole principle dressed for cryptography. Any *fixed, deterministic* function that compresses a large key space into a smaller one must send two different inputs to the same output — it cannot be injective. A predictable hash is therefore predictably broken: Eve could exploit its fixed collisions.

The remedy is to choose the hash *at random* from a carefully designed family, publicly, after the key exists. The gold standard is a **two-universal** family: one in which, for any two distinct inputs, a randomly chosen member of the family makes them collide with probability at most $1/M$ — no worse than blind chance. The cleanest such family is breathtakingly simple. Over bit-vectors of length $n$, pick a random seed $a = (a_1, \dots, a_n)$ and hash an input $x = (x_1, \dots, x_n)$ to a single parity bit:

$$\texttt{innerHash}(a, x) = a_1 x_1 + a_2 x_2 + \cdots + a_n x_n \pmod 2.$$

It is just a random parity check. Does it spread collisions perfectly? The theorem `two_universal` says yes, exactly: for any two distinct inputs $x \neq y$,

$$2 \cdot \#\{\, a : \texttt{innerHash}(a, x) = \texttt{innerHash}(a, y)\,\} = 2^n.$$

In plain terms, **precisely half of all seeds make any two distinct inputs collide** — the collision probability is exactly $1/2$, the best a single output bit could possibly do. The proof is a gem. Two inputs $x$ and $y$ must differ at some coordinate $j$. Flipping the seed's $j$-th entry, $a \mapsto a + e_j$, is a perfect pairing (an *involution*: do it twice and you return home) that swaps "collision" seeds with "non-collision" seeds. A perfect pairing means the two sets are the same size — exactly half each.

The generalization `two_universal_k` extends this to $k$ independent parity bits, giving collision probability exactly $2^{-k}$:

$$2^k \cdot \#\{\, A : \text{all } k \text{ rows collide on } x, y\,\} = (2^n)^k,$$

because the $k$ rows behave as $k$ independent copies of the one-bit hash. This is precisely the low-collision-probability input that the Leftover Hash Lemma demands. The circle closes: a *random parity function* provides the provably-low collision probability that *privacy amplification* converts into *exponentially small* leakage.

## The whole machine, in one breath

Step back and watch the parts mesh:

1. **Physics** forbids Eve from copying photons, so listening creates errors. The strongest naive attack imprints a $25\%$ error rate (`interceptResendQBER_eq`).
2. **Information theory** sets a precise budget: secret key survives exactly while the error stays below a threshold $p^\star \approx 11\%$, a value that is provably unique (`threshold_unique`) and bracketed by pure integer inequalities (`exists_threshold`). The $25\%$ attack lands above it and is always caught (`secureKeyRate_one_quarter_neg`).
3. **Hashing** finishes the job: a randomly chosen parity hash is perfectly two-universal (`two_universal`), and feeding its low collision probability into the Leftover Hash bound (`statDist_le_collision`) drives Eve's residual knowledge to exponentially small (`privacyAmplification_exp_bound`).

No part assumes a computation is hard. The eavesdropper may own a quantum computer the size of a planet; the $11\%$ line and the exponential collapse of her knowledge hold regardless. What once was a *hope* — "surely no one can break this" — becomes a *theorem*.

That is the quiet revolution of BB84: a secret you can not only keep, but **prove** you have kept. And the proof, it turns out, comes down to a coin flip, an integer comparison, and the stubborn refusal of a photon to be in two places at once.
