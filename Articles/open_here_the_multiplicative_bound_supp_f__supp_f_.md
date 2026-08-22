# You Cannot Hide in Both Places at Once

## How a hundred-year-old fact about roots of unity gives the sharpest possible uncertainty principle — and hands us a recipe for perfect signal recovery

### A signal and its ghost

Take a string of $p$ numbers — a sound sample, a pixel row, a list of measurements — and think of it as a function $f$ on the clock $\mathbb{Z}/p\mathbb{Z}$, the integers modulo $p$. Alongside $f$ lives its shadow, the **discrete Fourier transform**
$$\hat f(k) \;=\; \sum_{x \bmod p} e^{-2\pi i k x/p}\, f(x),$$
which reports how much of each pure frequency $k$ the signal contains. The transform is a bijection: $f$ and $\hat f$ carry exactly the same information, packaged in two utterly different ways.

The two packagings are in tension. A signal concentrated at a single instant — a click, a delta spike — has a transform that is spread perfectly flat across all $p$ frequencies. A signal that is constant in time is a single spike in frequency. Squeeze a signal in time and it bulges in frequency. This is the *uncertainty principle*, the discrete cousin of Heisenberg's, and the crispest way to measure it is by counting **supports**: let $|\operatorname{supp} f|$ be the number of places where $f$ is nonzero, and $|\operatorname{supp}\hat f|$ the number of frequencies it actually uses.

The classical statement, true for every modulus $n$ and every nonzero $f$, is multiplicative:
$$|\operatorname{supp} f| \cdot |\operatorname{supp}\hat f| \;\ge\; n .$$
It is a beautiful inequality and it is not the whole story. When the modulus is **prime**, something dramatically stronger holds.

### The additive uncertainty principle

> **Theorem (additive uncertainty principle).** Let $p$ be prime and let $f : \mathbb{Z}/p\mathbb{Z} \to \mathbb{C}$ be nonzero. Then
> $$|\operatorname{supp} f| + |\operatorname{supp}\hat f| \;\ge\; p+1 .$$

Sums, not products. To feel the difference, set $p = 13$ and imagine a signal occupying $4$ time slots whose transform occupies $4$ frequencies. The multiplicative bound is perfectly content: $4 \cdot 4 = 16 \ge 13$. The additive bound annihilates it: $4 + 4 = 8$, far below $14$. **No such signal exists.** In fact the additive bound implies the multiplicative one whenever both supports are nonempty — if $\alpha + \beta \ge p+1$ with $\alpha,\beta \ge 1$, then $\alpha\beta \ge \alpha + \beta - 1 \ge p$ — so the sum bound is a strict strengthening, never a trade.

And the sum bound is *exactly* right. A delta spike at a point $c$ has $|\operatorname{supp} f| = 1$ and $|\operatorname{supp}\hat f| = p$: total $p+1$. The constant function reverses the roles: total $p+1$ again. But the sharpness runs far deeper than these two examples, and this is the part that still surprises me:

> **Theorem (exact converse).** Let $p$ be prime and let $A, B \subseteq \mathbb{Z}/p\mathbb{Z}$ be *any* two sets with $|A| + |B| = p+1$. Then there is a signal $f$ whose support is exactly $A$ and whose transform's support is exactly $B$.

Not "some sets of those sizes" — *every* pair of sets, in every position, of every admissible pair of sizes. The inequality $|\operatorname{supp} f| + |\operatorname{supp} \hat f| \ge p+1$ carves out a region of the plane, and every single point on its boundary is attained, by signals whose supports you may place wherever you like. There is nothing left to improve.

### Why primality is not decoration

It is tempting to think the primality hypothesis is a technical convenience. It is not; it is the whole mechanism. Consider $p$ replaced by $4$ and the signal $f = (1,0,1,0)$, the indicator of the even residues. Its transform is $(2,0,2,0)$. Both supports have size $2$, so the total is $4$, which is less than $4+1$. The additive bound is simply false modulo $4$. (The multiplicative bound survives: $2 \cdot 2 = 4$.)

That example is the tip of a complete classification. If $n = de$ with $d, e \ge 2$, take $f$ to be the indicator of the subgroup $d\mathbb{Z}/n\mathbb{Z}$, which has $e$ elements. A finite Poisson summation — really just a geometric series — gives
$$\hat f(k) = \begin{cases} e, & e \mid k,\\ 0, & \text{otherwise,}\end{cases}$$
so $\hat f$ is supported exactly on the annihilator subgroup, of size $d$. The two supports total $d + e$, which for $d, e \ge 2$ is at most $de = n$: the bound fails, and it fails by a margin that grows with how balanced the factorisation is. Combining this with the prime case gives a clean dichotomy.

> **Theorem (primality criterion).** For $n \ge 2$, the bound $|\operatorname{supp} f| + |\operatorname{supp}\hat f| \ge n+1$ holds for *every* nonzero $f : \mathbb{Z}/n\mathbb{Z} \to \mathbb{C}$ **if and only if** $n$ is prime.

Subgroups are the enemy of uncertainty. A signal that is the indicator of a subgroup is simultaneously sparse in time and sparse in frequency, because the transform of a subgroup is (a multiple of) its annihilator. Prime cyclic groups have no proper subgroups other than the trivial one — nowhere for a signal to hide.

### The engine: every minor of the Fourier matrix is invertible

Where does the extra strength come from? From a fact about the Fourier matrix itself that is startling the first time you meet it.

Write $\zeta = e^{-2\pi i/p}$ and form the $p \times p$ matrix $M$ with entries $M_{x,y} = \zeta^{xy}$. Choose any $k$ rows and any $k$ columns — any at all, in any positions — and look at the resulting $k \times k$ block.

> **Theorem (Chebotarev, 1926).** For $p$ prime, every square submatrix of $(\zeta^{xy})_{x,y}$ has nonzero determinant.

This "total nonsingularity" is spectacular and it is special to prime order. Modulo $4$, the $2\times 2$ block of rows $\{0,2\}$ and columns $\{0,2\}$ is $\begin{pmatrix}1&1\\1&1\end{pmatrix}$: singular. Modulo a prime, no configuration of rows and columns can produce a degeneracy.

Once you have Chebotarev, the uncertainty principle is three lines. Suppose $f \neq 0$ and $|\operatorname{supp} f| + |\operatorname{supp}\hat f| \le p$. Write $A = \operatorname{supp} f$, so the complement of $\operatorname{supp}\hat f$ has at least $|A|$ elements; pick $|A|$ of them and call the set $R$. Then $\hat f$ vanishes on $R$, which says precisely that the vector $(f(x))_{x \in A}$ lies in the kernel of the square submatrix with rows $R$ and columns $A$. That matrix is invertible, so $f$ vanishes on $A$ — that is, $f = 0$. Contradiction.

### Frenkel's proof: watching a polynomial vanish

Chebotarev's theorem has several proofs; the most elementary — and the one that can be carried out with nothing but determinants, binomial coefficients and one fact about cyclotomic polynomials — is Péter Frenkel's. It is a lovely piece of mathematical accounting, and it goes like this.

Fix distinct residues $a_1,\dots,a_k$ and $b_1,\dots,b_k$ in $\{0,1,\dots,p-1\}$, and *promote the root of unity to a variable*: consider the integer polynomial
$$F(X) \;=\; \det\!\left(X^{\,a_i b_j}\right)_{i,j}.$$
Our determinant is $F(\zeta)$, and we want to prove it is nonzero. Suppose it vanishes. Since $\zeta$ is a primitive $p$-th root of unity, its minimal polynomial $\Phi_p(X) = 1 + X + \cdots + X^{p-1}$ must divide $F$.

Now shift: let $G(X) = F(X+1)$. Two things about $G$ are decisive.

**First**, $G$ vanishes to a precise order at $0$. Expanding the determinant, the coefficient of $X^d$ in $G$ is $\sum_\sigma \operatorname{sgn}(\sigma)\binom{\,\sum_i a_{\sigma(i)}b_i\,}{d}$, a signed sum of binomial coefficients. Converting binomials into powers via the falling factorial $X(X-1)\cdots(X-d+1)$, this coefficient is a combination of the *alternating power sums*
$$T_r \;=\; \sum_{\sigma} \operatorname{sgn}(\sigma)\Big(\sum_i a_{\sigma(i)} b_i\Big)^{r}.$$
Expand $T_r$ multinomially and you get a sum over exponent vectors $m = (m_1,\dots,m_k)$ with $\sum m_i = r$, each term carrying a determinant $\det(a_i^{m_j})$. If two entries of $m$ coincide, that determinant has two equal columns and dies. So only *injective* $m$ survive — and an injective vector of nonnegative integers has sum at least $0 + 1 + \cdots + (k-1) = N$, where $N = \binom{k}{2}$. Therefore $T_r = 0$ for all $r < N$, and every coefficient of $G$ below degree $N$ vanishes.

**Second**, the first surviving coefficient is computable, and it is a product of two Vandermonde determinants. At $r = N$ the only surviving exponent vectors are the permutations of $(0,1,\dots,k-1)$; each contributes $\pm$ a Vandermonde determinant, the signs conspire, and the multinomial coefficients collapse to $N!/\prod_{j<k} j!$. The bookkeeping ends at the identity
$$\Big(\prod_{j<k} j!\Big)\, G_N \;=\; V(a)\, V(b), \qquad V(a) = \prod_{i<j}(a_j - a_i),$$
where $G_N$ is the $N$-th coefficient of $G$.

Now spring the trap. Because $\Phi_p(X) \mid F(X)$, we get $\Phi_p(X+1) \mid G(X)$. The constant term of $\Phi_p(X+1)$ is $\Phi_p(1) = p$. Trailing coefficients multiply, and $G$'s trailing term sits exactly in degree $N$; hence $p$ divides $G_N$, and therefore $p$ divides $V(a)V(b)$. But $V(a)$ is a product of differences $a_j - a_i$ of *distinct* residues drawn from $\{0,\dots,p-1\}$ — each such difference is nonzero and smaller than $p$ in absolute value, so none is divisible by $p$, and neither is the product. Contradiction. $\blacksquare$

The elegance is in the choreography: the shift $X \mapsto X+1$ converts "$\zeta$ is a root" into "$p$ divides a particular integer", and the combinatorics of injective exponent vectors identifies that integer as a Vandermonde product that primality forbids $p$ from dividing.

### From an inequality to an algorithm

Uncertainty principles look like prohibitions, but a prohibition on where information can hide is a licence to *recover* it. This is the philosophy behind compressed sensing, and in the prime cyclic setting it takes an unusually clean and completely deterministic form.

> **Theorem (sparse recovery).** Let $p$ be prime and let $f, g$ be signals each supported on at most $k$ points. If $\hat f$ and $\hat g$ agree on *any* set $S$ of $2k$ frequencies, then $f = g$.

The proof is one line of the uncertainty principle: $h = f - g$ has at most $2k$ nonzero entries, and $\hat h$ vanishes on $S$, so $|\operatorname{supp}\hat h| \le p - 2k$; the supports total at most $p$, and hence $h = 0$.

The word *any* is what makes this remarkable. In generic compressed-sensing theorems, one must sample at random and accept a failure probability, or verify a restricted-isometry condition. Here, every sampling pattern of size $2k$ works, with certainty, for every $k$-sparse signal. And the threshold cannot be lowered:

> **Theorem (threshold sharpness).** For every $k \ge 1$ with $2k \le p$ and *every* set $S$ of $2k-1$ frequencies, there exist distinct $k$-sparse signals $f \neq g$ with $\hat f = \hat g$ on $S$.

So $2k$ measurements suffice, always, and $2k-1$ never do. There is no pattern-dependent middle ground.

The same total nonsingularity yields an interpolation theorem that reads like a Fourier-analytic Lagrange interpolation:

> **Theorem (Fourier interpolation).** Let $p$ be prime and $A, B \subseteq \mathbb{Z}/p\mathbb{Z}$ with $|A| = |B|$. For any prescribed values $g(k)$, $k \in B$, there is exactly one signal $f$ vanishing outside $A$ with $\hat f(k) = g(k)$ for all $k \in B$.

Two inequality regimes fall out. If $|B| \le |A|$, prescribed frequency data on $B$ can always be matched by a signal living on $A$ (existence). If $|A| \le |B|$, the frequency data on $B$ determines such a signal completely (uniqueness). The square case is both at once. Stated in the language of matrices: **every** rectangular $A \times B$ block of the prime Fourier matrix has the maximum possible rank $\min(|A|,|B|)$ — total nonsingularity in rank form.

There is even a "fundamental theorem of algebra" hiding here: for nonzero $f$, the number of frequencies at which $\hat f$ vanishes is *strictly less* than the number of time samples where $f$ is nonzero. A signal built from $k$ spikes has a spectrum with at most $k-1$ zeros — exactly the way a polynomial of degree $k-1$ has at most $k-1$ roots. That analogy is not decoration: the Fourier transform of a $k$-sparse signal *is* an exponential polynomial with $k$ terms, and total nonsingularity is the statement that such polynomials cannot vanish too often.

### What to take away

Three ideas, tightly linked.

*First*, arithmetic controls analysis. Whether a signal can be simultaneously sparse in time and in frequency depends on whether the modulus factors. Subgroups are hiding places, and primes have none.

*Second*, rigidity is a resource. "Every minor is invertible" sounds like a curiosity about a specific matrix; it is in fact the precise reason why $2k$ arbitrary frequency measurements pin down a $k$-sparse signal with no randomness, no genericity assumption, and no failure probability.

*Third*, sharp theorems come with sharp converses. The additive bound is not merely tight in a couple of extremal examples: every admissible pair of support sets, in every position, actually occurs. When a boundary is entirely attained, you know the inequality has captured exactly the right phenomenon — and that is a rarer kind of certainty than most inequalities in analysis ever achieve.
