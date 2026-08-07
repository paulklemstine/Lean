import Novelty.DiophantineLatticeShiftedTheta

/-!
# Torsion refinement: spectral gaps at `r`-torsion points, and even multiplicities

Cycle 2 of the research thread.  `Novelty/DiophantineLatticeSpectralGap.lean` proved that the
non-homogeneous form `x ↦ Q(x - v/2)` attached to a shortest lattice vector `v` has spectral
gap exactly `λ₁/4`.  Here the `2` is replaced by an arbitrary `r ≥ 2`, i.e. the shift is an
arbitrary `r`-torsion point of `(L ⊗ ℚ)/L` of the special shape `v/r`:

* `torsion_gap_ge` : if `v ∉ rL` then `Q(v/r - m) ≥ λ₁/r²` for every lattice point `m`;
* `frac_shortest_isInhomMin` : for a shortest `v` and `r ≥ 2` the spectral gap at `v/r` is
  *exactly* `λ₁/r²` — the `r = 2` case is the previous cycle's main theorem;
* `torsion_no_integral_solution` : the Diophantine corollary, `Q(x - v/r) = c` is unsolvable
  in integers for `c < λ₁/r²`.

A second, independent structural theorem concerns *multiplicities* rather than sizes: the
antipodal involution `m ↦ v - m` acts freely on the solution set of `Q(x - v/2) = c`, hence

* `halfPt_multiplicity_even` : every coefficient of the theta series of the non-homogeneous
  form at a half shortest vector is **even**.

Finally the diagonal case is worked out completely: `diagonal_isMinEnergy` computes `λ₁` and
`diagonal_covering_radius_least` / `diagonal_covering_le` compute the covering radius² as
`(Σ aᵢ)/4`, so that the ratio covering/packing is `(Σ aᵢ)/(min aᵢ)`, unbounded.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the factor `1/4` of cycle 1 is the `r = 2` shadow of a general
`1/r²` law indexed by the torsion order of the shift; moreover multiplicities in the shifted
theta series should always be even.
Experiment (Experimenter): the halving identity `Q(v/r - m) = Q(v - rm)/r²` and the
obstruction `v ∈ rL ⇒ Q(v) = r²Q(v/r) ≥ r²λ₁ > λ₁` both survive verbatim for every `r ≥ 2`;
the involution `m ↦ v - m` is fixed-point free precisely because `v ∉ 2L`, which is the *same*
obstruction.  So one lemma (`sub_two_smul_ne_zero` and its `r`-analogue) drives both results.
Analysis (Analyst): the two cycle-1 phenomena are thus explained by a single structural fact —
a shortest vector is primitive modulo `r` for every `r ≥ 2`.  What genuinely fails to
generalise is the involution: for `r ≥ 3` the map `m ↦ v - m` is not a symmetry of the shifted
form, so "even multiplicity" is special to `2`-torsion (it becomes "divisible by the order of
the stabiliser-free symmetry group" in general — see FUTURE_DIRECTIONS).
Critique (Critic): `halfPt_multiplicity_even` is stated for an arbitrary `Finset` enumerating
the solutions, so it is not vacuous for `S = ∅` only; `frac_shortest_isInhomMin` includes the
attainment clause, so it is an identity, not a one-sided bound.
Synthesis (PI): spectral gap `λ₁/r²` at `r`-torsion shifts, even theta coefficients at
`2`-torsion shifts, and an exact covering radius `(Σaᵢ)/4` in the diagonal case.
-/

namespace DiophantineLattice

open Finset

variable {n : ℕ}

/-! ## Gaps at `r`-torsion shifts -/

/-- The `r`-torsion point `v/r` of `(L ⊗ ℚ)/L`. -/
def fracPt (v : Fin n → ℤ) (r : ℤ) : Fin n → ℚ := fun i => (v i : ℚ) / (r : ℚ)

/-- Scaling identity: the non-homogeneous form at the shift `v/r` is `1/r²` times the
homogeneous form at the integral point `v - r m`. -/
lemma form_frac_sub (B : Matrix (Fin n) (Fin n) ℚ) (v m : Fin n → ℤ) {r : ℤ} (hr : r ≠ 0) :
    form B (fun i => fracPt v r i - emb m i)
      = form B (emb fun i => v i - r * m i) / (r : ℚ) ^ 2 := by
  have hr' : (r : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hr
  have h : (fun i => fracPt v r i - emb m i)
      = fun i => (1 / (r : ℚ)) * (emb (fun i => v i - r * m i)) i := by
    funext i
    simp only [fracPt, emb_apply]
    push_cast
    field_simp
  rw [h, form_smul]
  field_simp

/-- **Torsion spectral gap.**  If `v` avoids the sublattice `rL`, the non-homogeneous form at
the shift `v/r` is bounded below by `λ₁/r²`. -/
theorem torsion_gap_ge {B : Matrix (Fin n) (Fin n) ℚ} {lam : ℚ}
    (hmin : ∀ m : Fin n → ℤ, m ≠ 0 → lam ≤ form B (emb m)) {v : Fin n → ℤ} {r : ℤ} (hr : r ≠ 0)
    (hnot : ∀ m : Fin n → ℤ, (fun i => v i - r * m i) ≠ 0) (m : Fin n → ℤ) :
    lam / (r : ℚ) ^ 2 ≤ form B (fun i => fracPt v r i - emb m i) := by
  have hr' : (r : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hr
  have hpos : 0 < (r : ℚ) ^ 2 := by positivity
  rw [form_frac_sub B v m hr, div_eq_mul_inv, div_eq_mul_inv]
  exact mul_le_mul_of_nonneg_right (hmin _ (hnot m)) (by positivity)

/-- A shortest vector is **primitive modulo `r`** for every `r ≥ 2`. -/
lemma shortest_not_mem_rL {B : Matrix (Fin n) (Fin n) ℚ} {lam : ℚ} (hpos : 0 < lam)
    (hmin : ∀ m : Fin n → ℤ, m ≠ 0 → lam ≤ form B (emb m)) {v : Fin n → ℤ}
    (hv : form B (emb v) = lam) {r : ℤ} (hr : 2 ≤ r) (m : Fin n → ℤ) :
    (fun i => v i - r * m i) ≠ 0 := by
  intro h
  have hvm : ∀ i, v i = r * m i := by
    intro i
    have : (fun i => v i - r * m i) i = (0 : Fin n → ℤ) i := by rw [h]
    simpa [sub_eq_zero] using this
  have hm0 : m ≠ 0 := by
    intro hm
    have hv0 : v = 0 := by funext i; rw [hvm i, hm]; simp
    rw [hv0] at hv
    have hz : form B (emb (0 : Fin n → ℤ)) = 0 := by simp [form, bil, emb]
    rw [hz] at hv
    linarith
  have hemb : emb v = fun i => (r : ℚ) * (emb m) i := by
    funext i
    show ((v i : ℚ)) = (r : ℚ) * (m i : ℚ)
    rw [hvm i]; push_cast; ring
  have hr2 : (2 : ℚ) ≤ (r : ℚ) := by exact_mod_cast hr
  have hkey : lam = (r : ℚ) ^ 2 * form B (emb m) := by
    rw [← hv, hemb, form_smul]
  have hle := hmin m hm0
  have hF : 0 < form B (emb m) := lt_of_lt_of_le hpos hle
  have hr4 : (4 : ℚ) ≤ (r : ℚ) ^ 2 := by nlinarith
  nlinarith [mul_nonneg (by linarith : (0 : ℚ) ≤ (r : ℚ) ^ 2 - 4) hF.le]

/-- **Main theorem of cycle 2.**  For a shortest vector `v` and any `r ≥ 2`, the spectral gap
of the non-homogeneous form at the `r`-torsion shift `v/r` is exactly `λ₁/r²`. -/
theorem frac_shortest_isInhomMin {B : Matrix (Fin n) (Fin n) ℚ} (hpd : PosDef B) {lam : ℚ}
    (h : IsMinEnergy B lam) {v : Fin n → ℤ} (hv : form B (emb v) = lam) {r : ℤ} (hr : 2 ≤ r) :
    IsInhomMin B (fracPt v r) (lam / (r : ℚ) ^ 2) := by
  obtain ⟨⟨w, hw, hwlam⟩, hmin⟩ := h
  have hpos : 0 < lam := by rw [← hwlam]; exact hpd _ (emb_ne_zero hw)
  have hr0 : r ≠ 0 := by omega
  refine ⟨⟨0, ?_⟩, torsion_gap_ge hmin hr0 (shortest_not_mem_rL hpos hmin hv hr)⟩
  rw [form_frac_sub B v 0 hr0]
  have : (fun i => v i - r * (0 : Fin n → ℤ) i) = v := by funext i; simp
  rw [this, hv]

/-- Diophantine corollary: `Q(x - v/r) = c` has no integral solution for `c < λ₁/r²`. -/
theorem torsion_no_integral_solution {B : Matrix (Fin n) (Fin n) ℚ} (hpd : PosDef B) {lam : ℚ}
    (h : IsMinEnergy B lam) {v : Fin n → ℤ} (hv : form B (emb v) = lam) {r : ℤ} (hr : 2 ≤ r)
    {c : ℚ} (hc : c < lam / (r : ℚ) ^ 2) :
    ¬ ∃ m : Fin n → ℤ, form B (fun i => fracPt v r i - emb m i) = c := by
  rintro ⟨m, hm⟩
  have := (frac_shortest_isInhomMin hpd h hv hr).2 m
  rw [hm] at this
  linarith

/-! ## Even multiplicities in the shifted theta series -/

lemma form_neg (B : Matrix (Fin n) (Fin n) ℚ) (x : Fin n → ℚ) :
    form B (fun i => -x i) = form B x := by
  have : (fun i => -x i) = fun i => (-1 : ℚ) * x i := by funext i; ring
  rw [this, form_smul]
  norm_num

/-- The antipodal involution `m ↦ v - m` preserves the value of the non-homogeneous form at a
half lattice point. -/
lemma halfPt_antipode_form (B : Matrix (Fin n) (Fin n) ℚ) (v m : Fin n → ℤ) :
    form B (fun i => halfPt v i - emb (fun j => v j - m j) i)
      = form B (fun i => halfPt v i - emb m i) := by
  have h : (fun i => halfPt v i - emb (fun j => v j - m j) i)
      = fun i => -(halfPt v i - emb m i) := by
    funext i
    simp only [halfPt, emb_apply]
    push_cast
    ring
  rw [h, form_neg]

/-- **Even multiplicity theorem.**  Every coefficient of the theta series of the
non-homogeneous form `x ↦ Q(x - v/2)` (with `v` a shortest vector) is even: the solution set of
`Q(x - v/2) = c` carries a fixed-point-free involution. -/
theorem halfPt_multiplicity_even {B : Matrix (Fin n) (Fin n) ℚ} (hpd : PosDef B) {lam : ℚ}
    (h : IsMinEnergy B lam) {v : Fin n → ℤ} (hv : form B (emb v) = lam) (c : ℚ)
    (S : Finset (Fin n → ℤ))
    (hS : ∀ m : Fin n → ℤ, m ∈ S ↔ form B (fun i => halfPt v i - emb m i) = c) :
    Even S.card := by
  classical
  obtain ⟨⟨w, hw, hwlam⟩, hmin⟩ := h
  have hpos : 0 < lam := by rw [← hwlam]; exact hpd _ (emb_ne_zero hw)
  set g : (Fin n → ℤ) → (Fin n → ℤ) := fun m => fun j => v j - m j with hg
  have hgmem : ∀ m ∈ S, g m ∈ S := by
    intro m hm
    rw [hS] at hm ⊢
    rw [halfPt_antipode_form]
    exact hm
  have hginv : ∀ m, g (g m) = m := by
    intro m; funext j; simp [hg]
  have hgfix : ∀ m ∈ S, g m ≠ m := by
    intro m _ hfix
    have hvm : ∀ i, v i - 2 * m i = 0 := by
      intro i
      have : (g m) i = m i := by rw [hfix]
      simp only [hg] at this
      omega
    exact sub_two_smul_ne_zero hpos hmin hv m (funext hvm)
  have hsum : ∑ _x ∈ S, (1 : ZMod 2) = 0 :=
    Finset.sum_involution (fun a _ => g a) (fun a _ => by decide)
      (fun a ha _ => hgfix a ha) (fun a ha => hgmem a ha) (fun a _ => hginv a)
  rw [Finset.sum_const, nsmul_eq_mul, mul_one] at hsum
  exact ZMod.natCast_eq_zero_iff_even.mp hsum

/-! ## The diagonal case, computed completely -/

lemma form_diagonal (a x : Fin n → ℚ) :
    form (Matrix.diagonal a) x = ∑ i, a i * (x i) ^ 2 := by
  simp only [form, bil, Matrix.diagonal_apply, ite_mul, zero_mul, sum_ite_eq, mem_univ,
    if_true, sq]
  exact sum_congr rfl fun i _ => by ring

/-- For a positive diagonal form the minimal lattice energy is `min aᵢ`. -/
theorem diagonal_isMinEnergy {a : Fin n → ℚ} (ha : ∀ i, 0 < a i) (i0 : Fin n)
    (hi0 : ∀ i, a i0 ≤ a i) : IsMinEnergy (Matrix.diagonal a) (a i0) := by
  classical
  constructor
  · refine ⟨fun i => if i = i0 then 1 else 0, ?_, ?_⟩
    · intro hcon
      have h0 := congrFun hcon i0
      simp at h0
    · rw [form_diagonal]
      have h1 : ∀ i : Fin n,
          a i * ((emb (fun i => if i = i0 then (1 : ℤ) else 0)) i) ^ 2
            = if i = i0 then a i0 else 0 := by
        intro i; by_cases h : i = i0 <;> simp [emb, h]
      rw [sum_congr rfl fun i _ => h1 i, sum_ite_eq' univ i0 (fun _ => a i0)]
      simp
  · intro m hm
    obtain ⟨i, hi⟩ : ∃ i, m i ≠ 0 := by
      by_contra hcon
      push_neg at hcon
      exact hm (funext hcon)
    rw [form_diagonal]
    have hterm : a i0 ≤ a i * ((emb m) i) ^ 2 := by
      have hemb : (emb m) i = ((m i : ℚ)) := rfl
      rw [hemb]
      have hone : (1 : ℚ) ≤ ((m i : ℚ)) ^ 2 := by
        have h1 : (1 : ℤ) ≤ (m i) ^ 2 := by rcases lt_or_gt_of_ne hi with h | h <;> nlinarith
        exact_mod_cast h1
      nlinarith [hi0 i, (ha i).le,
        mul_nonneg (ha i).le (by linarith : (0 : ℚ) ≤ ((m i : ℚ)) ^ 2 - 1)]
    refine hterm.trans ?_
    exact single_le_sum (f := fun j => a j * ((emb m) j) ^ 2)
      (fun j _ => mul_nonneg (ha j).le (sq_nonneg _)) (mem_univ i)

/-- The deep hole is at squared distance at least `(Σ aᵢ)/4` from the lattice. -/
theorem diagonal_deepHole_ge {a : Fin n → ℚ} (ha : ∀ i, 0 < a i) (m : Fin n → ℤ) :
    (∑ i, a i) / 4 ≤ form (Matrix.diagonal a) (fun i => deepHole n i - emb m i) := by
  rw [form_diagonal, sum_div]
  refine sum_le_sum fun i _ => ?_
  have h := deepHole_term_ge (m i)
  have : deepHole n i - emb m i = 1 / 2 - (m i : ℚ) := rfl
  rw [this]
  nlinarith [(ha i).le, h]

/-- Rounding gives the matching covering bound `(Σ aᵢ)/4`. -/
theorem diagonal_covering_le {a : Fin n → ℚ} (ha : ∀ i, 0 < a i) (t : Fin n → ℚ) :
    ∃ m : Fin n → ℤ, form (Matrix.diagonal a) (fun i => t i - emb m i) ≤ (∑ i, a i) / 4 := by
  refine ⟨fun i => round (t i), ?_⟩
  rw [form_diagonal, sum_div]
  refine sum_le_sum fun i _ => ?_
  have h := abs_sub_round (t i)
  have h2 : |t i - (round (t i) : ℚ)| ^ 2 ≤ ((1 : ℚ) / 2) ^ 2 :=
    pow_le_pow_left₀ (abs_nonneg _) h 2
  rw [sq_abs] at h2
  have hterm : (t i - emb (fun i => round (t i)) i) ^ 2 ≤ 1 / 4 := by
    simpa [emb] using h2.trans_eq (by norm_num)
  nlinarith [(ha i).le, hterm, sq_nonneg (t i - emb (fun i => round (t i)) i)]

/-- The covering radius² of a positive diagonal form is exactly `(Σ aᵢ)/4`. -/
theorem diagonal_covering_radius_least {a : Fin n → ℚ} (ha : ∀ i, 0 < a i) (mu : ℚ)
    (hcov : ∀ t : Fin n → ℚ, ∃ m : Fin n → ℤ,
      form (Matrix.diagonal a) (fun i => t i - emb m i) ≤ mu) :
    (∑ i, a i) / 4 ≤ mu := by
  obtain ⟨m, hm⟩ := hcov (deepHole n)
  exact (diagonal_deepHole_ge ha m).trans hm

/-- The packing–covering ratio of a diagonal form is `(Σ aᵢ)/(min aᵢ)`, hence unbounded: with
all `aᵢ` equal to `1` the covering radius² is `n` times the bound `λ₁/4` of
`covering_ge_quarter_min`. -/
theorem diagonal_covering_gap {a : Fin n → ℚ} (ha : ∀ i, 0 < a i) (i0 : Fin n)
    (hn : 2 ≤ n) : a i0 / 4 < (∑ i, a i) / 4 := by
  have hlt : a i0 < ∑ i, a i := by
    obtain ⟨j, hj⟩ : ∃ j : Fin n, j ≠ i0 := by
      have : 1 < Fintype.card (Fin n) := by simpa using hn
      obtain ⟨j, hj⟩ := Fintype.exists_ne_of_one_lt_card this i0
      exact ⟨j, hj⟩
    have hsub : a i0 + a j ≤ ∑ i, a i := by
      have := Finset.add_sum_erase (univ.erase i0) a (mem_erase.mpr ⟨hj, mem_univ j⟩)
      have h2 : a i0 + ∑ i ∈ univ.erase i0, a i = ∑ i, a i :=
        Finset.add_sum_erase univ a (mem_univ i0)
      have h3 : a j ≤ ∑ i ∈ univ.erase i0, a i :=
        single_le_sum (f := a) (fun k _ => (ha k).le) (mem_erase.mpr ⟨hj, mem_univ j⟩)
      linarith
    have := ha j
    linarith
  linarith

end DiophantineLattice