import Speculative.AutoResearch.RLHFTiltTorsorPTX

/-!
# Tensorization of the KL-regularized RLHF objective

This file develops the *combinatorial* (product-space) theory of the RLHF / InstructGPT
objective already formalized in `Speculative.AutoResearch.RLHFGibbsVariational`:

```
J(q) = 𝔼_{y∼q}[r y] − β · KL(q ‖ p)   (+ γ · PTX term)
```

The theme is **tensorization**: when the response space is a product `Ω₁ × Ω₂`
(a token pair, two independent sub-answers, two parallel rollouts), the reference
policy is a product `p₁ ⊗ p₂`, and the reward is *additive*, `r(y₁,y₂) = r₁ y₁ + r₂ y₂`,
then every object of the theory splits:

* `partition_prodDist`   : `Z = Z₁ · Z₂`  (the partition function is multiplicative);
* `gibbsPolicy_prodDist` : the aligned policy is again a product policy;
* `klDiv_prodDist`       : KL divergence is additive on products;
* `objective_prodDist`   : the RLHF objective is additive;
* `freeEnergy_prodDist`  : the free energy (= optimal value) is additive.

The `n`-fold version (`Fin n → α`, i.i.d. reference, `r(y) = ∑ i, r (y i)`) gives
`partition_piDist : Z_n = Z₁ ^ n` and the **linear scaling laws**
`freeEnergy_piDist`, `klDiv_gibbs_piDist` and `alignmentTax_piDist`: alignment
value, information drift and PTX alignment tax all grow *exactly linearly* in the
number of independent coordinates.  The combinatorial engine is
`Finset.prod_univ_sum` (expansion of a product of sums over the "hypercube" of
index choices) — i.e. the distributive law, which is exactly why the RLHF Gibbs
measure over a product space is a product measure.

All results are `sorry`-free.
-/

namespace RLHFCombinatorics

open Finset RLHF

section Product

variable {Ω₁ Ω₂ : Type*} [Fintype Ω₁] [Fintype Ω₂]

/-- The product (independent) reference policy `p₁ ⊗ p₂` on `Ω₁ × Ω₂`. -/
def prodDist (p₁ : Ω₁ → ℝ) (p₂ : Ω₂ → ℝ) : Ω₁ × Ω₂ → ℝ := fun y => p₁ y.1 * p₂ y.2

/-- An additive (separable) reward on a product response space. -/
def addReward (r₁ : Ω₁ → ℝ) (r₂ : Ω₂ → ℝ) : Ω₁ × Ω₂ → ℝ := fun y => r₁ y.1 + r₂ y.2

theorem prodDist_isPosDist {p₁ : Ω₁ → ℝ} {p₂ : Ω₂ → ℝ} (h₁ : IsPosDist p₁)
    (h₂ : IsPosDist p₂) : IsPosDist (prodDist p₁ p₂) := by
  refine ⟨fun y => mul_pos (h₁.1 y.1) (h₂.1 y.2), ?_⟩
  rw [Fintype.sum_prod_type]
  simp only [prodDist]
  rw [← Finset.sum_mul_sum, h₁.2, h₂.2, mul_one]

/-- **Multiplicativity of the partition function.**  Independent reference policies plus
additive rewards give a partition function that factorizes. -/
theorem partition_prodDist {β : ℝ} {r₁ : Ω₁ → ℝ} {r₂ : Ω₂ → ℝ} {p₁ : Ω₁ → ℝ} {p₂ : Ω₂ → ℝ} :
    partition β (addReward r₁ r₂) (prodDist p₁ p₂)
      = partition β r₁ p₁ * partition β r₂ p₂ := by
  simp only [partition, prodDist, addReward, Fintype.sum_prod_type, add_div, Real.exp_add]
  rw [Finset.sum_mul_sum]
  exact Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun b _ => by ring

/-- **The aligned policy of a separable problem is a product policy.**  Tilting a product
reference by an additive reward cannot create correlations between the coordinates. -/
theorem gibbsPolicy_prodDist {β : ℝ} {r₁ : Ω₁ → ℝ} {r₂ : Ω₂ → ℝ} {p₁ : Ω₁ → ℝ} {p₂ : Ω₂ → ℝ}
    [Nonempty Ω₁] [Nonempty Ω₂] (h₁ : IsPosDist p₁) (h₂ : IsPosDist p₂) :
    gibbsPolicy β (addReward r₁ r₂) (prodDist p₁ p₂)
      = prodDist (gibbsPolicy β r₁ p₁) (gibbsPolicy β r₂ p₂) := by
  have hZ₁ := (partition_pos (β := β) (r := r₁) h₁).ne'
  have hZ₂ := (partition_pos (β := β) (r := r₂) h₂).ne'
  funext y
  simp only [gibbsPolicy, prodDist, addReward, partition_prodDist, add_div, Real.exp_add]
  field_simp

/-- **Additivity of the KL divergence on product policies.** -/
theorem klDiv_prodDist {q₁ g₁ : Ω₁ → ℝ} {q₂ g₂ : Ω₂ → ℝ}
    (hq₁ : IsPosDist q₁) (hq₂ : IsPosDist q₂) (hg₁ : IsPosDist g₁) (hg₂ : IsPosDist g₂) :
    klDiv (prodDist q₁ q₂) (prodDist g₁ g₂) = klDiv q₁ g₁ + klDiv q₂ g₂ := by
  have hsplit : ∀ a : Ω₁, ∀ b : Ω₂,
      q₁ a * q₂ b * Real.log (q₁ a * q₂ b / (g₁ a * g₂ b))
        = q₂ b * (q₁ a * Real.log (q₁ a / g₁ a)) + q₁ a * (q₂ b * Real.log (q₂ b / g₂ b)) := by
    intro a b
    have h : q₁ a * q₂ b / (g₁ a * g₂ b) = (q₁ a / g₁ a) * (q₂ b / g₂ b) := by
      field_simp
    rw [h, Real.log_mul (div_pos (hq₁.1 a) (hg₁.1 a)).ne' (div_pos (hq₂.1 b) (hg₂.1 b)).ne']
    ring
  simp only [klDiv, prodDist, Fintype.sum_prod_type]
  rw [Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun b _ => hsplit a b]
  simp only [Finset.sum_add_distrib, ← Finset.sum_mul, ← Finset.mul_sum]
  rw [hq₂.2, hq₁.2]
  simp [Finset.mul_sum]

theorem expectation_prodDist {q₁ : Ω₁ → ℝ} {q₂ : Ω₂ → ℝ} {r₁ : Ω₁ → ℝ} {r₂ : Ω₂ → ℝ}
    (hq₁ : IsDist q₁) (hq₂ : IsDist q₂) :
    ∑ y : Ω₁ × Ω₂, prodDist q₁ q₂ y * addReward r₁ r₂ y
      = (∑ a, q₁ a * r₁ a) + ∑ b, q₂ b * r₂ b := by
  have hsplit : ∀ a : Ω₁, ∀ b : Ω₂,
      q₁ a * q₂ b * (r₁ a + r₂ b) = q₂ b * (q₁ a * r₁ a) + q₁ a * (q₂ b * r₂ b) := by
    intro a b; ring
  simp only [prodDist, addReward, Fintype.sum_prod_type]
  rw [Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun b _ => hsplit a b]
  simp only [Finset.sum_add_distrib, ← Finset.sum_mul, ← Finset.mul_sum]
  rw [hq₂.2, hq₁.2]
  simp [Finset.mul_sum]

/-- **Tensorization of the RLHF objective.**  On a separable problem the objective of a
product policy is the sum of the coordinate objectives. -/
theorem objective_prodDist {β : ℝ} {r₁ p₁ q₁ : Ω₁ → ℝ} {r₂ p₂ q₂ : Ω₂ → ℝ}
    (hq₁ : IsPosDist q₁) (hq₂ : IsPosDist q₂) (hp₁ : IsPosDist p₁) (hp₂ : IsPosDist p₂) :
    objective β (addReward r₁ r₂) (prodDist p₁ p₂) (prodDist q₁ q₂)
      = objective β r₁ p₁ q₁ + objective β r₂ p₂ q₂ := by
  simp only [objective, expectation_prodDist hq₁.isDist hq₂.isDist,
    klDiv_prodDist hq₁ hq₂ hp₁ hp₂]
  ring

/-- **Additivity of the free energy** (= optimal RLHF value) on separable problems. -/
theorem freeEnergy_prodDist {β : ℝ} {r₁ p₁ : Ω₁ → ℝ} {r₂ p₂ : Ω₂ → ℝ}
    [Nonempty Ω₁] [Nonempty Ω₂] (h₁ : IsPosDist p₁) (h₂ : IsPosDist p₂) :
    freeEnergy β (addReward r₁ r₂) (prodDist p₁ p₂)
      = freeEnergy β r₁ p₁ + freeEnergy β r₂ p₂ := by
  have hZ₁ := partition_pos (β := β) (r := r₁) h₁
  have hZ₂ := partition_pos (β := β) (r := r₂) h₂
  simp only [freeEnergy, partition_prodDist]
  rw [Real.log_mul hZ₁.ne' hZ₂.ne']
  ring

end Product

section TensorPower

variable {α : Type*} [Fintype α] {n : ℕ}

/-- The i.i.d. reference policy `p^{⊗n}` on the space `Fin n → α` of length-`n` responses. -/
def piDist (n : ℕ) (p : α → ℝ) : (Fin n → α) → ℝ := fun y => ∏ i, p (y i)

/-- A per-token (additive) reward on length-`n` responses. -/
def sumReward (n : ℕ) (r : α → ℝ) : (Fin n → α) → ℝ := fun y => ∑ i, r (y i)

theorem piDist_isPosDist {p : α → ℝ} (hp : IsPosDist p) : IsPosDist (piDist n p) := by
  refine ⟨fun y => Finset.prod_pos fun i _ => hp.1 (y i), ?_⟩
  have := Finset.prod_univ_sum (fun _ : Fin n => (univ : Finset α)) (fun _ a => p a)
  simp only [Fintype.piFinset_univ] at this
  simpa [piDist, hp.2] using this.symm

/-- **Tensor-power law for the partition function**: `Z_n = Z₁ ^ n`.

The proof is the distributive law `Finset.prod_univ_sum`: expanding the product of `n`
copies of the single-token partition sum enumerates exactly the `|α|^n` responses. -/
theorem partition_piDist {β : ℝ} {r p : α → ℝ} :
    partition β (sumReward n r) (piDist n p) = (partition β r p) ^ n := by
  have key := Finset.prod_univ_sum (fun _ : Fin n => (univ : Finset α))
    (fun _ a => p a * Real.exp (r a / β))
  simp only [Fintype.piFinset_univ] at key
  have hterm : ∀ y : Fin n → α,
      (∏ i, (p (y i) * Real.exp (r (y i) / β)))
        = piDist n p y * Real.exp (sumReward n r y / β) := by
    intro y
    rw [Finset.prod_mul_distrib, ← Real.exp_sum]
    simp [piDist, sumReward, Finset.sum_div]
  rw [partition]
  calc ∑ y : Fin n → α, piDist n p y * Real.exp (sumReward n r y / β)
      = ∑ y : Fin n → α, ∏ i, (p (y i) * Real.exp (r (y i) / β)) :=
        Finset.sum_congr rfl fun y _ => (hterm y).symm
    _ = ∏ _i : Fin n, ∑ a, p a * Real.exp (r a / β) := key.symm
    _ = (partition β r p) ^ n := by simp [partition]

/-- **Linear scaling of the free energy in the number of independent coordinates.**
The optimal value of the KL-regularized objective on `n` i.i.d. coordinates is exactly
`n` times the single-coordinate optimum: alignment value is *extensive*. -/
theorem freeEnergy_piDist {β : ℝ} {r p : α → ℝ} [Nonempty α] (hp : IsPosDist p) :
    freeEnergy β (sumReward n r) (piDist n p) = n * freeEnergy β r p := by
  have hZ := partition_pos (β := β) (r := r) hp
  simp only [freeEnergy, partition_piDist]
  rw [Real.log_pow]
  ring

/-- The aligned policy on `n` i.i.d. coordinates is the `n`-fold product of the
single-coordinate aligned policy: **RLHF preserves independence**. -/
theorem gibbsPolicy_piDist {β : ℝ} {r p : α → ℝ} [Nonempty α] (hp : IsPosDist p) :
    gibbsPolicy β (sumReward n r) (piDist n p) = piDist n (gibbsPolicy β r p) := by
  have hZ := partition_pos (β := β) (r := r) hp
  funext y
  have hprod : ∏ i, (p (y i) * Real.exp (r (y i) / β)) / partition β r p
      = (∏ i, p (y i) * Real.exp (r (y i) / β)) / (partition β r p) ^ n := by
    rw [Finset.prod_div_distrib]
    simp
  simp only [gibbsPolicy, piDist, partition_piDist, sumReward]
  rw [hprod]
  congr 1
  rw [Finset.prod_mul_distrib, ← Real.exp_sum]
  simp [Finset.sum_div]

/-- **Marginalization identity for product policies.**  Integrating a one-coordinate
observable against an i.i.d. product measure returns the one-coordinate expectation.
The proof expands `∏ j (∑ a …)` by the distributive law, the combinatorial heart of
tensorization. -/
theorem sum_piDist_mul_apply {q : α → ℝ} (hq : ∑ a, q a = 1) (f : α → ℝ) (i : Fin n) :
    ∑ y : Fin n → α, (∏ j, q (y j)) * f (y i) = ∑ a, q a * f a := by
  classical
  have key := Finset.prod_univ_sum (fun _ : Fin n => (univ : Finset α))
      (fun j a => q a * (if j = i then f a else 1))
  simp only [Fintype.piFinset_univ] at key
  have hL : ∏ j : Fin n, ∑ a, q a * (if j = i then f a else 1) = ∑ a, q a * f a := by
    rw [Finset.prod_congr rfl (g := fun j => if j = i then (∑ a, q a * f a) else 1)
      (fun j _ => by by_cases h : j = i <;> simp [h, hq])]
    simp
  have hR : ∀ y : Fin n → α, (∏ j, q (y j) * (if j = i then f (y j) else 1))
      = (∏ j, q (y j)) * f (y i) := by
    intro y
    rw [Finset.prod_mul_distrib]
    congr 1
    simp
  rw [hL] at key
  rw [key]
  exact Finset.sum_congr rfl fun y _ => (hR y).symm

/-- **Extensivity of the expected reward** under the aligned policy. -/
theorem expectation_gibbs_piDist {β : ℝ} {r p : α → ℝ} [Nonempty α] (hp : IsPosDist p) :
    ∑ y : Fin n → α, gibbsPolicy β (sumReward n r) (piDist n p) y * sumReward n r y
      = n * ∑ a, gibbsPolicy β r p a * r a := by
  have hg : IsPosDist (gibbsPolicy β r p) := gibbsPolicy_isPosDist hp
  rw [gibbsPolicy_piDist hp]
  simp only [piDist, sumReward, Finset.mul_sum]
  rw [Finset.sum_comm]
  rw [Finset.sum_congr rfl fun i _ => sum_piDist_mul_apply hg.2 r i]
  simp [Finset.sum_const, Finset.mul_sum, mul_comm]

/-- **Extensivity of the information drift.**  The KL divergence between the aligned
policy and the reference on `n` i.i.d. coordinates is `n` times the single-coordinate
drift: the policy drifts *linearly* in the response length, so per-token KL budgets
are the only length-stable regularizers. -/
theorem klDiv_gibbs_piDist {β : ℝ} {r p : α → ℝ} [Nonempty α] (hβ : 0 < β)
    (hp : IsPosDist p) :
    klDiv (gibbsPolicy β (sumReward n r) (piDist n p)) (piDist n p)
      = n * klDiv (gibbsPolicy β r p) p := by
  have hpn : IsPosDist (piDist n p) := piDist_isPosDist hp
  have hne : Nonempty (Fin n → α) := ⟨fun _ => Classical.arbitrary α⟩
  -- read the KL off the exact free-energy identity, in both cases
  have hobj_n := objective_gibbs (β := β) (r := sumReward n r) (p := piDist n p) hβ hpn
  have hobj_1 := objective_gibbs (β := β) (r := r) (p := p) hβ hp
  rw [objective] at hobj_n hobj_1
  have hexp := expectation_gibbs_piDist (β := β) (r := r) (p := p) (n := n) hp
  have hfe := freeEnergy_piDist (β := β) (r := r) (p := p) (n := n) hp
  simp only [freeEnergy] at hfe
  have h1 : β * klDiv (gibbsPolicy β (sumReward n r) (piDist n p)) (piDist n p)
      = ∑ y : Fin n → α, gibbsPolicy β (sumReward n r) (piDist n p) y * sumReward n r y
        - β * Real.log (partition β (sumReward n r) (piDist n p)) := by linarith
  have h2 : β * klDiv (gibbsPolicy β r p) p
      = (∑ a, gibbsPolicy β r p a * r a) - β * Real.log (partition β r p) := by linarith
  have hkey : β * klDiv (gibbsPolicy β (sumReward n r) (piDist n p)) (piDist n p)
      = β * (n * klDiv (gibbsPolicy β r p) p) := by
    rw [h1, hexp, hfe]
    linear_combination (-(n : ℝ)) * h2
  exact mul_left_cancel₀ hβ.ne' hkey

/-- **Linear alignment tax.**  With an i.i.d. reference, an additive reward and an i.i.d.
pretraining distribution, the exact value of the PTX-augmented objective at the aligned
policy is `n` times its one-coordinate value: reward gain, entropy cost and the
information distance to the pretraining data all scale linearly and hence *cannot* be
traded off asymptotically by tuning `β`, `γ` alone. -/
theorem objectivePTX_gibbs_piDist {β γ : ℝ} {r p d : α → ℝ} [Nonempty α] (hβ : 0 < β)
    (hp : IsPosDist p) (hd : IsPosDist d) :
    objectivePTX β γ (sumReward n r) (piDist n p) (piDist n d)
        (gibbsPolicy β (sumReward n r) (piDist n p))
      = n * objectivePTX β γ r p d (gibbsPolicy β r p) := by
  have hne : Nonempty (Fin n → α) := ⟨fun _ => Classical.arbitrary α⟩
  have hpn : IsPosDist (piDist n p) := piDist_isPosDist hp
  have hdn : IsPosDist (piDist n d) := piDist_isPosDist hd
  have hg : IsPosDist (gibbsPolicy β r p) := gibbsPolicy_isPosDist hp
  have hgn : IsPosDist (gibbsPolicy β (sumReward n r) (piDist n p)) :=
    gibbsPolicy_isPosDist hpn
  have hval_n := ptx_value_at_gibbs (β := β) (γ := γ) (r := sumReward n r)
    (p := piDist n p) (d := piDist n d) hβ hpn hdn.isDist
  have hval_1 := ptx_value_at_gibbs (β := β) (γ := γ) (r := r) (p := p) (d := d)
    hβ hp hd.isDist
  have hfe := freeEnergy_piDist (β := β) (r := r) (p := p) (n := n) hp
  simp only [freeEnergy] at hfe
  -- entropy of an i.i.d. distribution is `n` times the one-coordinate entropy
  have hent : entropy (piDist n d) = n * entropy d := by
    have : ∀ i : Fin n, ∑ y : Fin n → α, (∏ j, d (y j)) * Real.log (d (y i))
        = ∑ a, d a * Real.log (d a) :=
      fun i => sum_piDist_mul_apply hd.2 (fun a => Real.log (d a)) i
    have hlog : ∀ y : Fin n → α, piDist n d y * Real.log (piDist n d y)
        = ∑ i, (∏ j, d (y j)) * Real.log (d (y i)) := by
      intro y
      simp only [piDist]
      rw [Real.log_prod (fun i _ => (hd.1 (y i)).ne'), Finset.mul_sum]
    simp only [entropy]
    rw [Finset.sum_congr rfl fun y _ => hlog y, Finset.sum_comm]
    rw [Finset.sum_congr rfl fun i _ => this i]
    simp [Finset.sum_const, Finset.mul_sum]
  -- the KL from the pretraining law to the aligned policy also tensorizes
  have hkl : klDiv (piDist n d) (gibbsPolicy β (sumReward n r) (piDist n p))
      = n * klDiv d (gibbsPolicy β r p) := by
    rw [gibbsPolicy_piDist hp]
    have hterm : ∀ y : Fin n → α,
        piDist n d y * Real.log (piDist n d y / piDist n (gibbsPolicy β r p) y)
          = ∑ i, (∏ j, d (y j)) * Real.log (d (y i) / gibbsPolicy β r p (y i)) := by
      intro y
      have hpos : ∀ i : Fin n, d (y i) / gibbsPolicy β r p (y i) ≠ 0 := by
        intro i
        exact ne_of_gt (div_pos (hd.1 (y i)) (hg.1 (y i)))
      have hdiv : piDist n d y / piDist n (gibbsPolicy β r p) y
          = ∏ i, d (y i) / gibbsPolicy β r p (y i) := by
        simp only [piDist]
        rw [Finset.prod_div_distrib]
      rw [hdiv, Real.log_prod (fun i _ => hpos i), Finset.mul_sum]
      simp [piDist]
    simp only [klDiv]
    rw [Finset.sum_congr rfl fun y _ => hterm y, Finset.sum_comm]
    rw [Finset.sum_congr rfl fun i _ =>
      sum_piDist_mul_apply hd.2 (fun a => Real.log (d a / gibbsPolicy β r p a)) i]
    simp [Finset.sum_const, Finset.mul_sum]
  rw [hval_n, hval_1, hfe, hent, hkl]
  ring

end TensorPower

end RLHFCombinatorics