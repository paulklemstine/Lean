# Future Directions: Primewise Torsion Persistence Stability

## Synthesis

The results in this work establish that torsion persistence is not a monolithic phenomenon but decomposes canonically into independent prime channels, each with its own stability law. This opens five interconnected research directions: (1) proving the sharp valuation-sensitive improvement conjecture, (2) developing functorial localization for persistence modules, (3) extending to higher-dimensional torsion phenomena, (4) building practical algorithms for arithmetic TDA, and (5) establishing entropy-theoretic bounds for primewise information content. These directions are unified by the principle that **arithmetic structure provides hidden regularity in topological data**.

---

## Direction 1: Sharp Valuation-Sensitive Stability Bound

**Conjecture**: For filtrations whose interleaving maps have p-adic divisibility controlled by ν = v_p(δ), the primewise stability modulus satisfies

```
ε_p ≤ δ / p^ν
```

where ν is the p-adic valuation of the interleaving defect.

**Test**: Construct explicit filtrations over Z/p^k Z for k = 1, 2, 3 with interleaving maps whose matrix entries are divisible by p^ν. Compute the actual primewise shift and compare against δ/p^ν. The conjecture predicts a monotone decrease; a single counterexample falsifies it.

**Impact**: This would establish that p-adic arithmetic directly controls topological stability — a bridge between valuation theory and TDA that has no precedent.

**Catalog References**: `Pythagorean/PrimewiseTorsionStability.lean` — `primeShiftBound_improved`, `primeShiftBound_improved_strict`

**Proof Strategy**: Define a "p-controlled interleaving" structure where forward/backward maps factor through p^ν-multiplication. Transport the existing stability proof through this factorization, extracting the improved constant at each step. The key technical lemma: if the interleaving map sends x to p^ν · f(x) for injective f, then the induced birth shift is bounded by δ/p^ν rather than δ.

**Domain Bridges**: p-adic analysis, arithmetic geometry, Iwasawa theory

**Lineage**: Extends `pTorsionBirthSet_deltaClose` and `primeShiftBound_improved_strict`

**Ambition**: Grand challenge — this would be the first theorem importing valuation theory into persistence stability

---

## Direction 2: Functorial Localization of Persistence Modules

**Conjecture**: There exists a functor L_p from the category of ℤ-persistence modules to ℤ_(p)-persistence modules (localization at p) such that:

1. L_p preserves interleavings (with the same parameter δ)
2. PTorsionBirthSet(p, F) = TorsionBirthSet(L_p(F))
3. L_p transforms interleavings into potentially tighter interleavings when the interleaving maps have p-local structure

**Test**: Implement L_p for finite persistence modules represented as sequences of finitely generated abelian groups. Verify properties (1)-(2) on 100 random examples. Search for examples where (3) gives strictly improved δ.

**Impact**: This would make primewise stability a corollary of ordinary stability applied to a localized module — conceptually clean and opening the door to all localization techniques from commutative algebra.

**Catalog References**: `Pythagorean/PrimewiseTorsionStability.lean` — `pTorsionBirthSet_eq_torsionBirthSet`, `pTorsionBirthSet_deltaClose`

**Proof Strategy**: Define L_p as the tensor product with ℤ_(p). Show that ℤ_(p) is flat over ℤ, so tensoring preserves exact sequences and injective maps. The interleaving maps descend to L_p since tensor product is functorial. The key: show that PTorsionBirthSet equals the torsion birth set of the localized module.

**Domain Bridges**: Commutative algebra, algebraic topology, derived categories

**Lineage**: Extends `prime_channel_independence` and `torsion_detector_factorizes_over_primes`

**Ambition**: Solid extension — builds systematic algebraic infrastructure

---

## Direction 3: Primewise Birth Spectra Distinguish Filtrations

**Conjecture** (Hypothesis D): There exist filtrations F, G with TorsionBirthSet(F) = TorsionBirthSet(G) (as global sets) but PTorsionBirthSet(p, F) ≠ PTorsionBirthSet(p, G) for some prime p.

**Test**: Exhaustive search over filtered abelian groups with at most 4 levels and torsion orders dividing 30. For each pair with matching global birth, check if primewise births differ. The conjecture predicts at least one distinguishing example.

**Impact**: Proves the primewise invariant is strictly finer than the global one — the prime decomposition has real information content beyond relabeling.

**Catalog References**: `Pythagorean/PrimewiseTorsionStability.lean` — `mem_globalTorsionBirthSet_implies_exists_prime`

**Proof Strategy**: Construct F with Z/2Z at level 1 and Z/6Z at level 3; construct G with Z/3Z at level 1 and Z/6Z at level 3. Both have global torsion birth at level 1, but F has 2-torsion birth at 1 and 3-torsion birth at 3, while G has 3-torsion birth at 1 and 2-torsion birth at 3. Formalize this in Lean.

**Domain Bridges**: Algebraic topology, data science, topological signal processing

**Lineage**: Direct test of the theory's discriminating power

**Ambition**: Solid extension — concrete and falsifiable

---

## Direction 4: Global Stability as Max Envelope

**Conjecture** (Hypothesis C): For finite-type filtrations with finitely many active primes,

```
optimal_global_shift(F, G) = sup_p optimal_prime_shift(p, F, G)
```

where the supremum is over all primes p.

**Test**: Compute both sides on 1000 random filtration pairs with torsion orders in {2, 3, 5, 6, 10, 15, 30}. The conjecture predicts exact equality. A single instance of strict inequality (global < max primewise, or global > max primewise) would falsify it.

**Impact**: Confirms that the primewise decomposition is a complete refinement — no information is lost, and the global bound is exactly the worst-case prime channel.

**Catalog References**: `Pythagorean/PrimewiseTorsionStability.lean` — `global_stability_from_primewise`

**Proof Strategy**: The inequality global ≤ sup_p is immediate from `global_stability_from_primewise`. The reverse requires showing that the global birth distance equals the maximum primewise birth distance. This follows from the decomposition theorem: the global birth is at the minimum of all prime births, and the Hausdorff distance between minima is bounded by the max of individual distances.

**Domain Bridges**: Metric geometry, minimax theory

**Lineage**: Extends `global_stability_from_primewise` and `globalTorsionBirthSet_deltaClose`

**Ambition**: Solid extension — proves completeness of the decomposition

---

## Direction 5: Primewise Entropy and Data Processing Inequality

**Conjecture** (Hypothesis E): Define the primewise birth entropy as

```
H_p(F) = -Σ_i (count of p-torsion births at level i / total) * log(...)
```

(using a suitable normalization over a family of filtrations). Then applying a prime-selective functor cannot increase H_p — i.e., the primewise entropy satisfies a data processing inequality.

**Test**: Define empirical birth entropy for finite filtration families. Compute before and after applying a prime-selective simplification (e.g., killing q-torsion for q ≠ p). Check whether H_p decreases or stays constant. The conjecture predicts H_p never increases; a single increase falsifies it.

**Impact**: Connects persistence theory to information theory via the arithmetic channel model. Would establish that primewise torsion is not just algebraically natural but information-theoretically optimal.

**Catalog References**: `Pythagorean/PrimewiseTorsionStability.lean` — `torsion_detector_factorizes_over_primes`, `prime_channel_independence`

**Proof Strategy**: Model the prime-selective functor as a deterministic channel in the sense of information theory. Use the standard data processing inequality for deterministic maps. The key: show that the prime-selective functor is a retraction (left inverse of inclusion), hence post-processing, hence cannot increase mutual information.

**Domain Bridges**: Information theory, statistical mechanics, topological data analysis

**Lineage**: Grand challenge extending the cross-domain signal processing interpretation

**Ambition**: Grand challenge — merges information theory with arithmetic topology
