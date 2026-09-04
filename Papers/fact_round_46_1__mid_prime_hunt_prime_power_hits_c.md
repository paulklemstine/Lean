# The Hidden Ledger

### Why repeated small primes tell you which numbers factor easily

---

## 0 · A number's secret budget

Pick a whole number and ask a deceptively simple question: is it built only out of **small** prime bricks?

$$1{,}048{,}575 \;=\; 3 \cdot 5^2 \cdot 11 \cdot 31 \cdot 41$$

The largest brick here is $41$. If "small" means "at most $50$", this number passes. If it means "at most $13$", it fails.

Numbers that pass have a name.

> **Definition.** A positive integer $v$ is **$B$-smooth** if every prime dividing $v$ is at most $B$. The threshold $B$ is the *factor-base bound*, and the primes $p \le B$ are the *factor base*. We write
> $$\Psi_B(x) \;=\; \#\{v : 1 \le v \le x,\ v \text{ is } B\text{-smooth}\}$$
> for the number of $B$-smooth values up to $x$, and $\pi(B)$ for the number of factor-base primes.

Smooth numbers are the hidden engine of modern integer factorization. Every serious factoring algorithm of the last forty years works the same way: generate a torrent of candidates, discard the ones that are not $B$-smooth, and assemble the survivors into a giant linear-algebra problem over the two-element field $\mathbb{F}_2$. The entire cost is governed by one number — **what fraction of your candidates survive the smoothness test?**

<details>
<summary><b>Background: why the survivors are useful at all</b> — click to expand</summary>

Once a candidate $v$ is known to be $B$-smooth, you know its complete factorization over the factor base, and hence its **exponent vector** $(v_p(v))_{p \le B}$. Reduce that vector modulo $2$. If you collect more than $\pi(B)$ such vectors they must be linearly dependent over $\mathbb{F}_2$, and a dependency is a sub-family whose product is a perfect square. In the classical sieves this yields a congruence of squares $a^2 \equiv b^2 \pmod N$, and $\gcd(a - b, N)$ is then a nontrivial factor of $N$ with constant probability. Everything hinges on producing smooth values fast enough — which is why predicting the yield matters. See the [Wikipedia article on smooth numbers](https://en.wikipedia.org/wiki/Smooth_number) and on the [quadratic sieve](https://en.wikipedia.org/wiki/Quadratic_sieve) for the classical picture.

</details>

The yield is hard to predict in practice. Asymptotically the answer is elegant: setting the **smoothness parameter**

$$u \;=\; \frac{\log x}{\log B},$$

one has $\Psi_B(x) \approx x\,\rho(u)$ with $\rho$ the [Dickman function](https://en.wikipedia.org/wiki/Dickman_function), which decays super-exponentially in $u$. But in the *tight-$u$ regime* where real sieves live — $u$ between roughly $2$ and $5$ — that asymptotic is a blunt instrument. What one wants is a per-instance dial.

---

## 1 · The empirical clue

A programme of experiments built exactly such a dial. The baseline model used the obvious features: candidate magnitude, the bound $B$, the derived $u$, and the **squarefree hit indicators** — for each factor-base prime $p$, does $p$ divide the candidate?

That baseline works well, but it leaves a residual. Two natural extra features failed to touch it:

| candidate feature | out-of-sample $R^2$ gain | verdict |
|---|---|---|
| mid-prime fraction of the factor base | $+0.019$ | confidence interval spans zero |
| quadratic-residue density | $+0.004$ | confidence interval spans zero |
| **prime-power hits: $p^2 \mid v$ for $p \le 13$** | $\mathbf{+0.0892}$ | **CI $[0.041,\,0.125]$ — decisive** |

*Repeated* small primes. Not which small primes divide your number, but which ones divide it **twice**.

The rest of this page explains why — and the explanation is not statistical. It is a chain of exact identities.

---

## 2 · The one idea: a divisibility test is a change of budget

Here is the theorem everything else follows from.

> **Exact Rescaling Theorem.** Let $m > 0$ be $B$-smooth. Then
> $$\#\{v \le x : v \text{ is } B\text{-smooth},\ m \mid v\} \;=\; \Psi_B\big(\lfloor x/m\rfloor\big).$$

No error term. No asymptotic regime. An equality of integers.

<details>
<summary><b>Click to reveal the proof</b> — it is a two-line bijection</summary>

The map is $v \mapsto v/m$, with inverse $w \mapsto m\,w$.

*Forward.* If $1 \le v \le x$, $v$ is smooth, and $m \mid v$, then $v/m$ is an integer, at least $1$ (because $m \le v$) and at most $\lfloor x/m\rfloor$. It is smooth because **smoothness passes to divisors**: any prime of $v/m$ is a prime of $v$.

*Backward.* If $1 \le w \le \lfloor x/m\rfloor$ and $w$ is smooth, then $mw \le x$ by the defining property of floor division, and $mw$ is smooth because **smoothness is multiplicative** — the prime support of a product is the union of the supports — using here that $m$ itself is smooth.

The two maps are mutually inverse: $m \cdot (v/m) = v$ when $m \mid v$, and $(mw)/m = w$ since $m > 0$. $\blacksquare$

</details>

<details>
<summary><b>Why the modulus <i>must</i> be smooth</b> — a total failure, not an error term</summary>

Take $B = 5$, $m = 7$, $x = 100$. No $5$-smooth number is divisible by $7$, so the left-hand side is $0$. But $\Psi_5(14) = |\{1,2,3,4,5,6,8,9,10,12\}| = 10$.

The backward map is what breaks: $7w$ leaves the smooth pool entirely. Smoothness of the modulus is a *hypothesis*, not a convenience — a detail worth savouring, because it is exactly the kind of side condition that a purely heuristic treatment would quietly drop.

</details>

**Read the theorem out loud.** Conditioning on $p^2 \mid v$ does not carve out some exotic subset of the pool. It reruns the *identical* smoothness question at a shrunken bound. A divisibility feature is a change of the smoothness budget.

Two immediate consequences. For distinct primes $p,q \le B$, joint hits compose multiplicatively,

$$\#\{v \le x : \text{smooth},\ p^2 \mid v,\ q^2 \mid v\} = \Psi_B\big(\lfloor x/(p^2q^2)\rfloor\big),$$

and the *exact* multiplicity strata telescope,

$$\#\{v \le x : \text{smooth},\ v_p(v) = j\} \;=\; \Psi_B\big(\lfloor x/p^j\rfloor\big) - \Psi_B\big(\lfloor x/p^{j+1}\rfloor\big).$$

---

## 3 · Drive it yourself

Before any more theory, get your hands on the object. The widget below computes the smooth pool live. Set the bound, set the prime, set the layer, and watch the identity hold on the nose.

**Things to try.**
1. Leave $B = 13$ and slide $x$. The hit count and the rescaled count move together, always equal.
2. Push the layer $j$ up to $4$ or $5$. Still exact — the theorem holds at every layer, not just $j = 2$.
3. Drop $B$ to $5$ and watch the toll table in section 2 of the widget: the same $4$-hit suddenly costs far more budget.
4. Scroll to the pool display at the bottom and look for the dashed outlines. Those are the pairs the baseline features can never tell apart.

{{interactive_demo:0}}

---

## 4 · The toll, and why it lives at small $B$

Translate the rescaling into the language of $u$. If $p^2 \mid v$ then, exactly,

$$u(v) \;=\; u(v/p^2) \;+\; \underbrace{\frac{2\log p}{\log B}}_{\text{the toll}}.$$

<details>
<summary><b>Proof, and the boundary condition that bites</b></summary>

Write $v = p^2 w$. Then $v/p^2 = w$ exactly and $\log v = 2\log p + \log w$; divide by $\log B$.

The inequality form at the rescaled bound — $u(\lfloor x/p^2\rfloor) \le u(x) - 2\log p/\log B$ — needs the hypothesis $p^2 \le x$. If $x < p^2$ then $\lfloor x/p^2\rfloor = 0$ and the logarithm degenerates. Small print, but real: the guarded statement is the true one.

</details>

Now the observation that carries the whole empirical story:

> **Antitonicity of the toll.** For $1 < B \le B'$, $\ \dfrac{2\log p}{\log B'} \le \dfrac{2\log p}{\log B}.$

The *same* arithmetic event costs *more* budget at a *smaller* factor base. At $B = 10^6$, hitting $4$ costs $2\log 2/\log 10^6 \approx 0.10$ units of $u$ — a rounding error. At $B = 13$ it costs $\approx 0.54$ — over half a unit. And since $\rho$ decays super-exponentially, half a unit of $u$ is enormous.

That is why the effect is a *tight-$u$* phenomenon, and why the experiment found it with $p \le 13$.

{{visualization:0}}

---

## 5 · The theorem that makes it inevitable

Now the deepest result. The prime-power features do not merely add *some* budget information. They carry *all* of it, linearly.

Let $\Omega(v)$ count the prime factors of $v$ **with multiplicity** — the discrete smoothness budget.

> **Budget Decomposition Theorem.**
> $$\sum_{\substack{v \le x \\ \text{smooth}}} \Omega(v) \;=\; \sum_{p \le B}\;\sum_{j=1}^{\lfloor\log_2 x\rfloor} \#\{v \le x : \text{smooth},\ p^j \mid v\} \;=\; \sum_{p \le B}\;\sum_{j=1}^{\lfloor\log_2 x\rfloor} \Psi_B\big(\lfloor x/p^j\rfloor\big).$$

<details>
<summary><b>Click to reveal the proof</b> — double counting, done cleanly</summary>

Two lemmas.

*The budget is a factor-base sum.* For a $B$-smooth $v$, $\ \Omega(v) = \sum_{p \le B} v_p(v)$, because primes outside the factor base contribute nothing.

*A valuation counts hits.* For $v \ne 0$ and prime $p$, $\ p^j \mid v \iff j \le v_p(v)$. So the number of layers $j \in [1,J]$ that fire is exactly $v_p(v)$, provided $J \ge v_p(v)$.

And $J = \lfloor\log_2 x\rfloor$ always suffices, because $2^{v_p(v)} \le p^{v_p(v)} \le v \le x$.

Combine: $\Omega(v) = \sum_{p\le B}\sum_{j=1}^{J}\mathbf{1}[p^j \mid v]$. Sum over the pool, exchange the two finite sums, and each $(p,j)$ term becomes a hit count. Apply the rescaling theorem to each modulus $p^j$ for the second equality. $\blacksquare$

</details>

**This is the whole story in one line.** The prime-power hit counts are a **linear coordinate system for the smoothness budget** — not a proxy that happens to correlate, but a basis in which the budget is literally a sum of coordinates. And the squarefree features are precisely the single layer $j = 1$ of a stack $\lfloor\log_2 x\rfloor$ deep.

The algorithm below computes the budget by two logically independent routes and attributes it layer by layer. Run it and read off how much of the budget layer one carries.

{{algorithm:2}}

---

## 6 · What the squarefree layer cannot see

The claim "layer one cannot see the budget" is not a soft statement about correlation. It is an impossibility theorem.

> **Blindness Theorem.** Let $p$ be a prime dividing $v \ne 0$ and let $k \ge 0$. Then $v$ and $v\cdot p^k$ have *identical* squarefree hit vectors, while
> $$\Omega(v \cdot p^k) = \Omega(v) + k.$$

Multiplying by a prime you already have changes nothing the squarefree features can detect, yet drives the budget up without bound. So the fibres of the squarefree feature map contain values of arbitrarily different budget: **no function of the squarefree hits recovers the budget.**

There is also a pigeonhole. There are only $2^{\pi(B)}$ possible squarefree vectors, so:

> **Collision Theorem.** If $2^{\pi(B)} < \Psi_B(x)$, then two *distinct* smooth values in $[1,x]$ share a squarefree hit vector.

At $B = 2$ this is unconditional and explicit: for $x \ge 4$ the values $2$ and $4$ already collide.

Contrast this with the full profile.

> **Complete Invariant Theorem.** Two positive $B$-smooth integers that trigger exactly the same prime-power hit features are equal.

<details>
<summary><b>Click to reveal the proof of completeness</b></summary>

By unique factorization it suffices to match every valuation. For a prime $p \le B$: since $p^{v_p(v)} \mid v$, the hypothesis gives $p^{v_p(v)} \mid w$, so $v_p(v) \le v_p(w)$; symmetrically $v_p(w) \le v_p(v)$. For a prime $p > B$: smoothness forces both valuations to vanish. $\blacksquare$

The prime-power profile is a perfect fingerprint of a smooth number. Its $j = 1$ truncation provably is not. That gap *is* the signal.

</details>

{{visualization:1}}

---

## 7 · The cost side: hits spend budget without buying relations

Why does the prime-power feature *predict* the sieve's yield rather than merely mimic it? Because of a complementary blindness — this time on the other side.

> **The $\mathbb{F}_2$ Blind Spot.** For any finite index set $S$, any $p > 0$, and any weights $w_i$,
> $$\prod_{i\in S}(p^2 w_i) \text{ is a perfect square} \iff \prod_{i\in S} w_i \text{ is a perfect square}.$$

<details>
<summary><b>Click to reveal the proof and its consequence</b></summary>

Factor out: $\prod_{i\in S}(p^2 w_i) = (p^{|S|})^2 \prod_{i\in S} w_i$, and multiplying by a nonzero square never changes squareness. (If $a^2 b = d^2$ then $a^2 \mid d^2$, so $a \mid d$; write $d = ae$ and cancel.) $\blacksquare$

**Consequence.** Given more than $\pi(B)$ smooth $p^2$-hits, some nonempty sub-family has a perfect-square product — and by the theorem that same relation is already present, unchanged, among the rescaled *cofactors*. The doubled prime contributes an even exponent to every member and so vanishes modulo $2$.

</details>

**A prime-power hit spends smoothness budget without buying a new relation direction.** Pure cost, no benefit — which is precisely what makes it a clean, exogenous predictor of yield: it moves the budget without perturbing the relation combinatorics.

---

## 8 · Is the hit sub-pool big enough to matter?

Yes, and by exact combinatorics rather than estimate. Let $P_B = \prod_{p\le B} p$.

> **Abundance bracket.** If $P_B^{\,m} \le x$ then
> $$(m+1)^{\pi(B)} \;\le\; \Psi_B(x) \;\le\; \big(\lfloor\log_2 x\rfloor + 1\big)^{\pi(B)}.$$

<details>
<summary><b>Click to reveal both bounds</b></summary>

*Lower.* Every exponent vector $f : \{p \le B\} \to \{0,\dots,m\}$ gives a distinct smooth value $\prod p^{f(p)} \le P_B^m \le x$. Unique factorization makes the assignment injective, and there are $(m+1)^{\pi(B)}$ vectors.

*Upper.* Map a smooth $v \le x$ to its valuation vector. Each entry is at most $\lfloor \log_2 x\rfloor$ since $2^{v_p(v)} \le v \le x$, and the map is injective on the smooth pool.

</details>

So the pool is **polynomial in $\log x$ of degree exactly $\pi(B)$**. Applying the lower bound at the rescaled bound $x/p^2$ shows the $p^2$-hit sub-pool is itself exponentially large in $\pi(B)$. And because the exponent is $\pi(B)$, shifting $\log x$ by $2\log p$ is a *first-order* effect on the count — which is the counting-side shadow of the budget toll.

At $B = 2$ everything is closed-form: $\Psi_2(x) = \lfloor\log_2 x\rfloor + 1$, and for $x \ge 4$,
$$\#\{v \le x : 4 \mid v,\ v \text{ a power of }2\} + 2 = \Psi_2(x).$$
Hitting $4$ consumes exactly two units of the base-two budget. Equality, no slack.

---

## 9 · The algorithms

The identities are not only explanatory; they are computational. Two more routines, each replacing a brute-force enumeration with a handful of rescaled counts.

{{algorithm:0}}

{{algorithm:1}}

---

## 10 · See it all verified

The full verification suite checks every statement on this page by brute force, on concrete ranges, and reports exact agreement.

{{demo:0}}

And a numerical study of what happens as $x \to \infty$: since the hit fraction *is* the ratio $\Psi_B(x/p^2)/\Psi_B(x)$, the whole predictive content of a prime-power feature is the local logarithmic derivative of the smooth-counting function.

{{demo:1}}

---

## 11 · The picture that emerges

Step back and a single statement organises everything.

> The prime-power hit features are the **graded coordinates of the multiplicative monoid of smooth numbers**, and the grading splits the information exactly in two:
>
> - **Layer $j = 1$** — squarefree hits — is the abelianization modulo squares. It sees the $\mathbb{F}_2$ relation data a sieve consumes, and *nothing else*.
> - **Layers $j \ge 2$** see the smoothness budget, and *nothing else*.

These two kinds of information are **disjoint by theorem**, not merely weakly correlated in a sample. That is why adding "$p^2$ divides $v$" to a squarefree-hit baseline produces genuine out-of-sample gain: the new coordinates span a direction the old ones provably cannot reach, so the contribution cannot be absorbed by re-weighting, and it must generalise. And it is why the gain concentrates at small $B$: the toll the new features measure is antitone in $B$.

There is a moral here about model-building. Two plausible features failed; one succeeded. In hindsight the difference is structural rather than statistical — the successful feature has an exact identity behind it, an identity saying it reconstructs the very quantity the yield depends on. When a feature works, ask not only *how much* it explains but *what theorem it is a shadow of*.

<details>
<summary><b>Where this goes next</b> — the open conjecture</summary>

Because the rescaling identity converts every question about hit features into a question about $\Psi_B$ at two nearby arguments, the natural conjecture is sharp: for fixed $B$ and $x \to \infty$,
$$\frac{\Psi_B(x/p^2)}{\Psi_B(x)} \;=\; 1 - \pi(B)\cdot\frac{2\log p}{\log x} + O\big((\log x)^{-2}\big),$$
and in the tight-$u$ regime, with $B$ growing alongside $x$,
$$\frac{\Psi_B(x/p^2)}{\Psi_B(x)} \;=\; \frac{\rho\!\left(u - \frac{2\log p}{\log B}\right)}{\rho(u)} + o(1).$$
The exact identity is settled. What remains is an asymptotic for $\Psi_B$ itself — and for fixed $B$ that is elementary lattice-point counting, which the abundance bracket already half-provides.

Further questions: what is the *minimal* set of layers that remains a complete invariant on a pool bounded by $x$ (a principled feature budget rather than a heuristic cutoff)? Does the joint-hit composition extend to a full inclusion–exclusion over squarefull moduli, giving an analytically predictable correlation structure for the design matrix? And what does a relation stage modulo $\ell$-th powers see — there the layers $j \equiv 0 \pmod \ell$ go blind, suggesting a whole family of gradings interpolating between relation data and budget data?

</details>

---

*A hunt that ends not with a fitted coefficient, but with an identity.*
