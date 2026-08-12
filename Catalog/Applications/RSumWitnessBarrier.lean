/-
# The `r`-SUM witness barrier: arity never compresses the search box

Fourth cycle.  `Catalog/Applications/ThreeSumSearchSpace.lean` proved, for arity
`3`, that a witness with positive entries bounded by `K` exists **iff** `p ≤ 3K`.
The obvious hypothesis — raised as a conjecture at the end of cycle 3 — is that
the same dichotomy holds at every arity `r`, with threshold `p ≤ r·K`.  Here it
is proved.

* `no_rsum_witness_of_small` : if `r·K < p` no `r`-tuple in the box `[1,K]^r`
  has sum divisible by `p`;
* `exists_rsum_witness` : if `r ≤ p ≤ r·K` (and `r ≥ 1`) such a tuple exists,
  by an explicit greedy construction (induction on `r` using `Fin.cons`);
* `rsum_witness_iff` : the exact dichotomy;
* `rsum_entry_size_barrier` : consequently, for a balanced semiprime `N = p*q`
  with `q ≤ 2p`, any arity-`r` search box that contains a witness obeys
  `N ≤ 2·r²·K²`, i.e. `K ≥ √N / (r√2)`.

Interpretation: increasing the arity shrinks the required entry magnitude only
by the *linear* factor `r`, never polynomially.  Combined with
`BirthdayBoundHierarchy.birthday_barrier_sqrt` (the number of inspected
selections must exceed `p` at every arity) both axes of the hierarchy are now
pinned: neither the count nor the magnitude improves past `√N`.
-/
import Mathlib
import Applications.ThreeSumSearchSpace

namespace RSumWitnessBarrier

open Finset

/-- Tuples of the search box: `r` positive entries, each at most `K`. -/
def InBox (K : ℕ) {r : ℕ} (x : Fin r → ℕ) : Prop := ∀ i, 0 < x i ∧ x i ≤ K

/-- Below the threshold there is no witness: the whole box has sums in `[r, rK]`,
which contains no positive multiple of `p` when `r·K < p`. -/
theorem no_rsum_witness_of_small {p K r : ℕ} (hr : 1 ≤ r) (h : r * K < p)
    {x : Fin r → ℕ} (hx : InBox K x) : ¬ p ∣ ∑ i, x i := by
  intro hdvd
  have hub : ∑ i, x i ≤ r * K := by
    calc ∑ i, x i ≤ ∑ _i : Fin r, K := Finset.sum_le_sum (fun i _ => (hx i).2)
      _ = r * K := by simp [mul_comm]
  have hlb : r ≤ ∑ i, x i := by
    calc r = ∑ _i : Fin r, 1 := by simp
      _ ≤ ∑ i, x i := Finset.sum_le_sum (fun i _ => (hx i).1)
  have hpos : 0 < ∑ i, x i := lt_of_lt_of_le hr hlb
  have := Nat.le_of_dvd hpos hdvd
  omega

/-- Above the threshold a witness always exists: an explicit greedy tuple whose
entries lie in `[1,K]` and whose sum is exactly `p`. -/
theorem exists_rsum_witness : ∀ {p K r : ℕ}, 1 ≤ r → r ≤ p → p ≤ r * K →
    ∃ x : Fin r → ℕ, InBox K x ∧ ∑ i, x i = p := by
  intro p K r
  induction r generalizing p with
  | zero => intro hr; omega
  | succ n ih =>
    intro _ hlb hub
    rcases Nat.eq_zero_or_pos n with hn | hn
    · subst hn
      have hub' : p ≤ K := by simpa using hub
      refine ⟨fun _ => p, fun i => ?_, by simp⟩
      show 0 < p ∧ p ≤ K
      exact ⟨by omega, hub'⟩
    · -- peel off one coordinate, greedily as large as possible
      have hK : 1 ≤ K := by nlinarith
      set c := min K (p - n) with hc
      have hc1 : 1 ≤ c := by omega
      have hcK : c ≤ K := by omega
      have hrem_lb : n ≤ p - c := by omega
      have hrem_ub : p - c ≤ n * K := by
        rcases le_or_gt K (p - n) with h | h
        · have : c = K := by omega
          have : p ≤ n * K + K := by
            have : (n + 1) * K = n * K + K := by ring
            omega
          omega
        · have : c = p - n := by omega
          have : p - c = n := by omega
          nlinarith
      obtain ⟨y, hy, hsum⟩ := ih hn hrem_lb hrem_ub
      refine ⟨Fin.cons c y, ?_, ?_⟩
      · intro i
        refine Fin.cases ?_ ?_ i
        · simpa using ⟨hc1, hcK⟩
        · intro j; simpa using hy j
      · rw [Fin.sum_cons, hsum]
        omega

/-- **The `r`-SUM witness dichotomy.**  A witness inside the box `[1,K]^r` exists
if and only if `p ≤ r·K`. -/
theorem rsum_witness_iff {p K r : ℕ} (hr : 1 ≤ r) (hrp : r ≤ p) :
    (∃ x : Fin r → ℕ, InBox K x ∧ p ∣ ∑ i, x i) ↔ p ≤ r * K := by
  constructor
  · rintro ⟨x, hx, hdvd⟩
    by_contra hlt
    push_neg at hlt
    exact no_rsum_witness_of_small hr hlt hx hdvd
  · intro h
    obtain ⟨x, hx, hsum⟩ := exists_rsum_witness hr hrp h
    exact ⟨x, hx, by rw [hsum]⟩

/-- **Entry-magnitude barrier at every arity.**  For a balanced semiprime
`N = p*q` (`q ≤ 2p`), an arity-`r` search box containing a witness satisfies
`N ≤ 2·r²·K²`.  The arity enters only through the linear factor `r`. -/
theorem rsum_entry_size_barrier {N p q K r : ℕ} (hN : N = p * q) (hr : 1 ≤ r) (hrp : r ≤ p)
    (hbal : q ≤ 2 * p) (hw : ∃ x : Fin r → ℕ, InBox K x ∧ p ∣ ∑ i, x i) :
    N ≤ 2 * r ^ 2 * K ^ 2 := by
  have hpK : p ≤ r * K := (rsum_witness_iff hr hrp).1 hw
  have hNle : N ≤ 2 * p * p := by
    rw [hN]
    calc p * q ≤ p * (2 * p) := Nat.mul_le_mul_left p hbal
      _ = 2 * p * p := by ring
  nlinarith [hNle, hpK]

/-- Consistency with the arity-`3` result of the previous cycle: the general
dichotomy specialises to `p ≤ 3K`. -/
theorem threeSum_case {p K : ℕ} (hp : 3 ≤ p) :
    (∃ x : Fin 3 → ℕ, InBox K x ∧ p ∣ ∑ i, x i) ↔ p ≤ 3 * K :=
  rsum_witness_iff (by norm_num) hp

end RSumWitnessBarrier