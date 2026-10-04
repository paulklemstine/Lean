# Two Primes Out of Thousands: Why the "Broken" Primes Don't Matter

*How a two-thousandths-of-a-bit anomaly became a theorem about information, sampling, and the cost of a few odd data points.*

---

## A tiny number that wanted an explanation

Take the polynomial $x^2 - 3$ and reduce it modulo a prime $p$. Three things can happen.

- The polynomial **splits**: it factors into two distinct linear pieces, because $3$ has a square root modulo $p$. This happens for $p = 11$, where $5^2 = 25 \equiv 3$.
- It stays **inert**: it cannot be factored at all. This happens for $p = 5$, since no square is $3$ modulo $5$.
- It **ramifies**: the two roots collide into a double root. Modulo $2$ we get $x^2 - 3 \equiv (x+1)^2$, and modulo $3$ we get $x^2$. These are the only two such primes, and they are exactly the primes dividing the discriminant $12$.

Number theorists call this pattern the **splitting type** of $p$. For $x^2 - 3$ a classical fact, quadratic reciprocity, says that for every prime other than $2$ and $3$ the splitting type depends only on $p \bmod 12$. The polynomial splits when $p \equiv \pm 1 \pmod{12}$ and stays inert when $p \equiv \pm 5 \pmod{12}$. Dirichlet's theorem says the four classes $1, 5, 7, 11$ get equal shares of primes in the long run, so the type is split or inert with probability one half each. Knowing $p \bmod 12$ tells you the type exactly.

In information-theoretic language, the residue $p \bmod 12$ carries **exactly one bit** of information about the splitting type.

A long-running computational programme measured exactly this quantity for many polynomials and many moduli. It sampled thousands of primes, recorded each prime's residue and splitting type, and computed the empirical mutual information between the two. For $x^2-3$ on the unramified primes the answer came out $I = 1.0000$ bits, as theory predicts. When the two ramified primes $2$ and $3$ were put back in, it came out $I = 1.0020$ bits.

The difference is two thousandths of a bit, caused by two primes among thousands. Experimenters routinely throw the ramified primes away as "exceptional". This experiment asked whether doing so is safe. Could a handful of exceptional points ever distort an information measurement badly? The answer is a clean theorem, and it says no, with a precise price tag.

## The counting channel

First, let's say what "information between residue and type" means for a finite list of primes.

Take a finite sample $S$ of $N$ primes and two read-outs on it: a **type** $g(p)$ and a **residue** $k(p)$. Pick a prime from $S$ uniformly at random. Then $g$ and $k$ become random variables, and we can use Shannon's entropies:

- $H(g)$ is the uncertainty about the type;
- $H(g \mid k)$ is the uncertainty about the type that remains once you know the residue;
- $I(g;k) = H(g) - H(g \mid k)$ is the **mutual information**, the number of bits the residue reveals about the type.

We call this the **counting channel** of the sample. It is a purely combinatorial object: every probability is a count divided by $N$.

All three quantities can be written with a single gadget. For a read-out $f$, define the **fibre log-sum**

$$\Lambda_S(f) \;=\; \sum_{a \in S} \log_2 \bigl|\{x \in S : f(x) = f(a)\}\bigr| .$$

Each prime contributes the logarithm of the size of its "fibre", meaning the number of primes in the sample that look like it under $f$. If $f$ separates every prime, every fibre has size $1$ and $\Lambda = 0$. If $f$ is constant, every fibre is the whole sample and $\Lambda = N\log_2 N$. A short computation turns Shannon's formulas into

$$N \cdot I_S(g;k) \;=\; N\log_2 N \;-\; \Lambda_S(g) \;-\; \Lambda_S(k) \;+\; \Lambda_S(k,g),$$

where $(k,g)$ is the paired read-out. Every entropy becomes a sum of logarithms of fibre sizes, and that is the form we can estimate.

## What happens when you add a few odd points

Now split the sample into the **unramified** part $U$ and the **ramified** part $R$, with $|R| = r$ points out of $N$. We want to compare $I_{U\cup R}$, the channel on everything, with $I_U$, the channel after discarding $R$.

The key step is to see what adding $R$ does to each fibre log-sum. Call the change the **fibre defect**:

$$D(f) \;=\; \Lambda_{U\cup R}(f) - \Lambda_U(f) - \Lambda_R(f).$$

**The defect is never negative.** Merging two samples can only make fibres bigger, so each logarithm can only grow.

**The defect is small.** Think of an unramified prime whose fibre in $U$ has $u$ members, and suppose the ramified sample adds $\rho$ more. Its logarithm grows from $\log_2 u$ to $\log_2(u+\rho)$. The elementary inequality $\log(1+t)\le t$ caps the growth at $\rho/(u \ln 2)$. Now sum over the $u$ members of that fibre: the extra cost is at most $\rho/\ln 2$. Summing over all fibres, the $\rho$'s add up to at most $r$. So the unramified primes as a group pay at most $r/\ln 2$ extra bits, *no matter how large $N$ is*. Each of the $r$ ramified primes pays at most $\log_2 N$, since no fibre can be bigger than the whole sample. Altogether

$$0 \;\le\; D(f) \;\le\; r\Bigl(\log_2 N + \tfrac{1}{\ln 2}\Bigr).$$

The amortisation is the heart of the argument. Each unramified fibre feels the intruders only in proportion to how many land in it relative to its own size. A big fibre barely notices a few visitors. A small fibre can be shaken badly, but it has few members to pay the cost.

## The theorem

There is one more ingredient. Merging two populations has an entropy cost of its own, the **mixing term**

$$E \;=\; N\log_2 N - |U|\log_2|U| - r\log_2 r,$$

which is $N$ times the binary entropy of the ramified fraction $r/N$. It too lies between $0$ and $r(\log_2 N + 1/\ln 2)$. The fibre log-sum identity then gives an exact accounting:

$$N I_{U\cup R} \;-\; |U|\, I_U \;-\; r\, I_R \;=\; E \;-\; D(g) \;-\; D(k) \;+\; D(k,g).$$

In words, the information of the whole equals the size-weighted information of the parts, plus mixing, minus two fibre defects, plus one more. Every term on the right is caught between $0$ and $r(\log_2 N + 1/\ln 2)$, so the whole bracket has absolute value at most $2r(\log_2 N + 1/\ln 2)$. Finally, mutual information on any sub-sample lies between $0$ and $\log_2 N$, so the leftover cross term $r(I_R - I_U)$ costs at most $r\log_2 N$. Dividing by $N$:

> **Theorem (ramified contribution is negligible).** Let $U$ and $R$ be disjoint finite samples, with $N = |U \cup R|$ and $r = |R|$. For *every* pair of read-outs $g, k$,
> $$\bigl|\, I_{U\cup R}(g;k) - I_U(g;k) \,\bigr| \;\le\; \frac{r}{N}\Bigl(3\log_2 N + \frac{2}{\ln 2}\Bigr).$$

Nothing about polynomials, primes or Galois groups enters. The statement holds for any finite dataset, any labelling and any contamination set. It says that $r$ odd points can move a counting mutual information by at most about $3r\log_2 N/N$ bits.

Two consequences follow at once.

- **Exclusion is justified asymptotically.** For a fixed number $r$ of exceptional points, the bound tends to $0$ as $N \to \infty$. For every tolerance $\varepsilon > 0$ there is a sample size beyond which including or excluding the ramified primes changes the channel by at most $\varepsilon$ bits, uniformly over all read-outs.
- **The concrete regime.** With two ramified primes and at least $2^{16} = 65{,}536$ primes in the sample, the bound evaluates to about $0.00155$. So the change is **at most $0.002$ bits, guaranteed.**

## Checking it against the data

How does the bound compare with reality? Here is the residue-mod-12 channel for $x^2-3$, computed on all primes up to $X$:

| $X$ | primes $N$ | $I$ (all) | $I$ (unramified) | gap | proved bound |
|---:|---:|---:|---:|---:|---:|
| $10^3$ | 168 | 1.0787 | 0.9974 | +0.0813 | 0.2984 |
| $10^4$ | 1,229 | 1.0157 | 0.9999 | +0.0158 | 0.0548 |
| $10^5$ | 9,592 | 1.0026 | 1.0000 | +0.0026 | 0.0089 |
| $10^6$ | 78,498 | 1.0004 | 1.0000 | +0.0004 | 0.0013 |

The row for about ten thousand primes reproduces the reported "+0.002 bits". The gap always sits inside the bound, roughly a third of it, and both shrink at the same $\log N/N$ rate. That factor of about three matches a diagnosis of where the proof is loose. The three fibre defects are bounded as if they were independent, but they are correlated, and in practice they partly cancel.

Why does the gap come out *positive* here? The two ramified primes have new residues ($2$ and $3$ modulo $12$) and a new type ("ramified"). A residue of $2$ or $3$ pins down the ramified type perfectly, so these primes add a sliver of extra, perfectly predictable uncertainty. That nudges the information slightly upward.

## Can you do better than $\log N / N$?

One might hope the true effect is of order $r/N$, with no logarithm at all. It is not. Here is a configuration that shows the logarithm is real.

Give all $N - r$ unramified points **the same type**, and give each of the $r$ ramified points **its own private type**. Use the type as both read-outs, so the channel is $I(g;g) = H(g)$, the entropy of the type. On the unramified points alone the type is constant, so $I_U = 0$. With the ramified points included,

$$I_{U\cup R} \;=\; \log_2 N - \frac{N-r}{N}\log_2(N-r) \;\ge\; \frac{r}{N}\log_2 N .$$

> **Theorem (sharpness).** For every $r \le N$ there are a sample of $N$ points, $r$ of them ramified, and a read-out for which including the ramified points raises the channel by at least $\frac{r}{N}\log_2 N$ bits.

So the rate $\log N/N$ is the true rate, and only the constant in front ($3$ in the theorem, $1$ in the example) is still open. In the data the observed constant is close to $1$, and the natural conjecture is that $1$ is the right answer.

## The Galois picture

Behind the experiments sits a cleaner, idealised object. For a Galois extension with group $G$, Chebotarev's density theorem says Frobenius elements of unramified primes are equidistributed in $G$. The "ideal" channel is then the mutual information $I(\sigma;T)$ under the uniform distribution on $G$, where $\sigma$ records what the residue class sees of a group element and $T$ records its splitting type.

A balanced finite model of the unramified primes is a **fibre product**. It pairs residue data $a$ with group elements $h$ whenever they are compatible, with every group element matched equally often. Its counting channel equals the ideal Galois channel *exactly*. Combined with the main theorem, this gives:

> **Theorem (Galois channel with ramification).** Add any $r$ extra (ramified) points to a balanced fibre-product model containing $N$ points in total after the addition. The measured residue-to-type information differs from the ideal Galois-group information $I(\sigma;T)$ by at most $\frac{r}{N}\bigl(3\log_2 N + \frac{2}{\ln 2}\bigr)$.

In other words, any effective equidistribution result can be turned directly into an information estimate, and ramification costs only $O(\log N/N)$ on top.

## Why this matters beyond number theory

Real datasets often contain a few points that "don't follow the rules": sensor glitches, edge cases, mislabelled entries. Analysts discard them, and they often worry that doing so hides something. For any statistic built from counting mutual information, this result gives a worst-case guarantee. $r$ arbitrary points among $N$ can move the estimate by at most $\tfrac{r}{N}(3\log_2 N + 2.89)$ bits. The guarantee holds whatever those points are, even if they were chosen adversarially. It also shows that you cannot hope for better than $\tfrac{r}{N}\log_2 N$ in the worst case.

For the original question the verdict is plain. Two ramified primes among thousands add about two thousandths of a bit. That is exactly the size the theorem predicts, and it is provably harmless. Excluding the ramified primes is fully justified.
