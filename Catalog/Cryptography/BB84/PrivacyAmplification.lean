import Mathlib
import Cryptography.MerkleDamgard

/-!
# BB84 Privacy Amplification: the Leftover-Hash / Collision Bound

Privacy amplification is the final stage of BB84: Alice and Bob apply a randomly
chosen 2-universal hash function to their reconciled raw key, shrinking it to a
shorter final key on which the eavesdropper's information is *exponentially small*.

The quantitative heart of the leftover-hash lemma is a Cauchy–Schwarz bound that
turns a bound on the **collision probability** `∑ p i ^ 2` (i.e. on Eve's
guessing / min-entropy) into a bound on the **statistical distance to uniform**
of the hashed key:

`∑ i, |p i - 1/M|  ≤  √(M · ∑ i, (p i)^2 − 1)`.

When the output length is `ℓ` bits (`M = 2^ℓ`) and the collision probability is at
most `2^{-k}` (min-entropy `k`), the right-hand side is at most `2^{(ℓ-k)/2}`,
which decays exponentially as the *entropy gap* `k - ℓ` grows.

We also reuse `Cryptography.MerkleDamgard.compression_collision_of_card` to show
that *deterministic* hashing into a smaller space is never injective — this is the
structural reason privacy amplification must use a *randomized* (universal) family.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): Eve's distinguishing advantage after privacy
  amplification is controlled by a single second-moment (collision) quantity, and
  the L¹ distance to uniform is at most the *square root* of the excess collision
  probability — exponentially small in the entropy gap.
EXPERIMENT (Experimenter): The centered vector `d i = p i - 1/M` has `∑ d i = 0`
  and `∑ d i^2 = ∑ p i^2 − 1/M`. Cauchy–Schwarz with the all-ones vector gives
  `(∑ |d i|)^2 ≤ M · ∑ d i^2 = M·∑ p i^2 − 1`. Squeezing through `Real.sqrt`
  yields the leftover-hash bound. Tested numerically on near-uniform and spiked
  distributions; the bound holds with room to spare.
ANALYSIS (Analyst): The proof needs only finite Cauchy–Schwarz
  (`Finset.sum_mul_sq_le_sq_mul_sq`) plus algebra on the centered second moment;
  no measure theory. Notably the bound did NOT require `p ≥ 0`: it is a pure
  Cauchy–Schwarz statement for any vector summing to 1, so we dropped that
  hypothesis (the probability case is the special case `p ≥ 0`). The exponential
  form follows from `M = 2^ℓ`, `collision ≤ 2^{-k}`, monotonicity of `√`.
CRITIQUE (Critic): Counterexample hunt — could the bound fail for a point mass?
  For `p = δ_j`, `∑ p^2 = 1`, RHS `= √(M-1)`, LHS `= 2(1 - 1/M) < √(M-1)` for
  `M ≥ 2`; robust. The only hypothesis (`∑ p = 1`) is exactly the normalization of
  a distribution — no hidden assumptions. The exponential bound's inequality holds
  for all `ℓ, k`; the regime `ℓ < k` is what makes it *small*. The catalog bridge
  is a genuine non-injectivity result, not a rename.
SYNTHESIS (PI): `statDist_le_collision` (Cauchy–Schwarz core) +
  `privacyAmplification_exp_bound` (exponential decay) + `injective_extractor_impossible`
  (catalog pigeonhole reuse).
-/

open Finset

noncomputable section

namespace BB84

/-- **Leftover-hash core (Cauchy–Schwarz bound).**
For any real vector `p` on a finite set of size `M` that sums to `1` (in particular
any probability vector), the statistical distance (twice the total-variation
distance) to the uniform distribution is bounded by the square root of the
*excess collision probability* `M · ∑ p i² − 1`.  Nonnegativity of `p` is not
needed: the bound is a pure Cauchy–Schwarz fact about the centered vector. -/
theorem statDist_le_collision {M : ℕ} (hM : 0 < M) (p : Fin M → ℝ)
    (hsum : ∑ i, p i = 1) :
    ∑ i, |p i - (M : ℝ)⁻¹| ≤ Real.sqrt ((M : ℝ) * (∑ i, (p i) ^ 2) - 1) := by
  refine Real.le_sqrt_of_sq_le ?_
  have h_cauchy_schwarz :
      (∑ i : Fin M, |p i - (M : ℝ)⁻¹|) ^ 2 ≤ M * (∑ i : Fin M, (p i - (M : ℝ)⁻¹) ^ 2) := by
    have hCS : ∀ (u v : Fin M → ℝ),
        (∑ i, u i * v i) ^ 2 ≤ (∑ i, u i ^ 2) * (∑ i, v i ^ 2) := by
      intro u v
      exact Finset.sum_mul_sq_le_sq_mul_sq Finset.univ u v
    simpa [← sq] using hCS (fun _ => 1) (fun i => |p i - (M : ℝ)⁻¹|)
  simp_all +decide [sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _]
  simp_all +decide [← Finset.mul_sum _ _ _, ← Finset.sum_mul, sq, mul_assoc, hM.ne']
  nlinarith [mul_inv_cancel₀ (by positivity : (M : ℝ) ≠ 0)]

/-- **Privacy amplification: exponentially small statistical distance.**
If the hashed key has `ℓ` output bits (`M = 2^ℓ`) and collision probability at most
`2^{-k}` (min-entropy `≥ k`), then its statistical distance to uniform is at most
`√(2^{ℓ-k})`.  This is exponentially small precisely in the *secure regime* where
the entropy gap `k - ℓ` is large (`ℓ < k`): then `2^{ℓ-k} → 0`.  The inequality
itself holds for all `ℓ, k`. -/
theorem privacyAmplification_exp_bound {ℓ k : ℕ}
    (p : Fin (2 ^ ℓ) → ℝ) (hsum : ∑ i, p i = 1)
    (hcoll : ∑ i, (p i) ^ 2 ≤ (2 : ℝ) ^ (-(k : ℤ))) :
    ∑ i, |p i - ((2 ^ ℓ : ℕ) : ℝ)⁻¹| ≤ Real.sqrt ((2 : ℝ) ^ ((ℓ : ℤ) - k)) := by
  refine' le_trans _ (Real.sqrt_le_sqrt _)
  · convert BB84.statDist_le_collision (show 0 < 2 ^ ℓ by positivity) p hsum using 1
  · norm_num [zpow_sub₀] at *
    exact le_add_of_le_of_nonneg
      (mul_le_mul_of_nonneg_left hcoll (by positivity)) zero_le_one

/-- **Why universal hashing must be randomized.**
Any *deterministic* compression `f : State → Block → State` of the raw key into the
state space is never injective once there is more than one block and the state space
is nonempty: by the pigeonhole principle (reusing the catalog's Merkle–Damgård
collision theorem) two distinct inputs collide. Hence a fixed hash cannot be a
secure extractor — privacy amplification needs a *random* member of a universal
family, whose leakage is then controlled by `statDist_le_collision`. -/
theorem injective_extractor_impossible {State Block : Type*}
    [Fintype State] [Fintype Block] [Nonempty State]
    (hB : 1 < Fintype.card Block) (f : State → Block → State) :
    ¬ Function.Injective (fun sb : State × Block => f sb.1 sb.2) := by
  -- Reuse the catalog's Merkle–Damgård pigeonhole collision theorem.
  obtain ⟨s, b, s', b', hne, heq⟩ :=
    Cryptography.MerkleDamgard.compression_collision_of_card hB f
  intro h_inj
  exact hne (h_inj heq)

end BB84