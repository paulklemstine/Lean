import Mathlib

/-!
# Almost-lossless compression: the ε-relaxed counting bound

This file is the foundation of a small formal theory of *almost-lossless*
(one-shot, fixed-length) source compression.  The guiding question is the one
from the research thread *Compression Beyond the Pigeonhole Bound*:

> Pigeonhole governs exact decoding of **all** strings.  If we only ask that the
> decoder succeed with probability `≥ 1 - ε`, how far does the counting bound
> relax, and can a random number generator (shared randomness) help?

## Contents

* `AlmostLossless.Code` : an encoder/decoder pair `S → C → Option S`.
* `AlmostLossless.Honest` : *no silent corruption* — on every source word the
  decoder either returns the correct word or explicitly declares failure.
* `AlmostLossless.card_correct_le_card_code` : the pigeonhole core, the set of
  correctly decoded words injects into the code alphabet.
* `AlmostLossless.uniform_failProb_lower` : for a uniform source the failure
  probability is at least `1 - |C|/|S|`; equivalently
  `AlmostLossless.card_code_ge_of_failProb_le` : an `ε`-reliable code needs
  `|C| ≥ (1-ε)|S|`.  This is *exactly* how much the counting bound relaxes.
* `AlmostLossless.randomized_avg_failProb_lower` : the same bound holds for the
  average failure probability of an arbitrary **randomized** ensemble of codes,
  i.e. a random number generator buys nothing at all on a uniform source.
* `AlmostLossless.tableCode` and `AlmostLossless.failProb_tableCode_le` : the
  matching achievability statement.  Any *typical set* `T` of probability
  `≥ 1 - ε` yields an honest code with alphabet of size `|T| + 1` and failure
  probability `≤ ε`, with `O(1)` (single table lookup) decoding.

Everything is finite and rational-valued: probabilities are explicit finite
sums, so all statements are elementary and fully constructive in content.
-/

namespace AlmostLossless

open Finset

/-- A fixed-length code: an encoder `enc : S → C` together with a decoder
`dec : C → Option S`, where `none` is an explicit *decoding failure* symbol. -/
structure Code (S C : Type*) where
  /-- The encoder. -/
  enc : S → C
  /-- The decoder; `none` means "I refuse to decode". -/
  dec : C → Option S

variable {S C : Type*}

/-- The source word `s` is decoded correctly. -/
def Correct (K : Code S C) (s : S) : Prop := K.dec (K.enc s) = some s

instance [DecidableEq S] (K : Code S C) (s : S) : Decidable (Correct K s) := by
  unfold Correct; infer_instance

/-- **No silent corruption**: on every source word the decoder either returns
the true word or explicitly aborts.  It never returns a *wrong* word. -/
def Honest (K : Code S C) : Prop :=
  ∀ s, K.dec (K.enc s) = some s ∨ K.dec (K.enc s) = none

theorem honest_iff (K : Code S C) :
    Honest K ↔ ∀ s t, K.dec (K.enc s) = some t → t = s := by
  constructor
  · intro h s t hst
    rcases h s with h' | h' <;> rw [h'] at hst
    · exact (Option.some_inj.mp hst).symm
    · exact absurd hst (by simp)
  · intro h s
    rcases hd : K.dec (K.enc s) with _ | t
    · exact Or.inr rfl
    · have hts := h s t hd
      subst hts
      exact Or.inl rfl

/-! ## The pigeonhole core -/

/-- The heart of the matter: distinct correctly-decoded source words must get
distinct codewords, so the correctly-decoded set injects into the code
alphabet.  No honesty or probability is involved. -/
theorem card_correct_le_card_code [Fintype S] [DecidableEq S] [Fintype C]
    (K : Code S C) : ({s | Correct K s} : Finset S).card ≤ Fintype.card C := by
  classical
  have hinj : ∀ a ∈ ({s | Correct K s} : Finset S), ∀ b ∈ ({s | Correct K s} : Finset S),
      K.enc a = K.enc b → a = b := by
    intro a ha b hb hab
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at ha hb
    have : (some a : Option S) = some b := by
      unfold Correct at ha hb
      rw [← ha, ← hb, hab]
    exact Option.some_inj.mp this
  calc ({s | Correct K s} : Finset S).card
      ≤ (Finset.univ : Finset C).card :=
        Finset.card_le_card_of_injOn K.enc (fun _ _ => Finset.mem_univ _) hinj
    _ = Fintype.card C := rfl

/-- Pigeonhole, failure form: at least `|S| - |C|` source words fail to decode. -/
theorem card_incorrect_ge [Fintype S] [DecidableEq S] [Fintype C] (K : Code S C) :
    Fintype.card S - Fintype.card C ≤ ({s | ¬ Correct K s} : Finset S).card := by
  classical
  have hsplit := Finset.card_filter_add_card_filter_not
    (s := (Finset.univ : Finset S)) (p := fun s => Correct K s)
  have := card_correct_le_card_code K
  simp only [Finset.card_univ] at hsplit
  omega

/-! ## Sources and failure probability -/

/-- A finitely supported probability distribution with rational weights. -/
structure Source (S : Type*) [Fintype S] where
  /-- The probability weight of each source word. -/
  w : S → ℚ
  /-- Weights are nonnegative. -/
  nonneg : ∀ s, 0 ≤ w s
  /-- Weights sum to one. -/
  total : ∑ s, w s = 1

variable [Fintype S]

/-- Probability of an event (a finite set of source words). -/
def Source.prob (μ : Source S) (A : Finset S) : ℚ := ∑ s ∈ A, μ.w s

/-- The probability that the decoder does **not** return the true source word. -/
def failProb [DecidableEq S] (μ : Source S) (K : Code S C) : ℚ :=
  ∑ s ∈ ({s | ¬ Correct K s} : Finset S), μ.w s

theorem failProb_nonneg [DecidableEq S] (μ : Source S) (K : Code S C) :
    0 ≤ failProb μ K :=
  Finset.sum_nonneg fun s _ => μ.nonneg s

/-- A failure probability is at most one. -/
theorem failProb_le_one [DecidableEq S] (μ : Source S) (K : Code S C) :
    failProb μ K ≤ 1 := by
  classical
  calc failProb μ K ≤ ∑ s, μ.w s :=
        Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
          (fun s _ _ => μ.nonneg s)
    _ = 1 := μ.total

/-- **Generic achievability lemma.**  If a code decodes every word of a set `T`
of probability at least `1 - ε` correctly, it fails with probability at most
`ε`.  All achievability results below are instances of this. -/
theorem failProb_le_of_correct_on [DecidableEq S] (μ : Source S) (K : Code S C)
    (T : Finset S) (hcor : ∀ s ∈ T, Correct K s) (ε : ℚ) (hT : 1 - ε ≤ μ.prob T) :
    failProb μ K ≤ ε := by
  classical
  have hsub : ({s | ¬ Correct K s} : Finset S) ⊆ Tᶜ := by
    intro s hs
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hs
    simp only [Finset.mem_compl]
    intro hsT
    exact hs (hcor s hsT)
  have h1 : failProb μ K ≤ ∑ s ∈ Tᶜ, μ.w s :=
    Finset.sum_le_sum_of_subset_of_nonneg hsub (fun s _ _ => μ.nonneg s)
  have h2 : ∑ s ∈ Tᶜ, μ.w s = 1 - μ.prob T := by
    have := Finset.sum_add_sum_compl T μ.w
    rw [μ.total] at this
    simp only [Source.prob]
    linarith
  linarith

/-- The uniform source on a nonempty finite alphabet. -/
def uniformSource [Nonempty S] : Source S where
  w _ := (Fintype.card S : ℚ)⁻¹
  nonneg _ := by positivity
  total := by
    have h : (Fintype.card S : ℚ) ≠ 0 := by
      have := Fintype.card_pos (α := S); positivity
    simp [Finset.sum_const, Finset.card_univ]

/-! ## The ε-relaxed counting bound (converse) -/

/-- **The counting bound, relaxed by `ε`.**  For a uniform source, every code
(honest or not) fails with probability at least `1 - |C|/|S|`. -/
theorem uniform_failProb_lower [DecidableEq S] [Nonempty S] [Fintype C] (K : Code S C) :
    1 - (Fintype.card C : ℚ) / (Fintype.card S : ℚ) ≤ failProb uniformSource K := by
  classical
  have hS : (0 : ℚ) < (Fintype.card S : ℚ) := by
    exact_mod_cast Fintype.card_pos (α := S)
  have hsplit := Finset.card_filter_add_card_filter_not
    (s := (Finset.univ : Finset S)) (p := fun s => Correct K s)
  simp only [Finset.card_univ] at hsplit
  have hc := card_correct_le_card_code K
  have hcount : (Fintype.card S : ℚ) - (Fintype.card C : ℚ)
      ≤ (({s | ¬ Correct K s} : Finset S).card : ℚ) := by
    have e1 : ((({s | Correct K s} : Finset S).card : ℚ))
        + (({s | ¬ Correct K s} : Finset S).card : ℚ) = (Fintype.card S : ℚ) := by
      exact_mod_cast hsplit
    have e2 : ((({s | Correct K s} : Finset S).card : ℚ)) ≤ (Fintype.card C : ℚ) := by
      exact_mod_cast hc
    linarith
  have hfp : failProb uniformSource K
      = (({s | ¬ Correct K s} : Finset S).card : ℚ) / (Fintype.card S : ℚ) := by
    simp [failProb, uniformSource, Finset.sum_const, nsmul_eq_mul, div_eq_mul_inv]
  rw [hfp, le_div_iff₀ hS]
  have : (1 - (Fintype.card C : ℚ) / (Fintype.card S : ℚ)) * (Fintype.card S : ℚ)
      = (Fintype.card S : ℚ) - (Fintype.card C : ℚ) := by
    field_simp
  rw [this]
  exact hcount

/-- Contrapositive form: an `ε`-reliable code for a uniform source needs a code
alphabet of size at least `(1-ε)|S|`.  The pigeonhole bound relaxes by exactly
the factor `1 - ε`, and by nothing more. -/
theorem card_code_ge_of_failProb_le [DecidableEq S] [Nonempty S] [Fintype C]
    (K : Code S C) (ε : ℚ) (h : failProb uniformSource K ≤ ε) :
    (1 - ε) * (Fintype.card S : ℚ) ≤ (Fintype.card C : ℚ) := by
  have hS : (0 : ℚ) < (Fintype.card S : ℚ) := by
    exact_mod_cast Fintype.card_pos (α := S)
  have h1 := uniform_failProb_lower (S := S) (C := C) K
  have : 1 - (Fintype.card C : ℚ) / (Fintype.card S : ℚ) ≤ ε := le_trans h1 h
  have h2 : (1 - ε) ≤ (Fintype.card C : ℚ) / (Fintype.card S : ℚ) := by linarith
  calc (1 - ε) * (Fintype.card S : ℚ)
      ≤ ((Fintype.card C : ℚ) / (Fintype.card S : ℚ)) * (Fintype.card S : ℚ) := by
        exact mul_le_mul_of_nonneg_right h2 hS.le
    _ = (Fintype.card C : ℚ) := by field_simp

/-! ## Randomness does not help on a uniform source -/

/-- Average failure probability of a randomized ensemble of codes indexed by a
uniformly random seed `ω : Ω` (shared randomness / a common RNG). -/
def avgFailProb [DecidableEq S] {Ω : Type*} [Fintype Ω] (μ : Source S)
    (K : Ω → Code S C) : ℚ :=
  (∑ ω, failProb μ (K ω)) / (Fintype.card Ω : ℚ)

/-- **A random number generator does not beat the counting bound.**  For a
uniform source, *every* randomized ensemble of codes with code alphabet `C` has
average failure probability at least `1 - |C|/|S|`, exactly the deterministic
bound.  Shared randomness cannot buy a single bit of rate. -/
theorem randomized_avg_failProb_lower [DecidableEq S] [Nonempty S] [Fintype C]
    {Ω : Type*} [Fintype Ω] [Nonempty Ω] (K : Ω → Code S C) :
    1 - (Fintype.card C : ℚ) / (Fintype.card S : ℚ)
      ≤ avgFailProb uniformSource K := by
  have hΩ : (0 : ℚ) < (Fintype.card Ω : ℚ) := by
    exact_mod_cast Fintype.card_pos (α := Ω)
  have hsum : (Fintype.card Ω : ℚ) * (1 - (Fintype.card C : ℚ) / (Fintype.card S : ℚ))
      ≤ ∑ ω, failProb uniformSource (K ω) := by
    calc (Fintype.card Ω : ℚ) * (1 - (Fintype.card C : ℚ) / (Fintype.card S : ℚ))
        = ∑ _ω : Ω, (1 - (Fintype.card C : ℚ) / (Fintype.card S : ℚ)) := by
          simp [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]; ring
      _ ≤ ∑ ω, failProb uniformSource (K ω) :=
          Finset.sum_le_sum fun ω _ => uniform_failProb_lower (K ω)
  rw [avgFailProb, le_div_iff₀ hΩ]
  linarith [hsum]

/-- Randomized converse in rate form. -/
theorem randomized_card_code_ge [DecidableEq S] [Nonempty S] [Fintype C]
    {Ω : Type*} [Fintype Ω] [Nonempty Ω] (K : Ω → Code S C) (ε : ℚ)
    (h : avgFailProb uniformSource K ≤ ε) :
    (1 - ε) * (Fintype.card S : ℚ) ≤ (Fintype.card C : ℚ) := by
  have hS : (0 : ℚ) < (Fintype.card S : ℚ) := by
    exact_mod_cast Fintype.card_pos (α := S)
  have h1 := randomized_avg_failProb_lower (S := S) (C := C) K
  have h2 : (1 - ε) ≤ (Fintype.card C : ℚ) / (Fintype.card S : ℚ) := by linarith
  calc (1 - ε) * (Fintype.card S : ℚ)
      ≤ ((Fintype.card C : ℚ) / (Fintype.card S : ℚ)) * (Fintype.card S : ℚ) :=
        mul_le_mul_of_nonneg_right h2 hS.le
    _ = (Fintype.card C : ℚ) := by field_simp

/-! ## Achievability: the typical-set table code -/

/-- The **table code** for a typical set `T`: enumerate `T` and send the index,
sending the explicit failure symbol `none` for every atypical word. -/
noncomputable def tableCode [DecidableEq S] (T : Finset S) : Code S (Option (Fin T.card)) where
  enc s := if h : s ∈ T then some (T.equivFin ⟨s, h⟩) else none
  dec o := o.map (fun i => (T.equivFin.symm i : S))

omit [Fintype S] in
/-- The table code never returns a wrong word. -/
theorem honest_tableCode [DecidableEq S] (T : Finset S) : Honest (tableCode T) := by
  intro s
  by_cases h : s ∈ T
  · left
    simp [tableCode, h]
  · right
    simp [tableCode, h]

omit [Fintype S] in
/-- Every typical word is decoded correctly. -/
theorem correct_tableCode [DecidableEq S] {T : Finset S} {s : S} (h : s ∈ T) :
    Correct (tableCode T) s := by
  simp [Correct, tableCode, h]

omit [Fintype S] in
/-- The code alphabet of the table code has exactly `|T| + 1` symbols: `|T|`
indices plus one explicit failure symbol. -/
theorem card_tableCode_alphabet [DecidableEq S] (T : Finset S) :
    Fintype.card (Option (Fin T.card)) = T.card + 1 := by simp

/-- **Achievability.**  If the typical set `T` carries probability at least
`1 - ε`, the table code fails with probability at most `ε`. -/
theorem failProb_tableCode_le [DecidableEq S] (μ : Source S) (T : Finset S)
    (ε : ℚ) (hT : 1 - ε ≤ μ.prob T) :
    failProb μ (tableCode T) ≤ ε :=
  failProb_le_of_correct_on μ _ T (fun _ hs => correct_tableCode hs) ε hT

/-! ## The exact ε-relaxed pigeonhole principle -/

/-- The correct set carries probability `1 - failProb`. -/
theorem prob_correct_eq [DecidableEq S] (μ : Source S) (K : Code S C) :
    μ.prob ({s | Correct K s} : Finset S) = 1 - failProb μ K := by
  classical
  have h := Finset.sum_add_sum_compl ({s | Correct K s} : Finset S) μ.w
  rw [μ.total] at h
  have hc : (({s | Correct K s} : Finset S))ᶜ = ({s | ¬ Correct K s} : Finset S) := by
    ext s; simp
  rw [hc] at h
  simp only [Source.prob, failProb]
  linarith

/-- Transport a code along an injection of the code alphabet. -/
noncomputable def spreadCode [DecidableEq S] [DecidableEq C] (T : Finset S)
    (f : Fin T.card ↪ C) (c₀ : C) : Code S C where
  enc s := if h : s ∈ T then f (T.equivFin ⟨s, h⟩) else c₀
  dec c := if h : ∃ i : Fin T.card, f i = c then some (T.equivFin.symm h.choose) else none

omit [Fintype S] in
theorem correct_spreadCode [DecidableEq S] [DecidableEq C] {T : Finset S}
    (f : Fin T.card ↪ C) (c₀ : C) {s : S} (hs : s ∈ T) :
    Correct (spreadCode T f c₀) s := by
  have hex : ∃ i : Fin T.card, f i = f (T.equivFin ⟨s, hs⟩) := ⟨_, rfl⟩
  simp only [Correct, spreadCode, hs, dif_pos, hex]
  have : hex.choose = T.equivFin ⟨s, hs⟩ := f.injective hex.choose_spec
  rw [this]
  simp

/-- **The exact `ε`-relaxed pigeonhole principle.**  A code alphabet `C` admits
an `ε`-reliable code for the source `μ` **iff** some set of at most `|C|` source
words carries probability at least `1 - ε`.  So the pigeonhole bound does not
simply relax by a factor: it relaxes to a statement about the *concentration*
of the source, and for a uniform source (where every set of size `|C|` has
probability `|C|/|S|`) this recovers `|C| ≥ (1-ε)|S|` exactly. -/
theorem epsilon_pigeonhole_iff [DecidableEq S] [Fintype C] [DecidableEq C] [Nonempty C]
    (μ : Source S) (ε : ℚ) :
    (∃ K : Code S C, failProb μ K ≤ ε)
      ↔ ∃ T : Finset S, T.card ≤ Fintype.card C ∧ 1 - ε ≤ μ.prob T := by
  classical
  constructor
  · rintro ⟨K, hK⟩
    refine ⟨({s | Correct K s} : Finset S), card_correct_le_card_code K, ?_⟩
    rw [prob_correct_eq]
    linarith
  · rintro ⟨T, hcard, hprob⟩
    have hemb : Nonempty (Fin T.card ↪ C) :=
      Function.Embedding.nonempty_of_card_le (by simpa using hcard)
    obtain ⟨f⟩ := hemb
    obtain ⟨c₀⟩ := ‹Nonempty C›
    exact ⟨spreadCode T f c₀,
      failProb_le_of_correct_on μ _ T (fun s hs => correct_spreadCode f c₀ hs) ε hprob⟩

end AlmostLossless