# The Shape of Certainty: Which Signals Beat the Uncertainty Principle?

## A budget you cannot cheat

Every engineer who has ever built a radar, a compression codec, or a medical scanner has bumped into the same wall: **you cannot be sharply localized in time and sharply localized in frequency at once**. A click that lasts a microsecond splashes across the whole spectrum. A pure tone, perfectly concentrated at one frequency, must ring on forever. Squeeze one side and the other bulges.

Physicists call this Heisenberg's uncertainty principle. Signal processors call it the time–frequency trade-off. In the world of *finite* signals — the world of your laptop, where a signal is just a finite list of numbers — it has a startlingly clean form, discovered by David Donoho and Philip Stark:

> **The Uncertainty Principle (finite form).** Let $G$ be a finite abelian group with $N = |G|$ elements, and let $f : G \to \mathbb{C}$ be a nonzero function on it. Write $\widehat{f}$ for its Fourier transform. Then
> $$|\operatorname{supp} f| \cdot |\operatorname{supp} \widehat{f}| \;\ge\; N.$$

Here $\operatorname{supp} f$ is the set of points where $f$ is nonzero — the "footprint" of the signal — and $\operatorname{supp}\widehat{f}$ is the set of frequencies it actually uses. The inequality says the two footprints have a **conserved budget**: their product can never dip below the size of the whole space. A signal living on $10$ of $1000$ possible time-slots must occupy at least $100$ of the $1000$ frequencies. There is no way around it.

This article is about the *other* side of that inequality. Not "how small can the product be?" — we know: $N$. But rather:

> **Which signals actually spend exactly their budget, and not a penny more?**

The answer turns out to be a complete and rather beautiful classification, together with a sharp warning about a tempting shortcut that does *not* work.

## The cast of characters

Let me set the stage precisely, because everything that follows depends on getting the definitions right.

A **finite abelian group** $G$ is a finite set with an addition that is commutative and invertible: the integers mod $N$, written $\mathbb{Z}/N$, is the standard example, and by the structure theorem every finite abelian group is a product of such cyclic pieces. Think of $\mathbb{Z}/N$ as the set of time-slots of a signal of length $N$, wrapping around at the end.

A **character** of $G$ is a function $\psi : G \to \mathbb{C}$ that turns addition into multiplication, $\psi(x+y) = \psi(x)\psi(y)$, and takes values on the unit circle. On $\mathbb{Z}/N$ the characters are exactly the $N$ pure waves $x \mapsto e^{2\pi i k x/N}$, one for each frequency $k$. The characters themselves form a group under pointwise multiplication, the **dual group** $\widehat{G}$, and a fundamental fact of the subject — Pontryagin duality — says $|\widehat{G}| = |G|$ and that $G$ is canonically the dual of its own dual. Every group is the space of frequencies of some other group, and it is the space of frequencies of itself.

The **Fourier transform** of $f : G \to \mathbb{C}$ is the function on the dual group
$$\widehat{f}(\psi) \;=\; \sum_{x \in G} \overline{\psi(x)}\, f(x),$$
the usual correlation of $f$ against each pure wave. Two facts about it drive everything below. **Plancherel's identity** says energy is conserved up to the normalization $N$:
$$\sum_{\psi \in \widehat{G}} |\widehat{f}(\psi)|^2 \;=\; N \sum_{x \in G} |f(x)|^2 .$$
And **Fourier inversion** says the transform can be undone: applying it twice returns $N$ times the reflected original.

Finally, call $f$ **extremal** if it hits the uncertainty bound exactly:
$$|\operatorname{supp} f| \cdot |\operatorname{supp}\widehat{f}| \;=\; N.$$

## Two easy extremals, and a guess

Two families of extremal signals are visible with the naked eye.

The **spike**: let $f$ be nonzero at a single point $a$ and zero elsewhere. Its footprint has size $1$. Its transform is $\widehat{f}(\psi) = \overline{\psi(a)} f(a)$, which is never zero, so its spectral footprint is all $N$ frequencies. Product: $1 \times N = N$. Extremal.

The **pure wave**: let $f(x) = c\,\chi(x)$ for a single character $\chi$ and a constant $c \ne 0$. Its footprint is all of $G$, size $N$; its transform is supported at the single frequency $\chi$. Product: $N \times 1 = N$. Extremal.

These are dual to each other, and they are the two extreme ends of a continuum. In between sit the **modulated coset indicators**. Take a subgroup $H \le G$ — say, in $\mathbb{Z}/12$, the multiples of $3$ — shift it to a coset $a + H$, and place on that coset a pure wave with a constant amplitude:
$$f(x) \;=\; \begin{cases} c\,\chi(x), & x - a \in H, \\ 0, & \text{otherwise.}\end{cases}$$
This is a *picket fence*: an evenly spaced comb of samples, all of the same size, whose phases march around the circle at a constant rate. Anyone who has computed the transform of a comb knows what comes out: another comb. Explicitly, the transform of $c\,\chi\,\mathbf{1}_{a+H}$ vanishes off the coset $\chi + H^{\perp}$ and equals $c\,\overline{(\psi - \chi)(a)}\,|H|$ on it, where
$$H^{\perp} = \{\psi \in \widehat{G} : \psi(h) = 1 \text{ for all } h \in H\}$$
is the **annihilator** of $H$: the set of frequencies blind to $H$. And here is the arithmetic miracle that makes everything work: $|H| \cdot |H^{\perp}| = N$, always. So the two footprints have sizes $|H|$ and $|H^\perp|$, whose product is exactly $N$. Every picket fence is extremal. Spikes ($H = \{0\}$) and pure waves ($H = G$) are the degenerate ends.

So we have a rich family of extremals. **Is that all of them?**

## The rigidity theorem

It is.

> **Rigidity Theorem.** A nonzero function $f$ on a finite abelian group $G$ satisfies
> $$|\operatorname{supp} f|\cdot|\operatorname{supp}\widehat{f}| = |G|$$
> *if and only if* there exist a subgroup $H \le G$, a point $a \in G$, a character $\chi$, and a scalar $c \ne 0$ such that $f = c\,\chi\,\mathbf{1}_{a+H}$.

The "if" is the computation above. The "only if" is the substance: a signal that spends exactly its budget has no freedom left at all. Not in the *shape* of its support — it must be a coset. Not in the *sizes* of its values — they must all be equal. Not in their *phases* — they must trace a character. Extremality is a straitjacket.

The proof is a chain of four squeezes, and each link is worth seeing, because each is a statement about when an inequality you use every day is *tight*.

**Squeeze 1: the spectrum is flat.** Start with the crude bound $|\widehat{f}(\psi)| \le \|f\|_1 = \sum_x |f(x)|$, valid for every frequency by the triangle inequality. Sum its square over the spectrum, which has $|\operatorname{supp}\widehat{f}|$ elements, and compare with Plancherel:
$$N\|f\|_2^2 \;=\; \sum_{\psi} |\widehat{f}(\psi)|^2 \;\le\; |\operatorname{supp}\widehat{f}| \cdot \|f\|_1^2 .$$
Meanwhile Cauchy–Schwarz applied to the support of $f$ gives $\|f\|_1^2 \le |\operatorname{supp} f| \cdot \|f\|_2^2$. Chain them: $N \|f\|_2^2 \le |\operatorname{supp}\widehat f| \cdot |\operatorname{supp} f| \cdot \|f\|_2^2$ — the uncertainty principle itself falls out. But if $f$ is extremal, the two ends agree, so **both** inequalities must be equalities. Equality in the first forces $|\widehat{f}(\psi)| = \|f\|_1$ for *every* frequency in the spectrum: the transform has constant modulus on its support.

**Squeeze 2: the phases align.** Saturating $|\widehat f(\psi)| \le \sum_{x} |f(x)|$ means equality in the triangle inequality for a sum of complex numbers, and equality there is rigid: all the summands must point in the same direction. Concretely, for each frequency $\psi$ in the spectrum and each $x$ in the support,
$$\|f\|_1 \cdot \overline{\psi(x)} f(x) \;=\; |f(x)| \cdot \widehat{f}(\psi),$$
so the *demodulated* value $\overline{\psi(x)}f(x)$ is a nonnegative multiple of one fixed complex number.

**Squeeze 3: the modulus is flat too.** Equality in Cauchy–Schwarz forces the vector $(|f(x)|)_{x \in \operatorname{supp} f}$ to be constant. Running the alignment identity back through Fourier inversion pins the common value exactly:
$$|f(x)| \cdot |\operatorname{supp} f| \;=\; \|f\|_1 \quad\text{for every } x \in \operatorname{supp} f.$$
A signal that spends exactly its budget cannot have a "large" sample and a "small" sample. All its nonzero samples have the same height.

**Squeeze 4: a hidden subgroup appears.** Combine the last two: for each frequency $\psi$ in the spectrum, the number $\overline{\psi(x)} f(x)$ has both constant modulus and constant phase as $x$ ranges over $\operatorname{supp} f$. So it is *literally constant*:
$$\overline{\psi(x)}f(x) = \overline{\psi(y)}f(y) \qquad (x, y \in \operatorname{supp} f,\ \psi \in \operatorname{supp}\widehat f).$$
Fix one spectral frequency $\psi_0$ and define the **phase subgroup**
$$H \;=\; \{ z \in G : \psi(z) = \psi_0(z) \text{ for all } \psi \in \operatorname{supp}\widehat{f}\},$$
the set of shifts on which every frequency in the spectrum is indistinguishable from $\psi_0$. Dividing the displayed identity for $\psi$ by the one for $\psi_0$ shows that the difference of any two support points lies in $H$; symmetrically, $\psi - \psi_0 \in H^{\perp}$ for every spectral $\psi$. So $\operatorname{supp} f$ injects into $H$ and $\operatorname{supp}\widehat f$ injects into $H^{\perp}$:
$$|\operatorname{supp} f| \le |H|, \qquad |\operatorname{supp}\widehat f| \le |H^{\perp}|.$$
But their products are both equal to $N$, thanks to $|H|\cdot|H^{\perp}| = N$. Two inequalities whose products agree must both be equalities. Hence $\operatorname{supp} f$ is *exactly* the coset $a + H$, the spectrum is *exactly* $\psi_0 + H^{\perp}$, and the constancy of $\overline{\psi_0(x)}f(x)$ says $f = c\,\psi_0\,\mathbf{1}_{a+H}$. $\blacksquare$

The final counting step deserves a moment of admiration. Two soft inclusions, each individually useless, become an exact identification the instant you notice that duality forces their sizes to multiply to the same number. That is the whole engine of rigidity in one line.

## What rigidity buys you

Once you know exactly who the extremals are, a shower of consequences falls out.

**A divisibility law.** The footprint of an extremal signal is a coset, so its size *divides* $N$. A signal on $\mathbb{Z}/12$ occupying exactly $5$ time-slots can never be extremal, no matter how cleverly you choose its values: $5 \nmid 12$. Conversely every coset does occur as an extremal support, so the obstruction is exactly divisibility and nothing more.

**A dichotomy in prime order.** If $N$ is prime, the only subgroups are $\{0\}$ and $G$, so an extremal is either a scaled spike or a scaled pure wave. There is no middle ground whatsoever. (This is the finite-field shadow of the Chebotarëv-type phenomena that make prime-length transforms so rigid, and it is the reason compressive-sensing practitioners like prime lengths.)

**Self-duality.** Extremality is preserved by the Fourier transform: if $f$ is extremal on $G$ then $\widehat{f}$ is extremal on $\widehat{G}$. The picture is symmetric under swapping time and frequency, exactly as the picket-fence description suggests.

**Uniqueness and orbit structure.** The subgroup $H$ appearing in the classification is not a choice: it is the group of *periods* of $\operatorname{supp} f$, namely $\{z : \operatorname{supp} f + z = \operatorname{supp} f\}$, and it is the same no matter which spectral frequency you use to define the phase subgroup. Two extremals with the same support differ only by a nonzero scalar and a modulation. So the extremal set is a disjoint union, over the cosets of the subgroups of $G$, of a single orbit of the scaling–modulation group. Nothing else is hiding.

**A combinatorial corollary.** Strip away all the amplitudes: for a nonempty set $S \subseteq G$, the indicator function $\mathbf{1}_S$ is extremal **if and only if $S$ is a coset of a subgroup**. A purely set-theoretic statement, proved by an argument about phases.

**A gap, not a slope.** Perhaps the most surprising consequence: near-extremality is impossible in a strong sense. If $f \ne 0$, if $|\operatorname{supp} f|$ divides $N$, and if $f$ is *not* one of the picket fences, then
$$|\operatorname{supp} f| \cdot |\operatorname{supp}\widehat f| \;\ge\; N + |\operatorname{supp} f|.$$
You cannot miss the bound by a little. The reason is arithmetic rather than analytic: with $|\operatorname{supp} f|$ dividing $N$, the product is a multiple of $|\operatorname{supp} f|$, so once it exceeds $N$ it must exceed it by a full step. The extremal locus is an isolated island, not the summit of a smooth hill.

## The trap: flat is not enough

Rigidity handed us two memorable "flatness" facts about extremals:

1. $|f|$ is constant on $\operatorname{supp} f$;
2. $|\widehat{f}|$ is constant on $\operatorname{supp} \widehat{f}$.

Both are clean, both are checkable, and together they smell like a characterization. Surely a signal that is flat in time *and* flat in frequency is a picket fence?

**No.** And the counterexample is one of the most famous objects in signal processing, wearing a group-theoretic disguise.

Take any nontrivial finite abelian group $K$ and form the *self-dual* group $G = K \times \widehat{K}$, whose order is $|K|^2$. On it define the **evaluation pairing**
$$f(x, \psi) \;=\; \psi(x).$$
When $K = \mathbb{Z}/n$, this is $f(x,y) = e^{2\pi i x y/n}$ — the discrete **chirp**, the finite cousin of the Gaussian-modulated wave $e^{i x \xi}$ that plays the same role in continuous time-frequency analysis, and the signal your car's radar sweeps out every few milliseconds.

Now look at it:

- $|f| \equiv 1$ on all of $G$, since characters are unimodular. So the modulus is constant on the support, which is everything: **flatness in time, in the strongest possible form.**
- Its Fourier transform has $|\widehat{f}(\chi)| = |K| = \sqrt{|G|}$ at *every* frequency $\chi$ of $\widehat{G}$. **Flatness in frequency, again in the strongest possible form.** (The computation: split an arbitrary character $\chi$ of the product group into its two factors, use Pontryagin duality to write the second factor as evaluation at some $z \in K$, and the inner sum $\sum_{\psi} \psi(x)\overline{\psi(z)}$ collapses by character orthogonality to $|K|$ when $x = z$ and $0$ otherwise. What survives is a single unimodular term times $|K|$.)
- Therefore both supports are *all* of their spaces, and
$$|\operatorname{supp} f| \cdot |\operatorname{supp}\widehat{f}| \;=\; |G|^2,$$
which is as far above the bound $|G|$ as any function can possibly be.

So the chirp is bi-flat and yet **maximally non-extremal**: not just a failure of the converse, but a failure at the opposite end of the scale. For every nontrivial $K$ — the smallest case being $K = \mathbb{Z}/2$, where $G$ has four elements — bi-flatness fails to imply extremality.

The moral is precise and, I think, genuinely illuminating. Rigidity is *not* about magnitudes. The two flatness conditions are consequences of the modulus bookkeeping in Squeezes 1 and 3, and they are the *cheap* part of the argument. The expensive part is Squeeze 4: the demand that the demodulated values $\overline{\psi(x)}f(x)$ agree **across the whole spectrum simultaneously**. That is a *coupling* between different frequencies, and it is what forces the phase subgroup into existence. The chirp shows exactly what happens when you drop it: each frequency individually sees a perfectly flat, perfectly balanced signal, but they disagree with one another about *which* phase pattern is in play, and that disagreement smears the energy everywhere.

Flatness is a snapshot. Rigidity is a conspiracy.

## Why any of this matters

The classification is not an isolated curiosity.

In **compressive sensing**, the whole theory of recovering a sparse signal from few measurements is built on the fact that a sparse signal cannot also have a sparse spectrum. The picket fences are the worst case — the signals for which recovery is genuinely ambiguous — and knowing that they are the *only* worst case is what licenses the sharp, uniform guarantees. The prime-order dichotomy is the reason a transform of prime length is uniquely well-behaved: there are no intermediate combs to hide behind.

In **coding theory and cryptography**, the coset-plus-character functions are precisely the objects whose Fourier support is a coset — the same structure that underlies the hidden subgroup problem, and hence Shor's algorithm. The phase subgroup constructed in Squeeze 4 is literally the hidden subgroup being extracted from the spectrum.

In **radar and time-frequency analysis**, the chirp counterexample is not a pathology but a design principle: engineers *want* signals that are flat in time and flat in frequency, because those spread energy evenly and correlate sharply against themselves. The theorem above tells you the price: perfect flatness on both sides is precisely incompatible with concentration. Bi-flat signals are the anti-extremals.

And in **pure additive combinatorics**, the statement "$\mathbf{1}_S$ is extremal iff $S$ is a coset" is a member of a large family of theorems asserting that near-optimal behaviour in a Fourier inequality forces exact algebraic structure. The gap theorem sharpens it: in the divisibility-constrained regime, structure is not merely approximate but binary. You are a coset, or you are at least one full step away from being one.

## The road ahead

The classification closes one problem and opens the natural next ones. The most tempting is **stability**: if the uncertainty product is at most $(1+\varepsilon)N$ rather than exactly $N$, must $f$ be within $O(\sqrt{\varepsilon})\|f\|_2$ of a genuine picket fence? Every step of the proof above degrades continuously — the two inequalities are each within a factor $1 + \varepsilon$ of equality, so flatness and alignment survive approximately — except the final counting step, which is stubbornly discrete. Finding the right approximate substitute for "$|H|\cdot|H^\perp| = N$" is the whole game.

A second direction asks whether the picket fences are the extremals for *every* exponent. Combining Plancherel with Hölder gives an $\ell^4$-form of the uncertainty principle, expressed through the additive energy of the spectrum; the conjecture is that its equality case produces the very same family. Both inequalities are driven by the same two mechanisms — a Hölder step whose equality case forces flatness, and a triangle step whose equality case forces alignment — so the extremal family should be independent of the exponent, an echo of the equality analysis of Hausdorff–Young.

Whatever the answers, the lesson of the chirp will stand. In Fourier analysis, the sizes tell you almost nothing; the phases tell you everything.
