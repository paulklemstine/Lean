# Faithful-Model Slackness in the Exponent-One-Fifth Factoring Cost Model: Two Certificates, Deletion Penalties, and a Sharp Coupling Threshold

**Aristotle**

*October 2026*

---

## Abstract

Harvey's deterministic integer factorisation algorithm runs in time $N^{1/5}$ up to logarithmic factors. Its parameter balance is often analysed through a three-leg cost $\max\{r,\ m,\ N^{1/2}/(r^{1/2}m)\}$, made up of a pair floor $r$, a baby-step budget $m$ and a giant-step interior. This relaxation is minimised exactly at $r = m = N^{1/5}$. It leaves out a leg the algorithm actually pays for: one step fixes an auxiliary length $M = \lceil (N/r)^{1/2}\rceil$, which costs $(N/r)^{1/4}$. We study the resulting four-leg **faithful** model
$$T(r,m) = \max\Big\{(N/r)^{1/4},\ \frac{N^{1/2}}{r^{1/2}m},\ r,\ m\Big\}$$
in the exponent coordinates $r = N^a$, $m = N^b$, and also in the original real-power form. Our results are as follows.

1. **Slackness.** The two legs $(N/r)^{1/4}$ and $r$ alone already force $N^{1/5}$. The interior and baby-step legs can be replaced by arbitrary values, or deleted, without lowering the optimum.
2. Both models have the same **unique** minimiser $a = b = 1/5$. The value $1/5$ has two certificates that share only the pair floor, and any modified cost with exponent below $1/5$ must break **both**.
3. **Deletion penalties.** Deleting the baby-step floor raises the optimum to $1/3$, a penalty of $2/15$. Deleting the pair floor raises it to $1/4$, a penalty of $1/20$.
4. A fourth search floor of weight $w$ gives $1/(5+2w)$ in the relaxation, so $1/6$ at $w = 1/2$. In the faithful model it gives nothing for any $w$.
5. **Independent certificate law.** For $\max\{(N/r)^\mu, N^\gamma/(r^\alpha m), r, m\}$ with $\mu > 0$ and $\alpha \ge 0$, the optimal exponent is exactly $\max(\mu/(1+\mu),\ \gamma/(2+\alpha))$.
6. **Coupling threshold.** If the $M$-leg is coupled to the baby steps as $(N/r)^{1/4}/m^\theta$, coupling alone never beats $1/5$. Together with a weight-$\tfrac12$ fourth floor, the exponent $1/6$ is reachable if and only if $\theta \ge 1/4$.
7. **Partition lemma.** A $k$-level baby-step/giant-step structure over a pool $S$ with $L_iT_i \ge S_i$ costs $\sum(L_i + T_i) \ge 2\sqrt S$. The inequality is strict as soon as two levels carry part of the pool, and the uniform $k$-way split costs exactly $\sqrt k$ times the optimum.

Every result holds inside an assumed cost shape. None of them is a lower bound for integer factorisation. Their use is to say which parts of the algorithm an improvement must change.

---

## 1. Introduction

### 1.1 Background

Deterministic integer factorisation has a long sequence of exponents. Trial division factors $N$ in $O(N^{1/2})$ arithmetic operations. Lehman's method (1974) achieves $O(N^{1/3})$. The Pollard–Strassen method, which uses fast polynomial arithmetic to evaluate products of consecutive integers in blocks, achieves $N^{1/4}$ up to logarithmic factors. In 2021 Harvey gave a deterministic algorithm with complexity $N^{1/5}$ up to logarithmic factors. It combines a Lehman-style search over a family of about $r$ candidate pairs with a baby-step/giant-step search, in the spirit of Shanks, over the remaining space, and uses fast polynomial multipoint evaluation for the giant steps.

Asymptotic analyses of such algorithms usually reduce the running time to the **maximum of a few legs**, each a monomial in $N$ and the tunable parameters. Choosing the parameters is then a min–max problem. After taking logarithms base $N$ it becomes a linear program. That is the setting of this paper.

### 1.2 The question

Once the exponent $1/5$ is in hand, the natural question is which legs hold the exponent at $1/5$, and therefore which legs an improvement must change. A widely used simplified model has three legs:
$$T_{\mathrm{rel}}(r,m) = \max\Big\{ r,\ m,\ \frac{N^{1/2}}{r^{1/2}m} \Big\}.$$
Its optimum is exactly $N^{1/5}$, which makes it look like a complete account. It suggests three co-binding legs, so that cheapening the baby steps, restructuring the interior, or adding a new search parameter that shrinks the interior should each lower the exponent.

### 1.3 The missing leg

One step of Harvey's algorithm fixes the auxiliary length
$$M = \big\lceil (N/r)^{1/2} \big\rceil ,$$
and computing with $M$ terms costs $(N/r)^{1/4}$ up to logarithmic factors. We take this as the modelling hypothesis of the paper. With it, the faithful cost is
$$T(r,m) = \max\Big\{ (N/r)^{1/4},\ \frac{N^{1/2}}{r^{1/2}m},\ r,\ m \Big\}.$$
The main observation is that adding this leg does not change the optimum, but it changes which legs certify the optimum. The interior and the baby steps turn out to be slack: they can be removed without changing the optimal exponent. Every improvement proposal that targets only them is therefore ruled out.

### 1.4 Organisation

Section 2 fixes definitions. Section 3 proves the basic bounds and uniqueness. Section 4 proves slackness in exponent and real-power form. Section 5 gives the two-certificate structure and the "both locks" theorem. Section 6 computes the deletion penalties. Section 7 treats the fourth-floor lever. Section 8 proves the independent certificate law. Section 9 proves the coupling threshold. Section 10 proves the partition lemma. Section 11 describes the computational procedures used in the examples. Sections 12 and 13 discuss what the results mean and list open problems.

---

## 2. Definitions

Throughout, $N > 1$ is the integer to be factored. All costs are taken up to factors polylogarithmic in $N$.

**Definition 2.1 (Exponent coordinates).** Write $r = N^a$ and $m = N^b$ with $a, b \in \mathbb{R}$. We call $a$ the *pair exponent* and $b$ the *baby-step exponent*. A monomial cost $N^{e(a,b)}$ with $e$ affine is identified with its exponent $e$. The exponent of a maximum of monomials is the maximum of their exponents.

**Definition 2.2 (Legs).** The four legs of the faithful model, with their exponents, are:

| leg | cost | exponent |
|---|---|---|
| $M$-leg | $(N/r)^{1/4}$ | $\dfrac{1-a}{4}$ |
| interior | $N^{1/2}/(r^{1/2}m)$ | $\dfrac12 - \dfrac a2 - b$ |
| pair floor | $r$ | $a$ |
| baby-step floor | $m$ | $b$ |

**Definition 2.3 (Relaxed and faithful exponents).** The *relaxed* (three-leg) exponent is
$$E_{\mathrm{rel}}(a,b) = \max\Big\{ a,\ b,\ \tfrac12 - \tfrac a2 - b \Big\}.$$
The *faithful* (four-leg) exponent is
$$E(a,b) = \max\Big\{ \tfrac{1-a}{4},\ E_{\mathrm{rel}}(a,b) \Big\}.$$
The *pair-leg core* is $P(a) = \max\{(1-a)/4,\ a\}$.

**Definition 2.4 (Certificate, slack).** Let $\mathcal L$ be a finite set of affine legs and $v^\ast = \inf_{a,b}\max_{\ell\in\mathcal L}\ell(a,b)$. A subset $\mathcal C \subseteq \mathcal L$ is a *certificate* for a value $v$ if $\max_{\ell\in\mathcal C}\ell(a,b) \ge v$ for all $(a,b)$. A leg $\ell \in \mathcal L$ is *slack* if $\mathcal L\setminus\{\ell\}$ is still a certificate for $v^\ast$. More strongly, a set of legs is *removable* if its complement is a certificate for $v^\ast$.

A slack leg may still be *tight* at the optimum, meaning equal to $v^\ast$ there. Slackness means that the bound does not depend on the leg.

**Definition 2.5 (Fourth floor, coupling).** A *fourth floor of weight $w \ge 0$* is a new parameter $N^c$ that costs $N^c$ and divides the interior by $N^{wc}$:
$$E^{(4)}_{\mathrm{rel}}(a,b,c;w) = \max\Big\{a,\ b,\ c,\ \tfrac12 - \tfrac a2 - b - wc\Big\},\qquad E^{(4)}(a,b,c;w) = \max\Big\{\tfrac{1-a}{4},\ E^{(4)}_{\mathrm{rel}}(a,b,c;w)\Big\}.$$
A *coupling of strength $\theta$* replaces the $M$-leg exponent by $\tfrac{1-a}{4} - \theta b$, that is, the $M$-leg cost by $(N/r)^{1/4}/m^\theta$:
$$E^{(4)}_\theta(a,b,c;w) = \max\Big\{\tfrac{1-a}{4} - \theta b,\ E^{(4)}_{\mathrm{rel}}(a,b,c;w)\Big\}.$$

**Definition 2.6 (Generalised faithful exponent).** For parameters $\mu > 0$, $\gamma \in \mathbb{R}$, $\alpha \ge 0$, set
$$G_{\mu,\gamma,\alpha}(a,b) = \max\Big\{ \mu(1-a),\ \gamma - \alpha a - b,\ a,\ b \Big\},$$
the exponent of $\max\{(N/r)^\mu,\ N^\gamma/(r^\alpha m),\ r,\ m\}$. Harvey's model is $(\mu,\gamma,\alpha) = (\tfrac14, \tfrac12, \tfrac12)$.

---

## 3. Basic bounds and the unique minimiser

**Theorem 3.1 (Relaxed lower bound).** For all real $a, b$, $E_{\mathrm{rel}}(a,b) \ge 1/5$.

*Proof.* Let $t = E_{\mathrm{rel}}(a,b)$. Then $a \le t$, $b \le t$ and $\tfrac12 - \tfrac a2 - b \le t$. Add the third inequality, half the first and the full second:
$$\tfrac12 = \Big(\tfrac12 - \tfrac a2 - b\Big) + \tfrac12 a + b \le t + \tfrac12 t + t = \tfrac52 t,$$
so $t \ge 1/5$. $\square$

The weights $(1, \tfrac12, 1)$ form a dual certificate for the linear program. They are the coefficients with which $a$ and $b$ enter the interior.

**Corollary 3.2.** $E(a,b) \ge E_{\mathrm{rel}}(a,b) \ge 1/5$ for all $a, b$.

**Proposition 3.3 (Attainment).** $E(\tfrac15,\tfrac15) = E_{\mathrm{rel}}(\tfrac15,\tfrac15) = \tfrac15$, and all four legs equal $1/5$ there. In real-power form, for every $N > 0$,
$$\big(N/N^{1/5}\big)^{1/4} = N^{1/5}, \qquad \frac{N^{1/2}}{(N^{1/5})^{1/2}\,N^{1/5}} = N^{1/5}.$$

*Proof.* $(1-\tfrac15)/4 = \tfrac15$ and $\tfrac12 - \tfrac1{10} - \tfrac15 = \tfrac15$. In real form, $N/N^{1/5} = N^{4/5}$ and $(N^{4/5})^{1/4} = N^{1/5}$. Likewise $N^{1/2 - 1/10 - 1/5} = N^{1/5}$. $\square$

**Theorem 3.4 (Unique minimiser).** If $E(a,b) \le 1/5$ then $a = b = 1/5$. Similarly, if $E_{\mathrm{rel}}(a,b) \le 1/5$ then $a = b = 1/5$.

*Proof.* Faithful case: $(1-a)/4 \le 1/5$ gives $a \ge 1/5$, and $a \le 1/5$ gives $a = 1/5$. Then $\tfrac12 - \tfrac1{10} - b \le \tfrac15$ gives $b \ge 1/5$, and with $b \le 1/5$ we get $b = 1/5$. Relaxed case: from $a, b \le 1/5$ and $\tfrac a2 + b \ge \tfrac12 - \tfrac15 = \tfrac3{10}$, equality must hold throughout, since $\tfrac a2 + b \le \tfrac1{10} + \tfrac15 = \tfrac3{10}$. So $a = b = 1/5$. $\square$

**Remark 3.5 (The $M$-leg is a geometric mean).** For every $(a,b)$,
$$\frac{1-a}{4} = \frac12\Big[\Big(\tfrac12 - \tfrac a2 - b\Big) + b\Big],$$
that is, $(N/r)^{1/4} = \sqrt{\dfrac{N^{1/2}}{r^{1/2}m}\cdot m}$. The $M$-leg exponent is therefore the average of the interior and baby-step exponents, so it never strictly exceeds both. Hence $E(a,b) = E_{\mathrm{rel}}(a,b)$ *identically*. In the unmodified model the $M$-leg is pointwise dominated: it ties the maximum only along the segment $b = (1-a)/4$, $0 \le a \le 1/5$, and it is never the unique maximum. This is why the relaxation computes the right running time. The identity holds only for the unmodified legs. A redesign that cheapens the interior or the baby steps without cheapening the $M$-stage breaks it, and at that point the $M$-leg becomes the binding constraint. Sections 4 and 5 make this precise.

So the faithful model and its relaxation agree on the optimal value and on the unique optimal parameters. The three-leg picture gives no hint that anything is missing. The difference appears only when we ask which legs certify the value.

---

## 4. Faithful-model slackness

**Theorem 4.1 (Pair-leg core).** For all real $a$, $P(a) = \max\{(1-a)/4,\ a\} \ge 1/5$, with equality iff $a = 1/5$.

*Proof.* If $a \ge 1/5$ the second term is at least $1/5$. If $a < 1/5$ then $(1-a)/4 > (1 - 1/5)/4 = 1/5$. Equality requires $a \le 1/5$ and $(1-a)/4 \le 1/5$, so $a = 1/5$. $\square$

**Theorem 4.2 (Slackness, exponent form).** For all real $a$, $f$, $g$,
$$\max\Big\{\tfrac{1-a}{4},\ f,\ a,\ g\Big\} \ge \tfrac15 .$$
Equivalently, in the faithful model the set {interior, baby-step floor} is removable. Replacing these two legs by arbitrary values, including arbitrarily negative ones, does not lower the optimum.

*Proof.* The maximum is at least $P(a) \ge 1/5$ by Theorem 4.1. $\square$

**Theorem 4.3 (Slackness, real-power form).** For all real $N > 0$, $r > 0$ and arbitrary real $f$, $g$,
$$\max\Big\{ (N/r)^{1/4},\ f,\ r,\ g \Big\} \ \ge\ N^{1/5}.$$

*Proof.* Suppose not. Then $(N/r)^{1/4} < N^{1/5}$ and $r < N^{1/5}$. Both sides of the first inequality are positive, so raising to the fourth power gives $N/r < N^{4/5}$, that is, $N < N^{4/5} r$. Multiplying the second inequality by $N^{4/5} > 0$ gives $N^{4/5} r < N^{4/5}N^{1/5} = N$. Together these give $N < N$, a contradiction. $\square$

**Interpretation.** At Harvey's operating point all four legs are tight. But the lower bound $N^{1/5}$ needs only the $M$-leg and the pair floor. **No improvement to the interior or the baby-step leg, of any size, can move the exponent $1/5$ as long as the $M$-leg and the pair floor keep their costs.**

The three-leg relaxation is still a valid lower bound: Theorem 3.1 holds. But it is a *relaxation*. Its binding legs, interior plus baby steps plus pair floor, are not the only ones the algorithm pays for. An exchange rate between legs read off the relaxation, for example "a fourth floor of weight $w$ buys exponent $1/(5+2w)$", describes the relaxation and not the algorithm.

---

## 5. Two certificates; improvement must break both

By Theorem 3.1, {interior, pair, baby} is a certificate for $1/5$. By Theorem 4.2, {$M$, pair} is a certificate for $1/5$. Both are minimal. Deleting any one leg from either leaves a set whose exponent can be pushed below $1/5$. For example, $\{(1-a)/4\}$ alone tends to $-\infty$ as $a \to \infty$, and $\{a, b\}$ alone tends to $-\infty$ as $a, b \to -\infty$. The two minimal certificates share exactly one leg, the pair floor. We call them **Certificate A** = {$M$-leg, pair floor} and **Certificate B** = {interior, pair floor, baby-step floor}.

**Theorem 5.1 (Improvement must break both certificates).** Let $M', f, g$ be arbitrary reals, the exponents of a modified $M$-leg, a modified interior and a modified baby-step leg, and keep the pair floor at exponent $a$. If
$$\max\{M',\ f,\ a,\ g\} < \tfrac15,$$
then
1. $M' < \tfrac{1-a}{4}$, so the $M$-leg was cheapened, **and**
2. for every $b \in \mathbb R$, $f < \tfrac12 - \tfrac a2 - b$ or $g < b$, so for every baby-step budget the interior or the baby steps were cheapened.

*Proof.* From the hypothesis, $M' < 1/5$ and $a < 1/5$, so $(1-a)/4 > 1/5 > M'$. For (2), suppose that for some $b$ we had $f \ge \tfrac12 - \tfrac a2 - b$ and $g \ge b$. Then $\max\{f, a, g\} \ge E_{\mathrm{rel}}(a,b) \ge 1/5$ by Theorem 3.1, a contradiction. $\square$

**Corollary 5.2.** Improving only the $M$-leg family, or only the {interior, baby-step} family, never lowers the exponent below $1/5$.

---

## 6. Floor deletions and their penalties

*Deleting* a floor means fixing its parameter at the trivial value $1$, so its exponent is $0$, instead of tuning it.

**Proposition 6.1 (Baby-step floor deletion).** For all $a$, $E(a, 0) \ge 1/3$, and $E(\tfrac13, 0) = \tfrac13$.

*Proof.* $E(a,0) = \max\{(1-a)/4,\ a,\ 0,\ \tfrac12 - \tfrac a2\}$. If $a \ge 1/3$, the pair leg is at least $1/3$. If $a < 1/3$, the interior is $\tfrac12 - \tfrac a2 > \tfrac13$. At $a = 1/3$: $(1-\tfrac13)/4 = \tfrac16$, and the pair leg and interior both equal $\tfrac13$. $\square$

**Proposition 6.2 (Pair floor deletion).** For all $b$, $E(0,b) \ge 1/4$, and $E(0,\tfrac14) = \tfrac14$.

*Proof.* With $a = 0$ the $M$-leg is $1/4$. At $b = 1/4$ the remaining legs are $0, \tfrac14, \tfrac14$. $\square$

**Corollary 6.3 (Attribution).** The deletion penalties are
$$\tfrac13 - \tfrac15 = \tfrac{2}{15}\quad\text{(baby-step floor)}, \qquad \tfrac14 - \tfrac15 = \tfrac{1}{20}\quad\text{(pair floor)}.$$
So a slowdown of $N^{1/20}$ comes from deleting the **pair floor**, which returns the algorithm to the Pollard–Strassen exponent $1/4$. Deleting the baby-step floor costs $N^{2/15}$. An earlier attribution of $N^{1/20}$ to the baby-step deletion mixed up the two.

---

## 7. The fourth-floor lever: real in the relaxation, blocked in the faithful model

**Theorem 7.1 (Fourth floor in the relaxation).** For every weight $w \ge 0$,
$$\min_{a,b,c} E^{(4)}_{\mathrm{rel}}(a,b,c;w) = \frac{1}{5+2w},$$
attained at $a = b = c = 1/(5+2w)$. In particular $w = 1/2$ gives $1/6$ and $w = 1$ gives $1/7$.

*Proof.* Let $t = E^{(4)}_{\mathrm{rel}}$. As in Theorem 3.1, using $a, b, c \le t$ and $w \ge 0$,
$$\tfrac12 = \Big(\tfrac12 - \tfrac a2 - b - wc\Big) + \tfrac12 a + b + wc \le t\big(1 + \tfrac12 + 1 + w\big) = t\cdot\tfrac{5+2w}{2}.$$
At $a = b = c = t = 1/(5+2w)$ the interior equals $\tfrac12 - t(\tfrac32 + w) = t$. $\square$

In general, if the legs entering the interior carry total weight $\Sigma w$ (with $\tfrac12$ from $r$ and $1$ from $m$), the relaxed optimum is $1/(2 + 2\Sigma w)$. Harvey's $\Sigma w = 3/2$ gives $1/5$.

**Theorem 7.2 (The lever is blocked in the faithful model).** For every $w$ (of any sign) and all $a, b, c$,
$$E^{(4)}(a,b,c;w) \ge \tfrac15 .$$

*Proof.* $E^{(4)} \ge \max\{(1-a)/4,\ a\} = P(a) \ge 1/5$ by Theorem 4.1. The new floor does not enter the $M$-leg. $\square$

So the "fourth floor" lever is a property of the relaxation. In the faithful model it needs a partner that acts on Certificate A (Section 9).

---

## 8. Generalised $M$-legs and the independent certificate law

**Proposition 8.1 ($M$-leg/pair optimum).** For $\mu > 0$ and all real $a$,
$$\max\{\mu(1-a),\ a\} \ge \frac{\mu}{1+\mu},$$
with equality at $a = \mu/(1+\mu)$.

*Proof.* The key identity is $\mu\big(1 - \tfrac{\mu}{1+\mu}\big) = \tfrac{\mu}{1+\mu}$. If $a \ge \mu/(1+\mu)$ the second term suffices. Otherwise $\mu(1-a) \ge \mu(1 - \tfrac{\mu}{1+\mu}) = \tfrac{\mu}{1+\mu}$ because $\mu > 0$. $\square$

**Corollary 8.2.** Harvey's $\mu = 1/4$ gives $\tfrac{1/4}{5/4} = \tfrac15$. If $\max\{\mu(1-a), a\} \le 1/6$ for some $a$, then $\mu \le 1/5$.

*Proof.* $\tfrac{\mu}{1+\mu} \le \tfrac16$ iff $6\mu \le 1 + \mu$ iff $\mu \le \tfrac15$. $\square$

**Lemma 8.3 (Interior-triple bound).** For $\alpha \ge 0$ and all real $\gamma, a, b$,
$$\max\{\gamma - \alpha a - b,\ a,\ b\} \ge \frac{\gamma}{2+\alpha}.$$

*Proof.* Let $t$ be the maximum. Then $\gamma = (\gamma - \alpha a - b) + \alpha a + b \le t + \alpha t + t$, using $\alpha \ge 0$ for $\alpha a \le \alpha t$. Divide by $2 + \alpha > 0$. $\square$

**Theorem 8.4 (Independent certificate law).** For $\mu > 0$, $\alpha \ge 0$ and real $\gamma$,
$$\min_{a,b}\ G_{\mu,\gamma,\alpha}(a,b) \;=\; \max\Big( \frac{\mu}{1+\mu},\ \frac{\gamma}{2+\alpha} \Big),$$
and the minimum is attained at $a = b = t^\ast$, where $t^\ast$ is the right-hand side.

*Proof.* Lower bound: $G \ge \max\{\mu(1-a), a\} \ge \mu/(1+\mu)$ by Proposition 8.1, and $G \ge \max\{\gamma - \alpha a - b, a, b\} \ge \gamma/(2+\alpha)$ by Lemma 8.3. Attainment: put $a = b = t^\ast$. Then $\mu \le t^\ast(1+\mu)$ gives $\mu(1 - t^\ast) \le t^\ast$, and $\gamma \le t^\ast(2+\alpha)$ gives $\gamma - \alpha t^\ast - t^\ast \le t^\ast$. The remaining two legs equal $t^\ast$. $\square$

**Interpretation.** The two certificates do not interact. The optimum is the larger of the value forced by Certificate A and the value forced by Certificate B. For Harvey's parameters both equal $1/5$:
$$\frac{1/4}{1 + 1/4} = \frac15 = \frac{1/2}{2 + 1/2}.$$
This coincidence explains why all four legs tie at the optimum. It also explains Theorem 5.1: lowering the smaller of two numbers does not lower their maximum.

---

## 9. Coupling the $M$-leg to the baby steps: a sharp threshold

Suppose the $M$-stage could reuse the baby-step table so that its cost becomes $(N/r)^{1/4}/m^{\theta}$ for some $\theta \ge 0$. Its exponent is then $\tfrac{1-a}{4} - \theta b$.

**Theorem 9.1 (Coupling alone is useless).** For all $\theta$, $a$, $b$,
$$\max\Big\{\tfrac{1-a}{4} - \theta b,\ E_{\mathrm{rel}}(a,b)\Big\} \ge \tfrac15.$$

*Proof.* Certificate B is untouched: the maximum is at least $E_{\mathrm{rel}}(a,b) \ge 1/5$ by Theorem 3.1. $\square$

**Theorem 9.2 (Coupled fourth-floor threshold).** With a fourth floor of weight $\tfrac12$:

1. for all $\theta, a, b, c$: $E^{(4)}_\theta(a,b,c;\tfrac12) \ge \tfrac16$;
2. there exist $a, b, c$ with $E^{(4)}_\theta(a,b,c;\tfrac12) \le \tfrac16$ **if and only if** $\theta \ge \tfrac14$. In that case $a = b = c = \tfrac16$ attains the value $\tfrac16$.

*Proof.* (1) follows from Theorem 7.1 with $w = 1/2$. For (2), suppose the cost is at most $1/6$. Then $a, b, c \le 1/6$ and $\tfrac a2 + b + \tfrac c2 \ge \tfrac12 - \tfrac16 = \tfrac13$. Since the left side is at most $\tfrac1{12} + \tfrac16 + \tfrac1{12} = \tfrac13$, we get $a = b = c = \tfrac16$. The coupled $M$-leg is then $\tfrac{5/6}{4} - \tfrac{\theta}{6} = \tfrac{5}{24} - \tfrac\theta6$, and $\tfrac5{24} - \tfrac\theta6 \le \tfrac16 = \tfrac4{24}$ iff $\theta \ge \tfrac14$. Conversely, if $\theta \ge 1/4$, the point $a = b = c = 1/6$ has all relaxed legs equal to $1/6$ and $M$-leg at most $1/6$. $\square$

For intermediate couplings the exponent varies continuously between $1/5$ and $1/6$. For example, exact linear programming gives $2/11$ at $\theta = 1/8$ and $5/29$ at $\theta = 1/5$.

**Remark.** A tempting guess is that the coupled model goes below $1/5$ for every $\theta > 0$. That is false without a new floor, by Theorem 9.1, because Certificate B still forces $1/5$. The correct statement is the two-requirement criterion of Theorem 9.2: a new floor of weight $\tfrac12$ **and** coupling strength $\theta \ge \tfrac14$.

---

## 10. The partition lemma for multi-level baby-step structures

A natural variation splits the baby-step/giant-step search into several levels. The following lemma rules this out for any search with product-form costs.

**Theorem 10.1 (Partition lemma).** Let $S_1, \dots, S_k \ge 0$ with $S = \sum_i S_i$, and let $L_i, T_i \ge 0$ satisfy $L_iT_i \ge S_i$. Then
$$\sum_{i=1}^k L_i + \sum_{i=1}^k T_i \ \ge\ 2\sqrt{S}.$$

*Proof.* We show the squared form $4S \le \big(\sum_i (L_i + T_i)\big)^2$ by induction on $k$. The case $k = 0$ is trivial. For the inductive step, with $U = \sum_{i<k}(L_i+T_i) \ge 0$,
$$(L_k + T_k + U)^2 = (L_k + T_k)^2 + 2(L_k+T_k)U + U^2 \ge 4L_kT_k + U^2 \ge 4S_k + 4\textstyle\sum_{i<k}S_i ,$$
using $(L_k + T_k)^2 - 4L_kT_k = (L_k - T_k)^2 \ge 0$ and $(L_k+T_k)U \ge 0$. Taking square roots of nonnegative quantities gives the claim. $\square$

**Theorem 10.2 (Strict partition lemma).** If, in addition, two distinct levels $i \ne j$ have $S_i > 0$ and $S_j > 0$, the inequality is strict:
$$\sum_i L_i + \sum_i T_i > 2\sqrt S.$$

*Proof.* $S_i > 0$ forces $L_i + T_i > 0$, since otherwise $L_i = 0$ and $L_iT_i = 0 < S_i$. The same holds for $j$. Expanding the square of the total cost as above, the cross term $2(L_i + T_i)(L_j + T_j)$ is strictly positive, and all other terms are bounded as before. So $(\text{total})^2 > 4S$. $\square$

Hence equality forces a single level to carry the whole pool, with $L = T = \sqrt S$ there.

**Proposition 10.3 (Uniform split penalty).** For $S \ge 0$ and $k \ge 1$, the uniform split $S_i = S/k$, $L_i = T_i = \sqrt{S/k}$ costs
$$k \cdot 2\sqrt{S/k} = \sqrt k \cdot 2\sqrt S,$$
a multiplicative penalty of exactly $\sqrt k$ over the single-level optimum.

*Proof.* $k\sqrt{S/k} = k\sqrt S/\sqrt k = \sqrt k\sqrt S$. $\square$

**Consequence.** Variable-step and two-level baby-step/giant-step schemes over a fixed pool cannot beat the single-level cost. The penalty is strict, and for uniform splits it is exactly $\sqrt k$. A related consequence: in the interior leg, the product $m \cdot N^{1/2}/(r^{1/2}m) = N^{1/2}r^{-1/2}$ does not depend on $m$. Re-splitting the work between baby and giant steps changes only how the cost is distributed, never the product, so by the AM–GM inequality no re-split beats the balanced one.

---

## 11. Computational procedures

The examples accompanying this paper use two simple exact procedures.

### 11.1 Exact min–max exponent by vertex enumeration

Given affine legs $\ell_j(x) = c_j + \langle d_j, x\rangle$ in variables $x \in \mathbb R^n$ ($n = 2$ or $3$), restricted to a box $[\mathrm{lo},\mathrm{hi}]^n$, we solve
$$\min\ t \quad\text{subject to}\quad t \ge \ell_j(x)\ \ \forall j,\qquad \mathrm{lo} \le x_i \le \mathrm{hi}.$$
The feasible region is a polyhedron in $\mathbb R^{n+1}$ and the objective is bounded below on it, so an optimum is attained at a vertex. A vertex is a point where $n+1$ linearly independent constraints are tight.

**Algorithm.**
1. List all constraints as rows $\langle \rho, (x,t)\rangle \ge \beta$.
2. For every subset of $n+1$ rows, solve the square linear system exactly over $\mathbb Q$ by Gaussian elimination. Skip singular systems.
3. Keep solutions satisfying all constraints. Return the one with the smallest $t$.

With $K$ constraints the cost is $\binom{K}{n+1}$ exact solves of size $n+1$. For the models here ($K \le 11$, $n \le 3$) that is at most $330$ solves. Exact rational arithmetic reproduces $1/5$, $1/6$, $1/3$, $1/4$, $2/11$ and $5/29$ exactly.

### 11.2 Certificate extraction

To find the minimal certificates of a model, enumerate the subsets $\mathcal C$ of legs in increasing size. Compute the optimum of $\mathcal C$ alone with 11.1, and call $\mathcal C$ a minimal certificate if it reproduces the full optimum and contains no previously found certificate. For the faithful model this procedure returns exactly {$M$, pair} and {interior, pair, baby}, matching Section 5.

---

## 12. Discussion

**Status of the results.** All statements are theorems about an *assumed* cost shape. They concern the leg structure $\max\{(N/r)^{1/4}, N^{1/2}/(r^{1/2}m), r, m\}$ and its generalisations, up to logarithmic factors. They do not derive that shape from the algorithm, and they say nothing about lower bounds for factoring in general. $N^{1/5}$ is an upper bound, attained by an algorithm. The results constrain *proposals* to improve that algorithm within its own design.

**What the results rule out.**
- *Cheapening the baby-step table.* Fast batched evaluation of the baby-step list cannot help, because the leg is slack (Theorem 4.2). In fact the baby-step stage already builds a polynomial by a product tree and evaluates it at the $m$ points with a Bluestein-type chirp transform. The fast-evaluation idea is already part of the algorithm.
- *Restructuring the interior.* Any re-split of baby versus giant work, and any multi-level schedule, is at best neutral (Section 10), and the interior is slack anyway.
- *A fourth floor alone.* It is blocked by Certificate A (Theorem 7.2).
- *Coupling alone.* It is blocked by Certificate B (Theorem 9.1).

**What remains open.** By the independent certificate law, an improvement to exponent $E$ must push *both* $\mu/(1+\mu)$ and the interior certificate below $E$. Within the coupled family, $1/6$ needs exactly a weight-$\tfrac12$ new floor *and* an $M$-leg coupling with $\theta \ge 1/4$ (Theorem 9.2). Because the threshold is sharp, a candidate mechanism can be accepted or rejected by computing one exponent.

**A methodological point.** The three-leg relaxation reproduces the correct optimum and the correct unique minimiser. Even so, its account of which legs bind is wrong for the algorithm. Matching the optimum of a cost model does not certify its binding structure. To see where an improvement must act, one needs the model of every step the algorithm pays for, together with the minimal certificates of that model.

**A logarithmic remark (empirical, not used).** Numerical experiments suggest that the bit-lengths $c_{a,b}$ of the exponents needed in the pair family satisfy $c_{2a,2b} = 2c_{a,b} + \delta$ with $\delta \in \{0, 1\}$. This was observed with no violations in several thousand trials up to $300$ bits. If true, the pair family needs $O(r)$ rather than $O(r\log r)$ modular exponentiations. A logarithmic saving on the pair leg does not change the exponent of $N$, and nothing in this paper depends on it.

---

## 13. Future directions

1. **An algorithmic mechanism for a coupled $M$-leg.** Conjecture: the $M$-stage, which computes with $\lceil (N/r)^{1/2}\rceil$ terms at cost $(N/r)^{1/4}$, can be arranged to reuse the $m$ baby steps so that its cost becomes $(N/r)^{1/4}/m^\theta$ with $\theta \ge 1/4$. Together with a weight-$\tfrac12$ new floor this would give exponent $1/6$ in the model (Theorem 9.2).
2. **Real-power certificate law.** For real $N > 1$, $\mu > 0$, $\alpha \ge 0$: $\inf_{r,m>0}\max\{(N/r)^\mu, N^\gamma/(r^\alpha m), r, m\} = N^{\max(\mu/(1+\mu),\,\gamma/(2+\alpha))}$, attained. The argument of Theorem 4.3 lifts Certificate A to real powers, and Certificate B lifts the same way.
3. **Weighted partition lemma.** If level $i$ costs $c_i(L_i + T_i)$ with $c_i > 0$ and $L_iT_i \ge S_i$, the total cost is at least $2(\min_i c_i)\sqrt S$, with equality only if the whole pool sits on a cheapest level.
4. **Deriving the cost shape.** Every statement here is conditional on the leg structure. The main open task is to derive the leg exponents $(\mu,\gamma,\alpha) = (\tfrac14,\tfrac12,\tfrac12)$, and the possible values of a coupling $\theta$ or a new-floor weight $w$, from an explicit algorithm.

---

## References

1. D. Harvey, *An exponent one-fifth algorithm for deterministic integer factorisation*, Mathematics of Computation **90** (2021).
2. R. S. Lehman, *Factoring large integers*, Mathematics of Computation **28** (1974), 637–646.
3. J. M. Pollard, *Theorems on factorization and primality testing*, Proceedings of the Cambridge Philosophical Society **76** (1974), 521–528.
4. V. Strassen, *Einige Resultate über Berechnungskomplexität*, Jahresbericht der DMV **78** (1976), 1–8.
5. D. Shanks, *Class number, a theory of factorization, and genera*, Proc. Symp. Pure Math. **20** (1971), 415–440.
6. L. I. Bluestein, *A linear filtering approach to the computation of discrete Fourier transform*, IEEE Trans. Audio Electroacoustics **18** (1970), 451–455.
