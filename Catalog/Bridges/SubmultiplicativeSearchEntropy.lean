import Mathlib

/-! # Submultiplicative search entropy and the Perron root

A bridge between three areas:

* **Combinatorics of proof search** — counting the successful prefixes of a search language;
* **Real analysis (Fekete's subadditive lemma)** — existence of the normalized logarithmic
  growth rate and its identification with the infimum of the finite-scale rates;
* **Linear algebra of nonnegative matrices (Perron theory)** — the growth rate of a
  finite-state pruned search equals `log ρ`, where `ρ` is the Perron eigenvalue of the
  automaton's transition matrix.
-/

open Filter Topology Set

namespace SubmultiplicativeSearchEntropy

/-! ## Part 1 — Submultiplicative counting functions and Fekete's lemma -/

/-- A *search profile* is a counting function `N : ℕ → ℝ` for the successful prefixes of each
length. It is submultiplicative and everywhere at least `1`. -/
structure SearchProfile where
  /-- number of successful prefixes of length `n` -/
  N : ℕ → ℝ
  one_le : ∀ n, 1 ≤ N n
  submul : ∀ m n, N (m + n) ≤ N m * N n

namespace SearchProfile

variable (P : SearchProfile)

lemma pos (n : ℕ) : 0 < P.N n := lt_of_lt_of_le zero_lt_one (P.one_le n)

/-- The finite-scale rate at length `n`: `log N n / n`. -/
noncomputable def rate (n : ℕ) : ℝ := Real.log (P.N n) / n

lemma rate_nonneg (n : ℕ) : 0 ≤ P.rate n :=
  div_nonneg (Real.log_nonneg (P.one_le n)) (Nat.cast_nonneg n)

/-- The logarithm of a submultiplicative profile is subadditive. -/
lemma subadditive_log : Subadditive (fun n => Real.log (P.N n)) := by
  intro m n
  have h1 : Real.log (P.N (m + n)) ≤ Real.log (P.N m * P.N n) :=
    Real.log_le_log (P.pos _) (P.submul m n)
  rwa [Real.log_mul (P.pos m).ne' (P.pos n).ne'] at h1

lemma bddBelow_rate : BddBelow (range fun n => Real.log (P.N n) / n) := by
  refine ⟨0, ?_⟩
  rintro x ⟨n, rfl⟩
  exact P.rate_nonneg n

/-- The **entropy (growth) rate** of a search profile: the infimum of its finite-scale rates. -/
noncomputable def growthRate : ℝ := sInf (P.rate '' Ici 1)

lemma growthRate_eq_lim : P.growthRate = P.subadditive_log.lim := by
  rw [Subadditive.lim]; rfl

/-- The growth rate is a lower bound for every finite-scale rate (`n ≥ 1`). -/
theorem growthRate_le_rate {n : ℕ} (hn : n ≠ 0) : P.growthRate ≤ P.rate n := by
  rw [P.growthRate_eq_lim]
  exact P.subadditive_log.lim_le_div P.bddBelow_rate hn

/-- **Fekete's lemma for search profiles.** The normalized logarithmic growth rate exists
and equals the infimum of the finite-scale rates. -/
theorem tendsto_growthRate :
    Tendsto P.rate atTop (𝓝 P.growthRate) := by
  rw [P.growthRate_eq_lim]
  exact P.subadditive_log.tendsto_lim P.bddBelow_rate

/-- The growth rate is the greatest lower bound of the finite-scale rates. -/
theorem isGLB_growthRate : IsGLB (P.rate '' Ici 1) P.growthRate := by
  refine isGLB_csInf ⟨P.rate 1, ⟨1, mem_Ici.2 le_rfl, rfl⟩⟩ ?_
  exact ⟨0, by rintro x ⟨n, -, rfl⟩; exact P.rate_nonneg n⟩

theorem growthRate_nonneg : 0 ≤ P.growthRate := by
  refine le_csInf ⟨P.rate 1, ⟨1, mem_Ici.2 le_rfl, rfl⟩⟩ ?_
  rintro x ⟨n, -, rfl⟩
  exact P.rate_nonneg n

/-- If the search space is finitely branching with branching factor `b`, i.e. `N n ≤ b ^ n`,
then the growth rate is at most `log b`. -/
theorem growthRate_le_log_of_le_pow {b : ℝ} (h : ∀ n, P.N n ≤ b ^ n) :
    P.growthRate ≤ Real.log b := by
  have h1 : P.rate 1 ≤ Real.log b := by
    have := h 1
    simp only [pow_one] at this
    have : Real.log (P.N 1) ≤ Real.log b := Real.log_le_log (P.pos 1) this
    simpa [rate] using this
  exact (P.growthRate_le_rate one_ne_zero).trans h1

/-- The **proof-search dimension** of a profile relative to an ambient branching factor `b`:
the growth rate normalized by `log b`. -/
noncomputable def searchDim (b : ℝ) : ℝ := P.growthRate / Real.log b

theorem searchDim_nonneg {b : ℝ} (hb : 1 ≤ b) : 0 ≤ P.searchDim b :=
  div_nonneg P.growthRate_nonneg (Real.log_nonneg hb)

/-- In a finitely branching space the dimension is at most one. -/
theorem searchDim_le_one {b : ℝ} (hb : 1 < b) (h : ∀ n, P.N n ≤ b ^ n) :
    P.searchDim b ≤ 1 := by
  have hlog : 0 < Real.log b := Real.log_pos hb
  rw [searchDim, div_le_one hlog]
  exact P.growthRate_le_log_of_le_pow h

end SearchProfile

/-! ## Part 2 — Nonnegative matrices: path counts of a finite-state pruning automaton -/

section Matrices

variable {k : ℕ} {A : Matrix (Fin k) (Fin k) ℝ}

/-- Entrywise nonnegativity is preserved by matrix powers. -/
lemma pow_entry_nonneg (hA : ∀ i j, 0 ≤ A i j) : ∀ (n : ℕ) (i j), 0 ≤ (A ^ n) i j := by
  intro n
  induction n with
  | zero => intro i j; by_cases h : i = j <;> simp [h]
  | succ n ih =>
      intro i j
      rw [pow_succ, Matrix.mul_apply]
      exact Finset.sum_nonneg fun l _ => mul_nonneg (ih i l) (hA l j)

/-- The number of length-`n` paths of the automaton with transition matrix `A`:
the sum of all entries of `A ^ n`. -/
def pathCount (A : Matrix (Fin k) (Fin k) ℝ) (n : ℕ) : ℝ := ∑ i, ∑ j, (A ^ n) i j

lemma pathCount_nonneg (hA : ∀ i j, 0 ≤ A i j) (n : ℕ) : 0 ≤ pathCount A n :=
  Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => pow_entry_nonneg hA n _ _

/-- **Submultiplicativity of path counts.** For a nonnegative matrix, the total number of
length-`(m+n)` paths is at most the product of the counts at lengths `m` and `n`. -/
theorem pathCount_submul (hA : ∀ i j, 0 ≤ A i j) (m n : ℕ) :
    pathCount A (m + n) ≤ pathCount A m * pathCount A n := by
  set f : Fin k → ℝ := fun l => ∑ i, (A ^ m) i l with hf
  set g : Fin k → ℝ := fun l => ∑ j, (A ^ n) l j with hg
  have hfnn : ∀ l, 0 ≤ f l := fun l =>
    Finset.sum_nonneg fun _ _ => pow_entry_nonneg hA m _ _
  have hgnn : ∀ l, 0 ≤ g l := fun l =>
    Finset.sum_nonneg fun _ _ => pow_entry_nonneg hA n _ _
  have key : pathCount A (m + n) = ∑ l, f l * g l := by
    unfold pathCount
    rw [pow_add]
    simp only [Matrix.mul_apply]
    calc ∑ i, ∑ j, ∑ l, (A ^ m) i l * (A ^ n) l j
        = ∑ i, ∑ l, ∑ j, (A ^ m) i l * (A ^ n) l j :=
          Finset.sum_congr rfl fun i _ => Finset.sum_comm
      _ = ∑ l, ∑ i, ∑ j, (A ^ m) i l * (A ^ n) l j := Finset.sum_comm
      _ = ∑ l, f l * g l := by
          refine Finset.sum_congr rfl fun l _ => ?_
          rw [hf, hg, Finset.sum_mul]
          exact Finset.sum_congr rfl fun i _ => (Finset.mul_sum _ _ _).symm
  have hm : pathCount A m = ∑ l, f l := Finset.sum_comm
  have hn : pathCount A n = ∑ l, g l := rfl
  rw [key, hm, hn, Finset.sum_mul]
  refine Finset.sum_le_sum fun l _ => ?_
  exact mul_le_mul_of_nonneg_left (Finset.single_le_sum (fun i _ => hgnn i)
    (Finset.mem_univ l)) (hfnn l)

/-! ### Perron eigenvectors control path counts -/

variable {r : ℝ}

/-- If `v` is an eigenvector of `A` for the eigenvalue `r`, it is an eigenvector of `A ^ n`
for `r ^ n`. -/
lemma mulVec_pow_of_eigen {v : Fin k → ℝ} (hv : A.mulVec v = r • v) :
    ∀ n, (A ^ n).mulVec v = (r ^ n) • v := by
  intro n
  induction n with
  | zero => simp
  | succ n ih =>
      rw [pow_succ, ← Matrix.mulVec_mulVec, hv, Matrix.mulVec_smul, ih, smul_smul, pow_succ,
        mul_comm]

/-- **Two-sided Perron estimate for path counts.** If `A` is nonnegative and has an eigenvector
`v` with `0 < c ≤ v i ≤ C` for the eigenvalue `r`, then the total number of length-`n` paths is
comparable to `r ^ n`, with constants depending only on `v`. -/
theorem pathCount_eigen_bounds (hA : ∀ i j, 0 ≤ A i j) {v : Fin k → ℝ} {c C : ℝ}
    (hcv : ∀ i, c ≤ v i) (hvC : ∀ i, v i ≤ C) (hv : A.mulVec v = r • v) (n : ℕ) :
    c * pathCount A n ≤ r ^ n * (∑ i, v i) ∧ r ^ n * (∑ i, v i) ≤ C * pathCount A n := by
  have hrow : ∀ i, ∑ j, (A ^ n) i j * v j = r ^ n * v i := by
    intro i
    have := congrFun (mulVec_pow_of_eigen (A := A) (r := r) hv n) i
    simpa [Matrix.mulVec, dotProduct] using this
  have hnn : ∀ i j, 0 ≤ (A ^ n) i j := pow_entry_nonneg hA n
  constructor
  · have h1 : ∀ i, c * (∑ j, (A ^ n) i j) ≤ r ^ n * v i := by
      intro i
      rw [← hrow i, Finset.mul_sum]
      exact Finset.sum_le_sum fun j _ => by
        rw [mul_comm]
        exact mul_le_mul_of_nonneg_left (hcv j) (hnn i j)
    calc c * pathCount A n = ∑ i, c * (∑ j, (A ^ n) i j) := by
            rw [pathCount, Finset.mul_sum]
      _ ≤ ∑ i, r ^ n * v i := Finset.sum_le_sum fun i _ => h1 i
      _ = r ^ n * (∑ i, v i) := by rw [Finset.mul_sum]
  · have h2 : ∀ i, r ^ n * v i ≤ C * (∑ j, (A ^ n) i j) := by
      intro i
      rw [← hrow i, Finset.mul_sum]
      exact Finset.sum_le_sum fun j _ => by
        rw [mul_comm]
        exact mul_le_mul_of_nonneg_right (hvC j) (hnn i j)
    calc r ^ n * (∑ i, v i) = ∑ i, r ^ n * v i := by rw [Finset.mul_sum]
      _ ≤ ∑ i, C * (∑ j, (A ^ n) i j) := Finset.sum_le_sum fun i _ => h2 i
      _ = C * pathCount A n := by rw [pathCount, Finset.mul_sum]

end Matrices

/-! ## Part 3 — The growth rate of a Perron-controlled search equals `log r` -/

/-- Auxiliary limit: `log (c * r ^ n) / n → log r`. -/
lemma tendsto_log_const_mul_pow_div {c r : ℝ} (hc : 0 < c) (hr : 0 < r) :
    Tendsto (fun n : ℕ => Real.log (c * r ^ n) / n) atTop (𝓝 (Real.log r)) := by
  have hlim : Tendsto (fun n : ℕ => Real.log c / n + Real.log r) atTop
      (𝓝 (0 + Real.log r)) :=
    (tendsto_const_div_atTop_nhds_zero_nat _).add tendsto_const_nhds
  rw [zero_add] at hlim
  refine hlim.congr' ?_
  filter_upwards [eventually_ne_atTop 0] with n hn
  have hn' : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hn
  rw [Real.log_mul hc.ne' (by positivity), Real.log_pow]
  field_simp

/-- **Squeeze lemma.** A positive sequence trapped between two constant multiples of `r ^ n`
has normalized logarithmic growth rate exactly `log r`. -/
lemma tendsto_log_div_of_comparable {N : ℕ → ℝ} {c C r : ℝ} (hc : 0 < c) (hC : 0 < C)
    (hr : 0 < r) (hlow : ∀ n, c * r ^ n ≤ N n) (hhigh : ∀ n, N n ≤ C * r ^ n) :
    Tendsto (fun n : ℕ => Real.log (N n) / n) atTop (𝓝 (Real.log r)) := by
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le
    (tendsto_log_const_mul_pow_div hc hr) (tendsto_log_const_mul_pow_div hC hr)
    (fun n => ?_) (fun n => ?_)
  · have hpos : 0 < c * r ^ n := by positivity
    have := Real.log_le_log hpos (hlow n)
    gcongr
  · have hpos : 0 < N n := lt_of_lt_of_le (by positivity) (hlow n)
    have := Real.log_le_log hpos (hhigh n)
    gcongr

/-! ## Part 4 — The bridge theorem: Perron root = entropy = dimension -/

section Bridge

variable {k : ℕ} {A : Matrix (Fin k) (Fin k) ℝ} {r : ℝ}

/-- **Bridge theorem (linear algebra ↔ search entropy).**  For a nonnegative transition matrix
admitting a strictly positive eigenvector for the eigenvalue `r > 0` (the Perron situation of a
strongly connected pruning automaton), the normalized logarithmic growth rate of the number of
length-`n` accepted paths exists and equals `log r`. -/
theorem tendsto_pathCount_rate (hk : 0 < k) (hA : ∀ i j, 0 ≤ A i j) {v : Fin k → ℝ} {c C : ℝ}
    (hc : 0 < c) (hcv : ∀ i, c ≤ v i) (hvC : ∀ i, v i ≤ C) (hv : A.mulVec v = r • v)
    (hr : 0 < r) :
    Tendsto (fun n : ℕ => Real.log (pathCount A n) / n) atTop (𝓝 (Real.log r)) := by
  have hkne : Nonempty (Fin k) := ⟨⟨0, hk⟩⟩
  obtain ⟨i0⟩ := hkne
  have hC : 0 < C := lt_of_lt_of_le hc ((hcv i0).trans (hvC i0))
  have hS : 0 < ∑ i, v i :=
    Finset.sum_pos (fun i _ => lt_of_lt_of_le hc (hcv i)) ⟨i0, Finset.mem_univ i0⟩
  have hbounds := fun n => pathCount_eigen_bounds (A := A) (r := r) hA hcv hvC hv n
  refine tendsto_log_div_of_comparable (c := (∑ i, v i) / C) (C := (∑ i, v i) / c)
    (by positivity) (by positivity) hr (fun n => ?_) (fun n => ?_)
  · rw [div_mul_eq_mul_div, div_le_iff₀ hC, mul_comm (∑ i, v i) (r ^ n)]
    exact (hbounds n).2.trans_eq (mul_comm _ _)
  · rw [div_mul_eq_mul_div, le_div_iff₀ hc, mul_comm (∑ i, v i) (r ^ n), mul_comm (pathCount A n) c]
    exact (hbounds n).1

/-- **Dimension form of the bridge.**  Relative to an ambient `b`-ary search tree (`b > 1`), the
proof-search dimension of a Perron-controlled pruning automaton is `log r / log b`. -/
theorem tendsto_pathCount_dim (hk : 0 < k) (hA : ∀ i j, 0 ≤ A i j) {v : Fin k → ℝ} {c C b : ℝ}
    (hc : 0 < c) (hcv : ∀ i, c ≤ v i) (hvC : ∀ i, v i ≤ C) (hv : A.mulVec v = r • v)
    (hr : 0 < r) (hb : 1 < b) :
    Tendsto (fun n : ℕ => Real.log (pathCount A n) / (n * Real.log b)) atTop
      (𝓝 (Real.log r / Real.log b)) := by
  have hlog : Real.log b ≠ 0 := (Real.log_pos hb).ne'
  have := (tendsto_pathCount_rate hk hA hc hcv hvC hv hr).div_const (Real.log b)
  refine this.congr fun n => ?_
  rw [div_div]

/-- The search profile attached to a pruning automaton whose path counts never vanish. -/
noncomputable def automatonProfile (A : Matrix (Fin k) (Fin k) ℝ) (hA : ∀ i j, 0 ≤ A i j)
    (h1 : ∀ n, 1 ≤ pathCount A n) : SearchProfile where
  N := pathCount A
  one_le := h1
  submul := pathCount_submul hA

/-- **Fekete meets Perron.**  For such an automaton, the Fekete growth rate (the infimum of the
finite-scale rates) is exactly `log r`. -/
theorem automatonProfile_growthRate (hk : 0 < k) (hA : ∀ i j, 0 ≤ A i j)
    (h1 : ∀ n, 1 ≤ pathCount A n) {v : Fin k → ℝ} {c C : ℝ}
    (hc : 0 < c) (hcv : ∀ i, c ≤ v i) (hvC : ∀ i, v i ≤ C) (hv : A.mulVec v = r • v)
    (hr : 0 < r) :
    (automatonProfile A hA h1).growthRate = Real.log r :=
  tendsto_nhds_unique (automatonProfile A hA h1).tendsto_growthRate
    (tendsto_pathCount_rate hk hA hc hcv hvC hv hr)

/-- **Dimension of a Perron-controlled automaton**, in terms of the `searchDim` of its profile:
relative to an ambient `b`-ary tree it is `log r / log b`. -/
theorem automatonProfile_searchDim (hk : 0 < k) (hA : ∀ i j, 0 ≤ A i j)
    (h1 : ∀ n, 1 ≤ pathCount A n) {v : Fin k → ℝ} {c C b : ℝ}
    (hc : 0 < c) (hcv : ∀ i, c ≤ v i) (hvC : ∀ i, v i ≤ C) (hv : A.mulVec v = r • v)
    (hr : 0 < r) :
    (automatonProfile A hA h1).searchDim b = Real.log r / Real.log b := by
  rw [SearchProfile.searchDim, automatonProfile_growthRate hk hA h1 hc hcv hvC hv hr]

/-- **Perron root is dominated by every finite path count.**  A purely linear-algebraic
consequence of the entropy picture: submultiplicativity of path counts plus Fekete's lemma force
`r ^ n ≤ ∑ᵢⱼ (A ^ n)ᵢⱼ` for *every* `n`, for a nonnegative matrix with a positive eigenvector. -/
theorem pow_le_pathCount (hk : 0 < k) (hA : ∀ i j, 0 ≤ A i j)
    (h1 : ∀ n, 1 ≤ pathCount A n) {v : Fin k → ℝ} {c C : ℝ}
    (hc : 0 < c) (hcv : ∀ i, c ≤ v i) (hvC : ∀ i, v i ≤ C) (hv : A.mulVec v = r • v)
    (hr : 0 < r) (n : ℕ) :
    r ^ n ≤ pathCount A n := by
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simpa using h1 0
  have hkey : Real.log r ≤ Real.log (pathCount A n) / n := by
    have h := (automatonProfile A hA h1).growthRate_le_rate (n := n) hn.ne'
    rwa [automatonProfile_growthRate hk hA h1 hc hcv hvC hv hr, SearchProfile.rate] at h
  have hn' : (0 : ℝ) < n := by exact_mod_cast hn
  have : Real.log (r ^ n) ≤ Real.log (pathCount A n) := by
    rw [Real.log_pow]
    rw [le_div_iff₀ hn'] at hkey
    linarith [hkey]
  have hpow : (0 : ℝ) < r ^ n := by positivity
  have hQ : (0 : ℝ) < pathCount A n := lt_of_lt_of_le zero_lt_one (h1 n)
  exact (Real.log_le_log_iff hpow hQ).mp this

end Bridge

/-! ## Part 5 — Worked instances

### 5a. Uniform self-similar search: the classical similarity dimension

A `1 × 1` transition matrix `!![s]` models a uniformly self-similar problem in which exactly `s`
of the branches at each node extend to a proof; the bridge recovers the classical similarity
dimension `log s / log b` of the earlier scalar theory. -/

section Uniform

variable {s : ℝ}

lemma pathCount_scalar (s : ℝ) (n : ℕ) : pathCount (!![s]) n = s ^ n := by
  have h : ∀ n : ℕ, (!![s]) ^ n = !![s ^ n] := by
    intro n
    induction n with
    | zero => ext i j; fin_cases i; fin_cases j; simp
    | succ n ih =>
        ext i j; fin_cases i; fin_cases j
        rw [pow_succ, ih]
        simp [Matrix.mul_apply, pow_succ]
  simp [pathCount, h n]

/-- **Recovering the similarity dimension.**  For the uniform `s`-successful branching profile
inside a `b`-ary search tree, the proof-search dimension is `log s / log b`. -/
theorem uniform_searchDim (hs : 0 < s) {b : ℝ} (hb : 1 < b) :
    Tendsto (fun n : ℕ => Real.log (pathCount (!![s]) n) / (n * Real.log b)) atTop
      (𝓝 (Real.log s / Real.log b)) := by
  refine tendsto_pathCount_dim (k := 1) (A := !![s]) (r := s) (v := fun _ => 1) (c := 1) (C := 1)
    Nat.one_pos ?_ one_pos (fun _ => le_rfl) (fun _ => le_rfl) ?_ hs hb
  · intro i j; fin_cases i; fin_cases j; simpa using hs.le
  · funext i; fin_cases i; simp [Matrix.mulVec, dotProduct]

end Uniform

/-! ### 5b. The Fibonacci pruning automaton and the golden ratio

Inside the binary search tree, prune every branch that would use two "expensive" inference steps
in a row.  The accepted paths are counted by the transition matrix `!![1,1;1,0]`, whose path
counts are Fibonacci numbers and whose Perron root is the golden ratio; the resulting
proof-search dimension is `log φ / log 2 ≈ 0.6942`. -/

section Fibonacci

/-- Transition matrix of the "no two consecutive marked steps" pruning automaton. -/
def fibMatrix : Matrix (Fin 2) (Fin 2) ℝ := !![1, 1; 1, 0]

lemma fibMatrix_nonneg : ∀ i j, 0 ≤ fibMatrix i j := by
  intro i j; fin_cases i <;> fin_cases j <;> simp [fibMatrix]

lemma fibMatrix_sq : fibMatrix ^ 2 = fibMatrix + 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [fibMatrix, pow_two, Matrix.mul_apply, Fin.sum_univ_succ]

/-- The golden ratio is a Perron eigenvalue of the Fibonacci automaton, with the strictly
positive eigenvector `(φ, 1)`. -/
lemma fibMatrix_mulVec_gold :
    fibMatrix.mulVec ![Real.goldenRatio, 1] = Real.goldenRatio • ![Real.goldenRatio, 1] := by
  funext i
  fin_cases i
  · simp only [fibMatrix, Matrix.mulVec, dotProduct, Fin.sum_univ_succ]
    simp
    nlinarith [Real.goldenRatio_sq]
  · simp [fibMatrix, Matrix.mulVec, dotProduct, Fin.sum_univ_succ]

/-- Path counts of the Fibonacci automaton satisfy the Fibonacci recursion. -/
lemma pathCount_fib_rec (n : ℕ) :
    pathCount fibMatrix (n + 2) = pathCount fibMatrix (n + 1) + pathCount fibMatrix n := by
  have hmat : fibMatrix ^ (n + 2) = fibMatrix ^ (n + 1) + fibMatrix ^ n := by
    have : fibMatrix ^ (n + 2) = fibMatrix ^ n * fibMatrix ^ 2 := by rw [pow_add]
    rw [this, fibMatrix_sq, mul_add, mul_one, ← pow_succ]
  simp only [pathCount, hmat, Matrix.add_apply]
  rw [← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl fun i _ => Finset.sum_add_distrib

/-- **The path counts are Fibonacci numbers**: `∑ᵢⱼ (Aⁿ)ᵢⱼ = Fₙ₊₃` (OEIS A000045). -/
theorem pathCount_fibMatrix (n : ℕ) : pathCount fibMatrix n = (Nat.fib (n + 3) : ℝ) := by
  induction n using Nat.twoStepInduction with
  | zero => simp [pathCount, Matrix.one_apply]; norm_num
  | one =>
      simp [pathCount, fibMatrix, Fin.sum_univ_succ]
      norm_num
  | more n ih1 ih2 =>
      rw [pathCount_fib_rec n, ih1, ih2]
      have hf : Nat.fib (n + 2 + 3) = Nat.fib (n + 1 + 3) + Nat.fib (n + 3) := by
        have e1 : n + 2 + 3 = (n + 3) + 2 := by ring
        have e2 : n + 1 + 3 = (n + 3) + 1 := by ring
        rw [e1, e2, Nat.fib_add_two]
        omega
      rw [hf]
      push_cast
      ring

/-- **Golden-ratio proof-search dimension.**  The Fibonacci-pruned binary search space has
proof-search dimension `log φ / log 2`. -/
theorem fibMatrix_searchDim :
    Tendsto (fun n : ℕ => Real.log (pathCount fibMatrix n) / (n * Real.log 2)) atTop
      (𝓝 (Real.log Real.goldenRatio / Real.log 2)) := by
  refine tendsto_pathCount_dim (k := 2) (A := fibMatrix) (r := Real.goldenRatio)
    (v := ![Real.goldenRatio, 1]) (c := 1) (C := Real.goldenRatio) (by norm_num) fibMatrix_nonneg
    one_pos ?_ ?_ fibMatrix_mulVec_gold Real.goldenRatio_pos (by norm_num)
  · intro i; fin_cases i <;> simp [Real.one_lt_goldenRatio.le]
  · intro i; fin_cases i <;> simp [Real.one_lt_goldenRatio.le]

/-- The Fibonacci path counts dominate all powers of the golden ratio:
`φ ^ n ≤ Fₙ₊₃`, obtained here from Fekete's lemma applied to the automaton. -/
theorem gold_pow_le_fib (n : ℕ) : Real.goldenRatio ^ n ≤ (Nat.fib (n + 3) : ℝ) := by
  have h1 : ∀ m, (1 : ℝ) ≤ pathCount fibMatrix m := by
    intro m
    rw [pathCount_fibMatrix m]
    have : 1 ≤ Nat.fib (m + 3) := Nat.fib_pos.2 (by omega)
    exact_mod_cast this
  have := pow_le_pathCount (k := 2) (A := fibMatrix) (r := Real.goldenRatio)
    (v := ![Real.goldenRatio, 1]) (c := 1) (C := Real.goldenRatio)
    (by norm_num) fibMatrix_nonneg h1 one_pos
    (by intro i; fin_cases i <;> simp [Real.one_lt_goldenRatio.le])
    (by intro i; fin_cases i <;> simp [Real.one_lt_goldenRatio.le])
    fibMatrix_mulVec_gold Real.goldenRatio_pos n
  rwa [pathCount_fibMatrix n] at this

end Fibonacci

end SubmultiplicativeSearchEntropy