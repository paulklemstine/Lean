# The Comb That Cannot Be Combed

### A guided tour of why one quantum algorithm refuses to be imitated

---

## 1. The question, in one line

Most advertised exponential quantum speedups have been *de-quantized*: someone
found a classical algorithm that reproduces the quantum machine's output
distribution in comparable time. The trick, every time, was that the quantum
state was **compressible** — low rank, or concentrated on a few outcomes, or with
a rapidly decaying spectrum.

So the natural question is whether the same can be done to the algorithm everyone
actually cares about: the one that factors integers.

This page is a tour of the answer, which is *no*, together with the reason —
which turns out to be a single geometric object you can watch on screen.

> **The punchline, stated up front.** The information that reveals a factor lives
> in one number $r$. That number parameterizes an object of rank exactly $r$ with
> a perfectly flat spectrum. Looking at that object can be free. *Extracting* $r$
> from it costs $\Theta(r)$. And the only prize extraction offers — the number $r$
> — already hands you a factorization by one line of elementary arithmetic.

---

## 2. Everything reduces to one number

Fix a modulus $N$ you would like to factor and a base $b$ coprime to it. The
**multiplicative order** of $b$ is the smallest $r \ge 1$ with
$$b^r \equiv 1 \pmod N.$$

<details>
<summary><strong>Why knowing $r$ finishes the job</strong> (click to reveal the two-line proof)</summary>

Suppose $r$ is even and $b^{r/2} \not\equiv -1 \pmod N$. Put $x = b^{r/2}$. Then
$x^2 = b^r \equiv 1$, but $x \not\equiv 1$ (that would contradict $r$ being the
*smallest* exponent) and $x \not\equiv -1$ (assumed). So $x$ is a **nontrivial
square root of unity**, and such a thing always splits the modulus:

- If $\gcd(x-1, N) = 1$, then since $N \mid (x-1)(x+1)$, the modulus would have to
  divide $x+1$ — i.e. $x \equiv -1$. Excluded.
- If $\gcd(x-1, N) = N$, then $N \mid x-1$ — i.e. $x \equiv 1$. Excluded.

So $1 < \gcd(x-1, N) < N$: a genuine factor. Concretely, $N = 15$, $b = 2$ gives
$r = 4$, $x = 4$, $\gcd(3,15) = 3$. Done.

Further reading: [Shor's algorithm](https://en.wikipedia.org/wiki/Shor%27s_algorithm),
[order of an element](https://en.wikipedia.org/wiki/Multiplicative_order).
</details>

So the entire cryptographic drama compresses into: **find $r$**.

---

## 3. Meet the comb

Here is the object. The quantum circuit puts a register into uniform superposition
over $\{0,\dots,Q-1\}$, computes $b^x \bmod N$ alongside it, and measures the
second register. Because $b^x$ depends only on $x \bmod r$, the first register
collapses onto an **arithmetic progression of spacing $r$** — a row of evenly
spaced teeth. A comb.

The hidden number is the tooth spacing, and you are not allowed to look at the
teeth. You are only allowed to look at the *spectrum*.

Assume for cleanliness that $r$ divides $Q$. Then the Fourier transform is a
complete geometric sum, and it collapses exactly:

$$\sum_{j=0}^{Q/r-1} e^{2\pi i\, j r y / Q} \;=\;
\begin{cases} Q/r, & (Q/r) \mid y, \\ 0, & \text{otherwise.}\end{cases}$$

No leakage, no tail, no approximation. The transform of a comb of spacing $r$ is a
comb of spacing $Q/r$. Inside the window there are exactly $r$ peaks, each of
probability exactly $1/r$.

**The number you want is the number of peaks.** Not the position of one peak — the
*count*. That is a global feature of the whole picture, and it is the single fact
from which everything else in this page follows.

Play with it. Change the grid, change the hidden order, and watch the peak count
track $r$ exactly:

{{interactive_demo:0}}

While you have the laboratory open, do three experiments:

1. **Slide the surrogate support $k$.** The blue outline is a classical sketch
   supported on $k$ outcomes. Notice that the measured distance never drops below
   the amber floor $1 - k/r$, and that keeping the sketch on the lattice makes it
   *equal* the floor. The bound is sharp; cleverness buys nothing.
2. **Pick two coprime orders.** The measured distance between the two combs
   matches $1 - \gcd(r,r')/\max(r,r')$ to the last digit. It is an identity, not
   an estimate.
3. **Read the certificate.** Half that number is a floor that *no* distribution
   can beat against both candidates at once. For coprime orders it converges to
   $1/2$ — the famous "$\mathrm{TV} \ge 0.5$" wall, here as an exact constant.

---

## 4. Flatness is the enemy of compression

The measurement distribution is uniform on its support: $r$ outcomes, each of
probability $1/r$. Its Shannon entropy is exactly $\log r$, the maximum possible
for that many outcomes. There is no heavy head to keep and no light tail to throw
away — which is precisely the structural hypothesis every de-quantization
technique needs.

Here is the price, exactly:

> **Incompressibility.** If a distribution $D$ is supported on at most $k$ points,
> then $\mathrm{TV}(P_r, D) \ge 1 - k/r$, and the bound is attained.

<details>
<summary><strong>Proof in three sentences</strong></summary>

The surrogate misses at least $r-k$ of the $r$ peaks. Those missed peaks form an
event of probability $(r-k)/r$ under the truth and $0$ under the surrogate. Total
variation dominates the discrepancy on any event, so
$\mathrm{TV} \ge (r-k)/r = 1 - k/r$; and putting mass $1/k$ on $k$ peaks attains
it exactly.
</details>

Put cryptographic numbers in: $k = \mathrm{poly}(\log N)$ against an exponentially
large $r$ gives distance $1 - o(1)$. The sketch is not a degraded copy of the
truth; the two are asymptotically **mutually singular**.

The ledger below makes this concrete on a grid you can check by hand, and then
extrapolates to $2048$-bit parameters:

{{demo:1}}

And here is the same statement as a picture — a heat map of the exact pairwise
distance $1 - \gcd/\max$ over all candidate orders, beside the incompressibility
floor plotted against the sketch size:

{{visualization:1}}

---

## 5. The five routes, and the one wall

Every proposal to de-quantize order finding is one of five things. Each one is
free to *observe* and expensive to *extract*, and it is always the same expense.

| Route | Free observation | Sealed extraction |
|---|---|---|
| Sparse / structured transforms | evaluating the transform at a known frequency | *locating* the informative frequencies: $\Theta(Q/r)$, or requires $r$ (circular) |
| Fixed-point gcd probe | $\gcd(b^t-1, N)$: one modular exponentiation | recovering $r$: $\Theta(r)$ naive, $\Theta(\sqrt r)$ meet-in-the-middle |
| Lattice-style samplers | evaluating a candidate distribution | matching the $r$-parameterized output: $\mathrm{TV} \ge 1 - \gcd/\max$ |
| Tensor networks | contracting a bounded-bond network | representing rank $r$ with bond dimension $k < r$: impossible |
| $\ell^1$ diffusions | one diffusion step | each step aggregates all $r$ eigenvalues |

The tensor-network row deserves its own theorem, because it is the route with the
best track record elsewhere.

> **Schmidt rank equals the order.** Viewed as a matrix across the cut between the
> two registers, the pre-measurement state has rank exactly $r$, and its distinct
> rows are orthonormal. Hence all $r$ Schmidt coefficients are equal, the
> entanglement spectrum is flat, and any bipartite decomposition of rank $k$
> forces $r \le k$.

<details>
<summary><strong>Why the rank is exactly $r$</strong></summary>

The coefficient matrix has a $1$ in position $(x, z)$ exactly when $b^x \equiv z$.
So row $x$ is the standard basis vector indexed by $b^x \bmod N$. The distinct
rows are therefore the standard basis vectors indexed by the *branch set*
$\{b^x : x < r\}$, which has exactly $r$ elements by minimality of the order and
is obviously linearly independent. Rank $= r$.
</details>

The consequence is a dichotomy, not a difficulty: polynomial bond dimension forces
a polynomially small order, which is exactly the regime where brute force would
have found $r$ anyway. [Matrix-product-state](https://en.wikipedia.org/wiki/Matrix_product_state)
simulation works here precisely when it is not needed.

---

## 6. The free oracle that says nothing

The most seductive route deserves its own bench. For any exponent $t$, compute
$\gcd(b^t - 1, N)$ — one modular exponentiation. This *probe* answers a perfectly
clean question:

$$N \mid b^t - 1 \iff r \mid t.$$

A free, exact divisibility oracle for the number you are hunting. Surely that is
enough?

Watch what it actually returns:

{{interactive_demo:1}}

Every cell below the order is dark. That is not an accident of the example — it is
a theorem: a positive multiple of $r$ is at least $r$, so the entire answer vector
on $\{1,\dots,r-1\}$ is constant and carries **zero bits**. The oracle sits in
silence until you happen to guess a multiple of the answer.

<details>
<summary><strong>The two matching lower bounds</strong></summary>

**Adversary bound.** Let $A$ be any procedure whose output depends only on the
probe answers at a finite query set $T$. If $A$ returns the correct order for two
different candidates $r \ne s$, then $T$ must contain some $t \ge \min(r,s)$ —
otherwise both answer vectors on $T$ are all-false, so $A$ returns the same number
in both cases.

**Counting bound.** A procedure reading $|T|$ probe bits can distinguish at most
$2^{|T|}$ candidates, so separating $n$ candidate orders needs $|T| \ge \log_2 n$
queries.

Together: $\Omega(\log r)$ queries are needed, and at least one must have
magnitude $\Omega(r)$. [Baby-step/giant-step](https://en.wikipedia.org/wiki/Baby-step_giant-step)
gets the count down to $\Theta(\sqrt r)$ — still exponential in the bit length.

**Is the seal vacuous?** No: for every $r \ge 2$, the base $2$ has order exactly
$r$ modulo the Mersenne number $2^r - 1$. Every scale is realised honestly.

**Is there an escape?** Exactly one, and it is circular: if you know a multiple $L$
of $r$ *together with its factorization*, then $r$ is the least divisor of $L$
passing the probe. For an RSA modulus the natural $L$ is
[$\lambda(N)$](https://en.wikipedia.org/wiki/Carmichael_function), whose
computation is itself equivalent to factoring. The door is unlocked from the
inside only.
</details>

Here is the extraction cost, measured rather than asserted, across many scales:

{{demo:2}}

---

## 7. The algorithms, one at a time

Four routines carry the whole story. The first is the ground truth everything else
is measured against.

{{algorithm:0}}

The second is the auditor: hand it any proposed classical sampler and it returns
both the measured distances and the floors that are *proved* to be unbeatable. It
refutes a candidate de-quantization before anyone implements it.

{{algorithm:1}}

The third is the best known classical attack in the probe model — and the upper
bound that meets the lower bounds of Section 6.

{{algorithm:2}}

The fourth closes the loop, turning a single sampled frequency into an actual
factorization.

{{algorithm:3}}

<details>
<summary><strong>Why the post-processing is unambiguous</strong> (Farey separation)</summary>

Two distinct fractions $s/r$ and $s'/r'$ satisfy
$$\Big|\frac{s}{r} - \frac{s'}{r'}\Big| = \frac{|sr' - s'r|}{rr'} \ge \frac{1}{rr'},$$
because the numerator is a nonzero integer. So if both approximate the same real
number to within $1/(2R^2)$ and both have denominator at most $R$, the triangle
inequality gives $|s/r - s'/r'| < 1/R^2 \le 1/(rr')$ — a contradiction unless the
fractions coincide. Hence a measured frequency determines *the* order, not a
competitor. See [continued fractions](https://en.wikipedia.org/wiki/Continued_fraction).
</details>

---

## 8. The picture worth keeping

Two hidden orders, two combs, two spectra — the secret visible only as a count:

{{visualization:0}}

---

## 9. Everything checked at once

Finally, the complete numerical audit: exact spectrum, entropy, sharpness of the
incompressibility bound, the exact two-comb distance, the pigeonhole floor, the
Schmidt rank computed exactly over the rationals, the silence of the probe, the
aliasing bound, and an end-to-end run that turns one sampled frequency into
$8051 = 83 \times 97$.

{{demo:0}}

---

## 10. What it all adds up to

Assemble the pieces for a single instance and they interlock:

1. no probe below $r$ says anything;
2. the state's rank across the register cut is exactly $r$;
3. every $k$-sparse surrogate is at distance $\ge 1 - k/r$ from the truth;
4. the true distribution is flat with entropy exactly $\log r$;
5. and the moment you know $r$, one gcd factors $N$.

Item 5 is what turns a list of difficulties into a **closure**. A polynomial-time
classical sampler of the output distribution would, through continued fractions
and a single gcd, be a polynomial-time factoring algorithm. De-quantizing this
algorithm is not a way around factoring — it *is* factoring.

There is a pleasing irony in the reason. Every de-quantization success of the last
decade exploited structure: low rank, concentration, decay. This algorithm's
central object has none. It is the most boring distribution imaginable — a flat
one — and that is exactly why it cannot be imitated. It exposes precisely
$\log r$ nats, spread perfectly evenly across $r$ equal teeth, and demands that
you take them all at once or not at all.

Coherent Fourier aggregation does exactly that, in one shot. That is the whole
advantage, and now we know its precise shape.
