/-
# DIAL-THRESHOLD, cycle III: the conductor threshold

Cycles I–II showed that a residue-dial system with conductor lcm `M*` adds, on
top of a Coppersmith hint `p mod m`, at most a factor `M*/gcd(M*, m)` of
discrimination, and that this budget is exactly attained.  Cycle III turns the
budget into the *threshold* the experiment is named for.

The joint attacker statistic is the pair `(p mod m, dial readings)`.  Its total
resolution is capped by a single integer:

  `L = lcm(m, M*)`,

and *nothing* — no choice of discriminants, no post-processing, no number of
dials — can push past it (`joint_resolution_cap`).  Consequently:

* `DialThreshold.pinning_window_le_lcm` — if the joint statistic determines the
  candidate uniquely in a window `[0, X)`, then `X ≤ lcm(m, M*) ≤ m · M*`.
* `DialThreshold.condLcm_ge_of_pinning` — hence `M* ≥ X / m`: to pin a prime in a
  window of size `X` the dials must carry `X/m` further residue information.
* `DialThreshold.coppersmith_threshold` — in the Coppersmith regime the window is
  the square of the hint (`X = m²`, i.e. `p < N^{1/2}` against `m ≈ N^{1/4}`), so
  pinning forces `M* ≥ m`: the dial conductor lcm must itself be of hint size.
  The "free" dials would have to be as expensive as a second Coppersmith hint —
  which is the precise sense in which the hint must be *external*.
* `DialThreshold.dial_count_threshold` — the same instance also forces
  `K ≥ log₃(X/m)` sign dials.

Everything is proved from the finitary lemmas of
`Combinatorics.DialThresholdNoAmplification`; nothing here is asymptotic.
-/
import Mathlib
import Combinatorics.DialThresholdSharpness

namespace DialThreshold

open Finset

variable {K : ℕ}

/-! ## 1. The joint resolution cap -/

/-- **Joint resolution cap.**  Two candidates congruent modulo `lcm(m, M*)` are
indistinguishable by the *pair* (Coppersmith hint, dial vector).  The attacker's
total residue resolution is therefore `lcm(m, M*)`, whatever the dials are. -/
theorem joint_resolution_cap (Ds : Fin K → Dial) {m a b : ℕ}
    (h : a % Nat.lcm m (condLcm Ds) = b % Nat.lcm m (condLcm Ds)) :
    a % m = b % m ∧ dialVec Ds a = dialVec Ds b := by
  constructor
  · have hm : m ∣ Nat.lcm m (condLcm Ds) := Nat.dvd_lcm_left _ _
    exact Nat.ModEq.of_dvd hm h
  · exact dialVec_congr Ds (Nat.dvd_lcm_right m (condLcm Ds)) h

/-- **The threshold.**  If the joint statistic `(p mod m, dial vector)` pins down
the candidate inside the window `[0, X)`, then the window cannot exceed the joint
resolution: `X ≤ lcm(m, M*)`. -/
theorem pinning_window_le_lcm (Ds : Fin K → Dial) {m X : ℕ} (hm : 0 < m)
    (hpin : ∀ a b : ℕ, a < X → b < X → a % m = b % m → dialVec Ds a = dialVec Ds b → a = b) :
    X ≤ Nat.lcm m (condLcm Ds) := by
  by_contra hlt
  push_neg at hlt
  set L := Nat.lcm m (condLcm Ds) with hL
  have hLpos : 0 < L := Nat.lcm_pos hm (condLcm_pos Ds)
  have hcong : (0 : ℕ) % L = L % L := by simp
  obtain ⟨h1, h2⟩ := joint_resolution_cap Ds (m := m) hcong
  have := hpin 0 L (lt_trans hLpos hlt) hlt h1 h2
  omega

/-- **The dials must supply the missing residue information.**  Pinning a
candidate in a window of size `X` from the hint `p mod m` plus the dials forces
`X ≤ m · M*`, i.e. the dial conductor lcm is at least `X/m`. -/
theorem condLcm_ge_of_pinning (Ds : Fin K → Dial) {m X : ℕ} (hm : 0 < m)
    (hpin : ∀ a b : ℕ, a < X → b < X → a % m = b % m → dialVec Ds a = dialVec Ds b → a = b) :
    X ≤ m * condLcm Ds :=
  (pinning_window_le_lcm Ds hm hpin).trans
    (Nat.le_of_dvd (Nat.mul_pos hm (condLcm_pos Ds)) (Nat.lcm_dvd_mul m (condLcm Ds)))

/-- **The Coppersmith threshold.**  In the regime of the experiment the search
window is the square of the hint modulus (`p < N^{1/2}`, `m ≈ N^{1/4}`).  Pinning
then forces `M* ≥ m`: the conductor lcm of the dial family must be at least as
large as the Coppersmith hint modulus itself.  Small, "free" dials — the ones
computable from the hint — are exactly those with `M* ∣ m`, and they are
information-free by `zeroInfo_dialVec_of_dvd`.  Hence there is no gain: the
hint must be genuinely external. -/
theorem coppersmith_threshold (Ds : Fin K → Dial) {m : ℕ} (hm : 0 < m)
    (hpin : ∀ a b : ℕ, a < m * m → b < m * m → a % m = b % m →
      dialVec Ds a = dialVec Ds b → a = b) :
    m ≤ condLcm Ds := by
  have h := condLcm_ge_of_pinning Ds (X := m * m) hm hpin
  exact Nat.le_of_mul_le_mul_left h hm

/-- **The two thresholds together.**  On the window `[0, m·C)` split into hint
classes of `C` candidates each, a system of `K` sign dials that pins every
candidate needs `C ≤ 3^K` dials' worth of capacity *and* `M* ≥ C`. -/
theorem dial_count_threshold (Ds : Fin K → Dial) {m C : ℕ} (hm : 0 < m)
    (hsign : ∀ (i : Fin K) (p : ℕ), (Ds i).chi p ∈ ({-1, 0, 1} : Finset ℤ))
    (hpin : ∀ a b : ℕ, a < m * C → b < m * C → a % m = b % m →
      dialVec Ds a = dialVec Ds b → a = b) :
    C ≤ 3 ^ K ∧ C ≤ condLcm Ds := by
  classical
  set Ω := (range (m * C)).filter (fun x => x % m = 0) with hΩ
  have hcard : Ω.card = C := by
    rw [hΩ, card_filter_range_mod hm ⟨C, rfl⟩ hm, Nat.mul_div_cancel_left _ hm]
  have hinj : Set.InjOn (dialVec Ds) Ω := by
    intro x hx y hy hxy
    simp only [hΩ, coe_filter, Set.mem_setOf_eq, mem_range] at hx hy
    exact hpin x y hx.1 hy.1 (hx.2.trans hy.2.symm) hxy
  constructor
  · by_contra hlt
    push_neg at hlt
    obtain ⟨p, hp, q, hq, hpq, heq⟩ := dial_capacity Ds Ω hsign (by omega)
    exact hpq (hinj hp hq heq)
  · have hmem : ∀ p ∈ Ω, p % m = 0 % m := fun p hp => by
      simpa using (mem_filter.1 hp).2
    have hbound : Ω.card ≤ condLcm Ds / Nat.gcd (condLcm Ds) m :=
      card_le_of_dialVec_injOn Ds Ω hm hmem hinj
    calc C = Ω.card := hcard.symm
      _ ≤ condLcm Ds / Nat.gcd (condLcm Ds) m := hbound
      _ ≤ condLcm Ds := Nat.div_le_self _ _

/-- **The threshold is tight, and the hypotheses are not vacuous.**  When the
dial conductor `C` is coprime to the hint modulus `m`, the single resolution
dial of conductor `C` does pin every candidate of the window `[0, m·C)`.  So
`pinning_window_le_lcm` is an equality there, and `coppersmith_threshold` is a
real obstruction rather than an empty implication: pinning is possible exactly
once the dials reach the missing scale. -/
theorem threshold_attained {m C : ℕ} (hC : 0 < C) (hco : Nat.Coprime m C) :
    ∀ a b : ℕ, a < m * C → b < m * C → a % m = b % m →
      dialVec ![resDial C hC] a = dialVec ![resDial C hC] b → a = b := by
  intro a b ha hb hm' hd
  have h1 : a ≡ b [MOD m] := hm'
  have h2 : a ≡ b [MOD C] := resDial_inj_mod hC hd
  have h3 : a ≡ b [MOD m * C] := (Nat.modEq_and_modEq_iff_modEq_mul hco).1 ⟨h1, h2⟩
  have h4 : a % (m * C) = b % (m * C) := h3
  rwa [Nat.mod_eq_of_lt ha, Nat.mod_eq_of_lt hb] at h4

/-- **Nothing is cut in Regime 1, quantitatively.**  If `M* ∣ m`, then on the
window `[0, m·C)` the hint class still contains `C` candidates *after* the dial
reading is taken into account: the dial cut removes not a single one.  With
`m ≈ N^{1/4}` and the window `≈ N^{1/2}`, the `≈ N^{1/4}` candidates all
survive. -/
theorem regime1_all_candidates_survive (Ds : Fin K → Dial) {m C : ℕ} (hm : 0 < m) (hC : 0 < C)
    (hdvd : condLcm Ds ∣ m) :
    ∃ v, ((range (m * C)).filter (fun x => x % m = 0)).filter (fun p => dialVec Ds p = v)
        = (range (m * C)).filter (fun x => x % m = 0) ∧
      (((range (m * C)).filter (fun x => x % m = 0)).filter
        (fun p => dialVec Ds p = v)).card = C := by
  classical
  set Ω := (range (m * C)).filter (fun x => x % m = 0) with hΩ
  have hmem : ∀ p ∈ Ω, p % m = 0 % m := fun p hp => by simpa using (mem_filter.1 hp).2
  have h0 : (0 : ℕ) ∈ Ω := by
    rw [hΩ, mem_filter, mem_range]
    exact ⟨Nat.mul_pos hm hC, by simp⟩
  have hcut : Ω.filter (fun p => dialVec Ds p = dialVec Ds 0) = Ω :=
    dial_cut_trivial Ds Ω hdvd hmem h0
  have hcard : Ω.card = C := by
    rw [hΩ, card_filter_range_mod hm ⟨C, rfl⟩ hm, Nat.mul_div_cancel_left _ hm]
  exact ⟨dialVec Ds 0, hcut, by rw [hcut, hcard]⟩

/-! ## 2. Self-generated data can never amplify -/

/-- **No self-amplification.**  Any statistic the attacker can *compute* — a
function `g` of the public modulus `N` and the hint `p mod m`, which includes
every "free witness" dial vector with `M* ∣ m` — is constant on the candidate
set, hence carries zero information about any secret, and remains so after any
further post-processing.  This is the formal content of the experiment's verdict:
a partial-key hint cannot be amplified by data derived from itself. -/
theorem self_generated_no_amplification {β γ : Type*} [DecidableEq β] [DecidableEq γ]
    {m r N : ℕ} (g : ℕ → ℕ → β) (Ω : Finset ℕ) (hΩ : ∀ p ∈ Ω, p % m = r % m) (S : ℕ → γ) :
    Round11.ZeroInfo Ω (fun p => g N (p % m)) S :=
  no_amplification_of_hintComputable (m := m) (r := r)
    ⟨fun x => g N (x % m), fun p => by simp⟩ Ω hΩ S

end DialThreshold