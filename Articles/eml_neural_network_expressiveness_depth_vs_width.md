# Two Neurons That Beat a Thousand

## How a curved activation function turns the hardest easy problem in machine learning into a one-line identity

### The parabola problem

Here is a task so simple it sounds like a joke: build a neural network that computes $x^2$ for $x$ between $0$ and $1$.

No hidden structure, no adversarial data, no high-dimensional curse. Just the parabola. And yet this innocuous target is one of the sharpest instruments we have for measuring what a network architecture can and cannot do — because for the workhorse activation of modern deep learning, the rectified linear unit
$$\mathrm{relu}(t) = \max(t, 0),$$
the parabola is genuinely *hard*.

A one-hidden-layer ReLU network is a sum
$$R(x) = c_0 + c_1 x + \sum_{i=1}^{k} a_i \,\mathrm{relu}(w_i x + b_i),$$
with completely arbitrary real parameters, and we generously allow the affine "skip connection" $c_0 + c_1 x$ for free. Whatever you choose, $R$ is a **piecewise linear** function: a polyline. Each unit contributes at most one kink, at the point $x = -b_i/w_i$ where its argument changes sign. With $k$ units you get at most $k$ kinks, hence at most $k+1$ straight segments on $[0,1]$.

Now the pigeonhole principle does its quiet work. Cut $[0,1]$ into $k+1$ equal subintervals of length $1/(k+1)$. There are at most $k$ kinks to distribute among $k+1$ boxes, so *some box is empty*: on that subinterval the entire network — every unit, the skip connection, all of it — collapses to a single straight line $\alpha x + \beta$.

And a straight line cannot follow a parabola. Sample the parabola and the line at the quarter, half, and three-quarter points of an interval of length $L$; the second difference of $x^2$ over spacing $L/4$ is exactly $2(L/4)^2 = L^2/8$, while the second difference of any affine function is zero. Splitting the discrepancy across the three sample points gives the clean bound: if $|x^2 - (\alpha x + \beta)| \le \varepsilon$ throughout an interval of length $L$, then
$$\varepsilon \;\ge\; \frac{L^2}{32}.$$

Put the two halves together with $L = 1/(k+1)$ and you have a theorem that no amount of clever training can dodge.

> **Theorem (Shallow ReLU barrier).** For every $k$, every choice of weights $a_i, w_i, b_i$ and every skip connection $c_0 + c_1x$, the one-hidden-layer ReLU network $R$ satisfies
> $$\max_{0 \le x \le 1} |x^2 - R(x)| \;\ge\; \frac{1}{32\,(k+1)^2}.$$

So accuracy $\varepsilon$ costs a shallow ReLU network at least $(k+1)^2 \ge 1/(32\varepsilon)$, i.e. **width $\Omega(\varepsilon^{-1/2})$**. Want three more decimal digits? Multiply your width by about thirty-two.

The same argument bites even harder on *derivatives*. On that empty box the network's slope is a single constant $\alpha$, while the true slope $2x$ sweeps across an interval of length $2/(k+1)$. Somewhere the mismatch is at least half of the sweep:
$$|\alpha - 2x| \;\ge\; \frac{1}{2(k+1)}$$
for some $x$ in the box. A shallow ReLU network's gradient field is only first-order accurate, no matter how many units you throw at it. For anyone doing physics-informed learning, sensitivity analysis, or optimal control — where the *derivative* of the network is the object of interest — that is bad news.

### Change the neuron, not the network

Now swap the activation. An **EML neuron** (exponential-minus-logarithm) computes
$$x \;\longmapsto\; e^{\,a x + b} \;-\; \log(c x + d),$$
with four real parameters. An **EML layer of width $k$** is an affine read-out of $k$ such neurons,
$$L(x) = \beta + \sum_{i=1}^{k} \gamma_i \left( e^{\,a_i x + b_i} - \log(c_i x + d_i)\right),$$
and depth is obtained by feeding one layer into the next.

Here is the punchline, and it takes two neurons.

Set $c = 0$ and $d = 1$ in both, so the logarithmic branches vanish ($\log 1 = 0$), give the first neuron $a = h$ and the second $a = -h$, and read out with weights $1/h^2$ each and bias $-2/h^2$. The layer computes
$$S_h(x) \;=\; \frac{e^{hx} + e^{-hx} - 2}{h^2}.$$

This is a **width-2 EML layer**, and it is nothing but the central second difference of the exponential — or, if you prefer, $\frac{2}{h^2}\big(\cosh(hx) - 1\big)$. Its Taylor expansion is
$$S_h(x) = x^2 + \frac{h^2 x^4}{12} + \frac{h^4x^6}{360} + \cdots$$

Every term after the first carries a factor $h^2$. Shrink $h$ and the parabola emerges.

> **Theorem (Second-order squaring at width two).** If $|hx| \le 1$ then
> $$\left| S_h(x) - x^2 \right| \;\le\; \frac{h^2 x^4}{6}.$$
> In particular, on $[0,1]$ the error is at most $h^2/6$, and with $h = 1/n$ it is at most $1/(6n^2)$.

The proof is a controlled Taylor remainder: expand $e^u$ and $e^{-u}$ to fifth order at $u = hx$, note that all odd powers cancel in the sum, and bound the tail by $u^4/6$ for $|u| \le 1$.

Two neurons. Fixed. Forever. Whatever accuracy $\varepsilon$ you demand, choose $h = \min(1, \varepsilon)$ and the same two-neuron layer delivers it. And the rate cannot be improved: at the endpoint $x = 1$ a matching lower Taylor estimate gives
$$\left| S_h(1) - 1 \right| \;\ge\; \frac{h^2}{14} \qquad (0 < h \le 1),$$
so the error is genuinely $\Theta(h^2)$ — the exponent $2$ is exact, and the constant is pinned between $1/14$ and $1/6$. (Numerically the true constant is $1/12$, exactly as the Taylor series predicts.)

### The separation

Stack the two theorems side by side and you get a clean statement about two model classes.

> **Theorem (Width separation).** For every accuracy $\varepsilon > 0$:
> - some EML layer of width **$2$** approximates $x^2$ on $[0,1]$ to within $\varepsilon$;
> - every one-hidden-layer ReLU network with $k$ units that does so must satisfy $(k+1)^2 \ge 1/(32\varepsilon)$.

Concretely, to match the accuracy $1/(6n^2)$ of the two-neuron EML layer with $h = 1/n$, a shallow ReLU network needs $16(k+1)^2 \ge 3n^2$, roughly $k \approx 0.43\,n$ units. At $n = 1000$ that is four hundred and thirty ReLU units against two EML neurons.

There is, of course, no free lunch, and it is worth naming the price honestly. The EML construction buys accuracy with *weight magnitude*: the read-out weight is $1/h^2$, so accuracy $h^2$ costs a coefficient of size $1/h^2$, and the two exponentials very nearly cancel. Width and precision are two currencies, and the theorem says EML can pay in either while shallow ReLU can only pay in width. Under a bounded-weight budget the separation would have to be re-examined — a question we return to at the end.

### Gradients come along for free

Differentiate $S_h$ and you get $\big(e^{hx} - e^{-hx}\big)/h$, which is the corresponding central difference for $\sinh$. The same cancellation of even powers applies, and the same fixed pair of neurons tracks the *derivative* of the target:
$$\left| \frac{e^{hx} - e^{-hx}}{h} - 2x \right| \;\le\; \frac{h^2}{2}, \qquad 0 < h \le 1, \; x \in [0,1].$$

Compare with the ReLU slope bound $1/(2(k+1))$: a shallow ReLU net's gradient error decays like $1/k$, while a fixed EML pair's decays like $h^2$. This is the precise sense in which the smooth activation gives "smoother gradients" — not a heuristic, an inequality.

### Depth multiplies degree

What does depth buy? Compose the layer with itself. Since $S_h(x) \approx x^2$, we should have $S_h(S_h(x)) \approx x^4$, and the composition should not amplify errors too badly. It doesn't.

> **Theorem (Depth-2 quartic).** For $0 < h \le 1/2$ and $x \in [0,1]$,
> $$\left| S_h\big(S_h(x)\big) - x^4 \right| \;\le\; h^2.$$

The proof is a two-line error decomposition with one subtlety. Write $y = S_h(x)$; then
$$S_h(S_h(x)) - x^4 = \underbrace{\big(S_h(y) - y^2\big)}_{\text{inner layer's error, at } y} + \underbrace{\big(y^2 - x^4\big)}_{\text{propagated error}} .$$
The second piece factors as $(y - x^2)(y + x^2)$, so it is controlled once you know $y$ stays bounded: indeed $|y - x^2| \le h^2/6 \le 1/24$, so $|y| \le 25/24$, which is exactly what keeps the pre-activation $|hy| \le 1$ inside the range where the Taylor bound is valid. That stability constraint — the output of one layer must remain in the regime where the next layer's estimate holds — is the entire content of the hypothesis $h \le 1/2$, and it is the mechanism by which depth composes safely. Two layers of width two, four neurons total, and you have a degree-four polynomial to second order.

### From squares to products, and to every quadratic form

One classical identity turns a squarer into a multiplier:
$$xy \;=\; \frac{(x+y)^2 - (x-y)^2}{4}.$$
This is *polarisation*, the same trick that recovers an inner product from a norm. Apply the width-2 layer at the two pre-activations $x+y$ and $x-y$ and combine:
$$P_h(x,y) \;=\; \frac{S_h(x+y) - S_h(x-y)}{4}.$$
That is four EML neurons — a **multiplication gate**.

> **Theorem (Multiplication gate).** For $0 < h \le 1/2$ and $x, y \in [0,1]$,
> $$\left| P_h(x,y) - xy \right| \;\le\; h^2,$$
> and at the corner $(1,1)$ the error is at least $2h^2/7$. The rate is exactly $\Theta(h^2)$.

Multiplication is the gateway to many variables. Every quadratic form $q(x) = \sum_{i,j} A_{ij} x_i x_j$ on $[0,1]^n$ is a weighted sum of products, so replacing each product by a gate gives a **single EML layer of width $4n^2$** with
$$\left| \sum_{i,j} A_{ij} P_h(x_i, x_j) - q(x) \right| \;\le\; h^2 \sum_{i,j} |A_{ij}|.$$
The constant $h^2$ is *dimension-free*: the ambient dimension enters only through the total coefficient mass $\sum |A_{ij}|$, never through an exponential factor. No curse of dimensionality lurks here, because quadratic forms are a low-complexity class and the gate is exact in the right sense.

Meanwhile, the ReLU barrier survives the passage to two variables, and it does so for free. A bivariate one-hidden-layer ReLU network restricted to the diagonal $y = x$ is again a univariate one-hidden-layer ReLU network — the unit $\mathrm{relu}(w_i x + v_i y + b_i)$ becomes $\mathrm{relu}((w_i + v_i)x + b_i)$, and $xy$ becomes $x^2$. So the same $1/(32(k+1)^2)$ bound applies verbatim: approximating the product on $[0,1]^2$ costs shallow ReLU width $\Omega(\varepsilon^{-1/2})$, while EML pays a flat width of $4$.

### The other direction: EML is never worse

A separation theorem is only half a story. Could the smooth activation be *bad* at something ReLU finds easy — at kinks, at corners, at non-smooth targets?

No, and for a charming reason: **ReLU hides inside EML at depth two**. The softplus function
$$\mathrm{softplus}(t) = \log(1 + e^{t})$$
is an exponential followed by a logarithm — precisely one EML neuron feeding into another. And softplus is a uniform approximation of ReLU after rescaling:
$$\left| \frac{\log(1 + e^{Mt})}{M} - \mathrm{relu}(t) \right| \;\le\; \frac{\log 2}{M} \qquad \text{for all } t, \; M > 0,$$
with equality at $t = 0$, where the smooth curve rounds off the corner by exactly $\log 2 / M$. Both inequalities are elementary: $\mathrm{relu}(t) \le \mathrm{softplus}(t) \le \mathrm{relu}(t) + \log 2$.

Consequently, a depth-2 EML network with $k$ parallel chains reproduces any $k$-unit shallow ReLU network to within $\big(\sum_i |a_i|\big)\log 2/M$, uniformly on the whole line, and $M$ is ours to choose. Every shallow ReLU approximation theorem therefore transfers:

> **Theorem (Lipschitz rate).** Let $f$ be $L$-Lipschitz on $[0,1]$. For every width $N \ge 1$ and every slack $\delta > 0$ there is a depth-2 EML network with $N$ chains whose uniform error on $[0,1]$ is at most
> $$\frac{2L}{N} + \delta.$$

The construction is the piecewise-linear interpolant of $f$ at the nodes $j/N$, written explicitly as a ReLU network whose read-out weights are the slope jumps, then emulated by softplus chains.

### What the two rates mean together

Put the two facts in one sentence and the picture snaps into focus.

On the **raw Lipschitz class**, EML achieves the rate $\Theta(1/N)$ — exactly the same as ReLU, no better. On the **smooth** target $x^2$ (and by extension on products and quadratic forms), EML achieves error $\Theta(h^2)$ at *constant* width, while shallow ReLU is stuck at $\Theta(k^{-2})$ in the width.

So the conjectured "$O((wd)^{-2})$" behaviour is real, but it is not a statement about width at all: it is a statement about **smoothness**. A Lipschitz function has no second derivative to exploit and the $1/N$ polyline rate is optimal for everyone. An analytic function has a convergent Taylor series, and an activation that is itself analytic can *reproduce the series* rather than chase it with straight lines — spending precision, not neurons.

That is the real lesson of the parabola. The reason ReLU networks are wide is not that approximation is hard; it is that a polyline is a poor language for a curve. Change the language, and two words suffice.

### Where this goes

Three threads run out of here. First, the weight budget: since the EML construction spends $1/h^2$ of read-out magnitude to buy $h^2$ of accuracy, "weight magnitude" and "width" are interchangeable currencies, and the honest lower bound should be stated in the combined budget rather than in width alone. Under a polynomial weight cap, the polynomial separation may soften into a logarithmic one — a conjecture worth settling, because it is exactly the regime in which real networks are trained.

Second, depth as a degree multiplier: the composition $S_h^{\circ m}$ should approximate $x^{2^m}$ at constant width with a constant growing only like $2^m$, doubling the polynomial degree per layer. The case $m=2$ is settled; the induction hinges on the same stability invariant that made the quartic work.

Third, the practical question. Exponentials and logarithms are more expensive than a comparison against zero, and near-cancelling terms of size $1/h^2$ are a numerical analyst's warning sign. But the trade is a familiar one from finite-difference methods, where the same central-difference stencil, the same $\Theta(h^2)$ rate, and the same round-off floor have been understood for a century. What the results above establish is that the trade is not an implementation detail: it is a genuine, provable boundary between two families of models, visible already in the humblest curve there is.
