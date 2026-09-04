import MachineLearning.ForkChannelProductUniversality

/-!
# The split-count channel is optimal among all symmetric fork readouts

The table-closure files proved `H1` — `Is ≥ max(g, A, X)` — by computing the four
channels and comparing their parameters, and
`MachineLearning.ForkChannelProductUniversality` extended the strict version to the
whole coordinatewise-product class.  Both arguments are *formula-driven*: they need
the closed form of the readout.

This file proves `H1` in its final, formula-free form: **no symmetric readout
whatsoever can beat the split count.**  For every readout `F` of an `(n+1)`-bit
Bernoulli(`p`) fork that is invariant under permutations of the bits,

`leak p F ≤ 1/(n+1) = isChan p n`   (`leak_le_isChan_of_symm`),

with the split count attaining the bound.  In particular the `Is`-domination is a
structural fact about exchangeability, not a coincidence of the AND/OR/XOR algebra.

The proof is a Cauchy–Schwarz argument inside the exact expectation functional `E`:

* `E_perm` — the product weights are permutation invariant, so `E` is;
* `Cov_cIdx_eq_of_symm` — for a symmetric readout every input bit has the same
  covariance with it, hence `Cov(w, F) = (n+1)·Cov(x₀, F)` where `w` is the Hamming
  weight (`Cov_wCh_eq_of_symm`);
* `Cov_sq_le` — Cauchy–Schwarz `Cov(F,G)² ≤ Var F · Var G`, proved from the
  nonnegativity of `Var (F + λG)` as a quadratic in `λ` (discriminant argument);
* combining, `(n+1)²·Cov(x₀,F)² ≤ Var w · Var F = (n+1)p(1-p)·Var F`, which is
  exactly `leak p F ≤ 1/(n+1)`.
-/

namespace ForkChannel

variable {n N : ℕ} {p : ℝ}

/-! ## Permutation invariance of the fork measure -/

/-- A readout is *symmetric* if it does not depend on the ordering of the bits. -/
def SymmReadout (F : (Fin N → Bool) → ℝ) : Prop :=
  ∀ (σ : Equiv.Perm (Fin N)) (x : Fin N → Bool), F (x ∘ σ) = F x

theorem wt_perm (p : ℝ) (σ : Equiv.Perm (Fin N)) (x : Fin N → Bool) :
    wt p (x ∘ σ) = wt p x :=
  Equiv.prod_comp σ (fun j => if x j then p else 1 - p)

/-- The exact expectation functional is permutation invariant. -/
theorem E_perm (p : ℝ) (σ : Equiv.Perm (Fin N)) (F : (Fin N → Bool) → ℝ) :
    E p (fun x => F (x ∘ σ)) = E p F := by
  refine Fintype.sum_equiv ⟨fun x => x ∘ σ, fun y => y ∘ σ.symm, ?_, ?_⟩ _ _ ?_
  · intro x; funext i; simp
  · intro y; funext i; simp
  · intro x
    show wt p x * F (x ∘ σ) = wt p (x ∘ σ) * F (x ∘ σ)
    rw [wt_perm]

/-- Every coordinatewise-product readout is symmetric. -/
theorem prodCh_symm (c : Bool → ℝ) : SymmReadout (prodCh c : (Fin N → Bool) → ℝ) := by
  intro σ x
  exact Equiv.prod_comp σ (fun j => c (x j))

/-- The Hamming weight is symmetric. -/
theorem wCh_symm : SymmReadout (wCh : (Fin N → Bool) → ℝ) := by
  intro σ x
  exact Equiv.sum_comp σ (fun j => cIdx j x)

/-- Symmetry is preserved by affine changes of the readout. -/
theorem SymmReadout.affine {F : (Fin N → Bool) → ℝ} (hF : SymmReadout F) (α β : ℝ) :
    SymmReadout (fun x => α * F x + β) := by
  intro σ x
  show α * F (x ∘ σ) + β = α * F x + β
  rw [hF σ x]

/-! ## Every bit has the same covariance with a symmetric readout -/

theorem Cov_cIdx_eq_of_symm {F : (Fin (n+1) → Bool) → ℝ} (hF : SymmReadout F) (p : ℝ)
    (i : Fin (n+1)) : Cov p (cIdx i) F = Cov p (cIdx 0) F := by
  have hE : E p (fun x => cIdx i x * F x) = E p (fun x => cIdx 0 x * F x) := by
    have hcomp : (fun x : Fin (n+1) → Bool =>
        (fun y => cIdx i y * F y) (x ∘ Equiv.swap (0 : Fin (n+1)) i))
        = fun x => cIdx 0 x * F x := by
      funext x
      have h1 : (x ∘ Equiv.swap (0 : Fin (n+1)) i) i = x 0 := by
        simp [Function.comp]
      show cIdx i (x ∘ Equiv.swap (0 : Fin (n+1)) i) * F (x ∘ Equiv.swap (0 : Fin (n+1)) i)
        = cIdx 0 x * F x
      rw [hF (Equiv.swap (0 : Fin (n+1)) i) x]
      unfold cIdx
      rw [h1]
    calc E p (fun x => cIdx i x * F x)
        = E p (fun x => (fun y => cIdx i y * F y) (x ∘ Equiv.swap (0 : Fin (n+1)) i)) :=
          (E_perm p (Equiv.swap (0 : Fin (n+1)) i) (fun y => cIdx i y * F y)).symm
      _ = E p (fun x => cIdx 0 x * F x) := by rw [hcomp]
  unfold Cov
  rw [hE, E_cIdx, E_cIdx]

/-- For a symmetric readout the covariance with the Hamming weight is `(n+1)` times the
covariance with a single bit. -/
theorem Cov_wCh_eq_of_symm {F : (Fin (n+1) → Bool) → ℝ} (hF : SymmReadout F) (p : ℝ) :
    Cov p (wCh : (Fin (n+1) → Bool) → ℝ) F = (n+1) * Cov p (cIdx 0) F := by
  have hsum : E p (fun x : Fin (n+1) → Bool => wCh x * F x)
      = ∑ i : Fin (n+1), E p (fun x => cIdx i x * F x) := by
    rw [E_congr p (G := fun x : Fin (n+1) → Bool => ∑ i, cIdx i x * F x)
        (fun x => by unfold wCh; rw [Finset.sum_mul]),
      E_sum p Finset.univ (fun i => fun x : Fin (n+1) → Bool => cIdx i x * F x)]
  have hterm : ∀ i : Fin (n+1), E p (fun x => cIdx i x * F x)
      = Cov p (cIdx 0) F + p * E p F := by
    intro i
    have h := Cov_cIdx_eq_of_symm hF p i
    have h2 : E p (fun x => cIdx i x * F x) - E p (cIdx i) * E p F = Cov p (cIdx 0) F := h
    rw [E_cIdx] at h2
    linarith
  unfold Cov
  rw [hsum, Finset.sum_congr rfl (fun i (_ : i ∈ Finset.univ) => hterm i), Finset.sum_const,
    E_wCh]
  simp only [Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  unfold Cov
  rw [E_cIdx]
  push_cast
  ring

/-! ## Cauchy–Schwarz for the exact covariance -/

theorem wt_nonneg (hp : 0 ≤ p) (hp1 : p ≤ 1) (x : Fin N → Bool) : 0 ≤ wt p x :=
  Finset.prod_nonneg (fun i _ => by by_cases h : x i <;> simp [h] <;> linarith)

theorem E_nonneg (hp : 0 ≤ p) (hp1 : p ≤ 1) {F : (Fin N → Bool) → ℝ} (hF : ∀ x, 0 ≤ F x) :
    0 ≤ E p F :=
  Finset.sum_nonneg (fun x _ => mul_nonneg (wt_nonneg hp hp1 x) (hF x))

theorem Var_eq_E_sub_sq (p : ℝ) (F : (Fin N → Bool) → ℝ) :
    Var p F = E p (fun x => (F x - E p F) ^ 2) := by
  have h : E p (fun x => (F x - E p F) ^ 2)
      = (E p (fun x => F x * F x) - (2 * E p F) * E p F) + (E p F) ^ 2 := by
    rw [E_congr p (G := fun x => (F x * F x - (2 * E p F) * F x) + (E p F) ^ 2)
        (fun x => by ring),
      E_add p (fun x => F x * F x - (2 * E p F) * F x) (fun _ => (E p F) ^ 2),
      E_sub p (fun x => F x * F x) (fun x => (2 * E p F) * F x), E_const_mul, E_const]
  rw [h]
  unfold Var Cov
  ring

theorem Var_nonneg (hp : 0 ≤ p) (hp1 : p ≤ 1) (F : (Fin N → Bool) → ℝ) : 0 ≤ Var p F := by
  rw [Var_eq_E_sub_sq]
  exact E_nonneg hp hp1 (fun x => sq_nonneg _)

theorem Var_add_smul (p : ℝ) (F G : (Fin N → Bool) → ℝ) (l : ℝ) :
    Var p (fun x => F x + l * G x)
      = Var p G * l ^ 2 + 2 * Cov p F G * l + Var p F := by
  have hE : E p (fun x => F x + l * G x) = E p F + l * E p G := by
    rw [E_add p F (fun x => l * G x), E_const_mul]
  have hE2 : E p (fun x => (F x + l * G x) * (F x + l * G x))
      = E p (fun x => F x * F x) + (2 * l) * E p (fun x => F x * G x)
        + l ^ 2 * E p (fun x => G x * G x) := by
    rw [E_congr p (G := fun x => (F x * F x + (2 * l) * (F x * G x)) + l ^ 2 * (G x * G x))
        (fun x => by ring),
      E_add p (fun x => F x * F x + (2 * l) * (F x * G x)) (fun x => l ^ 2 * (G x * G x)),
      E_add p (fun x => F x * F x) (fun x => (2 * l) * (F x * G x)),
      E_const_mul, E_const_mul]
  unfold Var Cov
  rw [hE, hE2]
  ring

/-- **Cauchy–Schwarz** for the exact fork covariance. -/
theorem Cov_sq_le (hp : 0 ≤ p) (hp1 : p ≤ 1) (F G : (Fin N → Bool) → ℝ) :
    (Cov p F G) ^ 2 ≤ Var p F * Var p G := by
  have key : ∀ l : ℝ, 0 ≤ Var p G * (l * l) + 2 * Cov p F G * l + Var p F := by
    intro l
    have h := Var_nonneg hp hp1 (fun x => F x + l * G x)
    rw [Var_add_smul] at h
    nlinarith [h]
  have hdisc := discrim_le_zero key
  unfold discrim at hdisc
  nlinarith [hdisc]

/-! ## The optimality theorem -/

theorem Var_wCh (p : ℝ) (n : ℕ) :
    Var p (wCh : (Fin (n+1) → Bool) → ℝ) = (n+1) * (p * (1 - p)) := by
  unfold Var Cov
  rw [E_wCh_mul_wCh, E_wCh]
  push_cast
  ring

/-- **The split-count channel is optimal among symmetric readouts.**  No permutation
invariant readout of an `(n+1)`-bit Bernoulli fork can leak more about a single input
bit than the Hamming weight does, whose leakage is exactly `1/(n+1)`. -/
theorem leak_le_isChan_of_symm (hp : 0 < p) (hp1 : p < 1) {F : (Fin (n+1) → Bool) → ℝ}
    (hF : SymmReadout F) : leak p F ≤ 1 / (n + 1) := by
  have hq : 0 < 1 - p := by linarith
  have hpq : 0 < p * (1 - p) := mul_pos hp hq
  have hN : (0:ℝ) < (n:ℝ) + 1 := by positivity
  have hVar : 0 ≤ Var p F := Var_nonneg hp.le hp1.le F
  rcases eq_or_lt_of_le hVar with hzero | hpos
  · unfold leak corrSq
    rw [Var_cIdx_zero, ← hzero, mul_zero, div_zero]
    positivity
  · have hCS : (Cov p (wCh : (Fin (n+1) → Bool) → ℝ) F) ^ 2
        ≤ Var p (wCh : (Fin (n+1) → Bool) → ℝ) * Var p F := Cov_sq_le hp.le hp1.le _ _
    rw [Cov_wCh_eq_of_symm hF p, Var_wCh] at hCS
    have hkey : ((n:ℝ) + 1) * (Cov p (cIdx (0 : Fin (n+1))) F) ^ 2
        ≤ (p * (1 - p)) * Var p F := by
      have hmul : (((n:ℝ) + 1) * Cov p (cIdx (0 : Fin (n+1))) F) ^ 2
          = ((n:ℝ) + 1) ^ 2 * (Cov p (cIdx (0 : Fin (n+1))) F) ^ 2 := by ring
      rw [hmul] at hCS
      nlinarith [hCS, hN]
    unfold leak corrSq
    rw [Var_cIdx_zero, div_le_div_iff₀ (mul_pos hpq hpos) hN]
    nlinarith [hkey, hpos, hN]


/-! ## The equality case: only readouts affine in the Hamming weight attain the bound -/

theorem Cov_comm (p : ℝ) (F G : (Fin N → Bool) → ℝ) : Cov p F G = Cov p G F := by
  unfold Cov
  rw [E_congr p (F := fun x => F x * G x) (G := fun x => G x * F x) (fun x => by ring)]
  ring

theorem wt_pos (hp : 0 < p) (hp1 : p < 1) (x : Fin N → Bool) : 0 < wt p x :=
  Finset.prod_pos (fun i _ => by by_cases h : x i <;> simp [h] <;> linarith)

/-- A readout of zero variance is constant: with `0 < p < 1` every bit pattern has
positive weight, so no cancellation is possible. -/
theorem eq_of_Var_eq_zero (hp : 0 < p) (hp1 : p < 1) {F : (Fin N → Bool) → ℝ}
    (h : Var p F = 0) (x : Fin N → Bool) : F x = E p F := by
  rw [Var_eq_E_sub_sq] at h
  have hsum : ∑ y : Fin N → Bool, wt p y * (F y - E p F) ^ 2 = 0 := h
  have hnn : ∀ y ∈ (Finset.univ : Finset (Fin N → Bool)),
      0 ≤ wt p y * (F y - E p F) ^ 2 :=
    fun y _ => mul_nonneg (wt_pos hp hp1 y).le (sq_nonneg _)
  have hzero := (Finset.sum_eq_zero_iff_of_nonneg hnn).mp hsum x (Finset.mem_univ x)
  have hx : (F x - E p F) ^ 2 = 0 := by
    rcases mul_eq_zero.mp hzero with h1 | h2
    · exact absurd h1 (wt_pos hp hp1 x).ne'
    · exact h2
  have : F x - E p F = 0 := by
    exact pow_eq_zero_iff (n := 2) (by norm_num) |>.mp hx
  linarith

/-- **Equality case of the optimality bound.**  A symmetric readout leaks exactly
`1/(n+1)` about a single input bit if and only if it is a non-degenerate affine
function of the Hamming weight — the split count is, up to affine changes, the unique
optimal symmetric readout. -/
theorem leak_eq_isChan_iff_affine_wCh (hp : 0 < p) (hp1 : p < 1)
    {F : (Fin (n+1) → Bool) → ℝ} (hF : SymmReadout F) :
    leak p F = 1 / (n + 1) ↔ ∃ α β : ℝ, α ≠ 0 ∧ ∀ x, F x = α * wCh x + β := by
  have hq : 0 < 1 - p := by linarith
  have hpq : 0 < p * (1 - p) := mul_pos hp hq
  have hN : (0:ℝ) < (n:ℝ) + 1 := by positivity
  have hVw : Var p (wCh : (Fin (n+1) → Bool) → ℝ) = ((n:ℝ) + 1) * (p * (1 - p)) := Var_wCh p n
  have hVwpos : 0 < Var p (wCh : (Fin (n+1) → Bool) → ℝ) := by rw [hVw]; positivity
  constructor
  · intro heq
    have hVarF : 0 < Var p F := by
      rcases eq_or_lt_of_le (Var_nonneg hp.le hp1.le F) with hz | hpos
      · exfalso
        have hzero : leak p F = 0 := by
          unfold leak corrSq
          rw [Var_cIdx_zero, ← hz, mul_zero, div_zero]
        rw [hzero] at heq
        have : (0:ℝ) < 1 / ((n:ℝ) + 1) := by positivity
        rw [← heq] at this
        exact lt_irrefl 0 this
      · exact hpos
    have hleak : (Cov p (cIdx (0 : Fin (n+1))) F) ^ 2 / (p * (1 - p) * Var p F)
        = 1 / ((n:ℝ) + 1) := by
      have h := heq
      unfold leak corrSq at h
      rw [Var_cIdx_zero] at h
      exact h
    have hkey : ((n:ℝ) + 1) * (Cov p (cIdx (0 : Fin (n+1))) F) ^ 2 = p * (1 - p) * Var p F := by
      rw [div_eq_div_iff (mul_pos hpq hVarF).ne' hN.ne'] at hleak
      linarith
    have hCw : Cov p (wCh : (Fin (n+1) → Bool) → ℝ) F
        = ((n:ℝ) + 1) * Cov p (cIdx 0) F := Cov_wCh_eq_of_symm hF p
    have hCsq : (Cov p (wCh : (Fin (n+1) → Bool) → ℝ) F) ^ 2
        = Var p (wCh : (Fin (n+1) → Bool) → ℝ) * Var p F := by
      rw [hCw, hVw]
      nlinarith [hkey]
    set l : ℝ := -(Cov p (wCh : (Fin (n+1) → Bool) → ℝ) F) / Var p (wCh) with hl
    have hzeroVar : Var p (fun x => F x + l * wCh x) = 0 := by
      rw [Var_add_smul]
      rw [Cov_comm p F (wCh : (Fin (n+1) → Bool) → ℝ), hl]
      field_simp
      nlinarith [hCsq]
    refine ⟨-l, E p (fun x => F x + l * wCh x), ?_, ?_⟩
    · intro hzero
      have hl0 : l = 0 := by linarith
      have hdiv : -(Cov p (wCh : (Fin (n+1) → Bool) → ℝ) F)
          / Var p (wCh : (Fin (n+1) → Bool) → ℝ) = 0 := by rw [← hl]; exact hl0
      have hC : Cov p (wCh : (Fin (n+1) → Bool) → ℝ) F = 0 := by
        rcases div_eq_zero_iff.mp hdiv with h | h
        · linarith
        · exact absurd h hVwpos.ne'
      rw [hC] at hCsq
      nlinarith [hCsq, hVwpos, hVarF]
    · intro x
      have hpt := eq_of_Var_eq_zero hp hp1 hzeroVar x
      simp only at hpt
      linear_combination hpt
  · rintro ⟨α, β, hα, hFx⟩
    have hEq : F = fun x => α * wCh x + β := funext hFx
    rw [hEq, leak_affine p β hα (wCh : (Fin (n+1) → Bool) → ℝ)]
    have h := isChan_value hp hp1 n
    simpa [isChan] using h

/-- Restated against the split-count channel itself. -/
theorem leak_le_split_of_symm (hp : 0 < p) (hp1 : p < 1) {F : (Fin (n+1) → Bool) → ℝ}
    (hF : SymmReadout F) : leak p F ≤ isChan p n := by
  rw [isChan_value hp hp1]
  exact leak_le_isChan_of_symm hp hp1 hF

end ForkChannel