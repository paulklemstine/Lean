/-
# Uniform boundedness of normalised tropical powers

`FUTURE_DIRECTIONS.md` (sub-conjecture 1, extracted from conjecture C1 on cyclicity)
proposed that *every* entry of `A^{⊗(m+1)} − (m+1)·λ` lies in the box `[−C, C]` with
`C = spread(v)` the spread of a tropical eigenvector.  This file settles that
sub-conjecture, in the sharp form:

* `tpow_le_spread` — the **upper** half of the conjecture is true exactly as stated:
  `tpow A m i j ≤ (m+1)·λ + spread v` for every eigenvector `v`;
* `no_spread_lower_bound` — the **lower** half is *false*: for
  `A = [[0,−3],[0,−3]]` the constant vector is an eigenvector (spread `0`) while the
  whole second column of every tropical power stays `3` below `(m+1)·λ`;
* `exists_uniform_entry_bound` — but the *boundedness* statement survives with a larger,
  explicitly computable constant: with `q ≤ n` the length of a critical cycle and
  `a = min_{i,j} A i j`,
  `|tpow A m i j − (m+1)·λ| ≤ spread v + (1+q)·|a − λ|` for all `m ≥ q + 1`.
  The lower bound is obtained by *constructing* long walks: one step into a critical
  node, `k` turns around the critical cycle, and a short tail of length `r ≤ q`.
* `tendsto_tpow_div` — consequently the entrywise Gelfand formula holds:
  `tpow A m i j / (m+1) → λ` for *every* pair `(i,j)`, a strengthening of the
  largest-entry version `tendsto_specNorm_div`.

The technical engine is the semigroup law `tpow_add : A^{⊗(a+b+2)} = A^{⊗(a+1)} ⊗ A^{⊗(b+1)}`
together with the critical cycle produced by tropical Perron–Frobenius.
-/
import Mathlib
import Algebra.TropicalLinearAlgebra.TropicalGelfand

namespace TropicalLA

open Filter Topology

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-! ## The semigroup law for tropical powers -/

/-- Tropical powers compose: `A^{⊗(a+1)} ⊗ A^{⊗(b+1)} = A^{⊗(a+b+2)}`. -/
theorem tpow_add (A : Matrix ι ι ℝ) (a b : ℕ) :
    tpow A (a + b + 1) = tmul (tpow A a) (tpow A b) := by
  induction b with
  | zero => rfl
  | succ b ih =>
      show tmul (tpow A (a + b + 1)) A = _
      rw [ih, tmul_assoc]
      rfl

/-- Concatenating an optimal walk of length `a+1` with one of length `b+1` is a lower
bound for the optimum over walks of length `a+b+2`. -/
theorem tpow_add_ge (A : Matrix ι ι ℝ) (a b : ℕ) (i k j : ι) :
    tpow A a i k + tpow A b k j ≤ tpow A (a + b + 1) i j := by
  rw [tpow_add]
  exact le_tmul (tpow A a) (tpow A b) i j k

/-! ## Smallest entry -/

/-- The smallest entry of `A`; a crude but uniform lower bound on any single step. -/
noncomputable def minEntry (A : Matrix ι ι ℝ) : ℝ :=
  (Finset.univ : Finset (ι × ι)).inf' Finset.univ_nonempty fun p => A p.1 p.2

theorem minEntry_le (A : Matrix ι ι ℝ) (i j : ι) : minEntry A ≤ A i j :=
  Finset.inf'_le (fun p : ι × ι => A p.1 p.2) (Finset.mem_univ (i, j))

/-- Every length-`(m+1)` optimal walk weighs at least `(m+1)` times the smallest entry. -/
theorem minEntry_mul_le_tpow (A : Matrix ι ι ℝ) (m : ℕ) (i j : ι) :
    ((m : ℝ) + 1) * minEntry A ≤ tpow A m i j := by
  induction m generalizing i j with
  | zero => simpa [tpow] using minEntry_le A i j
  | succ m ih =>
      have h1 : tpow A m i j + A j j ≤ tpow A (m + 1) i j := le_tmul (tpow A m) A i j j
      have h2 := ih i j
      have h3 := minEntry_le A j j
      push_cast
      linarith

/-! ## Upper bound from an eigenvector -/

/-- The spread of a vector: the difference between its largest and smallest entries. -/
noncomputable def spread (v : ι → ℝ) : ℝ :=
  Finset.univ.sup' (Finset.univ_nonempty (α := ι)) v
    - Finset.univ.inf' (Finset.univ_nonempty (α := ι)) v

theorem spread_nonneg (v : ι → ℝ) : 0 ≤ spread v := by
  obtain ⟨i⟩ := ‹Nonempty ι›
  have h1 : v i ≤ Finset.univ.sup' (Finset.univ_nonempty (α := ι)) v :=
    Finset.le_sup' v (Finset.mem_univ i)
  have h2 : Finset.univ.inf' (Finset.univ_nonempty (α := ι)) v ≤ v i :=
    Finset.inf'_le v (Finset.mem_univ i)
  rw [spread]; linarith

/-- **Entrywise upper bound** (the true half of the box conjecture): every entry of
`A^{⊗(m+1)}` is at most `(m+1)·lam` plus the spread of any eigenvector. -/
theorem tpow_le_spread {A : Matrix ι ι ℝ} {lam : ℝ} {v : ι → ℝ} (h : IsTropEigen A lam v)
    (m : ℕ) (i j : ι) : tpow A m i j ≤ ((m : ℝ) + 1) * lam + spread v := by
  have h1 : tpow A m i j + v j ≤ tmulVec (tpow A m) v i := le_tmulVec (tpow A m) v i j
  rw [h.tmulVec_tpow m] at h1
  have h2 : v i ≤ Finset.univ.sup' (Finset.univ_nonempty (α := ι)) v :=
    Finset.le_sup' v (Finset.mem_univ i)
  have h3 : Finset.univ.inf' (Finset.univ_nonempty (α := ι)) v ≤ v j :=
    Finset.inf'_le v (Finset.mem_univ j)
  rw [spread]
  simp only at h1
  linarith

/-! ## Powers of a critical cycle -/

/-- Repeating a critical cycle: there is a node `z` on a cycle of length `q ≤ n` such that
`A^{⊗(kq)} z z ≥ kq·lam` for every `k ≥ 1`. -/
theorem exists_critical_node (A : Matrix ι ι ℝ) :
    ∃ (q : ℕ) (z : ι), 0 < q ∧ q ≤ Fintype.card ι ∧
      ∀ k : ℕ, 0 < k → ((k * q : ℕ) : ℝ) * maxCycleMean A ≤ tpow A (k * q - 1) z z := by
  obtain ⟨q, c, hq0, hqn, hc, hcw⟩ := exists_critical_cycle_maxCycleMean (A := A)
  refine ⟨q, c 0, hq0, hqn, ?_⟩
  have hbase : (q : ℝ) * maxCycleMean A ≤ tpow A (q - 1) (c 0) (c 0) := by
    have hle : pathWeight A c (q - 1 + 1) ≤ tpow A (q - 1) (c 0) (c 0) :=
      (tpow_isGreatest A (q - 1) (c 0) (c 0)).2 ⟨c, rfl, by rw [show q - 1 + 1 = q by omega, hc], rfl⟩
    rw [show q - 1 + 1 = q by omega, hcw] at hle
    exact hle
  intro k hk
  induction k with
  | zero => omega
  | succ k ih =>
      rcases Nat.eq_zero_or_pos k with rfl | hkpos
      · simpa using hbase
      · have ihk := ih hkpos
        have hstep : tpow A (k * q - 1) (c 0) (c 0) + tpow A (q - 1) (c 0) (c 0)
            ≤ tpow A ((k * q - 1) + (q - 1) + 1) (c 0) (c 0) :=
          tpow_add_ge A (k * q - 1) (q - 1) (c 0) (c 0) (c 0)
        have hexp : (k + 1) * q = k * q + q := by ring
        have hkq1 : 1 ≤ k * q := Nat.one_le_iff_ne_zero.mpr (by positivity)
        have hidx : (k * q - 1) + (q - 1) + 1 = (k + 1) * q - 1 := by omega
        rw [hidx] at hstep
        have hcast : (((k + 1) * q : ℕ) : ℝ) = ((k * q : ℕ) : ℝ) + (q : ℝ) := by
          push_cast; ring
        rw [hcast, add_mul]
        linarith

/-! ## The uniform two-sided entrywise bound -/

/-- **Entrywise lower bound.**  For `m ≥ q + 1` (with `q` the length of a critical cycle)
every entry of `A^{⊗(m+1)}` is at least `(m+1)·lam − (1+q)·|a − lam|`, where `a` is the
smallest entry of `A`.  The witness walk enters a critical node in one step, turns `k`
times around the critical cycle and leaves along a tail of length `r ≤ q`. -/
theorem exists_uniform_entry_lower_bound (A : Matrix ι ι ℝ) :
    ∃ (K : ℝ) (N : ℕ), 0 ≤ K ∧ ∀ m : ℕ, N ≤ m → ∀ i j : ι,
      ((m : ℝ) + 1) * maxCycleMean A - K ≤ tpow A m i j := by
  obtain ⟨q, z, hq0, _, hcyc⟩ := exists_critical_node A
  set lam := maxCycleMean A with hlam
  set a := minEntry A with ha
  refine ⟨(1 + q) * |a - lam|, q + 1, by positivity, ?_⟩
  intro m hm i j
  -- split `m = k*q + r` with `1 ≤ k` and `1 ≤ r ≤ q`
  obtain ⟨k, r, hk1, hr1, hrq, hkr⟩ :
      ∃ k r : ℕ, 1 ≤ k ∧ 1 ≤ r ∧ r ≤ q ∧ k * q + r = m := by
    obtain ⟨k, s, hdm, hmod⟩ : ∃ k s : ℕ, q * k + s = m - 1 ∧ s < q :=
      ⟨(m - 1) / q, (m - 1) % q, Nat.div_add_mod _ _, Nat.mod_lt _ hq0⟩
    have hk1 : 1 ≤ k := by
      rcases Nat.eq_zero_or_pos k with rfl | hpos
      · simp only [Nat.mul_zero, Nat.zero_add] at hdm; omega
      · exact hpos
    have hcomm : k * q = q * k := Nat.mul_comm k q
    exact ⟨k, s + 1, hk1, by omega, by omega, by omega⟩
  have hkq1 : 1 ≤ k * q := Nat.mul_pos (by omega) hq0
  -- the three pieces of the walk
  have hstep1 : a ≤ tpow A 0 i z := by
    simpa [tpow] using minEntry_le A i z
  have hcycle : ((k * q : ℕ) : ℝ) * lam ≤ tpow A (k * q - 1) z z := hcyc k (by omega)
  have htail : (r : ℝ) * a ≤ tpow A (r - 1) z j := by
    have := minEntry_mul_le_tpow A (r - 1) z j
    have hcast : ((r - 1 : ℕ) : ℝ) + 1 = (r : ℝ) := by
      have : (1 : ℕ) ≤ r := hr1
      push_cast [this]
      ring
    rwa [hcast] at this
  -- glue: `i → z` (1 step), `z → z` (k*q steps), `z → j` (r steps)
  have hglue1 : tpow A 0 i z + tpow A (k * q - 1) z z ≤ tpow A (k * q) i z := by
    have h := tpow_add_ge A 0 (k * q - 1) i z z
    have hidx : 0 + (k * q - 1) + 1 = k * q := by
      have : 1 ≤ k * q := Nat.one_le_iff_ne_zero.mpr (by positivity)
      omega
    rwa [hidx] at h
  have hglue2 : tpow A (k * q) i z + tpow A (r - 1) z j ≤ tpow A m i j := by
    have h := tpow_add_ge A (k * q) (r - 1) i z j
    have hidx : k * q + (r - 1) + 1 = m := by omega
    rwa [hidx] at h
  -- assemble the numeric estimate
  have hkqcast : ((k * q : ℕ) : ℝ) = (m : ℝ) - (r : ℝ) := by
    have : (r : ℕ) ≤ m := by omega
    have : ((k * q : ℕ) : ℝ) + (r : ℝ) = (m : ℝ) := by
      rw [← Nat.cast_add, hkr]
    linarith
  have hrcast : (r : ℝ) ≤ (q : ℝ) := by exact_mod_cast hrq
  have hr1cast : (1 : ℝ) ≤ (r : ℝ) := by exact_mod_cast hr1
  have hlow : ((m : ℝ) + 1) * lam + (1 + (r : ℝ)) * (a - lam) ≤ tpow A m i j := by
    have hsum : a + (((k * q : ℕ) : ℝ) * lam) + (r : ℝ) * a ≤ tpow A m i j := by
      linarith
    rw [hkqcast] at hsum
    nlinarith [hsum]
  have habs : -((1 + (q : ℝ)) * |a - lam|) ≤ (1 + (r : ℝ)) * (a - lam) := by
    rcases le_total (a - lam) 0 with hneg | hpos
    · have habs' : |a - lam| = -(a - lam) := abs_of_nonpos hneg
      rw [habs']
      nlinarith
    · have habs' : |a - lam| = a - lam := abs_of_nonneg hpos
      rw [habs']
      nlinarith [abs_nonneg (a - lam)]
  linarith

/-- **Uniform two-sided entrywise bound** (the corrected form of sub-conjecture 1):
there are a constant `K ≥ 0` and a threshold `N` with
`|A^{⊗(m+1)} i j − (m+1)·λ| ≤ K` for all `m ≥ N` and all entries `(i,j)`. -/
theorem exists_uniform_entry_bound (A : Matrix ι ι ℝ) :
    ∃ (K : ℝ) (N : ℕ), 0 ≤ K ∧ ∀ m : ℕ, N ≤ m → ∀ i j : ι,
      |tpow A m i j - ((m : ℝ) + 1) * maxCycleMean A| ≤ K := by
  obtain ⟨K₁, N, hK₁, hlow⟩ := exists_uniform_entry_lower_bound A
  obtain ⟨v, hv⟩ := exists_tropEigen A
  refine ⟨max K₁ (spread v), N, le_trans hK₁ (le_max_left _ _), ?_⟩
  intro m hm i j
  have h1 := hlow m hm i j
  have h2 := tpow_le_spread hv m i j
  rw [abs_le]
  constructor
  · have := le_max_left K₁ (spread v)
    linarith
  · have := le_max_right K₁ (spread v)
    linarith

/-- **Entrywise tropical Gelfand formula.**  For *every* pair of indices the normalised
entries of the tropical powers converge to the maximum cycle mean.  (The largest-entry
version is `tendsto_specNorm_div`.) -/
theorem tendsto_tpow_div (A : Matrix ι ι ℝ) (i j : ι) :
    Tendsto (fun m : ℕ => tpow A m i j / (m + 1)) atTop (𝓝 (maxCycleMean A)) := by
  obtain ⟨K, N, hK, hbound⟩ := exists_uniform_entry_bound A
  set lam := maxCycleMean A with hlam
  have hKzero : Tendsto (fun m : ℕ => K / ((m : ℝ) + 1)) atTop (𝓝 0) := by
    have : Tendsto (fun m : ℕ => K * (1 / ((m : ℝ) + 1))) atTop (𝓝 (K * 0)) :=
      Tendsto.const_mul K tendsto_one_div_add_atTop_nhds_zero_nat
    simpa [mul_one_div] using this
  have hlow : Tendsto (fun m : ℕ => lam - K / ((m : ℝ) + 1)) atTop (𝓝 lam) := by
    simpa using (tendsto_const_nhds (x := lam) (f := atTop (α := ℕ))).sub hKzero
  have hhigh : Tendsto (fun m : ℕ => lam + K / ((m : ℝ) + 1)) atTop (𝓝 lam) := by
    simpa using (tendsto_const_nhds (x := lam) (f := atTop (α := ℕ))).add hKzero
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlow hhigh ?_ ?_
  · filter_upwards [eventually_ge_atTop N] with m hm
    have hb := (abs_le.mp (hbound m hm i j)).1
    have hpos : (0 : ℝ) < (m : ℝ) + 1 := by positivity
    rw [le_div_iff₀ hpos]
    have heq : (lam - K / ((m : ℝ) + 1)) * ((m : ℝ) + 1) = ((m : ℝ) + 1) * lam - K := by
      field_simp
    rw [heq]
    linarith
  · filter_upwards [eventually_ge_atTop N] with m hm
    have hb := (abs_le.mp (hbound m hm i j)).2
    have hpos : (0 : ℝ) < (m : ℝ) + 1 := by positivity
    rw [div_le_iff₀ hpos]
    have heq : (lam + K / ((m : ℝ) + 1)) * ((m : ℝ) + 1) = ((m : ℝ) + 1) * lam + K := by
      field_simp
    rw [heq]
    linarith

/-! ## The spread is *not* a lower bound: refutation of the naive box conjecture -/

/-- **Counterexample.**  For `A = [[0,−3],[0,−3]]` the constant vector is a tropical
eigenvector, so its spread is `0` and `λ(A) = 0`; nevertheless every entry in the second
column of every tropical power is at most `−3`.  Hence the two-sided box bound with
constant `spread v` is false: only the upper half of sub-conjecture 1 holds, and the
lower bound genuinely needs a constant depending on the entries of `A`. -/
theorem no_spread_lower_bound :
    ∃ (A : Matrix (Fin 2) (Fin 2) ℝ) (v : Fin 2 → ℝ),
      IsTropEigen A (maxCycleMean A) v ∧ spread v = 0 ∧
      ∀ (m : ℕ) (i : Fin 2), tpow A m i 1 ≤ ((m : ℝ) + 1) * maxCycleMean A - 3 := by
  classical
  set A : Matrix (Fin 2) (Fin 2) ℝ := Matrix.of ![![0, -3], ![0, -3]] with hA
  set v : Fin 2 → ℝ := fun _ => 0 with hv
  have hcol : ∀ k : Fin 2, A k 1 = -3 := by
    intro k; fin_cases k <;> norm_num [hA]
  have hentry : ∀ k l : Fin 2, A k l ≤ 0 := by
    intro k l; fin_cases k <;> fin_cases l <;> norm_num [hA]
  have hfirst : ∀ k : Fin 2, A k 0 = 0 := by
    intro k; fin_cases k <;> norm_num [hA]
  have heig : IsTropEigen A 0 v := by
    intro i
    apply le_antisymm
    · refine Finset.sup'_le _ _ fun j _ => ?_
      have := hentry i j
      simp [hv]
      linarith
    · have h := le_tmulVec A v i 0
      rw [hfirst i] at h
      simpa [hv] using h
  have hmax : maxCycleMean A = 0 :=
    ((tropEigen_iff_eq_maxCycleMean A 0).mp ⟨v, heig⟩).symm
  have hspread : spread v = 0 := by
    rw [spread, hv, Finset.sup'_const, Finset.inf'_const, sub_self]
  refine ⟨A, v, by rw [hmax]; exact heig, hspread, ?_⟩
  have hle0 : ∀ (m : ℕ) (i j : Fin 2), tpow A m i j ≤ 0 := by
    intro m i j
    have := tpow_le_spread heig m i j
    rw [hspread] at this
    simpa using this
  intro m i
  rw [hmax]
  have hkey : ∀ (m : ℕ) (i : Fin 2), tpow A m i 1 ≤ -3 := by
    intro m
    induction m with
    | zero => intro i; simpa [tpow] using le_of_eq (hcol i)
    | succ m ih =>
        intro i
        refine tmul_le (A := tpow A m) (B := A) fun k => ?_
        have h1 := hle0 m i k
        have h2 := hcol k
        rw [h2]
        linarith
  have := hkey m i
  simp only [mul_zero]
  linarith

end TropicalLA