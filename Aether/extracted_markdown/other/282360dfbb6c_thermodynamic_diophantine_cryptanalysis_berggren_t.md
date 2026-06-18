# Thermodynamic Diophantine Cryptanalysis: Berggren Transfer Operators for Certified Security of Triple-Based One-Way Maps

## Abstract

We formalize a novel bridge between thermodynamic formalism and cryptographic security analysis, centered on the Berggren tree of primitive Pythagorean triples. The central contribution is a suite of 27 formally verified Lean 4 theorems — with zero `sorry` statements — establishing that spectral-radius control on weighted transfer operators over the Berggren tree yields certified upper bounds on collision pressure and preimage probabilities for hash functions defined on integer triples.

The main theorem shows that when collision count growth rate κ_col is strictly less than twice the partition-sum growth rate κ_part (spectral separation), there exists a computable entropy gap ε > 0 such that collision pressure decays as −ε·n + O(1) with tree depth n. This formalizes a "thermodynamic security calculus" where one-wayness is certified by pressure inequalities rather than ad hoc counting.

## 1. Mathematical Framework

### 1.1 The Berggren Tree

The Berggren tree T encodes all primitive Pythagorean triples via three integer matrix generators A, B, C applied recursively to the seed (3, 4, 5). We define `berggrenDescendants seed n` as the cumulative finite set of all triples reachable in at most n generations.

### 1.2 Cryptographic Observables

A `BerggrenCryptoObservable` F assigns a nonneg, Lipschitz-controlled weight to each triple, inducing a weighted partition sum:

    Z_n(F) = Σ_{t ∈ S_n} exp(F.weight(t))

This is the finite-depth analog of the thermodynamic partition function.

### 1.3 Hash Functions and Collision Counting

For a hash function H : ℤ³ → Fin m, we define:
- **CollisionCount**: number of off-diagonal pairs with equal hash
- **PreimageCount**: number of triples mapping to a given output
- **WeightedPreimageProbability**: F-weighted fiber mass normalized by Z_n
- **CollisionPressure**: log(CC+1) − 2·log(Z_n)

## 2. Main Results

### 2.1 Fiber Decomposition (Theorems 11–12)

The partition sum decomposes as:

    Z_n = Σ_y Σ_{H(t)=y} exp(F.weight(t))

and the weighted preimage probabilities form a genuine probability distribution:

    Σ_y WPP(y) = 1

### 2.2 Pigeonhole Bound (Theorem 15)

For any hash H : ℤ³ → Fin m with m > 0:

    ∃ y : Fin m, 1/m ≤ WPP(y)

This is proved by contradiction using the normalization identity.

### 2.3 Two-Scale Collision Pressure Bound (Theorem 19)

**Main Bridge Theorem.** If collisions grow as CC ≤ C_col · exp(κ_col · n) and the partition sum is bounded below by Z_n ≥ exp(κ_part · n)/C_part, then:

    CollisionPressure ≤ log(C_col + 1) + 2·log(C_part) + (κ_col − 2·κ_part) · n

### 2.4 Security Gap Existence (Theorem 20)

When κ_col < 2·κ_part (spectral separation):

    ∃ ε > 0, ∀ n, CollisionPressure ≤ −ε · n + O(1)

This certifies exponentially decaying collision vulnerability.

### 2.5 Preimage Decay (Theorem 21)

Under fiber growth and partition lower bounds with entropy gap ε ≥ 0:

    WPP(y) ≤ C² · exp(−ε · n)

### 2.6 Pressure Convergence (Theorem 18)

With two-sided bounds exp(P·n)/C ≤ Z_n ≤ C·exp(P·n):

    |log(Z_n)/n − P| ≤ log(C)/n

giving O(1/n) convergence of the normalized log partition sum to the thermodynamic pressure.

## 3. Proof Techniques

The development employs diverse proof tactics:

| Tactic | Usage |
|--------|-------|
| `positivity` | Exponential positivity, partition sum positivity |
| `by_contra` / `push_neg` | Pigeonhole and existence proofs |
| `linarith` | Pressure inequality chains |
| `field_simp` | Division normalization |
| `Finset.sum_fiberwise_of_maps_to` | Partition sum fiber decomposition |
| `Finset.sum_le_sum` | Monotonicity of weighted sums |
| `Real.log_le_log` | Logarithmic monotonicity |
| `div_le_one_of_le₀` | Probability upper bounds |

## 4. Connections to Existing Work

This development bridges:

- **Thermodynamic formalism** (Ruelle, Bowen): partition sums, pressure, spectral gaps
- **Diophantine dynamics** (Berggren, Barning): generation of primitive Pythagorean triples  
- **Cryptographic security** (Goldreich): collision resistance, preimage hardness
- **Quantum computing** (Grover): post-quantum security bounds via spectral analysis
- **Information theory** (Shannon): entropy gaps, Cauchy-Schwarz probability bounds

## 5. Formalization Summary

| Category | Count |
|----------|-------|
| Definitions | 17 |
| Structures | 4 |
| Instances | 3 |
| Theorems (proved) | 27 |
| sorry statements | 0 |
| Lines of Lean code | ~740 |

All proofs are verified by Lean 4 with only standard axioms (propext, Classical.choice, Quot.sound).
