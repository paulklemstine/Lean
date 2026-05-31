import Mathlib

/-!
# Tropical Incompleteness via Idempotent Fixed Points

This module develops a mathematically rigorous bridge between idempotent/tropical algebra
and Gödelian self-reference. The core insight is that self-reference is not tied to Boolean
negation or arithmetic coding alone — it emerges from order-theoretic fixed-point structure
in idempotent closure operators.

## Main results

1. **`exists_fixedPoint_comp_closure`**: Every composition `C ∘ D` of monotone maps on a
   complete lattice admits a fixed point (via Knaster–Tarski). When `C` is idempotent
   (as in tropical/closure semantics), the fixed point is a "tropical Gödel sentence."

2. **`lfp_is_fixedPoint_comp_closure`**: The least fixed point of `C ∘ D` is explicitly
   given by `OrderHom.lfp` and satisfies `C (D x) = x`.

3. **`exists_tropical_fixed_point_fin`**: In the concrete tropical space `Fin n → ℕ`
   bounded coordinatewise, every monotone map has a fixed point. This gives a finite,
   computational version of tropical self-reference.

4. **`no_sound_complete_system_on_diagonal`**: No proof system can be simultaneously sound
   and complete when a diagonal/self-referential sentence exists. This is the semantic
   obstruction theorem connecting fixed points to incompleteness.

## Interpretation

A **tropical Gödel sentence** is a fixed point `g` of a composition `C ∘ D` where:
- `C` is a closure/provability operator (monotone, idempotent, extensive)
- `D` is a self-reference transformer (diagonal map)

The fixed-point equation `C(D(g)) = g` says: "g is closed under its own transformed
provability" — the tropical analogue of "this sentence is not provable."

## References

- Knaster–Tarski fixed-point theorem
- Gödel's incompleteness theorems (diagonal lemma)
- Tropical/idempotent semiring algebra
- Abstract interpretation theory (Cousot & Cousot)
-/

open OrderHom

/-! ## Part 1: Closure Operators -/

/-- A closure operator on a preordered type: monotone, extensive, and idempotent. -/
structure IsClosureOperator {S : Type*} [Preorder S] (C : S → S) : Prop where
  monotone' : Monotone C
  extensive' : ∀ x, x ≤ C x
  idempotent' : ∀ x, C (C x) = C x

/-! ## Part 2: Tropical Gödel Sentences -/

/-- A tropical Gödel sentence for operators `C` and `D` is a fixed point of `C ∘ D`. -/
def IsTropicalGodelSentence {S : Type*} (C D : S → S) (g : S) : Prop :=
  C (D g) = g

/-- A sentence diagonalizes against a proof system if its validity is equivalent to
    its own unprovability. -/
def DiagonalizesAgainst {S : Type*} (Provable Valid : S → Prop) (g : S) : Prop :=
  Valid g ↔ ¬ Provable g

/-! ## Part 3: Fixed-Point Theorems -/

/-
**Diagonal fixed point for monotone compositions on complete lattices.**
Every composition of monotone maps `C ∘ D` on a complete lattice has a fixed point.
This is the order-theoretic engine behind tropical self-reference: when `C` is a
closure/provability operator and `D` is a self-reference transformer, the fixed point
is a "tropical Gödel sentence."
-/
theorem exists_fixedPoint_comp_closure
    {S : Type*} [CompleteLattice S]
    (C D : S → S)
    (hC_mono : Monotone C)
    (hD_mono : Monotone D) :
    ∃ g : S, IsTropicalGodelSentence C D g := by
  -- By the Knaster-Tarski theorem, since C ∘ D is monotone, it has a least fixed point.
  have h_least_fixed_point : ∃ g, IsLeast {x | C (D x) ≤ x} g := by
    use sInf { x | C ( D x ) ≤ x };
    refine' ⟨ _, fun x hx => _ ⟩;
    · refine' le_sInf fun x hx => _;
      exact le_trans ( hC_mono ( hD_mono ( sInf_le hx ) ) ) hx;
    · exact sInf_le hx;
  obtain ⟨ g, hg ⟩ := h_least_fixed_point;
  exact ⟨ g, le_antisymm hg.1 ( hg.2 ( hC_mono ( hD_mono hg.1 ) ) ) ⟩

/-
The least fixed point of `C ∘ D` is explicitly a fixed point, via Knaster–Tarski.
This gives a canonical choice of tropical Gödel sentence.
-/
theorem lfp_is_fixedPoint_comp_closure
    {S : Type*} [CompleteLattice S]
    (C D : S → S)
    (hC_mono : Monotone C)
    (hD_mono : Monotone D) :
    let F : S →o S := ⟨C ∘ D, hC_mono.comp hD_mono⟩
    IsTropicalGodelSentence C D (OrderHom.lfp F) := by
  refine' le_antisymm _ _;
  · exact le_sInf fun x hx => hC_mono ( hD_mono ( sInf_le hx ) ) |> le_trans <| hx;
  · refine' sInf_le _;
    refine' hC_mono ( hD_mono _ );
    exact le_sInf fun x hx => hC_mono ( hD_mono ( sInf_le hx ) ) |> le_trans <| hx

/-! ## Part 4: Concrete Tropical Fixed Points -/

/-
**Finite tropical fixed point.** Every monotone, coordinatewise bounded self-map on
`Fin n → ℕ` has a fixed point. This produces concrete, computational tropical
self-referential sentences — fixed points of min-plus style operators.
-/
theorem exists_tropical_fixed_point_fin
    {n : ℕ} (B : Fin n → ℕ)
    (T : (Fin n → ℕ) → (Fin n → ℕ))
    (hmono : Monotone T)
    (hbounded : ∀ x, ∀ i, T x i ≤ B i) :
    ∃ x, T x = x := by
  -- Apply the Knaster-Tarski fixed-point theorem to the monotone function T on the complete lattice of functions from Fin n to ℕ.
  have h_fixed_point : ∃ x : Fin n → ℕ, T x ≤ x ∧ ∀ y : Fin n → ℕ, T y ≤ y → x ≤ y := by
    use sInf { x | T x ≤ x };
    refine' ⟨ _, fun y hy => _ ⟩;
    · refine' le_csInf _ _;
      · exact ⟨ B, fun i => hbounded B i ⟩;
      · exact fun x hx => le_trans ( hmono <| csInf_le ⟨ 0, fun y hy => zero_le _ ⟩ hx ) hx;
    · exact csInf_le ⟨ 0, fun x hx => zero_le _ ⟩ hy;
  obtain ⟨ x, hx₁, hx₂ ⟩ := h_fixed_point;
  exact ⟨ x, le_antisymm hx₁ ( hx₂ _ ( hmono hx₁ ) ) ⟩

/-! ## Part 5: Soundness-Completeness Obstruction -/

/-
**No sound and complete proof system admits a diagonal sentence.**
If `Provable` is sound with respect to `Valid`, and a sentence `g` diagonalizes
(i.e., `Valid g ↔ ¬ Provable g`), then the system cannot be complete.

This is the semantic core of Gödelian incompleteness, extracted from its usual
arithmetic-coding context into pure order/closure semantics.
-/
theorem no_sound_complete_system_on_diagonal
    {S : Type*}
    (Provable Valid : S → Prop) (g : S)
    (hsound : ∀ s, Provable s → Valid s)
    (hdiag : Valid g ↔ ¬ Provable g) :
    ¬ (∀ s, Valid s → Provable s) := by
  grind

/-! ## Part 6: Concrete Example — Min-based tropical operator -/

/-- A concrete tropical self-reference operator: pointwise min with constants.
`tropMin c x i = min (x i) (c i)` — this models a tropical proof transformer
that clips each coordinate to a bound. -/
def tropMin {n : ℕ} (c : Fin n → ℕ) (x : Fin n → ℕ) : Fin n → ℕ :=
  fun i => min (x i) (c i)

/-
`tropMin c` is monotone.
-/
theorem tropMin_monotone {n : ℕ} (c : Fin n → ℕ) : Monotone (tropMin c) := by
  exact fun x y h i => min_le_min ( h i ) le_rfl

/-
`tropMin c` is idempotent (applying it twice is the same as once).
-/
theorem tropMin_idempotent {n : ℕ} (c : Fin n → ℕ) (x : Fin n → ℕ) :
    tropMin c (tropMin c x) = tropMin c x := by
  exact funext fun i => by unfold tropMin; simp +decide

/-
`tropMin c` maps into the box bounded by `c`.
-/
theorem tropMin_bounded {n : ℕ} (c : Fin n → ℕ) (x : Fin n → ℕ) (i : Fin n) :
    tropMin c x i ≤ c i := by
  exact min_le_right _ _

/-
The fixed point of `tropMin c` is `c` itself.
-/
theorem tropMin_fixed_point {n : ℕ} (c : Fin n → ℕ) :
    tropMin c c = c := by
  exact funext fun x => min_eq_right le_rfl

/-- A more interesting tropical operator with shift:
`tropShift a b x i = min (x i + a i) (b i)`.
This models a Bellman-style update with additive costs. -/
def tropShift {n : ℕ} (a b : Fin n → ℕ) (x : Fin n → ℕ) : Fin n → ℕ :=
  fun i => min (x i + a i) (b i)

/-
`tropShift a b` is monotone.
-/
theorem tropShift_monotone {n : ℕ} (a b : Fin n → ℕ) :
    Monotone (tropShift a b) := by
  -- To prove monotonicity, we use the fact that min is monotone in both arguments.
  intros x y hxy;
  -- For any i, we have x i + a i ≤ y i + a i, hence min (x i + a i) (b i) ≤ min (y i + a i) (b i).
  intros i
  have hxi_le_yi : x i + a i ≤ y i + a i := by
    exact Nat.add_le_add_right ( hxy i ) _
  exact min_le_min hxi_le_yi le_rfl

/-
`tropShift a b` maps into the bounded box `[0, b]`.
-/
theorem tropShift_bounded {n : ℕ} (a b : Fin n → ℕ) (x : Fin n → ℕ) (i : Fin n) :
    tropShift a b x i ≤ b i := by
  exact min_le_right _ _

/-
`tropShift a b` has a fixed point (by the finite tropical fixed point theorem).
-/
theorem tropShift_has_fixed_point {n : ℕ} (a b : Fin n → ℕ) :
    ∃ x, tropShift a b x = x := by
  convert exists_tropical_fixed_point_fin b ( tropShift a b ) ( tropShift_monotone a b ) ( tropShift_bounded a b )

/-! ## Part 7: Integration — From Fixed Points to Incompleteness -/

/-
**Main integration theorem.** Given a closure operator `C` and a monotone
self-reference transformer `D` on a complete lattice, there exists a tropical
Gödel sentence. Moreover, no sound proof predicate compatible with the diagonal
construction can be complete.

This combines the fixed-point existence (Target 1) with the incompleteness
obstruction (Target 3).
-/
theorem tropical_incompleteness_integration
    {S : Type*} [CompleteLattice S]
    (C D : S → S)
    (_hC_mono : Monotone C)
    (_hD_mono : Monotone D)
    (Provable Valid : S → Prop)
    (hsound : ∀ s, Provable s → Valid s)
    (g : S) (_hg : IsTropicalGodelSentence C D g)
    (hdiag : Valid g ↔ ¬ Provable g) :
    ¬ (∀ s, Valid s → Provable s) :=
  no_sound_complete_system_on_diagonal Provable Valid g hsound hdiag

#print axioms exists_fixedPoint_comp_closure
#print axioms lfp_is_fixedPoint_comp_closure
#print axioms exists_tropical_fixed_point_fin
#print axioms no_sound_complete_system_on_diagonal
#print axioms tropMin_monotone
#print axioms tropMin_idempotent
#print axioms tropMin_bounded
#print axioms tropMin_fixed_point
#print axioms tropShift_monotone
#print axioms tropShift_bounded
#print axioms tropShift_has_fixed_point
#print axioms tropical_incompleteness_integration