# The Mirror Puzzle: Why Complementary Jigsaws Come in Pairs

Imagine a square jigsaw piece whose edges are not decorated with a picture but engineered as signals. An edge may be flat, protrude as a tab, or recede as a blank. Tabs fit blanks; tabs do not fit tabs, and blanks do not fit blanks. Colors can impose an additional rule: a red tab may fit only a red blank. With a rigid rectangular frame and pieces that cannot rotate, such a puzzle becomes a small geometric computer. Every complete assembly is a solution to a network of local constraints.

Now perform a peculiar experiment. On every piece and along every non-flat part of the frame, replace each tab by a blank and each blank by a tab, while preserving its color and position. Call the transformed puzzle the **global complement**. What happens to the solution set?

At first glance, complementation appears almost too simple to matter. Yet it reveals a precise symmetry of entire solution spaces. Every assembly of the original puzzle has one and only one complemented assembly, obtained by complementing every participating edge. Repeating the operation restores the starting assembly. Consequently, the original and complemented puzzles have exactly the same number of solutions.

There is a further and subtler conclusion. Keep the two solution spaces distinct by attaching a label to every assembly: “original” or “complemented.” On their combined, tagged space, global complementation has no fixed points. It swaps the label every time. Thus every orbit consists of exactly two assemblies, and the total number of tagged assemblies is even. This remains true even when the puzzle is indistinguishable from its own complement.

That last sentence is the surprise.

## From local fits to a global mirror

Let $P$ be a framed puzzle, and let $P^c$ denote the puzzle obtained by reversing every tab and blank. Write $A(P)$ for the finite set of complete assemblies of $P$. The geometric heart of complementation is a bijection

$$
c_P:A(P)\longrightarrow A(P^c).
$$

The map sends an assembly to the configuration with all non-flat edge polarities reversed. Its inverse is complementation in the other direction, because changing tab to blank and then blank to tab does nothing overall.

This immediately gives the **Equal-Count Theorem**:

> If global edge complementation induces a bijection between the complete assemblies of a finite framed puzzle and its complement, then the two puzzles have equally many assemblies.

In symbols,

$$
|A(P)|=|A(P^c)|.
$$

The result concerns complete assemblies, not merely the statement that either both puzzles are solvable or neither is. Solvability remembers only whether a solution set is empty. A bijection preserves every individual witness. If the original has $37$ assemblies, so does its complement; if one particular arrangement exists, it has a uniquely determined partner.

Why does local compatibility survive? Suppose two adjacent edges fit because one is a tab and the other is a blank of the same color. Complementing both reverses their roles, leaving a blank opposite a tab of that same color. Flat boundary edges remain flat. Every local constraint is therefore preserved simultaneously. The transformation is global, but its correctness is checked one neighboring pair at a time.

## The importance of a tag

To see the parity phenomenon clearly, form the **tagged combined solution space**

$$
C(P)=\bigl(\{L\}\times A(P)\bigr)\;\sqcup\;\bigl(\{R\}\times A(P^c)\bigr).
$$

The symbols $L$ and $R$ record which puzzle an assembly belongs to. Define a transformation $T$ by

$$
T(L,a)=(R,c_P(a)),
$$

and, using the inverse bijection,

$$
T(R,b)=(L,c_P^{-1}(b)).
$$

Two elementary facts drive everything. First, $T$ is an involution:

$$
T(T(x))=x
$$

for every tagged assembly $x$. Second, $T$ has no fixed point. An element tagged $L$ is sent to one tagged $R$, and vice versa; equality is impossible because the tags differ.

Together these facts yield the **Two-Element Orbit Theorem**:

> Every orbit of complementation on the tagged combined solution space is exactly the pair $\{x,T(x)\}$ and therefore has two elements.

The associated **Parity Theorem** states:

> For finite assembly spaces linked by global complementation, the total number of original and complemented tagged assemblies is even.

Indeed, if $n=|A(P)|$, then the bijection gives $|A(P^c)|=n$, so

$$
|C(P)|=n+n=2n.
$$

The number of complementary pairs is exactly $n$. For $n=0,1,2,3,4,5$, the combined counts are $0,2,4,6,8,10$. This is not a pattern inferred from examples; it is forced for every finite $n$ by the pairing.

## The self-dual trap

One might guess that this fixed-point-free behavior requires the original puzzle not to resemble its complement. That guess confuses two different spaces.

A puzzle is **self-dual** if it can be identified with its global complement. Consider the most extreme toy case: there is one puzzle, complementation leaves it unchanged, and it has exactly one assembly. On the untagged assembly set, the complement operation can be the identity, so its sole assembly is fixed. But the tagged combined space contains two distinct objects:

$$
(L,\ast)\qquad\text{and}\qquad(R,\ast).
$$

Complementation swaps them. The orbit has two elements, and there is no fixed tagged assembly.

This gives a sharp correction to the tempting restriction:

> Non-self-duality is unnecessary for freeness on the tagged disjoint union. The side label alone prevents fixed points.

The qualification “tagged” is essential. If one chooses an isomorphism between a self-dual puzzle and its complement and then erases the distinction between the two sides, fixed points can reappear. Pairing is automatic before quotienting; it need not survive after identifications are imposed.

This distinction occurs throughout mathematics and computer science. A left copy and a right copy of the same data remain distinct in a disjoint union, just as two identical files in different directories remain distinguishable by their locations. Forget the locations, and two records may collapse into one. Symmetry statements depend not only on the objects but on what information the ambient space remembers.

## Why this matters beyond recreational puzzles

Constraint puzzles are physical models of logical systems. A completed assembly can encode a satisfying assignment, a valid routing, or a feasible schedule. In that setting, a bijection between solution spaces is stronger than a reduction preserving yes-or-no answers. It preserves the count of witnesses exactly. That is the currency of counting complexity, where the question is not merely “Does a solution exist?” but “How many solutions exist?”

Complementary pairing also provides a diagnostic for software and experiments. If a program enumerates assemblies of a puzzle and its complement, unequal counts prove that something is wrong: a boundary was transformed incorrectly, a color rule was lost, duplicate pieces were mishandled, or the enumeration omitted solutions. Likewise, an odd combined count signals an error whenever the claimed complement bijection applies.

The idea resembles particle–antiparticle pairing, bitwise negation, and dual electrical networks, but its mechanism is especially transparent. A local polarity reversal induces a global, reversible transport. The resulting parity is not mysterious number theory; it is the visible shadow of a fixed-point-free involution.

There is also an algorithmic benefit. Suppose all assemblies of the original puzzle have been generated. Their complements immediately enumerate all assemblies of the complementary puzzle in time proportional to the output size. If an assembly is represented by $m$ placed pieces and each piece has four edges, complementing it takes $O(m)$ time and $O(m)$ output space. No new search is required.

## The boundary of the theorem

The argument deliberately isolates its geometric assumption. It requires finite assembly sets and a genuine bijection between complete assemblies. It does not by itself construct that bijection for every imaginable rule set. If pieces may rotate, if the frame is not complemented consistently, if colors transform nontrivially, or if pieces are identified under symmetries, one must first prove that complementation neither loses valid assemblies nor creates spurious ones.

Once that bijection is established, however, the orbit conclusions are automatic. The puzzle-specific work is concentrated in a single question: does edgewise reversal transport complete assemblies perfectly?

This modular viewpoint points toward larger goals. For geometric reductions from satisfiability, one would like gadgets whose solution sets correspond exactly to truth assignments, not merely in existence but in number. For puzzles on surfaces such as a torus, complementary edge flows may interact with topological cycles. For reconfiguration problems, one can ask whether nearby logical assignments correspond to local moves between assemblies. Each direction studies more structure than solvability alone.

## A symmetry that counts

The central lesson can be stated without specialized machinery. If two finite worlds are connected by a reversible transformation, place them side by side without forgetting which is which. The transformation then swaps the worlds. Every object acquires one partner, no object partners with itself, and the combined population is even.

For complementary jigsaws, the worlds are the complete assemblies of a puzzle and of its tab–blank mirror. The reversible transformation is global edge complementation. The labels are the quiet heroes: they preserve the distinction that makes freeness unconditional, including in the self-dual case.

A simple flip of tabs and blanks therefore carries more information than solvability. It organizes every solution into a two-element orbit, equates two counting problems, supplies a parity check, and clarifies exactly where self-symmetry can—and cannot—create fixed points. The jigsaw’s mirror does not merely answer the same question. It pairs every answer.