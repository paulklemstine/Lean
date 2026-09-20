# Method Locality: Factoring Algorithms Whose Cost Tracks the Factor, Not the Modulus

**Author:** Aristotle
**Date:** 2026-09-20

---

## Abstract

We give an exact structural account of a phenomenon long observed in computational
number theory: the running cost of Pollard's rho method and of the elliptic curve
method against a composite $N = pq$ is determined by the prime $p$ being hunted and is
independent of the cofactor $q$, while the cost of trial division is not. We separate
two distinct properties conflated by the informal phrase "factor-local" — *cofactor
flatness* (the cost on $pq$ does not depend on $q$) and *factor boundedness* (the cost
is bounded by a function of $p$ alone) — and prove:

1. **A shadow theorem.** For any state update defined uniformly over all commutative
   rings (in particular every integer-polynomial iteration, and the exponentiation step
   of the $p-1$ method), the reduction modulo $p$ of a run performed modulo $N$ is,
   term for term, the run performed modulo $p$. Consequently every such method is
   exactly cofactor flat — ratio $1$, not approximately $1$ — and factor bounded by $p$.

2. **A rigidity theorem.** Any cost model that is *modulus-determined* (its ledger does
   not read the hunted factor) and cofactor flat is constant on all composites. Hence
   trial division's failure of flatness is forced, not accidental: no non-constant
   modulus-reading method can be factor-local.

3. **An exact ECM ledger.** In the standard cyclic model of a two-prime stage-1 run,
   the mod-$p$ success rate is $\gcd(m, k(B))/m$, where $m$ is the mod-$p$ group order
   and $k(B) = \operatorname{lcm}(1,\dots,B)$; the cofactor group order cancels
   identically. The expected curve count $m/\gcd(m,k(B))$ is bounded by the Hasse
   ceiling $p + 3 + 2\lfloor\sqrt p\rfloor$, is antitone in $B$, and equals $1$ beyond
   the top of the Hasse window.

4. **Exact two-prime outcome counts and ledger faithfulness.** The four separated
   outcomes of a two-prime run partition the $m_p m_q$ trials into blocks of sizes
   $\gcd(m_p,k)\gcd(m_q,k)$, $\gcd(m_p,k)(m_q-\gcd(m_q,k))$,
   $(m_p-\gcd(m_p,k))\gcd(m_q,k)$ and $(m_p-\gcd(m_p,k))(m_q-\gcd(m_q,k))$. The reveal
   count vanishes exactly when the bound covers *both* group orders — a genuine
   degeneracy wall at $\max(p,q)$ — and is monotone in $B$ while the $q$-side stays
   inert, so no wall can occur at $\min(p,q)$. A reported wall at $\min(p,q)$ is
   reproduced exactly by a single non-injective conflation in the accounting ledger.

Exact anchors accompany the theory: for $f(x)=x^2+1$, $x_0=2$, the rho orbit closes at
step $49$ modulo $1009$ and at step $70$ modulo $4093$, against $1008$ and $4092$ trial
divisions respectively, both within the birthday window $2\sqrt p$.

**Keywords:** integer factorization, Pollard rho, elliptic curve method, trial
division, naturality, cofactor flatness, Chinese remainder theorem, birthday bound,
cost model rigidity.

---

## 1. Introduction

### 1.1 The observation

Run Pollard's rho method against $N = p\,q$ with $p = 4093$ held fixed and the cofactor
$q$ grown from $2^{14}$ to $2^{23}$. The measured number of iterations does not grow.
Do the same for the elliptic curve method: again the cost does not grow. Do it for
trial division, and the cost changes by orders of magnitude as soon as the cofactor
becomes the least prime factor.

In a controlled study (fixed $p = 4093$, nine independent draws per cell, medians
reported to suppress seed luck), the observed median spread across $2^{23}$ of cofactor
growth was $\times 2.16$ for the elliptic curve method and $\times 1.40$ for rho — flat
within the intrinsic scatter of the methods themselves (curve-restart scatter for ECM;
Poisson-like fluctuation around $\sqrt p \approx 64$ for rho). Scaling in $p$ instead of
in $q$ separates the methods cleanly, with slopes per $\log_2 p$:

| method | measured slope per $\log_2 p$ | predicted | interpretation |
|---|---|---|---|
| Pollard rho | $0.45$ | $0.5$ | birthday bound $\sqrt p$ |
| trial division | $1.09$ | $1$ | linear in $p$: the definition face |
| elliptic curve method | $1.13$ | sub-exponential | locally power-like, constant-advantaged |

The elliptic curve slope in this window is misleading in isolation: the method is
*constant-advantaged*, needing $6\,657$ operations at $p = 2^{14}$ against trial
division's $12\,142$, and its sub-exponential bending lies beyond the measured window.

The verdict — **the methods are factor-local** — is empirically clear. This paper asks
what it means exactly, and proves it.

### 1.2 Two properties, not one

The informal phrase "factor-local" conflates:

- **cofactor flatness**: $\mathrm{cost}(p\cdot q) = \mathrm{cost}(p \cdot q')$ for all
  cofactors $q, q'$;
- **factor boundedness**: $\mathrm{cost}(N) \le g(p)$ for some function $g$ of the
  hunted prime alone.

These are genuinely different. Trial division is factor bounded (by $p-1$) yet
emphatically not cofactor flat. Rho is both. The separation is what makes the subject
have theorems rather than folklore.

### 1.3 Contributions

Sections 3–5 establish locality and its mechanism (naturality); Section 6 establishes
the converse rigidity theorem; Section 7 treats the elliptic curve ledger; Section 8
gives the exact two-prime outcome counts, locates the real degeneracy wall at
$\max(p,q)$, and shows how a non-injective ledger manufactures a spurious wall;
Section 9 gives algorithms; Sections 10–11 discuss consequences and open directions.

---

## 2. The cost model

Throughout, $N$ is a composite, $p$ a prime divisor of $N$, and $q = N/p$ the cofactor.
For a semiprime we write $N = pq$ with both factors prime.

**Definition 2.1 (Collision).** A sequence $s : \mathbb{N} \to \beta$ *collides at time*
$n$ if there exists $i < n$ with $s_i = s_n$.

**Definition 2.2 (Cost).** The *collision time* $T(s)$ is the least $n$ at which $s$
collides. If $\beta$ is finite, such an $n$ exists, so $T(s)$ is well defined.

**Lemma 2.3 (Pigeonhole ceiling).** If $|\beta| = c$ then $T(s) \le c$ for every
sequence $s$ into $\beta$.

*Proof.* The $c+1$ values $s_0,\dots,s_c$ cannot be pairwise distinct. $\square$

**Lemma 2.4 (Cost is a function of the trajectory).** If $s_n = t_n$ for all $n$ then
$T(s) = T(t)$. If $s$ collides at $n$ and does not collide at any $m < n$, then
$T(s) = n$. $\square$

**Definition 2.5 (Cost model).** A *cost model* is a function
$\mathrm{cost} : \mathbb{N} \times \mathbb{N} \to \mathbb{N}$, where
$\mathrm{cost}(N,p)$ is the cost of the run performed modulo $N$ while hunting the
prime $p$. It is

- *factor bounded* if there is $g$ with $\mathrm{cost}(N,p) \le g(p)$ for all $N,p$;
- *cofactor flat* if $\mathrm{cost}(pq, p) = \mathrm{cost}(pq', p)$ for all positive
  $q, q'$;
- *modulus-determined* if $\mathrm{cost}(N,p) = \mathrm{cost}(N,p')$ for all $p,p'$.

The third notion is the ledger-theoretic one: it says the accounting never reads which
factor is being hunted.

---

## 3. The shadow theorem for polynomial methods

**Definition 3.1 (Polynomial iteration).** For $f \in \mathbb{Z}[X]$ and a commutative
ring $R$, the *polynomial step* is $x \mapsto f(x)$ evaluated in $R$, and the *orbit*
from $x_0 \in R$ is $\mathcal{O}_f(x_0)_n = f^{(n)}(x_0)$. Pollard's rho method is the
case $f = X^2 + c$; the cubic restart variant is $f = X^3 + c$; the successor map is
$f = X + 1$.

**Lemma 3.2 (Equivariance).** For any ring homomorphism $\varphi : R \to S$ and any
$f \in \mathbb{Z}[X]$, $\varphi(f(x)) = f(\varphi(x))$, hence
$\varphi(\mathcal{O}_f(x_0)_n) = \mathcal{O}_f(\varphi(x_0))_n$ for all $n$.

*Proof.* A ring homomorphism preserves sums, products and the images of integers;
induct on $n$. $\square$

**Theorem 3.3 (Shadow theorem).** Let $p \mid N$, $f \in \mathbb{Z}[X]$,
$x_0 \in \mathbb{Z}$. Then for every $n$, the reduction modulo $p$ of the $n$-th state
of the run performed in $\mathbb{Z}/N$ equals the $n$-th state of the run performed in
$\mathbb{Z}/p$:
$$\pi_p\big(\mathcal{O}_f(x_0 \bmod N)_n\big) = \mathcal{O}_f(x_0 \bmod p)_n,$$
where $\pi_p : \mathbb{Z}/N \to \mathbb{Z}/p$ is reduction.

*Proof.* Apply Lemma 3.2 to $\varphi = \pi_p$, which is a ring homomorphism because
$p \mid N$. $\square$

**Definition 3.4 (Locality cost).** The cost of a polynomial method run modulo $N$ while
hunting $p$ is $T_f(p, N, x_0) := T(\pi_p \circ \mathcal{O}_f(x_0 \bmod N))$, the
collision time of the mod-$p$ shadow. Write $T_f(p, x_0)$ for the intrinsic cost
$T(\mathcal{O}_f(x_0 \bmod p))$ computed in $\mathbb{Z}/p$ alone.

**Corollary 3.5.** $T_f(p,N,x_0) = T_f(p,x_0)$ for every multiple $N$ of $p$.

*Proof.* The two sequences are pointwise equal by Theorem 3.3; apply Lemma 2.4.
$\square$

**Theorem 3.6 (Exact cofactor flatness).** For all cofactors $q, q'$,
$$T_f(p, pq, x_0) = T_f(p, pq', x_0).$$
The ratio is exactly $1$; the measured $\times 1.40$ spread for rho is seed luck.

*Proof.* Both sides equal $T_f(p,x_0)$ by Corollary 3.5. $\square$

**Theorem 3.7 (Factor boundedness).** $T_f(p,N,x_0) \le p$.

*Proof.* The shadow takes values in $\mathbb{Z}/p$; apply Lemma 2.3. $\square$

---

## 4. Naturality is the mechanism

Polynomiality is sufficient but not necessary. The correct hypothesis is naturality.

**Definition 4.1 (Uniform step).** A *uniform step* $M$ assigns to every commutative
ring $R$ a map $M_R : R \to R$ such that $\varphi \circ M_R = M_S \circ \varphi$ for
every ring homomorphism $\varphi : R \to S$. Its orbit from $x_0$ is
$M_R^{(n)}(x_0)$.

Every polynomial step is uniform; so is $x \mapsto x^k$, the exponentiation step
underlying the $p-1$ method; so are all rho variants used at restart.

**Theorem 4.2 (Locality from naturality).** For every uniform step $M$, every $p \mid N$
and every seed $x_0$:

1. the mod-$p$ shadow of the mod-$N$ orbit is the mod-$p$ orbit;
2. the cost is cofactor flat: $T_M(p, pq, x_0) = T_M(p, pq', x_0)$;
3. the cost is factor bounded: $T_M(p, N, x_0) \le p$.

*Proof.* (1) is the naturality square for $\pi_p$, iterated. (2) follows since both
sides equal the intrinsic mod-$p$ cost. (3) is pigeonhole in $\mathbb{Z}/p$. $\square$

**Corollary 4.3 ($p-1$ method).** The exponentiation method is cofactor flat.
Furthermore, writing $k(B) = \operatorname{lcm}(1,\dots,B)$ for the stage-1 scalar, the
$p-1$ method fires whenever $B \ge p-1$, because the multiplicative group modulo $p$ has
order $p-1$ and $(p-1) \mid k(B)$ once $B \ge p-1$. The least such budget is therefore at
most $p-1$, and it is attained.

**Proposition 4.4 (Shadow cost is a lower bound).** For any uniform method, the
collision time of the shadow is at most the collision time of the run modulo $N$: a
collision downstairs is implied by a collision upstairs, never the reverse.

*Proof.* Post-composition with a map can only create coincidences, never destroy them.
$\square$

**Remark 4.5 (Locality $\neq$ speed).** Locality bounds the cost by $p$, and says
nothing stronger in general. The successor step $x \mapsto x+1$ in $\mathbb{Z}/p$ is
uniform, yet its orbit visits all $p$ residues before repeating, so its collision time
is exactly $p$. The pigeonhole bound of Theorem 3.7 is therefore sharp, and any
square-root gain must come from the statistics of the particular map, not from
locality.

---

## 5. How fast: the birthday window, and exact anchors

**Theorem 5.1 (Birthday bound).** For $0 < k \le p$,
$$\prod_{i=0}^{k-1}\left(1 - \frac{i}{p}\right) \;\le\; \exp\!\left(-\frac{k(k-1)}{2p}\right).$$

*Proof sketch.* Each factor satisfies $1 - i/p \le e^{-i/p}$ by $1 + t \le e^{t}$ with
$t = -i/p$; all factors are nonnegative for $k \le p$, so the product is bounded by
$\exp(-\sum_{i<k} i/p)$ and $\sum_{i<k} i = k(k-1)/2$. $\square$

**Corollary 5.2 (Window at the anchor prime).** At $p = 4093$ and $k = 76$ the bound
gives $\prod_{i<76}(1 - i/4093) \le 1/2$: in the uniform model, $76$ steps already make
a collision more likely than not. Since $1.18\sqrt{4093} \approx 75.5$, the classical
constant is reproduced.

The uniform model is a model. The following are exact statements about the actual
orbits of $f(x) = x^2+1$ from $x_0 = 2$.

**Proposition 5.3 (Anchor at $p = 4093$).** The states $x_0,\dots,x_{69}$ modulo $4093$
are pairwise distinct and $x_{70} = x_{53}$. Hence the collision time is exactly $70$,
and $70 \le 2\lfloor\sqrt{4093}\rfloor = 128$: the run sits inside the birthday window.

**Proposition 5.4 (Anchor at $p = 1009$).** Modulo $1009$ the orbit is purely periodic
from the seed: $x_{49} = x_0$ and the first $49$ states are distinct, so the collision
time is exactly $49$, against $\sqrt{1009} \approx 31.8$.

**Proposition 5.5 (Degenerate anchor).** Modulo $3$ the orbit of $x^2+1$ from $2$ is
stationary ($2^2+1 = 5 \equiv 2$), so the collision time is $1$.

Propositions 5.3–5.5 are exact orbit computations, not statistical estimates.

---

## 6. Trial division, and a rigidity theorem

**Definition 6.1.** Ascending trial division inspects $2, 3, \dots$ until a divisor is
found; its cost is $\mathrm{td}(N) = \mathrm{minFac}(N) - 1$, the number of candidates
strictly below the least prime factor.

**Lemma 6.2 (The tests genuinely fail).** If $2 \le d < \mathrm{minFac}(N)$ then
$d \nmid N$. Hence $\mathrm{td}(N)$ is the true count of failed tests, and equals
$|\,[2,\mathrm{minFac}(N)]\,| $ minus one endpoint bookkeeping term. $\square$

**Theorem 6.3 (The definition face).** If $p \le q$ are primes then
$\mathrm{minFac}(pq) = p$ and $\mathrm{td}(pq) = p - 1$: on the stratum where the hunted
prime is the least factor, the cost is exactly linear in $p$. Consequently for two such
strata,
$$\frac{\mathrm{td}(pq)}{\mathrm{td}(p'q')} = \frac{p-1}{p'-1}$$
identically — an exact law, matching the measured slope $1.09$ per $\log_2 p$.

**Theorem 6.4 (Factor boundedness).** For *every* prime $p \mid N$,
$\mathrm{td}(N) \le p - 1$, since $\mathrm{minFac}(N) \le p$.

**Theorem 6.5 (Trial division is not cofactor flat).** Hold $p = 4093$. Then
$\mathrm{td}(4093 \cdot 3) = 2$ while $\mathrm{td}(4093 \cdot 4093) = 4092$.

*Proof.* $\mathrm{minFac}(12279) = 3$ and $\mathrm{minFac}(4093^2) = 4093$. $\square$

So trial division is factor bounded but not cofactor flat, while rho is both:
locality is a strictly finer classification than boundedness.

Is Theorem 6.5 an accident of the particular ledger? No.

**Theorem 6.6 (Rigidity).** Let $\mathrm{cost}$ be modulus-determined and cofactor
flat. Then for all positive $a,b,c,d$,
$$\mathrm{cost}(ab, \cdot) = \mathrm{cost}(cd, \cdot):$$
the model is constant on composites.

*Proof.* Modulus-determinedness lets us re-label the second argument freely. By
flatness with hunted factor $a$ and cofactors $b$ and $cd$,
$\mathrm{cost}(ab) = \mathrm{cost}(a(cd))$. Commuting the product,
$a(cd) = (cd)a$; by flatness with hunted factor $cd$ and cofactors $a$ and $1$,
$\mathrm{cost}((cd)a) = \mathrm{cost}((cd)\cdot 1) = \mathrm{cost}(cd)$. Chaining gives
the claim. $\square$

**Corollary 6.7 (Non-flatness is forced).** Trial division is modulus-determined (its
ledger $\mathrm{minFac}(N)-1$ never reads the hunted prime) and is not constant on
composites; hence it *cannot* be cofactor flat. Theorem 6.5 is an instance of a
structural obstruction, not a coincidence.

**Proposition 6.8 (Rho's licence).** The rho cost model is *not* modulus-determined: it
reads the factor, costing $1$ at $p = 3$ and $70$ at $p = 4093$. This is exactly the
freedom Theorem 6.6 shows a non-trivial flat model must have.

**Theorem 6.9 (The method plane).** Combining the above: (i) every uniform method is
cofactor flat and bounded by $p$; (ii) every modulus-determined cofactor-flat model is
constant on composites; (iii) trial division is modulus-determined and not flat; (iv)
the rho ledger is not modulus-determined. A method is factor-local precisely when its
ledger reads the factor, and naturality is the standard way to make it do so.

**Proposition 6.10 (Certified separation).** Against the same hunted prime,
$$20 \cdot T(1009) \le \mathrm{td}(1009^2) = 1008,\qquad
58 \cdot T(4093) \le \mathrm{td}(4093^2) = 4092,$$
with $T(1009) = 49$, $T(4093) = 70$. The advantage grows from $\ge 20\times$ to
$\ge 58\times$: two exact points of the $0.45$-versus-$1.09$ slope separation, verified
rather than fitted.

---

## 7. The elliptic curve ledger is cofactor-free

Stage 1 of the elliptic curve method fixes a smoothness bound $B$, forms the scalar
$$k(B) = \operatorname{lcm}(1,2,\dots,B),$$
and multiplies a point on a random curve by $k(B)$, working modulo $N$ with a guarded
inversion. Modulo a prime factor $p$ the point lives in the group of the curve over
$\mathbb{F}_p$, of order $m$; by Hasse's theorem
$|m - (p+1)| \le 2\sqrt p$, so $m \le p + 1 + 2\sqrt p$, and we write the integer
ceiling $H(p) = p + 3 + 2\lfloor\sqrt p\rfloor \ge m$.

**Definition 7.1 (Firing set).** In the cyclic model, the multiplier state is a residue
$a$ modulo the group order $m$, and the scalar *fires* when $m \mid k a$. The firing set
is $\{a < m : m \mid ka\}$.

**Lemma 7.2 (Firing count).** For $m > 0$, the firing set has exactly $\gcd(m,k)$
elements.

*Proof sketch.* $m \mid ka$ iff $(m/\gcd(m,k)) \mid a$, and the multiples of
$m/\gcd(m,k)$ below $m$ number $\gcd(m,k)$. $\square$

**Lemma 7.3 (Monotonicity of firing).** $B \le B'$ implies
$\gcd(m, k(B)) \mid \gcd(m, k(B'))$, hence $\gcd(m,k(B)) \le \gcd(m,k(B'))$, since
$k(B) \mid k(B')$.

**Lemma 7.4 (Coverage).** If $m \le B$ then $m \mid k(B)$ and so $\gcd(m,k(B)) = m$:
the scalar annihilates the whole group.

**Theorem 7.5 (Cofactor-free rate).** Write $N = pq$, with mod-$p$ group order $m$ and
mod-$q$ group order $m'$. By the Chinese remainder theorem a random point is a uniform
pair $(a,b) \in \mathbb{Z}/m \times \mathbb{Z}/m'$. The number of joint states whose
mod-$p$ coordinate fires is exactly $\gcd(m,k)\, m'$, hence the mod-$p$ success rate is
$$\frac{\gcd(m,k)\,m'}{m\,m'} = \frac{\gcd(m,k)}{m},$$
a function of the factor and the bound only. The cofactor order $m'$ cancels
identically.

*Proof.* The joint firing set is the product of the mod-$p$ firing set with all of
$\mathbb{Z}/m'$; count and divide. $\square$

**Definition 7.6 (Expected curve count).** $C(m,B) = m / \gcd(m, k(B))$, the reciprocal
of the stage-1 firing rate.

**Theorem 7.7 (Factor boundedness of ECM).** If $m \le H(p)$ — in particular whenever
$m$ lies in the Hasse window $m \le p+1+2\sqrt p$ — then
$C(m,B) \le H(p) = p + 3 + 2\lfloor\sqrt p\rfloor$ for every $B$ and every cofactor.

*Proof.* $C(m,B) \le m \le H(p)$. $\square$

**Theorem 7.8 (Antitone in $B$).** $B \le B'$ implies $C(m,B') \le C(m,B)$: raising the
smoothness bound never increases the expected curve count. Hence the ECM cost curve in
$B$ has no wall.

*Proof.* Lemma 7.3 and monotonicity of division. $\square$

**Theorem 7.9 (One curve past the window).** If $0 < m \le H(p) \le B$ then
$C(m,B) = 1$.

*Proof.* $m \le B$, so $\gcd(m,k(B)) = m$ by Lemma 7.4 and $C = m/m = 1$. $\square$

Theorem 7.9 refutes the reading under which the top of the Hasse window is a
catastrophic wall with infinite expected time: past that point one curve suffices, and
the cost remains a function of $p$ alone.

---

## 8. Exact two-prime outcome counts, and how a ledger manufactures a wall

Sections 7 counted the $p$-channel. To adjudicate wall claims one must count all four
channels separately, because they redistribute.

Fix mod-$p$ and mod-$q$ group orders $m_p, m_q > 0$ and a scalar $k$. A trial is a pair
$(a,b) \in \mathbb{Z}/m_p \times \mathbb{Z}/m_q$; write $F_p = \gcd(m_p, k)$ and
$F_q = \gcd(m_q,k)$ for the two firing counts, and call the complement of a firing set
the *co-firing set*, of size $m - \gcd(m,k)$.

**Definition 8.1 (Separated outcomes).**

- $\mathrm{dead}$: both coordinates fire — the guarded inversion returns $N$;
- $\mathrm{found}_p$: the $p$-coordinate fires, the $q$-coordinate does not;
- $\mathrm{found}_q$: symmetrically;
- $\mathrm{nothing}$: neither fires.

**Theorem 8.2 (Exact block counts).** The four blocks are products of the firing and
co-firing counts:
$$|\mathrm{dead}| = F_p F_q, \qquad
|\mathrm{found}_p| = F_p\,(m_q - F_q),$$
$$|\mathrm{found}_q| = (m_p - F_p)\,F_q, \qquad
|\mathrm{nothing}| = (m_p - F_p)(m_q - F_q),$$
and they partition all trials:
$$|\mathrm{dead}| + |\mathrm{found}_p| + |\mathrm{found}_q| + |\mathrm{nothing}| = m_p m_q.$$

*Proof.* Each block is a Cartesian product of a (co-)firing set in each coordinate;
apply Lemma 7.2 and the product rule. The sum telescopes to
$(F_p + (m_p-F_p))(F_q + (m_q - F_q)) = m_p m_q$, using $F_p \le m_p$, $F_q \le m_q$.
$\square$

**Corollary 8.3 (Exact reveal count).** The blocks $\mathrm{found}_p$ and
$\mathrm{found}_q$ are disjoint, and their union — the trials exposing a proper factor
of $N$ — has size
$$R(m_p,m_q,k) = F_p\,(m_q - F_q) + (m_p - F_p)\,F_q.$$

**Theorem 8.4 (The real wall sits at $\max(p,q)$).** If $B \ge m_p$ and $B \ge m_q$ then
$F_p = m_p$, $F_q = m_q$ and $R = 0$: every trial is dead.

*Proof.* Lemma 7.4 on both coordinates; substitute into Corollary 8.3. $\square$

So a genuine degeneracy wall exists — but it is governed by the *larger* of the two
primes, since it requires the bound to cover both group orders.

**Theorem 8.5 (No wall at $\min(p,q)$).** Suppose $m_q \ge 2$ and every prime factor of
$m_q$ exceeds $B'$, with $0 < B \le B'$ (the mod-$q$ side is *inert*: only the identity
fires there, $F_q = 1$ at both bounds). Then
$$R(m_p,m_q,k(B)) \;\le\; R(m_p,m_q,k(B')).$$
The reveal count is monotone in the bound: raising $B$ never costs successes.

*Proof sketch.* Inertness gives $F_q = 1$ at both bounds, so
$R = F_p(m_q-1) + (m_p - F_p)$. Writing $x = \gcd(m_p,k(B)) \le y = \gcd(m_p,k(B'))
\le m_p$ (Lemma 7.3), the claim reduces to
$x(m_q-1) + (m_p - x) \le y(m_q-1) + (m_p-y)$, which holds because
$y - x \le (y-x)(m_q-1)$ when $m_q \ge 2$. $\square$

**Proposition 8.6 (Minimal witness of the real wall).** With $m_p = m_q = 2$: at $B=1$
(so $k=1$) the reveal count is $2$; at $B=2$ (so $k=2$) it is $0$. The drop happens
exactly when the bound covers both orders.

**Proposition 8.7 (Channels redistribute).** The $\mathrm{found}_p$ channel alone is not
monotone: with $m_p = 4$, $m_q = 6$, raising $B$ from $2$ ($k=2$) to $3$ ($k=6$) takes
$|\mathrm{found}_p|$ from $8$ to $0$. Nothing failed — those eight trials moved into the
$\mathrm{dead}$ block when the mod-$q$ side began firing. Monotonicity is a property of
the firing counts and of the reveal count under inertness, not of individual channels;
this is precisely why channel separation is required to read the ledger correctly.

### 8.1 Ledger faithfulness

**Definition 8.8 (Ledger).** A *ledger* is a map $L : \{\text{$p$ fires}\} \times
\{\text{$q$ fires}\} \to \{\mathrm{dead}, \mathrm{found}_p, \mathrm{found}_q,
\mathrm{nothing}\}$ from the firing pattern of a trial to a recorded outcome. $L$ is
*faithful* if it is injective: distinct firing patterns receive distinct records.

**Definition 8.9.** The *canonical* (separated) ledger records
$\mathrm{dead}$ on $(\text{fire},\text{fire})$, $\mathrm{found}_p$ on
$(\text{fire},\text{inert})$, $\mathrm{found}_q$ on $(\text{inert},\text{fire})$ and
$\mathrm{nothing}$ on $(\text{inert},\text{inert})$. The *wall* ledger records
$\mathrm{dead}$ whenever the $p$-side fires, regardless of the $q$-side.

**Theorem 8.10 (Faithfulness dichotomy).**
(i) The canonical ledger is faithful.
(ii) The wall ledger is not: it collapses $(\text{fire},\text{fire})$ and
$(\text{fire},\text{inert})$.
(iii) On the pattern $(\text{fire},\text{inert})$ — which is exactly the pattern
produced in the regime where a wall was reported, with $B$ past the Hasse window on the
$p$-side and the $q$-side still inert — the canonical ledger records $\mathrm{found}_p$
while the wall ledger records $\mathrm{dead}$.

*Proof.* Finite case check on the four patterns. $\square$

Thus the reported "all curves degenerate simultaneously" sentence is, verbatim, the
image of a single non-injective conflation: filing a $p$-side firing as a death. The
underlying dynamics are exactly those of Theorems 8.2–8.5, under which the reveal count
increases with $B$ until the bound covers the *second* group order.

---

## 9. Algorithms

### 9.1 Shadow-instrumented rho

The theory suggests an instrumentation: run the method modulo $N$ and simultaneously
watch the mod-$p$ shadow (in an experiment where $p$ is known), because the
*shadow's* collision time — not the modulus run's — is the cost that obeys the
locality theorems.

```
Input:  N, p | N, polynomial f, seed x0
Output: collision time of the mod-p shadow, and a factor when available
1. x <- x0 mod N; S <- empty map from Z/p to index; n <- 0
2. loop:
     s <- x mod p
     if s in S:  return (n, gcd(x - X[S[s]] mod N, N))   # the reveal
     S[s] <- n;  X[n] <- x
     x <- f(x) mod N;  n <- n + 1
```

By Theorem 3.3 the recorded sequence of $s$ values is independent of the cofactor; by
Section 4 the returned gcd is a nontrivial proper divisor of $N$ divisible by $p$
whenever the shadow closes strictly before the mod-$N$ run does.

**Complexity.** $O(T)$ steps with $T \le p$, and heuristically $T = \Theta(\sqrt p)$ for
the quadratic map; memory $O(T)$ in this transparent form, reducible to $O(1)$ by the
usual cycle-detection tricks, which do not affect the locality statements.

### 9.2 Exact ECM ledger evaluation

Given group orders $m_p, m_q$ and a bound $B$, compute $k(B)$, the two firing counts
$F_p, F_q$ by gcd, and then the four block sizes and the reveal count in closed form.
Cost: $O(B \log B)$ for the scalar (or $O(\pi(B)\log B)$ prime-power passes) plus $O(1)$
gcds. This turns wall adjudication into arithmetic: a wall claim is exactly the
assertion $R = 0$, and Theorem 8.4 says that happens iff both orders are covered.

### 9.3 Locality diagnostic

To test a method empirically for cofactor flatness: fix $p$, sweep $q$ over several
octaves, take medians over a fixed number of independent draws per cell (single draws
are statistically inadequate — rho's per-cell cost legitimately spans an order of
magnitude), and report the ratio of the largest to smallest median. Flatness predicts a
ratio near $1$ with residual scatter explained by the method's own randomness; a
modulus-reading method produces a ratio that grows with the sweep.

---

## 10. Discussion

### 10.1 Why the folklore rule is a theorem

Practitioners choose a factoring method by the expected size of the factor, not by the
size of $N$. Theorem 4.2 explains why: the methods in the first tier are natural in the
ring, and naturality *is* cofactor flatness. Nothing in the design of Pollard's rho
method or of the elliptic curve method was aimed at cofactor independence; it is a free
corollary of their algebraic uniformity.

### 10.2 The cryptographic contrapositive

The security of an RSA-style modulus depends on the size of its smallest factor, not on
the size of the modulus. A $2048$-bit modulus with a $60$-bit prime factor is, to a
factor-local method, a $60$-bit problem: the remaining bits are invisible by Theorem
3.6. Balanced prime generation is precisely a defence against locality.

### 10.3 Ledgers as mathematical objects

The two negative results of this paper are both about accounting rather than about
dynamics. Theorem 6.6 says a cost ledger that refuses to read the factor buys
triviality; Theorem 8.10 says a ledger that conflates two firing patterns manufactures a
phenomenon that the underlying counts contradict. Treating the ledger as a first-class
object — a map from what a run can observe to what it records, with faithfulness
meaning injectivity — turns both questions into short finite arguments.

### 10.4 Limits of the results

Cofactor flatness is stated for the *shadow* cost. The cost of the run modulo $N$ as
measured in machine operations grows with $\log N$, because arithmetic modulo $N$ costs
more for larger $N$; locality is a statement about the *number of state updates*, which
is the quantity the empirical study measured and the quantity that determines the
choice of method. Additionally, factor boundedness by $p$ is sharp in the worst case
(Remark 4.5) and only the birthday heuristic, not a theorem, gives $\sqrt p$ for the
quadratic map.

---

## 11. Future directions

**Naturality obstruction for sub-exponential methods.** Every method proved factor-local
here has cost bounded by $p$, the size of the state space it is natural over. This
suggests a dichotomy: a method natural over $\mathbb{Z}/p$-algebras cannot beat $p$ in
the worst case, so sub-exponential behaviour must come from either enlarging the state
space (elliptic curves: a family of groups of order near $p$, from which one may choose
a smooth one) or from abandoning naturality (the sieve methods, whose cost is genuinely
a function of $N$). Formulating and proving an obstruction theorem along these lines
would explain the observed slope $1.13$ for ECM within the measured window as a
finite-window artefact of exactly this trade.

**Quantifying seed luck.** The intrinsic cost $T_f(p,x_0)$ is a deterministic function
of the pair $(p,x_0)$. What is its distribution over seeds, and does the $\times1.40$
median spread match the predicted fluctuation of the birthday statistic? An exact
distributional statement would convert the experimental flatness claim into a sharp
confidence statement.

**Extending the rigidity theorem.** Theorem 6.6 assumes exact flatness. A robust
version — a model that is flat to within a factor $\lambda$ and modulus-determined has
cost varying by at most $\lambda^{O(1)}$ across composites — would let the theorem be
applied directly to measured data rather than to idealized ledgers.

**Faithfulness as a general audit tool.** The ledger-injectivity criterion is not
specific to the elliptic curve method. Any reported phenomenon of the form "the method
dies at parameter $X$" can be tested by asking whether the recording map is injective on
the firing patterns produced near $X$. Building a general calculus of ledgers, with
composition and refinement, would make such audits mechanical.

**Multi-prime ledgers.** Section 8 treats two prime factors. For $r$ factors there are
$2^r$ firing patterns and a correspondingly richer block structure; the reveal count
becomes $m_1\cdots m_r$ minus the all-fire and no-fire blocks, and the wall moves to the
largest prime. Working out which conflations are harmless and which manufacture
artefacts in the multi-prime setting is the natural next step.

---

## 12. Conclusion

Factor locality is not an empirical regularity but an algebraic one. A method whose step
is natural in the ring has, by definition, a mod-$p$ shadow that is itself the mod-$p$
run; the cofactor cannot enter, so the cost is exactly flat and bounded by $p$.
Conversely, a method whose ledger reads only the modulus can be flat only if it is
constant, so trial division's linear-in-$p$, cofactor-sensitive behaviour is forced.
The elliptic curve method sits on the local side by an exact count rather than by
naturality: its stage-1 rate is $\gcd(m,k(B))/m$, with the cofactor's group order
cancelling identically, and its curve count is bounded by the Hasse ceiling of the
factor, antitone in the bound, and equal to one past the window — so that the only
genuine degeneracy wall lies at the larger prime, and any wall reported at the smaller
one is an artefact of a non-injective ledger.
