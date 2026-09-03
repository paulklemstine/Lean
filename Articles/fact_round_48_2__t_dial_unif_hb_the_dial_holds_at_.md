# The Dial That Refuses to Move

### A hidden information channel in factoring experiments, and the exact algebra that governs when it lives and when it dies

---

## A statistic that behaved suspiciously well

Suppose you are running a large numerical experiment, and you want to know, early and cheaply, whether a particular run is going to succeed. The obvious thing to measure is *how often good things happen*: the yield, the hit rate, the count. Count is honest, count is cheap, and count is what everyone measures.

In a series of experiments on integer factoring ladders — long computations that grind through candidate numbers looking for useful algebraic relations — a different statistic kept beating count. Call it the **dial**. Instead of asking *how many* candidates are useful, the dial asks a subtler question: *does knowing which class a candidate falls into tell you anything about whether it will be useful?* It is a measurement of information, not of volume.

Across four experimental cells — two sampling regimes ("balanced" and "uniform") crossed with two input sizes (44-bit and 48-bit moduli) — the rank correlation between the dial and the eventual success rate came out at $0.686$, $0.656$, $0.553$ and $0.561$. In every single cell the dial beat the raw count statistic, by margins of $+0.06$ to $+0.10$, with confidence intervals excluding zero.

Two things about that table are strange, and this article is about both of them.

The first strangeness is the *stability*. Change the sampling regime, change the bit-length, and the dial keeps working, with almost the same strength. Numbers in experimental mathematics do not usually behave so calmly. Something is holding it in place.

The second strangeness is the *fragility*. A companion pilot experiment took the same ladder and randomised one innocuous-looking knob — the *multiplier*, a small auxiliary constant $k$ that the algorithm is free to choose. Randomising $k$ did not degrade the dial. It annihilated it. The channel went to zero, while the count statistic did not budge by a hair.

Stability and total fragility, in the same statistic. Both turn out to be theorems, and they are theorems about the same object: a finite abelian group and its characters.

---

## What the dial actually measures

Strip away the factoring machinery and the picture is this.

There is a finite abelian group $G$ — in the applications, the class group attached to the numbers being sieved, or the group of units modulo a prime. Every candidate the sampler produces lands in some class $a \in G$. Attached to the sampler is a **class-rate profile**: a function
$$s : G \to [0,1],$$
where $s(a)$ is the probability that a candidate landing in class $a$ is useful. The **count statistic** is just the average of this function,
$$\bar{s} \;=\; \frac{1}{|G|}\sum_{a \in G} s(a),$$
the overall yield.

Now the twist that makes the dial possible. The objects the algorithm actually cares about are built from *two* draws — a composite number is made of two prime factors, a relation is made of two halves. The composite lands in the class $c = ab$, where $a$ and $b$ are the classes of its two halves. The event "no fork" — both halves usable — has, conditional on the observed class $c$, the probability
$$N_s(c) \;=\; \frac{1}{|G|}\sum_{a \in G} s(a)\,s(ca^{-1}).$$
This is a convolution: $N_s = s \star s$. If you average $N_s$ over all $c$, you get exactly $\bar{s}^{\,2}$, as you would expect from two independent draws.

The **dial** is the mutual information between the observed class and the binary useful/not-useful outcome:
$$T(s) \;=\; h\!\left(\bar{s}^{\,2}\right) \;-\; \frac{1}{|G|}\sum_{c \in G} h\bigl(N_s(c)\bigr),$$
where $h(x) = -x\log x - (1-x)\log(1-x)$ is the binary entropy function. The first term is the entropy of the outcome if you ignore the class label; the second is the average entropy once you are told the class. The difference is what the class label buys you. Because $h$ is concave, $T(s) \ge 0$ always, with equality exactly when the class label is useless.

Two samplers can have *identical* count $\bar{s}$ and wildly different dials. That is the entire point, and it is why the dial can beat the count as a predictor.

---

## The ceiling, and who touches it

How large can the dial get? Not arbitrarily large. There is a hard universal ceiling, the same for every group $G$ and every profile:
$$T(s) \;\le\; C^{*} \;=\; h\!\left(\tfrac14\right) - \tfrac12 h\!\left(\tfrac12\right) \;=\; \tfrac32\log 2 - \tfrac34 \log 3 \;\approx\; 0.21576 \ \text{nats} \;=\; 0.31128\ \text{bits}.$$

About a third of a bit. That is all the information the class of a two-factor composite can ever carry about whether both of its factors are useful.

And the ceiling is touched by exactly one kind of profile. Equality $T(s) = C^{*}$ holds precisely when $s$ is the indicator function of a coset of a subgroup of index two — that is, when
$$s(a) = 1 \text{ for } a \in xK, \qquad s(a) = 0 \text{ otherwise},$$
for some subgroup $K \le G$ with $[G:K] = 2$ and some class $x$. In arithmetic language: the extremal sampler is the one whose usefulness is decided by a **quadratic character**, a $\pm 1$-valued multiplicative function. The Legendre symbol is the archetype.

This is a rigidity statement of a familiar flavour — a sharp inequality whose equality case pins down a single algebraic structure — and it is the hinge on which everything that follows turns. If you want the maximum, you must be looking at a quadratic character. There is no other way to get there.

---

## Why the dial does not move: it only sees the shadow

Here is the resolution of the first strangeness.

Suppose $f : G \twoheadrightarrow Q$ is a surjection of finite abelian groups, and suppose the profile on $G$ is *pulled back* from $Q$: the usefulness of a candidate depends only on its image $f(a)$, not on its finer position in $G$. Then

> **Inflation Invariance.** The dial of the pulled-back profile equals the dial of the original: $T(s \circ f) = T(s)$. The same holds for the mean rate, and for the multi-factor versions of the dial at every number of factors.

The proof is two lines of counting. Summing a pulled-back function over $G$ just repeats each value $|\ker f|$ times, so averages are preserved; and the convolution of two pulled-back profiles is the pull-back of the convolution, because the fibres of a group homomorphism are cosets. Everything the dial is built from commutes with the projection, so the dial does too.

Now read that as a statement about experiments. Increasing the bit-length of the inputs enlarges the ambient class group — it adds factors, extra structure, more classes. Changing the sampling regime relabels the group, or crosses it with something new. Neither operation touches the *character quotient*, the small group that the profile actually factors through. And the dial is a function of that quotient alone.

Concretely: take an index-two subgroup $K$ of $G$, take any coset of it, and inflate the whole picture to a much larger group $G \times Q$ by adjoining an arbitrary extra factor. The dial reads exactly $C^{*}$ — the same value, in every cell of the regime $\times$ bit-length grid, for every choice of coset and every choice of $Q$. There is nothing to drift, because the quantity being measured never knew about the axes along which the experiment was being varied.

That is why four numbers in a table came out so close together. Not luck: an invariance.

---

## Why the dial dies: averaging kills characters

Now the second strangeness — and this is where the mathematics becomes sharp enough to design against.

The factoring ladder in question is free to multiply its input by a small constant $k$ before starting work. This is old, standard practice: a good multiplier improves the arithmetic. In the pilot, the multiplier was drawn at random for each candidate rather than being fixed. Model that: if the multipliers form a subgroup $H \le G$ of the class group, the sampler no longer sees $s$ but its **average over $H$**,
$$(\mathrm{mix}_H\, s)(a) \;=\; \frac{1}{|H|}\sum_{h \in H} s(ha).$$

Two facts about this operation are immediate, and their combination is the whole story.

> **Count blindness.** Randomising the multiplier leaves the mean rate *exactly* unchanged: $\overline{\mathrm{mix}_H\, s} = \bar{s}$.

Nothing about the yield changes. The count statistic is, by construction, incapable of noticing that anything happened.

> **The washout dichotomy.** A profile invariant under the multiplier group $H$ can attain the ceiling $C^{*}$ **if and only if** $H$ is contained in some subgroup of index two.

The reason is exactly the rigidity of the ceiling. If a maximiser exists, it must be a coset indicator $1_{xK}$; and if that function is unchanged by multiplication by elements of $H$, then $H$ has to sit inside $K$. Conversely, if $H \le K$, the coset indicator itself is $H$-invariant and hits the cap. The surviving channel is precisely a quadratic character that is *trivial on the multipliers*.

At the level of a single character, the mechanism is a classical orthogonality argument. If $\chi$ is the $\pm 1$ character of $K$ and the multiplier group contains even *one* element outside $K$ — a single "non-residue" multiplier $h_1$ — then pairing $g$ with $gh_1$ flips the sign of every term and forces
$$\sum_{g \in H} \chi(g) = 0.$$
The randomised profile then collapses to the constant $\tfrac12$, and the dial reads not "somewhat less" but **exactly zero**. One bad multiplier is enough. Averaging equidistributes the character, and an equidistributed character carries no information at all.

Put the two facts side by side and you get the sharpest form of the empirical finding: the profile $1_K$ and its randomised version have *the same mean rate*, and their dials differ by the *full* cap $C^{*} > 0$. The count statistic sees a tie where the dial sees the maximum possible separation. That is precisely what the pilot experiment observed — and precisely why the experimental ladder has to be run with a fixed multiplier $k = 1$.

---

## The parity criterion: it comes down to a single power of two

The dichotomy above is stated in terms of subgroups, which is not something you can look up. But over a finite abelian group it converts into pure arithmetic.

> **Parity criterion.** For a finite abelian class group $G$ and a multiplier group $H$, a maximal channel survives multiplier randomisation **if and only if the index $[G:H]$ is even**.

One direction is trivial: a subgroup of index two forces even index. The other direction needs a genuine theorem — *every finite abelian group of even order contains a subgroup of index two* — and there is a proof that avoids the classification of abelian groups entirely. Take a $2$-subgroup one power short of a full Sylow $2$-subgroup; the quotient has order $2m$ with $m$ odd. In an abelian group of order $2m$, the squaring map is a homomorphism whose kernel is a $2$-group (every element squares to the identity), is nontrivial (Cauchy's theorem gives an element of order $2$), and cannot have order $4$ (since $4 \nmid 2m$). So the kernel has order exactly $2$, its image has index exactly $2$, and pulling back along the quotient maps gives an index-two subgroup upstairs.

Full randomisation is the case $H = G$, index $1$, odd: always fatal. A fixed multiplier is the case $H = \{1\}$, index $|G|$: harmless whenever the class group has even order — which, for the unit groups $(\mathbb{Z}/p)^{\times}$ of odd primes, is always.

Better still, the criterion tells you exactly how much randomisation an adversary can afford. Write $2^{v_2(|G|)}$ for the **$2$-part** of the group order — the largest power of two dividing it.

> **Budgeted adversary theorem.** A maximal channel survives randomisation by *every* multiplier group of order at most $B$ **if and only if** $B < 2^{v_2(|G|)}$. At the threshold, a single group — a Sylow $2$-subgroup — drives every profile strictly below the cap while leaving the mean rate untouched.

The design rule this yields is counter-intuitive and worth stating plainly: **the size of the class group is no defence at all.** What protects the channel is only the $2$-part. A class group of order $2m$ with $m$ odd, however astronomically large $m$ may be, is destroyed by a multiplier budget of $2$ — a single extra multiplier, chosen adversarially. For the unit group modulo $p$, the safe budget is the $2$-part of $p-1$: for $p = 17$ it is $16$, and for $p = 19$ or $p = 31$ it is a miserable $2$.

---

## Between life and death: a continuum

The dichotomy — cap or nothing — is real, but it is the picture you get by looking only at *subgroup* averaging. Widen the lens and the two outcomes turn out to be the endpoints of a smooth curve.

Fix a quadratic character $\chi$ of $G$ and a contrast parameter $t \in [0,1]$, and consider the family of profiles
$$s_t(a) \;=\; \frac{1 + t\,\chi(a)}{2}.$$
At $t = 1$ this is the coset indicator, the maximiser; at $t = 0$ it is the constant $\tfrac12$, carrying nothing; in between it is a noisy version of the character. Every member of the family has the same mean rate $\tfrac12$ — the count statistic is blind along the whole family.

A short computation, using only $\chi(a)^2 = 1$ and the vanishing of $\sum_a \chi(a)$, gives the conditional no-fork probability exactly:
$$N_{s_t}(c) \;=\; \frac{1 + t^{2}\chi(c)}{4}.$$
Note the square. The fork event pairs *two* independent draws, and each contributes a factor of the contrast, so the observable contrast is $t^2$, not $t$. This is a genuine prediction: halve the character contrast in your sampler and you quarter the contrast that reaches the detector.

Consequently the dial collapses to a one-dimensional, group-free law:
$$T(s_t) \;=\; D(t^{2}), \qquad D(u) \;=\; h\!\left(\tfrac14\right) - \tfrac12\left[h\!\left(\tfrac{1+u}{4}\right) + h\!\left(\tfrac{1-u}{4}\right)\right].$$
Strict concavity of the binary entropy makes $D$ strictly increasing on $[0,1]$, with $D(0) = 0$ and $D(1) = C^{*}$: as the contrast grows, the two evaluation points $(1 \pm u)/4$ spread apart and the concavity gap widens. Numerically the growth is dramatically non-linear — $D(t^2)$ is $0.0105$ at $t = 0.5$, $0.0727$ at $t = 0.8$, $0.1225$ at $t = 0.9$, and $0.2158$ at $t = 1$. Nine-tenths of the contrast retains barely over half of the information.

And now the dichotomy has a clean explanation. Subgroup multipliers act on this family in only two ways: if $H \le K$ they leave $t$ alone, and if $H \not\le K$ they send $t$ to $0$. A subgroup can only sit at the two endpoints of the curve. The curve itself, however, is fully populated: for every $0 < t < 1$ there is a legitimate sampler with the same yield as the optimal one and a dial value strictly between zero and the cap.

---

## Beyond quadratic, beyond two factors

Two final extensions show that none of this is an accident of the number two.

**Any order.** Replace the index-two subgroup by a subgroup $K$ of any index $d \ge 2$ — a residue channel of order $d$ rather than a quadratic one. With fixed multipliers, the dial of the indicator $1_K$ is
$$T(1_K) \;=\; h\!\left(\tfrac{1}{d^{2}}\right) - \tfrac1d\, h\!\left(\tfrac1d\right),$$
which is strictly positive for every $d$: $0.2158$, $0.1367$, $0.0932$, $0.0679$, $0.0518$ for $d = 2,3,4,5,6$. And as soon as the multiplier group generates every residue class modulo $K$ — the natural generalisation of "contains a non-residue" — the randomised profile flattens to the constant $1/d$ and the dial reads exactly $0$, with the mean rate $1/d$ unchanged throughout. The collapse is a phenomenon of characters, not of parity.

**Any number of factors.** For composites with $k$ prime factors rather than two, the same construction uses the $k$-fold convolution power, and for a quadratic character kernel the value is
$$\Phi_k(1_K) \;=\; h\!\left(2^{-k}\right) - \tfrac12 h\!\left(2^{-(k-1)}\right) \;>\; 0 \quad \text{for all } k \ge 2.$$
The dial decays as the number of factors grows — $0.2158$, $0.0956$, $0.0454$, $0.0222$, $0.0110$ for $k = 2, \ldots, 6$ — but it never dies. Full multiplier randomisation, on the other hand, sends it to exactly zero at every $k$ simultaneously, with the mean rate again preserved exactly. The contrast between "count sees nothing" and "the dial sees everything" holds at every level of the multi-prime hierarchy.

---

## What the table was really showing

Return to those four numbers: $0.686$, $0.656$, $0.553$, $0.561$.

The experiment varied two axes, regime and bit-length, and found essentially one answer. The theory explains why: the dial is an invariant of the character quotient, and neither axis changes that quotient. The experimental grid was, from the dial's point of view, a single cell.

The experiment also found that the dial beat the count everywhere, by $0.06$ to $0.10$. The theory explains that more forcefully than the data could: there exist pairs of samplers with *exactly* equal counts whose dials differ by the entire admissible range. Count is not a slightly weaker statistic than the dial; it is blind along the precise direction in which the dial is maximally sensitive.

And the experiment found that randomising a harmless-looking knob destroyed everything. This is not a bug to be tuned away but an exact algebraic law with an exact arithmetic threshold: the channel survives a randomising adversary of budget $B$ precisely when $B$ is smaller than the $2$-part of the class group order.

Three empirical observations — one stable, one comparative, one catastrophic — and each is the visible face of a theorem about characters of finite abelian groups. It is a small and pleasing example of the way experimental mathematics is supposed to work: you notice that a number refuses to move, you ask why, and the answer turns out to be that you were measuring a quotient all along.
