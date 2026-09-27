# Six Roots, Twelve Symmetries, and the Bits That Congruences Cannot Reach

*How a hexagon decides where $x^6 - 2$ breaks apart modulo a prime, and why no clock arithmetic can fully predict it*

---

## A polynomial walks into a prime

Take the polynomial $x^6 - 2$. Over the real numbers it has two roots, $\pm 2^{1/6}$. Over the complex numbers it has six, spaced evenly around a circle of radius $2^{1/6}$ like the vertices of a regular hexagon:

$$\alpha,\ \zeta\alpha,\ \zeta^2\alpha,\ \zeta^3\alpha,\ \zeta^4\alpha,\ \zeta^5\alpha, \qquad \alpha = 2^{1/6},\ \zeta = e^{2\pi i/6}.$$

Now do something number theorists do constantly: reduce modulo a prime $p$. Work in the finite world $\mathbb{F}_p = \{0, 1, \dots, p-1\}$, where arithmetic wraps around, and ask a very concrete question:

> **How many $x$ in $\mathbb{F}_p$ satisfy $x^6 \equiv 2 \pmod p$?**

Call this number $T(p)$, the *splitting type* of $p$. A few examples:

- $p = 5, 7, 11, 13, 19$: no solutions, so $T(p) = 0$.
- $p = 23$: exactly two solutions, so $T(23) = 2$.
- $p = 31$: since $2^5 = 32 \equiv 1$, we get $2^6 \equiv 2$. So $x = 2$ is a solution, and in fact there are six of them: $T(31) = 6$. It is the smallest prime with $T = 6$.

Run through thousands of primes and a striking pattern emerges. Only three values ever appear, $0$, $2$ and $6$, never $1$, $3$, $4$ or $5$. The frequencies settle down too. Among the primes up to $200{,}000$, about $66.8\%$ have type $0$, $25.0\%$ have type $2$, and $8.3\%$ have type $6$.

The source experiment behind this story measured these frequencies, and several information-theoretic quantities built on them, with high statistical significance. This article explains where *every one* of those numbers comes from, exactly, and what they reveal about a deep boundary in arithmetic: the line between *abelian* and *non-abelian* symmetry.

---

## The hexagon behind the curtain

The key to the pattern is that the six complex roots are not an unstructured set. They form a hexagon, and the symmetries of the polynomial are symmetries of that hexagon.

The smallest field containing all six roots is $K = \mathbb{Q}(2^{1/6}, \zeta)$. Since $\zeta = \tfrac{1+\sqrt{-3}}{2}$, this is also $\mathbb{Q}(2^{1/6}, \sqrt{-3})$, a field of degree $12$ over the rationals. Its *Galois group*, the group of all ways to shuffle the roots that respect every algebraic relation among them, has exactly $12$ elements. They come in two kinds:

- **Six rotations** $r_i$ ($i = 0, \dots, 5$). They send $\alpha \mapsto \zeta^i \alpha$ and leave $\sqrt{-3}$ alone. On the roots they act as $j \mapsto j + i$: spin the hexagon by $i$ notches.
- **Six reflections** $s_i$. They also apply complex conjugation, which flips $\sqrt{-3} \mapsto -\sqrt{-3}$. On the roots they act as $j \mapsto -i - j$: flip the hexagon across an axis.

This is the **dihedral group $D_6$**, the full symmetry group of a regular hexagon. It is *non-abelian*: the order in which you rotate and reflect matters.

Here is the bridge between the hexagon and the primes. For each prime $p$ that does not divide $6$, there is a distinguished symmetry, the *Frobenius element* of $p$. It is the shadow in characteristic zero of the map $x \mapsto x^p$. A root of $x^6 - 2$ modulo $p$ corresponds exactly to a root of the hexagon that Frobenius *fixes*. So

$$T(p) = \text{number of hexagon vertices fixed by the Frobenius of } p.$$

The celebrated **Chebotarev density theorem** says that, as $p$ ranges over the primes, the Frobenius element lands on each of the $12$ symmetries equally often. This is a precise statement about natural density, and it is the one modelling hypothesis we build on. Everything after it is exact group theory.

---

## Counting fixed vertices

So which symmetries of a hexagon fix which vertices?

- The **identity** $r_0$ fixes all six.
- Any **nontrivial rotation** fixes nothing, since every vertex moves.
- A **reflection** fixes the vertices lying on its mirror axis. A hexagon has two kinds of axes. Three axes pass through a pair of opposite *vertices*, and those reflections fix $2$ vertices. The other three pass through midpoints of opposite *edges*, and those reflections fix $0$.

This works for every polygon with an even number of sides. **The fixed-point law for $D_n$ with $n$ even:** rotations fix $n$ vertices (the identity) or none, and the reflection $j \mapsto -i-j$ fixes exactly $2$ vertices if $i$ is even and none if $i$ is odd. Solving $2j \equiv -i \pmod n$ has two solutions or none, depending on the parity of $i$.

Tally the twelve symmetries of the hexagon:

| type $T$ | symmetries | count | probability |
|---|---|---|---|
| $6$ | identity | $1$ | $1/12 \approx 8.3\%$ |
| $2$ | vertex-axis reflections $s_0, s_2, s_4$ | $3$ | $1/4 = 25\%$ |
| $0$ | 5 rotations + 3 edge-axis reflections | $8$ | $2/3 \approx 66.7\%$ |

These are precisely the observed frequencies. As a check, the average number of fixed vertices is $(8\cdot 0 + 3 \cdot 2 + 1 \cdot 6)/12 = 1$. Burnside's lemma requires exactly this, because the group moves any root to any other.

---

## The same story, told by the primes themselves

Chebotarev is an asymptotic statement. It would be unsatisfying if the "only $0$, $2$, $6$" pattern were only true *on average*. It is not: it holds for every single prime, and the reason is elementary.

**The cyclic-group root law.** In a cyclic group of order $n$, the equation $x^k = a$ has either no solutions or exactly $\gcd(n, k)$ of them. The solutions, if there are any, form a coset of the kernel of $x \mapsto x^k$, and that kernel has $\gcd(n,k)$ elements.

The nonzero elements of $\mathbb{F}_p$ form a cyclic group of order $p-1$. So for every prime $p \ge 5$,

$$T(p) \in \{0,\ \gcd(p-1, 6)\}.$$

Every such prime is odd, so $\gcd(p-1,6)$ is $6$ if $p \equiv 1 \pmod 3$ and $2$ if $p \equiv 2 \pmod 3$. This gives the two halves of the picture:

- **Rotation half.** If $p \equiv 1 \pmod 3$, then $T(p) \in \{0, 6\}$. These are the primes whose Frobenius is a rotation, the ones that leave $\sqrt{-3}$ alone.
- **Reflection half.** If $p \equiv 2 \pmod 3$, cubing is a bijection on $\mathbb{F}_p$, so $2$ is a sixth power exactly when it is a square. By the classical supplementary law of quadratic reciprocity, that happens exactly when $p \equiv \pm 1 \pmod 8$. So $T(p) = 2$ if $p \equiv \pm1 \pmod 8$, and $T(p) = 0$ otherwise.

Putting the two halves together gives a complete congruence table at modulus $24$:

| $p \bmod 24$ | $5, 11, 13, 19$ | $17, 23$ | $1, 7$ |
|---|---|---|---|
| $T(p)$ | $0$ | $2$ | **either $0$ or $6$** |

The last column matters most. For primes $\equiv 1$ or $7 \pmod{24}$, **no congruence condition can decide** whether $x^6 - 2$ has zero or six roots. Deciding it means knowing whether $2$ is a sixth power modulo $p$, and that is not a congruence condition on $p$ at all. Hold on to that column. It is the non-abelian heart of the story.

---

## Measuring surprise in bits

To compare how much different pieces of information "know" about $T$, we use Shannon's language of **entropy**. For a random quantity taking values with probabilities $q_1, q_2, \dots$, the entropy

$$H = -\sum_i q_i \log_2 q_i$$

measures, in bits, how uncertain you are before you look. Picture a prime drawn at random, with its Frobenius uniform on $D_6$. The type $T$ has probabilities $\tfrac{2}{3}, \tfrac14, \tfrac1{12}$, and a short calculation gives

$$\boxed{\,H(T) = \tfrac34 \log_2 3 \approx 1.1887 \text{ bits.}\,}$$

The experiment measured $1.1835$.

Now suppose someone tells you a cheap piece of side information, a **dial**, such as $p \bmod 3$. The leftover uncertainty is the *conditional entropy* $H(T \mid \text{dial})$: the average of the entropies inside each dial setting, weighted by how often that setting occurs. The **mutual information**

$$I(\text{dial}; T) = H(T) - H(T \mid \text{dial})$$

is how many bits the dial removes.

### The conductor-3 dial

Knowing $p \bmod 3$ is the same as knowing whether Frobenius is a rotation or a reflection.

- If $p \equiv 1 \pmod 3$ (rotation), the types are $\{6 : 1,\ 0 : 5\}$ out of $6$. That leaves $1 + \log_2 3 - \tfrac56 \log_2 5 \approx 0.65$ bits.
- If $p \equiv 2 \pmod 3$ (reflection), the types are $\{2 : 3,\ 0 : 3\}$, a fair coin with exactly $1$ bit.

Averaging and subtracting from $H(T)$:

$$\boxed{\,I(p \bmod 3;\ T) = \tfrac14\log_2 3 + \tfrac{5}{12}\log_2 5 - 1 \approx 0.3637 \text{ bits.}\,}$$

The experiment measured $0.3630$, and the exact value lies strictly between $0.34$ and $0.375$. The dial "leaks": it is strictly informative but falls far short of pinning $T$ down.

### The full abelian dial

Can a cleverer congruence do better? Knowing $p \bmod 24$ reveals both $p \bmod 3$ and whether $2$ is a square. In group terms, it reveals the image of Frobenius in the **abelianisation** of $D_6$, the largest commutative "shadow" of the group. For $D_6$ this shadow is $\mathbb{Z}/2 \times \mathbb{Z}/2$, the Galois group of $\mathbb{Q}(\sqrt{-3}, \sqrt 2)$. The only ambiguity left is the one from our table: the three symmetries $\{r_0, r_2, r_4\}$ look identical to the abelianisation, and they have types $6, 0, 0$. So

$$H(T \mid p \bmod 24) = \tfrac14 \log_2 3 - \tfrac16 \approx 0.2296, \qquad I(p \bmod 24;\ T) = \tfrac12\log_2 3 + \tfrac16 \approx 0.9591 \text{ bits.}$$

---

## The abelian ceiling

Is $p \bmod 24$ just a good choice, or is it the best possible? The work behind this article proves it is the best, and the argument applies to *every* finite group.

**Refinement monotonicity.** Suppose dial $B$ refines dial $A$, meaning that whenever two points get the same $B$-reading they also get the same $A$-reading. Then $H(T \mid B) \le H(T \mid A)$, so $B$ carries at least as much information as $A$. A finer dial never hurts. The proof writes conditional entropy as an average of fibre entropies and applies Gibbs' inequality inside each coarse fibre.

**The abelian ceiling theorem.** Let $G$ be any finite group and let $\varphi: G \to A$ be any homomorphism to a commutative group. Every such $\varphi$ factors through the abelianisation $G \to G^{ab}$, so the abelianisation refines $\varphi$. Hence, for any quantity $T$ read off a uniformly random element,

$$I(\varphi;\ T) \;\le\; I(G^{ab};\ T).$$

By the Kronecker–Weber theorem, a dial of the form "$p$ modulo $m$" sees Frobenius only through an abelian quotient of the Galois group. So *no congruence condition of any modulus* can extract more than $\tfrac12\log_2 3 + \tfrac16 \approx 0.959$ bits about the type of $x^6 - 2$. Equivalently, every such dial leaves at least

$$\tfrac14\log_2 3 - \tfrac16 \approx 0.2296 \text{ bits}$$

of uncertainty. That is about $19\%$ of $H(T)$, and it is permanently out of reach of clock arithmetic. This is the **non-abelian residue**.

Where does it come from? From one identity in the hexagon group:

$$r_1\, s_0\, r_1^{-1}\, s_0^{-1} = r_2.$$

The rotation by *two* notches is a **commutator**. Every map into a commutative group sends commutators to the identity. So every abelian dial is forced to confuse the identity (six roots) with $r_2$ and $r_4$ (no roots). Non-commutativity leaves a fingerprint that no abelian measurement can wipe off.

---

## Information is not prediction

Here is a twist that surprised the analysis. Suppose you actually want to *guess* $T(p)$, and you are scored on how often you are wrong.

- **With no information**, the best guess is always "$T = 0$", which is wrong on $4$ of the $12$ classes, an error rate of $1/3$.
- **Knowing $p \bmod 3$**, the best you can do is guess $0$ on the rotation side (wrong once in six) and anything on the reflection side (wrong three times in six, since it is a fair coin). That is again **$4$ of $12$ wrong**. The dial that carries $0.36$ bits of information gives **zero** improvement in prediction.
- **Knowing $p \bmod 24$**, you can guess $2$ on the classes $17, 23$ and $0$ everywhere else. You are wrong only on the identity class, so the error is $1/12$.
- **No abelian dial can do better.** Because $r_0$ and $r_2$ always share a reading but have different types, every predictor built on an abelian dial errs on at least $1/12$ of the Frobenius classes, and $p \bmod 24$ attains this floor.

Why do information and prediction diverge? A best guess only cares about the *majority* type in each dial setting. Entropy cares about the *entire* distribution. The mod-3 dial rearranges uncertainty among the minority types, turning a spread-out three-way distribution into a skewed one on one side and a coin flip on the other. The majority answer, "$0$", stays the same everywhere, so the guesser gains nothing even though the entropy drops.

---

## Two primes at once

The experiment also looked at **semiprimes** $N = pq$ and asked how much $N \bmod 3$ reveals about the pair of types $(T(p), T(q))$. With two independent Frobenius elements, the pair has entropy $H(T_1, T_2) = \tfrac32 \log_2 3$, twice the single entropy. The dial $N \bmod 3 = (p \bmod 3)(q \bmod 3)$ only reports whether the two Frobenii are *of the same kind* (both rotations or both reflections) or *of opposite kinds*.

Working through the $144$ pairs gives an exact closed form:

$$\boxed{\,I_{\text{pair}} = \tfrac38\log_2 3 + \tfrac{35}{72}\log_2 5 + \tfrac{17}{72}\log_2 17 - \tfrac{23}{9} \approx 0.1326 \text{ bits.}\,}$$

The experiment measured $0.1321$. A new prime, $17$, appears here out of nowhere. In the "same kind" setting, the type pair $(0,0)$ occurs $34 = 25 + 9$ times: $25$ from two blank rotations and $9$ from two edge-axis reflections. The $17$ in $34 = 2 \cdot 17$ ends up in the entropy. The pair channel is real but diluted: strictly positive, and strictly smaller than the single-prime channel.

---

## Why it matters

The dihedral group $D_6$ is the first genuinely non-abelian case where this "type channel" viewpoint could have broken down. It doesn't. Every observed number turns out to be an exact, closed-form quantity attached to the hexagon's symmetry group:

- the three types and their frequencies $\tfrac23, \tfrac14, \tfrac1{12}$;
- $H(T) = \tfrac34\log_2 3$;
- $I(p \bmod 3; T) = \tfrac14\log_2 3 + \tfrac5{12}\log_2 5 - 1$;
- the pair channel with its surprising $\log_2 17$.

Beyond matching experiment, the analysis draws a sharp line. Congruences, which are abelian information, can tell you at most $\approx 0.959$ of the $\approx 1.189$ bits. The rest lives in the commutator $r_2 = [r_1, s_0]$. Telling $0$ roots apart from $6$ requires knowing whether $2$ is a sixth power modulo $p$, and no clock of any size can tell you that.

This is a small, fully computable instance of one of the central themes of modern number theory. Abelian phenomena are governed by congruences (class field theory), while non-abelian ones need something deeper, the territory of the Langlands program. Here that boundary is measured in bits, a little under a quarter of a bit per prime.
