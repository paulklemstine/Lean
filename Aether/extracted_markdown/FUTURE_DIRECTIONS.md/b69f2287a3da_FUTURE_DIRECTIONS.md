# Future Directions: Conserved Quantities along Reduction Paths (Cycle Closeout)

## Synthesis

This cycle took the unified picture introduced in
`Catalog/Cryptography/ConservedPathReductions.lean` — that the cryptographic
hybrid/reduction calculus and the Fibonacci gcd-conservation law are two faces
of *one* structure, a non-negative **length functional on a discrete path**
together with **morphisms that contract or conserve it** — and pushed both
strands past the point where the original file stopped.

The original file proved the one-step laws (`gameDist_path_le`,
`pathLength_concat`, `lipschitz_reduction_contracts_path`,
`reduction_end_to_end_bound`) and two number-theoretic conservation laws
(`fib_gcd_conservation`, `fib_primitivity_bridge`). It deliberately handled only
a *single* Lipschitz morphism and only the *one-directional* divisibility fact
`Nat.fib_dvd`. The new file
`Catalog/Cryptography/StrongDivisibilityConservation.lean` closes both gaps.

## Results Summary

Five new theorems, all `sorry`-free, axioms limited to
`propext`/`Classical.choice`/`Quot.sound`:

1. **`pathLength_mono`** — the accumulated path length is monotone in the number
   of hybrids. A walk can only gain advantage as it lengthens.
2. **`subpath_endpoint_bound`** — the endpoint bound is translation-invariant:
   it holds over any sub-walk `[a, b)`, not just the initial segment `[0, n)`.
3. **`reduction_composition_constants`** — the genuine *two-morphism* law:
   composing a `K`-Lipschitz reduction with an `L`-Lipschitz reduction contracts
   path length by exactly `L * K`. Nonnegativity of the *outer* constant becomes
   load-bearing here, a structural sign that two-morphism conservation is
   strictly richer than the one-morphism case.
4. **`reduction_composition_end_to_end`** — the end-to-end quantitative estimate
   for a composed reduction, `dist (ψ (φ (f 0))) (ψ (φ (f n))) ≤ (L·K)·pathLength f n`.
5. **`fib_strong_divisibility`** — the headline. For `3 ≤ m`,
   `Nat.fib m ∣ Nat.fib n ↔ m ∣ n`. This is the converse direction that Mathlib's
   `Nat.fib_dvd` lacks, proved purely from gcd conservation `Nat.fib_gcd` plus
   injectivity of `fib` on `[2, ∞)`. The bound `3 ≤ m` is sharp: since
   `fib 1 = fib 2 = 1`, the equivalence fails for `m ∈ {1, 2}`.

The deep unifying observation: "constants multiply under composition" (crypto)
and "`fib m ∣ fib n ↔ m ∣ n`" (number theory) are the same statement that the
conserved coordinate is *functorial* — composite morphisms multiply their
contraction factors, and `n ↦ fib n` is an order-embedding of the divisor
lattice on its faithful range `[2, ∞)`.

## Research Directions

### 1. Functorial conservation: a Lipschitz category of reduction paths

`reduction_composition_constants` is associativity-of-contraction for two
morphisms; the natural completion is to package `(PseudoMetricSpace, K-Lipschitz
map)` as a category whose composition law multiplies the `pathLength`-contraction
constants, with `id` contracting by `1`. The key insight is that the entire
quantitative theory of cryptographic reductions is then a single functor from
this category to `(ℝ≥0, ·)` sending each morphism to its best contraction
factor, and the hybrid argument is naturality of the endpoint-bound transform.
*Why now?* The two-morphism law is already proved and `1`-Lipschitz identities are
trivial, so the category laws are within one cycle's reach; formalizing them turns
a pile of inequalities into a reusable categorical object that later cryptographic
files can instantiate directly.

### 2. Strong divisibility sequences as an abstract conserved structure

`fib_strong_divisibility` used nothing Fibonacci-specific except `Nat.fib_gcd`
(gcd conservation) and strict monotonicity on a tail. The key insight is that
**any** sequence `a : ℕ → ℕ` satisfying `a (gcd m n) = gcd (a m) (a n)` and
strict monotonicity beyond some index `N` is automatically a strong divisibility
sequence: `a m ∣ a n ↔ m ∣ n` for `m > N`. This is a falsifiable abstraction —
it predicts the identical biconditional for Lucas sequences, `q`-integers
`[n]_q = (q^n - 1)/(q - 1)`, and elliptic divisibility sequences. *Why now?* The
Fibonacci proof is essentially this abstract argument already; extracting the
hypotheses into a structure costs little and immediately yields several new
theorems by instantiation, including reproving `a^m - 1 ∣ a^n - 1 ↔ m ∣ n`.

### 3. Sharpness atlas: where conservation degrades to inequality

We documented that `3 ≤ m` is sharp for `fib_strong_divisibility` and that
`0 ≤ L` is load-bearing for composition. The key insight is that every
conservation law in this calculus has a precise *failure boundary*, and cataloguing
them is as valuable as the laws: for `m ∈ {1,2}` the gcd morphism stops being
injective; for `L < 0` the composed bound can reverse. The falsifiable claim is
that `reduction_composition_constants` is *false* without `0 ≤ L` — exhibit
explicit metric spaces and a negative `L` where `pathLength (ψ∘φ∘f) n > (L·K)·pathLength f n`.
*Why now?* Adversarial ground-truth demands we pin the exact corner where each
theorem breaks; both boundaries are concrete finite/elementary checks that the
disproof machinery can settle quickly.

### 4. The primitive-divisor bridge, quantitatively

`fib_primitivity_bridge` (original file) is qualitative: it collapses local
non-divisibility on proper divisors to all smaller indices. Combined with the new
`fib_strong_divisibility`, the key insight is that a prime `p` first divides
`fib k` exactly at `k = rank(p)` (the entry point / Pisano-related index), and
`fib_strong_divisibility` says the set of indices with `p ∣ fib k` is precisely
the multiples of `rank(p)`. The falsifiable conjecture: `rank(p) ∣ k ↔ p ∣ fib k`
and `rank(p) ≤ p + 1`, giving a clean Carmichael primitive-divisor count. *Why now?*
The catalog already contains the entry-point characterization
(`Catalog/Pythagorean/FibonacciEntryPointCharacterization.lean`,
`Catalog/Applications/FibonacciEntryPoints.lean`); the new biconditional is the
missing algebraic glue that turns those into a divisibility-index theorem.

### 5. Pseudometric path length as a genuine norm on the free path module

`pathLength` is additive under concatenation, monotone, nonnegative, and contracts
under Lipschitz maps. The key insight is that these are exactly the axioms making
`pathLength` a **seminorm** on the free ℝ-module of finite walks modulo
reparametrization, with `gameDist_path_le` the statement that the endpoint map is
`1`-Lipschitz for this seminorm. The falsifiable direction: the seminorm is a true
norm iff the space has no "zero-length nontrivial loops," i.e. its kernel is exactly
the constant walks. *Why now?* All four required algebraic laws are now theorems
in the two files; assembling them into a seminorm instance is a packaging step that
unlocks Mathlib's normed-space API for the cryptographic advantage calculus.
