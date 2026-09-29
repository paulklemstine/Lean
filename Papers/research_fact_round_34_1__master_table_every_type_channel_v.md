# The Master Table of Splitting-Type Channels for Cyclic and Dihedral Galois Groups of Degree 3 to 6, and the General Laws Behind It

**Aristotle** (Harmonic)

*2026-09-29*

---

## Abstract

For a Galois extension $K/\mathbb{Q}$ with group $G$, the Chebotarev density theorem makes the Frobenius class of a random prime a uniformly distributed element of $G$. The *splitting type* of the prime is then a random variable, and we can measure its Shannon entropy and its mutual information with various coarse read-outs. We give closed forms for all six measured channels, namely cyclic type, cyclic root count, the semiprime pair channel, dihedral type, the dihedral non-abelian residue, and the rotation dial, for the cyclic groups $C_n$ and the dihedral groups $D_n$ with $n \in \{3,4,5,6\}$. We then show that every cyclic root-count and dihedral entry is a special case of a law valid for all degrees. (i) The cyclic root-count entropy equals the *pinning entropy* $\pi(n) = h(1/n)$ for every $n$, and it equals the full type entropy **if and only if $n$ is prime**. (ii) The dihedral type entropy is $1 + \pi(n)/2$ for odd $n$, and has an explicit closed form for even $n$. (iii) The rotation fibre of $D_n$ is precisely the cyclic root-count channel of degree $n$. (iv) For $n \ge 3$, the rotation character carries **exactly one bit** about the dihedral type **if and only if $n$ is odd**. The proof uses a chain rule for counting entropy and the symmetry of mutual information. (v) $\pi(n) \to 0$, so along odd degrees the abelian share of dihedral type information tends to $1$, although the non-abelian residue is strictly positive at every finite degree. The general laws independently reproduce values previously obtained by enumeration. We close with open problems, including a conjectured even-degree limit $h(1/4) - 1/2$ for the dial.

---

## 1. Introduction

Let $f \in \mathbb{Z}[x]$ be monic and irreducible of degree $n$, with splitting field $K$ and Galois group $G$ acting on the $n$ roots. For a prime $p$ unramified in $K$, the factorisation pattern of $f \bmod p$ is the cycle type of the Frobenius class $\mathrm{Frob}_p \subset G$ acting on the roots. In particular, the number of roots of $f$ in $\mathbb{F}_p$ equals the number of roots fixed by $\mathrm{Frob}_p$. By the Chebotarev density theorem, the natural density of primes whose Frobenius lies in a conjugacy class $C$ is $|C|/|G|$. Every statistical question about splitting types of random primes therefore reduces to a question about a **uniformly random element of $G$**.

This paper adopts an information-theoretic viewpoint. A *read-out* is a function $g : G \to B$, such as the splitting type, the number of roots, or a character. We measure how many bits it carries by the Shannon entropy of its push-forward under the uniform measure. Coarse read-outs are compared with fine ones through conditional entropy and mutual information.

We treat the two basic families of Galois groups:

- **cyclic fields** of degree $n$ (group $C_n$, acting regularly on $n$ roots);
- **dihedral radical fields**, typified by $x^n - a$ (group $D_n$, acting on the $n$ roots as on the vertices of a regular $n$-gon).

The first contribution is a *master table* with every channel value in degrees $3$ to $6$ in closed form (Section 4). The second and main contribution is that the table is *explained*. Each cyclic root-count and dihedral column is an instance of a law valid for all $n$ (Sections 5–7), and each law is proved by structural arguments (fibre-shape evaluation, a chain rule, symmetry of mutual information), not by enumeration. Section 8 shows what the laws say as $n \to \infty$.

---

## 2. Counting entropy

All sources in this paper are uniform on a finite set. We therefore use the following elementary framework throughout.

**Definition 2.1 (Counting entropy).** Let $s$ be a finite nonempty set and $g : s \to B$ a function. The *entropy* of $g$ on $s$ is
$$H_s(g) = \log_2|s| - \frac{1}{|s|}\sum_{a\in s}\log_2\bigl|\{x\in s : g(x) = g(a)\}\bigr|.$$
Grouping the sum by fibres shows that this equals $-\sum_b p_b\log_2 p_b$ with $p_b = |g^{-1}(b)|/|s|$, the Shannon entropy of $g(X)$ for $X$ uniform on $s$.

**Definition 2.2 (Conditional entropy, mutual information).** For $g : s \to B$ and $k : s\to C$,
$$H_s(g\mid k) = \sum_{c\in k(s)}\frac{|k^{-1}(c)|}{|s|}\,H_{k^{-1}(c)}(g),\qquad I_s(g;k) = H_s(g) - H_s(g\mid k).$$

**Definition 2.3 (Pinning entropy).** For an integer $N\ge 1$,
$$\pi(N) = \log_2 N - \frac{N-1}{N}\log_2(N-1),$$
with $0\log_2 0 = 0$. Equivalently $\pi(N) = h(1/N)$, where $h(t) = -t\log_2 t - (1-t)\log_2(1-t)$ is the binary entropy. Thus $\pi(1) = 0$, $\pi(2) = 1$.

With $L = \log_2 3$ and $L_5 = \log_2 5$ one computes directly
$$\pi(3) = L - \tfrac23,\quad \pi(4) = 2 - \tfrac34 L,\quad \pi(5) = L_5 - \tfrac85,\quad \pi(6) = 1 + L - \tfrac56 L_5.$$

### 2.1 Two evaluation principles

**Lemma 2.4 (Uniform fibres).** If every fibre of $g$ on $s$ has exactly $c$ elements, then $H_s(g) = \log_2|s| - \log_2 c$. In particular a read-out constant on $s$ has entropy $0$.

*Proof.* Every summand in Definition 2.1 equals $\log_2 c$. $\square$

**Lemma 2.5 (Pinned read-out).** Suppose $a_0\in s$, $g$ separates $a_0$ from every other point ($g(x) = g(a_0)\Rightarrow x = a_0$), and $g$ is constant on $s\setminus\{a_0\}$. Then $H_s(g) = \pi(|s|)$.

*Proof.* The fibres are $\{a_0\}$ and $s\setminus\{a_0\}$, so the sum in Definition 2.1 is $0 + (|s|-1)\log_2(|s|-1)$. $\square$

### 2.2 Chain rule and symmetry

**Theorem 2.6 (Chain rule for a determined dial).** Let $g : s\to B$ and $\varphi : B\to C$. Then
$$H_s(g) = H_s(\varphi\circ g) + H_s(g\mid \varphi\circ g).$$
Consequently $I_s(g;\varphi\circ g) = H_s(\varphi\circ g)$: *a dial determined by the read-out carries exactly its own entropy.*

*Proof sketch.* Put $k = \varphi\circ g$. Inside a $k$-fibre $F$, the $g$-fibre of a point $a$ is its global $g$-fibre, because $g(x) = g(a)$ forces $k(x) = k(a)$. Expanding $\frac{|F|}{|s|}H_F(g)$ with Definition 2.1 gives $\frac{|F|}{|s|}\log_2|F| - \frac1{|s|}\sum_{a\in F}\log_2|g^{-1}(g(a))|$. Summing over $F$, the first terms reassemble to $\log_2|s| - H_s(k)$ and the second to $\log_2|s| - H_s(g)$. $\square$

**Lemma 2.7 (Fibrewise congruence).** If on every fibre of $k$ the read-outs $g$ and $g'$ induce the same partition, then $H_s(g\mid k) = H_s(g'\mid k)$.

**Theorem 2.8 (Symmetry of mutual information).** $I_s(g;k) = I_s(k;g)$. Hence $I_s(g;k)\le H_s(k)$ (the *dial capacity bound*).

*Proof sketch.* Apply Theorem 2.6 to the pair map $P = (g,k)$ with the two projections:
$H_s(P) = H_s(g) + H_s(P\mid g) = H_s(k) + H_s(P\mid k)$.
By Lemma 2.7, $H_s(P\mid g) = H_s(k\mid g)$ and $H_s(P\mid k) = H_s(g\mid k)$. Rearranging gives $H_s(g) - H_s(g\mid k) = H_s(k) - H_s(k\mid g)$. The bound follows since conditional entropy is nonnegative. $\square$

**Lemma 2.9 (Strict positivity).** If $g$ takes two different values on $s$, then $H_s(g) > 0$. If some fibre of $k$ contains two points with different $g$-values, then $H_s(g\mid k) > 0$.

*Proof.* In the first case every fibre is a proper subset of $s$, so each summand is $< \log_2|s|$. The second case follows by applying the first case on that fibre. $\square$

---

## 3. The channels

### 3.1 Cyclic channel

For a cyclic field of degree $n$, the Frobenius of a random prime is a uniform $a\in\mathbb{Z}/n$. Its splitting type is its order
$$T(a) = \frac{n}{\gcd(a,n)},$$
the common residue degree of the primes above $p$. Since $C_n$ acts regularly on the roots of a defining polynomial, a non-identity element fixes no root. The **root count** is therefore
$$R(a) = \begin{cases} n & T(a) = 1,\\ 0 & \text{otherwise.}\end{cases}$$
The cyclic **type entropy** is $H^{C}(n) = H_{\mathbb{Z}/n}(T)$ and the **root-count entropy** is $R^{C}(n) = H_{\mathbb{Z}/n}(R)$.

**Semiprime pair channel.** Let $p, q$ be two primes with independent uniform Frobenius elements $a, b\in\mathbb{Z}/n$. The Frobenius attached to the product class is $a+b$. The *pair channel* is
$$I_{\mathrm{pair}}(n) = I\bigl((T(a),T(b));\,T(a+b)\bigr),$$
the information the two individual splitting types carry about the splitting type of the product class, with $(a,b)$ uniform on $(\mathbb{Z}/n)^2$.

### 3.2 Dihedral channel

Let $D_n = \{r_i, s_i : i\in\mathbb{Z}/n\}$ act on vertices $v\in\mathbb{Z}/n$ by $r_i(v) = v+i$ and $s_i(v) = i - v$. For $x^n - a$ this is the action of the Galois group on the $n$ roots, and the splitting type we track is
$$T(g) = \#\{v : g(v) = v\},$$
the number of roots of $x^n - a$ modulo $p$. The **rotation dial** (rotation character) is the homomorphism $\rho : D_n\to\mathbb{Z}/2$, $\rho(r_i) = 0$, $\rho(s_i) = 1$. It is the abelian (quadratic) character through which $D_n$ factors to $C_2$. For $x^3 - 2$, for instance, it records $p \bmod 3$. We write
$$H^{D}(n) = H_{D_n}(T),\qquad \mathrm{Res}(n) = H_{D_n}(T\mid\rho),\qquad \mathrm{Dial}(n) = I_{D_n}(T;\rho).$$

---

## 4. The master table

**Theorem 4.1 (Master table).** With $L = \log_2 3$ and $L_5 = \log_2 5$:

| $n$ | $H^C(n)$ | $R^C(n)$ | $I_{\mathrm{pair}}(n)$ | $H^D(n)$ | $\mathrm{Res}(n)$ | $\mathrm{Dial}(n)$ |
|---|---|---|---|---|---|---|
| 3 | $L - \frac23$ | $L - \frac23$ | $L - \frac{10}{9}$ | $\frac23 + \frac L2$ | $\frac L2 - \frac13$ | $1$ |
| 4 | $\frac32$ | $2 - \frac{3L}4$ | $\frac54$ | $\frac{11}4 - \frac{5L_5}8$ | $\frac32 - \frac{3L}8$ | $\frac54 + \frac{3L}8 - \frac{5L_5}8$ |
| 5 | $L_5 - \frac85$ | $L_5 - \frac85$ | $L_5 + \frac{12L}{25} - \frac{72}{25}$ | $\frac15 + \frac{L_5}2$ | $\frac{L_5}2 - \frac45$ | $1$ |
| 6 | $\frac13 + L$ | $1 + L - \frac{5L_5}6$ | $L - \frac19$ | $\frac{3L}4$ | $1 + \frac L2 - \frac{5L_5}{12}$ | $\frac L4 + \frac{5L_5}{12} - 1$ |

Numerically (bits):

| $n$ | $H^C$ | $R^C$ | $I_{\mathrm{pair}}$ | $H^D$ | Res | Dial |
|---|---|---|---|---|---|---|
| 3 | 0.9183 | 0.9183 | 0.4739 | 1.4591 | 0.4591 | 1.0000 |
| 4 | 1.5000 | 0.8113 | 1.2500 | 1.2988 | 0.9056 | 0.3932 |
| 5 | 0.7219 | 0.7219 | 0.2027 | 1.3610 | 0.3610 | 1.0000 |
| 6 | 1.9183 | 0.6500 | 1.4739 | 1.1887 | 0.8250 | 0.3637 |

*Proof.* Column 1 follows from the order distribution of $\mathbb{Z}/n$. For example, for $n = 6$ the orders $1, 2, 3, 6$ occur $1, 1, 2, 2$ times, giving $\log_2 6 - \frac{4}{6} = \frac13 + L$. Column 3 is a finite evaluation over the $n^2$ pairs $(a,b)$. Columns 2, 4, 5 and 6 are specialisations of Theorems 5.1, 6.2, 6.4 and 7.3 below, combined with the values of $\pi(3),\dots,\pi(6)$ from Section 2. For the even rows of column 6 one subtracts: $\mathrm{Dial}(n) = H^D(n) - \mathrm{Res}(n)$. For instance
$$\mathrm{Dial}(4) = \Bigl(\tfrac{11}{4} - \tfrac{5L_5}{8}\Bigr) - \Bigl(\tfrac32 - \tfrac{3L}8\Bigr) = \tfrac54 + \tfrac{3L}8 - \tfrac{5L_5}8. \qquad\square$$

The remaining sections show why the table looks the way it does.

---

## 5. Cyclic laws

**Theorem 5.1 (Root-count law).** For every $n\ge 1$, $R^C(n) = \pi(n)$.

*Proof.* The type is $1$ only at $a = 0$: $n/\gcd(a,n) = 1$ forces $\gcd(a,n) = n$, so $n\mid a$ and $a = 0$ for $0 \le a < n$. So $R$ takes the value $n$ at $a = 0$ and $0$ elsewhere. It pins $0$ and is constant on the rest, and Lemma 2.5 gives $\pi(n)$. $\square$

**Proposition 5.2 (Totient form of the type entropy).** For $n\ge 1$,
$$H^C(n) = \log_2 n - \frac1n\sum_{d\mid n}\varphi(d)\log_2\varphi(d).$$

*Proof.* The image of $T$ is the set of divisors of $n$, and the fibre over $d$ has exactly $\varphi(d)$ elements (the elements of order $d$ in $\mathbb{Z}/n$). Group the sum in Definition 2.1 by fibres. $\square$

**Theorem 5.3 (Prime losslessness).** For $n\ge 2$, $R^C(n) = H^C(n)$ if and only if $n$ is prime. If $n$ is composite, $R^C(n) < H^C(n)$.

*Proof sketch.* If $n = p$ is prime, every type lies in $\{1,p\}$, and $R$ is an injective recoding of $T$ on this image ($1\mapsto p$, $p\mapsto 0$). Injective recodings preserve entropy.

Let $n$ be composite. By Theorem 5.1 and Proposition 5.2 it suffices to show
$$\sum_{d\mid n,\ d>1}\varphi(d)\log_2\varphi(d) < (n-1)\log_2(n-1).$$
Since $\sum_{d\mid n}\varphi(d) = n$, the weights $\varphi(d)$ for $d>1$ sum to $n-1$. Each satisfies $\varphi(d)\le d-1\le n-1$, so each term $\varphi(d)\log_2\varphi(d)\le\varphi(d)\log_2(n-1)$. For $d = q$, the least prime factor of $n$, we have $q < n$ and $\varphi(q) + 1 = q < n$. The inequality is therefore strict at that term. Summing gives the claim. $\square$

*Interpretation.* In a cyclic field of prime degree, "how many roots does the polynomial have mod $p$?" is as informative as the full factorisation pattern. In composite degree, primes with different residue degrees $1 < f < n$ and $f' = n$ all show zero roots, and the information separating them is lost.

---

## 6. Dihedral laws

### 6.1 Fixed points

**Lemma 6.1.** In $D_n$ ($n\ge 3$):

1. $T(r_0) = n$ and $T(r_i) = 0$ for $i\ne 0$.
2. If $n$ is odd, $T(s_i) = 1$ for all $i$.
3. If $n$ is even, $T(s_i) = 2$ if $i$ is even and $T(s_i) = 0$ if $i$ is odd.

*Proof.* (1) is clear. For (2)–(3), $s_i(v) = v$ means $2v = i$ in $\mathbb{Z}/n$. If $n$ is odd, $2$ is a unit and there is exactly one solution. If $n$ is even there are two solutions when $i$ is even and none when $i$ is odd. $\square$

Counting over the $2n$ elements gives the **type distributions**:
$$n \text{ odd}:\ \{0: n-1,\ 1: n,\ n: 1\};\qquad n\text{ even},\ n\ge 4:\ \{0: \tfrac{3n}2-1,\ 2: \tfrac n2,\ n: 1\}.$$

### 6.2 Type entropy

**Theorem 6.2 (Dihedral type law).**
(a) For odd $n\ge 3$: $H^D(n) = 1 + \tfrac12\pi(n)$.
(b) For $n = 2m$, $m\ge 2$:
$$H^D(n) = \log_2(4m) - \frac{(3m-1)\log_2(3m-1) + m\log_2 m}{4m}.$$

*Proof sketch.* Insert the type distributions into Definition 2.1. For (a),
$$H^D(n) = \log_2(2n) - \frac{(n-1)\log_2(n-1) + n\log_2 n}{2n} = 1 + \frac12\Bigl(\log_2 n - \frac{n-1}n\log_2(n-1)\Bigr).$$
For (b), $|D_n| = 4m$ and the fibres have sizes $3m-1$, $m$ and $1$. $\square$

*Rows.* $H^D(3) = 1 + \frac12(L - \frac23) = \frac23 + \frac L2$ and $H^D(5) = \frac15 + \frac{L_5}2$. For $m = 2$: $3 - \frac{5L_5 + 2}{8} = \frac{11}4 - \frac{5L_5}8$. For $m = 3$: $\log_2 12 - \frac{24 + 3L}{12} = \frac{3L}4$.

### 6.3 Fibres of the dial and the bridge

The dial $\rho$ is a fair coin: each fibre has $n$ elements, so by Lemma 2.4 $H_{D_n}(\rho) = \log_2(2n) - \log_2 n = 1$. Its two fibres are the rotations $\mathcal{R} = \rho^{-1}(0)$ and the reflections $\mathcal{S} = \rho^{-1}(1)$, and
$$\mathrm{Res}(n) = \tfrac12 H_{\mathcal{R}}(T) + \tfrac12 H_{\mathcal{S}}(T).$$

**Theorem 6.3 (Bridge).** For every $n\ge 1$, $H_{\mathcal{R}}(T) = \pi(n) = R^C(n)$. *The rotation fibre of the dihedral type channel is the cyclic root-count channel of the same degree.*

*Proof.* On $\mathcal{R}$, $T$ pins $r_0$ (value $n$) and is constant ($0$) elsewhere. Apply Lemma 2.5, then Theorem 5.1. $\square$

For the reflection fibre, $H_{\mathcal{S}}(T) = 0$ for odd $n$ ($T\equiv 1$, Lemma 2.4). For even $n$, $H_{\mathcal{S}}(T) = 1$, since $T\in\{0,2\}$ with $n/2$ elements each.

**Theorem 6.4 (Residue law).** For all $n \ge 3$,
$$\mathrm{Res}(n) = \begin{cases}\tfrac12\pi(n) & n\text{ odd},\\[2pt] \tfrac12\pi(n) + \tfrac12 & n\text{ even}.\end{cases}$$

*Proof.* Combine Theorem 6.3 with the reflection-fibre computation. $\square$

Rows: $\mathrm{Res}(3) = \frac L2 - \frac13$, $\mathrm{Res}(5) = \frac{L_5}2 - \frac45$, $\mathrm{Res}(4) = 1 - \frac{3L}8 + \frac12 = \frac32 - \frac{3L}8$, $\mathrm{Res}(6) = \frac12 + \frac L2 - \frac{5L_5}{12} + \frac12 = 1 + \frac L2 - \frac{5L_5}{12}$.

---

## 7. The parity law of the abelian dial

**Theorem 7.1 (Odd one-bit law).** For odd $n\ge 3$, $\mathrm{Dial}(n) = 1$.

*First proof.* By Theorems 6.2(a) and 6.4, $\mathrm{Dial}(n) = (1 + \frac12\pi(n)) - \frac12\pi(n) = 1$.

*Second (conceptual) proof.* For odd $n\ge 3$, Lemma 6.1 shows $\rho(g) = 1 \iff T(g) = 1$, because no rotation fixes exactly one vertex ($0 \ne 1 \ne n$). So $\rho = \varphi\circ T$ with $\varphi(t) = [t = 1]$. By Theorem 2.6, $I(T;\rho) = H(\rho) = 1$. $\square$

**Proposition 7.2 (Even strict inequality).** For even $n\ge 4$, $\mathrm{Dial}(n) < 1$.

*Proof.* By Theorem 2.8, $I(T;\rho) = I(\rho;T) = H(\rho) - H(\rho\mid T) = 1 - H(\rho\mid T)$. The rotation $r_1$ and the edge reflection $s_1$ both have $T = 0$ but $\rho(r_1) = 0 \ne 1 = \rho(s_1)$. By Lemma 2.9, $H(\rho\mid T) > 0$. $\square$

**Theorem 7.3 (Parity law).** For $n\ge 3$, the rotation character carries exactly one bit about the dihedral splitting type if and only if $n$ is odd:
$$I_{D_n}(T;\rho) = 1 \iff n\text{ odd}.$$

*Proof.* Theorem 7.1 and Proposition 7.2. $\square$

**Remark 7.4 (The boundary $n = 2$).** At $n = 2$ the identity and the reflections have the same fixed-point count, so the dihedral laws genuinely require $n\ge 3$.

---

## 8. Verdicts and the large-degree limit

**Corollary 8.1 (Table verdicts).**

1. *Root count:* $R^C = H^C$ at $n = 3,5$ and $R^C < H^C$ at $n = 4,6$.
2. *Binary cap:* $I_{\mathrm{pair}}(3) < 1$ and $I_{\mathrm{pair}}(5) < 1$, while $I_{\mathrm{pair}}(4) > 1$ and $I_{\mathrm{pair}}(6) > 1$.
3. *Abelian dial:* $\mathrm{Dial} = 1$ at $n = 3,5$ and $\mathrm{Dial} < 1$ at $n = 4,6$. The residue is strictly positive at all four degrees.
4. *Dihedral above cyclic count:* $R^C(n) < H^D(n)$ for $n = 3,4,5,6$.

*Proof.* (1) is Theorem 5.3 and (3) is Theorem 7.3 with Theorem 6.4. The remaining inequalities follow from the closed forms and the elementary bounds $1.58 < L < 1.59$ and $2.32 < L_5 < 2.33$. $\square$

**Theorem 8.2 (Bounds on pinning entropy).** For $n\ge 2$,
$$0 < \pi(n) \le \frac{1}{\ln 2}\left(\frac{1}{n-1} + \frac{\ln(n-1)}{n}\right).$$

*Proof sketch.* Write $\pi(n)\ln 2 = (\ln n - \ln(n-1)) + \frac1n\ln(n-1)$. The first bracket is at most $\frac{1}{n-1}$ by $\ln x\le x-1$ applied to $x = n/(n-1)$. Positivity follows from $\ln(n-1) < \ln n$. $\square$

**Corollary 8.3.** $\pi(n)\to 0$. Hence $R^C(n)\to 0$ and, for odd $n$, $\mathrm{Res}(n)\to 0$.

**Theorem 8.4 (Abelian saturation).** Along odd degrees,
$$\frac{\mathrm{Dial}(n)}{H^D(n)} = \frac{1}{1 + \frac12\pi(n)} \xrightarrow[n\to\infty,\ n\text{ odd}]{} 1,$$
while $\mathrm{Res}(n) = \tfrac12\pi(n) > 0$ for every odd $n\ge 3$.

So the non-abelian part of the dihedral splitting type becomes asymptotically invisible, but no finite odd degree is ever fully described by its abelian quotient. Sample values of the abelian share: $0.685$ ($n=3$), $0.735$ ($n=5$), $0.961$ ($n = 101$), $0.99926$ ($n=10001$).

---

## 9. Independent cross-check

Two of the table's inputs had earlier been obtained by direct enumeration over the group: the cyclic root-count entropies at $n = 4, 6$, and the $D_6$ type entropy $\frac34 L$ together with its residue $1 + \frac L2 - \frac{5L_5}{12}$. The general laws reproduce all of them. Theorem 5.1 gives $\pi(4) = 2 - \frac34 L$ and $\pi(6) = 1 + L - \frac56L_5$, Theorem 6.2(b) at $m = 3$ gives $\frac34L$, and Theorem 6.4 gives $\frac12\pi(6) + \frac12 = 1 + \frac L2 - \frac{5L_5}{12}$. The two independent routes agree.

---

## 10. Algorithms

All channel values can be recomputed by a direct enumeration.

**Algorithm A (Channel entropy by fibre counting).**
*Input:* a finite group $G$ given as a list, a read-out $g$, optionally a dial $k$.
1. Tabulate the multiset of values $g(x)$, $x\in G$, and compute $H = -\sum_b \frac{c_b}{|G|}\log_2\frac{c_b}{|G|}$.
2. For each dial value $c$, restrict to $k^{-1}(c)$ and compute $H_{k^{-1}(c)}(g)$ the same way. Weight by $|k^{-1}(c)|/|G|$ and sum to obtain $H(g\mid k)$.
3. Return $H$, $H(g\mid k)$ and $I = H - H(g\mid k)$.

The cost is $O(|G|\cdot c_g)$, where $c_g$ is the cost of one read-out evaluation. For $D_n$ acting on $n$ vertices, a naive fixed-point count gives $O(n^2)$ overall, which Lemma 6.1 reduces to $O(n)$.

**Algorithm B (Closed-form evaluation).** Evaluate $\pi(n)$, then apply Theorems 5.1, 6.2, 6.4 and 7.3. This costs $O(1)$ arithmetic operations per degree, plus $O(\sqrt n)$ divisor enumeration for Proposition 5.2.

Running A against B for $3\le n\le 30$ confirms every law to floating-point precision. For $n\le 20$ it also confirms that the loss $H^C(n) - R^C(n)$ vanishes exactly at the primes.

---

## 11. Discussion

**What "complete" means.** Every entry of the degree-$3$-to-$6$ cyclic and dihedral table is a closed form. Every cyclic root-count and dihedral column is an instance of a law valid for all degrees. The laws recover the previously enumerated values. This is the precise sense in which the framework is complete. It does **not** cover the other transitive Galois groups of degrees $4$ to $6$, such as $V_4$, $A_4$, $S_4$, $F_{20}$, $A_5$, $S_5$, or the many groups of degree $6$.

**Structural lessons.** Three simple mechanisms generate the whole table:

- *pinning* (a read-out that only detects the identity), which produces $\pi(n)$;
- *fibre decomposition along an abelian quotient*, which splits dihedral information into a one-bit dial plus a residue;
- *determination* (the dial is a function of the type), which forces the dial to carry its full entropy via the chain rule.

The parity phenomenon (one bit exactly in odd degree) has a transparent geometric source. In an odd polygon every reflection has a unique axis vertex, so "exactly one root" identifies reflections. In an even polygon, edge reflections impersonate non-trivial rotations.

**Arithmetic reading.** For $x^n - a$ with $n$ odd, the rotation dial is a quadratic character of $p$ (for instance $p\bmod 3$ when $n = 3$). Theorem 7.1 then says: *a prime $p$ is a "reflection prime" exactly when $x^n - a$ has exactly one root modulo $p$.* Knowing the root count determines the quadratic character, and the character carries one full bit. Classically, for $x^3 - 2$, a prime $p\equiv 2\pmod 3$ always gives exactly one root, while $p\equiv 1\pmod 3$ gives $0$ or $3$.

---

## 12. Future work

1. **Even-degree dial limit.** For $n = 2m$, is $\mathrm{Dial}(n)$ strictly decreasing in $m$ with limit $h(1/4) - \frac12\approx 0.3113$? The type distribution tends to $\{0:\frac34,\ 2:\frac14\}$ and the reflection fibre always carries one bit, which suggests this limit. Numerically $\mathrm{Dial}(8) = 0.3499$, $\mathrm{Dial}(100) = 0.3142$ and $\mathrm{Dial}(400) = 0.3120$. By Theorems 6.2(b) and 6.4 the question reduces to a limit of explicit elementary functions.
2. **Full abelianisation of $D_{2m}$.** The map $D_{2m}\to C_2\times C_2$ also separates reflections by axis parity. One expects $I = H^D(2m) - \pi(m)/4$, since fixing the class leaves only the pinning of the identity among the $m$ even rotations.
3. **Other Galois groups.** Extend the table to $A_4$, $S_4$, $F_{20}$, $A_5$, $S_5$ and the transitive groups of degree $6$. The chain rule, pinning and fibre lemmas apply verbatim to any finite permutation group.
4. **A general theory of the pair channel.** Find closed forms of $I_{\mathrm{pair}}(n)$ for all $n$, and characterise the binary-cap phenomenon $I_{\mathrm{pair}}(n) \lessgtr 1$ by the parity or factorisation of $n$.

---

## 13. Conclusion

The splitting type of a random prime is a small, exactly computable information source. For cyclic and dihedral groups it is governed by one function, the pinning entropy $\pi(n) = h(1/n)$. The root count of a cyclic field is $\pi(n)$ and is lossless exactly in prime degree. The dihedral type is a fair rotation coin plus half a pinning question. The abelian dial captures exactly one bit precisely in odd degree. As the degree grows, the non-abelian remainder fades but never disappears. The four rows of the master table are the cases $n = 3,4,5,6$ of these laws.
