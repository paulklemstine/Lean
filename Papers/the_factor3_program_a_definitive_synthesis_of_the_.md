# The Free Lunch That Isn't
### A guided tour of the free-witness classification, the trace lemma, and the noise floor

---

## Prologue: a number that keeps a secret

Multiply two primes together and hand me the answer. If the primes are small I will find them in seconds; if they are three hundred digits long, nobody will find them. That asymmetry holds up modern cryptography — and yet nobody can prove the wall is really there.

What we *can* do is map the wall. This page is about one large, natural family of attempts to climb it: the **counting attacks**. By the end you will have proved to yourself, interactively, two facts that fit together like a lock and a key:

1. Every counting attack in the family either hands you the *entire* factorization or hands you *nothing*. There is no middle ground.
2. The ones that hand you everything cost exactly as much to run as the brute-force search they were supposed to replace.

<details>
<summary><strong>Prerequisites — click if you'd like a five-minute refresher</strong></summary>

You need almost nothing beyond high-school algebra:

- **Divisors.** $d \mid N$ means $d$ divides $N$ exactly. The number $N = pq$ with $p \ne q$ prime has exactly four divisors: $1$, $p$, $q$, and $pq$.
- **Coprime.** $\gcd(m,n) = 1$ — no common prime factor.
- **The Chinese Remainder Theorem.** For coprime $m,n$ there is a ring isomorphism $\mathbb{Z}/mn \cong \mathbb{Z}/m \times \mathbb{Z}/n$. Everything modulo $mn$ splits into a piece modulo $m$ and a piece modulo $n$. ([Background reading](https://en.wikipedia.org/wiki/Chinese_remainder_theorem).)
- **The quadratic formula.** If you know $a+b$ and $ab$, you know $a$ and $b$: they are the roots of $x^2 - (a+b)x + ab$.
- **The birthday bound.** Trial division finds the smaller factor of $N = pq$ after about $\sqrt N$ steps. ([Background on integer factorization](https://en.wikipedia.org/wiki/Integer_factorization).)

That last pair — the quadratic formula and the $\sqrt{N}$ scale — is the whole plot.
</details>

---

## Act I — Counting your way to a factorization

Here is the shape of nearly every clever idea in the field. You cannot see $p$ and $q$ directly, so you *count* something instead — lattice points on a circle, roots of a polynomial, representations by a quadratic form — and hope the count carries a fingerprint of the factors.

The cleanest version is a weighted divisor sum. Give every divisor $d$ of $N$ a weight $w(d)$ and add:
$$A_w(N) \;=\; \sum_{d \mid N} w(d).$$

The magic ingredient is that the weight should respect the CRT splitting.

> **Definition (CRT weight).** A function $w : \mathbb{N} \to \mathbb{N}$ is a *CRT weight* if $w(1) = 1$ and $w(mn) = w(m)\,w(n)$ whenever $\gcd(m,n) = 1$.

Power weights $w(d) = d^k$ are the standard examples, and their aggregates are the classical divisor-power sums $\sigma_k(N) = \sum_{d\mid N} d^k$.

Now the structural fact that starts everything. Since $N = pq$ has exactly the four divisors $1, p, q, pq$, and since $w(pq) = w(p)w(q)$,
$$A_w(pq) \;=\; 1 + w(p) + w(q) + w(p)w(q) \;=\; \bigl(1 + w(p)\bigr)\bigl(1 + w(q)\bigr).$$

**One number on the left; a product of two local contributions on the right.** Both primes leave their marks, separately. Play with it — change the primes, change the weight, and watch the identity hold:

{{interactive_demo:0}}

> Set the weight to $w(d)=d$ and press **Run**. Then switch to $w(d)=d^2$ and $w(d)=d^3$. Notice that the left column and the right column always agree — that is the CRT splitting doing its work.

---

## Act II — The trace and the norm

Watch a two-hundred-year-old trick do the heavy lifting.

Write $x = w(p)$ and $y = w(q)$. From the identity above, the aggregate tells you
$$x + y \;=\; A_w(N) - 1 - w(N),$$
and you *already* know
$$xy \;=\; w(p)w(q) \;=\; w(pq) \;=\; w(N),$$
because $w$ is CRT-multiplicative and $N$ was given to you. A sum and a product.

In field-theoretic language the product is the **norm** — public, computable from $N$ alone, identical for every factorization — and the sum is the **trace** — the secret. The aggregate hands over the trace, and a pair of numbers is determined by its sum and its product.

> **The Trace Lemma.** Let $w$ be a strictly increasing CRT weight. Fix $N$ and suppose $N = ab = a'b'$ are two coprime factorizations with $a \le b$, $a' \le b'$. If the aggregates agree, then $a = a'$ and $b = b'$.

<details>
<summary><strong>Click to reveal the full proof (three lines of honest algebra)</strong></summary>

*Norms agree.* Multiplicativity on the coprime pairs gives $w(a)w(b) = w(N) = w(a')w(b')$.

*Traces agree.* Expanding $(1+w(a))(1+w(b)) = (1+w(a'))(1+w(b'))$ and cancelling the equal products leaves $w(a) + w(b) = w(a') + w(b')$.

*The pair is pinned.* A pair of naturals is determined by its sum and product: if $x \le y$, $x' \le y'$, $x+y = x'+y'$ and $xy = x'y'$, then setting $t = x'-x > 0$ under the assumption $x<x'$ gives $y' = y - t$ and
$$xy = (x+t)(y-t) = xy + t(y - x - t),$$
so $y - x = t$, i.e. $y = x'$ and $y' = x$ — contradicting $x' \le y'$. Hence $x = x'$.

Applying this to $(w(a),w(b))$ and $(w(a'),w(b'))$ gives $w(a) = w(a')$; strict monotonicity makes $w$ injective, so $a = a'$, and $b = b'$ follows by division. $\blacksquare$
</details>

**There is no such thing as a partially informative CRT aggregate.** It does not leak a hint you must amplify. It leaks the factorization, whole. The witness *is* the secret, wearing a coordinate change.

Scroll back to the laboratory above and open **Section 2**. The numbered steps are the recovery, performed live: the trace is extracted, the discriminant is computed, and the quadratic formula returns $p$.

---

## Act III — A prediction that came true

Theories earn their keep by predicting things nobody looked for. Take $w(d) = d^2$, whose aggregate is $\sigma_2$. On a semiprime,
$$\sigma_2(pq) = (1+p^2)(1+q^2) = 1 + p^2 + q^2 + N^2 .$$
Subtracting the known quantities leaves $p^2 + q^2$ — which *looks* weaker than $p+q$. It is not. Add $2N = 2pq$ and you get $(p+q)^2$ exactly; take an integer square root, then apply
$$p \;=\; \frac{(p+q) - \sqrt{(p+q)^2 - 4N}}{2},$$
and the smaller prime falls out in a handful of exact integer operations. No approximation, no search.

The theory said $p^2+q^2$ had to be a complete witness before anyone checked. It is. Here is the general inversion algorithm, valid for every exponent $k \ge 1$:

{{algorithm:0}}

Why does it work for *every* $k$, including exponents with no closed form? Because of a monotonicity principle that is worth stating on its own.

> **Spread monotonicity.** If $ab = a'b'$ with $a < a' \le b' < b$, then $a'^k + b'^k < a^k + b^k$ for every $k \ge 1$.

Rectangles of equal area: the long thin one has the longer perimeter, and the same is true for every power. Since the power sum is strictly monotone along the hyperbola $ab = N$, distinct factorizations can never share a value — which is why a binary search converges.

<details>
<summary><strong>Click to reveal the proof of spread monotonicity</strong></summary>

First the linear case $k=1$. From $ab = a'b'$ and $a < a'$ we get $b > b'$; writing $a' = a+s$, $b = b'+t$ turns $ab = a'b'$ into $at = sb'$. Since $a < a' \le b'$ we get $at = sb' \ge sa' > sa$, so $t > s$, so $a + b > a' + b'$.

For general $k$, use the telescoping identity $x^k - y^k = \bigl(\sum_{i<k} x^i y^{k-1-i}\bigr)(x-y)$ to write
$$a'^k - a^k = C_1 (a' - a), \qquad b^k - b'^k = C_2 (b - b'),$$
with $C_1 = \sum_{i<k} a'^i a^{k-1-i}$ and $C_2 = \sum_{i<k} b^i b'^{k-1-i}$. Since $a' \le b$ and $a \le b'$, every term of $C_1$ is at most the corresponding term of $C_2$, so $0 < C_1 \le C_2$. The linear case gives $a'-a < b-b'$. Multiplying the two inequalities: $a'^k - a^k < b^k - b'^k$, i.e. $a'^k + b'^k < a^k + b^k$. $\blacksquare$
</details>

---

## Act IV — Everything or nothing

What if the weight is *not* monotone? Suppose it collides: two different primes $p \ne p'$ with $w(p) = w(p')$.

Then the attack dies instantly, and it dies unconditionally. Pick a prime $q$ larger than both. The semiprimes $pq$ and $p'q$ have aggregates
$$(1+w(p))(1+w(q)) \quad\text{and}\quad (1+w(p'))(1+w(q)),$$
which are *equal*, while their smaller factors differ. So no function at all — computable or not, fast or slow — can map that shared value to both answers. The information is simply absent.

> **The Classification.** Every CRT weight is of exactly one of two kinds. Either it separates primes — and then, if it is also monotone, its aggregate pins the factorization completely, invertible in $O(1)$ arithmetic operations. Or it collides on two primes — and then no function of its aggregate can ever return a factor. There is no third behaviour.

Run the classifier on weights of your choosing:

{{algorithm:1}}

> Try it in the laboratory too: select **w collapsing two primes** in the weight menu. The verdict flips to **BLIND BRANCH**, and the widget prints an explicit certificate — two semiprimes with different smaller factors and identical aggregates.

<details>
<summary><strong>Where does the class end? The characters-only boundary</strong></summary>

A classification is only as good as its boundary. Power functions are CRT weights trivially. What about the other great family in analytic number theory, the exponential phases $x \mapsto z^x$ that power [Fourier analysis](https://en.wikipedia.org/wiki/Fourier_analysis) and [Gauss sums](https://en.wikipedia.org/wiki/Gauss_sum)?

They are not even in the class, and one evaluation proves it. Suppose $z^{mn} = z^m z^n$ for all coprime $m,n$. Take $m=2$, $n=3$: then $z^6 = z^2 z^3 = z^5$, and dividing by $z^5 \ne 0$ gives $z = 1$.

Exponential phases are *additive* in the exponent; the CRT splitting is *multiplicative* in the argument. The two are incompatible. Only genuine multiplicative characters decompose through the Chinese Remainder Theorem — so the classification covers exactly the natural class of counting attacks, no more and no less.
</details>

---

## Act V — The geometry: a tropical line and its corner

There is a change of coordinates that makes all of this visible at a glance.

[Tropical arithmetic](https://en.wikipedia.org/wiki/Tropical_geometry) replaces addition by taking a minimum, $x \oplus y = \min(x,y)$, and multiplication by ordinary addition, $x \odot y = x + y$. In these min-plus coordinates the multiplicative constraint $ab = N$ becomes a **tropical line**: a bent, piecewise-linear curve whose two rays meet at a corner. The corner sits at $a = b = \sqrt N$.

Every factorization of $N$ is a point on this line, and the classical trace $a+b$ is *minimized at the corner*.

{{visualization:0}}

> **Theorem.** Among factorizations $N = ab = a'b'$ with $a \le b$, $a' \le b'$ and $a \le a'$, one has $a' + b' \le a + b$: the more balanced pair has the smaller trace. In particular, for a semiprime the trace $p+q$ is strictly below the trivial factorization's trace $1 + N$, since $1 + pq - p - q = (p-1)(q-1) > 0$.

Use **Section 3** of the laboratory to walk along the line yourself: drag the slider and watch the trace profile dip at the corner and shoot up at the ends.

So here is the whole story in one image. The factoring secret is *a position on a tropical line*. The trace lemma says the position is all there is, and every counting witness in the class is just a different ruler laid along the same line.

---

## Act VI — The catch, and it is fatal

We have a witness worth everything. Why is factoring still hard?

Because the witness is not free. To evaluate $\sum_{d\mid N} w(d)$ you must know the divisors of $N$ — which is the problem you were trying to solve. Any honest evaluation is a *sweep*: probe $d = 2, 3, 4, \dots$ and test divisibility. And here the geometry turns cruel.

Look at the window from $2$ up to $\sqrt N$. For a semiprime $N = pq$ with $p<q$, **exactly one** probe in that entire window is a divisor: $p$ itself. ($q$ and $N$ lie above the corner; $1$ is below the window.) The window holds $\sqrt N - 1$ candidates. The density of useful probes is $1/(\sqrt N - 1)$.

Press **Sweep** in **Section 4** of the laboratory and watch the noise scroll by until the single green spike appears.

For balanced semiprimes — where $p < q \le 2p$, the cryptographic case — this sharpens into a theorem with an explicit constant.

> **The Noise-Floor Principle.** Let $N = pq$ be balanced. If a probe window $[2,m]$ contains a nontrivial divisor of $N$ at all, then $N \le 2m^2$, so the sweep has already reached the birthday scale $\sqrt{N/2}$. And no window ever contains more than two factor-bearing probes, since $N$ has only two nontrivial divisors. Dividing the bounded numerator by the forced denominator,
> $$\text{density of factor-bearing probes} \;\le\; \frac{2\sqrt2}{\sqrt N}.$$
> Moreover the sweep length is squeezed on both sides: $\sqrt{N/2} \le p \le \sqrt N$.

{{visualization:1}}

**This is the punchline.** The *aggregation barrier* — the obstruction that stops counting attacks — and the *birthday bound* — the obstruction that stops brute force — are not two obstacles of similar size. They are the same obstacle. The counting attack was never a shortcut; it was trial division in a wig.

<details>
<summary><strong>Can't we just precompute a clever list of probes?</strong></summary>

No. For any finite probe set $S$, let $M$ be its largest element, choose a prime $p > M$ and a prime $q > p$. The only nontrivial divisors of $N = pq$ are $p$ and $q$, both bigger than everything in $S$. Every probe misses. A probe set that works for all $N$ must grow with $N$ — and by the bound above it must grow all the way to the birthday scale.
</details>

---

## Epilogue: run everything yourself

Here is the complete numerical companion. It verifies, from scratch, every claim on this page: the CRT splitting, the trace/norm decomposition, uniqueness of the aggregate across all coprime factorizations, spread monotonicity for $k = 1,2,3$, closed-form recovery up to primes near $2^{31}$, an explicit prime-collision certificate, the characters-only boundary, the exact one-hit-per-window count, the $2\sqrt2/\sqrt N$ density bound, and the tropical corner.

{{demo:0}}

### What this does and does not settle

Be scrupulous: none of this proves that factoring is hard. That question is open, and this framework does not close it. What it does establish is a *complete and predictive* account of one large, natural family of approaches. Within the class of CRT-multiplicative counting aggregates the situation is now fully mapped — the boundary of the class is known, the behaviour inside it is a strict dichotomy, the positive branch comes with an explicit constant-time recovery formula, and it is sealed by a cost bound that coincides exactly with brute force.

A theory that says *there is nothing new here, and here is the proof* is worth a great deal. It tells the next researcher where not to dig.

### Where the frontier is

The dream is to widen the classification: to show that *every* efficiently computable counting function respecting the CRT splitting is either factorization-insensitive or reduces to a factor-secret coordinate with efficient recovery. That would upgrade the aggregation barrier from a robust regularity to a statement equivalent, in a precise sense, to the hardness of factoring itself. The other half is the noise floor, currently a theorem for balanced semiprimes and divisor probes and an extremely well-attested principle everywhere else — observed independently in circle-counting leak densities, in error terms for primes in arithmetic progressions, in divisor-sum error terms, and in the statistics of Pythagorean-triple trees, all landing on the same $c/\sqrt N$ scale.

Until then, the state of the art is this: we know why the clever ideas fail, we know they all fail for one reason, and we can prove that the reason is the same wall the dumb idea hits.
