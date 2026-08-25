# The Arithmetic of Skip Connections

## How a single "max" rule governs the stability of parallel networks — and why bookkeeping order matters exponentially

### A small trick with big consequences

Somewhere inside almost every modern deep network is a piece of arithmetic so modest it looks like a typo:

$$F(x) = x + r(x).$$

Instead of asking a layer to compute the output from scratch, you ask it only to compute a *correction* $r(x)$ to what it already has. The layer's job is to nudge, not to rebuild. This is the **residual block**, and its introduction was the moment very deep networks stopped being a fantasy and became routine.

The intuitive reason it works is a story about signal propagation, and it is fundamentally a story about *Lipschitz constants*. A map $F$ between metric spaces is called **$L$-Lipschitz** if it never stretches distances by more than a factor $L$:

$$d(F(x), F(y)) \le L \cdot d(x, y) \quad \text{for all } x, y.$$

The smallest such $L$ is the map's true amplification factor. If a network is a composition of $L$-Lipschitz layers, its stability, its sensitivity to adversarial perturbation, its gradient behaviour, and its generalization bounds all hinge on how these constants multiply along the pipeline.

Here is the residual trick in one line. If the correction $r$ is $K$-Lipschitz, then

$$d(F(x),F(y)) = d(x + r(x),\, y + r(y)) \le d(x,y) + d(r(x),r(y)) \le (1+K)\, d(x,y).$$

So the block is $(1+K)$-Lipschitz. Call $K$ the block's **certificate** and $1+K$ its **gain**. The remarkable thing is not this inequality — it is the triangle inequality wearing a hat — but the *algebra* that certificates obey when you start wiring blocks together. That algebra turns out to be rigid, sharp, and, in one crucial respect, treacherous.

### Two ways to wire

There are exactly two structural moves in a network architecture.

**Serially**, you feed one block into the next. If block $B_1$ has certificate $K_1$ and $B_2$ has certificate $K_2$, then $B_2 \circ B_1$ is again a residual block — its residual is $r_1(x) + r_2(x + r_1(x))$ — and its certificate is

$$K_1 \ast K_2 = K_1 + K_2 + K_1 K_2.$$

That formula looks arbitrary until you add one to it:

$$1 + (K_1 \ast K_2) = (1 + K_1)(1 + K_2).$$

Serial composition simply *multiplies gains*. The strange-looking operation $\ast$ is nothing more than multiplication in disguise, transported along the shift $K \mapsto 1+K$. In fact the map $K \mapsto 1+K$ is an order isomorphism from the certificates $[0,\infty)$ onto the gains $[1,\infty)$, carrying $\ast$ to ordinary multiplication. Certificates form a commutative monoid with unit $0$ — the identity block, which corrects nothing — and it is secretly the multiplicative monoid $([1,\infty), \times)$.

**In parallel**, you run two blocks side by side on two different streams: $(x,y) \mapsto (F_1(x), F_2(y))$. Now what?

The answer depends on how you measure distance on the pair. The natural choice — and the one built into the product of normed spaces — is the **max norm**:

$$d\big((x,y),(x',y')\big) = \max\big(d(x,x'),\, d(y,y')\big).$$

And with that convention the answer is beautifully simple: the parallel pair has gain

$$\max(1 + K_1,\ 1 + K_2).$$

**Theorem (Tensor-product certificate).** *If $B_1$ is a residual block with certificate $K_1$ on a normed space $X$ and $B_2$ is a residual block with certificate $K_2$ on $Y$, then their parallel composition $(x,y)\mapsto (B_1(x), B_2(y))$ on $X \times Y$ with the max product norm is $\max(1+K_1, 1+K_2)$-Lipschitz. Equivalently, parallel composition takes the maximum of certificates: $K_1 \parallel K_2 = \max(K_1, K_2)$.*

The proof is a two-line calculation, but the statement it yields is not two lines' worth of content, for a reason that has nothing to do with proving the inequality and everything to do with proving it *cannot be improved*.

### Sharpness: the bound is not slack

Upper bounds in this field are often generous — you prove them by chaining triangle inequalities and hope they are not absurdly loose. Here they are not loose at all. Consider **dilation blocks**: on the real line, take the residual $r(x) = Kx$. It is exactly $K$-Lipschitz, and the resulting block is $x \mapsto (1+K)x$, an honest scaling. Put two of them in parallel:

$$(x,y) \longmapsto \big((1+K_1)x,\ (1+K_2)y\big).$$

Test it on the pair of points $\big((1,0),(0,0)\big)$: the input distance is $1$ and the output distance is $1+K_1$. Test it on $\big((0,1),(0,0)\big)$: the output distance is $1+K_2$. So any valid Lipschitz constant must be at least both, hence at least their maximum. Combined with the theorem, we get equality on the nose.

**Theorem (Attainment).** *For every pair of nonnegative certificates $K_1, K_2$, the set of valid Lipschitz constants of the parallel pair of dilation blocks has a least element, and that least element is exactly $\max(1+K_1, 1+K_2)$.*

There is a strengthening that deserves to be stated separately, because it upgrades "our rule is correct" into "our rule is the only correct one":

**Theorem (Minimality of the max rule).** *Suppose $c(K_1, K_2)$ is any rule that assigns to a pair of certificates a valid certificate for their parallel composition — that is, every parallel pair of blocks with certificates $K_1, K_2$ is $(1 + c(K_1,K_2))$-Lipschitz. Then $c(K_1,K_2) \ge \max(K_1,K_2)$ for all $K_1, K_2$.*

The max rule is not *a* legal bookkeeping convention among many. It is the floor. Nothing tighter can ever be valid.

### Does the answer depend on how you glue?

A sceptic will object that $\max$ was baked in by the choice of product norm. Measure the pair with the *sum* of distances, or with the Euclidean combination, and surely the constant changes.

It does not.

**Theorem (Independence of the gluing).** *For all certificates $K_1, K_2 \ge 0$, the number $\max(1+K_1, 1+K_2)$ is simultaneously the least Lipschitz constant of the parallel dilation pair when $X \times Y$ carries the max distance, the sum ($\ell^1$) distance, and the Euclidean ($\ell^2$) distance.*

The intuition is that the extremal inputs are the coordinate directions — perturb only the first stream, or only the second — and along a single coordinate direction all three product norms agree. The amplification factor of a parallel pair is a property of the *pair of blocks*, not of the metric you use to bundle them. That is a genuine invariance statement, and it is what makes the max rule feel less like a convention and more like a law.

The same law scales in both structural directions. For a whole *width* — a family of blocks with certificates $K_i$ running in parallel across $n$ streams, measured in the supremum norm — the gain is $\sup_i (1 + K_i)$, and this too is exactly attained by dilations. For a *depth* — the same block stacked $d$ times — the gain is $(1+K)^d$, again exactly attained. Put the two together and a pair of parallel stacks of depths $d_1, d_2$ has sharp gain $\max\big((1+K_1)^{d_1}, (1+K_2)^{d_2}\big)$, which relaxes to the familiar exponential estimate $\exp\big(\max(K_1 d_1, K_2 d_2)\big)$ — the reason a deep residual tower with small per-layer corrections stays under control: $K$ small and $Kd$ moderate is enough.

### The twist: the same network, two different answers

Now for the part of the story that should change how you compute these bounds in practice.

A rectangular architecture has both width and depth: $w$ parallel streams, $d$ layers deep, with a certificate $K_{ij}$ for the block in stream $i$ at layer $j$. There are two obvious ways to add up the bookkeeping.

- **Depth first.** Compute each stream's total gain by multiplying down its column of layers, then take the max across streams:
  $$\text{sharp} = \max_i \ \prod_j (1 + K_{ij}).$$
- **Width first.** Certify each *layer* as a parallel block, using the max rule to get gain $\max_i(1+K_{ij})$, then multiply the layers together:
  $$\text{coarse} = \prod_j \ \max_i (1 + K_{ij}).$$

Both are valid certificates for *literally the same map*. And the first is always at least as good as the second, because a max of products never exceeds the product of maxima:

$$\max_i \prod_j (1+K_{ij}) \ \le\ \prod_j \max_i (1+K_{ij}).$$

How much worse can width-first be? The honest answer is: catastrophically.

Take two streams, alternate the work between them, and let each block be either trivial ($K = 0$) or a doubling ($K = 1$). Stream A does the work on even layers; stream B on odd layers. At depth $2n$, each stream has been doubled exactly $n$ times, so the true amplification of the pair is $2^n$. But every single layer contains one doubling block somewhere, so width-first certification sees a factor $2$ at *every* layer and reports $4^n$.

**Theorem (Unbounded laxity defect).** *For the alternating width-two architecture at depth $2n$, the least Lipschitz constant of the parallel pair is exactly $2^n$, while layerwise max-then-compose certification yields exactly $4^n$. Consequently the over-estimation factor $2^n$ exceeds any prescribed bound at sufficient depth, even though every individual certificate lies in $\{0,1\}$.*

The overestimate is a factor of $2^n$ — exponential in the depth, from a network in which every block is either the identity or a doubling. The smallest instance is already instructive: with the identity in one stream and a doubling in the other, crossed over between two layers, the composite map is $(x,y)\mapsto(2x,2y)$, whose true constant is $2$; width-first certification announces $4$.

Note carefully what is *not* going wrong. The two wirings really do compute the same function — the interchange law "compose-then-parallelise equals parallelise-then-compose" holds exactly, on the nose, as an identity of maps. It is only the *certificates* that disagree. In categorical language, the assignment of a certificate to a block is a **lax** monoidal functor, not a strong one: it respects the structure only up to an inequality, and that inequality can be arbitrarily strict.

The practical moral is sharp and, we think, underappreciated. Layerwise Lipschitz bookkeeping — the default in most stability analyses of wide architectures — leaks a factor that compounds with depth. Bookkeeping stream-by-stream, and taking the max only at the very end, is free to implement and exponentially tighter.

There is a pretty way to see why. The two quantities $\max_i \prod_j$ and $\prod_j \max_i$ are the two natural "determinant-like" contractions of the matrix of gains in the **max-times tropical semiring**, where addition is $\max$ and multiplication is ordinary multiplication. The laxity defect measures how far apart a max-of-products and a product-of-maxima can be, and the worst cases are exactly the *permutation-like* supports: architectures where each layer's heaviest block sits in a different stream, so that no single stream ever accumulates all the maxima being charged to it.

### Running the film backwards

One last symmetry. Suppose every correction is genuinely a *small* correction: $K < 1$. Then the block $x \mapsto x + r(x)$ is a contraction-perturbation of the identity, and the Banach fixed point theorem does the rest: on a complete space the equation $x + r(x) = y$ has exactly one solution for each $y$. The block is a bijection, and its inverse is $(1-K)^{-1}$-Lipschitz. Invertible residual blocks are exactly what makes normalizing flows and reversible architectures work — you can run the network backwards without storing activations.

And the inverse certificates obey the *same* max rule, thanks to an elementary but pleasing identity:

$$\big(1 - \max(K_1,K_2)\big)^{-1} = \max\big((1-K_1)^{-1},\, (1-K_2)^{-1}\big).$$

**Theorem (Dual max rule).** *If two residual blocks on complete spaces have certificates $K_1, K_2 < 1$, their parallel composition is a bijection of $X \times Y$ whose inverse is $\max\big((1-K_1)^{-1},(1-K_2)^{-1}\big)$-Lipschitz — and this bound is attained, by the inward dilations $x \mapsto (1-K)x$, whose inverses are precisely the outward dilations by $(1-K)^{-1}$.*

So on the contractive regime the calculus is symmetric: forward and backward stability are governed by the identical rule, with the identical sharpness.

### What to take away

Strip away the machine-learning motivation and what is left is a small, complete algebraic theory. Certificates live in $[0,\infty)$ with two operations: serial composition $K_1 \ast K_2 = K_1 + K_2 + K_1K_2$ (secretly multiplication of gains) and parallel composition $\max(K_1,K_2)$. Serial distributes over parallel. The pair $(\ast, \max)$ is precisely the max-times tropical semiring on $[1,\infty)$, and the whole theory of residual architectures is bookkeeping in that semiring.

Three things make it more than bookkeeping. First, the parallel rule is not merely valid but *minimal* — no tighter rule exists. Second, it is *invariant* under the choice of product metric, so it reflects the blocks and not our conventions. Third, and most consequentially, the calculus is *lax*: the same network admits certificates that differ by a factor exponential in its depth, purely as a function of the order in which you do the arithmetic.

The map is the same. The number you report about it need not be. Choosing the right contraction order costs nothing and buys an exponential — which is about the best trade available anywhere in mathematics.
