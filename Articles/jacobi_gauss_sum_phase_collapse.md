# The Sum That Refuses to Tell

## How a two-hundred-year-old exponential sum keeps a secret it looks like it should spill

Suppose someone hands you a large odd number $N$ and tells you it is the product of exactly two prime numbers, $N = pq$, but refuses to tell you which two. Finding $p$ and $q$ is the factoring problem: easy to state, apparently very hard to do, and the reason a great deal of the world's encrypted traffic is still readable only by its intended recipient.

Nobody expects to break that problem by accident. But there is a more modest and much more interesting question you can ask. Forget about recovering $p$ and $q$ exactly. Can you learn *anything at all* about them — even a single bit — from some quantity that is cheap to compute from $N$ alone?

This is a story about one specific, very natural candidate for such a leak, and about how, when you look hard enough, it turns out to leak precisely nothing.

---

## A wheel of signs

Start with a simple game. Fix an odd number $N$. For each whole number $n$ between $0$ and $N-1$, define a sign $\left(\frac{n}{N}\right)$, called the **Jacobi symbol**, which is $+1$, $-1$, or $0$. When $N$ is a prime $p$, the definition is easy to say: the symbol is $+1$ if $n$ is a nonzero *square* modulo $p$ (that is, if $n \equiv x^2 \pmod p$ for some $x$), it is $-1$ if $n$ is not a square modulo $p$, and it is $0$ if $p$ divides $n$. For a general odd $N = p_1 p_2 \cdots p_k$, you simply multiply the prime-by-prime answers together:
$$\left(\frac{n}{N}\right) = \left(\frac{n}{p_1}\right)\left(\frac{n}{p_2}\right)\cdots\left(\frac{n}{p_k}\right).$$

So the Jacobi symbol paints each residue class modulo $N$ with a sign. Now place those residues around a circle: put the number $n$ at the point $e^{2\pi i n/N}$ on the unit circle in the complex plane, which is the point you reach after walking $n/N$ of the way around. Then add up all those points, each weighted by its sign. The result is a single complex number,
$$\tau(N) \;=\; \sum_{n=0}^{N-1} \left(\frac{n}{N}\right) e^{2\pi i n / N},$$
called the **Jacobi Gauss sum**.

Think of it as an interference experiment. Half the residues push one way, half push the other, and the question is what survives the cancellation. Naively, adding $N$ unit vectors with random-looking signs should leave you with something of size about $\sqrt{N}$, in a random direction — the classic drunkard's walk. Half of that guess is exactly right, and the other half is spectacularly wrong.

**The length is exactly $\sqrt{N}$.** Not approximately: for every odd squarefree $N$ (that is, every odd $N$ not divisible by the square of a prime),
$$|\tau(N)| = \sqrt{N}.$$
The cancellation is perfect, in the sense that the residual is exactly what a random walk would predict, on the nose, with no error term. Gauss discovered this for prime $N$ in 1801 and it is one of the small miracles of number theory.

**The direction is not random at all.** And here is where the story begins.

---

## Where a secret could hide

Since $|\tau(N)|$ is pinned to $\sqrt{N}$, all the information in $\tau(N)$ lives in its *phase* — the angle $\arg \tau(N)$ that the arrow makes with the positive real axis. That single angle is where a leak could hide.

Here is why one might expect it to. When $N = pq$, the Jacobi symbol modulo $N$ is built out of the symbols modulo $p$ and modulo $q$, and the underlying prime-level sums behave very differently depending on the primes' residues modulo $4$. For an odd prime $p$, write
$$g_p \;=\; \sum_{a=0}^{p-1}\left(\frac{a}{p}\right) e^{2\pi i a/p}$$
for the classical **quadratic Gauss sum**. A theorem Gauss himself struggled with for four years before finding a proof says:
$$g_p = \sqrt{p} \quad \text{if } p \equiv 1 \pmod 4, \qquad g_p = i\sqrt{p}\quad \text{if } p \equiv 3 \pmod 4.$$
So the prime-level sums *do* see the residue mod $4$: they are real for $p \equiv 1$, and purely imaginary for $p \equiv 3$. They wear their arithmetic on their sleeve.

Now, a semiprime $N = pq$ falls into one of four classes according to the pair $(p \bmod 4,\, q \bmod 4)$: $(1,1)$, $(1,3)$, $(3,1)$, $(3,3)$. If the phase of $\tau(pq)$ could distinguish those four classes, then reading off one angle — a computation you can do knowing only $N$ — would tell you something genuinely private about the hidden factorization. The classes $(1,3)$ and $(3,1)$ are already visible from $N$ itself, because in those cases $N \equiv 3 \pmod 4$. But the classes $(1,1)$ and $(3,3)$ both give $N \equiv 1 \pmod 4$; they are *not* distinguishable from $N$ alone. If the phase could tell them apart, that would be one free bit of factor information from a single exponential sum.

That is the hypothesis worth testing. And the answer is a clean, hard no.

---

## The collapse

**Phase Collapse Theorem.** *For every odd squarefree $N$,*
$$\tau(N) = \sqrt{N} \quad \text{if } N \equiv 1 \pmod 4, \qquad \tau(N) = i\sqrt{N} \quad \text{if } N \equiv 3 \pmod 4.$$
*Equivalently, $\arg \tau(N) = 0$ or $\pi/2$, and which one it is depends on $N \bmod 4$ and nothing else.*

Read that again with the factoring question in mind. Two semiprimes $N = 5 \cdot 13 = 65$, in class $(1,1)$, and $N' = 3 \cdot 7 = 21$, in class $(3,3)$, have completely different hidden structure — but both are $1 \bmod 4$, so both sums are exactly real and positive: $\tau(65) = \sqrt{65}$, $\tau(21) = \sqrt{21}$. The angle is identical. The phase channel transmits exactly one bit, and that bit is $N \bmod 4$ — a quantity anyone can read off the last two digits of $N$ in binary. It is public information. Nothing private crosses the channel.

This is what one might call **structural orthogonality**: the invariant is not merely hard to extract information from, it provably carries none.

---

## Why it happens: two minus signs that turn out to be the same minus sign

The proof is where the pleasure is, because the collapse is not a coincidence of size or an averaging effect. It is an exact cancellation between two apparently unrelated pieces of arithmetic.

**Step one: the sum factors.** If $m$ and $n$ are coprime odd numbers, the Chinese Remainder Theorem lets you split the sum over residues mod $mn$ into a double sum over residues mod $m$ and mod $n$. Doing the bookkeeping carefully — the splitting requires a choice of Bézout coefficients, and each choice twists the additive character by a unit, which multiplies the sum by a Jacobi symbol — yields a beautiful *twisted multiplicativity* law:
$$\tau(mn) \;=\; \left(\frac{n}{m}\right)\left(\frac{m}{n}\right)\,\tau(m)\,\tau(n).$$
No primality is needed anywhere; coprimality alone suffices. Applied to $N = pq$ it says
$$\tau(pq) \;=\; \left(\frac{q}{p}\right)\left(\frac{p}{q}\right)\, g_p \, g_q .$$
So the semiprime sum is genuinely built from the two prime sums — plus a correction factor.

**Step two: the prime sums do see the residues.** As above, $g_p$ contributes a factor $i$ exactly when $p \equiv 3 \pmod 4$. So in the four classes, the product $g_p g_q$ has phase unit
$$(1,1) \to 1, \qquad (1,3) \to i, \qquad (3,1) \to i, \qquad (3,3) \to i \cdot i = -1.$$
Look at the fourth entry. If nothing else intervened, $(1,1)$ would give a positive real sum and $(3,3)$ would give a *negative* real one — and the phase would separate two classes that $N \bmod 4$ cannot. The leak would be real.

**Step three: reciprocity cancels it exactly.** The correction factor $\left(\frac{q}{p}\right)\left(\frac{p}{q}\right)$ is exactly the object controlled by the crown jewel of elementary number theory, Gauss's **law of quadratic reciprocity**:
$$\left(\frac{q}{p}\right)\left(\frac{p}{q}\right) = (-1)^{\frac{p-1}{2}\cdot\frac{q-1}{2}}.$$
That exponent is odd precisely when $p$ and $q$ are *both* $3 \bmod 4$. So the correction is $+1$ in the classes $(1,1)$, $(1,3)$, $(3,1)$, and $-1$ in the class $(3,3)$ — matching, term for term, exactly the case where the phase units multiplied to $-1$. The two minus signs annihilate:
$$(-1)\cdot(-1) = +1 .$$
The class $(3,3)$ lands back on the positive real axis, indistinguishable from $(1,1)$.

The punchline is that the two sources of sign are not independent quantities that happen to agree numerically. They are two faces of one arithmetic fact. Reciprocity's exceptional case — the unique case where the law flips a sign — is *defined* by the same condition $p \equiv q \equiv 3 \pmod 4$ that makes both prime Gauss sums imaginary. The would-be leak is plugged by the very theorem that describes how the primes see each other.

The smallest complete example is worth writing out. Take $N = 21 = 3 \cdot 7$, the smallest semiprime with both factors $3 \bmod 4$. Here $g_3 = i\sqrt3$ and $g_7 = i\sqrt7$, so $g_3 g_7 = -\sqrt{21}$. The reciprocity twist is $\left(\frac{7}{3}\right)\left(\frac{3}{7}\right) = (1)(-1) = -1$. Multiply: $\tau(21) = (-1)(-\sqrt{21}) = \sqrt{21}$, real and positive. And $21 \equiv 1 \pmod 4$, exactly as the theorem promises.

---

## How much of this needs Gauss's hardest theorem?

There is a subtlety worth being honest about, and it turns out to be illuminating rather than annoying.

The *square* of the sum is easy, in the sense that it needs no delicate sign work at all. From twisted multiplicativity plus the elementary identity $g_p^2 = \pm p$ (with $+$ for $p \equiv 1$ and $-$ for $p \equiv 3$ mod $4$, itself a short computation), one gets, for every odd squarefree $N$ and unconditionally:
$$\tau(N)^2 = N \quad \text{if } N \equiv 1 \pmod 4, \qquad \tau(N)^2 = -N \quad\text{if } N \equiv 3 \pmod 4.$$
This already contains the whole information-theoretic content of the collapse. It says $|\tau(N)| = \sqrt{N}$ and, more importantly, that the *line* through $\tau(N)$ in the complex plane — the real axis or the imaginary axis — is determined by $N \bmod 4$ alone. Sharpened slightly, this gives an unconditional dichotomy: $\tau(N) \in \{\sqrt N, -\sqrt N\}$ when $N \equiv 1 \pmod 4$, and $\tau(N) \in \{i\sqrt N, -i\sqrt N\}$ when $N \equiv 3 \pmod 4$.

So the entire residual dependence of the sum on the secret factorization is at most one global sign. And Gauss's celebrated sign theorem — the hard part, the one that took him four years — is needed only to say that this sign is always $+$. Which is a fact independent of the factorization anyway.

That decomposition is, I think, the sharpest way to state the result. The *soft* part of the argument, which uses only reciprocity and an algebraic square identity, already proves that no factor information survives beyond a sign; the *hard* part removes the sign, and removes it uniformly.

And in small cases you can dispense with the hard part entirely. For $p = 3$, $5$, and $7$ the sign can be computed by hand. The case $p = 7$ is the instructive one: the six nontrivial seventh roots of unity pair up under $k \leftrightarrow 7-k$ in such a way that the real part of $g_7$ cancels identically, leaving
$$g_7 = 2i\left(\sin\tfrac{2\pi}{7} + \sin\tfrac{4\pi}{7} - \sin\tfrac{6\pi}{7}\right).$$
Using $\sin\frac{4\pi}{7} = \sin\frac{3\pi}{7}$ and $\sin\frac{6\pi}{7} = \sin\frac{\pi}{7}$, positivity of the bracket reduces to the inequality $\sin\frac{\pi}{7} < \sin\frac{3\pi}{7}$, which is just monotonicity of the sine on $[0, \pi/2]$. Since $g_7^2 = -7$ and $g_7$ is a positive imaginary multiple, $g_7 = i\sqrt7$ — and with it, unconditionally, $\tau(21) = \sqrt{21}$ and $\tau(15) = i\sqrt{15}$.

---

## What the experiment showed

The theorem was found the way results often are found: by computing first. The sums $\tau(N)$ were evaluated for the thirteen semiprimes
$$15,\;21,\;33,\;35,\;51,\;65,\;77,\;85,\;91,\;115,\;143,\;187,\;209,$$
chosen to hit all four residue classes of $(p \bmod 4, q \bmod 4)$. In every case the normalized value $\tau(N)/\sqrt N$ came out to be exactly $1$ or exactly $i$ — $1$ when $N \equiv 1 \pmod 4$, $i$ when $N \equiv 3 \pmod 4$. Nothing else appeared. The $(1,1)$ semiprimes $65$ and $85$ produced the same value as the $(3,3)$ semiprimes $21$, $33$, $77$, and $209$. No individual residue survived into the output.

Extending the search to every odd squarefree modulus below $400$, with arbitrarily many prime factors, produces exactly two observed phases: $0$ and $\pi/2$. One bit. The public bit.

---

## Why a negative result is a good result

There is a natural reaction to all this: so what? A quantity that could have revealed something doesn't. Isn't that a non-event?

It isn't, for three reasons.

**First, because the candidate was serious.** Ideas for attacking factorization through analytic invariants are perennial, and Gauss sums are the most natural such invariant in existence: they have exactly square-root size, they factor along the prime decomposition of the modulus, and their prime-level constituents visibly encode $p \bmod 4$. Everything about the setup says the semiprime sum should remember more than $N$ does. A vague "probably not" is worth much less than a proof.

**Second, because the reason is structural, not statistical.** The collapse is not a matter of the leak being small, or hard to detect, or drowned in noise. It is an identity. The information is not hidden; it is not there. This is the strongest form a negative result can take, and it tells you something about *why* invariants of this type will fail: the sign that a naive count says should distinguish the classes is the same sign that reciprocity spends to make the classes look alike.

**Third, because it says where to look next.** The proof identifies the exact numerical coincidence responsible: in the quadratic case the reciprocity sign $(-1)^{\frac{p-1}{2}\frac{q-1}{2}}$ happens to equal the product of the phase units contributed by the prime sums. That is a coincidence of the group $\{\pm 1\}$ — of order two, small enough for two independent-looking signs to be forced to coincide. Move to cubic characters and the reciprocity sign lives among the Eisenstein integers, in a group of order three, where no such identity can hold uniformly. Twist the exponential by $n + n^{-1}$ instead of $n$, and you get Salié sums, whose evaluation involves square roots of $N$ modulo the individual primes — objects that genuinely do know the factorization. The negative result acts like a map: it marks the dead end, and it marks it precisely enough to point at the roads that are not dead ends.

---

## A closing image

Here is the picture I keep coming back to. You have $N$ arrows around a circle, each pointing at a root of unity, each stamped with a plus or a minus by an arithmetic rule that intimately depends on the secret primes $p$ and $q$. Every one of those signs is factorization-sensitive; change a prime and the pattern of signs changes utterly. You add them all up, and out of that riot of factor-dependent data comes an arrow of length exactly $\sqrt N$ pointing along one of just two directions, chosen by a fact about $N$ that a child could read off.

The interference is perfect, and it is perfectly discreet. Everything the arrows knew about $p$ and $q$ cancels — not approximately, not on average, but exactly, and for a reason: the last surviving sign is spent by quadratic reciprocity, buying nothing but a return to the axis it started on.
