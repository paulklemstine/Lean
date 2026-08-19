# Minimum Uncertainty Is a Subgroup

## How a single equation forces a hidden group to appear

There is a certain kind of theorem that mathematicians find irresistible: you assume nothing but an *equation*, and out of it walks a *structure*. You did not ask for a group. You did not ask for symmetry. You asked only that some quantity be as small as it can possibly be — and the answer turns out to be that the object you were studying was secretly a group all along.

This article is about two such theorems, and about the discovery that they are the same theorem wearing different clothes.

---

## Part I: A drum that cannot be everywhere at once

Suppose you have a finite collection of $N$ locations arranged in a circle — think of $N$ pixels on a ring, or $N$ time slots in a repeating schedule, or $N$ atoms in a crystal with periodic boundary conditions. A *signal* on this circle is just an assignment of a complex number $f(x)$ to each location $x$.

Every such signal can be decomposed into pure oscillations. On a ring of $N$ points, the pure oscillations are the functions
$$x \longmapsto e^{2\pi i k x / N}, \qquad k = 0, 1, \dots, N-1,$$
and the recipe for extracting how much of each oscillation your signal contains is the *discrete Fourier transform*:
$$\hat f(k) \;=\; \sum_{x} e^{-2\pi i k x / N} f(x).$$

Now here is the classical tension. Call the **support** of $f$, written $\operatorname{supp} f$, the set of locations where $f$ is not zero, and call $\operatorname{supp}\hat f$ the set of frequencies actually present. A signal concentrated at a single point — a click, a spike, a delta — has *every* frequency in it: $|\operatorname{supp} f| = 1$ but $|\operatorname{supp} \hat f| = N$. A pure tone is the reverse: one frequency, but it is nonzero everywhere. You cannot have both. The precise statement of this trade-off, the **Donoho–Stark uncertainty principle**, says that for every signal $f$ that is not identically zero,
$$|\operatorname{supp} f| \cdot |\operatorname{supp}\hat f| \;\ge\; N.$$

This is the discrete cousin of Heisenberg's uncertainty principle, and it is one of the pillars of modern signal processing: it is the reason a sparse signal can be reconstructed from few measurements, and it is at the heart of compressed sensing.

The inequality is easy to state. The interesting question is: **when is it an equality?**

## Part II: The shape of perfection

A signal $f$ is called **extremal** when the product of the two support sizes is exactly $N$ — when it is as simultaneously concentrated in space and in frequency as the laws of Fourier analysis allow.

We already know some examples. Suppose the $N$ points form a group $G$ (on the ring, $G = \mathbb{Z}/N$, and the group operation is addition modulo $N$). Take a **subgroup** $K \le G$ — for instance, on the ring with $N = 12$, the four points $\{0, 3, 6, 9\}$. Its indicator function, which is $1$ on $K$ and $0$ elsewhere, is extremal: its transform is supported exactly on the *annihilator* $K^{\perp}$, the set of frequencies that are trivial on $K$, and a Plancherel computation shows $|K| \cdot |K^{\perp}| = N$ on the nose. Now translate that indicator to sit on a coset $a + K$ instead, multiply it by a pure oscillation $\chi$, and scale by a nonzero constant $c$. Translation and modulation do nothing to the two support sizes — translation in space becomes modulation in frequency and vice versa — so the whole family
$$f(x) \;=\; c \cdot \chi(x) \cdot \mathbf{1}_{a + K}(x)$$
consists of extremal signals. Call these **coset modulations**.

The result at the heart of this work is that there are no others.

> **Classification of the extremals.** Let $G$ be a finite abelian group of order $N$ and let $f : G \to \mathbb{C}$ be a nonzero function. Then $|\operatorname{supp} f| \cdot |\operatorname{supp}\hat f| = N$ if and only if there exist a subgroup $K \le G$, a character $\chi$, an element $a \in G$, and a nonzero constant $c$ such that $f(x) = c\,\chi(x)$ for $x \in a + K$, and $f(x) = 0$ otherwise.

Read that again, because the direction that matters is the one that starts with a bare numerical coincidence. You are handed a function. You count two finite sets and multiply. The product happens to be $N$. And from that single arithmetic fact you may conclude that the function's support is a coset of a subgroup, that its modulus is constant on that coset, and that its phase is a character. The group appears out of nowhere.

How? The proof is an *equality analysis*: a chain of inequalities is written down whose two ends are both equal, so every link must be tight, and each tight link is a rigidity statement.

Let $M$ be the largest value of $|f|$, attained at some point $m$, and let $S = \sum_{x \in \operatorname{supp} f} |f(x)|$. Three easy bounds:

1. $S \le |\operatorname{supp} f| \cdot M$, since each term is at most $M$.
2. $|\hat f(\psi)| \le S$ for every frequency $\psi$, since the characters have modulus one.
3. Fourier inversion at the peak, $N \cdot f(m) = \sum_{\psi \in \operatorname{supp}\hat f} \psi(m)\hat f(\psi)$, gives $N M \le \sum_{\psi \in \operatorname{supp}\hat f}|\hat f(\psi)| \le |\operatorname{supp}\hat f| \cdot S$.

Chaining these: $N M \le |\operatorname{supp}\hat f| \cdot S \le |\operatorname{supp}\hat f| \cdot |\operatorname{supp} f| \cdot M$. If $f$ is extremal, the right-hand end equals $NM$, and the whole chain collapses to equalities. Collapse (1) says $|f|$ is *flat*: constant modulus $M$ across its support. Collapse (2), applied to a triangle inequality among $|\operatorname{supp} f|$ complex numbers all of the same modulus, says those numbers are all *equal*: for each surviving frequency $\psi$, the quantity $\overline{\psi(x)}f(x)$ does not depend on $x$. That is a phase-alignment statement, and it is the whole ballgame.

For pick a point $a$ in the support. Alignment says $f(x) = \psi(x - a) f(a)$ for every $x$ in the support and every surviving frequency $\psi$. So *all* the surviving frequencies agree on every difference $x - a$ — hence on the subgroup $K$ they generate. That forces the support into the coset $a + K$, and it forces the frequency support into a single coset of the annihilator $K^{\perp}$. Counting, $|\operatorname{supp} f| \le |K|$ and $|\operatorname{supp}\hat f| \le |K^{\perp}|$, while $|K| \cdot |K^{\perp}| = N = |\operatorname{supp} f| \cdot |\operatorname{supp}\hat f|$. Two inequalities whose products agree must both be equalities. Everything is pinned. Reading off the values gives $f = c\,\chi\,\mathbf{1}_{a+K}$.

## Part III: The other rigidity — Poisson summation

Change the subject, apparently. Poisson summation is the identity that lets you trade a sum over a lattice for a sum over the dual lattice; it powers the theory of theta functions and the analytic study of the Riemann zeta function. In a finite abelian group $G$ of order $N$ it reads, for a subgroup $H$ and *every* test function $f$,
$$N \sum_{x \in H} f(x) \;=\; |H| \sum_{\psi \in H^{\perp}} \hat f(\psi).$$

Beautiful — but is the pairing (subgroup, annihilator) really *necessary*? Perhaps some clever pair of a set $S \subseteq G$ and a set $T$ of frequencies, with no group structure at all, also satisfies
$$N \sum_{x \in S} f(x) \;=\; |S| \sum_{\psi \in T} \hat f(\psi) \quad \text{for all } f.$$
Call such a pair a **Poisson pair**. The answer is a flat no.

> **Rigidity of Poisson summation.** If $(S, T)$ is a Poisson pair with $S$ nonempty, then $S$ is a subgroup of $G$ and $T$ is exactly its annihilator. In particular $0 \in S$ and $|S| \cdot |T| = N$.

The proof is a lovely two-line-plus-epsilon argument. Feed the identity the Dirac spikes $\delta_y$, one for each $y \in G$. Because $\widehat{\delta_y}(\psi) = \overline{\psi(y)}$, the identity becomes
$$N \cdot \mathbf{1}_S(y) \;=\; |S| \sum_{\psi \in T}\psi(y).$$
Put $y = 0$: every character is $1$ at $0$, so $N = |S| \cdot |T|$. Therefore the displayed identity says $\sum_{\psi \in T} \psi(y) = |T| \cdot \mathbf{1}_S(y)$. Now, $|T|$ complex numbers of modulus one summing to exactly $|T|$ can only be all equal to $1$ — this is the equality case of the triangle inequality. So for $y \in S$, every $\psi \in T$ satisfies $\psi(y) = 1$; and for $y \notin S$ the sum is $0$, so certainly not all the $\psi(y)$ are $1$. That means $S$ is precisely the set $\{y : \psi(y) = 1 \text{ for all } \psi \in T\}$ — and *that* set is visibly closed under addition and negation. It is a subgroup. The count $|S| \cdot |T| = N$ then upgrades the obvious inclusion $T \subseteq S^{\perp}$ to an equality.

A pleasant corollary: since the argument used only $N$ scalar equations, **Poisson summation is a finite test**. If the identity holds for the $N$ Dirac spikes, it holds for every function whatsoever — and hence the full structure theorem applies.

## Part IV: One object, two faces

The two rigidity theorems now merge. On the one hand, every Poisson pair is (subgroup, annihilator). On the other hand, subgroup indicators are exactly the extremals with $f(a) = 1$, up to modulation and translation. Putting the two together: **every Poisson pair is the support pair $(\operatorname{supp} f, \operatorname{supp}\hat f)$ of an extremal function, and conversely.** The subgroup behind either phenomenon is unique. The extremals of the uncertainty principle and the valid Poisson summation formulas are the same mathematical object, counted twice.

## Part V: Arithmetic falls out

Once you know the extremals are coset modulations, you can *do arithmetic with them*.

**Lagrange rigidity.** The support of an extremal function is a coset, so its size is the order of a subgroup, so — by Lagrange's theorem — it divides $N$. And the frequency support has size exactly $N/|\operatorname{supp} f|$: the two support sizes are complementary divisors.

**A gap in the uncertainty principle.** Turn that around. If $s = |\operatorname{supp} f|$ does *not* divide $N$, then equality is impossible, so the inequality has room to spare — and an integrality argument says exactly how much:
$$|\operatorname{supp} f| \cdot |\operatorname{supp}\hat f| \;\ge\; N + \bigl(s - (N \bmod s)\bigr),$$
equivalently $|\operatorname{supp}\hat f| \ge \lceil N/s \rceil$. On a ring of $12$ points, a signal supported on $5$ points has $5 \nmid 12$, so it can never be extremal; the raw bound only says $|\operatorname{supp}\hat f| \ge 12/5 = 2.4$, while the sharpened one says $|\operatorname{supp}\hat f| \ge 3$ and the product overshoots $12$ by at least $5 - (12 \bmod 5) = 3$. On a group whose order is prime, *every* intermediate support size is forbidden: the only extremals are the modulated spikes and the multiples of pure tones, and everything else misses the bound by at least one.

**The extremal spectrum.** Which sizes are achievable? Exactly the divisors:

> **Extremal spectrum theorem.** For a finite abelian group $G$ of order $N$ and a natural number $d$, there is a nonzero extremal function with $|\operatorname{supp} f| = d$ if and only if $d \mid N$.

One direction is Lagrange rigidity. The other needs a genuine piece of group theory — the *converse of Lagrange's theorem for abelian groups*: a finite abelian group has a subgroup of every order dividing its own. (This is false for general finite groups: the alternating group $A_5$ has order $60$ but no subgroup of order $30$.) Proving it by induction, via Cauchy's theorem and the correspondence between subgroups of a quotient and subgroups containing the kernel, removes the last cyclicity assumption and makes the spectrum theorem universal. More precisely, a pair $(s,t)$ arises as $(|\operatorname{supp} f|, |\operatorname{supp}\hat f|)$ for an extremal $f$ precisely when $st = N$.

**Primality, detected by uncertainty.** Combining both directions yields a curiosity: $N$ is prime *if and only if* every extremal function on $G$ has support of size $1$ or $N$. Primality of the order can be read off from the geometry of the minimum-uncertainty states alone.

**And a limit to what uncertainty can see.** Two finite abelian groups with the same extremal spectrum have the same order — the spectrum *is* the divisor set — but conversely, equal order forces equal spectrum. So the spectrum knows the order and nothing more. The finer invariant, the actual family of extremal *supports*, does better: on the cyclic group $\mathbb{Z}/4$ there are exactly $2$ extremal supports of size $2$, while on the Klein group $\mathbb{Z}/2 \times \mathbb{Z}/2$ there are $6$ (two cosets for each of three subgroups of order two). Same spectrum, different geometry.

## Part VI: A closed algebra

Extremality is a fragile-looking analytic condition, so it is startling that the extremal class is closed under the natural operations.

*Products.* If $u$ and $v$ are extremal, then $uv$ is either identically zero or again extremal. This is not a soft statement — the class of functions with any prescribed support size is certainly not closed under products. It works because an extremal function is a coset modulation, and the intersection of a coset of $K$ with a coset of $K'$ is either empty or a coset of $K \cap K'$; the characters multiply, giving $\chi + \chi'$.

*Convolutions.* Dually, $u * v$ is zero or extremal, now with subgroup $K + K'$, because $(K + K')^{\perp} = K^{\perp}\cap K'^{\perp}$.

*Convolution powers.* Repeatedly convolving an extremal function with itself can never produce zero, since the frequency support is preserved exactly; so every convolution power is extremal, and the support size is a conserved quantity of the dynamics.

*Fourier transform.* Extremality is invariant under the transform itself: if $f$ is extremal on $G$, then $\hat f$ is extremal on the dual group.

Taken together, the minimum-uncertainty states form a rigid algebraic universe — a groupoid of coset modulations, stable under multiplication, convolution and duality.

## Part VII: The probabilistic punchline

Finally, specialize to probability. Let $p$ be a probability distribution on $G$: $p(x) \ge 0$ and $\sum_x p(x) = 1$. It is a legitimate signal, so it has a Fourier transform, and the uncertainty principle applies. What does a **minimum-uncertainty distribution** look like?

> **Extremal distributions are uniform on cosets.** If a probability distribution on a finite abelian group attains equality in the uncertainty principle, then it is the uniform distribution on a coset of a subgroup.

The classification hands this to us: $p = c\,\chi\,\mathbf{1}_{a+K}$; being real and nonnegative pins the phase, flatness makes it constant on its support, and $\sum p = 1$ fixes the constant to $1/|K|$. So among all distributions on a cyclic group of $12$ states, the ones that are simultaneously as concentrated as possible in state and in frequency are precisely: the point masses, the uniform distributions on the two-element cosets $\{a, a+6\}$, on the three-element cosets, the four-element cosets, the six-element cosets, and the uniform distribution on everything. Nothing else, ever. A distribution on $5$ of the $12$ states cannot be a minimum-uncertainty state, no matter how you weight it, because $5 \nmid 12$.

There is a slogan here, and it is worth remembering: **in a finite abelian world, the minimum-uncertainty states are exactly the uniform distributions on cosets.** Perfect localization in both domains is not an analytic accident to be optimized toward — it is an algebraic condition, and the objects that satisfy it are subgroups in disguise.

---

## Why it matters

Compressed sensing lives on the uncertainty principle: a signal cannot be sparse in both domains, so a sparse signal has a rich spectrum, so a few frequency samples suffice to identify it. The extremal functions are precisely the *worst cases* — the signals for which the bound is tight and reconstruction guarantees are sharpest. Knowing exactly what they are converts a soft analytic obstruction into a hard arithmetic one: on a group of prime order there are essentially no bad cases, while on a highly composite group the bad cases form a rich lattice indexed by the subgroups.

Poisson summation is the workhorse of lattice sums in number theory and crystallography. Its rigidity says that the lattice structure is not a convenient hypothesis but a *consequence*: any sampling scheme with a Poisson-type exchange formula is a lattice, whether you planned it that way or not.

And the small computation that anchors it all is easy to check by hand. On a ring of four points, enumerate every function taking values in $\{0, 1, -1, i, -i\}$ — all $5^4 = 625$ of them. The uncertainty product never dips below $4$. Exactly $48$ of them are extremal. Their support sizes are $1$, $2$ and $4$ — sixteen of each — and not a single one has support of size $3$, because $3$ does not divide $4$. Every extremal support is a coset; every extremal has constant modulus on its support; products and convolutions of extremals are zero or extremal. The theory predicts each of those counts exactly.

The equation forced the group to appear, and then the group told us everything else.
