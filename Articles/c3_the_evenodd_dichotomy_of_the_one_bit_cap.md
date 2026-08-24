# One Bit, and the Number Two

## How much a clock face tells you about a sum

Pick a clock with $n$ hours on it. Choose two hours at random — call them $a$ and $b$, each drawn uniformly and independently from $0, 1, \dots, n-1$. Now imagine that somebody is going to whisper a single piece of coarse information about $a$ and $b$ in your ear, and then ask you to guess $a + b$ modulo $n$.

The coarse information is this. For each hour $a$ on the clock, define its **type**
$$T(a) = \frac{n}{\gcd(a, n)}.$$
This is the number of distinct positions you visit if you keep stepping forward by $a$ hours: it is the *order* of $a$ in the cyclic group $\mathbb{Z}/n\mathbb{Z}$. On a $12$-hour clock, $T(3) = 4$ (you visit $3, 6, 9, 0$), $T(6) = 2$, $T(5) = 12$, and $T(0) = 1$. The type does not tell you which hour $a$ is; it tells you only how big a subgroup $a$ generates — the "shape" of $a$, not its identity.

What you get whispered is the **type pair** $\big(T(a), T(b)\big)$. What you want to know is the **sum residue** $(a+b) \bmod n$. The question is: *how many bits does the whisper carry?*

The answer, in information-theoretic currency, is the mutual information
$$I_{\mathrm{pair}}(n) \;=\; I\Big(\big(T(a),T(b)\big) \;;\; (a+b)\bmod n\Big),$$
measured in bits. Because $a+b$ is exactly uniform on the clock face when $a$ and $b$ are — every residue is hit precisely $n$ times among the $n^2$ pairs — this mutual information has a clean form:
$$I_{\mathrm{pair}}(n) = \log_2 n - H\big((a+b) \bmod n \;\big|\; (T(a),T(b))\big).$$
It measures exactly how far the type pair pushes you from total ignorance ($\log_2 n$ bits of uncertainty) toward certainty.

Compute it for the first few clocks and something strange jumps out.

| $n$ | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| $I_{\mathrm{pair}}(n)$ | $1.000$ | $0.474$ | $1.250$ | $0.203$ | $1.474$ | $0.114$ | $1.313$ | $0.527$ | $1.203$ | $0.052$ | $1.724$ |

Every even clock is at or above one bit. Every odd clock is comfortably below it. The number $1$ — one single bit — sits like a wall between the parities, and the wall does not budge as far as the eye can see. That observation is the seed of everything below, and the punchline is that it is *almost* right, right for a reason nobody would have guessed, and wrong in a way that takes twelve digits to expose.

## Why one bit, and why two?

Where would a *cap* of exactly one bit come from?

Here is the intuition. The type of $a$ is a divisor of $n$, and the hours with a given type $t$ are exactly the $\varphi(t)$ generators of the unique subgroup of order $t$, where $\varphi$ is Euler's totient function. So knowing the type pair confines the pair $(a,b)$ to a *product set* $A \times B$, with $|A| = \varphi(T(a))$ and $|B| = \varphi(T(b))$.

Now comes the observation that drives everything. On a product set, the map $(a,b) \mapsto a+b$ cannot collapse things very much. If you fix $a$, the sum determines $b$; if you fix $b$, the sum determines $a$. So every fibre of the sum map on $A \times B$ — every set of pairs sharing the same sum — injects into $A$ and into $B$, and therefore has at most $\min(|A|,|B|)$ elements. Since the product set has $|A| \cdot |B|$ elements in total, the sum must take at least
$$\frac{|A| \cdot |B|}{\min(|A|,|B|)} = \max(|A|,|B|)$$
distinct values, spread as evenly as that constraint allows. Entropy is at least the logarithm of the number of values you cannot avoid; so within a type class the sum residue still carries at least $\log_2 \max\big(\varphi(T(a)),\varphi(T(b))\big)$ bits of uncertainty. Averaging over all $n^2$ pairs gives what we may call the **universal envelope**:
$$I_{\mathrm{pair}}(n) \;\le\; \log_2 n \;-\; \underset{(a,b)}{\mathrm{avg}}\; \log_2 \max\big(\varphi(T(a)), \varphi(T(b))\big).$$

This inequality is the whole engine. It says: *the residual uncertainty is at least the log of the bigger of the two type classes*. And now the special role of the prime $2$ appears. On a clock of size $2^k$, the type classes are nested chains of two-adic residue classes, and the residue really is confined to exactly one coset of the right size — the fibre bound is not merely a bound but an *identity*. For every other prime, a type class is a union of $q-1$ arithmetic progressions rather than a single one, the residue spreads out more than the bound requires, and the channel leaks strictly less information.

That difference between "one progression" and "a union of $q-1$ progressions" is precisely the difference between $q = 2$ and $q > 2$. The prime two is the only prime with exactly one nontrivial residue class to be a generator in. The even/odd dichotomy is not a parity coincidence; it is the arithmetic of the number $2$ being the only prime for which $q - 1 = 1$.

## The exact law for powers of two

Because the fibre bound closes at $q = 2$, one can evaluate the envelope exactly. The computation is a self-similar recursion: multiplying both hours by $2$ is a bijection from the square of the $2^{k}$-clock onto the sub-square of even pairs on the $2^{k+1}$-clock, and it preserves types. Off that sub-square, at least one of the two hours is odd, hence a generator, hence has the maximal type class, of size $\varphi(2^{k+1}) = 2^{k}$. Solving the recursion gives the exact, closed, beautifully simple law:

> **The Two-Primary Law.** For every $k \ge 0$,
> $$I_{\mathrm{pair}}(2^k) = \frac{4}{3}\left(1 - 4^{-k}\right).$$

Read off the values: $I_{\mathrm{pair}}(1) = 0$, $I_{\mathrm{pair}}(2) = 1$, $I_{\mathrm{pair}}(4) = 5/4$, $I_{\mathrm{pair}}(8) = 21/16$, $I_{\mathrm{pair}}(16) = 85/64$, $I_{\mathrm{pair}}(32) = 341/256$. The sequence increases strictly and converges to $4/3$ — never reaching it. So the one-bit cap is not a ceiling at all: it is a *floor*, hit exactly once, at $n = 2$, and then left behind forever. The true ceiling of the two-power tower is four thirds of a bit.

The value $I_{\mathrm{pair}}(2) = 1$ has a satisfying interpretation. On the two-hour clock the type of $a$ is $1$ if $a = 0$ and $2$ if $a = 1$. So the type pair *is* the pair $(a,b)$, the sum is determined completely, and the whisper hands you the answer: one full bit, no more and no less. This is the "split-count fork" that saturates exactly one bit, and it is what the cap was named after.

## Odd primes never make it

For an odd prime $q$ the same recursion still gives an upper bound, and it evaluates to
$$I_{\mathrm{pair}}(q^k) \;\le\; \left(1 - q^{-2k}\right) E(q), \qquad E(q) = \frac{q^2 \log_2 q}{q^2 - 1} - \log_2(q-1).$$
At $q = 2$ the constant is $E(2) = \tfrac{4}{3}\cdot 1 - 0 = 4/3$, in exact agreement with the two-primary law — a reassuring consistency check, since the inequality is an equality there. For an odd prime the constant plummets:
$$E(3) = 0.7831, \quad E(5) = 0.4187, \quad E(7) = 0.2809, \quad E(11) = 0.1663, \dots$$
and one can bound it uniformly: $E(q) \le 39/40 < 1$ for every odd prime $q$. The mechanism is a two-line estimate: write $E(q) = \log_2\frac{q}{q-1} + \frac{\log_2 q}{q^2-1}$; the first term is at most $\log_2(3/2) < 3/5$ and the second at most $q/(q^2-1) \le 3/8$.

So a clock whose size is a power of an odd prime **never** reaches one bit — in fact never exceeds $39/40$ of a bit, and truly never exceeds $E(3) = 0.783$.

## The last ingredient: bits add up

The channel has one more structural property, and it is what turns local statements about primes into global statements about all $n$: if $m$ and $n$ are coprime then
$$I_{\mathrm{pair}}(mn) = I_{\mathrm{pair}}(m) + I_{\mathrm{pair}}(n),$$
a consequence of the Chinese Remainder Theorem, which splits the clock into independent primary clocks and the type into independent primary types. Hence
$$I_{\mathrm{pair}}(n) = \sum_{p^{e} \,\|\, n} I_{\mathrm{pair}}(p^{e}),$$
the sum running over the primary components of $n$. Information about a composite clock is the sum of information about its prime-power clocks.

Now everything falls into place. Write $n = 2^{a} m$ with $m$ odd.

* If $a \ge 1$, the two-part contributes at least $I_{\mathrm{pair}}(2) = 1$, and everything else contributes something non-negative. So **every even clock carries at least one bit**.
* If moreover $n \ne 2$, then either $a \ge 2$ (and the two-part alone gives $\ge 5/4$) or $a = 1$ and $m \ge 3$ (and the odd part contributes a strictly positive amount). So **every even clock other than $n=2$ carries strictly more than one bit**.

The strict positivity in the second case needs its own argument, and there is a pretty one. Among the $n^2$ pairs, exactly one — the pair $(0,0)$ — has the degenerate type pair $(1,1)$; a hint that both hours are $0$ tells you the sum exactly. That single class alone forces
$$I_{\mathrm{pair}}(n) \;\ge\; \frac{\log_2 n}{n^2} \;>\; 0 \qquad (n \ge 2),$$
a crude but universal quantitative lower bound.

Combining, for a prime power the dichotomy is exactly as clean as one could hope:

> **The Primary Dichotomy.** For a prime $q$ and $k \ge 0$: $\;I_{\mathrm{pair}}(q^k) > 1$ if and only if $q = 2$ and $k \ge 2$.

## The twist: an odd clock that breaks the cap

Everything above proves half of the folklore observation and improves it: evenness is *sufficient*. Is it *necessary*? The numerical table says yes for every $n$ up to $40$ — and for every $n$ anyone would reasonably check by hand.

It is false.

The reason is that additivity is a knapsack. Each odd prime $q$ contributes at most $\sup_k I_{\mathrm{pair}}(q^k)$, and those suprema are
$$0.5330,\; 0.2112,\; 0.1165,\; 0.0523,\; 0.0389,\; 0.0241,\; 0.0197,\; 0.0140,\; \dots$$
for $q = 3, 5, 7, 11, 13, 17, 19, 23, \dots$. Individually all are far below $1$. But their running sums are
$$0.533,\; 0.744,\; 0.861,\; 0.913,\; 0.952,\; 0.976,\; 0.996,\; \mathbf{1.010},\; \dots$$
and at the *eighth* odd prime the total crosses one bit. Nothing forbids an odd number from collecting eight or more distinct odd prime factors — it just has to be large, since the product of the first eight odd primes already runs to nine digits. One explicit witness:
$$n = 300\,840\,735\,195 = 3^2 \cdot 5 \cdot 7 \cdot 11 \cdot 13 \cdot 17 \cdot 19 \cdot 23 \cdot 29 \cdot 31, \qquad I_{\mathrm{pair}}(n) = 1.0088 > 1.$$
An odd clock, above the cap. The conjectured dichotomy, as a statement about parity, is dead.

What survives is better than what was conjectured, because it explains itself. The correct statement is not about the parity of $n$ but about its *primary components*:

> **The Corrected Dichotomy.** A prime-power clock exceeds one bit exactly when it is a power $2^k$ with $k \ge 2$; the two-power tower obeys $I_{\mathrm{pair}}(2^k) = \frac{4}{3}(1-4^{-k})$ exactly, with supremum $4/3$; every even clock carries at least one bit, and strictly more than one unless $n = 2$; every odd prime power carries at most $39/40$ of a bit; and consequently every odd clock satisfies
> $$I_{\mathrm{pair}}(n) \le \tfrac{39}{40}\,\omega(n),$$
> where $\omega(n)$ counts the distinct prime factors. In particular an odd clock with a single prime factor is strictly below the cap, and an odd clock can break the cap only by accumulating many primary components.

So the wall at one bit is real, but it belongs to the prime $2$, not to parity. Evenness breaks it in one stroke, because $2$ is the only prime whose generator class is a single residue class; oddness breaks it only by a thousand cuts, adding up eight or more independently sub-critical contributions.

## Why this is worth caring about

Three reasons.

First, it is a clean case study in a phenomenon that is everywhere in mathematics: a numerically overwhelming pattern (every $n \le 40$! every $n$ anyone can compute!) that is nonetheless false, and false for a structural reason that only becomes visible once you find the right decomposition. The pattern held to forty; the counterexample has twelve digits. Additivity over prime factors is exactly the kind of structure that lets small, harmless contributions conspire.

Second, the mechanism — that a sum map on a product set has fibres bounded by the smaller factor, so the image is at least the larger — is a genuinely reusable tool. It converts a hard entropy computation into a counting problem about type classes, and it is *tight* exactly when the smaller class is a union of full residue classes modulo the larger, which is a checkable arithmetic condition. Sum-set entropy inequalities of this kind sit at the heart of modern additive combinatorics.

Third, the quantity itself has a natural reading as a side-channel leak. Suppose a device works in $\mathbb{Z}/n\mathbb{Z}$ and, through timing or power consumption, leaks the *orders* of its two secret operands, but not the operands. How much of the output does that leak reveal? The answer: less than one bit, unless $2 \mid n$, in which case at least one bit — and never more than $\frac{4}{3} + \frac{39}{40}\,\omega(n_{\text{odd}})$ bits in total. The prime factorisation of the modulus is precisely the ledger of how much a coarse side channel can betray.

The clock face, it turns out, keeps a different secret depending on whether its number of hours is even. And the amount it keeps is measured, to the last fraction of a bit, by the arithmetic of $2$.
