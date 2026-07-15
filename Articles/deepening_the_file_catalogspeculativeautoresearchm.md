# Two Hidden Coordinate Systems: Factorial Digits and the Shadows of Triangles

Numbers and networks seem to speak different languages. A number is arranged along a line; a network spreads across vertices and edges. Yet both can be understood by the same broad habit of mind: replace a complicated object by the right family of smaller pieces, then prove that the pieces retain exactly the information that matters.

This principle appears here in two striking forms. First, the factorial number system turns ordinary integers into strings of digits whose place values are factorials. It is not an isolated curiosity: it is precisely a mixed-radix positional system, so its evaluation, digit bounds, extraction rule, reconstruction theorem, and uniqueness all come from one general mechanism. Second, a graph’s triangles can be treated as a family of three-element sets. Erasing one vertex from each triangle creates a “shadow” made of two-element sets—and every such pair is an edge. The Kruskal–Katona principle then converts abundance of triangles into a sharp lower bound on edges.

The common theme is a bridge. Factorial notation is connected to general positional arithmetic; triangle counting is connected to the geometry of set families. Once each bridge is built, the desired conclusions become consequences of a broader structure.

## When every column has its own base

In ordinary decimal notation, every column has base $10$. The number $407$ means

$$
4\cdot 10^2+0\cdot 10+7.
$$

A mixed-radix system lets the base change from one position to the next. Choose positive radices $b_0,b_1,b_2,\ldots$. Define the place value at position $i$ by

$$
B_i=\prod_{j=0}^{i-1} b_j,
$$

with the empty product $B_0=1$. A finite digit sequence $c_0,\ldots,c_{k-1}$ then represents

$$
V_b(c;k)=\sum_{i=0}^{k-1}c_iB_i.
$$

The natural validity rule is $0\le c_i<b_i$. This is exactly what prevents one column from containing enough units to carry into the next.

The factorial number system, or factoradic system, assigns place value $i!$ to position $i$ and permits digit $c_i$ to range from $0$ through $i$. Its value is

$$
V_!(c;k)=\sum_{i=0}^{k-1}c_i i!.
$$

At first glance, factorial notation looks unlike a standard positional system. But choose the mixed radices

$$
b_i=i+1.
$$

Then the running product is

$$
B_i=\prod_{j=0}^{i-1}(j+1)=i!.
$$

This elementary identity is the hinge on which the whole bridge turns.

### The Factorial–Mixed-Radix Equivalence

For every digit sequence $c$ and cutoff $k$, the mixed-radix value with radices $b_i=i+1$ equals the factoradic value:

$$
V_b(c;k)=V_!(c;k).
$$

Moreover, the mixed-radix bounds $c_i<b_i$ become exactly the factoradic bounds $c_i<i+1$, or equivalently $c_i\le i$.

The proof is transparent. Replace every running product $B_i$ by $i!$ in the mixed-radix sum. The two value formulas then coincide term by term, and the two validity conditions are the same inequalities written in two ways.

This is more than a change of notation. General mixed-radix arithmetic comes with a digit-extraction rule. For a number $n$, the digit at position $i$ is

$$
d_i(n)=\left\lfloor\frac{n}{B_i}\right\rfloor\bmod b_i.
$$

Under $b_i=i+1$ and $B_i=i!$, this becomes the familiar factoradic formula

$$
d_i(n)=\left\lfloor\frac{n}{i!}\right\rfloor\bmod(i+1).
$$

Thus the general and factorial extraction algorithms agree at every position, not merely in their final output.

## A perfect fit below $k!$

Why do the first $k$ factorial columns represent exactly the integers below $k!$? The answer is encoded in the product of the radices:

$$
\prod_{i=0}^{k-1}(i+1)=k!.
$$

There are $i+1$ choices for digit $c_i$. Hence the number of valid length-$k$ digit strings is

$$
1\cdot2\cdots k=k!.
$$

The numerical interval $\{0,1,\ldots,k!-1\}$ also contains $k!$ elements. Counting alone is suggestive, but reconstruction and uniqueness establish the exact correspondence.

### Reconstruction Theorem

If $0\le n<k!$ and

$$
d_i(n)=\left\lfloor\frac{n}{i!}\right\rfloor\bmod(i+1),
$$

then

$$
n=\sum_{i=0}^{k-1}d_i(n)i!.
$$

The bound $n<k!$ is sharp: the first $k$ positions have total capacity $k!$, so $k!$ itself requires the next position.

### Uniqueness Theorem

Suppose two length-$k$ digit sequences $c$ and $e$ satisfy $0\le c_i,e_i\le i$ for every $i<k$. If

$$
\sum_{i=0}^{k-1}c_i i!=\sum_{i=0}^{k-1}e_i i!,
$$

then $c_i=e_i$ for every $i<k$.

A useful proof idea is to inspect the first place where the strings differ. Lower places cannot compensate for one unit at position $r$, because their maximum total is

$$
\sum_{i=0}^{r-1}i\,i!=r!-1.
$$

That is strictly less than the value $r!$ of one unit in the next place. The mixed-radix uniqueness principle packages this argument for arbitrary varying bases; factorial uniqueness is its specialization.

For example, take $n=463$. Successive factoradic digits are

$$
(d_0,d_1,d_2,d_3,d_4,d_5)=(0,1,0,1,4,3),
$$

and indeed

$$
463=0\cdot0!+1\cdot1!+0\cdot2!+1\cdot3!+4\cdot4!+3\cdot5!.
$$

The digits obey $d_i\le i$, and no other valid string of six digits has the same value.

Factorial coordinates also have a famous combinatorial life: the successive alphabets of sizes $1,2,\ldots,k$ match the choices made while constructing a permutation by insertion. This is why factoradics are naturally related to permutation ranking and unranking. The arithmetic theorem developed here supplies the numerical backbone for that correspondence.

## From triangles to their shadows

Now turn from numbers to graphs. A finite simple graph consists of vertices joined by undirected edges, with no loops or repeated edges. A triangle is a set of three vertices with all three connecting edges present.

Suppose a graph has many triangles. How few edges could it possibly have? A first instinct might be to count incidences, but edges can belong to many triangles, so naive division gives weak results. The right move is to forget, temporarily, that the triangles came from a graph. Regard them simply as a family $\mathcal T$ of three-element subsets of the vertex set.

For any family $\mathcal F$ of $r$-element sets, its lower shadow $\partial\mathcal F$ is the family of all $(r-1)$-element sets obtained by deleting one element from a member of $\mathcal F$:

$$
\partial\mathcal F=\{A: |A|=r-1\text{ and }A\subseteq F\text{ for some }F\in\mathcal F\}.
$$

When $\mathcal F=\mathcal T$, every member of $\partial\mathcal T$ is a pair of vertices lying inside a triangle. Such a pair must be an edge. Therefore

$$
\partial\mathcal T\subseteq E,
$$

where $E$ is the graph’s edge set. This small observation is the geometric heart of the argument: triangle shadows are edges.

## The sharp triangle-to-edge threshold

The Kruskal–Katona theorem says, in essence, that a large family of equal-sized sets cannot have an arbitrarily small shadow. In the special form needed here, if a family of three-element sets has at least $\binom{k}{3}$ members, where $k\ge3$, then its shadow has at least $\binom{k}{2}$ pairs.

Combine this with the shadow inclusion and obtain the graph theorem.

### Triangle–Edge Theorem

Let $G$ be a finite simple graph on $n$ vertices. If $3\le k\le n$ and $G$ contains at least $\binom{k}{3}$ triangles, then $G$ contains at least $\binom{k}{2}$ edges.

The proof has three steps. The triangle family is $3$-uniform because every triangle contains three vertices. The Kruskal–Katona shadow bound gives

$$
|\partial\mathcal T|\ge\binom{k}{2}.
$$

Since every shadow pair is an edge,

$$
|E|\ge|\partial\mathcal T|\ge\binom{k}{2}.
$$

The bound is exact. The complete graph on $k$ vertices, together with any number of isolated vertices, has precisely $\binom{k}{3}$ triangles and $\binom{k}{2}$ edges. So neither threshold can be improved.

For $k=6$, the statement says that at least $\binom{6}{3}=20$ triangles force at least $\binom{6}{2}=15$ edges. A complete graph on six vertices attains both numbers. For $k=10$, the corresponding pair is $120$ triangles and $45$ edges.

## Why these bridges matter

The two stories are not the same theorem, but they embody the same research strategy.

In factorial arithmetic, the difficult-looking special system is placed inside a general family by identifying its cumulative weights. The identity $\prod_{j<i}(j+1)=i!$ transports evaluation, validity, extraction, reconstruction, and uniqueness all at once.

In graph counting, a global pattern is translated into a uniform set family. Deleting one vertex exposes a lower-dimensional trace, and a general shadow theorem supplies the numerical bound. The graph contributes the inclusion $\partial\mathcal T\subseteq E$; set-family geometry does the extremal counting.

These ideas have computational consequences. Factoradic extraction gives a direct encoder for bounded integers and a route to permutation indexing. Triangle shadows give a structural certificate: whenever a network reports a given triangle count, its edge count must clear a precise threshold. In data analysis, triangles represent local clustering; in communication networks they mark redundant three-way connectivity; in social networks they model closed triads. The theorem does not infer every detail of the network, but it imposes an unavoidable infrastructure cost on dense local cohesion.

The larger lesson is that mathematical objects often become simpler after a change of coordinates. Sometimes the coordinates are numerical, with factorial place values. Sometimes they are combinatorial, with triangles projected to edge shadows. In both cases, the right representation turns a specialized claim into a clean consequence of a general law—and reveals exactly why the bound is sharp.