import Cryptography.LatticePointEnumerator

/-!
# A uniqueness theorem for lattice-point enumerators of integer translates

Let `P ⊆ ℝ^d` be bounded and let

`L_{P+v}(t) = |t(P+v) ∩ ℤ^d|`,  `t > 0` real, `v ∈ ℤ^d`,

be the family of real-parameter lattice-point enumerators of all *integer* translates of `P`
(`LatticeEnumerator.shiftCount P t v`).  The main theorem of the paper
*A Fourier-analytic uniqueness theorem for lattice-point enumerators* states that this data
determines the indicator function of `P` almost everywhere, provided `P` is bounded,
measurable and has null topological frontier.

This file gives a complete, **elementary** proof of that statement (and of a strictly stronger
pointwise statement), avoiding Fourier analysis altogether.

## The mechanism

Fix a rational point `x = a/N ∈ ℚ^d` and put

`M = ⌈2R⌉ + 2`,  `q = N·M + 1`,  `t = N/q`,  `v = M·a ∈ ℤ^d`,

where `P ∪ Q ⊆ closedBall 0 R`.  The counted grid `(1/t)ℤ^d - v = (q/N)ℤ^d - M a` has spacing
`q/N = M + 1/N > 2R`, hence **at most one** of its points can lie in the ball of radius `R`;
and the lattice point `k = a` produces exactly the probe point

`a/t - v = a(M + 1/N) - M a = a/N = x`.

Consequently `L_{P+v}(t) = 1` if `x ∈ P` and `= 0` otherwise: the enumerator data *reads off*
the indicator of `P` at every rational point (`mem_iff_mem_of_integerTranslateData`).
Since `ℚ^d` is dense and, off the (null) frontier, membership is a local property, the
indicators agree almost everywhere.

## Main results

* `LatticeEnumerator.shiftCount_eq_one`, `LatticeEnumerator.shiftCount_eq_zero` : the
  sparse-grid evaluation lemmas.
* `LatticeEnumerator.mem_iff_mem_of_gridRepresentation` : the master lemma — membership is
  determined at every point of the form `s·k - v` with `k, v ∈ ℤ^d` and `s` large.
* `LatticeEnumerator.mem_iff_mem_of_integerTranslateData` : the data determines membership at
  every rational point — *exactly*, with no regularity hypothesis whatsoever.
* `LatticeEnumerator.ae_eq_of_integerTranslateData` : the paper's theorem, `P =ᵐ Q`, for
  bounded sets with null frontier.
* `LatticeEnumerator.volume_symmDiff_eq_zero_of_integerTranslateData` : the same, stated as
  `vol(P Δ Q) = 0`.
* `LatticeEnumerator.convexBody_eq_of_integerTranslateData` : the corollary for convex bodies:
  interiors and closures coincide.
* `LatticeEnumerator.eq_of_integerTranslateData_dim_one` : in dimension one the conclusion
  upgrades to exact set equality, with no measurability or frontier hypothesis.
-/

noncomputable section

open MeasureTheory Metric Set Filter Topology

namespace LatticeEnumerator

variable {d : ℕ}

/-- The data of the paper: the real-parameter lattice-point enumerators of all integer
translates of `P` and of `Q` agree. -/
def IntegerTranslateData (P Q : Set (Fin d → ℝ)) : Prop :=
  ∀ t : ℝ, 0 < t → ∀ v : Fin d → ℤ,
    shiftCount P t (fun i => (v i : ℝ)) = shiftCount Q t (fun i => (v i : ℝ))

/-- `shiftCount P t y` really is the lattice-point enumerator of the translate `P + y`. -/
lemma shiftCount_eq_dilCount_translate (P : Set (Fin d → ℝ)) (t : ℝ) (y : Fin d → ℝ) :
    shiftCount P t y = dilCount ((fun x => x + y) '' P) t := by
  unfold shiftCount dilCount
  congr 1
  ext k
  simp only [mem_shiftLattice, mem_dilLattice, Set.mem_image]
  constructor
  · intro hk
    exact ⟨fun i => (k i : ℝ) / t - y i, hk, by funext i; simp⟩
  · rintro ⟨p, hp, hpk⟩
    have hEq : (fun i => (k i : ℝ) / t - y i) = p := by
      funext i
      have hi := congrFun hpk i
      simp only [Pi.add_apply] at hi
      linarith
    rwa [hEq]

/-! ## Reading off the indicator on a sparse grid -/

/-- **Sparse-grid uniqueness.**  If the grid spacing `1/t` exceeds the diameter bound `2R` of
`P`, at most one grid point can be counted, namely the one lying in `closedBall 0 R`. -/
lemma eq_of_mem_shiftLattice_of_sparse {P : Set (Fin d → ℝ)} {R t : ℝ} (hP : P ⊆ closedBall 0 R)
    (ht : 0 < t) (h2R : 2 * R < 1 / t) {y : Fin d → ℝ} {k₀ : Fin d → ℤ}
    (hxR : (fun i => (k₀ i : ℝ) / t - y i) ∈ closedBall (0 : Fin d → ℝ) R) :
    ∀ k ∈ shiftLattice P t y, k = k₀ := by
  set x : Fin d → ℝ := fun i => (k₀ i : ℝ) / t - y i with hx
  intro k hk
  by_contra hne
  obtain ⟨j, hj⟩ : ∃ j, k j ≠ k₀ j := by
    by_contra hall
    push_neg at hall
    exact hne (funext hall)
  set z : Fin d → ℝ := fun i => (k i : ℝ) / t - y i with hz
  have hzP : z ∈ closedBall (0 : Fin d → ℝ) R := hP hk
  have hd1 : dist z x ≤ 2 * R := by
    have h1 : dist z 0 ≤ R := by simpa using hzP
    have h2 : dist x 0 ≤ R := by simpa using hxR
    have h3 := dist_triangle z 0 x
    rw [dist_comm (0 : Fin d → ℝ) x] at h3
    linarith
  have hd2 : 1 / t ≤ dist z x := by
    have hcoord : |z j - x j| ≤ dist z x := by
      have hle := dist_le_pi_dist z x j
      rwa [Real.dist_eq] at hle
    have hdiff : |z j - x j| = |(k j : ℝ) - (k₀ j : ℝ)| / t := by
      have hzx : z j - x j = ((k j : ℝ) - (k₀ j : ℝ)) / t := by
        rw [hz, hx]; ring
      rw [hzx, abs_div, abs_of_pos ht]
    have hone : (1 : ℝ) ≤ |(k j : ℝ) - (k₀ j : ℝ)| := by
      have h1 : (1 : ℤ) ≤ |k j - k₀ j| := Int.one_le_abs (sub_ne_zero.2 hj)
      have h2 : ((1 : ℤ) : ℝ) ≤ ((|k j - k₀ j| : ℤ) : ℝ) := by exact_mod_cast h1
      rwa [Int.cast_abs, Int.cast_sub, Int.cast_one] at h2
    calc 1 / t ≤ |(k j : ℝ) - (k₀ j : ℝ)| / t := by gcongr
      _ = |z j - x j| := hdiff.symm
      _ ≤ dist z x := hcoord
  linarith

/-- On a sparse grid the enumerator equals `1` exactly when the distinguished probe point
belongs to `P`. -/
lemma shiftCount_eq_one {P : Set (Fin d → ℝ)} {R t : ℝ} (hP : P ⊆ closedBall 0 R)
    (ht : 0 < t) (h2R : 2 * R < 1 / t) {y : Fin d → ℝ} {k₀ : Fin d → ℤ}
    (hxR : (fun i => (k₀ i : ℝ) / t - y i) ∈ closedBall (0 : Fin d → ℝ) R)
    (hxP : (fun i => (k₀ i : ℝ) / t - y i) ∈ P) : shiftCount P t y = 1 := by
  have hsingle : shiftLattice P t y = {k₀} :=
    Set.eq_singleton_iff_unique_mem.2 ⟨hxP, eq_of_mem_shiftLattice_of_sparse hP ht h2R hxR⟩
  rw [shiftCount, hsingle, Set.ncard_singleton]

/-- On a sparse grid the enumerator vanishes exactly when the distinguished probe point does
not belong to `P`. -/
lemma shiftCount_eq_zero {P : Set (Fin d → ℝ)} {R t : ℝ} (hP : P ⊆ closedBall 0 R)
    (ht : 0 < t) (h2R : 2 * R < 1 / t) {y : Fin d → ℝ} {k₀ : Fin d → ℤ}
    (hxR : (fun i => (k₀ i : ℝ) / t - y i) ∈ closedBall (0 : Fin d → ℝ) R)
    (hxP : (fun i => (k₀ i : ℝ) / t - y i) ∉ P) : shiftCount P t y = 0 := by
  have hempty : shiftLattice P t y = ∅ := by
    rw [Set.eq_empty_iff_forall_notMem]
    intro k hk
    have hk0 := eq_of_mem_shiftLattice_of_sparse hP ht h2R hxR k hk
    subst hk0
    exact hxP hk
  rw [shiftCount, hempty, Set.ncard_empty]

/-! ## The data determines the indicator at every rational point -/

/-- **Master lemma.**  Every point admitting a *sparse grid representation*
`x = s·k - v` with `k, v ∈ ℤ^d` and spacing `s > 2R` is seen by the enumerator data: it belongs
to `P` if and only if it belongs to `Q`. -/
theorem mem_iff_mem_of_gridRepresentation {P Q : Set (Fin d → ℝ)} {R : ℝ} (hR0 : 0 ≤ R)
    (hPR : P ⊆ closedBall 0 R) (hQR : Q ⊆ closedBall 0 R) (h : IntegerTranslateData P Q)
    {x : Fin d → ℝ} {k v : Fin d → ℤ} {s : ℝ} (hs : 2 * R < s)
    (hx : ∀ i, x i = s * (k i : ℝ) - (v i : ℝ)) : x ∈ P ↔ x ∈ Q := by
  have hs0 : 0 < s := lt_of_le_of_lt (by linarith) hs
  set t : ℝ := 1 / s with htdef
  have ht : 0 < t := by rw [htdef]; positivity
  have hinv : 1 / t = s := by rw [htdef, one_div_one_div]
  have h2R : 2 * R < 1 / t := by rw [hinv]; exact hs
  have hprobe : (fun i => (k i : ℝ) / t - ((v i : ℤ) : ℝ)) = x := by
    funext i
    rw [hx i, div_eq_mul_one_div, hinv]
    ring
  by_cases hxR : x ∈ closedBall (0 : Fin d → ℝ) R
  · have hprobeR : (fun i => (k i : ℝ) / t - ((v i : ℤ) : ℝ)) ∈
        closedBall (0 : Fin d → ℝ) R := by rw [hprobe]; exact hxR
    have hdata := h t ht v
    by_cases hxP : x ∈ P
    · by_cases hxQ : x ∈ Q
      · exact iff_of_true hxP hxQ
      · rw [shiftCount_eq_one hPR ht h2R hprobeR (by rw [hprobe]; exact hxP),
          shiftCount_eq_zero hQR ht h2R hprobeR (by rw [hprobe]; exact hxQ)] at hdata
        exact absurd hdata one_ne_zero
    · by_cases hxQ : x ∈ Q
      · rw [shiftCount_eq_zero hPR ht h2R hprobeR (by rw [hprobe]; exact hxP),
          shiftCount_eq_one hQR ht h2R hprobeR (by rw [hprobe]; exact hxQ)] at hdata
        exact absurd hdata.symm one_ne_zero
      · exact iff_of_false hxP hxQ
  · -- outside the bounding ball neither set contains `x`
    exact iff_of_false (fun hmem => hxR (hPR hmem)) (fun hmem => hxR (hQR hmem))

/-- A common bounding radius for two bounded sets, chosen nonnegative. -/
lemma exists_common_radius {P Q : Set (Fin d → ℝ)} (hbP : Bornology.IsBounded P)
    (hbQ : Bornology.IsBounded Q) :
    ∃ R : ℝ, 0 ≤ R ∧ P ⊆ closedBall 0 R ∧ Q ⊆ closedBall 0 R := by
  obtain ⟨R₁, hR₁⟩ := (Metric.isBounded_iff_subset_closedBall 0).1 hbP
  obtain ⟨R₂, hR₂⟩ := (Metric.isBounded_iff_subset_closedBall 0).1 hbQ
  refine ⟨max (max R₁ R₂) 0, le_max_right _ _, ?_, ?_⟩
  · exact hR₁.trans (closedBall_subset_closedBall
      (le_trans (le_max_left R₁ R₂) (le_max_left _ _)))
  · exact hR₂.trans (closedBall_subset_closedBall
      (le_trans (le_max_right R₁ R₂) (le_max_left _ _)))

/-- **Pointwise rigidity at rational points.**  Two bounded sets whose integer-translate
enumerators agree have *exactly* the same rational points.  No measurability or regularity is
needed. -/
theorem mem_iff_mem_of_integerTranslateData {P Q : Set (Fin d → ℝ)}
    (hbP : Bornology.IsBounded P) (hbQ : Bornology.IsBounded Q) (h : IntegerTranslateData P Q)
    (N : ℕ) (hN : 0 < N) (a : Fin d → ℤ) :
    (fun i => (a i : ℝ) / (N : ℝ)) ∈ P ↔ (fun i => (a i : ℝ) / (N : ℝ)) ∈ Q := by
  obtain ⟨R, hR0, hPR, hQR⟩ := exists_common_radius hbP hbQ
  have hNpos : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN
  -- the sparse grid: spacing `s = M + 1/N`, lattice point `k = a`, translate `v = M · a`
  set M : ℕ := ⌈2 * R⌉₊ + 2 with hM
  set s : ℝ := (M : ℝ) + 1 / (N : ℝ) with hsdef
  have hs : 2 * R < s := by
    have h1 : 2 * R ≤ (⌈2 * R⌉₊ : ℝ) := Nat.le_ceil _
    have h2 : (⌈2 * R⌉₊ : ℝ) + 2 = (M : ℝ) := by rw [hM]; push_cast; ring
    have h3 : (0 : ℝ) < 1 / (N : ℝ) := by positivity
    rw [hsdef]; linarith
  refine mem_iff_mem_of_gridRepresentation hR0 hPR hQR h (k := a) (v := fun i => (M : ℤ) * a i)
    (s := s) hs ?_
  intro i
  rw [hsdef]
  push_cast
  field_simp
  ring

/-- Rational points can be produced by rounding: `floorMap N x` is a rational point at
sup-distance at most `1/N` from `x`. -/
lemma exists_rational_point_close {x : Fin d → ℝ} {ε : ℝ} (hε : 0 < ε) :
    ∃ (N : ℕ) (a : Fin d → ℤ), 0 < N ∧ dist (fun i => (a i : ℝ) / (N : ℝ)) x < ε := by
  obtain ⟨n, hn⟩ := exists_nat_one_div_lt hε
  refine ⟨n + 1, fun i => ⌊((n : ℝ) + 1) * x i⌋, Nat.succ_pos n, ?_⟩
  have hpos : (0 : ℝ) < (n : ℝ) + 1 := by positivity
  have hd : dist (floorMap ((n : ℝ) + 1) x) x ≤ 1 / ((n : ℝ) + 1) := dist_floorMap_le hpos x
  have hfl : (fun i => ((⌊((n : ℝ) + 1) * x i⌋ : ℤ) : ℝ) / ((n + 1 : ℕ) : ℝ))
      = floorMap ((n : ℝ) + 1) x := by
    funext i
    simp [floorMap]
  rw [hfl]
  exact lt_of_le_of_lt hd hn

/-! ## The main uniqueness theorem -/

/-- Off the frontier, membership is determined by the rational points of the set. -/
lemma mem_closure_of_mem_interior_of_data {P Q : Set (Fin d → ℝ)}
    (hbP : Bornology.IsBounded P) (hbQ : Bornology.IsBounded Q) (h : IntegerTranslateData P Q)
    {x : Fin d → ℝ} (hx : x ∈ interior P) : x ∈ closure Q := by
  obtain ⟨ε, hε, hball⟩ := Metric.isOpen_iff.1 isOpen_interior x hx
  rw [Metric.mem_closure_iff]
  intro δ hδ
  obtain ⟨N, a, hN, hdist⟩ := exists_rational_point_close (x := x) (ε := min δ ε)
    (lt_min hδ hε)
  refine ⟨fun i => (a i : ℝ) / (N : ℝ), ?_, ?_⟩
  · refine (mem_iff_mem_of_integerTranslateData hbP hbQ h N hN a).1 ?_
    refine interior_subset (hball ?_)
    rw [mem_ball]
    exact lt_of_lt_of_le hdist (min_le_right _ _)
  · rw [dist_comm]
    exact lt_of_lt_of_le hdist (min_le_left _ _)

/-- **Main theorem (uniqueness for integer translates).**  If two bounded sets with null
topological frontier have the same real-parameter lattice-point enumerators for all integer
translates, their indicator functions agree almost everywhere. -/
theorem ae_eq_of_integerTranslateData {P Q : Set (Fin d → ℝ)}
    (hbP : Bornology.IsBounded P) (hbQ : Bornology.IsBounded Q)
    (hfrP : volume (frontier P) = 0) (hfrQ : volume (frontier Q) = 0)
    (h : IntegerTranslateData P Q) : P =ᵐ[volume] Q := by
  have haeP : ∀ᵐ x : (Fin d → ℝ), x ∉ frontier P := measure_eq_zero_iff_ae_notMem.1 hfrP
  have haeQ : ∀ᵐ x : (Fin d → ℝ), x ∉ frontier Q := measure_eq_zero_iff_ae_notMem.1 hfrQ
  filter_upwards [haeP, haeQ] with x hxP hxQ
  have key : ∀ (A B : Set (Fin d → ℝ)), Bornology.IsBounded A → Bornology.IsBounded B →
      IntegerTranslateData A B → x ∉ frontier A → x ∉ frontier B → x ∈ A → x ∈ B := by
    intro A B hbA hbB hAB hfA hfB hmem
    have hint : x ∈ interior A := by
      by_contra hni
      exact hfA ⟨subset_closure hmem, hni⟩
    have hcl : x ∈ closure B := mem_closure_of_mem_interior_of_data hbA hbB hAB hint
    have : x ∈ interior B := by
      by_contra hni
      exact hfB ⟨hcl, hni⟩
    exact interior_subset this
  have hsymm : IntegerTranslateData Q P := fun t ht v => (h t ht v).symm
  exact eq_iff_iff.2 ⟨fun hm => key P Q hbP hbQ h hxP hxQ hm,
    fun hm => key Q P hbQ hbP hsymm hxQ hxP hm⟩

/-- The main theorem stated as vanishing of the volume of the symmetric difference. -/
theorem volume_symmDiff_eq_zero_of_integerTranslateData {P Q : Set (Fin d → ℝ)}
    (hbP : Bornology.IsBounded P) (hbQ : Bornology.IsBounded Q)
    (hfrP : volume (frontier P) = 0) (hfrQ : volume (frontier Q) = 0)
    (h : IntegerTranslateData P Q) : volume (symmDiff P Q) = 0 := by
  exact measure_symmDiff_eq_zero_iff.mpr (ae_eq_of_integerTranslateData hbP hbQ hfrP hfrQ h)

/-- **Corollary for convex bodies.**  Two bounded convex sets with nonempty interior are
determined, as bodies (equal interiors, equal closures), by the enumerators of their integer
translates. -/
theorem convexBody_eq_of_integerTranslateData {P Q : Set (Fin d → ℝ)}
    (hcP : Convex ℝ P) (hcQ : Convex ℝ Q) (hbP : Bornology.IsBounded P)
    (hbQ : Bornology.IsBounded Q) (hiP : (interior P).Nonempty) (hiQ : (interior Q).Nonempty)
    (h : IntegerTranslateData P Q) : interior P = interior Q ∧ closure P = closure Q := by
  have hsub : ∀ (A B : Set (Fin d → ℝ)), Convex ℝ B → Bornology.IsBounded A →
      Bornology.IsBounded B → IntegerTranslateData A B → (interior B).Nonempty →
      interior A ⊆ interior B := by
    intro A B hcB hbA hbB hAB hiB
    have hsubcl : interior A ⊆ closure B := fun z hz =>
      mem_closure_of_mem_interior_of_data hbA hbB hAB hz
    have h2 : interior A ⊆ interior (closure B) := interior_maximal hsubcl isOpen_interior
    have h3 : interior (closure B) = interior B :=
      hcB.interior_closure_eq_interior_of_nonempty_interior hiB
    rw [h3] at h2
    exact h2
  have hsymm : IntegerTranslateData Q P := fun t ht v => (h t ht v).symm
  have hint : interior P = interior Q :=
    Set.Subset.antisymm (hsub P Q hcQ hbP hbQ h hiQ) (hsub Q P hcP hbQ hbP hsymm hiP)
  refine ⟨hint, ?_⟩
  have hP : closure (interior P) = closure P :=
    hcP.closure_interior_eq_closure_of_nonempty_interior hiP
  have hQ : closure (interior Q) = closure Q :=
    hcQ.closure_interior_eq_closure_of_nonempty_interior hiQ
  rw [← hP, ← hQ, hint]

/-- **Dimension one: exact rigidity, with no regularity hypothesis at all.**  On the real line
every point `x` admits a sparse grid representation `x = s·1 - n` with `n ∈ ℤ` and `s` as large as
we please, so the enumerator data of the integer translates determines membership at *every*
real point.  Two bounded subsets of `ℝ` with the same data are therefore literally equal — a
strictly stronger conclusion than almost-everywhere equality. -/
theorem eq_of_integerTranslateData_dim_one {P Q : Set (Fin 1 → ℝ)}
    (hbP : Bornology.IsBounded P) (hbQ : Bornology.IsBounded Q) (h : IntegerTranslateData P Q) :
    P = Q := by
  obtain ⟨R, hR0, hPR, hQR⟩ := exists_common_radius hbP hbQ
  ext x
  set n : ℤ := ⌈2 * R - x 0⌉ + 1 with hn
  have hns : 2 * R < x 0 + (n : ℝ) := by
    have hceil : (2 * R - x 0) ≤ (⌈2 * R - x 0⌉ : ℝ) := Int.le_ceil _
    rw [hn]
    push_cast
    linarith
  refine mem_iff_mem_of_gridRepresentation hR0 hPR hQR h (k := fun _ => 1) (v := fun _ => n)
    (s := x 0 + (n : ℝ)) hns ?_
  intro i
  fin_cases i
  push_cast
  ring

end LatticeEnumerator