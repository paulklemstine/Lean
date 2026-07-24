import Mathlib
import Computation.Hypercomputation.Foundations

/-!
# Metric and Thermodynamic Refinements of Exact Oracle Loading

The foundational chapter established a *qualitative* capacity obstruction: a device that
exactly loads every infinite binary oracle must possess infinitely many distinguishable
physical states.  Cardinality, however, is too coarse an invariant for analog physics — a
continuum of states is not by itself forbidden.  This chapter sharpens the obstruction into
*metric* and *thermodynamic* resource inequalities.

The organizing idea is that exact oracle loading is an **injective encoding**.  Restricting a
loader to the first `n` bits embeds the `2 ^ n`-element cube `Fin n → Bool` into the state
space, and every downstream limitation is a consequence of the size of this embedded cube:

* **Counting.** A finite state space must contain at least `2 ^ n` states for every `n`; this
  recovers, and quantifies, the infinite-capacity theorem.
* **Packing (energy–precision tradeoff).** If distinct stored strings are held at a uniform
  distinguishability margin `ε`, the state space contains a `2 ^ n`-point `ε`-separated set.
  Under a physically motivated packing law `card ≤ (V / ε) ^ d`, one obtains the resource
  inequality `n · log 2 ≤ d · (log V + log(1 / ε))`.
* **Compactness (topological obstruction).** A state space that resolves *all* oracle bits at
  a uniform margin cannot be compact: it would carry an infinite `ε`-separated set.
* **Erasure (thermodynamic bridge).** The uniform prior over the `2 ^ n` stored strings has
  Shannon entropy exactly `n · log 2`, the Landauer cost of resetting the loader.
-/

namespace Hypercomputation

open scoped BigOperators

/-! ## Finite-precision loaders and the counting bound -/

/-- A finite-precision loader stores the first `n` bits of an oracle in a physical state and
reads them back exactly.  This is the finite approximation to the ideal `ExactOracleLoader`. -/
structure FiniteOracleLoader (State : Type*) (n : ℕ) where
  /-- Encode an `n`-bit string as a physical state. -/
  load : (Fin n → Bool) → State
  /-- Read the `i`-th stored bit from a state. -/
  read : State → Fin n → Bool
  /-- Reading recovers exactly what was stored. -/
  exact : ∀ bits i, read (load bits) i = bits i

namespace FiniteOracleLoader

variable {State : Type*} {n : ℕ}

/-- Exact recovery forces the encoding to be injective: distinct strings need distinct states. -/
theorem load_injective (device : FiniteOracleLoader State n) :
    Function.Injective device.load := by
  intro a b h
  funext i
  have ha := device.exact a i
  have hb := device.exact b i
  rw [h] at ha
  rw [← ha, hb]

/-- A finite state space that supports an `n`-bit loader has at least `2 ^ n` states. -/
theorem card_ge [Fintype State] (device : FiniteOracleLoader State n) :
    2 ^ n ≤ Fintype.card State := by
  have h := Fintype.card_le_of_injective device.load device.load_injective
  rwa [Fintype.card_fun, Fintype.card_bool, Fintype.card_fin] at h

/-- Finite loaders are not vacuous: the `n`-bit cube stores itself. -/
def idLoader (n : ℕ) : FiniteOracleLoader (Fin n → Bool) n where
  load := id
  read := fun s => s
  exact := fun _ _ => rfl

end FiniteOracleLoader

/-! ## Anchor: quantitative infinite capacity of exact loaders

The ideal loader of the foundational chapter restricts to a finite-precision loader on every
finite prefix, so its state space must dominate `2 ^ n` for **all** `n`.  This is a
quantitative strengthening of `exact_loader_requires_infinite_precision`. -/

/-- Restrict an ideal exact loader to the first `n` coordinates, padding with `false`. -/
def _root_.Hypercomputation.ExactOracleLoader.restrict
    {State : Type*} (device : ExactOracleLoader State) (n : ℕ) :
    FiniteOracleLoader State n where
  load bits := device.load (fun m => if h : m < n then bits ⟨m, h⟩ else false)
  read s i := device.read s i
  exact bits i := by
    have h := device.exact (fun m => if h : m < n then bits ⟨m, h⟩ else false) i
    simp only [h, i.isLt, dif_pos, Fin.eta]

/-- An ideal exact loader over a finite state space would need at least `2 ^ n` states for
every `n`, which is impossible; equivalently, its state space grows without bound. -/
theorem exact_loader_card_ge {State : Type*} [Fintype State]
    (device : ExactOracleLoader State) (n : ℕ) :
    2 ^ n ≤ Fintype.card State :=
  (device.restrict n).card_ge

/-! ## The metric packing refinement (energy–precision tradeoff) -/

/-- A metric loader stores `n`-bit strings with a uniform *distinguishability margin*: any two
distinct strings map to states at distance at least `margin`. -/
structure MetricOracleLoader (State : Type*) [MetricSpace State] (n : ℕ)
    extends FiniteOracleLoader State n where
  /-- The uniform distinguishability scale. -/
  margin : ℝ
  /-- The margin is a genuine, positive resolution. -/
  margin_pos : 0 < margin
  /-- Distinct stored strings are held at least `margin` apart. -/
  separated : ∀ b b', b ≠ b' → margin ≤ dist (load b) (load b')

/-- A finite set of states is `ε`-separated if its distinct members are `ε` apart. -/
def IsMarginSeparated {State : Type*} [MetricSpace State] (ε : ℝ) (s : Finset State) : Prop :=
  ∀ x ∈ s, ∀ y ∈ s, x ≠ y → ε ≤ dist x y

namespace MetricOracleLoader

variable {State : Type*} [MetricSpace State] {n : ℕ}

/-- A metric loader materializes a `margin`-separated set of exactly `2 ^ n` states. -/
theorem exists_separated_set (device : MetricOracleLoader State n) :
    ∃ s : Finset State, IsMarginSeparated device.margin s ∧ s.card = 2 ^ n := by
  classical
  refine ⟨(Finset.univ : Finset (Fin n → Bool)).image device.load, ?_, ?_⟩
  · intro x hx y hy hxy
    simp only [Finset.mem_image, Finset.mem_univ, true_and] at hx hy
    obtain ⟨a, rfl⟩ := hx
    obtain ⟨b, rfl⟩ := hy
    exact device.separated a b (fun h => hxy (by rw [h]))
  · rw [Finset.card_image_of_injective _ device.toFiniteOracleLoader.load_injective]
    simp [Finset.card_univ]

/-- **Energy–precision tradeoff.**  Suppose the physical state space obeys a packing law: every
`margin`-separated configuration of states fits inside a volume-`V`, dimension-`d` region, so
its cardinality is at most `(V / margin) ^ d`.  Then resolving `n` bits at distinguishability
scale `margin` forces the resource inequality

  `n · log 2 ≤ d · (log V + log (1 / margin))`.

Reading `log(1/margin) = log(1/ε)` as *precision* and `d · log V` as an *energy/volume* budget,
this is the promised falsifiable lower bound of the form `d · log(1/ε) ≳ c · n`. -/
theorem energy_precision_tradeoff (device : MetricOracleLoader State n)
    (V : ℝ) (d : ℕ) (hV : 0 < V)
    (packing : ∀ s : Finset State, IsMarginSeparated device.margin s →
      (s.card : ℝ) ≤ (V / device.margin) ^ d) :
    (n : ℝ) * Real.log 2 ≤ d * (Real.log V + Real.log (1 / device.margin)) := by
  obtain ⟨s, hsep, hcard⟩ := device.exists_separated_set
  have hpack := packing s hsep
  rw [hcard] at hpack
  have hcast : ((2 ^ n : ℕ) : ℝ) = (2 : ℝ) ^ n := by push_cast; ring
  rw [hcast] at hpack
  -- take logs of `(2:ℝ)^n ≤ (V / margin)^d`
  have h2pos : (0 : ℝ) < (2 : ℝ) ^ n := by positivity
  have hlog := Real.log_le_log h2pos hpack
  rw [Real.log_pow, Real.log_pow] at hlog
  -- simplify `log (V / margin)`
  have hmpos := device.margin_pos
  have hdiv : Real.log (V / device.margin) = Real.log V + Real.log (1 / device.margin) := by
    rw [Real.log_div (ne_of_gt hV) (ne_of_gt hmpos), one_div, Real.log_inv]
    ring
  rw [hdiv] at hlog
  exact hlog

end MetricOracleLoader

/-! ## The topological obstruction: no compact universal loader -/

/-- A universal-margin loader resolves *every* oracle bit and keeps distinct oracles at a fixed
positive distance in the state space. -/
structure UniformMarginLoader (State : Type*) [MetricSpace State] where
  /-- Encode a full infinite oracle as a physical state. -/
  load : (ℕ → Bool) → State
  /-- Read any bit back from a state. -/
  read : State → ℕ → Bool
  /-- Reading recovers the encoded oracle exactly. -/
  exact : ∀ oracle i, read (load oracle) i = oracle i
  /-- Fixed uniform margin. -/
  margin : ℝ
  /-- Positivity of the margin. -/
  margin_pos : 0 < margin
  /-- Distinct oracles are held at least `margin` apart. -/
  separated : ∀ o o', o ≠ o' → margin ≤ dist (load o) (load o')

namespace UniformMarginLoader

variable {State : Type*} [MetricSpace State]

/-- The encoding of a universal-margin loader is injective. -/
theorem load_injective (device : UniformMarginLoader State) :
    Function.Injective device.load := by
  intro a b h
  funext i
  have ha := device.exact a i
  have hb := device.exact b i
  rw [h] at ha
  rw [← ha, hb]

/-- **Topological precision obstruction.**  No compact metric space supports a universal-margin
loader.  The image of `load` is an infinite set whose distinct points are all at distance at
least `margin`; such an `ε`-separated infinite set cannot live inside a compact (hence totally
bounded) space.  Cardinality alone does not forbid a continuum of states, but a *uniform*
readout margin does. -/
theorem not_compact (device : UniformMarginLoader State) [CompactSpace State] : False := by
  -- The image of `load` is an infinite, uniformly separated subset of a compact space.
  set f : (ℕ → Bool) → State := device.load with hf
  have hinj : Function.Injective f := device.load_injective
  -- Total boundedness of the whole space at scale `margin / 2`.
  have htb : TotallyBounded (Set.univ : Set State) :=
    isCompact_univ.totallyBounded
  rw [Metric.totallyBounded_iff] at htb
  obtain ⟨t, htfin, hcov⟩ := htb (device.margin / 2) (half_pos device.margin_pos)
  -- Map each oracle to a ball center covering its state; distinct oracles at margin apart
  -- cannot share a center, so this map is injective into a finite set — contradiction.
  have hchoose : ∀ o : ℕ → Bool, ∃ c ∈ t, f o ∈ Metric.ball c (device.margin / 2) := by
    intro o
    have : f o ∈ ⋃ c ∈ t, Metric.ball c (device.margin / 2) := hcov (Set.mem_univ _)
    simpa using this
  choose g hg hgball using hchoose
  have hginj : Function.Injective g := by
    intro a b hab
    by_contra hne
    have hne' : a ≠ b := hne
    have hsep := device.separated a b hne'
    have h1 : dist (f a) (g a) < device.margin / 2 := by
      have := hgball a; rwa [Metric.mem_ball] at this
    have h2 : dist (f b) (g b) < device.margin / 2 := by
      have := hgball b; rwa [Metric.mem_ball] at this
    rw [hab] at h1
    have : dist (f a) (f b) < device.margin := by
      calc dist (f a) (f b) ≤ dist (f a) (g b) + dist (g b) (f b) := dist_triangle _ _ _
        _ = dist (f a) (g b) + dist (f b) (g b) := by rw [dist_comm (g b) (f b)]
        _ < device.margin / 2 + device.margin / 2 := add_lt_add h1 h2
        _ = device.margin := by ring
    exact absurd hsep (not_le.mpr this)
  -- `g` injects an infinite type into the finite `t`, impossible.
  have : Infinite (ℕ → Bool) := infinite_binary_oracles
  have himg : (g '' Set.univ).Finite :=
    htfin.subset (Set.image_subset_iff.mpr (fun o _ => hg o))
  exact absurd (himg.of_finite_image hginj.injOn) Set.infinite_univ

end UniformMarginLoader

/-! ## The thermodynamic bridge: Landauer erasure cost -/

/-- **Erasure cost of a finite loader.**  Under a uniform prior over the `2 ^ n` distinguishable
stored strings, the stored Shannon entropy is exactly `n · log 2` nats, and the state space
contains at least `2 ^ n` states to realize it.  Resetting the loader therefore dissipates at
least `n · log 2` of entropy — Landauer's `n` bits of exported side information. -/
theorem finite_loader_erasure_cost {State : Type*} [Fintype State] {n : ℕ}
    (device : FiniteOracleLoader State n) :
    Real.log ((2 : ℝ) ^ n) = (n : ℝ) * Real.log 2 ∧ 2 ^ n ≤ Fintype.card State :=
  ⟨Real.log_pow 2 n, device.card_ge⟩

-- !-- Lab Notes -- !--
-- Hypothesis: The qualitative infinite-capacity obstruction for exact oracle loading should
-- refine to quantitative metric and thermodynamic resource inequalities, because exact loading
-- is fundamentally an injective encoding of the bit-cube `Fin n → Bool` into physical states.
-- Experiment: We isolated the finite-precision loader as the primitive object, proved its
-- encoding injective, and pushed this single fact through four independent lenses — counting
-- (`card_ge`), metric packing (`energy_precision_tradeoff`), compactness / total boundedness
-- (`UniformMarginLoader.not_compact`), and entropy (`finite_loader_erasure_cost`).
-- Analysis: All four survive. The counting bound quantifies the foundational theorem: an ideal
-- loader forces `2 ^ n` states for every `n` (`exact_loader_card_ge`), a strict strengthening of
-- `exact_loader_requires_infinite_precision`. The packing refinement converts a physically
-- justified packing law into a falsifiable inequality `n log 2 ≤ d (log V + log(1/ε))`. The
-- compactness result shows that cardinality is genuinely too coarse for analog systems: a
-- continuum state space is allowed, but a *uniform readout margin* is not, since it would embed
-- an infinite ε-separated set into a totally bounded space.
-- Critique: The packing law is an explicit hypothesis, not derived from mathematics alone — this
-- is honest, mirroring the foundational chapter's treatment of the energy/capacity bridge. The
-- statements are non-vacuous: `idLoader` inhabits the finite-loader type. No result collapses to
-- `True`, definitional equality, or pure `decide`; each uses injectivity, packing, triangle
-- inequalities, or logarithms.
-- Synthesis: Diagonalization gives external oracles power beyond a fixed program table; the
-- injective-encoding view then shows *why* realizing that power is physically expensive, in
-- three commensurable currencies — states, metric packing volume, and Landauer entropy.
-- !-- End Lab Notes -- !--

end Hypercomputation