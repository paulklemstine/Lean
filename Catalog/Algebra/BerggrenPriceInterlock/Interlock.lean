import Algebra.BerggrenPriceInterlock.NNode

/-!
# Berggren–Price interlock, Part IV: inequivalence, leg-swap asymmetry, depth duality

The two trees of Part II share a vertex set and a root but are *inequivalent descents*.
This file proves three exact separations and one cost comparison.

1. **Determinant obstruction.**  In Euclid coordinates the Berggren generators have
   determinants `+1, -1, +1` and the Price generators `-2, +2, +2`; since determinants
   are conjugation invariants, no invertible change of coordinates carries a Berggren
   generator to a Price generator (`no_conjugacy`).
2. **Leg-swap asymmetry.**  On triples both trees act linearly (`bergT_action`,
   `priceT_action`: the Veronese lift of the `2×2` maps).  Swapping the two legs
   permutes the Berggren generators (`swap_bergT_zero/one/two`) but carries no Price
   generator to a Price generator (`swap_priceT_ne`).
3. **Depth duality.**  Price depth is size-driven: `price_fst_le` gives `m ≤ 2^(d+1)`,
   hence the level containing a node has more than `m` nodes (`price_level_gt_fermat`) —
   already more work than Fermat's whole scan, which takes `m - r` steps.  Berggren depth
   is *not* size-driven: on the staircase family the Berggren depth is exponential in the
   Price depth (`depth_duality`).
-/

namespace BerggrenPrice

open Matrix

/-! ### Euclid-coordinate matrices and the determinant obstruction -/

/-- The Berggren generators as `2×2` integer matrices acting on `(m,n)`. -/
def bergMat : Fin 3 → Matrix (Fin 2) (Fin 2) ℤ
  | 0 => !![2, -1; 1, 0]
  | 1 => !![2, 1; 1, 0]
  | 2 => !![1, 2; 0, 1]

/-- The Price generators as `2×2` integer matrices acting on `(m,n)`. -/
def priceMat : Fin 3 → Matrix (Fin 2) (Fin 2) ℤ
  | 0 => !![2, 0; 1, -1]
  | 1 => !![2, 0; 1, 1]
  | 2 => !![1, 1; 0, 2]

/-- `(m,n)` as a column vector. -/
def vec (v : Node) : Fin 2 → ℤ := ![v.1, v.2]

theorem bergMat_action (i : Fin 3) (v : Node) : bergMat i *ᵥ vec v = vec (berg i v) := by
  funext j
  fin_cases i <;> fin_cases j <;>
    (simp [bergMat, vec, berg, bA, bB, bC, Matrix.mulVec, dotProduct, Fin.sum_univ_two]
     try ring)

theorem priceMat_action (i : Fin 3) (v : Node) : priceMat i *ᵥ vec v = vec (price i v) := by
  funext j
  fin_cases i <;> fin_cases j <;>
    (simp [priceMat, vec, price, pA, pB, pC, Matrix.mulVec, dotProduct, Fin.sum_univ_two]
     try ring)

theorem det_bergMat : ∀ i, (bergMat i).det = if i = 1 then -1 else 1 := by
  decide +kernel

theorem det_priceMat : ∀ i, (priceMat i).det = if i = 0 then -2 else 2 := by
  decide +kernel

/-- **Determinant obstruction / no conjugacy.**  No invertible change of coordinates
intertwines a Berggren generator with a Price generator: `|det|` is `1` versus `2`. -/
theorem no_conjugacy (S : Matrix (Fin 2) (Fin 2) ℤ) (hS : S.det ≠ 0) (i j : Fin 3) :
    S * bergMat i ≠ priceMat j * S := by
  intro h
  have hdet := congrArg Matrix.det h
  rw [Matrix.det_mul, Matrix.det_mul] at hdet
  fin_cases i <;> fin_cases j <;>
    · simp [bergMat, priceMat, Matrix.det_fin_two_of] at hdet
      omega

/-! ### Triple coordinates: both trees are linear, only Berggren is leg-symmetric -/

/-- The triple `(m² - n², 2mn, m² + n²)` as a column vector. -/
def tvec (v : Node) : Fin 3 → ℤ := ![oddLeg v, evenLeg v, hypot v]

/-- The Berggren generators on triples (the classical Barning–Hall matrices). -/
def bergT : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
  | 0 => !![1, -2, 2; 2, -1, 2; 2, -2, 3]
  | 1 => !![1, 2, 2; 2, 1, 2; 2, 2, 3]
  | 2 => !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- The Price generators on triples. -/
def priceT : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
  | 0 => !![2, 1, 1; 2, -2, 2; 2, -1, 3]
  | 1 => !![2, -1, 1; 2, 2, 2; 2, 1, 3]
  | 2 => !![2, 1, -1; -2, 2, 2; -2, 1, 3]

/-- The leg-swap involution `(a,b,c) ↦ (b,a,c)`. -/
def swapT : Matrix (Fin 3) (Fin 3) ℤ := !![0, 1, 0; 1, 0, 0; 0, 0, 1]

theorem bergT_action (i : Fin 3) (v : Node) : bergT i *ᵥ tvec v = tvec (berg i v) := by
  funext j
  fin_cases i <;> fin_cases j <;>
    simp [bergT, tvec, berg, bA, bB, bC, oddLeg, evenLeg, hypot, Matrix.mulVec,
      dotProduct, Fin.sum_univ_three] <;> ring

theorem priceT_action (i : Fin 3) (v : Node) : priceT i *ᵥ tvec v = tvec (price i v) := by
  funext j
  fin_cases i <;> fin_cases j <;>
    simp [priceT, tvec, price, pA, pB, pC, oddLeg, evenLeg, hypot, Matrix.mulVec,
      dotProduct, Fin.sum_univ_three] <;> ring

theorem swap_bergT_zero : swapT * bergT 0 * swapT = bergT 2 := by decide +kernel

theorem swap_bergT_one : swapT * bergT 1 * swapT = bergT 1 := by decide +kernel

theorem swap_bergT_two : swapT * bergT 2 * swapT = bergT 0 := by decide +kernel

/-- **Leg-swap asymmetry.**  Conjugating a Price generator by the leg swap never yields a
Price generator: the `(1,0)` entry becomes odd, while every Price generator has an even
first column. -/
theorem swap_priceT_ne (i j : Fin 3) : swapT * priceT i * swapT ≠ priceT j := by
  fin_cases i <;> fin_cases j <;> decide +kernel

/-! ### Depth duality and the traversal-cost comparison -/

theorem isNode_applyWord_berg (w : List (Fin 3)) : IsNode (applyWord berg w root) :=
  isNode_applyWord berg isNode_berg w isNode_root

theorem isNode_applyWord_price (w : List (Fin 3)) : IsNode (applyWord price w root) :=
  isNode_applyWord price isNode_price w isNode_root

/-- Price steps at most double `m`: after `d` steps `m ≤ 2^(d+1)`.  Price depth is
therefore at least `log₂ m - 1`: it is *size-driven*. -/
theorem price_fst_le (w : List (Fin 3)) :
    (applyWord price w root).1 ≤ 2 ^ (w.length + 1) := by
  induction w with
  | nil => norm_num [root]
  | cons i w ih =>
    have hnode := isNode_applyWord_price w
    have hstep : (price i (applyWord price w root)).1 ≤ 2 * (applyWord price w root).1 := by
      obtain ⟨-, h2, -, -⟩ := hnode
      fin_cases i <;> (simp [price, pA, pB, pC]; try omega)
    have : (2 : ℤ) * (applyWord price w root).1 ≤ 2 * 2 ^ (w.length + 1) := by linarith
    calc (applyWord price (i :: w) root).1 ≤ 2 * (applyWord price w root).1 := hstep
      _ ≤ 2 * 2 ^ (w.length + 1) := this
      _ = 2 ^ ((i :: w).length + 1) := by simp [pow_succ]; ring

/-- Berggren steps at most triple `m`, so only `m ≤ 2·3^d`: no logarithmic depth bound. -/
theorem berg_fst_le (w : List (Fin 3)) :
    (applyWord berg w root).1 ≤ 2 * 3 ^ w.length := by
  induction w with
  | nil => norm_num [root]
  | cons i w ih =>
    have hnode := isNode_applyWord_berg w
    have hstep : (berg i (applyWord berg w root)).1 ≤ 3 * (applyWord berg w root).1 := by
      obtain ⟨h1, h2, -, -⟩ := hnode
      fin_cases i <;> simp [berg, bA, bB, bC] <;> omega
    calc (applyWord berg (i :: w) root).1 ≤ 3 * (applyWord berg w root).1 := hstep
      _ ≤ 3 * (2 * 3 ^ w.length) := by linarith
      _ = 2 * 3 ^ ((i :: w).length) := by simp [pow_succ]; ring

/-- The Price level containing a node has `3^d` nodes with `m³ ≤ 8·(3^d)²`. -/
theorem price_level_cube (w : List (Fin 3)) :
    (applyWord price w root).1 ^ 3 ≤ 8 * (3 ^ w.length : ℤ) ^ 2 := by
  have hm : (applyWord price w root).1 ≤ 2 ^ (w.length + 1) := price_fst_le w
  have hpos : (0 : ℤ) ≤ (applyWord price w root).1 := by
    have := (isNode_applyWord_price w).2.1
    have := (isNode_applyWord_price w).1
    omega
  calc (applyWord price w root).1 ^ 3 ≤ (2 ^ (w.length + 1) : ℤ) ^ 3 :=
        pow_le_pow_left₀ hpos hm 3
    _ = 8 * (8 ^ w.length : ℤ) := by
        rw [← pow_mul, show (w.length + 1) * 3 = 3 * w.length + 3 by ring, pow_add, pow_mul]
        norm_num
        ring
    _ ≤ 8 * (9 ^ w.length : ℤ) := by
        have h89 : (8 : ℤ) ^ w.length ≤ 9 ^ w.length :=
          pow_le_pow_left₀ (by norm_num) (by norm_num) _
        linarith
    _ = 8 * (3 ^ w.length : ℤ) ^ 2 := by
        rw [← pow_mul, mul_comm w.length 2, pow_mul]
        norm_num

/-- **Traversal beats nothing.**  For any node of size `m ≥ 9` the Price level that
contains it already has more than `m` members, while Fermat's entire scan takes at most
`m - r ≤ m` trial values.  Enumerating the tree level is strictly more work. -/
theorem price_level_gt_fermat (w : List (Fin 3)) (h : 9 ≤ (applyWord price w root).1) :
    (applyWord price w root).1 < 3 ^ w.length := by
  set m := (applyWord price w root).1 with hm
  set X : ℤ := 3 ^ w.length with hX
  have hXpos : (0 : ℤ) < X := by positivity
  have hcube : m ^ 3 ≤ 8 * X ^ 2 := price_level_cube w
  by_contra hcon
  push_neg at hcon
  have hm0 : (0 : ℤ) < m := by linarith
  have hX2 : X ^ 2 ≤ m ^ 2 := by nlinarith
  have hm3 : 9 * m ^ 2 ≤ m ^ 3 := by nlinarith
  have hsq : (0 : ℤ) < m ^ 2 := by positivity
  linarith

/-! #### The staircase family: Berggren depth exponential in Price depth -/

theorem berg_replicate (k : ℕ) :
    applyWord berg (List.replicate k 2) root = (2 * (k : ℤ) + 2, 1) := by
  induction k with
  | zero => simp [root]
  | succ k ih =>
    rw [List.replicate_succ, applyWord_cons, ih]
    show bC _ = _
    refine Prod.ext ?_ ?_ <;> (simp [bC]; try ring)

theorem price_replicate (i : ℕ) :
    applyWord price (List.replicate i 1) root = (2 ^ (i + 1), 2 ^ (i + 1) - 1) := by
  induction i with
  | zero => simp [root]
  | succ i ih =>
    rw [List.replicate_succ, applyWord_cons, ih]
    show pB _ = _
    refine Prod.ext ?_ ?_ <;> (simp [pB]; try ring)

theorem price_staircase (i : ℕ) :
    applyWord price (0 :: List.replicate i 1) root = (2 ^ (i + 2), 1) := by
  rw [applyWord_cons, price_replicate]
  show pA _ = _
  refine Prod.ext ?_ ?_ <;> (simp [pA]; try ring)

theorem berg_staircase (i : ℕ) :
    applyWord berg (List.replicate (2 ^ (i + 1) - 1) 2) root = (2 ^ (i + 2), 1) := by
  rw [berg_replicate]
  have h1 : 1 ≤ 2 ^ (i + 1) := Nat.one_le_two_pow
  refine Prod.ext ?_ ?_
  · show 2 * ((2 ^ (i + 1) - 1 : ℕ) : ℤ) + 2 = 2 ^ (i + 2)
    rw [Nat.cast_sub h1]
    push_cast
    ring
  · rfl

theorem isNode_staircase (i : ℕ) : IsNode ((2 : ℤ) ^ (i + 2), 1) := by
  have h2 : (4 : ℤ) ≤ 2 ^ (i + 2) := by
    calc (4 : ℤ) = 2 ^ 2 := by norm_num
      _ ≤ 2 ^ (i + 2) := by
          exact pow_le_pow_right₀ (by norm_num) (by omega)
  refine ⟨le_refl 1, by simpa using by linarith, isCoprime_one_right, ?_⟩
  refine ⟨2 ^ (i + 1), ?_⟩
  show (2 : ℤ) ^ (i + 2) + 1 = 2 * 2 ^ (i + 1) + 1
  rw [pow_succ]
  ring

/-- **Depth duality (exact).**  The staircase node `(2^(i+2), 1)` sits at Berggren depth
`2^(i+1) - 1` and Price depth `i + 1`: the Berggren address is exponentially longer.
Berggren depth is ratio-driven, Price depth is size-driven; the two orderings of the
shared vertex set are incomparable. -/
theorem depth_duality (i : ℕ) :
    (∀ w : List (Fin 3), applyWord berg w root = (2 ^ (i + 2), 1) →
        w.length = 2 ^ (i + 1) - 1) ∧
    (∀ w : List (Fin 3), applyWord price w root = (2 ^ (i + 2), 1) → w.length = i + 1) := by
  obtain ⟨wb, -, hub⟩ := berg_tree _ (isNode_staircase i)
  obtain ⟨wp, -, hup⟩ := price_tree _ (isNode_staircase i)
  constructor
  · intro w hw
    have h1 : w = wb := hub w hw
    have h2 : List.replicate (2 ^ (i + 1) - 1) (2 : Fin 3) = wb := hub _ (berg_staircase i)
    rw [h1, ← h2, List.length_replicate]
  · intro w hw
    have h1 : w = wp := hup w hw
    have h2 : (0 : Fin 3) :: List.replicate i 1 = wp := hup _ (price_staircase i)
    rw [h1, ← h2]
    simp

end BerggrenPrice