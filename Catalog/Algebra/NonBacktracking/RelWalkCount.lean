import Mathlib

/-!
# Counting walks in a digraph by powers of its 0-1 matrix

This file develops, from scratch, the combinatorial interpretation of the entries and
the trace of powers of the incidence (0-1) matrix of an *arbitrary* decidable relation
`r : ι → ι → Prop` on a finite type `ι`.

Mathlib provides such a statement only for the adjacency matrix of a `SimpleGraph`
(`SimpleGraph.adjMatrix_pow_apply_eq_card_walk`).  The relation we ultimately care
about — "arc `f` follows arc `e` without backtracking" — is **not symmetric**, so the
`SimpleGraph` machinery does not apply and the theory has to be redone for a general
directed relation.

## Main definitions

* `RelWalkCount.relMatrix r` — the 0-1 matrix of `r` over `ℕ`.
* `RelWalkCount.walks r n a b` — the finset of walks of length `n` (i.e. lists of
  `n + 1` vertices) from `a` to `b` all of whose consecutive pairs are `r`-related.
* `RelWalkCount.closedWalks r n` — the finset of *rooted closed* walks of length `n`:
  walks of length `n` whose first and last entry agree.

## Main results

* `RelWalkCount.mem_walks` — the recursive definition of `walks` really describes the
  set of `r`-chains of the prescribed length and endpoints.
* `RelWalkCount.relMatrix_pow_apply` — `(M ^ n) a b` is the number of walks from `a`
  to `b` of length `n`.
* `RelWalkCount.trace_relMatrix_pow` — `trace (M ^ n)` is the number of rooted closed
  walks of length `n`.
* `RelWalkCount.rowSum_pow` — if every row of `M` sums to `q`, then every row of
  `M ^ n` sums to `q ^ n`; consequently `trace (M ^ n) ≤ card ι * q ^ n`.
-/

open Finset Matrix

namespace RelWalkCount

/-- `getLast?` ignores a prepended element as long as the tail is nonempty. -/
lemma getLast?_cons_of_ne_nil {α : Type*} (a : α) {l : List α} (h : l ≠ []) :
    (a :: l).getLast? = l.getLast? := by
  cases l with
  | nil => exact absurd rfl h
  | cons y t => simp [List.getLast?_cons_cons]

variable {ι : Type*} [Fintype ι] [DecidableEq ι] (r : ι → ι → Prop) [DecidableRel r]

/-- The 0-1 matrix (over `ℕ`) of a decidable relation. -/
def relMatrix : Matrix ι ι ℕ := Matrix.of fun i j => if r i j then 1 else 0

omit [Fintype ι] [DecidableEq ι] in
@[simp] lemma relMatrix_apply (i j : ι) :
    relMatrix r i j = if r i j then 1 else 0 := rfl

/-- `walks r n a b` is the finset of walks of length `n` from `a` to `b`, encoded as
lists of `n + 1` elements, in the digraph with arc relation `r`. -/
def walks : ℕ → ι → ι → Finset (List ι)
  | 0, a, b => if a = b then {[a]} else ∅
  | n + 1, a, b =>
      (univ.filter fun c => r a c).biUnion fun c => (walks n c b).image (fun l => a :: l)

lemma walks_zero (a b : ι) : walks r 0 a b = if a = b then {[a]} else ∅ := rfl

lemma walks_succ (n : ℕ) (a b : ι) :
    walks r (n + 1) a b =
      (univ.filter fun c => r a c).biUnion fun c => (walks r n c b).image (fun l => a :: l) :=
  rfl

/-- Every walk in `walks r n a b` starts at `a` (recorded separately: it is used to prove
disjointness of the pieces of the `biUnion`). -/
lemma head?_of_mem_walks : ∀ (n : ℕ) (a b : ι) (l : List ι), l ∈ walks r n a b →
    l.head? = some a := by
  intro n
  induction n with
  | zero =>
      intro a b l hl
      rw [walks_zero] at hl
      split at hl
      · simp at hl; subst hl; rfl
      · simp at hl
  | succ n ih =>
      intro a b l hl
      rw [walks_succ] at hl
      simp only [Finset.mem_biUnion, Finset.mem_image, Finset.mem_filter] at hl
      obtain ⟨c, _, l', _, rfl⟩ := hl
      rfl

/-- Characterisation of membership in `walks`: a list is a walk of length `n` from `a`
to `b` iff it has `n + 1` entries, starts at `a`, ends at `b`, and consecutive entries
are `r`-related. -/
theorem mem_walks : ∀ (n : ℕ) (a b : ι) (l : List ι),
    l ∈ walks r n a b ↔
      l.length = n + 1 ∧ l.head? = some a ∧ l.getLast? = some b ∧ List.IsChain r l := by
  intro n
  induction n with
  | zero =>
      intro a b l
      constructor
      · intro hl
        rw [walks_zero] at hl
        split at hl
        · rename_i hab
          simp only [Finset.mem_singleton] at hl
          subst hl; subst hab
          simp
        · simp at hl
      · rintro ⟨hlen, hhead, hlast, -⟩
        match l, hlen with
        | [x], _ =>
            have hhead' : x = a := by simpa using hhead
            have hlast' : x = b := by simpa using hlast
            subst hhead'
            rw [walks_zero]
            simp [hlast']
  | succ n ih =>
      intro a b l
      rw [walks_succ]
      simp only [Finset.mem_biUnion, Finset.mem_image, Finset.mem_filter, Finset.mem_univ,
        true_and]
      constructor
      · rintro ⟨c, hrc, l', hl', rfl⟩
        have hl'len : l'.length = n + 1 := ((ih c b l').1 hl').1
        have hl'head : l'.head? = some c := ((ih c b l').1 hl').2.1
        have hl'last : l'.getLast? = some b := ((ih c b l').1 hl').2.2.1
        have hl'chain : List.IsChain r l' := ((ih c b l').1 hl').2.2.2
        have hne : l' ≠ [] := by
          intro h; rw [h] at hl'len; simp at hl'len
        refine ⟨by simp [hl'len], rfl, ?_, ?_⟩
        · rw [getLast?_cons_of_ne_nil _ hne]; exact hl'last
        · rw [List.isChain_cons]
          refine ⟨?_, hl'chain⟩
          intro y hy
          rw [hl'head] at hy
          simp only [Option.mem_def, Option.some.injEq] at hy
          subst hy; exact hrc
      · rintro ⟨hlen, hhead, hlast, hchain⟩
        match l with
        | [] => simp at hlen
        | x :: l' =>
            have hhead' : x = a := by simpa using hhead
            subst hhead'
            have hl'len : l'.length = n + 1 := by simpa using hlen
            have hne : l' ≠ [] := by
              intro h; rw [h] at hl'len; simp at hl'len
            obtain ⟨c, hc⟩ : ∃ c, l'.head? = some c := by
              cases l' with
              | nil => exact absurd rfl hne
              | cons y t => exact ⟨y, rfl⟩
            rw [List.isChain_cons] at hchain
            refine ⟨c, ?_, l', ?_, rfl⟩
            · exact hchain.1 c hc
            · refine (ih c b l').2 ⟨hl'len, hc, ?_, hchain.2⟩
              rw [getLast?_cons_of_ne_nil _ hne] at hlast
              exact hlast

/-- The pieces of the `biUnion` defining `walks r (n+1) a b` are pairwise disjoint. -/
lemma walks_succ_disjoint (n : ℕ) (a b : ι) :
    Set.PairwiseDisjoint (↑(univ.filter fun c => r a c) : Set ι)
      (fun c => (walks r n c b).image (fun l => a :: l)) := by
  intro c _ c' _ hcc'
  simp only [Function.onFun, Finset.disjoint_left, Finset.mem_image]
  rintro l ⟨l₁, hl₁, rfl⟩ ⟨l₂, hl₂, h⟩
  have h1 := head?_of_mem_walks r n c b l₁ hl₁
  have h2 := head?_of_mem_walks r n c' b l₂ hl₂
  have hll : l₁ = l₂ := by simpa using h.symm
  subst hll
  rw [h1] at h2
  exact hcc' (by simpa using h2)

/-- **Walk counting.** The `(a, b)` entry of the `n`-th power of the 0-1 matrix of `r`
is the number of walks of length `n` from `a` to `b`. -/
theorem relMatrix_pow_apply : ∀ (n : ℕ) (a b : ι),
    (relMatrix r ^ n) a b = (walks r n a b).card := by
  intro n
  induction n with
  | zero =>
      intro a b
      simp only [pow_zero, Matrix.one_apply, walks_zero]
      split <;> simp
  | succ n ih =>
      intro a b
      rw [pow_succ', Matrix.mul_apply]
      rw [walks_succ, Finset.card_biUnion]
      · have h : ∀ c ∈ univ.filter fun c => r a c,
            ((walks r n c b).image (fun l => a :: l)).card = (walks r n c b).card := by
          intro c _
          exact Finset.card_image_of_injective _ (fun l₁ l₂ h => by simpa using h)
        rw [Finset.sum_congr rfl h, Finset.sum_filter]
        refine Finset.sum_congr rfl ?_
        intro c _
        by_cases hc : r a c <;> simp [hc, ih c b]
      · intro c hc c' hc' hcc'
        exact walks_succ_disjoint r n a b (by simpa using hc) (by simpa using hc') hcc'

/-- The finset of **rooted closed walks** of length `n`: walks of length `n` whose
initial and final vertex coincide. The root is the (marked) initial vertex. -/
def closedWalks (n : ℕ) : Finset (List ι) := univ.biUnion fun a => walks r n a a

/-- Characterisation of rooted closed walks: lists of `n + 1` entries, consecutive
entries `r`-related, first entry equal to last entry. -/
theorem mem_closedWalks (n : ℕ) (l : List ι) :
    l ∈ closedWalks r n ↔
      l.length = n + 1 ∧ List.IsChain r l ∧ l.head? = l.getLast? := by
  simp only [closedWalks, Finset.mem_biUnion, Finset.mem_univ, true_and]
  constructor
  · rintro ⟨a, ha⟩
    obtain ⟨hlen, hhead, hlast, hchain⟩ := (mem_walks r n a a l).1 ha
    exact ⟨hlen, hchain, by rw [hhead, hlast]⟩
  · rintro ⟨hlen, hchain, hhl⟩
    have hne : l ≠ [] := by
      intro h; rw [h] at hlen; simp at hlen
    obtain ⟨a, ha⟩ : ∃ a, l.head? = some a := by
      cases l with
      | nil => exact absurd rfl hne
      | cons x t => exact ⟨x, rfl⟩
    exact ⟨a, (mem_walks r n a a l).2 ⟨hlen, ha, by rw [← hhl]; exact ha, hchain⟩⟩

/-- **Trace counts rooted closed walks.** -/
theorem trace_relMatrix_pow (n : ℕ) :
    (relMatrix r ^ n).trace = (closedWalks r n).card := by
  rw [Matrix.trace]
  simp only [Matrix.diag]
  rw [closedWalks, Finset.card_biUnion]
  · exact Finset.sum_congr rfl fun a _ => relMatrix_pow_apply r n a a
  · intro a _ a' _ haa'
    simp only [Finset.disjoint_left]
    intro l hl hl'
    have h1 := head?_of_mem_walks r n a a l hl
    have h2 := head?_of_mem_walks r n a' a' l hl'
    rw [h1] at h2
    exact haa' (by simpa using h2)

/-! ### Row sums -/

/-- If every row of `relMatrix r` sums to `q`, then every row of its `n`-th power sums
to `q ^ n`. -/
theorem rowSum_pow {q : ℕ} (hq : ∀ a : ι, ∑ b, relMatrix r a b = q) :
    ∀ (n : ℕ) (a : ι), ∑ b, (relMatrix r ^ n) a b = q ^ n := by
  intro n
  induction n with
  | zero => intro a; simp [Matrix.one_apply, Finset.sum_ite_eq]
  | succ n ih =>
      intro a
      have hpow : ∀ b, (relMatrix r ^ (n + 1)) a b
          = ∑ c, relMatrix r a c * (relMatrix r ^ n) c b := by
        intro b; rw [pow_succ', Matrix.mul_apply]
      simp only [hpow]
      rw [Finset.sum_comm]
      have hsum : ∀ c ∈ (univ : Finset ι),
          ∑ b, relMatrix r a c * (relMatrix r ^ n) c b = relMatrix r a c * q ^ n := by
        intro c _
        rw [← Finset.mul_sum, ih c]
      rw [Finset.sum_congr rfl hsum, ← Finset.sum_mul, hq a, pow_succ]
      ring

/-- Under a constant row sum `q`, the number of rooted closed walks of length `n` is at
most `card ι * q ^ n`. -/
theorem card_closedWalks_le {q : ℕ} (hq : ∀ a : ι, ∑ b, relMatrix r a b = q) (n : ℕ) :
    (closedWalks r n).card ≤ Fintype.card ι * q ^ n := by
  rw [← trace_relMatrix_pow r n, Matrix.trace]
  simp only [Matrix.diag]
  calc ∑ a, (relMatrix r ^ n) a a
      ≤ ∑ a : ι, ∑ b, (relMatrix r ^ n) a b := by
        refine Finset.sum_le_sum fun a _ => ?_
        exact Finset.single_le_sum (f := fun b => (relMatrix r ^ n) a b)
          (fun b _ => Nat.zero_le _) (Finset.mem_univ a)
    _ = ∑ _a : ι, q ^ n := Finset.sum_congr rfl fun a _ => rowSum_pow r hq n a
    _ = Fintype.card ι * q ^ n := by
        rw [Finset.sum_const, Finset.card_univ, smul_eq_mul]

end RelWalkCount