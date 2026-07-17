import Mathlib
import Cryptography.ZeroKnowledge.ZKAmplification
import Cryptography.ZeroKnowledge.Graph3ColoringSimulator

/-!
# Zero-Knowledge Certification of Propositional Tautologies

This chapter isolates a finite theorem-proving protocol. A formula in `m` variables is
challenged at a uniformly chosen valuation. A false formula has at least one catching
valuation, so independent repetition gives an exact geometric soundness bound. Proof
values are committed with a uniformly masked element of a finite additive group; the
commitment distribution is independent of the value.

The construction deliberately separates two claims often conflated in informal
accounts. Random local checking supplies soundness, while zero knowledge requires an
independent simulation argument. Merely revealing a random proof line does not by
itself establish zero knowledge.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Six falsifiable targets were ranked by expected impact.
(1, famous-open subtask) Polynomial-statement communication should suffice for every
Peano-arithmetic theorem. (2, famous-open subtask) a zero-knowledge proof system for
propositional validity with polynomial communication should illuminate the NP versus
coNP barrier. (3, famous-open subtask) PCP encodings of bounded arithmetic should
retain zero knowledge under local opening. (4, cross-domain) Boolean truth tables and
finite-product probability should give an exact repetition law. (5, cross-domain)
finite additive-group actions and transcript simulation should give perfect hiding.
(6, cross-domain) proof-spectrum locality and commitment locality should admit a
common sheaf-like gluing law. The experiment concentrated on targets (4) and (5),
the finite cores required before the three grander complexity claims can be assessed.

Experiment (Experimenter): Formulas were evaluated on all Boolean valuations. A
counterexample valuation was removed from the accepting set to obtain the sharp
`2^m-1` bound. Uniform additive masking was treated as a pushforward along a
translation bijection, producing an explicit simulator distribution.

Analysis (Analyst): The surviving soundness rate is `((2^m-1)/2^m)^k`, not `2^-k`.
Thus one random valuation per round becomes exponentially weaker as the number of
variables grows. By contrast, hiding is perfect and has no asymptotic loss.

Critique (Critic): Targets (1)--(3) do not follow from these arguments and remain
unsupported. The PCP theorem measures resources against an encoded instance and does
not erase the cost of an arbitrarily long derivation; moreover, opening a random raw
proof line neither verifies its dependencies nor hides its contents. The local-check
protocol here is not a polynomial-communication proof of arbitrary tautologies: its
challenge space is exponential and it assumes direct formula evaluation. Target (6)
needs a definition of compatible local transcript distributions before it is even a
well-posed theorem. Targets (4) and (5) survive. Their main bounds are non-vacuous and
depend on an explicit false valuation and independent-product reasoning.

Synthesis (Principal Investigator): The resulting theory cleanly bridges Boolean
algebra, finite combinatorics, probability, and additive cryptographic masking. It
also identifies the missing ingredient for succinct theorem certification: a
probabilistically checkable encoding with robust local inconsistency, rather than a
raw list of derivation steps.
-- !-- Lab Notes -- !--
-/

namespace ZK.Propositional

/-- Propositional formulas with falsity and implication as a complete basis. -/
inductive Formula (m : ℕ) where
  | var : Fin m → Formula m
  | bot : Formula m
  | imp : Formula m → Formula m → Formula m
  deriving DecidableEq

/-- Boolean evaluation under a valuation. -/
def Formula.eval {m : ℕ} (v : Fin m → Bool) : Formula m → Bool
  | .var i => v i
  | .bot => false
  | .imp p q => !(p.eval v) || q.eval v

/-- A formula is a tautology when every Boolean valuation satisfies it. -/
def Formula.IsTautology {m : ℕ} (p : Formula m) : Prop :=
  ∀ v : Fin m → Bool, p.eval v = true

/-- Failure of tautologicity is witnessed by a concrete rejecting valuation. -/
theorem exists_rejecting_valuation {m : ℕ} {p : Formula m}
    (h : ¬ p.IsTautology) : ∃ v : Fin m → Bool, p.eval v = false := by
  classical
  unfold Formula.IsTautology at h
  push_neg at h
  obtain ⟨v, hv⟩ := h
  refine ⟨v, ?_⟩
  cases he : p.eval v with
  | false => rfl
  | true => exact False.elim (hv he)

/-- The accepting truth-table rows of a non-tautology occupy at most all but one
of the `2^m` possible valuations. -/
theorem accepting_valuations_card_le {m : ℕ} (p : Formula m)
    (h : ¬ p.IsTautology) :
    (Finset.univ.filter (fun v : Fin m → Bool => p.eval v = true)).card ≤ 2 ^ m - 1 := by
  classical
  obtain ⟨v₀, hv₀⟩ := exists_rejecting_valuation h
  have hsub : (Finset.univ.filter (fun v : Fin m → Bool => p.eval v = true)) ⊆
      Finset.univ.erase v₀ := by
    intro v hv
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hv
    simp only [Finset.mem_erase, Finset.mem_univ, and_true]
    rintro rfl
    rw [hv₀] at hv
    simp at hv
  calc
    (Finset.univ.filter (fun v : Fin m → Bool => p.eval v = true)).card
        ≤ (Finset.univ.erase v₀).card := Finset.card_le_card hsub
    _ = Fintype.card (Fin m → Bool) - 1 := by
      rw [Finset.card_erase_of_mem (Finset.mem_univ v₀), Finset.card_univ]
    _ = 2 ^ m - 1 := by simp

/-- Independent random-valuation challenges have geometric soundness error. The
left side is the product of the per-round accepting fractions. -/
theorem repeated_truth_table_soundness {m k : ℕ} (p : Formula m)
    (h : ¬ p.IsTautology) :
    ∏ _i : Fin k,
        ((Finset.univ.filter (fun v : Fin m → Bool => p.eval v = true)).card : ℚ) /
          (2 ^ m : ℕ)
      ≤ ((((2 ^ m : ℕ) - 1 : ℕ) : ℚ) / (2 ^ m : ℕ)) ^ k := by
  apply ZK.Amplification.prod_prob_le_pow
  · intro i
    positivity
  · intro i
    have hc := accepting_valuations_card_le p h
    have hcast :
        ((Finset.univ.filter (fun v : Fin m → Bool => p.eval v = true)).card : ℚ)
          ≤ (((2 ^ m : ℕ) - 1 : ℕ) : ℚ) := by exact_mod_cast hc
    gcongr

section Hiding

variable {q : ℕ} [NeZero q]

/-- Distribution of an additive one-time-pad commitment to `secret`. -/
noncomputable def commitmentDistribution (secret : ZMod q) : PMF (ZMod q) :=
  PMF.map (fun mask => secret + mask) (PMF.uniformOfFintype (ZMod q))

/-- Uniform masking has the uniform simulator distribution, independently of the
committed proof value. -/
theorem commitmentDistribution_eq_uniform (secret : ZMod q) :
    commitmentDistribution secret = PMF.uniformOfFintype (ZMod q) := by
  unfold commitmentDistribution
  exact ZK.Graph3Coloring.map_uniformOfFintype_of_bijective _
    (Equiv.addLeft secret).bijective

/-- Perfect hiding: any two proof values induce exactly the same verifier view. -/
theorem commitment_perfect_hiding (left right : ZMod q) :
    commitmentDistribution left = commitmentDistribution right := by
  rw [commitmentDistribution_eq_uniform, commitmentDistribution_eq_uniform]

/-- Every observed commitment has the same point probability for every secret. -/
theorem commitment_pointwise_independent (left right observed : ZMod q) :
    commitmentDistribution left observed = commitmentDistribution right observed := by
  rw [commitment_perfect_hiding left right]

end Hiding

/-- A single theorem packages the protocol's two independent guarantees: false
formulas have geometrically shrinking acceptance probability, while commitments
to any two local proof values are identically distributed. -/
theorem soundness_and_zero_knowledge {m k q : ℕ} [NeZero q]
    (p : Formula m) (h : ¬ p.IsTautology) (left right : ZMod q) :
    (∏ _i : Fin k,
        ((Finset.univ.filter (fun v : Fin m → Bool => p.eval v = true)).card : ℚ) /
          (2 ^ m : ℕ)
      ≤ ((((2 ^ m : ℕ) - 1 : ℕ) : ℚ) / (2 ^ m : ℕ)) ^ k) ∧
    commitmentDistribution left = commitmentDistribution right := by
  refine ⟨repeated_truth_table_soundness p h, ?_⟩
  exact commitment_perfect_hiding left right

end ZK.Propositional