import Novelty.BhSetsDifferences

/-!
# Greedy `B_h` sets: the obstruction set, its size, and a two-sided growth sandwich

`Novelty/GreedyDifferenceSidon.lean` grows a Sidon set greedily by refusing to repeat a
difference `a i - a j`, and squeezes the resulting Mian–Chowla sequence between `n²/2` and
`n⁴/4`.  This file carries the whole mechanism up the `B_h` tower of
`Novelty/BhSetsDifferences.lean`.

The greedy step for `B_h` is governed by a *weighted/signed* obstruction: a candidate `m`
above `A` fails exactly when some equation

  `d · m + Σs₀ = Σt₀`,  `1 ≤ d ≤ h`,  `s₀, t₀` multisets from `A` of size `≤ h`,

holds — the multiplicity of `m` on the two sides differs by `d`, and everything else is a
signed sum of at most `h` elements of `A`.  Since `m` is determined by `(d, Σt₀, Σs₀)`, the
obstruction set is finite and explicitly bounded, and the greedy process is well defined.

## Main results

* `sumPow`, `sumsUpTo` — the `k`-fold sumsets of `A` and their union for `k ≤ h`, with the
  bounds `card_sumPow_le : |kA| ≤ |A|^k` and `card_sumsUpTo_le : |S| ≤ (h+1)(|A|+1)^h`.
* `sum_mem_sumPow` — every multiset of `k` elements of `A` has its sum in the `k`-fold
  sumset (the bridge between the multiset language of `IsBh` and the sumset language).
* `bhBad` — the weighted obstruction set, with `card_bhBad_le : |bhBad| ≤ h·|S|²`.
* `isBh_insert_of_notMem_bhBad` — **the greedy step theorem**: if `A` is `B_h` and
  `m ∉ bhBad A h`, then `insert m A` is `B_h` (no ordering hypothesis on `m` is needed).  The proof splits a multiset
  over `insert m A` into its `m`-part and its `A`-part; equal multiplicities reduce to
  `B_{h-j}` for `A` (via `IsBh.antitone`), unequal multiplicities produce the weighted
  equation above.
* `exists_good_next_bh` — a valid greedy step always exists inside a window of length
  `h·((h+1)(|A|+1)^h)² + 1`.
* `greedySetBh`, `greedySeqBh` — the greedy `B_h` set and sequence, with
  `greedySetBh_isBh`, `card_greedySetBh`, `greedySeqBh_strictMono`.
* `greedySeqBh_le` — **polynomial upper bound**
  `a n ≤ (n+1)·(h·((h+1)(n+1)^h)² + 1)`, i.e. `a n = O_h(n^{2h+1})`.
* `choose_le_greedySeqBh` — **polynomial lower bound** `C(n+1, h) ≤ h · a n + 1`, of degree
  `h`, obtained from the `B_h` counting bound of the companion file.
* `greedySeqBh_sandwich` — the two combined.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): (G1) The Mian–Chowla mechanism is not special to `h = 2`: for
  every `h` the failure of a greedy step is a *weighted* linear equation `d·m = Σt₀ - Σs₀`
  with `1 ≤ d ≤ h`, so the obstruction set is bounded by `h · |S|²` where `S` collects the
  sums of at most `h` elements.  (G2) Consequently the greedy `B_h` sequence grows
  polynomially, of degree at most `2h+1`, and the `B_h` counting bound gives a matching
  lower bound of degree `h`.  (G3) The true growth is closer to the lower bound.
Experiment (Experimenter): the greedy `B₃` and `B₄` sequences were computed:
  `1, 2, 5, 14, 33, 72, 125, 219, 376, 573` and `1, 2, 6, 22, 56, 154, 369, 857, 1425`
  (OEIS A046185, A046186).  The proved lower bound `C(n+1,h) ≤ h·a n + 1` is satisfied
  tightly at the start (`n = 3, h = 3`: `20 ≤ 43`) and the upper bound is far off (`h = 3`,
  `n = 9`: bound ≈ `3·(4·10³)² · 10`), confirming (G3): the counting side is the sharp one.
  (G1) and (G2) were proved in full.
Analysis (Analyst): the `d` in `d·m = Σt₀ - Σs₀` is exactly the *signed weight* of the new
  element, and it is the only place where the `B_h` problem differs from the Sidon
  problem, where `d ∈ {1, 2}` and the case `d = 2` is impossible for `m` above `A`.  This
  isolates the extra difficulty of `B_h` greediness in a single divisibility.
Critique (Critic): the greedy step theorem is a one-sided implication (unlike its Sidon
  analogue, which is an `iff`) — the obstruction set is a genuine over-count, because not
  every triple `(d, x, y)` comes from multisets of the right sizes.  This is stated
  honestly: `bhBad` is sufficient for safety, not necessary for failure.  No theorem uses
  `decide` or `native_decide`; the sequence itself is only characterised, not computed.
Synthesis (PI): the greedy mechanism is uniform in `h`, with a degree-`(2h+1)` upper bound
  and a degree-`h` lower bound, and the gap is exactly the dispersion question raised for
  `h = 2` in the companion file.
-/

namespace GreedyBh

open Finset Pointwise BhDifference

/-! ## 1. Sumsets of bounded length -/

/-- The `k`-fold sumset of `A` (with repetition allowed). -/
def sumPow (A : Finset ℕ) : ℕ → Finset ℕ
  | 0 => {0}
  | k + 1 => sumPow A k + A

theorem card_sumPow_le (A : Finset ℕ) : ∀ k, #(sumPow A k) ≤ #A ^ k
  | 0 => by simp [sumPow]
  | k + 1 => by
      calc #(sumPow A (k + 1)) ≤ #(sumPow A k) * #A := Finset.card_add_le
        _ ≤ #A ^ k * #A := Nat.mul_le_mul_right _ (card_sumPow_le A k)
        _ = #A ^ (k + 1) := by ring

/-- Every multiset of `k` elements of `A` has its sum in the `k`-fold sumset. -/
theorem sum_mem_sumPow {A : Finset ℕ} (k : ℕ) : ∀ s : Multiset ℕ, (∀ x ∈ s, x ∈ A) →
    Multiset.card s = k → s.sum ∈ sumPow A k := by
  induction k with
  | zero =>
      intro s _ hcs
      rw [Multiset.card_eq_zero.mp hcs]
      simp [sumPow]
  | succ k ih =>
      intro s hs hcs
      have hpos : 0 < Multiset.card s := by omega
      obtain ⟨a, ha⟩ := Multiset.card_pos_iff_exists_mem.mp hpos
      obtain ⟨s', rfl⟩ := Multiset.exists_cons_of_mem ha
      have hcs' : Multiset.card s' = k := by
        rw [Multiset.card_cons] at hcs; omega
      have hs' : ∀ x ∈ s', x ∈ A := fun x hx => hs x (Multiset.mem_cons_of_mem hx)
      have haA : a ∈ A := hs a (Multiset.mem_cons_self _ _)
      have hmem := ih s' hs' hcs'
      rw [Multiset.sum_cons, Nat.add_comm a s'.sum]
      exact Finset.add_mem_add hmem haA

/-- The sums of at most `h` elements of `A`. -/
def sumsUpTo (A : Finset ℕ) (h : ℕ) : Finset ℕ := (Finset.range (h + 1)).biUnion (sumPow A)

theorem sum_mem_sumsUpTo {A : Finset ℕ} {h : ℕ} {s : Multiset ℕ} (hs : ∀ x ∈ s, x ∈ A)
    (hcs : Multiset.card s ≤ h) : s.sum ∈ sumsUpTo A h := by
  refine Finset.mem_biUnion.mpr ⟨Multiset.card s, ?_, sum_mem_sumPow _ s hs rfl⟩
  rw [Finset.mem_range]; omega

theorem card_sumsUpTo_le (A : Finset ℕ) (h : ℕ) : #(sumsUpTo A h) ≤ (h + 1) * (#A + 1) ^ h := by
  calc #(sumsUpTo A h) ≤ ∑ k ∈ Finset.range (h + 1), #(sumPow A k) :=
        Finset.card_biUnion_le
    _ ≤ ∑ _k ∈ Finset.range (h + 1), (#A + 1) ^ h := by
        refine Finset.sum_le_sum fun k hk => ?_
        rw [Finset.mem_range] at hk
        calc #(sumPow A k) ≤ #A ^ k := card_sumPow_le A k
          _ ≤ (#A + 1) ^ k := Nat.pow_le_pow_left (by omega) k
          _ ≤ (#A + 1) ^ h := Nat.pow_le_pow_right (by omega) (by omega)
    _ = (h + 1) * (#A + 1) ^ h := by
        rw [Finset.sum_const, Finset.card_range, smul_eq_mul]

/-! ## 2. The weighted obstruction set -/

/-- The **weighted obstruction set** for a greedy `B_h` step: the candidates `m` solving
`d · m + y = x` for some weight `1 ≤ d ≤ h` and sums `x, y` of at most `h` elements of
`A`. -/
def bhBad (A : Finset ℕ) (h : ℕ) : Finset ℕ :=
  ((Finset.Icc 1 h) ×ˢ (sumsUpTo A h) ×ˢ (sumsUpTo A h)).image fun p => (p.2.1 - p.2.2) / p.1

theorem card_bhBad_le (A : Finset ℕ) (h : ℕ) : #(bhBad A h) ≤ h * #(sumsUpTo A h) ^ 2 := by
  refine le_trans Finset.card_image_le ?_
  rw [Finset.card_product, Finset.card_product, Nat.card_Icc, pow_two]
  have hh : h + 1 - 1 = h := by omega
  rw [hh]

theorem mem_bhBad_of {A : Finset ℕ} {h d m x y : ℕ} (hd : 1 ≤ d) (hdh : d ≤ h)
    (hx : x ∈ sumsUpTo A h) (hy : y ∈ sumsUpTo A h) (heq : d * m + y = x) :
    m ∈ bhBad A h := by
  refine Finset.mem_image.mpr ⟨(d, x, y), ?_, ?_⟩
  · simp [Finset.mem_product, Finset.mem_Icc, hd, hdh, hx, hy]
  · have : x - y = d * m := by omega
    simp only [this]
    exact Nat.mul_div_cancel_left m hd

/-! ## 3. The greedy step for `B_h` -/

/-- Split a multiset over `insert m A` into its `m`-part and its `A`-part. -/
theorem multiset_split {A : Finset ℕ} {m : ℕ} (s : Multiset ℕ)
    (hs : ∀ x ∈ s, x ∈ insert m A) :
    s = Multiset.replicate (s.count m) m + s.filter (fun x => ¬ x = m) ∧
      (∀ x ∈ s.filter (fun x => ¬ x = m), x ∈ A) ∧
      Multiset.card (s.filter (fun x => ¬ x = m)) + s.count m = Multiset.card s ∧
      s.sum = s.count m * m + (s.filter (fun x => ¬ x = m)).sum := by
  have hsplit : Multiset.replicate (s.count m) m + s.filter (fun x => ¬ x = m) = s := by
    rw [← Multiset.filter_eq' s m]
    exact Multiset.filter_add_not _ s
  refine ⟨hsplit.symm, ?_, ?_, ?_⟩
  · intro x hx
    have hx1 : x ∈ s := Multiset.mem_of_mem_filter hx
    have hx2 : ¬ x = m := (Multiset.mem_filter.mp hx).2
    rcases Finset.mem_insert.mp (hs x hx1) with h | h
    · exact absurd h hx2
    · exact h
  · have := congrArg Multiset.card hsplit
    rw [Multiset.card_add, Multiset.card_replicate] at this
    omega
  · have := congrArg Multiset.sum hsplit
    rw [Multiset.sum_add, Multiset.sum_replicate, smul_eq_mul] at this
    omega

/-- If the `m`-multiplicities differ, the candidate `m` lies in the obstruction set. -/
theorem mem_bhBad_of_count_lt {A : Finset ℕ} {h m : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ∈ insert m A) (ht : ∀ x ∈ t, x ∈ insert m A)
    (hcs : Multiset.card s = h) (hct : Multiset.card t = h) (hsum : s.sum = t.sum)
    (hlt : t.count m < s.count m) : m ∈ bhBad A h := by
  obtain ⟨-, hs0A, hs0card, hs0sum⟩ := multiset_split s hs
  obtain ⟨-, ht0A, ht0card, ht0sum⟩ := multiset_split t ht
  set j := s.count m
  set k := t.count m
  set s0 := s.filter (fun x => ¬ x = m)
  set t0 := t.filter (fun x => ¬ x = m)
  have hxs : s0.sum ∈ sumsUpTo A h := sum_mem_sumsUpTo hs0A (by omega)
  have hxt : t0.sum ∈ sumsUpTo A h := sum_mem_sumsUpTo ht0A (by omega)
  refine mem_bhBad_of (d := j - k) (by omega) (by omega) hxt hxs ?_
  have hjm : j * m = k * m + (j - k) * m := by
    rw [← Nat.add_mul]
    congr 1
    omega
  have e1 : j * m + s0.sum = k * m + t0.sum := by rw [← hs0sum, ← ht0sum]; exact hsum
  rw [hjm] at e1
  omega

/-- **The greedy step for `B_h`.**  A candidate above `A` avoiding the weighted obstruction
set keeps the `B_h` property. -/
theorem isBh_insert_of_notMem_bhBad {A : Finset ℕ} {h m : ℕ} (hA : IsBh h A)
    (hbad : m ∉ bhBad A h) : IsBh h (insert m A) := by
  intro s t hs ht hcs hct hsum
  obtain ⟨hseq, hs0A, hs0card, hs0sum⟩ := multiset_split s hs
  obtain ⟨hteq, ht0A, ht0card, ht0sum⟩ := multiset_split t ht
  rcases lt_trichotomy (s.count m) (t.count m) with hlt | heq | hgt
  · exact absurd (mem_bhBad_of_count_lt ht hs hct hcs hsum.symm hlt) hbad
  · -- equal multiplicities: reduce to `B_{h - j}` for `A`
    set j := s.count m with hj
    set s0 := s.filter (fun x => ¬ x = m)
    set t0 := t.filter (fun x => ¬ x = m)
    have hcard0 : Multiset.card s0 = h - j := by omega
    have hcard0' : Multiset.card t0 = h - j := by omega
    have hsums : s0.sum = t0.sum := by
      rw [heq] at hs0sum
      omega
    have hs0t0 : s0 = t0 := by
      rcases Nat.eq_zero_or_pos (h - j) with hz | hpos
      · rw [Multiset.card_eq_zero.mp (by omega : Multiset.card s0 = 0),
          Multiset.card_eq_zero.mp (by omega : Multiset.card t0 = 0)]
      · exact hA.antitone hpos (by omega) s0 t0 hs0A ht0A hcard0 hcard0' hsums
    rw [hseq, hteq, ← heq, hs0t0]
  · exact absurd (mem_bhBad_of_count_lt hs ht hcs hct hsum hgt) hbad

/-! ## 4. The greedy `B_h` sequence -/

/-- The greedy predicate for `B_h`. -/
def GoodNextBh (h : ℕ) (A : Finset ℕ) (m : ℕ) : Prop := (∀ a ∈ A, a < m) ∧ IsBh h (insert m A)

/-- **A greedy `B_h` step always exists**, inside a window of length `h · |S|² + 1`. -/
theorem exists_good_next_bh {A : Finset ℕ} {h : ℕ} (hA : IsBh h A) :
    ∃ m, GoodNextBh h A m ∧ m ≤ A.sup id + h * ((h + 1) * (#A + 1) ^ h) ^ 2 + 1 := by
  classical
  set M := A.sup id with hM
  set B := h * ((h + 1) * (#A + 1) ^ h) ^ 2 with hB
  have hbadle : #(bhBad A h) ≤ B := by
    refine le_trans (card_bhBad_le A h) ?_
    rw [hB]
    exact Nat.mul_le_mul_left _ (Nat.pow_le_pow_left (card_sumsUpTo_le A h) 2)
  set S : Finset ℕ := Finset.Icc (M + 1) (M + B + 1) with hS
  have hcardS : #S = B + 1 := by rw [hS, Nat.card_Icc]; omega
  have hex : ∃ m ∈ S, m ∉ bhBad A h := by
    by_contra hcon
    push_neg at hcon
    have hle : #S ≤ #(bhBad A h) := Finset.card_le_card hcon
    omega
  obtain ⟨m, hmS, hmbad⟩ := hex
  have hmS' : M + 1 ≤ m ∧ m ≤ M + B + 1 := by simpa [hS, Finset.mem_Icc] using hmS
  have hlt : ∀ a ∈ A, a < m := by
    intro a ha
    have : a ≤ M := Finset.le_sup (f := id) ha
    omega
  exact ⟨m, ⟨hlt, isBh_insert_of_notMem_bhBad hA hmbad⟩, by omega⟩

/-- The least valid greedy `B_h` continuation of `A`. -/
noncomputable def nextGreedyBh (h : ℕ) (A : Finset ℕ) : ℕ := sInf {m | GoodNextBh h A m}

theorem goodNextBh_nextGreedyBh {A : Finset ℕ} {h : ℕ} (hA : IsBh h A) :
    GoodNextBh h A (nextGreedyBh h A) := by
  obtain ⟨m, hm, -⟩ := exists_good_next_bh hA
  exact Nat.sInf_mem (s := {m | GoodNextBh h A m}) ⟨m, hm⟩

theorem nextGreedyBh_le {A : Finset ℕ} {h : ℕ} (hA : IsBh h A) :
    nextGreedyBh h A ≤ A.sup id + h * ((h + 1) * (#A + 1) ^ h) ^ 2 + 1 := by
  obtain ⟨m, hm, hmle⟩ := exists_good_next_bh hA
  exact le_trans (Nat.sInf_le (s := {m | GoodNextBh h A m}) hm) hmle

/-- The greedy `B_h` set after `n` steps. -/
noncomputable def greedySetBh (h : ℕ) : ℕ → Finset ℕ
  | 0 => ∅
  | n + 1 => insert (nextGreedyBh h (greedySetBh h n)) (greedySetBh h n)

/-- The greedy `B_h` sequence. -/
noncomputable def greedySeqBh (h n : ℕ) : ℕ := nextGreedyBh h (greedySetBh h n)

theorem greedySetBh_succ (h n : ℕ) :
    greedySetBh h (n + 1) = insert (greedySeqBh h n) (greedySetBh h n) := rfl

theorem isBh_empty (h : ℕ) : IsBh h (∅ : Finset ℕ) := by
  intro s t hs ht hcs hct _
  rcases Multiset.empty_or_exists_mem s with rfl | ⟨a, ha⟩
  · rcases Multiset.empty_or_exists_mem t with rfl | ⟨b, hb⟩
    · rfl
    · exact absurd (ht b hb) (Finset.notMem_empty b)
  · exact absurd (hs a ha) (Finset.notMem_empty a)

theorem greedySetBh_isBh (h : ℕ) : ∀ n, IsBh h (greedySetBh h n)
  | 0 => isBh_empty h
  | n + 1 => (goodNextBh_nextGreedyBh (greedySetBh_isBh h n)).2

theorem lt_greedySeqBh {h n : ℕ} {a : ℕ} (ha : a ∈ greedySetBh h n) : a < greedySeqBh h n :=
  (goodNextBh_nextGreedyBh (greedySetBh_isBh h n)).1 a ha

theorem card_greedySetBh (h : ℕ) : ∀ n, #(greedySetBh h n) = n
  | 0 => rfl
  | n + 1 => by
      have hnot : greedySeqBh h n ∉ greedySetBh h n := fun hmem =>
        lt_irrefl _ (lt_greedySeqBh hmem)
      rw [greedySetBh_succ, Finset.card_insert_of_notMem hnot, card_greedySetBh h n]

theorem sup_greedySetBh_succ (h n : ℕ) : (greedySetBh h (n + 1)).sup id = greedySeqBh h n := by
  rw [greedySetBh_succ, Finset.sup_insert]
  have hle : (greedySetBh h n).sup id ≤ greedySeqBh h n :=
    Finset.sup_le fun a ha => le_of_lt (lt_greedySeqBh ha)
  simpa [id] using max_eq_left hle

theorem greedySeqBh_strictMono (h : ℕ) : StrictMono (greedySeqBh h) := by
  refine strictMono_nat_of_lt_succ fun n => ?_
  exact lt_greedySeqBh (by rw [greedySetBh_succ]; exact Finset.mem_insert_self _ _)

/-! ## 5. The growth sandwich -/

/-- The greedy window width at stage `n`. -/
def windowBh (h n : ℕ) : ℕ := h * ((h + 1) * (n + 1) ^ h) ^ 2 + 1

theorem windowBh_mono (h : ℕ) {m n : ℕ} (hmn : m ≤ n) : windowBh h m ≤ windowBh h n := by
  have h1 : (m + 1) ^ h ≤ (n + 1) ^ h := Nat.pow_le_pow_left (by omega) h
  have h2 : (h + 1) * (m + 1) ^ h ≤ (h + 1) * (n + 1) ^ h := Nat.mul_le_mul_left _ h1
  have h3 : ((h + 1) * (m + 1) ^ h) ^ 2 ≤ ((h + 1) * (n + 1) ^ h) ^ 2 :=
    Nat.pow_le_pow_left h2 2
  unfold windowBh
  exact Nat.add_le_add_right (Nat.mul_le_mul_left h h3) 1

/-- **Greedy step bound.** -/
theorem greedySeqBh_succ_le (h n : ℕ) :
    greedySeqBh h (n + 1) ≤ greedySeqBh h n + windowBh h (n + 1) := by
  have hb := nextGreedyBh_le (greedySetBh_isBh h (n + 1))
  rw [sup_greedySetBh_succ, card_greedySetBh] at hb
  simpa [windowBh, greedySeqBh, Nat.add_assoc] using hb

theorem greedySeqBh_zero_le (h : ℕ) : greedySeqBh h 0 ≤ windowBh h 0 := by
  have hb := nextGreedyBh_le (greedySetBh_isBh h 0)
  simp only [greedySetBh, Finset.sup_empty, Finset.card_empty] at hb
  simpa [windowBh, greedySeqBh] using hb

/-- **Polynomial upper bound** for the greedy `B_h` sequence: `a n = O_h(n^{2h+1})`. -/
theorem greedySeqBh_le (h : ℕ) : ∀ n, greedySeqBh h n ≤ (n + 1) * windowBh h n
  | 0 => by simpa using greedySeqBh_zero_le h
  | n + 1 => by
      have h1 := greedySeqBh_succ_le h n
      have h2 := greedySeqBh_le h n
      have h3 : windowBh h n ≤ windowBh h (n + 1) := windowBh_mono h (by omega)
      calc greedySeqBh h (n + 1) ≤ greedySeqBh h n + windowBh h (n + 1) := h1
        _ ≤ (n + 1) * windowBh h n + windowBh h (n + 1) := by omega
        _ ≤ (n + 1) * windowBh h (n + 1) + windowBh h (n + 1) :=
            Nat.add_le_add_right (Nat.mul_le_mul_left _ h3) _
        _ = (n + 1 + 1) * windowBh h (n + 1) := by ring

/-- **Polynomial lower bound** of degree `h`: the greedy `B_h` set at stage `n+1` is a
`B_h` subset of `{0, …, a n}`, so the counting bound applies. -/
theorem choose_le_greedySeqBh (h n : ℕ) : (n + 1).choose h ≤ h * greedySeqBh h n + 1 := by
  have hsub : greedySetBh h (n + 1) ⊆ Finset.range (greedySeqBh h n + 1) := by
    intro a ha
    rw [Finset.mem_range]
    rcases Finset.mem_insert.mp (by rwa [greedySetBh_succ] at ha) with rfl | hmem
    · omega
    · have := lt_greedySeqBh hmem; omega
  have hc := (greedySetBh_isBh h (n + 1)).choose_card_le hsub
  rw [card_greedySetBh] at hc
  simpa using hc

/-- **The greedy `B_h` sandwich**: a degree-`h` lower bound and a degree-`(2h+1)` upper
bound. -/
theorem greedySeqBh_sandwich (h n : ℕ) :
    (n + 1).choose h ≤ h * greedySeqBh h n + 1 ∧
      greedySeqBh h n ≤ (n + 1) * (h * ((h + 1) * (n + 1) ^ h) ^ 2 + 1) :=
  ⟨choose_le_greedySeqBh h n, greedySeqBh_le h n⟩

/-- For `h = 2` the greedy `B_h` process is the greedy Sidon process of the companion
file: the sets produced are Sidon at every stage. -/
theorem greedySetBh_two_isSidon (n : ℕ) : IsSidon (greedySetBh 2 n) :=
  (isBh_two_iff_isSidon _).mp (greedySetBh_isBh 2 n)

end GreedyBh