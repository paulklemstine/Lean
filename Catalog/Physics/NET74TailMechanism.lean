/-
# NET-74, structural side: the knee is a functional of the *tail*, and the
# head mass carries no information about it

NET-74 reports a *positive* association between the top-8 attention mass of a
domain and its knee `k*`, and reads that sign as a mechanism: "the knee is set
by the residual spread after the top keys are captured, not by how concentrated
the peak is".  `Physics/NET74SpearmanAudit.lean` shows the reported sign is not
what the tabulated numbers give.  This file shows that the *mechanism* claim,
unlike the correlation, can be proved outright — and that it makes the sign of
any head-mass/knee correlation uninformative in principle.

Everything is stated for the `AttentionProfile` of
`Applications/NET73KneeDecoupling.lean`: a capture curve `cum k` = attention
mass carried by the `k` heaviest keys, with knee `kneeAt τ = least k with
τ ≤ cum k`.

Main results.

* `kneeAt_eq_head_add_tailKnee` — **exact tail reduction.**  If the `r`
  heaviest keys do not already meet the tolerance, then
  `kneeAt τ = r + tailKnee r τ`: the knee splits as a fixed head budget plus a
  knee computed entirely inside the residual curve.
* `knee_depends_only_on_tail` — **the knee is a functional of the tail.**  Two
  domains whose capture curves agree from index `r` on have equal knees,
  whatever their heads do.
* `stagedProfile_cum_head` / `stagedProfile_kneeAt` — a two-phase family of
  domains realising *any* head mass `c ∈ (0, τ)` at index `r` together with
  *any* knee `k > r`.
* `head_mass_knee_decoupled`, `no_head_mass_functional_law` — consequently the
  top-8 mass determines nothing about the knee: no function whatsoever sends
  head mass to the knee.
* `head_mass_sign_uninformative` — both signs are realisable: there are pairs of
  domains where more top-8 mass goes with a larger knee and pairs where it goes
  with a smaller one.  A positive measured Spearman coefficient is therefore not
  evidence for the residual-spread mechanism; it is compatible with it, and so
  is a negative one.
* `tail_shape_dominates_head_mass` — for every `N` there are two domains with
  *identical* capture curves through key 8 whose knees differ by at least `N`.
* `kneeAt_le_of_geometric_tail`, `exists_geometric_tail_knee_bound` and
  `heavy_tail_knee_lower_bound` — the quantitative half: a geometric residual
  `R ρ^j` bounds the knee by the first `j` with `R ρ^j ≤ 1 - τ`, while a
  Pareto-type residual `R/(j+1)` forces `k* ≥ r + R/(1-τ) - 1`, which diverges
  as `τ → 1`.  This is the tail-shape analysis NET-74 lists as its next step,
  in the form of a theorem.
-/
import Mathlib
import Applications.NET73KneeDecoupling

namespace Catalog.NET74Tail

open Catalog.NET73 Catalog.NET73.AttentionProfile

/-! ## 1. The exact tail reduction -/

/-- The residual attention mass left outside the `r` heaviest keys. -/
def residual (P : AttentionProfile) (r : ℕ) : ℚ := 1 - P.cum r

/-- The knee *of the tail*: the least number of extra keys, beyond a head
budget of `r`, needed to reach the tolerance. -/
noncomputable def tailKnee (P : AttentionProfile) (r : ℕ) (τ : ℚ) : ℕ :=
  sInf {j | τ ≤ P.cum (r + j)}

variable (P Q : AttentionProfile)

lemma tailKnee_set_nonempty {τ : ℚ} (r : ℕ) (hτ : τ < 1) :
    {j | τ ≤ P.cum (r + j)}.Nonempty := by
  obtain ⟨k, hk⟩ := P.approaches_one τ hτ
  exact ⟨k, le_trans hk (P.cum_mono (Nat.le_add_left k r))⟩

lemma tailKnee_spec {τ : ℚ} {r : ℕ} (hτ : τ < 1) : τ ≤ P.cum (r + tailKnee P r τ) :=
  Nat.sInf_mem (tailKnee_set_nonempty P r hτ)

/-- **Exact tail reduction.**  If the `r` heaviest keys fall short of the
tolerance, the knee is the head budget plus the knee of the residual curve. -/
theorem kneeAt_eq_head_add_tailKnee {τ : ℚ} {r : ℕ} (hτ : τ < 1) (hr : P.cum r < τ) :
    P.kneeAt τ = r + tailKnee P r τ := by
  have hknee : τ ≤ P.cum (P.kneeAt τ) := P.kneeAt_spec hτ
  have hle : r ≤ P.kneeAt τ := by
    by_contra hlt
    push_neg at hlt
    exact absurd (le_trans hknee (P.cum_mono hlt.le)) (not_le.mpr hr)
  refine le_antisymm ?_ ?_
  · exact P.kneeAt_le (tailKnee_spec P hτ)
  · have hmem : P.kneeAt τ - r ∈ {j | τ ≤ P.cum (r + j)} := by
      simp only [Set.mem_setOf_eq, Nat.add_sub_cancel' hle]
      exact hknee
    have := Nat.sInf_le hmem
    have : tailKnee P r τ ≤ P.kneeAt τ - r := this
    omega

/-- **The knee is a functional of the tail alone.**  Two domains whose capture
curves agree from the head budget `r` onwards have the same knee, however
different their heads are. -/
theorem knee_depends_only_on_tail {τ : ℚ} {r : ℕ} (hτ : τ < 1)
    (hP : P.cum r < τ) (hQ : Q.cum r < τ) (h : ∀ j, P.cum (r + j) = Q.cum (r + j)) :
    P.kneeAt τ = Q.kneeAt τ := by
  have hset : {j | τ ≤ P.cum (r + j)} = {j | τ ≤ Q.cum (r + j)} := by
    ext j; simp [h j]
  rw [kneeAt_eq_head_add_tailKnee P hτ hP, kneeAt_eq_head_add_tailKnee Q hτ hQ,
    tailKnee, tailKnee, hset]

/-! ## 2. Two-phase domains: any head mass with any knee -/

/-- A **staged domain**: the `r` heaviest keys carry a total mass `c` (all of it
on the first key), the next `k - r` keys share the remaining `τ - c` evenly, and
the capture curve keeps rising afterwards.  Its top-`r` mass is exactly `c` and
its knee at tolerance `τ` is exactly `k`; the two are free parameters. -/
noncomputable def stagedProfile (d c τ : ℚ) (r k : ℕ)
    (hc : 0 < c) (hcτ : c < τ) (hr : 0 < r) (hrk : r < k) :
    AttentionProfile where
  tpw := d
  cum := fun j => if j = 0 then 0
    else min 1 (c + ((j - r : ℕ) : ℚ) * ((τ - c) / ((k : ℚ) - (r : ℚ))))
  cum_zero := by simp
  cum_le_one := by
    intro j
    by_cases h : j = 0 <;> simp [h]
  cum_mono := by
    have hkr : (0 : ℚ) < (k : ℚ) - (r : ℚ) := by
      have : (r : ℚ) < (k : ℚ) := by exact_mod_cast hrk
      linarith
    have hs : (0 : ℚ) ≤ (τ - c) / ((k : ℚ) - (r : ℚ)) :=
      div_nonneg (by linarith) hkr.le
    intro a b hab
    dsimp only
    by_cases ha : a = 0
    · subst ha
      rw [if_pos rfl]
      by_cases hb : b = 0
      · simp [hb]
      · rw [if_neg hb]
        refine le_min (by norm_num) ?_
        have : (0:ℚ) ≤ ((b - r : ℕ) : ℚ) * ((τ - c) / ((k : ℚ) - (r : ℚ))) :=
          mul_nonneg (Nat.cast_nonneg _) hs
        linarith
    · have hb : b ≠ 0 := by omega
      rw [if_neg ha, if_neg hb]
      have hsub : ((a - r : ℕ) : ℚ) ≤ ((b - r : ℕ) : ℚ) := by
        exact_mod_cast Nat.sub_le_sub_right hab r
      have hmul := mul_le_mul_of_nonneg_right hsub hs
      exact min_le_min le_rfl (by linarith)
  approaches_one := by
    have hkr : (0 : ℚ) < (k : ℚ) - (r : ℚ) := by
      have : (r : ℚ) < (k : ℚ) := by exact_mod_cast hrk
      linarith
    have hs : 0 < (τ - c) / ((k : ℚ) - (r : ℚ)) := div_pos (by linarith) hkr
    intro σ hσ
    set s := (τ - c) / ((k : ℚ) - (r : ℚ)) with hsdef
    refine ⟨r + ⌈s⁻¹⌉₊, ?_⟩
    have hne : r + ⌈s⁻¹⌉₊ ≠ 0 := by omega
    have hcast : ((r + ⌈s⁻¹⌉₊ - r : ℕ) : ℚ) = (⌈s⁻¹⌉₊ : ℚ) := by simp
    have hbig : (1 : ℚ) ≤ (⌈s⁻¹⌉₊ : ℚ) * s := by
      have h1 : s⁻¹ ≤ (⌈s⁻¹⌉₊ : ℚ) := Nat.le_ceil _
      have h2 := mul_le_mul_of_nonneg_right h1 hs.le
      rwa [inv_mul_cancel₀ (ne_of_gt hs)] at h2
    simp only [hne, if_false, hcast]
    have hge : (1 : ℚ) ≤ c + (⌈s⁻¹⌉₊ : ℚ) * s := by linarith
    rw [min_eq_left hge]
    exact hσ.le

/-- Positivity of the tail length, in ℚ. -/
private lemma kr_pos {r k : ℕ} (hrk : r < k) : (0 : ℚ) < (k : ℚ) - (r : ℚ) := by
  have : (r : ℚ) < (k : ℚ) := by exact_mod_cast hrk
  linarith

/-- Positivity of the per-key mass in the tail phase. -/
private lemma step_pos {c τ : ℚ} {r k : ℕ} (hcτ : c < τ) (hrk : r < k) :
    0 < (τ - c) / ((k : ℚ) - (r : ℚ)) :=
  div_pos (by linarith) (kr_pos hrk)

namespace Staged

variable {d c τ : ℚ} {r k : ℕ} (hc : 0 < c) (hcτ : c < τ) (hτ : τ < 1) (hr : 0 < r)
  (hrk : r < k)
include hc hcτ hτ hr hrk

/-- Through the head budget, the staged domain sits at mass exactly `c`. -/
lemma cum_head {j : ℕ} (hj1 : 1 ≤ j) (hj2 : j ≤ r) :
    (stagedProfile d c τ r k hc hcτ hr hrk).cum j = c := by
  have hne : j ≠ 0 := by omega
  have hsub : j - r = 0 := by omega
  show (if j = 0 then 0
    else min 1 (c + ((j - r : ℕ) : ℚ) * ((τ - c) / ((k : ℚ) - (r : ℚ))))) = c
  rw [if_neg hne, hsub]
  simp only [Nat.cast_zero, zero_mul, add_zero]
  exact min_eq_right (by linarith)

/-- Inside the tail phase the capture curve rises linearly. -/
lemma cum_tail {j : ℕ} (hj1 : r ≤ j) (hj2 : j ≤ k) :
    (stagedProfile d c τ r k hc hcτ hr hrk).cum j
      = c + ((j - r : ℕ) : ℚ) * ((τ - c) / ((k : ℚ) - (r : ℚ))) := by
  have hkr := kr_pos hrk
  have hne : j ≠ 0 := by omega
  have hjr : ((j - r : ℕ) : ℚ) ≤ (k : ℚ) - (r : ℚ) := by
    have : ((j - r : ℕ) : ℚ) ≤ ((k - r : ℕ) : ℚ) := by
      exact_mod_cast Nat.sub_le_sub_right hj2 r
    rwa [Nat.cast_sub (le_trans hj1 hj2)] at this
  have hle : c + ((j - r : ℕ) : ℚ) * ((τ - c) / ((k : ℚ) - (r : ℚ))) ≤ 1 := by
    have h1 : ((j - r : ℕ) : ℚ) * ((τ - c) / ((k : ℚ) - (r : ℚ)))
        ≤ ((k : ℚ) - (r : ℚ)) * ((τ - c) / ((k : ℚ) - (r : ℚ))) := by
      exact mul_le_mul_of_nonneg_right hjr (div_nonneg (by linarith) hkr.le)
    rw [mul_div_cancel₀ _ (ne_of_gt hkr)] at h1
    linarith
  show (if j = 0 then 0
    else min 1 (c + ((j - r : ℕ) : ℚ) * ((τ - c) / ((k : ℚ) - (r : ℚ))))) = _
  rw [if_neg hne]
  exact min_eq_right hle

/-- At key `k` the tolerance is met exactly. -/
lemma cum_at_knee : (stagedProfile d c τ r k hc hcτ hr hrk).cum k = τ := by
  have hkr := kr_pos hrk
  rw [cum_tail hc hcτ hτ hr hrk (le_of_lt hrk) le_rfl]
  rw [Nat.cast_sub hrk.le]
  have hkr := kr_pos hrk
  have hcancel : ((k : ℚ) - (r : ℚ)) * ((τ - c) / ((k : ℚ) - (r : ℚ))) = τ - c := by
    field_simp
  rw [hcancel]
  ring

/-- Before key `k` the tolerance is missed. -/
lemma cum_lt_of_lt {j : ℕ} (hj : j < k) :
    (stagedProfile d c τ r k hc hcτ hr hrk).cum j < τ := by
  have hkr := kr_pos hrk
  have hs := step_pos hcτ hrk
  rcases Nat.eq_zero_or_pos j with hj0 | hj0
  · subst hj0
    rw [(stagedProfile d c τ r k hc hcτ hr hrk).cum_zero]
    linarith
  rcases le_or_gt j r with hjr | hjr
  · rw [cum_head hc hcτ hτ hr hrk hj0 hjr]; linarith
  · rw [cum_tail hc hcτ hτ hr hrk hjr.le hj.le]
    have hlt : ((j - r : ℕ) : ℚ) < (k : ℚ) - (r : ℚ) := by
      have h1 : ((j - r : ℕ) : ℚ) < ((k - r : ℕ) : ℚ) := by
        have : j - r < k - r := by omega
        exact_mod_cast this
      rwa [Nat.cast_sub hrk.le] at h1
    have := mul_lt_mul_of_pos_right hlt hs
    rw [mul_div_cancel₀ _ (ne_of_gt hkr)] at this
    linarith

/-- **The staged domain has knee exactly `k`.** -/
theorem kneeAt_staged : (stagedProfile d c τ r k hc hcτ hr hrk).kneeAt τ = k := by
  set P := stagedProfile d c τ r k hc hcτ hr hrk with hP
  refine le_antisymm (P.kneeAt_le (le_of_eq (cum_at_knee hc hcτ hτ hr hrk).symm)) ?_
  by_contra hlt
  push_neg at hlt
  exact absurd (P.kneeAt_spec hτ) (not_le.mpr (cum_lt_of_lt hc hcτ hτ hr hrk hlt))

/-- Its top-`r` mass is exactly `c`. -/
theorem cum_head_eq : (stagedProfile d c τ r k hc hcτ hr hrk).cum r = c :=
  cum_head hc hcτ hτ hr hrk hr le_rfl

end Staged

/-! ## 3. Head mass predicts nothing -/

/-- **Head-mass decoupling.**  For every tolerance `τ`, every head mass
`c ∈ (0, τ)` and every knee `k > 8`, some domain has top-8 mass exactly `c` and
knee exactly `k`.  Top-8 mass and the knee are independent coordinates. -/
theorem head_mass_knee_decoupled {c τ : ℚ} {k : ℕ} (hc : 0 < c) (hcτ : c < τ)
    (hτ : τ < 1) (hk : 8 < k) :
    ∃ P : AttentionProfile, P.cum 8 = c ∧ P.kneeAt τ = k :=
  ⟨stagedProfile 1 c τ 8 k hc hcτ (by norm_num) hk,
    Staged.cum_head_eq hc hcτ hτ (by norm_num) hk,
    Staged.kneeAt_staged hc hcτ hτ (by norm_num) hk⟩

/-- **No functional law from head mass to the knee.**  Not merely no monotone
law, and not merely a weak correlation: no function of the top-8 mass can
return the knee, because one head mass supports every knee. -/
theorem no_head_mass_functional_law {τ : ℚ} (hτ0 : 1/2 < τ) (hτ : τ < 1) :
    ¬ ∃ g : ℚ → ℕ, ∀ P : AttentionProfile, P.kneeAt τ = g (P.cum 8) := by
  rintro ⟨g, hg⟩
  obtain ⟨P, hP, hP9⟩ := head_mass_knee_decoupled (c := 1/2) (k := 9)
    (by norm_num) hτ0 hτ (by norm_num)
  obtain ⟨Q, hQ, hQ10⟩ := head_mass_knee_decoupled (c := 1/2) (k := 10)
    (by norm_num) hτ0 hτ (by norm_num)
  have h9 : g (1/2) = 9 := by rw [← hP, ← hg P, hP9]
  have h10 : g (1/2) = 10 := by rw [← hQ, ← hg Q, hQ10]
  omega

/-- **The sign of a head-mass/knee association is uninformative.**  There are
domain pairs where more top-8 mass comes with a *larger* knee and pairs where it
comes with a *smaller* one.  Whatever sign a sample of domains exhibits, it is
consistent with the same underlying structure, so a positive Spearman
coefficient is not evidence for a residual-spread mechanism. -/
theorem head_mass_sign_uninformative {τ : ℚ} (hτ0 : 3/4 < τ) (hτ : τ < 1) :
    (∃ P Q : AttentionProfile, P.cum 8 < Q.cum 8 ∧ P.kneeAt τ < Q.kneeAt τ) ∧
    (∃ P Q : AttentionProfile, P.cum 8 < Q.cum 8 ∧ Q.kneeAt τ < P.kneeAt τ) := by
  have h12 : (0:ℚ) < 1/2 := by norm_num
  have h34 : (0:ℚ) < 3/4 := by norm_num
  have hlt12 : (1:ℚ)/2 < τ := by linarith
  constructor
  · obtain ⟨P, hP, hP9⟩ := head_mass_knee_decoupled (c := 1/2) (k := 9) h12 hlt12 hτ
      (by norm_num)
    obtain ⟨Q, hQ, hQ10⟩ := head_mass_knee_decoupled (c := 3/4) (k := 10) h34 hτ0 hτ
      (by norm_num)
    exact ⟨P, Q, by rw [hP, hQ]; norm_num, by rw [hP9, hQ10]; norm_num⟩
  · obtain ⟨P, hP, hP10⟩ := head_mass_knee_decoupled (c := 1/2) (k := 10) h12 hlt12 hτ
      (by norm_num)
    obtain ⟨Q, hQ, hQ9⟩ := head_mass_knee_decoupled (c := 3/4) (k := 9) h34 hτ0 hτ
      (by norm_num)
    exact ⟨P, Q, by rw [hP, hQ]; norm_num, by rw [hP10, hQ9]; norm_num⟩

/-- **Tail shape dominates the head.**  For every `N` there are two domains
whose capture curves are *identical* on the first eight keys — same entropy of
the head, same top-8 mass, same everything a head statistic can see — whose
knees differ by at least `N`. -/
theorem tail_shape_dominates_head_mass {τ : ℚ} (hτ0 : 1/2 < τ) (hτ : τ < 1) (N : ℕ) :
    ∃ P Q : AttentionProfile,
      (∀ j ≤ 8, P.cum j = Q.cum j) ∧ P.kneeAt τ + N ≤ Q.kneeAt τ := by
  have h12 : (0:ℚ) < 1/2 := by norm_num
  refine ⟨stagedProfile 1 (1/2) τ 8 9 h12 hτ0 (by norm_num) (by norm_num),
    stagedProfile 1 (1/2) τ 8 (9 + N) h12 hτ0 (by norm_num) (by omega), ?_, ?_⟩
  · intro j hj
    rcases Nat.eq_zero_or_pos j with hj0 | hj0
    · subst hj0
      simp only [AttentionProfile.cum_zero]
    · rw [Staged.cum_head h12 hτ0 hτ (by norm_num) (by norm_num) hj0 hj,
        Staged.cum_head h12 hτ0 hτ (by norm_num) (by omega) hj0 hj]
  · rw [Staged.kneeAt_staged h12 hτ0 hτ (by norm_num) (by norm_num),
      Staged.kneeAt_staged h12 hτ0 hτ (by norm_num) (by omega)]

/-! ## 4. Tail shape, quantitatively -/

/-- A geometric residual bounds the knee: as soon as `R ρ^j` drops below the
missing mass `1 - τ`, the budget `r + j` suffices. -/
theorem kneeAt_le_of_geometric_tail {τ R ρ : ℚ} {r j : ℕ}
    (hdecay : residual P (r + j) ≤ R * ρ ^ j) (hsmall : R * ρ ^ j ≤ 1 - τ) :
    P.kneeAt τ ≤ r + j := by
  refine P.kneeAt_le ?_
  have := hdecay
  rw [residual] at this
  linarith

/-- For a geometrically decaying residual the knee is finite and located by the
first index at which the geometric bound clears the missing mass. -/
theorem exists_geometric_tail_knee_bound {τ R ρ : ℚ} {r : ℕ} (hR : 0 < R)
    (hρ1 : ρ < 1) (hτ : τ < 1)
    (hdecay : ∀ j, residual P (r + j) ≤ R * ρ ^ j) :
    ∃ j, R * ρ ^ j ≤ 1 - τ ∧ P.kneeAt τ ≤ r + j := by
  have hpos : (0:ℚ) < (1 - τ) / R := div_pos (by linarith) hR
  obtain ⟨j, hj⟩ := exists_pow_lt_of_lt_one hpos hρ1
  have hle : R * ρ ^ j ≤ 1 - τ := by
    rw [lt_div_iff₀ hR] at hj
    nlinarith [hj]
  exact ⟨j, hle, kneeAt_le_of_geometric_tail P (hdecay j) hle⟩

/-- **Heavy (Pareto-type) tails force large knees.**  If the residual after
`r + j` keys stays above `R/(j+1)`, the knee satisfies
`k* ≥ r + R/(1 - τ) - 1`, a bound that diverges as the tolerance approaches the
full mass — in sharp contrast with the geometric case, where the same tolerance
costs only the first `j` with `R ρ^j ≤ 1 - τ`. -/
theorem heavy_tail_knee_lower_bound {τ R : ℚ} {r : ℕ} (hτ : τ < 1)
    (hhead : P.cum r < τ)
    (hheavy : ∀ j : ℕ, R / ((j : ℚ) + 1) ≤ residual P (r + j)) :
    R / (1 - τ) ≤ (P.kneeAt τ : ℚ) - (r : ℚ) + 1 := by
  have hknee : τ ≤ P.cum (P.kneeAt τ) := P.kneeAt_spec hτ
  have hle : r ≤ P.kneeAt τ := by
    by_contra hlt
    push_neg at hlt
    exact absurd (le_trans hknee (P.cum_mono hlt.le)) (not_le.mpr hhead)
  set j := P.kneeAt τ - r with hjdef
  have hrj : P.kneeAt τ = r + j := by omega
  have h1 : R / ((j : ℚ) + 1) ≤ 1 - τ := by
    have h := hheavy j
    rw [residual, ← hrj] at h
    linarith
  have hjpos : (0:ℚ) < (j : ℚ) + 1 := by positivity
  have hgoal : ((P.kneeAt τ : ℕ) : ℚ) - (r : ℚ) + 1 = (j : ℚ) + 1 := by
    rw [hrj]; push_cast; ring
  rw [hgoal, div_le_iff₀ (by linarith : (0:ℚ) < 1 - τ)]
  rw [div_le_iff₀ hjpos] at h1
  nlinarith [h1]

/-- **Synthesis.**  The knee is computed by the tail (`knee_depends_only_on_tail`
and `kneeAt_eq_head_add_tailKnee`), the head mass constrains it not at all
(`head_mass_knee_decoupled`), and the sign of any head-mass/knee association is
free (`head_mass_sign_uninformative`).  NET-74's mechanism sentence is a
theorem; its correlational evidence for that sentence is not evidence. -/
theorem net74_mechanism {τ : ℚ} (hτ0 : 3/4 < τ) (hτ : τ < 1) :
    (∀ P Q : AttentionProfile, ∀ r : ℕ, P.cum r < τ → Q.cum r < τ →
        (∀ j, P.cum (r + j) = Q.cum (r + j)) → P.kneeAt τ = Q.kneeAt τ) ∧
    (∀ k : ℕ, 8 < k → ∃ P : AttentionProfile, P.cum 8 = 1/2 ∧ P.kneeAt τ = k) ∧
    ¬ ∃ g : ℚ → ℕ, ∀ P : AttentionProfile, P.kneeAt τ = g (P.cum 8) := by
  refine ⟨fun P Q r hP hQ h => knee_depends_only_on_tail P Q hτ hP hQ h,
    fun k hk => head_mass_knee_decoupled (by norm_num) (by linarith) hτ hk,
    no_head_mass_functional_law (by linarith) hτ⟩

end Catalog.NET74Tail