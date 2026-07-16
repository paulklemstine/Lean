# The Anti-Fibonacci Mirage: How a Rebellious Sequence Revealed a Hidden Parabola

The Fibonacci sequence is mathematics’ most famous additive snowball. Begin with two ones, repeatedly add the previous two terms, and the list grows

$$
1,1,2,3,5,8,13,\ldots.
$$

Its neighboring ratios settle toward the golden ratio, and its fingerprints appear in branching plants, efficient search procedures, tilings, and population models. So an “anti-Fibonacci” sequence sounds irresistible: what happens if numbers refuse to follow Fibonacci addition?

One proposed answer began

$$
1,1,2,4,7,11,16,\ldots.
$$

The list was accompanied by a provocative story. Each new term was said to be the smallest positive integer unequal to the sum of the preceding two. It was expected to grow like one quarter of a square, and its successive ratios were supposed to oscillate rather than settle.

There is just one problem: the story and the numbers do not agree.

That mismatch is not a disappointment. It is the doorway to a cleaner and more surprising piece of mathematics. The displayed sequence is not governed by an evasive greedy rule at all. Its successive jumps are

$$
0,1,2,3,4,5,\ldots.
$$

Once that simple pattern is recognized, the apparent anti-Fibonacci mystery becomes an exact quadratic theory, complete with shifted squares, widening gaps, sparse values, and a sharp comparison with genuine Fibonacci growth.

## First, repair the definition

Let $A(0)=1$, and define the sequence by

$$
A(n+1)=A(n)+n
$$

for every nonnegative integer $n$. This recurrence generates exactly

$$
A(0),A(1),A(2),A(3),A(4),A(5),A(6)=1,1,2,4,7,11,16.
$$

It is important not to blur this definition with the proposed greedy rule. If one merely asks for the smallest positive integer unequal to one forbidden sum, then $1$ is almost always available; that rule does not produce the displayed list. The mathematics here concerns the sequence actually determined by the data.

Adding the increments $0+1+\cdots +(n-1)$ gives the closed form

$$
A(n)=1+\frac{n(n-1)}{2}.
$$

These are triangular numbers shifted upward by one. Geometrically, $n(n-1)/2$ counts the pairs chosen from $n$ objects, so $A(n)$ counts all such pairs plus one distinguished extra object. The sequence is therefore connected not to elusive avoidance but to one of combinatorics’ most basic counting patterns.

This formula immediately corrects the proposed scale. Since

$$
A(n)=\frac12n^2-\frac12n+1,
$$

we have

$$
\frac{A(n)}{n^2}=\frac12-\frac{1}{2n}+\frac{1}{n^2},
$$

and hence the ratio tends to $1/2$, not $1/4$. At one million,

$$
A(1{,}000{,}000)=499{,}999{,}500{,}001,
$$

so

$$
\frac{A(1{,}000{,}000)}{10^{12}}=0.499999500001.
$$

The numerical evidence does not merely lean away from one quarter; the exact formula rules it out.

## The shifted-square surprise

The most elegant identity appears when two consecutive terms are added.

**Shifted-Square Theorem.** For every nonnegative integer $n$,

$$
A(n)+A(n+1)=n^2+2.
$$

The proof is a one-line calculation. Substituting the closed form gives

$$
\left(1+\frac{n(n-1)}2\right)+
\left(1+\frac{n(n+1)}2\right)=n^2+2.
$$

Thus the consecutive sums are

$$
2,3,6,11,18,27,38,\ldots,
$$

which are precisely two more than the squares

$$
0,1,4,9,16,25,36,\ldots.
$$

This is not merely a pattern covering the first few terms. It completely characterizes the spectrum of consecutive sums: a nonnegative integer $m$ occurs as $A(n)+A(n+1)$ for some $n$ if and only if $m=n^2+2$ for some nonnegative integer $n$. Testing membership therefore requires no sequence generation. Subtract $2$ and ask whether the result is a perfect square.

The identity has a pleasing visual explanation. The two triangular parts of $A(n)$ and $A(n+1)$ fit together to make an $n$-by-$n$ square; the two added units remain as the $+2$. Two staircases become one square.

There is another square hidden in each individual value:

$$
8A(n)-7=(2n-1)^2.
$$

So every term yields an odd square after the affine transformation $x\mapsto 8x-7$. Conversely, if $8m-7$ is the square of a positive odd integer, then $m$ belongs to the value set. This square test turns a recurrence-membership question into elementary arithmetic.

## Gaps that keep opening

Because the recurrence itself says

$$
A(n+1)-A(n)=n,
$$

the gaps are exactly linear. Given any desired width $C$, choosing $n>C$ produces a gap larger than $C$. Far along the list, the sequence leaves increasingly large deserts of missing integers between successive values.

That observation explains why the value set has density zero. Up to a large threshold $X$, a quadratic sequence contributes only on the order of $\sqrt{X}$ distinct values. Compared with all $X$ positive integers up to the threshold, the occupied proportion is therefore on the order of $1/\sqrt{X}$, which tends to zero.

This sparsity must be described carefully. It concerns the values of the quadratic sequence defined above. It does not validate claims about a different greedy construction, nor does it say that “numbers representable as sums of earlier terms” form the same set. Precision about the object is part of the result.

## Why the quarter-square prediction cannot be rescued

Perhaps $n^2/4$ is not exactly right but remains within a fixed error? The closed form shows that even this weaker hope fails.

**Unbounded Quarter-Square Error Theorem.** For every nonnegative constant $C$, there is a nonnegative integer $n$ such that

$$
A(n)>\frac{n^2}{4}+C.
$$

Indeed,

$$
A(n)-\frac{n^2}{4}=\frac{n^2}{4}-\frac n2+1,
$$

which grows without bound. Thus no statement of the form

$$
A(n)=\left\lfloor\frac{n^2}{4}\right\rfloor+O(1)
$$

can hold. The discrepancy is not a small correction; it has quadratic order.

The neighboring ratios are equally decisive. For positive $n$,

$$
\frac{A(n+1)}{A(n)}=
\frac{n^2+n+2}{n^2-n+2},
$$

which tends to $1$. There is no oscillation between $1$ and $2$. Polynomial growth makes consecutive terms relatively closer and closer, even while their absolute difference grows larger and larger. This contrast—relative closeness alongside absolute separation—is a characteristic feature of quadratic sequences.

## A race against Fibonacci growth

The corrected sequence still earns an illuminating comparison with Fibonacci numbers. Let $F_0=0$, $F_1=1$, and $F_{k+2}=F_{k+1}+F_k$. Then for every $n\ge 6$,

$$
A(n)<F_{2n+1}.
$$

At $n=6$, the comparison is $16<233$. After that, the quadratic adds only $n$ at each step, while the odd-index Fibonacci subsequence has an addition law strong enough to preserve and enlarge the lead. The inequality can be proved by induction using the Fibonacci recurrence and the elementary bound that sufficiently advanced Fibonacci numbers dominate their indices.

The same odd-index Fibonacci numbers also arise as row sums of a Pascal–Riordan combinatorial array. Consequently, from row $6$ onward, those row sums exceed $A(n)$. This gives a bridge between two counting worlds: one built from triangular accumulation, the other from a structured array whose totals grow exponentially.

The comparison is a lesson in growth rates. A parabola can look formidable at first, but exponential growth eventually leaves every fixed-degree polynomial behind. Here the victory is not merely eventual in an unspecified sense; it is guaranteed from the explicit index $6$.

## Three fast experiments anyone can perform

The structure is visible even without advanced tools. A first experiment is a difference table. Write two rows:

$$
\begin{array}{c|rrrrrrr}
n&0&1&2&3&4&5&6\\ \hline
A(n)&1&1&2&4&7&11&16\\
A(n+1)-A(n)&0&1&2&3&4&5&
\end{array}
$$

The bottom row identifies the recurrence immediately. Difference tables play for discrete data the role that derivatives play for curves: constant first differences suggest a line, while constant second differences suggest a parabola. Here the first differences themselves rise linearly, so the values must be quadratic.

A second experiment checks the square spectrum. Add adjacent entries, subtract $2$, and take square roots:

$$
(1+1)-2=0^2,
\quad
(1+2)-2=1^2,
\quad
(2+4)-2=2^2,
\quad
(4+7)-2=3^2.
$$

The square roots recover the indices in order. This is an unusually transparent encoding: the location of a consecutive sum can be read directly from the number itself.

A third experiment compares scales. For $n=10$, $100$, and $1000$, the normalized values $A(n)/n^2$ are $0.46$, $0.4951$, and $0.499501$. Each extra decimal range pushes the ratio toward $0.5$. Meanwhile, the neighboring ratio moves toward $1$, and the raw gap moves upward without bound. Watching all three quantities together prevents a common intuition trap: a growing gap does not imply a growing ratio.

## What the failed story teaches

The original “anti-Fibonacci” narrative promised a sequence that dodged addition and the golden ratio. The data told a different story. Reading the differences exposed triangular accumulation; triangular accumulation yielded a quadratic formula; pairing neighboring triangles produced shifted squares; and the exact formula settled every asymptotic question.

This chain of discoveries illustrates a central mathematical habit: when a definition, a list of examples, and a conjecture pull in different directions, do not average them together. Test them against one another. A contradiction at the level of the first few terms can prevent pages of argument about the wrong object.

The corrected sequence remains worthy of study. Its transformed values lie on odd squares, its consecutive sums lie two above squares, and intersections between those two spectra lead naturally to quadratic Diophantine equations of Pell type. Its modular behavior asks which residue classes can contain transformed squares. Its counting function invites sharp formulas. Families with recurrence $B(n+1)=B(n)+an$ offer a wider laboratory in which quadratic value sets compete with Fibonacci coincidences.

So the deepest result is not that an anti-Fibonacci sequence defeats the golden ratio. It is that the displayed numbers refuse the mythology imposed on them. They are not chaotic rebels. They are a parabola in disguise—and once the disguise is removed, squares appear everywhere.

That transformation from a misleading label to an exact structure is itself a model of discovery: compute carefully, define honestly, and let the integers tell their own story.
