import Mathlib
import Computation.InformationTheory.ReversibleSortingBennett
import Computation.InformationTheory.ReversibleTropicalThermodynamics

/-!
# Finite object entropy and information loss

A map on the objects of two finite categories is, probabilistically, a deterministic
channel fed by the uniform distribution on its source.  This chapter separates two
quantities which coincide only in special cases:

* `objectEntropy f` is the Shannon entropy of the output object;
* `fiberLoss f` is the expected logarithm of the size of the observed fiber.

Their sum is the logarithm of the number of source objects.  Thus a uniform map with
`k` source objects above each of its `m` attained outputs has output entropy `log m`
and information loss `log k = log (|α|/m)`.  This distinction corrects the tempting
but inconsistent assignment of the latter formula to output entropy.

These definitions concern identification of objects.  They do not characterize
faithfulness of a functor, which is injectivity on morphism maps rather than on objects.
-/

noncomputable section

open Finset BigOperators Function

namespace FunctorialEntropy

/-- The fiber of a finite object map above an output. -/
def fiber {α β : Type*} [Fintype α] [DecidableEq β] (f : α → β) (b : β) : Finset α :=
  Finset.univ.filter fun a => f a = b

/-- Probability of observing `b` after choosing a source object uniformly. -/
def outputProb {α β : Type*} [Fintype α] [DecidableEq β]
    (f : α → β) (b : β) : ℝ :=
  (fiber f b).card / Fintype.card α

/-- Shannon entropy of the pushforward of the uniform distribution on source objects. -/
def objectEntropy {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) : ℝ :=
  -∑ b, outputProb f b * Real.log (outputProb f b)

/-- Expected information still needed to identify the source once its image is known. -/
def fiberLoss {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) : ℝ :=
  ∑ b, outputProb f b * Real.log (fiber f b).card

/-
Fiber probabilities form a distribution when the source is nonempty.
-/
theorem outputProb_isDistribution {α β : Type*} [Fintype α] [Nonempty α]
    [Fintype β] [DecidableEq β] (f : α → β) :
    IsDistribution (outputProb f) := by
  refine' ⟨ fun _ => div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ ), _ ⟩;
  unfold outputProb;
  rw [ ← Finset.sum_div, div_eq_iff ] <;> norm_cast <;> simp_all +decide;
  convert fiber_card_sum f

/-
The output entropy and expected fiber loss obey the deterministic chain rule.
-/
theorem entropy_loss_chain_rule {α β : Type*} [Fintype α] [Nonempty α]
    [Fintype β] [DecidableEq β] (f : α → β) :
    objectEntropy f + fiberLoss f = Real.log (Fintype.card α) := by
  convert congr_arg ( fun x : ℝ => x * Real.log ( Fintype.card α ) ) ( show ∑ b : β, outputProb f b = 1 from ?_ ) using 1;
  · unfold objectEntropy fiberLoss outputProb;
    rw [ Finset.sum_mul _ _ _ ] ; rw [ ← Finset.sum_neg_distrib ] ; rw [ ← Finset.sum_add_distrib ] ; refine' Finset.sum_congr rfl fun b _ => _ ; by_cases h : ( fiber f b ).card = 0 <;> simp +decide [ h, Real.log_div ] ; ring;
  · ring;
  · convert outputProb_isDistribution f |>.2

/-
Injective object maps lose no information.
-/
theorem fiberLoss_eq_zero_of_injective {α β : Type*} [Fintype α]
    [Fintype β] [DecidableEq β] (f : α → β) (hf : Injective f) :
    fiberLoss f = 0 := by
  refine' Finset.sum_eq_zero fun b _ => _;
  by_cases h : ∃ a : α, f a = b <;> simp_all +decide [ fiber ];
  exact Or.inr <| Or.inr <| Or.inl <| Finset.card_eq_one.mpr <| by obtain ⟨ a, rfl ⟩ := h; exact ⟨ a, by aesop ⟩ ;

/-
Conversely, zero expected fiber loss forces injectivity on source objects.
-/
theorem injective_of_fiberLoss_eq_zero {α β : Type*} [Fintype α]
    [Nonempty α] [Fintype β] [DecidableEq β] (f : α → β)
    (hzero : fiberLoss f = 0) :
    Injective f := by
  contrapose! hzero; simp_all +decide [ fiberLoss ] ;
  -- Since $f$ is not injective, there exist $x \neq y$ such that $f(x) = f(y)$.
  obtain ⟨x, y, hxy⟩ : ∃ x y : α, x ≠ y ∧ f x = f y := by
    simpa [ Function.Injective, and_comm ] using hzero;
  refine' ne_of_gt ( lt_of_lt_of_le _ ( Finset.single_le_sum ( fun b _ => _ ) ( Finset.mem_univ ( f x ) ) ) ) <;> simp_all +decide [ outputProb, fiber ];
  · exact mul_pos ( div_pos ( Nat.cast_pos.mpr ( Finset.card_pos.mpr ⟨ x, by aesop ⟩ ) ) ( Nat.cast_pos.mpr ( Fintype.card_pos ) ) ) ( Real.log_pos ( Nat.one_lt_cast.mpr ( Finset.one_lt_card.mpr ⟨ x, by aesop, y, by aesop ⟩ ) ) );
  · exact mul_nonneg ( div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ ) ) ( Real.log_natCast_nonneg _ )

/-
For nonempty finite sources, object-level information loss vanishes exactly for
object-injective maps.  This is deliberately not stated in terms of categorical
faithfulness.
-/
theorem fiberLoss_eq_zero_iff_injective {α β : Type*} [Fintype α]
    [Nonempty α] [Fintype β] [DecidableEq β] (f : α → β) :
    fiberLoss f = 0 ↔ Injective f := by
  exact ⟨ injective_of_fiberLoss_eq_zero f, fiberLoss_eq_zero_of_injective f ⟩

/-
A uniform `k`-to-one map has expected information loss `log k`.
-/
theorem fiberLoss_of_uniform_fibers {α β : Type*} [Fintype α] [Nonempty α]
    [Fintype β] [DecidableEq β] (f : α → β) (k : ℕ)
    (huniform : ∀ b, b ∈ Finset.image f Finset.univ → (fiber f b).card = k) :
    fiberLoss f = Real.log k := by
  by_cases hk : k = 0;
  · simp_all +decide [ Finset.ext_iff, fiber ];
    exact False.elim ( huniform ( Classical.arbitrary α ) ( Classical.arbitrary α ) rfl );
  · convert congr_arg ( · * Real.log k ) ( show ∑ b : β, outputProb f b = 1 from ?_ ) using 1;
    · rw [ Finset.sum_mul _ _ _ ];
      refine' Finset.sum_congr rfl fun b hb => _;
      by_cases hb' : b ∈ Finset.image f Finset.univ <;> simp_all +decide [ outputProb ];
      · aesop;
      · exact Or.inr ( Finset.eq_empty_of_forall_notMem fun x hx => hb' x <| Finset.mem_filter.mp hx |>.2 );
    · ring;
    · convert outputProb_isDistribution f |>.2

/-
A uniform map has output entropy equal to the logarithm of the number of attained
outputs, not the logarithm of its fiber size.
-/
theorem objectEntropy_of_uniform_fibers {α β : Type*} [Fintype α] [Nonempty α]
    [Fintype β] [DecidableEq β] (f : α → β) (k : ℕ)
    (huniform : ∀ b, b ∈ Finset.image f Finset.univ → (fiber f b).card = k) :
    objectEntropy f = Real.log (Finset.card (Finset.image f Finset.univ)) := by
  have h_card : (Fintype.card α : ℝ) = (Finset.card (Finset.image f Finset.univ) : ℝ) * k := by
    have h_card : (Fintype.card α : ℝ) = ∑ b ∈ Finset.image f Finset.univ, (fiber f b).card := by
      simp +decide [ fiber ];
      rw_mod_cast [ Fintype.card_eq_sum_ones, Finset.sum_image' ] ; aesop;
    rw [ h_card, Finset.sum_congr rfl huniform, Finset.sum_const, nsmul_eq_mul, Nat.cast_mul ];
    norm_cast;
  by_cases hk : k = 0;
  · aesop;
  · have h_chain : objectEntropy f + fiberLoss f = Real.log (Fintype.card α) := by
      convert entropy_loss_chain_rule f using 1
    have h_fiberLoss : fiberLoss f = Real.log k := by
      convert fiberLoss_of_uniform_fibers f k huniform using 1
    have h_card : (Fintype.card α : ℝ) = (Finset.card (Finset.image f Finset.univ) : ℝ) * k := by
      convert h_card using 1
    have h_log : Real.log (Fintype.card α) = Real.log (Finset.card (Finset.image f Finset.univ)) + Real.log k := by
      rw [ h_card, Real.log_mul ( Nat.cast_ne_zero.mpr <| Nat.ne_of_gt <| Finset.card_pos.mpr ⟨ f ( Classical.arbitrary α ), Finset.mem_image_of_mem _ <| Finset.mem_univ _ ⟩ ) ( Nat.cast_ne_zero.mpr hk ) ]
    linarith

/-
The constant map on a nonempty finite type erases all source-object information.
-/
theorem fiberLoss_constant {α β : Type*} [Fintype α] [Nonempty α]
    [Fintype β] [DecidableEq β] (b : β) :
    fiberLoss (fun _ : α => b) = Real.log (Fintype.card α) := by
  convert fiberLoss_of_uniform_fibers ( fun _ => b ) ( Fintype.card α ) _;
  · infer_instance;
  · simp +decide [ fiber ]

/-
The same constant map has zero output entropy.
-/
theorem objectEntropy_constant {α β : Type*} [Fintype α] [Nonempty α]
    [Fintype β] [DecidableEq β] (b : β) :
    objectEntropy (fun _ : α => b) = 0 := by
  have := entropy_loss_chain_rule ( fun _ : α => b );
  rw [ fiberLoss_constant ] at this ; linarith

/-
A concrete uniform channel with six source states, three outputs, and two states
per fiber loses `log 2` nats while retaining `log 3` nats.
-/
theorem modThree_channel :
    fiberLoss (fun i : Fin 6 => (⟨i.val % 3, Nat.mod_lt _ (by omega)⟩ : Fin 3)) = Real.log 2 ∧
    objectEntropy (fun i : Fin 6 => (⟨i.val % 3, Nat.mod_lt _ (by omega)⟩ : Fin 3)) = Real.log 3 := by
  constructor;
  · convert fiberLoss_of_uniform_fibers _ 2 _;
    · exact ⟨ 0 ⟩;
    · native_decide +revert;
  · convert objectEntropy_of_uniform_fibers _ 2 _;
    · exact ⟨ 0 ⟩;
    · simp +decide

-- !-- Lab Notes -- !--
-- Hypothesis: The proposed entropy should split into observable output entropy and
-- conditional information loss, with a finite chain rule linking the two.
-- Experiment: Constant, injective, and uniform many-to-one maps were compared.  A
-- six-to-three residue channel has three outputs of probability `1/3` and fibers of
-- size two.
-- Analysis: The original sum `-∑ p log p` measures output diversity.  It is `log m`
-- for `m` equally likely attained outputs.  The expected logarithmic fiber size is the
-- actual ambiguity remaining after observation and is `log k` for uniform fibers.
-- Critique: Object identification and categorical faithfulness are independent notions:
-- faithfulness constrains maps between hom-sets.  Infinite categories also require a
-- probability measure or a cardinal-valued replacement; counting all objects of `Top`
-- or `Set` does not define a probability distribution.
-- Synthesis: For finite object maps, the robust invariant is the pair
-- `(objectEntropy, fiberLoss)`, governed by an exact chain rule.  Zero loss detects
-- injectivity on objects, while uniform fibers yield the logarithmic quotient formula.
-- !-- end Lab Notes -- !--

end FunctorialEntropy