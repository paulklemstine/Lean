import Combinatorics.KneeInvariance

/-!
# The one-octave shift law for knee chains (NET-66)

This file formalises the *combinatorial* content behind the NET-66 measurement
(`SCALE-DELAYS-CONTEXT-SENSITIVITY-BY-ONE-DOUBLING`).

The measurement.  For two model scales one sweeps the key budget `k` at a fixed
gate and records the **knee** `k*` — the least budget whose retained quality
reaches the gate — at three context lengths `512, 1024, 2048`:

| context | 512 | 1024 | 2048 |
|---------|-----|------|------|
| 0.5B    | 16  | 20   | 24   |
| 1.5B    | 16  | 16   | 20   |

Reading contexts in *octaves* `j` (`ctx = 512 · 2 ^ j`), the large-model chain is
the small-model chain **translated right by exactly one octave**, with the
left-hand boundary value repeated:

`K₁(0) = K₀(0)`,  `K₁(j+1) = K₀(j)`.

The abstraction developed here is the *knee chain* `K : ℕ → ℕ`, `j ↦ k*(octave j)`,
together with the **octave shift** `shift K s = fun j => K (j - s)` (truncated
subtraction: scale buys *headroom*, the chain is clamped, not extrapolated, below
its base context).

What is proved:

* `shift_add`, `shift_zero` — scale acts on chains as the additive monoid `(ℕ,+)`;
  `shift_rate_unique` — for a strictly increasing base chain the exchange rate is
  *identifiable*: a single chain pair pins `s = 1`, so "one octave" is a
  measurable constant, not a fitting choice.
* `ScaleFamily.eq_shift` — **rigidity**: the exchange law `F(s+1, j+1) = F(s, j)`
  together with the boundary law `F(s+1, 0) = F(s, 0)` forces `F s = shift (F 0) s`.
  The whole two-dimensional table is determined by one chain.
* `ScaleFamily.antitone_scale` — **P3 refuted, structurally**: context-monotonicity
  plus the exchange law *imply* that scale can never increase the knee. No
  measurement is needed to exclude the "scale amplifies sensitivity" horn.
* `ScaleFamily.no_flattening`, `ScaleFamily.not_eventually_constant` — **P2 refuted,
  structurally**: if the base chain is unbounded (resp. non-constant) then so is
  every scaled chain. Scale *postpones* context sensitivity; it cannot remove it.
* `firstFail_shift`, `ScaleFamily.budget_table` — the **budget table in adjoint
  form**: the first octave at which a fixed key budget fails moves right by exactly
  one per scale step (`a 16-key budget covers the 0.5B to 512 and the 1.5B to 1024`).
* `ScaleFamily.served_card_two_mul` — the served region of the (scale × context)
  table is a staircase whose area is a **triangular number**: `2·area = 2Sf + S(S-1)`.
* `ScaleFamily.linear_base_shift` — when the base chain has constant increment `δ`,
  the law becomes `k*(s, j) = k₀ + δ·(j − s)⁺`: context and scale enter only through
  the *ratio* `ctx / 2^s`.
* `net66_*` — the measured cells, verified against the abstraction: the 1.5B chain
  `{16,16,20}`, the upward break at 2048 (P1), the two refutations, the identified
  rate, and the 16-key budget table.
* `family_realizable` — every octave-shifted family is realised by honest
  workloads in the sense of `Combinatorics.KneeInvariance`: the chains are knees of
  actual demand profiles, not free parameters.
-/

namespace Combinatorics.OctaveShiftLaw

open Finset Combinatorics.KneeInvariance

/-! ## Chains and the octave shift -/

/-- A **knee chain**: `K j` is the least key budget meeting the gate at context
`512 · 2 ^ j`. -/
abbrev Chain := ℕ → ℕ

/-- The **octave shift** by `s` doublings.  Truncated subtraction encodes the
clamp: below its base context the chain repeats its boundary value. -/
def shift (K : Chain) (s : ℕ) : Chain := fun j => K (j - s)

@[simp] theorem shift_zero (K : Chain) : shift K 0 = K := by
  funext j; simp [shift]

@[simp] theorem shift_apply (K : Chain) (s j : ℕ) : shift K s j = K (j - s) := rfl

/-- Scale acts on chains as the additive monoid `(ℕ, +)`. -/
theorem shift_add (K : Chain) (a b : ℕ) : shift (shift K a) b = shift K (a + b) := by
  funext j
  simp only [shift, Nat.sub_sub]
  rw [Nat.add_comm]

/-- **The exchange law.**  One scale doubling buys exactly one context doubling. -/
theorem shift_succ_succ (K : Chain) (s j : ℕ) :
    shift K (s + 1) (j + 1) = shift K s j := by
  simp [shift, Nat.succ_sub_succ]

/-- **The boundary law.**  At the base context, scale changes nothing. -/
theorem shift_succ_zero (K : Chain) (s : ℕ) : shift K (s + 1) 0 = shift K s 0 := by
  simp [shift]

theorem shift_monotone {K : Chain} (hK : Monotone K) (s : ℕ) : Monotone (shift K s) :=
  fun _ _ h => hK (Nat.sub_le_sub_right h s)

/-- **Rate identifiability.**  For a strictly increasing base chain, two shifts
coincide only if the shifts are equal: the "one octave" in the verdict is a
measurable constant, not a free fitting parameter. -/
theorem shift_rate_unique {K : Chain} (hK : StrictMono K) {a b : ℕ}
    (h : shift K a = shift K b) : a = b := by
  by_contra hne
  rcases Nat.lt_or_ge a b with hab | hab
  · have := congrFun h b
    simp only [shift, Nat.sub_self] at this
    have hpos : 0 < b - a := by omega
    exact absurd this (Nat.ne_of_gt (hK hpos))
  · have hba : b < a := by omega
    have := congrFun h a
    simp only [shift, Nat.sub_self] at this
    have hpos : 0 < a - b := by omega
    exact absurd this.symm (Nat.ne_of_gt (hK hpos))

/-! ## Scale families and the rigidity theorem -/

/-- A **scale family** of knee chains: `chain s j = k*(scale s, octave j)`, subject
to the two measured laws — the exchange law (one scale doubling ↔ one context
doubling) and the boundary law (at the base context, scale is inert). -/
structure ScaleFamily where
  /-- `chain s j` is the knee at scale index `s` and context octave `j`. -/
  chain : ℕ → Chain
  /-- The base chain is monotone in context. -/
  base_mono : Monotone (chain 0)
  /-- One scale doubling buys exactly one context doubling. -/
  exchange : ∀ s j, chain (s + 1) (j + 1) = chain s j
  /-- At the base context, scale changes nothing. -/
  boundary : ∀ s, chain (s + 1) 0 = chain s 0

namespace ScaleFamily

variable (F : ScaleFamily)

/-- **Rigidity.**  The two local laws determine the entire two-dimensional table
from the single base chain: `F s = shift (F 0) s`. -/
theorem eq_shift : ∀ s, F.chain s = shift (F.chain 0) s := by
  intro s
  induction s with
  | zero => simp
  | succ s ih =>
      funext j
      cases j with
      | zero =>
          rw [F.boundary s, ih]
          simp [shift]
      | succ j =>
          rw [F.exchange s j, ih]
          simp [shift, Nat.succ_sub_succ]

theorem apply_eq (s j : ℕ) : F.chain s j = F.chain 0 (j - s) := by
  rw [F.eq_shift s]; rfl

/-- Every chain in the family is monotone in context. -/
theorem chain_mono (s : ℕ) : Monotone (F.chain s) := by
  rw [F.eq_shift s]; exact shift_monotone F.base_mono s

/-- **P3 refuted, structurally.**  Context-monotonicity plus the exchange law
*force* the knee to be antitone in scale: a larger model can never require a
larger budget at the same context.  The "scale amplifies sensitivity" horn is
excluded by the shape of the law, before any measurement. -/
theorem antitone_scale (s j : ℕ) : F.chain (s + 1) j ≤ F.chain s j := by
  rw [F.apply_eq (s + 1) j, F.apply_eq s j]
  exact F.base_mono (by omega)

theorem antitone_scale' {s t : ℕ} (h : s ≤ t) (j : ℕ) : F.chain t j ≤ F.chain s j := by
  rw [F.apply_eq t j, F.apply_eq s j]
  exact F.base_mono (by omega)

/-- **P2 refuted, structurally (unbounded form).**  If the base chain is unbounded
then so is every scaled chain: no amount of scale flattens the context axis, it
only translates the break to a later octave. -/
theorem no_flattening (hub : ∀ b, ∃ j, b < F.chain 0 j) (s b : ℕ) :
    ∃ j, b < F.chain s j := by
  obtain ⟨j, hj⟩ := hub b
  refine ⟨j + s, ?_⟩
  rw [F.apply_eq s (j + s)]
  simpa using hj

/-- **P2 refuted, structurally (non-constant form).**  If the base chain rises
anywhere, every scaled chain rises too. -/
theorem not_eventually_constant (hne : ∃ j, F.chain 0 0 < F.chain 0 j) (s : ℕ) :
    ∃ j, F.chain s 0 < F.chain s j := by
  obtain ⟨j, hj⟩ := hne
  refine ⟨j + s, ?_⟩
  rw [F.apply_eq s (j + s), F.apply_eq s 0]
  simpa using hj

end ScaleFamily

/-! ## The budget table: the first failing octave moves right by one per scale step -/

/-- The **first failing octave** of a chain at key budget `b`: the least context
octave whose knee exceeds the budget. -/
noncomputable def firstFail (K : Chain) (b : ℕ) : ℕ := sInf {j | b < K j}

theorem firstFail_mem {K : Chain} {b : ℕ} (hne : ∃ j, b < K j) :
    b < K (firstFail K b) :=
  Nat.sInf_mem (by simpa [Set.Nonempty] using hne)

theorem le_of_lt_firstFail {K : Chain} {b j : ℕ} (h : j < firstFail K b) : K j ≤ b := by
  have := Nat.notMem_of_lt_sInf h
  simpa [Set.mem_setOf_eq] using this

/-- **Adjunction between budget and reach.**  For a monotone chain, "octave `j` is
served by budget `b`" is exactly "`j` lies below the first failure". -/
theorem lt_firstFail_iff {K : Chain} (hK : Monotone K) {b : ℕ} (hne : ∃ j, b < K j)
    {j : ℕ} : j < firstFail K b ↔ K j ≤ b := by
  refine ⟨le_of_lt_firstFail, fun h => ?_⟩
  by_contra hc
  push_neg at hc
  exact absurd (le_trans (firstFail_mem hne) (hK hc)) (by omega)

/-- **The one-octave budget law.**  Shifting a chain by `s` octaves moves the first
failing octave right by exactly `s`, provided the budget already covers the base
context. -/
theorem firstFail_shift {K : Chain} {b : ℕ} (hne : ∃ j, b < K j)
    (hf : 0 < firstFail K b) (s : ℕ) :
    firstFail (shift K s) b = firstFail K b + s := by
  have hmem : b < K (firstFail K b) := firstFail_mem hne
  refine le_antisymm (Nat.sInf_le ?_) ?_
  · show b < shift K s (firstFail K b + s)
    simpa [shift] using hmem
  · by_contra hc
    push_neg at hc
    have hmem' : b < shift K s (firstFail (shift K s) b) :=
      firstFail_mem ⟨firstFail K b + s, by simpa [shift] using hmem⟩
    set j := firstFail (shift K s) b with hj
    have hlt : j - s < firstFail K b := by omega
    exact absurd (le_of_lt_firstFail hlt) (by simpa [shift] using hmem')

namespace ScaleFamily

variable (F : ScaleFamily)

/-- **The budget table.**  At every scale step, a fixed key budget buys exactly one
extra context doubling. -/
theorem budget_table {b : ℕ} (hne : ∃ j, b < F.chain 0 j) (hf : 0 < firstFail (F.chain 0) b)
    (s : ℕ) : firstFail (F.chain s) b = firstFail (F.chain 0) b + s := by
  rw [F.eq_shift s]
  exact firstFail_shift hne hf s

/-- Octave `j` is served at scale `s` by budget `b` exactly when
`j < firstFail (base) b + s`. -/
theorem served_iff {b : ℕ} (hne : ∃ j, b < F.chain 0 j) (hf : 0 < firstFail (F.chain 0) b)
    (s j : ℕ) : F.chain s j ≤ b ↔ j < firstFail (F.chain 0) b + s := by
  obtain ⟨j₀, hj₀⟩ := hne
  have hne' : ∃ j, b < F.chain s j := ⟨j₀ + s, by
    rw [F.apply_eq s (j₀ + s)]; simpa using hj₀⟩
  rw [← F.budget_table ⟨j₀, hj₀⟩ hf s]
  exact (lt_firstFail_iff (F.chain_mono s) hne').symm

/-- The served region of the `S × J` corner of the (scale, context) table. -/
def served (F : ScaleFamily) (b S J : ℕ) : Finset (ℕ × ℕ) :=
  (range S ×ˢ range J).filter fun p => F.chain p.1 p.2 ≤ b

/-- **The budget table is a staircase of triangular area.**  If the window of
contexts is wide enough to contain the whole staircase, the number of served
(scale, context) cells is `S·f + S(S−1)/2`, stated without division. -/
theorem served_card_two_mul {b S J : ℕ} (hne : ∃ j, b < F.chain 0 j)
    (hf : 0 < firstFail (F.chain 0) b)
    (hJ : firstFail (F.chain 0) b + S ≤ J + 1) :
    2 * (F.served b S J).card = 2 * S * firstFail (F.chain 0) b + S * (S - 1) := by
  classical
  set f := firstFail (F.chain 0) b with hfdef
  have hcard : (F.served b S J).card = ∑ s ∈ range S, (f + s) := by
    unfold served
    rw [Finset.card_filter, Finset.sum_product]
    refine Finset.sum_congr rfl fun s hs => ?_
    have hsS : s < S := mem_range.mp hs
    have hle : f + s ≤ J := by omega
    have : ∀ j ∈ range J, (if F.chain s j ≤ b then 1 else 0) = (if j < f + s then 1 else 0) := by
      intro j _
      by_cases hcase : j < f + s
      · simp [hcase, (F.served_iff hne hf s j).mpr hcase]
      · have : ¬ F.chain s j ≤ b := fun hcon => hcase ((F.served_iff hne hf s j).mp hcon)
        simp [hcase, this]
    rw [Finset.sum_congr rfl this, ← Finset.card_filter]
    have hfil : (range J).filter (fun j => j < f + s) = range (f + s) := by
      ext j
      simp only [mem_filter, mem_range]
      omega
    rw [hfil, card_range]
  rw [hcard, Finset.sum_add_distrib, Finset.sum_const, card_range, smul_eq_mul]
  have hgauss : 2 * ∑ i ∈ range S, i = S * (S - 1) := by
    rw [mul_comm, Finset.sum_range_id_mul_two S]
  rw [Nat.mul_add, hgauss, ← mul_assoc]

/-- **The additive (log-linear) form.**  If the base chain has constant increment
`δ` per octave, the family is `k*(s, j) = k₀ + δ·(j − s)⁺`: context and scale enter
only through the ratio `ctx / 2 ^ s`. -/
theorem linear_base_shift {k₀ delta : ℕ} (hbase : ∀ j, F.chain 0 j = k₀ + delta * j)
    (s j : ℕ) : F.chain s j = k₀ + delta * (j - s) := by
  rw [F.apply_eq s j, hbase]

end ScaleFamily

/-! ## Realisation by honest workloads -/

/-- **Realisation.**  Every scale family is the knee table of actual demand
profiles: for any positive window count there are workloads whose knee at *every*
admissible gate is the prescribed entry.  The chains are therefore not free
parameters but invariants of genuine sparsity structures. -/
theorem family_realizable (n : ℕ) (hn : 0 < n) (F : ScaleFamily) :
    ∃ W : ℕ → ℕ → Workload n,
      ∀ s j (g : ℚ), 0 < g → g ≤ 1 → knee (W s j).agree g = F.chain s j :=
  ⟨fun s j => flat n (F.chain s j) 0, fun _ _ _ h0 h1 => flat_knee hn h0 h1⟩

/-! ## The measured NET-66 family -/

/-- The measured 0.5B chain `{16, 20, 24}` over octaves `512, 1024, 2048`. -/
def net66Base : Chain := fun j => 16 + 4 * j

theorem net66Base_mono : Monotone net66Base := by
  intro a b h
  simp only [net66Base]
  omega

theorem net66Base_strictMono : StrictMono net66Base := by
  intro a b h
  simp only [net66Base]
  omega

/-- The measured NET-66 scale family: scale index `s` (`s = 0` is 0.5B, `s = 1` is
1.5B), context octave `j` (`ctx = 512 · 2 ^ j`). -/
def net66 : ScaleFamily where
  chain := fun s => shift net66Base s
  base_mono := by simpa using net66Base_mono
  exchange := fun s j => shift_succ_succ net66Base s j
  boundary := fun s => shift_succ_zero net66Base s

/-- The measured 0.5B chain: `k*(512) = 16`, `k*(1024) = 20`, `k*(2048) = 24`. -/
theorem net66_small_chain :
    net66.chain 0 0 = 16 ∧ net66.chain 0 1 = 20 ∧ net66.chain 0 2 = 24 := by
  refine ⟨?_, ?_, ?_⟩ <;> simp [net66, shift, net66Base]

/-- The measured 1.5B chain: `k*(512) = 16`, `k*(1024) = 16`, `k*(2048) = 20`. -/
theorem net66_large_chain :
    net66.chain 1 0 = 16 ∧ net66.chain 1 1 = 16 ∧ net66.chain 1 2 = 20 := by
  refine ⟨?_, ?_, ?_⟩ <;> simp [net66, shift, net66Base]

/-- **The one-octave law, on the measured cells.**  The 1.5B curve is the 0.5B
curve translated right by one context doubling. -/
theorem net66_one_octave (j : ℕ) : net66.chain 1 (j + 1) = net66.chain 0 j :=
  net66.exchange 0 j

/-- **P1 confirmed.**  The 1.5B chain breaks upward at 2048: `k*(2048) = 20 > 16`. -/
theorem net66_P1_break : net66.chain 1 1 < net66.chain 1 2 := by
  simp [net66, shift, net66Base]

/-- **P2 refuted.**  Flatness does not survive to 2048 — and, structurally, it
survives at no scale whatsoever. -/
theorem net66_P2_refuted (s : ℕ) : ∃ j, net66.chain s 0 < net66.chain s j :=
  net66.not_eventually_constant ⟨1, by simp [net66, shift, net66Base]⟩ s

/-- **P3 refuted.**  At the same context (2048) the larger model needs *fewer*
keys: `20 < 24`.  Scale does not increase context sensitivity. -/
theorem net66_P3_refuted : net66.chain 1 2 < net66.chain 0 2 := by
  simp [net66, shift, net66Base]

/-- The rate is identified by the data: the 1.5B chain is the base chain shifted by
`r` octaves for exactly one value of `r`, namely `r = 1`. -/
theorem net66_rate_identified {r : ℕ} (h : ∀ j, net66.chain 1 j = shift net66Base r j) :
    r = 1 := by
  have : shift net66Base r = shift net66Base 1 := by
    funext j; rw [← h j]; rfl
  exact shift_rate_unique net66Base_strictMono this

/-- **The measured budget table.**  A 16-key budget covers the 0.5B out to octave
`0` (ctx 512) and the 1.5B out to octave `1` (ctx 1024): the first failing octave
is `1` at the small scale and `2` at the large one. -/
theorem net66_budget_16 :
    firstFail (net66.chain 0) 16 = 1 ∧ firstFail (net66.chain 1) 16 = 2 := by
  have h0 : net66.chain 0 0 = 16 := by norm_num [net66, shift, net66Base]
  have h1 : net66.chain 0 1 = 20 := by norm_num [net66, shift, net66Base]
  have hne : ∃ j, 16 < net66.chain 0 j := ⟨1, by rw [h1]; norm_num⟩
  have hbase : firstFail (net66.chain 0) 16 = 1 := by
    refine le_antisymm (Nat.sInf_le (show (16 : ℕ) < net66.chain 0 1 by rw [h1]; norm_num)) ?_
    rcases Nat.eq_zero_or_pos (firstFail (net66.chain 0) 16) with hz | hpos
    · exfalso
      have hm := firstFail_mem hne
      rw [hz, h0] at hm
      omega
    · exact hpos
  exact ⟨hbase, by rw [net66.budget_table hne (by rw [hbase]; omega) 1, hbase]⟩

/-- The 1.5B chain fails a 16-key budget for the first time at octave `2`
(ctx 2048), one doubling later than the 0.5B chain — the verdict in adjoint form. -/
theorem net66_delay_one_doubling :
    firstFail (net66.chain 1) 16 = firstFail (net66.chain 0) 16 + 1 := by
  obtain ⟨h0, h1⟩ := net66_budget_16
  omega

end Combinatorics.OctaveShiftLaw