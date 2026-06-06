# The Equations That Cannot Be Solved: Why Some Differential Equations Resist All Elementary Methods

*A deep mathematical barrier explains why certain fundamental equations of physics and engineering defy all attempts at closed-form solution.*

---

When a physicist encounters a differential equation — a mathematical statement describing how something changes — there is an almost irresistible urge to *solve* it. To find a neat formula involving familiar functions: exponentials, logarithms, trigonometric functions, perhaps their compositions. These are the "elementary" or EML (exponential-multiplicative-logarithmic) functions, the building blocks taught in every calculus course.

But some equations resist. Not because we haven't been clever enough, but because of a deep structural impossibility — as fundamental and absolute as the impossibility of trisecting an angle with straightedge and compass, or solving a general quintic polynomial with radicals.

## The Airy Equation: Simplicity That Deceives

Consider one of the simplest-looking differential equations in mathematics:

$$y'' = x \cdot y$$

This is Airy's equation, named after the 19th-century British astronomer George Biddell Airy, who encountered it while studying the intensity of light near a caustic — the bright curved line you see at the bottom of a coffee cup when sunlight hits it.

The equation is stunningly simple: the second derivative of y equals x times y. A beginning calculus student might attack it with optimism. Try y = eˣ? Then y'' = eˣ but xy = xeˣ — they don't match. Try a polynomial? If y = xⁿ, then y'' = n(n-1)x^{n-2} but xy = x^{n+1}. The exponents on the two sides always disagree. Try exponentials, logarithms, trigonometric functions in any combination. Nothing works.

And nothing *can* work. This is not a failure of ingenuity. It is a theorem.

## The Galois Group: Symmetry as Destiny

The reason lies in an extraordinary parallel between two seemingly different impossibility results in mathematics. In 1824, Niels Henrik Abel proved that the general quintic polynomial equation — degree five — cannot be solved by radicals (the familiar operations of addition, multiplication, and taking nth roots). His contemporary Évariste Galois, killed in a duel at age 20, explained *why*: the symmetry group of the equation's solutions determines everything.

If the Galois group (the group of symmetries that permute the equation's solutions while preserving all algebraic relations between them) is "solvable" — meaning it can be built up from simple, abelian layers — then the equation can be solved by radicals. If not, it cannot. The symmetric group S₅ on five elements is not solvable, and this is precisely why the quintic resists.

A century later, mathematicians discovered that the same principle governs differential equations. The role of the Galois group is played by the *differential Galois group* — a group of symmetries that acts on the solution space of the equation, preserving all differential algebraic relations. And the analog of "solvable by radicals" is "solvable by elementary (EML) functions."

For Airy's equation, the differential Galois group is SL(2,ℂ) — the special linear group of 2×2 complex matrices with determinant 1. This group has a remarkable property: it is *perfect*. In group theory, a perfect group is one that equals its own commutator subgroup — roughly speaking, every element can be expressed as a product of commutators [a,b] = aba⁻¹b⁻¹. Perfect groups are the opposite of solvable: their derived series never descends, never reaches the trivial group.

Because SL(2,ℂ) is perfect and non-trivial, it is not solvable. By the Kolchin-Singer theorem — the differential analog of Galois's fundamental theorem — this means Airy's equation has no nontrivial solutions expressible as elementary functions. The Airy function Ai(x) genuinely transcends the world of exp, log, and polynomials.

## Abel's Identity: The Wronskian Tells All

There is a beautiful intermediate result that connects the abstract group theory to concrete analysis. If you have two solutions y₁ and y₂ of any second-order linear ODE y'' + p(x)y' + q(x)y = 0, their Wronskian — the determinant

$$W(x) = y_1(x) y_2'(x) - y_1'(x) y_2(x)$$

— satisfies a remarkably simple first-order equation: W'(x) = -p(x)W(x). The solution is immediate:

$$W(x) = W(x_0) \cdot \exp\left(-\int_{x_0}^x p(t)\,dt\right)$$

This is Abel's identity, and it has a profound consequence: since the exponential is never zero, the Wronskian is either always zero or never zero. Two solutions are linearly independent if and only if their Wronskian is nonzero at any single point.

In the language of differential Galois theory, the Wronskian encodes the *determinant representation* of the Galois group. For a second-order equation, the Galois group acts as 2×2 matrices on the solution space, and the Wronskian captures the determinant. The fact that the Galois group preserves the Wronskian (up to the exponential factor) constrains it to lie within SL(2) — the matrices of determinant 1.

## The Kovacic Algorithm: Decision Made Mechanical

In 1986, Jerald Kovacic published a remarkable algorithm that decides, in finite steps, whether a second-order linear ODE y'' = r(x)y has solutions in elementary functions. The algorithm works by analyzing the rational function r(x) — specifically, its poles and their orders — and classifying the equation into one of four cases:

1. **Case 1 (Reducible):** The Galois group is triangularizable. An exponential solution exists.
2. **Case 2 (Imprimitive):** The Galois group is dihedral. Solutions involve square roots.
3. **Case 3 (Finite):** The Galois group is finite (tetrahedral, octahedral, or icosahedral symmetry). Solutions are algebraic.
4. **Case 4 (Full SL(2)):** The Galois group is the entire SL(2,ℂ). No elementary solution exists.

For Airy's equation y'' = xy, the coefficient r(x) = x is a polynomial with no finite poles. Its behavior at infinity — a pole of odd order 3 — rules out Cases 2 and 3 immediately. Case 1 analysis also fails. The equation falls squarely into Case 4: full SL(2) Galois group, no elementary solutions.

## Beyond Airy: A Universal Obstruction

Airy's equation is not an isolated curiosity. The same Galois-theoretic obstruction blocks elementary solutions for a vast class of equations that arise throughout physics and engineering:

- **Bessel's equation** (vibrations of circular membranes): for most parameter values, the Galois group is again SL(2), and Bessel functions are non-elementary.
- **The quantum harmonic oscillator**: the Hermite equation, which governs the wave functions of quantum mechanics, has solutions (Hermite functions) that are not elementary (though the Hermite *polynomials* are, of course, polynomial).
- **Painlevé equations**: these six families of second-order nonlinear ODEs define genuinely new transcendents — functions as fundamental as sin and exp, but lying beyond their reach.

## The Deeper Pattern

What makes this story so striking is not just the individual impossibility results, but the *pattern* they reveal. Whether we're asking about polynomial equations (Abel-Ruffini), geometric constructions (compass and straightedge), or differential equations (Kovacic-Kolchin-Singer), the answer always comes from the same source: **group theory**. The symmetries of the problem determine what constructions are possible.

This is not a coincidence. It reflects a deep principle in mathematics that Alexander Grothendieck would later formalize as Tannakian duality: the category of representations of a group contains all the information about the group itself. The "constructibility" of solutions — whether by radicals, by straightedge and compass, or by elementary functions — is encoded in the algebraic structure of the symmetry group.

The Airy function, invisible to the world of elementary functions, is nonetheless perfectly real. It describes the diffraction pattern of light near a fold caustic, the shape of the Schrödinger equation's solutions near a turning point, the transition between exponential decay and oscillatory behavior in wave phenomena. Its transcendence over elementary functions is not a deficiency but a signature of the richness of the physical world — a world that exceeds the vocabulary of exp and log, demanding new mathematical words to describe what it does.

---

*The results described in this article build on a long tradition from Abel (1824), Galois (1832), Liouville (1833), Kolchin (1948), and Kovacic (1986). The formal verification of these results represents a new chapter in the ongoing project of making mathematics fully rigorous.*
