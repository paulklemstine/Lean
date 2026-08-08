/-
# Symmetries of snakes and the support (dimension-reduction) theorem

This file continues the snake-in-the-box development of
`Computation/SnakeInTheBox.lean` and `Computation/SnakeMax.lean`.

Everything proved so far about snakes has been *extrinsic*: counting bounds in a
fixed cube `Q n`, or explicit constructions.  What was missing is the action of
the automorphism group of the hypercube — the hyperoctahedral group
`(ℤ/2)ⁿ ⋊ Sₙ` — on the set of snakes, and the resulting *intrinsic* notion of
the dimension a snake really lives in.

The chain here is:

1. **Hamming distance under a coordinate embedding.**
   `hammingDist_comp_embedding`: if `x` and `y` agree off the range of an
   embedding `e : Fin k ↪ Fin n`, restricting along `e` does not change the
   Hamming distance.  This is the technical heart of the file.

2. **Translations.** `xorC` (coordinatewise `xor`) is an isometry of the cube
   (`hammingDist_xorC`) and preserves adjacency (`adj_xorC`), so
   `Snake.translate` turns a snake into a snake.  Consequence:
   `exists_snake_base_zero` — every achievable length is achieved by a snake
   starting at the all-`false` vertex.

3. **Coordinate permutations.** `Snake.permute` is the second half of the
   hyperoctahedral action.

4. **Reversal.** `Snake.reverse`: reading a snake backwards is a snake.  (Note
   this is *not* an automorphism of the cube; it is the extra `ℤ/2` coming from
   the path structure.)

5. **The support theorem.** `Snake.dirs` is the set of coordinates that are
   flipped somewhere along the snake, and every vertex agrees with `v 0` off
   `dirs` (`Snake.eq_zero_of_notMem_dirs`).  Restricting along the canonical
   embedding `Fin #dirs ↪ Fin n` gives `Snake.restrict : Snake #s.dirs L`:

   > **a snake that moves in `k` directions is a snake in `Q k`.**

   Hence `Snake.length_le_maxLen_dirs : L ≤ maxLen #s.dirs`, and the counting
   ceiling of the catalog is upgraded from a statement about the ambient
   dimension to a statement about the *intrinsic* dimension:
   `Snake.card_dirs_bound`, `Snake.four_le_card_dirs`
   (a snake with five or more edges must move in at least four directions),
   and `Snake.log_lower_card_dirs` (`L + 1 ≤ 3 · 2 ^ (#dirs - 2)`, so the
   number of directions grows at least logarithmically in the length).

None of the results here use `decide` or `native_decide`.
-/
import Mathlib
import Computation.SnakeInTheBox
import Computation.SnakeMax

namespace SnakeInTheBox

open Finset

variable {n L : ℕ}

/-! ## Step 1: Hamming distance under a coordinate embedding -/

/-- Restricting two cube vertices along a coordinate embedding `e` does not change
their Hamming distance, provided they already agree outside the range of `e`. -/
theorem hammingDist_comp_embedding {k n : ℕ} (e : Fin k ↪ Fin n) {x y : Cube n}
    (h : ∀ j, j ∉ Set.range e → x j = y j) :
    hammingDist (fun a => x (e a)) (fun a => y (e a)) = hammingDist x y := by
  classical
  simp only [hammingDist]
  refine Finset.card_nbij (i := fun a => e a) ?_ ?_ ?_
  · intro a ha
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and] at ha ⊢
    exact ha
  · intro a _ b _ hab
    exact e.injective hab
  · intro j hj
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and] at hj
    by_cases hr : j ∈ Set.range e
    · obtain ⟨a, rfl⟩ := hr
      exact ⟨a, by simpa using hj, rfl⟩
    · exact absurd (h j hr) hj

/-- Version of `hammingDist_comp_embedding` for a plain injective function; the
statement matches syntactically after `rw`. -/
theorem hammingDist_comp_inj {k n : ℕ} (f : Fin k → Fin n) (hf : Function.Injective f)
    {x y : Cube n} (h : ∀ j, (∀ a, f a ≠ j) → x j = y j) :
    hammingDist (fun a => x (f a)) (fun a => y (f a)) = hammingDist x y :=
  hammingDist_comp_embedding ⟨f, hf⟩ (fun j hj => h j (fun a hja => hj ⟨a, hja⟩))

/-! ## Step 2: translations -/

/-- Coordinatewise `xor`: translation of the cube by the vector `c`. -/
def xorC (x c : Cube n) : Cube n := fun j => xor (x j) (c j)

@[simp] theorem xorC_apply (x c : Cube n) (j : Fin n) : xorC x c j = xor (x j) (c j) := rfl

/-- Translation is an isometry of the hypercube. -/
theorem hammingDist_xorC (x y c : Cube n) : hammingDist (xorC x c) (xorC y c) = hammingDist x y := by
  simp only [hammingDist]
  congr 1
  apply Finset.filter_congr
  intro j _
  simp only [xorC_apply]
  cases hc : c j <;> cases hx : x j <;> cases hy : y j <;> simp

theorem flipAt_xorC (x c : Cube n) (i : Fin n) :
    flipAt (xorC x c) i = xorC (flipAt x i) c := by
  funext j
  by_cases hj : j = i
  · subst hj; simp [flipAt]
  · simp [flipAt, hj]

/-- Translation preserves adjacency. -/
theorem adj_xorC {x y : Cube n} (c : Cube n) (h : Adj x y) : Adj (xorC x c) (xorC y c) := by
  obtain ⟨i, rfl⟩ := h
  exact ⟨i, (flipAt_xorC x c i).symm⟩

/-- Translating a snake by a fixed vector gives a snake. -/
def Snake.translate (s : Snake n L) (c : Cube n) : Snake n L where
  v := fun i => xorC (s.v i) c
  step := fun i hi => adj_xorC c (s.step i hi)
  chord := fun i j hj hij => by
    rw [hammingDist_xorC]; exact s.chord i j hj hij

@[simp] theorem Snake.translate_v (s : Snake n L) (c : Cube n) (i : ℕ) :
    (s.translate c).v i = xorC (s.v i) c := rfl

/-- Every achievable snake length is achieved by a snake based at the origin. -/
theorem exists_snake_base_zero (s : Snake n L) :
    ∃ t : Snake n L, t.v 0 = (fun _ => false) := by
  refine ⟨s.translate (s.v 0), ?_⟩
  funext j
  simp only [Snake.translate_v, xorC_apply]
  cases s.v 0 j <;> simp

/-! ## Step 3: coordinate permutations -/

/-- Permuting the coordinates of a snake gives a snake. -/
def Snake.permute (s : Snake n L) (σ : Equiv.Perm (Fin n)) : Snake n L where
  v := fun i => fun a => s.v i (σ a)
  step := fun i hi => by
    obtain ⟨d, hd⟩ := s.step i hi
    refine ⟨σ.symm d, ?_⟩
    funext a
    have : s.v (i + 1) (σ a) = flipAt (s.v i) d (σ a) := by rw [hd]
    rw [this]
    by_cases ha : a = σ.symm d
    · subst ha; simp [flipAt]
    · have hne : σ a ≠ d := by
        intro hc; exact ha (by rw [← hc]; simp)
      simp [flipAt, ha, hne]
  chord := fun i j hj hij => by
    rw [hammingDist_comp_inj (fun a => σ a) σ.injective
      (fun c hc => absurd (σ.apply_symm_apply c) (hc (σ.symm c)))]
    exact s.chord i j hj hij

@[simp] theorem Snake.permute_v (s : Snake n L) (σ : Equiv.Perm (Fin n)) (i : ℕ) :
    (s.permute σ).v i = fun a => s.v i (σ a) := rfl

/-! ## Step 4: reversal -/

/-- A snake read backwards is a snake. -/
def Snake.reverse (s : Snake n L) : Snake n L where
  v := fun i => s.v (L - i)
  step := fun i hi => by
    have h1 : L - i = (L - (i + 1)) + 1 := by omega
    have h2 : L - (i + 1) < L := by omega
    rw [h1]
    exact adj_symm (s.step (L - (i + 1)) h2)
  chord := fun i j hj hij => by
    rw [hammingDist_comm]
    exact s.chord (L - j) (L - i) (by omega) (by omega)

@[simp] theorem Snake.reverse_v (s : Snake n L) (i : ℕ) : s.reverse.v i = s.v (L - i) := rfl

/-! ## Step 5: the set of directions used by a snake -/

/-- The **support** of a snake: the set of coordinates flipped at some step. -/
def Snake.dirs (s : Snake n L) : Finset (Fin n) :=
  univ.filter (fun c => ∃ i ∈ Finset.range L, s.v i c ≠ s.v (i + 1) c)

theorem Snake.mem_dirs {s : Snake n L} {c : Fin n} :
    c ∈ s.dirs ↔ ∃ i, i < L ∧ s.v i c ≠ s.v (i + 1) c := by
  simp [Snake.dirs]

/-- Off its support, a snake is constant. -/
theorem Snake.eq_zero_of_notMem_dirs (s : Snake n L) {c : Fin n} (hc : c ∉ s.dirs) :
    ∀ i, i ≤ L → s.v i c = s.v 0 c := by
  intro i
  induction i with
  | zero => intro _; rfl
  | succ m ih =>
      intro hm
      have hmL : m < L := by omega
      have h1 : s.v m c = s.v (m + 1) c := by
        by_contra hne
        exact hc (Snake.mem_dirs.2 ⟨m, hmL, hne⟩)
      rw [← h1]
      exact ih (by omega)

/-- The step direction at index `i` belongs to the support. -/
theorem Snake.step_dir_mem_dirs (s : Snake n L) {i : ℕ} (hi : i < L) {d : Fin n}
    (hd : s.v (i + 1) = flipAt (s.v i) d) : d ∈ s.dirs := by
  refine Snake.mem_dirs.2 ⟨i, hi, ?_⟩
  rw [hd, flipAt_apply_self]
  cases s.v i d <;> simp

/-! ## Step 6: the support theorem -/

/-- **Dimension reduction.** A snake of length `L` that moves in `k = #dirs`
directions is (isomorphic to) a snake of length `L` in the cube `Q k`. -/
def Snake.restrict (s : Snake n L) : Snake (#s.dirs) L where
  v := fun i => fun a => s.v i (s.dirs.orderEmbOfFin rfl a)
  step := fun i hi => by
    obtain ⟨d, hd⟩ := s.step i hi
    have hdm : d ∈ s.dirs := s.step_dir_mem_dirs hi hd
    have hrange : (d : Fin n) ∈ Set.range (s.dirs.orderEmbOfFin (rfl : #s.dirs = #s.dirs)) := by
      rw [Finset.range_orderEmbOfFin]; exact hdm
    obtain ⟨a, ha⟩ := hrange
    refine ⟨a, ?_⟩
    funext b
    have hb : s.v (i + 1) (s.dirs.orderEmbOfFin rfl b)
        = flipAt (s.v i) d (s.dirs.orderEmbOfFin rfl b) := by rw [hd]
    rw [hb]
    by_cases hba : b = a
    · subst hba
      simp [flipAt, ha]
    · have hne : (s.dirs.orderEmbOfFin (rfl : #s.dirs = #s.dirs) b) ≠ d := by
        intro hc
        exact hba ((s.dirs.orderEmbOfFin rfl).injective (by rw [hc, ha]))
      simp [flipAt, hba, hne]
  chord := fun i j hj hij => by
    have hagree : ∀ c : Fin n,
        (∀ a, s.dirs.orderEmbOfFin (rfl : #s.dirs = #s.dirs) a ≠ c) → s.v i c = s.v j c := by
      intro c hc
      have hcd : c ∉ s.dirs := by
        intro hmem
        have : c ∈ Set.range (s.dirs.orderEmbOfFin (rfl : #s.dirs = #s.dirs)) := by
          rw [Finset.range_orderEmbOfFin]; exact hmem
        obtain ⟨a, ha⟩ := this
        exact hc a ha
      rw [s.eq_zero_of_notMem_dirs hcd i (by omega),
        s.eq_zero_of_notMem_dirs hcd j (by omega)]
    rw [hammingDist_comp_inj (fun a => s.dirs.orderEmbOfFin rfl a)
      (fun a b hab => (s.dirs.orderEmbOfFin rfl).injective hab) hagree]
    exact s.chord i j hj hij

/-- The length of a snake is bounded by the maximal snake length in the cube of
its own intrinsic dimension. -/
theorem Snake.length_le_maxLen_dirs (s : Snake n L) : L ≤ maxLen (#s.dirs) :=
  le_maxLen s.restrict

/-- The support of a snake never exceeds the ambient dimension. -/
theorem Snake.card_dirs_le (s : Snake n L) : #s.dirs ≤ n := by
  simpa using Finset.card_le_univ s.dirs

/-! ## Step 7: consequences -/

/-- In dimension at most three no snake has more than four edges. -/
theorem maxLen_le_four_of_le_three {k : ℕ} (hk : k ≤ 3) : maxLen k ≤ 4 := by
  interval_cases k
  · obtain ⟨s⟩ := exists_snake_maxLen 0
    have := s.card_le_pow
    simp at this
    omega
  · obtain ⟨s⟩ := exists_snake_maxLen 1
    have := s.card_le_pow
    norm_num at this
    omega
  · rw [maxLen_two]; norm_num
  · rw [maxLen_three]

/-- A snake with at least five edges must move in at least four different
directions: length five is impossible inside any three-dimensional subcube. -/
theorem Snake.four_le_card_dirs (s : Snake n L) (hL : 5 ≤ L) : 4 ≤ #s.dirs := by
  by_contra h
  have hk : #s.dirs ≤ 3 := by omega
  have := s.length_le_maxLen_dirs
  have := maxLen_le_four_of_le_three hk
  omega

/-- The counting ceiling, stated in the **intrinsic** dimension of the snake:
a snake of length `L` moving in `k ≥ 3` directions satisfies `L + 1 < 3 · 2 ^ (k - 2)`.
This is strictly stronger than the ambient statement whenever the snake does not
use all coordinates. -/
theorem Snake.card_dirs_bound (s : Snake n L) (hk : 3 ≤ #s.dirs) :
    L + 1 < 3 * 2 ^ (#s.dirs - 2) := by
  have h1 := s.length_le_maxLen_dirs
  have h2 := maxLen_upper (n := #s.dirs) hk
  omega

/-- The number of directions a snake uses grows at least logarithmically in its
length: `L + 1 ≤ 3 · 2 ^ (#dirs - 2)` with no hypothesis on the support size. -/
theorem Snake.log_lower_card_dirs (s : Snake n L) : L + 1 ≤ 3 * 2 ^ (#s.dirs - 2) := by
  by_cases hk : 3 ≤ #s.dirs
  · exact le_of_lt (s.card_dirs_bound hk)
  · have hk' : #s.dirs ≤ 2 := by omega
    have h1 := s.length_le_maxLen_dirs
    have h2 := maxLen_le_four_of_le_three (k := #s.dirs) (by omega)
    interval_cases h : #s.dirs
    · have : maxLen 0 = 0 := by
        obtain ⟨t⟩ := exists_snake_maxLen 0
        have := t.card_le_pow
        simp at this
        omega
      omega
    · have : maxLen 1 ≤ 1 := by
        obtain ⟨t⟩ := exists_snake_maxLen 1
        have := t.card_le_pow
        norm_num at this
        omega
      norm_num
      omega
    · rw [maxLen_two] at h1
      norm_num
      omega

/-- **Summary.** The intrinsic form of the snake-in-the-box ceiling: for every
snake, the number of coordinate directions it uses is at most the ambient
dimension, its length is bounded by the maximal length in that many dimensions,
and the counting ceiling applies in the intrinsic dimension. -/
theorem Snake.intrinsic_bounds (s : Snake n L) :
    #s.dirs ≤ n ∧ L ≤ maxLen (#s.dirs) ∧ L + 1 ≤ 3 * 2 ^ (#s.dirs - 2) :=
  ⟨s.card_dirs_le, s.length_le_maxLen_dirs, s.log_lower_card_dirs⟩

end SnakeInTheBox