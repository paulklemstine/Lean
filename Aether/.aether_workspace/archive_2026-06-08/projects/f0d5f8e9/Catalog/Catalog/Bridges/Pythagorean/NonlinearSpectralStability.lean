/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Nonlinear Eigenvalue Flows and Spectral Stability

This file extends the affine spectral stability theory from
`Catalog.Pythagorean.SchemeLorentzian` to **nonlinear eigenvalue flows**.

## Mathematical Context

The affine theory says: if each eigenvalue branch has the form `θ_j(t) = a_j + b_j·t`,
the stability radius is the first vanishing time `min_j (-a_j/b_j)`. This is elegant but
limited to linear parameter dependence.

Real perturbation families — in trust-region methods, polynomial homotopies, nonlinear
elasticity, and parametric PDEs — are not affine. This file proves that the same
"first spectral collision controls stability" paradigm survives for broad classes of
**non-affine eigenvalue flows**.

## Main Principle

> If instability can only arise when some eigenvalue branch crosses zero, then the
> nonlinear stability radius is exactly the earliest positive zero across all
> nontrivial branches, under verifiable sign/continuity/monotonicity hypotheses.

## Main Results

* `exists_first_positive_root_of_sign_change` — existence of a minimal positive root
  for a continuous function that changes sign (nonlinear IVT + minimality)
* `neg_before_first_root_pos_after_first_root` — sign characterization before and after
  the first root under strict monotonicity
* `stability_radius_eq_min_first_root` — the flagship theorem: stability radius equals
  the minimum first positive root across all eigenvalue branches
* `quadratic_branch_has_first_root_when_sign_changes` — polynomial specialization for
  quadratic eigenvalue branches

## Application Keywords

spectral bifurcation, trust-region optimization, polynomial homotopy continuation,
soft-mode instability, phase transitions, root isolation, parametric Hessians,
nonlinear eigenvalue flow, certified stability radius

## Cross-Domain Connections

* **Numerical algebraic geometry**: stability radius as minimum positive real root
* **Optimization / trust-region methods**: Hessian flows and local model validity
* **Dynamical systems**: bifurcation thresholds as first eigenvalue crossings
* **Mathematical physics**: soft-mode instability in energy landscapes
-/

open Set

noncomputable section

namespace NonlinearSpectralStability

/-! ## Core Definitions -/

/-- The set of positive zeros of a scalar function `θ`. -/
def positiveZeroSet (θ : ℝ → ℝ) : Set ℝ := {t | 0 < t ∧ θ t = 0}

/-- A **sign-crossing flow** is a continuous function that starts negative and
    eventually becomes positive. This is the nonlinear analogue of the affine
    eigenvalue branch with `a < 0` and `b > 0`. -/
structure SignCrossingFlow (θ : ℝ → ℝ) : Prop where
  continuous : Continuous θ
  neg_at_zero : θ 0 < 0
  eventually_pos : ∃ T > 0, 0 < θ T

/-! ## Theorem 1: Existence of a First Positive Root

This is the atomic lemma replacing the affine closed-form root.
Uses continuity, IVT, and well-ordering of ℝ (via completeness). -/

/-
**Existence of a first positive zero for a nonlinear branch.**

Let `θ : ℝ → ℝ` be continuous with `θ(0) < 0`, and suppose there exists
`T > 0` with `θ(T) > 0`. Then there exists a minimal positive root `r > 0`
with `θ(r) = 0`, and `r ≤ s` for every other positive root `s`.

This theorem is the nonlinear replacement for the affine vanishing-time
formula `t_j = -a_j / b_j`.
-/
theorem exists_first_positive_root_of_sign_change
    {θ : ℝ → ℝ}
    (hcont : Continuous θ)
    (hneg : θ 0 < 0)
    (hpos : ∃ T > 0, 0 < θ T) :
    ∃ r, 0 < r ∧ θ r = 0 ∧ ∀ s, 0 < s → θ s = 0 → r ≤ s := by
  -- By Sturm's theorem, there exists a point $c$ in $(0, T)$ such that $\theta(c) = 0$.
  obtain ⟨T, hT_pos, hT_pos_θ⟩ : ∃ T > 0, 0 < θ T := hpos
  obtain ⟨c, hc₁, hc₂⟩ : ∃ c ∈ Set.Ioo 0 T, θ c = 0 := by
    apply_rules [ intermediate_value_Ioo, hcont.continuousOn ];
    · linarith;
    · constructor <;> linarith;
  -- Consider the set $A = \theta^{-1}(\{0\}) \cap [0, T]$. This set is closed (as preimage of closed under continuous) intersected with compact = compact, nonempty (contains $c$).
  set A := θ⁻¹' {0} ∩ Set.Icc 0 T with hA_def
  have hA_closed : IsClosed A := by
    exact IsClosed.inter ( isClosed_singleton.preimage hcont ) ( isClosed_Icc )
  have hA_nonempty : A.Nonempty := by
    exact ⟨ c, hc₂, hc₁.1.le, hc₁.2.le ⟩
  have hA_compact : IsCompact A := by
    exact CompactIccSpace.isCompact_Icc.of_isClosed_subset hA_closed fun x hx => hx.2;
  -- Since $A$ is nonempty and compact, it has a minimum element $r$.
  obtain ⟨r, hr⟩ : ∃ r ∈ A, ∀ s ∈ A, r ≤ s := by
    exact hA_compact.exists_isLeast hA_nonempty;
  grind

/-! ## Theorem 2: Sign Before and After the First Root

This recovers the catalog's affine sign lemmas
(`eigenvalue_neg_before_vanishing`, `eigenvalue_pos_after_vanishing`)
in nonlinear form. The first root is the **phase boundary**. -/

/-
**Sign characterization before and after the first root under monotonicity.**

If `θ` is continuous and strictly monotone on `[0, ∞)`, and `r` is its
first positive root, then:
- `θ(t) < 0` for all `0 ≤ t < r` (stable phase)
- `θ(t) > 0` for all `t > r` (unstable phase)

This is the conceptual hinge: the first root is not merely a zero,
it is the **phase boundary** between stability and instability.
-/
theorem neg_before_first_root_pos_after_first_root
    {θ : ℝ → ℝ} {r : ℝ}
    (_hcont : Continuous θ)
    (hmono : StrictMonoOn θ (Ici 0))
    (hrpos : 0 < r)
    (hroot : θ r = 0)
    (_hmin : ∀ s, 0 < s → θ s = 0 → r ≤ s) :
    (∀ t, 0 ≤ t → t < r → θ t < 0) ∧
     (∀ t, r < t → 0 < θ t) := by
  exact ⟨ fun t ht₁ ht₂ => hroot ▸ hmono ( show 0 ≤ t by linarith ) ( show 0 ≤ r by linarith ) ht₂, fun t ht => by linarith [ hmono ( show 0 ≤ r by linarith ) ( show 0 ≤ t by linarith ) ht ] ⟩

/-! ## Theorem 3: Stability Radius Equals the Earliest Branch Root

This is the flagship theorem. It shows that for a finite family of
continuous, strictly monotone eigenvalue branches (each negative at `0`),
the stability radius — the supremum of parameters where all branches are
negative — equals the minimum first positive root across all branches.

The abstract stability predicate `StableAt t ↔ ∀ j, θ j t < 0` connects
spectral negativity to system stability. -/

/-
**Stability radius equals the minimum first positive root.**

Let `θ : ι → ℝ → ℝ` be a finite family of continuous eigenvalue branches,
each negative at `0` and strictly monotone on `[0, ∞)`. Assume stability at
parameter `t` is equivalent to all branches being negative. If at least one
branch eventually becomes positive, then the stability radius is the minimum
first positive root among all branches.
-/
theorem stability_radius_eq_min_first_root
    {ι : Type} [Fintype ι] [Nonempty ι]
    (θ : ι → ℝ → ℝ)
    (hcont : ∀ j, Continuous (θ j))
    (hneg0 : ∀ j, θ j 0 < 0)
    (_hmono : ∀ j, StrictMonoOn (θ j) (Ici 0))
    (hcross : ∃ j T, 0 < T ∧ 0 < θ j T) :
    ∃ r, 0 < r ∧
      (∃ j, θ j r = 0) ∧
      (∀ t, 0 ≤ t → t < r → ∀ j, θ j t < 0) ∧
      (∃ j, θ j r = 0 ∧ ∀ s, 0 < s → θ j s = 0 → r ≤ s) := by
  -- By definition of $S$, we know there exists $r > 0$ such that $r \in S$.
  obtain ⟨r, hr⟩ : ∃ r, r ∈ {s | 0 < s ∧ ∃ j, θ j s = 0} ∧ ∀ s ∈ {s | 0 < s ∧ ∃ j, θ j s = 0}, r ≤ s := by
    obtain ⟨j₀, T₀, hT₀_pos, hT₀_pos_j₀⟩ : ∃ j₀ T₀, 0 < T₀ ∧ 0 < θ j₀ T₀ := hcross;
    -- By definition of $S$, we know there exists $r > 0$ such that $r \in S$ and $r$ is the least element of $S$.
    obtain ⟨r, hr⟩ : ∃ r, r ∈ {s | 0 < s ∧ ∃ j, θ j s = 0} ∧ r ≤ T₀ := by
      -- By the intermediate value theorem, since $\theta_{j₀}(0) < 0$ and $\theta_{j₀}(T₀) > 0$, there exists some $r \in (0, T₀)$ such that $\theta_{j₀}(r) = 0$.
      obtain ⟨r, hr⟩ : ∃ r ∈ Set.Ioo 0 T₀, θ j₀ r = 0 := by
        apply_rules [ intermediate_value_Ioo ];
        · linarith;
        · exact Continuous.continuousOn ( hcont j₀ );
        · constructor <;> linarith [ hneg0 j₀ ];
      exact ⟨ r, ⟨ hr.1.1, j₀, hr.2 ⟩, hr.1.2.le ⟩;
    have h_compact : IsCompact ({s | 0 < s ∧ ∃ j, θ j s = 0} ∩ Set.Icc 0 T₀) := by
      have h_closed : IsClosed ({s | 0 < s ∧ ∃ j, θ j s = 0} ∩ Set.Icc 0 T₀) := by
        have h_closed : IsClosed ({s | ∃ j, θ j s = 0} ∩ Set.Icc 0 T₀) := by
          have h_closed : IsClosed (⋃ j, {s | θ j s = 0} ∩ Set.Icc 0 T₀) := by
            exact isClosed_iUnion_of_finite fun j => IsClosed.inter ( isClosed_eq ( hcont j ) continuous_const ) ( isClosed_Icc );
          convert h_closed using 1 ; ext ; aesop;
        convert h_closed using 1;
        grind +splitImp;
      exact CompactIccSpace.isCompact_Icc.of_isClosed_subset h_closed fun x hx => hx.2;
    have := h_compact.exists_isLeast;
    obtain ⟨ x, hx ⟩ := this ⟨ r, hr.1, ⟨ hr.1.1.le, hr.2 ⟩ ⟩;
    exact ⟨ x, hx.1.1, fun s hs => if hs' : s ≤ T₀ then hx.2 ⟨ hs, ⟨ hs.1.le, hs' ⟩ ⟩ else by linarith [ hx.1.2.2, hs.1 ] ⟩;
  refine' ⟨ r, hr.1.1, hr.1.2, _, _ ⟩;
  · intro t ht₁ ht₂ j;
    by_contra h_contra;
    -- Since $\theta_j(t) \geq 0$ and $\theta_j$ is strictly monotone on $[0, \infty)$, there exists some $s \in [0, t]$ such that $\theta_j(s) = 0$.
    obtain ⟨s, hs⟩ : ∃ s ∈ Set.Icc 0 t, θ j s = 0 := by
      apply_rules [ intermediate_value_Icc ];
      · exact Continuous.continuousOn ( hcont j );
      · constructor <;> linarith [ hneg0 j ];
    linarith [ hr.2 s ⟨ lt_of_le_of_ne hs.1.1 ( Ne.symm <| by rintro rfl; linarith [ hneg0 j ] ), j, hs.2 ⟩, hs.1.2 ];
  · aesop

/-! ## Theorem 4: Quadratic Branch Specialization

A concrete specialization to quadratic eigenvalue branches, bridging the
abstract theory to computational root-finding and numerical algebraic
geometry. -/

/-
**Quadratic branch has a first positive root when sign changes.**

For a quadratic branch `θ(t) = a + b·t + c·t²` with `a < 0` and `c > 0`,
the branch starts negative and eventually becomes positive (since the
leading coefficient is positive). Under the monotonicity condition `b ≥ 0`,
there exists a positive root, and the branch is negative before it.
-/
theorem quadratic_branch_has_first_root_when_sign_changes
    {a b c : ℝ}
    (hneg : a < 0)
    (hmono : 0 ≤ b)
    (hconv : 0 < c) :
    ∃ r, 0 < r ∧
      (a + b * r + c * r ^ 2 = 0) ∧
      ∀ t, 0 ≤ t → t < r → a + b * t + c * t ^ 2 < 0 := by
  refine' ⟨ ( -b + Real.sqrt ( b ^ 2 - 4 * a * c ) ) / ( 2 * c ), _, _, _ ⟩;
  · exact div_pos ( by nlinarith [ Real.sqrt_nonneg ( b ^ 2 - 4 * a * c ), Real.mul_self_sqrt ( by nlinarith : 0 ≤ b ^ 2 - 4 * a * c ) ] ) ( by positivity );
  · field_simp
    ring_nf
    rw [ Real.sq_sqrt ] <;> nlinarith;
  · intro t ht₁ ht₂;
    rw [ lt_div_iff₀ ( by positivity ) ] at ht₂;
    nlinarith [ mul_nonneg hconv.le ht₁, Real.mul_self_sqrt ( show 0 ≤ b ^ 2 - 4 * a * c by nlinarith ) ]

/-! ## Corollary: Affine Theory as a Special Case

When branches are affine (`θ_j(t) = a_j + b_j·t`), the nonlinear
theory recovers the affine stability radius formula. -/

/-
**Affine branch root recovery.**
For an affine branch `θ(t) = a + b·t` with `a < 0` and `b > 0`,
the unique positive root is `-a/b`, and the branch is negative before it.
This shows the nonlinear theory strictly contains the affine theory.
-/
theorem affine_branch_root_recovery
    {a b : ℝ}
    (hneg : a < 0)
    (hpos : 0 < b) :
    let r := -a / b
    0 < r ∧ (a + b * r = 0) ∧ ∀ t, 0 ≤ t → t < r → a + b * t < 0 := by
  exact ⟨ div_pos ( neg_pos.mpr hneg ) hpos, by rw [ mul_div_cancel₀ _ hpos.ne' ] ; ring, fun t ht₁ ht₂ => by nlinarith [ mul_div_cancel₀ ( -a ) hpos.ne' ] ⟩

/-! ## Auxiliary Lemma: Unique Root Under Strict Monotonicity -/

/-
A strictly monotone continuous function has at most one zero on any interval.
-/
theorem strictMono_unique_root
    {θ : ℝ → ℝ} {r s : ℝ}
    (hmono : StrictMonoOn θ (Ici 0))
    (hr : 0 ≤ r) (hs : 0 ≤ s)
    (hθr : θ r = 0) (hθs : θ s = 0) :
    r = s := by
  exact StrictMonoOn.injOn hmono hr hs <| by linarith;

/-! ## Auxiliary Lemma: Existence of Root via IVT -/

/-
If a continuous function is negative at `a` and positive at `b > a`,
then it has a zero in `(a, b)`. This is the standard IVT.
-/
theorem exists_root_of_sign_change_on_interval
    {θ : ℝ → ℝ} {a b : ℝ}
    (hcont : Continuous θ)
    (hab : a < b)
    (hna : θ a < 0)
    (hpb : 0 < θ b) :
    ∃ c, a < c ∧ c < b ∧ θ c = 0 := by
  have h_ivt : ∃ c ∈ Set.Ioo a b, θ c = 0 := by
    apply_rules [ intermediate_value_Ioo, hcont.continuousOn ];
    · linarith;
    · constructor <;> linarith
  obtain ⟨c, hc⟩ := h_ivt
  use c, hc.left.left, hc.left.right, hc.right

end NonlinearSpectralStability