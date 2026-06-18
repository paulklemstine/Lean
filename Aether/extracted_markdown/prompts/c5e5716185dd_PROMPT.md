

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

## YOUR ASSIGNMENT: Prime-Spectral Online Mirror Descent for Closure Proof Semirings via Gibbs Posterior Regret and Sequential Non-Derivability Certificates

Work in Lean 4 with `import Mathlib` and the existing prime-spectral / thermodynamic infrastructure already available in the environment. Strengthen the informal conjectures into a coherent formal development around normalized Gibbs updates, variational one-step inequalities, cumulative regret, and extraction of countermodel certificates from low average defect.

Use the following base declarations as the starting point, but do **not** leave the main objects as bare `Prop` conjectures: refine them into explicit definitions and theorem statements with usable hypotheses.

```lean
import Mathlib
import Speculative.AutoResearch.ThermodynamicSanovCompleteness

open scoped BigOperators

structure OnlineQuery (S : Type _) where
  lhs : S
  rhs : S

noncomputable def defectLoss
    [CoherentClosureProofSemiring S]
    (q : OnlineQuery S) (p : SpectralPoint S) : ℝ :=
  min 1 (countermodelDefect q.lhs q.rhs p)

noncomputable def gibbsUpdate
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    (μ : SpectralPoint S → ℝ) (η : ℝ) (q : OnlineQuery S) : SpectralPoint S → ℝ :=
  fun p => Real.exp (-η * defectLoss q p) * μ p
```

Your task is to replace the vague conjectural layer by a mathematically sharp formal theory centered on **normalized online Gibbs posteriors** and **prime-spectral regret certificates**.

---

## 1. Core formal objects to introduce

Define at least the following 10+ new objects/structures, with precise Lean signatures and useful simp lemmas:

```lean
/-- Nonnegative finite weight on spectral points. -/
def IsSpectralWeight
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    (μ : SpectralPoint S → ℝ) : Prop :=
  ∀ p, 0 ≤ μ p

/-- Total mass of a spectral weight. -/
noncomputable def spectralMass
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    (μ : SpectralPoint S → ℝ) : ℝ :=
  ∑ p, μ p

/-- Probability normalization predicate. -/
def IsSpectralDistribution
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    (μ : SpectralPoint S → ℝ) : Prop :=
  IsSpectralWeight μ ∧ spectralMass μ = 1

/-- Partition function for one Gibbs update. -/
noncomputable def gibbsPartition
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    (μ : SpectralPoint S → ℝ) (η : ℝ) (q : OnlineQuery S) : ℝ :=
  ∑ p, gibbsUpdate μ η q p

/-- Normalized Gibbs posterior. -/
noncomputable def normalizedGibbsUpdate
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    (μ : SpectralPoint S → ℝ) (η : ℝ) (q : OnlineQuery S) : SpectralPoint S → ℝ :=
  fun p => gibbsUpdate μ η q p / gibbsPartition μ η q

/-- Expected defect under a distribution. -/
noncomputable def expectedDefect
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    (μ : SpectralPoint S → ℝ) (q : OnlineQuery S) : ℝ :=
  ∑ p, μ p * defectLoss q p

/-- Cumulative defect along a query list at a spectral point. -/
noncomputable def cumulativePointDefect
    [CoherentClosureProofSemiring S]
    (qs : List (OnlineQuery S)) (p : SpectralPoint S) : ℝ :=
  (qs.map (fun q => defectLoss q p)).sum

/-- Recursive online posterior sequence. -/
noncomputable def onlinePosterior
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    (μ0 : SpectralPoint S → ℝ) (η : ℝ) : List (OnlineQuery S) → SpectralPoint S → ℝ
  | [] => μ0
  | q :: qs => normalizedGibbsUpdate (onlinePosterior μ0 η qs) η q

/-- Free energy of a weight against cumulative defect. -/
noncomputable def spectralFreeEnergy
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    (μ : SpectralPoint S → ℝ) (η : ℝ) (q : OnlineQuery S) : ℝ :=
  -(Real.log (gibbsPartition μ η q))

/-- Online regret against a comparator spectral point. -/
noncomputable def pointwiseOnlineRegret
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    (μ0 : SpectralPoint S → ℝ) (η : ℝ) (qs : List (OnlineQuery S)) (p⋆ : SpectralPoint S) : ℝ :=
  (qs.enum.map (fun ⟨t, q⟩ => expectedDefect (onlinePosterior μ0 η (qs.take t)) q)).sum
    - cumulativePointDefect qs p⋆

/-- Cesàro mean defect of a fixed pair x,y under the posterior sequence. -/
noncomputable def cesaroDefect
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    (μ0 : SpectralPoint S → ℝ) (η : ℝ) (x y : S) (n : ℕ) : ℝ :=
  ((Finset.range n).sum (fun t =>
    expectedDefect (onlinePosterior μ0 η []) ⟨x,y⟩)) / n

/-- Certificate that a spectral point witnesses persistent non-derivability. -/
def SequentialCountermodelCertificate
    [CoherentClosureProofSemiring S]
    (qs : List (OnlineQuery S)) (p : SpectralPoint S) (ε : ℝ) : Prop :=
  ∀ q ∈ qs, ε ≤ countermodelDefect q.lhs q.rhs p
```

You may refine `onlinePosterior` to recurse in the forward direction using an auxiliary `List.scanl`; if so, define both the recursive and scanned versions and prove them equivalent. Also define:

- `klSpectral` for finite KL divergence of two spectral distributions,
- `entropyProduction` or `thermodynamicDissipation`,
- `mirrorPotential`,
- `queryBatchDefect`,
- `lipschitzCertifiedRadius` or a similarly named ML-facing quantity based on defect averages.

Bridge: connects online learning, thermodynamic free energy, and proof-theoretic semantics.

---

## 2. Precise theorem layer to prove

You should prove a connected family of **at least 20 theorems**, with at least 10 nontrivial proofs using different tactics (`induction`, `rcases`, `by_contra`, `linarith`, `nlinarith`, `field_simp`, `omega`, `have`, `calc`, finite sum rearrangements). Theorems should include the following exact targets or stronger variants.

### A. Basic boundedness and positivity

```lean
theorem defectLoss_nonneg
    [CoherentClosureProofSemiring S]
    (q : OnlineQuery S) (p : SpectralPoint S) :
    0 ≤ defectLoss q p

theorem defectLoss_le_one
    [CoherentClosureProofSemiring S]
    (q : OnlineQuery S) (p : SpectralPoint S) :
    defectLoss q p ≤ 1

theorem gibbsUpdate_nonneg
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    {μ : SpectralPoint S → ℝ} (hμ : IsSpectralWeight μ)
    (η : ℝ) (q : OnlineQuery S) (p : SpectralPoint S) :
    0 ≤ gibbsUpdate μ η q p

theorem gibbsPartition_pos
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    [Nonempty (SpectralPoint S)]
    {μ : SpectralPoint S → ℝ}
    (hμ : IsSpectralDistribution μ) (η : ℝ) (q : OnlineQuery S) :
    0 < gibbsPartition μ η q
```

For `gibbsPartition_pos`, a robust path is:
1. use `hμ.2 : spectralMass μ = 1` to show some point has strictly positive mass,
2. obtain a positive term in the partition sum,
3. use positivity of `Real.exp`,
4. conclude strict positivity of the full finite sum.
If direct “there exists positive mass” is awkward, prove a lemma:
```lean
theorem exists_positive_weight_of_mass_one ...
```
by contradiction using finite sums and `linarith`.

### B. Normalization and probabilistic structure

```lean
theorem normalizedGibbsUpdate_isDistribution
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    [Nonempty (SpectralPoint S)]
    {μ : SpectralPoint S → ℝ}
    (hμ : IsSpectralDistribution μ) (η : ℝ) (q : OnlineQuery S) :
    IsSpectralDistribution (normalizedGibbsUpdate μ η q)

theorem expectedDefect_nonneg
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    {μ : SpectralPoint S → ℝ}
    (hμ : IsSpectralWeight μ) (q : OnlineQuery S) :
    0 ≤ expectedDefect μ q

theorem expectedDefect_le_mass
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    {μ : SpectralPoint S → ℝ}
    (hμ : IsSpectralWeight μ) (q : OnlineQuery S) :
    expectedDefect μ q ≤ spectralMass μ

theorem expectedDefect_le_one
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    {μ : SpectralPoint S → ℝ}
    (hμ : IsSpectralDistribution μ) (q : OnlineQuery S) :
    expectedDefect μ q ≤ 1
```

Here use `Finset.sum_le_sum`, the pointwise bound `defectLoss q p ≤ 1`, and `nlinarith`.

### C. Variational one-step inequalities (the formal heart)

Formalize a one-step mirror-descent inequality. A practical theorem, provable without importing the full Donsker–Varadhan machinery, is the log-partition sandwich:

```lean
theorem online_variational_step_lower
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    {μ : SpectralPoint S → ℝ}
    (hμ : IsSpectralDistribution μ) (η : ℝ) (q : OnlineQuery S) :
    -Real.log (gibbsPartition μ η q) ≤ η * expectedDefect μ q

theorem online_variational_step_upper
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    {μ : SpectralPoint S → ℝ}
    (hμ : IsSpectralDistribution μ) (hη : 0 ≤ η) (q : OnlineQuery S) :
    η * expectedDefect μ q ≤ -Real.log (gibbsPartition μ η q) + (η^2 / 2)
```

The lower bound can be obtained from the elementary inequality `exp (-x) ≤ 1` for `x ≥ 0` plus Jensen-style finite convexity if available; if Jensen is too heavy, prove a weaker but explicit bound:
```lean
theorem gibbsPartition_ge_exp_neg_expected :
  Real.exp (-η * expectedDefect μ q) ≤ gibbsPartition μ η q
```
and derive the log inequality from monotonicity of `Real.log`.

For the upper bound, a finite-form Hoeffding-type estimate on `[0,1]` losses is acceptable. If the strongest version is difficult, prove the explicit coarse bound:
```lean
theorem online_variational_step_upper_coarse ... :
  η * expectedDefect μ q ≤ -Real.log (gibbsPartition μ η q) + η^2
```
Be explicit which inequality you are actually proving.

### D. Recursive posterior evolution

```lean
theorem onlinePosterior_nil
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    (μ0 : SpectralPoint S → ℝ) (η : ℝ) :
    onlinePosterior μ0 η [] = μ0

theorem onlinePosterior_cons
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    (μ0 : SpectralPoint S → ℝ) (η : ℝ) (q : OnlineQuery S) (qs : List (OnlineQuery S)) :
    onlinePosterior μ0 η (q :: qs) =
      normalizedGibbsUpdate (onlinePosterior μ0 η qs) η q
```

Then prove by induction:

```lean
theorem onlinePosterior_isDistribution
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    [Nonempty (SpectralPoint S)]
    {μ0 : SpectralPoint S → ℝ}
    (hμ0 : IsSpectralDistribution μ0) (η : ℝ) :
    ∀ qs : List (OnlineQuery S), IsSpectralDistribution (onlinePosterior μ0 η qs)
```

This should use `induction qs with`
and not just simplification.

### E. Finite-horizon regret bounds

State and prove a finite-list regret theorem in the style of exponential weights. A clean formal target is:

```lean
theorem primeSpectral_online_regret_point
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    [Nonempty (SpectralPoint S)]
    {μ0 : SpectralPoint S → ℝ}
    (hμ0 : IsSpectralDistribution μ0)
    (hμ0_pos : ∀ p, 0 < μ0 p)
    {η : ℝ} (hη : 0 < η)
    (qs : List (OnlineQuery S)) (p⋆ : SpectralPoint S) :
    pointwiseOnlineRegret μ0 η qs p⋆
      ≤ (-Real.log (μ0 p⋆)) / η + (η / 2) * qs.length
```

Also prove a coarse version with `η * qs.length` on the RHS if needed. The proof architecture should be made explicit:

1. Define the cumulative unnormalized weight of `p⋆` after processing `qs`.
2. Show by induction on `qs` that this weight is
   `μ0 p⋆ * Real.exp (-η * cumulativePointDefect qs p⋆)`.
3. Compare it to the product of partition functions:
   `∏ t, gibbsPartition ...`.
4. Take logs and use the one-step variational upper bound to control the learner loss.
5. Rearrange with `field_simp` / `nlinarith`.

This theorem is the formal replacement for the original vague `primeSpectral_online_regret`.

Also derive a parameter-choice corollary with an explicit rate:

```lean
theorem primeSpectral_online_regret_balanced
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    [Nonempty (SpectralPoint S)]
    {μ0 : SpectralPoint S → ℝ}
    (hμ0 : IsSpectralDistribution μ0)
    (hμ0_pos : ∀ p, 0 < μ0 p)
    (qs : List (OnlineQuery S)) (p⋆ : SpectralPoint S)
    {T : ℕ} (hT : qs.length = T) (hTpos : 0 < T) :
    pointwiseOnlineRegret μ0 (Real.sqrt ((2 * (-Real.log (μ0 p⋆))) / T)) qs p⋆
      ≤ Real.sqrt (2 * (-Real.log (μ0 p⋆)) * T)
```

A weaker constant is acceptable, but the dependence must be explicit: `O(√T)` with actual formula, not prose.

### F. Cesàro extraction of countermodels

Replace the bare `cesaro_countermodel_extraction` conjecture by a theorem with a genuine witness:

```lean
theorem cesaro_countermodel_extraction
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    [Nonempty (SpectralPoint S)]
    {μ0 : SpectralPoint S → ℝ}
    (hμ0 : IsSpectralDistribution μ0)
    (hμ0_pos : ∀ p, 0 < μ0 p)
    {η ε : ℝ} (hη : 0 < η) (hε : 0 < ε)
    (x y : S)
    {n : ℕ} (hn : 0 < n)
    (hsmall :
      ((Finset.range n).sum (fun t =>
        expectedDefect (onlinePosterior μ0 η (List.replicate t ⟨x,y⟩)) ⟨x,y⟩)) / n < ε) :
    ∃ p : SpectralPoint S, countermodelDefect x y p < ε
```

Suggested proof route:
1. Assume contrariwise `∀ p, ε ≤ countermodelDefect x y p`.
2. Then `ε ≤ defectLoss ⟨x,y⟩ p` provided `ε ≤ 1`; split cases on `ε ≤ 1` vs `1 < ε`.
3. Deduce every expected defect is at least `ε`.
4. Sum over `t < n`, divide by `n`, contradict `hsmall`.
5. Use `rcases` on the finite nonempty spectral type to extract the witness.

Also prove a stronger sequential certificate theorem:

```lean
theorem sequential_nonDerivability_certificate
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    [Nonempty (SpectralPoint S)]
    {qs : List (OnlineQuery S)} {ε : ℝ}
    (huniform :
      ∀ p : SpectralPoint S, ∃ q ∈ qs, countermodelDefect q.lhs q.rhs p < ε) :
    ∃ q ∈ qs, ∃ p : SpectralPoint S, countermodelDefect q.lhs q.rhs p < ε
```

This is elementary but should be proved carefully using finite choice ideas over `Fintype`; it acts as a bridge to cryptographic “distinguishing witness extraction”.

---

## 3. Additional cross-domain theorems to raise impact

You must include theorem names and doc comments explicitly using application keywords such as
`quantum`, `thermodynamic`, `cryptographic`, `post_quantum`, `certified`, `lattice`, `robustness`.

Examples of acceptable additional theorem targets:

```lean
/-- Bridge: connects thermodynamic free-energy dissipation to certified robustness
of online proof-search posteriors. -/
theorem thermodynamic_certified_robustness_radius
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    [Nonempty (SpectralPoint S)]
    {μ0 : SpectralPoint S → ℝ}
    (hμ0 : IsSpectralDistribution μ0)
    (x y : S) (n : ℕ) :
    0 ≤ lipschitzCertifiedRadius μ0 x y n

/-- Bridge: connects post-quantum cryptographic hardness heuristics to finite
spectral regret via log-cardinality priors. -/
theorem post_quantum_uniform_prior_regret
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    [Nonempty (SpectralPoint S)] [DecidableEq (SpectralPoint S)]
    (η : ℝ) (hη : 0 < η)
    (qs : List (OnlineQuery S)) :
    let μu : SpectralPoint S → ℝ := fun _ => 1 / Fintype.card (SpectralPoint S)
    pointwiseOnlineRegret μu η qs (Classical.choice ‹Nonempty (SpectralPoint S)›)
      ≤ Real.log (Fintype.card (SpectralPoint S)) / η + (η / 2) * qs.length
```

Also include at least one theorem connecting cardinality of the spectral space to explicit complexity-like rates:
- `O(log |Spec| / η + ηT)`,
- balanced choice `η = sqrt(log |Spec| / T)`,
- a theorem name involving `lattice` or `quantum` even if the formal content is abstract and finite.

---

## 4. Proof strategy guidance

Use several proof patterns, not one.

### Strategy A: finite convex-analytic / entropy route
Most promising for the regret theorem.
- Show normalization and positivity first.
- Express partition functions as finite sums over `Fintype`.
- Use `Real.log_le_log`, `Real.strictMonoOn_exp`, and positivity of `Real.exp`.
- Build telescoping identities over the posterior recursion.
- Translate free-energy inequalities into regret bounds.

### Strategy B: direct induction on query lists
Most promising for recursive identities and cumulative-weight formulas.
- Prove exact formulas for the unnormalized mass of a fixed comparator point.
- Use `List.rec`, `List.length`, `List.take`, and `List.enum`.
- Introduce helper lemmas for `map`, `sum`, and `replicate`.
- This route is ideal for `primeSpectral_online_regret_point` and Cesàro lemmas.

### Strategy C: contradiction / witness extraction
Most promising for countermodel extraction.
- Use `by_contra h`.
- Convert universal lower bounds on `countermodelDefect` into lower bounds on every expected defect.
- Sum and divide to contradict a small Cesàro average.
- Apply `linarith`, `nlinarith`, and positivity of `n`.

### Strategy D: symmetric finite-space arguments
Useful for uniform priors and cardinality bounds.
- Define the uniform prior only under `[DecidableEq (SpectralPoint S)]`.
- Compute its mass by `Finset.card_univ`.
- Rewrite `-Real.log (1 / N)` as `Real.log N` when `0 < N`.
- Use `field_simp` carefully with `Nat.cast_ne_zero`.

---

## 5. Lean-specific implementation targets

Use explicit theorem signatures; do not hide hypotheses in local notation only. Include helper lemmas such as:

```lean
theorem spectralMass_nonneg ...
theorem spectralMass_eq_sum ...
theorem exists_positive_weight_of_mass_one ...
theorem normalizedGibbsUpdate_apply ...
theorem gibbsPartition_eq_sum_exp_mul ...
theorem cumulativePointDefect_cons ...
theorem cumulativePointDefect_append ...
theorem onlinePosterior_replicate_step ...
theorem expectedDefect_replicate_query_bound ...
theorem uniformSpectral_isDistribution ...
theorem log_inverse_uniform_cardinality ...
```

If KL divergence is introduced, prove at least:
```lean
theorem klSpectral_nonneg ...
theorem klSpectral_self_zero ...
theorem gibbs_freeEnergy_variational_bridge ...
```
A weaker finite-form statement is acceptable if exact Gibbs minimization is too heavy.

Where needed, add assumptions such as:
```lean
[Nonempty (SpectralPoint S)]
[DecidableEq (SpectralPoint S)]
```
but minimize them and isolate them theorem-by-theorem.

---

## 6. Mathematical significance to encode in doc comments

In theorem and definition doc comments, explicitly state bridges such as:

- Bridge: proof theory ↔ thermodynamic free energy.
- Bridge: online mirror descent ↔ prime-spectral semantics.
- Bridge: PAC-Bayesian Gibbs posterior ↔ certified robustness.
- Bridge: finite spectral regret ↔ post_quantum cryptographic witness extraction.
- Bridge: Cesàro defect collapse ↔ non-derivability countermodel certificates.

These comments matter: they clarify why the formal development is not just a restatement of Hedge, but a new semantic interface between online learning and closure-generated proof semirings.

---

## 7. Deliverable shape

Produce a substantial formal file, not a stub:
- 10+ definitions/structures,
- 20+ theorems,
- at least 3 main theorems of the scale of the regret bound / extraction theorem,
- zero `sorry`,
- use diverse tactics,
- keep theorem names inventive and domain-bridging.

If the full sharp regret constant is too difficult, prove the strongest explicit coarse bound you can and then derive the extraction theorem from that coarse bound. Prioritize:
1. normalized posterior well-posedness,
2. one-step free-energy inequality,
3. finite-horizon regret,
4. Cesàro countermodel extraction,
5. one cross-domain corollary with `quantum` / `cryptographic` / `certified_robustness` in the theorem name.

---

## 8. FUTURE_DIRECTIONS.md

Also produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps, each precise enough to become the next Lean target. Include at least:
1. an infinite-horizon / martingale extension,
2. a Schrödinger-bridge or entropic transport strengthening,
3. a lattice- or post-quantum-cryptographic interpretation of spectral regret,
4. a certified robustness / Lipschitz extension for neural or tropical classifiers.

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
            Formalize an online learning theory on the prime spectrum of coherent closure proof semirings: at each round, an adversary presents a query pair (x_t,y_t), the learner updates a Gibbs posterior over SpectralPoint S using entropic mirror descent, and incurs loss equal to a bounded countermodel defect surrogate. Prove a regret theorem comparing the cumulative free-energy loss of the sequential Gibbs posterior to any fixed spectral distribution, together with a sequential certificate theorem stating that persistent positive average defect yields an explicit non-derivability witness extracted from the time-averaged posterior. This extends the successful PAC-Bayesian and thermodynamic-semantic lines into a genuinely algorithmic sequential setting not currently in flight, while creating a new Algebra/Logic/ML bridge around online convex optimization on proof spectra.

            ### Precise Mathematical Framing
            Let S be a CoherentClosureProofSemiring with finite SpectralPoint S. For each round t and pair (x_t,y_t), define a bounded loss ell_t(p) from countermodelDefect x_t y_t p, e.g. clipped to [0,1]. Starting from prior mu_0 with full support, define mu_{t+1}(p) proportional to mu_t(p) * exp(-eta * ell_t(p)). Prove: (1) variational one-step identity expressing log-partition change as an infimum of expected loss plus KL penalty; (2) cumulative regret bound sum_t E_{mu_t}[ell_t] - inf_nu (sum_t E_nu[ell_t] + KL(nu||mu_0)/eta) <= O(eta T) or the exact mixability form; (3) if derivable x_t y_t for all t then every spectral loss vanishes appropriately, giving zero-regret calibration; (4) if average posterior loss stays bounded away from 0 on a repeated pair (x,y), then the Cesaro average posterior nu_T satisfies positive expected defect and hence yields a concrete countermodel witness p in its support with countermodelDefect x y p > 0; (5) in finite spectra, derive an explicit algorithm with complexity polynomial in |SpectralPoint S| and T. This creates a sequential analogue of prime-spectral PAC-Bayes, turns thermodynamic semantics into an online inference pipeline, and opens a field of proof-theoretic online learning.

            ### Lean 4 Sketch
import Mathlib
import Speculative.AutoResearch.ThermodynamicSanovCompleteness

open scoped BigOperators

structure OnlineQuery (S : Type _) where
  lhs : S
  rhs : S

noncomputable def defectLoss
    [CoherentClosureProofSemiring S]
    (q : OnlineQuery S) (p : SpectralPoint S) : ℝ :=
  min 1 (countermodelDefect q.lhs q.rhs p)

noncomputable def gibbsUpdate
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    (μ : SpectralPoint S → ℝ) (η : ℝ) (q : OnlineQuery S) : SpectralPoint S → ℝ :=
  fun p => Real.exp (-η * defectLoss q p) * μ p

conjecture online_variational_step
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    (μ ν : SpectralPoint S → ℝ) (η : ℝ) (q : OnlineQuery S) : Prop

conjecture primeSpectral_online_regret
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    (μ0 : SpectralPoint S → ℝ) (η : ℝ) (qs : List (OnlineQuery S)) : Prop

conjecture cesaro_countermodel_extraction
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    (μ0 : SpectralPoint S → ℝ) (η ε : ℝ) (x y : S) : Prop

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `entry_loss_bounded` : theorem entry_loss_bounded (p : ℝ) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
     (file: MachineLearning/QuantumTransformer/CrystallizationTraining.lean)
  2. `pac_bayes_prime_spectral_bound_of_mgf` : theorem pac_bayes_prime_spectral_bound_of_mgf {S : Type*} {n : ℕ}
     (file: Bridges/PACBayesBound.lean)
  3. `cumulative_regret_bounded` : theorem cumulative_regret_bounded (optimal actual : ℕ → ℝ) (N : ℕ) (B : ℝ)
     (file: EML/SPBExtended/ConvergenceGuarantees.lean)
  4. `gibbs_minimizes_free_energy` : theorem gibbs_minimizes_free_energy {S : Type*} {n : ℕ}
     (file: Bridges/GibbsPosterior.lean)
  5. `broadcasting_theorem` : theorem broadcasting_theorem {n : ℕ} (ign : Ignition n) (i : Fin n) :
     (file: MachineLearning/Consciousness/GlobalWorkspace.lean)

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
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


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

Research domain: MachineLearning
Research mode: formalize
