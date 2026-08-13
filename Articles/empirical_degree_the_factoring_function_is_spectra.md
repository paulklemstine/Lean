# The Silence of the Bits

## Why no simple parity of a public key can whisper a single secret bit — and why the one "anomaly" everybody found turns out to be a ruler, not a key

Take two large prime numbers, multiply them, and publish the answer. That is the whole idea behind most of the encryption that keeps the modern world running. The product $N = pq$ is public; the factors $p$ and $q$ are secret. Everyone believes that recovering $p$ from $N$ is hard. Nobody can prove it.

Faced with a wall like that, mathematicians do what climbers do with an unclimbable face: they map it. If we cannot prove that factoring is hard, we can at least prove that whole *families* of attacks fail. This article is about one such family, and about the strange, beautiful way the last apparent crack in it closed.

The family is the simplest one imaginable. Forget clever algorithms. Just ask: **is some bit of the secret factor a simple XOR of some bits of the public product?**

---

## The question, sharpened

Write the public number in binary: $N = N_{2k-1} N_{2k-2} \cdots N_1 N_0$, a string of $2k$ zeros and ones. Write the smaller secret factor in binary too: $p = p_{k-1} \cdots p_1 p_0$, a string of $k$ bits. Pick a bit position $j$ and ask for a rule that guesses $p_j$ from the bits of $N$.

The simplest possible rules are the **parities**. Choose a set $S$ of positions in $N$ and add up those bits modulo $2$:
$$\chi_S(N) = N_{i_1} \oplus N_{i_2} \oplus \cdots \oplus N_{i_d}, \qquad S = \{i_1, \dots, i_d\}.$$
The size $d = |S|$ is the *degree* of the rule. A degree-$1$ rule says "the secret bit is just this public bit". A degree-$3$ rule says "the secret bit is the XOR of these three public bits". These are the crudest attacks conceivable, and any real attack that starts by fitting a linear or low-degree model over $\mathrm{GF}(2)$ — which is to say, a great many attacks, including much of what a neural network learns first — begins by discovering one.

A rule is worthless if it is right half the time; a coin does that. So the quantity that matters is the **correlation**, the excess over a coin flip:
$$\mathrm{corr}(p_j, \chi_S) = \mathbb{E}\big[(-1)^{p_j} (-1)^{\chi_S(N)}\big],$$
which runs from $-1$ (always wrong, hence always right after flipping) through $0$ (a coin) to $+1$ (always right). The dictionary between the two languages is exact and worth remembering: a rule with correlation $\varepsilon$ is correct on exactly a fraction
$$\frac{1 + \varepsilon}{2}$$
of the inputs. Correlation *is* prediction advantage; there is nothing else hiding in it.

The collection of all these correlations, one for each set $S$, is the **Walsh spectrum** of the secret bit. It is a fingerprint. A random function has a boring, flat fingerprint: every correlation is tiny, of size about $1/\sqrt{m}$ where $m$ is the number of examples, and nothing sticks out. A function with structure has spikes.

So: does the factoring function have spikes?

---

## The census, and the one thing that stuck out

An exhaustive census answers this. For a given size $k$, enumerate every semiprime $N = pq$ with $p$ and $q$ both exactly $k$ bits long and prime, compute the entire spectrum of every secret bit against every parity of degree at most three, and calibrate the result against a null model — the same computation performed on randomly signed data, which tells you exactly how large the largest of thousands of meaningless numbers is expected to be.

The verdict is stark. At $k = 14$ — that is $380{,}628$ semiprimes, all $28$ bits of $N$ in play, $1 + 28 + 378 + 3276 = 3683$ parities of degree at most three examined for each secret bit — every informationally interesting bit of the secret factor shows a maximum correlation of at most $0.021$, against a null-model maximum of $0.0065$ and an all-parity noise level of $0.0101$. Nothing survives. **No parity of three or fewer bits of $N$ predicts any bit of $p$ better than a coin, to within the resolution of the census.** The factoring function looks, spectrally, exactly like a random function.

Exactly one thing broke the flatness, and it was not subtle. The top handful of bits of the secret factor — the ones that say how *big* $p$ is, not what $p$ *is* — correlate strongly with the top bit of $N$, at levels around $0.29$, $0.31$, $0.13$, $0.065$, $0.026$ as you walk down from the second-highest bit. And in earlier, smaller-scale runs, one more oddity had been logged and never explained: at $k = 10$, the low bit $p_2$ showed a correlation of $0.166$, some $1.7$ times the noise. A small crack, but a crack, sitting in the *low* half of the factor where no magnitude effect has any business being.

This article is about closing both.

---

## Why the low bits are silent: a two-line proof

Here is the surprise. The silence of the low bits is not an empirical near-miss to be measured ever more finely. On the right support it is an **exact theorem**, and its proof fits in a paragraph.

Change the question slightly. Instead of the full integers, work modulo $2^t$: let $p$ and $q$ range over *all* odd residues mod $2^t$ — there are $2^{t-1}$ of them — and let the public value be the low block $N = pq \bmod 2^t$.

**The Zero-Block Theorem.** *For every bit position $1 \le j < t$ and every real-valued statistic $g$ whatsoever of the public value,*
$$\sum_{p}\sum_{q} (-1)^{p_j}\, g(pq \bmod 2^t) = 0.$$

Not "small". Not "$O(m^{-1/2})$". Zero, exactly, always.

The proof has two moves, and both are one-liners.

*Move one: the product hides nothing, because multiplication shuffles.* Fix $p$. Since $p$ is odd, it is invertible modulo $2^t$, so the map $q \mapsto pq \bmod 2^t$ is a **bijection** of the odd residues onto themselves. As $q$ runs over the whole support, the public value $N$ runs over the whole support too, in some scrambled order. Therefore the inner sum $\sum_q g(pq)$ equals $\sum_N g(N)$ — the *same number for every $p$*. The public value, viewed across the whole support, carries not one bit of information about which $p$ produced it.

*Move two: the secret bit is balanced, because flipping is an involution.* What is left is $\big(\sum_p (-1)^{p_j}\big) \cdot \big(\sum_N g(N)\big)$, and the first factor vanishes: the map $p \mapsto p \oplus 2^j$, which flips bit $j$ and leaves everything else alone, sends odd residues to odd residues (because $j \ge 1$, so it never touches the last bit), stays inside the range (because $j < t$), is its own inverse, and reverses the sign $(-1)^{p_j}$. A sign-reversing involution forces the sum to be zero.

Two bijections, and the correlation is annihilated. The theorem says something considerably stronger than the census asked. It quantifies over *all* statistics $g$ — every parity of every degree, every polynomial in the bits, every neural network, every oracle — and the conclusion is not a bound but an identity. It follows that **any** predictor $h$ that reads only the public low block and guesses bit $j$ of the secret factor is correct on *exactly* half the pairs: not one pair more, not one pair fewer.

And the mechanism is not about primes at all. Strip away the arithmetic and what remains is a statement about groups: on any finite group, if a function $u$ of the first factor has mean zero, then $\sum_{a,b} u(a)\, g(ab) = 0$ for every $g$. The regular representation acts simply transitively; that is the entire content. Factoring's low bits are silent for the same reason a one-time pad is secure.

In fact the theorem upgrades to **perfect secrecy**. Fix a public value $N$ and look at its fiber — all the pairs $(p, q)$ that produce it. Every fiber has exactly $2^{t-1}$ points, and the secret factors appearing in it are *all* $2^{t-1}$ odd residues, each exactly once. So two different public values induce literally identical distributions over the secret factor: any property at all — any bit, any bit pattern, any predicate — has exactly the same count under $N$ as under $N'$. A guessing strategy that names one candidate value for the whole secret low block hits at most one of the $2^{t-1}$ points in the fiber. Its success rate is the success rate of a blind guess.

---

## Why the top bits are loud: a ruler, not a key

So what *was* the census seeing at the top?

Something completely deterministic, and completely harmless. Suppose $p$ and $q$ are balanced $k$-bit numbers, $2^{k-1} \le p \le q < 2^k$, and suppose the second-highest bit of the smaller one is set: $p_{k-2} = 1$. Then $p \ge 2^{k-1} + 2^{k-2} = 3 \cdot 2^{k-2}$, and since $q \ge p$ we get
$$N = pq \ \ge\ 9 \cdot 2^{2k-4} \ >\ 8\cdot 2^{2k-4} = 2^{2k-1}.$$
Since also $N < 2^{2k}$, this says exactly that the top bit of the product is set.

**The Top-Bit Transmission Law.** *For balanced $k$-bit factors, $p_{k-2} = 1$ implies $N_{2k-1} = 1$. Equivalently: if the product fails to carry into its top bit, the second-highest bit of the smaller factor is necessarily $0$.*

There is the "anomaly", in full. It is arithmetic so elementary a child could check it, and it explains the strongest signal in a scan of tens of millions of correlations. Better, one can prove the correlation is *genuinely* nonzero at every size: the event $\{p_{k-2} = 1\}$ is never empty (take $p = q = 3 \cdot 2^{k-2}$), the event $\{N_{2k-1} = 1\}$ is never everything (take $p = q = 2^{k-1}$, whose product is $2^{2k-2}$), and one event contains the other — so the covariance, which for nested events $A \subseteq B$ equals $\mathbb{P}(A)\big(1 - \mathbb{P}(B)\big)$, is strictly positive for every $k$. Exact enumeration gives $0.1800$, $0.1389$, $0.1187$, $0.1073$, $0.1025$, $0.0995$ at $k = 3, \dots, 8$, visibly converging.

Converging to what? Rescale: write $p = 2^{k-1}x$ and $q = 2^{k-1}y$, so the balanced support becomes the triangle $\{(x,y) \in [1,2]^2 : x \le y\}$ of area $1/2$. The event $p_{k-2} = 1$ becomes $x \ge 3/2$, of probability $1/4$; the carry-out event becomes $xy \ge 2$, of probability $2(1 - \log 2)$. The nesting survives, so the covariance tends to
$$\frac{1}{4}\Big(1 - 2(1-\log 2)\Big) = \frac{2\log 2 - 1}{4} = 0.0965735\ldots$$
The numbers above are marching straight at it. Translated into the language of prediction — where a correlation $\varepsilon$ means being right a fraction $(1+\varepsilon)/2$ of the time — this says the top-bit signal converges to correlation $4\log 2 - 5/2 = 0.2726$, or an accuracy of $63.6\%$: real, permanent, and entirely about size.

The crucial point is what this signal *is*. The predicate "$N \ge 2^{2k-1}$" is a statement about the **size** of $N$, computable from $N$ alone in one glance, and — this is the punchline — **symmetric in $p$ and $q$**. It cannot tell the two factors apart. It is a ruler laid against the product, not a key. Knowing that $N$ carried into its top bit narrows the factors to a slightly smaller box; it does not begin to say which point in the box they are. And the law is strictly one-sided, as it must be: $17 \times 31 = 527$ and $29 \times 31 = 899$ are both balanced $5$-bit semiprimes whose products have the same top bit set, yet the second-highest bit of the smaller factor is $0$ for one and $1$ for the other. The same pair of products $527$ and $19 \times 29 = 551$ agree in the top bit of $N$ and disagree in bit $1$ of the smaller factor. The top bit constrains; it never determines.

---

## And the $j = 2$ anomaly?

It was the same ruler, seen through a small window.

When the single-bit spectrum at $k = 10$ is opened up, the winning partner for $p_2$ is not some exotic low-order parity: it is $N_{2k-1}$, the top bit, the product-magnitude indicator. And when the correlation is tracked with size, it collapses: exhaustive enumeration over exact $k$-bit prime semiprimes gives
$$\mathrm{corr}(p_2, N_{2k-1}) = +0.254,\ +0.166,\ -0.013,\ -0.006 \quad\text{at } k = 8, 10, 12, 14,$$
with sign flips along the way at the odd sizes, against noise floors $m^{-1/2}$ of $0.060,\, 0.019,\, 0.0055,\, 0.0016$. A real effect does not change sign. A finite-sample fluctuation of the size family does exactly that, and then decays into the floor — while over the very same data the top-bit signal $\mathrm{corr}(p_{k-2}, N_{2k-1})$ sits stubbornly at $0.285$, indistinguishable from the exact limiting value $4\log 2 - 5/2 = 0.2726$ that the geometry above predicts, and refuses to move. Flat low block, loud top block, and nothing in between: the crack closes.

---

## What flatness costs

There is a last twist, and it is the one that makes "flat" a substantive claim rather than an absence of one. A spectrum cannot be flat all the way down. The total spectral mass of any $\pm 1$-valued function is exactly $1$ — this is Parseval's identity, $\sum_S \mathrm{corr}(f, \chi_S)^2 = 1$ — so the mass has to live somewhere. Three consequences follow immediately and they are worth stating.

*There is a floor.* Some parity always achieves $|\mathrm{corr}| \ge 2^{-n/2}$ on $n$-bit inputs; nothing is flatter than random.

*Heavy coefficients are rare.* At most $\varepsilon^{-2}$ parities can have correlation $\varepsilon$ or more. With $\varepsilon = 0.021$ that is at most $2267$ of them, out of $2^{28}$.

*Flat means spread.* If the whole spectrum is bounded by $\varepsilon$, then at least $\varepsilon^{-2}$ parities must carry nonzero mass. And if the low-degree scan comes back empty, then a fraction at least $1 - \varepsilon^2 \cdot \#\{S : |S| \le d\}$ of the entire mass provably sits on parities of degree greater than $d$. The census's $3683$ low-degree parities at correlation $0.021$ account for at most $3683 \times 0.021^2 \approx 1.6$ of the unit mass — right at the boundary where the quantitative statement bites, and precisely the reason the exact theorem, rather than the measurement, is what settles the matter.

So flatness is not the absence of structure. It is the statement that the structure has fled to high degree, spread across astronomically many coefficients, each one individually invisible. That is what a hard function looks like from the outside.

---

## What has actually been shown

Three things, and it is worth separating them cleanly.

First, on the low block modulo $2^t$ — over all odd pairs — the correlation between any bit of the secret factor and any function of the public value is **exactly zero**, with perfect secrecy behind it. The barrier here is not a bound with a constant; it is an identity.

Second, the one signal the spectrum does see is the top-bit magnitude family, governed by a deterministic transmission law, with a strictly positive covariance at every size and an explicit limiting constant $(2\log 2 - 1)/4$. It is symmetric in the two factors and readable from $N$ alone, so it reveals size, not factorization.

Third, everything in between — the $j = 2$ curiosity, the low-half cubic correlations decaying from $0.203$ to $0.013$ across the sizes — behaves exactly like sampling noise on a finite prime support, at the $1/\sqrt{\#\text{primes}}$ scale, and there are honest reasons why: the sign-reversing involution $p \mapsto p \oplus 2^j$ that makes the exact theorem work does not respect the convention "$p$ is the *smaller* factor", and the residue does not respect the restriction to primes. Exhaustive computation confirms this diagnosis in the sharpest possible way: restricted to the ordered support $p < q$, the largest correlation in the entire spectrum always sits at the *highest* bit of $p$ with the *empty* parity — that is, it is not a parity of $N$ at all, but the order statistic itself. The defect is a magnitude effect wearing a different hat.

None of this proves factoring is hard. What it does is retire an entire attack surface. Anyone hoping to learn a bit of a secret factor by finding the right XOR of bits of the public key is looking at a function that is, in the exact sense above, as featureless as a random one — except for a ruler that tells you how big the numbers are, which you knew already. It is a negative result with positive content: the wall has been mapped a little further, and where the map showed a crack, there is stone.
