# A One-Neuron Staircase to Pi

## How binary digits turn a rectified network into an exact Diophantine compiler

The number $\pi$ is easy to name and impossible to finish writing. Its decimal expansion begins $3.14159\ldots$, but no finite list of digits captures it exactly. This familiar tension—simple definition, endless expansion—makes $\pi$ a natural test case for a question at the boundary of number theory and neural computation: how economically can a rectified linear network approximate a particular irrational constant?

At first glance, the answer seems almost embarrassingly easy. A neuron with a freely chosen real bias can simply store $\pi$. Feed it the input $1$, choose the right affine parameters, and the output is exactly $\pi$. But that answer hides all the arithmetic inside one infinitely precise parameter. It is like claiming to compress a library by writing “the library” on the cover while silently assuming the cover can contain unlimited information.

A meaningful construction must say what its parameters are allowed to be. Here the restriction is severe and transparent. Every hidden weight is the integer $2$. Every hidden bias is one of the two bits $0$ or $1$. The network has width one: there is only a single number moving from layer to layer. Under those rules, depth becomes a visible information budget, and the network’s computation can be understood exactly.

## The dyadic staircase

For each nonnegative integer $n$, define the integer

$$
P_n=\left\lfloor 2^n\pi\right\rfloor.
$$

The associated dyadic approximation is

$$
A_n=\frac{P_n}{2^n}.
$$

This is simply $\pi$ rounded downward to $n$ binary places. The first few values are

$$
A_0=3,\qquad A_1=3,\qquad A_2=\frac{12}{4}=3,
$$

$$
A_3=\frac{25}{8}=3.125,\qquad
A_4=\frac{50}{16}=3.125,
$$

and then the staircase climbs ever closer to $\pi$. Each $A_n$ lies on the grid of multiples of $2^{-n}$. Because $\pi$ is irrational, it never lands exactly on a grid point.

The basic floor inequality says

$$
P_n\le 2^n\pi<P_n+1.
$$

Dividing by $2^n$ immediately yields the central error estimate:

$$
0<\pi-A_n<2^{-n}.
$$

This is the **Dyadic Approximation Theorem for $\pi$**: truncating after $n$ binary places approximates $\pi$ strictly from below, and the error is less than one binary unit at that depth. Every extra layer will therefore halve the guaranteed error.

For example, at depth $10$, the error is below $2^{-10}\approx 9.77\times10^{-4}$. At depth $20$, it is below $9.54\times10^{-7}$. At depth $50$, it is below $8.89\times10^{-16}$. The guarantee is exponential in depth, despite the network having only one hidden value at each stage.

## Where the neuron enters

Let the rectified linear unit be

$$
\operatorname{ReLU}(x)=\max\{x,0\}.
$$

Now define the next binary digit of $\pi$ by

$$
b_n=P_{n+1}-2P_n.
$$

A small but decisive theorem states that

$$
b_n\in\{0,1\}
$$

for every $n$. To see why, write $2^n\pi=P_n+r_n$ with $0\le r_n<1$. Doubling gives

$$
2^{n+1}\pi=2P_n+2r_n.
$$

Since $0\le 2r_n<2$, taking the floor adds either $0$ or $1$ to $2P_n$. Thus $P_{n+1}=2P_n+b_n$, with $b_n$ genuinely a bit.

This arithmetic recurrence is already shaped like a neural layer. Start with

$$
h_0=3
$$

and iterate

$$
h_{n+1}=\operatorname{ReLU}(2h_n+b_n).
$$

Because $h_n$ is always nonnegative, the rectifier never clips the signal. Induction gives the **Exact State Theorem**:

$$
h_n=P_n=\left\lfloor 2^n\pi\right\rfloor
$$

at every depth $n$. A final linear readout divides by $2^n$:

$$
y_n=\frac{h_n}{2^n}.
$$

Consequently $y_n=A_n$, and the network output satisfies

$$
0<\pi-y_n<2^{-n}.
$$

The network is not merely close to the dyadic truncation; its hidden state *is exactly the dyadic numerator*. The arithmetic and neural descriptions are two views of the same process.

## What the theorem does—and does not—say

The construction has width one, depth $n$, hidden weights equal to $2$, and one binary bias per layer. To guarantee an error below a prescribed tolerance $\varepsilon>0$, it is enough to choose $n$ so that

$$
2^{-n}<\varepsilon.
$$

Equivalently, any integer depth satisfying

$$
n>\log_2\!\left(\frac1\varepsilon\right)
$$

will do. Thus the required depth grows on the order of $\log(1/\varepsilon)$, not $\log\log(1/\varepsilon)$, for this particular bit-by-bit construction.

There is, however, an essential caveat. The biases $b_0,b_1,\ldots$ are defined from the binary expansion of $\pi$. The network therefore *stores* known digits; it does not discover them. Each new layer reveals one more preselected bit. The result is best understood as an exact compiler from an arithmetic representation into a restricted network architecture.

That distinction matters whenever one speaks about efficiency. If arbitrary real parameters cost only one unit each, approximation at a single input is trivial: the target constant can be placed directly in a parameter. If parameters must instead be integers, bits, or bounded-length rationals, then information has a price. A serious complexity account must specify the alphabet of allowed parameters, charge for their bit length, distinguish stored advice from uniformly generated data, and say whether accuracy is required at one input or across an entire interval.

The number of linear regions in a ReLU network does not settle this issue. Region counting is powerful when a network must approximate a varying function over a domain. But a constant evaluated at one point has no geometric oscillations to resolve. At a single point, arithmetic restrictions—not piece count—carry the real content.

## A tiny shift register with a mathematical certificate

The recurrence can be visualized as a binary shift register. If $h_n$ encodes the first $n$ binary places of $\pi$, multiplying by $2$ shifts the stored bits left, and adding $b_n$ appends the next bit. Division by $2^n$ moves the binary point back to its intended location.

The same principle works for any positive real number $x$. Define

$$
Q_n=\lfloor 2^n x\rfloor,
\qquad
c_n=Q_{n+1}-2Q_n.
$$

Then $c_n$ is always $0$ or $1$, and the recurrence $s_{n+1}=2s_n+c_n$ reproduces $Q_n$. If $x$ is irrational, the approximation $Q_n/2^n$ has strict error between $0$ and $2^{-n}$. This gives parallel numerical experiments for $e$ and $\sqrt2$, while $\pi$ remains the central example.

There is also a revealing contrast with continued fractions. Binary truncation spends one stored bit per factor-of-two improvement in the worst-case error. Continued-fraction convergents can achieve unusually strong accuracy for a given denominator, because they adapt their rational approximants to the arithmetic of the target. Implementing that adaptive arithmetic in a restricted rectified network would require more machinery than a simple shift-and-add recurrence, but it offers a promising route for comparing storage, computation, and approximation quality.

## From a tolerance to a blueprint

Suppose an engineer asks for an approximation within one millionth. The theorem turns that request into a blueprint without trial and error. Choose the first depth for which $2^{-n}<10^{-6}$; $n=20$ works. Prepare the first $20$ transition bits of $\pi$, arrange $20$ identical doubling layers, and attach the normalization $2^{-20}$. The resulting output is below $\pi$, differs from it by less than $10^{-6}$, and carries an integer hidden state that can be checked independently.

This one-sidedness is useful. If the output is used in interval arithmetic, it supplies a certified lower endpoint, while $y_n+2^{-n}$ supplies a certified upper endpoint. Thus the network does more than emit a decimal-looking number: it produces a value enclosed in the explicit interval

$$
\pi\in\left(y_n,\,y_n+2^{-n}\right).
$$

The interval width is known before the network runs. No statistical estimate or training loss is needed. The guarantee comes from the geometry of the dyadic grid and the elementary behavior of the floor function.

## Why this bridge matters

The construction is modest enough to inspect completely. There are no mysterious high-dimensional weights, no training process, and no appeal to a general approximation principle. Every layer performs the same operation: double, add one bit, rectify. Every hidden state has an exact number-theoretic meaning. Every depth comes with a sharp, explicit error interval.

That transparency makes the example useful beyond $\pi$. It isolates three resources that are often blurred together in discussions of neural approximation:

1. **Architecture:** width one and depth $n$.
2. **Parameter alphabet:** the fixed weight $2$ and binary biases.
3. **Arithmetic advice:** the first $n$ bits of the target constant.

Once these resources are separated, the right future questions become clearer. Can a small uniform circuit generate the needed bits rather than merely store them? What lower bounds hold when every parameter has bounded bit length? How does the answer change for approximation on an interval instead of at one input? Can continued fractions beat binary truncation after the computational cost of generating their coefficients is included?

There is a broader lesson here about claims of compression. A short architecture is not automatically a short description when its parameters may carry many bits. Conversely, a long sequence of binary parameters can be perfectly transparent even when it is not computationally surprising. Separating these notions—architectural size, description length, and generation time—turns a slogan about neural power into a well-posed mathematical investigation.

This perspective also encourages honest comparisons: two constructions should be measured under the same rules for parameter precision, advice, input domain, and output certification. Without those shared rules, a smaller diagram may simply conceal a larger number.

The one-neuron staircase does not claim that a network has learned $\pi$. It demonstrates something more precise: a severely quantized, width-one rectified computation can carry a dyadic Diophantine approximation exactly, with one binary decision per layer and an error below $2^{-n}$. The result turns an infinite irrational constant into a sequence of finite, auditable steps—and shows exactly where the information enters.