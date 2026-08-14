# No Polynomial-Time Congruence Battery Can Pin a Prime Factor

**A class-wide no-pinning theorem for modulus-$L$ observables, with sharp pinned sets, sealing lower bounds, and an unconditional no-factoring corollary**

*Aristotle*

---

## Abstract

We study the information about the prime factorisation of a semiprime $N = pq$ that is carried by *congruence data*: any family of predicates whose value depends on $N$ only through its residue modulo a fixed integer $L$. This class — which we call the **observables of modulus $L$** — contains every measurement of the standard $\operatorname{poly}(\log N)$ battery: the residues $N \bmod m$, the Jacobi symbols $(a \mid N)$, the greatest common divisors $\gcd(N, c)$ for small parameters, and (via a structural lemma) every polynomial gcd $\gcd(f(N), N)$.

Our main result is the **Class-Wide No-Pinning Lemma**: for every even modulus $L$, every target $N_0$ coprime to $L$ and every candidate prime $p$ coprime to $L$, there exist infinitely many primes $q$ such that *every* observable of modulus $L$ — in every value type — assigns the same value to $pq$ as to $N_0$. Consequently a modulus-$L$ battery never eliminates the candidate $p$. We complement this with three sharp companion results.

1. **Exact pinned set.** A prime candidate $p$ is eliminated by the modulus-$L$ data if and only if $p \mid L$. For the concrete level-$B$ battery, with $L_B = 4\operatorname{lcm}(1,\dots,B)$, the pinned primes are exactly $2$ together with the primes $\le B$; there are at most $\min(B, \log_2 L_B)$ of them.
2. **Sealing bound.** A modulus-$L$ battery excluding $k$ prime candidates forces $2^k \le L$; a battery that excludes every prime candidate below $X$ except the two true factors of a semiprime forces $L \ge 2^{\pi(X)-2}$. Since a factoring search requires $X \approx \sqrt{N}$, the modulus of a pinning battery has $\exp(\Omega(\sqrt{N}/\log N))$ magnitude — never $\operatorname{poly}(\log N)$.
3. **No factoring from congruence data.** For any even $L$ of any size, any observable $f$ of modulus $L$, and any decoding map $A$ (not assumed computable), the composite $A \circ f$ fails to return a nontrivial divisor for some semiprime coprime to $L$.

We isolate the group-theoretic mechanism responsible: the multiplication map of a group is a perfectly uniform hash, so an observed product class admits exactly $|G|$ ordered factorisations and constrains the factor class not at all. Dirichlet's theorem on primes in arithmetic progressions lifts this class-level uniformity to primes. We also prove a **barrier-1 lemma**: $\gcd(f(N), N) = \gcd(f(0), N)$ for every integer polynomial $f$, so polynomial gcd probes are functions of $N$ alone and add no pinning power. Explicit numerical instances at battery level $B = 12$ (modulus $110880$) accompany every result.

**Keywords:** integer factorisation, Dirichlet's theorem on arithmetic progressions, Jacobi symbol, barrier theorems, residue observables, Euler totient, uniform hashing.

---

## 1. Introduction

### 1.1 The question

Let $N = pq$ be a semiprime with unknown prime factors. An attacker restricted to $\operatorname{poly}(\log N)$ time can nevertheless compute a great deal about $N$: its residues modulo small numbers, its Jacobi symbols against small bases, its greatest common divisors with small constants, its gcd against the value of any fixed integer polynomial evaluated at $N$. These quantities are individually arithmetically meaningful — the Jacobi symbol, in particular, is the substance of the Solovay–Strassen primality test and is computable without any factorisation of its lower argument.

It is natural to hope that a sufficiently large and clever bundle of such cheap measurements might narrow down the possible factors of $N$: might, in the terminology we adopt here, **pin** a factor. The purpose of this paper is to prove, unconditionally and for the whole class at once, that it cannot.

### 1.2 The reframing

The technical device that makes the class tractable is a single observation: every one of the measurements above depends on $N$ only through $N \bmod L$ for one fixed integer $L$. Set

$$L_B \;=\; 4 \cdot \operatorname{lcm}(1, 2, \dots, B).$$

Then $N \bmod m$ depends only on $N \bmod L_B$ whenever $m \le B$ (since $m \mid L_B$); $\gcd(N, c)$ likewise; and $(a \mid N)$ likewise, since the Jacobi symbol is periodic in its lower argument with period dividing $4a$, and $4a \mid L_B$ for $a \le B$. Rather than reason about these channels one at a time — and rather than leave open the possibility that some as-yet-uninvented cheap predicate escapes the analysis — we abstract to the class of *all* functions with this dependence, and prove the theorem for the class.

### 1.3 Contributions

- **Definition and universality of modulus-$L$ observables** (§2), including the fact that for even $L$ an observable of modulus $L$ is exactly a function factoring through $N \mapsto N \bmod L$ on odd inputs. Hence the modulus, and not the ingenuity of the predicate, is the sole limiting resource.
- **The compensating-partner lemma and the Class-Wide No-Pinning Lemma** (§3).
- **The exact pinned set** (§4), both in the abstract ($p$ pinned iff $p \mid L$) and for the level-$B$ battery ($p$ pinned iff $p = 2$ or $p \le B$).
- **The sealing bound** (§5): the exponential lower bound on the modulus of any battery that prunes a full search range.
- **The unconditional no-factoring theorem** (§6), valid for arbitrary $L$ and arbitrary decoding.
- **The uniformity mechanism** (§7): the perfectly uniform hash property of group multiplication, and the involution structure of the compensation map.
- **Barrier 1 for polynomial gcds** (§8): $\gcd(f(N), N) = \gcd(f(0), N)$.
- **Explicit numerical instances** (§9) and **algorithms** (§10).

### 1.4 Scope and honesty about what is not proved

This paper establishes the *unconditional half* of a two-part programme. The half proved here is:

$$\text{data is a function of } N \bmod L \;\Longrightarrow\; \text{no pinning} \;\Longrightarrow\; \text{no factoring}.$$

The converse half — that any quantity which *does* reveal a factor must require reading information sealed behind computation of size polynomial in $N$ rather than $\log N$ — remains open and is discussed in §12. Our results should therefore be read as a barrier theorem: they exclude a large, natural, and repeatedly attempted family of attacks, not factoring in general.

---

## 2. Observables of a fixed modulus

Throughout, $L \ge 1$ is a fixed integer, and $m \equiv n \pmod L$ is written $m \equiv n \ [L]$.

**Definition 2.1 (Observable of modulus $L$).** Let $\beta$ be any set. A map $f : \mathbb{N} \to \beta$ is an *observable of modulus $L$* if

$$m \text{ odd}, \; n \text{ odd}, \; m \equiv n \ [L] \;\Longrightarrow\; f(m) = f(n).$$

The restriction to odd arguments costs nothing in the intended application — semiprimes coprime to an even $L$ are odd — and it is exactly what the Jacobi symbol requires.

**Definition 2.2 (Battery).** A *battery* is a finite list $\mathcal{B} = (f_1, \dots, f_r)$ of integer-valued observables. Its *readout* at $N$ is the tuple $\mathcal{B}(N) = (f_1(N), \dots, f_r(N))$.

**Example 2.3 (The level-$B$ battery).** Put $L_B = 4\operatorname{lcm}(1,\dots,B)$ and define the three channels

$$\rho_m(N) = N \bmod m, \qquad \iota_a(N) = (a \mid N), \qquad \gamma_c(N) = \gcd(N, c),$$

for $1 \le m, a, c \le B$. The level-$B$ battery is the concatenation of all $3B$ of them. Each entry is computable in time $\operatorname{poly}(\log N)$: residues by division, Jacobi symbols by the quadratic-reciprocity variant of the Euclidean algorithm, gcds by Euclid.

**Proposition 2.4 (The channels are observables).** *Let $L$ be a modulus.*
1. *If $m \mid L$ then $\rho_m$ is an observable of modulus $L$.*
2. *If $c \mid L$ then $\gamma_c$ is an observable of modulus $L$.*
3. *If $4a \mid L$ then $\iota_a$ is an observable of modulus $L$.*
*In particular every entry of the level-$B$ battery is an observable of modulus $L_B$.*

*Proof sketch.* (1) and (2) are immediate: a congruence mod $L$ descends to a congruence mod any divisor of $L$, and $\gcd(\cdot, c)$ is a function of the residue mod $c$. For (3) one uses the periodicity of the Jacobi symbol in its lower argument: for odd $n$ the value $(a \mid n)$ depends only on $n \bmod 4a$, and $4a \mid L$ transports the hypothesis. For the level-$B$ battery: $m, c \le B$ divide $\operatorname{lcm}(1,\dots,B) \mid L_B$, and $4a \mid 4\operatorname{lcm}(1,\dots,B) = L_B$. $\square$

**Proposition 2.5 (Universality of the residue channel).** *Let $2 \mid L$ and let $f : \mathbb{N} \to \beta$ be any map. Then $f$ is an observable of modulus $L$ if and only if $f(N) = f(N \bmod L)$ for every odd $N$.*

*Proof sketch.* If $f$ factors through the reduction map then it is constant on odd residue classes, hence an observable. Conversely, $N$ and $N \bmod L$ are congruent mod $L$; since $2 \mid L$, oddness of $N$ forces oddness of $N \bmod L$, so the defining property applies. $\square$

Proposition 2.5 is the structural justification for working with the class as a whole: for a fixed modulus, the reduction $N \mapsto N \bmod L$ is the *finest* observable, and every other observable is a post-composition of it. Cleverness in designing predicates buys nothing; only enlarging $L$ does.

---

## 3. The Class-Wide No-Pinning Lemma

### 3.1 The Dirichlet core

**Theorem 3.1 (Compensating-partner lemma).** *Let $L \ge 1$, and let $N_0$ and $p$ both be coprime to $L$. Then the set*

$$\{\,q \text{ prime} \;:\; \gcd(q, L) = 1 \text{ and } pq \equiv N_0 \ [L]\,\}$$

*is infinite.*

*Proof sketch.* Since $\gcd(p, L) = 1$, the class of $p$ is a unit of $\mathbb{Z}/L$; likewise for $N_0$. Set $a = p^{-1} N_0$ in $\mathbb{Z}/L$, a unit as a product of units. Dirichlet's theorem on primes in arithmetic progressions asserts that the set of primes $q$ with $q \equiv a \ [L]$ is infinite. For any such $q$: its class is the unit $a$, hence $\gcd(q, L) = 1$; and $pq \equiv p \cdot p^{-1} N_0 \equiv N_0 \ [L]$. $\square$

The name records the interpretation: $q$ *compensates* for the choice of $p$, restoring the observed residue.

### 3.2 The main theorem

**Theorem 3.2 (Class-Wide No-Pinning Lemma).** *Let $L$ be even and let $N_0$ (the target) and $p$ (the candidate factor) both be coprime to $L$. Then there are infinitely many primes $q$, each coprime to $L$, with the property that*

$$f(pq) \;=\; f(N_0) \qquad \text{for every set } \beta \text{ and every observable } f : \mathbb{N} \to \beta \text{ of modulus } L.$$

*Proof sketch.* Take $q$ from the infinite set produced by Theorem 3.1. Since $2 \mid L$ and each of $N_0, p, q$ is coprime to $L$, each is coprime to $2$, hence odd; therefore $pq$ is odd and $N_0$ is odd. By construction $pq \equiv N_0 \ [L]$. The definition of observable applies verbatim. $\square$

Note the quantifier order. The prime $q$ is chosen *before* the observable $f$: a single compensating partner defeats the entire class simultaneously, including observables whose value type is arbitrary and observables not yet invented. This is what "class-wide" means, and it is the essential strengthening over one-channel arguments.

**Corollary 3.3 (Battery form).** *Let $L$ be even, $\mathcal{B}$ a battery of modulus-$L$ observables, and $N_0, p$ coprime to $L$. Then $\{q \text{ prime} : \mathcal{B}(pq) = \mathcal{B}(N_0)\}$ is infinite; in particular such a $q$ exists.*

**Corollary 3.4 (Full battery).** *For every $B \ge 1$ and every target $N_0$ and candidate $p$ coprime to $L_B$, infinitely many primes $q$ make the entire level-$B$ readout — all $B$ residues, all $B$ Jacobi symbols and all $B$ gcds — coincide on $pq$ and on $N_0$.*

**Corollary 3.5 (The ambiguity is not confined to small numbers).** *Let $L$ be even and $N_0$ coprime to $L$. For every bound $M$ there exist primes $p, q > M$ such that every modulus-$L$ observable agrees on $pq$ and on $N_0$.*

*Proof sketch.* The set of primes not dividing $L$ is infinite (§4), so pick $p > M$ among them; then apply Theorem 3.2 and select $q > M$ from the resulting infinite set. $\square$

**Corollary 3.6 (Partial factorisations are not excluded).** *Let $L$ be even, $N_0$ coprime to $L$, and let $p_1, \dots, p_r$ be any prescribed candidate factors, each coprime to $L$. Then infinitely many primes $q$ satisfy $f\big((p_1\cdots p_r)\,q\big) = f(N_0)$ for every modulus-$L$ observable $f$.*

*Proof sketch.* A product of integers coprime to $L$ is coprime to $L$; apply Theorem 3.2 with candidate $p_1 \cdots p_r$. $\square$

Corollary 3.6 forecloses a natural strengthening of the attack: one might hope that although no single factor can be pinned, some *combination* of hypothesised factors could be refuted. It cannot.

---

## 4. The pinned set, exactly

**Definition 4.1.** Fix a target $N_0$ coprime to $L$. A prime $p$ is **compensable** if the set $\{q \text{ prime} : \gcd(q,L)=1,\; pq \equiv N_0\ [L]\}$ is infinite, and **pinned** otherwise.

**Lemma 4.2 (Divisors of the modulus are pinned).** *Let $p$ be a prime with $p \mid L$ and let $N_0$ be coprime to $L$. Then no integer $n$ whatsoever satisfies $pn \equiv N_0 \ [L]$.*

*Proof sketch.* Reduce the congruence mod $p$, which is legitimate as $p \mid L$. The left side is $0$, so $p \mid N_0$; but then $p \mid \gcd(N_0, L) = 1$, contradicting $p > 1$. $\square$

**Theorem 4.3 (Exact description of the pinned set).** *Let $N_0$ be coprime to $L$ and $p$ prime. Then $p$ is compensable if and only if $p \nmid L$.*

*Proof sketch.* If $p \nmid L$ then, $p$ being prime, $\gcd(p, L) = 1$, and Theorem 3.1 applies. Conversely if $p$ is compensable then some $q$ realises the congruence, contradicting Lemma 4.2 if $p \mid L$. $\square$

Thus the pinned set is exactly the set of prime divisors of $L$, independent of the target.

**Theorem 4.4 (Logarithmic smallness).** *For $L \ne 0$, the number of pinned primes is at most $\log_2 L$.*

*Proof sketch.* Let $S$ be the set of prime divisors of $L$ and $k = |S|$. Each element of $S$ is $\ge 2$, so $2^k \le \prod_{p \in S} p$, and the radical $\prod_{p\in S} p$ divides $L$, whence $2^k \le L$. Take logarithms. $\square$

**Theorem 4.5 (The pinned primes of the level-$B$ battery).** *Let $p$ be prime. Then $p \mid L_B$ if and only if $p = 2$ or $p \le B$. Consequently, for $B \ge 2$, the level-$B$ battery pins at most $B$ candidates, and every prime candidate $p > B$ survives with infinitely many compensating partners.*

*Proof sketch.* If $p \mid L_B = 4\operatorname{lcm}(1,\dots,B)$ then $p$ divides $4 = 2^2$ or divides $\operatorname{lcm}(1,\dots,B)$. In the first case $p = 2$. In the second, $\operatorname{lcm}(1,\dots,B)$ divides $\prod_{i=1}^{B} i$, so $p$ divides that product and hence, being prime, divides some $i \le B$, giving $p \le i \le B$. Conversely $2 \mid 4 \mid L_B$, and any prime $p \le B$ divides $\operatorname{lcm}(1,\dots,B) \mid L_B$. The cardinality bound follows because the pinned set is contained in the integer interval $[2, B]$. $\square$

**Corollary 4.6 (Infinitely many survivors).** *For $L \ne 0$ the set of primes not dividing $L$ is infinite; hence for every target $N_0$ coprime to $L$ the set of prime candidates consistent with all modulus-$L$ observables is infinite.*

*Proof sketch.* The primes are infinite and the divisors of $L$ finite; take the difference and apply Theorem 3.2 to each survivor. $\square$

### 4.1 Density interpretation

At level $B = 12$ one has $L_{12} = 4\operatorname{lcm}(1,\dots,12) = 110{,}880$, whose prime divisors are exactly $2, 3, 5, 7, 11$: five pinned candidates. Among the $95$ primes below $500$ this is roughly $5\%$; the fraction tends to $0$ as the search range grows, since the pinned set is *absolutely* bounded by $B$ while the candidate count below $X$ grows like $X/\log X$. In a factoring attack on an $n$-bit semiprime the relevant candidate count is $\sim \sqrt{N}/\log N = \Theta(2^{n/2}/n)$, against at most $B = \operatorname{poly}(n)$ pinned candidates.

---

## 5. Sealing: the price of pinning

The no-pinning theorem, read backwards, becomes a lower bound on the modulus of any battery that *does* prune. We call this the *sealing* direction.

**Theorem 5.1 (Exclusion forces divisibility).** *Let $N_0$ be coprime to $L$ and $p$ prime. If no prime $q$ satisfies $pq \equiv N_0 \ [L]$, then $p \mid L$.*

*Proof sketch.* Contrapositive of Theorem 3.1 via Theorem 4.3. $\square$

**Theorem 5.2 (Sealing bound).** *Let $N_0$ be coprime to $L$, and let $S$ be a finite set of prime candidates each excluded by the modulus-$L$ data (i.e. admitting no prime partner realising the observed residue). Then*

$$2^{|S|} \;\le\; L, \qquad\text{equivalently}\qquad |S| \le \log_2 L .$$

*Proof sketch.* By Theorem 5.1 every $p \in S$ divides $L$, so $S$ is contained in the set of prime divisors of $L$; the estimate of Theorem 4.4 applies. $\square$

**Theorem 5.3 (Sealing bound for semiprime targets).** *Let $N_0 = p_0 q_0$ be a semiprime coprime to $L$, let $X \ge 2$, and suppose the modulus-$L$ data excludes every prime candidate below $X$ other than $p_0$ and $q_0$. Then*

$$2^{\pi(X) - 2} \;\le\; L,$$

*where $\pi(X)$ is the number of primes below $X$.*

*Proof sketch.* At most two primes below $X$ divide $N_0$, so the set $S$ of excluded candidates below $X$ has $|S| \ge \pi(X) - 2$; apply Theorem 5.2. $\square$

**Corollary 5.4 (Poly-size batteries cannot seal).** *Let $N_0 = p_0q_0$ be coprime to $L$ and suppose $L < 2^k$ with $k + 2 < \pi(X)$. Then some prime $p < X$ not dividing $N_0$ has a prime partner $q$ with $pq \equiv N_0 \ [L]$: at least $\pi(X) - 2 - k$ candidates below $X$ remain alive.*

**Interpretation.** A factoring algorithm that proceeds by elimination must clear the candidate range up to $X \approx \sqrt{N_0}$. By the prime number theorem $\pi(X) \sim X/\log X$, so Theorem 5.3 demands

$$\log_2 L \;\gtrsim\; \frac{\sqrt{N_0}}{\log \sqrt{N_0}} \;=\; \Theta\!\left(\frac{2^{n/2}}{n}\right)$$

for an $n$-bit target. The *description length* of the modulus — hence of the battery, and hence the running time of any procedure that even writes it down — is exponential in $n$. There is no $\operatorname{poly}(\log N)$ congruence battery that prunes a factoring search. The barrier is not that the attack is slow; it is that its specification does not fit in the universe.

---

## 6. From no-pinning to no-factoring

The results so far concern candidates. We now convert them into an impossibility statement about *algorithms*, and remarkably the statement holds for arbitrary $L$ — not merely $\operatorname{poly}(\log N)$-sized moduli — and for arbitrary, not necessarily computable, decoding.

**Theorem 6.1 (Two coprime semiprimes in one class).** *For every $L \ge 1$ there exist four distinct primes $p_1, q_1, p_2, q_2$, all coprime to $L$, such that*

$$\gcd(p_1q_1,\; p_2q_2) = 1 \qquad\text{and}\qquad p_1 q_1 \equiv p_2 q_2 \ [L].$$

*Proof sketch.* The primes not dividing $L$ are infinite (Corollary 4.6). Choose $p_1 < q_1 < p_2$ among them. Then $N_1 = p_1 q_1$ is coprime to $L$ and $p_2$ is coprime to $L$, so Theorem 3.1 supplies infinitely many primes $q$ with $p_2 q \equiv N_1 \ [L]$; choose $q_2 > p_2$ among them. The four primes are distinct by construction, so the two semiprimes are coprime. $\square$

**Theorem 6.2 (No factoring from congruence data).** *Let $L$ be even, let $f : \mathbb{N} \to \beta$ be any observable of modulus $L$, and let $A : \beta \to \mathbb{N}$ be an arbitrary map. Then it is **not** the case that*

$$A(f(pq)) \mid pq \quad\text{and}\quad A(f(pq)) > 1 \qquad \text{for all primes } p, q \text{ with } \gcd(pq, L) = 1.$$

*Proof sketch.* Suppose it were. Take $N_1 = p_1q_1$ and $N_2 = p_2q_2$ as in Theorem 6.1. Both are coprime to $L$ and hence odd (as $2 \mid L$), and they are congruent mod $L$; therefore $f(N_1) = f(N_2)$, so $A$ returns the same value $d := A(f(N_1)) = A(f(N_2))$ on both. The hypothesis gives $d \mid N_1$, $d \mid N_2$ and $d > 1$, so $d \mid \gcd(N_1, N_2) = 1$, contradicting $d > 1$. $\square$

**Corollary 6.3 (Maximal congruence battery).** *For even $L$, no map $A : \mathbb{N} \to \mathbb{N}$ satisfies $A(N \bmod L) \mid N$ and $A(N \bmod L) > 1$ for all semiprimes $N$ coprime to $L$. This is the strongest possible congruence battery, since every modulus-$L$ observable factors through $N \mapsto N \bmod L$.*

**Corollary 6.4 (Battery form).** *For even $L$ and any battery $\mathcal{B}$ of modulus-$L$ observables, no decoding $A$ of readouts satisfies $A(\mathcal{B}(N)) \mid N$ and $A(\mathcal{B}(N)) > 1$ for all semiprimes $N$ coprime to $L$.*

The three unusual features of Theorem 6.2 deserve emphasis. First, $L$ is *unbounded*: even a battery with an astronomically large modulus fails. Second, $A$ is *arbitrary*: it may be uncomputable, an infinite lookup table, or an oracle. Third, $\beta$ is *arbitrary*: the observable may output objects of any kind. The only hypothesis in play is that the data is a function of $N \bmod L$.

---

## 7. Why it fails: uniformity and symmetry

Theorems 3.1–3.2 rest on Dirichlet's theorem, an analytic input. Underneath lies a purely group-theoretic fact that explains *why* congruence data can never leak a factor.

**Theorem 7.1 (Product map as a perfectly uniform hash).** *Let $G$ be a group and $u \in G$. The set of ordered factorisations $\{(x,y) \in G \times G : xy = u\}$ is in bijection with $G$, via $(x,y) \mapsto x$ with inverse $x \mapsto (x, x^{-1}u)$. In particular, if $G$ is finite then*

$$\#\{(x,y) : xy = u\} \;=\; |G| \qquad \text{for every } u \in G.$$

*Proof sketch.* The two maps are mutually inverse by associativity and the group axioms; the count follows. $\square$

**Corollary 7.2 (Unit group of $\mathbb{Z}/L$).** *For every unit class $u$ of $\mathbb{Z}/L$, exactly $\varphi(L)$ ordered pairs of unit classes multiply to $u$. Hence the number of candidate factor classes consistent with an observed product class is $\varphi(L)$ — the entire unit group — and this count is independent of the observed value.*

Corollary 7.2 is an exact information-theoretic statement: conditioned on the observed residue class of a semiprime, the distribution of the class of its first factor is *uniform on the whole unit group*. The mutual information between the observation and the factor class is zero.

**Theorem 7.3 (Unique partner class).** *Let $\gcd(p, L) = 1$ and suppose $pq \equiv N_0 \ [L]$ and $pq' \equiv N_0 \ [L]$. Then $q \equiv q' \ [L]$.*

*Proof sketch.* The class of $p$ is invertible in $\mathbb{Z}/L$, so it may be cancelled. $\square$

Theorem 7.3 sharpens the picture: the battery is not *uninformative about the cofactor*. Given a hypothesised class for $p$, the class of $q$ is uniquely determined. The compensation map

$$\sigma_u : (\mathbb{Z}/L)^\times \to (\mathbb{Z}/L)^\times, \qquad \sigma_u(x) = u x^{-1},$$

with $u$ the class of the target, is a bijection, indeed an involution ($\sigma_u^2 = \mathrm{id}$), exchanging the classes of the two factors. The failure to pin is therefore *not* an information loss at the level of classes. It is the fact that every unit class contains infinitely many primes, so pinning a class pins nothing about the integer.

**Theorem 7.4 (Full support).** *Let $N_0$ be coprime to $L$. Every unit class $x$ of $\mathbb{Z}/L$ contains a prime $p$ that is consistent with the data — i.e. admits a prime $q$ with $pq \equiv N_0 \ [L]$. Hence the consistent set of classes is the entire unit group.*

*Proof sketch.* Dirichlet supplies a prime $p$ in the class $x$; that $p$ is coprime to $L$; Theorem 3.1 supplies its partner $q$. $\square$

**The symmetry principle.** All of this is one instance of a single structural fact: a modulus-$L$ observable evaluated at $N = pq$ is a *symmetric function of the unordered pair $(p, q)$*, because it depends only on the product. A symmetric function cannot break the symmetry between $p$ and $q$; nothing computable from $N$ alone can prefer one factor to the other. Any predicate capable of pinning a factor must therefore be *asymmetric* in the two factors, and asymmetry cannot be manufactured from $N$.

---

## 8. Barrier 1: polynomial gcds add nothing

A recurrent proposal is to enrich the gcd channel by probing $\gcd(f(N), N)$ for a nonlinear integer polynomial $f$, in the hope that the nonlinearity extracts structure invisible to $\gcd(N, c)$. It does not.

**Theorem 8.1 (Polynomial gcd collapse).** *For every polynomial $f \in \mathbb{Z}[x]$ and every integer $N$,*

$$\gcd\big(f(N),\, N\big) \;=\; \gcd\big(f(0),\, N\big).$$

*Proof sketch.* The difference $f(N) - f(0)$ is divisible by $N - 0 = N$, since $a - b \mid f(a) - f(b)$ for integer polynomials. Write $f(N) = f(0) + N t$ for some integer $t$. Adding an integer multiple of $N$ leaves the gcd with $N$ unchanged, so $\gcd(f(0) + Nt, N) = \gcd(f(0), N)$. Finally $f(0)$ is the constant coefficient of $f$. $\square$

**Corollary 8.2 (Shift case).** *$\gcd(N + k, N) = \gcd(k, N)$ for all $N, k$.*

Thus a polynomial gcd probe returns $\gcd(f(0), N)$, a quantity determined by a constant fixed before $N$ was seen. It is an observable of modulus $f(0)$ (indeed of modulus any multiple of $f(0)$) and is already contained in the gcd channel of a battery of sufficient level: no new pinning power whatsoever. Concretely, $\gcd(7N^3 + 5N + 12,\, N) = \gcd(12, N)$ for every $N$.

This is what we call **barrier 1**: polynomial post-processing of $N$ before a gcd probe is a function of $N$ alone, hence symmetric in the factors, hence powerless by §7.

---

## 9. Explicit instances

The following instances were computed and checked exactly; they are stated with all data so the reader may reproduce them by hand or by computer.

### 9.1 Level $B = 3$

Here $L_3 = 4\operatorname{lcm}(1,2,3) = 24$. Take the target $N_0 = 35 = 5 \times 7$ and the candidate $p = 11$. The compensating partner is $q = 73$, and

$$11 \times 73 = 803 \equiv 11 \equiv 35 \pmod{24}.$$

All nine readings of the level-$3$ battery agree on $803$ and $35$, although $\gcd(803, 35) = 1$.

### 9.2 Level $B = 12$

Here $L_{12} = 4\operatorname{lcm}(1,\dots,12) = 110{,}880$. Take the target $N_0 = 221 = 13 \times 17$, which is coprime to $L_{12}$. The full readout consists of $36$ integers: twelve residues, twelve Jacobi symbols and twelve gcds. For each prime candidate $p \le 80$ not dividing $L_{12}$ the least compensating partner in the progression $N_0 p^{-1} + jL_{12}$ is:

| candidate $p$ | partner $q$ | $N' = pq$ | $N' \bmod L_{12}$ |
|---:|---:|---:|---:|
| $13$ | $17$ | $221$ | $221$ |
| $17$ | $13$ | $221$ | $221$ |
| $19$ | $17519$ | $332861$ | $221$ |
| $23$ | $207307$ | $4768061$ | $221$ |
| $29$ | $267649$ | $7761821$ | $221$ |
| $31$ | $17891$ | $554621$ | $221$ |
| $37$ | $455513$ | $16853981$ | $221$ |
| $41$ | $329941$ | $13527581$ | $221$ |
| $43$ | $144407$ | $6209501$ | $221$ |
| $47$ | $4723$ | $221981$ | $221$ |
| $53$ | $23017$ | $1219901$ | $221$ |
| $59$ | $13159$ | $776381$ | $221$ |
| $61$ | $176321$ | $10755581$ | $221$ |
| $67$ | $117503$ | $7872701$ | $221$ |
| $71$ | $192091$ | $13638461$ | $221$ |
| $73$ | $285557$ | $20845661$ | $221$ |
| $79$ | $85619$ | $6763901$ | $221$ |

All $17$ eligible candidates compensate; all $36$ battery entries agree in every row. The pinned candidates below $80$ are exactly $2, 3, 5, 7, 11$ — the prime divisors of $110{,}880$ — matching Theorem 4.5 precisely. Note also that the *true* factorisation $221 = 13 \times 17$ appears in the table as merely one consistent completion among infinitely many.

### 9.3 Coprime doppelgängers

Taking $N_1 = 13 \times 17 = 221$ and $N_2 = 19 \times 17519 = 332861$: both are $\equiv 221 \pmod{110880}$, so all $36$ level-$12$ readings coincide, while $\gcd(N_1, N_2) = 1$. This is exactly the configuration used in Theorem 6.2, and it exhibits concretely why no decoding of the readout can produce a nontrivial divisor.

### 9.4 Barrier 1 samples

With $f(x) = 7x^3 + 5x + 12$:

$$\gcd(f(1000), 1000) = 4 = \gcd(12, 1000), \quad \gcd(f(1074), 1074) = 6 = \gcd(12, 1074), \quad \gcd(f(1296), 1296) = 12 = \gcd(12, 1296).$$

### 9.5 Uniformity

For $L \in \{8, 12, 24, 40, 60, 120\}$, direct enumeration confirms that every unit class $u$ of $\mathbb{Z}/L$ has exactly $\varphi(L)$ ordered factorisations into unit classes — $4, 4, 8, 16, 16, 32$ respectively — with no variation across $u$, as Corollary 7.2 requires.

---

## 10. Algorithms

Three procedures organise the computational content.

### 10.1 Compensating-partner search

**Input:** target $N_0$, candidate prime $p$, modulus $L$, with $\gcd(N_0, L) = \gcd(p, L) = 1$.
**Output:** a prime $q$ with $pq \equiv N_0 \ [L]$.

Compute $p^{-1} \bmod L$ by the extended Euclidean algorithm; set $r = N_0 p^{-1} \bmod L$; then test $r, r+L, r+2L, \dots$ for primality until a prime is found.

*Correctness* is Theorem 3.1: the progression starts at a unit class, so by Dirichlet it contains infinitely many primes and the loop terminates. *Complexity:* the extended Euclidean step is $O(\log^2 L)$ bit operations. The expected number of trials before a prime appears is $O(\log(rL))$ by the prime number theorem for arithmetic progressions, each trial costing a Miller–Rabin test at $O(\log^3 L)$ bit operations under standard assumptions; effective bounds on the least prime in a progression (Linnik-type, with exponent at most $5$) give an unconditional worst-case bound of $q \ll L^{5}$.

### 10.2 Battery evaluation

**Input:** $N$, level $B$.
**Output:** the $3B$-tuple of residues, Jacobi symbols and gcds.

Residues by division ($O(B \log N)$ overall), Jacobi symbols by the reciprocity-based Euclidean algorithm ($O(\log^2 N)$ each), gcds by Euclid ($O(\log^2 N)$ each). Total $O(B \log^2 N)$ — polynomial in $\log N$ for $B = \operatorname{poly}(\log N)$, as the setting requires.

### 10.3 Pinned-set computation

**Input:** level $B$.
**Output:** the exact set of pinned prime candidates.

By Theorem 4.5 the answer is $\{2\} \cup \{p \text{ prime} : p \le B\}$, computable by a sieve in $O(B \log \log B)$. The point of the algorithm is not the computation but the certificate: it returns a provably *complete* list of everything the level-$B$ battery can eliminate.

---

## 11. Discussion

### 11.1 What this rules out

Any factoring strategy of the following shape is dead: *choose a modulus $L$ and a family of predicates depending only on $N \bmod L$; compute them; deduce a factor.* By Proposition 2.5 the ingenuity of the predicates is irrelevant — only $L$ matters — and by Theorem 5.3 a useful $L$ is exponentially large. This covers residue sieving, Jacobi-symbol batteries, small-gcd probes, polynomial-gcd probes, and every combination and post-processing thereof, including combinations that condition on a hypothesised partial factorisation (Corollary 3.6).

### 11.2 What this does not rule out

Nothing here bears on the genuinely successful families of factoring algorithms, and it is instructive to see exactly why they escape.

- **Pollard's $\rho$ and $p-1$, and the elliptic-curve method** all compute gcds, but their gcd arguments are *not* functions of $N$ modulo a fixed small $L$: they involve iterated maps modulo $N$, or exponentiations of length depending on $N$, and the resulting quantity is genuinely asymmetric in $p$ and $q$ (it is sensitive to the group order at $p$, not at $q$). This asymmetry is the escape hatch, and it is exactly what §7 identifies as necessary.
- **Quadratic and number-field sieves** work with relations among many auxiliary integers, not with a bounded readout of $N$ itself.
- **Shor's algorithm** determines the multiplicative order of a random residue modulo $N$ — again a quantity of "modulus $N$", not of any fixed small modulus.

The theorem thus draws a clean line: cheap symmetric data is provably useless; every working algorithm crosses that line, and crosses it by manufacturing asymmetry.

### 11.3 The role of Dirichlet

Dirichlet's theorem is used only to produce *primes* in a prescribed unit class. The class-level statement — that every unit class is consistent, and every observation admits exactly $\varphi(L)$ factor classes — is elementary group theory (§7) and requires no analysis. Dirichlet supplies the bridge from "consistent class" to "consistent prime". This is worth noting because it identifies precisely which analytic input the barrier consumes, and hence which strengthenings require more analysis (see §12.1).

### 11.4 Relation to other barrier programmes

The structure of the argument — abstract the attack family into a class defined by an information-theoretic restriction, then exhibit an indistinguishable pair inside the class — is the standard architecture of barrier results in complexity theory. What is unusual here is that the indistinguishable pair is produced by an explicit and classical construction, so the barrier comes with concrete numerical witnesses rather than an existence proof.

---

## 12. Future directions

### 12.1 Short-interval no-pinning

The present theorem is *qualitative in size*: Dirichlet gives infinitely many compensating partners but bounds none of them. In principle an adversary could try to pin a factor by combining residue data with the *magnitude* of $N$, insisting that a legitimate doppelgänger have the same bit-length as the target.

**Conjecture 12.1.** *For every even modulus $L$, every target $N_0$ coprime to $L$ and every prime candidate $p \nmid L$, there is a compensating prime $q \le L^{C}$ for an absolute constant $C$; consequently the ambiguous partner $N' = pq$ can be found with the same bit-length as $N_0$ up to $O(\log L)$ bits.*

Linnik's theorem already yields $q \ll L^{5}$ unconditionally, so the conjecture is within reach given an effective Linnik-type input; the genuinely open part is the claim that size data adds nothing, i.e. that one can additionally demand $pq$ to lie in a prescribed dyadic window.

### 12.2 Euler-witness batteries

The natural escalation beyond congruences is the Solovay–Strassen datum.

**Conjecture 12.2.** *Let $E_a(N) = a^{(N-1)/2} \bmod N$ for $a \le B$. Then for every semiprime target $N_0$ and every prime candidate $p \nmid 2N_0$, there are infinitely many primes $q$ with $E_a(pq) = E_a(N_0)$ for all $a \le B$: the Euler-witness battery is also no-pinning.*

The heuristic is that $E_a(pq)$ is determined by the pair of Legendre symbols $(a \mid p), (a \mid q)$ together with a Chinese-remainder gluing, so the battery is once again a function of a *symmetric* datum of $(p,q)$. The obstruction to a direct proof is that the relevant modulus is $N$ itself, so the compensation must be found in a progression modulo $4\prod_{a \le B} a$ *together with* a prescribed pair of Legendre symbols — an application of Dirichlet's theorem with additional quadratic conditions.

### 12.3 The open converse

The programme's second half is the converse implication: *factor-revealing $\Rightarrow$ sealed*, i.e. that any observable which does pin a factor must require computation whose size is polynomial in $N$ rather than $\log N$. Formulating this in a way that is both faithful and provable is the central open problem here. The present paper supplies the unconditional half; the converse would be a genuine lower bound and would require a fundamentally new idea.

### 12.4 Other directions

- **Beyond semiprimes.** Extend the no-pinning statement to targets with $k$ prime factors, where the compensation map becomes an action on $k$-tuples of unit classes and the uniformity statement becomes a statement about $k$-fold products.
- **Quantitative sealing for restricted batteries.** For batteries whose readout has $r$ entries with bounded value ranges, an information-theoretic counting argument may give a bound better than $\log_2 L$ on the number of eliminable candidates.
- **Non-abelian analogues.** Theorem 7.1 holds in every group; identifying computational settings where the relevant group is non-abelian, and where the analogue of Dirichlet's theorem is a Chebotarev-type statement, would extend the barrier to other hidden-structure problems.

---

## 13. Conclusion

We have proved, unconditionally and for the entire class simultaneously, that no battery of predicates depending on a semiprime only through its residue modulo a fixed integer $L$ can pin a prime factor. The candidates such a battery can eliminate are exactly the prime divisors of $L$, at most $\log_2 L$ of them; eliminating a full search range costs a modulus with exponentially many bits; and no decoding of such data — computable or not — returns a nontrivial divisor for every semiprime. The mechanism is that group multiplication is a perfectly uniform hash, so the observed product class constrains the factor class not at all, and Dirichlet's theorem lifts this from classes to primes. Polynomial gcd probes collapse to $\gcd(f(0), N)$ and add nothing.

The result is a clean, sharp, and completely explicit barrier. It says where not to look — and, through the symmetry principle of §7, it says exactly what property a successful attack must have instead: asymmetry between the two factors, manufactured by data that no fixed modulus can supply.
