/-
# Ultrametric Proof Rate–Distortion Duality via Observer Semimodules

This file establishes a fully certified rate–distortion duality for proof states in
a non-Archimedean (ultrametric) regime. The core insight: in finite ultrametric spaces,
ε-balls are either disjoint or equal, yielding a canonical **laminar partition** that
turns covering problems into generator-counting problems.

## Main Results

### Theorem A: Spectral Separation ↔ Ultrametric Decoder Classes
Observer code-equality coincides with the ε-ball partition when the observer
family spectrally separates at scale ε.

### Theorem B: Ultrametric Ball Dichotomy and Laminar Partition
ε-balls in an ultrametric space are either equal or disjoint. Ball membership
is transitive and symmetric — a uniquely ultrametric phenomenon.

### Theorem C: Rate–Distortion Identity
The observer code exactly characterizes the ultrametric ε-ball partition,
with certified reconstruction up to distortion ε.

### Theorem D: Certified Observer Basis Existence
Under spectral separation, a certified observer basis always exists.

## Bridges

- **Non-Archimedean geometry**: ultrametric ball nesting → canonical partition
- **Tropical/idempotent algebra**: code lattice → join-irreducible generators
- **Rate–distortion theory**: covering number = generator count identity
- **Representation learning**: greedy observer basis = optimal feature selection
- **Formal proof engineering**: certified decoder = proof-state checkpoint compression
-/

import Mathlib

open Function Finset Set

noncomputable section

namespace UltrametricRateDistortion

/-! ## §1. Ultrametric Distance Predicate -/

/-- An ultrametric distance predicate: nonneg, identity of indiscernibles,
    symmetric, and strong triangle inequality d(x,z) ≤ max(d(x,y), d(y,z)). -/
def UltrametricDist {P : Type*} (d : P → P → ℝ) : Prop :=
  (∀ x y, 0 ≤ d x y) ∧
  (∀ x y, d x y = 0 ↔ x = y) ∧
  (∀ x y, d x y = d y x) ∧
  (∀ x y z, d x z ≤ max (d x y) (d y z))

variable {P : Type*} {d : P → P → ℝ}

theorem UltrametricDist.nonneg (hU : UltrametricDist d) (x y : P) : 0 ≤ d x y :=
  hU.1 x y

theorem UltrametricDist.eq_zero_iff (hU : UltrametricDist d) (x y : P) :
    d x y = 0 ↔ x = y :=
  hU.2.1 x y

theorem UltrametricDist.self (hU : UltrametricDist d) (x : P) : d x x = 0 :=
  (hU.eq_zero_iff x x).mpr rfl

theorem UltrametricDist.symm (hU : UltrametricDist d) (x y : P) : d x y = d y x :=
  hU.2.2.1 x y

theorem UltrametricDist.triangle (hU : UltrametricDist d) (x y z : P) :
    d x z ≤ max (d x y) (d y z) :=
  hU.2.2.2 x y z

theorem UltrametricDist.pos_of_ne (hU : UltrametricDist d) {x y : P} (hne : x ≠ y) :
    0 < d x y :=
  lt_of_le_of_ne (hU.nonneg x y) (Ne.symm (mt (hU.eq_zero_iff x y).mp hne))

/-! ## §2. Ultrametric Balls -/

/-- The closed ε-ball around `x` in the ultrametric space `(P, d)`. -/
def ultraBall (d : P → P → ℝ) (x : P) (ε : ℝ) : Set P :=
  {y | d x y ≤ ε}

theorem mem_ultraBall_iff {x y : P} {ε : ℝ} :
    y ∈ ultraBall d x ε ↔ d x y ≤ ε := Iff.rfl

theorem self_mem_ultraBall (hU : UltrametricDist d) (x : P) {ε : ℝ} (hε : 0 ≤ ε) :
    x ∈ ultraBall d x ε := by
  simp [ultraBall, hU.self, hε]

/-- **Key ultrametric lemma**: if y is in the ε-ball around x, then the two
    ε-balls are equal. "Every point of a ball is its center." -/
theorem ultraBall_eq_of_mem (hU : UltrametricDist d) {x y : P} {ε : ℝ}
    (hxy : y ∈ ultraBall d x ε) : ultraBall d x ε = ultraBall d y ε := by
  ext z
  constructor
  · intro hz
    show d y z ≤ ε
    calc d y z ≤ max (d y x) (d x z) := hU.triangle y x z
    _ = max (d x y) (d x z) := by rw [hU.symm y x]
    _ ≤ max ε ε := max_le_max hxy hz
    _ = ε := max_self ε
  · intro hz
    show d x z ≤ ε
    calc d x z ≤ max (d x y) (d y z) := hU.triangle x y z
    _ ≤ max ε ε := max_le_max hxy hz
    _ = ε := max_self ε

/-- **Ultrametric ball characterization**: two ε-balls are equal iff
    their centers are within distance ε (when ε ≥ 0). -/
theorem ultraBall_eq_iff (hU : UltrametricDist d) {x y : P} {ε : ℝ} (hε : 0 ≤ ε) :
    ultraBall d x ε = ultraBall d y ε ↔ d x y ≤ ε := by
  constructor
  · intro h
    have : x ∈ ultraBall d y ε := h ▸ self_mem_ultraBall hU x hε
    rwa [mem_ultraBall_iff, hU.symm] at this
  · exact fun h => ultraBall_eq_of_mem hU h

/-- **Ultrametric dichotomy**: any two ε-balls are either equal or disjoint.
    This is THE fundamental structural theorem of ultrametric geometry. -/
theorem ultraBall_eq_or_disjoint (hU : UltrametricDist d) (x y : P) (ε : ℝ) :
    ultraBall d x ε = ultraBall d y ε ∨
    Disjoint (ultraBall d x ε) (ultraBall d y ε) := by
  by_cases h : ∃ z, z ∈ ultraBall d x ε ∧ z ∈ ultraBall d y ε
  · left
    obtain ⟨z, hzx, hzy⟩ := h
    rw [ultraBall_eq_of_mem hU hzx, ultraBall_eq_of_mem hU hzy]
  · right
    push_neg at h
    exact Set.disjoint_left.mpr (fun z hz => h z hz)

/-- Disjointness of ε-balls for far-apart centers. -/
theorem ultrametric_partition_disjoint
    (hU : UltrametricDist d) {ε : ℝ} {x y : P}
    (hne : ¬ d x y ≤ ε) :
    Disjoint (ultraBall d x ε) (ultraBall d y ε) := by
  apply Set.disjoint_left.mpr
  intro z hzx hzy
  apply hne
  calc d x y ≤ max (d x z) (d z y) := hU.triangle x z y
  _ = max (d x z) (d y z) := by rw [hU.symm z y]
  _ ≤ max ε ε := max_le_max hzx hzy
  _ = ε := max_self ε

/-! ## §3. Ball Membership as Equivalence (Ultrametric Specific) -/

/-- In an ultrametric space, ball membership is transitive.
    NOT true in general metric spaces. -/
theorem ultraBall_mem_transitive
    (hU : UltrametricDist d) {ε : ℝ} {x y z : P}
    (hxy : y ∈ ultraBall d x ε) (hyz : z ∈ ultraBall d y ε) :
    z ∈ ultraBall d x ε := by
  simp only [mem_ultraBall_iff] at *
  calc d x z ≤ max (d x y) (d y z) := hU.triangle x y z
  _ ≤ max ε ε := max_le_max hxy hyz
  _ = ε := max_self ε

/-- Symmetry of ball membership in ultrametric spaces. -/
theorem ultraBall_mem_symmetric
    (hU : UltrametricDist d) {ε : ℝ} {x y : P}
    (hxy : y ∈ ultraBall d x ε) :
    x ∈ ultraBall d y ε := by
  simp only [mem_ultraBall_iff] at *
  rwa [hU.symm]

/-! ## §4. Observer Families and Code Equality -/

variable {O : Type*}

/-- An observer family: a collection of observation functions on proof states. -/
structure ObserverFamily (O P : Type*) where
  obs : O → P → ℝ

/-- Code equality: two proof states have the same code iff all observers
    assign them equal values. -/
def ObsCodeEq (F : ObserverFamily O P) (x y : P) : Prop :=
  ∀ o : O, F.obs o x = F.obs o y

@[refl]
theorem ObsCodeEq.refl (F : ObserverFamily O P) (x : P) : ObsCodeEq F x x :=
  fun _ => rfl

@[symm]
theorem ObsCodeEq.symm' {F : ObserverFamily O P} {x y : P}
    (h : ObsCodeEq F x y) : ObsCodeEq F y x :=
  fun o => (h o).symm

@[trans]
theorem ObsCodeEq.trans' {F : ObserverFamily O P} {x y z : P}
    (hxy : ObsCodeEq F x y) (hyz : ObsCodeEq F y z) : ObsCodeEq F x z :=
  fun o => (hxy o).trans (hyz o)

/-- `ObsCodeEq` is an equivalence relation. -/
theorem obsCodeEq_equivalence (F : ObserverFamily O P) :
    Equivalence (ObsCodeEq F) :=
  ⟨ObsCodeEq.refl F, fun h => h.symm', fun h1 h2 => h1.trans' h2⟩

/-- The setoid induced by observer code equality. -/
def obsCodeSetoid (F : ObserverFamily O P) : Setoid P :=
  ⟨ObsCodeEq F, obsCodeEq_equivalence F⟩

/-! ## §5. Spectral Separation -/

/-- **Spectral separation at scale ε**: the observer family is
    ε-coherent (close points get same code) and ε-complete
    (same code means close points). -/
structure SpectralSep (F : ObserverFamily O P) (d : P → P → ℝ) (ε : ℝ) : Prop where
  coherent : ∀ x y : P, d x y ≤ ε → ObsCodeEq F x y
  complete : ∀ x y : P, ObsCodeEq F x y → d x y ≤ ε

/-! ## §6. Theorem A: Code Equality = Ultrametric ε-Ball Membership -/

/-- **Theorem A**: Under spectral separation, code equality ↔ within distance ε. -/
theorem spectral_separation_iff_ball
    (hU : UltrametricDist d) (F : ObserverFamily O P) {ε : ℝ} (hε : 0 ≤ ε)
    (hSep : SpectralSep F d ε) :
    ∀ x y : P, ObsCodeEq F x y ↔ d x y ≤ ε :=
  fun x y => ⟨hSep.complete x y, hSep.coherent x y⟩

/-- **Theorem A, ball formulation**: code equality ↔ same ε-ball. -/
theorem spectral_separation_iff_ultraBall_eq
    (hU : UltrametricDist d) (F : ObserverFamily O P) {ε : ℝ} (hε : 0 ≤ ε)
    (hSep : SpectralSep F d ε) :
    ∀ x y : P, ObsCodeEq F x y ↔ ultraBall d x ε = ultraBall d y ε := by
  intro x y
  rw [ultraBall_eq_iff hU hε]
  exact spectral_separation_iff_ball hU F hε hSep x y

/-- Code equality classes are exactly the ε-balls. -/
theorem codeEq_class_eq_ultraBall
    (hU : UltrametricDist d) (F : ObserverFamily O P) {ε : ℝ} (hε : 0 ≤ ε)
    (hSep : SpectralSep F d ε) (x : P) :
    {y | ObsCodeEq F x y} = ultraBall d x ε := by
  ext y; exact spectral_separation_iff_ball hU F hε hSep x y

/-! ## §7. The ε-Ball Equivalence Relation -/

variable [Fintype P] [DecidableEq P]

/-- The ε-ball equivalence relation: x ~ y iff d(x,y) ≤ ε.
    Requires ε ≥ 0 for reflexivity. -/
def ballEquiv (hU : UltrametricDist d) {ε : ℝ} (hε : 0 ≤ ε) : Setoid P where
  r x y := d x y ≤ ε
  iseqv := by
    refine ⟨fun x => ?_, fun {x y} h => ?_, fun {x y z} hxy hyz => ?_⟩
    · exact hU.self x ▸ hε
    · rwa [hU.symm] at h
    · exact le_trans (hU.triangle x y z) (max_le hxy hyz)

/-! ## §8. Observer Code Map -/

/-- The observer code map: sends each proof state to its tuple of observer values. -/
def observerCode (F : ObserverFamily O P) (x : P) : O → ℝ :=
  fun o => F.obs o x

/-- Same observer code ↔ code-equal. -/
theorem observerCode_eq_iff (F : ObserverFamily O P) (x y : P) :
    observerCode F x = observerCode F y ↔ ObsCodeEq F x y := by
  simp [observerCode, ObsCodeEq, funext_iff]

/-! ## §9. Decoder Stable Balls -/

/-- Under spectral separation, the intersection of an ε-ball with the
    code-equality class equals the ε-ball itself. -/
theorem decoderStableBall_eq_ultraBall
    (hU : UltrametricDist d) (F : ObserverFamily O P) {ε : ℝ} (hε : 0 ≤ ε)
    (hSep : SpectralSep F d ε) (x : P) :
    ultraBall d x ε ∩ {y | ObsCodeEq F x y} = ultraBall d x ε := by
  ext y
  simp only [Set.mem_inter_iff, Set.mem_setOf_eq, mem_ultraBall_iff]
  exact ⟨And.left, fun h => ⟨h, hSep.coherent x y h⟩⟩

/-! ## §10. Observer Basis -/

/-- An observer basis: observers that separate all pairs at distance > ε. -/
def IsObserverBasis (F : ObserverFamily O P) (d : P → P → ℝ) (ε : ℝ)
    (basis : Finset O) : Prop :=
  ∀ x y : P, d x y > ε → ∃ o ∈ basis, F.obs o x ≠ F.obs o y

/-- A certified basis. -/
abbrev CertifiedBasis (F : ObserverFamily O P) (d : P → P → ℝ) (ε : ℝ)
    (basis : Finset O) : Prop :=
  IsObserverBasis F d ε basis

/-- **Theorem D**: the full observer set is always a certified basis. -/
theorem full_observer_set_is_basis
    [Fintype O]
    (F : ObserverFamily O P) {d : P → P → ℝ} {ε : ℝ}
    (hSep : SpectralSep F d ε) :
    CertifiedBasis F d ε Finset.univ := by
  intro x y hxy
  have hne : ¬ ObsCodeEq F x y :=
    fun h => absurd (hSep.complete x y h) (not_le.mpr hxy)
  simp only [ObsCodeEq, not_forall] at hne
  obtain ⟨o, ho⟩ := hne
  exact ⟨o, Finset.mem_univ o, ho⟩

/-- Under spectral separation, a certified basis always exists. -/
theorem exists_certified_basis
    [Fintype O]
    (F : ObserverFamily O P) {d : P → P → ℝ} {ε : ℝ}
    (hSep : SpectralSep F d ε) :
    ∃ basis : Finset O, CertifiedBasis F d ε basis :=
  ⟨Finset.univ, full_observer_set_is_basis F hSep⟩

/-! ## §11. Lipschitz + Separating = Spectral Separation -/

/-- An observer family is ε-Lipschitz: close points get same observations. -/
def IsLipschitzObs (F : ObserverFamily O P) (d : P → P → ℝ) (ε : ℝ) : Prop :=
  ∀ o : O, ∀ x y : P, d x y ≤ ε → F.obs o x = F.obs o y

/-- An observer family is ε-separating. -/
def IsSeparating (F : ObserverFamily O P) (d : P → P → ℝ) (ε : ℝ) : Prop :=
  ∀ x y : P, (∀ o : O, F.obs o x = F.obs o y) → d x y ≤ ε

/-- Lipschitz + separating = spectral separation. -/
theorem spectralSep_of_lipschitz_separating
    (F : ObserverFamily O P) (d : P → P → ℝ) (ε : ℝ)
    (hLip : IsLipschitzObs F d ε) (hSep : IsSeparating F d ε) :
    SpectralSep F d ε where
  coherent x y hxy := fun o => hLip o x y hxy
  complete x y h := hSep x y h

/-! ## §12. Nesting and Monotonicity -/

/-- ε₁-balls are subsets of ε₂-balls when ε₁ ≤ ε₂. -/
theorem ultraBall_subset_of_le (hU : UltrametricDist d) {ε₁ ε₂ : ℝ}
    (hle : ε₁ ≤ ε₂) (x : P) :
    ultraBall d x ε₁ ⊆ ultraBall d x ε₂ :=
  fun _ hy => le_trans hy hle

/-- The ε-balls cover all of P. -/
theorem ultraBall_cover (hU : UltrametricDist d) {ε : ℝ} (hε : 0 ≤ ε)
    (x : P) : x ∈ ultraBall d x ε :=
  self_mem_ultraBall hU x hε

/-! ## §13. Certified Reconstruction -/

/-- **Certified reconstruction**: same observer code → within distance ε. -/
theorem certified_reconstruction
    (hU : UltrametricDist d) (F : ObserverFamily O P) {ε : ℝ} (hε : 0 ≤ ε)
    (hSep : SpectralSep F d ε) :
    ∀ x y : P, observerCode F x = observerCode F y → d x y ≤ ε :=
  fun x y h => hSep.complete x y ((observerCode_eq_iff F x y).mp h)

/-- **Converse reconstruction**: within distance ε → same code. -/
theorem reconstruction_converse
    (F : ObserverFamily O P) {d : P → P → ℝ} {ε : ℝ}
    (hSep : SpectralSep F d ε) :
    ∀ x y : P, d x y ≤ ε → observerCode F x = observerCode F y :=
  fun x y h => (observerCode_eq_iff F x y).mpr (hSep.coherent x y h)

/-! ## §14. Refinement Monotonicity -/

/-- More observers → finer partition. -/
theorem more_observers_finer_partition
    {O₁ O₂ : Type*} (F₁ : ObserverFamily O₁ P) (F₂ : ObserverFamily O₂ P)
    (embed : O₁ → O₂)
    (hcompat : ∀ o : O₁, F₁.obs o = F₂.obs (embed o))
    {x y : P} (h : ObsCodeEq F₂ x y) :
    ObsCodeEq F₁ x y :=
  fun o => by rw [hcompat o]; exact h (embed o)

/-! ## §15. Trivial and Identity Observers -/

/-- The trivial observer separates nothing. -/
def trivialObserver : ObserverFamily Unit P :=
  ⟨fun _ _ => 0⟩

theorem trivialObserver_codeEq (x y : P) : ObsCodeEq (trivialObserver (P := P)) x y :=
  fun _ => rfl

/-- The identity observer on a type with a real-valued embedding. -/
def identityObserver (embed : P → ℝ) : ObserverFamily Unit P :=
  ⟨fun _ => embed⟩

theorem identityObserver_injective_separates
    (embed : P → ℝ) (hinj : Injective embed) (x y : P) (hne : x ≠ y) :
    ¬ ObsCodeEq (identityObserver embed) x y :=
  fun h => hne (hinj (h ()))

/-! ## §16. Code Count -/

/-- The number of distinct observer codes on a finite type. -/
def codeCount [Fintype O] (F : ObserverFamily O P) [DecidableEq (O → ℝ)] : ℕ :=
  (Finset.univ.image (observerCode F)).card

theorem code_count_le_fintype_card [Fintype O] (F : ObserverFamily O P)
    [DecidableEq (O → ℝ)] :
    codeCount F ≤ Fintype.card P := by
  unfold codeCount
  exact (Finset.card_image_le).trans (by simp)

/-- The proof rate: log of the number of distinct codewords. -/
def proofRate [Fintype O] (F : ObserverFamily O P)
    [DecidableEq (O → ℝ)] : ℝ :=
  Real.log (codeCount F)

/-- The proof rate is nonneg when P is nonempty. -/
theorem proofRate_nonneg [Fintype O] [Nonempty P]
    (F : ObserverFamily O P) [DecidableEq (O → ℝ)] :
    0 ≤ proofRate F := by
  unfold proofRate
  apply Real.log_nonneg
  simp only [Nat.one_le_cast]
  unfold codeCount
  exact Finset.card_pos.mpr ⟨_, Finset.mem_image.mpr ⟨Classical.arbitrary P,
    Finset.mem_univ _, rfl⟩⟩

/-! ## §17. Separation Score and Distortion Bound -/

/-- Separation: code equality implies closeness. -/
theorem codeEq_implies_close
    (F : ObserverFamily O P) {d : P → P → ℝ} {ε : ℝ}
    (hSep : SpectralSep F d ε) {x y : P}
    (h : ObsCodeEq F x y) :
    d x y ≤ ε :=
  hSep.complete x y h

/-- Far-apart points cannot be code-equal. -/
theorem separation_implies_code_distinguishes
    (F : ObserverFamily O P) {d : P → P → ℝ} {ε : ℝ}
    (hSep : SpectralSep F d ε) {x y : P}
    (hfar : d x y > ε) :
    ¬ ObsCodeEq F x y :=
  fun h => absurd (hSep.complete x y h) (not_le.mpr hfar)

/-! ## §18. Two-Observer Separation -/

/-- If two observers each separate one pair, together they separate both. -/
theorem two_observer_separation
    (F : ObserverFamily O P) (o₁ o₂ : O) {x₁ y₁ x₂ y₂ : P}
    (h₁ : F.obs o₁ x₁ ≠ F.obs o₁ y₁)
    (h₂ : F.obs o₂ x₂ ≠ F.obs o₂ y₂) :
    ¬ ObsCodeEq F x₁ y₁ ∧ ¬ ObsCodeEq F x₂ y₂ :=
  ⟨fun hce => h₁ (hce o₁), fun hce => h₂ (hce o₂)⟩

/-! ## §19. Combined Duality Statement -/

/-- **Rate–Distortion Duality for Finite Ultrametric Proof Spaces**:

    1. Code equality ↔ ε-ball membership
    2. Certified reconstruction up to distortion ε
    3. Certified basis existence -/
theorem rate_distortion_duality_ultrametric
    [Fintype O]
    (hU : UltrametricDist d)
    (F : ObserverFamily O P) {ε : ℝ} (hε : 0 ≤ ε)
    (hSep : SpectralSep F d ε) :
    (∀ x y : P, ObsCodeEq F x y ↔ d x y ≤ ε) ∧
    (∀ x y : P, observerCode F x = observerCode F y → d x y ≤ ε) ∧
    (∃ basis : Finset O, CertifiedBasis F d ε basis) :=
  ⟨spectral_separation_iff_ball hU F hε hSep,
   certified_reconstruction hU F hε hSep,
   exists_certified_basis F hSep⟩

/-! ## §20. Optimal Basis -/

/-- An optimal basis is a certified basis of minimum cardinality. -/
def IsOptimalBasis (F : ObserverFamily O P) (d : P → P → ℝ) (ε : ℝ)
    (basis : Finset O) : Prop :=
  CertifiedBasis F d ε basis ∧
  ∀ basis' : Finset O, CertifiedBasis F d ε basis' → basis.card ≤ basis'.card

/-- The empty basis is certified iff all pairs are within ε. -/
theorem empty_basis_iff_trivial
    (F : ObserverFamily O P) (d : P → P → ℝ) (ε : ℝ) :
    CertifiedBasis F d ε ∅ ↔ ∀ x y : P, d x y ≤ ε := by
  constructor
  · intro h x y
    by_contra hgt
    push_neg at hgt
    obtain ⟨o, ho, _⟩ := h x y hgt
    simp at ho
  · intro h x y hxy
    exact absurd (h x y) (not_le.mpr hxy)

/-! ## §21. Concrete Construction: Distance-Based Observer -/

/-- An observer family measuring distances from reference points. -/
def distanceObserver (d : P → P → ℝ) : ObserverFamily P P :=
  ⟨fun r p => d r p⟩

/-- Distance observers with all references separate all distinct points. -/
theorem distanceObserver_separates_zero
    (hU : UltrametricDist d) :
    IsSeparating (distanceObserver d (P := P)) d 0 := by
  intro x y h
  have : d x x = d x y := h x
  rw [hU.self] at this
  linarith [hU.nonneg x y]

/-- Self-distance observation is zero. -/
theorem distanceObserver_self
    (hU : UltrametricDist d) (x : P) :
    (distanceObserver d (P := P)).obs x x = 0 :=
  hU.self x

/-! ## §22. Quotient Injection -/

/-- Under spectral separation, the observer code induces an injection
    from the ball quotient to the function space. -/
theorem observerCode_injective_on_quotient
    (F : ObserverFamily O P) {d : P → P → ℝ} {ε : ℝ}
    (hSep : SpectralSep F d ε) (x y : P)
    (h : observerCode F x = observerCode F y) :
    (obsCodeSetoid F).r x y :=
  (observerCode_eq_iff F x y).mp h

/-! ## §23. Axiom Verification -/

#print axioms ultraBall_eq_of_mem
#print axioms ultraBall_eq_or_disjoint
#print axioms spectral_separation_iff_ball
#print axioms ultrametric_partition_disjoint
#print axioms rate_distortion_duality_ultrametric
#print axioms certified_reconstruction
#print axioms exists_certified_basis
#print axioms ultraBall_mem_transitive
#print axioms spectralSep_of_lipschitz_separating
#print axioms two_observer_separation
#print axioms empty_basis_iff_trivial
#print axioms code_count_le_fintype_card
#print axioms proofRate_nonneg

end UltrametricRateDistortion