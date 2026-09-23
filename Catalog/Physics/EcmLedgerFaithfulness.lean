import Mathlib
import Catalog.Physics.EcmWallSharpThreshold

/-!
# Exact two-prime outcome counts, and how a non-injective ledger manufactures a wall

The audit of paper 159 turns on an accounting question: which recorded outcome does a
guarded inversion with `gcd = p` get filed under?  This file makes both halves of that
question exact.

**Exact counts.**  In the standard cyclic model — a random point is a uniformly random
pair of residues `(a, b) ∈ ℤ/m_p × ℤ/m_q`, one coordinate per prime factor of
`N = p·q` — the four separated outcomes partition `m_p · m_q` trials into blocks whose
sizes are products of the two firing counts:

* `card_deadSet`      : `gcd(m_p,k) · gcd(m_q,k)`
* `card_foundPSet`    : `gcd(m_p,k) · (m_q − gcd(m_q,k))`
* `card_foundQSet`    : `(m_p − gcd(m_p,k)) · gcd(m_q,k)`
* `card_nothingSet`   : `(m_p − gcd(m_p,k)) · (m_q − gcd(m_q,k))`
* `card_add_card_eq`  : the four blocks sum to `m_p · m_q`.

**The wall, exactly.**  `reveal_eq_empty_of_both_cover` shows that when the bound covers
*both* group orders every trial is `dead` and the reveal count is `0`: a genuine wall
exists, and it sits at `max(p,q)`.  `reveal_monotone_of_inert_q` shows that as long as
the mod-`q` side stays inert the reveal count is monotone in `B`, so nothing wall-shaped
can happen at `min(p,q)`.  `reveal_drops_two_two` is an explicit two-line witness of the
real wall.

**Ledger faithfulness.**  A ledger is a map from the firing pattern `(fires mod p,
fires mod q)` to a recorded outcome.  `canonicalLedger_faithful` states that the
separated ledger is injective; `wallLedger_not_faithful` and
`wallLedger_manufactures_wall` show that the single conflation "file a `p`-side firing
as a death" is non-injective and reproduces, verbatim, the recorded wall sentence on
inputs where the truth is `found_p`.
-/

namespace ECMWall

open ECMStage1 Finset

/-! ## The complement of the firing set -/

/-- Residues that are *not* killed by the scalar. -/
def coFiringSet (m k : ℕ) : Finset ℕ := Finset.range m \ firingSet m k

theorem firingSet_subset_range (m k : ℕ) : firingSet m k ⊆ Finset.range m :=
  Finset.filter_subset _ _

theorem card_coFiringSet {m k : ℕ} (hm : 0 < m) :
    (coFiringSet m k).card = m - Nat.gcd m k := by
  rw [coFiringSet, Finset.card_sdiff_of_subset (firingSet_subset_range m k),
    Finset.card_range, card_firingSet _ _ hm]

/-! ## The four separated outcome blocks -/

variable (mp mq k : ℕ)

/-- Trials revealing `p`: the mod-`p` coordinate fires, the mod-`q` one does not. -/
def foundPSet : Finset (ℕ × ℕ) := firingSet mp k ×ˢ coFiringSet mq k

/-- Trials revealing `q`. -/
def foundQSet : Finset (ℕ × ℕ) := coFiringSet mp k ×ˢ firingSet mq k

/-- Trials in which both coordinates degenerate: the guarded inversion returns `N`. -/
def deadSet : Finset (ℕ × ℕ) := firingSet mp k ×ˢ firingSet mq k

/-- Trials in which nothing degenerates. -/
def nothingSet : Finset (ℕ × ℕ) := coFiringSet mp k ×ˢ coFiringSet mq k

/-- Trials revealing a proper factor of `N`. -/
def revealSet : Finset (ℕ × ℕ) := foundPSet mp mq k ∪ foundQSet mp mq k

variable {mp mq k}

theorem card_deadSet (hp : 0 < mp) (hq : 0 < mq) :
    (deadSet mp mq k).card = Nat.gcd mp k * Nat.gcd mq k := by
  rw [deadSet, Finset.card_product, card_firingSet _ _ hp, card_firingSet _ _ hq]

theorem card_foundPSet (hp : 0 < mp) (hq : 0 < mq) :
    (foundPSet mp mq k).card = Nat.gcd mp k * (mq - Nat.gcd mq k) := by
  rw [foundPSet, Finset.card_product, card_firingSet _ _ hp, card_coFiringSet hq]

theorem card_foundQSet (hp : 0 < mp) (hq : 0 < mq) :
    (foundQSet mp mq k).card = (mp - Nat.gcd mp k) * Nat.gcd mq k := by
  rw [foundQSet, Finset.card_product, card_coFiringSet hp, card_firingSet _ _ hq]

theorem card_nothingSet (hp : 0 < mp) (hq : 0 < mq) :
    (nothingSet mp mq k).card = (mp - Nat.gcd mp k) * (mq - Nat.gcd mq k) := by
  rw [nothingSet, Finset.card_product, card_coFiringSet hp, card_coFiringSet hq]

/-- The four blocks account for every trial. -/
theorem card_add_card_eq (hp : 0 < mp) (hq : 0 < mq) :
    (deadSet mp mq k).card + (foundPSet mp mq k).card + (foundQSet mp mq k).card
      + (nothingSet mp mq k).card = mp * mq := by
  have h1 : Nat.gcd mp k ≤ mp := Nat.le_of_dvd hp (Nat.gcd_dvd_left _ _)
  have h2 : Nat.gcd mq k ≤ mq := Nat.le_of_dvd hq (Nat.gcd_dvd_left _ _)
  rw [card_deadSet hp hq, card_foundPSet hp hq, card_foundQSet hp hq,
    card_nothingSet hp hq]
  zify [h1, h2]
  ring

theorem foundPSet_disjoint_foundQSet :
    Disjoint (foundPSet mp mq k) (foundQSet mp mq k) := by
  refine Finset.disjoint_left.mpr ?_
  rintro ⟨a, b⟩ ha hb
  simp only [foundPSet, foundQSet, coFiringSet, Finset.mem_product, Finset.mem_sdiff] at ha hb
  exact hb.1.2 ha.1

/-- **Exact reveal count.**  The number of trials that expose a proper factor of `N`. -/
theorem card_revealSet (hp : 0 < mp) (hq : 0 < mq) :
    (revealSet mp mq k).card =
      Nat.gcd mp k * (mq - Nat.gcd mq k) + (mp - Nat.gcd mp k) * Nat.gcd mq k := by
  rw [revealSet, Finset.card_union_of_disjoint foundPSet_disjoint_foundQSet,
    card_foundPSet hp hq, card_foundQSet hp hq]

/-! ## The real wall: both orders covered -/

/-- **At `B ≥ max(m_p, m_q)` every trial is `dead`.**  This is the only regime in which
the method genuinely destroys itself, and it is governed by the *larger* prime. -/
theorem reveal_eq_empty_of_both_cover {B : ℕ} (hp : 0 < mp) (hq : 0 < mq)
    (hBp : mp ≤ B) (hBq : mq ≤ B) :
    (revealSet mp mq (stage1Scalar B)).card = 0 := by
  rw [card_revealSet hp hq, gcd_eq_self_at_wall hp hBp, gcd_eq_self_at_wall hq hBq]
  simp

/-- Below the real wall — while the mod-`q` side stays inert (only the identity fires
there) — the reveal count is monotone in the bound: raising `B1` never costs successes.
-/
theorem reveal_monotone_of_inert_q {B B' : ℕ} (hp : 0 < mp) (hq : 2 ≤ mq)
    (hB : B ≠ 0) (hBB : B ≤ B')
    (hinert : ∀ r ∈ mq.primeFactors, B' < r) :
    (revealSet mp mq (stage1Scalar B)).card ≤ (revealSet mp mq (stage1Scalar B')).card := by
  have hqpos : 0 < mq := by omega
  have hB' : B' ≠ 0 := by omega
  have hinertB : ∀ r ∈ mq.primeFactors, B < r := fun r hr => lt_of_le_of_lt hBB (hinert r hr)
  have hq1 : Nat.gcd mq (stage1Scalar B) = 1 :=
    firing_count_eq_one_of_all_prime_factors_gt hqpos.ne' hB hinertB
  have hq1' : Nat.gcd mq (stage1Scalar B') = 1 :=
    firing_count_eq_one_of_all_prime_factors_gt hqpos.ne' hB' hinert
  have hmono : Nat.gcd mp (stage1Scalar B) ≤ Nat.gcd mp (stage1Scalar B') :=
    firing_count_mono hp hBB
  have hle : Nat.gcd mp (stage1Scalar B') ≤ mp := Nat.le_of_dvd hp (Nat.gcd_dvd_left _ _)
  rw [card_revealSet hp hqpos, card_revealSet hp hqpos, hq1, hq1']
  simp only [mul_one]
  have hstep : ∀ x y : ℕ, x ≤ y → y ≤ mp →
      x * (mq - 1) + (mp - x) ≤ y * (mq - 1) + (mp - y) := by
    intro x y hxy hy
    have hpos : 0 < mq - 1 := by omega
    have key : (y - x) ≤ (y - x) * (mq - 1) := Nat.le_mul_of_pos_right _ hpos
    have expand : y * (mq - 1) = x * (mq - 1) + (y - x) * (mq - 1) := by
      rw [← Nat.add_mul]
      congr 1
      omega
    omega
  exact hstep _ _ hmono hle

/-- **Explicit witness of the real wall.**  Two groups of order `2`: at `B = 1` both
trials reveal a factor, at `B = 2` none does — the reveal count drops from `2` to `0`
because the bound has covered *both* orders. -/
theorem reveal_drops_two_two :
    (revealSet 2 2 (stage1Scalar 1)).card = 2 ∧ (revealSet 2 2 (stage1Scalar 2)).card = 0 := by
  constructor
  · rw [card_revealSet (by norm_num) (by norm_num)]
    have h : stage1Scalar 1 = 1 := by decide
    rw [h]
    decide
  · exact reveal_eq_empty_of_both_cover (by norm_num) (by norm_num) (by norm_num) (by norm_num)

/-- **The `found_p` channel alone is not monotone.**  With `m_p = 4`, `m_q = 6`, going
from `B = 2` to `B = 3` takes the `found_p` count from `8` to `0` — not because the
method failed, but because those eight trials moved into the `dead` block when the
mod-`q` side started firing too.  Monotonicity holds for the *firing* count
(`no_destruction_wall`); the per-channel counts redistribute, which is precisely why
channel separation is required to read the ledger. -/
theorem foundP_not_monotone :
    (foundPSet 4 6 (stage1Scalar 2)).card = 8 ∧ (foundPSet 4 6 (stage1Scalar 3)).card = 0 := by
  have h2 : stage1Scalar 2 = 2 := by decide
  have h3 : stage1Scalar 3 = 6 := by decide
  constructor
  · rw [card_foundPSet (by norm_num) (by norm_num), h2]
    decide
  · rw [card_foundPSet (by norm_num) (by norm_num), h3]
    decide

/-! ## Ledger faithfulness -/

/-- An accounting ledger: what a run records, given which residues degenerated. -/
abbrev Ledger := Bool → Bool → Outcome

/-- The outcome-separated ledger of experiment 568. -/
def canonicalLedger : Ledger := fun fp fq =>
  if fp then (if fq then Outcome.dead else Outcome.foundP)
  else (if fq then Outcome.foundQ else Outcome.nothing)

/-- A ledger is *faithful* when distinct firing patterns are recorded distinctly. -/
def Faithful (L : Ledger) : Prop := ∀ a b c d : Bool, L a b = L c d → a = c ∧ b = d

theorem canonicalLedger_faithful : Faithful canonicalLedger := by
  unfold Faithful canonicalLedger
  decide

/-- The conflating ledger that files any mod-`p` degeneracy as a death — the reading
under which the recorded wall sentence is true. -/
def wallLedger : Ledger := fun fp fq =>
  if fp then Outcome.dead else (if fq then Outcome.foundQ else Outcome.nothing)

theorem wallLedger_not_faithful : ¬ Faithful wallLedger := by
  unfold Faithful wallLedger
  decide

/-- **The wall sentence is the image of the conflation.**  On exactly the firing
pattern produced at `B ≥ p+1+2√p` with the mod-`q` side inert — `(true, false)` — the
faithful ledger records `found_p` while the conflating ledger records `dead`.  The
recorded "all curves degenerate simultaneously" is that single misfiling. -/
theorem wallLedger_manufactures_wall :
    canonicalLedger true false = Outcome.foundP ∧ wallLedger true false = Outcome.dead := by
  constructor <;> rfl

/-- The canonical ledger agrees with the `Prop`-valued outcome function of
`Catalog.Physics.EcmStage2Wall`. -/
theorem canonicalLedger_eq_outcomeOf (fp fq : Prop) [Decidable fp] [Decidable fq] :
    canonicalLedger (decide fp) (decide fq) = outcomeOf fp fq := by
  by_cases h1 : fp <;> by_cases h2 : fq <;>
    simp [canonicalLedger, outcomeOf, h1, h2]

end ECMWall