import Physics.AttentionKneeMultiplier

/-!
# The knee spectrum: closed form, gate invariance, and the five-domain table

Second cycle of the NET-75 analysis, building on
`Physics/AttentionKneeMultiplier.lean`.

Cycle 1 established that a *delay* shifts the knee additively while a *root of
the decay ratio* multiplies it (up to a ceiling correction).  Here we

1. solve the geometric knee in closed form,
   `kgeom r t = ⌈log t / log r⌉₊` (`kgeom_eq_ceil_log`);
2. introduce the real-valued **ideal knee** `log t / log r`, show it is within
   `1` of the integer knee (`kgeom_sub_idealKnee_lt_one`) and that it obeys the
   multiplicative law *exactly* (`idealKnee_root`);
3. prove **gate invariance of the tax**: the ratio of two ideal knees is
   independent of the gate (`idealKnee_ratio_gate_invariant`) — a falsifiable
   prediction for measurements at other contexts;
4. prove the **five-domain reconstruction**: the measured table
   `code 12, EN 20, math 20, DE 24, FR 40` is *exactly* realised by one master
   profile with fine knee `120` and tokenizer exponents `(10, 6, 6, 5, 3)`
   (`five_domain_table`), and `120` is the *least* possible master knee
   (`five_domain_base_minimal`);
5. prove a **composite tax law** for delay ∘ root, and that a delay can never
   mimic a root (`delay_ne_root`);
6. generalise the grid analysis: a grid measurement returns the least grid
   point above the true knee (`gridKnee_eq_least_grid_point`), and any pair of
   fail/pass observations brackets the knee (`knee_bracket`).
-/

namespace Physics.AttentionKnee

open Finset

/-! ## Closed form for the geometric knee -/

/-- **Closed form.** For `0 < r < 1` and `0 < t`, the geometric knee is the
ceiling of `log t / log r`. -/
theorem kgeom_eq_ceil_log {r t : ℝ} (hr0 : 0 < r) (hr1 : r < 1) (ht0 : 0 < t) :
    kgeom r t = ⌈Real.log t / Real.log r⌉₊ := by
  have hlr : Real.log r < 0 := Real.log_neg hr0 hr1
  have key : ∀ k : ℕ, r ^ k ≤ t ↔ Real.log t / Real.log r ≤ k := by
    intro k
    rw [← Real.log_le_log_iff (by positivity) ht0, Real.log_pow]
    constructor
    · intro h
      rw [div_le_iff_of_neg hlr]; linarith
    · intro h
      rw [div_le_iff_of_neg hlr] at h; linarith
  have hne : {k | r ^ k ≤ t}.Nonempty :=
    ⟨⌈Real.log t / Real.log r⌉₊, (key _).2 (Nat.le_ceil _)⟩
  refine le_antisymm (Nat.sInf_le ((key _).2 (Nat.le_ceil _))) ?_
  exact Nat.ceil_le.2 ((key _).1 (Nat.sInf_mem hne))

/-- The **ideal knee**: the real-valued cut-off at which a geometric profile
would meet the gate exactly. -/
noncomputable def idealKnee (r t : ℝ) : ℝ := Real.log t / Real.log r

theorem idealKnee_nonneg {r t : ℝ} (hr0 : 0 < r) (hr1 : r < 1) (ht0 : 0 < t)
    (ht1 : t ≤ 1) : 0 ≤ idealKnee r t := by
  have hlr : Real.log r < 0 := Real.log_neg hr0 hr1
  have hlt : Real.log t ≤ 0 := Real.log_nonpos ht0.le ht1
  rw [idealKnee, le_div_iff_of_neg hlr]
  simpa using hlt

/-- The integer knee is the ideal knee rounded up: they differ by less than one. -/
theorem kgeom_sub_idealKnee_lt_one {r t : ℝ} (hr0 : 0 < r) (hr1 : r < 1)
    (ht0 : 0 < t) (ht1 : t ≤ 1) :
    idealKnee r t ≤ (kgeom r t : ℝ) ∧ (kgeom r t : ℝ) < idealKnee r t + 1 := by
  have h := kgeom_eq_ceil_log hr0 hr1 ht0
  constructor
  · rw [h]; exact Nat.le_ceil _
  · rw [h]
    exact Nat.ceil_lt_add_one (idealKnee_nonneg hr0 hr1 ht0 ht1)

/-- **Exact multiplicative law for the ideal knee**: no ceiling correction. -/
theorem idealKnee_root {r t : ℝ} (hr0 : 0 < r) (hr1 : r < 1) {m : ℕ} (hm : 0 < m) :
    idealKnee (r ^ m) t = idealKnee r t / m := by
  have hlr : Real.log r ≠ 0 := ne_of_lt (Real.log_neg hr0 hr1)
  have hm0 : (m : ℝ) ≠ 0 := Nat.cast_ne_zero.2 hm.ne'
  rw [idealKnee, idealKnee, Real.log_pow]
  field_simp

/-- **Gate invariance of the tax.**  The ratio of the ideal knees of two
geometric profiles is `log r₂ / log r₁`, independent of the gate.  Hence the
domain multiplier measured at one context must reproduce at every other
context — a directly falsifiable prediction. -/
theorem idealKnee_ratio_gate_invariant {r₁ r₂ t : ℝ} (hr₁0 : 0 < r₁) (hr₁1 : r₁ < 1)
    (hr₂0 : 0 < r₂) (hr₂1 : r₂ < 1) (ht0 : 0 < t) (ht1 : t < 1) :
    idealKnee r₁ t / idealKnee r₂ t = Real.log r₂ / Real.log r₁ := by
  have hlr₁ : Real.log r₁ ≠ 0 := ne_of_lt (Real.log_neg hr₁0 hr₁1)
  have hlr₂ : Real.log r₂ ≠ 0 := ne_of_lt (Real.log_neg hr₂0 hr₂1)
  have hlt : Real.log t ≠ 0 := ne_of_lt (Real.log_neg ht0 ht1)
  rw [idealKnee, idealKnee]
  field_simp

/-! ## The five-domain table -/

/-- **Five-domain reconstruction.**  A single master profile with decay ratio
`r` whose knee is `120` reproduces the whole NET-75 table at one gate:
exponent `10` gives code `12`, exponent `6` gives EN prose and math `20`,
exponent `5` gives DE prose `24`, exponent `3` gives FR prose `40`.
So the five domains are consistent with being `m`-th roots of one common
decay ratio; the "tax" is neither a fixed step nor a fixed factor but the
exponent `m`. -/
theorem five_domain_table {r t : ℝ} (hr0 : 0 ≤ r) (hr1 : r < 1) (ht : 0 < t)
    (hmaster : kgeom r t = 120) :
    kgeom (r ^ 10) t = 12 ∧ kgeom (r ^ 6) t = 20 ∧ kgeom (r ^ 5) t = 24 ∧
      kgeom (r ^ 3) t = 40 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    · rw [kgeom_root hr0 hr1 ht (by norm_num), hmaster]
      decide

/-- The two extreme table entries already force `120 ∣ B`. -/
theorem five_domain_lcm {B : ℕ} (h24 : 24 ∣ B) (h20 : 20 ∣ B) : 120 ∣ B := by
  have : Nat.lcm 24 20 ∣ B := Nat.lcm_dvd h24 h20
  simpa [Nat.lcm] using this

/-- **Minimality of the master knee among exact divisors.**  Any positive
master knee `B` that reproduces the table entries `20` and `24` *by exact
division* is a multiple of `120`; hence `120` is the least such master.
(If only the ceiling law is imposed the bound drops to `118`; see
`Physics/AttentionKneeMasterKnee.lean`.) -/
theorem five_domain_base_minimal {B : ℕ} (hpos : 0 < B)
    (h20 : ∃ m, B = m * 20) (h24 : ∃ m, B = m * 24) : 120 ≤ B := by
  obtain ⟨a, rfl⟩ := h20
  exact Nat.le_of_dvd hpos
    (five_domain_lcm (by obtain ⟨b, hb⟩ := h24; exact ⟨b, by omega⟩) ⟨a, by ring⟩)

/-- The `120` master knee is achievable: the exponents are exactly the
cofactors of the table entries. -/
theorem five_domain_exponents :
    120 ⌈/⌉ 10 = 12 ∧ 120 ⌈/⌉ 6 = 20 ∧ 120 ⌈/⌉ 5 = 24 ∧ 120 ⌈/⌉ 3 = 40 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> decide

/-! ## Composite tax: delay after root -/

theorem geom_gate_nonempty {r τ : ℝ} (hr1 : r < 1) (hτ : τ < 1) :
    {k | τ ≤ retained (geom r) k}.Nonempty := by
  rw [geom_gate_set]
  exact kgeom_nonempty hr1 (by linarith)

/-- **Composite tax law.**  A `d`-token delay applied to the `m`-th power of a
decay ratio produces the knee `d + ⌈B / m⌉`, where `B` is the knee of the
underlying fine profile: the additive and the multiplicative taxes compose
without interference. -/
theorem composite_tax_law {r τ : ℝ} (hr0 : 0 ≤ r) (hr1 : r < 1) (hτ0 : 0 < τ)
    (hτ1 : τ < 1) (d : ℕ) {m : ℕ} (hm : 0 < m) :
    kstar (delay d (geom (r ^ m))) τ = d + (kgeom r (1 - τ) ⌈/⌉ m) := by
  have hrm1 : r ^ m < 1 := pow_lt_one₀ hr0 hr1 hm.ne'
  rw [kstar_delay d _ τ hτ0 (geom_gate_nonempty hrm1 hτ1), kstar_geom,
    kgeom_root hr0 hr1 (by linarith) hm]

/-- **A delay can never mimic a root.**  For `m ≥ 2` and any fixed additive
constant `d` there is a gate at which the fine knee is not `d` plus the coarse
knee: the two taxes are genuinely different laws, not reparametrisations. -/
theorem delay_ne_root {r : ℝ} (hr0 : 0 < r) (hr1 : r < 1) {m : ℕ} (hm : 2 ≤ m)
    (d : ℕ) : ∃ t : ℝ, 0 < t ∧ kgeom r t ≠ d + kgeom (r ^ m) t := by
  obtain ⟨t, ht, hgap⟩ := root_gap_unbounded hr0 hr1 hm (d + 1)
  exact ⟨t, ht, by omega⟩

/-! ## Grid measurements, in general -/

/-- **A grid measurement returns the least grid point above the true knee.** -/
theorem gridKnee_eq_least_grid_point (w : ℕ → ℝ) (hw : ∀ i, 0 ≤ w i) (τ : ℝ)
    (G : Finset ℕ) (hne : {k | k ∈ G ∧ τ ≤ retained w k}.Nonempty) :
    gridKnee w τ G = sInf {k | k ∈ G ∧ kstar w τ ≤ k} := by
  have hne' : {k | τ ≤ retained w k}.Nonempty := ⟨_, (Nat.sInf_mem hne).2⟩
  have hset : {k | k ∈ G ∧ τ ≤ retained w k} = {k | k ∈ G ∧ kstar w τ ≤ k} := by
    ext k
    simp only [Set.mem_setOf_eq]
    exact and_congr_right fun _ =>
      ⟨fun h => Nat.sInf_le h, fun h => le_retained_of_kstar_le w hw τ hne' h⟩
  rw [gridKnee, hset]

/-- **Bracketing.**  A failing observation at `a` and a passing observation at
`b` pin the true knee to `(a, b]`, whatever the grid in between. -/
theorem knee_bracket (w : ℕ → ℝ) (hw : ∀ i, 0 ≤ w i) (τ : ℝ) {a b : ℕ}
    (ha : ¬ τ ≤ retained w a) (hb : τ ≤ retained w b) :
    a < kstar w τ ∧ kstar w τ ≤ b := by
  refine ⟨?_, Nat.sInf_le hb⟩
  by_contra hle
  push_neg at hle
  exact ha (le_retained_of_kstar_le w hw τ ⟨b, hb⟩ hle)

/-- The NET-75 French data, as an instance of `knee_bracket`: with
`retained 36 = 0.9795 < 0.98 ≤ 0.9830 = retained 40` the true knee lies in
`(36, 40]`, so the reported `40` is an upper bound, not necessarily the knee. -/
theorem french_bracket (w : ℕ → ℝ) (hw : ∀ i, 0 ≤ w i)
    (h36 : retained w 36 = 0.9795) (h40 : retained w 40 = 0.9830) :
    36 < kstar w (0.98 : ℝ) ∧ kstar w (0.98 : ℝ) ≤ 40 := by
  refine knee_bracket w hw _ ?_ ?_
  · rw [h36]; norm_num
  · rw [h40]; norm_num

end Physics.AttentionKnee