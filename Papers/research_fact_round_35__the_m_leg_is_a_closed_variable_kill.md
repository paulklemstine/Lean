# The Baby-Step Leg of Harvey's $N^{1/5}$ Factoring Cost Is a Closed Variable, and "Adding a Floor" Is the Weight Lever in Disguise

**Aristotle**

*October 2026*

---

## Abstract

Harvey's deterministic integer-factoring algorithm runs in time $N^{1/5+o(1)}$. Ignoring logarithmic factors, its cost reduces to the balance

$$
\max\{A,B,C\} = \max\Big\{\tfrac{N^{1/2}}{r^{1/2}m},\ r,\ m\Big\},
$$

where $r$ bounds a Lehman-type pair search, $m$ is the length of a baby-step table, and $A$ is the cost of the matching ("interior") phase. In exponent form ($r=N^a$, $m=N^b$) the cost is $E(a,b)=\max\{a,\,b,\,\tfrac12-\tfrac a2-b\}$, whose minimum is $\tfrac15$. We ask whether the baby-step leg $C$, or the interior $A$ it feeds, can be cheapened to obtain a power-of-$N$ gain. We prove that it cannot, using three independent *pins*. (1) **Product invariance.** $A\cdot C=N^{1/2}/r^{1/2}$ does not depend on $m$, so $\max\{A,C\}\ge (N/r)^{1/4}$, with equality at the balanced split. Optimizing out $m$ turns the three-leg cost into Harvey's two-leg $\{M\text{-leg},\,r\}$ cost. (2) **Output counting.** A straight-line monoid program with $t$ multiplications outputs at most $t+1$ distinct elements, so the baby-step chain, which uses $m-1$ multiplications, is optimal. (3) **Injectivity with a sharp boundary.** The baby steps $\alpha,\dots,\alpha^m$ are distinct if $m\le\operatorname{ord}(\alpha)$ and collide if $0<\operatorname{ord}(\alpha)<m$, so the interior weight $1$ is a correctness condition. We compute the exact linear-programming sensitivity of the optimum: cheapening the legs $(r,m,A)$ by exponents $(\varepsilon_1,\varepsilon_2,\varepsilon_3)$ gives the optimum $\tfrac15-\tfrac{\varepsilon_1+2\varepsilon_2+2\varepsilon_3}{5}$ exactly, so the shadow prices are $(\tfrac15,\tfrac25,\tfrac25)$. We then analyze the previously untried lever of *adding a floor*, a new term in the maximum. Adding a term never helps by itself. A floor of interior weight $w$ bought at overhead $\delta$ gives the exact optimum $(\gamma+\delta)/(2+\alpha+w)$, which beats the old one iff $\delta(2+\alpha)<\gamma w$. For Harvey this condition is $\delta<w/5$. In a faithful model where the floor must also enter the $M$-leg with weight $\theta$, the cost is at least $\max\{1/(5+4\theta),\,1/(5+2w)\}$. Beating $\tfrac15$ requires $\theta>0$ and $w>0$, and reaching $\tfrac16$ requires $\theta\ge\tfrac14$ and $w\ge\tfrac12$; both thresholds are attained. No new factoring algorithm is claimed, and $N^{1/5}$ remains an upper bound, not a lower bound.

---

## 1. Introduction

### 1.1 Context

Deterministic factoring has a short history of exponents. Trial division takes $N^{1/2}$ steps. The Pollard–Strassen method takes $N^{1/4+o(1)}$, and so does Lehman's method in its basic form. In 2021 Harvey gave a deterministic algorithm running in time $O\big(N^{1/5}\log^{16/5}N/(\log\log N)^{3/5}\big)$. It combines a Lehman-style search over pairs of small integers with a baby-step/giant-step computation in $(\mathbb Z/N\mathbb Z)^\times$ that exploits the multiplicative order of a fixed element $\alpha$. The exponent $\tfrac15$ comes from balancing three costs.

This paper belongs to a sequence of attempts to push that exponent down by attacking the balance itself. After discarding logarithmic factors, the running time is governed by

$$
\operatorname{cost}(r,m) \;=\; \max\big\{A,B,C\big\},\qquad A=\frac{N^{1/2}}{r^{1/2}m},\quad B=r,\quad C=m. \tag{1.1}
$$

Here $B=r$ is the **pair leg**, the size of the Lehman-type search. $C=m$ is the **baby-step leg**, the number of powers $\alpha,\alpha^2,\dots,\alpha^m$ that are tabulated. $A$ is the **interior**, the matching work that remains once both have been paid for. Writing $r=N^a$ and $m=N^b$, the exponent of (1.1) is

$$
E(a,b)\;=\;\max\Big\{a,\ b,\ \tfrac12-\tfrac a2-b\Big\}. \tag{1.2}
$$

### 1.2 The question

Many earlier attempts tried to cheapen one term of (1.2). This paper concerns the baby-step leg $C$ together with the interior $A$. Can a cleverer table, a cleverer matching procedure, or a reorganized interior give a power-of-$N$ improvement?

Following a working rule we recommend in general, we screened the question with a short linear-programming sensitivity analysis before attacking it by search. The screen closed the question by a theorem: no such improvement exists. It also pointed to a lever outside the original framing, namely *adding a floor*, which changes the functional form of the cost instead of cheapening a term. We show that this lever reduces exactly to a quantity that was already known, the interior weight of a new parameter, and we compute its break-even law.

### 1.3 Summary of results

1. **(Optimum and certificate.)** $\min_{a,b}E(a,b)=\tfrac15$, attained at $a=b=\tfrac15$ and certified by the multipliers $(\tfrac15,\tfrac25,\tfrac25)$ (Theorem 3.2).
2. **(Pin 1: product invariance.)** $A\cdot C=N^{1/2}/r^{1/2}$ and $\max\{A,C\}\ge(N/r)^{1/4}$. In exponents, $\min_b E(a,b)=\max\{a,(1-a)/4\}$ (Theorems 4.1–4.3).
3. **(Pin 2: output counting.)** A straight-line program with $t$ multiplications outputs at most $t+1$ distinct values. The baby-step chain uses exactly $m-1$ multiplications and is optimal (Theorems 5.2–5.4).
4. **(Pin 3: injectivity.)** The baby steps are distinct iff no wrap-around occurs. The bound $m\le\operatorname{ord}(\alpha)$ is sharp (Theorems 6.1–6.2).
5. **(Shadow prices.)** The exact sensitivity of the optimum is $(\varepsilon_1+2\varepsilon_2+2\varepsilon_3)/5$ (Theorem 7.1). As a corollary, the baby-step leg is closed (Corollary 7.2).
6. **(Add a floor.)** The exact optimum is $(\gamma+\delta)/(2+\alpha+w)$, with a unique minimizer. The floor is beneficial iff $\delta(2+\alpha)<\gamma w$; for Harvey this means $\delta<w/5$. A floor with $w=0$ is useless (Theorems 8.1–8.5).
7. **(Faithful model.)** The cost is at least $\max\{1/(5+4\theta),1/(5+2w)\}$. Beating $\tfrac15$ needs $\theta,w>0$. Reaching $\tfrac16$ needs $\theta\ge\tfrac14$ and $w\ge\tfrac12$, and these thresholds are attained (Theorems 9.1–9.3).

---

## 2. Preliminaries: max-of-affine costs and dual certificates

All cost functions in this paper have the form $T(x)=\max_{i\in I}\ell_i(x)$, where each $\ell_i$ is an affine function of a real parameter vector $x$. The basic tool for lower bounds is the following.

**Lemma 2.1 (Dual certificate).** Let $I$ be a finite index set and let $\ell_i\in\mathbb R$ for $i\in I$. Suppose $\lambda_i\ge0$, $\sum_{i}\lambda_i=1$, and $\sum_i\lambda_i\ell_i=c$. If $T\ge\ell_i$ for all $i$, then $T\ge c$.

*Proof.* $c=\sum_i\lambda_i\ell_i\le\sum_i\lambda_i T=T$. $\square$

When the $\ell_i$ are affine functions of $x$ and the combination $\sum\lambda_i\ell_i(x)$ is a constant $c$, independent of $x$, Lemma 2.1 gives $\max_i\ell_i(x)\ge c$ for every $x$. By linear-programming duality, the multipliers that certify the optimum are the **shadow prices** of the legs.

**Lemma 2.2 (Adding a term is monotone).** If $L\le f(p)$ for all $p$, then $L\le\max\{f(p),F(p)\}$ for all $p$ and every function $F$.

*Proof.* $L\le f(p)\le\max\{f(p),F(p)\}$. $\square$

Lemma 2.2 is trivial, but it carries the point of Section 8. Appending a term to a maximum can never lower its minimum. A new term can only help if the new parameter it introduces also *modifies* an existing term.

---

## 3. Harvey's balance

**Definition 3.1.** For $a,b\in\mathbb R$ put $E(a,b)=\max\{a,\,b,\,\tfrac12-\tfrac a2-b\}$. The three entries are the exponents of the pair leg $r$, the baby-step leg $m$, and the interior.

**Theorem 3.2 (Optimum $\tfrac15$).** For all $a,b$ we have $E(a,b)\ge\tfrac15$, with equality at $a=b=\tfrac15$.

*Proof.* Use the multipliers $(\tfrac15,\tfrac25,\tfrac25)$:
$$\tfrac15 a+\tfrac25 b+\tfrac25\big(\tfrac12-\tfrac a2-b\big)=\tfrac15.$$
Lemma 2.1 gives the lower bound. At $a=b=\tfrac15$ all three legs equal $\tfrac15$. $\square$

The multiplier on the interior is $\tfrac25$, the same as on the baby-step leg. This already hints at Pin 1: the interior and the baby-step leg move together.

---

## 4. Pin 1: $A\cdot C$ is a single degree of freedom

**Theorem 4.1 (Product invariance).** For $m>0$,
$$A\cdot C=\frac{N^{1/2}}{r^{1/2}m}\cdot m=\frac{N^{1/2}}{r^{1/2}},$$
independently of $m$.

*Proof.* Cancel $m$. $\square$

**Theorem 4.2 (The interior and the baby steps collapse to the $M$-leg).** For $N,r,m>0$,
$$\max\Big\{\frac{N^{1/2}}{r^{1/2}m},\ m\Big\}\ \ge\ \Big(\frac Nr\Big)^{1/4},$$
with equality iff $m=(N/r)^{1/4}$.

*Proof.* For $x,y\ge0$ we have $xy\le\max\{x,y\}^2$. Apply this to $x=A$ and $y=m$. By Theorem 4.1, $A m=(N/r)^{1/2}=\big((N/r)^{1/4}\big)^2$. Taking square roots of nonnegative quantities gives the bound. Equality holds iff $A=m$. $\square$

**Theorem 4.3 (Optimizing out $m$).** For every $a$ and every $b$,
$$\max\Big\{b,\ \tfrac12-\tfrac a2-b\Big\}\ \ge\ \frac{1-a}{4},$$
with equality at $b=(1-a)/4$. Consequently
$$\min_b E(a,b)=\max\Big\{a,\ \frac{1-a}{4}\Big\},$$
and this minimum over $b$ is attained at $b=(1-a)/4$.

*Proof.* The average of $b$ and $\tfrac12-\tfrac a2-b$ is $\tfrac{1-a}{4}$, and the maximum of two numbers is at least their average. At $b=\tfrac{1-a}4$ both terms equal $\tfrac{1-a}{4}$. $\square$

**Interpretation.** The term $(N/r)^{1/4}$, with exponent $(1-a)/4$, is exactly the cost of Step 2 of Harvey's refined algorithm, the "$M$-leg". The value $\tfrac15$ therefore has two certificates that look different: one on the legs $\{M\text{-leg},r\}$ with multipliers $(\tfrac45,\tfrac15)$, and one on $\{\text{interior},r,m\}$ with multipliers $(\tfrac25,\tfrac15,\tfrac25)$. Theorem 4.3 shows that the second becomes the first once $m$ is optimized out. The interior's $\tfrac25$ and the baby-step leg's $\tfrac25$ merge into the $M$-leg's $\tfrac45$. Making the baby-step leg cheaper while keeping $A\cdot C$ fixed only re-splits a product whose split is already AM–GM optimal.

---

## 5. Pin 2: output counting

We model the construction of baby steps as a straight-line program over a monoid.

**Definition 5.1 (Straight-line program).** Let $G$ be a monoid. A *program* is a finite list of index pairs $(i_1,j_1),\dots,(i_t,j_t)$. Running it from an input $g_0\in G$ starts with the list $[g_0]$. Instruction $k$ appends $x_{i_k}\cdot x_{j_k}$, where $x_i$ is the current $i$-th entry and an out-of-range index reads as $1$. Each instruction is one multiplication.

**Theorem 5.2 (Length).** Running a program with $t$ instructions produces a list of exactly $t+1$ elements.

*Proof.* Induction on $t$. Each instruction appends exactly one element. $\square$

**Theorem 5.3 (Output counting).** Let $S\subseteq G$ be a finite set all of whose elements occur in the output of a program with $t$ multiplications. Then $|S|\le t+1$.

*Proof.* $S$ is contained in the set of entries of the output list. That set has at most as many elements as the list has entries, which is $t+1$ by Theorem 5.2. $\square$

**Theorem 5.4 (The baby-step chain is optimal).** Let $G$ be a group, $\alpha\in G$, and $1\le m\le\operatorname{ord}(\alpha)$.

1. Any straight-line program, from any input, whose output contains all of $\alpha,\alpha^2,\dots,\alpha^m$ uses at least $m-1$ multiplications.
2. The *baby-step program*, whose $j$-th instruction ($j=0,\dots,m-2$) multiplies entry $j$ (which is $\alpha^{j+1}$) by entry $0$ (which is $\alpha$), outputs exactly $[\alpha,\alpha^2,\dots,\alpha^m]$ using $m-1$ multiplications.

*Proof.* (1) By Theorem 6.1 below, the $m$ baby steps are pairwise distinct. Theorem 5.3 then gives $m\le t+1$. (2) Induction: if the current list is $[\alpha,\dots,\alpha^{j+1}]$, the next instruction appends $\alpha^{j+1}\cdot\alpha=\alpha^{j+2}$. $\square$

**Interpretation.** In Harvey's algorithm the baby steps are produced by a bare chain of $m$ single multiplications, and the companion step performs $m$ gcd computations, one per table entry. Since $m$ distinct elements cannot be produced with fewer than $m-1$ multiplications, $\Theta(m)$ is the information-theoretic floor for this leg in the straight-line model, and it is already met. In the notation of Section 7, $\varepsilon_2\le0$.

---

## 6. Pin 3: injectivity is a correctness hypothesis

Harvey's matching step relies on the following property: since the powers $\alpha_i$ in the baby-step list are distinct, thanks to the hypothesis $\operatorname{ord}_N(\alpha)\ge m$, each giant-step value $v_{a,b,j}$ equals at most one $\alpha_i$. We isolate the group-theoretic content and show that the hypothesis is sharp.

**Theorem 6.1 (Injectivity).** Let $G$ be a group, $\alpha\in G$, and $m\le\operatorname{ord}(\alpha)$. (If $\alpha$ has infinite order, take $\operatorname{ord}(\alpha)=\infty$.) Then $\alpha^1,\alpha^2,\dots,\alpha^m$ are pairwise distinct.

*Proof.* If $\alpha^{i+1}=\alpha^{j+1}$ with $0\le i,j<m$, cancel one factor $\alpha$ on the right to get $\alpha^i=\alpha^j$. The map $k\mapsto\alpha^k$ is injective on $\{0,1,\dots,\operatorname{ord}(\alpha)-1\}$, and $i,j<m\le\operatorname{ord}(\alpha)$, so $i=j$. $\square$

**Theorem 6.2 (Sharpness).** If $0<\operatorname{ord}(\alpha)<m$, then the list $\alpha^1,\dots,\alpha^m$ contains a repetition. Specifically, $\alpha^1=\alpha^{\operatorname{ord}(\alpha)+1}$, and both exponents lie in $\{1,\dots,m\}$.

*Proof.* $\alpha^{\operatorname{ord}(\alpha)+1}=\alpha^{\operatorname{ord}(\alpha)}\alpha=\alpha$, and $\operatorname{ord}(\alpha)+1\le m$. $\square$

**Example 6.3.** In $(\mathbb Z/1001\mathbb Z)^\times$, $1001=7\cdot11\cdot13$, the element $10$ has order $6$, since $10^3\equiv-1$. The baby steps for $m=6$ are $10,100,1000,991,901,1$, which are distinct. For $m=7$ the seventh step is $10^7\equiv10$, a collision.

**Interpretation.** In the exponent model, a hypothetical improvement that let each baby step "serve" several giant-step values would give $m$ a weight greater than $1$ in the interior. Theorem 6.2 shows that the boundary $m\le\operatorname{ord}(\alpha)$ is exactly where "at most one match per value" stops holding. Weight $1$ is the *correctness* condition of the matching phase, not slack in the analysis. In the notation of Section 7, the baby-step contribution to the interior cannot be cheapened, so $\varepsilon_3=0$ on that channel.

---

## 7. Exact LP sensitivity and the closure of the baby-step leg

**Definition 7.1.** For $\varepsilon_1,\varepsilon_2,\varepsilon_3\in\mathbb R$ define the cheapened cost
$$E_{\varepsilon}(a,b)=\max\Big\{a-\varepsilon_1,\ b-\varepsilon_2,\ \tfrac12-\tfrac a2-b-\varepsilon_3\Big\}.$$

**Theorem 7.1 (Exact sensitivity).** For all $\varepsilon$ and all $a,b$,
$$E_\varepsilon(a,b)\ \ge\ \frac15-\frac{\varepsilon_1+2\varepsilon_2+2\varepsilon_3}{5},$$
and for every $\varepsilon$ there exist $a,b$ achieving equality.

*Proof.* The multipliers $(\tfrac15,\tfrac25,\tfrac25)$ of Theorem 3.2 combine the cheapened legs into $\tfrac15-\tfrac{\varepsilon_1+2\varepsilon_2+2\varepsilon_3}{5}$. Lemma 2.1 gives the lower bound. For attainment, let $t$ be the right-hand side and set $a=t+\varepsilon_1$, $b=t+\varepsilon_2$. The first two legs equal $t$, and the third is
$$\tfrac12-\tfrac{t+\varepsilon_1}2-(t+\varepsilon_2)-\varepsilon_3=t,$$
which follows from the definition of $t$ by direct computation. $\square$

The shadow prices of $(r,m,\text{interior})$ are therefore exactly $(\tfrac15,\tfrac25,\tfrac25)$. The baby-step leg and the interior together carry $\tfrac45$ of the price. This is the LP counterpart of Pin 1, and it is why this pair looked like the natural target.

**Corollary 7.2 (The baby-step leg is closed).** Suppose the baby-step leg cannot be cheapened ($\varepsilon_2\le0$, by Pin 2) and the interior is not cheapened through the baby steps ($\varepsilon_3=0$, by Pin 3). Then for all $a,b$,
$$E_\varepsilon(a,b)\ \ge\ \frac15-\frac{\varepsilon_1}{5}.$$
Every remaining gain must come through the pair leg, at price $\tfrac15$.

*Proof.* Substitute $\varepsilon_3=0$ into Theorem 7.1 and use $2\varepsilon_2\le0$. $\square$

**Remark 7.3 (All three legs are co-binding).** At the optimum $a=b=\tfrac15$ all three legs are tight and every multiplier is strictly positive. Each leg therefore binds, and a power-of-$N$ cheapening of any one leg is priced exactly by Theorem 7.1. For the baby-step leg and the interior this price can never be collected, since that would contradict Pin 2 or Pin 3.

---

## 8. Adding a floor

Every earlier attempt tried to cheapen an existing term. The alternative is to change the functional form: introduce a new parameter $s=N^c$ that appears as a new term ("floor") in the maximum, is small at the current optimum, and binds after rebalancing. Lemma 2.2 shows that the new term alone cannot help. What matters is how $s$ enters the existing terms.

**Definition 8.1 (Floor cost).** Fix real constants $\gamma$ (numerator exponent), $\delta$ (overhead), $\alpha\ge0$ (interior weight of the pair leg) and $w\ge0$ (interior weight of the new floor). Define
$$F(a,b,c)=\max\Big\{a,\ b,\ c,\ \gamma+\delta-\alpha a-b-wc\Big\}.$$
Harvey's cost is the case $\gamma=\alpha=\tfrac12$, $\delta=0$, with the floor removed.

**Theorem 8.2 (Four-leg weighted AM–GM).** For $\alpha,w\ge0$ and all $a,b,c$,
$$F(a,b,c)\ \ge\ \frac{\gamma+\delta}{2+\alpha+w}.$$

*Proof.* Let $T=F(a,b,c)$. Then $a,b,c\le T$, and $\gamma+\delta-\alpha a-b-wc\le T$. Since $\alpha,w\ge0$, we have $\alpha a\le\alpha T$ and $wc\le wT$. Hence $\gamma+\delta\le T+\alpha T+T+wT=(2+\alpha+w)T$. Equivalently, apply Lemma 2.1 with multipliers proportional to $(\alpha,1,w,1)$. $\square$

**Theorem 8.3 (Attainment and uniqueness).** At $a=b=c=t:=(\gamma+\delta)/(2+\alpha+w)$ all four legs equal $t$, so the bound of Theorem 8.2 is the exact optimum. If moreover $\alpha>0$ and $w>0$, this is the *unique* minimizer: $F(a,b,c)\le t$ forces $a=b=c=t$. In other words, the new floor is binding after the rebalance.

*Proof.* Attainment: $\gamma+\delta-(2+\alpha+w)t+t=t$. Uniqueness: from $a,b,c\le t$ and $\gamma+\delta-\alpha a-b-wc\le t$, we get
$$(2+\alpha+w)t=\gamma+\delta\le t+\alpha a+b+wc\le t+\alpha t+t+wt.$$
So all intermediate inequalities are equalities: $b=t$, $\alpha a=\alpha t$ and $wc=wt$. Cancel $\alpha,w>0$. $\square$

**Theorem 8.4 (A floor that misses the interior is useless).** If $w=0$ and $\delta\ge0$, then $F(a,b,c)\ge\gamma/(2+\alpha)$, the old optimum, for all $a,b,c$.

*Proof.* By Theorem 8.2 with $w=0$, $F\ge(\gamma+\delta)/(2+\alpha)\ge\gamma/(2+\alpha)$. $\square$

**Theorem 8.5 (Break-even law).** For $\alpha,w\ge0$,
$$\frac{\gamma+\delta}{2+\alpha+w}<\frac{\gamma}{2+\alpha}\iff\delta(2+\alpha)<\gamma w.$$
For Harvey's parameters $\gamma=\alpha=\tfrac12$ (old optimum $\tfrac15$):
$$\frac{\tfrac12+\delta}{\tfrac52+w}<\frac15\iff\delta<\frac w5.$$
In particular, a floor of interior weight $w=\tfrac12$ with no overhead gives exactly $\tfrac{1/2}{3}=\tfrac16$.

*Proof.* Cross-multiply by the positive denominators. The resulting inequality $(\gamma+\delta)(2+\alpha)<\gamma(2+\alpha+w)$ simplifies to $\delta(2+\alpha)<\gamma w$. Substitute the Harvey values. $\square$

**Conclusion of Section 8.** "Add a floor" is the weight lever in disguise. The only effect of the new term is to add its interior weight $w$ to the denominator of the AM–GM bound. Its break-even overhead is $\gamma w/(2+\alpha)$, which is $w$ times the old optimum. For Harvey this is $w\cdot\tfrac15=w/5$.

---

## 9. The faithful model: the floor must enter both certificates

Harvey's refined algorithm contains the $M$-leg $(N/r)^{1/4}$ as an explicit step. A realistic new floor $s=N^c$ may enter the $M$-leg with weight $\theta\ge0$ and the interior with weight $w\ge0$.

**Definition 9.1.** 
$$\Phi_{\theta,w}(a,b,c)=\max\Big\{\tfrac{1-a}4-\theta c,\ a,\ b,\ c,\ \tfrac12-\tfrac a2-b-wc\Big\}.$$

**Theorem 9.1 (Faithful lower bounds).** For $\theta,w\ge0$ and all $a,b,c$:
$$\Phi_{\theta,w}(a,b,c)\ \ge\ \frac1{5+4\theta}\qquad\text{and}\qquad\Phi_{\theta,w}(a,b,c)\ \ge\ \frac1{5+2w}.$$

*Proof.* Let $T=\Phi_{\theta,w}(a,b,c)$. *First certificate* (legs $M$, $a$, $c$): from $\tfrac{1-a}{4}-\theta c\le T$, $a\le T$ and $\theta c\le\theta T$ we get $\tfrac14\le T+\tfrac T4+\theta T$, i.e. $1\le(5+4\theta)T$. In multiplier form this uses weights $\tfrac{4}{5+4\theta},\tfrac1{5+4\theta},\tfrac{4\theta}{5+4\theta}$. *Second certificate* (legs interior, $a$, $b$, $c$): from $\tfrac12-\tfrac a2-b-wc\le T$, $a,b\le T$ and $wc\le wT$ we get $\tfrac12\le T+\tfrac T2+T+wT$, i.e. $1\le(5+2w)T$. $\square$

**Theorem 9.2 (Beating $\tfrac15$ needs both couplings).** If $\theta,w\ge0$ and $\Phi_{\theta,w}(a,b,c)<\tfrac15$ for some $a,b,c$, then $\theta>0$ and $w>0$.

*Proof.* If $\theta=0$, the first bound of Theorem 9.1 is $\tfrac15$. If $w=0$, the second bound is $\tfrac15$. $\square$

**Theorem 9.3 (The $\tfrac16$ thresholds).** If $\theta,w\ge0$ and $\Phi_{\theta,w}(a,b,c)\le\tfrac16$, then $\theta\ge\tfrac14$ and $w\ge\tfrac12$. Conversely, $\Phi_{1/4,\,1/2}(\tfrac16,\tfrac16,\tfrac16)=\tfrac16$.

*Proof.* $\tfrac1{5+4\theta}\le\tfrac16$ gives $\theta\ge\tfrac14$, and $\tfrac1{5+2w}\le\tfrac16$ gives $w\ge\tfrac12$. For the converse, compute the five legs at $a=b=c=\tfrac16$: $\tfrac{5/6}{4}-\tfrac1{24}=\tfrac16$; then $\tfrac16,\tfrac16,\tfrac16$; and $\tfrac12-\tfrac1{12}-\tfrac16-\tfrac1{12}=\tfrac16$. $\square$

**Numerical observation.** In every case we tested with an exact minimax solver (Algorithm 10.1), the optimum of $\Phi_{\theta,w}$ equals $\max\{1/(5+4\theta),1/(5+2w)\}$. Examples: $(\theta,w)=(\tfrac18,\tfrac12)$ gives $\tfrac2{11}$, and $(\tfrac12,1)$ gives $\tfrac17$. We have proved only the lower bound in general and attainment at $(\tfrac14,\tfrac12)$.

---

## 10. Algorithms

**Algorithm 10.1 (Exact minimax of affine legs).** *Input:* affine legs $\ell_i(x)=c_i\cdot x+k_i$, $i=1,\dots,L$, with $x\in\mathbb Q^d$. *Output:* $\min_x\max_i\ell_i(x)$ and a minimizer.

1. For each subset $S$ of $d+1$ legs, solve the square linear system $c_i\cdot x-t=-k_i$ ($i\in S$) over $\mathbb Q$.
2. Discard singular systems and solutions with $\ell_j(x)>t$ for some $j$.
3. Return the feasible solution with the least $t$.

This is vertex enumeration for the epigraph linear program $\min t$ subject to $\ell_i(x)\le t$. It takes $O\big(\binom{L}{d+1}d^3\big)$ exact arithmetic operations, which is negligible for the costs above ($L\le5$, $d\le3$). It reproduces Theorems 3.2, 7.1, 8.3 and 9.3 exactly.

**Algorithm 10.2 (Baby-step chain).** $x_0\gets\alpha$; for $j=0,\dots,m-2$: $x_{j+1}\gets x_j\cdot x_0$. Return $[x_0,\dots,x_{m-1}]$. This uses $m-1$ multiplications, which is optimal by Theorem 5.4.

**Algorithm 10.3 (Injectivity check).** Compute $\operatorname{ord}(\alpha)$ in $(\mathbb Z/N\mathbb Z)^\times$ by repeated multiplication. Then the table is collision-free iff $m\le\operatorname{ord}(\alpha)$ (Theorems 6.1–6.2).

**Algorithm 10.4 (Floor screen).** Given a candidate new parameter with measured exponents $(\theta,w,\delta)$, report the guaranteed lower bound $\max\{1/(5+4\theta),\,1/(5+2w)\}$, together with the simple-model break-even test $\delta<w/5$. A candidate is worth developing only if both tests are favourable.

---

## 11. Discussion

### 11.1 What has been shown

The baby-step leg of Harvey's cost is a **closed variable**. Three independent facts each block a different kind of attack:

- Re-splitting $m$ cannot help, because $A\cdot C$ is invariant and the split is already AM–GM optimal (Pin 1).
- Building the table faster cannot help, because output counting forces $m-1$ multiplications and the chain already uses exactly that many (Pin 2).
- Making each table entry do more work breaks correctness, because injectivity holds exactly up to $m=\operatorname{ord}(\alpha)$ (Pin 3).

The exact shadow prices turn these qualitative facts into a sharp quantitative statement (Corollary 7.2).

### 11.2 What has not been shown

These results concern an exponent model of one algorithm family. They say nothing about logarithmic factors, and nothing about algorithms whose cost is not of this max-of-affine form. They do **not** prove that $N^{1/5}$ is optimal for deterministic factoring. $N^{1/5}$ remains an upper bound. The straight-line model of Pin 2 counts multiplications of group elements; operations outside that model are not covered.

### 11.3 Methodological remark

The analysis was run as a *screen* before investing search effort, and it took far less work than the search it replaced. More importantly, it produced a redirection as well as a negative answer. The lever outside the original framing, adding a floor, was analysed exactly and reduced to two concrete numerical targets. We recommend this discipline for any optimization whose cost is a maximum of affine exponents. Compute the dual multipliers first. Then check which legs are pinned by counting or by correctness.

---

## 12. Future directions

1. **Dual-coupled floor existence.** Is there an arithmetic search parameter $s$, such as a second Lehman multiplier or a second order-finding base, that reduces the $M$-leg by $s^{1/4}$ and the interior by $s^{1/2}$ at overhead below $s^{1/10}$? By Theorem 9.3 the target is the pair $(\theta,w)\ge(\tfrac14,\tfrac12)$, two numbers rather than an unspecified idea.
2. **Output-counting lower bounds for generic baby-step/giant-step interiors.** In a generic-group model, conjecture that the matching interior is bounded below by $\Omega(\#\text{candidates}/\#\text{stored})$, by extending Theorem 5.3 from one output list to collisions between two lists.
3. **Shadow-price monotonicity under faithful refinement.** Conjecture that adding legs to a max-of-affine cost weakly raises the shadow price of every original leg that remains binding. Complementary slackness (Lemma 2.1) is the natural engine.
4. **Injectivity-relaxation trade-off.** If injectivity is relaxed to "each value matches at most $k$ baby steps" (so $\operatorname{ord}(\alpha)\ge m/k$), the interior weight drops from $1$ to $1-\log k/\log m$. Conjecture that this can never beat $\tfrac15$, since Theorem 6.2 is sharp and every relaxation must pay for extra correctness checks.

---

## References

- D. Harvey, *An exponent one-fifth algorithm for deterministic integer factorisation*, Math. Comp. **90** (2021).
- R. S. Lehman, *Factoring large integers*, Math. Comp. **28** (1974), 637–646.
- J. M. Pollard, *Theorems on factorization and primality testing*, Proc. Cambridge Philos. Soc. **76** (1974), 521–528.
- V. Strassen, *Einige Resultate über Berechnungskomplexität*, Jber. Deutsch. Math.-Verein. **78** (1976/77), 1–8.
