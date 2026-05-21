import Mathlib

/-!
# Universal Affine Σ-Protocol Extraction

This file formalizes the **universal witness extraction principle** for affine Σ-protocols
over finite fields `ZMod q` where `q` is prime.

## Main Results

The central insight is that special soundness in Σ-protocols is not a protocol-by-protocol
trick, but a theorem of finite-dimensional linear algebra over finite fields. When the
verifier's acceptance condition is affine in the witness and response variables, any two
accepting transcripts with the same commitment and distinct challenges determine the witness
by solving a linear system.

### Core Extraction Theorems

* `one_dim_affine_extract` — 1-dimensional master extraction: if `z = r + c * w` for
  two transcripts with the same `r` and distinct challenges, then `w` is uniquely recovered.
* `multi_dim_affine_extract` — Coordinatewise extraction for vector witnesses.
* `matrix_affine_extract` — Full matrix extraction: if `z = t + c • (M w)` and `M` is
  injective, then `w` is uniquely determined.
* `no_unique_extract_of_noninj` — Obstruction theorem: if `M` is non-injective,
  unique extraction fails.

### Definitions

* `AffineSigmaTranscript` — A pair of accepting transcripts with the same commitment.
* `affineExtract1D` — The 1-dimensional extractor function.
* `affineExtractVec` — The vector extractor function.
* `HasExtractionRank` — Predicate for when unique extraction is possible.

### Cross-Domain Connection

* `affine_code_distance_extraction` — Links extraction uniqueness to injectivity of
  the "affine code" map, bridging cryptography and coding theory.
-/

open Matrix Finset

noncomputable section

/-! ## 1-Dimensional Affine Extraction -/

/-- The 1-dimensional affine extractor: given two responses and two challenges,
    recover the witness as `(z₁ - z₂) * (c₁ - c₂)⁻¹`. -/
def affineExtract1D {q : ℕ} [NeZero q] (z₁ z₂ c₁ c₂ : ZMod q) : ZMod q :=
  (z₁ - z₂) * (c₁ - c₂)⁻¹

/-
**Master 1-dimensional extraction lemma.** If `z₁ = r + c₁ * w` and `z₂ = r + c₂ * w`
    with `c₁ ≠ c₂` over `ZMod q` (q prime), then `w = (z₁ - z₂) * (c₁ - c₂)⁻¹`.
-/
theorem one_dim_affine_extract
    {q : ℕ} [Fact q.Prime]
    (r w z₁ z₂ c₁ c₂ : ZMod q)
    (h₁ : z₁ = r + c₁ * w)
    (h₂ : z₂ = r + c₂ * w)
    (hneq : c₁ ≠ c₂) :
    w = affineExtract1D z₁ z₂ c₁ c₂ := by
  unfold affineExtract1D; simp +decide [ h₁, h₂, sub_eq_iff_eq_add ] ;
  grind

/-
Uniqueness: the extracted witness is the *only* solution to the affine system.
-/
theorem one_dim_affine_extract_unique
    {q : ℕ} [Fact q.Prime]
    (_r z₁ z₂ c₁ c₂ : ZMod q)
    (hneq : c₁ ≠ c₂) :
    ∃! w : ZMod q, z₁ - z₂ = (c₁ - c₂) * w := by
  refine' ⟨ ( z₁ - z₂ ) / ( c₁ - c₂ ), _, _ ⟩;
  · simp +decide [ mul_div_cancel₀ _ ( sub_ne_zero_of_ne hneq ) ];
  · exact fun y hy => by rw [ hy, mul_div_cancel_left₀ _ ( sub_ne_zero_of_ne hneq ) ] ;

/-! ## Vector Affine Extraction -/

/-- The vector affine extractor: apply the 1D extractor coordinatewise. -/
def affineExtractVec {q : ℕ} [NeZero q] {n : ℕ}
    (z₁ z₂ : Fin n → ZMod q) (c₁ c₂ : ZMod q) : Fin n → ZMod q :=
  fun i => affineExtract1D (z₁ i) (z₂ i) c₁ c₂

/-
**Multi-dimensional coordinatewise extraction.** If each coordinate satisfies
    `z₁ i = r i + c₁ * w i` and `z₂ i = r i + c₂ * w i`, then the witness vector
    is recovered coordinatewise.
-/
theorem multi_dim_affine_extract
    {q : ℕ} [Fact q.Prime] {n : ℕ}
    (r w : Fin n → ZMod q)
    (z₁ z₂ : Fin n → ZMod q) (c₁ c₂ : ZMod q)
    (h₁ : ∀ i, z₁ i = r i + c₁ * w i)
    (h₂ : ∀ i, z₂ i = r i + c₂ * w i)
    (hneq : c₁ ≠ c₂) :
    w = affineExtractVec z₁ z₂ c₁ c₂ := by
  exact funext fun i => one_dim_affine_extract _ _ _ _ _ _ ( h₁ i ) ( h₂ i ) hneq

/-! ## Matrix Affine Extraction -/

/-- The matrix affine extractor: given `z = t + c • M w`, recover `M w` from two
    transcripts, then apply a left inverse of `M`. Here we define the intermediate
    step recovering `M w`. -/
def matrixExtractImage {q : ℕ} [NeZero q] {m : ℕ}
    (z₁ z₂ : Fin m → ZMod q) (c₁ c₂ : ZMod q) : Fin m → ZMod q :=
  fun i => (z₁ i - z₂ i) * (c₁ - c₂)⁻¹

/-
The difference of two accepting transcripts yields a scalar multiple of `M w`.
-/
theorem matrix_transcript_diff
    {q : ℕ} [Fact q.Prime] {n m : ℕ}
    (M : Matrix (Fin m) (Fin n) (ZMod q))
    (w : Fin n → ZMod q)
    (c₁ c₂ : ZMod q)
    (z₁ z₂ t : Fin m → ZMod q)
    (h₁ : z₁ = t + c₁ • (M.mulVec w))
    (h₂ : z₂ = t + c₂ • (M.mulVec w))
    (hneq : c₁ ≠ c₂) :
    M.mulVec w = matrixExtractImage z₁ z₂ c₁ c₂ := by
  ext i; simp [matrixExtractImage, h₁, h₂]; field_simp [hneq]; ring;
  linear_combination -mul_inv_cancel₀ ( sub_ne_zero_of_ne hneq ) * ( M *ᵥ w ) i

/-
**Universal matrix extraction theorem.** If `M` is injective and the acceptance
    condition is `z = t + c • M w`, then `w` is uniquely determined by two accepting
    transcripts with distinct challenges.
-/
theorem matrix_affine_extract
    {q : ℕ} [Fact q.Prime] {n m : ℕ}
    (M : Matrix (Fin m) (Fin n) (ZMod q))
    (w : Fin n → ZMod q)
    (c₁ c₂ : ZMod q)
    (z₁ z₂ t : Fin m → ZMod q)
    (h₁ : z₁ = t + c₁ • (M.mulVec w))
    (h₂ : z₂ = t + c₂ • (M.mulVec w))
    (hneq : c₁ ≠ c₂)
    (hinj : Function.Injective M.mulVec) :
    ∀ w' : Fin n → ZMod q,
      z₁ = t + c₁ • (M.mulVec w') →
      z₂ = t + c₂ • (M.mulVec w') →
      w' = w := by
  intro w' hw₁ hw₂;
  -- Subtracting the two transcript equations for w and w' gives (c₁ - c₂) • (M.mulVec w - M.mulVec w') = 0.
  have h_diff : (c₁ - c₂) • (M.mulVec w - M.mulVec w') = 0 := by
    simp_all +decide [ sub_smul, smul_sub ];
  simp_all +decide [ sub_eq_iff_eq_add, hinj.eq_iff ]

/-! ## Extraction Rank Condition -/

/-- A matrix `M` has **extraction rank** if its `mulVec` is injective, i.e.,
    the witness-to-response linear map has trivial kernel. This is the exact
    condition under which affine extraction succeeds uniquely. -/
def HasExtractionRank {q : ℕ} [NeZero q] {n m : ℕ}
    (M : Matrix (Fin m) (Fin n) (ZMod q)) : Prop :=
  Function.Injective M.mulVec

/-
**Obstruction theorem.** If `M` does not have extraction rank (i.e., `mulVec` is
    non-injective), then there exist distinct witnesses producing identical transcripts,
    so unique extraction is impossible.
-/
theorem no_unique_extract_of_noninj
    {q : ℕ} [Fact q.Prime] {n m : ℕ}
    (M : Matrix (Fin m) (Fin n) (ZMod q))
    (hninj : ¬ HasExtractionRank M) :
    ∃ w₁ w₂ : Fin n → ZMod q, w₁ ≠ w₂ ∧ M.mulVec w₁ = M.mulVec w₂ := by
  exact Classical.not_forall_not.1 fun h => hninj fun w₁ w₂ h' => Classical.not_not.1 fun h'' => h w₁ <| by tauto;

/-! ## Cross-Domain: Coding Theory Connection -/

/-- An **affine code map** sends a witness `w` to the vector of responses for each
    possible challenge value `c`. This connects the extraction problem to coding theory:
    two evaluations at distinct points suffice to recover the message iff the map is
    injective (analogous to minimum distance ≥ 2). -/
def affineCodeMap {q : ℕ} [NeZero q] {n m : ℕ}
    (M : Matrix (Fin m) (Fin n) (ZMod q))
    (t : Fin m → ZMod q) (c : ZMod q) (w : Fin n → ZMod q) : Fin m → ZMod q :=
  t + c • (M.mulVec w)

/-
**Coding theory bridge.** Extraction rank is equivalent to injectivity of the
    affine code map for all nonzero challenge values. (At c=0 the map is constant
    in w, so injectivity fails trivially unless n=0.)
-/
theorem affine_code_injectivity_iff_extraction
    {q : ℕ} [Fact q.Prime] {n m : ℕ}
    (M : Matrix (Fin m) (Fin n) (ZMod q)) :
    HasExtractionRank M ↔
    (∀ (t : Fin m → ZMod q) (c : ZMod q), c ≠ 0 →
      Function.Injective (affineCodeMap M t c)) := by
  refine' ⟨ _, fun h => _ ⟩;
  · intro h t c hc hc;
    intro w' hw'; have := h ( show M.mulVec hc = M.mulVec w' from ?_ ) ; aesop;
    simp_all +decide [ funext_iff, affineCodeMap ];
  · convert h 0 1 one_ne_zero using 1;
    unfold HasExtractionRank affineCodeMap; aesop;

/-
Two evaluations of the affine code at distinct challenges uniquely determine the
    witness when the code has extraction rank. This is the coding-theoretic formulation
    of special soundness.
-/
theorem affine_code_distance_extraction
    {q : ℕ} [Fact q.Prime] {n m : ℕ}
    (M : Matrix (Fin m) (Fin n) (ZMod q))
    (hrank : HasExtractionRank M)
    (t : Fin m → ZMod q)
    (c₁ c₂ : ZMod q) (hneq : c₁ ≠ c₂)
    (w₁ w₂ : Fin n → ZMod q)
    (h₁ : affineCodeMap M t c₁ w₁ = affineCodeMap M t c₁ w₂)
    (h₂ : affineCodeMap M t c₂ w₁ = affineCodeMap M t c₂ w₂) :
    w₁ = w₂ := by
  unfold affineCodeMap at *;
  simp_all +decide [ funext_iff, Matrix.mulVec ];
  exact fun x => by have := hrank ( show M.mulVec w₁ = M.mulVec w₂ from by ext i; cases h₁ i <;> cases h₂ i <;> simp_all +decide [ Matrix.mulVec, dotProduct ] ) ; simpa using congr_fun this x;

/-! ## Protocol Instances -/

/-! ### Schnorr Protocol Extraction -/

/-- The Schnorr extractor: given two responses and two challenges, recover the
    discrete log witness. -/
def schnorrExtractor {q : ℕ} [NeZero q] (z₁ z₂ c₁ c₂ : ZMod q) : ZMod q :=
  affineExtract1D z₁ z₂ c₁ c₂

/-
**Schnorr extraction theorem.** In the Schnorr protocol, the response satisfies
    `z = r + c * w` where `w` is the discrete log witness and `r` is the commitment
    randomness. Two accepting transcripts with distinct challenges recover `w`.
-/
theorem schnorr_extract_correct
    {q : ℕ} [Fact q.Prime]
    (r w z₁ z₂ c₁ c₂ : ZMod q)
    (hacc₁ : z₁ = r + c₁ * w)
    (hacc₂ : z₂ = r + c₂ * w)
    (hneq : c₁ ≠ c₂) :
    schnorrExtractor z₁ z₂ c₁ c₂ = w := by
  convert one_dim_affine_extract r w z₁ z₂ c₁ c₂ hacc₁ hacc₂ hneq |> Eq.symm using 1

/-! ### Chaum–Pedersen Protocol Extraction -/

/-- Chaum–Pedersen transcript at the scalar level. -/
structure ChaumPedersenTranscript (q : ℕ) [NeZero q] where
  z : ZMod q
  c : ZMod q

/-- The Chaum–Pedersen extractor is identical to Schnorr's at the scalar level. -/
def chaumPedersenExtractor {q : ℕ} [NeZero q]
    (t₁ t₂ : ChaumPedersenTranscript q) : ZMod q :=
  affineExtract1D t₁.z t₂.z t₁.c t₂.c

/-
**Chaum–Pedersen extraction theorem.** Two accepting Chaum–Pedersen transcripts
    with the same commitment and distinct challenges recover the shared witness.
-/
theorem chaum_pedersen_extract_correct
    {q : ℕ} [Fact q.Prime]
    (r w : ZMod q)
    (t₁ t₂ : ChaumPedersenTranscript q)
    (hacc₁ : t₁.z = r + t₁.c * w)
    (hacc₂ : t₂.z = r + t₂.c * w)
    (hneq : t₁.c ≠ t₂.c) :
    chaumPedersenExtractor t₁ t₂ = w := by
  convert one_dim_affine_extract r w t₁.z t₂.z t₁.c t₂.c hacc₁ hacc₂ hneq |> Eq.symm

/-! ### Okamoto Two-Generator Protocol -/

/-- Okamoto transcript: two response components and one challenge. -/
structure OkamotoTranscript (q : ℕ) [NeZero q] where
  z₁ : ZMod q
  z₂ : ZMod q
  c  : ZMod q

/-- The Okamoto extractor: extract both witness components independently. -/
def okamotoExtractor {q : ℕ} [NeZero q]
    (t₁ t₂ : OkamotoTranscript q) : ZMod q × ZMod q :=
  (affineExtract1D t₁.z₁ t₂.z₁ t₁.c t₂.c,
   affineExtract1D t₁.z₂ t₂.z₂ t₁.c t₂.c)

/-
**Okamoto extraction theorem.** Two accepting Okamoto transcripts with distinct
    challenges uniquely recover the 2-dimensional witness `(w₁, w₂)`.
-/
theorem okamoto_extract_correct
    {q : ℕ} [Fact q.Prime]
    (r₁ r₂ w₁ w₂ : ZMod q)
    (t₁ t₂ : OkamotoTranscript q)
    (hacc₁₁ : t₁.z₁ = r₁ + t₁.c * w₁)
    (hacc₁₂ : t₁.z₂ = r₂ + t₁.c * w₂)
    (hacc₂₁ : t₂.z₁ = r₁ + t₂.c * w₁)
    (hacc₂₂ : t₂.z₂ = r₂ + t₂.c * w₂)
    (hneq : t₁.c ≠ t₂.c) :
    okamotoExtractor t₁ t₂ = (w₁, w₂) := by
  exact Prod.ext ( one_dim_affine_extract r₁ w₁ t₁.z₁ t₂.z₁ t₁.c t₂.c hacc₁₁ hacc₂₁ hneq ▸ rfl ) ( one_dim_affine_extract r₂ w₂ t₁.z₂ t₂.z₂ t₁.c t₂.c hacc₁₂ hacc₂₂ hneq ▸ rfl )

/-! ### Okamoto as a Matrix Instance -/

/-- The Okamoto protocol matrix is the 2×2 identity. -/
def okamotoMatrix (q : ℕ) [NeZero q] : Matrix (Fin 2) (Fin 2) (ZMod q) := 1

/-
The identity matrix has extraction rank.
-/
theorem okamoto_has_extraction_rank {q : ℕ} [Fact q.Prime] :
    HasExtractionRank (okamotoMatrix q) := by
  unfold HasExtractionRank okamotoMatrix; simp +decide [ Function.Injective ] ;

/-! ### General Affine Σ-Protocol Abstraction -/

/-- An **affine Σ-protocol** over `ZMod q` with `n`-dimensional witness and
    `m`-dimensional response. -/
structure AffineSigmaProtocol (q : ℕ) [NeZero q] (n m : ℕ) where
  coeffMatrix : Matrix (Fin m) (Fin n) (ZMod q)
  offset : Fin m → ZMod q

/-- An accepting transcript for an affine Σ-protocol. -/
structure AffineSigmaProtocol.Transcript {q : ℕ} [NeZero q] {n m : ℕ}
    (P : AffineSigmaProtocol q n m) where
  challenge : ZMod q
  response : Fin m → ZMod q

/-- A transcript is accepting for witness `w`. -/
def AffineSigmaProtocol.IsAccepting {q : ℕ} [NeZero q] {n m : ℕ}
    (P : AffineSigmaProtocol q n m)
    (tr : P.Transcript)
    (w : Fin n → ZMod q) : Prop :=
  tr.response = P.offset + tr.challenge • (P.coeffMatrix.mulVec w)

/-- Two transcripts are **compatible** if they have distinct challenges. -/
def AffineSigmaProtocol.Compatible {q : ℕ} [NeZero q] {n m : ℕ}
    (P : AffineSigmaProtocol q n m)
    (tr₁ tr₂ : P.Transcript) : Prop :=
  tr₁.challenge ≠ tr₂.challenge

/-- An affine Σ-protocol has **special soundness** if extraction rank implies
    unique witness determination from compatible transcripts. -/
def AffineSigmaProtocol.HasSpecialSoundness {q : ℕ} [NeZero q] {n m : ℕ}
    (P : AffineSigmaProtocol q n m) : Prop :=
  HasExtractionRank P.coeffMatrix →
    ∀ (tr₁ tr₂ : P.Transcript) (w₁ w₂ : Fin n → ZMod q),
      P.Compatible tr₁ tr₂ →
      P.IsAccepting tr₁ w₁ →
      P.IsAccepting tr₂ w₁ →
      P.IsAccepting tr₁ w₂ →
      P.IsAccepting tr₂ w₂ →
      w₁ = w₂

/-
**Every affine Σ-protocol has special soundness.** This is the master theorem.
-/
theorem AffineSigmaProtocol.universal_special_soundness
    {q : ℕ} [Fact q.Prime] {n m : ℕ}
    (P : AffineSigmaProtocol q n m) :
    P.HasSpecialSoundness := by
  exact fun hrank tr₁ tr₂ w₁ w₂ hcompat hacc1w1 hacc2w1 hacc1w2 hacc2w2 => by
    have := matrix_affine_extract P.coeffMatrix w₁ tr₁.challenge tr₂.challenge tr₁.response tr₂.response P.offset hacc1w1 hacc2w1 (by
    exact hcompat) hrank
    exact this w₂ hacc1w2 hacc2w2 ▸ rfl

end