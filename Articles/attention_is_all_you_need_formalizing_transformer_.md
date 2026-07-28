# Attention as a Perfect Index: What a Finite Transformer Can Remember

## The geometry behind the familiar word

“Attention” sounds psychological, but its mathematical core begins with a simple act: compare two vectors and assign the comparison a number. A query asks what matters; a key advertises what it represents; a score measures their match. This small mechanism sits at the center of systems that translate languages, summarize documents, analyze proteins, and process time series.

The cleanest version is bilinear attention. Let $q,k\in\mathbb{R}^d$ be a query and a key, and let $W\in\mathbb{R}^{d\times d}$ be a learned matrix. Their score is

$$
B_W(q,k)=q^{\mathsf T}Wk.
$$

The matrix $W$ changes the geometry of comparison. With $W=I$, the score is the ordinary dot product. A general $W$ can amplify some directions, suppress others, or couple one coordinate of the query to another coordinate of the key.

This article develops three exact facts about a finite, linear-attention model. First, the score really is bilinear: it obeys superposition independently in its query and key. Second, additive positional information and learned coordinatewise affine transformations have transparent composition laws. Third, and most strikingly, a bank of attention heads can reproduce *every* function on a finite collection of fixed-length sequences exactly.

That final claim needs careful boundaries. It is an exact lookup-table theorem for linear attention on a finite domain. It is not the usual theorem that standard softmax transformers approximate continuous functions on compact Euclidean sets. The distinction matters—and also reveals the argument’s central idea with unusual clarity.

## Attention obeys superposition

A map is linear when mixtures at its input become the same mixtures at its output. Bilinearity means linearity in either argument while the other remains fixed. For any vectors $q_1,q_2,k,k_1,k_2\in\mathbb{R}^d$ and scalar $c\in\mathbb{R}$,

$$
B_W(q_1+q_2,k)=B_W(q_1,k)+B_W(q_2,k),
$$

$$
B_W(cq,k)=cB_W(q,k),
$$

$$
B_W(q,k_1+k_2)=B_W(q,k_1)+B_W(q,k_2),
$$

and

$$
B_W(q,ck)=cB_W(q,k).
$$

These laws are more than algebraic housekeeping. They say that attention scores can be understood by decomposing queries and keys into simpler parts. For example,

$$
B_W(aq_1+bq_2,k_1+k_2)
=a\bigl(B_W(q_1,k_1)+B_W(q_1,k_2)\bigr)
+b\bigl(B_W(q_2,k_1)+B_W(q_2,k_2)\bigr).
$$

Every interaction in the mixture is visible. This resembles superposition in wave physics: complicated signals can be split into components, analyzed separately, and recombined. It also resembles feature interaction in statistics, where $W$ specifies which query features pair with which key features.

## Giving order to a sequence

Attention by itself compares content. Yet a sentence is not merely a bag of words: “dog bites person” differs from “person bites dog.” A simple way to represent order is to add a position vector $p$ to a content vector $x$. Define

$$
P_p(x)=x+p.
$$

Two successive positional encodings do not create a mysterious new operation. They simply add:

$$
P_{p_2}(P_{p_1}(x))=P_{p_1+p_2}(x).
$$

Thus additive position vectors form a compositional bookkeeping system. If one encoding marks location within a sentence and another marks location within a paragraph, their combined effect is one encoding with the summed position vector.

Now consider the learned affine stage commonly placed after the data-dependent centering and variance normalization in a normalization layer. For coordinatewise scale $s$, bias $b$, and vector $x$, define

$$
A_{s,b}(x)_i=s_i x_i+b_i.
$$

This is deliberately only the learned affine post-transformation, not the full nonlinear normalization operation. Two such stages collapse into one:

$$
A_{s_2,b_2}(A_{s_1,b_1}(x))
=A_{s_2\odot s_1,\,s_2\odot b_1+b_2}(x),
$$

where $\odot$ denotes coordinatewise multiplication. Likewise, applying an affine stage after positional encoding gives

$$
A_{s,b}(P_p(x))_i=s_i x_i+(s_i p_i+b_i).
$$

Position therefore enters the final affine expression as part of an effective bias, scaled coordinate by coordinate. These identities can simplify networks algebraically: adjacent affine stages may be fused, and the effect of additive position can be tracked exactly.

## Turning attention into equality

The universality argument begins with a finite set $X$ of possible inputs. An “input” may be one token, but it may equally well be an entire fixed-length sequence. Associate each $x\in X$ with its one-hot vector $e_x\in\mathbb{R}^{X}$, defined by

$$
(e_x)_y=
\begin{cases}
1,&y=x,\\
0,&y\ne x.
\end{cases}
$$

One-hot vectors are perfect name tags. Their dot products test equality:

$$
e_x\cdot e_a=
\begin{cases}
1,&x=a,\\
0,&x\ne a.
\end{cases}
$$

This is attention reduced to a switch. A head keyed by $a$ is silent for every input except $a$.

Suppose a desired function assigns to each input $x\in X$ an output vector $f(x)\in\mathbb{R}^{Y}$, where $Y$ is a finite set of output coordinates. Build one head for each possible input $a\in X$. Give that head key $e_a$ and value $f(a)$. On input $x$, let it emit

$$
H_a(x)=(e_x\cdot e_a)f(a).
$$

Because the score is either zero or one,

$$
H_a(x)=
\begin{cases}
f(a),&x=a,\\
0,&x\ne a.
\end{cases}
$$

Now sum all heads:

$$
M_f(x)=\sum_{a\in X}H_a(x).
$$

Exactly one summand survives—the one indexed by $a=x$. Therefore

$$
M_f(x)=f(x)
$$

for every $x\in X$.

This is the **Finite Bilinear-Attention Universality Theorem**: for every function from a finite input set to a finite-dimensional real output space, a finite family of bilinear-attention lookup heads represents that function exactly.

The proof is almost visual. Imagine a wall of locked drawers, one for every possible input. A one-hot query is a key that opens exactly one drawer. Each drawer contains the prescribed output for its input. Opening all drawers “in parallel” is harmless because only one lock responds.

## From tokens to whole sequences

Let $\Sigma$ be a finite alphabet and fix an input length $n$. The set of sequences $\Sigma^n$ is finite, with $|\Sigma|^n$ elements. Treat each complete sequence as one member of the finite input set $X=\Sigma^n$.

Suppose the desired output has length $m$ and width $r$, so that a target map has the form

$$
f:\Sigma^n\longrightarrow\mathbb{R}^{m\times r}.
$$

The **Finite Sequence-to-Sequence Universality Theorem** states that a multi-head lookup model with one head per possible input sequence reproduces every output coordinate exactly. For every sequence $x\in\Sigma^n$, output position $i$, and feature coordinate $j$,

$$
M_f(x)_{i,j}=f(x)_{i,j}.
$$

No approximation error remains. The theorem covers arbitrary finite tasks: translation between bounded vocabularies and fixed lengths, finite-state labeling, table-defined control rules, or classification augmented with real-valued output features.

## Power, price, and perspective

Exactness comes at a steep price. The construction uses one head for every possible sequence. If the alphabet has $v$ symbols and the sequence length is $n$, the head count is

$$
v^n.
$$

This exponential growth makes the construction a foundational existence proof, not an efficient recipe for large language models. A vocabulary of only $100$ symbols and length $10$ already yields $100^{10}=10^{20}$ possible sequences.

Yet existence proofs have value even when their direct construction is expensive. They isolate the source of expressive power. Here it is not a subtle optimization phenomenon: finite universality follows from exact discrimination plus stored values. The result gives a baseline against which efficient architectures can be judged. Layers, shared projections, feed-forward networks, and distributed representations can be viewed as ways of compressing or factorizing an otherwise enormous lookup table.

The construction also clarifies why “universality” has several meanings. On a finite domain, exact representation is possible because every point can receive its own coordinate. On a continuous domain, there are infinitely many inputs, and one asks instead for approximation within an error tolerance, usually under continuity and compactness assumptions. Standard transformer attention additionally uses softmax normalization, whereas the selector here uses an unnormalized bilinear score. Moving from one setting to the other requires quantitative analysis: how sharply can softmax approximate an equality test, and with how many heads or layers?

## A small example with a large moral

Take binary strings of length $3$. There are only eight: $000$, $001$, $010$, $011$, $100$, $101$, $110$, and $111$. Suppose the desired output records two facts—the parity of the number of ones and the count itself. Thus $011$ should produce $(0,2)$, while $111$ should produce $(1,3)$.

The exhaustive model builds eight heads. The head for $011$ carries the key $e_{011}$ and the value $(0,2)$. When the query is $e_{011}$, its score is one; all seven competing scores are zero. The output is therefore $(0,2)$. The same mechanism works for every row of the table.

Of course, counting ones has a compact algorithm, and an intelligent model should discover or encode that structure rather than memorize eight cases. That contrast is precisely the point. Universality answers, “Can the architecture represent the rule at all?” Efficiency asks, “Can it exploit the rule’s structure?” The lookup theorem settles the first question in the finite setting and turns attention toward the second. It supplies a worst-case construction that works even when the target table has no visible pattern to compress.

## A map for what comes next

The elementary identities suggest a research path. One can replace exact zero-one selection with scaled softmax and bound the leakage from incorrect keys. One can add the full normalization operation—mean subtraction and variance scaling—and prove its invariances. One can build dimension-safe query, key, and value projections, concatenate heads, insert residual connections, and study positional symmetry. Most importantly, one can ask how much of the exponential lookup table can be compressed when the target function has structure.

The lasting lesson is simple. Bilinear attention supplies a geometry of comparison. One-hot representations turn that geometry into exact equality. Multiple heads turn equality into memory. On a finite universe of sequences, that chain is enough to realize any desired sequence-to-sequence rule—perfectly, transparently, and at a computational cost that points directly toward the harder problem of efficient representation.
