# Beyond Base Ten: The Hidden Family of Number Systems

## A number is a story about how you count

Every whole number you have ever written down is a compromise between two things: the *symbols* you are allowed to use and the *place values* those symbols sit on. In our everyday decimal world the symbols are the ten digits $0$ through $9$, and the place values marching leftward from the decimal point are $1, 10, 100, 1000, \dots$ — the powers of ten. The number $273$ is shorthand for

$$273 = 2\cdot 100 + 7\cdot 10 + 3\cdot 1.$$

Computers tell the same story in binary, where the only symbols are $0$ and $1$ and the place values are the powers of two: $1, 2, 4, 8, 16, \dots$. Clockmakers mix systems without thinking about it — sixty seconds to a minute, sixty minutes to an hour, twenty-four hours to a day.

That last example is the tip of a very large iceberg. What if the place values did not have to be the powers of a single fixed base at all? What if each position had its *own* base — its own local rule for how high you are allowed to count before you must carry to the next position? These are the **mixed-radix number systems**, and they turn out to be a single, unified family that contains binary, decimal, the sexagesimal clock, and one especially beautiful oddball called the **factorial number system** — all as special cases of one clean idea.

This article tells the story of that unification: what these systems are, why every number has *exactly one* representation in each of them, and why a strange-looking counting scheme built out of factorials is secretly just another member of the same club.

## The recipe for an "alien" number system

Pick any sequence of **bases**, one for each position:

$$b_0,\ b_1,\ b_2,\ b_3,\ \dots$$

where each $b_i$ is a positive whole number. Position $0$ is the rightmost, least significant slot; position $1$ is next, and so on. The base $b_i$ is the local rule at position $i$: it says the digit in that slot must be one of $0, 1, \dots, b_i - 1$. We call a digit **valid** at position $i$ precisely when it is strictly less than $b_i$.

Now we need the place values. In ordinary base ten the place value of position $i$ is $10^i$ — you get it by multiplying together $i$ copies of the base. In a mixed-radix system you do the same thing, except the bases you multiply are the *actual* bases of the *lower* positions. The place value of position $i$ is the **running product**

$$P_i \;=\; b_0\, b_1\, b_2 \cdots b_{i-1} \;=\; \prod_{j<i} b_j,$$

with the convention that the empty product $P_0 = 1$. Position $0$ is always worth $1$; position $1$ is worth $b_0$; position $2$ is worth $b_0 b_1$; and so on. Each new place value is the previous one multiplied by the base directly beneath it.

Finally, a number written as a string of digits $c_0, c_1, \dots, c_{k-1}$ (with $c_i$ valid at position $i$) stands for the value

$$\text{value} \;=\; \sum_{i<k} c_i\, P_i \;=\; c_0\, P_0 + c_1\, P_1 + \dots + c_{k-1} P_{k-1}.$$

That is the *entire* definition. Two familiar systems drop straight out of it:

- **Base $N$.** Take every base to be the same number, $b_i = N$. Then the running product is $P_i = N^i$, and you recover ordinary base-$N$ notation — binary when $N=2$, decimal when $N=10$.
- **The factorial system.** Take the base at position $i$ to be $b_i = i+1$. Then position $0$ has base $1$ (only the digit $0$ is allowed there), position $1$ has base $2$, position $2$ has base $3$, and so on. The running product becomes

$$P_i = 1\cdot 2\cdot 3\cdots i = i!,$$

the factorial of $i$. The place values are $1!, 2!, 3!, \dots$ wait — more precisely $0! = 1$, $1! = 1$, $2! = 2$, $3! = 6$, $4! = 24$, and a valid digit at position $i$ is any number from $0$ up to $i$.

The factorial system is genuinely strange the first time you meet it. The number $4$ becomes "$20$" (that is $2\cdot 2! + 0\cdot 1! = 4$), and the number $23$ becomes "$321$" (that is $3\cdot 3! + 2\cdot 2! + 1\cdot 1! = 18 + 4 + 1 = 23$). It looks like nonsense — until you realize it is the natural language of *permutations*. There are exactly $i!$ ways to arrange $i$ objects, so the factorial place values are precisely the sizes of the permutation "shells," and the factorial digits are exactly the instructions for picking one permutation out of the pile. This is why the factorial number system is the engine behind algorithms that generate the $n$-th shuffle of a deck directly, without listing all the shuffles before it.

## The one theorem that makes it all work

A number system is only useful if it is unambiguous: each number should have one and only one representation, and every representation should stand for a genuine number. In our decimal world we take this for granted. For this whole family of alien systems it is a theorem — and a surprisingly clean one.

**The Uniqueness Theorem.** *Suppose two strings of valid digits, of the same length $k$, evaluate to the same number. Then the strings are identical: they agree in every position.*

The reason is a chain of two simple facts. The first is a **size bound**: a valid $k$-digit number can never be as large as the running product $P_k$. In symbols, if every $c_i$ is valid then

$$\sum_{i<k} c_i\, P_i \;<\; P_k.$$

This is the mixed-radix version of the obvious statement that a $3$-digit decimal number is always less than $1000$. It follows by a short induction: the top digit contributes at most $(b_{k-1}-1)P_{k-1}$, and everything below it is (by the same claim one size smaller) less than $P_{k-1}$; adding these gives strictly less than $b_{k-1}P_{k-1} = P_k$.

The second fact is a pair of **splitting identities**. Because the lower positions can never accumulate as much as one full place value $P_{k-1}$, the top digit and the tail never interfere. Concretely, if you take a valid number and divide it by the top place value $P_{k-1}$, the quotient is exactly the top digit $c_{k-1}$, and the remainder is exactly the number formed by the lower digits:

$$\text{value} \div P_{k-1} = c_{k-1}, \qquad \text{value} \bmod P_{k-1} = \sum_{i<k-1} c_i P_i.$$

This is just Euclidean division doing what it always does — but the size bound is what guarantees the tail is a legitimate remainder.

With these two tools uniqueness is immediate. If two valid strings share a value, dividing both by the top place value forces their top digits to match; subtracting that top digit off leaves two shorter strings with the same value, and you repeat. Peel, match, repeat, until nothing is left. The digits were forced all along.

The companion result runs the movie backwards.

**The Existence Theorem.** *Every whole number $n$ below the running product $P_k$ has a valid $k$-digit representation — namely the one you get by greedy extraction.* To find the digit at position $i$, divide $n$ by the place value $P_i$ and take the remainder upon dividing by the local base $b_i$:

$$c_i = \left\lfloor \frac{n}{P_i} \right\rfloor \bmod b_i.$$

These extracted digits are automatically valid (a remainder mod $b_i$ is always below $b_i$), and reassembling them reproduces $n$ exactly.

Put the two theorems together and you get the headline: **for each length $k$, the valid $k$-digit strings are in perfect one-to-one correspondence with the numbers $0, 1, 2, \dots, P_k - 1$.** Uniqueness says no two strings collide; existence says none of the target numbers are missed. Every mixed-radix system, no matter how exotic its bases, is a flawless dictionary between digit strings and an initial block of the integers.

## The punchline: the factorial system was never special

Here is the payoff of building the general theory. The factorial number system had its own uniqueness theorem, proved on its own terms: valid factoradic strings (where the digit at position $i$ is at most $i$) represent numbers uniquely. But we can now see that this is not an independent fact at all — it is the general Uniqueness Theorem applied to the single choice of bases $b_i = i+1$.

Three observations line up the two pictures exactly:

1. **Place values agree.** The running product of the bases $1, 2, 3, \dots$ is $i!$, so the factorial place values *are* the mixed-radix place values for these bases. This is the identity $\prod_{j<i}(j+1) = i!$.
2. **Validity agrees.** The factoradic rule "$c_i \le i$" is literally the mixed-radix rule "$c_i < b_i$" for $b_i = i+1$, because being at most $i$ and being below $i+1$ are the same statement for whole numbers.
3. **Values agree.** Since both the place values and the digit bounds match, the two notions of "value" compute the identical sum.

Once these three transports are in place, factorial uniqueness follows as a one-line corollary of the general theorem. The specialized proof was not wrong — it was just a shadow of something larger. The factorial number system is one point in a continuous landscape of positional systems; binary and decimal are other points; the sexagesimal clock is yet another. They all obey the same two theorems because those theorems never cared about the particular bases in the first place. They cared only about the *running product* and the *local digit bound*, and every mixed-radix system has those.

## Why the running product is the whole story

Step back and notice what the general theory quietly reveals. Nowhere in the proofs of uniqueness or existence does the specific value of any single base appear. What appears, over and over, is the running product $P_i$ and the local bound $c_i < b_i$. This has a striking consequence: **all the counting information in a mixed-radix system is encoded in its sequence of running products, not in the bases themselves.**

The set of numbers you can write with $k$ digits is always the clean interval $\{0, 1, \dots, P_k - 1\}$ — an unbroken block of exactly $P_k$ integers. Two different-looking systems that happen to share the same running products at every length are therefore representing exactly the same numbers, in exactly the same quantity, even if their bases were chosen by wildly different rules. "How many numbers fit" is a function of the product alone.

There is even a graceful way the theory handles an apparent catastrophe. What if some base $b_i$ is zero? Then *no* digit is valid at that position — there is no number below zero to choose. Rather than breaking, the theory simply reports that there are no valid representations of that length, and every statement about valid representations holds vacuously and truthfully. The framework does not need a special exception; it absorbs the degenerate case on its own.

## The bigger picture

The moral of this story is one that runs through much of mathematics: the right level of generality does not complicate a result, it *clarifies* it. Number systems look like a topic where you either memorize the rules of base ten in grade school or dabble in binary as a programmer. But underneath the surface, decimal, binary, sexagesimal, and the permutation-flavored factorial system are the same object wearing different costumes. Each is a positional system whose place values are the running products of a chosen sequence of bases; each enjoys perfect uniqueness and existence; and each is, in the end, a bijection between strings of digits and a block of the counting numbers.

Once you see that unifying frame, questions that seemed to belong to separate worlds become the same question. How do you increment a number and resolve the carries? How much room does a fixed number of digits give you? When do two systems represent identical sets of numbers? For the whole family the answers turn on one quantity — the running product of the bases — and the specific identity of any single base fades into the background. That is what it means to find the natural home of an idea: the special cases stop being a list of curiosities and become a single theorem, seen from different angles.
