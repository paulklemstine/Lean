import Logic.PvsNPFoundations

/-!
# Exact Evaluation Oracles and Global Arithmetic Claims

An exact evaluator returns the value of a function at a requested point.  This file separates
that local capability from the additional global information needed to settle statements about
all zeros, orders of vanishing, distributions, or arithmetic reductions.

The central obstruction is interpolation: after any finite collection of evaluations, a
polynomial perturbation can preserve every observed value while prescribing an arbitrary value
at a fresh point.  Thus constant-time exact evaluation, by itself, is not a zero-classification
oracle.  Positive algorithmic consequences are instead obtained from explicit reductions to an
oracle fibre, and these reductions compose with the catalog's many-one reduction theory.
-/

open Finset BigOperators Function
open scoped Classical

namespace LFunctionOracle

/-- A decision problem is decided by one exact query to `eval` when membership is a fibre of
`eval`, after an input-dependent query map. -/
def OneQueryReducible {X Q A : Type*} (problem : Set X) (eval : Q → A) : Prop :=
  ∃ query : X → Q, ∃ accept : A → Prop,
    ∀ x, x ∈ problem ↔ accept (eval (query x))

/-- A problem defined by a selected output fibre always admits a one-query reduction. -/
theorem fibre_has_oneQueryReduction {Q A : Type*} (eval : Q → A) (accept : A → Prop) :
    OneQueryReducible {q | accept (eval q)} eval := by
  refine ⟨id, accept, ?_⟩
  intro q
  rfl

/-- One-query reducibility is stable under preprocessing by a many-one reduction. -/
theorem oneQueryReduction_of_manyOne
    {X Y Q A : Type*} {problem : Set X} {target : Set Y} {eval : Q → A}
    (hred : PvsNPFoundations.ManyOneReducible problem target)
    (horacle : OneQueryReducible target eval) :
    OneQueryReducible problem eval := by
  rcases hred with ⟨encode, hencode⟩
  rcases horacle with ⟨query, accept, hquery⟩
  refine ⟨query ∘ encode, accept, ?_⟩
  intro x
  rw [hencode x, hquery (encode x)]
  rfl

/-- If every problem in a class reduces to one oracle-decidable target, the whole class inherits
one-query oracle reductions.  This is the precise abstract form of an oracle-class collapse. -/
theorem hard_target_collapses_to_oneQuery
    {X Q A : Type*} {target : Set X} {problems : Set (Set X)} {eval : Q → A}
    (hhard : PvsNPFoundations.IsHardFor target problems)
    (horacle : OneQueryReducible target eval) :
    ∀ problem ∈ problems, OneQueryReducible problem eval := by
  intro problem hproblem
  exact oneQueryReduction_of_manyOne (hhard problem hproblem) horacle

/-- A factor-search specification: `factor n` must return a proper divisor whenever `n` is
composite.  Complexity bounds are intentionally kept separate from this extensional condition. -/
def IsFactorSearch (factor : ℕ → ℕ) : Prop :=
  ∀ n, ¬ Nat.Prime n → 2 ≤ n →
    factor n ∣ n ∧ 1 < factor n ∧ factor n < n

/-- An oracle-derived candidate is a valid factorization procedure exactly when the decoder's
arithmetic certificate is valid.  Oracle evaluation alone supplies no such certificate. -/
theorem factor_search_of_oracle_decoder
    {Q A : Type*} (eval : Q → A) (query : ℕ → Q) (decode : ℕ → A → ℕ)
    (hcertificate : ∀ n, ¬ Nat.Prime n → 2 ≤ n →
      decode n (eval (query n)) ∣ n ∧
      1 < decode n (eval (query n)) ∧ decode n (eval (query n)) < n) :
    IsFactorSearch (fun n => decode n (eval (query n))) := by
  intro n hnprime hn
  exact hcertificate n hnprime hn

/-! ## Finite observations do not determine global values -/

/-- The polynomial perturbation that vanishes on every point of `sample`. -/
def vanishingPerturbation (sample : Finset ℂ) (z : ℂ) : ℂ :=
  ∏ a ∈ sample, (z - a)

/-- The perturbation vanishes at each sampled point. -/
theorem vanishingPerturbation_eq_zero
    (sample : Finset ℂ) {z : ℂ} (hz : z ∈ sample) :
    vanishingPerturbation sample z = 0 := by
  unfold vanishingPerturbation
  apply Finset.prod_eq_zero hz
  simp

/-- Away from the sample, the perturbation is nonzero. -/
theorem vanishingPerturbation_ne_zero
    (sample : Finset ℂ) {z : ℂ} (hz : z ∉ sample) :
    vanishingPerturbation sample z ≠ 0 := by
  unfold vanishingPerturbation
  apply Finset.prod_ne_zero_iff.mpr
  intro a ha
  exact sub_ne_zero.mpr (Ne.symm (fun h => hz (h ▸ ha)))

/-- **Finite-query interpolation obstruction.**  Given arbitrary observations of `f` on a finite
sample and a fresh point `z`, there is another function agreeing with every observation but taking
any prescribed value `target` at `z`.

This is the decisive boundary for an evaluation oracle: no finite transcript can determine even
one unqueried value without structural restrictions on the admissible function family. -/
theorem finite_observations_allow_arbitrary_fresh_value
    (f : ℂ → ℂ) (sample : Finset ℂ) (z target : ℂ) (hz : z ∉ sample) :
    ∃ g : ℂ → ℂ,
      (∀ w ∈ sample, g w = f w) ∧ g z = target := by
  let p := vanishingPerturbation sample
  have hpz : p z ≠ 0 := vanishingPerturbation_ne_zero sample hz
  let scale : ℂ := (target - f z) / p z
  refine ⟨fun w => f w + scale * p w, ?_, ?_⟩
  · intro w hw
    have hpw : p w = 0 := vanishingPerturbation_eq_zero sample hw
    change f w + scale * p w = f w
    rw [hpw, mul_zero, add_zero]
  · change f z + ((target - f z) / p z) * p z = target
    field_simp
    ring

/-- In particular, a finite transcript compatible with a nonzero value at a fresh point is also
compatible with a zero there. -/
theorem finite_transcript_cannot_exclude_fresh_zero
    (f : ℂ → ℂ) (sample : Finset ℂ) (z : ℂ) (hz : z ∉ sample) :
    ∃ g : ℂ → ℂ, (∀ w ∈ sample, g w = f w) ∧ g z = 0 := by
  exact finite_observations_allow_arbitrary_fresh_value f sample z 0 hz

/-! ## Orders of vanishing require a finite witness -/

/-- `FirstNonzero jet k` says that `k` is the first nonzero coefficient in a derivative or Taylor
jet.  It abstracts the information needed to certify a finite order of vanishing. -/
def FirstNonzero (jet : ℕ → ℂ) (k : ℕ) : Prop :=
  jet k ≠ 0 ∧ ∀ j < k, jet j = 0

/-- A jet has at most one first nonzero index. -/
theorem firstNonzero_unique {jet : ℕ → ℂ} {k m : ℕ}
    (hk : FirstNonzero jet k) (hm : FirstNonzero jet m) : k = m := by
  rcases hk with ⟨hk0, hkprev⟩
  rcases hm with ⟨hm0, hmprev⟩
  by_contra hne
  rcases lt_or_gt_of_ne hne with hkm | hmk
  · exact hk0 (hmprev k hkm)
  · exact hm0 (hkprev m hmk)

/-- If a finite jet contains a nonzero term, well-ordering produces a certified order of
vanishing within that jet. -/
theorem finite_jet_yields_firstNonzero
    (jet : ℕ → ℂ) {bound : ℕ} (h : ∃ k ≤ bound, jet k ≠ 0) :
    ∃ k ≤ bound, FirstNonzero jet k := by
  let S := Finset.filter (fun k => jet k ≠ 0) (Finset.range (bound + 1))
  have hS : S.Nonempty := by
    rcases h with ⟨k, hk, hk0⟩
    refine ⟨k, Finset.mem_filter.mpr ⟨Finset.mem_range.mpr ?_, hk0⟩⟩
    omega
  let k := S.min' hS
  have hkS : k ∈ S := Finset.min'_mem S hS
  refine ⟨k, ?_, ?_⟩
  · have hklt : k < bound + 1 := Finset.mem_range.mp (Finset.mem_filter.mp hkS).1
    omega
  · refine ⟨(Finset.mem_filter.mp hkS).2, ?_⟩
    intro j hj
    by_contra hj0
    have hjS : j ∈ S := Finset.mem_filter.mpr ⟨Finset.mem_range.mpr ?_, hj0⟩
    · exact (Nat.not_lt_of_ge (Finset.min'_le S j hjS)) hj
    · have hklt : k < bound + 1 := Finset.mem_range.mp (Finset.mem_filter.mp hkS).1
      omega

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): (1) finite exact evaluation decides all zero-location claims;
-- (2) derivative-jet evaluation decides finite analytic rank when a nonzero coefficient is
-- bounded; (3) an explicit arithmetic decoder turns an evaluator into factor search; (4) a
-- complete oracle target collapses every many-one reducible class; (5) equality of finitely many
-- local values certifies functorial equality; (6) coefficient access plus effective tail bounds
-- can certify distribution laws.  Claims (1), (5), and unrestricted versions of (2) are the
-- boldest because they attempt to pass from local data to global structure.
--
-- Experiment (Experimenter): interpolation constructs a function with an arbitrary fresh value
-- while preserving every finite observation.  In contrast, reduction composition, certified
-- factor decoding, and bounded first-nonzero search survive as exact theorems.
--
-- Analysis (Analyst): evaluation and classification are distinct resources.  RH, BSD,
-- Sato--Tate, and functoriality concern infinitely many points, derivatives, limiting
-- distributions, or object identity.  Their missing ingredient is respectively a global zero
-- certificate, an effective nonvanishing bound, quantitative tail control, or a converse theorem.
--
-- Critique (Critic): no theorem infers an open conjecture from bare evaluation speed; doing so
-- would hide the conjecture in a decoder hypothesis.  The factor theorem likewise states its
-- indispensable arithmetic certificate explicitly.  The finite-query obstruction ranges over
-- arbitrary complex functions, so restricted L-function families may evade it only through
-- additional rigidity.
--
-- Synthesis (Principal Investigator): the surviving framework is a local-to-global boundary:
-- oracle consequences transfer along proved reductions, while interpolation refutes any claim
-- that finitely many unconstrained evaluations alone determine global analytic behavior.
-- !-- End Lab Notes -- !--

end LFunctionOracle