# The Hidden Music of $3n+1$

## How moving Fourier analysis into the 2-adic world turns a famous heuristic into a theorem

### A problem that eats mathematicians

Pick a whole number. If it is even, halve it. If it is odd, triple it and add one. Repeat.

Start with $7$ and you get $7, 22, 11, 34, 17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1$ — a climb to $52$, a long tumble, and then the trap: $1 \to 4 \to 2 \to 1$ forever. The **Collatz conjecture** says every starting number ends up in that trap. It has been checked for every integer below roughly $2^{68}$. It has resisted eighty years of attack. Paul Erdős is supposed to have said that mathematics is not yet ripe for such problems.

Everyone who plays with the problem for an afternoon discovers the same heuristic. Watch the *parities*, not the numbers. When $n$ is even, one step divides by $2$. When $n$ is odd, $3n+1$ is even, so the odd step is really two steps: $n \mapsto (3n+1)/2$, which multiplies by roughly $3/2$. If odd and even steps alternate "at random," each with probability $\tfrac12$, then over $k$ steps a number is multiplied by roughly
$$\left(\frac{3}{2}\right)^{k/2}\left(\frac{1}{1}\right)^{k/2} \cdot \text{(halvings)} \;=\; \left(\frac{\sqrt 3}{2}\right)^{k} \approx (0.866)^k .$$
Numbers shrink, geometrically, by about $13.4\%$ per step. Of course they fall into the trap.

That argument has one problem: it is not an argument. The Collatz map is a *deterministic* function. There are no coin flips. Nothing is random. The heuristic is a story we tell about a process that has no randomness in it whatsoever.

This article is about the discovery that the story is *literally true* — not approximately, not on average over some imagined ensemble, but as an exact arithmetic identity — provided you look at the problem through the right lens. The right lens is Fourier analysis. And the crucial move is to perform that Fourier analysis in the **2-adic** world rather than the ordinary one.

---

### The wrong Fourier transform

The natural first attempt is to build an exponential sum out of the Collatz map directly:
$$F(\omega) \;=\; \sum_{n=1}^{N} e^{2\pi i\, \omega\, T(n)},$$
where $T$ is the Collatz map, and to hope for a *spectral gap*: a proof that $|F(\omega)|$ is small — say, of size $\sqrt N$ — for every frequency $\omega$ away from zero. A spectral gap of that kind is exactly what one needs to make an equidistribution argument work.

This hope is doomed, and it is worth understanding why, because the reason points to the fix. The function $\omega \mapsto F(\omega)$ is a finite sum of continuous functions, hence continuous; and at $\omega = 0$ every term is $1$, so $F(0) = N$. Continuity then forces $|F(\omega)|$ to be arbitrarily close to $N$ for all $\omega$ in a small neighbourhood of $0$ — and that neighbourhood contains irrational frequencies, which no "away from zero" condition can exclude. There is no gap. There cannot be.

The obstruction is that the frequency variable lives on the ordinary real line: the *archimedean* world, where the whole point is that numbers can be close to each other continuously. But the Collatz map is not an archimedean object. Its entire structure is about divisibility by $2$. Asking about it in archimedean frequencies is like asking about a piano chord by measuring the weight of the piano.

So: change the group. Replace the real frequency by a **2-adic** frequency, and Fourier-analyse on the finite group $\mathbb{Z}/2^k\mathbb{Z}$.

---

### The parity word

Accelerate the map, once and for all. Define
$$T(n) = \begin{cases} n/2, & n \text{ even},\\[2pt] (3n+1)/2, & n \text{ odd}.\end{cases}$$
On even inputs this is one classical Collatz step; on odd inputs it is two, since $3n+1$ is automatically even. Nothing is lost — the orbits are the same, just with the forced halvings folded in.

Now run $n$ for $k$ steps and record only the parities. Write $b_j(n) \in \{0,1\}$ for the parity of the $j$-th iterate $T^{j}(n)$, and pack these bits into a single number
$$w_k(n) \;=\; \sum_{j=0}^{k-1} b_j(n)\, 2^{j} \;\in\; \{0,1,\dots,2^k-1\},$$
the **parity word** of $n$ at scale $k$. Let $s_k(n) = b_0(n)+\cdots+b_{k-1}(n)$ be the number of odd steps — the **odd-step count**.

Two facts make the parity word the right object, and both come from a single computation.

**The transport formula.** For all $n, m \ge 0$,
$$T^{k}\!\left(n + 2^k m\right) \;=\; T^{k}(n) \;+\; 3^{\,s_k(n)}\, m,$$
and moreover the first $k$ parity bits of $n + 2^k m$ are the same as those of $n$.

Read that slowly, because it is the whole engine. It says the $k$-fold Collatz map, restricted to a single residue class modulo $2^k$, is an **affine map** — a straight line — with slope exactly $3^{\,s_k(n)}/2^k$. The chaotic-looking Collatz dynamics is, at every 2-adic scale, a *union of $2^k$ straight lines*, and the slope of each line is a pure power of $3$ over a pure power of $2$. It follows immediately that the parity word of $n$ depends only on $n \bmod 2^k$: it is a genuine function on the finite group $\mathbb{Z}/2^k\mathbb{Z}$.

**The bit-flip lemma.** Adding $2^k$ to $n$ flips the $k$-th parity bit, and nothing before it.

Why? Because the transport formula gives $T^{k}(n + 2^k) = T^{k}(n) + 3^{\,s_k(n)}$, and $3^{s}$ is *odd*. Adding an odd number changes parity. That is the entire proof — and it is the hinge on which everything else turns, because it is what makes the parity map injective.

---

### The theorem: perfect cancellation

Injectivity plus counting gives the structure theorem.

> **Parity-Word Bijection Theorem.** For every $k$, the map $n \mapsto w_k(n)$ is a bijection from $\{0, 1, \dots, 2^k - 1\}$ onto itself. Every one of the $2^k$ binary words of length $k$ occurs as the parity prefix of exactly one residue class modulo $2^k$.

Now do Fourier analysis with this. Define the **Collatz parity transform** at scale $k$ and frequency $j$:
$$F_k(j) \;=\; \sum_{n=0}^{2^k - 1} e^{2\pi i\, j\, w_k(n) / 2^k}.$$

> **Exact Spectral Gap Theorem.** $F_k(0) = 2^k$, and $F_k(j) = 0$ for every $j \not\equiv 0 \pmod{2^k}$.

Because $w_k$ permutes $\{0,\dots,2^k-1\}$, the sum re-indexes into $\sum_{w} z^{w}$ with $z = e^{2\pi i j/2^k} \ne 1$ a root of unity — a complete geometric series, which sums to zero on the nose. Parseval reads $\sum_j |F_k(j)|^2 = 4^k$: **all** the spectral energy sits at the DC frequency and none anywhere else.

This is not a spectral *gap* in the usual sense of "small." A random collection of $2^k$ unit vectors would sum to something of size about $2^{k/2}$; the classic ambition in analytic number theory is to prove square-root cancellation. Here the cancellation is *total*. The archimedean transform had no gap at all; the 2-adic transform has an infinite one.

---

### Cashing in: the coin flips are real

Perfect equidistribution of parity words means the odd-step count $s_k$ is *exactly* binomially distributed. Concretely, for every number $x$ whatsoever,
$$\sum_{n=0}^{2^k - 1} x^{\,s_k(n)} \;=\; (1+x)^k .$$
The number of residues mod $2^k$ with exactly $s$ odd steps is exactly $\binom{k}{s}$. The coin-flip heuristic is not a heuristic. It is an identity.

Three consequences fall out by plugging in values of $x$ and differentiating.

**The mean.** $s_k$ has mean exactly $k/2$: over a complete residue system, $2\sum_n s_k(n) = k\,2^k$.

**The variance.** $\displaystyle\sum_{n<2^k} \bigl(2 s_k(n) - k\bigr)^2 = k \, 2^k$, i.e. the variance is exactly $k/4$ — precisely that of $k$ fair coin flips.

**Criticality.** Setting $x = 3$ gives $\sum_{n<2^k} 3^{\,s_k(n)} = 4^k$. The multiplier attached to the residue class of $n$ is $3^{s_k(n)}/2^k$, so its **arithmetic mean is exactly $1$**, for every $k$, with no error term. The Collatz map is a perfectly critical multiplicative process — no drift at all in the arithmetic mean.

And yet: the *geometric* mean is not $1$. Take logarithms. Define the **contraction exponent** of a class as $\Lambda_k(n) = k\log 2 - s_k(n)\log 3$, which is positive exactly when the multiplier $3^{s}/2^{k}$ is less than $1$. Averaging over residues,
$$\frac{1}{2^k}\sum_{n<2^k} \Lambda_k(n) \;=\; k\left(\log 2 - \tfrac12 \log 3\right) \;=\; k \log\frac{2}{\sqrt3} \;>\; 0 .$$
The geometric mean multiplier is exactly $(\sqrt3/2)^k \approx (0.866)^k$. The heuristic's magic number, derived exactly.

This is the familiar gap between arithmetic and geometric means, and it is the actual mathematical content of "Collatz orbits shrink." The average multiplier is $1$; the *typical* multiplier is $0.866^k$. The mean is dragged up to $1$ by a vanishingly small set of catastrophically expanding classes — and those classes really exist. At every scale $k$ there is a residue class whose first $k$ steps are *all odd* (multiplier $(3/2)^k$, exponent strictly negative) and one whose first $k$ steps are all even (multiplier $2^{-k}$, exponent the maximum $k\log 2$). No pointwise theorem is possible. Only a density theorem.

---

### How rare is bad behaviour?

A class fails to contract when $3^{\,s_k(n)} \ge 2^k$, i.e. when $s_k(n) \ge k\theta$ with the **critical density**
$$\theta = \frac{\log 2}{\log 3} \approx 0.63093 .$$
Since the mean is $k/2$, a failing class must deviate from the mean by at least $k\delta$, where the **spectral margin** is
$$\delta = \theta - \tfrac12 \approx 0.13093 ,$$
positive precisely because $\log 3 < 2\log 2$. Everything now reduces to a large-deviation estimate for an exactly binomial variable — and we have all its moments exactly.

Chebyshev's inequality, fed the exact variance, gives immediately:

> **Density-One Contraction Theorem.** The proportion $\rho_k$ of residue classes mod $2^k$ that fail to contract over their first $k$ steps satisfies $\rho_k \le \dfrac{1}{4\delta^2 k} \approx \dfrac{14.58}{k}$, and hence tends to $0$.

Almost every residue class contracts. But the exact generating function encodes *all* moments, not just the second, so we can do far better with a Chernoff argument. Set $x=2$ to get $\sum_{n<2^k} 2^{\,s_k(n)} = 3^k$. On the failing set, $3^s \ge 2^k$ forces the purely integer inequality $5s \ge 3k$ (this is just $27 \le 32$ in disguise — the arithmetic shadow of $\theta > 3/5$). Markov's inequality then yields $|B_k|^5 \cdot 8^k \le 243^k$, that is:

> **Exponential Decay Theorem.** $\rho_k^{\,5} \le \left(\dfrac{243}{256}\right)^{k}$; the non-contracting density decays exponentially, at rate at most $(243/256)^{1/5} \approx 0.98963$ per scale.

---

### From residue classes to actual integers

All of this is still about residues. The transport formula converts it into a statement about honest numbers, because on each class the $k$-step map is that straight line of slope $3^{s}/2^{k}$: if the slope is less than $1$, the line eventually dips below the diagonal, and a crude uniform bound $T^{k}(x) \le 2^k x$ pins down where.

> **Uniform Descent Theorem.** If $r = n \bmod 2^k$ satisfies $3^{\,s_k(r)} < 2^k$ and $n \ge 8^k$, then $T^{k}(n) < n$.

Combining with the density bounds: the proportion of residue classes on which the $k$-step map is strictly decreasing above the explicit threshold $8^k$ is at least $1 - 1/(4\delta^2 k)$, which tends to $1$.

Finally, counting integers by size rather than by residue class — each class mod $2^k$ meets $[1,N]$ in at most $N/2^k + 1$ points, and the finitely many exceptions below $8^k$ contribute nothing in the limit:

> **Natural-Density Descent Theorem.** For every $\varepsilon > 0$ there is a scale $k$ such that, for all sufficiently large $N$, fewer than an $\varepsilon$-fraction of the integers $n \le N$ fail to satisfy $T^{k}(n) < n$.

Quantitatively, counting up to $N = 64^k$, the failure density is at most $\rho_k + 2\cdot 8^{-k}$, so it is exponentially small in $k$: both the spectral term and the boundary correction vanish geometrically.

---

### What this does and does not prove

It does not prove the Collatz conjecture, and it is important to be honest about the gap. Every statement here is about the *first $k$ steps*. Descent for $k$ steps, on a density-one set, does not compose: after descending, an integer lands somewhere new, and there is no control over which residue class it lands in. Chaining infinitely many density-one events is exactly the step that no one knows how to take. A single exceptional orbit — one number whose residues conspire, at every scale, to sit inside the shrinking bad set — would refute the conjecture without contradicting anything above.

What it *does* do is convert folklore into mathematics. "Collatz parities behave like coin flips" is no longer a plausibility argument; it is the statement that the parity map is a bijection of $\mathbb{Z}/2^k\mathbb{Z}$, and hence that $\sum_n x^{s_k(n)} = (1+x)^k$ exactly. Every downstream constant — the drift $\log(2/\sqrt3)$, the critical density $\log 2/\log 3$, the margin $\delta \approx 0.131$, the Chebyshev constant $14.58$, the exponential rate $0.98963$ — is now a computed quantity rather than an estimate.

And there is a broader lesson, one that recurs across number theory. When a Fourier-analytic approach fails, the failure is often not in the method but in the group. The Collatz map lives on the 2-adics; ask it archimedean questions and it answers with noise. Ask it 2-adic questions and it answers with perfect silence at every nonzero frequency — a chord that cancels itself completely, and in that silence the shape of the problem becomes visible.

Whether that visibility ever extends to a proof of the conjecture is, of course, another matter. The next frontier is sharpening the large-deviation rate to its true value $e^{-D(\theta\|1/2)} \approx 0.9659$ — the exact Kullback–Leibler cost of biasing a fair coin to land heads a fraction $\theta$ of the time — and shrinking the descent threshold from $8^k$ down to $O(1)$, which numerical evidence strongly suggests is the truth. Neither would prove Collatz. Both would tell us, with more precision than we have now, exactly how narrow the escape hatch would have to be.
