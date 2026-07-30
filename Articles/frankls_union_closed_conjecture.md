# The Element That Refuses to Be Rare

## A tour through union-closed families, Boolean cubes, and an unfinished combinatorial mystery

Imagine a collection of clubs. Each club has a roster, and whenever two clubs merge, the combined roster is also on the official list of clubs. There may be many clubs or only a few; some may share nearly all their members, while others overlap hardly at all. A deceptively simple question now asks: must there be a person who belongs to at least half of the clubs?

Translated into mathematics, a **finite union-closed family** is a finite collection $\mathcal F$ of finite sets such that

$$
A,B\in\mathcal F \quad\Longrightarrow\quad A\cup B\in\mathcal F.
$$

The family is called nontrivial when at least one of its sets is nonempty. An element $x$ is **abundant** if it occurs in at least half the members of the family. Writing

$$
\mathcal F_x=\{A\in\mathcal F:x\in A\},
$$

abundance means

$$
2|\mathcal F_x|\ge |\mathcal F|.
$$

Frankl's union-closed sets conjecture says that every finite nontrivial union-closed family has an abundant element. No one knows whether this is true in full generality. The mystery is striking because the rule of closure under unions is so elementary. Yet that rule creates a global geometry among the sets, and local counting alone often fails to capture it.

The results described here do not claim to settle the unrestricted conjecture. They illuminate three rigorous pieces of its landscape: the hidden lattice structure of every union-closed family, a complete proof for universes with three elements, and exact extremal identities for the full Boolean cube.

## A roof built into the family

Take every set in $\mathcal F$ and unite them all:

$$
T=\bigcup_{A\in\mathcal F}A.
$$

If $\mathcal F$ is nonempty and union-closed, then $T$ itself belongs to $\mathcal F$. This is the **Greatest-Member Theorem**: every nonempty finite union-closed family has a greatest member under inclusion, namely the union of all its members. Moreover,

$$
A\subseteq T\qquad\text{for every }A\in\mathcal F.
$$

The proof is short but revealing. List the finitely many members and take their unions one at a time. Union-closure keeps every intermediate union inside the family, so the final union remains inside as well. By construction it contains every original member.

This turns the family into a finite join-semilattice: the operation $A\vee B=A\cup B$ acts as a join, and $T$ is the top element. The clubs are therefore not merely a list. They form a partially ordered architecture with a roof. That reformulation matters because it invites tools from order theory: one can study chains, generators, joins, and maximal elements rather than treating all incidence data as unstructured.

## The singleton lever

Suppose the family contains a one-element set $\{x\}$. Then $x$ must be abundant. This is the **Singleton Abundance Theorem**.

The reason is an injection. Split the family into sets that contain $x$ and sets that do not. To every set $A$ missing $x$, assign

$$
A\longmapsto A\cup\{x\}.
$$

Because both $A$ and $\{x\}$ belong to the family, union-closure guarantees that the image also belongs to the family. It contains $x$, and different inputs give different outputs: removing $x$ recovers $A$. Thus the sets missing $x$ inject into the sets containing $x$. There can be no more of the former than the latter, so at least half the family contains $x$.

This little map is a model of the kind of argument the conjecture seems to demand. It uses closure not merely to count available sets but to pair sparse behavior with dense behavior. Whenever a singleton appears, one abundant element is immediately identified.

## Three points: the whole conjecture in miniature

Now restrict attention to a universe with three elements, say $U=\{0,1,2\}$. Its power set has eight subsets, so a family is chosen from eight possible members. There are therefore

$$
2^8=256
$$

possible families in total.

The **Three-Point Theorem** states: if $\mathcal F\subseteq\mathcal P(U)$ is union-closed and contains a nonempty set, then some $x\in U$ belongs to at least half the members of $\mathcal F$.

The proof divides the world cleanly. If $\mathcal F$ contains a singleton, the injection above finishes the argument. If it contains no singleton, only a finite residue remains. Every one of the $256$ candidate families can be examined by the exact definitions: reject those that fail union-closure, reject those with no nonempty member, and for every survivor test whether at least one of $0,1,2$ has frequency at least $|\mathcal F|/2$. Every qualifying family passes.

This is not a numerical approximation or a random sample. It is an exhaustive finite argument. More importantly, the conceptual split shrinks what computation must do. The structural singleton theorem handles an entire class at once; enumeration is reserved for families where that theorem cannot apply.

The condition that a witness element actually occurs in some member is automatic here. If $x$ appears in at least half a nontrivial family, the exhaustive conclusion chooses an element from the active universe of the family. In the singleton branch, $\{x\}$ itself supplies the witness.

Small-universe theorems do more than check toy cases. They expose false heuristics before those heuristics infect a general strategy. For example, it is tempting to believe that choosing an element from a smallest nonempty set should always work. Such naive rules are not generally reliable. The three-point proof succeeds because it combines a genuinely structural mechanism with a complete residual search, not because every family obeys an obvious greedy pattern.

## The perfectly balanced cube

At the opposite extreme from an arbitrary family lies the full power set $\mathcal P(S)$ of an $n$-element set $S$. This is the **Boolean cube**: each subset corresponds to a binary string of length $n$, with a $1$ recording membership and a $0$ recording absence.

The Boolean cube is union-closed, and every point is abundant. In fact, every point belongs to exactly half of all subsets. Fix $x\in S$. Pair each subset missing $x$ with the subset obtained by adding $x$. This is now a bijection, so the two classes have equal size. Since the cube has $2^n$ members, the frequency of $x$ is $2^{n-1}$ when $n>0$.

Two exact counting identities summarize the cube. First, the number of subsets is

$$
|\mathcal P(S)|=2^n.
$$

Second, the sum of the sizes of all subsets is

$$
\sum_{A\subseteq S}|A|=n2^{n-1}
$$

for $n\ge 1$, with both sides equal to $0$ when $n=0$ under the corresponding integer identity.

The cleanest proof double-counts incidences $(x,A)$ with $x\in A$. Count first by subsets: this gives $\sum_{A\subseteq S}|A|$. Count instead by elements: each of the $n$ elements occurs in $2^{n-1}$ subsets, giving $n2^{n-1}$.

Combining the identities yields the **Boolean-Cube Average-Size Theorem**:

$$
2\sum_{A\subseteq S}|A|=n|\mathcal P(S)|.
$$

Thus the average subset size is exactly $n/2$. This is the equality pattern associated with the lower bound saying that a union-closed family has average member size at least one half of the base-two logarithm of its number of members. For the cube, $|\mathcal P(S)|=2^n$, so

$$
\frac12\log_2|\mathcal P(S)|=\frac n2.
$$

The identity itself needs no logarithms and no entropy: it is pure integer double counting. The cube is perfectly balanced coordinate by coordinate and globally balanced in average set size.

## A distant echo: information accumulated one step at a time

A separate identity shows how the same themes of nonnegativity and telescoping appear in information theory. For positive rates $\lambda$ and $\mu$, define the divergence between exponential laws by

$$
D(\lambda\|\mu)=\log\frac{\lambda}{\mu}+\frac{\mu}{\lambda}-1.
$$

The logarithmic inequality $\log t\le t-1$ for $t>0$ gives $D(\lambda\|\mu)\ge0$. At consecutive integer rates,

$$
D(k+1\|k+2)=\frac1{k+1}-\log\frac{k+2}{k+1}.
$$

Summing the first $n$ terms makes the logarithms telescope:

$$
\sum_{k=0}^{n-1}D(k+1\|k+2)=H_n-\log(n+1),
$$

where $H_n=1+\frac12+\cdots+\frac1n$. Consequently the accumulated divergence converges to the Euler--Mascheroni constant:

$$
\sum_{k=0}^{\infty}D(k+1\|k+2)=\gamma.
$$

This identity is not needed for the three-point theorem, but it offers a useful conceptual echo. A global constant can emerge from many nonnegative local increments, just as global frequency conclusions in union-closed families may emerge from carefully paired local incidences.

## What remains beyond the horizon

The unrestricted union-closed conjecture remains open. The next finite frontier is a four-element universe. A particularly useful reduction for five elements would again separate families containing singletons from those containing none. Other concrete questions ask for a direct analysis of families generated by two sets, an exact proof that each Boolean-cube coordinate occurs $2^{n-1}$ times, and precise conditions under which adjoining the top member preserves an existing abundant witness.

The lasting lesson is methodological. Union-closure provides more than an equation: it provides a map. The top-member theorem turns repeated unions into order. The singleton theorem turns union with $\{x\}$ into an injection. The Boolean cube turns coordinate toggling into a bijection. The three-point result then combines structure with exhaustive certainty.

The clubs metaphor also points toward applications. Union-closed data arise whenever combining two feasible collections remains feasible: merged capability lists, accumulated feature sets, pooled permissions, or collections of available resources. The theorem sought is not that one resource appears everywhere, but that closure prevents every resource from being simultaneously marginal. Even in abstract form, it is a statement about how repeated aggregation forces concentration.

Somewhere inside every nontrivial union-closed family, Frankl's conjecture predicts, an element refuses to be rare. On three points we can see it completely. In the Boolean cube every element displays it symmetrically. In the general case, the search continues for the map, pairing, or lattice principle that will finally make the hidden abundance unavoidable.
