# Counting Is Free, Locating Is Hard

### Why five exotic machines all failed to factor a number — and what the failure reveals about the shape of arithmetic

---

## A number with a secret

Take the number $N = 3\,127$. It has a secret: it is the product of two primes, $53 \times 59$. Finding those primes is, as far as anyone knows, hard — hard enough that the security of much of the world's encrypted traffic rests on the belief that for numbers of a few hundred digits it is essentially impossible.

But here is the strange thing. The *existence* of the secret is not hidden at all. Nobody needs to search to know that $N$ has exactly four divisors: $1$, $p$, $q$, and $N$ itself. Nobody needs to search to know that one of the two prime factors lies below $\sqrt{N}$ and the other above. Nobody needs to search to know exactly how many solutions the equation $x^{2^k} \equiv 1 \pmod N$ has, once you know a couple of small pieces of local data. An enormous amount of exact, provable, quantitative information about the factorization is available for free.

None of it tells you what $p$ is.

This article is about turning that observation into a theorem — or rather into a small family of theorems, each of which kills a plausible-sounding attack on factoring. The unifying slogan is: **counting is free, locating is hard.** Every one of the attacks we will look at computes some *count* — a number of solutions, a number of configurations, a partition function, a number of measurements — and every one of them dies at the same place: the count it computes is either constant across all numbers of the relevant type (so it carries literally zero information), or it depends only on data that is symmetric between $p$ and $q$ (so it cannot say which is which), or the cost of computing it is exactly the cost of the brute-force search it was supposed to replace.

The geometry behind all of this turns out to be *tropical*.

---

## The corner of the hyperbola

Start with a picture. The factorizations of $N$ are the lattice points on the hyperbola $xy = N$ with $x, y$ positive integers. Take logarithms: writing $X = \log x$, $Y = \log y$, the hyperbola becomes the straight line $X + Y = \log N$.

In *tropical* mathematics one works in the min-plus semiring: addition is replaced by taking a minimum, written $\oplus$, and multiplication is replaced by ordinary addition, written $\odot$. The line $X \odot Y = \log N$ is a tropical line, and a tropical line in one variable has a distinguished point — its **corner**, the place where the piecewise-linear function that defines it changes slope. For the divisor hyperbola the corner sits exactly at $X = Y = \tfrac12 \log N$, that is, at $\sqrt N$.

The first theorem makes this precise and completely elementary.

> **Corner Straddling Theorem.** Let $N \geq 1$ and let $d$ be any divisor of $N$. Then the divisor pair $(d, N/d)$ straddles $\sqrt N$:
> $$\min\left(d, \tfrac{N}{d}\right) \;\le\; \lfloor \sqrt N \rfloor \;\le\; \max\left(d, \tfrac{N}{d}\right).$$

The proof is one line of algebra: if $N = uv$ with $u \le v$ then $u^2 \le uv = N \le v^2$. But the geometric reading matters. **Every** factorization of $N$ is a pair of points symmetric about the tropical corner. The corner is the only landmark the number gives you for free, and half the hyperbola — the window $[1, \sqrt N]$ — is where all the small factors hide.

So: how much of that window do you have to inspect?

---

## A two-spike signal

Here is where a genuinely modern idea enters. **Compressed sensing** is the theory, now standard in medical imaging and signal processing, that a vector which is *sparse* — mostly zeros, with only a few nonzero spikes — can be reconstructed from far fewer measurements than its length. A vector of length $n$ with only $s$ spikes can typically be recovered from about $s \log n$ random linear measurements rather than all $n$ coordinates.

Now consider the indicator vector of the divisors of $N = pq$ across the window $[1, \sqrt N]$: put a $1$ at position $x$ if $x$ divides $N$, and $0$ otherwise. How sparse is it?

> **Two-Spike Theorem.** Let $p < q$ be primes and $N = pq$. The divisors of $N$ lying in the window $[1, \sqrt N]$ are exactly $1$ and $p$. Hence the divisor-indicator vector on that window has exactly two nonzero entries, and after discarding the trivial divisor $1$ there is exactly **one** nontrivial spike, located at $p$.

The proof is a two-line case check once you know that the divisors of $pq$ are precisely $\{1, p, q, pq\}$: neither $q$ nor $pq$ can satisfy $d^2 \le N$ when $p < q$, while $1$ and $p$ both do.

So the signal is as sparse as a signal can be while still being interesting. Compressed sensing promises recovery from $O(\log N)$ measurements. Doesn't that factor $N$ in polynomial time?

No — and the reason is a beautiful accounting failure. Compressed sensing's guarantees are about the *number* of measurements, not about the *cost of specifying and evaluating* them. A random measurement of a length-$\sqrt N$ vector is a random vector of length $\sqrt N$; writing it down costs $\sqrt N$ symbols and evaluating the inner product costs $\sqrt N$ divisibility tests. Multiply by $\log N$ measurements and you have paid $O(\sqrt N \log N)$ — *more* than trial division, which is the very thing you were trying to beat.

Could one use *structured* measurements instead, ones with a short description computable from $N$ alone? One can, but then a second wall appears: to know that a structured probe (a residue-class test, a character sum) will actually separate the spike at $p$ from the sea of zeros, you need to know something about where $p$ sits — which is what you were trying to find. Every escape route is either expensive or circular. The sparsity of the signal is real; the cheapness of the measurements is not.

The general form of this obstruction — call it the **free-witness aggregation barrier** — is that a quantity summed or searched over a window of size $W$ costs $W$ to obtain unless you can locate the interesting entry first, and locating it is the original problem.

---

## The partition function that knows nothing

Second attack, and the deepest structural point of the story.

A powerful technique in both statistical physics and complexity theory is to encode a search problem as a *partition function*: a weighted count over all configurations. Sometimes such counts, apparently exponential sums, collapse to something computable in polynomial time — this is what **holographic algorithms** and the matchgate machinery of the last two decades achieve. If factoring could be phrased as a constraint-satisfaction problem whose partition function collapses, factoring would collapse with it.

Factoring can indeed be phrased that way: let the variables be the bits of a candidate factor, and impose the constraint that the candidate multiplies to $N$. Now compute the partition function $Z$ — the number of satisfying configurations, i.e. the number of divisor pairs. Here is what you get.

> **Constant Partition Function Theorem.** For any two distinct primes $p, q$, the number $N = pq$ has exactly four divisors, so the divisor-pair count is
> $$Z = \tau(N) = 4$$
> for **every** semiprime, independently of $p$ and $q$.

And therefore:

> **No-Locating Corollary.** There is no function $f$ with $f(\tau(pq)) = p$ for all primes $p < q$. Indeed $15 = 3 \cdot 5$ and $35 = 5 \cdot 7$ have the same divisor count $4$ but different smallest factors, so $f(4)$ would have to be both $3$ and $5$.

This is a triviality to prove and yet it is exactly the right triviality. It says that the partition function of the factoring CSP is a *constant function of the input*. It has zero bits of information about $p$. Making it computable in polynomial time (which it already is: it is $4$) buys nothing at all.

What actually carries the information is not the value of $Z$ but the *address* of the satisfying configurations — quantities like "is the nontrivial small divisor congruent to $1$ modulo $4$?" These are the marginals of the distribution, not its normalization. And any marginal you can compute cheaply from $N$ alone is, by definition, a function of $N$ alone, so it tells you what you already knew; any marginal that genuinely depends on $p$ requires knowing $p$. Counting collapses; locating does not.

---

## An energy landscape with no slope

Third attack: physics. Encode factoring as the ground-state problem of an energy function,
$$E(a, b) = (N - ab)^2,$$
and let a machine find the minimum. This is exactly the strategy behind proposals to factor with **tensor networks** (build a parent Hamiltonian whose ground state is the factor state) and with **optical Ising machines** or **coherent Ising machines** (encode the bits of $a$ in the phases of optical modes and let the physics relax).

Two theorems finish these off.

> **Ground-Space Theorem.** For $N = pq$ with $p, q$ prime, the zero set of $E$ is exactly the four-point divisor set
> $$\{(1, N),\; (p, q),\; (q, p),\; (N, 1)\},$$
> and it has exactly four elements when $p \ne q$.

> **Spectral Gap / No-Gradient Theorem.** If $ab \ne N$ then $E(a,b) \ge 1$. There is no configuration of intermediate energy: the landscape is a flat plateau punctured by four zero-energy spikes.

Both are elementary — the first because a divisor of $pq$ is one of $1, p, q, pq$; the second because $E$ takes integer values and a nonzero square of an integer is at least $1$ — and together they are fatal to the physical proposals. A relaxation dynamic, whether a gradient descent, a simulated annealer, or an optical mode competition, needs a landscape with slope: it must be able to tell "warmer" from "colder". Here $E(a,b) = 1$ whether $ab$ misses $N$ by one or by a million (up to a squaring, which is monotone but conveys nothing about *direction*), and the four minima are isolated delta spikes in a space of $N^2$ configurations. A random restart hits a minimum with probability $4/N^2$; restricting to the $\sqrt N$-sized window and looking only for the nontrivial factor, the hit probability is the random divisor density $2/\sqrt{N}$ — precisely what unstructured search over the window would give.

The same accounting kills the tensor-network version from another direction. The state $|p\rangle |q\rangle$ that encodes the factorization is a **product state**: as a bipartite tensor it has rank one, so its entanglement entropy is exactly zero. There is nothing for the bond dimension of a tensor network to represent. Tensor networks are a compression tool for correlated states; when the target state has no correlations, they compress nothing and the cost of the problem reappears, unchanged, as the cost of *searching* for the ground state. The physics changed; the counting did not.

---

## The census, and the shuffle

The last attack is the subtlest and it is where the tropical geometry stops being a metaphor.

For $N = pq$ with $p, q$ distinct odd primes, the multiplicative group modulo $N$ splits, by the Chinese Remainder Theorem, as a product of two cyclic groups of orders $p-1$ and $q-1$. Its **torsion census** is the function
$$T(k) = \#\{x \bmod N : x^{2^k} \equiv 1\}.$$
This is computable in the sense that it has a clean closed form. Write $a = v_2(p-1)$ and $b = v_2(q-1)$ for the number of times $2$ divides $p-1$ and $q-1$ (the "2-adic levels"). Then:

> **Exact Census Theorem.** For distinct primes $p, q$,
> $$T(k) = 2^{\,\min(k,a) + \min(k,b)}, \qquad a = v_2(p-1),\; b = v_2(q-1).$$

Now look at that exponent through tropical spectacles. In the min-plus semiring, $\min(k,a) + \min(k,b)$ is literally the value at $X = k$ of the tropical quadratic
$$(X \oplus a) \odot (X \oplus b).$$
The census exponent *is* a tropical polynomial, and $a$ and $b$ are its **tropical roots**: expanding the product into monomials $2X$, $\min(a,b) + X$, and $a+b$, the minimum is attained twice exactly at $X = a$ and $X = b$. The census is a piecewise-linear concave function of $k$ whose two corners sit at the two 2-adic levels. Its slope on $[k, k+1]$ counts how many of $a, b$ still exceed $k$; the drop in slope at a point counts the multiplicity of that point as a root.

This is a genuinely informative object — it recovers the unordered pair $\{a, b\}$ exactly, and that is a real arithmetic fingerprint of $N$. It just is not enough.

> **Census Sealing Theorem.** No function of the entire census $k \mapsto T(k)$ returns the smaller prime factor. The semiprimes $21 = 3 \cdot 7$ and $77 = 7 \cdot 11$ have *identical* censuses for every $k$ — both have $\{a,b\} = \{1,1\}$ — but their smaller factors are $3$ and $7$.

One might hope to rescue the attack by using all exponents, not just powers of two: the full **torsion profile** $d \mapsto \#\{x : x^d \equiv 1 \bmod N\} = \gcd(p-1, d) \cdot \gcd(q-1, d)$. It fails, and the reason is exquisitely tropical. At each prime $\ell$, the profile sees only the *multiset* $\{v_\ell(p-1),\, v_\ell(q-1)\}$ of local valuations — never which factor carries which. So you may **shuffle the roots** between $p$ and $q$, independently at each prime, and the profile does not move.

> **Root-Shuffling Theorem.** If the pairs $(m_1, n_1)$ and $(m_2, n_2)$ carry the same multiset of $\ell$-adic valuations at every prime $\ell$, then $\gcd(m_1, d)\gcd(n_1,d) = \gcd(m_2,d)\gcd(n_2,d)$ for every $d$.
>
> **Full-Profile Sealing Theorem.** Consequently $N = 35 = 5 \cdot 7$ and $N = 39 = 3 \cdot 13$ have identical torsion profiles at *every* exponent $d$ — the pairs $(p-1, q-1)$ are $(4,6)$ and $(2,12)$, which differ only by swapping the $2$-adic valuations $2$ and $1$ between the two slots — and hence no functional of the whole profile can return a prime factor.

The same analysis extends verbatim to any squarefree modulus $N = \prod_{p \in S} p$: the census becomes $T(k) = 2^{\sum_{p} \min(k, v_2(p-1))}$, the exponent is the degree-$r$ tropical polynomial $\bigodot_{p \in S} (X \oplus v_2(p-1))$, and the multiplicity of $k+1$ as a tropical root is exactly the number of prime factors with $v_2(p-1) = k+1$, read off as a second difference of the census exponent. One consequence is a perfect miniature of the constant-partition-function phenomenon: for any odd squarefree $N$ with $r$ prime factors, $T(1) = 2^r$ *always*. The level-one census depends only on how many primes there are, never on which ones.

---

## What the failures have in common

Five attacks, five different technologies — sparse recovery, holographic counting, tensor networks, optical machines, group-theoretic censuses — and one shared fate.

**Every exotic resource pays the same bill in a different currency.** The compressed-sensing measurement matrix, the optical machine's mode volume, the tensor network's bond dimension, and the census's enumeration each carry the $\sqrt N$ or $N$ witness count in disguise. The resource changes the physics; it does not change the counting.

**What is symmetric cannot single out.** The census, the profile, the partition function are all invariant under exchanging $p$ and $q$, and the profile is invariant under a much larger shuffling group besides. Any invariant of a symmetry that mixes $p$ with $q$ is, by construction, blind to which is which. The theorems above are all, at bottom, exhibitions of that blindness: two different numbers, one identical invariant.

**Counting is trivial; locating is hard.** The partition function is $4$. The energy gap is $1$. The signal has two spikes. The census is a tropical quadratic with two known roots. All of that is exact, provable, and free — and the factor is still hiding at an address none of it reveals.

There is something clarifying about a negative result of this shape. It does not say "we tried and failed." It says: here is the precise quantity your method computes, here is a proof that it takes the same value on two numbers with different factorizations, and therefore your method cannot possibly work, no matter how it is implemented. The tropical corner at $\sqrt N$, and the little concave piecewise-linear census curve with its two corners at $v_2(p-1)$ and $v_2(q-1)$, are pictures of exactly how much arithmetic will tell you for free — and exactly where the free information stops.
