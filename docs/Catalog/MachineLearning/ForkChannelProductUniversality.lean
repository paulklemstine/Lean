import MachineLearning.ForkChannelTableClosure

/-!
# Profile universality for product readouts of a fork

`MachineLearning.ForkChannelCorrelation` computed the four fork channels
(`A` = AND, `g` = OR, `X` = XOR, `Is` = split count) of an `(n+1)`-bit
Bernoulli(`p`) fork and found that all four are values of one rational profile

`Φ(t, n) = tⁿ / (1 + t + ⋯ + tⁿ)`.

This file proves that this is **not a coincidence of the four examples**: it is
forced for *every* coordinatewise-product readout

`prodCh c (x) = ∏ᵢ c (xᵢ)`, `c : Bool → ℝ`,

and the parameter is read off the two moments of the single coordinate function

`m = E c = p·c(true) + (1-p)·c(false)`,  `s = E c² = p·c(true)² + (1-p)·c(false)²`,

namely `t = m² / s` (`leak_prodCh`).  Since `s - m² = p(1-p)(c(true) - c(false))²`
is strictly positive whenever the coordinate function is non-constant, the
parameter of a product readout is always `< 1` (`prodCh_param_lt_one`), while the
split-count (additive, non-product) channel sits exactly at `t = 1`.  So the
terminal profile is unreachable by product readouts, which upgrades the `H1`
domination `Is ≥ max(g, A, X)` to a *strict* inequality valid for the whole
product class (`leak_prodCh_lt_isChan`), and gives `H2` for the whole class
(`leak_prodCh_tendsto_zero`).

Two further structural consequences:

* **Affine invariance** (`leak_affine`): leakage only depends on the readout up to
  an invertible affine change `F ↦ αF + β`.  This is why the OR channel has the
  same leakage as NOR, and the `{0,1}`-valued XOR the same as the `±1` parity;
  the three Boolean channels are recovered from the universality theorem in
  `aChan_eq_of_universality`, `gChan_eq_of_universality`, `xChan_eq_of_universality`.
* **Ordering rigidity for the product class** (`leak_prodCh_le_iff`): two product
  readouts compare, at every fork size `≥ 2`, exactly as their parameters compare.
  In particular no pair of product readouts can exhibit a size-dependent
  crossover — the `n = 8` crossover is impossible not only for AND vs XOR but for
  any two product readouts.
-/

open Filter Topology

namespace ForkChannel

variable {n : ℕ} {p : ℝ}

/-! ## Product readouts and their coordinate moments -/

/-- The coordinatewise-product readout attached to a coordinate function `c`. -/
def prodCh (c : Bool → ℝ) (x : Fin n → Bool) : ℝ := ∏ i, c (x i)

/-- First moment of the coordinate function under `Bernoulli p`. -/
def mom1 (p : ℝ) (c : Bool → ℝ) : ℝ := p * c true + (1 - p) * c false

/-- Second moment of the coordinate function under `Bernoulli p`. -/
def mom2 (p : ℝ) (c : Bool → ℝ) : ℝ := p * (c true) ^ 2 + (1 - p) * (c false) ^ 2

/-- The channel parameter of a product readout: the squared first moment over the
second moment of its coordinate function. -/
noncomputable def prodParam (p : ℝ) (c : Bool → ℝ) : ℝ := (mom1 p c) ^ 2 / mom2 p c

/-- The variance identity for the coordinate function: `E c² - (E c)² = p(1-p)Δ²`. -/
theorem mom2_sub_mom1_sq (p : ℝ) (c : Bool → ℝ) :
    mom2 p c - (mom1 p c) ^ 2 = p * (1 - p) * (c true - c false) ^ 2 := by
  unfold mom1 mom2; ring

theorem mom1_sq_lt_mom2 (hp : 0 < p) (hp1 : p < 1) {c : Bool → ℝ} (hc : c true ≠ c false) :
    (mom1 p c) ^ 2 < mom2 p c := by
  have hd : c true - c false ≠ 0 := sub_ne_zero.mpr hc
  have hd2 : 0 < (c true - c false) ^ 2 := lt_of_le_of_ne (sq_nonneg _) (Ne.symm (pow_ne_zero 2 hd))
  have hq : 0 < 1 - p := by linarith
  have h := mom2_sub_mom1_sq p c
  nlinarith [mul_pos (mul_pos hp hq) hd2]

theorem mom2_pos (hp : 0 < p) (hp1 : p < 1) {c : Bool → ℝ} (hc : c true ≠ c false) :
    0 < mom2 p c :=
  lt_of_le_of_lt (sq_nonneg (mom1 p c)) (mom1_sq_lt_mom2 hp hp1 hc)

/-- A product readout can never reach the terminal parameter `1`. -/
theorem prodCh_param_lt_one (hp : 0 < p) (hp1 : p < 1) {c : Bool → ℝ} (hc : c true ≠ c false) :
    prodParam p c < 1 :=
  (div_lt_one (mom2_pos hp hp1 hc)).mpr (mom1_sq_lt_mom2 hp hp1 hc)

theorem prodCh_param_nonneg (hp : 0 < p) (hp1 : p < 1) {c : Bool → ℝ} (hc : c true ≠ c false) :
    0 ≤ prodParam p c :=
  div_nonneg (sq_nonneg _) (mom2_pos hp hp1 hc).le

/-! ## Exact expectations of a product readout -/

theorem E_prodCh (p : ℝ) (c : Bool → ℝ) :
    E p (prodCh c : (Fin n → Bool) → ℝ) = (mom1 p c) ^ n := by
  have h := E_prod (n := n) p (fun _ => c)
  show E p (fun x => ∏ i, c (x i)) = _
  rw [h]
  simp [mom1]

theorem prodCh_mul_self (c : Bool → ℝ) (x : Fin n → Bool) :
    prodCh c x * prodCh c x = prodCh (fun b => c b * c b) x := by
  unfold prodCh; rw [← Finset.prod_mul_distrib]

theorem E_prodCh_sq (p : ℝ) (c : Bool → ℝ) :
    E p (fun x : Fin n → Bool => prodCh c x * prodCh c x) = (mom2 p c) ^ n := by
  rw [E_congr p (fun x => prodCh_mul_self c x), E_prodCh]
  congr 1
  simp only [mom1, mom2]
  ring

theorem cIdx_zero_mul_prodCh (c : Bool → ℝ) (x : Fin (n+1) → Bool) :
    cIdx 0 x * prodCh c x
      = ∏ i, (if i = 0 then (if x i then c true else 0) else c (x i)) := by
  rw [cIdx_prod 0 x]
  unfold prodCh
  rw [← Finset.prod_mul_distrib]
  refine Finset.prod_congr rfl (fun k _ => ?_)
  by_cases hk : k = 0
  · subst hk; by_cases hx : x 0 <;> simp [hx]
  · by_cases hx : x k <;> simp [hk, hx]

theorem E_cIdx_zero_mul_prodCh (p : ℝ) (c : Bool → ℝ) :
    E p (fun x : Fin (n+1) → Bool => cIdx 0 x * prodCh c x)
      = p * c true * (mom1 p c) ^ n := by
  rw [E_congr p (fun x => cIdx_zero_mul_prodCh c x),
    E_prod p (fun i b => if i = 0 then (if b then c true else 0) else c b)]
  have hcongr : ∀ k : Fin (n+1),
      ((p * if k = 0 then (if true then c true else 0) else c true) +
        (1 - p) * if k = 0 then (if false then c true else 0) else c false)
        = if k = 0 then p * c true else mom1 p c := by
    intro k; by_cases h : k = 0 <;> simp [h, mom1]
  rw [Finset.prod_congr rfl (fun k _ => hcongr k), Fin.prod_univ_succ]
  simp

/-! ## Covariance and variance of a product readout -/

theorem Cov_cIdx_zero_prodCh (p : ℝ) (c : Bool → ℝ) :
    Cov p (cIdx (0 : Fin (n+1))) (prodCh c)
      = p * (1 - p) * (c true - c false) * (mom1 p c) ^ n := by
  unfold Cov
  rw [E_cIdx_zero_mul_prodCh, E_cIdx, E_prodCh, pow_succ]
  simp only [mom1]
  ring

theorem Var_prodCh (p : ℝ) (c : Bool → ℝ) :
    Var p (prodCh c : (Fin (n+1) → Bool) → ℝ)
      = (mom2 p c) ^ (n+1) - ((mom1 p c) ^ 2) ^ (n+1) := by
  unfold Var Cov
  rw [E_prodCh_sq, E_prodCh, ← pow_mul, Nat.mul_comm, pow_mul]
  ring

/-! ## The universality theorem -/

/-- **Profile universality.**  For every non-constant coordinate function `c`, the
leakage of the product readout `∏ᵢ c(xᵢ)` about a single input bit of an
`(n+1)`-bit Bernoulli(`p`) fork is the universal profile `Φ` evaluated at the
parameter `m²/s` built from the two coordinate moments. -/
theorem leak_prodCh (hp : 0 < p) (hp1 : p < 1) {c : Bool → ℝ} (hc : c true ≠ c false) (n : ℕ) :
    leak p (prodCh c : (Fin (n+1) → Bool) → ℝ) = Phi (prodParam p c) n := by
  have hq : 0 < 1 - p := by linarith
  have hd : c true - c false ≠ 0 := sub_ne_zero.mpr hc
  have hd2 : 0 < (c true - c false) ^ 2 := lt_of_le_of_ne (sq_nonneg _) (Ne.symm (pow_ne_zero 2 hd))
  have hs : 0 < mom2 p c := mom2_pos hp hp1 hc
  have hlt : (mom1 p c) ^ 2 < mom2 p c := mom1_sq_lt_mom2 hp hp1 hc
  have hkey : (0:ℝ) < (mom2 p c) ^ (n+1) - ((mom1 p c) ^ 2) ^ (n+1) := by
    have : ((mom1 p c) ^ 2) ^ (n+1) < (mom2 p c) ^ (n+1) :=
      pow_lt_pow_left₀ hlt (sq_nonneg _) (Nat.succ_ne_zero n)
    linarith
  have hsm : mom2 p c - (mom1 p c) ^ 2 = p * (1 - p) * (c true - c false) ^ 2 :=
    mom2_sub_mom1_sq p c
  have hpow : ((mom1 p c) ^ 2) ^ n = ((mom1 p c) ^ n) ^ 2 := by
    rw [← pow_mul, Nat.mul_comm, pow_mul]
  rw [prodParam, Phi_rat (sq_nonneg _) hlt n, hsm, hpow]
  unfold leak corrSq
  rw [Cov_cIdx_zero_prodCh, Var_prodCh, Var_cIdx_zero]
  rw [div_eq_div_iff (by positivity) hkey.ne']
  ring

/-! ## Consequences for the whole product class -/

/-- **H1, strict, for the whole product class**: every product readout leaks
strictly less about a single bit than the split-count channel. -/
theorem leak_prodCh_lt_isChan (hp : 0 < p) (hp1 : p < 1) {c : Bool → ℝ} (hc : c true ≠ c false)
    {n : ℕ} (hn : 1 ≤ n) :
    leak p (prodCh c : (Fin (n+1) → Bool) → ℝ) < isChan p n := by
  rw [leak_prodCh hp hp1 hc n, isChan_eq hp hp1 n]
  exact Phi_strictMono (prodCh_param_nonneg hp hp1 hc) (prodCh_param_lt_one hp hp1 hc) hn

/-- **H2 for the whole product class**: the leakage of any product readout tends to
`0` as the fork grows. -/
theorem leak_prodCh_tendsto_zero (hp : 0 < p) (hp1 : p < 1) {c : Bool → ℝ}
    (hc : c true ≠ c false) :
    Tendsto (fun n : ℕ => leak p (prodCh c : (Fin (n+1) → Bool) → ℝ)) atTop (𝓝 0) := by
  have h : (fun n : ℕ => leak p (prodCh c : (Fin (n+1) → Bool) → ℝ))
      = fun n : ℕ => Phi (prodParam p c) n := funext (fun n => leak_prodCh hp hp1 hc n)
  rw [h]
  exact Phi_tendsto_zero (prodCh_param_nonneg hp hp1 hc) (prodCh_param_lt_one hp hp1 hc).le

/-- **Ordering rigidity inside the product class**: two product readouts compare
exactly as their parameters do, at every fork size — hence no size-dependent
crossover is possible between any two product readouts. -/
theorem leak_prodCh_le_iff (hp : 0 < p) (hp1 : p < 1) {c d : Bool → ℝ}
    (hc : c true ≠ c false) (hd : d true ≠ d false) {n : ℕ} (hn : 1 ≤ n) :
    leak p (prodCh c : (Fin (n+1) → Bool) → ℝ) ≤ leak p (prodCh d : (Fin (n+1) → Bool) → ℝ)
      ↔ prodParam p c ≤ prodParam p d := by
  rw [leak_prodCh hp hp1 hc n, leak_prodCh hp hp1 hd n]
  exact Phi_le_iff (prodCh_param_nonneg hp hp1 hc) (prodCh_param_nonneg hp hp1 hd) hn

/-- No two product readouts can swap their order between two fork sizes. -/
theorem prodCh_crossover_free (hp : 0 < p) (hp1 : p < 1) {c d : Bool → ℝ}
    (hc : c true ≠ c false) (hd : d true ≠ d false) {m n : ℕ} (hm : 1 ≤ m) (hn : 1 ≤ n)
    (hmle : leak p (prodCh c : (Fin (m+1) → Bool) → ℝ)
      ≤ leak p (prodCh d : (Fin (m+1) → Bool) → ℝ)) :
    leak p (prodCh c : (Fin (n+1) → Bool) → ℝ)
      ≤ leak p (prodCh d : (Fin (n+1) → Bool) → ℝ) :=
  (leak_prodCh_le_iff hp hp1 hc hd hn).mpr ((leak_prodCh_le_iff hp hp1 hc hd hm).mp hmle)

/-! ## Affine invariance of leakage -/

theorem E_const (p β : ℝ) : E p (fun _ : Fin n → Bool => β) = β := by
  rw [E_congr p (G := fun _ : Fin n → Bool => β * (1:ℝ)) (fun _ => by ring), E_const_mul, E_one]
  ring

theorem E_affine (p α β : ℝ) (G : (Fin n → Bool) → ℝ) :
    E p (fun x => α * G x + β) = α * E p G + β := by
  rw [E_add p (fun x => α * G x) (fun _ => β), E_const_mul, E_const]

theorem Cov_affine_right (p α β : ℝ) (F G : (Fin n → Bool) → ℝ) :
    Cov p F (fun x => α * G x + β) = α * Cov p F G := by
  unfold Cov
  rw [E_congr p (F := fun x => F x * (α * G x + β))
      (G := fun x => α * (F x * G x) + β * F x) (fun x => by ring),
    E_add p (fun x => α * (F x * G x)) (fun x => β * F x), E_const_mul, E_const_mul,
    E_affine]
  ring

theorem Var_affine (p α β : ℝ) (G : (Fin n → Bool) → ℝ) :
    Var p (fun x => α * G x + β) = α ^ 2 * Var p G := by
  unfold Var
  rw [Cov_affine_right]
  unfold Cov
  rw [E_congr p (F := fun x => (α * G x + β) * G x)
      (G := fun x => α * (G x * G x) + β * G x) (fun x => by ring),
    E_add p (fun x => α * (G x * G x)) (fun x => β * G x), E_const_mul, E_const_mul,
    E_affine]
  ring

/-- Leakage is invariant under an invertible affine rescaling of the readout. -/
theorem leak_affine (p : ℝ) {α : ℝ} (β : ℝ) (hα : α ≠ 0) (F : (Fin (n+1) → Bool) → ℝ) :
    leak p (fun x => α * F x + β) = leak p F := by
  unfold leak corrSq
  rw [Cov_affine_right, Var_affine, mul_pow, mul_left_comm,
    mul_div_mul_left _ _ (pow_ne_zero 2 hα)]

/-! ## The three Boolean channels, re-derived from universality -/

theorem andCh_eq_prodCh (x : Fin n → Bool) :
    andCh x = prodCh (fun b => if b then (1:ℝ) else 0) x := rfl

theorem norCh_eq_prodCh (x : Fin n → Bool) :
    norCh x = prodCh (fun b => if b then (0:ℝ) else 1) x := rfl

theorem pmCh_eq_prodCh (x : Fin n → Bool) :
    pmCh x = prodCh (fun b => if b then (-1:ℝ) else 1) x := rfl

/-- The AND channel is the product readout at parameter `p`. -/
theorem aChan_eq_of_universality (hp : 0 < p) (hp1 : p < 1) (n : ℕ) : aChan p n = Phi p n := by
  have hc : ((fun b => if b then (1:ℝ) else 0) : Bool → ℝ) true
      ≠ ((fun b => if b then (1:ℝ) else 0) : Bool → ℝ) false := by norm_num
  have hpar : prodParam p (fun b => if b then (1:ℝ) else 0) = p := by
    unfold prodParam mom1 mom2
    norm_num
    rw [pow_two, mul_div_assoc, div_self hp.ne', mul_one]
  unfold aChan
  rw [show (andCh : (Fin (n+1) → Bool) → ℝ)
      = prodCh (fun b => if b then (1:ℝ) else 0) from funext (fun x => andCh_eq_prodCh x),
    leak_prodCh hp hp1 hc n, hpar]

/-- The OR channel is the product readout (NOR, up to an affine change) at parameter `1 - p`. -/
theorem gChan_eq_of_universality (hp : 0 < p) (hp1 : p < 1) (n : ℕ) :
    gChan p n = Phi (1 - p) n := by
  have hc : ((fun b => if b then (0:ℝ) else 1) : Bool → ℝ) true
      ≠ ((fun b => if b then (0:ℝ) else 1) : Bool → ℝ) false := by norm_num
  have hq : (1:ℝ) - p ≠ 0 := by linarith
  have hpar : prodParam p (fun b => if b then (0:ℝ) else 1) = 1 - p := by
    unfold prodParam mom1 mom2
    norm_num
    rw [pow_two, mul_div_assoc, div_self hq, mul_one]
  have hor : (orCh : (Fin (n+1) → Bool) → ℝ)
      = fun x => (-1 : ℝ) * prodCh (fun b => if b then (0:ℝ) else 1) x + 1 := by
    funext x; unfold orCh; rw [norCh_eq_prodCh]; ring
  unfold gChan
  rw [hor, leak_affine p 1 (by norm_num) (prodCh (fun b => if b then (0:ℝ) else 1)),
    leak_prodCh hp hp1 hc n, hpar]

/-- The XOR channel is the parity product readout (up to an affine change) at
parameter `(1 - 2p)²`. -/
theorem xChan_eq_of_universality (hp : 0 < p) (hp1 : p < 1) (n : ℕ) :
    xChan p n = Phi ((1 - 2*p) ^ 2) n := by
  have hc : ((fun b => if b then (-1:ℝ) else 1) : Bool → ℝ) true
      ≠ ((fun b => if b then (-1:ℝ) else 1) : Bool → ℝ) false := by norm_num
  have hpar : prodParam p (fun b => if b then (-1:ℝ) else 1) = (1 - 2*p) ^ 2 := by
    unfold prodParam mom1 mom2
    norm_num
    ring
  have hxor : (xorCh : (Fin (n+1) → Bool) → ℝ)
      = fun x => (-(1:ℝ)/2) * prodCh (fun b => if b then (-1:ℝ) else 1) x + 1/2 := by
    funext x; unfold xorCh; rw [pmCh_eq_prodCh]; ring
  unfold xChan
  rw [hxor, leak_affine p (1/2) (by norm_num) (prodCh (fun b => if b then (-1:ℝ) else 1)),
    leak_prodCh hp hp1 hc n, hpar]

end ForkChannel