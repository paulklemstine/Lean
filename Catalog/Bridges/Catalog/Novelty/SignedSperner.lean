import Mathlib

/-!
# The 1-D Sperner lemma as an exact signed count (a discrete degree)

The earlier work established the *parity* form of the one–dimensional Sperner lemma:
the number of "fully coloured" edges of a two–colouring of the path `0, 1, …, n` has
a fixed parity determined by the endpoints.  This file **deepens** that result from a
statement modulo `2` to an *exact integer identity*, by separating fully coloured
edges into **oriented** ones:

* an *up*-edge is a `false → true` transition (`upCount`), and
* a *down*-edge is a `true → false` transition (`downCount`).

The main theorem is a telescoping identity — the discrete analogue of "the degree of
a boundary map":

> **Signed Sperner count.**  `upCount c n - downCount c n = ⟦c n⟧ - ⟦c 0⟧`,
> where `⟦·⟧` sends `false ↦ 0`, `true ↦ 1`.

Every classical consequence drops out as a *corollary* of this single identity:

* the parity form (`parity`), recovering the earlier result;
* balanced crossings when the endpoints agree (`upCount_eq_downCount_of_eq`);
* Sperner existence, oriented (`exists_oriented`) and unoriented
  (`exists_fullyColoured_of_ne`);
* two discrete intermediate–value theorems (`discrete_ivt`, `discrete_ivt'`); and
* a discrete Brouwer fixed–point statement (`discrete_brouwer`) — the combinatorial
  bridge from Sperner to Brouwer, and hence to the existence of equilibria.

## Main results

* `SignedSperner.signed_count` — the exact signed identity (the flagship).
* `SignedSperner.card_eq` — `fullyColoured` splits into up- and down-edges.
* `SignedSperner.parity` — the parity form, as a corollary.
* `SignedSperner.upCount_eq_downCount_of_eq` — equal endpoints ⇒ equal crossings.
* `SignedSperner.exists_oriented`, `SignedSperner.exists_fullyColoured_of_ne` —
  Sperner existence.
* `SignedSperner.discrete_ivt`, `SignedSperner.discrete_ivt'` — discrete IVTs.
* `SignedSperner.discrete_brouwer` — a discrete Brouwer fixed point.
-/

namespace SignedSperner

open Finset

/-- The Boolean colour value: `false ↦ 0`, `true ↦ 1`. -/
def boolVal (b : Bool) : ℤ := if b then 1 else 0

/-- The number of *up*-edges (`false → true` transitions) among `0, …, n-1`. -/
def upCount (c : ℕ → Bool) (n : ℕ) : ℕ :=
  ((range n).filter (fun i => c i = false ∧ c (i + 1) = true)).card

/-- The number of *down*-edges (`true → false` transitions) among `0, …, n-1`. -/
def downCount (c : ℕ → Bool) (n : ℕ) : ℕ :=
  ((range n).filter (fun i => c i = true ∧ c (i + 1) = false)).card

/-- The set of *fully coloured* edges (endpoints of different colour). -/
def fullyColoured (c : ℕ → Bool) (n : ℕ) : Finset ℕ :=
  (range n).filter (fun i => c i ≠ c (i + 1))

/-- **Signed Sperner count (flagship).**  Along the path `0, 1, …, n`, the number of
`false → true` edges minus the number of `true → false` edges equals the difference
of the endpoint colour values.  This telescoping identity is the exact 1-D Sperner
lemma; the parity form is a corollary. -/
theorem signed_count (c : ℕ → Bool) (n : ℕ) :
    (upCount c n : ℤ) - downCount c n = boolVal (c n) - boolVal (c 0) := by
  unfold upCount downCount
  rw [Finset.card_filter, Finset.card_filter]
  push_cast
  rw [← Finset.sum_sub_distrib]
  have key : ∀ i, ((if c i = false ∧ c (i + 1) = true then (1 : ℤ) else 0)
      - (if c i = true ∧ c (i + 1) = false then 1 else 0))
      = boolVal (c (i + 1)) - boolVal (c i) := by
    intro i; unfold boolVal
    cases hi : c i <;> cases hi1 : c (i + 1) <;> simp
  simp_rw [key]
  exact Finset.sum_range_sub (fun i => boolVal (c i)) n

/-- The fully coloured edges split into the up-edges and the down-edges. -/
theorem card_eq (c : ℕ → Bool) (n : ℕ) :
    (fullyColoured c n).card = upCount c n + downCount c n := by
  unfold fullyColoured upCount downCount
  rw [← Finset.card_union_of_disjoint]
  · congr 1
    rw [← Finset.filter_or]
    apply Finset.filter_congr
    intro x _
    cases c x <;> cases c (x + 1) <;> simp
  · rw [Finset.disjoint_filter]; intro x _ h; simp_all

/-- **Parity form of the 1-D Sperner lemma** (a corollary of the signed count).  The
number of fully coloured edges is odd exactly when the endpoints differ. -/
theorem parity (c : ℕ → Bool) (n : ℕ) :
    (fullyColoured c n).card % 2 = (if c 0 = c n then 0 else 1) := by
  have h1 := signed_count c n
  have h2 := card_eq c n
  unfold boolVal at h1
  rcases hc0 : c 0 <;> rcases hcn : c n <;> rw [hc0, hcn] at h1 <;> simp_all <;> omega

/-- If the endpoints receive the *same* colour, then there are exactly as many
up-edges as down-edges (balanced crossings). -/
theorem upCount_eq_downCount_of_eq (c : ℕ → Bool) (n : ℕ) (h : c 0 = c n) :
    upCount c n = downCount c n := by
  have hs := signed_count c n
  rw [h] at hs
  simp only [sub_self] at hs
  omega

/-- **Oriented Sperner existence.**  A Sperner colouring (`c 0 = false`,
`c n = true`) has an oriented fully coloured edge: some `i < n` with `c i = false`
and `c (i+1) = true`. -/
theorem exists_oriented (c : ℕ → Bool) (n : ℕ) (h0 : c 0 = false) (hn : c n = true) :
    ∃ i < n, c i = false ∧ c (i + 1) = true := by
  have h1 := signed_count c n
  rw [h0, hn] at h1
  have hup : 0 < upCount c n := by
    have := h1
    simp only [boolVal] at this
    norm_num at this
    omega
  unfold upCount at hup
  obtain ⟨i, hi⟩ := Finset.card_pos.mp hup
  rw [Finset.mem_filter, Finset.mem_range] at hi
  exact ⟨i, hi.1, hi.2⟩

/-- **Unoriented Sperner existence.**  If the endpoints differ, some edge is fully
coloured. -/
theorem exists_fullyColoured_of_ne (c : ℕ → Bool) (n : ℕ) (h : c 0 ≠ c n) :
    ∃ i < n, c i ≠ c (i + 1) := by
  have hs := signed_count c n
  have hc := card_eq c n
  have hpos : 0 < (fullyColoured c n).card := by
    rcases hb0 : c 0 <;> rcases hbn : c n <;> simp_all [boolVal] <;> omega
  obtain ⟨i, hi⟩ := Finset.card_pos.mp hpos
  simp only [fullyColoured, Finset.mem_filter, Finset.mem_range] at hi
  exact ⟨i, hi.1, hi.2⟩

/-- **Discrete intermediate value theorem (upward crossing).**  If `f 0 ≤ 0 < f n`
then `f` has a sign change: some `i < n` with `f i ≤ 0` and `0 < f (i+1)`. -/
theorem discrete_ivt (f : ℕ → ℤ) (n : ℕ) (h0 : f 0 ≤ 0) (hn : 0 < f n) :
    ∃ i < n, f i ≤ 0 ∧ 0 < f (i + 1) := by
  obtain ⟨i, hlt, hi, hi1⟩ :=
    exists_oriented (fun k => decide (0 < f k)) n
      (by simp only [decide_eq_false_iff_not, not_lt]; exact h0)
      (by simp only [decide_eq_true_eq]; exact hn)
  refine ⟨i, hlt, ?_, ?_⟩
  · simpa only [decide_eq_false_iff_not, not_lt] using hi
  · simpa only [decide_eq_true_eq] using hi1

/-- **Discrete intermediate value theorem (downward crossing).**  If `f n ≤ 0 < f 0`
then some `i < n` has `0 < f i` and `f (i+1) ≤ 0`. -/
theorem discrete_ivt' (f : ℕ → ℤ) (n : ℕ) (h0 : 0 < f 0) (hn : f n ≤ 0) :
    ∃ i < n, 0 < f i ∧ f (i + 1) ≤ 0 := by
  obtain ⟨i, hlt, hi, hi1⟩ :=
    exists_oriented (fun k => decide (f k ≤ 0)) n
      (by simp only [decide_eq_false_iff_not, not_le]; exact h0)
      (by simp only [decide_eq_true_eq]; exact hn)
  refine ⟨i, hlt, ?_, ?_⟩
  · simpa only [decide_eq_false_iff_not, not_le] using hi
  · simpa only [decide_eq_true_eq] using hi1

/-- **Discrete Brouwer fixed point.**  A self-map `g` of `{0, …, n}` that pushes the
left endpoint strictly up (`0 < g 0`) and keeps the right endpoint in range
(`g n ≤ n`) has an approximate fixed point: some `i < n` with `i < g i` and
`g (i+1) ≤ i+1` — the map crosses the diagonal.  This is the combinatorial fixed
point behind Brouwer's theorem, and hence behind Nash's existence theorem. -/
theorem discrete_brouwer (g : ℕ → ℕ) (n : ℕ) (h0 : 0 < g 0) (hg : g n ≤ n) :
    ∃ i < n, i < g i ∧ g (i + 1) ≤ i + 1 := by
  obtain ⟨i, hlt, hi, hi1⟩ :=
    discrete_ivt' (fun k => (g k : ℤ) - k) n (by simp; exact_mod_cast h0)
      (by simp; exact_mod_cast hg)
  refine ⟨i, hlt, ?_, ?_⟩
  · have : (i : ℤ) < g i := by linarith
    exact_mod_cast this
  · have : (g (i + 1) : ℤ) ≤ i + 1 := by push_cast at hi1 ⊢; linarith
    exact_mod_cast this

end SignedSperner