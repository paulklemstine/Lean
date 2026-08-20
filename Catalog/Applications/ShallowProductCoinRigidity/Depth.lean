/-
Copyright (c) 2026. Released under the Apache 2.0 license.
-/
import Catalog.Applications.ShallowProductCoinRigidity.Core

/-!
# Rigidity gap at fixed depth `n`

A **product coin of depth `n`** on the word space `∀ i : ι, α i` (with
`|ι| = n` registers) is the fully unentangled state

`ψ_f (x) = ∏ i, f i (x i)`,   each `f i` an `ℓ²`-normalised coin.

Its **resonance amplitude** against a resonance set `R` of words is
`A(ψ) = ∑ x ∈ R, ψ x`.

The main result (`depthProdCoin_sq_gap`) transports the bipartite gap of
`Core.lean` along the splitting `∀ i, α i ≃ α i₀ × (∀ j ≠ i₀, α j)`:

> If `R` fails to be a box **along a single register `i₀`** — i.e. there are
> `x, y ∈ R` whose hybrid `Function.update y i₀ (x i₀)` is not in `R` — then for
> every product coin of any depth
> `‖A(ψ)‖² ≤ (1 - 1/(4|R|+1))·|R|`, equivalently `‖A(ψ)‖² ≤ |R| - 2/9`.

The gap is **uniform in the depth `n`** and in the register sizes: it depends
only on `|R|`.  Consequently no shallow (register-wise) coin ever attains the
Cauchy–Schwarz optimum for a resonance set that genuinely couples two
registers; the optimum requires a coin that already "knows" the coupling.

Two concrete families are then treated:

* `agreementSet` — the words whose first two registers agree.  For every depth
  `n ≥ 2` this set is non-box along register `i₀`, so all product coins lose at
  least `2/9` (`agreementSet_gap`).
* the two-point diagonal in `Bool × Bool`, where a sharp hand computation shows
  the true optimum is `1`, versus the trivial bound `|R| = 2`
  (`diag_sq_le_one`).  This certifies that the deficiency in the main theorem is
  real and quantifies how far the universal constant is from optimal.
-/

open Finset

namespace ShallowProductCoin

section Depth

variable {ι : Type*} [Fintype ι] [DecidableEq ι] {α : ι → Type*}
  [∀ i, Fintype (α i)] [∀ i, DecidableEq (α i)]

/-- The product (depth-`n`, fully unentangled) coin built from register coins
`f i`. -/
def prodCoin (f : ∀ i, α i → ℂ) : (∀ i, α i) → ℂ := fun x => ∏ i, f i (x i)

/-- Resonance amplitude of an arbitrary word-space state against `R`. -/
noncomputable def amp (R : Finset (∀ i, α i)) (psi : (∀ i, α i) → ℂ) : ℂ := ∑ x ∈ R, psi x

/-- `R` is **non-box along the register `i₀`**: some hybrid of two of its
elements, obtained by importing the `i₀`-letter of `x` into `y`, escapes `R`. -/
def NonBoxAt (R : Finset (∀ i, α i)) (i₀ : ι) : Prop :=
  ∃ x ∈ R, ∃ y ∈ R, Function.update y i₀ (x i₀) ∉ R

/-- The tail coin obtained from the registers other than `i₀`. -/
noncomputable def tailCoin (f : ∀ i, α i → ℂ) (i₀ : ι) :
    (∀ j : {j : ι // j ≠ i₀}, α j) → ℂ := fun b => ∏ j : {j : ι // j ≠ i₀}, f j (b j)

omit [∀ i, Fintype (α i)] [∀ i, DecidableEq (α i)] in
/-- Splitting a depth-`n` product coin at one register. -/
theorem prodCoin_split (f : ∀ i, α i → ℂ) (i₀ : ι) (x : ∀ i, α i) :
    prodCoin f x = f i₀ (x i₀) * tailCoin f i₀ (fun j => x j) := by
  unfold prodCoin tailCoin
  rw [Fintype.prod_eq_mul_prod_compl i₀ (fun i => f i (x i))]
  congr 1
  exact Finset.prod_subtype ({i₀}ᶜ) (fun j => by simp) (fun j => f j (x j))

omit [∀ i, DecidableEq (α i)] in
/-- The tail of a family of coins is a coin. -/
theorem tailCoin_isCoin (f : ∀ i, α i → ℂ) (hf : ∀ i, IsCoin (f i)) (i₀ : ι) :
    IsCoin (tailCoin f i₀) := by
  classical
  show ∑ b : (∀ j : {j : ι // j ≠ i₀}, α j), ‖tailCoin f i₀ b‖ ^ 2 = 1
  have hnorm : ∀ b : (∀ j : {j : ι // j ≠ i₀}, α j),
      ‖tailCoin f i₀ b‖ ^ 2 = ∏ j : {j : ι // j ≠ i₀}, ‖f j (b j)‖ ^ 2 := by
    intro b
    unfold tailCoin
    rw [norm_prod, ← Finset.prod_pow]
  rw [Finset.sum_congr rfl fun b _ => hnorm b]
  have hkey := Finset.prod_univ_sum (ι := {j : ι // j ≠ i₀}) (κ := fun j => α j)
    (fun _ => (Finset.univ : Finset (α _))) (fun j a => ‖f j a‖ ^ 2)
  rw [Fintype.piFinset_univ] at hkey
  rw [← hkey]
  exact Finset.prod_eq_one fun j _ => hf j

/-- **Depth-`n` rigidity gap.**  If the resonance set is not a box along some
register `i₀`, then every product coin of that depth misses the Cauchy–Schwarz
optimum by an explicit factor depending only on `|R|`:
`‖A(ψ)‖² · (4|R| + 1) ≤ 4|R|²`. -/
theorem depthProdCoin_sq_gap (R : Finset (∀ i, α i)) (f : ∀ i, α i → ℂ)
    (hf : ∀ i, IsCoin (f i)) {i₀ : ι} (hR : NonBoxAt R i₀) :
    ‖amp R (prodCoin f)‖ ^ 2 * (4 * R.card + 1) ≤ 4 * (R.card : ℝ) ^ 2 := by
  classical
  obtain ⟨x, hx, y, hy, hxy⟩ := hR
  set e := Equiv.piSplitAt i₀ α with he
  have hinj : Function.Injective e := e.injective
  set R' : Finset (α i₀ × (∀ j : {j : ι // j ≠ i₀}, α j)) := R.image e with hR'
  have hcard : R'.card = R.card := Finset.card_image_of_injective _ hinj
  -- the amplitude of the product coin is a bipartite amplitude
  have hamp : amp R (prodCoin f) = bipAmp R' (f i₀) (tailCoin f i₀) := by
    unfold amp bipAmp
    rw [hR', Finset.sum_image (fun a _ b _ h => hinj h)]
    exact Finset.sum_congr rfl fun z _ => prodCoin_split f i₀ z
  -- the three membership facts
  have hmem : ∀ z : ∀ i, α i, (e z ∈ R') ↔ z ∈ R := by
    intro z
    rw [hR']
    constructor
    · intro h
      obtain ⟨w, hw, hwz⟩ := Finset.mem_image.1 h
      exact hinj hwz ▸ hw
    · intro h; exact Finset.mem_image_of_mem _ h
  have hex : e x ∈ R' := (hmem x).2 hx
  have hey : e y ∈ R' := (hmem y).2 hy
  have hhyb : ((e x).1, (e y).2) = e (Function.update y i₀ (x i₀)) := by
    rw [he]
    ext
    · simp [Equiv.piSplitAt]
    · rename_i j
      simp [Equiv.piSplitAt, Function.update_of_ne j.2]
  have hout : ((e x).1, (e y).2) ∉ R' := by
    rw [hhyb]
    intro h
    exact hxy ((hmem _).1 h)
  have hgap := bipAmp_sq_gap R' (f i₀) (tailCoin f i₀) (hf i₀) (tailCoin_isCoin f hf i₀)
    (a := (e x).1) (b := (e x).2) (a' := (e y).1) (b' := (e y).2)
    (by simpa using hex) (by simpa using hey) hout
  rw [hamp, ← hcard]
  exact hgap

/-- Multiplicative form: `‖A(ψ)‖² ≤ (1 - c)·|R|` with the explicit constant
`c = 1/(4|R|+1) > 0`, uniform over all depths and all register alphabets. -/
theorem depthProdCoin_sq_le_one_sub_mul (R : Finset (∀ i, α i)) (f : ∀ i, α i → ℂ)
    (hf : ∀ i, IsCoin (f i)) {i₀ : ι} (hR : NonBoxAt R i₀) :
    ‖amp R (prodCoin f)‖ ^ 2 ≤ (1 - 1 / (4 * (R.card : ℝ) + 1)) * (R.card : ℝ) := by
  have hgap := depthProdCoin_sq_gap R f hf hR
  have hpos : (0 : ℝ) < 4 * (R.card : ℝ) + 1 := by positivity
  have hrw : (1 - 1 / (4 * (R.card : ℝ) + 1)) * (R.card : ℝ)
      = 4 * (R.card : ℝ) ^ 2 / (4 * (R.card : ℝ) + 1) := by
    field_simp
    ring
  rw [hrw, le_div_iff₀ hpos]
  exact hgap

/-- Additive form of the depth-`n` gap: the loss is at least `2/9`, uniformly in
the depth `n`, in the alphabet sizes and in `|R|`. -/
theorem depthProdCoin_sq_le_card_sub (R : Finset (∀ i, α i)) (f : ∀ i, α i → ℂ)
    (hf : ∀ i, IsCoin (f i)) {i₀ : ι} (hR : NonBoxAt R i₀) :
    ‖amp R (prodCoin f)‖ ^ 2 ≤ (R.card : ℝ) - 2 / 9 := by
  classical
  obtain ⟨x, hx, y, hy, hxy⟩ := hR
  have hne : x ≠ y := by
    rintro rfl
    exact hxy (by simpa [Function.update_eq_self] using hx)
  have hcard2 : 2 ≤ R.card := Finset.one_lt_card.2 ⟨x, hx, y, hy, hne⟩
  have hm : (2 : ℝ) ≤ (R.card : ℝ) := by exact_mod_cast hcard2
  have hgap := depthProdCoin_sq_gap R f hf ⟨x, hx, y, hy, hxy⟩
  nlinarith [hgap, hm]

/-- **Converse at depth `n`: product resonance sets are optimal for product
coins.**  If `R` is a genuine product of register-wise letter sets, the
Cauchy–Schwarz optimum `|R|` *is* attained by a depth-`n` product coin.
Together with `depthProdCoin_sq_gap` this is the depth-`n` dichotomy: the
optimum is attained by a shallow coin exactly when the resonance set does not
couple registers. -/
theorem piBox_attains (S : ∀ i, Finset (α i)) (hS : ∀ i, (S i).Nonempty) :
    ∃ f : ∀ i, α i → ℂ, (∀ i, IsCoin (f i)) ∧
      ‖amp (Fintype.piFinset S) (prodCoin f)‖ ^ 2 = ((Fintype.piFinset S).card : ℝ) := by
  classical
  refine ⟨fun i a => if a ∈ S i then ((Real.sqrt (S i).card : ℝ) : ℂ)⁻¹ else 0,
    fun i => uniform_isCoin _ (hS i), ?_⟩
  have hamp : amp (Fintype.piFinset S)
      (prodCoin fun i a => if a ∈ S i then ((Real.sqrt (S i).card : ℝ) : ℂ)⁻¹ else 0)
      = ∏ i, ∑ a ∈ S i, (if a ∈ S i then ((Real.sqrt (S i).card : ℝ) : ℂ)⁻¹ else 0) := by
    unfold amp prodCoin
    rw [Finset.prod_univ_sum]
  rw [hamp, Finset.prod_congr rfl fun i _ => uniform_sum (S i) (hS i)]
  rw [norm_prod, ← Finset.prod_pow, Fintype.card_piFinset]
  push_cast
  refine Finset.prod_congr rfl fun i _ => ?_
  have hc : (0 : ℝ) ≤ ((S i).card : ℝ) := Nat.cast_nonneg _
  rw [Complex.norm_real, Real.norm_eq_abs, abs_of_nonneg (Real.sqrt_nonneg _),
    Real.sq_sqrt hc]

end Depth

/-! ### A depth-`n` family: the agreement set -/

section Agreement

variable {n : ℕ}

/-- The **agreement set**: words of length `n` over `Bool` whose registers `i`
and `j` carry the same letter.  For `i ≠ j` this is the prototypical resonance
set that couples two registers. -/
def agreementSet (i j : Fin n) : Finset (Fin n → Bool) :=
  Finset.univ.filter fun x => x i = x j

/-- The agreement set of two distinct registers is not a box along `i`. -/
theorem agreementSet_nonBoxAt {i j : Fin n} (hij : i ≠ j) :
    NonBoxAt (α := fun _ : Fin n => Bool) (agreementSet i j) i := by
  refine ⟨fun _ => false, by simp [agreementSet], fun _ => true, by simp [agreementSet], ?_⟩
  simp [agreementSet, Function.update_of_ne (Ne.symm hij)]

/-- **Depth-`n` instance.**  For every `n` and every pair of distinct registers,
no product coin of depth `n` can resonate optimally with the agreement set: it
loses at least `2/9` of the optimum, no matter how large `n` is. -/
theorem agreementSet_gap {i j : Fin n} (hij : i ≠ j) (f : Fin n → Bool → ℂ)
    (hf : ∀ k, IsCoin (f k)) :
    ‖amp (agreementSet i j) (prodCoin f)‖ ^ 2 ≤ ((agreementSet i j).card : ℝ) - 2 / 9 :=
  depthProdCoin_sq_le_card_sub _ f hf (agreementSet_nonBoxAt hij)

end Agreement

/-! ### Sharpness benchmark: the two-point diagonal -/

/-- The diagonal of `Bool × Bool`. -/
def diagBool : Finset (Bool × Bool) := {(false, false), (true, true)}

theorem diagBool_card : diagBool.card = 2 := by decide

/-- The diagonal is not a box. -/
theorem diagBool_not_isBox : ¬ IsBox diagBool := by
  intro h
  have := h (false, false) (by decide) (true, true) (by decide)
  simp [diagBool] at this

/-- **Sharp value for the two-point diagonal.**  Every product coin on
`Bool × Bool` satisfies `‖A(ψ)‖² ≤ 1`, i.e. the optimum `|R| = 2` is missed by a
full unit — far more than the universal `2/9` guaranteed by the general theorem.
The bound `1` is attained (take `f` and `g` concentrated on `false`), so this is
the exact optimum for this resonance set. -/
theorem diag_sq_le_one (f g : Bool → ℂ) (hf : IsCoin f) (hg : IsCoin g) :
    ‖bipAmp diagBool f g‖ ^ 2 ≤ 1 := by
  have hfe : ‖f false‖ ^ 2 + ‖f true‖ ^ 2 = 1 := by
    have := hf
    unfold IsCoin at this
    simpa [Fintype.sum_bool, add_comm] using this
  have hge : ‖g false‖ ^ 2 + ‖g true‖ ^ 2 = 1 := by
    have := hg
    unfold IsCoin at this
    simpa [Fintype.sum_bool, add_comm] using this
  have hsum : bipAmp diagBool f g = f false * g false + f true * g true := by
    unfold bipAmp diagBool
    rw [Finset.sum_insert (by decide)]
    simp
  rw [hsum]
  have h1 : ‖f false * g false + f true * g true‖
      ≤ ‖f false‖ * ‖g false‖ + ‖f true‖ * ‖g true‖ := by
    refine le_trans (norm_add_le _ _) ?_
    rw [norm_mul, norm_mul]
  have h2 : (‖f false‖ * ‖g false‖ + ‖f true‖ * ‖g true‖) ^ 2 ≤ 1 := by
    nlinarith [sq_nonneg (‖f false‖ * ‖g true‖ - ‖f true‖ * ‖g false‖), hfe, hge,
      norm_nonneg (f false), norm_nonneg (f true), norm_nonneg (g false), norm_nonneg (g true)]
  nlinarith [h1, h2, norm_nonneg (f false * g false + f true * g true)]

/-- The sharp value `1` is attained on the diagonal: the bound of
`diag_sq_le_one` cannot be improved. -/
theorem diag_sq_one_attained :
    ∃ f g : Bool → ℂ, IsCoin f ∧ IsCoin g ∧ ‖bipAmp diagBool f g‖ ^ 2 = 1 := by
  refine ⟨fun b => if b = false then 1 else 0, fun b => if b = false then 1 else 0, ?_, ?_, ?_⟩
  · show ∑ b : Bool, _ = _
    simp
  · show ∑ b : Bool, _ = _
    simp
  · have hsum : bipAmp diagBool (fun b => if b = false then (1 : ℂ) else 0)
        (fun b => if b = false then (1 : ℂ) else 0) = 1 := by
      unfold bipAmp diagBool
      rw [Finset.sum_insert (by decide)]
      simp
    rw [hsum]
    simp

end ShallowProductCoin