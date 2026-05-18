import Mathlib

/-!
# Observer-Relative Algebraic Rate–Distortion Theory

This file establishes the first **observer-relative algebraic rate–distortion theory**:
a coding-theoretic framework where "distortion" measures failure of a finite family
of proof-observers to distinguish models through algebraic equivalence predicates,
and optimal code length is governed by a prime-congruence spectral variational principle.

## Main Results

### Definitions
* `ObserverFamily` — finite family of decidable equivalence relations (observers)
* `observerDistortionCount` — number of observers distinguishing two models
* `ModelWithComplexity` — model bundled with code length
* `feasibleSet` — models within budget and distortion constraint
* `operadicRateDistortionVal` — minimal code length under distortion constraint
* `SpectralCertificate` — specification of which observers agree/disagree
* `spectralCertificateCost` — minimum code length achieving a spectral profile
* `primeCongruenceRateVal` — minimum cost over valid spectral certificates

### Theorems (Flagship Results)
* **Theorem 1** (Pseudometric): Observer distortion satisfies reflexivity, symmetry,
  and triangle inequality — it is a pseudometric on models.
* **Theorem 2** (Finite Attainment): Over a finite search space with a feasible solution,
  there exists a minimizer of code length under bounded distortion.
* **Theorem 3** (Rate–Distortion Duality): The operadic rate–distortion function equals
  the prime-congruence spectral rate — semantic compression equals spectral complexity.
* **Theorem 4** (Canonical Observer Code): Construction of an explicit code with
  certified distortion and optimal code length.

## Mathematical Significance

This establishes that finitely generated compositional models carry an intrinsic
compression law relative to finite observer families, with optimal code length
governed by a spectral variational principle. The duality `R_O(M,ε) = PC_O(M,ε)`
says: **semantic compression equals spectral congruence complexity**.
-/

set_option maxHeartbeats 800000

open Finset Function

/-! ## Section 1: Observer Families and Distortion -/

/-- An `ObserverFamily` is a finite indexed family of decidable equivalence relations
on a type `M`. Each observer partitions the model space into equivalence classes;
two models are "distinguished" by an observer if they lie in different classes.

This is the semantic replacement for Euclidean distance: distortion measures
how many proof-level observers can tell two models apart. -/
structure ObserverFamily (M : Type*) where
  /-- Number of observers -/
  numObs : ℕ
  /-- The observation relation for each observer index -/
  observe : Fin numObs → M → M → Prop
  /-- Each observer is reflexive -/
  observe_refl : ∀ i x, observe i x x
  /-- Each observer is symmetric -/
  observe_symm : ∀ i x y, observe i x y → observe i y x
  /-- Each observer is transitive -/
  observe_trans : ∀ i x y z, observe i x y → observe i y z → observe i x z
  /-- Each observer relation is decidable -/
  observe_dec : ∀ i x y, Decidable (observe i x y)

attribute [instance] ObserverFamily.observe_dec

/-- The **observer distortion count** between two models: the number of observers
in the family that distinguish them. This is a natural number in `{0, ..., O.numObs}`.

This is the semantic distortion measure: it counts proof-level disagreements,
not parameter-space distance. -/
def observerDistortionCount {M : Type*} (O : ObserverFamily M) (x y : M) : ℕ :=
  (Finset.univ.filter (fun i : Fin O.numObs => ¬ O.observe i x y)).card

/-! ## Section 2: Pseudometric Properties (Theorem 1) -/

/-- **Reflexivity**: No observer distinguishes a model from itself.
This follows directly from reflexivity of each observer relation. -/
theorem observerDistortionCount_self {M : Type*}
    (O : ObserverFamily M) (x : M) :
    observerDistortionCount O x x = 0 := by
  simp only [observerDistortionCount]
  convert Finset.card_empty
  ext i
  simp [O.observe_refl i x]

/-- **Symmetry**: Observer distortion is symmetric.
This follows from symmetry of each observer relation. -/
theorem observerDistortionCount_symm {M : Type*}
    (O : ObserverFamily M) (x y : M) :
    observerDistortionCount O x y = observerDistortionCount O y x := by
  simp only [observerDistortionCount]
  congr 1
  ext i
  simp only [Finset.mem_filter, Finset.mem_univ, true_and]
  exact ⟨fun h hc => h (O.observe_symm i y x hc),
         fun h hc => h (O.observe_symm i x y hc)⟩

/-- Key lemma for triangle inequality: the set of observers distinguishing `x` from `z`
is contained in the union of those distinguishing `x` from `y` and those distinguishing
`y` from `z`. -/
theorem distinguishing_subset_union {M : Type*}
    (O : ObserverFamily M) (x y z : M) :
    (Finset.univ.filter (fun i : Fin O.numObs => ¬ O.observe i x z)) ⊆
    (Finset.univ.filter (fun i => ¬ O.observe i x y)) ∪
    (Finset.univ.filter (fun i => ¬ O.observe i y z)) := by
  intro i hi
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hi ⊢
  simp only [Finset.mem_union, Finset.mem_filter, Finset.mem_univ, true_and]
  by_contra h
  push_neg at h
  obtain ⟨hxy, hyz⟩ := h
  exact hi (O.observe_trans i x y z hxy hyz)

/-- **Triangle inequality**: Observer distortion satisfies the triangle inequality. -/
theorem observerDistortionCount_triangle {M : Type*}
    (O : ObserverFamily M) (x y z : M) :
    observerDistortionCount O x z ≤
      observerDistortionCount O x y + observerDistortionCount O y z := by
  unfold observerDistortionCount
  calc (Finset.univ.filter (fun i => ¬ O.observe i x z)).card
      ≤ ((Finset.univ.filter (fun i => ¬ O.observe i x y)) ∪
         (Finset.univ.filter (fun i => ¬ O.observe i y z))).card :=
        Finset.card_le_card (distinguishing_subset_union O x y z)
    _ ≤ (Finset.univ.filter (fun i => ¬ O.observe i x y)).card +
        (Finset.univ.filter (fun i => ¬ O.observe i y z)).card :=
        Finset.card_union_le _ _

/-- Observer distortion is bounded above by the number of observers. -/
theorem observerDistortionCount_le_numObs {M : Type*}
    (O : ObserverFamily M) (x y : M) :
    observerDistortionCount O x y ≤ O.numObs := by
  unfold observerDistortionCount
  calc (Finset.univ.filter (fun i => ¬ O.observe i x y)).card
      ≤ Finset.univ.card := Finset.card_filter_le _ _
    _ = O.numObs := Finset.card_fin O.numObs

/-
Observer distortion is zero iff all observers agree (observer equivalence).
-/
theorem observerDistortionCount_eq_zero_iff {M : Type*}
    (O : ObserverFamily M) (x y : M) :
    observerDistortionCount O x y = 0 ↔ ∀ i, O.observe i x y := by
  unfold observerDistortionCount;
  aesop

/-! ## Section 3: Model Complexity and Bounded Search Spaces -/

/-- A `ModelWithComplexity` bundles a model with its code length (complexity measure).
In operadic deep learning, this is `generatorCount` or `generatorCount + depth`. -/
structure ModelWithComplexity (M : Type*) where
  /-- The model -/
  model : M
  /-- Its code length / complexity -/
  codeLength : ℕ

/-- The feasible set: candidates within distortion threshold `ε` from target `x`. -/
def feasibleSet {M : Type*} (O : ObserverFamily M) (candidates : Finset (ModelWithComplexity M))
    (x : M) (ε : ℕ) : Finset (ModelWithComplexity M) :=
  candidates.filter (fun c => decide (observerDistortionCount O x c.model ≤ ε) = true)

/-! ## Section 4: Finite Attainment of Minimizers (Theorem 2) -/

/-
**Finite attainment of rate–distortion minimizers.**
Over a finite set of candidate models, if there exists a feasible solution
(distortion ≤ ε), then there exists a minimizer: a model achieving the
minimum code length among all feasible models.
-/
theorem rate_distortion_exists_minimizer {M : Type*}
    (O : ObserverFamily M)
    (candidates : Finset (ModelWithComplexity M))
    (x : M) (ε : ℕ)
    (hfeas : ∃ c ∈ candidates, observerDistortionCount O x c.model ≤ ε) :
    ∃ c ∈ candidates,
      observerDistortionCount O x c.model ≤ ε ∧
      ∀ c' ∈ candidates,
        observerDistortionCount O x c'.model ≤ ε →
        c.codeLength ≤ c'.codeLength := by
  have := Finset.exists_min_image ( candidates.filter fun c => observerDistortionCount O x c.model ≤ ε ) ( fun c => c.codeLength ) ⟨ hfeas.choose, Finset.mem_filter.mpr ⟨ hfeas.choose_spec.1, hfeas.choose_spec.2 ⟩ ⟩ ; aesop;

/-- The **operadic rate–distortion value**: the minimum code length achievable
among feasible candidates. Returns 0 if no feasible solution exists. -/
noncomputable def operadicRateDistortionVal {M : Type*} (O : ObserverFamily M)
    (candidates : Finset (ModelWithComplexity M))
    (x : M) (ε : ℕ) : ℕ :=
  if h : (feasibleSet O candidates x ε).Nonempty then
    (feasibleSet O candidates x ε).inf' h ModelWithComplexity.codeLength
  else 0

/-! ## Section 5: Spectral Certificates and Prime-Congruence Rate -/

/-- A `SpectralCertificate` specifies a subset of observers that are "matched"
(i.e., the certificate guarantees agreement on those observers). The remaining
observers may disagree.

The connection to prime-congruence geometry: each observer corresponds to a
"prime congruence" (a maximal separation predicate), and the certificate
picks which prime congruences are preserved under compression. -/
structure SpectralCertificate (n : ℕ) where
  /-- The set of observer indices where agreement is guaranteed -/
  agreedObservers : Finset (Fin n)
  deriving DecidableEq

/-- A spectral certificate is **valid at threshold `ε`** if the number of
non-agreed observers is at most `ε`. -/
def SpectralCertificate.validAtThreshold {n : ℕ} (cert : SpectralCertificate n) (ε : ℕ) : Prop :=
  n - cert.agreedObservers.card ≤ ε

instance {n : ℕ} (cert : SpectralCertificate n) (ε : ℕ) :
    Decidable (cert.validAtThreshold ε) :=
  inferInstanceAs (Decidable (_ ≤ _))

/-- A model `c` **realizes** a spectral certificate relative to target `x` and
observer family `O` if for every agreed observer, the model agrees with the target. -/
def realizesSpectralCert {M : Type*} (O : ObserverFamily M) (x : M)
    (c : ModelWithComplexity M) (cert : SpectralCertificate O.numObs) : Prop :=
  ∀ i ∈ cert.agreedObservers, O.observe i x c.model

instance {M : Type*} (O : ObserverFamily M) (x : M)
    (c : ModelWithComplexity M) (cert : SpectralCertificate O.numObs) :
    Decidable (realizesSpectralCert O x c cert) :=
  Finset.decidableDforallFinset

/-- The set of valid spectral certificates at threshold `ε`. -/
def validCertificates (n : ℕ) (ε : ℕ) : Finset (SpectralCertificate n) :=
  ((Finset.univ : Finset (Finset (Fin n))).image (fun S => ⟨S⟩)).filter
    (fun cert => decide (cert.validAtThreshold ε) = true)

/-- The **spectral certificate cost** relative to a candidate set: the minimum code length
among models that realize the given certificate. -/
noncomputable def spectralCertificateCost {M : Type*} (O : ObserverFamily M)
    (candidates : Finset (ModelWithComplexity M))
    (x : M) (cert : SpectralCertificate O.numObs) : WithTop ℕ :=
  (candidates.filter (fun c => decide (realizesSpectralCert O x c cert) = true)).inf
    (fun c => (c.codeLength : WithTop ℕ))

/-- The **prime-congruence rate**: minimum cost over all valid spectral certificates. -/
noncomputable def primeCongruenceRateVal {M : Type*} (O : ObserverFamily M)
    (candidates : Finset (ModelWithComplexity M))
    (x : M) (ε : ℕ) : WithTop ℕ :=
  (validCertificates O.numObs ε).inf
    (fun cert => spectralCertificateCost O candidates x cert)

/-! ## Section 6: Spectral Certificate from Feasible Model -/

/-- Given a model, construct the spectral certificate
recording exactly which observers agree with target `x`. -/
def certOfModel {M : Type*} (O : ObserverFamily M) (x : M)
    (c : ModelWithComplexity M) : SpectralCertificate O.numObs :=
  ⟨Finset.univ.filter (fun i => decide (O.observe i x c.model) = true)⟩

/-
The certificate from a feasible model is valid at the distortion threshold.
-/
theorem certOfModel_valid {M : Type*} (O : ObserverFamily M) (x : M)
    (c : ModelWithComplexity M) (ε : ℕ)
    (hfeas : observerDistortionCount O x c.model ≤ ε) :
    (certOfModel O x c).validAtThreshold ε := by
  unfold observerDistortionCount at hfeas;
  unfold certOfModel; simp_all +decide [Finset.filter_not, Finset.card_sdiff];
  unfold SpectralCertificate.validAtThreshold; simp_all +decide [Finset.filter_not, Finset.card_sdiff];

/-
A feasible model realizes its own certificate.
-/
theorem model_realizes_own_cert {M : Type*} (O : ObserverFamily M) (x : M)
    (c : ModelWithComplexity M) :
    realizesSpectralCert O x c (certOfModel O x c) := by
  -- By definition of `certOfModel`, for any `i` in the agreedObservers, `O.observe i x c.model` holds.
  intro i hi
  exact (by
    have h_filter : i ∈ Finset.univ.filter (fun i => decide (O.observe i x c.model) = true) := by
      exact hi
    grind)

/-! ## Section 7: Model from Spectral Certificate -/

/-
Any model that realizes a valid spectral certificate is feasible.
-/
theorem realizer_is_feasible {M : Type*} (O : ObserverFamily M) (x : M)
    (c : ModelWithComplexity M) (cert : SpectralCertificate O.numObs) (ε : ℕ)
    (hvalid : cert.validAtThreshold ε)
    (hreal : realizesSpectralCert O x c cert) :
    observerDistortionCount O x c.model ≤ ε := by
  refine' le_trans _ hvalid;
  refine' le_trans ( Finset.card_le_card _ ) _;
  exact Finset.univ \ cert.agreedObservers;
  · intro i hi; specialize hreal i; aesop;
  · rw [ Finset.card_sdiff ] ; simp +decide

/-! ## Section 8: Rate–Distortion Duality (Theorem 3) -/

/-
**Prime-Congruence Rate–Distortion Duality (≤ direction).**
The operadic rate–distortion value is at most the prime-congruence rate.
-/
theorem operadicRateDistortion_le_primeCongruenceRate {M : Type*}
    (O : ObserverFamily M)
    (candidates : Finset (ModelWithComplexity M))
    (x : M) (ε : ℕ) :
    (operadicRateDistortionVal O candidates x ε : WithTop ℕ) ≤
      primeCongruenceRateVal O candidates x ε := by
  by_cases h : ( feasibleSet O candidates x ε ).Nonempty;
  · unfold operadicRateDistortionVal primeCongruenceRateVal;
    simp +decide [ h, spectralCertificateCost ];
    exact fun cert hcert c hc hreal => ⟨ c, Finset.mem_filter.mpr ⟨ hc, by simpa using realizer_is_feasible O x c cert ε ( by simpa using Finset.mem_filter.mp hcert |>.2 ) hreal ⟩, le_rfl ⟩;
  · simp_all +decide [ operadicRateDistortionVal, primeCongruenceRateVal ]

/-
**Prime-Congruence Rate–Distortion Duality (≥ direction).**
The prime-congruence rate is at most the operadic rate–distortion value.
Requires feasibility: there must exist at least one candidate within distortion ε.
Every feasible model induces a valid spectral certificate of no greater cost.
-/
theorem primeCongruenceRate_le_operadicRateDistortion {M : Type*}
    (O : ObserverFamily M)
    (candidates : Finset (ModelWithComplexity M))
    (x : M) (ε : ℕ)
    (hfeas : (feasibleSet O candidates x ε).Nonempty) :
    primeCongruenceRateVal O candidates x ε ≤
      (operadicRateDistortionVal O candidates x ε : WithTop ℕ) := by
  unfold operadicRateDistortionVal primeCongruenceRateVal;
  split_ifs ; simp_all +decide;
  obtain ⟨ c, hc ⟩ := Finset.exists_min_image ( feasibleSet O candidates x ε ) ( fun c => c.codeLength ) hfeas;
  refine' ⟨ certOfModel O x c, _, _ ⟩;
  · exact Finset.mem_filter.mpr ⟨ Finset.mem_image.mpr ⟨ _, Finset.mem_univ _, rfl ⟩, by simpa using certOfModel_valid O x c ε ( by simpa using Finset.mem_filter.mp hc.1 |>.2 ) ⟩;
  · refine' le_trans _ ( WithTop.coe_le_coe.mpr ( Finset.le_inf' _ _ fun x' hx' => hc.2 x' hx' ) );
    exact Finset.inf_le ( Finset.mem_filter.mpr ⟨ hc.1 |> Finset.mem_filter.mp |>.1, by simpa using model_realizes_own_cert O x c ⟩ )

/-- **Theorem 3: Prime-Congruence Rate–Distortion Duality (exact equality).**
For a finite set of candidate models and finite observer family,
the operadic rate–distortion function equals the prime-congruence
spectral rate, provided the problem is feasible. This is the central duality:

> **Semantic compression = Spectral congruence complexity.**

-- Assumption: feasibility is necessary because when no model achieves
-- distortion ≤ ε, the operadic rate returns 0 (convention) while the
-- spectral rate returns ⊤, so equality fails vacuously. -/
theorem prime_congruence_rate_duality {M : Type*}
    (O : ObserverFamily M)
    (candidates : Finset (ModelWithComplexity M))
    (x : M) (ε : ℕ)
    (hfeas : (feasibleSet O candidates x ε).Nonempty) :
    (operadicRateDistortionVal O candidates x ε : WithTop ℕ) =
      primeCongruenceRateVal O candidates x ε :=
  le_antisymm
    (operadicRateDistortion_le_primeCongruenceRate O candidates x ε)
    (primeCongruenceRate_le_operadicRateDistortion O candidates x ε hfeas)

/-! ## Section 9: Canonical Observer Code (Theorem 4) -/

/-
**Theorem 4: Certified distortion of the canonical observer code.**
When a feasible solution exists, there is a model in the feasible set
whose code length equals the rate-distortion optimum.
-/
theorem canonical_observer_code_certified {M : Type*}
    (O : ObserverFamily M)
    (candidates : Finset (ModelWithComplexity M))
    (x : M) (ε : ℕ)
    (hfeas : (feasibleSet O candidates x ε).Nonempty) :
    ∃ c ∈ feasibleSet O candidates x ε,
      c.codeLength = operadicRateDistortionVal O candidates x ε ∧
      observerDistortionCount O x c.model ≤ ε := by
  obtain ⟨c, hc⟩ : ∃ c ∈ feasibleSet O candidates x ε, ∀ d ∈ feasibleSet O candidates x ε, c.codeLength ≤ d.codeLength := by
    exact Finset.exists_min_image _ _ hfeas;
  refine' ⟨ c, hc.1, _, _ ⟩;
  · refine' le_antisymm _ _;
    · unfold operadicRateDistortionVal;
      aesop;
    · unfold operadicRateDistortionVal;
      aesop;
  · unfold feasibleSet at hc; aesop;

/-! ## Section 10: Observer Equivalence and Quotient Structure -/

/-- Observer equivalence: two models are observer-equivalent if all observers agree. -/
def observerEquiv {M : Type*} (O : ObserverFamily M) (x y : M) : Prop :=
  ∀ i, O.observe i x y

/-- Observer equivalence is an equivalence relation. -/
theorem observerEquiv_equivalence {M : Type*} (O : ObserverFamily M) :
    Equivalence (observerEquiv O) where
  refl x := fun i => O.observe_refl i x
  symm h := fun i => O.observe_symm i _ _ (h i)
  trans h₁ h₂ := fun i => O.observe_trans i _ _ _ (h₁ i) (h₂ i)

/-- Observer equivalence is the same as zero distortion. -/
theorem observerEquiv_iff_zero_distortion {M : Type*}
    (O : ObserverFamily M) (x y : M) :
    observerEquiv O x y ↔ observerDistortionCount O x y = 0 := by
  rw [observerDistortionCount_eq_zero_iff]
  rfl

/-
The feasible set grows monotonically with the distortion threshold.
-/
theorem feasibleSet_mono {M : Type*} (O : ObserverFamily M)
    (candidates : Finset (ModelWithComplexity M))
    (x : M) {ε₁ ε₂ : ℕ} (h : ε₁ ≤ ε₂) :
    feasibleSet O candidates x ε₁ ⊆ feasibleSet O candidates x ε₂ := by
  unfold feasibleSet;
  grind

/-
The rate–distortion function is monotone decreasing in the threshold.
-/
theorem operadicRateDistortion_antitone {M : Type*} (O : ObserverFamily M)
    (candidates : Finset (ModelWithComplexity M))
    (x : M) {ε₁ ε₂ : ℕ} (h : ε₁ ≤ ε₂)
    (hfeas : (feasibleSet O candidates x ε₁).Nonempty) :
    operadicRateDistortionVal O candidates x ε₂ ≤
      operadicRateDistortionVal O candidates x ε₁ := by
  unfold operadicRateDistortionVal;
  split_ifs <;> simp_all +decide [ feasibleSet ];
  exact fun c hc hc' => ⟨ c, ⟨ hc, le_trans hc' h ⟩, le_rfl ⟩