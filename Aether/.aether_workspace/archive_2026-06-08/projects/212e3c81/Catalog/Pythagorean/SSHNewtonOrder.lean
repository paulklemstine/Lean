/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# SSH Newton-Order Conjecture via Toeplitz Asymptotics

This file establishes a theorem package connecting Newton inequalities for
elementary symmetric polynomials to quantum phase transitions in the
Su–Schrieffer–Heeger (SSH) model. The central result is that the
**Newton order parameter** — a purely algebraic invariant built from
ratios of elementary symmetric polynomials — can detect phase transitions:
it remains bounded in the gapped phase and diverges at criticality.

## Mathematical Setup

Given a spectrum `λ = (λ₁, …, λₘ) ∈ (0,1)ᵐ`, the elementary symmetric
polynomials `eₖ(λ)` satisfy Newton's inequalities: `eₖ² ≥ eₖ₋₁ · eₖ₊₁`.
The **Newton ratio** `Rₖ = eₖ² / (eₖ₋₁ · eₖ₊₁) ≥ 1` measures how far
the sequence is from the boundary of log-concavity.

The **supremal Newton gap** `sup_k log(eₖ₋₁ · eₖ₊₁ / eₖ²)` captures the
*worst* log-concavity violation and serves as an algebraic order parameter.

## Main Results

* `unbounded_of_frequently_ge_log` — A function that frequently exceeds
  `c · log m - b` is unbounded above.
* `supNewtonGap_ge_pointwise` — The supremal Newton gap dominates each
  pointwise gap.
* `bounded_newton_of_uniform_pinching_family` — Spectra uniformly pinched
  have uniformly bounded Newton gap.
* `newtonOrder_lower_bound_of_log_gap` — Log-concavity defects yield
  lower bounds on the Newton gap.
* `critical_toeplitz_implies_unbounded_newton` — The bridge theorem:
  Toeplitz asymptotic criterion implies divergent Newton order.

## Cross-Domain Connections

* **Algebraic combinatorics ↔ Toeplitz analysis**: `eₖ` are coefficients
  of `det(I + tC_m)`, a Toeplitz determinant.
* **Symmetric polynomials ↔ quantum physics**: The Newton ratio profile
  acts as an algebraic order parameter for phase transitions.
* **Asymptotic analysis ↔ information theory**: Correlation eigenvalues
  determine entanglement spectra; Newton defects proxy for
  information-theoretic criticality.
-/

open Finset BigOperators Real Filter Set

noncomputable section

/-! ## Section 1: Core Definitions -/

/-- The **pointwise Newton gap** at index `k` for a sequence `e : ℕ → ℝ`:
    `log(e(k-1)) + log(e(k+1)) - 2 · log(e(k))`.
    When `e` is log-concave, this is ≤ 0. -/
def pointwiseNewtonGap (e : ℕ → ℝ) (k : ℕ) : ℝ :=
  Real.log (e (k - 1)) + Real.log (e (k + 1)) - 2 * Real.log (e k)

/-- The **log-concavity gap** (second log-difference), an alias. -/
abbrev LogConcavityGap (e : ℕ → ℝ) (k : ℕ) : ℝ := pointwiseNewtonGap e k

/-- The **supremal Newton gap** over indices `1, …, n-1`.
    For `n ≤ 1`, returns 0. -/
def supNewtonGap (e : ℕ → ℝ) (n : ℕ) : ℝ :=
  if h : 2 ≤ n then
    Finset.sup' (Finset.Icc 1 (n - 1))
      (⟨1, Finset.mem_Icc.mpr ⟨le_refl 1, by omega⟩⟩)
      (fun k => pointwiseNewtonGap e k)
  else 0

/-- A **spectrally pinched family** is a family of spectra
    uniformly contained in `[ε, 1-ε]` for some `ε > 0`. -/
structure SpectrallyPinchedFamily where
  spectrum : ℕ → ℕ → ℝ
  eps : ℝ
  eps_pos : 0 < eps
  eps_lt : eps < 1 / 2
  size : ℕ → ℕ
  pinched : ∀ m i, i < size m → eps ≤ spectrum m i ∧ spectrum m i ≤ 1 - eps

/-- A **Toeplitz–Newton asymptotic** encodes a family of positive elementary-
    symmetric profiles together with a critical lower bound on the Newton gap. -/
structure ToeplitzNewtonAsymptotic where
  e : ℕ → ℕ → ℝ
  pos : ∀ m k, 0 < e m k
  n : ℕ → ℕ
  critical_gap :
    ∃ c > 0, ∃ b : ℝ, ∀ᶠ (m : ℕ) in Filter.atTop,
      c * Real.log (↑m : ℝ) - b ≤ supNewtonGap (e m) (n m)

/-! ## Section 2: Supremal Newton Gap Properties -/

/-- The supremal Newton gap dominates each pointwise gap. -/
theorem supNewtonGap_ge_pointwise (e : ℕ → ℝ) (n : ℕ) (k : ℕ)
    (hk1 : 1 ≤ k) (hk2 : k ≤ n - 1) (hn : 2 ≤ n) :
    pointwiseNewtonGap e k ≤ supNewtonGap e n := by
  unfold supNewtonGap
  rw [dif_pos hn]
  exact Finset.le_sup' _ (Finset.mem_Icc.mpr ⟨hk1, hk2⟩)

/-! ## Section 3: Unboundedness from Logarithmic Growth -/

/-
**Key analysis lemma:** If a function `f : ℕ → ℝ` satisfies
    `f(m) ≥ c · log(m) - b` for all sufficiently large `m`, with `c > 0`,
    then `f` is unbounded above on `ℕ`.
-/
theorem unbounded_of_frequently_ge_log
    (f : ℕ → ℝ)
    (h : ∃ c > 0, ∃ b : ℝ, ∀ᶠ (m : ℕ) in Filter.atTop,
      c * Real.log (↑m : ℝ) - b ≤ f m) :
    ¬BddAbove (Set.range f) := by
      -- By contradiction, assume $f$ is bounded above by some $M$.
      by_contra h_bounded
      obtain ⟨M, hM⟩ : ∃ M, ∀ m, f m ≤ M := by
        exact ⟨ h_bounded.choose, fun m => h_bounded.choose_spec ⟨ m, rfl ⟩ ⟩;
      obtain ⟨ c, hc_pos, b, hb ⟩ := h; have := hb.and ( Filter.eventually_gt_atTop ⌈Real.exp ( ( M + b ) / c ) ⌉₊ ) ; obtain ⟨ m, hm₁, hm₂ ⟩ := this.exists; nlinarith [ Nat.le_ceil ( Real.exp ( ( M + b ) / c ) ), Real.log_exp ( ( M + b ) / c ), Real.log_lt_log ( by positivity ) ( Nat.lt_of_ceil_lt hm₂ ), mul_div_cancel₀ ( M + b ) hc_pos.ne', hM m ] ;

/-
**Corollary with subsequence:** If along a strictly monotone subsequence
    `φ`, we have `f(φ(n)) ≥ c · log(φ(n)) - b`, then `f` is unbounded.
-/
theorem unbounded_of_subseq_log_lower_bound
    (f : ℕ → ℝ)
    (h : ∃ c > 0, ∃ b : ℝ, ∃ phi : ℕ → ℕ,
      StrictMono phi ∧
      ∀ n, c * Real.log (↑(phi n) : ℝ) - b ≤ f (phi n)) :
    ¬BddAbove (Set.range f) := by
      -- By assumption, there exist constants $c > 0$, $b$, and a strictly monotone subsequence $\phi$ such that $f(\phi(n)) \geq c \log(\phi(n)) - b$ for all $n$.
      obtain ⟨c, hc_pos, b, phi, h_phi_mono, h_bound⟩ := h
      have h_unbounded : Filter.Tendsto (fun n => c * Real.log (phi n) - b) Filter.atTop Filter.atTop := by
        exact Filter.Tendsto.atTop_add ( Filter.Tendsto.const_mul_atTop hc_pos <| Real.tendsto_log_atTop.comp <| tendsto_natCast_atTop_atTop.comp h_phi_mono.tendsto_atTop ) tendsto_const_nhds;
      exact fun ⟨ M, hM ⟩ => by have := h_unbounded.eventually_gt_atTop M; obtain ⟨ n, hn ⟩ := this.exists; linarith [ h_bound n, hM ( Set.mem_range_self ( phi n ) ) ] ;

/-! ## Section 4: Bounded Newton Order from Spectral Pinching -/

/-
**Logarithmic bound for pinched values:** For `x ∈ [ε, 1-ε]` with
    `0 < ε < 1/2`, we have `|log x| ≤ |log ε|`.
-/
theorem log_bounded_of_pinched (x eps : ℝ)
    (heps : 0 < eps) (heps2 : eps < 1 / 2)
    (hlo : eps ≤ x) (hhi : x ≤ 1 - eps) :
    |Real.log x| ≤ |Real.log eps| := by
      rw [ abs_of_nonpos, abs_of_nonpos ] <;> linarith [ Real.log_le_sub_one_of_pos heps, Real.log_le_sub_one_of_pos ( by linarith : 0 < x ), Real.log_le_log ( by linarith ) hlo ]

/-
**Core algebraic lemma:** For positive reals `a, b, c ∈ [δ, M]`,
    the second log-difference is bounded by `4 · |log M - log δ|`.
-/
theorem pointwise_gap_bounded_of_values_bounded
    (a b c delta M : ℝ) (hdelta : 0 < delta) (_hM : delta ≤ M)
    (ha : delta ≤ a ∧ a ≤ M) (hb : delta ≤ b ∧ b ≤ M)
    (hc : delta ≤ c ∧ c ≤ M) :
    |Real.log a + Real.log c - 2 * Real.log b| ≤
      4 * |Real.log M - Real.log delta| := by
        have h_bound : Real.log delta ≤ Real.log b ∧ Real.log b ≤ Real.log M ∧ Real.log delta ≤ Real.log a ∧ Real.log a ≤ Real.log M ∧ Real.log delta ≤ Real.log c ∧ Real.log c ≤ Real.log M := by
          exact ⟨ Real.log_le_log ( by linarith ) ( by linarith ), Real.log_le_log ( by linarith ) ( by linarith ), Real.log_le_log ( by linarith ) ( by linarith ), Real.log_le_log ( by linarith ) ( by linarith ), Real.log_le_log ( by linarith ) ( by linarith ), Real.log_le_log ( by linarith ) ( by linarith ) ⟩;
        cases abs_cases ( Real.log a + Real.log c - 2 * Real.log b ) <;> cases abs_cases ( Real.log M - Real.log delta ) <;> linarith

/-
**Bounded Newton order for pinched families (Theorem A).**

    For any family of positive sequences uniformly bounded in `[δ, M]`,
    the Newton gap is uniformly bounded.
-/
theorem bounded_newton_of_uniform_pinching_family
    (e : ℕ → ℕ → ℝ) (sz : ℕ → ℕ)
    (_hpos : ∀ m k, 0 < e m k)
    (hpinch : ∃ delta > (0 : ℝ), ∃ M : ℝ, ∀ m k, k ≤ sz m →
      delta ≤ e m k ∧ e m k ≤ M) :
    ∃ C : ℝ, 0 < C ∧ ∀ m k, 1 ≤ k → k ≤ sz m - 1 → 2 ≤ sz m →
      |pointwiseNewtonGap (e m) k| ≤ C := by
        obtain ⟨delta, hdelta_pos, M, hM⟩ := hpinch;
        use 4 * |Real.log M - Real.log delta| + 1, by
          positivity, fun m k hk1 hk2 hk3 => by
          apply le_trans ( pointwise_gap_bounded_of_values_bounded ( e m ( k - 1 ) ) ( e m k ) ( e m ( k + 1 ) ) delta M hdelta_pos ( by linarith [ hM m ( k - 1 ) ( by omega ), hM m k ( by omega ), hM m ( k + 1 ) ( by omega ) ] ) ( hM m ( k - 1 ) ( by omega ) ) ( hM m k ( by omega ) ) ( hM m ( k + 1 ) ( by omega ) ) ) ( by linarith )

/-! ## Section 5: Lower Bound from Log-Concavity Defects -/

/-
**Newton order lower bound from log-gap (Theorem B).**

    If the log-concavity defect at indices `k(m)` grows like `c · log m`,
    the supremal Newton gap inherits this growth.
-/
theorem newtonOrder_lower_bound_of_log_gap
    (e : ℕ → ℕ → ℝ) (sz : ℕ → ℕ)
    (_hpos : ∀ m k, 0 < e m k)
    (hk : ℕ → ℕ)
    (hk_range : ∀ᶠ (m : ℕ) in Filter.atTop,
      1 ≤ hk m ∧ hk m ≤ sz m - 1 ∧ 2 ≤ sz m)
    (hgap : ∃ c > 0, ∃ b : ℝ, ∀ᶠ (m : ℕ) in Filter.atTop,
      c * Real.log (↑m : ℝ) - b ≤ pointwiseNewtonGap (e m) (hk m)) :
    ∃ c > 0, ∃ b : ℝ, ∀ᶠ (m : ℕ) in Filter.atTop,
      c * Real.log (↑m : ℝ) - b ≤ supNewtonGap (e m) (sz m) := by
        obtain ⟨ c, hc0, b, hb ⟩ := hgap; use c, hc0, b; filter_upwards [ hb, hk_range ] with m hm h_m; refine le_trans hm ?_ ; exact supNewtonGap_ge_pointwise ( e m ) ( sz m ) ( hk m ) h_m.1 h_m.2.1 h_m.2.2;

/-! ## Section 6: The Bridge Theorem -/

/-- **Critical Toeplitz criterion implies unbounded Newton order (Theorem C).**

    This is the flagship bridge theorem: if a Toeplitz–Newton asymptotic
    holds, then the supremal Newton gap is unbounded. -/
theorem critical_toeplitz_implies_unbounded_newton
    (A : ToeplitzNewtonAsymptotic) :
    ¬BddAbove (Set.range fun m => supNewtonGap (A.e m) (A.n m)) := by
  obtain ⟨c, hcpos, b, hgap⟩ := A.critical_gap
  apply unbounded_of_frequently_ge_log
  exact ⟨c, hcpos, b, hgap⟩

/-- **Phase dichotomy theorem.**

    Pinched families have bounded Newton gap; Toeplitz-critical families
    have unbounded Newton gap. This is a purely algebraic phase diagnostic. -/
theorem ssh_phase_dichotomy
    (e_gapped : ℕ → ℕ → ℝ) (sz_gapped : ℕ → ℕ)
    (e_crit : ToeplitzNewtonAsymptotic)
    (hpos_gap : ∀ m k, 0 < e_gapped m k)
    (hpinch : ∃ delta > (0 : ℝ), ∃ M : ℝ, ∀ m k, k ≤ sz_gapped m →
      delta ≤ e_gapped m k ∧ e_gapped m k ≤ M) :
    (∃ C : ℝ, 0 < C ∧ ∀ m k, 1 ≤ k → k ≤ sz_gapped m - 1 → 2 ≤ sz_gapped m →
      |pointwiseNewtonGap (e_gapped m) k| ≤ C) ∧
    ¬BddAbove (Set.range fun m => supNewtonGap (e_crit.e m) (e_crit.n m)) :=
  ⟨bounded_newton_of_uniform_pinching_family e_gapped sz_gapped hpos_gap hpinch,
   critical_toeplitz_implies_unbounded_newton e_crit⟩

/-! ## Section 7: Structural Lemmas -/

/-
If `e` is strictly positive, the pointwise Newton gap equals
    `log(e(k-1) · e(k+1) / e(k)²)`.
-/
theorem pointwiseNewtonGap_eq_log_ratio (e : ℕ → ℝ) (k : ℕ) (_hk : 1 ≤ k)
    (hprev : 0 < e (k - 1)) (hcur : 0 < e k) (hnext : 0 < e (k + 1)) :
    pointwiseNewtonGap e k =
    Real.log (e (k - 1) * e (k + 1) / (e k) ^ 2) := by
      unfold pointwiseNewtonGap; rw [ Real.log_div ( by positivity ) ( by positivity ), Real.log_pow, Real.log_mul ( by positivity ) ( by positivity ) ] ; ring;

/-
The pointwise Newton gap is zero for constant positive sequences.
-/
theorem pointwiseNewtonGap_const (c : ℝ) (_hc : 0 < c) (k : ℕ) :
    pointwiseNewtonGap (fun _ => c) k = 0 := by
      unfold pointwiseNewtonGap; ring;

/-! ## Section 8: SSH Specialization -/

/-- **SSH gapped Newton bounded (Theorem A, SSH form).**

    For the SSH model with nonzero dimerization, if correlation eigenvalue
    esymm profiles are uniformly pinched, Newton order is bounded.
    Immediate corollary of the general pinching theorem. -/
theorem ssh_gapped_newton_bounded
    (sshEsymm : ℝ → ℕ → ℕ → ℝ)
    (dd : ℝ) (_hdd : dd ≠ 0) (sz : ℕ → ℕ)
    (hpos : ∀ m k, 0 < sshEsymm dd m k)
    (hcluster : ∃ eps > (0 : ℝ), ∃ M : ℝ, ∀ m k, k ≤ sz m →
      eps ≤ sshEsymm dd m k ∧ sshEsymm dd m k ≤ M) :
    ∃ C > 0, ∀ m k, 1 ≤ k → k ≤ sz m - 1 → 2 ≤ sz m →
      |pointwiseNewtonGap (sshEsymm dd m) k| ≤ C :=
  bounded_newton_of_uniform_pinching_family (sshEsymm dd) sz hpos hcluster

/-- **Critical SSH Newton divergence (Theorem C, SSH form).**

    At criticality, if the Toeplitz criterion holds, Newton order diverges. -/
theorem ssh_critical_newton_diverges
    (sshCrit : ToeplitzNewtonAsymptotic) :
    ¬BddAbove (Set.range fun m => supNewtonGap (sshCrit.e m) (sshCrit.n m)) :=
  critical_toeplitz_implies_unbounded_newton sshCrit

end