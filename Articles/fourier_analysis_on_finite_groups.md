# The Shape of a Signal: Fourier Analysis on Finite Groups

## A tune you cannot hum quietly

Strike a piano key and hold it. The note is sharply defined in pitch — a single, clean frequency — but it is smeared out in time, lasting seconds. Now clap your hands. The clap is sharply defined in time — a single instant — but smeared out in pitch: it contains *every* frequency at once, which is why a clap can excite the strings of an entire piano.

This is not an accident of pianos. It is a law. You cannot be sharp in time and sharp in frequency at the same time. In quantum mechanics the same law is Heisenberg's uncertainty principle, with position and momentum in place of time and pitch. In engineering it is the reason a radio channel cannot be both instantaneous and narrowband.

Most statements of this law live in the continuous world of real numbers, where "sharpness" is measured by variances and integrals and the answer involves $\pi$. But there is a discrete version that is cleaner, sharper, and in some ways more surprising — and it lives on **finite groups**. Here is the punchline, and it is startlingly simple:

> Let $G$ be a finite abelian group with $|G|$ elements, and let $f$ be a nonzero complex-valued function on $G$. Let $\operatorname{supp} f$ be the set of points where $f$ is nonzero, and $\operatorname{supp}\hat f$ the set of frequencies where its Fourier transform is nonzero. Then
> $$|\operatorname{supp} f| \cdot |\operatorname{supp} \hat f| \ \ge\ |G|.$$

No constants, no $\pi$, no analysis. Just counting. If your signal lives on 100 sample points and is nonzero at only 5 of them, then its spectrum must be nonzero at at least 20 frequencies. Concentration in one world is paid for, exactly, by spread in the other. This is the **Donoho–Stark uncertainty principle**, and it is the centrepiece of the story below.

What follows is a tour of that story: what the Fourier transform *is* when the underlying space is a finite group, why the uncertainty principle is true, which functions live exactly on the boundary of the inequality, and what happens when you turn the machinery loose on a problem in additive combinatorics — where it delivers a beautiful proof, and also a small, honest disappointment.

---

## Characters: the atoms of symmetry

Start with the finite cyclic group $\mathbb{Z}/n$, the integers modulo $n$: think of $n$ equally spaced points on a circle, with addition wrapping around. A function on $\mathbb{Z}/n$ is just a list of $n$ numbers — a digitized signal, a sampled waveform, a histogram.

What should "frequency" mean here? The right answer, and the one that generalizes, is: a frequency is a **character**. A character of a finite abelian group $G$ is a function $\psi : G \to \mathbb{C}$ that turns addition into multiplication,
$$\psi(x + y) = \psi(x)\,\psi(y), \qquad \psi(0) = 1 .$$
Because $G$ is finite, every $x$ satisfies $mx = 0$ for some $m$, so $\psi(x)^m = 1$: characters automatically take values on the unit circle. They are pure oscillations, of unit amplitude, that respect the group law.

For $G = \mathbb{Z}/n$ the characters are exactly what you would hope: for each $k \in \mathbb{Z}/n$,
$$\psi_k(x) = e^{2\pi i k x / n},$$
the $n$-th roots of unity spinning at $k$ different speeds. There are exactly $n$ of them, one per residue $k$ — a fact one can prove directly, by checking that the map $k \mapsto \psi_k$ is a bijection onto the set of all characters.

The characters of $G$ form a group in their own right under pointwise multiplication, called the **dual group** $\hat G$. This dual group has the same size as $G$: $|\hat G| = |G|$. The dual is where the "frequency domain" lives.

Two orthogonality relations do all the work in this subject, and both are elementary. Summing a *fixed* group element over *all* characters:
$$\sum_{\psi \in \hat G} \psi(x)\,\overline{\psi(y)} = \begin{cases} |G| & x = y,\\ 0 & x \ne y,\end{cases}$$
and summing a *fixed* pair of characters over *all* group elements:
$$\sum_{x \in G} \psi(x)\,\overline{\chi(x)} = \begin{cases} |G| & \psi = \chi,\\ 0 & \psi \ne \chi.\end{cases}$$
Both are instances of the same one-line trick: a nontrivial character sums to zero over the whole group, because translating the sum multiplies it by a value different from $1$, which forces the sum to vanish.

## The transform, and everything it does

With characters in hand, define the **Fourier transform** of $f : G \to \mathbb{C}$ as a function on the dual group:
$$\hat f(\psi) \ =\ \sum_{x \in G} \overline{\psi(x)}\, f(x), \qquad \psi \in \hat G .$$
For $G = \mathbb{Z}/n$ this is precisely the classical DFT, $\hat f(k) = \sum_x e^{-2\pi i k x/n} f(x)$ — the transform that your phone computes billions of times a day, the FFT.

The orthogonality relations immediately give the three pillars of the theory.

**Inversion.** Nothing is lost: the function can be rebuilt from its spectrum,
$$f(x) \ =\ \frac{1}{|G|}\sum_{\psi \in \hat G} \psi(x)\,\hat f(\psi).$$
Consequently the transform is a linear *bijection* from functions on $G$ to functions on $\hat G$.

**Parseval / Plancherel.** Energy is preserved, up to the normalization factor $|G|$:
$$\sum_{\psi \in \hat G} |\hat f(\psi)|^2 \ =\ |G| \sum_{x \in G} |f(x)|^2,$$
and more generally $\sum_\psi \hat f(\psi)\overline{\hat g(\psi)} = |G|\sum_x f(x)\overline{g(x)}$. The transform is an isometry after rescaling.

**Convolution.** Define the convolution $(f * g)(x) = \sum_{y} f(y)\,g(x-y)$ — the operation that blurs one function by another, and the operation that underlies polynomial multiplication, probability of sums of independent random variables, and digital filtering. Then
$$\widehat{f * g} \ =\ \hat f \cdot \hat g .$$
Convolution, which costs $|G|^2$ operations to compute directly, becomes plain pointwise multiplication in the frequency domain. This single identity is why the fast Fourier transform revolutionized computation.

There is even a pleasing symmetry lurking here. Applying the transform *twice* — the second time on the dual group, and reading the result back on $G$ through the canonical identification of $G$ with the dual of its dual — gives
$$\hat{\hat f}(x) \ =\ |G|\, f(-x).$$
The Fourier transform, suitably normalized, is essentially a fourth root of the identity: transform four times and you are back where you started.

## The group algebra: why any of this had to be true

There is a structural reason for all of it, and it is worth pausing on, because it explains the theory rather than merely verifying it.

Take the vector space of all functions $G \to \mathbb{C}$ and equip it with convolution as multiplication. The result is an algebra, the **group algebra** $\mathbb{C}[G]$, which encodes the group's entire symmetry structure. It is a $|G|$-dimensional algebra, and multiplication in it looks complicated.

The Fourier transform says: it isn't. Evaluating an element of $\mathbb{C}[G]$ at each character gives an isomorphism of algebras
$$\mathbb{C}[G] \ \xrightarrow{\ \sim\ }\ \mathbb{C}^{\hat G} \ \cong\ \mathbb{C}^{|G|},$$
where the right-hand side has plain pointwise multiplication. This is the Wedderburn–Artin decomposition of the group algebra in the abelian case: the algebra is a product of $|G|$ copies of the simplest algebra there is. The convolution theorem is not a lucky identity — it is the statement that this map is a ring homomorphism, and inversion is the statement that it is bijective.

A cute corollary falls out for free. A product of copies of $\mathbb{C}$ has no nonzero nilpotents, and this property transfers across the isomorphism: **the complex group algebra of a finite abelian group is reduced** — no nonzero function convolved with itself enough times ever vanishes identically. Try proving that by bare hands.

## Why concentration costs you

Now the uncertainty principle. Suppose $f \ne 0$; let $S = \operatorname{supp} f$ and $\hat S = \operatorname{supp}\hat f$, and let $M = \max_x |f(x)| > 0$.

*Step one: a concentrated function has small Fourier coefficients.* Every $\hat f(\psi)$ is a sum of $|S|$ terms (the rest vanish), each of modulus at most $M$, since characters have modulus $1$. So
$$|\hat f(\psi)| \ \le\ |S| \, M \qquad \text{for every } \psi.$$

*Step two: a concentrated spectrum cannot rebuild a tall function.* Pick $m$ with $|f(m)| = M$ and apply the inversion formula, in which only the $|\hat S|$ nonvanishing coefficients contribute:
$$M = |f(m)| = \frac{1}{|G|}\Bigl|\sum_{\psi \in \hat S} \psi(m)\hat f(\psi)\Bigr| \ \le\ \frac{1}{|G|}\,|\hat S| \cdot |S| M .$$

*Step three: cancel $M > 0$.* Out drops
$$|S|\cdot|\hat S| \ \ge\ |G| .$$

Three lines, two triangle inequalities, no cleverness. And yet the statement is genuinely restrictive, and it is *sharp*.

## Living on the boundary

Which functions achieve equality? The first example is the sharpest possible spike, the Dirac delta $\delta_a$, which equals $1$ at $a$ and $0$ elsewhere. Its transform is $\hat{\delta_a}(\psi) = \overline{\psi(a)}$, which has modulus $1$ — never zero. So $|{\operatorname{supp}\delta_a}| \cdot |\operatorname{supp}\hat{\delta_a}| = 1 \cdot |G| = |G|$: a perfect spike costs a perfectly flat spectrum. Equality.

The rich examples are subgroups. Let $H \le G$ be a subgroup and let $1_H$ be its indicator. Its **annihilator**
$$H^{\perp} = \{\psi \in \hat G : \psi(x) = 1 \text{ for all } x \in H\}$$
consists of the frequencies that cannot see $H$ at all. A short orthogonality argument shows
$$\widehat{1_H} \ =\ |H| \cdot 1_{H^\perp},$$
which is remarkable in itself: *the transform of a subgroup indicator is a rescaled indicator of a subgroup of the dual.* Subgroups are the eigen-objects of the Fourier transform.

Feeding this into Parseval yields, with no group theory at all,
$$|H| \cdot |H^{\perp}| \ =\ |G|,$$
a duality theorem obtained purely from Plancherel's identity. And it says precisely that $1_H$ achieves equality in the uncertainty principle. The trade-off is visible: a big subgroup has a small annihilator, and vice versa. In $\mathbb{Z}/12$, the subgroup $\{0,3,6,9\}$ of size $4$ has an annihilator of size $3$; the subgroup $\{0,6\}$ of size $2$ has an annihilator of size $6$. In each case the product is $12$.

The same circle of ideas gives **Poisson summation**: for any $f$,
$$|G| \sum_{x \in H} f(x) \ =\ |H| \sum_{\psi \in H^{\perp}} \hat f(\psi),$$
the finite-group avatar of the classical formula relating a sum over a lattice to a sum over its dual lattice.

Finally, equality is preserved by the three symmetries of the theory. Scaling $f$ by a nonzero constant changes nothing. Translating $f$ by $a$ multiplies $\hat f$ by a unimodular factor, so supports are merely shifted. Modulating $f$ — multiplying it by a character $\chi$ — translates $\hat f$ in the dual group. Each of these preserves both support sizes. Combining, we get a whole family of extremals: for any subgroup $H$, any $a \in G$, any character $\chi$, and any $c \ne 0$,
$$f(x) = c\,\chi(x)\,1_H(x - a)$$
satisfies $|\operatorname{supp} f|\cdot|\operatorname{supp}\hat f| = |G|$ exactly. These are *modulated cosets*: a constant-modulus function riding a pure oscillation, supported on a coset of a subgroup. It is conjectured — and widely believed — that these are the *only* extremals.

## Turning the crank: sums of sets

Uncertainty is one face of the theory. Here is another, from additive combinatorics: given two subsets $A, B$ of a finite abelian group, when is every element of $G$ expressible as $a + b$ with $a \in A$, $b \in B$?

Let
$$r_{A,B}(c) = \#\{(a,b) \in A \times B : a + b = c\}$$
count the representations. The first observation is that $r_{A,B}$ *is* a convolution: $r_{A,B} = 1_A * 1_B$. So by the convolution theorem and inversion,
$$|G| \cdot r_{A,B}(c) \ =\ \sum_{\psi \in \hat G} \psi(c)\,\widehat{1_A}(\psi)\,\widehat{1_B}(\psi).$$

Now split off the trivial character $\psi = 0$, for which $\widehat{1_A}(0) = |A|$ and $\widehat{1_B}(0) = |B|$. The result is a *main term plus error*:
$$|G|\, r_{A,B}(c) \ =\ |A||B| \ +\ \underbrace{\sum_{\psi \ne 0} \psi(c)\widehat{1_A}(\psi)\widehat{1_B}(\psi)}_{\text{error}} .$$
If the error is strictly smaller than $|A||B|$ in modulus, then $r_{A,B}(c) > 0$: the element $c$ *is* representable. And that is true for every $c$ simultaneously, so $A + B = G$.

How big is the error? Parseval, applied to an indicator, gives $\sum_\psi |\widehat{1_A}(\psi)|^2 = |G|\,|A|$; subtracting the trivial character's contribution $|A|^2$ leaves
$$\sum_{\psi \ne 0} |\widehat{1_A}(\psi)|^2 \ =\ |A|\,(|G| - |A|).$$
Then Cauchy–Schwarz bounds the error by $\sqrt{|A|(|G|-|A|)}\cdot\sqrt{|B|(|G|-|B|)}$, and the error is beaten by the main term as soon as
$$(|G| - |A|)(|G| - |B|) \ <\ |A|\,|B| .$$
**Conclusion:** under this condition, every element of $G$ is a sum $a+b$ with $a \in A$, $b \in B$.

It is a genuinely lovely argument — analysis proving a combinatorial statement. And now the honest twist. Expand the condition: $|G|^2 - |G|(|A|+|B|) + |A||B| < |A||B|$, i.e. $|G|^2 < |G|(|A|+|B|)$, i.e.
$$|A| + |B| \ >\ |G| .$$
The Fourier condition is *exactly equivalent* to the pigeonhole condition. And the pigeonhole proof is one line: if $|A| + |B| > |G|$ then the sets $A$ and $c - B$ must intersect, since their sizes add up to more than $|G|$; any point of the intersection gives a representation of $c$.

So the whole apparatus — characters, Parseval, Cauchy–Schwarz — reproduces the schoolchild's argument and not a step further. This is not a failure of the method; it is a precise measurement of it. Cauchy–Schwarz, applied bluntly to the full nonprincipal spectrum, is *exactly tight* at the pigeonhole threshold. If you want to do better, you must know something more about $A$ and $B$ than their sizes — you must control their largest Fourier coefficient. That is precisely the insight behind pseudorandomness in additive combinatorics: sets whose nontrivial Fourier coefficients are all small behave like random sets, and for them the error term collapses far below the crude Cauchy–Schwarz bound.

## Beyond the threshold: counting, exactly

Fourier analysis has more to say below the threshold, where $A + B$ may not be all of $G$. Applying Plancherel to the convolution $1_A * 1_B$ itself gives an exact identity for the **additive energy**:
$$|G| \sum_{c \in G} r_{A,B}(c)^2 \ =\ (|A||B|)^2 \ +\ E, \qquad E = \sum_{\psi \ne 0} |\widehat{1_A}(\psi)|^2\,|\widehat{1_B}(\psi)|^2 .$$
Not an inequality — an identity. The left side counts additive quadruples $a + b = a' + b'$; the right side reads that count off from the spectrum.

Since the representation function has total mass $\sum_c r_{A,B}(c) = |A||B|$ and is supported on the sumset $A+B$, Cauchy–Schwarz in the other direction yields a quantitative covering bound:
$$|A + B| \ \ge\ \frac{|G|\,(|A||B|)^2}{(|A||B|)^2 + E}.$$
A set pair with small nontrivial Fourier energy $E$ has a sumset covering nearly all of $G$ — a smooth, quantitative statement that degrades gracefully, rather than switching off abruptly at a threshold. In $\mathbb{Z}/12$ with $A = \{0,1,2\}$ and $B = \{0,4,8\}$ (both far below the pigeonhole threshold) the bound gives $|A+B| \ge 9$, and indeed $A + B$ has exactly $9$ elements: the estimate is attained.

## What is still open

The theory above is complete and airtight, but it leaves sharp, concrete questions.

The first is the **classification of extremals**. Modulated cosets attain equality in the uncertainty principle; are they the only functions that do? The proof suggests why they should be: equality in the two triangle inequalities forces $|f|$ to be constant on its support *and* forces all the phases $\overline{\psi(x)}f(x)$ to align across a full character sum — and phase alignment across a full character sum is exactly the statement that the support is a coset. Turning that suggestion into a proof is a self-contained finite combinatorial problem.

The second is **Tao's uncertainty principle**. When $|G| = p$ is prime, the multiplicative bound $|\operatorname{supp} f| \cdot |\operatorname{supp}\hat f| \ge p$ can be upgraded to the additive bound
$$|\operatorname{supp} f| + |\operatorname{supp}\hat f| \ \ge\ p + 1,$$
which is strictly stronger (a function with both supports of size $\sqrt p$ would satisfy the first and violate the second). The reason is a beautiful piece of algebra: when $p$ is prime, *every* square submatrix of the $p \times p$ DFT matrix is nonsingular — a theorem of Chebotarev that follows from the irreducibility of the cyclotomic polynomial. Prime moduli admit no accidental cancellations, so no function can hide in a small window of both worlds. And this is why prime lengths are the natural setting for compressed sensing: a sparse signal of $p$ samples is uniquely determined by any $2s$ of its Fourier coefficients if it has at most $s$ nonzeros.

The third is **stability**: extremals are rigid, but how rigid? One expects a quantitative improvement of the form
$$|\operatorname{supp} f| \cdot |\operatorname{supp}\hat f| \ \ge\ |G|\,(1 + \kappa\,\delta(f)),$$
where $\delta(f)$ measures how far $|f|$ is from being constant on its support and $\kappa > 0$ is absolute. The only lossy step of the three-line proof is the bound $|f(x)| \le M$; a function far from constant on its support wastes that step by a definite amount, and one should be able to recover it.

## Why it matters

Everything above is finite, discrete, and exactly stated — no error terms, no asymptotics, no limits. And yet it is the working core of an astonishing amount of applied mathematics.

The convolution theorem is the fast Fourier transform, and the fast Fourier transform is how signals are filtered, how large integers and polynomials are multiplied, and how images are compressed. The uncertainty principle, in exactly the discrete form proved above, is the theoretical basis of compressed sensing: a signal that is sparse in one domain must be spread out in the other, so a handful of measurements in the spread domain suffices to pin it down. The counting formula and the additive energy identity open every treatment of additive combinatorics.

And underneath all of it is one idea, of the kind that mathematics keeps rediscovering: a commutative symmetry group can be *diagonalized*. Choose the right coordinates — the characters — and translation-invariant operations, which look tangled in the original coordinates, become multiplication by numbers. Everything else, including the impossibility of being sharp in both pictures at once, is a consequence of that single change of basis.
