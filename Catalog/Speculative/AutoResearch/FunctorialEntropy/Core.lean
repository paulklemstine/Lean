import Mathlib

/-!
# Categorification of Entropy: The Information Loss of Functors

## Overview

This file develops a theory of **functorial entropy** — a measure of how much
information a function (or functor) between finite types destroys. The key insight
is that Shannon entropy naturally categorifies: every function f : α → β induces a
partition of α into fibers, and the entropy of this partition measures the
irreversible information loss.

## Main Definitions

* `fiberCard f b` — the cardinality of the fiber f⁻¹(b)
* `functorialEntropy f` — the functorial entropy H(f) = ∑_b (|f⁻¹(b)|/|α|) · log(|f⁻¹(b)|)
* `InformationChannel` — a structure packaging a function with its entropy properties
* `uniformFiber f k` — predicate that all nonempty fibers of f have size k

## Main Results

* `functorialEntropy_nonneg` — H(f) ≥ 0 for any function between finite types
* `functorialEntropy_eq_zero_iff_injective` — H(f) = 0 ↔ f is injective (main theorem)
* `functorialEntropy_uniform` — for uniform fibers of size k, H(f) = log(k)
* `functorialEntropy_id` — the identity has zero entropy (no information loss)
* `landauerCost_zero_of_bijective` — connection to Landauer's principle

## References

- Shannon, C.E. (1948). A mathematical theory of communication.
- Baez, Fong, Fritz (2014). A Bayesian characterization of relative entropy.
- Landauer, R. (1961). Irreversibility and heat generation in the computing process.
-/

noncomputable section

open Finset Function Real BigOperators Fintype

/-! ## §1. Fiber Cardinality -/

/-- The cardinality of the fiber of `f` over `b`: the number of elements in α
    that map to b under f. This is |f⁻¹(b)|. -/
def fiberCard {α β : Type*} [Fintype α] [DecidableEq β] (f : α → β) (b : β) : ℕ :=
  (Finset.univ.filter (fun a => f a = b)).card

/-- The fiber card is zero for elements not in the range of f. -/
theorem fiberCard_eq_zero_iff {α β : Type*} [Fintype α] [DecidableEq β]
    (f : α → β) (b : β) :
    fiberCard f b = 0 ↔ ∀ a, f a ≠ b := by
  simp [fiberCard, Finset.card_eq_zero, Finset.filter_eq_empty_iff]

/-- The fiber card is positive iff b is in the range of f. -/
theorem fiberCard_pos_iff {α β : Type*} [Fintype α] [DecidableEq β]
    (f : α → β) (b : β) :
    0 < fiberCard f b ↔ ∃ a, f a = b := by
  simp [fiberCard, Finset.card_pos, Finset.filter_nonempty_iff]

/-
The sum of all fiber cardinalities equals |α|.
-/
theorem sum_fiberCard {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) :
    ∑ b : β, fiberCard f b = Fintype.card α := by
  unfold fiberCard;
  simp +decide only [card_filter];
  rw [ Finset.sum_comm ] ; simp +decide

/-- For an injective function, every fiber has cardinality at most 1. -/
theorem fiberCard_le_one_of_injective {α β : Type*} [Fintype α] [DecidableEq β]
    (f : α → β) (hf : Injective f) (b : β) :
    fiberCard f b ≤ 1 := by
  simp only [fiberCard]
  rw [Finset.card_le_one]
  intro a₁ ha₁ a₂ ha₂
  simp at ha₁ ha₂
  exact hf (ha₁.trans ha₂.symm)

/-- For an injective function, fibers have size 0 or 1. -/
theorem fiberCard_of_injective {α β : Type*} [Fintype α] [DecidableEq β]
    (f : α → β) (hf : Injective f) (b : β) :
    fiberCard f b = 0 ∨ fiberCard f b = 1 := by
  have h := fiberCard_le_one_of_injective f hf b
  omega

/-! ## §2. Functorial Entropy -/

/-- **Functorial Entropy** of a function `f : α → β` between finite types.
    Defined as H(f) = ∑_{b ∈ β} (|f⁻¹(b)| / |α|) · log(|f⁻¹(b)|).

    This measures the information destroyed by f:
    - Each fiber of size 1 contributes 0 (no collapse)
    - Each fiber of size k > 1 contributes a positive amount proportional to log(k)
    - H(f) = 0 if and only if f is injective -/
def functorialEntropy {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) : ℝ :=
  ∑ b : β, (fiberCard f b : ℝ) / (Fintype.card α : ℝ) * Real.log (fiberCard f b : ℝ)

/-! ## §3. Non-negativity of Functorial Entropy -/

/-- Each summand of the functorial entropy is non-negative. -/
theorem functorialEntropy_summand_nonneg {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq β] (f : α → β) (b : β) :
    0 ≤ (fiberCard f b : ℝ) / (Fintype.card α : ℝ) * Real.log (fiberCard f b : ℝ) := by
  rcases Nat.eq_zero_or_pos (fiberCard f b) with h | h
  · simp [h]
  · apply mul_nonneg
    · apply div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)
    · exact Real.log_nonneg (by exact_mod_cast h)

/-- **Functorial entropy is non-negative**: H(f) ≥ 0. -/
theorem functorialEntropy_nonneg {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq β] (f : α → β) :
    0 ≤ functorialEntropy f :=
  Finset.sum_nonneg (fun b _ => functorialEntropy_summand_nonneg f b)

/-! ## §4. Zero Entropy Characterization -/

/-- If f is injective, then H(f) = 0: injective functions lose no information. -/
theorem functorialEntropy_of_injective {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq β] (f : α → β) (hf : Injective f) :
    functorialEntropy f = 0 := by
  unfold functorialEntropy
  apply Finset.sum_eq_zero
  intro b _
  rcases fiberCard_of_injective f hf b with h | h <;> simp [h]

/-
If H(f) = 0 and |α| > 0, then f is injective.
    The proof uses that each summand is non-negative, so the sum vanishing forces
    each summand to vanish, which forces each nonempty fiber to have size exactly 1.
-/
theorem injective_of_functorialEntropy_eq_zero {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq β] (f : α → β) (hcard : 0 < Fintype.card α)
    (h : functorialEntropy f = 0) :
    Injective f := by
  intro x y hxy;
  -- Since H(f) = 0, each term in the sum must be zero.
  have h_term_zero : ∀ b : β, (fiberCard f b : ℝ) / (Fintype.card α : ℝ) * Real.log (fiberCard f b : ℝ) = 0 := by
    exact fun b => le_antisymm ( le_trans ( Finset.single_le_sum ( fun b _ => functorialEntropy_summand_nonneg f b ) ( Finset.mem_univ b ) ) h.le ) ( functorialEntropy_summand_nonneg f b );
  -- Since the log term is zero, the fiber must have size 1.
  have h_fiber_size_one : ∀ b : β, fiberCard f b ≤ 1 := by
    intro b; specialize h_term_zero b; contrapose! h_term_zero;
    exact ne_of_gt ( mul_pos ( div_pos ( Nat.cast_pos.mpr ( pos_of_gt h_term_zero ) ) ( Nat.cast_pos.mpr hcard ) ) ( Real.log_pos ( Nat.one_lt_cast.mpr h_term_zero ) ) );
  exact Classical.not_not.1 fun h => absurd ( h_fiber_size_one ( f x ) ) ( by exact not_le_of_gt ( Finset.one_lt_card.2 ⟨ x, by aesop, y, by aesop ⟩ ) )

/-- **Main Theorem**: H(f) = 0 ↔ f is injective (for nonempty finite types). -/
theorem functorialEntropy_eq_zero_iff_injective {α β : Type*}
    [Fintype α] [Fintype β] [DecidableEq β] [Nonempty α]
    (f : α → β) :
    functorialEntropy f = 0 ↔ Injective f := by
  constructor
  · exact injective_of_functorialEntropy_eq_zero f Fintype.card_pos
  · exact functorialEntropy_of_injective f

/-! ## §5. Identity -/

/-- The identity function has zero entropy. -/
theorem functorialEntropy_id {α : Type*} [Fintype α] [DecidableEq α] :
    functorialEntropy (id : α → α) = 0 :=
  functorialEntropy_of_injective id injective_id

/-! ## §6. Uniform Fibers -/

/-- A function has **uniform fibers of size k** if every element in the codomain
    has either 0 or exactly k preimages. -/
def uniformFiber {α β : Type*} [Fintype α] [DecidableEq β]
    (f : α → β) (k : ℕ) : Prop :=
  ∀ b : β, fiberCard f b = 0 ∨ fiberCard f b = k

/-
The number of nonempty fibers times k equals |α| for uniform fibers.
-/
theorem uniformFiber_card_eq {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) (k : ℕ) (huf : uniformFiber f k) :
    (Finset.univ.filter (fun b : β => fiberCard f b ≠ 0)).card * k = Fintype.card α := by
  convert sum_fiberCard f;
  rw [ Finset.sum_congr rfl fun x hx => show fiberCard f x = if fiberCard f x = 0 then 0 else k by cases huf x <;> aesop ] ; simp +decide [ Finset.sum_ite ]

/-
**Uniform Fiber Entropy Formula**: When all nonempty fibers have size k,
    H(f) = log(k).
-/
theorem functorialEntropy_uniform {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq β] [Nonempty α]
    (f : α → β) (k : ℕ) (hk : 0 < k) (huf : uniformFiber f k) :
    functorialEntropy f = Real.log k := by
  -- Since each fiber cardinality is either 0 or k, the sum of the terms where the fiber has size k is equal to the sum of the terms where the fiber has size k.
  have h_sum : ∑ b : β, (fiberCard f b : ℝ) / (Fintype.card α : ℝ) * Real.log (fiberCard f b : ℝ) = ∑ b ∈ Finset.univ.filter (fun b => fiberCard f b ≠ 0), (k : ℝ) / (Fintype.card α : ℝ) * Real.log k := by
    rw [ Finset.sum_filter, Finset.sum_congr rfl ];
    intro b hb; specialize huf b; aesop;
  simp_all +decide;
  convert h_sum using 1;
  field_simp;
  rw [ mul_assoc, mul_comm, ← Nat.cast_mul, uniformFiber_card_eq f k huf ];
  ring

/-! ## §7. Constant Functions (Maximum Entropy) -/

/-
A constant function has maximum functorial entropy equal to log(|α|).
-/
theorem functorialEntropy_const {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq β] [Nonempty α]
    (b₀ : β) (hα : 1 < Fintype.card α) :
    functorialEntropy (fun _ : α => b₀) = Real.log (Fintype.card α) := by
  convert functorialEntropy_uniform _ ( Fintype.card α ) ( by linarith ) _;
  · infer_instance;
  · intro b; by_cases hb : b = b₀ <;> simp +decide [ hb, fiberCard ] ;
    aesop

/-! ## §8. Landauer Bridge -/

/-- The Landauer cost of a computation: kT · H(f). -/
def landauerCost {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (kT : ℝ) : ℝ :=
  kT * functorialEntropy f

/-- Reversible computations have zero Landauer cost. -/
theorem landauerCost_zero_of_bijective {α : Type*} [Fintype α] [DecidableEq α]
    [Nonempty α] (f : α → α) (kT : ℝ) (hf : Bijective f) :
    landauerCost f kT = 0 := by
  simp [landauerCost, functorialEntropy_of_injective f hf.injective]

/-- Zero Landauer cost at positive temperature implies injectivity. -/
theorem injective_of_landauerCost_zero {α : Type*} [Fintype α] [DecidableEq α]
    [Nonempty α] (f : α → α) (kT : ℝ) (hkT : 0 < kT)
    (h : landauerCost f kT = 0) :
    Injective f := by
  unfold landauerCost at h
  have hent : functorialEntropy f = 0 := by
    rcases mul_eq_zero.mp h with h | h
    · linarith
    · exact h
  exact (functorialEntropy_eq_zero_iff_injective f).mp hent

/-! ## §9. Information Channel Structure -/

/-- An **information channel** packages a function with its entropy profile.
    Novel categorical structure lifting scalar entropy into a structural property. -/
structure InformationChannel (α β : Type*) [Fintype α] [Fintype β] [DecidableEq β] where
  /-- The underlying function -/
  map : α → β
  /-- The entropy of the channel -/
  entropy : ℝ
  /-- The entropy equals the functorial entropy -/
  entropy_eq : entropy = functorialEntropy map
  /-- The entropy is non-negative -/
  entropy_nonneg : 0 ≤ entropy

/-- Construct an information channel from a function. -/
def InformationChannel.ofFun {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) : InformationChannel α β where
  map := f
  entropy := functorialEntropy f
  entropy_eq := rfl
  entropy_nonneg := functorialEntropy_nonneg f

/-- An information channel is lossless if its entropy is zero. -/
def InformationChannel.isLossless {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (ch : InformationChannel α β) : Prop :=
  ch.entropy = 0

/-- A lossless channel has an injective underlying function. -/
theorem InformationChannel.injective_of_lossless {α β : Type*}
    [Fintype α] [Fintype β] [DecidableEq β] [Nonempty α]
    (ch : InformationChannel α β) (h : ch.isLossless) :
    Injective ch.map := by
  rw [InformationChannel.isLossless, ch.entropy_eq] at h
  exact (functorialEntropy_eq_zero_iff_injective ch.map).mp h

/-! ## §10. Strict Positivity -/

/-- If f is not injective, then H(f) > 0. -/
theorem functorialEntropy_pos_of_not_injective {α β : Type*}
    [Fintype α] [Fintype β] [DecidableEq β] [Nonempty α]
    (f : α → β) (hf : ¬Injective f) :
    0 < functorialEntropy f := by
  rcases (functorialEntropy_nonneg f).lt_or_eq with h | h
  · exact h
  · exfalso
    exact hf ((functorialEntropy_eq_zero_iff_injective f).mp h.symm)

/-! ## §11. Upper Bound -/

/-
**Upper bound**: H(f) ≤ log(|α|) for any function f : α → β.
-/
theorem functorialEntropy_le_log_card {α β : Type*}
    [Fintype α] [Fintype β] [DecidableEq β] (f : α → β) :
    functorialEntropy f ≤ Real.log (Fintype.card α) := by
  by_contra! h_contra;
  refine' h_contra.not_ge _;
  refine' le_trans ( Finset.sum_le_sum _ ) _;
  use fun b => ( fiberCard f b : ℝ ) / Fintype.card α * Real.log ( Fintype.card α );
  · intro b _; by_cases hb : fiberCard f b = 0 <;> simp_all +decide;
    gcongr;
    exact Finset.card_le_univ _;
  · rw [ ← Finset.sum_mul _ _ _ ];
    rw [ ← Finset.sum_div, div_mul_eq_mul_div, div_le_iff₀ ] <;> norm_cast <;> norm_num [ sum_fiberCard ];
    · linarith;
    · by_cases h : Fintype.card α = 0;
      · simp_all +decide [ functorialEntropy ];
      · exact Nat.pos_of_ne_zero h

/-! ## §12. Conjecture: Composition Superadditivity -/

/-- **Conjecture (Composition Superadditivity)**: For surjective f and any g,
    H(g) ≤ H(g ∘ f). Pre-composing with a surjection cannot decrease information loss.

    Testable prediction: For f : Fin 6 → Fin 3 (each fiber size 2) and
    g : Fin 3 → Fin 2 (fiber sizes 2,1), verify H(g ∘ f) ≥ H(g). -/
theorem composition_entropy_conjecture {α β γ : Type*}
    [Fintype α] [Fintype β] [Fintype γ] [DecidableEq β] [DecidableEq γ]
    [Nonempty α] [Nonempty β]
    (f : α → β) (g : β → γ) (hf : Surjective f) :
    functorialEntropy g ≤ functorialEntropy (g ∘ f) := by
  sorry

end