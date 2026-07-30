# Six Islands of Reversibility in the Ocean of Elementary Cellular Automata

A row of lamps stretches around a circular track. Each lamp is either off or on. At the tick of a clock, every lamp looks at three bits of information—its left neighbor, itself, and its right neighbor—and all lamps update simultaneously according to the same rule. This is an elementary cellular automaton: one of the simplest mathematical universes in which local decisions create global dynamics.

Simplicity is deceptive. There are only eight possible three-lamp neighborhoods, and a rule chooses an output bit for each one. Thus there are

$$
2^8=256
$$

possible elementary rules. Yet their behavior ranges from extinction to intricate moving structures. A particularly sharp question asks whether time can be run backward. If we see the new row of lamps, can we reconstruct exactly one previous row?

For circular rows of every positive length, the answer is unexpectedly rigid. Among all $256$ elementary rules, exactly six are reversible on every circle:

$$
15,\ 51,\ 85,\ 170,\ 204,\ 240.
$$

They are not six unrelated miracles. Each performs only two basic operations: move the entire configuration one place, or flip every bit. The classification reveals a general lesson about reversible computation: when many local updates occur at once, preserving information globally is far harder than merely making a locally balanced truth table.

## From a lookup table to a universe

Write a circular configuration of length $n$ as

$$
x=(x_0,x_1,\ldots,x_{n-1}),\qquad x_i\in\{0,1\},
$$

with indices interpreted modulo $n$. A local rule is a function

$$
f:\{0,1\}^3\longrightarrow\{0,1\}.
$$

It induces a global update $F_{f,n}$ by

$$
(F_{f,n}(x))_i=f(x_{i-1},x_i,x_{i+1}).
$$

The rule is reversible on the $n$-cycle when $F_{f,n}$ is a bijection of the $2^n$ configurations: no two pasts merge into one future, and every possible future has a past. We call an elementary rule universally finite-cycle reversible when this holds for every integer $n\ge 1$.

Wolfram numbering packages the eight outputs into an integer from $0$ to $255$. For a neighborhood $(l,c,r)$, assign the index

$$
k=4l+2c+r.
$$

The output is the $k$th binary digit of the rule number. This convention lets one enumerate all rules without hiding their mathematical meaning.

A tempting but incorrect shortcut is to describe a local rule as a permutation of the eight neighborhoods. It cannot be: its input set has eight elements, but its output set has only two. Reversibility belongs to the global map on entire configurations. Local outputs overlap, because one cell’s right neighbor is another cell’s center. That overlap is where information may be preserved—or destroyed.

## The six survivors

The six reversible rules have transparent formulas. Let $L$ and $R$ denote cyclic shifts,

$$
(Lx)_i=x_{i-1},\qquad (Rx)_i=x_{i+1},
$$

and let $C$ denote pointwise complement,

$$
(Cx)_i=1-x_i.
$$

Then the six global maps are

$$
\begin{array}{c|c}
\text{Rule} & \text{Global action}\\ \hline
15 & CL\\
51 & C\\
85 & CR\\
170 & R\\
204 & I\\
240 & L
\end{array}
$$

Here $I$ is the identity. Rule $204$ simply copies the center cell. Rules $170$ and $240$ transport bits around the circle in opposite directions. Rule $51$ flips every bit. The remaining two combine a shift with a flip.

Why are they reversible? Left and right shifts undo one another:

$$
LR=RL=I.
$$

Complement is its own inverse:

$$
C^2=I.
$$

Moreover, complement commutes with shifting. Therefore every map in the table has an explicit inverse. The inverses are just as simple: $R^{-1}=L$, $L^{-1}=R$, $C^{-1}=C$, $(CR)^{-1}=CL$, and $(CL)^{-1}=CR$.

This gives the structural half of the classification: the six named rules work on every nonempty circular lattice, regardless of size.

## Four tiny circles expose every impostor

The striking half is not that these six are reversible, but that no others are. One might expect a bad rule to conceal its information loss until a very large ring exhibits a delicate collision. It never needs to. Circles of lengths $1$, $2$, $3$, and $4$ are enough.

The finite witness theorem states:

> **Short-Period Obstruction Theorem.** If an elementary rule is not one of $15,51,85,170,204,240$, then for some $n\in\{1,2,3,4\}$ its global map on the $n$-cycle is not bijective.

The argument is exhaustive but conceptually clean. For each of the $256$ local rules and each $n$ from $1$ through $4$, list all $2^n$ circular configurations, apply the rule, and inspect the outputs. A map from a finite set to itself is bijective exactly when its outputs are all distinct. Passing all four tests leaves precisely the six rules above.

This finite calculation combines with the explicit inverses to produce the full result:

> **Classification Theorem.** An elementary binary cellular automaton is reversible on every nonempty finite cycle if and only if its Wolfram number is one of $15,51,85,170,204,240$.

The logic matters. Testing four sizes alone does not generally prove behavior at all larger sizes. Here it identifies six candidates; a separate symbolic argument proves those candidates reversible for arbitrary $n$. Conversely, any rule claimed to be universal must pass the first four sizes, so it must be on the list.

## Watching information disappear

Consider rule $0$, which sends every neighborhood to $0$. Every initial row becomes the all-zero row in one step. Its many-to-one collapse is obvious. Other failures are subtler. Two distinct patterns may produce the same successor only because neighborhoods overlap around a particular cycle. That collision destroys injectivity. Since the configuration space is finite and has equal-sized domain and codomain, failure of injectivity is equivalent to failure of surjectivity: some future has no past.

The obstruction theorem says every excluded rule exhibits such information loss on a loop no longer than four cells. This is useful computationally. The largest test has only $2^4=16$ configurations, so the whole elementary universe can be screened with tiny tables. It is also useful scientifically: a short periodic pattern can be repeated indefinitely, turning a finite collision into evidence about periodic behavior on an unbounded line.

## What “Galois theory” should mean here

The language of groups naturally enters reversible dynamics, but it must enter at the right level. Bijective global maps of a fixed configuration space form a group under composition: composition preserves bijectivity, the identity is present, and each map has an inverse. The local truth tables themselves do not form permutations of the eight neighborhoods.

On an $n$-cycle, the six elementary reversible maps are generated by the shift $R$ and complement $C$. They satisfy

$$
R^n=I,\qquad C^2=I,\qquad CR=RC.
$$

Thus their composites have the form $R^kC^e$, where $k$ is taken modulo $n$ and $e\in\{0,1\}$. For $n>1$, these operations give a group isomorphic to

$$
\mathbb Z/n\mathbb Z\times\mathbb Z/2\mathbb Z,
$$

while the one-cell circle is degenerate because shifting does nothing. This is the genuine algebraic landscape behind the six rules: spatial translation and bitwise duality.

There is another subtlety. Composing a radius-$r$ automaton with a radius-$s$ automaton may require radius as large as $r+s$. Therefore maps of exactly one fixed radius need not be closed under composition. A robust theory should study all reversible finite-radius, shift-compatible global maps, organized by a radius filtration, rather than force closure where it does not exist.

## Reversible computation and physics

Why care whether a toy universe can run backward? Information loss has thermodynamic meaning. In physical models of computation, erasing a bit carries an energetic cost. Reversible logic avoids merging computational histories, making it relevant to low-energy computing and quantum circuit design. Cellular automata provide a spatially distributed laboratory for these ideas: every site acts locally, but reversibility is a global constraint.

The six-rule theorem shows that radius-one binary rules are too cramped to support rich universally reversible finite-cycle computation. Their only possibilities are transport, complement, identity, and combinations thereof. Complexity may appear in many elementary automata, but universal reversibility at this radius forces austere dynamics.

This does not mean reversible cellular automata are always trivial. Larger neighborhoods, larger alphabets, partitioned updates, and higher dimensions support sophisticated reversible behavior. Instead, the classification marks a boundary. With two states and nearest-neighbor synchronous updating, there is no room for a reversible elementary rule that genuinely mixes neighboring information on every finite ring.

## A small theorem with a broad method

The proof strategy is a reusable pattern. First, define reversibility globally. Second, use exhaustive search only where the state space is genuinely finite. Third, turn surviving cases into formulas. Fourth, prove those formulas invertible at arbitrary size. Finally, extract small counterexamples for every excluded case.

For larger radii, raw configuration enumeration grows quickly. A binary ring of length $n$ has $2^n$ states, while a radius-$r$ local rule has $2^{2r+1}$ input neighborhoods. De Bruijn graphs offer a more scalable language: vertices encode overlapping words, edges encode neighborhoods, and product graphs detect pairs of configurations that evolve identically. The same central question remains—whether distinct histories can merge—but graph structure replaces brute force.

The elementary case ends with an unusually crisp picture. Out of $256$ local laws, $250$ betray themselves on a circle of at most four cells. The six that remain merely shift, flip, or stand still. In a universe built from overlapping local observations, reversibility is not a property of isolated neighborhoods. It is the global art of never forgetting where a bit came from.
