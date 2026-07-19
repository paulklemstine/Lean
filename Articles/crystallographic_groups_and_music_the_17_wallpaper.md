# The Geometry of Repetition: How Symmetry Sets the Information Budget of Rhythm

A drum loop can feel spacious or crowded, predictable or unstable, even when it occupies the same number of beats as another loop. One reason is symmetry. Repetition does not merely copy sound; it ties musical positions together. If a transformation says that two cells of a rhythmic grid play the same role, then choosing one cell also chooses the other. Every such identification removes an independent decision.

This observation leads to a clean mathematical law: **the information capacity of a symmetric binary rhythm is exactly the number of symmetry classes in its grid**. If a grid collapses into $m$ classes under its chosen symmetries, then it supports exactly $2^m$ compatible onset patterns and therefore carries $m$ bits of uniform binary capacity.

The law is simple, but it creates a useful bridge between geometry, music, and information theory. It also clarifies what the celebrated seventeen wallpaper groups can—and cannot—tell us about rhythm.

## From loops to lattices

The simplest rhythm is a periodic binary sequence. At each integer time $n$, a function $f(n)$ records either an onset, $1$, or silence, $0$. Period $p$ means

$$
f(n+p)=f(n)
$$

for every $n$. The infinite sequence is therefore determined by $p$ cells arranged on a cycle.

Many musical patterns need more than one coordinate. A drum sequencer has time along one axis and instrumental voice along another. A piano-roll display has time and pitch. A polyrhythmic score may place phase on one axis and pulse subdivision on the other. In each case, a finite window can be repeated to tile a two-dimensional grid.

Planar periodic patterns invite the transformations studied by crystallography: translations, rotations, reflections, and glide reflections. The classical wallpaper-group theorem says that there are exactly seventeen types of discrete symmetry groups for periodic patterns in the Euclidean plane, up to geometric equivalence. This supplies a rich vocabulary for musical design: mirrors suggest palindromic organization, glides suggest shifted imitation, and rotations suggest cyclic exchange among voices or phrases.

But the number seventeen does not by itself prove that music has exactly seventeen kinds of rhythm. A wallpaper group describes the ambient symmetry of an infinite planar pattern. A finite sampled drum grid may admit only some transformations; one particular pattern may have more symmetry than the grid construction requires; and musical labels such as “canon” or “round” involve temporal and perceptual structure not captured by geometry alone. The rigorous insight available here is both more general and more precise: once any set of cell identifications is specified, its effect on the number of possible patterns is completely determined.

## Symmetry as an equivalence relation

Take a finite set $X$ of musical cells. These might be beat positions, time–pitch coordinates, or instrument–phase pairs. Suppose a relation $	hicksim$ tells us which cells symmetry identifies. It must satisfy three familiar rules:

1. Every cell is equivalent to itself.
2. If $x\thicksim y$, then $y\thicksim x$.
3. If $x\thicksim y$ and $y\thicksim z$, then $x\thicksim z$.

The resulting equivalence classes are the **symmetry classes** or **orbits** of the grid. The quotient set $X/{\thicksim}$ is the set of all such classes.

A binary pattern is a function

$$
f:X\longrightarrow\{0,1\}.
$$

It respects the symmetry when equivalent cells receive the same value:

$$
x\thicksim y \quad\Longrightarrow\quad f(x)=f(y).
$$

Call such a pattern invariant. If a reflection pairs the left and right halves of a grid, for example, an invariant pattern must make matching cells both active or both silent.

Here is the central structural result.

**Quotient Representation Theorem.** For any set $X$ equipped with an equivalence relation $	hicksim$, invariant binary patterns on $X$ correspond one-to-one with arbitrary binary labelings of the quotient $X/{\thicksim}$.

The reason is direct. Given a labeling of the quotient, assign each cell the label of its class. This produces an invariant pattern. Conversely, an invariant pattern has a well-defined value on each class because all representatives agree. The two constructions undo one another. In particular, a pattern is uniquely determined by its values on the quotient.

This theorem shifts attention from the original grid to its independent symmetry classes. A thousand-cell grid whose symmetry produces twelve classes has only twelve binary decisions.

## The symmetry–entropy law

When $X$ is finite and its quotient has $m$ classes, each class can independently be labeled $0$ or $1$. Hence:

**Symmetry–Entropy Counting Theorem.** If a finite binary grid has $m$ symmetry classes, then the number of symmetry-respecting patterns is

$$
2^m.
$$

Equivalently, the base-two logarithm of the pattern count is

$$
\log_2(2^m)=m.
$$

Thus the uniform binary information capacity is exactly $m$ bits.

Consider a sixteen-step rhythm with no imposed identifications. Every cell forms its own class, so $m=16$ and there are $2^{16}=65{,}536$ patterns. Now impose mirror symmetry pairing the first step with the sixteenth, the second with the fifteenth, and so on. There are eight classes, so only $2^8=256$ symmetric patterns remain. The reflection has not merely made the rhythm “more regular”; it has reduced its binary design space by a factor of $256$.

Or take a $4\times4$ time–voice grid and require all cells in each row to agree. The four rows are the four classes, giving $2^4=16$ patterns. Require every cell to agree with every other cell, and only one class remains.

That extreme case gives another exact result.

**Maximal-Symmetry Corollary.** On any nonempty finite binary grid, if every cell is identified with every other cell, exactly two invariant patterns exist: complete silence and an onset in every cell.

This is the floor of binary variety on a nonempty grid. Maximal identification leaves one decision, so the capacity is one bit.

## More identification, less freedom

Symmetry can be compared without naming a particular geometric group. Suppose one system has quotient classes that can be injected into those of another. Then the first quotient has no more classes than the second. Exponentiating by two preserves that order.

**Monotonicity Theorem.** For two symmetry systems on the same finite cell set, if the quotient of the first injects into the quotient of the second, then the first admits no more invariant binary patterns than the second.

In symbols, if the quotient sizes are $m_t$ and $m_s$ and there is an injection from the first quotient to the second, then $m_t\le m_s$ and

$$
2^{m_t}\le 2^{m_s}.
$$

This formalizes a composer’s intuition: tying more positions together cannot create new independent binary choices. It can only preserve or reduce the palette.

The statement is deliberately phrased through quotients rather than through a vague slogan such as “more symmetry.” Different symmetry groups are not always linearly ordered, and two geometrically distinct actions may happen to produce the same number of cell orbits. The quotient makes the comparison exact.

## A compositional control knob

The orbit count $m$ acts like a complexity dial. A composer can begin with a time–pitch grid and select transformations: perhaps translation by a phrase, reflection around a central beat, or a glide combining reflection with a shift. The transformations generate equivalence classes. One then chooses one onset value per class and expands those choices across the grid.

This procedure separates two creative decisions:

- **geometry:** which cells must move together;
- **content:** which symmetry classes contain onsets.

The separation is valuable in generative music. To sample uniformly from all invariant patterns, one does not need to reject nonsymmetric full-grid samples. Compute the classes, draw one random bit for each class, and copy it to every member. The running time after the classes are known is proportional to the number of cells, while the random information required is exactly $m$ bits.

It is equally useful for compression. Store the quotient labels plus the rule that reconstructs the full grid. The raw representation uses one bit per cell; the idealized invariant representation uses one bit per class. If a grid has $N$ cells and $m$ classes, the onset data shrink from $N$ bits to $m$ bits, apart from the cost of describing the symmetry itself.

For analysis, the theorem provides a null model. A highly symmetric family has fewer admissible patterns before any corpus is observed. Frequency comparisons among symmetry types should account for this unequal capacity: a class with $2^{20}$ available patterns and one with $2^5$ should not be compared as though their combinatorial baselines were identical.

## Seventeen geometric languages, not yet seventeen musical species

The wallpaper groups remain an inspiring vocabulary of transformations. They suggest structured rhythmic operations: half-turns for exchange, mirrors for reversal, glides for shifted reflection, and three-, four-, or sixfold rotations for cyclic organization. Yet a credible empirical claim requires more than analogy.

A test on a thousand drum patterns would need a reproducible encoding: How are expressive timing and velocity quantized? What counts as pitch or instrumental voice? Is approximate symmetry allowed? Which transformations descend to the finite toroidal grid created by looping? Is classification based on the full symmetry group of each pattern or on a chosen generating template? What statistical null model controls for orbit count and grid size?

Until these choices and a corpus are supplied, no distribution across seventeen classes has been established. Nor does planar classification alone justify calling one group a canon, another a blues form, or a maximally symmetric pattern “perfect.” Those are perceptual and musicological hypotheses.

What mathematics does establish is a durable core beneath such a research program. Symmetry partitions a musical grid into orbits. Invariant rhythms are exactly Boolean labelings of those orbits. The number of available rhythms is therefore $2^m$, their uniform capacity is $m$ bits, stronger identification cannot increase their count, and total identification leaves exactly silence and saturation.

That law is not confined to wallpaper patterns or music. It applies whenever binary data must remain constant on equivalence classes: symmetric images, repeated motifs, coded signals, tiled interfaces, and constrained experimental designs. Geometry determines which decisions are shared; information theory counts what freedom remains. Rhythm makes the connection audible.