import Physics.StackSquareCoreBasic

/-!
# Stack polyominoes with a square core: convexity of the counting function

The numerical data show that the second differences of `a(n) = stackSC n` are non-negative
from `n = 2` on (they are `0,0,0,0,1,0,2,0,3,0,4,1,5,2,8,3,11,7,…`), while `a` is *not*
log-concave.  This file proves both facts.

The mechanism is an exact identity for self-convolutions.  If `f` is a non-decreasing
sequence and `S = f * f` is its self-convolution, then in generating-function terms
`(1-x)^2 S(x) = ((1-x) f(x))^2`, so the second difference of `S` is the self-convolution of
the first difference of `f` — a non-negative sequence.  Concretely,

  `S(m+2) - 2 S(m+1) + S(m) = ∑_{i+j=m+2} (Δf)(i) (Δf)(j) ≥ 0`.

Since `conv b = pb b * pb b` and `pb b` is non-decreasing for `b ≥ 1`, each core layer of
`a` is convex, and the layers that switch on at the perfect squares do so convexly as well.

## Main results

* `conv_shift_diff` : the difference rule `Δ(g * f) = g * Δf` for finite convolutions.
* `self_conv_convex` : second differences of a self-convolution of a monotone sequence.
* `conv_convex` : `2 · conv b (m+1) ≤ conv b m + conv b (m+2)` for `b ≥ 1`.
* `stackSC_convex` : `2 · a(n+1) ≤ a(n) + a(n+2)` for `n ≥ 2`.
* `stackSC_not_logConcave` : `a` is *not* log-concave (`a(8)² = 25 < 28 = a(7)·a(9)`).
-/

namespace Physics.StackSquareCore

open Finset

/-! ## A difference rule for finite convolutions -/

/-- Reflection symmetry of a finite convolution. -/
lemma conv_comm_int (u v : ℕ → ℤ) (m : ℕ) :
    ∑ i ∈ range (m + 1), u i * v (m - i) = ∑ i ∈ range (m + 1), v i * u (m - i) := by
  rw [← Finset.sum_range_reflect (fun i => v i * u (m - i)) (m + 1)]
  refine Finset.sum_congr rfl (fun i hi => ?_)
  simp only [Finset.mem_range] at hi
  have h1 : m + 1 - 1 - i = m - i := by omega
  have h2 : m - (m - i) = i := by omega
  rw [h1, h2]
  ring

/-- **Difference rule** `Δ (g * f) = g * (Δ f)` for finite convolutions. -/
lemma conv_shift_diff (g f d : ℕ → ℤ) (hd0 : d 0 = f 0)
    (hd : ∀ i, d (i + 1) = f (i + 1) - f i) (m : ℕ) :
    (∑ i ∈ range (m + 2), g i * f (m + 1 - i)) - (∑ i ∈ range (m + 1), g i * f (m - i))
      = ∑ i ∈ range (m + 2), g i * d (m + 1 - i) := by
  have key : ∑ i ∈ range (m + 1), (g i * f (m + 1 - i) - g i * f (m - i))
      = ∑ i ∈ range (m + 1), g i * d (m + 1 - i) := by
    refine Finset.sum_congr rfl (fun i hi => ?_)
    simp only [Finset.mem_range] at hi
    have h1 : m + 1 - i = (m - i) + 1 := by omega
    rw [h1, hd (m - i)]
    ring
  have key2 : (∑ i ∈ range (m + 1), g i * f (m + 1 - i))
      - (∑ i ∈ range (m + 1), g i * f (m - i))
      = ∑ i ∈ range (m + 1), g i * d (m + 1 - i) := by
    rw [← Finset.sum_sub_distrib]
    exact key
  rw [Finset.sum_range_succ (fun i => g i * f (m + 1 - i)),
    Finset.sum_range_succ (fun i => g i * d (m + 1 - i))]
  have hlast : m + 1 - (m + 1) = 0 := by omega
  rw [hlast, hd0]
  linarith [key2]

/-- **Convexity of a self-convolution**: if `d` is the (non-negative) difference sequence of
`f`, the second difference of `f * f` is the self-convolution of `d`, hence non-negative. -/
lemma self_conv_convex (f d : ℕ → ℤ) (hd0 : d 0 = f 0)
    (hd : ∀ i, d (i + 1) = f (i + 1) - f i) (hdnn : ∀ i, 0 ≤ d i) (m : ℕ) :
    2 * (∑ i ∈ range (m + 2), f i * f (m + 1 - i))
      ≤ (∑ i ∈ range (m + 1), f i * f (m - i))
        + ∑ i ∈ range (m + 3), f i * f (m + 2 - i) := by
  set S : ℕ → ℤ := fun r => ∑ i ∈ range (r + 1), f i * f (r - i) with hS
  set Q : ℕ → ℤ := fun r => ∑ i ∈ range (r + 1), f i * d (r - i) with hQ
  have h1 : S (m + 1) - S m = Q (m + 1) := conv_shift_diff f f d hd0 hd m
  have h2 : S (m + 2) - S (m + 1) = Q (m + 2) := conv_shift_diff f f d hd0 hd (m + 1)
  have hQrefl : ∀ r : ℕ, Q r = ∑ i ∈ range (r + 1), d i * f (r - i) := by
    intro r
    rw [hQ]
    exact conv_comm_int f d r
  have h3 : Q (m + 2) - Q (m + 1) = ∑ i ∈ range (m + 3), d i * d (m + 2 - i) := by
    rw [hQrefl (m + 2), hQrefl (m + 1)]
    exact conv_shift_diff d f d hd0 hd (m + 1)
  have h4 : (0:ℤ) ≤ ∑ i ∈ range (m + 3), d i * d (m + 2 - i) :=
    Finset.sum_nonneg (fun i _ => mul_nonneg (hdnn i) (hdnn _))
  have hS0 : S m = ∑ i ∈ range (m + 1), f i * f (m - i) := rfl
  have hS1 : S (m + 1) = ∑ i ∈ range (m + 2), f i * f (m + 1 - i) := rfl
  have hS2 : S (m + 2) = ∑ i ∈ range (m + 3), f i * f (m + 2 - i) := rfl
  rw [← hS0, ← hS1, ← hS2]
  linarith

/-! ## Convexity of the layer counts and of `a` -/

/-- Each core layer `m ↦ conv b m` is convex, for `b ≥ 1`. -/
theorem conv_convex (b : ℕ) (hb : 1 ≤ b) (m : ℕ) :
    2 * conv b (m + 1) ≤ conv b m + conv b (m + 2) := by
  set f : ℕ → ℤ := fun i => (pb b i : ℤ) with hf
  set d : ℕ → ℤ := fun i => if i = 0 then (pb b 0 : ℤ) else (pb b i : ℤ) - (pb b (i - 1) : ℤ)
    with hdd
  have hd0 : d 0 = f 0 := by simp [hdd, hf]
  have hd : ∀ i, d (i + 1) = f (i + 1) - f i := by
    intro i
    simp only [hdd, hf, Nat.succ_ne_zero, if_false, Nat.add_sub_cancel]
  have hdnn : ∀ i, 0 ≤ d i := by
    intro i
    rcases Nat.eq_zero_or_pos i with rfl | hi
    · simp [hdd]
    · have hmono : pb b (i - 1) ≤ pb b i := pb_mono b hb (by omega)
      have hcast : ((pb b (i - 1) : ℤ)) ≤ (pb b i : ℤ) := by exact_mod_cast hmono
      simp only [hdd, if_neg (by omega : ¬ i = 0)]
      linarith
  have hkey := self_conv_convex f d hd0 hd hdnn m
  have hcast : ∀ r : ℕ, ((conv b r : ℕ) : ℤ) = ∑ i ∈ range (r + 1), f i * f (r - i) := by
    intro r
    rw [conv, hf]
    push_cast
    ring
  rw [← hcast m, ← hcast (m + 1), ← hcast (m + 2)] at hkey
  exact_mod_cast hkey

private lemma conv_zero_right' (b : ℕ) : conv b 0 = 1 := by
  simp [conv]

private lemma pb_one_right (b : ℕ) (hb : 1 ≤ b) : pb b 1 = 1 := by
  induction b with
  | zero => omega
  | succ b ih =>
      rcases Nat.eq_zero_or_pos b with rfl | hb0
      · simp
      · rw [pb_rec_of_lt b 1 (by omega)]
        exact ih hb0

private lemma conv_one_right (b : ℕ) (hb : 1 ≤ b) : conv b 1 = 2 := by
  simp [conv, Finset.sum_range_succ, pb_one_right b hb]

/-- The `k`-th layer of the sum defining `a`. -/
private def layer (k n : ℕ) : ℕ := if k * k ≤ n then conv (k - 1) (n - k * k) else 0

private lemma stackSC_eq_layer_sum (n : ℕ) (r : ℕ) (hr : n + 1 ≤ r) :
    stackSC n = ∑ k ∈ range r, layer k n := by
  have h0 : stackSC n = ∑ k ∈ range (n + 1), layer k n := rfl
  have hsub : range (n + 1) ⊆ range r := by
    intro x hx
    simp only [Finset.mem_range] at hx ⊢
    omega
  rw [h0]
  refine Finset.sum_subset hsub (fun k hk hk' => ?_)
  simp only [Finset.mem_range] at hk hk'
  have hkn : ¬ k * k ≤ n := by nlinarith
  simp [layer, hkn]

private lemma layer_zero_left (m : ℕ) (hm : 2 ≤ m) : layer 0 m = 0 := by
  have h : layer 0 m = conv 0 m := by simp [layer]
  rw [h, conv_zero_left, if_neg (by omega)]

private lemma layer_one_left (m : ℕ) (hm : 2 ≤ m) : layer 1 m = 0 := by
  have h : layer 1 m = conv 0 (m - 1) := by
    unfold layer
    rw [if_pos (by omega : 1 * 1 ≤ m)]
  rw [h, conv_zero_left, if_neg (by omega)]

/-- Every layer is convex in `n`, from `n ≥ 2` on. -/
private lemma layer_convex (k n : ℕ) (hn : 2 ≤ n) :
    2 * layer k (n + 1) ≤ layer k n + layer k (n + 2) := by
  match k with
  | 0 =>
      rw [layer_zero_left n hn, layer_zero_left (n + 1) (by omega),
        layer_zero_left (n + 2) (by omega)]
  | 1 =>
      rw [layer_one_left n hn, layer_one_left (n + 1) (by omega),
        layer_one_left (n + 2) (by omega)]
  | (k + 2) =>
      have hb : 1 ≤ k + 1 := by omega
      simp only [layer, show k + 2 - 1 = k + 1 from rfl]
      rcases Nat.lt_or_ge n ((k + 2) * (k + 2)) with hlt | hge
      · rcases Nat.lt_or_ge (n + 1) ((k + 2) * (k + 2)) with hlt1 | hge1
        · rcases Nat.lt_or_ge (n + 2) ((k + 2) * (k + 2)) with hlt2 | hge2
          · rw [if_neg (show ¬ (k + 2) * (k + 2) ≤ n + 1 by omega),
              if_neg (show ¬ (k + 2) * (k + 2) ≤ n by omega),
              if_neg (show ¬ (k + 2) * (k + 2) ≤ n + 2 by omega)]
          · rw [if_neg (show ¬ (k + 2) * (k + 2) ≤ n + 1 by omega),
              if_neg (show ¬ (k + 2) * (k + 2) ≤ n by omega),
              if_pos (show (k + 2) * (k + 2) ≤ n + 2 by omega)]
            omega
        · rw [if_pos (show (k + 2) * (k + 2) ≤ n + 1 by omega),
            if_neg (show ¬ (k + 2) * (k + 2) ≤ n by omega),
            if_pos (show (k + 2) * (k + 2) ≤ n + 2 by omega)]
          have h0 : n + 1 - (k + 2) * (k + 2) = 0 := by omega
          have h2 : n + 2 - (k + 2) * (k + 2) = 1 := by omega
          rw [h0, h2, conv_zero_right' (k + 1), conv_one_right (k + 1) hb]
      · rw [if_pos (show (k + 2) * (k + 2) ≤ n + 1 by omega),
          if_pos (show (k + 2) * (k + 2) ≤ n by omega),
          if_pos (show (k + 2) * (k + 2) ≤ n + 2 by omega)]
        have he1 : n + 1 - (k + 2) * (k + 2) = (n - (k + 2) * (k + 2)) + 1 := by omega
        have he2 : n + 2 - (k + 2) * (k + 2) = (n - (k + 2) * (k + 2)) + 2 := by omega
        rw [he1, he2]
        exact conv_convex (k + 1) hb (n - (k + 2) * (k + 2))

/-- **Convexity of the counting function**: `2 a(n+1) ≤ a(n) + a(n+2)` for `n ≥ 2`.
Equivalently, the gaps `a(n+1) - a(n)` are non-decreasing from `n = 2` on. -/
theorem stackSC_convex (n : ℕ) (hn : 2 ≤ n) :
    2 * stackSC (n + 1) ≤ stackSC n + stackSC (n + 2) := by
  have e0 : stackSC n = ∑ k ∈ range (n + 3), layer k n :=
    stackSC_eq_layer_sum n (n + 3) (by omega)
  have e1 : stackSC (n + 1) = ∑ k ∈ range (n + 3), layer k (n + 1) :=
    stackSC_eq_layer_sum (n + 1) (n + 3) (by omega)
  have e2 : stackSC (n + 2) = ∑ k ∈ range (n + 3), layer k (n + 2) :=
    stackSC_eq_layer_sum (n + 2) (n + 3) (by omega)
  rw [e0, e1, e2, Finset.mul_sum, ← Finset.sum_add_distrib]
  exact Finset.sum_le_sum (fun k _ => layer_convex k n hn)

/-- Convexity is the *best* multiplicative-type regularity available here: `a` is **not**
log-concave, since `a(8)² = 25 < 28 = a(7)·a(9)`. -/
theorem stackSC_not_logConcave :
    ¬ (∀ n : ℕ, 4 ≤ n → stackSC n * stackSC (n + 2) ≤ stackSC (n + 1) * stackSC (n + 1)) := by
  intro h
  have h7 := h 7 (by omega)
  rw [show stackSC 7 = 4 from by decide, show stackSC 8 = 5 from by decide,
    show stackSC 9 = 7 from by decide] at h7
  omega

/-! ## Divergence of the gaps -/

/-- Monotonicity of `a` from `n = 2` on (the two boundary values are checked directly). -/
private lemma stackSC_mono_two (n : ℕ) (hn : 2 ≤ n) : stackSC n ≤ stackSC (n + 1) := by
  rcases lt_or_ge n 4 with h | h
  · interval_cases n <;> decide
  · exact stackSC_mono n h

/-- The gaps are non-decreasing, including at the boundary cases `n = 1, 2, 3`. -/
private lemma gap_mono (n : ℕ) (hn : 1 ≤ n) :
    stackSC (n + 1) - stackSC n ≤ stackSC (n + 2) - stackSC (n + 1) := by
  rcases lt_or_ge n 4 with h | h
  · interval_cases n <;> decide
  · have hconv := stackSC_convex n (by omega)
    have hm1 : stackSC n ≤ stackSC (n + 1) := stackSC_mono n h
    have hm2 : stackSC (n + 1) ≤ stackSC (n + 2) := stackSC_mono (n + 1) (by omega)
    omega

/-- Telescoping: `a(j+2)` is at most `j` times the last gap. -/
private lemma stackSC_le_mul_gap (j : ℕ) :
    stackSC (j + 2) ≤ j * (stackSC (j + 2) - stackSC (j + 1)) := by
  induction j with
  | zero => simp [show stackSC 2 = 0 from by decide]
  | succ j ih =>
      have hstep : stackSC (j + 2) - stackSC (j + 1) ≤ stackSC (j + 3) - stackSC (j + 2) :=
        gap_mono (j + 1) (by omega)
      have hm : stackSC (j + 2) ≤ stackSC (j + 3) := stackSC_mono_two (j + 2) (by omega)
      have hmul : j * (stackSC (j + 2) - stackSC (j + 1))
          ≤ j * (stackSC (j + 3) - stackSC (j + 2)) := Nat.mul_le_mul_left j hstep
      show stackSC (j + 3) ≤ (j + 1) * (stackSC (j + 3) - stackSC (j + 2))
      calc stackSC (j + 3)
          = stackSC (j + 2) + (stackSC (j + 3) - stackSC (j + 2)) := by omega
        _ ≤ j * (stackSC (j + 3) - stackSC (j + 2)) + (stackSC (j + 3) - stackSC (j + 2)) :=
            Nat.add_le_add_right (le_trans ih hmul) _
        _ = (j + 1) * (stackSC (j + 3) - stackSC (j + 2)) := by ring

/-- **The gaps diverge**: `a(n+1) - a(n) ≥ n` for all large `n`, so the increments of the
sequence tend to infinity.  This combines convexity (the gaps are non-decreasing) with the
superpolynomial growth of `a`. -/
theorem stackSC_gap_ge (n : ℕ) (hn : 2 ≤ n)
    (hgrow : (n + 1) ^ 2 ≤ stackSC (n + 1)) : n ≤ stackSC (n + 1) - stackSC n := by
  have hkey := stackSC_le_mul_gap (n - 1)
  have he1 : n - 1 + 2 = n + 1 := by omega
  have he2 : n - 1 + 1 = n := by omega
  rw [he1, he2] at hkey
  have hbig : (n - 1) * n ≤ (n + 1) ^ 2 := by nlinarith [Nat.sub_le n 1]
  have hle : (n - 1) * n ≤ (n - 1) * (stackSC (n + 1) - stackSC n) := by
    calc (n - 1) * n ≤ (n + 1) ^ 2 := hbig
      _ ≤ stackSC (n + 1) := hgrow
      _ ≤ (n - 1) * (stackSC (n + 1) - stackSC n) := hkey
  exact Nat.le_of_mul_le_mul_left hle (by omega)

/-- The increments of `a` tend to infinity. -/
theorem stackSC_gap_tendsto_atTop :
    Filter.Tendsto (fun n : ℕ => stackSC (n + 1) - stackSC n) Filter.atTop Filter.atTop := by
  obtain ⟨N, hN⟩ := stackSC_superpolynomial 2
  refine Filter.tendsto_atTop.2 (fun C => ?_)
  filter_upwards [Filter.eventually_ge_atTop (max (N + 2) (C + 2))] with n hn
  have hn2 : 2 ≤ n := le_trans (by omega) (le_trans (le_max_left (N + 2) (C + 2)) hn)
  have hnN : N ≤ n + 1 := by
    have := le_trans (le_max_left (N + 2) (C + 2)) hn
    omega
  have hnC : C ≤ n := by
    have := le_trans (le_max_right (N + 2) (C + 2)) hn
    omega
  have hgrow : (n + 1) ^ 2 ≤ stackSC (n + 1) := hN (n + 1) hnN
  exact le_trans hnC (stackSC_gap_ge n hn2 hgrow)

end Physics.StackSquareCore