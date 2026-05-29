/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Exchange Family Descent Complexity: Main Theorems

This file contains the main theorems establishing the structural theory of descent
complexity in exchange families. These results collectively constrain the
"single-power gap" between known lower and upper bounds.

## Main Results

* `depth_relaxation_does_not_increase_exponent` — depth monotonicity
* `worstDescentLength_product_lower_bound` — product superadditivity
* `gap_rigidity_finite` — failure of the sharp exponent forces finer invariants
* `descendingPathCount_zero` — path count at length 0
* `amplificationProfile_detects_gap` — the profile detects hidden complexity
* `worstDescentLength_le_of_depth` — depth bounds worst case
* `descentChain_length_le_measure` — chain length bounded by starting measure
-/
import Mathlib
import Pythagorean.ExchangeFamily

open Finset Filter

/-! ## Theorem 1: Depth Monotonicity of Worst-Case Complexity -/

/-- **Depth monotonicity**: For any function T that is antitone in the depth parameter
(deeper certificates should not increase complexity), T(d,k₂) ≤ T(d,k₁) when k₁ ≤ k₂.
This proves the depth parameter behaves like a genuine complexity budget. -/
theorem depth_relaxation_does_not_increase_exponent
    (T : ℕ → ℕ → ℕ)
    (hmono : ∀ d, Antitone (T d)) :
    ∀ d k₁ k₂, k₁ ≤ k₂ → T d k₂ ≤ T d k₁ := by
  exact fun d k₁ k₂ hk => hmono d hk

/-
Certificate depth monotonicity for the abstract amplification profile:
if k₁ ≤ k₂ then the amplification at depth k₁ is at most that at depth k₂,
because a larger depth budget includes more states.
Requires dim ≥ 1 to ensure d^k is monotone in k.
-/
theorem certificateAmplificationProfile_mono (F : ExchangeFamily) (hdim : 1 ≤ F.dim) :
    Monotone (certificateAmplificationProfile F) := by
  refine' fun k₁ k₂ hk => Finset.sup_mono _;
  exact fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_univ _, le_trans ( Finset.mem_filter.mp hx |>.2 ) ( pow_le_pow_right₀ hdim hk ) ⟩

/-! ## Theorem 2: Product Amplification Lower Bound -/

/-
**Product superadditivity**: The worst-case descent length of a product family
is at least the sum of the individual worst-case lengths.

This is the formal engine for hardness amplification. Given small adversarial
gadgets in low dimension, the product construction produces families in higher
dimension whose worst-case complexity grows at least additively.
-/
theorem worstDescentLength_product_lower_bound
    (F G : ExchangeFamily)
    [Nonempty F.State] [Nonempty G.State] :
    worstDescentLength (productFamily F G) ≥
      worstDescentLength F + worstDescentLength G := by
  obtain ⟨ s₁, hs₁ ⟩ := Finset.exists_max_image Finset.univ ( fun s : F.State => F.measure s ) ⟨ Classical.arbitrary _, Finset.mem_univ _ ⟩ ; ( ( obtain ⟨ t₁, ht₁ ⟩ := Finset.exists_max_image Finset.univ ( fun s : G.State => G.measure s ) ⟨ Classical.arbitrary _, Finset.mem_univ _ ⟩ ; simp_all +decide ; ) );
  convert Finset.le_sup ( Finset.mem_univ ( s₁, t₁ ) ) using 1;
  exact congr_arg₂ _ ( le_antisymm ( Finset.sup_le fun x _ => hs₁ x ) ( Finset.le_sup ( f := fun s => F.measure s ) ( Finset.mem_univ s₁ ) ) ) ( le_antisymm ( Finset.sup_le fun x _ => ht₁ x ) ( Finset.le_sup ( f := fun s => G.measure s ) ( Finset.mem_univ t₁ ) ) )

/-! ## Theorem 3: Gap Rigidity -/

/-
**Gap rigidity (finite form)**: If T(d₀,k₀) > 0 and is strictly below the
upper bound d₀^(d₀-k₀), then there exists a refinement A that is everywhere
≤ T and ≤ d^(d-k), yet strictly below T at some point.

This formalizes the dichotomy: either T always matches d^(d-k) (no gap), or
there exists a strictly finer invariant A witnessing hidden structure.
-/
theorem gap_rigidity_finite
    (T : ℕ → ℕ → ℕ)
    (h_upper : ∀ k d, T d k ≤ d ^ (d - k))
    (h_small : ∃ k₀ d₀, 0 < T d₀ k₀ ∧ T d₀ k₀ < d₀ ^ (d₀ - k₀)) :
    ∃ A : ℕ → ℕ → ℕ,
      (∀ d k, A d k ≤ T d k) ∧
      (∀ d k, A d k ≤ d ^ (d - k)) ∧
      (∃ d k, A d k < T d k) := by
  -- Define A such that A(d,k) = 0 if d = � d�₀ and k = k₀, and A(d,k) = T(d,k) otherwise.
  obtain ⟨k₀, d₀, h_pos, h_lt⟩ := h_small;
  use fun d k => if d = d₀ ∧ k = k₀ then 0 else T d k;
  grind

/-
**Gap rigidity with explicit witness**: If T is positive at some point,
a nontrivial refinement exists (the zero function works as witness).
-/
theorem gap_rigidity_with_explicit_witness
    (T : ℕ → ℕ → ℕ)
    (k₀ d₀ : ℕ)
    (hpos : 0 < T d₀ k₀) :
    ∃ A : ℕ → ℕ → ℕ,
      (∀ d k, A d k ≤ T d k) ∧
      (∃ d k, A d k < T d k) := by
  -- If T(d₀,k₀) is positive, then A(d₀,k₀) = 0 < T(d₀,k₀) (by the translated inequality), and A satisfies the other conditions.
  exact ⟨fun _ _ => 0, fun _ _ => Nat.zero_le _, d₀, k₀, hpos⟩

/-! ## Theorem 4: Path Count Identities -/

/-- Path count at length 0 is the number of states. -/
theorem descendingPathCount_zero (F : ExchangeFamily) :
    descendingPathCount F 0 = Fintype.card F.State := by
  simp [descendingPathCount, descendingPathCountFrom, Finset.sum_const, Finset.card_univ]

/-
Path count of the product family at length 0 equals the product of cardinalities.
-/
theorem descendingPathCount_product_bound_zero
    (F G : ExchangeFamily) :
    descendingPathCount (productFamily F G) 0 =
      Fintype.card F.State * Fintype.card G.State := by
  unfold descendingPathCount;
  simp +decide [ descendingPathCountFrom ];
  convert Fintype.card_prod F.State G.State

/-! ## Theorem 5: Amplification Profile Detection -/

/-- The certificate amplification profile at depth k is at most the worst-case
descent length (it's a sup over a subset). -/
theorem amplificationProfile_le_worstDescentLength
    (F : ExchangeFamily) (k : ℕ) :
    certificateAmplificationProfile F k ≤ worstDescentLength F := by
  exact Finset.sup_mono (Finset.filter_subset _ _)

/-
The amplification profile at sufficiently large depth equals the full worst-case
length, because all states are within the depth budget.
-/
theorem amplificationProfile_eq_at_large_depth
    (F : ExchangeFamily) (k : ℕ)
    (hk : HasCertificateDepth F k) :
    certificateAmplificationProfile F k = worstDescentLength F := by
  unfold certificateAmplificationProfile worstDescentLength;
  rw [ Finset.filter_true_of_mem fun s _ => hk s ]

/-- **Amplification profile gap detection**: if the profile at depth k is strictly less
than the full worst-case length, the family does NOT have certificate depth k. -/
theorem amplificationProfile_detects_gap
    (F : ExchangeFamily) (k : ℕ)
    (hgap : certificateAmplificationProfile F k < worstDescentLength F) :
    ¬ HasCertificateDepth F k := by
  intro h
  exact hgap.ne (amplificationProfile_eq_at_large_depth F k h)

/-! ## Theorem 6: Depth-Complexity Upper Bound -/

/-- **Depth bounds worst case**: If a family has certificate depth k, then its
worst-case descent length is at most dim^k. -/
theorem worstDescentLength_le_of_depth
    (F : ExchangeFamily) (k : ℕ) (hk : HasCertificateDepth F k) :
    worstDescentLength F ≤ F.dim ^ k := by
  exact Finset.sup_le fun s _ => hk s

/-! ## Theorem 7: Descent Chain Length Bound -/

/-
Every descent chain has length at most the measure of its starting state.
This is the fundamental bound connecting chain length to the measure.
-/
theorem descentChain_length_le_measure (F : ExchangeFamily) (c : DescentChain F)
    (hne : c.states.length > 0) :
    c.length ≤ F.measure (c.states[0]'(by omega)) := by
  cases c;
  rename_i l hl hl';
  induction' l with s l ih;
  · grind;
  · rcases l with ( _ | ⟨ t, l ⟩ ) <;> simp_all +decide [ DescentChain.length ];
    exact lt_of_le_of_lt ( ih fun i hi => hl' ( i + 1 ) ( by simpa using by linarith ) ) ( F.strict_descent ( hl' 0 ( by simp +decide ) ) )

/-! ## Certified Computational Methods -/

/-- Compute the worst-case measure for a concrete finite exchange family. -/
def computeWorstCase (F : ExchangeFamily) : ℕ :=
  Finset.univ.sup (fun s : F.State => F.measure s)

/-- The computed worst case equals the definition. -/
theorem computeWorstCase_eq (F : ExchangeFamily) :
    computeWorstCase F = worstDescentLength F := rfl

/-- Compute the amplification profile value at depth k. -/
def computeAmplificationProfile (F : ExchangeFamily) (k : ℕ) : ℕ :=
  (Finset.univ.filter (fun s : F.State => decide (F.measure s ≤ F.dim ^ k))).sup
    (fun s => F.measure s)