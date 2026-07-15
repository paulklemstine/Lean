# The Arithmetic Diary of Three Halves

## A simple orbit leaves a complicated word

Begin with one of the least threatening operations in mathematics: multiply by three halves. Starting from $1$, the exact orbit is

$$
1,\ \frac32,\ \frac94,\ \frac{27}{8},\ldots,
$$

with general term $(3/2)^n$. Now imagine that an observer is allowed to record only the nearest integer at each step. Write

$$
\left(\frac32\right)^n=m_n+\varepsilon_n,
\qquad -\frac12\leq \varepsilon_n<\frac12,
$$

where $m_n$ is an integer and the half-open interval fixes how ties are handled. The sequence begins

$$
m_0,m_1,m_2,m_3,m_4,m_5,m_6,m_7
=1,2,2,3,5,8,11,17.
$$

Rounding seems to have thrown information away. Yet the discrepancy between multiplying a rounded value and rounding the next exact value leaves a small, revealing trace. Define the steering correction

$$
t_n=2m_{n+1}-3m_n.
$$

Equivalently, the rounded orbit obeys

$$
2m_{n+1}=3m_n+t_n.
$$

Thus $t_n$ records the tiny adjustment needed to steer the integer $3m_n$ to the even integer $2m_{n+1}$. The first corrections are

$$
1,-2,0,1,1,-2,1,\ldots.
$$

This infinite symbolic sequence is the three-halves steering word. Its interest comes from a striking tension. Each letter is tiny, but a long block of letters encodes an exact relation between integers of exponential size.

## Why only five symbols can appear

The correction can be expressed directly through the rounding errors. Comparing the orbit equations at times $n$ and $n+1$ gives

$$
t_n=3\varepsilon_n-2\varepsilon_{n+1}.
$$

Because both errors lie between $-1/2$ and $1/2$, this real number lies strictly between the integer barriers that would permit a magnitude of $3$. Since $t_n$ itself is an integer, it follows that

$$
t_n\in\{-2,-1,0,1,2\}.
$$

This Five-Symbol Alphabet Theorem is the first compression principle. An orbit growing like $(3/2)^n$ produces a word over just five letters. The bound also explains why a tempting three-letter guess fails: the early value $t_1=-2$ already reaches an extreme symbol.

Finite alphabets connect arithmetic to combinatorics on words, the field that studies recurring patterns in sequences. For a word $T=(t_n)$, let $p_T(k)$ denote the number of distinct consecutive blocks of length $k$ appearing in $T$. A constant or periodic word has very low complexity. A completely unconstrained five-letter word could exhibit all $5^k$ possible blocks. Every finite five-symbol sequence therefore satisfies the elementary upper bound

$$
p_T(k)\leq 5^k
$$

for the windows that are available in the chosen prefix. The important question is not this universal ceiling, but how arithmetic restricts repetitions far below it.

## A block is a compressed arithmetic instruction

Suppose we know a starting rounded value $m_n$ and the next $k$ steering symbols. Repeatedly applying

$$
2m_{r+1}=3m_r+t_r
$$

reconstructs the endpoint. To display the result cleanly, define the weighted block contribution

$$
W(n,k)=\sum_{j=0}^{k-1}3^{k-1-j}2^j t_{n+j},
$$

with $W(n,0)=0$. Then the Endpoint Reconstruction Theorem states

$$
2^k m_{n+k}=3^k m_n+W(n,k).
$$

The proof is an induction on $k$. For one step it is exactly the steering recurrence. Adding one more symbol multiplies the previous weighted contribution by $3$ and appends the new correction with coefficient $2^k$. This creates the alternating pattern of powers of $3$ and $2$ in the sum.

The formula is more than a convenient expansion. It says that a symbolic block is an arithmetic instruction: given its entry value, it determines its exit value exactly. No approximation remains.

## Repeated phrases force exponential rigidity

Now suppose the same length-$k$ block begins at two positions $a$ and $b$:

$$
t_{a+j}=t_{b+j}\qquad\text{for every }0\leq j<k.
$$

Equal blocks have equal weighted contributions, so subtracting the two reconstruction formulas cancels the entire symbolic part. What remains is the Repeated-Block Rigidity Theorem:

$$
2^k\bigl(m_{a+k}-m_{b+k}\bigr)
=3^k\bigl(m_a-m_b\bigr).
$$

This identity is the central bridge. A coincidence among small symbols forces two differences of rounded exponential values to be related by the exact ratio $(3/2)^k$. The longer the repeated phrase, the stronger the arithmetic constraint.

In ordinary text, repeated phrases are cheap. A writer can repeat a sentence at will. In the steering word, repetition must negotiate simultaneously with powers of $2$, powers of $3$, integer divisibility, and the narrow rounding interval. Symbolic recurrence has acquired a Diophantine price.

This phenomenon points toward the expected superlinear complexity of the word: one anticipates

$$
\frac{p_T(k)}{k}\longrightarrow\infty.
$$

The finite-block theorems developed here do not by themselves establish that asymptotic statement. They isolate its essential arithmetic mechanism. To pass from rigidity of one repeated block to a global lower bound on the number of blocks requires a deep anti-repetition principle for sparse exponential equations. The distinction matters: finite experiments can suggest complexity, but no amount of initial data alone proves an asymptotic law.

## The special meaning of silence

The symbol $0$ means that a step needs no correction:

$$
2m_{n+1}=3m_n.
$$

A run of zeros is therefore especially rigid. If

$$
t_n=t_{n+1}=\cdots=t_{n+k-1}=0,
$$

then the weighted contribution vanishes and endpoint reconstruction becomes

$$
2^k m_{n+k}=3^k m_n.
$$

Because $2^k$ and $3^k$ are coprime, the Zero-Block Divisibility Theorem follows:

$$
2^k\mid m_n.
$$

Each additional zero demands another factor of $2$ in the rounded value at the beginning of the run. This turns an apparently featureless patch of the word into a precise certificate of binary divisibility.

An infinite zero tail is even more constrained. If $t_{n+j}=0$ for every $j\geq0$, then $2^k$ divides $m_n$ for every $k$. No nonzero integer is divisible by arbitrarily large powers of $2$. Hence the Infinite-Zero-Tail Theorem says

$$
m_n=0.
$$

For the orbit of $1$, whose rounded values are positive, the steering word can never become permanently silent. This is a qualitative nonperiodicity signal: the dynamics must continue making corrections forever.

## A wider arithmetic pattern

The same architecture is not peculiar to three halves. For a rational multiplier $a/b$ with coprime positive integers $a>b$, one can round $(a/b)^n$ to integers and record

$$
s_n=bm_{n+1}-am_n.
$$

Iteration then produces endpoint coefficients $b^k$ and $a^k$, while bounded rounding errors again confine $s_n$ to a finite alphabet. Repeated symbolic blocks consequently impose exact scaling relations between integer differences. The three-halves case is the cleanest laboratory because the competing primes $2$ and $3$ are so visible.

This laboratory also suggests concrete questions. Can zero runs be bounded uniformly? The divisibility theorem says that a length-$k$ zero run requires $2^k\mid m_n$, while $m_n$ stays within one half of $(3/2)^n$. Can the extreme symbols $-2$ and $2$ occur with positive frequency? Their error formula requires neighboring rounding errors to sit near opposite ends of the allowed interval. Can repeated-block rigidity be counted sharply enough to prove a lower bound such as $p_T(k)\geq c k\log k$ over long ranges?

## Reading complexity without being fooled by data

A computer can generate thousands of steering symbols exactly and count their visible factors. Such an experiment is valuable: it reveals candidate repeats, tests reconstruction identities, and shows how quickly the observed vocabulary grows. But complexity is a statement about the infinite word. If a prefix of length $N$ contains $q$ different blocks of length $k$, then one has proved only that $p_T(k)\geq q$. Blocks that first occur after position $N$ remain invisible.

This is why the rigidity identity matters more than a spectacular graph. It applies at every pair of positions and every block length. Imagine, hypothetically, that $p_T(k)$ remained bounded by a constant multiple of $k$. Very long prefixes would then be forced to reuse a comparatively small stock of blocks many times. Every reuse would produce an equation

$$
2^k\bigl(m_{a+k}-m_{b+k}\bigr)=3^k\bigl(m_a-m_b\bigr).
$$

The route to superlinearity is to show that too many such equations cannot coexist. In this way, combinatorial scarcity would force arithmetic abundance, and number theory would rule that abundance out.

There is a useful analogy with language. Counting the distinct phrases in one chapter tells us something about an author's vocabulary but not everything about every future chapter. A structural rule saying that every repeated phrase forces a rare numerical coincidence is much stronger. It constrains the unwritten continuation as well as the observed text.

## From exact arithmetic to an experiment

The orbit can be computed without floating-point approximation. Since $(3/2)^n=3^n/2^n$, for $n\geq1$ the chosen nearest integer is

$$
m_n=\left\lfloor\frac{3^n+2^{n-1}}{2^n}\right\rfloor,
$$

with $m_0=1$. Integer powers therefore suffice to generate every rounded value and correction exactly. Once a prefix is available, sliding a window of length $k$ across it and storing the resulting tuples gives the number of distinct visible factors.

One can also turn the reconstruction formula into a checksum. Start with $W=0$. Reading the block from left to right, at its $j$th symbol replace

$$
W\quad\text{by}\quad 3W+2^j t_{n+j}.
$$

After $k$ steps, the identity $2^k m_{n+k}=3^k m_n+W$ must hold. A single mistyped steering symbol changes this weighted total and is detected by the endpoint comparison. The checksum is not meant for cryptographic security; its purpose is conceptual. It demonstrates that the word and the orbit are two views of the same exact recurrence.

## Tiny symbols, large consequences

The steering word is a diary written by rounding. Its alphabet has only five symbols, and each symbol records an error of at most a few units. But a block of length $k$ carries weights ranging through powers of $2$ and $3$. The Endpoint Reconstruction Theorem translates the diary back into exact arithmetic; the Repeated-Block Rigidity Theorem shows that identical passages force exponential scaling; the Zero-Block Divisibility and Infinite-Zero-Tail Theorems expose the arithmetic content of silence.

The larger lesson reaches beyond this particular orbit. Rounding does not merely destroy information. When performed repeatedly inside an expanding dynamical system, it can create a symbolic residue whose patterns remember exact number-theoretic structure. The letters are small. The equations they enforce are not.