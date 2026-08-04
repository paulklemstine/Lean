import Combinatorics.Percolation

/-!
# Monotone threshold couplings for finite percolation

A single collection of real-valued random keys can generate site or bond
configurations at every density parameter: an object is open at level `p` when
its key is at most `p`.  This file proves the deterministic part of the standard
monotone coupling.  In particular, connectivity and finite-grid crossing events
are nested as the threshold increases.

The construction reuses the finite percolation configurations and connectivity
predicates from `Catalog.Combinatorics.Percolation`; it makes no infinite-volume
claim and assumes no probability measure on the keys.
-/

namespace Cryptography.PercolationThresholdCoupling

/-- Open precisely the sites whose real-valued keys do not exceed `p`. -/
noncomputable def siteThresholdConfig {V : Type*} (key : V → ℝ) (p : ℝ) : SiteConfig V :=
  fun v => decide (key v ≤ p)

/-- Membership in a threshold site configuration is the corresponding key
inequality. -/
theorem siteThresholdConfig_eq_true_iff {V : Type*} (key : V → ℝ)
    (p : ℝ) (v : V) :
    siteThresholdConfig key p v = true ↔ key v ≤ p := by
  simp [siteThresholdConfig]

/-- Threshold site configurations are pointwise nested. -/
theorem siteThresholdConfig_mono {V : Type*} (key : V → ℝ) {p q : ℝ}
    (hpq : p ≤ q) (v : V) :
    siteThresholdConfig key p v = true →
      siteThresholdConfig key q v = true := by
  simp only [siteThresholdConfig_eq_true_iff]
  exact fun hv => hv.trans hpq

/-- Under one fixed key assignment, site connectivity persists when the
threshold increases. -/
theorem siteConnected_threshold_mono {V : Type*} (G : SimpleGraph V)
    (key : V → ℝ) (u v : V) {p q : ℝ} (hpq : p ≤ q) :
    SiteConnected G (siteThresholdConfig key p) u v →
      SiteConnected G (siteThresholdConfig key q) u v := by
  exact siteConnected_increasing G u v _ _
    (siteThresholdConfig_mono key hpq)

/-- A horizontal crossing in a finite grid persists under an increase of the
threshold in the common-key coupling. -/
theorem horizontalCrossing_threshold_mono (n : ℕ) (hn : 0 < n)
    (key : (Fin n × Fin n) → ℝ) {p q : ℝ} (hpq : p ≤ q) :
    HasHorizontalCrossing n hn (siteThresholdConfig key p) →
      HasHorizontalCrossing n hn (siteThresholdConfig key q) := by
  exact hasHorizontalCrossing_increasing n hn _ _
    (siteThresholdConfig_mono key hpq)

/-- Open precisely the bonds whose real-valued keys do not exceed `p`. -/
noncomputable def bondThresholdConfig {V : Type*} (key : Sym2 V → ℝ) (p : ℝ) : BondConfig V :=
  fun e => decide (key e ≤ p)

/-- Membership in a threshold bond configuration is the corresponding key
inequality. -/
theorem bondThresholdConfig_eq_true_iff {V : Type*} (key : Sym2 V → ℝ)
    (p : ℝ) (e : Sym2 V) :
    bondThresholdConfig key p e = true ↔ key e ≤ p := by
  simp [bondThresholdConfig]

/-- Threshold bond configurations are pointwise nested. -/
theorem bondThresholdConfig_mono {V : Type*} (key : Sym2 V → ℝ) {p q : ℝ}
    (hpq : p ≤ q) (e : Sym2 V) :
    bondThresholdConfig key p e = true →
      bondThresholdConfig key q e = true := by
  simp only [bondThresholdConfig_eq_true_iff]
  exact fun he => he.trans hpq

/-- Under one fixed edge-key assignment, bond connectivity persists when the
threshold increases. -/
theorem bondConnected_threshold_mono {V : Type*} (G : SimpleGraph V)
    (key : Sym2 V → ℝ) (u v : V) {p q : ℝ} (hpq : p ≤ q) :
    BondConnected G (bondThresholdConfig key p) u v →
      BondConnected G (bondThresholdConfig key q) u v := by
  exact bondConnected_increasing G u v _ _
    (bondThresholdConfig_mono key hpq)

/-- The configurations at equal thresholds agree, so the coupling is reflexive
for both site and bond models.  This packages the two distinct sample spaces
without identifying them. -/
theorem site_and_bond_connectivity_threshold_mono {V : Type*}
    (siteGraph bondGraph : SimpleGraph V) (siteKey : V → ℝ)
    (bondKey : Sym2 V → ℝ) (su sv bu bv : V) {p q : ℝ} (hpq : p ≤ q)
    (hs : SiteConnected siteGraph (siteThresholdConfig siteKey p) su sv)
    (hb : BondConnected bondGraph (bondThresholdConfig bondKey p) bu bv) :
    SiteConnected siteGraph (siteThresholdConfig siteKey q) su sv ∧
      BondConnected bondGraph (bondThresholdConfig bondKey q) bu bv := by
  exact ⟨siteConnected_threshold_mono siteGraph siteKey su sv hpq hs,
    bondConnected_threshold_mono bondGraph bondKey bu bv hpq hb⟩

end Cryptography.PercolationThresholdCoupling