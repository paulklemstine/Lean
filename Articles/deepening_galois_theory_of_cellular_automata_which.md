# Six Islands of Reversibility in the Ocean of Elementary Cellular Automata

A row of lamps stretches around a circular track. Each lamp is either off or on. At the tick of a clock, every lamp looks at three bits of information—its left neighbor, itself, and its right neighbor—and updates simultaneously. This is an **elementary cellular automaton**: a tiny deterministic universe whose law is specified by only eight yes-or-no choices.

There are $2^8=256$ such laws. Some freeze patterns. Some erase nearly everything. Some generate intricate fronts and apparent randomness. But one question cuts through their visual variety: if we see tomorrow’s pattern, can we reconstruct yesterday’s pattern uniquely?

That is the question of **reversibility**. The answer for elementary rules on finite circular tracks is strikingly rigid. Exactly six rules are reversible on every nonempty ring:

$$
15,
\quad 51,
\quad 85,
\quad 170,
\quad 204,
\quad 240.
$$

They are not six unrelated curiosities. Each performs only one of three spatial motions—shift left, stand still, or shift right—and may optionally flip every bit. Moreover, every other elementary rule reveals its irreversibility on a ring of at most four cells. An infinite family of tests collapses to four tiny experiments.

## From eight local cases to a global universe

Write a neighborhood as $(l,c,r)$, where each symbol belongs to $\{0,1\}$. A local rule is a function

$$
f:\{0,1\}^3\longrightarrow\{0,1\}.
$$

The conventional Wolfram number records the eight outputs as bits. The neighborhood $(l,c,r)$ receives the index

$$
4l+2c+r,
$$

and the output of rule $w$ is the bit of $w$ in that position. Thus one integer from $0$ through $255$ specifies the entire update law.

Now place $n>0$ cells on a ring. A configuration is a function

$$
x:\mathbb Z/n\mathbb Z\longrightarrow\{0,1\}.
$$

The global update $F_{w,n}$ applies the local rule everywhere at once:

$$
F_{w,n}(x)_i=f_w(x_{i-1},x_i,x_{i+1}),
$$

with indices interpreted modulo $n$. The rule is reversible on that ring when $F_{w,n}$ is a bijection. Bijectivity contains two demands: no two pasts may merge into one future, and every possible future must have a past.

A common but misleading slogan says that reversibility should mean “the local rule is a permutation.” Here that cannot literally be right: the local rule maps eight neighborhoods to only two symbols. Reversibility is a property of the global map, not a permutation of the neighborhood table.

## The six survivors

The six reversible rules have an exceptionally simple form. Their action on a ring is:

| Rule | New value at site $i$ |
|---:|:---|
| $15$ | $1-x_{i-1}$ |
| $51$ | $1-x_i$ |
| $85$ | $1-x_{i+1}$ |
| $170$ | $x_{i+1}$ |
| $204$ | $x_i$ |
| $240$ | $x_{i-1}$ |

Rules $170$, $204$, and $240$ respectively shift the pattern in one direction, leave it fixed, and shift it in the other direction. Rules $85$, $51$, and $15$ do the same three things and then complement every bit.

Why are these operations reversible? A cyclic shift loses nothing: shifting back restores the starting arrangement. Complementing loses nothing either, because complementing twice returns the original bit. A composition of reversible operations remains reversible.

The inverse can be written down explicitly. If a rule reads the left neighbor and applies a bit permutation $e$, then

$$
F(x)_i=e(x_{i-1}).
$$

To recover $x_i$, look one step to the right in the output and apply $e^{-1}$:

$$
F^{-1}(y)_i=e^{-1}(y_{i+1}).
$$

The corresponding formulas for a center-reading or right-reading rule use no shift or the opposite shift. For a binary alphabet, the only symbol permutations are identity and complement, producing exactly $3\times2=6$ possibilities.

## Four rings are enough

The classification has a surprisingly sharp finite flavor. Consider testing a rule on rings of lengths $1$, $2$, $3$, and $4$. For each $n$, there are only $2^n$ configurations, so one may construct the complete image table of $F_{w,n}$ and ask whether every output occurs exactly once.

The **small-cycle classification theorem** says:

> An elementary rule is bijective on all four rings of lengths $1$, $2$, $3$, and $4$ if and only if its Wolfram number is one of $15$, $51$, $85$, $170$, $204$, and $240$.

The forward direction is a finite exhaustion of all $256$ rules and all configurations on those rings. The reverse direction does not depend on enumeration: each listed rule is a shift or identity, optionally followed by complement, and is therefore bijective on every nonempty ring.

This immediately yields the **short-period obstruction theorem**:

> Every elementary rule outside the six-rule list fails to be injective or fails to be surjective on at least one ring whose length belongs to $\{1,2,3,4\}$.

In practical terms, every false candidate carries a tiny witness. One need not watch a million cells for a million steps. A ring no larger than four cells already exposes information loss or an unreachable state.

Combining the structural argument with the finite obstruction gives the complete result:

> An elementary binary radius-one cellular automaton is reversible on every nonempty finite ring if and only if its local rule reads exactly one of the three neighborhood coordinates and then applies a permutation of the binary alphabet.

Equivalently, universal finite-ring reversibility holds exactly for the six Wolfram rules listed above.

## Why nonlinear-looking rules fail

Most elementary rules genuinely mix their inputs. They may use majority, parity-like behavior, conjunctions, or case distinctions. Mixing is not automatically irreversible in every cellular-automaton setting, but in this tiny binary radius-one universe, universal reversibility is merciless: any rule outside the coordinate-permutation family collides or misses an output on a very short cycle.

A collision means that distinct configurations $x\ne x'$ satisfy

$$
F_{w,n}(x)=F_{w,n}(x').
$$

Once this happens, the future no longer identifies the past. A missing output means that some $y$ has no solution to

$$
F_{w,n}(x)=y.
$$

Because the domain and codomain both contain $2^n$ states, injectivity and surjectivity are equivalent on each fixed finite ring. Computationally, it is enough to insert all outputs into a set and check whether its size remains $2^n$.

This is also why finite rings are such effective microscopes. Periodic patterns on an infinite line correspond to configurations on finite rings. A short ring forces neighboring positions to interact repeatedly, amplifying subtle ambiguities in the local rule.

## The alphabet-independent mechanism

The positive half of the story is not specifically binary. Let $A$ be any alphabet, finite or infinite, and let $e:A\to A$ be a bijection. Consider a radius-one rule that ignores two of its inputs and applies $e$ to the remaining coordinate. For example,

$$
f(l,c,r)=e(l).
$$

On every nonempty ring, its global map is bijective. Its inverse is the opposite cyclic shift followed by $e^{-1}$. The same statement holds when the rule reads the center or right coordinate.

This gives the **single-coordinate reversibility theorem**:

> Over any alphabet $A$, a radius-one rule of the form $e(l)$, $e(c)$, or $e(r)$, where $e$ is a permutation of $A$, induces a bijection on every nonempty finite cyclic configuration space.

The theorem isolates the real engine of the six binary examples: independent reversible motion in space and reversible relabeling in the alphabet.

There is a broader group-like picture. Let $p$ permute the sites of an $n$-cell ring, and let $e$ permute the alphabet. Define

$$
T_{p,e}(x)_i=e(x_{p(i)}).
$$

This is always a permutation of configuration space, with inverse

$$
T_{p,e}^{-1}(y)_i=e^{-1}(y_{p^{-1}(i)}).
$$

Composing two such transformations produces another of the same kind. If $T_{p,e}$ is followed by $T_{q,d}$, then the resulting site motion is the corresponding composition of $p$ and $q$, while the alphabet relabeling is $d\circ e$. Spatial permutations and symbol permutations therefore combine without destroying reversibility.

## A tiny laboratory for information conservation

Reversible cellular automata matter because they are discrete models of information-preserving dynamics. They appear in reversible computing, where erasing information has thermodynamic consequences; in lattice models of physics, where one asks whether microscopic evolution can run backward; and in symbolic dynamics, where local constraints generate global transformations.

The elementary classification offers a clean lesson. Local determinism is cheap: every one of the $256$ rules determines a unique future. Global reversibility is rare: only six preserve enough information to determine a unique past on every finite ring. The difference between “can run forward” and “can run backward” is enormous.

It also demonstrates a productive partnership between structure and exhaustive calculation. Enumeration alone identifies six survivors but does not explain them. Algebra alone proves that shifts and complements work but does not rule out exotic competitors. Together they give both classification and understanding: four finite tests eliminate the pretenders, and explicit inverses reveal the common architecture of the survivors.

Questions remain. Is ring length $4$ genuinely necessary, or do lengths $1$, $2$, and $3$ already isolate the same six rules? What happens with three symbols, where there are vastly more local tables and six alphabet permutations? Is there, for each alphabet size $q$, a universal bound $B(q)$ such that testing rings up to $B(q)$ decides reversibility on all finite rings? And on the infinite line, how broadly can explicit opposite-shift inverses be extended?

For the elementary binary world, however, the picture is complete. Out of $256$ microscopic laws, universal reversibility selects six. Each simply moves a pattern by one step or not at all, and either preserves every bit or flips every bit. Beneath the apparent complexity lies a rigid conservation principle: if no information may be lost, the rule must carry each symbol intact through a reversible change of position and name.