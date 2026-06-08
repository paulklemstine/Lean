import Mathlib
import Speculative.ProofPhaseTransitions.Defs

/-!
# Monotone Provability Systems: Core Theorems

This file proves the main theorems establishing proof phase transitions in finite
monotone provability systems:

1. **Monotonicity** (`Provable.monotone`): Provability is monotone in the axiom set.
2. **Counting identity** (`provableCount_eq_filter_card`): The provable count equals
   a sum of indicators over the power set.
3. **Union bound** (`provableCount_le_sum_cert_supersets`): Upper bound on provable
   count via certificate sizes.
4. **Certificate size upper bound** (`provableCount_le_card_cert_mul`): If all
   certificates have size ≥ k, the number of provable subsets is bounded.
5. **Monotone Boolean function correspondence** (`provable_iff_monotone_indicator`):
   Provability corresponds to a monotone Boolean function.

## Mathematical Context

These results establish that proof emergence from random axioms obeys the same
mathematical laws as network reliability, bootstrap percolation, and monotone
Boolean function thresholds. The key insight is that every finite proof system
induces a reliability polynomial whose coefficients encode the combinatorial
structure of proof certificates.
-/

open Finset BigOperators

namespace MonotoneProvabilitySystem

variable {α τ : Type*} [Fintype α] [DecidableEq α]

/-! ### Theorem 1: Monotonicity of Provability -/

/-
**Provability is monotone**: if a target is provable from axiom set `A`, and `A ⊆ B`,
then the target is also provable from `B`. This is the foundational property that places
proof emergence within the theory of monotone events.

Mathematically: if `∃ S ∈ Cert(t), S ⊆ A` and `A ⊆ B`, then `∃ S ∈ Cert(t), S ⊆ B`.
-/
theorem Provable.monotone (M : MonotoneProvabilitySystem α τ) (t : τ) :
    Monotone (fun A : Finset α => M.Provable t A) := by
  -- To prove monotonicity, we take two axiom sets $A$ and $B$ such that $A \subseteq B$.
  -- By definition of $M.Provable t A$, there exists some certificate $S \in M.Cert t$ such that $S \subseteq A$.
  -- Since $A \subseteq B$, we also have $S \subseteq B$, so $M.Provable t B$.
  intro A B hAB
  intro htA
  obtain ⟨S, hS⟩ := htA;
  exact ⟨ S, hS.1, hS.2.trans hAB ⟩

/-
Equivalent formulation: adding an axiom preserves provability.
-/
theorem Provable.insert (M : MonotoneProvabilitySystem α τ) (t : τ)
    (A : Finset α) (a : α) (h : M.Provable t A) :
    M.Provable t (insert a A) := by
  -- By the monotonicity of provability, if $t$ is provable from $A$, then it is also provable from any superset of $A$.
  apply Provable.monotone M t (Finset.subset_insert a A) h

/-! ### Theorem 2: Counting Identity -/

/-
The provable count equals the cardinality of the filter of provable subsets.
This is a tautological-looking statement that serves as the bridge between the
abstract provability predicate and concrete counting.
-/
theorem provableCount_eq_filter_card (M : MonotoneProvabilitySystem α τ) (t : τ) :
    M.provableCount t =
      ((Finset.univ : Finset (Finset α)).filter (fun A => M.Provable t A)).card := by
  -- The `provableCount` is defined as the cardinality of the filter of provable subsets.
  -- So the statement is just unfolding the definition and simplification.
  dsimp [provableCount]

/-
The provable count equals a sum of indicators over the power set.
-/
theorem provableCount_eq_sum_indicator (M : MonotoneProvabilitySystem α τ) (t : τ) :
    (M.provableCount t : ℤ) =
      ∑ A ∈ (Finset.univ : Finset (Finset α)),
        if M.Provable t A then (1 : ℤ) else 0 := by
  -- By definition of `provableCount`, we know that
  simp [MonotoneProvabilitySystem.provableCount]

/-! ### Theorem 3: Certificate Union Bound -/

/-
For each certificate `S`, the number of supersets of `S` within the full axiom pool
is `2^(n - |S|)` where `n = |α|`.
-/
theorem card_supersets_of_cert (S : Finset α) :
    ((Finset.univ : Finset (Finset α)).filter (fun A => S ⊆ A)).card =
      2 ^ (Fintype.card α - S.card) := by
  -- The set of subsets of α that contain S is in bijection with the power set of the complement of S.
  have h_bij : Finset.filter (fun A => S ⊆ A) (Finset.powerset (Finset.univ : Finset α)) = Finset.image (fun T => S ∪ T) (Finset.powerset (Finset.univ \ S)) := by
    ext; simp +decide [ Finset.subset_iff ] ;
    exact ⟨ fun h => ⟨ ‹_› \ S, fun x hx => by aesop, by aesop ⟩, by aesop ⟩;
  convert congr_arg Finset.card h_bij using 1;
  rw [ Finset.card_image_of_injOn, Finset.card_powerset ];
  · simp +decide [ Finset.card_sdiff ];
  · intro T hT T' hT' h_eq; simp_all +decide [ Finset.ext_iff ] ;
    intro a; specialize h_eq a; replace hT := @hT a; replace hT' := @hT' a; aesop;

/-
**Union bound on provable count**: the number of axiom subsets making `t` provable
is at most the sum over certificates of `2^(n - |S|)`.

This is the finite-counting analogue of `Pr[t provable] ≤ ∑_S p^|S|`.
-/
theorem provableCount_le_sum_cert_supersets (M : MonotoneProvabilitySystem α τ) (t : τ) :
    M.provableCount t ≤
      ∑ S ∈ M.Cert t, 2 ^ (Fintype.card α - S.card) := by
  have h_subset : Finset.filter (fun A => M.Provable t A) (Finset.univ : Finset (Finset α)) ⊆ Finset.biUnion (M.Cert t) (fun S => Finset.filter (fun A => S ⊆ A) (Finset.univ : Finset (Finset α))) := by
    intro A hA; unfold MonotoneProvabilitySystem.Provable at hA; aesop;
  refine' le_trans ( Finset.card_le_card h_subset ) _;
  exact le_trans ( Finset.card_biUnion_le ) ( Finset.sum_le_sum fun S hS => by simpa using card_supersets_of_cert S |> le_of_eq )

/-! ### Theorem 4: Certificate Size Bound -/

/-
**Certificate-size upper bound**: if every certificate for `t` has size at least `k`,
then the provable count is at most `|Cert(t)| * 2^(n-k)`.

This is the key quantitative bound: it shows that proof emergence is controlled by
the minimal certificate size, which determines the threshold scale.
-/
theorem provableCount_le_card_cert_mul (M : MonotoneProvabilitySystem α τ) (t : τ) (k : ℕ)
    (hk : ∀ S ∈ M.Cert t, k ≤ S.card) :
    M.provableCount t ≤ (M.Cert t).card * 2 ^ (Fintype.card α - k) := by
  refine' le_trans ( provableCount_le_sum_cert_supersets M t ) _;
  exact le_trans ( Finset.sum_le_sum fun x hx => pow_le_pow_right₀ ( by decide ) ( Nat.sub_le_sub_left ( hk x hx ) _ ) ) ( by simp +decide )

/-! ### Theorem 5: Monotone Boolean Function Correspondence -/

/-- Helper: converting a Finset to its indicator function. -/
def toIndicator (A : Finset α) : α → Bool := fun a => a ∈ A

/-- Helper: converting an indicator function back to a Finset. -/
noncomputable def fromIndicator (f : α → Bool) : Finset α :=
  Finset.univ.filter (fun a => f a)

/-
The indicator-to-finset roundtrip.
-/
theorem fromIndicator_toIndicator (A : Finset α) :
    fromIndicator (toIndicator A) = A := by
  -- By definition of `fromIndicator` and `toIndicator`, we have `fromIndicator (toIndicator A) = A` because the indicator function of `A` is 1 for elements in `A` and 0 otherwise.
  ext a
  simp [fromIndicator, toIndicator]

/-
**Provability as a monotone Boolean function**: there exists a Boolean function `f`
such that `t` is provable from `A` iff `f(1_A) = true`, and `f` is monotone
(flipping any input from `false` to `true` cannot change the output from `true` to `false`).

This theorem formally places proof emergence within the framework of monotone Boolean
function theory, enabling the application of sharp-threshold results (Friedgut–Kalai,
Bourgain–Kalai–Kahn, etc.) to provability.
-/
theorem provable_iff_monotone_indicator (M : MonotoneProvabilitySystem α τ) (t : τ) :
    ∃ f : (α → Bool) → Bool,
      (∀ g h : α → Bool, (∀ a, g a ≤ h a) → f g ≤ f h) ∧
      (∀ A : Finset α, M.Provable t A ↔ f (toIndicator A) = true) := by
  refine' ⟨ fun g => decide ( M.Provable t ( Finset.univ.filter fun a => g a ) ), _, _ ⟩ <;> simp +decide;
  · intro g h hgh; by_cases hg : M.Provable t { a | g a = true } <;> by_cases hh : M.Provable t { a | h a = true } <;> simp +decide [ hg, hh ] ;
    exact hh ( by obtain ⟨ S, hS₁, hS₂ ⟩ := hg; exact ⟨ S, hS₁, fun a ha => by have := hS₂ ha; specialize hgh a; aesop ⟩ );
  · unfold toIndicator; aesop;

end MonotoneProvabilitySystem