import Catalog.Geometry.HyperbolicBerggrenSandwichExact

/-!
# Hyperbolic–Pythagorean Geodesics, cycle VIII: the tree structure of the depth function

Cycles I–VII studied a *single* Berggren node `(m,n)` and the effect of one Berggren move
on its hyperbolic position.  The quantity that the mission statement is really about — the
**path length**, i.e. the combinatorial depth `k` at which a node occurs — was so far only
touched in the negative (`depth_not_bounded_by_distance`: depth is not bounded by a constant
multiple of the hyperbolic distance).  This file settles the positive half and the
book-keeping that makes "the depth" a well-defined function in the first place.

## Main results

* `Reaches p k` : the inductive predicate "`p` is obtained from the root seed `(2,1)` by `k`
  Berggren moves".
* `reaches_isSeed` : every reachable pair is a Euclid seed (soundness).
* `seed_reaches` : **completeness of the Berggren tree.** *Every* Euclid seed is reachable.
  The proof runs the explicit inverse move `parentSeed`, which is a genuine trichotomy in
  the slope: `n/m ∈ (1/2, 1)`, `(1/3, 1/2)`, `(0, 1/3)` selects `B₁`, `B₂`, `B₃`.
* `reaches_unique` : **the Berggren tree really is a tree.**  A seed is reachable at exactly
  one depth, so `depth` is a well-defined function on seeds.
* `reaches_fst_le` : a node at depth `k` has `m ≤ 2·3^k`; hence
  `reaches_log_hyp_le` : `log c ≤ log 8 + k · log 9`, and
  `dist_le_depth` / `depth_ge_dist` : `2 d(i, z) ≤ log 32 + k · log 9`, i.e.
  **the hyperbolic distance is, up to constants, a lower bound for the depth**.
  Combined with `depth_not_bounded_by_distance` of cycle I this is the exact truth:
  `d ≲ k`, and no reverse inequality holds.
* `mspine_dist_ge` : along the middle (Pell) spine the reverse inequality *does* hold,
  `k · log 2 ≤ d`, so on that branch depth and distance are commensurable.
* `berggren_depth_logarithmic_reach` : **the `O(log N)` statement of the mission, in the
  only form in which it is true.**  For every `N` there is a Berggren node of hypotenuse
  `≥ N` at depth `k = ⌊log₂ N⌋`, and `k · log 2 ≤ log N`.

Together: reaching size `N` costs depth `Θ(log N)` at best (`berggren_depth_logarithmic_reach`
for the upper bound, `depth_ge_dist` for the matching lower bound), while an arbitrary node of
hypotenuse `N` can sit at depth as large as `Θ(√N)` (cycle I).
-/

namespace HyperbolicBerggrenGeodesics

open Real

/-! ## Part A. Reachability in the Berggren tree -/

/-- `Reaches p k` : the pair `p` is produced from the root Euclid seed `(2,1)` by exactly `k`
Berggren moves. -/
inductive Reaches : ℕ × ℕ → ℕ → Prop
  | root : Reaches (2, 1) 0
  | stepL {p k} : Reaches p k → Reaches (seedL p) (k + 1)
  | stepM {p k} : Reaches p k → Reaches (seedM p) (k + 1)
  | stepR {p k} : Reaches p k → Reaches (seedR p) (k + 1)

/-- **Soundness.**  Every reachable pair is a Euclid seed. -/
theorem reaches_isSeed {p : ℕ × ℕ} {k : ℕ} (h : Reaches p k) : IsSeed p.1 p.2 := by
  induction h with
  | root => exact isSeed_root
  | stepL _ ih => exact seedL_isSeed ih
  | stepM _ ih => exact seedM_isSeed ih
  | stepR _ ih => exact seedR_isSeed ih

/-- The hypotenuse of the Pythagorean triple attached to a pair. -/
def hypot (p : ℕ × ℕ) : ℕ := p.1 ^ 2 + p.2 ^ 2

/-! ## Part B. The inverse move, and completeness of the tree -/

/-- The **parent** of a Euclid seed `(M,N)`, i.e. the inverse Berggren move.  Which of the
three moves produced `(M,N)` is decided by the position of `M` relative to `2N` and `3N`
— equivalently by the position of the slope `N/M` relative to `1/2` and `1/3`. -/
def parentSeed (p : ℕ × ℕ) : ℕ × ℕ :=
  if 2 * p.2 < p.1 then
    (if 3 * p.2 < p.1 then (p.1 - 2 * p.2, p.2) else (p.2, p.1 - 2 * p.2))
  else (p.2, 2 * p.2 - p.1)

theorem parentSeed_seedL {m n : ℕ} (h : IsSeed m n) : parentSeed (seedL (m, n)) = (m, n) := by
  have h1 := h.pos
  have h2 := h.lt
  simp only [seedL, parentSeed]
  rw [if_neg (by omega), Prod.mk.injEq]
  omega

theorem parentSeed_seedM {m n : ℕ} (h : IsSeed m n) : parentSeed (seedM (m, n)) = (m, n) := by
  have h1 := h.pos
  have h2 := h.lt
  simp only [seedM, parentSeed]
  rw [if_pos (by omega), if_neg (by omega), Prod.mk.injEq]
  omega

theorem parentSeed_seedR {m n : ℕ} (h : IsSeed m n) : parentSeed (seedR (m, n)) = (m, n) := by
  have h1 := h.pos
  have h2 := h.lt
  simp only [seedR, parentSeed]
  rw [if_pos (by omega), if_pos (by omega), Prod.mk.injEq]
  omega

/-- A Euclid seed with `m = 2n` is the root. -/
theorem seed_two_mul_eq {m n : ℕ} (h : IsSeed m n) (hmn : m = 2 * n) : m = 2 ∧ n = 1 := by
  have : n ∣ Nat.gcd m n := Nat.dvd_gcd ⟨2, by omega⟩ dvd_rfl
  rw [h.cop] at this
  have hn : n = 1 := Nat.dvd_one.mp this
  exact ⟨by omega, hn⟩

/-- A Euclid seed never satisfies `m = 3n`: parity forbids it. -/
theorem seed_three_mul_ne {m n : ℕ} (h : IsSeed m n) : m ≠ 3 * n := by
  intro hmn
  have hd : n ∣ Nat.gcd m n := Nat.dvd_gcd ⟨3, by omega⟩ dvd_rfl
  rw [h.cop] at hd
  have hn : n = 1 := Nat.dvd_one.mp hd
  have := h.parity
  omega

/-- The parent of a non-root Euclid seed is a Euclid seed. -/
theorem parentSeed_isSeed {m n : ℕ} (h : IsSeed m n) (hroot : ¬ (m = 2 ∧ n = 1)) :
    IsSeed (parentSeed (m, n)).1 (parentSeed (m, n)).2 := by
  have hpos := h.pos
  have hlt := h.lt
  have hpar := h.parity
  have hne2 : m ≠ 2 * n := fun hc => hroot (seed_two_mul_eq h hc)
  have hne3 : m ≠ 3 * n := seed_three_mul_ne h
  by_cases hA : 2 * n < m
  · by_cases hB : 3 * n < m
    · -- came from `B₃`: parent `(m - 2n, n)`
      simp only [parentSeed, if_pos hA, if_pos hB]
      refine ⟨hpos, by omega, ?_, by omega⟩
      have hd : Nat.gcd (m - 2 * n) n ∣ m := by
        have h1 : Nat.gcd (m - 2 * n) n ∣ (m - 2 * n) + 2 * n :=
          Nat.dvd_add (Nat.gcd_dvd_left _ _) (Dvd.dvd.mul_left (Nat.gcd_dvd_right _ _) 2)
        simpa [Nat.sub_add_cancel (by omega : 2 * n ≤ m)] using h1
      have : Nat.gcd (m - 2 * n) n ∣ Nat.gcd m n :=
        Nat.dvd_gcd hd (Nat.gcd_dvd_right _ _)
      rw [h.cop] at this
      exact Nat.dvd_one.mp this
    · -- came from `B₂`: parent `(n, m - 2n)`
      simp only [parentSeed, if_pos hA, if_neg hB]
      refine ⟨by omega, by omega, ?_, by omega⟩
      have hd : Nat.gcd n (m - 2 * n) ∣ m := by
        have h1 : Nat.gcd n (m - 2 * n) ∣ (m - 2 * n) + 2 * n :=
          Nat.dvd_add (Nat.gcd_dvd_right _ _) (Dvd.dvd.mul_left (Nat.gcd_dvd_left _ _) 2)
        simpa [Nat.sub_add_cancel (by omega : 2 * n ≤ m)] using h1
      have : Nat.gcd n (m - 2 * n) ∣ Nat.gcd m n :=
        Nat.dvd_gcd hd (Nat.gcd_dvd_left _ _)
      rw [h.cop] at this
      exact Nat.dvd_one.mp this
  · -- came from `B₁`: parent `(n, 2n - m)`
    simp only [parentSeed, if_neg hA]
    refine ⟨by omega, by omega, ?_, by omega⟩
    have hd : Nat.gcd n (2 * n - m) ∣ m := by
      have h1 : Nat.gcd n (2 * n - m) ∣ 2 * n - (2 * n - m) :=
        Nat.dvd_sub (Dvd.dvd.mul_left (Nat.gcd_dvd_left _ _) 2) (Nat.gcd_dvd_right _ _)
      simpa [Nat.sub_sub_self (by omega : m ≤ 2 * n)] using h1
    have : Nat.gcd n (2 * n - m) ∣ Nat.gcd m n :=
      Nat.dvd_gcd hd (Nat.gcd_dvd_left _ _)
    rw [h.cop] at this
    exact Nat.dvd_one.mp this

/-- The parent of a non-root Euclid seed is strictly smaller in its first coordinate. -/
theorem parentSeed_fst_lt {m n : ℕ} (h : IsSeed m n) : (parentSeed (m, n)).1 < m := by
  have hpos := h.pos
  have hlt := h.lt
  by_cases hA : 2 * n < m
  · by_cases hB : 3 * n < m
    · simp only [parentSeed, if_pos hA, if_pos hB]; omega
    · simp only [parentSeed, if_pos hA, if_neg hB]; omega
  · simp only [parentSeed, if_neg hA]; omega

/-- Every non-root Euclid seed is one of the three Berggren children of its parent. -/
theorem seed_eq_child_parentSeed {m n : ℕ} (h : IsSeed m n) :
    (m, n) = seedL (parentSeed (m, n)) ∨ (m, n) = seedM (parentSeed (m, n)) ∨
      (m, n) = seedR (parentSeed (m, n)) := by
  have hpos := h.pos
  have hlt := h.lt
  by_cases hA : 2 * n < m
  · by_cases hB : 3 * n < m
    · refine Or.inr (Or.inr ?_)
      simp only [parentSeed, if_pos hA, if_pos hB, seedR, Prod.mk.injEq, and_true]
      omega
    · refine Or.inr (Or.inl ?_)
      simp only [parentSeed, if_pos hA, if_neg hB, seedM, Prod.mk.injEq, and_true]
      omega
  · refine Or.inl ?_
    simp only [parentSeed, if_neg hA, seedL, Prod.mk.injEq, and_true]
    omega

/-- **Completeness of the Berggren tree.**  Every Euclid seed is reachable from the root
`(2,1)` by finitely many Berggren moves. -/
theorem seed_reaches : ∀ (m : ℕ), ∀ (n : ℕ), IsSeed m n → ∃ k, Reaches (m, n) k := by
  intro m
  induction m using Nat.strong_induction_on with
  | _ m ih =>
    intro n h
    by_cases hroot : m = 2 ∧ n = 1
    · exact ⟨0, by rw [hroot.1, hroot.2]; exact Reaches.root⟩
    · obtain ⟨k, hk⟩ :=
        ih (parentSeed (m, n)).1 (parentSeed_fst_lt h) (parentSeed (m, n)).2
          (parentSeed_isSeed h hroot)
      rcases seed_eq_child_parentSeed h with hc | hc | hc
      · exact ⟨k + 1, by rw [hc]; exact Reaches.stepL hk⟩
      · exact ⟨k + 1, by rw [hc]; exact Reaches.stepM hk⟩
      · exact ⟨k + 1, by rw [hc]; exact Reaches.stepR hk⟩

/-! ## Part C. Uniqueness of the depth -/

/-- A node at positive depth is not the root. -/
theorem reaches_succ_ne_root {p : ℕ × ℕ} {k : ℕ} (h : Reaches p (k + 1)) : ¬ (p = (2, 1)) := by
  cases h with
  | @stepL q j hq =>
      have hs := reaches_isSeed hq
      intro hc
      have h1 : (seedL q).2 = q.1 := rfl
      have h2 : q.1 = 1 := by rw [← h1, hc]
      have := hs.pos
      have := hs.lt
      omega
  | @stepM q j hq =>
      have hs := reaches_isSeed hq
      intro hc
      have h1 : (seedM q).2 = q.1 := rfl
      have h2 : q.1 = 1 := by rw [← h1, hc]
      have := hs.pos
      have := hs.lt
      omega
  | @stepR q j hq =>
      have hs := reaches_isSeed hq
      intro hc
      have h1 : (seedR q).1 = q.1 + 2 * q.2 := rfl
      have h2 : q.1 + 2 * q.2 = 2 := by rw [← h1, hc]
      have := hs.pos
      have := hs.lt
      omega

/-- One step back: a node at depth `k+1` has its parent at depth `k`. -/
theorem reaches_parent {p : ℕ × ℕ} {k : ℕ} (h : Reaches p (k + 1)) :
    Reaches (parentSeed p) k := by
  cases h with
  | @stepL q j hq =>
      have hs := reaches_isSeed hq
      rw [show q = (q.1, q.2) from rfl] at hq ⊢
      rw [parentSeed_seedL hs]
      exact hq
  | @stepM q j hq =>
      have hs := reaches_isSeed hq
      rw [show q = (q.1, q.2) from rfl] at hq ⊢
      rw [parentSeed_seedM hs]
      exact hq
  | @stepR q j hq =>
      have hs := reaches_isSeed hq
      rw [show q = (q.1, q.2) from rfl] at hq ⊢
      rw [parentSeed_seedR hs]
      exact hq

/-- **The Berggren tree is a tree.**  A Euclid seed is reachable at exactly one depth; hence
`depth` is a well-defined function on the set of seeds. -/
theorem reaches_unique : ∀ (k j : ℕ) (p : ℕ × ℕ), Reaches p k → Reaches p j → k = j := by
  intro k
  induction k with
  | zero =>
      intro j p h0 hj
      cases j with
      | zero => rfl
      | succ j =>
          exfalso
          cases h0
          exact reaches_succ_ne_root hj rfl
  | succ k ih =>
      intro j p hk hj
      cases j with
      | zero =>
          exfalso
          cases hj
          exact reaches_succ_ne_root hk rfl
      | succ j =>
          have h1 := reaches_parent hk
          have h2 := reaches_parent hj
          exact congrArg Nat.succ (ih j _ h1 h2)

/-! ## Part D. Depth versus size: the lower bound -/

/-- A node at depth `k` has first coordinate at most `2·3^k`: each Berggren move at most
triples `m`. -/
theorem reaches_fst_le {p : ℕ × ℕ} {k : ℕ} (h : Reaches p k) : p.1 ≤ 2 * 3 ^ k := by
  induction h with
  | root => simp
  | @stepL q k hq ih =>
      have hs := reaches_isSeed hq
      have : (seedL q).1 = 2 * q.1 - q.2 := rfl
      rw [this, pow_succ]
      omega
  | @stepM q k hq ih =>
      have hs := reaches_isSeed hq
      have : (seedM q).1 = 2 * q.1 + q.2 := rfl
      rw [this, pow_succ]
      have := hs.lt
      omega
  | @stepR q k hq ih =>
      have hs := reaches_isSeed hq
      have : (seedR q).1 = q.1 + 2 * q.2 := rfl
      rw [this, pow_succ]
      have := hs.lt
      omega

/-- A node at depth `k` has hypotenuse at most `8·9^k`. -/
theorem reaches_hypot_le {p : ℕ × ℕ} {k : ℕ} (h : Reaches p k) : hypot p ≤ 8 * 9 ^ k := by
  have hm := reaches_fst_le h
  have hs := reaches_isSeed h
  have hn : p.2 < p.1 := hs.lt
  have h9 : (9 : ℕ) ^ k = (3 ^ k) ^ 2 := by
    rw [← pow_mul, mul_comm, pow_mul]
    norm_num
  have : hypot p ≤ 2 * p.1 ^ 2 := by
    simp only [hypot]
    nlinarith
  calc hypot p ≤ 2 * p.1 ^ 2 := this
    _ ≤ 2 * (2 * 3 ^ k) ^ 2 := by nlinarith
    _ = 8 * 9 ^ k := by rw [h9]; ring

/-- The logarithmic form of the size bound: at depth `k` the hypotenuse satisfies
`log c ≤ log 8 + k · log 9`. -/
theorem reaches_log_hypot_le {p : ℕ × ℕ} {k : ℕ} (h : Reaches p k) :
    Real.log ((p.1 : ℝ) ^ 2 + (p.2 : ℝ) ^ 2) ≤ Real.log 8 + k * Real.log 9 := by
  have hnat := reaches_hypot_le h
  have hs := reaches_isSeed h
  have hpos : 0 < p.1 := lt_trans hs.pos hs.lt
  have hc : ((p.1 : ℝ) ^ 2 + (p.2 : ℝ) ^ 2) ≤ 8 * 9 ^ k := by
    have : ((hypot p : ℕ) : ℝ) ≤ ((8 * 9 ^ k : ℕ) : ℝ) := by exact_mod_cast hnat
    simpa [hypot] using this
  have hcpos : (0 : ℝ) < (p.1 : ℝ) ^ 2 + (p.2 : ℝ) ^ 2 := by
    have : (0 : ℝ) < (p.1 : ℝ) := by exact_mod_cast hpos
    positivity
  calc Real.log ((p.1 : ℝ) ^ 2 + (p.2 : ℝ) ^ 2)
      ≤ Real.log (8 * 9 ^ k) := Real.log_le_log hcpos hc
    _ = Real.log 8 + k * Real.log 9 := by
        rw [Real.log_mul (by norm_num) (by positivity), Real.log_pow]

/-- **The hyperbolic distance is a lower bound for the depth.**  If a node sits at depth `k`
in the Berggren tree then `2 · d(i, z) ≤ log 32 + k · log 9`.  Together with
`depth_not_bounded_by_distance` (cycle I), which shows no reverse inequality can hold, this
pins down exactly the relation between the metric and the combinatorics. -/
theorem dist_le_depth {p : ℕ × ℕ} {k : ℕ} (h : Reaches p k) :
    2 * dist (hpoint p.1 p.2 (lt_trans (reaches_isSeed h).pos (reaches_isSeed h).lt))
      UpperHalfPlane.I ≤ Real.log 32 + k * Real.log 9 := by
  have hs := reaches_isSeed h
  have habs := hyperbolic_dist_eq_half_log_hypotenuse (m := p.1) (n := p.2) hs.pos hs.lt
  have hlog := reaches_log_hypot_le h
  have h32 : Real.log 32 = Real.log 8 + 2 * Real.log 2 := by
    rw [show (32 : ℝ) = 8 * 2 ^ 2 by norm_num, Real.log_mul (by norm_num) (by norm_num),
      Real.log_pow]
    push_cast
    ring
  have h1 := (abs_le.mp habs).2
  rw [h32]
  linarith

/-- The same statement solved for the depth: `k ≥ (2d − log 32)/log 9`. -/
theorem depth_ge_dist {p : ℕ × ℕ} {k : ℕ} (h : Reaches p k) :
    (2 * dist (hpoint p.1 p.2 (lt_trans (reaches_isSeed h).pos (reaches_isSeed h).lt))
      UpperHalfPlane.I - Real.log 32) / Real.log 9 ≤ (k : ℝ) := by
  have h9 : 0 < Real.log 9 := Real.log_pos (by norm_num)
  rw [div_le_iff₀ h9]
  have := dist_le_depth h
  linarith

/-! ## Part E. Depth versus size: the matching upper bound along the Pell spine -/

/-- The **middle spine**: iterate the Berggren move `B₂` from the root.  Its first
coordinates `2, 5, 12, 29, 70, …` are the Pell numbers. -/
def mspine : ℕ → ℕ × ℕ
  | 0 => (2, 1)
  | k + 1 => seedM (mspine k)

theorem mspine_reaches (k : ℕ) : Reaches (mspine k) k := by
  induction k with
  | zero => exact Reaches.root
  | succ k ih => exact Reaches.stepM ih

theorem mspine_isSeed (k : ℕ) : IsSeed (mspine k).1 (mspine k).2 :=
  reaches_isSeed (mspine_reaches k)

/-- The middle spine grows at least geometrically: `m_k ≥ 2^{k+1}`. -/
theorem mspine_fst_ge (k : ℕ) : 2 ^ (k + 1) ≤ (mspine k).1 := by
  induction k with
  | zero => simp [mspine]
  | succ k ih =>
      have hs := mspine_isSeed k
      have h1 : (mspine (k + 1)).1 = 2 * (mspine k).1 + (mspine k).2 := rfl
      rw [h1, pow_succ]
      have := hs.pos
      omega

/-- Consequently the hypotenuse along the middle spine is at least `4^{k+1}`. -/
theorem mspine_hypot_ge (k : ℕ) : 4 ^ (k + 1) ≤ hypot (mspine k) := by
  have h := mspine_fst_ge k
  have h4 : (4 : ℕ) ^ (k + 1) = (2 ^ (k + 1)) ^ 2 := by
    rw [← pow_mul, mul_comm, pow_mul]
    norm_num
  calc (4 : ℕ) ^ (k + 1) = (2 ^ (k + 1)) ^ 2 := h4
    _ ≤ (mspine k).1 ^ 2 := Nat.pow_le_pow_left h 2
    _ ≤ hypot (mspine k) := by simp [hypot]

/-- Along the middle spine the hyperbolic distance grows at least linearly in the depth:
`k · log 2 ≤ d(i, z_k)`.  So on this branch depth and distance are commensurable, and the
lower bound `dist_le_depth` is attained up to constants. -/
theorem mspine_dist_ge (k : ℕ) :
    (k : ℝ) * Real.log 2 ≤
      dist (hpoint (mspine k).1 (mspine k).2
        (lt_trans (mspine_isSeed k).pos (mspine_isSeed k).lt)) UpperHalfPlane.I := by
  have hs := mspine_isSeed k
  have habs := hyperbolic_dist_eq_half_log_hypotenuse (m := (mspine k).1) (n := (mspine k).2)
    hs.pos hs.lt
  have h1 := (abs_le.mp habs).1
  have hnat := mspine_hypot_ge k
  have hc : (4 : ℝ) ^ (k + 1) ≤ ((mspine k).1 : ℝ) ^ 2 + ((mspine k).2 : ℝ) ^ 2 := by
    have : ((4 ^ (k + 1) : ℕ) : ℝ) ≤ ((hypot (mspine k) : ℕ) : ℝ) := by exact_mod_cast hnat
    simpa [hypot] using this
  have hlog : Real.log ((4 : ℝ) ^ (k + 1)) ≤
      Real.log (((mspine k).1 : ℝ) ^ 2 + ((mspine k).2 : ℝ) ^ 2) :=
    Real.log_le_log (by positivity) hc
  have h4 : Real.log ((4 : ℝ) ^ (k + 1)) = ((k : ℝ) + 1) * (2 * Real.log 2) := by
    rw [Real.log_pow, show (4 : ℝ) = 2 ^ 2 by norm_num, Real.log_pow]
    push_cast
    ring
  rw [h4] at hlog
  linarith

/-- **The `O(log N)` reach theorem.**  For every target size `N` there is a Berggren node of
hypotenuse at least `N` at depth `k = ⌊log₂ N⌋`, and this depth satisfies
`k · log 2 ≤ log N` for `N ≥ 1`.  This is the mission's "sub-linear path length `O(log N)`"
in the only form in which it is true: *reaching* size `N` is logarithmically cheap, even
though an arbitrary node of that size can lie exponentially deeper (cycle I). -/
theorem berggren_depth_logarithmic_reach (N : ℕ) (hN : 1 ≤ N) :
    ∃ (k : ℕ) (p : ℕ × ℕ), Reaches p k ∧ N ≤ hypot p ∧ (k : ℝ) * Real.log 2 ≤ Real.log N := by
  refine ⟨Nat.log 2 N, mspine (Nat.log 2 N), mspine_reaches _, ?_, ?_⟩
  · have h1 : N < 2 ^ (Nat.log 2 N + 1) := Nat.lt_pow_succ_log_self (by norm_num) N
    have h2 : 2 ^ (Nat.log 2 N + 1) ≤ 4 ^ (Nat.log 2 N + 1) :=
      Nat.pow_le_pow_left (by norm_num) _
    have h3 := mspine_hypot_ge (Nat.log 2 N)
    omega
  · have hpow : 2 ^ Nat.log 2 N ≤ N := Nat.pow_log_le_self 2 (by omega)
    have hR : ((2 : ℝ)) ^ (Nat.log 2 N) ≤ (N : ℝ) := by exact_mod_cast hpow
    have := Real.log_le_log (by positivity) hR
    rwa [Real.log_pow] at this

/-! ## Part F. Depth is not governed by the continued fraction of the slope

The natural guess (conjecture **G1** of `FUTURE_DIRECTIONS.md`) is that a Berggren path is
the additive continued-fraction expansion of the slope `n/m`, so that the depth should equal
the sum of the partial quotients up to a bounded error, or at least up to a fixed
proportionality constant.  This is **false**, and the reason is structural: the move `B₃`
adds `2` to `m/n`, so a long run of `B₃`'s costs only *half* a partial quotient per step,
while the move `B₁` accumulates at the parabolic fixed point `n/m = 1` and costs a *whole*
partial quotient per step.  The two pure spines therefore realise two different
proportionality constants, and no single law can hold. -/

/-- The sum of the partial quotients of the continued fraction of `n/m`
(`cfSum n m = a₁ + a₂ + ⋯` when `n < m`). -/
def cfSum : ℕ → ℕ → ℕ
  | _, 0 => 0
  | n, (m + 1) => n / (m + 1) + cfSum (m + 1) (n % (m + 1))
  termination_by _ m => m
  decreasing_by exact Nat.mod_lt _ (Nat.succ_pos m)

theorem cfSum_zero (n : ℕ) : cfSum n 0 = 0 := by rw [cfSum]

theorem cfSum_succ (n m : ℕ) :
    cfSum n (m + 1) = n / (m + 1) + cfSum (m + 1) (n % (m + 1)) := by rw [cfSum]

theorem cfSum_one_left (M : ℕ) : cfSum M 1 = M := by
  rw [cfSum_succ M 0, Nat.mod_one, cfSum_zero]
  simp

/-- `1/M = [0; M]`. -/
theorem cfSum_one (M : ℕ) (hM : 0 < M) : cfSum 1 M = M := by
  obtain ⟨M', rfl⟩ : ∃ M', M = M' + 1 := ⟨M - 1, by omega⟩
  rcases Nat.eq_zero_or_pos M' with rfl | hM'
  · simpa using cfSum_one_left 1
  · rw [cfSum_succ, Nat.div_eq_of_lt (by omega), Nat.mod_eq_of_lt (by omega), cfSum_one_left]
    omega

/-- `(k+1)/(k+2) = [0; 1, k+1]`, of partial-quotient sum `k + 2`. -/
theorem cfSum_consec (k : ℕ) : cfSum (k + 1) (k + 2) = k + 2 := by
  rw [show k + 2 = (k + 1) + 1 from rfl, cfSum_succ, Nat.div_eq_of_lt (by omega),
    Nat.mod_eq_of_lt (by omega)]
  rcases Nat.eq_zero_or_pos k with rfl | hk
  · norm_num [cfSum_one_left]
  · have hd : (k + 2) / (k + 1) = 1 := by
      refine Nat.div_eq_of_lt_le ?_ ?_ <;> omega
    have hm : (k + 2) % (k + 1) = 1 := by
      rw [Nat.mod_eq_sub_mod (by omega), show k + 2 - (k + 1) = 1 from by omega,
        Nat.mod_eq_of_lt (by omega)]
    rw [cfSum_succ (k + 2) k, hd, hm, cfSum_one_left]
    omega

/-- The **right spine**: `k` applications of `B₃` to the root give `(2k+2, 1)`, slope
`1/(2k+2)`, whose single partial quotient is `2k+2 = 2·depth + 2`. -/
theorem rspine_reaches (k : ℕ) : Reaches (2 * k + 2, 1) k := by
  induction k with
  | zero => exact Reaches.root
  | succ k ih =>
      have h : Reaches (seedR (2 * k + 2, 1)) (k + 1) := Reaches.stepR ih
      have he : seedR (2 * k + 2, 1) = (2 * (k + 1) + 2, 1) := by
        simp only [seedR, Prod.mk.injEq, and_true]
        omega
      rwa [he] at h

/-- The **left spine**: `k` applications of `B₁` to the root give `(k+2, k+1)`, slope
`(k+1)/(k+2)`, whose partial quotients sum to `k + 2 = depth + 2`. -/
theorem lspine_reaches (k : ℕ) : Reaches (k + 2, k + 1) k := by
  induction k with
  | zero => exact Reaches.root
  | succ k ih =>
      have h : Reaches (seedL (k + 2, k + 1)) (k + 1) := Reaches.stepL ih
      have he : seedL (k + 2, k + 1) = (k + 1 + 2, k + 1 + 1) := by
        simp only [seedL, Prod.mk.injEq, and_true]
        omega
      rwa [he] at h

/-- **Refutation of the continued-fraction law for the depth (conjecture G1).**
There is *no* constant `λ ≥ 0` for which the depth of a Berggren node equals `λ` times the
sum of the partial quotients of its slope up to a bounded error.  The obstruction is
explicit: along the right spine the ratio is `1/2`, along the left spine it is `1`, and the
linear combination `(depth − λ·cfSum)` of the two families forces `k ≤ 3C + 2λ` for every
`k`. -/
theorem no_universal_depth_cfSum_law (lam C : ℝ) (hlam : 0 ≤ lam) :
    ¬ ∀ (m n k : ℕ), Reaches (m, n) k → |(k : ℝ) - lam * (cfSum n m : ℝ)| ≤ C := by
  intro H
  obtain ⟨k, hk⟩ := exists_nat_gt (3 * (C + 2 * lam))
  have h1 := H (2 * k + 2) 1 k (rspine_reaches k)
  have h2 := H (k + 2) (k + 1) k (lspine_reaches k)
  rw [cfSum_one _ (by omega)] at h1
  rw [cfSum_consec] at h2
  have h1' : |(k : ℝ) - lam * (2 * (k : ℝ) + 2)| ≤ C := by
    have : ((2 * k + 2 : ℕ) : ℝ) = 2 * (k : ℝ) + 2 := by push_cast; ring
    rwa [this] at h1
  have h2' : |(k : ℝ) - lam * ((k : ℝ) + 2)| ≤ C := by
    have : ((k + 2 : ℕ) : ℝ) = (k : ℝ) + 2 := by push_cast; ring
    rwa [this] at h2
  obtain ⟨hX1, hX2⟩ := abs_le.mp h1'
  obtain ⟨hY1, hY2⟩ := abs_le.mp h2'
  -- `2·(k − λ(k+2)) − (k − λ(2k+2)) = k − 2λ`, so `k ≤ 3C + 2λ`
  nlinarith [hk, hlam]

/-! ## Part G. Non-vacuity witnesses -/

/-- The seed `(12,5)` — hypotenuse `169 = 13²` — is reached in two `B₂` moves. -/
theorem reaches_twelve_five : Reaches (12, 5) 2 := by
  have h : Reaches (mspine 2) 2 := mspine_reaches 2
  simpa [mspine, seedM] using h

/-- …and at no other depth: the depth function is genuinely single-valued on a concrete seed. -/
theorem depth_twelve_five {k : ℕ} (h : Reaches (12, 5) k) : k = 2 :=
  reaches_unique k 2 (12, 5) h reaches_twelve_five

/-- The seed `(4,3)` — the triple `(7,24,25)` — is reached in two `B₁` moves, so two different
branches genuinely occur at the same depth. -/
theorem reaches_four_three : Reaches (4, 3) 2 := by
  have h : Reaches (seedL (seedL (2, 1))) (0 + 1 + 1) :=
    Reaches.stepL (Reaches.stepL Reaches.root)
  simpa [seedL] using h

end HyperbolicBerggrenGeodesics