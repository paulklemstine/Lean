/-! # CatalogBuild.Logic.PhotonChannels

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 30
-/

import Mathlib

noncomputable section

/-- The seven fundamental information channels of a photon. -/
inductive PhotonChannel where
  | frequency       -- Channel 1: Energy/frequency ω
  | polarization    -- Channel 2: Spin angular momentum / helicity σ
  | direction       -- Channel 3: Propagation direction k̂ (two angles on S²)
  | orbitalAM       -- Channel 4: Orbital angular momentum ℓ ∈ ℤ
  | radialMode      -- Channel 5: Radial mode index p ∈ ℕ
  | temporalMode    -- Channel 6: Temporal wave packet shape
  | photonNumber    -- Channel 7: Fock state occupation number n ∈ ℕ
  deriving DecidableEq, Fintype, Repr


/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonChannels
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 30] -/
theorem PhotonChannel.card : Fintype.card PhotonChannel = 7 := by
  bound


/-- Classification of Hilbert space dimension type for each channel. -/
inductive HilbertDimType where
  | finite (d : ℕ)      -- Finite-dimensional (d-dimensional)
  | countablyInfinite    -- Countably infinite (ℓ²)
  | continuous           -- Continuous / uncountably infinite (L²)
  deriving DecidableEq, Repr


/-- The Hilbert space dimension type of each photon channel.
- Polarization: exactly 2-dimensional (helicity ±1)
- OAM: countably infinite (ℓ ∈ ℤ)
- Radial mode: countably infinite (p ∈ ℕ)
- Photon number: countably infinite (n ∈ ℕ)
- Frequency: continuous (ω ∈ ℝ⁺)
- Direction: continuous (S²)
- Temporal mode: continuous (L²(ℝ)) -/
def hilbertDimType : PhotonChannel → HilbertDimType
  | .polarization => .finite 2
  | .orbitalAM => .countablyInfinite
  | .radialMode => .countablyInfinite
  | .photonNumber => .countablyInfinite
  | .frequency => .continuous
  | .direction => .continuous
  | .temporalMode => .continuous


/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonChannels
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 30] -/
theorem polarization_unique_finite :
    ∀ c : PhotonChannel, (∃ d, hilbertDimType c = .finite d) ↔ c = .polarization := by
  intro c; unfold hilbertDimType; aesop;


/-- The conjugate pair structure: channels linked by uncertainty relations. -/
inductive ConjugatePair where
  | freqTime    -- Frequency ↔ Temporal mode (ΔE·Δt ≥ ℏ/2)
  | dirPos      -- Direction ↔ Transverse position (Δp·Δx ≥ ℏ/2)
  | oamAngle    -- OAM ↔ Angular position (Δℓ·Δφ ≥ 1/2)
  | numPhase    -- Photon number ↔ Phase (Δn·Δφ ≥ 1/2)
  deriving DecidableEq, Fintype, Repr


/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonChannels
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 30] -/
theorem ConjugatePair.card : Fintype.card ConjugatePair = 4 := by
  decide +kernel


/-- Each conjugate pair involves a specific channel from our enumeration. -/
def ConjugatePair.primaryChannel : ConjugatePair → PhotonChannel
  | .freqTime => .frequency
  | .dirPos => .direction
  | .oamAngle => .orbitalAM
  | .numPhase => .photonNumber


/-- The secondary channel in each conjugate pair. -/
def ConjugatePair.secondaryChannel : ConjugatePair → PhotonChannel
  | .freqTime => .temporalMode
  | .dirPos => .direction      -- direction and position are conjugate
  | .oamAngle => .orbitalAM   -- OAM and angular position are conjugate
  | .numPhase => .photonNumber -- number and phase are conjugate


/-- Information capacity (in bits) of each channel under realistic visible-light parameters.
Assumptions: visible light (λ ≈ 500nm), 1-meter aperture, 1-second integration time,
bandwidth Δω ≈ 10⁶ resolvable frequency bins, OAM up to |ℓ| ≤ 50,
radial modes up to p ≤ 20, photon number up to n ≤ 5. -/
noncomputable def channelInfoCapacity : PhotonChannel → ℝ
  | .frequency => 20       -- log₂(10⁶) ≈ 20
  | .polarization => 1     -- exactly 1 qubit
  | .direction => 43       -- log₂(4π·(1m)²/(500nm)²) ≈ 43
  | .orbitalAM => 7        -- log₂(101) ≈ 7 (ℓ from -50 to +50)
  | .radialMode => 5       -- log₂(21) ≈ 5 (p from 0 to 20)
  | .temporalMode => 20    -- log₂(10⁶) time bins ≈ 20
  | .photonNumber => 3     -- log₂(6) ≈ 3 (n from 0 to 5)


/-- The total information capacity of a single photon across all seven channels. -/
noncomputable def totalInfoCapacity : ℝ :=
  (Finset.univ : Finset PhotonChannel).sum channelInfoCapacity


theorem totalInfoCapacity_eq : totalInfoCapacity = 99 := by
  unfold totalInfoCapacity channelInfoCapacity;
  rw [ show ( Finset.univ : Finset PhotonChannel ) = { PhotonChannel.frequency, PhotonChannel.polarization, PhotonChannel.direction, PhotonChannel.orbitalAM, PhotonChannel.radialMode, PhotonChannel.temporalMode, PhotonChannel.photonNumber } by rfl, Finset.sum_insert, Finset.sum_insert, Finset.sum_insert, Finset.sum_insert, Finset.sum_insert, Finset.sum_insert ] <;> simp +decide ; linarith


/-- Classification: which channels have a classical wave analogue? -/
def hasClassicalAnalogue : PhotonChannel → Bool
  | .frequency => true
  | .polarization => true
  | .direction => true
  | .orbitalAM => true
  | .radialMode => true
  | .temporalMode => true
  | .photonNumber => false


theorem photonNumber_unique_nonclassical :
    ∀ c : PhotonChannel, hasClassicalAnalogue c = false ↔ c = .photonNumber := by
  decide +kernel


/-- A photon channel is "bounded" if its practical Hilbert space dimension is finite. -/
def isBounded : PhotonChannel → Bool
  | .polarization => true   -- exactly 2-dimensional
  | _ => false


theorem polarization_unique_bounded :
    ∀ c : PhotonChannel, isBounded c = true ↔ c = .polarization := by
  intro c
  unfold isBounded
  aesop


/-- The symmetry origin of each channel, classified by the relevant subgroup. -/
inductive SymmetryOrigin where
  | timeTranslation       -- Noether: time translation → energy/frequency
  | spatialRotation       -- SO(3) rotation → angular momentum
  | axialRotation         -- SO(2) about propagation axis → helicity
  | transverseTranslation -- Transverse spatial → direction/position
  | scaleSymmetry         -- SU(1,1) → radial modes
  | temporalStructure     -- Time translation + pulse shaping
  | gaugeSymmetry         -- U(1) gauge → photon number conservation
  deriving DecidableEq, Repr


/-- Map from channels to their symmetry origins. -/
def symmetryOrigin : PhotonChannel → SymmetryOrigin
  | .frequency => .timeTranslation
  | .polarization => .axialRotation
  | .direction => .transverseTranslation
  | .orbitalAM => .spatialRotation
  | .radialMode => .scaleSymmetry
  | .temporalMode => .temporalStructure
  | .photonNumber => .gaugeSymmetry


/-- ## The Uncertainty Product Structure
For each conjugate pair, the product of uncertainties is bounded below.
We express this as: for conjugate observables A, B: ΔA · ΔB ≥ C
where C is the uncertainty bound. -/
noncomputable def uncertaintyBound : ConjugatePair → ℝ
  | .freqTime => 1/2    -- ΔE·Δt ≥ ℏ/2 (in natural units)
  | .dirPos => 1/2      -- Δp·Δx ≥ ℏ/2
  | .oamAngle => 1/2    -- Δℓ·Δφ ≥ 1/2
  | .numPhase => 1/2


theorem uncertaintyBound_pos : ∀ p : ConjugatePair, uncertaintyBound p > 0 := by
  exact fun p => by cases p <;> unfold uncertaintyBound <;> norm_num;


/-- ## Hyper-entanglement dimension
When two photons are entangled across multiple channels simultaneously,
the effective Hilbert space dimension grows multiplicatively.
Given practical dimensions for each channel, the hyper-entangled space
dimension is the product. -/
def practicalDim : PhotonChannel → ℕ
  | .frequency => 1000000   -- 10⁶ frequency bins
  | .polarization => 2       -- exactly 2
  | .direction => 10000000000000  -- ~10¹³ directions
  | .orbitalAM => 101        -- ℓ from -50 to +50
  | .radialMode => 21        -- p from 0 to 20
  | .temporalMode => 1000000 -- 10⁶ time bins
  | .photonNumber => 6


theorem practicalDim_pos : ∀ c : PhotonChannel, practicalDim c > 0 := by
  exact fun c => by cases c <;> decide;


/-- Hyper-entanglement dimension: the product of all channel dimensions. -/
def hyperEntanglementDim : ℕ :=
  (Finset.univ : Finset PhotonChannel).prod practicalDim


theorem hyperEntanglementDim_pos : hyperEntanglementDim > 0 := by
  decide +revert


theorem massless_polarization_states (s : ℕ) (hs : s ≥ 1) :
    (2 : ℕ) ≤ 2 * s + 1 := by
  grind


/-- ## Channel 7 and the Vacuum
The vacuum state is characterized by Channel 7 = 0 for all modes.
The zero-point energy per mode is ℏω/2.
Total zero-point energy (summed over all modes) diverges — this
is the cosmological constant problem.
We formalize a simple version: the zero-point energy of a single
mode at frequency ω (in natural units where ℏ = 1). -/
noncomputable def zeroPointEnergy (ω : ℝ) : ℝ := ω / 2


theorem zeroPointEnergy_pos {ω : ℝ} (hω : ω > 0) : zeroPointEnergy ω > 0 := by
  exact div_pos hω zero_lt_two


theorem zeroPointEnergy_mono {ω₁ ω₂ : ℝ} (h : ω₁ < ω₂) :
    zeroPointEnergy ω₁ < zeroPointEnergy ω₂ := by
  unfold zeroPointEnergy; linarith;


theorem shannonCapacity_mono {d₁ d₂ : ℕ} (h : d₁ ≤ d₂) :
    shannonCapacity d₁ ≤ shannonCapacity d₂ := by
  by_cases h₁ : d₁ = 0 <;> by_cases h₂ : d₂ = 0 <;> simp_all +decide [ shannonCapacity ];
  · exact Real.logb_nonneg ( by norm_num ) ( mod_cast Nat.one_le_iff_ne_zero.mpr h₂ );
  · gcongr ; norm_cast


theorem shannonCapacity_polarization : shannonCapacity 2 = 1 := by
  unfold shannonCapacity; norm_num;


end
