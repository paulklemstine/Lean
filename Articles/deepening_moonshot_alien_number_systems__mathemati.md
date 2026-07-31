# Counting Backward: How Base Negative Two Gives Every Integer a Unique Binary Address

Most of us meet number systems as a change of costume. Decimal writes twenty-three as $23$; binary writes the same number as $10111$. The symbols differ, but the place values march in the same familiar direction: $1,2,4,8,\ldots$, each larger and positive.

Negabinary changes the plot. Its radix is $-2$, so its place values alternate sign:

$$
1,-2,4,-8,16,-32,\ldots.
$$

Only the digits $0$ and $1$ are allowed. A finite string $b_0,b_1,\ldots,b_{n-1}$, written here from least significant to most significant, has value

$$
V(b_0,b_1,\ldots,b_{n-1})=\sum_{j=0}^{n-1}b_j(-2)^j,
$$

where each $b_j$ is either $0$ or $1$. Thus the bit list $(1,1)$ represents $1-2=-1$, while $(0,1,1)$ represents $0-2+4=2$. The alternating place values let unsigned bits describe negative numbers without a separate minus sign.

That is an attractive trick, but the deeper question is structural. Can every integer be written this way? And if so, could two different bit strings secretly describe the same integer? The answer to both questions is decisive: **every integer has exactly one canonical finite negabinary expansion**.

## What "canonical" means

Ordinary notation has a harmless ambiguity: $7$, $07$, and $007$ have the same value. Negabinary has the same issue at its most-significant end. We therefore call a bit list **canonical** if it is empty, or if its final, most-significant bit is $1$. In other words, leading zeroes are forbidden when the string is displayed in the usual most-significant-first order.

The empty list represents $0$. Every nonempty canonical list ends in $1$. With this convention, the central theorem can be stated cleanly.

**Unique Negabinary Representation Theorem.** For every integer $z$, there exists exactly one finite canonical bit list $(b_0,\ldots,b_{n-1})$ such that

$$
z=\sum_{j=0}^{n-1}b_j(-2)^j.
$$

The theorem says more than "an encoding usually works." It establishes a perfect correspondence between all integers and canonical finite binary strings interpreted at radix $-2$.

## The digit forced by parity

The proof begins with a wonderfully rigid observation. Suppose

$$
z=b_0-2q,
$$

where $b_0\in\{0,1\}$. Reducing modulo $2$ erases the second term, leaving

$$
z\equiv b_0\pmod 2.
$$

So the least-significant digit is not a choice. It must be the Euclidean remainder of $z$ modulo $2$: use $0$ when $z$ is even and $1$ when $z$ is odd. This remains true for negative integers because the Euclidean remainder modulo $2$ is still either $0$ or $1$; for example, $-9$ has remainder $1$.

Let

$$
d(z)=z\bmod 2\in\{0,1\}.
$$

After removing this forced digit, the remainder $z-d(z)$ is even. The next state is therefore

$$
N(z)=-\frac{z-d(z)}{2}.
$$

The minus sign is the signature of the negative radix. By construction,

$$
d(z)-2N(z)=z.
$$

This reconstruction identity is the engine of the conversion algorithm. Repeatedly record $d(z)$ and replace $z$ by $N(z)$. The recorded digits appear least significant first.

For $-9$, the states and digits are

$$
-9\xrightarrow{1}5\xrightarrow{1}-2\xrightarrow{0}1\xrightarrow{1}0.
$$

The resulting list is $(1,1,0,1)$, and indeed

$$
1-2+0\cdot4-8=-9.
$$

For $19$, one obtains $(1,1,1,0,1)$ because

$$
1-2+4+0\cdot(-8)+16=19.
$$

## Why the process always stops

A conversion rule is useful only if it terminates. Here the natural measure is absolute value. Apart from two small exceptional states, each step strictly decreases $|z|$:

**Descent Lemma.** If $z\neq0$ and $z\neq-1$, then

$$
|N(z)|<|z|.
$$

The exceptional value $-1$ is benign rather than dangerous: it moves to $1$, and $1$ moves to $0$. Indeed, $-1$ is represented by $(1,1)$.

Why does descent hold? Since $d(z)$ is either $0$ or $1$,

$$
|N(z)|=\left|\frac{z-d(z)}{2}\right|.
$$

Division by $2$ contracts magnitude. The only place where subtracting $1$ before division can prevent strict contraction is the tiny negative boundary case $z=-1$. Treating that state explicitly leaves a strict decrease everywhere else. Because nonnegative integer magnitudes cannot decrease forever, the process must reach $0$ after finitely many steps.

This gives existence. Starting from any integer, the algorithm produces finitely many bits, and repeatedly applying the reconstruction identity shows that their negabinary value is the original integer. The final recorded bit is $1$ unless the input was $0$, so the output is canonical.

## Why the answer is unique

Existence alone would still allow a strange arithmetic world in which one integer had several unrelated names. Parity rules this out from the bottom upward.

Suppose two canonical bit lists have the same value. Their first bits must agree because the value modulo $2$ recovers the least-significant bit:

$$
V(b_0,b_1,\ldots)\bmod2=b_0.
$$

After the matching first digits are removed, equality of the values implies equality of the remaining tails. The same argument repeats at every position.

There is one endpoint to check: could a nonempty canonical string represent $0$? It cannot. If its first digit is $1$, its value is odd and hence nonzero. If its first digit is $0$, dividing the value equation by $-2$ says that its tail also represents $0$. Continuing toward the most-significant end would eventually claim that the one-bit canonical string $(1)$ represents $0$, which is false. Therefore the only canonical representation of $0$ is the empty list.

These observations prove the **Canonical Injectivity Theorem**: if two canonical finite bit lists have equal negabinary value, then the lists are identical. Combined with the terminating construction, this proves the unique representation theorem.

## A reversible integer coordinate system

The result may be summarized as a bijection:

$$
\{\text{canonical finite bit lists}\}\longleftrightarrow\mathbb Z.
$$

Evaluation sends a bit list to its integer value; repeated parity extraction sends an integer back to its unique list. Each direction undoes the other.

There is also a useful one-step stability principle. For every integer $z$, the forced first bit $d(z)$ can be attached to a canonical expansion of $N(z)$, and the result evaluates to $z$. Symbolically, if a tail $L$ represents $N(z)$, then

$$
V(d(z)::L)=d(z)-2V(L)=d(z)-2N(z)=z.
$$

This local identity explains why the global algorithm is correct. Every iteration preserves a precise reconstruction equation; no guesswork accumulates.

## Arithmetic without a sign bit

Computers usually represent signed integers using conventions such as two's complement. Negabinary offers a different conceptual route: positive and negative integers inhabit one positional system, with no external sign marker. The sign is distributed across alternating place values.

This does not automatically make negabinary superior for conventional hardware. Carry behavior differs from ordinary binary, and fixed-width engineering brings its own constraints. But the system is valuable wherever representation itself matters: unusual arithmetic circuits, coding puzzles, symbolic algorithms, and the study of numeration systems with signed or complex radices.

It also teaches a broader lesson. A positional numeral system is not merely a row of symbols; it is an algorithmic theorem. To establish a genuine number system, one needs a digit-selection rule, a reconstruction law, a termination argument, and a uniqueness proof. In negabinary these pieces fit with unusual elegance:

1. parity forces the next digit;
2. subtracting that digit leaves an even number;
3. division by $-2$ produces the next state;
4. absolute value decreases, apart from the explicit bridge $-1\to1\to0$;
5. parity also proves that two canonical expansions cannot diverge.

The same remainder operation is responsible for both construction and uniqueness. That dual role is the mathematical heart of the story.

There is a useful visual intuition behind the alternating powers. Ordinary binary builds numbers by stacking weights on one side of zero. Negabinary alternates which side receives the next, larger weight. The $1$ place pulls right, the $-2$ place pulls left, the $4$ place pulls right again, and so on. Because each new weight is larger than the total scale of many preceding choices, the expansion can keep correcting direction while retaining a recoverable low-order fingerprint. Parity supplies that fingerprint.

The notation also invites hands-on experimentation. Start with any integer, positive or negative. Mark whether it is even or odd; that mark is the next bit. Subtract the mark, halve, reverse the sign, and repeat. The procedure turns a static integer into a short trajectory that zigzags toward zero. Decoding runs the film backward: begin at zero and repeatedly multiply by $-2$ and add the next digit. Reconstruction guarantees that each frame joins perfectly to the preceding one.

## Beyond negative two

Negabinary is the first stop in a larger landscape. A radix $-b$ with $b\ge2$ should use digits $0,1,\ldots,b-1$ and choose each digit as the Euclidean remainder modulo $b$. Similar descent arguments can seek a unique expansion of every integer.

Other directions are stranger. In base equal to the golden ratio, the identity $\varphi^2=\varphi+1$ creates genuine rewriting ambiguities, so uniqueness requires a normalization such as forbidding consecutive ones. Complex radices can encode lattice points in the plane, replacing absolute value with a geometric norm. In each setting, the central questions remain recognizable: Which digit is forced? Does the remainder shrink? Which strings are canonical? Do local rewriting rules converge to one normal form?

Negative two gives complete answers in their cleanest form. Its digits are as simple as binary, its range covers every integer, and its canonical notation is unique. By allowing place value itself to oscillate, arithmetic gains enough flexibility to write the entire signed number line with nothing but zeroes and ones.

That conclusion reframes what a number base can be. Positional notation need not move monotonically away from zero, nor must negative values wear a special label. A carefully chosen oscillation can encode sign internally, while a simple residue calculation keeps every digit inevitable. Negabinary is therefore both an alien notation and a familiar algorithm: at every step, ask only whether the current number is odd, then let division carry the story onward.