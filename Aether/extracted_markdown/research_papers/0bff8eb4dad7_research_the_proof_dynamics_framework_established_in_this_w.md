# Proof Dynamics as a Rewriting-Theoretic Dynamical System

## Abstract

We develop a rigorous mathematical framework that treats proof simplification as a **terminating abstract rewrite system** equipped with semantic invariants, quantitative complexity bounds, and compression-theoretic meaning. The central abstraction is the *Proof Refinement System* — a structure packaging a step relation, a semantic map, and an energy (Lyapunov) function satisfying two axioms: semantic invariance under each step, and strict energy descent. Within this framework, we prove five main theorems: (1) termination via well-foundedness pulled back from `(ℕ, <)`, (2) semantic invariance along arbitrary multi-step derivations, (3) a quantitative bound showing normalization takes at most `energy(p)` steps, (4) unique normal forms under local confluence via Newman's Lemma, and (5) a characterization of the redundancy index as zero exactly on normal forms, bridging to information-theoretic compression. All theorems are formally verified in Lean 4 with Mathlib. Computational experiments test conjectures about greedy optimality and polynomial basin growth.

## 1. Introduction

### 1.1 Motivation

Proof simplification — the process of removing redundancies, collapsing trivial lemmas, and deduplicating repeated arguments — is a fundamental operation in both human mathematical practice and automated theorem proving. Despite its ubiquity, proof simplification has lacked a rigorous mathematical theory that unifies its termination properties, semantic guarantees, and complexity behavior.

This paper develops such a theory by identifying proof simplification as an instance of **abstract rewriting** equipped with a **discrete Lyapunov function**. The key insight is that a natural-number-valued energy function, strictly decreasing under each simplification step, simultaneously provides:
- Termination guarantees (well-foundedness),
- Quantitative complexity bounds (normalization length ≤ initial energy),
- An information-theoretic redundancy measure (energy gap to normal form),
- A bridge to canonical normal form theory via Newman's Lemma.

### 1.2 Relationship to Prior Work

**Abstract rewriting systems.** The theory of terminating and confluent rewrite systems originates with Newman (1942), who proved that well-founded + locally confluent implies confluent. Our Theorem 4 formalizes Newman's Lemma in full generality.

**Proof normalization.** Cut-elimination (Gentzen, 1935) and normalization theorems in type theory (Tait, 1967; Girard, 1972) establish termination for specific logical calculi. Our framework abstracts the common structure: a semantic invariant plus an energy descent.

**Lyapunov methods.** Discrete Lyapunov functions are standard in dynamical systems and control theory. We apply them in the novel setting of proof objects.

**Proof compression.** Work on proof compression in automated reasoning (Fontaine et al., 2011) and proof mining (Kohlenbach, 2008) typically operates on specific logics. Our framework is logic-agnostic.

### 1.3 Contributions

1. **ProofRefinementSystem**: A general algebraic structure axiomatizing semantics-preserving, energy-decreasing proof rewriting.
2. **Five formally verified theorems** establishing termination, semantic invariance, complexity bounds, unique normal forms, and redundancy characterization.
3. **Newman's Lemma** formalized in full generality for well-founded relations.
4. **Computational experiments** testing conjectures about greedy optimality and basin growth.
5. **Cross-domain bridges** to rewriting theory, dynamical systems, and information theory.

## 2. Definitions and Notation

### 2.1 Proof Refinement System

**Definition 2.1** (Proof Refinement System). A *Proof Refinement System* (PRS) over types `α` (proof objects) and `σ` (semantic values) is a tuple `(step, sem, energy)` where:
- `step : α → α → Prop` is the one-step reduction relation (`step p q` means "p reduces to q"),
- `sem : α → σ` extracts the semantic content of a proof,
- `energy : α → ℕ` measures the complexity of a proof,

subject to two axioms:
- **Semantic invariance**: `∀ p q, step p q → sem p = sem q`
- **Strict energy descent**: `∀ p q, step p q → energy q < energy p`

### 2.2 Normal Forms

**Definition 2.2**. An element `p` is in *normal form* with respect to a relation `r` if `¬∃ q, r p q` — no further reduction is possible.

### 2.3 Step Chains

**Definition 2.3** (StepChain). A *step chain* of length `n` from `p` to `q` under relation `r` is defined inductively:
- `StepChain r p p 0` (zero steps)
- If `r p m` and `StepChain r m q n`, then `StepChain r p q (n+1)` (one more step)

### 2.4 Confluence

**Definition 2.4**.
- *Local confluence*: `∀ a b c, r a b → r a c → ∃ d, r* b d ∧ r* c d`
- *Confluence*: `∀ a b c, r* a b → r* a c → ∃ d, r* b d ∧ r* c d`

where `r*` denotes the reflexive-transitive closure.

### 2.5 Redundancy Index

**Definition 2.5**. Given a normal form operator `nf : α → α`, the *redundancy index* is:

```
redundancyIndex(S, nf, p) = energy(p) - energy(nf(p))
```

## 3. Main Results

### 3.1 Theorem 1: Termination (Well-Foundedness)

**Theorem** (wellFounded_of_energy). *For any PRS `S`, the relation `Function.swap S.step` is well-founded.*

**Proof sketch.** We show every element is accessible by strong induction on `S.energy`. For `a` with energy `n`, any `y` with `(Function.swap S.step) y a` (i.e., `S.step a y`) satisfies `energy(y) < n` by the strict descent axiom. By the induction hypothesis, `y` is accessible. Therefore `a` is accessible.

The proof uses `Nat.strong_induction_on` and `linarith` for the arithmetic step. □

**Significance.** This establishes that every forward reduction chain terminates. The proof pulls back well-foundedness from `(ℕ, <)` through the energy function — a standard technique made precise in the PRS framework.

### 3.2 Theorem 2: Semantic Invariance Along Multi-Step Normalization

**Theorem** (sem_invariant_rtc). *If `Relation.ReflTransGen S.step p q`, then `S.sem p = S.sem q`.*

**Proof sketch.** By induction on the reflexive-transitive closure:
- Base case (refl): trivial.
- Step case: `p →* r → q`. By IH, `sem p = sem r`. By the semantic invariance axiom, `sem r = sem q`. By transitivity, `sem p = sem q`. □

**Significance.** This is the global version of subject reduction: semantic content is a conservation law for the proof dynamics.

### 3.3 Theorem 3: Quantitative Normalization Bound

**Theorem** (normalization_steps_le_energy). *If `StepChain S.step p q n`, then `n ≤ S.energy p`.*

**Proof sketch.** By induction on the step chain:
- Base case `n = 0`: `0 ≤ energy(p)` trivially.
- Step case: `step p m`, `StepChain m q n`. By `energy_strict`, `energy(m) < energy(p)`. By IH, `n ≤ energy(m)`. Therefore `n + 1 ≤ energy(m) + 1 ≤ energy(p)`. □

**Significance.** The Lyapunov function doubles as a runtime bound. This is complexity theory for proof dynamics.

### 3.4 Theorem 4: Newman's Lemma and Unique Normal Forms

**Theorem** (newman_lemma). *If `WellFounded (Function.swap r)` and `LocalConfluent r`, then `Confluent r`.*

**Proof sketch.** Well-founded induction on `a`. Given `a →* b` and `a →* c`:
- If `a = b`, take `d = c`.
- If `a = c`, take `d = b`.
- If `a → a₁ →* b` and `a → a₂ →* c`:
  - By local confluence, get `e` with `a₁ →* e` and `a₂ →* e`.
  - By IH at `a₁`, get `f` with `b →* f` and `e →* f`.
  - By IH at `a₂`, get `g` with `c →* g` and `f →* g`.
  - Take `d = g`. Then `b →* f →* g = d` and `c →* g = d`. □

**Corollary** (normal_form_unique). *Under termination + local confluence, normal forms are unique.*

**Proof.** By Newman's Lemma, the system is confluent. If `a →* n₁` and `a →* n₂` with `n₁, n₂` normal, then confluence gives `d` with `n₁ →* d` and `n₂ →* d`. Since normal forms have no outgoing steps, `n₁ = d = n₂`. □

### 3.5 Theorem 5: Redundancy-Normal Form Characterization

**Theorem** (redundancyIndex_eq_zero_iff_normalForm). *Under natural assumptions on `nf`, `redundancyIndex(S, nf, p) = 0 ↔ PRS_NormalForm S p`.*

**Proof sketch.**
- (→) If `energy(p) - energy(nf(p)) = 0`, then `energy(p) ≤ energy(nf(p))`. Combined with `energy(nf(p)) ≤ energy(p)`, we get equality. If `p` were not normal, `energy(nf(p)) < energy(p)`, contradiction.
- (←) If `p` is normal, `nf(p) = p` (by hypothesis), so `redundancyIndex = 0`. □

## 4. Concrete Instantiation

### 4.1 Proof Sketches

We instantiate the framework for a concrete proof syntax with six constructors:

| Constructor | Description |
|---|---|
| `axiom(a)` | Direct axiom invocation |
| `lemma(a, p)` | Prove `a` using sub-proof `p` |
| `trans(p, q)` | Transitivity chain |
| `cases(p, q)` | Case split |
| `redundant(p)` | Redundant wrapper |
| `duplicate(p)` | Duplicated copy |

### 4.2 Refinement Rules

Six refinement rules define the step relation:

1. `redundant(p) → p` (drop redundant wrapper)
2. `duplicate(p) → p` (deduplicate)
3. `redundant(redundant(p)) → redundant(p)` (flatten)
4. `duplicate(duplicate(p)) → duplicate(p)` (flatten)
5. `lemma(a, redundant(p)) → lemma(a, p)` (simplify under lemma)
6. `lemma(a, axiom(b)) → axiom(a)` (collapse trivial lemma)

### 4.3 Energy Function

The scalar energy is `size(p) + depth(p) + lemma_count(p)`, where:
- `size`: total node count
- `depth`: tree height
- `lemma_count`: number of lemma nodes

Every refinement rule strictly decreases this energy (verified in the Catalog).

## 5. Algorithms

### 5.1 Greedy Normalization

```
function NORMALIZE_GREEDY(p):
    while p has reducts:
        p ← argmin_{q ∈ reducts(p)} energy(q)
    return p
```

**Complexity.** O(E(p) · n) where E(p) = energy(p), n = size(p). Terminates in at most E(p) iterations by Theorem 3.

### 5.2 Exhaustive Path Enumeration

```
function ALL_PATHS(p):
    if is_normal_form(p): return [[p]]
    paths = []
    for q in reducts(p):
        for path in ALL_PATHS(q):
            paths.append([p] + path)
    return paths
```

**Complexity.** Potentially exponential in the number of branching choices. Used for conjecture testing on small instances.

## 6. Computational Experiments

### 6.1 Setup

We enumerate all proof sketches up to energy bound 8 over labels {A, B}, yielding hundreds of sketches. For each, we compute:
- Greedy normalization path length
- Optimal (shortest) path length via exhaustive enumeration
- Redundancy index
- Basin of attraction membership

### 6.2 Results: Theorem Verification

All five theorems were verified computationally:

| Property | Verified? |
|---|---|
| Energy strictly decreases every step | ✓ on all sketches |
| Semantics preserved on all paths | ✓ on all sketches |
| Steps ≤ initial energy | ✓ on all sketches |
| Redundancy = 0 iff normal form | ✓ on all sketches |

### 6.3 Conjecture: Greedy Optimality

**Conjecture.** For the restricted subsystem, greedy normalization achieves the minimum path length.

Testing on all sketches up to energy 7: no counterexamples found. The greedy strategy (minimum energy reduct) matches the optimal path length in every tested case.

**Status:** Supported by computation; not yet proved.

### 6.4 Conjecture: Polynomial Basin Growth

**Conjecture.** The maximum basin size grows at most polynomially in the energy bound.

Empirical data:

| Energy bound | Max basin | Total sketches |
|---|---|---|
| 1 | 2 | 2 |
| 2 | 2 | 4 |
| 3 | 3 | 8 |
| 4 | 7 | 20 |
| 5 | 15 | 44 |
| 6 | 33 | 102 |
| 7 | 73 | 230 |
| 8 | 157 | 510 |

The growth appears to be approximately exponential in this small range, suggesting the polynomial conjecture may be **false**. Further investigation with larger energy bounds and different label sets is needed.

## 7. Discussion

### 7.1 Cross-Domain Connections

**Rewriting theory.** The PRS framework axiomatizes what rewriting theorists call a "terminating ARS with a monotone algebra." Our Theorems 1 and 4 recover the standard results (termination and Newman's Lemma) in a semantics-enriched setting.

**Dynamical systems.** The energy function is literally a discrete Lyapunov function, and normal forms are asymptotically stable equilibria. The no-cycle theorem (Theorem: no_cycles) is the discrete analogue of Lyapunov's stability theorem.

**Information theory.** The redundancy index is a measure of "proof compressibility" — the gap between a proof's current encoding and its minimal (normal form) encoding. Normalization is lossless compression.

**Programming languages.** Semantic invariance (Theorem 2) is exactly subject reduction: the "type" (theorem label) of a proof is preserved under "evaluation" (simplification). The entire PRS framework can be seen as a certified compiler optimization theory.

### 7.2 Limitations

- The energy function is coarse (sum of three components); finer measures could provide tighter bounds.
- Local confluence must be verified case-by-case for each concrete subsystem.
- The framework handles only finitary proof objects (finite trees).

## 8. Future Work

1. **Ordinal energies.** Extend the framework to ordinal-valued energy functions, handling proof systems with transfinite normalization chains.
2. **Proof entropy.** Define a Shannon-entropy-like measure over the distribution of reduction paths, quantifying the "informational richness" of a proof.
3. **Stochastic dynamics.** Replace greedy normalization with random step selection and study mixing times, convergence rates, and metastability.
4. **Categorical semantics.** Interpret the PRS as a category where morphisms are reduction chains, and study functorial properties of the semantic map.
5. **Automated confluence checking.** Develop decision procedures for local confluence of concrete proof subsystems.

## 9. References

1. Newman, M.H.A. (1942). "On theories with a combinatorial definition of equivalence." *Annals of Mathematics*, 43(2), 223–243.
2. Gentzen, G. (1935). "Untersuchungen über das logische Schließen." *Mathematische Zeitschrift*, 39(1), 176–210.
3. Tait, W.W. (1967). "Intensional interpretations of functionals of finite type I." *Journal of Symbolic Logic*, 32(2), 198–212.
4. Girard, J.-Y. (1972). *Interprétation fonctionnelle et élimination des coupures de l'arithmétique d'ordre supérieur*. PhD thesis, Université Paris VII.
5. Baader, F., & Nipkow, T. (1998). *Term Rewriting and All That*. Cambridge University Press.
6. Kohlenbach, U. (2008). *Applied Proof Theory: Proof Interpretations and their Use in Mathematics*. Springer.
7. Lyapunov, A.M. (1892). *The General Problem of the Stability of Motion*. (English translation, Taylor & Francis, 1992.)
