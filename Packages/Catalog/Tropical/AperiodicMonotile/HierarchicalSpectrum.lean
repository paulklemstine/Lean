import Mathlib

/-!
# A rigorous abstract core for a hierarchical monotile spectrum

This file does **not** claim to formalize the geometry of the 2023 hat or turtle.
Instead it isolates and proves the algebraic implication needed by any such
formalization: if every tiling locally decodes a hierarchy of residue addresses
at arbitrarily large substitution scales, then the tiling has no nonzero
translation period.  It also gives a simple continuous, injective affine
parameter path with distinguished endpoints, suitable as an abstract parameter
space for a proposed spectrum.
-/

namespace AperiodicMonotile

/-- Translation by `p` is a period of a one-dimensional configuration. -/
def IsPeriod {α : Type*} (c : ℤ → α) (p : ℤ) : Prop :=
  ∀ x, c (x + p) = c x

/-- `coarse` is locally decoded from `fine`. -/
def FactorsThrough {α β : Type*} (fine : ℤ → α) (coarse : ℤ → β) : Prop :=
  ∃ decode : α → β, coarse = decode ∘ fine

/-
Periods descend through a local decoding.
-/
lemma period_of_factorsThrough {α β : Type*} {fine : ℤ → α} {coarse : ℤ → β}
    {p : ℤ} (hfactor : FactorsThrough fine coarse) (hperiod : IsPeriod fine p) :
    IsPeriod coarse p := by
  obtain ⟨ decode, rfl ⟩ := hfactor;
  exact fun x => by rw [ Function.comp_apply, Function.comp_apply, hperiod ] ;

/-- The level-`n` address records position modulo the substitution scale `2^n`. -/
def levelAddress (n : ℕ) (x : ℤ) : ZMod (2 ^ n) := x

/-
A period of a level address is divisible by that level's scale.
-/
lemma pow_two_dvd_of_levelAddress_period {n : ℕ} {p : ℤ}
    (hperiod : IsPeriod (levelAddress n) p) :
    (2 : ℤ) ^ n ∣ p := by
  specialize hperiod 0; simp_all +decide [ levelAddress ] ;
  rw [ ZMod.intCast_zmod_eq_zero_iff_dvd ] at hperiod ; aesop

/-
No nonzero integer is divisible by every power of two.
-/
lemma eq_zero_of_all_pow_two_dvd {p : ℤ} (hdiv : ∀ n : ℕ, (2 : ℤ) ^ n ∣ p) :
    p = 0 := by
  contrapose! hdiv;
  obtain ⟨ n, hn ⟩ := pow_unbounded_of_one_lt ( |p| ) one_lt_two;
  exact ⟨ n, fun h => hn.not_ge <| Int.le_of_dvd ( abs_pos.mpr hdiv ) <| by simpa using h ⟩

/-- The full hierarchy consists of addresses at every substitution level. -/
def addressHierarchy (x : ℤ) (n : ℕ) : ZMod (2 ^ n) := levelAddress n x

/-
The full address hierarchy has only the zero translation period.
-/
theorem addressHierarchy_period_iff (p : ℤ) :
    IsPeriod addressHierarchy p ↔ p = 0 := by
  constructor <;> intro h;
  · apply eq_zero_of_all_pow_two_dvd;
    exact fun n => pow_two_dvd_of_levelAddress_period fun x => congr_fun ( h x ) n;
  · exact fun x => by aesop;

/-- A configuration enforces the hierarchy when every level is locally decodable. -/
def EnforcesHierarchy {α : Type*} (c : ℤ → α) : Prop :=
  ∀ n : ℕ, FactorsThrough c (levelAddress n)

/-
Hierarchy enforcement rules out every nonzero translation period.
-/
theorem aperiodic_of_enforcesHierarchy {α : Type*} {c : ℤ → α}
    (henforces : EnforcesHierarchy c) {p : ℤ} (hperiod : IsPeriod c p) :
    p = 0 := by
  exact eq_zero_of_all_pow_two_dvd fun n => pow_two_dvd_of_levelAddress_period ( period_of_factorsThrough ( henforces n ) hperiod )

/-- An abstract two-coordinate affine interpolation between two endpoint shapes. -/
def spectrumPath (t : ℝ) : ℝ × ℝ := (1 - t, t)

/-
The interpolation has the intended `hat` endpoint.
-/
lemma spectrumPath_zero : spectrumPath 0 = (1, 0) := by
  norm_num [ spectrumPath ]

/-
The interpolation has the intended `turtle` endpoint.
-/
lemma spectrumPath_one : spectrumPath 1 = (0, 1) := by
  norm_num [ spectrumPath ]

/-
Distinct parameters give distinct points on the affine spectrum path.
-/
lemma spectrumPath_injective : Function.Injective spectrumPath := by
  exact fun a b h => by injection h;

/-
The abstract spectrum path is continuous.
-/
theorem continuous_spectrumPath : Continuous spectrumPath := by
  apply_rules [ Continuous.prodMk, continuous_const, continuous_id ];
  fun_prop

/--
A candidate spectrum system supplies configurations at every parameter and a
proof that its substitution rule decodes every binary hierarchy level.
-/
structure SpectrumSystem where
  TileState : Type*
  configuration : ℝ → ℤ → TileState
  enforces : ∀ t ∈ Set.Icc (0 : ℝ) 1, EnforcesHierarchy (configuration t)

/-
A concrete witness that hierarchy enforcement is consistent: each tile state
stores the complete compatible list of level addresses.
-/
def canonicalSpectrumSystem : SpectrumSystem where
  TileState := ∀ n : ℕ, ZMod (2 ^ n)
  configuration := fun _ => addressHierarchy
  enforces := by
    intro t ht n
    use fun x => x n
    ext x
    simp [addressHierarchy]

/-
Every member of a hierarchy-enforcing candidate spectrum is aperiodic.
-/
theorem SpectrumSystem.member_aperiodic (S : SpectrumSystem) {t : ℝ}
    (ht : t ∈ Set.Icc (0 : ℝ) 1) {p : ℤ}
    (hperiod : IsPeriod (S.configuration t) p) : p = 0 := by
  exact aperiodic_of_enforcesHierarchy ( S.enforces t ht ) hperiod

/-
No two members of such a spectrum can share a common nonzero period.  This is
stronger than merely saying that each individual member is aperiodic.
-/
theorem SpectrumSystem.no_common_nonzero_period (S : SpectrumSystem)
    {s t : ℝ} (hs : s ∈ Set.Icc (0 : ℝ) 1) (ht : t ∈ Set.Icc (0 : ℝ) 1)
    {p : ℤ} (hp : p ≠ 0) :
    ¬ (IsPeriod (S.configuration s) p ∧ IsPeriod (S.configuration t) p) := by
  rintro ⟨hperiodS, hperiodT⟩
  have hpS : p = 0 := S.member_aperiodic hs hperiodS
  have hpT : p = 0 := S.member_aperiodic ht hperiodT
  exact hp (hpS.trans (hpT.symm.trans hpT))

end AperiodicMonotile