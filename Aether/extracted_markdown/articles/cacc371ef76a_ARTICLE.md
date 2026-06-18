# When Cellular Automata Become Geometry

## The Hidden Polynomial World Inside the Simplest Computers

Imagine a row of light bulbs, each one either on or off. Every second, each bulb looks at itself and its two neighbors and decides whether to switch. The rule is simple: a fixed table that says, for every possible configuration of three bulbs, what the center one should become. There are exactly 256 such rules — the elementary cellular automata, catalogued and studied by Stephen Wolfram in the 1980s.

Some rules are boring. Rule 0 turns everything off. Rule 204 does nothing at all. But Rule 110 is anything but boring: it can simulate a universal Turing machine. From 256 tiny lookup tables emerges the full spectrum of computational complexity, from trivial to universal.

For forty years, this has been the story: cellular automata as computation. But a new mathematical investigation reveals that these 256 rules have a secret double life — as algebraic geometry, the branch of mathematics that studies shapes defined by polynomial equations.

## Every Rule Is a Polynomial

The key insight is deceptively simple. Each bulb is either on (1) or off (0), and we can do arithmetic with these values using the rules of modular arithmetic: 1 + 1 = 0, as in a light switch. Mathematicians call this GF(2), the field with two elements.

In this arithmetic, every possible rule — every lookup table mapping three inputs to one output — can be written as a polynomial. Not just any polynomial, but a *multilinear* polynomial of degree at most 3:

g(a, b, c) = c₀ + c₁a + c₂b + c₃c + c₄ab + c₅ac + c₆bc + c₇abc

where each coefficient cᵢ is 0 or 1. This is called the **Algebraic Normal Form** (ANF), and it is unique: every rule corresponds to exactly one polynomial, and every such polynomial corresponds to exactly one rule.

Rule 90, which generates beautiful Sierpiński triangles, has the polynomial g(a, b, c) = a + c — it simply XORs the two neighbors. Rule 110, the universal computer, is g(a, b, c) = b + c + bc + abc — a genuinely cubic polynomial. Rule 204, the identity, is just g(a, b, c) = b.

This isn't just notation. It's a bridge to an entirely different mathematical universe.

## Fixed Points as Geometric Objects

When a cellular automaton runs, some configurations are unchanged — the **fixed points**. A pattern that maps to itself under the rule. These are the stable structures, the equilibria, the "crystals" of the automaton's dynamics.

In algebraic geometry, a **variety** is the set of solutions to a system of polynomial equations. And here's the connection: the fixed points of a cellular automaton on n cells are precisely the solutions to n polynomial equations over GF(2):

g(sₙ₋₁, s₀, s₁) = s₀  
g(s₀, s₁, s₂) = s₁  
...  
g(sₙ₋₂, sₙ₋₁, s₀) = sₙ₋₁

Each equation has degree at most 3. The fixed-point set is literally an algebraic variety — a geometric object defined by polynomial equations.

## The Complement Conjugation Theorem

One of the most elegant results to emerge from this geometric perspective is a hidden symmetry. For any rule g, there is a "complement-conjugate" rule g̃, defined by flipping every input and output:

g̃(a, b, c) = 1 + g(1+a, 1+b, 1+c)

The theorem says: the operation of complementing every cell — turning every 0 to 1 and every 1 to 0 — transforms fixed points of g into fixed points of g̃, perfectly and bijectively. This means the fixed-point varieties of g and g̃ always have exactly the same size.

Moreover, this complement-conjugate operation is an **involution**: applying it twice returns to the original rule. It partitions the 256 rules into 120 conjugate pairs and 16 self-conjugate rules (like Rule 150, whose polynomial a + b + c is its own complement-conjugate). These 16 self-conjugate rules are the "fixed points" of a symmetry acting on the space of all rules — a meta-mathematical echo of the fixed-point varieties we're studying.

## The Linear Rules and Their Perfect Geometry

Among the 256 rules, exactly 8 are **additive** — their polynomial has no constant term and no products of variables:

g(a, b, c) = αa + βb + γc

for some coefficients α, β, γ ∈ {0, 1}. These include Rule 0 (α=β=γ=0), Rule 204 (β=1, rest 0), Rule 90 (α=γ=1, β=0), and Rule 150 (α=β=γ=1).

For these rules, something remarkable happens: the fixed-point set isn't just a variety — it's a **linear** variety. A subspace. The fixed-point set is closed under addition and scalar multiplication of states. This means its size is always an exact power of 2: if the dimension of the fixed-point subspace is d, then there are exactly 2^d fixed points.

Rule 204 (identity) has d = n: every state is a fixed point, giving 2ⁿ fixed points. Rule 0 has d = 0: only the all-zeros state survives. Rule 90 on 8 cells has d = 2: exactly 4 fixed points. The "dimension" d is a single number that captures the entire complexity of the stable structure.

For nonlinear rules, the fixed-point set is still an algebraic variety, but it's no longer a subspace. It can have any size — not necessarily a power of 2. The transition from linear to nonlinear mirrors the transition from solvable geometry (lines, planes) to the wild world of curves and surfaces.

## What the Degree Tells Us

The ANF degree of a rule — 0, 1, 2, or 3 — is a rough measure of its algebraic complexity. Among all 256 rules:

- 1 rule has the zero polynomial (Rule 0)
- 1 rule has degree 0 (Rule 255, the constant-1 rule)
- 14 rules have degree 1 (the linear and affine rules)
- 112 rules have degree 2
- 128 rules have degree 3

The degree-3 rules include all the most "interesting" automata: Rule 110 (universal computation), Rule 30 (pseudorandom number generation), Rule 54 (complex emergent behavior). The algebraic geometry becomes richer — and harder to analyze — as the degree increases.

## The Bigger Picture

This work sits at the intersection of three great mathematical traditions. Cellular automata theory, born from von Neumann's work on self-replicating machines and Wolfram's computational classification. Algebraic geometry, whose roots go back to Descartes and whose modern form was shaped by Grothendieck's revolutionary ideas about schemes and sheaves. And finite field theory, the algebra of codes and cryptography.

The bridge between them is surprisingly concrete. Every cellular automaton rule *is* a polynomial map. Every fixed-point set *is* an algebraic variety. The complement-conjugate pairing *is* a group action on the space of varieties. And the dimension of the fixed-point variety *is* a measure of the rule's structural complexity.

What makes this connection powerful is that it translates questions about dynamics into questions about geometry. Instead of running a cellular automaton for millions of steps, we can study the polynomial equations that define its equilibria. Instead of classifying rules by their computational behavior — which requires Church-Turing-level analysis — we can classify them by the degree and structure of their defining polynomials, a computation that takes microseconds.

The frontier question remains open: does the dimension of the fixed-point variety correlate with Wolfram's empirical complexity classes? The data suggests intriguing patterns. Class 1 rules (convergent to a single state) tend to have low-dimensional varieties. Class 4 rules (complex, edge-of-chaos) often have higher-dimensional varieties. But the correlation is imperfect, and understanding why is the next great challenge — one that may require new tools from both algebraic geometry and complexity theory.

At the deepest level, this work suggests that cellular automata are not just models of computation. They are geometric objects, living in polynomial spaces over finite fields, carrying algebraic structure that mirrors and illuminates their dynamical behavior. The simplest computers in mathematics turn out to be algebraic varieties in disguise.
