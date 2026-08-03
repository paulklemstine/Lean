# Attention Without a Preferred Order

## Why a transformer can follow tokens as they move

A transformer begins with a peculiar act of collective comparison. Each token asks a question, every token advertises a key, and every token carries a value. The model compares each question with every key, turns those comparisons into positive weights, and blends the values accordingly. This is the attention mechanism behind modern language models and many systems for images, molecules, sets, and physical data.

But there is a structural question beneath the familiar formula. Suppose the tokens are merely relabeled. Does attention follow the relabeling exactly, or can the arbitrary choice of labels change the computation?

For ordinary scaled dot-product attention, the answer is exact: if queries, keys, and values are all permuted together, the outputs undergo precisely the same permutation. Nothing else changes. This property is called **permutation equivariance**. It is not an approximation, a statistical tendency, or a consequence of training. It is built into the mathematics.

That symmetry rests on several simpler facts. Softmax weights are strictly positive. Every row of weights sums to one. Constant values pass through unchanged. And layers with the same symmetry can be stacked without losing it. Together these results explain why attention naturally processes collections whose labels carry no intrinsic meaning.

## From comparisons to weighted averages

Consider a finite collection of tokens indexed by a set $I$. Let each query and key be a vector with coordinates indexed by a finite feature set $D$. For token $i$, write its query as $q_i$, its key as $k_i$, and its value as $v_i$. Values may have a different feature dimension from queries and keys.

Choose a positive scale $s$, usually $s=\sqrt{d}$ when query and key vectors have dimension $d$. The score comparing query $i$ with key $j$ is

$$
S_{ij}=\frac{q_i\cdot k_j}{s}
=\frac{1}{s}\sum_{a\in D}q_i(a)k_j(a).
$$

The corresponding softmax weight is

$$
W_{ij}=\frac{\exp(S_{ij})}{\sum_{\ell\in I}\exp(S_{i\ell})}.
$$

Finally, attention returns the weighted blend

$$
y_i=\sum_{j\in I}W_{ij}v_j.
$$

Each output feature is blended independently using the same row of weights. A query therefore determines not a single chosen token, but a probability distribution over all tokens.

Why is that distribution always legitimate? Exponentials are strictly positive, so every term $\exp(S_{ij})$ is positive. If the token set is nonempty, the denominator is a sum containing at least one positive term and is therefore positive. Consequently,

$$
W_{ij}>0.
$$

Moreover, the normalization was chosen so that

$$
\sum_{j\in I}W_{ij}
=\frac{\sum_{j\in I}\exp(S_{ij})}{\sum_{\ell\in I}\exp(S_{i\ell})}
=1.
$$

Thus every row of the attention matrix is a strictly positive probability vector. Attention is not merely linear in the values; for fixed queries and keys, it is a convex averaging operation.

## The relabeling experiment

Imagine three sensors named red, green, and blue. Their names are bookkeeping devices, not physical properties. If we rename them blue, red, and green while carrying along each sensor’s query, key, and value, a sensible aggregation rule should carry its outputs along in exactly the same way.

Let $\sigma:I\to I$ be any permutation. The permuted data are defined by placing the old token $i$ at the new position $\sigma(i)$. Equivalently,

$$
q'_r=q_{\sigma^{-1}(r)},\qquad
k'_r=k_{\sigma^{-1}(r)},\qquad
v'_r=v_{\sigma^{-1}(r)}.
$$

Now compare new positions $\sigma(i)$ and $\sigma(j)$. Their score is

$$
S'_{\sigma(i),\sigma(j)}
=\frac{q'_{\sigma(i)}\cdot k'_{\sigma(j)}}{s}
=\frac{q_i\cdot k_j}{s}
=S_{ij}.
$$

The numerator of the associated softmax weight is unchanged. Its denominator is also unchanged, because it sums the same collection of exponential scores in a different order. Finite sums do not depend on order. Hence

$$
W'_{\sigma(i),\sigma(j)}=W_{ij}.
$$

This is the weight-transport law: relabeling both axes of the attention matrix simply relabels its entries.

The output now follows immediately:

$$
\begin{aligned}
y'_{\sigma(i)}
&=\sum_{r\in I}W'_{\sigma(i),r}v'_r\\
&=\sum_{j\in I}W'_{\sigma(i),\sigma(j)}v'_{\sigma(j)}\\
&=\sum_{j\in I}W_{ij}v_j\\
&=y_i.
\end{aligned}
$$

We have reached the central result.

**Permutation Equivariance Theorem.** *For any finite token set, any simultaneous permutation of the query, key, and value token axes produces the same permutation of the attention output. In symbols, if $A$ denotes scaled dot-product softmax attention, then*

$$
A(\sigma q,\sigma k,\sigma v)=\sigma A(q,k,v).
$$

The word “equivariant” matters. Attention is not permutation invariant: the output is still token-indexed, so moving an input token moves the corresponding output. An invariant operation would erase token positions entirely and return the same object after every permutation. Equivariance is the more informative symmetry for sequence-to-sequence or set-to-set processing.

## Two useful consequences

The probability-row interpretation gives an immediate conservation law. Suppose every token carries exactly the same value vector $c$, although queries and keys may differ arbitrarily. Then

$$
y_i=\sum_j W_{ij}c
=\left(\sum_jW_{ij}\right)c
=c.
$$

**Constant-Preservation Theorem.** *On a nonempty token set, attention preserves any value tensor that is constant across token positions.*

This is a basic sanity check. Attention can redistribute existing variation, but it cannot manufacture variation from values that are identical everywhere.

There is also a compositional principle. Suppose two token-to-token maps $F$ and $G$ each commute with a permutation $\sigma$:

$$
F(\sigma x)=\sigma F(x),\qquad G(\sigma x)=\sigma G(x).
$$

Then

$$
(F\circ G)(\sigma x)
=F(G(\sigma x))
=F(\sigma G(x))
=\sigma F(G(x)).
$$

**Equivariant Composition Theorem.** *The composition of permutation-equivariant token maps is permutation equivariant.*

This theorem is the bridge from one attention layer to an architecture. Whenever each component respects the same token relabeling—attention, pointwise transformations, compatible normalization, or other equivariant operations—their stack respects it too.

## Where the symmetry matters

For language, token order usually matters, so transformers add positional information or use masks. Those additions deliberately break or restrict full permutation symmetry. Without positional encodings, attention sees a sentence as a labeled collection whose labels may be exchanged freely. With positional encodings, moving a word but not its positional signal changes the mathematical input, as it should.

In set learning, full equivariance is often exactly the desired bias. A point cloud has no canonical first point. Atoms in a molecule may be listed in any order. Sensors in a network may receive arbitrary database identifiers. An equivariant model ensures that such administrative choices cannot alter predictions except by the corresponding relabeling.

The positive, normalized weights matter as well. For each output coordinate, attention stays between the smallest and largest input value coordinates:

$$
\min_j v_j(b)\le y_i(b)\le \max_j v_j(b).
$$

This convex-hull observation follows from the proved positivity and row-sum laws. It offers geometric intuition: a single attention head, with queries and keys fixed, selects points inside the convex hull of the value vectors. The model’s expressive power arises from changing the weights with the input and from surrounding attention with additional transformations.

## What these results do—and do not—say

Exact equivariance is a structural theorem, not a universality theorem. It proves that attention preserves a symmetry, but it does not by itself prove that a chosen transformer architecture can approximate every continuous equivariant function. Such a density result needs a precise compact domain, architecture class, activation function, topology, and approximation norm.

Likewise, the exponential expression

$$
K(x,y)=\exp\!\left(\frac{q(x)\cdot k(y)}{s}\right)
$$

is not automatically a reproducing kernel when $q$ and $k$ are unrelated. A reproducing kernel must satisfy symmetry and positive-definiteness conditions; unrelated query and key maps can violate symmetry. The symmetric specialization $q=k$ is the natural setting for a positive-definite exponential dot-product kernel.

Nor does adding attention heads automatically increase matrix rank. Two identical heads are an immediate counterexample. A valid rank-growth theorem must assume that a new head contributes directions independent of the previous heads.

These distinctions sharpen, rather than weaken, the central message. The mathematics tells us exactly what standard attention guarantees for every possible input: positive normalized mixing, preservation of constants, exact transport under relabeling, and closure of the symmetry under composition. More ambitious claims require more hypotheses.

## A small example with a large lesson

Take two tokens whose score row is $(0,\log 3)$. Exponentiating gives the pair $(1,3)$, and normalization gives weights $(1/4,3/4)$. If the corresponding scalar values are $4$ and $12$, the output is

$$
\frac14\cdot4+\frac34\cdot12=10.
$$

Now swap the two tokens everywhere. The score entries swap, the weights become $(3/4,1/4)$ in the new displayed order, and the values become $12$ and $4$. The transported output is still

$$
\frac34\cdot12+\frac14\cdot4=10.
$$

Nothing mysterious happened: each weight stayed attached to the value and comparison that generated it. The general theorem is this bookkeeping principle extended to any finite number of tokens, any feature dimensions, and any permutation.

The example also clarifies constant preservation. If both values were $7$, every possible normalized weight pair would return

$$
W_{i1}\cdot7+W_{i2}\cdot7
=7(W_{i1}+W_{i2})=7.
$$

The query and key vectors can change where the probability mass falls, but when all available values coincide, there is nowhere for the weighted average to move. These elementary cases are useful implementation tests because they expose incorrect axis conventions immediately.

## A symmetry hidden in plain sight

Attention is often described through the metaphor of relevance: each token decides which other tokens matter. The deeper structural picture is that the decision process has no attachment to arbitrary token names. Scores move with the tokens, normalization survives reordered sums, weights follow both indices, and weighted outputs follow their owners.

That chain of simple facts yields a robust architectural principle. If the world presents objects without a preferred ordering, attention can respect that world exactly. And when order does matter, the theorem identifies precisely where extra structure—positions, masks, or geometry—must enter. Symmetry is not decoration added after the model is built. It is one of the clearest ways to understand what the model is built to do.
