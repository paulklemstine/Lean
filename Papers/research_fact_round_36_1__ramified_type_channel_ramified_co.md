# Ramified Primes Are Information-Theoretically Negligible: Sharp $O(\log N / N)$ Bounds for Contaminated Counting Channels

**Aristotle**

*2026-10-03*

---

## Abstract

Experiments on the "type channel" of a polynomial measure the empirical mutual information between the residue class of a prime and its splitting type. For $x^2 - 3$ the measured value is $I = 1.0000$ bits on unramified primes and $I = 1.0020$ bits once the two ramified primes $2$ and $3$ are included. We prove that a perturbation of this size is a universal feature of empirical mutual information and has nothing specific to do with primes.

Let a finite sample of size $N$ be the disjoint union of an "unramified" part $U$ and a "ramified" part $R$ with $|R| = r$. For every pair of read-outs $g, k$, the empirical mutual informations satisfy
$$\bigl|I_{U\cup R}(g;k) - I_U(g;k)\bigr| \le \frac{r}{N}\Bigl(3\log_2 N + \frac{2}{\ln 2}\Bigr).$$
The proof rests on an exact decomposition of $N I_{U\cup R}$ into the size-weighted informations of the two parts, a binary-entropy mixing term, and three *fibre defects* of fibre log-sums. Each of these is bounded through an amortised use of $\log(1+t) \le t$.

We show that the rate $\log N / N$ is optimal: an explicit configuration achieves a gain of at least $\frac{r}{N}\log_2 N$. Consequences include asymptotic justification for excluding ramified primes, uniformly over all read-outs; a certified bound of $0.002$ bits for two ramified primes among at least $2^{16}$ sample points; and a transfer theorem showing that a balanced Chebotarev fibre-product model contaminated by $r$ arbitrary points stays within the same bound of the ideal Galois-group channel.

---

## 1. Introduction

### 1.1 The experiment

Let $f \in \mathbb{Z}[x]$ be irreducible with splitting field $K$ and Galois group $G$. For a prime $p$ not dividing the discriminant, the factorisation pattern of $f \bmod p$ (its *splitting type*) is determined by the cycle type of the Frobenius class $\mathrm{Frob}_p \in G$. Chebotarev's density theorem makes these classes equidistributed. For a modulus $m$, the residue $p \bmod m$ sees part of $\mathrm{Frob}_p$, namely its image in a cyclotomic quotient. A natural statistic is therefore the *type channel*: the empirical mutual information, over a finite sample of primes, between the residue $p \bmod m$ and the splitting type.

For $f = x^2 - 3$ (discriminant $12$, ramified primes $\{2,3\}$) quadratic reciprocity shows that for $p \ne 2,3$ the polynomial splits mod $p$ if $p \equiv \pm 1 \pmod{12}$ and is inert if $p \equiv \pm 5 \pmod{12}$. Dirichlet's theorem then gives an ideal channel of exactly $1$ bit for the modulus $m = 12$. The experiment found:

| sample | $I(\text{residue};\text{type})$ |
|---|---|
| unramified primes only | $1.0000$ bits |
| all primes, including $2, 3$ | $1.0020$ bits |

Two primes among thousands shift the channel by $+0.002$ bits. The routine practice of discarding ramified primes therefore needs a justification that does not depend on the specific polynomial, modulus or sample. This paper supplies one.

### 1.2 Results in brief

Writing $N = |U \cup R|$ and $r = |R|$, the main results are:

1. **Exact decomposition** (Theorem 3.3): $N I_{U\cup R} - |U| I_U - r I_R = E - D(g) - D(k) + D(k,g)$. Here $E$ is a mixing term and $D$ denotes the fibre defect.
2. **Ramified bracket** (Theorem 3.4): $\bigl|N I_{U\cup R} - |U| I_U - r I_R\bigr| \le 2r(\log_2 N + 1/\ln 2)$.
3. **Negligibility** (Theorem 4.2): $|I_{U\cup R} - I_U| \le \frac{r}{N}(3\log_2 N + 2/\ln 2)$, for all read-outs.
4. **Asymptotic exclusion** (Corollary 4.4) and the **certified regime** (Corollary 4.5): $r \le 2$ and $N \ge 2^{16}$ give a change of at most $0.002$ bits.
5. **Sharpness** (Theorem 5.1): the gain can be at least $\frac{r}{N}\log_2 N$.
6. **Galois transfer** (Theorem 6.2): a contaminated Chebotarev fibre product lies within the same bound of the Galois channel $I(\sigma;T)$.

All results are statements about finite sets and counting measures. They apply verbatim to any dataset containing a small number of exceptional records.

---

## 2. The counting channel and fibre log-sums

Throughout, $\log_2$ is the binary logarithm, extended by $\log_2 0 = 0$. A *sample* is a finite set $S$, and a *read-out* is any function $f$ from $S$ to some set of labels. All read-outs are allowed; nothing is assumed about their ranges.

**Definition 2.1 (Counting entropies).** Let $S$ be a nonempty sample with $|S| = N$, and let $g, k$ be read-outs. Under the uniform probability on $S$:

- $H_S(g) = -\sum_v \frac{c_v}{N}\log_2\frac{c_v}{N}$, where $c_v = |\{x \in S : g(x) = v\}|$;
- $H_S(g \mid k) = H_S(k,g) - H_S(k)$, where $(k,g)$ is the paired read-out $x \mapsto (k(x), g(x))$;
- $I_S(g;k) = H_S(g) - H_S(g \mid k)$, the **counting mutual information**, or **counting channel**.

For the empty sample all three are set to $0$.

**Definition 2.2 (Fibre log-sum).** For a sample $S$ and a read-out $f$,
$$\Lambda_S(f) = \sum_{a \in S} \log_2 \bigl|\{x \in S : f(x) = f(a)\}\bigr|.$$
Grouping the sum by fibres gives $\Lambda_S(f) = \sum_v c_v \log_2 c_v$, where $c_v$ is the size of the fibre $f^{-1}(v) \cap S$. In particular $\Lambda_S(f) \ge 0$, since every fibre containing a point of $S$ has size at least $1$.

**Lemma 2.3 (Entropies as fibre log-sums).** For nonempty $S$ with $|S| = N$:

1. $H_S(g) = \log_2 N - \Lambda_S(g)/N$;
2. $H_S(g \mid k) = \bigl(\Lambda_S(k) - \Lambda_S(k,g)\bigr)/N$;
3. $N\, I_S(g;k) = N\log_2 N - \Lambda_S(g) - \Lambda_S(k) + \Lambda_S(k,g)$.

The identity in (3) also holds for $S = \varnothing$, where both sides vanish.

*Proof.* For (1), expand $-\sum_v \frac{c_v}{N}(\log_2 c_v - \log_2 N)$ and use $\sum_v c_v = N$. For the paired read-out, the fibre log-sum is the double sum
$$\Lambda_S(k,g) = \sum_{c}\sum_{v} n_{cv}\log_2 n_{cv}, \qquad n_{cv} = |\{x \in S: k(x)=c,\ g(x)=v\}|,$$
where the sum runs over the product of the images of $k$ and $g$. Pairs that do not occur contribute $0 \cdot \log_2 0 = 0$. Applying (1) to $(k,g)$ and to $k$ and subtracting gives (2). Then (3) is (1) minus (2), multiplied by $N$. $\square$

The fibre log-sum of a read-out depends on the sample, and the main object of study is how it changes when the sample grows.

**Definition 2.4 (Fibre defect).** For disjoint samples $U$ and $R$ and a read-out $f$ defined on $U \cup R$,
$$D(f) = \Lambda_{U\cup R}(f) - \Lambda_U(f) - \Lambda_R(f).$$

**Lemma 2.5 (Lower bound on the defect).** $D(f) \ge 0$.

*Proof.* Split $\Lambda_{U\cup R}(f)$ into the sum over $a \in U$ and the sum over $a \in R$. For $a \in U$, the fibre of $a$ in $U\cup R$ contains its fibre in $U$, which is nonempty since it contains $a$. Monotonicity of $\log_2$ gives a term-by-term comparison with $\Lambda_U(f)$. The same argument works for $a \in R$. $\square$

**Lemma 2.6 (Elementary logarithm estimate).** For $u > 0$ and $\rho \ge 0$,
$$\log_2(u + \rho) \le \log_2 u + \frac{\rho}{u \ln 2}.$$

*Proof.* Apply $\ln t \le t - 1$ with $t = (u+\rho)/u$. This gives $\ln(u+\rho) - \ln u \le \rho/u$; then divide by $\ln 2$. $\square$

**Lemma 2.7 (Amortised ratio sum).** For disjoint finite $U, R$ and any read-out $f$,
$$\sum_{a \in U} \frac{|\{x \in R : f(x) = f(a)\}|}{|\{x \in U : f(x) = f(a)\}|} \le |R|.$$

*Proof.* Group the sum by the value $v = f(a)$, over $v \in f(U)$. The $u_v = |f^{-1}(v)\cap U|$ terms with value $v$ each equal $\rho_v/u_v$, where $\rho_v = |f^{-1}(v)\cap R|$, so together they contribute exactly $\rho_v$. The sets $f^{-1}(v)\cap R$ for distinct $v$ are disjoint subsets of $R$, so $\sum_{v\in f(U)} \rho_v \le |R|$. $\square$

**Lemma 2.8 (Upper bound on the defect).** With $N = |U\cup R|$,
$$D(f) \le |R|\Bigl(\log_2 N + \frac{1}{\ln 2}\Bigr).$$

*Proof.* We bound the unramified and ramified contributions separately.

*Unramified points.* For $a \in U$ write $u_a = |\{x\in U: f(x)=f(a)\}| \ge 1$ and $\rho_a = |\{x\in R: f(x)=f(a)\}|$. By disjointness the fibre of $a$ in $U\cup R$ has size $u_a + \rho_a$. Lemma 2.6 gives $\log_2(u_a + \rho_a) \le \log_2 u_a + \rho_a/(u_a\ln 2)$. Summing over $a \in U$ and applying Lemma 2.7, the $U$-part of $\Lambda_{U\cup R}(f)$ is at most $\Lambda_U(f) + |R|/\ln 2$.

*Ramified points.* For $a \in R$ the fibre in $U\cup R$ has size at most $N$, so its logarithm is at most $\log_2 N$. The logarithm of the fibre in $R$ is nonnegative. Hence each term exceeds the corresponding term of $\Lambda_R(f)$ by at most $\log_2 N$, and the $R$-part of $\Lambda_{U\cup R}(f)$ is at most $\Lambda_R(f) + |R|\log_2 N$.

Adding the two bounds gives the claim. $\square$

The unramified estimate is the essential point. A fibre of size $u$ that receives $\rho$ intruders has its logarithm raised by about $\rho/u$ for each of its $u$ members, so it pays $\rho/\ln 2$ in total. The total over all fibres is $|R|/\ln 2$, *independent of $N$*. Only the $|R|$ intruders themselves can cost as much as $\log_2 N$ each.

---

## 3. The exact ramified decomposition

**Definition 3.1 (Mixing term).** For natural numbers $u, r$ put
$$E(u,r) = (u+r)\log_2(u+r) - u\log_2 u - r\log_2 r.$$
For $u + r > 0$ this equals $(u+r)\,h\!\left(\tfrac{r}{u+r}\right)$, where $h$ is the binary entropy function.

**Lemma 3.2 (Mixing bounds).** $0 \le E(u,r) \le r\bigl(\log_2(u+r) + 1/\ln 2\bigr)$.

*Proof.* The lower bound follows from $u\log_2 u \le u\log_2(u+r)$ and $r\log_2 r \le r\log_2(u+r)$. For the upper bound, Lemma 2.6 gives $u\log_2(u+r) \le u\log_2 u + r/\ln 2$ when $u > 0$, and the case $u = 0$ is trivial. Also $r\log_2 r \ge 0$. Then $E(u,r) = u\log_2(u+r) + r\log_2(u+r) - u\log_2 u - r\log_2 r \le r/\ln 2 + r\log_2(u+r)$. $\square$

**Theorem 3.3 (Exact ramified decomposition).** Let $U, R$ be finite samples and $g, k$ read-outs on $U\cup R$. Then
$$|U\cup R|\, I_{U\cup R}(g;k) - |U|\, I_U(g;k) - |R|\, I_R(g;k) = \Bigl(|U\cup R|\log_2|U\cup R| - |U|\log_2|U| - |R|\log_2|R|\Bigr) - D(g) - D(k) + D(k,g).$$
When $U$ and $R$ are disjoint, the first bracket is the mixing term $E(|U|,|R|)$.

*Proof.* Apply Lemma 2.3(3) to each of the three samples $U\cup R$, $U$, $R$ and subtract. The $N\log_2 N$ terms form the first bracket, and the $\Lambda$ terms regroup into fibre defects. $\square$

The decomposition says that the information of the union equals the size-weighted average of the informations of the parts, corrected by mixing and by three defects that enter with signs $-,-,+$.

**Theorem 3.4 (The ramified bracket).** If $U$ and $R$ are disjoint and $N = |U\cup R|$, then for all read-outs $g,k$,
$$\Bigl|N I_{U\cup R}(g;k) - |U| I_U(g;k) - |R| I_R(g;k)\Bigr| \le 2|R|\Bigl(\log_2 N + \frac{1}{\ln 2}\Bigr).$$

*Proof.* Write $B = |R|(\log_2 N + 1/\ln 2)$. By Lemmas 3.2, 2.5 and 2.8, each of $E$, $D(g)$, $D(k)$, $D(k,g)$ lies in $[0, B]$. In Theorem 3.3 the right-hand side $E - D(g) - D(k) + D(k,g)$ is therefore at most $E + D(k,g) \le 2B$ and at least $-D(g) - D(k) \ge -2B$. $\square$

---

## 4. Negligibility of the ramified contribution

We also need the elementary range of the counting channel.

**Lemma 4.1.** For any samples $S \subseteq T$ and read-outs $g, k$: $0 \le I_S(g;k) \le H_S(g) \le \log_2|S| \le \log_2|T|$.

*Proof.* Mutual information is nonnegative. Conditioning does not increase entropy, so $H_S(g\mid k) \ge 0$. An entropy of a distribution on at most $|S|$ atoms is at most $\log_2|S|$, and $\log_2$ is monotone. $\square$

**Theorem 4.2 (Ramified contribution is negligible).** Let $U, R$ be disjoint finite samples with $N = |U\cup R|$. For every pair of read-outs $g,k$,
$$\bigl|I_{U\cup R}(g;k) - I_U(g;k)\bigr| \le \frac{|R|}{N}\Bigl(3\log_2 N + \frac{2}{\ln 2}\Bigr).$$

*Proof.* If $N = 0$ there is nothing to prove. Otherwise $N = |U| + |R|$, and
$$N\bigl(I_{U\cup R} - I_U\bigr) = \bigl(N I_{U\cup R} - |U| I_U - |R| I_R\bigr) + |R|\,(I_R - I_U).$$
The first summand is bounded in absolute value by $2|R|(\log_2 N + 1/\ln 2)$ (Theorem 3.4). By Lemma 4.1 both $I_R$ and $I_U$ lie in $[0, \log_2 N]$, so $|I_R - I_U| \le \log_2 N$ and the second summand is at most $|R|\log_2 N$ in absolute value. Adding the two bounds and dividing by $N$ gives the theorem. $\square$

**Definition 4.3 (Ramified bound).** For natural numbers $r, N$ put
$$\mathcal{B}(r,N) = \frac{r}{N}\Bigl(3\log_2 N + \frac{2}{\ln 2}\Bigr).$$
Theorem 4.2 gives $|I_{U\cup R} - I_U| \le \mathcal{B}(r, N)$ whenever $|R| \le r$, since $\mathcal{B}$ is monotone in $r$.

**Corollary 4.4 (Exclusion is asymptotically justified).** For each fixed $r$, $\mathcal{B}(r,N) \to 0$ as $N\to\infty$. Consequently, for every $r \in \mathbb{N}$ and $\varepsilon > 0$ there is $N_0$ with the following property. For all disjoint $U,R$ with $|R| \le r$ and $|U\cup R| \ge N_0$, and all read-outs $g,k$,
$$|I_{U\cup R}(g;k) - I_U(g;k)| \le \varepsilon.$$

*Proof.* We have $\mathcal{B}(r,N) = r\bigl(\tfrac{3}{\ln 2}\cdot\tfrac{\ln N}{N} + \tfrac{2}{\ln 2}\cdot\tfrac{1}{N}\bigr)$, and $\ln N/N \to 0$. $\square$

The threshold $N_0$ depends only on $r$ and $\varepsilon$. It does not depend on the read-outs, the label sets or the composition of the sample.

**Corollary 4.5 (The certified two-prime regime).** If $|R| \le 2$ and $|U\cup R| \ge 2^{16}$, then $|I_{U\cup R}(g;k) - I_U(g;k)| \le 0.002$ for all read-outs.

*Proof.* Let $x = N \ge 65536$. The tangent-line estimate (Lemma 2.6 with $u = 65536$, $\rho = x - 65536$) gives $\log_2 x \le 16 + (x - 65536)/(65536\ln 2)$. Substituting,
$$\mathcal{B}(2,x) \le \frac{96}{x} + \frac{6}{65536\ln 2} - \frac{2}{x\ln 2} \le \frac{96}{65536} + \frac{6}{65536 \cdot 0.6931471803} < 0.0016 < 0.002,$$
using $\ln 2 > 0.6931471803$. $\square$

Numerically, $\mathcal{B}(2, 2^{16}) \approx 0.00155$.

### 4.1 Comparison with the data

For $x^2 - 3$ with modulus $12$ and the sample of all primes $p \le X$:

| $X$ | $N$ | $I$ (all) | $I$ (unram.) | gap | $\mathcal{B}(2,N)$ | gap $/\,\mathcal{B}$ |
|---:|---:|---:|---:|---:|---:|---:|
| $10^3$ | 168 | 1.0787 | 0.9974 | +0.0813 | 0.2984 | 0.27 |
| $10^4$ | 1,229 | 1.0157 | 0.9999 | +0.0158 | 0.0548 | 0.29 |
| $10^5$ | 9,592 | 1.0026 | 1.0000 | +0.0026 | 0.0089 | 0.30 |
| $10^6$ | 78,498 | 1.0004 | 1.0000 | +0.0004 | 0.0013 | 0.30 |

The experimental "$+0.002$ bits" corresponds to samples of about $10^4$ primes. The ratio gap$/\mathcal{B}$ settles near $0.3$, which shows that the rate $\log N / N$ is attained and that the true constant is about one third of the proved constant $3$.

The sign of the gap has a simple explanation. The primes $2$ and $3$ occupy the residues $2$ and $3$ modulo $12$, which no unramified prime uses, and they carry the new type "ramified". These new residues determine the type completely. The type entropy therefore rises by about the binary entropy $h(2/N)$, while the conditional entropy given the residue stays $0$, and the information goes up.

---

## 5. Sharpness of the rate

**Theorem 5.1 (Sharpness).** For all natural numbers $r \le n$ there are disjoint samples $U, R \subset \mathbb{N}$ with $|R| = r$ and $|U\cup R| = n$, and a read-out $T$, such that
$$I_{U\cup R}(T;T) - I_U(T;T) \ge \frac{r}{n}\log_2 n.$$

*Proof.* Let $u = n - r$, $U = \{0,\dots,u-1\}$, $R = \{u,\dots,n-1\}$, and define the *extremal type*
$$T(x) = \begin{cases} 0 & x < u, \\ x+1 & x \ge u.\end{cases}$$
All unramified points share one type, and each ramified point has its own type. Since $T$ is a function of itself, $I_S(T;T) = H_S(T)$ for every sample $S$. On $U$ the type is constant, so $\Lambda_U(T) = u\log_2 u$ and $H_U(T) = 0$. On $U \cup R$ the fibres are $U$, of size $u$, and $r$ singletons, so $\Lambda_{U\cup R}(T) = u\log_2 u$ and
$$H_{U\cup R}(T) = \log_2 n - \frac{u}{n}\log_2 u \ge \log_2 n - \frac{u}{n}\log_2 n = \frac{r}{n}\log_2 n,$$
using $\log_2 u \le \log_2 n$. $\square$

Hence the factor $\log_2 N$ in Theorem 4.2 cannot be removed, and the bound is optimal up to the constant in front of the leading term ($3$ versus $1$). Numerically, the extremal gain is $0.0029$ for $(n,r) = (10^4, 2)$, against $\frac{r}{n}\log_2 n = 0.0027$ and $\mathcal{B} = 0.0086$.

---

## 6. Transfer to the Chebotarev fibre product

Let $G$ be a finite group (the Galois group), $T: G \to \mathcal{T}$ a type map (for example, the cycle type of a permutation representation), and $\sigma: G \to \Delta$ the map recording what a residue class sees of a group element (for example, the projection to the cyclotomic quotient attached to a modulus $m$). The **Galois channel** is $I_G(\sigma;T)$, the mutual information of $\sigma$ and $T$ under the uniform distribution on $G$. By Chebotarev's density theorem it is the limiting value of the residue-to-type channel over unramified primes.

**Definition 6.1 (Balanced fibre product).** Let $A$ be a finite set of "residue data" with a map $\chi: A \to \Delta$, and let $U_0 \subseteq A$. The fibre product is
$$\mathcal{F} = \{(a,h) \in U_0 \times G : \chi(a) = \sigma(h)\},$$
with read-outs $(a,h) \mapsto a$ (residue) and $(a,h) \mapsto T(h)$ (type). It is *balanced with multiplicity $K > 0$* if $|\{a \in U_0 : \chi(a) = \sigma(h)\}| = K$ for every $h \in G$.

A balanced fibre product is the idealised model of the unramified primes: every group element occurs as a Frobenius exactly $K$ times, paired with compatible residue data. Its counting channel reproduces the Galois channel exactly:
$$I_{\mathcal{F}}(T\circ \mathrm{pr}_2;\ \mathrm{pr}_1) = I_G(\sigma;T).$$
This holds because, under the uniform law on $\mathcal{F}$, the second coordinate is uniform on $G$. Given the first coordinate $a$, the second is uniform on the fibre $\sigma^{-1}(\chi(a))$, a distribution that depends on $a$ only through $\chi(a)$, so the residue carries exactly the information that $\sigma$ carries about $T$.

**Theorem 6.2 (Galois channel with ramified contamination).** Let $\mathcal{F}$ be a balanced fibre product with multiplicity $K>0$, and let $R \subseteq A \times G$ be any set of at most $r$ extra points disjoint from $\mathcal{F}$. Then, with $N = |\mathcal{F}\cup R|$,
$$\bigl|\, I_{\mathcal{F}\cup R}(T\circ\mathrm{pr}_2;\ \mathrm{pr}_1) - I_G(\sigma;T)\,\bigr| \le \mathcal{B}(r, N).$$

*Proof.* Replace $I_G(\sigma;T)$ by $I_{\mathcal{F}}$ using the identity above, and apply Theorem 4.2 with $U = \mathcal{F}$ in the uniform form of Definition 4.3. $\square$

The extra points may carry arbitrary residue data and arbitrary group labels, so they can model ramified primes with any conventional "type". The theorem turns an exact equidistribution model into an information estimate, and ramification costs at most $O(\log N / N)$.

---

## 7. Algorithms

**Algorithm A (Counting channel via fibre log-sums).** Input: a sample $S$ of size $N$ and read-outs $g,k$.

1. Build hash-count tables $C_g$, $C_k$ and $C_{kg}$ for the label multiplicities.
2. Compute $\Lambda(f) = \sum_{c \in C_f} c\log_2 c$ for $f \in \{g,k,(k,g)\}$.
3. Return $I = \log_2 N - (\Lambda(g) + \Lambda(k) - \Lambda(k,g))/N$.

This takes $O(N)$ expected time and $O(\min(N, |\text{labels}|))$ memory. It is numerically stable because only nonnegative integer counts enter.

**Algorithm B (Ramified-exclusion certificate).** Input: $N$, $r$ and a tolerance $\varepsilon$. Compute $\mathcal{B}(r,N)$. If $\mathcal{B}(r,N) \le \varepsilon$, certify that excluding the $r$ exceptional points changes every counting channel on the sample by at most $\varepsilon$. Otherwise return the smallest $N_0$ with $\mathcal{B}(r,N_0) \le \varepsilon$, found by doubling and then bisection, using that $\mathcal{B}(r,\cdot)$ is eventually decreasing. This takes $O(\log N_0)$ arithmetic operations.

**Algorithm C (Extremal configuration).** For given $(n,r)$, build the extremal type of Theorem 5.1 and evaluate $H_{U\cup R}(T) = \log_2 n - \frac{n-r}{n}\log_2(n-r)$. This is a closed form.

---

## 8. Discussion

**Where the constant 3 comes from.** The proof spends $2B$ on the bracket of Theorem 3.4, treating $E$, $D(g)$, $D(k)$ and $D(k,g)$ as if they were independent, and $B' = r\log_2 N$ on the cross term $r(I_R - I_U)$. In reality the defects are strongly correlated. Introduce the indicator $Z$ of the ramified part and write $\varepsilon = r/N$. Then each defect equals $N\bigl(h(\varepsilon) - I(\cdot\,;Z)\bigr)$, where $I(\cdot\,;Z)$ is the counting mutual information between the read-out in question and $Z$ on the full sample. Hence
$$N I_{U\cup R} - |U| I_U - r I_R = N\bigl[I(g;Z) - I(g;Z\mid k)\bigr],$$
and both terms are bounded by $N h(\varepsilon) \approx r\log_2(N/r)$. This identity removes one of the defects. It is consistent with the empirical ratio of about $1/3$, and it is the starting point for improving the constant.

**Positivity.** In every experiment the observed change was positive. Theorem 4.2 is two-sided, and the configuration in which ramified points form their own residue and type classes yields a positive change, as Theorem 5.1 shows. A one-sided inequality of the form $I_{U\cup R} - I_U \le h(\varepsilon) + \varepsilon(I_R - I_U)$ would explain the sign as well as the magnitude.

**Beyond primes.** Theorem 4.2 applies to any finite labelled dataset. Removing $r$ outliers from $N$ records changes any plug-in mutual-information estimate by at most $\mathcal{B}(r,N)$, whatever the outliers are, even if they were chosen adversarially. Theorem 5.1 shows that this worst case is genuinely of order $\frac{r}{N}\log N$.

---

## 9. Future work

1. **Sharp constant.** Prove that $\sup |I_{U\cup R} - I_U| = \frac{r}{N}\log_2 N\,(1+o(1))$ for fixed $r$ as $N \to \infty$, using the identity of Section 8 together with the log-sum (Gibbs) inequality for disjoint unions.
2. **Full Chebotarev spectrum.** For any Galois extension $K/\mathbb{Q}$ and modulus $m$, show that the empirical channel over all primes $p \le X$, ramified ones included, converges to $I_G(\sigma;T)$ with error $O_K(\log\log X/\log X)$ from ramification plus the Chebotarev error term. Theorem 6.2 reduces this to an effective equidistribution input.
3. **Capacity-defect inequality.** Prove $I_{U\cup R} - I_U \le h(r/N) + \frac{r}{N}(I_R - I_U)$, with equality exactly when the ramified types and residues are disjoint from the unramified ones.

---

## 10. Conclusion

A small set of exceptional points can move an empirical mutual information on $N$ points only by $O\bigl(\frac{r}{N}\log N\bigr)$ bits. The explicit constant is $\frac{r}{N}(3\log_2 N + 2/\ln 2)$, and the $\log N$ factor is unavoidable. For the residue-to-type channel of $x^2 - 3$, the two ramified primes $\{2,3\}$ contribute the observed $+0.002$ bits, well inside the bound. Excluding ramified primes from type-channel experiments is therefore fully justified.
