import Mathlib

/-!
# Fork channels: exact correlation forms for OR / AND / XOR / split-count readouts

A *fork* is an `n`-bit source `x : Fin n → Bool` whose bits are independent with
`P(xᵢ = true) = p`, together with a scalar *readout* (a "channel") `F`.  This file
computes, **exactly**, how much a readout tells one about a single designated
input bit, measured by the squared Pearson correlation

`corrSq p (cIdx 0) F = Cov(x₀, F)² / (Var x₀ · Var F)`,

for the four readouts that appear in the fork literature:

* `orCh`   — the OR of the bits (the `g` channel);
* `andCh`  — the AND of the bits (the `A` channel);
* `xorCh`  — the parity of the bits (the `X` channel);
* `wCh`    — the split count, i.e. the Hamming weight (the `Is` channel).

The main discovery formalised here is that **all four answers are one and the
same rational function**

`Φ(t, n) = tⁿ / (1 + t + ⋯ + tⁿ)`,

evaluated at four different *channel parameters*:

| channel | readout | parameter `t` |
|---|---|---|
| `A`  | AND         | `p`         |
| `g`  | OR          | `1 - p`     |
| `X`  | XOR         | `(1 - 2p)²` |
| `Is` | split count | `1`         |

(see `aChan_eq`, `gChan_eq`, `xChan_eq`, `isChan_eq`).  The number of bits is
`n + 1` throughout, so `n` is the number of *non-designated* bits.

All expectations are finite sums over `Fin n → Bool` with the exact product
weights, so no normalisation or summation error can hide anywhere: the
"distributions sum to one" fact is `E_one`, proved from the master factorisation
lemma `E_prod`.

The consequences (orderings, limits, ratio behaviour, exact tables) are developed
in `MachineLearning.ForkChannelTableClosure`.
-/

namespace ForkChannel

variable {n : ℕ}

/-! ## The product measure and its expectation functional -/

/-- Weight of a bit pattern under independent `Bernoulli p` coordinates. -/
noncomputable def wt (p : ℝ) (x : Fin n → Bool) : ℝ := ∏ i, (if x i then p else 1 - p)

/-- Expectation of a real readout under the product weights. -/
noncomputable def E (p : ℝ) (F : (Fin n → Bool) → ℝ) : ℝ := ∑ x, wt p x * F x

/-- Master factorisation lemma: the expectation of a coordinatewise product is the
product of the coordinatewise expectations. -/
theorem E_prod (p : ℝ) (g : Fin n → Bool → ℝ) :
    E p (fun x => ∏ i, g i (x i)) = ∏ i, (p * g i true + (1 - p) * g i false) := by
  have h : ∀ i : Fin n, p * g i true + (1 - p) * g i false
      = ∑ b : Bool, (if b then p else 1 - p) * g i b := by intro i; simp
  rw [Finset.prod_congr rfl (fun i _ => h i), Finset.prod_univ_sum, Fintype.piFinset_univ]
  unfold E wt
  exact Finset.sum_congr rfl (fun x _ => (Finset.prod_mul_distrib).symm)

theorem E_congr (p : ℝ) {F G : (Fin n → Bool) → ℝ} (h : ∀ x, F x = G x) : E p F = E p G := by
  unfold E; exact Finset.sum_congr rfl (fun x _ => by rw [h])

theorem E_add (p : ℝ) (F G : (Fin n → Bool) → ℝ) :
    E p (fun x => F x + G x) = E p F + E p G := by
  unfold E; rw [← Finset.sum_add_distrib]; exact Finset.sum_congr rfl (fun x _ => by ring)

theorem E_sub (p : ℝ) (F G : (Fin n → Bool) → ℝ) :
    E p (fun x => F x - G x) = E p F - E p G := by
  unfold E; rw [← Finset.sum_sub_distrib]; exact Finset.sum_congr rfl (fun x _ => by ring)

theorem E_const_mul (p c : ℝ) (F : (Fin n → Bool) → ℝ) :
    E p (fun x => c * F x) = c * E p F := by
  unfold E; rw [Finset.mul_sum]; exact Finset.sum_congr rfl (fun x _ => by ring)

theorem E_sum (p : ℝ) {ι : Type*} (s : Finset ι) (F : ι → (Fin n → Bool) → ℝ) :
    E p (fun x => ∑ i ∈ s, F i x) = ∑ i ∈ s, E p (F i) := by
  unfold E
  simp_rw [Finset.mul_sum]
  rw [Finset.sum_comm]

/-- The weights really do sum to one (no unnormalised entropy can sneak in). -/
theorem E_one (p : ℝ) : E p (fun _ : Fin n → Bool => (1:ℝ)) = 1 := by
  have := E_prod (n := n) p (fun _ _ => (1:ℝ))
  simpa using this

/-! ## The four fork readouts -/

/-- Indicator readout of the `i`-th input bit. -/
def cIdx (i : Fin n) (x : Fin n → Bool) : ℝ := if x i then 1 else 0

/-- AND readout (the `A` channel). -/
def andCh (x : Fin n → Bool) : ℝ := ∏ i, (if x i then (1:ℝ) else 0)

/-- NOR readout: the indicator that all bits are `false`. -/
def norCh (x : Fin n → Bool) : ℝ := ∏ i, (if x i then (0:ℝ) else 1)

/-- OR readout (the `g` channel). -/
def orCh (x : Fin n → Bool) : ℝ := 1 - norCh x

/-- `±1`-valued parity readout. -/
def pmCh (x : Fin n → Bool) : ℝ := ∏ i, (if x i then (-1:ℝ) else 1)

/-- XOR readout (the `X` channel), the `{0,1}`-valued parity. -/
noncomputable def xorCh (x : Fin n → Bool) : ℝ := (1 - pmCh x) / 2

/-- Split-count readout (the `Is` channel): the Hamming weight. -/
def wCh (x : Fin n → Bool) : ℝ := ∑ i, cIdx i x

/-! ## Pointwise algebra of the readouts -/

theorem cIdx_prod (i : Fin n) (x : Fin n → Bool) :
    cIdx i x = ∏ j, (if j = i then (if x j then (1:ℝ) else 0) else 1) := by
  rw [Finset.prod_eq_single i (by intro b _ hb; simp [hb]) (by simp)]
  simp [cIdx]

theorem cIdx_mul_self (i : Fin n) (x : Fin n → Bool) : cIdx i x * cIdx i x = cIdx i x := by
  unfold cIdx; by_cases h : x i <;> simp [h]

theorem andCh_mul_self (x : Fin n → Bool) : andCh x * andCh x = andCh x := by
  unfold andCh
  rw [← Finset.prod_mul_distrib]
  exact Finset.prod_congr rfl (fun i _ => by by_cases h : x i <;> simp [h])

theorem norCh_mul_self (x : Fin n → Bool) : norCh x * norCh x = norCh x := by
  unfold norCh
  rw [← Finset.prod_mul_distrib]
  exact Finset.prod_congr rfl (fun i _ => by by_cases h : x i <;> simp [h])

theorem pmCh_mul_self (x : Fin n → Bool) : pmCh x * pmCh x = 1 := by
  unfold pmCh
  rw [← Finset.prod_mul_distrib]
  rw [Finset.prod_congr rfl (fun i (_ : i ∈ Finset.univ) =>
    show ((if x i then (-1:ℝ) else 1) * (if x i then (-1:ℝ) else 1)) = 1 by
      by_cases h : x i <;> simp [h])]
  simp

theorem orCh_mul_self (x : Fin n → Bool) : orCh x * orCh x = orCh x := by
  unfold orCh
  have h := norCh_mul_self x
  nlinarith [h]

theorem xorCh_mul_self (x : Fin n → Bool) : xorCh x * xorCh x = xorCh x := by
  unfold xorCh
  have h := pmCh_mul_self x
  nlinarith [h]

theorem cIdx_zero_mul_andCh (x : Fin (n+1) → Bool) :
    cIdx 0 x * andCh x = andCh x := by
  unfold cIdx andCh
  by_cases h : x 0
  · simp [h]
  · rw [Finset.prod_eq_zero (Finset.mem_univ (0 : Fin (n+1))) (by simp [h])]
    simp [h]

theorem cIdx_zero_mul_norCh (x : Fin (n+1) → Bool) :
    cIdx 0 x * norCh x = 0 := by
  unfold cIdx norCh
  by_cases h : x 0
  · rw [Finset.prod_eq_zero (Finset.mem_univ (0 : Fin (n+1))) (by simp [h])]
    simp
  · simp [h]

theorem cIdx_zero_mul_orCh (x : Fin (n+1) → Bool) :
    cIdx 0 x * orCh x = cIdx 0 x := by
  unfold orCh
  have h := cIdx_zero_mul_norCh x
  nlinarith [h]

/-! ## Exact expectations -/

theorem E_andCh (p : ℝ) : E p (andCh (n := n)) = p ^ n := by
  have h := E_prod (n := n) p (fun _ b => if b then (1:ℝ) else 0)
  show E p (fun x => ∏ i, (if x i then (1:ℝ) else 0)) = p ^ n
  rw [h]; simp

theorem E_norCh (p : ℝ) : E p (norCh (n := n)) = (1 - p) ^ n := by
  have h := E_prod (n := n) p (fun _ b => if b then (0:ℝ) else 1)
  show E p (fun x => ∏ i, (if x i then (0:ℝ) else 1)) = (1 - p) ^ n
  rw [h]; simp

theorem E_orCh (p : ℝ) : E p (orCh (n := n)) = 1 - (1 - p) ^ n := by
  unfold orCh
  rw [E_sub p (fun _ => (1:ℝ)) norCh, E_one, E_norCh]

theorem E_pmCh (p : ℝ) : E p (pmCh (n := n)) = (1 - 2*p) ^ n := by
  have h := E_prod (n := n) p (fun _ b => if b then (-1:ℝ) else 1)
  show E p (fun x => ∏ i, (if x i then (-1:ℝ) else 1)) = (1 - 2*p) ^ n
  rw [h]
  norm_num; congr 1; ring

theorem E_xorCh (p : ℝ) : E p (xorCh (n := n)) = (1 - (1 - 2*p) ^ n) / 2 := by
  unfold xorCh
  rw [E_congr p (G := fun x => (2:ℝ)⁻¹ * (1 - pmCh x)) (fun x => by ring),
    E_const_mul, E_sub p (fun _ => (1:ℝ)) pmCh, E_one, E_pmCh]
  ring

theorem E_cIdx (p : ℝ) (i : Fin n) : E p (cIdx i) = p := by
  rw [E_congr p (G := fun x => ∏ j, (if j = i then (if x j then (1:ℝ) else 0) else 1))
      (fun x => cIdx_prod i x),
    E_prod p (fun j b => if j = i then (if b then (1:ℝ) else 0) else 1),
    Finset.prod_eq_single i (by intro b _ hb; simp [hb]) (by simp)]
  simp

theorem E_cIdx_mul_cIdx (p : ℝ) {i j : Fin n} (hij : i ≠ j) :
    E p (fun x => cIdx i x * cIdx j x) = p ^ 2 := by
  rw [E_congr p (G := fun x => ∏ k, (if k = i ∨ k = j then (if x k then (1:ℝ) else 0) else 1))
      (fun x => by
        rw [cIdx_prod i x, cIdx_prod j x, ← Finset.prod_mul_distrib]
        refine Finset.prod_congr rfl (fun k _ => ?_)
        by_cases hk : k = i <;> by_cases hk2 : k = j <;> simp_all),
    E_prod p (fun k b => if k = i ∨ k = j then (if b then (1:ℝ) else 0) else 1)]
  have hcongr : ∀ k : Fin n,
      ((p * if k = i ∨ k = j then (if true then (1:ℝ) else 0) else 1) +
        (1 - p) * if k = i ∨ k = j then (if false then (1:ℝ) else 0) else 1)
        = if k ∈ ({i, j} : Finset (Fin n)) then p else 1 := by
    intro k; by_cases h : k = i ∨ k = j <;> simp [h]
  rw [Finset.prod_congr rfl (fun k _ => hcongr k), Finset.prod_ite_mem]
  simp [Finset.prod_const, hij]

/-- The expectation of the coordinate-`0` indicator times the `±1` parity. -/
theorem E_cIdx_zero_mul_pmCh (p : ℝ) :
    E p (fun x : Fin (n+1) → Bool => cIdx 0 x * pmCh x) = -p * (1 - 2*p) ^ n := by
  rw [E_congr p (G := fun x : Fin (n+1) → Bool =>
        ∏ j, (if j = 0 then (if x j then (-1:ℝ) else 0) else (if x j then (-1:ℝ) else 1)))
      (fun x => by
        rw [cIdx_prod 0 x]
        unfold pmCh
        rw [← Finset.prod_mul_distrib]
        refine Finset.prod_congr rfl (fun k _ => ?_)
        by_cases hk : k = 0
        · subst hk; by_cases hx : x 0 <;> simp [hx]
        · by_cases hx : x k <;> simp [hk, hx]),
    E_prod p (fun j b => if j = 0 then (if b then (-1:ℝ) else 0) else (if b then (-1:ℝ) else 1))]
  have hcongr : ∀ k : Fin (n+1),
      ((p * if k = 0 then (if true then (-1:ℝ) else 0) else (if true then (-1:ℝ) else 1)) +
        (1 - p) * if k = 0 then (if false then (-1:ℝ) else 0) else (if false then (-1:ℝ) else 1))
        = if k = 0 then -p else 1 - 2*p := by
    intro k; by_cases h : k = 0 <;> simp [h]; ring
  rw [Finset.prod_congr rfl (fun k _ => hcongr k), Fin.prod_univ_succ]
  simp

theorem E_wCh (p : ℝ) : E p (wCh (n := n)) = n * p := by
  unfold wCh
  rw [E_sum p Finset.univ (fun i => cIdx i)]
  rw [Finset.sum_congr rfl (fun i (_ : i ∈ Finset.univ) => E_cIdx p i)]
  simp [mul_comm]

theorem E_cIdx_zero_mul_wCh (p : ℝ) :
    E p (fun x : Fin (n+1) → Bool => cIdx 0 x * wCh x) = p + n * p ^ 2 := by
  unfold wCh
  rw [E_congr p (G := fun x : Fin (n+1) → Bool => ∑ i, cIdx 0 x * cIdx i x)
      (fun x => by rw [Finset.mul_sum]),
    E_sum p Finset.univ (fun i => fun x : Fin (n+1) → Bool => cIdx 0 x * cIdx i x),
    ← Finset.sum_erase_add _ _ (Finset.mem_univ (0 : Fin (n+1)))]
  have h1 : ∀ i ∈ (Finset.univ : Finset (Fin (n+1))).erase 0,
      E p (fun x : Fin (n+1) → Bool => cIdx 0 x * cIdx i x) = p ^ 2 := by
    intro i hi
    exact E_cIdx_mul_cIdx p (Ne.symm (Finset.ne_of_mem_erase hi))
  rw [Finset.sum_congr rfl h1, Finset.sum_const,
    E_congr p (G := cIdx (0 : Fin (n+1))) (fun x => cIdx_mul_self 0 x), E_cIdx]
  have : ((Finset.univ : Finset (Fin (n+1))).erase 0).card = n := by
    rw [Finset.card_erase_of_mem (Finset.mem_univ _)]
    simp
  rw [this]
  ring

theorem E_wCh_mul_wCh (p : ℝ) :
    E p (fun x : Fin (n+1) → Bool => wCh x * wCh x) = (n+1) * (p + n * p ^ 2) := by
  unfold wCh
  rw [E_congr p (G := fun x : Fin (n+1) → Bool => ∑ i, ∑ j, cIdx i x * cIdx j x)
      (fun x => by rw [Finset.sum_mul_sum]),
    E_sum p Finset.univ (fun i => fun x : Fin (n+1) → Bool => ∑ j, cIdx i x * cIdx j x)]
  have key : ∀ i : Fin (n+1),
      E p (fun x : Fin (n+1) → Bool => ∑ j, cIdx i x * cIdx j x) = p + n * p ^ 2 := by
    intro i
    rw [E_sum p Finset.univ (fun j => fun x : Fin (n+1) → Bool => cIdx i x * cIdx j x),
      ← Finset.sum_erase_add _ _ (Finset.mem_univ i)]
    have h1 : ∀ j ∈ (Finset.univ : Finset (Fin (n+1))).erase i,
        E p (fun x : Fin (n+1) → Bool => cIdx i x * cIdx j x) = p ^ 2 := by
      intro j hj
      exact E_cIdx_mul_cIdx p (Ne.symm (Finset.ne_of_mem_erase hj))
    rw [Finset.sum_congr rfl h1, Finset.sum_const,
      E_congr p (G := cIdx i) (fun x => cIdx_mul_self i x), E_cIdx]
    have : ((Finset.univ : Finset (Fin (n+1))).erase i).card = n := by
      rw [Finset.card_erase_of_mem (Finset.mem_univ _)]
      simp
    rw [this]
    ring
  rw [Finset.sum_congr rfl (fun i (_ : i ∈ Finset.univ) => key i)]
  simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  push_cast
  ring

/-! ## Covariance, variance, and the leakage functional -/

/-- Covariance of two readouts. -/
noncomputable def Cov (p : ℝ) (F G : (Fin n → Bool) → ℝ) : ℝ :=
  E p (fun x => F x * G x) - E p F * E p G

/-- Variance of a readout. -/
noncomputable def Var (p : ℝ) (F : (Fin n → Bool) → ℝ) : ℝ := Cov p F F

/-- Squared Pearson correlation of two readouts. -/
noncomputable def corrSq (p : ℝ) (F G : (Fin n → Bool) → ℝ) : ℝ :=
  (Cov p F G) ^ 2 / (Var p F * Var p G)

/-- Leakage of a channel about the designated (`0`-th) input bit of an `(n+1)`-bit fork. -/
noncomputable def leak (p : ℝ) (F : (Fin (n+1) → Bool) → ℝ) : ℝ := corrSq p (cIdx 0) F

/-- The universal fork profile `Φ(t, n) = tⁿ / (1 + t + ⋯ + tⁿ)`. -/
noncomputable def Phi (t : ℝ) (n : ℕ) : ℝ := t ^ n / ∑ k ∈ Finset.range (n+1), t ^ k

/-- The `g` (OR) channel of an `(n+1)`-bit fork. -/
noncomputable def gChan (p : ℝ) (n : ℕ) : ℝ := leak p (orCh (n := n+1))

/-- The `A` (AND) channel of an `(n+1)`-bit fork. -/
noncomputable def aChan (p : ℝ) (n : ℕ) : ℝ := leak p (andCh (n := n+1))

/-- The `X` (XOR) channel of an `(n+1)`-bit fork. -/
noncomputable def xChan (p : ℝ) (n : ℕ) : ℝ := leak p (xorCh (n := n+1))

/-- The `Is` (split-count) channel of an `(n+1)`-bit fork. -/
noncomputable def isChan (p : ℝ) (n : ℕ) : ℝ := leak p (wCh (n := n+1))

/-! ### Basic variances -/

theorem Var_cIdx_zero (p : ℝ) : Var p (cIdx (0 : Fin (n+1))) = p * (1 - p) := by
  unfold Var Cov
  rw [E_congr p (G := cIdx (0 : Fin (n+1))) (fun x => cIdx_mul_self 0 x), E_cIdx]
  ring

theorem geom_identity (t : ℝ) (n : ℕ) :
    1 - t ^ (n+1) = (1 - t) * ∑ k ∈ Finset.range (n+1), t ^ k := by
  have h := geom_sum_mul t (n+1)
  nlinarith [h]

theorem geom_sum_pos {t : ℝ} (ht : 0 ≤ t) (n : ℕ) : 0 < ∑ k ∈ Finset.range (n+1), t ^ k := by
  have h0 : (0:ℝ) < t ^ 0 := by simp
  refine Finset.sum_pos' (fun k _ => pow_nonneg ht k) ⟨0, Finset.mem_range.mpr (Nat.succ_pos n), h0⟩

/-! ## The four exact channel formulas -/

theorem aChan_eq {p : ℝ} (hp : 0 < p) (hp1 : p < 1) (n : ℕ) : aChan p n = Phi p n := by
  have hq : 0 < 1 - p := by linarith
  have hS : 0 < ∑ k ∈ Finset.range (n+1), p ^ k := geom_sum_pos hp.le n
  have hcov : Cov p (cIdx (0 : Fin (n+1))) (andCh (n := n+1)) = p ^ (n+1) * (1 - p) := by
    unfold Cov
    rw [E_congr p (G := andCh (n := n+1)) (fun x => cIdx_zero_mul_andCh x), E_andCh, E_cIdx]
    ring
  have hvar : Var p (andCh (n := n+1)) = p ^ (n+1) * (1 - p ^ (n+1)) := by
    unfold Var Cov
    rw [E_congr p (G := andCh (n := n+1)) (fun x => andCh_mul_self x), E_andCh]
    ring
  unfold aChan leak corrSq Phi
  rw [hcov, hvar, Var_cIdx_zero, geom_identity p n]
  have hpn : (0:ℝ) < p ^ (n+1) := pow_pos hp _
  have hp0 : p ≠ 0 := ne_of_gt hp
  have hq0 : (1 - p) ≠ 0 := ne_of_gt hq
  have hS0 : (∑ k ∈ Finset.range (n+1), p ^ k) ≠ 0 := ne_of_gt hS
  field_simp
  ring

theorem gChan_eq {p : ℝ} (hp : 0 < p) (hp1 : p < 1) (n : ℕ) : gChan p n = Phi (1 - p) n := by
  have hq : 0 < 1 - p := by linarith
  have hS : 0 < ∑ k ∈ Finset.range (n+1), (1 - p) ^ k := geom_sum_pos hq.le n
  have hcov : Cov p (cIdx (0 : Fin (n+1))) (orCh (n := n+1)) = p * (1 - p) ^ (n+1) := by
    unfold Cov
    rw [E_congr p (G := cIdx (0 : Fin (n+1))) (fun x => cIdx_zero_mul_orCh x), E_orCh, E_cIdx]
    ring
  have hvar : Var p (orCh (n := n+1)) = (1 - (1 - p) ^ (n+1)) * (1 - p) ^ (n+1) := by
    unfold Var Cov
    rw [E_congr p (G := orCh (n := n+1)) (fun x => orCh_mul_self x), E_orCh]
    ring
  unfold gChan leak corrSq Phi
  rw [hcov, hvar, Var_cIdx_zero, geom_identity (1 - p) n, show (1:ℝ) - (1 - p) = p by ring]
  have hqn : (0:ℝ) < (1 - p) ^ (n+1) := pow_pos hq _
  have hp0 : p ≠ 0 := ne_of_gt hp
  have hq0 : (1 - p) ≠ 0 := ne_of_gt hq
  have hS0 : (∑ k ∈ Finset.range (n+1), (1 - p) ^ k) ≠ 0 := ne_of_gt hS
  field_simp
  ring

theorem xChan_eq {p : ℝ} (hp : 0 < p) (hp1 : p < 1) (n : ℕ) :
    xChan p n = Phi ((1 - 2*p) ^ 2) n := by
  have hq : 0 < 1 - p := by linarith
  have hd2 : (0:ℝ) ≤ (1 - 2*p) ^ 2 := sq_nonneg _
  have hS : 0 < ∑ k ∈ Finset.range (n+1), ((1 - 2*p) ^ 2) ^ k := geom_sum_pos hd2 n
  have hcov : Cov p (cIdx (0 : Fin (n+1))) (xorCh (n := n+1))
      = p * (1 - p) * (1 - 2*p) ^ n := by
    unfold Cov xorCh
    rw [E_congr p (G := fun x : Fin (n+1) → Bool => (2:ℝ)⁻¹ * (cIdx 0 x - cIdx 0 x * pmCh x))
        (fun x => by unfold cIdx; by_cases h : x 0 <;> simp [h]; ring), E_const_mul,
      E_sub p (cIdx (0 : Fin (n+1))) (fun x => cIdx 0 x * pmCh x),
      E_cIdx, E_cIdx_zero_mul_pmCh]
    rw [E_congr p (F := fun x : Fin (n+1) → Bool => (1 - pmCh x) / 2)
        (G := fun x : Fin (n+1) → Bool => (2:ℝ)⁻¹ * (1 - pmCh x)) (fun x => by ring),
      E_const_mul, E_sub p (fun _ => (1:ℝ)) pmCh, E_one, E_pmCh]
    ring
  have hd : ((1 - 2*p) ^ 2) ^ (n+1) = ((1 - 2*p) ^ (n+1)) ^ 2 := by
    rw [← pow_mul, ← pow_mul, Nat.mul_comm]
  have hdn : ((1 - 2*p) ^ 2) ^ n = ((1 - 2*p) ^ n) ^ 2 := by
    rw [← pow_mul, ← pow_mul, Nat.mul_comm]
  have hvar : Var p (xorCh (n := n+1)) = (1 - ((1 - 2*p) ^ 2) ^ (n+1)) / 4 := by
    unfold Var Cov
    rw [E_congr p (G := xorCh (n := n+1)) (fun x => xorCh_mul_self x), E_xorCh, hd]
    ring
  have h4pq : 1 - (1 - 2*p) ^ 2 = 4 * (p * (1 - p)) := by ring
  unfold xChan leak corrSq Phi
  rw [hcov, hvar, Var_cIdx_zero, geom_identity ((1 - 2*p) ^ 2) n, h4pq, hdn]
  have hp0 : p ≠ 0 := ne_of_gt hp
  have hq0 : (1 - p) ≠ 0 := ne_of_gt hq
  have hS0 : (∑ k ∈ Finset.range (n+1), ((1 - 2*p) ^ 2) ^ k) ≠ 0 := ne_of_gt hS
  field_simp

theorem isChan_eq {p : ℝ} (hp : 0 < p) (hp1 : p < 1) (n : ℕ) : isChan p n = Phi 1 n := by
  have hq : 0 < 1 - p := by linarith
  have hcov : Cov p (cIdx (0 : Fin (n+1))) (wCh (n := n+1)) = p * (1 - p) := by
    unfold Cov
    rw [E_cIdx_zero_mul_wCh, E_cIdx, E_wCh]
    push_cast
    ring
  have hvar : Var p (wCh (n := n+1)) = (n+1) * (p * (1 - p)) := by
    unfold Var Cov
    rw [E_wCh_mul_wCh, E_wCh]
    push_cast
    ring
  unfold isChan leak corrSq Phi
  rw [hcov, hvar, Var_cIdx_zero]
  have hpq : (0:ℝ) < p * (1 - p) := mul_pos hp hq
  have hn : (0:ℝ) < (n:ℝ) + 1 := by positivity
  simp only [one_pow, Finset.sum_const, Finset.card_range, nsmul_eq_mul, mul_one]
  field_simp
  push_cast
  ring

end ForkChannel