# Beyond Power Series: The Strange Arithmetic of Things That Grow Forever

## A number system built for infinity

Ask a calculus student how fast a function grows, and they will reach for a
familiar toolbox: polynomials, exponentials, logarithms. We say $x^2$ grows
faster than $x$, that $e^x$ outruns every polynomial, and that $\log x$ creeps
upward so slowly it seems almost to stand still. These statements feel obvious.
But they hide a deep question: *is there a single, self-consistent number system
in which all of these growth rates live side by side — and in which we can do
ordinary algebra?*

The answer is yes, and its name is **transseries**. A transseries is an
asymptotic expansion that is allowed to mix powers, logarithms, exponentials, and
even towers of exponentials like $e^{e^x}$, all in one formal object. Where an
ordinary power series can only describe behavior like $1 + x + x^2 + \dots$, a
transseries can describe genuinely wild objects such as

$$e^{e^x} + 3\,e^x \cdot x^{1/2} - 7 + \frac{2}{x} + \frac{\log x}{x^2} + \cdots$$

This article tells the story of a rigorous, machine-checked construction of the
field of transseries, and of three things we can prove about it: that powers are
*formally* powerless against exponentials, that a transseries is uniquely pinned
down by its asymptotic expansion, and that this number system is rich enough to
take square roots and $n$-th roots — the property that, in the classical theory,
makes transseries a *real closed field*, an arithmetic universe as complete as the
real numbers themselves.

## The trouble with power series

Power series are the workhorses of analysis. Near a point, almost any smooth
function looks like an infinite polynomial. But power series have a built-in
ceiling: each one carries a single notion of "size," its **order** — the exponent
of its smallest nonzero term. The order of $3x^2 + 5x^7$ is $2$, because near
zero the $x^2$ term dominates.

This works beautifully until you try to compare a power series with an
exponential. The function $e^x$ has no finite order in the world of powers of
$x$: it beats $x$, it beats $x^{10}$, it beats $x^{1000}$, it beats $x^a$ for
*every* real $a$, no matter how astronomically large. There is simply no slot in
the power-series filing cabinet where $e^x$ belongs. You cannot say "$e^x$ is the
$x^{\infty}$ term," because $\infty$ is not a number.

Transseries fix this by enlarging the filing cabinet. Instead of indexing terms
by a single exponent, we index them by an entire *hierarchy* of growth scales.

## Transmonomials: a periodic table of growth

The building blocks of a transseries are called **transmonomials**. A
transmonomial is a formal product of powers drawn from a whole tower of scales:

$$\cdots (e^{e^x})^{a_2} \cdot (e^x)^{a_1} \cdot x^{a_0} \cdot (\log x)^{a_{-1}} \cdots$$

Each scale sits at an integer **tower height** $h$. Height $0$ is the ordinary
variable $x$. Height $1$ is $e^x$. Height $-1$ is $\log x$. Height $2$ is the
double exponential $e^{e^x}$, and so on, climbing up toward faster and faster
growth and down toward slower and slower growth. A transmonomial records, for
each height, the real exponent of that scale; only finitely many of these
exponents are allowed to be nonzero.

Formally, then, a transmonomial is just a **finitely supported function from the
integers (heights) to the reals (exponents)**. In the verified construction this
is written `ℤ →₀ ℝ` — finitely supported maps from $\mathbb{Z}$ to $\mathbb{R}$.

The genius is in how we *order* these monomials, because that order is exactly the
notion of asymptotic dominance. We compare two transmonomials **lexicographically,
giving the highest tower height the most weight**. To decide which of two
transmonomials is bigger, look first at the highest height where they differ:
whoever has the larger exponent there wins outright, no matter what happens at
lower heights.

This single rule encodes all of our intuitions at once:

- **Higher towers always win.** $e^{e^x}$ (height $2$) beats any power of $e^x$
  (height $1$), which beats any power of $x$ (height $0$), which beats any power
  of $\log x$ (height $-1$). In the verified development this is the theorem
  `mono_lt_mono_of_height`: *a transmonomial of strictly higher tower height (with
  positive exponent) dominates any transmonomial of lower height, whatever its
  exponent.*

- **At the same height, the larger exponent wins.** $x^3$ beats $x^2$, exactly as
  it should. This is the theorem `mono_lt_mono_same`.

The crown jewel is the formal statement that exponentials annihilate powers,
proved as `exp_dominates_pow`:

> For **every** real number $a$, the transmonomial $e^x$ dominates the
> transmonomial $x^a$.

Read that quantifier carefully: *every* real $a$, including $a = 10^{100}$. No
single order in the power-series world can express this. Here it falls out
cleanly from the lexicographic order, because $e^x$ lives one tower height above
every power of $x$.

## From monomials to series — and a free field

Once we have a linearly ordered group of transmonomials, we build transseries the
way mathematicians build all generalized series: as **Hahn series**. A Hahn
series is a formal sum $\sum_g c_g \cdot g$, with real coefficients $c_g$, whose
collection of nonzero terms forms a *well-ordered* set (every nonempty subset has
a smallest element). Well-orderedness is the magic condition that lets you add,
multiply, and even *divide* such infinite sums without ever needing to compute an
infinite numerical sum.

A foundational theorem of algebra — Hahn's theorem — says that when the value
group is linearly ordered and the coefficients form a field, the Hahn series
themselves form a field. Applying this to our ordered group of transmonomials and
real coefficients, we obtain:

> **The transseries form a field.**

Addition, subtraction, multiplication, and division by any nonzero element all
make sense. This is not an analytic miracle requiring convergence; it is pure
algebra, and in the formal development it is simply inherited from the general
Hahn-series field construction.

Every transseries now carries a **valuation**, written `orderTop`: the
transmonomial of its leading (most dominant) term, or the symbol $\top$
("infinitely small") reserved for the zero series. The valuation behaves
multiplicatively — the leading term of a product is the product of the leading
terms, `orderTop_mul` — and it is the rigorous replacement for the single
"order" of a power series. The real numbers sit inside this field as the constant
transseries (`C_injective`), so transseries genuinely extend ordinary arithmetic.

## The comparison theorem: expansions don't lie

Here is a question that sounds philosophical but turns out to be a precise
theorem. Suppose you compute the asymptotic expansion of a function term by term —
its leading behavior, then the next correction, then the next — and you never
stop. Could two genuinely different functions produce the *same* expansion all the
way down? Could the expansion secretly lose information?

For transseries, the answer is a reassuring **no**. We formalize the idea of two
transseries "agreeing to all orders": their difference is asymptotically smaller
than *every* transmonomial — smaller than every conceivable scale of growth. The
**asymptotic comparison theorem** (`agreeToAllOrders_iff_eq`) then states:

> Two transseries agree to all orders **if and only if** they are equal.

In other words, the asymptotic expansion of a transseries is a perfect
fingerprint. Nothing hides "below all orders." If two transseries match scale by
scale, they are literally the same object. The proof is a clean piece of valuation
logic: the only way for a difference to be smaller than every transmonomial is for
its valuation to be $\top$, and the only element with valuation $\top$ is zero. As
a bonus, "agreeing to all orders" is verified to be an equivalence relation
(`agreeToAllOrders_equivalence`) — which, given the theorem, just confirms that it
*is* equality in disguise.

This is the formal heart of why asymptotic analysis works at all. When physicists
and engineers expand a solution in powers of a small parameter and trust the
result, they are implicitly relying on a uniqueness principle of exactly this
kind.

To make sure the formal order is not an empty abstraction, the development also
ties it back to honest real analysis. The theorem `isLittleO_pow_exp` proves that
every polynomial $x^n$ is little-o of $e^x$ at infinity — the analytic shadow of
the formal `exp_dominates_pow`. And `isLittleO_expPow_expExp` proves that every
power of $e^x$ is little-o of $e^{e^x}$, the analytic shadow of "higher towers
win." The formal order and the analytic order agree.

## A non-Archimedean world

Transseries form an **ordered** field, and a strange one. The element $x$ is a
*positive infinitesimal*: it is bigger than zero, yet smaller than every positive
fraction $\tfrac{1}{n+1}$ (`x_infinitesimal`). Meanwhile $1/x$ is *infinite*: it
exceeds every natural number $n$ (`inv_x_infinite`). And of course they are
reciprocals, $x \cdot \tfrac1x = 1$ (`x_mul_inv_x`).

A field with infinitesimals and infinities is called **non-Archimedean** — it
violates the Archimedean principle that you can always reach any size by adding $1$
to itself enough times. The transseries field is non-Archimedean in the most
vivid possible way, with infinitely many distinct scales of infinity ($x$,
$e^x$, $e^{e^x}$, …) and infinitely many distinct scales of smallness. Crucially,
$\mathbb{R}$ still embeds as an ordered subfield: real constants compare exactly
as they do on the number line (`C_lt_iff`, `C_strictMono`).

## Roots and real closure: why real exponents matter

Now for the property that elevates transseries from "a useful bookkeeping device"
to "a complete arithmetic universe." A **real closed field** is, informally, a
field that behaves like the real numbers for the purposes of algebra and order:
every positive element has a square root, and every odd-degree polynomial has a
root. Real closure is the algebraic analogue of having no holes.

The classical theory of transseries proves they are real closed. The verified
development here establishes the decisive structural *ingredients* of that result,
and pinpoints exactly why ordinary Laurent series fall short.

The key is the **value group** — the group of all the leading scales. For an
ordinary Laurent or formal power series, exponents are integers, and the value
group is $\mathbb{Z}$. To extract a square root of a monomial you must halve its
exponent — but you cannot halve an odd integer and stay inside $\mathbb{Z}$. The
verified theorem `laurent_value_group_not_divisible` makes the obstruction
brutally concrete:

> There is no integer $k$ with $2k = 1$.

That single missing solution is the entire reason Laurent series fail to be real
closed. Transseries dodge it by allowing **real** exponents. Now halving is always
possible, and the development proves the value group is **divisible**
(`valueGroup_divisible`): for every transmonomial $g$ and every positive integer
$n$, there is a transmonomial $g'$ with $n \cdot g' = g$. Concretely you just
divide every exponent by $n$.

From divisibility, root extraction follows. The theorem `exists_nthRoot_term`
shows every one-term transseries has an $n$-th root for every $n > 0$, and its
special case `isSquare_term` shows every one-term transseries is a perfect square.
The recipe is exactly the intuitive one: to take the square root of a monomial,
halve all its exponents. With integer exponents this is impossible; with real
exponents it is automatic. That contrast — `laurent_value_group_not_divisible`
versus `valueGroup_divisible` — is the cleanest possible explanation of why
mathematicians had to invent transseries in the first place.

## Climbing the tower: the exp-shift symmetry

There is one more piece of structure worth meeting: the **exp-shift**. Applying
the exponential to the variable, $x \mapsto e^x$, ought to slide every scale up by
one tower height — turning $x$ into $e^x$, turning $e^x$ into $e^{e^x}$, and
turning $\log x$ back into $x$. The development realizes this as an actual
**field automorphism** of the transseries (`expShiftEquiv`): a structure-preserving
symmetry of the entire number system, with an inverse log-shift that slides
everything back down. It is verified to send the variable to the exponential
(`expShift_var`) and to be a genuine isomorphism (`logShift_expShift`,
`expShift_logShift`). This makes precise the idea that the tower of growth scales
is *self-similar*: it looks the same one level up as it does where you started,
and there is always another exponential waiting above any scale you name
(`exists_exp_tower_gt`).

## Why this matters

Transseries are not an exotic curiosity. They are the natural habitat of solutions
to differential equations that cannot be solved in closed form, of asymptotic
expansions in physics, and of the modern theory of o-minimal structures and
model theory of the real exponential field. They are central to **resurgence
theory**, the framework physicists use to extract sense from divergent series in
quantum field theory and string theory. The reason all of these fields can treat
asymptotic expansions as honest algebraic objects — adding them, multiplying them,
inverting them, taking roots — is that those expansions live in a real closed,
non-Archimedean field with a faithful valuation.

What this construction delivers is that whole edifice, built from the ground up
and checked to the last detail: an ordered field where exponentials provably crush
every power, where every expansion uniquely determines its function, and where the
real exponents that distinguish transseries from mere Laurent series are exactly
what unlock square roots and real closure. It is a small, complete window into how
infinity can be made to obey the ordinary rules of arithmetic.
