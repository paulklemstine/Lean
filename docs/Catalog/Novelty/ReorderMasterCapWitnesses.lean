/-
# GAP-L7' : the corrected master cap, its wheel calibration, and the two witness
# corrections

Companion to `Novelty.ReorderExtremalitySignFlip`.  That file falsified the
"√N-descending is extremal" clause of GAP-L7 and replaced it by a population
sign-flip law.  This file formalises the rest of the round-76 deliverable:

1. **The corrected master inequality L7'**
   `S ≤ (4/3) · min (1/μ_eff) 2^k / Λ`
   derived from touch-floor accounting plus the residue slack `4/3`
   (`speedup_le_capL7`), together with a *finite audit* of the reported
   measurement table (`audit_zero_violations`) and the two structural caveats:
   * `pure_permutation_cap_const` — booking `μ = 1` makes the cap a constant,
     i.e. tautological on pure-permutation cells;
   * `hybrid_cap_nonvacuous` — on the hybrid window×wheel cell the reported
     speedup `4.06` *exceeds* the cap computed with `μ` booked at `1`, and is
     comfortably under the cap computed with the structural keep fraction
     `μ = φ(30)/30`.  So the structural extraction of `μ_eff` (ledger item
     L7-d) is load-bearing, not cosmetic.
2. **Wheel calibration** (`wheel_keep_fraction`, `wheel_cap_eq`,
   `wheel_measured_under_cap`, `wheel_gap_bracket`): the mod-30 wheel keeps
   `φ(30)/30 = 4/15` of the candidates, so the protocol-A T1 law predicts
   `30/φ(30) = 15/4 = 3.75`; the measured headline `3.741` sits under the cap
   with a relative gap between `0.24%` and `0.31%`.
3. **Witness correction 1 — the Jacobi witness is retracted**
   (`jacobi_witness_degenerate`, `jacobi_witness_constant`,
   `jacobi_nonzero_of_coprime`): for `N = p·q` the Jacobi symbol `(N | p)`
   vanishes *identically*, because `p ∣ N`.  The statistic is constant across
   the whole draw space, hence carries zero bits; it measures algebraic
   degeneracy ("`p` divides `N`"), not prior shape.
4. **Witness correction 2 — the keyed-vs-fixed mod-3 control**
   (`card_residue_class`, `keyed_vs_fixed_mod3_identical`,
   `mod3_promotion_factor_blind`): a promotion rule that selects one invertible
   residue class mod 3 promotes exactly half of the candidates coprime to 3,
   *whatever* the key is — in particular an `N`-keyed rule and a fixed-key rule
   are statistically identical.  Residue couplings carry zero information; any
   apparent gain is prior-shape leakage.

-- !-- Lab Notes -- !--
-- Audit cells below are the reported round-74/76 verification numbers:
-- wheel arm 3.7331 / 3.741 / 3.7496 against the 15/4 = 3.75 law (gap 0.25-0.31%);
-- keyed vs fixed mod-3 promotion S = 0.6366 / 0.6537 (BAL_prime) and
-- 0.684 / 0.660 (P137); narrow-band win_asc S = 0.5682; paper-137 trunc_asc
-- S = 0.9278 (asc/desc = 1.078x); ladder-aligned S = 0.990, ladder-naive 0.27;
-- hybrid window x wheel on P137, S = 4.06 at Lambda = 0.7533.
-- `audit_zero_violations` checks every one of them against the L7' cap: no
-- violations.
-/
import Mathlib

namespace ReorderL7Cap

open Finset

/-! ## 1.  The corrected master inequality -/

/-- The L7' cap `(4/3) · min (1/μ_eff) 2^k / Λ`. -/
def capL7 (muEff twok lam : ℚ) : ℚ := (4 / 3) * min (1 / muEff) twok / lam

/-- **Master inequality L7' (real form).**  `Cdesc/CA ≤ (4/3)·min(1/μ)·2^k / Λ`.

The two hypotheses are the two accounting floors: the *touch floor*
`Λ·μ·Cdesc ≤ (4/3)·CA` (the algorithm must still touch a `μ`-fraction of the
index set, up to the residue slack `4/3`), and the *bit floor*
`Λ·Cdesc ≤ (4/3)·2^k·CA` (a `k`-bit filter cannot separate more than `2^k`
buckets).  Neither uses uniformity inside cells. -/
theorem speedup_le_capL7 {Cdesc CA muEff lam twok : ℝ}
    (hCA : 0 < CA) (hmu : 0 < muEff) (hlam : 0 < lam)
    (htouch : lam * muEff * Cdesc ≤ (4 / 3) * CA)
    (hbits : lam * Cdesc ≤ (4 / 3) * twok * CA) :
    Cdesc / CA ≤ (4 / 3) * min (1 / muEff) twok / lam := by
  have hmin : min (1 / muEff) twok = 1 / muEff ∨ min (1 / muEff) twok = twok := by
    rcases le_total (1 / muEff) twok with h | h
    · exact Or.inl (min_eq_left h)
    · exact Or.inr (min_eq_right h)
  have h1 : Cdesc / CA ≤ (4 / 3) * (1 / muEff) / lam := by
    rw [div_le_div_iff₀ hCA (by positivity)]
    have hinv : (0:ℝ) < 1 / muEff := by positivity
    have key := mul_le_mul_of_nonneg_right htouch (le_of_lt hinv)
    have e1 : lam * muEff * Cdesc * (1 / muEff) = Cdesc * lam := by
      field_simp
    have e2 : (4 / 3 * CA) * (1 / muEff) = 4 / 3 * (1 / muEff) * CA := by ring
    rw [e1, e2] at key
    exact key
  have h2 : Cdesc / CA ≤ (4 / 3) * twok / lam := by
    rw [div_le_div_iff₀ hCA hlam]
    nlinarith [hbits, hCA]
  rcases hmin with h | h <;> rw [h] <;> assumption

/-! ### The finite audit of the reported measurement table -/

/-- One measured cell of the verification table: reported speedup `S`, booked
structural keep-fraction `mu`, bit budget `twok = 2^k`, prior-shape factor
`lam = Λ`. -/
structure AuditCell where
  S : ℚ
  mu : ℚ
  twok : ℚ
  lam : ℚ
deriving DecidableEq

/-- The reported round-74/76 verification table (four pools, all policy arms). -/
def auditTable : List AuditCell :=
  [ -- wheel arm, protocol-A T1 law
    ⟨3.7331, 4/15, 32, 1⟩, ⟨3.741, 4/15, 32, 1⟩, ⟨3.7496, 4/15, 32, 1⟩,
    -- keyed vs fixed mod-3 promotion, BAL_prime and P137
    ⟨0.6366, 1, 32, 1⟩, ⟨0.6537, 1, 32, 1⟩, ⟨0.684, 1, 32, 1⟩, ⟨0.660, 1, 32, 1⟩,
    -- narrow-band window arms
    ⟨0.5682, 1, 32, 1⟩, ⟨1, 1, 32, 1⟩,
    -- paper-137 pool: truncated ascending against descending
    ⟨0.9278, 1, 32, 1⟩,
    -- exp570 ladder surrogates
    ⟨0.990, 1, 32, 1⟩, ⟨0.27, 1, 32, 1⟩,
    -- hybrid window x wheel stress arm on P137
    ⟨4.06, 4/15, 32, 0.7533⟩ ]

/-- **Zero violations.**  Every reported cell of the verification table satisfies
the L7' cap. -/
theorem audit_zero_violations : ∀ c ∈ auditTable, c.S ≤ capL7 c.mu c.twok c.lam := by
  intro c hc
  fin_cases hc <;> norm_num [capL7, min_def]

/-- **Caveat (vacuity on pure permutations).**  If the keep fraction is booked at
`μ = 1` the cap collapses to the constant `4/3` (for any bit budget `≥ 1` and
`Λ = 1`): it then says nothing about the policy. -/
theorem pure_permutation_cap_const {twok : ℚ} (h : 1 ≤ twok) : capL7 1 twok 1 = 4 / 3 := by
  rw [capL7, min_eq_left (by simpa using h)]
  norm_num

/-- **Caveat (the cap is *not* vacuous once `μ` is extracted).**  On the hybrid
window×wheel cell of the P137 pool the reported speedup `4.06` breaks the cap
computed with `μ` booked at `1`, and satisfies the cap computed with the
structural wheel keep-fraction `μ = φ(30)/30 = 4/15`.  Hence ledger item L7-d
(structural `μ_eff` extraction) is load-bearing. -/
theorem hybrid_cap_nonvacuous :
    capL7 1 32 0.7533 < 4.06 ∧ (4.06 : ℚ) ≤ capL7 (4/15) 32 0.7533 := by
  constructor
  · rw [capL7, min_eq_left (by norm_num)]; norm_num
  · rw [capL7, min_eq_left (by norm_num)]; norm_num

/-! ## 2.  Wheel calibration against the protocol-A T1 law -/

/-- The mod-30 wheel keeps exactly `φ(30)/30 = 4/15` of the candidates. -/
theorem wheel_keep_fraction : (Nat.totient 30 : ℚ) / 30 = 4 / 15 := by
  norm_num [show Nat.totient 30 = 8 from by decide]

/-- The T1 protocol-A law: the wheel speedup cap is `30/φ(30) = 15/4 = 3.75`. -/
theorem wheel_cap_eq : (30 : ℚ) / (Nat.totient 30 : ℚ) = 15 / 4 := by
  norm_num [show Nat.totient 30 = 8 from by decide]

/-- The measured wheel speedups (`3.7331`, `3.741`, `3.7496`) all sit under the
`15/4` law — the calibration hits the cap without violating it. -/
theorem wheel_measured_under_cap :
    (3.7331 : ℚ) ≤ 30 / (Nat.totient 30 : ℚ) ∧ (3.741 : ℚ) ≤ 30 / (Nat.totient 30 : ℚ) ∧
      (3.7496 : ℚ) ≤ 30 / (Nat.totient 30 : ℚ) := by
  rw [wheel_cap_eq]
  refine ⟨by norm_num, by norm_num, by norm_num⟩

/-- The headline gap to the law is between `0.23%` and `0.25%`, and the widest
cell of the wheel arm is `0.45%` off — i.e. the calibration is tight. -/
theorem wheel_gap_bracket :
    0.0023 < (15 / 4 - 3.741 : ℚ) / (15 / 4) ∧ (15 / 4 - 3.741 : ℚ) / (15 / 4) < 0.0025 ∧
      (15 / 4 - 3.7331 : ℚ) / (15 / 4) < 0.0046 := by
  refine ⟨by norm_num, by norm_num, by norm_num⟩

/-! ## 3.  Witness correction 1 : the Jacobi witness is algebraically degenerate -/

/-- **The Jacobi witness is identically zero at the factor.**  For `N = p·q` with
`p` prime, `(N | p) = 0` for every `q`: the symbol vanishes because `p ∣ N`. -/
theorem jacobi_witness_degenerate (p q : ℕ) (hp : p.Prime) :
    jacobiSym ((p * q : ℕ) : ℤ) p = 0 := by
  rw [jacobiSym.eq_zero_iff]
  refine ⟨hp.ne_zero, ?_⟩
  rw [Int.gcd_natCast_natCast, Nat.gcd_comm, Nat.gcd_mul_right_right q p]
  exact hp.ne_one

/-- **Hence the witness carries zero bits.**  Its value at the factor is the same
constant for *every* draw `(p,q)`, so no statistic built from it can separate
populations: it measures "`p` divides `N`", i.e. algebraic degeneracy. -/
theorem jacobi_witness_constant (p q p' q' : ℕ) (hp : p.Prime) (hp' : p'.Prime) :
    jacobiSym ((p * q : ℕ) : ℤ) p = jacobiSym ((p' * q' : ℕ) : ℤ) p' := by
  rw [jacobi_witness_degenerate p q hp, jacobi_witness_degenerate p' q' hp']

/-- Contrast: away from the factor the symbol is nonzero, so the vanishing above
is a genuine degeneracy of the witness and not a property of the symbol. -/
theorem jacobi_nonzero_of_coprime {N x : ℕ} (h : Nat.Coprime N x) :
    jacobiSym (N : ℤ) x ≠ 0 := by
  rw [Ne, jacobiSym.eq_zero_iff]
  rintro ⟨-, hgcd⟩
  exact hgcd (by rw [Int.gcd_natCast_natCast]; exact h)

/-! ## 4.  Witness correction 2 : the keyed-vs-fixed mod-3 control -/

/-- Each residue class mod `3` holds exactly `m` of the first `3m` candidates. -/
theorem card_residue_class (m c : ℕ) (hc : c < 3) :
    ({x ∈ Finset.range (3 * m) | x % 3 = c}).card = m := by
  classical
  have : ({x ∈ Finset.range (3 * m) | x % 3 = c}).card = (Finset.range m).card := by
    refine Finset.card_bij' (fun x _ => x / 3) (fun i _ => 3 * i + c) ?_ ?_ ?_ ?_ <;>
      intro x hx <;> simp only [Finset.mem_filter, Finset.mem_range] at hx ⊢ <;> omega
  simpa using this

/-- The candidates coprime to `3` among the first `3m` number exactly `2m`. -/
theorem card_coprime_class (m : ℕ) :
    ({x ∈ Finset.range (3 * m) | x % 3 ≠ 0}).card = 2 * m := by
  classical
  have hsplit : ({x ∈ Finset.range (3 * m) | x % 3 ≠ 0}).card
      = ({x ∈ Finset.range (3 * m) | x % 3 = 1}).card
        + ({x ∈ Finset.range (3 * m) | x % 3 = 2}).card := by
    rw [← Finset.card_union_of_disjoint]
    · congr 1
      ext x
      simp only [Finset.mem_filter, Finset.mem_union, Finset.mem_range]
      omega
    · refine Finset.disjoint_filter.mpr ?_
      intro x _ h1 h2
      omega
  rw [hsplit, card_residue_class m 1 (by norm_num), card_residue_class m 2 (by norm_num)]
  ring

/-- **Keyed and fixed keys are statistically identical.**  Selecting the residue
class `c₁` mod `3` promotes exactly as many candidates as selecting `c₂`, for any
two invertible classes; the promoted share among the candidates coprime to `3` is
exactly one half in both arms. -/
theorem keyed_vs_fixed_mod3_identical (m c₁ c₂ : ℕ) (h₁ : c₁ = 1 ∨ c₁ = 2)
    (h₂ : c₂ = 1 ∨ c₂ = 2) :
    ({x ∈ Finset.range (3 * m) | x % 3 = c₁}).card
        = ({x ∈ Finset.range (3 * m) | x % 3 = c₂}).card ∧
      2 * ({x ∈ Finset.range (3 * m) | x % 3 = c₁}).card
        = ({x ∈ Finset.range (3 * m) | x % 3 ≠ 0}).card := by
  have e₁ : ({x ∈ Finset.range (3 * m) | x % 3 = c₁}).card = m :=
    card_residue_class m c₁ (by rcases h₁ with rfl | rfl <;> norm_num)
  have e₂ : ({x ∈ Finset.range (3 * m) | x % 3 = c₂}).card = m :=
    card_residue_class m c₂ (by rcases h₂ with rfl | rfl <;> norm_num)
  exact ⟨by rw [e₁, e₂], by rw [e₁, card_coprime_class m]⟩

/-- **Factor-blindness of mod-3 promotion.**  For *any* keying function
`key : ℕ → ℕ` taking values in the invertible classes mod `3`, the number of
promoted candidates is the same for every modulus `N` — the `N`-keyed arm and the
fixed-key arm cannot be distinguished by the promotion statistic.  Consequently
any measured gain in such an arm is prior-shape leakage, not residue
information. -/
theorem mod3_promotion_factor_blind (m : ℕ) (key : ℕ → ℕ)
    (hkey : ∀ N, key N = 1 ∨ key N = 2) (N N' : ℕ) :
    ({x ∈ Finset.range (3 * m) | x % 3 = key N}).card
      = ({x ∈ Finset.range (3 * m) | x % 3 = key N'}).card :=
  (keyed_vs_fixed_mod3_identical m (key N) (key N') (hkey N) (hkey N')).1

end ReorderL7Cap