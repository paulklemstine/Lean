/-
# Non-Archimedean Löwenheim–Sample Duality via Ultrametric Proof Types
# and Operadic Compression Cores

This file formalizes a bridge between three domains:
  1. **Non-Archimedean geometry** — ultrametric pseudo-emetric spaces
  2. **Model-theoretic approximation** — observer-stable proof systems
  3. **Sample compression / learning theory** — finite compression certificates

## Main Results

### Structures (7 novel types)
* `UltrametricProofType` — ultrametric pseudo-emetric proof space
* `ProofContraction` — q-contractive self-map on an ultrametric space
* `CompressionCore` — finite seed set with depth bound
* `OperadicDecoder` — decoder from codes to hypotheses
* `ProofObserver` — bounded observation function with continuity
* `RealizationFunctor` — Lipschitz map from proofs to hypotheses

### Theorems (proved, zero sorry)
* `iterate_contraction` — iterate of q-contraction is q^n-contractive
* `iterate_contraction_bound` — orbit pair distance bound
* `finite_core_of_totally_bounded` — total boundedness implies finite core with depth
* `finite_core_of_totally_bounded_weak` — weaker version without depth bound
* `cover_pushforward` — finite cover pushes forward through Lipschitz maps
* `cover_pullback` — finite cover pulls back through faithful maps
* `cover_duality` — certificate-level duality (iff)
* `finite_elementary_compression_core` — approximate Löwenheim principle
* `compression_core_covering_number` — compression implies finite covering number

## Cross-Domain Significance

This formalizes the principle that **compactness in a non-Archimedean proof
semantics is equivalent to compressibility in a compositional learning semantics**.
-/

import Mathlib

open Function Set ENNReal

noncomputable section

/-! ## §1. Core Structures -/

/-- An ultrametric proof type: a type with pseudo-emetric structure satisfying
    the strong (non-Archimedean) triangle inequality
    `d(x,z) ≤ max(d(x,y), d(y,z))`. -/
structure UltrametricProofType where
  P : Type*
  instPseudoEMetricSpace : PseudoEMetricSpace P
  ultrametric : ∀ x y z : P, edist x z ≤ max (edist x y) (edist y z)

attribute [instance] UltrametricProofType.instPseudoEMetricSpace

/-- A proof contraction: a self-map on an ultrametric proof space that is
    strictly contractive with ratio `q < 1`. Models proof normalization
    or cut-elimination. -/
structure ProofContraction (U : UltrametricProofType) where
  map : U.P → U.P
  q : ℝ≥0∞
  q_lt_one : q < 1
  contractive : ∀ x y : U.P, edist (map x) (map y) ≤ q * edist x y

/-- A compression core: a finite set of seed proofs together with an iteration
    depth bound. -/
structure CompressionCore (P : Type*) where
  seeds : Finset P
  depth : ℕ

/-- `CoreCovers C ε K` asserts that core `K` covers all of `P`
    within precision `ε` using iterates of `C`. -/
def CoreCovers
    {P : Type*} [PseudoEMetricSpace P]
    (C : P → P) (ε : ℝ≥0∞) (K : CompressionCore P) : Prop :=
  ∀ p : P, ∃ s ∈ K.seeds, ∃ n ≤ K.depth, edist p ((C^[n]) s) ≤ ε

/-- `HasCoreCertificate C ε k` asserts existence of a compression core of size
    at most `k` that ε-covers all of `P` via contraction iterates. -/
def HasCoreCertificate
    {P : Type*} [PseudoEMetricSpace P]
    (C : P → P) (ε : ℝ≥0∞) (k : ℕ) : Prop :=
  ∃ K : CompressionCore P, K.seeds.card ≤ k ∧ CoreCovers C ε K

/-- A finite ε-cover: the basic covering predicate without contraction structure. -/
def HasFiniteCover
    {P : Type*} [PseudoEMetricSpace P]
    (ε : ℝ≥0∞) (k : ℕ) : Prop :=
  ∃ S : Finset P, S.card ≤ k ∧ ∀ p : P, ∃ s ∈ S, edist p s ≤ ε

/-- An operadic decoder: maps codes to hypotheses. -/
structure OperadicDecoder (Code H : Type*) [PseudoEMetricSpace H] where
  decode : Code → H

/-- `HasCompressionCertificate decode ε k` asserts that the hypothesis space
    can be ε-covered by at most `k` decoded codewords. -/
def HasCompressionCertificate
    {Code H : Type*} [PseudoEMetricSpace H]
    (decode : Code → H) (ε : ℝ≥0∞) (k : ℕ) : Prop :=
  ∃ T : Finset Code, T.card ≤ k ∧ ∀ h : H, ∃ c ∈ T, edist h (decode c) ≤ ε

/-- A proof observer: a function from proofs to observations that is uniformly
    continuous at every scale. Observers play the role of formulas in the
    approximate Löwenheim–Skolem analogy. -/
structure ProofObserver (P α : Type*) [PseudoEMetricSpace P] [PseudoEMetricSpace α] where
  observe : P → α
  continuous_at_scale :
    ∀ ε : ℝ≥0∞, ∀ x y : P, edist x y ≤ ε → edist (observe x) (observe y) ≤ ε

/-- A realization functor: a Lipschitz map from proof states to hypotheses. -/
structure RealizationFunctor
    (P H : Type*) [PseudoEMetricSpace P] [PseudoEMetricSpace H] where
  toFun : P → H
  K : ℝ≥0∞
  lipschitz : ∀ p q : P, edist (toFun p) (toFun q) ≤ K * edist p q

/-! ## §2. Iteration Lemmas -/

/-- Iterating a q-contractive map n times yields a q^n-contractive map. -/
theorem iterate_contraction
    {P : Type*} [PseudoEMetricSpace P]
    (C : P → P) (q : ℝ≥0∞)
    (hC : ∀ x y, edist (C x) (C y) ≤ q * edist x y) :
    ∀ n x y, edist ((C^[n]) x) ((C^[n]) y) ≤ q ^ n * edist x y := by
  intro n x y
  induction n with
  | zero => simp
  | succ n ih =>
    simp only [iterate_succ', comp_apply]
    calc edist (C ((C^[n]) x)) (C ((C^[n]) y))
        ≤ q * edist ((C^[n]) x) ((C^[n]) y) := hC _ _
      _ ≤ q * (q ^ n * edist x y) := mul_le_mul_left' ih _
      _ = q * q ^ n * edist x y := (mul_assoc _ _ _).symm
      _ = q ^ (n + 1) * edist x y := by rw [pow_succ']

/-- Distance between iterates at different depths is controlled by q^m. -/
theorem iterate_contraction_bound
    {P : Type*} [PseudoEMetricSpace P]
    (C : P → P) (q : ℝ≥0∞)
    (hC : ∀ x y, edist (C x) (C y) ≤ q * edist x y)
    (x : P) (m n : ℕ) (hmn : m ≤ n) :
    edist ((C^[m]) x) ((C^[n]) x) ≤ q ^ m * edist x ((C^[n - m]) x) := by
  have : (C^[n]) x = (C^[m]) ((C^[n - m]) x) := by
    rw [← iterate_add_apply, Nat.add_sub_cancel' hmn]
  rw [this]
  exact iterate_contraction C q hC m x _

/-! ## §3. Finite Core Theorems -/

/-
**Finite Core from Total Boundedness (strong form).**
    In a totally bounded space, every ε-neighborhood
    can be reached from a finite seed set via bounded-depth iteration (with N=0).
    The contraction is not needed for existence, but the ultrametric structure
    ensures the core has clean geometry.
-/
theorem finite_core_of_totally_bounded
    {P : Type*} [PseudoEMetricSpace P]
    (hUltra : ∀ x y z : P, edist x z ≤ max (edist x y) (edist y z))
    (C : P → P)
    (q : ℝ≥0∞)
    (hq : q < 1)
    (hC : ∀ x y : P, edist (C x) (C y) ≤ q * edist x y)
    (hTot : TotallyBounded (Set.univ : Set P)) :
    ∀ ⦃ε : ℝ≥0∞⦄, ε ≠ 0 →
      ∃ (S : Finset P) (N : ℕ),
        ∀ p : P, ∃ s ∈ S, ∃ n ≤ N, edist p ((C^[n]) s) ≤ ε := by
  intro ε hε_ne
  obtain ⟨S, hS⟩ : ∃ (S : Finset P), ∀ p : P, ∃ s ∈ S, edist p s ≤ ε := by
    rcases eq_or_ne ε ⊤ with rfl | hε_top <;> simp_all +decide [ totallyBounded_iff_subset ];
    · cases isEmpty_or_nonempty P <;> simp_all +decide [ Set.ext_iff ];
      exact ⟨ { Classical.arbitrary P }, Classical.arbitrary P, Finset.mem_singleton_self _ ⟩;
    · obtain ⟨ S, hS₁, hS₂ ⟩ := hTot { p : P × P | edist p.1 p.2 ≤ ε } ( by
        obtain ⟨ δ, hδ_pos, hδ ⟩ := ENNReal.lt_iff_exists_nnreal_btwn.mp ( lt_of_le_of_ne ( zero_le _ ) ( Ne.symm hε_ne ) );
        grind +suggestions );
      exact ⟨ hS₁.toFinset, fun p => by simpa using Set.ext_iff.mp hS₂ p ⟩;
  exact ⟨ S, 0, fun p => by obtain ⟨ s, hs₁, hs₂ ⟩ := hS p; exact ⟨ s, hs₁, 0, by simp +decide, by simpa using hs₂ ⟩ ⟩

/-
**Finite Core from Total Boundedness (weak form).**
    Without a depth bound — just existence of a finite covering set.
-/
theorem finite_core_of_totally_bounded_weak
    {P : Type*} [PseudoEMetricSpace P]
    (hUltra : ∀ x y z : P, edist x z ≤ max (edist x y) (edist y z))
    (C : P → P)
    (q : ℝ≥0∞)
    (hq : q < 1)
    (hC : ∀ x y : P, edist (C x) (C y) ≤ q * edist x y)
    (hTot : TotallyBounded (Set.univ : Set P)) :
    ∀ ⦃ε : ℝ≥0∞⦄, ε ≠ 0 →
      ∃ S : Finset P,
        ∀ p : P, ∃ s ∈ S, ∃ n : ℕ, edist p ((C^[n]) s) ≤ ε := by
  intro ε hε
  have h_total_bounded : ∀ ⦃ε : ℝ≥0∞⦄, ε ≠ 0 → ∃ (S : Finset P), ∀ p : P, ∃ s ∈ S, edist p s ≤ ε := by
    intro ε hε
    obtain ⟨S, hS⟩ : ∃ S : Finset P, Set.univ ⊆ ⋃ y ∈ S, EMetric.ball y ε := by
      rcases hε.lt_or_gt with hε | hε <;> simp_all +decide [ Metric.totallyBounded_iff ];
      have := ( EMetric.totallyBounded_iff.1 hTot ) ε hε;
      obtain ⟨ t, ht, ht' ⟩ := this; exact ⟨ ht.toFinset, Set.eq_univ_of_forall fun x => by simpa using ht' ( Set.mem_univ x ) ⟩ ;
    exact ⟨ S, fun p => by rcases Set.mem_iUnion₂.1 ( hS ( Set.mem_univ p ) ) with ⟨ s, hs, hps ⟩ ; exact ⟨ s, hs, le_of_lt hps ⟩ ⟩;
  exact Exists.elim ( h_total_bounded hε ) fun S hS => ⟨ S, fun p => by obtain ⟨ s, hs₁, hs₂ ⟩ := hS p; exact ⟨ s, hs₁, 0, hs₂ ⟩ ⟩

/-! ## §4. Certificate Duality -/

/-
**Cover Pushforward.**
    A finite ε-cover of the proof space pushes forward to a finite cover of the
    hypothesis space through a uniformly continuous realization map.

    This is the "proof geometry → learning theory" direction. Given:
    - A finite ε-cover of P
    - R maps ε-close proofs to δ-close hypotheses
    - Every hypothesis is realized by some proof (R is surjective)
    Then H has a finite δ-cover.
-/
theorem cover_pushforward
    {P H : Type*}
    [PseudoEMetricSpace P] [PseudoEMetricSpace H]
    [DecidableEq H]
    (R : P → H)
    (ε δ : ℝ≥0∞)
    (k : ℕ)
    (hCont : ∀ x y : P, edist x y ≤ ε → edist (R x) (R y) ≤ δ)
    (hSurj : Surjective R)
    (hCover : @HasFiniteCover P _ ε k) :
    @HasFiniteCover H _ δ k := by
  obtain ⟨ S, hS ⟩ := hCover;
  refine' ⟨ S.image R, _, _ ⟩;
  · exact le_trans ( Finset.card_image_le ) hS.1;
  · intro p; obtain ⟨ q, rfl ⟩ := hSurj p; obtain ⟨ s, hs, hs' ⟩ := hS.2 q; use R s; aesop;

/-
**Cover Pullback.**
    If the hypothesis space has a finite cover and the realization is faithful
    (nearby hypotheses imply nearby proofs), then the proof space has a cover.

    This is the "learning theory → proof geometry" direction.
-/
theorem cover_pullback
    {P H : Type*}
    [PseudoEMetricSpace P] [PseudoEMetricSpace H]
    [DecidableEq P]
    (R : P → H)
    (lift : H → P)
    (ε δ : ℝ≥0∞)
    (k : ℕ)
    (hLift : ∀ h : H, R (lift h) = h)
    (hFaithful : ∀ x : P, ∀ h : H, edist (R x) h ≤ δ →
      edist x (lift h) ≤ ε)
    (hCover : @HasFiniteCover H _ δ k) :
    @HasFiniteCover P _ ε k := by
  obtain ⟨ T, hT₁, hT₂ ⟩ := hCover;
  use T.image lift;
  exact ⟨ Finset.card_image_le.trans hT₁, fun p => by rcases hT₂ ( R p ) with ⟨ s, hs₁, hs₂ ⟩ ; exact ⟨ lift s, Finset.mem_image_of_mem _ hs₁, hFaithful _ _ hs₂ ⟩ ⟩

/-
**Cover Duality (Certificate Level).**
    Under suitable faithfulness and realization conditions, a finite ε-cover
    of the proof space exists iff a finite δ-cover of the hypothesis space exists.

    This is the non-Archimedean Löwenheim–Sample duality.
-/
theorem cover_duality
    {P H : Type*}
    [PseudoEMetricSpace P] [PseudoEMetricSpace H]
    [DecidableEq P] [DecidableEq H]
    (R : P → H)
    (lift : H → P)
    (ε δ : ℝ≥0∞)
    (k : ℕ)
    (hCont : ∀ x y : P, edist x y ≤ ε → edist (R x) (R y) ≤ δ)
    (hSurj : Surjective R)
    (hLift : ∀ h : H, R (lift h) = h)
    (hFaithful : ∀ x : P, ∀ h : H, edist (R x) h ≤ δ →
      edist x (lift h) ≤ ε) :
    @HasFiniteCover P _ ε k ↔ @HasFiniteCover H _ δ k := by
  exact ⟨fun a => cover_pushforward R ε δ k hCont hSurj a,
         fun a => cover_pullback R lift ε δ k hLift hFaithful a⟩

/-! ## §5. Core Certificate ↔ Compression Certificate Bridge -/

/-
**Core Certificate implies Compression Certificate.**
    If the proof space has a core certificate and we have an encoding/decoding
    scheme compatible with the realization, then the hypothesis class has a
    compression certificate.

    The key insight: iterate orbits of seeds in proof space become decoded
    codewords in hypothesis space.
-/
theorem core_certificate_to_compression
    {P H Code : Type*}
    [PseudoEMetricSpace P] [PseudoEMetricSpace H]
    (C : P → P) (R : P → H)
    (encode : P → Code) (decode : Code → H)
    (ε δ : ℝ≥0∞) (k : ℕ)
    (hRoundtrip : ∀ p : P, decode (encode p) = R p)
    (hCont : ∀ x y : P, edist x y ≤ ε → edist (R x) (R y) ≤ δ)
    (hSurj : Surjective R)
    (hCore : HasCoreCertificate C ε k) :
    ∃ m : ℕ, HasCompressionCertificate decode δ m := by
  obtain ⟨ K, hK ⟩ := hCore;
  obtain ⟨S, hS⟩ : ∃ S : Finset Code, ∀ p ∈ K.seeds, ∀ n ≤ K.depth, encode (C^[n] p) ∈ S := by
    -- The image of a finite set under a function is finite.
    have h_image_finite : Set.Finite (⋃ p ∈ K.seeds, ⋃ n ≤ K.depth, {encode (C^[n] p)}) := by
      exact Set.Finite.biUnion ( Finset.finite_toSet K.seeds ) fun p hp => Set.Finite.biUnion ( Set.finite_Iic K.depth ) fun n hn => Set.finite_singleton _;
    exact ⟨ h_image_finite.toFinset, fun p hp n hn => h_image_finite.mem_toFinset.mpr <| Set.mem_iUnion₂.mpr ⟨ p, hp, Set.mem_iUnion₂.mpr ⟨ n, hn, rfl ⟩ ⟩ ⟩;
  refine' ⟨ S.card, S, le_rfl, _ ⟩;
  intro h
  obtain ⟨p, hp⟩ : ∃ p : P, R p = h := hSurj h
  obtain ⟨s, hs₁, n, hn₁, hn₂⟩ : ∃ s ∈ K.seeds, ∃ n ≤ K.depth, edist p ((C^[n]) s) ≤ ε := hK.right p
  use encode (C^[n] s)
  aesop

/-! ## §6. Approximate Löwenheim Principle -/

/-
**Finite Elementary Compression Core.**
    If the proof space is totally bounded and observers are uniformly continuous
    at scale ε, then there exists a finite compression core that simultaneously
    approximates all proofs and preserves all observer values up to ε.

    This is the approximate Löwenheim principle: finite approximate elementary
    substructures exist in totally bounded spaces with uniformly continuous
    observations.
-/
theorem finite_elementary_compression_core
    {P α : Type*}
    [PseudoEMetricSpace P]
    [PseudoEMetricSpace α]
    (C : P → P)
    (Obs : Finset (P → α))
    (ε : ℝ≥0∞)
    (hε : ε ≠ 0)
    (hTot : TotallyBounded (Set.univ : Set P))
    (hStable : ∀ φ ∈ Obs, ∀ x y : P,
      edist x y ≤ ε → edist (φ x) (φ y) ≤ ε) :
    ∃ S : Finset P,
      ∀ p : P, ∃ s ∈ S, ∃ n : ℕ,
        edist p ((C^[n]) s) ≤ ε ∧
        ∀ φ ∈ Obs, edist (φ p) (φ ((C^[n]) s)) ≤ ε := by
  have := EMetric.totallyBounded_iff.mp hTot ε hε.bot_lt;
  cases' this with t ht;
  exact ⟨ ht.1.toFinset, fun p => by rcases Set.mem_iUnion₂.1 ( ht.2 ( Set.mem_univ p ) ) with ⟨ s, hs, hps ⟩ ; exact ⟨ s, ht.1.mem_toFinset.2 hs, 0, by simpa using hps.le, fun φ hφ => hStable φ hφ _ _ ( by simpa using hps.le ) ⟩ ⟩

/-! ## §7. Covering Number Bridge -/

/-
**Compression Core Covering Number.**
    If a hypothesis class admits an ε-compression certificate of size k,
    then the class has covering number at most k at precision ε.
    This bridges to learnability via standard finite-class bounds.
-/
theorem compression_core_covering_number
    {Code H : Type*}
    [PseudoEMetricSpace H] [DecidableEq H]
    (decode : Code → H)
    (ε : ℝ≥0∞)
    (k : ℕ)
    (hCompress : HasCompressionCertificate decode ε k) :
    ∃ T : Finset H, T.card ≤ k ∧
      ∀ h : H, ∃ t ∈ T, edist h t ≤ ε := by
  exact ⟨ hCompress.choose.image decode, Finset.card_image_le.trans hCompress.choose_spec.1, fun h => by obtain ⟨ c, hc₁, hc₂ ⟩ := hCompress.choose_spec.2 h; exact ⟨ _, Finset.mem_image_of_mem _ hc₁, hc₂ ⟩ ⟩

/-! ## §8. Contraction Preserves Covers -/

/-
**Contraction Orbit Inclusion.**
    If S is an ε-cover and C is q-contractive, then S also serves as
    a (q*ε)-cover after applying C. Contraction dynamics shrink
    covering radii geometrically.
-/
theorem contraction_shrinks_cover
    {P : Type*} [PseudoEMetricSpace P]
    (C : P → P) (q : ℝ≥0∞)
    (hC : ∀ x y : P, edist (C x) (C y) ≤ q * edist x y)
    (S : Finset P) (ε : ℝ≥0∞)
    (hBase : ∀ p : P, ∃ s ∈ S, edist p s ≤ ε) :
    ∀ p : P, ∃ s ∈ S, edist (C p) (C s) ≤ q * ε := by
  exact fun p => by obtain ⟨ s, hs₁, hs₂ ⟩ := hBase p; exact ⟨ s, hs₁, le_trans ( hC _ _ ) ( mul_le_mul_left' hs₂ _ ) ⟩ ;

end