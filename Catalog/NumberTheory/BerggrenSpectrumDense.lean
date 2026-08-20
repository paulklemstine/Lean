import Catalog.NumberTheory.BerggrenRateSpectrum

/-!
# Hyperbolic–Pythagorean Geodesics, cycle XI: the growth spectrum is dense

Sequel to `NumberTheory/BerggrenRateSpectrum.lean`.  Cycle X refuted conjecture I1's claim
that the metric growth rate of a `B₁`-free Berggren path is a function of the asymptotic
frequency of the middle move, and exhibited infinitely many exact interior rates
accumulating at `0`.  This file settles the *first* clause of I1 in the strongest form
that survives that refutation: the set of exactly realised rates is **dense** in the whole
interval `[0, log(1+√2)]`.

The tool is the two–parameter family of periodic words `(B₂^a B₃^b)^∞` with `a` odd.  The
period matrix is `M^a R^b` with `M = [[2,1],[1,0]]`, `R = [[1,2],[0,1]]`; its entries are
Pell numbers, its determinant is `(-1)^a = -1`, and its trace is
`T(a,b) = P_{a+1} + 2 b P_a + P_{a-1}`, so the growth constant is the quadratic surd
`σ(a,b) = (T + √(T²+4))/2` and the rate is `log σ(a,b)/(a+b)`.
-/

namespace HyperbolicBerggrenGeodesics

open Real Filter Topology

noncomputable section

/-! ## Part I. Pell numbers and the matrix `M^a` -/

/-- The Pell numbers `P_0 = 0`, `P_1 = 1`, `P_{k+2} = 2P_{k+1} + P_k`. -/
def pellNum : ℕ → ℕ
  | 0 => 0
  | 1 => 1
  | (k + 2) => 2 * pellNum (k + 1) + pellNum k

/-- The shifted Pell number `P_{a-1}`, with the convention `P_{-1} = 1`. -/
def pellPrev : ℕ → ℕ
  | 0 => 1
  | (a + 1) => pellNum a

theorem pellNum_succ_eq (a : ℕ) : pellNum (a + 1) = 2 * pellNum a + pellPrev a := by
  cases a with
  | zero => rfl
  | succ a => rfl

theorem pellNum_pos (a : ℕ) (ha : 0 < a) : 0 < pellNum a := by
  induction a with
  | zero => omega
  | succ a ih =>
      rcases Nat.eq_zero_or_pos a with h | h
      · subst h; norm_num [pellNum]
      · have := ih h
        rw [pellNum_succ_eq]
        omega

theorem pellPrev_le (a : ℕ) (ha : 0 < a) : pellPrev a ≤ pellNum a := by
  cases a with
  | zero => omega
  | succ a =>
      show pellNum a ≤ pellNum (a + 1)
      rw [pellNum_succ_eq]
      omega

/-- **Cassini's identity for the Pell numbers**: `P_{a+1} P_{a-1} − P_a² = (−1)^a`. -/
theorem pell_cassini (a : ℕ) :
    (pellNum (a + 1) : ℤ) * (pellPrev a : ℤ) - (pellNum a : ℤ) ^ 2 = (-1) ^ a := by
  induction a with
  | zero => norm_num [pellNum, pellPrev]
  | succ a ih =>
      have hstep : (pellNum (a + 2) : ℤ) = 2 * pellNum (a + 1) + pellNum a := by
        rw [show pellNum (a + 2) = 2 * pellNum (a + 1) + pellNum a from rfl]; push_cast; ring
      have hprev : (pellPrev (a + 1) : ℤ) = pellNum a := rfl
      rw [hstep, hprev, pow_succ]
      have hp : (pellNum (a + 1) : ℤ) = 2 * pellNum a + pellPrev a := by
        rw [pellNum_succ_eq]; push_cast; ring
      linear_combination -ih - (pellNum (a + 1) : ℤ) * hp

/-- For odd `a` Cassini's identity reads `P_a² = P_{a+1} P_{a-1} + 1`, an identity of
natural numbers. -/
theorem pell_cassini_odd {a : ℕ} (ha : Odd a) :
    pellNum a ^ 2 = pellNum (a + 1) * pellPrev a + 1 := by
  have h := pell_cassini a
  rw [ha.neg_one_pow] at h
  have : ((pellNum a ^ 2 : ℕ) : ℤ) = ((pellNum (a + 1) * pellPrev a + 1 : ℕ) : ℤ) := by
    push_cast; linarith
  exact_mod_cast this

/-- **The action of `B₂^a`.**  Running `a` copies of the middle move applies the matrix
`M^a = [[P_{a+1}, P_a], [P_a, P_{a-1}]]`. -/
theorem run_replicate_M (a : ℕ) (w : List Move) :
    run (List.replicate a Move.M ++ w)
      = (pellNum (a + 1) * (run w).1 + pellNum a * (run w).2,
         pellNum a * (run w).1 + pellPrev a * (run w).2) := by
  induction a with
  | zero => simp [pellNum, pellPrev]
  | succ a ih =>
      have hcons : List.replicate (a + 1) Move.M ++ w
          = Move.M :: (List.replicate a Move.M ++ w) := by
        simp [List.replicate_succ]
      have hstep : run (Move.M :: (List.replicate a Move.M ++ w))
          = seedM (run (List.replicate a Move.M ++ w)) := rfl
      rw [hcons, hstep, ih]
      have h1 : pellNum (a + 2) = 2 * pellNum (a + 1) + pellNum a := rfl
      have h2 : pellPrev (a + 1) = pellNum a := rfl
      refine Prod.ext_iff.mpr ⟨?_, ?_⟩
      · show 2 * (pellNum (a + 1) * (run w).1 + pellNum a * (run w).2)
              + (pellNum a * (run w).1 + pellPrev a * (run w).2)
            = pellNum (a + 2) * (run w).1 + pellNum (a + 1) * (run w).2
        rw [h1, pellNum_succ_eq a]; ring
      · show pellNum (a + 1) * (run w).1 + pellNum a * (run w).2
            = pellNum (a + 1) * (run w).1 + pellPrev (a + 1) * (run w).2
        rw [h2]

/-! ## Part J. The quadratic surd attached to a trace with determinant `-1` -/

/-- The dominant root of `x² = T x + 1`. -/
def sigmaT (T : ℝ) : ℝ := (T + Real.sqrt (T ^ 2 + 4)) / 2

theorem sigmaT_sqrt_sq (T : ℝ) : Real.sqrt (T ^ 2 + 4) ^ 2 = T ^ 2 + 4 :=
  Real.sq_sqrt (by positivity)

theorem sigmaT_gt (T : ℝ) (hT : 0 ≤ T) : T < sigmaT T := by
  have h := sigmaT_sqrt_sq T
  have hnn : 0 ≤ Real.sqrt (T ^ 2 + 4) := Real.sqrt_nonneg _
  simp only [sigmaT]
  nlinarith

theorem sigmaT_lt (T : ℝ) (hT : 0 < T) : sigmaT T < T + 1 := by
  have h := sigmaT_sqrt_sq T
  have hnn : 0 ≤ Real.sqrt (T ^ 2 + 4) := Real.sqrt_nonneg _
  simp only [sigmaT]
  nlinarith

theorem sigmaT_sq (T : ℝ) : sigmaT T ^ 2 = T * sigmaT T + 1 := by
  have h := sigmaT_sqrt_sq T
  simp only [sigmaT]
  nlinarith

theorem sigmaT_mono {T U : ℝ} (hT : 0 ≤ T) (h : T ≤ U) : sigmaT T ≤ sigmaT U := by
  have hs : Real.sqrt (T ^ 2 + 4) ≤ Real.sqrt (U ^ 2 + 4) :=
    Real.sqrt_le_sqrt (by nlinarith)
  simp only [sigmaT]
  linarith

/-! ## Part K. The two-parameter family `(B₂^a B₃^b)^∞` -/

/-- The trace of the period matrix `M^a R^b`, namely `P_{a+1} + 2b P_a + P_{a-1}`. -/
def traceG (a b : ℕ) : ℕ := pellNum (a + 1) + 2 * b * pellNum a + pellPrev a

/-- The Perron root of the period matrix `M^a R^b` for odd `a` (determinant `-1`). -/
def sigmaG (a b : ℕ) : ℝ := sigmaT (traceG a b)

/-- The metric growth rate of the path `(B₂^a B₃^b)^∞`. -/
def rateG (a b : ℕ) : ℝ := Real.log (sigmaG a b) / ((a : ℝ) + (b : ℝ))

/-- The `B₁`-free periodic word `(B₂^a B₃^b)^j`. -/
def wordG (a b : ℕ) : ℕ → List Move
  | 0 => []
  | j + 1 => List.replicate a Move.M ++ (List.replicate b Move.R ++ wordG a b j)

theorem wordG_length (a b j : ℕ) : (wordG a b j).length = (a + b) * j := by
  induction j with
  | zero => rfl
  | succ j ih => simp [wordG, ih]; ring

theorem wordG_countM (a b j : ℕ) : countM (wordG a b j) = a * j := by
  have hM : List.count Move.M (List.replicate a Move.M) = a := by
    rw [List.count_replicate]; simp
  have hR : List.count Move.M (List.replicate b Move.R) = 0 := by
    rw [List.count_replicate]; simp
  induction j with
  | zero => rfl
  | succ j ih =>
      have h : wordG a b (j + 1)
          = List.replicate a Move.M ++ (List.replicate b Move.R ++ wordG a b j) := rfl
      unfold countM
      rw [h, List.count_append, List.count_append, hM, hR]
      unfold countM at ih
      rw [ih]
      ring

theorem wordG_no_L (a b j : ℕ) : Move.L ∉ wordG a b j := by
  induction j with
  | zero => simp [wordG]
  | succ j ih =>
      have h : wordG a b (j + 1)
          = List.replicate a Move.M ++ (List.replicate b Move.R ++ wordG a b j) := rfl
      rw [h]
      simp [List.mem_append, ih]

/-- One period of the family, as a linear map of seeds. -/
def stepMat (a b : ℕ) (v : ℕ × ℕ) : ℕ × ℕ :=
  (pellNum (a + 1) * (v.1 + 2 * b * v.2) + pellNum a * v.2,
   pellNum a * (v.1 + 2 * b * v.2) + pellPrev a * v.2)

theorem run_wordG_succ (a b j : ℕ) :
    run (wordG a b (j + 1)) = stepMat a b (run (wordG a b j)) := by
  have h : wordG a b (j + 1)
      = List.replicate a Move.M ++ (List.replicate b Move.R ++ wordG a b j) := rfl
  rw [h, run_replicate_M, run_replicate_R]
  rfl

/-- **The two-term recurrence.**  For odd `a` the period matrix has determinant `-1`, so
the first coordinate satisfies `x_{j+2} = T x_{j+1} + x_j` with `T = traceG a b`. -/
theorem stepMat_rec {a : ℕ} (ha : Odd a) (b : ℕ) (v : ℕ × ℕ) :
    (stepMat a b (stepMat a b v)).1 = traceG a b * (stepMat a b v).1 + v.1 := by
  have hc := pell_cassini_odd ha
  simp only [stepMat, traceG]
  zify
  zify at hc
  linear_combination (v.1 : ℤ) * hc

theorem wordG_rec {a : ℕ} (ha : Odd a) (b j : ℕ) :
    (run (wordG a b (j + 2))).1
      = traceG a b * (run (wordG a b (j + 1))).1 + (run (wordG a b j)).1 := by
  rw [show j + 2 = (j + 1) + 1 from rfl, run_wordG_succ a b (j + 1), run_wordG_succ a b j]
  exact stepMat_rec ha b _

/-! ## Part L. Geometric two-sided bounds and the exact rate -/

/-- Elementary facts about the Pell entries of the period matrix, for odd `a`. -/
theorem pell_odd_facts {a : ℕ} (ha : Odd a) :
    1 ≤ pellNum a ∧ pellPrev a ≤ pellNum a ∧
      pellNum (a + 1) = 2 * pellNum a + pellPrev a := by
  have hpos : 0 < a := ha.pos
  exact ⟨pellNum_pos a hpos, pellPrev_le a hpos, pellNum_succ_eq a⟩

theorem one_le_traceG {a : ℕ} (ha : Odd a) (b : ℕ) : 1 ≤ traceG a b := by
  obtain ⟨hq, hs, hp⟩ := pell_odd_facts ha
  simp only [traceG]
  omega

theorem traceG_pos_real {a : ℕ} (ha : Odd a) (b : ℕ) : (1 : ℝ) ≤ (traceG a b : ℝ) := by
  exact_mod_cast one_le_traceG ha b

theorem one_lt_sigmaG {a : ℕ} (ha : Odd a) (b : ℕ) : 1 < sigmaG a b := by
  have h1 := traceG_pos_real ha b
  have h2 := sigmaT_gt ((traceG a b : ℝ)) (by linarith)
  simp only [sigmaG]
  linarith

theorem sigmaG_pos {a : ℕ} (ha : Odd a) (b : ℕ) : 0 < sigmaG a b :=
  lt_trans zero_lt_one (one_lt_sigmaG ha b)

theorem wordG_base_zero (a b : ℕ) : run (wordG a b 0) = (2, 1) := rfl

theorem wordG_base_one (a b : ℕ) :
    (run (wordG a b 1)).1 = pellNum (a + 1) * (2 + 2 * b) + pellNum a := by
  rw [show (1 : ℕ) = 0 + 1 from rfl, run_wordG_succ a b 0, wordG_base_zero]
  simp [stepMat]

/-- Geometric two-sided bounds along `(B₂^a B₃^b)^j` for odd `a`. -/
theorem wordG_sandwich {a : ℕ} (ha : Odd a) (b j : ℕ) :
    1 * sigmaG a b ^ j ≤ ((run (wordG a b j)).1 : ℝ) ∧
      ((run (wordG a b j)).1 : ℝ) ≤ 3 * sigmaG a b ^ j := by
  obtain ⟨hq, hs, hp⟩ := pell_odd_facts ha
  have hqR : (1 : ℝ) ≤ (pellNum a : ℝ) := by exact_mod_cast hq
  have hsR : (pellPrev a : ℝ) ≤ (pellNum a : ℝ) := by exact_mod_cast hs
  have hpR : (pellNum (a + 1) : ℝ) = 2 * (pellNum a : ℝ) + (pellPrev a : ℝ) := by
    exact_mod_cast congrArg (fun t : ℕ => (t : ℝ)) hp
  have hsnn : (0 : ℝ) ≤ (pellPrev a : ℝ) := Nat.cast_nonneg _
  have hbR : (0 : ℝ) ≤ (b : ℝ) := Nat.cast_nonneg _
  have hTdef : (traceG a b : ℝ)
      = (pellNum (a + 1) : ℝ) + 2 * (b : ℝ) * (pellNum a : ℝ) + (pellPrev a : ℝ) := by
    simp only [traceG]; push_cast; ring
  have hT1 := traceG_pos_real ha b
  have hgt : (traceG a b : ℝ) < sigmaG a b := sigmaT_gt _ (by linarith)
  have hlt : sigmaG a b < (traceG a b : ℝ) + 1 := sigmaT_lt _ (by linarith)
  have hspos := sigmaG_pos ha b
  have hssq : sigmaG a b ^ 2 = (traceG a b : ℝ) * sigmaG a b + 1 := sigmaT_sq _
  have hbase0 : ((run (wordG a b 0)).1 : ℝ) = 2 := by rw [wordG_base_zero]; norm_num
  have hbase1 : ((run (wordG a b 1)).1 : ℝ)
      = (pellNum (a + 1) : ℝ) * (2 + 2 * (b : ℝ)) + (pellNum a : ℝ) := by
    rw [wordG_base_one]; push_cast; ring
  have key : ∀ j, (1 * sigmaG a b ^ j ≤ ((run (wordG a b j)).1 : ℝ) ∧
      ((run (wordG a b j)).1 : ℝ) ≤ 3 * sigmaG a b ^ j) ∧
      (1 * sigmaG a b ^ (j + 1) ≤ ((run (wordG a b (j + 1))).1 : ℝ) ∧
        ((run (wordG a b (j + 1))).1 : ℝ) ≤ 3 * sigmaG a b ^ (j + 1)) := by
    intro j
    induction j with
    | zero =>
        refine ⟨⟨by rw [hbase0]; norm_num, by rw [hbase0]; norm_num⟩, ?_⟩
        have hp1 : sigmaG a b ^ (0 + 1) = sigmaG a b := by norm_num
        rw [hbase1, hp1]
        constructor
        · nlinarith
        · nlinarith
    | succ j ih =>
        refine ⟨ih.2, ?_⟩
        have hrecn := wordG_rec ha b j
        have hrec : ((run (wordG a b (j + 2))).1 : ℝ)
            = (traceG a b : ℝ) * ((run (wordG a b (j + 1))).1 : ℝ)
              + ((run (wordG a b j)).1 : ℝ) := by
          rw [hrecn]; push_cast; ring
        have hpowj : (0 : ℝ) < sigmaG a b ^ j := pow_pos hspos j
        have hexp : sigmaG a b ^ (j + 2)
            = (traceG a b : ℝ) * sigmaG a b ^ (j + 1) + sigmaG a b ^ j := by
          have hsq : sigmaG a b ^ (j + 2) = sigmaG a b ^ j * sigmaG a b ^ 2 := by ring
          rw [hsq, hssq]; ring
        refine ⟨?_, ?_⟩
        · rw [show j + 1 + 1 = j + 2 from rfl, hrec, hexp]
          nlinarith [ih.1.1, ih.2.1]
        · rw [show j + 1 + 1 = j + 2 from rfl, hrec, hexp]
          nlinarith [ih.1.2, ih.2.2]
  exact (key j).1

/-- **The exact metric growth rate of `(B₂^a B₃^b)^∞` for odd `a`** is
`log σ(a,b)/(a+b)` with `σ(a,b) = (T + √(T²+4))/2`, `T = P_{a+1} + 2b P_a + P_{a-1}`. -/
theorem wordG_rate_tendsto {a : ℕ} (ha : Odd a) (b : ℕ) :
    Tendsto (fun j : ℕ => wdist (wordG a b j) / (wordG a b j).length) atTop
      (𝓝 (rateG a b)) := by
  have hab : 0 < a + b := by have := ha.pos; omega
  have h := tendsto_rate_of_geometric (wordG a b) (sigmaG a b) 1 3 (a + b) hab
    (fun j => wordG_length a b j) (one_lt_sigmaG ha b) (by norm_num) (by norm_num)
    (fun j => (wordG_sandwich ha b j).1) (fun j => (wordG_sandwich ha b j).2)
  have hcast : ((a + b : ℕ) : ℝ) = (a : ℝ) + (b : ℝ) := by push_cast; ring
  simpa [rateG, hcast] using h

/-! ## Part M. The top of the spectrum lies in the family: `rateG a 0 = log(1+√2)` -/

/-- **Binet's formula for the Pell numbers**: `P_n = (λ^n − μ^n)/(2√2)`, `λ = 1+√2`,
`μ = 1−√2`. -/
theorem pell_binet (n : ℕ) :
    (pellNum n : ℝ) = (silver ^ n - silverBar ^ n) / (2 * Real.sqrt 2) := by
  have hs2 : Real.sqrt 2 ^ 2 = 2 := sqrt_two_sq
  have hs2pos : (0 : ℝ) < Real.sqrt 2 := by nlinarith [sqrt_two_bounds.1]
  have key : ∀ n, (pellNum n : ℝ) = (silver ^ n - silverBar ^ n) / (2 * Real.sqrt 2) ∧
      (pellNum (n + 1) : ℝ) = (silver ^ (n + 1) - silverBar ^ (n + 1)) / (2 * Real.sqrt 2) := by
    intro n
    induction n with
    | zero =>
        constructor
        · show ((0 : ℕ) : ℝ) = _
          simp
        · show ((1 : ℕ) : ℝ) = _
          simp only [silver, silverBar]
          field_simp
          ring
    | succ n ih =>
        refine ⟨ih.2, ?_⟩
        have hrec : pellNum (n + 2) = 2 * pellNum (n + 1) + pellNum n := rfl
        have ha : silver ^ (n + 2) = 2 * silver ^ (n + 1) + silver ^ n := by
          have h1 : silver ^ (n + 2) = silver ^ n * silver ^ 2 := by ring
          rw [h1, silver_sq_eq]; ring
        have hb : silverBar ^ (n + 2) = 2 * silverBar ^ (n + 1) + silverBar ^ n := by
          have h1 : silverBar ^ (n + 2) = silverBar ^ n * silverBar ^ 2 := by ring
          rw [h1, silverBar_sq_eq]; ring
        rw [show n + 1 + 1 = n + 2 from rfl, hrec]
        push_cast
        rw [ih.1, ih.2, ha, hb]
        field_simp
        ring
  exact (key n).1

/-- The trace of `M^a` is `λ^a + μ^a`. -/
theorem traceG_zero_eq {a : ℕ} (ha : 0 < a) :
    (traceG a 0 : ℝ) = silver ^ a + silverBar ^ a := by
  obtain ⟨c, rfl⟩ : ∃ c, a = c + 1 := ⟨a - 1, by omega⟩
  have hs2 : Real.sqrt 2 ^ 2 = 2 := sqrt_two_sq
  have hs2pos : (0 : ℝ) < Real.sqrt 2 := by nlinarith [sqrt_two_bounds.1]
  have hT : (traceG (c + 1) 0 : ℝ) = (pellNum (c + 2) : ℝ) + (pellNum c : ℝ) := by
    simp only [traceG, pellPrev]
    push_cast
    ring
  have hla : silver ^ (c + 2) = silver ^ c * silver ^ 2 := by ring
  have hlb : silverBar ^ (c + 2) = silverBar ^ c * silverBar ^ 2 := by ring
  have hl1 : silver ^ 2 + 1 = 2 * Real.sqrt 2 * silver := by
    simp only [silver]; nlinarith
  have hl2 : silverBar ^ 2 + 1 = -(2 * Real.sqrt 2) * silverBar := by
    simp only [silverBar]; nlinarith
  rw [hT, pell_binet, pell_binet]
  rw [← add_div, div_eq_iff (by positivity)]
  have hpow : silver ^ (c + 1) = silver ^ c * silver := by ring
  have hpowb : silverBar ^ (c + 1) = silverBar ^ c * silverBar := by ring
  rw [hla, hlb, hpow, hpowb]
  linear_combination (silver ^ c) * hl1 - (silverBar ^ c) * hl2

/-- For odd `a` the surd of `M^a` is exactly `λ^a`: the pure middle-move path is a member
of the family, at `b = 0`. -/
theorem sigmaG_zero {a : ℕ} (ha : Odd a) : sigmaG a 0 = silver ^ a := by
  have hs2 : Real.sqrt 2 ^ 2 = 2 := sqrt_two_sq
  have hT := traceG_zero_eq ha.pos
  have hmul : silver * silverBar = -1 := by
    simp only [silver, silverBar]; nlinarith
  have hprod : silver ^ a * silverBar ^ a = -1 := by
    rw [← mul_pow, hmul, ha.neg_one_pow]
  have hspos : (0 : ℝ) < silver ^ a := pow_pos silver_pos a
  have hbneg : silverBar ^ a < 0 := by
    refine Odd.pow_neg ha ?_
    simp only [silverBar]
    nlinarith [sqrt_two_bounds.1]
  have hsq : ((traceG a 0 : ℝ)) ^ 2 + 4 = (silver ^ a - silverBar ^ a) ^ 2 := by
    rw [hT]; nlinarith [hprod]
  have hnn : (0 : ℝ) ≤ silver ^ a - silverBar ^ a := by linarith
  simp only [sigmaG, sigmaT]
  rw [hsq, Real.sqrt_sq hnn, hT]
  ring

/-- **The maximal rate `log(1+√2)` of cycle IX is the member `b = 0` of the family.** -/
theorem rateG_top {a : ℕ} (ha : Odd a) : rateG a 0 = Real.log silver := by
  have hapos : 0 < a := ha.pos
  have haR : (0 : ℝ) < (a : ℝ) := by exact_mod_cast hapos
  simp only [rateG, sigmaG_zero ha, Nat.cast_zero, add_zero]
  rw [Real.log_pow]
  field_simp

/-! ## Part N. Crude uniform bounds, monotonicity and the vanishing of the rate -/

theorem pellNum_le_three_pow (n : ℕ) : pellNum n ≤ 3 ^ n := by
  have key : ∀ n, pellNum n ≤ 3 ^ n ∧ pellNum (n + 1) ≤ 3 ^ (n + 1) := by
    intro n
    induction n with
    | zero => exact ⟨by norm_num [pellNum], by norm_num [pellNum]⟩
    | succ n ih =>
        refine ⟨ih.2, ?_⟩
        have hrec : pellNum (n + 2) = 2 * pellNum (n + 1) + pellNum n := rfl
        have h3 : 3 ^ (n + 2) = 3 * 3 ^ (n + 1) := by ring
        have h4 : 3 ^ n ≤ 3 ^ (n + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
        rw [show n + 1 + 1 = n + 2 from rfl, hrec, h3]
        omega
  exact (key n).1

theorem two_mul_add_five_le (b : ℕ) : 2 * b + 5 ≤ 9 * 3 ^ b := by
  induction b with
  | zero => norm_num
  | succ b ih =>
      have h : (3 : ℕ) ^ (b + 1) = 3 * 3 ^ b := by ring
      have hp : 1 ≤ 3 ^ b := Nat.one_le_pow _ _ (by norm_num)
      omega

theorem traceG_succ_le (a b : ℕ) : traceG a b + 1 ≤ 3 ^ (a + b + 2) := by
  have hp : pellNum (a + 1) ≤ 3 ^ (a + 1) := pellNum_le_three_pow (a + 1)
  have hq : pellNum a ≤ 3 ^ a := pellNum_le_three_pow a
  have hs : pellPrev a ≤ 3 ^ a := by
    cases a with
    | zero => simp [pellPrev]
    | succ a =>
        have := pellNum_le_three_pow a
        have h3 : 3 ^ a ≤ 3 ^ (a + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
        simpa [pellPrev] using le_trans this h3
  have h1 : (3 : ℕ) ^ (a + 1) = 3 * 3 ^ a := by ring
  have h2 : (3 : ℕ) ^ (a + b + 2) = 3 ^ a * (9 * 3 ^ b) := by
    rw [show a + b + 2 = a + (b + 2) from by omega, pow_add]
    ring
  have hb := two_mul_add_five_le b
  have hpa : 1 ≤ 3 ^ a := Nat.one_le_pow _ _ (by norm_num)
  have hstep : traceG a b + 1 ≤ 3 ^ a * (2 * b + 5) := by
    simp only [traceG]
    calc pellNum (a + 1) + 2 * b * pellNum a + pellPrev a + 1
        ≤ 3 * 3 ^ a + 2 * b * 3 ^ a + 3 ^ a + 3 ^ a := by
          have : 2 * b * pellNum a ≤ 2 * b * 3 ^ a := Nat.mul_le_mul_left _ hq
          omega
      _ = 3 ^ a * (2 * b + 5) := by ring
  calc traceG a b + 1 ≤ 3 ^ a * (2 * b + 5) := hstep
    _ ≤ 3 ^ a * (9 * 3 ^ b) := Nat.mul_le_mul_left _ hb
    _ = 3 ^ (a + b + 2) := h2.symm

theorem sigmaG_le_three_pow {a : ℕ} (ha : Odd a) (b : ℕ) :
    sigmaG a b ≤ 3 ^ (a + b + 2) := by
  have h1 := sigmaT_lt ((traceG a b : ℝ)) (by linarith [traceG_pos_real ha b])
  have h2 : ((traceG a b : ℝ)) + 1 ≤ (3 : ℝ) ^ (a + b + 2) := by
    have := traceG_succ_le a b
    have hcast : ((traceG a b + 1 : ℕ) : ℝ) ≤ ((3 ^ (a + b + 2) : ℕ) : ℝ) := by
      exact_mod_cast this
    push_cast at hcast
    linarith
  simp only [sigmaG]
  linarith

theorem rateG_pos {a : ℕ} (ha : Odd a) (b : ℕ) : 0 < rateG a b := by
  have hlog := Real.log_pos (one_lt_sigmaG ha b)
  have hapos : (0 : ℝ) < (a : ℝ) := by exact_mod_cast ha.pos
  have hbnn : (0 : ℝ) ≤ (b : ℝ) := Nat.cast_nonneg _
  simp only [rateG]
  positivity

/-- A crude uniform ceiling for all the rates of the family. -/
theorem rateG_le_crude {a : ℕ} (ha : Odd a) (b : ℕ) : rateG a b ≤ 3 * Real.log 3 := by
  have hapos : (1 : ℝ) ≤ (a : ℝ) := by exact_mod_cast ha.pos
  have hbnn : (0 : ℝ) ≤ (b : ℝ) := Nat.cast_nonneg _
  have hspos := sigmaG_pos ha b
  have hle := sigmaG_le_three_pow ha b
  have hlog : Real.log (sigmaG a b) ≤ ((a : ℝ) + (b : ℝ) + 2) * Real.log 3 := by
    have h := Real.log_le_log hspos hle
    rw [Real.log_pow] at h
    push_cast at h
    linarith
  have hl3 : 0 < Real.log 3 := Real.log_pos (by norm_num)
  have hden : (0 : ℝ) < (a : ℝ) + (b : ℝ) := by linarith
  simp only [rateG]
  rw [div_le_iff₀ hden]
  nlinarith

theorem traceG_mono (a b : ℕ) : traceG a b ≤ traceG a (b + 1) := by
  simp only [traceG]
  have : 2 * b * pellNum a ≤ 2 * (b + 1) * pellNum a :=
    Nat.mul_le_mul_right _ (by omega)
  omega

theorem sigmaG_mono (a b : ℕ) : sigmaG a b ≤ sigmaG a (b + 1) := by
  have h : ((traceG a b : ℝ)) ≤ ((traceG a (b + 1) : ℝ)) := by
    exact_mod_cast traceG_mono a b
  exact sigmaT_mono (Nat.cast_nonneg _) h

/-- **The rate changes slowly in `b`**: consecutive rates differ by at most
`3 log 3/(a+b+1)`, uniformly in `b`. -/
theorem rateG_gap {a : ℕ} (ha : Odd a) (b : ℕ) :
    rateG a b - rateG a (b + 1) ≤ 3 * Real.log 3 / ((a : ℝ) + (b : ℝ) + 1) := by
  have hapos : (1 : ℝ) ≤ (a : ℝ) := by exact_mod_cast ha.pos
  have hbnn : (0 : ℝ) ≤ (b : ℝ) := Nat.cast_nonneg _
  have hD : (0 : ℝ) < (a : ℝ) + (b : ℝ) := by linarith
  have hD1 : (0 : ℝ) < (a : ℝ) + (b : ℝ) + 1 := by linarith
  have hL : 0 ≤ Real.log (sigmaG a b) := le_of_lt (Real.log_pos (one_lt_sigmaG ha b))
  have hLmono : Real.log (sigmaG a b) ≤ Real.log (sigmaG a (b + 1)) :=
    Real.log_le_log (sigmaG_pos ha b) (sigmaG_mono a b)
  have hcast : ((a : ℝ) + ((b + 1 : ℕ) : ℝ)) = (a : ℝ) + (b : ℝ) + 1 := by push_cast; ring
  have hstep : rateG a (b + 1) ≥ Real.log (sigmaG a b) / ((a : ℝ) + (b : ℝ) + 1) := by
    simp only [rateG, hcast]
    gcongr
  have hkey : rateG a b - Real.log (sigmaG a b) / ((a : ℝ) + (b : ℝ) + 1)
      = rateG a b / ((a : ℝ) + (b : ℝ) + 1) := by
    simp only [rateG]
    field_simp
    ring
  have hcr : rateG a b ≤ 3 * Real.log 3 := rateG_le_crude ha b
  have : rateG a b - rateG a (b + 1) ≤ rateG a b / ((a : ℝ) + (b : ℝ) + 1) := by
    rw [← hkey]; linarith
  refine le_trans this ?_
  gcongr

/-- **For a fixed odd `a` the rates tend to `0` as the `B₃`-blocks grow.** -/
theorem rateG_tendsto_zero {a : ℕ} (ha : Odd a) :
    Tendsto (fun b : ℕ => rateG a b) atTop (𝓝 0) := by
  have hq : 1 ≤ pellNum a := pellNum_pos a ha.pos
  have hA : (0 : ℝ) < 2 * (pellNum a : ℝ) := by
    have : (1 : ℝ) ≤ (pellNum a : ℝ) := by exact_mod_cast hq
    linarith
  have hB : (0 : ℝ) ≤ (pellNum (a + 1) : ℝ) + (pellPrev a : ℝ) + 1 := by positivity
  have hup := log_affine_div_tendsto_zero (2 * (pellNum a : ℝ))
    ((pellNum (a + 1) : ℝ) + (pellPrev a : ℝ) + 1) hA hB
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hup ?_ ?_
  · filter_upwards with b using le_of_lt (rateG_pos ha b)
  · filter_upwards [eventually_ge_atTop 1] with b hb
    have hbR : (1 : ℝ) ≤ (b : ℝ) := by exact_mod_cast hb
    have hapos : (1 : ℝ) ≤ (a : ℝ) := by exact_mod_cast ha.pos
    have hspos := sigmaG_pos ha b
    have hlt := sigmaT_lt ((traceG a b : ℝ)) (by linarith [traceG_pos_real ha b])
    have haff : sigmaG a b ≤ 2 * (pellNum a : ℝ) * (b : ℝ)
        + ((pellNum (a + 1) : ℝ) + (pellPrev a : ℝ) + 1) := by
      have hT : ((traceG a b : ℝ))
          = (pellNum (a + 1) : ℝ) + 2 * (b : ℝ) * (pellNum a : ℝ) + (pellPrev a : ℝ) := by
        simp only [traceG]; push_cast; ring
      have hlt' : sigmaG a b < (traceG a b : ℝ) + 1 := hlt
      rw [hT] at hlt'
      linarith
    have hlog : Real.log (sigmaG a b)
        ≤ Real.log (2 * (pellNum a : ℝ) * (b : ℝ)
            + ((pellNum (a + 1) : ℝ) + (pellPrev a : ℝ) + 1)) :=
      Real.log_le_log hspos haff
    have hLnn : 0 ≤ Real.log (sigmaG a b) := le_of_lt (Real.log_pos (one_lt_sigmaG ha b))
    have hden : (0 : ℝ) < (b : ℝ) := by linarith
    have hden2 : (b : ℝ) ≤ (a : ℝ) + (b : ℝ) := by linarith
    calc rateG a b = Real.log (sigmaG a b) / ((a : ℝ) + (b : ℝ)) := rfl
      _ ≤ Real.log (sigmaG a b) / (b : ℝ) := by
          gcongr
      _ ≤ _ := by
          gcongr

/-! ## Part O. The growth spectrum is dense in `[0, log(1+√2)]` -/

/-- **Main theorem of cycle XI.**  Every value `r` of the interval `[0, log(1+√2)]` is
approximated, to within any prescribed `ε > 0`, by the *exact* metric growth rate of an
explicit `B₁`-free periodic Berggren path `(B₂^a B₃^b)^∞` with `a` odd.  Together with the
upper envelope `d ≤ (k+1) log(1+√2) + log 2` of cycle IX (which caps every rate by
`log(1+√2)`), the closure of the metric growth spectrum of the Berggren tree is exactly
`[0, log(1+√2)]`.

The proof is a discrete intermediate-value argument: at `b = 0` the rate is exactly
`log(1+√2)` (`rateG_top`), for fixed `a` the rates tend to `0` (`rateG_tendsto_zero`), and
consecutive rates differ by at most `3 log 3/(a+b+1)` (`rateG_gap`), which is `< ε` once `a`
is large. -/
theorem berggren_spectrum_dense {r eps : ℝ} (hr0 : 0 ≤ r) (hrtop : r ≤ Real.log silver)
    (heps : 0 < eps) :
    ∃ a b : ℕ, Odd a ∧ (∀ j : ℕ, Move.L ∉ wordG a b j) ∧
      Tendsto (fun j : ℕ => wdist (wordG a b j) / (wordG a b j).length) atTop
        (𝓝 (rateG a b)) ∧ |rateG a b - r| < eps := by
  classical
  obtain ⟨K, hK⟩ := exists_nat_gt (3 * Real.log 3 / eps)
  refine ⟨2 * K + 1, ?_⟩
  set a : ℕ := 2 * K + 1 with hadef
  have ha : Odd a := ⟨K, by omega⟩
  have haR : (K : ℝ) ≤ (a : ℝ) := by
    have : K ≤ a := by omega
    exact_mod_cast this
  -- the gap between consecutive rates is smaller than `eps`
  have hgap : ∀ b : ℕ, 3 * Real.log 3 / ((a : ℝ) + (b : ℝ) + 1) < eps := by
    intro b
    have hbnn : (0 : ℝ) ≤ (b : ℝ) := Nat.cast_nonneg _
    have hpos : (0 : ℝ) < (a : ℝ) + (b : ℝ) + 1 := by
      have : (0 : ℝ) ≤ (a : ℝ) := Nat.cast_nonneg _
      linarith
    rw [div_lt_iff₀ hpos]
    have hK' : 3 * Real.log 3 / eps < (a : ℝ) + (b : ℝ) + 1 := by linarith
    rw [div_lt_iff₀ heps] at hK'
    linarith
  by_cases hex : ∃ b : ℕ, rateG a b < r
  · -- discrete intermediate value: take the first `b` whose rate drops below `r`
    have hb0 : rateG a (Nat.find hex) < r := Nat.find_spec hex
    have hne : Nat.find hex ≠ 0 := by
      intro h0
      rw [h0, rateG_top ha] at hb0
      linarith
    obtain ⟨c, hc⟩ : ∃ c, Nat.find hex = c + 1 := ⟨Nat.find hex - 1, by omega⟩
    have hcge : r ≤ rateG a c := by
      by_contra hlt
      push_neg at hlt
      have : Nat.find hex ≤ c := Nat.find_le hlt
      omega
    have hgapc := rateG_gap ha c
    have hlow : r - eps < rateG a (c + 1) := by
      have := hgap c
      linarith
    refine ⟨c + 1, ha, fun j => wordG_no_L a (c + 1) j, wordG_rate_tendsto ha (c + 1), ?_⟩
    rw [abs_lt]
    constructor
    · linarith
    · have : rateG a (c + 1) < r := by rw [← hc]; exact hb0
      linarith
  · -- no rate drops below `r`, so `r = 0` and any small rate will do
    push_neg at hex
    have hr_le : r ≤ 0 :=
      ge_of_tendsto (rateG_tendsto_zero ha) (Filter.Eventually.of_forall hex)
    have hr : r = 0 := le_antisymm hr_le hr0
    obtain ⟨b, hb⟩ :=
      (Filter.Tendsto.eventually_lt_const heps (rateG_tendsto_zero ha)).exists
    refine ⟨b, ha, fun j => wordG_no_L a b j, wordG_rate_tendsto ha b, ?_⟩
    rw [hr, sub_zero, abs_of_pos (rateG_pos ha b)]
    exact hb

/-- **No rate exceeds `log(1+√2)`.**  If the lengths of a family of words tend to infinity
and the distance-to-length ratios converge, the limit is at most `log(1+√2)`; this is the
upper envelope of cycle IX in rate form. -/
theorem rate_limit_le_silver {w : ℕ → List Move} {R : ℝ}
    (hlen : Tendsto (fun j : ℕ => (((w j).length : ℝ))) atTop atTop)
    (h : Tendsto (fun j : ℕ => wdist (w j) / (w j).length) atTop (𝓝 R)) :
    R ≤ Real.log silver := by
  have hzero : Tendsto
      (fun j : ℕ => (Real.log silver + Real.log 2) / (((w j).length : ℝ))) atTop (𝓝 0) :=
    Filter.Tendsto.div_atTop tendsto_const_nhds hlen
  have hlim : Tendsto
      (fun j : ℕ => Real.log silver + (Real.log silver + Real.log 2) / (((w j).length : ℝ)))
      atTop (𝓝 (Real.log silver)) := by
    simpa using (tendsto_const_nhds (x := Real.log silver) (f := atTop (α := ℕ))).add hzero
  refine le_of_tendsto_of_tendsto h hlim ?_
  have hev : ∀ᶠ j : ℕ in atTop, (1 : ℝ) ≤ (((w j).length : ℝ)) :=
    hlen.eventually_ge_atTop 1
  filter_upwards [hev] with j hj
  have hpos : (0 : ℝ) < (((w j).length : ℝ)) := by linarith
  have hup := (berggren_word_two_sided_sharp (w j)).2
  rw [div_le_iff₀ hpos]
  have hid : (Real.log silver + (Real.log silver + Real.log 2) / (((w j).length : ℝ)))
      * (((w j).length : ℝ))
      = ((((w j).length : ℝ)) + 1) * Real.log silver + Real.log 2 := by
    field_simp
    ring
  rw [hid]
  exact hup

/-- **The spectrum, packaged.**  Every realised rate lies in `[0, log(1+√2)]`, the maximum
`log(1+√2)` is realised by a member of the family, and the realised rates are dense in the
whole interval; the middle-move frequency of the approximating path `(B₂^a B₃^b)^∞` is
`a/(a+b)`.  Hence the closure of the metric growth spectrum of the Berggren tree is exactly
`[0, log(1+√2)]`. -/
theorem berggren_spectrum_closure :
    (∀ a b : ℕ, Odd a → 0 < rateG a b ∧ rateG a b ≤ Real.log silver) ∧
      (∀ a : ℕ, Odd a → rateG a 0 = Real.log silver) ∧
      (∀ a b j : ℕ, (a + b) * countM (wordG a b j) = a * (wordG a b j).length) ∧
      ∀ r eps : ℝ, 0 ≤ r → r ≤ Real.log silver → 0 < eps →
        ∃ a b : ℕ, Odd a ∧ (∀ j : ℕ, Move.L ∉ wordG a b j) ∧
          Tendsto (fun j : ℕ => wdist (wordG a b j) / (wordG a b j).length) atTop
            (𝓝 (rateG a b)) ∧ |rateG a b - r| < eps := by
  refine ⟨fun a b ha => ⟨rateG_pos ha b, ?_⟩, fun _ ha => rateG_top ha,
    fun a b j => by rw [wordG_countM, wordG_length]; ring,
    fun _ _ hr0 hrtop heps => berggren_spectrum_dense hr0 hrtop heps⟩
  have hab : 0 < a + b := by have := ha.pos; omega
  have habR : (0 : ℝ) < ((a + b : ℕ) : ℝ) := by exact_mod_cast hab
  have hlen : Tendsto (fun j : ℕ => (((wordG a b j).length : ℝ))) atTop atTop := by
    have : ∀ j : ℕ, (((wordG a b j).length : ℝ)) = ((a + b : ℕ) : ℝ) * (j : ℝ) := by
      intro j; rw [wordG_length]; push_cast; ring
    simp only [this]
    exact tendsto_natCast_atTop_atTop.const_mul_atTop habR
  exact rate_limit_le_silver hlen (wordG_rate_tendsto ha b)

end

end HyperbolicBerggrenGeodesics