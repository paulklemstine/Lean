import Cryptography.NonabelianTypeChannel.GroupChannel

/-!
# `AGL(1,8)` as a genuine permutation group of the eight points of `𝔽₈`

The first object of the splitting-type catalog whose abelianization has order `> 4`.

We realise the field `𝔽₈ = 𝔽₂[x]/(x³ + x + 1)` on the carrier `Fin 8` (bit `i` of the
label is the coefficient of `xⁱ`): addition is `xor`, multiplication is carry-less
multiplication reduced modulo `x³ + x + 1`.  The element `x` (label `2`) is primitive, and
`gpow e = xᵉ` for `e : Fin 7` lists `𝔽₈ˣ`.

The affine group `AGL(1,8) = 𝔽₈ ⋊ 𝔽₈ˣ` is then the finite set `aglSet` of the 56
permutations `aff e b : t ↦ xᵉ · t + b` of `Fin 8`, inside the honest group
`Equiv.Perm (Fin 8)`.

## Main results

* `aff_mul`, `aff_inv`, `aff_one` — the affine composition law, proved pointwise.
* `aglSet_isSubgroup` — `AGL(1,8)` is a subgroup of `Sym(𝔽₈)`, with `aglSet_card : 56`.
* `aglDerived` — the translation group `C₂³ = transSet` (order 8) is **exactly** the
  derived subgroup: every commutator is a translation and every translation is a
  commutator (a certificate `TypeChannel.IsDerivedFinset`).
* `aglCoset_isCosetReadout` — the readout `aglCoset σ = log_x (σ 1 + σ 0)`, defined on *all*
  permutations, has the cosets of `[G,G]` as level sets: it is the abelianization
  `G → G^ab = C₇`, i.e. the residue `p mod 7` attached to the radical field.
* `aglType` (the cycle type) is a class function of the whole symmetric group
  (`aglType_conj`), and `aglType_aff` evaluates it: `[1⁸]`, `[2⁴]` or `[1,7]`
  (Mathlib's `cycleType` omits fixed points, so these are `0`, `{2,2,2,2}`, `{7}`).
-/

namespace AGL8

open Finset Equiv

/-! ## 1. The field `𝔽₈` on `Fin 8` -/

/-- Addition in `𝔽₈`: bitwise `xor` of the labels. -/
def fadd (s t : Fin 8) : Fin 8 := ⟨(s.val ^^^ t.val) % 8, Nat.mod_lt _ (by norm_num)⟩

/-- Carry-less product of two labels (a polynomial of degree `≤ 4` over `𝔽₂`). -/
def clmul (s t : ℕ) : ℕ :=
  (if t.testBit 0 then s else 0) ^^^ (if t.testBit 1 then 2 * s else 0) ^^^
    (if t.testBit 2 then 4 * s else 0)

/-- Reduction modulo `x³ + x + 1`: first kill `x⁴ = x² + x`, then `x³ = x + 1`. -/
def reduce (r : ℕ) : ℕ :=
  let r₁ := if r.testBit 4 then r ^^^ 22 else r
  if r₁.testBit 3 then r₁ ^^^ 11 else r₁

/-- Multiplication in `𝔽₈ = 𝔽₂[x]/(x³+x+1)`. -/
def fmul (s t : Fin 8) : Fin 8 := ⟨reduce (clmul s.val t.val) % 8, Nat.mod_lt _ (by norm_num)⟩

/-- The powers of the primitive element `x` (label `2`): `gpow e = xᵉ`. -/
def gpow (e : Fin 7) : Fin 8 := ![1, 2, 4, 3, 6, 7, 5] e

/-- The discrete logarithm to base `x`, the inverse of `gpow` on `𝔽₈ˣ`. -/
def dlog (s : Fin 8) : Fin 7 := ![0, 0, 1, 3, 2, 6, 4, 5] s

lemma fmul_gpow_gpow : ∀ e e' : Fin 7, fmul (gpow e) (gpow e') = gpow (e + e') := by decide

lemma gpow_succ_eq : ∀ e : Fin 7, fmul 2 (gpow e) = gpow (e + 1) := by decide

lemma dlog_gpow : ∀ e : Fin 7, dlog (gpow e) = e := by decide

lemma fadd_comm : ∀ s t : Fin 8, fadd s t = fadd t s := by decide

lemma fadd_assoc : ∀ s t u : Fin 8, fadd (fadd s t) u = fadd s (fadd t u) := by decide

lemma fadd_zero : ∀ s : Fin 8, fadd s 0 = s := by decide

lemma fadd_self : ∀ s : Fin 8, fadd s s = 0 := by decide

lemma fmul_assoc : ∀ s t u : Fin 8, fmul (fmul s t) u = fmul s (fmul t u) := by decide

lemma fmul_fadd : ∀ s t u : Fin 8, fmul s (fadd t u) = fadd (fmul s t) (fmul s u) := by decide

lemma fmul_one : ∀ s : Fin 8, fmul 1 s = s := by decide

/-- `x` really is primitive: it has multiplicative order `7`, and `x³ = x + 1`. -/
lemma x_cubed : fmul 2 (fmul 2 2) = fadd 2 1 := by decide

/-! ## 2. The affine permutations -/

/-- The affine map `t ↦ xᵉ · t + b` as a bijection of `𝔽₈`. -/
def aff (e : Fin 7) (b : Fin 8) : Perm (Fin 8) where
  toFun t := fadd (fmul (gpow e) t) b
  invFun t := fmul (gpow (-e)) (fadd t b)
  left_inv := by
    intro t
    revert t; revert e b; decide
  right_inv := by
    intro t
    revert t; revert e b; decide

@[simp] lemma aff_apply (e : Fin 7) (b t : Fin 8) :
    aff e b t = fadd (fmul (gpow e) t) b := rfl

/-- The affine composition law `(xᵉ·, b) ∘ (xᵉ'·, b') = (x^{e+e'}·, xᵉ b' + b)`. -/
theorem aff_mul (e e' : Fin 7) (b b' : Fin 8) :
    aff e b * aff e' b' = aff (e + e') (fadd (fmul (gpow e) b') b) := by
  ext t
  simp only [Perm.mul_apply, aff_apply]
  rw [fmul_fadd, ← fmul_assoc, fmul_gpow_gpow, fadd_assoc]

/-- The identity is the affine map `(1, 0)`. -/
theorem aff_one : aff 0 0 = 1 := by
  ext t
  revert t; decide

/-- Inverses of affine maps are affine. -/
theorem aff_inv (e : Fin 7) (b : Fin 8) :
    (aff e b)⁻¹ = aff (-e) (fmul (gpow (-e)) b) := by
  rw [inv_eq_iff_mul_eq_one, aff_mul, ← aff_one]
  congr 1
  · simp
  · rw [← fmul_assoc, fmul_gpow_gpow]
    revert e b; decide

/-- Two affine maps agree only if their parameters agree. -/
theorem aff_injective2 : ∀ e e' : Fin 7, ∀ b b' : Fin 8,
    (∀ t, aff e b t = aff e' b' t) → e = e' ∧ b = b' := by
  intro e e' b b' h
  have h0 := h 0
  have h1 := h 1
  simp only [aff_apply] at h0 h1
  revert h0 h1; revert e e' b b'; decide

/-! ## 3. The group `AGL(1,8)` and its derived subgroup -/

/-- The parameter space `𝔽₈ˣ × 𝔽₈`, written as `Fin 7 × Fin 8`. -/
def params : Finset (Fin 7 × Fin 8) := univ

/-- The parameter map. -/
def affP (p : Fin 7 × Fin 8) : Perm (Fin 8) := aff p.1 p.2

/-- The parameter map `(e, b) ↦ aff e b` is injective. -/
theorem aff_inj : Function.Injective affP := by
  rintro ⟨e, b⟩ ⟨e', b'⟩ h
  have := aff_injective2 e e' b b' (fun t => by simp only [affP] at h; rw [h])
  simp [this.1, this.2]

/-- `AGL(1,8)` as a finite set of permutations of `𝔽₈`. -/
def aglSet : Finset (Perm (Fin 8)) := params.image affP

/-- The translation subgroup `{t ↦ t + b} ≅ C₂³`. -/
def transSet : Finset (Perm (Fin 8)) := (univ : Finset (Fin 8)).image (fun b => aff 0 b)

lemma mem_aglSet {σ : Perm (Fin 8)} : σ ∈ aglSet ↔ ∃ e b, σ = aff e b := by
  simp only [aglSet, params, affP, mem_image, mem_univ, true_and, Prod.exists]
  constructor
  · rintro ⟨e, b, rfl⟩; exact ⟨e, b, rfl⟩
  · rintro ⟨e, b, rfl⟩; exact ⟨e, b, rfl⟩

lemma mem_transSet {σ : Perm (Fin 8)} : σ ∈ transSet ↔ ∃ b, σ = aff 0 b := by
  simp only [transSet, mem_image, mem_univ, true_and]
  constructor
  · rintro ⟨b, rfl⟩; exact ⟨b, rfl⟩
  · rintro ⟨b, rfl⟩; exact ⟨b, rfl⟩

lemma aff_mem (e : Fin 7) (b : Fin 8) : aff e b ∈ aglSet := mem_aglSet.mpr ⟨e, b, rfl⟩

theorem aglSet_card : aglSet.card = 56 := by
  rw [aglSet, card_image_of_injective _ aff_inj]
  rfl

theorem transSet_card : transSet.card = 8 := by
  rw [transSet, card_image_of_injective]
  · rfl
  · intro b b' h
    exact (aff_injective2 0 0 b b' (fun t => by simp only at h; rw [h])).2

/-- **`AGL(1,8)` is a group of permutations.** -/
theorem aglSet_isSubgroup : TypeChannel.IsSubgroupFinset aglSet where
  one_mem := by rw [← aff_one]; exact aff_mem 0 0
  mul_mem := by
    intro σ hσ τ hτ
    obtain ⟨e, b, rfl⟩ := mem_aglSet.mp hσ
    obtain ⟨e', b', rfl⟩ := mem_aglSet.mp hτ
    rw [aff_mul]; exact aff_mem _ _
  inv_mem := by
    intro σ hσ
    obtain ⟨e, b, rfl⟩ := mem_aglSet.mp hσ
    rw [aff_inv]; exact aff_mem _ _

/-- The translations form a group. -/
theorem transSet_isSubgroup : TypeChannel.IsSubgroupFinset transSet where
  one_mem := by rw [← aff_one]; exact mem_transSet.mpr ⟨0, rfl⟩
  mul_mem := by
    intro σ hσ τ hτ
    obtain ⟨b, rfl⟩ := mem_transSet.mp hσ
    obtain ⟨b', rfl⟩ := mem_transSet.mp hτ
    rw [aff_mul]; exact mem_transSet.mpr ⟨_, by rw [add_zero]⟩
  inv_mem := by
    intro σ hσ
    obtain ⟨b, rfl⟩ := mem_transSet.mp hσ
    rw [aff_inv]; exact mem_transSet.mpr ⟨_, by rw [neg_zero]⟩

lemma transSet_subset : transSet ⊆ aglSet := by
  intro σ hσ
  obtain ⟨b, rfl⟩ := mem_transSet.mp hσ
  exact aff_mem 0 b

/-- Every translation `t ↦ t + s` is the commutator `[x·, t ↦ t + d]` with
`d = s / (x + 1)`, i.e. `(x+1) d = s`. -/
lemma translation_is_commutator : ∀ s : Fin 8, ∃ d : Fin 8,
    fadd (fmul (gpow 1) (fmul (gpow (-1)) d)) (fmul (gpow 1) d) = s := by decide

/-- **The derived subgroup of `AGL(1,8)` is the translation group `C₂³`.** -/
theorem aglDerived : TypeChannel.IsDerivedFinset aglSet transSet where
  subset := transSet_subset
  commutator_mem := by
    intro σ hσ τ hτ
    obtain ⟨e, b, rfl⟩ := mem_aglSet.mp hσ
    obtain ⟨e', b', rfl⟩ := mem_aglSet.mp hτ
    rw [aff_inv, aff_inv, aff_mul, aff_mul, aff_mul]
    have hexp : e + e' + -e + -e' = 0 := by abel
    rw [hexp]
    exact mem_transSet.mpr ⟨_, rfl⟩
  mem_commutator := by
    intro σ hσ
    obtain ⟨s, rfl⟩ := mem_transSet.mp hσ
    obtain ⟨d, hd⟩ := translation_is_commutator s
    refine ⟨aff 1 0, aff_mem _ _, aff 0 d, aff_mem _ _, ?_⟩
    rw [aff_inv, aff_inv, aff_mul, aff_mul, aff_mul]
    congr 1
    clear hσ; subst hd; revert d; decide

/-! ## 4. The abelianization readout `G → C₇` -/

/-- The abelianization readout, defined on every permutation of `𝔽₈`: the discrete log of
the slope `σ 1 - σ 0` (in characteristic two, `σ 1 + σ 0`).  On `AGL(1,8)` it is the
multiplier exponent, i.e. the image in `G^ab = 𝔽₈ˣ ≅ C₇`. -/
def aglCoset (σ : Perm (Fin 8)) : Fin 7 := dlog (fadd (σ 1) (σ 0))

@[simp] theorem aglCoset_aff : ∀ (e : Fin 7) (b : Fin 8), aglCoset (aff e b) = e := by
  unfold aglCoset; simp only [aff_apply]; decide

/-- The abelianization readout is a homomorphism `AGL(1,8) → ℤ/7`. -/
theorem aglCoset_mul {σ τ : Perm (Fin 8)} (hσ : σ ∈ aglSet) (hτ : τ ∈ aglSet) :
    aglCoset (σ * τ) = aglCoset σ + aglCoset τ := by
  obtain ⟨e, b, rfl⟩ := mem_aglSet.mp hσ
  obtain ⟨e', b', rfl⟩ := mem_aglSet.mp hτ
  rw [aff_mul]; simp

lemma aglCoset_eq_zero_iff {σ : Perm (Fin 8)} (hσ : σ ∈ aglSet) :
    aglCoset σ = 0 ↔ σ ∈ transSet := by
  obtain ⟨e, b, rfl⟩ := mem_aglSet.mp hσ
  rw [aglCoset_aff, mem_transSet]
  constructor
  · rintro rfl; exact ⟨b, rfl⟩
  · rintro ⟨b', h⟩
    exact (aff_injective2 e 0 b b' (fun t => by rw [h])).1

/-- **The level sets of `aglCoset` are exactly the cosets of `[G,G] = C₂³`.** -/
theorem aglCoset_isCosetReadout : TypeChannel.IsCosetReadout aglSet transSet aglCoset := by
  intro σ hσ τ hτ
  have hτi : τ⁻¹ ∈ aglSet := aglSet_isSubgroup.inv_mem _ hτ
  rw [← aglCoset_eq_zero_iff (aglSet_isSubgroup.mul_mem _ hσ _ hτi), aglCoset_mul hσ hτi]
  have hinv : aglCoset τ⁻¹ = - aglCoset τ := by
    have h1 := aglCoset_mul hτ hτi
    rw [mul_inv_cancel, ← aff_one, aglCoset_aff] at h1
    rw [eq_neg_iff_add_eq_zero, add_comm, ← h1]
  rw [hinv, ← sub_eq_add_neg, sub_eq_zero]

/-- `G^ab` has seven elements: the abelianization cap is `log₂ 7`. -/
theorem aglCoset_image_card : (aglSet.image aglCoset).card = 7 := by
  have : aglSet.image aglCoset = univ := by
    ext e
    simp only [mem_image, mem_univ, iff_true]
    exact ⟨aff e 0, aff_mem e 0, aglCoset_aff e 0⟩
  rw [this]; rfl

/-! ## 5. The splitting-type readout: cycle type on the eight points -/

/-- The splitting-type readout: the cycle type of `σ` on the eight points of `𝔽₈`
(Mathlib convention: fixed points are omitted). -/
def aglType (σ : Perm (Fin 8)) : Multiset ℕ := σ.cycleType

/-- **The type readout is a class function** — invariant under conjugation by *every*
permutation of the eight points, a fortiori by `AGL(1,8)`. -/
theorem aglType_conj (σ τ : Perm (Fin 8)) : aglType (τ * σ * τ⁻¹) = aglType σ :=
  Perm.cycleType_conj

/-- A permutation of prime order `p` whose support has `k · p` points has cycle type
`p^k`. -/
lemma cycleType_of_prime_pow_eq_one {σ : Perm (Fin 8)} {p k : ℕ} [hp : Fact p.Prime]
    (hpow : σ ^ p = 1) (hne : σ ≠ 1) (hsupp : σ.support.card = k * p) :
    σ.cycleType = Multiset.replicate k p := by
  have hord : orderOf σ = p := orderOf_eq_prime hpow hne
  obtain ⟨n, hn⟩ := Perm.cycleType_prime_order (hord ▸ hp.out)
  rw [hord] at hn
  have hsum := Perm.sum_cycleType σ
  rw [hn, Multiset.sum_replicate, smul_eq_mul, hsupp] at hsum
  have hk : n + 1 = k := Nat.eq_of_mul_eq_mul_right hp.out.pos hsum
  rw [hn, hk]

set_option maxRecDepth 100000 in
lemma aff_pow_seven : ∀ (e : Fin 7) (b : Fin 8), e ≠ 0 → (aff e b) ^ 7 = 1 := by
  intro e b he
  ext t
  revert t; revert e b; decide +kernel

set_option maxRecDepth 100000 in
lemma aff_pow_two : ∀ b : Fin 8, (aff 0 b) ^ 2 = 1 := by
  intro b; ext t; revert t; revert b; decide +kernel

lemma aff_support_seven : ∀ (e : Fin 7) (b : Fin 8), e ≠ 0 → (aff e b).support.card = 7 := by
  decide

lemma aff_support_eight : ∀ b : Fin 8, b ≠ 0 → (aff 0 b).support.card = 8 := by
  decide

lemma aff_ne_one_of_exp {e : Fin 7} (b : Fin 8) (he : e ≠ 0) : aff e b ≠ 1 := by
  intro h
  rw [← aff_one] at h
  exact he (aff_injective2 e 0 b 0 (fun t => by rw [h])).1

lemma aff_ne_one_of_trans {b : Fin 8} (hb : b ≠ 0) : aff 0 b ≠ 1 := by
  intro h
  rw [← aff_one] at h
  exact hb (aff_injective2 0 0 b 0 (fun t => by rw [h])).2

/-- The three cycle types of `AGL(1,8)` on `𝔽₈`, as a function of the parameters. -/
def typeCode (p : Fin 7 × Fin 8) : Multiset ℕ :=
  if p.1 = 0 then (if p.2 = 0 then 0 else {2, 2, 2, 2}) else {7}

/-- **Evaluation of the type readout.**  The identity has type `[1⁸]`, the seven non-trivial
translations have type `[2⁴]`, and every element with non-trivial multiplier — which has
exactly one fixed point — has type `[1,7]`. -/
theorem aglType_aff (e : Fin 7) (b : Fin 8) : aglType (aff e b) = typeCode (e, b) := by
  unfold aglType typeCode
  by_cases he : e = 0
  · subst he
    by_cases hb : b = 0
    · subst hb; simp [aff_one]
    · haveI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
      simp only [hb, if_true, if_false]
      rw [cycleType_of_prime_pow_eq_one (k := 4) (aff_pow_two b) (aff_ne_one_of_trans hb)
        (by rw [aff_support_eight b hb])]
      rfl
  · haveI : Fact (Nat.Prime 7) := ⟨by norm_num⟩
    simp only [he, if_false]
    rw [cycleType_of_prime_pow_eq_one (k := 1) (aff_pow_seven e b he) (aff_ne_one_of_exp b he)
      (by rw [aff_support_seven e b he])]
    rfl

end AGL8