import Mathlib

/-!
# Zero-knowledge theorem proving: finite information-theoretic core

This file formalizes two independent facts about the proposed random-proof-line protocol.

1. Randomly opening an actual witness coordinate is perfectly witness-private exactly when
   all valid witnesses are equal. Thus merely seeing a random line is not, by itself, a
   zero-knowledge argument.
2. Independent repetition multiplies the accepting fractions. The advertised `2⁻ᵏ`
   soundness follows only when a single round already catches with probability at least
   one half. If there is just one bad line among `n`, the exact escape probability is
   `((n-1)/n)^k`.

The final section supplies a genuine perfect-hiding primitive: additive one-time-pad
commitments over `ZMod q` have a secret-independent distribution.
-/

namespace PhaseAZeroKnowledge

/-- Perfect witness-independence of a deterministic verifier view. -/
def PerfectWitnessPrivacy {S W V : Type*} (valid : S → W → Prop)
    (view : S → W → V) : Prop :=
  ∀ s w₁ w₂, valid s w₁ → valid s w₂ → view s w₁ = view s w₂

/-- The verifier view obtained by opening coordinate `i`. -/
def openingView {S A : Type*} (i : Fin n) (_statement : S)
    (witness : Fin n → A) : A := witness i

/-- Opening coordinate `i` is private precisely when that coordinate is fixed among
all valid witnesses for a statement. -/
theorem openingView_private_iff {S A : Type*} (valid : S → (Fin n → A) → Prop)
    (i : Fin n) :
    PerfectWitnessPrivacy valid (openingView i) ↔
      ∀ s w₁ w₂, valid s w₁ → valid s w₂ → w₁ i = w₂ i := by
  constructor <;> intro h <;> exact h

/-- If two valid witnesses differ at the challenged coordinate, opening it is not
perfectly witness-private. -/
theorem openingView_not_private {S A : Type*} (valid : S → (Fin n → A) → Prop)
    (i : Fin n) (s : S) (w₁ w₂ : Fin n → A)
    (h₁ : valid s w₁) (h₂ : valid s w₂) (hne : w₁ i ≠ w₂ i) :
    ¬ PerfectWitnessPrivacy valid (openingView i) := by
  exact fun h => hne (h s w₁ w₂ h₁ h₂)

/-- **Privacy characterization.** If every coordinate can be opened, coordinate
opening is perfectly witness-private exactly when each statement has at most one
valid witness. Randomizing the challenged coordinate does not remove this obstruction,
because the challenge is part of the transcript. -/
theorem all_openings_private_iff_unique {S A : Type*}
    (valid : S → (Fin n → A) → Prop) :
    (∀ i, PerfectWitnessPrivacy valid (openingView i)) ↔
      ∀ s w₁ w₂, valid s w₁ → valid s w₂ → w₁ = w₂ := by
  constructor
  · intro h s w₁ w₂ hw₁ hw₂
    funext i
    exact h i s w₁ w₂ hw₁ hw₂
  · intro h i s w₁ w₂ hw₁ hw₂
    exact congrFun (h s w₁ w₂ hw₁ hw₂) i

/-- A relation with two valid one-bit witnesses. -/
def bitWitnessValid (_statement : Unit) (_witness : Fin 1 → Bool) : Prop := True

/-- Concrete privacy failure for the naive line-opening protocol. -/
theorem bit_opening_leaks :
    ¬ PerfectWitnessPrivacy bitWitnessValid (openingView (0 : Fin 1)) := by
  apply openingView_not_private bitWitnessValid (0 : Fin 1) ()
      (fun _ => false) (fun _ => true)
  · trivial
  · trivial
  · decide

section Amplification

open Finset

/-- The accepting challenge vectors in independent repetition factor as a finite
Cartesian product. -/
theorem piFinset_card_eq_prod {k n : ℕ} (accept : Fin k → Finset (Fin n)) :
    (Fintype.piFinset accept).card = ∏ i, (accept i).card :=
  Fintype.card_piFinset accept

/-- If every round accepts at most `e` challenges, at most `e^k` challenge vectors
survive all rounds. -/
theorem repeated_accept_card_le {k n e : ℕ} (accept : Fin k → Finset (Fin n))
    (h : ∀ i, (accept i).card ≤ e) :
    (Fintype.piFinset accept).card ≤ e ^ k := by
  rw [piFinset_card_eq_prod]
  calc
    ∏ i, (accept i).card ≤ ∏ _i : Fin k, e :=
      Finset.prod_le_prod' (fun i _ => h i)
    _ = e ^ k := by simp

/-- Independent repetition turns a per-round accepting fraction `e/n` into the
geometric bound `(e/n)^k`. -/
theorem amplified_probability_le {k n e : ℕ} (accept : Fin k → Finset (Fin n))
    (h : ∀ i, (accept i).card ≤ e) :
    ((Fintype.piFinset accept).card : ℚ) / (n : ℚ) ^ k ≤ ((e : ℚ) / n) ^ k := by
  have hc := repeated_accept_card_le accept h
  rw [div_pow]
  gcongr
  exact_mod_cast hc

/-- The claimed `2⁻ᵏ` bound requires a genuine one-round half-soundness premise. -/
theorem amplified_half_soundness {k n e : ℕ} (hn : 0 < n) (he : 2 * e ≤ n)
    (accept : Fin k → Finset (Fin n)) (h : ∀ i, (accept i).card ≤ e) :
    ((Fintype.piFinset accept).card : ℚ) / (n : ℚ) ^ k ≤ (1 / 2) ^ k := by
  refine (amplified_probability_le accept h).trans ?_
  have hnq : (0 : ℚ) < n := by exact_mod_cast hn
  have hbase : (e : ℚ) / n ≤ 1 / 2 := by
    rw [div_le_div_iff₀ hnq (by norm_num)]
    have hcast : (2 : ℚ) * e ≤ n := by exact_mod_cast he
    linarith
  gcongr

/-- Escape probability when exactly one among `n` checks detects cheating. -/
def singleBadFailure (n k : ℕ) : ℚ := (((n - 1 : ℕ) : ℚ) / n) ^ k

/-- With four checks and one bad location, the error is `(3/4)^k`. -/
theorem four_check_failure (k : ℕ) :
    singleBadFailure 4 k = (3 / 4 : ℚ) ^ k := by
  norm_num [singleBadFailure]

/-- For every positive repetition count, `(3/4)^k` is strictly larger than
`(1/2)^k`; random line checking does not automatically yield binary soundness. -/
theorem four_check_not_binary_sound (k : ℕ) (hk : 0 < k) :
    (1 / 2 : ℚ) ^ k < singleBadFailure 4 k := by
  rw [four_check_failure]
  exact pow_lt_pow_left₀ (by norm_num) (by norm_num) hk.ne'

/-- No fixed repetition count yields a statement-size-independent one-half error
bound for a proof with a single bad location: `2k+2` locations already suffice to
keep escape probability above one half. -/
theorem no_fixed_repetition_half_bound (k : ℕ) :
    (1 / 2 : ℚ) < singleBadFailure (2 * k + 2) k := by
  rcases k with (_ | k) <;> norm_num [singleBadFailure] at *
  have hBernoulli :
      ((2 * (k + 1) + 1) / (2 * (k + 1) + 2 : ℚ)) ^ (k + 1) ≥
        1 - (k + 1) / (2 * (k + 1) + 2) := by
    have hb : ∀ x : ℚ, 0 ≤ x ∧ x ≤ 1 → ∀ n : ℕ,
        (1 - x) ^ n ≥ 1 - n * x := by
      exact fun x hx n => by
        induction n <;> norm_num [pow_succ']
        nlinarith [mul_self_nonneg x]
    convert hb (1 / (2 * (k + 1) + 2))
      ⟨by positivity, by rw [div_le_iff₀] <;> linarith⟩ (k + 1) using 1 <;>
      norm_num <;> ring
    · field_simp
      ring
  exact lt_of_lt_of_le (by rw [sub_div', div_lt_div_iff₀] <;> nlinarith) hBernoulli

end Amplification

section PerfectHiding

variable {q : ℕ} [NeZero q]

/-- Additive one-time-pad commitment distribution. -/
noncomputable def commitmentDistribution (secret : ZMod q) : PMF (ZMod q) :=
  PMF.map (fun mask => secret + mask) (PMF.uniformOfFintype (ZMod q))

/-- Mapping a uniform finite distribution through a bijection preserves it. -/
theorem map_uniform_of_bijective {α β : Type*} [Fintype α] [Fintype β]
    [Nonempty α] [Nonempty β] (f : α → β) (hf : Function.Bijective f) :
    PMF.map f (PMF.uniformOfFintype α) = PMF.uniformOfFintype β := by
  ext b
  rw [PMF.map_apply, PMF.uniformOfFintype_apply]
  obtain ⟨a, rfl⟩ := hf.surjective b
  rw [tsum_eq_single a]
  · simp [PMF.uniformOfFintype_apply, Fintype.card_congr (Equiv.ofBijective f hf)]
  · intro a' ha'
    have hne : f a ≠ f a' := fun h => ha' (hf.injective h.symm ▸ rfl)
    simp [hne]

/-- Uniform masking produces exactly the simulator's uniform distribution. -/
theorem commitmentDistribution_eq_uniform (secret : ZMod q) :
    commitmentDistribution secret = PMF.uniformOfFintype (ZMod q) := by
  unfold commitmentDistribution
  exact map_uniform_of_bijective _ (Equiv.addLeft secret).bijective

/-- **Perfect hiding.** Any two committed proof values induce identical verifier
views. This is the appropriate hiding fact absent from naive coordinate opening. -/
theorem commitment_perfect_hiding (left right : ZMod q) :
    commitmentDistribution left = commitmentDistribution right := by
  rw [commitmentDistribution_eq_uniform, commitmentDistribution_eq_uniform]

end PerfectHiding

end PhaseAZeroKnowledge