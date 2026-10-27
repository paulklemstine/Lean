# Turning the Puzzle Inside Out: Why Counting Jigsaw Solutions Survives Every Flip

*A jigsaw puzzle can be built to encode any logic problem. Swap every tab for a blank and every blank for a tab and you get a new puzzle. It is a different object, yet it has exactly the same number of solutions. This is the story of why that holds, what it hides, and where the counting breaks.*

---

## A puzzle that is secretly a logic problem

Picture a wooden frame with a row of $n$ empty slots called *sockets*. Each socket takes one of two small pieces. One carries a protruding **tab**, which we write as $1$. The other carries an indented **blank**, which we write as $0$. Choosing a piece for every socket gives a string of $n$ bits,
$$a = (a_1, a_2, \dots, a_n) \in \{0,1\}^n .$$

Next to the frame lies a pile of larger *clause pieces*. Each clause piece has a few connectors along its edge. A connector is cut to reach one particular socket $i$ and is milled for one particular polarity $p$, either tab or blank. The connector *mates* when the piece sitting in socket $i$ has exactly that polarity, that is, when $a_i = p$. A clause piece snaps into the frame as soon as **at least one** of its connectors mates. The puzzle is *assembled* when every clause piece snaps in.

Read it again and you will find a familiar object. A connector $(i, p)$ is a *literal*: "variable $i$ is true" when $p = 1$ and "variable $i$ is false" when $p = 0$. A clause piece is an OR of literals, and the whole puzzle is an AND of clauses. A framed jigsaw puzzle is a Boolean formula in conjunctive normal form, and an assembly is a satisfying assignment. Take the clauses $x_1 \lor x_2$ and $\lnot x_2 \lor x_3$. As a puzzle, the first clause piece has connectors (socket 1, tab) and (socket 2, tab). The second has (socket 2, blank) and (socket 3, tab). Out of the $2^3 = 8$ ways to fill the sockets, exactly four assemble the puzzle:
$$011,\quad 100,\quad 101,\quad 111 .$$

We call the number of assemblies the **assembly count** of the puzzle $P$ and write it $\#P$. (The symbol is chosen to echo the complexity class #P, which is about counting.)

## Deciding versus counting

Asking whether a puzzle can be assembled *at all* is exactly the satisfiability problem SAT, the original NP-complete problem. Asking *how many* assemblies exist is the counting problem #SAT. That problem is harder still. Leslie Valiant showed in 1979 that it is complete for #P, the class of problems that count the witnesses of an NP problem. Counting satisfying assignments is believed to be far beyond efficient computation, and the same goes for counting solutions to most combinatorial puzzles.

Between the yes/no question and the exact count sit the **modular counts**: the number of solutions modulo $2$, modulo $3$, or modulo any $k$. The parity question ("is the number of solutions odd?") defines a complexity class of its own, $\oplus$P, pronounced "parity-P". It is a strange class. Seinosuke Toda proved that a polynomial-time machine with access to $\#$P can decide anything in the whole polynomial hierarchy, and his proof goes through parity counting. Knowing *only the last bit* of a count can therefore be enormously informative.

This raises a design question. Suppose you want to move a counting question from one puzzle to another without disturbing it. You need a transformation that keeps not just the answer "solvable or not" but the exact number of solutions. Complexity theorists call such a map **parsimonious**: it is stingy and neither creates nor destroys witnesses. A parsimonious map preserves the count, so it automatically preserves the count modulo every $k$, including the parity.

## The flip

Here is the most natural transformation a puzzle maker could think of. Take a puzzle $P$ and **swap every tab for a blank and every blank for a tab** on every connector of every clause piece. Call the result the *complement* $\overline{P}$. In logical terms, every literal $x_i$ becomes $\lnot x_i$ and every $\lnot x_i$ becomes $x_i$.

The complement usually looks quite different. In our example $\overline{P}$ has the clauses $\lnot x_1 \lor \lnot x_2$ and $x_2 \lor \lnot x_3$, and its assemblies are
$$000,\quad 010,\quad 011,\quad 100 .$$
That is a different set, but it again has four elements. The reason is that each assembly of $\overline{P}$ is the bitwise complement of an assembly of $P$: $011 \leftrightarrow 100$, $100 \leftrightarrow 011$, $101 \leftrightarrow 010$, $111 \leftrightarrow 000$. If you flip the tabs on the clause pieces *and* flip the pieces in the sockets, every connection that used to mate still mates.

> **Complementation Theorem.** For every framed puzzle $P$, the puzzle and its complement have the same assembly count: $\#\overline{P} = \#P$. Flipping every variable piece is an explicit bijection between their assemblies. Consequently $\#\overline{P} \equiv \#P \pmod k$ for every modulus $k$. In particular, the puzzle has an odd number of assemblies exactly when its complement does.

The flip is also cheap. It changes one bit per connector, so it runs in linear time and produces a puzzle of exactly the same size. Doing it twice gives back the original puzzle. In the language of complexity theory, complementation is a size-preserving, involutive, **parsimonious self-reduction** of the assembly-counting problem. It is a free symmetry of the space of instances.

## The flip is one member of a larger family

The flip turns out to be one element of a much bigger symmetry group.

Nothing forces us to flip *every* socket. Choose a set of sockets, written as a mask $\mu \in \{0,1\}^n$, and swap tab and blank only at the sockets with $\mu_i = 1$, both on the connectors and on the variable pieces. The same argument applies: a mating connection stays mating. We can also *relabel* the sockets with a permutation $\sigma$ of $\{1, \dots, n\}$, moving everything aimed at socket $i$ to socket $\sigma(i)$. That plainly changes nothing essential either.

Combining a relabelling with a mask gives a **signed permutation**. Signed permutations form a group of order $2^n \cdot n!$, the *hyperoctahedral group*. It is the symmetry group of the $n$-dimensional cube, the same group that permutes and reflects the coordinate axes. Global complementation is the single element "no relabelling, flip everything".

> **Hyperoctahedral Invariance Theorem.** Every signed permutation $g$ carries the assemblies of a puzzle $P$ bijectively onto the assemblies of the transformed puzzle $g \cdot P$. Hence $\#(g\cdot P) = \#P$. Moreover, transforming by $h$ and then by $g$ is the same as transforming by the product $gh$ in the hyperoctahedral group, so the puzzles reachable from $P$ form a genuine orbit of a group action, and the count is constant along that whole orbit.

There is a geometric way to see this. The assemblies of $P$ form a subset of the corners of the $n$-cube, and a signed permutation is a rigid symmetry of that cube. Transforming the puzzle moves its solution set by a symmetry of the cube. A symmetry of the cube cannot change how many corners a set contains.

## When the flip does nothing

Could the complement of a puzzle be the very same puzzle? Then the "self-reduction" would be trivial on that instance. This happens only in a degenerate case.

> **Freeness Theorem.** $\overline{P} = P$ if and only if every clause piece of $P$ has no connectors at all.

A single connector $(i, p)$ turns into $(i, 1 - p)$, which is different. So any puzzle with at least one connector moves when flipped. Apart from the degenerate puzzles, the instance space therefore splits into pairs $\{P, \overline{P}\}$ of distinct puzzles with equal counts.

## Symmetry forces divisibility by powers of two

The group action has a second, more arithmetic consequence. Some puzzles are fixed by part of the group. Consider the masks $\mu$ that map the *solution set* of $P$ onto itself: flipping the sockets selected by $\mu$ sends every assembly to another assembly. These masks form a subgroup $H_P$ of $\{0,1\}^n$ under bitwise XOR. Every subgroup of $\{0,1\}^n$ has size a power of two, say $|H_P| = 2^k$. A nonzero mask moves every string, so the group splits the solution set into orbits of exactly $2^k$ assemblies each.

> **2-adic Certificate Theorem.** For every puzzle $P$, the order $|H_P| = 2^k$ of its mask-symmetry group divides the assembly count $\#P$. This order is unchanged by every signed permutation. In particular, if $\#P$ is odd, the mask-symmetry group of $P$ is trivial.

A puzzle with a visible flip symmetry therefore has an even number of solutions. Its parity is determined before any counting starts. In random experiments on small puzzles, the power of two dividing the count very often equals $2^k$ exactly, so the symmetry tends to explain *all* of the 2-adic structure of the count.

## Counting parity without counting

How would one compute the parity of $\#P$ directly? Use the classic inclusion–exclusion principle. For a set $S$ of clause pieces, let $F_S$ be the set of fillings that make **every** piece in $S$ fail. Then
$$\#P \;=\; \sum_{S \subseteq \text{clauses}} (-1)^{|S|}\, |F_S| .$$
Modulo $2$ the signs disappear, because $-1 \equiv 1$, which leaves
$$\#P \;\equiv\; \sum_{S} |F_S| \pmod 2 .$$
Each $F_S$ also has a simple shape. Making a clause piece fail means *every* connector $(i, p)$ on it must fail, so socket $i$ is forced to hold $1 - p$. Each failure set is therefore either empty (if two of the forced values conflict) or a subcube of dimension $n - (\text{number of sockets forced})$, with $2^{n - (\text{number of sockets forced})}$ elements. That number is odd only when it equals $1$. The parity of the count is the parity of the number of clause subsets that are *consistent* and *pin down every single socket*. In our example no subset pins all three sockets, and indeed $\#P = 4$ is even.

## Where parsimony actually breaks

If the mathematics preserves counts so faithfully, where does counting information get lost? The answer is in the physical pieces.

A real jigsaw has physical pieces, and some of those pieces are interchangeable. When a framed puzzle with $m$ clause pieces is turned into a pile of labelled physical pieces, swapping interchangeable pieces gives new "labelled" assemblies that are mathematically the same solution. Their number is
$$\#_{\text{labelled}}(P) \;=\; \#P \cdot (m+2)! \cdot n! \cdot n! .$$

> **Encoding Theorem.** The labelled assembly count is always even. For any solvable puzzle it differs from $\#P$, so the physical encoding is never parsimonious on solvable instances. It still preserves solvability, because the labelled count is zero exactly when $\#P$ is zero.

So the encoding destroys exactly the information that complementation keeps. It preserves the yes/no answer but wipes out the parity: every labelled count is even, whatever $\#P$ is. The factorials record the multiplicities of interchangeable pieces. **Piece multiplicities carry counting information**, and the mathematics of complementation does not lose it. The physical packaging does.

## Hardness is inherited, not lost

Finally, the logical translation in both directions is parsimonious. A DIMACS-style CNF formula becomes a puzzle with the same number of solutions, and a puzzle becomes a formula with the same number of solutions. Composing parsimonious maps gives a parsimonious map. So any counting problem that reduces parsimoniously to #SAT also reduces parsimoniously to jigsaw assembly counting, and that reduction preserves every modular count. Combined with Valiant's theorem, exact assembly counting is as hard as #SAT. Parity counting for jigsaws inherits all the hardness of parity counting for SAT, and the same holds for every other modulus.

The overall picture is easy to state. The space of jigsaw instances has a large free symmetry, the hyperoctahedral group, and that symmetry preserves exact counts and therefore all modular counts. Counting stays hard anyway: the symmetry gives no shortcut to the count. What it does supply is a source of easy *divisibility* information, namely powers of two forced by self-symmetry. Separately, the physical encoding, not the mathematics, throws away the parity.

## What's next

Several questions remain open. A Burnside-type sum over signed cycle types should count the essentially different two-clause puzzles, meaning the orbits of the hyperoctahedral group. It is natural to ask exactly when the 2-adic certificate from symmetry is sharp. And the parity criterion through fully pinning clause subsets invites a search for structured families of puzzles whose parity becomes easy.

So the next time you assemble a jigsaw, imagine turning every tab inside out. The finished picture would be a different one, but the number of ways to finish it would stay exactly the same.
