# Polarisation Cancellation in Exponential Product Gates: the Sharp Constant, the Corner Theorem, and an Affine-Readout Barrier

**Author:** Aristotle
**Date:** 2026-08-24

---

## Abstract

Networks whose nonlinearity is the exponential $u \mapsto e^u$ synthesise multiplication by *polarisation*: from a soft squaring unit
$$S_h(u) = \frac{e^{hu} + e^{-hu} - 2}{h^{2}} = u^{2} + \frac{h^{2}u^{4}}{12} + \frac{h^{4}u^{6}}{360} + \cdots$$
one forms the width-four product gate $P_h(x,y) = \tfrac14\bigl(S_h(x+y) - S_h(x-y)\bigr)$, which approximates $xy$ to $O(h^{2})$. We determine the error of this gate exactly.

Writing $\gamma(t) = e^{t} + e^{-t} - 2 - t^{2}$ for the remainder of $2\cosh$ after its quadratic Taylor polynomial, we prove the exact identity
$$P_h(x,y) - xy = \frac{\gamma\bigl(h(x+y)\bigr) - \gamma\bigl(h|x-y|\bigr)}{4h^{2}},$$
which exhibits the error as the *increment* of a single even, monotone function. From it we derive: (i) a two-sided polarised bound with the correct shape $(x+y)^4 - (x-y)^4$ rather than the sum $(x+y)^4 + (x-y)^4$ produced by branchwise estimation; (ii) the sharp leading term $h^{2}xy(x^{2}+y^{2})/6$ with explicit remainder $h^4/21$; and (iii) a *closed form for the supremum*, valid for every $h>0$ with no Taylor expansion,
$$\sup_{[0,1]^{2}}\bigl|P_h(x,y) - xy\bigr| = \frac{e^{2h} + e^{-2h} - 2 - 4h^{2}}{4h^{2}} = \frac{h^{2}}{3} + \frac{2h^{4}}{45} + \cdots,$$
the supremum being attained at the corner $(1,1)$.

We then show the $\Theta(h^{2})$ rate is intrinsic: no scalar gain, and more strikingly no *affine read-out* $\lambda P_h(x,y) + \mu S_h(x) + \nu S_h(y) + \kappa$ reusing the gate's own squaring units, achieves $o(h^{2})$ — the obstruction being exhibited by a mixed second difference that annihilates $\mu,\nu,\kappa$ exactly.

Finally we abstract the mechanism: for *every* generator $g(t) = t^{2} + \gamma_g(t)$ whose remainder is even, vanishes at $0$, and is non-decreasing on $[0,\infty)$, the maximal error of the polarisation gate over $[0,1]^2$ equals $\gamma_g(2h)/(4h^{2})$ and is attained at $(1,1)$; when $\gamma_g(t) = ct^4 + O(t^6)$ this is $4ch^{2} + O(h^{4})$. The exponential constant $1/3$ is simply $4c$ with $c = 1/12$. A non-monotone counterexample, $g(t) = t^{2} - t^{4}$, shows the monotonicity hypothesis is load-bearing. Applications: quadratic forms on $[0,1]^n$ with error $(h^2/3 + h^4/21)\lVert A\rVert_1$, and a chained two-gate bound $\tfrac34 h^{2}$ demonstrating additive rather than compounding error accumulation.

**Keywords:** polarisation identity, exponential activation, product gate, sharp approximation constant, monotone remainder, mixed second difference, approximation barrier.

---

## 1. Introduction

### 1.1 Multiplication is not a layer operation

A feed-forward layer computes $x \mapsto \sigma(Wx + b)$: an affine map followed by a pointwise univariate nonlinearity. Such a map cannot compute the bilinear form $(x,y) \mapsto xy$ in one step, whatever $\sigma$ may be, because $\sigma$ never sees two coordinates at once. Yet products dominate the functional vocabulary of physics, statistics and modern architectures — energies, forces, moments, covariances, attention scores, polynomial features.

The classical remedy is the **polarisation identity**
$$xy = \frac{(x+y)^{2} - (x-y)^{2}}{4}, \tag{1.1}$$
which reduces multiplication to squaring, a univariate operation. If $\sigma(u) = u^{2}$ the reduction is exact and multiplication costs one layer of width $2$. For other activations one first synthesises an approximate square, then polarises.

### 1.2 Exponential networks and the soft square

Consider networks whose nonlinearity is $u \mapsto e^{u}$. Fix a scale $h > 0$ and define the **soft squaring unit**
$$S_h(u) \;=\; \frac{e^{hu} + e^{-hu} - 2}{h^{2}}. \tag{1.2}$$
Two exponential units and a linear read-out. Because
$$e^{hu} + e^{-hu} = 2 + h^2u^2 + \frac{h^4u^4}{12} + \frac{h^6u^6}{360} + \cdots,$$
we have $S_h(u) = u^{2} + h^{2}u^{4}/12 + h^{4}u^{6}/360 + \cdots$, so $S_h \to (\cdot)^2$ locally uniformly as $h \to 0$. Substituting into $(1.1)$ gives the **product gate**
$$\boxed{\;P_h(x,y) \;=\; \frac{S_h(x+y) - S_h(x-y)}{4}\;} \tag{1.3}$$
of width $4$ (four exponential units) and depth $1$.

### 1.3 The question, and why the obvious answer is wrong

How large is $P_h(x,y) - xy$ on the unit square $[0,1]^{2}$?

The branchwise estimate is immediate: $|S_h(u) - u^{2}| \lesssim h^{2}u^{4}/12$ on the relevant range, so by the triangle inequality
$$\bigl|P_h(x,y) - xy\bigr| \;\lesssim\; \frac{h^{2}\bigl[(x+y)^{4} + (x-y)^{4}\bigr]}{24}. \tag{1.4}$$
This bound is true but structurally wrong. Setting $y = 0$: since $S_h$ is even, $P_h(x,0) = \tfrac14\bigl(S_h(x) - S_h(-x)\bigr) = 0$ **exactly**, while $(1.4)$ predicts an error $h^{2}x^{4}/12 > 0$. The estimate cannot see that the two polarisation branches make correlated errors that cancel.

The conjecture this paper settles is that the correct shape is the **difference** of fourth powers,
$$\bigl|P_h(x,y) - xy\bigr| \;\le\; \frac{h^{2}\bigl[(x+y)^{4} - (x-y)^{4}\bigr]}{24}, \tag{1.5}$$
and consequently that
$$\sup_{[0,1]^{2}}\bigl|P_h(x,y) - xy\bigr| \;=\; \frac{h^{2}}{3} + O(h^{4}), \tag{1.6}$$
attained at the corner $(1,1)$.

### 1.4 Results

We prove $(1.5)$ and $(1.6)$, and go substantially past them.

1. **Exact error identity** (Theorem 3.1). $P_h(x,y) - xy = \bigl[\gamma(h(x+y)) - \gamma(h|x-y|)\bigr]/(4h^{2})$, where $\gamma(t) = e^t + e^{-t} - 2 - t^2$.
2. **Two-sided polarised bound** (Theorem 4.5). For $0 < h \le \tfrac12$ and $(x,y) \in [0,1]^2$,
 $$\frac{h^{2}\bigl[(x+y)^{4}-(x-y)^{4}\bigr]}{48} \;\le\; P_h(x,y) - xy \;\le\; \frac{h^{2}\bigl[(x+y)^{4}-(x-y)^{4}\bigr]}{24}.$$
 In particular the error is non-negative and vanishes identically on the axes.
3. **Sharp local constant** (Theorem 4.8). $\bigl|P_h(x,y) - xy - h^{2}xy(x^{2}+y^{2})/6\bigr| \le h^{4}/21$. Since $(x+y)^4-(x-y)^4 = 8xy(x^2+y^2)$, the sharp constant is $/48$, not $/24$: the conjectured constant is right in shape but a factor $2$ conservative.
4. **The corner theorem and closed form** (Theorems 5.2, 5.3). For *every* $h>0$, $\sup_{[0,1]^2}|P_h - xy| = \gamma(2h)/(4h^2) = \bigl(e^{2h}+e^{-2h}-2-4h^2\bigr)/(4h^2)$, attained at $(1,1)$. The $O(h^{4})$ of $(1.6)$ is removable.
5. **No scalar debiasing** (Theorem 6.2). For all $h \in (0,\tfrac12]$ and all $\lambda \in \mathbb{R}$, $\max\{|\lambda P_h(1,1)-1|, |\lambda P_h(1,\tfrac12)-\tfrac12|\} \ge h^{2}/100$.
6. **No affine debiasing** (Theorem 6.6). For all $h\in(0,\tfrac12]$ and all $\lambda,\mu,\nu,\kappa \in \mathbb{R}$, the read-out $\lambda P_h(x,y)+\mu S_h(x)+\nu S_h(y)+\kappa$ errs by at least $h^{2}/210$ somewhere on $[0,1]^{2}$; consequently no affine read-out is $O(h^{4})$ (Corollary 6.7).
7. **Universality** (Theorems 7.3–7.5). For every even monotone generator remainder the maximum is $\gamma_g(2h)/(4h^2)$ at $(1,1)$; pointwise smaller remainders give uniformly better gates; a quartic leading coefficient $c$ yields $4ch^2 + O(h^4)$. The hypothesis is necessary (Proposition 7.9).
8. **Applications** (Theorems 8.1, 8.5). Quadratic forms with error $(h^2/3 + h^4/21)\lVert A\rVert_1$; two chained gates with error $\le \tfrac34 h^2$, versus the additive prediction $\tfrac23 h^2$.

### 1.5 The methodological point

The lossy step in $(1.4)$ is $|E_+ - E_-| \le |E_+| + |E_-|$, which is lossless exactly when $E_- = 0$ and therefore *cannot detect cancellation*. We show (Remark 4.6) that any pair of term-by-term Taylor bounds is insufficient in principle: on the diagonal $x=y$ the two branch remainders coincide and the true error is $0$, so an exact estimate is required there, which no non-matching upper/lower pair achieves.

The replacement is a **monotonicity certificate**. Cancellation between polarisation branches is a statement about how the remainder *changes*, not about how *large* it is. This is the organising idea of the paper, and it is what makes the corner theorem free of Taylor analysis altogether.

---

## 2. Notation and standing conventions

Throughout, $h > 0$ is the scale parameter and $I = [0,1]$.

**Definition 2.1 (Soft squaring unit).** $S_h(u) = \bigl(e^{hu} + e^{-hu} - 2\bigr)/h^{2}$ for $h \ne 0$.

**Definition 2.2 (Product gate).** $P_h(x,y) = \tfrac14\bigl(S_h(x+y) - S_h(x-y)\bigr)$.

**Definition 2.3 (Cosh remainder).** $\gamma(t) = e^{t} + e^{-t} - 2 - t^{2}$.

Elementary properties, all immediate: $\gamma$ is even, $\gamma(-t) = \gamma(t)$; $\gamma(|t|) = \gamma(t)$; $\gamma(0) = 0$; and the power series
$$\gamma(t) = \sum_{k\ge2}\frac{2t^{2k}}{(2k)!} = \frac{t^{4}}{12} + \frac{t^{6}}{360} + \frac{t^{8}}{20160} + \cdots \tag{2.1}$$
has non-negative coefficients. Note also $S_h(u) = \bigl(u^{2}h^{2} + \gamma(hu)\bigr)/h^{2} = u^{2} + \gamma(hu)/h^{2}$.

**Definition 2.4 (Error set).** $\mathcal{E}(h) = \bigl\{\,|P_h(x,y) - xy| : (x,y) \in I \times I\,\bigr\} \subset \mathbb{R}$.

---

## 3. The exact error identity

**Theorem 3.1 (Exact error identity).** *For $h \ne 0$ and all $x,y \in \mathbb{R}$,*
$$P_h(x,y) - xy \;=\; \frac{\gamma\bigl(h(x+y)\bigr) - \gamma\bigl(h(x-y)\bigr)}{4h^{2}}.$$

*Proof.* By Definition 2.3, $S_h(u) = u^{2} + \gamma(hu)/h^{2}$. Hence
$$P_h(x,y) = \frac{(x+y)^{2} - (x-y)^{2}}{4} + \frac{\gamma(h(x+y)) - \gamma(h(x-y))}{4h^{2}},$$
and the first term is $xy$ by the polarisation identity $(1.1)$. $\square$

The identity is *exact*: no approximation has been made. The entire error of the gate is the increment of the single even function $\gamma$ between the two polarisation arguments.

**Corollary 3.2 (Normalised form).** *For $h > 0$,*
$$P_h(x,y) - xy \;=\; \frac{\gamma\bigl(h(x+y)\bigr) - \gamma\bigl(h|x-y|\bigr)}{4h^{2}}.$$

*Proof.* $\gamma$ is even, so $\gamma(h(x-y)) = \gamma(|h(x-y)|) = \gamma(h|x-y|)$ using $h>0$. $\square$

For $x,y \ge 0$ the arguments satisfy $0 \le h|x-y| \le h(x+y)$, a normalisation we use constantly.

**Corollary 3.3 (Exactness on the axes).** *$P_h(x,0) = P_h(0,y) = 0$ for all $x,y$ and all $h \ne 0$.*

*Proof.* Put $y = 0$ in Theorem 3.1: both arguments of $\gamma$ equal $hx$ up to sign, and $\gamma$ is even. $\square$

**Corollary 3.4 (One-sidedness).** *For $h>0$ and $x,y \ge 0$, $P_h(x,y) - xy \ge 0$.*

*Proof.* $\gamma$ is non-decreasing on $[0,\infty)$ (Lemma 4.2 below) and $0 \le h|x-y| \le h(x+y)$, so the numerator in Corollary 3.2 is non-negative. $\square$

The gate systematically **overshoots** on the positive quadrant. This asymmetry is invisible to any absolute-value bound and is the mechanism behind the accumulation results of §8.

---

## 4. Cancellation via monotonicity

### 4.1 Monotonicity of the remainder

**Lemma 4.1 (Cubic bracket for $2\sinh$).** *For $t \in [0,1]$,*
$$\frac{t^{3}}{3} \;\le\; e^{t} - e^{-t} - 2t \;\le\; \frac{t^{3}}{2}.$$

*Proof sketch.* Both sides follow from truncated exponential series with explicit remainder control. For the lower bound, $e^t \ge \sum_{k=0}^{6}t^k/k!$ for $t \ge 0$, while $e^{-t}$ is bounded above by its degree-$6$ Taylor polynomial plus a remainder of size $\le t^7/7!\cdot 2$ on $[0,1]$; combining, $e^t - e^{-t} - 2t \ge t^3/3 + 2t^5/120 - (\text{remainder}) \ge t^3/3$ since $t \le 1$. The upper bound is the same computation with the truncation at degree $4$ and the inequality reversed. $\square$

**Lemma 4.2 ($\gamma$ is monotone).** *$\gamma' (t) = e^{t} - e^{-t} - 2t \ge 0$ for $t \ge 0$; hence $\gamma$ is non-decreasing on $[0,\infty)$ and $\gamma \ge 0$ everywhere.*

*Proof.* $\gamma'(t) = e^t - e^{-t} - 2t = 2(\sinh t - t) \ge 0$ for $t \ge 0$. Monotonicity on $[0,\infty)$ follows; non-negativity from $\gamma(0)=0$, monotonicity, and evenness. $\square$

Observe the striking economy: Lemma 4.2 needs no radius restriction and no Taylor bracket. It is $\sinh t \ge t$.

**Lemma 4.3 (Slack monotonicity).** *Both slack functions*
$$U(t) = \frac{t^{4}}{6} - \gamma(t), \qquad L(t) = \gamma(t) - \frac{t^{4}}{12}$$
*are non-decreasing on $[0,1]$.*

*Proof.* $U'(t) = \tfrac{2}{3}t^{3} - (e^t - e^{-t} - 2t) \ge \tfrac23 t^3 - \tfrac12 t^3 > 0$ by the upper half of Lemma 4.1; $L'(t) = (e^t-e^{-t}-2t) - \tfrac13 t^{3} \ge 0$ by the lower half. $\square$

This is the crux. Monotonicity of the slacks converts *pointwise* Taylor information about $\gamma$ into *incremental* information, which is what a polarised difference actually requires.

**Lemma 4.4 (Cancellation estimates).** *For $0 \le b \le a \le 1$,*
$$\frac{a^{4} - b^{4}}{12} \;\le\; \gamma(a) - \gamma(b) \;\le\; \frac{a^{4} - b^{4}}{6}.$$

*Proof.* $U(b) \le U(a)$ rearranges to $\gamma(a) - \gamma(b) \le (a^4-b^4)/6$; $L(b) \le L(a)$ rearranges to $\gamma(a)-\gamma(b) \ge (a^4-b^4)/12$. $\square$

The right-hand sides involve $a^{4} - b^{4}$: the difference of fourth powers, exactly the shape the axis test of §1.3 demanded. Both inequalities are equalities when $a = b$, so no spurious error appears on the diagonal.

### 4.2 The polarised bound

**Theorem 4.5 (Two-sided polarised bound).** *For $0 < h \le \tfrac12$ and $x,y \in [0,1]$,*
$$\frac{h^{2}\bigl[(x+y)^{4}-(x-y)^{4}\bigr]}{48} \;\le\; P_h(x,y) - xy \;\le\; \frac{h^{2}\bigl[(x+y)^{4}-(x-y)^{4}\bigr]}{24}.$$
*In particular $|P_h(x,y)-xy| \le h^{2}\bigl[(x+y)^{4}-(x-y)^{4}\bigr]/24$, which vanishes identically on the axes.*

*Proof.* Set $a = h(x+y)$ and $b = h|x-y|$. Then $0 \le b \le a$ because $|x-y| \le x+y$ for $x,y \ge 0$, and $a \le 2h \le 1$. Lemma 4.4 applies. Moreover $a^{4} = h^{4}(x+y)^{4}$ and $b^{4} = h^{4}(x-y)^{4}$. Substituting into Corollary 3.2 and dividing by $4h^{2}$ turns $(a^4-b^4)/12$ into $h^{2}\bigl[(x+y)^4-(x-y)^4\bigr]/48$ and $(a^4-b^4)/6$ into the corresponding $/24$. Non-negativity of the error (Corollary 3.4) converts the upper bound into an absolute-value bound. $\square$

**Remark 4.6 (Why branchwise estimation must fail).** Suppose one bounds the two branches separately: $\gamma(a) \le \alpha a^{4}$, $\gamma(b) \ge \beta b^{4}$ with constants $\alpha > \beta$ (necessarily, since $\gamma(t)/t^4$ is not constant). Then the resulting bound $\gamma(a) - \gamma(b) \le \alpha a^{4} - \beta b^{4}$ evaluated at $a = b$ gives $(\alpha - \beta)a^{4} > 0$, while the truth is $0$. Since $a = b$ corresponds exactly to the diagonal $x = y$ — the *largest* region of the square in a measure-theoretic sense — no separate-branch scheme can be sharp there. Cancellation is not detectable by size estimates; it requires the monotone comparison of Lemma 4.3.

### 4.3 The sharp local constant

**Lemma 4.7 (Quartic approximation of $\gamma$).** *For $|t| \le 1$, $\bigl|\gamma(t) - t^{4}/12\bigr| \le t^{6}/350$; more precisely $\bigl|\gamma(t) - t^{4}/12 - t^{6}/360\bigr| \le t^{8}/17920$, and one-sidedly $\gamma(t) \le t^4/12 + t^6/352$.*

*Proof sketch.* Apply the standard exponential remainder bound at order $8$ to $e^{t}$ and $e^{-t}$ and add. The odd terms cancel; the even terms reproduce $t^2 + t^4/12 + t^6/360$ after subtracting $2$, and the tail is controlled by $t^{8}/17920$ on $|t| \le 1$. The cruder statements follow using $t^{8}\le t^{6}$ on $|t|\le1$. $\square$

**Theorem 4.8 (Sharp asymptotics).** *For $0 < h \le \tfrac12$ and $x,y \in [0,1]$,*
$$\left|\,P_h(x,y) - xy - \frac{h^{2}\,xy\,(x^{2}+y^{2})}{6}\,\right| \;\le\; \frac{h^{4}}{21}.$$

*Proof.* With $a = h(x+y)$, $b = h|x-y|$ as before ($|a|,|b| \le 1$), Lemma 4.7 gives $\bigl|\gamma(a) - a^{4}/12\bigr| \le a^{6}/350$ and likewise for $b$. Hence
$$\left|\bigl(\gamma(a)-\gamma(b)\bigr) - \frac{a^{4}-b^{4}}{12}\right| \le \frac{a^{6}+b^{6}}{350} = \frac{h^{6}\bigl[(x+y)^{6} + (x-y)^{6}\bigr]}{350} \le \frac{65\,h^{6}}{350},$$
using $(x+y)^{6}\le 64$ and $(x-y)^{6}\le 1$. Dividing by $4h^{2}$ and noting
$$\frac{a^{4}-b^{4}}{48h^{2}} = \frac{h^{2}\bigl[(x+y)^{4}-(x-y)^{4}\bigr]}{48} = \frac{h^{2}\,xy(x^{2}+y^{2})}{6}$$
(because $(x+y)^{4}-(x-y)^{4} = 8xy(x^{2}+y^{2})$) yields the bound $65h^{4}/1400 \le h^{4}/21$. $\square$

So within the sandwich of Theorem 4.5 it is the **lower** constant that is attained: the true leading term is $h^{2}\bigl[(x+y)^4-(x-y)^4\bigr]/48$. The conjectured $/24$ is correct in *shape* — which was the substantive claim, since it is the shape that encodes cancellation — but a factor $2$ conservative as a constant.

**Corollary 4.9 (Uniform bound).** *For $0<h\le\tfrac12$ and $x,y \in [0,1]$, $|P_h(x,y)-xy| \le h^{2}/3 + h^{4}/21$.*

*Proof.* On $[0,1]^{2}$ one has $xy(x^{2}+y^{2}) \le 2$, so the leading term is at most $h^{2}/3$; add the remainder of Theorem 4.8. $\square$

---

## 5. The corner theorem: the supremum in closed form

Corollary 4.9 combined with the value at $(1,1)$ already gives $(1.6)$: since Theorem 4.5 at $x=y=1$ yields $P_h(1,1) - 1 \ge h^2\cdot 16/48 = h^{2}/3$, we obtain
$$\Bigl|\ \sup\mathcal{E}(h) - \frac{h^{2}}{3}\ \Bigr| \;\le\; \frac{h^{4}}{21} \qquad (0 < h \le \tfrac12), \tag{5.1}$$
with the corner value within $h^{4}/21$ of the supremum. But far more is true, and the proof is shorter.

**Theorem 5.1 (Corner dominance).** *For every $h > 0$ and every $(x,y) \in [0,1]^{2}$,*
$$\bigl|P_h(x,y) - xy\bigr| \;\le\; \frac{\gamma(2h)}{4h^{2}} \;=\; P_h(1,1) - 1.$$

*Proof.* By Corollary 3.4 the error is non-negative, so its absolute value equals $\bigl[\gamma(h(x+y)) - \gamma(h|x-y|)\bigr]/(4h^{2})$ by Corollary 3.2. Now $\gamma$ is non-decreasing on $[0,\infty)$ (Lemma 4.2) and $0 \le h(x+y) \le 2h$, so $\gamma(h(x+y)) \le \gamma(2h)$; and $\gamma(h|x-y|) \ge 0$. Hence the numerator is $\le \gamma(2h)$. The corner value is computed by putting $x=y=1$: the arguments are $2h$ and $0$, and $\gamma(0)=0$. $\square$

**Theorem 5.2 (The maximum is attained at $(1,1)$).** *For every $h>0$, $\gamma(2h)/(4h^{2})$ is the greatest element of $\mathcal{E}(h)$.*

*Proof.* It is a member, by the corner computation; it is an upper bound, by Theorem 5.1. $\square$

**Theorem 5.3 (Closed form).** *For every $h>0$,*
$$\sup_{(x,y)\in[0,1]^{2}}\bigl|P_h(x,y) - xy\bigr| \;=\; \frac{e^{2h} + e^{-2h} - 2 - 4h^{2}}{4h^{2}}.$$

*Proof.* Theorem 5.2 and $\gamma(2h) = e^{2h}+e^{-2h}-2-4h^2$. $\square$

**Corollary 5.4 (Expansion).** *Using $(2.1)$ with $t = 2h$,*
$$\sup_{[0,1]^{2}}\bigl|P_h - xy\bigr| \;=\; \frac{1}{4h^{2}}\sum_{k\ge2}\frac{2(2h)^{2k}}{(2k)!} \;=\; \frac{h^{2}}{3} + \frac{2h^{4}}{45} + \frac{h^{6}}{315} + \cdots$$
*In particular $\bigl|\sup\mathcal{E}(h) - h^{2}/3\bigr| \le h^{4}/21$ for $0<h\le\tfrac12$, consistent with $(5.1)$, and the numerically observed remainder coefficient is $2/45 \approx 0.0444$ against the certified $1/21 \approx 0.0476$.*

Three comments.

* The $O(h^{4})$ in the original conjecture is **removable**: the supremum has a closed form for all $h > 0$, not merely an asymptotic.
* The proof of Theorem 5.1 uses *no Taylor expansion at all*. Only $\gamma \ge 0$, $\gamma$ non-decreasing on $[0,\infty)$, and $\gamma(0) = 0$ — that is, only $\sinh t \ge t$.
* The maximiser is unique in the relevant sense: the numerator strictly increases in $x+y$ and strictly decreases in $|x-y|$ away from degeneracies, so $(1,1)$ is the unique point of $[0,1]^2$ maximising $x+y$ subject to $|x-y|=0$.

---

## 6. Barriers: the $\Theta(h^{2})$ rate is intrinsic

The sharp constant invites an engineering question: can it be *calibrated away* by a smarter read-out, leaving the architecture untouched? We show it cannot, at two levels of ambition.

### 6.1 No scalar debiasing

By Theorem 4.8, the leading error is $h^{2}xy(x^{2}+y^{2})/6$. This is **not proportional to $xy$**: the factor $x^{2}+y^{2}$ varies over the square. Therefore no output rescaling can absorb it.

**Lemma 6.1 (Two probes).** *For $0<h\le\tfrac12$: $\bigl|P_h(1,1) - 1 - h^{2}/3\bigr| \le h^{4}/21$ and $\bigl|P_h(1,\tfrac12) - \tfrac12 - 5h^{2}/48\bigr| \le h^{4}/21$.*

*Proof.* Theorem 4.8 at $(1,1)$ and at $(1,\tfrac12)$; the leading coefficients are $1\cdot1\cdot2/6 = 1/3$ and $1\cdot\tfrac12\cdot\tfrac54/6 = 5/48$. $\square$

The *relative* leading errors are $h^{2}/3$ at the first probe and $(5h^{2}/48)/(1/2) = 5h^{2}/24$ at the second. They differ.

**Theorem 6.2 (No scalar debiasing).** *For every $h \in (0,\tfrac12]$ and every $\lambda \in \mathbb{R}$ (possibly depending on $h$),*
$$\max\Bigl\{\bigl|\lambda P_h(1,1) - 1\bigr|,\ \bigl|\lambda P_h(1,\tfrac12) - \tfrac12\bigr|\Bigr\} \;\ge\; \frac{h^{2}}{100}.$$

*Proof sketch.* Suppose both quantities were $< h^{2}/100$. Write $A = P_h(1,1) = 1 + h^{2}/3 + \varepsilon_1$ and $B = P_h(1,\tfrac12) = \tfrac12 + 5h^{2}/48 + \varepsilon_2$ with $|\varepsilon_i| \le h^{4}/21$. Then $\lambda A \approx 1$ and $\lambda B \approx \tfrac12$ force $\lambda \approx 1 - h^{2}/3$ and $\lambda \approx 1 - 5h^{2}/24$ respectively; these differ by $h^{2}/8 + O(h^4)$, which for $h \le \tfrac12$ exceeds the slack $2\cdot h^{2}/100$ allowed by the assumed bounds. Contradiction. $\square$

### 6.2 No affine debiasing

A more ambitious repair reuses the two soft-squaring units already present in the gate. Consider the **affine read-out**
$$N_{\lambda\mu\nu\kappa}(x,y) \;=\; \lambda\,P_h(x,y) \;+\; \mu\,S_h(x) \;+\; \nu\,S_h(y) \;+\; \kappa, \tag{6.1}$$
with error $E(x,y) = N_{\lambda\mu\nu\kappa}(x,y) - xy$. This costs nothing new: $S_h(x)$ and $S_h(y)$ are computable from the same four exponential units, and the extra coefficients are read-out weights. Can they achieve $o(h^{2})$?

**Definition 6.3 (Mixed second difference).** For $F : \mathbb{R}^2 \to \mathbb{R}$ and points $a,d$ (first coordinate), $b,c$ (second),
$$D[F] \;=\; F(a,b) - F(a,c) - F(d,b) + F(d,c).$$

**Lemma 6.4 (Annihilation).** *$D$ annihilates every function of the form $F(x,y) = \varphi(x) + \psi(y) + \kappa$.*

*Proof.* $\varphi(a)+\psi(b) - \varphi(a) - \psi(c) - \varphi(d) - \psi(b) + \varphi(d) + \psi(c) = 0$; constants cancel by the alternating signs. $\square$

This is *exact* — no estimates, no small parameters. Applying $D$ to $E$ therefore eliminates $\mu$, $\nu$ and $\kappa$ completely, leaving only $\lambda$ and the genuinely bilinear content.

Take the two rectangles anchored at the origin:

* $R_1$ with corners $(1,1),(1,0),(0,1),(0,0)$;
* $R_2$ with corners $(\tfrac12,\tfrac12),(\tfrac12,0),(0,\tfrac12),(0,0)$.

On both, three of the four vertices lie on an axis, where by Corollary 3.3 the gate is exactly $0$ and $S_h(0) = 0$. Consequently:

**Lemma 6.5 (The two scalar equations).** *For $h \ne 0$,*
$$D_{R_1}[E] = \lambda P_h(1,1) - 1, \qquad D_{R_2}[E] = \lambda P_h(\tfrac12,\tfrac12) - \tfrac14 .$$

*Proof.* Expand $E$ at the four vertices of each rectangle; use $P_h(x,0) = P_h(0,y) = 0$, $S_h(0)=0$, and Lemma 6.4 to cancel the $\mu,\nu,\kappa$ contributions. The surviving bilinear terms $-xy$ contribute $-1$ and $-\tfrac14$ respectively. $\square$

**Theorem 6.6 (No affine debiasing).** *For every $h \in (0,\tfrac12]$ and all $\lambda,\mu,\nu,\kappa \in \mathbb{R}$ there exists $(x,y) \in [0,1]^{2}$ with*
$$\bigl|N_{\lambda\mu\nu\kappa}(x,y) - xy\bigr| \;\ge\; \frac{h^{2}}{210}.$$

*Proof sketch.* Suppose not; then $|E| < h^{2}/210$ at each of the seven probe points $(1,1),(1,0),(0,1),(0,0),(\tfrac12,\tfrac12),(\tfrac12,0),(0,\tfrac12)$. By Lemma 6.5 and the triangle inequality (each mixed difference is a signed sum of four such values),
$$\bigl|\lambda A - 1\bigr| < \frac{4h^{2}}{210}, \qquad \bigl|\lambda B - \tfrac14\bigr| < \frac{4h^{2}}{210},$$
where $A = P_h(1,1)$ and $B = P_h(\tfrac12,\tfrac12)$. By Theorem 4.8, $A = 1 + h^{2}/3 + O(h^{4}/21)$ and $B = \tfrac14 + h^{2}/48 + O(h^{4}/21)$, so
$$A - 4B \;=\; \frac{h^{2}}{3} - \frac{h^{2}}{12} + O\!\left(\frac{h^{4}}{4}\right) \;=\; \frac{h^{2}}{4} + O(h^{4}).$$
Subtracting four times the second display from the first gives $|\lambda(A - 4B)| < 20h^{2}/210 = 2h^{2}/21$, whence $|\lambda| \cdot h^{2}/4 \lesssim 2h^{2}/21$ and so $|\lambda| < \tfrac12$ for $h \le \tfrac12$. But then $|\lambda A - 1| \ge 1 - |\lambda| \cdot |A| > 1 - \tfrac12\cdot\tfrac32 = \tfrac14$, contradicting $|\lambda A - 1| < 4h^{2}/210 \le 1/210$. $\square$

**Corollary 6.7 (Not fourth order).** *For every constant $C$ there is an $h \in (0,\tfrac12]$ such that for all $\lambda,\mu,\nu,\kappa$ the error of $N_{\lambda\mu\nu\kappa}$ exceeds $C h^{4}$ somewhere on $[0,1]^{2}$.*

*Proof.* Choose $n \in \mathbb{N}$ with $n > 210C$ and set $h = 1/(n+2)$. Then $210Ch^{2} < 1$, i.e. $Ch^{4} < h^{2}/210$, and Theorem 6.6 applies. $\square$

**Interpretation.** Define the *correction rank* of the gate as the minimum number of additional nonlinear units needed to bring the error to $o(h^{2})$. Theorem 6.6 says this rank is at least $1$: reusing the gate's existing units, in any affine combination, is provably insufficient. The barrier's mechanism is instructive — it is not a size estimate but a *rank* statement. Two probes with *different ratios of quartic error to bilinear value* cannot be reconciled by a rank-one (scalar) correction, and separable corrections are invisible to the mixed difference.

---

## 7. Universality: it was never about the exponential

Theorem 5.1 used three properties of $\gamma$ and nothing else. We isolate them.

**Definition 7.1 (Even generator).** An *even generator* is a pair $g(t) = t^{2} + \gamma_g(t)$ where the **remainder** $\gamma_g : \mathbb{R}\to\mathbb{R}$ satisfies (i) $\gamma_g(-t) = \gamma_g(t)$; (ii) $\gamma_g(0) = 0$; (iii) $\gamma_g$ is non-decreasing on $[0,\infty)$.

Any power series $\sum_{k\ge2}c_{2k}t^{2k}$ with $c_{2k}\ge0$ is such a remainder; so is $|t|^{p}$ for $p > 0$, or $\cosh$-type and $\log$-type remainders with non-negative increments.

**Definition 7.2 (Polarisation gate of a generator).**
$$G_h(x,y) \;=\; \frac{g\bigl(h(x+y)\bigr) - g\bigl(h(x-y)\bigr)}{4h^{2}}.$$

Exactly as in Theorem 3.1, $G_h(x,y) - xy = \bigl[\gamma_g(h(x+y)) - \gamma_g(h|x-y|)\bigr]/(4h^{2})$ for $h>0$; from (ii)–(iii), $\gamma_g \ge 0$, hence the error is non-negative on the positive quadrant.

**Theorem 7.3 (Universal corner theorem).** *For every even generator $g$ and every $h>0$, the maximum of $|G_h(x,y) - xy|$ over $[0,1]^{2}$ is attained at $(1,1)$ and equals*
$$\frac{\gamma_g(2h)}{4h^{2}} \;=\; \frac{g(2h) - 4h^{2}}{4h^{2}}.$$

*Proof.* Verbatim the proof of Theorems 5.1–5.3, replacing $\gamma$ by $\gamma_g$. $\square$

**Theorem 7.4 (Design criterion / monotone comparison).** *If $\gamma_{g_1}(t) \le \gamma_{g_2}(t)$ for all $t$, then for all $h > 0$,*
$$\max_{[0,1]^{2}}\bigl|G^{(1)}_h - xy\bigr| \;\le\; \max_{[0,1]^{2}}\bigl|G^{(2)}_h - xy\bigr|.$$

*Proof.* Both maxima are $\gamma_{g_i}(2h)/(4h^{2})$ by Theorem 7.3, and $4h^2>0$. $\square$

There is therefore **no trade-off**: minimising the remainder pointwise minimises the worst-case error, uniformly in $h$. Activation design for polarisation gates is a one-dimensional optimisation over remainders.

**Theorem 7.5 (Universal quartic constant).** *Suppose $|\gamma_g(t) - c\,t^{4}| \le C t^{6}$ for $|t| \le 1$. Then for $0 < h \le \tfrac12$,*
$$\Bigl|\ \max_{[0,1]^{2}}\bigl|G_h - xy\bigr| \;-\; 4c\,h^{2}\ \Bigr| \;\le\; 16C\,h^{4}.$$

*Proof.* By Theorem 7.3 the maximum is $\gamma_g(2h)/(4h^2)$. Then
$$\frac{\gamma_g(2h)}{4h^{2}} - 4ch^{2} = \frac{\gamma_g(2h) - c(2h)^{4}}{4h^{2}},$$
whose absolute value is at most $C(2h)^{6}/(4h^{2}) = 16Ch^{4}$. $\square$

**Corollary 7.6 (The exponential instance).** *For the exponential generator $g(t) = e^{t}+e^{-t}-2$, so $\gamma_g = \gamma$, Lemma 4.7 gives $c = 1/12$, $C = 1/352$, whence*
$$\Bigl|\max_{[0,1]^2}|P_h - xy| - \tfrac{h^{2}}{3}\Bigr| \le \frac{h^{4}}{22}.$$
*The constant $1/3$ is exactly $4c$.*

**Proposition 7.7 (Pure quartic generators: no remainder).** *For $g(t) = t^{2} + c\,t^{4}$ with $c \ge 0$, the maximum is $4ch^{2}$ **exactly**, for all $h>0$.*

*Proof.* $\gamma_g(2h)/(4h^2) = c(2h)^4/(4h^2) = 4ch^2$. $\square$

Thus the $O(h^{4})$ in the exponential case originates **entirely** in the sextic and higher Taylor coefficients of $2\cosh$, not in the polarisation mechanism.

**Proposition 7.8 (Degeneration to exactness).** *At $c=0$, $g(t)=t^{2}$, the gate satisfies $G_h(x,y) = xy$ identically. Moreover the exponential gate is never better than the pure quartic gate with the same leading coefficient: for $0<h\le\tfrac12$, $4\cdot\tfrac1{12}h^{2} \le \max_{[0,1]^2}|P_h - xy|$.*

*Proof.* The first is the polarisation identity. The second follows from Lemma 4.4 with $b=0$: $\gamma(2h) \ge (2h)^4/12$. $\square$

**Proposition 7.9 (Monotonicity is load-bearing).** *For the non-monotone generator $g(t) = t^{2} - t^{4}$, the closed form of Theorem 7.3 evaluates to $\bigl(g(2h) - 4h^{2}\bigr)/(4h^{2}) = -4h^{2} < 0$, which is not the maximum of an absolute value. The true maximum of $|G_h(x,y) - xy|$ over $[0,1]^{2}$ is $+4h^{2}$, attained at $(1,1)$.*

*Proof.* Here $G_h(x,y) - xy = -h^{2}\bigl[(x+y)^4 - (x-y)^4\bigr]/4 = -2h^{2}xy(x^{2}+y^{2})$ exactly, so the error is non-positive and its absolute value is $2h^{2}xy(x^{2}+y^{2}) \le 4h^{2}$ on $[0,1]^{2}$, with equality at $(1,1)$. The formula's prediction $-4h^{2}$ is negative while every element of the error set is non-negative, so it is not even a member. $\square$

This gate *undershoots*, reversing the one-sidedness of Corollary 3.4 — an instructive reminder that the sign of the systematic bias is an intrinsic property of the activation's remainder, and that a designer who wants unbiased-in-expectation products must break monotonicity deliberately.

---

## 8. Applications

### 8.1 Quadratic forms

**Theorem 8.1 (Sharp quadratic-form error).** *Let $A \in \mathbb{R}^{n\times n}$ and $x \in [0,1]^{n}$. For $0<h\le\tfrac12$,*
$$\left|\ \sum_{i,j} A_{ij}\,P_h(x_i,x_j) \;-\; \sum_{i,j}A_{ij}\,x_ix_j\ \right| \;\le\; \left(\frac{h^{2}}{3} + \frac{h^{4}}{21}\right)\sum_{i,j}\bigl|A_{ij}\bigr| .$$

*Proof.* Write the difference as $\sum_{i,j}A_{ij}\bigl(P_h(x_i,x_j) - x_ix_j\bigr)$ and apply the triangle inequality with Corollary 4.9 termwise. $\square$

A quadratic form on $[0,1]^n$ is thus computed by a single layer of $4n^{2}$ exponential units to accuracy $(h^{2}/3 + h^{4}/21)\lVert A\rVert_1$, a **threefold improvement** on the branchwise constant $h^{2}\lVert A\rVert_1$, uniform in $n$. Practically: since $h$ controls the dynamic range $e^{\pm 2h}$ of the exponentials and hence the numerical conditioning of the layer, a factor of $3$ in the error constant buys a factor $\sqrt{3}$ in the admissible $h$.

### 8.2 Product trees: errors add, they do not compound

Chaining gates raises a genuine difficulty: the output of a gate leaves the unit square, since $P_h(1,1) = 1 + h^{2}/3 + O(h^{4}) > 1$. A box version of the corner theorem handles this.

**Theorem 8.2 (Box bound).** *Let $M>0$ with $2Mh \le 1$, and $0 \le x,y \le M$. Then*
$$\bigl|P_h(x,y) - xy\bigr| \;\le\; \frac{M^{4}h^{2}}{3} + \frac{M^{6}h^{4}}{22}.$$

*Proof.* As in Theorem 5.1, monotonicity of $\gamma$ bounds the error by $\gamma(2Mh)/(4h^{2})$. Then apply the one-sided sextic bound $\gamma(u) \le u^{4}/12 + u^{6}/352$ of Lemma 4.7 at $u = 2Mh$ (legitimate since $|2Mh|\le1$) and simplify: $(2Mh)^{4}/12 + (2Mh)^{6}/352 = \bigl(M^{4}h^{2}/3 + M^{6}h^{4}/22\bigr)\cdot 4h^{2}$. $\square$

The $M^{4}$ scaling is what makes chaining tractable.

**Corollary 8.3 (Unit square).** *For $0<h\le\tfrac12$ and $x,y \in[0,1]$: $|P_h(x,y)-xy| \le h^{2}/3 + h^{4}/22$.*

**Lemma 8.4 (Output range).** *For $0<h\le\tfrac14$ and $x,y\in[0,1]$: $0 \le P_h(x,y) \le \tfrac{33}{32}$.*

*Proof.* Non-negativity from Corollary 3.4 and $xy \ge 0$; the upper bound from $xy \le 1$ plus Corollary 8.3 with $h^{2}\le\tfrac1{16}$, $h^{4}\le\tfrac1{256}$. $\square$

The overshoot is a mere $3\%$.

**Theorem 8.5 (Two chained gates).** *For $0<h\le\tfrac14$ and $x,y,z\in[0,1]$,*
$$\bigl|P_h\bigl(P_h(x,y),\,z\bigr) - xyz\bigr| \;\le\; \frac{3h^{2}}{4} \;=\; \frac94\cdot\frac{h^{2}}{3}.$$

*Proof.* Let $Q = P_h(x,y) \in [0,\tfrac{33}{32}]$ by Lemma 8.4. Split
$$P_h(Q,z) - xyz = \bigl[P_h(Q,z) - Qz\bigr] + \bigl[(Q - xy)z\bigr].$$
The first bracket is bounded by Theorem 8.2 with $M = \tfrac{33}{32}$ (and $2Mh \le 33/64 \le 1$): at most $(33/32)^{4}h^{2}/3 + (33/32)^{6}h^{4}/22$. The second is bounded by $z\cdot(h^{2}/3 + h^{4}/22) \le h^{2}/3 + h^{4}/22$ using Corollary 8.3. Adding, and using $h^{4}\le h^{2}/16$ for $h\le\tfrac14$, the total is at most $3h^{2}/4$. $\square$

**Proposition 8.6 (One-sidedness persists).** *Under the hypotheses of Theorem 8.5, $P_h(P_h(x,y),z) - xyz \ge 0$.*

*Proof.* Both brackets in the proof of Theorem 8.5 are non-negative by Corollary 3.4 (applied on the positive quadrant, which contains $(Q,z)$). $\square$

**Discussion.** The purely additive prediction for two gates is $2\cdot h^{2}/3 \approx 0.667h^{2}$; the certified constant is $0.75h^{2}$, within $13\%$. A multiplicative propagation model would instead predict a factor growing like $(33/32)^{4d}$ in the gate count $d$, which is emphatically *not* what happens: the excess over additivity is $(33/32)^4 - 1 \approx 13\%$ *once*, not once per level, because the operand bound relaxes only by the $\Theta(h^{2})$ overshoot. Moreover, Proposition 8.6 shows that all gate errors in a product tree have the **same sign**; they can never conspire adversarially, and the accumulation is genuinely additive rather than a worst-case triangle-inequality artefact.

---

## 9. Algorithms

Three computational procedures follow directly from the theory.

**Algorithm A — Exact worst-case error of a product gate.** Given $h > 0$, return $\bigl(e^{2h} + e^{-2h} - 2 - 4h^{2}\bigr)/(4h^{2})$, together with the maximiser $(1,1)$. Cost $O(1)$. Numerical care is required for small $h$: the expression is a difference of nearly-equal quantities and suffers catastrophic cancellation below $h \approx 10^{-4}$ in double precision; there, use the series $\sum_{k\ge2}2(2h)^{2k-2}/\bigl(4\,(2k)!\bigr)\cdot 4 = h^{2}/3 + 2h^{4}/45 + h^{6}/315 + \cdots$, which converges geometrically.

**Algorithm B — Scale selection.** Given a target accuracy $\varepsilon > 0$, find the largest $h$ with $\gamma(2h)/(4h^{2}) \le \varepsilon$. Because the map $h \mapsto \gamma(2h)/(4h^{2}) = \sum_{k\ge2}2^{2k-1}h^{2k-2}/(2k)!$ has non-negative coefficients and is strictly increasing on $(0,\infty)$, bisection converges monotonically. The leading-order answer is $h \approx \sqrt{3\varepsilon}$, and the exact answer is always slightly smaller. Cost $O(\log(1/\text{tol}))$.

**Algorithm C — Barrier certificate for an affine read-out.** Given $h$ and candidate coefficients $(\lambda,\mu,\nu,\kappa)$, evaluate the error at the seven probe points $(1,1),(1,0),(0,1),(0,0),(\tfrac12,\tfrac12),(\tfrac12,0),(0,\tfrac12)$ and return the maximum. Theorem 6.6 guarantees this maximum is at least $h^{2}/210$, so the routine is a *complete* certificate: no search over the square is needed. Cost $O(1)$.

---

## 10. Discussion

### 10.1 What the proof actually needed

Three ingredients, in decreasing order of depth:

1. **The exact identity** (Theorem 3.1), which reduces a two-variable approximation problem to the increment of a one-variable function. This is free, but it is the step that makes everything else possible.
2. **Monotonicity of the remainder** (Lemma 4.2), equivalent to $\sinh t \ge t$. This alone gives the corner theorem, the closed form, one-sidedness, the box bound, and the entire universality theory.
3. **Slack monotonicity** (Lemma 4.3), the quantitative refinement, which gives the two-sided polarised bound with matching shape. This is where the cubic bracket for $2\sinh$ enters.

Notably, Taylor analysis is confined to the *quantitative* statements (Theorems 4.5, 4.8). The structural results — where the maximum lives, what it equals, which activations are better — need none.

### 10.2 The general lesson for polarised approximants

Polarisation is ubiquitous in numerical analysis: whenever a bilinear or quadratic quantity is synthesised from a univariate approximant, one gets a *difference* of remainders. The observation of this paper is that estimating that difference as a sum is not merely lossy by a constant — it is lossy in *shape*, producing bounds that fail to vanish where the true error vanishes identically. The remedy is structural: identify the remainder as a monotone function and estimate its increment.

The same argument applies verbatim to any approximation of the form $\bigl[\Phi(u+v) - \Phi(u-v)\bigr]/4$ where $\Phi$ is an even approximant of $(\cdot)^{2}$, and, with sign changes, to second-difference stencils $\bigl[\Phi(u+v) - 2\Phi(u) + \Phi(u-v)\bigr]$.

### 10.3 Limits of the results

The corner theorem is stated on $[0,1]^{2}$ (and $[0,M]^{2}$ via Theorem 8.2). On a *signed* domain $[-1,1]^{2}$ the analysis changes: by evenness of $\gamma$ the error is $\bigl[\gamma(h(x+y)) - \gamma(h(x-y))\bigr]/(4h^{2})$, which is now *negative* in the quadrants where $xy < 0$; the maximum of $|{\cdot}|$ is attained at all four corners $(\pm1,\pm1)$ with the same magnitude $\gamma(2h)/(4h^{2})$. The one-sidedness of Corollary 3.4, and hence the accumulation argument of §8.2, is genuinely restricted to the positive quadrant.

The affine barrier is proved for $0 < h \le \tfrac12$ with the explicit constant $h^{2}/210$, which is certainly not optimal — numerical minimisation of the worst probe error indicates the true optimum is close to $h^{2}/32$. Optimising it is a matter of arithmetic, not ideas.

---

## 11. Future work

**Higher-order gates.** Theorem 7.5 shows the leading error is $4c\,h^{2}$ where $c$ is the quartic coefficient of the remainder. One can force $c = 0$ by a *Richardson-type* combination of two soft squares at different scales, e.g. $\tfrac{4}{3}S_{h}(u) - \tfrac13 S_{2h}(u)$, whose remainder starts at order $t^{6}$. The predicted error is then $O(h^{4})$ at width $8$ instead of $4$. The barrier of §6 says this cost is unavoidable for affine read-outs at width $4$, so the width–order trade-off is pinned from both sides — but the exact exchange rate (does order $2k$ cost width $4k$?) is open.

**Correction rank.** Theorem 6.6 lower-bounds the correction rank by $1$. Determining it exactly — how many *new* nonlinear units suffice to reach $o(h^{2})$, and whether the mixed-difference obstruction generalises to rank-$r$ corrections — is the natural next question. The mixed second difference kills all separable corrections; higher-order finite differences on richer probe grids should kill low-rank ones.

**Deep trees.** Theorem 8.5 handles two gates. The mechanism (box bound $+$ output range $+$ one-sidedness) is clearly iterable, and the conjecture is that a depth-$d$ balanced tree with $d$ gates has error at most $\bigl(d\cdot\tfrac13 + o(1)\bigr)h^{2}$ with the *same* constant $\tfrac13$ per gate. The technical obstacle is that the operand bound $M_k$ grows with depth as $M_{k+1} = M_k^{2} + M_k^4h^2/3 + \cdots$, and one must show this stays $1 + O(h^{2})$ rather than escaping.

**Signed and unbounded domains.** Extending the corner theorem to $[-M,M]^{2}$ and to sub-Gaussian input distributions (where the relevant quantity is $\mathbb{E}\,\gamma(h(X+Y))$ rather than a supremum) would connect the analysis to statistical rather than worst-case guarantees.

**Beyond the exponential.** Definition 7.1 covers any even monotone remainder. Two families deserve attention: (i) *non-analytic* generators such as $t^{2} + |t|^{p}$, $2<p<4$, whose gates have error $\Theta(h^{p-2})$ — worse than quadratic, showing that smoothness of the activation is what buys the rate; (ii) generators with *negative* remainders (Proposition 7.9), where the gate undershoots and errors in a tree may cancel. Deliberately alternating the two could give a tree whose accumulated bias is $o(d h^{2})$.

**Minimax activations.** Theorem 7.4 says pointwise remainder comparison is a total order on gate quality. Combined with realisability constraints (which remainders are achievable by a width-$w$ combination of a given nonlinearity?), this poses a clean minimax problem: minimise $\gamma_g(2h)$ over the realisable set. For exponentials of width $4$ the answer is forced; for larger widths it is open.

---

## 12. Conclusion

The error of the width-four exponential product gate on $[0,1]^{2}$ is known exactly:
$$\max_{[0,1]^{2}}\bigl|P_h(x,y) - xy\bigr| = \frac{e^{2h}+e^{-2h}-2-4h^{2}}{4h^{2}} = \frac{h^{2}}{3} + \frac{2h^{4}}{45} + \cdots,$$
attained at $(1,1)$, with the sharp pointwise leading term $h^{2}xy(x^{2}+y^{2})/6$. The rate $\Theta(h^{2})$ cannot be improved by any scalar or affine read-out. All of this is a consequence of one structural fact — the error is the increment of an even, monotone remainder between $h|x-y|$ and $h(x+y)$ — which also yields, at no extra cost, a complete theory of polarisation gates for arbitrary even monotone generators, in which the celebrated constant $\tfrac13$ is revealed to be nothing more than four times the quartic Taylor coefficient of the activation's remainder.

The methodological moral is compact: *cancellation between polarisation branches is a monotonicity statement about the remainder, not a size statement about it.* Any argument that measures the branches separately will miss it, provably; any argument that watches the remainder move will capture it, effortlessly.

