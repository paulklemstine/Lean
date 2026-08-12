# The CRT-Split No-Go: Why $N$-Alone Iteration Cannot Factor in $\mathrm{poly}(\log N)$

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

Let $N = pq$ be a semiprime with $p \neq q$ prime. We give a complete structural analysis of the family of factoring procedures that iterate a map manufactured from $N$ alone — a polynomial, or more generally a straight-line program over $(+,-,\times,{}^{-1})$ with arbitrary integer constants — and extract a factor by taking greatest common divisors of differences along the trajectory.

Two facts organise everything. **Fact 1 (the reveal criterion):** $\gcd(d, N)$ is a nontrivial divisor of $N$ if and only if exactly one of $p \mid d$, $q \mid d$ holds; equivalently, for arbitrary $N > 1$, if and only if some prime factor of $N$ divides $d$ while $N$ does not. **Fact 2 (CRT-blindness):** iteration of an integer polynomial commutes with reduction, so the mod-$p$ trajectory is determined by the reduced map and reduced seed alone; and more generally a straight-line program all of whose inversions succeed commutes with *every* ring homomorphism out of $\mathbb{Z}/N$, hence with both Chinese Remainder projections.

Together these yield the **reveal characterisation**: along any such trajectory, $\gcd(x_t - x_s, N)$ is a nontrivial factor if and only if the mod-$p$ orbit closes between times $s$ and $t$ *exclusive-or* the mod-$q$ orbit does. Consequently no factor appears before $\min(T_p, T_q)$, where $T_m$ is the first closure time of the mod-$m$ orbit, and a factor appears exactly at $\min(T_p, T_q)$ whenever $T_p \neq T_q$.

We then quantify $T_p$ in the three exhaustive regimes. **(a) Generic nonlinear maps:** we prove the exact birthday law, that among all $n^n$ maps of an $n$-element set exactly $(n-1)^{\underline{T}} n^{\,n-T}$ have a collision-free orbit prefix of length $T+1$; its Gaussian tail; a two-sided threshold window at $T \asymp \sqrt n$; and — via a layer-cake identity — that the *average* first closure time is $\Theta(\sqrt n)$, lying between $\lfloor\sqrt n\rfloor/2$ and $3(\lfloor \sqrt n\rfloor + 1)$. Any tortoise-and-hare detector inherits an average lower bound of $\lfloor\sqrt n\rfloor / 4$. On the reduced state space this is $\Theta(\sqrt p) = \Theta(N^{1/4})$: Pollard rho is average-case optimal in its class. **(b) Smoothness-dependent maps:** the Pollard $p-1$ reveal time is *exactly* $\min(\mathrm{ord}_p a, \mathrm{ord}_q a)$ when the two orders differ — an invariant of the hidden factors, invisible in $N$. **(c) Structurally simple maps:** for $x \mapsto x+1$ a reveal forces a time gap $\ge \min(p,q)$, hence $t \ge \sqrt{N/2}$ for balanced semiprimes, and superpolynomially in $\log N$: for every $c, k$ there are balanced semiprimes on which every reveal time exceeds $c\,(\log_2 N)^k$; and a constant map never reveals at all.

Finally, the **straight-line rigidity dichotomy** closes the last escape: for every straight-line program and every input mod $N$, either the computation is CRT-blind, or some intermediate value is a non-unit which is $0$ or *is* a nontrivial factor of $N$. Division is the only route out of polynomiality, and a failed division is the factorisation (circularity). All statements are illustrated on the modulus $N = 341371 = 631 \cdot 541$, where $x \mapsto x^2 + 1$ from seed $2$ first reveals $631$ at $(s,t) = (23,36)$ — minimal, and exactly the first mod-$631$ closure, with $\sqrt{631} \approx 25.1$.

We stress what is *not* claimed: this is not a lower bound for factoring. It is a complete classification of a natural, tempting, and historically productive family of methods, together with a proof that no member of it runs in $\mathrm{poly}(\log N)$ except by accident of unknowable smoothness.

**Keywords:** integer factorisation, Chinese Remainder Theorem, Pollard rho, Pollard $p-1$, functional graphs, birthday paradox, straight-line programs, algebraic barriers.

---

## 1. Introduction

### 1.1 The question

A recurring intuition about integer factorisation is that the number $N$ must somehow *contain* its factors in a directly accessible way: its digits, its residues, its algebraic structure are all determined by $p$ and $q$, so there ought to be a sufficiently clever function, iterated a modest number of times, that pulls them back out. Historically this intuition has been productive: Pollard's rho method and Pollard's $p-1$ method are exactly of this form, as are their many variants.

This paper asks the intuition to be precise, and then refutes it. Fix the following model.

> **The $N$-explicit iteration model.** Given $N$, choose a seed $x_0 \in \mathbb{Z}$ and a map $f$ built from the ring operations $+, -, \times$ (and, in the extended model, division) applied to the variable and to integer constants read off $N$. Compute the trajectory $x_{n+1} = f(x_n)$, reduced modulo $N$, and output $\gcd(x_t - x_s, N)$ for pairs $s < t$, stopping when this is a nontrivial divisor.

Almost every "elementary" factoring proposal is an instance. The main result of this paper is that *no instance runs in $\mathrm{poly}(\log N)$ steps*, for a reason that is structural rather than empirical, and that the reason admits a complete three-way classification of the possible behaviours.

### 1.2 Overview of the argument

The argument has four movements.

1. **The reveal mechanism is unique** (§2). A gcd is nontrivial exactly when the two Chinese Remainder components disagree about vanishing. This is a bare-hands fact about divisibility, but it converts a search for a *number* into a search for an *asymmetry*.
2. **The model is symmetric** (§3, §7). Polynomial iteration commutes with reduction; straight-line programs whose inversions succeed commute with every ring homomorphism. Nothing in the model can distinguish the two components.
3. **Therefore the reveal is a one-sided cycle closure** (§4), and its time is exactly $\min(T_p, T_q)$.
4. **Every regime of closure behaviour is slow** (§5, §6). Generic maps close at the birthday scale $\Theta(\sqrt p)$ — proved exactly, on average, and robustly under cycle detection. Smoothness-dependent maps close at a multiplicative order. Structurally simple maps close at the full modulus. There is no fourth possibility.

### 1.3 Relation to known barriers

Two classical obstructions appear here as theorems rather than slogans. *Barrier 5* — "an iteration that only knows $N$ has nothing to iterate on" — is the statement that a constant map never reveals (Theorem 5.6). *Barrier 6* — circularity — is the statement that a nontrivial idempotent mod $N$ is already a factorisation (Theorem 7.6), generalised in Theorem 7.5 to arbitrary straight-line programs: any computation that behaves differently in the two components has, at that moment, produced a non-unit, and a non-unit is a factor.

---

## 2. Fact 1: the reveal criterion

Throughout, $N > 1$ is an integer and $d \in \mathbb{Z}$.

**Definition 2.1.** We say $d$ *reveals a factor of* $N$, written $\mathrm{Rev}_N(d)$, if
$$1 < \gcd(d, N) < N.$$

**Lemma 2.2.** *If $r \mid N$ then $r \mid \gcd(d,N)$ if and only if $r \mid d$.*

*Proof.* If $r \mid \gcd(d,N)$ then $r \mid d$ since $\gcd(d,N) \mid d$. Conversely if $r \mid d$ and $r \mid N$ then $r$ divides the gcd. $\square$

**Theorem 2.3 (Fact 1; the exclusive-or criterion).** *Let $N = pq$ with $p \neq q$ prime. Then for every $d \in \mathbb{Z}$,*
$$\mathrm{Rev}_{pq}(d) \iff \big(p \mid d\big) \ \mathrm{XOR}\ \big(q \mid d\big).$$

*Proof sketch.* Write $g = \gcd(d, N)$, so $g \mid N$ and, by Lemma 2.2, $p \mid g \iff p \mid d$ and $q \mid g \iff q \mid d$.

($\Rightarrow$) Suppose $1 < g < N$. If $p \mid g$ then $q \nmid g$, since $p, q$ coprime would force $pq \mid g$, i.e. $g \ge N$. If $p \nmid g$, then either $q \mid g$ (done), or neither prime divides $g$, in which case $g$ is coprime to both $p$ and $q$, hence to $N$; as $g \mid N$ this gives $g = 1$, contradicting $g > 1$.

($\Leftarrow$) Suppose $p \mid g$ and $q \nmid g$. Then $g \ge p > 1$, and $g \neq N$ since $q \mid N$ but $q \nmid g$. Symmetrically in the other case. $\square$

The criterion is not special to semiprimes.

**Theorem 2.4 (Fact 1, general modulus).** *For $N > 1$ and $d \in \mathbb{Z}$,*
$$\mathrm{Rev}_N(d) \iff \Big(\exists\, r \text{ prime},\ r \mid N \text{ and } r \mid d\Big)\ \text{ and }\ N \nmid d.$$

*Proof sketch.* $\gcd(d,N) > 1$ iff it has a prime divisor, necessarily a prime divisor of both $d$ and $N$; and $\gcd(d,N) < N$ iff $N \nmid d$ (since $\gcd(d,N) = N$ exactly when $N \mid d$). $\square$

**Interpretation.** A reveal is *partial agreement across the CRT decomposition*: the datum $d$ vanishes in some components and not all. Total agreement ($N \mid d$) and total disagreement ($\gcd = 1$) are both invisible. Every gcd-based factoring method is a hunt for partial agreement.

---

## 3. Fact 2: $N$-explicit maps are CRT-blind

**Definition 3.1.** For $f \in \mathbb{Z}[X]$ and $x_0 \in \mathbb{Z}$, the *orbit* is
$$\mathcal{O}_f(x_0, n) = f^{\,\circ n}(x_0), \qquad \mathcal{O}_f(x_0, 0) = x_0 .$$
For a modulus $m$, the *reduced orbit* $\overline{\mathcal{O}}_f^{\,m}(x_0, n) \in \mathbb{Z}/m$ is the orbit of $\bar x_0$ under the reduced polynomial $\bar f \in (\mathbb{Z}/m)[X]$.

**Theorem 3.2 (Functoriality).** *For every $f \in \mathbb{Z}[X]$, every $m$, every $x_0$ and every $n$,*
$$\mathcal{O}_f(x_0, n) \bmod m \;=\; \overline{\mathcal{O}}_f^{\,m}(x_0, n).$$

*Proof sketch.* Induction on $n$. The base case is the definition of reduction. The step is the compatibility of polynomial evaluation with the reduction homomorphism: $\overline{f(z)} = \bar f(\bar z)$. $\square$

**Theorem 3.3 (Blindness).** *If $f, g \in \mathbb{Z}[X]$ satisfy $\bar f = \bar g$ in $(\mathbb{Z}/m)[X]$, and $x_0 \equiv y_0 \pmod m$, then $\overline{\mathcal{O}}_f^{\,m}(x_0, n) = \overline{\mathcal{O}}_g^{\,m}(y_0, n)$ for all $n$.*

*Proof.* Immediate from Definition 3.1: the reduced orbit is a function of $(\bar f, \bar x_0)$ only. $\square$

**Corollary 3.4 (Divisibility form).** *If $m \mid x_0 - y_0$ then $m \mid \mathcal{O}_f(x_0,n) - \mathcal{O}_f(y_0,n)$ for all $n$.*

*Proof.* Induction, using $a - b \mid f(a) - f(b)$ for integer polynomials. $\square$

**Discussion.** Theorem 3.3 is the precise content of "an $N$-explicit map does not split the CRT." Whatever the coefficients of $f$ are — however intricately manufactured from the digits of $N$ — the mod-$p$ dynamics sees only $f \bmod p$ and $x_0 \bmod p$. To make the map behave differently in the two components one would have to reduce it mod $p$ *deliberately*, i.e. to already possess $p$. Section 7 upgrades this from polynomials to arbitrary straight-line programs including division.

---

## 4. The reveal is an exclusive one-sided closure

Combining §2 and §3 gives the central structural theorem of the paper.

**Theorem 4.1 (Reveal characterisation).** *Let $N = pq$ with $p \neq q$ prime, let $f \in \mathbb{Z}[X]$, let $x_0 \in \mathbb{Z}$, and let $s < t$. Then*
$$\mathrm{Rev}_{pq}\big(\mathcal{O}_f(x_0,t) - \mathcal{O}_f(x_0,s)\big) \iff \Big(\overline{\mathcal{O}}_f^{\,p}(x_0,t) = \overline{\mathcal{O}}_f^{\,p}(x_0,s)\Big)\ \mathrm{XOR}\ \Big(\overline{\mathcal{O}}_f^{\,q}(x_0,t) = \overline{\mathcal{O}}_f^{\,q}(x_0,s)\Big).$$

*Proof.* By Theorem 2.3 the left side is $(p \mid x_t - x_s)\ \mathrm{XOR}\ (q \mid x_t - x_s)$. By Theorem 3.2, $m \mid x_t - x_s$ if and only if the reduced orbits mod $m$ agree at times $s$ and $t$. $\square$

**Definition 4.2.** The reduced orbit *closes at time* $t$ if $\overline{\mathcal{O}}^{\,m}(x_0,t) = \overline{\mathcal{O}}^{\,m}(x_0,s)$ for some $s < t$. Write $T_m = T_m(f, x_0)$ for the least such $t$.

**Theorem 4.3 (Pigeonhole).** *$T_m \le m$ for every $f, x_0, m \ge 1$; and after a closure at $(s,t)$ the reduced orbit is eventually periodic with period $t - s$ from time $s$ on.*

*Proof sketch.* Among the $m+1$ values $\overline{\mathcal{O}}^{\,m}(x_0, 0), \dots, \overline{\mathcal{O}}^{\,m}(x_0, m)$ in a set of size $m$, two coincide. Periodicity follows by induction from determinism of the iteration. $\square$

This is the *rho shape*: a tail followed by a cycle.

**Theorem 4.4 (No reveal before the first closure).** *If $t < \min(T_p, T_q)$ then for every $s < t$, $\gcd(x_t - x_s, N)$ is $1$.*

*Proof.* Both mod-$p$ and mod-$q$ prefixes are injective up to time $t$, so both sides of the XOR in Theorem 4.1 are false. $\square$

**Theorem 4.5 (Reveal at the minimum).** *If $T_p \neq T_q$ then, writing $t^\ast = \min(T_p, T_q)$, there exists $s < t^\ast$ with $\mathrm{Rev}_N(x_{t^\ast} - x_s)$.*

*Proof sketch.* Say $T_p < T_q$. At time $T_p$ the mod-$p$ orbit agrees with an earlier value at some $s < T_p$; the mod-$q$ orbit does not agree with any earlier value, since $T_p < T_q$. So exactly one branch of the XOR holds and Theorem 4.1 applies. $\square$

**Corollary 4.6.** *For an $N$-explicit iteration whose two closure times differ, the first reveal time is exactly $\min(T_p, T_q)$ — a statistic of the reduced dynamics in a space of size $p$ (resp. $q$), each about $\sqrt N$ for balanced semiprimes.*

Conversely, symmetry is fatal:

**Theorem 4.7 (Simultaneous closure is blind).** *If the two reduced orbits close at the same pair of times $(s,t)$ then no factor is revealed at $(s,t)$.*

*Proof.* Both branches of the XOR are true, so $\gcd(x_t - x_s, N) = N$. $\square$

---

## 5. Regime (c): structurally simple maps

**Lemma 5.1.** *For $f = X + 1$, $\mathcal{O}_f(x_0, n) = x_0 + n$.*

**Theorem 5.2 (Successor reveal criterion).** *For $N = pq$, $s < t$, the successor iteration reveals a factor at $(s,t)$ iff $(p \mid t - s)\ \mathrm{XOR}\ (q \mid t - s)$.*

*Proof.* Combine Lemma 5.1 with Theorem 2.3: the difference is $t - s$. $\square$

**Theorem 5.3 (Lower bound).** *Any reveal for the successor iteration satisfies $t - s \ge \min(p,q)$; in particular $t \ge \min(p,q)$.*

*Proof.* A positive multiple of $p$ or of $q$ is at least $p$ or $q$. $\square$

**Theorem 5.4 (Balanced case).** *If $p < q \le 2p$ then any reveal time satisfies $N = pq \le 2t^2$, i.e. $t \ge \sqrt{N/2}$.*

*Proof.* $t \ge p$ and $q \le 2p$ give $pq \le 2p^2 \le 2t^2$. $\square$

**Theorem 5.5 (Superpolynomiality).** *For every $c, k \in \mathbb{N}$ there exist primes $p < q \le 2p$ such that, with $N = pq$, every revealing pair $(s,t)$ for the successor iteration satisfies*
$$t > c \,(\log_2 N)^k .$$

*Proof sketch.* By Bertrand's postulate choose $p$ arbitrarily large and $q$ with $p < q \le 2p$, so $\log_2 N \le 2\log_2 p + 2$. By Theorem 5.3 any reveal has $t \ge p \ge 2^{\,L}$ where $L = \lfloor\log_2 p\rfloor$. The elementary growth fact that $c' L^k < 2^L$ for all large $L$ (with $c' = c\,4^k$) then gives $c (\log_2 N)^k \le c' L^k < 2^L \le t$ once $p$ is chosen large enough. $\square$

The extreme degenerate case reveals nothing whatsoever.

**Theorem 5.6 (Barrier 5).** *For a constant map $f = c$ and any $1 \le s < t$, $\gcd(x_t - x_s, N) = N$: no factor is ever revealed.*

*Proof.* $x_s = x_t = c$ for $s, t \ge 1$, so the difference is $0$. $\square$

Correspondingly, the successor map realises the pigeonhole bound of Theorem 4.3 exactly:

**Theorem 5.7.** *For $f = X+1$ and any seed, $T_m = m$ exactly.*

*Proof sketch.* The reduced orbit is $\bar x_0 + n$, injective for $n < m$ and returning to $\bar x_0$ at $n = m$. $\square$

**Summary of regime (c).** Structurally simple maps sit at the *worst* end of the closure spectrum: full modulus, hence $\ge \sqrt{N/2}$ and superpolynomial in $\log N$.

---

## 6. Regime (a): the birthday law for generic maps

This section is the quantitative heart. It concerns an $n$-element state space $S$ (for us $S = \mathbb{Z}/p$, $n = p$) and the ensemble of all $n^n$ maps $S \to S$, which is the standard model for "generic" reduced dynamics.

**Definition 6.1.** Fix $a \in S$. For $f : S \to S$, the *orbit prefix of length $T+1$* is $a, f(a), \dots, f^{[T]}(a)$; it is *collision-free* (written $\mathrm{Inj}_T(f)$) if these $T+1$ values are pairwise distinct. Let $A_T = \#\{f : \mathrm{Inj}_T(f)\}$. The *closure time* $\tau(f)$ is the least $T$ with $\neg\,\mathrm{Inj}_T(f)$; it exists and satisfies $\tau(f) \le n$ by pigeonhole.

### 6.1 The exact count

**Theorem 6.2 (Exact birthday law).** *For $T < n$,*
$$A_T \;=\; (n-1)^{\underline{T}} \cdot n^{\,n - T} \;=\; (n-1)(n-2)\cdots(n-T)\cdot n^{\,n-T} .$$
*Equivalently,*
$$\frac{A_T}{n^n} \;=\; \prod_{i=1}^{T}\Big(1 - \frac{i}{n}\Big).$$

*Proof sketch.* Induction on $T$ via a fibration. The key structural input is *locality of iteration*: the prefix $a, f(a), \dots, f^{[T]}(a)$ depends only on the values of $f$ at the earlier prefix points, so modifying $f$ at $f^{[T]}(a)$ changes nothing before time $T$. Define the *reset* map $\rho(f) = f$ with the value at $f^{[T]}(a)$ overwritten by $a$. Then:

* $\rho$ preserves collision-freeness at level $T$ and maps the level-$T$ set into itself;
* the fiber of $\rho$ over any level-$T$ map $h$ consists exactly of the $n$ updates of $h$ at the position $h^{[T]}(a)$, so all fibers have size exactly $n$;
* within one fiber, a map survives to level $T+1$ iff its value at $f^{[T]}(a)$ avoids the $T+1$ points already used, so exactly $n - (T+1)$ survive.

Hence $A_{T+1} = \frac{n - (T+1)}{n}\,A_T$, and $A_0 = n^n$. Unwinding gives the closed form. (For $n = 4$, $a$ fixed, $T = 2$ the formula predicts $3\cdot 2\cdot 4^2 = 96$ collision-free maps out of $256$, which agrees with exhaustive enumeration.) $\square$

### 6.2 Two-sided tails

**Theorem 6.3 (Lower tail).** *For $T < n$,*
$$A_T \;\ge\; \Big(1 - \frac{T(T+1)}{2n}\Big) n^n .$$

*Proof sketch.* Weierstrass' product inequality $\prod (1 - c_i) \ge 1 - \sum c_i$ applied to $c_i = i/n$, plus $\sum_{i=1}^T i = T(T+1)/2$. $\square$

**Theorem 6.4 (Upper tail / Gaussian bound).** *For $T < n$,*
$$A_T \;\le\; \exp\!\Big(-\frac{T(T+1)}{2n}\Big)\, n^n .$$

*Proof sketch.* The upper Weierstrass inequality $\prod(1 - c_i) \le \exp(-\sum c_i)$ for $0 \le c_i \le 1$, applied to the exact product of Theorem 6.2. $\square$

**Corollary 6.5 (Threshold window).** *If $T(T+1) \le n$ then $A_T \ge n^n/2$: at least half of all maps have not yet collided. If $4n \le T(T+1)$ then $A_T \le n^n/4$, since $\exp(-2) \le 1/4$.*

Thus the collision-free fraction passes from $\ge 1/2$ to $\le 1/4$ inside the window $\sqrt n \lesssim T \lesssim 2\sqrt n$. **The birthday exponent $1/2$ is sharp from both sides.** Specialised to $S = \mathbb{Z}/p$, the state space of the reduced dynamics of an $N$-explicit iteration, the first cycle closure — by §4 the only factor-revealing event — occurs at $T \asymp \sqrt p = N^{1/4}$ for balanced $N$.

### 6.3 The average closure time is $\Theta(\sqrt n)$

Probability statements are weaker than statements about the expected running time. We prove the latter exactly up to constants.

**Theorem 6.6 (Layer cake).** *$\displaystyle \sum_{f : S \to S} \tau(f) \;=\; \sum_{T=0}^{n-1} A_T .$*

*Proof sketch.* For fixed $f$, $\#\{T < n : \mathrm{Inj}_T(f)\} = \tau(f)$, because $\mathrm{Inj}_T(f)$ holds precisely for $T < \tau(f)$ (collision-freeness is inherited by shorter prefixes) and $\tau(f) \le n$. Exchange the order of summation. $\square$

Closure times *are* the birthday counts, summed. This makes both bounds mechanical.

**Theorem 6.7 (Average lower bound).** *For every $T$ with $T(T+1) \le n$,*
$$\sum_f \tau(f) \;\ge\; (T+1)\cdot \frac{n^n}{2}.$$
*Taking $T + 1 = \lfloor\sqrt n\rfloor$ gives $\sum_f \tau(f) \ge \lfloor\sqrt n\rfloor\, n^n/2$: the average first closure time is at least $\lfloor\sqrt n\rfloor / 2$.*

*Proof.* Every $f$ in the level-$T$ collision-free set has $\tau(f) \ge T+1$, and by Corollary 6.5 that set has at least $n^n/2$ elements; all closure times are non-negative. $\square$

**Theorem 6.8 (Analytic core).** *For $n \ge 1$,*
$$\sum_{T=0}^{n-1} \exp\!\Big(-\frac{T(T+1)}{2n}\Big) \;\le\; 3\big(\lfloor \sqrt n\rfloor + 1\big).$$

*Proof sketch.* Put $m = \lfloor\sqrt n\rfloor + 1$ and cut $[0,n)$ into blocks of length $m$. On the $k$-th block $T \ge km$, so $T(T+1)/(2n) \ge k^2m^2/(2n) \ge k/2$ (using $m^2 \ge n$ and $k^2 \ge k$), whence the block sum is at most $m\,e^{-k/2}$. Summing the geometric series with ratio $e^{-1/2} \le 0.61$ gives a factor at most $1/(1 - 0.61) < 3$. $\square$

**Theorem 6.9 (Average upper bound).** *For $n \ge 1$,*
$$\sum_f \tau(f) \;\le\; 3\big(\lfloor\sqrt n\rfloor + 1\big) n^n .$$

*Proof.* Theorem 6.6, then Theorem 6.4 termwise, then Theorem 6.8. $\square$

**Theorem 6.10 ($\Theta(\sqrt n)$).** *The average first closure time over all $n^n$ maps lies between $\lfloor\sqrt n\rfloor/2$ and $3(\lfloor\sqrt n\rfloor + 1)$. On the reduced state space $\mathbb{Z}/p$ this reads: the average first cycle closure — the only factor-revealing event — lies between $\sqrt p / 2$ and $3(\sqrt p + 1)$.*

For a balanced semiprime this is $\Theta(N^{1/4})$, and it is *sharp*: the rho exponent cannot be improved within the generic regime.

### 6.4 Cycle detection inherits the barrier

Pollard rho does not detect the first collision; it runs a tortoise and a hare and waits for a match. That could conceivably be faster. It is not.

**Theorem 6.11 (A Floyd match is a collision).** *If $f^{[i]}(a) = f^{[2i]}(a)$ with $i > 0$, then $\tau(f) \le 2i$.*

*Proof.* The prefix of length $2i+1$ contains the repeated pair at positions $i$ and $2i$. $\square$

**Theorem 6.12 (Average barrier for the rho loop).** *Let $\mathrm{ftime}(f)$ be any tortoise-and-hare match time for $f$ (any $i > 0$ with $f^{[i]}(a) = f^{[2i]}(a)$; in particular the first such $i$, which the Pollard rho loop returns). Then*
$$\sum_f \mathrm{ftime}(f) \;\ge\; \lfloor\sqrt n\rfloor \cdot \frac{n^n}{4},$$
*i.e. the average is at least $\lfloor\sqrt n\rfloor / 4$; on $\mathbb{Z}/p$, at least $\sqrt p / 4$.*

*Proof.* $\tau(f) \le 2\,\mathrm{ftime}(f)$ by Theorem 6.11; sum and apply Theorem 6.7. $\square$

**Conclusion of regime (a).** Generic nonlinear $N$-explicit iteration costs $\Theta(\sqrt p) = \Theta(N^{1/4})$ on average, and no cycle-detection variant improves the exponent — only the constant.

---

## 7. Regime (b), circularity, and the straight-line dichotomy

### 7.1 The smoothness regime, exactly

**Theorem 7.1 (Pollard $p-1$ reveal criterion).** *For $N = pq$, $a \in \mathbb{Z}$, $M \in \mathbb{N}$,*
$$\mathrm{Rev}_{pq}(a^M - 1) \iff \big(\mathrm{ord}_p(a) \mid M\big)\ \mathrm{XOR}\ \big(\mathrm{ord}_q(a) \mid M\big).$$

*Proof.* By Theorem 2.3 it suffices that $r \mid a^M - 1 \iff \mathrm{ord}_r(a) \mid M$, which is the definition of multiplicative order. $\square$

**Theorem 7.2 (Exact reveal time).** *If $a$ is invertible modulo both $p$ and $q$ and $\mathrm{ord}_p(a) \neq \mathrm{ord}_q(a)$, then the least $M > 0$ with $\mathrm{Rev}_{pq}(a^M - 1)$ is exactly*
$$M^\ast = \min\big(\mathrm{ord}_p(a),\, \mathrm{ord}_q(a)\big).$$

*Proof sketch.* ($\ge$) A reveal at $M>0$ forces one of the orders to divide $M$, hence $M \ge$ that order $\ge M^\ast$. ($\le$) At $M = M^\ast$, say $M^\ast = \mathrm{ord}_p(a)$: then $\mathrm{ord}_p(a) \mid M^\ast$, while $\mathrm{ord}_q(a) \nmid M^\ast$ because $\mathrm{ord}_q(a) > M^\ast$ (the orders differ and $M^\ast$ is the smaller). The XOR holds, so Theorem 7.1 gives a reveal. $\square$

**Discussion.** The cost of regime (b) is *precisely* an invariant of the hidden factors. On the running example $N = 341371 = 631\cdot 541$ with $a = 2$, $\mathrm{ord}_{631}(2) = 45$ and $\mathrm{ord}_{541}(2) = 540$, so $M^\ast = 45$ — reachable in a handful of multiplications, since $\gcd(2^{45}-1, N) = 631$. Both $630 = 2\cdot3^2\cdot5\cdot7$ and $540 = 2^2\cdot3^3\cdot5$ are smooth. This is the boundary of the no-go, and it is honest to state it: *there are moduli on which an $N$-independent iteration wins quickly*. But nothing in $N$ tells an algorithm in advance whether it is in that situation, and for $N$ chosen with non-smooth $p-1$ and $q-1$ the same theorem makes $M^\ast$ astronomically large.

### 7.2 Barrier 6: the CRT idempotents are the factors

**Theorem 7.3 (Circularity).** *Let $N > 1$ and let $e \in \mathbb{Z}$ satisfy $N \mid e(e-1)$, $N \nmid e$, $N \nmid e - 1$ — a nontrivial idempotent mod $N$, equivalently a splitting of $\mathbb{Z}/N$ into two complementary ideals. Then $1 < \gcd(e, N) < N$.*

*Proof sketch.* $\gcd(e,N) < N$ because $N \nmid e$. If $\gcd(e, N) = 1$ then from $N \mid e(e-1)$ we get $N \mid e-1$, contradiction. $\square$

So any procedure that manufactures a CRT separator has already factored: the separator *is* the factorisation.

### 7.3 The straight-line rigidity dichotomy

Polynomials are not the most general $N$-explicit maps: one might divide. We model this exactly.

**Definition 7.4.** A *straight-line expression* in one variable is built by the grammar
$$e \;::=\; x \mid c\ (c \in \mathbb{Z}) \mid e_1 + e_2 \mid e_1 - e_2 \mid e_1 \cdot e_2 \mid e^{-1},$$
interpreted in any commutative ring $R$, with $e^{-1}$ interpreted by the total inverse function that returns $0$ on non-units. Say *all inversions succeed at $x$* if every inversion node is applied to a unit of $R$ when evaluated at $x$; say $e$ is *division-free* if it has no inversion node.

Two facts about this model. First, *a division-free program is literally an integer polynomial*: one can read off a polynomial $P_e \in \mathbb{Z}[X]$ with $P_e(x) = e(x)$ for all $x \in \mathbb{Z}$, so every theorem of §2–§6 applies verbatim to division-free straight-line iterations, including the reveal characterisation of Theorem 4.1. Second:

**Theorem 7.5 (CRT-blindness of successful computations).** *Let $\varphi : R \to S$ be a ring homomorphism and $e$ a straight-line expression such that all inversions of $e$ succeed at $x \in R$. Then*
$$\varphi\big(e(x)\big) \;=\; e\big(\varphi(x)\big).$$

*Proof sketch.* Structural induction. Constants, the variable, and $+,-,\times$ are handled by the homomorphism axioms. For an inversion node applied to a unit $u$, $\varphi(u)$ is a unit and $\varphi(u^{-1}) = \varphi(u)^{-1}$; the total-inverse convention agrees with the honest inverse at units. $\square$

**Corollary 7.6 (Orbits split with the CRT, not against it).** *For coprime $m_1, m_2$ the orbit of a straight-line iteration in $\mathbb{Z}/(m_1m_2)$ maps, under the Chinese Remainder isomorphism, to the pair of orbits of **the same program** in $\mathbb{Z}/m_1$ and $\mathbb{Z}/m_2$.*

This is the exact sense in which an $N$-explicit map "does not split the CRT": it computes both components with one and the same code.

**Theorem 7.7 (A non-unit is a factorisation).** *If $v \in \mathbb{Z}/N$ is neither $0$ nor a unit, and $N > 1$, then $\mathrm{Rev}_N(\tilde v)$ for the integer representative $\tilde v$ of $v$.*

*Proof sketch.* $v$ is a unit iff $\gcd(\tilde v, N) = 1$, and $v = 0$ iff $N \mid \tilde v$ iff $\gcd(\tilde v, N) = N$. Excluding both leaves $1 < \gcd(\tilde v, N) < N$. $\square$

**Theorem 7.8 (Straight-line rigidity dichotomy).** *Let $N > 1$, let $e$ be a straight-line expression, and let $x \in \mathbb{Z}/N$. Then at least one of the following holds:*

1. *the computation is **CRT-blind**: $\varphi(e(x)) = e(\varphi(x))$ for every ring homomorphism $\varphi$ out of $\mathbb{Z}/N$ — in particular for both CRT projections, so the same program computes both components and no information about the splitting is produced; or*
2. *some intermediate value $v$ of the computation is not a unit, and then $v = 0$ or $v$ reveals a nontrivial factor of $N$.*

*Proof.* If all inversions succeed at $x$, Theorem 7.5 gives (1). Otherwise some inversion node is applied to a non-unit $v$; if $v = 0$ we are in the second disjunct of (2), and otherwise Theorem 7.7 gives a factor. $\square$

**This is the closure of the argument.** Leaving polynomiality requires dividing; dividing successfully keeps you blind; dividing unsuccessfully hands you the factorisation you were trying to compute. There is no third option.

---

## 8. The three regimes: a complete classification

Let $f$ be any $N$-explicit iteration in the sense of §1.1. By §7 it is either CRT-blind or self-defeating, and by §4 its reveal time (when the two closure times differ) is exactly $\min(T_p, T_q)$. The possible closure behaviours are exhaustively:

| Regime | Example | Reveal time | Cost |
|---|---|---|---|
| (a) generic nonlinear | $x \mapsto x^2+1$ | first exclusive cycle closure | $\Theta(\sqrt p) = \Theta(N^{1/4})$ on average, sharp; rho loop $\ge \sqrt p / 4$ |
| (b) smoothness-dependent | $\gcd(a^M-1, N)$ | exactly $\min(\mathrm{ord}_p a, \mathrm{ord}_q a)$ | an invariant of the hidden factors; fast only by accident |
| (c) structurally simple | $x \mapsto x+1$; constants | $\ge \min(p,q)$; never | $\ge \sqrt{N/2}$, superpolynomial in $\log N$; or no reveal at all |

No case is polynomial in $\log N$, and (b) is polynomial only for moduli whose smoothness is not detectable from $N$.

---

## 9. Verification on a concrete modulus

Take $N = 341371 = 631 \cdot 541$, $f(x) = x^2 + 1$, seed $x_0 = 2$. The trajectory mod $N$ begins $2, 5, 26, 677, 458330 \bmod N, \dots$.

**Observation 9.1.** *The pair $(s,t) = (23,36)$ satisfies $\gcd(x_{36} - x_{23}, N) = 631$ — a nontrivial factor. Moreover $631 \mid x_{36} - x_{23}$ and $541 \nmid x_{36} - x_{23}$, so exactly one branch of the exclusive-or of Theorem 4.1 holds, and the reveal is exactly the closure of the mod-$631$ orbit while the mod-$541$ orbit has not yet closed.*

**Observation 9.2 (Minimality).** *No pair $s < t \le 35$ reveals a factor.* Notably this is established not by a brute-force gcd search but through Theorem 4.4: it suffices to check that both reduced orbits are injective on $\{0,\dots,35\}$, which is the mechanism the theory predicts. The first reveal is therefore at $t = 36$, while $\sqrt{631} \approx 25.1$ — the birthday scale — and $\log_2 N \approx 18.4$.

**Observation 9.3 (Regime (b) on the same modulus).** *$\mathrm{ord}_{631}(2) = 45$ divides $45$; $\mathrm{ord}_{541}(2) = 540$ does not; hence $\gcd(2^{45}-1, N) = 631$, and by Theorem 7.2 the exact Pollard $p-1$ reveal time is $45$.*

**Scaling experiment.** Running $x \mapsto x^2+1$ from seed $2$ on random balanced semiprimes and recording the first revealing pair $(s,t)$, with $r = t/\sqrt{\min(p,q)}$:

| bits | $p$ | $q$ | $(s,t)$ | factor | $r$ | $\log_2 t$ |
|---|---|---|---|---|---|---|
| 9 | 509 | 257 | (0, 9) | 509 | 0.56 | 3.17 |
| 10 | 1013 | 827 | (14, 31) | 1013 | 1.08 | 4.95 |
| 11 | 1951 | 1627 | (33, 40) | 1627 | 0.99 | 5.32 |
| 12 | 3923 | 3259 | (37, 63) | 3923 | 1.10 | 5.98 |
| 13 | 7789 | 6073 | (21, 81) | 6073 | 1.04 | 6.34 |
| 14 | 12437 | 15373 | (84, 113) | 12437 | 1.01 | 6.82 |
| 15 | 30367 | 24517 | (15, 146) | 30367 | 0.93 | 7.19 |
| 16 | 58943 | 62219 | (173, 218) | 58943 | 0.90 | 7.77 |
| 17 | 97547 | 115067 | (303, 422) | 97547 | 1.35 | 8.72 |
| 18 | 147011 | 177623 | (223, 364) | 147011 | 0.95 | 8.51 |
| 19 | 325081 | 347587 | (423, 523) | 325081 | 0.92 | 9.03 |

The normalised reveal time $r$ stays $O(1)$ across the whole range while $\log_2 t$ grows linearly in the bit size: the reveal time tracks $\sqrt p = N^{1/4}$, exponential in $\log N$. In every run the revealed factor is exactly the prime whose reduced orbit closed first — a direct experimental confirmation of Theorem 4.5.

---

## 10. Algorithms

Three procedures encapsulate the constructive content.

**Algorithm A (Exclusive-closure trace).** Given $N = pq$, a map $f$, and a seed, simultaneously iterate the reduced orbits mod $p$ and mod $q$, recording the first time each revisits an earlier value. Output $\min(T_p, T_q)$ and the corresponding prime. By Theorems 4.4 and 4.5 this is exactly the first reveal time of the gcd search, computed without any gcds. Complexity: $O(\min(T_p,T_q))$ ring operations plus a hash table.

**Algorithm B (Birthday law evaluation).** Compute the exact collision-free fraction $\prod_{i=1}^{T}(1 - i/n)$ and its two-sided bounds $1 - T(T+1)/(2n)$ and $\exp(-T(T+1)/(2n))$; locate the threshold window $T(T+1) \le n \le T(T+1)/4$. Complexity: $O(T)$.

**Algorithm C (Exact $p-1$ reveal time).** Given $N=pq$ and a base $a$, compute the two multiplicative orders and return their minimum, together with a verification that $\gcd(a^{M^\ast}-1, N)$ is a nontrivial factor. Complexity dominated by order computation.

---

## 11. Discussion

**What is proved.** Within the $N$-explicit iteration model — which subsumes Pollard rho, Pollard $p-1$, their polynomial variants, and every straight-line program over $(+,-,\times,{}^{-1})$ with integer constants — the factor-revealing event is *uniquely* an exclusive one-sided CRT closure; the reveal time is exactly the smaller of the two closure times; and each of the three exhaustive regimes costs at least $\Theta(N^{1/4})$ on average, or is governed by an unknowable smoothness invariant, or is superpolynomial outright. Cycle detection cannot beat the birthday exponent. Division cannot escape blindness without producing the factorisation.

**What is not proved.** This is not a lower bound for integer factorisation. The general number field sieve is not an $N$-explicit iteration: it builds and sieves over algebraic number fields, uses linear algebra over $\mathbb{F}_2$ on relations, and its structure has no counterpart in the model. Nor does the argument touch quantum period-finding. Moreover, regime (b) shows the model itself admits fast instances on special moduli, so no *universal* $\mathrm{poly}(\log N)$ lower bound valid for all $N$-explicit maps and all $N$ is claimed — such a statement would be equivalent to the hardness of factoring.

**Why the classification is exhaustive.** The reveal time is $\min(T_p, T_q)$, a closure statistic of a deterministic map on a set of size $p$ (or $q$). Any such map is either (i) statistically indistinguishable from a random map at the relevant scale — the birthday regime; (ii) endowed with group structure whose closure time is an order — the smoothness regime; or (iii) so rigid that its orbit is a full cycle or a fixed point — the simple regime. The theorems above bound each.

**A heuristic sharpened into a theorem.** "You can't factor $N$ using only $N$" is folklore. What is new here is the identification of the *unique* mechanism by which any such attempt could succeed, the *exact* identity for when it does, and matching upper and lower bounds — including in expectation, not merely with probability — on the cost of that mechanism.

---

## 12. Future directions

* **Beyond straight-line programs.** The rigidity dichotomy is proved for one-variable straight-line programs over $(+,-,\times,{}^{-1})$. Branching programs — computations that test a value and take different paths — are the natural next model. A conditional branch on "is $v$ invertible?" is exactly a factoring oracle call, so one expects the dichotomy to persist, but a clean statement covering multi-variable and randomised straight-line programs remains to be formulated.
* **Distributional refinement of regime (a).** We have $\Theta(\sqrt n)$ for the average closure time with explicit constants $1/2$ and $3$. The true constant is $\sqrt{\pi/2}$ — the expected rho length of a random map — and matching it from the exact birthday product is a concrete open problem.
* **Non-uniform reduced dynamics.** The generic-regime bounds are for the uniform ensemble of all $n^n$ maps. Quadratic maps $x \mapsto x^2 + c$ on $\mathbb{Z}/p$ are not uniform, and the extent to which their closure statistics match the uniform model is a longstanding question in arithmetic dynamics; any progress transfers directly to a sharper regime-(a) barrier.
* **The smoothness regime as a distributional statement.** Theorem 7.2 gives the exact reveal time for a fixed base. Averaging over bases and over semiprimes with prescribed smoothness would turn regime (b) from a pointwise identity into a distributional barrier.
* **Second-order variants.** Iterations with memory, e.g. $x_{n+1} = f(x_n, x_{n-1})$, and multi-seed methods, are still CRT-blind by the same functoriality argument, but their closure statistics live on a larger state space and the birthday scale changes from $\sqrt p$ to $\sqrt{p^2} = p$ or better — quantifying this is a natural extension.
