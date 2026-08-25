# Skip Connections, Sharply

### A guided tour of the certificate calculus of residual blocks

---

## 0. The one-line idea

Almost every modern deep architecture is built from a piece of arithmetic that looks like a typo:

$$F(x) = x + r(x).$$

Rather than computing its output from scratch, a layer computes a *correction* to what it already has. This is the **residual block**, and the whole of this page is about one question:

> If you know how strongly the correction $r$ can stretch distances, how strongly can the whole architecture stretch distances?

The answer turns out to be a small, complete algebra — with one genuinely surprising twist at the end.

<details>
<summary><strong>Refresher: what is a Lipschitz constant?</strong></summary>

A map $F$ between metric spaces is **$L$-Lipschitz** if it never magnifies distances by more than $L$:

$$d\big(F(x), F(y)\big) \le L\, d(x,y) \qquad \text{for all } x,y.$$

The *least* such $L$ is the map's true amplification factor. Lipschitz constants control robustness to perturbations, well-posedness of inverse problems, the stability of iterative schemes, and much else. See the [Lipschitz continuity](https://en.wikipedia.org/wiki/Lipschitz_continuity) overview for background.

A key point for what follows: a bound like "$F$ is $L$-Lipschitz" is a *certificate*, and certificates can be valid without being tight. Half of this page is about proving tightness.
</details>

Throughout, if the residual $r$ is $K$-Lipschitz we call $K$ the block's **certificate** and $1+K$ its **gain**. The triangle inequality gives the basic estimate immediately:

$$d\big(F(x),F(y)\big) = d\big(x+r(x),\, y+r(y)\big) \le d(x,y) + d\big(r(x),r(y)\big) \le (1+K)\,d(x,y).$$

So a block with certificate $K$ is $(1+K)$-Lipschitz. Everything else is about what happens when you wire blocks together.

---

## 1. Two ways to wire, two operations

There are exactly two structural moves in an architecture.

**In depth (serially)**, you feed one block into the next. If the first has certificate $K_1$ and the second $K_2$, the composite is again a residual block, with certificate

$$K_1 \ast K_2 = K_1 + K_2 + K_1K_2.$$

That formula looks arbitrary until you add one to both sides:

$$1 + (K_1 \ast K_2) = (1+K_1)(1+K_2).$$

**Serial composition just multiplies gains.**

**In width (in parallel)**, you run two blocks on two separate streams, $(x,y)\mapsto (F_1(x),F_2(y))$. Measuring the pair with the natural product distance $d\big((x,y),(x',y')\big) = \max\big(d(x,x'),d(y,y')\big)$, the answer is:

$$K_1 \parallel K_2 = \max(K_1,K_2), \qquad\text{gain } = \max(1+K_1,\,1+K_2).$$

<details>
<summary><strong>Proof of the parallel bound (two lines)</strong></summary>

Let $M = \max(K_1,K_2)$. The parallel residual is $(x,y)\mapsto (r_1(x), r_2(y))$, and

$$\max\big(d(r_1x,r_1x'),\ d(r_2y,r_2y')\big) \le \max\big(K_1 d(x,x'),\ K_2 d(y,y')\big) \le M \max\big(d(x,x'), d(y,y')\big).$$

So the parallel residual is $M$-Lipschitz, i.e. the parallel pair is a residual block with certificate $M$, hence has gain $1+M = \max(1+K_1,1+K_2)$. $\blacksquare$
</details>

<details>
<summary><strong>The certificate semiring (for the algebraically minded)</strong></summary>

The two operations make $[0,\infty)$ into an idempotent semiring-like structure: $\ast$ is a commutative monoid law with unit $0$, $\max$ is an idempotent commutative monoid law with unit $0$, and $\ast$ distributes over $\max$:

$$(a \parallel b)\ast c = (a\ast c)\parallel(b\ast c).$$

The map $\gamma(a) = 1+a$ is an order isomorphism of $[0,\infty)$ onto $[1,\infty)$ carrying $(\ast,\max)$ to $(\times,\max)$. In other words, the certificate calculus is exactly the positive part of the **max-times [tropical semiring](https://en.wikipedia.org/wiki/Tropical_geometry)**. Every computation on this page is a tropical computation; the analytic content is that the tropical answers are not merely valid but optimal.
</details>

{{demo:1}}

---

## 2. Is the max rule *tight*? Play with it

Upper bounds proved by chaining triangle inequalities are usually generous. This one is not — and the fastest way to believe it is to watch it.

Drag the certificates and see which direction gets stretched the most. Then switch the product metric and watch the answer refuse to move.

{{interactive_demo:0}}

What you should discover:

- The extremal direction is always a **coordinate axis** — perturb one stream, leave the other alone.
- The measured constant is always exactly $\max(1+K_1,1+K_2)$, never the sum.
- Changing between the max, sum and Euclidean product metrics reshapes the ball completely but changes nothing about the constant.

<details>
<summary><strong>Why the coordinate axes are extremal, and why the metric drops out</strong></summary>

Take the **dilation blocks**: on the real line, $r(x) = Kx$, which is exactly $K$-Lipschitz. The block computes $x \mapsto (1+K)x$, and the parallel pair is

$$(x,y)\longmapsto \big((1+K_1)x,\ (1+K_2)y\big).$$

Test on the input pair $\big((1,0),(0,0)\big)$: the input distance is $1$ and the output distance is $1+K_1$, so any valid constant is $\ge 1+K_1$. Test on $\big((0,1),(0,0)\big)$ to get $\ge 1+K_2$. Hence the least valid constant is exactly $\max(1+K_1,1+K_2)$.

**Attainment theorem.** For every $K_1,K_2\ge0$ the parallel pair of dilation blocks has least Lipschitz constant exactly $\max(1+K_1,1+K_2)$.

Now note that both test pairs differ in a *single coordinate*, and every $\ell^p$ combination of a vector with one nonzero entry is that entry. So the same two tests give the same lower bound in the $\ell^1$, $\ell^2$ and $\ell^\infty$ products, and the matching upper bounds hold in each as well.

**Metric-independence theorem.** For all $K_1,K_2\ge0$, the number $\max(1+K_1,1+K_2)$ is simultaneously the least Lipschitz constant in the $\ell^\infty$, $\ell^1$ and $\ell^2$ cartesian products.
</details>

Attainment has a sharp corollary that is worth stating on its own.

> **Minimality of the max rule.** Suppose $c(K_1,K_2)$ is *any* rule assigning to a pair of certificates a valid certificate for their parallel composition. Then $c(K_1,K_2) \ge \max(K_1,K_2)$ everywhere.

The max rule is not one legal convention among many — it is the floor. Nothing tighter can ever be valid, and the second demo above verifies this numerically by testing candidate rules against the extremal blocks.

{{visualization:0}}

---

## 3. Width and depth

The same law scales in both structural directions, and both are sharp.

| Structure | Certificate | Gain | Sharp? |
|---|---|---|---|
| One block | $K$ | $1+K$ | yes (dilation) |
| Depth $d$ | — | $(1+K)^d$ | yes (dilation stack) |
| Width $n$ | $\sup_i K_i$ | $\sup_i (1+K_i)$ | yes (parallel dilations) |
| Two stacks | — | $\max\big((1+K_1)^{d_1}, (1+K_2)^{d_2}\big)$ | yes |

The last line relaxes to the familiar estimate

$$\max\big((1+K_1)^{d_1},(1+K_2)^{d_2}\big) \le \exp\big(\max(K_1d_1,\ K_2d_2)\big),$$

which explains why a deep residual tower with small per-layer corrections stays under control: what matters is the product $Kd$, not $d$ alone. And the sharpness results say the exponential is not an artefact of a lazy estimate — it is really there in the architecture.

{{algorithm:0}}

---

## 4. The twist: the same network, two different numbers

Here is where the story stops being routine.

A real architecture has **both** width and depth: $w$ streams, $d$ layers, a certificate $K_{ij}$ per block. There are two obvious ways to add up the bookkeeping, and they are both valid for the *same map*:

$$\text{sharp} = \max_i \prod_j (1+K_{ij}) \qquad\text{(multiply down each stream, then take the max)}$$

$$\text{coarse} = \prod_j \max_i (1+K_{ij}) \qquad\text{(certify each layer, then multiply)}$$

Since a max of products never exceeds a product of maxima, $\text{sharp} \le \text{coarse}$ always. The question is how bad it gets.

**Find out for yourself.** Toggle cells, load presets, change the width and depth, and watch the two numbers separate.

{{interactive_demo:1}}

<details>
<summary><strong>The exact answer: the alternating architecture</strong></summary>

Take two streams and let each block be either trivial ($K=0$) or a doubling ($K=1$). Stream A does the work on even layers, stream B on odd layers. At depth $2n$:

- each stream has doubled exactly $n$ times, so $\text{sharp} = 2^n$ — and this really is the least Lipschitz constant of the map;
- every layer contains a doubling *somewhere*, so $\text{coarse} = 2^{2n} = 4^n$.

**Unbounded laxity defect.** The over-estimation factor is exactly $2^n$ — exponential in the depth — even though every certificate lies in $\{0,1\}$.

The smallest instance is already telling: identity then doubling in one stream, doubling then identity in the other. The composite is $(x,y)\mapsto(2x,2y)$, whose true constant is $2$; layerwise bookkeeping announces $4$.
</details>

<details>
<summary><strong>What is <em>not</em> going wrong: the interchange law</strong></summary>

The two wirings compute the same function, exactly:

$$(B_1\times B_2)\circ(C_1\times C_2) = (B_1\circ C_1)\times(B_2\circ C_2).$$

This is the statement that the cartesian product is a bifunctor, and it holds on the nose. It is only the *certificates* that disagree. In categorical language the certificate assignment is a **lax** monoidal functor rather than a strong one: it respects the structure only up to an inequality,

$$(a\ast c)\parallel(b\ast d) \ \le\ (a\parallel b)\ast(c\parallel d),$$

and that inequality can be arbitrarily strict. Equality does hold in one important case — when all streams share a layer's certificate — which is exactly the distributivity law of the certificate semiring.
</details>

<details>
<summary><strong>The tropical explanation of the worst cases</strong></summary>

Write $g_{ij} = 1 + K_{ij}$. Then

$$\text{sharp} = \bigoplus_i \bigotimes_j g_{ij}, \qquad \text{coarse} = \bigotimes_j \bigoplus_i g_{ij},$$

with $\oplus = \max$ and $\otimes = \times$: the two natural contraction orders of the same matrix in the max-times semiring. In log coordinates this is max-plus arithmetic, and the defect

$$\sum_j \max_i \ell_{ij} \ -\ \max_i \sum_j \ell_{ij}, \qquad \ell_{ij} = \log(1+K_{ij}),$$

is manifestly nonnegative, zero when one row dominates every column, and maximal when the column argmaxima are spread across as many distinct rows as possible. That is the heuristic behind the conjecture that the *cyclic* architectures $K_{ij} = C\cdot[\,j\equiv i \bmod w\,]$ are the extremisers, with defect $(1+C)^{d(1-1/w)}$ — try the "Cyclic" preset above at several widths.
</details>

{{algorithm:1}}

{{visualization:1}}

**The practical moral.** The two schemes cost exactly the same to compute, and the depth-first one is exponentially tighter. Any stability analysis of a multi-stream architecture that certifies layer by layer is quietly leaking a factor that compounds with depth. Accumulate along streams; take the maximum once, at the very end.

---

## 5. Running the film backwards

One last symmetry, and it is the one that matters for reversible architectures and [normalizing flows](https://en.wikipedia.org/wiki/Flow-based_generative_model).

Suppose every correction is genuinely small: $K < 1$. Then $x\mapsto x+r(x)$ is a contraction-perturbation of the identity, and the [Banach fixed point theorem](https://en.wikipedia.org/wiki/Banach_fixed-point_theorem) does the rest.

> **Invertibility.** On a complete space, a residual block with certificate $K<1$ computes a bijection, and its inverse is $(1-K)^{-1}$-Lipschitz.

<details>
<summary><strong>Proof sketch</strong></summary>

*Injectivity:* $\|B(x)-B(y)\| \ge \|x-y\| - \|r(x)-r(y)\| \ge (1-K)\|x-y\|$, so $B$ never collapses distances by more than $(1-K)$.

*Surjectivity:* fixing $y$, the map $\Phi(x) = y - r(x)$ is a $K$-contraction, hence has a unique fixed point $x^\ast$; and $x^\ast = y - r(x^\ast)$ says exactly $B(x^\ast) = y$.

*Inverse bound:* apply the first display at $x = B^{-1}(u)$, $y = B^{-1}(v)$.
</details>

And the inverse certificates obey the *same* max rule, because $t\mapsto (1-t)^{-1}$ is increasing and increasing maps commute with maxima:

$$\big(1-\max(K_1,K_2)\big)^{-1} = \max\big((1-K_1)^{-1},\ (1-K_2)^{-1}\big).$$

> **Dual max rule.** The parallel composition of two blocks with certificates $K_1,K_2<1$ is a bijection whose inverse has sharp Lipschitz constant $\max\big((1-K_1)^{-1},(1-K_2)^{-1}\big)$ — attained by the inward dilations $x\mapsto(1-K)x$, whose inverses are the outward dilations.

So forward and backward stability are governed by the identical rule, with identical sharpness. Laxity, it turns out, is a phenomenon of *depth*, not of parallelism.

{{algorithm:2}}

---

## 6. Run everything

The script below reproduces every number on this page from scratch — the gain bound on linear and nonlinear blocks, the serial and parallel rules, the metric invariance, the width and depth laws, the $2^n$ versus $4^n$ table, and the certified inversion of a nonlinear contractive block.

{{demo:0}}

---

## 7. What to take away

1. **The parallel rule is $\max$** — and it is valid, attained, and *minimal*: no tighter rule exists.
2. **It does not depend on how you glue** — the same sharp constant in the max, sum and Euclidean products, because the extremisers live on coordinate axes.
3. **Serial composition multiplies gains**, so the whole calculus is the max-times tropical semiring on $[1,\infty)$.
4. **The calculus is lax.** The same network admits certificates differing by a factor exponential in its depth, purely as a function of the order in which you do the arithmetic.
5. **Contract along depth first, take maxima last.** It is free, and it buys you an exponential.
