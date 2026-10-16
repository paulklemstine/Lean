# Which Terms Carry the Exponent? The Delete-a-Term Screen, the Redundant Smoothness Leg, and the Load-Bearing Baby-Step Reuse in Harvey's $N^{1/5}$ Balance

**Aristotle**

*October 2026*

---

## Abstract

Harvey's deterministic factoring algorithm runs in time $N^{1/5+o(1)}$. With logarithmic factors dropped, its running time is the maximum of three power-of-$N$ costs, and the exponent $1/5$ is the value of the linear minimax $\min_{a,b}\max\{a,\ b,\ \tfrac12-\tfrac a2-b\}$, where $r=N^a$ is the size of a pair family and $m=N^b$ the length of a baby-step list. A fourth cost, a smoothness-sieve term $(N/r)^{1/4}$, appears in a refined accounting and is large in practice. We study the question *which terms of such a balance actually carry the exponent*, and prove the following.

1. **The delete-a-term screen.** For any parameter space and any family of terms, a value bound survives every modification of one term, including deleting it or making it free, if and only if it already holds for the remaining terms alone. So a term is worth optimising if and only if deleting it changes the minimax value.
2. **The smoothness leg is exponent-redundant.** With a leg $(N/r)^{\theta}$ the value is exactly $V(\theta)=\max\{1/5,\ \theta/(1+\theta)\}$. The actual leg $\theta=1/4$ sits exactly on the breakpoint. It is active at the unique optimum, yet deleting it or making it free leaves the value at $1/5$. For $\theta>1/4$, no parameter choice reaches $1/5$.
3. **Exactly three of the four terms are load-bearing.** Deleting the interior, the pair term, or the baby-step term from the three-term core drops the value from $1/5$ to $0$.
4. **The baby-step reuse is load-bearing.** Without the split ($m=1$) the value is Lehman's $1/3$. Every unbalanced split $b\ne 1/5$ costs strictly more than $1/5$. A "collapse" coupling that sweeps the pair grid and the interior with a single product tree has value exactly $1/4$, a penalty of exactly $N^{1/20}$. A ground-truth implementation of the collapse coupling reports a fitted penalty slope of $0.046$–$0.052$ against $1/20=0.050$.
5. **Pricing the untouched lever.** An $m^{1-\varepsilon}$ baby-step table would give exponent exactly $(1-\varepsilon)/(5-3\varepsilon)<1/5$. An interior gain $N^{-\delta}$ gives exactly $(1-2\delta)/5$. The two levers trade at the rate $\delta=\varepsilon/(5-3\varepsilon)$. A previously proposed target $N^{(1/2-\delta)/5}$ is wrong by a factor of two.

Separately, we prove a **general-exponent reveal identity**: for $N=pq$ and every exponent $E$, the number of units $a$ for which $\gcd(a^E-1,N)$ is a proper factor is $R(E)=d_p(q-1)+d_q(p-1)-2d_pd_q$, where $d_p=\gcd(E,p-1)$ and $d_q=\gcd(E,q-1)$. We also show that the maximal-density case $(p-1)\mid(q-1)$, where the reveal density is $1-1/k$, is factored by a single integer square root, because the associated quadratic has an exactly square discriminant. None of this improves the exponent $1/5$, which remains an upper bound. No unconditional superpolynomial lower bound for factoring is known.

---

## 1. Introduction

### 1.1 The deterministic factoring exponent

Let $N$ be a positive integer. A *deterministic* factoring algorithm is one that uses neither randomness nor unproved hypotheses. The best known running times for such algorithms have the form $N^{e+o(1)}$. Trial division gives $e=1/2$. Lehman's method gives $e=1/3$. The Pollard–Strassen method, which evaluates a product of consecutive integers with fast polynomial multiplication and multipoint evaluation, gives $e=1/4$. Harvey (2021) lowered the exponent to $e=1/5$, combining a Lehman-style family of candidate pairs with a baby-step giant-step search.

These are upper bounds. No superpolynomial lower bound for factoring is known in any general model of computation. Results that *rule out* proposed improvements are therefore not lower bounds on factoring. They are statements about the structure of a particular family of algorithms. The purpose of such statements is to stop effort being spent on terms that cannot move the exponent, and to point it at terms that can.

### 1.2 The exponent model

Throughout, we write $r=N^a$ and $m=N^b$ and drop all factors polylogarithmic in $N$. In this model Harvey's algorithm has three costs:

| term | meaning | cost | exponent |
|---|---|---|---|
| pair family | candidate pairs enumerated | $r$ | $a$ |
| baby-step list | stored powers $\alpha^0,\dots,\alpha^{m-1}$ | $m$ | $b$ |
| interior | remaining giant-step search | $N^{1/2}/(r^{1/2}m)$ | $\tfrac12-\tfrac a2-b$ |

The total exponent is

$$c(a,b)\;=\;\max\Big\{a,\ b,\ \tfrac12-\tfrac a2-b\Big\}. \tag{1}$$

A refined accounting adds a smoothness-sieve term $M^{1/2}=(N/r)^{1/4}$, of exponent $\tfrac14(1-a)$. We call it the *M-leg*. At realistic sizes ($N\approx 2^{100}$), once polylogarithmic weights are included, it was estimated to take about one quarter of the total budget. An earlier analysis listed it as one of three co-leading terms.

### 1.3 Questions and answers

We ask three questions.

* **Q1.** Is the M-leg a genuine constraint on the exponent?
* **Q2.** Is the reuse of the baby-step list, which is a "zero-sum trade in $m$" between list length and interior size, essential? Or is it slack that a different organisation could remove?
* **Q3.** Is there a cheap, general test that answers questions like Q1 before a research effort is committed?

The answers are: Q1, no (Theorem 3.1); Q2, yes, by exactly $N^{1/20}$ against the natural alternative (Theorems 5.1–5.4); Q3, yes, the delete-a-term screen (Theorem 2.2). Section 7 adds an independent counting result about gcd-based factor revelation, valid for arbitrary exponents.

---

## 2. Minimax values and the delete-a-term screen

### 2.1 Definitions

Let $X$ be any set (the parameter space) and $F:X\to\mathbb{Q}$ any function.

**Definition 2.1.** A number $c$ is a *minimax lower bound* for $F$ if $c\le F(x)$ for all $x\in X$. A number $v$ is the *minimax value* of $F$ if it is a minimax lower bound and is attained, i.e. $F(x_0)=v$ for some $x_0\in X$.

The minimax value is unique when it exists. If $v$ and $w$ are both values, attained at $x$ and $y$, then $v\le F(y)=w$ and $w\le F(x)=v$.

In all our applications $F$ is a pointwise maximum $F(x)=\max_i T_i(x)$ of finitely many *terms*, each affine in the parameters. Computing the value is then a small linear program: minimise $t$ subject to $t\ge T_i(x)$.

### 2.2 The screen

**Theorem 2.2 (Delete-a-term screen).** Let $F':X\to\mathbb{Q}$ be the maximum of all terms except one, and let $c\in\mathbb{Q}$. Then
$$\Big(\forall\,g':X\to\mathbb{Q},\ \ c \text{ is a minimax lower bound for } \max\{F',g'\}\Big)\iff c \text{ is a minimax lower bound for } F'.$$
Equivalently, in positive form: there is some modification $g'$ of the extra term with $\max\{F'(x),g'(x)\}<v$ at some $x$ if and only if $F'(x)<v$ at some $x$.

*Proof.* ($\Leftarrow$) Since $\max\{F',g'\}\ge F'\ge c$ pointwise, this holds for every $g'$. ($\Rightarrow$) Take $g'=F'$. Then $\max\{F',F'\}=F'$, which is "deleting" the term. $\square$

The proof is short, but the content is a working rule.

> **Screening rule.** In a minimax cost $\max\{T_1,\dots,T_k\}$, a term is worth optimising if and only if deleting it (equivalently, making it free) moves the minimax value. A term whose deletion does not move the value is worthless to optimise, whatever its size or polylogarithmic weight.

Two companion facts make the rule easy to apply.

**Lemma 2.3 (Inert term preserves the value).** Suppose $v$ is the minimax value of $F'$, attained at $x_0$, and $g(x_0)\le v$. Then $\max\{F',g\}$ has minimax value exactly $v$.

*Proof.* $v\le F'\le\max\{F',g\}$ everywhere, and at $x_0$ we have $\max\{F'(x_0),g(x_0)\}=\max\{v,g(x_0)\}=v$. $\square$

**Lemma 2.4 (Monotonicity).** If $F'$ has value $v$ and $\max\{F',g\}$ has value $w$, then $v\le w$.

*Proof.* At a point $x$ where $\max\{F'(x),g(x)\}=w$, we have $v\le F'(x)\le w$. $\square$

**Remark 2.5 (Screening is relative).** Whether a term is redundant depends on the set of terms it is compared against. Redundancy is not preserved when other terms are deleted, so one should screen one term against a fixed set, prune it if it is inert, and then screen again. Section 4 gives a concrete example.

### 2.3 The three-term balance

**Proposition 2.6 (Harvey balance).** The function $c(a,b)$ in (1), over $(a,b)\in\mathbb{Q}^2$, has minimax value exactly $1/5$. The value is attained at $(a,b)=(1/5,1/5)$, and *only* there: if $c(a,b)\le 1/5$, then $a=b=1/5$.

*Proof.* With weights $\tfrac15,\tfrac25,\tfrac25$,
$$\tfrac15 a+\tfrac25 b+\tfrac25\Big(\tfrac12-\tfrac a2-b\Big)=\tfrac15.$$
A convex combination is at most the maximum, so $c(a,b)\ge 1/5$. At $a=b=1/5$ all three terms equal $1/5$. For uniqueness, suppose $a\le 1/5$, $b\le 1/5$ and $\tfrac12-\tfrac a2-b\le 1/5$. Then $\tfrac a2+b\ge\tfrac3{10}$, and with $a,b\le\tfrac15$ this forces $a=b=\tfrac15$. $\square$

---

## 3. The M-leg is exponent-redundant

For a smoothness exponent $\theta\ge0$, define the four-term cost
$$c_\theta(a,b)=\max\big\{c(a,b),\ \theta(1-a)\big\}.$$
The M-leg of the refined accounting is $\theta=1/4$. The value $\theta=0$ corresponds to a leg that is *completely free* (constant cost).

**Theorem 3.1 (Redundancy of the M-leg).** For every $\theta\le 1/4$, the minimax value of $c_\theta$ is exactly $1/5$. In particular this holds for the actual leg $\theta=1/4$ and for the free leg $\theta=0$, and it agrees with the value when the leg is deleted (Proposition 2.6).

*Proof.* Apply Lemma 2.3 with $F'=c$, $v=1/5$, $x_0=(1/5,1/5)$. We need $\theta(1-\tfrac15)=\tfrac45\theta\le\tfrac15$, which holds exactly when $\theta\le\tfrac14$. $\square$

**Theorem 3.2 (Value above the breakpoint).** For every $\theta\ge 1/4$, the minimax value of $c_\theta$ is exactly $\theta/(1+\theta)$. It is attained at $a=\theta/(1+\theta)$, $b=(1-a)/4$.

*Proof.* *Lower bound.* Let $v=c_\theta(a,b)$. Then $a\le v$ and $\theta(1-a)\le v$. Multiply the first by $\theta$ and add the second: $\theta\le(1+\theta)v$. *Attainment.* At $a=\theta/(1+\theta)$ we have $1-a=1/(1+\theta)$, so $\theta(1-a)=\theta/(1+\theta)=a$. With $b=(1-a)/4$ the interior is $\tfrac12-\tfrac a2-\tfrac{1-a}4=\tfrac{1-a}4=b$. Finally $b\le a$ is equivalent to $1\le 5a$, i.e. $5\theta\ge1+\theta$, i.e. $\theta\ge\tfrac14$. So the maximum is $a=\theta/(1+\theta)$. $\square$

**Corollary 3.3 (Value function).** For all $\theta\ge0$,
$$V(\theta)\;=\;\max\Big\{\tfrac15,\ \tfrac{\theta}{1+\theta}\Big\}.$$
$V$ is constant on $[0,1/4]$ and strictly increasing on $[1/4,\infty)$. The breakpoint is exactly $\theta=1/4$.

**Theorem 3.4 (Strict breakpoint).** If $\theta>1/4$, then $c_\theta(a,b)>1/5$ for every $(a,b)$.

*Proof.* If $c_\theta(a,b)\le 1/5$, then $c(a,b)\le1/5$, so $a=1/5$ by uniqueness (Proposition 2.6). Then $\theta(1-a)=\tfrac45\theta>\tfrac15$, a contradiction. $\square$

**Theorem 3.5 (The real leg is co-tight).** At the unique optimum of $c$, the actual leg has exponent $\tfrac14(1-\tfrac15)=\tfrac15$. More precisely, $c(a,b)=1/5$ implies $\tfrac14(1-a)=1/5$.

So the real M-leg is *active* at the optimum (it attains the maximum) and yet *redundant* (deleting it does not change the value). It sits exactly on the breakpoint of $V$. This illustrates the main lesson of the section in its strongest form: neither size nor tightness implies leverage.

---

## 4. Exactly three terms are load-bearing

Restrict the parameters to the natural box $0\le a\le1$, $0\le b\le1$, i.e. $1\le r,m\le N$.

**Theorem 4.1 (Load-bearing classification).** On the box:

1. Deleting the interior: $\max\{a,b\}$ has value $0$, attained at $(0,0)$.
2. Deleting the pair term: $\max\{b,\ \tfrac12-\tfrac a2-b\}$ has value $0$, attained at $(1,0)$.
3. Deleting the baby-step term: $\max\{a,\ \tfrac12-\tfrac a2-b\}$ has value $0$, attained at $(0,\tfrac12)$.
4. For *every* replacement $g'$ of a fourth term, $\max\{c(a,b),g'(a,b)\}\ge1/5$.

Both the three-term and the four-term ($\theta=1/4$) costs have value $1/5$ on the box.

*Proof.* Items 1–3: every term is non-negative on the box, and each displayed point makes the remaining terms vanish. For example, in item 3, $a=0$ and $\tfrac12-0-\tfrac12=0$. Item 4 is Theorem 2.2 applied to Proposition 2.6. The box values follow because $(1/5,1/5)$ lies in the box. $\square$

By the screening rule, **exactly three of the four terms carry the exponent**: the interior, the pair family and the baby-step list. The M-leg is a co-leader only by polylogarithmic weight, not by exponent. This corrects the earlier description of it as one of "three co-leaders".

**Remark 4.2 (An instance of Remark 2.5).** If the M-leg is kept and the interior is deleted, the value on the box remains $1/5$. The cost $\max\{a,b,\tfrac14(1-a)\}$ is minimised at $a=1/5$, $b=0$. Likewise, deleting $m$ while keeping the M-leg gives $\max\{a,\tfrac12-\tfrac a2-b,\tfrac14(1-a)\}$, which is minimised at $a=\tfrac15$, $b=1$ with value $1/5$. In both cases the M-leg becomes the binding term. The classification above is therefore the result of a two-stage screen: prune the inert M-leg first, then screen the three-term core.

---

## 5. The baby-step reuse is load-bearing

### 5.1 Limits of the split

**Theorem 5.1 (No split is Lehman).** If $m=1$ ($b=0$), then $c(a,0)\ge1/3$ for every $a$, with equality at $a=1/3$.

*Proof.* $c(a,0)\ge\max\{a,\tfrac12-\tfrac a2\}$. If $a\le\tfrac13$, the second term is at least $\tfrac13$. Otherwise the first is. At $a=\tfrac13$ both equal $\tfrac13$. $\square$

So without the baby-step list the balance falls back to Lehman's exponent.

**Theorem 5.2 (The split must be exactly balanced).** If $b\ne1/5$, then $c(a,b)>1/5$ for every $a$.

*Proof.* We always have $c\ge1/5$. Equality forces $b=1/5$ by uniqueness. $\square$

### 5.2 The collapse coupling

Consider a natural alternative that removes the baby-step split. One Strassen-type product tree sweeps the pair grid and the interior together. Such a tree evaluates a search space of size $S$ in time $S^{1/2}$ up to logarithms. Here the joint space has size $r\cdot N^{1/2}/r^{1/2}=N^{1/2}r^{1/2}$, so the sweep has exponent $\tfrac14+\tfrac a4$. Alongside the pair enumeration $a$, the cost is
$$c_{\mathrm{col}}(a)=\max\Big\{a,\ \tfrac14+\tfrac a4\Big\},\qquad a\ge0.$$

**Theorem 5.3 (Collapse value).** Over $a\ge0$, $c_{\mathrm{col}}$ has minimax value exactly $1/4$, attained at $a=0$.

*Proof.* $c_{\mathrm{col}}(a)\ge\tfrac14+\tfrac a4\ge\tfrac14$, with equality at $a=0$. $\square$

**Theorem 5.4 (The penalty is exactly $1/20$).** If $v$ is the value of $c_{\mathrm{col}}$ and $w$ the value of $c$, then $v-w=\tfrac14-\tfrac15=\tfrac1{20}$.

Removing the baby-step split deletes the $m$ term and turns a three-term balance into a two-term balance. The exponent rises by exactly $1/20$.

### 5.3 Experimental confirmation

The collapse coupling was implemented as a complete factoring pipeline, using genuine number-theoretic-transform product trees and remainder-tree multipoint evaluation, and its output was checked against ground-truth factorisations. We report the outcome as experimental data.

* The mechanism is a **correct** factoring algorithm.
* Its dominant input-size exponent is $0.2500$, not $\le0.20$.
* The fitted penalty slope against the $1/5$ balance is $0.046$–$0.052$, against the exact model value $1/20=0.0500$.

The fit also refutes a table of large constant factors (a constant of "256") that had been proposed in support of the coupling. Together, Theorems 5.1–5.4 and the experiment establish that **the $m$-reuse is load-bearing, not slack**.

---

## 6. Pricing the remaining lever

The screen says the baby-step term is worth attacking, because deleting it moves the value. The model also computes *how much* any attack would be worth.

**Theorem 6.1 (Baby-step discount).** For $0\le\varepsilon<1$, let
$$c^{\varepsilon}(a,b)=\max\big\{a,\ (1-\varepsilon)b,\ \tfrac12-\tfrac a2-b\big\},$$
the balance with the baby-step list built in $m^{1-\varepsilon}$. Its minimax value is exactly
$$\frac{1-\varepsilon}{5-3\varepsilon},$$
attained at $a=\frac{1-\varepsilon}{5-3\varepsilon}$, $b=\frac{1}{5-3\varepsilon}$. For $0<\varepsilon<1$ this is strictly less than $1/5$.

*Proof.* Let $v=c^\varepsilon(a,b)$. Use the weighted combination
$$(1-\varepsilon)\cdot a\;+\;2\cdot(1-\varepsilon)b\;+\;2(1-\varepsilon)\cdot\Big(\tfrac12-\tfrac a2-b\Big)=1-\varepsilon,$$
whose weights sum to $(1-\varepsilon)+2+2(1-\varepsilon)=5-3\varepsilon$. Hence $(5-3\varepsilon)v\ge1-\varepsilon$. At the displayed point all three terms equal $\frac{1-\varepsilon}{5-3\varepsilon}$. Strictness: $5(1-\varepsilon)<5-3\varepsilon$ if and only if $\varepsilon>0$. $\square$

**Theorem 6.2 (Interior gain).** Shrinking the interior to $N^{1/2-\delta}/(r^{1/2}m)$ gives
$$\min_{a,b}\max\big\{a,\ b,\ \tfrac12-\delta-\tfrac a2-b\big\}=\frac{1-2\delta}{5},$$
attained at $a=b=(1-2\delta)/5$.

*Proof.* The same weights $\tfrac15,\tfrac25,\tfrac25$ give $\tfrac15(1-2\delta)$. All three terms are equal at the displayed point. $\square$

**Corollary 6.3 (A misstated target).** The previously proposed target $T=N^{(1/2-\delta)/5}$ is off by a factor of two. The correct value is $(1-2\delta)/5=2\cdot\frac{1/2-\delta}{5}$, and the two agree only at $\delta=1/2$. At $\delta=0$ the misstated formula would claim $1/10$, below the proven floor $1/5$ of the model.

**Theorem 6.4 (Exchange rate of the two levers).** For $\varepsilon<1$,
$$\frac{1-2\,\frac{\varepsilon}{5-3\varepsilon}}{5}=\frac{1-\varepsilon}{5-3\varepsilon}.$$
So a baby-step discount $\varepsilon$ is worth exactly an interior gain $\delta=\varepsilon/(5-3\varepsilon)$.

*Proof.* The left side equals $\frac{5-3\varepsilon-2\varepsilon}{5(5-3\varepsilon)}=\frac{5(1-\varepsilon)}{5(5-3\varepsilon)}$. $\square$

For example, $\varepsilon=\tfrac14$ gives exponent $3/17\approx0.1765$, the same as an interior gain $\delta=1/17$. $\varepsilon=\tfrac12$ gives $1/7$.

---

## 7. The general-exponent reveal identity

We now turn to a classical revelation mechanism. Let $N=pq$ with $p\ne q$ odd primes, and identify $(\mathbb{Z}/N)^\times\cong(\mathbb{Z}/p)^\times\times(\mathbb{Z}/q)^\times$ by the Chinese remainder theorem. For an exponent $E\ge0$ and a unit $a\leftrightarrow(v_1,v_2)$, the quantity $\gcd(a^E-1,N)$ is a *proper* factor of $N$ exactly when one of $v_1^E=1$, $v_2^E=1$ holds and the other fails.

**Definition 7.1.** $d_p=\gcd(E,p-1)$, $d_q=\gcd(E,q-1)$, and $R(E)$ is the number of units with exactly one of $v_1^E=1$, $v_2^E=1$.

**Lemma 7.2.** In the cyclic group $(\mathbb{Z}/p)^\times$ of order $p-1$, the equation $x^E=1$ has exactly $\gcd(E,p-1)$ solutions.

*Proof.* With a generator $h$, $h^j$ solves $x^E=1$ iff $(p-1)\mid jE$ iff $\frac{p-1}{\gcd(E,p-1)}\mid j$, which has $\gcd(E,p-1)$ solutions $j\in[0,p-2]$. $\square$

**Theorem 7.3 (Component counts).** For every $E$:
* $\#\{v: v_1^E=1\}=d_p(q-1)$;
* $\#\{v: v_1^E=1,\ v_2^E=1\}=d_pd_q$;
* $\#\{v: v_1^E=1,\ v_2^E\ne1\}=d_p(q-1)-d_pd_q$;
* $\#\{v: v_2^E=1,\ v_1^E\ne1\}=d_q(p-1)-d_pd_q$.

*Proof.* The first two counts follow from the product decomposition and Lemma 7.2. Each of the last two is the first-type count minus the "both" count. $\square$

**Theorem 7.4 (General-exponent reveal identity).** For every exponent $E$,
$$R(E)=d_p\,(q-1)+d_q\,(p-1)-2\,d_p\,d_q.$$

*Proof.* Add the last two counts of Theorem 7.3. The subtractions are legitimate because $d_q\le q-1$ and $d_p\le p-1$. $\square$

**Corollary 7.5 (Recovery of the Euler-gap law).** At $E=N-1=pq-1$, since $pq-1\equiv q-1\pmod{p-1}$ and $pq-1\equiv p-1\pmod{q-1}$, both gcds equal the *Euler gap* $g=\gcd(p-1,q-1)$, and
$$R(N-1)=g(q-1)+g(p-1)-2g^2,$$
which is the previously known count for the single exponent $N-1$.

**Proposition 7.6 (Four-cell partition).** Write $P=p-1$, $Q=q-1$, $x=d_p\le P$, $y=d_q\le Q$. Then
$$\underbrace{xy}_{\text{both}}+\underbrace{(xQ+yP-2xy)}_{\text{exactly one}}+\underbrace{(P-x)(Q-y)}_{\text{neither}}=PQ.$$

*Proof.* Write $P=x+s$, $Q=y+t$. The middle term equals $xt+ys$, and $xy+xt+ys+st=(x+s)(y+t)$. $\square$

The partition shows how to make $R(E)$ large. One wants one of $d_p, d_q$ "full" and the other small. This is the structure behind the future directions in Section 9.

### 7.1 The maximal-density extreme is algebraically solvable

**Theorem 7.7 (Square discriminant).** For integers $p,k,s$, put $q=k(p-1)+s$ and $N=pq$. Then $kp^2+(s-k)p-N=0$, and
$$(s-k)^2+4kN=(2kp+s-k)^2.$$

*Proof.* Both are polynomial identities in $p,k,s$, verified by expansion. $\square$

**Corollary 7.8 (One integer square root).**
* ($s=1$) If $q=k(p-1)+1$ with $k,p\ge1$, then $\big\lfloor\sqrt{(k-1)^2+4kN}\big\rfloor=2kp-(k-1)$ and
$$p=\frac{\big\lfloor\sqrt{(k-1)^2+4kN}\big\rfloor+(k-1)}{2k}.$$
* ($s=-1$) If $q=k(p-1)-1$ with $k\ge1$, $p\ge2$, then
$$p=\frac{\big\lfloor\sqrt{(k+1)^2+4kN}\big\rfloor+(k+1)}{2k}.$$

**Theorem 7.9 (The maximal-gap extreme).** Let $p<q$ be primes with $(p-1)\mid(q-1)$, so that the Euler gap takes its largest possible value $g=p-1$, and write $q=k(p-1)+1$. Then

1. $R(N-1)=(p-1)(q-p)$, i.e. the reveal density is $R(N-1)/\varphi(N)=(q-p)/(q-1)=1-1/k$;
2. $p$ is recovered from $N$ and $k$ by the single integer square root of Corollary 7.8.

*Proof.* (1) From Corollary 7.5 with $g=p-1$: $(p-1)(q-1)+(p-1)^2-2(p-1)^2=(p-1)(q-p)$. (2) Corollary 7.8 with $s=1$. $\square$

So the high-density end of the gcd-reveal family is exactly its algebraically solvable end. When $k$ is unknown but bounded, one tries $k=1,2,\dots,K$, at a cost of $K$ integer square roots. The same phenomenon applies to the $s=-1$ extreme $q=k(p-1)-1$ ($kp^2-(k+1)p-N=0$, discriminant $(2kp-(k+1))^2$). That is where a cross-channel attempt built on a second Euler-gap family ended.

---

## 8. Algorithms

**Algorithm A (Exact two-parameter minimax).** *Input:* affine terms $T_i(a,b)=\alpha_i+\beta_ia+\gamma_ib$ and a box $[0,1]^2$. *Output:* $\min_{(a,b)}\max_iT_i$ and an optimiser.

1. Form the set $\mathcal L$ of lines: the four box edges, and $T_i=T_j$ for all $i<j$.
2. For every pair of non-parallel lines in $\mathcal L$, compute the intersection point, and keep it if it lies in the box.
3. Return the candidate with the smallest $\max_iT_i$.

The epigraph $\{(a,b,t):t\ge T_i\}$ is a polyhedron, and a minimiser of $t$ can be found at a vertex. At a vertex, at least two independent "lines" are tight. With $k$ terms the cost is $O(k^4)$ in exact rational arithmetic, which is negligible for $k\le10$.

**Algorithm B (Delete-a-term screen).** *Input:* a term set $\mathcal T$. *Output:* a partition into load-bearing and redundant terms.

1. $v\leftarrow$ value of $\mathcal T$ (Algorithm A).
2. For each $T\in\mathcal T$: if value$(\mathcal T\setminus\{T\})=v$, then $T$ is redundant. Remove it, set $\mathcal T\leftarrow\mathcal T\setminus\{T\}$, and restart.
3. When no further term can be removed, every remaining term is load-bearing.

The restart in step 2 is what Remark 2.5 requires. On Harvey's four terms the screen removes the M-leg and certifies the three-term core.

**Algorithm C (Extreme factoring by one square root).** *Input:* $N$ and a bound $K$. For $k=1,\dots,K$ and $s\in\{+1,-1\}$: compute $D=(s-k)^2+4kN$ and $\rho=\lfloor\sqrt D\rfloor$. If $\rho^2=D$ and $2k\mid\rho-(s-k)$, put $p=(\rho-(s-k))/(2k)$, and output $p$ if $1<p<N$ and $p\mid N$. Cost: $O(K)$ integer square roots of $O(\log N)$-bit numbers.

**Numerical illustrations.** For $p=1009$ and $q=2\cdot1008+1=2017$, $N=2035153$ is recovered with $k=2$, and the reveal density is $1/2$. For $p=1019$ and $q=10\cdot1018+1=10181$, $N=10374439$ is recovered with $k=10$, density $9/10$. For the $s=-1$ case, $p=523$ and $q=4\cdot522-1=2087$ give $N=1091501$, recovered with $k=4$. For $p=13$, $q=37$ ($N=481$, $g=12$), a direct count over all units confirms $R(E)$ for every $E<2N$, for example $R(36)=0$ (here $d_p=12=p-1$ and $d_q=36=q-1$, so every unit is a liar on both sides) and $R(N-1)=288$.

---

## 9. Discussion and future directions

**What changed.** Before this work, the order-free balance was believed to be held up by three co-leaders, the interior, $r$, and the M-leg, and the baby-step reuse was a candidate for removal. Afterwards: the M-leg is inert, with $V(\theta)$ flat up to a breakpoint where the real leg sits. The exponent is carried by the interior, $r$ and $m$. The $m$-reuse is worth exactly $N^{1/20}$ against the collapse alternative, and theory and experiment agree on that value.

**What did not change.** The exponent $1/5$ was not improved. It remains an upper bound, not a floor. All statements in Sections 3–6 concern the exponent model with polylogarithmic factors dropped. They describe a family of algorithms, not factoring itself.

**Future directions.**

1. *Sub-linear baby-step tables.* The $m$-leg is the only leg whose discount converts directly into exponent, via $\varepsilon\mapsto(1-\varepsilon)/(5-3\varepsilon)$. Conjecture: in the generic-group model, no table of $\alpha^0,\dots,\alpha^{m-1}$ supporting polylogarithmic membership queries can be built in $m^{1-\varepsilon}$ group operations.
2. *Breakpoint rigidity.* For a balance $\max\{a,b,\gamma-\tfrac a2-b\}$ with leg $\theta(1-a)$, the breakpoint should be $\theta^*=(2\gamma/5)/(1-2\gamma/5)$. At $\gamma=\tfrac12$ this gives $\theta^*=1/4$. Conjecture: legs derived from Strassen-type methods always satisfy $\theta\le\theta^*$.
3. *Reveal-density maximisers are algebraic.* Conjecture: for fixed $k$, the integers $N=pq$ with $R(N-1)/\varphi(N)\ge1-1/k$ are factored in polynomial time by at most $k$ integer square roots.
4. *Exponent-optimal reveal exponents.* The four-cell partition suggests $\max_ER(E)/\varphi(N)=1-\big(\tfrac1{p-1}+\tfrac1{q-1}\big)+O(1/pq)$, attained only by exponents whose structure is itself factor-revealing.

**A methodological note.** The screen, the slack-constraint principle (a constraint with zero multiplier at the optimum cannot move it) and the vacuity of symmetric read-outs together form a small toolkit of general checks. Each is cheap, and each can rule out a target before effort is spent on it.

---

## References

* D. Harvey, *An exponent one-fifth algorithm for deterministic integer factorisation*, 2021.
* R. S. Lehman, *Factoring large integers*, Mathematics of Computation 28 (1974).
* V. Strassen, *Einige Resultate über Berechnungskomplexität*, Jahresbericht der DMV 78 (1976/77).
* J. M. Pollard, *Theorems on factorization and primality testing*, Proc. Cambridge Philos. Soc. 76 (1974).
