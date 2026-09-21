/-
# THE-SUM-DIFFERENCE-SPLIT, part IV: the hyperbola ceiling

Cycle 3 of the round-29 loop.  Parts II and III bounded the factor-residue hint value by the
label entropy `H(T)` and showed that bound to be sharp.  That ceiling, however, knows nothing
about the modulus: it is the same for `m = 5` and for `m = 31`.  This part proves the ceiling
that *does* know the modulus, and evaluates it exactly for the uniform factor battery over a
finite field, where the computation becomes a point count on the hyperbola `xy = n`.

* `SumDiffUniform.hintValue_le_entropy_gap` — **the sharp general ceiling**:
  `I(T ; s,d) - I(T ; N) ≤ H(s,d) - H(N)` in bits, for *any* labels.  The right-hand side is
  the residual uncertainty of the factor pair once `N` is known — literally "what knowing `p`
  and `q` separately adds over reading `N`", the quantity the round-29 write-up names.  The
  proof is a second data-processing step, applied to the *joint* statistic `(T, ·)`.
* `SumDiffUniform.card_hyperbola_ne_zero`, `card_hyperbola_zero` — the point counts
  `#{(x,y) ∈ F² : xy = n} = q - 1` for `n ≠ 0` and `2q - 1` for `n = 0`, over any finite field
  with `q` elements: the affine hyperbola minus its two asymptotic points, and the degenerate
  pair of lines.
* `SumDiffUniform.H_residueView_uniform`, `H_productView_uniform` — the two entropies of the
  uniform factor battery in closed form: `log q²` and
  `phi(q², 2q-1) + (q-1) · phi(q², q-1)`.
* `SumDiffUniform.hintValue_uniform_le` — the capstone: for the uniform battery over `F` and
  **any** labelling whatsoever, the hint value is at most
  `(log q² - phi(q², 2q-1) - (q-1) phi(q², q-1)) / log 2`.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1, cycle 3): the modulus-aware ceiling on the hint value is the conditional
  entropy `H(p,q | pq)`, and for the uniform battery this is computable in closed form from
  the fibre structure of the multiplication map of a finite field.
Experiment (Stage 2, cycle 3): evaluated the closed form at `q = 31` (see
  `ComputationalEvidence.md`): `H(s,d) = log₂ 961 = 9.9084` bits, `H(N) = 4.9365` bits, so the
  ceiling is `4.9719` bits.  The round-29 reading `+0.5189` bits is `10.4%` of it.  At `q = 5`:
  `H(s,d) = 4.6439`, `H(N) = 2.2227`, ceiling `2.4212` bits — and the part-III ceiling witness
  attains `2` of those `2.4212` bits, so the two ceilings are genuinely comparable in size.
Analysis (Stage 3, cycle 3): the hyperbola count is the whole story.  Every fibre of the
  product view over a nonzero residue has exactly `q - 1` points; the fibre over `0` is the
  degenerate conic `xy = 0`, a pair of lines with `2q - 1` points.  The entropy defect of the
  product view — and hence the entire budget available to a factor-residue hint — is therefore
  a statement about a single degenerate conic.
Critique (Stage 4, cycle 3): the ceiling is proved for the *uniform* battery; a battery
  supported on the units `F* × F*` has a different, smaller budget (`log₂(q-1)` exactly, since
  every product fibre then has `q - 1` points), which is conjecture C3 of
  `FUTURE_DIRECTIONS.md`.  The general ceiling `hintValue_le_entropy_gap` is assumption-free
  and is the statement to quote when the population is not uniform.
-/
import Mathlib
import Algebra.SumDiffHintValue

namespace SumDiffUniform

open TraceBattery BatterySynergy SumDiffSplit Finset

/-! ## 1. The sharp general ceiling: conditional entropy of the hint -/

section General

variable {Ω : Type*} [Fintype Ω] {Λ : Type*} {R : Type*} [CommRing R] [Invertible (2 : R)]

/-- Adjoining the label to a coarsening is still a coarsening. -/
theorem H_pr_product_le (L : Ω → Λ) (P Q : Ω → R) :
    H (pr L (productView P Q)) ≤ H (pr L (residueView P Q)) := by
  have hcomp : (fun w : Λ × (R × R) => (w.1, prodOf w.2)) ∘ (pr L (residueView P Q))
      = pr L (productView P Q) := by
    funext x
    simp [pr, productView, residueView, prodOf_sd]
  have h := H_comp_le (pr L (residueView P Q)) fun w : Λ × (R × R) => (w.1, prodOf w.2)
  rwa [hcomp] at h

/-- **The sharp ceiling on the hint value.**  Whatever the labels, the factor-residue hint
can release at most the entropy that the joint residue view has over the product view:
`I(T ; s,d) - I(T ; N) ≤ H(s,d) - H(N)`.  This is the modulus-aware ceiling: unlike the
label-entropy ceiling it shrinks as the product view approaches a faithful code. -/
theorem hintValue_le_entropy_gap (L : Ω → Λ) (P Q : Ω → R) :
    hintValue L P Q ≤ Hb (residueView P Q) - Hb (productView P Q) := by
  have hkey := H_pr_product_le L P Q
  have hnum : condH L (productView P Q) - condH L (residueView P Q)
      ≤ H (residueView P Q) - H (productView P Q) := by
    simp only [condH]
    linarith
  rw [hintValue_eq_condH_release, Hb, Hb, ← sub_div]
  exact (div_le_div_iff_of_pos_right log_two_pos).mpr hnum

end General

/-! ## 2. The hyperbola count over a finite field -/

section Field

variable {F : Type*} [Field F] [Fintype F] [DecidableEq F]

/-- **The affine hyperbola `xy = n`, `n ≠ 0`, has exactly `q - 1` points.** -/
theorem card_hyperbola_ne_zero {n : F} (hn : n ≠ 0) :
    (univ.filter fun v : F × F => v.1 * v.2 = n).card = Fintype.card F - 1 := by
  have hcard : (univ.erase (0 : F)).card = Fintype.card F - 1 := by
    rw [Finset.card_erase_of_mem (mem_univ _), Finset.card_univ]
  rw [← hcard]
  refine (Finset.card_nbij' (i := fun x : F => (x, n * x⁻¹)) (j := fun v : F × F => v.1)
    ?_ ?_ ?_ ?_).symm
  · intro x hx
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_coe, Finset.mem_erase] at hx ⊢
    have hx0 : x ≠ 0 := hx.1
    refine ⟨mem_univ _, ?_⟩
    field_simp
  · intro v hv
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_coe, Finset.mem_erase,
      Finset.mem_univ, and_true, true_and] at hv ⊢
    intro h0
    exact hn (by rw [← hv, h0, zero_mul])
  · intro x hx
    rfl
  · intro v hv
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and] at hv
    have hv1 : v.1 ≠ 0 := by
      intro h0
      exact hn (by rw [← hv, h0, zero_mul])
    have : n * v.1⁻¹ = v.2 := by
      rw [← hv]
      field_simp
    exact Prod.ext rfl this

/-- **The degenerate conic `xy = 0` is a pair of lines with `2q - 1` points.** -/
theorem card_hyperbola_zero :
    (univ.filter fun v : F × F => v.1 * v.2 = 0).card = 2 * Fintype.card F - 1 := by
  classical
  set A : Finset (F × F) := univ.filter fun v : F × F => v.1 = 0 with hA
  set B : Finset (F × F) := univ.filter fun v : F × F => v.2 = 0 with hB
  have hApro : A = ({0} : Finset F) ×ˢ (univ : Finset F) := by
    ext ⟨x, y⟩; simp [hA, eq_comm]
  have hBpro : B = (univ : Finset F) ×ˢ ({0} : Finset F) := by
    ext ⟨x, y⟩; simp [hB, eq_comm]
  have hcardA : A.card = Fintype.card F := by
    rw [hApro, Finset.card_product, Finset.card_singleton, Finset.card_univ, one_mul]
  have hcardB : B.card = Fintype.card F := by
    rw [hBpro, Finset.card_product, Finset.card_singleton, Finset.card_univ, mul_one]
  have hinter : A ∩ B = {((0 : F), (0 : F))} := by
    ext v
    simp only [Finset.mem_inter, hA, hB, Finset.mem_filter, Finset.mem_univ, true_and,
      Finset.mem_singleton, Prod.ext_iff]
  have hunion : (univ.filter fun v : F × F => v.1 * v.2 = 0) = A ∪ B := by
    ext v
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_union, hA, hB,
      mul_eq_zero]
  have hkey := Finset.card_union_add_card_inter A B
  rw [hinter, Finset.card_singleton, hcardA, hcardB] at hkey
  rw [hunion]
  omega

end Field

/-! ## 3. The uniform factor battery -/

section Uniform

variable {F : Type*} [Field F] [Fintype F] [DecidableEq F] [Invertible (2 : F)]

/-- The uniform factor battery: the population is *all* pairs of residues, each once. -/
def unifP : F × F → F := Prod.fst

/-- The second factor of the uniform factor battery. -/
def unifQ : F × F → F := Prod.snd

omit [Field F] [DecidableEq F] [Invertible (2:F)] in
theorem card_pop : Fintype.card (F × F) = Fintype.card F * Fintype.card F :=
  Fintype.card_prod F F

omit [Invertible (2:F)] in
theorem cnt_productView (n : F) :
    cnt (productView (unifP (F := F)) unifQ) n
      = (univ.filter fun v : F × F => v.1 * v.2 = n).card := by
  rw [cnt, fib_eq_filter]
  rfl

theorem cnt_residueView (v : F × F) :
    cnt (residueView (unifP (F := F)) unifQ) (residueView unifP unifQ v) = 1 := by
  rw [cnt, fib_eq_filter, Finset.card_eq_one]
  refine ⟨v, ?_⟩
  ext w
  simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_singleton]
  constructor
  · intro h
    exact sd_injective (a₁ := w) (a₂ := v) h
  · intro h; rw [h]

/-- **The joint residue view of the uniform battery is a faithful code**: its entropy is
`log q²`, the full population entropy. -/
theorem H_residueView_uniform :
    H (residueView (unifP (F := F)) unifQ)
      = Real.log ((Fintype.card F : ℝ) * (Fintype.card F : ℝ)) := by
  have hne : Nonempty (F × F) := ⟨(0, 0)⟩
  have h : ∀ a ∈ img (residueView (unifP (F := F)) unifQ),
      cnt (residueView (unifP (F := F)) unifQ) a = 1 := by
    intro a ha
    obtain ⟨v, rfl⟩ := mem_img.1 ha
    exact cnt_residueView v
  have hH := H_eq_log_sub_log_of_uniform (residueView (unifP (F := F)) unifQ) 1 (by norm_num) h
  rw [hH, card_pop]
  push_cast
  simp

omit [Invertible (2:F)] in
/-- **The product view of the uniform battery, in closed form.**  One degenerate fibre of size
`2q - 1` and `q - 1` hyperbolic fibres of size `q - 1`. -/
theorem H_productView_uniform :
    H (productView (unifP (F := F)) unifQ)
      = phi (Fintype.card F * Fintype.card F) (2 * Fintype.card F - 1)
        + (Fintype.card F - 1) * phi (Fintype.card F * Fintype.card F) (Fintype.card F - 1) := by
  classical
  have hsurj : img (productView (unifP (F := F)) unifQ) = univ := by
    ext n
    simp only [Finset.mem_univ, iff_true]
    exact mem_img.2 ⟨(1, n), by simp [productView, unifP, unifQ]⟩
  have hsum : H (productView (unifP (F := F)) unifQ)
      = ∑ n : F, phi (Fintype.card (F × F)) (cnt (productView (unifP (F := F)) unifQ) n) := by
    rw [H_eq_sum_phi, hsurj]
  rw [hsum, card_pop]
  rw [← Finset.sum_erase_add univ _ (mem_univ (0 : F))]
  have hzero : cnt (productView (unifP (F := F)) unifQ) 0 = 2 * Fintype.card F - 1 := by
    rw [cnt_productView]; exact card_hyperbola_zero
  have hother : ∀ n ∈ univ.erase (0 : F),
      phi (Fintype.card F * Fintype.card F) (cnt (productView (unifP (F := F)) unifQ) n)
        = phi (Fintype.card F * Fintype.card F) (Fintype.card F - 1) := by
    intro n hn
    have hn0 : n ≠ 0 := (Finset.mem_erase.1 hn).1
    rw [cnt_productView, card_hyperbola_ne_zero hn0]
  rw [Finset.sum_congr rfl hother, Finset.sum_const, hzero,
    Finset.card_erase_of_mem (mem_univ _), Finset.card_univ, nsmul_eq_mul]
  have hq : 1 ≤ Fintype.card F := Fintype.card_pos
  rw [Nat.cast_sub hq, Nat.cast_one]
  ring

/-- **The hyperbola ceiling.**  For the uniform factor battery over a finite field of odd
characteristic and **any** labelling of it, the factor-residue hint value is bounded by an
explicit function of `q` alone: the entropy defect created by the degenerate conic `xy = 0`
together with the `q - 1`-point hyperbolae. -/
theorem hintValue_uniform_le {Λ : Type*} (L : F × F → Λ) :
    hintValue L (unifP (F := F)) unifQ
      ≤ (Real.log ((Fintype.card F : ℝ) * (Fintype.card F : ℝ))
          - (phi (Fintype.card F * Fintype.card F) (2 * Fintype.card F - 1)
            + (Fintype.card F - 1)
              * phi (Fintype.card F * Fintype.card F) (Fintype.card F - 1))) / Real.log 2 := by
  have h := hintValue_le_entropy_gap L (unifP (F := F)) unifQ
  rwa [Hb, Hb, H_residueView_uniform, H_productView_uniform, div_sub_div_same] at h

end Uniform

/-! ## 4. The modulus of the experiment -/

instance : Fact (Nat.Prime 31) := ⟨by norm_num⟩

/-- At the round-29 modulus the population of factor pairs has `961` members and the joint
residue view codes all of them faithfully: its entropy is `log 961` nats, i.e. `log₂ 961` bits,
the full 10-bit hint. -/
theorem residue_entropy_at_31 :
    H (residueView (unifP (F := ZMod 31)) unifQ) = Real.log 961 :=
  (H_residueView_uniform (F := ZMod 31)).trans (by norm_num [ZMod.card])

end SumDiffUniform