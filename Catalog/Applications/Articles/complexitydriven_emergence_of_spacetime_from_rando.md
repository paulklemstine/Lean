# When Sets Behave Like Spacetime: The Hidden Order in Union-Closed Families

## A puzzle that looks like physics

Imagine a vast collection of configurations — think of them as snapshots of a
universe in which each "site" can be either occupied or empty. A snapshot is just
a finite set: the set of sites that happen to be filled. Now impose a single,
almost trivial rule on your collection of snapshots: if two configurations both
appear, then their *overlay* — the configuration in which a site is filled
whenever it was filled in **either** snapshot — must also appear.

This rule is called **union closure**, and it is one of the most innocent-looking
constraints in all of mathematics. Yet it turns out to encode the same kind of
structure that physicists invoke when they talk about *order parameters*,
*two-point correlation functions*, *coarse-graining*, and the positive
correlations that make a lattice gas behave like a coherent, almost-classical
medium. In this article we follow a chain of small, fully rigorous results that
make that analogy precise. None of them require a supercomputer; all of them can
be checked by hand on a napkin. And together they sketch a surprisingly clean
picture of how *macroscopic regularity emerges from microscopic combinatorics*.

The central object is a **family** $F$ of finite subsets of a ground set
$\alpha$. You can read $\alpha$ as the set of lattice sites, and each $s \in F$
as one allowed configuration. The uniform probability measure on $F$ — pick a
configuration at random, all equally likely — turns this purely combinatorial
gadget into a statistical-mechanical system. The question that drives everything
below is simple: **what must be true about the average behavior of such a
system, no matter how the configurations were chosen?**

## Counting two ways: the conservation law

The first result is a conservation law in disguise. For a site $a$, define its
**member count**

$$\mathrm{memberCount}(a, F) = \#\{\, s \in F : a \in s \,\},$$

the number of configurations in which site $a$ is occupied. Divide by $|F|$ and
you get the **marginal occupancy** of $a$ — the probability that site $a$ is
filled in a random configuration. Now ask a global question: if you add up the
occupancy over *all* sites, what do you get?

The answer is forced, and it is exact:

$$\sum_{a \in \alpha} \mathrm{memberCount}(a, F) \;=\; \sum_{s \in F} |s|.$$

In words: the total occupancy summed over sites equals the total number of filled
cells summed over configurations. This is the discrete analogue of the statement
that *particle number is conserved no matter how you slice the bookkeeping* —
count by columns (sites) or by rows (configurations), you get the same grand
total. The proof is the classic double-counting move: both sides count the pairs
$(a, s)$ with $a \in s$. It is the kind of identity that feels too obvious to
state until you realize it is the backbone of every average you will ever compute
on this system.

## From averages to order: the popular element

Conservation laws are useful precisely because they convert *global* information
into *local* consequences. Here is the payoff. Suppose the configurations are, on
average, at least half full — formally, suppose

$$2 \sum_{s \in F} |s| \;\ge\; |F| \cdot |\alpha|,$$

which says the mean configuration size is at least $|\alpha|/2$. Then there must
exist a single site $a$ that is occupied in at least half of all configurations:

$$2 \cdot \mathrm{memberCount}(a, F) \;\ge\; |F|.$$

This is a **majority-from-average principle**. It says you cannot have a system
that is globally dense without *some specific site* being persistently, reliably
occupied. In the language of phase transitions, a nonzero average density forces a
nonzero **order parameter**: at least one degree of freedom acquires a definite,
above-chance expectation value. The proof is a contrapositive pigeonhole — if
*every* site were occupied less than half the time, then summing those strict
inequalities (using the conservation law above) would make the total occupancy too
small to meet the hypothesis. Density cannot hide; it must condense onto a witness.

This is exactly the flavor of argument that underlies spontaneous symmetry
breaking. The microscopic rule treats all sites symmetrically, yet the macroscopic
constraint (high density) guarantees that symmetry is broken *somewhere*: a
distinguished site emerges with a robust expectation value.

## The closure dynamics

Now we let the system evolve. The natural dynamics on configuration space is
**coarse-graining by overlay**: given the family $F$, form its **union closure**
$\langle F \rangle$, defined as the collection of every configuration you can
build by overlaying a nonempty subcollection of $F$:

$$\langle F \rangle = \big\{\, \textstyle\bigcup_{s \in G} s \;:\; \emptyset \ne G \subseteq F \,\big\}.$$

Two facts make this a genuine closure operator. First, it is **extensive**: every
original configuration survives, $F \subseteq \langle F \rangle$ (overlay a set
with itself and nothing changes). Second, it is **idempotent in spirit** — the
result is genuinely union-closed: overlaying any two members of $\langle F\rangle$
lands you back inside $\langle F \rangle$, because the overlay of two overlays is
itself an overlay of the combined subcollection. The closure is therefore the
smallest union-closed family containing $F$: the unique stationary state of the
coarse-graining dynamics.

And here the analogy with thermodynamics becomes sharp. Total occupancy can only
*increase* under closure:

$$\sum_{s \in F} |s| \;\le\; \sum_{s \in \langle F \rangle} |s|.$$

Coarse-graining never destroys filled cells; overlays are at least as large as
their constituents, and new configurations are only added, never removed. This is
a discrete, exact analogue of the **second law**: the relevant extensive quantity
is monotone along the closure flow. The arrow of the dynamics points toward
greater occupancy, just as the arrow of thermodynamic time points toward greater
entropy.

## Order builds itself: every upset is union-closed

There is a beautiful structural reason union closure is so natural. Recall that an
**upper set** (or *upset*) is a family closed under *growth*: if a configuration
$s$ is allowed and $t \supseteq s$ is any larger configuration, then $t$ is
allowed too. Upsets are the order filters of the Boolean lattice of all subsets —
they are the monotone properties, the "if it is filled enough, it stays in the
family" families.

The bridge result says: **every upset is automatically union-closed.** If $s$ and
$t$ are both in an upset $F$, then $s \cup t$ contains $s$, and growth-closure
immediately puts $s \cup t$ into $F$. So monotonicity (an order-theoretic notion)
silently implies overlay-closure (an algebraic notion). Whole swaths of physically
natural systems — every monotone constraint, every "more is allowed" rule — are
union-closed for free. The union-closed world is not a narrow special case; it is
where monotone physics lives.

## Two points, one principle: inclusion–exclusion and positive correlation

To talk about *correlations* we need two sites at once. Define the **joint count**

$$\mathrm{jointCount}(a, b, F) = \#\{\, s \in F : a \in s \text{ and } b \in s \,\},$$

the number of configurations in which $a$ and $b$ are simultaneously occupied —
the unnormalized **two-point correlation function**. Its companion is the
**union count**, the number of configurations occupying at least one of the two
sites. These three quantities obey the exact bookkeeping identity

$$\mathrm{unionCount}(a, b, F) = \mathrm{memberCount}(a, F) + \mathrm{memberCount}(b, F) - \mathrm{jointCount}(a, b, F).$$

This is inclusion–exclusion, the finite-probability identity
$P(A \cup B) = P(A) + P(B) - P(A \cap B)$ written in raw counts. It is the
fundamental relation tying single-site and two-site statistics together, and it
holds no matter what the family looks like.

The deepest result of the collection concerns the *sign* of correlations. Take the
**full powerset** — every possible configuration is allowed, all $2^{|\alpha|}$ of
them, each equally likely. This is the maximally disordered, infinite-temperature
system. For any two sites $a$ and $b$, the counts satisfy

$$2^{|\alpha|} \cdot \mathrm{jointCount}(a, b) \;\ge\; \mathrm{memberCount}(a) \cdot \mathrm{memberCount}(b).$$

Dividing through by $|F|^2 = 2^{2|\alpha|}$, this is exactly the statement that the
**two-point function dominates the product of one-point functions**:

$$P(a \text{ and } b) \;\ge\; P(a)\,P(b),$$

i.e. the covariance of the two site-occupancy indicators is non-negative. This is
the **base case of the celebrated FKG inequality** — the principle, ubiquitous in
statistical mechanics, that monotone observables in a monotone system are
positively correlated. On the full powerset the two distinct sites are in fact
*independent* (the inequality is an equality, $2^{n}\cdot 2^{n-2} = 2^{n-1}\cdot
2^{n-1}$): there is exactly $2^{|\alpha|-1}$ configurations through each single
site and $2^{|\alpha|-2}$ through any pair. But when $a = b$ the inequality becomes
strict — a site is perfectly correlated with itself — and that strictness is the
seed from which genuine positive correlation grows once you restrict to a smaller,
more structured family.

## Why this is a story about emergence

Step back and look at the shape of the argument. We started with featureless
combinatorial data — an arbitrary list of finite sets. We imposed one monotone
rule and discovered:

- a **conservation law** (total occupancy is slice-independent);
- an **order parameter** (density forces a popular site);
- a **second law** (closure is monotone in occupancy);
- a **structural origin** (monotone families are union-closed automatically);
- a **correlation principle** (two-point dominates one-point — FKG positivity).

These are the very ingredients physicists reach for when they argue that a smooth,
classical, large-scale world *emerges* from a chaotic microscopic substrate. The
modern dream of quantum gravity — that spacetime geometry and its curvature
condense out of the entanglement and complexity of an underlying quantum network —
has exactly this logical structure: a monotone resource (entanglement entropy,
configuration density) that obeys conservation and inequality constraints, an
order parameter that switches on past a threshold, and positive correlations that
glue local data into a coherent whole. The union-closed family is a stripped-down
laboratory where every one of those moves can be made airtight.

The lesson is not that finite sets *are* spacetime. It is that the **logical
skeleton of emergence is combinatorial**. Monotonicity plus closure plus
double-counting already gives you conservation, an arrow of time, and positive
correlation — the scaffolding on which any theory of emergent geometry must hang.
When a discrete model of the universe finally earns the name *spacetime*, the first
things it will have to satisfy are humble identities like the ones above. The math
of "more is allowed, and overlap only helps" is older and deeper than any
particular physics — and, reassuringly, it is exactly true.
