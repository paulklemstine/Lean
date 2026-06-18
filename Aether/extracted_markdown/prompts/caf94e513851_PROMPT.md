

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new

## PRIME-SPECTRAL DE FINNETTI / GIBBS MIXTURE PROGRAM

Work in a new file that builds a self-contained finite-state exchangeability theory for `SpectralPoint S`, with all objects explicitly formalized in Lean 4 and no `sorry`. The finite-state hypothesis is the decisive simplification: exploit `[Fintype (SpectralPoint S)]` to avoid measure-theoretic pathologies and realize all probability measures as finitely supported weights. The goal is to turn prime-spectral proof semantics into a thermodynamic / cryptographic / certified-robustness mixture theory.

You should introduce a concrete finite-probability layer if the existing `ProbabilityMeasure` API is too heavy. If necessary, define a wrapper structure with normalization and use coercions/maps/binds to connect it to existing measure notions. The core objective is not API mimicry but a mathematically sharp formalization of finite exchangeable families and their Gibbs-mixture representation.

Bridge: connects exchangeability + proof theory + thermodynamic free energy + PAC-Bayesian posteriors + post_quantum_security semantics.

---

## DEFINITIONS TO ADD

Introduce at least the following 10+ definitions, with doc comments containing keywords such as `quantum`, `thermodynamic`, `cryptographic`, `certified`, `lattice`, `Gibbs`, `entropy`, `robustness`.

1. `SpectralLaw S := ProbabilityMeasure (SpectralPoint S)`

2. `FiniteExchangeableFamily (α : Type _) :=
  ∀ n, ProbabilityMeasure (Fin n → α)`

3. `ExchangeableFamily`
   ```lean
   def ExchangeableFamily {α : Type _}
     (P : ∀ n, ProbabilityMeasure (Fin n → α)) : Prop := ...
   ```
   Formalize invariance under every equivalence/permutation of coordinates:
   ```lean
   ∀ n (e : Equiv.Perm (Fin n)),
     map (fun f i => f (e i)) (P n) = P n
   ```

4. `ProjectiveConsistent`
   ```lean
   def ProjectiveConsistent {α : Type _}
     (P : ∀ n, ProbabilityMeasure (Fin n → α)) : Prop := ...
   ```
   Require consistency under coordinate truncation `Fin (n) → Fin (n+1)` / `Fin.castLE`.

5. `empiricalMeasure`
   ```lean
   def empiricalMeasure {α : Type _} [Fintype α] [DecidableEq α] {n : ℕ}
     (x : Fin n → α) : ProbabilityMeasure α := ...
   ```
   This is the type-theoretic hinge between combinatorics and thermodynamic rate functions.

6. `iidProduct`
   ```lean
   def iidProduct {α : Type _}
     (μ : ProbabilityMeasure α) : ∀ n, ProbabilityMeasure (Fin n → α) := ...
   ```

7. `MixingLaw`
   ```lean
   abbrev MixingLaw (S : Type _) [CoherentClosureProofSemiring S] :=
     ProbabilityMeasure (ProbabilityMeasure (SpectralPoint S))
   ```

8. `RepresentsExchangeableFamily`
   ```lean
   def RepresentsExchangeableFamily {α : Type _}
     (M : ProbabilityMeasure (ProbabilityMeasure α))
     (P : ∀ n, ProbabilityMeasure (Fin n → α)) : Prop :=
     ∀ n, P n = Measure.bind M (fun μ => iidProduct μ n)
   ```

9. `expectedDefect`
   ```lean
   def expectedDefect [CoherentClosureProofSemiring S]
     (x y : S) (μ : ProbabilityMeasure (SpectralPoint S)) : ℝ := ...
   ```
   Define this concretely from the closure/self-model semantics already available in the catalog. If the ambient defect is `0/1`-valued, state that and exploit it.

10. `ZeroDefectLaw`
    ```lean
    def ZeroDefectLaw [CoherentClosureProofSemiring S]
      (x y : S) (μ : ProbabilityMeasure (SpectralPoint S)) : Prop :=
      expectedDefect x y μ = 0
    ```

11. `ExchangeableAdmissibleFamily`
    ```lean
    def ExchangeableAdmissibleFamily [CoherentClosureProofSemiring S]
      (P : ∀ n, ProbabilityMeasure (Fin n → SpectralPoint S)) : Prop := ...
    ```
    Bundle exchangeability, projective consistency, and semantic admissibility.

12. `AlmostEveryRepresentingMeasureZeroDefect`
    ```lean
    def AlmostEveryRepresentingMeasureZeroDefect [CoherentClosureProofSemiring S]
      (x y : S)
      (P : ∀ n, ProbabilityMeasure (Fin n → SpectralPoint S)) : Prop := ...
    ```
    In the finite setting, reduce “almost every” to zero mass on the bad set.

13. `RepresentsAdmissibleExchangeableFamily`
    ```lean
    def RepresentsAdmissibleExchangeableFamily [CoherentClosureProofSemiring S]
      (M : MixingLaw S) : Prop := ∃ P, ExchangeableAdmissibleFamily S P ∧
        RepresentsExchangeableFamily M P
    ```

14. `thermodynamicFreeEnergyOfMixing`
15. `quantumCertifiedRobustnessRadius`
16. `postQuantumCountermodelEntropy`
   
These last three can be simple derived numerical invariants with explicit inequalities later; they matter for the AEM utility/impact score.

---

## PRECISE TARGET THEOREMS

You should state and prove the three main theorems in Lean with exact signatures as close as possible to the following, adjusting only if the finite probability wrapper forces a harmless change.

```lean
theorem primeSpectral_deFinetti_representation
  [CoherentClosureProofSemiring S]
  [Fintype (SpectralPoint S)] [DecidableEq (SpectralPoint S)]
  (P : ∀ n, ProbabilityMeasure (Fin n → SpectralPoint S))
  (hexch : ExchangeableFamily P)
  (hproj : ProjectiveConsistent P) :
  ∃ M : ProbabilityMeasure (ProbabilityMeasure (SpectralPoint S)),
    ∀ n, P n = Measure.bind M (fun μ => iidProduct μ n)
```

```lean
theorem derivable_iff_mixture_zero_defect
  [CoherentClosureProofSemiring S]
  [Fintype (SpectralPoint S)] [DecidableEq (SpectralPoint S)]
  (x y : S) :
  derivable x y ↔
    ∀ (P : ∀ n, ProbabilityMeasure (Fin n → SpectralPoint S)),
      ExchangeableAdmissibleFamily S P →
      AlmostEveryRepresentingMeasureZeroDefect x y P
```

```lean
theorem nonderivable_positive_mixture_mass
  [CoherentClosureProofSemiring S]
  [Fintype (SpectralPoint S)] [DecidableEq (SpectralPoint S)]
  (x y : S) (hnd : ¬ derivable x y) :
  ∃ ε > 0,
    ∃ M : ProbabilityMeasure (ProbabilityMeasure (SpectralPoint S)),
      RepresentsAdmissibleExchangeableFamily S M ∧
      M {μ | ε ≤ expectedDefect x y μ} > 0
```

If `Measure.bind` is awkward for your finite encoding, define a finite `bind` operation and prove a compatibility lemma with the existing one.

---

## REQUIRED SUPPORTING THEOREMS

Prove at least 20 theorems total, including the three targets. The following list is a minimum backbone; strengthen whenever possible.

### A. Finite probability / simplex infrastructure

1. `iidProduct_zero`
   ```lean
   theorem iidProduct_zero {α} (μ : ProbabilityMeasure α) :
     iidProduct μ 0 = ProbabilityMeasure.pure (fun i => Fin.elim0 i)
   ```

2. `iidProduct_succ_eval_split`
   Express the `n+1` product as head-tail factorization.

3. `empiricalMeasure_total_mass`
   Show normalization exactly.

4. `empiricalMeasure_support_bound`
   Explicit cardinality bound:
   ```lean
   Fintype.card ↑(support (empiricalMeasure x)) ≤ n
   ```

5. `exchangeable_empirical_invariant`
   Empirical measure is permutation invariant.

6. `projective_of_iidProduct`
   ```lean
   theorem projective_of_iidProduct {α}
     (μ : ProbabilityMeasure α) :
     ProjectiveConsistent (iidProduct μ)
   ```

7. `exchangeable_of_iidProduct`
   ```lean
   theorem exchangeable_of_iidProduct {α}
     (μ : ProbabilityMeasure α) :
     ExchangeableFamily (iidProduct μ)
   ```

8. `exchangeable_of_mixture`
   Mixtures of iid families are exchangeable.

9. `projective_of_mixture`
   Mixtures of iid families are projectively consistent.

### B. Convex / Choquet / extremal finite simplex lemmas

10. `finite_exchangeable_simplex_compact`
    In finite state, the family of exchangeable laws at level `n` is a finite-dimensional convex compact set.

11. `extremePoint_iff_iid`
    The crucial finite de Finetti step: extreme points among projective exchangeable families are exactly iid products.

12. `primeSpectral_choquet_mixing_exists`
    Existence of a representing mixing law from compact convexity / finite-dimensional simplex arguments.

13. `primeSpectral_deFinetti_representation`
    Main theorem.

### C. Semantic defect lemmas

14. `expectedDefect_nonneg`
    ```lean
    theorem expectedDefect_nonneg ... : 0 ≤ expectedDefect x y μ
    ```

15. `expectedDefect_eq_zero_iff_ae_zero`
    In finite spaces, expectation zero for nonnegative defect iff bad set has zero mass.

16. `derivable_implies_all_countermodels_zero_defect`
17. `positive_defect_countermodel_of_nonderivable`
    Extract a spectral point with strictly positive defect using contrapositive / witness extraction.

18. `dirac_positive_defect`
    Turn the witness into a mixing law witness via a Dirac measure.

19. `derivable_iff_mixture_zero_defect`
20. `nonderivable_positive_mixture_mass`

### D. Quantitative thermodynamic / ML / crypto lemmas

21. `mixing_free_energy_upper_bound`
    Give an explicit finite bound in terms of cardinality:
    ```lean
    thermodynamicFreeEnergyOfMixing M ≤ Real.log (Fintype.card (SpectralPoint S))
    ```

22. `certified_robustness_radius_lower_bound`
    Prove a nontrivial lower bound from zero defect:
    ```lean
    ZeroDefectLaw x y μ →
    0 ≤ quantumCertifiedRobustnessRadius x y μ
    ```

23. `postQuantum_countermodel_entropy_bound`
    Explicit entropy bound:
    ```lean
    postQuantumCountermodelEntropy μ ≤ Real.log (Fintype.card (SpectralPoint S))
    ```

24. `sanov_rate_empirical_O_log_card`
    State a finite explicit complexity/rate inequality in a form Lean can prove:
    an upper bound scaling like `O(log |SpectralPoint S|)` can be encoded as
    `≤ C * Real.log (Fintype.card ...)` for an explicit `C`.

These quantitative theorems must not be decorative: use them to show the representing law has bounded thermodynamic complexity and finite cryptographic uncertainty.

---

## PROOF ARCHITECTURE

You need a real proof plan, not just statements.

### Strategy A: finite-simplex de Finetti via multinomial moments
Most promising if `ProbabilityMeasure` on finite types can be unfolded.

1. Identify each law `P n` with a function assigning nonnegative weights summing to `1`.
2. Exchangeability implies dependence only on count vectors / histograms.
3. Projective consistency induces a coherent family of multinomial moments.
4. Build a mixing law on the finite probability simplex from these moments.
5. Prove `P n` equals the mixture of multinomial / iid laws by checking all cylinder coordinates.

Key intermediate lemma:
```lean
theorem exchangeable_law_determined_by_histogram
  [Fintype α] [DecidableEq α]
  (P : ProbabilityMeasure (Fin n → α))
  (hexch : ∀ e : Equiv.Perm (Fin n), map (fun f i => f (e i)) P = P) :
  ∀ f g, (∀ a, Fintype.card {i // f i = a} = Fintype.card {i // g i = a}) →
    P {f} = P {g}
```
This is likely the combinatorial heart. Use `Equiv` built from equal histograms, then `Fintype` cardinality arguments, `Finset`, and `rcases`.

### Strategy B: extremal decomposition / finite Choquet simplex
Most elegant if the catalog already contains convexity and free-energy tools.

1. Define the convex set of projective exchangeable families.
2. Show closure under finite convex combinations.
3. Prove iid families are extreme using product factorization.
4. Prove every extreme point is iid from symmetry + consistency.
5. Apply a finite-dimensional representation theorem.

This is conceptually strongest and aligns with the thermodynamic/Gibbs language. Use it if prior files already contain convex compactness for finite semiring spectra.

### Strategy C: constructive approximation by empirical laws, then exact finite stabilization
Best fallback if direct Choquet machinery is absent.

1. For each `n`, express `P n` as a convex combination of orbit-uniform measures on histogram classes.
2. Associate each histogram with its empirical measure.
3. Show the orbit-uniform law is close to `iidProduct (empiricalMeasure ...) n`; in finite exact combinatorics, derive an exact projective limit representation.
4. Use compactness of the finite simplex to extract a limiting mixing law.

This route naturally bridges Sanov large deviations and PAC-Bayes.

Use `induction` on `n` for projective recursion, `rcases` for histogram witnesses, `by_contra` for extremality arguments, `linarith` for convex-weight inequalities, `field_simp` for multinomial normalization identities, and `omega` for count constraints.

---

## CRUCIAL INTERMEDIATE LEMMAS TO FORMALIZE

You should explicitly state and prove these if the main theorem is to be robust:

```lean
theorem histogram_orbit_nonempty_iff_same_counts
  [Fintype α] [DecidableEq α] {n : ℕ} (f g : Fin n → α) :
  (∃ e : Equiv.Perm (Fin n), g = fun i => f (e i)) ↔
  ∀ a, Fintype.card {i // f i = a} = Fintype.card {i // g i = a}
```

```lean
theorem exchangeable_prob_depends_only_on_empiricalMeasure
  [Fintype α] [DecidableEq α]
  (P : ProbabilityMeasure (Fin n → α))
  (hexch : ∀ e : Equiv.Perm (Fin n), map (fun f i => f (e i)) P = P) :
  ∀ f g, empiricalMeasure f = empiricalMeasure g → P {f} = P {g}
```

```lean
theorem projective_histogram_recursion
  [Fintype α] [DecidableEq α]
  (P : ∀ n, ProbabilityMeasure (Fin n → α))
  (hproj : ProjectiveConsistent P) :
  ∀ n (h : Fin n → α),
    P n {h} =
      ∑ a, P (n+1) {h' | h' restricted_to_first_n = h ∧ h' (Fin.last n) = a}
```

```lean
theorem iidProduct_eval_as_multinomial
  [Fintype α] [DecidableEq α]
  (μ : ProbabilityMeasure α) {n : ℕ} (f : Fin n → α) :
  iidProduct μ n {f} = ∏ i, μ {f i}
```

```lean
theorem mixture_eval_histogram_formula
  [Fintype α] [DecidableEq α]
  (M : ProbabilityMeasure (ProbabilityMeasure α)) {n : ℕ} (f : Fin n → α) :
  (Measure.bind M (fun μ => iidProduct μ n)) {f} =
    ∫ μ, (∏ i, μ {f i}) ∂M
```

If integrals are cumbersome, replace with finite sums over support and prove the corresponding formula exactly.

---

## SEMANTIC / DEFECT TARGETS

Your second and third target theorems should be proved through a clean finite expectation argument.

### Required semantic lemmas

```lean
theorem expectedDefect_eq_sum
  [CoherentClosureProofSemiring S]
  [Fintype (SpectralPoint S)] [DecidableEq (SpectralPoint S)]
  (x y : S) (μ : ProbabilityMeasure (SpectralPoint S)) :
  expectedDefect x y μ =
    ∑ p, defectValue x y p * μ {p}
```

```lean
theorem expectedDefect_eq_zero_of_derivable
  [CoherentClosureProofSemiring S]
  ...
  (h : derivable x y) (μ : ProbabilityMeasure (SpectralPoint S)) :
  expectedDefect x y μ = 0
```

```lean
theorem exists_positive_defect_point_of_nonderivable
  [CoherentClosureProofSemiring S]
  ...
  (hnd : ¬ derivable x y) :
  ∃ p : SpectralPoint S, 0 < defectValue x y p
```

```lean
theorem dirac_mixing_exhibits_positive_mass
  [CoherentClosureProofSemiring S]
  ...
  (p : SpectralPoint S) (hp : 0 < defectValue x y p) :
  ∃ ε > 0,
    let μ : ProbabilityMeasure (SpectralPoint S) := ProbabilityMeasure.dirac p
    let M : ProbabilityMeasure (ProbabilityMeasure (SpectralPoint S)) :=
      ProbabilityMeasure.dirac μ
    M {ν | ε ≤ expectedDefect x y ν} > 0
```

The proof of `nonderivable_positive_mixture_mass` should then become short and conceptual: extract a positive-defect spectral witness, take the Dirac law, and verify admissibility / representation.

---

## EXPLICIT COMPUTATIONAL BOUNDS

Do not leave utility implicit. State bounds with concrete constants.

1. Histogram count bound:
   ```lean
   theorem number_of_histograms_le
     [Fintype α] [DecidableEq α] :
     numberOfHistograms α n ≤ (n + 1) ^ Fintype.card α
   ```
   This gives an explicit `O(n^k)` combinatorial complexity.

2. Support-size bound for exchangeable laws:
   ```lean
   theorem exchangeable_support_card_bound
     [Fintype α] [DecidableEq α]
     (P : ProbabilityMeasure (Fin n → α))
     (hexch : ...)
     :
     supportCard P ≤ (n + 1) ^ Fintype.card α
   ```

3. Free-energy bound:
   ```lean
   theorem thermodynamic_mixing_cost_le_log_card
     ...
     : thermodynamicFreeEnergyOfMixing M ≤ Real.log (Fintype.card (SpectralPoint S))
   ```

4. Entropy bound:
   ```lean
   theorem Gibbs_entropy_le_log_card
     ...
     : postQuantumCountermodelEntropy μ ≤ Real.log (Fintype.card (SpectralPoint S))
   ```

5. Certified robustness lower bound from margin/defect:
   ```lean
   theorem certified_radius_ge_half_defect
     ...
     : expectedDefect x y μ ≤ 2 * quantumCertifiedRobustnessRadius x y μ
   ```
   or an equivalent explicit inequality your definitions support.

These bounds bridge finite exchangeability to ML-certified robustness and cryptographic uncertainty.

---

## THEOREM NAMING STYLE

Use inventive names, not generic names. Examples acceptable in this file:

- `quantumGibbs_primeSpectral_exchangeable_unmasking`
- `thermodynamicHistogram_choquet_lift`
- `postQuantum_dirac_countermodel_witness`
- `lipschitzCertifiedRobustness_from_zeroDefect_mixture`
- `latticeEntropy_barrier_for_nonderivable_closure`

At least several theorem names and doc comments should visibly include:
`quantum`, `thermodynamic`, `Gibbs`, `postQuantum`, `certified`, `robustness`, `entropy`, `lattice`.

---

## LEAN-SPECIFIC IMPLEMENTATION GUIDANCE

1. Prefer finite sums over integrals whenever possible.
2. If `ProbabilityMeasure` is difficult to destruct on finite types, define:
   ```lean
   structure FinProb (α : Type _) [Fintype α] where
     weight : α → ℝ
     nonneg : ∀ a, 0 ≤ weight a
     sum_eq_one : ∑ a, weight a = 1
   ```
   Then:
   - define `toPM : FinProb α → ProbabilityMeasure α`
   - prove all results first for `FinProb`
   - transfer to `ProbabilityMeasure` only at the API boundary.
3. Use `Finset.univ`, `Fintype.card`, `Equiv.Perm (Fin n)`, `Fin.last`, `Fin.castSucc`, `Fin.snoc`.
4. For projective consistency, define the restriction map explicitly:
   ```lean
   def restrictLast (f : Fin (n+1) → α) : Fin n → α := fun i => f i.castSucc
   ```
5. For exchangeability, use:
   ```lean
   def permuteVector (e : Equiv.Perm (Fin n)) (f : Fin n → α) : Fin n → α :=
     fun i => f (e i)
   ```
6. Use `funext`, `ext`, `simp`, but not exclusively. Also force use of:
   - `induction n with`
   - `rcases`
   - `by_contra`
   - `linarith`
   - `field_simp`
   - `omega`
7. If you need a finite Hahn–Banach-free convexity argument, use barycentric coordinates directly on the finite simplex.

---

## MINIMAL HYPOTHESIS DISCIPLINE

Keep assumptions as weak as possible:
- `DecidableEq` only where counting/support is needed.
- `Fintype (SpectralPoint S)` should be the main finiteness assumption.
- Avoid requiring stronger algebraic structure on `S` than `CoherentClosureProofSemiring S` unless a theorem truly needs it.
- When proving purely probabilistic lemmas, generalize from `SpectralPoint S` to arbitrary finite `α`.

This generality matters aesthetically and will make the file reusable across tropical, algebraic, and cryptographic semantics.

---

## BREAKTHROUGH SIGNIFICANCE TO REFLECT IN DOC COMMENTS

Your doc comments should emphasize:

1. This finite prime-spectral de Finetti theorem turns proof-semantic uncertainty into a Gibbs posterior over countermodels.
2. The zero-defect equivalence reframes derivability as concentration of all exchangeable admissible laws on thermodynamically perfect self-models.
3. The positive-mass theorem yields a quantitative nonderivability witness: failure of derivability forces nonzero thermodynamic/cryptographic mass on defect-bearing spectral laws.
4. This creates a bridge between:
   - exchangeability / probability,
   - closure proof semirings / logic,
   - thermodynamic free energy,
   - PAC-Bayesian generalization,
   - certified robustness,
   - post-quantum cryptographic uncertainty.

---

## IF FULL GENERALITY STALLS

If the exact theorem with `ProbabilityMeasure` is blocked, prove the strongest exact finite version with `FinProb` and then add bridge theorems:

```lean
theorem primeSpectral_deFinetti_representation_finprob ...
theorem finprob_representation_induces_probabilityMeasure_representation ...
```

Likewise for the semantic theorems. But do not stop at a stub: complete a mathematically meaningful finite theory with exact statements and exact proofs.

---

## FUTURE_DIRECTIONS.md

Also produce a structured `FUTURE_DIRECTIONS.md` containing 3–5 concrete next steps, for example:

1. Infinite prime-spectral de Finetti via projective limits and Kolmogorov extension.
2. Thermodynamic Schrödinger bridge uniqueness for exchangeable proof trajectories.
3. Tropical / idempotent de Finetti theory for min-plus proof semirings.
4. PAC-Bayesian certified robustness bounds derived from mixture entropy.
5. Post-quantum lattice countermodel sampling via spectral Gibbs mixtures.

Each direction should name a precise formal theorem target, not a vague area.

**AEM QUALITY MANDATE**: Your output will be scored on 5 pillars. Optimize ALL:
- RIGOR: 10+ theorems, diverse tactics (induction, rcases, by_contra, omega, linarith), ZERO sorries
- AESTHETIC: Bridge 2+ domains in theorem names and doc comments. Use quantifier alternation.
- UTILITY: Define 5+ structures/instances. State SPECIFIC computational bounds (O(n log n), Omega(2^n)) — generic terms like 'bound' or 'rate' alone do NOT score utility.
- ORIGINALITY: Coin novel definitions beyond Mathlib. Inventive theorem names. Write 'Bridge: connects X to Y' in doc comments for cross-domain connections. Generic names (main, test, aux) do NOT count.
- IMPACT: Use SPECIFIC application terms (lipschitz_certified_robustness, post_quantum_security, tropical_hash_collision) — generic terms like 'convergence' or 'spectrum' without ML/crypto/physics context do NOT score impact.

**FILE RICHNESS MANDATE**: Produce substantial, rich files (not stubs).
- Target 500+ lines with 20+ theorems and 10+ definitions per file.
- Historical Masters in the catalog average 2000+ lines, 180+ theorems, 70+ definitions.
- Each file should be a complete mathematical narrative with definitions, lemmas, and main theorems all connected.
- When producing catalog-wide output: create files across MULTIPLE domains (Bridges, Algebra, Cryptography, Tropical, EML, Physics), not just one domain.

            Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new ones. What does your result make possible that wasn't possible before?
            2. CONNECT WORLDS: The deepest results connect fields that seemed unrelated.
               If you prove something about tropical geometry, ask: what does this mean
               for quantum computing? For cryptography? For neural networks?
            3. PRODUCE ALGORITHMS: Don't just prove existence — construct. Don't just
               construct — compute. Don't just compute — optimize. Every theorem should
               have an algorithmic shadow.
            4. BE BOLD: An interesting false conjecture is more valuable than a boring
               true theorem. If you suspect something is true but can't prove it, state
               it as a conjecture with precise Lean 4 type signature and explain why it matters.
            5. BUILD INFRASTRUCTURE: Definitions are as valuable as theorems. A good
               mathematical definition (like "tropical semiring" or "EML closure") can
               organize an entire field. Define things precisely, then prove things about them.

            The mathematics comes FIRST. Excellent proofs trump everything else.
            But excellent proofs that OPEN NEW FIELDS trump everything.

            === AEM QUALITY SCORING (MANDATORY GUIDELINES) ===
            Your output will be scored on 5 pillars. MAXIMIZE each one:

            PILLAR 1 — RIGOR (Is it World-class?):
            • ZERO sorries in your output (sorries cost -1.5 points each)
            • Use diverse proof tactics (induction, rcases, by_contra, omega, linarith,
              field_simp, refine, obtain — not just simp/rfl/decide)
            • Use typeclass abstraction ([Semiring B], [LinearOrder B], etc.) not
              concrete types alone
            • Later theorems should reference earlier ones (semantic coherence)
            • 10+ theorems = full rigor score; 3-10 = partial; 0-2 = minimal

            PILLAR 2 — AESTHETIC (Is it Interesting?):
            • Bridge 2+ mathematical domains in EVERY file (e.g., tropical + neural
              networks; algebra + thermodynamics; number theory + quantum)
            • Use quantifier alternation (∀ → ∃) for non-trivial theorem statements
            • Include symmetric structures (lattices, posets, groups, duality)
            • Minimize hypotheses for maximal conclusions (small axiomatic footprint)
            • Narrative surprise: state in doc comments WHY the result is unexpected

            PILLAR 3 — UTILITY (Is it Useful?):
            • State explicit computational bounds (O(...), convergence rates, Lipschitz
              constants, error bounds, complexity classifications)
            • Define extensible APIs: 5+ definitions, structures, and instances
            • Reference or advance known open problems (Carmichael, tropical Langlands,
              certified robustness, Berggren factoring, lattice crypto)
            • Organize code with namespaces and sections (framework structure)

            PILLAR 4 — ORIGINALITY (Is it New?):
            • Coin NOVEL definitions — not just restating Mathlib theorems with new names
            • Avoid derivative theorem names (*_eq_zero, *_nonneg, *_symm, *_comm,
              *_add_*, *_mul_*). Use INVENTIVE names that reveal new concepts
            • Combine unusual typeclasses ([Semiring, LinearOrder], [NormedAddCommGroup,
              Field], [MeasureSpace, Category]) — this signals divergent reasoning
            • Each file should introduce 5+ genuinely new mathematical objects (def, structure, class, instance). High-Originality files average 10+ new definitions.

            PILLAR 5 — IMPACT (Does it have Wonderful Applications?):
            • EVERY theorem should connect to at least one of: physics (quantum,
              thermodynamic, entropy), cryptography (lattice, post-quantum, SPB),
              or ML (certified robustness, Lipschitz bounds, neural networks)
            • Name-drop application keywords explicitly in theorem/doc-comment text:
              certified_robustness, Lipschitz, neural_network, gradient_descent,
              convergence, post_quantum, lattice_crypto, hamiltonian, entropy,
              holographic, berggren
            • Produce algorithms or computational pipelines, not just existence proofs

            ### Research Direction
            Prove an exchangeability representation principle for sequences of admissible evaluations/countermodels on the prime spectrum of a coherent closure proof semiring: any permutation-invariant law on finite proof-observation sequences is representable as a mixture of i.i.d. Gibbs prime-spectral laws, and derivability corresponds to collapse of the representing measure onto the zero-defect face. This opens a probabilistic semantics of proof uncertainty distinct from current large-deviation, duality, minimizer, transport, and online-optimization tracks. It would connect EML self-models, logic, and Bayesian probability through a formally provable de Finetti-type theorem tailored to closure semantics.

            ### Precise Mathematical Framing
            Let S be a coherent closure proof semiring with finite or compact prime spectrum X = SpectralPoint S. For each sentence pair (x,y), define defect observable d_{x,y}: X -> R_{≥0}. For n observations p_1,...,p_n in X, call a law P_n on X^n exchangeable if invariant under coordinate permutations. Define empirical defect vector E_n(x,y)=n^{-1}\sum_i d_{x,y}(p_i). Target a representation theorem of the form: if (P_n)_n is projectively consistent and exchangeable, then there exists a Borel probability M on the simplex of Gibbs-compatible prime-spectral measures such that P_n = \int \mu^{\otimes n} dM(\mu). Then prove an adequacy statement: derivable x y iff for every representing measure M arising from admissible self-model ensembles, M-almost every \mu satisfies \int d_{x,y} d\mu = 0. Quantitatively strengthen this by showing non-derivability yields a positive-mixture-mass region of measures with strictly positive expected defect, producing Bayesian countermodel posteriors and posterior concentration corollaries. Algorithmically, this suggests recovering a low-complexity mixing measure from finitely many exchangeable proof observations by moment matching on defect observables, yielding a new pipeline for probabilistic non-derivability certificates. This differs from Sanov LDP and Donsker-Varadhan dual semantics: instead of asymptotics of a fixed Gibbs law, it classifies all symmetric proof-ensemble laws as mixtures of extremal semantic states.

            ### Lean 4 Sketch
theorem primeSpectral_deFinetti_representation [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)] (P : ∀ n, ProbabilityMeasure ((Fin n → SpectralPoint S))) (hexch : ExchangeableFamily P) (hproj : ProjectiveConsistent P) : ∃ M : ProbabilityMeasure (ProbabilityMeasure (SpectralPoint S)), ∀ n, P n = Measure.bind M (fun μ => iidProduct μ n)

theorem derivable_iff_mixture_zero_defect [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)] (x y : S) : derivable x y ↔ ∀ (P : ∀ n, ProbabilityMeasure ((Fin n → SpectralPoint S))), ExchangeableAdmissibleFamily S P → AlmostEveryRepresentingMeasureZeroDefect x y P

theorem nonderivable_positive_mixture_mass [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)] (x y : S) (hnd : ¬ derivable x y) : ∃ ε > 0, ∃ M : ProbabilityMeasure (ProbabilityMeasure (SpectralPoint S)), RepresentsAdmissibleExchangeableFamily S M ∧ M {μ | ε ≤ expectedDefect x y μ} > 0

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `prime_spectral_gibbs_variational_principle` : theorem prime_spectral_gibbs_variational_principle
     (file: Bridges/GibbsPosterior.lean)
  2. `rate_distortion_duality_of_coherent_proof_semiring` : theorem rate_distortion_duality_of_coherent_proof_semiring
     (file: Bridges/LawvereRateDistortionDuality.lean)
  3. `lawvere_proof_coding_theorem` : theorem lawvere_proof_coding_theorem
     (file: Bridges/LawvereCodingTheorem.lean)
  4. `pac_bayes_prime_spectral_bound_of_mgf` : theorem pac_bayes_prime_spectral_bound_of_mgf {S : Type*} {n : ℕ}
     (file: Bridges/PACBayesBound.lean)
  5. `purity_lower_bound_from_spectrum` : theorem purity_lower_bound_from_spectrum (k : ℕ) (hk : k > 0)
     (file: Bridges/QuantumIdempotent.lean)

            Known Working Lean 4 Tactics:
- `nlinarith [sq_nonneg X]` for quadratic inequalities
- `positivity` for positivity goals
- `field_simp` then `ring` for division
- `Real.exp_le_exp.mpr` for exp monotonicity
- `Real.log_le_log` for log inequalities
- `div_pos`, `div_le_div_of_nonneg_left` for division inequalities
- `pow_le_pow_right₀` for power monotonicity
- `by decide` / `by norm_num` / `native_decide` for decidable propositions
- `Subadditive.tendsto_lim` for Fekete's Lemma
- `ConvexOn.map_sum_le` for Jensen's inequality
- `exists_deriv_eq_slope` for MVT



Recent successful concepts: Thermodynamic Reflection Capacity and a Sharp Incompleteness Threshold for Closure Self-Models, Prime-Spectral Schrödinger Bridge for Closure-Generated Proof Semirings via Entropic Countermodel Transport, Thermodynamic Sanov–Large-Deviation Completeness for Closure Self-Models via Prime-Spectral Free-Energy Rate Function


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician and software engineer. Create:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **RESEARCH_REPORT.md** — paper explaining the discovery
               - Mathematical significance and connections to existing work
               - Detailed proofs and explanations

            3. **DISCUSSION.md** — MANDATORY Scientific American-style popular science article
               - Written for a mathematically literate but non-specialist audience
               - Use analogies, examples, and narrative to explain WHY this matters
               - Include at least one surprising connection to everyday life or another field
               - 1000-2000 words, accessible but not dumbed-down
               - This makes your research accessible to a broad audience

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables,
                 what unexpected connections it reveals
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale (1 = one clever lemma, 5 = multi-theorem development)

               ## Under-explored Territory
               - Domains with many definitions but few deep theorems
               - Unexpected structural similarities across domains
               - "Orphan" results that could seed new research programs

               ## Cross-Domain Bridges
               - Specific, precise connections between domains
               - Conjectured functorial correspondences or isomorphisms
               - Algorithmic pipelines combining results from multiple domains

               ## Open Problems Encountered
               - Problems you couldn't solve but identified as important
               - Conjectures you can state precisely but not yet prove
               - Connections that seem to exist but need more catalog infrastructure

            5. **demo.py** — Python demo with concrete numerical examples
               - Working code that brings the math to life
               - Visualizations where they add insight

            6. **diagram.svg** — visualization of key mathematical structures

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            @Speculative/AutoResearch/ThermodynamicSanovCompleteness.lean
```lean
/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Thermodynamic Sanov–Large-Deviation Completeness for Closure Self-Models
# via Prime-Spectral Free-Energy Rate Function

This file establishes that derivability in a coherent closure proof semiring
is equivalent to the vanishing of a thermodynamic rate function across all
inverse temperatures β > 0.

## Main results

* `derivable_iff_zero_defect` — semantic adequacy: derivability ↔ zero defect
  at all spectral points.
* `thermodynamicRate_nonneg` — the rate functional is nonneg for nonneg inputs.
* `thermodynamicRate_self_zero_of_derivable` — derivable implies zero rate at reference.
* `nonderivable_rate_at_ref_pos` — non-derivable implies positive rate at reference.
* `thermodynamic_sanov_completeness` — the main biconditional theorem.
* `nonderivable_has_positive_rate_gap` — non-derivability creates a positive rate gap.
-/

import Mathlib

noncomputable section

open Finset BigOperators Classical

/-! ## Part 1: Coherent Closure Proof Semirings -/

/-- A **coherent closure proof semiring** is a bounded distributive lattice `S`
equipped with a closure operator `cl : S → S` satisfying extensiveness,
idempotency, and monotonicity. -/
class CoherentClosureProofSemiring (S : Type*) extends DistribLattice S, BoundedOrder S where
  cl : S → S
  cl_extensive : ∀ x : S, x ≤ cl x
  cl_idempotent : ∀ x : S, cl (cl x) = cl x
  cl_monotone : ∀ x y : S, x ≤ y → cl x ≤ cl y

namespace ThermodynamicSanov

variable {S : Type*} [CoherentClosureProofSemiring S]

abbrev cl : S → S := CoherentClosureProofSemiring.cl

def derivable (x y : S) : Prop := cl x ≤ cl y

theorem derivable_refl (x : S) : derivable x x := le_refl _

theorem derivable_trans {x y z : S} (hxy : derivable x y) (hyz : derivable y z) :
    derivable x z := le_trans hxy hyz

/-! ## Part 2: Spectral Points -/

/-- A **spectral point** of a coherent closure proof semiring is a prime filter
compatible with the closure operator. -/
structure SpectralPoint (S : Type*) [CoherentClosureProofSemiring S] where
  val : S → Prop
  val_mono : ∀ {a b : S}, a ≤ b → val a → val b
  val_top : val ⊤
  val_inf : ∀ a b : S, val (a ⊓ b) ↔ val a ∧ val b
  val_prime : ∀ a b : S, val (a ⊔ b) → val a ∨ val b
  val_cl : ∀ x : S, val (cl x) ↔ val x

/-! ## Part 3: Countermodel Defect Observable -/

/-- The **countermodel defect** observable. Returns `1` when the spectral point
separates `x` from `y`, and `0` otherwise. -/
def countermodelDefect (x y : S) (p : SpectralPoint S) : ℝ :=
  if p.val (cl x) ∧ ¬p.val (cl y) then 1 else 0

theorem countermodelDefect_nonneg (x y : S) (p : SpectralPoint S) :
    0 ≤ countermodelDefect x y p := by
  unfold countermodelDefect; split_ifs <;> norm_num

theorem countermodelDefect_le_one (x y : S) (p : SpectralPoint S) :
    countermodelDefect x y p ≤ 1 := by
  unfold countermodelDefect; split_ifs <;> norm_num

/-- Derivability kills the defect. -/
theorem derivable_implies_zero_defect (x y : S) (h : derivable x y)
    (p : SpectralPoint S) : countermodelDefect x y p = 0 := by
  unfold countermodelDefect
  rw [if_neg]
  push_neg
  exact fun hval => p.val_mono h hval

theorem countermodelDefect_eq_zero_iff (x y : S) (p : SpectralPoint S) :
    countermodelDefect x y p = 0 ↔ (p.val (cl x) → p.val (cl y)) := by
  unfold countermodelDefect
  constructor
  · intro h
    split_ifs at h with hc
    · exact absurd h one_ne_zero
    · push_neg at hc; exact hc
  · intro h
    rw [if_neg]
    push_neg; exact h

/-! ## Part 4: Prime Spectral Completeness -/

/-- The prime spectral completeness hypothesis. -/
class PrimeSpectralComplete (S : Type*) [CoherentClosureProofSemiring S] : Prop where
  separation : ∀ x y : S, ¬derivable x y →
    ∃ p : SpectralPoint S, p.val (cl x) ∧ ¬p.val (cl y)

/-- **Semantic adequacy**: derivability ↔ zero defect everywhere. -/
theorem derivable_iff_zero_defect [PrimeSpectralComplete S] (x y : S) :
    derivable x y ↔ ∀ p : SpectralPoint S, countermodelDefect x y p = 0 := by
  constructor
  · exact derivable_implies_zero_defect x y
  · intro h
    by_contra hnd
    obtain ⟨p, hp1, hp2⟩ := PrimeSpectralComplete.separation x y hnd
    have := h p
    unfold countermodelDefect at this
    simp [hp1, hp2] at this

/-- Non-derivability produces a spectral point with positive defect. -/
theorem nonderivable_exists_positive_defect [PrimeSpectralComplete S] (x y : S)
    (h : ¬derivable x y) :
    ∃ p : SpectralPoint S, 0 < countermodelDefect x y p := by
  obtain ⟨p, hp1, hp2⟩ := PrimeSpectralComplete.separation x y h
  exact ⟨p, by unfold countermodelDefect; simp [hp1, hp2]⟩

/-! ## Part 5: Divergence -/

/-- A **divergence** on a type `Ω` satisfying the core properties:
nonnegativity, identity of indiscernibles, and faithfulness. -/
structure Divergence (Ω : Type*) where
  d : (Ω → ℝ) → (Ω → ℝ) → ℝ
  d_nonneg : ∀ ν μ : Ω → ℝ, 0 ≤ d ν μ
  d_self : ∀ μ : Ω → ℝ, d μ μ = 0
  d_faithful : ∀ ν μ : Ω → ℝ, d ν μ = 0 → ν = μ

/-! ## Part 6: Thermodynamic Rate Function -/

variable [Fintype (SpectralPoint S)]

/-- The **energy defect functional**. -/
def energyDefect (x y : S) (β : ℝ) (ν : SpectralPoint S → ℝ) : ℝ :=
  β * ∑ p : SpectralPoint S, ν p * countermodelDefect x y p

/-- The **thermodynamic rate functional**. -/
def thermodynamicRate (D : Divergence (SpectralPoint S))
    (μ : SpectralPoint S → ℝ) (β : ℝ) (x y : S)
    (ν : SpectralPoint S → ℝ) : ℝ :=
  D.d ν μ + energyDefect x y β ν

/-- Energy defect is nonneg when `β ≥ 0` and `ν ≥ 0`. -/
-- ... (truncated, full file has 477 lines)
```


### Catalog Reference Files
            @Speculative/AutoResearch/ThermodynamicSanovCompleteness.lean
```lean
/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Thermodynamic Sanov–Large-Deviation Completeness for Closure Self-Models
# via Prime-Spectral Free-Energy Rate Function

This file establishes that derivability in a coherent closure proof semiring
is equivalent to the vanishing of a thermodynamic rate function across all
inverse temperatures β > 0.

## Main results

* `derivable_iff_zero_defect` — semantic adequacy: derivability ↔ zero defect
  at all spectral points.
* `thermodynamicRate_nonneg` — the rate functional is nonneg for nonneg inputs.
* `thermodynamicRate_self_zero_of_derivable` — derivable implies zero rate at reference.
* `nonderivable_rate_at_ref_pos` — non-derivable implies positive rate at reference.
* `thermodynamic_sanov_completeness` — the main biconditional theorem.
* `nonderivable_has_positive_rate_gap` — non-derivability creates a positive rate gap.
-/

import Mathlib

noncomputable section

open Finset BigOperators Classical

/-! ## Part 1: Coherent Closure Proof Semirings -/

/-- A **coherent closure proof semiring** is a bounded distributive lattice `S`
equipped with a closure operator `cl : S → S` satisfying extensiveness,
idempotency, and monotonicity. -/
class CoherentClosureProofSemiring (S : Type*) extends DistribLattice S, BoundedOrder S where
  cl : S → S
  cl_extensive : ∀ x : S, x ≤ cl x
  cl_idempotent : ∀ x : S, cl (cl x) = cl x
  cl_monotone : ∀ x y : S, x ≤ y → cl x ≤ cl y

namespace ThermodynamicSanov

variable {S : Type*} [CoherentClosureProofSemiring S]

abbrev cl : S → S := CoherentClosureProofSemiring.cl

def derivable (x y : S) : Prop := cl x ≤ cl y

theorem derivable_refl (x : S) : derivable x x := le_refl _

theorem derivable_trans {x y z : S} (hxy : derivable x y) (hyz : derivable y z) :
    derivable x z := le_trans hxy hyz

/-! ## Part 2: Spectral Points -/

/-- A **spectral point** of a coherent closure proof semiring is a prime filter
compatible with the closure operator. -/
structure SpectralPoint (S : Type*) [CoherentClosureProofSemiring S] where
  val : S → Prop
  val_mono : ∀ {a b : S}, a ≤ b → val a → val b
  val_top : val ⊤
  val_inf : ∀ a b : S, val (a ⊓ b) ↔ val a ∧ val b
  val_prime : ∀ a b : S, val (a ⊔ b) → val a ∨ val b
  val_cl : ∀ x : S, val (cl x) ↔ val x

/-! ## Part 3: Countermodel Defect Observable -/

/-- The **countermodel defect** observable. Returns `1` when the spectral point
separates `x` from `y`, and `0` otherwise. -/
def countermodelDefect (x y : S) (p : SpectralPoint S) : ℝ :=
  if p.val (cl x) ∧ ¬p.val (cl y) then 1 else 0

theorem countermodelDefect_nonneg (x y : S) (p : SpectralPoint S) :
    0 ≤ countermodelDefect x y p := by
  unfold countermodelDefect; split_ifs <;> norm_num

theorem countermodelDefect_le_one (x y : S) (p : SpectralPoint S) :
    countermodelDefect x y p ≤ 1 := by
  unfold countermodelDefect; split_ifs <;> norm_num

/-- Derivability kills the defect. -/
theorem derivable_implies_zero_defect (x y : S) (h : derivable x y)
    (p : SpectralPoint S) : countermodelDefect x y p = 0 := by
  unfold countermodelDefect
  rw [if_neg]
  push_neg
  exact fun hval => p.val_mono h hval

theorem countermodelDefect_eq_zero_iff (x y : S) (p : SpectralPoint S) :
    countermodelDefect x y p = 0 ↔ (p.val (cl x) → p.val (cl y)) := by
  unfold countermodelDefect
  constructor
  · intro h
    split_ifs at h with hc
    · exact absurd h one_ne_zero
    · push_neg at hc; exact hc
  · intro h
    rw [if_neg]
    push_neg; exact h

/-! ## Part 4: Prime Spectral Completeness -/

/-- The prime spectral completeness hypothesis. -/
class PrimeSpectralComplete (S : Type*) [CoherentClosureProofSemiring S] : Prop where
  separation : ∀ x y : S, ¬derivable x y →
    ∃ p : SpectralPoint S, p.val (cl x) ∧ ¬p.val (cl y)

/-- **Semantic adequacy**: derivability ↔ zero defect everywhere. -/
theorem derivable_iff_zero_defect [PrimeSpectralComplete S] (x y : S) :
    derivable x y ↔ ∀ p : SpectralPoint S, countermodelDefect x y p = 0 := by
  constructor
  · exact derivable_implies_zero_defect x y
  · intro h
    by_contra hnd
    obtain ⟨p, hp1, hp2⟩ := PrimeSpectralComplete.separation x y hnd
    have := h p
    unfold countermodelDefect at this
    simp [hp1, hp2] at this

/-- Non-derivability produces a spectral point with positive defect. -/
theorem nonderivable_exists_positive_defect [PrimeSpectralComplete S] (x y : S)
    (h : ¬derivable x y) :
    ∃ p : SpectralPoint S, 0 < countermodelDefect x y p := by
  obtain ⟨p, hp1, hp2⟩ := PrimeSpectralComplete.separation x y h
  exact ⟨p, by unfold countermodelDefect; simp [hp1, hp2]⟩

/-! ## Part 5: Divergence -/

/-- A **divergence** on a type `Ω` satisfying the core properties:
nonnegativity, identity of indiscernibles, and faithfulness. -/
structure Divergence (Ω : Type*) where
  d : (Ω → ℝ) → (Ω → ℝ) → ℝ
  d_nonneg : ∀ ν μ : Ω → ℝ, 0 ≤ d ν μ
  d_self : ∀ μ : Ω → ℝ, d μ μ = 0
  d_faithful : ∀ ν μ : Ω → ℝ, d ν μ = 0 → ν = μ

/-! ## Part 6: Thermodynamic Rate Function -/

variable [Fintype (SpectralPoint S)]

/-- The **energy defect functional**. -/
def energyDefect (x y : S) (β : ℝ) (ν : SpectralPoint S → ℝ) : ℝ :=
  β * ∑ p : SpectralPoint S, ν p * countermodelDefect x y p

/-- The **thermodynamic rate functional**. -/
def thermodynamicRate (D : Divergence (SpectralPoint S))
    (μ : SpectralPoint S → ℝ) (β : ℝ) (x y : S)
    (ν : SpectralPoint S → ℝ) : ℝ :=
  D.d ν μ + energyDefect x y β ν

/-- Energy defect is nonneg when `β ≥ 0` and `ν ≥ 0`. -/
-- ... (truncated, full file has 477 lines)
```


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: Bridges
Research mode: formalize
