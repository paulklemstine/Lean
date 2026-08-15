import Mathlib
import Tropical.NeuralNetworks.EOSWidthTropicalSeparation

/-!
# From the tropical mechanism to a one-sided cure *probability*

`EOSWidthTropicalSeparation` shows that an EOS with an exclusive dimension is
unboundedly separable from the digit atoms, while an EOS living inside the digit
block has a uniformly bounded margin.  This file turns that dichotomy into the
probabilistic law observed in NET-26.

The learned boundary embedding is random (it depends on the seed).  Modelling
the learned EOS as a coefficient vector `c : Fin D → ℝ` on the digit block, the
main structural result is an exact criterion:

* `separable_eosOf_iff` — a block-supported EOS is separable from *all* digit
  atoms by *some* max-plus readout **iff** at least one of its coefficients is
  strictly positive.

Since a random coefficient vector satisfies this only sometimes, the cure event
in the fragile regime `E ≤ D` has a probability strictly inside `(0,1)`, while
in the robust regime `E > D` it is identically `1`:

* `cureProb_lt_one`, `cureProb_pos`, `cureProb_robust_eq_one`,
  `one_sided_distribution_shift` — the formal statement of
  EOS-WIDTH-DISTRIBUTION-SHIFT at the level of the model.
* `separable_mono` and `eosVec_le_of_le` give the *one-sidedness*: widening the
  boundary token can never destroy separability.
* `signSeed_cureProb` — a concrete seed model (`±1` coefficients) where the
  fragile cure probability is computed exactly and is neither `0` nor `1`.
-/

namespace EOSWidth

open Finset

/-! ## Part 1: separability and its monotonicity in the boundary token -/

/-- A boundary vector is *separable* when some max-plus readout scores it
strictly above every digit atom. -/
def Separable (N D : ℕ) (x : TVec N) : Prop :=
  ∃ w : TVec N, ∀ j : Fin D, score w (digit N D j) < score w x

lemma score_mono {N : ℕ} (w : TVec N) {x y : TVec N} (h : ∀ i, x i ≤ y i) :
    score w x ≤ score w y := by
  refine Finset.sup_le ?_
  intro i _
  exact le_trans (add_le_add (le_refl (w i)) (h i))
    (Finset.le_sup (f := fun i => w i + y i) (mem_univ i))

/-- **One-sidedness.**  Enlarging the boundary token coordinatewise (in
particular, widening a zero-padded EOS) can never destroy separability. -/
theorem separable_mono {N D : ℕ} {x y : TVec N} (hxy : ∀ i, x i ≤ y i)
    (hx : Separable N D x) : Separable N D y := by
  obtain ⟨w, hw⟩ := hx
  exact ⟨w, fun j => lt_of_lt_of_le (hw j) (score_mono w hxy)⟩

/-- Zero-padded EOS embeddings are monotone in their width. -/
theorem eosVec_le_of_le {N E E' : ℕ} (h : E ≤ E') (i : Fin N) :
    eosVec N E i ≤ eosVec N E' i := by
  by_cases h1 : (i : ℕ) < E
  · simp [eosVec, h1, (by omega : (i : ℕ) < E')]
  · simp [eosVec, h1]

/-- Consequently the cure event is monotone in the EOS width: this is the
"one-sided" half of EOS-WIDTH-DISTRIBUTION-SHIFT. -/
theorem separable_eosVec_mono {N D E E' : ℕ} (h : E ≤ E')
    (hE : Separable N D (eosVec N E)) : Separable N D (eosVec N E') :=
  separable_mono (eosVec_le_of_le h) hE

/-! ## Part 2: the exact separability criterion inside the digit block -/

/-- A *learned* boundary embedding supported on the digit block, with real
coefficients `c`. -/
def eosOf {N D : ℕ} (c : Fin D → ℝ) : TVec N :=
  fun i => if h : (i : ℕ) < D then ((c ⟨(i : ℕ), h⟩ : ℝ) : WithBot ℝ) else ⊥

lemma eosOf_apply_castLE {N D : ℕ} (hDN : D ≤ N) (c : Fin D → ℝ) (j : Fin D) :
    (eosOf c : TVec N) (Fin.castLE hDN j) = ((c j : ℝ) : WithBot ℝ) := by
  unfold eosOf
  have hj : ((Fin.castLE hDN j : Fin N) : ℕ) < D := by simp
  rw [dif_pos hj]
  congr 2

lemma eosOf_noExclusiveDim {N D : ℕ} (c : Fin D → ℝ) :
    NoExclusiveDim N D (eosOf c : TVec N) := by
  intro i hi
  unfold eosOf
  rw [dif_neg (by omega)]

/-- **The exact criterion.**  A block-supported boundary embedding is separable
from the digit atoms iff one of its coefficients is strictly positive.  The
"only if" half is the tropical margin bound; the "if" half is an explicit
single-coordinate readout. -/
theorem separable_eosOf_iff {N D : ℕ} (hDN : D ≤ N) (hD : 0 < D) (c : Fin D → ℝ) :
    Separable N D (eosOf c : TVec N) ↔ ∃ i : Fin D, 0 < c i := by
  constructor
  · rintro ⟨w, hw⟩
    by_contra hc
    push_neg at hc
    -- all coefficients are ≤ 0, so the tropical margin bound forbids separation
    have hsupc : (univ.sup fun j : Fin D => (eosOf c : TVec N) (Fin.castLE hDN j))
        ≤ (0 : WithBot ℝ) := by
      refine Finset.sup_le ?_
      intro j _
      rw [eosOf_apply_castLE]
      exact_mod_cast hc j
    have hbound := margin_le_of_no_exclusive_dim hDN (eosOf c : TVec N)
      (eosOf_noExclusiveDim c) w
    have hstep : (univ.sup fun j : Fin D => (eosOf c : TVec N) (Fin.castLE hDN j))
        + (univ.sup fun j : Fin D => score w (digit N D j))
        ≤ 0 + univ.sup fun j : Fin D => score w (digit N D j) :=
      add_le_add hsupc (le_refl _)
    rw [zero_add] at hstep
    have hle : score w (eosOf c : TVec N) ≤ univ.sup fun j : Fin D => score w (digit N D j) :=
      le_trans hbound hstep
    -- but separation forces the strict opposite inequality
    have hbot : (⊥ : WithBot ℝ) < score w (eosOf c : TVec N) :=
      lt_of_le_of_lt bot_le (hw ⟨0, hD⟩)
    have hlt : (univ.sup fun j : Fin D => score w (digit N D j)) < score w (eosOf c : TVec N) := by
      rw [Finset.sup_lt_iff hbot]
      intro j _
      exact hw j
    exact absurd hle (not_le.mpr hlt)
  · rintro ⟨i, hi⟩
    refine ⟨probe (Fin.castLE hDN i) 0, ?_⟩
    intro j
    rw [score_probe, score_probe, eosOf_apply_castLE]
    have hrhs : ((0 : ℝ) : WithBot ℝ) + ((c i : ℝ) : WithBot ℝ) = ((c i : ℝ) : WithBot ℝ) := by
      norm_num
    rw [hrhs]
    by_cases hji : (i : ℕ) = (j : ℕ)
    · have hdj : digit N D j (Fin.castLE hDN i) = 0 := by
        simp only [digit, Fin.val_castLE]
        rw [if_pos hji]
      rw [hdj]
      have hz : ((0 : ℝ) : WithBot ℝ) + (0 : WithBot ℝ) = ((0 : ℝ) : WithBot ℝ) := by norm_num
      rw [hz]
      exact_mod_cast hi
    · have hdj : digit N D j (Fin.castLE hDN i) = ⊥ := by
        refine digit_apply_of_ne j _ ?_
        simpa using hji
      rw [hdj]
      simp

/-- The tropical sup of the coefficients of a block-supported boundary
embedding is attained at a maximising coefficient. -/
lemma sup_eosOf_eq {N D : ℕ} (hDN : D ≤ N) (c : Fin D → ℝ) {i : Fin D}
    (hi : ∀ j : Fin D, c j ≤ c i) :
    (univ.sup fun j : Fin D => (eosOf c : TVec N) (Fin.castLE hDN j))
      = ((c i : ℝ) : WithBot ℝ) := by
  refine le_antisymm (Finset.sup_le ?_) ?_
  · intro j _
    rw [eosOf_apply_castLE]
    exact_mod_cast hi j
  · rw [← eosOf_apply_castLE hDN c i]
    exact Finset.le_sup (f := fun j : Fin D => (eosOf c : TVec N) (Fin.castLE hDN j))
      (mem_univ i)

/-- **The margin bound is sharp.**  In the fragile regime the uniform bound of
`margin_le_of_no_exclusive_dim` is attained: some readout realises exactly the
largest boundary coefficient as its margin over the digit atoms.  So the best
achievable boundary-vs-digit margin is *exactly* `maxᵢ cᵢ`, which is positive
precisely on the seeds that cure. -/
theorem margin_bound_sharp {N D : ℕ} (hDN : D ≤ N) (hD : 0 < D) (c : Fin D → ℝ) :
    ∃ w : TVec N, score w (eosOf c : TVec N) =
      (univ.sup fun j : Fin D => (eosOf c : TVec N) (Fin.castLE hDN j))
        + (univ.sup fun j : Fin D => score w (digit N D j)) := by
  classical
  obtain ⟨i, -, hi⟩ := Finset.exists_max_image (univ : Finset (Fin D)) c
    ⟨⟨0, hD⟩, mem_univ _⟩
  have hi' : ∀ j : Fin D, c j ≤ c i := fun j => hi j (mem_univ j)
  refine ⟨probe (Fin.castLE hDN i) 0, ?_⟩
  have hleft : score (probe (Fin.castLE hDN i) 0) (eosOf c : TVec N)
      = ((c i : ℝ) : WithBot ℝ) := by
    rw [score_probe, eosOf_apply_castLE]
    norm_num
  have hdig : (univ.sup fun j : Fin D => score (probe (Fin.castLE hDN i) 0) (digit N D j))
      = (0 : WithBot ℝ) := by
    refine le_antisymm (Finset.sup_le ?_) ?_
    · intro j _
      rw [score_probe]
      by_cases hji : (i : ℕ) = (j : ℕ)
      · have hdj : digit N D j (Fin.castLE hDN i) = 0 := by
          simp only [digit, Fin.val_castLE]
          rw [if_pos hji]
        rw [hdj]
        norm_num
      · rw [digit_apply_of_ne j _ (by simpa using hji)]
        simp
    · have hii : digit N D i (Fin.castLE hDN i) = 0 := by
        simp [digit]
      calc (0 : WithBot ℝ) = score (probe (Fin.castLE hDN i) 0) (digit N D i) := by
            rw [score_probe, hii]; norm_num
        _ ≤ _ := Finset.le_sup
            (f := fun j : Fin D => score (probe (Fin.castLE hDN i) 0) (digit N D j))
            (mem_univ i)
  rw [hleft, sup_eosOf_eq hDN c hi', hdig, add_zero]

/-- **The robust regime is deterministic.**  Any boundary token owning a
dimension outside the digit block is separable — no matter what the seed did. -/
theorem separable_of_exclusiveDim {N D : ℕ} (x : TVec N) {p : Fin N}
    (hp : ExclusiveDim N D x p) : Separable N D x := by
  obtain ⟨w, hM, hdig⟩ := exclusive_dim_unbounded_margin x hp 0
  refine ⟨w, fun j => ?_⟩
  rw [hdig j]
  exact lt_of_lt_of_le (WithBot.bot_lt_coe (0 : ℝ)) hM

/-- A zero-padded EOS of width `E > D` is separable. -/
theorem separable_eosVec_of_gt {N D E : ℕ} (hDN : D < N) (hDE : D < E) :
    Separable N D (eosVec N E) := by
  refine separable_of_exclusiveDim (p := ⟨D, hDN⟩) _ ⟨by simp, ?_⟩
  simp only [eosVec]
  rw [if_pos (show ((⟨D, hDN⟩ : Fin N) : ℕ) < E from hDE)]
  exact fun h => absurd h.symm (by simp)

/-! ## Part 3: the cure probability -/

/-- Uniform probability of an event on a finite seed space. -/
def cureProb {Ω : Type} [Fintype Ω] (S : Finset Ω) : ℚ := S.card / Fintype.card Ω

/-- The set of seeds on which a (not necessarily decidable) cure predicate
holds. -/
noncomputable def cureSet {Ω : Type} [Fintype Ω] (P : Ω → Prop) : Finset Ω := by
  classical
  exact univ.filter P

lemma mem_cureSet {Ω : Type} [Fintype Ω] (P : Ω → Prop) (o : Ω) :
    o ∈ cureSet P ↔ P o := by
  classical
  simp [cureSet]

/-- The cure event of the fragile regime `E ≤ D`, as a set of seeds. -/
noncomputable def fragileCureSet {Ω : Type} [Fintype Ω] (N D : ℕ)
    (c : Ω → Fin D → ℝ) : Finset Ω :=
  cureSet (fun o => Separable N D (eosOf (c o) : TVec N))

/-- Membership in the fragile cure set is the positive-coefficient criterion. -/
theorem mem_fragileCureSet_iff {Ω : Type} [Fintype Ω] {N D : ℕ}
    (hDN : D ≤ N) (hD : 0 < D) (c : Ω → Fin D → ℝ) (o : Ω) :
    o ∈ fragileCureSet N D c ↔ ∃ i : Fin D, 0 < c o i := by
  rw [fragileCureSet, mem_cureSet, separable_eosOf_iff hDN hD]

/-- If some seed produces an all-nonpositive embedding, the fragile cure
probability is `< 1`. -/
theorem cureProb_lt_one {Ω : Type} [Fintype Ω] {N D : ℕ} (hDN : D ≤ N) (hD : 0 < D)
    (c : Ω → Fin D → ℝ) {o : Ω} (ho : ∀ i, c o i ≤ 0) :
    cureProb (fragileCureSet N D c) < 1 := by
  classical
  have hne : o ∉ fragileCureSet N D c := by
    rw [mem_fragileCureSet_iff hDN hD]
    push_neg
    exact ho
  have hcard : (fragileCureSet N D c).card < Fintype.card Ω := by
    have hsub : fragileCureSet N D c ⊂ univ :=
      ⟨subset_univ _, fun h => hne (h (mem_univ o))⟩
    rw [← Finset.card_univ]
    exact Finset.card_lt_card hsub
  have hpos : (0 : ℚ) < Fintype.card Ω := by
    have : 0 < Fintype.card Ω := Fintype.card_pos_iff.mpr ⟨o⟩
    exact_mod_cast this
  rw [cureProb, div_lt_one hpos]
  exact_mod_cast hcard

/-- If some seed produces an embedding with a positive coefficient, the fragile
cure probability is `> 0`. -/
theorem cureProb_pos {Ω : Type} [Fintype Ω] {N D : ℕ} (hDN : D ≤ N) (hD : 0 < D)
    (c : Ω → Fin D → ℝ) {o : Ω} {i : Fin D} (ho : 0 < c o i) :
    0 < cureProb (fragileCureSet N D c) := by
  classical
  have hmem : o ∈ fragileCureSet N D c := by
    rw [mem_fragileCureSet_iff hDN hD]; exact ⟨i, ho⟩
  have hcard : 0 < (fragileCureSet N D c).card := Finset.card_pos.mpr ⟨o, hmem⟩
  have hpos : (0 : ℚ) < Fintype.card Ω := by
    have : 0 < Fintype.card Ω := Fintype.card_pos_iff.mpr ⟨o⟩
    exact_mod_cast this
  apply div_pos _ hpos
  exact_mod_cast hcard

/-- In the robust regime every seed cures: the cure set is the whole seed
space, of probability `1`. -/
theorem cureProb_robust_eq_one {Ω : Type} [Fintype Ω] [Nonempty Ω] {N D E : ℕ}
    (hDN : D < N) (hDE : D < E) :
    cureProb (cureSet (fun _ : Ω => Separable N D (eosVec N E))) = 1 := by
  classical
  have hall : cureSet (fun _ : Ω => Separable N D (eosVec N E)) = univ := by
    apply Finset.eq_univ_of_forall
    intro o
    rw [mem_cureSet]
    exact separable_eosVec_of_gt hDN hDE
  have hpos : (0 : ℚ) < Fintype.card Ω := by
    have : 0 < Fintype.card Ω := Fintype.card_pos
    exact_mod_cast this
  rw [cureProb, hall, Finset.card_univ]
  field_simp

/-- **EOS-WIDTH-DISTRIBUTION-SHIFT (model form).**  With a seed distribution
that can produce both an all-nonpositive and a positive coefficient, the fragile
regime `E ≤ D` cures with probability strictly between `0` and `1`, while the
robust regime `E > D` cures with probability `1`: a one-sided distribution
shift, never a sharp deterministic boundary. -/
theorem one_sided_distribution_shift {Ω : Type} [Fintype Ω] [Nonempty Ω] {N D E : ℕ}
    (hDN : D < N) (hD : 0 < D) (hDE : D < E) (c : Ω → Fin D → ℝ)
    {o₀ o₁ : Ω} {i₁ : Fin D} (h0 : ∀ i, c o₀ i ≤ 0) (h1 : 0 < c o₁ i₁) :
    0 < cureProb (fragileCureSet N D c) ∧
      cureProb (fragileCureSet N D c) <
        cureProb (cureSet (fun _ : Ω => Separable N D (eosVec N E))) := by
  refine ⟨cureProb_pos (le_of_lt hDN) hD c h1, ?_⟩
  rw [cureProb_robust_eq_one hDN hDE]
  exact cureProb_lt_one (le_of_lt hDN) hD c h0

/-! ## Part 4: a concrete seed model -/

/-- A two-seed `±1` model on a one-dimensional digit block: seed `0` learns a
positive boundary coefficient and cures, seed `1` learns a negative one and
fails.  The fragile cure probability is exactly `1/2` — strictly interior,
exactly as the empirical `3/12` is. -/
theorem signSeed_cureProb {N : ℕ} (hN : 1 ≤ N) :
    cureProb (fragileCureSet N 1 (fun o : Fin 2 => fun _ : Fin 1 =>
      if o = 0 then (1 : ℝ) else -1)) = 1 / 2 := by
  classical
  have hset : fragileCureSet N 1
      (fun o : Fin 2 => fun _ : Fin 1 => if o = 0 then (1 : ℝ) else -1) = {0} := by
    ext o
    rw [mem_fragileCureSet_iff hN (by norm_num)]
    fin_cases o <;> simp
  rw [cureProb, hset]
  simp

end EOSWidth