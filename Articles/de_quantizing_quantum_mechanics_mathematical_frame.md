# The Comb That Refuses to Be Compressed

## Why one particular quantum state blocks the classical shortcut to breaking RSA

For thirty years, the story of quantum computing has been told through a single
punchline: a quantum machine can factor large integers quickly, and classical
machines cannot. Every prediction about the collapse of internet cryptography,
every "harvest now, decrypt later" warning, every national roadmap for
post-quantum standards traces back to one algorithm and one subroutine inside
it — the quantum Fourier transform acting on a superposition of exponentially
many numbers at once.

But the story has developed a subplot. Over the last decade, a stream of results
has *de-quantized* quantum algorithms: taken a quantum procedure advertised as
exponentially faster and shown that, under the structural assumptions the
quantum algorithm secretly needs, a classical algorithm does just as well.
Recommendation systems, low-rank matrix inversion, principal component analysis —
one after another, the promised exponential speedups turned out to hinge on the
data being *low-rank*, and low-rank data is something classical randomized
algorithms devour happily.

That raises an obvious and slightly dangerous question. Is the quantum Fourier
transform inside the factoring algorithm also de-quantizable? Is the state it
acts on secretly simple?

This article answers that question with a formula. The answer is no — and the
reason is a small piece of arithmetic that anyone can check by hand.

---

## Where the exponential hides

Let us set the stage precisely, because the whole argument turns on being
precise.

A register of $L$ bits holds one of $n = 2^L$ values. A quantum state of that
register is a list of $n$ complex numbers, the *amplitudes*, one for each value
$x \in \{0, 1, \dots, n-1\}$. That is where the exponential lives: to write the
state down naively costs $2^L$ numbers, which for $L = 2048$ is more numbers
than there are atoms in the observable universe.

Classical simulation of quantum systems does not, however, always pay that
price. The workhorse tool — the *matrix product state*, also called a *tensor
train* — exploits the fact that most physically relevant states are far from
generic. Cut the register into a left block of $a$ bits and a right block of $b$
bits, with $a + b = L$. Write $P = 2^a$ and $Q = 2^b$, so $n = PQ$, and read
each index $x$ as a pair: $x = pQ + q$ with $0 \le p < P$ and $0 \le q < Q$. The
amplitude list, which was a vector of length $n$, becomes a $P \times Q$ matrix
$M$.

Now ask: what is the **rank** of that matrix? If the rank is $D$, then $M$
factors as a $P \times D$ matrix times a $D \times Q$ matrix — meaning the state
can be stored and manipulated as two small blocks glued along an index of size
$D$, rather than one gigantic list. That number $D$ is the *bond dimension*, and
it is the single number that decides whether classical simulation is cheap or
hopeless. A tensor-train simulation costs roughly $D^2$ per site. If $D$ is
polynomial in $L$, the classical machine wins. If $D$ is exponential, it loses.

Two facts make this the right notion and not a convenient approximation. First,
a factorization $M = AB$ through an index of size $D$ exists **if and only if**
$D \ge \operatorname{rank} M$ — so the minimal bond dimension across a cut is
exactly the rank, no more and no less. Second, multiplying rows and columns by
nonzero numbers does not change the rank; so *phases are free*. Every
single-qubit phase gate the tensor-train version of the Fourier transform
applies to a core tensor is, from the point of view of compressibility, a no-op.
That is a small lemma with a large consequence: any hardness we find is
intrinsic to the *pattern* of nonzero amplitudes, not to their values.

---

## The comb

Here is the state that matters. Halfway through the factoring algorithm, after
the modular-exponentiation step and a measurement of the second register, the
first register collapses onto an evenly spaced set of basis states:

$$|\mathrm{comb}\rangle \;=\; \sum_{\substack{x < n \\ x \equiv x_0 \ (\mathrm{mod}\ r)}} |x\rangle .$$

Amplitude $1$ on every $x$ congruent to $x_0$ modulo $r$, amplitude $0$
everywhere else. It is called a *comb* because if you draw the amplitudes along
the number line you get evenly spaced teeth of spacing $r$. The number $r$ is
the *order* — the secret the algorithm is hunting, the thing whose discovery
factors the modulus. It is typically enormous, comparable to the modulus itself.

The comb looks trivially simple. Its amplitudes are all $0$ or $1$; the pattern
is perfectly regular; it has no randomness in it at all. Surely such a state
compresses?

Reshape it across the cut. The matrix entry is

$$M[p, q] = \begin{cases} 1 & \text{if } pQ + q \equiv x_0 \pmod r, \\ 0 & \text{otherwise.}\end{cases}$$

Two competing intuitions immediately appear. In favour of compressibility: each
row of $M$ is determined by a single number, $pQ \bmod r$ — the left block never
communicates anything else to the right block. So the rank is at most $r$, and
an explicit factorization realizes it: the left core records the residue $pQ
\bmod r$, the right core completes it to $x_0$. Against compressibility: the
distinct rows are *indicator vectors of disjoint residue classes*, hence
pairwise orthogonal, and orthogonal nonzero vectors can never be linearly
dependent. The usual escape hatch of $0/1$ matrices — many distinct rows, few
independent ones — is slammed shut.

So the rank is exactly the number of distinct residues $pQ \bmod r$ that occur.
And that is a question about a cyclic group.

---

## The reduced period

As $p$ runs over $0, 1, 2, \dots$, the residue $pQ \bmod r$ walks through the
subgroup of $\mathbb{Z}/r$ generated by $Q$. That subgroup consists of the
multiples of $g = \gcd(r, Q)$, and it has exactly

$$s \;=\; \frac{r}{\gcd(r, Q)}$$

elements. Call $s$ the **reduced period**. This is the whole story:

> **Exact Bond Dimension Theorem.** For a period $r$ with $0 < r \le Q$, the rank
> of the reshaped comb across the cut $n = PQ$ is exactly
> $$\operatorname{rank} M \;=\; \min\!\left(P, \ \frac{r}{\gcd(r,Q)}\right),$$
> independent of the offset $x_0$. Consequently a tensor-train representation
> with bond index of size $D$ exists precisely when $D \ge \min(P, r/\gcd(r,Q))$.

The upper bound is the explicit two-core factorization through the reduced
period; the lower bound is a hand-built $k \times k$ identity submatrix, where
the row indices are chosen to hit each of the $s$ reachable residues once and
the column indices are chosen to complete each residue to $x_0$. Nothing deeper
is needed, and nothing weaker suffices.

The special case that motivated the question is worth stating on its own. If the
period is coprime to the right block size and both blocks are at least as large
as the period, then $\gcd(r,Q) = 1$ and the formula reads $\operatorname{rank} M
= r$: **the bond dimension of the comb is the order itself.** Not $\log r$, not a
constant — $r$. The comb is also a product state (bond dimension $1$) across a
cut if and only if $r = 1$; every nontrivial period is genuinely entangled across
every such cut.

And in the case that actually matters — a binary register — the formula becomes
startlingly clean. Write the period as $r = 2^t m$ with $m$ odd, and take the
cut at depth $b \ge t$ with $r \le 2^b$. Then $\gcd(2^t m, 2^b) = 2^t$, so the
reduced period is exactly $m$:

> **Odd-Part Law.** Across the binary cut $2^a \otimes 2^b$, the Schmidt rank of
> the comb with period $r = 2^t m$ ($m$ odd) is $\min(2^a, m)$. The power-of-two
> part of the period costs nothing at all; the odd part costs everything.
>
> **Dichotomy.** With at least one qubit on the left, the comb is a product state
> across the cut if and only if its period is a pure power of two.

This is the punchline in one sentence. A comb of period $1024$ on a binary
register is a *product state* — completely free. A comb of period $1023$ is
maximally expensive, needing bond dimension $\min(2^a, 1023)$. The two periods
differ by one, and the difference between them is the difference between trivial
and intractable.

Push it to the balanced cut, $L = 2a$ qubits split down the middle, with the
period $r = 2^a - 1$ — an odd order, coprime to the block size, exactly the kind
of order a generic base has modulo a generic RSA modulus. Every tensor-train
representation of that comb needs bond dimension at least

$$2^a - 1 \;=\; 2^{L/2} - 1 .$$

Exponential in the number of qubits. The tensor train is not merely inconvenient;
it is as large as the state it was supposed to compress.

---

## The Fourier transform: a surprise, and a trap

So the input to the quantum Fourier transform is hard. What about its output?

Here the situation is genuinely subtle, and the subtlety is where a naive
de-quantization claim would come to grief.

Suppose for a moment that the period divides the register size exactly:
$n = mr$. This is the textbook idealization — the case where the comb has
exactly $m$ teeth, perfectly spaced, wrapping around the register with no
remainder. Its Fourier transform is then a *sharp* comb: writing
$\zeta = e^{2\pi i/n}$, the transformed amplitude at frequency $k$ is

$$\Psi(k) \;=\; \begin{cases} m\,\zeta^{x_0 k} & \text{if } m \mid k, \\ 0 & \text{otherwise.}\end{cases}$$

The transform of a comb of period $r$ is a comb of period $m = n/r$, decorated
with phases. And phases are free. So the output rank obeys the *same law* as the
input, with $r$ replaced by the co-period $m$:

$$\operatorname{rank}(\text{output}) \;=\; \min\!\left(P, \frac{m}{\gcd(m,Q)}\right).$$

Not preserved — **inverted**. A hard input becomes an easy output, and vice
versa. And that inversion has a quantitative consequence that is, honestly,
rather beautiful:

> **Complementarity Theorem.** For an exact comb of period $r$ in a register of
> size $n = mr$, cut as $n = PQ$ with $r \le Q$ and $m \le Q$, the product of the
> bond dimensions before and after the Fourier transform satisfies
> $$D_{\mathrm{in}} \cdot D_{\mathrm{out}} \;\le\; P \;=\; n/Q .$$

At a balanced cut, $P = Q = \sqrt{n}$, this says at least one of the two states
has bond dimension at most $n^{1/4}$. An exact comb cannot be tensor-train-hard
in position space *and* in frequency space. There is an uncertainty principle
for compressibility, and it says the Fourier transform always hands you a cheap
side.

The proof is arithmetic rather than analytic: since $Q$ divides $rm$, one has
$Q \le \gcd(r,Q)\gcd(m,Q)$, and multiplying the two reduced periods gives
$$\frac{r}{\gcd(r,Q)}\cdot\frac{m}{\gcd(m,Q)} = \frac{rm}{\gcd(r,Q)\gcd(m,Q)} \le \frac{rm}{Q} = P.$$

This is exactly the tensor-train Fourier emulation claim that de-quantization
enthusiasts hope for — and it is *true*, in a strong quantitative form. So why
does the factoring algorithm survive?

Because of a single hypothesis: $r \mid n$.

---

## The boundary is a divisibility

The complementarity theorem needs the period to divide the register size. The
factoring algorithm runs on a binary register, $n = 2^L$. The order $r$ it is
searching for is generically odd — and an odd number greater than $1$ never
divides a power of two.

So the real post-measurement state is not the exact comb but the **truncated**
comb: the teeth $x_0, x_0 + r, x_0 + 2r, \dots$ stop wherever they happen to
land relative to $n$, leaving a ragged edge. And truncated combs are governed by
the Odd-Part Law, which says their bond dimension is $\min(2^a, m)$ with $m$ the
odd part of $r$ — exponentially large.

The de-quantization boundary is therefore not vague, not asymptotic, and not a
matter of constants. It is the divisibility relation $r \mid n$. On one side of
that line, tensor trains emulate the quantum Fourier transform beautifully and
the complementarity theorem hands you a cheap representation for free. On the
other side, the bond dimension is the odd part of the order and the emulation is
sealed at cost $\Omega(m^2)$ per site. The factoring algorithm lives, always and
necessarily, on the wrong side of that line.

There is an appealing irony here. The algorithm's continued-fraction
post-processing step exists *precisely because* $r$ does not divide $n$: the
measured frequency is only approximately a multiple of $n/r$, and one must
recover $r$ from an inexact rational approximation. The very imperfection that
forces the algorithm to work harder is the imperfection that protects it from
being emulated.

---

## What is still open, and how to close it

Two questions remain, and both are sharp enough to be attacked head-on.

The first is about the *transformed truncated* comb. For an exact comb, the
transform concentrates on multiples of $m$ — mostly zeros, hence a low rank. For
a truncated comb with $J$ teeth the transform is a geometric sum

$$\Psi(k) \;=\; \sum_{j < J} \omega^{(x_0 + jr)k} \;=\; \omega^{x_0 k}\,\frac{1 - \omega^{rkJ}}{1 - \omega^{rk}}, \qquad \omega = e^{2\pi i/n}.$$

One might guess that the ragged truncation makes the numerator's vanishing
condition $n \mid rkJ$ impossible, so that the spectrum has *full support* and
the support-only rank bound immediately forces maximal rank. That guess is
wrong, and pleasantly so, because the truth is an exact count. On a binary
register $n = 2^L$ with $r$ odd, $r$ is invertible modulo $n$, so the
denominator vanishes only at $k = 0$ (where $\Psi(0) = J \ne 0$), and for
$k \ne 0$ the numerator vanishes precisely when $n \mid kJ$, that is when
$k$ is a multiple of $n/\gcd(n,J)$. Hence:

> **Zero-Count Law.** For $n = 2^L$ and odd period $r$, the transformed truncated
> comb vanishes at exactly $\gcd(n, J) - 1$ frequencies, where $J$ is the number
> of teeth. In particular its spectrum has full support if and only if $J$ is
> odd.

The smallest counterexample to the naive guess is tiny: $n = 16$, $r = 5$,
$x_0 = 0$ has $J = 4$ teeth and the transform vanishes at $k = 4, 8, 12$. But
$\gcd(n,J) - 1$ zeros out of $n$ frequencies is a vanishing fraction, and the
intended conclusion survives them. Writing the transform as
$\Psi[p,q] = \sum_{j<J} \omega^{x_j pQ}\,\omega^{x_j q}$ exhibits it as a sum of
$J$ rank-one terms, so its rank is at most $J$; and when $J \le \min(P,Q)$ the
two factors are Vandermonde matrices with distinct nodes — the teeth are
distinct modulo $P$ because $r$ is odd and $P$ is a power of two — which forces
the rank to be exactly $J$. The remaining case $J > P$, where the rank should
saturate at the maximum $P$, is confirmed in every instance we have computed
exactly, and is the sharp form of the open question.

The second question is robustness. All of the above is about *exact* rank, and
every de-quantization claim in the literature is approximate: $\varepsilon$-close,
sampled, sketched. Can an approximate tensor train do better? Here the structure
of the comb is unusually generous: because its rows are indicators of disjoint
residue classes, its singular value decomposition is available in closed form
with no numerical work at all. The singular values are exactly
$\sigma_c = \sqrt{\mu_c \nu_c}$, where $\mu_c$ and $\nu_c$ count the left and
right indices in residue class $c$. Every truncation to rank $D$ below the true
rank $K$ therefore incurs Frobenius error at least
$(K - D)\min_c(\mu_c\nu_c)$, which for a comb with an exponentially large odd
part means no polynomial-size tensor train can approximate it to vanishing
relative error. The exact theorems become robust ones.

---

## The shape of the answer

It is worth stepping back to see what kind of statement this is.

De-quantization results almost always say: *your quantum algorithm needed the
data to be low-rank, and low-rank data is classically easy.* They are hardness
results about the quantum advantage, extracted by looking hard at the
assumptions. What we have here is the mirror image: an exact computation of the
relevant rank, showing that the assumption fails — and failing in a way
controlled by a completely explicit arithmetic quantity, the odd part of the
order.

The result is not a proof that factoring is classically hard. It says nothing
about algorithms that never write the comb down. What it does is close one
specific, plausible, much-discussed route with a formula rather than a hunch:
across every cut, the compressibility of the factoring algorithm's central state
is $\min(P, r/\gcd(r,Q))$, and on a binary register that is the odd part of the
order.

A single number, computable in a line of arithmetic, decides whether the most
famous state in quantum computing can be squeezed onto a laptop. The number is
the odd part of the order. It is large. The comb does not compress.
