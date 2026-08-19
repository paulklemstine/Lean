# The Formula That Refuses to Bend

## How one of analysis's most useful identities turns out to be a perfect detector of hidden symmetry

There is a small family of formulas in mathematics that seem to know more than they should. You feed them a function, they hand back a number, and somewhere in the exchange they quietly reveal a structural truth about the space you are working in. The Poisson summation formula is the most famous member of that family. This is the story of what happens when you try to break it — and of the discovery that it cannot be broken, bent, approximated, or renormalised. It either holds exactly, or it fails by a wide, quantifiable margin. There is nothing in between.

### Sampling, aliasing, and a very old idea

Start with something concrete. Suppose you are recording a sound. The microphone does not capture the whole continuous waveform; it takes samples, say $8{,}000$ times a second. Every engineer knows what happens next: frequencies above half the sampling rate do not vanish, they *masquerade*. A $9{,}000$ Hz tone recorded at $8{,}000$ samples per second comes back sounding like a $1{,}000$ Hz tone. Frequencies fold onto each other. This is aliasing, and it is the reason your camera turns a spinning wheel backwards.

Poisson summation is the exact bookkeeping of that folding. In its classical form it says that summing a function over a lattice of sample points is the same as summing its Fourier transform over the *dual* lattice — the finer you sample in space, the coarser your grid in frequency, and the two sums agree exactly. It is the identity behind the sampling theorem, behind theta-function transformations in number theory, behind Ewald summation in crystallography, behind the analytic proofs of quadratic reciprocity.

For this article we work in the cleanest possible arena: a finite abelian group $G$. Think of $G$ as the clock face $\mathbb{Z}/n\mathbb{Z}$ — the integers modulo $n$ — or as a product of several such clocks. A *character* of $G$ is a way of wrapping the group onto the unit circle in the complex plane without tearing it: a function $\psi : G \to \mathbb{C}$ with $|\psi(x)| = 1$ and
$$\psi(x+y) = \psi(x)\,\psi(y).$$
On $\mathbb{Z}/n\mathbb{Z}$ these are exactly the functions $x \mapsto e^{2\pi i k x/n}$, one for each $k$. The characters form a group of their own, of the same size as $G$, and the Fourier transform of a function $f : G \to \mathbb{C}$ is the recipe that evaluates $f$ against every character:
$$\hat f(\psi) \;=\; \sum_{x \in G} \overline{\psi(x)}\, f(x).$$

A **subgroup** $H \subseteq G$ is a subset containing $0$ and closed under addition and negation — the even residues inside $\mathbb{Z}/8\mathbb{Z}$, say, or the multiples of $3$ inside $\mathbb{Z}/12\mathbb{Z}$. Every subgroup has a shadow on the character side, its **annihilator**
$$H^\perp \;=\; \{\psi : \psi(x) = 1 \text{ for all } x \in H\},$$
the characters that cannot see $H$ at all: they are constantly $1$ there. The annihilator is the finite analogue of the dual lattice, and the sizes trade off exactly as sampling intuition demands: $|H| \cdot |H^\perp| = |G|$. Big subgroup, small annihilator.

With that vocabulary, Poisson summation on a finite abelian group reads:
$$|G| \sum_{x \in H} f(x) \;=\; |H| \sum_{\psi \in H^\perp} \hat f(\psi) \qquad \text{for every } f : G \to \mathbb{C}.$$
Sum over the subgroup on the left, sum over the annihilator on the right, weight each side by the size of the other, and the two agree — always, for every function whatsoever.

### The question nobody had answered

That identity is the "if" direction, and it is classical. But look at the statement again. Nothing in the *shape* of the formula demands that $H$ be a subgroup. Given any subset $S \subseteq G$ at all — the squares modulo $8$, a random handful of residues, three points chosen by throwing darts — you can still form its annihilator
$$S^\perp = \{\psi : \psi(x) = 1 \text{ for all } x \in S\},$$
and you can still write down the candidate identity
$$|G| \sum_{x \in S} f(x) \;\overset{?}{=}\; |S| \sum_{\psi \in S^\perp} \hat f(\psi) \qquad \text{for all } f. \tag{$P_S$}$$
Call a set satisfying $(P_S)$ a **Poisson set**. Subgroups are Poisson sets. Is anything else?

This is a natural question with a slightly menacing quality, because the equation has a lot of freedom in it. The left side depends on $S$ only through which points it contains; the right side depends on $S$ only through its annihilator, which is a much coarser object. There seems to be room for accidents — some strange set whose annihilator happens to compensate for its irregularity. The answer is that there is no room at all.

### The classification

**Theorem (Classification of Poisson sets).** *A finite subset $S$ of a finite abelian group $G$ satisfies $(P_S)$ for every function $f$ if and only if $S$ is empty or $S$ is a subgroup of $G$.*

The empty set is a genuine exception rather than an oversight — both sides of $(P_S)$ are then zero, since $|S| = 0$ and the empty sum vanishes — and it is the *only* exception. Everything else that satisfies Poisson summation is a subgroup, full stop.

Equivalently, and more usefully for anyone who wants to *check* the condition: for nonempty $S$, the analytic identity $(P_S)$ holds precisely when $0 \in S$ and $S$ is closed under subtraction. A statement about infinitely many complex-valued test functions collapses into a finite table lookup.

Something even sharper is true, and this is where the result becomes surprising rather than merely tidy. You do not need all functions $f$ to force the conclusion. You need one.

**Theorem (One test function suffices).** *Let $S$ be a set and $y_0$ any single point of $S$. If the identity $(P_S)$ holds for the single Dirac delta $\delta_{y_0}$ — the function equal to $1$ at $y_0$ and $0$ everywhere else — then $S$ is already a subgroup.*

A Dirac delta is the least informative function imaginable. It carries one bit of location and nothing else. Yet checking Poisson summation against that one spike, at any one point of $S$, is enough to certify that $S$ is closed under addition and negation. The identity is not merely rigid; it is rigid on contact.

### Why it works: the defect has a formula

The engine behind all of this is a single change of perspective. Any set $S$ sits inside the smallest subgroup containing it, its **generated subgroup** $\langle S \rangle$ — take $S$, add and subtract elements repeatedly until nothing new appears. The crucial observation is that the character side cannot tell $S$ and $\langle S \rangle$ apart:
$$S^\perp \;=\; \langle S \rangle^\perp .$$
A character that is $1$ on $S$ is automatically $1$ on all sums, differences, and negatives of elements of $S$; being constantly $1$ is a condition that propagates through the group operation. So the right-hand side of $(P_S)$ is *blind to the difference between $S$ and the subgroup it generates*, while the left-hand side sees it perfectly. As an immediate corollary, for every set $S$ whatsoever,
$$|\langle S\rangle| \cdot |S^\perp| \;=\; |G|,$$
the size trade-off being governed by the generated subgroup, not by $S$ itself.

Now define the **defect** of $S$ at $f$ as the amount by which $(P_S)$ fails:
$$D_S(f) \;=\; |G| \sum_{x \in S} f(x) \;-\; |S| \sum_{\psi \in S^\perp} \hat f(\psi).$$
Applying honest Poisson summation to the genuine subgroup $\langle S \rangle$ and substituting gives an exact, closed-form answer.

**Theorem (Defect formula).** *For every set $S$ and every function $f$,*
$$|\langle S\rangle| \cdot D_S(f) \;=\; |G| \Big( |\langle S\rangle| \sum_{x \in S} f(x) \;-\; |S| \sum_{x \in \langle S\rangle} f(x) \Big).$$

Read that right-hand side as a comparison of averages. Up to positive factors, the defect measures exactly the discrepancy between the average of $f$ over $S$ and the average of $f$ over the subgroup $S$ generates. If $S = \langle S\rangle$, the two averages coincide for every $f$ and the defect vanishes identically. If $S \subsetneq \langle S\rangle$, choose $f$ to be a spike sitting on a point of $S$ and the two averages cannot agree: the spike counts for a fraction $1/|S|$ of the $S$-average but only $1/|\langle S\rangle|$ of the larger average. The defect formula converts that mismatch into a number, and the number is not small.

**Theorem (Gap theorem — no approximate Poisson sets).** *If $S$ is nonempty and not a subgroup, then some Dirac delta supported at a point of $S$ has defect of magnitude at least*
$$|\langle S \rangle| - |S| \;\geq\; 1 .$$

This is the statement that kills any hope of an approximate theory. One might have imagined a spectrum of near-Poisson sets, sets that satisfy the identity to within a small error, useful in applications where exactness is unattainable. There is no such spectrum. Every non-subgroup misses by at least a full unit, and by much more when it is far from filling out its generated subgroup. The property is all-or-nothing.

Nor can the failure be repaired by fiddling with the normalisation. Suppose you allow yourself an arbitrary constant $c$ and ask when $|G| \sum_{x \in S} f(x) = c \sum_{\psi \in S^\perp} \hat f(\psi)$ holds for all $f$. For nonempty $S$ the answer is that $S$ must be a subgroup *and* $c$ must equal $|S|$. The constant in Poisson summation is not a convention; it is forced.

### Cosets, uncertainty, and a fingerprint for groups

Three consequences give the result texture.

**The affine picture.** Subgroups are not translation-invariant objects — sliding one over by a point destroys it — yet Fourier analysis handles translation beautifully: replacing $f$ by $f(x_0 + \cdot)$ multiplies each Fourier coefficient by the phase $\psi(x_0)$. Building that phase into the identity gives an *affine Poisson formula*
$$|G| \sum_{x \in S} f(x) \;=\; |S| \sum_{\psi \in (S - x_0)^\perp} \psi(x_0)\, \hat f(\psi),$$
and this phase-twisted version characterises **cosets** — translates $x_0 + H$ of subgroups — exactly as the untwisted version characterises subgroups. So the rigidity is affine, not merely linear. Concretely: the squares modulo $8$, namely $\{0, 1, 4\}$, are not a coset of anything, so no choice of base point rescues them.

**Extremality in the uncertainty principle.** Every set is squeezed between two dual size estimates. On one side, $|S| \cdot |S^\perp| \leq |G|$, inherited from the generated subgroup. On the other, the Donoho–Stark uncertainty principle applied to the indicator function $\mathbf{1}_S$ gives $|G| \leq |S| \cdot |\mathrm{supp}\,\widehat{\mathbf{1}_S}|$: a function and its Fourier transform cannot both be concentrated. The classification says the first inequality is an equality *precisely* for Poisson sets — and equivalently, that $S$ is Poisson exactly when the Fourier support of its indicator is exactly $S^\perp$, the smallest it could conceivably be. Poisson sets are the uncertainty extremals. Subgroups are, in the sharpest possible sense, the most concentrated objects a finite abelian group contains.

**Counting the formulas.** Since nonempty Poisson sets are exactly subgroups, the family of exact Poisson summation formulas available on $G$ is a perfect copy of the subgroup lattice of $G$. It is closed under intersection, but not under union: in the Klein four-group $\mathbb{Z}/2 \times \mathbb{Z}/2$ the two sets $\{0, (1,0)\}$ and $\{0, (0,1)\}$ are both Poisson, while their union is not — it misses $(1,1)$. And on a cyclic group the count is a classical arithmetic function: the number of exact Poisson summation formulas on $\mathbb{Z}/n\mathbb{Z}$ is exactly $d(n)$, the number of divisors of $n$. Twelve, for example, supports precisely six.

This turns the family of Poisson formulas into a fingerprint. The cyclic group $\mathbb{Z}/4\mathbb{Z}$ and the Klein four-group both have four elements, but the first supports four Poisson sets and the second supports six. How many exact Poisson summation formulas a group admits is not a function of how big it is; it is an invariant of its isomorphism type. Poisson summation *sees* the internal structure of the group.

### The moral

The classical direction of Poisson summation is a computational tool: it lets you trade an intractable sum for a tractable one. The converse recasts it as something else entirely — a *test*. Hand me a black box that evaluates $\sum_{x \in S} f(x)$ for a set $S$ I cannot see. I feed it a single spike, compare against the annihilator sum, and if the numbers match I know with certainty that $S$ is closed under addition and negation. If they do not match, I know they miss by at least one, and I can read off from the gap how far $S$ is from filling out the subgroup it generates.

The squares modulo $8$ — the residue set that governs which numbers can be legs of a Pythagorean triple — fail this test by a margin of $5$ out of a group of size $8$. That is not a near miss. It is the formula announcing, at full volume, that the quadratic residues have no additive structure whatsoever.

Symmetry, it turns out, is not something Poisson summation assumes. It is something Poisson summation detects.
