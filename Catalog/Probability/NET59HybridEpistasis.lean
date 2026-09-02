import Probability.NET59TVCore

/-!
# NET-59: hybrid bounds, solo costs and the epistasis budget

A *stack* is a list of channels `F : List (Kern α α)` applied left to right
(`chain`).  Pruning replaces `F` by a second list `P` of the same length.
Three damage functionals are compared, all measured in total variation:

* the **joint cost** `tv (chain F μ) (chain P μ)` — prune everything;
* the **solo cost** at layer `j`, `tv (chain F μ) (chain (F.set j p) μ)` — prune
  layer `j` only, which is exactly the NET-59 measurement;
* the **point cost** at layer `j`, `tv (push f ν) (push p ν)` with
  `ν = chain (F.take j) μ` the intact upstream state — the damage layer `j`
  does to its own output law before any downstream channel sees it.

Main results.

* `tv_chain_le` — data processing along a whole stack.
* `chain_hybrid_bound` — the hybrid (telescoping) bound
  `joint ≤ hybridCost F P μ`, where `hybridCost` sums the *contextual* costs,
  each evaluated at the already-pruned upstream state.
* `chain_tv_le_depth_mul` — if every layer's pruning is `ε`-close **uniformly in
  its input**, the joint cost is at most `depth · ε`.  This is the only
  hypothesis under which a per-layer budget really does add up.
* `solo_le_point` — the solo cost never exceeds the point cost: the downstream
  stack can only mask damage, never reveal it.  Hence a flat solo profile is
  *evidence-free* about the point profile.
* `hybrid_le_point_plus_drift`, `chain_bound_of_points` — the epistasis budget:
  joint cost `≤ Σ point costs + 2 · Σ upstream drift`, with the drift itself
  controlled by the earlier layers.  For depth two this reads
  `joint ≤ 3 · point₀ + point₁`.
-/

namespace Catalog.Probability.NET59

open Finset

variable {α : Type*} [Fintype α]

/-! ## 1. Stacks -/

/-- Run a stack of channels on an input law, first layer first. -/
def chain : List (Kern α α) → Dist α → Dist α
  | [], μ => μ
  | K :: L, μ => chain L (push K μ)

@[simp] theorem chain_nil (μ : Dist α) : chain [] μ = μ := rfl

@[simp] theorem chain_cons (K : Kern α α) (L : List (Kern α α)) (μ : Dist α) :
    chain (K :: L) μ = chain L (push K μ) := rfl

theorem chain_append (L₁ L₂ : List (Kern α α)) (μ : Dist α) :
    chain (L₁ ++ L₂) μ = chain L₂ (chain L₁ μ) := by
  induction L₁ generalizing μ with
  | nil => simp
  | cons K L ih => simp [ih]

/-- **Data processing along a stack.** -/
theorem tv_chain_le (L : List (Kern α α)) (μ ν : Dist α) :
    tv (chain L μ) (chain L ν) ≤ tv μ ν := by
  induction L generalizing μ ν with
  | nil => simp
  | cons K L ih => exact (ih (push K μ) (push K ν)).trans (tv_push_le K μ ν)

/-! ## 2. The hybrid (telescoping) bound -/

/-- The sum of the *contextual* per-layer costs: layer `j` is charged the damage
it does at the state reached after pruning all layers before it. -/
def hybridCost : List (Kern α α) → List (Kern α α) → Dist α → ℚ
  | [], _, _ => 0
  | _ :: _, [], _ => 0
  | f :: F, p :: P, μ => tv (push f μ) (push p μ) + hybridCost F P (push p μ)

@[simp] theorem hybridCost_nil (P : List (Kern α α)) (μ : Dist α) :
    hybridCost [] P μ = 0 := rfl

@[simp] theorem hybridCost_cons (f p : Kern α α) (F P : List (Kern α α)) (μ : Dist α) :
    hybridCost (f :: F) (p :: P) μ = tv (push f μ) (push p μ) + hybridCost F P (push p μ) :=
  rfl

theorem hybridCost_nonneg (F P : List (Kern α α)) (μ : Dist α) : 0 ≤ hybridCost F P μ := by
  induction F generalizing P μ with
  | nil => simp
  | cons f F ih =>
      cases P with
      | nil => simp [hybridCost]
      | cons p P => exact add_nonneg (tv_nonneg _ _) (ih P (push p μ))

/-- **Hybrid bound.**  The joint damage of pruning a whole stack is at most the
sum of the contextual per-layer damages. -/
theorem chain_hybrid_bound (F P : List (Kern α α)) (hlen : F.length = P.length) (μ : Dist α) :
    tv (chain F μ) (chain P μ) ≤ hybridCost F P μ := by
  induction F generalizing P μ with
  | nil =>
      cases P with
      | nil => simp
      | cons p P => simp at hlen
  | cons f F ih =>
      cases P with
      | nil => simp at hlen
      | cons p P =>
          have h1 : tv (chain F (push f μ)) (chain P (push p μ))
              ≤ tv (chain F (push f μ)) (chain F (push p μ))
                + tv (chain F (push p μ)) (chain P (push p μ)) := tv_triangle _ _ _
          have h2 : tv (chain F (push f μ)) (chain F (push p μ)) ≤ tv (push f μ) (push p μ) :=
            tv_chain_le F _ _
          have h3 := ih P (by simpa using hlen) (push p μ)
          simp only [chain_cons, hybridCost_cons]
          linarith

/-! ## 3. Uniform per-layer budgets do add up -/

/-- If every layer of the stack is replaced by a channel that is `ε`-close to it
**at every input state**, the joint damage is at most `depth · ε`.

The hypothesis is genuinely about the worst case over upstream states; the
NET-59 solo profile only probes one state per layer, and
`Probability.NET59NonIdentifiability` shows the difference is fatal. -/
theorem chain_tv_le_depth_mul {ε : ℚ} :
    ∀ (F P : List (Kern α α)), F.length = P.length →
      (∀ q ∈ F.zip P, ∀ a : α, tv (q.1 a) (q.2 a) ≤ ε) →
      ∀ μ : Dist α, tv (chain F μ) (chain P μ) ≤ F.length * ε := by
  intro F
  induction F with
  | nil =>
      intro P hlen _ μ
      cases P with
      | nil => simp
      | cons p P => simp at hlen
  | cons f F ih =>
      intro P hlen h μ
      cases P with
      | nil => simp at hlen
      | cons p P =>
          have hfp : ∀ a : α, tv (f a) (p a) ≤ ε := h (f, p) (by simp) 
          have hstep : tv (push f μ) (push p μ) ≤ ε := tv_push_perturb_unif f p μ hfp
          have htail : ∀ q ∈ F.zip P, ∀ a : α, tv (q.1 a) (q.2 a) ≤ ε := by
            intro q hq; exact h q (by simp [List.zip_cons_cons, hq])
          have hrec := ih P (by simpa using hlen) htail (push p μ)
          have h1 : tv (chain F (push f μ)) (chain P (push p μ))
              ≤ tv (chain F (push f μ)) (chain F (push p μ))
                + tv (chain F (push p μ)) (chain P (push p μ)) := tv_triangle _ _ _
          have h2 : tv (chain F (push f μ)) (chain F (push p μ)) ≤ tv (push f μ) (push p μ) :=
            tv_chain_le F _ _
          have : ((f :: F).length : ℚ) * ε = ε + F.length * ε := by
            push_cast [List.length_cons]; ring
          rw [chain_cons, chain_cons, this]
          linarith

/-! ## 4. Solo costs are dominated by point costs -/

/-- The intact upstream state entering layer `j`. -/
def upstream (F : List (Kern α α)) (j : ℕ) (μ : Dist α) : Dist α := chain (F.take j) μ

/-- **Solo ≤ point.**  Pruning layer `j` alone changes the *output* of the stack
by at most the amount by which it changes the output of layer `j` itself: the
downstream layers can only mask the damage.

Consequently a flat solo profile constrains nothing: it is compatible with
arbitrarily large point costs (see `Probability.NET59NonIdentifiability`). -/
theorem solo_le_point (F : List (Kern α α)) (j : ℕ) (f p : Kern α α)
    (hj : j < F.length) (hf : F[j] = f) (μ : Dist α) :
    tv (chain F μ) (chain (F.set j p) μ)
      ≤ tv (push f (upstream F j μ)) (push p (upstream F j μ)) := by
  have hF : F = F.take j ++ f :: F.drop (j + 1) := by
    conv_lhs => rw [← List.set_getElem_self hj]
    rw [List.set_eq_take_cons_drop _ hj, hf]
  have hFset : F.set j p = F.take j ++ p :: F.drop (j + 1) :=
    List.set_eq_take_cons_drop _ hj
  have e1 : chain F μ = chain (F.drop (j + 1)) (push f (upstream F j μ)) := by
    conv_lhs => rw [hF]
    rw [chain_append, chain_cons, upstream]
  have e2 : chain (F.set j p) μ = chain (F.drop (j + 1)) (push p (upstream F j μ)) := by
    rw [hFset, chain_append, chain_cons, upstream]
  rw [e1, e2]
  exact tv_chain_le _ _ _

/-! ## 5. The epistasis budget -/

/-- One layer of the epistasis accounting: the contextual cost of a layer is its
point cost at the intact state plus twice the accumulated upstream drift. -/
theorem hybrid_le_point_plus_drift (f p : Kern α α) (μ ν : Dist α) :
    tv (push f μ) (push p μ) ≤ tv (push f ν) (push p ν) + 2 * tv μ ν :=
  tv_push_context_shift f p μ ν

/-- **Depth-two epistasis budget.**  For a two-layer stack the joint damage is
bounded by the two point costs, with the *first* layer's point cost appearing
with the epistatic factor `3`: `1` for its own damage and `2` for the drift it
inflicts on the second layer's input. -/
theorem chain_bound_of_points (f₀ p₀ f₁ p₁ : Kern α α) (μ : Dist α) :
    tv (chain [f₀, f₁] μ) (chain [p₀, p₁] μ)
      ≤ 3 * tv (push f₀ μ) (push p₀ μ)
        + tv (push f₁ (push f₀ μ)) (push p₁ (push f₀ μ)) := by
  have hyb : tv (chain [f₀, f₁] μ) (chain [p₀, p₁] μ)
      ≤ tv (push f₀ μ) (push p₀ μ)
        + tv (push f₁ (push p₀ μ)) (push p₁ (push p₀ μ)) := by
    have := chain_hybrid_bound [f₀, f₁] [p₀, p₁] rfl μ
    simpa [hybridCost] using this
  have shift : tv (push f₁ (push p₀ μ)) (push p₁ (push p₀ μ))
      ≤ tv (push f₁ (push f₀ μ)) (push p₁ (push f₀ μ))
        + 2 * tv (push p₀ μ) (push f₀ μ) :=
    tv_push_context_shift f₁ p₁ (push p₀ μ) (push f₀ μ)
  rw [tv_comm (push p₀ μ) (push f₀ μ)] at shift
  linarith

end Catalog.Probability.NET59