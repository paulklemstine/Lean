# When Logic Clicks: Jigsaw Puzzles, Satisfying Assignments, and the Symmetry of Tabs and Blanks

A jigsaw piece looks innocent in isolation. It has four sides, some flat, some carrying tabs, and some cut into blanks. Yet a box of such pieces presents a global question: can thousands of local pairings be made simultaneously, without contradiction? That tension between local fit and global consistency is the same tension that animates one of computer science’s central problems—Boolean satisfiability.

The connection is more than a metaphor. In an abstract family of logic puzzles, truth assignments and valid assembly recipes correspond one for one. The correspondence preserves not only whether a solution exists, but the exact number of solutions and whether the solution is unique. It also exposes an elegant symmetry: reverse every truth value, reverse every literal in the logical formula, and swap every tab with a blank. Solvability does not change.

These conclusions do **not** by themselves prove that ordinary commercial jigsaws, with free placement and realistic geometry, are NP-complete. That broader geometric claim requires additional gadgets and a careful account of positions, rotations, crossings, and boundaries. What the mathematics does establish is the exact logical core that such a reduction would need to preserve.

## A Boolean formula as a box of pieces

A Boolean variable $x_i$ can take one of two values, true or false. A **literal** is either $x_i$ or its negation $\neg x_i$. A **clause** is a list of literals interpreted as an OR: it is satisfied when at least one listed literal is true. A **formula** is a list of clauses interpreted as an AND: it is satisfied only when every clause is satisfied.

For example, consider

$$
F=(x_0\lor x_1\lor \neg x_2)\land(\neg x_0\lor x_2).
$$

The assignment

$$
(x_0,x_1,x_2)=(\mathrm{false},\mathrm{true},\mathrm{false})
$$

satisfies $F$. The first clause is true because $x_1$ is true, while the second is true because $\neg x_0$ is true.

Now imagine encoding the choice for each variable with assignment pieces. A tab can represent one Boolean state and a blank its complement. Clause pieces have interfaces corresponding to their literals. The essential fitting rule is simple: the clause piece fits under an assignment exactly when at least one of its literal interfaces is activated by a true literal. Thus the local physical statement “this clause component can connect” is equivalent to the logical statement “this clause is satisfied.”

A puzzle assembly recipe is then an assignment of truth values to the declared variables for which every clause piece fits. Because the same assignment is retained throughout the translation, no witness is forgotten and no extra witness is invented.

## The central one-to-one correspondence

The key result can be stated without any machinery.

**Assembly–Assignment Correspondence.** Fix $n$ declared variables and a Boolean formula $F$. Assign false to every variable outside the declared set. Then the set of valid assembly recipes for the puzzle associated with $F$ is in canonical bijection with the set of satisfying assignments of $F$ on those $n$ variables.

The proof follows the clause interfaces. Begin with a valid assembly recipe. Every clause piece fits, so for each clause at least one corresponding literal is true. Hence every clause is satisfied, and the retained assignment satisfies $F$. Conversely, begin with a satisfying assignment. Every clause contains a true literal, so the corresponding clause piece has an activated fitting interface. Hence all clause pieces fit, producing an assembly recipe. Both transformations leave the assignment unchanged, so applying one after the other returns exactly the starting object.

This “leaves the witness unchanged” feature is stronger than the usual statement that one problem has a solution exactly when the other does. It is called a **parsimonious correspondence**: the translation preserves solutions individually.

Three consequences arrive immediately.

First, the puzzle is solvable if and only if the formula is satisfiable. Second, the exact counts agree:

$$
\#\{\text{assembly recipes for }F\}
=
\#\{\text{satisfying assignments of }F\}.
$$

Third, uniqueness is preserved: the constructed puzzle has exactly one assembly recipe if and only if the formula has exactly one satisfying assignment.

Counting matters because existence can hide rich structure. Two puzzles may both be solvable while one has a single forced route and the other has a vast family of alternatives. The bijection distinguishes those situations perfectly. It transports the entire finite solution space rather than a single yes-or-no answer.

## A ten-piece experiment

For the running formula, there are $n=3$ variables and $m=2$ clauses. The abstract construction uses

$$
N=2n+m+2=2\cdot3+2+2=10
$$

pieces: two assignment pieces per variable, one piece per clause, and two boundary pieces. The assignment $(\mathrm{false},\mathrm{true},\mathrm{false})$ activates $x_1$ in the first clause and $\neg x_0$ in the second, so it supplies an explicit assembly recipe.

The formula actually has more than one satisfying assignment. A short exhaustive check over the $2^3=8$ possible assignments finds five solutions. By the exact counting theorem, the associated abstract puzzle therefore has five assembly recipes as well. This is a miniature laboratory for the general theorem: a truth table on one side becomes a catalogue of assemblies on the other, with no discrepancy in cardinality.

The construction scales cleanly at the abstract level. For a formula with $n$ variables and $m$ clauses, the stated piece inventory grows linearly as $2n+m+2$. Evaluating one candidate assignment requires checking the literals in every clause, so the work is proportional to the formula’s total number of literal occurrences. Exhaustive counting still takes exponential time in $n$, because there are $2^n$ possible assignments; the correspondence explains exactly where that combinatorial explosion appears in the assembly space.

## Turning the whole world inside out

The second central idea is symmetry. Complement an assignment by changing every true value to false and every false value to true. At the same time, complement the formula by reversing every literal polarity: replace $x_i$ by $\neg x_i$ and $\neg x_i$ by $x_i$.

A literal keeps its truth under this simultaneous reversal. If $x_i$ was true before, then after reversal the variable is false but the literal has become $\neg x_i$, which is again true. If $\neg x_i$ was true before, then the variable becomes true and the literal becomes $x_i$. Consequently, clause truth is preserved, and therefore formula truth is preserved.

**Complementation Theorem.** For every assignment $a$ and formula $F$, the complemented assignment $\bar a$ satisfies the complemented formula $\bar F$ if and only if $a$ satisfies $F$.

The operation is an involution: performing it twice restores the original assignment and formula. It therefore gives a bijection between the satisfying assignments of $F$ and those of $\bar F$. Through the assembly–assignment correspondence, it also gives the following physical interpretation.

**Tab–Blank Solvability Symmetry.** The puzzle associated with $F$ is solvable if and only if the puzzle associated with $\bar F$ is solvable. Conceptually, global Boolean negation corresponds to swapping tabs and blanks throughout the logical interfaces.

For the running example, complementation turns

$$
(x_0\lor x_1\lor\neg x_2)\land(\neg x_0\lor x_2)
$$

into

$$
(\neg x_0\lor\neg x_1\lor x_2)\land(x_0\lor\neg x_2).
$$

The satisfying assignment $(\mathrm{false},\mathrm{true},\mathrm{false})$ becomes $(\mathrm{true},\mathrm{false},\mathrm{true})$, which satisfies the complemented formula. Every solution is paired this way.

There is a subtle but important limit. Solvability invariance does not yet imply that complementation acts freely on a single puzzle’s solution set. A formula or framed puzzle may be self-dual under additional relabeling, creating special fixed behavior. Establishing free two-element orbits requires a hypothesis excluding such self-duality.

## Complexity: what is proved, and what remains

Boolean satisfiability is the archetypal NP-complete problem. It is tempting to jump from the correspondence to the slogan “jigsaw puzzles are NP-complete.” For the abstract formula-indexed assembly model, satisfiability and assembly are indeed equivalent at the witness level. But unrestricted geometric jigsaws demand more.

A complete geometric reduction must replace the abstract clause-fitting condition with actual planar components. Wires must carry truth values; fan-out gadgets must copy them; clause gadgets must accept one or more true inputs; and crossover gadgets—or an alternative planar layout—must prevent signals from interfering. A rigid frame must eliminate unwanted translations, rotations, and interchangeable placements. Most critically, these gadgets must introduce neither spurious assemblies nor destroy valid ones.

The exact correspondence proved here sharply identifies that remaining burden. The logical bookkeeping is already parsimonious. Any mismatch in a geometric realization must arise from geometry: a gadget symmetry, an unintended fit, a boundary ambiguity, or a crossing problem.

That distinction is scientifically useful. It replaces a broad claim with a precise research program. One may ask whether four-sided, non-rotatable square pieces with finitely many edge colors suffice; whether assembly counts equal satisfying-assignment counts up to a predictable symmetry factor; or whether the topology of the space of solutions survives geometric realization.

## From edges to topology

Tabs and blanks suggest a conservation law. When two interior edges meet, a positive protrusion and a negative indentation cancel. On a rectangular region, this resembles a discrete divergence principle: unmatched signed edge potential must be accounted for at the boundary.

On surfaces with holes, cancellation may carry more information. A torus has two independent noncontractible directions, so signed edge data could produce two flux obstructions. In algebraic-topological language, those obstructions would live in a first cohomology group and would have to pair trivially with every allowable cycle. This remains a conjectural extension, but it grows naturally from the same local complementarity rule.

There is also topology inside the collection of solutions. Make each satisfying assignment a vertex, and join two vertices when they differ in one variable. The resulting solution graph—and higher-dimensional cubical complex when several independent flips commute—records how solutions connect. A parsimonious geometric construction might preserve not only the number of solutions but the shape of this solution complex up to deformation.

The humble jigsaw thus opens three windows at once. Logic describes which local conditions can coexist. Complexity measures the cost of finding a global witness. Topology studies conserved boundary data and the shape of all witnesses together.

The satisfying snap of two pieces is local. The wonder of a completed puzzle is global. Between those scales lies a precise mathematics: clauses become interfaces, assignments become recipes, solution counts are preserved exactly, and a universal tab–blank reversal mirrors Boolean negation. The broader geometric complexity story is not finished—but its logical heart is now visible, one complementary edge at a time.
