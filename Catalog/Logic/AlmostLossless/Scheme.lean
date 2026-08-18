import Logic.AlmostLossless.Core
import Logic.AlmostLossless.Hashing

/-!
# The Monte-Carlo compressor: hash-and-scan with uniqueness decoding

This file assembles the deliverable of the research thread: an explicit
almost-lossless compression scheme with

* an explicit **failure probability** bound (over the shared random seed and the
  source), see `AlmostLossless.avgFailProb_scanCode_le`;
* an explicit **decoder complexity** figure — the decoder is a single linear
  scan whose cost, counted in hash evaluations, is *exactly* the number of
  candidates it is handed (`AlmostLossless.scanWithCost_cost`), and for the
  bucketed instance the expected number of candidates is at most
  `1 + (|T|-1)/m₁` (`AlmostLossless.expected_bucket_size_le`);
* **no silent corruption**: `AlmostLossless.honest_scanCode` shows the decoder
  is honest *unconditionally* — for every seed, even a catastrophically bad one,
  and for every source word, typical or not.  The uniqueness test built into the
  scan plays the role of a checksum: two candidates means "abort", never a wrong
  answer.

The uniqueness (`ScanState`) decoder is what makes error detection free: the
decoder emits a word only if it is the *unique* candidate matching the received
hash, and the true word is always among the candidates, so an emitted word is
always the true word.
-/

namespace AlmostLossless

open Finset

/-! ## A cost-instrumented uniqueness scan -/

/-- The state of the decoder's linear scan: no candidate yet, exactly one
candidate so far, or at least two (in which case the decoder will abort). -/
inductive ScanState (S : Type*) where
  /-- No matching candidate seen yet. -/
  | empty : ScanState S
  /-- Exactly one matching candidate seen so far. -/
  | unique : S → ScanState S
  /-- At least two matching candidates: the decoder must abort. -/
  | ambiguous : ScanState S
  deriving DecidableEq

variable {S A M : Type*}

/-- One step of the scan: test the candidate, update the uniqueness state. -/
def scanStep (p : S → Bool) (st : ScanState S) (t : S) : ScanState S :=
  if p t then (match st with | .empty => .unique t | _ => .ambiguous) else st

/-- The step specialised to candidates already known to match. -/
def scanStepAll (st : ScanState S) (t : S) : ScanState S :=
  match st with | .empty => .unique t | _ => .ambiguous

/-- The decoder's scan over a candidate list. -/
def scan (p : S → Bool) (L : List S) : ScanState S := L.foldl (scanStep p) .empty

/-- The same scan, instrumented with a counter incremented once per candidate
test (one hash evaluation plus one comparison). -/
def scanWithCost (p : S → Bool) (L : List S) : ScanState S × ℕ :=
  L.foldl (fun st t => (scanStep p st.1 t, st.2 + 1)) (.empty, 0)

theorem scanWithCost_aux (p : S → Bool) (L : List S) (st : ScanState S) (n : ℕ) :
    L.foldl (fun st t => (scanStep p st.1 t, st.2 + 1)) (st, n)
      = (L.foldl (scanStep p) st, n + L.length) := by
  induction L generalizing st n with
  | nil => simp
  | cons a L ih => simp [ih, Nat.add_right_comm, Nat.add_assoc]

/-- **Exact decoder complexity.**  The instrumented scan performs exactly one
candidate test per candidate: `|L|` hash evaluations, no more and no less. -/
theorem scanWithCost_cost (p : S → Bool) (L : List S) :
    (scanWithCost p L).2 = L.length := by
  simp [scanWithCost, scanWithCost_aux]

/-- The instrumentation does not change the answer. -/
theorem scanWithCost_state (p : S → Bool) (L : List S) :
    (scanWithCost p L).1 = scan p L := by
  simp [scanWithCost, scan, scanWithCost_aux]

theorem foldl_scanStep_eq_filter (p : S → Bool) (L : List S) (st : ScanState S) :
    L.foldl (scanStep p) st = (L.filter p).foldl scanStepAll st := by
  induction L generalizing st with
  | nil => simp
  | cons a L ih =>
    by_cases hp : p a = true
    · rw [List.filter_cons_of_pos hp]
      simp only [List.foldl_cons, scanStep, hp, if_true]
      rw [ih]
      rfl
    · rw [List.filter_cons_of_neg (by simpa using hp)]
      simp only [List.foldl_cons, scanStep, hp]
      exact ih st

theorem foldl_scanStepAll_ambiguous (l : List S) :
    l.foldl scanStepAll .ambiguous = .ambiguous := by
  induction l with
  | nil => rfl
  | cons a l ih => simpa [scanStepAll] using ih

/-- A scan reports a unique answer exactly when the candidate list contains
exactly one match; this is the error-detection guarantee. -/
theorem scan_unique_iff (p : S → Bool) (L : List S) (t : S) :
    scan p L = .unique t ↔ L.filter p = [t] := by
  rw [scan, foldl_scanStep_eq_filter]
  constructor
  · intro h
    rcases hl : L.filter p with _ | ⟨u, l⟩
    · rw [hl] at h; exact absurd h (by simp)
    · rcases l with _ | ⟨v, l⟩
      · rw [hl] at h
        simp only [List.foldl_cons, List.foldl_nil, scanStepAll] at h
        cases h; rfl
      · rw [hl] at h
        simp only [List.foldl_cons, scanStepAll] at h
        rw [foldl_scanStepAll_ambiguous] at h
        exact absurd h (by simp)
  · intro h
    rw [h]
    rfl

/-- A nodup list in which `s` is the only element satisfying `p` filters to
`[s]`. -/
theorem filter_eq_singleton_of_unique {p : S → Bool} {s : S} :
    ∀ (L : List S), L.Nodup → s ∈ L → (∀ x ∈ L, p x = true → x = s) → p s = true →
      L.filter p = [s] := by
  intro L
  induction L with
  | nil => intro _ hs _ _; simp at hs
  | cons a L ih =>
    intro hnd hs huniq hps
    rw [List.nodup_cons] at hnd
    by_cases hpa : p a = true
    · have hae : a = s := huniq a (by simp) hpa
      subst hae
      rw [List.filter_cons_of_pos hpa]
      have hnil : L.filter p = [] := by
        rw [List.filter_eq_nil_iff]
        intro x hx hpx
        exact hnd.1 (by rw [← huniq x (by simp [hx]) hpx] at *; exact hx)
      rw [hnil]
    · rw [List.filter_cons_of_neg (by simpa using hpa)]
      have hsL : s ∈ L := by
        rcases List.mem_cons.1 hs with h | h
        · exact absurd (h ▸ hps) hpa
        · exact h
      exact ih hnd.2 hsL (fun x hx => huniq x (by simp [hx])) hps

/-! ## Scan schemes -/

/-- A **scan scheme**: a typical set `T`, a seeded hash used as the codeword,
and, for each seed and each received codeword, the list of candidates the
decoder scans (in practice produced by a precomputed index of `T`).  The two
axioms say the candidates are typical words and the true word is always a
candidate — these are exactly what makes the decoder honest. -/
structure ScanScheme (S A M : Type*) where
  /-- The typical set the encoder and decoder agree on. -/
  typical : Finset S
  /-- The seeded hash sent as the codeword. -/
  hash : A → S → M
  /-- The candidates the decoder scans on receiving a codeword. -/
  cand : A → M → Finset S
  /-- Candidates are typical words. -/
  cand_subset : ∀ a m, cand a m ⊆ typical
  /-- The true word is always among the candidates. -/
  self_mem_cand : ∀ a s, s ∈ typical → s ∈ cand a (hash a s)

variable [DecidableEq S] [DecidableEq M]

/-- The decoder: scan the candidate list, answer only if the match is unique. -/
noncomputable def ScanScheme.decode (P : ScanScheme S A M) (a : A) (m : M) : Option S :=
  match scan (fun t => decide (P.hash a t = m)) (P.cand a m).toList with
  | .unique t => some t
  | _ => none

/-- The decoder's cost in candidate tests (hash evaluations). -/
def ScanScheme.decodeCost (P : ScanScheme S A M) (a : A) (m : M) : ℕ := (P.cand a m).card

omit [DecidableEq S] in
/-- **Exact decoding complexity**: the decoder performs exactly
`|cand a m|` hash evaluations and comparisons — no search, no backtracking. -/
theorem ScanScheme.decodeCost_eq (P : ScanScheme S A M) (a : A) (m : M) :
    (scanWithCost (fun t => decide (P.hash a t = m)) (P.cand a m).toList).2
      = P.decodeCost a m := by
  rw [scanWithCost_cost, Finset.length_toList, ScanScheme.decodeCost]

/-- The code induced by a scan scheme with seed `a`.  The encoder sends the hash
of a typical word and an explicit failure flag for an atypical one, so the
codeword alphabet has `|M| + 1` symbols. -/
noncomputable def ScanScheme.code (P : ScanScheme S A M) (a : A) : Code S (Option M) where
  enc s := if s ∈ P.typical then some (P.hash a s) else none
  dec c := c.bind (P.decode a)

/-- **No silent corruption, unconditionally.**  Whatever the seed — even one for
which the hash collides all over the typical set — the decoder either returns
the true source word or explicitly declares failure. -/
theorem honest_scanCode (P : ScanScheme S A M) (a : A) : Honest (P.code a) := by
  intro s
  by_cases hs : s ∈ P.typical
  · -- the true word is a candidate and matches, so a unique match must be it
    rcases hd : (P.code a).dec ((P.code a).enc s) with _ | t
    · exact Or.inr rfl
    · left
      have hdec : P.decode a (P.hash a s) = some t := by
        simpa [ScanScheme.code, hs] using hd
      have hscan : scan (fun u => decide (P.hash a u = P.hash a s))
          (P.cand a (P.hash a s)).toList = .unique t := by
        unfold ScanScheme.decode at hdec
        rcases hst : scan (fun u => decide (P.hash a u = P.hash a s))
            (P.cand a (P.hash a s)).toList with _ | u | _
        · rw [hst] at hdec; exact absurd hdec (by simp)
        · rw [hst] at hdec
          simp only [Option.some_inj] at hdec
          rw [hdec]
        · rw [hst] at hdec; exact absurd hdec (by simp)
      have hfilter := (scan_unique_iff _ _ _).1 hscan
      have hmem : s ∈ (P.cand a (P.hash a s)).toList.filter
          (fun u => decide (P.hash a u = P.hash a s)) := by
        rw [List.mem_filter]
        exact ⟨Finset.mem_toList.2 (P.self_mem_cand a s hs), by simp⟩
      rw [hfilter] at hmem
      have : s = t := List.mem_singleton.1 hmem
      rw [this]
  · right
    simp [ScanScheme.code, hs]

/-- If the seed hashes the typical set injectively, every typical word decodes
correctly. -/
theorem correct_scanCode (P : ScanScheme S A M) (a : A)
    (hinj : ∀ x ∈ P.typical, ∀ y ∈ P.typical, P.hash a x = P.hash a y → x = y)
    {s : S} (hs : s ∈ P.typical) : Correct (P.code a) s := by
  have hfilter : (P.cand a (P.hash a s)).toList.filter
      (fun u => decide (P.hash a u = P.hash a s)) = [s] := by
    refine filter_eq_singleton_of_unique _ (Finset.nodup_toList _)
      (Finset.mem_toList.2 (P.self_mem_cand a s hs)) ?_ (by simp)
    intro x hx hpx
    have hxT : x ∈ P.typical := P.cand_subset a _ (Finset.mem_toList.1 hx)
    exact hinj x hxT s hs (by simpa using hpx)
  have : P.decode a (P.hash a s) = some s := by
    unfold ScanScheme.decode
    rw [(scan_unique_iff _ _ _).2 hfilter]
  simp [Correct, ScanScheme.code, hs, this]

/-! ## Failure probability of the Monte-Carlo scheme -/

variable [Fintype S] [Fintype A] [DecidableEq A] [Nonempty A] [Fintype M] [Nonempty M]

/-- **The deliverable bound.**  Draw the seed with a random number generator.
The average failure probability of the scan code is at most
`ε + |T|(|T|-1)/|M|`, where `ε` bounds the probability of the atypical set: the
first term is the (unavoidable) atypicality loss, the second is the Monte-Carlo
collision loss.  Every failure is *detected* (the decoder returns `none`). -/
theorem avgFailProb_scanCode_le (μ : Source S) (P : ScanScheme S A M)
    (hu : TwoUniversal P.hash) (ε : ℚ) (hε : 0 ≤ ε) (hT : 1 - ε ≤ μ.prob P.typical) :
    avgFailProb μ (fun a => P.code a)
      ≤ ε + (P.typical.offDiag.card : ℚ) / (Fintype.card M : ℚ) := by
  classical
  have hA : (0 : ℚ) < (Fintype.card A : ℚ) := by exact_mod_cast Fintype.card_pos (α := A)
  -- split the seeds into good ones and bad ones
  set B : Finset A := {a | CollidesOn P.hash P.typical a} with hB
  have hgood : ∀ a ∈ Bᶜ, failProb μ (P.code a) ≤ ε := by
    intro a ha
    have hna : ¬ CollidesOn P.hash P.typical a := by
      simpa [hB, Finset.mem_compl] using ha
    exact failProb_le_of_correct_on μ _ P.typical
      (fun s hs => correct_scanCode P a (injOn_of_not_collidesOn hna) hs) ε hT
  have hbad : ∀ a ∈ B, failProb μ (P.code a) ≤ 1 := fun a _ => failProb_le_one μ _
  have hsum : ∑ a, failProb μ (P.code a) ≤ (Fintype.card A : ℚ) * ε + (B.card : ℚ) := by
    have hsplit : ∑ a, failProb μ (P.code a)
        = ∑ a ∈ B, failProb μ (P.code a) + ∑ a ∈ Bᶜ, failProb μ (P.code a) := by
      rw [Finset.sum_add_sum_compl]
    rw [hsplit]
    have h1 : ∑ a ∈ B, failProb μ (P.code a) ≤ (B.card : ℚ) := by
      calc ∑ a ∈ B, failProb μ (P.code a) ≤ ∑ _a ∈ B, (1 : ℚ) :=
            Finset.sum_le_sum hbad
        _ = (B.card : ℚ) := by simp
    have h2 : ∑ a ∈ Bᶜ, failProb μ (P.code a) ≤ (Fintype.card A : ℚ) * ε := by
      calc ∑ a ∈ Bᶜ, failProb μ (P.code a) ≤ ∑ _a ∈ Bᶜ, ε := Finset.sum_le_sum hgood
        _ = (Bᶜ.card : ℚ) * ε := by simp [Finset.sum_const, nsmul_eq_mul]
        _ ≤ (Fintype.card A : ℚ) * ε := by
            have : (Bᶜ.card : ℚ) ≤ (Fintype.card A : ℚ) := by
              exact_mod_cast Finset.card_le_univ Bᶜ
            exact mul_le_mul_of_nonneg_right this hε
    linarith
  have hcoll : (B.card : ℚ) / (Fintype.card A : ℚ)
      ≤ (P.typical.offDiag.card : ℚ) / (Fintype.card M : ℚ) := collisionProb_le hu _
  rw [avgFailProb, div_le_iff₀ hA]
  have hstep : (B.card : ℚ) ≤ (P.typical.offDiag.card : ℚ) / (Fintype.card M : ℚ)
      * (Fintype.card A : ℚ) := by
    rw [div_le_iff₀ hA] at hcoll
    linarith
  calc ∑ a, failProb μ (P.code a) ≤ (Fintype.card A : ℚ) * ε + (B.card : ℚ) := hsum
    _ ≤ (Fintype.card A : ℚ) * ε
        + (P.typical.offDiag.card : ℚ) / (Fintype.card M : ℚ) * (Fintype.card A : ℚ) := by
          linarith
    _ = (ε + (P.typical.offDiag.card : ℚ) / (Fintype.card M : ℚ)) * (Fintype.card A : ℚ) := by
          ring

end AlmostLossless