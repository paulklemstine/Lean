# The Shape of a Prime: How Much a Product Tells You About Its Factors

## A question about secrets

Here is a very old game, played with two players and one number.

Alice picks two large primes, $p$ and $q$, multiplies them, and hands you the product $N = pq$. You are not allowed to factor it — that is the whole point. But you *are* allowed to ask questions about $p$ and $q$ that don't require knowing them: questions whose answers can be squeezed out of $N$ itself.

The classic question is a coin flip. Fix a quadratic field, say $\mathbb{Q}(\sqrt 5)$, and ask of each prime: *does it split or stay inert?* That is one bit per prime, and the two bits are not independent of $N$ — the Legendre symbol is multiplicative, so $N$ hands you the **product** of the two answers for free. Knowing the product of two coin flips is worth exactly one bit. And there the story seemed to stop. Any *binary* symmetric fork of this kind is capped at one bit: you learn the parity of the pair, and nothing more. A hard ceiling.

This article is about what happens when you refuse to ask a yes/no question.

## Primes have shapes, not just answers

Go up from the quadratic field $\mathbb{Q}(\sqrt5)$ to a cyclotomic field $\mathbb{Q}(\zeta_f)$, where $\zeta_f = e^{2\pi i/f}$ is a primitive $f$-th root of unity and $f$ is prime. This field has a symmetry group — its Galois group — which is exactly the multiplicative group of nonzero residues mod $f$:
$$\mathrm{Gal}\big(\mathbb{Q}(\zeta_f)/\mathbb{Q}\big) \;\cong\; (\mathbb{Z}/f)^{\times} \;\cong\; C_n, \qquad n = f-1,$$
a **cyclic** group of order $n$.

Now take any prime $p \ne f$. Inside $\mathbb{Q}(\zeta_f)$ it does not stay prime; it breaks into pieces. And the way it breaks is completely determined by one integer:
$$T(p) \;=\; \mathrm{ord}_f(p) \;=\; \text{the smallest } k \ge 1 \text{ with } p^k \equiv 1 \pmod f .$$
The prime $p$ splits into exactly $n/T(p)$ distinct prime ideals, each of *residue degree* $T(p)$. We call $T(p)$ the **splitting type** of $p$. It is not a bit. It is a divisor of $n$ — and for $\mathbb{Q}(\zeta_{13})$, with $n = 12$, there are six possible values: $1, 2, 3, 4, 6, 12$.

The old binary question — "does $p$ split completely?" — is the single coarse question "is $T(p) = 1$?". It throws away almost everything. The type is the whole shape; the yes/no answer is one shadow of it.

Two facts make the type an unusually clean object to reason about.

**It is exact.** $T(p)$ depends only on the residue $p \bmod f$, and it is a *deterministic function* of that residue. In the language of information: if you know $p \bmod f$, you know the type with no uncertainty, so the residue-to-type channel transmits the full entropy of the type,
$$I(p \bmod f\;;\;T) \;=\; H(T),$$
with no leakage and no loss. There is no approximation here and no error term.

**It does not thicken.** Refine your observation from $p \bmod f$ to $p \bmod f^2$, or mod any multiple of $f$: you learn nothing new about $T$. The type lives on the residue mod $f$ and nowhere finer. Extra precision buys exactly zero additional bits.

## The Euler law for shapes

How often does each shape occur? Under the natural (Chebotarev) equidistribution of Frobenius elements — equivalently, sampling a residue uniformly from the cyclic group $C_n$ — the answer is one of the prettiest counting facts in elementary number theory.

> **The Euler-$\varphi$ Type Law.** For every divisor $d$ of $n$, exactly $\varphi(d)$ of the $n$ residues have splitting type $d$. Hence
> $$\Pr[\,T = d\,] \;=\; \frac{\varphi(d)}{n}, \qquad d \mid n,$$
> where $\varphi$ is Euler's totient function.

The proof is a single line once you set it up right. Write the cyclic group additively as $\mathbb{Z}/n$; the type of an element $x$ is its additive order, $T(x) = n/\gcd(n,x)$. Then $T(x) = d$ exactly when $\gcd(n,x) = n/d$, and the elements of $\mathbb{Z}/n$ with a prescribed gcd $n/d$ are precisely the multiples of $n/d$ that are coprime to $d$ — there are $\varphi(d)$ of them. Summing over divisors recovers the classical identity $\sum_{d \mid n}\varphi(d) = n$: every residue has exactly one shape.

For $\mathbb{Q}(\zeta_5)$, $n = 4$, the shapes are $\{1,2,4\}$ with probabilities $\tfrac14, \tfrac14, \tfrac12$. For $\mathbb{Q}(\zeta_7)$, $n = 6$, the shapes are $\{1,2,3,6\}$ with probabilities $\tfrac16,\tfrac16,\tfrac13,\tfrac13$.

Feeding this into Shannon's formula gives a closed expression for how much information one prime's shape carries:
$$H(T) \;=\; \log_2 n \;-\; \frac{1}{n}\sum_{d \mid n} \varphi(d)\log_2 \varphi(d).$$
For $\mathbb{Q}(\zeta_5)$ this is exactly $\tfrac32$ bits. For $\mathbb{Q}(\zeta_7)$ it is $\log_2 6 - \tfrac13 \approx 1.9183$ bits. Compare that with the single bit available in the quadratic case: the shape of a prime in a cyclotomic field is a genuinely richer object.

And the coarse yes/no readout? "Does $p$ split completely?" is true for exactly one residue out of $n$, so its entropy is the binary entropy of $1/n$:
$$H(\text{splits completely?}) \;=\; \log_2 n - \frac{n-1}{n}\log_2 (n-1).$$
For $n=4$ that is $2 - \tfrac34\log_2 3 \approx 0.8113$ bits — call it the *quartic pinning*, an exact value nailed down by the quartic character alone. Against $H(T) = 1.5$ bits, the yes/no readout is throwing away nearly half the signal. When $n$ is prime the two coincide (a prime cyclic order has only two shapes, so the type *is* binary); when $n$ is composite the coarse readout is strictly lossy. **The type, not the root count, is the complete object.**

## Two primes and a product

Now return to Alice's game, but ask the multi-state question instead of the binary one.

Alice's semiprime is $N = pq$. What you can see is:

* the **norm class** $N \bmod f$, which you can compute from $N$ directly, and
* nothing about $p$ and $q$ individually.

What you would like to know is the **unordered type pair** $\{T(p), T(q)\}$ — the shapes of the two hidden factors, without labels, since $N$ can never tell you which factor is which.

Because the residue map is multiplicative, $N \bmod f$ is the *product* of the two residues in the cyclic group $C_n$. Take discrete logarithms and the picture becomes purely additive: choose $x, y$ uniformly and independently from $\mathbb{Z}/n$, let their shapes be $T(x) = n/\gcd(n,x)$ and $T(y)$, and let the visible norm class be $x + y \bmod n$. The quantity we want is the mutual information between the observable and the hidden pair,
$$I_{\mathrm{pair}}(n) \;=\; H(\Pi) \;-\; \frac{1}{n}\sum_{c \in \mathbb{Z}/n} H(\Pi_c),$$
where $\Pi$ is the distribution of the unordered pair $\{T(x),T(y)\}$ and $\Pi_c$ is that same distribution conditioned on $x + y = c$. Every ingredient is a finite sum over a finite group, so this is not a statistical estimate — it is an exact real number, computable in closed form.

Here is what comes out.

| cyclic order $n$ | field | shapes | $H(T)$ | $I_{\mathrm{pair}}$ | exact value |
|---|---|---|---|---|---|
| $2$ | $\mathbb{Q}(\sqrt 5)$ | $2$ | $1$ | $1.0000$ | $1$ |
| $3$ | — | $2$ | $0.9183$ | $0.4739$ | $\log_2 3 - \tfrac{10}{9}$ |
| $4$ | $\mathbb{Q}(\zeta_5)$ | $3$ | $1.5$ | $\mathbf{1.2500}$ | $\tfrac54$ |
| $6$ | $\mathbb{Q}(\zeta_7)$ | $4$ | $1.9183$ | $\mathbf{1.4739}$ | $\log_2 3 - \tfrac19$ |
| $8$ | — | $4$ | $1.75$ | $\mathbf{1.3125}$ | $\tfrac{21}{16}$ |
| $10$ | $\mathbb{Q}(\zeta_{11})$ | $4$ | $1.7219$ | $\mathbf{1.2027}$ | $\log_2 5 + \tfrac{12}{25}\log_2 3 - \tfrac{47}{25}$ |
| $12$ | $\mathbb{Q}(\zeta_{13})$ | $6$ | $2.4183$ | $\mathbf{1.7239}$ | $\log_2 3 + \tfrac{5}{36}$ |
| $16$ | $\mathbb{Q}(\zeta_{17})$ | $5$ | $1.875$ | $\mathbf{1.3281}$ | $\tfrac{85}{64}$ |

The first row is the classical story: the quadratic fork sits *exactly* at one bit, reproducing the old cap on the nose. Every even order after it breaks through. And every odd order — $3, 5, 7, 9, 11, 13, 15$ — stays strictly below.

The one-bit ceiling was never a law of nature. It was a property of asking binary questions.

## Three laws that govern the numbers

The values in that table are not a random scatter. They obey three exact laws.

**1. Coprime channels add.** If $n = mk$ with $\gcd(m,k) = 1$, then
$$I_{\mathrm{pair}}(mk) \;=\; I_{\mathrm{pair}}(m) + I_{\mathrm{pair}}(k).$$
For instance $I_{\mathrm{pair}}(12) = I_{\mathrm{pair}}(4) + I_{\mathrm{pair}}(3) = \tfrac54 + (\log_2 3 - \tfrac{10}{9}) = \log_2 3 + \tfrac5{36}$, and $I_{\mathrm{pair}}(15) = I_{\mathrm{pair}}(3) + I_{\mathrm{pair}}(5)$, and $I_{\mathrm{pair}}(20) = I_{\mathrm{pair}}(4)+I_{\mathrm{pair}}(5)$. The reason is the Chinese Remainder Theorem: the cyclic group splits as $\mathbb{Z}/m \times \mathbb{Z}/k$, and the type map factors as a product $T = T_m \cdot T_k$ of *coprime* components. The unordered pair in the big group is reconstructible from the unordered pairs in the two components, and the ambiguity in matching them up is cancelled exactly by conditioning on the norm class in each factor. The channel is a tensor product; its information is a sum.

**2. Doubling an odd order buys exactly one bit.** For odd $m$,
$$I_{\mathrm{pair}}(2m) \;=\; I_{\mathrm{pair}}(m) + 1.$$
This is the additivity law applied with $k = 2$, and it identifies the classical quadratic bit as a *summand* of the general channel — the old cap is the $C_2$ factor, and everything else rides on top of it. So $I_{\mathrm{pair}}(6) = I_{\mathrm{pair}}(3) + 1$, $I_{\mathrm{pair}}(10) = I_{\mathrm{pair}}(5)+1$, $I_{\mathrm{pair}}(14) = I_{\mathrm{pair}}(7)+1$.

**3. The two-power tower converges to $4/3$.** For $n = 2^k$ the shape is essentially the $2$-adic valuation, and the valuation of a sum is the minimum of the valuations unless they collide. That self-similarity produces the exact law
$$I_{\mathrm{pair}}(2^k) \;=\; \frac43\left(1 - 4^{-k}\right):$$
$1, \tfrac54, \tfrac{21}{16}, \tfrac{85}{64}, \dots$ strictly increasing, and never reaching its limit of $\tfrac43$ bits. A purely $2$-power cyclic group can leak at most one and a third bits about its hidden pair, no matter how large it is.

Together these say something structural: the information content of the channel is governed by the *divisor structure* of the cyclic order. Rich divisor lattices give rich channels. Among the small orders, $n = 12$ — six shapes, the divisor lattice of $12$ — is the champion at $1.7239$ bits.

They also explain the even/odd pattern in the table. Since $C_2$ is the unique quotient whose type pair *is* the norm class (the split-count fork, worth exactly one bit), an even order carries $1 + I_{\mathrm{pair}}(\text{odd part}) \ge 1$ bits, while an odd order carries only the strictly sub-critical contribution of its odd factors. Exceeding the cap and having even order look like the same condition — verified for every cyclic order up to $40$, and proved outright for all the orders listed in the table.

## What the split-count sees, and what it misses

There is a satisfying consistency check hidden in all this. The old binary observable — the number of prime factors, or equivalently "how many roots does the defining polynomial have mod $p$" — is a *projection* of the type. Push the type channel down along that projection and you recover exactly the classical split-count information, no more and no less. The classical quantity is one face of the richer object, and the richer object strictly dominates it.

Where does the information get lost? In the collapse. For $\mathbb{Q}(\zeta_5)$ the root count cannot distinguish a prime whose ideal factorisation looks like $[2,2]$ from one that looks like $[4]$ — both give "no roots". For $\mathbb{Q}(\zeta_7)$ the patterns $[2,2,2]$, $[3,3]$ and $[6]$ are all flattened into the same answer. Each collapse is a merge of distinct states, and merging states can only destroy entropy. That is precisely why the root-count entropy sits strictly below $H(T)$ for every composite order, and why it agrees with it for prime orders, where nothing is merged.

## Why this matters — and why it doesn't break anything

It is tempting to read all this as a crack in the wall around factoring. It isn't, and the reasons are worth stating precisely.

First, the channel is **symmetric**: the pair $\{T(p),T(q)\}$ is unordered by construction, and the amount of information about *which* factor has which shape is essentially zero. You may learn that one of the two hidden primes splits completely in $\mathbb{Q}(\zeta_7)$ — you will not learn which one.

Second, the whole channel is a function of one small residue, $N \bmod f$. It is a dial with $f-1$ positions. To learn about $p$ and $q$ from it you would need to invert the Chinese-Remainder-style mixing, and the leak per modulus stays bounded — $4/3$ bits for two-power orders, and modest constants elsewhere — while the number of bits needed to specify a factor grows with the size of the primes.

Third, the whole edifice sits on classical foundations: cyclotomic fields, Dirichlet characters, the Chinese Remainder Theorem, and Chebotarev's density theorem from 1922. Nothing here is new machinery; what's new is the *measurement*.

And that is the point. The result is not a new attack, it is a new accounting. For a century the folklore has been that a product of two primes tells you a single bit about the pair — the parity of a character. What the multi-state analysis shows is that this bit was an artifact of only ever asking binary questions. Ask the complete question — *what shape does each factor have?* — and the answer is $1.25$ bits in $\mathbb{Q}(\zeta_5)$, $1.4739$ in $\mathbb{Q}(\zeta_7)$, $1.7239$ in $\mathbb{Q}(\zeta_{13})$, with exact closed forms in each case, governed by a clean additivity law over the divisor lattice.

Old ceilings often turn out to be ceilings on the questions, not on the world. This one was.
