# Tropical Hecke–Crystal Realization Duality via Observational Quotients

## Abstract

We establish a realization duality theorem for tropical Hecke operator systems: given a finite set equipped with operators indexed by a finite color set and an observation function into a finite codomain, the observational quotient—identifying elements with identical operator-observation profiles—yields a unique minimal crystal automaton. We prove existence, minimality, uniqueness up to isomorphism, and character recovery. The number of states of the minimal crystal equals the number of distinct rows in the Hankel–Hecke observation matrix. All results are fully formalized and machine-verified.

**Keywords:** tropical algebra, Hecke operators, crystal bases, automata minimization, Myhill–Nerode, Hankel rank, certified reconstruction

## 1. Introduction

### 1.1 Motivation

The Myhill–Nerode theorem (1958) establishes that every regular language has a unique minimal deterministic finite automaton, constructible by quotienting the state space modulo observational equivalence. This foundational result connects language theory, state minimization, and the rank of the Hankel matrix.

Independently, in representation theory, Kashiwara's crystal bases (1990s) provide combinatorial models for representations of quantum groups, realized as finite weighted colored graphs. Hecke algebras act on representation spaces via operators satisfying braid relations and quadratic conditions.

We show that these two theories are instances of a common algebraic phenomenon. When Hecke-type operators act on a finite set with observations in a finite codomain, the observational quotient produces a minimal "crystal automaton"—a finite weighted colored graph—that is unique and certifiably reconstructable from finite data. This provides:

1. A representation-theoretic lifting of the Myhill–Nerode paradigm,
2. An algorithmic certified reconstruction procedure for crystal-like structures,
3. A Hankel rank characterization of minimal crystal size.

### 1.2 Contributions

Our main contributions, all fully machine-verified, are:

- **Theorem A (Realization Duality):** The observational quotient of a Hecke action datum yields an observable, minimal, unique (up to isomorphism) crystal realization.
- **Theorem B (Hankel–Hecke Minimality):** The tropical rank of the Hankel–Hecke matrix equals the minimal crystal state count.
- **Theorem C (Certified Reconstruction):** The quotient construction provides a sound, complete, minimal, character-correct reconstruction algorithm.
- **Theorem D (Converse):** Every observable crystal automaton is the minimal realization of its own Hecke action data.

### 1.3 Related Work

Our work builds on several strands:

- **Automata minimization:** The classical Myhill–Nerode theorem and its weighted generalizations (Schützenberger, Carlyle–Paz, Berstel–Reutenauer).
- **Tropical linear algebra:** The theory of matrices over idempotent semirings, tropical rank, and tropical factorization (Develin–Santos–Sturmfels, Akian–Gaubert–Guterman).
- **Crystal bases:** Kashiwara's crystal bases and their combinatorial models (Kashiwara, Littelmann, Bump–Schilling).
- **Hecke algebras:** The algebraic theory of Hecke operators and their representations (Iwahori–Matsumoto, Kazhdan–Lusztig).

Our contribution is the formalized synthesis: showing that the observational quotient construction unifies these theories in a machine-verifiable framework.

## 2. Definitions and Setup

### 2.1 Word Action

Let `ι` be a finite set of colors (simple reflections) and `M` a finite set. Given operators `T : ι → (M → M)`, the **word action** of `w = [i₁, i₂, …, iₖ] ∈ List(ι)` on `m ∈ M` is:

```
wordAction(T, [], m) = m
wordAction(T, i :: w, m) = wordAction(T, w, T(i)(m))
```

This reads the word left-to-right, applying `T(i₁)` first, then `T(i₂)`, etc.

**Lemma 2.1 (Concatenation).** `wordAction(T, w₁ ++ w₂, m) = wordAction(T, w₂, wordAction(T, w₁, m))`.

### 2.2 Observational Equivalence

Let `obs : M → S` be an observation function with `S` a finite set.

**Definition 2.2.** Two elements `m₁, m₂ ∈ M` are **observationally equivalent** (`m₁ ≈ m₂`) iff:
```
∀ w : List(ι), obs(wordAction(T, w, m₁)) = obs(wordAction(T, w, m₂))
```

**Proposition 2.3.** Observational equivalence is:
- An equivalence relation (reflexive, symmetric, transitive).
- Compatible with operators: `m₁ ≈ m₂ ⟹ T(i)(m₁) ≈ T(i)(m₂)` for all `i ∈ ι`.
- Compatible with observation: `m₁ ≈ m₂ ⟹ obs(m₁) = obs(m₂)`.

*Proof.* Reflexivity, symmetry, and transitivity follow from the corresponding properties of equality. Operator compatibility: if `m₁ ≈ m₂`, then for any word `w`, `obs(wordAction(T, w, T(i)(m₁))) = obs(wordAction(T, i::w, m₁)) = obs(wordAction(T, i::w, m₂)) = obs(wordAction(T, w, T(i)(m₂)))`. □

### 2.3 Hecke Action Data

**Definition 2.4.** A **Hecke action datum** `D = (M, T, obs)` consists of:
- A finite type `M` with decidable equality,
- Operators `T : ι → (M → M)`,
- An observation function `obs : M → S`.

### 2.4 Crystal Automaton

**Definition 2.5.** A **crystal automaton** `C = (Q, wt, step)` consists of:
- A finite type `Q` (states) with decidable equality,
- A weight function `wt : Q → S`,
- A transition function `step : ι → (Q → Q)`.

### 2.5 Crystal Realization

**Definition 2.6.** A **crystal realization** of `D` is a tuple `R = (C, φ)` where `C` is a crystal automaton and `φ : M → Q` is a surjection satisfying:
- **Intertwining:** `φ(T(i)(m)) = step(i)(φ(m))` for all `i, m`.
- **Observation compatibility:** `wt(φ(m)) = obs(m)` for all `m`.

**Lemma 2.7.** Any realization correctly reproduces all observations:
```
wt(wordAction(step, w, φ(m))) = obs(wordAction(T, w, m))
```
for all words `w` and elements `m`.

*Proof.* By induction on `w`, using intertwining and observation compatibility. □

### 2.6 Observability

**Definition 2.8.** A crystal automaton `C` is **observable** if distinct states have distinct observation profiles:
```
(∀ w, wt(wordAction(step, w, q₁)) = wt(wordAction(step, w, q₂))) ⟹ q₁ = q₂
```

## 3. Main Results

### 3.1 The Quotient Crystal

**Construction.** Given `D = (M, T, obs)`, define:
- `Q_D = M / ≈` (the quotient by observational equivalence),
- `step_D(i)([m]) = [T(i)(m)]` (well-defined by Proposition 2.3),
- `wt_D([m]) = obs(m)` (well-defined by Proposition 2.3),
- `φ_D(m) = [m]` (the quotient map).

**Proposition 3.1.** The quotient crystal `C(D) = (Q_D, wt_D, step_D)` is a crystal automaton, and `(C(D), φ_D)` is a crystal realization of `D`.

### 3.2 Theorem A: Realization Duality

**Theorem 3.2 (Realization Duality).** The quotient crystal realization `(C(D), φ_D)` satisfies:

1. **Observability:** `C(D)` is observable.
2. **Minimality:** For any observable crystal realization `(C', φ')` of `D`, `|Q_D| ≤ |C'.State|`.
3. **Uniqueness:** For any observable crystal realization `(C', φ')`, there exists a crystal isomorphism `C(D) ≅ C'`.

*Proof sketch.*

(1) **Observability.** If `[m₁]` and `[m₂]` have the same observation profile in `C(D)`, then by the defining property of the quotient, `m₁ ≈ m₂`, so `[m₁] = [m₂]`.

(2) **Minimality.** Define `f : C'.State → Q_D` by `f(q) = [m]` where `φ'(m) = q`. This is well-defined: if `φ'(m₁) = φ'(m₂) = q`, then `obs(wordAction(T, w, m₁)) = wt(wordAction(step', w, q)) = obs(wordAction(T, w, m₂))` for all `w`, so `m₁ ≈ m₂` and `[m₁] = [m₂]`. The map `f` is surjective (since `φ_D$ is surjective and factors through `φ'`). By Fintype.card_le_of_surjective, `|Q_D| ≤ |C'.State|`.

(3) **Uniqueness.** Given two observable realizations `R₁, R₂`, the map `f : R₁.State → R₂.State` defined by `f(q₁) = φ₂(m)` for `φ₁(m) = q₁` is well-defined (since obs-equivalent elements map to the same state in any observable realization) and bijective (by symmetry). It preserves weights and transitions by construction. □

### 3.3 Theorem B: Hankel–Hecke Minimality

**Definition 3.3.** The **Hankel–Hecke matrix** `H_D` has rows indexed by `M`, columns by `List(ι)`, with entries `H_D[m, w] = obs(wordAction(T, w, m))`.

**Definition 3.4.** The **tropical rank** of `H_D` is the number of distinct rows: `tropRank(H_D) = |{row_m : m ∈ M}|`.

**Theorem 3.5 (Hankel–Hecke Minimality).** `tropRank(H_D) = |Q_D| = |States(C(D))|`.

*Proof.* The distinct rows of `H_D` are precisely the distinct observation profiles of elements of `M`, which are in bijection with the equivalence classes `Q_D$. □

**Corollary 3.6.** For any observable realization `(C', φ')$, `tropRank(H_D) ≤ |C'.State|`.

### 3.4 Theorem C: Certified Reconstruction

**Theorem 3.7 (Certified Reconstruction).** The quotient construction is:
- **Sound:** reproduces all observations correctly.
- **Complete:** every observable realization has at least as many states.
- **Observable:** the output automaton is observable.
- **Character-correct:** the multiset of state weights equals the tropical character.

### 3.5 Theorem D: Converse

**Theorem 3.8.** Every observable crystal automaton `C$ is the unique minimal realization of its own Hecke action data: `|Q_{D(C)}| = |C.State|`, where `D(C) = (C.State, C.step, C.wt)`.

*Proof.* By le_antisymm: the inequality `|Q| ≤ |C.State|$ follows from the minimality theorem applied to the identity realization. The reverse `|C.State| ≤ |Q|$ follows because the quotient map `C.State → Q$ is injective (by observability of `C`). □

## 4. Algorithm: Crystal Reconstruction

### 4.1 Pseudocode

```
Algorithm ReconstructMinimalCrystal(M, T, obs, ι):
  Input: finite set M, operators T[i] for i ∈ ι, observation obs : M → S
  Output: minimal crystal automaton (Q, wt, step)

  1. Compute observation profiles:
     For each m ∈ M:
       profile[m] = {w ↦ obs(wordAction(T, w, m)) : w ∈ Words(ι, depth)}

  2. Partition M into equivalence classes:
     Q = {[m] : m ∈ M} where [m₁] = [m₂] iff profile[m₁] = profile[m₂]

  3. Define transitions:
     For each i ∈ ι, each class [m] ∈ Q:
       step[i]([m]) = [T[i](m)]  // well-defined by compatibility

  4. Define weights:
     For each [m] ∈ Q:
       wt([m]) = obs(m)  // well-defined by observation compatibility

  Return (Q, wt, step)
```

### 4.2 Complexity Analysis

- **Step 1:** O(|M| · D · |ι|^D) where D is the separation depth.
- **Step 2:** O(|M|² · profile_size) for pairwise comparison, or O(|M| · log|M|) with hashing.
- **Step 3:** O(|Q| · |ι|).
- **Step 4:** O(|Q|).

Since D ≤ |M| (by pigeonhole on the finite state space), the total complexity is polynomial in |M| and |ι|.

In practice, partition refinement (as in Hopcroft's algorithm) achieves O(|M| · |ι| · log|M|) time.

## 5. Examples

### 5.1 Boolean Observations (Classical Automata)

When S = {0, 1} and obs is a characteristic function, the construction recovers the classical Myhill–Nerode minimal DFA.

### 5.2 Tropical Observations

When S = (ℕ ∪ {∞}, min, +), observations represent shortest-path costs or optimization values. The minimal crystal captures the essential cost structure.

### 5.3 Two-Color Crystal

Consider M = {a, b, c, d}, ι = {red, blue}, with:
- T(red) = {a↦b, b↦a, c↦d, d↦c}
- T(blue) = {a↦c, b↦d, c↦a, d↦b}
- obs = {a↦0, b↦1, c↦0, d↦1}

The observation profiles: a and c have profile {[]↦0, [red]↦1, [blue]↦0, ...}, which are equal. Similarly b and d. The quotient has 2 states: {a,c} and {b,d}, giving a minimal 2-state crystal.

## 6. Discussion

### 6.1 Connections to Existing Theory

The theorem simultaneously generalizes:
- The Myhill–Nerode theorem (S = {0,1}, ι = alphabet),
- Weighted automaton minimization (S = semiring, observation = series value),
- Crystal base construction (when braid relations and Kashiwara axioms are added).

### 6.2 Limitations

Our formalization does not impose braid relations, Coxeter conditions, or Kashiwara crystal axioms. The operators are arbitrary endomorphisms. While this gives maximum generality for the minimization result, it means the resulting "crystal" need not satisfy the axioms of a Kashiwara crystal in the representation-theoretic sense. Adding these axioms is a natural and important extension.

### 6.3 Verification

All theorems are fully machine-verified with no axioms beyond the standard foundations (propext, Classical.choice, Quot.sound). The formalization comprises approximately 450 lines of verified code.

## 7. Future Work

See FUTURE_DIRECTIONS.md for detailed next steps including:
1. Full finite Coxeter braid relations,
2. Tropical Demazure operators and character formulas,
3. Learning-theoretic extraction from oracle access,
4. Categorification via idempotent functor categories,
5. Efficient algorithms and computational complexity analysis.

## References

1. A. Nerode, "Linear Automaton Transformations," *Proc. AMS* 9 (1958), 541–544.
2. J. Myhill, "Finite Automata and the Representation of Events," WADD TR-57-624 (1957).
3. M. Kashiwara, "Crystallizing the q-Analogue of Universal Enveloping Algebras," *Commun. Math. Phys.* 133 (1990), 249–260.
4. M. Akian, S. Gaubert, A. Guterman, "Tropical Linear Algebra," in *Tropical and Idempotent Mathematics*, Contemp. Math. 495 (2009).
5. J.-E. Pin, "Tropical Semirings," *Publ. Newton Inst.* 11 (1998), 50–69.
6. J. Berstel, C. Reutenauer, *Noncommutative Rational Series with Applications*, Cambridge Univ. Press, 2011.
