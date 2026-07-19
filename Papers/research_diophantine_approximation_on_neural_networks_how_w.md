# Dyadic Diophantine Approximation by Width-One ReLU Networks

## Binary Parameter Compilers, Exact Hidden States, and Error Complexity for $\pi$

**Aristotle**  
**July 19, 2026**

## Abstract

We study approximation of the constant $\pi$ by a scalar rectified linear network under an explicit quantization constraint. At depth $n$, define the dyadic numerator $P_n=\lfloor 2^n\pi\rfloor$ and the digit $b_n=P_{n+1}-2P_n$. We prove that every $b_n$ belongs to $\{0,1\}$ and that the width-one recurrence

$$
h_0=3,
\qquad
h_{n+1}=\operatorname{ReLU}(2h_n+b_n)
$$

has the exact hidden state $h_n=P_n$. The normalized output $A_n=h_n/2^n$ is therefore the lower dyadic truncation of $\pi$ and obeys

$$
0<\pi-A_n<2^{-n}.
$$

Consequently every positive tolerance is reached at finite depth, and a sufficient explicit depth is any integer $n>\log_2(1/\varepsilon)$. The construction uses width one, a fixed integer hidden weight $2$, and one binary bias per layer. Its interpretation requires care: the biases encode pre-existing binary digits of $\pi$, so the construction measures storage and execution rather than the uniform computational cost of generating those digits. We formulate the result as an exact bridge between dyadic Diophantine approximation and quantized rectified computation, discuss why unrestricted real parameters trivialize single-point approximation, provide algorithms for simulation and certification, and identify parameter bit complexity and uniform digit generation as the appropriate foundations for future lower bounds.

## 1. Introduction

Universal approximation results describe the ability of neural networks to approximate broad classes of functions. They do not, by themselves, answer a more arithmetic question: when the target is a distinguished constant and the parameters are restricted, how does approximation quality depend on depth, width, and parameter information?

At a single input, unrestricted real parameters make this question degenerate. An affine unit may simply contain $\pi$ as a bias and output it exactly. Counting that bias as one parameter ignores its unbounded information content. The issue becomes substantive only after the admissible parameters and their costs are specified.

We impose a particularly simple parameter alphabet. The hidden network has width one. Its weight at every layer is the integer $2$. Its layer-dependent biases are bits, hence belong to $\{0,1\}$. The activation is the rectified linear unit

$$
\operatorname{ReLU}(x)=\max\{x,0\}.
$$

The resulting network is a shift-and-add machine for the binary expansion of $\pi$. Its hidden state after $n$ layers is not merely approximately related to $\pi$: it is exactly $\lfloor 2^n\pi\rfloor$. This identity yields an immediate and sharp error certificate after normalization.

The main result may be summarized as follows.

> **Dyadic ReLU Approximation Theorem.** For every nonnegative integer $n$, there are binary biases $b_0,\ldots,b_{n-1}$ such that a width-one depth-$n$ rectified network with every hidden weight equal to $2$ outputs
> 
> $$
> A_n=\frac{\lfloor 2^n\pi\rfloor}{2^n},
> $$
> 
> and its error satisfies
> 
> $$
> 0<\pi-A_n<2^{-n}.
> $$

This yields logarithmic depth in inverse accuracy for the stated architecture. It does not yield a uniform algorithm for computing the bits of $\pi$, nor does it establish that $\pi$ is intrinsically harder than a rational constant. Rather, it cleanly separates network execution from arithmetic advice.

The rest of the paper develops the construction from first principles, proves each component, gives executable algorithms and numerical examples, and discusses the complexity model needed for meaningful extensions.

## 2. Arithmetic and Network Definitions

### 2.1 Dyadic lower approximations

A **dyadic rational of depth $n$** is a number of the form $m/2^n$ with $m$ an integer. For each nonnegative integer $n$, define the **binary prefix numerator of $\pi$** by

$$
P_n=\left\lfloor 2^n\pi\right\rfloor.
$$

Define the corresponding **lower dyadic approximation** by

$$
A_n=\frac{P_n}{2^n}.
$$

The terminology “lower” records that $A_n\le\pi$. Since $\pi$ is irrational, equality never occurs.

The next digit is recovered from consecutive prefix numerators.

> **Definition 2.1 (binary transition digit).** For each $n\ge0$, define
> 
> $$
> b_n=P_{n+1}-2P_n.
> $$

This formula describes the usual left shift of a binary integer followed by appending one bit.

### 2.2 Scalar rectified networks

A width-one depth-$n$ rectified computation consists of an initial scalar state $h_0$, scalar weights $w_0,\ldots,w_{n-1}$, scalar biases $c_0,\ldots,c_{n-1}$, and the recurrence

$$
h_{k+1}=\operatorname{ReLU}(w_kh_k+c_k).
$$

Our network uses

$$
h_0=3,\qquad w_k=2,\qquad c_k=b_k.
$$

Thus

$$
h_{k+1}=\operatorname{ReLU}(2h_k+b_k).
$$

At depth $n$, the linear readout is

$$
y_n=2^{-n}h_n.
$$

The factor $2^{-n}$ may be viewed either as a final readout weight or as external normalization. All hidden weights remain equal to $2$, and every hidden bias is binary.

### 2.3 Resource accounting

For the depth-$n$ construction, the relevant resources are:

- hidden width: $1$;
- hidden depth: $n$;
- hidden weights: $n$ copies of the integer $2$;
- hidden biases: $n$ bits $b_0,\ldots,b_{n-1}$;
- readout scaling: $2^{-n}$;
- arithmetic advice: the first $n$ binary transition digits of $\pi$.

The last item is logically distinct from evaluation cost. Supplying the digits nonuniformly uses $n$ bits of target-dependent information. Generating them uniformly is a separate computational problem.

## 3. Binary Transition Structure

We begin with the elementary floor identity that drives the construction.

> **Lemma 3.1 (binary digit lemma).** For every nonnegative integer $n$, the transition digit
> 
> $$
> b_n=P_{n+1}-2P_n
> $$
> 
> is either $0$ or $1$.

**Proof sketch.** Write

$$
2^n\pi=P_n+r_n,
$$

where the defining property of the floor gives $0\le r_n<1$. Multiplication by $2$ yields

$$
2^{n+1}\pi=2P_n+2r_n,
$$

with $0\le2r_n<2$. Since $2P_n$ is an integer,

$$
P_{n+1}=\left\lfloor 2^{n+1}\pi\right\rfloor
       =2P_n+\lfloor2r_n\rfloor.
$$

The final floor is $0$ or $1$, proving the claim. $\square$

An equivalent formulation is the exact recurrence

$$
P_{n+1}=2P_n+b_n,
\qquad b_n\in\{0,1\}.
$$

The initial numerator is also explicit.

> **Lemma 3.2 (initial prefix).** The depth-zero prefix numerator is $P_0=3$.

**Proof sketch.** Since $3<\pi<4$, taking the floor of $2^0\pi=\pi$ gives $P_0=3$. $\square$

Finally, every prefix numerator is nonnegative.

> **Lemma 3.3 (nonnegativity).** For every $n\ge0$, one has $P_n\ge0$.

**Proof sketch.** Both $2^n$ and $\pi$ are positive, so $2^n\pi>0$. The floor of this quantity is nonnegative because in fact $2^n\pi\ge\pi>3$. $\square$

These facts show that binary truncation is naturally computed by a positive shift-and-add recurrence.

## 4. Exact Neural Execution

We now identify the network state with the arithmetic prefix.

> **Theorem 4.1 (exact hidden-state theorem).** Let
> 
> $$
> h_0=3,
> \qquad
> h_{n+1}=\operatorname{ReLU}(2h_n+b_n),
> $$
> 
> where $b_n=P_{n+1}-2P_n$. Then, for every nonnegative integer $n$,
> 
> $$
> h_n=P_n=\left\lfloor 2^n\pi\right\rfloor.
> $$

**Proof sketch.** Proceed by induction. At $n=0$, Lemma 3.2 gives $h_0=3=P_0$. Assume $h_n=P_n$. Then

$$
2h_n+b_n=2P_n+(P_{n+1}-2P_n)=P_{n+1}.
$$

By Lemma 3.3, $P_{n+1}\ge0$, so the rectifier acts as the identity. Hence

$$
h_{n+1}=\operatorname{ReLU}(P_{n+1})=P_{n+1}.
$$

This closes the induction. $\square$

The theorem explains the precise role of rectification. It does not create the binary recurrence; rather, positivity ensures it does not disturb it. This is still a valid rectified network, but its trajectory remains in the linear region of the activation.

> **Corollary 4.2 (exact readout identity).** For every $n\ge0$, the normalized network output satisfies
> 
> $$
> y_n=\frac{h_n}{2^n}=\frac{\lfloor2^n\pi\rfloor}{2^n}=A_n.
> $$

**Proof sketch.** Substitute the identity from Theorem 4.1 into the definition $y_n=2^{-n}h_n$. $\square$

Thus the network is an exact executor for a classical Diophantine approximation scheme.

## 5. Approximation Error and Depth

The defining inequalities for the floor give the quantitative estimate.

> **Theorem 5.1 (strict dyadic error bound).** For every nonnegative integer $n$,
> 
> $$
> 0<\pi-y_n<\frac1{2^n}.
> $$

**Proof sketch.** By Corollary 4.2,

$$
y_n=\frac{P_n}{2^n}.
$$

The floor inequality gives

$$
P_n\le2^n\pi<P_n+1.
$$

Because $\pi$ is irrational, $2^n\pi$ cannot equal the integer $P_n$, so the first inequality is strict. Subtract $P_n$ and divide by the positive number $2^n$ to obtain

$$
0<\pi-\frac{P_n}{2^n}<\frac1{2^n}.
$$

This is the desired estimate. $\square$

Strict positivity is a specifically irrational feature. For a dyadic rational target, the same construction eventually reaches the target exactly, after which the lower error is zero. The upper estimate remains valid.

> **Corollary 5.2 (eventual attainment of every tolerance).** For every real $\varepsilon>0$, there exists a nonnegative integer $n$ such that
> 
> $$
> |y_n-\pi|<\varepsilon.
> $$

**Proof sketch.** Powers $2^{-n}$ converge to zero, so choose $n$ with $2^{-n}<\varepsilon$. Theorem 5.1 shows that $y_n<\pi$, hence

$$
|y_n-\pi|=\pi-y_n<2^{-n}<\varepsilon.
$$

$\square$

An explicit sufficient depth follows directly.

> **Corollary 5.3 (explicit depth selection).** If $0<\varepsilon<1$ and
> 
> $$
> n>\log_2\!\left(\frac1\varepsilon\right),
> $$
> 
> then $|y_n-\pi|<\varepsilon$. In particular, the choice
> 
> $$
> n=\left\lceil\log_2\!\left(\frac1\varepsilon\right)\right\rceil+1
> $$
> 
> is always sufficient.

**Proof sketch.** Exponentiating the strict inequality for $n$ gives $2^n>1/\varepsilon$, equivalently $2^{-n}<\varepsilon$. Apply Corollary 5.2’s estimate. $\square$

Therefore this bitwise compiler has depth complexity $O(\log(1/\varepsilon))$. A stronger $O(\log\log(1/\varepsilon))$ depth claim does not follow from the present one-bit-per-layer architecture.

## 6. Algorithms

### 6.1 Prefix construction

Given a sufficiently accurate representation of the target, the prefix numerator is computed by multiplication and flooring.

**Algorithm 1: Dyadic prefix extraction**

**Input:** a positive real target $x$ and a depth $n$.  
**Output:** $Q_n=\lfloor2^nx\rfloor$.

1. Compute $s=2^n x$ with enough precision to determine its floor.
2. Return $\lfloor s\rfloor$.

For ordinary fixed-precision numerical arithmetic, this operation is constant-time at the machine-word level until the word size is exceeded. In bit complexity, the output has $O(n)$ bits for fixed $x$, and reliable evaluation must carry enough guard precision to distinguish $2^nx$ from nearby integers.

### 6.2 Bias extraction

**Algorithm 2: Binary transition stream**

**Input:** a positive target $x$ and a maximum depth $N$.  
**Output:** integers $Q_0,\ldots,Q_N$ and bits $c_0,\ldots,c_{N-1}$.

1. Set $Q_k=\lfloor2^k x\rfloor$ for $0\le k\le N$.
2. For each $0\le k<N$, set $c_k=Q_{k+1}-2Q_k$.
3. Assert that $c_k\in\{0,1\}$.
4. Return the prefixes and bits.

Using arbitrary-precision integers, the recurrence itself requires $O(N)$ shifts and additions on integers of at most $O(N)$ bits. With schoolbook integer costs, this is $O(N^2)$ bit operations after the bits are known. The cost of producing trustworthy target digits is separate.

### 6.3 Network execution and certification

**Algorithm 3: Width-one ReLU evaluation**

**Input:** $N$ binary biases $c_0,\ldots,c_{N-1}$.  
**Output:** hidden states and normalized approximations.

1. Initialize $h_0=\lfloor x\rfloor$.
2. For $k=0,\ldots,N-1$:
   1. compute $z_{k+1}=2h_k+c_k$;
   2. set $h_{k+1}=\max\{z_{k+1},0\}$;
   3. set $a_{k+1}=h_{k+1}/2^{k+1}$.
3. Return all $h_k$ and $a_k$.

For positive $x$, all states are nonnegative and rectification is inactive. Given the digit stream, the arithmetic cost is linear in the number of layers at the unit-cost level. The exact certificate is the identity $h_k=Q_k$, while the universal interval certificate is

$$
0\le x-a_k<2^{-k}.
$$

If $x$ is irrational, the left inequality is strict.

## 7. Numerical Illustrations

The construction can be evaluated exactly once a high-precision value supplies the needed floors. For $\pi$, selected depths give the following guaranteed bounds:

| Depth $n$ | Guaranteed upper bound $2^{-n}$ | Approximate decimal scale |
|---:|---:|---:|
| $4$ | $1/16$ | $6.25\times10^{-2}$ |
| $10$ | $1/1024$ | $9.77\times10^{-4}$ |
| $20$ | $1/1{,}048{,}576$ | $9.54\times10^{-7}$ |
| $40$ | $1/1{,}099{,}511{,}627{,}776$ | $9.09\times10^{-13}$ |
| $50$ | $1/1{,}125{,}899{,}906{,}842{,}624$ | $8.88\times10^{-16}$ |

The actual error depends on the fractional tail of $2^n\pi$ and may be much smaller than the bound, but it is always positive and below the displayed threshold.

The same algorithm applies to $e$ and $\sqrt2$. For a positive irrational target $x$, define

$$
Q_n(x)=\lfloor2^nx\rfloor,
\qquad
c_n(x)=Q_{n+1}(x)-2Q_n(x).
$$

The same proof gives $c_n(x)\in\{0,1\}$, exact state $h_n=Q_n(x)$, and

$$
0<x-\frac{h_n}{2^n}<2^{-n}.
$$

These examples demonstrate that the architecture is a general compiler for positive irrational constants, not a special analytic formula for $\pi$.

## 8. Generalization to Positive Irrational Targets

The mechanism is not specific to any analytic identity for $\pi$. It follows from radix-two arithmetic.

> **Theorem 8.1 (universal positive-target compiler).** Let $x>0$ be irrational. Define
> 
> $$
> Q_n=\lfloor2^n x\rfloor,
> \qquad
> c_n=Q_{n+1}-2Q_n,
> $$
> 
> and initialize $s_0=\lfloor x\rfloor$. Then $c_n\in\{0,1\}$ for every $n$, the recurrence
> 
> $$
> s_{n+1}=\operatorname{ReLU}(2s_n+c_n)
> $$
> 
> satisfies $s_n=Q_n$, and its normalized output $z_n=s_n/2^n$ obeys
> 
> $$
> 0<x-z_n<2^{-n}.
> $$

**Proof sketch.** Write $2^n x=Q_n+r_n$ with $0\le r_n<1$. Doubling shows $Q_{n+1}=2Q_n+\lfloor2r_n\rfloor$, so $c_n$ is binary. Positivity of $x$ makes every $Q_n$ nonnegative, and induction therefore identifies the rectified recurrence with $Q_n$. The floor inequalities give $0\le x-Q_n/2^n<2^{-n}$; irrationality rules out equality on the left. $\square$

The theorem applies directly to $e$ and $\sqrt2$. For a positive rational target whose reduced denominator is a power of two, the process eventually becomes exact. For other positive rationals, the binary expansion is eventually periodic and the strict lower bound persists at every depth where the target is not itself on the dyadic grid. These cases clarify that the architecture is universal while exactness behavior is governed by the target’s arithmetic.

## 9. Interpretation and Limitations

### 9.1 Storage is not generation

The bias sequence is extracted from the binary expansion of the target. It therefore contains the answer in distributed form. The network executes a representation supplied to it; it does not derive the representation from a finite target-independent program.

This is not a defect in the theorem, but it controls its interpretation. The construction establishes an exact equivalence between two descriptions:

1. the first $n$ binary digits encoded by $\lfloor2^n\pi\rfloor$;
2. the state reached by $n$ width-one rectified shift-and-add layers.

To claim an efficient *computation* of $\pi$, one must also account for the algorithm that generates $b_n$.

### 9.2 Why arbitrary reals trivialize the problem

Suppose a model permits arbitrary real parameters at unit cost and asks only for the value at one input. Then a single affine map can output $\pi$ exactly by using $\pi$ as its bias. Under that convention, rational-versus-irrational approximation rates have no robust meaning.

A useful complexity model should specify:

1. the allowable parameter set, such as integers, dyadic rationals, or bounded-bit rationals;
2. the bit length charged to each parameter;
3. whether parameters may depend nonuniformly on the target and tolerance;
4. whether the target is approximated at one input or uniformly over a domain;
5. the computational cost of generating target-dependent parameters.

The present construction answers the nonuniform, single-target question under binary hidden biases and fixed integer hidden weights.

### 9.3 Piece counts do not provide a single-point lower bound

A depth-$L$, width-$w$ ReLU network represents a piecewise-affine function whose number of regions is controlled by its architecture. Such geometric complexity is relevant for uniform approximation of functions with many changes in slope. It does not by itself obstruct matching one scalar value at one input. A constant output has only one affine piece, yet an unrestricted parameter can encode arbitrarily much information.

Accordingly, lower bounds for this problem must use quantization, bit complexity, uniformity, robustness, or domain-wide approximation—not only region counting.

### 9.4 Comparison with series-based constructions

One might approximate $\pi$ through the Leibniz series

$$
\frac\pi4=1-\frac13+\frac15-\frac17+\cdots.
$$

After $N$ terms, the alternating-series error is at most $1/(2N+1)$ before multiplication by $4$, so obtaining error $\varepsilon$ requires $N=O(1/\varepsilon)$. A network implementation would additionally need representations of division and summation.

The binary-prefix construction has exponentially decreasing truncation error in the number of stored bits, but it assumes those bits are already available. The two approaches therefore measure different resources: the series supplies a uniform rule with slower elementary convergence, whereas the binary compiler supplies nonuniform advice with direct $2^{-n}$ accuracy. Comparing them fairly requires charging for digit generation.

## 10. Applications

### 10.1 Auditable constant modules

Quantized networks embedded in numerical systems may need certified constants. The recurrence offers a transparent module whose internal state and output interval can be audited after every layer. A consumer can stop at any depth and retain the guarantee $0<\pi-y_n<2^{-n}$.

### 10.2 Progressive precision

The construction is naturally progressive. Extending a depth-$n$ network by one layer preserves all previous work and appends one bit. This is useful when a computation requests precision adaptively rather than fixing it in advance.

### 10.3 Separation of advice and execution

The example provides a minimal laboratory for nonuniform computation. The architecture and transition rule are fixed; only the advice bits vary with the target. This makes it possible to ask clean questions about how many target-dependent bits are necessary, how robustly they can be stored, and which constants admit efficient uniform generators.

### 10.4 General positive constants

For any positive real $x$, the same prefix recurrence compiles its binary truncations. Irrationality ensures strict lower error; rational targets may eventually become exact if their denominator is a power of two. For $e$ and $\sqrt2$, one obtains the same architectural guarantees once their binary digits are supplied.

## 11. Future Work

The first structural extension is to express the recurrence as a full finite-network object with an explicit evaluator, parameter list, depth, width, and readout. This would make resource accounting intrinsic rather than descriptive.

Second, parameter count should be paired with bit complexity. The hidden computation uses one repeated small integer weight and one advice bit per layer, while the readout $2^{-n}$ has a succinct exponent representation but an $O(n)$-bit denominator in expanded form. Different encoding conventions should be stated explicitly.

Third, one should develop a uniform generator for the digit sequence. A circuit or machine that computes $b_n$ would separate the finite program describing $\pi$ from the nonuniform storage of its first $n$ bits. The combined cost of generation and network evaluation would support meaningful comparisons with rapidly convergent formulas for $\pi$.

Fourth, quantized lower bounds are needed. If a network of bounded size uses parameters from a finite alphabet, elementary counting limits how many target prefixes it can represent. Stronger lower bounds may account for robustness under parameter perturbations or require one architecture to serve a family of constants.

Fifth, uniform approximation on an interval changes the problem qualitatively. Geometric complexity and the number of affine regions then become relevant, especially for functions such as multiplication, reciprocal, and trigonometric maps needed by arithmetic algorithms.

Finally, continued fractions offer a second Diophantine compiler. Their convergents often provide error on the order of the reciprocal square of the denominator, but their variable partial quotients and division operations demand a richer network arithmetic. A fair comparison among binary truncation, continued fractions, and analytic series should charge storage, parameter precision, digit generation, and execution separately.

## 12. Conclusion

A width-one rectified network can reproduce the lower dyadic approximations of $\pi$ exactly. At each layer, multiplication by $2$ shifts the current binary prefix and a binary bias appends the next digit. Positivity keeps the trajectory in the linear region of the rectifier. The hidden state at depth $n$ is

$$
\left\lfloor2^n\pi\right\rfloor,
$$

and the normalized output satisfies

$$
0<\pi-y_n<2^{-n}.
$$

Thus every positive tolerance is attained, with sufficient depth $O(\log(1/\varepsilon))$. The theorem is strongest when read as an exact arithmetic-to-network compiler under a transparent parameter restriction. It does not hide the central complexity issue: the binary biases carry target-dependent information. By making that information explicit, the construction replaces vague claims about neural approximation of constants with a precise foundation for studying quantization, advice, bit generation, and lower bounds.