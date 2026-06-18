# Future Directions: Jacobson Adequacy for Closure-Generated Proof Semirings

This document outlines concrete next steps building on the semantic adequacy theorem:

> `derivable x y ↔ ∀ e, AdmissibleEvaluation e → (e x → e y)`

proved in `Bridges/JacobsonAdequacy/Theorems.lean`.

---

## 1. Decidable Semi-Algorithm for Non-Derivability via Finite Evaluation Search

**Statement**: For finitely generated coherent closure proof semirings, non-derivability
can be witnessed by a *finite* search over prime ideals.

**Formalization target**:
```lean
theorem finite_witness_of_not_derivable
    [Fintype S] [CoherentClosureProofSemiring S] {x y : S} :
    ¬ derivable x y →
    ∃ (J : Finset S), IsPrimeIdeal J ∧ cl y ∈ J ∧ cl x ∉ J
```

**Why it matters**: This turns semantic completeness into a proof-search procedure.
For finite lattices, the prime ideal spectrum is finite and enumerable, giving
a complete refutation algorithm. For infinite but finitely presented lattices,
coherence (= compactness of the spectrum) should give finite certificates.

**Approach**: Use `Fintype` to enumerate all subsets, filter for prime ideals,
and apply the adequacy theorem.

---

## 2. Nucleus-Sheaf Interpretation and Global Section Indistinguishability

**Statement**: The Jacobson proof congruence equals the sheaf-theoretic global
section indistinguishability relation on the prime spectrum.

**Formalization target**:
```lean
theorem proof_congruence_eq_sheaf_global_sections
    [CoherentClosureProofSemiring S] :
    proofCongruence = globalSectionCongruence (primeSpectrum S)
```

**Why it matters**: This connects the algebraic adequacy theorem to the topos-theoretic
perspective on proof systems. The closure operator is a nucleus on a frame, and the
proof congruence corresponds to the global sections of the associated sheaf. This
gives a geometric interpretation of derivability.

**Approach**: Define the prime spectrum as a topological space (spectral space),
construct the structure sheaf using localization at prime points, and show that
global section equality corresponds to derivability.

---

## 3. Tropicalization of Admissible Evaluations and Min-Plus Completeness

**Statement**: When the proof semiring has tropical (min-plus or max-plus) structure,
admissible evaluations specialize to tropical valuations, and the adequacy theorem
becomes a tropical Nullstellensatz.

**Formalization target**:
```lean
theorem tropical_adequacy
    [TropicalClosureProofSemiring S] (x y : S) :
    derivable x y ↔ ∀ v, TropicalValuation v → v x ≤ v y
```

**Why it matters**: Tropical geometry provides efficient algorithms for optimization
and integer programming. A tropical adequacy theorem would connect proof-theoretic
derivability to tropical convexity, enabling optimization-based proof search.

**Approach**: Define tropical closure proof semirings (where `⊔` is min/max and `⊓`
is addition), show that admissible evaluations specialize to tropical valuations,
and apply the general adequacy theorem.

---

## 4. Quantitative Countermodel Bounds from Coherence Rank

**Statement**: The "size" of the smallest countermodel is bounded by the coherence
rank of the proof semiring.

**Formalization target**:
```lean
theorem countermodel_size_bound
    [CoherentClosureProofSemiring S] {x y : S} :
    ¬ derivable x y →
    ∃ (n : ℕ) (e : Fin n → S → Prop),
      (∀ i, AdmissibleEvaluation (e i)) ∧
      n ≤ coherenceRank S ∧
      ∃ i, ¬ (e i x → e i y)
```

**Why it matters**: Quantitative bounds on countermodel size directly translate to
complexity bounds on refutation. If the coherence rank is polynomial in the size
of the presentation, this gives efficient refutation algorithms.

**Approach**: Analyze the proof of the prime ideal theorem to extract size bounds.
The key input is the compactness/coherence condition, which controls how many
prime ideals are needed to cover the spectrum.

---

## 5. Thermodynamic Dual Semantics: Free-Energy Interpretation

**Statement**: In the thermodynamic interpretation, derivability corresponds to
non-positive free-energy gap: `derivable x y ↔ F(x) - F(y) ≤ 0` where `F` is
a free-energy functional derived from the partition function over admissible
evaluations.

**Formalization target**:
```lean
theorem thermodynamic_duality
    [CoherentClosureProofSemiring S] [MeasurableSpace S] (x y : S) :
    derivable x y ↔ freeEnergyGap x y ≤ 0
```

where `freeEnergyGap x y = sup { log(P(e x)) - log(P(e y)) | e admissible }`.

**Why it matters**: This connects proof theory to statistical mechanics, where
the "temperature" parameter controls the sharpness of the evaluation. At zero
temperature (the "ground state"), the evaluations concentrate on the separating
prime ideals, recovering the algebraic adequacy theorem. At positive temperature,
the free-energy gap provides a smooth relaxation of derivability that could be
optimized by gradient methods.

**Approach**: Define the partition function as a sum/integral over admissible
evaluations, define the free energy via the Legendre transform, and show that
the zero-temperature limit recovers the algebraic adequacy theorem.

---

## Additional Directions

- **Categorical adequacy**: Generalize from lattices to categories with closure
  monads, proving adequacy for categorical proof systems.
- **Constructive adequacy**: Investigate which parts of the proof can be made
  constructive (the prime ideal theorem requires Zorn's lemma / Boolean Prime
  Ideal Theorem, but finite versions are constructive).
- **Automated refutation**: Implement the finite evaluation search as a Lean
  tactic that automatically refutes false `derivable` claims.
- **Connection to Lindenbaum-Tarski algebras**: Show that for propositional
  logics, the coherent closure proof semiring is the Lindenbaum-Tarski algebra
  and the adequacy theorem specializes to the classical completeness theorem.
