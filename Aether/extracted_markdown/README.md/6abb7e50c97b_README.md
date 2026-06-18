This project was edited by [Aristotle](https://aristotle.harmonic.fun).

To cite Aristotle:
- Tag @Aristotle-Harmonic on GitHub PRs/issues
- Add as co-author to commits:
```
Co-authored-by: Aristotle (Harmonic) <aristotle-harmonic@harmonic.fun>
```

# The Integer Decoder: Four Channels of Algebraic Reality

A research project exploring the idea that integers carry structured information
decodable through exactly four algebraic channels — the four normed division algebras
guaranteed by Hurwitz's theorem (1898): ℝ, ℂ, ℍ, 𝕆.

## Project Structure

### Research Materials (`research/`)

- **[`research_notes.md`](research/research_notes.md)** — Comprehensive research notes covering
  all four channels, the unified decoder framework, quantum mathematical space, connections
  to physics, computational experiments, and open questions.

- **[`paper.md`](research/paper.md)** — Full research paper: "The Integer Decoder: Extracting
  Structured Information Through the Four Composition Algebra Channels." Covers the framework,
  channel analysis, signature space geometry, quantum integer states, and formal verification.

- **[`scientific_american_article.md`](research/scientific_american_article.md)** — Popular science
  article: "The Universe Has Only Four Ears: What Integers Are Secretly Telling Us." Accessible
  introduction to the framework for a general audience.

- **[`hypotheses_and_frontier.md`](research/hypotheses_and_frontier.md)** — Eight novel hypotheses,
  frontier science ideas (quantum mathematical space, octonionic computing, arithmetic entanglement),
  testable predictions, and open research directions.

### Lean 4 Formalizations (`RequestProject/`)

#### `Foundations/IntegerDecoder.lean` — Core Theorems (9 theorems, all proved ✓)

| Theorem | Description | Status |
|---------|-------------|--------|
| `lagrange_four_squares` | Every ℕ is a sum of 4 squares (Channel 3 always works) | ✅ Proved |
| `gaussian_norm_multiplicative` | Brahmagupta-Fibonacci 2-square identity | ✅ Proved |
| `sum_two_squares_mul` | Product of sums of 2 squares is a sum of 2 squares | ✅ Proved |
| `channel_2_implies_4` | Channel 2 embeds in Channel 3 | ✅ Proved |
| `fermat_sum_two_squares` | Primes p ≡ 1 (mod 4) are sums of 2 squares | ✅ Proved |
| `euler_four_square_identity` | Euler's 4-square identity (Channel 3 composition law) | ✅ Proved |
| `eight_square_identity_exists` | Degen's 8-square identity (Channel 4 composition law) | ✅ Proved |
| `jacobi_sum_pos` | Jacobi sum is positive for n ≥ 1 (Channel 3 always has output) | ✅ Proved |
| `d₁_multiplicative` | Channel 2 multiplicativity: divisor count formula for coprime inputs | ✅ Proved |

#### `Explorations/CayleyDickson.lean` — Cayley-Dickson & Channel Properties (7 theorems, all proved ✓)

| Theorem | Description | Status |
|---------|-------------|--------|
| `complex_norm_sq_mul` | Complex norm squared is multiplicative | ✅ Proved |
| `quaternion_not_commutative` | Quaternions are non-commutative (Channel 3 ≠ Channel 2) | ✅ Proved |
| `channel_1_to_2` | Channel 1 → Channel 2 embedding | ✅ Proved |
| `channel_2_to_3` | Channel 2 → Channel 3 embedding | ✅ Proved |
| `channel_3_to_4` | Channel 3 → Channel 4 embedding | ✅ Proved |
| `hurwitz_dimensions` | {1,2,4,8} = {2⁰, 2¹, 2², 2³} | ✅ Proved |
| `channel_1_bounded` | Channel 1 outputs at most 2 representations | ✅ Proved |

#### `Explorations/Computations.lean` — Computational Experiments (10 experiments)

Computes four-channel signatures, verifies Jacobi's formula, analyzes prime signatures,
tests Channel 3 positivity (Lagrange), and validates the r₄/r₂ ratio prediction.

## Key Ideas

### The Four Channels

Every integer n broadcasts on exactly four algebraic channels:

1. **Real (dim 1)**: Magnitude, sign, prime factorization — the integer's "DNA"
2. **Complex (dim 2)**: Gaussian integer factorization, representations as a² + b²
3. **Quaternionic (dim 4)**: Representations as a² + b² + c² + d² (always possible!)
4. **Octonionic (dim 8)**: Representations as sum of 8 squares, E₈ lattice connections

### Why Exactly Four?

Hurwitz's theorem (1898) proves composition algebras exist ONLY in dimensions 1, 2, 4, 8.
There is no 16-square identity. The decoder has exactly four channels — no more, no less.

### Novel Contributions

- **Four-channel signature** Σ(n) = (r₁, r₂, r₄, r₈) as a canonical invariant of integers
- **Signature space geometry** — mapping integers into ℝ⁴ reveals clustering structure
- **Quantum integer states** — representation spaces as Hilbert spaces
- **Arithmetic entanglement** — non-factorizable representations of composite integers
- **Channel hierarchy** — formal proof of the embedding chain: Ch1 ⊂ Ch2 ⊂ Ch3 ⊂ Ch4

## Building

```bash
lake build
```

Requires Lean 4.28.0 with Mathlib v4.28.0.
