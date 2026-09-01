import Physics.AttentionKneeSpectrum

/-!
# Rigidity of the multiplicative tax, entropy bounds, and mixed corpora

Third cycle of the NET-75 analysis.  Cycles 1–2 showed that a delay taxes the
knee additively, a root of the decay ratio taxes it multiplicatively, and that
the five measured domains are consistent with one master profile.  The obvious
adversarial question is: *is the exact multiplicative law an artefact of the
geometric model?*  The answer is no — it is rigid.

## Main results

* `multiplicative_rigidity` — if two profiles with strictly increasing
  retention satisfy `k*(A, τ) = m · k*(B, τ)` at **every** gate, then their
  retention curves are related by exact block rescaling,
  `retained A (m·k) = retained B k`.  No assumption of geometric decay is
  used: an exact `×m` tokenizer tax *forces* self-similar retention.
* `ceilDiv_ceilDiv` — taxes compose: applying an `m`-tax then an `m'`-tax is
  exactly an `(m·m')`-tax, so the tax exponents form a multiplicative monoid
  (`kgeom_root_comp`).
* `kstar_ge_of_max_weight` — **min-entropy bound**: a profile whose largest
  attention weight is at most `p` (min-entropy `-log p`) has knee at least
  `τ / p`.  A flat, high-entropy language cannot have a small knee.
* `kstar_mix_bounds` — a mixed corpus (convex combination of two domains) has
  its knee sandwiched between the two domain knees: multilingual mixtures
  cannot beat their best component nor lose to their worst.
-/

namespace Physics.AttentionKnee

open Finset

/-! ## Strictly increasing retention -/

theorem retained_strictMono (w : ℕ → ℝ) (hw : ∀ i, 0 < w i) :
    StrictMono (retained w) := by
  apply strictMono_nat_of_lt_succ
  intro n
  rw [retained_succ]
  linarith [hw n]

theorem retained_pos (w : ℕ → ℝ) (hw : ∀ i, 0 < w i) {k : ℕ} (hk : 0 < k) :
    0 < retained w k := by
  have := retained_strictMono w hw hk
  rwa [retained_zero] at this

/-- With strictly increasing retention, the knee at the gate `retained w k` is
exactly `k`. -/
theorem kstar_retained_self (w : ℕ → ℝ) (hw : ∀ i, 0 < w i) (k : ℕ) :
    kstar w (retained w k) = k := by
  refine kstar_eq w _ le_rfl ?_
  intro j hj
  exact not_le.2 (retained_strictMono w hw hj)

/-- If the gate is unreachable the knee degenerates to `0`. -/
theorem kstar_eq_zero_of_empty (w : ℕ → ℝ) (τ : ℝ)
    (h : {k | τ ≤ retained w k} = ∅) : kstar w τ = 0 := by
  rw [kstar, h]
  exact Nat.sInf_empty

/-! ## Rigidity of the exact multiplicative law -/

/-- **Rigidity.**  Suppose two profiles with strictly increasing retention obey
an exact `×m` knee law at every positive gate.  Then their retention curves
agree after block rescaling: `retained A (m·k) = retained B k`.

In other words, a genuine multiplicative tokenizer tax is not a numerical
coincidence of geometric decay — it forces the taxed language's attention
profile to be an exact `m`-fold *block dilation* of the untaxed one. -/
theorem multiplicative_rigidity {A B : ℕ → ℝ} (hA : ∀ i, 0 < A i) (hB : ∀ i, 0 < B i)
    {m : ℕ} (hm : 0 < m)
    (hlaw : ∀ τ : ℝ, 0 < τ → kstar A τ = m * kstar B τ) {k : ℕ} (hk : 0 < k) :
    retained A (m * k) = retained B k := by
  -- one direction: the gate `retained B k` is met at `m * k` in `A`
  have h1 : retained B k ≤ retained A (m * k) := by
    have hpos : 0 < retained B k := retained_pos B hB hk
    have hkB : kstar B (retained B k) = k := kstar_retained_self B hB k
    have hkA : kstar A (retained B k) = m * k := by
      rw [hlaw _ hpos, hkB]
    have hne : {j | retained B k ≤ retained A j}.Nonempty := by
      rcases Set.eq_empty_or_nonempty {j | retained B k ≤ retained A j} with hemp | h
      · exfalso
        have h0 := kstar_eq_zero_of_empty A (retained B k) hemp
        rw [hkA] at h0
        exact absurd h0 (Nat.mul_pos hm hk).ne'
      · exact h
    have := le_retained_kstar A (retained B k) hne
    rwa [hkA] at this
  -- other direction: the gate `retained A (m * k)` is met at `k` in `B`
  have h2 : retained A (m * k) ≤ retained B k := by
    have hmk : 0 < m * k := Nat.mul_pos hm hk
    have hpos : 0 < retained A (m * k) := retained_pos A hA hmk
    have hkA : kstar A (retained A (m * k)) = m * k := kstar_retained_self A hA _
    have hkB : kstar B (retained A (m * k)) = k := by
      have := hlaw _ hpos
      rw [hkA] at this
      exact (Nat.eq_of_mul_eq_mul_left hm this.symm)
    have hne : {j | retained A (m * k) ≤ retained B j}.Nonempty := by
      rcases Set.eq_empty_or_nonempty {j | retained A (m * k) ≤ retained B j} with hemp | h
      · exfalso
        have := kstar_eq_zero_of_empty B (retained A (m * k)) hemp
        rw [hkB] at this
        omega
      · exact h
    have := le_retained_kstar B (retained A (m * k)) hne
    rwa [hkB] at this
  linarith

/-! ## Composition of taxes -/

/-- Ceiling divisions compose: `⌈⌈B/m⌉/m'⌉ = ⌈B/(m·m')⌉`. -/
theorem ceilDiv_ceilDiv (B : ℕ) {m m' : ℕ} (hm : 0 < m) (hm' : 0 < m') :
    (B ⌈/⌉ m) ⌈/⌉ m' = B ⌈/⌉ (m * m') := by
  have key : ∀ n : ℕ, ((B ⌈/⌉ m) ⌈/⌉ m' ≤ n ↔ B ⌈/⌉ (m * m') ≤ n) := by
    intro n
    rw [ceilDiv_le_iff_le_mul hm', ceilDiv_le_iff_le_mul hm,
      ceilDiv_le_iff_le_mul (Nat.mul_pos hm hm'), Nat.mul_assoc]
  exact le_antisymm ((key _).2 le_rfl) ((key _).1 le_rfl)

/-- **Taxes compose multiplicatively.**  Taxing by exponent `m` and then by
exponent `m'` is exactly taxing by `m · m'`; the tokenizer taxes form a
multiplicative monoid acting on knees. -/
theorem kgeom_root_comp {r t : ℝ} (hr0 : 0 ≤ r) (hr1 : r < 1) (ht : 0 < t)
    {m m' : ℕ} (hm : 0 < m) (hm' : 0 < m') :
    kgeom (r ^ (m * m')) t = (kgeom r t ⌈/⌉ m) ⌈/⌉ m' := by
  rw [kgeom_root hr0 hr1 ht (Nat.mul_pos hm hm'),
    ceilDiv_ceilDiv (kgeom r t) hm hm']

/-! ## A min-entropy lower bound for the knee -/

/-- **Min-entropy bound.**  If no single position carries more than `p` of the
attention mass — equivalently the min-entropy is at least `-log p` — then the
knee is at least `τ / p`.  A flat (high-entropy) domain cannot have a small
knee, whatever its decay shape. -/
theorem kstar_ge_of_max_weight (w : ℕ → ℝ) {p τ : ℝ} (hp : 0 < p)
    (hbdd : ∀ i, w i ≤ p) (hne : {k | τ ≤ retained w k}.Nonempty) :
    τ / p ≤ (kstar w τ : ℝ) := by
  have hgate : τ ≤ retained w (kstar w τ) := le_retained_kstar w τ hne
  have hsum : retained w (kstar w τ) ≤ (kstar w τ : ℝ) * p := by
    have : ∑ i ∈ range (kstar w τ), w i ≤ ∑ _i ∈ range (kstar w τ), p :=
      Finset.sum_le_sum fun i _ => hbdd i
    simpa [retained, Finset.sum_const, nsmul_eq_mul] using this
  rw [div_le_iff₀ hp]
  linarith

/-! ## Mixed corpora -/

/-- The convex mixture of two attention profiles. -/
def mix (lam : ℝ) (A B : ℕ → ℝ) : ℕ → ℝ := fun i => lam * A i + (1 - lam) * B i

theorem retained_mix (lam : ℝ) (A B : ℕ → ℝ) (k : ℕ) :
    retained (mix lam A B) k = lam * retained A k + (1 - lam) * retained B k := by
  simp only [retained, mix, Finset.sum_add_distrib, Finset.mul_sum]

/-- **Mixed-corpus sandwich.**  The knee of a convex mixture of two domains
lies between the two domain knees: a multilingual mixture can neither beat its
easiest component nor fall behind its hardest one. -/
theorem kstar_mix_bounds {lam τ : ℝ} (hlam0 : 0 ≤ lam) (hlam1 : lam ≤ 1)
    (A B : ℕ → ℝ) (hA : ∀ i, 0 ≤ A i) (hB : ∀ i, 0 ≤ B i)
    (hneA : {k | τ ≤ retained A k}.Nonempty) (hneB : {k | τ ≤ retained B k}.Nonempty) :
    min (kstar A τ) (kstar B τ) ≤ kstar (mix lam A B) τ ∧
      kstar (mix lam A B) τ ≤ max (kstar A τ) (kstar B τ) := by
  have hupper : τ ≤ retained (mix lam A B) (max (kstar A τ) (kstar B τ)) := by
    have hA' : τ ≤ retained A (max (kstar A τ) (kstar B τ)) :=
      le_retained_of_kstar_le A hA τ hneA (le_max_left _ _)
    have hB' : τ ≤ retained B (max (kstar A τ) (kstar B τ)) :=
      le_retained_of_kstar_le B hB τ hneB (le_max_right _ _)
    rw [retained_mix]
    nlinarith
  refine ⟨?_, Nat.sInf_le hupper⟩
  refine le_kstar_of_forall_lt _ τ ⟨_, hupper⟩ ?_
  intro j hj
  have hjA : ¬ τ ≤ retained A j :=
    not_le_retained_of_lt_kstar A τ (lt_of_lt_of_le hj (min_le_left _ _))
  have hjB : ¬ τ ≤ retained B j :=
    not_le_retained_of_lt_kstar B τ (lt_of_lt_of_le hj (min_le_right _ _))
  push_neg at hjA hjB
  rw [retained_mix]
  push_neg
  have hAle : lam * retained A j ≤ lam * τ := mul_le_mul_of_nonneg_left hjA.le hlam0
  have hBle : (1 - lam) * retained B j ≤ (1 - lam) * τ :=
    mul_le_mul_of_nonneg_left hjB.le (by linarith)
  rcases le_or_gt lam (1 / 2) with h | h
  · have hstrict : (1 - lam) * retained B j < (1 - lam) * τ :=
      mul_lt_mul_of_pos_left hjB (by linarith)
    nlinarith
  · have hstrict : lam * retained A j < lam * τ := mul_lt_mul_of_pos_left hjA (by linarith)
    nlinarith

end Physics.AttentionKnee