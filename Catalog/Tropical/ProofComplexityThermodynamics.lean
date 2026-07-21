import Mathlib

/-!
# Proof Complexity and Thermodynamic Cost

This file separates three claims often conflated in speculative discussions of
"thermodynamic proof complexity".

* For the model `cost = K · T · log 2`, cost is monotone (and at positive
  temperature strictly monotone) in description complexity `K`.
* Raw proof length is not enough: padding gives a strictly longer proof with the
  same information content and hence the same cost.
* The literal claim that one fixed proof beats *every* computable bound is false,
  since the constant function at its own complexity is already a computable bound.
  The valid Chaitin-style replacement is uniform unboundedness: every fixed budget
  is exceeded by some object under every injective binary description scheme.
* In the canonical model of uniformly random `n`-bit statements, mean binary
  description length is `n - 1 + 2⁻ⁿ`, hence linear, not exponential.  A concrete
  four-bit counterexample refutes the proposed exponential lower bound.

No physical identification of abstract description length with dissipated heat is
assumed here; `thermodynamicCost` is the mathematical model specified in the mission.
-/

noncomputable section

open Finset Function Real BigOperators

namespace ProofComplexityThermodynamics

/-- The proposed thermodynamic cost model (Boltzmann's constant normalized to one). -/
def thermodynamicCost (K : ℕ) (T : ℝ) : ℝ := (K : ℝ) * T * Real.log 2

/-
At nonnegative temperature, lower Kolmogorov complexity implies no greater cost.
-/
theorem cost_mono_complexity {K₁ K₂ : ℕ} {T : ℝ}
    (hK : K₁ ≤ K₂) (hT : 0 ≤ T) :
    thermodynamicCost K₁ T ≤ thermodynamicCost K₂ T := by
  exact mul_le_mul_of_nonneg_right ( mul_le_mul_of_nonneg_right ( Nat.cast_le.mpr hK ) hT ) ( Real.log_nonneg one_le_two )

/-
At positive temperature, a strict complexity reduction gives a strict cost reduction.
-/
theorem cost_strict_mono_complexity {K₁ K₂ : ℕ} {T : ℝ}
    (hK : K₁ < K₂) (hT : 0 < T) :
    thermodynamicCost K₁ T < thermodynamicCost K₂ T := by
  exact mul_lt_mul_of_pos_right ( mul_lt_mul_of_pos_right ( Nat.cast_lt.mpr hK ) hT ) ( Real.log_pos one_lt_two )

/-- A proof object with irrelevant padding.  Its information-bearing description is
`payload`; `padding` changes raw length but not semantic complexity. -/
structure PaddedProof where
  payload : List Bool
  padding : List Bool
  deriving DecidableEq

/-- Raw stored length, including irrelevant padding. -/
def PaddedProof.rawLength (p : PaddedProof) : ℕ := p.payload.length + p.padding.length

/-- Description complexity in this padding model. -/
def PaddedProof.complexity (p : PaddedProof) : ℕ := p.payload.length

/-- Cost of a padded proof. -/
def PaddedProof.cost (p : PaddedProof) (T : ℝ) : ℝ :=
  thermodynamicCost p.complexity T

/-
**Counterexample to raw-length monotonicity.** There are proofs of different raw
length but identical complexity and cost, at every temperature.
-/
theorem padding_refutes_raw_length_cost :
    ∃ short long : PaddedProof,
      short.rawLength < long.rawLength ∧
      short.complexity = long.complexity ∧
      ∀ T : ℝ, short.cost T = long.cost T := by
  -- Choose `short` with empty payload and empty padding, and `long` with empty payload and padding of length 1.
  use ⟨[], []⟩, ⟨[], [true]⟩;
  simp +decide;
  exact fun T => rfl

/-! ## A finite-description Chaitin analogue -/

/-- Binary description complexity induced by an encoding. -/
def binaryComplexity (enc : ℕ → ℕ) (x : ℕ) : ℕ := Nat.size (enc x)

/-
Among `2^n+1` objects, an injective binary encoding must assign one a code
longer than `n` bits.
-/
theorem finite_incompressibility (enc : ℕ → ℕ) (hinj : Injective enc) (n : ℕ) :
    ∃ x ∈ Finset.range (2 ^ n + 1), n < binaryComplexity enc x := by
  by_contra! h;
  -- Then for all x in range(2^n+1), enc x < 2^n.
  have h_enc_lt_pow : ∀ x ∈ Finset.range (2^n + 1), enc x < 2^n := by
    intro x hx; specialize h x hx; rw [ binaryComplexity ] at h; rw [ Nat.size_le ] at h; aesop;
  exact absurd ( Finset.card_le_card ( show Finset.image enc ( Finset.range ( 2 ^ n + 1 ) ) ⊆ Finset.range ( 2 ^ n ) from Finset.image_subset_iff.mpr fun x hx => Finset.mem_range.mpr ( h_enc_lt_pow x hx ) ) ) ( by rw [ Finset.card_image_of_injective _ hinj ] ; simp +arith +decide )

/-
Every fixed complexity budget is exceeded.  This is the sound quantifier order
for the proof-theoretic analogue of Chaitin incompressibility.
-/
theorem complexity_unbounded (enc : ℕ → ℕ) (hinj : Injective enc) (n : ℕ) :
    ∃ x, n < binaryComplexity enc x := by
  by_contra h;
  exact h <| by obtain ⟨ x, hx₁, hx₂ ⟩ := finite_incompressibility enc hinj n; exact ⟨ x, hx₂ ⟩ ;

/-
At positive temperature the corresponding thermodynamic costs are unbounded.
-/
theorem thermodynamic_cost_unbounded (enc : ℕ → ℕ) (hinj : Injective enc)
    {T B : ℝ} (hT : 0 < T) :
    ∃ x, B < thermodynamicCost (binaryComplexity enc x) T := by
  -- Let c=T*log 2, which is positive. By the Archimedean property choose natural n with B/c < n (or directly B < n*c).
  obtain ⟨n, hn⟩ : ∃ n : ℕ, B < n * T * Real.log 2 := by
    exact exists_nat_gt ( B / ( T * Real.log 2 ) ) |> fun ⟨ n, hn ⟩ => ⟨ n, by rw [ div_lt_iff₀ ( mul_pos hT ( Real.log_pos one_lt_two ) ) ] at hn; linarith ⟩;
  obtain ⟨ x, hx ⟩ := complexity_unbounded enc hinj n;
  exact ⟨ x, hn.trans_le <| mul_le_mul_of_nonneg_right ( mul_le_mul_of_nonneg_right ( mod_cast hx.le ) hT.le ) <| Real.log_nonneg one_le_two ⟩

/-
**Disproof of the literal "exceeds every computable bound" formulation.**
No single object can have complexity larger than every numerical bound function:
the constant function equal to its own complexity defeats the claim.
-/
theorem no_object_exceeds_every_bound (enc : ℕ → ℕ) :
    ¬ ∃ x, ∀ bound : ℕ → ℕ, bound x < binaryComplexity enc x := by
  exact fun ⟨ x, hx ⟩ => lt_irrefl _ ( hx fun _ => binaryComplexity enc x )

/-! ## Average complexity of uniformly random fixed-width statements -/

/-- Total canonical binary description length of all numbers represented by at most
`n` bits. -/
def totalBinaryComplexity (n : ℕ) : ℕ :=
  ∑ x ∈ Finset.range (2 ^ n), Nat.size x

/-- Mean canonical description length for a uniformly sampled `n`-bit word. -/
def averageBinaryComplexity (n : ℕ) : ℚ :=
  (totalBinaryComplexity n : ℚ) / (2 ^ n : ℚ)

/-- Mean cost in the thermodynamic model for the same uniform sample. -/
def averageThermodynamicCost (n : ℕ) (T : ℝ) : ℝ :=
  ((totalBinaryComplexity n : ℝ) / (2 ^ n : ℝ)) * T * Real.log 2

/-
Exact total description length: `1 + (n-1)2^n` for positive widths.
-/
theorem totalBinaryComplexity_exact {n : ℕ} (hn : 0 < n) :
    totalBinaryComplexity n = (n - 1) * 2 ^ n + 1 := by
  induction' n with n ih <;> norm_num [ Nat.pow_succ', Finset.sum_range_succ ] at *;
  have h_split : totalBinaryComplexity (n + 1) = totalBinaryComplexity n + ∑ x ∈ Finset.Ico (2 ^ n) (2 ^ (n + 1)), Nat.size x := by
    unfold totalBinaryComplexity;
    rw [ Finset.sum_range_add_sum_Ico _ ( Nat.pow_le_pow_right ( by decide ) ( Nat.le_succ _ ) ) ];
  have h_block : ∀ x ∈ Finset.Ico (2 ^ n) (2 ^ (n + 1)), Nat.size x = n + 1 := by
    intro x hx
    have h_size : Nat.size x ≤ n + 1 := by
      rw [ Nat.size_le ] ; aesop
    have h_size_ge : n + 1 ≤ Nat.size x := by
      grind +suggestions
    exact le_antisymm h_size h_size_ge;
  rcases n with ( _ | n ) <;> simp_all +decide [ Nat.pow_succ' ];
  nlinarith only [ Nat.sub_add_cancel ( show 2 * ( 2 * 2 ^ n ) ≥ 2 * 2 ^ n by linarith [ pow_pos ( zero_lt_two' ℕ ) n ] ) ]

/-
Exact mean description length.  It is linear (asymptotic to `n`), not exponential.
-/
theorem averageBinaryComplexity_exact {n : ℕ} (hn : 0 < n) :
    averageBinaryComplexity n = (n : ℚ) - 1 + 1 / (2 ^ n : ℚ) := by
  convert congr_arg ( fun x : ℚ => x / ( 2 ^ n ) ) ( show ( totalBinaryComplexity n : ℚ ) = ( n - 1 ) * 2 ^ n + 1 by
                                                      convert congr_arg ( fun x : ℕ => x : ℕ → ℚ ) ( totalBinaryComplexity_exact hn ) using 1;
                                                      cases n <;> aesop ) using 1;
  rw [ add_div, mul_div_cancel_right₀ _ ( by positivity ) ]

/-
The thermodynamic average has the same linear factor, scaled by `T * log 2`.
-/
theorem averageThermodynamicCost_exact {n : ℕ} (hn : 0 < n) (T : ℝ) :
    averageThermodynamicCost n T =
      ((n : ℝ) - 1 + 1 / (2 ^ n : ℝ)) * T * Real.log 2 := by
  unfold averageThermodynamicCost;
  rw [ totalBinaryComplexity_exact hn ];
  cases n with
  | zero => omega
  | succ n =>
      norm_num at *
      ring_nf
      norm_num [mul_assoc, ← mul_pow]

/-
The mean lies between `n-1` and `n`; this gives elementary linear upper and lower
bounds without invoking asymptotic notation.
-/
theorem averageBinaryComplexity_linear_bounds {n : ℕ} (hn : 0 < n) :
    (n : ℚ) - 1 ≤ averageBinaryComplexity n ∧
      averageBinaryComplexity n ≤ n := by
  rw [ averageBinaryComplexity_exact hn ];
  exact ⟨ le_add_of_nonneg_right <| by positivity, by linarith [ show ( 1 : ℚ ) / 2 ^ n ≤ 1 by rw [ div_le_iff₀ <| by positivity ] ; norm_cast; linarith [ Nat.pow_le_pow_right two_pos hn ] ] ⟩

/-
**Concrete disproof of an exponential-average lower bound.** For four-bit true
statements the average canonical cost is `49/16`, strictly below `2^(4-1)=8`.
-/
theorem exponential_average_claim_false :
    averageBinaryComplexity 4 = 49 / 16 ∧
    averageBinaryComplexity 4 < 2 ^ (4 - 1) := by
  rw [averageBinaryComplexity_exact (by norm_num : 0 < 4)]
  norm_num

end ProofComplexityThermodynamics