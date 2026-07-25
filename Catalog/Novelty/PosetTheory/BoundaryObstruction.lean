/-
# The literal threshold fails at the boundary: an incoherence-index obstruction

The v19d mission conjecture asserts that for **every** `k ≥ 1` and **every**
`n ≥ 2*k+1` some maximal standard frame on `2*n` voters has incoherence index
exactly `2*k+2`.  The companion file `CofiniteRealization.lean` proves the
*cofinite* part (all sufficiently large electorates).  This file shows the
*literal* threshold `n ≥ 2*k+1` is **false**: at the boundary `n = 2*k+1` the
target index `2*k+2` is unattainable.

The obstruction is structural.  For any frame `F` on `N = 2*n` voters, the
incoherence index is bounded by the additive order of each atom
(`incoherenceIndex_le_addOrderOf`).  Hence if the index exceeds `N/2`, every atom
must be a *generator* of `ZMod N` (`atoms_generate_of_index_gt_half`).  At the
boundary `N = 4*k+2` the target `2*k+2 = N/2 + 1` exceeds `N/2`, so a realizing
frame would consist only of generators; we then rule this out explicitly for
`k = 1` (`boundary_obstruction_k1`), refuting the literal claim with the concrete
counterexample `k = 1, n = 3` on `6` voters.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  Adversarial test of the v19d threshold: maybe
`n ≥ 2*k+1` is too optimistic and the true cofinite onset is later.

EXPERIMENT (Experimenter).  Exhaustive search (`ComputationalEvidence.md`) over
*all* maximal frames shows: for even `N`, the realizable incoherence indices are
either `≤ N/2` or `= N` — the open interval `(N/2, N)` is never hit.  At
`N = 4*k+2` the target `2*k+2 = N/2+1` sits in that forbidden interval.  Concrete
refutations: `(k,n) = (1,3),(2,5),(3,7)` all fail.

ANALYSIS (Analyst).  The cause: `index F ≤ addOrderOf a` for every atom `a`
(replicate `a` to its order), and a divisor of `N` exceeding `N/2` must equal `N`.
So a frame with index `> N/2` is built from generators only.  For `N = 6` the
generators are just `{1, 5}`, and the (at most) three nonempty generator-frames
have indices `6, 6, 2` — never `4`.

CRITIQUE (Critic).  The general lemma `atoms_generate_of_index_gt_half` holds for
all `N` (only the divisor argument is used, proved by `omega`/`Nat.le_of_dvd`).
The boundary refutation is a finite case analysis driven by that lemma, not a raw
`decide` over `Finset (ZMod 6)`.  The full `(N/2, N)`-gap for all even `N` needs
the tight two-generator bound `index{a,b} ≤ N/2`; that is recorded as a future
direction with computational evidence.

SYNTHESIS (PI).  Combined with `CofiniteRealization.cofinite_realization`, the
picture is: realization holds cofinitely but **not** down to `n = 2*k+1`; the
honest threshold is strictly larger.  See `FUTURE_DIRECTIONS.md`.
-- !-- Lab Notes -- !--
-/
import Mathlib

namespace SocialChoice.Boundary

open scoped BigOperators

/-- A *standard social decision frame* on `N` voters (catalog model). -/
abbrev Frame (N : ℕ) := Finset (ZMod N)

/-- A *perfectly balanced sequence* for a frame `F`. -/
def IsBalanced {N : ℕ} (F : Frame N) (l : List (ZMod N)) : Prop :=
  l ≠ [] ∧ (∀ x ∈ l, x ∈ F) ∧ l.sum = 0

/-- The set of lengths of perfectly balanced sequences of `F`. -/
def balancedLengths {N : ℕ} (F : Frame N) : Set ℕ :=
  { k | ∃ l, IsBalanced F l ∧ l.length = k }

/-- The *incoherence index*. -/
noncomputable def incoherenceIndex {N : ℕ} (F : Frame N) : ℕ :=
  sInf (balancedLengths F)

/-- A frame is *maximal* when its atoms generate the whole decision space. -/
def IsMaximal {N : ℕ} (F : Frame N) : Prop :=
  AddSubgroup.closure (F : Set (ZMod N)) = ⊤

/-! ### General obstruction lemmas -/

/-
**Order bound.**  Repeating an atom `a ∈ F` to its additive order gives a
perfectly balanced sequence, so the incoherence index is at most `addOrderOf a`.
-/
lemma incoherenceIndex_le_addOrderOf {N : ℕ} [NeZero N] (F : Frame N)
    {a : ZMod N} (ha : a ∈ F) : incoherenceIndex F ≤ addOrderOf a := by
  refine' Nat.sInf_le ⟨ _, _, _ ⟩;
  exact List.replicate ( addOrderOf a ) a;
  · refine' ⟨ _, _, _ ⟩;
    · exact List.ne_nil_of_length_pos ( by rw [ List.length_replicate ] ; exact addOrderOf_pos a );
    · exact fun x hx => by rw [ List.eq_of_mem_replicate hx ] ; exact ha;
    · simp +decide [ addOrderOf_nsmul_eq_zero ];
  · norm_num

/-
**Generators only.**  If the incoherence index of `F` strictly exceeds `N/2`,
then every atom of `F` is a generator of `ZMod N` (its additive order is `N`).
-/
lemma atoms_generate_of_index_gt_half {N : ℕ} [NeZero N] (F : Frame N)
    (h : N / 2 < incoherenceIndex F) {a : ZMod N} (ha : a ∈ F) :
    addOrderOf a = N := by
  have := incoherenceIndex_le_addOrderOf F ha;
  -- Also `addOrderOf a ∣ N` (additive order divides the cardinality `N = Nat.card (ZMod N)`).
  have h_div : addOrderOf a ∣ N := by
    rw [ addOrderOf_dvd_iff_nsmul_eq_zero ] ; aesop;
  obtain ⟨ k, hk ⟩ := h_div;
  rcases k with ( _ | _ | k ) <;> simp_all +decide;
  grind

/-! ### Boundary refutation at `k = 1` (electorate of `6` voters) -/

/-
The additive-order-`6` elements of `ZMod 6` are exactly `1` and `5`.
-/
lemma addOrderOf_six_eq {a : ZMod 6} (h : addOrderOf a = 6) : a = 1 ∨ a = 5 := by
  fin_cases a <;> simp_all +decide [ addOrderOf_eq_iff ]

/-
**Boundary obstruction.**  No maximal standard frame on `6 = 2·3` voters has
incoherence index `4`.  Since `4 = 2·1 + 2` and `3 = 2·1 + 1`, this refutes the
literal v19d threshold "`n ≥ 2*k+1`" already at `k = 1, n = 3`.  (The maximality
hypothesis `IsMaximal F` is kept to match the conjecture verbatim; the proof shows
the obstruction holds for *every* frame on `6` voters, maximal or not.)
-/
theorem boundary_obstruction_k1 :
    ¬ ∃ F : Frame 6, IsMaximal F ∧ incoherenceIndex F = 4 := by
  by_contra! h_contra;
  obtain ⟨F, _hmax, hidx⟩ := h_contra
  have h_addOrder : ∀ a ∈ F, addOrderOf a = 6 := by
    exact fun a ha => atoms_generate_of_index_gt_half F ( by linarith [ Nat.div_add_mod 6 2, Nat.mod_lt 6 two_pos ] ) ha;
  -- Let $p$ be a perfectly balanced sequence of length $4$.
  obtain ⟨l, hl_balanced, hl_length⟩ : ∃ l : List (ZMod 6), IsBalanced F l ∧ l.length = 4 := by
    exact hidx ▸ Nat.sInf_mem ( show balancedLengths F |> Set.Nonempty from Set.nonempty_iff_ne_empty.2 <| by rintro h; simp_all +decide [ incoherenceIndex ] );
  -- By assumption, every element in $l$ is either $1$ or $5$.
  have h_elements : ∀ x ∈ l, x = 1 ∨ x = 5 := by
    exact fun x hx => addOrderOf_six_eq ( h_addOrder x ( hl_balanced.2.1 x hx ) );
  -- Therefore, $1 \in F$ and $5 \in F$.
  have h_one_five : 1 ∈ F ∧ 5 ∈ F := by
    have h_one_five : 1 ∈ l ∧ 5 ∈ l := by
      by_cases h1 : 1 ∈ l <;> by_cases h5 : 5 ∈ l <;> simp_all +decide;
      · have h_l_replicate : l = List.replicate l.length 1 := by
          exact List.eq_replicate_of_mem fun x hx => Or.resolve_right ( h_elements x hx ) fun hx' => h5 <| hx'.symm ▸ hx;
        rw [ h_l_replicate, hl_length ] at hl_balanced; simp_all +decide [ IsBalanced ] ;
      · have h_replicate : l = List.replicate l.length 5 := by
          exact List.eq_replicate_of_mem fun x hx => Or.resolve_left ( h_elements x hx ) fun hx' => h1 <| hx'.symm ▸ hx;
        rw [ h_replicate, hl_length ] at hl_balanced; simp_all +decide [ IsBalanced ] ;
      · induction l <;> aesop;
    exact ⟨ hl_balanced.2.1 _ h_one_five.1, hl_balanced.2.1 _ h_one_five.2 ⟩;
  -- The list `[1, 5]` is balanced for `F`: nonempty, both entries in `F`, and `(1 : ZMod 6) + 5 = 0`.
  have h_balanced_two : IsBalanced F [1, 5] := by
    exact ⟨ by decide, by simp +decide [ h_one_five ], by simp +decide ⟩;
  exact absurd hidx ( by exact ne_of_lt <| lt_of_le_of_lt ( Nat.sInf_le ⟨ _, h_balanced_two, rfl ⟩ ) <| by decide )

end SocialChoice.Boundary