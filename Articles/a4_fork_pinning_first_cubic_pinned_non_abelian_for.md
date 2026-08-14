# The Prime That Whispers Its Symmetry

## How a quartic equation with no symmetry to spare still tells you, from its last two digits in base nine, exactly what shape it will take

### A question you can ask a prime

Take the polynomial
$$x^4 + 8x + 12.$$

It has no rational roots, no obvious structure, nothing pretty about it. Now pick a prime $p$ and ask a very concrete question: *how does this polynomial factor when its coefficients are read modulo $p$?* It might split into four linear factors, or into two quadratics, or break as a linear times a cubic. The list of answers, as $p$ runs over all primes, is an infinite fingerprint of the polynomial. Reading that fingerprint is one of the oldest games in number theory: it is what Gauss was doing when he proved quadratic reciprocity, and what the twentieth-century edifice of class field theory was built to systematize.

The classical miracle is that for *some* polynomials the fingerprint is periodic. The polynomial $x^2+1$ factors modulo $p$ exactly when $p \equiv 1 \pmod 4$: the behaviour of a prime in an algebraic world determined by nothing more than its remainder after division by $4$. Knowing $p$ mod $4$ is like turning a dial with two settings, each of which fixes the answer.

But most polynomials are *not* periodic in this way. Their fingerprints are, from the point of view of any dial built out of remainders, pure noise. The question we want to answer precisely is: **which questions about a prime can a dial answer, which ones can it answer only partially, and which ones is it completely blind to?** The answer turns out to be beautifully sharp — and information-theoretic in shape.

---

### Three regimes: pinned, flat, and leaking

Fix a modulus $m$ and call the residue class $p \bmod m$ the **dial**; fix a yes/no question $F$ about how the polynomial factors mod $p$ and call it a **fork**. Both are random variables once $p$ ranges over primes with their natural density. The right measure of "how much does the dial tell you" is Shannon's **mutual information**
$$I(\text{dial};F) \;=\; H(F) - H(F \mid \text{dial}),$$
in bits. It is zero when the two are independent, and equals $H(F)$ — its largest possible value — when the dial determines the fork completely.

Here is the first structural result: purely a theorem about entropy, but it organizes everything else.

> **Fork Trichotomy Theorem.** Let the dial take finitely many values $y$ with strictly positive probabilities $w(y)$ summing to $1$, and suppose the fork has conditional rate $f(y) = P(F = 1 \mid \text{dial} = y) \in [0,1]$. Write $\bar f = \sum_y w(y) f(y)$ for the overall rate. Then
> $$0 \;\le\; I(\text{dial};F) \;\le\; H(\bar f),$$
> and moreover:
> - $I = 0$ **if and only if** $f$ is constant — the fork is **flat**, the dial is blind;
> - $I = H(\bar f)$ **if and only if** every $f(y)$ is $0$ or $1$ — the fork is **pinned**, the dial is an oracle;
> - otherwise $0 < I < H(\bar f)$ — the fork **leaks**.

The proof is a sharpened Jensen's inequality. The binary entropy $H(t) = -t\log_2 t - (1-t)\log_2(1-t)$ is *strictly* concave on $[0,1]$, so $\sum_y w(y) H(f(y)) \le H\!\left(\sum_y w(y) f(y)\right)$, with equality precisely when all the $f(y)$ agree — the flat case and the lower bound. For the upper bound, $I = H(\bar f) - \sum_y w(y)H(f(y))$, and the subtracted term is a sum of non-negative pieces which vanishes exactly when each $H(f(y)) = 0$, i.e. each $f(y) \in \{0,1\}$ — the pinned case.

So there are exactly three regimes. The mathematics is in deciding, for a given polynomial and question, which one you are in — and, when it leaks, computing the exact number of bits.

---

### The symmetry group decides

The bridge from polynomials to this trichotomy is Galois theory. Attached to our quartic is its **Galois group** $G$: the symmetries of the four roots respecting all polynomial relations among them. For each unramified prime $p$ there is a conjugacy class in $G$, the **Frobenius class** of $p$, whose cycle type *is* the factorization pattern of the polynomial mod $p$. Chebotarev's density theorem (1922) says these classes are equidistributed: each element of $G$ occurs with density $1/|G|$.

Now the crucial constraint, entirely group-theoretic. A congruence "$p \equiv a \pmod m$" is *abelian* data: the residue classes $(\mathbb{Z}/m)^\times$ form a commutative group. Class field theory (Takagi, 1920) tells us congruences can see the Frobenius only through *abelian quotients* of $G$ — that is, only through the **abelianization**
$$G^{\mathrm{ab}} = G/[G,G],$$
the largest commutative image of $G$, obtained by killing all commutators $[a,b] = a^{-1}b^{-1}ab$.

This gives an exact criterion, which we can state and prove with no arithmetic at all:

> **Pinning-Content Criterion.** A fork — that is, a predicate $F$ on the group $G$ — is the pullback of a predicate on $G^{\mathrm{ab}}$ if and only if it is invariant under multiplication by commutators: $F(gc) \Leftrightarrow F(g)$ for all $g \in G$ and all $c \in [G,G]$.

One direction is immediate: commutators die in $G^{\mathrm{ab}}$. In the other, define the predicate on $G^{\mathrm{ab}}$ by "some preimage satisfies $F$"; commutator-invariance is exactly what makes that well defined, since two elements have the same image precisely when they differ by a commutator.

The slogan: **a fork can be pinned by a congruence if and only if it factors through the abelianization.** Everything else is a consequence.

---

### Why $A_4$ is the interesting case

Until now, every polynomial known to exhibit congruence pinning did so through one of two mechanisms. Either the group was **non-abelian** but the abelianization was the tiny group $C_2$ — the case of the symmetric groups $S_3$ and $S_4$, whose only character is the *sign*, so the pinned fork is "is the discriminant a square mod $p$", pure quadratic reciprocity, worth one bit. Or the group was **abelian** to begin with — a cyclic cubic field $G = C_3$, its own abelianization, pinned by a cubic residue symbol.

Nobody had a witness for the structurally new possibility: a **non-abelian** group whose abelianization is nevertheless of order three, so that the pinning must be by a genuinely *cubic* character. The smallest such group is the alternating group $A_4$ — the twelve rotations of a regular tetrahedron.

Inside $A_4$ sits the **Klein four-group** $V_4$, consisting of the identity together with the three double transpositions $(01)(23)$, $(02)(13)$, $(03)(12)$. Two facts about it are the whole story:

> **Theorem.** $[A_4,A_4] = V_4$, and consequently $|A_4^{\mathrm{ab}}| = 3$.

$V_4$ has a beautifully intrinsic description: it is exactly the set of *even involutions*, the elements $\sigma$ with $\sigma^2 = 1$ and even sign. One checks that every commutator of two even permutations of four letters is an even involution, and conversely that every even involution is realized as such a commutator; since $|A_4| = 12$ and $|V_4| = 4$, the quotient has order $3$.

So $A_4$ is non-abelian, has a nontrivial commutator subgroup, and yet its abelian shadow is a cyclic group of order three. If class field theory is right, a fork of an $A_4$-field should be pinnable exactly when it is a union of $V_4$-cosets — and the pinning must be cubic.

---

### The field, and its hidden cyclotomic core

Return to $x^4+8x+12$. Its discriminant is
$$\mathrm{disc} = 576^2 = 2^{12}\cdot 3^4,$$
a perfect square. A square discriminant means no odd permutation can occur as a Frobenius, so the Galois group sits inside $A_4$; together with irreducibility (transitivity) and the presence of an order-three element, this pins the group to $A_4$ exactly.

There is a striking arithmetic signature here. One might guess that a double transposition, which fixes no letter, is "somehow like" a pair of transpositions. It is not. Counting fixed roots of each element of $A_4$:

> **The $[4,1,0]$ signature.** Every element of $A_4$ fixes $4$, $1$, or $0$ of the four letters — never exactly $2$. Explicitly: the identity fixes all $4$ (density $1/12$); the eight $3$-cycles fix exactly $1$ (density $2/3$); the three double transpositions fix none (density $1/4$).

Since the number of fixed letters equals the number of linear factors mod $p$, the prediction is: **no prime ever gives exactly two roots**. A sweep over roughly $23{,}000$ unramified primes measures densities $0.0826$, $0.6661$, $0.2513$ and $0.0000$, against the theoretical $1/12$, $2/3$, $1/4$ and $0$. The two-root count is empty, on the nose.

Now for the hidden core. The **Klein resolvent** of a quartic with roots $r_1,r_2,r_3,r_4$ is the cubic whose roots are the three pairings
$$r_1r_2+r_3r_4,\qquad r_1r_3+r_2r_4,\qquad r_1r_4+r_2r_3,$$
each fixed exactly by $V_4$. A Vieta computation gives, for our quartic,
$$y^3 - 48y - 64 = 0,$$
with discriminant $576^2$, the same as the quartic's, as it must be. So the fixed field $K$ of the Klein group inside the splitting field is generated by a root of $y^3-48y-64$; it has no rational root — a short descent on numerator and denominator kills every candidate — so it really is a cubic field.

And here is the pretty part. Substituting $y = 4z$:
$$y^3-48y-64 \;=\; 64\left(z^3 - 3z - 1\right).$$

The cubic $z^3-3z-1$ (equivalently $z^3-3z+1$, after $z \mapsto -z$) is the most classical cyclic cubic in existence: its roots are $-(\zeta_9+\zeta_9^{-1})$ and its conjugates, where $\zeta_9$ is a primitive ninth root of unity. Indeed if $\zeta^9=1$ and $\zeta^3\neq1$ then $\zeta^6+\zeta^3+1=0$, and expanding $(\zeta+\zeta^{-1})^3$ gives exactly $3(\zeta+\zeta^{-1}) - 1$.

So the cubic core hidden inside the non-abelian $A_4$-field is $K = \mathbb{Q}(\zeta_9)^+$, the real subfield of the ninth cyclotomic field — **conductor $9$**.

(One might have guessed conductor $3$, since $3$ is the only ramified prime in the cubic. The generator $r_1r_2+r_3r_4$ is not an algebraic integer generator — it has index $64$ — and the true field discriminant is $81 = 9^2$, giving conductor $9$. We will see below that this is not a technicality: the modulus $3$ genuinely carries zero information.)

---

### The pinning, exactly

Class field theory for $\mathbb{Q}(\zeta_9)^+$ now converts a group-theoretic statement into an arithmetic one. Since $(\mathbb{Z}/9)^\times$ is cyclic of order $6$, its subgroup of cubes has index $3$, and one computes it directly: the cubes mod $9$ are exactly $\{1,8\}$. The cubic residue symbol mod $9$ is the homomorphism $\chi_9 : (\mathbb{Z}/9)^\times \to \mathbb{Z}/3$ sending $\{1,8\}\mapsto 0$, $\{2,7\}\mapsto1$, $\{4,5\}\mapsto2$; it is multiplicative and its kernel is the cubes.

And on the Galois side, the character $\chi: A_4 \to \mathbb{Z}/3$ reading off the $V_4$-coset of a permutation is a homomorphism whose kernel is exactly $V_4$. Both sides are the *same* cyclic group of order three:
$$A_4^{\mathrm{ab}} \;\cong\; (\mathbb{Z}/9)^\times/\text{cubes} \;\cong\; C_3 .$$

The consequence is the central result:

> **Cubic Pinning Theorem.** For the $A_4$-field of $x^4+8x+12$, the fork
> $$F_0(p) \;=\; [\,\mathrm{Frob}\,p \in V_4\,] \;=\; [\,\text{the quartic has } 4 \text{ or } 0 \text{ roots mod } p\,]$$
> satisfies
> $$F_0(p) = 1 \iff p \text{ is a cube mod } 9 \iff p \equiv 1 \text{ or } 8 \pmod 9,$$
> and therefore, with the dial $p \bmod 9$ (six equidistributed classes),
> $$I(p \bmod 9;\;F_0) \;=\; H(1/3) \;=\; \log_2 3 - \tfrac23 \;=\; 0.9183\ldots \text{ bits},$$
> the maximum possible for a fork of rate $1/3$.

This is the first *cubic* pinning of a *non-abelian* field. Empirically it is exact: over the same $23{,}000$ primes, the conditional probability of $F_0$ given $p\equiv\pm1 \bmod 9$ is $1.0000$, given the other four classes it is $0.0000$, and the measured mutual information is $0.9188$ bits against the theoretical $0.9183$.

Two sanity checks confirm that $9$ is minimal. Reading the same fork through $p \bmod 3$ gives conditional rate exactly $1/3$ in both classes — each class mod $3$ contains exactly one cube among its three units mod $9$ — so $I(p \bmod 3; F_0) = 0$. And the dial $p \bmod 5$, coprime to the conductor, is likewise flat.

**The punchline is that the value $H(1/3)$ is the same one an abelian cyclic cubic field produces.** Non-abelianness cost nothing. What matters is not whether the Galois group is commutative; it is only the *character of its abelianization*.

---

### The wall inside the coset

Having found a fork the dial answers perfectly, ask a harder question. Instead of "is the Frobenius in $V_4$", ask "is it *the identity*" — does the quartic split completely mod $p$? That is a rate-$1/12$ event, strictly finer, sitting inside the pinned one.

Here the non-abelian structure bites, in a way genuinely new relative to all the abelian examples:

> **Within-$V_4$ Flatness.** Every homomorphism from $A_4$ to an abelian group is trivial on $V_4$. Hence no congruence condition of any modulus whatsoever can distinguish the identity Frobenius from a double transposition.

The proof is one line — $V_4$ is the commutator subgroup, and commutators die in any abelian image — but the consequence is a hard information wall. Empirically $P(\mathrm{Frob}=e \mid p \equiv 1) = 0.2426$ and $P(\mathrm{Frob}=e \mid p\equiv 8) = 0.2523$, both $1/4$; and the conditional information between the dial and "identity versus double transposition", given the $V_4$ fibre, measures $0.0001$ bits.

So the identity fork is not pinned. Nor is it flat: it is *contained* in a pinned event and inherits some predictability. It is in the third regime, and the leak has an exact closed form.

> **Exact Leakage Law.** Let $g$ be a pinned fork of rate $p$, and let $F$ be the $q$-thinning of $g$: $P(F=1\mid \text{dial}=y) = q\cdot g(y)$, where the thinning is independent of the dial. Then
> $$I(\text{dial};F) \;=\; H(pq) \;-\; p\cdot H(q).$$
> If moreover $0<p<1$ and $0<q<1$, then $0 < I < H(pq)$: the fork strictly leaks.

The computation is direct: the overall rate is $pq$, and the conditional entropy $\sum_y w(y)H(q\, g(y))$ equals $p\, H(q)$, because $H(0)=0$ and $g$ takes only the values $0$ and $1$. Strictness comes from the pleasing inequality $p\,H(q) < H(pq)$, which is strict concavity of $H$ applied to the interpolation between $0$ and $q$.

Applying this with $p = 1/3$ (the $V_4$ fibre) and $q = 1/4$ (the identity's share inside $V_4$, by Chebotarev) gives:

> **Leakage of the identity fork.**
> $$I(p \bmod 9;\; [\mathrm{Frob}\,p = e]) \;=\; H(1/12) - \tfrac13 H(1/4) \;=\; 0.4138 - \tfrac13(0.8113) \;=\; 0.1434 \text{ bits},$$
> strictly between $0$ and $H(1/12)=0.4138$.

The measured value is $0.1419$. Knowing $p \bmod 9$ raises your odds that the quartic splits completely — from $1/12$ to $1/4$ when the dial reads $\pm1$, and to $0$ otherwise — but it never *tells* you. That extra $0.27$ bits is sealed behind the commutator subgroup, permanently.

Three regimes; three witnesses in a single field. That is the conceptual payload.

---

### Composite numbers, and the death of the channel

The same machinery says something about numbers that are not prime. Let $N = pq$ be a product of two unramified primes. Because the cubic character is multiplicative, the dial reading of $N$ is the *sum* of the readings of its factors in $\mathbb{Z}/3$. The two summands are independent and uniform. This turns the whole analysis into finite combinatorics on $\mathbb{Z}/3 \times \mathbb{Z}/3$, and everything can be computed exactly:

- **Both factors split:** $I = H(1/9) - \tfrac13 H(1/3) = 0.1972$ bits (measured $0.1997$).
- **At least one splits:** $I = H(5/9) - H(1/3) = 0.0728$ bits (measured $0.0688$).
- **Exactly one splits:** $I = H(4/9) - \tfrac23 H(1/3) = 0.3789$ bits (measured $0.3736$).
- **The number of split factors:** distributed as $\mathrm{Bin}(2,1/3) = (4/9,4/9,1/9)$, with $I = H(4/9,4/9,1/9) - H(1/3) = 0.4739$ bits (measured $0.4710$).
- **Which factor is the split one:** $I = 0$ **exactly**. For every class of $N$, exactly one of the three admissible pairs has its first factor split, so the conditional rate is $1/3$ regardless. The dial is perfectly blind.

That last item is the **which-factor wall**, and it is the reason none of this is a factoring algorithm. The residue of a composite tells you a statistical fact about the multiset of its factors and *nothing whatsoever* about how that multiset is split up. It is a theorem, not a limitation of technique: a product is symmetric in its factors, while a dial can only read the product.

Push further, to $N = p_1\cdots p_{k+1}$, and the general law is

> **The $k$-factor AND law.** $I\big(N \bmod 9;\ \text{all factors split}\big) = H\!\left(3^{-(k+1)}\right) - \tfrac13 H\!\left(3^{-k}\right)$,
> which is strictly positive for every $k$, but **tends to $0$ as $k \to \infty$**.

The channel dies: a number with many prime factors has, as far as its residue mod $9$ can tell, essentially random splitting behaviour.

---

### The last line of the table

We can now close the classification of which Galois groups admit congruence pinning, using the criterion above:

| Galois group | Abelianization | Pinnable forks | Best information |
|---|---|---|---|
| $C_2$ | $C_2$ | split vs. inert | $H(1/2) = 1$ bit |
| $C_3$ (cyclic cubic) | $C_3$ | split vs. inert | $H(1/3) = 0.918$ bits |
| $S_3$, $S_4$ | $C_2$ | sign of Frobenius | $H(1/2) = 1$ bit |
| $A_4$ | $C_3$ | $V_4$-membership | $H(1/3) = 0.918$ bits |
| $A_5$ | trivial | **none** | $0$ |

The last line is the sharpest, and it is a theorem, not a guess:

> **Absolute unpinnability of $A_5$.** The alternating group on five letters is perfect: $[A_5,A_5]=A_5$. Hence every homomorphism from $A_5$ to an abelian group is trivial, and the only forks of an $A_5$-field that factor through the abelianization are the two constant ones. No congruence condition of any modulus can carry a single bit about the factorization of a generic quintic.

The proof is short given simplicity of $A_5$: the commutator subgroup is normal, so it is trivial or everything; if trivial, the group would be abelian, which two non-commuting $3$-cycles refute.

This is why quintics resist. The Galois group has no abelian shadow at all — no character sees anything — so the whole apparatus of residues and reciprocity laws is exactly as informative as a coin flip. It is the unsolvability of the quintic, translated into bits.

---

### What the $A_4$ case actually teaches

It is tempting to think that "abelian" is the property that makes arithmetic tractable — that cyclotomic fields, quadratic fields and cyclic cubics are understood because their symmetry groups commute. The $A_4$ story shows that this is the wrong invariant.

$A_4$ does not commute. It has a genuine non-abelian core, a normal subgroup $V_4$ that abelian data can never penetrate. And yet its $V_4$-fork behaves *identically* to the fork of an honest abelian cyclic cubic: same conductor, same cubic character, same $H(1/3) = \log_2 3 - 2/3$ bits, to four decimals over tens of thousands of primes. Pinning is not about abelianness; it is about the character of the abelianization — a strictly coarser thing.

Once you accept that, the trichotomy is a complete map of the terrain. A question is answerable by residues if and only if it can be read off the abelianization. If it can, you get all of its entropy. If it is orthogonal to the abelianization, you get nothing. And if it is a refinement of an answerable question — visible in part, blocked in part by the commutator subgroup — you get exactly $H(pq) - p H(q)$ bits, no more and no less.

Three regimes, one criterion, and a tetrahedron's worth of rotations to show that all three can live inside a single equation. Not bad for
$$x^4 + 8x + 12.$$
