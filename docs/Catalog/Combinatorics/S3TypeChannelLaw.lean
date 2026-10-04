/-
# FIVE-FIELDS-ONE-LAW: the type channel of an `S₃` field at its conductor

The empirical "type-channel law" of the FACT programme reports, for five independent `S₃`
cubic fields (most recently `x³ - 4x + 1`, discriminant `229`), a mutual information
`I(p mod D ; T) ≈ 1` bit between the residue class of a prime `p` modulo the conductor
`D` and the splitting type `T(p)`.  This file proves the law *exactly*, in a form that
is independent of the field.

**Chebotarev model.**  Frobenius classes are uniform on `G = Gal`, residue classes uniform
on `R = (ℤ/D)ˣ`, and the two are coupled only through their common abelian quotient:
`ε(σ) = χ(r)` (for an `S₃` field: `sign σ = (p / D)`, the quadratic resolvent).  The joint
law is the uniform distribution on the fibre product `G ×_Δ R`.

Main results (all built on the counting entropy `uEnt / condEnt / mutInfo` of
`Shared.CyclicTypeChannel`):

* `mutInfo_fibreProd` — for *any* balanced `ε, χ` and any read-out `τ` through which `ε`
  factors, `I(τ ; r) = log₂ |Δ|` exactly;
* `mutInfo_fibreProd_hom` — the group form (surjective homomorphisms);
* `mutInfo_cycleType_eq_one` — every `S_n`, `n ≥ 2`: the cycle-type channel is one bit;
* `mutInfo_rootCount_eq_one`, `typeChannel_conductor_eq_one`, `typeChannel_229_eq_one` —
  the `S₃` root-count channel is one bit for every odd prime conductor, in particular `229`;
* `uEnt_fixCount_S3`, `condEnt_rootCount_S3` — the bit splits as
  `H(T) = 2/3 + ½ log₂ 3` and `H(T | class) = ½ log₂ 3 - 1/3`;
* `mutInfo_fibreProd_trivial` — the abelian boundary: a trivial quotient gives `0` bits.

The arithmetic input (that for `x³ - 4x + 1` the root count mod `p` really is coupled
to `p mod 229` through the Legendre symbol) is proved in
`Combinatorics.S3CubicConductor229`.
-/
import Shared.CyclicTypeChannelNonneg

namespace S3TypeChannel

open Finset CyclicTypeChannel

section FibreProduct

variable {G R Δ β : Type*} [Fintype G] [Fintype R] [DecidableEq G] [DecidableEq R]
  [DecidableEq Δ] [DecidableEq β]

/-- The fibre product `G ×_Δ R = {(σ, r) | ε σ = χ r}`. -/
def fibreProd (ε : G → Δ) (χ : R → Δ) : Finset (G × R) :=
  univ.filter (fun x => ε x.1 = χ x.2)

variable (ε : G → Δ) (χ : R → Δ)

omit [DecidableEq R] in
lemma card_filter_fibreProd (P : G → Prop) [DecidablePred P] :
    #{x ∈ fibreProd ε χ | P x.1} = ∑ σ ∈ univ.filter P, #{r | χ r = ε σ} := by
  rw [card_eq_sum_card_fiberwise (f := Prod.fst) (t := univ.filter P)
    (fun x hx => mem_filter.2 ⟨mem_univ _, (mem_filter.1 hx).2⟩)]
  refine sum_congr rfl fun σ hσ => ?_
  have hP : P σ := (mem_filter.1 hσ).2
  have h : {x ∈ {x ∈ fibreProd ε χ | P x.1} | x.1 = σ}
      = (univ.filter (fun r => χ r = ε σ)).map
          ⟨fun r => (σ, r), fun a b h => by simpa using h⟩ := by
    ext ⟨a, b⟩
    simp only [fibreProd, mem_filter, mem_univ, true_and, mem_map, Function.Embedding.coeFn_mk,
      Prod.mk.injEq]
    constructor
    · rintro ⟨⟨h1, _⟩, rfl⟩
      exact ⟨b, h1.symm, rfl, rfl⟩
    · rintro ⟨r, hr, rfl, rfl⟩
      exact ⟨⟨hr.symm, hP⟩, rfl⟩
  rw [h, card_map]

omit [DecidableEq G] in
lemma card_fibreProd_snd (c : R) :
    #{x ∈ fibreProd ε χ | x.2 = c} = #{σ | ε σ = χ c} := by
  have h : {x ∈ fibreProd ε χ | x.2 = c}
      = (univ.filter (fun σ => ε σ = χ c)).map
          ⟨fun σ => (σ, c), fun a b h => by simpa using h⟩ := by
    ext ⟨a, b⟩
    simp only [fibreProd, mem_filter, mem_univ, true_and, mem_map, Function.Embedding.coeFn_mk,
      Prod.mk.injEq]
    constructor
    · rintro ⟨h1, rfl⟩
      exact ⟨a, h1, rfl, rfl⟩
    · rintro ⟨σ, hσ, rfl, rfl⟩
      exact ⟨hσ, rfl⟩
  rw [h, card_map]

omit [DecidableEq G] in
lemma card_fibreProd_joint (τ : G → β) (c : R) (v : β) :
    #{x ∈ fibreProd ε χ | x.2 = c ∧ (τ ∘ Prod.fst) x = v} = #{σ | ε σ = χ c ∧ τ σ = v} := by
  have h : {x ∈ fibreProd ε χ | x.2 = c ∧ (τ ∘ Prod.fst) x = v}
      = (univ.filter (fun σ => ε σ = χ c ∧ τ σ = v)).map
          ⟨fun σ => (σ, c), fun a b h => by simpa using h⟩ := by
    ext ⟨a, b⟩
    simp only [fibreProd, mem_filter, mem_univ, true_and, mem_map, Function.Embedding.coeFn_mk,
      Prod.mk.injEq, Function.comp]
    constructor
    · rintro ⟨h1, rfl, h2⟩
      exact ⟨a, ⟨h1, h2⟩, rfl, rfl⟩
    · rintro ⟨σ, ⟨hσ, h2⟩, rfl, rfl⟩
      exact ⟨hσ, rfl, h2⟩
  rw [h, card_map]

/-- **The fibre-product law.**  Let `ε : G → Δ` and `χ : R → Δ` be balanced
(every fibre of `ε` has `A > 0` points, every fibre of `χ` has `B > 0` points), and let
`τ : G → β` be any read-out through which `ε` factors (`ε = e ∘ τ`).  On the uniform
fibre product `G ×_Δ R` the mutual information between `τ` and the `R`-coordinate is
exactly `log₂ |Δ|` bits, independently of `G`, `R`, `τ`, `A` and `B`. -/
theorem mutInfo_fibreProd [Fintype Δ] (τ : G → β) (e : β → Δ) (hτ : ∀ σ, e (τ σ) = ε σ)
    {A B : ℕ} (hA : ∀ d, #{σ | ε σ = d} = A) (hB : ∀ d, #{r | χ r = d} = B)
    (hA0 : 0 < A) (hB0 : 0 < B) :
    mutInfo (fibreProd ε χ) (τ ∘ Prod.fst) Prod.snd = Real.logb 2 (Fintype.card Δ) := by
  set s := fibreProd ε χ with hs_def
  -- the three marginal counts
  have hGcard : Fintype.card G = Fintype.card Δ * A := by
    rw [← card_univ, card_eq_sum_card_fiberwise (f := ε) (t := univ) (fun _ _ => mem_univ _)]
    simp [hA, mul_comm]
  have hN : s.card = Fintype.card Δ * A * B := by
    have h := card_filter_fibreProd ε χ (fun _ => True)
    simp only [filter_true_of_mem (fun _ _ => trivial), hB, sum_const, smul_eq_mul] at h
    rw [h, card_univ, hGcard]
  have hM : ∀ c, #{x ∈ s | x.2 = c} = A := fun c => by
    rw [card_fibreProd_snd, hA]
  have hm : ∀ v, #{x ∈ s | (τ ∘ Prod.fst) x = v} = #{σ | τ σ = v} * B := fun v => by
    have h := card_filter_fibreProd ε χ (fun σ => τ σ = v)
    simp only [hB, sum_const, smul_eq_mul] at h
    exact h
  -- the empty case
  rcases isEmpty_or_nonempty Δ with hΔ | hΔ
  · have h0 : s.card = 0 := by rw [hN, Fintype.card_eq_zero]; simp
    rw [card_eq_zero] at h0
    simp [mutInfo, condEnt, uEnt, h0, Fintype.card_eq_zero]
  have hΔpos : 0 < Fintype.card Δ := Fintype.card_pos
  have hNpos : 0 < s.card := by rw [hN]; positivity
  have hne : s.Nonempty := card_pos.1 hNpos
  have hNR : (0 : ℝ) < s.card := by exact_mod_cast hNpos
  -- every term of the Kullback–Leibler double sum equals `(n / N) log₂ |Δ|`
  have hterm : ∀ c ∈ s.image Prod.snd, ∀ v ∈ s.image (τ ∘ Prod.fst),
      ((#{x ∈ s | x.2 = c ∧ (τ ∘ Prod.fst) x = v} : ℝ) / s.card) *
        (Real.logb 2 (s.card : ℝ) - Real.logb 2 (#{x ∈ s | (τ ∘ Prod.fst) x = v} : ℝ)
          - Real.logb 2 (#{x ∈ s | x.2 = c} : ℝ)
          + Real.logb 2 (#{x ∈ s | x.2 = c ∧ (τ ∘ Prod.fst) x = v} : ℝ))
      = ((#{x ∈ s | x.2 = c ∧ (τ ∘ Prod.fst) x = v} : ℝ) / s.card)
          * Real.logb 2 (Fintype.card Δ) := by
    intro c _ v _
    by_cases hn : #{x ∈ s | x.2 = c ∧ (τ ∘ Prod.fst) x = v} = 0
    · rw [hn, Nat.cast_zero, zero_div, zero_mul, zero_mul]
    have hjoint := card_fibreProd_joint ε χ τ c v
    obtain ⟨σ₀, hσ₀⟩ := card_pos.1 (Nat.pos_of_ne_zero (hjoint ▸ hn))
    simp only [mem_filter, mem_univ, true_and] at hσ₀
    have hev : e v = χ c := by rw [← hσ₀.2, hτ, hσ₀.1]
    have hn' : #{x ∈ s | x.2 = c ∧ (τ ∘ Prod.fst) x = v} = #{σ | τ σ = v} := by
      rw [hjoint]
      congr 1
      refine filter_congr fun σ _ => ⟨fun h => h.2, fun h => ⟨?_, h⟩⟩
      rw [← hτ, h, hev]
    have hav : 0 < #{σ | τ σ = v} := by rw [← hn']; exact Nat.pos_of_ne_zero hn
    rw [hn', hm, hM, hN]
    have ha : (0 : ℝ) < (#{σ | τ σ = v} : ℝ) := by exact_mod_cast hav
    have hAR : (0 : ℝ) < A := by exact_mod_cast hA0
    have hBR : (0 : ℝ) < B := by exact_mod_cast hB0
    have hDR : (0 : ℝ) < Fintype.card Δ := by exact_mod_cast hΔpos
    push_cast
    rw [Real.logb_mul (by positivity) hBR.ne', Real.logb_mul hDR.ne' hAR.ne',
      Real.logb_mul ha.ne' hBR.ne']
    ring_nf
  rw [mutInfo_eq_double s _ _ hne]
  rw [sum_congr rfl fun c hc => sum_congr rfl fun v hv => hterm c hc v hv]
  simp only [← sum_mul, ← sum_div]
  have htot : ∑ c ∈ s.image Prod.snd, ∑ v ∈ s.image (τ ∘ Prod.fst),
      (#{x ∈ s | x.2 = c ∧ (τ ∘ Prod.fst) x = v} : ℝ) = s.card := by
    have h1 : ∀ c ∈ s.image Prod.snd, ∑ v ∈ s.image (τ ∘ Prod.fst),
        (#{x ∈ s | x.2 = c ∧ (τ ∘ Prod.fst) x = v} : ℝ) = (#{x ∈ s | x.2 = c} : ℝ) :=
      fun c _ => by exact_mod_cast jointCount_sum_g s (τ ∘ Prod.fst) Prod.snd c
    rw [sum_congr rfl h1]
    exact_mod_cast sum_fiber_card s Prod.snd
  rw [htot, div_self hNR.ne', one_mul]

omit [DecidableEq R] in
/-- **Marginal invariance.**  If every fibre of `χ` has `B > 0` points, the type entropy on
the fibre product equals the type entropy on `G` (the Chebotarev distribution). -/
theorem uEnt_fibreProd_fst (τ : G → β) {B : ℕ} (hB : ∀ d, #{r | χ r = d} = B) (hB0 : 0 < B) :
    uEnt (fibreProd ε χ) (τ ∘ Prod.fst) = uEnt univ τ := by
  classical
  rcases isEmpty_or_nonempty G with hG | hG
  · have h1 : fibreProd ε χ = ∅ := by
      ext x
      exact (IsEmpty.false x.1).elim
    simp [h1, uEnt]
  set s := fibreProd ε χ
  have hN : s.card = Fintype.card G * B := by
    have h := card_filter_fibreProd ε χ (fun _ => True)
    simp only [filter_true_of_mem (fun _ _ => trivial), hB, sum_const, smul_eq_mul] at h
    rw [h, card_univ]
  have hm : ∀ v, #{x ∈ s | (τ ∘ Prod.fst) x = v} = #{σ | τ σ = v} * B := fun v => by
    have h := card_filter_fibreProd ε χ (fun σ => τ σ = v)
    simp only [hB, sum_const, smul_eq_mul] at h
    exact h
  have himg : s.image (τ ∘ Prod.fst) = univ.image τ := by
    ext v
    simp only [mem_image, mem_univ, true_and]
    constructor
    · rintro ⟨x, -, rfl⟩
      exact ⟨x.1, rfl⟩
    · rintro ⟨σ, rfl⟩
      obtain ⟨r, hr⟩ := card_pos.1 (hB0.trans_eq (hB (ε σ)).symm)
      refine ⟨(σ, r), ?_, rfl⟩
      simp only [s, fibreProd, mem_filter, mem_univ, true_and]
      exact ((mem_filter.1 hr).2).symm
  have hGR : (0 : ℝ) < Fintype.card G := by exact_mod_cast Fintype.card_pos
  have hBR : (0 : ℝ) < B := by exact_mod_cast hB0
  have hsum : ∑ v ∈ univ.image τ, (#{σ | τ σ = v} : ℝ) = Fintype.card G := by
    exact_mod_cast sum_fiber_card (univ : Finset G) τ
  rw [uEnt_eq_image, uEnt_eq_image, himg, hN, card_univ]
  simp only [hm]
  have hpos : ∀ v ∈ univ.image τ, (0 : ℝ) < (#{σ | τ σ = v} : ℝ) := by
    intro v hv
    obtain ⟨σ, -, rfl⟩ := mem_image.1 hv
    exact_mod_cast card_pos.2 ⟨σ, by simp⟩
  have hexp : ∑ v ∈ univ.image τ, ((#{σ | τ σ = v} * B : ℕ) : ℝ)
        * Real.logb 2 ((#{σ | τ σ = v} * B : ℕ) : ℝ)
      = B * (∑ v ∈ univ.image τ, (#{σ | τ σ = v} : ℝ) * Real.logb 2 (#{σ | τ σ = v} : ℝ))
        + B * Real.logb 2 B * Fintype.card G := by
    rw [← hsum, mul_sum, mul_sum, ← sum_add_distrib]
    refine sum_congr rfl fun v hv => ?_
    push_cast
    rw [Real.logb_mul (hpos v hv).ne' hBR.ne']
    ring
  rw [hexp]
  push_cast
  rw [Real.logb_mul hGR.ne' hBR.ne']
  field_simp
  ring

end FibreProduct

section GroupLaw

variable {G R H β : Type*} [Group G] [Fintype G] [DecidableEq G] [Group R] [Fintype R]
  [DecidableEq R] [Group H] [Fintype H] [DecidableEq H] [DecidableEq β]

/-- **Group form of the fibre-product law.**  For surjective homomorphisms
`ε : G →* H` (the abelianised Frobenius) and `χ : R →* H` (the character read off the
residue class), and any type read-out `τ` determining `ε`, the type channel at the
conductor carries exactly `log₂ |H|` bits. -/
theorem mutInfo_fibreProd_hom (ε : G →* H) (χ : R →* H) (hε : Function.Surjective ε)
    (hχ : Function.Surjective χ) (τ : G → β) (e : β → H) (hτ : ∀ σ, e (τ σ) = ε σ) :
    mutInfo (fibreProd ε χ) (τ ∘ Prod.fst) Prod.snd = Real.logb 2 (Fintype.card H) := by
  refine mutInfo_fibreProd ε χ τ e hτ (A := #{σ | ε σ = 1}) (B := #{r | χ r = 1})
    (fun d => MonoidHom.card_fiber_eq_of_mem_range ε (hε d) ⟨1, map_one ε⟩)
    (fun d => MonoidHom.card_fiber_eq_of_mem_range χ (hχ d) ⟨1, map_one χ⟩)
    (card_pos.2 ⟨1, by simp⟩) (card_pos.2 ⟨1, by simp⟩)

/-- **Abelian boundary.**  If the common quotient is trivial (e.g. a cyclic cubic field,
whose Frobenius never leaves `A₃`), the channel at the conductor is silent. -/
theorem mutInfo_fibreProd_trivial [Subsingleton H] (ε : G →* H) (χ : R →* H) (τ : G → β) :
    mutInfo (fibreProd ε χ) (τ ∘ Prod.fst) Prod.snd = 0 := by
  have h := mutInfo_fibreProd_hom ε χ (fun d => ⟨1, Subsingleton.elim _ _⟩)
    (fun d => ⟨1, Subsingleton.elim _ _⟩) τ (fun _ => 1) (fun _ => Subsingleton.elim _ _)
  rw [h, Fintype.card_eq_one_iff.2 ⟨1, fun _ => Subsingleton.elim _ _⟩]
  simp

end GroupLaw

/-! ## The symmetric-group (`S_n`) law: one bit -/

section Symmetric

variable {α R : Type*} [Fintype α] [DecidableEq α] [Group R] [Fintype R] [DecidableEq R]

/-- The parity read off from a cycle type. -/
def cycleSign (m : Multiset ℕ) : ℤˣ := (-1 : ℤˣ) ^ (m.sum + Multiset.card m)

/-- **Universal `S_n` law.**  For every degree `n ≥ 2` (`Nontrivial α`) and every residue
group `R` with a surjective quadratic character `χ : R →* ℤˣ`, the cycle-type channel of the
Chebotarev fibre product `S_n ×_{±1} R` carries exactly one bit. -/
theorem mutInfo_cycleType_eq_one [Nontrivial α] (χ : R →* ℤˣ) (hχ : Function.Surjective χ) :
    mutInfo (fibreProd (Equiv.Perm.sign : Equiv.Perm α → ℤˣ) χ)
      ((fun σ : Equiv.Perm α => σ.cycleType) ∘ Prod.fst) Prod.snd = 1 := by
  rw [mutInfo_fibreProd_hom Equiv.Perm.sign χ (Equiv.Perm.sign_surjective α) hχ _ cycleSign
    (fun σ => (Equiv.Perm.sign_of_cycleType σ).symm)]
  simp [Fintype.card_units_int]

/-- The number of fixed points of a permutation; for the Frobenius of a cubic this is
the number of roots of the cubic modulo `p`. -/
def fixCount (σ : Equiv.Perm α) : ℕ := #{i | σ i = i}

/-- The parity read off from the root count of a cubic: one root means a transposition. -/
def rootSign (k : ℕ) : ℤˣ := if k = 1 then -1 else 1

/-- For `S₃` the root count determines the sign (`3 ↦ +1`, `1 ↦ -1`, `0 ↦ +1`). -/
theorem rootSign_fixCount (σ : Equiv.Perm (Fin 3)) :
    rootSign (fixCount σ) = Equiv.Perm.sign σ := by
  revert σ
  decide

/-- **The `S₃` root-count law.**  For every residue group with a surjective quadratic
character, the root-count (splitting-type) channel of the `S₃` fibre product is exactly
one bit. -/
theorem mutInfo_rootCount_eq_one (χ : R →* ℤˣ) (hχ : Function.Surjective χ) :
    mutInfo (fibreProd (Equiv.Perm.sign : Equiv.Perm (Fin 3) → ℤˣ) χ)
      (fixCount ∘ Prod.fst) Prod.snd = 1 := by
  rw [mutInfo_fibreProd_hom Equiv.Perm.sign χ (Equiv.Perm.sign_surjective (Fin 3)) hχ _ rootSign
    rootSign_fixCount]
  simp [Fintype.card_units_int]

/-- The Chebotarev entropy of the splitting type of an `S₃` cubic:
`H(T) = (1/6)·log₂ 6 + (1/2)·log₂ 2 + (1/3)·log₂ 3 = 2/3 + (1/2)·log₂ 3 ≈ 1.459` bits. -/
theorem uEnt_fixCount_S3 :
    uEnt (univ : Finset (Equiv.Perm (Fin 3))) fixCount = 2 / 3 + Real.logb 2 3 / 2 := by
  rw [uEnt_eq_countSum _ _ {1, 3, 2} (by decide)]
  have h6 : Real.logb 2 (6 : ℝ) = 1 + Real.logb 2 3 := lb_6
  have hc : ((univ : Finset (Equiv.Perm (Fin 3))).card : ℝ) = 6 := by
    rw [card_univ, Fintype.card_perm, Fintype.card_fin]; norm_num
  rw [hc]
  simp only [Multiset.insert_eq_cons, Multiset.map_cons, Multiset.map_singleton,
    Multiset.sum_cons, Multiset.sum_singleton]
  push_cast
  rw [h6, Real.logb_one, Real.logb_self_eq_one (by norm_num : (1 : ℝ) < 2)]
  ring

/-- **Entropy split of the `S₃` law.**  In the fibre-product model the splitting type
has entropy `2/3 + (1/2) log₂ 3`; the residue class removes exactly one bit, leaving the
conditional entropy `H(T | class) = (1/2) log₂ 3 - 1/3 ≈ 0.459` (the binary entropy
`h(1/3)` on the residue half, zero on the non-residue half). -/
theorem condEnt_rootCount_S3 (χ : R →* ℤˣ) (hχ : Function.Surjective χ) :
    condEnt (fibreProd (Equiv.Perm.sign : Equiv.Perm (Fin 3) → ℤˣ) χ)
      (fixCount ∘ Prod.fst) Prod.snd = Real.logb 2 3 / 2 - 1 / 3 := by
  have hI := mutInfo_rootCount_eq_one χ hχ
  have hH : uEnt (fibreProd (Equiv.Perm.sign : Equiv.Perm (Fin 3) → ℤˣ) χ)
      (fixCount ∘ Prod.fst) = 2 / 3 + Real.logb 2 3 / 2 := by
    rw [uEnt_fibreProd_fst _ χ fixCount (B := #{r | χ r = 1})
      (fun d => MonoidHom.card_fiber_eq_of_mem_range χ (hχ d) ⟨1, map_one χ⟩)
      (card_pos.2 ⟨1, by simp⟩), uEnt_fixCount_S3]
  unfold mutInfo at hI
  linarith

end Symmetric

/-! ## Prime conductors: every prime `ℓ`, one law -/

section Conductor

variable (ℓ : ℕ) [Fact ℓ.Prime]

/-- The quadratic character of `(ℤ/ℓ)ˣ`, as a homomorphism to `ℤˣ = {±1}`. -/
noncomputable def legendreHom : (ZMod ℓ)ˣ →* ℤˣ := (quadraticChar (ZMod ℓ)).toUnitHom

theorem legendreHom_surjective (hℓ : ℓ ≠ 2) : Function.Surjective (legendreHom ℓ) := by
  have hchar : ringChar (ZMod ℓ) ≠ 2 := by rwa [ZMod.ringChar_zmod_n]
  obtain ⟨a, ha⟩ := FiniteField.exists_nonsquare hchar
  have ha0 : a ≠ 0 := fun h => ha (h ▸ IsSquare.zero)
  intro d
  rcases Int.units_eq_one_or d with rfl | rfl
  · exact ⟨1, map_one _⟩
  · refine ⟨Units.mk0 a ha0, Units.ext ?_⟩
    rw [legendreHom, MulChar.coe_toUnitHom, Units.val_mk0,
      quadraticChar_neg_one_iff_not_isSquare.2 ha]
    rfl

/-- **FIVE-FIELDS-ONE-LAW, conductor form.**  For every odd prime conductor `ℓ`, in the
Chebotarev model of an `S₃` cubic field whose quadratic resolvent has conductor `ℓ`
(Frobenius `σ ∈ S₃` coupled to `p mod ℓ` by `sign σ = (p / ℓ)`), the mutual information
between `p mod ℓ` and the splitting type (root count) is exactly one bit. -/
theorem typeChannel_conductor_eq_one (hℓ : ℓ ≠ 2) :
    mutInfo (fibreProd (Equiv.Perm.sign : Equiv.Perm (Fin 3) → ℤˣ) (legendreHom ℓ))
      (fixCount ∘ Prod.fst) Prod.snd = 1 :=
  mutInfo_rootCount_eq_one _ (legendreHom_surjective ℓ hℓ)

/-- The fifth field: `x³ - 4x + 1`, discriminant `229`. -/
theorem typeChannel_229_eq_one :
    haveI : Fact (Nat.Prime 229) := ⟨by norm_num⟩
    mutInfo (fibreProd (Equiv.Perm.sign : Equiv.Perm (Fin 3) → ℤˣ) (legendreHom 229))
      (fixCount ∘ Prod.fst) Prod.snd = 1 :=
  haveI : Fact (Nat.Prime 229) := ⟨by norm_num⟩
  typeChannel_conductor_eq_one 229 (by norm_num)

end Conductor

end S3TypeChannel