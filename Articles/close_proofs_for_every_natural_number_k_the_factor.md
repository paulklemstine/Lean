# The Number System Hidden Inside Every Permutation

A permutation is a rearrangement: shuffle a deck, reorder a playlist, assign jobs to machines, or rank a set of candidates. At first glance, rearrangements seem stubbornly global. Moving one item can alter the position of many others, and the number of possibilities grows with breathtaking speed. For $k$ objects there are

$$
k! = 1\cdot 2\cdots k
$$

possible permutations. Yet that product contains a clue. It says that a permutation can be described by making one choice from $1$ possibility, then one from $2$, then one from $3$, and so on up to $k$.

This is the idea behind a **factorial code of length $k$**. Such a code is a digit vector

$$
(c_0,c_1,\ldots,c_{k-1})
$$

in which the digit $c_i$ may take the values $0,1,\ldots,i$. Unlike ordinary decimal notation, where every position has radix $10$, the permitted radix changes with position. The first digit has one possibility, the second has two, the third has three, and the last has $k$. These are mixed-radix coordinates, tuned exactly to factorial growth.

The central result is stronger than a counting coincidence. **For every natural number $k$, factorial codes of length $k$ correspond bijectively to permutations of $k$ objects.** Every permutation has exactly one code, and every valid code decodes to exactly one permutation.

That statement turns a global rearrangement into a sequence of bounded local choices. It also reveals a hidden geometry: the symmetric group does not merely label the code space; it acts on it freely and transitively. In plain language, any code can be moved to any other by one and only one permutation.

## Building a permutation one choice at a time

The correspondence can be understood recursively. Suppose we already know how to encode permutations of $k$ objects. To encode a permutation of $k+1$ objects, first record one distinguished choice: where one selected object appears, or equivalently which of the $k+1$ available slots it occupies. This gives a new digit with $k+1$ possible values. Remove that object and relabel the remaining positions in order. What remains is a permutation of $k$ objects, which can be encoded recursively.

Thus a code of length $k+1$ splits naturally into

$$
\text{one digit chosen from }\{0,\ldots,k\}
\quad\text{and}\quad
\text{a code of length }k.
$$

The same split occurs on the permutation side. The two recursive structures match stage by stage. At length $0$, both sides contain a single empty object. Adding one stage preserves a one-to-one correspondence, so induction establishes the classification at every length.

A familiar concrete version is the Lehmer code. Given a permutation written as a list, repeatedly record the index of its first entry among the remaining sorted values, then delete that entry. For example, take the permutation

$$
(3,1,4,0,2).
$$

Among $\{0,1,2,3,4\}$, the first entry $3$ has index $3$. Remove it. Among $\{0,1,2,4\}$, the next entry $1$ has index $1$. Continuing gives

$$
(3,1,2,0,0),
$$

whose successive digits lie in sets of sizes $5,4,3,2,1$. Reversing their order produces the increasing-radix convention. Decoding reverses the operation: maintain a sorted list of unused values, select the indexed value, remove it, and continue.

The recursive viewpoint matters because it is not an arbitrary pairing of two sets with the same size. It respects the way permutations and codes are assembled.

## Why the number of codes is exactly $k!$

The counting theorem now has two complementary proofs. Directly, there are $i+1$ choices for digit $c_i$, so the product rule gives

$$
1\cdot 2\cdot 3\cdots k=k!
$$

codes. Alternatively, the bijection transfers the known count of permutations to the code space. The second proof says more: the count is accompanied by a reversible representation.

For $k=4$, the $24$ codes are the vectors

$$
(c_0,c_1,c_2,c_3),
\qquad
0\le c_0<1,
\quad 0\le c_1<2,
\quad 0\le c_2<3,
\quad 0\le c_3<4.
$$

This representation supports ranking and unranking. A code can be converted to an integer by factorial weights,

$$
R(c)=\sum_{i=0}^{k-1} c_i i!,
$$

which ranges from $0$ to $k!-1$. Conversely, repeated division by $1,2,\ldots,k$ recovers the digits. Combined with permutation encoding, this provides a deterministic way to place all permutations in a linear order without listing them first.

That mechanism appears wherever exhaustive search must traverse permutations: scheduling, combinatorial optimization, randomized testing, and exact sampling. An integer seed in $\{0,\ldots,k!-1\}$ can be unranked into a unique permutation, while a permutation can be compressed back to its rank.

## A space with perfect symmetry

The bijection lets the symmetric group act on codes. If $\sigma$ is a permutation and $c$ is a code, decode $c$ to a permutation $\tau$, compose on the left to obtain $\sigma\tau$, and encode the result. Denote the resulting code by $\sigma\cdot c$.

This transported operation obeys the two laws of a group action:

$$
e\cdot c=c
$$

for the identity permutation $e$, and

$$
(\sigma\tau)\cdot c=\sigma\cdot(\tau\cdot c).
$$

More importantly, the action is **free** and **transitive**. Freeness means that if $\sigma\cdot c=c$ for even one code $c$, then $\sigma$ must be the identity. Transitivity means that for any two codes $c$ and $d$, some permutation carries $c$ to $d$.

Together these properties give the **Factorial-Code Torsor Theorem**: for every pair of codes $c,d$, there exists a unique permutation $\sigma$ such that

$$
\sigma\cdot c=d.
$$

Indeed, if $c$ decodes to $\tau_c$ and $d$ decodes to $\tau_d$, the unique transporter is

$$
\sigma=\tau_d\tau_c^{-1}.
$$

A torsor is like a group whose origin has been erased. There is no intrinsically preferred code serving as zero, but the difference between any two codes is a well-defined permutation. This is a useful model for data with relative but not absolute alignment. In machine learning, for example, labels assigned to clusters are arbitrary: relabeling all clusters changes the representation but not the partition. A torsor perspective separates the object from the accidental choice of labels.

The same idea applies to ranking systems, anonymous agents, interchangeable particles, and architectures designed to be equivariant under permutations. Factorial digits provide compact coordinates, while the torsor action guarantees that symmetry has not been lost.

## The tempting Chinese-remainder analogy

Mixed-radix digits resemble residues. At length $4$, the nontrivial digit sets have sizes $2$, $3$, and $4$, and their product has size

$$
2\cdot3\cdot4=24=4!.
$$

This tempts one to identify the additive cyclic group $\mathbb Z/24\mathbb Z$ with

$$
\mathbb Z/2\mathbb Z\times\mathbb Z/3\mathbb Z\times\mathbb Z/4\mathbb Z.
$$

Both sets have $24$ elements. But the proposed additive equivalence is impossible.

The obstruction is the order of elements. The cyclic group $\mathbb Z/24\mathbb Z$ contains an element of additive order $24$, namely the class of $1$. In the product group, the order of an element divides the least common multiple of the component moduli:

$$
\operatorname{lcm}(2,3,4)=12.
$$

No element on the product side has order $24$. Therefore the groups cannot be isomorphic.

This yields a sharp length-four boundary theorem: **factorial codes of length $4$ still classify permutations perfectly, but their radix components cannot serve as independent additive Chinese-remainder coordinates for $\mathbb Z/24\mathbb Z$.**

The contrast teaches an important lesson. Equal cardinality can support a bijection, but it does not preserve algebraic structure. The classical Chinese Remainder Theorem gives a product decomposition when the moduli are pairwise coprime. The factorial radices $2,3,4$ are not: the factors $2$ and $4$ overlap in prime content. Carries between factorial digits are therefore not cosmetic. They encode dependencies that prevent componentwise addition from reproducing addition modulo $24$.

## Coordinates, symmetry, and learning

Why should this matter beyond recreational combinatorics? Many computational systems must represent objects on which permutations act. A model of a molecule should not depend on how atoms are numbered. A set-processing network should not care about input order. A multi-agent policy should behave predictably when agent labels are exchanged.

Factorial codes offer a complete finite coordinate system for such symmetries. Since every code is one group element away from every other, an equivariant map is tightly constrained: once its behavior is known at one reference point, symmetry transports that behavior throughout the orbit. This can reduce redundancy in both algorithms and learned models.

The recursive digits also suggest multiscale computation. Early stages describe choices in small symmetric groups; later stages add one object at a time. Algorithms can exploit this hierarchy rather than treating a permutation as a flat list. Ranking, unranking, sampling, and group actions can all be organized around the same insertion-and-removal structure.

But the length-four obstruction warns against the wrong simplification. The digits are independent as choices when counting codes, yet they are not independent cyclic coordinates under addition. For learning systems, that distinction is familiar: features may form a convenient parameterization without supporting naive componentwise operations. A representation must be judged not only by whether it is bijective, but by which transformations it respects.

## The broader picture

Three ideas meet in factorial codes. First, mixed-radix notation turns factorial growth into bounded digits. Second, recursive permutation decomposition makes those digits canonical and reversible. Third, transporting group multiplication reveals that the code space is a torsor, with a unique symmetry relating every ordered pair of points.

The resulting picture is both constructive and cautionary. It gives an exact algorithm for encoding and decoding permutations, a proof that there are $k!$ codes, and a symmetry action that is free and transitive. At the same time, it shows that these coordinates are not a disguised Chinese-remainder system: already at length $4$, additive element orders expose the mismatch.

A factorial code is therefore more than a clever numeral system. It is a coordinate chart for finite symmetry—one that faithfully records permutations, supports exact computation, and makes clear where coordinatewise arithmetic must give way to structured carries.