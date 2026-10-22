import Computation.FourierFunctor.Sharpness

/-!
# Rigidity: the converse of the equality case of the uncertainty principle

`Sharpness.lean` proves that every **modulated coset indicator**
`g ↦ c · χ(g) · 1_K(g − a)` attains equality in the Donoho–Stark bound
`|G| ≤ |supp f| · |supp 𝓕f|`.  This file proves the **converse**, which was
recorded as conjecture C2 in `FUTURE_DIRECTIONS.md`:

* `donoho_stark_rigidity` — if `f ≠ 0` satisfies
  `|supp f| · |supp 𝓕f| = |G|`, then there are a subgroup `K ≤ G`, a point
  `a ∈ G`, a character `χ` and a scalar `c ≠ 0` with
  `f g = if g − a ∈ K then c · χ g else 0`;
* `donoho_stark_equality_iff` — the resulting classification: equality holds
  **iff** `f` is a modulated coset indicator.

## The argument

Let `A = supp f`, `B = supp 𝓕f`, `M = max ‖f‖` attained at `a`, `N = |G|`.

1. Fourier inversion at `a` gives `N·M ≤ ∑_{ψ ∈ B} ‖𝓕f ψ‖`, while the triangle
   inequality gives `‖𝓕f ψ‖ ≤ |A|·M` for every `ψ`.  Since `|A|·|B| = N`, both
   chains are equalities, so `‖𝓕f ψ‖ = |A|·M` for **every** `ψ ∈ B`
   (`norm_fourier_eq_of_equality`).
2. Equality in the triangle inequality for `𝓕f ψ = ∑_{g ∈ A} f g · ψ(−g)`
   forces every summand to have the same argument and modulus `M`; hence for
   each `ψ ∈ B` there is `c ≠ 0` with `f = c·ψ` on `A`
   (`exists_scalar_eq_char_on_support`).
3. Consequently all `ψ ∈ B` agree on `A − a`, i.e. `A − a` is contained in the
   subgroup `fourierPeriod f` on which the characters of `B` all agree.
4. Conversely, inversion shows `f (g + x) = ψ₀ x · f g` for `x ∈ fourierPeriod f`
   (`translate_of_mem_fourierPeriod`), so `A` is stable under translation by
   `fourierPeriod f`; with `a ∈ A` this gives `A = a + fourierPeriod f` and the
   explicit formula for `f`.

Note that no divisibility hypothesis is imposed: the fact that `|supp f|`
divides `|G|` is a *consequence* of the theorem.

-- !-- Lab Notes -- !--

* Hypothesizer: the two extremal families already proved (Dirac masses and
  modulated coset indicators) should exhaust the equality case; the obstruction
  to proving it was thought to be a classification of finite abelian groups, but
  the argument above needs none.
* Experimenter: the crucial technical step is the equality case of the complex
  triangle inequality.  Rather than invoking a strict-convexity lemma we rotate
  by `u = conj(𝓕f ψ)/‖𝓕f ψ‖` and compare real parts, reducing everything to
  `Finset.sum_eq_sum_iff_of_le` and the elementary fact `z.re = ‖z‖ → z = ‖z‖`
  (`eq_norm_of_re_eq_norm`).
* Analyst: step 4 is the only place where inversion is used a second time, and
  it is what upgrades "`A − a` lies in a subgroup" to "`A − a` *is* that
  subgroup"; without it one only obtains `|supp f| ≤ |fourierPeriod f|`.
* Critic: `f ≠ 0` is necessary (the zero function has `|supp f|·|supp 𝓕f| = 0`).
  The subgroup produced is canonical — it is `fourierPeriod f`, the common
  period lattice of the characters occurring in `f` — while `a`, `χ` and `c` are
  only determined up to the obvious ambiguities.
-/

open CategoryTheory AddChar Finset
open scoped Classical

namespace FourierFunctor

variable {G : Type} [AddCommGroup G] [Fintype G]

/-! ### Two elementary lemmas -/

/-- A complex number whose real part equals its modulus **is** that modulus.
This is the equality case of `Complex.re_le_norm`. -/
lemma eq_norm_of_re_eq_norm {z : ℂ} (h : z.re = ‖z‖) : z = (‖z‖ : ℂ) := by
  have h2 : ‖z‖ ^ 2 = z.re ^ 2 + z.im ^ 2 := by
    rw [Complex.sq_norm, Complex.normSq_apply]; ring
  rw [← h] at h2
  have him : z.im = 0 := by nlinarith [sq_nonneg z.im]
  apply Complex.ext <;> simp [him, ← h]

/-- Fourier inversion in `ℓ¹` form: `|G|·‖f g‖` is at most the `ℓ¹` norm of the
transform, the sum being taken over its support. -/
theorem card_mul_norm_le_sum_norm_fourier (f : G → ℂ) (g : G) :
    (Fintype.card G : ℝ) * ‖f g‖ ≤ ∑ ψ ∈ support (fourier f), ‖fourier f ψ‖ := by
  classical
  have hinv : f g = (Fintype.card G : ℂ)⁻¹ * ∑ ψ : AddChar G ℂ, fourier f ψ * ψ g := by
    conv_lhs => rw [← fourierInv_fourier f]
    rw [fourierInv_apply]
  have hnorm : ‖f g‖ = (Fintype.card G : ℝ)⁻¹ * ‖∑ ψ : AddChar G ℂ, fourier f ψ * ψ g‖ := by
    rw [hinv, norm_mul, norm_inv]; simp
  have h2 : ∀ ψ : AddChar G ℂ, ‖fourier f ψ * ψ g‖ = ‖fourier f ψ‖ := by
    intro ψ; rw [norm_mul, ψ.norm_apply, mul_one]
  have h3 : (∑ ψ : AddChar G ℂ, ‖fourier f ψ * ψ g‖)
      = ∑ ψ ∈ support (fourier f), ‖fourier f ψ‖ := by
    rw [Finset.sum_congr rfl fun ψ _ => h2 ψ]
    refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
    intro ψ _ hψ
    have : fourier f ψ = 0 := by
      by_contra hne; exact hψ (mem_support.2 hne)
    simp [this]
  have hcard : (0 : ℝ) < (Fintype.card G : ℝ) := by
    exact_mod_cast Fintype.card_pos_iff.2 ⟨(0 : G)⟩
  have key : ‖f g‖ ≤ (Fintype.card G : ℝ)⁻¹ * ∑ ψ ∈ support (fourier f), ‖fourier f ψ‖ := by
    rw [hnorm]
    refine mul_le_mul_of_nonneg_left ?_ (by positivity)
    calc ‖∑ ψ : AddChar G ℂ, fourier f ψ * ψ g‖
        ≤ ∑ ψ : AddChar G ℂ, ‖fourier f ψ * ψ g‖ := norm_sum_le _ _
      _ = ∑ ψ ∈ support (fourier f), ‖fourier f ψ‖ := h3
  calc (Fintype.card G : ℝ) * ‖f g‖
      ≤ (Fintype.card G : ℝ) *
          ((Fintype.card G : ℝ)⁻¹ * ∑ ψ ∈ support (fourier f), ‖fourier f ψ‖) :=
        mul_le_mul_of_nonneg_left key hcard.le
    _ = ∑ ψ ∈ support (fourier f), ‖fourier f ψ‖ := by field_simp

/-! ### Step 1: the transform has constant modulus on its support -/

/-- **First rigidity step.**  If the Donoho–Stark bound is an equality then the
transform has constant modulus `|supp f| · max‖f‖` on its whole support. -/
theorem norm_fourier_eq_of_equality (f : G → ℂ) (a : G) (M : ℝ) (hMdef : M = ‖f a‖)
    (hM : ∀ g, ‖f g‖ ≤ M)
    (heq : (support f).card * (support (fourier f)).card = Fintype.card G)
    (ψ : AddChar G ℂ) (hψ : ψ ∈ support (fourier f)) :
    ‖fourier f ψ‖ = (support f).card * M := by
  classical
  set A := support f with hA
  set B := support (fourier f) with hB
  have h1 : ∀ χ : AddChar G ℂ, ‖fourier f χ‖ ≤ A.card * M :=
    fun χ => norm_fourier_le_card_support_mul f M hM χ
  have h2 : (Fintype.card G : ℝ) * M ≤ ∑ χ ∈ B, ‖fourier f χ‖ := by
    rw [hMdef]; exact card_mul_norm_le_sum_norm_fourier f a
  have hcast : ((A.card : ℝ) * B.card) = (Fintype.card G : ℝ) := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) heq
  have h4 : (∑ _χ ∈ B, ((A.card : ℝ) * M)) = (Fintype.card G : ℝ) * M := by
    rw [Finset.sum_const, nsmul_eq_mul, ← hcast]; ring
  have hle : ∀ χ ∈ B, ‖fourier f χ‖ ≤ (A.card : ℝ) * M := fun χ _ => h1 χ
  have hsum : (∑ χ ∈ B, ‖fourier f χ‖) = ∑ _χ ∈ B, ((A.card : ℝ) * M) := by
    have h3 : (∑ χ ∈ B, ‖fourier f χ‖) ≤ ∑ _χ ∈ B, ((A.card : ℝ) * M) :=
      Finset.sum_le_sum hle
    rw [h4] at h3 ⊢
    linarith
  exact (Finset.sum_eq_sum_iff_of_le hle).1 hsum ψ hψ

/-! ### Step 2: on its support, `f` is a multiple of each extremal character -/

/-- **Second rigidity step.**  Equality forces, for every character `ψ` in the
support of the transform, that `f` agrees with a non-zero multiple of `ψ` on the
whole support of `f`.  This is the equality case of the triangle inequality. -/
theorem exists_scalar_eq_char_on_support (f : G → ℂ) (a : G) (M : ℝ) (hMdef : M = ‖f a‖)
    (hMpos : 0 < M) (hM : ∀ g, ‖f g‖ ≤ M)
    (heq : (support f).card * (support (fourier f)).card = Fintype.card G)
    (ψ : AddChar G ℂ) (hψ : ψ ∈ support (fourier f)) :
    ∃ c : ℂ, c ≠ 0 ∧ ∀ g ∈ support f, f g = c * ψ g := by
  classical
  have hznorm : ‖fourier f ψ‖ = ((support f).card : ℝ) * M :=
    norm_fourier_eq_of_equality f a M hMdef hM heq ψ hψ
  have hzne : fourier f ψ ≠ 0 := mem_support.1 hψ
  have hzpos : 0 < ‖fourier f ψ‖ := norm_pos_iff.2 hzne
  -- the rotation making the transform value positive
  obtain ⟨u, hunorm, huz⟩ :
      ∃ u : ℂ, ‖u‖ = 1 ∧ u * fourier f ψ = ((‖fourier f ψ‖ : ℝ) : ℂ) := by
    refine ⟨(starRingEnd ℂ) (fourier f ψ) / ((‖fourier f ψ‖ : ℝ) : ℂ), ?_, ?_⟩
    · rw [norm_div, RCLike.norm_conj]
      simp [hzpos.ne']
    · rw [div_mul_eq_mul_div, mul_comm, Complex.mul_conj,
        show Complex.normSq (fourier f ψ) = ‖fourier f ψ‖ ^ 2 from (Complex.sq_norm _).symm]
      push_cast
      field_simp
  have hune : u ≠ 0 := by
    intro h
    rw [h, zero_mul] at huz
    exact hzpos.ne' (by exact_mod_cast huz.symm)
  -- restrict the transform to the support of `f`
  have hzsum : fourier f ψ = ∑ g ∈ support f, f g * ψ (-g) := by
    rw [fourier_apply]
    refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
    intro g _ hg
    have : f g = 0 := by
      by_contra hne; exact hg (mem_support.2 hne)
    simp [this]
  -- compare real parts
  have hnormterm : ∀ g : G, ‖u * (f g * ψ (-g))‖ = ‖f g‖ := by
    intro g
    rw [norm_mul, norm_mul, hunorm, ψ.norm_apply, one_mul, mul_one]
  have hFsum : (∑ g ∈ support f, (u * (f g * ψ (-g))).re) = ((support f).card : ℝ) * M := by
    have hre : (∑ g ∈ support f, (u * (f g * ψ (-g))).re) = (u * fourier f ψ).re := by
      rw [hzsum, Finset.mul_sum, Complex.re_sum]
    rw [hre, huz, Complex.ofReal_re, hznorm]
  have hFle : ∀ g ∈ support f, (u * (f g * ψ (-g))).re ≤ M := by
    intro g _
    calc (u * (f g * ψ (-g))).re ≤ ‖u * (f g * ψ (-g))‖ := Complex.re_le_norm _
      _ = ‖f g‖ := hnormterm g
      _ ≤ M := hM g
  have hFeq : ∀ g ∈ support f, (u * (f g * ψ (-g))).re = M := by
    refine (Finset.sum_eq_sum_iff_of_le hFle).1 ?_
    rw [hFsum, Finset.sum_const, nsmul_eq_mul]
  -- hence every term is the positive real `M`
  have hterm : ∀ g ∈ support f, u * (f g * ψ (-g)) = (M : ℂ) := by
    intro g hg
    have h1 : ‖u * (f g * ψ (-g))‖ ≤ M := by rw [hnormterm g]; exact hM g
    have h2 : M ≤ ‖u * (f g * ψ (-g))‖ := by
      rw [← hFeq g hg]; exact Complex.re_le_norm _
    have h3 : ‖u * (f g * ψ (-g))‖ = M := le_antisymm h1 h2
    have h4 : (u * (f g * ψ (-g))).re = ‖u * (f g * ψ (-g))‖ := by rw [h3, hFeq g hg]
    rw [eq_norm_of_re_eq_norm h4, h3]
  refine ⟨(M : ℂ) * u⁻¹, ?_, ?_⟩
  · exact mul_ne_zero (by exact_mod_cast hMpos.ne') (inv_ne_zero hune)
  · intro g hg
    have hψg : ψ (-g) * ψ g = 1 := by
      rw [← ψ.map_add_eq_mul]; simp
    calc f g = f g * (ψ (-g) * ψ g) := by rw [hψg, mul_one]
      _ = u⁻¹ * (u * (f g * ψ (-g))) * ψ g := by
          rw [inv_mul_cancel_left₀ hune]; ring
      _ = (M : ℂ) * u⁻¹ * ψ g := by rw [hterm g hg]; ring

/-! ### The period subgroup -/

/-- The subgroup of `G` on which **all** characters occurring in the Fourier
transform of `f` agree.  For a modulated coset indicator supported on `a + K`
this is exactly `K`. -/
def fourierPeriod (f : G → ℂ) : AddSubgroup G where
  carrier := {x | ∀ ψ ∈ support (fourier f), ∀ ψ' ∈ support (fourier f), ψ x = ψ' x}
  zero_mem' := by
    intro ψ _ ψ' _
    simp [AddChar.map_zero_eq_one]
  add_mem' := by
    intro x y hx hy ψ hψ ψ' hψ'
    rw [ψ.map_add_eq_mul, ψ'.map_add_eq_mul, hx ψ hψ ψ' hψ', hy ψ hψ ψ' hψ']
  neg_mem' := by
    intro x hx ψ hψ ψ' hψ'
    rw [ψ.map_neg_eq_inv, ψ'.map_neg_eq_inv, hx ψ hψ ψ' hψ']

lemma mem_fourierPeriod {f : G → ℂ} {x : G} :
    x ∈ fourierPeriod f ↔
      ∀ ψ ∈ support (fourier f), ∀ ψ' ∈ support (fourier f), ψ x = ψ' x := Iff.rfl

/-- **Quasi-periodicity.**  Translating `f` by an element of its period subgroup
multiplies it by a single character value; in particular the support of `f` is
invariant under `fourierPeriod f`. -/
theorem translate_of_mem_fourierPeriod (f : G → ℂ) {x : G} (hx : x ∈ fourierPeriod f)
    {ψ₀ : AddChar G ℂ} (hψ₀ : ψ₀ ∈ support (fourier f)) (g : G) :
    f (g + x) = ψ₀ x * f g := by
  classical
  have hinv : ∀ y : G, f y = (Fintype.card G : ℂ)⁻¹ * ∑ ψ : AddChar G ℂ, fourier f ψ * ψ y := by
    intro y
    conv_lhs => rw [← fourierInv_fourier f]
    rw [fourierInv_apply]
  have hterm : ∀ ψ : AddChar G ℂ,
      fourier f ψ * ψ (g + x) = ψ₀ x * (fourier f ψ * ψ g) := by
    intro ψ
    by_cases hψ : ψ ∈ support (fourier f)
    · rw [ψ.map_add_eq_mul, mem_fourierPeriod.1 hx ψ hψ ψ₀ hψ₀]; ring
    · have h0 : fourier f ψ = 0 := by
        by_contra hne; exact hψ (mem_support.2 hne)
      rw [h0]; ring
  rw [hinv (g + x), Finset.sum_congr rfl fun ψ _ => hterm ψ, ← Finset.mul_sum, hinv g]
  ring

/-! ### The classification -/

/-- **Donoho–Stark rigidity.**  A non-zero function attaining equality in the
uncertainty principle is a scalar multiple of a character times the indicator of
a coset of a subgroup: `f g = c · χ g` on `a + K` and `0` elsewhere.  Together
with `donoho_stark_equality_coset` this classifies the extremal functions. -/
theorem donoho_stark_rigidity (f : G → ℂ) (hf : f ≠ 0)
    (heq : (support f).card * (support (fourier f)).card = Fintype.card G) :
    ∃ (K : AddSubgroup G) (a : G) (χ : AddChar G ℂ) (c : ℂ), c ≠ 0 ∧
      ∀ g, f g = if g - a ∈ K then c * χ g else 0 := by
  classical
  -- a point where `‖f‖` is maximal
  obtain ⟨a, -, ha⟩ :=
    Finset.exists_max_image (Finset.univ : Finset G) (fun g => ‖f g‖) ⟨0, Finset.mem_univ 0⟩
  set M : ℝ := ‖f a‖ with hMdef
  have hM : ∀ g, ‖f g‖ ≤ M := fun g => ha g (Finset.mem_univ g)
  have hMpos : 0 < M := by
    obtain ⟨g, hg⟩ := support_nonempty_of_ne_zero hf
    exact lt_of_lt_of_le (norm_pos_iff.2 (mem_support.1 hg)) (hM g)
  have haA : a ∈ support f := mem_support.2 (by
    intro h
    rw [h] at hMdef
    simp [hMdef] at hMpos)
  have hfa : f a ≠ 0 := mem_support.1 haA
  -- the support of the transform is non-empty
  have hBne : (support (fourier f)).Nonempty := by
    refine support_nonempty_of_ne_zero (f := fourier f) ?_
    intro h
    refine hf ?_
    have : fourierInv (fourier (G := G) f) = fourierInv 0 := by rw [h]
    rw [fourierInv_fourier f] at this
    simpa using this
  obtain ⟨ψ₀, hψ₀⟩ := hBne
  -- Step 3: the support of `f`, translated to the origin, lies in the period subgroup
  have hchar : ∀ ψ ∈ support (fourier f), ∀ g ∈ support f, ψ (g - a) * f a = f g := by
    intro ψ hψ g hg
    obtain ⟨c, hcne, hc⟩ :=
      exists_scalar_eq_char_on_support f a M hMdef hMpos hM heq ψ hψ
    have hga : ψ (g - a) = ψ g * ψ (-a) := by
      rw [show g - a = g + -a by abel, ψ.map_add_eq_mul]
    have hinv : ψ (-a) * ψ a = 1 := by
      rw [← ψ.map_add_eq_mul]; simp
    rw [hga, hc g hg, hc a haA]
    calc ψ g * ψ (-a) * (c * ψ a) = c * ψ g * (ψ (-a) * ψ a) := by ring
      _ = c * ψ g := by rw [hinv, mul_one]
  have hsub : ∀ g ∈ support f, g - a ∈ fourierPeriod f := by
    intro g hg ψ hψ ψ' hψ'
    have h1 := hchar ψ hψ g hg
    have h2 := hchar ψ' hψ' g hg
    have := h1.trans h2.symm
    exact mul_right_cancel₀ hfa this
  refine ⟨fourierPeriod f, a, ψ₀, f a * ψ₀ (-a), ?_, ?_⟩
  · exact mul_ne_zero hfa (addChar_apply_ne_zero ψ₀ (-a))
  · intro g
    by_cases hgK : g - a ∈ fourierPeriod f
    · rw [if_pos hgK]
      have hga : f (a + (g - a)) = ψ₀ (g - a) * f a :=
        translate_of_mem_fourierPeriod f hgK hψ₀ a
      have hsimp : a + (g - a) = g := by abel
      rw [hsimp] at hga
      have hexp : ψ₀ (g - a) = ψ₀ g * ψ₀ (-a) := by
        rw [show g - a = g + -a by abel, ψ₀.map_add_eq_mul]
      rw [hga, hexp]; ring
    · rw [if_neg hgK]
      by_contra hne
      exact hgK (hsub g (mem_support.2 hne))

omit [Fintype G] in
/-- The extremal function produced by `donoho_stark_rigidity` is exactly a
scalar multiple of a modulated coset indicator of `Sharpness.lean`. -/
lemma cosetFun_eq_ite (K : AddSubgroup G) (a : G) (χ : AddChar G ℂ) (g : G) :
    cosetFun K a χ g = if g - a ∈ K then χ g else 0 := by
  by_cases h : g - a ∈ K <;> simp [cosetFun, indicator, h]

omit [AddCommGroup G] in
lemma support_smul {c : ℂ} (hc : c ≠ 0) (h : G → ℂ) :
    support (fun g => c * h g) = support h := by
  ext g
  simp [mem_support, hc]

omit [Fintype G] in
/-- An extremal function in the sense of `donoho_stark_rigidity` is literally a
scalar multiple of a modulated coset indicator. -/
lemma eq_smul_cosetFun (f : G → ℂ) {K : AddSubgroup G} {a : G} {χ : AddChar G ℂ} {c : ℂ}
    (hfeq : ∀ g, f g = if g - a ∈ K then c * χ g else 0) :
    f = fun g => c * cosetFun K a χ g := by
  funext g
  rw [hfeq g, cosetFun_eq_ite]
  by_cases h : g - a ∈ K <;> simp [h]

/-- **Classification of the equality case (conjecture C2, closed).**  For a
non-zero function on a finite abelian group, the Donoho–Stark inequality is an
equality **iff** the function is a non-zero scalar multiple of a character times
the indicator of a coset of a subgroup. -/
theorem donoho_stark_equality_iff (f : G → ℂ) (hf : f ≠ 0) :
    (support f).card * (support (fourier f)).card = Fintype.card G ↔
      ∃ (K : AddSubgroup G) (a : G) (χ : AddChar G ℂ) (c : ℂ), c ≠ 0 ∧
        ∀ g, f g = if g - a ∈ K then c * χ g else 0 := by
  classical
  refine ⟨donoho_stark_rigidity f hf, ?_⟩
  rintro ⟨K, a, χ, c, hc, hfeq⟩
  have hf_eq : f = fun g => c * cosetFun K a χ g := eq_smul_cosetFun f hfeq
  have hsupp : support f = support (cosetFun K a χ) := by
    rw [hf_eq]; exact support_smul hc _
  have hfour : ∀ ψ : AddChar G ℂ, fourier f ψ = c * fourier (cosetFun K a χ) ψ := by
    intro ψ
    rw [hf_eq]
    rw [show (fun g => c * cosetFun K a χ g) = c • cosetFun K a χ from rfl,
      map_smul]
    simp
  have hsupp2 : support (fourier f) = support (fourier (cosetFun K a χ)) := by
    have : fourier f = fun ψ => c * fourier (cosetFun K a χ) ψ := funext hfour
    rw [this]; exact support_smul hc _
  rw [hsupp, hsupp2]
  exact donoho_stark_equality_coset K a χ

/-- Non-vacuity of the rigidity theorem: Dirac masses do satisfy its hypothesis
(by `donoho_stark_sharp`), so the classification has content. -/
theorem exists_coset_form_delta (a : G) :
    ∃ (K : AddSubgroup G) (b : G) (χ : AddChar G ℂ) (c : ℂ), c ≠ 0 ∧
      ∀ g, delta a g = if g - b ∈ K then c * χ g else 0 :=
  donoho_stark_rigidity (delta a) (delta_ne_zero a) (donoho_stark_sharp a)

/-! ### A divisibility consequence -/

/-- **The support of an extremal function is a coset**, so its cardinality
divides the order of the group.  This is a genuinely new obstruction: it is not
visible from the inequality `|G| ≤ |supp f|·|supp 𝓕f|` itself. -/
theorem card_support_dvd_of_equality (f : G → ℂ) (hf : f ≠ 0)
    (heq : (support f).card * (support (fourier f)).card = Fintype.card G) :
    (support f).card ∣ Fintype.card G := by
  classical
  obtain ⟨K, a, χ, c, hc, hfeq⟩ := donoho_stark_rigidity f hf heq
  have hcard : (support f).card = Nat.card K := by
    rw [eq_smul_cosetFun f hfeq, support_smul hc, card_support_cosetFun]
  rw [hcard, ← Nat.card_eq_fintype_card]
  exact AddSubgroup.card_addSubgroup_dvd_card K

/-- **Strict uncertainty.**  If the size of the support of `f` does not divide
`|G|` then the Donoho–Stark inequality is strict. -/
theorem donoho_stark_strict_of_not_dvd (f : G → ℂ) (hf : f ≠ 0)
    (hdvd : ¬ ((support f).card ∣ Fintype.card G)) :
    Fintype.card G < (support f).card * (support (fourier f)).card :=
  (donoho_stark f hf).lt_of_ne fun h => hdvd (card_support_dvd_of_equality f hf h.symm)

end FourierFunctor