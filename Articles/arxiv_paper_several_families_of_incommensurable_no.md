# How to Count Hyperbolic Worlds Without Listing Them

## A bridge from geometry to information

Imagine a hall of mirrors whose walls do not live in ordinary Euclidean space. The walls bound a polytope in hyperbolic space, and every pair of adjacent walls meets at an angle of the form $\pi/m$, where $m$ is an integer at least $2$. Reflections in those walls generate a highly structured symmetry group. Such an object is called a **hyperbolic Coxeter polytope**.

These polytopes sit at a crossroads of geometry, algebra, topology, and dynamics. Their angles are discrete, but their ambient geometry is curved. Their reflection groups tile hyperbolic space, yet two different-looking tiles can encode closely related groups. In the noncompact finite-volume case, the polytope reaches all the way to infinity through cusp-shaped ends while still enclosing finite hyperbolic volume.

A natural classification question is therefore subtler than “How many shapes are there?” The more meaningful question is: **How many genuinely different commensurability types are there?** Two reflection groups are commensurable when, after conjugating one if necessary, they share isomorphic finite-index subgroups. Commensurability forgets finite-scale decoration and records a deeper common geometric ancestry.

The central idea developed here is a counting bridge. Instead of comparing every pair of polytopes directly, attach to each polytope a label that cannot change within a commensurability class. Count the labels, and one automatically obtains a lower bound for the number of classes. When binary geometric choices generate exponentially many labels while volume grows only linearly, exponential growth in commensurability classes follows.

## The invariant as a geometric fingerprint

A **commensurability invariant** is a function $I$ from a family of objects to some set of values such that

$$
P\sim Q \quad\Longrightarrow\quad I(P)=I(Q),
$$

where $P\sim Q$ means that $P$ and $Q$ are commensurable. Examples arising in hyperbolic geometry include maximal cusp density, invariant trace fields, and suitable volume or covolume data.

The invariant need not identify a class uniquely. Several classes may share one value. What matters is the one-way implication: different invariant values force different classes.

**Invariant-Counting Principle.** Let $S$ be any finite family, let $\sim$ be an equivalence relation on $S$, and let $I$ be constant on equivalence classes. Then

$$
|I(S)|\le |S/{\sim}|.
$$

Here $I(S)$ is the set of distinct invariant values and $S/{\sim}$ is the set of equivalence classes represented in $S$.

The proof is almost visual. Collapse the family $S$ into its equivalence classes. Because $I$ is constant on each class, it descends to a function from classes to invariant values. A function cannot have an image larger than its domain. Therefore the number of values cannot exceed the number of classes.

This elementary inequality does enormous conceptual work. Pairwise incommensurability is a global relation: to establish it naively for $N$ objects may appear to require up to $N(N-1)/2$ comparisons. A separating invariant replaces those comparisons with the evaluation of one fingerprint per object.

## The local grammar of Coxeter angles

The counting bridge is abstract, but Coxeter geometry supplies rigid numerical data. If two facets meet at dihedral angle $\pi/m$, their outward unit normals contribute an off-diagonal Gram-matrix entry

$$
g(m)=-\cos(\pi/m).
$$

The diagonal entries are $1$. For every integer $m\ge 2$, the angle satisfies

$$
0<\frac{\pi}{m}\le \frac{\pi}{2}.
$$

Cosine decreases from $1$ toward $0$ on this interval, so

$$
0\le \cos(\pi/m)<1.
$$

Negating gives the **Gram-Entry Range Theorem**:

$$
-1<-\cos(\pi/m)\le 0.
$$

At $m=2$, the walls are orthogonal and the entry is $0$. As $m$ increases, the angle shrinks and the entry approaches $-1$ without reaching it. This half-open interval is the local numerical corridor in which Coxeter Gram data must lie for intersecting facets.

The result is modest in appearance, but it is the first filter in any Gram-matrix search. A proposed matrix with an intersecting-facet entry outside $(-1,0]$ cannot come from an angle $\pi/m$ with $m\ge2$. Local angle restrictions, global matrix signature, and the finite or affine nature of vertex links together form the architecture behind geometric realization.

## A clean model of exponential growth

To isolate the arithmetic engine, consider words of length $n$ in a binary alphabet. Write a word as

$$
w=(w_1,\ldots,w_n)\in\{0,1\}^n.
$$

Attach an additional decoration bit $\varepsilon\in\{0,1\}$. Thus an object is a pair $(w,\varepsilon)$. Declare two objects equivalent precisely when their words agree:

$$
(w,\varepsilon)\sim(w',\varepsilon')\quad\Longleftrightarrow\quad w=w'.
$$

The decoration is deliberately invisible to equivalence. Consequently each class contains two genuinely distinct objects, $(w,0)$ and $(w,1)$. The relation is therefore strictly coarser than equality; the class count is not manufactured by pretending that every object is isolated.

Take the invariant to be the word itself, $I(w,\varepsilon)=w$. It is constant on classes and assumes exactly $2^n$ values. Define the model volume to be the Hamming weight

$$
V(w,\varepsilon)=\#\{i:w_i=1\}.
$$

Every word has at most $n$ occupied positions, so $V(w,\varepsilon)\le n$. The invariant-counting principle now yields the **Binary Exponential-Growth Theorem**:

> For every nonnegative integer $n$, the full decorated binary family has model volume at most $n$ and represents at least $2^n$ equivalence classes.

In fact the model has exactly $2^n$ classes, each of size two. The lower bound also has the analytic form

$$
2^n=\exp(n\log 2)\ge 1+n\log 2,
$$

where the final inequality is the standard bound $e^x\ge1+x$. Thus the family displays a precise linear-versus-exponential contrast: permitted volume grows like $n$, while distinguishable classes grow like $e^{(\log2)n}$.

## Why the decoration bit matters

One could obtain $2^n$ classes trivially by declaring equivalence to mean equality. That would conceal the point. Commensurability in geometry really does forget information: distinct polytopes may belong to the same commensurability class. The decoration bit makes that forgetting explicit.

The model separates three roles that are often blurred together:

1. the **object**, containing both structural and decorative information;
2. the **equivalence relation**, retaining only common ancestry;
3. the **invariant**, recording information guaranteed to survive passage to a class.

This separation is essential when moving back to geometry. A cusp modification, a diagrammatic choice, or a gluing decoration may alter the polytope without changing every commensurability-sensitive quantity. A useful invariant must detect enough of the construction word while remaining constant under commensurability.

## From binary words to cusped polytopes

The model does not by itself assert that every binary word is realized by a hyperbolic Coxeter polytope. Rather, it identifies exactly what a geometric construction must provide.

Suppose that for each word $w\in\{0,1\}^n$ one constructs a finite-volume noncompact hyperbolic Coxeter polytope $P_w$. Assume two quantitative facts. First, there are constants $A,B>0$ such that

$$
\operatorname{vol}(P_w)\le An+B.
$$

Second, a commensurability invariant takes distinct values on distinct words. Then the $2^n$ words yield at least $2^n$ commensurability classes. If $V=An+B$, this becomes

$$
\#\text{classes of volume at most }V
\ge 2^{(V-B)/A}
=\exp\!\left(\frac{\log2}{A}(V-B)\right).
$$

That is exponential growth in the volume threshold.

Maximal cusp density is especially natural for noncompact finite-volume objects. A cusp is an end that extends infinitely far while narrowing rapidly enough to contribute finite volume. One may enlarge disjoint horoball neighborhoods around cusps until they become maximal; the fraction of total volume occupied by this maximal cusp configuration can serve as a rigid geometric fingerprint. If local binary choices produce distinct densities, the counting bridge turns those numerical distinctions into incommensurability.

## Classification and construction play different roles

Finite classifications and infinite constructions complement each other. A classification of five-dimensional finite-volume Coxeter polytopes with eight facets reports $141$ examples, of which $125$ are noncompact. Such a finite stock is a laboratory: one can inspect diagrams, Gram matrices, cusp links, and candidate replacement pieces.

An infinite-family theorem asks a different question. It seeks repeatable local moves whose cost is controlled and whose invariant signature accumulates without collision. The classification supplies ingredients; the counting principle explains how those ingredients can scale.

The decisive resource is not merely the number of available pieces but their **information per unit volume**. A binary choice carries one bit. Repeating it at $n$ controlled sites gives $n$ bits and hence $2^n$ possible words. If each site adds bounded volume, then information grows linearly with volume and the number of encoded types grows exponentially.

This viewpoint suggests a broader entropy law. If a construction uses an alphabet of $q$ equally costly modifications, then $q^n$ words are available and the natural exponent becomes $\log q$ per site. If costs differ, weighted entropy replaces the simple count. If the invariant recovers a word only up to subexponentially many ambiguities, the leading exponential rate can still survive.

## The boundary between combinatorics and geometry

The argument cleanly divides into a universal part and a geometric part.

The universal part says: invariants factor through equivalence classes; distinct values lower-bound classes; $n$ binary decisions create $2^n$ words; and linear size turns that count into an exponential lower bound.

The geometric part must establish that the proposed objects exist, have the required finite volume, satisfy Coxeter angle and Gram-signature constraints, possess appropriate finite or ideal vertex links, and carry an invariant that really separates the construction words.

Keeping this boundary visible prevents overstatement. The binary model proves the counting mechanism in a nondegenerate setting. It does not replace the geometric realization problem. Instead, it tells researchers precisely where the difficult geometry lives: in constructing the family and proving separation.

## A reusable lesson

The method reaches beyond hyperbolic reflection groups. Whenever a classification problem has

- an equivalence relation expressing sameness at the right scale,
- an invariant constant on its classes,
- many independently selectable local features, and
- a size or energy cost that grows additively,

the same bridge can turn local information into global abundance.

The mirrors of hyperbolic space make the story vivid, but its core is an information principle: a structure with $n$ reliable binary switches can encode $2^n$ distinguishable signatures. Geometry determines whether those switches are realizable and whether their signatures survive commensurability. Counting then does the rest.
