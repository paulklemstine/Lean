import Applications.NET59ProbeBudgets.Basic

/-!
# Which probe sets see a layer?  The linear algebra of probing

A budget that "depends only on the behaviour of a layer at prescribed upstream
states" sees a channel `K` only through the probe responses `push K s`,
`s ∈ S`.  Because `push K` is *linear* in the input law, what a probe set can
see is governed by the linear span of the probe vectors `s.p ∈ ℚ^α`.

* `separates_of_spans` — if the probe vectors span `ℚ^α`, two channels with the
  same probe responses are equal;
* `exists_blind_pair` — **witness interpolation**: if the probe vectors do *not*
  span `ℚ^α` (and `α` has two points), there are two channels with identical
  responses at *every* probe whose outputs at some state are mutually singular
  (`tv = 1`).  The construction takes a nonzero linear functional `φ`
  annihilating the probes, normalises its coefficient vector `w` to `u` with
  `max |u| = 1`, and mixes two point masses with weights `(1 ± u a)/2`;
* `separates_iff` — a probe set separates channels **iff** `α` is a singleton
  or the probes span;
* `diracProbes_spans`, `card_le_of_spans` — the `|α|` Dirac probes span, and no
  family of fewer than `|α|` probes does.  So a finite probe set that suffices
  exists, and its minimum size is exactly the number of states.
-/

namespace Catalog.Probability.NET59.ProbeBudgets

open Finset

variable {α : Type*} [Fintype α]

/-! ## 1. Probe vectors and their span -/

/-- The span of the probe vectors `s.p` of a set of probe states. -/
def probeSpan (S : Set (Dist α)) : Submodule ℚ (α → ℚ) := Submodule.span ℚ (Dist.p '' S)

/-- A probe set *spans* if its probe vectors span all of `ℚ^α`. -/
def Spans (S : Set (Dist α)) : Prop := probeSpan S = ⊤

/-- Two channels *agree on* a probe set if they have the same response at every
probe state. -/
def AgreeOn (S : Set (Dist α)) (f p : Kern α α) : Prop := ∀ s ∈ S, push f s = push p s

/-- A probe set *separates* channels if agreeing on it forces equality. -/
def Separates (S : Set (Dist α)) : Prop := ∀ f p : Kern α α, AgreeOn S f p → f = p

/-- The pushforward through a channel, extended linearly to all of `ℚ^α`. -/
def pushL (K : Kern α α) : (α → ℚ) →ₗ[ℚ] (α → ℚ) where
  toFun v b := ∑ a, v a * (K a).p b
  map_add' v w := by
    funext b; simp only [Pi.add_apply, add_mul, Finset.sum_add_distrib]
  map_smul' c v := by
    funext b; simp only [Pi.smul_apply, smul_eq_mul, RingHom.id_apply, Finset.mul_sum, mul_assoc]

theorem pushL_dist (K : Kern α α) (s : Dist α) : pushL K s.p = (push K s).p := rfl

theorem pushL_single [DecidableEq α] (K : Kern α α) (a : α) :
    pushL K (fun x => if x = a then 1 else 0) = (K a).p := by
  funext b
  change ∑ x, (if x = a then (1 : ℚ) else 0) * (K x).p b = (K a).p b
  rw [Finset.sum_eq_single a] <;> simp +contextual

/-! ## 2. Spanning probe sets separate -/

/-- **Spanning probes see everything.**  If the probe vectors span `ℚ^α`, two
channels with identical probe responses are identical. -/
theorem separates_of_spans {S : Set (Dist α)} (hS : Spans S) : Separates S := by
  classical
  intro f p hfp
  have hle : probeSpan S ≤ LinearMap.ker (pushL f - pushL p) := by
    rw [probeSpan, Submodule.span_le]
    rintro _ ⟨s, hs, rfl⟩
    simp only [SetLike.mem_coe, LinearMap.mem_ker, LinearMap.sub_apply, pushL_dist, hfp s hs,
      sub_self]
  rw [hS] at hle
  funext a
  have hmem : (fun x => if x = a then (1 : ℚ) else 0) ∈ LinearMap.ker (pushL f - pushL p) :=
    hle Submodule.mem_top
  rw [LinearMap.mem_ker, LinearMap.sub_apply, sub_eq_zero, pushL_single, pushL_single] at hmem
  exact Dist.ext' fun b => congrFun hmem b

/-! ## 3. Two-point mixtures -/

/-- The mixture `θ μ + (1-θ) ν`. -/
def mix (θ : ℚ) (h0 : 0 ≤ θ) (h1 : θ ≤ 1) (μ ν : Dist α) : Dist α where
  p b := θ * μ.p b + (1 - θ) * ν.p b
  nonneg b := add_nonneg (mul_nonneg h0 (μ.nonneg b)) (mul_nonneg (by linarith) (ν.nonneg b))
  sum_one := by
    rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum, μ.sum_one, ν.sum_one]; ring

/-- Mixtures of the same two laws are `|θ - θ'| · tv μ ν` apart. -/
theorem tv_mix (θ θ' : ℚ) (h0 h1 h0' h1') (μ ν : Dist α) :
    tv (mix θ h0 h1 μ ν) (mix θ' h0' h1' μ ν) = |θ - θ'| * tv μ ν := by
  unfold tv
  have : ∀ b, |(mix θ h0 h1 μ ν).p b - (mix θ' h0' h1' μ ν).p b| = |θ - θ'| * |μ.p b - ν.p b| := by
    intro b
    rw [← abs_mul]; congr 1; simp only [mix]; ring
  rw [Finset.sum_congr rfl fun b _ => this b, ← Finset.mul_sum]; ring

/-- Distinct point masses are at total variation distance `1`. -/
theorem tv_dirac_ne [DecidableEq α] {x y : α} (hxy : x ≠ y) : tv (dirac x) (dirac y) = 1 := by
  refine le_antisymm (tv_le_one _ _) ?_
  unfold tv
  have hsub : ∑ b ∈ ({x, y} : Finset α), |(dirac x).p b - (dirac y).p b|
      ≤ ∑ b, |(dirac x).p b - (dirac y).p b| :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _) fun _ _ _ => abs_nonneg _
  rw [Finset.sum_pair hxy] at hsub
  simp [dirac, hxy, Ne.symm hxy] at hsub
  simp only [dirac]
  linarith

/-- The response of a "state-dependent mixture" channel `a ↦ mix (θ a) μ ν` to a
probe `s` is the mixture with the `s`-averaged weight. -/
theorem push_mixK_p (θ : α → ℚ) (h0 : ∀ a, 0 ≤ θ a) (h1 : ∀ a, θ a ≤ 1) (μ ν s : Dist α)
    (b : α) :
    (push (fun a => mix (θ a) (h0 a) (h1 a) μ ν) s).p b
      = (∑ a, s.p a * θ a) * μ.p b + (1 - ∑ a, s.p a * θ a) * ν.p b := by
  simp only [push_apply, mix]
  have h : ∑ a, s.p a * ν.p b = ν.p b := by rw [← Finset.sum_mul, s.sum_one, one_mul]
  have e : ∑ a, s.p a * (θ a * μ.p b + (1 - θ a) * ν.p b)
      = (∑ a, s.p a * θ a) * μ.p b + ∑ a, s.p a * ν.p b - (∑ a, s.p a * θ a) * ν.p b := by
    rw [Finset.sum_mul, Finset.sum_mul, ← Finset.sum_add_distrib, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun a _ => by ring
  rw [e, h]; ring

/-! ## 4. Witness interpolation through any non-spanning probe set -/

/-- **Witness interpolation.**  If the probe vectors fail to span `ℚ^α` and `α`
has two distinct points, there are channels `g, q` that agree at *every* probe
state but whose outputs at some state are mutually singular. -/
theorem exists_blind_pair [DecidableEq α] {S : Set (Dist α)} (hS : ¬ Spans S)
    {x y : α} (hxy : x ≠ y) :
    ∃ g q : Kern α α, AgreeOn S g q ∧ ∃ a, tv (g a) (q a) = 1 := by
  -- a nonzero functional annihilating the probes
  obtain ⟨φ, hφ0, hφ⟩ := Submodule.exists_le_ker_of_lt_top (probeSpan S) (lt_top_iff_ne_top.2 hS)
  set w : α → ℚ := fun a => φ (fun j => if a = j then 1 else 0) with hw
  have hφw : ∀ v, φ v = ∑ a, v a * w a := by
    intro v; rw [LinearMap.pi_apply_eq_sum_univ φ v]; simp [hw, smul_eq_mul]
  have hann : ∀ s ∈ S, ∑ a, s.p a * w a = 0 := by
    intro s hs
    rw [← hφw]
    exact hφ (Submodule.subset_span ⟨s, hs, rfl⟩)
  -- normalise
  have hne : (Finset.univ : Finset α).Nonempty := ⟨x, Finset.mem_univ x⟩
  obtain ⟨a₀, -, ha₀⟩ := Finset.exists_max_image Finset.univ (fun a => |w a|) hne
  have hM : 0 < |w a₀| := by
    by_contra hle
    push_neg at hle
    apply hφ0
    refine LinearMap.ext fun v => ?_
    rw [hφw, LinearMap.zero_apply]
    refine Finset.sum_eq_zero fun a _ => ?_
    have : |w a| ≤ 0 := (ha₀ a (Finset.mem_univ a)).trans hle
    rw [abs_nonpos_iff.1 this, mul_zero]
  set M := |w a₀|
  set u : α → ℚ := fun a => w a / M with hu
  have hu_abs : ∀ a, |u a| ≤ 1 := by
    intro a
    rw [hu]; dsimp only
    rw [abs_div, abs_of_pos hM, div_le_one hM]
    exact ha₀ a (Finset.mem_univ a)
  have hu0 : |u a₀| = 1 := by
    rw [hu]; dsimp only; rw [abs_div, abs_of_pos hM, div_self hM.ne']
  have hlo : ∀ a, -1 ≤ u a := fun a => (abs_le.1 (hu_abs a)).1
  have hhi : ∀ a, u a ≤ 1 := fun a => (abs_le.1 (hu_abs a)).2
  let θg : α → ℚ := fun a => (1 + u a) / 2
  let θq : α → ℚ := fun a => (1 - u a) / 2
  have hg0 : ∀ a, 0 ≤ θg a := fun a => by have := hlo a; simp only [θg]; linarith
  have hg1 : ∀ a, θg a ≤ 1 := fun a => by have := hhi a; simp only [θg]; linarith
  have hq0 : ∀ a, 0 ≤ θq a := fun a => by have := hhi a; simp only [θq]; linarith
  have hq1 : ∀ a, θq a ≤ 1 := fun a => by have := hlo a; simp only [θq]; linarith
  refine ⟨fun a => mix (θg a) (hg0 a) (hg1 a) (dirac x) (dirac y),
    fun a => mix (θq a) (hq0 a) (hq1 a) (dirac x) (dirac y), ?_, a₀, ?_⟩
  · intro s hs
    have hsu : ∑ a, s.p a * u a = 0 := by
      simp only [hu, mul_div_assoc', ← Finset.sum_div, hann s hs, zero_div]
    have hg : ∑ a, s.p a * θg a = 1 / 2 := by
      have : ∑ a, s.p a * θg a = (∑ a, s.p a + ∑ a, s.p a * u a) / 2 := by
        rw [add_div, Finset.sum_div, Finset.sum_div, ← Finset.sum_add_distrib]
        exact Finset.sum_congr rfl fun a _ => by simp only [θg]; ring
      rw [this, s.sum_one, hsu]; norm_num
    have hq : ∑ a, s.p a * θq a = 1 / 2 := by
      have : ∑ a, s.p a * θq a = (∑ a, s.p a - ∑ a, s.p a * u a) / 2 := by
        rw [sub_div, Finset.sum_div, Finset.sum_div, ← Finset.sum_sub_distrib]
        exact Finset.sum_congr rfl fun a _ => by simp only [θq]; ring
      rw [this, s.sum_one, hsu]; norm_num
    refine Dist.ext' fun b => ?_
    rw [push_mixK_p, push_mixK_p, hg, hq]
  · rw [tv_mix, tv_dirac_ne hxy, mul_one]
    simp only [θg, θq]
    rw [show (1 + u a₀) / 2 - (1 - u a₀) / 2 = u a₀ by ring, hu0]

/-! ## 5. The separation dichotomy -/

/-- On a singleton state space there is only one law. -/
theorem dist_subsingleton [Subsingleton α] (μ ν : Dist α) : μ = ν := by
  refine Dist.ext' fun a => ?_
  have hμ := μ.sum_one; have hν := ν.sum_one
  rw [Fintype.sum_subsingleton _ a] at hμ hν
  rw [hμ, hν]

/-- **Separation dichotomy.**  A set of probe states determines every channel
from its probe responses if and only if the state space is a singleton or the
probe vectors span `ℚ^α`. -/
theorem separates_iff [DecidableEq α] (S : Set (Dist α)) :
    Separates S ↔ Subsingleton α ∨ Spans S := by
  constructor
  · intro hsep
    by_contra h
    push_neg at h
    obtain ⟨hns, hspan⟩ := h
    obtain ⟨x, y, hxy⟩ := exists_pair_ne α
    obtain ⟨g, q, hgq, a, ha⟩ := exists_blind_pair hspan hxy
    rw [hsep g q hgq, tv_self] at ha
    exact zero_ne_one ha
  · rintro (h | h)
    · intro f p _; funext a; exact dist_subsingleton _ _
    · exact separates_of_spans h

/-! ## 6. How many probes?  Exactly `|α|` -/

/-- The `|α|` Dirac probes span. -/
theorem diracProbes_spans [DecidableEq α] : Spans (Set.range (dirac : α → Dist α)) := by
  rw [Spans, eq_top_iff]
  intro v _
  have hv : v = ∑ a, v a • (dirac a).p := by
    funext b
    simp only [Finset.sum_apply, Pi.smul_apply, smul_eq_mul, dirac]
    rw [Finset.sum_eq_single b] <;> simp +contextual [eq_comm]
  rw [hv]
  exact Submodule.sum_mem _ fun a _ =>
    Submodule.smul_mem _ _ (Submodule.subset_span ⟨dirac a, ⟨a, rfl⟩, rfl⟩)

/-- **Lower bound on probe budgets.**  A spanning family of probe states has at
least `|α|` members: no budget certified on fewer probes than states can see
every channel. -/
theorem card_le_of_spans {m : ℕ} (probes : Fin m → Dist α)
    (h : Spans (Set.range probes)) : Fintype.card α ≤ m := by
  have hrange : Dist.p '' Set.range probes = Set.range (fun i => (probes i).p) := by
    rw [← Set.range_comp]; rfl
  have h1 := finrank_range_le_card (R := ℚ) (fun i => (probes i).p)
  rw [Set.finrank, ← hrange] at h1
  change Module.finrank ℚ (probeSpan (Set.range probes)) ≤ _ at h1
  rw [h, finrank_top, Module.finrank_fintype_fun_eq_card] at h1
  simpa using h1

end Catalog.Probability.NET59.ProbeBudgets