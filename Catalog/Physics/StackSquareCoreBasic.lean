import Mathlib

/-!
# Stack polyominoes with a square core: the counting function

A *stack polyomino* of area `n` is a column-convex, bottom-justified polyomino whose
sequence of column heights `h₁, …, h_r` (all `≥ 1`, summing to `n`) is **unimodal**:
it weakly increases up to a maximum and then weakly decreases.  Its *core* is the
maximal plateau, i.e. the block of columns of maximal height `k`.  The stack has a
**square core** when that plateau consists of exactly `k` columns, so that the top block
is a `k × k` square.

Slicing such a stack as

  (left slope) ++ (k × k square) ++ (right slope)

where both slopes are partitions into parts `≤ k - 1` (weakly increasing on the left,
weakly decreasing on the right) yields the counting formula

  a(n) = Σ_{k² ≤ n}  Σ_{i + j = n - k²}  p_{≤ k-1}(i) · p_{≤ k-1}(j),

equivalently the generating function `Σ_k x^{k²} / ∏_{i=1}^{k-1}(1 - x^i)²`.
The combinatorial justification of this formula (a bijection with genuine column-height
lists) is carried out in `Physics.StackSquareCoreStacks`; here we develop the arithmetic
layer.

## Main results

* `pb_rec` : the Euler recurrence `p_{≤b+1}(m) = p_{≤b}(m) + p_{≤b+1}(m - (b+1))`.
* `two_pow_le_pb` : `2^b ≤ p_{≤ b+1}(m)` as soon as `b(b+3) ≤ 2m`.
* `pb_le_pow` : `p_{≤ b+1}(m) ≤ (m+1)^b`.
* `stackSC_table` : the first 32 values agree with the catalogued OEIS data
  `1,1,0,0,1,2,3,4,5,7,9,13,17,24,31,42,54,71,90,117,147,188,236,298,371,466,576,716,882,
  1088,1331,1633`.
* `stackSC_eq_zero_iff` : `a(n) = 0 ↔ n = 2 ∨ n = 3`.
* `stackSC_mono` : `a` is non-decreasing from `n = 4` on.
* `stackSC_linear_lower` : `n - 3 ≤ a(n)` for `n ≥ 4` (exactly the `k = 2` layer).
* `two_pow_le_stackSC` : `2^m ≤ a(n)` whenever `3m² + 11m + 8 ≤ 2n`, i.e. `a(n)` grows at
  least like `exp(c √n)`.
* `stackSC_le_pow` : `a(n) ≤ (n+1)^(2 √n + 2)`, an `exp(C √n log n)` upper bound.
* `stackSC_superpolynomial` : for every `d`, eventually `n^d ≤ a(n)`.
-/

namespace Physics.StackSquareCore

open Finset Filter Asymptotics

/-! ## Bounded partition numbers -/

/-- `pb b m` is the number of partitions of `m` into parts of size at most `b`.
The recursion chooses the multiplicity `c` of the largest allowed part `b+1`. -/
def pb : ℕ → ℕ → ℕ
  | 0, m => if m = 0 then 1 else 0
  | (b + 1), m => ∑ c ∈ range (m / (b + 1) + 1), pb b (m - c * (b + 1))

@[simp] lemma pb_zero_left (m : ℕ) : pb 0 m = if m = 0 then 1 else 0 := rfl

lemma pb_succ_left (b m : ℕ) :
    pb (b + 1) m = ∑ c ∈ range (m / (b + 1) + 1), pb b (m - c * (b + 1)) := rfl

@[simp] lemma pb_zero_right (b : ℕ) : pb b 0 = 1 := by
  induction b with
  | zero => simp
  | succ b ih => rw [pb_succ_left]; simp [ih]

@[simp] lemma pb_one_left (m : ℕ) : pb 1 m = 1 := by
  rw [pb_succ_left]
  simp only [pb_zero_left]
  rw [Finset.sum_eq_single m] <;> simp +contextual [Nat.sub_eq_zero_iff_le]
  omega

/-- Enlarging the allowed part size can only increase the count. -/
lemma pb_le_succ_left (b m : ℕ) : pb b m ≤ pb (b + 1) m := by
  rw [pb_succ_left]
  have h0 : (0 : ℕ) ∈ range (m / (b + 1) + 1) := by simp
  calc pb b m = pb b (m - 0 * (b + 1)) := by simp
    _ ≤ _ := Finset.single_le_sum (f := fun c => pb b (m - c * (b + 1)))
                (fun i _ => Nat.zero_le _) h0

lemma pb_pos (b m : ℕ) (hb : 1 ≤ b) : 0 < pb b m := by
  induction b generalizing m with
  | zero => omega
  | succ b ih =>
      rcases Nat.eq_zero_or_pos b with rfl | hb0
      · simp
      · exact lt_of_lt_of_le (ih m hb0) (pb_le_succ_left b m)

lemma pb_rec_of_lt (b m : ℕ) (h : m < b + 1) : pb (b + 1) m = pb b m := by
  have h1 : m / (b + 1) = 0 := Nat.div_eq_of_lt h
  rw [pb_succ_left, h1]
  simp

/-- **Euler's recurrence** for partitions with bounded parts. -/
lemma pb_rec (b m : ℕ) (h : b + 1 ≤ m) :
    pb (b + 1) m = pb b m + pb (b + 1) (m - (b + 1)) := by
  have key : m / (b + 1) = (m - (b + 1)) / (b + 1) + 1 := by
    conv_lhs => rw [show m = (m - (b + 1)) + (b + 1) by omega]
    exact Nat.add_div_right _ (Nat.succ_pos b)
  rw [pb_succ_left, pb_succ_left (m := m - (b + 1)), key,
    Finset.sum_range_succ' (fun c => pb b (m - c * (b + 1))) ((m - (b + 1)) / (b + 1) + 1)]
  have h2 : ∀ c : ℕ, m - (b + 1) - c * (b + 1) = m - (c + 1) * (b + 1) := by
    intro c; rw [Nat.sub_sub]; ring_nf
  simp only [h2, Nat.zero_mul, Nat.sub_zero]
  exact Nat.add_comm _ _

lemma pb_mono_step (b : ℕ) (hb : 1 ≤ b) : ∀ m, pb b m ≤ pb b (m + 1) := by
  induction b with
  | zero => omega
  | succ b ih =>
    rcases Nat.eq_zero_or_pos b with rfl | hb0
    · simp
    · have ihb := ih hb0
      intro m
      induction m using Nat.strong_induction_on with
      | _ m ihm =>
        rcases Nat.lt_or_ge m (b + 1) with hm | hm
        · rcases Nat.lt_or_ge (m + 1) (b + 1) with hm1 | hm1
          · rw [pb_rec_of_lt _ _ hm, pb_rec_of_lt _ _ hm1]; exact ihb m
          · rw [pb_rec_of_lt _ _ hm, pb_rec _ _ hm1]
            exact le_trans (ihb m) (Nat.le_add_right _ _)
        · have hm1 : b + 1 ≤ m + 1 := by omega
          rw [pb_rec _ _ hm, pb_rec _ _ hm1]
          refine Nat.add_le_add (ihb m) ?_
          have he : m + 1 - (b + 1) = (m - (b + 1)) + 1 := by omega
          rw [he]
          exact ihm (m - (b + 1)) (by omega)

lemma pb_mono (b : ℕ) (hb : 1 ≤ b) : Monotone (pb b) := by
  intro x y hxy
  induction y with
  | zero => simp_all
  | succ y ih =>
    rcases Nat.lt_or_ge x (y + 1) with h | h
    · exact (ih (by omega)).trans (pb_mono_step b hb y)
    · have : x = y + 1 := by omega
      simp [this]

/-- **Exponential lower bound for bounded partitions**: doubling the allowed part size
range doubles the count, as soon as there is enough room. -/
theorem two_pow_le_pb (b m : ℕ) (h : b * (b + 3) ≤ 2 * m) : 2 ^ b ≤ pb (b + 1) m := by
  induction b generalizing m with
  | zero => simp
  | succ b ih =>
    have hm : b + 2 ≤ m := by nlinarith
    obtain ⟨t, rfl⟩ : ∃ t, m = t + (b + 2) := ⟨m - (b + 2), by omega⟩
    rw [pb_rec (b + 1) _ (by omega)]
    have h1 : 2 ^ b ≤ pb (b + 1) (t + (b + 2)) := ih _ (by nlinarith)
    have h2 : 2 ^ b ≤ pb (b + 1) t := ih _ (by nlinarith)
    have h3 : pb (b + 1) t ≤ pb (b + 2) t := pb_le_succ_left _ _
    have he : t + (b + 2) - (b + 2) = t := by omega
    rw [he]
    calc 2 ^ (b + 1) = 2 ^ b + 2 ^ b := by ring
      _ ≤ pb (b + 1) (t + (b + 2)) + pb (b + 2) t := Nat.add_le_add h1 (h2.trans h3)

/-- **Polynomial upper bound for bounded partitions.** -/
theorem pb_le_pow (b m : ℕ) : pb (b + 1) m ≤ (m + 1) ^ b := by
  induction b generalizing m with
  | zero => simp
  | succ b ih =>
    rw [pb_succ_left]
    calc ∑ c ∈ range (m / (b + 2) + 1), pb (b + 1) (m - c * (b + 2))
        ≤ ∑ _c ∈ range (m / (b + 2) + 1), (m + 1) ^ b := by
          refine Finset.sum_le_sum (fun c _ => le_trans (ih _) ?_)
          exact Nat.pow_le_pow_left (by omega) b
      _ = (m / (b + 2) + 1) * (m + 1) ^ b := by
          rw [Finset.sum_const, Finset.card_range]; ring
      _ ≤ (m + 1) * (m + 1) ^ b := by
          refine Nat.mul_le_mul_right _ ?_
          have := Nat.div_le_self m (b + 2); omega
      _ = (m + 1) ^ (b + 1) := by ring

lemma pb_le_pow' (b m : ℕ) : pb b m ≤ (m + 1) ^ b := by
  cases b with
  | zero => simp; split_ifs <;> omega
  | succ b => exact (pb_le_pow b m).trans (Nat.pow_le_pow_right (by omega) (by omega))

/-! ## The stack-polyomino counting function -/

/-- Convolution of two bounded-partition sequences: the number of ways of splitting the
two slopes of a stack, of total area `m`, into a left and a right partition with parts
of size at most `b`. -/
def conv (b m : ℕ) : ℕ := ∑ j ∈ range (m + 1), pb b j * pb b (m - j)

/-- `stackSC n` is the number of stack polyominoes of area `n` with square core:
the layer indexed by `k` counts the stacks whose core is the `k × k` square. -/
def stackSC (n : ℕ) : ℕ :=
  ∑ k ∈ range (n + 1), if k * k ≤ n then conv (k - 1) (n - k * k) else 0

@[simp] lemma conv_zero_left (m : ℕ) : conv 0 m = if m = 0 then 1 else 0 := by
  rw [conv, Finset.sum_eq_single 0]
  · simp
  · intro j _ hj; simp [hj]
  · intro h; simp at h

@[simp] lemma conv_one_left (m : ℕ) : conv 1 m = m + 1 := by simp [conv]

lemma pb_le_conv (b m : ℕ) : pb b m ≤ conv b m := by
  rw [conv]
  calc pb b m = pb b 0 * pb b (m - 0) := by simp
    _ ≤ _ := Finset.single_le_sum (f := fun j => pb b j * pb b (m - j))
                (fun i _ => Nat.zero_le _) (by simp)

lemma conv_mono_step (b : ℕ) (hb : 1 ≤ b) (m : ℕ) : conv b m ≤ conv b (m + 1) := by
  have h1 : conv b (m + 1)
      = (∑ j ∈ range (m + 1), pb b j * pb b (m + 1 - j)) + pb b (m + 1) * pb b 0 := by
    rw [conv, Finset.sum_range_succ]; simp
  have h2 : conv b m ≤ ∑ j ∈ range (m + 1), pb b j * pb b (m + 1 - j) := by
    rw [conv]
    exact Finset.sum_le_sum (fun j _ => Nat.mul_le_mul_left _ (pb_mono b hb (by omega)))
  omega

lemma conv_mono (b : ℕ) (hb : 1 ≤ b) : Monotone (conv b) := by
  intro x y hxy
  induction y with
  | zero => simp_all
  | succ y ih =>
    rcases Nat.lt_or_ge x (y + 1) with h | h
    · exact (ih (by omega)).trans (conv_mono_step b hb y)
    · have : x = y + 1 := by omega
      simp [this]

lemma conv_le_pow (b m : ℕ) : conv b m ≤ (m + 1) ^ (2 * b + 1) := by
  rw [conv]
  calc ∑ j ∈ range (m + 1), pb b j * pb b (m - j)
      ≤ ∑ _j ∈ range (m + 1), (m + 1) ^ b * (m + 1) ^ b := by
        refine Finset.sum_le_sum (fun j hj => Nat.mul_le_mul ?_ ?_)
        · exact (pb_le_pow' b j).trans (Nat.pow_le_pow_left (by simp at hj; omega) b)
        · exact (pb_le_pow' b (m - j)).trans (Nat.pow_le_pow_left (by omega) b)
    _ = (m + 1) * ((m + 1) ^ b * (m + 1) ^ b) := by
        rw [Finset.sum_const, Finset.card_range]; ring
    _ = (m + 1) ^ (2 * b + 1) := by ring

set_option maxRecDepth 10000 in
/-- The first 32 values of `a(n)` agree with the catalogued data. -/
theorem stackSC_table :
    (List.range 32).map stackSC =
      [1, 1, 0, 0, 1, 2, 3, 4, 5, 7, 9, 13, 17, 24, 31, 42, 54, 71, 90, 117, 147, 188,
        236, 298, 371, 466, 576, 716, 882, 1088, 1331, 1633] := by
  decide

/-- Each individual core layer is dominated by the whole count. -/
lemma layer_le_stackSC (n k : ℕ) (hk : k * k ≤ n) : conv (k - 1) (n - k * k) ≤ stackSC n := by
  have hkn : k ∈ range (n + 1) := by
    simp only [Finset.mem_range]
    rcases Nat.eq_zero_or_pos k with rfl | hk0
    · omega
    · nlinarith
  rw [stackSC]
  calc conv (k - 1) (n - k * k) = (if k * k ≤ n then conv (k - 1) (n - k * k) else 0) := by
        simp [hk]
    _ ≤ _ := Finset.single_le_sum
                (f := fun k => if k * k ≤ n then conv (k - 1) (n - k * k) else 0)
                (fun i _ => Nat.zero_le _) hkn

/-- The `k = 2` layer (a domino-topped stack) already forces linear growth. -/
theorem stackSC_linear_lower (n : ℕ) (hn : 4 ≤ n) : n - 3 ≤ stackSC n := by
  have h := layer_le_stackSC n 2 (by omega)
  have h2 : conv (2 - 1) (n - 2 * 2) = n - 3 := by
    rw [show (2 : ℕ) - 1 = 1 from rfl, conv_one_left]; omega
  omega

/-- `a` is non-decreasing from `n = 4` onwards. -/
theorem stackSC_mono (n : ℕ) (hn : 4 ≤ n) : stackSC n ≤ stackSC (n + 1) := by
  rw [stackSC, stackSC]
  have hext : ∑ k ∈ range (n + 2), (if k * k ≤ n then conv (k - 1) (n - k * k) else 0)
      = ∑ k ∈ range (n + 1), (if k * k ≤ n then conv (k - 1) (n - k * k) else 0) := by
    rw [Finset.sum_range_succ, if_neg (by nlinarith), add_zero]
  refine le_trans (le_of_eq hext.symm) (Finset.sum_le_sum ?_)
  intro k _
  by_cases hkn : k * k ≤ n
  · rw [if_pos hkn, if_pos (by omega : k * k ≤ n + 1)]
    match k, hkn with
    | 0, _ =>
        show conv 0 (n - 0 * 0) ≤ conv 0 (n + 1 - 0 * 0)
        simp only [conv_zero_left]; split_ifs <;> omega
    | 1, _ =>
        show conv 0 (n - 1 * 1) ≤ conv 0 (n + 1 - 1 * 1)
        simp only [conv_zero_left]; split_ifs <;> omega
    | (k + 2), hkn => exact conv_mono (k + 2 - 1) (by omega) (by omega)
  · rw [if_neg hkn]; exact Nat.zero_le _

/-- **Stretched-exponential lower bound**: `2^m ≤ a(n)` once `3m² + 11m + 8 ≤ 2n`. -/
theorem two_pow_le_stackSC (m n : ℕ) (h : 3 * m * m + 11 * m + 8 ≤ 2 * n) :
    2 ^ m ≤ stackSC n := by
  have hk : (m + 2) * (m + 2) ≤ n := by nlinarith
  obtain ⟨N, hN⟩ : ∃ N, n = N + (m + 2) * (m + 2) := ⟨n - (m + 2) * (m + 2), by omega⟩
  have h1 := layer_le_stackSC n (m + 2) hk
  have hsub : n - (m + 2) * (m + 2) = N := by omega
  rw [hsub, show m + 2 - 1 = m + 1 from rfl] at h1
  have h2 : 2 ^ m ≤ pb (m + 1) N := two_pow_le_pb m N (by nlinarith)
  have h3 : pb (m + 1) N ≤ conv (m + 1) N := pb_le_conv _ _
  omega

theorem stackSC_pos (n : ℕ) (hn : n ≠ 2) (hn' : n ≠ 3) : 0 < stackSC n := by
  match n, hn, hn' with
  | 0, _, _ => decide
  | 1, _, _ => decide
  | 2, h, _ => exact absurd rfl h
  | 3, _, h => exact absurd rfl h
  | (n + 4), _, _ =>
      have := stackSC_linear_lower (n + 4) (by omega)
      omega

/-- The only vanishing values are the two "gap" areas `n = 2, 3`: a stack of area 2 or 3
can never have a square core. -/
theorem stackSC_eq_zero_iff (n : ℕ) : stackSC n = 0 ↔ n = 2 ∨ n = 3 := by
  constructor
  · intro h
    by_contra hc
    push_neg at hc
    have := stackSC_pos n hc.1 hc.2
    omega
  · rintro (rfl | rfl) <;> decide

/-- **Stretched-exponential upper bound.** -/
theorem stackSC_le_pow (n : ℕ) : stackSC n ≤ (n + 1) ^ (2 * Nat.sqrt n + 2) := by
  rw [stackSC]
  calc ∑ k ∈ range (n + 1), (if k * k ≤ n then conv (k - 1) (n - k * k) else 0)
      ≤ ∑ _k ∈ range (n + 1), (n + 1) ^ (2 * Nat.sqrt n + 1) := by
        refine Finset.sum_le_sum (fun k _ => ?_)
        by_cases hk : k * k ≤ n
        · rw [if_pos hk]
          have hks : k ≤ Nat.sqrt n := Nat.le_sqrt.2 hk
          calc conv (k - 1) (n - k * k) ≤ (n - k * k + 1) ^ (2 * (k - 1) + 1) := conv_le_pow _ _
            _ ≤ (n + 1) ^ (2 * (k - 1) + 1) := Nat.pow_le_pow_left (by omega) _
            _ ≤ (n + 1) ^ (2 * Nat.sqrt n + 1) := Nat.pow_le_pow_right (by omega) (by omega)
        · rw [if_neg hk]; exact Nat.zero_le _
    _ = (n + 1) * (n + 1) ^ (2 * Nat.sqrt n + 1) := by
        rw [Finset.sum_const, Finset.card_range]; ring
    _ = (n + 1) ^ (2 * Nat.sqrt n + 2) := by ring

/-- Every polynomial is eventually dominated by `2^x`. -/
lemma poly_le_two_pow (c e : ℕ) : ∃ C : ℕ, ∀ x : ℕ, C ≤ x → c * x ^ e ≤ 2 ^ x := by
  have h : (fun n : ℕ => (n : ℝ) ^ e) =o[atTop] fun n : ℕ => (2 : ℝ) ^ n :=
    isLittleO_pow_const_const_pow_of_one_lt e (by norm_num)
  have hc : (0 : ℝ) < 1 / (c + 1) := by positivity
  obtain ⟨C, hC⟩ := Filter.eventually_atTop.1 (h.bound hc)
  refine ⟨C, fun x hx => ?_⟩
  have hb := hC x hx
  rw [Real.norm_eq_abs, Real.norm_eq_abs, abs_of_nonneg (by positivity),
    abs_of_nonneg (by positivity)] at hb
  have hcast : (c : ℝ) * (x : ℝ) ^ e ≤ 2 ^ x := by
    have hcpos : (0 : ℝ) < (c : ℝ) + 1 := by positivity
    have hkey : ((c : ℝ) + 1) * (x : ℝ) ^ e ≤ 2 ^ x := by
      calc ((c : ℝ) + 1) * (x : ℝ) ^ e ≤ ((c : ℝ) + 1) * (1 / ((c : ℝ) + 1) * 2 ^ x) :=
            mul_le_mul_of_nonneg_left hb (le_of_lt hcpos)
        _ = 2 ^ x := by field_simp
    nlinarith [pow_nonneg (Nat.cast_nonneg x : (0 : ℝ) ≤ x) e]
  have : ((c * x ^ e : ℕ) : ℝ) ≤ ((2 ^ x : ℕ) : ℝ) := by push_cast; exact hcast
  exact_mod_cast this

/-- **Superpolynomial growth**: `a(n)` eventually dominates every polynomial `n^d`. -/
theorem stackSC_superpolynomial (d : ℕ) : ∃ N : ℕ, ∀ n : ℕ, N ≤ n → n ^ d ≤ stackSC n := by
  obtain ⟨C, hC⟩ := poly_le_two_pow (4 ^ d * 2 ^ (2 * d)) (2 * d)
  refine ⟨4 * (C + 1) * (C + 1) + 100, fun n hn => ?_⟩
  set s := Nat.sqrt n with hs
  set m := s / 2 with hm
  have hs2 : s * s ≤ n := Nat.sqrt_le n
  have hslt : n < (s + 1) * (s + 1) := Nat.lt_succ_sqrt n
  have hsC : 2 * (C + 1) ≤ s := Nat.le_sqrt.2 (by nlinarith)
  have hs10 : 10 ≤ s := Nat.le_sqrt.2 (by nlinarith)
  have hmC : C + 1 ≤ m := by omega
  have hm1 : 1 ≤ m := by omega
  have h2m : 2 * m ≤ s := by omega
  have hsm : s ≤ 2 * m + 1 := by omega
  have hcond : 3 * m * m + 11 * m + 8 ≤ 2 * n := by nlinarith
  have hstack : 2 ^ m ≤ stackSC n := two_pow_le_stackSC m n hcond
  have hnle : n ≤ 4 * ((m + 1) * (m + 1)) := by nlinarith
  have h1 : n ^ d ≤ (4 * ((m + 1) * (m + 1))) ^ d := Nat.pow_le_pow_left hnle d
  have h2 : (m + 1) ^ (2 * d) = ((m + 1) * (m + 1)) ^ d := by rw [pow_mul, pow_two]
  have h3 : (m + 1) ^ (2 * d) ≤ (2 * m) ^ (2 * d) := Nat.pow_le_pow_left (by omega) _
  have h4 : (2 * m) ^ (2 * d) = 2 ^ (2 * d) * m ^ (2 * d) := by rw [Nat.mul_pow]
  have h5 : 4 ^ d * 2 ^ (2 * d) * m ^ (2 * d) ≤ 2 ^ m := hC m (by omega)
  calc n ^ d ≤ (4 * ((m + 1) * (m + 1))) ^ d := h1
    _ = 4 ^ d * (m + 1) ^ (2 * d) := by rw [Nat.mul_pow, h2]
    _ ≤ 4 ^ d * (2 ^ (2 * d) * m ^ (2 * d)) := Nat.mul_le_mul_left _ (by omega)
    _ = 4 ^ d * 2 ^ (2 * d) * m ^ (2 * d) := by ring
    _ ≤ 2 ^ m := h5
    _ ≤ stackSC n := hstack

end Physics.StackSquareCore