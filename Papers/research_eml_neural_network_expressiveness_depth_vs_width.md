# Depth, Width and Weight Magnitude for Exponential–Logarithmic Activations: A Provable Separation from Shallow Rectified Networks

**Author:** Aristotle
**Date:** 2026-08-20

---

## Abstract

We study the approximation power of neural networks whose activation is the *exponential-minus-logarithm* (EML) unit
$$x \mapsto e^{ax+b} - \log(cx+d),$$
and we compare it, quantitatively and in both directions, with one-hidden-layer rectified-linear (ReLU) networks.

Our central object is a single EML layer of width $2$,
$$S_h(x) = \frac{e^{hx} + e^{-hx} - 2}{h^2},$$
obtained by switching off the logarithmic branches and reading out two exponential neurons with weights $1/h^2$ and bias $-2/h^2$. We prove that $S_h$ approximates $x^2$ on $[0,1]$ with uniform error at most $h^2/6$ and at least $h^2/14$, hence exactly $\Theta(h^2)$ at *constant* width; that the same fixed pair of neurons approximates the derivative $2x$ with error at most $h^2/2$; and that the self-composition $S_h \circ S_h$ approximates $x^4$ with error at most $h^2$, so depth composes without degrading the order.

Against this we prove a matching structural lower bound: **every** one-hidden-layer ReLU network with $k$ units, arbitrary real parameters and a free affine skip connection has uniform error at least $1/(32(k+1)^2)$ on $x^2$, and misestimates the slope $2x$ by at least $1/(2(k+1))$ somewhere in $[0,1]$. Combining the two yields a width separation: accuracy $\varepsilon$ costs the EML model width $2$ and costs the shallow ReLU model width $\Omega(\varepsilon^{-1/2})$.

Polarisation upgrades the squaring layer to a width-$4$ *multiplication gate* with error $\Theta(h^2)$ on $[0,1]^2$ (at most $h^2$, at least $2h^2/7$ at the corner), whence every quadratic form in $n$ variables is a single EML layer of width $4n^2$ with the dimension-free error $h^2 \sum_{i,j}|A_{ij}|$; and the ReLU barrier transfers verbatim to the bivariate product by restriction to the diagonal.

Finally we prove the converse containment. Softplus, $\log(1+e^t)$, is literally an exponential neuron followed by a logarithmic one, and satisfies $|M^{-1}\log(1+e^{Mt}) - \mathrm{relu}(t)| \le \log 2/M$. Hence depth-$2$ EML networks dominate shallow ReLU networks at equal width, and inherit the Jackson rate $2L/N + \delta$ for $L$-Lipschitz targets at width $N$. Together the two halves settle the shape of the trade-off: the conjectured $O(w^{-2})$ behaviour is a **smoothness** phenomenon purchased with weight magnitude, not a width phenomenon; on the raw Lipschitz class the rate for both models is $\Theta(1/N)$.

**Keywords:** expressive power, depth–width trade-off, ReLU lower bounds, exponential activation, softplus, polarisation identity, Jackson rate, piecewise linear approximation.

---

## 1. Introduction

### 1.1 The question

Approximation theory for neural networks has two halves. The *upper-bound* half exhibits architectures that reach a prescribed accuracy and counts their resources; the *lower-bound* half proves that a competing architecture cannot do the same with fewer. A separation theorem is a matched pair.

For piecewise-linear activations the lower-bound half has a canonical mechanism: a one-hidden-layer ReLU network is a polyline with at most as many kinks as it has units, and polylines are poor at curvature. This is the source of the classical $\Omega(k^{-2})$ obstruction on smooth targets. For *analytic* activations no such mechanism exists, and one expects — but must prove — that the extra smoothness buys something.

The EML activation $x \mapsto e^{ax+b} - \log(cx+d)$ is analytic on its domain and contains two very different behaviours in one unit: an exponential branch with unbounded growth and all derivatives positive, and a logarithmic branch with slowly-varying, concave behaviour. The question this paper answers is: *what exactly does that smoothness buy, and what does it cost?*

### 1.2 Results and organisation

Section 2 fixes the model. Section 3 constructs the width-2 squaring layer and proves the two-sided rate $\Theta(h^2)$, together with the gradient estimate; it also shows that a naive one-neuron forward-difference construction is genuinely only first order, so the improvement is real and not an artefact of a lossy estimate. Section 4 proves that depth composes, via the quartic $S_h \circ S_h \approx x^4$. Section 5 proves the shallow-ReLU lower bounds from scratch (pigeonhole on breakpoints, exact affinity on the empty box, and a three-point second-difference estimate). Section 6 assembles the separation. Section 7 develops the multiplication gate, quadratic forms in $n$ variables, and the transfer of the ReLU barrier to two inputs. Section 8 proves the converse containment through softplus and the Lipschitz Jackson rate. Section 9 gives algorithms and numerical corroboration; Section 10 discusses interpretation, limitations and future directions.

A one-paragraph summary of the interpretation, stated up front so the reader can keep it in view: **width, depth and weight magnitude are three currencies, and an analytic activation can pay in any of them, while a piecewise-linear one can pay only in width.** The $\Theta(h^2)$ rate at constant width is precisely the exchange of accuracy $h^2$ against read-out weight $1/h^2$.

---

## 2. The model

**Definition 2.1 (EML neuron).** An *EML neuron* is determined by four real parameters $(a,b,c,d)$ and computes
$$\mathcal N_{a,b,c,d}(x) = e^{ax+b} - \log(cx+d),$$
defined wherever $cx+d>0$. Setting $c=0$, $d=1$ switches the logarithmic branch off, since $\log 1 = 0$; setting $a=0$, $b\to-\infty$ is not allowed, but $a = 0$ leaves a harmless constant $e^{b}$ that the read-out bias absorbs.

**Definition 2.2 (EML layer).** An *EML layer of width $k$* consists of neurons $\mathcal N_1, \dots, \mathcal N_k$, read-out weights $\gamma_1,\dots,\gamma_k \in \mathbb R$ and a bias $\beta \in \mathbb R$; it computes
$$L(x) = \beta + \sum_{i=1}^{k} \gamma_i \,\mathcal N_i(x).$$

**Definition 2.3 (Depth).** A *depth-2 EML network* is a composition $L_2 \circ L_1$ of two layers, or more generally (Section 8) a family of parallel chains $\mathcal N^{(2)}_i \circ \mathcal N^{(1)}_i$ with an affine read-out and an affine skip connection:
$$\mathcal D(x) = s_0 + s_1 x + \sum_{i=1}^{k} \gamma_i \, \mathcal N^{(2)}_i\!\left(\mathcal N^{(1)}_i(x)\right).$$
Depth $m$ is obtained by iterating.

**Definition 2.4 (Shallow ReLU network).** With $\mathrm{relu}(t)=\max(t,0)$, a *one-hidden-layer ReLU network with $k$ units* is
$$R_k(x) = c_0 + c_1 x + \sum_{i=1}^{k} a_i\,\mathrm{relu}(w_i x + b_i),$$
with arbitrary real $a_i, w_i, b_i, c_0, c_1$. The affine skip connection $c_0 + c_1x$ is granted for free; all lower bounds below hold with it present, hence a fortiori without it.

Throughout, "uniform error on a set $S$" means $\sup_{x \in S} |f(x) - \text{network}(x)|$, and $h > 0$ denotes a scale parameter.

---

## 3. A width-2 EML layer squares to second order

### 3.1 The construction

**Definition 3.1 (Central-difference squaring layer).** For $h \ne 0$ let $S_h$ be the EML layer of width $2$ with neurons $(a,b,c,d) = (h,0,0,1)$ and $(-h,0,0,1)$, read-out weights $1/h^2$, $1/h^2$, and bias $-2/h^2$.

**Proposition 3.2.** For $h \ne 0$,
$$S_h(x) = \frac{e^{hx} + e^{-hx} - 2}{h^2} = \frac{2\big(\cosh(hx)-1\big)}{h^2}.$$

*Proof.* Both logarithmic branches read $\log(0\cdot x + 1) = 0$; substitute and simplify. $\square$

$S_h$ is exactly the second central difference of the exponential map, and its Maclaurin series is
$$S_h(x) = x^2 + \frac{h^2x^4}{12} + \frac{h^4 x^6}{360} + \cdots,$$
every term beyond the first carrying $h^2$. Note $S_h(0)=0$, so the layer is exact at the origin.

### 3.2 The upper bound

**Lemma 3.3 (Quartic Taylor bound for $2\cosh$).** For $|u| \le 1$,
$$\left| e^{u} + e^{-u} - 2 - u^2 \right| \;\le\; \frac{u^4}{6}.$$

*Proof sketch.* Apply the standard fifth-order Taylor estimate for $e^u$ and, separately, for $e^{-u}$ (both admissible since $|u| \le 1$, $|-u|\le 1$). All odd powers cancel in the sum, the constant and quadratic terms are subtracted off, and the surviving quartic term is $2u^4/4! = u^4/12$; the fifth-order remainders contribute at most $|u|^5$ times an explicit constant, and $|u|^5 \le u^4$ on $|u|\le 1$. Collecting terms gives a total bounded by $u^4/6$. The true asymptotic constant is $1/12$; the factor two is the price of a uniformly valid remainder bound over the whole range $|u|\le1$. $\square$

**Theorem 3.4 (Second-order squaring).** For $h \ne 0$ and any $x$ with $|hx| \le 1$,
$$\left| S_h(x) - x^2 \right| \;\le\; \frac{h^2 x^4}{6}.$$

*Proof.* By Proposition 3.2,
$$S_h(x) - x^2 = \frac{e^{hx}+e^{-hx}-2-(hx)^2}{h^2}.$$
Lemma 3.3 with $u = hx$ bounds the numerator by $(hx)^4/6 = h^4x^4/6$; divide by $h^2$. $\square$

**Corollary 3.5 (Rate on the unit interval).** For $0 < h \le 1$ and $x \in [0,1]$, $|S_h(x)-x^2| \le h^2/6$. In particular, taking $h = 1/n$ for an integer $n\ge1$,
$$\max_{x \in [0,1]} \left| S_{1/n}(x) - x^2 \right| \;\le\; \frac{1}{6n^2}.$$

**Corollary 3.6 (Constant width suffices for any accuracy).** For every $\varepsilon > 0$ there is $h>0$ — namely $h = \min(1,\varepsilon)$ — such that the *width-two* EML layer $S_h$ satisfies $|S_h(x)-x^2| \le \varepsilon$ for all $x \in [0,1]$.

The width does not depend on $\varepsilon$; only the parameters do. This is the statement that will be contrasted with Theorem 5.5.

### 3.3 The lower bound: the rate is exactly $\Theta(h^2)$

An upper bound alone leaves open the possibility that the estimate is lossy and the true rate is better (or that the comparison with ReLU is unfair). It is not.

**Lemma 3.7 (Lower Taylor estimate).** For $0 < h \le 1$,
$$e^{h} + e^{-h} \;\ge\; 2 + h^2 + \frac{h^4}{14}.$$

*Proof sketch.* For $e^h$ use the fact that a partial sum of the exponential series underestimates $e^h$ for $h \ge 0$, retaining terms through $h^4$. For $e^{-h}$ use a two-sided fifth-order remainder estimate, valid because $|-h|\le1$, and absorb the resulting $h^5$ and $h^6$ terms into $h^4$ using $h \le 1$. The surviving quartic coefficient is $2/4! = 1/12$ minus the absorbed remainder, which is still at least $1/14$. $\square$

**Theorem 3.8 (Sharpness).** For $0 < h \le 1$,
$$\left| S_h(1) - 1 \right| \;\ge\; \frac{h^2}{14}.$$

*Proof.* $S_h(1) - 1 = \big(e^h + e^{-h} - 2 - h^2\big)/h^2 \ge (h^4/14)/h^2 = h^2/14$ by Lemma 3.7. $\square$

**Theorem 3.9 (Two-sided rate).** For $0 < h \le 1$, the uniform error of the width-2 EML layer on $[0,1]$ lies between $h^2/14$ and $h^2/6$. Hence it is $\Theta(h^2)$, and the exponent $2$ is exact.

Numerically the constant is $1/12 \approx 0.0833$ (Section 9), comfortably inside the proved bracket $[1/14, 1/6] = [0.0714, 0.1667]$.

### 3.4 The naive construction is genuinely slower

One might obtain a squaring network from the *forward* difference instead, using a single exponential neuron:
$$F_h(x) = \frac{2}{h^2}\left(e^{hx} - 1 - hx\right) = x^2 + \frac{h x^3}{3} + \cdots.$$
This is a width-1 EML layer (with the linear term supplied by an affine read-out) and it is only first order. That statement, too, we prove rather than assume.

**Theorem 3.10 (First-order barrier for the forward construction).** For every $h > 0$,
$$\frac{2}{h^2}\left(e^{h} - 1 - h\right) - 1 \;\ge\; \frac{h}{3}.$$

*Proof.* The partial sum $1 + h + h^2/2 + h^3/6 \le e^h$ for $h \ge 0$. Subtracting and multiplying by $2/h^2$ gives exactly $h/3$ plus a nonnegative remainder. $\square$

So at $x = 1$ the forward network's error is at least $h/3$, and the central-difference layer's improvement from $\Theta(h)$ to $\Theta(h^2)$ is a genuine gain. Numerically the forward error at $x=1$ tends to $h/3$ from above, so the constant in Theorem 3.10 is *sharp*.

### 3.5 Gradients

**Lemma 3.11 (Cubic Taylor bound for $2\sinh$).** For $|u| \le 1$, $\left|e^u - e^{-u} - 2u\right| \le |u|^3/2$.

**Theorem 3.12 (Second-order gradients at width two).** For $0 < h \le 1$ and $x \in [0,1]$,
$$\left| \frac{e^{hx}-e^{-hx}}{h} - 2x \right| \;\le\; \frac{h^2}{2}.$$

*Proof.* The left-hand quantity is $S_h'(x) - (x^2)'$; write it as $\big(e^{hx}-e^{-hx}-2hx\big)/h$ and apply Lemma 3.11 with $u = hx$, using $|hx|^3 \le h^3$ on the stated range. $\square$

The point is that this is the derivative of *the same* two-neuron network, with no retraining, no extra units, and the same second-order rate. Section 5 shows the corresponding ReLU statement is first order in the width and cannot be improved.

---

## 4. Depth composes: the quartic

**Theorem 4.1 (Depth-2 quartic approximation).** For $0 < h \le 1/2$ and $x \in [0,1]$,
$$\left| S_h\big(S_h(x)\big) - x^4 \right| \;\le\; h^2 .$$

*Proof.* Put $y = S_h(x)$ and decompose
$$S_h(S_h(x)) - x^4 = \big(S_h(y) - y^2\big) + \big(y^2 - x^4\big).$$

*Stability of the intermediate value.* By Corollary 3.5, $|y - x^2| \le h^2/6 \le 1/24$, and $0 \le x^2 \le 1$, so $|y| \le 25/24$. Consequently $|hy| \le \tfrac12 \cdot \tfrac{25}{24} < 1$, which is exactly the hypothesis needed to apply Theorem 3.4 at the point $y$. This is the only place where $h \le 1/2$ is used, and it is the mechanism by which depth composes safely: the output of layer one must stay inside the domain of validity of layer two's estimate.

*First term.* Theorem 3.4 at $y$ gives $|S_h(y)-y^2| \le h^2 y^4/6 \le h^2 \cdot 2/6 = h^2/3$, using $y^4 \le (25/24)^4 \le 2$.

*Second term.* $y^2 - x^4 = (y-x^2)(y+x^2)$, and $|y+x^2| \le 25/24 + 1$, so
$$|y^2 - x^4| \le \frac{h^2}{6}\cdot\frac{49}{24} \le \frac{h^2}{2}.$$

Adding, $|S_h(S_h(x))-x^4| \le h^2/3 + h^2/2 \le h^2$. $\square$

Two layers, width $2$ each, four neurons total, and a degree-four target at second order. The empirical constant is $\approx 1/4$ against the proved $1$ (Section 9). The natural conjecture — depth $m$ gives $x^{2^m}$ with a constant growing like $2^m$ — is stated in Section 10; the proof above already contains the invariant needed for the induction.

---

## 5. The shallow ReLU barrier

We now prove the matching lower bound, from first principles, for the model of Definition 2.4.

### 5.1 Pigeonhole on breakpoints

**Lemma 5.1 (Breakpoint-free interval).** Let $w, b \in \mathbb R^k$. Among the $k+1$ intervals
$$I_j = \left(\frac{j}{k+1}, \frac{j+1}{k+1}\right), \qquad j = 0, 1, \dots, k,$$
at least one contains no breakpoint, i.e. there is $j$ such that for all $x \in I_j$ and all $i$ with $w_i \ne 0$ one has $w_i x + b_i \ne 0$.

*Proof.* A unit with $w_i \ne 0$ has exactly one breakpoint $-b_i/w_i$; units with $w_i = 0$ have none (they are constants, $\mathrm{relu}(b_i)$). At most $k$ points must be placed in $k+1$ disjoint open intervals, so one interval receives none. $\square$

### 5.2 Exact affinity on the empty box

**Lemma 5.2 (Single unit).** If $w x + b \ne 0$ for all $x$ in an interval $I$, then $x \mapsto \mathrm{relu}(wx+b)$ agrees on $I$ with a fixed affine function: either $wx+b$ throughout (if the expression is positive somewhere, hence everywhere by continuity and the intermediate value theorem) or $0$ throughout. If $w = 0$ the unit is the constant $\mathrm{relu}(b)$.

**Lemma 5.3 (Whole network).** Under the conclusion of Lemma 5.1, there exist $\alpha, \beta \in \mathbb R$ with $R_k(x) = \alpha x + \beta$ for all $x \in I_j$.

*Proof.* Sum the affine representations of Lemma 5.2 over $i$, weighted by $a_i$, and add the skip connection. $\square$

**Proposition 5.4 (Structural core).** For every $k$ and every parameter choice there are $0 \le p < q \le 1$ with $q - p = 1/(k+1)$ and reals $\alpha,\beta$ such that $R_k(x) = \alpha x + \beta$ for all $x \in (p,q)$.

### 5.3 A line cannot follow a parabola

**Lemma 5.5 (Three-point second difference).** Let $p<q$, $L = q-p$, and suppose $|x^2 - (\alpha x + \beta)| \le \varepsilon$ for all $x \in (p,q)$. Then
$$\varepsilon \;\ge\; \frac{L^2}{32}.$$

*Proof.* Evaluate the hypothesis at $x_1 = p + L/4$, $x_2 = p+L/2$, $x_3 = p+3L/4$. The second difference operator $g \mapsto g(x_1) - 2g(x_2) + g(x_3)$ annihilates affine functions and sends $x^2$ to $2(L/4)^2 = L^2/8$. Hence
$$\frac{L^2}{8} = \big(x_1^2 - (\alpha x_1+\beta)\big) - 2\big(x_2^2-(\alpha x_2+\beta)\big) + \big(x_3^2-(\alpha x_3+\beta)\big) \le 4\varepsilon,$$
giving $\varepsilon \ge L^2/32$. $\square$

The optimal constant for this problem is $1/8$, attained by comparing at the endpoints of the interval; the constant $1/32$ is the price of sampling at interior quarter points, which keeps the argument valid on the *open* interval produced by the pigeonhole step. Since only the exponent matters for the separation, we keep the simpler route.

### 5.4 The lower bounds

**Theorem 5.6 (Shallow ReLU cannot square).** For every $k \ge 0$, every $a,w,b \in \mathbb R^k$ and every $c_0,c_1 \in \mathbb R$,
$$\max_{x \in [0,1]} \left| x^2 - R_k(x) \right| \;\ge\; \frac{1}{32\,(k+1)^2}.$$

*Proof.* Combine Proposition 5.4 (an interval of length $1/(k+1)$ on which $R_k$ is affine, contained in $[0,1]$) with Lemma 5.5. $\square$

The case $k = 0$ is included and reads $\varepsilon \ge 1/32$: a purely affine model cannot beat $1/32$ on the parabola.

**Theorem 5.7 (Shallow ReLU cannot match the slope).** For every $k$ and every parameter choice there is an interval $(p,q) \subseteq [0,1]$ of length $1/(k+1)$ on which $R_k$ is affine with some slope $\alpha$, and a point $x \in (p,q)$ with
$$|\alpha - 2x| \;\ge\; \frac{1}{2(k+1)}.$$

*Proof.* On $(p,q)$ the true slope $2x$ ranges over an interval of length $2/(k+1)$ while the network's slope is the constant $\alpha$. Whichever side of the midpoint $\alpha$ falls on, one of the two quarter points $p + L/4$, $p + 3L/4$ (with $L = 1/(k+1)$) is at distance at least $L/2 = 1/(2(k+1))$ from $\alpha$ in the sense required. $\square$

Contrast with Theorem 3.12: EML's gradient error is $O(h^2)$ at width $2$; shallow ReLU's is $\Omega(1/k)$, i.e. only first order in the width.

---

## 6. The separation theorem

**Theorem 6.1 (Width separation on $x^2$).** For every $\varepsilon > 0$:

1. *(EML upper bound.)* There is $h > 0$ such that the EML layer $S_h$, of width $2$, satisfies $|S_h(x)-x^2| \le \varepsilon$ for all $x \in [0,1]$.
2. *(ReLU lower bound.)* Every one-hidden-layer ReLU network $R_k$ with $|x^2 - R_k(x)| \le \varepsilon$ on $[0,1]$ satisfies
$$(k+1)^2 \;\ge\; \frac{1}{32\varepsilon}.$$

*Proof.* (1) is Corollary 3.6; (2) is Theorem 5.6 rearranged. $\square$

**Corollary 6.2 (Explicit exchange rate).** To match the accuracy $1/(6n^2)$ of the width-2 EML layer with $h = 1/n$, a shallow ReLU network must satisfy
$$3n^2 \le 16(k+1)^2, \qquad\text{i.e.}\qquad k+1 \ge \frac{\sqrt3}{4}\,n \approx 0.433\,n.$$
The EML width stays at $2$.

**Remark 6.3 (What is being traded).** The read-out weights of $S_h$ are $\pm 1/h^2$, and the two exponentials nearly cancel: at accuracy $\varepsilon = h^2/6$ the coefficients have magnitude $\sim 1/(6\varepsilon)$. So the separation is *width* against *weight magnitude*, and it is honest to state it as such. It is nevertheless a separation between the two model classes as usually defined (arbitrary real parameters), and Section 10 records the precise conjecture for the bounded-weight regime.

---

## 7. Polarisation: products, quadratic forms, and two inputs

### 7.1 The multiplication gate

**Definition 7.1.** The *EML multiplication gate* is
$$P_h(x,y) = \frac{S_h(x+y) - S_h(x-y)}{4} = \frac{e^{h(x+y)}+e^{-h(x+y)}-e^{h(x-y)}-e^{-h(x-y)}}{4h^2}.$$
It is a layer of width $4$ (four exponential neurons, evaluated at the two pre-activations $x+y$ and $x-y$).

The construction is the polarisation identity $xy = \tfrac14\big((x+y)^2-(x-y)^2\big)$ applied to an approximate squarer.

**Theorem 7.2 (Accuracy of the gate).** If $|h(x+y)| \le 1$ and $|h(x-y)| \le 1$ then
$$\left| P_h(x,y) - xy \right| \;\le\; \frac{h^2\big((x+y)^4 + (x-y)^4\big)}{24}.$$
In particular, for $0 < h \le 1/2$ and $x,y \in [0,1]$,
$$\left| P_h(x,y) - xy \right| \;\le\; h^2.$$

*Proof.* Apply Theorem 3.4 at the two points $x \pm y$ and combine by the triangle inequality, dividing by $4$. On $[0,1]^2$ one has $(x+y)^4 \le 16$ and $(x-y)^4 \le 1$, giving $17h^2/24 \le h^2$; the hypotheses $|h(x\pm y)|\le 1$ hold because $h \le 1/2$ and $|x \pm y| \le 2$. $\square$

**Theorem 7.3 (Sharpness of the gate).** For $0 < h \le 1/2$,
$$\left| P_h(1,1) - 1 \right| \;\ge\; \frac{2h^2}{7}.$$
Hence the gate's uniform error on $[0,1]^2$ is $\Theta(h^2)$, bracketed between $2h^2/7$ and $h^2$.

*Proof.* $S_h(0) = 0$, so $P_h(1,1) = S_h(2)/4$, and
$$P_h(1,1)-1 = \frac{e^{2h}+e^{-2h}-2-(2h)^2}{4h^2}.$$
Apply Lemma 3.7 with $h$ replaced by $2h \in (0,1]$: the numerator is at least $(2h)^4/14 = 16h^4/14$, so the quotient is at least $4h^2/14 = 2h^2/7$. $\square$

The empirical constant is $1/3$ (Section 9), consistent with the proved bracket $[2/7, 17/24] = [0.286, 0.708]$.

### 7.2 Quadratic forms in many variables

**Theorem 7.4 (Every quadratic form is a single EML layer).** Let $A \in \mathbb R^{n\times n}$, let $q(x) = \sum_{i,j} A_{ij}x_ix_j$, and let $0 < h \le 1/2$. Then for all $x \in [0,1]^n$,
$$\left| \sum_{i,j} A_{ij}\,P_h(x_i,x_j) \;-\; q(x) \right| \;\le\; h^2 \sum_{i,j}\left|A_{ij}\right|.$$
The left-hand network is a single EML layer of width at most $4n^2$.

*Proof.* Subtract termwise, apply Theorem 7.2 to each product and the triangle inequality:
$$\left|\sum_{i,j}A_{ij}\big(P_h(x_i,x_j)-x_ix_j\big)\right| \le \sum_{i,j}|A_{ij}|\cdot h^2. \qquad\square$$

The essential point is that the constant $h^2$ is **dimension-free**: the ambient dimension $n$ enters only through the coefficient mass $\|A\|_{1,1} = \sum_{i,j}|A_{ij}|$, never through an exponential factor. There is no curse of dimensionality on the class of quadratic forms with bounded coefficient mass. (Width $4n^2$ is of course the natural count of monomials; it can be halved by symmetry and reduced further for low-rank $A$, since $P_h$ applied to the pre-activations of a rank-$r$ factorisation costs $O(r)$ gates.)

### 7.3 The ReLU barrier in two inputs

**Definition 7.5.** A one-hidden-layer ReLU network in two inputs with $k$ units is
$$R^{(2)}_k(x,y) = c_0 + c_1x + c_2y + \sum_{i=1}^{k}a_i\,\mathrm{relu}(w_ix+v_iy+b_i).$$

**Lemma 7.6 (Diagonal restriction).** $R^{(2)}_k(x,x)$ is a one-hidden-layer *univariate* ReLU network with $k$ units, namely with hidden weights $w_i + v_i$, biases $b_i$, read-out $a_i$ and skip connection $c_0 + (c_1+c_2)x$.

**Theorem 7.7 (Products are as hard as squares for shallow ReLU).** If $|xy - R^{(2)}_k(x,y)| \le \varepsilon$ for all $(x,y) \in [0,1]^2$, then
$$\varepsilon \;\ge\; \frac{1}{32(k+1)^2}.$$

*Proof.* Restrict to $y=x$. The target becomes $x^2$ and the network becomes a univariate $k$-unit shallow ReLU network by Lemma 7.6; apply Theorem 5.6. $\square$

The restriction is *lossless* — a bivariate unit becomes a genuine univariate unit, not a degenerate one — so the transferred bound costs nothing and cannot be evaded by an adversarial choice of $v_i$.

**Theorem 7.8 (Product separation).** For every $\varepsilon>0$ there is $h>0$ such that the width-$4$ EML gate satisfies $|P_h(x,y)-xy|\le\varepsilon$ on $[0,1]^2$; whereas every bivariate shallow ReLU network achieving the same accuracy has $(k+1)^2 \ge 1/(32\varepsilon)$.

*Proof.* Take $h=\min(1/2,\varepsilon)$ in Theorem 7.2 (then $h^2 \le h \le \varepsilon$), and Theorem 7.7 for the converse. $\square$

---

## 8. The converse: depth-2 EML contains shallow ReLU

A separation is only informative if the favoured model is not *worse* elsewhere. It is not, and the reason is structural rather than analytic.

### 8.1 Softplus is an EML composite

**Definition 8.1.** $\mathrm{softplus}(t) = \log(1+e^t)$.

Observe that $\mathrm{softplus}$ is exactly an exponential neuron $t \mapsto e^{t}$ followed by a logarithmic neuron $u \mapsto -\log(1 + u)$ (up to sign, absorbed by the read-out) — i.e. a depth-2 EML chain with the exponential branch of the second neuron switched off.

**Lemma 8.2.** For all $t$: $\mathrm{relu}(t) \le \mathrm{softplus}(t) \le \mathrm{relu}(t) + \log 2$.

*Proof.* For $t \le 0$: $\mathrm{relu}(t)=0 \le \log(1+e^t)$ since $1+e^t \ge 1$; and $\log(1+e^t) \le \log 2$ since $e^t \le 1$. For $t>0$: $\log(1+e^t) = t + \log(1+e^{-t}) \ge t = \mathrm{relu}(t)$, and $\log(1+e^{-t}) \le \log 2$. $\square$

**Theorem 8.3 (Scaled softplus approximates ReLU).** For $M>0$ and all $t$,
$$\left| \frac{\log(1+e^{Mt})}{M} - \mathrm{relu}(t) \right| \;\le\; \frac{\log 2}{M},$$
with equality at $t=0$.

*Proof.* Apply Lemma 8.2 at $Mt$ and use the positive homogeneity $\mathrm{relu}(Mt) = M\,\mathrm{relu}(t)$; divide by $M$. $\square$

### 8.2 Emulation and domination

**Theorem 8.4 (Emulation error).** For $M>0$ there is an explicit depth-2 EML network $\mathcal E_M$ with $k$ parallel chains — the $i$-th chain being $x \mapsto e^{M(w_ix+b_i)}$ followed by $u \mapsto 1 - \log(1+u)$, read out with weight $-a_i/M$, plus the skip connection $c_0+c_1x$ — such that for all real $x$,
$$\left| \mathcal E_M(x) - R_k(x) \right| \;\le\; \Big(\sum_{i=1}^k |a_i|\Big)\frac{\log 2}{M}.$$

*Proof.* The $i$-th chain computes $-\big(\log(1+e^{M(w_ix+b_i)}) - 1\big)/M$ up to the constant absorbed by the bias, i.e. $a_i \cdot \mathrm{softplus}(M(w_ix+b_i))/M$ after read-out. Subtract $R_k$ termwise and apply Theorem 8.3 to each term with the triangle inequality. $\square$

**Theorem 8.5 (Domination).** Let $f$ be any function, $S$ any set, and suppose a $k$-unit shallow ReLU network approximates $f$ within $\varepsilon$ on $S$. Then for every $\delta>0$ there is a depth-2 EML network with $k$ chains approximating $f$ within $\varepsilon + \delta$ on $S$.

*Proof.* Choose $M \ge \max\{1, (\sum_i|a_i|)\log 2/\delta\}$ in Theorem 8.4 and apply the triangle inequality. $\square$

### 8.3 The Lipschitz Jackson rate

**Definition 8.6 (Interpolant as a ReLU network).** For $f:[0,1]\to\mathbb R$ and $N \ge 1$, let $\sigma_j = N\big(f((j+1)/N)-f(j/N)\big)$ be the slope of the linear interpolant on the $j$-th piece and $\lambda_j = \sigma_j - \sigma_{j-1}$ (with $\sigma_{-1}=0$) the slope jump at the node $j/N$. Then
$$\Pi_N f(x) = f(0) + \sum_{j=0}^{N-1} \lambda_j\, \mathrm{relu}\!\left(x - \frac{j}{N}\right)$$
is a width-$N$ shallow ReLU network, and on each piece $[j/N,(j+1)/N]$ it equals the linear interpolant of $f$ at the endpoints (telescoping the slope jumps).

**Theorem 8.7 (Interpolation error).** If $f$ is $L$-Lipschitz on $[0,1]$ then $\max_{x\in[0,1]}|f(x)-\Pi_Nf(x)| \le 2L/N$.

*Proof sketch.* Fix $x$ in the $j$-th piece. The interpolant is a convex combination of $f(j/N)$ and $f((j+1)/N)$, each within $L/N$ of $f(x)$ by the Lipschitz property (the piece has length $1/N$); hence the interpolant is within $L/N$ of $f(x)$, and the crude bound $2L/N$ holds with room to spare, uniformly including the endpoints. $\square$

**Theorem 8.8 (Jackson rate for depth-2 EML).** Let $f$ be $L$-Lipschitz on $[0,1]$, let $N \ge 1$ and $\delta > 0$. There is a depth-2 EML network with $N$ chains whose uniform error on $[0,1]$ is at most
$$\frac{2L}{N} + \delta .$$

*Proof.* Combine Theorem 8.7 with the domination Theorem 8.5. $\square$

Since the $\Theta(1/N)$ rate is optimal for the Lipschitz class for *any* model with $N$ parameters of this type, Theorem 8.8 says depth-2 EML is exactly as good as ReLU there — no better, no worse.

---

## 9. Algorithms and numerical corroboration

Two elementary algorithms suffice to realise all constructions.

**Algorithm A (Central-difference squaring layer).** Given a target accuracy $\varepsilon$, set $h = \min(1,\sqrt{6\varepsilon})$ and return the width-2 layer with parameters $(h,0,0,1)$, $(-h,0,0,1)$, read-out $(1/h^2, 1/h^2)$, bias $-2/h^2$. Evaluation costs two exponentials. The guaranteed uniform error on $[0,1]$ is $h^2/6 \le \varepsilon$.

**Algorithm B (Quadratic-form layer).** Given $A \in \mathbb R^{n\times n}$ and $\varepsilon$, set $h = \min(1/2, \sqrt{\varepsilon/\|A\|_{1,1}})$ and return $\sum_{i,j}A_{ij}P_h(x_i,x_j)$, a layer of width $\le 4n^2$; evaluation costs $O(n^2)$ exponentials, or $O(n^2)$ arithmetic operations plus $O(n^2)$ transcendental calls. Guaranteed error $h^2\|A\|_{1,1} \le \varepsilon$.

**Algorithm C (Softplus emulator).** Given a shallow ReLU network $(a,w,b,c_0,c_1)$ and slack $\delta$, set $M = \max\{1, (\sum_i|a_i|)\log 2/\delta\}$ and return the depth-2 EML chains of Theorem 8.4. Uniform emulation error $\le \delta$.

Direct numerical evaluation on a $1001$-point grid of $[0,1]$ (and a $51\times51$ grid of $[0,1]^2$ for the gate) gives the following observed constants, where each column reports $\max$ error divided by the predicted rate:

| $h$ | $\max\lvert S_h - x^2\rvert / h^2$ | $\max\lvert F_h - x^2\rvert / h$ | $\max\lvert S_h\!\circ\! S_h - x^4\rvert/h^2$ | $\max\lvert S_h' - 2x\rvert/h^2$ | $\max\lvert P_h - xy\rvert/h^2$ |
|---|---|---|---|---|---|
| $0.5$    | $0.0840$ | $0.3795$ | $0.2612$ | $0.3375$ | $0.3446$ |
| $0.25$   | $0.0835$ | $0.3553$ | $0.2527$ | $0.3344$ | $0.3361$ |
| $0.125$  | $0.0834$ | $0.3440$ | $0.2507$ | $0.3336$ | $0.3340$ |
| $0.0625$ | $0.0833$ | $0.3386$ | — | — | $0.3335$ |

The limits are $1/12$, $1/3$, $1/4$, $1/3$ and $1/3$ respectively — every one strictly inside the proved constants $1/6$, $1/3$ (matched exactly), $1$, $1/2$ and $17/24$. The lower bounds are likewise corroborated: $|S_h(1)-1|/h^2 \to 1/12 > 1/14$, and $|P_h(1,1)-1|/h^2 \to 1/3 > 2/7$.

The scaled softplus behaves as predicted: at $M=10$, $\big|M^{-1}\log(1+e^{Mt}) - \mathrm{relu}(t)\big|$ equals $4.54\times10^{-6}$ at $t=\pm1$ and $0.0693 = \log 2/10$ at $t=0$, the maximum.

---

## 10. Discussion

### 10.1 What the trade-off actually is

The mission conjecture was a rate of the form $O((wd)^{-2/n})$ for the EML class on Lipschitz targets, matching the ReLU rate with smoother gradients. The results above refine this into two crisply separated statements.

**On the Lipschitz class the rate is $\Theta(1/N)$ for both models.** Theorem 8.8 gives the upper bound for depth-2 EML at width $N$, via the containment of ReLU. Nothing better is available, because a Lipschitz function carries no second-order information to exploit.

**On smooth (analytic) targets the correct statement is not about width at all.** Theorem 3.9 gives a $\Theta(h^2)$ rate at the *fixed* width $2$, and Theorem 5.6 shows this is unattainable for shallow ReLU at any fixed width. The resource actually being spent is weight magnitude: read-out coefficients $1/h^2$ buy accuracy $h^2$. Width, depth and precision are three currencies; an analytic activation converts freely between them, while a piecewise-linear one is confined to width (and depth, which for ReLU multiplies the number of linear pieces).

The gradient results sharpen the same contrast: $O(h^2)$ at width $2$ versus $\Omega(1/k)$ at width $k$. If the derivative of the learned function is the object of interest — physics-informed models, sensitivity analysis, control, calibration of surrogate models — this is the more consequential half of the separation.

### 10.2 Limitations

Three should be stated plainly.

*Weight magnitude.* As noted, the EML upper bounds are purchased with coefficients of size $\Theta(1/\varepsilon)$ and near-cancelling exponentials. In floating-point arithmetic this places a round-off floor at roughly $\sqrt{u}$ in the target accuracy ($u$ the unit roundoff) — exactly the classical trade-off of central-difference differentiation, where the optimal step balances truncation $O(h^2)$ against cancellation $O(u/h^2)$.

*Class of targets.* The width-2 phenomenon is specific to targets whose Taylor series the activation can reproduce cheaply — squares, products, quadratic forms, and (via depth) powers of the form $x^{2^m}$. It is not a general-purpose escape from approximation-theoretic lower bounds.

*Model of ReLU.* The lower bounds are for *one hidden layer*. Deep ReLU networks achieve $O(4^{-d})$ on $x^2$ with $d$ layers by the classical sawtooth construction, so the separation established here is between EML and *shallow* ReLU, not against arbitrary-depth ReLU. What Section 8 adds is that depth-2 EML also contains shallow ReLU, so the comparison at fixed small depth is one-sided in EML's favour.

### 10.3 Future directions

**C1. Bounded-weight separation.** Fix $W \ge 1$ and restrict all EML weights (inner and read-out) to $[-W,W]$. Conjecture: approximating $x^2$ on $[0,1]$ to accuracy $\varepsilon$ then requires width $k \ge c\,\varepsilon^{-1/2}/\log W$, and this is attained. The key insight is that the width-2 construction spends $1/h^2$ of read-out magnitude to buy $h^2$ of accuracy, so weight magnitude and width are interchangeable currencies and the lower bound should be stated in the total budget $k\log W$. Both halves of the ledger are already in place: the upper bound exhibits the exchange rate explicitly, and the pigeonhole argument of Section 5 is a template for a lower bound that counts *pieces*, which under a weight budget an EML layer also has.

**C2. Depth is worth an exponent for analytic targets.** Conjecture: for every $m \ge 1$ the $m$-fold composition $S_h^{\circ m}$ approximates $x^{2^m}$ on $[0,1]$ with uniform error $\le C_m h^2$ and $C_m \le 2^m$, whereas any depth-1 EML layer of width $k$ needs $k \ge c\,2^m/(1+|\log h|)$ for the same accuracy — depth doubling the polynomial degree per layer at constant width. Theorem 4.1 is the case $m = 2$ with $C_2 = 1$, and its proof used only that the first layer's output stays in a fixed compact set, an invariant that iterates: the estimate $|y| \le 25/24 \Rightarrow |hy| \le 1$ is exactly the induction hypothesis needed.

**C3. Beyond quadratic forms.** Polarisation gives products; products give monomials by iteration, and monomials give polynomials. The natural target is a Bernstein- or Chebyshev-type theorem: which polynomial classes admit EML networks of width polynomial in the degree with dimension-free error constants, and where does the coefficient mass $\|A\|_{1,1}$ generalise to a Barron-type norm?

**C4. Numerical stabilisation.** Since the obstruction to small $h$ is cancellation, the natural fix is a stably evaluated variant — using $\mathrm{expm1}$, or a Chebyshev-economised combination of several $h$ scales (Richardson extrapolation across scales would give $\Theta(h^4)$ at width $4$). Quantifying the achievable accuracy under a fixed floating-point format would turn the theoretical separation into a practical one.

**C5. Training dynamics.** All results here are about expressivity, i.e. the existence of good parameters. Whether gradient descent *finds* the central-difference configuration — a delicate near-cancellation of two large exponentials — is a separate and genuinely open question, and the honest counterweight to the optimism of Theorem 6.1.

---

## 11. Conclusion

The parabola is the simplest curved target there is, and it already separates two families of networks. A single EML layer of two neurons reaches any accuracy on $x^2$, with an error that is exactly $\Theta(h^2)$ in its scale parameter and whose derivative is simultaneously accurate to $O(h^2)$; every one-hidden-layer ReLU network with $k$ units errs by at least $1/(32(k+1)^2)$ and misestimates the slope by $\Omega(1/k)$. Polarisation extends the phenomenon to products, hence to all quadratic forms with a dimension-free constant, and the ReLU barrier transfers to the bivariate product without loss. In the other direction, softplus — an exponential followed by a logarithm — embeds every shallow ReLU network into a depth-2 EML network of equal width, so the smooth model is never worse and inherits the optimal $\Theta(1/N)$ Lipschitz rate.

The conclusion is not that one activation dominates another in practice; it is that the phrase "depth–width trade-off" is incomplete. For analytic activations the true statement involves a third currency, weight magnitude, and the honest question for future work is what the exchange rates become when all three are budgeted at once.
