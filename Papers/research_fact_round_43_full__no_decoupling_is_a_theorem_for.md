# No-Decoupling for Quadratic-Form Sieving: Column Space, Split Set, and the Complete-Cost Rule

**Aristotle**

*October 2026*

---

## Abstract

In the quadratic sieve and its multi-polynomial variants, the linear algebra over $\mathbb{F}_2$ has one column for every prime that can divide a sieved value. It is classical that for $x^2-N$ only primes at which $N$ is a quadratic residue can occur. We ask whether any of the three standard per-instance enhancements — the large-prime (partial-relation) variation, Silverman's multiple polynomials, and adaptive choice of the smoothness bound $B$ — can move the column space off this *split set*. We show that none can, and that all three cases follow from a single identity: for a quadratic form $f(x)=Ax^2+Bx+C$ with discriminant $D=B^2-4AC$,

$$4A\,f(x) = (2Ax+B)^2 - D.$$

Consequently every prime divisor of every value of $f$ makes $D$ a square, and for odd $p\nmid A$ the column set of $f$ *equals* the split set of $D$. A Silverman family has a common discriminant and therefore one common column set (not the "quarter" obtained from two unrelated discriminants); the large prime of a partial relation is itself split, and a large-prime pair has odd-exponent support inside the small split set; and an adaptive bound only reparametrises the ray $Q\approx m/2$. We isolate the one surviving lever — extra polynomials buy rows at zero marginal column cost, so $|\mathcal S_B(D)|+1$ smooth values always contain a square regardless of the number of forms — and show it is gated by $B^2M\lesssim\sqrt{N/2}$, derived from an exact minimax $\min_A\max(N/A,\,AM^2-N/A)=M\sqrt{N/2}$; the gate fails by a factor exceeding $600$ for all $N<2^{42}$ with $B,M\ge 1000$. Finally, we prove that the elasticity of a total cost $S+L$ is the cost-share-weighted average of the component elasticities and is positive iff $L'>-S'$; this explains an observed sign inversion between sieve-only and complete-cost pricing and yields a methodological rule. Two earlier claims in this line of work (a "$\approx 1/4$" multi-polynomial column fraction and a favourable direction for adaptive $B$) are corrected. A cubic example marks the exact boundary of the theory.

---

## 1. Introduction

The quadratic sieve (QS) factors an odd composite $N$ by producing many congruences $X_i^2\equiv V_i \pmod N$ in which the $V_i$ are $B$-smooth, and then finding a subset whose product of $V_i$ is a perfect square. Writing each smooth $V_i$ as an exponent vector modulo $2$ turns the last step into finding a dependency among vectors in $\mathbb{F}_2^{Q}$, where $Q$ is the number of primes that can actually occur — the **columns**. Each smooth value is a **row**. Once the number of rows exceeds $Q$, a dependency exists, and with probability at least about $1/2$ per dependency it yields a nontrivial factor via $\gcd(X-Y,N)$.

For the basic polynomial $x^2-N$, a prime $p$ dividing a value satisfies $x^2\equiv N\pmod p$; hence only primes with $\left(\frac{N}{p}\right)\in\{0,1\}$ appear. We call this set the **split set**. It contains roughly half of the primes up to $B$.

Practical sieves add three enhancements:

* **Large primes (LP):** retain values that are $B$-smooth apart from a single prime $r$ in $(B,L]$, and combine pairs sharing $r$.
* **Multiple polynomials (MPQS):** sieve a family of quadratic forms $f_t(x)=A_tx^2+B_tx+C_t$, each over a short interval $[-M,M]$.
* **Adaptive $B$:** choose the smoothness bound per instance.

A natural question is whether any of these can **decouple** the column space from the split set: open columns outside it, intersect several split sets to shrink it, or move the number of columns independently of the factor-base size. If so, it would give a new lever on the cost of reaching a factor.

**Main conclusions.**

1. *No-decoupling is a theorem for all three channels* (Sections 3–5). The single reason: any form whose discriminant is tied to $N$ forces the split set, so column space and split set are the same object.
2. *The full cost inverts the sign* (Section 7). Pricing only the sieve makes larger $Q$ look favourable; pricing sieve plus $\mathbb{F}_2$ elimination makes it unfavourable. A general identity explains when and why.
3. *One lever survives, on the row side* (Section 6): the number of polynomials is orthogonal to the number of columns. Its useful regime is limited by an explicit gate that fails by nearly three orders of magnitude at 41–42 bits.
4. *Boundary* (Section 8): outside differences of squares — e.g. cubic values — non-split columns appear.

We also record two corrections to earlier claims made in this series of investigations (Section 9).

---

## 2. Definitions and notation

Throughout, $p$ denotes a rational prime and $\mathbb{Z}/p\mathbb{Z}$ the field with $p$ elements. An integer $D$ is called a **square mod $p$** if there is $r\in\mathbb{Z}/p\mathbb{Z}$ with $r^2\equiv D$; we include $D\equiv 0$.

**Definition 2.1 (Quadratic form, value, discriminant).** A *quadratic form* (in the sieving sense) is an integer polynomial $f(x)=Ax^2+Bx+C$. Its *value* at $x\in\mathbb{Z}$ is $f(x)$, and its *discriminant* is $\operatorname{disc} f = B^2-4AC$. The basic QS polynomial $x^2-N$ is the form $(1,0,-N)$ with discriminant $4N$.

**Definition 2.2 (Factor base, split set).** For a bound $B$, the *factor base* $\mathcal P_B$ is the set of primes $p\le B$. For an integer $D$ the *split set* (or set of *admissible primes*) is
$$\mathcal S_B(D) = \{\,p\le B \text{ prime} : D \text{ is a square mod } p\,\}.$$

**Definition 2.3 (Column set).** The *column set* of a form $f$ (up to $B$) is the set of primes $p\le B$ dividing at least one value $f(x)$, $x\in\mathbb{Z}$. For a family $(f_t)_{t\in\mathcal T}$ it is the union over $t$.

**Definition 2.4 (Silverman family).** Fix $N$ (or $kN$ with a small multiplier $k$). For a prime $q$ with $\left(\frac{N}{q}\right)=1$, set $A=q^2$, choose $b$ with $b^2\equiv N\pmod{q^2}$ (a Hensel lift of a square root mod $q$), and put $c=(b^2-N)/A\in\mathbb{Z}$. The form $f(x)=Ax^2+2bx+c$ satisfies
$$\operatorname{disc} f=(2b)^2-4Ac=4N, \qquad A\,f(x)=(Ax+b)^2-N.$$
A family of such forms (varying $q$) is a *Silverman family*; all members share the discriminant $4N$.

**Definition 2.5 (Partial relation, LP-pair).** A *partial relation* is an equation $x^2-N=s\cdot r$ with $s$ $B$-smooth and $r$ prime. Two partial relations sharing $r$ form an *LP-pair*; their product $(s_1r)(s_2r)$ is the combined relation.

**Definition 2.6 (Elasticity).** For a positive differentiable cost $C(u)$ with $u=\log Q$, the *elasticity* of $C$ with respect to $Q$ is $\frac{d}{du}\log C = C'(u)/C(u)$.

---

## 3. The discriminant identity and the Column Theorem

**Lemma 3.1 (Discriminant identity).** For every form $f=(A,B,C)$ and every integer $x$,
$$4A\,f(x) = (2Ax+B)^2-\operatorname{disc} f.$$

*Proof.* Expand: $(2Ax+B)^2-(B^2-4AC)=4A^2x^2+4ABx+4AC=4A(Ax^2+Bx+C)$. $\square$

**Lemma 3.2 (Quadratic character constraint).** If a prime $p$ divides $y^2-D$ for some integer $y$, then $D$ is a square mod $p$.

*Proof.* $y^2\equiv D\pmod p$. $\square$

**Theorem 3.3 (Columns force the split set).** Let $f$ be any form and $p$ any prime (including $p=2$ and primes dividing $A$). If $p\mid f(x)$ for some $x$, then $\operatorname{disc} f$ is a square mod $p$.

*Proof.* If $p\mid f(x)$ then $p\mid 4Af(x)=(2Ax+B)^2-\operatorname{disc}f$ by Lemma 3.1; apply Lemma 3.2 with $y=2Ax+B$. $\square$

**Theorem 3.4 (The split set is exhausted — Column Theorem).** Let $p$ be an odd prime with $p\nmid A$. Then
$$\exists\,x\in\mathbb{Z}:\ p\mid f(x) \iff \operatorname{disc}f \text{ is a square mod } p.$$
Hence, away from the primes dividing $2A$, the column set of $f$ equals the split set $\mathcal S_B(\operatorname{disc} f)$.

*Proof.* ($\Rightarrow$) is Theorem 3.3. ($\Leftarrow$) Let $r^2\equiv \operatorname{disc}f\pmod p$. Since $p$ is odd and $p\nmid A$, $2A$ is invertible mod $p$; let $y\equiv (r-B)(2A)^{-1}$ and take $x$ any integer representative of $y$. Then $2Ax+B\equiv r$, so by Lemma 3.1, $4A f(x)\equiv r^2-\operatorname{disc}f\equiv 0$. Since $4A$ is a unit mod $p$, $p\mid f(x)$. $\square$

*Remark 3.5.* Theorem 3.3 has no hypotheses at all: no prime outside the split set of the discriminant ever appears, regardless of the leading coefficient. Theorem 3.4 is the converse and shows the inclusion is an equality at all but finitely many primes. "Column space" and "split set" are the same object.

**Lemma 3.6 (Square-class invariance).** Let $D,s\in\mathbb{Z}$ and $p\nmid s$. Then $Ds^2$ is a square mod $p$ iff $D$ is.

*Proof.* If $D\equiv r^2$ then $Ds^2\equiv (rs)^2$. Conversely if $Ds^2\equiv r^2$ then, $s$ being invertible, $D\equiv (rs^{-1})^2$. $\square$

In particular $kN$ and $4kN$ have the same split set at every odd prime, so the normalisation of a Silverman family (discriminant $kN$ or $4kN$) is immaterial.

---

## 4. Multiple polynomials: a shared discriminant is one constraint

**Theorem 4.1 (Multi-polynomial support).** Let $(f_t)_{t\in\mathcal T}$ be any family of forms with $\operatorname{disc} f_t = D$ for all $t$. If $p\le B$ is a prime dividing some value $f_t(x)$, then $p\in\mathcal S_B(D)$. Thus the column set of the whole family is contained in the single split set $\mathcal S_B(D)$.

*Proof.* Theorem 3.3 applied to $f_t$, using $\operatorname{disc}f_t=D$. $\square$

**Theorem 4.2 (Identical column sets).** If $\operatorname{disc}f=\operatorname{disc}g$, then for every odd prime $p$ dividing neither leading coefficient,
$$\big(\exists x: p\mid f(x)\big)\iff\big(\exists x: p\mid g(x)\big).$$

*Proof.* Both sides are equivalent, by Theorem 3.4, to "$\operatorname{disc}f=\operatorname{disc}g$ is a square mod $p$". $\square$

**Theorem 4.3 (A conjunction of identical constraints equals one).** For a nonempty family with common discriminant $D$,
$$\{p\in\mathcal P_B : \operatorname{disc} f_t \text{ is a square mod } p \text{ for every } t\} = \mathcal S_B(D).$$

*Proof.* Each condition in the conjunction is the same condition "$D$ is a square mod $p$"; a nonempty conjunction of copies of one statement is that statement. $\square$

**Theorem 4.4 (Silverman's square relation).** If $A=a^2$, then for all $x$
$$(2a)^2 f(x)\equiv (2Ax+B)^2 \pmod{\operatorname{disc} f}.$$
So with $\operatorname{disc}f=kN$ (or $4kN$), each value of a Silverman form is, up to the square factor $(2a)^2$, a square modulo $N$ — which is what lets values from different forms be multiplied together in a single congruence of squares.

*Proof.* Lemma 3.1 with $4A=(2a)^2$ gives $(2a)^2f(x)-(2Ax+B)^2=-\operatorname{disc}f$, a multiple of $\operatorname{disc}f$. $\square$

**Contrast with unrelated discriminants.** If $D_1,D_2$ are "independent" (e.g. $D_1D_2$ is not a square), then by the Chebotarev (or simply quadratic reciprocity plus Dirichlet) density theorem the four sign patterns of $\left(\frac{D_1}{p}\right),\left(\frac{D_2}{p}\right)$ are asymptotically equidistributed, so the primes at which *both* are squares have density $1/4$. The "$\approx1/4$" phenomenon is real — but it belongs to a different construction, not to Silverman's.

**Empirical confirmation.** On the test corpus (41–42-bit $N$), the multi-polynomial column set occupied $0.487$–$0.505$ of $\pi(B)$ — identical to single-polynomial QS — whereas pairs of unrelated discriminants gave $0.244$–$0.317$.

---

## 5. Large primes and adaptive $B$

### 5.1 Large primes: a monotonicity identity

**Lemma 5.1 (Monotonicity).** If $B\le L$ then $\mathcal S_B(N)\subseteq\mathcal S_L(N)$.

*Proof.* Immediate from the definition. $\square$

**Theorem 5.2 (The large prime is split).** If $x^2-N=s\cdot r$ with $r$ prime (of any size), then $r\in\mathcal S_L(N)$ for every $L\ge r$.

*Proof.* $r\mid x^2-N$; apply Lemma 3.2. $\square$

**Theorem 5.3 (LP-pair support).** Let $x_1^2-N=s_1r$ and $x_2^2-N=s_2r$ with $r$ prime and $s_1,s_2$ nonzero and $B$-smooth. Then every prime $p$ occurring to an odd power in $(s_1r)(s_2r)$ lies in the *small* split set $\mathcal S_B(N)$.

*Proof.* $v_p\big((s_1r)(s_2r)\big)=v_p(s_1)+v_p(s_2)+2v_p(r)$. If this is odd, then $v_p(s_1)$ or $v_p(s_2)$ is nonzero; say $p\mid s_1$. Then $p\le B$ by smoothness and $p\mid x_1^2-N$, so $p\in\mathcal S_B(N)$ by Lemma 3.2. $\square$

So large primes enlarge the *row* supply without enlarging the effective column space: an LP-pair is a full relation over $\mathcal S_B(N)$, and the set of large primes that can occur at all is $\mathcal S_L(N)\setminus\mathcal S_B(N)$. This is the definitional reason every production QS ships the LP variation — it is a monotonicity identity, not a discovery. (The classical probabilistic analyses of the large-prime variations indeed define their prime sets as the primes $q$ with $\left(\frac{N}{q}\right)=1$.) Empirically, the number of LP columns equalled the split-set prediction on 68/68 instances.

### 5.2 Adaptive $B$: a reparametrisation

Let $m=\pi(B)$ and $Q=|\mathcal S_B(N)|$. By Theorem 3.4 and the equidistribution of quadratic characters, $Q\sim m/2$. Changing $B$ therefore moves the pair $(m,Q)$ *along* the ray $Q\approx m/2$. The measured log-log slope across the corpus was
$$\frac{d\log Q}{d\log m}=0.99718\pm0.03722,$$
consistent with $1$. The bound $B$ is a reparametrisation of a one-parameter family, not a second degree of freedom.

---

## 6. The row-side lever: number of polynomials $\perp$ number of columns

**Theorem 6.1 ($\mathbb{F}_2$ dependency).** Let $\mathcal S$ be a finite set of primes and $V_1,\dots,V_n$ nonzero natural numbers all of whose prime factors lie in $\mathcal S$. If $n>|\mathcal S|$, there is a nonempty $T\subseteq\{1,\dots,n\}$ with $\prod_{i\in T}V_i$ a perfect square.

*Proof.* The parity vectors $\big(v_p(V_i)\bmod 2\big)_{p\in\mathcal S}$ are $n$ vectors in $\mathbb{F}_2^{|\mathcal S|}$, so they are linearly dependent; a dependency is a nonempty subset whose parity vectors sum to $0$, i.e. a square product. $\square$

**Theorem 6.2 (Multi-polynomial congruence of squares).** Let $(f_t)_{t\in\mathcal T}$ be *any* family (of any size) with common discriminant $D$. Suppose we have $n$ pairs $(t_i,x_i)$ such that $V_i=|f_{t_i}(x_i)|$ is nonzero and $B$-smooth. If
$$n > |\mathcal S_B(D)|,$$
then some nonempty sub-product $\prod_{i\in T}V_i$ is a perfect square. The threshold depends on $D$ and $B$ only, not on $|\mathcal T|$.

*Proof.* Each prime factor $p$ of $V_i$ is $\le B$ and divides $f_{t_i}(x_i)$, hence lies in $\mathcal S_B(D)$ by Theorem 4.1. Apply Theorem 6.1 with $\mathcal S=\mathcal S_B(D)$. $\square$

(In a complete implementation one adds a column for the sign $-1$, which does not affect the argument.) Theorem 6.2 is precisely the statement that the $T$-th polynomial buys **rows** at **zero marginal rank cost**. It is real, and it is what MPQS does — but it is a row-side effect, not a decoupling of the column space.

### 6.1 The gate

On $[-M,M]$ a centred Silverman form $A^{-1}\big((Ax+b)^2-N\big)$ with $|b|\le A/2$ ranges from about $-N/A$ (at the centre) to about $AM^2-N/A$ (at the ends).

**Theorem 6.3 (Silverman minimax).** For all $N,M,A>0$,
$$\max\!\left(\frac NA,\ AM^2-\frac NA\right)\ \ge\ M\sqrt{N/2},$$
with equality at $A^\ast = 2\sqrt{N/2}/M=\sqrt{2N}/M$, where both extremes equal $M\sqrt{N/2}\approx0.707\,M\sqrt N$.

*Proof.* Let $m=M\sqrt{N/2}$, so $m^2=M^2N/2$, and $y=N/A$. If $y\ge m$ we are done. Otherwise $0<y<m$ and $AM^2=M^2N/y=2m^2/y$, so we need $2m^2/y-y\ge m$, i.e. $2m^2-my-y^2\ge0$, i.e. $(m-y)(2m+y)\ge 0$, which holds. At $A=A^\ast$: $N/A^\ast = NM/(2\sqrt{N/2}) = M\sqrt{N/2}$, and $A^\ast M^2-N/A^\ast = 2M\sqrt{N/2}-M\sqrt{N/2}$. $\square$

In Silverman's construction $A=q^2$ with $q>B$ (so that $q$ is not a factor-base prime), whence $A>B^2$. For the $T$ forms to sit near $A^\ast$ one needs $B^2\lesssim A^\ast$, i.e. $B^2M\lesssim\sqrt{2N}$; we state the gate in the normalisation of the minimax value,
$$B^2\,M\ \lesssim\ \sqrt{N/2}\approx 0.707\sqrt N,$$
noting that the constant is immaterial in view of the next result. This condition does not appear in Silverman's original analysis.

**Theorem 6.4 (The gate fails at 42 bits).** If $N<2^{42}$ and $B,M\ge1000$, then
$$B^2M > 600\,\sqrt{N/2}.$$

*Proof.* $\sqrt{N/2}<\sqrt{2^{41}}<1.49\times10^6<10^9/600$, while $B^2M\ge10^9$. $\square$

Equivalently $B^2M>300\sqrt{2N}$, so either normalisation of the gate fails by more than two and a half orders of magnitude. This explains the observed saturation of the multi-polynomial gain at $T\approx4$: as $T$ grows, admissible leading coefficients run out near $A^\ast$, the ratio $A_{\text{actual}}/A_{\text{ideal}}$ climbs (measured $13.8\times$ to $1477\times$), values grow, and the smooth yield per form falls.

---

## 7. The complete-cost rule

Let $u=\log Q$, and let $S(u)>0$ be the sieve cost and $L(u)>0$ the cost of the $\mathbb{F}_2$ elimination.

**Theorem 7.1 (Elasticity of a total cost).** If $S,L$ are differentiable at $u$ with derivatives $s',l'$, then
$$\frac{d}{du}\log\big(S+L\big)=\frac{S}{S+L}\cdot\frac{s'}{S}+\frac{L}{S+L}\cdot\frac{l'}{L}=\frac{s'+l'}{S+L}.$$

*Proof.* Chain rule: $\frac{d}{du}\log(S+L)=(s'+l')/(S+L)$; expand. $\square$

**Corollary 7.2 (Betweenness).** The total elasticity lies between $\min(s'/S,\,l'/L)$ and $\max(s'/S,\,l'/L)$.

*Proof.* It is a convex combination with weights $S/(S+L)$ and $L/(S+L)$. $\square$

**Corollary 7.3 (Sign criterion).** The total elasticity is positive iff $l'>-s'$.

*Proof.* $S+L>0$, so the sign of $(s'+l')/(S+L)$ is that of $s'+l'$. $\square$

**Corollary 7.4 (Sieve-only pricing inverts the sign).** If $s'<0$ but $l'>-s'$, then the sieve-only elasticity $s'/S$ is negative while the complete-cost elasticity is positive.

*Proof.* Combine $s'/S<0$ with Corollary 7.3. $\square$

**Empirical instance.** On an 80-instance corpus,
$$\frac{d\log S}{d\log Q}=-0.1490\pm0.1299\ \ (\text{negative on }73/80),\qquad \frac{d\log(S+L)}{d\log Q}=+0.0787\pm0.1472\ \ (\text{positive on }60/80,\ t\approx+4.8).$$
The elimination term grew by factors $146\times$ to $3981\times$ across the range, while the sieve term was flat above $B=2400$. By Corollary 7.4 this is exactly the configuration in which the sign inverts.

**Rule.** *A per-instance lever on QS cost must be priced against the complete cost of reaching a factor — sieve work plus the $\mathbb{F}_2$ elimination that grows with $Q$. Any reported $d\log(\text{cost})/d\log Q$ must state which terms are in the cost.*

---

## 8. The boundary: leaving differences of squares

All results above rest on Lemma 3.1, which expresses (a multiple of) every value as $y^2-D$ with $D$ tied to $N$. Without that structure the constraint disappears.

**Proposition 8.1 (Cubic values break the split constraint).** There exist $N,x$ and a prime $p$ with $p\mid x^3-N$ but $N$ not a square mod $p$. For example $N=2$, $x=3$, $p=5$: $3^3-2=25$, while the squares mod $5$ are $\{0,1,4\}$.

For the 41-bit $N=1{,}099{,}515{,}822{,}059=1048573\cdot1048583$, eleven non-split primes below $200$ already divide values $x^3-N$ for $x$ in a window of length $2000$ above $N^{1/3}$.

This is the only route by which a large-prime, multi-polynomial or bound-tuning channel could ever add non-split columns — and it is no longer the quadratic sieve but the algebraic (number field sieve) direction, where columns correspond to degree-one prime ideals of a higher-degree field.

---

## 9. Corrections to earlier claims

**9.1 Multi-polynomial column fraction.** An earlier claim held that the multi-polynomial column set has density $\approx1/4$ of $\pi(B)$, reasoning that each form contributes an independent "half" constraint. This is wrong: Silverman forms share the discriminant $kN$, so by Theorem 4.3 the conjunction is a single constraint and the density is $\approx1/2$ (measured $0.487$–$0.505$). The figure $1/4$ is what two *unrelated* discriminants give (measured $0.244$–$0.317$). The conclusion that multiple polynomials cannot decouple the column space is unchanged and is now Theorem 4.1.

**9.2 Adaptive $B$ direction.** An earlier claim reported a favourable direction for increasing $Q$, an interior optimum at $B=9600$, and an oracle saving of $0.9533\times$. These were based on sieve-only pricing and are withdrawn: under complete-cost pricing the sign is reversed (Section 7). The reparametrisation result $d\log Q/d\log m\approx1$ stands.

**9.3 Data audit.** Two summary tables were re-derived from the underlying records. For the large-prime experiment, the committed summary had been written before the data it summarised and misreported the comparison (the true counts were 54–64 of 66 instances in favour of the arm the summary had declared the loser). For the adaptive-$B$ experiment, two quoted cost figures did not appear in any record; the true flat-basin geometric means were $3835.5$, $3833.0$, $3795.4$, $3811.9$, $3831.1$. A permutation null with $20000$ resamples confirmed that the reported effect magnitude $0.0478$ is not noise — but, by the reparametrisation result, it is not reachable by an instance-level lever.

---

## 10. Algorithms

**Algorithm A (Column set = split set).** Input $D$, $B$. For each prime $p\le B$: if $p=2$ or $p\mid D$ accept; otherwise accept iff $D^{(p-1)/2}\equiv1\pmod p$ (Euler's criterion). Output the accepted primes. Cost $O(\pi(B)\log p)$ modular multiplications. By Theorem 3.4 this equals the column set of any form of discriminant $D$ at odd $p\nmid A$; sieve roots are $x\equiv(\pm\sqrt D-B)(2A)^{-1}\pmod p$, computed with Tonelli–Shanks.

**Algorithm B (Silverman family with shared discriminant).** Starting near $q_0=\lceil(\sqrt{2N}/M)^{1/2}\rceil$, $q_0>B$: for successive primes $q$ with $\left(\frac Nq\right)=1$, compute $r=\sqrt N\bmod q$, Hensel-lift to $b\equiv r+q\cdot\big((N-r^2)/q\big)(2r)^{-1}\pmod{q^2}$, set $A=q^2$, $c=(b^2-N)/A$, emit $(A,2b,c)$. Every emitted form has discriminant $4N$; by Theorem 4.2 no new columns are introduced.

**Algorithm C (Square from $|\mathcal S_B(D)|+1$ rows).** Map each smooth value to its parity vector over $\mathcal S_B(D)$ and run Gaussian elimination over $\mathbb{F}_2$ tracking row combinations; the first vector reducing to $0$ gives the dependency. Dense cost $O(Q^3)$ bit operations ($O(Q^2)$ per row with word-level parallelism); sparse methods (block Lanczos/Wiedemann) cost about $O(Q\cdot w)$ per iteration with $w$ the row weight. This growth in $Q$ is the term $L$ of Section 7.

**Algorithm D (LP pairing).** Bucket partial relations by their large prime $r$; within each bucket combine the first relation with every other. By Theorem 5.3, each combination is a full relation over $\mathcal S_B(N)$. More generally, cycles in the graph whose vertices are large primes (plus a vertex for $1$) and whose edges are partials give full relations; their number is the cycle rank of that graph.

---

## 11. Numerical illustration

For $N=1{,}099{,}515{,}822{,}059$ (41 bits):

* With $B=400$ ($\pi(B)=78$), the primes dividing some $x^2-N$ and the split set coincide exactly: $41$ primes, fraction $0.526$.
* Four Silverman forms (leading coefficients $175561=419^2$, $185761=431^2$, $187489=433^2$, $201601=449^2$) all have discriminant $4N=4{,}398{,}063{,}288{,}236$ and each has exactly the same $40$ odd columns; intersection = union = odd split set. Twenty random pairs of unrelated discriminants give intersection fractions averaging $0.277$.
* Among $1368$ partial relations with large prime in $(300,15000]$, not one large prime was non-split; all $344$ LP-pairs had odd support inside the small split set.
* With $B=120$ ($|\mathcal S_B|=15$) and $M=20000$: one form yields $4$ smooth rows, two forms $6$, four forms $13$, eight forms $33$; the columns touched never exceed $15$, and the first $16$ rows contain a square product drawing on four different forms.
* At $N\approx2^{42}$, $B=M=1000$: $B^2M/\sqrt{N/2}\approx674$.

---

## 12. Discussion

The three channels look different operationally — one changes which values are kept, one changes which polynomial is sieved, one changes the bound — but structurally they are the same: each produces values of the shape $y^2-D$ with $D\in\{N,kN,4kN\}\cdot(\text{square})$, and Lemma 3.1 converts every prime divisor into a square root of $D$. This collapses what might appear to be three empirical questions into one theorem, and explains why the measured column fractions are so stable.

The positive content is equally structural. Since columns are a function of $D$ alone, all the freedom in MPQS is on the row side: more polynomials mean more smooth values per unit of sieve length. The scarce resource is not columns but *admissible leading coefficients near the minimax optimum*, and the gate quantifies when they run out.

Finally the complete-cost identity is not specific to factoring. Whenever a pipeline has several stages whose costs move in opposite directions with a parameter, stage-level elasticities can have the opposite sign from the total. The convex-combination form makes the criterion transparent: the total goes up iff the absolute increase in the growing stage exceeds the absolute decrease in the shrinking one.

---

## 13. Future directions

1. **Norm-form column theorem for degree-$d$ sieves.** For $f$ monic irreducible of degree $d$ and $p\nmid\operatorname{disc}f$, $p$ divides some $f(x)$ iff $f$ has a root mod $p$; the column density should be the Chebotarev proportion of Galois elements with a fixed point, equal to $1/2$ only for $d=2$. The quadratic theorem is the $d=2$ case of "columns are primes with a degree-one prime above them".
2. **Complete-cost elasticity sign theorem.** With $S(B)\sim\pi(B)u^u$ and $L(B)\sim\pi(B)^\omega$, $\omega\in[2,3]$, prove the total elasticity is positive for all $B$ above the sieve-optimal bound by a factor $(\log N)^c$; by Corollary 7.3 only the asymptotics of $S$ and $L$ remain.
3. **Row-side saturation law.** With $T$ forms of leading coefficient $q_t^2$, $q_t>B$, $q_t^2\approx\sqrt{2N}/M$, show the yield gain saturates once $T$ exceeds the number of primes in $\big(B,(\sqrt{2N}/M)^{1/2}\big]$, i.e. is governed by the gate.
4. **Large-prime graph cycle rank.** Show that the number of full relations obtainable from single-large-prime partials equals the cycle rank $E-V+C$ of the large-prime graph, and that each has odd support in the $B$-split set, generalising Theorem 5.3 from pairs to cycles.

---

## 14. Conclusion

For quadratic-form sieving the decoupling question is closed: large primes, multiple polynomials and adaptive bounds cannot move the column space off the split set, because every form with discriminant tied to $N$ turns each prime divisor of its value into a square root of that discriminant. One row-side lever survives — extra polynomials add rows at zero column cost — gated by $B^2M\lesssim\sqrt{N/2}$, which fails by more than $600\times$ at 42 bits. And the cost of any such lever must be computed on the complete pipeline: the elasticity of a sum is the share-weighted average of the parts, and pricing one part alone can reverse the sign.
