# The Hidden Ledger: When a Faster Algorithm Is Only Half as Fast as It Claims

*How a fifty-year-old factoring trick taught us a precise rule for when "doing less work" really means "finishing sooner", and how one innocent-looking exponent can make the same trick a hundred times slower.*

---

## A snake that bites its own tail

Pick a large number $N$ that you suspect is the product of two primes, say $N = p \cdot q$. You want $p$, but you don't know it. In 1975 John Pollard suggested something that sounds almost too lazy to work. Choose a simple map, usually

$$f(x) = x^2 + c \pmod N,$$

pick a seed $x_0$, and just iterate: $x_1 = f(x_0)$, $x_2 = f(x_1)$, and so on. Then wait.

Here is why waiting pays off. The secret prime $p$ is quietly watching. If you reduce every $x_i$ modulo $p$, you get a walk on only $p$ possible values. Sooner or later it must revisit a value, and once it does, it is trapped: every later step repeats an earlier one. Draw the walk and it looks like the Greek letter $\rho$. There is a **tail** of some length $\mu$, which then runs into a **cycle** of some length $\lambda$. That is the shape that gives *Pollard's rho method* its name.

The trick is that you can detect the loop modulo $p$ without knowing $p$. If $x_i \equiv x_j \pmod p$, then $p$ divides $x_i - x_j$, so $\gcd(x_i - x_j, N)$ is very likely to equal $p$ itself. Because the map behaves roughly like a random function, the birthday paradox says the first repeat arrives after about $\sqrt{\pi p/2} \approx 1.2533\sqrt{p}$ steps. That is the square root of the size of the haystack, far smaller than the $p$ steps that trial division would need.

What remains is an engineering question with a long history: **how do you notice that you have entered the loop**, using only a couple of stored numbers?

## Two classic loop detectors

**Floyd's tortoise and hare.** Run two walkers, one taking a single step at a time and one taking two. At step $i$, compare $x_i$ with $x_{2i}$. Once both are on the cycle, the hare gains one position per step and eventually laps the tortoise. Each round costs **three** applications of $f$ (one for the tortoise, two for the hare) and **one** comparison, which in factoring is one gcd.

**Brent's teleporting tortoise.** In 1980 Richard Brent proposed a thriftier scheme. Park a marker at position $2^k - 1$. Let a single walker run ahead for up to $2^k$ steps, comparing each new point with the marker. If there is no match, move the marker to where the walker now stands, double the budget, and repeat. Each step costs **one** application of $f$ and **one** comparison.

Brent's method is celebrated as the faster of the two, and in the currency most analyses use, the number of applications of $f$, it is. For $f(x) = x^2 + c$ one application is one modular multiplication, a "group operation". So the question looks settled.

It isn't quite settled, and the reason why is the subject of this article.

## Two ledgers, not one

Every run of rho has (at least) two cost ledgers:

1. **The counted ledger**: modular multiplications, the number that textbooks and complexity analyses usually report.
2. **The uncounted ledger**: comparisons, meaning the gcds and subtractions that actually spot the collision. They are rarely tallied because each one "should be cheap".

The two detectors line up on opposite sides of this split. On a cycle of length $\lambda$ with no tail, Floyd does $3\lambda$ multiplications but only $\lambda$ comparisons. Brent does far fewer multiplications, yet his comparison count equals his multiplication count, because he compares after every single step.

Writing $F$ for Floyd's stopping index and $B$ for the number of steps Brent takes, the situation can be stated exactly, for **every possible rho shape** (every tail $\mu \ge 0$ and every cycle length $\lambda \ge 1$):

> **Theorem (the survivor).** Brent always uses strictly fewer evaluations of $f$ than Floyd. More precisely, $B + 1 \le 2F + \lambda \le 3F$.
>
> **Theorem (the other ledger).** Floyd never uses more comparisons than Brent: $F \le B$.

So the ratio of Brent's work to Floyd's work in the counted ledger can never reach 1, whatever the shape. In the uncounted ledger the inequality points the other way, also whatever the shape. A claim that mentions only the first ledger is not false, but it describes half of the books.

## The boundary, stated as a law

Suppose a multiplication costs $a$ units of time and a comparison costs $b$. Then the wall-clock cost of a run is

$$W = a \cdot (\text{evaluations}) + b \cdot (\text{comparisons}).$$

Simple algebra turns "Brent beats Floyd on the clock" into a precise balance:

$$W_{\text{Brent}} < W_{\text{Floyd}} \iff b \cdot (\text{comparison overrun}) < a \cdot (\text{evaluation saving}).$$

From this the general rule falls out, and it is the main conceptual point of the work:

> **The local-win law.** A local improvement to an algorithm survives into real-world speed **if and only if** it reduces the counted operations *without changing what each operation costs*, and *without increasing the operations that are not being counted*.

Is this just a cautionary tale, or can the hidden ledger really reverse the verdict? It really can. For **any** positive comparison cost $b$, however small next to the multiplication cost $a$, some loop shape makes Brent strictly slower than Floyd. The bad shapes are pure cycles (no tail) whose length sits just past a power of two, $\lambda = 2^m + 1$. On such a cycle:

- Floyd uses $3(2^m + 1)$ evaluations and $2^m + 1$ comparisons;
- Brent uses $3 \cdot 2^m$ evaluations **and** $3 \cdot 2^m$ comparisons.

Brent saves exactly **three** multiplications and pays $2^{m+1} - 1$ extra comparisons. Even if a comparison costs only 5% of a multiplication, Floyd already wins on the clock at $\lambda = 65$. Brent's lead in the counted ledger is guaranteed, and the hidden ledger can still erase it.

## What the measurements say

On random instances, Brent's advantage holds up well. Experiments on Pollard rho, with semiprimes $N < 2^{62}$ and the hidden prime $p$ ranging between $2^{19}$ and $2^{29}$, gave these figures:

- Brent needs about $1.62\sqrt{p}$ multiplications on average and Floyd about $2.24\sqrt{p}$. Within paired runs on the same instance, the ratio is $0.733 \pm 0.150$: a **26.7%** cut in group operations, stable across scales spanning a factor of 32 in $\sqrt p$.
- The cut is real, so Brent is a **genuine survivor**. It reduces the count without changing the cost per operation, since it still applies $x^2 + c$ once per step.
- Yet the hidden ledger takes a large share of it. Gcds fell by only 14.7%, because Brent's stopping index is about $2.18$ times Floyd's, so it performs *more gcds per multiplication* ($0.636$ against $0.501$). On the wall clock the 26.7% saving shrank to **13.8%**. The uncounted channel absorbed 11.9 of the 26.7 percentage points, roughly 46% of the advertised gain.

So a sentence of the form "Brent is 27% faster" overstates the practical gain by about a factor of two. The same experiment also shows why it is not a wash: Brent keeps a real advantage, because it changed only the counted ledger and changed it a lot.

Two more observations sharpen the picture.

**Batching gcds hardly matters.** The standard trick of multiplying 32 differences together and taking one gcd removed **96.1%** of the gcds and bought just **0.11%** of wall-clock time. Once comparisons are cheap enough, further savings in comparisons are worth almost nothing. Note the asymmetry: Brent wins by cutting the expensive ledger, while batching cuts the cheap one.

**Brent is already at the floor.** It applies $x^2 + c$, at one multiplication, exactly once per new iterate, the minimum possible for this map. There is no further improvement *of this shape* left to find.

There is also a subtle point about constants. The birthday constant $\sqrt{\pi/2} \approx 1.2533$ concerns the *first* collision. A detector cannot stop at the first collision, because it does not know where the collision is. Brent stops at about 1.76 times the first-collision index and Floyd at about 2.43 times. In the experiments the rho walk itself matched the birthday law closely ($1.2423$ against a simulated $1.2569$), but the implementation pays about **$1.29 \times \sqrt{\pi/2}$**. That figure sits inside the band $1.244$–$1.325$ that Cheon, Hong and Kim measured independently for primes of 1024 bits. And contrary to a common intuition, the "high-probability" cost is not smaller than the average one. The distribution is skewed to the right (Brent's mean is $1.619$, its median $1.693$, its 90th percentile $3.271$).

## The cliff: one exponent, a hundredfold slowdown

The local-win law has a second clause: a win must not change *what an operation costs*. A natural "optimization" violates it in a dramatic way.

Why use $x^2 + c$? Why not $x^3 + c$, or $x^E + c$ for some other exponent? It costs a little more per step, but perhaps the walk mixes better.

Here is what happens. Modulo a prime $p$, the nonzero residues form a cyclic group of order $p - 1$, and the map $x \mapsto x^E$ is a homomorphism of that group. Whether it scrambles or merely shuffles depends on one number:

> **Theorem (the cliff criterion).** For any exponent $E \ge 1$, prime $p$ and constant $c$, the map $x \mapsto x^E + c$ is a **permutation** of the residues modulo $p$ if and only if $\gcd(E, p - 1) = 1$.

A permutation has no tails at all. Every point lies on a cycle, and the walk wanders along that cycle until it returns to exactly where it started:

> **Theorem (pure cycles).** For any injective map of a finite set to itself, every orbit is a pure cycle. The first repeated point is the starting point itself, and Floyd's detector stops at *exactly* the cycle length.

This is the opposite of what rho needs. The birthday paradox works because a random function *merges* paths: many inputs share the same output, so collisions come early. A permutation never merges anything, and its cycles are typically of length comparable to $p$ rather than $\sqrt{p}$. In the extreme case of $x \mapsto x + 1$ (exponent $E = 1$, $c = 1$) every orbit takes exactly $p$ steps to close.

When $\gcd(E, p - 1) = d > 1$, by contrast, the power map is $d$-to-one on the nonzero residues. Its image has at most $(p-1)/d + 1$ elements, and this gives a hard ceiling:

> **Theorem (compression bound).** Every orbit of $x \mapsto x^E + c$ modulo $p$ closes within $(p - 1)/d + 2$ steps, where $d = \gcd(E, p-1)$.

For $x^2 + c$ we always have $d \ge 2$ (for odd $p$), so squaring always compresses. That is the quiet reason the textbook map works.

Now take the prime $p = 65537 = 2^{16} + 1$. Here $p - 1 = 2^{16}$ has no factor of 3, so $\gcd(3, p-1) = 1$ and **$x^3 + c$ is a permutation for every choice of $c$.** In the experiments the cubic walk at this prime was **104.9 times slower** than the quadratic one. On 40-bit semiprimes, splitting the hidden primes by whether $3$ divides $p - 1$, the median cost of the cubic map was $3.43\sqrt{p}$ when it acts as an automorphism, $2.20\sqrt p$ when it compresses, against $1.70\sqrt p$ for the baseline.

So the folklore statement "exponent 2 is optimal" is true *on average* over primes, but the average hides a jump of a factor of about 105 that depends on the arithmetic of $p - 1$. The resource being spent is the **structure of the multiplicative group modulo $p$**, which is exactly what rho relies on to look random. This is clause two of the law seen in action: changing the exponent changed what each operation costs, and it changed the walk itself.

## Lessons for anyone who optimizes

The rule extracted here is not really about factoring. It applies to any algorithm whose speed is quoted in a single unit:

- **Name every ledger.** If your improvement is stated in one unit (multiplications, cache misses, messages, gradient steps), list the operations you are *not* counting and check whether they moved.
- **A survivor is structural, not lucky.** Brent survives because it shrank the expensive ledger by a large factor and left the cost per operation alone. Batching gcds shrank the cheap ledger and bought almost nothing.
- **Averages can hide cliffs.** "Optimal on average" can conceal a discontinuity of a factor of 100 controlled by a single arithmetic condition, here $\gcd(E, p - 1) = 1$.
- **Know where the floor is.** Once a method uses one operation per new piece of information, as Brent does, wins of the same kind are used up.

Pollard's snake has been biting its tail for half a century. It still has something to teach about how to keep honest books.
