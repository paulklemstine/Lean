# The Shape of a Solution: What Equality Patterns Reveal About Diophantine Equations

## A question you can ask about any equation

Everyone meets the equation $x^2 + y^2 = z^2$ as a child, dressed as a right triangle. Everyone meets its most famous solution, $3^2 + 4^2 = 5^2$, and most people meet a second one, $5^2 + 12^2 = 13^2$. Very few people ever ask the question that this article is about, which is embarrassingly simple once you hear it:

**Which coincidences among $x$, $y$, and $z$ are possible?**

Not *which numbers* solve the equation — that question is completely answered by the classical parametrisation of Pythagorean triples. Rather: among the solutions, which patterns of *sameness* occur? A triple $(x, y, z)$ of non-negative integers falls into exactly one of five possible "shapes", according to which of its entries agree:

- all three entries different, e.g. $(3,4,5)$;
- the two legs agree, $x = y \ne z$;
- the first leg agrees with the hypotenuse, $x = z \ne y$;
- the second leg agrees with the hypotenuse, $y = z \ne x$;
- all three agree, $x = y = z$.

Five shapes, because five is the number of ways to partition a three-element set — the third *Bell number*. Now go looking for each shape on the Pythagorean cone.

All three different? $(3,4,5)$. All three equal? $(0,0,0)$, the degenerate solution, which is a solution nonetheless. First leg equal to the hypotenuse? Take $(7, 0, 7)$: indeed $49 + 0 = 49$. Second leg equal to the hypotenuse? $(0, 7, 7)$. That is four of the five shapes, each realised by an explicit triple.

The fifth shape — the two legs equal, hypotenuse different — is the isosceles right triangle, and it is *impossible*. If $x = y$ then $2x^2 = z^2$, and unless $x = 0$ this makes $\sqrt{2}$ rational. The obstruction is exactly the oldest theorem in irrationality: **$2$ is not a perfect square**.

So the Pythagorean cone realises $4$ of the $5$ available shapes. Call the number of missing shapes the **defect**. The Pythagorean defect is $1$, and the single missing shape is a two-and-a-half-thousand-year-old theorem in disguise.

## From a curiosity to an invariant

Once you have counted the shapes for one equation, you can count them for any equation. For a homogeneous equation $F(x_1, \dots, x_n) = 0$, define its **kernel spectrum** to be the set of equality patterns realised by its non-negative integer solutions, and its **defect** to be
$$\mathrm{defect}(F) \;=\; B_n - \#\mathrm{Spec}(F),$$
where $B_n$ is the $n$-th Bell number, the total number of patterns available. The defect is a small non-negative integer attached to any Diophantine equation, and it is a purely *qualitative* measurement: it does not care how many solutions there are, only which coincidences among the coordinates can be arranged.

Two things make this worth doing. First, the defect is *computable in examples* — every missing pattern corresponds to a concrete, usually classical, arithmetic obstruction. Second, and much less obvious, the defect is *sensitive*: it changes when you deform the equation, and it changes when you change the number of variables. It is not one of those invariants that turns out to be constant for silly reasons.

Both of those claims are theorems, and the rest of this article explains them.

## The engine: one small descent lemma

Almost everything about ternary conics reduces to a single arithmetic statement, and it is worth seeing it in full because it has a surprise inside.

> **Two-parameter descent.** Let $P$ and $Q$ be non-negative integers with $Q \ne 0$. The equation $P u^2 = Q v^2$ has a solution in non-negative integers with $u \ne 0$ **and** $u \ne v$ if and only if $PQ$ is a perfect square **and** $P \ne Q$.

The "only if" half is a two-line descent: from $Pu^2 = Qv^2$ one computes $PQ \cdot u^2 = (Qv)^2$, so $PQ$ is a square times a square, hence a square. The "if" half is a construction: writing $PQ = m^2$, the pair $(u,v) = (Q, m)$ works, because $P Q^2 = (PQ) Q = m^2 Q = Q m^2$.

The surprise is the clause $P \ne Q$. It is not a technicality; it is a *second, independent obstruction*, and it is invisible in the Pythagorean case. If $P = Q$ then $u^2 = v^2$ forces $u = v$, so the required inequality $u \ne v$ can never hold no matter how beautifully square $PQ$ is. Call this the **degeneracy obstruction**. In geometric language it says: the diagonal point $(1,1,\dots,1)$ lies on the curve, and every candidate solution collapses onto it.

## A complete dictionary for ternary conics

Arm yourself with that lemma and the general conic
$$A x^2 + B y^2 = C z^2$$
gives up all of its secrets. Two of the five patterns are easy: the all-equal pattern is always realised, by the origin, so the defect of a conic can never exceed $4$; and the all-distinct pattern has no clean criterion but is easy to test in examples. The three *mixed* patterns are exactly the interesting ones, and each has a closed-form criterion.

> **Equal legs.** The pattern $x = y \ne z$ occurs on $Ax^2 + By^2 = Cz^2$ (with $C \ne 0$) if and only if $(A+B)\,C$ is a perfect square and $A + B \ne C$.
>
> **First leg meets the hypotenuse.** The pattern $x = z \ne y$ occurs (with $B \ne 0$) if and only if $A \le C$, the product $(C-A)\,B$ is a perfect square, and $A + B \ne C$.
>
> **Second leg meets the hypotenuse.** The pattern $y = z \ne x$ occurs (with $A \ne 0$) if and only if $B \le C$, the product $(C-B)\,A$ is a perfect square, and $A + B \ne C$.

Look at what the three criteria have in common. Each carries its own square condition — a different square condition in each case — but all three carry the *same* degeneracy clause $A + B \ne C$. That is not a coincidence of bookkeeping; it is a structural fact with an immediate and rather startling consequence.

> **Diagonal degeneracy.** If $A + B = C$ — equivalently, if the point $(1,1,1)$ lies on the conic — then all three mixed patterns are blocked simultaneously. The spectrum shrinks to at most the two extremes, "all equal" and "all different", and the defect is at least $3$.

One linear condition on the coefficients switches off three arithmetic phenomena at once. The classic instance is $x^2 + y^2 = 2z^2$: an equation absolutely swarming with solutions — $1^2 + 7^2 = 2 \cdot 5^2$, $7^2 + 17^2 = 2 \cdot 13^2$, and infinitely many more — yet not one of them exhibits any partial coincidence among its coordinates. Every solution is either totally degenerate or totally generic. The equation is arithmetically rich and qualitatively barren.

## The defect takes every possible value

Now deform. Fix the legs and slide the coefficient of the hypotenuse, giving the one-parameter family
$$x^2 + y^2 = C z^2, \qquad C = 1, 2, 3, \dots$$
The Pythagorean cone is the member $C = 1$, with defect $1$. What happens to the other members?

The answer is as clean as one could hope: **the defect takes every value it is allowed to take.**

- $C = 50$: **defect $0$**. Every one of the five patterns occurs. $17^2 + 31^2 = 50 \cdot 5^2$ is generic; $5^2 + 5^2 = 50 \cdot 1^2$ has equal legs (and indeed $(1+1)\cdot 50 = 100$ is a square); $1^2 + 7^2 = 50 \cdot 1^2$ has the first leg equal to the hypotenuse (and $(50-1)\cdot 1 = 49$ is a square). Nothing is missing.
- $C = 1$: **defect $1$**. The Pythagorean cone, missing only the isosceles pattern, because $(1+1) \cdot 1 = 2$ is not a square.
- $C = 8$: **defect $2$**. Equal legs survive, since $(1+1)\cdot 8 = 16 = 4^2$: witness $2^2 + 2^2 = 8 \cdot 1^2$. But both leg-hypotenuse patterns die, because $(8-1)\cdot 1 = 7$ is not a square.
- $C = 2$: **defect $3$**. Diagonal degeneracy. All three mixed patterns die at once, though generic solutions like $1^2 + 7^2 = 2\cdot 5^2$ abound.
- $C = 3$: **defect $4$**, the maximum possible. Here the equation $x^2 + y^2 = 3z^2$ has *no* non-trivial solutions whatsoever. Only the origin survives, so only the all-equal pattern is realised.

The last case is the deepest, and it is proved by classical infinite descent at the prime $3$. Squares are congruent to $0$ or $1$ modulo $3$, so $x^2 + y^2 \equiv 0 \pmod 3$ forces both $x$ and $y$ to be divisible by $3$; substituting $x = 3a$, $y = 3b$ turns the equation into $3(a^2+b^2) = z^2$, which forces $3 \mid z$ as well; writing $z = 3c$ returns the original equation with strictly smaller numbers. Repeating forever is impossible among non-negative integers, so the only solution is $(0,0,0)$. It is Fermat's descent, in miniature, and it is exactly what pushes the defect up to its ceiling.

So along a single, utterly explicit pencil of conics, the defect runs through $0, 1, 2, 3, 4$ and stops there. It is not constant, it is not monotone in $C$, and the Pythagorean value $1$ is neither the minimum nor the maximum. Whatever else it may be, this invariant is not trivial.

## Adding dimensions

What happens with more legs? Consider $x^2 + y^2 + z^2 = w^2$, whose solutions include $2^2 + 3^2 + 6^2 = 7^2$. A quadruple has $15$ possible equality patterns (the fourth Bell number). Exactly **eight** are realised, so the defect leaps from $1$ to $7$.

The reason is a rigidity phenomenon that holds in every dimension and that is, in hindsight, obvious — which is the best kind of theorem:

> **Hypotenuse–leg rigidity.** If $x_1^2 + \cdots + x_k^2 = y^2$ and the hypotenuse $y$ equals one of the legs $x_j$, then *every other leg is zero*.

The proof is one line: subtract $x_j^2 = y^2$ from the sum and the remaining squares add to zero. But the pattern-level consequence is strong. Once the hypotenuse merges with any leg, all the other legs are forced into a single block (they are all $0$), so no realised pattern can simultaneously merge the hypotenuse with a leg and keep two other legs apart. In dimension three that single observation kills six of the seven missing patterns.

The seventh missing pattern is "all three legs equal, hypotenuse different", and its obstruction is the familiar one: it would require $3x^2 = w^2$, and $3$ is not a perfect square. The general statement is a small gem:

> **Constant legs in every dimension.** The equation $x_1^2 + \cdots + x_k^2 = y^2$ has a solution with all legs equal to the same nonzero value and the hypotenuse different from it **if and only if $k$ is a perfect square and $k \ne 1$**.

So the pattern is blocked for $k = 2$ (since $2$ is not a square — this is the Pythagorean case) and for $k = 3$ (since $3$ is not a square), but it is *realised* for $k = 4$: $1^2+1^2+1^2+1^2 = 2^2$. The obstruction is not a fact about Pythagoras; it is a fact about the number of legs, and it disappears the moment the leg count becomes a square. Rigidity, meanwhile, gives a universal count: for $k \ge 2$ there are exactly $k+1$ realised patterns in which the hypotenuse shares a block with a leg — the all-zero pattern plus one "one-hot" pattern for each leg.

There is also a pleasing symmetry accounting. Permuting the legs acts on patterns, and the spectrum of a leg-symmetric equation must be a union of orbits. In dimension three the seven missing patterns split into orbits of sizes $1 + 3 + 3$: the single symmetric "all legs equal" pattern, matched to the symmetric obstruction "$3$ is not a square", and two orbits of size three, matched to the rigidity obstruction, which singles out a leg and therefore cannot be symmetric. The orbit decomposition sees the two obstructions and separates them.

## Higher exponents, and a theorem that leaves a mark

Replace squares by $p$-th powers, and the same machinery runs, with "perfect square" replaced by "perfect $p$-th power". The key descent generalises: if $k a^p = c^p$ with $a \ne 0$, then $k$ is a $p$-th power (divide out the greatest common divisor of $a$ and $c$; coprimality forces the reduced leg to be $1$). Consequently, the equal-legs pattern occurs on $A x^p + B y^p = C z^p$ exactly when $(A+B)C^{p-1}$ is a $p$-th power and $A + B \ne C$.

Three instances at the cubic exponent $p = 3$ tell the whole story, and they show that the two obstructions are genuinely independent:

- $x^3 + y^3 = z^3$: equal legs blocked, because $2$ is not a cube. (Nothing as deep as Fermat's Last Theorem is needed for this.)
- $x^3 + y^3 = 2z^3$: equal legs blocked — but *not* by the power condition, which is satisfied since $2 \cdot 2^2 = 8 = 2^3$. Here the degeneracy clause bites: $1 + 1 = 2$, so $(1,1,1)$ is on the curve.
- $x^3 + y^3 = 16z^3$: equal legs **realised**, by $2^3 + 2^3 = 16 \cdot 1^3$. The power condition holds, $2 \cdot 16^2 = 8^3$, and $2 \ne 16$.

So the failure of the isosceles pattern for the Fermat equation is a fact about the *coefficient*, not about the exponent. Change the coefficient to $16$ and it comes back.

Finally, the defect of the Fermat family itself. For the equation $x^p + y^p = z^p$ with $p \ge 3$, three patterns occur: the origin, and the two "one leg is zero" patterns $(a, 0, a)$ and $(0, a, a)$. The equal-legs pattern is blocked by the power obstruction. And the all-distinct pattern would require a solution in three pairwise distinct positive integers — precisely a counterexample to Fermat's Last Theorem. Since none exists, the defect of $x^p+y^p=z^p$ is $2$ for every $p \ge 3$, while for $p = 2$ it is $1$. The defect is not constant along the exponent family either, and the jump at $p = 3$ is Fermat's Last Theorem itself, wearing a very light disguise.

## Why bother?

The kernel spectrum is a way of asking, for a given equation, *what qualitative configurations of coincidence its solutions can display*. It is coarse enough to be a finite computation — there are only $B_n$ patterns to check — and fine enough that each answer encodes a real theorem: the irrationality of $\sqrt{2}$, descent at the prime $3$, coprimality arguments for $p$-th powers, and Fermat's Last Theorem all appear as single bits in a table.

And the invariant behaves like a real invariant. It is not order-theoretic: the Pythagorean spectrum contains the finest pattern (all coordinates distinct) and the coarsest (all equal) but misses one in between, so it is neither an up-set nor a down-set in the lattice of partitions — the defect lives strictly in the interior. It is not constant on families: it sweeps all of $\{0,1,2,3,4\}$ across the conic pencil. It is not dimension-blind: it jumps from $1$ to $7$ when a leg is added. And it is not exponent-blind: it jumps from $1$ to $2$ at the cubic Fermat equation, for the deepest reason available.

There is something appealing about a question that a child can ask of the equation on the first page of every geometry book — *can the two legs be equal?* — and that, asked systematically, turns into a finite invariant fine enough to detect Fermat's Last Theorem.
