# MASTER FUTURE DIRECTIONS — Accumulated Research Wisdom

*Last updated: 2026-05-05 05:14*

## Next Steps

### 1. Tropical Nullstellensatz for Proof Semirings

**Goal**: Establish a Nullstellensatz-type theorem for idempotent semirings (dioids) where the addition is join and multiplication is composition.

In classical algebraic geometry, the Nullstellensatz says that maximal ideals correspond to points of the variety. For proof semirings, the analogous statement would be: **the maximal theories of a finitely generated proof semiring correspond to the "points" of the proof space** — i.e., to complete consistent extensions.

**Key question**: When does every maximal theory arise as the kernel of an evaluation map to a simple proof semiring?

**Lean target**: Formalize the idempotent semiring order (`a ≤ b ↔ a + b = b`) and prove that in this setting, prime theories correspond to prime filters in the lattice, connecting to the Stone duality for distributive lattices.

### 2. Constructive Prime Witness Extraction for Non-Derivability

**Goal**: Replace the Zorn's lemma argument with a constructive procedure for finding prime separating witnesses.

The current proof uses classical logic (Zorn's lemma). For computational applications — particularly automated theorem proving and proof search — a constructive version is needed. This would give an **algorithm** that, given a semiprime kernel K and a ∉ K, produces a prime theory P with K ⊆ P and a ∉ P.

**Approach**: For finitely generated theories, the prime avoidance argument can be made constructive by exhaustive search over a finite lattice of theories. For countably generated theories, a priority argument (analogous to Lindenbaum's lemma) may suffice.

**Lean target**: Prove a `Decidable` version of `exists_prime_theory_avoiding` for `Fintype α`.

### 3. Spectral Completeness for Closure Operators

**Goal**: Connect the prime theory intersection theorem to closure operators and Galois connections in the style of abstract interpretation.

Given a closure operator `C : Set α → Set α` (monotone, extensive, idempotent), the closed sets form a complete lattice. The prime theories in this lattice are the "semantic points" of the closure system. The reconstruction theorem says that semiprime closed sets are determined by their prime spectrum.

**Key application**: In abstract interpretation, the closed sets are the abstract domains. The prime spectrum gives a canonical decomposition of abstract domains into "prime components," each corresponding to a single semantic distinction.

**Lean target**: Formalize `ClosureOperator`-based proof semirings and prove the spectrum theorem in this generality. Bridge to Mathlib's `ClosureOperator` API.

### 4. Comparison with Kripke/Joyal Semantics via Prime Filters

**Goal**: Establish a formal comparison between:
- Prime theories in proof semirings (our framework)
- Kripke frames / prime filters in Heyting algebras
- Points of the Zariski spectrum

In intuitionistic logic, Kripke semantics uses prime filters of a Heyting algebra as "possible worlds." Our prime theories play an analogous role for proof semirings. The comparison would formalize:

- **Distributive lattice case**: Prime theories = prime filters = spectrum points (Stone duality)
- **General semiring case**: Prime theories generalize prime filters to non-lattice settings
- **Ring case**: Prime theories = prime ideals = Zariski spectrum points

**Lean target**: For a `BooleanAlgebra α`, prove that `IsPrimeTheory T ↔ IsUltrafilter Tᶜ`, connecting to Mathlib's filter/ultrafilter API.

### 5. Finite-Generation and Elimination Algorithms for Proof Congruences

**Goal**: Develop computational tools for working with proof congruences in finitely presented semirings.

For finitely presented commutative semirings `α = ℕ[x₁,...,xₙ] / (relations)`, the prime spectrum is a finite object (or at least computably enumerable). This opens the door to:

- **Proof search by prime elimination**: To show a ∉ K, find a prime congruence separating them.
- **Decision procedures for derivability**: If the prime spectrum is finite, derivability reduces to checking membership in finitely many prime theories.
- **Gröbner-basis analogues**: Develop a "standard basis" algorithm for theories in proof semirings, analogous to Gröbner bases for polynomial ideals.

**Lean target**: Implement `DecidableEq` and `Fintype` instances for proof congruences over finite semirings, and prove that the reconstruction theorem gives a decision procedure.