# Every Permutation Has an Address

## How factorial digits turn rearrangements into a number line

A shuffled deck looks like disorder. Fifty-two cards can be arranged in an almost inconceivably large number of ways, and changing the position of a single card may produce a completely different ordering. Yet beneath that apparent chaos lies a coordinate system as exact as street addresses. For a collection of $k$ distinct objects, every possible ordering can be assigned one and only one integer from $0$ through $k!-1$. Even better, the digits of that address naturally obey changing bounds: the first digit has only one choice, the next has two, the next three, and so on.

This is the factorial number system, and its relationship with permutations is more than a coincidence of counting. There is a canonical, reversible classification connecting bounded factorial digits, ordinary integer ranks, and rearrangements. The digits do not merely count the right number of possibilities. Their weighted value is exactly the rank of the corresponding permutation.

That fact turns a combinatorial universe into a navigable landscape. It explains why permutations can be stored compactly, generated without repetition, sampled uniformly, and broken apart recursively.

## Digits whose bases keep changing

Ordinary decimal notation uses powers of ten. A number such as $407$ means

$$
4\cdot 10^2+0\cdot 10^1+7\cdot 10^0.
$$

Every decimal digit lies between $0$ and $9$. Factorial notation changes the place values and also changes the allowed digit at each place.

A factorial code of length $k$ is a sequence

$$
(c_0,c_1,\ldots,c_{k-1})
$$

in which

$$
0\le c_i<i+1.
$$

Thus $c_0$ must be $0$, $c_1$ may be $0$ or $1$, and $c_2$ may be $0$, $1$, or $2$. The numerical value of the code is

$$
V(c)=\sum_{i=0}^{k-1}c_i i!.
$$

For example, the code $(0,1,2,3)$ has value

$$
0\cdot0!+1\cdot1!+2\cdot2!+3\cdot3!=23.
$$

That is the final rank available at length $4$, because $4!-1=23$.

The changing digit bounds make the arithmetic fit perfectly. There are

$$
1\cdot2\cdot3\cdots k=k!
$$

possible codes. There are also $k!$ permutations of $k$ distinct objects. But equal population sizes alone do not tell us which code belongs to which permutation. The deeper result constructs a reversible bridge.

## The first lock: every code fits below $k!$

The Range Theorem says that every length-$k$ factorial code satisfies

$$
0\le V(c)<k!.
$$

The key is recursive. Separate the final digit $c_k$ of a length-$(k+1)$ code from its lower digits. If the lower part has value $r$, then

$$
V(c)=c_k k!+r,
$$

where $0\le c_k\le k$ and $0\le r<k!$. Therefore

$$
V(c)\le k\,k!+(k!-1)=(k+1)!-1.
$$

So factorial evaluation always lands among exactly the integers $0,1,\ldots,k!-1$.

This resembles the familiar statement that a three-digit decimal numeral lies below $1000$, but the mechanism is more finely tuned: each new digit contributes a multiple of $k!$, and its allowed values supply exactly $k+1$ blocks of size $k!$.

## The second lock: no two codes collide

A useful address system cannot send two homes to the same address. The Uniqueness Theorem states that if two factorial codes $c$ and $d$ have the same value, then every corresponding digit agrees:

$$
V(c)=V(d)\quad\Longrightarrow\quad c=d.
$$

Again, the recursive block structure does the work. Write

$$
V(c)=c_k k!+r,
\qquad
V(d)=d_k k!+s,
$$

with $0\le r,s<k!$. The intervals associated with different leading digits do not overlap. Equality forces $c_k=d_k$, and then it forces $r=s$. Repeating the argument on the lower digits proves total agreement.

Together, range and uniqueness already give a remarkable classification. There are $k!$ codes, each yields a distinct integer below $k!$, and there are exactly $k!$ such integers. Consequently factorial evaluation is a bijection between length-$k$ codes and the rank set

$$
\{0,1,\ldots,k!-1\}.
$$

Every rank has one and only one factorial expansion with the prescribed bounds.

## From a rank to a rearrangement

Now comes the combinatorial heart of the story. A permutation of $k+1$ objects can be described by two pieces of information:

1. the selected position of one distinguished object, with $k+1$ choices; and
2. a permutation of the remaining $k$ objects, with $k!$ choices.

This gives the familiar recurrence

$$
(k+1)!=(k+1)k!,
$$

but it also gives an algorithm. Given a rank $n$ below $(k+1)!$, divide it into a quotient and remainder:

$$
n=qk!+r,
\qquad 0\le q<k+1,
\qquad 0\le r<k!.
$$

Use $q$ to choose where the distinguished object goes, and use $r$ recursively to arrange the remaining objects. At length zero there is one empty arrangement, so the recursion starts without ambiguity.

The Recursive Permutation Ranking Theorem states that this procedure is a bijection between the integers below $k!$ and the permutations of $k$ objects. Each recursive insertion is reversible: remove the distinguished object to recover its position, then rank what remains.

Combining this bijection with factorial evaluation yields the Factorial-Code Classification Theorem:

> For every natural number $k$, length-$k$ factorial codes are in canonical one-to-one correspondence with permutations of $k$ objects. Under this correspondence, the permutation's numerical rank is exactly $V(c)=\sum_{i=0}^{k-1}c_i i!$.

“Canonical” matters here. We are not arbitrarily pairing two sets of equal size. The arithmetic decomposition into quotient and remainder mirrors the combinatorial decomposition into a selected position and a smaller permutation.

## A small universe you can hold in your hand

For $k=4$, there are $4!=24$ codes and $24$ permutations. Consider rank $17$. Repeated factorial division gives

$$
17=2\cdot3!+5,
$$

$$
5=2\cdot2!+1,
$$

$$
1=1\cdot1!+0.
$$

Its ascending factorial digits are therefore $(0,1,2,2)$, since

$$
17=0\cdot0!+1\cdot1!+2\cdot2!+2\cdot3!.
$$

To interpret the same rank as a permutation, start with the ordered list $[0,1,2,3]$. In the conventional selection version of unranking, read the factorial digits from the largest place downward and repeatedly choose an indexed item from the remaining list. The digits $2,2,1,0$ select $2$, then $3$, then $1$, then $0$, producing $[2,3,1,0]$. Running the procedure backward reconstructs the same digits and rank.

This concrete selection convention is a familiar realization of the recursive principle. Different choices about whether one inserts a distinguished largest element or selects from an ordered pool alter the visible digit orientation, but not the central classification: bounded factorial digits, ranks below $k!$, and permutations carry the same information.

## Existence, uniqueness, and equality

The classification has several immediate consequences, each useful in its own right.

The Unique Representation Theorem says that every permutation of $k$ objects has exactly one factorial code. There are no missing permutations and no duplicate encodings.

The Code Equality Criterion says that two codes represent the same permutation exactly when all their digits agree. This is stronger than a counting observation: equality of complex rearrangements reduces to equality of short bounded coordinates.

The Rank Equality Criterion says that two classified permutations agree exactly when their code values agree:

$$
\sigma_c=\sigma_d
\quad\Longleftrightarrow\quad
V(c)=V(d).
$$

Finally, the Enumeration Corollary recovers the classical count: the number of permutations of $k$ objects is $k!$. Here the factorial is not only the answer to a multiplication argument; it is the size of an explicit address space.

The first few populations are

$$
1,1,2,6,24,120
$$

for lengths $0,1,2,3,4,5$. These are simultaneously counts of factorial codes, valid ranks, and permutations.

## Why this coordinate system matters

Permutation ranking is a practical technology. A permutation stored as a list of $k$ labels requires many entries. Its rank is a single integer below $k!$, while its factorial digits provide a structured mixed-radix representation. Databases can index arrangements; search procedures can divide a permutation space into contiguous rank intervals; simulations can draw a uniformly random integer below $k!$ and unrank it to obtain a uniformly random permutation.

The recursive decomposition also supports parallel work. If ranks are grouped by their highest factorial digit, the whole space splits into $k$ equal blocks, each containing $(k-1)!$ permutations. A worker can receive one block, fix the first selection, and explore the rest independently.

There are conceptual applications too. Inversions measure how far a permutation departs from sorted order. Conventional Lehmer digits count suitable inversions, making factorial coordinates a bridge between arithmetic rank and geometric disorder. The sum of those digits is expected to control parity: even and odd permutations alternate according to whether that sum is even or odd. Carrying in factorial arithmetic then becomes a precise question about how neighboring permutations change.

## Order inside disorder

A permutation is often introduced as the purest symbol of choice: take $k$ objects and put them in any order. The factorial number system reveals that these choices are layered rather than amorphous. At one stage there are $k$ possibilities, at the next $k-1$, and eventually only one. The product of those shrinking decisions is $k!$, while the weighted digits record the same decision tree as one integer.

The resulting theorem is both structural and algorithmic. Every legal factorial code stays in range. Different codes have different values. Every value below $k!$ determines one permutation. Every permutation returns one code. Arithmetic rank and combinatorial arrangement coincide.

So the next time a deck is shuffled, imagine not just one ordering among many, but one exact point on a factorial number line. Disorder has an address—and factorial digits know how to find it.
