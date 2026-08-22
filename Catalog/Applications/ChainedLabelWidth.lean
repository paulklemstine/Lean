/-
# Chained integer label encodings: the width criterion

## Context (FACT round-29 #2, "THE-ORIGINAL-STANDS")

Experimental pipelines routinely build a *joint label* for a pair of discrete
codes `(a, b)` by chaining them into a single integer

  `pj = a * M + b`

for some fixed decimal *frame* `M` (in the programme: `M = 10000`, `M = 100`,
`M = 10`).  This is a bijection onto its image **iff the frame is at least as
wide as the alphabet of the inner code**.  When the frame is too narrow the
encoding silently *merges* distinct pairs, and every downstream statistic
(label count, label entropy, mutual information) is computed on a coarsening of
the intended population rather than on the population itself.

This file is the arithmetic half of the reconciliation.  It proves:

* `chain_inj_of_lt` / `chainPair_injective` — width-valid chaining is injective;
* `chain_collision_of_frame_lt` — a *narrow* frame always produces an explicit
  collision, so the failure is structural, not data-dependent;
* `card_chain_image_of_width` — a wide frame realises the full `A * B` labels;
* `card_chain_image_of_narrow` — the **exact** label count `M * (A - 1) + B`
  for a narrow frame `M ≤ B`; the image is a full interval;
* `collapse_36_to_18` — the audited instance: `4 × 9 = 36` genuine pairs are
  reported as `18` labels under a `·3` frame (the shape of the retracted
  rebuild reading), while a width-valid frame keeps all `36`.

Nothing here is `decide`-only: the counting theorems are proved for all
`A, B, M` by an explicit interval identification, and the numeric instances are
corollaries of them.
-/
import Mathlib

namespace ChainedLabelWidth

open Finset

/-- Chained integer label: outer code `a`, inner code `b`, decimal frame `M`. -/
def chain (M a b : ℕ) : ℕ := a * M + b

@[simp] lemma chain_def (M a b : ℕ) : chain M a b = a * M + b := rfl

/-! ## Width criterion: injectivity -/

/-- **Width criterion.**  If both inner codes fit strictly inside the frame,
the chained label determines both components. -/
theorem chain_inj_of_lt {M a b a' b' : ℕ} (hb : b < M) (hb' : b' < M)
    (h : chain M a b = chain M a' b') : a = a' ∧ b = b' := by
  simp only [chain_def] at h
  have hM : 0 < M := lt_of_le_of_lt (Nat.zero_le b) hb
  have ha : a = a' := by
    have e1 : (a * M + b) / M = a := by
      rw [Nat.add_comm, Nat.add_mul_div_right _ _ hM, Nat.div_eq_of_lt hb, Nat.zero_add]
    have e2 : (a' * M + b') / M = a' := by
      rw [Nat.add_comm, Nat.add_mul_div_right _ _ hM, Nat.div_eq_of_lt hb', Nat.zero_add]
    rw [← e1, ← e2, h]
  subst ha
  exact ⟨rfl, by omega⟩

/-- Width-valid chaining is injective on the product of code alphabets. -/
theorem chainPair_injective {A B M : ℕ} (hBM : B ≤ M) :
    Set.InjOn (fun p : ℕ × ℕ => chain M p.1 p.2)
      {p : ℕ × ℕ | p.1 < A ∧ p.2 < B} := by
  rintro ⟨a, b⟩ ⟨-, hb⟩ ⟨a', b'⟩ ⟨-, hb'⟩ h
  obtain ⟨h1, h2⟩ := chain_inj_of_lt (lt_of_lt_of_le hb hBM) (lt_of_lt_of_le hb' hBM) h
  exact Prod.ext h1 h2

/-- **Narrow frames always collide.**  If the frame `M` is strictly smaller than
the inner alphabet size `B` (and there are at least two outer codes), two
*distinct* admissible pairs receive the same chained label. -/
theorem chain_collision_of_frame_lt {A B M : ℕ} (hM : M < B) (hA : 2 ≤ A) :
    ∃ a b a' b', a < A ∧ b < B ∧ a' < A ∧ b' < B ∧ (a, b) ≠ (a', b') ∧
      chain M a b = chain M a' b' := by
  refine ⟨0, M, 1, 0, by omega, hM, by omega, by omega, ?_, ?_⟩
  · simp
  · simp [chain]

/-! ## Exact label counts -/

/-- Wide frame (`B ≤ M`): all `A * B` pairs survive as distinct labels. -/
theorem card_chain_image_of_width {A B M : ℕ} (hBM : B ≤ M) :
    ((range A ×ˢ range B).image (fun p => chain M p.1 p.2)).card = A * B := by
  rw [Finset.card_image_of_injOn, Finset.card_product, Finset.card_range,
    Finset.card_range]
  rintro ⟨a, b⟩ hab ⟨a', b'⟩ hab' h
  simp only [Finset.mem_coe, Finset.mem_product, Finset.mem_range] at hab hab'
  obtain ⟨h1, h2⟩ :=
    chain_inj_of_lt (lt_of_lt_of_le hab.2 hBM) (lt_of_lt_of_le hab'.2 hBM) h
  exact Prod.ext h1 h2

/-- Under a **narrow** frame `M ≤ B` the image is exactly the interval
`[0, M * (A - 1) + B)`. -/
theorem chain_image_eq_range {A B M : ℕ} (hMB : M ≤ B) (hA : 1 ≤ A) :
    (range A ×ˢ range B).image (fun p => chain M p.1 p.2)
      = range (M * (A - 1) + B) := by
  ext n
  simp only [Finset.mem_image, Finset.mem_product, Finset.mem_range, Prod.exists]
  constructor
  · rintro ⟨a, b, ⟨ha, hb⟩, rfl⟩
    have : a ≤ A - 1 := by omega
    have : a * M ≤ (A - 1) * M := Nat.mul_le_mul_right _ this
    simp only [chain_def]
    calc a * M + b ≤ (A - 1) * M + b := by omega
      _ < (A - 1) * M + B := by omega
      _ = M * (A - 1) + B := by ring_nf
  · intro hn
    rcases Nat.lt_or_ge n (M * (A - 1)) with hlt | hge
    · -- `n` is below the top row: use `a = n / M`, `b = n % M`
      have hM : 0 < M := by
        rcases Nat.eq_zero_or_pos M with h0 | h0
        · simp [h0] at hlt
        · exact h0
      refine ⟨n / M, n % M, ⟨?_, ?_⟩, ?_⟩
      · have : n / M < A - 1 := by
          exact Nat.div_lt_of_lt_mul (by omega)
        omega
      · exact lt_of_lt_of_le (Nat.mod_lt _ hM) hMB
      · simp only [chain_def]
        rw [Nat.div_add_mod' n M]
    · -- top row: `a = A - 1`, `b = n - M * (A - 1)`
      refine ⟨A - 1, n - M * (A - 1), ⟨by omega, by omega⟩, ?_⟩
      simp only [chain_def]
      have : (A - 1) * M = M * (A - 1) := by ring
      omega

/-- **Exact narrow-frame label count.**  A frame `M ≤ B` reports
`M * (A - 1) + B` labels for a population of `A * B` genuine pairs. -/
theorem card_chain_image_of_narrow {A B M : ℕ} (hMB : M ≤ B) (hA : 1 ≤ A) :
    ((range A ×ˢ range B).image (fun p => chain M p.1 p.2)).card
      = M * (A - 1) + B := by
  rw [chain_image_eq_range hMB hA, Finset.card_range]

/-- The two regimes agree on the boundary `M = B`: no information is lost
exactly when the frame is wide enough. -/
theorem narrow_count_lt_pairs {A B M : ℕ} (hMB : M < B) (hA : 2 ≤ A) :
    M * (A - 1) + B < A * B := by
  have h1 : M * (A - 1) + 1 * (A-1) ≤ (B-1) * (A - 1) + 1 * (A-1) := by
    have : M * (A-1) ≤ (B-1) * (A-1) := Nat.mul_le_mul_right _ (by omega)
    omega
  have h2 : (B - 1) * (A - 1) + 1 * (A - 1) = B * (A - 1) := by
    have : 0 < B := by omega
    cases B with
    | zero => omega
    | succ b => simp; ring
  have h3 : B * (A - 1) + B = A * B := by
    cases A with
    | zero => omega
    | succ a => simp; ring
  omega

/-! ## The audited instance: `36` genuine pairs, `18` reported labels -/

/-- Paper 91's width-valid frame: `pj = pc_a * 10000 + pc_b` on a
`4 × 9` code population keeps all `36` labels. -/
theorem labels_wide_frame :
    ((range 4 ×ˢ range 9).image (fun p => chain 10000 p.1 p.2)).card = 36 :=
  card_chain_image_of_width (by norm_num)

/-- The rebuild's narrow frame `·3` on the same population reports only `18`
labels: exactly half of the genuine pairs are merged. -/
theorem labels_narrow_frame :
    ((range 4 ×ˢ range 9).image (fun p => chain 3 p.1 p.2)).card = 18 :=
  card_chain_image_of_narrow (by norm_num) (by norm_num)

/-- **The collapse.**  On one and the same population the narrow frame reports
exactly half as many labels as the width-valid frame — the arithmetic signature
of the retracted rebuild reading. -/
theorem collapse_36_to_18 :
    2 * ((range 4 ×ˢ range 9).image (fun p => chain 3 p.1 p.2)).card
      = ((range 4 ×ˢ range 9).image (fun p => chain 10000 p.1 p.2)).card := by
  rw [labels_wide_frame, labels_narrow_frame]

/-- A width-check predicate an audit can actually run: the frame must dominate
the inner alphabet. -/
def WidthOK (B M : ℕ) : Prop := B ≤ M

/-- The width check is *exactly* the no-collision criterion (for at least two
outer codes and a nonempty inner alphabet). -/
theorem widthOK_iff_no_collision {A B : ℕ} (hA : 2 ≤ A) (M : ℕ) :
    WidthOK B M ↔
      ∀ a b a' b', a < A → b < B → a' < A → b' < B →
        chain M a b = chain M a' b' → (a, b) = (a', b') := by
  constructor
  · intro hW a b a' b' _ hb _ hb' h
    obtain ⟨h1, h2⟩ := chain_inj_of_lt (lt_of_lt_of_le hb hW) (lt_of_lt_of_le hb' hW) h
    simp [h1, h2]
  · intro hno
    by_contra hW
    have hM : M < B := by
      simpa [WidthOK, Nat.not_le] using hW
    obtain ⟨a, b, a', b', ha, hb, ha', hb', hne, heq⟩ :=
      chain_collision_of_frame_lt (A := A) hM hA
    exact hne (hno a b a' b' ha hb ha' hb' heq)

end ChainedLabelWidth