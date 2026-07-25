import Mathlib
import Bridges.InformationTheory.SubadditiveSequenceBridge

/-!
# Information-Theoretic Bounds for Finite Derivation Search

This study isolates the finite counting principles that genuinely support
information-theoretic lower bounds. A candidate derivation is represented by a
word over a finite alphabet. The results separate three notions that are often
conflated: description length, the number of candidates, and the number of
queries required when the verifier is treated as an unstructured oracle.

The central scaling law is exact: if a statement of size `n` exposes `n` choices
at each of `n` derivation steps, then the candidate population is `n^n`, whose
base-two logarithm is `n log₂ n`. This law is conditional on that branching
model; it is not a distribution-free theorem about mathematical statements.
-/

namespace ProofSearchInformationLimits

/-- Candidate derivations of depth `L` over an alphabet of size `q`. -/
abbrev Words (q L : ℕ) := Fin L → Fin q

/-- Binary descriptions whose length is strictly below `n`. -/
abbrev ShortBinary (n : ℕ) := Σ k : Fin n, (Fin (k : ℕ) → Bool)

/-
Exact-length derivations have exponential cardinality.
-/
theorem card_words (q L : ℕ) : Fintype.card (Words q L) = q ^ L := by
  erw [ Fintype.card_pi ] ; norm_num;

/-
The collection of all binary descriptions shorter than `n` has cardinality
`2^n - 1`.
-/
theorem card_shortBinary (n : ℕ) : Fintype.card (ShortBinary n) = 2 ^ n - 1 := by
  convert Fintype.card_sigma;
  exact Nat.sub_eq_of_eq_add <| by induction n <;> simp_all +decide [ Fin.sum_univ_castSucc, pow_succ' ] ; linarith;

/-
No lossless description scheme compresses every `n`-bit object below `n`
bits. This is the finite pigeonhole form of incompressibility.
-/
theorem no_uniform_strict_compression (n : ℕ) :
    ¬ ∃ f : Words 2 n → ShortBinary n, Function.Injective f := by
  have h_card : Fintype.card (Words 2 n) > Fintype.card (ShortBinary n) := by
    rw [ card_words, card_shortBinary ] ; exact Nat.sub_lt ( by positivity ) ( by positivity );
  exact fun ⟨ f, hf ⟩ => h_card.not_ge <| Fintype.card_le_of_injective f hf

/-
An unstructured verifier can hide a unique successful derivation outside any
proper query set. Thus fewer than all candidates cannot distinguish an empty
success set from a singleton success set.
-/
theorem adversarial_unqueried_witness {α : Type*} [Fintype α] [DecidableEq α]
    (queried : Finset α) (hproper : queried.card < Fintype.card α) :
    ∃ secret : α, secret ∉ queried ∧
      (∀ x ∈ queried, (x = secret) = False) := by
  obtain ⟨secret, hsecret⟩ : ∃ secret : α, secret ∉ queried := by
    exact not_forall.mp fun h => hproper.not_ge <| by rw [ show queried = Finset.univ from Finset.eq_univ_of_forall h ] ; simp +decide ;
  grind

/-
In particular, for `q^L` candidates, every query budget below `q^L` leaves
an unqueried location at which a unique proof may be hidden.
-/
theorem exponential_query_boundary (q L : ℕ) (queried : Finset (Words q L))
    (hbudget : queried.card < q ^ L) :
    ∃ secret : Words q L, secret ∉ queried ∧
      ∀ x ∈ queried, (x = secret) = False := by
  convert adversarial_unqueried_witness queried _;
  exact hbudget.trans_le ( by rw [ card_words ] )

/-
The proposed `n log n` information scale is exact in the explicit model with
`n` available symbols at each of `n` positions.
-/
theorem n_log_n_exact (n : ℕ) :
    Real.logb 2 (Fintype.card (Words n n)) = n * Real.logb 2 n := by
  convert Real.logb_pow 2 n using 1
  norm_num [Real.logb, mul_div_assoc]

/-
Cartesian composition multiplies candidate populations, the combinatorial
source of additive logarithmic information.
-/
theorem card_composed_words (q₁ q₂ L₁ L₂ : ℕ) :
    Fintype.card (Words q₁ L₁ × Words q₂ L₂) = q₁ ^ L₁ * q₂ ^ L₂ := by
  simp +decide

/-
Under positive branching, logarithmic information is additive under
independent Cartesian composition.
-/
theorem log_card_composition (q₁ q₂ L₁ L₂ : ℕ) (h₁ : 0 < q₁) (h₂ : 0 < q₂) :
    Real.log (Fintype.card (Words q₁ L₁ × Words q₂ L₂)) =
      L₁ * Real.log q₁ + L₂ * Real.log q₂ := by
  norm_num [ card_composed_words ];
  rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_pow, Real.log_pow ]

/-- Exact logarithmic candidate counts form an additive, hence subadditive,
sequence. This connects finite derivation counting to the catalog's Fekete
framework for asymptotic growth rates. -/
noncomputable def logCandidateCount (q n : ℕ) : ℝ := Real.log (Fintype.card (Words q n))

theorem logCandidateCount_growth (q n : ℕ) :
    logCandidateCount q n = n * Real.log q := by
  convert Real.log_pow ( q : ℝ ) n using 1;
  unfold logCandidateCount; rw [ card_words ] ; norm_cast;

theorem logCandidateCount_subadditive (q : ℕ) :
    Subadditive (logCandidateCount q) := by
  convert SubadditiveSequenceBridge.subadditive_def ( fun n ↦ n * Real.log q ) |>.2 _ using 1;
  · exact funext fun n => logCandidateCount_growth q n;
  · exact fun n m => by push_cast; linarith;

/-
The Fekete doubling inequality specializes to a sharp information bound for
candidate derivations.
-/
theorem doubled_depth_information (q n : ℕ) :
    logCandidateCount q (n + n) ≤
      logCandidateCount q n + logCandidateCount q n := by
  convert SubadditiveSequenceBridge.subadditive_double ( logCandidateCount q ) ( logCandidateCount_subadditive q ) n using 1

/-! ## Concrete instances -/

example : Fintype.card (Words 2 5) = 32 := by
  rw [card_words]
  norm_num

example : Fintype.card (Words 4 3) = 64 := by
  rw [card_words]
  norm_num

example : Fintype.card (ShortBinary 5) = 31 := by
  rw [card_shortBinary]
  norm_num

example : Fintype.card (Words 3 3) = 27 := by
  rw [card_words]
  norm_num

#check @no_uniform_strict_compression
#check @exponential_query_boundary
#check @n_log_n_exact
#check @logCandidateCount_subadditive

/-!
### Generalization

The same counting argument extends from uniform words to level-dependent
alphabets, where the candidate population is a product of branching factors and
its logarithm is a sum. Submultiplicative candidate families lead naturally to
subadditive logarithmic counts and asymptotic entropy through Fekete's lemma.
A broader extension would replace finite alphabets by prefix-free weighted trees
and cardinality by Kraft mass.

### Boundaries

The `n log n` theorem depends essentially on having `n` choices at each of `n`
steps. Fixed branching gives linear information instead. The query lower bound
assumes an unstructured equality oracle; algebraic structure, learned heuristics,
or certificates can reduce search. Finally, cardinality alone does not define a
probability distribution on proofs, so an expression of the form `-log₂ P(P)`
requires a separately specified measure. These are definition boundaries, not
counterexamples to the finite counting results.
-/

/-!
-- !-- Lab Notes -- !--

**Hypothesis (ranked by expected impact).**
1. In an `n`-branching, depth-`n` derivation model, information is exactly
   `n log₂ n`, providing a precise conditional realization of the proposed law.
2. Unstructured proof search has a sharp exponential query lower bound: any
   proper set of tested candidates can miss a unique successful derivation.
3. Independent composition makes information additive and candidate counts
   multiplicative, bridging combinatorics and information theory.
4. Logarithmic candidate counts belong to Fekete's subadditive growth framework.
5. No injective binary code strictly compresses all statements of a fixed size.
6. The same `n log n` law holds for fixed branching and for every distribution
   on theorem statements.

**Experiment.** Exact cardinalities were derived for finite words and all shorter
binary descriptions. The `n`-branching model was converted to a logarithmic
identity. An adversarial singleton construction tested the query claim. Product
spaces tested composition, and the resulting logarithmic sequence was connected
to the existing subadditive-sequence theory. Small instances (`2^5 = 32`,
`4^3 = 64`, `3^3 = 27`, and `2^5 - 1 = 31`) serve as concrete checks.

**Analysis.** Hypotheses 1--5 survive in the stated finite models. Hypothesis 6
fails and needs a different definition: fixed branching yields `Θ(n)` rather
than `Θ(n log n)`, while information content is not even determined until a
probability law is chosen. The common structural pattern is that logarithms turn
Cartesian multiplication into additive information and submultiplicative growth
into subadditivity.

**Critique.** None of the results establishes an unconditional complexity class
lower bound for a full deductive system. The oracle theorem deliberately removes
all semantic structure, so it is a boundary result rather than evidence that
structured derivation procedures always require exhaustive search. The exact scaling theorem also covers the zero-size boundary under the standard
logarithm convention, while its intended branching interpretation begins at
positive size. No external arXiv, OEIS, or LMFDB signal was
provided, so no unsupported external attribution influenced the targets.

**Synthesis.** The defensible information-theoretic core consists of exact
finite counting, incompressibility by pigeonhole, adversarial oracle search, and
additivity under composition. The conjectured `n log n` behavior is recovered
exactly when branching itself scales with statement size; outside that regime,
the model predicts a different growth law.
-/

end ProofSearchInformationLimits