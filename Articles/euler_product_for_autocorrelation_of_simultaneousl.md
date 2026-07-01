# Who Can See You? The Hidden Arithmetic of Lattice Points in Plain Sight

Imagine standing in an infinite orchard where trees are planted at every point with whole-number coordinates: at $(0,0)$, at $(1,0)$, at $(2,3)$, and so on, stretching out forever in every direction. This is the integer lattice $\mathbb{Z}^k$. Now ask a simple question: from where you stand, which trees can you actually *see*? A tree is hidden if another tree stands exactly between you and it, blocking the line of sight. This innocent-looking puzzle — the problem of **visible lattice points** — turns out to hide a beautiful piece of number theory, one that connects prime numbers, geometry, and even the mathematics of how crystals scatter light.

This article tells the story of a single, surprisingly powerful idea: **visibility is a question that primes answer one at a time.** From that idea flows an exact formula — an *Euler product* — for how the visible points correlate with themselves, and a subtle warning about a natural-looking shortcut that quietly fails.

## When can you see a lattice point?

Stand at the origin and look toward the point $v = (a, b)$. The line of sight is blocked by another lattice point precisely when $v$ is a whole-number multiple of some closer lattice point — for instance, $(4, 6)$ is hidden behind $(2, 3)$, because $(4,6) = 2 \cdot (2,3)$. The clean way to say this: $v$ is **visible from the origin** exactly when the greatest common divisor of its coordinates equals $1$. We call such a vector *primitive*. So $(2,3)$ is visible (their gcd is $1$), but $(4,6)$ is not (their gcd is $2$).

More generally, a point $v$ is visible from an observer sitting at $x$ when the difference $v - x$ is primitive, i.e. $\gcd(v - x) = 1$, where by $\gcd$ of a vector we mean the gcd of all its coordinates.

Now here is the twist that drives our whole story. Suppose you don't have one observer, but a whole finite crew of them scattered across the lattice — a set $S = \{x_1, x_2, \dots, x_m\}$ of vantage points. Which trees are visible *to every single observer at once*? These are the **simultaneously visible points**:
$$V_S = \{\, v \in \mathbb{Z}^k : \gcd(v - x) = 1 \text{ for every } x \in S \,\}.$$
When $S$ is just the single point $\{0\}$, this is the classical set of visible lattice points. Allowing many observers is where new mathematics begins.

## Primes hold the keys

The engine behind everything is a translation of the visibility condition into the language of prime numbers. Whether or not $\gcd(v - x) = 1$ has nothing to do with large, complicated numbers; it is decided independently by each prime.

Here is the precise statement, which we might call the **Local–Global Bridge**:

> **A vector is primitive if and only if it is nonzero modulo every prime.** That is, $\gcd(w) = 1$ exactly when, for each prime $p$, at least one coordinate of $w$ is not divisible by $p$.

Why is this true? A prime $p$ divides $\gcd(w)$ precisely when it divides *every* coordinate of $w$ — equivalently, when $w$ collapses to the zero vector after we reduce each coordinate modulo $p$. So the gcd equals $1$ exactly when no prime manages to divide all coordinates at once, which is to say $w$ survives as a nonzero residue vector modulo every prime. A blocked line of sight is nothing more than a prime that has "captured" all the coordinates simultaneously.

This is the moment the problem becomes tractable. Global coprimality — a statement about the infinitely many integers dividing a vector — dissolves into a family of independent, finite, prime-by-prime checks. Each prime $p$ only ever sees the vector through the tiny window of its residues in $\mathbb{Z}/p\mathbb{Z}$.

## Counting correlations: the Euler product

The deepest questions about a random-looking set are not about individual points but about *patterns* — how the set overlaps with shifted copies of itself. Fix a shift $z \in \mathbb{Z}^k$ and ask: among all points in a huge box $[-N, N]^k$, what fraction lie in $V_S$ *and* also lie in $V_S$ after we slide everything by $z$? Taking the box to infinity gives the **autocorrelation**
$$\gamma_S(z) = \lim_{N \to \infty} \frac{\bigl|\, V_S \cap (V_S + z) \cap [-N, N]^k \,\bigr|}{(2N+1)^k}.$$
It measures the density of points $v$ that are simultaneously visible from $S$ and whose shift-back $v - z$ is *also* simultaneously visible from $S$.

The Local–Global Bridge turns this into a counting problem prime by prime. A point $v$ contributes to $\gamma_S(z)$ only if, for every prime $p$, the residue of $v$ avoids a certain forbidden list. Being visible from all of $S$ forbids $v$ from matching any residue in $S_p$ — the image of $S$ modulo $p$ — and having $v - z$ visible from all of $S$ forbids $v$ from matching any residue in $(S - z)_p$. So the fraction of residues modulo $p$ that are *allowed* is
$$1 - \frac{\bigl|\, S_p \cup (S - z)_p \,\bigr|}{p^k},$$
where $S_p$ and $(S-z)_p$ are the images of $S$ and of the shifted set $S - z$ inside the finite grid $(\mathbb{Z}/p\mathbb{Z})^k$. Because different primes impose *independent* constraints — a consequence of the Chinese Remainder Theorem, which lets us stitch together residue conditions across coprime moduli — these per-prime survival probabilities multiply. The result is a clean **Euler product**:
$$\gamma_S(z) = \prod_{p \text{ prime}} \left(1 - \frac{\bigl|\, S_p \cup (S - z)_p \,\bigr|}{p^k}\right).$$

For the classical case $S = \{0\}$ and shift $z = 0$, the set $S_p \cup (S-z)_p$ is just the single residue $\{0\}$, so each factor is $1 - p^{-k}$, and the product becomes $\prod_p (1 - p^{-k}) = 1/\zeta(k)$, the famous reciprocal of the Riemann zeta value. The density of visible lattice points in the plane is $1/\zeta(2) = 6/\pi^2 \approx 0.608$ — about three points in five are in plain sight. Our formula is the sweeping generalization of this classic to any number of observers and any shift.

## A cautionary tale: the shortcut that fails

There is a tempting way to try to shortcut the Euler product. The whole formula is multiplicative across primes, so one might guess that the *local factor itself* behaves multiplicatively — that if you combined two primes $p$ and $q$ into a single modulus $pq$, the "local density" $1 - |S_{pq}|/(pq)^k$ would simply be the product of the local densities at $p$ and at $q$. It sounds plausible. It is false.

The reason is a genuine subtlety about how the *image of a fixed finite set* behaves under reduction. Consider the humblest possible example: on the line $\mathbb{Z}^1$, take $S = \{0, 1\}$ with $p = 2$ and $q = 3$. Modulo $2$, the set $\{0,1\}$ maps to $\{0, 1\}$ — two residues. Modulo $3$, it also maps to two residues. And modulo $6$, it *still* maps to just two residues, $\{0, 1\}$, not the four you'd get from a Chinese-Remainder "product" grid. So the local density at $6$ works out to $1 - 2/6 = 2/3$, while the product of the local densities at $2$ and $3$ is $(1 - 2/2)(1 - 2/3) = 0 \cdot \tfrac13 = 0$. Two-thirds is not zero. The shortcut collapses.

The lesson is precise and worth savoring: the image of a *specific* finite set of points is not a rectangular "cylinder" set, so its size does not factor across coprime moduli. What genuinely multiplies is not the size of one fixed set's image, but the **density of primitive residue vectors** — a Jordan-totient-style quantity counting how many residue vectors modulo $n$ are coprime to $n$. That density *is* multiplicative: the fraction of primitive vectors modulo $pq$ is the product of the fractions modulo $p$ and modulo $q$. This is the true arithmetic backbone of the Euler product, and distinguishing it from the false shortcut is one of the quiet victories of getting the details exactly right.

## From points to prisms: why physicists care

This might feel like a recreational puzzle, but the autocorrelation $\gamma_S(z)$ is exactly the quantity a physicist reaches for when studying **diffraction** — the pattern of bright spots produced when waves scatter off a structured arrangement of points, as X-rays do off a crystal. The diffraction pattern is, mathematically, the Fourier transform of the autocorrelation. A structure whose diffraction consists of sharp, isolated bright spots (rather than a diffuse smear) is said to have a **pure point spectrum** — the hallmark of long-range order, the signature that distinguishes a crystal, or a quasicrystal, from an amorphous glass.

The Euler product tells us something remarkable: because $\gamma_S(z)$ factors as a product of simple, periodic, prime-by-prime terms, it is an *almost-periodic* function of the shift $z$. And almost-periodic autocorrelations are precisely the ones that diffract into pure point spectra. The set of simultaneously visible lattice points — despite looking sparse and irregular, riddled with the pseudo-random gaps left by every prime — carries hidden long-range order, order that a diffraction experiment would reveal as a crisp constellation of peaks. The visible points are a mathematical crystal in disguise.

## What comes next

The Local–Global Bridge, the complement-count local factor, and the Chinese-Remainder multiplicativity together form a skeleton on which a fuller theory can be built. Three natural frontiers stand out.

First, **existence and value of the density**: one expects that for every dimension $k \ge 2$, every finite observer set $S$, and every shift $z$, the limit $\gamma_S(z)$ genuinely exists and equals the Euler product. The finite complement-count identity is exactly the numerator of each Euler factor; the remaining work is a sieve argument controlling the tail of the product, which converges comfortably because $\sum_p p^{-k}$ is finite once $k \ge 2$.

Second, **pure-point diffraction**: the almost-periodicity handed to us by the multiplicative structure should upgrade, via a Fourier argument, to a theorem that the diffraction measure of $V_S$ is pure point, with peaks located at rational positions dictated by the moduli present in $S$.

Third, a notion of **visibility capacity**: enlarging the observer set can only thin the crowd of simultaneously visible points, and the density depends on $S$ only through its finite residue images. Two observer sets that look wildly different geometrically but share the same residues modulo every prime are density-indistinguishable — an invariant, a "capacity," attached to $S$ that ignores geometry and remembers only arithmetic.

From a question a child could ask — *which trees can I see through the orchard?* — we arrive at prime numbers, zeta values, the Chinese Remainder Theorem, and the diffraction of crystals. That is the quiet wonder of this corner of mathematics: look closely enough at what is visible, and you find the primes staring back.
