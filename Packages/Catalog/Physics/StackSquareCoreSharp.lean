import Physics.StackSquareCoreBasic
import Physics.StackSquareCoreAsymptotics

/-!
# Stack polyominoes with a square core: the sharp `√n` upper bound

`Physics.StackSquareCoreAsymptotics` proves `c √n ≤ log a(n) ≤ C √n log n`.  Here the
spurious `log n` factor is removed, so that the order of growth is pinned down exactly:

  `log a(n) ≍ √n`.

The route is the classical Hardy–Ramanujan style estimate, carried out by hand and
entirely elementarily:

* `pb_mul_pow_le_prod` : Chebyshev/Rankin bound `p_{≤b}(m) x^m ≤ ∏_{i=1}^{b} (1-x^i)⁻¹`
  for `0 < x < 1`, proved by induction on `b` from the Euler recursion.
* `sum_neg_log_le` : with the choice `x = 1 - 1/N`, the Euler product satisfies
  `∑_{i=1}^{b} -log(1-x^i) ≤ 6N`.  The `i ≤ N` range is handled by
  `1-x^i ≥ i/(8N)` together with the elementary Stirling bound `N^N ≤ N! e^N`
  (`pow_self_le_factorial_mul_exp`), and the `i > N` range by a geometric series.
* `log_pb_le_sqrt` : optimizing `N ≈ √m` gives `log p_{≤b}(m) ≤ 8√m + 12`, uniformly in `b`.
* `log_stackSC_le_sqrt` : `log a(n) ≤ 16√n + 2 log(n+1) + 24`.
* `stackSC_log_sqrt_sharp` : `((√n-2)/2) log 2 ≤ log a(n) ≤ 30 √n` for `n ≥ 100`.
* `log_stackSC_isBigO_sqrt`, `sqrt_isBigO_log_stackSC` : `log a(n) ≍ √n`.
-/

namespace Physics.StackSquareCore

open Finset Filter Real Asymptotics


lemma geom_sum_le_inv_one_sub (x : ℝ) (hx0 : 0 ≤ x) (hx1 : x < 1) (n : ℕ) :
    ∑ i ∈ range n, x ^ i ≤ (1 - x)⁻¹ := by
  have h0 : (0:ℝ) < 1 - x := by linarith
  have key : (1 - x) * ∑ i ∈ range n, x ^ i = 1 - x ^ n := by
    have h := geom_sum_mul x n
    nlinarith [h]
  refine le_of_mul_le_mul_left ?_ h0
  rw [key, mul_inv_cancel₀ (ne_of_gt h0)]
  have : (0:ℝ) ≤ x ^ n := by positivity
  linarith

lemma succ_pow_le_pow_mul_exp (n : ℕ) : ((n : ℝ) + 1) ^ n ≤ (n : ℝ) ^ n * Real.exp 1 := by
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp
  · have hn0 : (0:ℝ) < n := by exact_mod_cast hn
    have h1 : (n : ℝ) + 1 ≤ (n : ℝ) * Real.exp (1 / n) := by
      have := Real.add_one_le_exp (1 / (n:ℝ))
      have h2 : (n:ℝ) * (1 / n + 1) ≤ (n:ℝ) * Real.exp (1/n) :=
        mul_le_mul_of_nonneg_left this hn0.le
      rw [mul_add, mul_one, mul_one_div, div_self (ne_of_gt hn0)] at h2
      linarith
    calc ((n : ℝ) + 1) ^ n ≤ ((n : ℝ) * Real.exp (1 / n)) ^ n :=
          pow_le_pow_left₀ (by positivity) h1 n
      _ = (n:ℝ) ^ n * Real.exp (1/n) ^ n := by rw [mul_pow]
      _ = (n:ℝ) ^ n * Real.exp 1 := by
          rw [← Real.exp_nat_mul]
          congr 2
          field_simp

lemma pow_self_le_factorial_mul_exp (n : ℕ) :
    (n : ℝ) ^ n ≤ (n.factorial : ℝ) * Real.exp n := by
  induction n with
  | zero => simp
  | succ n ih =>
      have hstep : ((n:ℝ) + 1) ^ (n + 1) = ((n:ℝ) + 1) * ((n:ℝ) + 1) ^ n := by ring
      have h1 : ((n : ℝ) + 1) ^ n ≤ (n : ℝ) ^ n * Real.exp 1 := succ_pow_le_pow_mul_exp n
      have h2 : (n : ℝ) ^ n * Real.exp 1 ≤ (n.factorial : ℝ) * Real.exp n * Real.exp 1 :=
        mul_le_mul_of_nonneg_right ih (Real.exp_pos 1).le
      have h3 : ((n:ℝ) + 1) * (((n.factorial : ℝ) * Real.exp n) * Real.exp 1)
          = (((n+1).factorial : ℝ)) * Real.exp ((n:ℝ) + 1) := by
        rw [Nat.factorial_succ]
        push_cast
        rw [Real.exp_add]
        ring
      have hnn : (0:ℝ) ≤ (n:ℝ) + 1 := by positivity
      push_cast
      rw [hstep]
      calc ((n:ℝ) + 1) * ((n:ℝ) + 1) ^ n
          ≤ ((n:ℝ) + 1) * ((n.factorial : ℝ) * Real.exp n * Real.exp 1) := by
            refine mul_le_mul_of_nonneg_left (h1.trans h2) hnn
        _ = (((n+1).factorial : ℝ)) * Real.exp ((n:ℝ) + 1) := by rw [← h3]

lemma log_factorial_ge (n : ℕ) :
    (n : ℝ) * Real.log n - n ≤ Real.log (n.factorial) := by
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp
  · have hn0 : (0:ℝ) < n := by exact_mod_cast hn
    have hf : (0:ℝ) < (n.factorial : ℝ) := by exact_mod_cast n.factorial_pos
    have h := pow_self_le_factorial_mul_exp n
    have hlog := Real.log_le_log (by positivity) h
    rw [Real.log_pow, Real.log_mul (ne_of_gt hf) (Real.exp_ne_zero _), Real.log_exp] at hlog
    linarith

section
variable (N : ℕ)

lemma exp_two_le_eight : Real.exp 2 ≤ 8 := by
  have h := Real.exp_one_lt_d9
  have : Real.exp 2 = Real.exp 1 * Real.exp 1 := by
    rw [← Real.exp_add]; norm_num
  nlinarith [Real.exp_pos 1]

lemma two_le_exp_one : (2:ℝ) ≤ Real.exp 1 := by
  have := Real.exp_one_gt_d9
  linarith

lemma one_sub_inv_pow_ge (hN : 2 ≤ N) : (1/8 : ℝ) ≤ (1 - (N:ℝ)⁻¹) ^ N := by
  have hN2 : (2:ℝ) ≤ (N:ℝ) := by exact_mod_cast hN
  set x : ℝ := 1 - (N:ℝ)⁻¹ with hxdef
  have hx0 : 0 < x := by
    rw [hxdef]
    have : (N:ℝ)⁻¹ ≤ 1/2 := by
      rw [inv_le_comm₀ (by linarith) (by norm_num)]; linarith
    linarith
  have hxN : 0 < x ^ N := by positivity
  have hne : ((N:ℝ) - 1) ≠ 0 := by intro h; rw [sub_eq_zero] at h; linarith
  have hx' : x = ((N:ℝ) - 1) / N := by rw [hxdef]; field_simp
  have hinv : 1 / x = 1 + 1 / ((N:ℝ) - 1) := by
    rw [hx', one_div_div]
    field_simp
    ring
  have e1 : 1 / x ≤ Real.exp (1 / ((N:ℝ) - 1)) := by
    rw [hinv]
    have := Real.add_one_le_exp (1 / ((N:ℝ) - 1))
    linarith
  have e2 : (1 / x) ^ N ≤ Real.exp ((N:ℝ) * (1 / ((N:ℝ) - 1))) := by
    calc (1/x) ^ N ≤ (Real.exp (1 / ((N:ℝ) - 1))) ^ N :=
          pow_le_pow_left₀ (by positivity) e1 N
      _ = Real.exp ((N:ℝ) * (1 / ((N:ℝ) - 1))) := by rw [← Real.exp_nat_mul]
  have e3 : (N:ℝ) * (1 / ((N:ℝ) - 1)) ≤ 2 := by
    rw [mul_one_div, div_le_iff₀ (by linarith)]
    linarith
  have e4 : (1/x) ^ N ≤ 8 :=
    e2.trans ((Real.exp_le_exp.2 e3).trans exp_two_le_eight)
  rw [div_pow, one_pow, div_le_iff₀ hxN] at e4
  linarith

lemma one_sub_inv_pow_le (hN : 2 ≤ N) : (1 - (N:ℝ)⁻¹) ^ N ≤ 1/2 := by
  have hN2 : (2:ℝ) ≤ (N:ℝ) := by exact_mod_cast hN
  have hNpos : (0:ℝ) < N := by linarith
  set x : ℝ := 1 - (N:ℝ)⁻¹ with hxdef
  have hx0 : 0 ≤ x := by
    rw [hxdef]
    have : (N:ℝ)⁻¹ ≤ 1/2 := by
      rw [inv_le_comm₀ (by linarith) (by norm_num)]; linarith
    linarith
  have e1 : x ≤ Real.exp (-(N:ℝ)⁻¹) := by
    have := Real.add_one_le_exp (-(N:ℝ)⁻¹)
    rw [hxdef]; linarith
  have e2 : x ^ N ≤ Real.exp (-1 : ℝ) := by
    calc x ^ N ≤ (Real.exp (-(N:ℝ)⁻¹)) ^ N := pow_le_pow_left₀ hx0 e1 N
      _ = Real.exp ((N:ℝ) * (-(N:ℝ)⁻¹)) := by rw [← Real.exp_nat_mul]
      _ = Real.exp (-1 : ℝ) := by
          congr 1
          field_simp
  have e3 : Real.exp (-1 : ℝ) ≤ 1/2 := by
    rw [Real.exp_neg]
    rw [inv_le_comm₀ (Real.exp_pos 1) (by norm_num)]
    simpa using two_le_exp_one
  linarith
end

section Sum
variable (N : ℕ)

lemma one_sub_pow_lower (hN : 2 ≤ N) (i : ℕ) (hi1 : 1 ≤ i) (hiN : i ≤ N) :
    (i : ℝ) / (8 * N) ≤ 1 - (1 - (N:ℝ)⁻¹) ^ i := by
  have hN2 : (2:ℝ) ≤ (N:ℝ) := by exact_mod_cast hN
  set x : ℝ := 1 - (N:ℝ)⁻¹ with hxdef
  have hinvle : (N:ℝ)⁻¹ ≤ 1/2 := by
    rw [inv_le_comm₀ (by linarith) (by norm_num)]; linarith
  have hx0 : 0 < x := by rw [hxdef]; linarith
  have hx1 : x ≤ 1 := by
    rw [hxdef]
    have : (0:ℝ) ≤ (N:ℝ)⁻¹ := by positivity
    linarith
  have h1x : 1 - x = (N:ℝ)⁻¹ := by rw [hxdef]; ring
  have hgeom : 1 - x ^ i = (1 - x) * ∑ j ∈ range i, x ^ j := by
    have h := geom_sum_mul x i
    nlinarith [h]
  have hsum : (i : ℝ) * x ^ (i - 1) ≤ ∑ j ∈ range i, x ^ j := by
    have hcard : (range i).card = i := Finset.card_range i
    have := Finset.card_nsmul_le_sum (range i) (fun j => x ^ j) (x ^ (i - 1))
      (fun j hj => by
        simp only [Finset.mem_range] at hj
        exact pow_le_pow_of_le_one hx0.le hx1 (by omega))
    rw [hcard, nsmul_eq_mul] at this
    exact this
  have hlow : (1/8 : ℝ) ≤ x ^ (i - 1) := by
    refine (one_sub_inv_pow_ge N hN).trans ?_
    exact pow_le_pow_of_le_one hx0.le hx1 (by omega)
  have hip : (0:ℝ) ≤ (i:ℝ) := by positivity
  have hNpos : (0:ℝ) < (N:ℝ) := by linarith
  rw [hgeom, h1x]
  rw [div_le_iff₀ (by positivity)]
  have h2 : (i:ℝ) * (1/8) ≤ (i:ℝ) * x ^ (i-1) := by nlinarith
  have h3 : (i:ℝ) * (1/8) ≤ ∑ j ∈ range i, x ^ j := le_trans h2 hsum
  have hfin : (N:ℝ)⁻¹ * ((i:ℝ) * (1/8)) ≤ (N:ℝ)⁻¹ * ∑ j ∈ range i, x ^ j :=
    mul_le_mul_of_nonneg_left h3 (by positivity)
  calc (i:ℝ) = ((N:ℝ)⁻¹ * ((i:ℝ) * (1/8))) * (8 * N) := by field_simp
    _ ≤ ((N:ℝ)⁻¹ * ∑ j ∈ range i, x ^ j) * (8 * N) :=
        mul_le_mul_of_nonneg_right hfin (by positivity)

lemma neg_log_one_sub_pow_le (hN : 2 ≤ N) (i : ℕ) (hi : N + 1 ≤ i) :
    -Real.log (1 - (1 - (N:ℝ)⁻¹) ^ i) ≤ 2 * (1 - (N:ℝ)⁻¹) ^ i := by
  have hN2 : (2:ℝ) ≤ (N:ℝ) := by exact_mod_cast hN
  set x : ℝ := 1 - (N:ℝ)⁻¹ with hxdef
  have hinvle : (N:ℝ)⁻¹ ≤ 1/2 := by
    rw [inv_le_comm₀ (by linarith) (by norm_num)]; linarith
  have hx0 : 0 < x := by rw [hxdef]; linarith
  have hx1 : x ≤ 1 := by
    rw [hxdef]
    have : (0:ℝ) ≤ (N:ℝ)⁻¹ := by positivity
    linarith
  have hy : x ^ i ≤ 1/2 :=
    (pow_le_pow_of_le_one hx0.le hx1 (by omega : N ≤ i)).trans (one_sub_inv_pow_le N hN)
  have hy0 : (0:ℝ) < x ^ i := by positivity
  have hd : (0:ℝ) < 1 - x ^ i := by linarith
  have hlog : Real.log ((1 - x ^ i)⁻¹) ≤ (1 - x ^ i)⁻¹ - 1 :=
    Real.log_le_sub_one_of_pos (by positivity)
  rw [Real.log_inv] at hlog
  have hinv : (1 - x ^ i)⁻¹ - 1 = x ^ i / (1 - x ^ i) := by
    rw [eq_div_iff (ne_of_gt hd), sub_mul, inv_mul_cancel₀ (ne_of_gt hd), one_mul]
    ring
  rw [hinv] at hlog
  have hfrac : x ^ i / (1 - x ^ i) ≤ 2 * x ^ i := by
    rw [div_le_iff₀ hd]
    nlinarith
  linarith

lemma sum_neg_log_le (b : ℕ) (hN : 2 ≤ N) :
    ∑ i ∈ Icc 1 b, -Real.log (1 - (1 - (N:ℝ)⁻¹) ^ i) ≤ 6 * N := by
  have hN2 : (2:ℝ) ≤ (N:ℝ) := by exact_mod_cast hN
  have hNpos : (0:ℝ) < (N:ℝ) := by linarith
  set x : ℝ := 1 - (N:ℝ)⁻¹ with hxdef
  have hinvle : (N:ℝ)⁻¹ ≤ 1/2 := by
    rw [inv_le_comm₀ (by linarith) (by norm_num)]; linarith
  have hinvpos : (0:ℝ) < (N:ℝ)⁻¹ := by positivity
  have hx0 : 0 < x := by rw [hxdef]; linarith
  have hx1 : x < 1 := by rw [hxdef]; linarith
  have hnonneg : ∀ i ∈ Icc 1 N ∪ Icc (N+1) b, 0 ≤ -Real.log (1 - x ^ i) := by
    intro i hi
    have hi1 : 1 ≤ i := by
      simp only [Finset.mem_union, Finset.mem_Icc] at hi
      omega
    have h1 : x ^ i < 1 := pow_lt_one₀ hx0.le hx1 (by omega)
    have h2 : (0:ℝ) ≤ x ^ i := by positivity
    have : Real.log (1 - x ^ i) ≤ 0 := Real.log_nonpos (by linarith) (by linarith)
    linarith
  have hsub : Icc 1 b ⊆ Icc 1 N ∪ Icc (N+1) b := by
    intro i hi
    simp only [Finset.mem_Icc] at hi
    simp only [Finset.mem_union, Finset.mem_Icc]
    omega
  have hdisj : Disjoint (Icc 1 N) (Icc (N+1) b) := by
    rw [Finset.disjoint_left]
    intro i hi hi2
    simp only [Finset.mem_Icc] at hi hi2
    omega
  have hstep1 : ∑ i ∈ Icc 1 b, -Real.log (1 - x ^ i)
      ≤ ∑ i ∈ Icc 1 N, -Real.log (1 - x ^ i) + ∑ i ∈ Icc (N+1) b, -Real.log (1 - x ^ i) := by
    rw [← Finset.sum_union hdisj]
    exact Finset.sum_le_sum_of_subset_of_nonneg hsub (fun i hi _ => hnonneg i hi)
  -- Part A
  have hA : ∑ i ∈ Icc 1 N, -Real.log (1 - x ^ i) ≤ 4 * N := by
    have hterm : ∀ i ∈ Icc 1 N,
        -Real.log (1 - x ^ i) ≤ Real.log (8 * N) - Real.log i := by
      intro i hi
      simp only [Finset.mem_Icc] at hi
      have hipos : (0:ℝ) < (i:ℝ) := by
        have : 0 < i := hi.1
        exact_mod_cast this
      have hlow := one_sub_pow_lower N hN i hi.1 hi.2
      have hd : (0:ℝ) < (i:ℝ) / (8 * N) := by positivity
      have := Real.log_le_log hd hlow
      rw [Real.log_div (ne_of_gt hipos) (by positivity)] at this
      linarith
    have hsum := Finset.sum_le_sum hterm
    have hcard : (Icc 1 N).card = N := by simp
    have hsplit : ∑ i ∈ Icc 1 N, (Real.log (8 * N) - Real.log i)
        = N * Real.log (8 * N) - ∑ i ∈ Icc 1 N, Real.log i := by
      rw [Finset.sum_sub_distrib, Finset.sum_const, hcard, nsmul_eq_mul]
    have hfact : ∑ i ∈ Icc 1 N, Real.log i = Real.log (N.factorial) := by
      rw [← Real.log_prod]
      · congr 1
        rw [← Nat.cast_prod]
        norm_cast
        rw [← Finset.Ico_add_one_right_eq_Icc 1 N, Finset.prod_Ico_id_eq_factorial]
      · intro i hi
        simp only [Finset.mem_Icc] at hi
        have : 0 < i := hi.1
        positivity
    have hlogfact : (N:ℝ) * Real.log N - N ≤ Real.log (N.factorial) := log_factorial_ge N
    have hlog8 : Real.log (8 * N) = Real.log 8 + Real.log N := by
      rw [Real.log_mul (by norm_num) (by positivity)]
    have hlog8le : Real.log 8 ≤ 3 := by
      have h2 : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
      have : Real.log 8 = 3 * Real.log 2 := by
        rw [show (8:ℝ) = 2 ^ (3:ℕ) by norm_num, Real.log_pow]
        norm_num
      linarith
    rw [hsplit, hfact, hlog8] at hsum
    nlinarith [hsum, hlogfact, hlog8le, hNpos]
  -- Part B
  have hB : ∑ i ∈ Icc (N+1) b, -Real.log (1 - x ^ i) ≤ 2 * N := by
    have hterm : ∀ i ∈ Icc (N+1) b, -Real.log (1 - x ^ i) ≤ 2 * x ^ i := by
      intro i hi
      simp only [Finset.mem_Icc] at hi
      exact neg_log_one_sub_pow_le N hN i hi.1
    have h1 : ∑ i ∈ Icc (N+1) b, -Real.log (1 - x ^ i) ≤ ∑ i ∈ Icc (N+1) b, 2 * x ^ i :=
      Finset.sum_le_sum hterm
    have hsub2 : Icc (N+1) b ⊆ range (b+1) := by
      intro i hi
      simp only [Finset.mem_Icc] at hi
      simp only [Finset.mem_range]
      omega
    have h2 : ∑ i ∈ Icc (N+1) b, 2 * x ^ i ≤ ∑ i ∈ range (b+1), 2 * x ^ i :=
      Finset.sum_le_sum_of_subset_of_nonneg hsub2 (fun i _ _ => by positivity)
    have h3 : ∑ i ∈ range (b+1), 2 * x ^ i = 2 * ∑ i ∈ range (b+1), x ^ i := by
      rw [Finset.mul_sum]
    have h4 : ∑ i ∈ range (b+1), x ^ i ≤ (1 - x)⁻¹ :=
      geom_sum_le_inv_one_sub x hx0.le hx1 (b+1)
    have h5 : (1 - x)⁻¹ = (N:ℝ) := by
      rw [hxdef]
      simp only [sub_sub_cancel]
      rw [inv_inv]
    linarith
  linarith
end Sum

/-- Generating-function domination: for `0 < x < 1`, `p_{≤b}(m) x^m ≤ ∏_{i=1}^b (1-x^i)⁻¹`. -/
theorem pb_mul_pow_le_prod (b : ℕ) : ∀ (m : ℕ) (x : ℝ), 0 < x → x < 1 →
    (pb b m : ℝ) * x ^ m ≤ ∏ i ∈ Icc 1 b, (1 - x ^ i)⁻¹ := by
  induction b with
  | zero =>
      intro m x hx hx1
      simp only [pb_zero_left]
      by_cases hm : m = 0
      · subst hm; simp
      · simp [hm]
  | succ b ih =>
      intro m x hx hx1
      have hpos : ∀ i : ℕ, 1 ≤ i → 0 < 1 - x ^ i := by
        intro i hi
        have : x ^ i < 1 := pow_lt_one₀ hx.le hx1 (by omega)
        linarith
      have hPpos : 0 < ∏ i ∈ Icc 1 b, (1 - x ^ i)⁻¹ := by
        refine Finset.prod_pos fun i hi => ?_
        simp only [Finset.mem_Icc] at hi
        exact inv_pos.2 (hpos i hi.1)
      set K := m / (b + 1) with hK
      have hstep : (pb (b+1) m : ℝ) * x ^ m
          = ∑ c ∈ range (K + 1), (pb b (m - c * (b+1)) : ℝ) * x ^ m := by
        rw [pb_succ_left]
        push_cast
        rw [Finset.sum_mul]
      rw [hstep]
      have hterm : ∀ c ∈ range (K + 1),
          (pb b (m - c * (b+1)) : ℝ) * x ^ m
            ≤ (∏ i ∈ Icc 1 b, (1 - x ^ i)⁻¹) * (x ^ (b+1)) ^ c := by
        intro c hc
        simp only [Finset.mem_range] at hc
        have hcm : c * (b + 1) ≤ m := by
          have : c ≤ m / (b+1) := by omega
          calc c * (b+1) ≤ (m / (b+1)) * (b+1) := Nat.mul_le_mul_right _ this
            _ ≤ m := Nat.div_mul_le_self _ _
        have hxm : x ^ m = x ^ (m - c * (b+1)) * (x ^ (b+1)) ^ c := by
          rw [← pow_mul, ← pow_add]
          congr 1
          rw [Nat.mul_comm (b+1) c]
          omega
        rw [hxm, ← mul_assoc]
        refine mul_le_mul_of_nonneg_right (ih _ x hx hx1) (by positivity)
      calc ∑ c ∈ range (K + 1), (pb b (m - c * (b+1)) : ℝ) * x ^ m
          ≤ ∑ c ∈ range (K + 1), (∏ i ∈ Icc 1 b, (1 - x ^ i)⁻¹) * (x ^ (b+1)) ^ c :=
            Finset.sum_le_sum hterm
        _ = (∏ i ∈ Icc 1 b, (1 - x ^ i)⁻¹) * ∑ c ∈ range (K + 1), (x ^ (b+1)) ^ c := by
            rw [Finset.mul_sum]
        _ ≤ (∏ i ∈ Icc 1 b, (1 - x ^ i)⁻¹) * (1 - x ^ (b+1))⁻¹ := by
            refine mul_le_mul_of_nonneg_left ?_ hPpos.le
            set y := x ^ (b+1) with hydef
            have hy : y < 1 := pow_lt_one₀ hx.le hx1 (by omega)
            have hy0 : (0:ℝ) < 1 - y := by linarith
            have key : (1 - y) * ∑ c ∈ range (K+1), y ^ c = 1 - y ^ (K+1) := by
              have h := geom_sum_mul y (K+1)
              nlinarith [h]
            refine le_of_mul_le_mul_left ?_ hy0
            rw [key, mul_inv_cancel₀ (ne_of_gt hy0)]
            have : (0:ℝ) ≤ y ^ (K+1) := by positivity
            linarith
        _ = ∏ i ∈ Icc 1 (b+1), (1 - x ^ i)⁻¹ := by
            rw [Finset.prod_Icc_succ_top (by omega)]


/-- The truncated Euler product at `x = 1 - 1/N` is at most `exp (6N)`. -/
lemma prod_le_exp (b N : ℕ) (hN : 2 ≤ N) :
    ∏ i ∈ Icc 1 b, (1 - (1 - (N:ℝ)⁻¹) ^ i)⁻¹ ≤ Real.exp (6 * N) := by
  have hN2 : (2:ℝ) ≤ (N:ℝ) := by exact_mod_cast hN
  set x : ℝ := 1 - (N:ℝ)⁻¹ with hxdef
  have hinvle : (N:ℝ)⁻¹ ≤ 1/2 := by
    rw [inv_le_comm₀ (by linarith) (by norm_num)]; linarith
  have hinvpos : (0:ℝ) < (N:ℝ)⁻¹ := by positivity
  have hx0 : 0 < x := by rw [hxdef]; linarith
  have hx1 : x < 1 := by rw [hxdef]; linarith
  have hne : ∀ i ∈ Icc 1 b, (1 - x ^ i)⁻¹ ≠ 0 := by
    intro i hi
    simp only [Finset.mem_Icc] at hi
    have h1 : x ^ i < 1 := pow_lt_one₀ hx0.le hx1 (by omega)
    simp only [ne_eq, inv_eq_zero]
    intro h
    linarith
  have hpos : 0 < ∏ i ∈ Icc 1 b, (1 - x ^ i)⁻¹ := by
    refine Finset.prod_pos fun i hi => ?_
    simp only [Finset.mem_Icc] at hi
    have h1 : x ^ i < 1 := pow_lt_one₀ hx0.le hx1 (by omega)
    exact inv_pos.2 (by linarith)
  have hlog : Real.log (∏ i ∈ Icc 1 b, (1 - x ^ i)⁻¹) ≤ 6 * N := by
    rw [Real.log_prod hne]
    have : ∀ i ∈ Icc 1 b, Real.log ((1 - x ^ i)⁻¹) = -Real.log (1 - x ^ i) := by
      intro i _; rw [Real.log_inv]
    rw [Finset.sum_congr rfl this]
    exact sum_neg_log_le N b hN
  calc ∏ i ∈ Icc 1 b, (1 - x ^ i)⁻¹ = Real.exp (Real.log (∏ i ∈ Icc 1 b, (1 - x ^ i)⁻¹)) :=
        (Real.exp_log hpos).symm
    _ ≤ Real.exp (6 * N) := Real.exp_le_exp.2 hlog

/-- Uniform bound on bounded-partition counts, with a free parameter `N`. -/
lemma log_pb_le_param (b m N : ℕ) (hN : 2 ≤ N) :
    Real.log (pb b m) ≤ 6 * N + 2 * m / N := by
  have hN2 : (2:ℝ) ≤ (N:ℝ) := by exact_mod_cast hN
  have hNpos : (0:ℝ) < (N:ℝ) := by linarith
  set x : ℝ := 1 - (N:ℝ)⁻¹ with hxdef
  have hinvle : (N:ℝ)⁻¹ ≤ 1/2 := by
    rw [inv_le_comm₀ (by linarith) (by norm_num)]; linarith
  have hinvpos : (0:ℝ) < (N:ℝ)⁻¹ := by positivity
  have hx0 : 0 < x := by rw [hxdef]; linarith
  have hx1 : x < 1 := by rw [hxdef]; linarith
  have hxhalf : (1:ℝ)/2 ≤ x := by rw [hxdef]; linarith
  have hmain : (pb b m : ℝ) * x ^ m ≤ Real.exp (6 * N) :=
    (pb_mul_pow_le_prod b m x hx0 hx1).trans (prod_le_exp b N hN)
  rcases Nat.eq_zero_or_pos (pb b m) with h0 | h0
  · rw [h0]
    simp only [Nat.cast_zero, Real.log_zero]
    positivity
  · have hppos : (0:ℝ) < (pb b m : ℝ) := by exact_mod_cast h0
    have hxm : (0:ℝ) < x ^ m := by positivity
    have hlog : Real.log ((pb b m : ℝ) * x ^ m) ≤ 6 * N := by
      have := Real.log_le_log (by positivity) hmain
      rwa [Real.log_exp] at this
    rw [Real.log_mul (ne_of_gt hppos) (ne_of_gt hxm), Real.log_pow] at hlog
    have hneglog : -Real.log x ≤ 2 / N := by
      have h1 : Real.log x⁻¹ ≤ x⁻¹ - 1 := Real.log_le_sub_one_of_pos (by positivity)
      rw [Real.log_inv] at h1
      have h2 : x⁻¹ ≤ 2 := by
        rw [inv_le_comm₀ hx0 (by norm_num)]
        linarith
      have h3 : x⁻¹ - 1 = (1 - x) / x := by field_simp
      have h4 : (1 - x) = (N:ℝ)⁻¹ := by rw [hxdef]; ring
      have h5 : (1 - x) / x = (N:ℝ)⁻¹ * x⁻¹ := by rw [h4, div_eq_mul_inv]
      have h6 : (N:ℝ)⁻¹ * x⁻¹ ≤ (N:ℝ)⁻¹ * 2 := by
        exact mul_le_mul_of_nonneg_left h2 hinvpos.le
      have h7 : (N:ℝ)⁻¹ * 2 = 2 / N := by field_simp
      linarith [h1, h3, h5, h6, h7]
    have hmn : (m:ℝ) * (-Real.log x) ≤ (m:ℝ) * (2 / N) :=
      mul_le_mul_of_nonneg_left hneglog (by positivity)
    have hfin : (m:ℝ) * (2 / N) = 2 * m / N := by ring
    linarith

/-- **Hardy–Ramanujan type bound**: `log p_{≤b}(m) ≤ 8 √m + 12`, uniformly in `b`. -/
theorem log_pb_le_sqrt (b m : ℕ) : Real.log (pb b m) ≤ 8 * Real.sqrt m + 12 := by
  set N := Nat.sqrt m + 2 with hNdef
  have hN : 2 ≤ N := by omega
  have hbound := log_pb_le_param b m N hN
  have hNpos : (0:ℝ) < (N:ℝ) := by
    have : (0:ℕ) < N := by omega
    exact_mod_cast this
  have hsq : Real.sqrt m ≤ (N:ℝ) := by
    have := sqrt_lt_natSqrt_add_one m
    have h2 : ((Nat.sqrt m : ℝ) + 1) ≤ (N:ℝ) := by
      rw [hNdef]; push_cast; linarith
    linarith
  have hNle : (N:ℝ) ≤ Real.sqrt m + 2 := by
    have := natSqrt_le_sqrt m
    rw [hNdef]; push_cast; linarith
  have hsqnn : (0:ℝ) ≤ Real.sqrt m := Real.sqrt_nonneg _
  have hmsq : (m:ℝ) = Real.sqrt m * Real.sqrt m :=
    (Real.mul_self_sqrt (by positivity)).symm
  have hdiv : 2 * (m:ℝ) / N ≤ 2 * Real.sqrt m := by
    rw [div_le_iff₀ hNpos]
    nlinarith [hsq, hsqnn, hmsq]
  linarith

/-- Exponential form of the bound. -/
lemma pb_le_exp_sqrt (b m : ℕ) : (pb b m : ℝ) ≤ Real.exp (8 * Real.sqrt m + 12) := by
  rcases Nat.eq_zero_or_pos (pb b m) with h0 | h0
  · rw [h0]
    simp only [Nat.cast_zero]
    positivity
  · have hppos : (0:ℝ) < (pb b m : ℝ) := by exact_mod_cast h0
    calc (pb b m : ℝ) = Real.exp (Real.log (pb b m)) := (Real.exp_log hppos).symm
      _ ≤ _ := Real.exp_le_exp.2 (log_pb_le_sqrt b m)

lemma conv_le_exp_sqrt (b M : ℕ) :
    (conv b M : ℝ) ≤ ((M:ℝ) + 1) * Real.exp (16 * Real.sqrt M + 24) := by
  have hMnn : (0:ℝ) ≤ (M:ℝ) := by positivity
  have hterm : ∀ j ∈ range (M + 1),
      ((pb b j : ℝ) * (pb b (M - j) : ℝ)) ≤ Real.exp (16 * Real.sqrt M + 24) := by
    intro j hj
    simp only [Finset.mem_range] at hj
    have h1 : (pb b j : ℝ) ≤ Real.exp (8 * Real.sqrt M + 12) := by
      refine (pb_le_exp_sqrt b j).trans (Real.exp_le_exp.2 ?_)
      have : Real.sqrt j ≤ Real.sqrt M := by
        apply Real.sqrt_le_sqrt
        exact_mod_cast Nat.cast_le.2 (by omega : j ≤ M)
      linarith
    have h2 : (pb b (M - j) : ℝ) ≤ Real.exp (8 * Real.sqrt M + 12) := by
      refine (pb_le_exp_sqrt b (M - j)).trans (Real.exp_le_exp.2 ?_)
      have : Real.sqrt (M - j : ℕ) ≤ Real.sqrt M := by
        apply Real.sqrt_le_sqrt
        exact_mod_cast Nat.cast_le.2 (by omega : M - j ≤ M)
      linarith
    calc (pb b j : ℝ) * (pb b (M - j) : ℝ)
        ≤ Real.exp (8 * Real.sqrt M + 12) * Real.exp (8 * Real.sqrt M + 12) := by
          refine mul_le_mul h1 h2 (by positivity) (by positivity)
      _ = Real.exp (16 * Real.sqrt M + 24) := by rw [← Real.exp_add]; ring_nf
  have hsum : (conv b M : ℝ) = ∑ j ∈ range (M + 1), ((pb b j : ℝ) * (pb b (M - j) : ℝ)) := by
    rw [conv]; push_cast; ring
  rw [hsum]
  calc ∑ j ∈ range (M + 1), ((pb b j : ℝ) * (pb b (M - j) : ℝ))
      ≤ ∑ _j ∈ range (M + 1), Real.exp (16 * Real.sqrt M + 24) := Finset.sum_le_sum hterm
    _ = ((M:ℝ) + 1) * Real.exp (16 * Real.sqrt M + 24) := by
        rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul]
        push_cast; ring

lemma stackSC_le_exp_sqrt (n : ℕ) :
    (stackSC n : ℝ) ≤ ((n:ℝ) + 1) ^ 2 * Real.exp (16 * Real.sqrt n + 24) := by
  have hnn : (0:ℝ) ≤ (n:ℝ) := by positivity
  have hcast : (stackSC n : ℝ)
      = ∑ k ∈ range (n + 1), (if k * k ≤ n then (conv (k - 1) (n - k * k) : ℝ) else 0) := by
    rw [stackSC]
    push_cast
    exact Finset.sum_congr rfl (fun k _ => by split_ifs <;> simp)
  rw [hcast]
  calc ∑ k ∈ range (n + 1), (if k * k ≤ n then (conv (k - 1) (n - k * k) : ℝ) else 0)
      ≤ ∑ _k ∈ range (n + 1), ((n:ℝ) + 1) * Real.exp (16 * Real.sqrt n + 24) := by
        refine Finset.sum_le_sum (fun k _ => ?_)
        by_cases hk : k * k ≤ n
        · rw [if_pos hk]
          refine (conv_le_exp_sqrt (k - 1) (n - k * k)).trans ?_
          have h1 : ((n - k * k : ℕ) : ℝ) + 1 ≤ (n:ℝ) + 1 := by
            have : ((n - k * k : ℕ) : ℝ) ≤ (n:ℝ) := by
              exact_mod_cast Nat.cast_le.2 (Nat.sub_le _ _)
            linarith
          have h2 : Real.exp (16 * Real.sqrt (n - k * k : ℕ) + 24)
              ≤ Real.exp (16 * Real.sqrt n + 24) := by
            refine Real.exp_le_exp.2 ?_
            have : Real.sqrt ((n - k * k : ℕ) : ℝ) ≤ Real.sqrt n := by
              apply Real.sqrt_le_sqrt
              exact_mod_cast Nat.cast_le.2 (Nat.sub_le n (k * k))
            linarith
          exact mul_le_mul h1 h2 (by positivity) (by positivity)
        · rw [if_neg hk]; positivity
    _ = ((n:ℝ) + 1) ^ 2 * Real.exp (16 * Real.sqrt n + 24) := by
        rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul]
        push_cast; ring

/-- **Sharp-order upper bound**: `log a(n) ≤ 16 √n + 2 log(n+1) + 24`. -/
theorem log_stackSC_le_sqrt (n : ℕ) :
    Real.log (stackSC n) ≤ 16 * Real.sqrt n + 2 * Real.log ((n:ℝ) + 1) + 24 := by
  have hnn : (0:ℝ) ≤ (n:ℝ) := by positivity
  have hb := stackSC_le_exp_sqrt n
  rcases Nat.eq_zero_or_pos (stackSC n) with h0 | h0
  · rw [h0]
    simp only [Nat.cast_zero, Real.log_zero]
    have : (0:ℝ) ≤ Real.log ((n:ℝ) + 1) := Real.log_nonneg (by linarith)
    have hs : (0:ℝ) ≤ Real.sqrt n := Real.sqrt_nonneg _
    linarith
  · have hpos : (0:ℝ) < (stackSC n : ℝ) := by exact_mod_cast h0
    have := Real.log_le_log hpos hb
    rw [Real.log_mul (by positivity) (Real.exp_ne_zero _), Real.log_pow, Real.log_exp] at this
    push_cast at this
    linarith

private lemma sqrt_succ_le (n : ℕ) : Real.sqrt ((n:ℝ) + 1) ≤ Real.sqrt n + 1 := by
  have hs : (0:ℝ) ≤ Real.sqrt n := Real.sqrt_nonneg _
  have hsq : Real.sqrt n * Real.sqrt n = (n:ℝ) := Real.mul_self_sqrt (by positivity)
  rw [show (Real.sqrt n + 1) = Real.sqrt ((Real.sqrt n + 1) ^ 2) from
    (Real.sqrt_sq (by positivity)).symm]
  apply Real.sqrt_le_sqrt
  nlinarith

private lemma two_log_succ_le (n : ℕ) : 2 * Real.log ((n:ℝ) + 1) ≤ 4 * Real.sqrt n := by
  have hpos : (0:ℝ) < (n:ℝ) + 1 := by positivity
  have hsqpos : (0:ℝ) < Real.sqrt ((n:ℝ) + 1) := Real.sqrt_pos.2 hpos
  have h1 : Real.log (Real.sqrt ((n:ℝ) + 1)) ≤ Real.sqrt ((n:ℝ) + 1) - 1 :=
    Real.log_le_sub_one_of_pos hsqpos
  have h2 : Real.log (Real.sqrt ((n:ℝ) + 1)) = Real.log ((n:ℝ) + 1) / 2 :=
    Real.log_sqrt hpos.le
  have h3 := sqrt_succ_le n
  rw [h2] at h1
  linarith

/-- **Sharp two-sided stretched-exponential estimate**: for `n ≥ 100`,
`((√n - 2)/2)·log 2 ≤ log a(n) ≤ 30 √n`.  In particular `log a(n) ≍ √n`: the
`log n` factor of `stackSC_log_sqrt_bounds` is spurious. -/
theorem stackSC_log_sqrt_sharp (n : ℕ) (hn : 100 ≤ n) :
    (Real.sqrt n - 2) / 2 * Real.log 2 ≤ Real.log (stackSC n) ∧
      Real.log (stackSC n) ≤ 30 * Real.sqrt n := by
  refine ⟨log_stackSC_ge n hn, ?_⟩
  have hs10 : (10:ℝ) ≤ Real.sqrt n := by
    rw [show (10:ℝ) = Real.sqrt 100 by
      rw [show (100:ℝ) = 10 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]]
    exact Real.sqrt_le_sqrt (by exact_mod_cast hn)
  have h1 := log_stackSC_le_sqrt n
  have h2 := two_log_succ_le n
  linarith

/-- `log a(n) = O(√n)`. -/
theorem log_stackSC_isBigO_sqrt :
    (fun n : ℕ => Real.log (stackSC n)) =O[atTop] (fun n : ℕ => Real.sqrt n) := by
  refine Asymptotics.IsBigO.of_bound 30 ?_
  filter_upwards [eventually_ge_atTop 100] with n hn
  have h := (stackSC_log_sqrt_sharp n hn).2
  have hlow : 0 ≤ Real.log (stackSC n) := by
    have h1 : 1 ≤ stackSC n := stackSC_pos n (by omega) (by omega)
    have : (1:ℝ) ≤ (stackSC n : ℝ) := by exact_mod_cast h1
    exact Real.log_nonneg this
  rw [Real.norm_eq_abs, Real.norm_eq_abs, abs_of_nonneg hlow,
    abs_of_nonneg (Real.sqrt_nonneg _)]
  linarith

/-- `√n = O(log a(n))`: together with `log_stackSC_isBigO_sqrt`, `log a(n) ≍ √n`. -/
theorem sqrt_isBigO_log_stackSC :
    (fun n : ℕ => Real.sqrt n) =O[atTop] (fun n : ℕ => Real.log (stackSC n)) := by
  refine Asymptotics.IsBigO.of_bound 4 ?_
  filter_upwards [eventually_ge_atTop 100] with n hn
  have hs10 : (10:ℝ) ≤ Real.sqrt n := by
    rw [show (10:ℝ) = Real.sqrt 100 by
      rw [show (100:ℝ) = 10 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]]
    exact Real.sqrt_le_sqrt (by exact_mod_cast hn)
  have hlog2 : (0.6931471803:ℝ) < Real.log 2 := Real.log_two_gt_d9
  have h := (stackSC_log_sqrt_sharp n hn).1
  have hlow : 0 ≤ Real.log (stackSC n) := by
    have h1 : 1 ≤ stackSC n := stackSC_pos n (by omega) (by omega)
    have : (1:ℝ) ≤ (stackSC n : ℝ) := by exact_mod_cast h1
    exact Real.log_nonneg this
  rw [Real.norm_eq_abs, Real.norm_eq_abs, abs_of_nonneg hlow,
    abs_of_nonneg (Real.sqrt_nonneg _)]
  nlinarith [h, hs10, hlog2]

end Physics.StackSquareCore