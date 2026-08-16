# Learning at Absolute Zero
### A guided tour of tropical geometry, frozen networks, and why sharpness beats smoothness

---

## 0. The one-sentence version

A neural network built from rectifiers is a *piecewise-linear* function pretending to be smooth. If you stop pretending — if you push the weights up until every soft blend becomes a hard choice — the network becomes an object in **tropical geometry**, its training landscape becomes a polytope you can see, and its convergence rate becomes something you can *count* rather than estimate.

This page builds that story from nothing. You will need no background beyond "what is a maximum" and "what is a derivative, roughly".

---

## 1. An arithmetic with no subtraction

Replace addition by maximum and multiplication by addition:

$$a \oplus b = \max(a,b), \qquad a \odot b = a + b.$$

Check the laws: both operations are commutative and associative, $\odot$ distributes over $\oplus$ (because $\max(a,b)+c = \max(a+c,b+c)$), the element $-\infty$ is the additive identity and $0$ is the multiplicative identity. This is the **max-plus** or **tropical semiring**. The one thing missing is subtraction — you cannot undo a maximum.

Write a polynomial in this arithmetic and unfold the definitions:

$$p(x) \;=\; c_0 \oplus (a_1\odot x)\oplus(a_2\odot x^{\odot 2})\oplus\cdots \;=\; \max\{c_0,\ a_1+x,\ a_2+2x,\ \dots\}.$$

> **A tropical polynomial in one variable is a maximum of finitely many straight lines.**

Its graph is convex and piecewise linear, with one kink wherever the winning line changes. Each line $(a,c) \mapsto ax+c$ is a **tropical monomial**: $a$ is its slope, $c$ its coefficient. A **tropical rational function** is a difference $p - q$ of two such maxima; dropping convexity, these are exactly the continuous piecewise-linear functions with finitely many pieces.

<details>
<summary>Why is a difference of two convex piecewise-linear functions an arbitrary piecewise-linear function?</summary>

Any continuous piecewise-linear $f$ with finitely many pieces can be written $f = p - q$ where $q$ is a large convex "corrector". Concretely, if the kinks of $f$ are at $x_1 < \cdots < x_r$ with slope jumps $\delta_1,\dots,\delta_r$, split the jumps into positive and negative parts. The positive jumps assemble a convex piecewise-linear $p_+$; the negative jumps, negated, assemble a convex $q$; and $f = (\ell + p_+) - q$ for a suitable affine $\ell$. Each convex summand is a max of affine functions, i.e. a tropical polynomial.
</details>

---

## 2. Freezing a smooth network: watch it happen

Modern architectures are full of soft blends. The prototype is the exp–log aggregator at temperature $T$,

$$\mathrm{LSE}_T(u_1,\dots,u_k) = T\log\bigl(e^{u_1/T}+\cdots+e^{u_k/T}\bigr),$$

which for $T=1$ is the log-partition function of statistical mechanics and, inside a network, is what a softmax gate or a mixture head computes. The parameter $s = 1/T$ is the overall **weight scale**: multiplying every weight of the unit by $s$ is exactly the same as dividing the temperature by $s$.

Lower $T$ and the largest term drowns out the others. The bound is two lines of algebra and completely explicit:

$$\max_j u_j \;\le\; \mathrm{LSE}_T(u_1,\dots,u_k) \;\le\; \max_j u_j + T\log k.$$

> **The Dequantization Theorem.** *A smooth exp–log unit and its tropical shadow never differ by more than $T\log k$, uniformly in the input. Hence the smooth unit converges to the max-plus unit as $T\to 0^{+}$, equivalently as the weight scale $s\to\infty$, at rate $O(1/s)$.*

<details>
<summary>Click to reveal the two-line proof</summary>

Let $M = \max_j u_j$. Since $e^{M/T}$ is one of the $k$ summands and all summands are positive, $e^{M/T} \le \sum_j e^{u_j/T}$; taking $T\log(\cdot)$, which is increasing for $T>0$, gives the lower bound. Since every summand is at most $e^{M/T}$ and there are $k$ of them, $\sum_j e^{u_j/T} \le k\,e^{M/T}$; taking $T\log(\cdot)$ and using $\log(ka) = \log k + \log a$ gives the upper bound. Both steps are exact — no Taylor expansion, no asymptotics.
</details>

Now play with it. Drag the temperature down and watch the smooth curve fall into the creases of the tropical one, always trapped inside the orange band whose width is the certified error $T\log k$. Note especially that widening the layer (raising $k$) barely moves the band: the price of freezing grows only *logarithmically* in the width.

{{interactive_demo:0}}

And here is the same phenomenon plotted quantitatively: on the right, the observed uniform defect against the proved envelope $T\log k$, on log-log axes.

{{visualization:0}}

---

## 3. The dictionary: tropical functions *are* rectifier networks

Which functions live in the frozen world? Exactly the ones your rectifier network already computes.

> **The Tropical–Rectifier Dictionary.** *A function $f:\mathbb{R}\to\mathbb{R}$ is tropical rational if and only if some feed-forward network of rectifier units — affine maps, sums, scalar multiples, and $\mathrm{relu}(u)=\max(u,0)$, at arbitrary depth — computes it exactly.*

The proof is a pair of constructions, and the reverse direction is a single identity you should commit to memory:

$$\boxed{\;\max(u,v) \;=\; v + \mathrm{relu}(u-v)\;}$$

Each extra line in a tropical polynomial costs **exactly one rectifier**. A tropical polynomial with $k$ monomials becomes a network with $k-1$ rectifiers; a tropical rational function $p-q$ becomes the difference of two such blocks. Algebraic complexity and architectural cost are the same number.

<details>
<summary>Click to reveal the forward direction (networks never leave the tropical world)</summary>

Induct on the structure of the network. Affine leaves are tropical rational. For the constructors, write $f = P-Q$ and $h = P'-Q'$ with $P,Q,P',Q'$ tropical polynomials:

- **Sums:** $f + h = (P+P')-(Q+Q')$, and a *sum* of tropical polynomials is again one — this is the tropical **product rule**: $\max_i(\ell_i) + \max_j(\ell'_j) = \max_{i,j}(\ell_i + \ell'_j)$, so the monomials of the product are the pairwise sums.
- **Scalars:** for $c\ge0$, $cf = cP-cQ$ (and $c\max(u,v)=\max(cu,cv)$); for $c<0$, negate.
- **Maxima:** $\max(P-Q,\,P'-Q') = \max(P+Q',\,P'+Q)-(Q+Q')$.
- **Rectifier:** $\mathrm{relu}(f) = \max(f,0)$ and constants are tropical polynomials.

So the tropical rational functions form a lattice-ordered vector space closed under the rectifier, and the network can never escape it.
</details>

Here is the compiler, together with a pruning pass that deletes monomials which never attain the maximum — an *exact*, not approximate, form of model compression.

{{algorithm:0}}

---

## 4. Training: a landscape with no curvature at all

Take the simplest frozen model: the max-plus monomial

$$M_\theta(z) = z \odot \theta = z + \theta,$$

a single trainable shift, and fit it to data $(X_i,Y_i)$ under absolute error. Writing $y_i = Y_i - X_i$ for the residuals, the empirical risk is

$$R(\theta) \;=\; \sum_{i=0}^{N-1}\bigl|\theta - y_i\bigr|.$$

This loss is *itself* a tropical polynomial in $\theta$ — a maximum of $2^N$ affine functions, one per sign pattern, with slopes running over $-N,-N+2,\dots,N$. Training a tropical model on a tropical loss never leaves the tropical category. It is convex, it is $N$-Lipschitz, and it has **zero curvature everywhere**: a stack of straight segments glued at the data points.

Classical wisdom says such landscapes are hard. For a general nonsmooth convex objective, no first-order method beats an error of order $1/\sqrt n$ after $n$ steps.

**But the tropical loss is not general.** It has a property that curvature-based theory has no name for.

---

## 5. Sharpness: the V-shape that replaces strong convexity

Order the residuals $y_0\le y_1\le\cdots\le y_{2m}$ (odd sample size $N=2m+1$) and let $\theta^\star = y_m$ be the median. Then, for **every** $\theta$:

$$R(\theta) \;\ge\; R(\theta^\star) + \lvert\theta - \theta^\star\rvert .$$

> **The Sharpness Theorem.** *The tropical absolute-error risk grows at least linearly, with constant exactly $1$, away from the median. Consequently the median is a minimizer, and it is the unique one.*

Compare with strong convexity, which gives *quadratic* growth $f(x)\ge f^\star + \tfrac\mu2\|x-z\|^2$. Linear growth is **stronger** near the optimum, not weaker — and it is exactly the property a nonsmooth method can exploit.

<details>
<summary>Click to reveal the pairing proof — it is genuinely beautiful</summary>

Sum the loss against its own index reflection $i \mapsto 2m-i$, which is an involution:

$$2R(\theta) = \sum_{i=0}^{2m}\bigl(|\theta - y_i| + |\theta - y_{2m-i}|\bigr).$$

For each $i$, the median $y_m$ lies **between** $y_i$ and $y_{2m-i}$ (if $i\le m$ then $y_i\le y_m\le y_{2m-i}$; otherwise the reverse). And for a point $v$ lying between $u$ and $w$, the elementary inequality

$$|v-u| + |v-w| \;\le\; |\theta-u| + |\theta-w|$$

holds for every $\theta$: the sum of distances to two fixed points is minimized precisely on the segment joining them. So every paired term is at least as small at $\theta^\star$ as at $\theta$. Now look at the *diagonal* pair $i = m$: it contributes $2|\theta - y_m|$ at $\theta$ and $0$ at $\theta^\star$. Discard all the other (nonnegative) terms and keep only that one:

$$2|\theta-\theta^\star| \;\le\; 2R(\theta) - 2R(\theta^\star). \qquad\blacksquare$$
</details>

Sharpness pays an immediate dividend: it converts guarantees about the *loss* into guarantees about the *parameter*. For a general convex loss, a small risk gap tells you nothing about proximity to the argmin — the valley may be long and flat. Sharpness forbids valleys.

---

## 6. Three step rules, three fates

Now train, and watch. In the lab below, the left plot shows the landscape with its sharpness cone (dashed red): the risk can never dip below it, which is why the minimum is unique. The right plot tracks the squared parameter error against the *proved* geometric envelope.

Try all three rules:

1. **A fixed step that is too large.** The iterates lock into a cycle and never approach the optimum. This is not a numerical artifact — it is an exact, permanent failure.
2. **The tuned step $\eta = D/(N\sqrt n)$.** Slow but sure: some iterate before time $n$ is within $DN/\sqrt n$ of optimal, in both risk and parameter.
3. **The Polyak step.** Self-tuning, no hyperparameter, and geometrically fast.

{{interactive_demo:1}}

### 6a. Why the fixed step can fail forever

Take the three samples $0,1,2$ (median $1$), step $\eta = 3$, start at $\theta_0 = 3$. Outside the convex hull of the data the subgradient is *constant* of magnitude $N=3$, so the iterate translates by exactly $9$ every step:

$$3 \to -6 \to 3 \to -6 \to \cdots$$

an exact two-cycle, never within distance $2$ of the optimum. There is no restoring force proportional to the error — precisely what curvature would have supplied. So the statement "gradient descent converges to the optimum" is simply **false** for a fixed step on a tropical loss; the correct statements are the best-iterate bound and the Polyak bound.

### 6b. Why the Polyak step converges geometrically

With optimal value $R^\star$ known, take

$$\theta_{k+1} = \theta_k - \frac{R(\theta_k)-R^\star}{g(\theta_k)^2}\,g(\theta_k).$$

> **The Geometric Convergence Theorem.** *If $R$ is convex with subgradient bound $G$ and sharp with constant $\mu>0$ at $\theta^\star$, then every Polyak step contracts the squared distance:*
> $$(\theta_{k+1}-\theta^\star)^2 \le \Bigl(1-\frac{\mu^2}{G^2}\Bigr)(\theta_k-\theta^\star)^2,$$
> *hence $(\theta_n-\theta^\star)^2 \le (1-\mu^2/G^2)^n(\theta_0-\theta^\star)^2$ and $\theta_n\to\theta^\star$.*

For the tropical fit, $\mu = 1$ and $G = N$, so the guaranteed factor is $1 - 1/N^2$.

<details>
<summary>Click to reveal the contraction proof</summary>

Write $d = R(\theta)-R^\star$ and $g = g(\theta)$, and set $t = d/g^2$ so the step is $\theta - tg$. Expanding,

$$(\theta - tg-\theta^\star)^2 = (\theta-\theta^\star)^2 - 2t\,g(\theta-\theta^\star) + t^2g^2 .$$

Convexity gives $d \le g(\theta-\theta^\star)$, and $t^2g^2 = td$, so the right-hand side is at most $(\theta-\theta^\star)^2 - 2td + td = (\theta-\theta^\star)^2 - td$. Sharpness gives $d \ge \mu|\theta-\theta^\star|$, hence $d^2 \ge \mu^2(\theta-\theta^\star)^2$, and $g^2 \le G^2$; therefore

$$td = \frac{d^2}{g^2} \ge \frac{\mu^2}{G^2}(\theta-\theta^\star)^2 . \qquad\blacksquare$$

A by-product of the same reasoning: evaluating sharpness at $\theta^\star+1$ and comparing with the affine minorant gives $\mu \le G$, so the factor $1-\mu^2/G^2$ really does lie in $[0,1)$.
</details>

Here are the two regimes side by side, with the sharpness cone and the trajectories:

{{visualization:1}}

And the algorithm itself, which reports the certificate at every step:

{{algorithm:1}}

**The bottom line.** To reach accuracy $\varepsilon$ from distance $D$: the tuned fixed step needs $\sim D^2N^2/\varepsilon^2$ iterations; the Polyak step needs $\sim 2N^2\log(D/\varepsilon)$. The dependence on $\varepsilon$ collapses from polynomial to logarithmic.

---

## 7. But surely a *real* network does better?

No — and this is the sharpest (pun intended) conclusion of the whole story.

> **Risk-Landscape Equivalence.** *A one-variable function is tropical rational if and only if there is a rectifier network whose empirical absolute-error risk agrees with it on **every** finite data set.*

<details>
<summary>Click to reveal the one-point trick</summary>

One direction is the dictionary: equal functions have equal risks. For the other, suppose $f$ and the network $e$ have equal risk on every data set. Fix any $x$ and apply this to the *single-point* data set $X_0 = x$, $Y_0 = f(x)$. The risk of $f$ is $|f(x)-f(x)| = 0$, so the risk of $e$ is $0$, i.e. $|e(x)-f(x)| = 0$. Since $x$ was arbitrary, $e = f$ pointwise — and equality of risks on all data sets is equality of functions.
</details>

So the tropical class and the rectifier class have *identical* loss landscapes: same minimizers, same sharpness constants, same Lipschitz constants, same rates. Whatever speed you observe when training a piecewise-linear model does not come from depth or architecture. It comes from the **geometry of the loss**, encoded in two numbers:

| invariant | meaning | value here |
|---|---|---|
| $G$ | largest tropical slope = Lipschitz constant = subgradient bound | $N$ |
| $\mu$ | sharpness constant: linear growth away from the optimum | $1$ |
| $\mu/G$ | the **tropical condition number** | $1/N$ |

These play the role that $m/L$ (strong convexity over smoothness) plays for smooth problems — except that here they are *combinatorial*: read off from which lines are active at the optimum.

---

## 8. Run everything yourself

The following script checks every claim above numerically: the dequantization band, the compilation, the sharpness inequality on random samples, both convergence rates against their proved envelopes, the two-cycle, and the landscape equivalence.

{{demo:0}}

And the annealing routine, which turns the dequantization bound into an actual training schedule: pick the temperature $T = \varepsilon/(2N\log k)$ and any $\varepsilon/2$-optimal point of the smooth surrogate is $\varepsilon$-optimal for the tropical problem.

{{algorithm:2}}

---

## 9. Where this goes next

The one-variable theory is complete: $\mu = 1$, $G = N$, contraction $1-1/N^2$, all constants explicit. In $\mathbb{R}^d$ two things change. The tropical product rule generalizes verbatim — the algebra is not the obstacle. But the median/pairing argument does not: in higher dimension the $L^1$ minimizer is a coordinatewise median only for separable losses. The right generalization of $\mu/G$ should be a ratio of slopes in the **normal fan of a Newton polytope** at the optimal vertex, which would make the convergence rate of first-order training computable by counting the faces of a polytope, with no analytic estimate anywhere.

Two conjectures make this precise.

**Conjecture (a tropical condition number governs all first-order rates).** For a tropical rational loss on $\mathbb{R}^d$ with maximal slope $G$ and sharpness $\mu$, Polyak-step descent contracts squared distance by exactly $1-\mu^2/G^2$ per step, and no first-order method beats $(1-\mu^2/G^2)^{n/2}$ on the worst instance with those invariants.

**Conjecture (dequantization commutes with training).** If $\theta_T(n)$ is the $n$-th iterate of the smooth network at temperature $T$ and $\theta_0(n)$ that of its tropical limit, then $|\theta_T(n)-\theta_0(n)| \le C\,n\,T\log k$, so the two training trajectories share a limit set as $T\to 0^{+}$. The defect is $T\log k$ *per unit*, so it can accumulate only linearly along a trajectory of nonexpansive updates; what is missing is a discrete Grönwall argument for piecewise-linear update maps.

---

## Further reading

- [Tropical geometry](https://en.wikipedia.org/wiki/Tropical_geometry) — the general theory of the max-plus semiring and its polytopes.
- [Max-plus algebra](https://en.wikipedia.org/wiki/Max-plus_algebra) — the algebraic side, with applications to scheduling and discrete event systems.
- [Subgradient methods](https://en.wikipedia.org/wiki/Subgradient_method) — the classical $O(1/\sqrt n)$ theory and the Polyak step size.
- [Rectifier (neural networks)](https://en.wikipedia.org/wiki/Rectifier_(neural_networks)) — the activation that makes networks piecewise linear.
- [Newton polytope](https://en.wikipedia.org/wiki/Newton_polygon) — the combinatorial object whose normal fan is conjectured to control the rate in higher dimension.
- [LogSumExp](https://en.wikipedia.org/wiki/LogSumExp) — the smooth maximum, and its role as a free energy.

---

*Freezing a network costs at most $T\log k$, uniformly. What you get back is a crystal you can see through.*
