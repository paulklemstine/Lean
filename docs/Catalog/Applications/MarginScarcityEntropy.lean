import Applications.MarginScarcityCorrelation

/-!
# Cycle 2: Rényi-2 diffuseness is a certified obstruction to portability

Cycle 1 (`Applications.MarginScarcityPortability`,
`Applications.MarginScarcityCorrelation`) established that the
margin-uncertified fraction upper-bounds transplant damage while weight-space
distance predicts nothing.  That leaves the margin statistic itself needing
logit margins.  This file removes even that: it bounds margin scarcity from
*below* by a pure information-theoretic statistic of the same forward pass, the
**collision mass / Rényi-2 entropy** of the score vector — the quantity through
which `Catalog.Novelty.KVDecisionDissociation.strictTop_le_sqrt_collision`
identified the diffuse tail as the fragile region.

The bridge is one inequality.  If the (nonnegative) score vector `u x` has
collision mass `C(x) = ∑ₖ u x k²` then its top coordinate is at most `√C(x)`;
a margin certificate at drift `eps` needs a top-1 *gap* exceeding `2·eps`, hence
needs `√C(x) > 2·eps`.  Contrapositively:

  `C(x) ≤ 4·eps²`  ⟹  position `x` carries no margin certificate,

equivalently, in entropy form, `H₂(u x) ≥ 2·log(1/(2·eps))` ⟹ uncertified.

## Main results

* `diffuse_not_certified` — the pointwise bridge (probability/information theory
  meets the decision geometry of the transplant).
* `diffuseFrac_le_uncertifiedFrac` — the fractional form: the diffuse fraction
  is a certified *lower* bound for the margin-uncertified fraction.
* `renyi2_diffuse_iff` — the collision-mass criterion in Rényi-2 entropy form.
* `entropy_obstruction_to_portability` — the headline sandwich: for a block
  whose score vectors are nonnegative,

    `diffuseFrac ≤ uncertifiedFrac`  and  `damageFrac ≤ uncertifiedFrac`,

  so a block that is `ρ`-diffuse can never be certified portable below `ρ` by
  the margin route — while a block that *is* certified below `τ` is necessarily
  `τ`-concentrated (`concentration_necessary`).
* `diffuse_lower_bound_is_not_damage` — the boundary (adversarial review):
  diffuseness bounds the *certificate*, not the damage; there are totally
  diffuse blocks with zero damage.  The two inequalities of the sandwich point
  the same way for a reason, and the sandwich cannot be closed.

## Lab notes

At the NET-54 tail arm the prefix drift is `eps ≈ 0.16` (`relK`), so the
diffuseness threshold is `C ≤ 4·eps² = 0.1024`, i.e. an effective support of
more than `1/0.1024 ≈ 9.8` tokens.  `diffuseFrac_le_uncertifiedFrac` then turns
any measured fraction of tail positions above that effective support directly
into a lower bound on margin scarcity, to be compared with the `≥ 0.4557`
certified by `net54_margin_scarcity`.
-/

namespace Catalog.Applications.MarginScarcityEntropy

open Finset
open Catalog.Novelty.KVDecisionDissociation
open Catalog.Probability.TailTransplantGeometry
open Catalog.Probability.TailTransplantCost
open Catalog.Applications.MarginScarcityPortability

variable {Ω : Type*} [Fintype Ω] [DecidableEq Ω]

/-- Collision mass of a score vector (the exponential of minus its Rényi-2
entropy).  Small collision mass = diffuse. -/
def collisionMass {n : ℕ} (p : Fin n → ℝ) : ℝ := ∑ k, p k ^ 2

/-- Rényi-2 entropy of a score vector. -/
noncomputable def renyi2 {n : ℕ} (p : Fin n → ℝ) : ℝ := -Real.log (collisionMass p)

open Classical in
/-- The positions whose score vector is diffuse at scale `eps`. -/
noncomputable def diffuseSet {m : ℕ} (u : Ω → Fin m → ℝ) (eps : ℝ) : Finset Ω :=
  Finset.univ.filter (fun x => collisionMass (u x) ≤ 4 * eps ^ 2)

open Classical in
/-- The diffuse fraction — a single-forward-pass statistic needing neither a
transplant nor logit margins. -/
noncomputable def diffuseFrac {m : ℕ} (u : Ω → Fin m → ℝ) (eps : ℝ) : ℝ :=
  ((diffuseSet u eps).card : ℝ) / (Fintype.card Ω : ℝ)

omit [Fintype Ω] [DecidableEq Ω] in
/-- **The bridge.**  A diffuse position carries no margin certificate: its top
score is at most `√C ≤ 2·eps`, while a certificate demands a top-1 gap above
`2·eps`. -/
theorem diffuse_not_certified {m : ℕ} (u v : Ω → Fin m → ℝ) (d : Ω → Fin m) (eps : ℝ)
    (heps : 0 ≤ eps) (hm : 1 < m) (x : Ω) (hnn : ∀ k, 0 ≤ u x k)
    (hdiff : collisionMass (u x) ≤ 4 * eps ^ 2) :
    ¬ MarginCertified u v d eps x := by
  intro hcert
  obtain ⟨j, hj⟩ : ∃ j : Fin m, j ≠ d x := by
    have hcard : 1 < Fintype.card (Fin m) := by simpa using hm
    exact Fintype.exists_ne_of_one_lt_card hcard (d x)
  have hgap := hcert.1 j hj
  have htop : u x (d x) ≤ Real.sqrt (collisionMass (u x)) :=
    strictTop_le_sqrt_collision (u x) hnn (d x)
  have hsqrt : Real.sqrt (collisionMass (u x)) ≤ 2 * eps := by
    have h1 : Real.sqrt (collisionMass (u x)) ≤ Real.sqrt (4 * eps ^ 2) :=
      Real.sqrt_le_sqrt hdiff
    have h2 : Real.sqrt (4 * eps ^ 2) = 2 * eps := by
      rw [show (4 : ℝ) * eps ^ 2 = (2 * eps) ^ 2 by ring, Real.sqrt_sq (by linarith)]
    linarith [h1, h2.le, h2.ge]
  have hju : 0 ≤ u x j := hnn j
  linarith

open Classical in
omit [DecidableEq Ω] in
/-- Fractional form of the bridge: the diffuse fraction is a certified lower
bound for the margin-uncertified fraction. -/
theorem diffuseFrac_le_uncertifiedFrac {m : ℕ} (u v : Ω → Fin m → ℝ) (d : Ω → Fin m)
    (eps : ℝ) (heps : 0 ≤ eps) (hm : 1 < m) (hnn : ∀ x k, 0 ≤ u x k) :
    diffuseFrac u eps ≤ uncertifiedFrac u v d eps := by
  classical
  have hsub : diffuseSet u eps ⊆ uncertifiedSet u v d eps := by
    intro x hx
    simp only [diffuseSet, Finset.mem_filter, Finset.mem_univ, true_and] at hx
    simp only [uncertifiedSet, Finset.mem_filter, Finset.mem_univ, true_and]
    exact diffuse_not_certified u v d eps heps hm x (hnn x) hx
  have hcard : ((diffuseSet u eps).card : ℝ) ≤ ((uncertifiedSet u v d eps).card : ℝ) := by
    exact_mod_cast Finset.card_le_card hsub
  unfold diffuseFrac uncertifiedFrac
  exact div_le_div_of_nonneg_right hcard (by positivity)

/-- **Entropy form of the diffuseness criterion.**  For a score vector with
positive collision mass, being diffuse at scale `eps` is exactly having Rényi-2
entropy at least `2·log(1/(2·eps))`. -/
theorem renyi2_diffuse_iff {n : ℕ} (p : Fin n → ℝ) (eps : ℝ) (heps : 0 < eps)
    (hC : 0 < collisionMass p) :
    (2 * Real.log (1 / (2 * eps)) ≤ renyi2 p) ↔ collisionMass p ≤ 4 * eps ^ 2 := by
  have h2eps : (0 : ℝ) < 2 * eps := by linarith
  have hlog : 2 * Real.log (1 / (2 * eps)) = -Real.log (4 * eps ^ 2) := by
    rw [Real.log_div one_ne_zero h2eps.ne', Real.log_one,
      show (4 : ℝ) * eps ^ 2 = (2 * eps) ^ 2 by ring, Real.log_pow]
    push_cast
    ring
  rw [renyi2, hlog, neg_le_neg_iff]
  exact Real.log_le_log_iff hC (by positivity)

open Classical in
omit [DecidableEq Ω] in
/-- **The headline sandwich.**  For a block with nonnegative score vectors the
single forward pass produces two certified inequalities around the margin
statistic: it is at least the diffuse fraction and at least the measured
post-transplant damage.  Diffuseness is therefore an obstruction to certifying
portability, and no transplant is needed to detect it. -/
theorem entropy_obstruction_to_portability [Nonempty Ω] {m : ℕ} (u v : Ω → Fin m → ℝ)
    (d dH : Ω → Fin m) (eps : ℝ) (heps : 0 ≤ eps) (hm : 1 < m)
    (hnn : ∀ x k, 0 ≤ u x k) (hH : ∀ x, IsStrictTop (v x) (dH x)) :
    diffuseFrac u eps ≤ uncertifiedFrac u v d eps ∧
      damageFrac dH d ≤ uncertifiedFrac u v d eps :=
  ⟨diffuseFrac_le_uncertifiedFrac u v d eps heps hm hnn,
    margin_route_screens_damage u v d dH eps hH⟩

open Classical in
omit [DecidableEq Ω] in
/-- Contrapositive reading: a block certified portable below `tau` by the margin
route is necessarily `tau`-concentrated. -/
theorem concentration_necessary {m : ℕ} (u v : Ω → Fin m → ℝ) (d : Ω → Fin m)
    (eps tau : ℝ) (heps : 0 ≤ eps) (hm : 1 < m) (hnn : ∀ x k, 0 ≤ u x k)
    (hcert : uncertifiedFrac u v d eps ≤ tau) :
    diffuseFrac u eps ≤ tau :=
  le_trans (diffuseFrac_le_uncertifiedFrac u v d eps heps hm hnn) hcert

open Classical in
omit [DecidableEq Ω] in
/-- **Boundary of the entropy route (adversarial review).**  Diffuseness bounds
the *certificate*, never the damage: there is a totally diffuse block
(`diffuseFrac = 1`, hence `uncertifiedFrac = 1`) whose transplant damage is
zero.  So the sandwich `diffuseFrac ≤ uncertifiedFrac`, `damage ≤
uncertifiedFrac` cannot be closed into `diffuseFrac ≤ damage`. -/
theorem diffuse_lower_bound_is_not_damage [Nonempty Ω] :
    ∃ (u v : Ω → Fin 2 → ℝ) (d dH : Ω → Fin 2) (eps : ℝ),
      0 < eps ∧ (∀ x, IsStrictTop (v x) (dH x)) ∧
      diffuseFrac u eps = 1 ∧ uncertifiedFrac u v d eps = 1 ∧ damageFrac dH d = 0 := by
  classical
  have hN : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast Fintype.card_pos
  refine ⟨fun _ => ![1, 0], fun _ => ![1, 0], fun _ => 0, fun _ => 0, 1, one_pos, ?_, ?_, ?_, ?_⟩
  · intro x j hj
    fin_cases j
    · exact absurd rfl hj
    · norm_num
  · have huniv : diffuseSet (fun _ : Ω => ![(1 : ℝ), 0]) 1 = Finset.univ := by
      ext x
      simp [diffuseSet, collisionMass, Fin.sum_univ_two]
    rw [diffuseFrac, huniv, Finset.card_univ, div_self hN.ne']
  · have huniv : uncertifiedSet (fun _ : Ω => ![(1 : ℝ), 0]) (fun _ => ![(1 : ℝ), 0])
        (fun _ => 0) 1 = Finset.univ := by
      ext x
      simp only [uncertifiedSet, Finset.mem_filter, Finset.mem_univ, true_and, iff_true]
      intro hcert
      have := hcert.1 1 (by simp)
      norm_num at this
    rw [uncertifiedFrac, huniv, Finset.card_univ, div_self hN.ne']
  · have hempty : disagreeSet (fun _ : Ω => (0 : Fin 2)) (fun _ => 0) = ∅ := by
      ext x; simp [mem_disagreeSet]
    simp [damageFrac, hempty]

end Catalog.Applications.MarginScarcityEntropy