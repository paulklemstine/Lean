/-
# Depth compounding of quantization error, and which layer is the sensitive one

The NET-52 round measured a *depth gradient*: quantizing the last twelve layers hurts more than
quantizing the first twelve (+0.4054 vs +0.3885 CE), and the damage explodes as the mesh
coarsens.  This file proves the two structural facts behind that phenomenology for the exactly
solvable model of a deep *product* network `x ↦ (∏_i w i) · x`.

* `prod_perturb_bound` — if every weight has modulus at most `M` and is perturbed by at most
  `δ` (for RTN, `δ = Δ/2`), the product moves by at most `(M + δ)^n − M^n`.  This is the
  compounding law: the bound is `≈ n M^(n−1) δ` for small `δ`, i.e. *linear in depth but
  exponential in the weight scale*, and it blows up as soon as `M > 1`.
* `prod_perturb_sharp` — the bound is attained (all weights at `+M`, all errors at `+δ`), so
  the compounding is real, not an artifact of triangle inequalities.
* `single_layer_defect` — an exact identity: perturbing layer `k` alone changes the product by
  `t · ∏_{i ≠ k} w i`.  The *sensitivity* of a layer is the complementary product.
* `sensitivity_antitone` — consequently, the smaller a layer's weight, the larger its
  sensitivity.  Layer position enters only through the weight profile: "deeper is worse"
  is equivalent to "deeper layers carry smaller weights", a falsifiable statement about a
  pretrained checkpoint rather than a law of depth.
* `depth_cliff` — for `M ≥ 1` and any prescribed budget, a deep enough product network exceeds
  it at any fixed bit budget: the empirical cliff has a formal counterpart.
-/
import Mathlib

namespace Catalog.NumberTheory.QuantDepth

open Finset

/-- A product of numbers of modulus at most `M` has modulus at most `M ^ n`. -/
lemma abs_prod_le {M : ℝ} (hM : 0 ≤ M) (v : ℕ → ℝ) :
    ∀ n, (∀ i < n, |v i| ≤ M) → |∏ i ∈ Finset.range n, v i| ≤ M ^ n := by
  intro n
  induction n with
  | zero => simp
  | succ k ih =>
      intro h
      rw [Finset.prod_range_succ, abs_mul, pow_succ]
      exact mul_le_mul (ih fun i hi => h i (by omega)) (h k (by omega)) (abs_nonneg _)
        (by positivity)

/-- **Compounding law.**  Perturbing each of `n` weights of modulus `≤ M` by at most `δ` moves
their product by at most `(M + δ) ^ n − M ^ n`. -/
theorem prod_perturb_bound {M δ : ℝ} (hM : 0 ≤ M) (hδ : 0 ≤ δ) (w e : ℕ → ℝ) :
    ∀ n, (∀ i < n, |w i| ≤ M) → (∀ i < n, |e i| ≤ δ) →
      |∏ i ∈ Finset.range n, (w i + e i) - ∏ i ∈ Finset.range n, w i| ≤ (M + δ) ^ n - M ^ n := by
  intro n
  induction n with
  | zero => simp
  | succ k ih =>
      intro hw he
      have ihk := ih (fun i hi => hw i (by omega)) (fun i hi => he i (by omega))
      set P' := ∏ i ∈ Finset.range k, (w i + e i) with hP'
      set P := ∏ i ∈ Finset.range k, w i with hP
      have hP'abs : |P'| ≤ (M + δ) ^ k := by
        refine abs_prod_le (by linarith) _ k ?_
        intro i hi
        calc |w i + e i| ≤ |w i| + |e i| := abs_add_le _ _
          _ ≤ M + δ := add_le_add (hw i (by omega)) (he i (by omega))
      have hbk : |w k| ≤ M := hw k (by omega)
      have hek : |e k| ≤ δ := he k (by omega)
      have hsplit : P' * (w k + e k) - P * w k = P' * e k + w k * (P' - P) := by ring
      rw [Finset.prod_range_succ, Finset.prod_range_succ, ← hP', ← hP, hsplit]
      have h1 : |P' * e k + w k * (P' - P)| ≤ |P'| * |e k| + |w k| * |P' - P| := by
        calc |P' * e k + w k * (P' - P)| ≤ |P' * e k| + |w k * (P' - P)| := abs_add_le _ _
          _ = |P'| * |e k| + |w k| * |P' - P| := by rw [abs_mul, abs_mul]
      have h2 : |P'| * |e k| ≤ (M + δ) ^ k * δ :=
        mul_le_mul hP'abs hek (abs_nonneg _) (by positivity)
      have h3 : |w k| * |P' - P| ≤ M * ((M + δ) ^ k - M ^ k) :=
        mul_le_mul hbk ihk (abs_nonneg _) (le_trans (abs_nonneg _) hbk)
      have hgoal : (M + δ) ^ (k + 1) - M ^ (k + 1)
          = (M + δ) ^ k * δ + M * ((M + δ) ^ k - M ^ k) := by
        rw [pow_succ, pow_succ]; ring
      rw [hgoal]
      linarith

/-- **The compounding bound is attained.** -/
theorem prod_perturb_sharp {M δ : ℝ} (hM : 0 ≤ M) (hδ : 0 ≤ δ) (n : ℕ) :
    |∏ _i ∈ Finset.range n, (M + δ) - ∏ _i ∈ Finset.range n, M| = (M + δ) ^ n - M ^ n := by
  rw [Finset.prod_const, Finset.prod_const, Finset.card_range,
    abs_of_nonneg (by
      have : M ^ n ≤ (M + δ) ^ n := pow_le_pow_left₀ hM (by linarith) n
      linarith)]

/-- **Exact layer sensitivity.**  Perturbing layer `k` by `t` moves the product by exactly
`t` times the complementary product. -/
theorem single_layer_defect (n : ℕ) (w : ℕ → ℝ) {k : ℕ} (hk : k < n) (t : ℝ) :
    (∏ i ∈ Finset.range n, (if i = k then w i + t else w i)) - ∏ i ∈ Finset.range n, w i
      = t * ∏ i ∈ (Finset.range n).erase k, w i := by
  have hkmem : k ∈ Finset.range n := Finset.mem_range.2 hk
  have hmod : ∏ i ∈ Finset.range n, (if i = k then w i + t else w i)
      = (w k + t) * ∏ i ∈ (Finset.range n).erase k, w i := by
    rw [← Finset.mul_prod_erase _ _ hkmem, if_pos rfl]
    congr 1
    refine Finset.prod_congr rfl ?_
    intro i hi
    rw [if_neg (Finset.ne_of_mem_erase hi)]
  have horig : ∏ i ∈ Finset.range n, w i = w k * ∏ i ∈ (Finset.range n).erase k, w i :=
    (Finset.mul_prod_erase _ _ hkmem).symm
  rw [hmod, horig]
  ring

/-- **Smaller weights are more sensitive layers.**  If layer `a` has a weight no larger in
modulus than layer `b`, then layer `b`'s sensitivity is no larger than layer `a`'s.  Thus a
depth gradient in quantization damage is a statement about the depth profile of weight
magnitudes, nothing more. -/
theorem sensitivity_antitone {n : ℕ} (w : ℕ → ℝ) {a b : ℕ} (ha : a < n) (hb : b < n)
    (hane : w a ≠ 0) (hab : |w a| ≤ |w b|) :
    |∏ i ∈ (Finset.range n).erase b, w i| ≤ |∏ i ∈ (Finset.range n).erase a, w i| := by
  have hamem : a ∈ Finset.range n := Finset.mem_range.2 ha
  have hbmem : b ∈ Finset.range n := Finset.mem_range.2 hb
  have hA : |w a| * |∏ i ∈ (Finset.range n).erase a, w i| = |∏ i ∈ Finset.range n, w i| := by
    rw [← abs_mul, Finset.mul_prod_erase _ _ hamem]
  have hB : |w b| * |∏ i ∈ (Finset.range n).erase b, w i| = |∏ i ∈ Finset.range n, w i| := by
    rw [← abs_mul, Finset.mul_prod_erase _ _ hbmem]
  have hpos : 0 < |w a| := abs_pos.2 hane
  have hBnn : 0 ≤ |∏ i ∈ (Finset.range n).erase b, w i| := abs_nonneg _
  nlinarith [hA, hB, hpos, hBnn]

/-- **The depth cliff.**  Fix a bit budget through the half-mesh `δ > 0` and a weight scale
`M ≥ 1`.  Then for every damage budget `c` there is a depth `n` at which the worst-case
compounded defect of the product network exceeds `c`: no depth-uniform floor exists either. -/
theorem depth_cliff {M δ : ℝ} (hM : 1 ≤ M) (hδ : 0 < δ) (c : ℝ) :
    ∃ n : ℕ, c < (M + δ) ^ n - M ^ n := by
  have hgrow : ∀ n : ℕ, (M + δ) ^ n - M ^ n ≥ n * δ * M ^ (n - 1) := by
    intro n
    induction n with
    | zero => simp
    | succ k ih =>
        have hM0 : (0:ℝ) < M := by linarith
        have hmono : M ^ k ≤ (M + δ) ^ k := pow_le_pow_left₀ (by linarith) (by linarith) k
        have hstep : (M + δ) ^ (k + 1) - M ^ (k + 1)
            = (M + δ) ^ k * δ + M * ((M + δ) ^ k - M ^ k) := by
          rw [pow_succ, pow_succ]; ring
        have key : M * ((k:ℝ) * δ * M ^ (k - 1)) = (k:ℝ) * δ * M ^ k := by
          rcases Nat.eq_zero_or_pos k with hk | hk
          · subst hk; simp
          · have hp : M ^ (k - 1) * M = M ^ k := by
              rw [← pow_succ]
              congr 1
              omega
            calc M * ((k:ℝ) * δ * M ^ (k - 1)) = (k:ℝ) * δ * (M ^ (k - 1) * M) := by ring
              _ = (k:ℝ) * δ * M ^ k := by rw [hp]
        have hmul : M * ((k:ℝ) * δ * M ^ (k - 1)) ≤ M * ((M + δ) ^ k - M ^ k) :=
          mul_le_mul_of_nonneg_left ih (le_of_lt hM0)
        have hdelta : M ^ k * δ ≤ (M + δ) ^ k * δ :=
          mul_le_mul_of_nonneg_right hmono (le_of_lt hδ)
        have hk1 : ((k + 1 : ℕ) : ℝ) * δ * M ^ (k + 1 - 1) = (k:ℝ) * δ * M ^ k + δ * M ^ k := by
          simp only [Nat.add_sub_cancel]
          push_cast
          ring
        rw [hstep, hk1]
        rw [key] at hmul
        linarith
  obtain ⟨n, hn⟩ := exists_nat_gt ((|c| + 1) / δ)
  refine ⟨n, ?_⟩
  have hnd : |c| + 1 < n * δ := by
    rw [div_lt_iff₀ hδ] at hn
    linarith
  have hMn : (1:ℝ) ≤ M ^ (n - 1) := one_le_pow₀ hM
  have hbound := hgrow n
  have hnn : (0:ℝ) ≤ n * δ := by positivity
  nlinarith [le_abs_self c]

end Catalog.NumberTheory.QuantDepth