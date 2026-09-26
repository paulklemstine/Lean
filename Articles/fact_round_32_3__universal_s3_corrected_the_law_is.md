# One Bit of Sign: Why Every $S_3$ Cubic Whispers the Same Secret — in Its Own Accent

## Two polynomials that look nothing alike

Take two innocent-looking cubic polynomials:

$$f(x) = x^3 - 2 \qquad\text{and}\qquad g(x) = x^3 + x + 1.$$

The first is the equation of the cube root of two, a number the ancient Greeks tried and failed to construct with ruler and compass when they were asked to "double the cube". The second is a random-looking trinomial with no famous history. Yet they share a hidden skeleton. Each has three complex roots, and the symmetries that shuffle those roots — the *Galois group* — are, in both cases, all six permutations of three objects. Mathematicians call this group $S_3$.

Now play a game that number theorists have played since Gauss. Pick a prime $p$ and look at the polynomial "modulo $p$": do arithmetic on the clock with $p$ hours, and ask how many of the $p$ possible hour-values $x$ make the polynomial vanish. For a cubic there are three possible answers that matter:

* **three roots** — the polynomial splits completely (type $1+1+1$);
* **exactly one root** — one linear factor times an irreducible quadratic (type $1+2$);
* **no roots** — the polynomial stays irreducible (type $3$).

For example, modulo $5$ the pure cubic $x^3 - 2$ has exactly one root ($3^3 = 27 \equiv 2$), while $x^3 + x + 1$ has none. Modulo $11$ each has exactly one root. Modulo $43$, remarkably, $x^3-2$ has three roots ($20$, $32$ and $34$), while $x^3+x+1$ has only one.

This "splitting type" is a fingerprint the prime leaves on the polynomial. A deep theorem — the Chebotarev density theorem — says that as $p$ ranges over all primes, the three types occur with frequencies $1/6$, $1/2$ and $1/3$, which are precisely the proportions of the identity, the three transpositions and the two 3-cycles among the six elements of $S_3$. Counting roots of $x^3-2$ and $x^3+x+1$ at the primes up to $20{,}000$ gives about $0.16$, $0.50$ and $0.33$ for both polynomials. They behave like identical twins.

The question behind this work is: **how much does the splitting type tell you, and does the answer depend on which polynomial you picked?**

## The sign of a shuffle

Every permutation has a *sign*: $+1$ if it can be built from an even number of swaps, $-1$ if it needs an odd number. In $S_3$, the identity and the two 3-cycles are even; the three transpositions are odd. The sign is a *character* of the group: it respects composition, turning the six-element group into the two-element group $\{+1, -1\}$.

When you reduce a polynomial modulo $p$, number theory hands you a particular permutation of the roots, the *Frobenius element* of $p$. Its cycle shape is the splitting type. So the sign of Frobenius is the question "is the splitting type $1+2$, or not?" Exactly one root means odd; zero or three roots mean even.

Here is the first, completely group-theoretic observation. Think of the Frobenius element as a random draw from $S_3$ (that's what Chebotarev says, statistically). The sign is a fair coin: three of the six permutations are even and three are odd. So the sign carries exactly **one bit** of information, in Shannon's sense. And the splitting type — the cycle shape — pins the sign down completely. In information-theoretic language, the mutual information between the sign and the type is

$$I(\text{sign}\,;\,\text{type}) = 1 \text{ bit, exactly.}$$

## The law is universal

The first main result says that nothing about this depends on the polynomial, or even on the group being $S_3$.

> **Universal Sign-Channel Theorem.** Let $G$ be any finite group, drawn uniformly at random. Let $\chi : G \to \{\pm 1\}$ be any surjective character (a homomorphism onto the two-element group), and let $T$ be any "type" function on $G$ such that elements of equal type always have equal character value. Then the type carries exactly one bit of information about the character: $I(\chi\,;\,T) = 1$.

The reason is short and elegant. Two facts combine:

1. **A homomorphism pushes the uniform distribution to the uniform distribution.** Every fibre of $\chi$ is a coset of the kernel, and all cosets have the same size. So if $\chi$ hits both $+1$ and $-1$, each value comes up with probability exactly $1/2$, and the entropy of $\chi$ is $\log_2 2 = 1$ bit. More generally, the entropy of any homomorphism of a uniformly random group element is $\log_2$ of the size of its image.
2. **If you know the type, you know the character.** That makes the leftover uncertainty $H(\chi \mid T)$ zero, so the mutual information equals the full entropy.

This immediately covers every $S_3$-field — $x^3-2$, $x^3+x+1$, and every other cubic with full Galois group — and, for that matter, every symmetric group $S_n$ with $n \ge 2$, where the sign of a permutation is always a function of its cycle type. It is also sharp: *no* type function whatsoever can carry more than one bit about a $\pm1$-valued character, because one bit is all the character has. A badly chosen type can carry less. In $S_3$, the statement "the permutation fixes the first root" carries zero bits about the sign: among the two permutations that fix it, one is even and one is odd, and among the four that move it, two are even and two are odd.

Two companion laws come along for free:

* **The semiprime pair channel.** Take two independent Frobenius elements $g$ and $h$ (think of two primes $p$ and $q$ forming a semiprime $pq$) and the product character $\chi(g)\chi(h)$. The pair of types $(T(g), T(h))$ again carries exactly one bit about it.
* **Flatness of independent coordinates.** If the group is a product $S_3 \times C$ — as happens when you combine the cubic field with an unrelated abelian field, such as a cyclotomic field for a modulus that has nothing to do with the cubic — then the abelian coordinate carries *zero* bits about the $S_3$ cycle type. Unrelated moduli are flat.

So the *shape* of the channel is universal. It is dictated by the group alone.

## The plot twist: where can you read the bit?

The experiments that prompted this work made a sharper claim: that for the new field of $x^3-2$, the sign bit is the character "$p \bmod 3$". That claim is true, and a remarkable fact in its own right:

> **Pure Cubic Theorem.** For every prime $p > 3$, the polynomial $x^3 - 2$ has exactly one root modulo $p$ if and only if $p \equiv 2 \pmod 3$.

The proof is a pleasant piece of clock arithmetic. If $p \equiv 2 \pmod 3$, then $3$ does not divide $p - 1$, and cubing is a *bijection* of the integers modulo $p$. (Explicitly, $x^{2p-1} = x$ for every $x$ by Fermat's little theorem, and $2p - 1$ is a multiple of $3$, so raising to the power $(2p-1)/3$ undoes cubing.) Every number, $2$ included, has exactly one cube root. If instead $p \equiv 1 \pmod 3$, there is a primitive cube root of unity $\omega$, and any cube root $x$ of a nonzero $a$ comes with two siblings $\omega x$ and $\omega^2 x$. So $x^3 = a$ has either no root or three, never exactly one.

So for $x^3-2$ the sign bit lives at *modulus 3*: learn the remainder of $p$ on division by $3$ and you know the sign of Frobenius. On the four primes $\{5, 7, 11, 13\}$, two with each remainder, the channel from "$p \bmod 3$" to the splitting type carries exactly one bit. On the four semiprimes built from $\{5, 7\}$, the pair of splitting types determines $pq \bmod 3$ and again carries exactly one bit.

But is "modulus 3" part of the universal law? **No.** Here is the counterexample, and it is tiny:

$$5 \equiv 11 \equiv 2 \pmod 3, \qquad\text{but}\qquad x^3 + x + 1 \text{ has no root mod } 5 \text{ and exactly one root mod } 11.$$

(Modulo $11$, the root is $x = 2$, since $8 + 2 + 1 = 11$.) So for the trinomial, the prime $5$ has an even Frobenius and $11$ has an odd one, even though they agree modulo $3$. On the pair $\{5, 11\}$, the "$p \bmod 3$" channel of the trinomial carries **zero** bits.

Where, then, does the trinomial keep its sign bit? At modulus **31**:

> **Trinomial Theorem.** For every prime $p$ other than $2$ and $31$, the polynomial $x^3 + x + 1$ has exactly one root modulo $p$ if and only if $p$ is *not* a perfect square modulo $31$.

Check: $5 \equiv 6^2 \pmod{31}$ is a square, and indeed there is no root mod $5$; $11$ is not a square mod $31$, and indeed there is one root mod $11$. On $\{5, 11\}$ the "is $p$ a square mod 31?" channel carries exactly one bit.

## The hidden messenger: the discriminant

Why $3$ for one polynomial and $31$ for the other? The answer is the oldest invariant of a polynomial, its *discriminant*. For the "depressed" cubic $x^3 + ax + b$ it is

$$\Delta = -4a^3 - 27b^2.$$

For $x^3 - 2$ we get $\Delta = -108 = -3 \cdot 6^2$; for $x^3 + x + 1$ we get $\Delta = -31$. The discriminant is the square of the product of all root differences, $\delta = (r_1-r_2)(r_1-r_3)(r_2-r_3)$, and a transposition of the roots flips the sign of $\delta$ while a 3-cycle leaves it alone. That is the whole connection between discriminants and signs, and it becomes a precise statement modulo $p$:

> **Sign Law (Stickelberger's parity law for cubics).** Let $p$ be an odd prime and $x^3 + ax + b$ a cubic over the integers modulo $p$ with nonzero discriminant $\Delta$. Then the cubic has exactly one root modulo $p$ if and only if $\Delta$ is not a square modulo $p$.

The proof splits into two halves, each with its own charm.

**When the cubic has a root $r$.** Dividing out the root leaves the quadratic $x^2 + rx + (a + r^2)$, and a short computation shows

$$\Delta = (-3r^2 - 4a)\,(3r^2 + a)^2.$$

The first factor is exactly the discriminant of the leftover quadratic, and the second factor is a square. So $\Delta$ is a square precisely when the quadratic's discriminant is, which (by the quadratic formula, available since $2$ is invertible) is precisely when the quadratic has roots — that is, when the cubic has a second root. This half works over *any* field in which $2 \ne 0$.

**When the cubic has no root.** Then it is irreducible, and we move to the bigger field obtained by adjoining one abstract root $r$. There the Frobenius map $x \mapsto x^p$ sends roots to roots, fixes nothing outside the prime field, and therefore cycles the three roots $r \to r^p \to r^{p^2} \to r$. A cyclic shuffle of three objects is even, so it fixes $\delta$. And an element fixed by Frobenius must already live in the integers modulo $p$: the $p$ ordinary residues already exhaust all $p$ possible roots of $x^p - x$, leaving no room for another. Hence $\delta$ is an honest residue modulo $p$, and $\Delta = \delta^2$ is a square. In the language of permutations: no roots means a 3-cycle, which is even.

Combining both halves gives the sign law. Applied to our two polynomials:

* For $x^3-2$: exactly one root $\iff$ $-108$ is a non-square $\iff$ $-3$ is a non-square (because $108 = 3 \cdot 36$) $\iff$ $p \equiv 2 \pmod 3$. As a bonus, running the argument backwards *proves* the classical fact that $-3$ is a square modulo a prime $p>3$ exactly when $p \equiv 1 \pmod 3$ — derived here from a cube-root problem.
* For $x^3+x+1$: exactly one root $\iff$ $-31$ is a non-square mod $p$. Then Gauss's law of quadratic reciprocity, which for $-31$ reads $\left(\frac{-31}{p}\right) = \left(\frac{p}{31}\right)$, converts this into a condition on $p \bmod 31$.

So the sign bit of the trinomial depends only on the remainder of $p$ modulo $31$: two primes with the same remainder mod $31$ always have the same sign of Frobenius.

## The corrected verdict

The experiments reported that a different $S_3$ field produces "exactly the same one-bit channel". Pulling the claim apart gives a cleaner and truer statement:

* **Universal:** the *shape* of the channel. For every $S_3$-field, the splitting type carries exactly one bit about the sign of Frobenius, never more, and a coarser statistic can carry less. This holds because of the group structure alone, and it generalises to every finite group with a $\pm1$ character.
* **Not universal:** the *conductor*, meaning the modulus at which that bit can be read off from $p$ itself. It is set by the discriminant: $3$ for $x^3-2$ (discriminant $-3\cdot 6^2$), $31$ for $x^3+x+1$ (discriminant $-31$).

Put crudely, every $S_3$ cubic whispers the same one-bit secret, but each whispers it in the accent of its own discriminant. The claim "the sign character sits at conductor $3$" is true for $x^3 - 2$ and false for $x^3 + x + 1$, and the primes $5$ and $11$ are enough to show it.

## Why it matters

This is a tidy illustration of a principle that runs through modern number theory: **the group decides the statistics, the arithmetic decides the address.** Chebotarev's theorem says that Frobenius elements are distributed like random group elements, so anything expressible purely in terms of the group — entropies, mutual informations, the proportions $1/6 : 1/2 : 1/3$ — is the same for every field with the same Galois group. But the *abelian* part of the story, here the sign character, is also a Dirichlet character, and a Dirichlet character has an address: a conductor, a modulus at which it becomes visible. Class field theory is, in large part, the theory of those addresses.

The information-theoretic lens makes the dichotomy vivid. Viewed as a communication channel from "type" to "sign", every $S_3$ field has exactly the same capacity: one bit. Viewed as a channel from "residue of $p$ modulo $m$" to "sign", the capacity is one bit when $m$ is a multiple of the right conductor and essentially zero when $m$ is unrelated. Among the primes up to $3000$, the residue mod $3$ carries $0.999$ bits about the sign for $x^3-2$ but $0.000$ bits for $x^3+x+1$, while the residue mod $31$ carries $0.9995$ bits for the trinomial and only about $0.01$ bits for the pure cubic (a finite-sample leftover, not a signal).

## What comes next

The corrected picture points to several natural next steps. First, for any irreducible integer cubic with group $S_3$, the sign bit should depend on $p$ exactly modulo $|D_0|$, where $D_0$ is the fundamental discriminant of the quadratic field $\mathbb{Q}(\sqrt{\Delta})$, and on no smaller modulus. The sign law plus quadratic reciprocity supply the core, and what remains is reducing a general cubic to depressed form and proving that the modulus is minimal. Second, the Frobenius argument above generalises to Stickelberger's full theorem: a separable polynomial of degree $n$ with $r$ irreducible factors modulo $p$ has square discriminant exactly when $n - r$ is even. Third, for any finite group, the type channel should see exactly the characters of the group's abelianization, since these are the only characters there are and each is a function of the conjugacy class.

The moral stays the same all the way up: the one-bit law belongs to the group, and the conductor where you can read it belongs to the particular field.
