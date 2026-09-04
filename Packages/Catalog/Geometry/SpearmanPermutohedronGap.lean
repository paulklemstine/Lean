import Mathlib

/-!
# The Spearman dial is a chordal distance on the permutohedron: quantisation and a rigidity gap

## Research context (FACT round-44 #2, exp 499, `T-DIAL-AXES: regime holds, u breaks`)

The measured quantity in the `T`-dial programme is a **Spearman rank correlation**
`rho(T, rate)` computed on a finite population of size `N`, with a pre-registered acceptance
band (`[0.71, 0.76]` for the paper-165 anchor) and a "dial" threshold `u` (the adopted
operating point is `u = 2.5`; the round-44 experiment records that `u = 3.5` degrades on
`5/5` seeds).  Every catalogue file in this thread has treated `rho` as an opaque real number
in `[-1, 1]`.  It is not: on a *tie-free* population of size `n` the Spearman statistic is a
rescaled squared Euclidean distance between two vertices of the **permutohedron**
`Π_{n-1} ⊂ ℝ^n`, and therefore takes only finitely many, explicitly quantised values.

This file makes that geometry precise and extracts the consequence that matters for the
"regime holds / `u` breaks" reading: **the dial cannot take a value in the open band just
below `1`.**  There is an explicit rigidity gap `12/(n³ − n)`; any reading strictly inside it
forces the two rankings to be literally equal.  Symmetrically the reading `−1` is attained
only at the antipode (the reversal permutation), which is the diameter of the permutohedron.

Reproduction context: `ResearchOutput/scripts/2026-08-21-resume/exp499_t_dial_axes.py`,
`exp499_result.json`, seeds `20260940`–`20260944`.

## Main results

Write `rk σ i = σ(i)` for the rank vector of a permutation `σ` of `Fin n`, and

* `D σ τ = ∑ i, (σ i − τ i)²` — the squared Euclidean (chordal) distance of two permutohedron
  vertices, i.e. the raw Spearman `∑ d²`;
* `sprho σ τ = 1 − 6 D σ τ / (n³ − n)` — the Spearman rank correlation.

### 1. Permutohedron geometry (Section 1–2)

* `perm_vertex_sum`, `perm_vertex_normSq` — every rank vector lies on the hyperplane
  `∑ xᵢ = n(n−1)/2` **and** on the sphere of squared radius `n(n−1)(2n−1)/6`: the `n!` vertices
  of the permutohedron are cospherical.  This is what makes `D` an affine function of the
  inner product (`D_eq_two_mul_sub`), hence what makes Spearman a *correlation* at all.
* `D_right_invariant` — `D` is right-invariant, so `D σ τ = D (στ⁻¹) 1`: the dial only sees the
  relative permutation.

### 2. Extremes and the diameter (Section 3)

* `ip_le_normSq` / `D_eq_zero_iff` — `D ≥ 0` with equality exactly at `σ = τ`.
* `ip_ge_reversed` and `D_le_D_rev` — the reversal `Fin.revPerm` is the antipode: it maximises
  `D` over all pairs, and `three_mul_D_rev` gives the exact diameter `3 · D_max = n(n² − 1)`.

### 3. Quantisation and the rigidity gap (Section 4)

* `D_even` — `D` is always **even** (a parity invariant of the permutohedron lattice: the
  displacement vector sums to zero).
* `D_two_le_of_ne` — hence `σ ≠ τ ⇒ D ≥ 2`: there is no vertex pair at squared distance `1`.
* `sprho_le_one_sub_gap` and `sprho_eq_one_of_gt_gap` — the dial's rigidity gap.  For `n ≥ 2`
  no Spearman value lies in the open interval `(1 − 12/(n³ − n), 1)`; a reading in that window
  certifies exact agreement.  Dually `sprho_neg_one_iff_rev` characterises the value `−1`.

### 4. Spearman really is Pearson (Section 5)

* `sprho_pearson_identity` — `12·(n·⟨σ,τ⟩ − (∑ i)²) = n²(n²−1) · sprho σ τ`, i.e. the
  normalisation `1 − 6∑d²/(n³−n)` is exactly the Pearson correlation of the two rank vectors.
  This is the theorem that licenses reading the dial as a correlation coefficient.

## Lab notes

Small-case data recorded by `decide` at the end of the file (`labnote_D_values_fin3`,
`labnote_diameter_fin3`): for `n = 3` the six vertices of the hexagon `Π₂` realise exactly the
squared distances `{0, 2, 6, 8}`; the value `1` (and every odd value) is absent, and the
diameter is `8 = 3·(3²−1)/3`, matching `three_mul_D_rev`.
-/

namespace Catalog.Geometry.SpearmanPermutohedron

open Finset

variable {n : ℕ}

/-! ## Section 1. Rank vectors and the permutohedron -/

/-- The rank vector of a permutation: the `i`-th coordinate of the permutohedron vertex
associated with `σ`. -/
def rk (σ : Equiv.Perm (Fin n)) (i : Fin n) : ℤ := ((σ i : Fin n) : ℕ)

/-- `∑ i` over `Fin n`, the common coordinate sum of all permutohedron vertices. -/
def linSum (n : ℕ) : ℤ := ∑ i : Fin n, ((i : ℕ) : ℤ)

/-- `∑ i²` over `Fin n`, the common squared radius of all permutohedron vertices. -/
def normSq (n : ℕ) : ℤ := ∑ i : Fin n, ((i : ℕ) : ℤ) ^ 2

/-- Raw Spearman statistic `∑ d²`: the squared Euclidean distance between two vertices. -/
def D (σ τ : Equiv.Perm (Fin n)) : ℤ := ∑ i, (rk σ i - rk τ i) ^ 2

/-- Euclidean inner product of two rank vectors. -/
def ip (σ τ : Equiv.Perm (Fin n)) : ℤ := ∑ i, rk σ i * rk τ i

@[simp] lemma rk_one (i : Fin n) : rk (1 : Equiv.Perm (Fin n)) i = ((i : ℕ) : ℤ) := rfl

lemma rk_mul (σ π : Equiv.Perm (Fin n)) (i : Fin n) : rk (σ * π) i = rk σ (π i) := rfl

/-- **All permutohedron vertices lie on a common hyperplane.** -/
theorem perm_vertex_sum (σ : Equiv.Perm (Fin n)) : ∑ i, rk σ i = linSum n :=
  Equiv.sum_comp σ (fun i => ((i : ℕ) : ℤ))

/-- **All permutohedron vertices lie on a common sphere.** -/
theorem perm_vertex_normSq (σ : Equiv.Perm (Fin n)) : ∑ i, (rk σ i) ^ 2 = normSq n :=
  Equiv.sum_comp σ (fun i => ((i : ℕ) : ℤ) ^ 2)

/-- Gauss' sum, in the form needed for the Spearman normalisation. -/
theorem two_mul_linSum (n : ℕ) : 2 * linSum n = (n : ℤ) * (n - 1) := by
  induction n with
  | zero => simp [linSum]
  | succ m ih =>
      unfold linSum at *
      rw [Fin.sum_univ_castSucc]
      simp only [Fin.val_castSucc, Fin.val_last]
      push_cast
      linarith

/-- The square-pyramidal sum, in the form needed for the Spearman normalisation. -/
theorem six_mul_normSq (n : ℕ) : 6 * normSq n = (n : ℤ) * (n - 1) * (2 * n - 1) := by
  induction n with
  | zero => simp [normSq]
  | succ m ih =>
      unfold normSq at *
      rw [Fin.sum_univ_castSucc]
      simp only [Fin.val_castSucc, Fin.val_last]
      push_cast
      nlinarith [ih]

/-! ## Section 2. `D` as a chordal distance -/

/-- Because all vertices are cospherical, the squared distance is an affine function of the
inner product.  This is the structural reason the Spearman statistic is a correlation. -/
theorem D_eq_two_mul_sub (σ τ : Equiv.Perm (Fin n)) : D σ τ = 2 * (normSq n - ip σ τ) := by
  unfold D ip
  have h : ∀ i : Fin n,
      (rk σ i - rk τ i) ^ 2 = (rk σ i) ^ 2 + (rk τ i) ^ 2 - 2 * (rk σ i * rk τ i) := by
    intro i; ring
  simp_rw [h]
  rw [Finset.sum_sub_distrib, Finset.sum_add_distrib, perm_vertex_normSq, perm_vertex_normSq,
    ← Finset.mul_sum]
  ring

theorem D_nonneg (σ τ : Equiv.Perm (Fin n)) : 0 ≤ D σ τ :=
  Finset.sum_nonneg fun _ _ => sq_nonneg _

theorem D_comm (σ τ : Equiv.Perm (Fin n)) : D σ τ = D τ σ := by
  unfold D; exact Finset.sum_congr rfl fun i _ => by ring

/-- The dial is right-invariant: it only depends on the relative permutation. -/
theorem D_right_invariant (σ τ π : Equiv.Perm (Fin n)) : D (σ * π) (τ * π) = D σ τ := by
  unfold D
  simp_rw [rk_mul]
  exact Equiv.sum_comp π (fun i => (rk σ i - rk τ i) ^ 2)

theorem D_eq_D_one (σ τ : Equiv.Perm (Fin n)) : D σ τ = D (σ * τ⁻¹) 1 := by
  unfold D
  rw [← Equiv.sum_comp τ (fun i => (rk (σ * τ⁻¹) i - rk 1 i) ^ 2)]
  exact Finset.sum_congr rfl fun i _ => by simp [rk]

theorem ip_eq_ip_one (σ τ : Equiv.Perm (Fin n)) : ip σ τ = ip (σ * τ⁻¹) 1 := by
  unfold ip
  rw [← Equiv.sum_comp τ (fun i => rk (σ * τ⁻¹) i * rk 1 i)]
  exact Finset.sum_congr rfl fun i _ => by simp [rk]

theorem D_eq_zero_iff (σ τ : Equiv.Perm (Fin n)) : D σ τ = 0 ↔ σ = τ := by
  constructor
  · intro h
    have hall := (Finset.sum_eq_zero_iff_of_nonneg
      (fun i _ => sq_nonneg (rk σ i - rk τ i))).1 h
    ext i
    have hi := hall i (Finset.mem_univ i)
    have hrk : rk σ i = rk τ i := by nlinarith [sq_nonneg (rk σ i - rk τ i)]
    unfold rk at hrk
    exact_mod_cast hrk
  · rintro rfl; simp [D]

/-! ## Section 3. Extremes: the identity and the antipodal reversal -/

/-- The inner product is maximised by agreement (this is the trivial half of rearrangement,
made trivial by cosphericity). -/
theorem ip_le_normSq (σ τ : Equiv.Perm (Fin n)) : ip σ τ ≤ normSq n := by
  have h := D_nonneg σ τ
  rw [D_eq_two_mul_sub] at h
  linarith

lemma rk_rev_mul (μ : Equiv.Perm (Fin n)) (i : Fin n) :
    rk (Fin.revPerm * μ) i = (n : ℤ) - 1 - rk μ i := by
  have hlt : ((μ i : Fin n) : ℕ) < n := (μ i).isLt
  have hval : (Fin.revPerm * μ : Equiv.Perm (Fin n)) i = Fin.rev (μ i) := rfl
  unfold rk
  rw [hval, Fin.val_rev]
  omega

/-- The reversal permutation is antipodal: it minimises the inner product. -/
theorem ip_ge_reversed (σ τ : Equiv.Perm (Fin n)) :
    ((n : ℤ) - 1) * linSum n - normSq n ≤ ip σ τ := by
  rw [ip_eq_ip_one]
  set μ := σ * τ⁻¹ with hμ
  have key : ip (Fin.revPerm * μ) 1 = ((n : ℤ) - 1) * linSum n - ip μ 1 := by
    unfold ip
    rw [show (((n : ℤ) - 1) * linSum n - ∑ i, rk μ i * rk 1 i)
        = ∑ i, (((n : ℤ) - 1) * rk 1 i - rk μ i * rk 1 i) by
      rw [Finset.sum_sub_distrib, ← Finset.mul_sum, perm_vertex_sum]]
    exact Finset.sum_congr rfl fun i _ => by rw [rk_rev_mul]; ring
  have hub := ip_le_normSq (Fin.revPerm * μ) 1
  rw [key] at hub
  linarith

/-- The inner product of the reversal with the identity. -/
lemma ip_rev_one (n : ℕ) :
    ip (Fin.revPerm : Equiv.Perm (Fin n)) 1 = ((n : ℤ) - 1) * linSum n - normSq n := by
  have h : ∀ i : Fin n, rk (Fin.revPerm : Equiv.Perm (Fin n)) i * rk 1 i
      = ((n : ℤ) - 1) * ((i : ℕ) : ℤ) - ((i : ℕ) : ℤ) ^ 2 := by
    intro i
    have hr := rk_rev_mul (1 : Equiv.Perm (Fin n)) i
    rw [mul_one] at hr
    rw [hr, rk_one]
    ring
  unfold ip
  simp_rw [h]
  rw [Finset.sum_sub_distrib, ← Finset.mul_sum]
  rfl

/-- The exact diameter of the permutohedron: `D_max = n(n²−1)/3`. -/
theorem three_mul_D_rev (n : ℕ) :
    3 * D (Fin.revPerm : Equiv.Perm (Fin n)) 1 = (n : ℤ) * ((n : ℤ) ^ 2 - 1) := by
  have h1 := two_mul_linSum n
  have h2 := six_mul_normSq n
  rw [D_eq_two_mul_sub, ip_rev_one]
  linear_combination 2 * h2 - 3 * ((n : ℤ) - 1) * h1

/-- **The reversal realises the diameter**: no pair of rankings is further apart. -/
theorem D_le_D_rev (σ τ : Equiv.Perm (Fin n)) :
    D σ τ ≤ D (Fin.revPerm : Equiv.Perm (Fin n)) 1 := by
  have h1 := ip_ge_reversed σ τ
  rw [D_eq_two_mul_sub, D_eq_two_mul_sub, ip_rev_one]
  linarith

/-! ## Section 4. Quantisation and the rigidity gap -/

/-- **Parity invariant.**  The displacement vector between two permutohedron vertices sums to
zero, and `x² ≡ x (mod 2)`, so the raw Spearman statistic is always even. -/
theorem D_even (σ τ : Equiv.Perm (Fin n)) : (2 : ℤ) ∣ D σ τ := by
  have h0 : ∑ i, (rk σ i - rk τ i) = 0 := by
    rw [Finset.sum_sub_distrib, perm_vertex_sum, perm_vertex_sum]; ring
  have hD : D σ τ = ∑ i, ((rk σ i - rk τ i) ^ 2 - (rk σ i - rk τ i)) := by
    unfold D; rw [Finset.sum_sub_distrib, h0]; ring
  rw [hD]
  refine Finset.dvd_sum fun i _ => ?_
  rw [show (rk σ i - rk τ i) ^ 2 - (rk σ i - rk τ i)
      = (rk σ i - rk τ i - 1) * ((rk σ i - rk τ i - 1) + 1) by ring]
  exact (Int.even_mul_succ_self _).two_dvd

/-- **Rigidity gap (integer form).**  Distinct rankings are at squared distance at least `2`;
the value `1` is unattainable. -/
theorem D_two_le_of_ne {σ τ : Equiv.Perm (Fin n)} (h : σ ≠ τ) : 2 ≤ D σ τ := by
  have h1 := D_even σ τ
  have h2 := D_nonneg σ τ
  have h3 : D σ τ ≠ 0 := fun hc => h ((D_eq_zero_iff σ τ).1 hc)
  omega

/-! ## Section 5. The Spearman correlation -/

/-- The Spearman rank correlation coefficient `1 − 6∑d²/(n³ − n)`. -/
def sprho (σ τ : Equiv.Perm (Fin n)) : ℚ :=
  1 - 6 * ((D σ τ : ℚ)) / ((n : ℚ) ^ 3 - (n : ℚ))

lemma cube_sub_pos (hn : 2 ≤ n) : (0 : ℚ) < (n : ℚ) ^ 3 - (n : ℚ) := by
  have h : (2 : ℚ) ≤ (n : ℚ) := by exact_mod_cast hn
  have hsq : (0 : ℚ) < (n : ℚ) ^ 2 - 1 := by nlinarith
  have hn0 : (0 : ℚ) < (n : ℚ) := by linarith
  nlinarith [mul_pos hn0 hsq]

/-- The rescaled diameter bound, in `ℚ`. -/
lemma three_mul_D_le (σ τ : Equiv.Perm (Fin n)) :
    (3 : ℚ) * (D σ τ : ℚ) ≤ (n : ℚ) ^ 3 - (n : ℚ) := by
  have hle : (3 : ℤ) * D σ τ ≤ (n : ℤ) * ((n : ℤ) ^ 2 - 1) := by
    have h := D_le_D_rev σ τ
    have h2 := three_mul_D_rev n
    linarith
  have hQ : (3 : ℚ) * (D σ τ : ℚ) ≤ (n : ℚ) * ((n : ℚ) ^ 2 - 1) := by exact_mod_cast hle
  nlinarith [hQ]

theorem sprho_le_one (σ τ : Equiv.Perm (Fin n)) (hn : 2 ≤ n) : sprho σ τ ≤ 1 := by
  have hpos := cube_sub_pos hn
  have hD : (0 : ℚ) ≤ (D σ τ : ℚ) := by exact_mod_cast D_nonneg σ τ
  have h : 0 ≤ 6 * (D σ τ : ℚ) / ((n : ℚ) ^ 3 - (n : ℚ)) := by positivity
  unfold sprho
  linarith

theorem neg_one_le_sprho (σ τ : Equiv.Perm (Fin n)) (hn : 2 ≤ n) : -1 ≤ sprho σ τ := by
  have hpos := cube_sub_pos hn
  have key : 6 * (D σ τ : ℚ) / ((n : ℚ) ^ 3 - (n : ℚ)) ≤ 2 := by
    rw [div_le_iff₀ hpos]
    linarith [three_mul_D_le σ τ]
  unfold sprho
  linarith

theorem sprho_eq_one_iff (σ τ : Equiv.Perm (Fin n)) (hn : 2 ≤ n) : sprho σ τ = 1 ↔ σ = τ := by
  have hpos := cube_sub_pos hn
  constructor
  · intro h
    unfold sprho at h
    have h6 : 6 * (D σ τ : ℚ) / ((n : ℚ) ^ 3 - (n : ℚ)) = 0 := by linarith
    rcases div_eq_zero_iff.1 h6 with h' | h'
    · have : (D σ τ : ℚ) = 0 := by linarith
      exact (D_eq_zero_iff σ τ).1 (by exact_mod_cast this)
    · exact absurd h' (ne_of_gt hpos)
  · rintro rfl
    simp [sprho, (D_eq_zero_iff σ σ).2 rfl]

/-- **Rigidity gap for the dial.**  No Spearman reading lies strictly between
`1 − 12/(n³ − n)` and `1`. -/
theorem sprho_le_one_sub_gap {σ τ : Equiv.Perm (Fin n)} (hn : 2 ≤ n) (h : σ ≠ τ) :
    sprho σ τ ≤ 1 - 12 / ((n : ℚ) ^ 3 - (n : ℚ)) := by
  have hpos := cube_sub_pos hn
  have h2 : (2 : ℚ) ≤ (D σ τ : ℚ) := by exact_mod_cast D_two_le_of_ne h
  unfold sprho
  have : (12 : ℚ) / ((n : ℚ) ^ 3 - (n : ℚ)) ≤ 6 * (D σ τ : ℚ) / ((n : ℚ) ^ 3 - (n : ℚ)) := by
    gcongr
    linarith
  linarith

/-- Contrapositive form: a reading inside the gap certifies exact agreement of the rankings. -/
theorem sprho_eq_one_of_gt_gap {σ τ : Equiv.Perm (Fin n)} (hn : 2 ≤ n)
    (h : 1 - 12 / ((n : ℚ) ^ 3 - (n : ℚ)) < sprho σ τ) : σ = τ := by
  by_contra hc
  exact absurd (sprho_le_one_sub_gap hn hc) (not_le.2 h)

/-- The dial reads exactly `−1` only at the antipode, i.e. at the diameter of the
permutohedron. -/
theorem sprho_neg_one_iff_rev (σ τ : Equiv.Perm (Fin n)) (hn : 2 ≤ n) :
    sprho σ τ = -1 ↔ D σ τ = D (Fin.revPerm : Equiv.Perm (Fin n)) 1 := by
  have hpos := cube_sub_pos hn
  have hne : ((n : ℚ) ^ 3 - (n : ℚ)) ≠ 0 := ne_of_gt hpos
  have hrevQ : (3 : ℚ) * (D (Fin.revPerm : Equiv.Perm (Fin n)) 1 : ℚ)
      = (n : ℚ) ^ 3 - (n : ℚ) := by
    have h := three_mul_D_rev n
    have h' : (3 : ℚ) * (D (Fin.revPerm : Equiv.Perm (Fin n)) 1 : ℚ)
        = (n : ℚ) * ((n : ℚ) ^ 2 - 1) := by exact_mod_cast h
    rw [h']; ring
  have hequiv : sprho σ τ = -1 ↔ 6 * (D σ τ : ℚ) / ((n : ℚ) ^ 3 - (n : ℚ)) = 2 := by
    unfold sprho; constructor <;> intro h <;> linarith
  rw [hequiv, div_eq_iff hne]
  constructor
  · intro h
    have : (D σ τ : ℚ) = (D (Fin.revPerm : Equiv.Perm (Fin n)) 1 : ℚ) := by linarith
    exact_mod_cast this
  · intro h
    rw [h]
    linarith

/-- **Spearman is Pearson.**  The centred inner product of the two rank vectors equals
`n²(n²−1)/12` times `sprho`: the normalisation `1 − 6∑d²/(n³−n)` is exactly the Pearson
correlation coefficient of the ranks.  This is the theorem that licenses reading the dial as a
correlation coefficient. -/
theorem sprho_pearson_identity (σ τ : Equiv.Perm (Fin n)) (hn : 2 ≤ n) :
    12 * ((n : ℚ) * (ip σ τ : ℚ) - ((linSum n : ℚ)) ^ 2)
      = (n : ℚ) ^ 2 * ((n : ℚ) ^ 2 - 1) * sprho σ τ := by
  have hpos := cube_sub_pos hn
  have hne : ((n : ℚ) ^ 3 - (n : ℚ)) ≠ 0 := ne_of_gt hpos
  have h1 : 2 * (linSum n : ℚ) = (n : ℚ) * ((n : ℚ) - 1) := by
    exact_mod_cast two_mul_linSum n
  have h2 : 6 * (normSq n : ℚ) = (n : ℚ) * ((n : ℚ) - 1) * (2 * (n : ℚ) - 1) := by
    exact_mod_cast six_mul_normSq n
  have h3 : (D σ τ : ℚ) = 2 * ((normSq n : ℚ) - (ip σ τ : ℚ)) := by
    exact_mod_cast D_eq_two_mul_sub σ τ
  have hsp : (n : ℚ) ^ 2 * ((n : ℚ) ^ 2 - 1) * sprho σ τ
      = (n : ℚ) ^ 2 * ((n : ℚ) ^ 2 - 1) - 6 * (D σ τ : ℚ) * (n : ℚ) := by
    have hn0 : (n : ℚ) ≠ 0 := by
      have : (2 : ℚ) ≤ (n : ℚ) := by exact_mod_cast hn
      intro hc; rw [hc] at this; linarith
    have hne2 : (n : ℚ) ^ 2 - 1 ≠ 0 := by
      have : (2 : ℚ) ≤ (n : ℚ) := by exact_mod_cast hn
      intro hc; nlinarith
    unfold sprho
    field_simp
  rw [hsp]
  linear_combination (6 * (n : ℚ)) * h3 + (2 * (n : ℚ)) * h2 +
    (-3 * (2 * (linSum n : ℚ) + (n : ℚ) * ((n : ℚ) - 1))) * h1


/-! ## Lab notes: small-case data (`n = 3`, the hexagon `Π₂`) -/

/-- The six vertices of the hexagon realise only the squared distances `{0, 2, 6, 8}`:
in particular every value is even, confirming `D_even`, and `1` never occurs. -/
theorem labnote_D_values_fin3 :
    ∀ σ τ : Equiv.Perm (Fin 3), D σ τ = 0 ∨ D σ τ = 2 ∨ D σ τ = 6 ∨ D σ τ = 8 := by
  decide

/-- The hexagon's diameter is `8 = 3(3²−1)/3`, matching `three_mul_D_rev`. -/
theorem labnote_diameter_fin3 : D (Fin.revPerm : Equiv.Perm (Fin 3)) 1 = 8 := by
  decide

end Catalog.Geometry.SpearmanPermutohedron