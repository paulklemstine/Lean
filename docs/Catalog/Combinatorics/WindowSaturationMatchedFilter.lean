/-
# Cycle 1: the window statistic, the matched filter, and the saturation theorem

This is the base file of the `WindowSaturation` family.  It fixes the objects
that the later cycles (`WindowSaturationDesigns`, `WindowSaturationBimodal`,
`WindowSaturationRealizability`, `WindowSaturationExponentDial`) all speak
about.

The instrument.  A *window model* `Model n m` is a family of `m` pairwise
orthogonal nonzero columns `v_0, …, v_{m-1}` in `ℝⁿ` together with a nonzero
response `y`.  Two scalar summaries of a column are used throughout:

* `a i = ⟪v i, y⟫` — the *signal* of column `i`;
* `s i = ⟪v i, v i⟫` — the *mass* of column `i`.

Given a weight sequence `w` and a *window edge* `B`, the window statistic
aggregates the first `B` columns into `S_{w,B} = ∑_{i<B} w i • v i` and reports
the squared cosine

  `R²(w, B) = ⟪S_{w,B}, y⟫² / (‖S_{w,B}‖² ‖y‖²) = num(w,B)² / (den(w,B) ‖y‖²)`.

Everything downstream is a statement about how `R²(w, ·)` moves as the window
edge `B` is opened.

Main results here:

* `Model.unique_interior_argmax` — **the saturation theorem**.  If the weight is
  *matched* on a signal block `[0, t)` (`w i a i = ρ w i² s i`, with positive
  contribution) and every later column inside the window is pure noise
  (`a i = 0`) but still carries mass (`w i ≠ 0`), then the window curve has a
  *unique* maximum at the interior edge `t`: `R²(w, B) < R²(w, t)` for every
  `B ≤ m` with `B ≠ t`.  This is the formal content of a measured `B*`.
* `Model.R2_mf` — the matched filter `mf i = a i / s i` realises the *energy*
  `E B = ∑_{i<B} a i² / s i`, i.e. `R²(mf, B) = E B / ‖y‖²`.  Since `E` is
  nondecreasing, the matched weight can never produce an interior peak; a
  measured `B*` is therefore a statement about the *weight*, not the columns.
-/
import Mathlib

open Finset

namespace WindowSaturation

/-- The Euclidean inner product on `Fin n → ℝ`. -/
def dot {n : ℕ} (u v : Fin n → ℝ) : ℝ := ∑ j, u j * v j

lemma dot_comm {n : ℕ} (u v : Fin n → ℝ) : dot u v = dot v u := by
  simp only [dot]
  exact Finset.sum_congr rfl fun j _ => mul_comm _ _

lemma dot_self_nonneg {n : ℕ} (u : Fin n → ℝ) : 0 ≤ dot u u :=
  Finset.sum_nonneg fun _ _ => mul_self_nonneg _

/-- A **window model**: `m` pairwise orthogonal nonzero columns in `ℝⁿ`
together with a nonzero response. -/
structure Model (n m : ℕ) where
  /-- the columns -/
  v : ℕ → Fin n → ℝ
  /-- the response -/
  y : Fin n → ℝ
  /-- columns inside the window are nonzero -/
  self_pos : ∀ i < m, 0 < dot (v i) (v i)
  /-- columns inside the window are pairwise orthogonal -/
  orth : ∀ i < m, ∀ j < m, i ≠ j → dot (v i) (v j) = 0
  /-- the response is nonzero -/
  resp_pos : 0 < dot y y

namespace Model

variable {n m : ℕ} (M : Model n m)

/-- The signal of column `i`: `⟪v i, y⟫`. -/
def a (i : ℕ) : ℝ := dot (M.v i) M.y

/-- The mass of column `i`: `‖v i‖²`. -/
def s (i : ℕ) : ℝ := dot (M.v i) (M.v i)

/-- The numerator `⟪S_{w,B}, y⟫` of the window statistic. -/
def num (w : ℕ → ℝ) (B : ℕ) : ℝ := ∑ i ∈ range B, w i * M.a i

/-- The denominator `‖S_{w,B}‖²` of the window statistic (orthogonality of the
columns has already been used to diagonalise it). -/
def den (w : ℕ → ℝ) (B : ℕ) : ℝ := ∑ i ∈ range B, (w i) ^ 2 * M.s i

/-- The window score `R²(w, B)`. -/
noncomputable def R2 (w : ℕ → ℝ) (B : ℕ) : ℝ := (M.num w B) ^ 2 / (M.den w B * dot M.y M.y)

/-- The matched filter weight `a i / s i`. -/
noncomputable def mf (i : ℕ) : ℝ := M.a i / M.s i

/-- The accumulated matched-filter energy `∑_{i<B} a i² / s i`. -/
noncomputable def E (B : ℕ) : ℝ := ∑ i ∈ range B, (M.a i) ^ 2 / M.s i

lemma s_nonneg (i : ℕ) : 0 ≤ M.s i := dot_self_nonneg _

lemma s_pos {i : ℕ} (hi : i < m) : 0 < M.s i := M.self_pos i hi

@[simp] lemma num_zero (w : ℕ → ℝ) : M.num w 0 = 0 := by simp [num]

@[simp] lemma den_zero (w : ℕ → ℝ) : M.den w 0 = 0 := by simp [den]

lemma num_succ (w : ℕ → ℝ) (B : ℕ) :
    M.num w (B + 1) = M.num w B + w B * M.a B := Finset.sum_range_succ _ _

lemma den_succ (w : ℕ → ℝ) (B : ℕ) :
    M.den w (B + 1) = M.den w B + (w B) ^ 2 * M.s B := Finset.sum_range_succ _ _

lemma den_nonneg (w : ℕ → ℝ) (B : ℕ) : 0 ≤ M.den w B :=
  Finset.sum_nonneg fun i _ => mul_nonneg (sq_nonneg _) (M.s_nonneg i)

/-- The denominator is monotone in the window edge: opening the window can only
add mass. -/
lemma den_mono (w : ℕ → ℝ) {B C : ℕ} (h : B ≤ C) : M.den w B ≤ M.den w C := by
  refine Finset.sum_le_sum_of_subset_of_nonneg
    (Finset.range_subset.mpr fun x hx => Finset.mem_range.mpr (lt_of_lt_of_le hx h)) ?_
  intro i _ _
  exact mul_nonneg (sq_nonneg _) (M.s_nonneg i)

/-- Strict growth of the denominator across a block of massive columns. -/
lemma den_lt_den (w : ℕ → ℝ) {B C : ℕ} (hBC : B < C) (hCm : C ≤ m)
    (hw : ∀ i, B ≤ i → i < C → w i ≠ 0) : M.den w B < M.den w C := by
  have hstep : ∀ k, B ≤ k → k < C → M.den w k < M.den w (k + 1) := by
    intro k hk hkC
    rw [den_succ]
    have : 0 < (w k) ^ 2 * M.s k :=
      mul_pos (sq_pos_of_ne_zero (hw k hk hkC)) (M.s_pos (lt_of_lt_of_le hkC hCm))
    linarith
  -- induct on the gap
  have key : ∀ d, 0 < d → B + d ≤ C → M.den w B < M.den w (B + d) := by
    intro d
    induction d with
    | zero => intro h; exact absurd h (lt_irrefl 0)
    | succ k ih =>
        intro _ hle
        rcases Nat.eq_zero_or_pos k with hk | hk
        · subst hk
          simpa using hstep B le_rfl (by omega)
        · have h1 : M.den w B < M.den w (B + k) := ih hk (by omega)
          have h2 : M.den w (B + k) < M.den w (B + k + 1) :=
            hstep (B + k) (by omega) (by omega)
          calc M.den w B < M.den w (B + k) := h1
            _ < M.den w (B + k + 1) := h2
            _ = M.den w (B + (k + 1)) := by ring_nf
  have := key (C - B) (by omega) (by omega)
  simpa [Nat.add_sub_cancel' hBC.le] using this

lemma R2_nonneg (w : ℕ → ℝ) (B : ℕ) : 0 ≤ M.R2 w B :=
  div_nonneg (sq_nonneg _) (mul_nonneg (M.den_nonneg w B) (le_of_lt M.resp_pos))

/-- Past the signal block the numerator no longer moves. -/
lemma num_const_after {w : ℕ → ℝ} {t B : ℕ}
    (hnoise : ∀ i, t ≤ i → i < m → M.a i = 0) (htB : t ≤ B) (hBm : B ≤ m) :
    M.num w B = M.num w t := by
  induction B with
  | zero =>
      have : t = 0 := by omega
      rw [this]
  | succ k ih =>
      rcases Nat.lt_or_ge t (k + 1) with hk | hk
      · have hk' : t ≤ k := by omega
        rw [num_succ, ih hk' (by omega), hnoise k hk' (by omega)]
        ring
      · have : t = k + 1 := by omega
        rw [this]

/-! ## The matched filter -/

/-- The matched filter realises the accumulated energy. -/
theorem R2_mf {B : ℕ} (hBm : B ≤ m) : M.R2 M.mf B = M.E B / dot M.y M.y := by
  have hs : ∀ i ∈ range B, M.s i ≠ 0 := by
    intro i hi
    exact ne_of_gt (M.s_pos (lt_of_lt_of_le (Finset.mem_range.mp hi) hBm))
  have hnum : M.num M.mf B = M.E B := by
    refine Finset.sum_congr rfl fun i _ => ?_
    simp only [mf]
    ring
  have hden : M.den M.mf B = M.E B := by
    refine Finset.sum_congr rfl fun i hi => ?_
    have hsi := hs i hi
    simp only [mf]
    field_simp
  have hE : 0 ≤ M.E B :=
    Finset.sum_nonneg fun i _ => div_nonneg (sq_nonneg _) (M.s_nonneg i)
  rw [R2, hnum, hden]
  rcases eq_or_lt_of_le hE with h | h
  · rw [← h]; simp
  · rw [sq, mul_div_mul_left _ _ (ne_of_gt h)]

/-! ## The saturation theorem -/

variable {w : ℕ → ℝ} {t : ℕ} {rho : ℝ}

/-- On a matched signal block the numerator is `ρ` times the denominator. -/
lemma num_eq_rho_den (hmatch : ∀ i < t, w i * M.a i = rho * ((w i) ^ 2 * M.s i))
    {B : ℕ} (hB : B ≤ t) : M.num w B = rho * M.den w B := by
  induction B with
  | zero => simp
  | succ k ih =>
      rw [num_succ, den_succ, ih (by omega), hmatch k (by omega)]
      ring

/-- **The saturation theorem.**  A weight matched on the signal block `[0, t)`
and merely massive afterwards produces a *unique* argmax of the window curve,
located at the interior edge `t`.

No hypothesis relating `t` and `m` is needed: the conclusion only ranges over
windows `B ≤ m`. -/
theorem unique_interior_argmax (ht : 1 ≤ t)
    (hmatch : ∀ i < t, w i * M.a i = rho * ((w i) ^ 2 * M.s i))
    (hsig : ∀ i < t, 0 < w i * M.a i)
    (hnoise : ∀ i, t ≤ i → i < m → M.a i = 0)
    (hw : ∀ i, t ≤ i → i < m → w i ≠ 0) :
    ∀ B ≤ m, B ≠ t → M.R2 w B < M.R2 w t := by
  have hY : 0 < dot M.y M.y := M.resp_pos
  -- every signal column carries positive weighted mass
  have hterm : ∀ i < t, 0 < (w i) ^ 2 * M.s i := by
    intro i hi
    rcases lt_or_eq_of_le (mul_nonneg (sq_nonneg (w i)) (M.s_nonneg i)) with h | h
    · exact h
    · exfalso
      have := hsig i hi
      rw [hmatch i hi, ← h] at this
      simp at this
  have hrho : 0 < rho := by
    have h0 : 0 < w 0 * M.a 0 := hsig 0 (by omega)
    rw [hmatch 0 (by omega)] at h0
    have hX : 0 < (w 0) ^ 2 * M.s 0 := hterm 0 (by omega)
    by_contra hc
    push_neg at hc
    nlinarith
  -- the denominator is strictly increasing over the signal block
  have hden_lt : ∀ {B C : ℕ}, B < C → C ≤ t → M.den w B < M.den w C := by
    intro B C hBC hCt
    have key : ∀ k, B ≤ k → k < C → M.den w k < M.den w (k + 1) := by
      intro k _ hkC
      rw [den_succ]
      have := hterm k (lt_of_lt_of_le hkC hCt)
      linarith
    have gap : ∀ d, 0 < d → B + d ≤ C → M.den w B < M.den w (B + d) := by
      intro d
      induction d with
      | zero => intro h; exact absurd h (lt_irrefl 0)
      | succ k ih =>
          intro _ hle
          rcases Nat.eq_zero_or_pos k with hk | hk
          · subst hk; simpa using key B le_rfl (by omega)
          · have h1 := ih hk (by omega)
            have h2 := key (B + k) (by omega) (by omega)
            calc M.den w B < M.den w (B + k) := h1
              _ < M.den w (B + k + 1) := h2
              _ = M.den w (B + (k + 1)) := by ring_nf
    have := gap (C - B) (by omega) (by omega)
    simpa [Nat.add_sub_cancel' hBC.le] using this
  have hdt : 0 < M.den w t := by
    have := hden_lt (B := 0) (C := t) (by omega) le_rfl
    simpa using this
  have hR2t : M.R2 w t = rho ^ 2 * M.den w t / dot M.y M.y := by
    rw [R2, num_eq_rho_den M hmatch le_rfl]
    field_simp
  intro B hBm hBt
  rcases Nat.lt_or_ge B t with hlt | hge
  · -- inside the signal block: the score is `ρ² · den / ‖y‖²`, strictly increasing
    have hdB : M.den w B < M.den w t := hden_lt hlt le_rfl
    rcases eq_or_lt_of_le (M.den_nonneg w B) with h0 | h0
    · have : M.R2 w B = 0 := by
        rw [R2, num_eq_rho_den M hmatch hlt.le, ← h0]
        simp
      rw [this, hR2t]
      exact div_pos (mul_pos (pow_pos hrho 2) hdt) hY
    · have hRB : M.R2 w B = rho ^ 2 * M.den w B / dot M.y M.y := by
        rw [R2, num_eq_rho_den M hmatch hlt.le]
        field_simp
      rw [hRB, hR2t]
      have hrho2 : 0 < rho ^ 2 := by positivity
      have hmul : rho ^ 2 * M.den w B < rho ^ 2 * M.den w t := by nlinarith
      exact (div_lt_div_iff_of_pos_right hY).mpr hmul
  · -- beyond the signal block: the numerator is frozen, the denominator grows
    have hBt' : t < B := lt_of_le_of_ne hge (Ne.symm hBt)
    have hnumB : M.num w B = M.num w t := num_const_after M hnoise hge hBm
    have hdenB : M.den w t < M.den w B := by
      refine den_lt_den M w hBt' hBm ?_
      intro i hi hiB
      exact hw i hi (lt_of_lt_of_le hiB hBm)
    have hdB : 0 < M.den w B := lt_trans hdt hdenB
    rw [R2, R2, hnumB]
    have hnt : (0:ℝ) < (M.num w t) ^ 2 := by
      rw [num_eq_rho_den M hmatch le_rfl]
      positivity
    exact div_lt_div_of_pos_left hnt (mul_pos hdt hY) (by nlinarith)

end Model

end WindowSaturation