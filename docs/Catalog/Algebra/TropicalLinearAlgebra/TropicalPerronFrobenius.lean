/-
# Tropical Perron–Frobenius: existence of the eigenvalue

This file completes the max-plus spectral theory of `TropicalEigenvalue.lean` by
proving **existence**: every matrix with finite real entries has a tropical
eigenvalue, namely its maximum cycle mean, together with an explicit eigenvector
built from the Kleene star (optimal-path) matrix of the normalised matrix.

The combinatorial engine is `pathWeight_excise`: a walk that repeats a vertex
splits into a shorter walk with the same endpoints plus a closed sub-walk.
Together with the pigeonhole principle this yields

* `cycle_le_maxCycleMean` : *every* closed walk, of any length, has weight at most
  `length · λ` where `λ` is the maximum mean over closed walks of length `≤ n`;
* `exists_short_walk_ge`  : when all cycles are nonpositive, every walk is dominated
  by one of length at most `n` with the same endpoints;
* `exists_tropEigen`      : **tropical Perron–Frobenius** — `A` has the eigenvalue
  `maxCycleMean A`, with an eigenvector given by optimal paths into a critical node.

Combined with `tropEigenvalue_unique` this says: a max-plus matrix with finite
entries has *exactly one* eigenvalue, the maximum cycle mean.
-/
import Mathlib
import Algebra.TropicalLinearAlgebra.TropicalEigenvalue

namespace TropicalLA

variable {ι : Type*} [Fintype ι] [Nonempty ι]

section Excision

omit [Fintype ι] [Nonempty ι] in
/-- **Walk excision.**  If a walk `p` of length `m` visits the same vertex at times
`a < b`, then deleting the closed sub-walk between those times leaves a walk with the
same endpoints, and the two weights add up to the original weight. -/
theorem pathWeight_excise (A : Matrix ι ι ℝ) (p : ℕ → ι) {a b m : ℕ} (hab : a < b) (hbm : b ≤ m)
    (hp : p a = p b) :
    pathWeight A (fun t => if t < a then p t else p (t + (b - a))) (m - (b - a))
      + pathWeight A (fun t => p (a + t)) (b - a) = pathWeight A p m := by
  set d := b - a with hd
  have hd1 : 1 ≤ d := by omega
  have hbd : a + d = b := by omega
  set q : ℕ → ι := fun t => if t < a then p t else p (t + d) with hq
  have hqle : ∀ t, t ≤ a → q t = p t := by
    intro t ht
    rcases lt_or_eq_of_le ht with h | h
    · simp [hq, h]
    · subst h
      simp only [hq, lt_irrefl, if_false]
      rw [hbd, ← hp]
  have hqge : ∀ t, a ≤ t → q t = p (t + d) := by
    intro t ht
    rcases lt_or_eq_of_le ht with h | h
    · simp [hq, Nat.not_lt.mpr (le_of_lt h)]
    · subst h; simp [hq]
  have h1 : ∑ t ∈ Finset.Ico 0 a, A (q t) (q (t+1)) = ∑ t ∈ Finset.Ico 0 a, A (p t) (p (t+1)) := by
    refine Finset.sum_congr rfl fun t ht => ?_
    simp only [Finset.mem_Ico] at ht
    rw [hqle t (le_of_lt ht.2), hqle (t+1) (by omega)]
  have key : ∀ t, a ≤ t → A (q t) (q (t+1)) = A (p (t+d)) (p (t+d+1)) := by
    intro t ht
    rw [hqge t ht, hqge (t+1) (by omega)]
    congr 2
    omega
  have h2 : ∑ t ∈ Finset.Ico a (m - d), A (q t) (q (t+1))
      = ∑ s ∈ Finset.Ico b m, A (p s) (p (s+1)) := by
    calc ∑ t ∈ Finset.Ico a (m - d), A (q t) (q (t+1))
        = ∑ t ∈ Finset.Ico a (m - d), (fun s => A (p s) (p (s+1))) (t + d) :=
          Finset.sum_congr rfl fun t ht => key t (Finset.mem_Ico.mp ht).1
      _ = ∑ s ∈ Finset.Ico (a + d) ((m - d) + d), A (p s) (p (s+1)) :=
          Finset.sum_Ico_add' (fun s => A (p s) (p (s+1))) a (m - d) d
      _ = ∑ s ∈ Finset.Ico b m, A (p s) (p (s+1)) := by
          rw [show a + d = b by omega, show m - d + d = m by omega]
  have h3 : pathWeight A (fun t => p (a + t)) d = ∑ s ∈ Finset.Ico a b, A (p s) (p (s+1)) := by
    rw [pathWeight, Finset.sum_Ico_eq_sum_range]
    exact (Finset.sum_congr (by rw [← hd]) fun t _ => by rw [Nat.add_assoc]).symm
  have hsplit : pathWeight A q (m - d) = ∑ t ∈ Finset.Ico 0 a, A (p t) (p (t+1))
      + ∑ s ∈ Finset.Ico b m, A (p s) (p (s+1)) := by
    rw [pathWeight, Finset.range_eq_Ico,
      ← Finset.sum_Ico_consecutive (fun t => A (q t) (q (t+1))) (Nat.zero_le a)
        (by omega : a ≤ m - d), h1, h2]
  have e1 := Finset.sum_Ico_consecutive (fun t => A (p t) (p (t+1))) (Nat.zero_le a) (le_of_lt hab)
  have e2 := Finset.sum_Ico_consecutive (fun t => A (p t) (p (t+1))) (Nat.zero_le b) hbm
  rw [hsplit, h3, pathWeight, Finset.range_eq_Ico]
  simp only at e1 e2 ⊢
  linarith

omit [Nonempty ι] in
/-- Pigeonhole: a walk of length `> n` repeats a vertex within its first `n+1` steps. -/
theorem exists_repeat (p : ℕ → ι) : ∃ a b : ℕ, a < b ∧ b ≤ Fintype.card ι ∧ p a = p b := by
  classical
  obtain ⟨x, hx, y, hy, hxy, hpxy⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to
      (s := Finset.range (Fintype.card ι + 1)) (t := (Finset.univ : Finset ι))
      (by simp) (fun a _ => Finset.mem_univ (p a))
  rw [Finset.mem_range] at hx hy
  rcases lt_or_gt_of_ne hxy with h | h
  · exact ⟨x, y, h, by omega, hpxy⟩
  · exact ⟨y, x, h, by omega, hpxy.symm⟩

end Excision

section MaxCycleMean

variable (A : Matrix ι ι ℝ)

theorem cycleIndex_nonempty :
    ((Finset.range (Fintype.card ι)) ×ˢ (Finset.univ : Finset ι)).Nonempty := by
  refine Finset.Nonempty.product ?_ Finset.univ_nonempty
  exact Finset.nonempty_range_iff.mpr (Fintype.card_ne_zero)

/-- The **maximum cycle mean** of `A`: the largest mean weight of a closed walk of
length at most `n = |ι|`.  (Theorem `cycle_le_maxCycleMean` shows longer cycles cannot
do better.) -/
noncomputable def maxCycleMean : ℝ :=
  ((Finset.range (Fintype.card ι)) ×ˢ (Finset.univ : Finset ι)).sup'
    (cycleIndex_nonempty) (fun q => tpow A q.1 q.2 q.2 / (q.1 + 1))

variable {A}

theorem tpow_diag_div_le_maxCycleMean {k : ℕ} (hk : k < Fintype.card ι) (i : ι) :
    tpow A k i i / (k + 1) ≤ maxCycleMean A := by
  rw [maxCycleMean]
  exact Finset.le_sup' (fun q : ℕ × ι => tpow A q.1 q.2 q.2 / (q.1 + 1))
    (show (k, i) ∈ (Finset.range (Fintype.card ι)) ×ˢ (Finset.univ : Finset ι) by
      simp [Finset.mem_product, hk])

theorem exists_eq_maxCycleMean :
    ∃ (k : ℕ) (i : ι), k < Fintype.card ι ∧ maxCycleMean A = tpow A k i i / (k + 1) := by
  obtain ⟨q, hq, hval⟩ := Finset.exists_mem_eq_sup' (cycleIndex_nonempty (ι := ι))
    (fun q : ℕ × ι => tpow A q.1 q.2 q.2 / (q.1 + 1))
  rw [Finset.mem_product, Finset.mem_range] at hq
  exact ⟨q.1, q.2, hq.1, by rw [maxCycleMean]; exact hval⟩

/-- Short cycles (length `≤ n`) obey the bound defining the maximum cycle mean. -/
theorem short_cycle_le {m : ℕ} (hm : 0 < m) (hmn : m ≤ Fintype.card ι) {c : ℕ → ι}
    (hc : c m = c 0) : pathWeight A c m ≤ m * maxCycleMean A := by
  obtain ⟨k, rfl⟩ : ∃ k, m = k + 1 := ⟨m - 1, by omega⟩
  have hk : k < Fintype.card ι := by omega
  have hle : pathWeight A c (k + 1) ≤ tpow A k (c 0) (c 0) :=
    (tpow_isGreatest A k (c 0) (c 0)).2 ⟨c, rfl, hc, rfl⟩
  have hbound := tpow_diag_div_le_maxCycleMean (A := A) hk (c 0)
  have hpos : (0 : ℝ) < (k : ℝ) + 1 := by positivity
  rw [div_le_iff₀ hpos] at hbound
  push_cast
  linarith

/-- **Every** closed walk, of any length, has weight at most `length · maxCycleMean`.
Long cycles are handled by excising a repeated vertex and inducting. -/
theorem cycle_le_maxCycleMean : ∀ (m : ℕ) (c : ℕ → ι), c m = c 0 →
    pathWeight A c m ≤ m * maxCycleMean A := by
  intro m
  induction m using Nat.strong_induction_on with
  | _ m ih =>
    intro c hc
    rcases Nat.eq_zero_or_pos m with rfl | hm
    · simp [pathWeight]
    by_cases hmn : m ≤ Fintype.card ι
    · exact short_cycle_le hm hmn hc
    · push_neg at hmn
      obtain ⟨a, b, hab, hbn, hpab⟩ := exists_repeat c
      have hbm : b ≤ m := le_of_lt (lt_of_le_of_lt hbn hmn)
      have hd : 0 < b - a := by omega
      have hdm : b - a < m := by omega
      have hsplit := pathWeight_excise A c hab hbm hpab
      set d := b - a with hdd
      set q : ℕ → ι := fun t => if t < a then c t else c (t + d) with hq
      have hq0 : q 0 = c 0 := by
        rcases Nat.eq_zero_or_pos a with ha | ha
        · subst ha
          simp only [hq, lt_irrefl, if_false, Nat.zero_add]
          rw [show d = b by omega, ← hpab]
        · simp [hq, ha]
      have hqm : q (m - d) = c 0 := by
        have : ¬ (m - d < a) := by omega
        rw [hq]
        simp only [this, if_false]
        rw [show m - d + d = m by omega, hc]
      have hqcycle : q (m - d) = q 0 := by rw [hqm, hq0]
      have h1 : pathWeight A q (m - d) ≤ (m - d : ℕ) * maxCycleMean A := ih (m - d) (by omega) q hqcycle
      have hcyc : (fun t => c (a + t)) d = (fun t => c (a + t)) 0 := by
        simp only
        rw [show a + d = b by omega, show a + 0 = a by omega, hpab]
      have h2 : pathWeight A (fun t => c (a + t)) d ≤ (d : ℕ) * maxCycleMean A :=
        ih d hdm _ hcyc
      have hcast : ((m - d : ℕ) : ℝ) = (m : ℝ) - (d : ℝ) := by
        have : d ≤ m := by omega
        push_cast [this]
        ring
      rw [← hsplit]
      rw [hcast] at h1
      linarith

/-- The maximum cycle mean is attained: there is a **critical cycle** of length
`1 ≤ m ≤ n` whose mean weight equals `maxCycleMean A`. -/
theorem exists_critical_cycle_maxCycleMean :
    ∃ (m : ℕ) (c : ℕ → ι), 0 < m ∧ m ≤ Fintype.card ι ∧ c m = c 0 ∧
      pathWeight A c m = m * maxCycleMean A := by
  obtain ⟨k, i, hk, hval⟩ := exists_eq_maxCycleMean (A := A)
  obtain ⟨p, hp0, hpk, hpw⟩ := (tpow_isGreatest A k i i).1
  refine ⟨k + 1, p, by omega, by omega, by rw [hpk, hp0], ?_⟩
  have hpos : (0 : ℝ) < (k : ℝ) + 1 := by positivity
  rw [hval, ← hpw]
  push_cast
  field_simp

end MaxCycleMean

section Existence

variable {A : Matrix ι ι ℝ}

omit [Fintype ι] [Nonempty ι] in
/-- Peeling the first step off a walk. -/
theorem pathWeight_shift (A : Matrix ι ι ℝ) (p : ℕ → ι) (m : ℕ) :
    pathWeight A p (m + 1) = A (p 0) (p 1) + pathWeight A (fun t => p (t + 1)) m := by
  rw [pathWeight, pathWeight, Finset.sum_range_succ' (fun t => A (p t) (p (t + 1))) m]
  ring

omit [Fintype ι] [Nonempty ι] in
/-- Subtracting a constant from every entry lowers each length-`m` walk weight by `m·lam`. -/
theorem pathWeight_sub_const (A : Matrix ι ι ℝ) (lam : ℝ) (p : ℕ → ι) (m : ℕ) :
    pathWeight (Matrix.of fun i j => A i j - lam) p m = pathWeight A p m - m * lam := by
  rw [pathWeight, pathWeight]
  simp only [Matrix.of_apply, Finset.sum_sub_distrib, Finset.sum_const, Finset.card_range,
    nsmul_eq_mul]

omit [Nonempty ι] in
/-- **Cycle removal.**  If every closed walk of `A` has nonpositive weight, then any walk
is dominated by a walk of length at most `n = |ι|` with the same endpoints. -/
theorem exists_short_walk_ge (hcyc : ∀ (m : ℕ) (c : ℕ → ι), c m = c 0 → pathWeight A c m ≤ 0) :
    ∀ (m : ℕ), 0 < m → ∀ (p : ℕ → ι), ∃ (m' : ℕ) (q : ℕ → ι), 0 < m' ∧ m' ≤ Fintype.card ι ∧
      q 0 = p 0 ∧ q m' = p m ∧ pathWeight A p m ≤ pathWeight A q m' := by
  intro m
  induction m using Nat.strong_induction_on with
  | _ m ih =>
    intro hm p
    by_cases hmn : m ≤ Fintype.card ι
    · exact ⟨m, p, hm, hmn, rfl, rfl, le_rfl⟩
    · push_neg at hmn
      obtain ⟨a, b, hab, hbn, hpab⟩ := exists_repeat p
      have hbm : b ≤ m := le_of_lt (lt_of_le_of_lt hbn hmn)
      have hsplit := pathWeight_excise A p hab hbm hpab
      set d := b - a with hdd
      set q : ℕ → ι := fun t => if t < a then p t else p (t + d) with hq
      have hd0 : 0 < d := by omega
      have hdm : d < m := by omega
      have hq0 : q 0 = p 0 := by
        rcases Nat.eq_zero_or_pos a with ha | ha
        · subst ha
          simp only [hq, lt_irrefl, if_false, Nat.zero_add]
          rw [show d = b by omega, ← hpab]
        · simp [hq, ha]
      have hqend : q (m - d) = p m := by
        have hlt : ¬ (m - d < a) := by omega
        rw [hq]
        simp only [hlt, if_false]
        rw [show m - d + d = m by omega]
      have hcycle : pathWeight A (fun t => p (a + t)) d ≤ 0 := by
        refine hcyc d _ ?_
        show p (a + d) = p (a + 0)
        rw [show a + d = b by omega, show a + 0 = a by omega, hpab]
      obtain ⟨m', r, h1, h2, h3, h4, h5⟩ := ih (m - d) (by omega) (by omega) q
      exact ⟨m', r, h1, h2, by rw [h3, hq0], by rw [h4, hqend], by linarith⟩

/-- The Kleene-star (optimal path) vector: `v j` is the best weight of a walk of length
between `1` and `n` from `j` to the base point `i₀`. -/
noncomputable def kleeneVec (B : Matrix ι ι ℝ) (i₀ : ι) : ι → ℝ :=
  fun j => (Finset.range (Fintype.card ι)).sup'
    (Finset.nonempty_range_iff.mpr Fintype.card_ne_zero) (fun k => tpow B k j i₀)

theorem tpow_le_kleeneVec (B : Matrix ι ι ℝ) (i₀ : ι) {k : ℕ} (hk : k < Fintype.card ι) (j : ι) :
    tpow B k j i₀ ≤ kleeneVec B i₀ j :=
  Finset.le_sup' (fun k => tpow B k j i₀) (Finset.mem_range.mpr hk)

theorem exists_tpow_eq_kleeneVec (B : Matrix ι ι ℝ) (i₀ : ι) (j : ι) :
    ∃ k, k < Fintype.card ι ∧ kleeneVec B i₀ j = tpow B k j i₀ := by
  obtain ⟨k, hk, hval⟩ := Finset.exists_mem_eq_sup'
    (Finset.nonempty_range_iff.mpr (Fintype.card_ne_zero (α := ι))) (fun k => tpow B k j i₀)
  exact ⟨k, Finset.mem_range.mp hk, hval⟩

/-- Sufficient criterion for an eigenpair: a uniform upper bound that is attained in
every row. -/
theorem isTropEigen_of (A : Matrix ι ι ℝ) (lam : ℝ) (v : ι → ℝ)
    (hup : ∀ i j, A i j + v j ≤ lam + v i) (htight : ∀ i, ∃ j, A i j + v j = lam + v i) :
    IsTropEigen A lam v := by
  intro i
  refine le_antisymm (Finset.sup'_le _ _ fun j _ => hup i j) ?_
  obtain ⟨j, hj⟩ := htight i
  rw [← hj]
  exact le_tmulVec A v i j

/-- **Tropical Perron–Frobenius (existence).**  Every max-plus matrix with finite
entries has the eigenvalue `maxCycleMean A`; an eigenvector is given by optimal path
weights into a node of a critical cycle. -/
theorem exists_tropEigen (A : Matrix ι ι ℝ) :
    ∃ v : ι → ℝ, IsTropEigen A (maxCycleMean A) v := by
  classical
  set lam := maxCycleMean A with hlam
  set B : Matrix ι ι ℝ := Matrix.of fun i j => A i j - lam with hB
  have hBentry : ∀ i j, B i j = A i j - lam := fun i j => rfl
  have hcycB : ∀ (m : ℕ) (c : ℕ → ι), c m = c 0 → pathWeight B c m ≤ 0 := by
    intro m c hc
    rw [hB, pathWeight_sub_const]
    have := cycle_le_maxCycleMean (A := A) m c hc
    linarith
  obtain ⟨m₀, c, hm₀, hm₀n, hc, hcw⟩ := exists_critical_cycle_maxCycleMean (A := A)
  set i₀ := c 0 with hi₀
  set v := kleeneVec B i₀ with hv
  -- the base point has nonnegative potential
  have hv0 : 0 ≤ v i₀ := by
    obtain ⟨k, rfl⟩ : ∃ k, m₀ = k + 1 := ⟨m₀ - 1, by omega⟩
    have hpath : pathWeight B c (k + 1) ≤ tpow B k i₀ i₀ :=
      (tpow_isGreatest B k i₀ i₀).2 ⟨c, rfl, hc, rfl⟩
    have hzero : pathWeight B c (k + 1) = 0 := by
      rw [hB, pathWeight_sub_const, hcw]
      ring
    have hkle : tpow B k i₀ i₀ ≤ v i₀ := tpow_le_kleeneVec B i₀ (by omega) i₀
    linarith
  -- upper bound
  have hup : ∀ i j, B i j + v j ≤ v i := by
    intro i j
    obtain ⟨k, hk, hkv⟩ := exists_tpow_eq_kleeneVec B i₀ j
    rw [← hv] at hkv
    obtain ⟨p, hp0, hpk, hpw⟩ := (tpow_isGreatest B k j i₀).1
    set p' : ℕ → ι := fun t => if t = 0 then i else p (t - 1) with hp'
    have hp'0 : p' 0 = i := by simp [hp']
    have hp'succ : ∀ t, p' (t + 1) = p t := by intro t; simp [hp']
    have hp'w : pathWeight B p' (k + 2) = B i j + pathWeight B p (k + 1) := by
      rw [pathWeight_shift B p' (k + 1), hp'0, hp'succ 0, hp0]
      congr 1
    have hp'end : p' (k + 2) = i₀ := by rw [show k + 2 = (k + 1) + 1 from rfl, hp'succ, hpk]
    obtain ⟨m', r, hm'0, hm'n, hr0, hrend, hrw⟩ :=
      exists_short_walk_ge hcycB (k + 2) (by omega) p'
    obtain ⟨k', rfl⟩ : ∃ k', m' = k' + 1 := ⟨m' - 1, by omega⟩
    have hrle : pathWeight B r (k' + 1) ≤ tpow B k' i i₀ := by
      refine (tpow_isGreatest B k' i i₀).2 ⟨r, ?_, ?_, rfl⟩
      · rw [hr0, hp'0]
      · rw [hrend, hp'end]
    have hfin : tpow B k' i i₀ ≤ v i := tpow_le_kleeneVec B i₀ (by omega) i
    have : B i j + v j = pathWeight B p' (k + 2) := by rw [hp'w, hkv, hpw]
    linarith
  -- tightness
  have htight : ∀ i, ∃ j, B i j + v j = v i := by
    intro i
    obtain ⟨k, hk, hkv⟩ := exists_tpow_eq_kleeneVec B i₀ i
    rw [← hv] at hkv
    obtain ⟨p, hp0, hpk, hpw⟩ := (tpow_isGreatest B k i i₀).1
    refine ⟨p 1, le_antisymm (hup i (p 1)) ?_⟩
    rcases Nat.eq_zero_or_pos k with rfl | hkpos
    · -- length-one optimal walk: `p 1 = i₀`
      have h1 : p 1 = i₀ := hpk
      have hpw' : pathWeight B p 1 = B i (p 1) := by
        rw [pathWeight, Finset.sum_range_one, hp0]
      rw [hkv, hpw, hpw', h1]
      have : 0 ≤ v i₀ := hv0
      linarith
    · obtain ⟨k', rfl⟩ : ∃ k', k = k' + 1 := ⟨k - 1, by omega⟩
      have htail : pathWeight B (fun t => p (t + 1)) (k' + 1) ≤ tpow B k' (p 1) i₀ := by
        refine (tpow_isGreatest B k' (p 1) i₀).2 ⟨fun t => p (t + 1), rfl, ?_, rfl⟩
        simpa using hpk
      have htailv : tpow B k' (p 1) i₀ ≤ v (p 1) := tpow_le_kleeneVec B i₀ (by omega) (p 1)
      have hsplit : pathWeight B p (k' + 2) = B i (p 1) + pathWeight B (fun t => p (t + 1)) (k' + 1) := by
        rw [pathWeight_shift B p (k' + 1), hp0]
      rw [hkv, hpw, show k' + 1 + 1 = k' + 2 from rfl, hsplit]
      linarith
  refine ⟨v, isTropEigen_of A lam v (fun i j => ?_) (fun i => ?_)⟩
  · have := hup i j
    rw [hBentry] at this
    linarith
  · obtain ⟨j, hj⟩ := htight i
    rw [hBentry] at hj
    exact ⟨j, by linarith⟩

/-- **Tropical Perron–Frobenius, full statement.**  A max-plus matrix with finite entries
has exactly one eigenvalue, namely its maximum cycle mean. -/
theorem tropEigen_iff_eq_maxCycleMean (A : Matrix ι ι ℝ) (lam : ℝ) :
    (∃ v : ι → ℝ, IsTropEigen A lam v) ↔ lam = maxCycleMean A := by
  constructor
  · rintro ⟨v, hv⟩
    obtain ⟨w, hw⟩ := exists_tropEigen A
    exact tropEigenvalue_unique hv hw
  · rintro rfl
    exact exists_tropEigen A

end Existence

end TropicalLA