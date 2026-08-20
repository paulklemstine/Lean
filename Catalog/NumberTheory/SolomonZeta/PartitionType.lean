/-
# Hall's formula in partition form

`Shared.SolomonZeta.AbelianPGroup` proves, for a finite abelian `p`-group `X` of exponent
dividing `pᵉ`,

  `#Aut(X) · #{N ≤ ℤⁿ : ℤⁿ/N ≅ X}  =  (∏_{i<d} (pⁿ - p^i)) · #(pX)ⁿ`,   `d = dim_{𝔽_p} X/pX`.

This file evaluates the two residual invariants `#(pX)` and `d` for `X` presented by a
partition, i.e. `X = ∏_{i<r} ℤ/p^{λ_i}` with all `λ_i ≥ 1`:

* `card_pRad_partition` : `#(pX) = p^{Σ (λ_i - 1)} = p^{|λ| - r}`;
* `finrank_frattini_partition` : `dim_{𝔽_p} X/pX = r`, the number of parts;

and hence obtains the classical closed formula (`autCard_mul_quotIsoCount_partition`)

  `#Aut(X) · #{N ≤ ℤⁿ : ℤⁿ/N ≅ X} = (∏_{i<r} (pⁿ - p^i)) · p^{n(|λ| - r)}`.

The proofs identify `p·X` inside a product with the product of the `p·(ℤ/p^{λ_i})`
(`mem_pRad_pi`), and each factor with the kernel of the reduction map
`ℤ/p^{a} → ℤ/p` (`mem_pRad_zmod_pow_iff`), whose cardinality is `p^{a-1}`.
-/
import Catalog.Shared.SolomonZeta.AbelianPGroup

namespace SolomonZeta

open Module Pointwise

/-! ### The submodule `pX` -/

variable {p : ℕ}

/-- Membership in `pX` is being divisible by `p`. -/
theorem mem_pRad_iff {X : Type*} [AddCommGroup X] (x : X) :
    x ∈ pRad p X ↔ ∃ y, x = (p : ℤ) • y := by
  show x ∈ (Ideal.span {(p : ℤ)}) • (⊤ : Submodule ℤ X) ↔ _
  rw [Submodule.ideal_span_singleton_smul]
  constructor
  · intro h
    rw [Submodule.mem_smul_pointwise_iff_exists] at h
    obtain ⟨y, _, rfl⟩ := h
    exact ⟨y, rfl⟩
  · rintro ⟨y, rfl⟩
    exact Submodule.smul_mem_pointwise_smul _ _ _ Submodule.mem_top

/-- `p·(∏ Mᵢ) = ∏ (p·Mᵢ)`, in membership form. -/
theorem mem_pRad_pi {ι : Type*} {M : ι → Type*} [∀ i, AddCommGroup (M i)] (x : ∀ i, M i) :
    x ∈ pRad p (∀ i, M i) ↔ ∀ i, x i ∈ pRad p (M i) := by
  simp only [mem_pRad_iff]
  constructor
  · rintro ⟨y, rfl⟩ i
    exact ⟨y i, rfl⟩
  · intro h
    choose y hy using h
    exact ⟨y, funext hy⟩

/-- The cardinality of `p·(∏ Mᵢ)` is the product of the cardinalities of the `p·Mᵢ`. -/
theorem card_pRad_pi {ι : Type*} [Fintype ι] {M : ι → Type*} [∀ i, AddCommGroup (M i)] :
    Nat.card (pRad p (∀ i, M i)) = ∏ i, Nat.card (pRad p (M i)) := by
  have e : (pRad p (∀ i, M i)) ≃ (∀ i, (pRad p (M i) : Type _)) :=
    (Equiv.subtypeEquivRight fun x => mem_pRad_pi x).trans Equiv.subtypePiEquivPi
  rw [Nat.card_congr e, Nat.card_pi]

/-- In `ℤ/pᵃ`, the submodule `p·X` is the kernel of the reduction map to `ℤ/p`. -/
theorem mem_pRad_zmod_pow_iff (p a : ℕ) [hp : Fact p.Prime] (ha : a ≠ 0) (x : ZMod (p ^ a)) :
    x ∈ pRad p (ZMod (p ^ a)) ↔
      ZMod.castHom (dvd_pow_self p ha) (ZMod p) x = 0 := by
  haveI : NeZero (p ^ a) := ⟨pow_ne_zero _ hp.out.pos.ne'⟩
  rw [mem_pRad_iff]
  constructor
  · rintro ⟨y, rfl⟩
    have h1 : ((p : ℤ) • y) = (p : ZMod (p ^ a)) * y := by
      rw [zsmul_eq_mul]; norm_cast
    rw [h1, map_mul]
    simp
  · intro h
    refine ⟨(x.val / p : ℕ), ?_⟩
    have hx : ((x.val : ℕ) : ZMod p) = 0 := by
      simpa [ZMod.castHom_apply, ZMod.natCast_val] using h
    have hdvd : p ∣ x.val := (ZMod.natCast_eq_zero_iff _ _).1 hx
    have h2 : ((p : ℤ) • ((x.val / p : ℕ) : ZMod (p ^ a)))
        = ((p * (x.val / p) : ℕ) : ZMod (p ^ a)) := by
      rw [zsmul_eq_mul]; push_cast; norm_cast
    rw [h2, Nat.mul_div_cancel' hdvd, ZMod.natCast_val, ZMod.cast_id]

/-- `#(p·ℤ/pᵃ) = p^{a-1}`. -/
theorem card_pRad_zmod_pow (p a : ℕ) [hp : Fact p.Prime] (ha : a ≠ 0) :
    Nat.card (pRad p (ZMod (p ^ a))) = p ^ (a - 1) := by
  haveI : NeZero (p ^ a) := ⟨pow_ne_zero _ hp.out.pos.ne'⟩
  set f : ZMod (p ^ a) →+ ZMod p :=
    (ZMod.castHom (dvd_pow_self p ha) (ZMod p)).toAddMonoidHom with hf
  have hsurj : Function.Surjective f := ZMod.ringHom_surjective _
  have hquot : Nat.card (ZMod (p ^ a) ⧸ f.ker) = p := by
    rw [Nat.card_congr (QuotientAddGroup.quotientKerEquivOfSurjective f hsurj).toEquiv]
    simp [Nat.card_eq_fintype_card]
  have htot := AddSubgroup.card_eq_card_quotient_mul_card_addSubgroup f.ker
  rw [hquot] at htot
  have hcard : Nat.card (ZMod (p ^ a)) = p ^ a := by simp [Nat.card_eq_fintype_card]
  have hp1 : p ^ a = p * p ^ (a - 1) := by
    rw [← pow_succ']; congr 1; omega
  rw [hcard] at htot
  have hker : Nat.card f.ker = p ^ (a - 1) :=
    Nat.eq_of_mul_eq_mul_left hp.out.pos (htot.symm.trans hp1)
  rw [← hker]
  exact Nat.card_congr (Equiv.subtypeEquivRight fun x => mem_pRad_zmod_pow_iff p a ha x)

/-! ### The module attached to a partition -/

variable {r : ℕ}

/-- The finite abelian `p`-group of type `λ`: `∏_{i<r} ℤ/p^{λ_i}`. -/
abbrev PartitionModule (p : ℕ) {r : ℕ} (lam : Fin r → ℕ) : Type :=
  ∀ i : Fin r, ZMod (p ^ lam i)

variable (p) in
/-- The order of the group of type `λ` is `p^{|λ|}`. -/
theorem card_partitionModule [hp : Fact p.Prime] (lam : Fin r → ℕ) :
    Nat.card (PartitionModule p lam) = p ^ ∑ i, lam i := by
  haveI : ∀ i : Fin r, NeZero (p ^ lam i) := fun i => ⟨pow_ne_zero _ hp.out.pos.ne'⟩
  rw [Nat.card_pi]
  simp [Nat.card_eq_fintype_card, Finset.prod_pow_eq_pow_sum]

variable (p) in
/-- `#(pX) = p^{Σ (λ_i - 1)}` for `X` of type `λ` with all parts positive. -/
theorem card_pRad_partition [Fact p.Prime] {lam : Fin r → ℕ} (hlam : ∀ i, lam i ≠ 0) :
    Nat.card (pRad p (PartitionModule p lam)) = p ^ ∑ i, (lam i - 1) := by
  rw [card_pRad_pi]
  simp only [fun i => card_pRad_zmod_pow p (lam i) (hlam i)]
  rw [Finset.prod_pow_eq_pow_sum]

variable (p) in
/-- `pᵉ` annihilates the group of type `λ` as soon as every part is at most `e`. -/
theorem pow_smul_partitionModule_eq_zero [Fact p.Prime] {lam : Fin r → ℕ} {e : ℕ}
    (he : ∀ i, lam i ≤ e) (x : PartitionModule p lam) : ((p : ℤ) ^ e) • x = 0 := by
  funext i
  have hdvd : (p : ℤ) ^ lam i ∣ (p : ℤ) ^ e := pow_dvd_pow _ (he i)
  have hzero : (((p : ℤ) ^ e : ℤ) : ZMod (p ^ lam i)) = 0 := by
    have : ((p ^ lam i : ℕ) : ℤ) ∣ ((p ^ e : ℕ) : ℤ) := by push_cast; exact hdvd
    have h0 := (ZMod.intCast_zmod_eq_zero_iff_dvd ((p : ℤ) ^ e) (p ^ lam i)).2 (by
      push_cast at this ⊢; exact this)
    simpa using h0
  show ((p : ℤ) ^ e) • x i = 0
  rw [zsmul_eq_mul, hzero, zero_mul]

variable (p) in
/-- The Frattini quotient of the group of type `λ` has order `p^r`, `r` = number of parts. -/
theorem card_frattini_partition [hp : Fact p.Prime] {lam : Fin r → ℕ} (hlam : ∀ i, lam i ≠ 0) :
    Nat.card (FrattiniQuot p (PartitionModule p lam)) = p ^ r := by
  haveI : ∀ i : Fin r, NeZero (p ^ lam i) := fun i => ⟨pow_ne_zero _ hp.out.pos.ne'⟩
  haveI : Finite (PartitionModule p lam) := Finite.of_equiv _ (Equiv.refl _)
  have hsplit : Nat.card (FrattiniQuot p (PartitionModule p lam))
      * Nat.card (pRad p (PartitionModule p lam)) = Nat.card (PartitionModule p lam) := by
    have h := AddSubgroup.card_eq_card_quotient_mul_card_addSubgroup
      (pRad p (PartitionModule p lam)).toAddSubgroup
    have e : Nat.card (FrattiniQuot p (PartitionModule p lam))
        = Nat.card (PartitionModule p lam ⧸ (pRad p (PartitionModule p lam)).toAddSubgroup) :=
      Nat.card_congr (Equiv.refl _)
    rw [e, h]
    congr 1
  rw [card_pRad_partition p hlam, card_partitionModule p lam] at hsplit
  have hsum : ∑ i, lam i = r + ∑ i, (lam i - 1) := by
    have hone : ∑ i, lam i = ∑ i : Fin r, (1 + (lam i - 1)) :=
      Finset.sum_congr rfl fun i _ => by have := hlam i; omega
    rw [hone, Finset.sum_add_distrib]
    simp
  rw [hsum, pow_add] at hsplit
  exact Nat.eq_of_mul_eq_mul_right (pow_pos hp.out.pos _) hsplit

variable (p) in
/-- The minimal number of generators of the group of type `λ` is the number of parts. -/
theorem finrank_frattini_partition [hp : Fact p.Prime] {lam : Fin r → ℕ}
    (hlam : ∀ i, lam i ≠ 0) :
    finrank (ZMod p) (FrattiniQuot p (PartitionModule p lam)) = r := by
  haveI : ∀ i : Fin r, NeZero (p ^ lam i) := fun i => ⟨pow_ne_zero _ hp.out.pos.ne'⟩
  haveI : Finite (PartitionModule p lam) := Finite.of_equiv _ (Equiv.refl _)
  haveI : Finite (FrattiniQuot p (PartitionModule p lam)) :=
    Finite.of_surjective _ (Submodule.mkQ_surjective _)
  have hcard := FiniteField.pow_finrank_eq_natCard p (FrattiniQuot p (PartitionModule p lam))
  rw [card_frattini_partition p hlam] at hcard
  exact Nat.pow_right_injective hp.out.two_le hcard

/-! ### Hall's formula in partition form -/

variable (p) in
/-- **Hall's formula, partition form.**  For `X = ∏_{i<r} ℤ/p^{λ_i}` with all `λ_i ≥ 1`,

  `#Aut(X) · #{N ≤ ℤⁿ : ℤⁿ/N ≅ X} = (∏_{i<r} (pⁿ - p^i)) · p^{n·Σ(λ_i - 1)}`.

Both residual invariants of `Shared.SolomonZeta.AbelianPGroup` are thus explicit in `λ`:
the number of parts `r` and the "co-length" `|λ| - r`. -/
theorem autCard_mul_quotIsoCount_partition [hp : Fact p.Prime] {lam : Fin r → ℕ}
    (hlam : ∀ i, lam i ≠ 0) (n : ℕ) :
    autCard ℤ (PartitionModule p lam) * quotIsoCount ℤ (Fin n → ℤ) (PartitionModule p lam)
      = (∏ i : Fin r, (p ^ n - p ^ (i : ℕ))) * p ^ (n * ∑ i, (lam i - 1)) := by
  haveI : ∀ i : Fin r, NeZero (p ^ lam i) := fun i => ⟨pow_ne_zero _ hp.out.pos.ne'⟩
  haveI : Finite (PartitionModule p lam) := Finite.of_equiv _ (Equiv.refl _)
  have hpe := pow_smul_partitionModule_eq_zero p
    (lam := lam) (e := ∑ i, lam i) (fun i => Finset.single_le_sum (f := lam)
      (fun j _ => Nat.zero_le _) (Finset.mem_univ i))
  rw [autCard_mul_quotIsoCount_pGroup hpe n, card_pRad_partition p hlam,
    finrank_frattini_partition p hlam, ← pow_mul, mul_comm (∑ i, (lam i - 1)) n]

end SolomonZeta