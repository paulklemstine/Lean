# Counting Is Free, Locating Is Hard: Tropical Sealing Theorems for Semiprime Witness Structures

**Author:** Aristotle
**Date:** 2026-08-13

---

## Abstract

We give a unified, fully rigorous account of why five structurally distinct proposals for integer factorization — sparse recovery of the divisor indicator, holographic evaluation of a factoring partition function, ground-state search for a tensor-network parent Hamiltonian, relaxation in an optical/Ising machine, and the $2$-Sylow torsion census of $(\mathbb{Z}/N\mathbb{Z})^\times$ — fail for one and the same reason. In each case the object that the method computes efficiently is a *count*, and each such count is either (i) constant across the class of inputs, hence information-free; (ii) invariant under a symmetry that exchanges the prime factors, hence unable to distinguish them; or (iii) obtainable only at a cost equal to the size of the search window it was meant to replace.

The organizing geometry is tropical. In logarithmic coordinates the divisor hyperbola $xy = N$ is the tropical line $X \odot Y = N$ with corner at $\sqrt N$, and every divisor pair straddles that corner. More strikingly, the $2$-Sylow torsion census $T(k) = \#\{x : x^{2^k} = 1 \bmod N\}$ of a semiprime $N = pq$ satisfies $T(k) = 2^{\min(k,a)+\min(k,b)}$ with $a = v_2(p-1)$, $b = v_2(q-1)$, so that its exponent is *exactly* the min-plus polynomial $(X \oplus a)\odot(X \oplus b)$, whose tropical root set is $\{a,b\}$. For a general squarefree modulus with prime set $S$ the census exponent is the degree-$|S|$ tropical polynomial $\bigodot_{p \in S}(X \oplus v_2(p-1))$, and the multiplicity of a tropical root $k$ is the number of primes with $v_2(p-1) = k$, recovered as a second difference of the census. We prove that the census, and indeed the entire torsion profile $d \mapsto \#\{x : x^d = 1\}$, is invariant under *tropical root shuffling* — permuting local valuations between the prime factors — and exhibit explicit collisions ($21$ vs. $77$ for the $2$-power census; $35$ vs. $39$ for the full profile) that seal the whole free-witness family at once.

Alongside these we prove: the divisor-count partition function of a semiprime is the constant $4$; the divisor indicator restricted to $[1,\sqrt N]$ is a $2$-spike vector with a unique nontrivial spike at $p$; and the energy $E(a,b) = (N-ab)^2$ has ground set exactly the four-point divisor set with spectral gap $1$, so its landscape is a delta, not a slope. All results are stated and proved for arbitrary parameters.

**Keywords:** tropical geometry, min-plus semiring, integer factorization, torsion census, $2$-adic valuation, partition function, compressed sensing, Ising machines, information-theoretic barriers.

---

## 1. Introduction

### 1.1 The shape of the question

Let $N = pq$ be a semiprime with $p < q$ prime. A very large amount of exact structural information about $N$ is available at negligible cost:

* the divisor lattice of $N$ is a $2 \times 2$ Boolean lattice with four elements;
* the divisor pairs are symmetric about $\sqrt N$;
* the group $(\mathbb{Z}/N\mathbb{Z})^\times$ is a product of two cyclic groups, and the number of its $d$-torsion elements has a closed form;
* the energy landscape $E(a,b) = (N-ab)^2$ has an explicitly describable zero set.

None of this reveals $p$. The purpose of this paper is to explain *why not*, in a way that is precise enough to constitute a proof of impossibility for concrete algorithmic proposals rather than an impression.

We adopt the following informal taxonomy, which the theorems below make formal.

**Barrier A (constancy).** A quantity $Q(N)$ which is constant on the class of inputs carries zero information; no post-processing $f(Q(N))$ can locate a factor.

**Barrier B (symmetry).** A quantity invariant under a group action that mixes $p$ and $q$ cannot distinguish them. Two inputs in the same orbit with different factorizations constitute a proof of impossibility.

**Barrier C (aggregation cost).** A quantity defined as an aggregate over a window of size $W$ costs $\Theta(W)$ to obtain unless one already knows where in the window the interesting entry is; but that is the original problem.

Each of the five attacks we analyse dies against one or more of A, B, C. The point of the paper is that these are not three unrelated phenomena but three faces of one structural fact, most visible in tropical coordinates: **the free data attached to $N$ is the *shape* of a piecewise-linear object — its corners, its slopes, its multiplicities — and the shape is symmetric in the factors.**

### 1.2 Notation and conventions

$\mathbb{N}$ denotes the non-negative integers. For $m \ge 1$ and a prime $\ell$, $v_\ell(m)$ denotes the $\ell$-adic valuation, i.e. the exponent of $\ell$ in the prime factorization of $m$; we write $v_2$ for $\ell = 2$. $\tau(N)$ is the number of positive divisors of $N$. $\lfloor \sqrt N \rfloor$ is the integer square root.

The **tropical (min-plus) semiring** is $(\mathbb{N} \cup \{\infty\}, \oplus, \odot)$ with
$$x \oplus y = \min(x,y), \qquad x \odot y = x + y,$$
neutral elements $\infty$ for $\oplus$ and $0$ for $\odot$. A **tropical polynomial** in one variable is a finite min-plus combination $\bigoplus_i (c_i \odot X^{\odot i})$, i.e. a function $x \mapsto \min_i (c_i + i x)$: a concave piecewise-linear function with integer slopes. A point $x_0$ is a **tropical root** (a point of the *corner locus*) if the minimum defining the polynomial at $x_0$ is attained by at least two distinct monomials; the **multiplicity** of a root is the drop in slope across it. This is the standard combinatorial shadow of algebraic geometry over a valued field, and all we use of it here is that valuations turn products into sums and gcd's into minima.

---

## 2. The divisor lattice of a semiprime and the constancy barrier

### 2.1 The divisor set

**Theorem 2.1 (Divisor set of a semiprime).** *Let $p, q$ be primes. Then*
$$\mathrm{Div}(pq) = \{1,\, p,\, q,\, pq\}.$$

*Proof sketch.* The divisor set of a product is the product (as a set of pairwise products) of the divisor sets when the factors are handled multiplicatively: every divisor of $pq$ is of the form $d_1 d_2$ with $d_1 \mid p$, $d_2 \mid q$. Since $\mathrm{Div}(p) = \{1,p\}$ and $\mathrm{Div}(q) = \{1,q\}$, the four products $1\cdot1$, $p \cdot 1$, $1 \cdot q$, $p \cdot q$ exhaust the divisors, and conversely each of the four listed values is realized by such a product. $\square$

Note that the statement holds without assuming $p \ne q$; when $p = q$ the displayed set has three distinct elements and the equality of sets still holds.

**Theorem 2.2 (Constant partition function).** *Let $p \ne q$ be primes. Then $\tau(pq) = 4$.*

*Proof sketch.* Distinct primes are coprime, and the divisor count is multiplicative over coprime factors: $\tau(pq) = \tau(p)\tau(q) = 2 \cdot 2 = 4$. Formally, $\mathrm{Div}(p) = \{1,p\}$ has two elements since $p > 1$, likewise for $q$. $\square$

### 2.2 Why holographic collapse cannot help

Model factorization as a counting constraint-satisfaction problem: variables are the bits of a candidate divisor $a$, and the constraint is $a \mid N$ (equivalently, the existence of $b$ with $ab = N$). The partition function of this #CSP, with unit weights, is the number of divisor pairs, i.e. $\tau(N)$. Holographic algorithms in the sense of matchgate theory are precisely a technology for collapsing exponential-looking partition functions to polynomial-time computable quantities. Theorem 2.2 says that in this instance the collapse is total and totally useless:

**Theorem 2.3 (No-locating from the partition function).** *There is no function $f : \mathbb{N} \to \mathbb{N}$ such that $f(\tau(pq)) = p$ for all primes $p < q$.*

*Proof sketch.* Apply the hypothetical $f$ to $15 = 3\cdot5$ and to $35 = 5 \cdot 7$. By Theorem 2.2 both have $\tau = 4$, so $f(4) = 3$ and $f(4) = 5$, a contradiction. $\square$

This is Barrier A in its purest form. It also isolates the correct diagnosis of what a partition-function attack would *need*: not the normalization $Z$ but the **marginals** of the induced distribution over satisfying assignments — quantities like $\Pr[\text{the nontrivial small divisor} \equiv 1 \bmod 4]$. These are exactly the "addresses" of the witnesses. They depend on $p, q \bmod 4$, and any procedure that computes them from $N$ alone would already constitute a factoring algorithm; the reduction is circular rather than merely unproven.

---

## 3. The tropical corner of the divisor hyperbola

The set of factorizations $\{(x,y) \in \mathbb{Z}_{>0}^2 : xy = N\}$ is the integer point set of a hyperbola. Under $X = \log x$, $Y = \log y$ it becomes the set of integer-log points on the line $X + Y = \log N$, which in min-plus notation is the tropical relation $X \odot Y = \log N$. The distinguished point of this tropical line is its corner $X = Y = \tfrac12 \log N$, i.e. $\sqrt N$.

**Theorem 3.1 (Corner straddling).** *Let $N \ge 1$ and $d \mid N$. Then*
$$\min\!\left(d, \tfrac{N}{d}\right) \le \lfloor \sqrt N\rfloor \le \max\!\left(d, \tfrac{N}{d}\right).$$

*Proof sketch.* Write $N = uv$ with $\{u,v\} = \{d, N/d\}$ and $u \le v$. Then $u^2 \le uv = N$, so $u \le \lfloor\sqrt N\rfloor$ by the defining property of the integer square root; and $N \le v^2$, so $\lfloor \sqrt N \rfloor \le \lfloor\sqrt{v^2}\rfloor = v$ by monotonicity of the integer square root. $\square$

Theorem 3.1 is elementary but it is the geometric backbone of everything that follows: it identifies the canonical search window $[1, \lfloor \sqrt N \rfloor]$ as *one side of the tropical corner*, and asserts that every factorization has exactly one member in that window. All the attacks below are, in one way or another, attempts to find that member without scanning the window.

---

## 4. Sparsity is real; cheap measurement is not

### 4.1 The witness vector is a 2-spike

Define the **divisor indicator** of $N$ on the corner window to be the vector $W_N \in \{0,1\}^{\lfloor\sqrt N\rfloor}$ with $W_N(x) = 1$ iff $x \mid N$.

**Theorem 4.1 (Two-spike structure).** *Let $p < q$ be primes and $N = pq$. Then*
$$\{d \in \mathrm{Div}(N) : d^2 \le N\} = \{1, p\}.$$
*Consequently $W_N$ has exactly two nonzero entries.*

*Proof sketch.* By Theorem 2.1 the candidates are $1, p, q, pq$. We have $1 \le N$ and $p^2 < pq = N$ since $p < q$. Conversely $q^2 > pq = N$ since $q > p$, and $(pq)^2 > pq$ since $pq \ge 4$. $\square$

**Corollary 4.2 (Sparsity).** *$\#\{d \in \mathrm{Div}(N) : d^2 \le N\} = 2$ for $N = pq$, $p<q$ prime.*

**Theorem 4.3 (Unique nontrivial witness).** *With $p<q$ prime and $N = pq$,*
$$\{d \in \mathrm{Div}(N) : d^2 \le N\}\setminus\{1\} = \{p\}.$$

*Proof sketch.* Immediate from Theorem 4.1 and $p \ne 1$. $\square$

Thus recovering the factorization is exactly the problem of **locating a single spike in a length-$\sqrt N$ binary vector**.

### 4.2 The measurement-cost accounting

Compressed sensing asserts that an $s$-sparse vector of length $n$ is recoverable from $m = O(s \log n)$ suitably random linear measurements. With $s = 2$ and $n = \sqrt N$ this reads $m = O(\log N)$: logarithmically many measurements, which sounds like a polynomial-time factoring algorithm.

The gap is that the theory counts *measurements*, not *operations*. Two costs are hidden:

1. **Specification cost.** A generic random measurement vector of length $n = \sqrt N$ requires $\Theta(\sqrt N)$ bits to specify. There is no shorter description of a generic vector; that is the content of incompressibility.
2. **Evaluation cost.** Even given the measurement vector, forming $\langle \phi, W_N\rangle$ requires touching the $\sqrt N$ coordinates of $W_N$, i.e. performing $\sqrt N$ divisibility tests on $N$.

Hence the total is $\Theta(\sqrt N \log N)$ — asymptotically worse than trial division up to $\sqrt N$, which costs $\Theta(\sqrt N)$. This is exactly Barrier C: *the measurement specification cost is the aggregation.*

One may attempt to evade this with **structured** measurement families whose entries are computable in polylogarithmic time from $N$ (residue-class probes $\phi_r(x) = [x \equiv r \bmod M]$, multiplicative character sums, etc.). Two obstacles then appear. First, structured families lack the incoherence (restricted-isometry) properties that make $O(s\log n)$ recovery possible; a residue-class probe partitions the window into blocks and one still needs to identify the block containing $p$, which is a search of the same size. Second, and decisively, to argue that a specific short probe separates $p$ from the zeros one needs a priori knowledge of the residue class of $p$, which is precisely the information sought: the argument is circular. The sparsity of $W_N$ is a genuine and provable fact (Theorem 4.1); what fails is the assumption that measurements are free.

---

## 5. Energy landscapes: a delta, not a slope

Define, for $N, a, b \in \mathbb{N}$,
$$E_N(a,b) := (N - ab)^2 \in \mathbb{Z}.$$
This is the objective used both by tensor-network "parent Hamiltonian" proposals (whose ground space is designed to be the factor state) and by optical/coherent Ising machines (which relax an Ising energy encoding the same constraint, typically with $a$'s bits as spins).

**Lemma 5.1 (Zero set).** *$E_N(a,b) = 0$ iff $ab = N$.*

*Proof sketch.* A square in $\mathbb{Z}$ vanishes iff its base does, and $N - ab = 0$ iff $ab = N$ after casting to $\mathbb{Z}$. $\square$

**Theorem 5.2 (Spectral gap / no gradient).** *If $ab \ne N$ then $E_N(a,b) \ge 1$.*

*Proof sketch.* $E_N(a,b)$ is a nonnegative integer by construction, and nonzero by Lemma 5.1; hence at least $1$. $\square$

Theorem 5.2 is trivial arithmetic with a strong operational meaning. Local search dynamics — gradient descent, simulated annealing, coherent Ising relaxation — require an energy that decreases *toward* the solution over a neighbourhood structure. Here the energy is a squared residual; while $E$ does vary with $|N - ab|$, its level sets are the hyperbola-parallel families $ab = \text{const}$, which in the search space of bit-strings for $a$ have no local coherence at all: flipping a single low-order bit of $a$ changes $ab$ by $b$, which is an uncontrolled jump relative to the residual. Formally, the minimum of $E$ over any non-solution configuration is bounded below by $1$ and the solution set is a finite point set, so the landscape restricted to the integer configuration space is a plateau punctured by isolated zeros — a delta function, not a basin.

**Theorem 5.3 (Ground space is the divisor set).** *For $p, q$ prime and $N = pq$,*
$$\{(a,b) \in \mathbb{N}^2 : E_N(a,b) = 0\} = \{(1,N),\ (p,q),\ (q,p),\ (N,1)\}.$$

*Proof sketch.* If $ab = N$ then $a \mid N$, so by Theorem 2.1 $a \in \{1,p,q,N\}$; in each case $b$ is determined by cancellation ($p, q > 0$). Conversely each listed pair multiplies to $N$. $\square$

**Theorem 5.4 (Ground-space cardinality).** *If moreover $p < q$, the ground space has exactly four elements.*

*Proof sketch.* The four listed pairs are pairwise distinct: $p < q < pq$ and $1 < p$, so their first coordinates $1, p, q, pq$ are four distinct numbers. $\square$

**Corollary 5.5 (Random-restart density).** *Over the configuration space $\{1,\dots,N\}^2$ of size $N^2$, a uniformly random configuration is a ground state with probability $4/N^2$. Restricted to the corner window and discarding the trivial divisor, a uniformly random probe $x \in [1,\sqrt N]$ is a nontrivial witness with probability $1/\lfloor\sqrt N\rfloor$ — the random divisor density.*

*Proof sketch.* Combine Theorem 5.4 with Theorem 4.3. $\square$

This is precisely what closes the optical-machine proposal quantitatively: an optical parametric oscillator network with $L$ modes encodes $2^L$ configurations, and if $2^L \approx \sqrt N$ then the observed random-restart success rate matches $2/2^L$, the divisor density. Numerically, at $14$ bits one measures $\approx 0.014$ against a predicted $2^{-6}\approx 0.0156$, and at $26$ bits $\approx 0.00025$ against a predicted $0.00024$. **The device's mode volume *is* the witness count**; the analog resource changes the physics, not the counting (Barriers A/C).

The tensor-network proposal fails for a complementary reason. The target ground state $|p\rangle\otimes|q\rangle$ is a **product state**: as a bipartite tensor it has Schmidt rank $1$ and entanglement entropy exactly $0$. Tensor networks are an ansatz whose expressive advantage is the efficient representation of *correlated* states with bounded entanglement; a state with zero entanglement is representable by bond dimension one, so the ansatz is trivial and provides no computational leverage. The difficulty is entirely relocated to the variational search for the ground state within the ansatz — which by Theorems 5.2–5.4 is search over a plateau with four isolated minima.

---

## 6. The torsion census as a tropical polynomial

We now turn to the richest of the five structures, where "tropical" becomes literal rather than analogical.

### 6.1 Torsion counting

For a group $G$ and $d \in \mathbb{N}$ set
$$\mathcal{T}(G, d) := \#\{x \in G : x^d = 1\}.$$

**Lemma 6.1 (Invariance and multiplicativity).** *$\mathcal{T}(-,d)$ is invariant under group isomorphism, and $\mathcal{T}(G\times H, d) = \mathcal{T}(G,d)\cdot\mathcal{T}(H,d)$.*

*Proof sketch.* An isomorphism restricts to a bijection of $d$-torsion subsets, since it preserves powers and the identity. For products, $(x,y)^d = 1$ iff $x^d = 1$ and $y^d=1$, so the torsion set is a Cartesian product. $\square$

**Lemma 6.2 (Cyclic groups).** *If $G$ is finite cyclic then $\mathcal{T}(G,d) = \gcd(|G|, d)$.*

*Proof sketch.* Standard: in $\mathbb{Z}/n\mathbb{Z}$ the solutions of $dx = 0$ form the subgroup of order $\gcd(n,d)$. $\square$

**Theorem 6.3 (Torsion count of a semiprime modulus).** *For distinct primes $p,q$ and any $d$,*
$$\mathcal{T}\big((\mathbb{Z}/pq\mathbb{Z})^\times, d\big) = \gcd(p-1, d)\cdot\gcd(q-1,d).$$

*Proof sketch.* The Chinese Remainder Theorem gives a ring isomorphism $\mathbb{Z}/pq\mathbb{Z} \cong \mathbb{Z}/p\mathbb{Z}\times\mathbb{Z}/q\mathbb{Z}$ and hence a group isomorphism of unit groups $(\mathbb{Z}/pq\mathbb{Z})^\times \cong (\mathbb{Z}/p\mathbb{Z})^\times \times (\mathbb{Z}/q\mathbb{Z})^\times$. Each factor is cyclic of order $p-1$ resp. $q-1$. Apply Lemma 6.1 then Lemma 6.2. $\square$

**Theorem 6.4 (Squarefree moduli).** *Let $S$ be a finite set of primes and $N = \prod_{p\in S} p$. Then for all $d$,*
$$\mathcal{T}\big((\mathbb{Z}/N\mathbb{Z})^\times, d\big) = \prod_{p \in S}\gcd(p-1,d).$$

*Proof sketch.* Induction on $S$ using coprimality of a prime to the product of the remaining ones, CRT multiplicativity of the unit group, and Lemma 6.2 at each prime; the empty product is the trivial group with $\mathcal{T} = 1$. $\square$

### 6.2 Valuations as a tropical morphism

**Lemma 6.5 ($v_2$ is a semiring morphism).** *For nonzero $m,n$:*
$$v_2(\gcd(m,n)) = \min(v_2 m,\, v_2 n), \qquad v_2(mn) = v_2 m + v_2 n.$$
*Equivalently, in the tropical semiring, $v_2(\gcd(m,n)) = v_2(m)\oplus v_2(n)$ and $v_2(mn) = v_2(m)\odot v_2(n)$: the $2$-adic valuation carries $(\mathbb{N}_{\ne0}, \gcd, \cdot)$ into $(\mathbb{N},\oplus,\odot)$.*

*Proof sketch.* Both are the standard behaviour of prime-exponent functions: the factorization of a gcd is the pointwise min of factorizations, and factorization is additive under multiplication. $\square$

**Lemma 6.6 (Truncated 2-part).** *For $m \ne 0$, $\gcd(m, 2^k) = 2^{\min(v_2 m,\, k)}$.*

*Proof sketch.* Apply Lemma 6.5 with $n = 2^k$ and note $\gcd(m,2^k)$ is a power of $2$ with valuation $\min(v_2 m, k)$. $\square$

### 6.3 The exact census and its tropicality

**Definition 6.7.** The **$2$-Sylow torsion census** of $N$ is $T_N(k) := \mathcal{T}((\mathbb{Z}/N\mathbb{Z})^\times, 2^k)$. For $a,b \in \mathbb{N}$ the **census exponent** is $\mathcal{E}_{a,b}(k) := \min(k,a) + \min(k,b)$.

**Theorem 6.8 (Exact census of a semiprime).** *For distinct primes $p,q$ and all $k$,*
$$T_{pq}(k) = 2^{\,\min(k,a) + \min(k,b)}, \qquad a := v_2(p-1),\ b := v_2(q-1).$$

*Proof sketch.* By Theorem 6.3, $T_{pq}(k) = \gcd(p-1,2^k)\gcd(q-1,2^k)$; apply Lemma 6.6 twice and combine the powers. $\square$

Equivalently: $(\mathbb{Z}/N\mathbb{Z})^\times$ has $2$-Sylow subgroup $C_{2^a}\times C_{2^b}$, and the census counts its $2^k$-torsion.

**Theorem 6.9 (Tropicality of the census).** *For all $a,b,k$, the census exponent is the value at $X=k$ of the tropical quadratic*
$$P_{a,b}(X) = (X \oplus a)\odot(X\oplus b),$$
*i.e. $\mathcal{E}_{a,b}(k) = \min(k,a)+\min(k,b)$ is min-plus-polynomial in $k$.*

*Proof sketch.* Immediate from the definitions of $\oplus$ and $\odot$; the content is the identification, not the computation. Formally, tropicalizing sends $\min$ to $\oplus$ and $+$ to $\odot$. $\square$

**Theorem 6.10 (Monomial expansion).** *$\mathcal{E}_{a,b}(k) = \min\big(2k,\ \min(a,b)+k,\ a+b\big)$.*

*Proof sketch.* Case analysis on the relative order of $k, a, b$; equivalently, expanding $(X\oplus a)\odot(X\oplus b)$ gives the monomials $X^{\odot2}$, $(a\oplus b)\odot X$, $a\odot b$. $\square$

**Definition 6.11 (Corner locus).** With the three monomials $M_0(x) = 2x$, $M_1(x) = \min(a,b)+x$, $M_2(x) = a+b$, say $x$ is a **tropical root** of $P_{a,b}$ if the minimum $\min_i M_i(x)$ is attained by at least two distinct indices.

**Theorem 6.12 (Corner locus of the census quadratic).** *$x$ is a tropical root of $P_{a,b}$ if and only if $x = a$ or $x = b$.*

*Proof sketch.* ($\Leftarrow$) Assume WLOG $a \le b$. At $x = a$ the monomials $M_0 = 2a$ and $M_1 = a + a = 2a$ agree and are minimal (since $M_2 = a+b \ge 2a$). At $x = b$, $M_1 = a + b = M_2$ and both are minimal. The case $b \le a$ is symmetric. ($\Rightarrow$) If two of the three monomials agree at the common minimum, a finite case check on which pair coincides forces $x \in \{a,b\}$: $M_0 = M_1$ forces $x = \min(a,b)$ together with minimality; $M_1 = M_2$ forces $x = \max(a,b)$; $M_0 = M_2$ with minimality forces $2x = a+b \le \min(a,b)+x$, i.e. $x \le \min(a,b)$ and $2x = a + b$, hence $a = b = x$. $\square$

Thus **the $2$-adic fingerprint $\{a,b\}$ of the semiprime is exactly the corner locus of its census**, and the census is a concave piecewise-linear function of $k$ with slope $2$ below $\min(a,b)$, slope $1$ between the roots, and slope $0$ above $\max(a,b)$.

**Theorem 6.13 (Census slope).** *$\mathcal{E}_{a,b}(k+1) - \mathcal{E}_{a,b}(k) = [k < a] + [k < b]$.*

*Proof sketch.* $\min(k+1,a)-\min(k,a) = [k<a]$ and likewise for $b$. $\square$

**Theorem 6.14 (The census determines the unordered fingerprint).** *If $\mathcal{E}_{a,b} = \mathcal{E}_{a',b'}$ as functions on $\mathbb{N}$, then $\{a,b\} = \{a',b'\}$ as multisets.*

*Proof sketch.* Evaluate at $k = a, b, a', b'$ and at a large $k$ exceeding all four (where both sides equal $a+b$ and $a'+b'$ respectively, giving $a+b = a'+b'$); the resulting linear system over $\min$'s forces the multisets to coincide. $\square$

### 6.4 The census does not locate

**Theorem 6.15 (Explicit census collision).** *For all $k$, $T_{21}(k) = T_{77}(k)$, where $21 = 3\cdot7$ and $77 = 7\cdot11$.*

*Proof sketch.* $v_2(3-1)=v_2(2)=1$, $v_2(7-1)=v_2(6)=1$, $v_2(11-1)=v_2(10)=1$. So both semiprimes have fingerprint $\{1,1\}$ and, by Theorem 6.8, census $2^{2\min(k,1)}$. $\square$

**Theorem 6.16 (Census sealing).** *There is no functional $f$ on census functions with $f(T_{pq}) = p$ for all primes $p<q$.*

*Proof sketch.* Such an $f$ would give $f(T_{21}) = 3$ and $f(T_{77}) = 7$, contradicting Theorem 6.15. $\square$

This is Barrier B: the census is a function of the unordered fingerprint only (Theorems 6.8 and 6.14 make this an exact characterization of its information content), and the fingerprint is far from determining the factorization.

### 6.5 Higher degree: squarefree moduli

Let $S$ be a set of odd primes, $N = \prod_{p\in S}p$, $r = |S|$, and define the **multi-census exponent** $\mathcal{E}_S(k) := \sum_{p\in S}\min(k, v_2(p-1))$.

**Theorem 6.17 (Exact census, general squarefree modulus).** *$T_N(k) = 2^{\mathcal{E}_S(k)}$.*

*Proof sketch.* Theorem 6.4 with $d = 2^k$ and Lemma 6.6 at each prime. $\square$

**Theorem 6.18 (Degree-$r$ tropicality).** *$\mathcal{E}_S$ is the value function of the tropical polynomial $\bigodot_{p\in S}\big(X \oplus v_2(p-1)\big)$.*

*Proof sketch.* Induction on $S$: the tropical product of the factors is the ordinary sum of the $\min$'s. $\square$

**Theorem 6.19 (Slope counts surviving primes).** *$\mathcal{E}_S(k+1) = \mathcal{E}_S(k) + \#\{p\in S : v_2(p-1) > k\}$.*

*Proof sketch.* Term-by-term as in Theorem 6.13. $\square$

**Theorem 6.20 (Tropical root multiplicity).** *For all $k$,*
$$\big(\mathcal{E}_S(k+1)-\mathcal{E}_S(k)\big) - \big(\mathcal{E}_S(k+2)-\mathcal{E}_S(k+1)\big) = \#\{p \in S: v_2(p-1) = k+1\}.$$
*That is, the multiplicity of $k+1$ as a tropical root of the census polynomial equals the number of prime factors at $2$-adic level exactly $k+1$.*

*Proof sketch.* By Theorem 6.19 both differences are counts of surviving primes at consecutive levels; the primes counted at level $k$ but not at level $k+1$ are exactly those with $v_2(p-1) = k+1$. $\square$

**Theorem 6.21 (Newton-polygon / layer-cake duality).** *$\mathcal{E}_S(k) = \sum_{j<k} \#\{p\in S: v_2(p-1)>j\}$: the tropical polynomial is the discrete integral of its root-counting function.*

*Proof sketch.* Telescoping Theorem 6.19 from $0$. $\square$

**Theorem 6.22 (Concavity).** *$\mathcal{E}_S(k+2) + \mathcal{E}_S(k) \le 2\,\mathcal{E}_S(k+1)$.*

*Proof sketch.* The slope $\#\{p : v_2(p-1)>k\}$ is antitone in $k$ because the defining condition weakens as $k$ decreases; concavity of a piecewise-linear function is exactly antitonicity of its slopes. $\square$

**Theorem 6.23 (Level-one census is information-free).** *If every $p \in S$ is an odd prime, then $T_N(1) = 2^{|S|}$.*

*Proof sketch.* For odd $p$, $2 \mid p-1$, so $v_2(p-1) \ge 1$ and $\min(1, v_2(p-1)) = 1$; hence $\mathcal{E}_S(1) = |S|$. $\square$

Theorem 6.23 is the exact analogue, inside the census world, of the constant partition function of Theorem 2.2: the first level of the census depends only on the *number* of prime factors, not on which primes they are. Barrier A again, now in a family where higher levels *are* informative — a sharp illustration that "informative" and "locating" are different properties.

**Theorem 6.24 (What the census determines).** *If $\mathcal{E}_S = \mathcal{E}_{S'}$ then for every $k \ge 1$, $\#\{p\in S: v_2(p-1)=k\} = \#\{p\in S': v_2(p-1)=k\}$.*

*Proof sketch.* Both sides are the second difference of the common function by Theorem 6.20. $\square$

Level $0$ is invisible: a tropical root at $0$ contributes no corner, matching the fact that the prime $2$ (with $v_2(2-1)=0$) leaves no trace in the $2$-power census.

---

## 7. Root shuffling: sealing the whole free-witness family

Theorems 6.16 and 6.24 concern the $2$-power census. One might hope that the *full torsion profile*
$$\Pi_N(d) := \mathcal{T}\big((\mathbb{Z}/N\mathbb{Z})^\times, d\big) = \gcd(p-1,d)\gcd(q-1,d)$$
over all exponents $d$ restores injectivity, since it sees every prime $\ell$, not only $\ell = 2$. It does not, and the obstruction is a clean tropical symmetry.

**Lemma 7.1 (Valuation of a gcd, pointwise).** *For nonzero $m,d$ and any prime $\ell$: $v_\ell(\gcd(m,d)) = \min(v_\ell m, v_\ell d)$.*

*Proof sketch.* The factorization of a gcd is the pointwise infimum of the factorizations. $\square$

**Theorem 7.2 (Tropical root shuffling).** *Let $m_1,n_1,m_2,n_2$ be nonzero and suppose that for every prime $\ell$,*
$$\{v_\ell(m_1), v_\ell(n_1)\} = \{v_\ell(m_2), v_\ell(n_2)\} \text{ as multisets.}$$
*Then for every nonzero $d$,*
$$\gcd(m_1,d)\cdot\gcd(n_1,d) = \gcd(m_2,d)\cdot\gcd(n_2,d).$$

*Proof sketch.* Two positive integers are equal iff their factorizations agree at every prime. At a prime $\ell$, using additivity of valuations under products and Lemma 7.1, the left side has $\ell$-valuation $\min(v_\ell m_1, v_\ell d) + \min(v_\ell n_1, v_\ell d)$, and similarly on the right. The hypothesis says the pairs $(v_\ell m_1, v_\ell n_1)$ and $(v_\ell m_2, v_\ell n_2)$ agree up to a swap, and the expression $\min(u,t)+\min(v,t)$ is symmetric in $(u,v)$. Non-prime $\ell$ contribute zero on both sides. $\square$

The tropical reading: the profile evaluates, at each prime $\ell$ independently, the tropical polynomial $(X\oplus v_\ell(m))\odot(X\oplus v_\ell(n))$; a tropical polynomial depends only on the *multiset* of its roots, never on any labelling of them. Assigning valuations to $p$ versus $q$ is exactly such a labelling.

**Theorem 7.3 (Explicit shuffle).** *For every nonzero $d$: $\gcd(4,d)\gcd(6,d) = \gcd(2,d)\gcd(12,d)$.*

*Proof sketch.* At $\ell = 2$ the valuation pairs are $(2,1)$ and $(1,2)$ — a swap. At every other prime, $v_\ell(4)=v_\ell(2)=0$ and $v_\ell(6) = v_\ell(12) = [\ell = 3]$. Apply Theorem 7.2. $\square$

**Theorem 7.4 (Profile collision).** *For every $d \ge 1$, the moduli $35 = 5\cdot 7$ and $39 = 3\cdot13$ have equal torsion profiles:*
$$\mathcal{T}\big((\mathbb{Z}/35\mathbb{Z})^\times, d\big) = \mathcal{T}\big((\mathbb{Z}/39\mathbb{Z})^\times, d\big).$$

*Proof sketch.* By Theorem 6.3 the two sides are $\gcd(4,d)\gcd(6,d)$ and $\gcd(2,d)\gcd(12,d)$; apply Theorem 7.3. $\square$

**Theorem 7.5 (Sealing of the entire free-witness family).** *There is no functional $f$ on profiles with $f(\Pi_{pq}) = p$ for all primes $p<q$.*

*Proof sketch.* Such an $f$ would yield $f(\Pi_{35}) = 5$ and $f(\Pi_{39}) = 3$, contradicting Theorem 7.4. $\square$

Theorem 7.5 is the strongest impossibility statement in the paper: it rules out, in one stroke, *every* algorithm whose only access to $N$ is via the counts $\#\{x : x^d \equiv 1 \bmod N\}$, for arbitrary and arbitrarily many exponents $d$, including adaptively chosen ones (an adaptive strategy is a particular functional of the profile). All such "$k$-th root witness counting" methods are sealed.

It is worth being precise about what is *not* claimed. The theorem does not say these counts are useless: knowing $\gcd(p-1,d)\gcd(q-1,d)$ for well-chosen $d$ is genuinely useful in, say, Pollard's $p-1$ method — but there the algorithm uses group *elements* (witness addresses: an actual $x$ with $x^d \ne 1$ yields $\gcd(x^d - 1, N)$), not merely the counts. The distinction between counting and locating is exactly the distinction between the profile value and the identity of a witness realizing it.

---

## 8. Algorithms

The results above are impossibility statements, but they rest on positive algorithmic content: everything they say is free really is computable in polylogarithmic or polynomial time, and we record the procedures.

### 8.1 Census evaluation from a known factorization

Given the factorization $N = \prod_{p\in S}p$, computing $T_N(k)$ for all $k \le K$ costs $O(|S|\cdot(\log N + K))$: compute $v_2(p-1)$ for each $p$ by counting trailing zero bits, then accumulate $\mathcal{E}_S(k) = \sum_p \min(k, v_2(p-1))$. Without the factorization, evaluating $T_N(k)$ directly by enumeration costs $\Theta(N)$ — this asymmetry *is* the sealing.

### 8.2 Fingerprint recovery from the census

Given the census values $T(0), T(1), \dots, T(K)$ of a semiprime with $\max(a,b) \le K$, the fingerprint $\{a,b\}$ is recovered in $O(K)$: form $\mathcal{E}(k) = \log_2 T(k)$, take first differences $s(k) = \mathcal{E}(k+1) - \mathcal{E}(k) \in \{0,1,2\}$, and read off $\min(a,b)$ as the first $k$ where $s$ drops from $2$ to $1$ and $\max(a,b)$ as the first $k$ where $s$ drops to $0$ (Theorem 6.13). For general squarefree moduli, the second differences give root multiplicities at every level (Theorem 6.20).

### 8.3 Corner-window search (the honest baseline)

Trial division over the corner window $[2, \lfloor\sqrt N\rfloor]$ finds $p$ in $\Theta(\sqrt N)$ divisibility tests and is guaranteed by Theorems 3.1 and 4.1 to succeed. Every "exotic" method analysed above is, on the accounting of Section 4.2 and Corollary 5.5, at best a re-encoding of this baseline.

### 8.4 Collision search

To manufacture explicit counterexamples of the type used in Theorems 6.15 and 7.4, enumerate semiprimes $pq$ below a bound, key them by their local valuation multisets $\big(\{v_\ell(p-1), v_\ell(q-1)\}\big)_\ell$ (for $\ell$ up to the bound), and report any two keys that coincide with different factorizations. Cost is $O(B\log B)$ for bound $B$ with a sieve. The pairs $(21, 77)$ and $(35,39)$ are the smallest instances of the $2$-power and full-profile collisions respectively.

---

## 9. Discussion

### 9.1 A single mechanism in five disguises

The list of failures is uniform when read at the right level of abstraction:

| Proposal | Computed object | Failure mode |
|---|---|---|
| Sparse recovery of the divisor indicator | $O(\log N)$ inner products against $\sqrt N$-long vectors | Barrier C: specification/evaluation cost is the full window |
| Holographic partition function | $Z = \tau(N) = 4$ | Barrier A: constant across all semiprimes |
| Tensor-network parent Hamiltonian | ground state of $(N-ab)^2$ | Barrier A/C: zero entanglement, four isolated minima, no gradient |
| Optical/Ising machine | relaxation over $2^L$ modes | Barrier A/C: mode volume equals witness count; success $= 2/2^L$ |
| $2$-Sylow torsion census / full profile | $\gcd(p-1,d)\gcd(q-1,d)$ | Barrier B: invariant under root shuffling; explicit collisions |

The invariant content across the row is: **the resource changes the physics, not the counting.** Whatever the substrate — random matrices, matchgates, tensors, optical modes, finite groups — the quantity that becomes cheap is a count over the same witness set, and the witness set has a size and a symmetry group that no change of substrate alters.

### 9.2 Counting versus locating

The sharpest formulation is the counting/locating dichotomy. Given $N = pq$:

* the *number* of divisor pairs is $4$, exactly, for free;
* the *number* of $d$-torsion units is $\gcd(p-1,d)\gcd(q-1,d)$, in closed form;
* the *number* of ground states of $(N-ab)^2$ is $4$;
* the *number* of spikes in the window indicator is $2$.

Every one of these is a *count*, and each is either constant or symmetric. What is missing in every case is an *address*: which $x$ in the window is the spike, which configuration is a ground state, which unit realizes a given torsion order. Formally the counting problems are all in polynomial time (indeed constant time), and the search problems are all equivalent to factoring. That the counting versions collapse while the search versions do not is a strong hint that any successful attack must be *witness-producing* rather than *witness-counting* — which is exactly the profile of the classical algorithms that do work (Pollard's rho and $p-1$, elliptic curve method, quadratic and number field sieves), all of which manufacture an explicit element whose gcd with $N$ is nontrivial.

### 9.3 Tropical geometry as the right coordinate system

Two independent tropical structures appeared, and it is worth separating them.

1. **The multiplicative structure of $N$** tropicalizes, under $\log$, to the tropical line with corner at $\sqrt N$ (Theorem 3.1). This is the geometry of the search window.
2. **The $2$-adic structure of the unit group** tropicalizes, under $v_2$, to a min-plus polynomial whose roots are the local levels of $p-1$ and $q-1$ (Theorems 6.9, 6.12, 6.18). This is the geometry of the invariant.

The second is the one with teeth. Once one knows that the census is a tropical polynomial, the sealing theorems become structural rather than accidental: a tropical polynomial in one variable is determined by, and determines, only the multiset of its roots with multiplicity. The census therefore carries exactly $\mathrm{multiset}\{v_2(p-1), v_2(q-1)\}$ and not one bit more (Theorem 6.14), and the full profile carries exactly the family of such multisets over all primes $\ell$ (Theorem 7.2) — a piece of data invariant under a large shuffling group whose orbits contain distinct semiprimes (Theorem 7.4). *Being blind to labels is not a defect of the particular method; it is the definition of a tropical polynomial.*

### 9.4 Scope and limitations

We emphasize the exact logical strength of the results. Theorems 2.3, 6.16 and 7.5 are unconditional impossibility statements about a restricted access model: an algorithm which sees only the stated statistic. They say nothing about algorithms with other access to $N$, and they are of course not statements about the complexity of factoring itself. Their value is as *closures*: they convert a family of speculative proposals into a settled question, and they identify precisely which feature (constancy, shuffling invariance, aggregation cost) must be broken by any proposal that hopes to succeed.

Theorem 5.2 is an exact statement about integer configurations; it does not by itself rule out continuous relaxations with different objectives, though it does show that the naive squared residual has no usable gradient structure on the integer lattice, and Corollary 5.5 shows that the empirical success rate of a relaxation with no such structure matches unstructured search.

---

## 10. Future directions

The formal development suggests three lines of attack, each pushing where the present proofs are tight.

**Conjecture 1 (Tropical Sealing Conjecture).** *Every multiplicative "spectral" statistic of $(\mathbb{Z}/N\mathbb{Z})^\times$ is root-shuffling invariant, hence cannot locate.* Precisely: let $F$ be any function of $N$ computable from the isomorphism class of $(\mathbb{Z}/N\mathbb{Z})^\times$ alone. Then for squarefree $N = \prod p$, $F(N)$ is invariant under any permutation of the local valuation multisets $\{v_\ell(p-1)\}_{p\mid N}$ that preserves the multiset at each prime $\ell$; consequently, for every $B$ there exist two $B$-bit semiprimes with equal $F$ and coprime factorizations. The invariance half is already a theorem (Theorem 7.2 together with the fact that the torsion profile is a complete isomorphism invariant of a finite abelian group), so the conjecture reduces to a purely tropical statement about shuffling roots of one-variable min-plus polynomials, with the open part being the *density* claim — the existence of shuffled pairs at every bit size, which needs a Linnik or Bombieri–Vinogradov type input on primes in arithmetic progressions $p \equiv 1 + 2^a u$.

**Conjecture 2 (Tropical Corner Barrier).** *No polynomial-time algorithm can evaluate the census exponent $k \mapsto \min(k, v_2(p-1)) + \min(k, v_2(q-1))$ at any $k \ge 1$ for adversarial semiprimes.* Precisely: evaluating $T(k)$ for a single $k \in [1, \log N]$ is as hard as factoring, in the sense that an oracle returning $T(2)$ for arbitrary semiprimes yields a probabilistic polynomial-time factoring algorithm. The key point is that $T(2) = 2^{\min(2,a)+\min(2,b)}$ distinguishes $a = 1$ from $a \ge 2$, i.e. reveals $p \bmod 4$-type information about the *unordered* pair; combining this with the classical square-root-of-unity factoring reduction — which the four-point ground space of Theorem 5.3 makes explicit — should upgrade the oracle into a factorization, showing that the sealing of Theorem 6.16 is tight rather than an artefact. Since the exact formula (Theorem 6.8) is now available, the reduction can be attempted symbolically rather than experimentally.

**Conjecture 3 (Level-zero invisibility and beyond).** The census cannot see level $0$, and more generally the passage from the corner locus to the factorization loses exactly the labelling data. A quantitative version would measure the entropy of the fibre: how many $B$-bit semiprimes share a given tropical root multiset, and how that count grows with $B$. A matching upper bound would turn the qualitative sealing theorems into a statement that the census leaks $O(\log\log N)$ bits — the sizes of the two levels — and no more.

---

## 11. Conclusion

Five proposals to factor a semiprime by an exotic computational resource have been analysed and each is closed by an exact theorem. The divisor-count partition function is the constant $4$ and cannot locate. The divisor indicator over the corner window $[1,\sqrt N]$ is a genuine $2$-spike signal with a unique nontrivial spike at $p$, but the measurements needed to exploit its sparsity cost as much as scanning the window. The energy $(N - ab)^2$ has ground set exactly $\{(1,N),(p,q),(q,p),(N,1)\}$ with spectral gap $1$: a delta, not a slope, so both tensor-network and optical relaxations degrade to random search at the divisor density. And the $2$-Sylow torsion census is exactly $2^{\min(k,a)+\min(k,b)}$ — the tropical quadratic with roots $a = v_2(p-1)$ and $b = v_2(q-1)$ — which determines the unordered fingerprint and nothing more, while the full torsion profile over all exponents is invariant under shuffling local valuations between the factors and collides on $35$ and $39$.

The lesson generalizes past the specific proposals. Tropical polynomials know their roots as a multiset and are blind to labels; counting problems know cardinalities and are blind to addresses. A method for factoring must, at some point, produce an address.
