# Future Directions: Ultrametric Proof Automaton Duality

This document outlines 5 concrete breakthrough research directions opened by the formalization of the ultrametric proof automaton duality theorem.

---

## 1. Profinite Completion and Inverse-Limit Ultrametric Proof Spaces

**Theorem Target:**
For a compatible family of finite proof systems `{(P_n, step_n, obs_n)}` with surjective bonding maps `π_{n,m} : P_n → P_m` (for n ≥ m) that respect observational equivalence, the inverse limit `P_∞ = lim← P_n` carries a canonical profinite topology, and the minimal proof automaton of `P_∞` is recovered as the inverse limit of the finite minimal automata.

**Proof Strategy:**
- Define compatible families of finite proof systems as a functor from `(ℕ, ≥)` to the category of finite proof systems with automaton morphisms.
- Use the universal property of inverse limits in the category of compact Hausdorff spaces.
- Show that observational equivalence on `P_∞` equals the intersection of pulled-back equivalences from all finite levels.
- The minimal automaton of `P_∞` is the inverse limit of the quotient automata, which is a compact metrizable space with the limit ultrametric.

**Key Lemma (formalizable):**
```
theorem profinite_limit_automaton_exists
    {P : ℕ → Type*} [∀ n, Fintype (P n)]
    (step : ∀ n, Sym → P n → P n)
    (obs : ∀ n, O → P n → S)
    (bond : ∀ n, P (n+1) → P n)
    (hcompat : ∀ n σ p, bond n (step (n+1) σ p) = step n σ (bond n p)) :
    ∃ Q : Type*, CompactSpace Q ∧ T2Space Q ∧ ...
```

**Cross-Domain Impact:** Connects to p-adic analysis (Qₚ as inverse limit of Z/p^n Z), profinite groups in Galois theory, and continuous automata in formal language theory.

---

## 2. Krohn–Rhodes Decomposition for Ultrametric Proof Automata

**Theorem Target:**
Every finite ultrametric proof automaton admits a wreath-product decomposition into "prime" components: simple group components (handling symmetry) and aperiodic/counter-free components (handling sequential logic). The ultrametric structure constrains which decompositions are metrically compatible.

**Proof Strategy:**
- Formalize the classical Krohn–Rhodes theorem for finite semigroups/automata.
- Define "metrically compatible" wreath products: the ultrametric on the composite automaton is bounded by a function of the component metrics.
- Show that the prime decomposition of the transition monoid of a minimal proof automaton respects the non-Archimedean rank structure.
- Prove that aperiodic components correspond to "star-free" observer predicates.

**Key Definitions:**
```
structure MetricWreathProduct (A B : Type*) [DPA A Sym O S] [DPA B Sym O S] where
  composite : DPA (A × B) Sym O S
  metric_bound : ∀ p q, sep_composite p q ≤ max (sep_A (fst p) (fst q)) (sep_B (snd p) (snd q))
```

**Cross-Domain Impact:** Connects to algebraic automata theory, circuit complexity (the Krohn–Rhodes theorem is related to NC¹ vs ACC⁰), and hierarchical proof compression.

---

## 3. Tropical Entropy and Mutual Information for Observer Spectra

**Theorem Target:**
Define a tropical (min-plus) entropy for observer spectra measuring the "information content" of the observer family, and prove:
1. The tropical entropy equals the log of the number of equivalence classes (states of the minimal automaton).
2. The tropical mutual information between two observer subfamilies satisfies a chain rule.
3. Adding an observer that doesn't refine any equivalence class has zero tropical mutual information gain.

**Proof Strategy:**
- Define tropical entropy as `H_trop(obs) = log₂(|P/≈|)` where `≈` is observational equivalence.
- Define conditional tropical entropy and mutual information via the lattice of congruences.
- The chain rule follows from the second isomorphism theorem for congruences.
- Zero-gain theorem follows from the kernel characterization: if the new observer doesn't split any class, the trace map kernel is unchanged.

**Key Theorem:**
```
theorem tropical_entropy_eq_log_states
    {P Sym O S : Type*} [Fintype P]
    (step : Sym → P → P) (obs : O → P → S) :
    tropical_entropy step obs = Nat.log 2 (Fintype.card (ProofStateQuotient step obs allAdmissible))
```

**Cross-Domain Impact:** Connects to information theory, tropical geometry, rate-distortion theory for proof compression, and PAC learning bounds for automata identification.

---

## 4. Sheaf Semantics on Proof Trees via Prime-Congruence Residuation

**Theorem Target:**
The observer-trace semimodule, when viewed as a presheaf on the poset of prime congruences ordered by refinement, satisfies the sheaf condition. The global sections of this sheaf recover the original proof dynamics up to observational equivalence.

**Proof Strategy:**
- Define the site: objects are prime congruences (observers that cannot be decomposed as intersections of strictly coarser congruences), morphisms are refinements.
- The presheaf assigns to each prime congruence `c` the quotient `P/c`.
- The sheaf condition states that if local sections (quotient elements) are compatible on overlaps (common coarsenings), they glue to a unique global section.
- This follows from the Chinese Remainder Theorem for congruences when the prime family is separating.

**Key Structures:**
```
structure ProofSheaf (P : Type*) (Primes : Set (Congruence P)) where
  sections : ∀ c ∈ Primes, Type*
  restriction : ∀ c d (hcd : c ≤ d), sections d → sections c
  gluing : (compatible local sections) → global section
  uniqueness : gluing is unique
```

**Cross-Domain Impact:** Connects to algebraic geometry (structure sheaf of Spec), topos theory, and categorical semantics of type theory. Potentially yields a "proof-theoretic Nullstellensatz."

---

## 5. Learnability Bounds from Observer VC-Dimension

**Theorem Target:**
Define a VC-dimension for observer families acting on proof states, and prove:
1. The minimal automaton has at most `2^(VC-dim)` states.
2. An observer family of VC-dimension `d` can be exactly identified from `O(d · log |P|)` membership queries (observer evaluations).
3. The sample complexity for PAC-learning the minimal automaton from random observer traces is `Θ(d / ε)`.

**Proof Strategy:**
- Define VC-dimension of the observer family: the largest set of proof states that can be "shattered" (all 2^k observation patterns realized) by the observers.
- The bound on automaton states follows from the Sauer–Shelah lemma.
- The identification algorithm uses the equivalence between trace map kernel and observational equivalence: binary search over observer evaluations to determine equivalence classes.
- PAC bounds follow from standard VC-theory applied to the hypothesis class of quotient automata.

**Key Theorem:**
```
theorem automaton_states_le_vc_bound
    {P Sym O : Type*} [Fintype P] [Fintype O]
    (step : Sym → P → P) (obs : O → P → Bool) :
    Fintype.card (ProofStateQuotient step obs allAdmissible) ≤ 2 ^ vc_dimension step obs
```

**Cross-Domain Impact:** Connects to computational learning theory (Angluin's L* algorithm for DFA learning), query complexity, and active learning for theorem provers. The ultrametric structure potentially gives tighter bounds via hierarchical sampling.

---

## Summary of Research Priorities

| Direction | Difficulty | Impact | Dependencies |
|-----------|-----------|--------|-------------|
| 1. Profinite completion | Medium | High | Category theory, topology |
| 2. Krohn–Rhodes | Hard | Very High | Semigroup theory, wreath products |
| 3. Tropical entropy | Medium | High | Information theory |
| 4. Sheaf semantics | Hard | Very High | Algebraic geometry, topos theory |
| 5. VC-dimension bounds | Medium | High | Learning theory, combinatorics |

**Recommended order:** 3 → 5 → 1 → 4 → 2 (increasing difficulty, each building on prior results).
