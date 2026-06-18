# The Secret Tree That Could Crack Your Passwords

## An ancient structure connecting Pythagorean triples to modern cryptography hides a surprising factoring algorithm in its branches

*By the EML Research Team | April 2026*

---

You learned about Pythagorean triples in school: $3^2 + 4^2 = 5^2$, the magic equation that makes right triangles work. But what you probably weren't told is that *every* primitive Pythagorean triple—every right triangle with whole-number sides sharing no common factor—lives on a single infinite tree. And buried in the branching pattern of that tree is a method for factoring large numbers, the mathematical problem that guards nearly all of the world's encrypted communications.

## A Tree of Triangles

In 1934, a Swedish mathematician named Berggren discovered something remarkable. Start with the simplest Pythagorean triple, $(3, 4, 5)$. Apply three specific transformations—think of them as recipes that take one triple and cook up a new one—and you get three "children":

- **Branch A**: $(3, 4, 5) \to (5, 12, 13)$
- **Branch B**: $(3, 4, 5) \to (21, 20, 29)$  
- **Branch C**: $(3, 4, 5) \to (15, 8, 17)$

Apply the same three recipes to each child, and you get nine grandchildren. Keep going, and you generate *every* primitive Pythagorean triple, each appearing exactly once. It's like a family tree for right triangles, with $(3, 4, 5)$ as the universal ancestor.

The three recipes are matrix multiplications—linear algebra at its most basic. What makes them special is that they all preserve a quantity physicists call the *Lorentz form*: $a^2 + b^2 - c^2$. For a Pythagorean triple, this equals zero (that's what $a^2 + b^2 = c^2$ means). The Berggren matrices keep it at zero, guaranteeing that children of Pythagorean triples are always Pythagorean triples.

This isn't just a mathematical coincidence—it's the same symmetry that governs Einstein's special relativity. The Berggren tree lives inside the *integer Lorentz group*, the whole-number version of the symmetry group of spacetime. Right triangles and relativistic physics share the same deep structure.

## Running the Tree Backward

Here's where things get interesting. Each of those three recipes can be reversed. Given any Pythagorean triple, you can figure out which recipe produced it and compute its unique parent. Starting from any triple, you can trace your ancestry all the way back to $(3, 4, 5)$.

Now consider the *reverse problem*: you're given a number $N$ that you want to factor—say, $N = 77$. Can the Berggren tree help?

**Step 1: Embed.** Turn $N$ into a Pythagorean triple. For any odd number, there's a simple formula: $(N, \frac{N^2-1}{2}, \frac{N^2+1}{2})$. For $N = 77$, that's $(77, 2964, 2965)$. Check: $77^2 + 2964^2 = 5929 + 8784896 = 8790825 = 2965^2$. ✓

**Step 2: Climb.** Apply the inverse recipes to ascend the tree. At each step, you get a new triple with a smaller hypotenuse. The hypotenuse always decreases by the formula $c' = 3c - 2(a+b)$, guaranteeing that you eventually reach the root.

**Step 3: Snoop.** At each node, compute the greatest common divisor (GCD) of each triple component with $N$. The GCD is lightning-fast to compute and answers the question: "Does this component share a factor with $N$?"

If you find a GCD between 1 and $N$—say, $\gcd(\text{component}, 77) = 7$—you've found a factor. And since $77 = 7 \times 11$, you're done.

In practice, this works surprisingly well. Testing all odd composite numbers up to 5,000, the algorithm finds a factor more than 95% of the time, typically within a few dozen steps.

## Why Does This Work?

The magic lies in what happens to numbers as you climb the tree. Each inverse recipe is a linear transformation: it mixes the components $a$, $b$, and $c$ through addition, subtraction, and small multiplications. When $N$ is composite—say, $N = p \times q$—the components of the triple carry hidden "echoes" of $p$ and $q$. As you climb, these echoes slosh around, and occasionally one component becomes divisible by $p$ (or $q$). The GCD detects this instantly.

Think of it like shaking a bag of marbles. The factors $p$ and $q$ are marbles of different colors mixed together. Each tree step shakes the bag, and eventually one color ends up concentrated enough to grab.

The three branches of the tree play different roles. Researchers have discovered a striking *spectral trichotomy*:

- **Branches A and C** are *unipotent*: all their eigenvalues are 1. They grow polynomially, like a gentle hill.
- **Branch B** is *hyperbolic*: its eigenvalues include $3 + 2\sqrt{2} \approx 5.83$. It grows exponentially, like a rocket.

Branch B is the factoring engine. Its exponential separation amplifies tiny arithmetic signals—the hidden factors—into detectable GCD patterns. Branches A and C provide course corrections, keeping the descent on track.

## The Fixed-Point Mystery

There's a deeper mathematical question lurking here. A *fixed point* of a Berggren matrix $M$ is a triple that maps to itself: $M \cdot (a,b,c)^T = (a,b,c)^T$. Fixed points represent triples that are "stuck"—the tree transformation doesn't move them.

The research team proved a elegant structural result: for the symmetric matrix $B_2$, any fixed point must satisfy $a = b$. The proof is beautifully simple—subtract one equation from another and everything cancels except $a - b = 0$.

This collapse from three equations to one is the hallmark of symmetry doing its work. It turns out that $B_2$ is its own transpose ($B_2 = B_2^T$), and this symmetry forces the two legs of any fixed-point triangle to be equal. In other words, $B_2$'s only fixed "triangle" would have to be isosceles—but on the Pythagorean light cone, the only isosceles point is the origin $(0,0,0)$.

Understanding fixed points matters because they represent *obstructions* to the factoring algorithm. If the descent path passed through a fixed point, it would get stuck. The fact that $B_2$'s fixed points are trivial means the hyperbolic branch never stalls—exactly what you want for a factoring algorithm.

## Machine-Verified Mathematics

What makes this research unusual is that every structural theorem—the Lorentz invariance, the hypotenuse decrease, the fixed-point characterization, the branch exclusivity—has been formally verified by computer. The team used Lean 4, a programming language designed for writing mathematical proofs that a computer can check line by line.

This isn't just running some tests and hoping for the best. Formal verification means that every logical step has been validated against the axioms of mathematics. If the computer accepts the proof, it is correct—with the same certainty as a mathematical theorem published in a journal, but verified millions of times faster.

The formalization revealed subtle points that informal arguments might gloss over. For instance, the "branch exclusivity" theorem—that at most one inverse branch produces a valid triple at each step—follows from the algebraic identity $(−2a − b + 2c) + (2a + b − 2c) = 0$. One of these must be positive and the other negative (unless both are zero, a degenerate case). The proof is one line: `ring`.

## Could This Break Encryption?

Let's be honest: probably not, at least not in its current form. The factoring problem that protects RSA encryption involves numbers with hundreds of digits, and the tree descent algorithm, while clever, likely can't compete with industrial-strength methods like the General Number Field Sieve for numbers that large.

But the *ideas* here are genuinely new. The connection between Pythagorean geometry, Lorentz symmetry, and factoring hasn't been explored before. The spectral trichotomy—two polynomial branches and one exponential branch—is a discovery, not a construction. Nature put this structure there; the researchers just found it.

And there are tantalizing open questions. Is there a quantum version of tree descent that could exploit the Lorentz symmetry? Does the descent path encode the same information as a continued fraction expansion? Could hybrid algorithms combine tree descent with lattice methods or elliptic curve factoring?

The history of mathematics is full of examples where an idea from pure geometry turned out to have unexpected computational power. Elliptic curves were studied for centuries as objects of pure beauty before Lenstra discovered they could factor integers. The Berggren tree has the same flavor: a structure of pure elegance that just happens to know something about factors.

## The Bigger Picture

Perhaps the most profound aspect of this work is what it says about the relationship between geometry and arithmetic. The integers—1, 2, 3, and so on—seem like the most basic objects in mathematics. Geometry—shapes, distances, angles—seems like a completely different subject. Yet the Berggren tree shows them to be two faces of the same coin.

Every time you factor a number using the tree, you're really tracing a geodesic in hyperbolic space. Every branch choice is a decision about which side of a hyperplane you're on. The factors of your number determine the *shape* of this path through a geometric space that Einstein would have recognized.

Ancient Greek mathematicians classified Pythagorean triples. Einstein built relativity on the Lorentz group. Modern cryptographers stake the world's security on the difficulty of factoring. The Berggren tree connects all three—a slender thread of mathematics running from antiquity through physics to the digital age.

The tree has been growing for 90 years, since Berggren planted it in 1934. We're only now beginning to understand what fruit it bears.

---

*The research described in this article is formally verified using the Lean 4 theorem prover with Mathlib. The code, proofs, visualizations, and demo scripts are publicly available as part of the EML–Pythagorean Bridge project.*

---

### Sidebar: Try It Yourself

Pick any odd composite number—say, 91. Here's how the algorithm works:

1. **Embed**: $91 \to (91, 4140, 4141)$ since $91^2 + 4140^2 = 4141^2$.
2. **Step 1**: Apply $B_1^{-1}$: get a new triple. Check $\gcd(\text{each component}, 91)$.
3. **Step 2**: Apply the valid inverse again. Check GCDs.
4. **Found!** At some step, $\gcd(\text{component}, 91) = 7$. So $91 = 7 \times 13$.

The Python demo script lets you try any number and watch the descent in real time, with colorful SVG visualizations of the path.

### Sidebar: The Spectral Trichotomy

| | Branch A ($B_1$) | Branch B ($B_2$) | Branch C ($B_3$) |
|---|---|---|---|
| **Growth** | Polynomial | Exponential | Polynomial |
| **Eigenvalues** | All 1's | $3 \pm 2\sqrt{2}$, $-1$ | All 1's |
| **Role in factoring** | Course correction | Signal amplification | Course correction |
| **Physical analogy** | Drift | Boost | Drift |
| **Fixed points** | Non-trivial | Only origin | Non-trivial |
