/-
# The general (reducible) tropical Perron–Frobenius theorem

`TropicalIrreducible.lean` proves that an **irreducible** max-plus matrix with `⊥ = −∞`
entries has a finite eigenvector, and refutes the converse.  This file gives the exact
characterisation, with no connectivity hypothesis at all:

> `A : Matrix ι ι (WithBot ℝ)` has a finite eigenvector for the eigenvalue `lam`
> **iff**
> (a) every closed walk in the support digraph has mean weight at most `lam`
>     (`AllSuppCyclesLe`), and
> (b) every vertex is joined by a support walk to a vertex lying on a closed support walk
>     of mean weight exactly `lam` — a *critical node* (`ReachesCritical`).

This is `tropEigenBot_iff_criticalReachable`.  It contains the irreducible case (there
every vertex reaches every other, and a critical cycle exists) and explains the
counterexample `diag(0,0)` of the previous file (each of the two vertices carries its own
critical loop, so (b) holds even though the digraph is disconnected).

The construction of the eigenvector is a *critical potential*: `v j` is the largest weight
of a normalised support walk from `j` to a critical node.  Two devices make it usable in
Lean:

* walks are cut down to length `≤ n = |ι|` by `exists_short_suppWalk_ge`, an excision
  lemma that preserves the support and does not decrease the weight (the excised closed
  sub-walks have nonpositive normalised weight by (a));
* the maximum is taken over the finite index set `range n ×ˢ univ` of the *penalised*
  matrix `normApprox A lam` (each `⊥` is replaced by a large negative number).  A separate
  estimate shows the penalty is so large that the optimal walk never uses a `⊥` position,
  so the penalised optimum is genuinely a maximum over support walks.
-/
import Mathlib
import Algebra.TropicalLinearAlgebra.TropicalIrreducible

namespace TropicalLA

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-! ## Critical nodes and the two conditions -/

section Defs

variable (A : Matrix ι ι (WithBot ℝ)) (lam : ℝ)

/-- A **critical node**: a vertex lying on a closed support walk of mean weight `lam`. -/
def IsCriticalNode (c : ι) : Prop :=
  ∃ (m : ℕ) (p : ℕ → ι), 0 < m ∧ p 0 = c ∧ p m = c ∧ IsSuppWalk A p m ∧
    pathWeight (finPart A) p m = m * lam

/-- Condition (a): no closed support walk beats the mean `lam`. -/
def AllSuppCyclesLe : Prop :=
  ∀ (m : ℕ) (p : ℕ → ι), IsSuppWalk A p m → p m = p 0 → pathWeight (finPart A) p m ≤ m * lam

/-- Condition (b): every vertex has access to the critical graph. -/
def ReachesCritical : Prop :=
  ∀ i, ∃ (m : ℕ) (p : ℕ → ι), 0 < m ∧ p 0 = i ∧ IsSuppWalk A p m ∧ IsCriticalNode A lam (p m)

end Defs

variable {A : Matrix ι ι (WithBot ℝ)} {lam : ℝ}

/-! ## Necessity of the two conditions -/

omit [Nonempty ι] in
theorem allSuppCyclesLe_of_isTropEigenBot {v : ι → ℝ} (h : IsTropEigenBot A lam v) :
    AllSuppCyclesLe A lam := fun _ _ hw hc => h.suppCycle_le hw hc

omit [Fintype ι] [Nonempty ι] in
/-- Telescoping along an orbit of a tight-successor function. -/
theorem tightOrbit_pathWeight {v : ι → ℝ} {f : ι → ι}
    (hf : ∀ i, finPart A i (f i) = lam + v i - v (f i)) (x : ι) (m : ℕ) :
    pathWeight (finPart A) (fun t => f^[t] x) m = m * lam + v x - v (f^[m] x) := by
  induction m with
  | zero => rw [pathWeight]; simp
  | succ m ih =>
      have hsplit : pathWeight (finPart A) (fun t => f^[t] x) (m + 1)
          = pathWeight (finPart A) (fun t => f^[t] x) m
            + finPart A (f^[m] x) (f^[m + 1] x) := by
        rw [pathWeight, pathWeight, Finset.sum_range_succ]
      have hstep : f^[m + 1] x = f (f^[m] x) := by rw [Function.iterate_succ_apply']
      rw [hsplit, ih, hstep, hf (f^[m] x)]
      push_cast
      ring

/-- Every vertex reaches a critical node: follow the tight successors until the orbit
closes up. -/
theorem reachesCritical_of_isTropEigenBot {v : ι → ℝ} (h : IsTropEigenBot A lam v) :
    ReachesCritical A lam := by
  classical
  choose f hfsupp hf using h.exists_tight
  have hf' : ∀ i, finPart A i (f i) = lam + v i - v (f i) := by
    intro i; have := hf i; linarith
  intro i
  obtain ⟨a, b, hab, hfab⟩ : ∃ a b : ℕ, a < b ∧ f^[a] i = f^[b] i := by
    obtain ⟨x, y, hxy, hfxy⟩ := Finite.exists_ne_map_eq_of_infinite (fun n : ℕ => f^[n] i)
    rcases lt_or_gt_of_ne hxy with hlt | hlt
    · exact ⟨x, y, hlt, hfxy⟩
    · exact ⟨y, x, hlt, hfxy.symm⟩
  have horbitSupp : ∀ (x : ι) (m : ℕ), IsSuppWalk A (fun t => f^[t] x) m := by
    intro x m t _
    have : f^[t + 1] x = f (f^[t] x) := by rw [Function.iterate_succ_apply']
    simp only [this]
    exact hfsupp _
  refine ⟨b, fun t => f^[t] i, by omega, by simp, horbitSupp i b, ?_⟩
  -- `f^[b] i = f^[a] i` lies on a closed support walk of mean `lam`
  show IsCriticalNode A lam (f^[b] i)
  have hclosed : f^[b - a] (f^[b] i) = f^[b] i := by
    rw [← hfab, ← Function.iterate_add_apply, show b - a + a = b by omega]
    exact hfab.symm
  refine ⟨b - a, fun t => f^[t] (f^[b] i), by omega, by simp, by simpa using hclosed,
    horbitSupp _ (b - a), ?_⟩
  rw [tightOrbit_pathWeight hf' (f^[b] i) (b - a), hclosed]
  ring

/-! ## Excision preserving the support -/

omit [Nonempty ι] in
/-- **Support-preserving shortening.**  If every closed support walk has nonpositive
`B`-weight, every support walk is dominated by a support walk of length at most
`n = |ι|` with the same endpoints. -/
theorem exists_short_suppWalk_ge {B : Matrix ι ι ℝ}
    (hcyc : ∀ (m : ℕ) (c : ℕ → ι), IsSuppWalk A c m → c m = c 0 → pathWeight B c m ≤ 0) :
    ∀ (m : ℕ), 0 < m → ∀ (p : ℕ → ι), IsSuppWalk A p m →
      ∃ (m' : ℕ) (q : ℕ → ι), 0 < m' ∧ m' ≤ Fintype.card ι ∧ q 0 = p 0 ∧ q m' = p m ∧
        IsSuppWalk A q m' ∧ pathWeight B p m ≤ pathWeight B q m' := by
  intro m
  induction m using Nat.strong_induction_on with
  | _ m ih =>
    intro hm p hw
    by_cases hmn : m ≤ Fintype.card ι
    · exact ⟨m, p, hm, hmn, rfl, rfl, hw, le_rfl⟩
    · push_neg at hmn
      obtain ⟨a, b, hab, hbn, hpab⟩ := exists_repeat p
      have hbm : b ≤ m := le_of_lt (lt_of_le_of_lt hbn hmn)
      have hsplit := pathWeight_excise B p hab hbm hpab
      set d := b - a with hd
      have hd0 : 0 < d := by omega
      have hdm : d < m := by omega
      set q : ℕ → ι := fun t => if t < a then p t else p (t + d) with hq
      have hqle : ∀ t, t ≤ a → q t = p t := by
        intro t ht
        rcases lt_or_eq_of_le ht with h | h
        · simp [hq, h]
        · subst h
          simp only [hq, lt_irrefl, if_false]
          rw [show t + d = b by omega, ← hpab]
      have hqge : ∀ t, a ≤ t → q t = p (t + d) := by
        intro t ht
        rcases lt_or_eq_of_le ht with h | h
        · simp [hq, Nat.not_lt.mpr (le_of_lt h)]
        · subst h; simp [hq]
      have hq0 : q 0 = p 0 := hqle 0 (Nat.zero_le a)
      have hqend : q (m - d) = p m := by
        rw [hqge (m - d) (by omega), show m - d + d = m by omega]
      have hwq : IsSuppWalk A q (m - d) := by
        intro t ht
        rcases Nat.lt_or_ge t a with h | h
        · rw [hqle t (le_of_lt h), hqle (t + 1) (by omega)]
          exact hw t (by omega)
        · rw [hqge t h, hqge (t + 1) (by omega), show t + 1 + d = (t + d) + 1 by omega]
          exact hw (t + d) (by omega)
      have hwcyc : IsSuppWalk A (fun t => p (a + t)) d := by
        intro t ht
        have : a + (t + 1) = (a + t) + 1 := by omega
        simp only [this]
        exact hw (a + t) (by omega)
      have hcycle : pathWeight B (fun t => p (a + t)) d ≤ 0 := by
        refine hcyc d _ hwcyc ?_
        show p (a + d) = p (a + 0)
        rw [show a + d = b by omega, show a + 0 = a by omega, hpab]
      obtain ⟨m', r, h1, h2, h3, h4, h5, h6⟩ := ih (m - d) (by omega) (by omega) q hwq
      exact ⟨m', r, h1, h2, by rw [h3, hq0], by rw [h4, hqend], h5, by linarith⟩

/-! ## The penalised normalised matrix -/

section Penalty

variable (A lam)

/-- A crude bound on all the data of `(A, lam)`, at least `1`. -/
noncomputable def spreadAbs : ℝ := |entryMax A| + |entryMin A| + 2 * |lam| + 1

/-- The penalty replacing `⊥` in the normalised matrix. -/
noncomputable def penaltyN : ℝ := 2 * Fintype.card ι * spreadAbs A lam + 1

open Classical in
/-- The normalised matrix `A − lam` with `⊥` replaced by a large negative penalty. -/
noncomputable def normApprox : Matrix ι ι ℝ :=
  fun i j => if A i j = ⊥ then -penaltyN A lam else finPart A i j - lam

variable {A lam}

theorem one_le_spreadAbs : 1 ≤ spreadAbs A lam := by
  have h1 : (0 : ℝ) ≤ |entryMax A| := abs_nonneg _
  have h2 : (0 : ℝ) ≤ |entryMin A| := abs_nonneg _
  have h3 : (0 : ℝ) ≤ |lam| := abs_nonneg _
  rw [spreadAbs]; linarith

theorem penaltyN_pos : 0 < penaltyN A lam := by
  have h := one_le_spreadAbs (A := A) (lam := lam)
  have hc : (1 : ℝ) ≤ (Fintype.card ι : ℝ) := by
    exact_mod_cast Fintype.card_pos (α := ι)
  rw [penaltyN]
  nlinarith

theorem normApprox_of_supp {i j : ι} (h : A i j ≠ ⊥) :
    normApprox A lam i j = finPart A i j - lam := by
  rw [normApprox]; simp [h]

theorem normApprox_of_bot {i j : ι} (h : A i j = ⊥) :
    normApprox A lam i j = -penaltyN A lam := by
  rw [normApprox]; simp [h]

theorem normApprox_le (i j : ι) : normApprox A lam i j ≤ spreadAbs A lam := by
  by_cases h : A i j = ⊥
  · rw [normApprox_of_bot h]
    have := penaltyN_pos (A := A) (lam := lam)
    have := one_le_spreadAbs (A := A) (lam := lam)
    linarith
  · rw [normApprox_of_supp h]
    have h1 : finPart A i j ≤ entryMax A := le_entryMax i j
    have h2 : entryMax A ≤ |entryMax A| := le_abs_self _
    have h3 : -lam ≤ |lam| := neg_le_abs _
    have h4 : (0 : ℝ) ≤ |entryMin A| := abs_nonneg _
    have h5 : (0 : ℝ) ≤ |lam| := abs_nonneg _
    rw [spreadAbs]
    linarith

theorem neg_spreadAbs_le_normApprox {i j : ι} (h : A i j ≠ ⊥) :
    -spreadAbs A lam ≤ normApprox A lam i j := by
  rw [normApprox_of_supp h]
  have h1 : entryMin A ≤ finPart A i j := entryMin_le i j
  have h2 : -|entryMin A| ≤ entryMin A := neg_abs_le _
  have h3 : -|lam| ≤ -lam := by
    have := le_abs_self lam; linarith
  have h4 : (0 : ℝ) ≤ |entryMax A| := abs_nonneg _
  have h5 : (0 : ℝ) ≤ |lam| := abs_nonneg _
  rw [spreadAbs]
  linarith

/-- On a support walk the penalised matrix computes the normalised weight. -/
theorem pathWeight_normApprox_supp {p : ℕ → ι} {m : ℕ} (hw : IsSuppWalk A p m) :
    pathWeight (normApprox A lam) p m = pathWeight (finPart A) p m - m * lam := by
  rw [pathWeight, pathWeight]
  rw [Finset.sum_congr rfl (fun t ht => normApprox_of_supp (hw t (Finset.mem_range.mp ht)))]
  simp [Finset.sum_sub_distrib, mul_comm]

theorem neg_le_pathWeight_normApprox {p : ℕ → ι} {m : ℕ} (hw : IsSuppWalk A p m) :
    -((m : ℝ) * spreadAbs A lam) ≤ pathWeight (normApprox A lam) p m := by
  rw [pathWeight]
  calc -((m : ℝ) * spreadAbs A lam) = ∑ _t ∈ Finset.range m, -spreadAbs A lam := by
        simp [Finset.sum_const]
    _ ≤ ∑ t ∈ Finset.range m, normApprox A lam (p t) (p (t + 1)) :=
        Finset.sum_le_sum fun t ht => neg_spreadAbs_le_normApprox (hw t (Finset.mem_range.mp ht))

theorem pathWeight_normApprox_le (p : ℕ → ι) (m : ℕ) :
    pathWeight (normApprox A lam) p m ≤ (m : ℝ) * spreadAbs A lam := by
  rw [pathWeight]
  calc ∑ t ∈ Finset.range m, normApprox A lam (p t) (p (t + 1))
      ≤ ∑ _t ∈ Finset.range m, spreadAbs A lam := Finset.sum_le_sum fun t _ => normApprox_le _ _
    _ = (m : ℝ) * spreadAbs A lam := by simp [Finset.sum_const]

/-- **The penalty bites.**  A short walk that uses a `⊥` position has weight strictly below
the guaranteed weight of any short support walk. -/
theorem pathWeight_normApprox_lt_of_bot {p : ℕ → ι} {m t : ℕ} (hmn : m ≤ Fintype.card ι)
    (ht : t < m) (hbot : A (p t) (p (t + 1)) = ⊥) :
    pathWeight (normApprox A lam) p m < -((Fintype.card ι : ℝ) * spreadAbs A lam) := by
  classical
  have hE := one_le_spreadAbs (A := A) (lam := lam)
  have hsplit : pathWeight (normApprox A lam) p m =
      (∑ s ∈ (Finset.range m).erase t, normApprox A lam (p s) (p (s + 1)))
        + normApprox A lam (p t) (p (t + 1)) := by
    rw [pathWeight, ← Finset.sum_erase_add _ _ (Finset.mem_range.mpr ht)]
  have hrest : (∑ s ∈ (Finset.range m).erase t, normApprox A lam (p s) (p (s + 1)))
      ≤ ((m : ℝ) - 1) * spreadAbs A lam := by
    have hcard : ((Finset.range m).erase t).card = m - 1 := by
      rw [Finset.card_erase_of_mem (Finset.mem_range.mpr ht), Finset.card_range]
    calc (∑ s ∈ (Finset.range m).erase t, normApprox A lam (p s) (p (s + 1)))
        ≤ ∑ _s ∈ (Finset.range m).erase t, spreadAbs A lam :=
          Finset.sum_le_sum fun s _ => normApprox_le _ _
      _ = ((m : ℕ) - 1 : ℕ) * spreadAbs A lam := by
          rw [Finset.sum_const, hcard, nsmul_eq_mul]
      _ = ((m : ℝ) - 1) * spreadAbs A lam := by
          have : ((m - 1 : ℕ) : ℝ) = (m : ℝ) - 1 := by
            have : 1 ≤ m := by omega
            push_cast [this]; ring
          rw [this]
  rw [hsplit, normApprox_of_bot hbot, penaltyN]
  have hmn' : (m : ℝ) ≤ (Fintype.card ι : ℝ) := by exact_mod_cast hmn
  nlinarith [hE, hmn']

end Penalty

/-! ## The critical potential -/

section Potential

open Classical in
/-- `critPotential A lam c₀ j` is the maximal weight, in the penalised normalised matrix,
of a walk of length between `1` and `n` from `j` to a critical node (`c₀` is a default
critical node used to keep the index set rectangular). -/
noncomputable def critPotential (A : Matrix ι ι (WithBot ℝ)) (lam : ℝ) (c₀ j : ι) : ℝ :=
  ((Finset.range (Fintype.card ι)) ×ˢ (Finset.univ : Finset ι)).sup' cycleIndex_nonempty
    (fun q => tpow (normApprox A lam) q.1 j (if IsCriticalNode A lam q.2 then q.2 else c₀))

theorem le_critPotential {c₀ j c : ι} {k : ℕ} (hk : k < Fintype.card ι)
    (hc : IsCriticalNode A lam c) :
    tpow (normApprox A lam) k j c ≤ critPotential A lam c₀ j := by
  classical
  have hmem : (k, c) ∈ (Finset.range (Fintype.card ι)) ×ˢ (Finset.univ : Finset ι) := by
    simp [Finset.mem_product, hk]
  have := Finset.le_sup'
    (f := fun q : ℕ × ι =>
      tpow (normApprox A lam) q.1 j (if IsCriticalNode A lam q.2 then q.2 else c₀)) hmem
  simpa [hc, critPotential] using this

theorem exists_eq_critPotential {c₀ : ι} (hc₀ : IsCriticalNode A lam c₀) (j : ι) :
    ∃ (k : ℕ) (c : ι), k < Fintype.card ι ∧ IsCriticalNode A lam c ∧
      critPotential A lam c₀ j = tpow (normApprox A lam) k j c := by
  classical
  obtain ⟨q, hq, hval⟩ := Finset.exists_mem_eq_sup' (cycleIndex_nonempty (ι := ι))
    (fun q : ℕ × ι => tpow (normApprox A lam) q.1 j
      (if IsCriticalNode A lam q.2 then q.2 else c₀))
  rw [Finset.mem_product, Finset.mem_range] at hq
  by_cases hcrit : IsCriticalNode A lam q.2
  · exact ⟨q.1, q.2, hq.1, hcrit, by rw [critPotential, hval]; simp [hcrit]⟩
  · exact ⟨q.1, c₀, hq.1, hc₀, by rw [critPotential, hval]; simp [hcrit]⟩

end Potential

/-! ## Sufficiency of the two conditions -/

section Sufficiency

variable (hle : AllSuppCyclesLe A lam) (hreach : ReachesCritical A lam)

include hle in
theorem suppCycle_normApprox_nonpos :
    ∀ (m : ℕ) (c : ℕ → ι), IsSuppWalk A c m → c m = c 0 →
      pathWeight (normApprox A lam) c m ≤ 0 := by
  intro m c hw hc
  rw [pathWeight_normApprox_supp hw]
  have := hle m c hw hc
  linarith

/-- The optimal short walk realising a value of `critPotential` never uses a `⊥` position,
provided the value is not too small. -/
theorem isSuppWalk_of_pathWeight_ge {p : ℕ → ι} {m : ℕ} (hmn : m ≤ Fintype.card ι)
    (hge : -((Fintype.card ι : ℝ) * spreadAbs A lam) ≤ pathWeight (normApprox A lam) p m) :
    IsSuppWalk A p m := by
  intro t ht hbot
  have := pathWeight_normApprox_lt_of_bot (A := A) (lam := lam) hmn ht hbot
  linarith

include hle hreach in
/-- Lower bound for the critical potential: every vertex reaches a critical node along a
short support walk. -/
theorem neg_le_critPotential (c₀ : ι) (j : ι) :
    -((Fintype.card ι : ℝ) * spreadAbs A lam) ≤ critPotential A lam c₀ j := by
  obtain ⟨m, p, hm, hp0, hw, hcrit⟩ := hreach j
  obtain ⟨m', q, hm'0, hm'n, hq0, hqend, hwq, -⟩ :=
    exists_short_suppWalk_ge (B := normApprox A lam) (suppCycle_normApprox_nonpos hle) m hm p hw
  obtain ⟨k, rfl⟩ : ∃ k, m' = k + 1 := ⟨m' - 1, by omega⟩
  have hlow := neg_le_pathWeight_normApprox (lam := lam) hwq
  have hle' : pathWeight (normApprox A lam) q (k + 1) ≤ tpow (normApprox A lam) k j (q (k + 1)) :=
    (tpow_isGreatest (normApprox A lam) k j (q (k + 1))).2 ⟨q, by rw [hq0, hp0], rfl, rfl⟩
  have hcrit' : IsCriticalNode A lam (q (k + 1)) := by rw [hqend]; exact hcrit
  have hpot := le_critPotential (c₀ := c₀) (j := j) (by omega : k < Fintype.card ι) hcrit'
  have hcast : ((k + 1 : ℕ) : ℝ) ≤ (Fintype.card ι : ℝ) := by exact_mod_cast hm'n
  have hE := one_le_spreadAbs (A := A) (lam := lam)
  nlinarith [hlow, hle', hpot]

include hle hreach in
/-- The optimal walk realising the critical potential is a support walk. -/
theorem exists_suppWalk_eq_critPotential {c₀ : ι} (hc₀ : IsCriticalNode A lam c₀) (j : ι) :
    ∃ (m : ℕ) (p : ℕ → ι) (c : ι), 0 < m ∧ m ≤ Fintype.card ι ∧ p 0 = j ∧ p m = c ∧
      IsCriticalNode A lam c ∧ IsSuppWalk A p m ∧
      critPotential A lam c₀ j = pathWeight (normApprox A lam) p m := by
  obtain ⟨k, c, hk, hc, hval⟩ := exists_eq_critPotential hc₀ j
  obtain ⟨p, hp0, hpk, hpw⟩ := (tpow_isGreatest (normApprox A lam) k j c).1
  have hge : -((Fintype.card ι : ℝ) * spreadAbs A lam) ≤ pathWeight (normApprox A lam) p (k + 1) := by
    rw [← hpw, ← hval]
    exact neg_le_critPotential hle hreach c₀ j
  exact ⟨k + 1, p, c, by omega, by omega, hp0, hpk, hc,
    isSuppWalk_of_pathWeight_ge (by omega) hge, by rw [hval, hpw]⟩

include hle hreach in
/-- The defining inequality of an eigenvector, for the critical potential. -/
theorem critPotential_le {c₀ : ι} (hc₀ : IsCriticalNode A lam c₀) {i j : ι} (hij : A i j ≠ ⊥) :
    normApprox A lam i j + critPotential A lam c₀ j ≤ critPotential A lam c₀ i := by
  obtain ⟨m, p, c, hm, hmn, hp0, hpm, hc, hw, hval⟩ :=
    exists_suppWalk_eq_critPotential hle hreach hc₀ j
  -- prepend the edge `i → j`
  set p' : ℕ → ι := fun t => if t = 0 then i else p (t - 1) with hp'
  have hp'0 : p' 0 = i := by simp [hp']
  have hp'succ : ∀ t, p' (t + 1) = p t := by intro t; simp [hp']
  have htailfun : (fun t => p' (t + 1)) = p := funext hp'succ
  have hp'w : pathWeight (normApprox A lam) p' (m + 1)
      = normApprox A lam i j + pathWeight (normApprox A lam) p m := by
    rw [pathWeight_shift (normApprox A lam) p' m, htailfun, hp'0, hp'succ 0, hp0]
  have hp'w' : IsSuppWalk A p' (m + 1) := by
    intro t ht
    rcases Nat.eq_zero_or_pos t with rfl | hpos
    · rw [hp'0, hp'succ 0, hp0]; exact hij
    · obtain ⟨s, rfl⟩ : ∃ s, t = s + 1 := ⟨t - 1, by omega⟩
      rw [hp'succ, hp'succ]
      exact hw s (by omega)
  obtain ⟨m', q, hm'0, hm'n, hq0, hqend, hwq, hqge⟩ :=
    exists_short_suppWalk_ge (B := normApprox A lam) (suppCycle_normApprox_nonpos hle)
      (m + 1) (by omega) p' hp'w'
  obtain ⟨k', rfl⟩ : ∃ k', m' = k' + 1 := ⟨m' - 1, by omega⟩
  have hq_end : q (k' + 1) = c := by rw [hqend]; rw [show m + 1 = m + 1 from rfl]; rw [hp'succ, hpm]
  have hle2 : pathWeight (normApprox A lam) q (k' + 1) ≤ tpow (normApprox A lam) k' i c :=
    (tpow_isGreatest (normApprox A lam) k' i c).2 ⟨q, by rw [hq0, hp'0], hq_end, rfl⟩
  have hpot := le_critPotential (c₀ := c₀) (j := i) (by omega : k' < Fintype.card ι) hc
  rw [hval]
  linarith [hqge, hp'w]

include hle in
/-- A critical node has nonnegative critical potential (its own critical cycle). -/
theorem critPotential_nonneg_of_critical {c₀ : ι} (hc₀ : IsCriticalNode A lam c₀) {c : ι}
    (hc : IsCriticalNode A lam c) : 0 ≤ critPotential A lam c₀ c := by
  obtain ⟨m, p, hm, hp0, hpm, hw, hweight⟩ := hc
  have hzero : pathWeight (normApprox A lam) p m = 0 := by
    rw [pathWeight_normApprox_supp hw, hweight]; ring
  obtain ⟨m', q, hm'0, hm'n, hq0, hqend, hwq, hqge⟩ :=
    exists_short_suppWalk_ge (B := normApprox A lam) (suppCycle_normApprox_nonpos hle) m hm p hw
  obtain ⟨k, rfl⟩ : ∃ k, m' = k + 1 := ⟨m' - 1, by omega⟩
  have hq_end : q (k + 1) = c := by rw [hqend, hpm]
  have hle2 : pathWeight (normApprox A lam) q (k + 1) ≤ tpow (normApprox A lam) k c c :=
    (tpow_isGreatest (normApprox A lam) k c c).2 ⟨q, by rw [hq0, hp0], hq_end, rfl⟩
  have hpot := le_critPotential (c₀ := c₀) (j := c) (by omega : k < Fintype.card ι) hc₀
  have hpot2 : tpow (normApprox A lam) k c c ≤ critPotential A lam c₀ c :=
    le_critPotential (by omega : k < Fintype.card ι) ⟨m, p, hm, hp0, hpm, hw, hweight⟩
  linarith [hqge, hzero]

include hle hreach in
/-- Tightness: in every row the critical potential attains its bound, at a support edge. -/
theorem exists_tight_critPotential {c₀ : ι} (hc₀ : IsCriticalNode A lam c₀) (i : ι) :
    ∃ j, A i j ≠ ⊥ ∧
      normApprox A lam i j + critPotential A lam c₀ j = critPotential A lam c₀ i := by
  obtain ⟨m, p, c, hm, hmn, hp0, hpm, hc, hw, hval⟩ :=
    exists_suppWalk_eq_critPotential hle hreach hc₀ i
  refine ⟨p 1, ?_, ?_⟩
  · have := hw 0 hm
    rwa [hp0] at this
  · have hedge : A i (p 1) ≠ ⊥ := by have := hw 0 hm; rwa [hp0] at this
    have hup := critPotential_le hle hreach hc₀ hedge
    refine le_antisymm hup ?_
    obtain ⟨k, rfl⟩ : ∃ k, m = k + 1 := ⟨m - 1, by omega⟩
    have hsplit : pathWeight (normApprox A lam) p (k + 1)
        = normApprox A lam i (p 1) + pathWeight (normApprox A lam) (fun t => p (t + 1)) k := by
      rw [pathWeight_shift (normApprox A lam) p k, hp0]
    rcases Nat.eq_zero_or_pos k with rfl | hk
    · -- the optimal walk is the single edge `i → c`
      have hc1 : p 1 = c := hpm
      have hpw : pathWeight (normApprox A lam) p 1 = normApprox A lam i (p 1) := by
        rw [pathWeight, Finset.sum_range_one, hp0]
      have hnn : 0 ≤ critPotential A lam c₀ (p 1) := by
        rw [hc1]; exact critPotential_nonneg_of_critical hle hc₀ hc
      have hup' : normApprox A lam i (p 1) + critPotential A lam c₀ (p 1)
          ≤ critPotential A lam c₀ i := hup
      rw [hval, hpw]
      linarith
    · obtain ⟨k', rfl⟩ : ∃ k', k = k' + 1 := ⟨k - 1, by omega⟩
      have htail : pathWeight (normApprox A lam) (fun t => p (t + 1)) (k' + 1)
          ≤ tpow (normApprox A lam) k' (p 1) c :=
        (tpow_isGreatest (normApprox A lam) k' (p 1) c).2
          ⟨fun t => p (t + 1), rfl, by simpa using hpm, rfl⟩
      have hpot : tpow (normApprox A lam) k' (p 1) c ≤ critPotential A lam c₀ (p 1) :=
        le_critPotential (by omega : k' < Fintype.card ι) hc
      rw [hval, hsplit]
      linarith

include hle hreach in
/-- **Sufficiency.**  Conditions (a) and (b) produce a finite eigenvector. -/
theorem exists_tropEigenBot_of_criticalReachable :
    ∃ v : ι → ℝ, IsTropEigenBot A lam v := by
  obtain ⟨i⟩ := ‹Nonempty ι›
  obtain ⟨m, p, hm, hp0, hw, hc₀⟩ := hreach i
  set c₀ := p m with hc₀def
  refine ⟨critPotential A lam c₀, isTropEigenBot_of (fun a b => ?_) (fun a => ?_)⟩
  · by_cases hbot : A a b = ⊥
    · rw [hbot]; simp
    · rw [← coe_finPart hbot, ← WithBot.coe_add, WithBot.coe_le_coe]
      have := critPotential_le hle hreach hc₀ hbot
      rw [normApprox_of_supp hbot] at this
      linarith
  · obtain ⟨b, hne, hb⟩ := exists_tight_critPotential hle hreach hc₀ a
    refine ⟨b, ?_⟩
    rw [← coe_finPart hne, ← WithBot.coe_add, WithBot.coe_inj]
    rw [normApprox_of_supp hne] at hb
    linarith

end Sufficiency

/-- **The general tropical Perron–Frobenius theorem.**  A max-plus matrix with `⊥` entries
has a finite eigenvector for `lam` exactly when no support cycle beats the mean `lam` and
every vertex has access to a critical node. -/
theorem tropEigenBot_iff_criticalReachable :
    (∃ v : ι → ℝ, IsTropEigenBot A lam v) ↔ AllSuppCyclesLe A lam ∧ ReachesCritical A lam := by
  constructor
  · rintro ⟨v, hv⟩
    exact ⟨allSuppCyclesLe_of_isTropEigenBot hv, reachesCritical_of_isTropEigenBot hv⟩
  · rintro ⟨hle, hreach⟩
    exact exists_tropEigenBot_of_criticalReachable hle hreach

/-! ## A worked reducible example

The general theorem genuinely covers matrices outside the reach of the irreducible one:
`A = [[0, ⊥], [5, ⊥]]` has the sink `0` as its only cycle, so vertex `1` never returns to
itself, yet every vertex reaches the critical loop at `0`. -/

noncomputable def sinkExample : Matrix (Fin 2) (Fin 2) (WithBot ℝ) :=
  fun i j => if j = 0 then (((if i = 0 then 0 else 5 : ℝ)) : WithBot ℝ) else ⊥

theorem sinkExample_supp_iff {i j : Fin 2} : sinkExample i j ≠ ⊥ ↔ j = 0 := by
  constructor
  · intro h
    by_contra hj
    exact h (by simp [sinkExample, hj])
  · intro hj
    simp [sinkExample, hj]

theorem sinkExample_finPart_zero (i : Fin 2) :
    finPart sinkExample i 0 = if i = 0 then 0 else 5 := by
  by_cases h : i = 0 <;> simp [finPart, sinkExample, h]
  rfl

theorem sinkExample_allSuppCyclesLe : AllSuppCyclesLe sinkExample 0 := by
  intro m p hw hc
  rcases Nat.eq_zero_or_pos m with rfl | hm
  · simp [pathWeight]
  have hend : ∀ t, t < m → p (t + 1) = 0 := fun t ht => sinkExample_supp_iff.mp (hw t ht)
  have hp0 : p 0 = 0 := by
    rw [← hc, show m = (m - 1) + 1 by omega]
    exact hend (m - 1) (by omega)
  have hall : ∀ t, t < m → p t = 0 := by
    intro t ht
    rcases Nat.eq_zero_or_pos t with rfl | htp
    · exact hp0
    · rw [show t = (t - 1) + 1 by omega]
      exact hend (t - 1) (by omega)
  have hzero : pathWeight (finPart sinkExample) p m = 0 := by
    rw [pathWeight]
    refine Finset.sum_eq_zero fun t ht => ?_
    have h1 : p t = 0 := hall t (Finset.mem_range.mp ht)
    have h2 : p (t + 1) = 0 := hend t (Finset.mem_range.mp ht)
    rw [h1, h2, sinkExample_finPart_zero]
    simp
  rw [hzero]
  simp

theorem sinkExample_isCriticalNode_zero : IsCriticalNode sinkExample 0 0 := by
  refine ⟨1, fun _ => 0, one_pos, rfl, rfl, ?_, ?_⟩
  · intro t _
    exact sinkExample_supp_iff.mpr rfl
  · rw [pathWeight, Finset.sum_range_one, sinkExample_finPart_zero]
    simp

theorem sinkExample_reachesCritical : ReachesCritical sinkExample 0 := by
  intro i
  refine ⟨1, fun t => if t = 0 then i else 0, one_pos, by simp, ?_, ?_⟩
  · intro t ht
    interval_cases t
    simpa using sinkExample_supp_iff.mpr rfl
  · simpa using sinkExample_isCriticalNode_zero

/-- The example is not irreducible: nothing points back into vertex `1`. -/
theorem sinkExample_not_stronglyConnected : ¬ StronglyConnected sinkExample := by
  intro hSC
  have key : ∀ i j : Fin 2, Relation.TransGen (Supp sinkExample) i j → j = 0 := by
    intro i j h
    induction h with
    | single hij => exact sinkExample_supp_iff.mp hij
    | tail hab hbc ih => exact sinkExample_supp_iff.mp hbc
  exact absurd (key 0 1 (hSC 0 1)) (by decide)

/-- **Non-vacuity of the general theorem**: a matrix that is *not* irreducible but still
has a finite tropical eigenvector, produced by `tropEigenBot_iff_criticalReachable`. -/
theorem sinkExample_exists_tropEigenBot :
    (∃ v : Fin 2 → ℝ, IsTropEigenBot sinkExample 0 v) ∧ ¬ StronglyConnected sinkExample :=
  ⟨tropEigenBot_iff_criticalReachable.mpr
      ⟨sinkExample_allSuppCyclesLe, sinkExample_reachesCritical⟩,
    sinkExample_not_stronglyConnected⟩

end TropicalLA