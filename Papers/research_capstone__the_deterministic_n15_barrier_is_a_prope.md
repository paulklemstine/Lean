# Three Roads to One-Fifth: The Baby-Step/Giant-Step Barrier in Deterministic Factoring, and the Divisibility-Covering Wall

**Aristotle**

*October 2026*

---

## Abstract

The best known deterministic integer-factoring algorithms run in time $N^{1/5}$ up to logarithmic factors. In the standard exponent model, their cost is the maximum of three terms: an interior term $a$, a list term $b$ and a residual-search term $\tfrac12 - \tfrac a2 - b$, where $r = N^a$ and $m = N^b$ are the two tunable parameters. We show by three independent arguments that the value $\tfrac15$ is a property of this baby-step/giant-step *motif* as a whole and is not caused by any single term.

1. **Slack constraints.** In an arbitrary linear order, adding a constraint can move an optimum only if the constraint is active at every optimiser. An order-finding term of $N$-exponent $0$ is slack by an unbounded logarithmic factor, so it cannot move $\tfrac15$.
2. **Delete a term.** The general three-leg optimum is exactly $\gamma/(1+u+w/c)$. The list parameter enters only through the benefit-to-cost ratio $w/c$, which is bounded by $1$, and reaching $\tfrac16$ would require $w/c = \tfrac32$. The optimiser $(\tfrac15,\tfrac15)$ is unique, and deleting any one leg lowers the optimum.
3. **Space–time invariant.** Every parameter choice satisfies $3A + 2C \ge 1$, where $A$ is the time exponent and $C$ the space exponent. This bound alone gives the floor $\tfrac15$ again.

We then study the one non-circular exit from the motif, the *divisibility covering* of the index set $[n] = \{1,\dots,n\}$. We prove an exact finite counting wall: if disjoint sets $S, T \subset [0, M]$ cover $[2n]$, then $4^n \le (2n+1)M^{|S||T|}$. Asymptotically this gives $\alpha + \beta_S + \beta_T \ge 1$, and in particular $\alpha + 2\beta \ge 1$. Single-anchor coverings satisfy the stronger bound $\alpha + \beta \ge 1$. Both ends of the wall are realised explicitly: the lcm pair at $(\alpha,\beta) = (1,0)$, which is optimal among single pairs, and the baby-step/giant-step sets themselves, viewed as a covering, at $(0,\tfrac12)$. The interior point $(\tfrac13,\tfrac13)$, where the counting constraint has exactly zero slack, is not constructed. It is the single precisely stated open door. None of the results below is a factoring algorithm or a lower bound for factoring.

---

## 1. Introduction

### 1.1 Context

Deterministic factoring has a short list of exponent records. Trial division costs $N^{1/2}$. The Pollard–Strassen method costs $N^{1/4}$ up to logarithmic factors. The current record of $N^{1/5}$, also up to logarithmic factors, comes from a finer use of the same structure. All of these methods share a pattern that we call the **baby-step/giant-step motif**: an unknown quantity of size $K$ is split into two coordinates of size about $\sqrt K$, two short lists are built, and a collision is found between them.

We stress two facts at the outset.

* $N^{1/5}$ is an **upper bound** on what deterministic methods achieve. It is not a floor. No unconditional superpolynomial lower bound for factoring is known in any general model of computation.
* The results below concern the **exponent model** of the motif. They explain why certain improvements cannot move the exponent, and they identify the one structural change that is not ruled out. They contain no new factoring method.

### 1.2 The exponent model

Write $r = N^a$ for the number of interior "pairs" processed and $m = N^b$ for the length of the list that is built. Ignoring logarithmic factors, the cost of the motif is $N^{E(a,b)}$, where

$$
E(a,b) \;=\; \max\Bigl(a,\; b,\; \tfrac12 - \tfrac a2 - b\Bigr).
$$

We call the three terms the **interior leg**, the **list leg** (or $m$-leg) and the **search leg**. The search leg is the exponent of the residual search that remains after the interior work and the list have each removed part of the original $N^{1/2}$ search space.

### 1.3 Contributions

* **Theorem 2.2:** $E \ge \tfrac15$, with equality exactly at $(\tfrac15,\tfrac15)$, where all three legs are active.
* **Road I (Section 3):** the slack-constraint lemma in an arbitrary linear order, and its application to order-finding terms and redundant extra legs, including a two-scale (exponent, log-power) version.
* **Road II (Section 4):** the closed-form optimum $\gamma/(1+u+w/c)$ of the general three-leg problem, the closed-variable bound, re-split invariance, the exact ratio needed for $\tfrac16$, and the delete-a-leg witnesses.
* **Road III (Section 5):** the space–time invariant $3A + 2C \ge 1$, its tightness, and its consequences.
* **Covering wall (Section 7):** the exact inequality $4^n \le (2n+1)M^{|S||T|}$, its asymptotic forms, the single-anchor wall, the necessity of disjointness, and explicit coverings at both ends of the wall.

The results are collected in the following summary theorem.

> **Capstone Theorem.**
> 1. For all real $a,b$, $E(a,b) \ge \tfrac15$, with equality if and only if $a = b = \tfrac15$. Moreover $3A(a,b) + 2b \ge 1$, where $A(a,b) = \max(a, \tfrac12 - \tfrac a2 - b)$.
> 2. If disjoint finite sets $S,T \subset \mathbb Z \cap [0,M]$ form a divisibility covering of $[2n]$, then $4^n \le (2n+1)\,M^{|S|\,|T|}$.
> 3. For each $k$, the sets $S_k = \{k^2 + kj : 0 \le j < k\}$ and $T_k = \{0,1,\dots,k-1\}$ are disjoint, each has $k$ elements, and they cover $[k^2]$. For each $n$, the pair $\{\operatorname{lcm}(1,\dots,n)\}$, $\{0\}$ covers $[n]$.

---

## 2. The motif exponent

**Definition 2.1 (motif exponent).** For $a, b \in \mathbb R$ (or $\mathbb Q$), let $E(a,b) = \max(a, b, \tfrac12 - \tfrac a2 - b)$.

**Theorem 2.2 (floor, attainment, uniqueness).** For all $a,b$, we have $E(a,b) \ge \tfrac15$. Moreover $E(\tfrac15,\tfrac15) = \tfrac15$, and $E(a,b) = \tfrac15$ holds if and only if $a = b = \tfrac15$.

*Proof.* We have the identity
$$
\tfrac12\, a + 1\cdot b + 1\cdot\bigl(\tfrac12 - \tfrac a2 - b\bigr) = \tfrac12.
$$
Each leg is at most $E$, so $\tfrac52 E \ge \tfrac12$, which gives $E \ge \tfrac15$. At $(\tfrac15,\tfrac15)$ the three legs are $\tfrac15$, $\tfrac15$ and $\tfrac12 - \tfrac1{10} - \tfrac15 = \tfrac15$. Conversely, if $E = \tfrac15$ then $a \le \tfrac15$, $b \le \tfrac15$ and $\tfrac12 - \tfrac a2 - b \le \tfrac15$. The last inequality says $\tfrac a2 + b \ge \tfrac3{10}$. Together with the first two this forces $a = b = \tfrac15$. $\square$

**Corollary 2.3 (all legs active).** If $E(a,b) = \tfrac15$, then $a$, $b$ and $\tfrac12 - \tfrac a2 - b$ are all equal to $\tfrac15$.

The weights $(\tfrac12, 1, 1)$ are a dual certificate for the linear program "minimise $t$ subject to every leg being at most $t$". Section 4 generalises this certificate.

---

## 3. Road I: the slack-constraint lemma

The first argument applies to a very general situation. Let $X$ be any set of parameters and $\alpha$ any linearly ordered set of costs.

**Lemma 3.1 (slack constraint).** Let $f, g : X \to \alpha$, and suppose $v \le f(x)$ for all $x$.

1. *(Lower half.)* $v \le \max(f(x), g(x))$ for all $x$.
2. *(Attainment.)* If $f(x_0) = v$ and $g(x_0) \le v$, then $\max(f(x_0), g(x_0)) = v$.
3. *(Only active constraints move the optimum.)* If $v < \max(f(x), g(x))$ for every $x$, then $v < g(x)$ at every $x$ with $f(x) = v$.

*Proof.* Part 1 holds because $\max(f,g) \ge f \ge v$. Part 2 holds because $\max(v, g(x_0)) = v$. For part 3, take $x$ with $f(x) = v$. Then $v < \max(v, g(x))$, and this is possible only if $v < g(x)$. $\square$

**Corollary 3.2 (collapse is inert on a slack constraint).** Under the hypotheses of Lemma 3.1(2), the problems "minimise $f$" and "minimise $\max(f,g)$" have the same optimal value $v$, attained at the same point $x_0$. Removing a slack constraint, or weakening the assumption it encodes, cannot change the optimum.

**Proposition 3.3 (the order-finding term is slack).** Adding an order-finding term of $N$-exponent $0$ leaves the optimum unchanged:
$$
\max(E(a,b), 0) \ge \tfrac15 \quad\text{for all } a,b, \qquad \max\bigl(E(\tfrac15,\tfrac15),0\bigr) = \tfrac15 .
$$

*Proof.* Apply Lemma 3.1 with $f = E$, $g \equiv 0$, $v = \tfrac15$ and $x_0 = (\tfrac15,\tfrac15)$, using Theorem 2.2. $\square$

**Proposition 3.4 (two-scale version).** Order costs $N^{e}(\log N)^{k}$ lexicographically by the pair $(e,k)$. For all rationals $k,\ell$,
$$
(0, k) < (\tfrac15, \ell), \qquad\text{hence}\qquad \max\bigl((\tfrac15,\ell),(0,k)\bigr) = (\tfrac15,\ell).
$$

The point is that no power of $\log N$, however large, makes the order term active. In the concrete accounting of the motif, the order-finding term sits below the optimum by a factor of about $(\log_2 N)^{0.8}$: about $256$ at $1024$ bits, about $446$ at $2048$ bits, and growing without bound. A recent improvement that removes an assumption about the order therefore cannot move the exponent $\tfrac15$, by Corollary 3.2.

**Corollary 3.5 (redundant extra legs).** Let $g(a,b)$ be any additional leg with $g(\tfrac15,\tfrac15) \le \tfrac15$. Then $\max(E, g) \ge \tfrac15$ everywhere, and equality holds at $(\tfrac15,\tfrac15)$. In particular the fourth ("$M$-") leg of the motif, whose exponent at the optimum does not exceed $\tfrac15$, is exponent-redundant.

---

## 4. Road II: delete a term, and the closed variable

**Definition 4.1 (general three-leg exponent).** For parameters $\gamma, u, w, c$ let
$$
G(a,b) = G_{\gamma,u,w,c}(a,b) = \max\bigl(a,\; c\,b,\; \gamma - u\,a - w\,b\bigr).
$$
Here $c$ is the per-unit **cost** of the list, $w$ is its per-unit **benefit** to the search, $u$ is the benefit of the interior work and $\gamma$ is the initial search exponent. The motif is the case $\gamma = u = \tfrac12$, $w = c = 1$, where $G = E$.

**Theorem 4.2 (general three-leg optimum).** Let $u \ge 0$, $w \ge 0$ and $c > 0$, and put $v = \gamma/(1 + u + w/c)$. Then:

1. $G(a,b) \ge v$ for all $a,b$;
2. $G(v, v/c) = v$.

*Proof.* Write $m = G(a,b)$. Then $a \le m$, $cb \le m$ and $\gamma - ua - wb \le m$. Since $wb = (w/c)(cb) \le (w/c)m$ and $ua \le um$, we get $\gamma \le m + um + (w/c)m$, which is (1). For (2), note that $c\cdot(v/c) = v$ and
$$
\gamma - uv - w\frac{v}{c} = \gamma - v\Bigl(u + \frac wc\Bigr) = v,
$$
using $\gamma = v(1+u+w/c)$. $\square$

**Proposition 4.3 (re-split invariance).** For every $\lambda \ne 0$,
$$
G_{\gamma,u,\lambda w,\lambda c}(a, b/\lambda) = G_{\gamma,u,w,c}(a,b).
$$
Thus the list leg enters only through the ratio $w/c$. Changing the unit in which the list is measured cannot help.

*Proof.* We have $(\lambda c)(b/\lambda) = cb$ and $(\lambda w)(b/\lambda) = wb$. $\square$

**Corollary 4.4 (the closed $m$-variable).** Suppose $0 \le w \le c$ and $c > 0$. Then $G_{1/2,1/2,w,c}(a,b) \ge \tfrac15$ for all $a,b$.

*Proof.* By Theorem 4.2, $G \ge \tfrac12/(\tfrac32 + w/c)$, and since $w/c \le 1$ this is at least $\tfrac12/\tfrac52 = \tfrac15$. $\square$

The hypothesis $w \le c$ is exactly what the motif provides. *Output counting* gives cost weight $c \ge 1$, because producing $m$ distinct list entries takes at least $m$ steps. *Injectivity* gives benefit weight $w \le 1$, because each entry removes at most one candidate from the residual search.

**Proposition 4.5 (what $\tfrac16$ would cost).** Let $w \ge 0$ and $c > 0$. Then
$$
\frac{1/2}{1 + 1/2 + w/c} = \frac16 \iff w = \tfrac32\, c .
$$
The exponent $\tfrac16$ is therefore incompatible with $w \le c$.

*Proof.* The equation is equivalent to $\tfrac32 + w/c = 3$, that is, $w/c = \tfrac32$. $\square$

**Proposition 4.6 (delete a leg; co-binding).** On the box $0 \le a, b \le \tfrac12$, each two-leg subproblem of $E$ has value strictly below $\tfrac15$ somewhere:

| deleted leg | remaining legs | witness $(a,b)$ | value |
|---|---|---|---|
| interior $a$ | $\max(b,\ \tfrac12 - \tfrac a2 - b)$ | $(\tfrac12, \tfrac18)$ | $\tfrac18$ |
| list $b$ | $\max(a,\ \tfrac12 - \tfrac a2 - b)$ | $(0, \tfrac12)$ | $0$ |
| search | $\max(a, b)$ | $(0,0)$ | $0$ |

Together with Corollary 2.3, this shows that all three legs are **co-binding**. Each is active at the optimum, and none can be removed without lowering the floor. An attack on a single leg must therefore change the *structure* (the ratio $w/c$ or the coefficients $\gamma, u$), not just a constant or a logarithmic factor.

---

## 5. Road III: the space–time invariant

The list is stored, so the list leg measures **space**. The interior and search legs measure **time**.

**Definition 5.1.** Let the time exponent be $A(a,b) = \max(a, \tfrac12 - \tfrac a2 - b)$ and the space exponent be $C = b$.

**Theorem 5.2 (space–time invariant).** For all $a, b$,
$$
3A(a,b) + 2b \ge 1 \qquad(\text{i.e. } T^3 S^2 \ge N).
$$
The bound is tight: $3A\bigl(\tfrac{1-2b}{3}, b\bigr) + 2b = 1$ for every $b$.

*Proof.* We have $3A \ge a + 2(\tfrac12 - \tfrac a2 - b) = 1 - 2b$. For tightness, at $a = (1-2b)/3$ the search leg is $\tfrac12 - \tfrac{1-2b}{6} - b = \tfrac{1-2b}{3} = a$, so $A = a$ and $3A + 2b = 1$. $\square$

**Corollary 5.3.**

1. *(A cap on space raises time.)* If $b \le \sigma$, then $A(a,b) \ge (1-2\sigma)/3$.
2. *(Fast time needs space.)* If $A(a,b) < \tfrac15$, then $b > \tfrac15$.
3. *(The invariant re-derives $\tfrac15$.)* $\max(A(a,b), b) \ge \tfrac15$.
4. $\max(A(a,b), b) = E(a,b)$.

*Proof.* Parts 1 and 2 are rearrangements of Theorem 5.2. For part 3, if both $A < \tfrac15$ and $b < \tfrac15$, then $3A + 2b < 1$, a contradiction. Part 4 is associativity and commutativity of $\max$. $\square$

### 5.1 Motif exhaustion

The space–time reading divides the legs into $C$ = space, $A$ = time and a structural **search** component, and it explains why the escapes tried inside the motif are circular.

* *A floor or cap on $C$* is a memory optimisation. By Corollary 5.3(1)–(2) it cannot lower time below what the invariant allows.
* *Lowering $A$* requires reducing a quantity that Theorem 5.2 ties down and that Proposition 4.6 shows is co-binding.
* *Supplying the hidden structure by other means*, so that the search is replaced by a direct computation, amounts to solving a discrete-logarithm or order-finding problem. Those problems are equivalent to factoring under randomised reductions, so this is circular for a deterministic factoring method.

This part is a structural argument about the motif, not a theorem about all algorithms.

---

## 6. Synthesis: three derivations agree

**Theorem 6.1 (three derivations agree).**

1. $\max(E(a,b), 0) \ge \tfrac15$ for all $a,b$ (Road I).
2. $\dfrac{1/2}{1 + 1/2 + 1/1} = \tfrac15$, and $G_{1/2,1/2,1,1}(a,b) \ge \tfrac15$ for all $a,b$ (Road II).
3. $\max(A(a,b), b) \ge \tfrac15$ for all $a,b$ (Road III).
4. $E(a,b) = \tfrac15 \iff a = b = \tfrac15$.

The three arguments are logically independent. The first uses only order-theoretic monotonicity. The second uses the linear-programming certificate of the general shape. The third uses the space–time reading. All three produce the same number, attained at the same unique point. We conclude that the deterministic $\tfrac15$ is **motif-intrinsic**: the only non-circular way to go below it is to change the motif itself.

---

## 7. The exit: divisibility coverings and their counting wall

### 7.1 Definitions

**Definition 7.1 (divisibility covering).** Finite sets $S, T \subset \mathbb Z$ form a *divisibility covering of $[n]$* if for every $i$ with $1 \le i \le n$ there are $s \in S$ and $t \in T$ with $i \mid s - t$.

This is the object behind the covering route of Umans and Wang. In place of a baby-step/giant-step search, one asks for a small pair of sets whose differences, taken together, are divisible by every index in $[n]$. The quality of a covering family is measured by exponents $(\alpha, \beta)$: $|S|, |T| \le n^\beta$ and $\log \max(S \cup T) \le n^\alpha$.

Coverings are monotone (a covering of $[n]$ covers every $[n']$ with $n' \le n$) and translation-invariant (shifting $S$ and $T$ by the same integer preserves the covering).

**Remark 7.2 (the disjointness guard is necessary).** The pair $S = T = \{0\}$ covers every $[n]$, because $0$ is divisible by everything. Every nontrivial statement below therefore assumes $S \cap T = \emptyset$.

### 7.2 The exact counting wall

**Lemma 7.3.** Let $X \neq 0$ be a natural number such that every $i \in [m]$ divides $X$. Then $\binom mk \mid X$ for every $0 \le k \le m$.

*Proof.* Fix a prime $p$ and let $e = v_p\binom mk$. By Kummer's theorem, $e$ is the number of carries when adding $k$ and $m-k$ in base $p$, so $e \le \lfloor \log_p m \rfloor$ and hence $p^{e} \le m$. Then $p^{e} \in [m]$ divides $X$, so $v_p(X) \ge e$. Since this holds for every prime, $\binom mk \mid X$. $\square$

**Theorem 7.4 (counting wall, exact finite form).** Let $S, T \subset \mathbb Z$ be disjoint, with every element in $[0,M]$, and suppose they form a divisibility covering of $[2n]$. Then
$$
4^n \;\le\; (2n+1)\, M^{|S|\,|T|}.
$$

*Proof.* Let $X = \bigl|\prod_{s\in S}\prod_{t\in T}(s-t)\bigr|$. By disjointness every factor is nonzero, so $X \ne 0$. Each factor has absolute value at most $M$, so $X \le M^{|S||T|}$. Every $i \in [2n]$ divides some factor and hence divides $X$. By Lemma 7.3 with $m = 2n$ and $k = n$, the central binomial coefficient $\binom{2n}{n}$ divides $X$, so $\binom{2n}n \le X$. Finally $\binom{2n}{n}$ is the largest of the $2n+1$ terms in $\sum_j \binom{2n}{j} = 4^n$, so $4^n \le (2n+1)\binom{2n}{n}$. $\square$

**Corollary 7.5 (logarithmic form).** Under the hypotheses of Theorem 7.4 with $M \ge 1$,
$$
n \log 4 \;\le\; \log(2n+1) + |S|\,|T| \log M .
$$

**Theorem 7.6 (asymptotic wall, asymmetric form).** Let $\alpha, \beta_1, \beta_2 \in \mathbb R$. Suppose that for arbitrarily large $n$ there exist disjoint $S, T$ with elements in $[0, M]$, $M \ge 1$, covering $[2n]$, with $|S| \le (2n)^{\beta_1}$, $|T| \le (2n)^{\beta_2}$ and $\log M \le (2n)^{\alpha}$. Then $\alpha + \beta_1 + \beta_2 \ge 1$.

*Proof.* Suppose $\gamma = \alpha + \beta_1 + \beta_2 < 1$, and let $\delta = \max(\gamma, \tfrac12) < 1$. By Corollary 7.5,
$$
n\log 4 \le \log(2n+1) + (2n)^{\gamma} \le \log(2n+1) + (2n)^{\delta}.
$$
Dividing by $n$, the right-hand side tends to $0$ because $\delta < 1$, while the left-hand side is the constant $\log 4$. This is a contradiction for $n$ large enough, and such $n$ exist by hypothesis. $\square$

**Corollary 7.7 (symmetric wall).** For coverings with $|S|,|T| \le (2n)^\beta$ and $\log M \le (2n)^\alpha$, we have $\alpha + 2\beta \ge 1$.

**Corollary 7.8 (single-anchor wall).** If moreover $|T| \le 1$ (a "star" covering anchored at one point), then $\alpha + \beta \ge 1$. At $\beta = \tfrac13$ such coverings need $\alpha \ge \tfrac23$, twice the zero-slack value.

*Proof.* Apply Theorem 7.6 with $\beta_2 = 0$, since $|T| \le 1 = (2n)^0$. $\square$

### 7.3 The two ends of the wall are realised

**Theorem 7.9 (the lcm end, $(\alpha,\beta) = (1,0)$).** For every $n$, the pair $S = \{\operatorname{lcm}(1,\dots,n)\}$, $T = \{0\}$ is a divisibility covering of $[n]$. It is optimal among single pairs: if $s \ne t$ lie in $[0,M]$ and $\{s\},\{t\}$ cover $[n]$, then $\operatorname{lcm}(1,\dots,n) \le M$.

*Proof.* Each $i \le n$ divides the lcm. For optimality, every $i \le n$ divides $s - t \ne 0$, so $\operatorname{lcm}(1,\dots,n) \mid |s-t|$, and therefore $\operatorname{lcm}(1,\dots,n) \le |s-t| \le M$. $\square$

Because $\log \operatorname{lcm}(1,\dots,n) \sim n$ by the prime number theorem, this pair has $\alpha = 1$ and $\beta = 0$.

**Corollary 7.10 (a classical bound).** For all $n$, $4^n \le (2n+1)\operatorname{lcm}(1,\dots,2n)$.

*Proof.* Apply Theorem 7.4 to the lcm covering of $[2n]$ with $M = \operatorname{lcm}(1,\dots,2n)$ and $|S| = |T| = 1$. $\square$

**Theorem 7.11 (the baby-step/giant-step end, $(\alpha,\beta) = (0,\tfrac12)$).** For $k \ge 1$ let
$$
S_k = \{k^2 + kj : 0 \le j < k\} \quad(\text{giant steps}), \qquad T_k = \{0, 1, \dots, k-1\}\quad(\text{baby steps}).
$$
Then $|S_k| = |T_k| = k$, the sets are disjoint, all elements lie in $[0, 2k^2]$, and $(S_k, T_k)$ is a divisibility covering of $[k^2]$.

*Proof.* The differences $s - t = k^2 + kj - r$, with $0 \le j, r < k$, take every value in the interval $[k^2-k+1,\ 2k^2-k]$, which consists of $k^2$ consecutive integers. Explicitly, every $d \in [0, k^2)$ is written as $d = k\lfloor d/k\rfloor + (d \bmod k)$, and then $k^2 + k\lfloor d/k\rfloor - (k-1-(d \bmod k)) = (k^2-k+1) + d$. Any $i \le k^2$ consecutive integers contain a multiple of $i$. Disjointness holds because every element of $S_k$ is at least $k^2 > k-1$. $\square$

Here $\log M = O(\log n)$, which gives $\alpha = 0$, and $|S|=|T| = \sqrt n$, which gives $\beta = \tfrac12$. **The motif itself, read as a covering, sits on the wall.** Substituting it into Theorem 7.4 gives $4^n \le (2n+1)(2k^2)^{k^2}$ whenever $2n \le k^2$.

### 7.4 The zero-slack point

Both constructed ends lie on the line $\alpha + 2\beta = 1$, since $1 + 2\cdot0 = 0 + 2\cdot\tfrac12 = 1$. The interior point
$$
\alpha = \beta = \tfrac13, \qquad \alpha + 2\beta = 1,
$$
has **exactly zero slack** in the counting constraint. In the covering approach to deterministic factoring, this point corresponds to improving the exponent from $\tfrac15$ to $\tfrac16$. A lemma on primorial arithmetic progressions provides one building block for structured coverings. A second known lemma excludes *generic* factorizations, so only structured constructions could reach the point. **No covering with $(\alpha,\beta) = (\tfrac13,\tfrac13)$ is constructed here.** The door is open and unclaimed.

---

## 8. Algorithms

**Algorithm 8.1 (explicit baby-step/giant-step witness).** *Input:* $k \ge 1$ and $1 \le i \le k^2$. *Output:* $s \in S_k$, $t \in T_k$ and $q$ with $s - t = qi$.

1. $a \leftarrow k^2 - k + 1$ (the smallest difference).
2. $q \leftarrow \lceil a / i \rceil$ (the first multiple of $i$ that is at least $a$).
3. $d \leftarrow qi - a$, so that $0 \le d < i \le k^2$.
4. $s \leftarrow k^2 + k\lfloor d/k \rfloor$ and $t \leftarrow k - 1 - (d \bmod k)$.
5. Return $(s, t, q)$.

This takes $O(1)$ arithmetic operations, and its correctness is exactly the proof of Theorem 7.11. Producing witnesses for all of $[k^2]$ costs $O(k^2)$.

**Algorithm 8.2 (covering verification and wall check).** Given $n$ and sets $S, T$, check for each $i \in [n]$ whether $\exists s,t:\ i \mid s - t$. This costs $O(n|S||T|)$ operations. Alternatively, compute $X = \prod(s-t)$ once and test $i \mid X$; this test is necessary but not sufficient for covering, so it can only rule sets out. Then compare $4^{\lfloor n/2\rfloor}$ with $(2\lfloor n/2\rfloor + 1) M^{|S||T|}$.

**Algorithm 8.3 (three-leg optimiser).** Given $(\gamma,u,w,c)$ with $u, w\ge 0$ and $c>0$, return $v = \gamma/(1+u+w/c)$ and the optimiser $(v, v/c)$. Certify the result with the dual weights $(u, w/c, 1)$, normalised by their sum. This is $O(1)$ and agrees with brute-force grid minimisation.

---

## 9. Computational illustrations

The following computations illustrate the theorems. They are finite checks and exploratory searches, not proofs.

* An exact rational grid search over $[0,\tfrac12]^2$ with step $\tfrac1{120}$ finds the minimum $E = \tfrac15$ at the single point $(\tfrac15,\tfrac15)$.
* For $k = 2,3,5,8$, the sets $(S_k,T_k)$ cover $[2\lfloor k^2/2\rfloor]$, and $\binom{2n}{n}$ divides $\prod |s-t|$, as the proof of Theorem 7.4 predicts.
* For $n = 1, 3, 5, 10, 20$, the classical bound $4^n \le (2n+1)\operatorname{lcm}(1,\dots,2n)$ holds with ample room. For example, at $n = 20$ the comparison is $1.1\times10^{12}$ against $2.2\times10^{17}$.
* *Exploratory search.* Let $M_k(n)$ be the least $M$ for which disjoint $k$-element sets in $[0,M]$ cover $[n]$. Two lower bounds are immediate: some difference must be a nonzero multiple of $n$, and $2k$ distinct nonnegative integers are needed, so $M_k(n) \ge \max(n, 2k-1)$. Brute force gives $M_1(n) = 1, 2, 6, 12, 60$ for $n = 1,\dots,5$, which is $\operatorname{lcm}(1,\dots,n)$, consistent with Theorem 7.9. It gives $M_2(n) = 3,3,3,4,5,6,7,8$ for $n=1,\dots,8$, followed by a jump to $M_2(9) = 18$ and $M_2(10) = 20$. For $k = 3$ it gives $M_3(n) = \max(n,5)$ for all $n \le 17$.

---

## 10. Discussion

**What is and is not claimed.** All statements in Sections 2–7 are unconditional theorems about explicit finite or exponent-level objects. They do not bound the complexity of factoring from below. They bound what a particular algorithmic *motif* can achieve within its own cost model, and they show that the obvious routes out of that model are either inert (slack), structurally blocked (co-binding legs and the closed variable) or circular (equivalent to factoring).

**Five screening lemmas.** The results give a reusable checklist for any proposed improvement of the motif:

1. *Slack constraint* (Lemma 3.1): does the proposal act on a term that is active at the optimum?
2. *Delete a term* (Proposition 4.6): all three legs are co-binding.
3. *Three-way balance* (Theorem 4.2): the optimum is $\gamma/(1+u+w/c)$, so one of $\gamma$, $u$ or $w/c$ must change.
4. *Symmetric-readout vacuity:* re-labelling or re-reading the same three legs, for example by re-splitting the list as in Proposition 4.3, leaves the optimum unchanged.
5. *Closed variable* (Corollary 4.4): $w \le c$ by injectivity and output counting.

Proposals based on order-finding, pair filters, the $m$-leg or side channels fail at least one of these tests.

**The remaining door.** The divisibility-covering formulation replaces search by covering, and its own counting wall $\alpha + 2\beta \ge 1$ is tight at both ends. Whether the interior point $(\tfrac13,\tfrac13)$ can be reached is a concrete question in elementary number theory.

---

## 11. Future directions

**Conjecture 11.1 (degrees-of-freedom wall for designed coverings).** Fix $\beta < \tfrac12$. Call a disjoint covering of $[n]$ *CRT-designed* if, for every prime $p \in (|S||T|, n]$, the residues modulo $p$ of all elements of $S \cup T$ are fixed by congruence conditions. Then any such covering with $|S|,|T| \le n^\beta$ has $\log M \ge n^{1-\beta-o(1)}$. That is, designed coverings meet the single-anchor line $\alpha + \beta \ge 1$ and never the counting line. *Heuristic:* a prime $p$ larger than the number of differences cannot be hit "for free", as happens in the interval regime of Theorem 7.11. It must be paid for with about $\log p$ bits inside one of only $2n^\beta$ numbers, and summing over $p \in (n^{2\beta}, n]$ costs about $n$ bits. Corollary 7.8 proves the case $|T| = 1$.

**Conjecture 11.2 (no interior hybrid).** For every $\beta \in (0,\tfrac12)$ there is no family of coverings of $[n]$ with $|S|,|T| \le n^\beta$ and $\log M \le n^{1-2\beta+o(1)}$. In particular $(\tfrac13,\tfrac13)$ would be unattainable, and the true feasible region would be $\{\alpha+\beta \ge 1\} \cup \{\beta \ge \tfrac12\}$. *Heuristic:* the two constructed ends use incompatible mechanisms, interval coincidence (which needs $k^2 \ge n$) and design (which pays $n$ bits). A union-bound estimate $e^{2kn^\alpha}\prod_{p > k^2}(k^2/p) < 1$ suggests that no mixture does better. Proving or refuting this would settle whether the covering door is real.

**Conjecture 11.3 (exact small-$k$ covering numbers).** $M_k(n) = \max(n, 2k-1)$ whenever $n \le k^2 + 2k$, and $\log M_k(n) \asymp n/k$ as $n \to \infty$ with $k$ fixed. For fixed $k$ the asymmetric wall gives only $\log M \ge (n\log 2 - O(\log n))/k^2$, while the design heuristic predicts $n/k$, so fixed-$k$ data separates the two lines. The searches of Section 9 agree with the first part for $k \le 3$ in the range searched.

**Further directions.** These include extending Lemma 7.3-type divisibility arguments to weighted coverings (where each difference may be used only for indices in a prescribed residue class), and settling the remaining coset-separation headroom in the related Galois-group classification (for example $\mathrm{AGL}(1,8)$, with a cap of about $2.807$ bits). The latter is a completeness gap and does not threaten the barrier.
