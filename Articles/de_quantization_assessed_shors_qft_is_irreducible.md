# The Comb That Cannot Be Compressed

### Why the quantum heart of Shor's factoring algorithm refuses to be simulated cheaply

---

## A rumour of de-quantization

Every few years a rumour goes around: *quantum computers may not be so special after all*. The rumour has a respectable pedigree. Time and again, an algorithm that looked like it needed genuine quantum weirdness has turned out to be imitable by an ordinary computer. Quantum recommendation systems, several quantum machine-learning speedups, whole families of "quantum-inspired" linear algebra routines — all were **de-quantized**: someone found a classical algorithm that did the same job in comparable time, and the quantum advantage evaporated.

The technique behind many of these de-quantizations is beautifully simple in spirit. A quantum state on $n$ qubits is a vector of $2^n$ complex numbers, which is hopeless to write down. But most physically interesting states are not arbitrary vectors: they are *compressible*. Write the state as a chain of small tensors — a **matrix-product state**, in the language of physics; a **tensor train**, in the language of numerical analysis — and the whole thing is described by roughly $n D^2$ numbers, where $D$, the **bond dimension**, measures how tangled the two halves of the system are. If $D$ stays small, everything you want to do to the state, including running a quantum Fourier transform on it, can be done classically in time roughly $O(n D^2)$. Low entanglement means no quantum advantage.

So here is the natural question, and it is the question this article answers:

> Is the state inside Shor's factoring algorithm compressible in this sense?

If it were, the most celebrated quantum algorithm ever written — the one that threatens RSA, the one that motivates billions of dollars of hardware development — would collapse into an ordinary classical computation.

It is not. And the reason is unusually clean: the state at the heart of Shor's algorithm is not merely entangled, it is entangled in the *worst possible way*, with an entanglement spectrum that is perfectly **flat**. Flat spectra are the nightmare case for compression, because compression works by throwing away small numbers, and here there are no small numbers to throw away. Everything that could be discarded is exactly as important as everything that is kept.

---

## What Shor actually builds

Let $N$ be the number we want to factor and pick some $a$ coprime to $N$. The **order** of $a$ modulo $N$ is the least $r \geq 1$ with $a^r \equiv 1 \pmod N$. Knowing $r$ essentially factors $N$: if $r$ is even and $a^{r/2} \not\equiv -1 \pmod N$, then $b = a^{r/2}$ satisfies $b^2 \equiv 1$ while $b \neq \pm 1$, so $N$ divides $(b-1)(b+1)$ but divides neither factor — and $\gcd(b-1, N)$ is a nontrivial divisor of $N$. Shor's algorithm is entirely a machine for finding $r$.

It does so by preparing, in a register of size $Q$, the superposition

$$|\psi\rangle \;=\; \frac{1}{\sqrt{Q}} \sum_{x=0}^{Q-1} |x\rangle \, \big|a^x \bmod N\big\rangle ,$$

then applying a Fourier transform to the first register and measuring. Two registers, one big entangled state. The exponent register holds every $x$ at once; the function register holds the corresponding power of $a$.

The relevant structural fact about this state is that the function $x \mapsto a^x \bmod N$ is exactly $r$-periodic: $a^x = a^{x'}$ precisely when $x \equiv x' \pmod r$. Every value of the function is hit by exactly the same number of exponents. That perfect regularity is what makes the state so incompressible.

**Theorem (exact entanglement of the Shor state).** *Suppose the register size is $Q = r\,m$ for a positive integer $m$, and the second register holds a function of exact period $r$. Then, across the cut between the exponent register and the function register, the state $|\psi\rangle$ has Schmidt rank exactly $r$, its Schmidt spectrum is perfectly flat — all $r$ nonzero coefficients equal $1/\sqrt{r}$ — its entanglement entropy is exactly $\log r$, and the mutual information between the registers is exactly $2\log r$. Consequently every matrix-product representation of $|\psi\rangle$ across this cut has bond dimension at least $r$.*

The proof is a two-line combinatorial observation once one has the right lens, and the lens is worth naming, because it covers a huge class of states produced by "run a classical function in superposition".

**Fibre-matching states.** Suppose two registers, with index sets $\mathcal A$ and $\mathcal B$, are each labelled by maps $u : \mathcal A \to \Sigma$ and $v : \mathcal B \to \Sigma$ into a common label set $\Sigma$, and the amplitude of $|f\rangle|g\rangle$ is a constant $c$ when the labels agree and $0$ otherwise:

$$M_{f,g} = c \cdot [\,u(f) = v(g)\,].$$

Then $M$ is *already* in Schmidt form, once you normalize. The Schmidt vectors on the left are the normalized indicator vectors of the level sets ("fibres") $u^{-1}(s)$; on the right, of $v^{-1}(s)$; and the Schmidt coefficient attached to a label $s$ is

$$w_s = c\,\sqrt{|u^{-1}(s)| \cdot |v^{-1}(s)|}.$$

The Schmidt rank is therefore the number of labels realized on *both* sides,

$$\operatorname{rank} = \big|\,\mathrm{im}\,u \cap \mathrm{im}\,v\,\big|,$$

and the entanglement entropy is $\sum_s \eta\big(c^2\,|u^{-1}(s)|\,|v^{-1}(s)|\big)$, where $\eta(t) = -t\log t$. When all the fibres have equal size — the *balanced* case — the spectrum is flat and the entropy is exactly $\log(\text{rank})$, the largest value compatible with that rank.

For the Shor state, take $\Sigma$ to be the set of residues, $u$ the map $x \mapsto a^x \bmod N$ and $v$ the identity. Exact periodicity says every fibre of $u$ has size $m$; the fibres of the identity have size $1$; there are exactly $r$ distinct values. Balanced. Rank $r$. Entropy $\log r$. Done.

For a factoring-relevant $N$ the order $r$ is typically comparable to $N$ itself — exponentially large in the number of digits. So the bond dimension needed is exponentially large. There is no low-rank representation to exploit.

---

## The comb: the input the Fourier transform actually sees

A tensor-network practitioner will object, quite rightly, that this is not the state the Fourier transform acts on. In the usual telling one *measures* the function register first; the exponent register then collapses onto a single residue class,

$$c_x = \begin{cases} \text{const}, & x \equiv x_0 \pmod r,\\ 0, & \text{otherwise,}\end{cases}$$

a spike every $r$ steps: the **periodic comb**. And the comb lives on a single register, so the relevant cut is not between two registers but *inside* one — the tensor train chops the exponent register into a low part and a high part. Writing $Q = B\cdot C$ and $x = b + B\,c$ with $b < B$, $c < C$, the question becomes: what is the entanglement of the comb across the cut at position $B$?

Here the answer is not merely "exponential"; it is an exact arithmetic formula, and it is sharper than the folklore estimate $D = \Theta(\min(r, Q/r))$ that circulates in the literature. Define the **cut period**

$$\mathrm{per}(r, B) \;=\; \frac{r}{\gcd(r, B)},$$

the number of distinct residues mod $r$ that the high part of the register can reach as $c$ runs over $0, 1, 2, \dots$ (each step of $c$ advances $x$ by $B$, so the reachable residues are the multiples of $\gcd(r,B)$, and there are exactly $r/\gcd(r,B)$ of them).

**Theorem (sharp bond dimension of the comb).** *If $r \leq B$, the Schmidt rank of the comb across the cut $x = b + Bc$ is exactly*
$$\min\Big(C, \; \frac{r}{\gcd(r,B)}\Big).$$
*In particular the rank equals $r$ whenever $B$ is coprime to $r$ and $C \geq r$; and the rank equals $1$ — the comb is a product state — if and only if $r$ divides $B$.*

The mechanism is transparent through the fibre-matching lens. The low part carries the label $b \mapsto b \bmod r$; the high part carries the label $c \mapsto x_0 - Bc \bmod r$, the residue that the low part must supply to complete a tooth of the comb. A pair $(b,c)$ carries amplitude precisely when the two labels agree, so the rank is the number of shared labels. If $B \geq r$ the low part realizes every residue; the high part realizes exactly $\min(C, r/\gcd(r,B))$ of them.

Two corollaries deserve emphasis.

*First:* **no qubit cut ever compresses a comb of odd order.** Real implementations split registers at powers of two, $B = 2^k$. If $r$ is odd and bigger than $1$, then $r$ cannot divide any power of two — an odd number greater than $1$ has an odd prime factor, which $2^k$ does not. So $\gcd(r, 2^k) = 1$ and the rank is the full $\min(C, r)$. And $r$ odd is not a corner case: it is exactly the case in which the standard classical post-processing needs a fresh base $a$, which is to say it happens routinely.

*Second:* **the only escape is to already know the answer.** The rank drops to $1$ precisely when $r \mid B$, i.e. when the block size has been chosen as a multiple of the period. Choosing such a $B$ requires knowing $r$ — the very quantity the whole algorithm exists to compute. Compression is available exactly to someone who does not need it.

And in the intermediate regime, where the two halves are shorter than the period, the spectrum is not just high-rank but *flat*: when $B \leq r$, $C \leq r$ and $\gcd(B,r) = 1$, both label maps are injective, every matching label carries a single pair, and all the Schmidt coefficients coincide. There is no decaying tail. Truncation is not "lossy but acceptable"; it is amputation.

---

## The other end of the transform

One might hope the Fourier transform *itself* buys something: perhaps the output is nearly a single basis state, so even if the input is expensive the output is cheap, and a clever algorithm could jump the gap.

It is not. The Fourier transform of a comb is a comb.

**Theorem (the transformed comb).** *Let $Q = r\,m$ and transform the comb of period $r$ and offset $x_0$. The output amplitude at frequency $y$ vanishes unless $m$ divides $y$, and has constant modulus otherwise; the output probability distribution is exactly*
$$P(y) = \begin{cases} 1/r, & m \mid y, \\ 0, & \text{otherwise,}\end{cases}$$
*a uniform distribution on the $r$ multiples of $m$, which sums to $1$ as it must.*

This transformed comb, presented across a cut, is the period-$m$ comb multiplied on both sides by *diagonal phase matrices*. Diagonal matrices with nonvanishing entries are invertible, and multiplying by an invertible matrix cannot change a rank. So the output state has Schmidt rank exactly $\min(C, m/\gcd(m,B))$: the same arithmetic law, with the period $r$ replaced by the dual period $m = Q/r$. Both endpoints of the Fourier transform are exponentially entangled. The state is expensive when it goes in and expensive when it comes out. Only the final *measurement* produces a single basis state, and by then the computation is over.

There is a subtlety here that is worth telling honestly, because it is the kind of thing that separates a plausible story from a proved one. It is tempting to conjecture a **complementarity**: input rank times output rank must be large, because a cut aligned with the period $r$ is misaligned with the dual period $m$. That is false. Take $Q = 36$, $r = m = 6$, and cut in the middle, $B = C = 6$: both the input comb and the output comb are product states. Rank one at both ends.

What *is* true is a sharp lcm law. The cut period obeys the divisibility rule $r \mid Bk \iff \mathrm{per}(r,B) \mid k$, from which one deduces $\mathrm{per}(\mathrm{lcm}(r,m), B) = \mathrm{lcm}\big(\mathrm{per}(r,B), \mathrm{per}(m,B)\big)$, and hence

$$\min\Big(C,\ \mathrm{per}\big(\mathrm{lcm}(r,m),\,B\big)\Big) \;\leq\; \mathrm{rank}_{\text{in}} \cdot \mathrm{rank}_{\text{out}} .$$

Both ends can be cheap simultaneously *only* when $\mathrm{lcm}(r,m)$ divides $B$ — an exquisitely aligned cut. For odd $r$ and a power-of-two block size that never happens. The escape hatch exists, and it is locked from the inside.

---

## How badly does truncation fail?

Suppose one ignores all of this and truncates anyway, keeping $D$ bond dimensions out of $r$. How wrong is the result?

For a *generic* physical state the answer might be "hardly at all", because the discarded Schmidt coefficients are tiny. For a flat state, one can compute the damage exactly.

**Theorem (flat-spectrum Eckart–Young).** *Let $M$ be a normalized state with a flat Schmidt spectrum of rank $r$ (all coefficients $1/\sqrt r$), and let $A$ be any normalized state of Schmidt rank at most $D$. Then the squared overlap satisfies*
$$|\langle M, A\rangle|^2 \;\leq\; \frac{D}{r},$$
*and the bound is attained: truncating $M$ to any $D$ of its Schmidt vectors and renormalizing achieves exactly $D/r$. Equivalently, the squared distance obeys $\|M - A\|^2 \geq 2 - 2\sqrt{D/r}$.*

The proof is a Cauchy–Schwarz computation: the overlap is a sum over $D$ terms each bounded by $r^{-1/2}$ times a Schmidt coefficient of $A$, and those coefficients have squares summing to at most $1$, so the overlap is at most $\sqrt{D/r}$.

This corrects a natural but wrong guess. The informal literature sometimes quotes a truncation fidelity of $(D/r)^2$; the truth is $D/r$, which is *larger* — truncation is less catastrophic than folklore claims by a square root — and still hopeless, because with $r$ exponential in the input size and $D$ polynomial, $D/r$ is exponentially small either way. Applied directly to Shor's state: **every bond-dimension-$D$ approximation of the Shor register state has fidelity at most $D/r$.**

The sampling picture is equally stark. Suppose a classical algorithm outputs samples drawn from some distribution supported on a set $S$ of frequencies. The ideal Fourier output spreads probability $1/r$ over $r$ peaks. Then the total-variation distance obeys

$$d_{\mathrm{TV}}(\text{ideal}, \text{sampler}) \;\geq\; 1 - \frac{|S|}{r},$$

so any sampler whose support is at most half the number of peaks is at distance at least $1/2$: it fails half the time, which for a decision procedure is no better than a coin. Polynomially many peaks against exponentially many is total failure, not graceful degradation.

---

## The closing of the circle

Now put the pieces together, and note where they meet: on the question of *what a small bond dimension would actually imply*.

A representation of the Shor state with bond dimension $\chi$ forces $r \leq \chi$; and $r \leq \chi$ means there exists $k$ with $1 \leq k \leq \chi$ and $a^k \equiv 1 \pmod N$. In other words, **a polynomially small bond dimension is a certificate that the order is polynomially small** — and a polynomially small order is found by a classical computer in polynomial time by simply raising $a$ to successive powers. The regime in which the tensor-network emulation works is exactly the regime in which one never needed a quantum computer.

And in the other direction the ideal quantum output is genuinely powerful. Every peak of the output distribution sits at a frequency $y = k\,m$, and the continued-fraction expansion of $y/Q$ recovers

$$\frac{Q}{\gcd(y, Q)} = \frac{r}{\gcd(k, r)},$$

a divisor of $r$, equal to $r$ exactly when $\gcd(k,r) = 1$ — which happens for a constant fraction of peaks. Once $r$ is in hand and $r$ is even with $a^{r/2}\not\equiv -1$, the gcd trick returns a nontrivial factor of $N$. So a polynomial-time classical sampler of Shor's output distribution *is* a polynomial-time factoring algorithm.

That is the whole argument, and its shape is a dichotomy. Either the order is small — in which case the state is compressible, and also the problem is classically trivial — or the order is large, in which case the state is exponentially entangled at both ends of the Fourier transform, with a flat spectrum that no truncation can survive, and any classical emulator that succeeded would have factored $N$ in polynomial time.

---

## What this does and does not say

It does *not* say the tensor-train Fourier transform is wrong. It is a real theorem: a state with a genuinely low-rank tensor-train representation really can be Fourier-transformed classically in time linear in the register length and quadratic in the bond dimension. What the results here establish is that its precondition is violated, sharply and at both endpoints, by exactly the state Shor's algorithm builds. The hypothesis fails; the theorem is inapplicable; there is no contradiction anywhere. This is how honest de-quantization assessments usually end — not with an error found, but with a precondition measured and found wanting.

Nor is this a proof that factoring is hard, or that $\mathrm{P} \neq \mathrm{NP}$, or that no classical factoring algorithm exists. It is a proof that *this route* is closed, and closed for a structural reason: the coherent superposition inside the Fourier transform is not a wasteful encoding of a sparse object. It is genuinely $r$-dimensional, uniformly so, with every direction carrying equal weight.

There is a pleasing irony in the arithmetic. Compression of the comb becomes possible exactly when the block size is a multiple of the period, and the period is the answer. Everything in this analysis is a variation on that theme: the structure that would make Shor's algorithm classically cheap is the structure whose discovery *is* the computation. You can have the compression, or you can have the problem. Not both.

For once, then, a rumour can be laid to rest with a formula. The bond dimension of Shor's Fourier input is exactly $\min\!\big(C, r/\gcd(r,B)\big)$; the spectrum is flat; the fidelity of a rank-$D$ truncation is exactly $D/r$; and the quantum exception stands.
