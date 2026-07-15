import Mathlib

/-!
# What random proof-step opening does—and does not—guarantee

This file gives a finite, information-theoretic analysis of the protocol proposed in
the prompt.  A verifier asks for a coordinate of a witness and receives that coordinate
in the clear.  We characterize perfect zero knowledge for this protocol, show a concrete
privacy failure, and quantify why checking one uniformly random proof line does not by
itself give soundness error `2⁻ᵏ`.

No computational hardness assumption is modeled.  Consequently the results concern
perfect (not computational) zero knowledge.
-/

namespace ZeroKnowledge

/-- Perfect witness-independence of a deterministic verifier view. -/
def PerfectWitnessPrivacy {S W V : Type*} (valid : S → W → Prop)
    (view : S → W → V) : Prop :=
  ∀ s w₁ w₂, valid s w₁ → valid s w₂ → view s w₁ = view s w₂

/-- The view produced by opening coordinate `i` of a finite witness. -/
def openingView {S A : Type*} (i : Fin n) (_statement : S)
    (witness : Fin n → A) : A := witness i

/-
Opening a coordinate is perfectly witness-private exactly when every two valid
witnesses agree at that coordinate.
-/
theorem openingView_private_iff {S A : Type*} (valid : S → (Fin n → A) → Prop)
    (i : Fin n) :
    PerfectWitnessPrivacy valid (openingView i) ↔
      ∀ s w₁ w₂, valid s w₁ → valid s w₂ → w₁ i = w₂ i := by
  constructor <;> intro h <;> exact h

/-
If two valid witnesses differ in the challenged coordinate, revealing that
coordinate is not perfect zero knowledge.
-/
theorem openingView_not_private {S A : Type*} (valid : S → (Fin n → A) → Prop)
    (i : Fin n) (s : S) (w₁ w₂ : Fin n → A)
    (h₁ : valid s w₁) (h₂ : valid s w₂) (hne : w₁ i ≠ w₂ i) :
    ¬ PerfectWitnessPrivacy valid (openingView i) := by
  exact fun h => hne ( h s w₁ w₂ h₁ h₂ )

/-
Revealing *every possible* coordinate is private only when the valid witness is
unique extensionally.  Randomizing which coordinate is revealed does not remove this
obstruction, since the challenge itself is part of the transcript.
-/
theorem all_openings_private_iff_unique {S A : Type*}
    (valid : S → (Fin n → A) → Prop) :
    (∀ i, PerfectWitnessPrivacy valid (openingView i)) ↔
      ∀ s w₁ w₂, valid s w₁ → valid s w₂ → w₁ = w₂ := by
  -- Fix an $i$.
  apply Iff.intro;
  · intro h s w₁ w₂ hw₁ hw₂; ext i; exact h i s w₁ w₂ hw₁ hw₂;
  · intro h i s w₁ w₂ h₁ h₂ ; have := h s w₁ w₂ h₁ h₂ ; aesop;

/-- A concrete two-witness relation for which opening coordinate zero leaks the secret. -/
def bitWitnessValid (_statement : Unit) (_witness : Fin 1 → Bool) : Prop := True

/-
The naive opening protocol fails perfect witness privacy even for a one-bit witness.
-/
theorem bit_opening_leaks :
    ¬ PerfectWitnessPrivacy bitWitnessValid (openingView (0 : Fin 1)) := by
  -- By definition of `openingView`, we have that `openingView 0 (fun _ => false) ≠ openingView 0 (fun _ => true)`.
  simp [PerfectWitnessPrivacy, bitWitnessValid, openingView] at *;
  exists fun _ => Bool.true, fun _ => Bool.false

section Soundness

/-- Exact false-acceptance probability after `k` independent repetitions when one out
of `n` equally likely checks catches the error.  The definition is meaningful for
`n > 0`; callers carry that condition. -/
def singleBadFailure (n k : ℕ) : ℚ := (((n - 1 : ℕ) : ℚ) / n) ^ k

/-
With four possible checks and only one bad location, `k` repetitions have failure
probability `(3/4)^k`, not `(1/2)^k`.
-/
theorem four_check_failure (k : ℕ) :
    singleBadFailure 4 k = (3 / 4 : ℚ) ^ k := by
  unfold singleBadFailure; norm_num;

/-
For every positive number of repetitions, the preceding failure probability is
strictly greater than the advertised `2⁻ᵏ` bound.
-/
theorem four_check_not_binary_sound (k : ℕ) (hk : 0 < k) :
    (1 / 2 : ℚ) ^ k < singleBadFailure 4 k := by
  exact four_check_failure k ▸ pow_lt_pow_left₀ ( by norm_num ) ( by norm_num ) hk.ne'

/-
In fact no fixed repetition count gives a statement-size-independent `1/2`
soundness bound: choosing `n = 2k+2` leaves more than half the probability mass on
challenge sequences which miss a single bad location.
-/
theorem no_fixed_repetition_half_bound (k : ℕ) :
    (1 / 2 : ℚ) < singleBadFailure (2 * k + 2) k := by
  rcases k with ( _ | k ) <;> norm_num [ singleBadFailure ] at *;
  -- By Bernoulli's inequality, we have $(1 - \frac{1}{2(k+1)+2})^{k+1} \geq 1 - \frac{k+1}{2(k+1)+2}$.
  have h_bernoulli : ((2 * (k + 1) + 1) / (2 * (k + 1) + 2 : ℚ)) ^ (k + 1) ≥ 1 - (k + 1) / (2 * (k + 1) + 2) := by
    have h_bernoulli : ∀ x : ℚ, 0 ≤ x ∧ x ≤ 1 → ∀ n : ℕ, (1 - x) ^ n ≥ 1 - n * x := by
      exact fun x hx n => by induction n <;> norm_num [ pow_succ' ] ; nlinarith [ mul_self_nonneg x ] ;
    convert h_bernoulli ( 1 / ( 2 * ( k + 1 ) + 2 ) ) ⟨ by positivity, by rw [ div_le_iff₀ ] <;> linarith ⟩ ( k + 1 ) using 1 <;> norm_num ; ring;
    · -- Let's simplify the expression.
      field_simp
      ring;
    · ring;
  exact lt_of_lt_of_le ( by rw [ sub_div', div_lt_div_iff₀ ] <;> nlinarith ) h_bernoulli

/-
Standard independent repetition *does* yield `2⁻ᵏ` once a genuine one-round
soundness bound `p ≤ 1/2` has first been established.
-/
theorem binary_soundness_amplification (p : ℚ) (hp0 : 0 ≤ p)
    (hp : p ≤ 1 / 2) (k : ℕ) :
    p ^ k ≤ (1 / 2 : ℚ) ^ k := by
  gcongr

end Soundness

section Masking

/-- Boolean one-time-pad masking. -/
def mask (message randomness : Bool) : Bool := xor message randomness

/-
For each message and alleged masked value there is exactly one randomness bit
which produces it.  This is the finite counting core of perfect secrecy.
-/
theorem mask_fiber_card (message ciphertext : Bool) :
    (Finset.univ.filter fun randomness : Bool =>
      mask message randomness = ciphertext).card = 1 := by
  cases message <;> cases ciphertext
  · apply Finset.card_eq_one.mpr
    exact ⟨false, by ext x; cases x <;> simp [mask]⟩
  · apply Finset.card_eq_one.mpr
    exact ⟨true, by ext x; cases x <;> simp [mask]⟩
  · apply Finset.card_eq_one.mpr
    exact ⟨true, by ext x; cases x <;> simp [mask]⟩
  · apply Finset.card_eq_one.mpr
    exact ⟨false, by ext x; cases x <;> simp [mask]⟩

/-
Uniform Boolean masking has a message-independent transcript distribution,
expressed as equality of every transcript fiber cardinality.
-/
theorem uniform_mask_perfect_privacy (m₁ m₂ ciphertext : Bool) :
    (Finset.univ.filter fun randomness : Bool =>
      mask m₁ randomness = ciphertext).card =
    (Finset.univ.filter fun randomness : Bool =>
      mask m₂ randomness = ciphertext).card := by
  rw [mask_fiber_card, mask_fiber_card]

/-
Correctness of opening the Boolean mask.
-/
theorem mask_open_correct (message randomness : Bool) :
    xor (mask message randomness) randomness = message := by
  cases message <;> cases randomness <;> simp [mask]

end Masking

end ZeroKnowledge