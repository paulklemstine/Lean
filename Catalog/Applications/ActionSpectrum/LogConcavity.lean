import Applications.ActionSpectrum.Basic

/-!
# Log-concavity of the subset spectrum of a finite action

The research target of this file is the claim

> for every finite action the spectrum is log-concave: `t_r² ≥ t_{r-1}·t_{r+1}` for `1 ≤ r < |X|`.

**The claim is false.**  The cyclic group of order `4` acting on `4` points has spectrum
`(1, 1, 2, 1, 1)`, and `t_1² = 1 < 2 = t_0·t_2` (`SubsetSpectrum.C4.not_logConcaveSpectrum`,
`SubsetSpectrum.not_forall_logConcaveSpectrum`).

What we prove instead is a complete structural explanation of *when* the claim holds,
plus a quantitative repair that is valid for every finite action:

* `SubsetSpectrum.logConcave_of_trivial_action` — for the trivial action the spectrum is the
  binomial row and log-concavity **does** hold (so the statement is not vacuous);
* `SubsetSpectrum.spec_mul_spec_le_card_sq_mul_spec_sq` — the **guarded universal version**
  `t_{r-1}·t_{r+1} ≤ |G|²·t_r²`, valid for *every* finite action;
* `SubsetSpectrum.spec_eq_one_of_logConcave` — a **collapse/propagation theorem**: once two
  consecutive spectrum values equal `1`, log-concavity forces *all* later values to be `1`;
* `SubsetSpectrum.logConcave_iff_setTransitive` — hence for a *transitive* action,
  log-concavity of the spectrum is **equivalent** to set-transitivity (`r`-homogeneity for
  every `r`), a drastic rigidity statement: the conjecture holds only for the handful of
  set-transitive permutation groups;
* `SubsetSpectrum.choose_le_card_of_transitive_logConcave` — the resulting numerical
  obstruction `C(n,r) ≤ |G|` for all `r`, so a log-concave transitive action needs a group
  of exponential size;
* `SubsetSpectrum.not_logConcave_of_regular` — an **infinite family of counterexamples**:
  every regular action on `n ≥ 4` points (a group acting on itself by translation) fails
  log-concavity;
* `SubsetSpectrum.logConcave_perm` — the symmetric group is such an action, so the class of
  log-concave transitive actions is nonempty.

A group-free sharpening of the guarded bound, `t_{r-1}·t_{r+1} ≤ r(n-r)·t_r²`, is proved by a
shadow argument in `Applications.ActionSpectrum.Shadow`.

## Lab notes (computed with the executable model `SubsetSpectrum.spec`)

Spectra of the cyclic group `C_n` acting on `n` points (binary necklaces by weight):

```
n = 3 : 1 1 1 1
n = 4 : 1 1 2 1 1
n = 5 : 1 1 2 2 1 1
n = 6 : 1 1 3 4 3 1 1
n = 7 : 1 1 3 5 5 3 1 1
n = 8 : 1 1 4 7 10 7 4 1 1
```

Every one of these fails log-concavity at `r = 1` (and, by the symmetry `t_r = t_{n-r}`,
at `r = n-1`) as soon as `n ≥ 4`.  The trivial group on `4` points gives `1 4 6 4 1`
(log-concave), `S_4` and `A_4` on `4` points give `1 1 1 1 1` (log-concave).
-/

open Finset

namespace SubsetSpectrum

variable {G X : Type*} [Group G] [MulAction G X] [DecidableEq X] [Fintype G] [Fintype X]

/-! ## The property under investigation -/

variable (G X) in
/-- The subset spectrum `t_0, …, t_n` of the action is **log-concave**:
`t_{r-1} · t_{r+1} ≤ t_r²` for `1 ≤ r < n`. -/
def LogConcaveSpectrum : Prop :=
  ∀ r : ℕ, 1 ≤ r → r < Fintype.card X → spec G X (r - 1) * spec G X (r + 1) ≤ spec G X r ^ 2

/-- Reindexed form of log-concavity, free of truncated subtraction. -/
theorem logConcaveSpectrum_iff :
    LogConcaveSpectrum G X ↔
      ∀ k : ℕ, k + 2 ≤ Fintype.card X →
        spec G X k * spec G X (k + 2) ≤ spec G X (k + 1) ^ 2 := by
  constructor
  · intro h k hk
    have := h (k + 1) (by omega) (by omega)
    simpa using this
  · intro h r h1 h2
    obtain ⟨k, rfl⟩ : ∃ k, r = k + 1 := ⟨r - 1, by omega⟩
    simpa using h k (by omega)

/-! ## A genuine positive instance: the trivial action -/

/-- For the trivial action the spectrum is the binomial row `C(n,r)`, which *is* log-concave. -/
theorem logConcave_of_trivial_action (htriv : ∀ (g : G) (x : X), g • x = x) :
    LogConcaveSpectrum G X := by
  rw [logConcaveSpectrum_iff]
  intro k _
  rw [spec_of_trivial_action htriv, spec_of_trivial_action htriv, spec_of_trivial_action htriv]
  exact Nat.choose_mul_choose_le_choose_sq _ _

/-- The symmetric group acts set-transitively, hence log-concavely (with equality `1 = 1`). -/
theorem logConcave_perm : LogConcaveSpectrum (Equiv.Perm X) X := by
  rw [logConcaveSpectrum_iff]
  intro k hk
  rw [spec_perm_eq_one (by omega), spec_perm_eq_one (by omega), spec_perm_eq_one (by omega)]
  norm_num

/-! ## The guarded universal version, valid for every finite action -/

/-- **Quantitative repair of the conjecture.**  For every finite action and every `r ≥ 1`,
`t_{r-1} · t_{r+1} ≤ |G|² · t_r²`.  The proof sandwiches the spectrum between
`C(n,r)/|G|` and `C(n,r)` and then uses log-concavity of the binomial row. -/
theorem spec_mul_spec_le_card_sq_mul_spec_sq (r : ℕ) (hr : 1 ≤ r) :
    spec G X (r - 1) * spec G X (r + 1) ≤ (Fintype.card G) ^ 2 * spec G X r ^ 2 := by
  obtain ⟨k, rfl⟩ : ∃ k, r = k + 1 := ⟨r - 1, by omega⟩
  simp only [Nat.add_sub_cancel]
  set n := Fintype.card X
  calc spec G X k * spec G X (k + 2)
      ≤ n.choose k * n.choose (k + 2) :=
        Nat.mul_le_mul (spec_le_choose k) (spec_le_choose (k + 2))
    _ ≤ (n.choose (k + 1)) ^ 2 := Nat.choose_mul_choose_le_choose_sq n k
    _ ≤ (Fintype.card G * spec G X (k + 1)) ^ 2 := by
        exact Nat.pow_le_pow_left (choose_le_card_mul_spec (k + 1)) 2
    _ = (Fintype.card G) ^ 2 * spec G X (k + 1) ^ 2 := by ring

/-! ## The collapse theorem: log-concavity forces the spectrum to be constantly `1` -/

/-- **Propagation of the value `1`.**  If two consecutive spectrum values are `1` and the
spectrum is log-concave from that point on, then *all* subsequent values are `1`.
This is the engine behind the rigidity statement below. -/
theorem spec_eq_one_of_logConcave {m : ℕ} (hm : spec G X m = 1) (hm1 : spec G X (m + 1) = 1)
    (hlc : LogConcaveSpectrum G X) :
    ∀ r : ℕ, m ≤ r → r ≤ Fintype.card X → spec G X r = 1 := by
  rw [logConcaveSpectrum_iff] at hlc
  -- two-step induction: the pair `(t_{m+j}, t_{m+j+1})` stays `(1,1)`
  have key : ∀ j : ℕ, m + j ≤ Fintype.card X →
      spec G X (m + j) = 1 ∧ (m + j + 1 ≤ Fintype.card X → spec G X (m + j + 1) = 1) := by
    intro j
    induction j with
    | zero => intro _; exact ⟨by simpa using hm, fun _ => by simpa using hm1⟩
    | succ j ih =>
        intro hj
        have hj' : m + j ≤ Fintype.card X := by omega
        obtain ⟨h0, h1⟩ := ih hj'
        have h1' : spec G X (m + j + 1) = 1 := h1 (by omega)
        have e1 : m + (j + 1) = m + j + 1 := by omega
        rw [e1, show m + j + 1 + 1 = m + j + 2 from by omega]
        refine ⟨h1', ?_⟩
        intro _
        have hlc' := hlc (m + j) (by omega)
        rw [h0, h1'] at hlc'
        have hpos : 0 < spec G X (m + j + 2) := spec_pos (by omega)
        have hle : spec G X (m + j + 2) ≤ 1 := by
          calc spec G X (m + j + 2) = 1 * spec G X (m + j + 2) := (one_mul _).symm
            _ ≤ 1 ^ 2 := hlc'
            _ = 1 := one_pow 2
        omega
  intro r hmr hrn
  obtain ⟨j, rfl⟩ : ∃ j, r = m + j := ⟨r - m, by omega⟩
  exact (key j hrn).1

/-- **Rigidity.**  For a transitive action, log-concavity of the subset spectrum is
*equivalent* to set-transitivity: `G` is transitive on `r`-element subsets for every `r`.
In particular the mission conjecture can only hold for the extremely rare set-transitive
permutation groups. -/
theorem logConcave_iff_setTransitive (htrans : spec G X 1 = 1) :
    LogConcaveSpectrum G X ↔ ∀ r : ℕ, r ≤ Fintype.card X → spec G X r = 1 := by
  constructor
  · intro hlc r hr
    rcases Nat.eq_zero_or_pos (Fintype.card X) with hn | hn
    · have : r = 0 := by omega
      simp [this]
    · exact spec_eq_one_of_logConcave (m := 0) (by simp) (by simpa using htrans) hlc r (by omega) hr
  · intro h
    rw [logConcaveSpectrum_iff]
    intro k hk
    rw [h k (by omega), h (k + 1) (by omega), h (k + 2) (by omega)]
    norm_num

/-- A transitive log-concave action forces the acting group to be enormous:
`C(n,r) ≤ |G|` for every `r ≤ n` (so `|G| ≥ C(n, ⌊n/2⌋)`). -/
theorem choose_le_card_of_transitive_logConcave (htrans : spec G X 1 = 1)
    (hlc : LogConcaveSpectrum G X) (r : ℕ) (hr : r ≤ Fintype.card X) :
    (Fintype.card X).choose r ≤ Fintype.card G := by
  have h1 : spec G X r = 1 := (logConcave_iff_setTransitive htrans).1 hlc r hr
  have := choose_le_card_mul_spec (G := G) (X := X) r
  rwa [h1, mul_one] at this

/-- **Cardinality obstruction.**  A transitive action of a group that is smaller than some
binomial coefficient `C(n,r)` cannot have a log-concave spectrum. -/
theorem not_logConcave_of_card_lt_choose (htrans : spec G X 1 = 1) {r : ℕ}
    (hr : r ≤ Fintype.card X) (hcard : Fintype.card G < (Fintype.card X).choose r) :
    ¬ LogConcaveSpectrum G X := by
  intro hlc
  exact absurd (choose_le_card_of_transitive_logConcave htrans hlc r hr) (by omega)

/-- **An infinite family of counterexamples.**  Every *regular* action (transitive with
`|G| = |X|`, e.g. any group acting on itself by translation) on `n ≥ 4` points has a
spectrum that is **not** log-concave.  The cyclic counterexample `C₄` below is the case
`n = 4`. -/
theorem not_logConcave_of_regular (htrans : spec G X 1 = 1)
    (hreg : Fintype.card G = Fintype.card X) (hn : 4 ≤ Fintype.card X) :
    ¬ LogConcaveSpectrum G X := by
  have key : ∀ n : ℕ, 4 ≤ n → n < n.choose 2 := by
    intro n hn
    rw [Nat.choose_two_right]
    have h : (n + 1) * 2 ≤ n * (n - 1) := by
      obtain ⟨m, rfl⟩ : ∃ m, n = m + 4 := ⟨n - 4, by omega⟩
      have hm : m + 4 - 1 = m + 3 := by omega
      rw [hm]
      nlinarith
    have := (Nat.le_div_iff_mul_le (by norm_num : 0 < 2)).2 h
    omega
  exact not_logConcave_of_card_lt_choose htrans (r := 2) (by omega)
    (by rw [hreg]; exact key _ hn)

/-- Contrapositive form: a transitive action which is not `2`-homogeneous is **not**
log-concave.  (This is the generic situation, whence the failure of the conjecture.) -/
theorem not_logConcave_of_transitive_of_two_le_spec_two (htrans : spec G X 1 = 1)
    (h2 : 2 ≤ spec G X 2) (hn : 2 ≤ Fintype.card X) : ¬ LogConcaveSpectrum G X := by
  intro hlc
  have := (logConcave_iff_setTransitive htrans).1 hlc 2 hn
  omega

end SubsetSpectrum

/-! ## Counterexamples: the regular actions of cyclic groups -/

/-- The cyclic group of order `n`, written multiplicatively, acting on `ZMod n` by
translation (the regular action). -/
abbrev Cyc (n : ℕ) := Multiplicative (ZMod n)

instance (n : ℕ) : SMul (Cyc n) (ZMod n) := ⟨fun g x => Multiplicative.toAdd g + x⟩

instance (n : ℕ) : MulAction (Cyc n) (ZMod n) where
  one_smul x := by change (0 : ZMod n) + x = x; ring
  mul_smul g h x := by
    change (Multiplicative.toAdd g + Multiplicative.toAdd h) + x = _
    change _ = Multiplicative.toAdd g + (Multiplicative.toAdd h + x)
    ring

/-- The cyclic group of order `4`. -/
abbrev C4 := Cyc 4

namespace SubsetSpectrum
namespace Cyc

variable (n : ℕ) [NeZero n]

/-- The translation action of `C_n` on `n` points is transitive. -/
theorem spec_one : spec (Cyc n) (ZMod n) 1 = 1 := by
  have : Nonempty (ZMod n) := ⟨0⟩
  rw [spec_one_eq_one_iff_pretransitive]
  intro x y
  exact ⟨Multiplicative.ofAdd (y - x), by
    show (y - x) + x = y
    ring⟩

/-- **An infinite family of counterexamples.**  For every `n ≥ 4` the spectrum of the
regular action of the cyclic group `C_n` on `n` points fails to be log-concave. -/
theorem not_logConcaveSpectrum (hn : 4 ≤ n) : ¬ LogConcaveSpectrum (Cyc n) (ZMod n) := by
  have hcardX : Fintype.card (ZMod n) = n := ZMod.card n
  have hcardG : Fintype.card (Cyc n) = n :=
    (Fintype.card_congr (Multiplicative.ofAdd (α := ZMod n))).symm.trans hcardX
  refine not_logConcave_of_regular (spec_one n) ?_ ?_
  · rw [hcardG, hcardX]
  · rw [hcardX]; exact hn

end Cyc

namespace C4

/-- The spectrum of the regular action of `C₄` on four points is `(1, 1, 2, 1, 1)`:
the three types of `2`-subsets collapse to two orbits ("adjacent" and "opposite" pairs
on the 4-cycle). -/
theorem spec_values :
    spec C4 (ZMod 4) 0 = 1 ∧ spec C4 (ZMod 4) 1 = 1 ∧ spec C4 (ZMod 4) 2 = 2 ∧
      spec C4 (ZMod 4) 3 = 1 ∧ spec C4 (ZMod 4) 4 = 1 := by
  refine ⟨by decide, by decide, by decide, by decide, by decide⟩

/-- The regular action of `C₄` on `4` points is transitive but not `2`-homogeneous. -/
theorem transitive_not_two_homogeneous :
    spec C4 (ZMod 4) 1 = 1 ∧ 2 ≤ spec C4 (ZMod 4) 2 := by
  refine ⟨by decide, by decide⟩

/-- **Refutation of the conjecture at `r = 1`**: `t_1² = 1 < 2 = t_0 · t_2`. -/
theorem not_logConcave_at_one :
    ¬ (spec C4 (ZMod 4) (1 - 1) * spec C4 (ZMod 4) (1 + 1) ≤ spec C4 (ZMod 4) 1 ^ 2) := by
  decide

/-- The spectrum of `C₄` acting on four points is **not** log-concave. -/
theorem not_logConcaveSpectrum : ¬ LogConcaveSpectrum C4 (ZMod 4) := by
  intro h
  exact not_logConcave_at_one (h 1 (by norm_num) (by decide))

end C4

/-- **The mission conjecture is false.**  There is no theorem asserting log-concavity of the
subset spectrum for all finite actions: `C₄` acting on `4` points is a counterexample
(and, by `SubsetSpectrum.Cyc.not_logConcaveSpectrum`, so is every larger cyclic group). -/
theorem not_forall_logConcaveSpectrum :
    ¬ (∀ (G X : Type) [Group G] [Fintype G] [DecidableEq X] [Fintype X] [MulAction G X],
        LogConcaveSpectrum G X) := by
  intro h
  exact C4.not_logConcaveSpectrum (h C4 (ZMod 4))

end SubsetSpectrum