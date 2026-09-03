import Mathlib

/-!
# Reed–Solomon codes: dimension `k` and minimum distance exactly `n - k + 1`

This file packages the space of polynomials of degree `< k` over a field `F` as a
finite-dimensional `F`-vector space, builds the Reed–Solomon evaluation encoder as an
`F`-linear map into `Fin n → F`, and proves:

* `ReedSolomonMDS.finrank_degreeLT`: the message space has dimension `k`;
* `ReedSolomonMDS.encoder_injective`: the encoder is injective when the evaluation points are
  distinct and `k ≤ n`, hence (`ReedSolomonMDS.finrank_code`) the Reed–Solomon code has
  dimension exactly `k`;
* `ReedSolomonMDS.weight_lower_bound`: every nonzero codeword has Hamming weight at least
  `n - k + 1` (root counting);
* `ReedSolomonMDS.singleton_bound`: a general **Singleton bound** for arbitrary linear codes:
  if every nonzero codeword of a subspace `C ≤ (Fin n → F)` has weight at least `d`, then
  `finrank C + d ≤ n + 1`;
* `ReedSolomonMDS.minDist_code` and `ReedSolomonMDS.singleton_equality`: combining the two,
  the minimum distance of the Reed–Solomon code is exactly `n - k + 1`, i.e. Reed–Solomon
  codes are MDS.

An explicit minimum-weight codeword, the evaluation vector of `∏ i ∈ T, (X - C (α i))` for a
set `T` of `k - 1` evaluation points, is constructed in
`ReedSolomonMDS.exists_codeword_of_weight`.

The development then continues with:

* `ReedSolomonMDS.restrict_bijective_of_mds` and `ReedSolomonMDS.mds_of_restrict_injective`: a
  `k`-dimensional code is MDS if and only if every set of `k` coordinates is an information set;
* `ReedSolomonMDS.exists_unique_codeword_on`, `ReedSolomonMDS.eq_of_agree_on`,
  `ReedSolomonMDS.unique_decoding`: interpolation, correction of `n - k` erasures, and unique
  decoding inside the radius `(n - k) / 2`;
* `ReedSolomonMDS.finrank_add_finrank_dualCode` and `ReedSolomonMDS.minDist_dualCode_code`: the
  dual code has dimension `n - k` and minimum distance exactly `k + 1`, so the dual of a
  Reed–Solomon code is MDS as well;
* `ReedSolomonMDS.rs_zmod5_parameters`: the concrete `[5, 3]` code over `ZMod 5`.
-/

open Polynomial Finset Module Function

namespace ReedSolomonMDS

variable {F : Type*} [Field F] [DecidableEq F] {n k : ℕ}

/-! ## The message space and the encoder -/

/-- The Reed–Solomon **encoder**: the `F`-linear map sending a polynomial of degree `< k` to
its vector of values at the evaluation points `α 0, …, α (n-1)`. -/
def encoder (k : ℕ) (α : Fin n → F) : degreeLT F k →ₗ[F] (Fin n → F) where
  toFun p i := (p : F[X]).eval (α i)
  map_add' p q := by funext i; simp
  map_smul' c p := by funext i; simp

omit [DecidableEq F] in
@[simp] lemma encoder_apply (k : ℕ) (α : Fin n → F) (p : degreeLT F k) (i : Fin n) :
    encoder k α p i = (p : F[X]).eval (α i) := rfl

/-- The Reed–Solomon **code**: the image of the encoder, a subspace of `Fin n → F`. -/
def code (k : ℕ) (α : Fin n → F) : Submodule F (Fin n → F) :=
  LinearMap.range (encoder k α)

omit [DecidableEq F] in
/-- The space of polynomials of degree `< k` has dimension `k`. -/
theorem finrank_degreeLT : finrank F (degreeLT F k) = k := by
  simpa using (Module.finrank_eq_card_basis (degreeLT.basis F k))

omit [DecidableEq F] in
/-- A polynomial in `degreeLT F k` has `natDegree < k` unless it is zero. -/
theorem natDegree_lt_of_mem_degreeLT {p : F[X]} (hp : p ∈ degreeLT F k) (hp0 : p ≠ 0) :
    p.natDegree < k := by
  rw [mem_degreeLT, degree_eq_natDegree hp0] at hp
  exact_mod_cast hp

omit [DecidableEq F] in
/-- With distinct evaluation points and `k ≤ n`, the encoder is injective. -/
theorem encoder_injective {α : Fin n → F} (hα : Injective α) (hkn : k ≤ n) :
    Injective (encoder k α) := by
  rw [← LinearMap.ker_eq_bot]
  refine (Submodule.eq_bot_iff _).2 fun p hp => ?_
  have hval : ∀ i, (p : F[X]).eval (α i) = 0 := fun i => congrFun (LinearMap.mem_ker.1 hp) i
  rcases eq_or_ne (p : F[X]) 0 with h0 | h0
  · exact Subtype.ext h0
  · have hlt : (p : F[X]).natDegree < k := natDegree_lt_of_mem_degreeLT p.2 h0
    have hdeg : (p : F[X]).natDegree < Fintype.card (Fin n) := by
      simpa using hlt.trans_le hkn
    exact Subtype.ext (Polynomial.eq_zero_of_natDegree_lt_card_of_eval_eq_zero _ hα hval hdeg)

omit [DecidableEq F] in
/-- **Dimension of a Reed–Solomon code**: it equals `k`. -/
theorem finrank_code {α : Fin n → F} (hα : Injective α) (hkn : k ≤ n) :
    finrank F (code k α) = k := by
  have h := LinearEquiv.finrank_eq
    (LinearEquiv.ofInjective (encoder k α) (encoder_injective hα hkn))
  rw [code, ← h, finrank_degreeLT]

/-! ## Weight bounds -/

/-- If a vector vanishes on a set `S` of coordinates, its Hamming weight is at most `n - #S`. -/
theorem hammingNorm_le_of_vanishing {c : Fin n → F} {S : Finset (Fin n)}
    (h : ∀ i ∈ S, c i = 0) : hammingNorm c ≤ n - #S := by
  have hsub : (univ.filter fun i => c i ≠ 0) ⊆ Sᶜ := by
    intro i hi
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hi
    simp only [Finset.mem_compl]
    exact fun hS => hi (h i hS)
  have hcard := Finset.card_le_card hsub
  rw [Finset.card_compl] at hcard
  simpa [hammingNorm] using hcard

/-- If the zero set of a vector is exactly `S`, its Hamming weight is `n - #S`. -/
theorem hammingNorm_eq_card_compl {c : Fin n → F} {S : Finset (Fin n)}
    (h : ∀ i, c i = 0 ↔ i ∈ S) : hammingNorm c = n - #S := by
  have hset : (univ.filter fun i => c i ≠ 0) = Sᶜ := by
    ext i
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_compl, ← h i]
  have hval : hammingNorm c = #(univ.filter fun i => c i ≠ 0) := rfl
  rw [hval, hset, Finset.card_compl]
  simp

/-- **Root-counting lower bound**: every nonzero Reed–Solomon codeword has Hamming weight at
least `n - k + 1`. -/
theorem weight_lower_bound {α : Fin n → F} (hα : Injective α) (hk : 1 ≤ k) (hkn : k ≤ n)
    {c : Fin n → F} (hc : c ∈ code k α) (hc0 : c ≠ 0) : n - k + 1 ≤ hammingNorm c := by
  obtain ⟨p, rfl⟩ := hc
  have hp0 : (p : F[X]) ≠ 0 := by
    intro h
    exact hc0 (by funext i; simp [h])
  have hdeg : (p : F[X]).natDegree ≤ k - 1 := by
    have := natDegree_lt_of_mem_degreeLT p.2 hp0
    omega
  set Z : Finset (Fin n) := univ.filter (fun i => (p : F[X]).eval (α i) = 0) with hZ
  have hmemZ : ∀ i, encoder k α p i = 0 ↔ i ∈ Z := by
    intro i
    simp [hZ]
  have hcard : #Z ≤ k - 1 := by
    have himg : #(Z.image α) ≤ (p : F[X]).natDegree := by
      refine Polynomial.card_le_degree_of_subset_roots ?_
      intro x hx
      obtain ⟨i, hi, rfl⟩ := Finset.mem_image.1 (show x ∈ Z.image α from hx)
      have hroot : (p : F[X]).eval (α i) = 0 := by
        simpa [hZ] using (Finset.mem_filter.1 hi).2
      exact (Polynomial.mem_roots' ).2 ⟨hp0, hroot⟩
    have heq : #Z = #(Z.image α) := (Finset.card_image_of_injective _ hα).symm
    omega
  have hnorm : hammingNorm (encoder k α p) = n - #Z := hammingNorm_eq_card_compl hmemZ
  omega

/-! ## Puncturing / restriction of a code -/

/-- The **restriction** (puncturing) map: a codeword restricted to the coordinates in `S`. -/
def restrict (C : Submodule F (Fin n → F)) (S : Finset (Fin n)) : C →ₗ[F] ({x // x ∈ S} → F) :=
  (LinearMap.funLeft F F (fun i : {x // x ∈ S} => (i : Fin n))).comp C.subtype

omit [DecidableEq F] in
@[simp] lemma restrict_apply (C : Submodule F (Fin n → F)) (S : Finset (Fin n)) (c : C)
    (i : {x // x ∈ S}) : restrict C S c i = (c : Fin n → F) (i : Fin n) := rfl

/-- If every nonzero codeword has weight at least `d` and `S` omits fewer than `d` coordinates,
then restricting to `S` is injective: `S` "carries" the whole code. -/
theorem restrict_injective {C : Submodule F (Fin n → F)} {S : Finset (Fin n)} {d : ℕ}
    (hC : ∀ c ∈ C, c ≠ 0 → d ≤ hammingNorm c) (hS : n - #S < d) :
    Injective (restrict C S) := by
  rw [← LinearMap.ker_eq_bot]
  refine (Submodule.eq_bot_iff _).2 fun c hc => ?_
  by_contra hne
  have hc0 : (c : Fin n → F) ≠ 0 := fun h => hne (Subtype.ext h)
  have hvan : ∀ i ∈ S, (c : Fin n → F) i = 0 := by
    intro i hi
    simpa using congrFun (LinearMap.mem_ker.1 hc) ⟨i, hi⟩
  have h1 := hammingNorm_le_of_vanishing hvan
  have h2 := hC c c.2 hc0
  omega

/-! ## The Singleton bound -/

/-- **Singleton bound** for an arbitrary linear code `C ≤ (Fin n → F)`: if every nonzero
codeword has Hamming weight at least `d`, and `1 ≤ d ≤ n`, then `finrank C + d ≤ n + 1`.

The proof punctures the code at `d - 1` coordinates: the restriction of `C` to the remaining
`n - d + 1` coordinates is injective, since a codeword vanishing there would have weight at
most `d - 1`. -/
theorem singleton_bound {C : Submodule F (Fin n → F)} {d : ℕ} (hd : 1 ≤ d) (hdn : d ≤ n)
    (hC : ∀ c ∈ C, c ≠ 0 → d ≤ hammingNorm c) :
    finrank F C + d ≤ n + 1 := by
  obtain ⟨S, -, hS⟩ := Finset.exists_subset_card_eq
    (show n + 1 - d ≤ #(univ : Finset (Fin n)) by simp; omega)
  have hinj : Injective (restrict C S) := restrict_injective hC (by omega)
  have hle : finrank F C ≤ finrank F ({x // x ∈ S} → F) :=
    LinearMap.finrank_le_finrank_of_injective hinj
  have hcard : finrank F ({x // x ∈ S} → F) = n + 1 - d := by simp [hS]
  omega

/-! ## Minimum distance and the MDS property -/

/-- The minimum distance of a linear code: the least Hamming weight of a nonzero codeword. -/
noncomputable def minDist (C : Submodule F (Fin n → F)) : ℕ :=
  sInf {d | ∃ c ∈ C, c ≠ 0 ∧ hammingNorm c = d}

omit [DecidableEq F] in
/-- The all-ones vector is a Reed–Solomon codeword whenever `k ≥ 1`. -/
theorem one_mem_code {α : Fin n → F} (hk : 1 ≤ k) : (fun _ => (1 : F)) ∈ code k α := by
  refine ⟨⟨1, ?_⟩, ?_⟩
  · rw [mem_degreeLT]
    exact lt_of_le_of_lt degree_one_le (by exact_mod_cast Nat.cast_lt.2 hk)
  · funext i; simp

/-- If some nonzero codeword exists, the minimum distance is attained. -/
theorem minDist_mem {C : Submodule F (Fin n → F)} (h : ∃ c ∈ C, c ≠ 0) :
    ∃ c ∈ C, c ≠ 0 ∧ hammingNorm c = minDist C := by
  obtain ⟨c, hc, hc0⟩ := h
  have hne : {d | ∃ c ∈ C, c ≠ 0 ∧ hammingNorm c = d}.Nonempty := ⟨hammingNorm c, c, hc, hc0, rfl⟩
  exact Nat.sInf_mem hne

omit [DecidableEq F] in
/-- A nonzero Reed–Solomon codeword exists as soon as `1 ≤ k` and `0 < n`. -/
theorem exists_nonzero_codeword {α : Fin n → F} (hk : 1 ≤ k) (hn : 0 < n) :
    ∃ c ∈ code k α, c ≠ 0 :=
  ⟨_, one_mem_code (α := α) hk, fun h => one_ne_zero (congrFun h ⟨0, hn⟩)⟩

/-- **Lower bound for the Reed–Solomon minimum distance** (from root counting). -/
theorem le_minDist_code {α : Fin n → F} (hα : Injective α) (hk : 1 ≤ k) (hkn : k ≤ n) :
    n - k + 1 ≤ minDist (code k α) := by
  obtain ⟨c, hc, hc0, hnorm⟩ := minDist_mem (exists_nonzero_codeword (α := α) hk (by omega))
  have := weight_lower_bound hα hk hkn hc hc0
  omega

/-- **Upper bound for the Reed–Solomon minimum distance** (from the Singleton bound applied to
the code, whose dimension is `k`). -/
theorem minDist_code_le {α : Fin n → F} (hα : Injective α) (hk : 1 ≤ k) (hkn : k ≤ n) :
    minDist (code k α) ≤ n - k + 1 := by
  obtain ⟨c, hc, hc0, hnorm⟩ := minDist_mem (exists_nonzero_codeword (α := α) hk (by omega))
  have hdle : minDist (code k α) ≤ n := by
    rw [← hnorm]
    simpa using (hammingNorm_le_card_fintype (x := c))
  have hd1 : 1 ≤ minDist (code k α) := by
    rw [← hnorm]
    exact hammingNorm_pos_iff.2 hc0
  have hlow : ∀ c ∈ code k α, c ≠ 0 → minDist (code k α) ≤ hammingNorm c :=
    fun c hc hc0 => Nat.sInf_le ⟨c, hc, hc0, rfl⟩
  have hsb := singleton_bound hd1 hdle hlow
  rw [finrank_code hα hkn] at hsb
  omega

/-- **Reed–Solomon codes are MDS**: the minimum distance is exactly `n - k + 1`. -/
theorem minDist_code {α : Fin n → F} (hα : Injective α) (hk : 1 ≤ k) (hkn : k ≤ n) :
    minDist (code k α) = n - k + 1 :=
  le_antisymm (minDist_code_le hα hk hkn) (le_minDist_code hα hk hkn)

/-- **The Singleton bound is attained by Reed–Solomon codes**: `dim + distance = n + 1`. -/
theorem singleton_equality {α : Fin n → F} (hα : Injective α) (hk : 1 ≤ k) (hkn : k ≤ n) :
    finrank F (code k α) + minDist (code k α) = n + 1 := by
  rw [finrank_code hα hkn, minDist_code hα hk hkn]
  omega

/-! ## An explicit minimum-weight codeword -/

/-- An explicit codeword of minimal weight: for a set `T` of `k - 1` evaluation points, the
polynomial `∏ i ∈ T, (X - C (α i))` has degree `k - 1 < k` and its evaluation vector vanishes
exactly on `T`, hence has weight `n - (k - 1) = n - k + 1`. -/
theorem exists_codeword_of_weight {α : Fin n → F} (hα : Injective α) (hk : 1 ≤ k) (hkn : k ≤ n) :
    ∃ c ∈ code k α, c ≠ 0 ∧ hammingNorm c = n - k + 1 := by
  obtain ⟨T, -, hT⟩ := Finset.exists_subset_card_eq
    (show k - 1 ≤ #(univ : Finset (Fin n)) by simp; omega)
  set p : F[X] := ∏ i ∈ T, (X - C (α i)) with hp
  have hmonic : p.Monic := monic_prod_of_monic _ _ fun i _ => monic_X_sub_C _
  have hpdeg : p.natDegree = k - 1 := by
    rw [hp, natDegree_prod _ _ fun i _ => X_sub_C_ne_zero (α i)]
    simp [hT]
  have hmem : p ∈ degreeLT F k := by
    rw [mem_degreeLT, degree_eq_natDegree hmonic.ne_zero, hpdeg]
    exact_mod_cast (by omega : k - 1 < k)
  have heval : ∀ j : Fin n, p.eval (α j) = 0 ↔ j ∈ T := by
    intro j
    rw [hp, eval_prod, Finset.prod_eq_zero_iff]
    constructor
    · rintro ⟨i, hi, hzero⟩
      simp only [eval_sub, eval_X, eval_C, sub_eq_zero] at hzero
      rw [hα hzero]; exact hi
    · intro hj
      exact ⟨j, hj, by simp⟩
  have hzeroset : ∀ i, encoder k α ⟨p, hmem⟩ i = 0 ↔ i ∈ T := fun i => by
    simpa using heval i
  refine ⟨encoder k α ⟨p, hmem⟩, ⟨⟨p, hmem⟩, rfl⟩, ?_, ?_⟩
  · intro h
    have hall : ∀ j : Fin n, j ∈ T := fun j => (hzeroset j).1 (by
      have := congrFun h j
      simpa using this)
    have hn : n ≤ #T := by
      have := Finset.card_le_card (fun j (_ : j ∈ (univ : Finset (Fin n))) => hall j)
      simpa using this
    omega
  · have := hammingNorm_eq_card_compl hzeroset
    omega

/-! ## Information sets: the MDS characterization

A `k`-dimensional code is MDS exactly when **every** set of `k` coordinates is an information
set, i.e. the restriction to those coordinates is a linear isomorphism onto `F^k`. -/

/-- **MDS ⇒ information sets.** If a `k`-dimensional code has all nonzero weights `≥ n-k+1`,
then restricting to any `k` coordinates is a linear isomorphism. -/
theorem restrict_bijective_of_mds {C : Submodule F (Fin n → F)} (hrank : finrank F C = k)
    (hC : ∀ c ∈ C, c ≠ 0 → n - k + 1 ≤ hammingNorm c) {S : Finset (Fin n)} (hS : #S = k) :
    Bijective (restrict C S) := by
  have hinj : Injective (restrict C S) := restrict_injective hC (by omega)
  have hdim : finrank F C = finrank F ({x // x ∈ S} → F) := by simp [hrank, hS]
  exact ⟨hinj, (LinearMap.injective_iff_surjective_of_finrank_eq_finrank hdim).1 hinj⟩

/-- **Information sets ⇒ MDS.** If restricting a `k`-dimensional code to every set of `k`
coordinates is injective, then every nonzero codeword has weight at least `n - k + 1`. -/
theorem mds_of_restrict_injective {C : Submodule F (Fin n → F)} (hkn : k ≤ n)
    (hres : ∀ S : Finset (Fin n), #S = k → Injective (restrict C S)) :
    ∀ c ∈ C, c ≠ 0 → n - k + 1 ≤ hammingNorm c := by
  intro c hc hc0
  by_contra hlt
  push_neg at hlt
  -- the zero set of `c` has at least `k` elements
  set Z : Finset (Fin n) := univ.filter (fun i => c i = 0) with hZ
  have hnorm : hammingNorm c = n - #Z := hammingNorm_eq_card_compl (fun i => by simp [hZ])
  have hZcard : #Z ≤ n := by simpa using Finset.card_le_univ Z
  have hk : k ≤ #Z := by omega
  obtain ⟨S, hSZ, hS⟩ := Finset.exists_subset_card_eq hk
  have hvan : ∀ i ∈ S, c i = 0 := by
    intro i hi
    simpa [hZ] using (Finset.mem_filter.1 (hSZ hi)).2
  have : (⟨c, hc⟩ : C) = 0 := by
    refine hres S hS ?_
    funext i
    simpa using hvan i i.2
  exact hc0 (congrArg Subtype.val this)

/-- Any `k` coordinates form an information set for a Reed–Solomon code. -/
theorem code_restrict_bijective {α : Fin n → F} (hα : Injective α) (hk : 1 ≤ k) (hkn : k ≤ n)
    {S : Finset (Fin n)} (hS : #S = k) : Bijective (restrict (code k α) S) :=
  restrict_bijective_of_mds (finrank_code hα hkn)
    (fun _ hc hc0 => weight_lower_bound hα hk hkn hc hc0) hS

/-- **Lagrange interpolation, coding-theoretic form.** For any `k` coordinates and any
prescribed values there is a unique Reed–Solomon codeword taking those values. -/
theorem exists_unique_codeword_on {α : Fin n → F} (hα : Injective α) (hk : 1 ≤ k) (hkn : k ≤ n)
    {S : Finset (Fin n)} (hS : #S = k) (v : {x // x ∈ S} → F) :
    ∃! c : code k α, ∀ i : {x // x ∈ S}, (c : Fin n → F) (i : Fin n) = v i := by
  obtain ⟨hinj, hsurj⟩ := code_restrict_bijective hα hk hkn hS
  obtain ⟨c, hcv⟩ := hsurj v
  refine ⟨c, fun i => by simpa using congrFun hcv i, fun c' hc' => ?_⟩
  refine hinj ?_
  funext i
  rw [restrict_apply, hc' i, ← congrFun hcv i, restrict_apply]

/-- **Erasure correction.** Two Reed–Solomon codewords agreeing on at least `k` coordinates
coincide: any `n - k` erasures can be corrected. -/
theorem eq_of_agree_on {α : Fin n → F} (hα : Injective α) (hk : 1 ≤ k) (hkn : k ≤ n)
    {S : Finset (Fin n)} (hS : k ≤ #S) {c₁ c₂ : Fin n → F} (h₁ : c₁ ∈ code k α)
    (h₂ : c₂ ∈ code k α) (hagree : ∀ i ∈ S, c₁ i = c₂ i) : c₁ = c₂ := by
  by_contra hne
  have hsub : c₁ - c₂ ∈ code k α := Submodule.sub_mem _ h₁ h₂
  have hsub0 : c₁ - c₂ ≠ 0 := fun h => hne (sub_eq_zero.1 h)
  have hlow := weight_lower_bound hα hk hkn hsub hsub0
  have hvan : ∀ i ∈ S, (c₁ - c₂) i = 0 := fun i hi => by
    simp [Pi.sub_apply, hagree i hi]
  have hup := hammingNorm_le_of_vanishing hvan
  have hcard : #S ≤ n := by simpa using Finset.card_le_univ S
  omega

/-! ## Error correction radius -/

/-- **Unique decoding.** If `2t < n - k + 1`, then any received word has at most one
Reed–Solomon codeword within Hamming distance `t`. -/
theorem unique_decoding {α : Fin n → F} (hα : Injective α) (hk : 1 ≤ k) (hkn : k ≤ n) {t : ℕ}
    (ht : 2 * t < n - k + 1) {y c₁ c₂ : Fin n → F} (h₁ : c₁ ∈ code k α) (h₂ : c₂ ∈ code k α)
    (hd₁ : hammingDist y c₁ ≤ t) (hd₂ : hammingDist y c₂ ≤ t) : c₁ = c₂ := by
  by_contra hne
  have htri : hammingDist c₁ c₂ ≤ hammingDist c₁ y + hammingDist y c₂ :=
    hammingDist_triangle c₁ y c₂
  have h1y : hammingDist c₁ y = hammingDist y c₁ := hammingDist_comm _ _
  have hsub : c₁ - c₂ ∈ code k α := Submodule.sub_mem _ h₁ h₂
  have hsub0 : c₁ - c₂ ≠ 0 := fun h => hne (sub_eq_zero.1 h)
  have hlow := weight_lower_bound hα hk hkn hsub hsub0
  have heq : hammingDist c₁ c₂ = hammingNorm (c₁ - c₂) := hammingDist_eq_hammingNorm _ _
  omega

/-- The Reed–Solomon code corrects any `t ≤ (n - k) / 2` errors uniquely. -/
theorem unique_decoding_half {α : Fin n → F} (hα : Injective α) (hk : 1 ≤ k) (hkn : k ≤ n)
    {t : ℕ} (ht : t ≤ (n - k) / 2) {y c₁ c₂ : Fin n → F} (h₁ : c₁ ∈ code k α)
    (h₂ : c₂ ∈ code k α) (hd₁ : hammingDist y c₁ ≤ t) (hd₂ : hammingDist y c₂ ≤ t) :
    c₁ = c₂ :=
  unique_decoding hα hk hkn (by omega) h₁ h₂ hd₁ hd₂

/-! ## The dual code and MDS duality -/

/-- The standard identification `F^n ≃ (F^n)*` coming from the standard basis; it turns the
standard bilinear form `⟨x, y⟩ = ∑ x i * y i` into evaluation of functionals. -/
noncomputable def stdDualEquiv (F : Type*) [Field F] (n : ℕ) :
    (Fin n → F) ≃ₗ[F] Module.Dual F (Fin n → F) :=
  (Pi.basisFun F (Fin n)).toDualEquiv

omit [DecidableEq F] in
lemma stdDualEquiv_apply (y x : Fin n → F) : stdDualEquiv F n y x = ∑ i, y i * x i := by
  have hx : ∑ i, x i • (Pi.basisFun F (Fin n)) i = x := by
    simpa using (Pi.basisFun F (Fin n)).sum_repr x
  have hval : stdDualEquiv F n y x
      = (Pi.basisFun F (Fin n)).toDual y (∑ i, x i • (Pi.basisFun F (Fin n)) i) := by
    rw [hx]; rfl
  rw [hval, map_sum]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [map_smul, Basis.toDual_apply_left, Pi.basisFun_repr, smul_eq_mul, mul_comm]

/-- The **dual code** of `C` with respect to the standard bilinear form. -/
def dualCode (C : Submodule F (Fin n → F)) : Submodule F (Fin n → F) where
  carrier := {y | ∀ c ∈ C, ∑ i, y i * c i = 0}
  zero_mem' := by intro c _; simp
  add_mem' := by
    intro a b ha hb c hc
    simp only [Set.mem_setOf_eq, Pi.add_apply, add_mul] at *
    rw [Finset.sum_add_distrib, ha c hc, hb c hc, add_zero]
  smul_mem' := by
    intro r a ha c hc
    simp only [Set.mem_setOf_eq, Pi.smul_apply, smul_eq_mul, mul_assoc] at *
    rw [← Finset.mul_sum, ha c hc, mul_zero]

omit [DecidableEq F] in
@[simp] lemma mem_dualCode {C : Submodule F (Fin n → F)} {y : Fin n → F} :
    y ∈ dualCode C ↔ ∀ c ∈ C, ∑ i, y i * c i = 0 := Iff.rfl

omit [DecidableEq F] in
/-- The dual code is the image of the dual annihilator under the standard identification. -/
theorem dualCode_eq_map (C : Submodule F (Fin n → F)) :
    dualCode C = Submodule.map (stdDualEquiv F n).symm.toLinearMap C.dualAnnihilator := by
  ext y
  rw [Submodule.mem_map_equiv]
  simp only [LinearEquiv.symm_symm, Submodule.mem_dualAnnihilator, mem_dualCode,
    stdDualEquiv_apply]

omit [DecidableEq F] in
/-- **Dimension of the dual code**: `dim C + dim C⊥ = n`. -/
theorem finrank_add_finrank_dualCode (C : Submodule F (Fin n → F)) :
    finrank F C + finrank F (dualCode C) = n := by
  have h1 : finrank F (dualCode C) = finrank F C.dualAnnihilator := by
    rw [dualCode_eq_map]
    exact LinearEquiv.finrank_map_eq (stdDualEquiv F n).symm C.dualAnnihilator
  have h2 := Subspace.finrank_add_finrank_dualAnnihilator_eq C
  simpa [h1] using h2

/-- **The dual of an MDS code is MDS (weight bound).** If `C` has dimension `k` and every
nonzero codeword has weight at least `n - k + 1`, then every nonzero codeword of `C⊥` has
weight at least `k + 1`.

The proof uses that every set of `k` coordinates is an information set for `C`: given a dual
codeword `y` of weight at most `k`, enlarge its support to a `k`-set `T` and pick `c ∈ C`
restricting on `T` to the indicator of a coordinate `j` where `y j ≠ 0`; then `⟨y, c⟩ = y j ≠ 0`,
contradicting `y ∈ C⊥`. -/
theorem dual_weight_lower_bound {C : Submodule F (Fin n → F)} (hrank : finrank F C = k)
    (hkn : k ≤ n) (hC : ∀ c ∈ C, c ≠ 0 → n - k + 1 ≤ hammingNorm c)
    {y : Fin n → F} (hy : y ∈ dualCode C) (hy0 : y ≠ 0) : k + 1 ≤ hammingNorm y := by
  by_contra hlt
  push_neg at hlt
  set Sy : Finset (Fin n) := univ.filter (fun i => y i ≠ 0) with hSy
  have hnormSy : hammingNorm y = #Sy := rfl
  have hSycard : #Sy ≤ k := by omega
  obtain ⟨T, hST, -, hT⟩ :=
    Finset.exists_subsuperset_card_eq (Finset.subset_univ Sy) hSycard (by simpa using hkn)
  obtain ⟨j, hj⟩ : ∃ j, y j ≠ 0 := Function.ne_iff.1 hy0
  have hjS : j ∈ Sy := by simp [hSy, hj]
  obtain ⟨-, hsurj⟩ := restrict_bijective_of_mds hrank hC hT
  obtain ⟨c, hc⟩ := hsurj (fun i => if (i : Fin n) = j then 1 else 0)
  have hcval : ∀ i ∈ T, (c : Fin n → F) i = if i = j then 1 else 0 := by
    intro i hi
    simpa using congrFun hc ⟨i, hi⟩
  have hzero : ∑ i, y i * (c : Fin n → F) i = 0 := hy _ c.2
  have h1 : ∑ i ∈ Sy, y i * (c : Fin n → F) i = ∑ i, y i * (c : Fin n → F) i := by
    refine Finset.sum_subset (Finset.subset_univ Sy) ?_
    intro i _ hi
    simp only [hSy, Finset.mem_filter, Finset.mem_univ, true_and, not_not] at hi
    simp [hi]
  have h2 : ∑ i ∈ Sy, y i * (c : Fin n → F) i = y j := by
    rw [Finset.sum_congr rfl fun i hi => by rw [hcval i (hST hi)]]
    simp [Finset.sum_ite_eq' Sy j, hjS, mul_ite]
  exact hj (by rw [← h2, h1, hzero])

omit [DecidableEq F] in
/-- The dual of a Reed–Solomon code has dimension `n - k`. -/
theorem finrank_dualCode_code {α : Fin n → F} (hα : Injective α) (hkn : k ≤ n) :
    finrank F (dualCode (code k α)) = n - k := by
  have h := finrank_add_finrank_dualCode (code k α)
  rw [finrank_code hα hkn] at h
  omega

/-- **The dual of a Reed–Solomon code is MDS**: its minimum distance is exactly `k + 1`,
matching the Singleton bound for its dimension `n - k`. -/
theorem minDist_dualCode_code {α : Fin n → F} (hα : Injective α) (hk : 1 ≤ k) (hkn : k < n) :
    minDist (dualCode (code k α)) = k + 1 := by
  have hkle : k ≤ n := le_of_lt hkn
  have hfr : finrank F (dualCode (code k α)) = n - k := finrank_dualCode_code hα hkle
  have hne : dualCode (code k α) ≠ ⊥ := by
    intro h
    rw [h, finrank_bot] at hfr
    omega
  obtain ⟨y, hy, hy0, hnorm⟩ := minDist_mem (Submodule.exists_mem_ne_zero_of_ne_bot hne)
  have hlowAll : ∀ z ∈ dualCode (code k α), z ≠ 0 → k + 1 ≤ hammingNorm z := fun z hz hz0 =>
    dual_weight_lower_bound (finrank_code hα hkle) hkle
      (fun c hc hc0 => weight_lower_bound hα hk hkle hc hc0) hz hz0
  have hlow : k + 1 ≤ minDist (dualCode (code k α)) := by
    have := hlowAll y hy hy0
    omega
  have hdle : minDist (dualCode (code k α)) ≤ n := by
    rw [← hnorm]
    simpa using (hammingNorm_le_card_fintype (x := y))
  have hd1 : 1 ≤ minDist (dualCode (code k α)) := by omega
  have hminAll : ∀ z ∈ dualCode (code k α), z ≠ 0 →
      minDist (dualCode (code k α)) ≤ hammingNorm z :=
    fun z hz hz0 => Nat.sInf_le ⟨z, hz, hz0, rfl⟩
  have hsb := singleton_bound hd1 hdle hminAll
  rw [hfr] at hsb
  omega

/-! ## A concrete instance over `ZMod 5` -/

section Example

private lemma prime_five : Nat.Prime 5 := by norm_num

local instance : Fact (Nat.Prime 5) := ⟨prime_five⟩

/-- The five evaluation points `0, 1, 2, 3, 4` of `ZMod 5`. -/
def pts5 : Fin 5 → ZMod 5 := fun i => ((i : ℕ) : ZMod 5)

/-- The evaluation points `0, 1, 2, 3, 4` of `ZMod 5` are distinct. -/
theorem zmod5_points_injective : Injective pts5 := by decide

/-- The `[5, 3]` Reed–Solomon code over `ZMod 5` has dimension `3`, minimum distance `3`,
and its dual is a `[5, 2]` code of minimum distance `4`. -/
theorem rs_zmod5_parameters :
    finrank (ZMod 5) (code 3 pts5) = 3 ∧
      minDist (code 3 pts5) = 3 ∧
      finrank (ZMod 5) (dualCode (code 3 pts5)) = 2 ∧
      minDist (dualCode (code 3 pts5)) = 4 :=
  ⟨finrank_code zmod5_points_injective (by norm_num),
   minDist_code zmod5_points_injective (by norm_num) (by norm_num),
   finrank_dualCode_code zmod5_points_injective (by norm_num),
   minDist_dualCode_code zmod5_points_injective (by norm_num) (by norm_num)⟩

end Example

end ReedSolomonMDS