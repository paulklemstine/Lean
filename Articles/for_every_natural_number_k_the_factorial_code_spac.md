# When Counting Codes Refuse to Become Coordinates

## The seduction of factorial digits

Our ordinary decimal notation hides a remarkable engineering decision: every position has the same radix. The units place counts in powers of $10^0$, the tens place in powers of $10^1$, and so on. But positional notation need not use one fixed base. A mixed-radix system may change its alphabet from one position to the next. Clocks already do this: seconds roll over after $60$, minutes after $60$, and hours after $24$.

The factorial number system is one of the purest variable-base systems. Its place values are

$$
0!=1,\quad 1!=1,\quad 2!=2,\quad 3!=6,\quad 4!=24,\ldots,
$$

and the digit multiplying $i!$ may be any integer from $0$ through $i$. Thus a code of length $k$ is a tuple

$$
(c_0,c_1,\ldots,c_{k-1})\qquad\text{with}\qquad 0\le c_i\le i,
$$

whose value is

$$
V_k(c)=\sum_{i=0}^{k-1}c_i i!.
$$

The first digit is forced to be $0$, the next has two choices, the next three, and so forth. Consequently there are

$$
1\cdot2\cdot3\cdots k=k!
$$

valid codes of length $k$. Even better, they represent exactly the integers from $0$ to $k!-1$, with no repetition. This is the Factorial Representation Theorem: **every integer $n$ satisfying $0\le n<k!$ has a unique expansion $n=\sum_{i<k}c_i i!$ with $0\le c_i\le i$.**

This notation has practical bite. Its digits are closely related to the successive choices used to rank permutations. It also makes division by changing radices natural: extract the $i$-th digit by a quotient-and-remainder step at radix $i+1$. Yet a deceptively simple question reveals that counting objects is not the same as respecting their algebra.

## The tempting product

Because the $i$-th digit has $i+1$ possible values, one may view it as a residue modulo $i+1$. Ignoring the trivial one-element factor, codes of length $k$ then look like the set

$$
\mathbb Z/2\mathbb Z\times\mathbb Z/3\mathbb Z\times\cdots\times\mathbb Z/k\mathbb Z.
$$

This product has $2\cdot3\cdots k=k!$ elements, exactly as many as $\mathbb Z/k!\mathbb Z$. Could factorial digits therefore be a version of Chinese-remainder coordinates? Could addition and multiplication be performed independently in each digit?

At $k=3$, the answer is yes. Since $3!=6$ and $2$ and $3$ are coprime, the Chinese Remainder Theorem gives a ring isomorphism

$$
\mathbb Z/6\mathbb Z\cong \mathbb Z/2\mathbb Z\times\mathbb Z/3\mathbb Z,
$$

sending a residue $n$ to $(n\bmod 2,n\bmod 3)$. This is not merely a pairing of six objects with six objects. It preserves addition, multiplication, zero, and one.

Success at this small stage is dangerous: it encourages a false pattern. At $k=4$, both candidate spaces still contain $24$ elements,

$$
\mathbb Z/24\mathbb Z
\qquad\text{and}\qquad
\mathbb Z/2\mathbb Z\times\mathbb Z/3\mathbb Z\times\mathbb Z/4\mathbb Z.
$$

There are certainly bijections between them. Factorial evaluation itself supplies one at the level of finite sets. But no bijection between them can preserve addition.

## The twelve-step obstruction

To see the failure, do not inspect multiplication. Look at repeated addition.

In an additive group, say that a positive integer $m$ annihilates an element $x$ if adding $x$ to itself $m$ times gives zero. Every element of $mathbb Z/2\mathbb Z$ is annihilated by $2$, every element of $\mathbb Z/3\mathbb Z$ by $3$, and every element of $\mathbb Z/4\mathbb Z$ by $4$. Therefore $12$, a common multiple of $2$, $3$, and $4$, annihilates every triple in their product:

$$
12(a,b,c)=(0,0,0).
$$

But in $\mathbb Z/24\mathbb Z$, twelve copies of $1$ do not vanish:

$$
12\cdot 1=12\not\equiv0\pmod{24}.
$$

Suppose an additive isomorphism existed. It would send $1$ to some triple $x$. Since $12x=0$, preservation of repeated addition would force the image of $12\cdot1$ to be zero. Injectivity would then force $12\cdot1=0$ back in $\mathbb Z/24\mathbb Z$, contradicting the displayed calculation.

This proves the Stage-Four Obstruction Theorem: **there is no additive-group isomorphism between $\mathbb Z/24\mathbb Z$ and $\mathbb Z/2\mathbb Z\times\mathbb Z/3\mathbb Z\times\mathbb Z/4\mathbb Z$. Hence there is no ring isomorphism either.**

The argument is short because it finds the right invariant: the exponent of a finite abelian group, meaning the smallest positive integer that annihilates every element. The product has exponent

$$
\operatorname{lcm}(2,3,4)=12,
$$

whereas the cyclic group $\mathbb Z/24\mathbb Z$ has exponent $24$. Cardinality sees only how many elements there are. Exponent sees how addition moves among them.

## Why carries matter

What goes wrong with digitwise addition? Take factorial digits at positions with radices $2$, $3$, and $4$. If a digit reaches its radix, it cannot simply wrap to zero without affecting its neighbor. The local identity

$$
(i+1)i!=(i+1)!
$$

says that an overflow of $i+1$ units at position $i$ becomes one unit at position $i+1$. Carries couple adjacent positions.

Residue products deliberately erase that coupling. In the product of residue rings, each coordinate wraps independently. A factorial code instead belongs to a nested positional system: lower positions feed higher positions. The two spaces can be equally large while possessing different internal motion.

A small numerical example makes the distinction vivid. At length four, $11$ has factorial expansion

$$
11=1\cdot3!+2\cdot2!+1\cdot1!+0\cdot0!,
$$

so its high-to-low digits are $(1,2,1,0)$. Adding $1$ gives

$$
12=2\cdot3!+0\cdot2!+0\cdot1!+0\cdot0!,
$$

with digits $(2,0,0,0)$. Several lower digits reset and their carries cascade. Coordinatewise modular addition cannot reproduce that transformation, because it has no channel through which one coordinate can alter another.

This distinction appears far beyond number notation. Computer arithmetic is built around carry propagation. Calendar calculations use nested units rather than independent clocks. Hierarchical counters, combinatorial ranking schemes, and data encodings often possess the same feature: their states form a rectangular-looking set, but their natural operation crosses coordinate boundaries.

## The general mixed-radix principle

Factorial notation is a special case of a broader construction. Choose radices $b_0,b_1,\ldots$ with $b_i\ge1$, define place values

$$
P_0=1,\qquad P_i=\prod_{j=0}^{i-1}b_j,
$$

and allow digits $0\le c_i<b_i$. The mixed-radix value through length $k$ is

$$
M_k(c)=\sum_{i=0}^{k-1}c_iP_i.
$$

For factorial radices $b_i=i+1$, the place value is exactly

$$
P_i=1\cdot2\cdots i=i!,
$$

so mixed-radix evaluation becomes factorial evaluation. The general digit condition $c_i<b_i$ becomes $c_i\le i$. The general uniqueness principle therefore yields factorial uniqueness: **if two valid factorial codes of length $k$ have the same value, then all their first $k$ digits agree.**

This bridge explains both the power and the limitation of the notation. The product of local alphabet sizes establishes a perfect classification of a finite interval. It does not establish a product decomposition of algebraic operations.

## A tour through the first four stages

At length one, there is only the forced digit $c_0=0$, so the entire code space represents zero. At length two, the digit $c_1$ may be $0$ or $1$, producing the two values $0$ and $1$. There is only one nontrivial residue factor, $\mathbb Z/2\mathbb Z$, so no conflict can arise.

Length three is the exceptional sweet spot. Its six codes have digits $(c_0,c_1,c_2)$ with $c_0=0$, $c_1\in\{0,1\}$, and $c_2\in\{0,1,2\}$. The factors $2$ and $3$ are coprime, so every pair of residues selects exactly one class modulo $6$. For example, the conditions

$$
n\equiv1\pmod2,\qquad n\equiv2\pmod3
$$

select $n\equiv5\pmod6$. Here the residue grid genuinely supports the same ring arithmetic as the cyclic source.

Length four introduces four choices for $c_3$ and expands the state space to $24$. Yet the new modulus $4$ is not new arithmetic information independent of modulus $2$: knowing a number modulo $4$ already determines it modulo $2$. The raw product still counts the modulo-$2$ choice and the modulo-$4$ choice as separate slots. That duplication causes no trouble for counting, because $2\cdot3\cdot4=24$, but it changes the orders of elements under addition. The transition from three to four positions is therefore the first place where a rectangular coordinate box and a cyclic arithmetic system visibly part company.

This low-stage tour also shows why examples alone can mislead. A conjecture tested only through $k=3$ looks flawless. The first composite radix that overlaps an earlier radix supplies the counterexample.

## What the failure teaches

The Chinese Remainder Theorem succeeds when its moduli are pairwise coprime. Factorial radices are not. At stage four, the factors $2$ and $4$ overlap; they share the prime $2$. This overlap is exactly what makes the least common multiple smaller than the product:

$$
\operatorname{lcm}(2,3,4)=12<24=2\cdot3\cdot4.
$$

The likely broad pattern is now visible. For larger stages, the direct product of radix residues should continue to have a smaller additive exponent than the cyclic group of order $k!$. The correct multiplicative coordinates are instead associated with the coprime prime-power factors of $k!$. Those are genuine Chinese-remainder components, but they are not the factorial digits themselves.

There is also a more faithful structural picture. The ideals generated by

$$
1!,2!,3!,\ldots
$$

form a nested filtration. Each new factorial digit chooses a representative in one successive layer. Such choices need not split the layer into an independent algebraic factor. Carries are the visible trace of that nonsplitting.

In the infinite setting, this becomes even richer. Truncations modulo $k!$ fit together because $k!$ divides $(k+1)!$. Their inverse limit can support an infinite factorial expansion, but addition must be normalized by carries. The stage-four obstruction already rules out the naive dream of coordinatewise addition on raw residues.

The moral is simple and broadly useful: a coordinate system can classify states perfectly without decomposing their dynamics. Factorial digits count exactly right. They reconstruct every number in the relevant interval uniquely. At length three they even coincide with true residue coordinates. But from length four onward, the carry is not a nuisance to be optimized away. It is the algebraic structure itself, announcing that the positions belong to one connected arithmetic machine.