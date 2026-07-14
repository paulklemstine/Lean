import Mathlib

/-!
# The Modal Logic of the Forcing Multiverse: Frame Correspondences

This file develops the abstract Kripke-frame core behind the *modal logic of
forcing* in the set-theoretic multiverse.  A "world" is a model of set theory and
the accessibility relation `R` is read as *"is a forcing extension of"*.

For a relation `R : W → W → Prop` we define the box (necessity: *true in every
accessible extension*) and diamond (possibility: *true in some accessible
extension*) operators on assertions `P : W → Prop`, and prove the classical
*Sahlqvist frame correspondences* linking the modal axioms to first-order frame
conditions:

* `box_toPoint_iff_reflexive`   —  axiom **T** `□p → p`     ↔ reflexivity;
* `box_box_iff_transitive`      —  axiom **4** `□p → □□p`   ↔ transitivity;
* `brouwer_iff_symmetric`       —  axiom **B** `p → □◇p`    ↔ symmetry;
* `euclid_iff_euclidean`        —  axiom **5** `◇p → □◇p`   ↔ euclideanness;
* `directed_iff_confluent`      —  axiom **.2** `◇□p → □◇p` ↔ confluence (directedness).

The upshot (`nat_le_frame_is_S42_not_S5`) is the content of Direction 1 of the
research programme: the *directed but antisymmetric* forcing-extension order —
modelled by `(ℕ, ≤)` — validates **T**, **4** and **.2** but refutes **B** and
**5**.  Symmetry is exactly the frame condition whose loss drops `S5` to the
Hamkins–Löwe logic `S4.2`.
-/

namespace Multiverse

variable {W : Type*} (R : W → W → Prop)

/-- Necessity: `p` holds in every world accessible from `w`. -/
def box (P : W → Prop) (w : W) : Prop := ∀ v, R w v → P v

/-- Possibility: `p` holds in some world accessible from `w`. -/
def dia (P : W → Prop) (w : W) : Prop := ∃ v, R w v ∧ P v

/-- A relation is **euclidean** when any two worlds accessible from a common world
are mutually accessible in one direction (`R x y → R x z → R y z`). -/
def Euclidean : Prop := ∀ ⦃x y z⦄, R x y → R x z → R y z

/-- A relation is **confluent** / **directed** when any two worlds accessible from
a common world have a common accessible successor.  This is the "directedness" of
iterated forcing: two extensions can be amalgamated. -/
def Confluent : Prop := ∀ ⦃x y z⦄, R x y → R x z → ∃ u, R y u ∧ R z u

/-! ## Frame correspondences -/

/-
**Axiom T** `□p → p` is valid on the frame iff `R` is reflexive.
-/
theorem box_toPoint_iff_reflexive :
    (∀ (P : W → Prop) w, box R P w → P w) ↔ Reflexive R := by
  constructor;
  · exact fun h x => h _ x fun _ h' => h';
  · intro hR P w hP; exact hP w (hR w)

/-
**Axiom 4** `□p → □□p` is valid on the frame iff `R` is transitive.
-/
theorem box_box_iff_transitive :
    (∀ (P : W → Prop) w, box R P w → box R (box R P) w) ↔ Transitive R := by
  refine' ⟨ _, fun h P w hw x hx => _ ⟩;
  · intro h x y z hxy hyz;
    specialize h ( fun v => R x v ) x ; simp_all +decide [ box ];
    exact h _ hxy _ hyz;
  · exact fun y hy => hw y ( h hx hy )

/-
**Axiom B** `p → □◇p` (Brouwer) is valid on the frame iff `R` is symmetric.
-/
theorem brouwer_iff_symmetric :
    (∀ (P : W → Prop) w, P w → box R (dia R P) w) ↔ Symmetric R := by
  refine' ⟨ fun h => _, fun h => _ ⟩;
  · intro x y hxy; specialize h ( fun z => z = x ) x; simp_all +decide [ box, dia ] ;
  · intro P w hw v hv
    use w;
    exact ⟨ h hv, hw ⟩

/-
**Axiom 5** `◇p → □◇p` is valid on the frame iff `R` is euclidean.
-/
theorem euclid_iff_euclidean :
    (∀ (P : W → Prop) w, dia R P w → box R (dia R P) w) ↔ Euclidean R := by
  constructor <;> intro h;
  · intro x y z hxy hxz; specialize h ( fun w => w = z ) x; simp_all +decide [ box, dia ] ;
  · exact fun P w ⟨ v, hv, hv' ⟩ x hx => ⟨ v, h hx hv, hv' ⟩

/-
**Axiom .2** `◇□p → □◇p` (directedness) is valid on the frame iff `R` is
confluent.  This is the axiom separating `S4.2` from `S4`.
-/
theorem directed_iff_confluent :
    (∀ (P : W → Prop) w, dia R (box R P) w → box R (dia R P) w) ↔ Confluent R := by
  constructor;
  · intro h x y z hxy hxz;
    specialize h ( fun w => R z w ) x;
    grind +locals;
  · intros h P w hw; intro v hv; obtain ⟨ a, ha₁, ha₂ ⟩ := hw; obtain ⟨ u, hu₁, hu₂ ⟩ := h hv ha₁; use u; aesop;

/-! ## The forcing-extension order `(ℕ, ≤)` is genuinely `S4.2`, not `S5` -/

/-
The extension order is reflexive.
-/
theorem nat_le_reflexive : Reflexive (· ≤ · : ℕ → ℕ → Prop) := by
  exact fun x => le_refl x

/-
The extension order is transitive.
-/
theorem nat_le_transitive : Transitive (· ≤ · : ℕ → ℕ → Prop) := by
  exact fun x y z hxy hyz => le_trans hxy hyz

/-
The extension order is confluent/directed: any two extensions amalgamate.
-/
theorem nat_le_confluent : Confluent (· ≤ · : ℕ → ℕ → Prop) := by
  exact fun x y z h1 h2 => ⟨ Max.max y z, le_max_left _ _, le_max_right _ _ ⟩

/-
The extension order is **not** symmetric.
-/
theorem nat_le_not_symmetric : ¬ Symmetric (· ≤ · : ℕ → ℕ → Prop) := by
  exact fun h => by have := @h 0 1; norm_num at this;

/-
The extension order is **not** euclidean.
-/
theorem nat_le_not_euclidean : ¬ Euclidean (· ≤ · : ℕ → ℕ → Prop) := by
  exact fun h => by have := @h 0 1 0; norm_num at this;

/-
**Direction 1, main separation.**  On the directed antisymmetric forcing
order `(ℕ, ≤)`, the modal axioms **T**, **4** and **.2** are valid, while **B**
and **5** both fail.  Hence the logic of directed forcing is `S4.2`, strictly
weaker than the `S5` obtained from a symmetric (equivalence) accessibility.
-/
theorem nat_le_frame_is_S42_not_S5 :
    -- T holds
    (∀ (P : ℕ → Prop) w, box (· ≤ ·) P w → P w) ∧
    -- 4 holds
    (∀ (P : ℕ → Prop) w, box (· ≤ ·) P w → box (· ≤ ·) (box (· ≤ ·) P) w) ∧
    -- .2 holds
    (∀ (P : ℕ → Prop) w, dia (· ≤ ·) (box (· ≤ ·) P) w → box (· ≤ ·) (dia (· ≤ ·) P) w) ∧
    -- B fails
    (¬ ∀ (P : ℕ → Prop) w, P w → box (· ≤ ·) (dia (· ≤ ·) P) w) ∧
    -- 5 fails
    (¬ ∀ (P : ℕ → Prop) w, dia (· ≤ ·) P w → box (· ≤ ·) (dia (· ≤ ·) P) w) := by
  grind +suggestions

end Multiverse