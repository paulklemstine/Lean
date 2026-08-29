# The KV Precision Cliff: Crowding, Homogeneity, and the Absence of a Usable Middle

**Author:** Aristotle
**Date:** 2026-08-29

---

## Abstract

Quantizing the key–value cache of a transformer language model exhibits a sharp
discontinuity. On a seven-billion-parameter instruction-tuned model evaluated on
a held-out slice of approximately $62{,}000$ tokens at context length $2048$,
an $8$-bit cache is quality-neutral (worst-case perplexity change $+0.097\%$
across all three $8$-bit arms, with one arm improving by $0.238\%$), while a raw
per-tensor $4$-bit cache raises perplexity from $7.1093$ to $2714.6042$, a
factor of $381.8$ ($+38{,}084\%$).

We give a mathematical account of this discontinuity that is structural rather
than empirical. Four results form the core.

1. **A crowding law.** Attention logits at a head live in a bounded window of
   width $R$; with $n$ cached positions, a pigeonhole argument forces some
   consecutive pair to be separated by at most $R/n$. Defining a bit width $b$
   to be *safe* when the induced logit error $A/2^{b}$ cannot bridge half that
   forced gap, safety at $(n,b)$ and safety at $(2n,\,b+1)$ are the **same
   proposition**. Thus the minimal safe width satisfies $b^*(2n)=b^*(n)+1$
   exactly: the cliff is located at $b - \log_2 n$, not at $b$. At the reference
   scale $A=1$, $R=32$, $n=2048$ the criterion brackets the cliff in $(4,8]$,
   reproducing the measurement, and predicts that $8$ bits already fail at
   $n = 32768$.

2. **A two-sided perplexity certificate.** A logit perturbation bounded by
   $\varepsilon$ multiplies perplexity by at most $e^{2\varepsilon}$. Forward,
   this certifies the $8$-bit arms: $\varepsilon \le 1/2000$ gives at most
   $+0.11\%$. Backward, the measured factor $\ge 380$ forces the effective
   $4$-bit logit error to be at least $2.5$ nats, which in turn forces a logit
   dynamic range of at least $40$ nats if the error is uniform-grid resolution.

3. **A homogeneity obstruction.** Linear depth propagation
   $E_{L+1} = \kappa E_L + \varepsilon$ has closed form
   $\varepsilon(\kappa^{L}-1)/(\kappa-1)$, is exponential in $L$, and is exactly
   homogeneous of degree one in $\varepsilon$. Since $8 \to 4$ bits multiplies
   the step by $16$, no sub-homogeneous damage model can reproduce both arms:
   folklore "error amplification through depth" under-predicts the collapse by
   more than two orders of magnitude, for every $\kappa$ and every $L$
   simultaneously. The measured pair instead forces a power-law response
   exponent $p > 3$, and $p \ge 3$ confines the entire free-to-annihilated
   transition to at most $4$ bit widths.

4. **A structural limit on block scaling.** Block scaling is *exactly* a bit
   shift: safety of a range shrunk by $2^{m}$ at $b$ bits equals safety of the
   full range at $b+m$ bits. A rescue of the $4$-bit cell therefore requires the
   per-block range to be more than $16\times$ smaller than the per-tensor range,
   and one full-range block destroys the gain. But no scaling scheme can rescue
   *distinctness*: $16$ codes cannot separate the $32$ weights of a block, the
   collision survives every affine rescaling, and collided keys receive exactly
   equal softmax weights.

Finally, a *sandwich theorem* computes the width of the band between "provably
inverted" and "provably free" as $\lceil \log_2 (R/(n\delta))\rceil$ bits,
equal to $4$ at the reference scale — exactly the gap between the two arms the
experiment ran.

**Keywords:** attention quantization, key–value cache, softmax stability,
pigeonhole crowding, perplexity bounds, homogeneity obstruction, block scaling,
threshold phenomena.

---

## 1. Introduction

### 1.1 The measurement

Autoregressive transformer inference caches, for each processed token, a key
vector and a value vector per attention head. This *KV cache* dominates memory
at long context and is the natural target for reduced-precision storage. The
empirical grid that motivates this work was run on a seven-billion-parameter
instruction-tuned model at context $2048$, threads fixed, on a held-out text
slice of $\approx 62$K tokens, varying the cache element type for keys ($K$) and
values ($V$) independently:

| $K$ | $V$ | perplexity | $\Delta$ vs control |
|---|---|---|---|
| $16$-bit float | $16$-bit float | $7.1093$ | — |
| $8$-bit | $16$-bit float | $7.0924$ | $-0.238\%$ |
| $16$-bit float | $8$-bit | $7.1160$ | $+0.094\%$ |
| $8$-bit | $8$-bit | $7.1162$ | $+0.097\%$ |
| **$4$-bit (per-tensor)** | **$4$-bit (per-tensor)** | **$2714.6042$** | **$+38{,}084\%$** |

Two laws were extracted. **(L1) Eight-bit cache is free:** full-width $8$-bit
storage halves the KV buffer at worst-case $+0.10\%$ perplexity, so the trade is
memory-versus-speed (a measured $+16$–$26\%$ pass-time tax), never
memory-versus-quality. **(L2) The cliff is a wall:** between $8$ and $4$ bits
there is no usable operating point in this grid.

No key-versus-value asymmetry was resolvable at the $8$-bit floor, and no
single-sided $4$-bit arms were run; those remain open.

### 1.2 What needs explaining

A factor of $381.8$ in perplexity from a factor of $16$ in quantization step is
not a smooth response. Three questions organize the paper.

- **Where is the cliff?** Is $4$ versus $8$ bits the right coordinate at all?
  (Section 3: no — the right coordinate is $b - \log_2 n$.)
- **Why is it a cliff and not a slope?** (Sections 4 and 5: because the response
  exponent is $> 3$, and no linear-in-$\varepsilon$ mechanism can produce it.)
- **Can engineering flatten it?** (Section 6: block scaling buys resolution at a
  computable exchange rate, and buys no distinctness at all.)

### 1.3 Notation and conventions

Throughout, $n$ is the number of cached positions (context length), $b$ a bit
width, $R > 0$ the width of the window containing a head's attention logits
(measured in nats, since logits enter an exponential), and $A > 0$ the logit-side
dynamic range that a $b$-bit uniform grid must cover, so that the induced
per-position logit error is at most $A/2^{b}$. All logarithms are natural unless
subscripted. For a vector of logits $s \in \mathbb{R}^{N}$ the softmax weight is

$$\sigma_i(s) \;=\; \frac{e^{s_i}}{\sum_{k=1}^{N} e^{s_k}}, \qquad \sigma_i(s) > 0, \quad \sum_i \sigma_i(s) = 1 .$$

We use two elementary properties of $\sigma$ repeatedly: it is *strictly
order-preserving* ($\sigma_i(s) < \sigma_j(s) \iff s_i < s_j$) and *shift
invariant*.

---

## 2. Preliminaries: softmax stability

**Lemma 2.1 (Two-sided multiplicative stability).**
*Let $s, d \in \mathbb{R}^{N}$ with $|d_k| \le \varepsilon$ for all $k$. Then for
every $i$,*
$$e^{-2\varepsilon}\,\sigma_i(s) \;\le\; \sigma_i(s+d) \;\le\; e^{2\varepsilon}\,\sigma_i(s).$$

*Proof sketch.* The numerator $e^{s_i + d_i}$ lies in
$[e^{-\varepsilon}, e^{\varepsilon}]\cdot e^{s_i}$, and the denominator
$\sum_k e^{s_k + d_k}$ lies in $[e^{-\varepsilon},e^{\varepsilon}]\cdot \sum_k
e^{s_k}$ since every term is scaled by a factor in that interval. Dividing gives
a factor in $[e^{-2\varepsilon}, e^{2\varepsilon}]$. The lower bound also follows
from the upper bound by perturbing back: applying the upper bound to the pair
$(s+d, -d)$ and noting $(s+d)+(-d) = s$ yields
$\sigma_i(s) \le e^{2\varepsilon}\sigma_i(s+d)$. $\square$

**Lemma 2.2 (Order preservation).** *$\sigma_i(s) < \sigma_j(s)$ if and only if
$s_i < s_j$.* Immediate, since $\sigma$ divides a strictly increasing function of
$s_i$ by a common positive denominator.

Consequently a perturbation of size $\varepsilon$ can invert the order of two
positions $i, j$ precisely when $|s_j - s_i| < 2\varepsilon$: the adversarial
displacement $(+\varepsilon, -\varepsilon)$ closes exactly a gap of
$2\varepsilon$. This threshold, $2\varepsilon$ against the logit gap, is the
quantity every result below compares something to.

---

## 3. The crowding law: the cliff lives at $b - \log_2 n$

### 3.1 Crowding is forced

**Theorem 3.1 (Crowding pigeonhole).**
*Let $s_0, s_1, \dots, s_n$ be real numbers with $s_n - s_0 \le R$ and $n \ge 1$.
Then there exists $k < n$ with*
$$s_{k+1} - s_k \;\le\; \frac{R}{n}.$$

*Proof.* Suppose not: $s_{k+1} - s_k > R/n$ for all $k < n$. Summing the $n$
strict inequalities and telescoping,
$s_n - s_0 = \sum_{k<n}(s_{k+1}-s_k) > n\cdot(R/n) = R$, contradicting the
spread hypothesis. $\square$

Nothing is assumed about the distribution of the logits — not independence, not
smoothness, not a prior. The statement is a property of *any* $n+1$ numbers in a
window of width $R$. This is why we call the crowding **forced**: a model cannot
train its way out of it. If the head's logits are monotonically enumerated, the
witnessing pair is genuinely adjacent and correctly ordered before quantization.

The dependence on $n$ is the point. Doubling the context halves the guaranteed
worst-case spacing.

### 3.2 The safety criterion

**Definition 3.2 (Safe bit width).** For $A, R \in \mathbb{R}$, $n, b \in
\mathbb{N}$, say $b$ is *safe at context $n$*, written $\mathrm{Safe}(A,R,n,b)$,
when
$$2\cdot \frac{A}{2^{b}} \;<\; \frac{R}{n}.$$

The left side is the width of the interval a quantizer of resolution $A/2^{b}$
can close (Lemma 2.2 discussion); the right side is the forced crowding gap of
Theorem 3.1. Safety says the noise cannot bridge the gap that crowding
guarantees exists.

**Proposition 3.3 (Arithmetic form).** *For $n \ge 1$,*
$$\mathrm{Safe}(A,R,n,b) \iff 2An < R\,2^{b}.$$
*Moreover safety is monotone in $b$ when $A \ge 0$, and for $R>0$, $n\ge1$ some
$b$ is always safe.*

*Proof sketch.* Clear denominators, both positive. Monotonicity: $A/2^{b'} \le
A/2^{b}$ for $b \le b'$, $A \ge 0$. Existence: take $b = \lceil 2An/R\rceil$ and
use $m < 2^{m}$. $\square$

### 3.3 One bit per context doubling — exactly

**Theorem 3.4 (Crowding law).** *For all $A, R \in \mathbb{R}$ and $n, b \in
\mathbb{N}$,*
$$\mathrm{Safe}(A,R,2n,\,b+1) \iff \mathrm{Safe}(A,R,n,\,b),$$
*and more generally, for every $m$,*
$$\mathrm{Safe}(A,R,2^{m}n,\,b+m) \iff \mathrm{Safe}(A,R,n,\,b).$$

*Proof.* Doubling $n$ replaces the right-hand side $R/n$ by $(R/n)/2$; adding one
bit replaces the left-hand side $2(A/2^{b})$ by $(2(A/2^{b}))/2$. Both sides of a
strict inequality are divided by the same positive constant, so the inequality is
unchanged. The general case follows by induction on $m$. $\square$

This is an *identity of propositions*, not an asymptotic equivalence — a point
worth stressing, because scaling laws in this area are usually approximate.

**Definition 3.5.** $b^{*}(n) = \min\{\, b : \mathrm{Safe}(A,R,n,b)\,\}$, which
exists by Proposition 3.3.

**Corollary 3.6 (Exact cliff motion).** *If $R>0$, $n \ge 1$, and zero bits are
not already safe at context $2n$ (the nondegenerate regime), then*
$$b^{*}(2n) \;=\; b^{*}(n) + 1 .$$

*Proof sketch.* Theorem 3.4 applied to $b^{*}(n)$ gives $b^{*}(2n) \le b^{*}(n)+1$.
Conversely $b^{*}(2n) \ge 1$ by the nondegeneracy hypothesis, so
$b^{*}(2n) = c+1$ for some $c$; Theorem 3.4 backwards makes $c$ safe at $n$,
hence $b^{*}(n) \le c$ and $b^{*}(2n) = c+1 \ge b^{*}(n)+1$. $\square$

**Interpretation.** The quality-preserving KV width is not a constant of the
model. It is a function of context, with slope exactly $1$ bit per doubling. The
invariant is $b - \log_2 n$.

### 3.4 The criterion bites: a genuine inversion

Safety is stated as a comparison of numbers; the following says that violating it
has an operational consequence.

**Theorem 3.7 (Crowding inverts the softmax).** *Let $n \ge 1$, let
$s : \{0,\dots,n\} \to \mathbb{R}$ be monotone with $s_n - s_0 \le R$, and let
$\varepsilon$ satisfy $R/n < 2\varepsilon$. Then there exist indices $i \le j$
with $s_i \le s_j$ and a perturbation $d$ with $|d_k| \le \varepsilon$ for all
$k$ such that*
$$\sigma_j(s+d) \;<\; \sigma_i(s+d).$$
*That is: two correctly ordered cached positions have strictly reversed attention
weights after quantization.*

*Proof sketch.* Theorem 3.1 supplies adjacent $k, k+1$ with
$s_{k+1}-s_k \le R/n < 2\varepsilon$. Define $d_m = +\varepsilon$ for $m \le k$
and $d_m = -\varepsilon$ otherwise. Then
$(s_{k+1} - \varepsilon) - (s_k + \varepsilon) = (s_{k+1}-s_k) - 2\varepsilon < 0$,
and Lemma 2.2 converts the reversed logit order into a reversed softmax order.
$\square$

Note that the perturbation used is not exotic: a sign pattern that pushes lower
logits up and higher logits down is exactly what independent rounding produces
with probability bounded away from zero.

### 3.5 The reference instance

Take the reference scale $A = 1$ (unit logit-side amplification of one key
entry) and $R = 32$ nats.

**Proposition 3.8 (Bracketing).** *At $n = 2048$: $\mathrm{Safe}(1,32,2048,8)$
holds and $\mathrm{Safe}(1,32,2048,4)$ fails.*

*Proof.* By Proposition 3.3, safety is $2\cdot 1\cdot 2048 < 32\cdot 2^{b}$, i.e.
$4096 < 32\cdot 2^{b}$, i.e. $2^{b} > 128$. True at $b=8$ ($256 > 128$), false at
$b=4$ ($16 \not> 128$). $\square$

So the criterion places the cliff in $(4, 8]$ — where the experiment found it —
with no fitted parameters beyond the choice of $R$ and $A$.

**Proposition 3.9 (Falsifiable prediction).** *$\mathrm{Safe}(1,32,32768,8)$
fails:* $2\cdot 32768 = 65536 \not< 32 \cdot 256 = 8192$.

Four context doublings from $2048$ consume four bits; hence the comfortable
$8$-bit operating point is a property of the context length, not of the model.
This is a two-point experiment: rerun the same grid at $8192$ and check whether
the free width moves up by exactly two bits.

---

## 4. The perplexity certificate and its inverse

The crowding law explains fragility. Freedom needs a bound that reaches the
reported quantity, which is perplexity.

**Definition 4.1.** For logits $s$ and true token $i$, the log-loss is
$\ell(s,i) = -\log \sigma_i(s)$. For a slice of $m$ positions with logits
$z_a$ and true tokens $t_a$, the mean cross-entropy is
$H = \frac{1}{m}\sum_{a} \ell(z_a, t_a)$ and the perplexity is
$\mathrm{PPL} = e^{H}$.

**Theorem 4.2 (Log-loss stability).** *If $|d_k| \le \varepsilon$ for all $k$
then $\ell(s+d, i) \le \ell(s,i) + 2\varepsilon$.*

*Proof.* By the lower bound of Lemma 2.1,
$\sigma_i(s+d) \ge e^{-2\varepsilon}\sigma_i(s) > 0$; take $-\log$ of both sides,
which reverses the inequality, and use $\log(e^{-2\varepsilon}x) = \log x -
2\varepsilon$. $\square$

**Theorem 4.3 (Perplexity certificate).** *If every logit of every position of a
slice of $m \ge 1$ positions is perturbed by at most $\varepsilon$, then*
$$\mathrm{PPL}_{\text{perturbed}} \;\le\; e^{2\varepsilon}\; \mathrm{PPL}_{\text{exact}}.$$

*Proof.* Sum Theorem 4.2 over the $m$ positions, divide by $m$ to get
$H' \le H + 2\varepsilon$, and exponentiate (monotone). $\square$

### 4.1 The free side

**Corollary 4.4 (Eight-bit is free).** *If $\varepsilon \le 1/2000$ nats, then
$\mathrm{PPL}_{\text{perturbed}} \le 1.0011 \cdot \mathrm{PPL}_{\text{exact}}$.*

*Proof.* $e^{2/2000} = e^{1/1000} \le (1 - 1/1000)^{-1} \le 1.0011$, using
$e^{x} \le (1-x)^{-1}$ for $x<1$, itself a consequence of $1+x \le e^{x}$ at
$-x$. $\square$

A full-width $8$-bit code on a well-scaled tensor injects logit error on the
order of half a milli-nat, so the certificate predicts at most $+0.11\%$. The
measured $8$-bit arms were $-0.238\%$, $+0.094\%$, $+0.097\%$: all inside the
certified envelope, and the negative arm is consistent with measurement noise on
a single slice. This is law **L1**, with a proof rather than a data point.

### 4.2 The inverse reading

Upper bounds are usually inert as explanations. This one is not, because the
measured damage is so extreme that the inequality runs backwards with force.

**Theorem 4.5 (Effective four-bit error).** *If the perturbation is bounded by
$\varepsilon$ and the measured perplexity ratio satisfies
$\mathrm{PPL}_{\text{perturbed}} \ge 380\,\mathrm{PPL}_{\text{exact}}$, then*
$$\varepsilon \;\ge\; 2.5 \ \text{nats}.$$

*Proof.* By Theorem 4.3, $380 \le e^{2\varepsilon}$. Since $e^{5} < 149 < 380$
(from $e < 2.7182818286$, so $e^{5} < 2.7182818286^{5} < 149$), we get
$e^{5} < e^{2\varepsilon}$, hence $5 < 2\varepsilon$. $\square$

The observed ratio is $2714.6042/7.1093 = 381.8 > 380$. So the $4$-bit cache
injects at least $2.5$ nats of logit error per position — a multiplicative
distortion of $e^{2.5} \approx 12$ in unnormalized attention weight. This is not
a perturbed ranking; it is a different ranking.

**Corollary 4.6 (A prediction about the model, not the quantizer).** *If the
$4$-bit logit error is the resolution $A/2^{4}$ of a uniform grid over logit
dynamic range $A$, then $A \ge 40$ nats.*

*Proof.* $2.5 \le A/16$. $\square$

This is testable and could falsify the whole uniform-resolution account:
measure the per-head attention-logit range of the model. If it is far below $40$
nats, the collapse is not average-resolution failure but *outlier* failure — a
few keys with extreme magnitude inflating the per-tensor scale for everyone
else. (See Section 8, direction C2.)

---

## 5. Why depth amplification is not the mechanism

### 5.1 The linear propagation model

The standard informal explanation is that a small key error is multiplied
through every softmax boundary of every layer. Formalize it: let each layer
amplify the incoming error by $\kappa \ge 1$ and inject fresh error
$\varepsilon$,
$$E_0 = 0, \qquad E_{L+1} = \kappa E_L + \varepsilon .$$

**Proposition 5.1 (Closed form and growth).** *For $\kappa \ne 1$,*
$$E_L = \varepsilon\,\frac{\kappa^{L} - 1}{\kappa - 1}.$$
*For $\kappa, \varepsilon \ge 0$: $E_L \ge 0$ and $E_{L+1} \ge \varepsilon
\kappa^{L}$; for $\kappa \ge 1$ also $E_L \ge L\varepsilon$.*

*Proof sketch.* Induction on $L$ for each claim; the closed form is the geometric
sum, and $E_{L+1} \ge \varepsilon\kappa^{L}$ follows from
$E_{L+1} = \kappa E_L + \varepsilon \ge \kappa(\varepsilon \kappa^{L-1})$. $\square$

So the model does what its advocates claim: error grows exponentially in depth.
That is not the issue.

### 5.2 The obstruction

**Theorem 5.2 (Exact homogeneity).** *For all $\kappa, \varepsilon, c$ and all
$L$,*
$$E_L(\kappa,\, c\varepsilon) \;=\; c\,E_L(\kappa,\varepsilon).$$

*Proof.* Induction: $E_0$ is $0$ for both; if $E_L(\kappa,c\varepsilon) = cE_L$
then $E_{L+1}(\kappa,c\varepsilon) = \kappa c E_L + c\varepsilon =
c(\kappa E_L + \varepsilon)$. $\square$

Homogeneity is *parameter-free*: it does not depend on $\kappa$ or $L$, so no
choice of depth or gain can escape it.

**Definition 5.3.** A damage response $D : \mathbb{R}_{\ge0} \to \mathbb{R}$ is
*sub-homogeneous* if $D(cx) \le c\,D(x)$ for all $c \ge 1$, $x \ge 0$. Every
linear-propagation model, at every depth and gain, is sub-homogeneous (with
equality).

**Theorem 5.4 (Refutation of sub-homogeneous damage).** *There is no
sub-homogeneous $D$ and $\varepsilon \ge 0$ with*
$$D(\varepsilon) \le \tfrac{1}{1000} \qquad\text{and}\qquad D(16\varepsilon) \ge 5 .$$

*Proof.* $D(16\varepsilon) \le 16 D(\varepsilon) \le 16/1000 < 5$. $\square$

The two hypotheses are exactly the measurement. The $8$-bit arm's excess
log-perplexity is $\log(7.1162/7.1093) < 1/1000$ nats (using
$\log x \le x - 1$: the ratio is $1.00097$, so the excess is below
$9.7\times10^{-4}$). The $4$-bit arm's excess is
$\log(2714.6042/7.1093) > 5$ nats (since $e^{5} < 149 < 381.8$). And the step
ratio between raw per-tensor $4$-bit and $8$-bit codes is exactly $16$.

**Corollary 5.5 (Quantified under-prediction).** *If a linear depth model is
calibrated so that its certified $8$-bit excess matches the measurement,
$2E_L(\kappa,\varepsilon) \le 1/1000$, then its $4$-bit prediction is*
$$2E_L(\kappa, 16\varepsilon) \;=\; 16\cdot 2E_L(\kappa,\varepsilon) \;\le\; \tfrac{16}{1000} \;<\; 5 ,$$
*under-predicting the measured excess by a factor exceeding $300$.*

**The cliff is a threshold phenomenon, not a gain.**

### 5.3 What the data do force

**Theorem 5.6 (Response exponent).** *Suppose the excess log-perplexity follows a
power law $D(x) = Cx^{p}$ with $C>0$ in the quantization step $x>0$. If
$D(x) \le 1/1000$ and $D(16x) \ge 5$, then $p > 3$.*

*Proof.* $D(16x) = 16^{p}Cx^{p}$. From $Cx^{p} \le 1/1000$ we get
$4096\,Cx^{p} \le 4.096 < 5 \le 16^{p}Cx^{p}$, and dividing by $Cx^{p} > 0$
gives $4096 < 16^{p}$. Since $4096 = 16^{3}$, this reads $16^{3} < 16^{p}$, and
strict monotonicity of $t \mapsto 16^{t}$ yields $p > 3$. $\square$

Thus the *observable* content of the collapse is a steep exponent, and steepness
bounds the width of the transition.

**Theorem 5.7 (The transition band is at most four bits wide).** *Fix $C, A,
\delta > 0$ and an exponent $p \ge 3$, and call a bit width $b$ **intermediate**
if*
$$\delta \;<\; C\left(\frac{A}{2^{b}}\right)^{p} \;<\; 5000\,\delta ,$$
*i.e. the damage it produces is neither free nor annihilating in the sense the
experiment observed. Then any two intermediate widths $b, b'$ satisfy
$|b - b'| \le 4$.*

*Proof sketch.* Suppose $b' \ge b+5$. Then $A/2^{b} \ge 32\,(A/2^{b'})$, so
$$\left(\frac{A}{2^{b}}\right)^{p} \;\ge\; 32^{p}\left(\frac{A}{2^{b'}}\right)^{p} \;\ge\; 2^{15}\left(\frac{A}{2^{b'}}\right)^{p} = 32768 \left(\frac{A}{2^{b'}}\right)^{p},$$
using $p \ge 3$. But intermediacy of $b$ gives
$C(A/2^{b})^{p} < 5000\delta$ and intermediacy of $b'$ gives
$C(A/2^{b'})^{p} > \delta$, so $5000\delta > 32768\,\delta$ — a contradiction.
$\square$

Five extra bits shrink the damage by more than the entire free-to-annihilated
dynamic range. This is the precise sense of "no usable middle": **the middle
exists, but is at most four bit widths wide**, and the grid $\{4,8\}$ is exactly
four bits apart. The experiment straddled the whole band in one step.

### 5.4 The cliff needs no depth at all

**Theorem 5.8 (Realization in a single softmax).** *There exist a logit gap
$G>0$ and an error scale $\varepsilon>0$ — namely $G = 12$ nats,
$\varepsilon = 13$ nats — such that in a two-position head with logits
$(0, G)$ and adversarial perturbation $(+\eta, -\eta)$:*
- *at $\eta = \varepsilon/16 = 0.8125$, the log-loss of the correct token rises by
  at most $1/1000$ nat (a perplexity factor below $1.001$);*
- *at $\eta = \varepsilon = 13$, it rises by at least $5$ nats (a perplexity
  factor above $148$).*

*Proof sketch.* For two positions the log-loss of the second class is
$\ell = \log(1 + e^{a-b})$ where $(a,b)$ are the perturbed logits. Unperturbed,
$a-b = -12$, so $\ell_0 = \log(1+e^{-12}) \le e^{-12} \le 1$. At $\eta =
13/16$ the argument is $13/16 - (12 - 13/16) = -83/8$, and
$\log(1+e^{-83/8}) \le e^{-83/8} \le 1/1000$ using $1000 \le e^{7} \le e^{83/8}$
and $\log(1+x)\le x$. At $\eta = 13$ the argument is $13-(12-13) = 14$, and
$\log(1+e^{14}) \ge \log e^{14} = 14 \ge \ell_0 + 5$. $\square$

So the same $16\times$ step ratio separates "free" from "annihilated" inside a
*single* attention head. Depth is not required to manufacture the cliff (Theorem
5.8), and depth-linear propagation cannot manufacture it (Theorem 5.4). Together
these bracket the folklore explanation from both sides.

---

## 6. Block scaling: a bit shift on resolution, nothing on distinctness

The natural engineering response to a $4$-bit collapse is *block scaling*:
partition the tensor into blocks (conventionally $32$ weights) and give each
block its own scale $\sigma$ and offset $\mu$. Does it rescue $4$-bit KV? The
answer has two halves that point in opposite directions.

### 6.1 Yes, on resolution — exactly one bit per halving of range

**Theorem 6.1 (Block scaling is a bit shift).** *For all $A, R$ and $n, b, m$,*
$$\mathrm{Safe}\!\left(\frac{A}{2^{m}},\,R,\,n,\,b\right) \iff \mathrm{Safe}(A,R,n,\,b+m).$$

*Proof.* $2\big((A/2^{m})/2^{b}\big) = 2\big(A/2^{b+m}\big)$; the right-hand
sides agree. $\square$

Quantizing a range shrunk by $2^{m}$ at $b$ bits is *the same safety statement*
as quantizing the full range at $b+m$ bits. Compare Theorem 3.4: context and
range enter the criterion through the same exponent, so the three quantities
(bits, $\log_2$ context, $\log_2$ range concentration) trade at par.

**Theorem 6.2 (A rescue needs $16\times$ concentration).** *Let $n \ge 1$,
$A>0$, and suppose a block whose range is $\rho A$ is safe at $4$ bits while the
full range $A$ is not safe even at $8$ bits. Then*
$$\rho \;<\; \frac{1}{16}.$$

*Proof sketch.* In arithmetic form, safety of the block is $2\rho An < R\,2^{4}$
and failure at $8$ bits is $R\,2^{8} \le 2An$. Multiply the first by $16$:
$32\rho An < R\cdot 2^{8} \le 2An$, and divide by $2An > 0$ to get
$16\rho < 1$. $\square$

Block scaling must shrink the dynamic range by *more than the four bits it is
trying to replace*. That is a sharp, cheap experiment: measure the ratio
(per-block key range)/(per-tensor key range); the resolution axis is rescued
exactly when that ratio is below $1/16$.

**Proposition 6.3 (Rescue at the reference scale).** *$\mathrm{Safe}(1,32,2048,4)$
fails, but $\mathrm{Safe}(2^{-4},32,2048,4)$ holds.*

*Proof.* The second is $\mathrm{Safe}(1,32,2048,8)$ by Theorem 6.1, which holds by
Proposition 3.8. $\square$

**Definition 6.4.** For block ranges $A_1,\dots,A_B$, the blocked cache is
*block-safe* at $(n,b)$ if $\mathrm{Safe}(A_j,R,n,b)$ for every $j$.

**Proposition 6.5 (The worst block governs).** *If $A_j \le A_{j_0}$ for all $j$
and $\mathrm{Safe}(A_{j_0},R,n,b)$, then the cache is block-safe.* (Monotonicity
of $A \mapsto A/2^{b}$.)

**Proposition 6.6 (One full-range block destroys the gain).** *If some block still
spans the entire tensor range, $A_{j_0} = A_{\text{full}}$, then block safety
implies $\mathrm{Safe}(A_{\text{full}}, R, n, b)$ — the blocked cache is safe only
where the per-tensor cache already was.*

A single outlier-bearing block therefore cancels the benefit for the whole
tensor. This is the mechanism by which outliers, not average precision, could
govern the cliff.

### 6.2 No, on distinctness — and no scheme can

**Theorem 6.7 (Four bits collide inside every block).** *Let $x_1,\dots,x_{32}$
be pairwise distinct reals and let $Q$ be any map whose image on these points
lies in a finite codebook $C$ with $|C| \le 16$. Then there exist $i \ne j$ with
$x_i \ne x_j$ and $Q(x_i) = Q(x_j)$.*

*Proof.* Pigeonhole: $32$ points map into at most $16$ codes, and $16 < 32$, so
two indices share a code; distinctness of the $x$'s makes the collision genuine.
$\square$

**Theorem 6.8 (Affine rescaling cannot separate).** *For every block scale
$\sigma$ and offset $\mu$, the rescaled quantizer
$x \mapsto \sigma\,Q\!\left(\frac{x - \mu}{\sigma}\right)$ still collides: there
are $i \ne j$ with $x_i \ne x_j$ and equal outputs.*

*Proof.* Apply Theorem 6.7 to the composite map
$y \mapsto Q((y-\mu)/\sigma)$, whose codebook is still of size $\le 16$; then
multiply both equal outputs by $\sigma$. $\square$

The number of distinct outputs is a property of the codebook cardinality, and
affine reparameterization does not change cardinality. **Scaling schemes move
where the levels are; they never add levels.**

**Theorem 6.9 (A collision is a tie; a tie is a lost ranking).** *If two cache
positions have equal quantized logits $s_i = s_j$, then $\sigma_i(s) =
\sigma_j(s)$ exactly.*

*Proof.* The softmax numerators are equal and the denominator is shared. $\square$

Zero information about the relative importance of the two tokens survives. This
is not a degraded ranking; it is an erased one — and it happens inside *every*
block of *every* layer at $4$ bits.

**Theorem 6.10 (Resolution rescued, distinctness not).** *At the reference scale,
$\mathrm{Safe}(2^{-4},32,2048,4)$ holds — the resolution criterion is satisfied by
a $16$-fold concentrated block at four bits — and simultaneously any $32$ distinct
keys in that block contain a pair that the $16$-level code cannot distinguish.*

The two thresholds move differently: block scaling shifts the **resolution**
threshold by a computable number of bits and cannot shift the **distinctness**
threshold at all. At four bits, with $32$-weight blocks, the two have already
crossed. That is the structural reason the cliff is a wall.

---

## 7. The sandwich: how wide is the unexplained band?

Two certificates now exist, pointing opposite ways.

- **Fragile side (Theorem 3.7).** If $A/2^{b}$ exceeds half the forced crowding
  gap $R/n$, some correctly ordered pair is provably inverted.
- **Free side (Theorem 4.3).** If the logit error is below $\delta/2$, perplexity
  is provably multiplied by at most $e^{\delta}$.

Between them lies a band of widths where neither applies. Its width is exactly
computable.

**Theorem 7.1 (From safe to free).** *Let $n \ge 1$, $\delta>0$, and suppose
$2^{m} \ge \dfrac{R}{n\delta}$. If $\mathrm{Safe}(A,R,n,b)$, then*
$$2\cdot \frac{A}{2^{\,b+m}} \;\le\; \delta .$$

*Proof.* Safety gives $2(A/2^{b}) < R/n$. The hypothesis on $m$ gives
$R/n \le \delta\,2^{m}$. Divide by $2^{m}$:
$2(A/2^{b+m}) = \big(2(A/2^{b})\big)/2^{m} < \delta$. $\square$

**Corollary 7.2 (Band width).** *Under the same hypotheses, every width
$b' \ge b+m$ satisfies the free criterion $2(A/2^{b'}) \le \delta$ (for
$A \ge 0$). Hence at most*
$$m \;=\; \left\lceil \log_2 \frac{R}{n\delta} \right\rceil$$
*bit widths can lie strictly between "provably inverted" and "provably free".*

**Theorem 7.3 (The sandwich, in one statement).** *Let $s$ be a monotone logit
profile on $n+1$ positions inside a window of width $R$, let the quantizer's logit
error be $A/2^{b}$, and let $2^{m} \ge R/(n\delta)$. If
$R/n < 2(A/2^{b})$, then simultaneously:*
1. *there exist correctly ordered positions $i, j$ and an admissible perturbation
   after which $\sigma_j < \sigma_i$ — the ranking is provably broken at width
   $b$; and*
2. *every width $b'$ that is safe satisfies $2(A/2^{b'+m}) \le \delta$ — so $m$
   further bits make the perplexity certificate apply at tolerance $\delta$.*

**Proposition 7.4 (The reference scale: four bits).** *At $A=1$, $R=32$,
$n=2048$, $\delta = 1/1000$:*
$$\log_2 \frac{R}{n\delta} = \log_2 \frac{32}{2048\times 0.001} = \log_2 15.625 \;<\; 4 ,$$
*so for every safe $b$, $2\cdot(1/2^{b+4}) \le 1/1000$.*

The two provable regimes are separated by **four bit widths** — exactly the gap
between the two arms actually run. The experiment did not fail to find a middle;
at its own scale, the middle is at most four widths wide and the grid stepped
across it in one move.

The formula is a design tool. The band **narrows by one bit for every context
doubling** (larger $n$) and **widens by one bit for every tenfold tightening of
the tolerance $\delta$**. Concretely: run $5$, $6$, $7$ bits at context $2048$
and the middle becomes resolvable.

---

## 8. Algorithms

Three procedures follow directly from the theory and are what one would actually
run.

**A. Safe-width oracle.** Given $(A, R, n)$, return $b^{*}(n) =
\min\{b : 2An < R\,2^{b}\} = \max\big(0, \lceil \log_2(2An/R)\rceil\big)$ (with
the convention that the ceiling is strict when $2An/R$ is an exact power of two).
Cost $O(1)$. By Corollary 3.6 the whole curve $n \mapsto b^{*}(n)$ over the
context range is obtained from one evaluation plus $\log_2$ of the range.

**B. Band locator.** Given $(A, R, n, \delta)$, return the interval
$[\,b^{*}(n),\ b^{*}(n) + \lceil\log_2(R/(n\delta))\rceil\,]$ of bit widths that
neither certificate resolves. This is the *experiment planner*: any grid that
skips this interval cannot see the transition. Cost $O(1)$.

**C. Block-rescue test.** Given the per-tensor key range $A_{\text{full}}$ and
per-block ranges $A_1,\dots,A_B$, compute $\rho = \max_j A_j / A_{\text{full}}$
(Proposition 6.5: the worst block governs) and report *rescued* iff
$\rho < 1/16$ and $\mathrm{Safe}(\rho A_{\text{full}}, R, n, 4)$. Additionally
report the *distinctness verdict*, which is always **failed** at $4$ bits with
$32$-weight blocks by Theorem 6.7 — a codebook cardinality check, independent of
the data. Cost $O(B)$ plus one pass over the tensor to compute block extrema.

---

## 9. Applications and practical consequences

**Deployment.** Store the KV cache at $8$ bits. The certificate (Corollary 4.4)
makes this a memory-versus-*speed* decision — the measured pass-time tax was
$+16$–$26\%$ — and never a memory-versus-quality one, at this context. Do not
store it at $4$ bits per-tensor under any circumstances: the observed perplexity
of $2714$ corresponds, by Theorem 4.5, to at least $2.5$ nats of logit error.

**Long context changes the answer.** Corollary 3.6 says the safe width climbs by
one bit per context doubling. A configuration validated at $2048$ carries no
guarantee at $8192$, and at $32768$ the reference-scale criterion already fails
at $8$ bits (Proposition 3.9). Any long-context deployment should re-derive
$b^{*}$, not inherit it.

**Experiment design.** Corollary 7.2 explains why a $\{4,8\}$ grid sees a wall:
the unresolved band is four bits wide at the reference scale, so the grid
straddles it exactly. To measure the transition rather than jump it, sample $5$,
$6$, $7$ bits.

**Diagnosing which failure you have.** Corollary 4.6 discriminates the two
candidate mechanisms with one measurement. If the per-head logit dynamic range is
$\ge 40$ nats, uniform-grid resolution suffices to explain the collapse. If it is
far below, the collapse is outlier-driven — and then Proposition 6.6 says block
scaling will not help either, because one full-range block cancels the gain.

**Mixed precision.** Since the criterion involves only the induced logit error,
it applies per head. Heads with narrow logit windows $R$ tolerate fewer bits;
heads with wide windows need more. The safe-width oracle is per-head, and the
worst head governs the model exactly as the worst block governs the tensor.

---

## 10. Discussion: what survived, what failed

**Survived and stronger than expected.** The crowding law is *exact*, not
asymptotic: safety at $(n,b)$ and at $(2n,b+1)$ are the same proposition
(Theorem 3.4). The homogeneity obstruction (Theorem 5.4) is parameter-free: it
kills the depth story for every gain $\kappa$ and every depth $L$ at once,
without needing to know either.

**Failed as stated, and replaced.** A first attempt at the band-width theorem
compared a "fatal" width with a "free" width. That comparison turns out to be
*consistent*, not contradictory — no bound follows. The correct statement
compares two *intermediate* widths, both in the band, and that is Theorem 5.7 as
proved.

**True, but only under the right definition.** "There is no usable middle" is
false as a statement about the real line: the response function is continuous, so
intermediate damage values are attained. It is true as a statement about *integer
bit widths with a steep exponent*: the middle exists and is at most four widths
wide (Theorem 5.7), and independently the two provable regimes are separated by
four widths at the reference scale (Proposition 7.4). Both routes give four, from
different premises — one from the response exponent, one from the certificate
gap.

**Honest limits of the empirical anchor.** A single held-out slice; point
estimates without per-arm standard errors; one model, one context, one machine;
$4$-bit block-scaled variants untested; no single-sided $4$-bit arms, so the
key-versus-value asymmetry question remains open by design. The choice
$R = 32$ nats, $A = 1$ for the reference scale is a plausible reading of a
trained model's logit spread, not a measurement — Corollary 4.6 is precisely the
experiment that would pin it down.

**Scope of the theory.** The crowding law bounds the *worst* pair, not the
typical one; a model whose attention is dominated by one position may be far more
robust than the criterion suggests. Conversely, the certificate of Theorem 4.3 is
worst-case in $\varepsilon$ and therefore conservative on the free side. The
theory brackets the truth; it does not predict the exact perplexity.

---

## 11. Future directions

The immediate program has three strands.

**C1. Crowding-corrected cliff position.** The key insight is that the cliff is
not located at a bit width at all: it is located at $b - \log_2 n$, because the
forced minimum gap between attention logits inside a bounded window shrinks
exactly like $1/n$. This makes the untested "cliff position versus context
length" question a two-point experiment: rerun the same grid at $8192$ and check
whether the free width moves up by exactly two bits.

> **Conjecture C1.** For a fixed model and head, the minimal quality-preserving
> KV width satisfies $b^{*}(2n) = b^{*}(n) + 1$ up to one bit, for all $n$ in the
> model's trained range.

**C2. Outlier-driven dynamic range of attention logits.** Corollary 4.6 runs the
certificate backwards to a statement about the network: the effective $4$-bit
error of at least $2.5$ nats requires a covered logit range of at least $40$
nats if the error is uniform resolution. Measuring the per-head logit range
either confirms the uniform account or forces an outlier account — in which case
Proposition 6.6 predicts that block scaling fails too, since a single full-range
block cancels the concentration gain.

**C4. Resolving the middle.** Corollary 7.2 gives the exact width
$\lceil\log_2(R/(n\delta))\rceil$ of the band no certificate covers, equal to
four at the reference scale. Sampling $5$, $6$, $7$ bits at context $2048$ should
reveal whether the response inside the band is the steep power law of Theorem 5.6
($p > 3$) or something sharper still.

Beyond these: single-sided $4$-bit arms to settle the key-versus-value asymmetry;
per-head mixed precision driven by the safe-width oracle; and an extension of the
crowding law from the worst pair to the *distribution* of gaps, which would turn
the worst-case criterion into an expected-damage prediction.

---

## 12. Conclusion

The KV precision axis has no usable middle at context $2048$, and the reason is
that two independent thresholds — resolution and distinctness — cross between
$8$ and $4$ bits.

On the resolution axis, the safety condition $2A/2^{b} < R/n$ trades bits against
$\log_2$ context at exactly par: $b^{*}(2n) = b^{*}(n)+1$. At the reference scale
this brackets the cliff in $(4,8]$, matching the measurement, and predicts that
$8$ bits stop being free somewhere below context $32768$. The perplexity
certificate $\mathrm{PPL} \le e^{2\varepsilon}\,\mathrm{PPL}_0$ certifies the
$8$-bit arms forward and, read backwards, converts the measured $380\times$
collapse into a lower bound of $2.5$ nats on the effective $4$-bit logit error.
No sub-homogeneous mechanism — in particular no linear depth amplification, at
any depth or gain — can span the measured $16\times$-step-to-$5000\times$-damage
ratio; what the data force instead is a response exponent above $3$, which
confines the whole transition to at most four bit widths.

On the distinctness axis, block scaling is exactly a bit shift and can rescue
resolution given more than $16\times$ range concentration in *every* block — but
$16$ codes cannot separate $32$ weights, no affine rescaling changes that, and
collided keys tie exactly in the softmax. The resolution wall can be pushed; the
distinctness wall cannot.

That is why the cliff is a wall.
