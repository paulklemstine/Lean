# Slack Constraints, Shadow Prices, and Sound Filters: Corrections to the Exponent-One-Fifth Factoring Landscape

**Aristotle** · 2026-10-19

---

## Abstract

Harvey's deterministic integer-factoring algorithm runs in time $N^{1/5+o(1)}$. Up to logarithmic factors, its cost is governed by the three-term minimax $E(a,b) = \max(a,\, b,\, \tfrac12 - \tfrac a2 - b)$. We use this model to settle several questions that had been answered incorrectly or left open.

**(i)** We prove a *slack-constraint lemma*: if a convex objective is minimised under a constraint that contains a neighbourhood of the minimiser, then removing the constraint does not change the optimum. As an application, we compute the full phase diagram of a ceiling $b \le c$ on the baby-step exponent. The optimum is $1/5$ when $c \ge 1/5$ and $(1-2c)/3$ when $c < 1/5$. Harvey's actual ceiling $c = 2/5$ is therefore slack, and the removal of the order-finding hypothesis behind it cannot move the exponent.

**(ii)** We solve the filtered model $\max(a-\sigma_2,\, b,\, \tfrac12 - \tfrac a2 - b - \sigma_1)$ exactly. Its optimum is $\tfrac15 - \tfrac{\sigma_2}{5} - \tfrac{2\sigma_1}{5}$, attained at a unique point where the three terms are equal. Consequently a filter acting only on candidate pairs must have strength $N^{1/6}$, not $N^{1/18}$, to reach exponent $1/6$.

**(iii)** We show that the filter "keep $(a,b)$ only if $a \le b$" is sound for Lehman-accurate approximations, and that it has exact strength $2\cdot\#\{\text{kept}\} = \#\{\text{all}\} + \lfloor\sqrt r\rfloor$. This refutes the claim that no such filter is known.

**(iv)** For the $p-1$-type reveal with $p-1 = ga$ and $q-1 = gb$, we prove that the number of revealing exponents per period is exactly $a+b-2$, independent of $g$. The reveal density $(a+b-2)/(ab)$ has supremum $1$, approached but never attained along $a = 1$. On the class $a,b\ge 2$ it is at most $1/2$, with equality if and only if $\min(a,b) = 2$.

**(v)** We prove a disjointness guard and a divisor-mass union bound for coverings of $[1,n]$ by divisibility of differences.

**(vi)** We show that a published large-order precondition, $\delta \ge N^{1/4}\log^8 N$ at $\delta = N^{1/3}$, fails exactly for $2^{96}\le N<2^{950}$ (within $N\ge 2^{96}$) and holds for every $N \ge 2^{950}$.

**(vii)** We prove that the legs of the Berggren $B$-spine of Pythagorean triples satisfy $a_k - b_k = (-1)^{k+1}$, and record an exact effective-sample-size count of $163$ among $38{,}635$ primes.

The common thread is linear-programming duality. The dual weights $(1/5, 2/5, 2/5)$ of Harvey's minimax account for every exponent correction in this note.

---

## 1. Introduction

### 1.1 Background

Let $N = pq$ with $p < q$ primes. Among deterministic algorithms with rigorous analyses, the exponent of $N$ in the running time has decreased over the years. Lehman's method achieves $1/3$. The Pollard–Strassen method achieves $1/4$. Hittmeir's baby-step giant-step refinement improves on that by logarithmic factors. In 2021 Harvey reached $1/5$ by combining Lehman-type rational approximation of $p/q$ with baby-step giant-step order computations. Throughout, $N^{1/5}$ is an **upper bound** on the deterministic record and not a lower bound. No unconditional super-polynomial lower bound for integer factoring is known in any standard model.

Records invite speculation about what might lower them. One such suggestion was that a parameter ceiling in Harvey's analysis depends on a hypothesis about order-finding, so a recent result removing that hypothesis might lower the exponent. This paper explains why it cannot, and isolates the general principle involved (Section 3). Along the way we correct several quantitative claims that had been circulating about the same algorithm and its neighbours.

### 1.2 The model and its limits

All exponent statements below are made in the **exponent model**. We write every cost as $N^{x}$ and discard factors polylogarithmic in $N$. The model is exact as a statement about exponents. It says nothing about logarithmic factors or constants. Which cost terms a concrete algorithmic modification affects is a *modelling input*. We prove consequences of each choice and do not decide which choice a given modification realises.

### 1.3 Summary of contributions

1. **Slack-constraint lemma** (Theorem 3.1) and its value form (Corollary 3.2). Application to Harvey's baby-step ceiling (Theorem 3.3) and the exact phase diagram (Theorem 3.4).
2. **Exact filtered optimum** with uniqueness and three-way co-dominance (Theorem 4.1). Corrected sieve targets $\sigma = 1/6$ versus $\sigma = 1/18$ (Corollaries 4.2–4.3).
3. **A free sound filter** (Theorems 5.1 and 5.3).
4. **Euler-gap reveal counting**: the gap cancels (Theorems 6.2–6.3), and the supremum dichotomy $1$ versus $1/2$ (Theorems 6.4–6.5).
5. **Covering guards** (Proposition 7.2, Theorem 7.3, Corollary 7.4).
6. **Bounded violation window** for a polylogarithmic precondition (Theorem 8.1).
7. **Berggren spine collapse** (Theorem 9.1) and an **effective-sample-size** count (Proposition 10.1).
8. Methodological findings, which are empirical and not theorems (Section 11).

---

## 2. Harvey's three-term exponent model

Harvey's algorithm has two tunable exponents. The parameter $a$ sets the number $r = N^{a}$ of Lehman candidate pairs $(a', b')$ with $a'b' \le r$, swept one by one. The parameter $b$ sets the size $m = N^{b}$ of a baby-step table. The residual search interval left after rational approximation has length about $N^{1/2}/r^{1/2}$, and each giant step covers $m$ positions, so the giant sweep costs $N^{1/2 - a/2 - b}$.

**Definition 2.1 (Harvey exponent).** For $(a,b) \in \mathbb R^2$ set
$$E(a,b) = \max\big(T_2,\, T_3,\, T_1\big),\qquad T_2 = a,\quad T_3 = b,\quad T_1 = \tfrac12 - \tfrac a2 - b.$$
Here $T_2$ is the pair sweep, $T_3$ the baby-step table, and $T_1$ the giant sweep.

**Proposition 2.2.** $E(a,b) \ge 1/5$ for all $(a,b)$, with equality at $(1/5,1/5)$. At that point $T_1 = T_2 = T_3 = 1/5$.

*Proof.* With weights $w = (w_2, w_3, w_1) = (1/5, 2/5, 2/5)$, which are nonnegative and sum to $1$,
$$\tfrac15 a + \tfrac25 b + \tfrac25\big(\tfrac12 - \tfrac a2 - b\big) = \tfrac15,$$
identically in $a,b$. A maximum dominates any convex combination of its arguments, so $E \ge 1/5$. Direct substitution gives equality at $(1/5,1/5)$. $\square$

The weights $w$ are the **dual weights**, or *shadow prices*, of the linear program $\min_{a,b,t}\{t : t \ge T_i\}$. They are the unique convex combination of the three affine terms with constant value. They will reappear in every result of Sections 3 and 4.

**Remark 2.3 (co-dominance).** At the optimum, no term dominates: all three are equal. In particular the baby-step term is a co-leader. Statements of the form "the $r$-term is the whole leading cost" are incorrect. Harvey's parameter $s$ is a sum of two summands of the shape $N^{1/5}\lg^{1/5}N$. Measuring these at seven bit sizes gives a ratio of $1.000000$, so $s = 2N^{1/5}\lg^{1/5}N$, consistent with the exact balance. (This is a measurement and is reported as such.) Uniqueness of the optimiser is a special case of Theorem 4.1 below.

---

## 3. The slack-constraint lemma

### 3.1 The lemma

**Theorem 3.1 (Slack-Constraint Lemma).** Let $E$ be a real topological vector space, $A \subseteq E$ convex, and $f : E \to \mathbb R$ convex on $A$. Let $C \subseteq E$, and let $x \in A$ be such that

- $C$ is a neighbourhood of $x$ (the constraint is *slack* at $x$), and
- $f(x) \le f(y)$ for all $y \in A \cap C$.

Then $f(x) \le f(y)$ for all $y \in A$.

*Proof.* Since $C$ is a neighbourhood of $x$, the set $A\cap C$ is a neighbourhood of $x$ within $A$. Hence $x$ is a local minimiser of $f$ on $A$. Suppose some $y\in A$ had $f(y) < f(x)$. For $t\in(0,1]$ the point $x_t = (1-t)x + ty$ lies in $A$, and convexity gives $f(x_t) \le (1-t)f(x) + tf(y) < f(x)$. As $t\to 0$, $x_t \to x$, so $x_t$ eventually lies in $A \cap C$. This contradicts local minimality. $\square$

**Corollary 3.2 (value form).** Under the hypotheses of Theorem 3.1, and if in addition $x \in C$,
$$\inf f(A) = \inf f(A \cap C) = f(x).$$
Dropping a slack constraint leaves the optimal value unchanged.

The lemma converts a familiar intuition into a test. *An argument of the form "hypothesis $X$ fell, therefore the optimum improves" is valid only if the constraint encoded by $X$ is active at the optimum.* If the constraint's ceiling strictly exceeds what the optimum needs, then the fall of $X$ moves nothing.

### 3.2 Application to the baby-step ceiling

**Theorem 3.3.** $E$ is convex on $\mathbb R^2$. The ceiling $\{(a,b) : b < 2/5\}$ is an open neighbourhood of $(1/5,1/5)$, and $(1/5,1/5)$ minimises $E$ globally. Lifting the ceiling therefore leaves the optimum at $1/5$.

*Proof.* Each of $T_1, T_2, T_3$ is affine, and a pointwise maximum of affine functions is convex. The set $\{b<2/5\}$ is open and contains $(1/5,1/5)$. Proposition 2.2 shows that $(1/5,1/5)$ minimises $E$ on the constrained set, and Theorem 3.1 promotes this to all of $\mathbb R^2$. $\square$

### 3.3 The full phase diagram

**Theorem 3.4 (phase diagram of the ceiling $b\le c$).** Let $c \in \mathbb R$.

1. *(Slack regime.)* If $c \ge 1/5$, then $\min_{b\le c} E(a,b) = 1/5$, attained at $(1/5,1/5)$.
2. *(Active regime.)* If $c < 1/5$, then $\min_{b \le c} E(a,b) = (1-2c)/3$, attained at $\big((1-2c)/3,\ c\big)$. Moreover $(1-2c)/3 > 1/5$.

So the ceiling changes the exponent if and only if it is active, which happens if and only if $c < 1/5$.

*Proof.* (1) The lower bound comes from Proposition 2.2, and $(1/5,1/5)$ is feasible. (2) For the lower bound, use the weights $(1/3, 0, 2/3)$ on $(T_2, T_3, T_1)$:
$$E \ge \tfrac13 a + \tfrac23\big(\tfrac12 - \tfrac a2 - b\big) = \tfrac13 - \tfrac{2b}{3} \ge \tfrac{1-2c}{3}.$$
At $a = (1-2c)/3$, $b = c$, one checks that $T_1 = T_2 = (1-2c)/3$ and $T_3 = c < (1-2c)/3$. The last inequality is equivalent to $c < 1/5$. $\square$

**Remark 3.5 (size of the slack).** Harvey's ceiling is $m \le N^{2/5}$, that is $c = 2/5$, while the optimum needs $m = N^{1/5}$. In the exponent model the headroom is therefore a factor $N^{1/5}$. An earlier account described the slack as a factor of about $\lg^{0.8}N$. At the exponent level that figure does not apply. The true headroom is a full power of $N$, which makes the conclusion stronger. In Harvey's own accounting the order-finding step is negligible, and Theorem 3.4 explains why that is structural and not accidental.

---

## 4. Filters and the corrected sieve target

### 4.1 The filtered model

A *filter* is a modification that discards candidates before they are processed. Suppose a filter divides the pair term by $N^{\sigma_2}$ and the giant-sweep term by $N^{\sigma_1}$.

**Definition (filtered exponent).** For $\sigma_1,\sigma_2 \in \mathbb Q$ set
$$E_{\sigma_1,\sigma_2}(a,b) = \max\Big(a - \sigma_2,\ b,\ \tfrac12 - \tfrac a2 - b - \sigma_1\Big),\qquad V(\sigma_1,\sigma_2) = \tfrac15 - \tfrac{\sigma_2}5 - \tfrac{2\sigma_1}{5}.$$

**Theorem 4.1 (exact filtered optimum, uniqueness, co-dominance).** For all $\sigma_1,\sigma_2$:

1. $E_{\sigma_1,\sigma_2}(a,b) \ge V(\sigma_1,\sigma_2)$ for all $a,b$;
2. equality holds at $(a^*,b^*) = (V + \sigma_2,\ V)$;
3. if $E_{\sigma_1,\sigma_2}(a,b) = V$, then $(a,b) = (a^*,b^*)$, and at that point $a - \sigma_2 = b = \tfrac12 - \tfrac a2 - b - \sigma_1$.

*Proof.* (1) The same dual weights $(1/5,2/5,2/5)$ give
$$\tfrac15(a-\sigma_2) + \tfrac25 b + \tfrac25\big(\tfrac12 - \tfrac a2 - b - \sigma_1\big) = V.$$
(2) Direct substitution. (3) If the maximum equals $V$, each term is at most $V$, while their weighted average with strictly positive weights equals $V$. Hence every term equals $V$. The resulting linear system has the unique solution $(a^*,b^*)$. $\square$

The optimum is an exact **shadow-price formula**: a saving $\sigma_i$ on term $i$ lowers the exponent by $w_i\sigma_i$. Pair savings are worth $1/5$ of their face value and sweep savings $2/5$.

### 4.2 Two targets, one dual vector

**Corollary 4.2 (pair-only filter).** $V(0,\sigma) = \tfrac15 - \tfrac\sigma5$. Hence $V(0,\sigma) = 1/6$ if and only if $\sigma = 1/6$.

**Corollary 4.3 (pair-and-sweep filter).** $V(\sigma,\sigma) = \tfrac15 - \tfrac{3\sigma}5$. Hence $V(\sigma,\sigma) = 1/6$ if and only if $\sigma = 1/18$.

The often-quoted target "a pair filter of strength $N^{1/18}$ reaches $1/6$" therefore assumes the filter also divides the giant sweep. In Harvey's analysis the dominant logarithmic cost of the sweep comes from a smoothness sieve, and a filter on Lehman pairs does not divide it. For a genuine pair filter the target is $\sigma = 1/6$, **three times larger** in the exponent. The two targets are not in conflict. They are two readings of one dual vector.

**Corollary 4.4 (constant filters gain no exponent).** $V(0,0) - V(0,\sigma) = \sigma/5$. A filter of constant strength $s$ has $\sigma = \log_2 s/\log_2 N \to 0$, so it improves the running time by a constant factor and does not change the exponent.

---

## 5. A free, sound pair filter

It had been asserted that no quantity-matched sound filter on Harvey's pair family is known. Here is one.

**Theorem 5.1 (soundness of the $a\le b$ filter).** Let $p,q,a,b$ be integers with $0 < p < q$ and $b > 0$, and suppose $|aq - bp| < b$ (Lehman accuracy). Then $a < b$.

*Proof.* If $a \ge b$, then since $q>0$ we have $aq \ge bq$, so $aq - bp \ge b(q-p) \ge b$, because $q - p\ge 1$. This contradicts $aq - bp \le |aq-bp| < b$. $\square$

The hypothesis $p>0$ cannot be dropped. For example $p=-2$, $q=-1$, $a=2$, $b=1$ satisfies the other hypotheses but not the conclusion. In Harvey's analysis the good pair approximates $p/q$ in exactly this sense (via the classical Dirichlet/Hardy–Wright approximation argument), so the filter never discards it.

**Definition 5.2.** $\mathcal P(r) = \{(a,b) \in \mathbb Z_{\ge1}^2 : ab \le r\}$.

**Theorem 5.3 (exact strength).** For every $r \ge 0$,
$$2\cdot \#\{(a,b) \in \mathcal P(r) : a \le b\} = \#\mathcal P(r) + \lfloor \sqrt r\rfloor.$$

*Proof.* Split $\mathcal P(r)$ into the parts with $a<b$, $a=b$ and $a>b$. The swap $(a,b)\mapsto(b,a)$ preserves $ab\le r$ and is a bijection between the first and third parts. The diagonal part is $\{(a,a) : 1\le a\le \lfloor\sqrt r\rfloor\}$. Thus $\#\{a\le b\} = L + D$ and $\#\mathcal P = 2L + D$, where $L = \#\{a<b\}$ and $D = \lfloor\sqrt r\rfloor$. $\square$

*Example.* $r = 100$: $\#\mathcal P(100) = 482$, the filter keeps $246$, and $2\cdot 246 = 482 + 10$.

The filter has strength $s = 2$ up to a lower-order $\sqrt r$ term. By Corollary 4.4 it gains no exponent. It does show that the space of sound filters is not empty, and that the target $\sigma = 1/6$ is hard but not known to be impossible. A runtime measurement of the filter on Harvey's pair sweep reported a speed factor of about $0.93$. That number is empirical and depends on the implementation.

---

## 6. Euler-gap reveal density

### 6.1 Setting

Let $p-1 = ga$ and $q-1 = gb$ with $\gcd(a,b)=1$. An exponent $e$ **reveals** a factor if exactly one of $p-1\mid e$ and $q-1\mid e$ holds. In that case, for every base $x$ coprime to $N$, $x^e\equiv1$ modulo exactly one of the primes, and $\gcd(x^e-1,N)$ is typically a proper factor.

**Definition 6.1.** For positive $a,b$ let $R(a,b) = \#\{k \in [0,ab) : \text{exactly one of } a\mid k,\ b\mid k\}$. For $g\ge1$ let
$$R_g(a,b) = \#\{e\in[0,gab) : g\mid e \text{ and exactly one of } ga\mid e,\ gb\mid e\}.$$

### 6.2 The count and the cancellation of the gap

**Theorem 6.2 (reveal count).** If $a,b\ge1$ and $\gcd(a,b)=1$, then $R(a,b) = a+b-2$.

*Proof.* In $[0,ab)$ there are $b$ multiples of $a$ and $a$ multiples of $b$. Since $a$ and $b$ are coprime, a common multiple is a multiple of $ab$, so the only one in range is $0$. Pointwise, $[\,a\mid k\,] + [\,b\mid k\,] = [\text{exactly one}] + 2[\text{both}]$. Summing over $k$ gives $a + b = R(a,b) + 2$. $\square$

**Theorem 6.3 (the gap cancels).** For every $g\ge1$, $R_g(a,b) = R(a,b)$.

*Proof.* The map $k\mapsto gk$ is a bijection from $[0,ab)$ onto the multiples of $g$ in $[0,gab)$. Since $g>0$, $ga\mid gk \iff a\mid k$ and $gb\mid gk\iff b\mid k$. $\square$

Hence the reveal density among $g$-multiples is
$$\rho(a,b) = \frac{R_g(a,b)}{ab} = \frac{a+b-2}{ab},$$
independent of $g$. Framing such reveals in terms of a "large Euler gap" credits the wrong variable. The cofactors $a,b$ govern the reveal, and the shared factor does not.

### 6.3 Supremum: $1$ versus $1/2$

**Theorem 6.4.** $\rho(a,b) < 1$ for all $a,b\ge1$. For every $\varepsilon>0$ there is $b\ge1$ with $\rho(1,b) > 1-\varepsilon$. Thus $\sup\rho = 1$, and the supremum is not attained.

*Proof.* $ab - (a+b-2) = (a-1)(b-1) + 1 > 0$. Along $a=1$, $\rho(1,b) = (b-1)/b = 1 - 1/b$. $\square$

**Theorem 6.5.** If $a,b\ge2$, then $\rho(a,b)\le 1/2$, with equality if and only if $a=2$ or $b=2$.

*Proof.* $ab - 2(a+b-2) = (a-2)(b-2) \ge 0$, with equality iff one factor vanishes. $\square$

The two claims "$\sup\rho = 1/2$" and "$\sup\rho = 1$" are therefore both correct, on different classes. The value $1$ requires $a=1$, meaning $p-1\mid q-1$. On the class where neither of $p-1$, $q-1$ divides the other, the supremum is $1/2$.

---

## 7. Coverings by divisibility: two guards

**Definition 7.1.** Finite sets $S,T\subset\mathbb Z$ *cover $[1,n]$ by divisibility* if every $k\in\{1,\dots,n\}$ divides some difference $s-t$ with $s\in S$, $t\in T$.

Such coverings arise in a recent framework that would give an integer-factoring exponent of $1/6$. In that framework, with set-size parameters $\alpha,\beta$, the covering budget at the critical point $\alpha=\beta=1/3$ is $n^{2\beta+\alpha} = n$, against a demand of order $\theta(n)\sim n$, so the ratio tends to $1$. The exponent $1/6$ is the **floor** of that framework, with no slack. This is the opposite situation to Section 3: here the constraint is tight. (The consequence for polynomial factorisation, an exponent improvement from $3/2$ to $4/3$, keeps slack of its own. It is the integer exponent $1/6$ that is tight.) In that framework all remaining design freedom lies in the choice of a factorisation $U = U_1\cdots U_\ell$ of a smooth integer, and generic choices are ruled out by counting. The next two results make that counting explicit and protect computational searches against a known artefact.

**Proposition 7.2 (Guard 1: disjointness).** If $S\cap T\neq\emptyset$, then $S,T$ cover $[1,n]$ for every $n$.

*Proof.* If $x\in S\cap T$, then $k\mid x-x = 0$ for every $k$. $\square$

*Example.* $S=\{0,5\}$, $T=\{5,7\}$ "cover" $[1,1000]$. The disjoint pair $S=\{0,5\}$, $T=\{7\}$ fails at $k=3$, since the differences are $-7$ and $-2$.

**Theorem 7.3 (Guard 2: divisor-mass union bound).** If $S\cap T=\emptyset$ and $S,T$ cover $[1,n]$, then
$$n\ \le \sum_{(s,t)\in S\times T} d\big(|s-t|\big),$$
where $d(m)$ is the number of positive divisors of $m$.

*Proof.* Disjointness makes every $s-t$ nonzero. Each $k\le n$ lies in the divisor set of some $|s-t|$, so $[1,n]\subseteq\bigcup_{(s,t)}\mathrm{Div}(|s-t|)$. Take cardinalities and apply the union bound. $\square$

**Corollary 7.4 (counting barrier).** If in addition $d(|s-t|)\le D$ for all $s\in S$, $t\in T$, then $n\le |S|\,|T|\,D$.

Since $d(m) = m^{o(1)}$, a disjoint covering inside $[0,M]$ with $M = n^{O(1)}$ needs $|S|\,|T|\ge n^{1-o(1)}$. Achieving the floor requires differences with unusually many divisors, which is why the framework puts its freedom into factorisations of a smooth integer.

---

## 8. Polylogarithmic preconditions fail only on bounded windows

A published lemma on large-order elements requires $\delta \ge N^{1/4}\log^8 N$. At $\delta = N^{1/3}$ and $N = 2^k$ (base-2 logarithm), raising both sides to the twelfth power turns the condition into
$$\mathrm{Pre}(k):\qquad k^{96}\le 2^k .$$
It had been claimed that the precondition fails for every $N\ge 2^{96}$.

**Theorem 8.1 (bounded violation window).**
1. $\mathrm{Pre}(k)$ fails for every $k$ with $96\le k\le 949$.
2. $\mathrm{Pre}(k)$ holds for every $k\ge 950$.

In particular $\mathrm{Pre}(2048)$ holds (RSA-2048), and the universal failure claim is false.

*Proof sketch.* *Growth step:* for $k\ge139$,
$$(k+1)^{96} = k^{96}(1+1/k)^{96}\le k^{96}e^{96/k}\le 2k^{96},$$
because $96/k\le 96/139 < \ln 2$. Hence $\mathrm{Pre}(k)\Rightarrow\mathrm{Pre}(k+1)$ for $k\ge139$. *Part 2:* check $\mathrm{Pre}(950)$ directly and induct. *Part 1:* check directly that $\mathrm{Pre}(949)$ fails. By the growth step, holding propagates upward on $[139,\infty)$, so failure at $949$ propagates downward to every $k\in[139,949]$. The remaining finitely many $k\in[96,138]$ are checked directly. $\square$

A direct computation shows that the failure set within $k\ge2$ is exactly the interval $[2,949]$. The lesson generalises (Conjecture 2 in Section 13): a polylogarithmic precondition can fail only on a bounded window, so any claim that it "fails for all large $N$" is false.

---

## 9. The Berggren spine

Berggren's matrix $B$ acts on Pythagorean triples by
$$B(a,b,c) = (a+2b+2c,\ 2a+b+2c,\ 2a+2b+3c).$$
Define the **$B$-spine** by $t_0 = (3,4,5)$ and $t_{k+1} = B\,t_k$: $(3,4,5)$, $(21,20,29)$, $(119,120,169)$, $(697,696,985)$, $\ldots$

**Theorem 9.1.** Every $t_k = (a_k,b_k,c_k)$ satisfies $a_k^2+b_k^2=c_k^2$ and $a_k - b_k = (-1)^{k+1}$. Consequently $\gcd(a_k-b_k,N) = 1$ for every integer $N$ and every $k$.

*Proof.* Induction on $k$. $B$ preserves the Pythagorean form. For the difference, $a_{k+1}-b_{k+1} = (a_k+2b_k+2c_k) - (2a_k+b_k+2c_k) = -(a_k-b_k)$, and $a_0-b_0 = -1$. $\square$

Every gcd probe built on $a_k - b_k$ along the spine therefore returns $1$. Five such probes that had been proposed separately collapse to one event, and that event never reveals a factor.

---

## 10. Effective sample size

**Proposition 10.1.** Among the $38{,}635$ primes in $[2^{19},2^{20})$, exactly $163$ have $p-1$ that is $13$-smooth.

This is an exact enumeration. The methodological consequence is that any permutation or resampling test on "smooth-$p-1$" primes in this range has an effective sample size of $163$ distinct primes. A p-value computed by treating repeated draws of the same primes as independent observations overstates significance. Reports should give distinct-prime counts and not draw counts.

---

## 11. Methodological findings (empirical)

The following findings are measurements or audits, not theorems. We include them because they changed which questions are worth asking.

- **Summand balance.** The two summands of Harvey's parameter $s$ have measured ratio $1.000000$ at seven bit sizes, consistent with Remark 2.3.
- **An instrument artefact in a class-number experiment.** A reported linear "class-number penalty" for a complex-multiplication route turned out to be an artefact. The harness took the real part of complex $j$-invariants, which produced polynomials whose roots were not all real and whose Galois group was the full symmetric group $S_h$ instead of the class group. With correct class polynomials the class number cancels exactly, which confirms the earlier negative result for that route.
- **Short-window ergodicity is false as stated.** For $126$ of $429$ primes tested, full-period $\log_2$-uniformity fails. The orbit starts at the rational point $1/N$, which is periodic and lies in the exceptional null set of an almost-everywhere theorem. The corresponding value-level result is a null with empty tail, not a proof.
- **The attention audit.** An audit of the campaign's prior written results found that $145$ of $185$ factoring-relevant results had never been reread over $32$ rounds. These included the decisive negative results on a non-abelian (braid-group) route and on the complex-multiplication route. Three of the round's twelve lines of attack re-derived results already on record. The main bottleneck was attention, not insight.
- **Attribution.** The $N^{1/3}$ large-order-target conjecture is due to Hittmeir, not Harvey.

---

## 12. Algorithms

### 12.1 Slack screening test

*Input:* a convex cost model $f$ on a convex domain $A$, a constraint set $C$, and a computed constrained minimiser $x$.
*Output:* whether removing the constraint can possibly move the optimum.

1. Decide whether $x$ lies in the interior of $C$. For a ceiling $g(x)\le c$ with $g$ continuous, check $g(x) < c$.
2. If yes, report **SLACK**: by Theorem 3.1 the optimum is unchanged when the constraint is removed. Stop.
3. If no, report **ACTIVE**: the optimum may move. Compute the unconstrained optimum, as in Theorem 3.4.

For the Harvey model the test costs $O(1)$. For a max-of-affine model with $k$ terms in $d$ variables it costs one linear program.

### 12.2 Shadow-price target calculator

*Input:* savings $(\sigma_1,\sigma_2)$ on (sweep, pairs). *Output:* the optimal exponent and optimiser.

1. $V \leftarrow \tfrac15 - \tfrac{\sigma_2}5 - \tfrac{2\sigma_1}5$.
2. $(a^*,b^*)\leftarrow(V+\sigma_2,\ V)$.
3. To reach a target $\tau$ with a pair-only filter, solve $\sigma_2 = 5(1/5 - \tau)$. For $\tau = 1/6$ this gives $\sigma_2 = 1/6$.

The cost is $O(1)$. In general one solves for the dual weights once and evaluates $V(0) - \sum w_i\sigma_i$.

### 12.3 Guarded covering search

*Input:* candidate generator for $(S,T)$ (for example from factorisations $U = U_1\cdots U_\ell$), target $n$.

1. **Guard 1.** If $S\cap T\ne\emptyset$, reject the candidate.
2. **Guard 2.** Compute $\mu = \sum_{s,t} d(|s-t|)$. If $\mu < n$, reject (Theorem 7.3).
3. For $k = 1,\dots,n$, test whether some $s - t$ is divisible by $k$. Record the largest $n'$ such that all of $[1,n']$ is covered.
4. If coverage *decreases* with $n$ under a raised resource cap, record the result as a lower bound on what is achievable and not as a measurement.

Step 3 costs $O(n\,|S|\,|T|)$ naively, or $O(|S||T|\,\tau)$ with divisor enumeration of the differences, where $\tau$ is the cost of factoring one difference.

---

## 13. Discussion and future work

Every correction in this note comes from a single object: the dual weight vector $(1/5,2/5,2/5)$ of Harvey's minimax. A filter on term $i$ gains $w_i\sigma_i$. A ceiling moves the optimum if and only if it cuts the dual-optimal face. The slack-constraint lemma is the convex-analytic form of the same statement. We propose three directions.

**Conjecture 1 (dual-weight transfer law).** For any cost model $\max_i(\ell_i(x) - \sigma_i)$ with affine $\ell_i$ and unique dual weights $w$, the optimum equals $V(0) - \sum_i w_i\sigma_i$ exactly, for all sufficiently small $\sigma$. Theorem 4.1 is the three-term case. The general statement should follow from linear-programming duality together with the uniqueness argument used there. It would let one read off the target for any proposed filter from the dual vector alone.

**Conjecture 2 (bounded violation windows).** For all $\alpha>\beta$ and $c>0$, the set $\{k\ge 2 : 2^{\alpha k} < 2^{\beta k}k^{c}\}$ is a bounded interval, with right endpoint $\frac{c}{\alpha-\beta}\log_2\frac{c}{\alpha-\beta}\,(1+o(1))$. Theorem 8.1 settles $c = 96$, $\alpha-\beta = 1/12$, where the window within $k\ge2$ is $[2,949]$. The growth step generalises directly.

**Conjecture 3 (divisor-mass floor for disjoint coverings).** If $S\cap T=\emptyset$, $S,T\subseteq[0,M]$, and $S,T$ cover $[1,n]$ by divisibility, then the divisor mass $\sum_{s,t}d(|s-t|)$ is at least $n$ (Theorem 7.3), and so $|S||T| \ge n/\max_{m\le M}d(m)$. We conjecture that coverings approaching this floor up to $n^{o(1)}$ must draw their differences from integers with highly structured factorisations, as in the primorial-factorisation constructions of Section 7. A guarded search at $n = 10^4$ to $10^6$ (Algorithm 12.3) is the natural first test.

**Open frontier.** In summary:

1. the opening from removing the order-finding hypothesis is closed for a general reason (Theorems 3.1–3.4);
2. the concrete filter target is $N^{1/6}$ (Corollary 4.2). It is not known to be impossible (Theorem 5.1), but the only known free filter gives a factor of $2$;
3. the one remaining constructive direction is a disjoint covering built from factorisations of a smooth integer, searched under both guards.

The deterministic record stays at $N^{1/5}$, which is an upper bound and not a floor.

---

## References

- R. S. Lehman, *Factoring large integers*, Mathematics of Computation 28 (1974), 637–646.
- V. Strassen, *Einige Resultate über Berechnungskomplexität*, Jahresbericht der DMV 78 (1976), 1–8.
- M. Hittmeir, *A babystep-giantstep method for faster deterministic integer factorization*, Mathematics of Computation 87 (2018).
- D. Harvey, *An exponent one-fifth algorithm for deterministic integer factorisation*, Mathematics of Computation 90 (2021).
- G. H. Hardy and E. M. Wright, *An Introduction to the Theory of Numbers*, Oxford University Press.
- B. Berggren, *Pytagoreiska trianglar*, Tidskrift för elementär matematik, fysik och kemi 17 (1934).
- S. Boyd and L. Vandenberghe, *Convex Optimization*, Cambridge University Press, 2004.
