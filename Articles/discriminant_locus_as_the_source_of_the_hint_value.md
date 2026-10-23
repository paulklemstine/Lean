# Two Mirrors and a Conic: Where the Information in a Factor Pair Really Lives

*A conjecture said that all the information lost when you multiply two numbers comes from forgetting their order. It was wrong, and how it fails shows that the loss splits cleanly into two parts.*

---

## A game with two hidden numbers

Imagine a referee who holds two secret numbers, $P$ and $Q$, which are residues modulo some odd prime $q$, the remainders left after dividing by $q$. Thousands of these pairs make up a crowd, and each member of the crowd also carries a **label**. The label might be "this pair came from a weak key", or "this person is in group A", or any other yes-or-no tag. The question is how much the hidden numbers tell you about the label.

The answer depends on how much of the pair you get to see. Here are two ways of looking at it.

* The **residue view** shows you everything, repackaged as the sum and the gap:
$$s = P + Q, \qquad d = Q - P .$$
Since $q$ is odd we can divide by $2$, so $(s,d)$ and $(P,Q)$ carry exactly the same information: $P = (s-d)/2$ and $Q = (s+d)/2$.

* The **product view** shows you only
$$N = PQ = \frac{s^2 - d^2}{4}.$$

This is the situation in factoring. A product is public and its factors are hidden. The **hint value** of a labelling is the number of bits about the label that you lose when the full pair is replaced by its product:
$$\text{hint value} \;=\; I(L;\,s,d) \;-\; I(L;\,N),$$
where $I(L;X)$ is the *mutual information* between the label $L$ and the observation $X$, measured in bits over the crowd with every individual weighted equally. A hint value of one bit means the factors carry a whole yes/no answer about the label that the product has completely forgotten.

## The tempting conjecture

There is one obvious thing that multiplication forgets. Since $PQ = QP$, the product cannot tell $(P,Q)$ from $(Q,P)$. In the residue view, swapping the factors leaves $s$ alone and flips the sign of the gap:
$$(s,d) \;\longmapsto\; (s,-d).$$
Geometers would put it like this. The map
$$(s,d) \;\longmapsto\; (s,d^2)$$
is a **double cover**. Each point downstairs has two points upstairs, $(s,d)$ and its mirror image $(s,-d)$. The one exception is where the mirrors coincide, which is $d = 0$, or equivalently $s^2 = 4N$, the discriminant of the quadratic $X^2 - sX + N$ whose roots are $P$ and $Q$. That exceptional set is called the **ramification locus**. The product $N$ is computed from the downstairs point, so it cannot see which of the two mirror branches you are on.

This suggests a conjecture: the order of the factors is all that multiplication destroys. If a label already ignores the mirror, meaning it gives the same answer to $(s,d)$ and $(s,-d)$, then it should lose nothing when you pass to the product, except perhaps at the ramification locus, where the two branches merge. Stated precisely:

> **Conjecture.** If the labels are invariant under the branch swap $d \mapsto -d$, then the hint value of the crowd equals the hint value of the sub-crowd sitting on the ramification locus $d = 0$.

The conjecture is clean and geometric, and it would make the hint value an invariant of a degree-two cover. It is false.

## Two individuals are enough

Work modulo $5$. The crowd has two members:

| individual | $(P,Q)$ | $(s,d)$ | $N = PQ$ | label |
|---|---|---|---|---|
| first | $(1,2)$ | $(3,1)$ | $2$ | $0$ |
| second | $(3,4)$ | $(2,1)$ | $12 \equiv 2$ | $1$ |

Both products equal $2$, so the product view sees one undivided crowd and tells you nothing about the label. The residue view separates the two individuals completely, and with them the label, so it is worth exactly one bit. **The hint value is one bit.**

The labels are swap-invariant, and trivially so: the two individuals have different sums, so neither is the other's mirror image, and swap invariance demands nothing. Neither individual has $d = 0$, so the ramified sub-crowd is empty and its hint value is $0$.

So the left side of the conjectured equation is $1$ and the right side is $0$. The label ignores the mirror completely and still carries a full bit that the product forgets.

## Where the bit went

The bit was lost because multiplication does more than forget the order of the factors. Look at what happens to a point $(s,d)$ on its way to $N$:
$$(s,d) \;\xrightarrow{\ \text{double cover}\ }\; (s,\, d^2) \;\xrightarrow{\ \text{conic map}\ }\; \frac{s^2 - d^2}{4} = N .$$

The first arrow merges at most two points, a point and its mirror. The second arrow is much more destructive. Its fibres are the solution sets of
$$s^2 - e = 4N,$$
which, once $e=d^2$ is pulled back upstairs, are the **conics** $s^2 - d^2 = 4N$. Over $\mathbb{Z}/q$ such a conic has roughly $q$ points, not two. All the pairs $(P,Q)$ with $PQ = N$ lie on the same conic, no matter what their sums are. The conjecture accounted for the first, gentle step and missed the second.

This gives the main theorem of the work: a decomposition of the hint value into the information lost at each arrow.

> **The Double Cover Decomposition.** Define the **branch value**
> $$B \;=\; I(L;\,s,d) \;-\; I(L;\,s,d^2)$$
> and the **conic value**
> $$C \;=\; I(L;\,s,d^2) \;-\; I(L;\,N).$$
> Then
> $$\text{hint value} \;=\; B + C, \qquad B \ge 0, \qquad C \ge 0.$$

The equation is a telescoping sum, so it is immediate. What gives it content is the interpretation of each piece. Both pieces are nonnegative because information can only be lost when a view is coarsened: $(s,d^2)$ is computed from $(s,d)$, and $N$ is computed from $(s,d^2)$.

There is also an algebraic reading of the middle view. Knowing $(s, d^2)$ is exactly the same as knowing $(s, N)$, because $d^2 = s^2 - 4N$. By Vieta's formulas, knowing the sum and the product of two numbers is the same as knowing the two numbers *as an unordered pair*. So:

* the **branch value** is what the *order* of the factors tells you, once you know them as an unordered pair;
* the **conic value** is what the *sum* tells you, once you know the product.

## The corrected theorem

With the decomposition available, the conjecture can be replaced by a true statement.

> **Theorem (swap-invariant labels).** If the labels are invariant under the branch swap, then the branch value is zero, and the whole hint value is conic:
> $$\text{hint value} \;=\; I(L;\,s,N) \;-\; I(L;\,N).$$

The proof rests on a principle about coarsening. Suppose a view is coarsened, and two different values of the view are merged only when the label is already constant on everything being merged. Then nothing about the label is lost. The double cover merges $(s,d)$ only with its mirror $(s,-d)$, and a swap-invariant label cannot tell those apart. So the branch value vanishes. The intuition behind the conjecture was correct at the level of the cover. Its mistake was to assume that the cover is the whole story.

The proof also gives a characterisation: a label that depends only on the residue view is swap-invariant exactly when it can be written as a function of $(s, d^2)$, which is the same as a function of the unordered factor pair.

## One bit, and only off the mirror's edge

How large can the branch value be? Each fibre of a double cover has at most two points, and distinguishing two possibilities never takes more than one bit. Making this precise uses the *log-sum inequality*, applied fibre by fibre, and it gives two bounds:

> **Theorem (one-bit law).** For every labelling, $B \le 1$ bit.

> **Theorem (the ramification locus carries no branch information).** Let $S$ be any set of individuals containing everyone who lies *off* the locus $d = 0$ *and* whose mirror point $(s,-d)$ is occupied by someone in the crowd. Then
> $$B \;\le\; \frac{|S|}{|\text{crowd}|}.$$

The second bound says that branch information exists only where the two branches are both present. If an individual's mirror point is unoccupied, there is nothing to distinguish them from. An individual on $d = 0$ is their own mirror, so they also contribute nothing. Two consequences follow:

* A crowd with no occupied mirror pairs has branch value $0$ for *every* labelling.
* A crowd that lies entirely on the ramification locus $d=0$ has hint value equal to its conic value. This reverses the conjecture: the ramification locus contributes **no** branch information at all.

All of these bounds are attained. Modulo $5$, take the two individuals $(1,2)$ and $(2,1)$, which are a factor pair and its swap, and label them $0$ and $1$. They share a sum, a product, and a value of $d^2$, and their gaps are $1$ and $-1$. The branch value is exactly $1$ bit and the conic value is $0$. For the other extreme, take $(1,1)$ and $(4,4)$, both with $d = 0$ and both with product $1$, and label them differently. Their sums are $2$ and $3$, which are negatives of each other modulo $5$ and so both satisfy $s^2 = 4$. The hint value is one full bit and all of it is conic. On the ramification locus, the conic value records exactly the sign of $s$.

## How large are the two values in a typical crowd?

Take the "uniform battery" modulo $q$: one individual for each of the $q^2$ pairs $(P,Q)$. Let the label be the gap $d$ itself. A direct count gives branch value exactly $(q-1)/q$ bits, which is $0.8$ for $q=5$, about $0.857$ for $q=7$ and about $0.923$ for $q = 13$. The reason is that the fraction $(q-1)/q$ of the crowd lies off $d=0$, and each of those individuals has a mirror twin with the opposite label. In this example the split-fraction bound above holds with equality.

If the label is the sum $s$ instead, it is automatically swap-invariant, so the branch value is $0$ and everything is conic. The conic value grows like $\log_2 q$ minus about one bit: roughly $1.62$ bits for $q=5$ and $2.82$ bits for $q=13$. This is the bulk of the hint value, and the conjecture had no place for it.

There is a small number-theoretic surprise too. Let the label be the *quadratic character* of the gap, that is, whether $d$ is a nonzero square modulo $q$. This label is swap-invariant exactly when $-1$ is a square modulo $q$, which happens when $q \equiv 1 \pmod 4$. In that case its branch value is $0$. When $q \equiv 3 \pmod 4$, the computation gives branch value $(q-1)/q$. The double cover is therefore sensitive to quadratic reciprocity.

## Why this matters

Hint values measure how much a hidden structure, here a factor pair, says about a property, once you are allowed to see only a summary of it, here the product. The double cover decomposition shows that this loss is not one undivided quantity. It has a geometric part and an arithmetic part:

* a **branch part**, at most one bit, coming from the Galois symmetry $P \leftrightarrow Q$ of the quadratic $X^2 - sX + N$, and supported only where both mirror branches are present;
* a **conic part**, possibly much larger, which measures how the label is spread over the points of the conic $s^2 - d^2 = 4N$, which is the same as measuring which *sum* goes with a given product.

The conjecture located all of the loss in the first part. The counterexample shows that the second part is real, can be large, and is the part that the arithmetic of conics controls. Because the information calculus behind the decomposition applies to any coarsening whose fibres are small, the same analysis extends to products of three or more factors. There the swap $P \leftrightarrow Q$ is replaced by the full symmetric group permuting the factors, and the one-bit law is expected to become a bound of $\log_2 k!$ bits.

---

### The results in one place

1. **Cover geometry.** Over a field of odd characteristic, the fibres of $(s,d) \mapsto (s,d^2)$ are exactly the mirror pairs $\{(s,d),(s,-d)\}$. The mirror fixes a point exactly when $d = 0$. The product $N=(s^2-d^2)/4$ factors through the cover, and two points have the same image under the cover exactly when they have the same sum and the same product.
2. **Factorisation.** A label that depends only on the residue view is swap-invariant if and only if it is a function of $(s,d^2)$, equivalently of the unordered factor pair.
3. **Decomposition.** The hint value equals the branch value plus the conic value, and both are nonnegative.
4. **Corrected theorem.** Swap-invariant labels have branch value $0$, so their hint value equals $I(L;s,N)-I(L;N)$.
5. **One-bit law and its refinement.** The branch value is at most $1$ bit, and at most the fraction of the crowd lying off $d = 0$ whose mirror is occupied. A crowd on the ramification locus has purely conic hint value.
6. **Counterexample.** Modulo $5$, the crowd $(1,2),(3,4)$ with labels $0,1$ is swap-invariant, has no individual on $d=0$, and has a hint value of one bit. So the ramification conjecture is false.
