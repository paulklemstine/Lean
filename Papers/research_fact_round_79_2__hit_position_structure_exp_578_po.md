# Positional Geometry of the Fermat / Quadratic-Sieve Polynomial

**Carriers, discrepancy bounds, and the non-locality of the smooth locus**

*Aristotle*

---

## Abstract

For a composite modulus $N$ and base $b = \lceil\sqrt N\,\rceil$, the *sieve polynomial* is $v(j) = (b+j)^2 - N$, and a *hit* at position $j$ is a position whose value $v(j)$ is $B$-smooth. Extensive sampling on balanced $96$-bit semiprimes shows that hits cluster toward small $j$: pooled over $9565$ hits from $127$ moduli, the rescaled hit position deviates from uniformity with Kolmogorov–Smirnov statistic $D = 0.09519$ against a null control at $D = 0.00693$, with a monotone declining decile profile from $0.162$ down to $0.072$. This paper develops the exact arithmetic theory needed to interpret such a signal, separating the *magnitude* channel from the *positional* channel.

We prove: (i) the **Position–GCD Law** $\gcd(j, v(j)) = \gcd(j, v(0))$, so the entire arithmetic interaction between a position and its own value is fixed by the single integer $v(0) = b^2 - N$; (ii) a **free cofactor reduction** turning this into a genuine, magnitude-free smoothness enrichment; (iii) that this *gcd carrier* is nevertheless **positionally uniform**, being periodic of period $|v(0)|$, as is divisibility by any fixed prime (at most two residue classes) or prime power; (iv) a general **local discrepancy bound**: a residue-determined position property has window counts differing by at most its modulus, so an observed block excess of $E$ hits forces every local explanation to have modulus $T \ge E$; (v) that the unique declining local carrier is full self-divisibility $j \mid v(j) \iff j \mid v(0)$, with exact density $1/j$ and a proved **harmonic block decline** yielding a strict small-$j$ excess; (vi) the **magnitude sandwich** $2bj \le v(j) \le 2bj + j^2 + 2b$ and the resulting **cell collapse**, showing that stratifying by $|v|$ within one $N$ confines positions to a factor-two window and therefore cannot decorrelate position from magnitude; (vii) **non-locality of the smooth locus**: no modulus and no set of residues describes the positions carrying smooth values, witnessed by unbounded block imbalance on an explicit degenerate sieve; and (viii) exact **terminal-position** geometry: the square positions of a semiprime sieve are the trivial factorization and Fermat's terminal position $2(b+j) = p+q$, which itself obeys the magnitude law $2bj_0 \le d^2$.

The parsimonious picture that survives is: within-$N$ small-$j$ clustering $=$ the linear magnitude law $+$ a positionally uniform divisibility enrichment $+$ a thin harmonic sliver. Every congruence-type alternative is now quantitatively bounded, and the residual signal is pushed onto explicitly non-local or cross-modulus mechanisms.

**Keywords.** Fermat factorization, quadratic sieve, smooth numbers, sieve polynomial, equidistribution, discrepancy, Kolmogorov–Smirnov, semiprimes.

---

## 1. Introduction

### 1.1 The sieve polynomial

Fermat's factorization method searches for a representation $N = x^2 - k^2$, from which $N = (x-k)(x+k)$ is immediate. Starting at $b = \lceil \sqrt N\,\rceil$ and sweeping upwards, it examines the values

$$v(j) \;=\; (b+j)^2 - N, \qquad j = 0, 1, 2, \dots$$

and halts when $v(j)$ is a perfect square. Congruence-of-squares methods — the quadratic sieve and its relatives — relax the halting condition: rather than waiting for a square, they collect positions where $v(j)$ is **$B$-smooth**, i.e. all of its prime factors are $< B$, and then assemble a square by linear algebra over $\mathbb F_2$ on the exponent vectors. We call such a position a **hit**.

The performance of the whole family of algorithms is therefore a question about the *distribution of hits along the parabola*: how many, and where.

**Definition 1.1 (Sieve polynomial and hits).** For integers $b, N$ put $v_{b,N}(j) = (b+j)^2 - N$. Given a smoothness bound $B$, position $j$ is a *hit* if $|v_{b,N}(j)|$ lies in the set of $B$-smooth numbers, that is, if every prime factor of $|v_{b,N}(j)|$ is smaller than $B$. We write $v(j)$ when $b, N$ are clear, and $v(0) = b^2 - N$ for the *base value*.

### 1.2 The empirical signal

The motivating measurement, carried out on a population of $128$ balanced semiprimes of bit length $96$ with hit positions recorded from $150{,}000$ sampled positions per modulus, is the following.

* **Overdispersion.** The per-modulus hit count has mean $74.95$ and range $29$–$136$, far broader than Poisson; this over-dispersion has now replicated four times across independent populations, leaving $39$–$61\%$ of the between-$N$ variance unexplained by known rate factors.
* **Positional non-uniformity.** Rescaling each hit's position to $u \in [0,1]$ within the searched range and pooling $9565$ hits from the $127$ hit-carrying moduli, the empirical distribution of $u$ deviates from $U[0,1]$ with $D = 0.09519$ at overwhelming significance, whereas a paired control built from non-hits gives $D = 0.00693$, consistent with the null.
* **Decile profile.** The decile masses are
 $$0.162,\ 0.123,\ 0.109,\ 0.097,\ 0.091,\ 0.091,\ 0.090,\ 0.084,\ 0.081,\ 0.072,$$
 monotone declining, against a flat control.
* **Stratification.** Conditioning on eight cells of $(\text{bit-length of } |v|) \times (\text{mantissa octant})$ and comparing each hit only with size-matched non-hits in its own cell, the pooled discrepancy *rises* to $D = 0.10423$; $7$ of $8$ cells are individually significant (median cell $p = 1.86\times 10^{-5}$); a within-cell permutation test gives $p < 0.0005$.
* **Null legs.** Lag-$1..10$ autocorrelation of the hit indicator is $\rho = +0.00283$ with confidence interval $[0.00112, 0.00475]$ — excluding zero but below the pre-registered $0.05$ threshold — and the edge fraction is $0.2346$ against a baseline of $0.20$, below the pre-registered $0.25$ threshold. Neither leg fires; their controls are null.

The natural first reading — "$v$ is increasing, small $j$ means small values, small values are more often smooth" — is precisely what the stratification was designed to remove. This paper asks what is arithmetically *possible*: which mechanisms could in principle produce a small-$j$ excess, how large an excess each can produce, and what the stratification protocol actually controls.

### 1.3 Contributions and organization

Section 2 proves the position–gcd law and turns it into a smoothness carrier. Section 3 develops the equidistribution device and shows that every local carrier — primes, prime powers, gcd — is positionally uniform, culminating in a discrepancy bound usable as a falsification instrument. Section 4 isolates the unique declining local carrier and proves its harmonic small-$j$ excess. Section 5 quantifies the magnitude channel and proves the cell-collapse obstruction to size-stratification. Section 6 proves non-locality of the smooth locus. Section 7 gives the exact terminal-position geometry. Section 8 assembles the interpretation; Section 9 discusses algorithms and applications; Section 10 lists open directions.

---

## 2. The position–GCD law and the gcd carrier

Everything begins with the exact expansion of the polynomial about its own starting point.

**Lemma 2.1 (Base expansion).** For all $b, N, j \in \mathbb Z$,
$$v(j) - v(0) \;=\; j\,(j + 2b).$$

*Proof.* $((b+j)^2 - N) - (b^2 - N) = 2bj + j^2 = j(j+2b)$. $\square$

**Lemma 2.2 (Strict monotonicity).** If $b \ge 0$ and $0 \le j_1 < j_2$ then $v(j_1) < v(j_2)$.

*Proof.* $0 \le b + j_1 < b + j_2$, so $(b+j_1)^2 < (b+j_2)^2$; subtract $N$. $\square$

Thus, on the relevant range, *position and magnitude are functionally dependent*: they are strictly increasing functions of each other. This single fact will return with force in Section 5.

**Theorem 2.3 (Position–GCD Law).** For all $b, N, j \in \mathbb Z$,
$$\gcd\bigl(j,\; v(j)\bigr) \;=\; \gcd\bigl(j,\; v(0)\bigr).$$

*Proof.* By Lemma 2.1, $v(j) = v(0) + (j + 2b)\, j$. Adding a multiple of $j$ to the second argument does not change its gcd with $j$. $\square$

**Corollary 2.4 (Self-divisibility form).** $j \mid v(j) \iff j \mid v(0)$.

The content is that the *arithmetic* relation between a sieve position and the value it carries is not a moving target: it is governed entirely by the fixed integer $v(0) = b^2 - N$, computable before the sieve starts. Position $j$ interacts with its own value exactly as it interacts with $v(0)$.

This becomes a statement about smoothness through an elementary but essential observation.

**Theorem 2.5 (Free cofactor reduction).** Let $B$ be a smoothness bound, $v$ a positive integer, and $g \mid v$ with $0 < g < B$. Then $v$ is $B$-smooth if and only if $v/g$ is $B$-smooth.

*Proof.* ($\Rightarrow$) A divisor of a $B$-smooth number is $B$-smooth. ($\Leftarrow$) Every positive integer $g < B$ is itself $B$-smooth, since all of its prime factors are $\le g < B$; the $B$-smooth numbers are closed under multiplication, so $g \cdot (v/g) = v$ is $B$-smooth. $\square$

**Corollary 2.6 (The gcd carrier).** Put $g(j) = \gcd(j, v(0))$. If $0 < g(j) < B$ then position $j$ is a hit if and only if the *reduced cofactor* $|v(j)|/g(j)$ is $B$-smooth. In particular, if $0 < j < B$ and $j \mid v(0)$, then $|v(j)|$ is $B$-smooth as soon as $|v(j)/j|$ is.

This is a genuinely **beyond-magnitude** enrichment: the effective quantity being tested at position $j$ is smaller than $v(j)$ by a factor depending only on the arithmetic of $j$ against $v(0)$, not on $|v(j)|$ at all. Measured at matched magnitude, positions with nontrivial $g(j)$ hit about $21\%$ more often, with a monotone dose–response in $\log g$ (standardized effect $z = +24.2$).

The carrier is thus established as real. The next section shows that it is nonetheless the wrong shape to explain clustering.

---

## 3. Local carriers are positionally uniform

### 3.1 The equidistribution device

**Definition 3.1 (Local position property).** A property $P \subseteq \mathbb Z$ of positions is *local of modulus $T$* if there is $Q \subseteq \mathbb Z/T\mathbb Z$ with $P(j) \iff Q(j \bmod T)$ for all $j$.

**Theorem 3.2 (Window equidistribution).** Let $P$ be local of modulus $T \ge 1$ with residue set $Q$. Then for every starting point $a \in \mathbb Z$,
$$\#\{\, 0 \le i < T : P(a + i) \,\} \;=\; \#Q .$$
In particular the count is independent of $a$.

*Proof.* The map $i \mapsto (a+i) \bmod T$ is a bijection from $\{0,\dots,T-1\}$ to $\mathbb Z/T\mathbb Z$, with inverse $x \mapsto (x - a \bmod T)$ taken as a representative in $[0,T)$. It carries the positions satisfying $P$ exactly onto $Q$. $\square$

### 3.2 Primes and prime powers

**Theorem 3.3 (Two residue classes per prime).** Let $p$ be prime. The set of residues $x \bmod p$ with $p \mid v(x)$, i.e. with $(b + x)^2 \equiv N \pmod p$, has cardinality at most $2$.

*Proof.* If no solution exists the set is empty. If $r$ is a solution and $x$ is any solution, then $(b+x)^2 - (b+r)^2 = (x-r)(x+r+2b) \equiv 0 \pmod p$, so $x \equiv r$ or $x \equiv -r-2b$. $\square$

**Corollary 3.4 (Exact positional uniformity of prime divisibility).** For every prime $p$, every window of $p$ consecutive positions contains the same number of positions $j$ with $p \mid v(j)$, and that number is at most $2$. No single small prime can generate a small-$j$ excess.

*Proof.* Divisibility by $p$ is local of modulus $p$, since $p \mid v(j)$ depends only on $j \bmod p$; apply Theorems 3.2 and 3.3. $\square$

The lifting to prime powers is exact — no extra solutions appear.

**Theorem 3.5 (Prime powers give two classes).** Let $p$ be an odd prime with $p \nmid N$, and $k \ge 1$. If $p^k \mid v(x)$ and $p^k \mid v(y)$ then
$$p^k \mid (x - y) \quad\text{or}\quad p^k \mid (x + y + 2b).$$
Equivalently, fixing one solution $r$, every solution $x$ satisfies $x \equiv r$ or $x \equiv -r - 2b \pmod{p^k}$.

*Proof.* From $v(x) - v(y) = (x-y)(x+y+2b)$ we get $p^k \mid (x-y)(x+y+2b)$. Since $p \mid v(x)$ and $p \nmid N$, $p \nmid (b+x)$: otherwise $p \mid (b+x)^2 - v(x) = N$. As $p$ is odd, $p \nmid 2$. Now if $p \nmid (x - y)$ we may push all of $p^k$ into the second factor; if $p \mid (x-y)$ then $p \nmid (x+y+2b)$, since their sum is $2(b+x)$, which is prime to $p$, and so all of $p^k$ divides $(x-y)$. $\square$

**Corollary 3.6.** Divisibility by $p^k$ is local of modulus $p^k$ with at most two residue classes, hence exactly equidistributed at that scale.

### 3.3 The gcd carrier is uniform

**Theorem 3.7 (Positional uniformity of the gcd carrier).** Suppose $v(0) \ne 0$. The set of positions with $\gcd(j, v(0)) > 1$ is local of modulus $|v(0)|$; consequently every window of $|v(0)|$ consecutive positions contains the same number of such positions.

*Proof.* $\gcd(j, v(0))$ depends only on $j \bmod v(0)$, since $\gcd(j, v(0)) = \gcd(j \bmod v(0),\, v(0))$. Apply Theorem 3.2 with $T = |v(0)|$. $\square$

Combining Corollary 2.6 with Theorem 3.7: *the gcd carrier is a real, magnitude-free smoothness enrichment which is exactly uniform in position, and therefore cannot be the source of an observed small-$j$ excess.*

### 3.4 A discrepancy bound as a falsification instrument

Write $\mathrm{cnt}_P(a, L) = \#\{0 \le i < L : P(a+i)\}$ for the count of a position property in the window $[a, a+L)$.

**Lemma 3.8 (Additivity).** $\mathrm{cnt}_P(a, L_1 + L_2) = \mathrm{cnt}_P(a, L_1) + \mathrm{cnt}_P(a + L_1, L_2)$, and $\mathrm{cnt}_P(a, L) \le L$.

**Lemma 3.9 (Full periods).** If $P$ is local of modulus $T$ with residue set $Q$, then $\mathrm{cnt}_P(a, T m) = m\,\#Q$ for every $a$ and $m \ge 0$.

*Proof.* Induction on $m$ using Lemma 3.8 and Theorem 3.2. $\square$

**Theorem 3.10 (Window bounds).** Let $P$ be local of modulus $T$ with residue set $Q$, and let $L = Tm + r$ with $0 \le r < T$. Then for every $a$,
$$m\,\#Q \;\le\; \mathrm{cnt}_P(a, L) \;\le\; m\,\#Q + T .$$

*Proof.* Split $L$ into $m$ full periods and a remainder of length $r < T$; the remainder contributes between $0$ and $r \le T$. $\square$

**Theorem 3.11 (Local block balance).** Let $P$ be local of modulus $T$. Then for any two windows of the same length $L$,
$$\bigl|\mathrm{cnt}_P(a, L) - \mathrm{cnt}_P(a', L)\bigr| \;\le\; T .$$

*Proof.* Both counts lie in the interval $[m\#Q,\; m\#Q + T]$ of Theorem 3.10. $\square$

**Corollary 3.12 (Modulus lower bound; falsification instrument).** Suppose two equally long blocks of sieve positions are observed to differ by $E$ hits. Then *every* local explanation of the excess must have modulus $T \ge E$. Equivalently, all carriers of modulus $T < E$ are ruled out by that single observation.

This converts a positional excess from a $p$-value into a structural constraint, and is the recommended reporting standard for such measurements: an excess of $E$ hits kills all congruence-type mechanisms below modulus $E$.

---

## 4. The unique declining carrier: exact $1/j$ density

The extreme case of the position–gcd law is full self-divisibility. By Corollary 2.4, $j \mid v(j)$ iff $j \mid v(0)$ — a divisor condition on the *fixed* integer $v(0)$, whose density in $j$ decreases.

**Theorem 4.1 (One multiple per window).** For $d \ge 1$ and any $a \in \mathbb Z$, exactly one of $a, a+1, \dots, a + d - 1$ is divisible by $d$.

*Proof.* Divisibility by $d$ is local of modulus $d$ with residue set $\{0\}$; apply Theorem 3.2. $\square$

**Theorem 4.2 (Exact density $1/d$).** For $d \ge 1$, $t \ge 0$ and any $a$, exactly $t$ of the $d\,t$ consecutive integers $a, \dots, a + dt - 1$ are divisible by $d$.

*Proof.* Induction on $t$: split the window $[a, a + d(t+1))$ into $[a, a+dt)$ and the length-$d$ window starting at $a + dt$, and apply Theorem 4.1 to the second. $\square$

So the self-divisibility carrier has density *exactly* $1/j$ at position scale $j$: a declining profile, in sharp contrast to the flat gcd carrier.

**Theorem 4.3 (Harmonic block decline).** For every integer $K \ge 1$,
$$\sum_{j=K+1}^{2K} \frac 1 j \;<\; \sum_{j=1}^{K} \frac 1 j .$$

*Proof.* The left sum has exactly $K$ terms, each at most $1/(K+1)$, hence is at most $K/(K+1) < 1$. The right sum contains the term $j = 1$ and all terms are nonnegative, hence is at least $1$. $\square$

**Theorem 4.4 (Small-$j$ excess of the self-divisibility carrier).** Let $K \ge 1$ and let $M \ge 1$ be divisible by every $j \in [1, 2K]$ (so that all densities in the window are exact). For any $a \in \mathbb Z$, averaging over the $M$ consecutive base values $a, a+1, \dots, a+M-1$,
$$\sum_{j=K+1}^{2K} \#\{\, 0 \le i < M : j \mid a + i \,\} \;<\; \sum_{j=1}^{K} \#\{\, 0 \le i < M : j \mid a + i \,\}.$$
Equivalently, the expected number of positions $j \in [1,K]$ with $j \mid v(j)$ strictly exceeds the expected number in the next block $(K, 2K]$.

*Proof.* By Theorem 4.2, for each $j \le 2K$ the inner count equals $M/j$ exactly. So both sides are $M$ times the corresponding harmonic sum, and Theorem 4.3 applies after multiplying by $M > 0$. $\square$

Thus the *shape* observed in the data — monotone decline across position blocks — has an exact, magnitude-free arithmetic ancestor. Two caveats keep it honest: its mass is a harmonic tail (small), and by Theorem 3.11 its per-window discrepancy is bounded by its modulus, so it cannot manufacture a large excess.

**Proposition 4.5 (Carrier contrast).** For $d \ge 1$, $t \ge 0$, the count of $d$-divisible positions in a window of length $d t$ is $t$, while in a window of length $2dt$ it is $2t$: the *rate* is scale-invariant at fixed $d$, but doubling the position scale $d \mapsto 2d$ halves the density. The gcd carrier's window count, by contrast, is invariant under translation of the window at fixed length (Theorem 3.7). The two carriers are quantitatively separated: one declines in the scale parameter, the other does not move at all.

---

## 5. The magnitude channel and the collapse of size-stratification

We now pin down the competing explanation exactly. Assume $b = \lceil\sqrt N\,\rceil$, made precise as $(b-1)^2 \le N \le b^2$.

**Theorem 5.1 (Magnitude sandwich).** For $j \ge 0$ and $(b-1)^2 \le N \le b^2$,
$$2bj \;\le\; v(j) \;\le\; 2bj + j^2 + 2b .$$

*Proof.* Write $v(j) = 2bj + j^2 + (b^2 - N)$. Since $N \le b^2$ we have $b^2 - N \ge 0$, whence $v(j) \ge 2bj + j^2 \ge 2bj$. Since $(b-1)^2 \le N$ we have $b^2 - N \le b^2 - (b-1)^2 = 2b - 1 \le 2b$, whence $v(j) \le 2bj + j^2 + 2b$. $\square$

For the practical range $j \ll b$ the value is essentially the *linear* function $2bj$: magnitude and position are the same variable up to bounded distortion. Two consequences.

**Theorem 5.2 (Position bound from a value bound).** If $j \ge 0$ and $v(j) \le X$ then $2bj \le X$, i.e. $j \le X/(2b)$.

**Theorem 5.3 (Initial-block localization).** For $b \ge 1$, the number of positions $j \ge 1$ with $v(j) \le X$ is at most $\lfloor X/(2b)\rfloor$. Conversely, for $2 \le j \le b$ one has $v(j) \le 4bj$, so every position $j \le X/(4b)$ in that range does carry a value $\le X$. Hence the sub-$X$ part of the sieve is an initial block of positions of length between $X/(4b)$ and $X/(2b)$.

*Proof.* The first claim is Theorem 5.2 plus counting. For the second, $v(j) = 2bj + j^2 + (b^2 - N) \le 2bj + jb + 2b \le 4bj$ when $2 \le j \le b$. $\square$

This is what any positional test must be controlled against. And it is exactly here that the stratification protocol breaks.

**Theorem 5.4 (Size classes are position intervals).** Let $b \ge 0$ and let $f$ be any monotone function of the value. If $f(v(j_1)) = f(v(j_2)) = c$ and $0 \le j_1 \le j \le j_2$, then $f(v(j)) = c$. That is, every magnitude class is an *order-connected set of positions*.

*Proof.* By Lemma 2.2, $v$ is increasing on $j \ge 0$; hence $f\circ v$ is monotone, and $c = f(v(j_1)) \le f(v(j)) \le f(v(j_2)) = c$. $\square$

**Theorem 5.5 (Cell collapse).** Let $b \ge 1$, $(b-1)^2 \le N$, and suppose $j_1, j_2$ lie in the same one-bit magnitude cell in the weak sense $v(j_2) \le 2\,v(j_1)$. Then
$$b\,j_2 \;\le\; 2b\,j_1 + 2b + j_1^2, \qquad\text{i.e.}\qquad j_2 \le 2j_1 + 2 + \frac{j_1^2}{b}.$$

*Proof.* Expand both sides of $(b+j_2)^2 - N \le 2\bigl((b+j_1)^2 - N\bigr)$, use $N \ge (b-1)^2$, and simplify; the quadratic inequality reduces to the stated linear bound after discarding nonnegative squares. $\square$

**Corollary 5.6 (Sharp small-position form).** If in addition $j_1^2 \le b$, then $j_2 \le 2j_1 + 3$.

**Interpretation.** Within a single modulus $N$, conditioning on the bit-length (or bit-length times mantissa octant) of $|v|$ confines the positions in a cell to a factor-two window, by Theorem 5.5, and each cell is an interval of positions, by Theorem 5.4. There is therefore *nothing within a cell to decorrelate*: position and magnitude remain tied. A pooled "stratified" positional statistic computed across such cells is not reading within-cell geometry; it is re-reading the same position–magnitude tie cell by cell, with the pooling providing the apparent gain. This does not refute the measurement, but it does mean the observed strengthening of $D$ under stratification ($0.09519 \to 0.10423$) cannot be interpreted as magnitude-free within-$N$ geometry without a control that breaks Theorem 5.4 — for instance a *cross-modulus* comparison at matched $|v|$ but widely differing $j$. When such a comparison is performed at matched $|v|$ and $256$-fold different positions, the hit rates agree to within $4\%$ (weighted ratio $R = 0.983$): no positional excess is detected.

---

## 6. Non-locality of the smooth locus

Sections 3–4 bound what congruence-type mechanisms can do. It remains to ask whether the smooth locus itself is such a mechanism. It is not, and the obstruction is unbounded.

Consider the *degenerate sieve* $b = 1$, $N = 0$, whose values are $v(j) = (j+1)^2$, with smoothness bound $B = 3$.

**Lemma 6.1 ($3$-smooth numbers).** A positive integer $n$ is $3$-smooth if and only if $n = 2^k$ for some $k \ge 0$.

*Proof.* If $n$ is $3$-smooth, its only possible prime factor is $2$, so $n$ is a power of two. Conversely every prime dividing $2^k$ equals $2 < 3$. $\square$

**Lemma 6.2 (Hit positions of the degenerate sieve).** For $i \ge 0$, position $i$ is a hit if and only if $i + 1$ is a power of two.

*Proof.* The value is $(i+1)^2$, which is a power of two iff $i+1$ is; use Lemma 6.1 and the fact that $B$-smoothness passes to divisors and squares. $\square$

**Theorem 6.3 (Unbounded block imbalance).** For every $n \ge 0$, the block $[0, 2^n)$ contains at least $n+1$ hits, while the block $[2^n, 2^{n+1})$ of the same length contains at most one. Hence
$$\mathrm{cnt}\bigl(0, 2^n\bigr) \;\ge\; \mathrm{cnt}\bigl(2^n, 2^n\bigr) + n .$$

*Proof.* The positions $2^k - 1$ for $k = 0, 1, \dots, n$ all lie in $[0, 2^n)$ and are distinct, giving $n+1$ hits. In $[2^n, 2^{n+1})$, a hit at $i$ requires $i + 1 = 2^k$ with $2^n < 2^k \le 2^{n+1}$, forcing $k = n+1$ and $i = 2^{n+1}-1$: at most one position. $\square$

**Theorem 6.4 (The smooth locus is not local).** For every $T$ there exist two equally long blocks of positions whose hit counts differ by more than $T$. Consequently there is no modulus $T$ and no set of residues $Q \subseteq \mathbb Z/T\mathbb Z$ such that a position carries a smooth value exactly when its residue lies in $Q$.

*Proof.* Take $n = T+1$ in Theorem 6.3: the imbalance is at least $T + 1 > T$. If the locus were local of modulus $T$, Theorem 3.11 would bound the imbalance by $T$ — contradiction. $\square$

**Consequence.** The dichotomy is complete. Local carriers have positional discrepancy at most their modulus (Theorem 3.11); the smooth locus has unbounded positional discrepancy (Theorem 6.4); therefore the positional structure of hits is not, in general, of congruence type. The only mechanism on the table with unbounded positional reach is the magnitude law $v(j) \approx 2bj$ of Theorem 5.1.

---

## 7. Exact geometry of the terminal Fermat position

One family of positions is understood exactly rather than statistically, and provides a calibration for positional claims.

**Theorem 7.1 (Square positions are factorizations).** For all $b, N, j, k$,
$$v(j) = k^2 \iff N = (b + j - k)(b + j + k).$$

*Proof.* Both sides are equivalent to $(b+j)^2 - k^2 = N$. $\square$

**Theorem 7.2 (Terminal position).** If $N = s^2 - d^2$ then $v(s - b) = d^2$. In particular, for $N = pq$ with $p + q = 2s$ and $q - p = 2d$, the position $j_0 = s - b$ carries the perfect square $d^2$; this is the *terminal Fermat position*, at which the method halts.

*Proof.* $v(s-b) = (b + s - b)^2 - (s^2 - d^2) = d^2$. For the semiprime form, $4pq = (p+q)^2 - (q-p)^2 = 4(s^2 - d^2)$. $\square$

**Theorem 7.3 (The terminal position obeys the magnitude law).** If $b \le s$ and $s^2 - d^2 \le b^2$ (as holds for $b = \lceil\sqrt N\,\rceil$), then
$$2b\,(s - b) \;\le\; d^2 .$$

*Proof.* $2b(s-b) \le (s-b)(s+b) = s^2 - b^2 \le d^2$ using $b \le s$ and $s^2 - d^2 \le b^2$. $\square$

So a balanced semiprime has its terminal position at small $j$ *because the value there, $d^2$, is small* — a magnitude statement, not extra positional structure. Even the one exactly known position is governed by the linear law.

**Theorem 7.4 (Uniqueness of square positions for semiprimes).** Let $p \le q$ be primes and $N = pq$. If $v(j) = k^2$ with $k \ge 0$ and $b + j - k > 1$, then $2(b+j) = p + q$: the position is the terminal Fermat position. Every other square position corresponds to the trivial factorization $b + j - k = 1$.

*Proof.* By Theorem 7.1, $(b+j-k)(b+j+k) = pq$ with $1 < b+j-k \le b+j+k$. The only factorizations of a semiprime into an ordered pair $u \le w$ are $(1, pq)$ and $(p,q)$: if $p \mid u$ write $u = p u'$, then $u' w = q$ forces $u' = 1$ (else $w = 1$, contradicting $u \le w$ and $q \ge 2$); if $p \nmid u$ then $u \mid q$ by coprimality, giving $u \in \{1, q\}$, and $u = q$ forces $w = p \le u$, hence $u = p = q$. Excluding $u = 1$ leaves $u = p$, $w = q$, and adding these gives $2(b+j) = p+q$. $\square$

---

## 8. Synthesis: what the theory says about the measurement

Assemble the results.

1. **A beyond-magnitude carrier exists.** By Theorems 2.3 and 2.5, the guaranteed factor $g(j) = \gcd(j, v(0))$ can be divided out for free when $g(j) < B$, lowering the effective smoothness threshold at that position — a real enrichment invisible to $|v(j)|$, and empirically worth about $21\%$ in hit rate at matched magnitude.
2. **But it is positionally flat.** By Theorem 3.7 it is periodic of period $|v(0)|$; by Theorem 3.2 its window counts are translation-invariant. It enriches without clustering. The same holds for divisibility by any prime (Corollary 3.4) or prime power (Corollary 3.6).
3. **Only the full-divisor sub-carrier declines.** $j \mid v(j) \iff j \mid v(0)$ has exact density $1/j$ (Theorem 4.2) and a proved block-wise harmonic decline (Theorems 4.3, 4.4). Its mass is small.
4. **Every local mechanism is quantitatively capped.** Theorem 3.11 bounds block imbalance by the modulus, so an excess of $E$ hits forces $T \ge E$ (Corollary 3.12). This is a reusable falsification instrument.
5. **Magnitude cannot be conditioned away within one $N$.** Theorems 5.4 and 5.5 show that magnitude cells are intervals of positions confined to a factor-two window, so the stratified statistic does not isolate positional geometry.
6. **The smooth locus is not local.** Theorem 6.4: no modulus describes it; its imbalance is unbounded. Whatever produces large positional excesses is not a congruence.
7. **The exactly known position is a magnitude phenomenon.** Theorem 7.3.
8. **Cross-scale evidence is null.** At matched $|v|$ and $256$-fold different positions, hit rates agree to within $4\%$ ($R = 0.983$).

**The parsimonious picture.** Within-$N$ small-$j$ clustering $=$ the magnitude law $2bj \le v(j) \le 2bj + j^2 + 2b$, plus a positionally uniform divisibility enrichment governed by $v(0)$, plus a thin harmonic sliver from full self-divisibility. The measured signal is not thereby explained away — it is made *expensive*: any surviving explanation must be non-local, or have modulus at least the observed excess, or be a cross-modulus rather than within-modulus effect. That is a narrowed corridor, not a closed door.

---

## 9. Algorithms and applications

### 9.1 Free-cofactor sieving

Corollary 2.6 is directly implementable. Before sieving, compute $v(0) = b^2 - N$ once. At each position $j < B$, compute $g = \gcd(j, v(0))$ (one Euclidean step chain, $O(\log j)$) and test $|v(j)|/g$ rather than $|v(j)|$. The saving is a factor $g$ off the number to be factored at that position, at negligible cost, and it applies uniformly along the sieve. For $j$ ranging over a block of length $L$, the total number of positions receiving a nontrivial discount equals the count of $j$ in the block sharing a factor with $v(0)$, a quantity predicted exactly by Theorem 3.7.

### 9.2 The modulus lower bound as a reporting standard

Corollary 3.12 gives a one-line conversion from a measured block excess $E$ to a lower bound on the modulus of any local explanation. Any experiment reporting positional structure should report $E$ alongside its $p$-value, since $E$ is what excludes mechanisms; $p$-values exclude only chance.

### 9.3 Stratification design

Theorems 5.4 and 5.5 imply a concrete design rule: within a single modulus, do not stratify by $|v|$ to control for magnitude — it is a no-op, since size cells are position intervals. Valid designs must compare across moduli at matched $|v|$ and dissimilar $j$, or must match on $j$ and vary $|v|$ by changing $b$ (multiple-polynomial sieving), which is precisely where the null cross-scale result of Section 8(8) was obtained.

### 9.4 Calibration by the terminal position

Theorems 7.2–7.4 give an exactly known hit whose position is predictable from the factor gap: $j_0 = s - b$, with $2b j_0 \le d^2$. Any positional statistic can be validated by checking that it assigns the terminal position the score the magnitude law predicts, not more.

---

## 10. Future directions

**D1. Harmonic law for the full-divisor carrier.** Because $j \mid v(j) \iff j \mid v(0)$, the only position-declining carrier is a divisor-counting problem for the *single* integer $v(0)$, so its profile should be $d(v(0))$-shaped rather than merely $1/j$-shaped. Conjecture: for a random base value the expected number of self-divisor positions in $[1, J]$ is $\log J + 2\gamma - 1 + o(1)$; the mass of the block $(K, 2K]$ converges to $\log 2$, so the small-$j$ excess of $[1,K]$ over $(K,2K]$ widens like $\log K + \gamma - \log 2$. The block-decline half is proved (Theorem 4.4); what remains is the asymptotic constant — the classical Dirichlet divisor problem transported to the sieve.

**D2. Modulus lower bound as a falsification instrument.** Turn Corollary 3.12 into a standard reporting requirement: an excess of $E$ hits rules out all local carriers of modulus below $E$. Combined with the non-locality theorem, this gives a clean two-sided classification of admissible mechanisms.

**D3. Functional form of the small-$j$ profile.** Fit the observed decile profile against the prediction of the magnitude law alone, $\Pr[\text{hit at } j] \approx \rho(u(j))$ with $u = \log v(j)/\log B$ from the Dickman–de Bruijn heuristic, and quantify the residual. The theory above says the residual should be flat in $j$ up to a harmonic tail.

**D4. Positional $\leftrightarrow$ rate link.** Does $j$-local clustering predict *which* moduli are hit-rich? A positive answer would connect the within-$N$ geometry to the $39$–$61\%$ unexplained between-$N$ overdispersion; a negative answer separates the two phenomena.

**D5. Multiple-polynomial designs.** Varying $b$ at fixed $N$ produces families of sieve polynomials whose base values $v(0)$ differ; the gcd carrier's strength varies with $v(0)$ while magnitude is held fixed. This is the cleanest available experimental separation of the two channels.

---

## 11. Conclusion

The distribution of smooth values along the Fermat / quadratic-sieve parabola admits an exact arithmetic anatomy. The interaction between a position and its own value is governed by a single integer through the position–gcd law; that interaction yields a genuine magnitude-free smoothness enrichment; that enrichment is exactly uniform in position; the unique declining sub-carrier is full self-divisibility, with density $1/j$ and a proved harmonic block decline; every congruence-type mechanism is capped by its modulus; the smooth locus itself admits no congruence description; and the magnitude channel ties position to size so tightly that size-stratification within a modulus is vacuous. Together these results replace a vague dichotomy — "magnitude or structure?" — with a precise inventory of what each mechanism can and cannot produce, and turn a measured positional excess into a quantitative lower bound on the complexity of its explanation.
