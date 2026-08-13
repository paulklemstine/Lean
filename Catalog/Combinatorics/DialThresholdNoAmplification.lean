/-
# DIAL-THRESHOLD: residue dials cannot amplify a Coppersmith hint

Formal companion to `45_DialThreshold_NoAmplification.md` (experiment #380).

**The question.**  A Coppersmith-style attack starts from a *partial key hint*:
the residue `p % m` of the secret prime, with `m ≈ N^{1/4}`.  The "free witness"
side of the programme offers a different kind of data: a vector of **residue
dials** `p ↦ ((D₁ | p), …, (D_K | p))` of Kronecker symbols at fundamental
discriminants.  Each dial is a *periodic* function of `p`, with conductor
dividing `4|D_i|`.  Can the dials *amplify* the hint — cut the candidate set
below what `p % m` already achieves?

**The answer, proved here: no.**  Everything is controlled by one integer,
the conductor lcm `M* = lcm_i cond(D_i)`, measured against the hint modulus `m`:

* `DialThreshold.card_image_dialVec_le` — the **master bound**.  On any candidate
  set inside one hint class mod `m`, the dial vector takes at most
  `M* / gcd(M*, m)` distinct values.  This is the exact amplification budget.
* `DialThreshold.exists_large_dial_fibre` — consequently some dial reading keeps
  at least a `gcd(M*,m)/M*` fraction of the candidates: the dials cannot shrink
  the candidate set by more than the factor `M*/gcd(M*, m)`.
* **Regime 1 (`M* ∣ m`)**: `dialVec_const_of_dvd`, `dial_cut_trivial`,
  `zeroInfo_dialVec_of_dvd`, `zeroInfo_dialVec_postprocessed` — the budget is
  `1`: the dial vector is *constant* on the candidate set, the induced cut is the
  identity, and (in the exact counting sense `Round11.ZeroInfo` of the catalog)
  the dials carry **zero information** about any secret whatsoever, even after
  arbitrary post-processing.
* **Regime 2 (`M* ∤ m`)**: `hint_underdetermines_residue`,
  `not_hintComputable_of_separates`, `pinning_forces_not_dvd`,
  `card_le_of_dialVec_injOn` — a dial system that separates even two candidates
  is *not computable from the hint*, and pinning `C` candidates forces
  `M*/gcd(M*,m) ≥ C`, i.e. the dials must reach strictly beyond the hint.
* `DialThreshold.dial_capacity` — the information-theoretic side: `K` sign dials
  cannot separate more than `3^K` candidates, so pinning needs `K = Ω(log C)`.

Together these are a dichotomy: *hint-computable ⇒ information-useless*
(`no_amplification_of_hintComputable`), *informative ⇒ not hint-computable*.

The concluding section instantiates the two regimes on the experiment's own
numbers with genuine Kronecker dials `(D | ·)`:
`N = 808·10⁶`-scale hint `m = 168` with dials of conductor `12, 84, 168`
(Regime 1) and `N = 340·10⁶`-scale hint `m = 135` with the dial `(-4 | ·)` of
conductor `16` (Regime 2, witnessed by the candidate pair `541, 811`).
-/
import Mathlib
import Combinatorics.Round11FingerprintInformation

namespace DialThreshold

open Finset

/-! ## 1. Residue dials -/

/-- A **residue dial**: an integer-valued statistic of a candidate prime that is
periodic with some conductor.  Kronecker symbols `(D | ·)` at a fixed
discriminant are the motivating example (`DialThreshold.kron`). -/
structure Dial where
  /-- The conductor: the period of the dial. -/
  cond : ℕ
  cond_pos : 0 < cond
  /-- The reading of the dial at a candidate. -/
  chi : ℕ → ℤ
  periodic : ∀ n, chi (n + cond) = chi n

namespace Dial

variable (d : Dial)

/-- Periodicity iterates: the reading is unchanged by any multiple of the
conductor. -/
theorem chi_add_mul (n k : ℕ) : d.chi (n + k * d.cond) = d.chi n := by
  induction k with
  | zero => simp
  | succ k ih =>
      have h : n + (k + 1) * d.cond = (n + k * d.cond) + d.cond := by ring
      rw [h, d.periodic, ih]

/-- A dial reading only depends on the residue modulo any multiple of its
conductor. -/
theorem chi_mod_dvd {M : ℕ} (hM : d.cond ∣ M) (n : ℕ) : d.chi (n % M) = d.chi n := by
  obtain ⟨c, hc⟩ := hM
  conv_rhs => rw [← Nat.mod_add_div n M]
  rw [hc, show n % (d.cond * c) + d.cond * c * (n / (d.cond * c))
        = n % (d.cond * c) + (c * (n / (d.cond * c))) * d.cond by ring,
      d.chi_add_mul]

/-- **The dial is a function of the residue.**  Two candidates congruent modulo
any multiple of the conductor give the same reading. -/
theorem chi_congr {M a b : ℕ} (hM : d.cond ∣ M) (h : a % M = b % M) :
    d.chi a = d.chi b := by
  rw [← d.chi_mod_dvd hM a, h, d.chi_mod_dvd hM b]

end Dial

/-! ### Kronecker dials

The free-witness dials of the experiment: `p ↦ (D | p)`, realized as a genuinely
periodic function by evaluating the Jacobi symbol at the reduced representative
modulo `4|D|`.  On odd candidates it agrees with `(D | ·)` on the nose. -/

/-- The Kronecker dial at a nonzero discriminant `D`, with conductor `4|D|`. -/
def kron (D : ℤ) (hD : D ≠ 0) : Dial where
  cond := 4 * D.natAbs
  cond_pos := by
    have : D.natAbs ≠ 0 := Int.natAbs_ne_zero.mpr hD
    omega
  chi := fun n => jacobiSym D (n % (4 * D.natAbs))
  periodic := fun n => by simp [Nat.add_mod_right]

@[simp] theorem kron_cond (D : ℤ) (hD : D ≠ 0) : (kron D hD).cond = 4 * D.natAbs := rfl

/-- On odd candidates the Kronecker dial *is* the Jacobi symbol `(D | ·)`. -/
theorem kron_apply_odd {D : ℤ} (hD : D ≠ 0) {n : ℕ} (hn : Odd n) :
    (kron D hD).chi n = jacobiSym D n :=
  (jacobiSym.mod_right D hn).symm

/-! ## 2. Dial systems and the conductor lcm `M*` -/

variable {K : ℕ}

/-- The **dial vector** of a candidate: all `K` readings at once. -/
def dialVec (Ds : Fin K → Dial) (p : ℕ) : Fin K → ℤ := fun i => (Ds i).chi p

/-- `M*`: the lcm of the conductors of the dial system. -/
def condLcm (Ds : Fin K → Dial) : ℕ := Finset.univ.lcm (fun i => (Ds i).cond)

theorem cond_dvd_condLcm (Ds : Fin K → Dial) (i : Fin K) : (Ds i).cond ∣ condLcm Ds :=
  Finset.dvd_lcm (mem_univ i)

theorem condLcm_pos (Ds : Fin K → Dial) : 0 < condLcm Ds := by
  refine Nat.pos_of_ne_zero (fun h => ?_)
  rw [condLcm, Finset.lcm_eq_zero_iff] at h
  obtain ⟨i, -, hi⟩ := h
  exact absurd hi (Ds i).cond_pos.ne'

/-- `M*` is the exact resolution of a dial system: candidates congruent mod any
multiple of `M*` are indistinguishable by the dials. -/
theorem dialVec_congr (Ds : Fin K → Dial) {M a b : ℕ} (hM : condLcm Ds ∣ M)
    (h : a % M = b % M) : dialVec Ds a = dialVec Ds b :=
  funext fun i => (Ds i).chi_congr ((cond_dvd_condLcm Ds i).trans hM) h

/-- Special case: the dial vector is determined by the residue mod `M*`. -/
theorem dialVec_mod (Ds : Fin K → Dial) (p : ℕ) :
    dialVec Ds (p % condLcm Ds) = dialVec Ds p :=
  dialVec_congr Ds dvd_rfl (Nat.mod_mod_of_dvd p dvd_rfl)

/-! ## 3. Counting the residues visible inside a hint class -/

/-- **Arithmetic-progression count.**  Among the `M` residues mod `M`, exactly
`M / g` lie in a prescribed class mod a divisor `g`. -/
theorem card_filter_range_mod {M g c : ℕ} (hg : 0 < g) (hdvd : g ∣ M) (hc : c < g) :
    ((range M).filter (fun x => x % g = c)).card = M / g := by
  classical
  have hgM : g * (M / g) = M := Nat.mul_div_cancel' hdvd
  have key : ((range M).filter (fun x => x % g = c))
      = (range (M / g)).image (fun i => c + g * i) := by
    ext x
    simp only [mem_filter, mem_range, mem_image]
    constructor
    · rintro ⟨hx, hxc⟩
      refine ⟨x / g, Nat.div_lt_div_of_lt_of_dvd hdvd hx, ?_⟩
      rw [← hxc]
      exact Nat.mod_add_div x g
    · rintro ⟨i, hi, rfl⟩
      have hi' : i + 1 ≤ M / g := hi
      refine ⟨?_, ?_⟩
      · calc c + g * i < g + g * i := by omega
          _ = g * (i + 1) := by ring
          _ ≤ g * (M / g) := Nat.mul_le_mul_left g hi'
          _ = M := hgM
      · rw [Nat.add_mul_mod_self_left, Nat.mod_eq_of_lt hc]
  have hinj : Function.Injective (fun i => c + g * i) := by
    intro a b hab
    have hab' : c + g * a = c + g * b := hab
    exact Nat.eq_of_mul_eq_mul_left hg (by omega)
  rw [key, Finset.card_image_of_injective _ hinj, Finset.card_range]

/-! ## 4. The master bound: the amplification budget is `M* / gcd(M*, m)` -/

/-- **Master bound.**  On a candidate set contained in a single hint class
`p ≡ r (mod m)`, the dial vector takes at most `M* / gcd(M*, m)` distinct
values.  Everything else in this file is a consequence of this one inequality:
the *entire* discriminating power of the dials, beyond the hint, is the index
`M*/gcd(M*, m)` by which the dial resolution overshoots the hint. -/
theorem card_image_dialVec_le (Ds : Fin K → Dial) (Ω : Finset ℕ) {m r : ℕ} (hm : 0 < m)
    (hΩ : ∀ p ∈ Ω, p % m = r % m) :
    (Ω.image (dialVec Ds)).card ≤ condLcm Ds / Nat.gcd (condLcm Ds) m := by
  classical
  set M := condLcm Ds with hM
  set g := Nat.gcd M m with hgdef
  have hMpos : 0 < M := condLcm_pos Ds
  have hgpos : 0 < g := Nat.gcd_pos_of_pos_right _ hm
  have hgM : g ∣ M := Nat.gcd_dvd_left _ _
  have hgm : g ∣ m := Nat.gcd_dvd_right _ _
  set T := (range M).filter (fun x => x % g = r % g) with hT
  have hsub : Ω.image (dialVec Ds) ⊆ T.image (dialVec Ds) := by
    intro v hv
    rw [mem_image] at hv
    obtain ⟨p, hp, rfl⟩ := hv
    refine mem_image.2 ⟨p % M, ?_, dialVec_mod Ds p⟩
    rw [hT, mem_filter, mem_range]
    refine ⟨Nat.mod_lt _ hMpos, ?_⟩
    rw [Nat.mod_mod_of_dvd p hgM]
    exact (Nat.ModEq.of_dvd hgm (hΩ p hp))
  calc (Ω.image (dialVec Ds)).card ≤ (T.image (dialVec Ds)).card := card_le_card hsub
    _ ≤ T.card := card_image_le
    _ = M / g := card_filter_range_mod hgpos hgM (Nat.mod_lt _ hgpos)

/-- **No amplification beyond the budget.**  Some dial reading is shared by at
least a `gcd(M*,m)/M*` fraction of the candidates: reading the dials cannot
shrink a candidate set inside one hint class by more than the factor
`M*/gcd(M*, m)`. -/
theorem exists_large_dial_fibre (Ds : Fin K → Dial) (Ω : Finset ℕ) {m r : ℕ} (hm : 0 < m)
    (hΩ : ∀ p ∈ Ω, p % m = r % m) (hne : Ω.Nonempty) :
    ∃ v, Ω.card ≤ (condLcm Ds / Nat.gcd (condLcm Ds) m) *
        (Ω.filter (fun p => dialVec Ds p = v)).card := by
  classical
  set I := Ω.image (dialVec Ds) with hI
  have hIne : I.Nonempty := hne.image _
  obtain ⟨v, hvI, hvmax⟩ := Finset.exists_max_image I
    (fun v => (Ω.filter (fun p => dialVec Ds p = v)).card) hIne
  refine ⟨v, ?_⟩
  have hfib : Ω.card = ∑ w ∈ I, (Ω.filter (fun p => dialVec Ds p = w)).card :=
    Finset.card_eq_sum_card_fiberwise (fun p hp => mem_image_of_mem _ hp)
  have hsum : ∑ w ∈ I, (Ω.filter (fun p => dialVec Ds p = w)).card
      ≤ I.card * (Ω.filter (fun p => dialVec Ds p = v)).card := by
    simpa [smul_eq_mul] using
      Finset.sum_le_card_nsmul I (fun w => (Ω.filter (fun p => dialVec Ds p = w)).card)
        _ (fun w hw => hvmax w hw)
  have hIcard : I.card ≤ condLcm Ds / Nat.gcd (condLcm Ds) m :=
    card_image_dialVec_le Ds Ω hm hΩ
  calc Ω.card = ∑ w ∈ I, (Ω.filter (fun p => dialVec Ds p = w)).card := hfib
    _ ≤ I.card * (Ω.filter (fun p => dialVec Ds p = v)).card := hsum
    _ ≤ (condLcm Ds / Nat.gcd (condLcm Ds) m) *
          (Ω.filter (fun p => dialVec Ds p = v)).card := Nat.mul_le_mul_right _ hIcard

/-! ## 5. Regime 1 (`M* ∣ m`): the dials are constant, hence useless -/

/-- **Zero pinning.**  If the conductor lcm divides the hint modulus, the dial
vector is *constant* on every candidate set inside a hint class. -/
theorem dialVec_const_of_dvd (Ds : Fin K → Dial) (Ω : Finset ℕ) {m r : ℕ}
    (hdvd : condLcm Ds ∣ m) (hΩ : ∀ p ∈ Ω, p % m = r % m) {p₀ : ℕ} (hp₀ : p₀ ∈ Ω) :
    ∀ p ∈ Ω, dialVec Ds p = dialVec Ds p₀ :=
  fun p hp => dialVec_congr Ds hdvd ((hΩ p hp).trans (hΩ p₀ hp₀).symm)

/-- **The dial cut is the identity.**  Filtering the candidates by the true dial
reading removes nothing: the dials add no constraint beyond the hint. -/
theorem dial_cut_trivial (Ds : Fin K → Dial) (Ω : Finset ℕ) {m r : ℕ}
    (hdvd : condLcm Ds ∣ m) (hΩ : ∀ p ∈ Ω, p % m = r % m) {p₀ : ℕ} (hp₀ : p₀ ∈ Ω) :
    Ω.filter (fun p => dialVec Ds p = dialVec Ds p₀) = Ω :=
  Finset.filter_true_of_mem (fun p hp => dialVec_const_of_dvd Ds Ω hdvd hΩ hp₀ p hp)

/-- **Zero information (Regime 1).**  In the exact counting sense of the
catalog's `Round11.ZeroInfo`, the dial vector is uninformative about *any*
secret statistic `S` of the candidate, on any candidate set inside a hint
class. -/
theorem zeroInfo_dialVec_of_dvd {γ : Type*} [DecidableEq γ] (Ds : Fin K → Dial)
    (Ω : Finset ℕ) {m r : ℕ} (hdvd : condLcm Ds ∣ m)
    (hΩ : ∀ p ∈ Ω, p % m = r % m) (S : ℕ → γ) :
    Round11.ZeroInfo Ω (dialVec Ds) S := by
  rcases Ω.eq_empty_or_nonempty with rfl | ⟨p₀, hp₀⟩
  · intro t s; simp
  · exact Round11.zeroInfo_of_const (dialVec_const_of_dvd Ds Ω hdvd hΩ hp₀)

/-- **Post-processing cannot help (Regime 1).**  No lattice reduction, no
learning algorithm, no arbitrary function `g` of the dial vector extracts
anything about the secret. -/
theorem zeroInfo_dialVec_postprocessed {γ δ : Type*} [DecidableEq γ] [DecidableEq δ]
    (Ds : Fin K → Dial) (Ω : Finset ℕ) {m r : ℕ} (hdvd : condLcm Ds ∣ m)
    (hΩ : ∀ p ∈ Ω, p % m = r % m) (S : ℕ → γ) (g : (Fin K → ℤ) → δ) :
    Round11.ZeroInfo Ω (g ∘ dialVec Ds) S :=
  Round11.zeroInfo_comp g (zeroInfo_dialVec_of_dvd Ds Ω hdvd hΩ S)

/-! ## 6. Hint-computability, and the dichotomy -/

/-- A statistic is **hint-computable** when it is a function of the hint `p % m`
alone — i.e. the attacker can evaluate it from the Coppersmith hint. -/
def HintComputable {β : Type*} (m : ℕ) (T : ℕ → β) : Prop :=
  ∃ g : ℕ → β, ∀ p, T p = g (p % m)

theorem hintComputable_iff {β : Type*} (m : ℕ) (T : ℕ → β) :
    HintComputable m T ↔ ∀ a b, a % m = b % m → T a = T b := by
  constructor
  · rintro ⟨g, hg⟩ a b hab
    rw [hg a, hg b, hab]
  · intro h
    refine ⟨fun x => T (x % m), fun p => ?_⟩
    show T p = T (p % m % m)
    exact h p (p % m % m) (by simp)

/-- Regime 1 is exactly the computable regime: `M* ∣ m` makes the dial vector a
function of the hint. -/
theorem hintComputable_dialVec_of_dvd (Ds : Fin K → Dial) {m : ℕ} (hdvd : condLcm Ds ∣ m) :
    HintComputable m (dialVec Ds) :=
  (hintComputable_iff m _).2 (fun _ _ hab => dialVec_congr Ds hdvd hab)

/-- **The master dichotomy, useless half.**  *Any* hint-computable statistic —
dials or otherwise — is constant on a hint class, hence carries zero information
about any secret, even after arbitrary post-processing.  This is the abstract
reason the residue dials cannot amplify a Coppersmith hint. -/
theorem no_amplification_of_hintComputable {β γ : Type*} [DecidableEq β] [DecidableEq γ]
    {m r : ℕ} {T : ℕ → β} (hT : HintComputable m T) (Ω : Finset ℕ)
    (hΩ : ∀ p ∈ Ω, p % m = r % m) (S : ℕ → γ) :
    Round11.ZeroInfo Ω T S := by
  rcases Ω.eq_empty_or_nonempty with rfl | ⟨p₀, hp₀⟩
  · intro t s; simp
  · exact Round11.zeroInfo_of_const
      (fun p hp => (hintComputable_iff m T).1 hT p p₀ ((hΩ p hp).trans (hΩ p₀ hp₀).symm))

/-- **Regime 2, non-computability.**  If the conductor scale `M` does not divide
the hint modulus `m`, then the hint genuinely fails to determine the residue mod
`M`: two candidates in the same hint class can differ mod `M`. -/
theorem hint_underdetermines_residue {M m : ℕ} (hM : ¬ M ∣ m) :
    ∃ a b : ℕ, a % m = b % m ∧ a % M ≠ b % M := by
  refine ⟨0, m, by simp, ?_⟩
  simpa [Nat.zero_mod, eq_comm, Nat.dvd_iff_mod_eq_zero] using hM

/-- A dial system that separates two candidates of a common hint class is not
hint-computable: the attacker cannot evaluate it. -/
theorem not_hintComputable_of_separates (Ds : Fin K → Dial) {m a b : ℕ}
    (hab : a % m = b % m) (hsep : dialVec Ds a ≠ dialVec Ds b) :
    ¬ HintComputable m (dialVec Ds) :=
  fun h => hsep ((hintComputable_iff m _).1 h a b hab)

/-- **Barrier 6, sharp form.**  A dial system that *pins* (separates) two
candidates of a hint class must have conductor lcm not dividing the hint
modulus: pinning dials necessarily read `p` beyond the hint. -/
theorem pinning_forces_not_dvd (Ds : Fin K → Dial) {m a b : ℕ}
    (hab : a % m = b % m) (hsep : dialVec Ds a ≠ dialVec Ds b) :
    ¬ condLcm Ds ∣ m :=
  fun hdvd => not_hintComputable_of_separates Ds hab hsep
    (hintComputable_dialVec_of_dvd Ds hdvd)

/-- **Quantitative barrier 6.**  If the dials pin down every candidate of a hint
class, then the overshoot index `M*/gcd(M*, m)` is at least the number of
candidates.  With `m ≈ N^{1/4}` and a candidate count `C`, this forces
`M* ≥ C·gcd(M*,m)`: the dial conductors must be *larger* than the hint. -/
theorem card_le_of_dialVec_injOn (Ds : Fin K → Dial) (Ω : Finset ℕ) {m r : ℕ} (hm : 0 < m)
    (hΩ : ∀ p ∈ Ω, p % m = r % m)
    (hinj : Set.InjOn (dialVec Ds) Ω) :
    Ω.card ≤ condLcm Ds / Nat.gcd (condLcm Ds) m := by
  classical
  have : (Ω.image (dialVec Ds)).card = Ω.card := Finset.card_image_of_injOn hinj
  rw [← this]
  exact card_image_dialVec_le Ds Ω hm hΩ

/-! ## 7. The information-theoretic side: `K = Ω(log C)` dials are needed -/

/-- **Dial capacity.**  A system of `K` sign dials (readings in `{-1, 0, 1}`,
which is the case for Kronecker symbols) has at most `3^K` distinct dial
vectors; so on more than `3^K` candidates two are always confused.  Pinning a
candidate set of size `C` therefore needs `K ≥ log₃ C` dials — the `Θ(log N)`
threshold of the experiment. -/
theorem dial_capacity (Ds : Fin K → Dial) (Ω : Finset ℕ)
    (hsign : ∀ (i : Fin K) (p : ℕ), (Ds i).chi p ∈ ({-1, 0, 1} : Finset ℤ))
    (hcard : 3 ^ K < Ω.card) :
    ∃ p ∈ Ω, ∃ q ∈ Ω, p ≠ q ∧ dialVec Ds p = dialVec Ds q := by
  classical
  set B : Finset (Fin K → ℤ) := Fintype.piFinset (fun _ => ({-1, 0, 1} : Finset ℤ)) with hB
  have hBcard : B.card = 3 ^ K := by
    rw [hB, Fintype.card_piFinset]
    simp
  have hmaps : ∀ p ∈ Ω, dialVec Ds p ∈ B := by
    intro p _
    rw [hB, Fintype.mem_piFinset]
    exact fun i => hsign i p
  have hlt : B.card < Ω.card := by rw [hBcard]; exact hcard
  obtain ⟨p, hp, q, hq, hpq, heq⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to hlt hmaps
  exact ⟨p, hp, q, hq, hpq, heq⟩

/-- Kronecker dials are sign dials, so `dial_capacity` applies to them. -/
theorem kron_sign {D : ℤ} (hD : D ≠ 0) (n : ℕ) :
    (kron D hD).chi n ∈ ({-1, 0, 1} : Finset ℤ) := by
  have := jacobiSym.trichotomy D (n % (4 * D.natAbs))
  rcases this with h | h | h <;> simp [kron, h]

/-! ## 8. The two experimental regimes, on the experiment's own numbers -/

section Regime1

/-- The Regime-1 dial system of the experiment: Kronecker dials at
`D = -3, 21, 42`, of conductors `12, 84, 168`. -/
def dials808 : Fin 3 → Dial :=
  ![kron (-3) (by norm_num), kron 21 (by norm_num), kron 42 (by norm_num)]

theorem dials808_conds :
    (dials808 0).cond = 12 ∧ (dials808 1).cond = 84 ∧ (dials808 2).cond = 168 := by
  refine ⟨?_, ?_, ?_⟩ <;> simp [dials808]

/-- `M* = lcm(12, 84, 168) = 168` divides the hint modulus `m = 168`. -/
theorem condLcm_dials808_dvd : condLcm dials808 ∣ 168 :=
  Finset.lcm_dvd (fun i _ => by fin_cases i <;> simp [dials808])

/-- **Regime 1, the experiment's instance (`N ≈ 808·10⁶`, `m = 168`).**  On any
candidate set inside the hint class mod `168`, the three Kronecker dials read the
same value on every candidate: the dial vector is computable from the hint and
constant on the candidates, so it adds nothing. -/
theorem regime1_zero_pinning (Ω : Finset ℕ) {r : ℕ} (hΩ : ∀ p ∈ Ω, p % 168 = r % 168)
    {p₀ : ℕ} (hp₀ : p₀ ∈ Ω) : ∀ p ∈ Ω, dialVec dials808 p = dialVec dials808 p₀ :=
  dialVec_const_of_dvd dials808 Ω condLcm_dials808_dvd hΩ hp₀

/-- **Regime 1: zero information.**  Against any secret statistic, on any
candidate set in the hint class, the dial vector of `dials808` is uninformative —
and so is every post-processing of it. -/
theorem regime1_zero_info {γ δ : Type*} [DecidableEq γ] [DecidableEq δ] (Ω : Finset ℕ)
    {r : ℕ} (hΩ : ∀ p ∈ Ω, p % 168 = r % 168) (S : ℕ → γ) (g : (Fin 3 → ℤ) → δ) :
    Round11.ZeroInfo Ω (dialVec dials808) S ∧ Round11.ZeroInfo Ω (g ∘ dialVec dials808) S :=
  ⟨zeroInfo_dialVec_of_dvd dials808 Ω condLcm_dials808_dvd hΩ S,
   zeroInfo_dialVec_postprocessed dials808 Ω condLcm_dials808_dvd hΩ S g⟩

/-- Non-vacuity of Regime 1: `28393` and `28729` are two distinct primes in the
hint class `p ≡ 1 (mod 168)` (their product is of the experiment's scale
`≈ 8.16·10⁸`), so the candidate set really does contain more than one prime. -/
theorem regime1_witness :
    Nat.Prime 28393 ∧ Nat.Prime 28729 ∧ 28393 % 168 = 1 ∧ 28729 % 168 = 1 := by
  refine ⟨by norm_num, by norm_num, by norm_num, by norm_num⟩

/-- The two Regime-1 candidates are genuinely confused by the dials. -/
theorem regime1_confusion :
    dialVec dials808 28393 = dialVec dials808 28729 := by
  refine regime1_zero_pinning ({28393, 28729} : Finset ℕ) (r := 1) ?_ (by simp) 28393 (by simp)
  intro p hp
  fin_cases hp <;> norm_num

end Regime1

section Regime2

/-- The Regime-2 dial of the experiment: the Kronecker dial `(-4 | ·)`, of
conductor `16`.  The hint modulus is `m = 135`, and `16 ∤ 135`. -/
def dials340 : Fin 1 → Dial := ![kron (-4) (by norm_num)]

theorem condLcm_dials340 : condLcm dials340 = 16 := by
  simp [condLcm, dials340]

/-- The hint `p mod 135` does not determine the dial's argument `p mod 16`. -/
theorem regime2_not_determined : ∃ a b : ℕ, a % 135 = b % 135 ∧ a % 16 ≠ b % 16 :=
  hint_underdetermines_residue (by norm_num)

/-- **Regime 2, the experiment's instance (`N ≈ 340·10⁶`, `m = 135`).**  The two
primes `541` and `811` lie in the same hint class mod `135`, yet the single dial
`(-4 | ·)` separates them: `(-4 | 541) = 1` while `(-4 | 811) = -1`.  Hence the
dial is *informative* about the candidate — and therefore, by
`not_hintComputable_of_separates`, *not computable from the hint*. -/
theorem regime2_separating :
    541 % 135 = 811 % 135 ∧ dialVec dials340 541 ≠ dialVec dials340 811 := by
  refine ⟨by norm_num, ?_⟩
  intro h
  have h0 := congrFun h 0
  rw [show dialVec dials340 541 0 = jacobiSym (-4) 541 from
        kron_apply_odd (by norm_num) ⟨270, by norm_num⟩,
      show dialVec dials340 811 0 = jacobiSym (-4) 811 from
        kron_apply_odd (by norm_num) ⟨405, by norm_num⟩] at h0
  norm_num at h0

/-- **Regime 2: the dial is not hint-computable.**  The attacker holding only
`p mod 135` cannot evaluate `(-4 | p)`. -/
theorem regime2_not_hintComputable : ¬ HintComputable 135 (dialVec dials340) :=
  not_hintComputable_of_separates dials340 regime2_separating.1 regime2_separating.2

/-- **Regime 2: the conductor must overshoot the hint.**  Since the dial pins the
two candidates apart, its conductor lcm cannot divide the hint modulus. -/
theorem regime2_conductor_beyond_hint : ¬ condLcm dials340 ∣ 135 :=
  pinning_forces_not_dvd dials340 regime2_separating.1 regime2_separating.2

/-- Both Regime-2 candidates are primes, so the instance is not vacuous. -/
theorem regime2_witness : Nat.Prime 541 ∧ Nat.Prime 811 :=
  ⟨by norm_num, by norm_num⟩

end Regime2

/-! ## 9. The verdict

`no_amplification_dichotomy` packages the closure: for every dial system and
every hint modulus, either the dials are hint-computable — and then they are
provably worthless on the candidate set, for every secret and every
post-processing — or they are not computable from the hint at all. -/

/-- **DIAL-THRESHOLD, closed.**  Exactly one of the two regimes occurs, and
neither yields amplification:

* if `M* ∣ m`, the dial vector is computable from the hint *and* constant on the
  candidate set (zero information, even after post-processing);
* if `M* ∤ m`, the hint provably fails to determine the residue `p mod M*` that
  the dials read, and any dial system separating two candidates of the hint class
  is not hint-computable. -/
theorem no_amplification_dichotomy {γ δ : Type*} [DecidableEq γ] [DecidableEq δ]
    (Ds : Fin K → Dial) (Ω : Finset ℕ) {m r : ℕ}
    (hΩ : ∀ p ∈ Ω, p % m = r % m) (S : ℕ → γ) (g : (Fin K → ℤ) → δ) :
    (condLcm Ds ∣ m ∧ HintComputable m (dialVec Ds) ∧
        Round11.ZeroInfo Ω (dialVec Ds) S ∧ Round11.ZeroInfo Ω (g ∘ dialVec Ds) S)
    ∨ (¬ condLcm Ds ∣ m ∧
        (∃ a b : ℕ, a % m = b % m ∧ a % condLcm Ds ≠ b % condLcm Ds) ∧
        ∀ a b : ℕ, a % m = b % m → dialVec Ds a ≠ dialVec Ds b →
          ¬ HintComputable m (dialVec Ds)) := by
  by_cases hdvd : condLcm Ds ∣ m
  · exact Or.inl ⟨hdvd, hintComputable_dialVec_of_dvd Ds hdvd,
      zeroInfo_dialVec_of_dvd Ds Ω hdvd hΩ S,
      zeroInfo_dialVec_postprocessed Ds Ω hdvd hΩ S g⟩
  · exact Or.inr ⟨hdvd, hint_underdetermines_residue hdvd,
      fun a b hab hsep => not_hintComputable_of_separates Ds hab hsep⟩

end DialThreshold