# The Tree That Grew Too Slowly: Silver Ratios, Pythagorean Triples, and a Conjecture That Wasn't

## A perfect tree

Every schoolchild meets $3^2 + 4^2 = 5^2$. Fewer meet the astonishing fact that *every* right triangle with whole-number sides — every one, without exception, forever — can be reached from $(3,4,5)$ by a sequence of three simple moves.

This is the **Berggren tree**, discovered by the Swedish mathematician B. Berggren in 1934 and rediscovered independently by F. J. M. Barning and A. Hall in the 1960s. Start with $(3,4,5)$. Apply any of three fixed $3\times 3$ integer matrices,

$$A_1 = \begin{pmatrix} 1 & -2 & 2\\ 2 & -1 & 2 \\ 2 & -2 & 3\end{pmatrix},\quad A_2 = \begin{pmatrix} 1 & 2 & 2\\ 2 & 1 & 2 \\ 2 & 2 & 3\end{pmatrix},\quad A_3 = \begin{pmatrix} -1 & 2 & 2\\ -2 & 1 & 2 \\ -2 & 2 & 3\end{pmatrix},$$

to the column vector $(a,b,c)^{T}$, and out comes another *primitive* Pythagorean triple — one whose legs share no common factor. Repeat. You get an infinite ternary tree: one node at the root, three at depth one, nine at depth two, $3^k$ at depth $k$. And the miracle is that this tree is **exact**: no triple appears twice, and none is ever missed.

$$(3,4,5) \to (5,12,13),\ (21,20,29),\ (15,8,17) \to \cdots$$

It is one of the most beautiful objects in elementary number theory: a perfect, lossless, three-fold branching enumeration of an infinite arithmetic family.

## The silver ratio takes the stage

Trees grow. How fast does this one grow?

Look at the middle branch — apply $A_2$ over and over. The hypotenuses are
$$5,\ 29,\ 169,\ 985,\ 5741,\ 33461,\ 195025,\ \ldots$$
These are the odd-indexed **Pell numbers**, and they satisfy the tidy recurrence
$$c_{k+2} = 6c_{k+1} - c_k .$$
The characteristic equation $x^2 - 6x + 1 = 0$ has roots
$$\lambda = 3 + 2\sqrt{2} \approx 5.8284, \qquad \lambda^{-1} = 3 - 2\sqrt{2} \approx 0.1716,$$
and these are exactly the eigenvalues of the Barning matrices. The dominant one is the **square of the silver ratio**: if $\delta_S = 1 + \sqrt 2 \approx 2.4142$ is the silver ratio — the humbler cousin of the golden ratio, the number satisfying $x = 2 + 1/x$ — then $\lambda = \delta_S^2$.

So along the middle spine the hypotenuse multiplies by $3 + 2\sqrt 2$ each step. There is an exact formula:
$$c_k = \frac{(10 + 7\sqrt 2)\,\lambda^{k} + (10 - 7\sqrt 2)\,\lambda^{-k}}{4},$$
and consequently $\frac{\log c_k}{k} \to \log(3 + 2\sqrt 2) = 2\log(1+\sqrt 2)$.

Better still, this is a genuine **speed limit** for the entire tree, not just for one branch. Every node at depth $k$ has hypotenuse at most
$$c \le 2\,(3 + 2\sqrt 2)^{\,k+1}.$$
Nothing in the tree outruns the silver ratio. (The proof is a small gem: attach to each node the "silver potential" $\Phi(m,n) = m + (\sqrt 2 - 1)n$ built from its Euclid parameters, and check that each of the three moves multiplies $\Phi$ by at most $1 + \sqrt 2$ — with *equality* precisely for the middle move. The extremal branch is the middle spine, and everything else is slower.)

## Counting by decay: the zeta idea

Number theorists have a favourite way to extract the statistics of an infinite family: build a **Dirichlet series**. Take every object in the family, raise its "size" to the power $-s$, and add up. If the objects are the positive integers you get Riemann's $\zeta(s) = \sum n^{-s}$, which converges for $s > 1$ and blows up at $s = 1$ — the fingerprint of the fact that there are about $H$ integers below $H$.

The point where a Dirichlet series stops converging is called its **abscissa of convergence**, and it is a compressed summary of how densely the family is distributed. So: define the **Berggren tree zeta function**
$$Z(s) \;=\; \sum_{w} c(w)^{-s},$$
where $w$ runs over *all* nodes of the tree — all words in three letters — and $c(w)$ is the hypotenuse living at node $w$. Where is its abscissa?

Here is the natural guess, and it is a seductive one. The depth-$k$ layer contains $3^k$ nodes. Each of them has hypotenuse at most $\approx \lambda^{k}$. So group the sum by layers and bound each layer by its largest term:
$$Z(s) \;\lesssim\; \sum_{k \ge 0} 3^k \cdot \left(\lambda^{k}\right)^{-s} \;=\; \sum_{k\ge 0}\left(3\lambda^{-s}\right)^{k},$$
a geometric series that converges exactly when $3\lambda^{-s} < 1$, i.e. when
$$s \;>\; \sigma_{\text{silver}} \;=\; \frac{\log 3}{\log(3 + 2\sqrt 2)} \;=\; 0.62324\ldots$$

That is a beautiful number. Three branches, silver growth, and out drops a fractal-looking exponent $\log 3/\log \lambda$ — precisely the shape of a Hausdorff dimension. Any self-respecting conjecture would be that this is the abscissa of convergence: *the Berggren tree's analytic character is governed by the silver ratio*.

It is false.

## The abscissa is exactly $1$

**Theorem.** *The Berggren tree zeta function $Z(s) = \sum_w c(w)^{-s}$ converges for every $s > 1$ and diverges for every $s \le 1$. Its abscissa of convergence is exactly $1$.*

Both halves are provable by hand, and the two arguments are pleasingly different in flavour.

**Why it converges past $1$.** The right coordinates are Euclid's. Every primitive triple with odd first leg is $(m^2-n^2,\ 2mn,\ m^2+n^2)$ for a unique pair $(m,n)$ with $0 < n < m$, coprime, of opposite parity — call such a pair a *Euclid seed*. In these coordinates the three Barning matrices become breathtakingly simple:
$$s_0(m,n) = (2m-n,\ m),\qquad s_1(m,n) = (2m+n,\ m),\qquad s_2(m,n) = (m+2n,\ n),$$
acting on the root seed $(2,1)$. Every seed invariant — positivity, coprimality, opposite parity — is preserved by one line of arithmetic apiece; injectivity of the labelling follows because the three moves land in disjoint angular sectors ($m < 2n$, $2n<m<3n$, $m > 3n$); and completeness follows by strong induction on $m$, running the moves backwards.

Now the sum over tree nodes *is* a sum over seeds, and since $c = m^2 + n^2 \ge m^2$,
$$Z(s) \;=\; \sum_{\text{seeds }(m,n)} (m^2+n^2)^{-s} \;\le\; \sum_{m \ge 1}\ \sum_{n < m} m^{-2s} \;=\; \sum_{m\ge 1} m^{1 - 2s},$$
which converges for $s > 1$. Note what happened: the layer structure has vanished entirely. What controls the sum is the *two-dimensional* lattice of seeds, not the ternary branching.

**Why it diverges at $1$ and below.** Here we plant primes in the tree. If $p$ is an odd prime and $1 \le j$ with $2j < p$, then $(p, 2j)$ is a legitimate Euclid seed — coprimality is free because $p$ is prime and $2j < p$, and the parity is right because $p$ is odd. By completeness, each of these sits somewhere in the tree. Its hypotenuse is $p^2 + 4j^2 \le 2p^2$, so
$$\sum_{w} \frac{1}{c(w)} \;\ge\; \sum_{p \text{ odd prime}}\ \sum_{j=1}^{(p-1)/2} \frac{1}{2p^2} \;\ge\; \sum_{p} \frac{1}{8p},$$
and Euler's theorem that $\sum_p 1/p$ diverges finishes the job. Since the terms only grow as $s$ decreases, divergence at $s=1$ propagates to all $s \le 1$.

So the abscissa is $1$, and the silver-ratio prediction $0.62324\ldots$ is off by a wide margin. In fact the failure is quantitative and pinpointable:

**Theorem (the gap is real).** *For every $s$ with $0.6233 < s \le 1$, the layer majorant $\sum_k 3^k(2\lambda^{k+1})^{-s}$ converges while $Z(s)$ diverges.*

The heuristic isn't wrong about the layers — it correctly bounds the layer maximum. It is wrong about *typical* nodes.

## Why the heuristic fails: a tree of wildly unequal branches

Here is the picture that explains everything. Take the depth-$k$ layer, all $3^k$ nodes of it, and look at the range of hypotenuses inside it.

At the top, the middle spine, reached by $A_2^k$: hypotenuse $\approx \lambda^k$, growing exponentially.

At the bottom, the *slow spine*, reached by applying the first move $s_0$ over and over: the seed at depth $k$ is $(k+2,\ k+1)$, so the hypotenuse is
$$c = (k+2)^2 + (k+1)^2 = 2k^2 + 6k + 5 .$$
That grows merely **quadratically** — $13, 25, 41, 61, 85, \ldots$ — while its sibling at the same depth has raced off to $\lambda^k$.

| depth $k$ | nodes | smallest $c$ | median $c$ | largest $c$ |
|---|---|---|---|---|
| 4 | 81 | 61 | 949 | 5{,}741 |
| 8 | 6{,}561 | 181 | 166{,}025 | 6{,}625{,}109 |
| 12 | 531{,}441 | 365 | 28{,}529{,}485 | 7{,}645{,}370{,}045 |

At depth $12$ the layer maximum exceeds the layer minimum by a factor of twenty million. Replacing every node in a layer by the largest one is not a mild overestimate — it is a catastrophe. The layer maximum is governed by a single eigenvalue; the *distribution* inside a layer is governed by the statistics of the words, and the words with lots of $s_2$'s stay small forever.

The moral generalises well beyond this tree. **When a self-similar family is exponentially branching but the sizes within each generation are exponentially spread, the top eigenvalue tells you almost nothing about the analytic behaviour.** The zeta function sees the whole distribution.

## What the abscissa really means: an exact counting law

An abscissa at $1$ is a statement about counting. Let $N(H)$ be the number of Berggren nodes with hypotenuse at most $H$ — equivalently, by completeness, the number of primitive Pythagorean triples with odd first leg and hypotenuse $\le H$.

**Theorem.** *For all $H \ge 512$,*
$$\frac{H}{50} \;\le\; N(H) \;\le\; 2H .$$
*In particular $N(H) = \Theta(H)$: the count grows linearly in $H$, not like $H^{0.623}$.*

The upper bound is immediate: $c \le H$ forces $m \le \sqrt H$ and $n < m$, so there are at most about $H$ pairs. The lower bound is a hand-rolled sieve, and it is worth spelling out because it is entirely elementary:

- The triangle $\{1 \le n < m \le M\}$ contains $M(M-1)/2$ pairs.
- Pairs sharing a common factor $d \ge 2$ number at most $\tfrac{M^2}{2}\sum_{d\ge 2} d^{-2}$, and the telescoping estimate $\sum_{d\ge 2} d^{-2} \le 25/36$ makes this at most $\tfrac{25}{72}M^2$. So at least $\tfrac{11}{72}M^2$ coprime pairs survive.
- At least half of those have opposite parity. Why? Because the map $(m,n) \mapsto \left(\tfrac{m+n}{2}, \tfrac{m-n}{2}\right)$ is an injection from coprime odd–odd pairs into coprime opposite-parity pairs. (Coprime pairs are never even–even.)
- Every surviving pair with $m \le M$ has $c = m^2+n^2 \le 2M^2$, giving $N(2M^2) \ge \tfrac{11}{144}M^2 - \tfrac{M}{4}$, and rescaling gives the clean form.

Notice something delicious: **the counting law and the abscissa can each be derived without the other, by completely disjoint means.** One route goes through prime seeds and Euler's divergence of $\sum 1/p$; the other goes through this coprimality sieve. And they can be *joined*: a dyadic block argument shows that the counting law alone forces the zeta function to diverge at $s=1$. Between $H$ and $128H$ the tree acquires at least $128H/50 - 2H = 0.56H$ new nodes, each contributing at least $1/(128H)$ to the harmonic sum, so each block adds at least $0.56/128 > 1/300$. Iterating,
$$\sum_{c(w) \le 512\cdot 128^{k}} \frac{1}{c(w)} \;\ge\; \frac{k}{300},$$
which is a hard, explicit, logarithmic divergence. That is a miniature **Tauberian theorem**: counting statistics on one side, analytic behaviour on the other, and an explicit bridge between them.

## The legs tell the same story — for a different reason

Each node carries not just a hypotenuse but two legs, $a = m^2 - n^2$ (odd) and $b = 2mn$ (even). One can form leg zeta functions $Z_a(s) = \sum_w a(w)^{-s}$ and $Z_b(s) = \sum_w b(w)^{-s}$.

**Theorem.** *Both leg zeta functions also have abscissa of convergence exactly $1$.*

Divergence below $1$ is easy — the legs are smaller than the hypotenuse, so the leg series dominate the hypotenuse series termwise. But convergence above $1$ *cannot* be inherited from the hypotenuse, because the legs are not comparable to $c$ from below: along the spine of repeated third moves the seed is $(2k+2,1)$, so the even leg $b = 2mn$ is linear in $k$ while $c$ is quadratic, and $b/c \to 0$; along the slow spine the seed is $(k+2,k+1)$, so the odd leg $a = m^2-n^2 = 2k+3$ is linear while $c$ is quadratic, and $a/c \to 0$. The fix is to exploit the *multiplicative* structure: $b = 2mn \ge m\cdot n$ and $a = (m-n)(m+n) \ge (m-n)\cdot m$. Each is a product of two nearly-independent parameters, so
$$a(w)^{-s} \le u^{-s}v^{-s}, \qquad b(w)^{-s} \le m^{-s}n^{-s},$$
and the double sum $\sum_{u,v\ge 1} u^{-s}v^{-s} = \zeta(s)^2$ converges. Two different reindexings of the seed lattice, $(m,n)\mapsto(m,n)$ and $(m,n)\mapsto(m-n,m)$, do the two cases.

This is a nice subtlety: the even legs have a *different* counting function from the hypotenuses (there are roughly $B\log B$ values of $2mn$ below $B$ counted with multiplicity, versus $\Theta(B)$ hypotenuses), yet the abscissa is unchanged. The abscissa is robust; the finer asymptotics are not.

## What comes next: a pole at $s=1$, with residue $1/(2\pi)$

The bounds $H/50 \le N(H) \le 2H$ pin the order of growth but leave a factor of a hundred in the constant. Numerically the truth is unmistakable:

| $H$ | $N(H)$ | $N(H)/H$ |
|---|---|---|
| $10^3$ | 158 | 0.1580 |
| $10^4$ | 1{,}593 | 0.15930 |
| $10^5$ | 15{,}919 | 0.159190 |
| $10^6$ | 159{,}139 | 0.1591390 |
| $4\times 10^6$ | 636{,}617 | 0.15915425 |

and $1/(2\pi) = 0.15915494\ldots$

**Conjecture.** $\displaystyle \lim_{H\to\infty} \frac{N(H)}{H} = \frac{1}{2\pi}$, *and consequently $Z(s)$ extends meromorphically past $s=1$ with a simple pole there of residue $1/(2\pi)$.*

The heuristic is transparent once one is in seed coordinates. $N(H)$ counts lattice points $(m,n)$ with $m^2+n^2 \le H$, $0 < n < m$, $\gcd(m,n)=1$, $m+n$ odd. The quarter-disc of radius $\sqrt H$ has area $\pi H/4$; restricting to $n<m$ halves it to $\pi H/8$; the coprimality condition contributes a density factor $6/\pi^2$; the opposite-parity condition, conditioned on coprimality, contributes a further factor $2/3$. Multiply:
$$\frac{\pi H}{8}\cdot\frac{6}{\pi^2}\cdot\frac{2}{3} \;=\; \frac{H}{2\pi}.$$
A Gauss circle count twisted by a coprimality-and-parity sieve. The pieces are all classical; assembling them with the right error terms is the remaining work.

## The shape of the lesson

We began with a conjecture: that the silver ratio, which so evidently and provably governs the *geometry* of the Berggren tree, would also govern its *analysis*. It does not. The abscissa of convergence is $1$, a full $0.38$ to the right of the silver prediction, and the reason is the enormous internal spread of each generation.

But this is not a failure — it is a sharpening. The refutation comes with a replacement: an exact abscissa, an exact order of growth $\Theta(H)$ for the counting function, a Tauberian bridge from one to the other, matching results for the legs, and a precise conjectural constant $1/(2\pi)$ with a clean geometric derivation. The silver ratio keeps its throne over the tree's metric growth — the speed limit $c \le 2(3+2\sqrt 2)^{k+1}$ and the exact spine formula are as true as ever. It simply does not rule the tree's arithmetic density.

There is a general principle hiding here that anyone who works with self-similar structures — fractals, random walks, branching processes, dynamical zeta functions, expander graphs — will recognise. Growth rates and densities are different animals. A top eigenvalue is a statement about the fastest branch. A zeta function is a statement about all branches at once, weighted by how many of them are actually small. When the branches diverge in speed, so do the two answers.

The Berggren tree, three moves and a right triangle, turns out to be a perfect laboratory for that distinction.
