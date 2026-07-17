# The Hidden Product Inside a Zigzag

## How record blocks turn alternating permutations into a modular counting machine

A permutation is usually imagined as disorder: take the numbers from $1$ to $m$, shuffle them, and ask what patterns survive. But one family of permutations behaves less like a shuffled deck and more like a mountain range. Its entries must fall, rise, fall, rise:

$$
a_1>a_2<a_3>a_4<\cdots.
$$

These are called **down-up permutations**, one of the two standard orientations of alternating permutations. Their enumeration is classical. The number of down-up permutations of $m$ symbols is the Euler zigzag number $E_m$. The first few values are

$$
E_1=1,\qquad E_2=1,\qquad E_3=2,\qquad E_4=5,\qquad E_5=16.
$$

The intrigue begins when one asks not only how many zigzags exist, but how their high points set records.

For a down-up permutation of even length $2n$, the odd positions $a_1,a_3,\ldots,a_{2n-1}$ are the peaks. Read this peak word from left to right and mark each entry larger than every peak before it. Such an entry is a **left-to-right maximum**, or record. Cut the peak word immediately before every record except the first. The lengths of the resulting factors form a composition of $n$: an ordered list of positive integers whose sum is $n$. This is the permutation’s **record composition**.

For example, if the successive peaks have relative pattern

$$
5,2,7,4,9,8,
$$

then the records are $5$, $7$, and $9$. Cutting before the latter two gives blocks

$$
(5,2)\mid(7,4)\mid(9,8),
$$

so the record composition is $(2,2,2)$. Order matters: $(1,2)$ and $(2,1)$ describe different record histories even though they determine the same unordered partition.

This record statistic suggests a striking product. Given a composition

$$
\alpha=(\alpha_1,\ldots,\alpha_\ell),
$$

write

$$
s_j=\alpha_1+\cdots+\alpha_j.
$$

The associated weight is

$$
W(\alpha)=\prod_{j=1}^{\ell}
\binom{2s_j-1}{2\alpha_j-1}E_{2\alpha_j-1}.
$$

At first glance this formula is mysterious. Why should a global record pattern break into binomial coefficients and odd Euler numbers? A finite assembly model makes the answer transparent.

## A block is a choice plus a zigzag

Imagine constructing a record history one block at a time. Suppose $s$ parts have already been processed and the next part has size $a$. The new stage contains two independent decisions.

First, choose $2a-1$ labels from an available set of size $2(s+a)-1$. There are

$$
\binom{2(s+a)-1}{2a-1}
$$

ways to do this. Second, arrange those chosen labels in a down-up pattern of odd length $2a-1$. There are $E_{2a-1}$ possibilities. The product

$$
\binom{2(s+a)-1}{2a-1}E_{2a-1}
$$

is therefore the number of possibilities at that stage.

An **assembly of type $\alpha$ starting after $s$ processed parts** is the sequence of these stagewise choices. The empty composition has one empty assembly. For a nonempty composition $(a,\beta)$, an assembly consists of:

1. a choice of $2a-1$ objects from $2(s+a)-1$ objects;
2. a down-up permutation of the selected $2a-1$ objects; and
3. an assembly of type $\beta$ starting after $s+a$ processed parts.

This definition contains the multiplication principle in its bones. Every first-stage choice can be paired with every valid continuation.

### The Assembly Product Theorem

For every list $\alpha=(\alpha_1,\ldots,\alpha_\ell)$ of nonnegative integers and every starting value $s$, the number of assemblies of type $\alpha$ starting at $s$ is

$$
W_s(\alpha)=\prod_{j=1}^{\ell}
\binom{2(s+s_j)-1}{2\alpha_j-1}E_{2\alpha_j-1},
$$

where $s_j=\alpha_1+\cdots+\alpha_j$ and an empty product equals $1$. In particular, at $s=0$ this is $W(\alpha)$.

The proof is a clean induction on the number of parts. There is exactly one empty assembly. For $(a,\beta)$, count the label choice, multiply by the $E_{2a-1}$ internal zigzags, and then multiply by the number of continuations, now based at $s+a$. Repeating this step yields the displayed product.

For genuine record compositions the parts are positive, so no edge-case interpretation is needed. The slightly broader statement is useful algebraically because it mirrors the recursive construction exactly.

## Why cutting works

The product is more than a closed formula: it remembers where a composition can be cut. Let $\alpha$ and $\beta$ be two lists, let $|\alpha|$ denote the sum of the parts of $\alpha$, and let $\alpha\mathbin{\|}\beta$ denote concatenation. Then the **Concatenation Factorization Theorem** says

$$
W_s(\alpha\mathbin{\|}\beta)
=W_s(\alpha)W_{s+|\alpha|}(\beta).
$$

The shift by $|\alpha|$ is essential. The suffix does not begin in a fresh universe; it begins after all parts in the prefix have been processed. This is the combinatorial analogue of carrying state through a pipeline.

At $s=0$,

$$
W(\alpha\mathbin{\|}\beta)
=W(\alpha)W_{|\alpha|}(\beta).
$$

Consequently, the number of assemblies factors at every block boundary. This locality is exactly what one hopes for when ordered record data are encoded in a noncommutative setting: exchanging two blocks can change the partial sums, and therefore can change the coefficient.

Appending one final part $a$ gives the particularly useful recurrence

$$
W(\alpha\mathbin{\|}(a))
=W(\alpha)
\binom{2(|\alpha|+a)-1}{2a-1}E_{2a-1}.
$$

Thus a table of weights can be built incrementally. No previous product has to be recomputed.

## Tiny cases, large clues

A one-part composition has no genuine record cut. The binomial coefficient is

$$
\binom{2n-1}{2n-1}=1,
$$

so the **Singleton Theorem** reads

$$
W((n))=E_{2n-1}.
$$

The coefficient is simply the number of odd-length zigzags internal to the lone block.

The smallest multi-block example is $(1,1)$. Since $E_1=1$,

$$
W((1,1))=inom{1}{1}E_1\binom{3}{1}E_1=3.
$$

This value already shows why order-sensitive block data are richer than an ordinary partition statistic. For comparison,

$$
W((1,2))=inom{1}{1}E_1\binom{5}{3}E_3=20,
$$

whereas

$$
W((2,1))=inom{3}{3}E_3\binom{5}{1}E_1=10.
$$

The two compositions have the same parts, but their weights differ by a factor of two. The running total $s_j$ makes chronology mathematically visible.

This asymmetry points toward noncommutative symmetric functions. Ordinary symmetric functions naturally forget the order of parts; noncommutative analogues retain it. The assembly weights therefore have exactly the right behavioral signature for coefficients indexed by compositions rather than partitions. Establishing a full symmetric-function identity requires defining the relevant algebra and matching its basis coefficients, but the finite product mechanism is already isolated here.

## A compact language for huge numbers

The product formula also changes how one computes. Directly listing every down-up permutation quickly becomes impractical: there are already $E_9=7936$ zigzags on nine letters, and the numbers accelerate sharply thereafter. An assembly weight needs no such list. One computes the required odd Euler numbers, walks through the composition from left to right, and updates two quantities: the running sum and the running product.

For a current state $s$ and next part $a$, the update is

$$
s\longleftarrow s+a,
\qquad
W\longleftarrow W\binom{2s-1}{2a-1}E_{2a-1}.
$$

After the final part, $W$ is the desired assembly count. This is an exact algorithm, not an approximation or simulation. Its control flow is linear in the number of blocks once the Euler numbers are available.

The Euler numbers themselves can be built by the Entringer triangle, a triangular table formed by repeated addition. Starting with $E_0=1$, it produces

$$
1,1,1,2,5,16,61,272,1385,7936,\ldots.
$$

Thus the entire calculation can be performed with integer arithmetic. That matters because the product’s factors are combinatorial counts: rounding would erase their meaning.

There is also a sampling interpretation. At each stage, choose one admissible label subset and one odd zigzag, then move to the next stage. Choosing each local option uniformly and independently produces a uniform random assembly because every assembly corresponds to exactly one chain of local decisions. If a future bijection identifies assemblies with alternating permutations of a fixed record composition, this procedure will become a direct sampler for that conditioned permutation class.

## What the model does—and what remains

The assembly theorem proves, without ambiguity, that the proposed product counts a concrete finite family assembled from label selections and odd alternating permutations. It proves the empty case, the full product, factorization across cuts, the final-block recurrence, the singleton reduction, and the value $W((1,1))=3$.

A further combinatorial bridge is needed to identify these assemblies directly with even-length alternating permutations having a specified record composition. Such a bridge must take a permutation, cut its peak word at noninitial records, and recover—bijectively—the successive label choices and odd zigzags of the assembly. Once that bijection is supplied, the product becomes the desired enumeration of the original record classes. Likewise, passing from ordered compositions to unordered record partitions requires summing over rearrangements, and the noncommutative-symmetric-function interpretation requires its own coefficient theorem.

This distinction is fruitful rather than merely cautious. It separates the numerical engine from the encoding problem. The engine is simple: choose labels, arrange a local zigzag, update the running sum, repeat. The encoding problem asks why a global alternating permutation decomposes into exactly those local data.

That pattern appears far beyond permutation theory. Dynamic programming separates a state update from the meaning of the state. Statistical mechanics factors a large configuration into local choices while tracking boundary conditions. Data compression divides a stream into blocks but must preserve enough context to decode the whole. Here the carried state is only the partial sum $s$, yet it records precisely how large the next label pool must be.

The deepest lesson of the product is therefore architectural. A record composition is global history written as ordered local blocks. Euler numbers count the shape inside each block; binomial coefficients count the resources assigned to it; partial sums transmit the past into the future. Once those three roles are separated, the formidable-looking formula becomes inevitable:

$$
\text{global count}
=
\prod_{\text{blocks}}
\bigl(\text{label choices}\bigr)
\bigl(\text{local zigzags}\bigr).
$$

A zigzag may look erratic, but its records leave a disciplined trail.