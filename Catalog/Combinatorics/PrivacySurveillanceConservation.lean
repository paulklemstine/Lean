/-
Copyright (c) 2025 Privacy-Surveillance Conservation Law Project. All rights reserved.

# Privacy-Surveillance Conservation Law

## Bridge: Information Theory ↔ Privacy Theory ↔ Combinatorics

We formalize the **Privacy-Surveillance Conservation Law** for deterministic
observation functions on finite sets: for any function f : S → C between finite types,

  π(f) + σ(f) = n(n − 1)

where π(f) counts ordered pairs of distinct elements mapped to the same value
(privacy index), σ(f) counts ordered pairs mapped to different values (surveillance
index), and n = |S|.

## Main Results
* **Theorem 1** (Conservation Law): π(f) + σ(f) = n(n-1)
* **Theorem 2** (Fiber Decomposition): π(f) = Σ_c fib(c)(fib(c)-1)
* **Theorem 3** (Data Processing Inequality): post-processing never decreases privacy
* **Theorem 4** (Injective Characterization): π(f) = 0 ↔ f injective
* **Theorem 5** (Constant Characterization): σ(f) = 0 ↔ f constant (on Nonempty S)
* **Theorem 6** (Privacy Spectrum Refinement): the spectrum determines π(f)
* **Theorem 7** (Balanced Partition Minimality): balanced partitions minimize privacy
-/

import Mathlib

open Finset Function BigOperators

variable {S C D : Type*} [Fintype S] [DecidableEq S] [Fintype C] [DecidableEq C]

/-! ## Section 1: Core Indices -/

/-- The **privacy index** of f: number of ordered pairs (s₁, s₂) with s₁ ≠ s₂
    that f cannot distinguish (mapped to the same code). -/
def privacyIndex (f : S → C) : ℕ :=
  ((Finset.univ ×ˢ Finset.univ).filter fun p : S × S => p.1 ≠ p.2 ∧ f p.1 = f p.2).card

/-- The **surveillance index** of f: number of ordered pairs (s₁, s₂) with s₁ ≠ s₂
    that f distinguishes (mapped to different codes). -/
def surveillanceIndex (f : S → C) : ℕ :=
  ((Finset.univ ×ˢ Finset.univ).filter fun p : S × S => p.1 ≠ p.2 ∧ f p.1 ≠ f p.2).card

/-- The **fiber** of f at c: all elements mapping to c. -/
def fiber (f : S → C) (c : C) : Finset S :=
  Finset.univ.filter fun s => f s = c

/-- Fiber cardinality. -/
def fiberCard (f : S → C) (c : C) : ℕ := (fiber f c).card

/-! ## Section 2: The Conservation Law -/

/-- **Lemma**: The set of ordered pairs of distinct elements decomposes into
    privacy pairs and surveillance pairs. -/
lemma privacy_surveillance_disjoint_union (f : S → C) :
    (Finset.univ ×ˢ Finset.univ).filter (fun p : S × S => p.1 ≠ p.2) =
    ((Finset.univ ×ˢ Finset.univ).filter (fun p : S × S => p.1 ≠ p.2 ∧ f p.1 = f p.2)) ∪
    ((Finset.univ ×ˢ Finset.univ).filter (fun p : S × S => p.1 ≠ p.2 ∧ f p.1 ≠ f p.2)) := by
  ext ⟨a, b⟩
  simp only [Finset.mem_filter, Finset.mem_product, Finset.mem_univ, true_and,
             Finset.mem_union]
  constructor
  · intro h
    by_cases heq : f a = f b
    · left; exact ⟨h, heq⟩
    · right; exact ⟨h, heq⟩
  · rintro (⟨h, _⟩ | ⟨h, _⟩) <;> exact h

omit [Fintype C] in
lemma privacy_surveillance_disjoint (f : S → C) :
    Disjoint
      ((Finset.univ ×ˢ Finset.univ).filter (fun p : S × S => p.1 ≠ p.2 ∧ f p.1 = f p.2))
      ((Finset.univ ×ˢ Finset.univ).filter (fun p : S × S => p.1 ≠ p.2 ∧ f p.1 ≠ f p.2)) := by
  rw [Finset.disjoint_filter]
  intro ⟨a, b⟩ _ ⟨_, h1⟩ ⟨_, h2⟩
  exact h2 h1

/-
Number of ordered pairs of distinct elements in S.
-/
lemma card_distinct_pairs :
    ((Finset.univ ×ˢ Finset.univ).filter (fun p : S × S => p.1 ≠ p.2)).card =
    Fintype.card S * (Fintype.card S - 1) := by
  rw [ Finset.card_filter ];
  erw [ Finset.sum_product ] ; simp +contextual [ Finset.filter_ne ];
  simp +decide [ Finset.sum_ite, Finset.filter_ne ]

/-
**Theorem 1: The Privacy-Surveillance Conservation Law.**
    For any observation function f : S → C,
      π(f) + σ(f) = |S| · (|S| − 1)

    Every pair of distinct states is either privacy-preserving or surveillance-accessible.
    This is the fundamental budget constraint of observation.
-/
theorem conservation_law (f : S → C) :
    privacyIndex f + surveillanceIndex f = Fintype.card S * (Fintype.card S - 1) := by
  convert congr_arg Finset.card ( privacy_surveillance_disjoint_union f ) using 1;
  · convert congr_arg Finset.card ( privacy_surveillance_disjoint_union f |> Eq.symm ) using 1;
    rw [ Finset.card_union_of_disjoint ( privacy_surveillance_disjoint f ) ];
    rfl;
  · rw [ ← privacy_surveillance_disjoint_union, card_distinct_pairs ]

/-! ## Section 3: Fiber Decomposition of Privacy -/

/-
The privacy index decomposes as a sum over fibers:
    π(f) = Σ_{c ∈ image(f)} fib(c) · (fib(c) − 1)

    Each fiber of size k contributes k(k-1) ordered pairs of indistinguishable elements.
-/
theorem privacy_fiber_decomposition (f : S → C) :
    privacyIndex f = ∑ c ∈ Finset.univ.image f,
      fiberCard f c * (fiberCard f c - 1) := by
  unfold privacyIndex;
  -- We can partition the privacy pairs by their shared image value c.
  have h_partition : ((Finset.univ ×ˢ Finset.univ).filter (fun p : S × S => p.1 ≠ p.2 ∧ f p.1 = f p.2)) = Finset.biUnion (Finset.univ.image f) (fun c => Finset.offDiag (fiber f c)) := by
    ext ⟨x, y⟩; simp [fiber];
    exact ⟨ fun h => ⟨ y, h.2, rfl, h.1 ⟩, by rintro ⟨ a, ha₁, ha₂, ha₃ ⟩ ; exact ⟨ ha₃, ha₁.trans ha₂.symm ⟩ ⟩;
  rw [ h_partition, Finset.card_biUnion ];
  · simp +decide [ fiberCard, mul_tsub ];
  · intro c hc d hd hcd; simp_all +decide [ Finset.disjoint_left, fiber ] ;

/-! ## Section 4: Extremal Characterizations -/

/-
**Theorem 4**: The privacy index is zero if and only if f is injective.
    Zero privacy = total surveillance = every pair is distinguishable.
-/
theorem privacy_zero_iff_injective (f : S → C) :
    privacyIndex f = 0 ↔ Function.Injective f := by
  simp +decide [ privacyIndex, Finset.ext_iff ];
  exact ⟨ fun h a b hab => Classical.not_not.1 fun h' => h a b h' hab, fun h a b hab => fun h' => hab ( h h' ) ⟩

/-
**Theorem 5**: The surveillance index is zero iff f is constant (on nonempty S).
    Zero surveillance = total privacy = no pair is distinguishable.
-/
theorem surveillance_zero_iff_constant [Nonempty S] (f : S → C) :
    surveillanceIndex f = 0 ↔ ∀ s₁ s₂ : S, f s₁ = f s₂ := by
  refine' ⟨ fun h s₁ s₂ => _, fun h => _ ⟩;
  · contrapose! h;
    exact ne_of_gt ( Finset.card_pos.mpr ⟨ ( s₁, s₂ ), by aesop ⟩ );
  · exact Finset.card_eq_zero.mpr ( Finset.filter_eq_empty_iff.mpr fun p hp => by aesop )

/-- Injective functions maximize the surveillance index. -/
theorem injective_max_surveillance (f : S → C) (hinj : Function.Injective f) :
    surveillanceIndex f = Fintype.card S * (Fintype.card S - 1) := by
  have h1 := conservation_law f
  have h2 := (privacy_zero_iff_injective f).mpr hinj
  omega

/-- Constant functions maximize the privacy index. -/
theorem constant_max_privacy [Nonempty S] (f : S → C) (hconst : ∀ s₁ s₂, f s₁ = f s₂) :
    privacyIndex f = Fintype.card S * (Fintype.card S - 1) := by
  have h1 := conservation_law f
  have h2 := (surveillance_zero_iff_constant f).mpr hconst
  omega

/-! ## Section 5: Data Processing Inequality -/

/-
**Theorem 3: Deterministic Data Processing Inequality.**
    If g = h ∘ f, then π(g) ≥ π(f).
    Post-processing can only merge fibers, never split them.
    Equivalently, post-processing can only decrease surveillance.
-/
theorem data_processing_inequality [Fintype D] [DecidableEq D]
    (f : S → C) (h : C → D) :
    privacyIndex f ≤ privacyIndex (h ∘ f) := by
  apply Finset.card_le_card;
  grind

/-- Corollary: post-processing can only decrease surveillance. -/
theorem surveillance_data_processing [Fintype D] [DecidableEq D]
    (f : S → C) (h : C → D) :
    surveillanceIndex (h ∘ f) ≤ surveillanceIndex f := by
  have h1 := conservation_law f
  have h2 := conservation_law (h ∘ f)
  have h3 := data_processing_inequality f h
  omega

/-! ## Section 6: Privacy Spectrum -/

/-- The **privacy spectrum** of f: the multiset of fiber sizes.
    This is the finest invariant of f's privacy structure up to relabeling.
    Two functions have the same privacy spectrum iff they induce the same
    partition structure on S (up to isomorphism). -/
noncomputable def privacySpectrum (f : S → C) : Multiset ℕ :=
  (Finset.univ.image f).val.map (fun c => fiberCard f c)

/-
The privacy spectrum determines the privacy index:
    π(f) = Σ_{k ∈ spectrum(f)} k(k-1).
-/
theorem spectrum_determines_privacy (f : S → C) :
    privacyIndex f = ((privacySpectrum f).map (fun k => k * (k - 1))).sum := by
  convert privacy_fiber_decomposition f using 1;
  unfold privacySpectrum; aesop;

/-
The privacy spectrum sums to |S|: fibers partition the domain.
-/
theorem spectrum_sum_eq_card (f : S → C) :
    (privacySpectrum f).sum = Fintype.card S := by
  have h_sum_fibers : ∑ c ∈ Finset.univ.image f, (Finset.univ.filter (fun s => f s = c)).card = Fintype.card S := by
    rw [ ← Finset.card_biUnion ];
    · convert Finset.card_univ ; aesop;
    · exact fun x hx y hy hxy => Finset.disjoint_left.mpr fun s hsx hsy => hxy <| by aesop;
  convert h_sum_fibers using 1

/-! ## Section 7: Fiber Refinement Ordering -/

/-- A function g **refines** f if f's fibers are unions of g's fibers.
    Equivalently: f = h ∘ g for some h. In the deterministic setting,
    refinement exactly captures the data processing ordering. -/
def Refines (g f : S → C) : Prop :=
  ∀ s₁ s₂ : S, g s₁ = g s₂ → f s₁ = f s₂

/-
Refinement implies privacy ordering: if g refines f (g is finer),
    then g has fewer privacy pairs. The coarser observation f has more collisions.
-/
theorem refines_privacy_ge (g f : S → C) (href : Refines g f) :
    privacyIndex g ≤ privacyIndex f := by
  exact Finset.card_le_card fun x hx => by unfold Refines at href; aesop;

/-! ## Section 8: Collision Probability and Privacy -/

/-- The **collision probability** of f: probability that two uniformly random
    distinct elements are mapped to the same value. This is π(f) / n(n-1). -/
noncomputable def collisionProbability (f : S → C) : ℚ :=
  if Fintype.card S ≤ 1 then 0
  else (privacyIndex f : ℚ) / (Fintype.card S * (Fintype.card S - 1) : ℚ)

/-
Collision probability is between 0 and 1.
-/
theorem collisionProbability_range (f : S → C) :
    0 ≤ collisionProbability f ∧ collisionProbability f ≤ 1 := by
  unfold collisionProbability;
  split_ifs <;> simp_all +decide [ Fintype.card_le_one_iff ];
  refine' ⟨ div_nonneg ( Nat.cast_nonneg _ ) ( mul_nonneg ( Nat.cast_nonneg _ ) ( sub_nonneg.mpr ( Nat.one_le_cast.mpr ( Fintype.card_pos_iff.mpr ⟨ Classical.choose ‹∃ x x_1 : S, ¬x = x_1› ⟩ ) ) ) ), div_le_one_of_le₀ _ ( mul_nonneg ( Nat.cast_nonneg _ ) ( sub_nonneg.mpr ( Nat.one_le_cast.mpr ( Fintype.card_pos_iff.mpr ⟨ Classical.choose ‹∃ x x_1 : S, ¬x = x_1› ⟩ ) ) ) ) ⟩;
  convert Nat.cast_le.mpr ( show privacyIndex f ≤ Fintype.card S * ( Fintype.card S - 1 ) from _ ) using 1;
  · cases h : Fintype.card S <;> simp_all +decide;
  · infer_instance;
  · infer_instance;
  · infer_instance;
  · exact conservation_law f ▸ Nat.le_add_right _ _

/-! ## Section 9: Surveillance Product Bound -/

/-- For composed observations on product spaces, the conservation law applies. -/
theorem surveillance_product_conservation
    {S₁ S₂ C₁ C₂ : Type*}
    [Fintype S₁] [DecidableEq S₁] [Fintype C₁] [DecidableEq C₁]
    [Fintype S₂] [DecidableEq S₂] [Fintype C₂] [DecidableEq C₂]
    (f₁ : S₁ → C₁) (f₂ : S₂ → C₂) :
    privacyIndex (fun p : S₁ × S₂ => (f₁ p.1, f₂ p.2)) +
    surveillanceIndex (fun p : S₁ × S₂ => (f₁ p.1, f₂ p.2)) =
    Fintype.card (S₁ × S₂) * (Fintype.card (S₁ × S₂) - 1) :=
  conservation_law _

/-! ## Section 10: Conjectures and Testable Predictions -/

/-
**Conjecture (Balanced Partition Minimality)**:
    Among all partitions of n elements into k nonempty parts,
    the balanced partition (parts differ by at most 1) minimizes
    Σ fᵢ(fᵢ - 1), i.e., minimizes the privacy index.

    **Testable prediction**: For n = 6, k = 3:
    - Balanced: [2,2,2] → Σ = 3·2 = 6
    - Unbalanced: [1,2,3] → Σ = 0 + 2 + 6 = 8 ≥ 6 ✓
    - Unbalanced: [1,1,4] → Σ = 0 + 0 + 12 = 12 ≥ 6 ✓
-/
theorem balanced_partition_minimizes_privacy
    (n k : ℕ) (hn : 2 ≤ n) (hk : 1 ≤ k) (hkn : k ≤ n)
    (fibers : Fin k → ℕ)
    (hsum : ∑ i, fibers i = n)
    (hpos : ∀ i, 1 ≤ fibers i) :
    (n % k) * (n / k + 1) * (n / k) + (k - n % k) * (n / k) * (n / k - 1) ≤
    ∑ i, fibers i * (fibers i - 1) := by
  -- Let $q = n / k$ and $r = n % k$.
  set q : ℕ := n / k
  set r : ℕ := n % k;
  -- By the properties of the sum of squares, we know that $\sum_{i=0}^{k-1} fibers_i^2 \geq r(q+1)^2 + (k-r)q^2$.
  have h_sum_squares : ∑ i, fibers i ^ 2 ≥ r * (q + 1) ^ 2 + (k - r) * q ^ 2 := by
    -- Let $y_i = x_i - q$. Then $\sum y_i = r$ and $\sum y_i^2 \geq r$.
    set y : Fin k → ℤ := fun i => (fibers i : ℤ) - q
    have hy_sum : ∑ i, y i = r := by
      simp +zetaDelta at *;
      linarith [ Nat.mod_add_div n k, show ∑ i : Fin k, ( fibers i : ℤ ) = n from mod_cast hsum ]
    have hy_sq_sum : ∑ i, y i ^ 2 ≥ r := by
      rw [ ← hy_sum ];
      exact Finset.sum_le_sum fun i _ => by nlinarith only;
    -- Expanding the square and using the definitions of $y_i$ and $q$, we get:
    have h_expand : ∑ i, (fibers i : ℤ) ^ 2 = ∑ i, (y i + q) ^ 2 := by
      exact Finset.sum_congr rfl fun _ _ => by ring;
    have h_expand_sq : ∑ i, (y i + q) ^ 2 = ∑ i, y i ^ 2 + 2 * q * ∑ i, y i + k * q ^ 2 := by
      simp +decide [ add_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul ];
      ac_rfl
    have h_final : ∑ i, (fibers i : ℤ) ^ 2 ≥ r + 2 * q * r + k * q ^ 2 := by
      exact h_expand.symm ▸ h_expand_sq.symm ▸ by nlinarith;
    have h_final_nat : ∑ i, fibers i ^ 2 ≥ r * (q + 1) ^ 2 + (k - r) * q ^ 2 := by
      nlinarith only [ Nat.sub_add_cancel ( show r ≤ k from Nat.le_of_lt ( Nat.mod_lt _ hk ) ), h_final ]
    exact h_final_nat;
  zify at *;
  simp_all +decide [ mul_sub, ← sq ];
  rw [ Nat.cast_sub ( show r ≤ k from Nat.le_of_lt <| Nat.mod_lt _ hk ) ] at *;
  rw [ Nat.cast_sub ];
  · convert sub_le_sub_right h_sum_squares n using 1 ; ring;
    rw [ show ( n : ℤ ) = q * k + r by norm_cast; rw [ Nat.div_add_mod' ] ] ; ring;
  · exact Nat.div_pos hkn hk