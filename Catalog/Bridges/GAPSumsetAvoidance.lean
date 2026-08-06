/-
# δ-dense sets avoiding sumsets of generalised arithmetic progressions

This file extends `Bridges/DeltaDenseSumsetAvoidance.lean` from ordinary arithmetic
progressions to *generalised* arithmetic progressions (GAPs).

A GAP of dimension `r`, side length `k` and generators `d 0, …, d (r-1)` is
`a + {x₀ d₀ + ⋯ + x_{r-1} d_{r-1} : 0 ≤ xᵢ < k}` (`DeltaDense.gapF`).  Sumsets of two
GAPs are again GAPs, of dimension the sum of the dimensions, and the key geometric
observation is that a GAP of dimension `R` and side `k` always contains a *staircase*:
walk `k-1` steps along `d 0`, then `k-1` steps along `d 1`, and so on.  The staircase
is strictly increasing, so it has exactly `R(k-1)+1` points, and it is described by only
`R + 1` parameters `(t, d 0, …, d (R-1))`.  Hence the first-moment/union bound over all
staircases inside `[n]` costs only `n^{R+1}`, and the same counting engine
(`DeltaDense.exists_card_eq_avoiding_family`, `DeltaDense.pow_cond`) applies.

The main result, `DeltaDense.exists_dense_avoiding_gap_sumsets`, is that for every
`0 < δ < 1`, every large `n` and every pair of dimensions `r, s` with `1 ≤ r+s ≤ 9`
there is `S ⊆ [n]` with `|S| ≥ δn` containing **no** sumset of a dimension-`r` and a
dimension-`s` GAP of common side length `k ≥ 3 log n / log (1/δ)` — the same constant
`C(δ) = 3` as in the one-dimensional case, uniformly in the dimension.

Taking `r = s = 1` recovers the two-progression statement
(`DeltaDense.exists_dense_avoiding_ap_sumsets_of_gap`), and taking `r = 0` allows a
completely arbitrary first summand (`DeltaDense.exists_dense_no_sumset_with_gap`).
Finally `DeltaDense.S16_no_gap_sumset` verifies the phenomenon on the explicit
density-`1/2` set `{0,1,3,6,8,12,13,14} ⊆ [16]`, for GAPs of arbitrary dimension.
-/
import Bridges.DeltaDenseSumsetAvoidance
import Bridges.DeltaDenseSumsetAvoidanceExample

namespace DeltaDense

open Finset Pointwise

/-! ## Staircases -/

/-- The `j`-th corner of the staircase starting at `t` with side length `k` and step
sequence `d`: `stairBase t k d j = t + (k-1)·(d 0 + ⋯ + d (j-1))`. -/
def stairBase (t k : ℕ) (d : ℕ → ℕ) : ℕ → ℕ
  | 0 => t
  | j + 1 => stairBase t k d j + d j * (k - 1)

/-- The staircase with `r` arms: starting at `t`, walk `k-1` steps of size `d 0`, then
`k-1` steps of size `d 1`, and so on.  Consecutive arms meet exactly at a corner, so the
staircase has `r(k-1)+1` points (`card_staircase`). -/
def staircase (t k : ℕ) (d : ℕ → ℕ) (r : ℕ) : Finset ℕ :=
  insert t ((range r).biUnion fun j => apF (stairBase t k d j) (d j) k)

lemma stairBase_mono (t k : ℕ) (d : ℕ → ℕ) {j j' : ℕ} (h : j ≤ j') :
    stairBase t k d j ≤ stairBase t k d j' := by
  induction j' with
  | zero => simp_all
  | succ p ih =>
      rcases Nat.lt_or_ge j (p + 1) with hlt | hge
      · exact le_trans (ih (by omega)) (by simp [stairBase])
      · have : j = p + 1 := by omega
        simp [this]

lemma le_stairBase (t k : ℕ) (d : ℕ → ℕ) (j : ℕ) : t ≤ stairBase t k d j :=
  stairBase_mono t k d (Nat.zero_le j)

lemma mem_apF_bounds {a d k x : ℕ} (hx : x ∈ apF a d k) : a ≤ x ∧ x ≤ a + d * (k - 1) := by
  obtain ⟨i, hi, rfl⟩ := mem_apF.1 hx
  exact ⟨by omega, by have : d * i ≤ d * (k - 1) := Nat.mul_le_mul_left _ (by omega); omega⟩

lemma mem_staircase_le {t k : ℕ} {d : ℕ → ℕ} {r x : ℕ} (hx : x ∈ staircase t k d r) :
    t ≤ x ∧ x ≤ stairBase t k d r := by
  rw [staircase, Finset.mem_insert] at hx
  rcases hx with rfl | hx
  · exact ⟨le_rfl, le_stairBase _ _ _ _⟩
  · obtain ⟨j, hj, hxj⟩ := Finset.mem_biUnion.1 hx
    rw [Finset.mem_range] at hj
    obtain ⟨h1, h2⟩ := mem_apF_bounds hxj
    refine ⟨le_trans (le_stairBase _ _ _ _) h1, le_trans h2 ?_⟩
    have : stairBase t k d j + d j * (k - 1) = stairBase t k d (j + 1) := rfl
    rw [this]
    exact stairBase_mono t k d (by omega)

lemma stairBase_mem_staircase {t k : ℕ} {d : ℕ → ℕ} {r j : ℕ} (hk : 1 ≤ k) (hj : j ≤ r) :
    stairBase t k d j ∈ staircase t k d r := by
  cases j with
  | zero => exact Finset.mem_insert_self _ _
  | succ p =>
      refine Finset.mem_insert_of_mem (Finset.mem_biUnion.2 ⟨p, Finset.mem_range.2 (by omega), ?_⟩)
      exact mem_apF.2 ⟨k - 1, by omega, rfl⟩

lemma staircase_succ (t k : ℕ) (d : ℕ → ℕ) (r : ℕ) :
    staircase t k d (r + 1) = staircase t k d r ∪ apF (stairBase t k d r) (d r) k := by
  ext x
  simp only [staircase, Finset.range_add_one, Finset.biUnion_insert, Finset.mem_insert,
    Finset.mem_union, Finset.mem_biUnion, Finset.mem_range]
  constructor
  · rintro (h | h | h)
    exacts [Or.inl (Or.inl h), Or.inr h, Or.inl (Or.inr h)]
  · rintro ((h | h) | h)
    exacts [Or.inl h, Or.inr (Or.inr h), Or.inr (Or.inl h)]

/-- A staircase with positive steps has exactly `r(k-1)+1` points. -/
lemma card_staircase {t k : ℕ} {d : ℕ → ℕ} {r : ℕ} (hk : 1 ≤ k) (hd : ∀ j < r, 0 < d j) :
    (staircase t k d r).card = r * (k - 1) + 1 := by
  induction r with
  | zero => simp [staircase]
  | succ p ih =>
      have ihp := ih (fun j hj => hd j (by omega))
      set A := staircase t k d p with hA
      set B := apF (stairBase t k d p) (d p) k with hB
      have hinter : A ∩ B ⊆ {stairBase t k d p} := by
        intro x hx
        rw [Finset.mem_inter] at hx
        have h1 := (mem_staircase_le hx.1).2
        have h2 := (mem_apF_bounds hx.2).1
        rw [Finset.mem_singleton]
        omega
      have hmem : stairBase t k d p ∈ A ∩ B :=
        Finset.mem_inter.2 ⟨stairBase_mem_staircase hk le_rfl, self_mem_apF (by omega)⟩
      have hcard1 : (A ∩ B).card = 1 := by
        refine le_antisymm (le_trans (Finset.card_le_card hinter) (by simp)) ?_
        exact Finset.card_pos.2 ⟨_, hmem⟩
      have hcB : B.card = k := card_apF _ (hd p (by omega)) _
      have hun := Finset.card_union_add_card_inter A B
      rw [staircase_succ]
      have : (A ∪ B).card = p * (k - 1) + 1 + k - 1 := by omega
      rw [← hA, ← hB, this]
      have : 1 ≤ k := hk
      cases k with
      | zero => omega
      | succ q => simp; ring

/-- A two-armed staircase is exactly the "L-shaped" witness of
`Bridges/DeltaDenseSumsetAvoidance.lean`. -/
lemma staircase_two {t k : ℕ} {d : ℕ → ℕ} (hk : 1 ≤ k) :
    staircase t k d 2 = gridWitness t (d 0) (d 1) k := by
  have hbase : stairBase t k d 1 = t + d 0 * (k - 1) := rfl
  ext x
  simp only [staircase, gridWitness, Finset.mem_insert, Finset.mem_biUnion, Finset.mem_range,
    Finset.mem_union]
  constructor
  · rintro (rfl | ⟨j, hj, hxj⟩)
    · exact Or.inl (self_mem_apF (by omega))
    · interval_cases j
      · exact Or.inl hxj
      · exact Or.inr (by rwa [hbase] at hxj)
  · rintro (h | h)
    · exact Or.inr ⟨0, by omega, h⟩
    · exact Or.inr ⟨1, by omega, by rwa [hbase]⟩

lemma stairBase_congr {t k : ℕ} {d d' : ℕ → ℕ} {r : ℕ} (h : ∀ j < r, d j = d' j) :
    ∀ j ≤ r, stairBase t k d j = stairBase t k d' j := by
  intro j hj
  induction j with
  | zero => rfl
  | succ p ih =>
      have hp := ih (by omega)
      simp only [stairBase, hp, h p (by omega)]

lemma staircase_congr {t k : ℕ} {d d' : ℕ → ℕ} {r : ℕ} (h : ∀ j < r, d j = d' j) :
    staircase t k d r = staircase t k d' r := by
  refine congrArg (insert t) (Finset.biUnion_congr rfl fun j hj => ?_)
  rw [Finset.mem_range] at hj
  rw [stairBase_congr h j (by omega), h j hj]

/-! ## Generalised arithmetic progressions -/

/-- The generalised arithmetic progression of dimension `r`, side length `k`, base point
`a` and generators `d 0, …, d (r-1)`:
`gapF a k d r = a + {x₀ d₀ + ⋯ + x_{r-1} d_{r-1} : 0 ≤ xᵢ < k}`. -/
def gapF (a k : ℕ) (d : ℕ → ℕ) : ℕ → Finset ℕ
  | 0 => {a}
  | r + 1 => gapF a k d r + apF 0 (d r) k

lemma gapF_succ (a k : ℕ) (d : ℕ → ℕ) (r : ℕ) :
    gapF a k d (r + 1) = gapF a k d r + apF 0 (d r) k := rfl

/-- A one-dimensional GAP is an ordinary arithmetic progression. -/
lemma gapF_one (a k : ℕ) (d : ℕ → ℕ) : gapF a k d 1 = apF a (d 0) k := by
  ext x
  simp only [gapF, Finset.mem_add, Finset.mem_singleton, mem_apF]
  constructor
  · rintro ⟨u, hu, v, ⟨i, hi, rfl⟩, rfl⟩
    exact ⟨i, hi, by omega⟩
  · rintro ⟨i, hi, rfl⟩
    exact ⟨a, rfl, d 0 * i, ⟨i, hi, by omega⟩, by omega⟩

lemma gapF_mono_dim {a k : ℕ} {d : ℕ → ℕ} (hk : 1 ≤ k) {r r' : ℕ} (h : r ≤ r') :
    gapF a k d r ⊆ gapF a k d r' := by
  induction r' with
  | zero => simp_all
  | succ p ih =>
      rcases Nat.lt_or_ge r (p + 1) with hlt | hge
      · refine (ih (by omega)).trans ?_
        intro x hx
        rw [gapF_succ]
        have : x + 0 ∈ gapF a k d p + apF 0 (d p) k :=
          Finset.add_mem_add hx (self_mem_apF (by omega))
        simpa using this
      · have : r = p + 1 := by omega
        simp [this]

lemma gapF_mono_side {a : ℕ} {d : ℕ → ℕ} {k k' : ℕ} (h : k ≤ k') (r : ℕ) :
    gapF a k d r ⊆ gapF a k' d r := by
  induction r with
  | zero => simp [gapF]
  | succ p ih =>
      rw [gapF_succ, gapF_succ]
      exact Finset.add_subset_add ih (apF_mono _ _ h)

lemma stairBase_mem_gapF {a k : ℕ} {d : ℕ → ℕ} (hk : 1 ≤ k) {r j : ℕ} (hj : j ≤ r) :
    stairBase a k d j ∈ gapF a k d r := by
  induction j generalizing r with
  | zero => exact gapF_mono_dim hk (Nat.zero_le r) (by simp [gapF, stairBase])
  | succ p ih =>
      have hmem : stairBase a k d p + d p * (k - 1) ∈ gapF a k d (p + 1) := by
        rw [gapF_succ]
        exact Finset.add_mem_add (ih le_rfl) (mem_apF.2 ⟨k - 1, by omega, by omega⟩)
      exact gapF_mono_dim hk hj hmem

lemma arm_subset_gapF {a k : ℕ} {d : ℕ → ℕ} (hk : 1 ≤ k) {r j : ℕ} (hj : j < r) :
    apF (stairBase a k d j) (d j) k ⊆ gapF a k d r := by
  intro x hx
  obtain ⟨i, hi, rfl⟩ := mem_apF.1 hx
  refine gapF_mono_dim hk (show j + 1 ≤ r by omega) ?_
  rw [gapF_succ]
  exact Finset.add_mem_add (stairBase_mem_gapF hk le_rfl) (mem_apF.2 ⟨i, hi, by omega⟩)

/-- A GAP contains its own staircase. -/
lemma staircase_subset_gapF {a k : ℕ} {d : ℕ → ℕ} (hk : 1 ≤ k) (r : ℕ) :
    staircase a k d r ⊆ gapF a k d r := by
  intro x hx
  rw [staircase, Finset.mem_insert] at hx
  rcases hx with rfl | hx
  · exact gapF_mono_dim hk (Nat.zero_le r) (by simp [gapF])
  · obtain ⟨j, hj, hxj⟩ := Finset.mem_biUnion.1 hx
    exact arm_subset_gapF hk (Finset.mem_range.1 hj) hxj

/-! ## Sumsets of GAPs -/

/-- Concatenation of two step sequences: `d` on `[0, r)`, then `e`. -/
def dcat (d e : ℕ → ℕ) (r : ℕ) : ℕ → ℕ := fun j => if j < r then d j else e (j - r)

lemma stairBase_dcat_left {a b k : ℕ} {d e : ℕ → ℕ} {r j : ℕ} (hj : j ≤ r) :
    stairBase (a + b) k (dcat d e r) j = stairBase a k d j + b := by
  induction j with
  | zero => rfl
  | succ p ih =>
      have hp := ih (by omega)
      simp only [stairBase, hp, dcat, if_pos (show p < r by omega)]
      omega

lemma stairBase_dcat_right {a b k : ℕ} {d e : ℕ → ℕ} {r j : ℕ} :
    stairBase (a + b) k (dcat d e r) (r + j) = stairBase a k d r + stairBase b k e j := by
  induction j with
  | zero => simpa using stairBase_dcat_left (a := a) (b := b) (k := k) (d := d) (e := e) le_rfl
  | succ p ih =>
      have hrp : ¬ (r + p < r) := by omega
      have : r + (p + 1) = (r + p) + 1 := by omega
      rw [this]
      simp only [stairBase, ih, dcat, if_neg hrp, Nat.add_sub_cancel_left]
      omega

/-- **The key geometric fact.**  The sumset of a dimension-`r` GAP and a dimension-`s`
GAP (with the same side length `k`) contains a staircase with `r + s` arms, whose steps
are the concatenated generator sequences. -/
lemma staircase_subset_gapF_add {a b k : ℕ} {d e : ℕ → ℕ} (hk : 1 ≤ k) (r s : ℕ) :
    staircase (a + b) k (dcat d e r) (r + s) ⊆ gapF a k d r + gapF b k e s := by
  intro x hx
  rw [staircase, Finset.mem_insert] at hx
  have hb0 : b ∈ gapF b k e s := gapF_mono_dim hk (Nat.zero_le s) (by simp [gapF])
  have ha0 : a ∈ gapF a k d r := gapF_mono_dim hk (Nat.zero_le r) (by simp [gapF])
  rcases hx with rfl | hx
  · exact Finset.add_mem_add ha0 hb0
  · obtain ⟨j, hj, hxj⟩ := Finset.mem_biUnion.1 hx
    rw [Finset.mem_range] at hj
    obtain ⟨i, hi, rfl⟩ := mem_apF.1 hxj
    rcases Nat.lt_or_ge j r with hjr | hjr
    · rw [stairBase_dcat_left (a := a) (b := b) (k := k) (d := d) (e := e) (le_of_lt hjr),
        dcat, if_pos hjr]
      have he : stairBase a k d j + b + d j * i = (stairBase a k d j + d j * i) + b := by ring
      rw [he]
      exact Finset.add_mem_add (arm_subset_gapF hk hjr (mem_apF.2 ⟨i, hi, rfl⟩)) hb0
    · obtain ⟨j', rfl⟩ : ∃ j', j = r + j' := ⟨j - r, by omega⟩
      have hj's : j' < s := by omega
      rw [stairBase_dcat_right (a := a) (b := b) (k := k) (d := d) (e := e), dcat,
        if_neg (by omega : ¬ (r + j' < r)), Nat.add_sub_cancel_left]
      have he : stairBase a k d r + stairBase b k e j' + e j' * i
          = stairBase a k d r + (stairBase b k e j' + e j' * i) := by ring
      rw [he]
      exact Finset.add_mem_add (stairBase_mem_gapF hk le_rfl)
        (arm_subset_gapF hk hj's (mem_apF.2 ⟨i, hi, rfl⟩))

/-! ## The counting step -/

/-- If `m ≤ n`, `2 ≤ k` and `n^{R+1} · m^{R(k-1)+1} < n^{R(k-1)+1}`, then there is
a set `S ⊆ [n]` with exactly `m` elements containing no staircase with `R` arms of side
length `k` and positive steps.  (There are at most `n^{R+1}` such staircases inside `[n]`,
and each has `R(k-1)+1` elements.) -/
theorem exists_card_eq_no_staircase {n m R k : ℕ} (hmn : m ≤ n) (hk : 2 ≤ k)
    (hcond : n ^ (R + 1) * m ^ (R * (k - 1) + 1) < n ^ (R * (k - 1) + 1)) :
    ∃ S ⊆ range n, S.card = m ∧
      ∀ (t : ℕ) (d : ℕ → ℕ), (∀ j < R, 0 < d j) → ¬ (staircase t k d R ⊆ S) := by
  classical
  set I : Finset (ℕ × (Fin R → ℕ)) :=
    (range n) ×ˢ (Fintype.piFinset fun _ : Fin R => Icc 1 n) with hI
  set dfun : (Fin R → ℕ) → ℕ → ℕ := fun v j => if h : j < R then v ⟨j, h⟩ else 1 with hdfun
  have hIcard : I.card = n ^ (R + 1) := by
    rw [hI, Finset.card_product, Finset.card_range, Fintype.card_piFinset]
    simp [Nat.card_Icc, pow_succ, mul_comm]
  obtain ⟨S, hSsub, hScard, hSno⟩ :=
    exists_card_eq_avoiding_family I (fun p => staircase p.1 k (dfun p.2) R)
      (fun p hp => by
        rw [hI, Finset.mem_product, Fintype.mem_piFinset] at hp
        have hpos : ∀ j < R, 0 < dfun p.2 j := by
          intro j hj
          rw [hdfun]
          simp only [dif_pos hj]
          have := hp.2 ⟨j, hj⟩
          rw [Finset.mem_Icc] at this
          omega
        rw [card_staircase (by omega) hpos])
      hmn (by omega) (by rw [hIcard]; exact hcond)
  refine ⟨S, hSsub, hScard, ?_⟩
  intro t d hd hsub
  -- the parameters `t, d 0, …, d (R-1)` all lie in the allowed ranges
  have ht : t < n := by
    have : t ∈ S := hsub (Finset.mem_insert_self _ _)
    simpa using hSsub this
  have hdn : ∀ j, j < R → d j ≤ n := by
    intro j hj
    have hmem : stairBase t k d j + d j ∈ staircase t k d R := by
      refine Finset.mem_insert_of_mem (Finset.mem_biUnion.2 ⟨j, Finset.mem_range.2 hj, ?_⟩)
      exact mem_apF.2 ⟨1, by omega, by ring⟩
    have := hSsub (hsub hmem)
    rw [Finset.mem_range] at this
    have hb := le_stairBase t k d j
    omega
  refine hSno (t, fun j : Fin R => d j) ?_ ?_
  · rw [hI, Finset.mem_product, Fintype.mem_piFinset]
    refine ⟨Finset.mem_range.2 ht, fun j => Finset.mem_Icc.2 ⟨hd j j.isLt, hdn j j.isLt⟩⟩
  · have hcongr : staircase t k (dfun fun j : Fin R => d j) R = staircase t k d R := by
      refine staircase_congr fun j hj => ?_
      rw [hdfun]
      simp [dif_pos hj]
    simpa [hcongr] using hsub

/-! ## The main theorem -/

/-- **Sharpness for generalised progressions, with `C(δ) = 3` uniformly in the dimension.**

For every `0 < δ < 1`, every `n` large enough (`δ² n ≥ 1` and `δ n log(1/δ) ≥ 100`) and
every pair of dimensions `r, s` with `1 ≤ r + s ≤ 9`, there is a set `S ⊆ [n]` with
`|S| ≥ δ n` such that for **all** generalised arithmetic progressions `A` of dimension
`r` and `B` of dimension `s`, with arbitrary positive generators and common side length
`k ≥ 3 log n / log (1/δ)`, the sumset `A + B` is not contained in `S`.

The witness is the `((r+s)(k-1)+1)`-point staircase inside `A + B`, described by the
`r + s + 1` parameters `(t, d 0, …, d (r+s-1))`; the union bound therefore costs
`n^{r+s+1}`, which the staircase's length comfortably beats. -/
theorem exists_dense_avoiding_gap_sumsets (δ : ℝ) (h0 : 0 < δ) (h1 : δ < 1) {n : ℕ}
    (hn2 : 2 ≤ n) (hδn : 1 ≤ δ ^ 2 * n) (hbig : 100 ≤ δ * n * Real.log (1 / δ))
    {r s : ℕ} (hrs1 : 1 ≤ r + s) (hrs9 : r + s ≤ 9) :
    ∃ S ⊆ range n, δ * n ≤ S.card ∧
      ∀ (a b k : ℕ) (d e : ℕ → ℕ), (∀ j < r, 0 < d j) → (∀ j < s, 0 < e j) →
        3 * (Real.log n / Real.log (1 / δ)) ≤ k →
        ¬ (gapF a k d r + gapF b k e s ⊆ S) := by
  have hlpos : 0 < Real.log (1 / δ) := by
    simp only [one_div]
    exact Real.log_pos (by rw [lt_inv_comm₀ (by norm_num) h0]; simpa using h1)
  have hn0 : (0 : ℝ) < n := by
    have : (2 : ℝ) ≤ n := by exact_mod_cast hn2
    linarith
  have hδn1 : 1 ≤ δ * n := by nlinarith [hδn, h0, h1, hn0]
  have hR2 : 2 ≤ Real.log n / Real.log (1 / δ) := by
    have hle : (1 / δ) ^ 2 ≤ (n : ℝ) := by
      rw [div_pow, one_pow, div_le_iff₀ (by positivity)]
      linarith [hδn]
    have hlog := Real.log_le_log (by positivity) hle
    rw [Real.log_pow] at hlog
    rw [le_div_iff₀ hlpos]
    push_cast at hlog
    linarith
  set R : ℝ := Real.log n / Real.log (1 / δ) with hRdef
  set N : ℕ := r + s with hN
  have hNR : (1 : ℝ) ≤ (N : ℝ) := by exact_mod_cast hrs1
  have hNR9 : (N : ℝ) ≤ 9 := by exact_mod_cast hrs9
  set k₀ : ℕ := ⌈3 * R⌉₊ with hk₀
  have hk₀ge : 3 * R ≤ (k₀ : ℝ) := Nat.le_ceil _
  have hk₀2 : 2 ≤ k₀ := by
    have : (2 : ℝ) ≤ (k₀ : ℝ) := by linarith
    exact_mod_cast this
  have hcast : ((N * (k₀ - 1) + 1 : ℕ) : ℝ) = (N : ℝ) * ((k₀ : ℝ) - 1) + 1 := by
    have hle : 1 ≤ k₀ := by omega
    push_cast [Nat.cast_sub hle]
    ring
  have hmn : ⌈δ * (n : ℝ)⌉₊ ≤ n := Nat.ceil_le.2 (by nlinarith)
  have hcond : n ^ (N + 1) * (⌈δ * (n : ℝ)⌉₊) ^ (N * (k₀ - 1) + 1)
      < n ^ (N * (k₀ - 1) + 1) := by
    refine pow_cond δ h0 h1 n hn2 hδn1 hbig (N + 1) (by omega) (N * (k₀ - 1) + 1) ?_
    rw [hcast]
    push_cast
    nlinarith [hk₀ge, hR2, hNR, hNR9]
  obtain ⟨S, hSsub, hScard, hSno⟩ := exists_card_eq_no_staircase hmn hk₀2 hcond
  refine ⟨S, hSsub, by rw [hScard]; exact Nat.le_ceil _, ?_⟩
  intro a b k d e hd he hk hsub
  have hkk : k₀ ≤ k := Nat.ceil_le.2 (by exact_mod_cast hk)
  have hdpos : ∀ j < N, 0 < dcat d e r j := by
    intro j hj
    rw [dcat]
    by_cases hjr : j < r
    · simpa [hjr] using hd j hjr
    · simp only [if_neg hjr]
      exact he _ (by omega)
  refine hSno (a + b) (dcat d e r) hdpos ?_
  refine subset_trans (staircase_subset_gapF_add (by omega) r s) (subset_trans ?_ hsub)
  exact Finset.add_subset_add (gapF_mono_side hkk r) (gapF_mono_side hkk s)

/-- **Arbitrary first summand.**  The same set `S` also avoids `A + B` for a completely
arbitrary nonempty `A` and a generalised progression `B` of dimension `1 ≤ r ≤ 9` and side
length `k ≥ 3 log n / log (1/δ)`: indeed `A + B` contains a translate of `B`, hence a
staircase.  This is the `r = 0` case of `exists_dense_avoiding_gap_sumsets`, since a
dimension-`0` GAP is a single point. -/
theorem exists_dense_no_sumset_with_gap (δ : ℝ) (h0 : 0 < δ) (h1 : δ < 1) {n : ℕ}
    (hn2 : 2 ≤ n) (hδn : 1 ≤ δ ^ 2 * n) (hbig : 100 ≤ δ * n * Real.log (1 / δ))
    {r : ℕ} (hr1 : 1 ≤ r) (hr9 : r ≤ 9) :
    ∃ S ⊆ range n, δ * n ≤ S.card ∧
      ∀ (A : Finset ℕ) (b k : ℕ) (e : ℕ → ℕ), A.Nonempty → (∀ j < r, 0 < e j) →
        3 * (Real.log n / Real.log (1 / δ)) ≤ k →
        ¬ (A + gapF b k e r ⊆ S) := by
  obtain ⟨S, hSsub, hScard, hSno⟩ :=
    exists_dense_avoiding_gap_sumsets δ h0 h1 hn2 hδn hbig
      (r := 0) (s := r) (by omega) (by omega)
  refine ⟨S, hSsub, hScard, ?_⟩
  intro A b k e hA he hk hsub
  obtain ⟨a, ha⟩ := hA
  refine hSno a b k (fun _ => 0) e (by omega) he hk ?_
  refine subset_trans (Finset.add_subset_add_right ?_) hsub
  simpa [gapF] using ha

/-- **An explicit small instance.**  The density-`1/2` set `S16 = {0,1,3,6,8,12,13,14} ⊆ [16]`
of `Bridges/DeltaDenseSumsetAvoidanceExample.lean` contains no sumset of two generalised
progressions of *any* dimensions `r + s ≥ 1` and common side length `k ≥ 4`: such a sumset
contains a staircase, whose first arm is a `4`-term progression. -/
theorem S16_no_gap_sumset (a b k r s : ℕ) (d e : ℕ → ℕ) (hd : ∀ j < r, 0 < d j)
    (he : ∀ j < s, 0 < e j) (hk : 4 ≤ k) (hrs : 1 ≤ r + s) :
    ¬ (gapF a k d r + gapF b k e s ⊆ S16) := by
  intro hsub
  have hst : staircase (a + b) k (dcat d e r) (r + s) ⊆ S16 :=
    (staircase_subset_gapF_add (by omega) r s).trans hsub
  have hD0 : 0 < dcat d e r 0 := by
    rw [dcat]
    by_cases hr : 0 < r
    · simpa [hr] using hd 0 hr
    · simp only [if_neg (by omega : ¬ (0 < r)), Nat.zero_sub]
      exact he 0 (by omega)
  refine S16_no_ap (a + b) _ hD0 (subset_trans (apF_mono _ _ hk) (subset_trans ?_ hst))
  intro x hx
  exact Finset.mem_insert_of_mem (Finset.mem_biUnion.2 ⟨0, Finset.mem_range.2 (by omega), hx⟩)

/-- Specialisation to `r = s = 1`: the two-progression sharpness statement, recovered from
the GAP version via `gapF_one`. -/
theorem exists_dense_avoiding_ap_sumsets_of_gap (δ : ℝ) (h0 : 0 < δ) (h1 : δ < 1) {n : ℕ}
    (hn2 : 2 ≤ n) (hδn : 1 ≤ δ ^ 2 * n) (hbig : 100 ≤ δ * n * Real.log (1 / δ)) :
    ∃ S ⊆ range n, δ * n ≤ S.card ∧
      ∀ a b d₁ d₂ k : ℕ, 0 < d₁ → 0 < d₂ →
        3 * (Real.log n / Real.log (1 / δ)) ≤ k →
        ¬ (apF a d₁ k + apF b d₂ k ⊆ S) := by
  obtain ⟨S, hSsub, hScard, hSno⟩ :=
    exists_dense_avoiding_gap_sumsets δ h0 h1 hn2 hδn hbig
      (r := 1) (s := 1) (by omega) (by omega)
  refine ⟨S, hSsub, hScard, ?_⟩
  intro a b d₁ d₂ k hd₁ hd₂ hk hsub
  refine hSno a b k (fun _ => d₁) (fun _ => d₂) (fun _ _ => hd₁) (fun _ _ => hd₂) hk ?_
  rwa [gapF_one, gapF_one]

end DeltaDense