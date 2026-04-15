/-! # CatalogBuild.Computation.Factoring.IntegerDiffraction

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 33
-/

import Mathlib

noncomputable section

/-- The diffraction amplitude of a finite set S ⊂ ℤ at frequency θ ∈ ℝ.
This is the fundamental "wave function" — each integer in S emits a
unit-amplitude wave e^{2πisθ}, and they superpose. -/
def diffractionAmplitude (S : Finset ℤ) (θ : ℝ) : ℂ :=
  ∑ s ∈ S, Complex.exp (2 * Real.pi * s * θ * Complex.I)

/-- The diffraction intensity — the physically observable quantity.
    This is the squared modulus of the amplitude. -/

def diffractionIntensity (S : Finset ℤ) (θ : ℝ) : ℝ :=
  Complex.normSq (diffractionAmplitude S θ)

/-- The autocorrelation function: counts the number of pairs (s, t) ∈ S × S
    with s - t = d. This is the "difference multiset" of S. -/

def autocorrelation (S : Finset ℤ) (d : ℤ) : ℕ :=
  ((S ×ˢ S).filter (fun p => p.1 - p.2 = d)).card

/-- A set is a Sidon set (B₂ set) if all pairwise differences are distinct,
    i.e., the autocorrelation is at most 1 for d ≠ 0. -/

def IsSidonSet (S : Finset ℤ) : Prop :=
  ∀ d : ℤ, d ≠ 0 → autocorrelation S d ≤ 1

/-- Two sets are "homometric" if they have the same diffraction pattern,
    equivalently the same autocorrelation function. -/

def IsHomometric (S T : Finset ℤ) : Prop :=
  ∀ d : ℤ, autocorrelation S d = autocorrelation T d

/-! ## Section 2: The Two-Photon Experiment

"Light up just 2 numbers on the number line and watch them interfere."

For S = {a, b}, the diffraction intensity is:
  I(θ) = 2 + 2cos(2π(b-a)θ)

This is Young's double-slit experiment on the integers!
The fringe spacing is determined by the gap (b - a). -/

/-- The diffraction amplitude of a singleton set. -/

theorem amplitude_singleton (a : ℤ) (θ : ℝ) :
    diffractionAmplitude {a} θ = Complex.exp (2 * Real.pi * a * θ * Complex.I) := by
  simp [diffractionAmplitude]

/-
PROBLEM
The diffraction intensity of a singleton is always 1.
    A single photon has no interference pattern.

PROVIDED SOLUTION
Unfold diffractionIntensity and diffractionAmplitude, simplify the singleton sum, then use the fact that |e^{ix}|² = 1 for any real x. Use Complex.normSq_exp_ofReal_mul_I or similar.
-/

theorem intensity_singleton (a : ℤ) (θ : ℝ) :
    diffractionIntensity {a} θ = 1 := by
  unfold diffractionIntensity; norm_num [ Complex.normSq_eq_norm_sq, Complex.norm_exp ] ;
  exact Or.inl ( by rw [ diffractionAmplitude ] ; norm_num [ Complex.norm_exp ] )

/-
PROBLEM
Two-slit amplitude: sum of two complex exponentials.

PROVIDED SOLUTION
Unfold diffractionAmplitude and simplify the sum over {a, b} using Finset.sum_pair hab.
-/

theorem amplitude_pair (a b : ℤ) (hab : a ≠ b) (θ : ℝ) :
    diffractionAmplitude {a, b} θ =
    Complex.exp (2 * Real.pi * a * θ * Complex.I) +
    Complex.exp (2 * Real.pi * b * θ * Complex.I) := by
  exact Finset.sum_pair hab

/-! ## Section 3: Fundamental Properties of Diffraction -/

/-
PROBLEM
**Non-negativity**: Diffraction intensity is always non-negative.
    (Intensity is a squared modulus — it's physical!)

PROVIDED SOLUTION
diffractionIntensity is defined as Complex.normSq of something, and Complex.normSq is always nonneg. Use map_nonneg or Complex.normSq_nonneg.
-/

theorem intensity_nonneg (S : Finset ℤ) (θ : ℝ) :
    0 ≤ diffractionIntensity S θ := by
  exact Complex.normSq_nonneg _

/-
PROBLEM
**Peak Theorem**: At θ = 0, all waves are in phase and constructively
    interfere. The intensity equals |S|². This is the "bright center."

PROVIDED SOLUTION
At θ=0, each term in the sum is exp(0) = 1, so the amplitude is |S|. The normSq of a real number n is n². Unfold diffractionIntensity and diffractionAmplitude, simplify using mul_zero or zero_mul to get exp(0)=1 for each term, then show the sum is (S.card : ℂ), and normSq of (S.card : ℂ) is (S.card)².
-/

theorem intensity_at_zero (S : Finset ℤ) :
    diffractionIntensity S 0 = (S.card : ℝ) ^ 2 := by
  unfold diffractionIntensity;
  unfold diffractionAmplitude; norm_num [ Complex.normSq ] ; ring;

/-
PROBLEM
**Empty set**: The vacuum has zero diffraction intensity.

PROVIDED SOLUTION
Unfold diffractionIntensity and diffractionAmplitude, the empty sum is 0, and normSq 0 = 0.
-/

theorem intensity_empty (θ : ℝ) :
    diffractionIntensity ∅ θ = 0 := by
  unfold diffractionIntensity diffractionAmplitude ; norm_num

/-
PROBLEM
The amplitude of the empty set is zero.

PROVIDED SOLUTION
Unfold diffractionAmplitude, the empty sum is 0.
-/

theorem amplitude_empty (θ : ℝ) :
    diffractionAmplitude (∅ : Finset ℤ) θ = 0 := by
  exact Finset.sum_empty

/-! ## Section 4: Translation Invariance —
    "Shifting the grating doesn't change the fringes"

This is a profound physical fact: the diffraction pattern depends only on
the *relative positions* of the slits, not their absolute location.
Mathematically: I_{S+k}(θ) = I_S(θ) for all k ∈ ℤ. -/

/-- Translate a set by an integer offset. -/

def translateSet (S : Finset ℤ) (k : ℤ) : Finset ℤ :=
  S.map ⟨(· + k), add_left_injective k⟩

/-
PROBLEM
Translation multiplies the amplitude by a phase factor.

PROVIDED SOLUTION
Unfold diffractionAmplitude and translateSet. After mapping, the sum becomes ∑ s ∈ S, exp(2π(s+k)θi). Factor out exp(2πkθi) using exp(a+b)=exp(a)·exp(b), then pull the constant factor out of the sum using Finset.mul_sum.
-/

theorem amplitude_translate (S : Finset ℤ) (k : ℤ) (θ : ℝ) :
    diffractionAmplitude (translateSet S k) θ =
    Complex.exp (2 * Real.pi * k * θ * Complex.I) * diffractionAmplitude S θ := by
  unfold diffractionAmplitude translateSet; simp +decide [ mul_assoc, mul_left_comm, Finset.mul_sum _ _ _ ] ; ring;
  exact Finset.sum_congr rfl fun _ _ => by rw [ ← Complex.exp_add ] ; ring;

/-
PROBLEM
**Translation Invariance of Intensity**: Shifting S by k doesn't change I(θ).
    The diffraction pattern sees only differences, not absolute positions.

PROVIDED SOLUTION
Use amplitude_translate to get diffractionAmplitude (translateSet S k) θ = exp(2πkθi) * diffractionAmplitude S θ. Then diffractionIntensity is normSq, and normSq(c*z) = normSq(c)*normSq(z). Since c = exp(ix) has normSq = 1, we get normSq(z).
-/

theorem intensity_translate (S : Finset ℤ) (k : ℤ) (θ : ℝ) :
    diffractionIntensity (translateSet S k) θ = diffractionIntensity S θ := by
  unfold diffractionIntensity;
  rw [ amplitude_translate ];
  norm_num [ Complex.normSq_eq_norm_sq, Complex.norm_exp ]

/-! ## Section 5: The Autocorrelation Encodes the Diffraction

The fundamental theorem connecting algebra and optics:
  I_S(θ) = ∑_d c_S(d) · e^{2πidθ}

where c_S(d) is the autocorrelation. This means:
- The diffraction pattern is the Fourier transform of the autocorrelation
- Two sets with the same autocorrelation have identical diffraction (homometric sets)
- The diffraction pattern cannot in general distinguish a set from its "homometric twins" -/

/-
PROBLEM
Self-autocorrelation at d=0 equals |S|.

PROVIDED SOLUTION
When d=0, the filter condition is s-t=0, i.e., s=t. The pairs in S×S with s=t are exactly the diagonal, which bijects with S. So the count is S.card. Use the bijection (s,s) ↔ s.
-/

theorem autocorrelation_zero (S : Finset ℤ) :
    autocorrelation S 0 = S.card := by
  unfold autocorrelation;
  rw [ Finset.card_filter ];
  erw [ Finset.sum_product ];
  simp +decide [ sub_eq_zero ]

/-
PROBLEM
The autocorrelation of a singleton at d=0 is 1.

PROVIDED SOLUTION
For S={a}, S×S = {(a,a)}, filter with d=0 gives {(a,a)}, card = 1. Just simp/decide.
-/

theorem autocorrelation_singleton_zero (a : ℤ) :
    autocorrelation {a} 0 = 1 := by
  exact autocorrelation_zero _

/-
PROBLEM
The autocorrelation of a singleton at d≠0 is 0.

PROVIDED SOLUTION
For S={a}, S×S = {(a,a)}, the only pair has difference 0 ≠ d, so the filter is empty, card = 0. Unfold autocorrelation, simp, and use hd.
-/

theorem autocorrelation_singleton_ne (a : ℤ) (d : ℤ) (hd : d ≠ 0) :
    autocorrelation {a} d = 0 := by
  unfold autocorrelation; aesop;

/-! ## Section 6: Sidon Sets — Maximum Diffraction Flatness

A Sidon set (B₂ set) has all pairwise differences distinct.
In diffraction terms: the autocorrelation is as "flat" as possible —
each nonzero difference appears exactly once. This means the diffraction
pattern is maximally uniform, like white light.

Sidon sets are the "anti-lasers" of integer diffraction: no frequency
is preferentially amplified. -/

/-
PROBLEM
A singleton is always a Sidon set.

PROVIDED SOLUTION
Use autocorrelation_singleton_ne to show autocorrelation {a} d = 0 for d ≠ 0, which is ≤ 1.
-/

theorem sidon_singleton (a : ℤ) : IsSidonSet {a} := by
  -- For any d ≠ 0, the autocorrelation is zero, which is ≤ 1.
  intros d hd
  simp [IsSidonSet, autocorrelation_singleton_ne a d hd]

/-
PROBLEM
Any pair {a, b} with a ≠ b is a Sidon set.

PROVIDED SOLUTION
For S = {a,b} and d ≠ 0, the product S×S = {(a,a),(a,b),(b,a),(b,b)}. Filter by s-t=d: (a,a) has diff 0, (b,b) has diff 0, (a,b) has diff a-b, (b,a) has diff b-a. Since d≠0, at most one of a-b=d or b-a=d holds (and not both since a≠b means a-b ≠ b-a). So the count is ≤ 1.
-/

theorem sidon_pair (a b : ℤ) (hab : a ≠ b) : IsSidonSet {a, b} := by
  -- Assume a ≠ b. Let d ∈ ℤ be non-zero.
  by_contra h;
  unfold IsSidonSet at h;
  simp_all +decide [ Finset.filter_insert, Finset.filter_singleton, autocorrelation ];
  obtain ⟨ x, hx₁, hx₂ ⟩ := h; rw [ Finset.card_filter ] at hx₂; simp_all +decide [ Finset.sum ] ;
  grind +ring

/-! ## Section 7: Coherence and Decoherence

When two sets S and T are "illuminated" simultaneously, the total
diffraction is NOT simply I_S + I_T. There are interference terms:

I_{S∪T} = I_S + I_T + 2·Re(∑_{s∈S,t∈T} e^{2πi(s-t)θ})

The cross-term represents coherence between the two "light sources."

**Coherence** (cross-term large): The sets have many common differences
**Decoherence** (cross-term small): The differences are "incommensurable" -/

/-- The cross-amplitude between two sets. -/

def crossAmplitude (S T : Finset ℤ) (θ : ℝ) : ℂ :=
  ∑ s ∈ S, ∑ t ∈ T, Complex.exp (2 * Real.pi * (↑(s - t) : ℝ) * θ * Complex.I)

/-
PROBLEM
The amplitude of a union of disjoint sets decomposes.

PROVIDED SOLUTION
Unfold diffractionAmplitude. Use Finset.sum_union h (the disjointness hypothesis).
-/

theorem amplitude_disjoint_union (S T : Finset ℤ) (h : Disjoint S T) (θ : ℝ) :
    diffractionAmplitude (S ∪ T) θ =
    diffractionAmplitude S θ + diffractionAmplitude T θ := by
  exact Finset.sum_union h

/-! ## Section 8: Reflection Symmetry

The diffraction pattern of S equals that of -S (the reflection).
Physically: a mirror image of the grating produces the same fringes.
This is why diffraction cannot distinguish chirality — the
"phase problem" of crystallography. -/

/-- Reflect a set through the origin. -/

def reflectSet (S : Finset ℤ) : Finset ℤ :=
  S.map ⟨fun x => -x, neg_injective⟩

/-
PROBLEM
Reflection has the same intensity: I_{-S}(θ) = I_S(θ).

PROVIDED SOLUTION
The amplitude of reflectSet S at θ is ∑_{s∈S} exp(2π(-s)θi) = ∑_{s∈S} exp(-2πsθi) = conj(∑_{s∈S} exp(2πsθi)) = conj(A_S(θ)). Then normSq(conj(z)) = normSq(z).
-/

theorem intensity_reflect (S : Finset ℤ) (θ : ℝ) :
    diffractionIntensity (reflectSet S) θ = diffractionIntensity S θ := by
  unfold diffractionIntensity diffractionAmplitude reflectSet;
  norm_num [ Complex.normSq, Complex.ext_iff, Finset.sum_neg_distrib ];
  norm_num [ Complex.exp_re, Complex.exp_im ]

/-! ## Section 9: Prime Diffraction — The Light Primes

The primes ≡ 1 (mod 4) are the "light primes": they split in ℤ[i]
as p = π·π̄, creating paired Gaussian integer photons. Their
diffraction pattern has special arithmetic structure.

The primes ≡ 3 (mod 4) are "dark primes": they remain inert in ℤ[i]
and contribute darkness to the sum-of-squares representation theory. -/

/-- A prime is "light" if it is ≡ 1 (mod 4). -/

def IsLightPrime (p : ℕ) : Prop := Nat.Prime p ∧ p % 4 = 1

/-- A prime is "dark" if it is ≡ 3 (mod 4). -/

def IsDarkPrime (p : ℕ) : Prop := Nat.Prime p ∧ p % 4 = 3

/-- 2 is the unique "twilight prime" — neither fully light nor fully dark. -/

structure at specific "harmonic" frequencies related to the
distribution of primes. This intermediate structure is the
source of their compressive power. -/

/-- A set has "spiked diffraction" if its autocorrelation is concentrated
    on a few values. Formalized: the support of the autocorrelation
    (restricted to nonzero d) has size at most k. -/

def HasSpikedDiffraction (S : Finset ℤ) (k : ℕ) : Prop :=
  ((S ×ˢ S).image (fun p => p.1 - p.2) |>.filter (· ≠ 0)).card ≤ k

/-! ## Section 11: Oracle Consultation

The Oracle speaks:

"Every finite set of integers is a frozen wave. To diffract it is to
let the wave remember what it was. The bright fringes are the truths
the set was built to encode. The dark fringes are the truths it
was built to conceal. Between brightness and darkness, the light
primes hold the key — for they alone can split the wave into its
conjugate halves, each carrying exactly half the truth."

In formal terms: the Fourier analysis of a finite set over ℤ/nℤ
decomposes the characteristic function into frequencies, and the
"light" frequencies (those associated with quadratic residues)
carry the compressible structure. -/

/-! ## Section 12: Computational Experiments -/

end -- end noncomputable section

/-- Compute the autocorrelation of a finite set at a given difference. -/

def autocorrelationCompute (S : List ℤ) (d : ℤ) : ℕ :=
  (S.product S).countP (fun p => p.1 - p.2 = d)

-- Two-photon experiment: {0, 1}
#eval autocorrelationCompute [0, 1] 0     -- Expected: 2
#eval autocorrelationCompute [0, 1] 1     -- Expected: 1
#eval autocorrelationCompute [0, 1] (-1)  -- Expected: 1
#eval autocorrelationCompute [0, 1] 2     -- Expected: 0

-- Three-photon experiment: {0, 1, 3} — a Sidon set
#eval autocorrelationCompute [0, 1, 3] 0    -- Expected: 3
#eval autocorrelationCompute [0, 1, 3] 1    -- Expected: 1
#eval autocorrelationCompute [0, 1, 3] 2    -- Expected: 1
#eval autocorrelationCompute [0, 1, 3] 3    -- Expected: 1

-- Non-Sidon set: {0, 1, 2, 3}
#eval autocorrelationCompute [0, 1, 2, 3] 1  -- Expected: 3 (repeated difference!)

-- Light primes up to 30: {5, 13, 17, 29}
#eval autocorrelationCompute [5, 13, 17, 29] 0   -- 4
#eval autocorrelationCompute [5, 13, 17, 29] 8   -- 1 (13-5)
#eval autocorrelationCompute [5, 13, 17, 29] 12  -- 2 (17-5 and 29-17)
#eval autocorrelationCompute [5, 13, 17, 29] 4   -- 1 (17-13)
#eval autocorrelationCompute [5, 13, 17, 29] 16  -- 1 (29-13)
#eval autocorrelationCompute [5, 13, 17, 29] 24  -- 1 (29-5)

-- Dark primes up to 20: {3, 7, 11, 19}
#eval autocorrelationCompute [3, 7, 11, 19] 4  -- 2 (7-3 and 11-7)
-- Dark primes have repeated differences — they cohere.

noncomputable section

/-! ## Section 13: The Homometric Problem

Two sets S and T are *homometric* if they have the same diffraction pattern
(equivalently, the same autocorrelation). This is the mathematical version
of the crystallographic phase problem. -/

/-- Homometricity is reflexive. -/

theorem homometric_refl (S : Finset ℤ) : IsHomometric S S := fun _ => rfl

/-- Homometricity is symmetric. -/

theorem homometric_symm {S T : Finset ℤ} (h : IsHomometric S T) :
    IsHomometric T S := fun d => (h d).symm

/-- Homometricity is transitive. -/

theorem homometric_trans {S T U : Finset ℤ} (h1 : IsHomometric S T)
    (h2 : IsHomometric T U) : IsHomometric S U :=
  fun d => (h1 d).trans (h2 d)

/-
PROBLEM
Homometric sets have the same cardinality (from autocorrelation at 0).

PROVIDED SOLUTION
Use the fact that autocorrelation S 0 = S.card (autocorrelation_zero). Since h says autocorrelation S d = autocorrelation T d for all d, in particular for d=0: S.card = autocorrelation S 0 = autocorrelation T 0 = T.card.
-/

theorem homometric_card {S T : Finset ℤ} (h : IsHomometric S T) :
    S.card = T.card := by
  -- By definition of homometricity, the autocorrelations at 0 are equal.
  have h_autocorrelation_zero : autocorrelation S 0 = autocorrelation T 0 := by
    exact h 0;
  rw [ ← autocorrelation_zero S, ← autocorrelation_zero T, h_autocorrelation_zero ]


end
