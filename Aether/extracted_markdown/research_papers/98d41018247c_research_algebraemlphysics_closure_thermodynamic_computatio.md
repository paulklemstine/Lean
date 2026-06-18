# Closure–Thermodynamic Computation Duality via Idempotent Dissipation Semimodules and Certified Minimal Entropy-Scheduler Reconstruction

## Abstract

We establish a finite thermodynamic analogue of the Myhill–Nerode minimal realization theorem, where closure-compatible dissipation semantics replaces language acceptance. Given a finite thermodynamic computation object — a finite state space equipped with a closure operator, a monotone energy functional, and finitely many dissipation generators — we prove that the dissipation profile map is injective on closed sets under a natural separation axiom, that any two separated realizations of the same dissipation data are isomorphic (in the sense of a profile-preserving bijection on closed sets), and that the separated realization has the minimum number of closed sets among all realizations. We construct explicit canonical realizations for arbitrary nonempty dissipation data and prove a clean reversible/irreversible decomposition of generators. All results are machine-verified in Lean 4 with no unresolved proof obligations.

## 1. Introduction

### 1.1 Motivation

The Myhill–Nerode theorem (1958) establishes that the minimal deterministic finite automaton recognizing a regular language is unique up to isomorphism, with states corresponding to equivalence classes of the Nerode right-congruence. This foundational result has analogues in weighted automata theory, where the Hankel matrix rank determines the minimal realization size, and in systems theory, where observability and controllability yield minimal state-space realizations (Kalman 1960).

We develop a thermodynamic analogue where the "language" is replaced by a dissipation cost profile — a vector recording the energy cost of each computational generator — and the "states" are macro-configurations (closed sets under a closure operator modeling physical coarse-graining). The central insight is that closure-constrained dissipative cost is the right invariant for characterizing finite irreversible computing systems.

### 1.2 Relationship to Prior Work

**Landauer's principle** (1961) establishes that erasing one bit of information requires dissipation of at least kT ln 2 energy. Our framework generalizes this: non-trivial closure growth (information erasure at the macro-level) carries positive energy cost under a strict monotonicity axiom (Theorem 7).

**Tropical/idempotent algebra** provides the natural algebraic setting for dissipation costs: addition corresponds to choosing the minimum-cost implementation (min-plus), and the zero element represents zero dissipation. Our profile vectors live in ℕⁿ with pointwise comparison, which embeds into the tropical semiring.

**Closure systems and EML** (Extensional Machine Learning) use closure operators to model inductive inference and concept learning. Our closure operator captures physical coarse-graining: the map from microscopic to macroscopic configurations.

**Weighted automata minimization** (Berstel–Reutenauer 2011, Droste–Kuich–Vogler 2009) studies minimal realizations of formal power series. Our work can be viewed as a weighted minimization where weights are dissipation costs and the series is evaluated over closed macro-configurations rather than words.

### 1.3 Contributions

1. **Definitions**: We formalize finite thermodynamic computation objects (ThermoComp), dissipation profiles, separation, and realization.
2. **Injectivity**: We prove that the profile map is injective on closed sets for separated systems (Theorem 1).
3. **Minimality**: We prove that separated realizations have the minimum number of closed sets (Theorem 3).
4. **Uniqueness**: We prove that two separated realizations admit a profile-preserving bijection (Theorem 4).
5. **Realizability**: We construct canonical realizations for arbitrary nonempty dissipation data (Theorem 5).
6. **Factorization**: We prove the reversible/irreversible generator decomposition (Theorem 8).
7. **Landauer witness**: We prove that strict closure growth implies positive energy cost (Theorem 7).
8. **Verification**: All results are machine-verified in Lean 4.

## 2. Definitions and Notation

### 2.1 Closure Operators

**Definition 1** (Closure Operator). For a finite type S with decidable equality, a *closure operator* on Finset S is a function cl : Finset S → Finset S satisfying:
- Extensiveness: A ⊆ cl(A) for all A
- Monotonicity: A ⊆ B → cl(A) ⊆ cl(B)
- Idempotence: cl(cl(A)) = cl(A) for all A

A set A is *closed* if cl(A) = A.

### 2.2 Thermodynamic Computation Objects

**Definition 2** (ThermoComp). A *finite thermodynamic computation object* T = (S, cl, energy, dissip) consists of:
- A finite type S (internal states)
- A closure operator cl on Finset S
- An energy functional energy : Finset S → ℕ satisfying energy(A) ≤ energy(cl(A))
- n dissipation generators dissip : Fin n → Finset S → ℕ

**Definition 3** (Profile). The *dissipation profile* of a set A is:
  profile(A) := (dissip₀(cl(A)), dissip₁(cl(A)), ..., dissipₙ₋₁(cl(A)))

**Definition 4** (Separated). T is *separated* if for all closed A, B:
  profile(A) = profile(B) → A = B

### 2.3 Dissipation Data and Realization

**Definition 5** (DissipData). *Dissipation data* D = (m, prof) consists of m distinct profile vectors prof : Fin m → (Fin n → ℕ) with prof injective.

**Definition 6** (Realizes). T *realizes* D if there exists a surjective map f from T's closed sets to Fin m satisfying closedProfile(A) = D.prof(f(A)) for all closed A.

## 3. Main Results

### Theorem 1: Profile Injectivity

**Statement**: If T is separated, then the profile map restricted to closed sets is injective.

*Proof*: Immediate from the definition of separation. Given closed sets A, B with profile(A) = profile(B), separation yields A = B. □

### Theorem 2: Counting Lemma

**Statement**: If T is separated and realizes D, then |ClosedSets(T)| = D.numProfs.

*Proof*: The realization map f : ClosedSets → Fin m is surjective (by realization) and injective (by separation + profile compatibility). Hence bijective, giving |ClosedSets| = m. □

### Theorem 3: Minimal Realization (State Minimality)

**Statement**: For any separated T₁ realizing D and any T₂ realizing D:
  |ClosedSets(T₁)| ≤ |ClosedSets(T₂)|

*Proof*: By Theorem 2, |ClosedSets(T₁)| = D.numProfs. By the surjectivity in T₂'s realization, |ClosedSets(T₂)| ≥ D.numProfs. □

### Theorem 4: Uniqueness (Isomorphism Theorem)

**Statement**: For two separated T₁, T₂ both realizing D, there exists a bijection f : ClosedSets(T₁) → ClosedSets(T₂) preserving profiles.

*Proof*: Compose the bijection ClosedSets(T₁) ≃ Fin m (from T₁'s separated realization) with the inverse bijection Fin m ≃ ClosedSets(T₂). Profile preservation follows from the compatibility conditions. □

### Theorem 5: Canonical Realization (Existence)

**Statement**: For any D with D.numProfs > 0, there exists a separated ThermoComp on Fin D.numProfs realizing D.

*Proof sketch*: Construct a chain closure on Fin m: cl(A) = [0..max(A)] (the interval from 0 to the maximum element of A). The closed sets are exactly the intervals [0..k] for k ∈ Fin m, giving exactly m closed sets. Define dissip(i, A) = D.prof(max(A), i). Separation follows from the injectivity of D.prof. □

### Theorem 6: Complete Duality

**Statement**: For two separated realizations T₁, T₂ of the same D:
1. closedProfile is injective on both T₁ and T₂
2. |ClosedSets(T₁)| = |ClosedSets(T₂)|
3. |ClosedSets(T₁)| = D.numProfs

*Proof*: Combines Theorems 1, 2, and 3. □

### Theorem 7: Landauer Witness

**Statement**: If energy is strictly monotone under closure (cl(A) ≠ A → energy(A) < energy(cl(A))), then non-trivial closure growth produces a positive energy gap: 0 < energy(cl(A)) - energy(A).

*Proof*: Immediate from the strict inequality and natural number subtraction. □

### Theorem 8: Reversible/Irreversible Decomposition

**Statement**: For any ThermoComp T:
1. Every generator is either reversible (zero dissipation on all closed sets) or irreversible (positive dissipation witness exists).
2. The reversible and irreversible generators partition Fin n.
3. The partition is disjoint.

*Proof*: Classical dichotomy ∀ vs ∃. The partition and disjointness follow from filter properties. □

### Theorem 9: Energy Chain Bound

**Statement**: For energy strictly monotone on closed sets, a chain A₁ ⊂ A₂ ⊂ A₃ of closed sets satisfies energy(A₁) + 2 ≤ energy(A₃).

*Proof*: Two strict inequalities in ℕ: energy(A₁) < energy(A₂) < energy(A₃), yielding the bound by integer arithmetic. □

### Theorem 10: Zero-Loss Uniqueness

**Statement**: In a separated system, there is at most one zero-loss closed set (where all generators have zero dissipation).

*Proof*: Two zero-loss closed sets have the same (zero) profile, so separation forces equality. □

## 4. Algorithms

### Algorithm 1: Canonical Realization Construction

```
INPUT:  n generators, m profile vectors D[0..m-1] ∈ ℕⁿ (all distinct)
OUTPUT: ThermoComp T on Fin(m) realizing D

CONSTRUCT:
  States: S = {0, 1, ..., m-1}
  Closure: cl(A) = {x ∈ S | x ≤ max(A)} for A ≠ ∅; cl(∅) = {0}
  Energy: energy(A) = |A|
  Dissipation: dissip(i, A) = D[max(A)][i] for A ≠ ∅; dissip(i, ∅) = D[0][i]

VERIFY:
  Closed sets = {[0..k] | k = 0, ..., m-1}  (m closed sets)
  Profile([0..k]) = D[k] for all k
  Separation: D injective → profiles injective
```

**Time complexity**: O(m · n) for construction, O(m² · n) for verification.

### Algorithm 2: Minimal Realization Check

```
INPUT:  ThermoComp T with n generators on state space S
OUTPUT: Whether T is the minimal (separated) realization

1. Enumerate closed sets C₁, ..., Cₖ (fixpoints of cl)
2. Compute profiles P₁ = profile(C₁), ..., Pₖ = profile(Cₖ)
3. Check injectivity: are all Pᵢ distinct?
4. If yes: T is separated → minimal
5. If no: identify equivalence classes → quotient gives minimal
```

**Time complexity**: O(k² · n) where k = number of closed sets.

## 5. Concrete Example

The file includes a verified concrete example: a two-state system (`Fin 2`) with identity closure and two indicator-based generators. Generator i assigns dissipation 1 to set A if i ∈ A, else 0. This gives distinct profiles to all four finsets (∅, {0}, {1}, {0,1}), establishing separation.

The proof of separation proceeds by finite case analysis: `fin_cases A; fin_cases B; simp +decide`.

## 6. Discussion

### 6.1 Comparison with Myhill–Nerode

| Aspect | Myhill–Nerode | Thermo Duality |
|--------|--------------|----------------|
| Objects | DFA | ThermoComp |
| States | Automaton states | Closed macro-configs |
| Semantics | Language (word → Bool) | Profile (set → ℕⁿ) |
| Equivalence | Nerode relation | Profile equivalence |
| Separation | Right-invariant | Dissipation-distinguishing |
| Minimal | Min-state DFA | Min-closed-set ThermoComp |
| Uniqueness | Up to isomorphism | Up to profile-preserving bijection |

### 6.2 Limitations

1. **Finite setting only**: The theory currently handles finite state spaces. Extension to countable or continuous state spaces would require topological closure operators and measure-theoretic energy functionals.

2. **No dynamics**: The current framework captures static dissipation costs but not the dynamics of state transitions. A full "thermodynamic automaton" would need transition relations compatible with closure.

3. **Natural number costs**: Using ℕ for dissipation costs is a simplification. Physical dissipation is real-valued; extending to ℝ or ℝ≥0 introduces completeness and continuity issues.

### 6.3 Strengths

1. **Complete machine verification**: Every theorem is proved in Lean 4 with no gaps.
2. **Constructive realizations**: The canonical realization is explicitly constructed, not just shown to exist.
3. **Clean decomposition**: The reversible/irreversible split is total and disjoint.

## 7. Future Work

See FUTURE_DIRECTIONS.md for detailed proposals. Key directions include:
- Tropical spectral theory of dissipation matrices
- Categorical equivalence with weighted coalgebras
- Learning algorithms for minimal entropy schedulers
- Finite Landauer lower bounds via closure rank
- Extension to quantum channels

## References

1. R. Landauer. "Irreversibility and heat generation in the computing process." IBM J. Research and Development, 5(3):183–191, 1961.
2. A. Nerode. "Linear automaton transformations." Proc. AMS, 9(4):541–544, 1958.
3. J. Myhill. "Finite automata and the representation of events." WADD TR 57-624, 1957.
4. R.E. Kalman. "A new approach to linear filtering and prediction problems." ASME J. Basic Engineering, 82:35–45, 1960.
5. J. Berstel, C. Reutenauer. "Noncommutative Rational Series with Applications." Cambridge, 2011.
6. M. Droste, W. Kuich, H. Vogler. "Handbook of Weighted Automata." Springer, 2009.
7. C.H. Bennett. "Logical reversibility of computation." IBM J. Research and Development, 17(6):525–532, 1973.
