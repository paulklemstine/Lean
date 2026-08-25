import Mathlib

/-!
# A machine-verified `q`-expansion of the modular invariant `j`

The Monstrous-Moonshine head-character table records, for each of the `194`
conjugacy classes `g` of the Monster, the coefficient `c_g(1)` of `q` in the
McKay–Thompson series `T_g = q⁻¹ + 0 + c_g(1) q + ⋯`.  The entry for the
identity class `1A` is the coefficient of `q` in `j - 744`, i.e. the famous
`196884 = 196883 + 1` of McKay's observation.

This file *computes that entry from first principles inside Lean*, rather than
importing it as unverified data.  The route is purely formal-power-series
arithmetic over `ℤ`:

* `MoonshineJ.E4` is the Eisenstein series `E₄ = 1 + 240 ∑ σ₃(n) qⁿ`, defined by
  its divisor-sum coefficients;
* `MoonshineJ.deltaPart m = ∏_{k=1}^{m} (1 - q^k)^24` is the truncated
  eta-product, so that `Δ = q · deltaPart ∞`;
* `MoonshineJ.deltaPart_stable` proves that the coefficients of `deltaPart m`
  below degree `N` do **not** depend on `m` once `m ≥ N - 1`, which is what makes
  "the" eta product well defined without any convergence theory;
* `MoonshineJ.E4_cube_agree_delta_mul_j` proves
  `E₄³ ≡ deltaPart 7 · J  (mod q⁸)` with
  `J = 1 + 744 q + 196884 q² + 21493760 q³ + 864299970 q⁴ + ⋯`,
  which is exactly the statement `j = q⁻¹ + 744 + 196884 q + ⋯` since
  `j = E₄³/Δ` and `Δ = q · deltaPart`;
* `MoonshineJ.j_coefficients_unique` shows the tabulated coefficients are
  *forced*: any power series `f` with `E₄³ ≡ deltaPart m · f (mod q⁸)` has the
  same first eight coefficients, because `deltaPart m` is a unit of `ℤ⟦X⟧`;
* `MoonshineJ.j_head_coefficient` is the resulting head-table entry
  `c_{1A}(1) = 196884`, and `MoonshineJ.mckay_head_1A` is McKay's
  `196884 = 196883 + 1`.

As a by-product the same computation verifies the first eight values of the
Ramanujan tau function (`MoonshineJ.tau_values`).

## Method

Formal power series are not computable, so the arithmetic is done on *lists of
integers* (truncated series) with an explicit convolution product, and a small
congruence calculus `MoonshineJ.AgreeBelow N` (`≡ mod Xᴺ`) transfers the
list-level identity — discharged by the kernel with `decide` — to genuine
`PowerSeries ℤ` statements.  `MoonshineJ.agreeBelow_iff_dvd` identifies
`AgreeBelow N` with divisibility by `Xᴺ`, which makes the congruence calculus
(products, powers, cancellation by units) pure ideal theory.
-/

namespace MoonshineJ

open Finset PowerSeries

/-! ## 1. Truncated integer series, represented by lists -/

/-- Coefficient of a truncated series presented as a list (zero beyond the end). -/
def cf (a : List ℤ) (n : ℕ) : ℤ := a.getD n 0

lemma cf_map_range (f : ℕ → ℤ) {N n : ℕ} (h : n < N) :
    cf ((List.range N).map f) n = f n := by
  have h' : ((List.range N).map f)[n]? = some (f n) := by
    rw [List.getElem?_map, List.getElem?_range h]; rfl
  simp [cf, List.getD_eq_getElem?_getD, h']

/-- Cauchy convolution of two truncated series. -/
def convol (a b : List ℤ) (n : ℕ) : ℤ := ∑ k ∈ range (n + 1), cf a k * cf b (n - k)

/-- Product of two truncated series, kept to `N` terms. -/
def mulT (N : ℕ) (a b : List ℤ) : List ℤ := (List.range N).map (convol a b)

/-- The constant series `1`, kept to `N` terms. -/
def oneT (N : ℕ) : List ℤ := (List.range N).map (fun k => if k = 0 then 1 else 0)

/-- Powers of a truncated series. -/
def powT (N : ℕ) (a : List ℤ) : ℕ → List ℤ
  | 0 => oneT N
  | m + 1 => mulT N a (powT N a m)

/-- The truncated polynomial `1 - q^n`. -/
def etaAtom (N n : ℕ) : List ℤ :=
  (List.range N).map (fun k => if k = 0 then 1 else if k = n then -1 else 0)

/-- The truncated eta product `∏_{k=1}^{m} (1 - q^k)^24`. -/
def etaProd (N : ℕ) : ℕ → List ℤ
  | 0 => oneT N
  | m + 1 => mulT N (powT N (etaAtom N (m + 1)) 24) (etaProd N m)

/-- The truncated Eisenstein series `E₄ = 1 + 240 ∑ σ₃(n) qⁿ`. -/
def e4T (N : ℕ) : List ℤ :=
  (List.range N).map (fun n => if n = 0 then 1 else 240 * ((∑ d ∈ n.divisors, d ^ 3 : ℕ) : ℤ))

/-- The tabulated head of `q · j`, i.e. the coefficients `c(n-1)` of
`j = q⁻¹ + 744 + 196884 q + ⋯`. -/
def jT : List ℤ :=
  [1, 744, 196884, 21493760, 864299970, 20245856256, 333202640600, 4252023300096]

/-- The tabulated Ramanujan tau values `τ(1), …, τ(8)`. -/
def tauT : List ℤ := [1, -24, 252, -1472, 4830, -6048, -16744, 84480]

/-- The power series attached to a list of coefficients. -/
noncomputable def ser (a : List ℤ) : PowerSeries ℤ := PowerSeries.mk (cf a)

@[simp] lemma coeff_ser (a : List ℤ) (n : ℕ) : coeff n (ser a) = cf a n := coeff_mk _ _

/-! ## 2. The congruence calculus `≡ mod Xᴺ` -/

/-- `f` and `g` have the same coefficients in all degrees `< N`. -/
def AgreeBelow (N : ℕ) (f g : PowerSeries ℤ) : Prop := ∀ n < N, coeff n f = coeff n g

lemma agreeBelow_iff_dvd {N : ℕ} {f g : PowerSeries ℤ} :
    AgreeBelow N f g ↔ (X : PowerSeries ℤ) ^ N ∣ (f - g) := by
  rw [X_pow_dvd_iff]
  constructor
  · intro h n hn; simpa [sub_eq_zero] using h n hn
  · intro h n hn; have := h n hn; simpa [sub_eq_zero] using this

@[refl] lemma AgreeBelow.refl (N : ℕ) (f : PowerSeries ℤ) : AgreeBelow N f f := fun _ _ => rfl

lemma AgreeBelow.symm {N : ℕ} {f g : PowerSeries ℤ} (h : AgreeBelow N f g) :
    AgreeBelow N g f := fun n hn => (h n hn).symm

lemma AgreeBelow.trans {N : ℕ} {f g h : PowerSeries ℤ}
    (h₁ : AgreeBelow N f g) (h₂ : AgreeBelow N g h) : AgreeBelow N f h :=
  fun n hn => (h₁ n hn).trans (h₂ n hn)

lemma AgreeBelow.mul {N : ℕ} {f f' g g' : PowerSeries ℤ}
    (hf : AgreeBelow N f f') (hg : AgreeBelow N g g') : AgreeBelow N (f * g) (f' * g') := by
  rw [agreeBelow_iff_dvd] at hf hg ⊢
  have hsplit : f * g - f' * g' = f * (g - g') + g' * (f - f') := by ring
  rw [hsplit]
  exact dvd_add (hg.mul_left f) (hf.mul_left g')

lemma AgreeBelow.pow {N : ℕ} {f g : PowerSeries ℤ} (h : AgreeBelow N f g) :
    ∀ m : ℕ, AgreeBelow N (f ^ m) (g ^ m)
  | 0 => by simpa using AgreeBelow.refl N 1
  | m + 1 => by
      rw [pow_succ, pow_succ]
      exact (h.pow m).mul h

/-- Cancellation of a unit factor: the congruence calculus mod `Xᴺ` lives in the
quotient ring `ℤ⟦X⟧/(Xᴺ)`, where units cancel. -/
lemma AgreeBelow.cancel_left {N : ℕ} {u f g : PowerSeries ℤ} (hu : IsUnit u)
    (h : AgreeBelow N (u * f) (u * g)) : AgreeBelow N f g := by
  rw [agreeBelow_iff_dvd] at h ⊢
  obtain ⟨v, rfl⟩ := hu
  have hmul : (v : PowerSeries ℤ) * f - (v : PowerSeries ℤ) * g
      = (v : PowerSeries ℤ) * (f - g) := by ring
  rw [hmul] at h
  have hfg : f - g = ((v⁻¹ : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) *
      ((v : PowerSeries ℤ) * (f - g)) := by
    rw [← mul_assoc, ← Units.val_mul, inv_mul_cancel, Units.val_one, one_mul]
  rw [hfg]
  exact h.mul_left _

/-! ## 3. The list arithmetic computes power-series arithmetic -/

lemma coeff_ser_mul (a b : List ℤ) (n : ℕ) :
    coeff n (ser a * ser b) = convol a b n := by
  rw [coeff_mul, Finset.Nat.sum_antidiagonal_eq_sum_range_succ_mk]
  simp [convol]

lemma agree_mulT (N : ℕ) (a b : List ℤ) : AgreeBelow N (ser (mulT N a b)) (ser a * ser b) := by
  intro n hn
  rw [coeff_ser, coeff_ser_mul, mulT, cf_map_range _ hn]

lemma agree_oneT (N : ℕ) : AgreeBelow N (ser (oneT N)) 1 := by
  intro n hn
  rw [coeff_ser, oneT, cf_map_range _ hn, PowerSeries.coeff_one]

lemma agree_powT (N : ℕ) (a : List ℤ) : ∀ m : ℕ,
    AgreeBelow N (ser (powT N a m)) ((ser a) ^ m)
  | 0 => by simpa [powT] using agree_oneT N
  | m + 1 => by
      refine (agree_mulT N a (powT N a m)).trans ?_
      rw [pow_succ, mul_comm ((ser a) ^ m) (ser a)]
      exact (AgreeBelow.refl N (ser a)).mul (agree_powT N a m)

lemma agree_etaAtom (N n : ℕ) (hn : 0 < n) :
    AgreeBelow N (ser (etaAtom N n)) (1 - X ^ n) := by
  intro k hk
  rw [coeff_ser, etaAtom, cf_map_range _ hk, map_sub, PowerSeries.coeff_one,
    PowerSeries.coeff_X_pow]
  rcases eq_or_ne k 0 with rfl | hk0
  · have h0n : (0 : ℕ) ≠ n := hn.ne
    simp [h0n]
  · by_cases hkn : k = n
    · subst hkn; simp [hk0]
    · simp [hk0, hkn]

/-! ## 4. The eta product and the Eisenstein series -/

/-- The truncated eta product `∏_{k=1}^{m} (1 - q^k)^24`, as a genuine power
series.  `Δ = q · deltaPart ∞`. -/
noncomputable def deltaPart (m : ℕ) : PowerSeries ℤ := ∏ k ∈ Icc 1 m, (1 - X ^ k) ^ 24

lemma deltaPart_succ (m : ℕ) :
    deltaPart (m + 1) = deltaPart m * (1 - X ^ (m + 1)) ^ 24 := by
  rw [deltaPart, deltaPart, Finset.prod_Icc_succ_top (by omega)]

lemma agree_etaProd (N : ℕ) : ∀ m : ℕ, AgreeBelow N (ser (etaProd N m)) (deltaPart m)
  | 0 => by simpa [etaProd, deltaPart] using agree_oneT N
  | m + 1 => by
      refine (agree_mulT N _ _).trans ?_
      rw [deltaPart_succ, mul_comm (deltaPart m)]
      exact ((agree_powT N (etaAtom N (m + 1)) 24).trans
        ((agree_etaAtom N (m + 1) (by omega)).pow 24)).mul (agree_etaProd N m)

/-- The Eisenstein series `E₄ = 1 + 240 ∑_{n ≥ 1} σ₃(n) qⁿ`. -/
noncomputable def E4 : PowerSeries ℤ :=
  PowerSeries.mk (fun n => if n = 0 then 1 else 240 * ((∑ d ∈ n.divisors, d ^ 3 : ℕ) : ℤ))

lemma agree_e4T (N : ℕ) : AgreeBelow N (ser (e4T N)) E4 := by
  intro n hn
  rw [coeff_ser, e4T, cf_map_range _ hn, E4, coeff_mk]

/-- The tabulated head of `q · j`. -/
noncomputable def jSeries : PowerSeries ℤ := ser jT

/-! ## 5. Truncation stability: the eta product is well defined -/

/-- Beyond degree `k`, the factor `(1 - q^k)^24` is invisible. -/
lemma agree_etaFactor_one {N k : ℕ} (hk : N ≤ k) :
    AgreeBelow N ((1 - X ^ k) ^ 24) 1 := by
  rw [agreeBelow_iff_dvd]
  have hdvd : ((1 : PowerSeries ℤ) - X ^ k) - 1 ∣ (1 - X ^ k) ^ 24 - 1 ^ 24 :=
    sub_dvd_pow_sub_pow _ _ 24
  have hsimp : ((1 : PowerSeries ℤ) - X ^ k) - 1 = -(X ^ k) := by ring
  rw [hsimp, one_pow] at hdvd
  refine dvd_trans (pow_dvd_pow (X : PowerSeries ℤ) hk) (dvd_trans ?_ hdvd)
  exact (dvd_neg).mpr dvd_rfl

/-- Adding one more factor does not change the coefficients below degree `N`,
once the factor's exponent has passed `N`. -/
lemma deltaPart_succ_agree {N m : ℕ} (h : N ≤ m + 1) :
    AgreeBelow N (deltaPart (m + 1)) (deltaPart m) := by
  rw [deltaPart_succ]
  simpa using (AgreeBelow.refl N (deltaPart m)).mul (agree_etaFactor_one (k := m + 1) h)

/-- **Stability of the eta product.**  The coefficients of `∏_{k≤m}(1-q^k)^24`
in degrees `< N` are independent of the cut-off `m`, as soon as `m ≥ N - 1`.
This is what makes the infinite product well defined coefficientwise. -/
theorem deltaPart_agree_of_le {N : ℕ} : ∀ m : ℕ, N ≤ m + 1 →
    AgreeBelow N (deltaPart m) (deltaPart (N - 1))
  | 0, hm => by
      have h0 : N - 1 = 0 := by omega
      rw [h0]
  | (m + 1), hm => by
      rcases Nat.lt_or_ge N (m + 2) with hlt | hge
      · exact (deltaPart_succ_agree (by omega)).trans (deltaPart_agree_of_le m (by omega))
      · have hNm : N = m + 2 := by omega
        subst hNm
        have hm1 : m + 2 - 1 = m + 1 := by omega
        rw [hm1]

/-- Any two sufficiently long truncations of the eta product agree. -/
theorem deltaPart_stable {N m m' : ℕ} (h : N ≤ m + 1) (h' : N ≤ m' + 1) :
    AgreeBelow N (deltaPart m) (deltaPart m') :=
  (deltaPart_agree_of_le m h).trans (deltaPart_agree_of_le m' h').symm

/-- The eta product is a unit of `ℤ⟦X⟧`: its constant term is `1`. -/
lemma isUnit_deltaPart (m : ℕ) : IsUnit (deltaPart m) := by
  rw [PowerSeries.isUnit_iff_constantCoeff, deltaPart, map_prod]
  have : ∀ k ∈ Icc 1 m, constantCoeff ((1 - X ^ k) ^ 24) = (1 : ℤ) := by
    intro k hk
    have hk1 : 1 ≤ k := (Finset.mem_Icc.mp hk).1
    have hX : constantCoeff ((X : PowerSeries ℤ) ^ k) = 0 := by
      rw [map_pow, PowerSeries.constantCoeff_X, zero_pow (by omega)]
    rw [map_pow, map_sub, hX, map_one, sub_zero, one_pow]
  rw [Finset.prod_congr rfl this, Finset.prod_const_one]
  exact isUnit_one

/-! ## 6. The verified expansion -/

set_option maxRecDepth 40000 in
/-- The kernel-checked truncated identity `E₄³ = (∏(1-q^k)^24) · J` to eight
terms. -/
theorem list_identity :
    mulT 8 (mulT 8 (e4T 8) (e4T 8)) (e4T 8) = mulT 8 (etaProd 8 7) jT := by decide

set_option maxRecDepth 40000 in
/-- The kernel-checked truncated eta product, i.e. the first eight Ramanujan tau
values. -/
theorem list_tau : etaProd 8 7 = tauT := by decide

/-- **The `q`-expansion of `j`.**  Modulo `q⁸`,
`E₄³ = (∏_{k≥1}(1-q^k)^24) · (1 + 744q + 196884q² + 21493760q³ + ⋯)`.
Since `Δ = q · ∏(1-q^k)^24` and `j = E₄³/Δ`, this says
`j = q⁻¹ + 744 + 196884 q + 21493760 q² + ⋯`. -/
theorem E4_cube_agree_delta_mul_j : AgreeBelow 8 (E4 ^ 3) (deltaPart 7 * jSeries) := by
  have hE : AgreeBelow 8 (ser (mulT 8 (mulT 8 (e4T 8) (e4T 8)) (e4T 8))) (E4 ^ 3) := by
    refine ((agree_mulT 8 _ _).trans (((agree_mulT 8 _ _).trans
      ((agree_e4T 8).mul (agree_e4T 8))).mul (agree_e4T 8))).trans ?_
    rw [pow_succ, pow_two]
  have hD : AgreeBelow 8 (ser (mulT 8 (etaProd 8 7) jT)) (deltaPart 7 * jSeries) :=
    (agree_mulT 8 _ _).trans ((agree_etaProd 8 7).mul (AgreeBelow.refl 8 jSeries))
  rw [list_identity] at hE
  exact hE.symm.trans hD

/-- **Rigidity of the tabulated coefficients.**  Any power series whose product
with the eta product reproduces `E₄³` modulo `q⁸` has exactly the tabulated
coefficients.  (The cut-off `m ≥ 7` is immaterial by `deltaPart_stable`.) -/
theorem j_coefficients_unique (f : PowerSeries ℤ) {m : ℕ} (hm : 7 ≤ m)
    (hf : AgreeBelow 8 (E4 ^ 3) (deltaPart m * f)) : AgreeBelow 8 f jSeries := by
  have hstab : AgreeBelow 8 (deltaPart m * jSeries) (deltaPart 7 * jSeries) :=
    (deltaPart_stable (by omega) (by omega)).mul (AgreeBelow.refl 8 jSeries)
  exact AgreeBelow.cancel_left (isUnit_deltaPart m)
    (hf.symm.trans (E4_cube_agree_delta_mul_j.trans hstab.symm))

/-! ## 7. The head-table entry for the identity class -/

@[simp] lemma coeff_jSeries (n : ℕ) : coeff n jSeries = cf jT n := coeff_ser _ _

/-- **The `1A` entry of the Monstrous-Moonshine head table.**  The coefficient of
`q` in `j - 744` is `196884`, and it is forced by the power-series identity
`E₄³ = Δ · j` alone. -/
theorem j_head_coefficient (f : PowerSeries ℤ) {m : ℕ} (hm : 7 ≤ m)
    (hf : AgreeBelow 8 (E4 ^ 3) (deltaPart m * f)) : coeff 2 f = 196884 := by
  have h2 := j_coefficients_unique f hm hf 2 (by norm_num)
  rw [h2, coeff_jSeries]
  decide

/-- The constant term of `j` is `744`. -/
theorem j_constant_term (f : PowerSeries ℤ) {m : ℕ} (hm : 7 ≤ m)
    (hf : AgreeBelow 8 (E4 ^ 3) (deltaPart m * f)) : coeff 1 f = 744 := by
  have h1 := j_coefficients_unique f hm hf 1 (by norm_num)
  rw [h1, coeff_jSeries]
  decide

/-- The next three coefficients of `j`. -/
theorem j_next_coefficients (f : PowerSeries ℤ) {m : ℕ} (hm : 7 ≤ m)
    (hf : AgreeBelow 8 (E4 ^ 3) (deltaPart m * f)) :
    coeff 3 f = 21493760 ∧ coeff 4 f = 864299970 ∧ coeff 5 f = 20245856256 := by
  refine ⟨?_, ?_, ?_⟩
  · rw [j_coefficients_unique f hm hf 3 (by norm_num), coeff_jSeries]; decide
  · rw [j_coefficients_unique f hm hf 4 (by norm_num), coeff_jSeries]; decide
  · rw [j_coefficients_unique f hm hf 5 (by norm_num), coeff_jSeries]; decide

/-- **Ramanujan tau values.**  The verified eta product yields
`τ(1), …, τ(8) = 1, -24, 252, -1472, 4830, -6048, -16744, 84480`. -/
theorem tau_values {m : ℕ} (hm : 7 ≤ m) (n : ℕ) (hn : n < 8) :
    coeff n (deltaPart m) = cf tauT n := by
  have h1 : AgreeBelow 8 (deltaPart m) (deltaPart 7) := deltaPart_stable (by omega) (by omega)
  have h2 : AgreeBelow 8 (ser (etaProd 8 7)) (deltaPart 7) := agree_etaProd 8 7
  rw [h1 n hn, ← h2 n hn, coeff_ser, list_tau]

/-! ## 8. McKay's observation, on verified numbers

The dimensions of the smallest irreducible representations of the Monster are
`1`, `196883`, `21296876`, `842609326`, `19360062527`, `293553734298`.  The
following identities exhibit the verified `j`-coefficients as non-negative
integral combinations of them — the numerical shadow of the graded Monster
module `V♮`. -/

/-- McKay's observation for the head coefficient: `c(1) = 196884 = 1 + 196883`. -/
theorem mckay_head_1A : cf jT 2 = 1 + 196883 := by decide

/-- `c(2) = 21493760 = 1 + 196883 + 21296876`. -/
theorem mckay_level_2 : cf jT 3 = 1 + 196883 + 21296876 := by decide

/-- `c(3) = 864299970 = 2·1 + 2·196883 + 21296876 + 842609326`. -/
theorem mckay_level_3 : cf jT 4 = 2 * 1 + 2 * 196883 + 21296876 + 842609326 := by decide

/-- `c(4) = 20245856256 = 2·1 + 3·196883 + 2·21296876 + 842609326 + 19360062527`. -/
theorem mckay_level_4 :
    cf jT 5 = 2 * 1 + 3 * 196883 + 2 * 21296876 + 842609326 + 19360062527 := by decide

/-- `c(5) = 333202640600
        = 3·1 + 5·196883 + 4·21296876 + 842609326 + 2·19360062527 + 293553734298`. -/
theorem mckay_level_5 :
    cf jT 6 = 3 * 1 + 5 * 196883 + 4 * 21296876 + 842609326 + 2 * 19360062527
      + 293553734298 := by decide

end MoonshineJ