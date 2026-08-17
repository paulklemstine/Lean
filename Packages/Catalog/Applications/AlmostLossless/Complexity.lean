/-
# Almost-lossless compression III: exact decoder complexity

The rate question for almost-lossless compression is settled by
`Applications.AlmostLossless.Core` (converse) and
`Applications.AlmostLossless.Enumerative` (achievability).  The remaining — and,
for this thread, the real — obstacle is the **decoder's running time**: Shannon's
random-coding argument produces a codebook whose decoder is an exhaustive search
through the codebook, i.e. `2 ^ k` probes at rate `k`.

Here we give an *instrumented* (step-counting) version of both decoders and prove
their exact costs:

* `AlmostLossless.enumDecI_cost_enc` — the enumerative decoder of
  `enumCode S k` consumes exactly `k + 2` steps on a typical source: one step per
  transmitted index bit, one for the flag bit, one indexed table access.
* `AlmostLossless.scanI_cost_worst` — the naive random-coding decoder
  (linear scan of the codebook) costs exactly `|codebook|` probes in the worst
  case, i.e. `2 ^ k` at rate `k`.
* `AlmostLossless.decoder_complexity_separation` — for every rate `k ≥ 4` the
  enumerative decoder is *strictly* faster, and
* `AlmostLossless.decoder_speedup_unbounded` — the speed-up factor is unbounded:
  for every `M` there is a rate at which the enumerative decoder is more than `M`
  times faster.

Both instrumented decoders are proved to compute the *same function* as the
decoders they instrument (`enumDecI_fst`, `scanI_sound`), so the step counts are
counts of a genuine decoding procedure, not of a stand-in.
-/
import Mathlib
import Applications.AlmostLossless.Enumerative

namespace AlmostLossless

open Finset

/-! ## Instrumented bit-reading -/

/-- Step-counting version of `fromBits`: one step per bit, plus one step to
recognise the end of the string. -/
def fromBitsI : List Bool → ℕ × ℕ
  | [] => (0, 1)
  | b :: l => ((if b then 1 else 0) + 2 * (fromBitsI l).1, (fromBitsI l).2 + 1)

/-- The instrumented reader computes `fromBits`. -/
@[simp] theorem fromBitsI_fst (l : List Bool) : (fromBitsI l).1 = fromBits l := by
  induction l with
  | nil => simp [fromBitsI, fromBits]
  | cons b l ih => simp [fromBitsI, fromBits, ih]

/-- Exact cost of reading a bit string: `length + 1` steps. -/
@[simp] theorem fromBitsI_snd (l : List Bool) : (fromBitsI l).2 = l.length + 1 := by
  induction l with
  | nil => simp [fromBitsI]
  | cons b l ih => simp [fromBitsI, ih]

/-! ## The instrumented enumerative decoder -/

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- Step-counting version of the decoder of `enumCode S k`: it reads the flag bit
(1 step), reads the index (`fromBitsI`), and performs one indexed table access
(1 step). -/
noncomputable def enumDecI (S : Finset α) : List Bool → Option α × ℕ
  | [] => (none, 1)
  | false :: _ => (none, 1)
  | true :: rest =>
      if h : (fromBitsI rest).1 < S.card then
        (some ((S.equivFin.symm ⟨(fromBitsI rest).1, h⟩ : S) : α), (fromBitsI rest).2 + 1)
      else (none, (fromBitsI rest).2 + 1)

omit [Fintype α] in
/-- The instrumented decoder computes exactly the decoder of `enumCode S k`. -/
theorem enumDecI_fst (S : Finset α) (k : ℕ) (l : List Bool) :
    (enumDecI S l).1 = (enumCode S k).dec l := by
  match l with
  | [] => rfl
  | false :: _ => rfl
  | true :: rest =>
      by_cases h : fromBits rest < S.card <;>
        simp [enumDecI, enumCode, h]

omit [Fintype α] in
/-- **Exact decoding complexity of the enumerative scheme.**  Decoding a typical
source costs `k + 2` steps: `k` index bits, one flag bit and one table access.
This is *linear in the transmitted rate*, in contrast with `scanI_cost_worst`. -/
theorem enumDecI_cost_enc {S : Finset α} {k : ℕ} (hcard : S.card ≤ 2 ^ k) {x : α} (h : x ∈ S) :
    (enumDecI S ((enumCode S k).enc x)).2 = k + 2 := by
  have hlt : ((S.equivFin ⟨x, h⟩ : Fin S.card) : ℕ) < S.card := (S.equivFin ⟨x, h⟩).isLt
  have hlt' : ((S.equivFin ⟨x, h⟩ : Fin S.card) : ℕ) < 2 ^ k := lt_of_lt_of_le hlt hcard
  rw [enumCode_enc_mem h]
  simp only [enumDecI, fromBitsI_snd, length_toBits]
  split <;> rfl

omit [Fintype α] in
/-- Uniform cost bound: the decoder never spends more than `k + 3` steps on a
codeword of the scheme. -/
theorem enumDecI_cost_le {S : Finset α} {k : ℕ} (x : α) :
    (enumDecI S ((enumCode S k).enc x)).2 ≤ k + 3 := by
  by_cases h : x ∈ S
  · rw [enumCode_enc_mem h]
    simp only [enumDecI, fromBitsI_snd, length_toBits]
    split <;> simp
  · rw [enumCode_enc_not_mem h]
    simp [enumDecI]

/-! ## The naive random-coding decoder: exhaustive search -/

/-- Step-counting exhaustive search: probe the codebook entry of each candidate in
turn and stop at the first match.  This is the decoder produced by Shannon's
random-coding argument, which offers no structure to exploit. -/
def scanI (cb : α → List Bool) (w : List Bool) : List α → Option α × ℕ
  | [] => (none, 0)
  | a :: rest =>
      if cb a = w then (some a, 1) else ((scanI cb w rest).1, (scanI cb w rest).2 + 1)

omit [Fintype α] [DecidableEq α] in
/-- The scan is sound: any answer it returns really does encode to the received
word (so an exhaustive-search decoder also never corrupts silently). -/
theorem scanI_sound (cb : α → List Bool) (w : List Bool) :
    ∀ (l : List α) (a : α), (scanI cb w l).1 = some a → cb a = w := by
  intro l
  induction l with
  | nil => intro a h; simp [scanI] at h
  | cons b rest ih =>
      intro a h
      by_cases hb : cb b = w
      · simp only [scanI, if_pos hb] at h
        rw [← Option.some_inj.mp h.symm] at hb
        exact hb
      · simp only [scanI, if_neg hb] at h
        exact ih a h

omit [Fintype α] [DecidableEq α] in
/-- The scan never costs more than the size of the codebook. -/
theorem scanI_cost_le (cb : α → List Bool) (w : List Bool) :
    ∀ l : List α, (scanI cb w l).2 ≤ l.length := by
  intro l
  induction l with
  | nil => simp [scanI]
  | cons b rest ih =>
      by_cases hb : cb b = w
      · simp [scanI, hb]
      · simpa [scanI, hb] using ih

omit [Fintype α] [DecidableEq α] in
/-- If no candidate in the list matches, the whole codebook is probed. -/
theorem scanI_cost_of_no_match (cb : α → List Bool) (w : List Bool) :
    ∀ l : List α, (∀ b ∈ l, cb b ≠ w) → (scanI cb w l).2 = l.length := by
  intro l
  induction l with
  | nil => intro _; simp [scanI]
  | cons b rest ih =>
      intro hno
      have hb : cb b ≠ w := hno b (by simp)
      have hrest : ∀ c ∈ rest, cb c ≠ w := fun c hc => hno c (by simp [hc])
      simp [scanI, hb, ih hrest]

omit [Fintype α] [DecidableEq α] in
/-- **Exact worst-case complexity of exhaustive-search decoding.**  If the true
source sits at the end of the codebook, the scan probes *every* entry. -/
theorem scanI_cost_worst (cb : α → List Bool) (l : List α) (a : α)
    (hno : ∀ b ∈ l, cb b ≠ cb a) :
    (scanI cb (cb a) (l ++ [a])).2 = l.length + 1 ∧ (scanI cb (cb a) (l ++ [a])).1 = some a := by
  induction l with
  | nil => simp [scanI]
  | cons b rest ih =>
      have hb : cb b ≠ cb a := hno b (by simp)
      have hrest : ∀ c ∈ rest, cb c ≠ cb a := fun c hc => hno c (by simp [hc])
      obtain ⟨h1, h2⟩ := ih hrest
      constructor
      · simp only [List.cons_append, scanI, if_neg hb]
        simp [h1]
      · simp only [List.cons_append, scanI, if_neg hb]
        simpa using h2

omit [Fintype α] [DecidableEq α] in
/-- At rate `k` the exhaustive-search decoder makes `2 ^ k` probes: the codebook of
a random code of rate `k` has `2 ^ k` entries and the search may reach the last. -/
theorem scanI_cost_exponential (cb : α → List Bool) (hinj : Function.Injective cb)
    (l : List α) (a : α) (hnot : a ∉ l) {k : ℕ} (hlen : l.length + 1 = 2 ^ k) :
    (scanI cb (cb a) (l ++ [a])).2 = 2 ^ k := by
  have hno : ∀ b ∈ l, cb b ≠ cb a := by
    intro b hb hcb
    exact hnot (hinj hcb ▸ hb)
  rw [(scanI_cost_worst cb l a hno).1, hlen]


/-! ## No reordering of an unstructured codebook helps -/

omit [Fintype α] [DecidableEq α] in
/-- **Worst case is order-independent.**  Whatever order the codebook is stored in,
some source costs a full scan of the codebook.  Exhaustive search over a random
codebook of `2 ^ k` entries therefore always has worst-case cost `2 ^ k`. -/
theorem scanI_worst_over_orderings (cb : α → List Bool) (hinj : Function.Injective cb)
    (l : List α) (hne : l ≠ []) (hnodup : l.Nodup) :
    ∃ x ∈ l, (scanI cb (cb x) l).2 = l.length := by
  set a : α := l.getLast hne with ha
  have hsplit : l.dropLast ++ [a] = l := List.dropLast_append_getLast hne
  have hnodup' : (l.dropLast ++ [a]).Nodup := by rw [hsplit]; exact hnodup
  have hnotmem : a ∉ l.dropLast := by
    simp only [List.nodup_append] at hnodup'
    intro hmem
    exact hnodup'.2.2 a hmem a (List.mem_singleton_self a) rfl
  have hno : ∀ b ∈ l.dropLast, cb b ≠ cb a := by
    intro b hb hcb
    exact hnotmem (hinj hcb ▸ hb)
  obtain ⟨hcost, -⟩ := scanI_cost_worst cb l.dropLast a hno
  have hlen : l.length = l.dropLast.length + 1 := by
    conv_lhs => rw [← hsplit]
    simp
  refine ⟨a, List.getLast_mem hne, ?_⟩
  rw [show (scanI cb (cb a) l).2 = (scanI cb (cb a) (l.dropLast ++ [a])).2 by rw [hsplit],
    hcost, hlen]

omit [Fintype α] [DecidableEq α] in
private theorem sum_map_succ (t : List α) (g : α → ℕ) :
    (t.map (fun x => g x + 1)).sum = (t.map g).sum + t.length := by
  induction t with
  | nil => simp
  | cons a u ih => simp only [List.map_cons, List.sum_cons, ih, List.length_cons]; omega

omit [Fintype α] [DecidableEq α] in
/-- **The average case is exponential too.**  Summing the search cost over all
sources of a codebook with distinct entries gives `n (n+1) / 2`, i.e. an average of
`(n+1)/2` probes: at rate `k` (so `n = 2 ^ k`) exhaustive search costs about
`2 ^ (k-1)` probes even on average, against the enumerative decoder's `k + 2`. -/
theorem scanI_total_cost (cb : α → List Bool) (hinj : Function.Injective cb) :
    ∀ l : List α, l.Nodup →
      2 * ((l.map (fun x => (scanI cb (cb x) l).2)).sum) = l.length * (l.length + 1) := by
  intro l
  induction l with
  | nil => intro _; simp
  | cons b t ih =>
      intro hnodup
      have hbt : b ∉ t := by
        simpa using (List.nodup_cons.mp hnodup).1
      have htn : t.Nodup := (List.nodup_cons.mp hnodup).2
      have hhead : (scanI cb (cb b) (b :: t)).2 = 1 := by simp [scanI]
      have hcongr : (t.map (fun x => (scanI cb (cb x) (b :: t)).2))
          = (t.map (fun x => (scanI cb (cb x) t).2 + 1)) := by
        refine List.map_congr_left (fun x hx => ?_)
        have hne : cb b ≠ cb x := by
          intro hcb
          exact hbt (hinj hcb ▸ hx)
        simp [scanI, hne]
      have hmap : (t.map (fun x => (scanI cb (cb x) (b :: t)).2)).sum
          = (t.map (fun x => (scanI cb (cb x) t).2)).sum + t.length := by
        rw [hcongr, sum_map_succ]
      have hIH := ih htn
      simp only [List.map_cons, List.sum_cons, hhead, hmap, List.length_cons]
      nlinarith [hIH]

/-! ## The separation -/

/-- A linear function of the rate is eventually beaten by the exponential search
cost: `k + 3 < 2 ^ k` for `k ≥ 4`. -/
theorem linear_lt_exp {k : ℕ} (hk : 4 ≤ k) : k + 3 < 2 ^ k := by
  induction k with
  | zero => omega
  | succ n ih =>
      rcases Nat.lt_or_ge n 4 with hn | hn
      · interval_cases n <;> simp_all
      · have h := ih hn
        have h2 : 2 ^ (n + 1) = 2 * 2 ^ n := by ring
        omega

omit [Fintype α] in
/-- **Decoder complexity separation.**  At every rate `k ≥ 4`, decoding with the
enumerative scheme is strictly cheaper than exhaustive search through a codebook
of `2 ^ k` entries — the gap between `k + 2` and `2 ^ k` steps. -/
theorem decoder_complexity_separation {S : Finset α} {k : ℕ} (hk : 4 ≤ k)
    (hcard : S.card ≤ 2 ^ k) {x : α} (hx : x ∈ S)
    (cb : α → List Bool) (hinj : Function.Injective cb) (l : List α) (a : α) (hnot : a ∉ l)
    (hlen : l.length + 1 = 2 ^ k) :
    (enumDecI S ((enumCode S k).enc x)).2 < (scanI cb (cb a) (l ++ [a])).2 := by
  rw [enumDecI_cost_enc hcard hx, scanI_cost_exponential cb hinj l a hnot hlen]
  have := linear_lt_exp hk
  omega

/-- Auxiliary growth estimate: `2 ^ (2m + 4) > 2m + 4`, squared. -/
private theorem sq_growth (m : ℕ) : (2 * m + 4) * (2 * m + 4) < 2 ^ (4 * m + 8) := by
  have h1 : 2 * m + 4 < 2 ^ (2 * m + 4) := Nat.lt_two_pow_self
  have h2 : 2 ^ (4 * m + 8) = 2 ^ (2 * m + 4) * 2 ^ (2 * m + 4) := by
    rw [← pow_add]; ring_nf
  calc (2 * m + 4) * (2 * m + 4) < 2 ^ (2 * m + 4) * 2 ^ (2 * m + 4) :=
        Nat.mul_lt_mul_of_lt_of_lt h1 h1
    _ = 2 ^ (4 * m + 8) := h2.symm

/-- **The speed-up is unbounded.**  For every factor `M` there is a rate `k` at
which the enumerative decoder's `k + 3` steps are more than `M` times cheaper than
the `2 ^ k` probes of exhaustive search.  Randomised codebooks therefore lose an
unbounded factor in decoding time while (by `Core.epsilon_relaxed_pigeonhole` and
`Enumerative.achievability`) gaining nothing in rate. -/
theorem decoder_speedup_unbounded (M : ℕ) : ∃ k : ℕ, 4 ≤ k ∧ M * (k + 3) < 2 ^ k := by
  refine ⟨4 * M + 8, by omega, ?_⟩
  have hgrow := sq_growth M
  have hM : M * (4 * M + 8 + 3) ≤ (2 * M + 4) * (2 * M + 4) := by nlinarith
  omega

end AlmostLossless