/-
# The phase route is closed, but the interaction route is open — exactly

This file proves a *separation theorem* for feature encodings, in the exact
finite-sample least-squares calculus of `Logic.PhaseRouteLeastSquares`.

Setting.  The sample space is a product `α × β` (think: the residue of a root
position modulo one prime, paired with the residue modulo a second prime, or
paired with itself), and the target is an **alignment indicator**

  `graphInd σ (a, b) = if b = σ a then 1 else 0`   (`σ : α ≃ β`).

*Singleton* (linear-phase) encodings are the additive predictors
`additive u v (a, b) = u a + v b`, where `u`, `v` are **arbitrary** real
functions of a single coordinate — this is strictly more general than one-hot
dummies, sines/cosines of phases, or any other per-coordinate featurisation, and
it also covers arbitrarily many such features used simultaneously, since the
additive family is closed under sums.

Results.

* `cov_graphInd_additive_eq_zero` : every additive predictor has covariance
  *exactly* `0` with the alignment target.  There is no small residual signal to
  be found: the linear phase route is closed identically, not approximately.
* `graphInd_additive_no_gain` / `graphInd_additive_strict_loss` : consequently no
  additive predictor beats the intercept-only baseline, and every *nonconstant*
  one is strictly worse; the excess error equals the predictor's own variance.
* `Rsq_additive_nonpos` : the same statement in `R²` units — the attainable gain
  is `≤ 0`, never the pre-stated `+0.05`, and never even `+0.0215`.
* `nuisance_no_gain` : adding arbitrarily many features from an *independent*
  block of coordinates (other primes / other windows) does not change this.
* `graphInd_eq_sum_interactions` : the alignment target is *exactly* a sum of
  `card α` degree-2 products of one-hot singleton features, and
  `Rsq_interaction_eq_one` : that degree-2 encoding attains `R² = 1`.

So the missing variance is not merely hard to reach with singleton phases; it
lives, provably and entirely, in the degree-2 (joint alignment) layer.
-/
import Logic.PhaseRouteLeastSquares

namespace Logic.PhaseRoute

open Finset

/-! ### Bilinearity tools for the empirical covariance -/

section Bilinear
variable {ι : Type*} [Fintype ι] [Nonempty ι]

omit [Nonempty ι] in
lemma cov_add_right (y h k : ι → ℝ) :
    cov y (fun i => h i + k i) = cov y h + cov y k := by
  have hfun : (fun i => y i * (h i + k i)) = (fun i => y i * h i + y i * k i) := by
    funext i; ring
  simp only [cov, hfun]
  rw [avg_add, avg_add]
  ring

omit [Nonempty ι] in
lemma cov_comm (y h : ι → ℝ) : cov y h = cov h y := by
  have hfun : (fun i => y i * h i) = (fun i => h i * y i) := by funext i; ring
  simp only [cov, hfun]
  ring

end Bilinear

/-! ### Products: lifting, and independence of distinct blocks -/

section Product
variable {α β : Type*} [Fintype α] [Fintype β] [Nonempty α] [Nonempty β]

/-- Averaging a function of the first coordinate over the product is the same as
averaging it over the first factor. -/
lemma avg_comp_fst (f : α → ℝ) : avg (fun x : α × β => f x.1) = avg f := by
  have hb : (0:ℝ) < (Fintype.card β : ℝ) := by
    have : 0 < Fintype.card β := Fintype.card_pos
    positivity
  have ha : (0:ℝ) < (Fintype.card α : ℝ) := by
    have : 0 < Fintype.card α := Fintype.card_pos
    positivity
  have hs : (∑ x : α × β, f x.1) = (Fintype.card β : ℝ) * ∑ a, f a := by
    rw [Fintype.sum_prod_type]
    have hone : ∀ a : α, (∑ _b : β, f a) = (Fintype.card β : ℝ) * f a := by
      intro a
      simp [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    rw [Finset.sum_congr rfl fun a _ => hone a, ← Finset.mul_sum]
  simp only [avg, hs, Fintype.card_prod, Nat.cast_mul]
  field_simp

lemma avg_comp_snd (g : β → ℝ) : avg (fun x : α × β => g x.2) = avg g := by
  have ha : (0:ℝ) < (Fintype.card α : ℝ) := by
    have : 0 < Fintype.card α := Fintype.card_pos
    positivity
  have hb : (0:ℝ) < (Fintype.card β : ℝ) := by
    have : 0 < Fintype.card β := Fintype.card_pos
    positivity
  have hs : (∑ x : α × β, g x.2) = (Fintype.card α : ℝ) * ∑ b, g b := by
    rw [Fintype.sum_prod_type]
    simp [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  simp only [avg, hs, Fintype.card_prod, Nat.cast_mul]
  field_simp

/-- Coordinates of a product are (empirically) independent: a function of the
first coordinate and a function of the second have zero covariance. -/
theorem cov_fst_snd_eq_zero (f : α → ℝ) (g : β → ℝ) :
    cov (fun x : α × β => f x.1) (fun x : α × β => g x.2) = 0 := by
  have hs : (∑ x : α × β, f x.1 * g x.2) = (∑ a, f a) * (∑ b, g b) := by
    rw [Fintype.sum_prod_type]
    rw [Finset.sum_mul]
    exact Finset.sum_congr rfl fun a _ => by rw [Finset.mul_sum]
  have hprod : avg (fun x : α × β => f x.1 * g x.2) = avg f * avg g := by
    have ha : (0:ℝ) < (Fintype.card α : ℝ) := by
      have : 0 < Fintype.card α := Fintype.card_pos
      positivity
    have hb : (0:ℝ) < (Fintype.card β : ℝ) := by
      have : 0 < Fintype.card β := Fintype.card_pos
      positivity
    simp only [avg, hs, Fintype.card_prod, Nat.cast_mul]
    field_simp
  simp only [cov, hprod, avg_comp_fst, avg_comp_snd]
  ring

/-- Covariances of functions of the first coordinate are computed in the first
factor. -/
lemma cov_comp_fst (f f' : α → ℝ) :
    cov (fun x : α × β => f x.1) (fun x : α × β => f' x.1) = cov f f' := by
  have h1 : avg (fun x : α × β => f x.1 * f' x.1) = avg (fun a => f a * f' a) :=
    avg_comp_fst (β := β) (fun a => f a * f' a)
  simp only [cov, h1, avg_comp_fst]

lemma varr_comp_fst (f : α → ℝ) : varr (fun x : α × β => f x.1) = varr f :=
  cov_comp_fst f f

end Product

/-! ### Alignment targets and singleton (linear-phase) encodings -/

section Alignment
variable {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β] [Nonempty α] [Nonempty β]

/-- The alignment indicator of the bijection `σ`: the target is `1` exactly on
the graph of `σ`, i.e. exactly when the two coordinates are *jointly aligned*. -/
noncomputable def graphInd (σ : α ≃ β) : α × β → ℝ := fun x => if x.2 = σ x.1 then 1 else 0

/-- A singleton (linear-phase) predictor: an arbitrary function of the first
coordinate plus an arbitrary function of the second. -/
def additive (u : α → ℝ) (v : β → ℝ) : α × β → ℝ := fun x => u x.1 + v x.2

omit [DecidableEq β] [Nonempty α] [Nonempty β] in
lemma card_eq_of_equiv (σ : α ≃ β) : (Fintype.card β : ℝ) = (Fintype.card α : ℝ) := by
  rw [Fintype.card_congr σ]

omit [Nonempty α] [Nonempty β] in
lemma sum_graphInd (σ : α ≃ β) : (∑ x : α × β, graphInd σ x) = (Fintype.card α : ℝ) := by
  rw [Fintype.sum_prod_type]
  simp [graphInd]

omit [Nonempty β] in
lemma avg_graphInd (σ : α ≃ β) : avg (graphInd σ) = 1 / (Fintype.card α : ℝ) := by
  have ha : (0:ℝ) < (Fintype.card α : ℝ) := by
    have : 0 < Fintype.card α := Fintype.card_pos
    positivity
  have hb : (Fintype.card β : ℝ) = (Fintype.card α : ℝ) := card_eq_of_equiv σ
  simp only [avg, sum_graphInd, Fintype.card_prod, Nat.cast_mul, hb]
  field_simp

omit [Fintype α] [Fintype β] [Nonempty α] [Nonempty β] in
/-- The alignment target is idempotent as a `0/1` indicator. -/
lemma graphInd_mul_self (σ : α ≃ β) :
    (fun x : α × β => graphInd σ x * graphInd σ x) = graphInd σ := by
  funext x
  by_cases h : x.2 = σ x.1 <;> simp [graphInd, h]

omit [Nonempty β] in
/-- The variance of the alignment target: `1/m - 1/m²` with `m = card α`. -/
theorem varr_graphInd (σ : α ≃ β) :
    varr (graphInd σ) = 1 / (Fintype.card α : ℝ) - 1 / ((Fintype.card α : ℝ) ^ 2) := by
  have ha : (0:ℝ) < (Fintype.card α : ℝ) := by
    have : 0 < Fintype.card α := Fintype.card_pos
    positivity
  simp only [varr, cov, graphInd_mul_self, avg_graphInd]
  field_simp

omit [Nonempty β] in
/-- With at least two classes the alignment target is nondegenerate. -/
theorem varr_graphInd_pos (σ : α ≃ β) (hcard : 2 ≤ Fintype.card α) :
    0 < varr (graphInd σ) := by
  have ha : (2:ℝ) ≤ (Fintype.card α : ℝ) := by exact_mod_cast hcard
  have ha0 : (0:ℝ) < (Fintype.card α : ℝ) := by linarith
  rw [varr_graphInd]
  rw [sub_pos, div_lt_div_iff₀ (by positivity) ha0]
  nlinarith

omit [Nonempty β] in
/-- The mean of the target times an additive predictor. -/
lemma avg_graphInd_mul_additive (σ : α ≃ β) (u : α → ℝ) (v : β → ℝ) :
    avg (fun x : α × β => graphInd σ x * additive u v x)
      = ((∑ a, u a) + ∑ b, v b) / ((Fintype.card α : ℝ) * (Fintype.card α : ℝ)) := by
  have ha : (0:ℝ) < (Fintype.card α : ℝ) := by
    have : 0 < Fintype.card α := Fintype.card_pos
    positivity
  have hb : (Fintype.card β : ℝ) = (Fintype.card α : ℝ) := card_eq_of_equiv σ
  have hs : (∑ x : α × β, graphInd σ x * additive u v x) = (∑ a, u a) + ∑ b, v b := by
    rw [Fintype.sum_prod_type]
    have hinner : ∀ a : α, (∑ b : β, graphInd σ (a, b) * additive u v (a, b))
        = u a + v (σ a) := by
      intro a
      simp [graphInd, additive]
    rw [Finset.sum_congr rfl fun a _ => hinner a, Finset.sum_add_distrib]
    rw [Equiv.sum_comp σ v]
  simp only [avg, hs, Fintype.card_prod, Nat.cast_mul, hb]

omit [DecidableEq β] in
lemma avg_additive (u : α → ℝ) (v : β → ℝ) :
    avg (additive u v) = avg u + avg v := by
  have : additive u v = fun x : α × β => (fun a => u a) x.1 + (fun b => v b) x.2 := rfl
  rw [this, avg_add, avg_comp_fst, avg_comp_snd]

/-- **The linear phase route is closed, identically.** Every singleton
(additive) encoding has *exactly zero* empirical covariance with the alignment
target — for any bijection `σ`, any `u`, any `v`. -/
theorem cov_graphInd_additive_eq_zero (σ : α ≃ β) (u : α → ℝ) (v : β → ℝ) :
    cov (graphInd σ) (additive u v) = 0 := by
  have ha : (0:ℝ) < (Fintype.card α : ℝ) := by
    have : 0 < Fintype.card α := Fintype.card_pos
    positivity
  have hb : (Fintype.card β : ℝ) = (Fintype.card α : ℝ) := card_eq_of_equiv σ
  have hu : avg u = (∑ a, u a) / (Fintype.card α : ℝ) := rfl
  have hv : avg v = (∑ b, v b) / (Fintype.card β : ℝ) := rfl
  simp only [cov, avg_graphInd_mul_additive, avg_graphInd, avg_additive, hu, hv, hb]
  field_simp
  ring

/-- **No-gain theorem for singleton phases.** No additive predictor beats the
intercept-only baseline for an alignment target. -/
theorem graphInd_additive_no_gain (σ : α ≃ β) (u : α → ℝ) (v : β → ℝ) :
    varr (graphInd σ) ≤ msse (graphInd σ) (additive u v) :=
  msse_ge_varr_of_cov_eq_zero (cov_graphInd_additive_eq_zero σ u v)

/-- **Strict-harm theorem.** A nonconstant additive predictor is strictly worse
than the baseline, and the excess error is exactly its own variance. -/
theorem graphInd_additive_strict_loss (σ : α ≃ β) (u : α → ℝ) (v : β → ℝ)
    (hv : varr (additive u v) ≠ 0) :
    varr (graphInd σ) < msse (graphInd σ) (additive u v) :=
  msse_gt_varr_of_cov_eq_zero (cov_graphInd_additive_eq_zero σ u v) hv

theorem graphInd_additive_excess (σ : α ≃ β) (u : α → ℝ) (v : β → ℝ) :
    msse (graphInd σ) (additive u v) - varr (graphInd σ)
      = varr (additive u v)
        + (avg (graphInd σ) - avg (additive u v)) * (avg (graphInd σ) - avg (additive u v)) :=
  msse_excess_of_cov_eq_zero (cov_graphInd_additive_eq_zero σ u v)

/-- **In `R²` units: the incremental gain of any singleton phase encoding is
`≤ 0`.** -/
theorem Rsq_additive_nonpos (σ : α ≃ β) (hcard : 2 ≤ Fintype.card α) (u : α → ℝ) (v : β → ℝ) :
    Rsq (graphInd σ) (additive u v) ≤ 0 :=
  Rsq_nonpos_of_cov_eq_zero (cov_graphInd_additive_eq_zero σ u v) (varr_graphInd_pos σ hcard)

/-- Even the *best possible* affine model built on a single phase feature
`x ↦ u x.1` has squared correlation `0` with the target. -/
theorem corr_singleton_phase_eq_zero (σ : α ≃ β) (u : α → ℝ) :
    cov (graphInd σ) (fun x : α × β => u x.1) = 0 := by
  have h := cov_graphInd_additive_eq_zero σ u (fun _ => 0)
  have he : additive u (fun _ : β => (0:ℝ)) = fun x : α × β => u x.1 := by
    funext x; simp [additive]
  rwa [he] at h

theorem corr_singleton_phase_snd_eq_zero (σ : α ≃ β) (v : β → ℝ) :
    cov (graphInd σ) (fun x : α × β => v x.2) = 0 := by
  have h := cov_graphInd_additive_eq_zero σ (fun _ => 0) v
  have he : additive (fun _ : α => (0:ℝ)) v = fun x : α × β => v x.2 := by
    funext x; simp [additive]
  rwa [he] at h

end Alignment

/-! ### Nuisance blocks: other primes, other windows, still nothing -/

section Nuisance
variable {α β γ : Type*} [Fintype α] [Fintype β] [Fintype γ]
  [DecidableEq β] [Nonempty α] [Nonempty β] [Nonempty γ]

/-- **Nuisance-block invariance.** Enlarge the sample space by an independent
block `γ` (features coming from other primes or other windows). Any predictor
that is a singleton encoding in the aligned block plus an arbitrary function of
the nuisance block still has covariance exactly `0` with the alignment target,
hence still cannot beat the baseline. -/
theorem cov_nuisance_eq_zero (σ : α ≃ β) (u : α → ℝ) (v : β → ℝ) (w : γ → ℝ) :
    cov (fun x : (α × β) × γ => graphInd σ x.1)
        (fun x : (α × β) × γ => additive u v x.1 + w x.2) = 0 := by
  rw [cov_add_right]
  rw [cov_comp_fst (graphInd σ) (additive u v), cov_fst_snd_eq_zero (graphInd σ) w]
  rw [cov_graphInd_additive_eq_zero]
  ring

theorem nuisance_no_gain (σ : α ≃ β) (u : α → ℝ) (v : β → ℝ) (w : γ → ℝ) :
    varr (fun x : (α × β) × γ => graphInd σ x.1)
      ≤ msse (fun x : (α × β) × γ => graphInd σ x.1)
             (fun x : (α × β) × γ => additive u v x.1 + w x.2) :=
  msse_ge_varr_of_cov_eq_zero (cov_nuisance_eq_zero σ u v w)

end Nuisance

/-! ### The interaction layer, where the missing variance actually lives -/

section Interaction
variable {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
  [Nonempty α] [Nonempty β]

/-- One-hot singleton feature on the first coordinate. -/
noncomputable def onehotFst (c : α) : α × β → ℝ := fun x => if x.1 = c then 1 else 0

/-- One-hot singleton feature on the second coordinate. -/
noncomputable def onehotSnd (d : β) : α × β → ℝ := fun x => if x.2 = d then 1 else 0

omit [Fintype β] [Nonempty α] [Nonempty β] in
/-- **Exact degree-2 structure of the alignment target.** The target is the sum
of `card α` pairwise *products* of singleton one-hot features: it is a pure
degree-2 (interaction) object, invisible to every degree-1 encoding. -/
theorem graphInd_eq_sum_interactions (σ : α ≃ β) (x : α × β) :
    graphInd σ x = ∑ c : α, onehotFst c x * onehotSnd (σ c) x := by
  have hterm : ∀ c : α, onehotFst c x * onehotSnd (σ c) x
      = if x.1 = c then (if x.2 = σ c then (1:ℝ) else 0) else 0 := by
    intro c
    simp only [onehotFst, onehotSnd]
    split <;> simp
  rw [Finset.sum_congr rfl fun c _ => hterm c]
  simp [graphInd]

omit [Nonempty α] [Nonempty β] in
/-- The interaction encoding predicts the alignment target perfectly. -/
theorem msse_interaction_eq_zero (σ : α ≃ β) :
    msse (graphInd σ) (fun x => ∑ c : α, onehotFst c x * onehotSnd (σ c) x) = 0 := by
  have hfun : (fun x : α × β => ∑ c : α, onehotFst c x * onehotSnd (σ c) x) = graphInd σ := by
    funext x
    exact (graphInd_eq_sum_interactions σ x).symm
  rw [hfun]
  simp [msse, avg]


omit [Nonempty α] [Nonempty β] in
/-- **`R² = 1` for the degree-2 encoding.** -/
theorem Rsq_interaction_eq_one (σ : α ≃ β) :
    Rsq (graphInd σ) (fun x => ∑ c : α, onehotFst c x * onehotSnd (σ c) x) = 1 := by
  rw [Rsq, msse_interaction_eq_zero]
  simp

/-- **Separation theorem.** For a nondegenerate alignment target: every
singleton (linear-phase) encoding has `R² ≤ 0`, while the explicit degree-2
interaction encoding has `R² = 1`. The entire signal sits at degree `2`. -/
theorem phase_interaction_separation (σ : α ≃ β) (hcard : 2 ≤ Fintype.card α) :
    (∀ u : α → ℝ, ∀ v : β → ℝ, Rsq (graphInd σ) (additive u v) ≤ 0) ∧
      Rsq (graphInd σ) (fun x => ∑ c : α, onehotFst c x * onehotSnd (σ c) x) = 1 :=
  ⟨fun u v => Rsq_additive_nonpos σ hcard u v, Rsq_interaction_eq_one σ⟩

end Interaction

/-! ### The prime windows `3 ≤ p ≤ 97`, concretely -/

section PrimeWindows

/-- Diagonal alignment of two root-position residues modulo `p`. -/
noncomputable def diagAlign (p : ℕ) [NeZero p] : ZMod p × ZMod p → ℝ :=
  graphInd (Equiv.refl (ZMod p))

/-- For every prime window `p ≥ 2`, the diagonal alignment target has variance
`1/p - 1/p²` and is nondegenerate. -/
theorem varr_diagAlign (p : ℕ) [NeZero p] :
    varr (diagAlign p) = 1 / (p : ℝ) - 1 / ((p : ℝ) ^ 2) := by
  have h := varr_graphInd (Equiv.refl (ZMod p))
  rwa [ZMod.card p] at h

/-- Instantiated at the top of the high-prime window (`p = 97`): the singleton
phase gain is `≤ 0` while the interaction encoding is perfect. -/
theorem high_prime_97_separation :
    (∀ u v : ZMod 97 → ℝ, Rsq (diagAlign 97) (additive u v) ≤ 0) ∧
      Rsq (diagAlign 97)
        (fun x => ∑ c : ZMod 97, onehotFst c x * onehotSnd ((Equiv.refl (ZMod 97)) c) x) = 1 := by
  have hcard : 2 ≤ Fintype.card (ZMod 97) := by
    rw [ZMod.card]; norm_num
  exact phase_interaction_separation (Equiv.refl (ZMod 97)) hcard

/-- Instantiated at the bottom of the low-prime window (`p = 3`). -/
theorem low_prime_3_separation :
    (∀ u v : ZMod 3 → ℝ, Rsq (diagAlign 3) (additive u v) ≤ 0) ∧
      Rsq (diagAlign 3)
        (fun x => ∑ c : ZMod 3, onehotFst c x * onehotSnd ((Equiv.refl (ZMod 3)) c) x) = 1 := by
  have hcard : 2 ≤ Fintype.card (ZMod 3) := by
    rw [ZMod.card]; norm_num
  exact phase_interaction_separation (Equiv.refl (ZMod 3)) hcard

/-- Uniformly over the whole scanned range `3 ≤ p ≤ 97` (indeed for every
`p ≥ 2`): no singleton phase encoding at modulus `p` produces a positive
same-window `R²`. This is the formal counterpart of the empirical finding that
the measured `+0.0215` cannot be a real degree-1 effect. -/
theorem phase_route_closed_all_windows (p : ℕ) [NeZero p] (hp : 2 ≤ p)
    (u v : ZMod p → ℝ) : Rsq (diagAlign p) (additive u v) ≤ 0 := by
  have hcard : 2 ≤ Fintype.card (ZMod p) := by
    rw [ZMod.card]; exact hp
  exact Rsq_additive_nonpos (Equiv.refl (ZMod p)) hcard u v

end PrimeWindows

end Logic.PhaseRoute