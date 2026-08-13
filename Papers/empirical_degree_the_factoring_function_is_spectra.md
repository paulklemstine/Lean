# The Silence of the Bits
### A guided tour of spectral flatness in the factoring problem

Multiply two large primes, publish the product, keep the factors. That single asymmetry carries an
enormous amount of the world's encrypted traffic. Nobody can prove that recovering the factors is
hard — but we *can* prove that entire families of attacks are doomed. This page is a guided tour of
one such proof, and of the one signal that survives it.

The attack family we retire here is the simplest imaginable: **XOR a handful of bits of the public
number $N$ and hope the answer equals a bit of the secret factor $p$.**

---

## 1. The question, in one picture

Write $N$ in binary as $N_{2k-1}\cdots N_1 N_0$ and the smaller factor as $p_{k-1}\cdots p_1p_0$.
For a set $S$ of positions, the *parity* rule is
$$\chi_S(N) \;=\; \bigoplus_{i\in S} N_i,$$
and its quality is measured by the correlation
$$\mathrm{corr}(p_j,\chi_S) \;=\; \mathbb{E}\big[(-1)^{p_j}(-1)^{\chi_S(N)}\big] \in [-1,1].$$

The dictionary between the two languages is exact, and it is the only piece of formalism you need
for the whole page:

> **Correlation is prediction advantage.** A rule with correlation $\varepsilon$ is right on exactly
> a fraction $\tfrac{1+\varepsilon}{2}$ of the inputs. Correlation $0$ means a coin.

The collection of all these numbers, one per set $S$, is the **Walsh spectrum** of the secret bit —
a fingerprint. A random function has a boring fingerprint: everything sits at the noise level
$m^{-1/2}$, where $m$ is the number of examples. A structured function has spikes.

So: does the factoring function have spikes? Here is the whole answer in one image.

{{visualization:0}}

A big cold rectangle, and a small hot corner. The rest of this page explains both — and it turns
out that the cold part is *exactly* zero, and the hot part is a ruler, not a key.

---

## 2. Play with the theorem before you read it

The cleanest statement lives modulo $2^t$: let $p$ and $q$ range over **all** odd residues mod
$2^t$, and let the public value be the low block $N = pq \bmod 2^t$. Then, for every bit
$1\le j<t$, the entire spectrum of $p_j$ is zero.

Not small. Zero. Every bar, exactly.

The widget below computes the full spectrum live. Move the sliders; then tick the boxes to break a
hypothesis of the theorem and watch *how* it fails — the failure is as informative as the theorem.

{{interactive_demo:0}}

<details>
<summary><b>Click to reveal the two-line proof</b></summary>

**The Zero-Block Theorem.** *For $t\ge 2$, $1\le j<t$ and **every** real-valued statistic $g$ of the
public value,*
$$\sum_{p}\sum_{q}(-1)^{p_j}\,g(pq \bmod 2^t) \;=\; 0 .$$

*Proof.* Two bijections.

1. **Multiplication shuffles.** Fix $p$. Since $p$ is odd it is invertible mod $2^t$, so
   $q\mapsto pq \bmod 2^t$ is a bijection of the odd residues onto themselves. Hence the inner sum
   equals $\sum_N g(N)$ — the *same number for every $p$*.
2. **Flipping is an involution.** What remains is
   $\big(\sum_p(-1)^{p_j}\big)\big(\sum_N g(N)\big)$, and the first factor vanishes because
   $p\mapsto p\oplus 2^j$ maps odd residues to odd residues (it never touches bit $0$, as $j\ge 1$),
   stays in range (as $j<t$), is its own inverse, and reverses the sign. $\blacksquare$

Note what is *not* assumed: $g$ is arbitrary. Every parity of every degree, every polynomial in the
bits, every look-up table, every trained model. All of them have correlation exactly zero.
</details>

<details>
<summary><b>Click to reveal the strengthening: perfect secrecy</b></summary>

Fix a public value $N$ and look at its **fiber**, the set of pairs producing it. Because
$q = p^{-1}N$ is determined by $p$, every fiber contains each of the $2^{t-1}$ odd residues exactly
once as a secret factor. Therefore:

* every fiber has exactly $2^{t-1}$ points;
* for **any** property $P$ whatsoever, $\#\{p\in\mathrm{Fib}(N):P(p)\}$ is the same for every $N$ —
  distinct public values induce *identical* distributions on the secret;
* a strategy that names one candidate for the whole secret low block hits at most one fiber point,
  i.e. succeeds with probability exactly $2^{-(t-1)}$, the blind-guess rate.

The mechanism is not arithmetic at all. On **any** finite group, if $u$ has mean zero then
$\sum_{a,b}u(a)g(ab)=0$: the regular representation is simply transitive. Factoring's low bits are
silent for the same reason a one-time pad is secure. (For background see
[Boolean Fourier analysis](https://en.wikipedia.org/wiki/Analysis_of_Boolean_functions) and the
[Walsh–Hadamard transform](https://en.wikipedia.org/wiki/Fast_Walsh%E2%80%93Hadamard_transform).)
</details>

The certificate behind the widget is a finite, exact computation — no floating point anywhere:

{{algorithm:1}}

---

## 3. So what *was* the census seeing?

Something completely deterministic, and completely harmless. Suppose $2^{k-1}\le p\le q<2^k$ and the
second-highest bit of the smaller factor is set, $p_{k-2}=1$. Then $p\ge 3\cdot 2^{k-2}$, hence
$q\ge p\ge 3\cdot 2^{k-2}$, hence
$$N \;\ge\; 9\cdot 2^{2k-4}\;>\;8\cdot 2^{2k-4} \;=\; 2^{2k-1},$$
so the product **must** carry into its top bit.

> **The Top-Bit Transmission Law.** For balanced $k$-bit factors, $p_{k-2}=1$ implies
> $N_{2k-1}=1$. Equivalently: if $N<2^{2k-1}$ then necessarily $p_{k-2}=0$.

Click around the square below: pick a pair of factors, read off the bits, and see the law fire (or
stay silent, which is just as important — the implication is strictly one-sided).

{{interactive_demo:1}}

<details>
<summary><b>Click to reveal why the correlation is strictly positive at every size — and what its exact limit is</b></summary>

Write $A=\{p_{k-2}=1\}$ and $B=\{N_{2k-1}=1\}$. The law says $A\subseteq B$, so
$$\mathrm{cov}(A,B) \;=\; \mathbb{P}(A)\big(1-\mathbb{P}(B)\big).$$
Now $A$ is never empty ($p=q=3\cdot2^{k-2}$ works) and $B$ is never everything
($p=q=2^{k-1}$ gives $N=2^{2k-2}<2^{2k-1}$), so the covariance is **strictly positive at every
size** — in stark contrast with the exactly-vanishing low block.

For the limit, rescale $p=2^{k-1}x$, $q=2^{k-1}y$: the support becomes the triangle
$\mathcal S=\{1\le x\le y\le 2\}$ of area $1/2$, the event $A$ becomes $\{x\ge 3/2\}$ with
$\mathbb{P}(A)=1/4$, and $B$ becomes $\{xy\ge 2\}$ with
$\mathbb{P}(B)=2(1-\log 2)=0.61371\ldots$ Hence
$$\mathrm{cov}\;\longrightarrow\;\frac{2\log 2-1}{4}=0.0965735\ldots,
\qquad \mathrm{corr}\;\longrightarrow\;4\log 2-\tfrac52 = 0.2725887\ldots$$
The measured value of that coefficient on the prime support at $k=14$ is $0.285$.
</details>

{{visualization:1}}

And the exact arithmetic behind that curve, in $O(2^k)$ rather than $O(4^k)$:

{{algorithm:2}}

**Why this signal is harmless.** The predicate $N\ge 2^{2k-1}$ is a statement about the *size* of
$N$, readable from $N$ in one glance, and **symmetric in $p$ and $q$** — it cannot tell the two
factors apart. It is a ruler laid against the product, not a key.

---

## 4. The anomaly that wasn't

For years one number resisted explanation: at $k=10$, the *low* bit $p_2$ correlated at $0.166$ with
something, roughly $1.7$ times the noise. A low bit has no business knowing about magnitude.

Open up the spectrum and the winning partner is… $N_{2k-1}$, the top bit. And then track it with
size:

$$\mathrm{corr}(p_2,N_{2k-1}) \;=\; +0.254,\ +0.166,\ -0.013,\ -0.006 \qquad (k=8,10,12,14).$$

It **alternates in sign** and **decays to the noise floor**. A structural correlation does neither.
Over the identical data the genuine top-bit coefficient sits at $0.285$ and never budges.

{{visualization:2}}

<details>
<summary><b>Click to reveal how a maximum over thousands of parities should be calibrated</b></summary>

The maximum of $|\mathcal F|$ near-independent standardised coefficients concentrates near
$\sqrt{2\log|\mathcal F|}$ in units of the noise floor $m^{-1/2}$. At $k=14$ ($n=28$ bits,
$m=380628$ semiprimes) this predicts an all-parity maximum of about $6.2\,m^{-1/2}=0.0101$ —
exactly the observed noise level. So a scan returning a maximum of $0.021$ over $3683$ degree-$\le3$
parities is reporting *noise*, not signal. Calibration is not a detail; it is the entire difference
between a discovery and a mirage.
</details>

{{algorithm:3}}

---

## 5. Flatness is not emptiness

One last twist, and it is what makes "flat" a claim rather than an absence of one. For any
$\pm1$-valued function, [Parseval's identity](https://en.wikipedia.org/wiki/Parseval%27s_identity)
fixes the total spectral mass:
$$\sum_S \mathrm{corr}(f,\chi_S)^2 \;=\; 1 .$$
The mass has to live *somewhere*. Three consequences:

* **There is a floor.** Some parity always achieves $|\mathrm{corr}|\ge 2^{-n/2}$: nothing is flatter
  than random.
* **Heavy coefficients are rare.** At most $\varepsilon^{-2}$ parities can reach correlation
  $\varepsilon$.
* **Flat means spread.** A spectrum bounded by $\varepsilon$ must be supported on at least
  $\varepsilon^{-2}$ parities, and if the degree-$\le d$ scan comes back empty then at least
  $1-\varepsilon^2\cdot\#\{S:|S|\le d\}$ of the mass provably sits above degree $d$.

So flatness says the structure has *fled to high degree*, spread over astronomically many
individually invisible coefficients. That is exactly what a pseudorandom function looks like from
the outside.

The transform that makes such a scan feasible at all — $O(n2^n)$ instead of $O(4^n)$:

{{algorithm:0}}

---

## 6. Run the whole story yourself

Everything above is a finite computation. This script reproduces each claim end to end: exact zero
correlations fiber by fiber, perfect secrecy of the low block, the ordering defect and its
magnitude-statistic signature, the transmission law with its one-sided counterexamples, and the
decay of the anomaly.

{{demo:0}}

---

## 7. What has actually been shown

1. **On the low block, exactly flat.** Over all odd pairs mod $2^t$, every bit of the secret factor
   is uncorrelated with *every* statistic of the public value — an identity, not a bound — and each
   public value induces the same distribution on the secret as every other.
2. **One non-flat family, and it is symmetric.** The top-bit magnitude/carry structure obeys a
   deterministic one-sided law, has strictly positive covariance at every size with limit
   $(2\log2-1)/4$ (correlation $4\log 2-5/2$), and is symmetric in $p$ and $q$: it reveals size,
   never identity.
3. **Everything in between is noise.** The low-bit anomaly and the decaying low-half cubic
   correlations are finite-support fluctuations at the $1/\sqrt{\#\text{primes}}$ scale, with an
   honest explanation for why they exist at all: the sign-reversing involution that powers the exact
   theorem does not respect the convention "$p$ is the smaller factor", and exhaustive computation
   shows the residual defect is precisely the order statistic — a magnitude effect wearing a
   different hat.

None of this proves factoring is hard. What it does is retire an attack surface: on this face of the
problem, there is nothing to find but a ruler.
