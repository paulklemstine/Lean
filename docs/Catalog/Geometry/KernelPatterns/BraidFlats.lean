import Geometry.KernelPatterns.Bell

/-!
# Kernel patterns as the flats of the braid arrangement

The braid arrangement `A_{n-1}` in `ℝ^n` is the family of hyperplanes
`H_{ij} = {v | v i = v j}`.  Its *flats* (the elements of its intersection
lattice) are the subspaces obtained by intersecting families of these
hyperplanes; each such subspace is cut out by the equations coming from an
equivalence relation on the index set.

This file is the geometric side of `Geometry.KernelPatterns.Core`:

* `braidFlat x` — the flat cut out by the kernel of the tuple `x`.
* `braidFlat_eq_iff` — **two tuples cut out the same flat iff they have the
  same kernel pattern**, so `pat` is a complete invariant of the flat.
* `braidFlat_le_iff` — the (order-reversing) dictionary between inclusion of
  flats and refinement of kernels.
* `finrank_braidFlat` — the dimension of the flat is the number of blocks.
* `card_braidFlats` — the intersection lattice of the braid arrangement has
  exactly `(patterns n n).card` elements; for `n ≤ 5` this is the Bell number
  (`card_braidFlats_five : ... = 52`).
-/

namespace Geometry.KernelPatterns

open Finset

variable {n : ℕ} {X : Type*}

/-- The flat of the braid arrangement determined by the kernel of a tuple `x`:
the set of vectors constant on the blocks of `x`. -/
def braidFlat (x : Fin n → X) : Submodule ℝ (Fin n → ℝ) where
  carrier := {v | ∀ i j, x i = x j → v i = v j}
  add_mem' := by intro a b ha hb i j h; simp [ha i j h, hb i j h]
  zero_mem' := by intro i j _; rfl
  smul_mem' := by intro c a ha i j h; simp [ha i j h]

@[simp] lemma mem_braidFlat {x : Fin n → X} {v : Fin n → ℝ} :
    v ∈ braidFlat x ↔ ∀ i j, x i = x j → v i = v j := Iff.rfl

/-- The characteristic vector of the block of `i`. -/
def blockIndicator [DecidableEq X] (x : Fin n → X) (i : Fin n) : Fin n → ℝ :=
  fun k => if x k = x i then 1 else 0

lemma blockIndicator_mem [DecidableEq X] (x : Fin n → X) (i : Fin n) :
    blockIndicator x i ∈ braidFlat x := by
  intro k l h
  simp [blockIndicator, h]

/-- Inclusion of flats is refinement of kernels (order-reversingly). -/
theorem braidFlat_le_iff [DecidableEq X] {Y : Type*} [DecidableEq Y]
    (x : Fin n → X) (y : Fin n → Y) :
    braidFlat x ≤ braidFlat y ↔ ∀ i j, y i = y j → x i = x j := by
  constructor
  · intro h i j hy
    have hmem : blockIndicator x i ∈ braidFlat y := h (blockIndicator_mem x i)
    have hval : (if x i = x i then (1 : ℝ) else 0) = (if x j = x i then (1 : ℝ) else 0) :=
      hmem i j hy
    rw [if_pos rfl] at hval
    by_contra hx
    rw [if_neg fun hji => hx hji.symm] at hval
    exact one_ne_zero hval
  · intro h v hv i j hy
    exact hv i j (h i j hy)

/-- **The flat is a complete geometric encoding of the kernel pattern.** -/
theorem braidFlat_eq_iff [DecidableEq X] {Y : Type*} [DecidableEq Y]
    (x : Fin n → X) (y : Fin n → Y) :
    braidFlat x = braidFlat y ↔ pat x = pat y := by
  constructor
  · intro h
    refine pat_congr fun k l => ?_
    have h1 := (braidFlat_le_iff y x).1 h.ge
    have h2 := (braidFlat_le_iff x y).1 h.le
    exact ⟨fun hkl => h1 k l hkl, fun hkl => h2 k l hkl⟩
  · intro h
    have hker : ∀ i j, x i = x j ↔ y i = y j := by
      intro i j
      rw [← pat_eq_iff (x := x), ← pat_eq_iff (x := y), h]
    apply le_antisymm
    · exact (braidFlat_le_iff x y).2 fun i j hy => (hker i j).2 hy
    · exact (braidFlat_le_iff y x).2 fun i j hx => (hker i j).1 hx

/-- Coordinates on a flat: a vector constant on blocks is exactly a function on
the set of first-occurrence representatives. -/
noncomputable def braidFlatEquiv [DecidableEq X] (x : Fin n → X) :
    braidFlat x ≃ₗ[ℝ] (↥(univ.image (pat x)) → ℝ) where
  toFun v := fun r => (v : Fin n → ℝ) r.1
  map_add' := by intro v w; rfl
  map_smul' := by intro c v; rfl
  invFun w := ⟨fun i => w ⟨pat x i, Finset.mem_image_of_mem _ (mem_univ i)⟩, by
    intro i j h
    have : pat x i = pat x j := pat_eq_iff.2 h
    simp [this]⟩
  left_inv := by
    rintro ⟨v, hv⟩
    apply Subtype.ext
    funext i
    exact hv _ _ (apply_pat x i)
  right_inv := by
    intro w
    funext r
    obtain ⟨r, hr⟩ := r
    obtain ⟨i, -, rfl⟩ := Finset.mem_image.1 hr
    simp

/-- **The dimension of a braid flat is the number of blocks of the kernel.** -/
theorem finrank_braidFlat [DecidableEq X] (x : Fin n → X) :
    Module.finrank ℝ (braidFlat x) = (univ.image (pat x)).card := by
  rw [(braidFlatEquiv x).finrank_eq, Module.finrank_fintype_fun_eq_card,
    Fintype.card_coe]

/-- Extreme cases: an injective tuple cuts out the whole space. -/
theorem braidFlat_of_injective [DecidableEq X] {x : Fin n → X}
    (hx : Function.Injective x) : braidFlat x = ⊤ := by
  refine eq_top_iff.2 fun v _ i j h => ?_
  rw [hx h]

/-- Extreme cases: a constant tuple cuts out the line of constant vectors, of
dimension `1` when `n ≠ 0`. -/
theorem finrank_braidFlat_const [NeZero n] (c : X) :
    Module.finrank ℝ (braidFlat (fun _ : Fin n => c)) = 1 := by
  classical
  rw [finrank_braidFlat]
  have h0 : ∀ i : Fin n, pat (fun _ : Fin n => c) i = (0 : Fin n) := by
    intro i
    have hle : pat (fun _ : Fin n => c) i ≤ (0 : Fin n) := Finset.min'_le _ _ (by simp)
    have hval : (pat (fun _ : Fin n => c) i : ℕ) ≤ ((0 : Fin n) : ℕ) := hle
    have h00 : ((0 : Fin n) : ℕ) = 0 := rfl
    exact Fin.ext (by omega)
  have himg : univ.image (pat fun _ : Fin n => c) = {(0 : Fin n)} := by
    ext j
    simp only [Finset.mem_image, Finset.mem_univ, true_and, Finset.mem_singleton]
    constructor
    · rintro ⟨i, rfl⟩; exact h0 i
    · rintro rfl; exact ⟨(0 : Fin n), h0 _⟩
  rw [himg, Finset.card_singleton]

/-! ### Counting the flats -/

/-- The intersection lattice of the braid arrangement: the flats cut out by
`n`-tuples. -/
def braidFlats (n : ℕ) : Set (Submodule ℝ (Fin n → ℝ)) :=
  {L | ∃ x : Fin n → Fin n, L = braidFlat x}

/-- **The flats of the braid arrangement are counted by the kernel patterns.** -/
theorem card_braidFlats (n : ℕ) : Nat.card (braidFlats n) = (patterns n n).card := by
  classical
  have hbij : Function.Bijective
      (fun p : ↥(patterns n n) => (⟨braidFlat (p : Fin n → Fin n), ⟨p, rfl⟩⟩ :
        ↥(braidFlats n))) := by
    constructor
    · rintro ⟨p, hp⟩ ⟨q, hq⟩ h
      rw [mem_patterns_self] at hp hq
      have : braidFlat p = braidFlat q := congrArg Subtype.val h
      have := (braidFlat_eq_iff p q).1 this
      rw [hp, hq] at this
      exact Subtype.ext this
    · rintro ⟨L, x, rfl⟩
      refine ⟨⟨pat x, (mem_patterns_self _).2 (pat_idem x)⟩, Subtype.ext ?_⟩
      exact (braidFlat_eq_iff (pat x) x).2 (pat_idem x)
  rw [← Nat.card_eq_of_bijective _ hbij, Nat.card_eq_finsetCard]

/-- For `n = 5` the braid arrangement in `ℝ^5` has exactly `52` flats, the fifth
Bell number. -/
theorem card_braidFlats_five : Nat.card (braidFlats 5) = 52 := by
  rw [card_braidFlats, card_patterns_five]

/-- For `n = 4` the braid arrangement in `ℝ^4` has exactly `15` flats. -/
theorem card_braidFlats_four : Nat.card (braidFlats 4) = 15 := by
  rw [card_braidFlats, card_patterns_four]

end Geometry.KernelPatterns