import Geometry.KernelPatterns.Core

/-!
# Counting kernel patterns: orbits, set partitions and the Bell numbers

Building on `Geometry.KernelPatterns.Core`, this file counts kernel patterns.

* `orbit_card_eq_card_patterns` — the number of `Sym(Fin m)`-orbits on the
  configuration space `(Fin m)^n` of `n`-tuples equals `(patterns n m).card`.
  (This is the counting form of the completeness theorem `perm_orbit_iff_pat_eq`.)
* `patternsEquivSetoid` — kernel patterns of length `n` are in bijection with
  equivalence relations (i.e. set partitions) on `Fin n`.
* `card_patterns_le_five` — the first six values of the pattern-counting
  sequence are the Bell numbers `1, 1, 2, 5, 15, 52` (OEIS A000110), agreeing
  with Mathlib's `Nat.bell`.
* `card_patterns_eq_sum_blocks` — the refinement of the count by the number of
  blocks.
-/

namespace Geometry.KernelPatterns

open Finset

/-- Kernel patterns of `n`-tuples using exactly `k` distinct values (i.e. set
partitions of `Fin n` into exactly `k` blocks). -/
def patternsWith (n k : ℕ) : Finset (Fin n → Fin n) :=
  (patterns n n).filter fun p => (univ.image p).card = k

/-- `patterns n n` is the finset of idempotent tuples. -/
theorem patterns_self_eq_filter (n : ℕ) :
    patterns n n = univ.filter fun p : Fin n → Fin n => pat p = p := by
  ext p
  simp [mem_patterns_self]

/-! ### Orbit counting -/

section Orbits

variable (n m : ℕ)

/-- The pattern map descends to the orbit space of the `Sym(Fin m)`-action on
`n`-tuples, and identifies it with the finset of patterns. -/
theorem orbit_card_eq_card_patterns :
    Nat.card (MulAction.orbitRel.Quotient (Equiv.Perm (Fin m)) (Fin n → Fin m))
      = (patterns n m).card := by
  classical
  have hwd : ∀ x y : Fin n → Fin m,
      MulAction.orbitRel (Equiv.Perm (Fin m)) (Fin n → Fin m) x y →
        (⟨pat x, Finset.mem_image_of_mem _ (Finset.mem_univ x)⟩ : ↥(patterns n m))
          = ⟨pat y, Finset.mem_image_of_mem _ (Finset.mem_univ y)⟩ := by
    intro x y h
    obtain ⟨σ, hσ⟩ := h
    have hcomp : σ ∘ y = x := funext fun i => congrFun hσ i
    have hpat : pat x = pat y := by rw [← hcomp]; exact pat_perm σ y
    exact Subtype.ext hpat
  let f : MulAction.orbitRel.Quotient (Equiv.Perm (Fin m)) (Fin n → Fin m) →
      ↥(patterns n m) :=
    Quotient.lift (fun x => (⟨pat x, Finset.mem_image_of_mem _ (Finset.mem_univ x)⟩ :
      ↥(patterns n m))) hwd
  have hbij : Function.Bijective f := by
    constructor
    · rintro ⟨x⟩ ⟨y⟩ hxy
      have hp : pat x = pat y := congrArg Subtype.val hxy
      obtain ⟨σ, hσ⟩ := exists_perm_of_pat_eq hp
      refine Quotient.sound ⟨σ⁻¹, funext fun i => ?_⟩
      have : σ (x i) = y i := congrFun hσ i
      simp [Equiv.Perm.smul_def, ← this]
    · rintro ⟨p, hp⟩
      obtain ⟨x, -, rfl⟩ := Finset.mem_image.1 hp
      exact ⟨Quotient.mk _ x, rfl⟩
  rw [Nat.card_eq_of_bijective f hbij, Nat.card_eq_finsetCard]

end Orbits

/-! ### Patterns are set partitions -/

/-- The kernel of a tuple, as an equivalence relation on the index set. -/
def kerSetoid {n : ℕ} {X : Type*} (x : Fin n → X) : Setoid (Fin n) where
  r i j := x i = x j
  iseqv := ⟨fun _ => rfl, fun h => h.symm, fun h h' => h.trans h'⟩

open Classical in
/-- **Kernel patterns are exactly the set partitions of the index set**: the map
sending a pattern to its kernel relation is a bijection onto `Setoid (Fin n)`. -/
noncomputable def patternsEquivSetoid (n : ℕ) : ↥(patterns n n) ≃ Setoid (Fin n) where
  toFun p := kerSetoid (p : Fin n → Fin n)
  invFun s := ⟨pat (fun i => Quotient.mk s i), by
    rw [mem_patterns_self]; exact pat_idem _⟩
  left_inv := by
    rintro ⟨p, hp⟩
    rw [mem_patterns_self] at hp
    apply Subtype.ext
    show (pat fun i => Quotient.mk (kerSetoid p) i) = p
    have : pat (fun i => Quotient.mk (kerSetoid p) i) = pat p :=
      pat_congr fun k l => by
        constructor
        · intro h; exact Quotient.exact h
        · intro h; exact Quotient.sound h
    rw [this, hp]
  right_inv := by
    intro s
    have hiff : ∀ k l : Fin n,
        pat (fun i => Quotient.mk s i) k = pat (fun i => Quotient.mk s i) l ↔ s.r k l := by
      intro k l
      rw [pat_eq_iff]
      exact ⟨fun h => Quotient.exact h, fun h => Quotient.sound h⟩
    exact Setoid.ext hiff

/-! ### Refining the count by the number of blocks -/

theorem card_patterns_eq_sum_blocks (n : ℕ) :
    (patterns n n).card = ∑ k ∈ range (n + 1), (patternsWith n k).card := by
  classical
  refine Finset.card_eq_sum_card_fiberwise (f := fun p => (univ.image p).card) ?_
  intro p _
  have : (univ.image p).card ≤ n := by simpa using Finset.card_le_univ (univ.image p)
  simpa [Nat.lt_succ_iff] using this

/-! ### The Bell numbers `1, 1, 2, 5, 15, 52` -/

theorem bell_three : Nat.bell 3 = 5 := by simp [Nat.bell, Fin.sum_univ_succ]

theorem bell_four : Nat.bell 4 = 15 := by simp [Nat.bell, Fin.sum_univ_succ]

theorem bell_five : Nat.bell 5 = 52 := by
  have h : Nat.choose 4 2 = 6 := by decide
  simp [Nat.bell, Fin.sum_univ_succ, h]

theorem card_patterns_zero : (patterns 0 0).card = 1 := by
  rw [patterns_self_eq_filter]; decide

theorem card_patterns_one : (patterns 1 1).card = 1 := by
  rw [patterns_self_eq_filter]; decide

theorem card_patterns_two : (patterns 2 2).card = 2 := by
  rw [patterns_self_eq_filter]; decide

set_option maxRecDepth 4000 in
theorem card_patterns_three : (patterns 3 3).card = 5 := by
  rw [patterns_self_eq_filter]; decide

set_option maxRecDepth 40000 in
theorem card_patterns_four : (patterns 4 4).card = 15 := by
  rw [patterns_self_eq_filter]; decide

set_option maxRecDepth 1000000 in
theorem card_patterns_five : (patterns 5 5).card = 52 := by
  rw [patterns_self_eq_filter]; decide

/-- **The pattern-counting sequence begins with the Bell numbers.**  For
`n = 0, 1, 2, 3, 4, 5` the number of kernel patterns of `n`-tuples equals
`Nat.bell n`, i.e. `1, 1, 2, 5, 15, 52` (OEIS A000110). -/
theorem card_patterns_eq_bell_le_five :
    (patterns 0 0).card = Nat.bell 0 ∧ (patterns 1 1).card = Nat.bell 1 ∧
      (patterns 2 2).card = Nat.bell 2 ∧ (patterns 3 3).card = Nat.bell 3 ∧
      (patterns 4 4).card = Nat.bell 4 ∧ (patterns 5 5).card = Nat.bell 5 :=
  ⟨by rw [card_patterns_zero, Nat.bell_zero],
   by rw [card_patterns_one, Nat.bell_one],
   by rw [card_patterns_two, Nat.bell_two],
   by rw [card_patterns_three, bell_three],
   by rw [card_patterns_four, bell_four],
   by rw [card_patterns_five, bell_five]⟩

/-- Consequently the number of `Sym(Fin 5)`-orbits of `5`-tuples is `52`. -/
theorem orbit_card_five :
    Nat.card (MulAction.orbitRel.Quotient (Equiv.Perm (Fin 5)) (Fin 5 → Fin 5)) = 52 := by
  rw [orbit_card_eq_card_patterns, card_patterns_five]

end Geometry.KernelPatterns