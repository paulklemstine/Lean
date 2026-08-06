# The Arithmetic of Groove: How Symmetry Sets the Price of a Rhythm

## A drum machine is a wallpaper

Open any drum machine and you meet a grid. Time runs left to right in sixteen
little steps; instruments — kick, snare, hat, clap — stack up the vertical axis.
Each cell of the grid is either lit or dark. A rhythm is nothing more than a
choice of lit cells.

Count them. Sixteen steps times four instruments is $64$ cells, and each cell is
an independent binary choice, so there are $2^{64}$ possible patterns: roughly
eighteen quintillion. If you auditioned one per second you would need six
hundred billion years. And yet, when a producer sits down at that machine,
almost none of those eighteen quintillion patterns are live options. Something
prunes the space, drastically, before a single decision is made.

That something is **symmetry**. A groove repeats. A canon answers itself a bar
later. A backbeat is invariant under a half-bar shift. A palindromic fill reads
the same forwards and backwards. Each of these is a statement that the pattern
is unchanged by some transformation of the grid — and every such statement is a
constraint that shrinks the space of possibilities.

This article is about turning that vague observation into an exact accounting.
The central claim is short enough to fit on one line:

> **Every symmetry you impose costs you a precise, computable number of bits,
> and the exchange rate is the number of orbits.**

What follows is what that sentence means, why it is true, and what it buys you.

## Patterns that are blind to a symmetry

Fix a finite set of cells — call it the grid — and fix a group $G$ of
transformations acting on it. A **pattern** is a function assigning to each cell
either "on" or "off". The pattern is **$G$-invariant** if applying any
transformation in $G$ leaves it looking exactly the same: for every $g \in G$
and every cell $a$,
$$ f(g \cdot a) = f(a). $$

Here is the first, and most important, observation. Invariance is not a
complicated condition. It says only this: *whenever two cells can be carried
into one another by the group, they must agree.* Group the cells into **orbits**
— maximal families of cells mutually reachable by the group — and an invariant
pattern is exactly a free choice of on/off, once per orbit.

That gives the theorem the entire subject rests on.

> **Orbit Capacity Theorem.** *If a group $G$ acts on a finite grid with exactly
> $m$ orbits, then the number of $G$-invariant binary patterns is exactly
> $2^{m}$. Equivalently, the space of $G$-invariant patterns carries exactly $m$
> bits of information.*

The proof is a single sentence: an invariant pattern is a function on the set of
orbits, and there are $2^m$ Boolean functions on an $m$-element set.

Suddenly the accounting question — *how much creative room does this style leave
me?* — has become a counting question: *how many orbits does the symmetry group
have?* And counting orbits is a solved problem.

## Burnside does the bookkeeping

The classical tool is a lemma from the nineteenth century, usually credited to
Burnside (and, more honestly, to Cauchy and Frobenius): the number of orbits of
a finite group equals the *average* number of cells left in place by a group
element,
$$ m \;=\; \frac{1}{|G|}\sum_{g \in G} |\mathrm{Fix}(g)|. $$

Substituting into the capacity theorem gives a formula that turns geometry into
a number of bits:

> **Burnside Capacity Formula.** *The number of $G$-invariant patterns on a
> finite grid is*
> $$ 2^{\,\frac{1}{|G|}\sum_{g\in G}|\mathrm{Fix}(g)|}. $$
> *Division-free form: the number of invariant patterns, raised to the power
> $|G|$, equals $2^{\sum_g |\mathrm{Fix}(g)|}$.*

You never have to enumerate the orbits. You only have to answer, for each
symmetry separately, "how many cells does this one pin down?" — usually a
one-line calculation. Then you average, and the exponent falls out.

## Four symmetries, four exact prices

Make the drum grid concrete. Let time be cyclic with period $p$ and pitch cyclic
with period $q$: the grid is the discrete torus $\mathbb{Z}_p \times
\mathbb{Z}_q$, with $pq$ cells and $2^{pq}$ unrestricted patterns. Now impose
each of the four generators a crystallographer would recognise.

**Translation (the ostinato).** Demand invariance under *every* time shift. The
orbits are the horizontal circles — one per pitch — so there are $q$ of them,
and the capacity is exactly $2^{q}$. On a four-beat, three-instrument grid that
is $8$ patterns out of $4096$. Total time-shift invariance is a brutal
constraint: it says the rhythm has no rhythm at all, only a choice of which
instruments drone.

**Point reflection (retrograde–inversion).** The transformation
$(t,n) \mapsto (-t,-n)$ plays the pattern backwards while turning it upside
down. Everything is paired with its antipode except the cells that are their own
negatives. In a cycle of length $n$ there are $\tau(n) = 2$ such cells when $n$
is even (the origin and the half-period) and $\tau(n) = 1$ when $n$ is odd (just
the origin). Burnside then gives $(pq + \tau(p)\tau(q))/2$ orbits, so

> **Point-Reflection Capacity.** *The number of retrograde–inversion invariant
> patterns on the $p \times q$ torus is exactly*
> $$ 2^{\left(pq + \tau(p)\tau(q)\right)/2}, \qquad
>    \tau(n) = \begin{cases} 2 & n \text{ even},\\ 1 & n \text{ odd}.\end{cases} $$

On the $3\times3$ torus that is $2^5 = 32$; on the $4\times3$ torus, where the
even time axis contributes an extra fixed cell, $2^7 = 128$. The parity of the
bar length is not a detail — it changes the answer.

**Quarter turn.** Rotating a grid by ninety degrees mixes the time and pitch
axes, so it only makes sense when the two periods agree. That is a theorem, not
a convention:

> **Quarter-Turn Descent Criterion.** *The planar quarter turn
> $(t,n)\mapsto(-n,t)$ preserves the sublattice $p\mathbb{Z}\times q\mathbb{Z}$
> — equivalently, it descends to a well-defined map of the $p\times q$ torus —
> if and only if $p = q$.*

More generally, the transformations of the plane that preserve the square
lattice are the eight signed permutation matrices. The diagonal ones — axis
reflections and the half turn — descend to *every* torus. The swapping ones —
quarter turns and diagonal reflections — descend *only* to the square tori. So
a rectangular drum grid has an eight-element point group cut down to four, and
the missing four are exactly the ones that would trade a beat for a semitone.

On a square torus the quarter turn generates a cyclic group of order four, whose
square is precisely the retrograde–inversion above. Its Burnside data: the
identity fixes $p^2$ cells; each quarter turn fixes the diagonal cells $(t,t)$
with $t = -t$, of which there are $\tau(p)$; the half turn fixes $\tau(p)^2$.

> **Quarter-Turn Capacity.** *The number of quarter-turn invariant patterns on
> the $p\times p$ torus is exactly*
> $$ 2^{\left(p^2 + 2\tau(p) + \tau(p)^2\right)/4}
>   = \begin{cases} 2^{(p^2+3)/4} & p \text{ odd},\\[2pt]
>                   2^{(p^2+8)/4} & p \text{ even}.\end{cases} $$

Concretely: $8$ patterns on the $3\times3$ grid, $128$ on the $5\times5$, $8$ on
the $2\times2$, $64$ on the $4\times4$. Note the collision at $p=3$ and $p=2$:
a very small even grid can be *less* constrained than a slightly larger odd one,
because its extra two-torsion cells are extra freedom.

**Glide reflection.** The fourth and subtlest generator is the glide: reflect,
then slide by half a period. Musically it is the inverted answer displaced by
half a bar — the move that makes a canon feel like a mirror rather than an echo.
On a torus with even time period $p$ the glide is
$$ \gamma(t,n) = \bigl(t + \tfrac{p}{2},\, -n\bigr). $$
It is an involution, and — this is its defining feature — it has *no fixed
cells at all*. A glide is a symmetry that is a symmetry of no point. Burnside
therefore averages $pq$ and $0$:

> **Glide Capacity.** *On the $p \times q$ torus with $p$ even, the glide
> reflection $\gamma$ has exactly $pq/2$ orbits, all of size two, and the number
> of $\gamma$-invariant patterns is exactly $2^{pq/2}$ — a clean halving of the
> bit budget.*

That is $64$ patterns on the $4\times3$ torus and $4$ on the $2\times2$. Among
all the crystallographic generators, the glide is the one with the cleanest
price tag: exactly half your bits, no parity corrections, no exceptions.

## More symmetry is always cheaper — and usually strictly cheaper

The capacities above line up in an order, and the order is not an accident.

> **Monotonicity of Capacity.** *If $H \leq K$ are groups of symmetries, then
> there are no more $K$-invariant patterns than $H$-invariant ones. Moreover the
> drop is **strict** as soon as $K$ merges two cells that $H$ keeps in separate
> orbits — and if $K$ merges nothing new, the two capacities are equal.*

So the exchange rate is exact in both directions: capacity falls if and only if
the larger group genuinely fuses orbits. A symmetry you impose that the pattern
already had for free costs you nothing.

## Which symmetries can a single pattern have?

So far we have fixed a group and counted patterns. Turn it around: fix a
pattern, and ask what its symmetries are. The **symmetry group** of a pattern is
the set of transformations that happen to leave it alone; it is always a
subgroup of the ambient group, and the pattern is invariant in the earlier sense
exactly when this subgroup is everything.

It is easy to see that a real rhythm sits strictly in between. Take the
backbeat on a four-beat cycle: onsets on beats $0$ and $2$. Its symmetry group
contains the half-bar shift, so it is not trivial; it does not contain the
one-beat shift, so it is not everything. A pattern's symmetry group must be
carefully distinguished from the ambient crystallographic group — a distinction
that gets blurred with disappointing frequency in informal accounts of "the
seventeen wallpaper groups of music".

Are the intermediate cases all realised, or are there gaps? None:

> **Realizability of Symmetry Types.** *For a group acting on itself by
> translation, **every** subgroup $H$ occurs exactly as the symmetry group of an
> explicit pattern: the indicator function of $H$. On a $p\times q$ drum grid,
> for the cyclic time-shift group, every subgroup of the shift group is exactly
> the symmetry group of the pattern that lights a column $(t,n)$ precisely when
> the shift by $t$ lies in $H$.*

There is no missing symmetry type. The full lattice of subgroups, from trivial
to total, is populated by honest patterns.

## What "canon" really costs

Musical vocabulary is full of words that sound like theorems and behave like
vibes. Here is one made precise. Call a pattern a **canon at time distance $g$**
if shifting the whole thing forward by $g$ reproduces it exactly. That is a
property a given grid either has or does not, so it can be tested — and
refuted.

Because the shift action on a torus is *free* (no nonzero shift fixes any cell),
the shifts generated by $g$ chop the onsets into complete groups of size $d$,
the order of $g$. Hence the constraint:

> **Canon Divisibility.** *If a pattern is a canon at time distance $g$, its
> number of onsets is divisible by $d$, the additive order of $g$.*

Call a piece a canon at a distance that generates the whole bar, and its onset
count had better be a multiple of the bar length. This is a numerical test that
an actual score can fail.

And the test wastes nothing — every value the obstruction permits is achieved:

> **The Complete Onset Spectrum of Canons.** *A number $k$ is the onset count of
> some canon at time distance $g$ on the $p\times q$ torus **if and only if**
> $d \mid k$ and $k \leq pq$.*

The engine is a general fact worth stating on its own: a finite group acting
freely on a finite set has an invariant subset of every size $|\Gamma|\cdot j$
with $j$ at most the orbit count — just take the union of $j$ whole orbits.
Applied to a four-beat, one-instrument grid and the half-bar shift, the spectrum
is exactly $\{0, 2, 4\}$: a half-bar canon on one drum has zero, two, or four
onsets, and nothing else is possible.

## Bits, entropy, and the cost of taste

All of this measures capacity in the crude sense: how many patterns are legal.
Real music is not uniform over its legal patterns — a style prefers some grooves
enormously over others. Does that change the accounting?

It does, and by exactly the amount you would hope.

> **Maximum-Entropy Bound.** *Any probability distribution on the space of
> $G$-invariant patterns has Shannon entropy at most $m$ bits, where $m$ is the
> number of orbits, with equality **precisely** for the uniform distribution.*

So the orbit count is not just a count; it is a hard information-theoretic
ceiling on any generative model that respects the symmetry. Every stylistic
preference strictly lowers the entropy.

By how much? Consider the most natural biased model: independently, switch each
orbit on with probability $\theta$ and off with probability $1-\theta$. The
resulting distribution on invariant patterns has an entropy that can be computed
in closed form.

> **Orbit-Bernoulli Entropy.** *The entropy of the $\theta$-biased orbit model
> on $G$-invariant patterns is exactly $m \cdot H_2(\theta)$ bits, where*
> $$ H_2(\theta) = -\theta\log_2\theta - (1-\theta)\log_2(1-\theta) $$
> *is the binary entropy function. Consequently the **entropy deficit** — the
> gap between the full capacity $m$ and the model's entropy — is exactly*
> $$ m - m\,H_2(\theta) \;=\; m\bigl(1 - H_2(\theta)\bigr), $$
> *and, since $H_2(\theta) \leq 1$ with equality only at $\theta = 1/2$, the
> deficit is nonnegative and vanishes exactly for the unbiased model.*

The interpretation is clean and, I think, genuinely useful. **Stylistic bias
costs a fixed number of bits per orbit.** A style with a sparse aesthetic —
onsets on maybe a fifth of the available slots, $\theta = 0.2$ — has
$H_2(0.2) \approx 0.722$, so it spends about $0.278$ bits of every orbit's
budget on being recognisably itself. Double the number of orbits and you double
both the raw capacity and the absolute cost of the style. The per-orbit price is
a property of the taste alone; the total is that price times the geometry.

That factorisation — *geometry supplies the orbit count, taste supplies the
per-orbit deficit, and the two simply multiply* — is the most satisfying thing
in this whole story. It says a rhythm's information content splits cleanly into
a structural part you can compute from the symmetry group with Burnside's lemma,
and a stylistic part you can estimate from onset density alone.

## Where the story does and does not go

Two cautions, both worth stating because the folklore version of this subject
overreaches in exactly these places.

First, the seventeen wallpaper groups. It is tempting to announce that rhythmic
patterns are classified by the seventeen planar crystallographic groups. Nothing
above proves that, and the descent results show why the claim needs care: on a
rectangular torus, half the point group simply does not exist. Which planar
symmetries survive quotienting to a $p \times q$ grid is a question with a
precise answer, and that answer depends on $p$ and $q$. A genuine classification
theorem would first need planar Euclidean isometries, lattices, discreteness,
and compactness of the quotient — and then a proof.

Second, the musical vocabulary. Words like "canon", "round", and "blues form"
are hypotheses to be evaluated, not consequences of any classification. The
canon predicate above shows how such a word can be made honest: state it as a
property of the grid, derive a numerical consequence, and check it. The onset
spectrum theorem then shows the consequence is not merely necessary but exactly
right.

What *is* established is a small, sharp toolkit. Symmetry groups act on grids;
invariant patterns number $2^{\text{orbits}}$; Burnside computes the orbits from
fixed-point counts; the four crystallographic generators each have a closed-form
price on the torus, with parity corrections where the geometry demands them;
every subgroup is realised as somebody's symmetry group; the canon label has a
complete numerical spectrum; and probabilistic models obey a maximum-entropy
ceiling whose deficit, for the natural biased model, is exactly one fixed cost
per orbit.

Eighteen quintillion patterns on a drum machine. Ask for a glide and you are
down to $2^{32}$, about four billion. Ask for a full ostinato and you are down
to $2^{4} = 16$. The grid never gets smaller — the orbits do, and the bits go
with them.
