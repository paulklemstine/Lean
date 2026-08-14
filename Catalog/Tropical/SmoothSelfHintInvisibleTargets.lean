import Tropical.SmoothSelfHintSubgroupTargets

/-!
# Which targets are invisible?  The abelian answer: only the trivial ones

`miF_symJointG_eq_zero_iff_autocorrelation` reduced the question "for which target sets
`A ⊆ G` is the symmetric divisibility statistic invisible?" to a purely combinatorial
condition: the autocorrelation `n ↦ |A ∩ n·A⁻¹|` must be constant.  The subgroup file
showed that proper subgroups (hence the quadratic-residue and `k`-th-power targets) never
satisfy it.  This file settles the question completely for **commutative** groups — the
case of arithmetic interest, since the divisibility events of Paper 54 live in the cyclic
group `(ZMod l)ˣ`.

The autocorrelation is the representation function
`reprCount A n = #{(a, b) ∈ A × A : a·b = n}` (`autocorrelation_eq_reprCount`), and the
theorem is:

* `SmoothSelfHint.reprCount_const_iff_trivial` — in a finite commutative group,
  `reprCount A` is constant **iff** `A = ∅` or `A = univ`.

The proof is Fourier-analytic: writing `S(ψ) = ∑_{a ∈ A} ψ(a)` for an additive character
`ψ` of `Additive G`, the identity `S(ψ)² = ∑_n reprCount A n · ψ(n)`
(`charSum_sq_eq_reprCount_sum`) shows that constancy of `reprCount` forces `S(ψ)² = 0`,
hence `S(ψ) = 0`, for every nontrivial `ψ`; Fourier inversion
(`AddChar.sum_apply_eq_ite`) then makes the indicator function of `A` constant.

Consequences:

* `SmoothSelfHint.miF_symJointG_eq_zero_iff_trivial` — **the classification of invisible
  targets in the abelian case**: the symmetric leak vanishes iff `A` is `∅` or everything.
* `SmoothSelfHint.miF_symJointG_pos_of_nontrivial` — every nontrivial target leaks.
* `SmoothSelfHint.abelian_dichotomy` — the sharp form of the asymmetric/symmetric
  dichotomy: for *every* target the asymmetric leak is `0`, and for every *nontrivial*
  target the symmetric leak is `> 0`.
* `SmoothSelfHint.miF_symJointG_pos_units_of_nontrivial` — the arithmetic corollary in
  `(ZMod l)ˣ`: no nontrivial divisibility-type event on the factors is invisible.
-/

open Finset

namespace SmoothSelfHint

section CommGroup

variable {G : Type*} [CommGroup G] [Fintype G] [DecidableEq G]

/-- The representation function of `A`: the number of ordered factorisations `n = a · b`
with **both** factors in `A`.  It is counted here in the equivalent form
`#{a ∈ A : n·a⁻¹ ∈ A}`. -/
def reprCount (A : Finset G) (n : G) : ℕ := (A.filter (fun a => n * a⁻¹ ∈ A)).card

omit [Fintype G] in
/-- The autocorrelation appearing in the classification theorem *is* the representation
function. -/
theorem autocorrelation_eq_reprCount (A : Finset G) (n : G) :
    (A ∩ A.image (fun b => n * b⁻¹)).card = reprCount A n := by
  unfold reprCount
  congr 1
  ext a
  simp only [Finset.mem_inter, Finset.mem_image, Finset.mem_filter]
  constructor
  · rintro ⟨ha, b, hb, hba⟩
    refine ⟨ha, ?_⟩
    have : n * a⁻¹ = b := by
      rw [← hba]; simp
    rw [this]; exact hb
  · rintro ⟨ha, hna⟩
    exact ⟨ha, n * a⁻¹, hna, by simp⟩

omit [Fintype G] in
/-- The fibre of the multiplication map over `n`, restricted to `A × A`, has
`reprCount A n` elements. -/
theorem card_prod_fiber_eq_reprCount (A : Finset G) (n : G) :
    ((A ×ˢ A).filter (fun p : G × G => p.1 * p.2 = n)).card = reprCount A n := by
  unfold reprCount
  apply Finset.card_bij (fun p _ => p.1)
  · intro p hp
    simp only [Finset.mem_filter, Finset.mem_product] at hp ⊢
    refine ⟨hp.1.1, ?_⟩
    have h : n * p.1⁻¹ = p.2 := by rw [← hp.2]; simp
    rw [h]; exact hp.1.2
  · intro p hp q hq hpq
    simp only [Finset.mem_filter, Finset.mem_product] at hp hq
    have h : p.1 * p.2 = q.1 * q.2 := by rw [hp.2, hq.2]
    rw [hpq] at h
    exact Prod.ext hpq (mul_left_cancel h)
  · intro a ha
    simp only [Finset.mem_filter] at ha
    refine ⟨(a, n * a⁻¹), ?_, rfl⟩
    simp only [Finset.mem_filter, Finset.mem_product]
    exact ⟨⟨ha.1, ha.2⟩, by simp [mul_left_comm]⟩

/-! ### Fourier analysis on the additive shadow of `G` -/

omit [CommGroup G] [DecidableEq G] in
theorem card_additive_eq : Fintype.card (Additive G) = Fintype.card G :=
  Fintype.card_congr (Additive.ofMul).symm

omit [DecidableEq G] in
/-- Orthogonality: a nontrivial character sums to zero over the group. -/
theorem sum_char_eq_ite (ψ : AddChar (Additive G) ℂ) :
    ∑ n : G, ψ (Additive.ofMul n) = if ψ = 0 then (Fintype.card G : ℂ) else 0 := by
  classical
  have h : ∑ m : Additive G, ψ m = if ψ = 0 then (Fintype.card (Additive G) : ℂ) else 0 :=
    AddChar.sum_eq_ite ψ
  rw [card_additive_eq] at h
  rw [← h]
  exact Fintype.sum_equiv Additive.ofMul _ _ (fun _ => rfl)

/-- Fourier inversion in the form we need: summing a fixed group element over *all*
characters detects whether that element is the identity. -/
theorem sum_over_chars_eq_ite (g : G) :
    ∑ ψ : AddChar (Additive G) ℂ, ψ (Additive.ofMul g)
      = if g = 1 then (Fintype.card G : ℂ) else 0 := by
  classical
  have h := AddChar.sum_apply_eq_ite (α := Additive G) (Additive.ofMul g)
  rw [card_additive_eq] at h
  rw [h]
  have hiff : (Additive.ofMul g = 0) ↔ g = 1 :=
    ⟨fun hh => Additive.ofMul.injective hh, fun hh => by rw [hh]; rfl⟩
  simp only [hiff]

/-- The square of a character sum is the Fourier transform of the representation
function.  This is the analytic heart of the classification. -/
theorem charSum_sq_eq_reprCount_sum (A : Finset G) (ψ : AddChar (Additive G) ℂ) :
    (∑ a ∈ A, ψ (Additive.ofMul a)) ^ 2
      = ∑ n : G, (reprCount A n : ℂ) * ψ (Additive.ofMul n) := by
  have h1 : (∑ a ∈ A, ψ (Additive.ofMul a)) ^ 2
      = ∑ p ∈ A ×ˢ A, ψ (Additive.ofMul (p.1 * p.2)) := by
    rw [sq, Finset.sum_mul_sum, Finset.sum_product]
    exact Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by
      rw [ofMul_mul, AddChar.map_add_eq_mul]
  rw [h1, ← Finset.sum_fiberwise' (A ×ˢ A) (fun p : G × G => p.1 * p.2)
      (fun n => ψ (Additive.ofMul n))]
  refine Finset.sum_congr rfl fun n _ => ?_
  rw [Finset.sum_const, card_prod_fiber_eq_reprCount, nsmul_eq_mul]

/-- If the representation function is constant then every nontrivial character sum over
`A` vanishes: `A` has *flat* Fourier transform off the trivial character. -/
theorem charSum_eq_zero_of_reprCount_const (A : Finset G) (c : ℕ)
    (hc : ∀ n : G, reprCount A n = c) (ψ : AddChar (Additive G) ℂ) (hψ : ψ ≠ 0) :
    ∑ a ∈ A, ψ (Additive.ofMul a) = 0 := by
  have h := charSum_sq_eq_reprCount_sum A ψ
  simp_rw [hc] at h
  rw [← Finset.mul_sum, sum_char_eq_ite ψ, if_neg hψ, mul_zero] at h
  exact (pow_eq_zero_iff (n := 2) (by norm_num)).mp h

/-- Fourier inversion applied to a set with constant representation function: its
indicator function is constant, i.e. `|G|·1_A(g) = |A|` for every `g`. -/
theorem card_mul_indicator_of_reprCount_const (A : Finset G) (c : ℕ)
    (hc : ∀ n : G, reprCount A n = c) (g : G) :
    (if g ∈ A then (Fintype.card G : ℂ) else 0) = (A.card : ℂ) := by
  classical
  have h1 : ∑ a ∈ A, ∑ ψ : AddChar (Additive G) ℂ, ψ (Additive.ofMul (a * g⁻¹))
      = if g ∈ A then (Fintype.card G : ℂ) else 0 := by
    rw [Finset.sum_congr rfl (fun a _ => sum_over_chars_eq_ite (a * g⁻¹))]
    simp_rw [mul_inv_eq_one]
    exact Finset.sum_ite_eq' A g (fun _ => (Fintype.card G : ℂ))
  have h2 : ∑ ψ : AddChar (Additive G) ℂ, ∑ a ∈ A, ψ (Additive.ofMul (a * g⁻¹))
      = (A.card : ℂ) := by
    have hterm : ∀ ψ : AddChar (Additive G) ℂ, ∑ a ∈ A, ψ (Additive.ofMul (a * g⁻¹))
        = ψ (Additive.ofMul g⁻¹) * ∑ a ∈ A, ψ (Additive.ofMul a) := by
      intro ψ
      rw [Finset.mul_sum]
      exact Finset.sum_congr rfl fun a _ => by
        rw [ofMul_mul, AddChar.map_add_eq_mul, mul_comm]
    rw [Finset.sum_congr rfl (fun ψ _ => hterm ψ),
      Finset.sum_eq_single (0 : AddChar (Additive G) ℂ)]
    · simp
    · intro ψ _ hψ
      rw [charSum_eq_zero_of_reprCount_const A c hc ψ hψ, mul_zero]
    · intro h
      exact absurd (Finset.mem_univ _) h
  rw [← h1, Finset.sum_comm, h2]

/-- **Only the trivial targets are invisible.**  In a finite commutative group the
representation function `n ↦ #{(a,b) ∈ A² : ab = n}` is constant exactly when `A` is
empty or everything.  (Equivalently: no proper nonempty subset of an abelian group is a
"perfect sumset".) -/
theorem reprCount_const_iff_trivial (A : Finset G) :
    (∀ n m : G, reprCount A n = reprCount A m) ↔ (A = ∅ ∨ A = Finset.univ) := by
  constructor
  · intro h
    by_cases hA : A = ∅
    · exact Or.inl hA
    right
    obtain ⟨a₀, ha₀⟩ := Finset.nonempty_iff_ne_empty.mpr hA
    have hcard : 0 < A.card := Finset.card_pos.mpr ⟨a₀, ha₀⟩
    have hkey := card_mul_indicator_of_reprCount_const A (reprCount A 1)
      (fun n => h n 1)
    refine Finset.eq_univ_of_forall fun g => ?_
    by_contra hg
    have := hkey g
    rw [if_neg hg] at this
    have : (A.card : ℂ) = 0 := this.symm
    have : A.card = 0 := by exact_mod_cast this
    omega
  · rintro (rfl | rfl) <;> intro n m
    · simp [reprCount]
    · simp [reprCount]

/-- **Classification of invisible targets, abelian case.**  The symmetric leak of the
target `A` vanishes if and only if `A` is trivial.  Combined with `miF_asym_zero` (the
asymmetric leak is *always* zero) this is the sharpest possible form of the
asymmetric/symmetric dichotomy. -/
theorem miF_symJointG_eq_zero_iff_trivial (A : Finset G) :
    miF (symJointG A) = 0 ↔ (A = ∅ ∨ A = Finset.univ) := by
  rw [miF_symJointG_eq_zero_iff_autocorrelation]
  simp_rw [autocorrelation_eq_reprCount]
  exact reprCount_const_iff_trivial A

/-- Every nontrivial target leaks a strictly positive number of bits. -/
theorem miF_symJointG_pos_of_nontrivial (A : Finset G) (h₀ : A ≠ ∅) (h₁ : A ≠ Finset.univ) :
    0 < miF (symJointG A) := by
  rcases lt_or_eq_of_le
    (miF_nonneg (symJointG A) (symJointG_nonneg A) (symJointG_sum_one A))
    with h | h
  · exact h
  · exact absurd ((miF_symJointG_eq_zero_iff_trivial A).mp h.symm) (by tauto)

/-- **The abelian dichotomy.**  For a finite commutative group: the asymmetric statistic
leaks exactly `0` bits for *every* target, while the symmetric statistic leaks strictly
positive information for *every* target that is neither empty nor everything. -/
theorem abelian_dichotomy (A : Finset G) (h₀ : A ≠ ∅) (h₁ : A ≠ Finset.univ) :
    miF (jointAsym A) = 0 ∧ 0 < miF (symJointG A) :=
  ⟨miF_asym_zero A, miF_symJointG_pos_of_nontrivial A h₀ h₁⟩

end CommGroup

/-- The arithmetic corollary.  In `(ZMod l)ˣ` — the group where the divisibility events
`l ∣ x - 1`, "`x` is a quadratic residue", etc. live — *no* nontrivial event on the
factors is invisible from the product: every such event leaks. -/
theorem miF_symJointG_pos_units_of_nontrivial (l : ℕ) [Fact (Nat.Prime l)]
    (A : Finset (ZMod l)ˣ) (h₀ : A ≠ ∅) (h₁ : A ≠ Finset.univ) :
    0 < miF (symJointG A) :=
  miF_symJointG_pos_of_nontrivial A h₀ h₁

/-- The singleton case `A = {1}`, i.e. the event `l ∣ x - 1`, recovered from the general
classification for every odd prime `l`. -/
theorem miF_symJointG_pos_units_singleton (l : ℕ) [Fact (Nat.Prime l)] (hl : 2 < l) :
    0 < miF (symJointG ({1} : Finset (ZMod l)ˣ)) := by
  refine miF_symJointG_pos_units_of_nontrivial l _ (by simp) ?_
  intro h
  have hcard : ({1} : Finset (ZMod l)ˣ).card = Fintype.card (ZMod l)ˣ := by
    rw [h, Finset.card_univ]
  rw [Finset.card_singleton, card_units_zmod l] at hcard
  omega

end SmoothSelfHint