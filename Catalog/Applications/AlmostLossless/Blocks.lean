/-
# Almost-lossless compression VIII: block composition

Cycle 3.  The scheme of `Applications.AlmostLossless.Enumerative` is *fixed rate*:
every codeword has exactly `k + 1` bits (`enumCode_length_eq`).  Concatenating `n`
codewords is therefore parse-free — the decoder slices the received string into
`n` chunks of `k + 1` bits and decodes each — and none of the exponential search
cost of random coding reappears at the block level.

## Main results

* `AlmostLossless.decodeChunks_concat` — the block decoder inverts the block
  encoder on every source all of whose blocks are decodable.
* `AlmostLossless.blockCode_sound` — soundness composes: no silent corruption.
* `AlmostLossless.goodSet_blockCode` — the good set of the block code is exactly
  the product of the per-block good sets.
* `AlmostLossless.blockCode_failProb_le` — **union bound**: under the product
  source, `n` blocks each failing with probability `≤ ε` give a total failure
  probability `≤ n ε`.
* `AlmostLossless.blockDecI_cost` — **exact decoding complexity of the block
  scheme**: `n (k + 3) + 1` steps for `n (k+1)` transmitted bits, i.e. linear in
  the length of the message.
-/
import Mathlib
import Applications.AlmostLossless.Complexity

namespace AlmostLossless

open Finset

variable {α : Type*} [Fintype α] [DecidableEq α]

/-! ## The block encoder and decoder -/

/-- Concatenation of the per-block codewords. -/
def concatEnc (c : Code α) {n : ℕ} (v : Fin n → α) : List Bool :=
  (List.ofFn (fun i => c.enc (v i))).flatten

omit [Fintype α] [DecidableEq α] in
@[simp] theorem concatEnc_zero (c : Code α) (v : Fin 0 → α) : concatEnc c v = [] := by
  simp [concatEnc]

omit [Fintype α] [DecidableEq α] in
theorem concatEnc_succ (c : Code α) {n : ℕ} (v : Fin (n + 1) → α) :
    concatEnc c v = c.enc (v 0) ++ concatEnc c (fun i : Fin n => v i.succ) := by
  simp [concatEnc, List.ofFn_succ]

/-- Slice the received string into chunks of `ℓ` bits and decode each one; a single
failing chunk makes the whole block fail. -/
def decodeChunks (c : Code α) (ℓ : ℕ) : ℕ → List Bool → Option (List α)
  | 0, w => if w = [] then some [] else none
  | n + 1, w =>
      match c.dec (w.take ℓ) with
      | none => none
      | some a => (decodeChunks c ℓ n (w.drop ℓ)).map (fun as => a :: as)

/-- The fixed-rate block code on `n`-tuples. -/
noncomputable def blockCode (c : Code α) (ℓ n : ℕ) : Code (Fin n → α) where
  enc v := concatEnc c v
  dec w := (decodeChunks c ℓ n w).bind
    (fun as => if h : as.length = n then some (fun i => as.get (Fin.cast h.symm i)) else none)

/-! ## Correctness -/

omit [Fintype α] [DecidableEq α] in
/-- **The block decoder inverts the block encoder.** -/
theorem decodeChunks_concat {c : Code α} {ℓ : ℕ} (hlen : ∀ x, (c.enc x).length = ℓ) :
    ∀ (n : ℕ) (v : Fin n → α), (∀ i, Decodes c (v i)) →
      decodeChunks c ℓ n (concatEnc c v) = some (List.ofFn v) := by
  intro n
  induction n with
  | zero => intro v _; simp [decodeChunks]
  | succ n ih =>
      intro v hv
      rw [concatEnc_succ]
      have htake : (c.enc (v 0) ++ concatEnc c (fun i : Fin n => v i.succ)).take ℓ = c.enc (v 0) :=
        List.take_left' (hlen (v 0))
      have hdrop : (c.enc (v 0) ++ concatEnc c (fun i : Fin n => v i.succ)).drop ℓ
          = concatEnc c (fun i : Fin n => v i.succ) := List.drop_left' (hlen (v 0))
      have hrec := ih (fun i : Fin n => v i.succ) (fun i => hv i.succ)
      have hv0 : c.dec (c.enc (v 0)) = some (v 0) := hv 0
      simp only [decodeChunks, htake, hdrop, hv0, hrec, Option.map_some]
      simp [List.ofFn_succ]

omit [Fintype α] [DecidableEq α] in
/-- Any answer the block decoder returns is the true tuple, and every block of it
was decodable. -/
theorem decodeChunks_sound {c : Code α} {ℓ : ℕ} (hs : Sound c) (hlen : ∀ x, (c.enc x).length = ℓ) :
    ∀ (n : ℕ) (v : Fin n → α) (as : List α),
      decodeChunks c ℓ n (concatEnc c v) = some as →
        as = List.ofFn v ∧ ∀ i, Decodes c (v i) := by
  intro n
  induction n with
  | zero =>
      intro v as h
      simp only [concatEnc_zero, decodeChunks] at h
      have has : as = [] := by simpa using h.symm
      exact ⟨by simp [has], fun i => i.elim0⟩
  | succ n ih =>
      intro v as h
      rw [concatEnc_succ] at h
      have htake : (c.enc (v 0) ++ concatEnc c (fun i : Fin n => v i.succ)).take ℓ = c.enc (v 0) :=
        List.take_left' (hlen (v 0))
      have hdrop : (c.enc (v 0) ++ concatEnc c (fun i : Fin n => v i.succ)).drop ℓ
          = concatEnc c (fun i : Fin n => v i.succ) := List.drop_left' (hlen (v 0))
      simp only [decodeChunks, htake, hdrop] at h
      cases hd : c.dec (c.enc (v 0)) with
      | none => rw [hd] at h; exact absurd h (by simp)
      | some a =>
          have ha : a = v 0 := hs (v 0) a hd
          rw [hd] at h
          simp only [Option.map_eq_some_iff] at h
          obtain ⟨bs, hbs, rfl⟩ := h
          obtain ⟨hbs', hall⟩ := ih (fun i : Fin n => v i.succ) bs hbs
          refine ⟨by rw [hbs', ha]; simp [List.ofFn_succ], ?_⟩
          intro i
          refine Fin.cases ?_ ?_ i
          · rw [Decodes, hd, ha]
          · intro j; exact hall j

omit [Fintype α] [DecidableEq α] in
/-- **Soundness composes.** -/
theorem blockCode_sound {c : Code α} {ℓ : ℕ} (hs : Sound c) (hlen : ∀ x, (c.enc x).length = ℓ)
    (n : ℕ) : Sound (blockCode c ℓ n) := by
  intro v u hvu
  simp only [blockCode] at hvu
  cases hdc : decodeChunks c ℓ n (concatEnc c v) with
  | none => rw [hdc] at hvu; exact absurd hvu (by simp)
  | some as =>
      obtain ⟨rfl, -⟩ := decodeChunks_sound hs hlen n v as hdc
      rw [hdc] at hvu
      simp only [Option.bind_some] at hvu
      rw [dif_pos (by simp)] at hvu
      have := Option.some_inj.mp hvu
      funext i
      rw [← this]
      simp

omit [Fintype α] [DecidableEq α] in
/-- Every tuple of decodable blocks is decoded. -/
theorem blockCode_decodes {c : Code α} {ℓ : ℕ} (hlen : ∀ x, (c.enc x).length = ℓ)
    {n : ℕ} (v : Fin n → α) (hv : ∀ i, Decodes c (v i)) : Decodes (blockCode c ℓ n) v := by
  simp only [Decodes, blockCode]
  rw [decodeChunks_concat hlen n v hv]
  simp only [Option.bind_some]
  rw [dif_pos (by simp)]
  simp

/-- **The good set of the block code is the product of the good sets.** -/
theorem goodSet_blockCode {c : Code α} {ℓ : ℕ} (hs : Sound c) (hlen : ∀ x, (c.enc x).length = ℓ)
    (n : ℕ) : goodSet (blockCode c ℓ n) = Fintype.piFinset (fun _ : Fin n => goodSet c) := by
  ext v
  rw [mem_goodSet, Fintype.mem_piFinset]
  constructor
  · intro hv i
    rw [mem_goodSet]
    simp only [Decodes, blockCode] at hv
    cases hdc : decodeChunks c ℓ n (concatEnc c v) with
    | none => rw [hdc] at hv; exact absurd hv (by simp)
    | some as => exact (decodeChunks_sound hs hlen n v as hdc).2 i
  · intro hv
    exact blockCode_decodes hlen v (fun i => (mem_goodSet).1 (hv i))

/-! ## The union bound for the product source -/

variable {p : α → ℝ}

omit [DecidableEq α] in
/-- The product distribution is a probability distribution. -/
theorem prod_sum_eq_one (hsum : ∑ x, p x = 1) (n : ℕ) :
    ∑ v : Fin n → α, ∏ i, p (v i) = 1 := by
  classical
  have h := Finset.prod_univ_sum (fun _ : Fin n => (univ : Finset α)) (fun _ x => p x)
  rw [hsum] at h
  simp only [Finset.prod_const_one] at h
  rw [Fintype.piFinset_univ] at h
  exact h.symm

omit [Fintype α] [DecidableEq α] in
/-- The mass of a product set is the product of the masses. -/
theorem mass_piFinset (G : Finset α) (n : ℕ) :
    ∑ v ∈ Fintype.piFinset (fun _ : Fin n => G), ∏ i, p (v i) = (∑ x ∈ G, p x) ^ n := by
  classical
  have h := Finset.prod_univ_sum (fun _ : Fin n => G) (fun _ x => p x)
  simp only [Finset.prod_const] at h
  rw [← h]
  simp

/-- **Union bound for block composition.**  If each block fails with probability at
most `ε`, then `n` blocks fail with probability at most `n ε` — and, by
`blockCode_sound`, still never silently. -/
theorem blockCode_failProb_le {c : Code α} {ℓ : ℕ} (hs : Sound c)
    (hlen : ∀ x, (c.enc x).length = ℓ) (hp : ∀ x, 0 ≤ p x) (hsum : ∑ x, p x = 1)
    {ε : ℝ} (hε : 0 ≤ ε) (hfail : failProb p c ≤ ε) (n : ℕ) :
    failProb (fun v : Fin n → α => ∏ i, p (v i)) (blockCode c ℓ n) ≤ n * ε := by
  classical
  set P : (Fin n → α) → ℝ := fun v => ∏ i, p (v i) with hP
  have hgoodmass : ∑ v ∈ goodSet (blockCode c ℓ n), P v = (∑ x ∈ goodSet c, p x) ^ n := by
    rw [goodSet_blockCode hs hlen n]
    exact mass_piFinset (p := p) (goodSet c) n
  have htot : ∑ v : Fin n → α, P v = 1 := prod_sum_eq_one hsum n
  have hsplit : ∑ v ∈ goodSet (blockCode c ℓ n), P v = 1 - failProb P (blockCode c ℓ n) :=
    mass_goodSet htot _
  have hmass : ∑ x ∈ goodSet c, p x = 1 - failProb p c := mass_goodSet hsum c
  have hg : 1 - ε ≤ ∑ x ∈ goodSet c, p x := by rw [hmass]; linarith
  have hgnn : 0 ≤ ∑ x ∈ goodSet c, p x := Finset.sum_nonneg fun x _ => hp x
  rcases le_or_gt 0 (1 - ε) with hpos | hneg
  · -- Bernoulli's inequality
    have hbern : 1 + (n : ℝ) * (-ε) ≤ (1 + (-ε)) ^ n :=
      one_add_mul_le_pow (by linarith) n
    have hmono : ((1 : ℝ) - ε) ^ n ≤ (∑ x ∈ goodSet c, p x) ^ n :=
      pow_le_pow_left₀ hpos hg n
    have : (1 : ℝ) - (n : ℝ) * ε ≤ (∑ x ∈ goodSet c, p x) ^ n := by
      have h1 : (1 : ℝ) + (n : ℝ) * (-ε) = 1 - (n : ℝ) * ε := by ring
      have h2 : (1 : ℝ) + (-ε) = 1 - ε := by ring
      rw [h1, h2] at hbern
      linarith
    rw [hgoodmass] at hsplit
    linarith
  · -- `ε > 1`: the bound is vacuous unless `n = 0`, where the failure probability is `0`
    cases n with
    | zero =>
        have : failProb P (blockCode c ℓ 0) = 0 := by
          rw [hgoodmass] at hsplit
          simp at hsplit
          linarith
        simpa using this.le
    | succ m =>
        have hnn : 0 ≤ (∑ x ∈ goodSet c, p x) ^ (m + 1) := pow_nonneg hgnn _
        rw [hgoodmass] at hsplit
        have hle1 : failProb P (blockCode c ℓ (m + 1)) ≤ 1 := by linarith
        have : (1 : ℝ) ≤ ((m : ℝ) + 1) * ε := by nlinarith [Nat.cast_nonneg (α := ℝ) m]
        push_cast
        linarith

/-! ## Exact decoding complexity of the block scheme -/

/-- Step-counting block decoder: for each of the `n` blocks it slices off `k + 1`
bits (1 step) and runs the instrumented enumerative decoder. -/
noncomputable def blockDecI (S : Finset α) (k : ℕ) : ℕ → List Bool → Option (List α) × ℕ
  | 0, w => (if w = [] then some [] else none, 1)
  | n + 1, w =>
      match (enumDecI S (w.take (k + 1))).1 with
      | none => (none, (enumDecI S (w.take (k + 1))).2 + 1)
      | some a =>
          ((blockDecI S k n (w.drop (k + 1))).1.map (fun as => a :: as),
            (enumDecI S (w.take (k + 1))).2 + (blockDecI S k n (w.drop (k + 1))).2 + 1)

omit [Fintype α] in
/-- **Exact decoding complexity of the block scheme.**  Decoding `n` blocks of a
rate-`k` code costs `n (k + 3) + 1` steps — linear in the `n (k+1)` transmitted
bits — whereas exhaustive search over a random codebook for the whole block would
cost up to `2 ^ (n k)` probes. -/
theorem blockDecI_cost {S : Finset α} {k : ℕ} (hcard : S.card ≤ 2 ^ k) :
    ∀ (n : ℕ) (v : Fin n → α), (∀ i, v i ∈ S) →
      (blockDecI S k n (concatEnc (enumCode S k) v)).1 = some (List.ofFn v) ∧
      (blockDecI S k n (concatEnc (enumCode S k) v)).2 = n * (k + 3) + 1 := by
  intro n
  induction n with
  | zero => intro v _; simp [blockDecI]
  | succ n ih =>
      intro v hv
      have hlen : ∀ x : α, ((enumCode S k).enc x).length = k + 1 := enumCode_length_eq S k
      rw [concatEnc_succ]
      have htake : ((enumCode S k).enc (v 0)
          ++ concatEnc (enumCode S k) (fun i : Fin n => v i.succ)).take (k + 1)
          = (enumCode S k).enc (v 0) := List.take_left' (hlen (v 0))
      have hdrop : ((enumCode S k).enc (v 0)
          ++ concatEnc (enumCode S k) (fun i : Fin n => v i.succ)).drop (k + 1)
          = concatEnc (enumCode S k) (fun i : Fin n => v i.succ) := List.drop_left' (hlen (v 0))
      have hdec : (enumDecI S ((enumCode S k).enc (v 0))).1 = some (v 0) := by
        rw [enumDecI_fst S k]
        exact enumCode_decodes hcard (hv 0)
      have hcost : (enumDecI S ((enumCode S k).enc (v 0))).2 = k + 2 :=
        enumDecI_cost_enc hcard (hv 0)
      obtain ⟨ih1, ih2⟩ := ih (fun i : Fin n => v i.succ) (fun i => hv i.succ)
      constructor
      · simp only [blockDecI, htake, hdrop, hdec, ih1, Option.map_some]
        simp [List.ofFn_succ]
      · simp only [blockDecI, htake, hdrop, hdec, hcost, ih2]
        ring

end AlmostLossless