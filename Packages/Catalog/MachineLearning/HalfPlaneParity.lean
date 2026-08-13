import MachineLearning.HalfPlaneSemiprime

/-!
# Cycle 3: the parity of the half-plane count is diagonal-local

The half-plane cut `x + y < N/2` is symmetric under the swap `(x,y) ↦ (y,x)`.
Consequently the parity of the non-separable count `H(N)` is decided entirely by
the *diagonal* solutions `x = y`, i.e. by the square roots of `1/2`:

  `H(N) ≡ #{x < N/4 : 2x² ≡ 1 (mod N)}  (mod 2)`.

Together with the reflection identity `H = high + 2R`, the same congruence holds
for the corner count `high(N)`.  So the non-separable object `H` is locally
determined *modulo 2*: any factor-dependent information it carries lives in its
higher-order bits.

We also record two sharpness facts:

* `exists_eight_mul_highCount_gt` : the constant `4` in `4·high(N) ≤ C(N)` cannot be
  improved to `8` (`N = 9`);
* `highCount_not_multiplicative` : the corner count is genuinely non-separable
  (`high(33) = 4` but `high(3)·high(11) = 0`).
-/

namespace HalfPlane

open Finset

/-- Diagonal points of the low half-plane: `x = y` forces `2x² ≡ 1 (mod N)` and
`4x < N`. -/
def fixDiagFinset (N : ℕ) : Finset ℕ :=
  (Finset.range N).filter (fun x => (2 * x ^ 2) % N = 1 % N ∧ 4 * x < N)

/-- The number of diagonal points of the low half-plane. -/
def fixDiagCount (N : ℕ) : ℕ := (fixDiagFinset N).card

/-- The low half-plane is stable under the swap `(x,y) ↦ (y,x)`. -/
lemma swap_mem_lowFinset {N : ℕ} {p : ℕ × ℕ} (hp : p ∈ lowFinset N) :
    (p.2, p.1) ∈ lowFinset N := by
  rw [mem_lowFinset] at hp ⊢
  obtain ⟨⟨h1, h2, hc⟩, hs⟩ := hp
  refine ⟨⟨h2, h1, ?_⟩, by simpa using (by omega : 2 * (p.2 + p.1) < N)⟩
  show (p.2 ^ 2 + p.1 ^ 2) % N = 1 % N
  have hcomm : p.2 ^ 2 + p.1 ^ 2 = p.1 ^ 2 + p.2 ^ 2 := by ring
  rw [hcomm]
  exact hc

/-- The diagonal part of the low half-plane is parametrised by `x`. -/
theorem card_diag_eq_fixDiagCount (N : ℕ) :
    ((lowFinset N).filter (fun p => p.1 = p.2)).card = fixDiagCount N := by
  refine Finset.card_bij (fun p _ => p.1) ?_ ?_ ?_
  · intro p hp
    rw [Finset.mem_filter, mem_lowFinset] at hp
    obtain ⟨⟨⟨h1, h2, hc⟩, hs⟩, hdiag⟩ := hp
    simp only [fixDiagFinset, Finset.mem_filter, Finset.mem_range]
    refine ⟨h1, ?_, by omega⟩
    rw [← hdiag] at hc
    have hdbl : p.1 ^ 2 + p.1 ^ 2 = 2 * p.1 ^ 2 := by ring
    rwa [hdbl] at hc
  · intro p hp q hq hpq
    rw [Finset.mem_filter] at hp hq
    have h1 : p.1 = q.1 := hpq
    have hd1 : p.1 = p.2 := hp.2
    have hd2 : q.1 = q.2 := hq.2
    exact Prod.ext h1 (by omega)
  · intro x hx
    simp only [fixDiagFinset, Finset.mem_filter, Finset.mem_range] at hx
    obtain ⟨hx1, hx2, hx3⟩ := hx
    have hmem : ((x, x) : ℕ × ℕ) ∈ lowFinset N := by
      rw [mem_lowFinset]
      refine ⟨⟨hx1, hx1, ?_⟩, by simpa using (by omega : 2 * (x + x) < N)⟩
      show (x ^ 2 + x ^ 2) % N = 1 % N
      have hdbl : x ^ 2 + x ^ 2 = 2 * x ^ 2 := by ring
      rw [hdbl]
      exact hx2
    exact ⟨(x, x), Finset.mem_filter.mpr ⟨hmem, rfl⟩, rfl⟩

/-- The off-diagonal part of the low half-plane is split in two equal halves by the
swap `(x,y) ↦ (y,x)`. -/
theorem card_offdiag_even (N : ℕ) :
    (((lowFinset N).filter (fun p => ¬ p.1 = p.2)).filter (fun p => p.1 < p.2)).card
      = (((lowFinset N).filter (fun p => ¬ p.1 = p.2)).filter (fun p => ¬ p.1 < p.2)).card := by
  refine Finset.card_bij' (fun p _ => (p.2, p.1)) (fun p _ => (p.2, p.1)) ?_ ?_ ?_ ?_
  · intro p hp
    rw [Finset.mem_filter, Finset.mem_filter] at hp ⊢
    obtain ⟨⟨hmem, hne⟩, hlt⟩ := hp
    refine ⟨⟨swap_mem_lowFinset hmem, ?_⟩, ?_⟩
    · show ¬ (p.2 = p.1)
      omega
    · show ¬ (p.2 < p.1)
      omega
  · intro p hp
    rw [Finset.mem_filter, Finset.mem_filter] at hp ⊢
    obtain ⟨⟨hmem, hne⟩, hlt⟩ := hp
    refine ⟨⟨swap_mem_lowFinset hmem, ?_⟩, ?_⟩
    · show ¬ (p.2 = p.1)
      omega
    · show p.2 < p.1
      omega
  · intro p _; rfl
  · intro p _; rfl

/-- **Parity of the half-plane count.**  `H(N) ≡ #{x : 2x² ≡ 1, 4x < N} (mod 2)`:
the swap symmetry cancels everything off the diagonal. -/
theorem halfPlaneCount_parity (N : ℕ) :
    halfPlaneCount N % 2 = fixDiagCount N % 2 := by
  have hsplit : ((lowFinset N).filter (fun p => p.1 = p.2)).card
      + ((lowFinset N).filter (fun p => ¬ p.1 = p.2)).card = (lowFinset N).card :=
    Finset.card_filter_add_card_filter_not (s := lowFinset N) (p := fun p => p.1 = p.2)
  have hoff : (((lowFinset N).filter (fun p => ¬ p.1 = p.2)).filter (fun p => p.1 < p.2)).card
      + (((lowFinset N).filter (fun p => ¬ p.1 = p.2)).filter (fun p => ¬ p.1 < p.2)).card
      = ((lowFinset N).filter (fun p => ¬ p.1 = p.2)).card :=
    Finset.card_filter_add_card_filter_not
      (s := (lowFinset N).filter (fun p => ¬ p.1 = p.2)) (p := fun p => p.1 < p.2)
  have hhalf := card_offdiag_even N
  have hdiag := card_diag_eq_fixDiagCount N
  rw [halfPlaneCount_eq_card_low]
  omega

/-- The same congruence for the corner count: `high(N) ≡ H(N) (mod 2)` for `N ≥ 2`. -/
theorem highCount_parity (N : ℕ) (hN : 2 ≤ N) :
    highCount N % 2 = fixDiagCount N % 2 := by
  have hid := halfPlaneCount_eq_highCount_add N hN
  have hpar := halfPlaneCount_parity N
  omega

/-! ### Sharpness and the genuine non-separability of the corner count -/

/-- The constant `4` in `4·high(N) ≤ C(N)` cannot be improved to `8`:
at `N = 9` one has `high = 2` while `C = 12 < 16`. -/
theorem exists_eight_mul_highCount_gt :
    ∃ N : ℕ, 3 ≤ N ∧ circleCount N < 8 * highCount N := by
  refine ⟨9, by norm_num, ?_⟩
  have h1 : circleCount 9 = 12 := by decide
  have h2 : highCount 9 = 2 := by decide
  omega

/-- **The corner count is not CRT-separable either.** -/
theorem highCount_not_multiplicative :
    Nat.Coprime 3 11 ∧ highCount (3 * 11) ≠ highCount 3 * highCount 11 := by
  refine ⟨by decide, ?_⟩
  have h1 : highCount (3 * 11) = 4 := by decide
  have h2 : highCount 3 * highCount 11 = 0 := by decide
  omega

/-! ### Lab notes (cycle 3)

```
N     :  3  5  7  9 15 16 17 24 25 31 33 35
H(N)  :  2  2  2  4  4  6  3 12  6  7  8  6
diag  :  0  0  0  0  0  0  1  0  0  1  0  0
H mod 2: 0  0  0  0  0  0  1  0  0  1  0  0
```
The parity of `H` tracks the diagonal count exactly (checked by full enumeration
for all `N < 80`).  Note `N = 17`: `2·6² = 72 ≡ 4`, while `x = 3` gives
`2·9 = 18 ≡ 1 (mod 17)` and `4·3 = 12 < 17`, so the diagonal contributes one point
and `H(17) = 3` is odd.
-/

example : halfPlaneCount 17 % 2 = fixDiagCount 17 % 2 := by decide
example : fixDiagCount 17 = 1 := by decide
example : highCount 31 % 2 = 1 := by decide

end HalfPlane