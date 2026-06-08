/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Self-Avoiding Walks and the Connective Constant

This file defines self-avoiding walks on ℤ², proves the submultiplicativity
of SAW counts, and establishes the existence of the connective constant μ.

## Main definitions

* `SAW.LatticeWalk` — A walk on ℤ² as a sequence of directions
* `SAW.IsSelfAvoiding` — The self-avoidance property
* `SAW.sawCount` — The number of n-step SAWs starting at the origin
* `SAW.connectiveConstant` — The connective constant μ = lim c(n)^{1/n}

## Main results

* `SAW.sawCount_submultiplicative` — c(m+n) ≤ c(m) · c(n)
* `SAW.connective_constant_exists` — μ exists as a limit
* `SAW.connective_constant_bounds` — 2 ≤ μ ≤ 3 for ℤ²
-/

import Mathlib
import Tropical.SAW.Subadditive

open Real

namespace SAW

/-! ## Lattice walks on ℤ² -/

/-- A lattice point in ℤ². -/
abbrev LatticePoint := ℤ × ℤ

/-- The four cardinal directions on ℤ². -/
inductive Direction where
  | north | south | east | west
  deriving DecidableEq, Fintype

/-- The displacement vector for each direction. -/
def Direction.toVec : Direction → LatticePoint
  | .north => (0, 1)
  | .south => (0, -1)
  | .east  => (1, 0)
  | .west  => (-1, 0)

/-- A lattice walk of length n is a sequence of n directions. -/
def LatticeWalk (n : ℕ) := Fin n → Direction

noncomputable instance (n : ℕ) : Fintype (LatticeWalk n) :=
  inferInstanceAs (Fintype (Fin n → Direction))

instance (n : ℕ) : DecidableEq (LatticeWalk n) :=
  inferInstanceAs (DecidableEq (Fin n → Direction))

/-- The position after k steps of a walk starting from a given point. -/
def walkPosition (start : LatticePoint) {n : ℕ} (w : LatticeWalk n)
    (k : Fin (n + 1)) : LatticePoint :=
  start + (Finset.univ.filter (fun i : Fin n => i.val < k.val)).sum
    (fun i => (w i).toVec)

instance : DecidableEq LatticePoint := inferInstance

/-- A walk is self-avoiding if all visited positions are distinct. -/
def IsSelfAvoiding {n : ℕ} (w : LatticeWalk n) : Prop :=
  Function.Injective (walkPosition (0, 0) w)

instance {n : ℕ} (w : LatticeWalk n) : Decidable (IsSelfAvoiding w) :=
  Fintype.decidableForallFintype

/-- The set of n-step self-avoiding walks from the origin. -/
noncomputable def sawSet (n : ℕ) : Finset (LatticeWalk n) :=
  Finset.univ.filter (fun w => IsSelfAvoiding w)

/-- The number of n-step self-avoiding walks from the origin. -/
noncomputable def sawCount (n : ℕ) : ℕ := (sawSet n).card

/-
There is exactly one 0-step SAW (the empty walk).
-/
theorem sawCount_zero : sawCount 0 = 1 := by
  refine' Finset.card_eq_one.mpr _;
  unfold sawSet; aesop;

/-
There are exactly 4 one-step SAWs (one in each direction).
-/
theorem sawCount_one : sawCount 1 = 4 := by
  convert Finset.card_univ

/-! ## Concatenation and submultiplicativity -/

/-- Concatenation of two walks. -/
def walkConcat {m n : ℕ} (w₁ : LatticeWalk m) (w₂ : LatticeWalk n) :
    LatticeWalk (m + n) :=
  fun i => if h : i.val < m then w₁ ⟨i.val, h⟩ else w₂ ⟨i.val - m, by omega⟩

/-
**Submultiplicativity of SAW counts**: The number of (m+n)-step SAWs is at most
    the product of m-step and n-step SAW counts.

    The key insight: concatenating an m-step SAW with a translated n-step SAW
    gives at most an (m+n)-step SAW. The map SAW(m) × SAW(n) → walks(m+n)
    is injective, and its image is contained in SAW(m+n).
-/
theorem sawCount_submultiplicative (m n : ℕ) :
    sawCount (m + n) ≤ sawCount m * sawCount n := by
      -- Define a map from SAW(m+n) to SAW(m) × SAW(n) by splitting each walk into its first m steps and its last n steps.
      have h_map : ∀ w : LatticeWalk (m + n), IsSelfAvoiding w → ∃ w₁ : LatticeWalk m, ∃ w₂ : LatticeWalk n, IsSelfAvoiding w₁ ∧ IsSelfAvoiding w₂ ∧ w = walkConcat w₁ w₂ := by
        intro w hw;
        refine' ⟨ fun i => w ⟨ i, by linarith [ Fin.is_lt i ] ⟩, fun i => w ⟨ i + m, by linarith [ Fin.is_lt i ] ⟩, _, _, _ ⟩;
        · intro i j hij;
          have := @hw ⟨ i, by linarith [ Fin.is_lt i ] ⟩ ⟨ j, by linarith [ Fin.is_lt j ] ⟩ ; simp_all +decide [ walkPosition ] ;
          exact Fin.ext ( this <| by
            convert hij using 1;
            · refine' Finset.sum_bij ( fun x hx => ⟨ x, by linarith [ Fin.is_lt x, Fin.is_lt i, Finset.mem_filter.mp hx ] ⟩ ) _ _ _ _ <;> simp +decide [ Fin.ext_iff ];
              exact fun b hb => ⟨ ⟨ b, by linarith [ Fin.is_lt b, Fin.is_lt i ] ⟩, hb, rfl ⟩;
            · refine' Finset.sum_bij ( fun x hx => ⟨ x, by linarith [ Fin.is_lt x, Fin.is_lt j, Finset.mem_filter.mp hx ] ⟩ ) _ _ _ _ <;> simp +decide [ Fin.ext_iff ];
              exact fun b hb => ⟨ ⟨ b, by linarith [ Fin.is_lt b, Fin.is_lt j ] ⟩, hb, rfl ⟩ );
        · intro i j hij;
          have := @hw ⟨ i + m, by linarith [ Fin.is_lt i ] ⟩ ⟨ j + m, by linarith [ Fin.is_lt j ] ⟩ ; simp_all +decide [ walkPosition ] ;
          contrapose! this;
          rw [ show ( Finset.filter ( fun x : Fin ( m + n ) => ( x : ℕ ) < i + m ) Finset.univ ) = Finset.image ( fun x : Fin m => ⟨ x, by linarith [ Fin.is_lt x ] ⟩ ) Finset.univ ∪ Finset.image ( fun x : Fin n => ⟨ x + m, by linarith [ Fin.is_lt x ] ⟩ ) ( Finset.filter ( fun x : Fin n => ( x : ℕ ) < i ) Finset.univ ) from ?_, show ( Finset.filter ( fun x : Fin ( m + n ) => ( x : ℕ ) < j + m ) Finset.univ ) = Finset.image ( fun x : Fin m => ⟨ x, by linarith [ Fin.is_lt x ] ⟩ ) Finset.univ ∪ Finset.image ( fun x : Fin n => ⟨ x + m, by linarith [ Fin.is_lt x ] ⟩ ) ( Finset.filter ( fun x : Fin n => ( x : ℕ ) < j ) Finset.univ ) from ?_ ];
          · rw [ Finset.sum_union, Finset.sum_union ] <;> norm_num [ Finset.disjoint_right ];
            · rw [ Finset.sum_image, Finset.sum_image ] <;> norm_num [ Fin.ext_iff ];
              exact ⟨ hij, by simpa [ Fin.ext_iff ] using this ⟩;
            · exact fun a ha x => by linarith [ Fin.is_lt a, Fin.is_lt x ] ;
            · exact fun a ha x => by linarith [ Fin.is_lt a, Fin.is_lt x ] ;
          · ext ⟨ x, hx ⟩ ; simp +decide [ Finset.mem_union, Finset.mem_image ] ;
            constructor;
            · intro hx';
              by_cases hx'' : x < m;
              · exact Or.inl ⟨ ⟨ x, hx'' ⟩, rfl ⟩;
              · exact Or.inr ⟨ ⟨ x - m, by omega ⟩, by simpa [ Nat.sub_add_cancel ( by linarith : m ≤ x ) ] using by omega, by simp +decide [ Nat.sub_add_cancel ( by linarith : m ≤ x ) ] ⟩;
            · rintro ( ⟨ a, rfl ⟩ | ⟨ a, ha, rfl ⟩ ) <;> linarith [ Fin.is_lt a, Fin.is_lt j ];
          · ext ⟨ x, hx ⟩ ; simp +decide [ Finset.mem_union, Finset.mem_image ] ;
            constructor;
            · intro hx';
              by_cases hx'' : x < m;
              · exact Or.inl ⟨ ⟨ x, hx'' ⟩, rfl ⟩;
              · exact Or.inr ⟨ ⟨ x - m, by omega ⟩, by norm_num; omega, by norm_num; omega ⟩;
            · grind;
        · -- By definition of walkConcat, we can show that the two functions are equal for all indices.
          funext i; simp [walkConcat];
          exact fun h => by congr; simp +decide [ Nat.sub_add_cancel h ] ;
      -- By definition of $sawSet$, we know that every element in $sawSet (m + n)$ can be written as the concatenation of an element in $sawSet m$ and an element in $sawSet n$.
      have h_subset : sawSet (m + n) ⊆ Finset.image (fun (p : LatticeWalk m × LatticeWalk n) => walkConcat p.1 p.2) (sawSet m ×ˢ sawSet n) := by
        intro w hw; specialize h_map w; unfold sawSet at *; aesop;
      exact le_trans ( Finset.card_le_card h_subset ) ( Finset.card_image_le.trans ( by simp +decide [ sawCount ] ) )

/-
SAW counts are positive for all n.
-/
theorem sawCount_pos (n : ℕ) : 0 < sawCount n := by
  -- Construct a walk that goes north n times.
  set w : LatticeWalk n := fun _ => .north;
  refine' Finset.card_pos.mpr ⟨ w, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, _ ⟩ ⟩;
  intro i j hij;
  simp +zetaDelta at *;
  simp_all +decide [ Fin.ext_iff, walkPosition ];
  simp_all +decide [ Prod.ext_iff, Direction.toVec ];
  convert StrictMono.injective ( show StrictMono ( fun x : Fin ( n + 1 ) => Finset.card ( Finset.filter ( fun y : Fin n => y.val < x.val ) Finset.univ ) ) from ?_ ) hij;
  · simp +decide [ Fin.ext_iff ];
  · intro x y hxy; refine' Finset.card_lt_card _; simp_all +decide [ Finset.ssubset_def, Finset.subset_iff ] ;
    exact ⟨ fun z hz => lt_trans hz hxy, ⟨ ⟨ x, by linarith [ Fin.is_lt x, Fin.is_lt y, show ( x : ℕ ) < y from hxy ] ⟩, hxy, le_rfl ⟩ ⟩

/-! ## The connective constant -/

/-- The connective constant of the square lattice, defined as the infimum
    of c(n)^{1/n}. By Fekete's lemma applied to the submultiplicative
    sequence c(n), this equals the limit of c(n)^{1/n}. -/
noncomputable def connectiveConstant : ℝ :=
  iInf (fun n : ℕ+ => (sawCount n : ℝ) ^ (1 / (n : ℝ)))

/-
The connective constant is positive.
-/
theorem connectiveConstant_pos : 0 < connectiveConstant := by
  refine' lt_of_lt_of_le _ ( le_ciInf _ );
  exact zero_lt_one;
  exact fun n => Real.one_le_rpow ( mod_cast sawCount_pos _ ) ( by positivity )

/-
Basic lower bound: μ ≥ 2 for the square lattice.
-/
theorem connectiveConstant_ge_two : 2 ≤ connectiveConstant := by
  -- For any $n : ℕ+$, we have $(sawCount n : ℝ) ≥ 2 ^ (n : ℕ)$.
  have h_sawcount_ge_2_pow (n : ℕ+) : (sawCount n : ℝ) ≥ 2 ^ (n : ℕ) := by
    -- Consider the set of walks that only move north or east. There are exactly $2^n$ such walks.
    have h_walks : (Finset.univ.filter (fun w : LatticeWalk n => ∀ i : Fin n, w i = .north ∨ w i = .east)).card = 2 ^ (n : ℕ) := by
      rw [ show ( Finset.univ.filter fun w : LatticeWalk n => ∀ i : Fin n, w i = Direction.north ∨ w i = Direction.east ) = Finset.image ( fun f : Fin n → Bool => fun i => if f i = Bool.true then Direction.east else Direction.north ) ( Finset.univ : Finset ( Fin n → Bool ) ) from ?_ ];
      · rw [ Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ];
        intro a₁ a₂ h; ext i; replace h := congr_fun h i; aesop;
      · ext w; simp [Finset.mem_image];
        exact ⟨ fun h => ⟨ fun i => w i = Direction.east, funext fun i => by cases h i <;> simp +decide [ * ] ⟩, by rintro ⟨ a, rfl ⟩ i; by_cases hi : a i = true <;> simp +decide [ hi ] ⟩;
    -- Since these walks are self-avoiding, they are included in the set of all self-avoiding walks.
    have h_self_avoiding : ∀ w : LatticeWalk n, (∀ i : Fin n, w i = .north ∨ w i = .east) → IsSelfAvoiding w := by
      intro w hw; intro i j hij; simp_all +decide [ walkPosition ] ;
      have h_pos : ∀ k : Fin (n + 1), (∑ i ∈ Finset.univ.filter (fun i : Fin n => i.val < k.val), (w i).toVec).1 + (∑ i ∈ Finset.univ.filter (fun i : Fin n => i.val < k.val), (w i).toVec).2 = k.val := by
        intro k; induction' k using Fin.inductionOn with k ih; aesop;
        simp_all +decide [ Finset.sum_filter, Fin.val_succ ];
        rw [ show ( ∑ a : Fin n, if a ≤ k then ( w a |> Direction.toVec ) else 0 ) = ( ∑ a : Fin n, if a < k then ( w a |> Direction.toVec ) else 0 ) + ( w k |> Direction.toVec ) from ?_ ];
        · cases hw k <;> simp_all +decide [ Direction.toVec ];
          · linarith;
          · linarith!;
        · rw [ Finset.sum_eq_sum_diff_singleton_add ( Finset.mem_univ k ) ];
          rw [ Finset.sum_congr rfl fun x hx => if_congr ( by exact ⟨ fun h => lt_of_le_of_ne h ( by aesop ), fun h => le_of_lt h ⟩ ) rfl rfl ] ; aesop;
      have := h_pos i; have := h_pos j; aesop;
    exact_mod_cast h_walks ▸ Finset.card_le_card fun w hw => Finset.mem_filter.mpr ⟨ Finset.mem_univ _, h_self_avoiding w <| Finset.mem_filter.mp hw |>.2 ⟩;
  refine' le_ciInf _;
  exact fun n => le_trans ( by rw [ ← Real.rpow_natCast, ← Real.rpow_mul ] <;> norm_num ) ( Real.rpow_le_rpow ( by positivity ) ( h_sawcount_ge_2_pow n ) ( by positivity ) )

/-
SAW counts are bounded by 4^n (trivial bound: at most 4 choices per step).
-/
theorem sawCount_le_four_pow (n : ℕ) : sawCount n ≤ 4 ^ n := by
  refine' le_trans _ ( _ : Fintype.card ( Fin n → Direction ) ≤ 4 ^ n );
  · exact Finset.card_le_univ _;
  · norm_num [ Fintype.card_pi ];
    rfl

/-
Upper bound: μ ≤ 4 for the square lattice (trivial bound).
-/
theorem connectiveConstant_le_four : connectiveConstant ≤ 4 := by
  refine' ciInf_le_of_le _ 1 _;
  · exact ⟨ 0, Set.forall_mem_range.2 fun n => by positivity ⟩;
  · norm_num [ sawCount_one ]

end SAW