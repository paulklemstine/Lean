# Perfect Rulers and the Arithmetic of Distinct Sums

## A puzzle about addition

Pick a handful of whole numbers. Now add them together in every possible
way — every pair, in every order — and write down the sums. A natural
question that mathematicians have chewed on for nearly a century is
disarmingly simple: *how many of those sums can be forced to collide, and
how few?*

Consider the set $\{0, 1, 3, 7\}$. Its pairwise sums are

$$0{+}0=0,\quad 0{+}1=1,\quad 0{+}3=3,\quad 0{+}7=7,\quad 1{+}1=2,\quad 1{+}3=4,$$
$$1{+}7=8,\quad 3{+}3=6,\quad 3{+}7=10,\quad 7{+}7=14.$$

Look closely: apart from the unavoidable symmetry $a+b = b+a$, every one
of these sums is *different*. There are no surprise coincidences, no two
genuinely different pairs landing on the same total. A set with this
property — where the only way to get $a+b = c+d$ is the trivial one — is
called a **Sidon set**, after the analyst Simon Sidon who introduced them
in the 1930s while studying Fourier series.

Now compare with the innocent-looking $\{0,1,2,3\}$. Here $0+3 = 1+2 = 3$,
and $0+2 = 1+1 = 2$: the sums pile up. This set is *not* Sidon. The
difference between these two four-element sets is the whole story, and it
turns out to have a crisp, quantitative shape.

## Rulers with no repeated distances

Sidon sets go by many names in different corners of mathematics. Engineers
building radar and sonar arrays call the same idea a **Golomb ruler**: an
imaginary ruler whose tick marks are placed so that every pair of marks is
a *different* distance apart. Such rulers let you reconstruct which pair
produced a measured echo without ambiguity, which is exactly what you want
when you are trying to locate an aircraft from the delays between reflected
pulses. The condition "all pairwise sums distinct" and "all pairwise
differences distinct" are two faces of the same coin.

The same objects appear in the design of error-correcting codes, in
frequency-hopping schemes that keep radio channels from interfering, and in
the pure number theory of how dense a set of integers can be while keeping
its sums under control. A recurring theme in all of these is a single
guiding intuition: **a Sidon set is as "spread out" as a set can possibly
be, additively.** This article is about making that intuition into an exact
theorem.

## Measuring collisions: additive energy

To turn "how many coincidences" into a number, mathematicians use a
quantity called the **additive energy** of a set $s$, written $E[s]$. It is
simply the count of all quadruples $(a,b,c,d)$ of elements of $s$ — order
mattering — that satisfy the equation

$$a + b = c + d.$$

Every such quadruple is one "collision event." A set with low energy has
few collisions; a set with high energy is riddled with them. Additive
energy is one of the central measuring sticks of modern combinatorics: it
quantifies exactly how far a set is from being additively random, and it
sits at the heart of deep results about arithmetic structure.

There is a beautiful way to picture $E[s]$. For each integer $x$, let
$r_s(x)$ count the number of ordered pairs $(a,b)$ from $s$ with $a+b = x$.
This function $r_s$ is the **self-convolution** of the set — you can think
of it as a smoothed-out silhouette that records how many ways each total
can be reached. Then a short calculation shows

$$E[s] = \sum_x r_s(x)^2.$$

In words: the additive energy is the squared "size" — the $L^2$ energy — of
the convolution silhouette. A jagged silhouette with tall spikes (many ways
to reach a few totals) has large energy; a flat silhouette spread thinly
across many totals has small energy. Sidon sets are the ones whose
silhouette is as flat as arithmetic allows.

## The exact floor

Here is the first main result. No matter which finite set of integers you
choose, its additive energy can never dip below a fixed floor determined
only by how many elements it has.

> **The Energy Floor.** Every finite set $s$ of integers satisfies
> $$E[s] \ge 2|s|^2 - |s|,$$
> where $|s|$ denotes the number of elements of $s$.

Why is there a floor at all? Because some collisions are *free* — they
happen automatically for every set, Sidon or not. Whenever you pick any two
elements $a$ and $b$, the equation $a + b = a + b$ is a (trivial) solution,
and so is $a + b = b + a$. These two families of forced solutions already
account for $2|s|^2$ quadruples, and they overlap only in the $|s|$ cases
where $a = b$. Subtract the double-counted overlap and you get exactly
$2|s|^2 - |s|$ guaranteed collisions. You can never have fewer.

The second main result says that Sidon sets are precisely the sets that
have *no others*.

> **The Sidon Characterisation.** A finite set of integers $s$ is a Sidon
> set if and only if its additive energy attains the floor exactly:
> $$E[s] = 2|s|^2 - |s|.$$

So being a Sidon set is not just *a* minimality property — it is *the*
minimality property. Sidon sets are the exact minimisers of additive
energy among all sets of a given size. Every extra coincidence beyond the
forced ones pushes the energy strictly above the floor, and conversely any
set sitting on the floor has smuggled in no extra coincidences at all.

Let us sanity-check with our two examples. For the Sidon set $\{0,1,3,7\}$,
$|s| = 4$, so the floor is $2\cdot 16 - 4 = 28$; and indeed a direct count
gives $E = 28$. For the non-Sidon $\{0,1,2,3\}$, the floor is again $28$,
but a direct count gives $E = 44$ — a strict surplus of $16$, the fingerprint
of its many collisions. Even the tiny arithmetic progression $\{0,1,2\}$ has
energy $19$, comfortably above its floor of $2\cdot 9 - 3 = 15$.

## Two kernels, and only two

The most striking part of the story is *why* the floor has the value it
does — and it is here that the "multi-kernel" theme of the title comes into
sharp focus. One might imagine that certifying the minimum energy requires a
clever, growing collection of gadgets, one tuned to each set. The truth is
the opposite: the entire minimum is witnessed by exactly **two** elementary
building blocks, the same two for every set, no matter how large.

Picture the collection of all collision quadruples as points in a large
grid. The forced collisions organise themselves into two overlapping
"kernels":

- **The diagonal kernel.** These are the quadruples of the shape
  $a + b = a + b$: pick any $a$ and any $b$, and read off the trivial
  identity. There are exactly $|s|^2$ of them.
- **The swap kernel.** These are the quadruples of the shape
  $a + b = b + a$: the same pair, with the roles of the two summands
  exchanged. Again there are exactly $|s|^2$ of them.

These two kernels are almost disjoint. They meet only where a pair is its
own swap — that is, when $a = b$ — and there are exactly $|s|$ such shared
quadruples. By the inclusion–exclusion principle, their union has

$$|s|^2 + |s|^2 - |s| = 2|s|^2 - |s|$$

quadruples. That is the floor, laid bare as a simple count.

The punchline: for a Sidon set, these two kernels are not merely a *lower*
bound — they are *everything*. Every single collision in a Sidon set is
either a diagonal identity or a swap; there are no others. So the energy of
a Sidon set is realised, exactly and on the nose, as the almost-disjoint
union of two shifted copies of the set's own product. The heuristic that
one needs many kernels, weighted and tuned, collapses to a rigid,
universal, two-element skeleton. For Sidon sets, *two kernels are optimal,
and three are never needed.*

## Why this reframing matters

At first glance this may look like accounting. But turning an inequality
into an exact identity — "the energy surplus is precisely the number of
non-trivial coincidences" — is what makes results portable. It converts a
vague slogan ("low energy means structured") into a hard census with
explicit constants.

It also reframes an entire optimisation philosophy. A popular strategy in
applications is *multi-kernel smoothing*: combine a family of convolution
kernels with tunable weights and search for the combination that minimises
some energy. Recognising that the exact minimiser has a fixed two-kernel
core means those searches are best understood as small perturbations around
a known rigid center, not open-ended explorations. The optimisation has a
skeleton, and the skeleton has exactly two bones.

## A ladder upward

The two-kernel picture suggests a natural staircase. Ordinary Sidon sets
control *pairwise* sums; but one can demand that all sums of $h$ elements be
distinct — the so-called $B_h$ sets. The forced coincidences there come from
permuting $h$ summands, so the silhouette is bounded not by $2$ but by
$h!$, and the minimal certifying family of kernels is conjectured to jump
from two (the case $h=2$) to $h!$ in general. The rigid skeleton grows, but
it stays rigid.

Another direction quantifies imperfection. If a set misses the Sidon
condition by a handful of stray coincidences, its energy should exceed the
floor by an amount that counts those strays exactly — and, conversely, a
set whose energy is only slightly above the floor should be reparable into
a genuine Sidon set by deleting only a few elements. That is the robust,
real-world version of the theorem: not just "perfect or not," but "how far
from perfect, and how cheaply fixed."

## The moral

The moral is a small marvel of economy. A question about addition —
how spread out can a set of numbers be? — resolves into a single equation
$E[s] = 2|s|^2 - |s|$ that is at once a floor obeyed by everyone and a
signature worn only by the best-behaved sets. And the reason the floor
holds is not some elaborate machine but two humble, universal patterns:
"a plus b equals a plus b," and "a plus b equals b plus a." From a
ruler with no repeated distances to the design of radar arrays, that is
the whole secret, hiding in plain sight.
