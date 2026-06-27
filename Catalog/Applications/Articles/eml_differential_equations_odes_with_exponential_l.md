# When a Solution Refuses to Be Written Down

## A bridge that almost everyone has crossed without noticing

Sometime in school, most of us meet an equation like $y' = 2y$ and learn the
ritual answer: $y = Ce^{2x}$. We slide an exponential into place, check that it
fits, and move on. The lesson hidden in that small victory is enormous. It says:
*the equation knows its own answer in advance.* The shape of the equation — a
rate of change proportional to the present value — forces the answer to be an
exponential. There is no freedom, no creativity required. The equation dictates.

So here is a question that sounds innocent and turns out to be one of the
deepest in mathematics: **does every nice differential equation have an answer
you can actually write down?** Not "approximate numerically," not "draw on a
graph," but *write* — as a finite formula built from the everyday toolkit of
exponentials, logarithms, roots, powers, and the four arithmetic operations.

The answer is no. And the surprise is not just *that* it is no, but *how
sharply* we can prove it, *which* equations fail, and *why*. This article is
about a small, beautiful corner of that story: the algebra of so-called **EML
functions** (Exponential–Logarithmic functions — the elementary closed forms),
the **Riccati transform** that turns a hard linear equation into a quadratic
one, the **Wronskian** that quietly measures whether two solutions are genuinely
different, and a single famous equation — **Airy's equation** — that stands as a
monument to the limits of closed form.

## The toolkit and its boundary

Call a function *EML* if you can build it from the constants and the variable
$x$ using addition, subtraction, multiplication, division, roots,
exponentials, and logarithms — finitely many times. Polynomials are EML.
$e^x$ is EML. $\log(1+x^2)$, $\sqrt{e^x + x}$, $\frac{x}{1 - e^{-x}}$ — all
EML. This is the universe of "formulas" in the ordinary sense.

Differential equations are the natural inhabitants of this universe. A
**first-order linear** equation looks like $y' = a\,y$, and a **second-order
linear** equation (the kind that governs springs, waves, quantum particles, and
much of physics) looks like
$$
y'' = a\,y,
$$
where $a$ is some coefficient that may itself depend on $x$. The question of the
hour: when does such an equation have an EML solution, and when is its solution
forever beyond the reach of formulas?

To attack this cleanly, mathematicians do something audacious. They forget that
$x$ is a number and remember only one thing about differentiation: it obeys the
**product rule** (Leibniz's law),
$$
(fg)' = f'g + fg'.
$$
A set of "functions" together with an operation $'$ obeying this rule — and the
usual rules of arithmetic — is called a **differential field**. Inside such a
field, the symbol $'$ is just an algebraic gadget. Astonishingly, almost
everything we need about closed-form solutions can be proved at this purely
algebraic level, with no limits, no continuity, no analysis at all. That is the
viewpoint that makes the results below airtight.

## The Riccati transform: trading linear for quadratic

The first big idea is a change of variables so clever it feels like cheating.
Given a solution $y$ of $y'' = a\,y$, look not at $y$ but at its **logarithmic
derivative**,
$$
v = \frac{y'}{y}.
$$
This is the instantaneous growth *rate* of $y$ — the same quantity that turns
compound interest into a percentage. A short computation using only the product
rule and the quotient rule shows that whenever $y \neq 0$,
$$
v' + v^2 = \frac{y''}{y}.
$$
And if $y$ solves $y'' = a\,y$, the right-hand side is simply $a$. So $v$
satisfies
$$
v' + v^2 = a.
$$

This is the **Riccati equation**, and the move from $y'' = a y$ to $v' + v^2 = a$
is the **Riccati transform**. We have traded a *second-order linear* equation for
a *first-order* one — at the price of making it *nonlinear* (that squared term
$v^2$). It is exactly the right trade. The original equation hides its solutions
two derivatives deep; the Riccati version exposes the essential difficulty in a
single, low-order package. In our formalization this is the theorem
`riccati_of_second_order`: *for any nonzero $y$ with $y'' = a y$, the logarithmic
derivative $v = y'/y$ satisfies $v' + v^2 = a$.* It holds in any differential
field whatsoever — no assumptions, no fine print.

Why does this matter for closed forms? Because of a domino effect. If the linear
equation had an EML solution $y$, then $v = y'/y$ would be EML too (derivatives
and quotients of EML functions are EML), and crucially, the structure of EML
functions forces $v$ to be not just EML but **rational** — a ratio of
polynomials — in the most important cases. So the existence of a fancy
closed-form solution collapses to a brutally concrete question: *does the Riccati
equation have a solution that is a ratio of two polynomials?* That question we
can settle by counting.

## The constants, and the geometry of "how many solutions"

Before counting, we need to know how many solutions to expect, and what
"different solutions" even means. Here a second elegant structure appears: the
**field of constants**. In any differential field, the elements with zero
derivative — the things that "don't change" — form a self-contained number
system: you can add, subtract, multiply, and divide them and never leave. This is
`constantsSubfield`, and membership in it is exactly the condition $x' = 0$. The
constants are the bedrock; everything else is measured relative to them.

Two facts give the second-order equation $y'' = a y$ its shape:

- **Scaling and adding solutions gives solutions.** If $y_1$ and $y_2$ solve the
  equation, so does $y_1 + y_2$; and if $c$ is a constant, so does $c\,y_1$.
  (These are `add_solution` and `scale_solution`.) In plain terms, solutions form
  a *vector space* over the constants — they superpose, exactly as waves do.

- **The solution space is at most two-dimensional.** A second-order equation
  pins down a function once you know its value and its slope at a point — two
  numbers, two degrees of freedom. So there is room for at most two genuinely
  independent solutions.

How do we *detect* whether two solutions are genuinely independent, rather than
one being a constant multiple of the other? With the **Wronskian**:
$$
W = y_1\,y_2' - y_2\,y_1'.
$$
This combination is the algebraic fingerprint of independence. And it has a
magical property, **Abel's identity**: when $y_1$ and $y_2$ both solve
$y'' = a y$, the Wronskian's derivative is *zero*,
$$
W' = 0,
$$
so $W$ is a constant (theorem `wronskian_deriv_eq_zero`, repackaged as
`wronskian_isConstant`). The proof is one line of the product rule: differentiate
$W$, the cross terms cancel, and what's left is $y_1(y_2'') - y_2(y_1'') = y_1(a
y_2) - y_2(a y_1) = 0$.

The payoff is a perfect dichotomy. If two solutions are *dependent* — tied
together by constants — their Wronskian is zero (`wronskian_eq_zero_of_linDep`).
Contrapositively, a *nonzero* Wronskian certifies that the two solutions are
truly independent (`linIndep_of_wronskian_ne_zero`). Put together: a pair of
solutions forms a **fundamental system** — a complete basis spanning all
solutions — exactly when their Wronskian is a **nonzero constant**
(`wronskian_isConstant_ne_zero_of_linIndep`). One number, the Wronskian, tells
you whether you have found the whole solution space or are going in circles.

This is the **algebraic skeleton** of differential Galois theory: a field of
constants, a solution space of dimension at most two over it, and a symmetry
group (the differential Galois group) acting on that space. For first-order
equations the picture is even simpler — any two nonzero solutions of $y' = a y$
have a *constant* ratio (`firstOrder_ratio_isConstant`), so the solution space is
a single line and the symmetry group is just rescaling by constants. The algebra
is always there, always well-behaved.

## The gap: when the algebra exists but the formula doesn't

Now the twist. The algebraic skeleton above always exists. The constants are
there; the two-dimensional solution space is there; the Galois group is there.
But none of that guarantees the solutions can be *written down* as EML formulas.
The skeleton is real; the flesh of closed form may be missing. This gap —
**algebra present, geometry (explicit formula) absent** — is the heart of the
matter, and it has a single, unforgettable witness.

### Airy's equation

The Airy equation is
$$
y'' = x\,y.
$$
It could hardly look simpler: the coefficient is just $x$ itself. It is also one
of the most important equations in physics — it governs the bending of light
near a caustic (the bright cusp at the bottom of a coffee cup), the transition
region in quantum mechanics where a particle passes from "allowed" to
"forbidden," and the tail of the rainbow. Its solutions, the Airy functions,
are perfectly real, smooth, and well-understood numerically.

And yet **they cannot be written in closed form.** No combination of
exponentials, logarithms, roots, and arithmetic will ever produce them. Here is
how the proof goes, in two clean strokes.

**Stroke one: no polynomial solution.** Suppose a nonzero polynomial $p$
satisfied $p'' = x\,p$. Compare degrees. Differentiating *lowers* a polynomial's
degree, so $p''$ has degree at least two below $p$. Multiplying by $x$ *raises*
degree by one. So the left side has degree $\le \deg p - 2$ while the right side
has degree $\deg p + 1$. These can never match. Contradiction. (This is
`no_poly_solves_airy`, resting on the degree-mismatch lemma
`degree_second_deriv_lt_degree_X_mul`. The same argument kills $y'' = q\,y$ for
*any* coefficient $q$ of positive degree — theorem
`no_poly_solves_second_order_pos_deg`.)

**Stroke two: no rational Riccati solution.** By the Riccati transform, a
closed-form solution of Airy would hand us a *rational* solution $v = p/q$ of
$$
v' + v^2 = x.
$$
Clear denominators (writing $v = p/q$ and multiplying through by $q^2$) and this
becomes the polynomial identity
$$
p'\,q - p\,q' + p^2 = x\,q^2.
$$
Now count degrees one more time. The term $p^2$ has degree $2\deg p$ — always
**even**. The "Wronskian-like" piece $p'q - p q'$ has degree at most
$\deg p + \deg q - 1$ (theorem `natDegree_wronskianLike_le`). On the right,
$x\,q^2$ has degree $1 + 2\deg q$ — always **odd**. The leading behavior of the
left side is governed by an even degree, the right by an odd one, and they cannot
reconcile. There is no rational $v$. (This is the parity obstruction
`no_rational_solves_riccati_odd_deg`, specialized to Airy in
`no_rational_solves_riccati_airy`.)

Together these two strokes — bundled as `airy_no_poly_and_no_rational_riccati` —
slam every door. Airy's equation has a pristine algebraic theory and no closed
form at all. The growth rate $v$ of any solution is a transcendental object that
no finite formula can capture.

## Sharpness: parity is the whole story

It would be a thin result if the obstruction were a fluke. It is not — it is a
*decision procedure*, and it is **sharp**. This is the entry point of the
**Kovacic algorithm**, the celebrated method that, given a second-order linear
equation, decides in finitely many steps whether a closed-form solution exists.
Its very first step is precisely the rational-Riccati test above.

Consider the family of "generalized Airy" equations $y'' = x^{2k+1}\,y$, whose
coefficients have odd degree $1, 3, 5, \dots$. The parity argument obstructs
*every one of them*: none has a rational Riccati solution
(`no_rational_riccati_genAiry`). But the moment the degree turns *even*, the door
can open. Take $y'' = (x^2 + 1)\,y$. Its Riccati equation $v' + v^2 = x^2 + 1$
has the explicit polynomial solution $v = x$ — check: $v' + v^2 = 1 + x^2$, done.
This corresponds to the honest closed-form solution $y = e^{x^2/2}$ (whose
logarithmic derivative is indeed $x$). The theorem `riccati_evenDeg_solvable`
records this witness, and `natDegree_evenWitness` confirms the coefficient really
does have even degree two.

Putting the two halves together gives the punchline,
`kovacic_parity_decision_sharp`: on the monomial-coefficient family, **odd degree
means no closed form, even degree can mean closed form.** The parity test is not
a one-sided trick that happens to fail for Airy; it is a tight, two-sided
criterion. The odd-degree hypothesis cannot be dropped, because the even-degree
side genuinely contains solvable equations.

## Why this is more than a curiosity

The story we have told is, in miniature, the story of one of mathematics' great
unifications. In the seventeenth and eighteenth centuries, "solving" a
differential equation meant finding a formula. The Airy functions, the Bessel
functions, the elliptic integrals — these resisted, and for a long time it was
unclear whether the resistance was a failure of cleverness or a law of nature.

The differential Galois theory built by Picard, Vessiot, Kolchin, and Kovacic
settled it: it is a law of nature. Just as Galois showed that the quintic
equation $x^5 + \cdots = 0$ has no solution in radicals because its symmetry
group is too complicated, differential Galois theory shows that Airy's equation
has no solution in closed form because *its* symmetry group is too complicated.
The Riccati transform, the Wronskian, the field of constants — these are the
instruments that make the symmetry group visible and the obstruction concrete
enough to *compute*.

What we have laid out here is that entire chain, made rigorous at the level of
pure algebra: the Riccati transform holds in any differential field; the
Wronskian is always a constant; independence is exactly nonvanishing of that
constant; and the gap between the ever-present algebra and the sometimes-absent
formula is witnessed, decidably and sharply, by a parity count that says Airy's
equation will never be tamed by a formula.

The next time you see the bright cusp of light at the bottom of a coffee cup —
that caustic is an Airy function — you can know something its discoverers did
not: not only is there no formula for it, but we can *prove* there is no formula,
and we can tell, just by reading off the parity of a degree, exactly which of its
cousins share its fate and which do not. The equation knows its own answer. It
simply, provably, refuses to write it down.
