/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the project LICENSE file.
-/
import Mathlib

/-!
# Quotient Orbit Compression: Core Theory

## Bridge: Algebraic Dynamics ↔ Cryptographic Collision Bounds ↔ EML State Compression

This file develops a theory of **quotient-observable dynamics** for finite iterates.
The central result is that any deterministic trajectory on a finite type `α` must
produce a collision (under a decidable setoid `ρ`) within at most `|α/ρ|` steps.

This simultaneously serves as:
- An **algebraic dynamical system** theorem on finite quotient recurrence,
- An **EML-style observable-state compression** principle,
- A **cryptographic collision certificate** on quotient states,
- A **certified robustness** statement for quotient-observable trajectories.

## Main results

- `quotient_eq_implies_rel`: Quotient equality implies setoid relation.
- `exists_lt_lt_iterate_quotient_eq`: Pigeonhole gives distinct iterates with equal quotient.
- `exists_iterate_rel_of_card_quotient`: Core theorem — bounded-horizon quotient collision.
- `eml_observable_orbit_bound`: Observable orbit count ≤ quotient cardinality.
- `post_quantum_security_collision_upper_bound`: Crypto-facing collision certificate.
- `certified_robustness_via_quotient_compression`: Universal certified robustness.
-/

open Function Finset Fintype

namespace QuotientOrbitCompression

/-! ## §1. Foundational quotient-relation lemmas -/

/-- **Bridge: quotient algebra → setoid relation.**
    Equality in the quotient `α/ρ` implies the underlying setoid relation `ρ.r`. -/
theorem quotient_eq_implies_rel
    {α : Type*} (ρ : Setoid α) {a b : α} :
    Quotient.mk (s := ρ) a = Quotient.mk (s := ρ) b → ρ.r a b := by
  intro h; exact Quotient.exact h

/-! ## §2. Pigeonhole on quotient traces -/

/-- **Core pigeonhole on quotient traces**: there exist distinct indices `m < n ≤ |α/ρ|`
    such that the quotient images of `f^[m](x)` and `f^[n](x)` coincide.
    Bridge: finite combinatorics → quotient dynamical systems. -/
theorem exists_lt_lt_iterate_quotient_eq
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) (x : α) :
    ∃ m n : ℕ, m < n ∧ n ≤ Fintype.card (Quotient ρ) ∧
      Quotient.mk (s := ρ) ((f^[m]) x) = Quotient.mk (s := ρ) ((f^[n]) x) := by
  have hcard : Fintype.card (Quotient ρ) < Fintype.card (Fin (Fintype.card (Quotient ρ) + 1)) := by
    simp [Fintype.card_fin]
  let g : Fin (Fintype.card (Quotient ρ) + 1) → Quotient ρ :=
    fun i => Quotient.mk (s := ρ) ((f^[i.1]) x)
  obtain ⟨i, j, hne, heq⟩ := Fintype.exists_ne_map_eq_of_card_lt g hcard
  rcases Nat.lt_or_gt_of_ne (Fin.val_ne_of_ne hne) with h | h
  · exact ⟨i.1, j.1, h, Nat.le_of_lt_succ j.isLt, heq⟩
  · exact ⟨j.1, i.1, h, Nat.le_of_lt_succ i.isLt, heq.symm⟩

/-- **Core theorem — quotient-cardinality recurrence.**
    For any endomorphism `f` on a finite type `α` with decidable setoid `ρ`,
    every point `x` has iterates `f^[m](x)` and `f^[n](x)` that are `ρ`-related
    with `m < n ≤ |α/ρ|`.

    **Bridge: algebraic dynamics ↔ cryptographic collision bounds.**
    Complexity: O(|α/ρ|) observations suffice for collision detection.

    **Bridge: quotient cardinality ↔ certified robustness observables.** -/
theorem exists_iterate_rel_of_card_quotient
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) (x : α) :
    ∃ m n : ℕ, m < n ∧ n ≤ Fintype.card (Quotient ρ) ∧
      ρ.r ((f^[m]) x) ((f^[n]) x) := by
  obtain ⟨m, n, hmn, hbound, heq⟩ := exists_lt_lt_iterate_quotient_eq ρ f x
  exact ⟨m, n, hmn, hbound, quotient_eq_implies_rel ρ heq⟩

/-! ## §3. Observable orbit definitions and bounds -/

/-- The **quotient-observable trace** maps each step `i ∈ {0, ..., N}` to the
    quotient class of `f^[i](x)`. -/
def quotientObservableTrace
    {α : Type*} (ρ : Setoid α) (f : α → α) (x : α) (N : ℕ) :
    Fin (N + 1) → Quotient ρ :=
  fun i => Quotient.mk (s := ρ) ((f^[i.1]) x)

/-- The **observable orbit set**: distinct quotient classes visited in first `N+1` iterates. -/
def observableOrbitSet
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) (x : α) (N : ℕ) :
    Finset (Quotient ρ) :=
  Finset.univ.image (quotientObservableTrace ρ f x N)

/-- The **observable orbit count**: number of distinct quotient classes visited. -/
def observableOrbitCount
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) (x : α) (N : ℕ) : ℕ :=
  (observableOrbitSet ρ f x N).card

/-- **EML observable orbit bound**: the number of distinct quotient classes
    visited in any window is at most `|α/ρ|`.

    **Bridge: finite orbit theory ↔ EML state compression.**
    O(|α/ρ|) upper bound on observable state space complexity. -/
theorem eml_observable_orbit_bound
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) (x : α) (N : ℕ) :
    observableOrbitCount ρ f x N ≤ Fintype.card (Quotient ρ) := by
  unfold observableOrbitCount observableOrbitSet
  exact Finset.card_le_univ _

/-- **Compressed horizon bound**: specializing to `N = |α/ρ|`. -/
theorem eml_observable_orbit_bound_at_quotient_card
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) (x : α) :
    observableOrbitCount ρ f x (Fintype.card (Quotient ρ)) ≤
      Fintype.card (Quotient ρ) :=
  eml_observable_orbit_bound ρ f x _

/-! ## §4. Compression statistics -/

/-- The **compression gap** between collision indices: `n - m`. -/
def quotientCompressionGap (m n : ℕ) : ℕ := n - m

/-- **Quotient collision entropy**: `|α| - |α/ρ|`, the information discarded.
    Bridge: information theory → algebraic compression. -/
noncomputable def quotientCollisionEntropy
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r] : ℕ :=
  Fintype.card α - Fintype.card (Quotient ρ)

/-- **Orbit compression ratio**: `|α/ρ| / |α|` measuring compression efficiency. -/
noncomputable def orbitCompressionRatio
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r] : ℚ :=
  (Fintype.card (Quotient ρ) : ℚ) / (Fintype.card α : ℚ)

/-- **Observable diameter**: one less than the observable orbit count. -/
def quotientObservableDiameter
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) (x : α) (N : ℕ) : ℕ :=
  observableOrbitCount ρ f x N - 1

/-- The collision entropy is nonneg (trivially, since it's ℕ). -/
theorem quotientCollisionEntropy_nonneg
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r] :
    0 ≤ quotientCollisionEntropy ρ :=
  Nat.zero_le _

/-
**Orbit compression ratio is at most 1**: the quotient never has more states
    than the ambient type. Bridge: information theory → algebraic compression.
-/
theorem orbitCompressionRatio_le_one
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r] :
    orbitCompressionRatio ρ ≤ 1 := by
  refine' div_le_one_of_le₀ _ ( Nat.cast_nonneg _ );
  exact_mod_cast Fintype.card_le_of_surjective _ Quotient.mk_surjective

/-- Observable diameter + 1 is bounded by quotient card + 1. -/
theorem quotientObservableDiameter_bound
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) (x : α) (N : ℕ) :
    quotientObservableDiameter ρ f x N + 1 ≤ Fintype.card (Quotient ρ) + 1 := by
  unfold quotientObservableDiameter
  have h := eml_observable_orbit_bound ρ f x N
  omega

/-! ## §5. Cryptographic collision certificates -/

/-- A **lattice-crypto collision certificate**: existence of quotient collision
    within the cardinality horizon.
    Bridge: algebraic dynamics → post-quantum security analysis. -/
def lattice_crypto_collision_certificate
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) (x : α) : Prop :=
  ∃ m n : ℕ, m < n ∧ n ≤ Fintype.card (Quotient ρ) ∧
    ρ.r ((f^[m]) x) ((f^[n]) x)

/-- **Post-quantum security collision upper bound**: every trajectory has a
    deterministic collision certificate within `|α/ρ|` steps.
    O(|α/ρ|) deterministic collision bound for post-quantum analysis.

    Bridge: finite orbit recurrence → post_quantum_security collision analysis. -/
theorem post_quantum_security_collision_upper_bound
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) (x : α) :
    lattice_crypto_collision_certificate ρ f x :=
  exists_iterate_rel_of_card_quotient ρ f x

/-- **Certified robustness for observables**: ∀ starting points,
    quotient collisions exist within the cardinality bound.
    Bridge: quotient cardinality → certified_robustness for ML observables. -/
def certified_robustness_observable
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) : Prop :=
  ∀ x : α, ∃ m n : ℕ, m < n ∧
    n ≤ Fintype.card (Quotient ρ) ∧
    ρ.r ((f^[m]) x) ((f^[n]) x)

/-- **Certified robustness via quotient compression**: ∀x, ∃m, ∃n quantifier alternation.
    Bridge: quotient compression → certified_robustness for observable trajectories. -/
theorem certified_robustness_via_quotient_compression
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) :
    certified_robustness_observable ρ f :=
  fun x => exists_iterate_rel_of_card_quotient ρ f x

/-! ## §6. First-repeat and certificate structures -/

/-- Predicate for the **first quotient repeat**: `(m, n)` is the earliest
    pair witnessing a quotient collision with terminal index `n`. -/
def isFirstQuotientRepeat
    {α : Type*} (ρ : Setoid α) (f : α → α) (x : α) (m n : ℕ) : Prop :=
  m < n ∧
  ρ.r ((f^[m]) x) ((f^[n]) x) ∧
  ∀ a b : ℕ, a < b → b < n → ¬ ρ.r ((f^[a]) x) ((f^[b]) x)

/-- A **quotient repeat certificate** packages collision data with proofs.
    Bridge: algebraic orbit theory → certified collision extraction. -/
structure QuotientRepeatCertificate
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) (x : α) where
  m : ℕ
  n : ℕ
  strictMonoWitness : m < n
  horizonWitness : n ≤ Fintype.card (Quotient ρ)
  relatedWitness : ρ.r ((f^[m]) x) ((f^[n]) x)

/-- **Existence of quotient repeat certificates.** -/
theorem exists_QuotientRepeatCertificate
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) (x : α) :
    Nonempty (QuotientRepeatCertificate ρ f x) := by
  obtain ⟨m, n, hmn, hbound, hrel⟩ := exists_iterate_rel_of_card_quotient ρ f x
  exact ⟨⟨m, n, hmn, hbound, hrel⟩⟩

/-
**Existence of first quotient repeat within the horizon.**
    Upgrades pigeonhole into a genuine orbit-structure theorem with minimality.
    Bridge: orbit structure theory → minimal collision extraction.
-/
theorem exists_first_quotient_repeat
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) (x : α) :
    ∃ m n, isFirstQuotientRepeat ρ f x m n ∧ n ≤ Fintype.card (Quotient ρ) := by
  -- Let's denote the set of indices where the quotient repeat occurs as S.
  set S := {n | ∃ m < n, ρ.r ((f^[m]) x) ((f^[n]) x)} with hS_def;
  -- By the well-ordering principle, S has a least element n₀.
  obtain ⟨n₀, hn₀⟩ : ∃ n₀ ∈ S, ∀ n ∈ S, n₀ ≤ n := by
    have h_nonempty : S.Nonempty := by
      exact Exists.elim ( exists_iterate_rel_of_card_quotient ρ f x ) fun m hm => Exists.elim hm fun n hn => ⟨ n, m, hn.1, hn.2.2 ⟩;
    exact ⟨ Nat.find h_nonempty, Nat.find_spec h_nonempty, fun n hn => Nat.find_min' h_nonempty hn ⟩;
  obtain ⟨ ⟨ m, hm₁, hm₂ ⟩, hm₃ ⟩ := hn₀;
  refine' ⟨ m, n₀, ⟨ hm₁, hm₂, _ ⟩, _ ⟩;
  · exact fun a b hab hbn₀ h => not_lt_of_ge ( hm₃ b ⟨ a, hab, h ⟩ ) hbn₀;
  · have := exists_iterate_rel_of_card_quotient ρ f x;
    exact le_trans ( hm₃ _ ⟨ _, this.choose_spec.choose_spec.1, this.choose_spec.choose_spec.2.2 ⟩ ) this.choose_spec.choose_spec.2.1

/-! ## §7. Setoid-respecting dynamics and semiconjugacy -/

/-- `f` **respects** setoid `ρ` if it preserves the equivalence relation.
    Bridge: semiring congruence functoriality → quotient dynamical systems. -/
def RespectsSetoid
    {α : Type*} (ρ : Setoid α) (f : α → α) : Prop :=
  ∀ ⦃a b : α⦄, ρ.r a b → ρ.r (f a) (f b)

/-
**Iterated stability**: if `f` respects `ρ`, then `f^[n]` respects `ρ` for all `n`.
    Bridge: congruence algebra → iterated dynamical stability.
-/
theorem respectsSetoid_iterate
    {α : Type*} (ρ : Setoid α) (f : α → α)
    (hf : RespectsSetoid ρ f) :
    ∀ n : ℕ, ∀ ⦃a b : α⦄, ρ.r a b → ρ.r ((f^[n]) a) ((f^[n]) b) := by
  intro n;
  induction n <;> aesop

/-- The **quotient lift map**: when `f` respects `ρ`, it induces an endomorphism
    on `Quotient ρ`. -/
def quotientLiftMap
    {α : Type*} (ρ : Setoid α) (f : α → α)
    (hf : RespectsSetoid ρ f) :
    Quotient ρ → Quotient ρ :=
  Quotient.map f (fun _a _b hab => hf hab)

/-
**Semiconjugacy of iteration**: iteration commutes with quotient projection.
    `(quotientLiftMap ρ f hf)^[n] (⟦x⟧) = ⟦f^[n](x)⟧`

    Bridge: semiring congruence functoriality ↔ quotient dynamical systems.
-/
theorem quotientLiftMap_iterate_commutes
    {α : Type*} (ρ : Setoid α) (f : α → α)
    (hf : RespectsSetoid ρ f) (x : α) (n : ℕ) :
    ((quotientLiftMap ρ f hf)^[n]) (Quotient.mk (s := ρ) x) =
      Quotient.mk (s := ρ) ((f^[n]) x) := by
  induction n <;> simp_all +decide [ Function.iterate_succ_apply', quotientLiftMap ]

/-! ## §8. Saturation and exactness -/

/-- An orbit is **quotient-saturated** if it visits every quotient class
    within the cardinality horizon. -/
def QuotientOrbitSaturated
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) (x : α) : Prop :=
  ∀ q : Quotient ρ, ∃ n : ℕ, n ≤ Fintype.card (Quotient ρ) ∧
    Quotient.mk (s := ρ) ((f^[n]) x) = q

/-
**Saturation implies maximal observable count**: the upper bound is tight
    under saturation. Bridge: saturation analysis → sharp compression bounds.
-/
theorem quotient_orbit_saturated_cardinality_exact
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) (x : α)
    (hsat : QuotientOrbitSaturated ρ f x) :
    observableOrbitCount ρ f x (Fintype.card (Quotient ρ)) =
      Fintype.card (Quotient ρ) := by
  refine' le_antisymm _ _;
  · exact eml_observable_orbit_bound ρ f x _;
  · refine' Finset.card_le_card _;
    intro q hq;
    rcases hsat q with ⟨ n, hn, rfl ⟩ ; exact Finset.mem_image.mpr ⟨ ⟨ n, by linarith ⟩, Finset.mem_univ _, rfl ⟩

/-! ## §9. Monotonicity of observable orbit count -/

/-
Observable orbit set is monotone in the horizon.
-/
theorem observableOrbitSet_mono
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) (x : α) {M N : ℕ} (h : M ≤ N) :
    observableOrbitSet ρ f x M ⊆ observableOrbitSet ρ f x N := by
  intro q;
  simp +decide [ observableOrbitSet, mem_image ];
  exact fun i hi => ⟨ ⟨ i, by linarith [ Fin.is_lt i ] ⟩, hi ⟩

/-- Observable orbit count is monotone in the horizon. -/
theorem observableOrbitCount_mono
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) (x : α) {M N : ℕ} (h : M ≤ N) :
    observableOrbitCount ρ f x M ≤ observableOrbitCount ρ f x N :=
  Finset.card_le_card (observableOrbitSet_mono ρ f x h)

/-
Observable orbit count at step 0 is exactly 1.
-/
theorem observableOrbitCount_zero
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    (f : α → α) (x : α) :
    observableOrbitCount ρ f x 0 = 1 := by
  convert Finset.card_singleton ( Quotient.mk ( s := ρ ) x )

/-- Compression gap is positive for any collision. -/
theorem quotientCompressionGap_pos {m n : ℕ} (h : m < n) :
    0 < quotientCompressionGap m n := by
  unfold quotientCompressionGap; omega

/-- Compression gap bounded by quotient cardinality. -/
theorem quotientCompressionGap_le_card
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r]
    {m n : ℕ} (_hm : m < n) (hn : n ≤ Fintype.card (Quotient ρ)) :
    quotientCompressionGap m n ≤ Fintype.card (Quotient ρ) := by
  unfold quotientCompressionGap; omega

/-! ## §10. Concrete models -/

/-- Discrete setoid on `Bool`: equality. -/
def boolDiscreteSetoid : Setoid Bool where
  r := (· = ·)
  iseqv := ⟨fun _ => rfl, fun h => h.symm, fun h1 h2 => h1.trans h2⟩

instance : DecidableRel boolDiscreteSetoid.r := fun a b => Bool.decEq a b

/-
Quotient of `Bool` by discrete setoid has cardinality 2.
-/
theorem bool_discrete_quotient_card :
    Fintype.card (Quotient boolDiscreteSetoid) = 2 := by
  convert Fintype.card_congr ( Equiv.ofBijective _ ?_ );
  convert rfl;
  convert Fintype.card_fin 2;
  exact fun x => Quotient.liftOn' x ( fun x => if x = Bool.true then 1 else 0 ) fun x y h => by cases x <;> cases y <;> simp_all +decide ;
  constructor <;> intro x <;> simp_all +decide [ Function.Injective ];
  · intro y h; rcases Quotient.exists_rep x with ⟨ x, rfl ⟩ ; rcases Quotient.exists_rep y with ⟨ y, rfl ⟩ ; aesop;
  · fin_cases x <;> [ exact ⟨ Quotient.mk _ Bool.false, rfl ⟩ ; exact ⟨ Quotient.mk _ Bool.true, rfl ⟩ ]

/-- `Bool.not` collision: `not^[0](true) = true = not^[2](true)`. -/
theorem bool_not_collision :
    ∃ m n : ℕ, m < n ∧ n ≤ 2 ∧
      boolDiscreteSetoid.r ((Bool.not^[m]) true) ((Bool.not^[n]) true) :=
  ⟨0, 2, by omega, le_refl _, by native_decide⟩

/-- Identity on `Bool` collides at steps 0 and 1. -/
theorem bool_id_immediate_collision (b : Bool) :
    ∃ m n : ℕ, m < n ∧ n ≤ 1 ∧
      boolDiscreteSetoid.r ((id^[m]) b) ((id^[n]) b) :=
  ⟨0, 1, by omega, le_refl _, by simp [boolDiscreteSetoid]⟩

/-
`|α/ρ| ≤ |α|` for any setoid.
-/
theorem quotient_card_le_card
    {α : Type*} [Fintype α] [DecidableEq α]
    (ρ : Setoid α) [DecidableRel ρ.r] :
    Fintype.card (Quotient ρ) ≤ Fintype.card α := by
  exact card_quotient_le ρ

/-- Collision horizon is positive when α is nonempty. -/
theorem quotient_card_pos
    {α : Type*} [Fintype α] [DecidableEq α] [h : Nonempty α]
    (ρ : Setoid α) [DecidableRel ρ.r] :
    0 < Fintype.card (Quotient ρ) := by
  haveI : Nonempty (Quotient ρ) := h.map (Quotient.mk (s := ρ))
  exact Fintype.card_pos

end QuotientOrbitCompression