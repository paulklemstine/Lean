# Chapter 6 — Scientific American Article

# Inside-Out: The Mathematical Art of Breaking Numbers Apart

*What if you could factor large numbers not by dividing, but by climbing down a tree of right triangles? A radical new approach to factoring — one of the hardest problems in computer science — uses Pythagorean geometry to crack composites wide open.*

---

## The Problem That Guards Your Secrets

Every time you buy something online, you rely on one mathematical fact: multiplying two large prime numbers is easy, but *un-multiplying* (factoring) the result is extraordinarily hard.

RSA encryption, the backbone of internet security, works because nobody knows how to efficiently factor a 2,048-bit number (about 617 digits). The best classical algorithms take longer than the age of the universe.

But what if there's a completely different way to approach the problem?

## The Inside-Out Idea

Traditional factoring works "outside-in": you try to divide N by candidate factors 2, 3, 5, 7, 11, ... until one works. The **Inside-Out Factoring** (IOF) framework flips this on its head.

```
    TRADITIONAL:     Try divisors from outside
    ┌──────────────────────────────────────┐
    │  N = 143                             │
    │  Try 2? No. Try 3? No. Try 5? No.   │
    │  Try 7? No. Try 11? Yes! 143 = 11×13│
    └──────────────────────────────────────┘
    
    INSIDE-OUT:      Descend a geometric tree
    ┌──────────────────────────────────────┐
    │  N = 143                             │
    │  Build triple: (143, 10224, 10225)   │
    │  Descend Berggren tree...            │
    │  Step 5: gcd(leg, 143) = 11  ✓       │
    └──────────────────────────────────────┘
```

The key idea: embed N into a Pythagorean triple, then *descend* the Berggren tree using inverse transformations. At each step, check whether the GCD of a leg with N reveals a factor.

## Why Does the GCD Reveal Factors?

Think of it this way. If N = p × q, then as you descend the tree, the legs of each triple change according to linear transformations. These legs trace a deterministic path through the integers.

By the **pigeonhole principle**, at some point a leg must be divisible by p (or q). When that happens, gcd(leg, N) = p — and you've found a factor without ever trying to divide by p directly!

```
    Descent path (legs mod 7, for N = 77 = 7 × 11):
    
    Step 0:  leg ≡ 0 (mod 7)?  No  (leg = 77 — wait, 77 = 7×11!)
    Step 1:  leg ≡ 3 (mod 7)?  No
    Step 2:  leg ≡ 5 (mod 7)?  No  
    Step 3:  leg ≡ 0 (mod 7)?  YES!  gcd = 7  ← Factor found!
```

## The Chimera: Combining Multiple Approaches

The researchers didn't stop at one factoring method. They developed a **chimera** — a hybrid algorithm that combines:

1. **IOF Descent**: Berggren tree descent with GCD extraction
2. **Fermat's Method**: Express N = a² - b² = (a-b)(a+b)
3. **Integer Diffraction**: Analyze N through its "diffraction pattern" of residues
4. **Tropical Factoring**: Use tropical (max-plus) algebra to find factors

```
    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
    │  IOF Descent  │    │ Fermat Method │    │  Tropical    │
    │  (Berggren)   │    │  (a²-b²)     │    │  Factoring   │
    └──────┬───────┘    └──────┬───────┘    └──────┬───────┘
           │                   │                   │
           └───────────┬───────┘───────────────────┘
                       │
                       ▼
              ┌────────────────┐
              │  CHIMERA FACTOR │
              │   (consensus)   │
              └────────────────┘
```

## The ECDLP Connection

The researchers also connected their framework to the **Elliptic Curve Discrete Logarithm Problem** (ECDLP) — the hardness assumption underlying Bitcoin's security. Points on elliptic curves can be parameterized via stereographic-like maps, and the group law on the curve has deep structural similarities to the Berggren tree's branching.

## Dynamical Systems Perspective

The IOF descent can be viewed as a **dynamical system**: iterate an inverse Berggren map and observe the orbit. The researchers proved that:

- The orbit always converges to (3, 4, 5) — a global attractor
- The "speed" of convergence (how quickly factors appear) depends on the prime factorization of N
- The descent is deterministic — no randomness needed, unlike many modern factoring algorithms

## The Honest Assessment

The researchers are refreshingly honest about the limitations. The IOF algorithm, as currently understood, has complexity comparable to trial division: O(√N) steps in the worst case. It doesn't break RSA.

But the *approach* is novel. Factoring through geometric descent is a fundamentally different paradigm from algebraic methods (quadratic sieve, number field sieve). And it opens new questions:

- Are there *shortcuts* in the Berggren tree that allow jumping past many levels?
- Can the tree structure be combined with lattice reduction techniques?
- Does the quantum version (quantum walks on the Berggren tree) offer speedups?

These questions drive ongoing research, formalized in 209 machine-verified theorems across 11 files.

---

*Based on 11 Lean 4 files in Factoring/, approximately 209 machine-verified theorems.*
