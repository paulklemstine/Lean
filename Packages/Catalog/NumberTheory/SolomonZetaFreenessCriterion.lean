/-
# A Möbius-theoretic characterisation of freeness (conjecture D5)

For a commutative local ring `R` with finite residue field `k` (`q = #k`) the local formula
`SolomonZeta.mobiusWeight_free_local` computes the Möbius weight of a *free* lattice `Rⁿ` at any
finite quotient type `X`:

  `Σ_{Y ≤ X} μ(Y, X)·#Hom(Rⁿ, Y) = (∏_{i<d}(qⁿ - q^i))·#(𝔪X)ⁿ`,  `d = dim_k X/𝔪X`.

This file proves that this sequence of values *characterises* freeness: for `R` noetherian local
with all `R/𝔪ʲ` finite (e.g. `R = ℤ_p`, or a complete local order), a finitely generated
`R`-module `M` is free of rank `n` **iff** its Möbius weights agree with the free ones at every
finite quotient type (`SolomonZeta.nonempty_linearEquiv_free_iff_mobiusWeight_eq`).

The three ingredients of the "if" direction are:

* the residual dimension is detected by the weight at `k^{n+1}`, whose free weight vanishes
  (`SolomonZeta.freeMobiusWeight_residue_pi_succ`), so `M` needs at most `n` generators
  (`SolomonZeta.exists_surjective_residue_pi`, `SolomonZeta.exists_surjective_from_free`);
* a *counting rigidity*: composition with a surjection `π : Rⁿ ↠ M` embeds the surjections
  `M ↠ X` into the surjections `Rⁿ ↠ X`, and equality of the two (finite) counts forces every
  surjection `Rⁿ ↠ X` to kill `ker π` (`SolomonZeta.ker_le_ker_of_card_surj_eq`);
* applying this to `X = Rⁿ/𝔪ʲRⁿ` for every `j` and Krull's intersection theorem gives
  `ker π = 0`.

The counting rigidity is the conceptual point: free modules realise the *maximal* number of
surjections onto every finite quotient type, and any deficiency of `M` is already visible on the
finite-length quotients of `Rⁿ`.
-/
import Catalog.Shared.SolomonZeta.LocalOrder
import Catalog.Shared.SolomonZeta.Invariance
import Catalog.Shared.SolomonZeta.PadicLattice

namespace SolomonZeta

open IsLocalRing Module Function

universe u v

variable {R : Type u} [CommRing R] [IsLocalRing R] [Fintype (ResidueField R)]

/-- The Möbius weight of the free lattice of rank `n` at the quotient type `X`, as computed by
`SolomonZeta.mobiusWeight_free_local`: `(∏_{i<d}(qⁿ - q^i))·#(𝔪X)ⁿ` with `d = dim_k X/𝔪X`. -/
noncomputable def freeMobiusWeight (R : Type u) [CommRing R] [IsLocalRing R]
    [Fintype (ResidueField R)] (n : ℕ) (X : Type*) [AddCommGroup X] [Module R X] : ℕ :=
  (∏ i : Fin (finrank (ResidueField R) (ResQuot R X)),
      (Fintype.card (ResidueField R) ^ n - Fintype.card (ResidueField R) ^ (i : ℕ)))
    * Nat.card ↥((maximalIdeal R) • (⊤ : Submodule R X)) ^ n

theorem mobiusWeight_free_eq_freeMobiusWeight (X : Type*) [AddCommGroup X] [Module R X]
    [Finite X] [Module.Finite R X] (n : ℕ) :
    mobiusWeight R (Fin n → R) X = (freeMobiusWeight R n X : ℤ) := by
  rw [freeMobiusWeight]
  exact mobiusWeight_free_local n

/-! ### The residual test space `k^m` -/

omit [Fintype (ResidueField R)] in
/-- The maximal ideal annihilates a vector space over the residue field. -/
theorem maximalIdeal_smul_top_residue_pi (m : ℕ) :
    (maximalIdeal R) • (⊤ : Submodule R (Fin m → ResidueField R)) = ⊥ := by
  refine le_antisymm (Submodule.smul_le.2 fun r hr x _ => ?_) bot_le
  rw [Submodule.mem_bot]
  funext i
  show r • x i = 0
  rw [Algebra.smul_def, show algebraMap R (ResidueField R) r = 0 from
    Ideal.Quotient.eq_zero_iff_mem.2 hr, zero_mul]

/-- The residual dimension of `k^m` is `m`. -/
theorem finrank_resQuot_residue_pi (m : ℕ) :
    finrank (ResidueField R) (ResQuot R (Fin m → ResidueField R)) = m := by
  haveI : Finite (ResQuot R (Fin m → ResidueField R)) :=
    Finite.of_surjective _ (Submodule.mkQ_surjective _)
  haveI : Fintype (ResQuot R (Fin m → ResidueField R)) := Fintype.ofFinite _
  have hcard : Fintype.card (ResQuot R (Fin m → ResidueField R))
      = Fintype.card (ResidueField R) ^ m := by
    have e := Submodule.quotEquivOfEqBot _ (maximalIdeal_smul_top_residue_pi (R := R) m)
    rw [← Nat.card_eq_fintype_card, Nat.card_congr e.toEquiv, Nat.card_eq_fintype_card]
    simp
  have hpow := Module.card_eq_pow_finrank (K := ResidueField R)
    (V := ResQuot R (Fin m → ResidueField R))
  rw [hcard] at hpow
  exact (Nat.pow_right_injective Fintype.one_lt_card hpow).symm

/-- **The free weight of rank `n` vanishes at the residual test space `k^{n+1}`**: a free lattice
of rank `n` has no surjection onto a module needing `n+1` generators. -/
theorem freeMobiusWeight_residue_pi_succ (n : ℕ) :
    freeMobiusWeight R n (Fin (n + 1) → ResidueField R) = 0 := by
  rw [freeMobiusWeight]
  refine mul_eq_zero_of_left ?_ _
  exact Finset.prod_eq_zero (i := ⟨n, by rw [finrank_resQuot_residue_pi]; omega⟩)
    (Finset.mem_univ _) (by simp)

/-! ### Residual dimension and generation -/

variable {M : Type v} [AddCommGroup M] [Module R M] [Module.Finite R M]

omit [Fintype (ResidueField R)] in
/-- If `M` has residual dimension `> n`, it surjects onto `k^{n+1}`. -/
theorem exists_surjective_residue_pi (n : ℕ) (h : n < finrank (ResidueField R) (ResQuot R M)) :
    ∃ f : M →ₗ[R] (Fin (n + 1) → ResidueField R), Surjective f := by
  classical
  haveI : FiniteDimensional (ResidueField R) (ResQuot R M) :=
    Module.Finite.of_restrictScalars_finite R (ResidueField R) (ResQuot R M)
  set d := finrank (ResidueField R) (ResQuot R M) with hd
  set b := Module.finBasis (ResidueField R) (ResQuot R M) with hb
  set emb : Fin (n + 1) → Fin d := fun i => ⟨i, lt_of_le_of_lt (Nat.lt_succ_iff.1 i.2) h⟩ with hemb
  have hembinj : Injective emb := by
    intro i j hij
    exact Fin.ext (congrArg (fun (x : Fin d) => (x : ℕ)) hij)
  set f : ResQuot R M →ₗ[ResidueField R] (Fin (n + 1) → ResidueField R) :=
    LinearMap.pi (fun i => b.coord (emb i)) with hf
  have hfsurj : Surjective f := by
    intro w
    refine ⟨∑ i : Fin (n + 1), w i • b (emb i), ?_⟩
    funext j
    show b.coord (emb j) (∑ i : Fin (n + 1), w i • b (emb i)) = w j
    rw [map_sum]
    simp only [map_smul, Basis.coord_apply, Basis.repr_self, smul_eq_mul]
    rw [Finset.sum_eq_single j]
    · simp
    · intro i _ hij
      have hne : emb i ≠ emb j := fun hcon => hij (hembinj hcon)
      simp [hne]
    · simp
  exact ⟨(f.restrictScalars R).comp (Submodule.mkQ _),
    hfsurj.comp (Submodule.mkQ_surjective _)⟩

omit [Fintype (ResidueField R)] in
/-- If `M` has residual dimension at most `n`, it is a quotient of `Rⁿ` (Nakayama). -/
theorem exists_surjective_from_free (n : ℕ)
    (h : finrank (ResidueField R) (ResQuot R M) ≤ n) :
    ∃ π : (Fin n → R) →ₗ[R] M, Surjective π := by
  classical
  haveI : FiniteDimensional (ResidueField R) (ResQuot R M) :=
    Module.Finite.of_restrictScalars_finite R (ResidueField R) (ResQuot R M)
  set d := finrank (ResidueField R) (ResQuot R M) with hd
  set b := Module.finBasis (ResidueField R) (ResQuot R M) with hb
  set w : Fin n → ResQuot R M := fun i => if hi : (i : ℕ) < d then b ⟨i, hi⟩ else 0 with hw
  have hspanw : Submodule.span (ResidueField R) (Set.range w) = ⊤ := by
    refine le_antisymm le_top ?_
    rw [← b.span_eq]
    refine Submodule.span_le.2 ?_
    rintro _ ⟨j, rfl⟩
    have hjn : (j : ℕ) < n := lt_of_lt_of_le j.2 h
    have hwj : w ⟨j, hjn⟩ = b j := by
      simp only [hw]
      rw [dif_pos j.2]
    rw [← hwj]
    exact Submodule.subset_span ⟨⟨j, hjn⟩, rfl⟩
  set v : Fin n → M := fun i => surjInv (Submodule.mkQ_surjective
    ((maximalIdeal R) • (⊤ : Submodule R M))) (w i) with hv
  have hvw : ∀ i, Submodule.mkQ ((maximalIdeal R) • (⊤ : Submodule R M)) (v i) = w i := fun i =>
    surjInv_eq _ _
  have hspanv : Submodule.span R (Set.range v) = ⊤ := by
    rw [span_eq_top_iff_span_resQuot]
    rw [show (fun i => Submodule.mkQ ((maximalIdeal R) • (⊤ : Submodule R M)) (v i)) = w from
      funext hvw, hspanw]
  refine ⟨Fintype.linearCombination R v, ?_⟩
  rw [← LinearMap.range_eq_top, Fintype.range_linearCombination, hspanv]

/-! ### Counting rigidity -/

omit [IsLocalRing R] [Fintype (ResidueField R)] in
/-- The Möbius weight counts surjections onto the quotient type. -/
theorem mobiusWeight_eq_card_surj (X : Type*) [AddCommGroup X] [Module R X] [Finite X] :
    mobiusWeight R M X = (Nat.card {g : M →ₗ[R] X // Surjective g} : ℤ) := by
  rw [← homEqCount_top_eq_mobiusWeight, homEqCount]
  congr 1
  exact Nat.card_congr (Equiv.subtypeEquivRight fun f => by rw [LinearMap.range_eq_top])

omit [IsLocalRing R] [Fintype (ResidueField R)] [Module.Finite R M] in
/-- **Counting rigidity.**  Let `π : Rⁿ ↠ M` be a surjection and `X` a finite quotient type at
which `M` admits as many surjections as `Rⁿ` does.  Then every surjection `Rⁿ ↠ X` kills
`ker π`: composition with `π` is an injection of the first surjection set into the second, and
equal cardinalities make it a bijection. -/
theorem ker_le_ker_of_card_surj_eq {n : ℕ} (π : (Fin n → R) →ₗ[R] M) (hπ : Surjective π)
    (X : Type*) [AddCommGroup X] [Module R X] [Finite X]
    (hcard : Nat.card {g : M →ₗ[R] X // Surjective g}
      = Nat.card {f : (Fin n → R) →ₗ[R] X // Surjective f})
    (f : (Fin n → R) →ₗ[R] X) (hf : Surjective f) :
    LinearMap.ker π ≤ LinearMap.ker f := by
  have hcomp : ∀ g₁ g₂ : M →ₗ[R] X, g₁ ∘ₗ π = g₂ ∘ₗ π → g₁ = g₂ := by
    intro g₁ g₂ h'
    refine LinearMap.ext fun m => ?_
    obtain ⟨x, rfl⟩ := hπ m
    exact congrFun (congrArg (fun (l : (Fin n → R) →ₗ[R] X) => (l : (Fin n → R) → X)) h') x
  haveI : Finite ((Fin n → R) →ₗ[R] X) := finite_linearMap
  haveI : Finite (M →ₗ[R] X) :=
    Finite.of_injective (fun g : M →ₗ[R] X => g ∘ₗ π) fun g₁ g₂ h => hcomp g₁ g₂ h
  set Φ : {g : M →ₗ[R] X // Surjective g} → {f : (Fin n → R) →ₗ[R] X // Surjective f} :=
    fun g => ⟨g.1 ∘ₗ π, g.2.comp hπ⟩ with hΦ
  have hinj : Injective Φ := by
    rintro ⟨g₁, h₁⟩ ⟨g₂, h₂⟩ hg
    exact Subtype.ext (hcomp g₁ g₂ (congrArg Subtype.val hg))
  have hbij : Bijective Φ := (Nat.bijective_iff_injective_and_card Φ).2 ⟨hinj, hcard⟩
  obtain ⟨g, hg⟩ := hbij.2 ⟨f, hf⟩
  intro x hx
  have hfx : f x = g.1 (π x) :=
    (congrArg (fun (t : {f : (Fin n → R) →ₗ[R] X // Surjective f}) => t.1 x) hg).symm
  rw [LinearMap.mem_ker] at hx ⊢
  rw [hfx, hx, map_zero]

/-! ### Finiteness of the test quotients `Rⁿ/IRⁿ` -/

omit [IsLocalRing R] [Fintype (ResidueField R)] in
theorem finite_quotient_smul_top (I : Ideal R) [Finite (R ⧸ I)] (n : ℕ) :
    Finite ((Fin n → R) ⧸ (I • (⊤ : Submodule R (Fin n → R)))) := by
  classical
  set phi : (Fin n → R) →ₗ[R] (Fin n → (R ⧸ I)) :=
    LinearMap.pi fun i => (I.mkQ).comp (LinearMap.proj i) with hphi
  have hker : LinearMap.ker phi ≤ I • (⊤ : Submodule R (Fin n → R)) := by
    intro v hv
    have hvi : ∀ i, v i ∈ I := by
      intro i
      have h0 : phi v i = 0 := by rw [LinearMap.mem_ker] at hv; rw [hv]; rfl
      exact Ideal.Quotient.eq_zero_iff_mem.1 (show (Ideal.Quotient.mk I) (v i) = 0 from h0)
    have hsum : v = ∑ i : Fin n, (v i) • (Pi.single i (1 : R) : Fin n → R) := by
      funext j
      simp [Pi.single_apply]
    rw [hsum]
    exact Submodule.sum_mem _ fun i _ => Submodule.smul_mem_smul (hvi i) Submodule.mem_top
  haveI : Finite ((Fin n → R) ⧸ LinearMap.ker phi) :=
    Finite.of_injective (phi.quotKerEquivRange).toEquiv (phi.quotKerEquivRange).injective
  refine Finite.of_surjective (Submodule.mapQ _ _ LinearMap.id hker) ?_
  intro y
  obtain ⟨x, rfl⟩ := Submodule.mkQ_surjective _ y
  exact ⟨Submodule.Quotient.mk x, rfl⟩

/-! ### The characterisation -/

/-- **Freeness is detected by the Möbius weights (conjecture D5).**  Let `R` be a noetherian
commutative local ring with finite residue field such that every `R/𝔪ʲ` is finite (for instance
`R = ℤ_p`).  A finitely generated `R`-module `M` is free of rank `n` if and only if its Möbius
weight at every finite quotient type `X` equals the free weight
`(∏_{i<d}(qⁿ - q^i))·#(𝔪X)ⁿ`, `d = dim_k X/𝔪X`. -/
theorem nonempty_linearEquiv_free_iff_mobiusWeight_eq [IsNoetherianRing R]
    (hfin : ∀ j : ℕ, Finite (R ⧸ (maximalIdeal R) ^ j)) (n : ℕ) :
    Nonempty (M ≃ₗ[R] (Fin n → R)) ↔
      ∀ (X : Type u) [AddCommGroup X] [Module R X] [Finite X] [Module.Finite R X],
        mobiusWeight R M X = (freeMobiusWeight R n X : ℤ) := by
  constructor
  · rintro ⟨e⟩ X _ _ _ _
    rw [mobiusWeight_congr_left (X := X) e, mobiusWeight_free_eq_freeMobiusWeight]
  · intro H
    have hle : finrank (ResidueField R) (ResQuot R M) ≤ n := by
      by_contra hcon
      push_neg at hcon
      obtain ⟨f, hf⟩ := exists_surjective_residue_pi n hcon
      have hzero : mobiusWeight R M (Fin (n + 1) → ResidueField R) = 0 := by
        rw [H (Fin (n + 1) → ResidueField R), freeMobiusWeight_residue_pi_succ]
        simp
      exact (mobiusWeight_eq_zero_iff.1 hzero) f hf
    obtain ⟨π, hπ⟩ := exists_surjective_from_free n hle
    have hker : ∀ j : ℕ,
        LinearMap.ker π ≤ (maximalIdeal R) ^ j • (⊤ : Submodule R (Fin n → R)) := by
      intro j
      haveI := hfin j
      haveI : Finite ((Fin n → R) ⧸ ((maximalIdeal R) ^ j • (⊤ : Submodule R (Fin n → R)))) :=
        finite_quotient_smul_top _ n
      haveI : Module.Finite R ((Fin n → R) ⧸ ((maximalIdeal R) ^ j
        • (⊤ : Submodule R (Fin n → R)))) := Module.Finite.of_finite
      have hcard : Nat.card {g : M →ₗ[R] ((Fin n → R) ⧸ ((maximalIdeal R) ^ j
            • (⊤ : Submodule R (Fin n → R)))) // Surjective g}
          = Nat.card {f : (Fin n → R) →ₗ[R] ((Fin n → R) ⧸ ((maximalIdeal R) ^ j
            • (⊤ : Submodule R (Fin n → R)))) // Surjective f} := by
        have h1 := mobiusWeight_eq_card_surj (R := R) (M := M)
          ((Fin n → R) ⧸ ((maximalIdeal R) ^ j • (⊤ : Submodule R (Fin n → R))))
        have h2 := mobiusWeight_eq_card_surj (R := R) (M := (Fin n → R))
          ((Fin n → R) ⧸ ((maximalIdeal R) ^ j • (⊤ : Submodule R (Fin n → R))))
        have h3 := H ((Fin n → R) ⧸ ((maximalIdeal R) ^ j • (⊤ : Submodule R (Fin n → R))))
        have h4 := mobiusWeight_free_eq_freeMobiusWeight (R := R)
          ((Fin n → R) ⧸ ((maximalIdeal R) ^ j • (⊤ : Submodule R (Fin n → R)))) n
        rw [h1] at h3
        rw [h2] at h4
        exact_mod_cast h3.trans h4.symm
      have hkerle := ker_le_ker_of_card_surj_eq π hπ _ hcard
        (Submodule.mkQ ((maximalIdeal R) ^ j • (⊤ : Submodule R (Fin n → R))))
        (Submodule.mkQ_surjective _)
      rwa [Submodule.ker_mkQ] at hkerle
    have hbot : LinearMap.ker π = ⊥ := by
      refine le_antisymm ?_ bot_le
      have hinf := Ideal.iInf_pow_smul_eq_bot_of_isLocalRing (R := R) (M := (Fin n → R))
        (I := maximalIdeal R) (IsLocalRing.maximalIdeal.isMaximal R).ne_top
      rw [← hinf]
      exact le_iInf hker
    exact ⟨(LinearMap.quotKerEquivOfSurjective π hπ).symm.trans
      (Submodule.quotEquivOfEqBot _ hbot)⟩

/-! ### Noetherian local rings with finite residue field -/

/-- For a noetherian local ring with finite residue field, every quotient `R/𝔪ʲ` is finite:
the associated graded pieces `𝔪ⁱ/𝔪ⁱ⁺¹` are finitely generated over the finite field `k`. -/
theorem finite_quotient_maximalIdeal_pow (R : Type u) [CommRing R] [IsLocalRing R]
    [IsNoetherianRing R] [Finite (ResidueField R)] (j : ℕ) :
    Finite (R ⧸ (maximalIdeal R) ^ j) := by
  haveI : Finite (R ⧸ maximalIdeal R) := inferInstanceAs (Finite (ResidueField R))
  exact Ideal.finite_quotient_pow (IsNoetherian.noetherian _) j

/-- **Freeness is detected by the Möbius weights, hypothesis-free form.**  Over any noetherian
commutative local ring with finite residue field, a finitely generated module is free of rank
`n` iff its Möbius weights are those of `Rⁿ` at every finite quotient type. -/
theorem nonempty_linearEquiv_free_iff_mobiusWeight_eq_of_isNoetherianRing [IsNoetherianRing R]
    (n : ℕ) :
    Nonempty (M ≃ₗ[R] (Fin n → R)) ↔
      ∀ (X : Type u) [AddCommGroup X] [Module R X] [Finite X] [Module.Finite R X],
        mobiusWeight R M X = (freeMobiusWeight R n X : ℤ) :=
  nonempty_linearEquiv_free_iff_mobiusWeight_eq (finite_quotient_maximalIdeal_pow R) n

/-! ### The `p`-adic case -/

/-- Every quotient `ℤ_p/𝔪ʲ` is finite. -/
theorem finite_quotient_maximalIdeal_pow_padic (p : ℕ) [Fact p.Prime] (j : ℕ) :
    Finite (ℤ_[p] ⧸ (maximalIdeal ℤ_[p]) ^ j) := by
  rw [PadicInt.maximalIdeal_eq_span_p, Ideal.span_singleton_pow, ← PadicInt.ker_toZModPow j]
  exact Finite.of_injective _ (RingHom.quotientKerEquivOfSurjective
    (f := PadicInt.toZModPow (p := p) j) (ZMod.ringHom_surjective _)).injective

/-- **Freeness over `ℤ_p` is detected by the Möbius weights.**  A finitely generated
`ℤ_p`-module `M` is free of rank `n` iff for every finite `ℤ_p`-module `X`

  `Σ_{Y ≤ X} μ(Y, X)·#Hom(M, Y) = (∏_{i<d}(pⁿ - p^i))·#(pX)ⁿ`,  `d = dim_{𝔽_p} X/pX`,

i.e. iff `M` has the Möbius weights of the free lattice `ℤ_pⁿ`. -/
theorem nonempty_linearEquiv_free_iff_mobiusWeight_eq_padic (p : ℕ) [Fact p.Prime]
    (M : Type) [AddCommGroup M] [Module ℤ_[p] M] [Module.Finite ℤ_[p] M] (n : ℕ) :
    Nonempty (M ≃ₗ[ℤ_[p]] (Fin n → ℤ_[p])) ↔
      ∀ (X : Type) [AddCommGroup X] [Module ℤ_[p] X] [Finite X] [Module.Finite ℤ_[p] X],
        mobiusWeight ℤ_[p] M X = (freeMobiusWeight ℤ_[p] n X : ℤ) :=
  nonempty_linearEquiv_free_iff_mobiusWeight_eq (finite_quotient_maximalIdeal_pow_padic p) n

/-! ### Sharpness: one test space is not enough -/

/-- **The single test space `k^{n+1}` does not characterise freeness.**  Over `R = ℤ_p` take
`n = 1` and `M = 𝔽_p` (the residue field, a cyclic `ℤ_p`-module).  Its Möbius weight at the
residual test space `k²` agrees with the free weight of rank one — both vanish, since neither
`M` nor a rank one free lattice surjects onto `k²` — yet `M` is not free of rank one.

So the "if" direction of `SolomonZeta.nonempty_linearEquiv_free_iff_mobiusWeight_eq` genuinely
needs the whole family of finite quotient types: the residual test space only bounds the number
of generators. -/
theorem mobiusWeight_residue_pi_succ_insufficient (p : ℕ) [Fact p.Prime] :
    mobiusWeight ℤ_[p] (ResidueField ℤ_[p]) (Fin 2 → ResidueField ℤ_[p])
        = (freeMobiusWeight ℤ_[p] 1 (Fin 2 → ResidueField ℤ_[p]) : ℤ)
      ∧ IsEmpty (ResidueField ℤ_[p] ≃ₗ[ℤ_[p]] (Fin 1 → ℤ_[p])) := by
  constructor
  · rw [freeMobiusWeight_residue_pi_succ (R := ℤ_[p]) 1]
    refine mobiusWeight_eq_zero_of_no_surjection fun f hf => ?_
    have hcard := Nat.card_le_card_of_surjective f hf
    have h1 : Nat.card (Fin 2 → ResidueField ℤ_[p]) = p ^ 2 := by
      rw [Nat.card_fun]
      simp [Nat.card_eq_fintype_card, card_residueField_padicInt]
    have h2 : Nat.card (ResidueField ℤ_[p]) = p := by
      rw [Nat.card_eq_fintype_card, card_residueField_padicInt]
    rw [h1, h2] at hcard
    have hp := (Fact.out (p := p.Prime)).two_le
    nlinarith [hcard]
  · refine ⟨fun e => ?_⟩
    haveI : Finite (Fin 1 → ℤ_[p]) := Finite.of_equiv _ e.toEquiv
    exact (Finite.not_infinite (α := Fin 1 → ℤ_[p]) inferInstance) inferInstance

/-! ### Maximality of the free weights -/

omit [IsLocalRing R] [Fintype (ResidueField R)] [Module.Finite R M] in
/-- Composition with a surjection `π : Rⁿ ↠ M` embeds the surjections `M ↠ X` into the
surjections `Rⁿ ↠ X`. -/
theorem card_surj_le_of_surjective {n : ℕ} (π : (Fin n → R) →ₗ[R] M) (hπ : Surjective π)
    (X : Type*) [AddCommGroup X] [Module R X] [Finite X] :
    Nat.card {g : M →ₗ[R] X // Surjective g}
      ≤ Nat.card {f : (Fin n → R) →ₗ[R] X // Surjective f} := by
  haveI : Finite ((Fin n → R) →ₗ[R] X) := finite_linearMap
  refine Nat.card_le_card_of_injective
    (fun g : {g : M →ₗ[R] X // Surjective g} => (⟨g.1 ∘ₗ π, g.2.comp hπ⟩ :
      {f : (Fin n → R) →ₗ[R] X // Surjective f})) ?_
  rintro ⟨g₁, h₁⟩ ⟨g₂, h₂⟩ hg
  have h' : g₁ ∘ₗ π = g₂ ∘ₗ π := congrArg Subtype.val hg
  refine Subtype.ext (LinearMap.ext fun m => ?_)
  obtain ⟨x, rfl⟩ := hπ m
  exact congrFun (congrArg (fun (l : (Fin n → R) →ₗ[R] X) => (l : (Fin n → R) → X)) h') x

/-- **Free lattices maximise the Möbius weight.**  If the finitely generated module `M` is
generated by `n` elements, then at every finite quotient type its Möbius weight is at most the
free weight of rank `n`; by
`SolomonZeta.nonempty_linearEquiv_free_iff_mobiusWeight_eq` equality throughout characterises
freeness. -/
theorem mobiusWeight_le_freeMobiusWeight (n : ℕ)
    (h : finrank (ResidueField R) (ResQuot R M) ≤ n)
    (X : Type u) [AddCommGroup X] [Module R X] [Finite X] [Module.Finite R X] :
    mobiusWeight R M X ≤ (freeMobiusWeight R n X : ℤ) := by
  obtain ⟨π, hπ⟩ := exists_surjective_from_free n h
  have h1 := mobiusWeight_eq_card_surj (R := R) (M := M) X
  have h2 := mobiusWeight_eq_card_surj (R := R) (M := (Fin n → R)) X
  have h3 := mobiusWeight_free_eq_freeMobiusWeight (R := R) X n
  rw [h2] at h3
  rw [h1, ← h3]
  exact_mod_cast card_surj_le_of_surjective π hπ X

end SolomonZeta