# Primorial-Assisted Factorization: A Rigorous Mathematical Analysis

## Notation and Definitions

Let $\pi(x)$ denote the prime-counting function. Define the **primorial** up to bound $B$ as:

$$P_B = \prod_{\substack{p \leq B \\ p \text{ prime}}} p = p_1 \cdot p_2 \cdots p_{\pi(B)}$$

Let $N$ be a composite integer with unknown factorization $N = \prod_{i} q_i^{e_i}$, where the $q_i$ are distinct primes.

We assume $P = P_B$ for some "staggeringly large, unspecified" bound $B$, and that every prime factor of $N$ satisfies $q_i \leq B$ (the "near-universal" assumption).

---

## 1. The GCD Bypass: Complexity of $\gcd(N, P)$

### 1.1 What $\gcd(N, P)$ Computes

**Theorem.** If every prime factor of $N$ is at most $B$, then $\gcd(N, P) = \text{rad}(N) = \prod_{i} q_i$, i.e., the squarefree kernel (radical) of $N$.

*Proof.* Since $P_B$ is squarefree and contains every prime $\leq B$ exactly once, $\gcd(N, P_B) = \prod_{q_i \mid N,\; q_i \leq B} q_i = \prod_i q_i = \text{rad}(N)$.  $\square$

This yields the *set* of prime factors (via their product), but **not** the individual factors or their multiplicities. To extract individual primes from $\text{rad}(N)$, one must still factor $\text{rad}(N)$—a potentially hard problem in its own right. When $N$ is an RSA modulus $N = pq$ with $p \neq q$, we get $\gcd(N, P) = pq = N$, which is useless. We learn nothing beyond what we already knew.

**Key structural observation:** For $\gcd(N, P)$ to *directly* reveal a nontrivial factor $1 < d < N$, we would need a $P$ that contains *some but not all* prime factors of $N$. But the premise posits a near-universal primorial containing almost every prime up to $B$. This is a fundamental tension: the more "universal" $P$ is, the less discriminating $\gcd(N, P)$ becomes.

### 1.2 Complexity of the Euclidean Algorithm on $\gcd(N, P)$

Let $n = \lceil \log_2 N \rceil$ and $m = \lceil \log_2 P \rceil$ denote the bit-lengths.

**Classical Euclidean Algorithm.** The number of division steps is $O(\min(n, m))$ by Lamé's theorem (more precisely, bounded by roughly $\log_\varphi(\max(N, P))$ where $\varphi = \frac{1+\sqrt{5}}{2}$). Each division step requires one integer division of an $O(m)$-bit number by an $O(n)$-bit number. Using schoolbook arithmetic, each division costs $O(mn)$ bit operations, giving total complexity:

$$T_{\text{classical}} = O(m \cdot n \cdot \min(m, n)) \subseteq O(m^2 n)$$

**Binary GCD (Stein's algorithm).** Avoids divisions, using only shifts and subtractions. Total cost: $O(m^2)$ bit operations.

**Subquadratic GCD (Schönhage, 1971; Stehlé–Zimmermann, 2004).** Employing a half-GCD recursive strategy analogous to Knuth's algorithm, with fast multiplication as a subroutine:

$$T_{\text{fast-gcd}}(m) = O(M(m) \log m)$$

where $M(m)$ is the cost of multiplying two $m$-bit integers.

### 1.3 The Multiplication Bottleneck: The Magnitude of $P$

By the Prime Number Theorem, $\ln P_B = \sum_{p \leq B} \ln p = \vartheta(B) \sim B$ (Chebyshev's theta function), so:

$$m = \lceil \log_2 P_B \rceil = \Theta(B / \ln 2) = \Theta(B)$$

The primorial $P_B$ has approximately $B$ bits. For "staggeringly large" $B$:

| Multiplication Algorithm | $M(m)$ | Source |
|---|---|---|
| Schoolbook | $O(m^2)$ | Classical |
| Karatsuba (1962) | $O(m^{1.585})$ | $O(m^{\log_2 3})$ |
| Toom–Cook-$k$ | $O(m^{1+\varepsilon})$ for any $\varepsilon > 0$ | Asymptotic family |
| Schönhage–Strassen (1971) | $O(m \log m \log \log m)$ | FFT over $\mathbb{Z}/({2^k+1})\mathbb{Z}$ |
| Harvey–van der Hoeven (2021) | $O(m \log m)$ | Conditionally optimal |

With Harvey–van der Hoeven multiplication:

$$T_{\text{fast-gcd}}(m) = O(m \log^2 m)$$

### 1.4 Space Complexity

**The truly prohibitive constraint is storage.** Storing $P_B$ requires $\Theta(B)$ bits $= \Theta(B/8)$ bytes. For even modest cryptographic bounds:

- $B = 2^{1024}$: Storage requires $\sim 2^{1024}$ bits $\approx 10^{308}$ bits. This exceeds the estimated number of particles in the observable universe ($\sim 10^{80}$) by a factor of $10^{228}$.
- $B = 10^{20}$ (modest): $P_B$ has $\sim 10^{20}$ bits $\approx 12$ exabytes.

Even for "tractable" $B$, the I/O cost of streaming $P$ through memory dominates. The GCD computation, while polynomial in $m$, is rendered infeasible by the sheer magnitude of $P$.

### 1.5 Partial Primorial Strategy

One could compute $\gcd(N, P_B)$ for moderate $B$ (trial division in disguise). This is equivalent to trial division up to $B$, which costs $O(\pi(B) \cdot n) = O\!\left(\frac{B}{\ln B} \cdot n\right)$ using individual trial divisions. The primorial GCD batches these into one operation but with the overhead of constructing and storing $P_B$.

**Verdict:** Computing $\gcd(N, P)$ for a truly universal primorial is **theoretically correct** but **computationally vacuous**. It reduces to a storage problem that dwarfs any savings from fast GCD algorithms.

---

## 2. Quadratic Disconnect: Why $P$ Does Not Accelerate Algebraic Factorization

### 2.1 Euler's Sum of Two Squares

**Theorem (Euler).** If $N = a^2 + b^2 = c^2 + d^2$ with $\{a,b\} \neq \{c,d\}$, then a nontrivial factor of $N$ can be extracted via:

$$\gcd(N,\; (ac + bd)) \quad \text{or} \quad \gcd(N,\; (ad - bc))$$

The core difficulty is **finding** two distinct representations, not computing GCDs once they are known. The representations live in the ring $\mathbb{Z}[i]$, where $N = (a+bi)(a-bi) = (c+di)(c-di)$. Two representations correspond to two *genuinely different* factorizations in $\mathbb{Z}[i]$.

**Why $P$ is irrelevant:** The search for representations $N = a^2 + b^2$ is a problem over $\mathbb{Z}^2$ (or equivalently, $\mathbb{Z}[i]$). It requires finding lattice points on a circle of radius $\sqrt{N}$. Knowledge of $P$—a multiplicative object over $\mathbb{Z}$—provides:

1. **No geometric information** about the distribution of $(a, b)$ pairs on the circle $a^2 + b^2 = N$.
2. **No algebraic shortcut** in $\mathbb{Z}[i]$, because $P$ factors completely differently over $\mathbb{Z}[i]$ than $N$ does. The factorization of $P$ in $\mathbb{Z}[i]$ gives Gaussian integer factors of each prime $p \leq B$, but combining them to reconstruct the Gaussian factorization of $N$ is equivalent to knowing the factorization of $N$ in $\mathbb{Z}$.
3. **No reduction in search space:** The number of representations is $r_2(N) = 4\sum_{d \mid N} \chi(d)$ (where $\chi$ is the nontrivial character mod 4). Computing $r_2(N)$ requires the factorization of $N$—exactly what we seek.

**Formally:** Let $N = pq$ with $p, q$ primes $\equiv 1 \pmod{4}$. Write $p = \pi_p \bar{\pi}_p$ and $q = \pi_q \bar{\pi}_q$ in $\mathbb{Z}[i]$. Then the two representations correspond to:
- $N = (\pi_p \pi_q)(\bar{\pi}_p \bar{\pi}_q)$, giving $a + bi = \pi_p \pi_q$
- $N = (\pi_p \bar{\pi}_q)(\bar{\pi}_p \pi_q)$, giving $c + di = \pi_p \bar{\pi}_q$

To compute these, we need $\pi_p$ and $\pi_q$ individually—i.e., we need to know $p$ and $q$.

### 2.2 Fermat's Factorization

**Fermat's method** seeks $a, b$ such that $N = a^2 - b^2 = (a+b)(a-b)$.

The algorithm iterates: for $a = \lceil\sqrt{N}\rceil, \lceil\sqrt{N}\rceil + 1, \ldots$, check if $a^2 - N$ is a perfect square.

**Complexity:** If $N = pq$ with $p > q$, then $a = \frac{p+q}{2}$, $b = \frac{p-q}{2}$, and the number of iterations is $a - \lceil\sqrt{N}\rceil \approx \frac{(p-q)^2}{4\sqrt{N}}$. For balanced primes ($p \approx q \approx \sqrt{N}$, as in RSA), the gap $p - q$ is $\Theta(\sqrt{N})$, giving $\Theta(\sqrt[4]{N}\,)$ iterations—worse than trial division.

**Why $P$ is irrelevant:** Fermat's method is a **search over the additive structure** of $\mathbb{Z}$: we seek $a$ such that $a^2 - N \in \{b^2 : b \in \mathbb{Z}\}$, i.e., $a^2 \equiv N \pmod{b}$ for some $b$ simultaneously making $a^2 - N$ a perfect square. Knowledge of $P$ (a multiplicative object):

1. **Does not identify the correct $a$.** The value $a = \frac{p+q}{2}$ depends on $p + q$, a *sum* of factors. $P$ encodes *products*. There is no known efficient method to extract $p + q$ from $p \cdot q$ and $P$ without first knowing $p$ and $q$ individually.
2. **Does not accelerate the quadratic residuosity test.** Checking whether $a^2 - N$ is a perfect square costs $O(n^2)$ per candidate via Newton's method for integer square root. $P$ contributes nothing here.
3. **Does not shrink the search interval.** The gap between $\lceil\sqrt{N}\rceil$ and $a = \frac{p+q}{2}$ is determined by $|p - q|$, which is an additive quantity invisible to $P$.

**Algebraic root cause:** Both Euler's and Fermat's methods exploit the ring structure of $\mathbb{Z}$ or $\mathbb{Z}[i]$—specifically, the interplay between multiplication and addition (sums of squares, differences of squares). The primorial $P$ is a purely multiplicative construct. The "quadratic disconnect" is precisely the gap between the **multiplicative monoid** $(\mathbb{Z}, \times)$ and the **ring** $(\mathbb{Z}, +, \times)$. Factorization algorithms that exploit additive or quadratic structure (representations as sums/differences of squares) operate in a domain where multiplicative knowledge alone is structurally insufficient.

---

## 3. The Sieve Parallel: Factor Bases as Curated Sub-Primorials

### 3.1 The Quadratic Sieve (QS) Framework

The Quadratic Sieve (Pomerance, 1981) works as follows:

1. **Choose a factor base** $\mathcal{F} = \{p_1, p_2, \ldots, p_k\}$ consisting of all primes $p \leq B_{\text{smooth}}$ such that $N$ is a quadratic residue mod $p$ (i.e., $\left(\frac{N}{p}\right) = 1$).

2. **Sieve** for $B_{\text{smooth}}$-smooth values: find many $x_i$ such that $Q(x_i) = (x_i + \lfloor\sqrt{N}\rfloor)^2 - N$ factors completely over $\mathcal{F}$:
$$Q(x_i) = \prod_{j=1}^{k} p_j^{e_{ij}}$$

3. **Linear algebra over $\mathbb{F}_2$:** Find a subset $S$ such that $\sum_{i \in S} e_{ij} \equiv 0 \pmod{2}$ for all $j$. This gives:
$$\prod_{i \in S} Q(x_i) = \left(\prod_j p_j^{\sum_i e_{ij}/2}\right)^2 = b^2$$
and $\prod_{i \in S} (x_i + \lfloor\sqrt{N}\rfloor)^2 = a^2$, yielding $a^2 \equiv b^2 \pmod{N}$.

4. **Factor extraction:** $\gcd(a - b, N)$ gives a nontrivial factor with probability $\geq 1/2$.

**Optimal smoothness bound:** $B_{\text{smooth}} = L(N)^{1/2}$ where $L(N) = e^{\sqrt{\ln N \cdot \ln \ln N}}$, giving total complexity $O(L(N))$ — i.e., subexponential.

### 3.2 Structural Comparison: $P$ vs. Factor Bases

| Property | Primorial $P_B$ | QS Factor Base $\mathcal{F}$ |
|---|---|---|
| **Size** | $\pi(B)$ primes, $\Theta(B)$ bits | $\pi(B_{\text{smooth}}) = L(N)^{1/2+o(1)}$ primes |
| **Selection criterion** | All primes $\leq B$ | Only primes $p$ with $\left(\frac{N}{p}\right) = 1$ |
| **Representation** | Single integer (product) | Explicit list (set of primes) |
| **Computational role** | Input to $\gcd$ | Defines the sieve and the exponent vectors |
| **Adaptivity to $N$** | None | Fully adapted via Legendre symbol |

**Critical distinction:** The factor base $\mathcal{F}$ is **adapted to $N$** via the quadratic residuosity condition $\left(\frac{N}{p}\right) = 1$. This ensures that for each $p \in \mathcal{F}$, there exist $x$ with $p \mid Q(x)$, making smooth values findable. The primorial $P$ includes primes where $\left(\frac{N}{p}\right) = -1$; these primes **cannot** divide any $Q(x)$ and are pure dead weight.

Moreover, the QS never computes $\gcd(N, \prod \mathcal{F})$. The factor base is used **element-wise** for sieving: for each $p \in \mathcal{F}$, the algorithm identifies arithmetic progressions $\{x : p \mid Q(x)\}$ and sieves them individually. Collapsing $\mathcal{F}$ into a single product $P_{\mathcal{F}} = \prod_{p \in \mathcal{F}} p$ would destroy the sieve structure entirely.

### 3.3 Could $P$ Replace the Sieve?

One might ask: given $P$, can we skip the sieve and directly determine if $Q(x)$ is smooth by computing $\gcd(Q(x), P)$?

**Analysis:** $\gcd(Q(x), P)$ returns $\text{rad}(Q(x))$ if $Q(x)$ is $B$-smooth, and a proper divisor otherwise. This tells us:
- Whether $Q(x)$ is $B$-smooth: yes, iff $\gcd(Q(x), P) = |Q(x)|$ (after accounting for signs and squarefree parts — more precisely, iff the largest prime factor of $Q(x)$ is $\leq B$). Actually, this test is not quite right: $\gcd(Q(x), P)$ gives the squarefree part of the smooth component. To fully test smoothness, one would need to verify that $Q(x) / \gcd(Q(x), P)^k$ equals 1 after iteratively dividing.

But even if smoothness testing were free, the **bottleneck of QS is not smoothness testing**—it is the *density* of smooth values. The probability that a random $m$-bit integer is $B$-smooth is $u^{-u(1+o(1))}$ where $u = m/\log_2 B$ (Canfield–Erdős–Pomerance theorem). The sieve's role is to *efficiently enumerate* these rare smooth values using the multiplicative structure of $Q(x)$ as $x$ varies in arithmetic progressions. Having $P$ does not increase the density of smooth values; it merely offers an alternative (and inferior) method of detecting them.

**Complexity comparison for smoothness testing of a single value $Q(x)$ of bit-size $s$:**

- **Trial division up to $B$:** $O\!\left(\frac{B}{\ln B} \cdot s\right)$
- **$\gcd(Q(x), P)$ with fast GCD:** $O(M(\max(s, B)) \cdot \log \max(s, B))$ — dramatically worse since $B \gg s$.
- **Sieving (amortized over all $x$):** $O(\log \log B)$ per value of $x$, since each prime $p$ contributes $O(1)$ amortized work.

The sieve is exponentially more efficient than any GCD-based approach.

---

## 4. Applied Cryptography: Batch GCD and Compromised RSA Keys

### 4.1 The Batch GCD Attack (Heninger et al., 2012; Lenstra et al., 2012)

Given a collection $\{N_1, N_2, \ldots, N_k\}$ of RSA moduli, the **batch GCD** algorithm efficiently computes all pairwise GCDs to find moduli that share a prime factor.

**Naive approach:** Compute $\gcd(N_i, N_j)$ for all $\binom{k}{2}$ pairs. Cost: $O(k^2 \cdot n^2)$ for $n$-bit moduli. For $k = 10^7$ (realistic internet-scale), this is $\sim 10^{14}$ GCD computations — infeasible.

**Bernstein's product tree algorithm (2004):**

1. **Compute the product** $\Pi = \prod_{i=1}^{k} N_i$. Cost: $O(M(kn) \log k)$ via a binary product tree. Size: $\Theta(kn)$ bits.

2. **Compute remainders** $r_i = \Pi \bmod N_i^2$ for all $i$, via a **remainder tree** (top-down division). Cost: $O(M(kn) \log k)$.

3. **Extract shared factors:** $\gcd(r_i / N_i, N_i)$ gives $\gcd(N_i, \prod_{j \neq i} N_j)$. If this is nontrivial, $N_i$ shares a factor with some $N_j$.

**Total complexity:** $O(M(kn) \log k) = O(kn \log(kn) \log k)$ using Harvey–van der Hoeven, versus $O(k^2 n^2)$ naively.

### 4.2 Structural Analogy to the Primorial

The product $\Pi = \prod_i N_i$ is structurally analogous to the primorial $P$, but with critical differences:

| Property | Primorial $P_B$ | Batch product $\Pi$ |
|---|---|---|
| **Constituents** | All primes $\leq B$ | RSA moduli $N_i = p_i q_i$ |
| **Size** | $\Theta(B)$ bits | $\Theta(kn)$ bits ($k$ moduli of $n$ bits) |
| **Information content** | Redundant (reconstructible from $B$) | High (encodes all moduli) |
| **Utility of $\gcd(N_i, \cdot)$** | Returns $\text{rad}(N_i) = N_i$ if all factors $\leq B$ | Returns shared factor if one exists |

**The key insight:** Batch GCD works because RSA moduli are **products of two primes**, and the attack exploits **shared factors between different moduli**. The product $\Pi$ serves as a compact encoding of *all* moduli, enabling efficient pairwise comparison. The primorial $P$ contains *every* prime and thus $\gcd(N, P)$ is always trivially $\text{rad}(N)$ — it reveals shared factors with $P$, which is *every* factor.

### 4.3 Why Batch GCD Succeeds Where Primorial GCD Fails

Batch GCD exploits a **specific structural vulnerability**: two independently generated RSA moduli $N_i = p_i q_i$ and $N_j = p_j q_j$ may satisfy $p_i = p_j$ due to faulty random number generation. In this case:

$$\gcd(N_i, N_j) = p_i = p_j$$

This immediately factors both $N_i$ and $N_j$. The attack succeeds because:

1. **The shared factor is a proper divisor** of each modulus (not the full radical).
2. **The product $\Pi$** is feasibly computable: for $k = 10^7$ moduli of 2048 bits, $|\Pi| \approx 2 \times 10^{10}$ bits $\approx 2.5$ GB — large but tractable.
3. **The vulnerability is real:** Heninger et al. (2012) found that $\sim 0.2\%$ of RSA public keys on the internet shared a prime factor, compromising $\sim 64{,}000$ keys.

In contrast, the primorial approach:
- Produces trivial GCDs ($= N$ or $= \text{rad}(N)$).
- Requires infeasible storage.
- Exploits no structural vulnerability — it is brute-force trial division in disguise.

### 4.4 Partial Primorial as Pollard's $p-1$ Method

The closest practical analog to the primorial approach is **Pollard's $p-1$ algorithm** (1974). Here, one computes $P_B = \text{lcm}(1, 2, \ldots, B)$ (closely related to the primorial) and then $\gcd(a^{P_B} - 1, N)$ for a random base $a$. If $p \mid N$ and $p - 1$ is $B$-smooth (i.e., all prime factors of $p-1$ are $\leq B$), then $p \mid \gcd(a^{P_B} - 1, N)$.

This is the *correct* way to leverage multiplicative knowledge of many primes for factorization: not through direct GCD with $P$, but through **modular exponentiation** which exploits Fermat's Little Theorem to collapse the group $(\mathbb{Z}/p\mathbb{Z})^*$.

**Complexity:** $O(B \cdot M(n))$ for computing $a^{P_B} \bmod N$, where $n = \log_2 N$. This is efficient for $B$-powersmooth $p - 1$ with moderate $B$, but fails for RSA primes specifically chosen so that $p - 1$ has large prime factors.

---

## 5. Summary: The Fundamental Friction

The analysis reveals three layers of impossibility:

### Layer 1: Information-Theoretic Redundancy
$P_B$ is **fully determined by $B$** — it carries zero bits of information beyond the value of $B$ itself. Any computation using $P_B$ can, in principle, be reformulated using $B$ alone (e.g., trial division up to $B$). The primorial is an astronomically expensive encoding of a single number.

### Layer 2: Computational Infeasibility
Even granting oracle access to $P$, the GCD computation costs $O(B \log^2 B)$ bit operations (with optimal multiplication), and $P$ requires $\Theta(B)$ bits of storage. For $B$ sufficient to cover RSA-2048 primes ($B \geq 2^{1024}$), this exceeds all physical computational bounds.

### Layer 3: Structural Mismatch
The deepest issue: factorization hardness does not reside in the multiplicative structure alone. Quadratic and algebraic factorization methods exploit the **ring structure** of $\mathbb{Z}$ — the interplay of addition and multiplication. A primorial, being a purely multiplicative object, is structurally orthogonal to these methods. The multiplicative group $(\mathbb{Z}/N\mathbb{Z})^*$ can be leveraged for factorization (as in Pollard's $p-1$, ECM, etc.), but this requires **modular arithmetic relative to $N$**, not possession of a large product of primes.

In the language of computational complexity: factorization is believed to be hard not because primes are "hidden," but because the *correspondence* between a number's multiplicative decomposition and its representation in positional notation is computationally opaque. Possessing $P$ does not bridge this gap — it merely restates the list of primes, which was never the bottleneck.

---

## References

- Bernstein, D.J. (2004). "How to find smooth parts of integers." Preprint.
- Harvey, D., van der Hoeven, J. (2021). "Integer multiplication in time $O(n \log n)$." *Annals of Mathematics*, 193(2), 563–617.
- Heninger, N., Durumeric, Z., Wustrow, E., Halderman, J.A. (2012). "Mining Your Ps and Qs: Detection of Widespread Weak Keys in Network Devices." *USENIX Security*.
- Lenstra, A.K., Hughes, J.P., Augier, M., Bos, J.W., Kleinjung, T., Wachter, C. (2012). "Ron was wrong, Whit is right." *IACR ePrint 2012/064*.
- Pollard, J.M. (1974). "Theorems on factorization and primality testing." *Proc. Cambridge Phil. Soc.*, 76, 521–528.
- Pomerance, C. (1981). "Analysis and comparison of some integer factoring algorithms." *Computational Methods in Number Theory*, Part I.
- Schönhage, A. (1971). "Schnelle Berechnung von Kettenbruchentwicklungen." *Acta Informatica*, 1, 139–144.
