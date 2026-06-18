# Future Directions: Tropical Additive Combinatorics

## 1. Tropical Schnirelmann Density Theory

**Goal**: Define a mathematically sound tropical analogue of Schnirelmann density and prove comparison theorems with classical lower asymptotic density.

**Definition candidate**: For a cost function `f : ℕ → WithTop ℕ`, define the *tropical Schnirelmann density* as
```
σ_T(f) = inf_{n ≥ 1} |{k ≤ n : f(k) = 0}| / n
```
This is simply the classical Schnirelmann density of the zero-set of `f`.

**Theorem targets**:
- `tropSchnirelmann_eq_classical`: For indicator costs `tropInd A`, the tropical Schnirelmann density equals the classical Schnirelmann density of `A`.
- `tropSchnirelmann_conv_bound`: If `σ_T(f) > 0` and `σ_T(g) > 0`, then the zero-set of `tropConvNat f g` has Schnirelmann density at least `σ_T(f) + σ_T(g) - σ_T(f)·σ_T(g)` (Schnirelmann's theorem through tropical lens).
- `tropSchnirelmann_basis_iff`: `A` is an additive basis of order `h` iff the `h`-fold tropical self-convolution of `tropInd A` vanishes identically for large enough `n`.

**Files to create**: `Tropical/SchnirelmannDensity.lean`

**Mathlib dependencies**: `Mathlib.Combinatorics.Additive.Density`, `Mathlib.Order.Filter.AtTop`

---

## 2. Finite-Group Tropical Sumset Inequalities

**Goal**: Formalize Cauchy–Davenport and Kneser-type results as statements about zero loci of tropical convolutions over `ZMod p` and finite abelian groups.

**Definition candidate**: Define tropical convolution over a finite group `G`:
```lean
def tropConvGroup [Fintype G] [AddGroup G] (f g : G → WithTop ℕ) (x : G) : WithTop ℕ :=
  Finset.inf Finset.univ (fun a => f a + g (x - a))
```

**Theorem targets**:
- `tropConv_zeroLocus_eq_sumset_group`: Exact equivalence between zero locus and sumset for finite groups.
- `cauchy_davenport_tropical`: For `A, B ⊆ ZMod p` (p prime), the zero locus of `tropConvGroup (tropInd A) (tropInd B)` has cardinality at least `min(p, |A| + |B| - 1)`.
- `kneser_tropical`: Kneser's theorem formulated as a stabilizer-adjusted lower bound on the zero locus cardinality of tropical convolutions over finite abelian groups.

**Files to create**: `Tropical/FiniteGroupConv.lean`, `Tropical/CauchyDavenport.lean`

**Mathlib dependencies**: `Mathlib.Combinatorics.Additive.CauchyDavenport`, `Mathlib.GroupTheory.SpecificGroups.ZMod`

---

## 3. Weighted Tropical Goldbach and Graded Costs

**Goal**: Replace the binary `0/⊤` prime cost with graded cost functions and study what additive information survives.

**Definition candidates**:
```lean
-- Unit cost off primes
def primeCostUnit (n : ℕ) : WithTop ℕ := if Nat.Prime n then 0 else 1

-- Logarithmic cost (approximating von Mangoldt)
def primeCostLog (n : ℕ) : WithTop ℕ := if Nat.Prime n then 0 else ↑(Nat.log 2 n)

-- Almost-prime grading: cost = number of prime factors minus 1
def almostPrimeCost (n : ℕ) : WithTop ℕ := if n ≤ 1 then ⊤ else ↑(Nat.factors n).length - 1
```

**Theorem targets**:
- `weighted_goldbach_bound`: For `primeCostUnit`, the tropical self-convolution at even `n > 2` is at most 2 (since at most one of any pair is non-prime, contributing cost 1 each).
- `almost_prime_tropical_vanishing`: For `k`-almost primes with `k ≥ 2`, the tropical self-convolution eventually vanishes (using Chen's theorem or Brun sieve bounds).
- `graded_cost_monotonicity`: If `f ≤ g` pointwise, then `tropConvNat f h ≤ tropConvNat g h`.

**Files to create**: `Tropical/WeightedCosts.lean`

---

## 4. Verified Computational Bridge

**Goal**: Build a certified evaluator for `goldbachTrop n` on finite ranges and connect it to explicit prime-search witnesses.

**Approach**:
- Implement a decidable version of `goldbachTrop` for concrete `n` using `Decidable` instances.
- Use `native_decide` or `decide` to certify `goldbachTrop n = 0` for specific even `n`.
- Build a verified lookup table confirming Goldbach for all even `n ≤ N` for some concrete `N`.

**Theorem targets**:
```lean
-- Verified Goldbach up to a bound
theorem goldbach_verified_to_bound :
    ∀ n : ℕ, 2 < n → Even n → n ≤ 1000 → goldbachTrop n = 0

-- Certified witness extraction
theorem goldbach_witness (n : ℕ) (h : goldbachTrop n = 0) :
    ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ p + q = n
```

**Files to create**: `Tropical/Computation.lean`

**Mathlib dependencies**: `Mathlib.Tactic.NormNum`, `Mathlib.Data.Nat.Prime.Basic`

---

## 5. Analytic-to-Tropical Transfer Principles

**Goal**: Formulate how classical analytic estimates on representation functions imply tropical vanishing or bounded costs.

**Key insight**: The classical Goldbach representation function `r(n) = |{(p,q) : p+q=n, both prime}|` satisfies `r(n) > 0 ↔ goldbachTrop n = 0`. Analytic lower bounds on `r(n)` (e.g., from the circle method) transfer to tropical vanishing.

**Theorem targets**:
- `representation_positive_iff_tropical_zero`: `0 < Finset.card {(p,q) ∈ Finset.range n ×ˢ Finset.range n | Nat.Prime p ∧ Nat.Prime q ∧ p + q = n} ↔ goldbachTrop n = 0`
- `tropical_from_density`: If a set `A` has positive lower asymptotic density `δ > 0`, then for all sufficiently large `n`, `tropConvNat (tropInd A) (tropInd A) n = 0`. (This follows from additive combinatorics: sets of positive density are asymptotic bases of order 2, by Erdős–Ginzburg–Ziv type results or Schnirelmann iteration.)
- `heuristic_tropical_prime_bound`: Formalize the heuristic that `goldbachTrop n = 0` for all even `n > 2` assuming the Hardy–Littlewood circle method estimate (stated as a hypothesis, not proved).

**Files to create**: `Tropical/AnalyticTransfer.lean`

**Mathlib dependencies**: `Mathlib.Analysis.SpecificLimits.Basic`, `Mathlib.NumberTheory.ArithmeticFunction`

---

## Cross-Cutting Infrastructure

### Tropical Semiring Abstraction
After concrete theorems are established, abstract to a general idempotent semiring setting:
- Define `TropicalConv` as a typeclass for semirings where addition is idempotent (i.e., `a + a = a`).
- Show that `WithTop ℕ` with `min` and `+` forms such a semiring.
- Prove that convolution support theorems transfer across semiring homomorphisms.

### Connection to Optimization
- Interpret `tropConvNat f g n` as the minimum cost of decomposing `n` into `a + b` with costs `f(a)` and `g(b)`.
- This is a shortest-path problem in a decomposition graph.
- Formalize the connection to dynamic programming: `tropConvNat` is the Bellman equation for additive decomposition.

### Automated Verification Pipeline
- Build CI infrastructure that automatically checks new tropical theorems against Mathlib updates.
- Create a test suite with concrete computations validating all definitions.
- Integrate with `lake` build system for continuous verification.
